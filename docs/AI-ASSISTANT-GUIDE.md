# README_LLM.md - AI Assistant Guide

This document provides structured information for Large Language Models (LLMs) and AI assistants to help users with dotfiles management using chezmoi.

## Repository Overview

**Repository**: amitse/dotfiles  
**Management Tool**: chezmoi  
**Primary Config**: tmux cross-platform configuration  
**CLI Tools**: bat, ripgrep, fzf, zoxide, exa, entr, Midnight Commander  
**Supported OS**: Windows, Linux, macOS  

## Quick Actions for Users

### Installation Commands

**Universal (any OS):**
```bash
curl -fsSL https://raw.githubusercontent.com/amitse/dotfiles/main/bootstrap.sh | bash
```

**Windows PowerShell:**
```powershell
irm https://raw.githubusercontent.com/amitse/dotfiles/main/bootstrap.ps1 | iex
```

**Linux only:**
```bash
curl -fsSL https://raw.githubusercontent.com/amitse/dotfiles/main/install-linux.sh | bash
```

**Dry run (preview only):**
```bash
curl -fsSL https://raw.githubusercontent.com/amitse/dotfiles/main/bootstrap.sh | bash -s -- --dry-run
```

### Post-Installation Commands

**Daily workflow:**
```bash
chezmoi edit ~/.tmux.conf    # Edit managed files
chezmoi diff                 # Preview changes
chezmoi apply               # Apply changes
chezmoi cd && git push && exit  # Commit and push
```

**Add new files:**
```bash
chezmoi add ~/.gitconfig     # Add existing file
chezmoi add --template ~/.config/app/config  # Add as template
```

## File Structure

```
├── bootstrap.sh                                    # Cross-platform installer
├── bootstrap.ps1                                   # Windows PowerShell installer  
├── install-linux.sh                                # Linux-only installer
├── dot_tmux.conf.tmpl                              # tmux config template (main config)
├── dot_config/shell/aliases.sh.tmpl                # Shell aliases for CLI tools
├── dot_config/bat/config.tmpl                      # bat (cat replacement) config
├── dot_config/ripgrep/config                       # ripgrep search patterns
├── configs/powershell/Microsoft.PowerShell_profile.ps1.tmpl  # PowerShell profile
├── .chezmoiignore                                  # Files to ignore
├── .gitattributes                                  # Git line ending config
├── .gitignore                                      # Git ignore patterns
└── README.md                                       # User documentation
```

## Current Configurations

### tmux Configuration Features
- **Prefix**: Ctrl-a (instead of Ctrl-b)
- **Mouse support**: Enabled
- **Copy mode**: Vi-style
- **Clipboard integration**: Platform-specific (clip.exe/wl-copy/xclip/pbcopy)
- **Colors**: 256-color + RGB support
- **Status bar**: Customized with hostname and time
- **Key bindings**: 
  - `|` and `-` for pane splitting
  - `Alt+arrows` for pane navigation
  - `r` to reload config

### Cross-Platform Templating

The tmux config uses chezmoi templates:

```tmux
{{- if eq .chezmoi.os "windows" }}
# Windows-specific settings
{{- else if eq .chezmoi.os "darwin" }}
# macOS-specific settings  
{{- else }}
# Linux-specific settings
{{- end }}
```

## Installed CLI Tools

The bootstrap scripts automatically install these modern CLI tools:

### Core Tools
- **bat**: Enhanced `cat` with syntax highlighting and paging
  - Usage: `bat file.txt`, replaces `cat`
  - Config: `~/.config/bat/config`
  
- **ripgrep (rg)**: Ultra-fast text search
  - Usage: `rg "pattern" [path]`, replaces `grep`
  - Config: `~/.config/ripgrep/config`
  
- **fzf**: Fuzzy finder for files and command history
  - Usage: `fzf`, `Ctrl+R` (history), `Ctrl+T` (files)
  - Integrates with other tools for enhanced search

- **zoxide**: Smart directory jumper with frecency
  - Usage: `z [partial_path]`, replaces `cd`
  - Learns your most-used directories

- **exa**: Modern `ls` replacement with colors and git integration
  - Usage: `exa`, `exa -l`, `exa --tree`
  - Aliases: `ls`, `ll`, `la`, `tree`

### Utility Tools
- **entr**: File watcher for running commands on changes
  - Usage: `ls *.py | entr python test.py`
  
- **Midnight Commander (mc)**: Terminal file manager
  - Usage: `mc`

### Installation Status by OS
- **Linux**: Full support via package managers (apt/pacman/dnf) + fallbacks
- **Windows**: Via winget/scoop/chocolatey (some tools may need manual install)
- **macOS**: Via Homebrew (full support)

## Troubleshooting Guide for LLMs

### Common Issues and Solutions

**Issue: "chezmoi not found"**
```bash
# Install chezmoi first
sh -c "$(curl -fsLS get.chezmoi.io)"
# Or use package manager
sudo apt install chezmoi  # Ubuntu
winget install twpayne.chezmoi  # Windows
```

**Issue: "Permission denied" on Linux**
```bash
# Make scripts executable
chmod +x bootstrap.sh install-linux.sh
```

**Issue: "Clipboard not working in tmux"**
```bash
# Install clipboard tools (Linux)
sudo apt install wl-clipboard  # Wayland
sudo apt install xclip         # X11
sudo apt install xsel          # Alternative

# The tmux config will auto-detect available tools
```

