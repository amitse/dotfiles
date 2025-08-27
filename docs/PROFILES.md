# Configuration Profiles Guide

This dotfiles repository supports three different profiles to match your needs and expertise level.

## 🎯 Profile Overview

| Profile | Tools | Use Case | Setup Time |
|---------|-------|----------|------------|
| **Minimal** | Git + tmux | Basic development, servers | 2-3 minutes |
| **Developer** | + Modern CLI tools | Daily development work | 5-7 minutes |
| **Power User** | + Advanced features | Maximum productivity | 8-10 minutes |

## 🏁 Minimal Profile

**Perfect for:**
- Servers and remote machines
- Learning environments  
- Minimal overhead setups
- Users new to dotfiles

**What you get:**
- ✅ Git configuration with essential aliases
- ✅ tmux with sensible defaults
- ✅ Cross-platform clipboard integration
- ✅ Basic shell aliases and functions

**Tools installed:**
```bash
git tmux
```

**Configuration highlights:**
- Git aliases: `st`, `co`, `lg`, `cam`
- tmux prefix: `Ctrl+a`
- Smart clipboard detection per platform
- Essential shell functions

**Try after installation:**
```bash
tmux                    # Start terminal multiplexer
git st                  # Quick status
git lg                  # Pretty log
```

---

## 💻 Developer Profile

**Perfect for:**
- Software developers
- Daily coding work
- Modern development workflows
- Users who want enhanced productivity

**What you get:**
- ✅ Everything from Minimal profile
- ✅ Modern CLI tool replacements
- ✅ Fuzzy finding capabilities
- ✅ Enhanced search and navigation
- ✅ GitHub CLI integration

**Tools installed:**
```bash
git tmux fzf ripgrep bat zoxide gh exa
```

**Enhanced features:**
- **fzf**: Fuzzy file finder and command history
- **ripgrep**: Ultra-fast text search (replaces grep)
- **bat**: Syntax-highlighted file viewer (replaces cat)
- **zoxide**: Smart directory jumping (replaces cd)
- **GitHub CLI**: Repository management from terminal
- **exa**: Modern directory listing (replaces ls)

**New capabilities:**
```bash
# Fuzzy finding
Ctrl+R                  # Fuzzy history search
Ctrl+T                  # Fuzzy file finder
fe pattern              # Fuzzy file editor

# Enhanced tools
bat file.py             # Syntax-highlighted viewing
rg "function"           # Ultra-fast search
z documents             # Smart directory jumping
gh pr list              # GitHub pull requests

# Better directory listing
ls                      # Now colorful with git status
ll                      # Detailed view with metadata
tree                    # Directory tree view
```

**Workflow improvements:**
- **Search**: `rg` is 10x faster than `grep`
- **Navigation**: `z` learns your most-used directories
- **File viewing**: `bat` shows syntax highlighting and line numbers
- **History**: Fuzzy search through thousands of commands instantly

---

## 🚀 Power User Profile

**Perfect for:**
- Advanced users who want everything
- Users comfortable with complex tooling
- Those who want maximum productivity
- Power users and system administrators

**What you get:**
- ✅ Everything from Developer profile
- ✅ Advanced automation tools
- ✅ Enhanced git workflow
- ✅ Powerline-style prompt
- ✅ Additional productivity tools

**Tools installed:**
```bash
git tmux fzf ripgrep bat zoxide gh exa entr delta fd lazygit gitui
```

**Advanced features:**
- **entr**: File watcher for automation
- **delta**: Beautiful git diffs with syntax highlighting
- **fd**: Modern find replacement
- **lazygit**: Terminal UI for git operations
- **gitui**: Another git TUI option
- **Advanced shell prompt** with git status
- **Comprehensive aliases** for all tools

**Power user capabilities:**
```bash
# Advanced git workflow
glog                    # Beautiful git log with graph
gclean                  # Clean up merged branches
delta                   # Better git diffs (auto-configured)

# File watching and automation
ls *.py | entr python test.py    # Re-run tests on file changes

# Advanced search and navigation
fd "pattern"            # Fast file finding
fzf_rg                  # Interactive search with preview
fif "text"              # Search in files with preview

# Enhanced directory operations
dust                    # Better disk usage (if available)
bottom                  # Better system monitor (if available)

# Git TUI options
lazygit                 # Full-featured git interface
gitui                   # Alternative git interface
```

**Productivity features:**
- **Smart prompt**: Shows git branch, status, and context
- **Advanced aliases**: Shortcuts for complex operations
- **Tool integration**: All tools work together seamlessly
- **Auto-completion**: Enhanced tab completion for all tools

---

## 🔄 Switching Profiles

You can change profiles at any time:

### Method 1: Reinitialize
```bash
# Remove current setup
chezmoi purge

# Reinitialize with new profile
curl -fsSL https://raw.githubusercontent.com/amitse/dotfiles/main/install.sh | bash
```

### Method 2: Manual Configuration
```bash
# Edit chezmoi configuration
chezmoi edit ~/.config/chezmoi/chezmoi.toml

# Change profile line:
profile = "power-user"  # or "developer" or "minimal"

# Reapply configuration
chezmoi apply
```

## 📊 Profile Comparison

### Resource Usage
| Profile | Disk Space | RAM Usage | Install Time |
|---------|------------|-----------|--------------|
| Minimal | ~50MB | Minimal | 2-3 min |
| Developer | ~200MB | Low | 5-7 min |
| Power User | ~500MB | Moderate | 8-10 min |

### Learning Curve
| Profile | Complexity | New Commands | Configuration |
|---------|------------|--------------|---------------|
| Minimal | Low | 5-10 | Basic |
| Developer | Medium | 20-30 | Moderate |
| Power User | High | 50+ | Advanced |

### Feature Matrix
| Feature | Minimal | Developer | Power User |
|---------|---------|-----------|------------|
| Git aliases | ✅ | ✅ | ✅ |
| tmux config | ✅ | ✅ | ✅ |
| Modern CLI tools | ❌ | ✅ | ✅ |
| Fuzzy finding | ❌ | ✅ | ✅ |
| GitHub integration | ❌ | ✅ | ✅ |
| File watching | ❌ | ❌ | ✅ |
| Git TUI | ❌ | ❌ | ✅ |
| Advanced prompt | ❌ | ❌ | ✅ |
| Auto-updates | ❌ | ❌ | ✅ |

## 🎯 Choosing the Right Profile

**Choose Minimal if:**
- You're new to dotfiles
- Working on servers/remote machines
- Want minimal system impact
- Prefer simplicity over features

**Choose Developer if:**
- You code regularly
- Want modern tool benefits
- Comfortable with moderate complexity
- Value productivity improvements

**Choose Power User if:**
- You want maximum features
- Comfortable with complex tooling
- Spend most time in terminal
- Want cutting-edge productivity tools

## 📈 Upgrading Profiles

Start with **Minimal** and upgrade when you're comfortable:

**Minimal → Developer**: When you want better search and navigation
**Developer → Power User**: When you want advanced automation and git features

Each profile builds on the previous one, so upgrades are seamless!

---

**Need help choosing?** Start with **Developer** profile - it provides the best balance of features and simplicity for most users.