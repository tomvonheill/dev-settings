#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Dev Settings Setup ==="
echo ""

# Prerequisites
echo "Checking prerequisites..."
MISSING=()
command -v brew >/dev/null || MISSING+=("homebrew (https://brew.sh)")
command -v git >/dev/null || MISSING+=("git")

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "Missing: ${MISSING[*]}"
    echo "Install these first, then re-run."
    exit 1
fi

echo "Installing brew packages..."
brew install --quiet zsh-vi-mode nvm gh tmux vim 2>/dev/null || true

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Symlink or copy
link_file() {
    local src="$1" dest="$2"
    if [ -e "$dest" ]; then
        echo "  Backing up existing $dest -> ${dest}.bak"
        mv "$dest" "${dest}.bak"
    fi
    cp "$src" "$dest"
    echo "  Installed $dest"
}

echo ""
echo "Installing config files..."
link_file "$SCRIPT_DIR/shell/zshrc" "$HOME/.zshrc"
link_file "$SCRIPT_DIR/shell/vimrc" "$HOME/.vimrc"
link_file "$SCRIPT_DIR/git/gitconfig" "$HOME/.gitconfig"
link_file "$SCRIPT_DIR/terminal/tmux.conf" "$HOME/.tmux.conf"

# Cursor settings
CURSOR_DIR="$HOME/Library/Application Support/Cursor/User"
if [ -d "$CURSOR_DIR" ]; then
    echo ""
    echo "Installing Cursor settings..."
    link_file "$SCRIPT_DIR/cursor/settings.json" "$CURSOR_DIR/settings.json"
    link_file "$SCRIPT_DIR/cursor/keybindings.json" "$CURSOR_DIR/keybindings.json"

    echo "Installing Cursor extensions..."
    cat "$SCRIPT_DIR/cursor/extensions.txt" | xargs -L 1 cursor --install-extension 2>/dev/null || echo "  (install Cursor first, then re-run)"
else
    echo ""
    echo "Cursor not found — skipping. Install Cursor, then re-run."
fi

# NVM + Node
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    echo ""
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

echo ""
echo "Done! Open a new terminal to apply changes."
