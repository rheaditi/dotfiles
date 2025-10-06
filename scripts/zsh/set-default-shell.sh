#!/usr/bin/env bash

# Set Zsh as Default Shell
# Simple environment-aware shell changing

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source utility functions
source "$SCRIPT_DIR/../utils/logging.sh"
source "$SCRIPT_DIR/../utils/interactive.sh"

# Execute default shell setup
log-step "Setting up default shell..."

# Check if in devbox environment
if [[ "$REMOTE_DEV_ENV" == "true" ]]; then
  log-info "Devbox environment - skipping shell change"
  exit 0
fi

# Get current and target shells
current_shell="$SHELL"
zsh_path=$(which zsh 2>/dev/null)

if [[ -z "$zsh_path" ]]; then
  log-error "zsh not found in PATH"
  exit 1
fi

# Check if already using zsh
if [[ "$current_shell" == "$zsh_path" ]]; then
  log-already-exists "Default shell is already zsh"
  exit 0
fi

# Add zsh to /etc/shells if needed
if ! grep -q "^$zsh_path$" /etc/shells 2>/dev/null; then
  log-info "Adding zsh to /etc/shells..."
  echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null || {
    log-error "Failed to add zsh to /etc/shells"
    exit 1
  }
fi

if is-interactive; then
  if ask-with-timeout "Change default shell to zsh?"; then
    chsh -s "$zsh_path" && log-success "Default shell changed to zsh"
  fi
else
  log-warning "Non-interactive environment"
  log-info "To change default shell manually: chsh -s $zsh_path"
fi
