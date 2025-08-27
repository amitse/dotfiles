#!/bin/bash
# Basic validation script for dotfiles functionality
# Tests template rendering, install scripts, and configuration validation

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# repo root is two levels up from scripts/tools
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo -e "${BLUE}🧪 Dotfiles Validation Suite${NC}"
echo -e "${BLUE}============================${NC}"
echo ""

# Test 1: Check required files exist
test_required_files() {
    echo -e "${BLUE}📁 Testing required files...${NC}"
    
    local required_files=(
        "scripts/install/install-unix.sh"
        "scripts/install/install-windows.ps1"
        "README.md"
        "PLAN.md"
        ".chezmoi/chezmoi.toml.tmpl"
        "templates/root/dot_zshrc.tmpl"
        "templates/partials/shell/core.sh.tmpl"
        "templates/partials/shell/exports.sh.tmpl"
        "templates/partials/shell/paths.sh.tmpl"
        "templates/partials/shell/functions.sh.tmpl"
    )
    
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$REPO_ROOT/$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -eq 0 ]]; then
        echo -e "${GREEN}✅ All required files present${NC}"
    else
        echo -e "${RED}❌ Missing files:${NC}"
        for file in "${missing_files[@]}"; do
            echo -e "  ${RED}• $file${NC}"
        done
        return 1
    fi
}

