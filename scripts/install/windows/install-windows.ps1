# Simple Windows dotfiles installer
# Usage: irm https://raw.githubusercontent.com/amitse/dotfiles/main/scripts/install/windows/install-windows.ps1 | iex

$ErrorActionPreference = "Stop"

# Tools to install
$tools = @(
    "twpayne.chezmoi"
    "junegunn.fzf"
    "BurntSushi.ripgrep.MSVC"
    "sharkdp.bat"
    "ajeetdsouza.zoxide"
    "eza-community.eza"
    "GitHub.cli"
    "dandavison.delta"
    "sharkdp.fd"
    "jesseduffield.lazygit"
    "ClementTsang.bottom"
    "bootandy.dust"
)

Write-Host "� Installing dotfiles..." -ForegroundColor Green

# Install all tools in one command
Write-Host "📦 Installing tools with winget..." -ForegroundColor Yellow
try {
    $toolsList = $tools -join " --id "
    $command = "winget install --id $toolsList --silent --accept-package-agreements --accept-source-agreements"
    Invoke-Expression $command
    Write-Host "✅ Tools installed" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Some tools may have failed, continuing..." -ForegroundColor Yellow
}

# Initialize dotfiles with chezmoi
Write-Host "🔧 Setting up dotfiles..." -ForegroundColor Yellow
try {
    chezmoi init --apply https://github.com/amitse/dotfiles.git
    Write-Host "✅ Dotfiles setup complete!" -ForegroundColor Green
} catch {
    Write-Host "❌ Chezmoi setup failed. Run manually:" -ForegroundColor Red
    Write-Host "   chezmoi init --apply https://github.com/amitse/dotfiles.git"
}

Write-Host "🎉 Done! Restart your terminal." -ForegroundColor Green