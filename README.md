# Dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io) - modular, profile-based development environment setup.

## 🚀 One-Command Installation

**Linux/macOS:**

```bash
curl -fsSL https://raw.githubusercontent.com/amitse/dotfiles/main/install.sh | bash
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/amitse/dotfiles/main/install.ps1 | iex
```

That's it! The installer will:

1. Install chezmoi
2. Let you choose a profile (minimal/developer/power-user)  
3. Configure everything automatically

## 🎯 Choose Your Profile

| Profile | Tools | Perfect For |
|---------|-------|-------------|
| **Minimal** | git, tmux | Servers, learning |
| **Developer** | + fzf, ripgrep, bat, zoxide, gh | Daily development |
| **Power User** | + exa, entr, delta, lazygit, advanced features | Maximum productivity |

**👉 Most users should choose Developer profile.**

## 📚 Documentation

- **[📖 Getting Started](docs/GETTING-STARTED.md)** - Complete setup guide
- **[🎯 Profile Guide](docs/PROFILES.md)** - Detailed profile comparison  
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

### All Profiles:

- ✅ **Git** with smart aliases and cross-platform settings
- ✅ **tmux** with sensible defaults and clipboard integration
- ✅ **Cross-platform support** (Windows/Linux/macOS)

### Developer Profile Adds:

- ✅ **fzf** - Fuzzy finder (Ctrl+R, Ctrl+T)
- ✅ **ripgrep** - Ultra-fast text search
- ✅ **bat** - Enhanced file viewer
- ✅ **zoxide** - Smart directory jumping
- ✅ **GitHub CLI** - Terminal repo management

### Power User Profile Adds:

- ✅ **exa** - Modern directory listing
- ✅ **delta** - Beautiful git diffs
- ✅ **lazygit** - Visual git interface
- ✅ **Advanced shell features**

## ⚡ Quick Examples

```bash
# After installation:
Ctrl+R                    # Fuzzy history search
Ctrl+T                    # Fuzzy file finder
bat README.md             # Syntax-highlighted viewing
rg "function"             # Ultra-fast search
z documents               # Smart directory jumping

# Git shortcuts:
git st                    # Status
git lg                    # Beautiful log
git cam "message"         # Commit all

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

> 🤖 **For AI Assistants**: See [docs/AI-ASSISTANT-GUIDE.md](docs/AI-ASSISTANT-GUIDE.md) for technical details and troubleshooting guides.