#!/usr/bin/env bash

# Zsh Configuration Setup
# Handles zshrc configuration based on environment (devbox vs others)

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source utility functions
source "$SCRIPT_DIR/../utils/logging.sh"
source "$SCRIPT_DIR/../utils/file-operations.sh"
source "$DOTFILES_ROOT/common/utils/platform-detection.sh"

# Execute zshrc setup
log-step "Setting up zsh configuration..."

# Path to our config file and target location
CONFIG_FILE="$DOTFILES_ROOT/configs/zsh/dotzshrc"
TARGET_FILE="$HOME/.zshrc"

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
  log-error "Config file not found: $CONFIG_FILE"
  exit 1
fi

if is-devbox; then
  # Devbox environment - symlink to ~/.zshrc-rheaditi and source from ~/.zshrc
  log-info "Devbox environment detected"

  dotfiles_zshrc="$HOME/.zshrc-rheaditi"

  # Create symlink to our config
  ln -sf "$CONFIG_FILE" "$dotfiles_zshrc"
  log-success "Created symlink: $dotfiles_zshrc -> $CONFIG_FILE"

  # Add source line to existing ~/.zshrc if it doesn't exist
  if [[ -f "$TARGET_FILE" ]]; then
    if grep -q "source.*\.zshrc-rheaditi" "$TARGET_FILE" 2>/dev/null; then
      log-already-exists "Dotfiles zshrc already sourced in existing .zshrc"
    else
      log-info "Adding source line to existing .zshrc"
      echo "" >> "$TARGET_FILE"
      echo "# Source dotfiles configuration" >> "$TARGET_FILE"
      echo "source ~/.zshrc-rheaditi" >> "$TARGET_FILE"
      log-success "Added dotfiles source to existing .zshrc"
    fi
  else
    log-info "No existing .zshrc found, creating one with source line"
    echo "# Source dotfiles configuration" > "$TARGET_FILE"
    echo "source ~/.zshrc-rheaditi" >> "$TARGET_FILE"
    log-success "Created .zshrc with dotfiles source"
  fi
else
  # Local environment - backup existing ~/.zshrc and symlink our config
  log-info "Local environment detected"

  # Backup existing zshrc if it exists
  if [[ -f "$TARGET_FILE" || -L "$TARGET_FILE" ]]; then
    backup-file "$TARGET_FILE" || {
      log-error "Failed to backup existing .zshrc"
      exit 1
    }
  fi

  # Create symlink
  ln -sf "$CONFIG_FILE" "$TARGET_FILE"
  log-success "Created symlink: $TARGET_FILE -> $CONFIG_FILE"
fi

log-success "Zsh configuration setup completed!"
log-info "Configuration file: $CONFIG_FILE"
log-info "Active configuration: $TARGET_FILE"
