#!/bin/bash

set -e
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
PRIVATE_DIR="$DOTFILES_DIR/private"

# Link public dotfiles
echo "Linking public dotfiles..."
"$DOTFILES_DIR/.dotbot/bin/dotbot" -c "$DOTFILES_DIR/install.conf.yaml" || true

# Link private dotfiles if repo exists
if [ -f "$PRIVATE_DIR/install.conf.yaml" ]; then
    echo "Linking private dotfiles..."
    "$DOTFILES_DIR/.dotbot/bin/dotbot" -c "$PRIVATE_DIR/install.conf.yaml"
else
    echo "No install.conf.yaml for private dotfiles found at $PRIVATE_DIR, skipping."
    echo "Clone your private repo there or set PRIVATE_DIR."
fi

echo "✅ Done."
