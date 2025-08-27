# Dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io).

## Features

- **Cross-platform**: Works on Windows, macOS, and Linux
- **Templating**: OS-specific configurations using chezmoi templates
- **tmux configuration**: Enhanced tmux setup with mouse support, vi-mode, and platform-specific clipboard integration
- **Safe secrets**: Excludes sensitive files and provides patterns for secure secret management

## Quick Start

### 🚀 One-line install (Cross-platform)

**Automatic OS detection** - works on Windows (Git Bash/WSL), Linux, and macOS:

```bash
curl -fsSL https://raw.githubusercontent.com/amitse/dotfiles/main/bootstrap.sh | bash
```

**Options:**
```bash
# Dry run (preview only)
curl -fsSL https://raw.githubusercontent.com/amitse/dotfiles/main/bootstrap.sh | bash -s -- --dry-run

# Force reinstall
curl -fsSL https://raw.githubusercontent.com/amitse/dotfiles/main/bootstrap.sh | bash -s -- --force

# Custom repo
curl -fsSL https://raw.githubusercontent.com/amitse/dotfiles/main/bootstrap.sh | bash -s -- --repo https://github.com/yourusername/dotfiles.git
```

### 🐧 Linux only (simple)

```bash
curl -fsSL https://raw.githubusercontent.com/amitse/dotfiles/main/install-linux.sh | bash
```

### 🪟 Windows (PowerShell)

**Automated (recommended):**
```powershell
# Download and run bootstrap script
irm https://raw.githubusercontent.com/amitse/dotfiles/main/bootstrap.ps1 | iex

# Or with parameters
.\bootstrap.ps1 -DryRun
.\bootstrap.ps1 -Force
```

**Manual installation:**
```powershell
# Install chezmoi (choose one method)
winget install twpayne.chezmoi
# OR with Scoop
scoop install chezmoi
# OR with Chocolatey  
choco install chezmoi

# Initialize with your dotfiles repo
chezmoi init https://github.com/amitse/dotfiles.git

# Review what would be applied (dry run)
chezmoi diff

# Apply the dotfiles
chezmoi apply
```

### 🍎 macOS (Manual)

```bash
# Install chezmoi
brew install chezmoi

# Initialize with your dotfiles repo
chezmoi init https://github.com/amitse/dotfiles.git

# Review what would be applied
chezmoi diff

# Apply the dotfiles
chezmoi apply
```

### 🐧 Linux (Manual)

```bash
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# Or with package managers
# Ubuntu/Debian:
sudo apt install chezmoi
# Arch Linux:
sudo pacman -S chezmoi
# Homebrew (macOS/Linux):
brew install chezmoi

# Initialize with your dotfiles repo
chezmoi init https://github.com/amitse/dotfiles.git

# Review what would be applied
chezmoi diff

# Apply the dotfiles
chezmoi apply
```

## Usage

### Daily workflow

```bash
# Edit a managed file (opens in your $EDITOR)
chezmoi edit ~/.tmux.conf

# Or edit the template directly
chezmoi edit --apply ~/.tmux.conf

# See what has changed
chezmoi diff

# Apply changes
chezmoi apply

# Add a new file to be managed
chezmoi add ~/.config/git/config

# Commit and push changes
chezmoi cd
git add .
git commit -m "Update tmux config"
git push
exit
```

### Managing secrets

chezmoi provides several ways to handle secrets securely:

1. **Environment variables**: Use templates with `{{ .Env.SECRET_NAME }}`
2. **External tools**: Integration with 1Password, Bitwarden, etc.
3. **Age encryption**: Encrypt sensitive files with age
4. **GPG**: Traditional GPG encryption

Example with environment variables:
```bash
# Add secret to environment (e.g., in your shell profile)
export GITHUB_TOKEN="your_token_here"

# Use in templates
{{ .Env.GITHUB_TOKEN }}
```

## Files included

- `.tmux.conf` - tmux configuration with:
  - Ctrl-a prefix
  - Mouse support
  - Vi-mode copy
  - Cross-platform clipboard integration:
    - **Windows**: `clip.exe`
    - **Linux**: `wl-copy` (Wayland) → `xclip` → `xsel` → fallback
    - **macOS**: `pbcopy`
  - 256-color support
  - Sensible defaults

## Customization

### Adding new files

```bash
# Add an existing file
chezmoi add ~/.config/app/config.yaml

# Create a new templated file
chezmoi add --template ~/.config/app/config.yaml
```

### OS-specific configurations

Use chezmoi's templating to create OS-specific sections:

```tmux
{{- if eq .chezmoi.os "windows" }}
# Windows-specific tmux settings
{{- else if eq .chezmoi.os "darwin" }}
# macOS-specific tmux settings  
{{- else }}
# Linux-specific tmux settings
{{- end }}
```

### Machine-specific configurations

```tmux
{{- if eq .chezmoi.hostname "work-laptop" }}
# Work-specific settings
{{- else if eq .chezmoi.hostname "home-desktop" }}
# Personal machine settings
{{- end }}
```

## File naming conventions

chezmoi uses special prefixes for file names:

- `dot_` → `.` (creates dotfiles)
- `private_` → private files (600 permissions)
- `executable_` → executable files (755 permissions)
- `symlink_` → symbolic links
- `.tmpl` → template files (processed by chezmoi)

Examples:
- `dot_tmux.conf.tmpl` → `~/.tmux.conf` (templated)
- `private_dot_ssh/config` → `~/.ssh/config` (private)
- `executable_dot_local/bin/script` → `~/.local/bin/script` (executable)

## Troubleshooting

### Check chezmoi status
```bash
chezmoi doctor
```

### View what chezmoi would do
```bash
chezmoi diff
```

### Debug template rendering
```bash
chezmoi execute-template < template_file.tmpl
```

### Force update a file
```bash
chezmoi apply --force ~/.tmux.conf
```

## Linux Dependencies

For full tmux clipboard integration on Linux, install one of:

```bash
# Wayland (recommended for modern Linux)
sudo apt install wl-clipboard    # Ubuntu/Debian
sudo pacman -S wl-clipboard      # Arch Linux

# X11 systems
sudo apt install xclip           # Ubuntu/Debian
sudo pacman -S xclip             # Arch Linux
# OR
sudo apt install xsel            # Ubuntu/Debian
sudo pacman -S xsel              # Arch Linux
```

The tmux config will automatically detect and use the best available clipboard tool.

## Bootstrap Scripts

Multiple automated installation options:

- **`bootstrap.sh`** - Cross-platform script (Windows/Linux/macOS)
- **`bootstrap.ps1`** - Windows PowerShell script
- **`install-linux.sh`** - Simple Linux-only script

All scripts support dry-run mode and automatic dependency installation.

## Resources

- [chezmoi documentation](https://chezmoi.io/)
- [chezmoi quick start](https://chezmoi.io/quick-start/)
- [Template functions](https://chezmoi.io/user-guide/templating/)
- [Managing secrets](https://chezmoi.io/user-guide/password-managers/)