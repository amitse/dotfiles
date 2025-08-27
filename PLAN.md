# Dotfiles Maintainability Enhancement Plan

**Status**: In Progress  
**Started**: August 27, 2025  
**Goal**: Transform the dotfiles repository into a highly maintainable, modular, and user-friendly system

## 🎯 Overview

This plan addresses the "overwhelming" nature of the current dotfiles setup by implementing:
- **Modular architecture** using chezmoi best practices
- **Smart dependency management** with fallbacks
- **Automated setup and maintenance** via chezmoi scripts
- **Profile-based configuration** for different user types
- **Advanced secrets management** with multiple backend support
- **Improved documentation** with context-aware help

## 📁 New Directory Structure

```
dotfiles/
├── 📄 PLAN.md                           # This file
├── 📄 README.md                         # Simple getting started
├── 🚀 install.sh                        # Universal installer
├── 
├── 📂 .chezmoi/                         # chezmoi configuration
│   ├── 📄 chezmoi.toml.tmpl            # Main config with data
│   └── 📂 templates/                    # Shared template functions
│       ├── 📄 platform-detect.tmpl     # OS/platform detection
│       ├── 📄 tool-check.tmpl          # Tool availability checks
│       └── 📄 version-check.tmpl       # Version comparison helpers
│
├── 📂 .chezmoiscripts/                  # Automation scripts
│   ├── 📄 run_once_before_00-setup-package-managers.sh.tmpl
│   ├── 📄 run_once_before_10-install-essential-tools.sh.tmpl
│   ├── 📄 run_once_before_20-install-modern-cli-tools.sh.tmpl
│   ├── 📄 run_after_30-configure-shell.sh.tmpl
│   ├── 📄 run_onchange_40-update-tools.sh.tmpl
│   └── 📄 run_once_after_90-setup-complete.sh.tmpl
│
├── 📂 _partials/                        # Modular configuration pieces
│   ├── 📂 shell/                        # Shell configurations
│   │   ├── 📄 core.sh.tmpl             # Basic shell settings
│   │   ├── 📄 aliases.sh.tmpl          # Smart aliases
│   │   ├── 📄 functions.sh.tmpl        # Useful functions
│   │   ├── 📄 history.sh.tmpl          # History configuration
│   │   └── 📂 prompts/                 # Different prompt styles
│   │       ├── 📄 minimal.sh.tmpl      # Simple prompt
│   │       ├── 📄 git-aware.sh.tmpl    # Git-integrated prompt
│   │       └── 📄 powerline.sh.tmpl    # Advanced prompt
│   │
│   ├── 📂 tools/                        # Modern CLI tool configs
│   │   ├── 📄 fzf.sh.tmpl              # Fuzzy finder setup
│   │   ├── 📄 zoxide.sh.tmpl           # Smart directory jumping
│   │   ├── 📄 modern-aliases.sh.tmpl   # bat, rg, exa aliases
│   │   ├── 📄 git-enhanced.sh.tmpl     # Advanced git integration
│   │   └── 📄 github-cli.sh.tmpl       # GitHub CLI integration
│   │
│   ├── 📂 platforms/                    # Platform-specific configs
│   │   ├── 📄 linux.sh.tmpl            # Linux-specific settings
│   │   ├── 📄 macos.sh.tmpl            # macOS-specific settings
│   │   ├── 📄 windows.sh.tmpl          # Windows/WSL settings
│   │   └── 📄 common.sh.tmpl           # Cross-platform base
│   │
│   └── 📂 profiles/                     # Configuration profiles
│       ├── 📄 minimal.sh.tmpl          # Basic setup
│       ├── 📄 developer.sh.tmpl        # Development tools
│       └── 📄 power-user.sh.tmpl       # Everything enabled
│
├── 📂 configs/                          # Main configuration files
│   ├── 📄 dot_gitconfig.tmpl           # Git configuration
│   ├── 📄 dot_tmux.conf.tmpl           # tmux configuration
│   ├── 📄 dot_zshrc.tmpl               # Zsh main config (modular)
│   ├── 📂 dot_config/                  # XDG config files
│   │   ├── 📂 bat/
│   │   │   └── 📄 config.tmpl          # bat configuration
│   │   ├── 📂 ripgrep/
│   │   │   └── 📄 config               # ripgrep configuration
│   │   └── 📂 shell/
│   │       └── 📄 aliases.sh.tmpl      # Shell aliases
│   │
│   └── 📂 Documents/                    # Platform-specific configs
│       └── 📂 PowerShell/
│           └── 📄 Microsoft.PowerShell_profile.ps1.tmpl
│
├── 📂 scripts/                          # Utility scripts
│   ├── 📄 health-check.sh              # System health checker (Linux/macOS/Git Bash)
│   ├── 📄 health-check.ps1             # System health checker (Windows PowerShell)
│   ├── 📄 update-all.sh                # Update all tools
│   ├── 📄 backup-configs.sh            # Backup current configs
│   └── 📄 chezmoi-help.sh              # Interactive help system
│
├── 📂 docs/                             # Documentation
│   ├── 📄 GETTING-STARTED.md           # Quick start guide
│   ├── 📄 CUSTOMIZATION.md             # How to customize
│   ├── 📄 TROUBLESHOOTING.md           # Common issues
│   ├── 📄 PROFILES.md                  # Profile system guide
│   ├── 📄 SECRETS.md                   # Secrets management
│   └── 📄 ADVANCED.md                  # Advanced usage
│
├── 📂 legacy/                           # Old files (will be removed)
│   ├── 📄 bootstrap.ps1                # Will be replaced
│   ├── 📄 bootstrap.sh                 # Will be replaced
│   └── 📄 install-linux.sh             # Will be replaced
│
└── 📄 .chezmoiignore                    # Files to ignore
```

