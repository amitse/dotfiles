#!/bin/bash
# Enhanced dotfiles installer using chezmoi with profile selection
# Usage: curl -fsSL https://raw.githubusercontent.com/amitse/dotfiles/main/install.sh | bash

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

DOTFILES_REPO="amitse/dotfiles"

echo -e "${GREEN}🚀 Enhanced Dotfiles Installer${NC}"
echo -e "${BLUE}================================${NC}"
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
    # Otherwise try reading from /dev/tty if available
    if [ -e /dev/tty ]; then
        read -r -p "$prompt" "$__resultvar" < /dev/tty
        return $?
    fi
    # Non-interactive environment: return failure and set variable empty
    eval "$__resultvar=''"
    return 1
}

# Function to show profile information
show_profile_info() {
    echo -e "${CYAN}📋 Available Profiles:${NC}"
    echo ""
    echo -e "${GREEN}1) Minimal Profile${NC}"
    echo -e "   📦 Tools: git, tmux"
    echo -e "   🎯 Perfect for: Servers, learning, minimalists"
    echo -e "   💾 Size: ~10MB"
    echo ""
    echo -e "${BLUE}2) Developer Profile${NC} ${YELLOW}(Recommended)${NC}"
    echo -e "   📦 Tools: git, tmux, fzf, ripgrep, bat, zoxide, gh"
    echo -e "   🎯 Perfect for: Daily development, most users"
    echo -e "   💾 Size: ~50MB"
    echo ""
    echo -e "${CYAN}3) Power User Profile${NC}"
    echo -e "   📦 Tools: Everything + exa, entr, delta, lazygit, advanced features"
    echo -e "   🎯 Perfect for: Maximum productivity, power users"
    echo -e "   💾 Size: ~100MB"
    echo ""
}

# Function to prompt for profile selection
select_profile() {
    while true; do
        show_profile_info
        echo -e "${YELLOW}Which profile would you like to install?${NC}"
        # Try to read interactively (prefers /dev/tty when stdin isn't a TTY)
        if ! safe_read "Enter your choice (1-3, or 'h' for help): " choice; then
            # No interactive TTY available — pick a sensible default (Developer)
            echo -e "${YELLOW}No TTY available; defaulting to Developer profile (2). To force non-interactive install, run with --non-interactive.${NC}"
            choice=2
        fi
        
        case $choice in
            1)
                echo -e "${GREEN}✅ Selected: Minimal Profile${NC}"
                export PROFILE_CHOICE="1"
                break
                ;;
            2)
                echo -e "${BLUE}✅ Selected: Developer Profile${NC}"
                export PROFILE_CHOICE="2"
                break
                ;;
            3)
                echo -e "${CYAN}✅ Selected: Power User Profile${NC}"
                export PROFILE_CHOICE="3"
                break
                ;;
            h|H|help)
                echo ""
                echo -e "${CYAN}💡 Profile Details:${NC}"
                echo ""
                echo -e "${GREEN}Minimal:${NC} Just the essentials for command-line work"
                echo -e "• git: Version control"
                echo -e "• tmux: Terminal multiplexer"
                echo ""
                echo -e "${BLUE}Developer:${NC} Modern CLI tools for efficient development"
                echo -e "• fzf: Fuzzy finder (Ctrl+R, Ctrl+T)"
                echo -e "• ripgrep: Ultra-fast text search"
                echo -e "• bat: Enhanced file viewer with syntax highlighting"
                echo -e "• zoxide: Smart directory jumping"
                echo -e "• gh: GitHub CLI"
                echo ""
                echo -e "${CYAN}Power User:${NC} Everything + advanced productivity tools"
                echo -e "• exa: Modern 'ls' replacement"
                echo -e "• delta: Beautiful git diffs"
                echo -e "• lazygit: Visual git interface"
                echo -e "• Advanced shell features and automation"
                echo ""
                continue
                ;;
            *)
                echo -e "${RED}❌ Invalid choice. Please enter 1, 2, 3, or 'h' for help.${NC}"
                echo ""
                continue
                ;;
        esac
    done
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
            curl -sfL https://git.io/chezmoi | sh
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ -n "$WSL_DISTRO_NAME" ]]; then
        # Linux
        curl -sfL https://git.io/chezmoi | sh
        # Add to PATH if needed
        if [[ ! "$PATH" =~ "$HOME/.local/bin" ]]; then
            export PATH="$HOME/.local/bin:$PATH"
        fi
    else
        # Fallback
        curl -sfL https://git.io/chezmoi | sh
    fi
    
    echo -e "${GREEN}✅ chezmoi installed${NC}"
}

