#!/usr/bin/env bash

# Zsh Prompts Installation
# Handles installation and configuration of zsh prompt themes

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source utility functions
source "$SCRIPT_DIR/../utils/logging.sh"
source "$SCRIPT_DIR/../utils/package-manager.sh"

# Install or update Pure prompt
install-pure-prompt() {
  log-step "Setting up Pure prompt..."

  local pure_dir="$HOME/.zsh/pure"

  if [ -d "$pure_dir" ]; then
    log-info "Pure prompt already installed, updating..."
    (cd "$pure_dir" && git pull) || log-warning "Could not update Pure prompt"
  else
    log-info "Installing Pure prompt..."
    mkdir -p "$HOME/.zsh"
    git clone https://github.com/sindresorhus/pure.git "$pure_dir" || {
      log-error "Failed to install Pure prompt"
      return 1
    }
    log-success "Pure prompt installed successfully"
  fi
}

# Execute prompts setup
log-step "Installing zsh prompts..."

# Install Pure prompt
if ! install-pure-prompt; then
  log-error "Failed to install Pure prompt"
  exit 1
fi

log-success "Zsh prompts installation completed!"
log-info "Installed prompts:"
log-info "  ✅ Pure prompt (available at ~/.zsh/pure)"
log-info "Note: Prompts are installed but not activated yet"
