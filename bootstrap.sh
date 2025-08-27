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
                log_info "Installing essential tools (apt)..."
                sudo apt update
                # Essential tools
                sudo apt install -y git tmux curl zsh || true
                # Clipboard tools (non-fatal)
                sudo apt install -y wl-clipboard || sudo apt install -y xclip || sudo apt install -y xsel || true
                
                log_info "Installing CLI enhancement tools (apt)..."
                # Modern CLI tools
                sudo apt install -y bat ripgrep fzf fd-find || true
                sudo apt install -y mc || true  # Midnight Commander
                
                log_info "Installing GitHub CLI (apt)..."
                # GitHub CLI installation for Ubuntu/Debian
                if ! command_exists gh; then
                    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
                    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                    sudo apt update && sudo apt install -y gh || true
                fi
                
            elif command_exists pacman; then
                log_info "Installing tools (pacman)..."
                sudo pacman -S --noconfirm git tmux curl zsh || true
                sudo pacman -S --noconfirm wl-clipboard || sudo pacman -S --noconfirm xclip || true
                
                log_info "Installing CLI enhancement tools (pacman)..."
                sudo pacman -S --noconfirm bat ripgrep fzf fd exa zoxide mc || true
                
                log_info "Installing GitHub CLI (pacman)..."
                sudo pacman -S --noconfirm github-cli || true
                
            elif command_exists dnf; then
                log_info "Installing tools (dnf)..."
                sudo dnf install -y git tmux curl zsh || true
                sudo dnf install -y wl-clipboard || sudo dnf install -y xclip || true
                
                log_info "Installing CLI enhancement tools (dnf)..."
                sudo dnf install -y bat ripgrep fzf fd-find mc || true
                # exa and zoxide may need different repos
                
                log_info "Installing GitHub CLI (dnf)..."
                sudo dnf install -y gh || true
            fi
            
            # Try to install tools via other methods if package manager didn't have them
            install_modern_cli_tools_linux
            ;;
        "darwin")
            if command_exists brew; then
                log_info "Installing tools (Homebrew)..."
                brew install git tmux zsh || true
                
                log_info "Installing CLI enhancement tools (Homebrew)..."
                brew install bat ripgrep fzf fd exa zoxide entr midnight-commander || true
                
                log_info "Installing GitHub CLI (Homebrew)..."
                brew install gh || true
            fi
            ;;
        "windows")
            log_info "Windows detected - installing tools via package managers..."
            install_modern_cli_tools_windows
            ;;
    esac
    
    log_success "Dependencies installation completed"
}

# Install modern CLI tools on Linux via alternative methods
install_modern_cli_tools_linux() {
    log_info "Installing additional CLI tools via alternative methods..."
    
    # Install exa if not available
    if ! command_exists exa && ! command_exists eza; then
        log_info "Installing exa/eza (modern ls replacement)..."
        if command_exists cargo; then
            cargo install exa || cargo install eza || true
        elif [ -f "$HOME/.cargo/bin/cargo" ]; then
            "$HOME/.cargo/bin/cargo" install exa || "$HOME/.cargo/bin/cargo" install eza || true
        fi
    fi
    
    # Install zoxide if not available
    if ! command_exists zoxide; then
        log_info "Installing zoxide (smart cd replacement)..."
        if command_exists cargo; then
            cargo install zoxide || true
        elif [ -f "$HOME/.cargo/bin/cargo" ]; then
            "$HOME/.cargo/bin/cargo" install zoxide || true
        else
            # Try binary installation
            curl -sS https://webinstall.dev/zoxide | bash || true
        fi
    fi
    
    # Install entr if not available
    if ! command_exists entr; then
        log_info "Installing entr (file watcher)..."
        # Try from source if package manager doesn't have it
        if command_exists git && command_exists make; then
            cd /tmp
            git clone https://github.com/eradman/entr.git && cd entr && make test && sudo make install || true
            cd - > /dev/null
        fi
    fi
}

# Install modern CLI tools on Windows
install_modern_cli_tools_windows() {
    if command_exists winget.exe; then
        log_info "Installing CLI tools via winget..."
        # Install essential tools
        winget.exe install Git.Git --silent || true
        winget.exe install GitHub.cli --silent || true
        
        # Install modern CLI tools that are available via winget
        winget.exe install sharkdp.bat --silent || true
        winget.exe install BurntSushi.ripgrep.MSVC --silent || true
        winget.exe install junegunn.fzf --silent || true
        winget.exe install ajeetdsouza.zoxide --silent || true
        # Note: exa, entr, mc may not be available via winget
        
    elif command_exists scoop; then
        log_info "Installing CLI tools via scoop..."
        # Essential tools
        scoop install git gh || true
        
        # Modern CLI tools
        scoop install bat ripgrep fzf zoxide || true
        scoop install exa entr || true
        
    elif command_exists choco; then
        log_info "Installing CLI tools via chocolatey..."
        # Essential tools
        choco install git github-cli -y || true
        
        # Modern CLI tools
        choco install bat ripgrep fzf zoxide -y || true
        # Some tools may not be available
    fi
    
    # Try to install missing tools via other methods
    if ! command_exists bat; then
        log_warning "bat not installed - consider manually installing from https://github.com/sharkdp/bat"
    fi
    if ! command_exists rg; then
        log_warning "ripgrep not installed - consider manually installing from https://github.com/BurntSushi/ripgrep"
    fi
    if ! command_exists fzf; then
        log_warning "fzf not installed - consider manually installing from https://github.com/junegunn/fzf"
    fi
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