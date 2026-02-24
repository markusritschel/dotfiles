#!/bin/bash

set -e
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
"$DOTFILES_DIR/.dotbot/bin/dotbot" -c "$DOTFILES_DIR/install.conf.yaml"
