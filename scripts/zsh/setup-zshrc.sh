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

if is-devbox; then
  log-info "Devbox environment detected"
  dotfiles_zshrc="$HOME/.zshrc-rheaditi"
  ln -sf "$CONFIG_FILE" "$dotfiles_zshrc"
  log-success "Created symlink: $dotfiles_zshrc -> $CONFIG_FILE"

  if [[ -f "$TARGET_FILE" ]] && grep -q "source.*\.zshrc-rheaditi" "$TARGET_FILE" 2>/dev/null; then
    log-already-exists "Dotfiles already configured"
  elif [[ -f "$TARGET_FILE" ]]; then
    log-info "Adding source line to existing .zshrc"
    echo -e "\n# Source dotfiles configuration\nsource ~/.zshrc-rheaditi" >> "$TARGET_FILE"
    log-success "Added dotfiles source to existing .zshrc"
  else
    log-info "No .zshrc found, creating minimal one"
    echo -e "# Minimal zsh configuration - sources dotfiles\nsource ~/.zshrc-rheaditi" > "$TARGET_FILE"
    log-success "Created minimal .zshrc"
  fi
else
  log-info "Local environment detected"
  if [[ -f "$TARGET_FILE" || -L "$TARGET_FILE" ]]; then
    backup-file "$TARGET_FILE" || {
      log-error "Failed to backup existing .zshrc"
      exit 1
    }
  fi
  ln -sf "$CONFIG_FILE" "$TARGET_FILE"
  log-success "Created direct symlink: $TARGET_FILE -> $CONFIG_FILE"
fi

log-success "Zsh configuration setup completed!"
