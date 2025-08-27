# Dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io) - now with enhanced maintainability and modular architecture!

> 🤖 **For AI Assistants**: See [README_LLM.md](README_LLM.md) for structured troubleshooting and integration guidance.

## ✨ What's New

- 🏗️ **Modular Architecture** - Organized, maintainable configuration pieces
- 🎯 **Profile System** - Choose minimal/developer/power-user setups
- 🤖 **Smart Installation** - Automatic tool detection and installation
- 📚 **Better Documentation** - Clear guides for every experience level
- 🔧 **Health Monitoring** - Built-in system to check configuration health

## 🚀 One-Command Installation

**Universal installer (detects your OS automatically):**

```bash
curl -fsSL https://raw.githubusercontent.com/amitse/dotfiles/main/install.sh | bash
```

That's it! The installer will:
1. Detect your platform (Windows/Linux/macOS)
2. Let you choose a profile (minimal/developer/power-user)  
3. Install tools based on your profile
4. Configure everything automatically

## 🎯 Choose Your Profile

| Profile | Tools | Perfect For | Install Time |
|---------|-------|-------------|--------------|
| **Minimal** | git, tmux | Servers, learning, simplicity | 2-3 minutes |
| **Developer** | + fzf, ripgrep, bat, zoxide, gh | Daily development work | 5-7 minutes |
| **Power User** | + exa, entr, delta, lazygit, advanced features | Maximum productivity | 8-10 minutes |

**👉 Most users should choose Developer profile for the best balance.**

## 📚 Quick Links

- **[📖 Getting Started](docs/GETTING-STARTED.md)** - Complete setup guide
- **[🎯 Profile Guide](docs/PROFILES.md)** - Detailed profile comparison  
- **[🔧 Customization](docs/CUSTOMIZATION.md)** - How to customize your setup
- **[🆘 Troubleshooting](docs/TROUBLESHOOTING.md)** - Fix common issues
- **[📋 Implementation Plan](PLAN.md)** - Technical roadmap and architecture

## 🔧 Daily Commands

```bash
# Check system health
chezmoi-help health

# Edit any configuration file
chezmoi edit ~/.tmux.conf

# Preview changes
chezmoi diff

# Apply changes  
chezmoi apply

# Update from remote
chezmoi update
```

## 💡 What You Get

### All Profiles Include:
- ✅ **Git configuration** with smart aliases and cross-platform settings
- ✅ **tmux setup** with sensible defaults and clipboard integration
- ✅ **Cross-platform support** for Windows, Linux, and macOS

### Developer Profile Adds:
- ✅ **fzf** - Fuzzy finder for files and command history (Ctrl+R, Ctrl+T)
- ✅ **ripgrep** - Ultra-fast text search (replaces grep)
- ✅ **bat** - Enhanced file viewer with syntax highlighting
- ✅ **zoxide** - Smart directory jumping (learns your habits)
- ✅ **GitHub CLI** - Manage repos, PRs, and issues from terminal

### Power User Profile Adds:
- ✅ **exa** - Modern directory listing with git integration
- ✅ **entr** - File watcher for automated workflows
- ✅ **delta** - Beautiful git diffs with syntax highlighting
- ✅ **Advanced shell features** - Enhanced prompt, comprehensive aliases
- ✅ **Git TUI options** - lazygit, gitui for visual git management

## 🌟 Key Features

### Smart & Adaptive
- **Automatic tool detection** - Configurations adapt to available tools
- **Graceful degradation** - Works even if some tools aren't installed
- **Platform-specific optimizations** - Native clipboard, package managers

### Modular Architecture
- **Clean separation** - Each tool has its own configuration module
- **Easy customization** - Modify specific features without affecting others
- **Template-driven** - Smart configurations based on your environment

### Comprehensive Documentation
- **Progressive complexity** - Start simple, add features as you learn
- **Context-aware help** - Guidance specific to your setup
- **Troubleshooting guides** - Solutions for common issues

## ⚡ Quick Examples

**After installation, try these:**

```bash
# Modern CLI tools (Developer/Power User profiles)
Ctrl+R                    # Fuzzy history search
Ctrl+T                    # Fuzzy file finder
bat README.md             # Syntax-highlighted file viewing
rg "function"             # Ultra-fast text search
z documents               # Smart directory jumping

# Git enhancements (All profiles)
git st                    # Status (alias)
git lg                    # Beautiful log with graph
git cam "message"         # Commit all with message

# tmux (All profiles)
tmux                      # Start session
# Inside tmux:
Ctrl+a |                  # Split vertically
Ctrl+a -                  # Split horizontally
Ctrl+a r                  # Reload config
```

## � Health Monitoring

Built-in health check system:

```bash
# Run comprehensive health check
chezmoi-help health

# Quick status check
chezmoi status

# System diagnostics
chezmoi doctor
```

## 🛠 Advanced Features

- **Secrets management** - Support for 1Password, Bitwarden, environment variables
- **Profile switching** - Change profiles anytime without losing data
- **Auto-updates** - Keep tools and configurations current
- **Backup system** - Never lose your customizations

---

## Legacy Installation Methods

<details>
<summary>Click to see platform-specific installers (not recommended)</summary>

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

### Core Configuration
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

### Modern CLI Tools & Configs
- **Shell aliases** (`.config/shell/aliases.sh`) - Smart aliases for modern CLI tools
- **PowerShell profile** - Windows-specific enhancements and tool integration
- **bat config** (`.config/bat/config`) - Syntax highlighting and theming
- **ripgrep config** (`.config/ripgrep/config`) - Search patterns and file type associations

### Git & GitHub Configuration
- **Git config** (`.gitconfig`) - Aliases, settings, and tool integration
- **GitHub CLI** - Automatic installation and integration

### Zsh Configuration (Linux/macOS)
- **Zsh shell** - Modern shell with advanced features
- **Zsh config** (`.zshrc`) - Completion, history, and tool integration
- **Zsh aliases** (`.zsh_aliases`) - Shell-specific aliases and functions
- **Smart append logic** - Safely integrates with existing `.zshrc` files

### Automatically Installed CLI Tools
- **[bat](https://github.com/sharkdp/bat)** - Enhanced `cat` with syntax highlighting
- **[ripgrep](https://github.com/BurntSushi/ripgrep)** - Ultra-fast text search (`rg`)
- **[fzf](https://github.com/junegunn/fzf)** - Fuzzy finder for files and history
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** - Smart `cd` command with frecency
- **[exa](https://github.com/ogham/exa)** - Modern `ls` replacement with colors and icons
- **[entr](https://github.com/eradman/entr)** - File watcher for running commands on changes
- **[Midnight Commander](https://midnight-commander.org/)** - Terminal file manager

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

- **[LLM Assistant Guide](README_LLM.md)** - Structured guide for AI assistants and troubleshooting
- [chezmoi documentation](https://chezmoi.io/)
- [chezmoi quick start](https://chezmoi.io/quick-start/)
- [Template functions](https://chezmoi.io/user-guide/templating/)
- [Managing secrets](https://chezmoi.io/user-guide/password-managers/)