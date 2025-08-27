# Dotfiles health check script for PowerShell
# Verifies installation, configuration, and tool availability

$ErrorActionPreference = "Continue"

# Colors for output
$Colors = @{
    Green = "Green"
    Blue = "Blue"
    Yellow = "Yellow"
    Red = "Red"
    Cyan = "Cyan"
}

# Counters
$Script:ChecksPassed = 0
$Script:ChecksFailed = 0
$Script:ChecksWarning = 0

function Write-LogInfo {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor $Colors.Blue
}

function Write-LogSuccess {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor $Colors.Green
    $Script:ChecksPassed++
}

function Write-LogWarning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor $Colors.Yellow
    $Script:ChecksWarning++
}

function Write-LogError {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor $Colors.Red
    $Script:ChecksFailed++
}

function Write-LogHeader {
    param([string]$Message)
    Write-Host "🔍 $Message" -ForegroundColor $Colors.Cyan
    Write-Host ("=" * 50)
}

function Test-CommandExists {
    param([string]$Command)
    try {
        if (Get-Command $Command -ErrorAction SilentlyContinue) {
            return $true
        }
        return $false
    }
    catch {
        return $false
    }
}

function Test-ChezmoiInstallation {
    Write-LogHeader "Checking chezmoi Installation"
    
    if (Test-CommandExists "chezmoi") {
        try {
            $version = (chezmoi --version 2>$null) -split "`n" | Select-Object -First 1
            Write-LogSuccess "chezmoi installed: $version"
            
            # Check if chezmoi is initialized
            try {
                $sourceDir = chezmoi source-path 2>$null
                if ($sourceDir) {
                    Write-LogSuccess "chezmoi initialized at: $sourceDir"
                    
                    # Check if we can verify files
                    $verifyResult = chezmoi verify --quiet 2>$null
                    if ($LASTEXITCODE -eq 0) {
                        Write-LogSuccess "All managed files are in sync"
                    } else {
                        Write-LogWarning "Some files have been modified outside chezmoi"
                        Write-LogInfo "Run 'chezmoi diff' to see changes"
                    }
                } else {
                    Write-LogError "chezmoi not initialized"
                    Write-LogInfo "Run 'chezmoi init https://github.com/username/dotfiles.git'"
                    return $false
                }
            }
            catch {
                Write-LogError "chezmoi not initialized"
                Write-LogInfo "Run 'chezmoi init https://github.com/username/dotfiles.git'"
                return $false
            }
        }
        catch {
            Write-LogError "Error checking chezmoi status"
            return $false
        }
    } else {
        Write-LogError "chezmoi not installed"
        Write-LogInfo "Install with: irm https://get.chezmoi.io/ps1 | iex"
        return $false
    }
    return $true
}

function Test-EssentialTools {
    Write-LogHeader "Checking Essential Tools"
    
    $essentialTools = @("git", "tmux")
    
    foreach ($tool in $essentialTools) {
        if (Test-CommandExists $tool) {
            $version = ""
            switch ($tool) {
                "git" {
                    try {
                        $version = (git --version 2>$null) -replace "git version ", ""
                    } catch { $version = "unknown" }
                }
                "tmux" {
                    try {
                        $version = (tmux -V 2>$null) -replace "tmux ", ""
                    } catch { $version = "unknown" }
                }
            }
            $versionText = if ($version) { " (v$version)" } else { "" }
            Write-LogSuccess "$tool installed$versionText"
        } else {
            Write-LogError "$tool not found"
        }
    }
}

function Test-ModernTools {
    Write-LogHeader "Checking Modern CLI Tools"
    
    $modernTools = @("fzf", "rg", "bat", "zoxide", "exa", "gh", "delta", "fd")
    $available = @()
    $missing = @()
    
    foreach ($tool in $modernTools) {
        if (Test-CommandExists $tool) {
            $available += $tool
        } else {
            $missing += $tool
        }
    }
    
    if ($available.Count -gt 0) {
        Write-LogSuccess "Available: $($available -join ', ')"
    }
    
    if ($missing.Count -gt 0) {
        Write-LogWarning "Missing: $($missing -join ', ')"
        Write-LogInfo "These tools provide enhanced functionality but are optional"
    }
}

function Test-ShellConfiguration {
    Write-LogHeader "Checking Shell Configuration"
    
    # Check current shell
    $currentShell = $env:SHELL
    if (-not $currentShell) {
        $currentShell = "PowerShell"
    }
    
    Write-LogSuccess "Using: $currentShell"
    
    if ($currentShell -like "*zsh*") {
        # Check if .zshrc is managed by chezmoi
        try {
            $managed = chezmoi managed ~/.zshrc 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess ".zshrc is managed by chezmoi"
            } else {
                Write-LogWarning ".zshrc is not managed by chezmoi"
            }
        }
        catch {
            Write-LogWarning ".zshrc management status unknown"
        }
    } elseif ($currentShell -like "*PowerShell*") {
        Write-LogSuccess "PowerShell detected (Windows native)"
        
        # Check PowerShell profile
        if (Test-Path $PROFILE) {
            Write-LogSuccess "PowerShell profile exists"
        } else {
            Write-LogWarning "PowerShell profile not found"
        }
    }
    
    # Check environment variables
    if ($env:EDITOR) {
        Write-LogSuccess "EDITOR set to: $env:EDITOR"
    } else {
        Write-LogWarning "EDITOR not set"
    }
}

