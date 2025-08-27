#!/bin/bash
# Dotfiles health check script
# Verifies installation, configuration, and tool availability

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
    ((CHECKS_PASSED++))
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((CHECKS_WARNING++))
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
    ((CHECKS_FAILED++))
}

log_header() {
    echo -e "${CYAN}🔍 $1${NC}"
    echo "$(printf '=%.0s' {1..50})"
}

# Check if chezmoi is installed and working
check_chezmoi() {
    log_header "Checking chezmoi Installation"
    
    if command -v chezmoi >/dev/null 2>&1; then
        local version=$(chezmoi --version | head -1)
        log_success "chezmoi installed: $version"
        
        # Check if chezmoi is initialized
        if chezmoi source-path >/dev/null 2>&1; then
            local source_dir=$(chezmoi source-path)
            log_success "chezmoi initialized at: $source_dir"
            
            # Check if we can verify files
            if chezmoi verify --quiet 2>/dev/null; then
                log_success "All managed files are in sync"
            else
                log_warning "Some files have been modified outside chezmoi"
                log_info "Run 'chezmoi diff' to see changes"
            fi
        else
            log_error "chezmoi not initialized"
            log_info "Run 'chezmoi init https://github.com/username/dotfiles.git'"
            return 1
        fi
    else
    log_error "chezmoi not installed"
    log_info "Install with: sh -c \"$(curl -fsLS get.chezmoi.io)\" -- -b \"$HOME/.local/bin\""
        return 1
    fi
}

# Check essential tools
check_essential_tools() {
    log_header "Checking Essential Tools"
    
    local essential_tools=("git" "tmux")
    
    for tool in "${essential_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            local version=""
            case "$tool" in
                "git")
                    version=$(git --version | cut -d' ' -f3)
                    ;;
                "tmux")
                    version=$(tmux -V | cut -d' ' -f2)
                    ;;
            esac
            log_success "$tool installed${version:+ (v$version)}"
        else
            log_error "$tool not found"
        fi
    done
}