**Issue: "Config not updating"**
```bash
# Force update
chezmoi apply --force ~/.tmux.conf

# Check what changed
chezmoi diff

# Verify source
chezmoi doctor
```

**Issue: "Line ending problems on Windows"**
```bash
# Already handled by .gitattributes
# If issues persist:
git config core.autocrlf false
git config core.eol lf
```

### Verification Commands

**Check installation:**
```bash
chezmoi --version
chezmoi doctor              # Comprehensive health check
chezmoi source-path         # Show source directory
```

**Check tmux config:**
```bash
tmux show-options -g        # Show global options
tmux list-keys             # Show key bindings
tmux info                  # Show session info
```

## Customization Patterns

### Adding OS-Specific Sections

```tmux
{{- if eq .chezmoi.os "windows" }}
# Windows-only config
set -g status-right '#[fg=cyan]%Y-%m-%d %H:%M #[fg=green]#H'
{{- else if eq .chezmoi.os "darwin" }}
# macOS-only config  
set -g status-right '#[fg=cyan]%Y-%m-%d %H:%M #[fg=green]#(hostname -s)'
{{- else }}
# Linux-only config
set -g status-right '#[fg=cyan]%Y-%m-%d %H:%M #[fg=green]#(hostname -s)'
{{- end }}
```

### Adding Machine-Specific Config

```tmux
{{- if eq .chezmoi.hostname "work-laptop" }}
# Work-specific settings
{{- else if eq .chezmoi.hostname "home-desktop" }}
# Personal machine settings
{{- end }}
```

### Adding New Config Files

**PowerShell profile (Windows):**
```bash
chezmoi add $PROFILE
# Creates: Documents_PowerShell_Microsoft.PowerShell_profile.ps1.tmpl
```

**Git config:**
```bash
chezmoi add ~/.gitconfig
# Creates: dot_gitconfig
```

**With templating:**
```bash
chezmoi add --template ~/.config/app/config.yaml
# Creates: dot_config/app/config.yaml.tmpl
```

## File Naming Conventions

| Prefix | Result | Purpose |
|--------|--------|---------|
| `dot_` | `.filename` | Hidden files/dotfiles |
| `private_` | `filename` (600 perms) | Private files |
| `executable_` | `filename` (755 perms) | Executable files |
| `symlink_` | `filename` → target | Symbolic links |
| `.tmpl` | Processed template | Template files |

**Examples:**
- `dot_tmux.conf.tmpl` → `~/.tmux.conf` (templated)
- `private_dot_ssh/config` → `~/.ssh/config` (private)
- `executable_dot_local/bin/script` → `~/.local/bin/script` (executable)

## Dependency Information

### Required Tools
- **git**: Version control
- **chezmoi**: Dotfiles manager

### Optional Tools (for full functionality)
- **tmux**: Terminal multiplexer
- **Clipboard tools (Linux)**: wl-clipboard, xclip, or xsel
- **Package managers**: winget/scoop/choco (Windows), apt/pacman/dnf (Linux), brew (macOS)

## Advanced Operations

### Branching for Different Environments

```bash
# Create work-specific branch
chezmoi cd
git checkout -b work
# Edit configs for work environment
git commit -m "Work-specific configs"
git push -u origin work

# Switch environments
chezmoi init --branch work https://github.com/amitse/dotfiles.git
```

### Managing Secrets

```bash
# Use environment variables in templates
echo 'export GITHUB_TOKEN="secret"' >> ~/.bashrc
# In template: {{ .Env.GITHUB_TOKEN }}

# Use external secret managers
chezmoi secret keyring set github_token  # macOS Keychain
# In template: {{ keyring "github_token" }}
```

### Updating from Remote

```bash
chezmoi update              # Pull and apply in one command
# OR
chezmoi cd && git pull && exit && chezmoi apply
```

## Error Recovery

### Reset Everything

```bash
# Remove chezmoi completely
chezmoi purge --force

# Reinstall
curl -fsSL https://raw.githubusercontent.com/amitse/dotfiles/main/bootstrap.sh | bash
```

### Backup Before Changes

```bash
# Backup current configs
cp ~/.tmux.conf ~/.tmux.conf.backup

# Apply new version
chezmoi apply

# Restore if needed
cp ~/.tmux.conf.backup ~/.tmux.conf
```

## LLM Assistant Guidelines

When helping users with this dotfiles repository:

1. **Always suggest the appropriate installer** based on their OS
2. **Use the verification commands** to diagnose issues
3. **Reference the troubleshooting section** for common problems
4. **Explain the template system** when they want to customize configs
5. **Show them the daily workflow** commands for ongoing use
6. **Suggest dry-run mode** for new users to preview changes
7. **Recommend backup strategies** before major changes

### Example User Scenarios

**"I want to install your dotfiles"**
→ Provide the appropriate one-liner for their OS

**"My tmux clipboard isn't working"**
→ Check OS, suggest appropriate clipboard tool installation

**"I want to add my git config"**
→ Show `chezmoi add ~/.gitconfig` and explain the workflow

**"How do I customize the tmux config?"**
→ Explain `chezmoi edit ~/.tmux.conf` and template system

**"Something broke, how do I reset?"**
→ Guide through verification commands and recovery options