function Test-GitConfiguration {
    Write-LogHeader "Checking Git Configuration"
    
    if (Test-CommandExists "git") {
        # Check basic git config
        try {
            $gitName = git config --global user.name 2>$null
            $gitEmail = git config --global user.email 2>$null
            
            if ($gitName) {
                Write-LogSuccess "Git user name: $gitName"
            } else {
                Write-LogWarning "Git user name not set"
                Write-LogInfo "Set with: git config --global user.name 'Your Name'"
            }
            
            if ($gitEmail) {
                Write-LogSuccess "Git user email: $gitEmail"
            } else {
                Write-LogWarning "Git user email not set"
                Write-LogInfo "Set with: git config --global user.email 'your@email.com'"
            }
            
            # Check if gitconfig is managed
            try {
                $managed = chezmoi managed ~/.gitconfig 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-LogSuccess "Git configuration is managed by chezmoi"
                } else {
                    Write-LogWarning "Git configuration not managed by chezmoi"
                }
            }
            catch {
                Write-LogWarning "Cannot determine git config management status"
            }
            
            # Check git aliases
            try {
                $alias = git config --global alias.st 2>$null
                if ($alias) {
                    Write-LogSuccess "Git aliases configured"
                } else {
                    Write-LogWarning "Git aliases not configured"
                }
            }
            catch {
                Write-LogWarning "Cannot check git aliases"
            }
        }
        catch {
            Write-LogError "Error checking git configuration"
        }
    }
}

function Test-PlatformFeatures {
    Write-LogHeader "Checking Platform-Specific Features"
    
    $os = [System.Environment]::OSVersion.Platform
    Write-LogSuccess "Platform: Windows"
    
    # Check package managers
    if (Test-CommandExists "winget") {
        Write-LogSuccess "Package manager: winget"
    } elseif (Test-CommandExists "scoop") {
        Write-LogSuccess "Package manager: scoop"
    } elseif (Test-CommandExists "choco") {
        Write-LogSuccess "Package manager: chocolatey"
    } else {
        Write-LogWarning "No package manager detected"
        Write-LogInfo "Consider installing winget, scoop, or chocolatey"
    }
    
    # Check for WSL
    if (Test-CommandExists "wsl") {
        Write-LogSuccess "WSL available"
    }
}

function Show-Summary {
    Write-Host ""
    Write-LogHeader "Health Check Summary"
    
    $total = $Script:ChecksPassed + $Script:ChecksFailed + $Script:ChecksWarning
    
    Write-Host "✅ Passed: $Script:ChecksPassed" -ForegroundColor $Colors.Green
    Write-Host "⚠️  Warnings: $Script:ChecksWarning" -ForegroundColor $Colors.Yellow
    Write-Host "❌ Failed: $Script:ChecksFailed" -ForegroundColor $Colors.Red
    Write-Host "📊 Total: $total" -ForegroundColor $Colors.Blue
    
    Write-Host ""
    
    if ($Script:ChecksFailed -eq 0) {
        if ($Script:ChecksWarning -eq 0) {
            Write-LogSuccess "Perfect! Your dotfiles setup is healthy! 🎉"
        } else {
            Write-LogInfo "Good! Minor warnings that can be improved 👍"
        }
    } else {
        Write-LogError "Issues found that need attention 🔧"
        Write-LogInfo "Check the errors above and follow the suggested fixes"
    }
    
    Write-Host ""
    Write-LogInfo "💡 Tips:"
    Write-Host "  • Run this check regularly with: .\scripts\health-check.ps1"
    Write-Host "  • Update dotfiles: chezmoi update"
    Write-Host "  • Edit configs: chezmoi edit <file>"
    Write-Host "  • Get help: chezmoi help"
}

# Main execution
function Invoke-HealthCheck {
    Write-Host "🏥 Dotfiles Health Check" -ForegroundColor $Colors.Cyan
    Write-Host (Get-Date)
    Write-Host ""
    
    Test-ChezmoiInstallation
    Write-Host ""
    
    Test-EssentialTools
    Write-Host ""
    
    Test-ModernTools
    Write-Host ""
    
    Test-ShellConfiguration
    Write-Host ""
    
    Test-GitConfiguration
    Write-Host ""
    
    Test-PlatformFeatures
    Write-Host ""
    
    Show-Summary
}

# Run main function
Invoke-HealthCheck