# Secrets Management Implementation Plan

## Overview
Implement comprehensive secrets management for the dotfiles repository with multiple backend support, following chezmoi best practices.

## Supported Backends

### 1. 1Password (Primary)
- **Command Line Tool**: `op`
- **URL Format**: `op://vault/item/field`
- **Template Function**: `secret "op://Personal/GitHub Token/credential"`

### 2. Bitwarden
- **Command Line Tool**: `bw`
- **URL Format**: `bw://item-id/field`
- **Template Function**: `secret "bw://github-token/password"`

### 3. Environment Variables
- **URL Format**: `env://VARIABLE_NAME`
- **Template Function**: `secret "env://GITHUB_TOKEN"`

### 4. File-based Secrets
- **URL Format**: `file://path/to/secret`
- **Template Function**: `secret "file://~/.secrets/github_token"`

## Implementation Structure

### Template Function (`templates/secret`)
```tmpl
{{- define "secret" -}}
{{- $url := . -}}
{{- if hasPrefix $url "op://" -}}
  {{- output "op" "read" $url | trim -}}
{{- else if hasPrefix $url "bw://" -}}
  {{- $parts := split "/" $url -}}
  {{- $itemId := index $parts 2 -}}
  {{- $field := index $parts 3 | default "password" -}}
  {{- output "bw" "get" "password" $itemId "--session" (env "BW_SESSION") | trim -}}
{{- else if hasPrefix $url "env://" -}}
  {{- $varName := slice $url 6 -}}
  {{- env $varName -}}
{{- else if hasPrefix $url "file://" -}}
  {{- $filePath := slice $url 7 -}}
  {{- if hasPrefix $filePath "~/" -}}
    {{- $filePath = printf "%s/%s" .chezmoi.homeDir (slice $filePath 2) -}}
  {{- end -}}
  {{- include $filePath | trim -}}
{{- else -}}
  {{- fail (printf "Unsupported secret URL format: %s" $url) -}}
{{- end -}}
{{- end -}}
```

### Configuration Template (`.chezmoi.toml.tmpl`)
Add secrets configuration section:

```toml
[data.secrets]
    # Preferred secret backend (op, bw, env, file)
    backend = "{{ promptString "secrets_backend" "Choose secrets backend (op/bw/env/file)" "env" }}"
    
    # 1Password vault (if using op)
    {{- if eq .secrets.backend "op" }}
    op_account = "{{ promptString "op_account" "1Password account/subdomain" "" }}"
    op_vault = "{{ promptString "op_vault" "1Password vault name" "Personal" }}"
    {{- end }}
    
    # Bitwarden session (if using bw)
    {{- if eq .secrets.backend "bw" }}
    bw_server = "{{ promptString "bw_server" "Bitwarden server URL" "https://bitwarden.com" }}"
    {{- end }}
```

### Secret Files to Manage

#### Git Configuration (`dot_gitconfig.tmpl`)
```ini
[user]
    name = "{{ .user.name }}"
    email = "{{ .user.email }}"

[github]
    {{- if .data.secrets }}
    user = "{{ .user.name }}"
    token = "{{ template "secret" "op://Personal/GitHub Token/credential" }}"
    {{- end }}

[credential "https://github.com"]
    helper = 
    {{- if eq .chezmoi.os "windows" }}
    helper = manager-core
    {{- else if eq .chezmoi.os "darwin" }}
    helper = osxkeychain
    {{- else }}
    helper = cache --timeout=3600
    {{- end }}
```

#### SSH Configuration (`private_dot_ssh/config.tmpl`)
```ssh
# Personal GitHub
Host github.com
    HostName github.com
    User git
    {{- if template "secret" "op://Personal/SSH Key/private_key" }}
    IdentityFile ~/.ssh/github_personal
    {{- end }}
    IdentitiesOnly yes

# Work GitHub
Host github-work
    HostName github.com
    User git
    {{- if template "secret" "op://Work/SSH Key/private_key" }}
    IdentityFile ~/.ssh/github_work
    {{- end }}
    IdentitiesOnly yes
```

