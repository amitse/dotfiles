#!/bin/bash
# Linux-specific dotfiles bootstrap script
# Simple and focused installation for Linux systems

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO_URL="https://github.com/amitse/dotfiles.git"

echo -e "${GREEN}🐧 Linux dotfiles bootstrap${NC}"
echo

# Install chezmoi
if ! command -v chezmoi >/dev/null 2>&1; then
    echo -e "${BLUE}📦 Installing chezmoi...${NC}"
    
    # Try package managers first
    if command -v apt-get >/dev/null 2>&1; then
        echo "Using apt..."
        sudo apt update
        if apt list chezmoi 2>/dev/null | grep -q chezmoi; then
            sudo apt install -y chezmoi
        else
            sh -c "$(curl -fsLS https://get.chezmoi.io)"
        fi
    elif command -v pacman >/dev/null 2>&1; then
        echo "Using pacman..."
        sudo pacman -S --noconfirm chezmoi
    elif command -v dnf >/dev/null 2>&1; then
        echo "Using dnf..."
        sudo dnf install -y chezmoi
    else
        echo "Using official script..."
        sh -c "$(curl -fsLS https://get.chezmoi.io)"
        export PATH="$HOME/.local/bin:$PATH"
    fi
else
    echo -e "${GREEN}✅ chezmoi already installed${NC}"
fi

# Install dependencies
echo -e "${BLUE}📦 Installing dependencies...${NC}"
if command -v apt-get >/dev/null 2>&1; then
    sudo apt install -y git tmux
    # Try clipboard tools (non-fatal)
    sudo apt install -y wl-clipboard 2>/dev/null || \
    sudo apt install -y xclip 2>/dev/null || \
    sudo apt install -y xsel 2>/dev/null || true
elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm git tmux
    sudo pacman -S --noconfirm wl-clipboard 2>/dev/null || \
    sudo pacman -S --noconfirm xclip 2>/dev/null || true
fi

# Setup dotfiles
echo -e "${BLUE}⚙️  Setting up dotfiles...${NC}"
chezmoi init "$REPO_URL"

echo -e "${YELLOW}📋 Preview of changes:${NC}"
chezmoi diff

read -p "Apply dotfiles? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    chezmoi apply
    echo -e "${GREEN}✅ Dotfiles installed!${NC}"
else
    echo -e "${YELLOW}⏸️  Skipped. Run 'chezmoi apply' when ready.${NC}"
fi

echo
echo -e "${BLUE}📚 Usage:${NC}"
echo "  chezmoi edit ~/.tmux.conf  # Edit files"
echo "  chezmoi diff              # See changes"
echo "  chezmoi apply             # Apply changes"