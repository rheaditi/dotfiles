#!/usr/bin/env bash

# Zsh Configuration Setup - Environment-aware zshrc configuration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/../utils/logging.sh"
source "$SCRIPT_DIR/../utils/file-operations.sh"
source "$DOTFILES_ROOT/common/utils/platform-detection.sh"

log-step "Setting up zsh configuration..."

CONFIG_FILE="$DOTFILES_ROOT/configs/zsh/dotzshrc"
TARGET_FILE="$HOME/.zshrc"

[[ ! -f "$CONFIG_FILE" ]] && { log-error "Config file not found: $CONFIG_FILE"; exit 1; }

# Backup existing .zshrc if it exists
if [[ -f "$TARGET_FILE" || -L "$TARGET_FILE" ]]; then
  backup-file "$TARGET_FILE" || {
    log-error "Failed to backup existing .zshrc"
    exit 1
  }
fi

# Create direct symlink to our config
ln -sf "$CONFIG_FILE" "$TARGET_FILE"
log-success "Created direct symlink: $TARGET_FILE -> $CONFIG_FILE"

log-success "Zsh configuration setup completed!"

# Check for old zshrc files that could be cleaned up
old_zshrc_files=$(find "$HOME" -maxdepth 1 -name ".zshrc*" ! -name ".zshrc" 2>/dev/null)
if [[ -n "$old_zshrc_files" ]]; then
  log-info "Old zshrc files found (consider cleanup):"
  echo "$old_zshrc_files" | while read -r file; do
    log-info "  $file"
  done
fi