#### Environment Secrets (`dot_secrets.env.tmpl`)
```bash
# API Keys
{{- if .data.features.github_integration }}
GITHUB_TOKEN="{{ template "secret" "op://Personal/GitHub Token/credential" }}"
{{- end }}

# Development Database URLs
DATABASE_URL="{{ template "secret" "op://Development/Database/url" }}"

# Cloud Provider Credentials
AWS_ACCESS_KEY_ID="{{ template "secret" "op://AWS/Access Key/username" }}"
AWS_SECRET_ACCESS_KEY="{{ template "secret" "op://AWS/Access Key/password" }}"
{{- end }}
```

## Setup Scripts

### 1Password Setup (`run_once_after_40-setup-1password.sh.tmpl`)
```bash
#!/bin/bash
{{- if eq .data.secrets.backend "op" }}
# Install 1Password CLI if not present
if ! command -v op &> /dev/null; then
    echo "Installing 1Password CLI..."
    {{- if eq .chezmoi.os "darwin" }}
    brew install 1password-cli
    {{- else if eq .chezmoi.os "linux" }}
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
    sudo apt update && sudo apt install 1password-cli
    {{- end }}
fi

# Authenticate with 1Password (user needs to do this manually)
if ! op account list &> /dev/null; then
    echo "Please authenticate with 1Password:"
    echo "op account add --address {{ .data.secrets.op_account }}.1password.com"
fi
{{- end }}
```

### Bitwarden Setup (`run_once_after_41-setup-bitwarden.sh.tmpl`)
```bash
#!/bin/bash
{{- if eq .data.secrets.backend "bw" }}
# Install Bitwarden CLI if not present
if ! command -v bw &> /dev/null; then
    echo "Installing Bitwarden CLI..."
    {{- if eq .chezmoi.os "darwin" }}
    brew install bitwarden-cli
    {{- else }}
    npm install -g @bitwarden/cli
    {{- end }}
fi

# Configure Bitwarden server
bw config server {{ .data.secrets.bw_server }}

# Authenticate (user needs to do this manually)
if [[ -z "$BW_SESSION" ]]; then
    echo "Please authenticate with Bitwarden:"
    echo "bw login"
    echo "export BW_SESSION=\"\$(bw unlock --raw)\""
fi
{{- end }}
```

## Usage Examples

### In Templates
```bash
# Simple secret reference
export GITHUB_TOKEN="{{ template "secret" "op://Personal/GitHub Token/credential" }}"

# Production secrets
export AWS_ACCESS_KEY="{{ template "secret" "op://AWS/Production/access_key" }}"

# Fallback to environment variable
export DATABASE_URL="{{ template "secret" "env://DATABASE_URL" }}"
```

### Security Best Practices

1. **Never commit actual secrets** - Only commit templates
2. **Use appropriate backend** - 1Password/Bitwarden for personal, env vars for CI/CD
3. **Rotate secrets regularly** - Template makes this easy
4. **Use least privilege** - Different secrets for different environments
5. **Backup secret references** - Document secret locations in password manager

## Testing Strategy

### Test Script (`scripts/test-secrets.sh`)
```bash
#!/bin/bash
# Test secrets management functionality

echo "Testing secrets management..."

# Test template function with different backends
test_backends=("env://TEST_SECRET" "file://~/.test_secret")

for backend in "${test_backends[@]}"; do
    echo "Testing backend: $backend"
    if chezmoi execute-template --config /dev/null <<< "{{ template \"secret\" \"$backend\" }}"; then
        echo "✅ $backend works"
    else
        echo "❌ $backend failed"
    fi
done
```

## Migration Plan

1. **Phase 1**: Implement template function and basic structure
2. **Phase 2**: Add 1Password and environment variable support
3. **Phase 3**: Add Bitwarden and file-based secrets
4. **Phase 4**: Create setup scripts and documentation
5. **Phase 5**: Migrate existing hardcoded values to secrets

## Documentation

- Add secrets section to main README
- Create detailed guide in `docs/SECRETS.md`
- Update documentation with secret requirements
- Add troubleshooting guide for common secret issues