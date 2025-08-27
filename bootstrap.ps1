# Bootstrap script for Windows dotfiles setup
# Run this script to automatically install chezmoi and apply dotfiles

param(
    [string]$Repository = "https://github.com/amitse/dotfiles.git",
    [switch]$Force,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Bootstrapping dotfiles with chezmoi..." -ForegroundColor Green

# Function to check if a command exists
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Function to install chezmoi
function Install-Chezmoi {
    Write-Host "📦 Installing chezmoi..." -ForegroundColor Yellow
    
    # Try different installation methods
    if (Test-Command "winget") {
        Write-Host "   Using winget..." -ForegroundColor Gray
        winget install twpayne.chezmoi --silent
    }
    elseif (Test-Command "scoop") {
        Write-Host "   Using scoop..." -ForegroundColor Gray
        scoop install chezmoi
    }
    elseif (Test-Command "choco") {
        Write-Host "   Using chocolatey..." -ForegroundColor Gray
        choco install chezmoi -y
    }
    else {
        Write-Host "   Downloading chezmoi directly..." -ForegroundColor Gray
        
        # Download and install chezmoi manually
        $tempDir = [System.IO.Path]::GetTempPath()
        $chezmoiPath = Join-Path $tempDir "chezmoi.exe"
        
        # Detect architecture
        $arch = if ([Environment]::Is64BitOperatingSystem) { "amd64" } else { "i386" }
        $downloadUrl = "https://github.com/twpayne/chezmoi/releases/latest/download/chezmoi_windows_$arch.exe"
        
        Write-Host "   Downloading from: $downloadUrl" -ForegroundColor Gray
        Invoke-WebRequest -Uri $downloadUrl -OutFile $chezmoiPath
        
        # Create a directory in PATH for chezmoi
        $binDir = Join-Path $env:USERPROFILE ".local\bin"
        if (-not (Test-Path $binDir)) {
            New-Item -Path $binDir -ItemType Directory -Force | Out-Null
        }
        
        $chezmoiInstallPath = Join-Path $binDir "chezmoi.exe"
        Move-Item $chezmoiPath $chezmoiInstallPath -Force
        
        # Add to PATH if not already there
        $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($userPath -notlike "*$binDir*") {
            Write-Host "   Adding $binDir to PATH..." -ForegroundColor Gray
            [Environment]::SetEnvironmentVariable("PATH", "$userPath;$binDir", "User")
            $env:PATH = "$env:PATH;$binDir"
        }
    }
    
    # Verify installation
    if (Test-Command "chezmoi") {
        $version = chezmoi --version
        Write-Host "✅ chezmoi installed successfully: $version" -ForegroundColor Green
    }
    else {
        throw "❌ Failed to install chezmoi. Please install manually."
    }
}

# Function to install CLI enhancement tools
function Install-CLITools {
    Write-Host "🔧 Installing CLI enhancement tools..." -ForegroundColor Yellow
    
    # Try different package managers
    if (Test-Command "winget") {
        Write-Host "   Using winget..." -ForegroundColor Gray
        
        # Install modern CLI tools
        $tools = @(
            @{Name="bat"; Id="sharkdp.bat"},
            @{Name="ripgrep"; Id="BurntSushi.ripgrep.MSVC"},
            @{Name="fzf"; Id="junegunn.fzf"},
            @{Name="zoxide"; Id="ajeetdsouza.zoxide"}
        )
        
        foreach ($tool in $tools) {
            try {
                Write-Host "   Installing $($tool.Name)..." -ForegroundColor Gray
                winget install $tool.Id --silent --accept-package-agreements --accept-source-agreements 2>$null
            }
            catch {
                Write-Host "   ⚠️  Failed to install $($tool.Name) via winget" -ForegroundColor Yellow
            }
        }
    }
    elseif (Test-Command "scoop") {
        Write-Host "   Using scoop..." -ForegroundColor Gray
        
        # Add extras bucket for more tools
        scoop bucket add extras 2>$null
        
        $tools = @("bat", "ripgrep", "fzf", "zoxide", "exa")
        foreach ($tool in $tools) {
            try {
                Write-Host "   Installing $tool..." -ForegroundColor Gray
                scoop install $tool 2>$null
            }
            catch {
                Write-Host "   ⚠️  Failed to install $tool via scoop" -ForegroundColor Yellow
            }
        }
    }
    elseif (Test-Command "choco") {
        Write-Host "   Using chocolatey..." -ForegroundColor Gray
        
        $tools = @("bat", "ripgrep", "fzf", "zoxide")
        foreach ($tool in $tools) {
            try {
                Write-Host "   Installing $tool..." -ForegroundColor Gray
                choco install $tool -y 2>$null
            }
            catch {
                Write-Host "   ⚠️  Failed to install $tool via chocolatey" -ForegroundColor Yellow
            }
        }
    }
    else {
        Write-Host "   ⚠️  No package manager found. Consider installing winget, scoop, or chocolatey" -ForegroundColor Yellow
        Write-Host "   Manual installation links:" -ForegroundColor Gray
        Write-Host "     - bat: https://github.com/sharkdp/bat/releases" -ForegroundColor Gray
        Write-Host "     - ripgrep: https://github.com/BurntSushi/ripgrep/releases" -ForegroundColor Gray
        Write-Host "     - fzf: https://github.com/junegunn/fzf/releases" -ForegroundColor Gray
        Write-Host "     - zoxide: https://github.com/ajeetdsouza/zoxide/releases" -ForegroundColor Gray
    }
    
    Write-Host "✅ CLI tools installation completed" -ForegroundColor Green
}

# Function to initialize and apply dotfiles
function Initialize-Dotfiles {
    param([string]$Repo, [bool]$IsDryRun, [bool]$ForceApply)
    
    Write-Host "📁 Initializing dotfiles from: $Repo" -ForegroundColor Yellow
    
    # Check if chezmoi is already initialized
    $chezmoiSourceDir = chezmoi source-path 2>$null
    if ($chezmoiSourceDir -and (Test-Path $chezmoiSourceDir) -and -not $ForceApply) {
        Write-Host "⚠️  chezmoi already initialized at: $chezmoiSourceDir" -ForegroundColor Yellow
        Write-Host "   Use -Force to reinitialize" -ForegroundColor Gray
        return
    }
    
    if ($ForceApply -and $chezmoiSourceDir) {
        Write-Host "🗑️  Removing existing chezmoi configuration..." -ForegroundColor Yellow
        Remove-Item $chezmoiSourceDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # Initialize chezmoi
    Write-Host "   Initializing chezmoi..." -ForegroundColor Gray
    chezmoi init $Repo
    
    # Show what would be applied
    Write-Host "📋 Preview of changes:" -ForegroundColor Yellow
    chezmoi diff
    
    if ($IsDryRun) {
        Write-Host "🔍 Dry run complete. Use without -DryRun to apply changes." -ForegroundColor Cyan
        return
    }
    
    # Ask for confirmation unless forced
    if (-not $ForceApply) {
        $response = Read-Host "`n❓ Apply these changes? (y/N)"
        if ($response -ne "y" -and $response -ne "Y") {
            Write-Host "❌ Aborted by user." -ForegroundColor Red
            return
        }
    }
    
    # Apply dotfiles
    Write-Host "⚙️  Applying dotfiles..." -ForegroundColor Yellow
    chezmoi apply
    
    Write-Host "✅ Dotfiles applied successfully!" -ForegroundColor Green
}

# Main execution
try {
    # Check if chezmoi is installed
    if (-not (Test-Command "chezmoi")) {
        Install-Chezmoi
    }
    else {
        $version = chezmoi --version
        Write-Host "✅ chezmoi already installed: $version" -ForegroundColor Green
    }
    
    # Install CLI enhancement tools
    Install-CLITools
    
    # Initialize and apply dotfiles
    Initialize-Dotfiles -Repo $Repository -IsDryRun $DryRun -ForceApply $Force
    
    Write-Host "`n🎉 Bootstrap complete!" -ForegroundColor Green
    Write-Host "📚 See README.md for usage instructions" -ForegroundColor Cyan
    Write-Host "🔧 Edit files with: chezmoi edit <file>" -ForegroundColor Cyan
    Write-Host "📄 View changes with: chezmoi diff" -ForegroundColor Cyan
    Write-Host "⚡ Apply changes with: chezmoi apply" -ForegroundColor Cyan
}
catch {
    Write-Host "❌ Bootstrap failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}