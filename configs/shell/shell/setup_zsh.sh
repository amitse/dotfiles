#!/bin/bash
# Script to handle zsh configuration
# This script appends to existing .zshrc if it exists, or creates a new one

ZSHRC_FILE="$HOME/.zshrc"
MANAGED_MARKER="# === CHEZMOI MANAGED SECTION ==="
MANAGED_END="# === END CHEZMOI MANAGED SECTION ==="

# Function to add our configuration to existing .zshrc
append_to_zshrc() {
    echo "Appending chezmoi configuration to existing .zshrc..."
    
    # Check if our section already exists
    if grep -q "$MANAGED_MARKER" "$ZSHRC_FILE"; then
        echo "Chezmoi section already exists in .zshrc"
        return 0
    fi
    
    # Backup existing .zshrc
    cp "$ZSHRC_FILE" "$ZSHRC_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backed up existing .zshrc"
    
    # Append our configuration
    cat >> "$ZSHRC_FILE" << 'EOF'

# === CHEZMOI MANAGED SECTION ===
# This section is managed by chezmoi dotfiles
# Source the main chezmoi-managed zsh configuration

if [ -f ~/.config/shell/zshrc_managed ]; then
    source ~/.config/shell/zshrc_managed
fi

# Source chezmoi-managed aliases
if [ -f ~/.zsh_aliases ]; then
    source ~/.zsh_aliases
fi
# === END CHEZMOI MANAGED SECTION ===
EOF
    
    echo "Added chezmoi configuration to existing .zshrc"
}

# Main logic
if [ -f "$ZSHRC_FILE" ]; then
    # .zshrc exists, append our configuration
    append_to_zshrc
else
    # No .zshrc exists, we can create it normally
    echo "No existing .zshrc found, chezmoi will create it"
fi