# Function to create a temporary chezmoi config for profile preselection
create_temp_config() {
    local temp_dir=$(mktemp -d)
    local config_file="$temp_dir/chezmoi.toml"
    
    cat > "$config_file" << EOF
[data]
    profile_preselected = "${PROFILE_CHOICE}"
    git_name_preselected = "${GIT_NAME}"
    git_email_preselected = "${GIT_EMAIL}"
EOF
    
    export CHEZMOI_CONFIG_FILE="$config_file"
    export TEMP_CONFIG_DIR="$temp_dir"
}

# Function to initialize dotfiles
init_dotfiles() {
    echo -e "${BLUE}🔧 Initializing dotfiles...${NC}"
    
    if [[ -d "$HOME/.local/share/chezmoi" ]]; then
        echo -e "${YELLOW}⚠️  Dotfiles already initialized. Updating...${NC}"
        chezmoi update
    else
        echo -e "${BLUE}📥 Cloning and applying dotfiles...${NC}"
        
        # Use our temporary config if created
        if [[ -n "$CHEZMOI_CONFIG_FILE" ]]; then
            chezmoi init --config "$CHEZMOI_CONFIG_FILE" --apply "https://github.com/${DOTFILES_REPO}.git"
        else
            chezmoi init --apply "https://github.com/${DOTFILES_REPO}.git"
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
    
    case $PROFILE_CHOICE in
        1)
            echo -e "${GREEN}📦 Minimal Profile Installed${NC}"
            echo -e "• git with smart aliases"
            echo -e "• tmux with sensible defaults"
            ;;
        2)
            echo -e "${BLUE}📦 Developer Profile Installed${NC}"
            echo -e "• All minimal tools plus:"
            echo -e "• fzf (Ctrl+R for history, Ctrl+T for files)"
            echo -e "• ripgrep (rg command for fast search)"
            echo -e "• bat (enhanced cat with syntax highlighting)"
            echo -e "• zoxide (z command for smart directory jumping)"
            echo -e "• GitHub CLI (gh command)"
            ;;
        3)
            echo -e "${CYAN}📦 Power User Profile Installed${NC}"
            echo -e "• All developer tools plus:"
            echo -e "• exa (modern ls replacement)"
            echo -e "• delta (beautiful git diffs)"
            echo -e "• lazygit (visual git interface)"
            echo -e "• Advanced shell features"
            ;;
    esac
    
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
    if [[ "$PROFILE_CHOICE" != "1" ]]; then
        echo -e "• Try 'Ctrl+R' for fuzzy history search"
        echo -e "• Use 'z <partial-path>' for smart directory jumping"
    fi
    echo ""
    echo -e "${GREEN}✨ Your development environment is ready!${NC}"
}

# Main installation flow
main() {
    # Check for Windows (suggest PowerShell)
    if [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]]; then
        echo -e "${RED}❌ For Windows, please use PowerShell instead:${NC}"
        echo -e "${BLUE}irm https://raw.githubusercontent.com/${DOTFILES_REPO}/main/install.ps1 | iex${NC}"
        exit 1
    fi
    
    # Trap to ensure cleanup
    trap cleanup EXIT
    
    # Interactive profile selection
    select_profile
    
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
    export PROFILE_CHOICE="${2:-2}"
    export GIT_NAME="${3:-Test User}"
    export GIT_EMAIL="${4:-test@example.com}"
    echo -e "${YELLOW}Running in non-interactive mode...${NC}"
    install_chezmoi
    create_temp_config
    init_dotfiles
    echo -e "${GREEN}✅ Non-interactive installation complete${NC}"
    exit 0
fi

# Run main function
main "$@"