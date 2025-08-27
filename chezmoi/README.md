# Chezmoi Templates and Scripts

This directory contains all chezmoi-specific templates and scripts.

## Structure

- `templates/` - Chezmoi template files (formerly `.chezmoi/`)
  - `chezmoi.toml.tmpl` - Main chezmoi configuration template
  - `shared/` - Shared template components
- `scripts/` - Chezmoi execution scripts (formerly `.chezmoiscripts/`)

## Migration Note

These files were moved from their original locations:
- `.chezmoi/` → `chezmoi/templates/`
- `.chezmoiscripts/` → `chezmoi/scripts/`

This change improves repository organization by grouping all chezmoi-related files together while maintaining git history.