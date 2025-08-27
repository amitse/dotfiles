# Troubleshooting Guide

Common issues and solutions for your dotfiles setup.

## 🚨 Common Issues

### Installation Issues

**Problem**: Installation script fails  
**Solution**: 
1. Ensure you have internet connectivity
2. Try running the installer again
3. Check that chezmoi is properly installed: `chezmoi --version`

**Problem**: PowerShell script execution disabled  
**Solution**:
```powershell
# Allow script execution for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run the health check
.\scripts\health-check.ps1
```

**Problem**: Permission denied errors  
**Solution**:
```bash
# Linux/macOS
chmod +x ~/.local/bin/chezmoi

# Windows - Run PowerShell as Administrator if needed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Configuration Issues

**Problem**: Shell changes not taking effect  
**Solution**:
```bash
# Restart your shell or source the config
source ~/.zshrc
# or
exec $SHELL
```

**Problem**: Tool not found after installation  
**Solution**:
1. Restart your terminal
2. Check if tool is in PATH: `which <toolname>`
3. Re-run: `chezmoi apply`

### Platform-Specific Issues

#### Windows/WSL
**Problem**: Line ending issues  
**Solution**:
```bash
git config --global core.autocrlf true
chezmoi apply
```

**Problem**: Permission issues in WSL  
**Solution**:
```bash
sudo chown -R $USER:$USER ~/
```

#### macOS
**Problem**: Command not found for brew-installed tools  
**Solution**:
```bash
# Add Homebrew to PATH
eval "$(/opt/homebrew/bin/brew shellenv)"
source ~/.zshrc
```

#### Linux
**Problem**: Missing development tools  
**Solution**:
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install build-essential curl git

# Fedora
sudo dnf groupinstall "Development Tools"
```

## 🔍 Diagnostic Commands

### Health Check
```bash
# Windows PowerShell
.\scripts\health-check.ps1

# Linux/macOS/Git Bash
bash scripts/health-check.sh
```

### Check Configuration Status
```bash
# See what files are managed
chezmoi managed

# Check for differences
chezmoi diff

# Verify all files
chezmoi verify
```

### Debug Template Issues
```bash
# Test template rendering
chezmoi execute-template < template-file.tmpl

# Check data values
chezmoi data
```

## 🛠 Reset and Recovery

### Reset Single File
```bash
# Reset a file to the source version
chezmoi apply --force ~/.zshrc
```

### Complete Reset
```bash
# Remove and re-initialize (CAREFUL!)
rm -rf ~/.local/share/chezmoi
chezmoi init --apply https://github.com/amitse/dotfiles.git
```

### Backup Before Reset
```bash
# Backup current configs
cp ~/.zshrc ~/.zshrc.backup
cp ~/.gitconfig ~/.gitconfig.backup
```

## 📊 Getting Help

### Check System Information
```bash
# System info
uname -a

# Shell info
echo $SHELL
echo $0

# chezmoi info
chezmoi doctor
```

### Common Fix Commands
```bash
# Update everything
chezmoi update

# Re-apply all configs
chezmoi apply

# See what changed
chezmoi status
```

## 🆘 Still Stuck?

1. Check the health check output:
   - Windows PowerShell: `.\scripts\health-check.ps1`
   - Linux/macOS/Git Bash: `bash scripts/health-check.sh`
2. Review your platform-specific configuration in `templates/partials/platforms/`
3. Ensure all required tools are installed for your chosen profile
4. Try switching to a minimal profile to isolate issues

## 📞 Reporting Issues

When reporting issues, please include:
- Operating system and version
- Shell type and version
- chezmoi version: `chezmoi --version`
- Output of: `chezmoi doctor`
- Error messages (full output)
