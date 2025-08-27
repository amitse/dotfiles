#!/bin/bash
# Enhanced dotfiles installer using chezmoi
# Usage (Linux/macOS):
#   curl -fsSL https://raw.githubusercontent.com/amitse/dotfiles/main/scripts/install/unix/install-unix.sh | bash

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

DOTFILES_REPO="amitse/dotfiles"

echo -e "${GREEN}🚀 Power User Dotfiles Installer${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""

# Safe read helper: prefer /dev/tty when stdin is not a terminal (e.g. curl | bash)
safe_read() {
    # Usage: safe_read "Prompt: " varname
    local prompt="$1"
    local __resultvar="$2"
    # If stdin is a TTY, read normally
    if [ -t 0 ]; then
        read -r -p "$prompt" "$__resultvar"
        return $?
    fi
    # Otherwise try reading from /dev/tty if available. Use fd 3 to
    # avoid clobbering stdin/stdout and improve compatibility.
    if [ -e /dev/tty ]; then
        # Open /dev/tty on fd 3 for reading, read using -u 3, then close fd 3
        exec 3</dev/tty
        read -r -u 3 -p "$prompt" "$__resultvar"
        local rc=$?
        exec 3<&-
        return $rc
    fi
    # Non-interactive environment: return failure and set variable empty
    eval "$__resultvar=''"
    return 1
}

# Function to prompt for git credentials
prompt_git_credentials() {
    echo ""
    echo -e "${YELLOW}🔧 Git Configuration${NC}"
    echo "We'll configure git with your information."
    echo ""
    
    # Prompt for git name (use safe_read; fallback to env or default)
    if safe_read "Enter your full name for git commits: " git_name; then
        while [[ -z "$git_name" ]]; do
            echo -e "${RED}❌ Name cannot be empty${NC}"
            if ! safe_read "Enter your full name for git commits: " git_name; then
                break
            fi
        done
    else
        # No tty: try environment or pick a default
        git_name="${GIT_NAME:-Test User}"
        echo -e "${YELLOW}No TTY available; using git name: $git_name${NC}"
    fi
    export GIT_NAME="$git_name"

    # Prompt for git email (use safe_read; fallback to env or default)
    if safe_read "Enter your email address for git commits: " git_email; then
        while [[ ! "$git_email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; do
            echo -e "${RED}❌ Please enter a valid email address${NC}"
            if ! safe_read "Enter your email address for git commits: " git_email; then
                break
            fi
        done
    else
        git_email="${GIT_EMAIL:-test@example.com}"
        echo -e "${YELLOW}No TTY available; using git email: $git_email${NC}"
    fi
    export GIT_EMAIL="$git_email"
    
    echo ""
    echo -e "${GREEN}✅ Git configured for: $git_name <$git_email>${NC}"
}

# Function to install chezmoi
install_chezmoi() {
    if command -v chezmoi >/dev/null 2>&1; then
        echo -e "${BLUE}✅ chezmoi already installed${NC}"
        return
    fi
    
    echo -e "${BLUE}📦 Installing chezmoi...${NC}"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew >/dev/null 2>&1; then
            brew install chezmoi
        else
            # Install chezmoi to ~/.local/bin explicitly
            sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ -n "$WSL_DISTRO_NAME" ]]; then
        # Linux
        # Install chezmoi to ~/.local/bin explicitly
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
        # Add to PATH if needed
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            export PATH="$HOME/.local/bin:$PATH"
        fi
    else
        # Fallback
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            export PATH="$HOME/.local/bin:$PATH"
        fi
    fi
    
    echo -e "${GREEN}✅ chezmoi installed${NC}"
}

# Function to create a temporary chezmoi config
create_temp_config() {
    local temp_dir=$(mktemp -d)
    local config_file="$temp_dir/chezmoi.toml"
    
    cat > "$config_file" << EOF
[data]
    git_name_preselected = "${GIT_NAME}"
    git_email_preselected = "${GIT_EMAIL}"
EOF
    
    export CHEZMOI_CONFIG_FILE="$config_file"
    export TEMP_CONFIG_DIR="$temp_dir"
}