# Check modern CLI tools
check_modern_tools() {
    log_header "Checking Modern CLI Tools"
    
    local modern_tools=("fzf" "rg" "bat" "zoxide" "exa" "gh" "delta" "fd")
    local available=()
    local missing=()
    
    for tool in "${modern_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            available+=("$tool")
        else
            missing+=("$tool")
        fi
    done
    
    if [ ${#available[@]} -gt 0 ]; then
        log_success "Available: ${available[*]}"
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_warning "Missing: ${missing[*]}"
        log_info "These tools provide enhanced functionality but are optional"
    fi
}

# Check shell configuration
check_shell_config() {
    log_header "Checking Shell Configuration"
    
    # Check current shell
    if [ -n "$ZSH_VERSION" ]; then
        log_success "Using Zsh (recommended)"
        
        # Check if .zshrc is managed by chezmoi
        if chezmoi managed ~/.zshrc >/dev/null 2>&1; then
            log_success ".zshrc is managed by chezmoi"
        else
            log_warning ".zshrc is not managed by chezmoi"
        fi
        
        # Check for zsh-specific features
        if command -v fzf >/dev/null 2>&1; then
            if bindkey | grep -q "fzf" 2>/dev/null; then
                log_success "FZF key bindings loaded"
            else
                log_warning "FZF key bindings not loaded (try restarting shell)"
            fi
        fi
        
    elif [ -n "$BASH_VERSION" ]; then
        log_warning "Using Bash (consider switching to Zsh for enhanced features)"
        log_info "Install zsh and run: chsh -s \$(which zsh)"
    else
        log_warning "Unknown shell: $SHELL"
    fi
    
    # Check environment variables
    if [ -n "$EDITOR" ]; then
        log_success "EDITOR set to: $EDITOR"
    else
        log_warning "EDITOR not set"
    fi
}

# Check tmux configuration
check_tmux_config() {
    log_header "Checking tmux Configuration"
    
    if command -v tmux >/dev/null 2>&1; then
        # Check if tmux config is managed
        if chezmoi managed ~/.tmux.conf >/dev/null 2>&1; then
            log_success "tmux configuration is managed by chezmoi"
        else
            log_warning "tmux configuration not managed by chezmoi"
        fi
        
        # Check if tmux is running
        if tmux list-sessions >/dev/null 2>&1; then
            log_success "tmux sessions available"
        else
            log_info "No tmux sessions running (this is normal)"
        fi
        
        # Check clipboard integration
        local clip_cmd=""
        if command -v wl-copy >/dev/null 2>&1; then
            clip_cmd="wl-copy (Wayland)"
        elif command -v xclip >/dev/null 2>&1; then
            clip_cmd="xclip (X11)"
        elif command -v xsel >/dev/null 2>&1; then
            clip_cmd="xsel (X11)"
        elif command -v pbcopy >/dev/null 2>&1; then
            clip_cmd="pbcopy (macOS)"
        elif command -v clip.exe >/dev/null 2>&1; then
            clip_cmd="clip.exe (Windows)"
        fi
        
        if [ -n "$clip_cmd" ]; then
            log_success "Clipboard integration: $clip_cmd"
        else
            log_warning "No clipboard tool detected"
            log_info "Install wl-clipboard, xclip, or xsel for clipboard support"
        fi
    fi
}

# Check git configuration
check_git_config() {
    log_header "Checking Git Configuration"
    
    if command -v git >/dev/null 2>&1; then
        # Check basic git config
        local git_name=$(git config --global user.name 2>/dev/null)
        local git_email=$(git config --global user.email 2>/dev/null)
        
        if [ -n "$git_name" ]; then
            log_success "Git user name: $git_name"
        else
            log_warning "Git user name not set"
            log_info "Set with: git config --global user.name 'Your Name'"
        fi
        
        if [ -n "$git_email" ]; then
            log_success "Git user email: $git_email"
        else
            log_warning "Git user email not set"
            log_info "Set with: git config --global user.email 'your@email.com'"
        fi
        
        # Check if gitconfig is managed
        if chezmoi managed ~/.gitconfig >/dev/null 2>&1; then
            log_success "Git configuration is managed by chezmoi"
        else
            log_warning "Git configuration not managed by chezmoi"
        fi
        
        # Check git aliases
        if git config --global alias.st >/dev/null 2>&1; then
            log_success "Git aliases configured"
        else
            log_warning "Git aliases not configured"
        fi
    fi
}

# Check for updates
check_updates() {
    log_header "Checking for Updates"
    
    if chezmoi source-path >/dev/null 2>&1; then
        local source_dir=$(chezmoi source-path)
        
        if [ -d "$source_dir/.git" ]; then
            cd "$source_dir"
            
            # Check for local changes
            if git status --porcelain | grep -q .; then
                log_warning "Local changes not committed"
                log_info "Commit changes: cd \$(chezmoi source-path) && git add . && git commit"
            else
                log_success "No uncommitted local changes"
            fi
            
            # Check for remote updates
            git fetch origin >/dev/null 2>&1
            local local_commit=$(git rev-parse HEAD)
            local remote_commit=$(git rev-parse @{u} 2>/dev/null)
            
            if [ "$local_commit" != "$remote_commit" ] && [ -n "$remote_commit" ]; then
                log_warning "Remote updates available"
                log_info "Update with: chezmoi update"
            else
                log_success "Up to date with remote"
            fi
        else
            log_warning "Not a git repository"
        fi
    fi
}

# Check platform-specific features
check_platform_features() {
    log_header "Checking Platform-Specific Features"
    
    local os=$(uname -s)
    case "$os" in
        "Linux")
            log_success "Platform: Linux"
            
            # Check package manager
            if command -v apt >/dev/null 2>&1; then
                log_success "Package manager: apt"
            elif command -v pacman >/dev/null 2>&1; then
                log_success "Package manager: pacman"
            elif command -v dnf >/dev/null 2>&1; then
                log_success "Package manager: dnf"
            elif command -v yum >/dev/null 2>&1; then
                log_success "Package manager: yum"
            else
                log_warning "No recognized package manager"
            fi
            
            # Check for WSL
            if grep -qi "microsoft" /proc/version 2>/dev/null; then
                log_success "Running in WSL"
            fi
            ;;
        "Darwin")
            log_success "Platform: macOS"
            
            if command -v brew >/dev/null 2>&1; then
                log_success "Package manager: Homebrew"
            else
                log_warning "Homebrew not installed"
                log_info "Install from: https://brew.sh"
            fi
            ;;
        "CYGWIN"*|"MINGW"*|"MSYS"*)
            log_success "Platform: Windows (Git Bash/MSYS)"
            
            if command -v winget.exe >/dev/null 2>&1; then
                log_success "Package manager: winget"
            elif command -v scoop >/dev/null 2>&1; then
                log_success "Package manager: scoop"
            elif command -v choco >/dev/null 2>&1; then
                log_success "Package manager: chocolatey"
            else
                log_warning "No package manager detected"
            fi
            ;;
        *)
            log_warning "Unknown platform: $os"
            ;;
    esac
}

# Show summary
show_summary() {
    echo ""
    log_header "Health Check Summary"
    
    local total=$((CHECKS_PASSED + CHECKS_FAILED + CHECKS_WARNING))
    
    echo -e "${GREEN}✅ Passed: $CHECKS_PASSED${NC}"
    echo -e "${YELLOW}⚠️  Warnings: $CHECKS_WARNING${NC}"
    echo -e "${RED}❌ Failed: $CHECKS_FAILED${NC}"
    echo -e "${BLUE}📊 Total: $total${NC}"
    
    echo ""
    
    if [ $CHECKS_FAILED -eq 0 ]; then
        if [ $CHECKS_WARNING -eq 0 ]; then
            log_success "Perfect! Your dotfiles setup is healthy! 🎉"
        else
            log_info "Good! Minor warnings that can be improved 👍"
        fi
    else
        log_error "Issues found that need attention 🔧"
        log_info "Check the errors above and follow the suggested fixes"
    fi
    
    echo ""
    log_info "💡 Tips:"
    echo "  • Run this check regularly: chezmoi-health"
    echo "  • Update dotfiles: chezmoi update"
    echo "  • Edit configs: chezmoi edit <file>"
    echo "  • Get help: chezmoi-help"
}

# Main execution
main() {
    echo -e "${CYAN}🏥 Dotfiles Health Check${NC}"
    echo "$(date)"
    echo ""
    
    check_chezmoi
    echo ""
    
    check_essential_tools
    echo ""
    
    check_modern_tools
    echo ""
    
    check_shell_config
    echo ""
    
    check_tmux_config
    echo ""
    
    check_git_config
    echo ""
    
    check_updates
    echo ""
    
    check_platform_features
    echo ""
    
    show_summary
}

# Run main function
main "$@"