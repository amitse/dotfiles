# Scripts

This directory contains utility scripts organized by purpose and platform.

## Structure

- `install/` - Installation scripts by platform
  - `windows/` - Windows-specific install scripts
  - `unix/` - Unix/Linux/macOS install scripts
- `health/` - Health check and diagnostic scripts
- `tools/` - Validation and utility scripts

## Migration Note

Install scripts were reorganized by platform:
- `scripts/install/install-windows.ps1` → `scripts/install/windows/`
- `scripts/install/install-unix.sh` → `scripts/install/unix/`