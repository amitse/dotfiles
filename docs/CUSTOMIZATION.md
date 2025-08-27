# Customization Guide

This guide explains how to customize your dotfiles setup to match your preferences and workflow.

## 🎯 Overview

The dotfiles system is built with modularity in mind. You can customize:
- Individual tool configurations
- Platform-specific settings
- Personal aliases and functions

## 🔧 Quick Customization

### Edit Individual Files
```bash
# Edit your shell configuration
chezmoi edit ~/.zshrc

# Edit git configuration
chezmoi edit ~/.gitconfig

# Edit tmux configuration
chezmoi edit ~/.tmux.conf
```

### Preview Changes
```bash
# See what will change
chezmoi diff

# Apply changes
chezmoi apply
```

## 📂 Understanding the Structure

The modular structure in `templates/partials/` allows you to customize specific aspects:

```
templates/partials/
├── shell/          # Shell configurations
├── tools/          # Modern CLI tool configs
├── platforms/      # Platform-specific configs
└── profiles/       # Configuration profiles
```

## 🎨 Common Customizations

### Adding Personal Aliases
Edit the aliases configuration:
```bash
chezmoi edit ~/.config/shell/aliases.sh
```

### Changing Your Profile
Re-run the configuration:
```bash
chezmoi init --apply
```

### Platform-Specific Settings
Customize platform-specific configurations in:
- `templates/partials/platforms/windows.sh.tmpl` (Windows/WSL)
- `templates/partials/platforms/linux.sh.tmpl` (Linux)
- `templates/partials/platforms/macos.sh.tmpl` (macOS)

## 📚 Advanced Customization

For detailed customization examples and advanced configuration patterns, see the template files in the `templates/partials/` directory.

Each template file includes comments explaining available options and customization points.

## 🆘 Need Help?

- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Review template files for configuration options
- Use `chezmoi help` for command reference