## 🚀 Implementation Phases

### Phase 1: Foundation & Infrastructure (Week 1)

**Priority**: High Impact, Low Effort  
**Time Estimate**: 4-6 hours

#### 1.1 Core Setup
- [x] ✅ Create unified `install.sh`
- [ ] 🔄 Create `PLAN.md` (this document)
- [ ] 📁 Reorganize directory structure
- [ ] 📄 Create `.chezmoi/chezmoi.toml.tmpl` with data-driven config
- [ ] 🧪 Add basic tool detection templates

#### 1.2 Basic Modularization
- [ ] 📂 Create `_partials/` directory structure
- [ ] 🔧 Split `dot_zshrc.tmpl` into modular pieces
- [ ] 🔍 Implement `lookPath` checks in existing templates
- [ ] 📋 Create basic health check script

#### 1.3 Documentation Restructure
- [ ] 📚 Move detailed docs to `docs/` directory
- [ ] ✏️ Simplify main `README.md` to single command
- [ ] 📖 Create getting started guide

**Success Criteria**:
- Single command installation works
- Basic modular shell config loads
- Health check script shows system status

### Phase 2: Profile System & Smart Dependencies (Week 2)

**Priority**: Medium Effort, High Value  
**Time Estimate**: 6-8 hours

#### 2.1 Configuration Profiles
- [ ] 📊 Implement profile system in `.chezmoi/chezmoi.toml.tmpl`
  - Minimal profile (git + tmux)
  - Developer profile (+ modern CLI tools)
  - Power user profile (everything)
- [ ] 🎛️ Create profile-specific configurations in `_partials/profiles/`
- [ ] 🤖 Add interactive profile selection to installer

#### 2.2 Advanced Dependency Management
- [ ] 🔍 Smart tool detection with version checking
- [ ] 🔄 Intelligent fallback systems
- [ ] 📦 Tool installation via chezmoi scripts
- [ ] ⚠️ Graceful degradation when tools unavailable

#### 2.3 Automation Scripts
- [ ] 📜 Create `.chezmoiscripts/` for automated setup
- [ ] 🔧 Package manager detection and tool installation
- [ ] 🔄 Update scripts that run on configuration changes
- [ ] ✅ Post-installation validation and setup

