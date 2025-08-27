# Simple PowerShell dotfiles installer# Enhanced PowerShell dotfiles installer using chezmoi

# Usage: irm https://raw.githubusercontent.com/amitse/dotfiles/main/scripts/install/windows/install-windows.ps1 | iex# Usage: irm https://raw.githubusercontent.com/amitse/dotfiles/main/install.ps1 | iex



$ErrorActionPreference = "Stop"param(

    [string]$NonInteractive = $null,

Write-Host "🚀 Power User Dotfiles Installer" -ForegroundColor Green    [string]$GitName = "Test User",

Write-Host "=================================" -ForegroundColor Blue    [string]$GitEmail = "test@example.com"

)

# List of tools to install

$tools = @($ErrorActionPreference = "Stop"

    "twpayne.chezmoi"$DOTFILES_REPO = "amitse/dotfiles"

    "junegunn.fzf"

    "BurntSushi.ripgrep.MSVC"Write-Host "🚀 Power User Dotfiles Installer" -ForegroundColor Green

    "sharkdp.bat"Write-Host "=================================" -ForegroundColor Blue

    "ajeetdsouza.zoxide"Write-Host ""

    "eza-community.eza"

    "eradman.entr"# Function to prompt for git credentials

    "GitHub.cli"function Get-GitCredentials {

    "dandavison.delta"    Write-Host ""

    "sharkdp.fd"    Write-Host "🔧 Git Configuration" -ForegroundColor Yellow

    "jesseduffield.lazygit"    Write-Host "We'll configure git with your information."

    "ClementTsang.bottom"    Write-Host ""

    "bootandy.dust"    

)    do {

        $gitName = Read-Host "Enter your full name for git commits"

Write-Host "📦 Installing tools with winget..." -ForegroundColor Yellow    } while ([string]::IsNullOrWhiteSpace($gitName))

try {    

    # Install all tools in one command    do {

    winget install --id $($tools -join ' --id ') --silent --accept-package-agreements --accept-source-agreements        $gitEmail = Read-Host "Enter your email address for git commits"

    Write-Host "✅ Tools installed successfully!" -ForegroundColor Green    } while ($gitEmail -notmatch "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$")

} catch {    

    Write-Host "⚠️  Some tools may have failed to install, continuing..." -ForegroundColor Yellow    Write-Host ""

}    Write-Host "✅ Git configured for: $gitName <$gitEmail>" -ForegroundColor Green

    

Write-Host "🔧 Setting up dotfiles with chezmoi..." -ForegroundColor Yellow    return @{

try {        Name = $gitName

    # Initialize chezmoi with the dotfiles repo        Email = $gitEmail

    chezmoi init --apply https://github.com/amitse/dotfiles.git    }

    Write-Host "✅ Dotfiles setup complete!" -ForegroundColor Green}

} catch {

    Write-Host "❌ Chezmoi setup failed. Please run manually:" -ForegroundColor Red# Function to install chezmoi

    Write-Host "   chezmoi init --apply https://github.com/amitse/dotfiles.git"function Install-Chezmoi {

}    if (Get-Command chezmoi -ErrorAction SilentlyContinue) {

        Write-Host "✅ chezmoi already installed" -ForegroundColor Blue

Write-Host ""        return

Write-Host "🎉 Installation complete! Restart your terminal to use new tools." -ForegroundColor Green    }
    
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