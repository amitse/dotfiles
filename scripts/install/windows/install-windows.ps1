# Enhanced PowerShell dotfiles installer using chezmoi
# Usage: irm https://raw.githubusercontent.com/amitse/dotfiles/main/install.ps1 | iex

param(
    [string]$NonInteractive = $null,
    [string]$GitName = "Test User",
    [string]$GitEmail = "test@example.com"
)

$ErrorActionPreference = "Stop"
$DOTFILES_REPO = "amitse/dotfiles"

Write-Host "🚀 Power User Dotfiles Installer" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Blue
Write-Host ""

# Function to prompt for git credentials
function Get-GitCredentials {
    Write-Host ""
    Write-Host "🔧 Git Configuration" -ForegroundColor Yellow
    Write-Host "We'll configure git with your information."
    Write-Host ""
    
    do {
        $gitName = Read-Host "Enter your full name for git commits"
    } while ([string]::IsNullOrWhiteSpace($gitName))
    
    do {
        $gitEmail = Read-Host "Enter your email address for git commits"
    } while ($gitEmail -notmatch "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$")
    
    Write-Host ""
    Write-Host "✅ Git configured for: $gitName <$gitEmail>" -ForegroundColor Green
    
    return @{
        Name = $gitName
        Email = $gitEmail
    }
}

# Function to install chezmoi
function Install-Chezmoi {
    if (Get-Command chezmoi -ErrorAction SilentlyContinue) {
        Write-Host "✅ chezmoi already installed" -ForegroundColor Blue
        return
    }
    
    Write-Host "📦 Installing chezmoi..." -ForegroundColor Blue
    
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Using winget to install chezmoi..." -ForegroundColor Blue
        winget install twpayne.chezmoi --silent --accept-source-agreements --accept-package-agreements
    } elseif (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "Using scoop to install chezmoi..." -ForegroundColor Blue
        scoop install chezmoi
    } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Using chocolatey to install chezmoi..." -ForegroundColor Blue
        choco install chezmoi -y
    } else {
        Write-Host "Installing chezmoi directly..." -ForegroundColor Blue
        $tempDir = [System.IO.Path]::GetTempPath()
        $installScript = Join-Path $tempDir "install-chezmoi.ps1"
        Invoke-WebRequest -Uri "https://get.chezmoi.io/ps1" -OutFile $installScript
        & $installScript
        Remove-Item $installScript -Force
    }
    
    Write-Host "✅ chezmoi installed" -ForegroundColor Green
}

# Function to create a temporary chezmoi config
function New-TempConfig {
    param(
        [string]$GitName,
        [string]$GitEmail
    )
    
    $tempDir = [System.IO.Path]::GetTempFileName() + "_dir"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    $configFile = Join-Path $tempDir "chezmoi.toml"
    
    $configContent = @"
[data]
    git_name_preselected = "$GitName"
    git_email_preselected = "$GitEmail"
"@
    
    Set-Content -Path $configFile -Value $configContent
    
    return @{
        ConfigFile = $configFile
        TempDir = $tempDir
    }
}

# Function to initialize dotfiles
function Initialize-Dotfiles {
    param(
        [string]$ConfigFile = $null
    )
    
    Write-Host "🔧 Initializing dotfiles..." -ForegroundColor Blue
    
    $chezmoiDir = Join-Path $env:USERPROFILE ".local\share\chezmoi"
    
    if (Test-Path $chezmoiDir) {
        Write-Host "⚠️  Dotfiles already initialized. Updating..." -ForegroundColor Yellow
        chezmoi update
    } else {
        Write-Host "📥 Cloning and applying dotfiles..." -ForegroundColor Blue
        
        if ($ConfigFile) {
            chezmoi init --config $ConfigFile --apply "https://github.com/$DOTFILES_REPO.git"
        } else {
            chezmoi init --apply "https://github.com/$DOTFILES_REPO.git"
        }
    }
}

# Function to show completion information
function Show-CompletionInfo {
    Write-Host ""
    Write-Host "🎉 Installation Complete!" -ForegroundColor Green
    Write-Host "=========================" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "📦 Power User Environment Installed" -ForegroundColor Cyan
    Write-Host "• git with smart aliases and delta diffs"
    Write-Host "• tmux with sensible defaults"
    Write-Host "• fzf (Ctrl+R for history, Ctrl+T for files)"
    Write-Host "• ripgrep (rg command for fast search)"
    Write-Host "• bat (enhanced cat with syntax highlighting)"
    Write-Host "• zoxide (z command for smart directory jumping)"
    Write-Host "• exa (modern ls replacement)"
    Write-Host "• lazygit (visual git interface)"
    Write-Host "• GitHub CLI (gh command)"
    Write-Host "• Advanced shell features and modern CLI tools"
    
    Write-Host ""
    Write-Host "📚 Useful Commands:" -ForegroundColor Blue
    Write-Host "  chezmoi status     - See what was configured" -ForegroundColor Yellow
    Write-Host "  chezmoi diff       - See pending changes" -ForegroundColor Yellow
    Write-Host "  chezmoi apply      - Apply changes" -ForegroundColor Yellow
    Write-Host "  chezmoi update     - Pull and apply updates" -ForegroundColor Yellow
    Write-Host "  chezmoi edit       - Edit configuration files" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🚀 Quick Start:" -ForegroundColor Blue
    Write-Host "• Open a new PowerShell/Terminal to see your new environment"
    Write-Host "• Try 'Ctrl+R' for fuzzy history search"
    Write-Host "• Use 'z <partial-path>' for smart directory jumping"
    Write-Host "• Use 'exa -la' for modern directory listing"
    Write-Host "• Use 'lazygit' for visual git interface"
    Write-Host ""
    Write-Host "✨ Your power user development environment is ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "💡 You may need to restart PowerShell/Terminal to use all installed tools." -ForegroundColor Cyan
}

# Cleanup function
function Remove-TempFiles {
    param([string]$TempDir)
    
    if ($TempDir -and (Test-Path $TempDir)) {
        Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Main installation flow
try {
    # Handle non-interactive mode
    if ($NonInteractive -eq "true") {
        Write-Host "Running in non-interactive mode..." -ForegroundColor Yellow
        $gitCredentials = @{
            Name = $GitName
            Email = $GitEmail
        }
    } else {
        # Interactive mode
        Write-Host "Installing power user development environment..." -ForegroundColor Cyan
        $gitCredentials = Get-GitCredentials
    }
    
    Write-Host ""
    Write-Host "� Starting installation..." -ForegroundColor Blue
    
    # Install chezmoi
    Install-Chezmoi
    
    # Create temporary config with preselected values
    $tempConfig = New-TempConfig -GitName $gitCredentials.Name -GitEmail $gitCredentials.Email
    
    try {
        # Initialize dotfiles
        Initialize-Dotfiles -ConfigFile $tempConfig.ConfigFile
        
        # Show completion information
        Show-CompletionInfo
    }
    finally {
        # Cleanup
        Remove-TempFiles -TempDir $tempConfig.TempDir
    }
}
catch {
    Write-Host "❌ Installation failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "• Make sure you have internet connectivity"
    Write-Host "• Try running PowerShell as Administrator"
    Write-Host "• Check that execution policy allows scripts: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
    Write-Host "• Visit https://github.com/$DOTFILES_REPO for manual installation instructions"
    exit 1
}