**Success Criteria**:
- Profile selection works during installation
- Tools install automatically based on profile
- Configurations adapt to available tools
- Setup scripts handle different environments

### Phase 3: Advanced Features & Secrets (Week 3)

**Priority**: High Value, Medium Effort  
**Time Estimate**: 4-6 hours

#### 3.1 Secrets Management
- [ ] 🔐 Integrate multiple secret backends:
  - 1Password CLI
  - Bitwarden CLI
  - Environment variables (fallback)
  - GPG encryption
- [ ] 🛡️ Secure git configuration with tokens
- [ ] 🔑 SSH key management examples

#### 3.2 Advanced Tool Integration
- [ ] 🎨 Context-aware prompt system
- [ ] 🔄 Auto-updating tool configurations
- [ ] 📊 Advanced FZF integration with previews
- [ ] 🚀 GitHub CLI deep integration

#### 3.3 Maintenance Automation
- [ ] 🔄 Auto-update system for tools and configs
- [ ] 📊 Configuration drift detection
- [ ] 🧹 Cleanup scripts for old installations
- [ ] 📈 Usage analytics and optimization suggestions

**Success Criteria**:
- Secrets work with multiple backends
- Advanced tool features function correctly
- System maintains itself with minimal intervention

### Phase 4: Polish & User Experience (Week 4)

**Priority**: User Experience Enhancement  
**Time Estimate**: 3-4 hours

#### 4.1 Enhanced Documentation
- [ ] 📚 Context-aware help system
- [ ] 🎥 Create setup walkthrough examples
- [ ] 🐛 Comprehensive troubleshooting guide
- [ ] 🎯 Profile-specific documentation

#### 4.2 User Experience Improvements
- [ ] 🎨 Colorized output and progress indicators
- [ ] 📋 Interactive configuration wizard
- [ ] 🔍 Better error messages and suggestions
- [ ] 🎉 Success confirmation with next steps

#### 4.3 Testing & Validation
- [ ] 🧪 Test on multiple platforms and environments
- [ ] 📝 Create validation test suite
- [ ] 🔄 CI/CD for testing installations
- [ ] 📊 Performance optimization

**Success Criteria**:
- Smooth user experience from install to daily use
- Clear guidance at every step
- Robust testing coverage
- Excellent error handling

## 📋 Configuration Data Structure

### `.chezmoi/chezmoi.toml.tmpl` Example

```toml
{{- $profile := promptString "profile" "Choose profile (minimal/developer/power-user)" "developer" -}}
{{- $gitName := promptString "git_name" "Git user name" (env "USER") -}}
{{- $gitEmail := promptString "git_email" "Git email" "" -}}

[data]
    profile = "{{ $profile }}"
    
    [data.user]
        name = "{{ $gitName }}"
        email = "{{ $gitEmail }}"
    
    [data.features]
        {{- if eq $profile "minimal" }}
        modern_cli = false
        developer_tools = false
        advanced_git = false
        {{- else if eq $profile "developer" }}
        modern_cli = true
        developer_tools = true
        advanced_git = true
        {{- else if eq $profile "power-user" }}
        modern_cli = true
        developer_tools = true
        advanced_git = true
        powerline_prompt = true
        github_integration = true
        {{- end }}
    
    [data.tools]
        {{- if eq $profile "minimal" }}
        essential = ["git", "tmux"]
        {{- else if eq $profile "developer" }}
        essential = ["git", "tmux", "fzf", "ripgrep", "bat", "zoxide"]
        {{- else if eq $profile "power-user" }}
        essential = ["git", "tmux", "fzf", "ripgrep", "bat", "zoxide", "exa", "entr", "gh", "delta"]
        {{- end }}
    
    [data.paths]
        workspace = "{{ if eq .chezmoi.os "windows" }}C:\\Workspace{{ else }}~/workspace{{ end }}"
        dotfiles = "{{ .chezmoi.sourceDir }}"
```

