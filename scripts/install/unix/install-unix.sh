#!/bin/bash
# Simple Unix dotfiles installer
# Usage: curl -fsSL https://raw.githubusercontent.com/amitse/dotfiles/main/scripts/install/unix/install-unix.sh | bash

set -e

# Common tools across distros
tools_common="fzf ripgrep bat fd-find zoxide exa git-delta lazygit bottom dust"

echo "🚀 Installing dotfiles..."

# Detect package manager and install tools
if command -v apt >/dev/null 2>&1; then
    echo "📦 Installing tools with apt..."
    sudo apt update
    sudo apt install -y curl $tools_common
elif command -v pacman >/dev/null 2>&1; then
    echo "📦 Installing tools with pacman..."
    sudo pacman -S --noconfirm curl $tools_common
elif command -v dnf >/dev/null 2>&1; then
    echo "📦 Installing tools with dnf..."
    sudo dnf install -y curl $tools_common
elif command -v yum >/dev/null 2>&1; then
    echo "📦 Installing tools with yum..."
    sudo yum install -y curl $tools_common
elif command -v brew >/dev/null 2>&1; then
    echo "📦 Installing tools with brew..."
    brew install $tools_common
else
    echo "❌ No supported package manager found"
    exit 1
fi

# Install chezmoi
echo "📦 Installing chezmoi..."
if ! command -v chezmoi >/dev/null 2>&1; then
    sh -c "$(curl -fsLS get.chezmoi.io)"
    export PATH="$HOME/.local/bin:$PATH"
else
    echo "✅ chezmoi already installed"
fi

# Initialize dotfiles
echo "🔧 Setting up dotfiles..."
if chezmoi init --apply https://github.com/amitse/dotfiles.git; then
    echo "✅ Dotfiles setup complete!"
else
    echo "❌ Chezmoi setup failed. Run manually:"
    echo "   chezmoi init --apply https://github.com/amitse/dotfiles.git"
fi

echo "🎉 Done! Restart your terminal."