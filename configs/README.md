# Configuration Templates

This directory contains configuration templates for various tools and platforms.

## Structure

- `templates/` - Generic configuration templates
  - `dot_gitconfig.tmpl` - Git configuration template
  - `dot_tmux.conf.tmpl` - Tmux configuration template
- `powershell/` - PowerShell-specific configurations (Windows)
- `shell/` - Shell aliases and configurations
- `bat/` - Bat (cat replacement) configuration
- `ripgrep/` - Ripgrep search configuration

## Migration Note

Configuration templates were reorganized:
- `configs/dot_*.tmpl` → `configs/templates/`
- `Documents/PowerShell/` → `configs/powershell/`