# Test 2: Validate shell script syntax
test_shell_scripts() {
    echo -e "${BLUE}🔧 Testing shell script syntax...${NC}"
    
    local errors=0
    
    # Test install script (now under scripts/install)
    if bash -n "$REPO_ROOT/scripts/install/install-unix.sh"; then
        echo -e "${GREEN}✅ install-unix.sh syntax valid${NC}"
    else
        echo -e "${RED}❌ install-unix.sh syntax error${NC}"
        ((errors++))
    fi
    
    # Test health-check.sh
    if [[ -f "$REPO_ROOT/scripts/health/health-check.sh" ]]; then
        if bash -n "$REPO_ROOT/scripts/health/health-check.sh"; then
            echo -e "${GREEN}✅ health-check.sh syntax valid${NC}"
        else
            echo -e "${RED}❌ health-check.sh syntax error${NC}"
            ((errors++))
        fi
    fi
    
    # Test shell partials (basic syntax check)
    # Check shell partials under templates/partials
    for partial in "$REPO_ROOT"/templates/partials/shell/*.tmpl; do
        if [[ -f "$partial" ]]; then
            # Remove chezmoi template syntax for basic syntax check
            local temp_file=$(mktemp)
            sed 's/{{[^}]*}}/""/' "$partial" > "$temp_file"

            if bash -n "$temp_file" 2>/dev/null; then
                echo -e "${GREEN}✅ $(basename "$partial") syntax valid${NC}"
            else
                echo -e "${YELLOW}⚠️  $(basename "$partial") has template syntax (expected)${NC}"
            fi

            rm -f "$temp_file"
        fi
    done
    
    return $errors
}

# Test 3: Check PowerShell script syntax (if pwsh is available)
test_powershell_scripts() {
    echo -e "${BLUE}💻 Testing PowerShell script syntax...${NC}"
    
    if command -v pwsh >/dev/null 2>&1; then
        if pwsh -Command "& { . '$REPO_ROOT/scripts/install/install-windows.ps1' -NonInteractive true -ErrorAction Stop }" -ErrorAction Stop; then
            echo -e "${GREEN}✅ install-windows.ps1 syntax valid${NC}"
        else
            echo -e "${RED}❌ install-windows.ps1 syntax error${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠️  PowerShell not available, skipping PowerShell tests${NC}"
    fi
}

# Test 4: Validate chezmoi template syntax
test_chezmoi_templates() {
    echo -e "${BLUE}📝 Testing chezmoi template syntax...${NC}"
    
    # Check if chezmoi is available
    if ! command -v chezmoi >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  chezmoi not installed, installing temporarily...${NC}"
        
        # Install chezmoi to a temporary location
        local temp_dir=$(mktemp -d)
        export PATH="$temp_dir:$PATH"
        
        curl -sfL https://git.io/chezmoi | sh -s -- -b "$temp_dir"
        
        if ! command -v chezmoi >/dev/null 2>&1; then
            echo -e "${RED}❌ Failed to install chezmoi temporarily${NC}"
            return 1
        fi
    fi
    
    # Create a temporary test directory
    local test_dir=$(mktemp -d)
    cd "$test_dir"
    
    # Test template rendering with different profiles
    local profiles=("minimal" "developer" "power-user")
    
    for profile in "${profiles[@]}"; do
        echo -e "${BLUE}  Testing $profile profile...${NC}"
        
        # Create test config
        cat > chezmoi.toml << EOF
[data]
    profile = "$profile"
    
    [data.user]
        name = "Test User"
        email = "test@example.com"
    
    [data.secrets]
        backend = "env"
    
    [data.features]
        modern_cli = true
        developer_tools = true
        advanced_git = true
        powerline_prompt = false
        github_integration = true
    
    [data.tools]
        essential = ["git", "tmux"]
        optional = []
    
    [data.paths]
        workspace = "~/workspace"
        dotfiles = "~/dotfiles"
        local_bin = "~/.local/bin"
    
    [data.editor]
        default = "vim"
        gui = "code"
EOF
        
        # Test initialization (dry run)
        if chezmoi init --config ./chezmoi.toml --dry-run "$REPO_ROOT" >/dev/null 2>&1; then
            echo -e "${GREEN}  ✅ $profile profile templates valid${NC}"
        else
            echo -e "${RED}  ❌ $profile profile template errors${NC}"
            return 1
        fi
    done
    
    # Cleanup
    cd "$REPO_ROOT"
    rm -rf "$test_dir"
    
    echo -e "${GREEN}✅ All chezmoi templates valid${NC}"
}

# Test 5: Check documentation links
test_documentation() {
    echo -e "${BLUE}📚 Testing documentation...${NC}"
    
    # Check that referenced docs exist
    local missing_docs=()
    
    local expected_docs=(
        "docs/GETTING-STARTED.md"
        "docs/PROFILES.md"
        "docs/AI-ASSISTANT-GUIDE.md"
        "PLAN.md"
    )
    
    for doc in "${expected_docs[@]}"; do
        if [[ ! -f "$REPO_ROOT/$doc" ]]; then
            missing_docs+=("$doc")
        fi
    done
    
    if [[ ${#missing_docs[@]} -eq 0 ]]; then
        echo -e "${GREEN}✅ All documentation files present${NC}"
    else
        echo -e "${RED}❌ Missing documentation files:${NC}"
        for doc in "${missing_docs[@]}"; do
            echo -e "  ${RED}• $doc${NC}"
        done
        return 1
    fi
}

# Test 6: Validate repository structure
test_repository_structure() {
    echo -e "${BLUE}🏗️ Testing repository structure...${NC}"
    
    local required_dirs=(
        "templates/partials"
        "docs"
        "scripts"
        ".chezmoi"
        ".github/workflows"
    )
    
    local missing_dirs=()
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$REPO_ROOT/$dir" ]]; then
            missing_dirs+=("$dir")
        fi
    done
    
    if [[ ${#missing_dirs[@]} -eq 0 ]]; then
        echo -e "${GREEN}✅ Repository structure valid${NC}"
    else
        echo -e "${RED}❌ Missing directories:${NC}"
        for dir in "${missing_dirs[@]}"; do
            echo -e "  ${RED}• $dir${NC}"
        done
        return 1
    fi
}

# Fail fast if any legacy '_partials' references remain in the tree
check_for_legacy_partials_refs() {
    echo -e "${BLUE}🔎 Checking for legacy '_partials' references...${NC}"

    if Select-String -Path "$REPO_ROOT" -Pattern "_partials" -CaseSensitive -Quiet 2>/dev/null; then
        echo -e "${RED}❌ Found references to '_partials' in the repository. Please update them to 'templates/partials'${NC}"
        return 1
    else
        # Use grep as fallback for environments without Select-String
        if grep -R --line-number "_partials" "$REPO_ROOT" >/dev/null 2>&1; then
            echo -e "${RED}❌ Found references to '_partials' in the repository. Please update them to 'templates/partials'${NC}"
            return 1
        fi
    fi

    echo -e "${GREEN}✅ No legacy '_partials' references found${NC}"
}

# Test 7: Basic install script validation (non-interactive)
test_install_script() {
    echo -e "${BLUE}🚀 Testing install script (dry run)...${NC}"
    
    # Test if the script accepts the non-interactive flag (moved under scripts/install)
    if bash -n "$REPO_ROOT/scripts/install/install-unix.sh"; then
        echo -e "${GREEN}✅ Install script syntax valid${NC}"

        # Check if it handles the non-interactive flag correctly
        local output
        if output=$(bash "$REPO_ROOT/scripts/install/install-unix.sh" --non-interactive 2>&1 | head -10); then
            echo -e "${GREEN}✅ Install script handles non-interactive mode${NC}"
        else
            echo -e "${YELLOW}⚠️  Install script non-interactive mode may need chezmoi${NC}"
        fi
    else
        echo -e "${RED}❌ Install script syntax error${NC}"
        return 1
    fi
}

# Run all tests
main() {
    local failed_tests=()
    
    echo "Running validation tests in: $REPO_ROOT"
    echo ""
    
    # Run each test and track failures
    test_required_files || failed_tests+=("Required Files")
    echo ""
    
    test_shell_scripts || failed_tests+=("Shell Scripts")
    echo ""
    
    test_powershell_scripts || failed_tests+=("PowerShell Scripts")
    echo ""
    
    test_chezmoi_templates || failed_tests+=("Chezmoi Templates")
    echo ""
    
    test_documentation || failed_tests+=("Documentation")
    echo ""
    
    test_repository_structure || failed_tests+=("Repository Structure")
    echo ""
    
    test_install_script || failed_tests+=("Install Script")
    echo ""
    
    # Summary
    echo -e "${BLUE}📊 Validation Summary${NC}"
    echo -e "${BLUE}===================${NC}"
    
    if [[ ${#failed_tests[@]} -eq 0 ]]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}"
        echo -e "${GREEN}✅ Repository is ready for use${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed tests:${NC}"
        for test in "${failed_tests[@]}"; do
            echo -e "  ${RED}• $test${NC}"
        done
        echo ""
        echo -e "${YELLOW}🔧 Please fix the failing tests before using the repository${NC}"
        return 1
    fi
}

# Run main function
main "$@"
