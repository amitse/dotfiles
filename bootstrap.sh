#!/bin/bash
# Cross-platform dotfiles bootstrap script
# Works on Windows (Git Bash/WSL), Linux, and macOS
# Usage: curl -fsSL https://raw.githubusercontent.com/amitse/dotfiles/main/bootstrap.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/amitse/dotfiles.git"
DRY_RUN=false
FORCE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --repo)
            REPO_URL="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --dry-run    Show what would be done without applying changes"
            echo "  --force      Force reinstallation even if already set up"
            echo "  --repo URL   Use custom repository URL"
            echo "  -h, --help   Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_step() {
    echo -e "${CYAN}🔧 $1${NC}"
}

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "darwin"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ -n "$WSL_DISTRO_NAME" ]]; then
        echo "windows"
    else
        log_warning "Unknown OS type: $OSTYPE"
        echo "linux"  # Default fallback
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install chezmoi based on OS
install_chezmoi() {
    local os=$(detect_os)
    
    if command_exists chezmoi; then
        local version=$(chezmoi --version | head -n1)
        log_success "chezmoi already installed: $version"
        return 0
    fi
    
    log_step "Installing chezmoi for $os..."
    
    case $os in
        "linux")
            if command_exists apt-get; then
                # Try package manager first
                if apt list chezmoi 2>/dev/null | grep -q chezmoi; then
                    log_info "Installing via apt..."
                    sudo apt update && sudo apt install -y chezmoi
                else
                    install_chezmoi_script
                fi
            elif command_exists pacman; then
                log_info "Installing via pacman..."
                sudo pacman -S --noconfirm chezmoi
            elif command_exists dnf; then
                log_info "Installing via dnf..."
                sudo dnf install -y chezmoi
            elif command_exists yum; then
                log_info "Installing via yum..."
                sudo yum install -y chezmoi
            else
                install_chezmoi_script
            fi
            ;;
        "darwin")
            if command_exists brew; then
                log_info "Installing via Homebrew..."
                brew install chezmoi
            else
                install_chezmoi_script
            fi
            ;;
        "windows")
            if command_exists winget.exe; then
                log_info "Installing via winget..."
                winget.exe install twpayne.chezmoi --silent
            elif command_exists scoop; then
                log_info "Installing via scoop..."
                scoop install chezmoi
            elif command_exists choco; then
                log_info "Installing via chocolatey..."
                choco install chezmoi -y
            else
                install_chezmoi_script
            fi
            ;;
    esac
    
    # Verify installation
    if command_exists chezmoi; then
        local version=$(chezmoi --version | head -n1)
        log_success "chezmoi installed successfully: $version"
    else
        log_error "Failed to install chezmoi"
        exit 1
    fi
}

# Install chezmoi using the official script
install_chezmoi_script() {
    log_info "Installing via official script..."
    sh -c "$(curl -fsLS https://get.chezmoi.io)"
    
    # Add to PATH if needed
    if ! command_exists chezmoi && [ -f "$HOME/.local/bin/chezmoi" ]; then
        export PATH="$HOME/.local/bin:$PATH"
        log_info "Added ~/.local/bin to PATH for this session"
        log_warning "Add 'export PATH=\"\$HOME/.local/bin:\$PATH\"' to your shell profile"
    fi
}

# Install system dependencies
install_dependencies() {
    local os=$(detect_os)
    
    log_step "Installing system dependencies for $os..."
    
    case $os in
        "linux")
            if command_exists apt-get; then
                log_info "Installing clipboard tools (apt)..."
                # Install clipboard tools but don't fail if they're not available
                sudo apt update
                sudo apt install -y git tmux || true
                # Try to install clipboard tools (non-fatal)
                sudo apt install -y wl-clipboard || sudo apt install -y xclip || sudo apt install -y xsel || true
            elif command_exists pacman; then
                log_info "Installing tools (pacman)..."
                sudo pacman -S --noconfirm git tmux || true
                sudo pacman -S --noconfirm wl-clipboard || sudo pacman -S --noconfirm xclip || true
            elif command_exists dnf; then
                log_info "Installing tools (dnf)..."
                sudo dnf install -y git tmux || true
                sudo dnf install -y wl-clipboard || sudo dnf install -y xclip || true
            fi
            ;;
        "darwin")
            if command_exists brew; then
                log_info "Installing tools (Homebrew)..."
                brew install git tmux || true
            fi
            ;;
        "windows")
            log_info "Windows detected - assuming git and basic tools are available"
            # On Windows, we assume Git for Windows is installed
            ;;
    esac
    
    log_success "Dependencies installation completed"
}

# Initialize and apply dotfiles
setup_dotfiles() {
    log_step "Setting up dotfiles from $REPO_URL..."
    
    # Check if already initialized
    if chezmoi source-path >/dev/null 2>&1 && [ "$FORCE" != true ]; then
        local source_dir=$(chezmoi source-path)
        log_warning "chezmoi already initialized at: $source_dir"
        log_info "Use --force to reinitialize"
        return 0
    fi
    
    if [ "$FORCE" = true ]; then
        log_step "Force mode: removing existing chezmoi configuration..."
        chezmoi purge --force || true
    fi
    
    # Initialize chezmoi
    log_info "Initializing chezmoi..."
    chezmoi init "$REPO_URL"
    
    # Show what would be applied
    log_step "Preview of changes:"
    chezmoi diff
    
    if [ "$DRY_RUN" = true ]; then
        log_info "Dry run complete. Run without --dry-run to apply changes."
        return 0
    fi
    
    # Ask for confirmation unless forced
    if [ "$FORCE" != true ]; then
        echo
        read -p "Apply these changes? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_warning "Aborted by user."
            return 0
        fi
    fi
    
    # Apply dotfiles
    log_step "Applying dotfiles..."
    chezmoi apply
    
    log_success "Dotfiles applied successfully!"
}

# Main execution
main() {
    echo -e "${GREEN}🚀 Bootstrapping dotfiles with chezmoi...${NC}"
    echo
    
    # Install dependencies first
    install_dependencies
    
    # Install chezmoi
    install_chezmoi
    
    # Setup dotfiles
    setup_dotfiles
    
    echo
    log_success "Bootstrap complete!"
    echo
    log_info "Next steps:"
    echo -e "  ${CYAN}📚 Read the README: cat ~/.local/share/chezmoi/README.md${NC}"
    echo -e "  ${CYAN}🔧 Edit files: chezmoi edit <file>${NC}"
    echo -e "  ${CYAN}📄 View changes: chezmoi diff${NC}"
    echo -e "  ${CYAN}⚡ Apply changes: chezmoi apply${NC}"
    echo
}

# Run main function
main "$@"