# Function to initialize dotfiles
init_dotfiles() {
    echo -e "${BLUE}🔧 Initializing dotfiles...${NC}"
    
    # Resolve chezmoi binary robustly in case PATH/hash isn't updated yet
    resolve_chezmoi_bin() {
        if command -v chezmoi >/dev/null 2>&1; then
            command -v chezmoi
            return
        fi
        if [[ -x "$HOME/.local/bin/chezmoi" ]]; then
            echo "$HOME/.local/bin/chezmoi"
            return
        fi
        if [[ -x "./bin/chezmoi" ]]; then
            echo "./bin/chezmoi"
            return
        fi
        echo ""
    }
    
    local CM_BIN
    CM_BIN="$(resolve_chezmoi_bin)"
    if [[ -z "$CM_BIN" ]]; then
        echo -e "${RED}❌ Error: 'chezmoi' not found on PATH after installation.${NC}"
        echo -e "${YELLOW}Tip:${NC} Ensure $HOME/.local/bin is in your PATH and re-run the installer."
        exit 1
    fi
    
    if [[ -d "$HOME/.local/share/chezmoi" ]]; then
        echo -e "${YELLOW}⚠️  Dotfiles already initialized. Updating...${NC}"
        "$CM_BIN" update
    else
        echo -e "${BLUE}📥 Cloning and applying dotfiles...${NC}"
        
        # Use our temporary config if created
        if [[ -n "$CHEZMOI_CONFIG_FILE" ]]; then
            "$CM_BIN" init --config "$CHEZMOI_CONFIG_FILE" --apply "https://github.com/${DOTFILES_REPO}.git"
        else
            "$CM_BIN" init --apply "https://github.com/${DOTFILES_REPO}.git"
        fi
    fi
}

# Function to clean up temporary files
cleanup() {
    if [[ -n "$TEMP_CONFIG_DIR" ]] && [[ -d "$TEMP_CONFIG_DIR" ]]; then
        rm -rf "$TEMP_CONFIG_DIR"
    fi
}

# Function to show post-installation info
show_completion_info() {
    echo ""
    echo -e "${GREEN}🎉 Installation Complete!${NC}"
    echo -e "${GREEN}=========================${NC}"
    echo ""
    
    echo -e "${CYAN}📦 Power User Environment Installed${NC}"
    echo -e "• git with smart aliases and delta diffs"
    echo -e "• tmux with sensible defaults"
    echo -e "• fzf (Ctrl+R for history, Ctrl+T for files)"
    echo -e "• ripgrep (rg command for fast search)"
    echo -e "• bat (enhanced cat with syntax highlighting)"
    echo -e "• zoxide (z command for smart directory jumping)"
    echo -e "• exa (modern ls replacement)"
    echo -e "• lazygit (visual git interface)"
    echo -e "• GitHub CLI (gh command)"
    echo -e "• Advanced shell features and modern CLI tools"
    
    echo ""
    echo -e "${BLUE}📚 Useful Commands:${NC}"
    echo -e "  ${YELLOW}chezmoi status${NC}     - See what was configured"
    echo -e "  ${YELLOW}chezmoi diff${NC}       - See pending changes"
    echo -e "  ${YELLOW}chezmoi apply${NC}      - Apply changes"
    echo -e "  ${YELLOW}chezmoi update${NC}     - Pull and apply updates"
    echo -e "  ${YELLOW}chezmoi edit${NC}       - Edit configuration files"
    echo ""
    echo -e "${BLUE}🚀 Quick Start:${NC}"
    echo -e "• Open a new terminal to see your new environment"
    echo -e "• Type 'functions_help' to see available functions"
    echo -e "• Try 'Ctrl+R' for fuzzy history search"
    echo -e "• Use 'z <partial-path>' for smart directory jumping"
    echo -e "• Use 'exa -la' for modern directory listing"
    echo -e "• Use 'lazygit' for visual git interface"
    echo ""
    echo -e "${GREEN}✨ Your power user development environment is ready!${NC}"
}

# Main installation flow
main() {
    # Check for Windows (suggest PowerShell)
    if [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]]; then
        echo -e "${RED}❌ For Windows, please use PowerShell instead:${NC}"
        echo -e "${BLUE}irm https://raw.githubusercontent.com/${DOTFILES_REPO}/main/scripts/install/windows/install-windows.ps1 | iex${NC}"
        exit 1
    fi
    
    # Trap to ensure cleanup
    trap cleanup EXIT
    
    echo -e "${CYAN}Installing power user development environment...${NC}"
    
    # Git credentials
    prompt_git_credentials
    
    echo ""
    echo -e "${BLUE}🔄 Starting installation...${NC}"
    
    # Install chezmoi
    install_chezmoi
    
    # Create temporary config with preselected values
    create_temp_config
    
    # Initialize dotfiles
    init_dotfiles
    
    # Show completion information
    show_completion_info
}

# Handle non-interactive mode (for CI/testing)
if [[ "${1:-}" == "--non-interactive" ]]; then
    export GIT_NAME="${2:-Test User}"
    export GIT_EMAIL="${3:-test@example.com}"
    echo -e "${YELLOW}Running in non-interactive mode...${NC}"
    install_chezmoi
    create_temp_config
    init_dotfiles
    echo -e "${GREEN}✅ Non-interactive installation complete${NC}"
    exit 0
fi

# Run main function
main "$@"