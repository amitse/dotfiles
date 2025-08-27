# Dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io) - a complete power user development environment setup.

## 🚀 One-Command Installation

**Linux/macOS:**

```bash
curl -fsSL https://raw.githubusercontent.com/amitse/dotfiles/main/scripts/install/unix/install-unix.sh | bash
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/amitse/dotfiles/main/scripts/install/windows/install-windows.ps1 | iex
```

That's it! The installer will:

1. Install chezmoi
2. Configure everything automatically with full power user features
3. Set up all modern CLI tools and advanced configurations

## 📚 Documentation

- **[📖 Getting Started](docs/GETTING-STARTED.md)** - Complete setup guide
- **[🔧 Customization](docs/CUSTOMIZATION.md)** - How to customize your setup
- **[🆘 Troubleshooting](docs/TROUBLESHOOTING.md)** - Fix common issues
- **[📋 Implementation Plan](PLAN.md)** - Technical roadmap

## 🔧 Daily Commands

```bash
# Check system health
# Windows PowerShell:
.\scripts\health-check.ps1
# Linux/macOS/Git Bash:
bash scripts/health-check.sh

# Edit configuration
chezmoi edit ~/.tmux.conf

# Preview changes
chezmoi diff

# Apply changes  
chezmoi apply

# Update from remote
chezmoi update

# Check managed files status
chezmoi status
```

## 💡 What You Get

### Complete Development Environment:

- ✅ **Git** with smart aliases and cross-platform settings
- ✅ **tmux** with sensible defaults and clipboard integration
- ✅ **fzf** - Fuzzy finder (Ctrl+R, Ctrl+T)
- ✅ **ripgrep** - Ultra-fast text search
- ✅ **bat** - Enhanced file viewer
- ✅ **zoxide** - Smart directory jumping
- ✅ **GitHub CLI** - Terminal repo management
- ✅ **exa** - Modern directory listing
- ✅ **delta** - Beautiful git diffs
- ✅ **lazygit** - Visual git interface
- ✅ **Advanced shell features** with modern CLI tools
- ✅ **Cross-platform support** (Windows/Linux/macOS)

## ⚡ Quick Examples

```bash
# After installation:
Ctrl+R                    # Fuzzy history search
Ctrl+T                    # Fuzzy file finder
bat README.md             # Syntax-highlighted viewing
rg "function"             # Ultra-fast search
z documents               # Smart directory jumping
exa -la                   # Modern ls with icons

# Git shortcuts:
git st                    # Status
git lg                    # Beautiful log with delta
git cam "message"         # Commit all
lazygit                   # Visual git interface

# tmux:
Ctrl+a |                  # Split vertically
Ctrl+a -                  # Split horizontally
```

## 🛠 Manual Installation

<details>
<summary>Advanced users: Manual chezmoi setup</summary>

```bash
# Install chezmoi first
sh -c "$(curl -fsLS get.chezmoi.io)"  # Linux/macOS
# or: winget install twpayne.chezmoi    # Windows

# Initialize dotfiles
chezmoi init --apply https://github.com/amitse/dotfiles.git
```

</details>

------

## 📋 Changelog

### August 2025 - Folder Restructure

The repository was reorganized for better maintainability:

- **`chezmoi/`** - All chezmoi-specific templates and scripts (moved from `.chezmoi/` and `.chezmoiscripts/`)
- **`configs/templates/`** - Generic configuration templates (moved from `configs/dot_*.tmpl`)  
- **`configs/powershell/`** - PowerShell configurations (moved from `Documents/PowerShell/`)
- **`scripts/install/{unix,windows}/`** - Platform-specific install scripts

Git history is preserved for all moved files. Old clone instructions remain valid.

------

> 🤖 **For AI Assistants**: See [docs/AI-ASSISTANT-GUIDE.md](docs/AI-ASSISTANT-GUIDE.md) for technical details and troubleshooting guides.