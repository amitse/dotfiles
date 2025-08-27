# Getting Started with Dotfiles

Welcome to your personal dotfiles repository! This guide will get you up and running quickly.

## 🚀 Quick Installation

**One command to rule them all:**

```bash
curl -fsSL https://raw.githubusercontent.com/amitse/dotfiles/main/scripts/install/unix/install-unix.sh | bash
```

That's it! The installer will:
1. Detect your operating system
2. Install chezmoi and required tools
3. Apply your power user dotfiles configuration

## 📋 What Gets Installed

### Complete Power User Environment:
- ✅ **Git** - Version control with smart aliases and delta diffs
- ✅ **tmux** - Terminal multiplexer with sensible defaults
- ✅ **fzf** - Fuzzy finder for files and commands
- ✅ **ripgrep (rg)** - Ultra-fast text search
- ✅ **bat** - Enhanced `cat` with syntax highlighting
- ✅ **zoxide** - Smart directory jumping
- ✅ **exa** - Modern `ls` replacement
- ✅ **entr** - File watcher for automation
- ✅ **delta** - Better git diffs
- ✅ **lazygit** - Visual git interface
- ✅ **GitHub CLI** - GitHub integration
- ✅ **Cross-platform clipboard integration**
- ✅ **Advanced shell features and modern CLI tools**

## 🎯 First Steps After Installation

### 1. Restart Your Shell
```bash
# Start a new shell session to load configurations
exec $SHELL -l
```

### 2. Try Essential Commands

**tmux (Terminal Multiplexer):**
```bash
tmux                    # Start tmux session
# Inside tmux:
# Ctrl+a |              # Split pane vertically  
# Ctrl+a -              # Split pane horizontally
# Ctrl+a r              # Reload tmux config
```

**Git Aliases:**
```bash
git st                  # Status (shorter)
git lg                  # Pretty log with graph
git co main             # Checkout main branch
git cam "message"       # Commit all with message
```

### 3. Explore Modern CLI Tools

**Fuzzy Finding:**
```bash
# Press Ctrl+R for fuzzy history search
# Press Ctrl+T for fuzzy file finder
fzf                     # Interactive file selector
```

**Enhanced File Operations:**
```bash
bat README.md           # Syntax-highlighted file viewing
rg "function"           # Ultra-fast text search
z documents             # Smart directory jumping (after using it)
```

**Better Directory Listing:**
```bash
ls                      # Now uses exa (if installed)
ll                      # Long format with git status
tree                    # Directory tree view
```

## ⚙️ Customization

### Edit Configuration Files
```bash
# Edit any managed file
chezmoi edit ~/.tmux.conf
chezmoi edit ~/.zshrc

# Preview changes before applying
chezmoi diff

# Apply changes
chezmoi apply
```

### Add New Files to Management
```bash
# Add existing file
chezmoi add ~/.gitconfig

# Add file as template (with variables)
chezmoi add --template ~/.config/app/config.yaml
```

### Check Status
```bash
chezmoi status          # See what's managed
chezmoi doctor          # Health check
```

## 🔧 Platform-Specific Features

### Linux
- Automatic clipboard tool detection (wl-copy → xclip → xsel)
- Package manager integration (apt, dnf, pacman)
- Native shell integration

### macOS
- Native clipboard integration (pbcopy/pbpaste)
- Homebrew package manager support
- GNU tools compatibility

### Windows
- PowerShell profile with modern CLI aliases
- Native clipboard integration (clip.exe)
- WSL compatibility

## 🆘 Common Issues

**"Command not found" after installation:**
```bash
# Restart your shell
exec $SHELL -l

# Or manually source configuration
source ~/.zshrc
```

**tmux clipboard not working (Linux):**
```bash
# Install clipboard tools
sudo apt install wl-clipboard  # Wayland
# OR
sudo apt install xclip         # X11
```

**Tools not found:**
```bash
# Check what's installed
chezmoi-help status

# Update tools
chezmoi update
```

## 📚 Next Steps

- **[Customization Guide](CUSTOMIZATION.md)** - Deep customization options
- **[Troubleshooting](TROUBLESHOOTING.md)** - Solve common problems  
- **[Advanced Usage](ADVANCED.md)** - Power user features

## 🎉 Tips for Daily Use

1. **Use aliases** - `git st` instead of `git status`
2. **Leverage fzf** - Ctrl+R for history, Ctrl+T for files
3. **Smart directory jumping** - Use `z` instead of `cd`
4. **Edit with chezmoi** - Always use `chezmoi edit` for managed files
5. **Regular updates** - Run `chezmoi update` weekly

---

**Need help?** Run `chezmoi-help` for interactive assistance or check the troubleshooting guide.