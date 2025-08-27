#!/bin/bash#!/bin/bash

# Simple dotfiles installer# Enhanced dotfiles installer using chezmoi

# Usage: curl -fsSL https://raw.githubusercontent.com/amitse/dotfiles/main/scripts/install/unix/install-unix.sh | bash# Usage (Linux/macOS):

#   curl -fsSL https://raw.githubusercontent.com/amitse/dotfiles/main/scripts/install/unix/install-unix.sh | bash

set -e

set -e

echo "🚀 Power User Dotfiles Installer"

echo "================================="# Colors

GREEN='\033[0;32m'

# Detect package managerBLUE='\033[0;34m'

if command -v apt >/dev/null 2>&1; thenYELLOW='\033[1;33m'

    PM="apt"RED='\033[0;31m'

    INSTALL_CMD="sudo apt update && sudo apt install -y"CYAN='\033[0;36m'

    TOOLS="git tmux fzf ripgrep bat zoxide exa entr gh delta fd-find"NC='\033[0m'

elif command -v dnf >/dev/null 2>&1; then

    PM="dnf"DOTFILES_REPO="amitse/dotfiles"

    INSTALL_CMD="sudo dnf install -y"

    TOOLS="git tmux fzf ripgrep bat zoxide exa entr gh delta fd-find"echo -e "${GREEN}🚀 Power User Dotfiles Installer${NC}"

elif command -v yum >/dev/null 2>&1; thenecho -e "${BLUE}=================================${NC}"

    PM="yum"echo ""

    INSTALL_CMD="sudo yum install -y"

    TOOLS="git tmux fzf ripgrep bat zoxide exa entr gh delta fd-find"# Safe read helper: prefer /dev/tty when stdin is not a terminal (e.g. curl | bash)

elif command -v pacman >/dev/null 2>&1; thensafe_read() {

    PM="pacman"    # Usage: safe_read "Prompt: " varname

    INSTALL_CMD="sudo pacman -S --noconfirm"    local prompt="$1"

    TOOLS="git tmux fzf ripgrep bat zoxide exa entr github-cli git-delta fd"    local __resultvar="$2"

elif command -v brew >/dev/null 2>&1; then    # If stdin is a TTY, read normally

    PM="brew"    if [ -t 0 ]; then

    INSTALL_CMD="brew install"        read -r -p "$prompt" "$__resultvar"

    TOOLS="git tmux fzf ripgrep bat zoxide exa entr gh git-delta fd"        return $?

else    fi

    echo "❌ No supported package manager found (apt/dnf/yum/pacman/brew)"    # Otherwise try reading from /dev/tty if available. Use fd 3 to

    exit 1    # avoid clobbering stdin/stdout and improve compatibility.

fi    if [ -e /dev/tty ]; then

        # Open /dev/tty on fd 3 for reading, read using -u 3, then close fd 3

echo "📦 Installing tools with $PM..."        exec 3</dev/tty

        read -r -u 3 -p "$prompt" "$__resultvar"

# Install chezmoi first        local rc=$?

if ! command -v chezmoi >/dev/null 2>&1; then        exec 3<&-

    if [ "$PM" = "brew" ]; then        return $rc

        brew install chezmoi    fi

    else    # Non-interactive environment: return failure and set variable empty

        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin    eval "$__resultvar=''"

        export PATH="$HOME/.local/bin:$PATH"    return 1

    fi}

fi

# Function to prompt for git credentials

# Install all tools in one commandprompt_git_credentials() {

echo "📦 Installing: $TOOLS"    echo ""

$INSTALL_CMD $TOOLS || echo "⚠️  Some tools may have failed to install, continuing..."    echo -e "${YELLOW}🔧 Git Configuration${NC}"

    echo "We'll configure git with your information."

echo "🔧 Setting up dotfiles with chezmoi..."    echo ""

if chezmoi init --apply https://github.com/amitse/dotfiles.git; then    

    echo "✅ Dotfiles setup complete!"    # Prompt for git name (use safe_read; fallback to env or default)

else    if safe_read "Enter your full name for git commits: " git_name; then

    echo "❌ Chezmoi setup failed. Please run manually:"        while [[ -z "$git_name" ]]; do

    echo "   chezmoi init --apply https://github.com/amitse/dotfiles.git"            echo -e "${RED}❌ Name cannot be empty${NC}"

fi            if ! safe_read "Enter your full name for git commits: " git_name; then

                break

echo ""            fi

echo "🎉 Installation complete! Restart your terminal to use new tools."        done
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