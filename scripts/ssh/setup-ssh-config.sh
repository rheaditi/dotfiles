#!/usr/bin/env bash

# SSH Configuration Setup Script
# Symlinks the dotfiles configs/ssh/config to ~/.ssh/config

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/logging.sh"
source "$SCRIPT_DIR/../utils/file-operations.sh"

DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_DIR="$DOTFILES_ROOT/configs/ssh"
SSH_CONFIG="$CONFIG_DIR/config"
SSH_DIR="$HOME/.ssh"
SSH_CONFIG_DEST="$SSH_DIR/config"

# Set up SSH config symlink
setup-ssh-config() {
  log-info "Setting up SSH config..."

  # Ensure ~/.ssh directory exists with correct permissions
  if [[ ! -d "$SSH_DIR" ]]; then
    log-info "Creating ~/.ssh directory..."
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    log-success "Created ~/.ssh directory"
  fi

  # Check if symlink already points to the correct target
  if [[ -L "$SSH_CONFIG_DEST" ]] && [[ "$(readlink "$SSH_CONFIG_DEST")" == "$SSH_CONFIG" ]]; then
    log-already-exists "SSH config symlink already set up: $SSH_CONFIG_DEST -> $SSH_CONFIG"
    return 0
  fi

  # Backup existing config if it's a real file (not a symlink)
  if [[ -f "$SSH_CONFIG_DEST" && ! -L "$SSH_CONFIG_DEST" ]]; then
    backup-file "$SSH_CONFIG_DEST"
  fi

  # Create symlink
  ln -sf "$SSH_CONFIG" "$SSH_CONFIG_DEST"
  log-success "Created symlink: $SSH_CONFIG_DEST -> $SSH_CONFIG"
}

# Main execution
setup-ssh-config