## 🔧 Template Function Examples

### Smart Tool Detection

```go-template
{{/* Check if tool is available and get version */}}
{{- define "tool-available" -}}
{{- $tool := . -}}
{{- if lookPath $tool -}}
{{- $version := output $tool "--version" | regexFind "\\d+\\.\\d+\\.\\d+" -}}
{{- dict "available" true "version" $version -}}
{{- else -}}
{{- dict "available" false "version" "" -}}
{{- end -}}
{{- end -}}

{{/* Usage in templates */}}
{{- $fzf := include "tool-available" "fzf" | fromJson -}}
{{- if $fzf.available }}
# FZF is available (version {{ $fzf.version }})
{{- if semverCompare ">=0.30.0" $fzf.version }}
# Use advanced features
{{- else }}
# Use basic features
{{- end }}
{{- end }}
```

### Platform-Specific Configurations

```go-template
{{/* Load platform-specific configuration */}}
{{- if eq .chezmoi.os "linux" }}
{{ include "_partials/platforms/linux.sh.tmpl" . }}
{{- else if eq .chezmoi.os "darwin" }}
{{ include "_partials/platforms/macos.sh.tmpl" . }}
{{- else if eq .chezmoi.os "windows" }}
{{ include "_partials/platforms/windows.sh.tmpl" . }}
{{- end }}
```

## 📊 Progress Tracking

### Week 1 Tasks
- [ ] Directory restructure
- [ ] Basic modularization
- [ ] Tool detection system
- [ ] Health check script
- [ ] Documentation organization

### Week 2 Tasks
- [ ] Profile system implementation
- [ ] Smart dependency management
- [ ] Automation scripts
- [ ] Interactive installer

### Week 3 Tasks
- [ ] Secrets management
- [ ] Advanced tool integration
- [ ] Auto-update system
- [ ] Maintenance automation

### Week 4 Tasks
- [ ] Enhanced documentation
- [ ] User experience polish
- [ ] Testing and validation
- [ ] Performance optimization

## 🎯 Success Metrics

### Technical Metrics
- ✅ Single command installation (< 2 minutes)
- ✅ Zero configuration errors on fresh systems
- ✅ 100% backward compatibility
- ✅ Support for 3 profiles (minimal/developer/power-user)
- ✅ Works on Windows, Linux, macOS

### User Experience Metrics
- ✅ Clear next steps after installation
- ✅ Context-aware help system
- ✅ Self-healing configurations
- ✅ Easy customization process
- ✅ Comprehensive troubleshooting

### Maintainability Metrics
- ✅ Modular configuration files (< 100 lines each)
- ✅ Automated testing on multiple platforms
- ✅ Self-documenting code with templates
- ✅ Easy to add new tools/configurations
- ✅ Graceful handling of missing dependencies

## 🔄 Migration Strategy

### From Current State
1. **Preserve existing functionality** - all current features continue working
2. **Gradual migration** - move one component at a time to new structure
3. **Legacy support** - keep old files during transition
4. **Testing** - validate each component before removing old version
5. **Documentation** - update docs as we migrate

### Rollback Plan
- Keep current files in `legacy/` directory
- Create restore script if needed
- Document any breaking changes
- Provide migration assistance

## 🎉 Post-Implementation Benefits

### For Users
- ⚡ **Faster setup** - single command, profile-based installation
- 🎯 **Clearer purpose** - know exactly what each component does
- 🔧 **Easier customization** - modify small, focused files
- 📚 **Better guidance** - context-aware help and documentation
- 🛡️ **More secure** - proper secrets management

### For Maintainers
- 🧩 **Modular architecture** - easier to understand and modify
- 🤖 **Automated testing** - confidence in changes
- 📖 **Self-documenting** - templates explain themselves
- 🔄 **Easy updates** - modify one component without affecting others
- 🚀 **Scalable** - easy to add new features and tools

---

**Next Actions**: Start with Phase 1 implementation, beginning with directory restructure and basic modularization.