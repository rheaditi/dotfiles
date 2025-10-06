#!/usr/bin/env bash

# Main Zsh Shell Setup Script
# Orchestrates zsh installation, Oh My Zsh setup, and prompt configuration

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source utility functions
source "$SCRIPT_DIR/utils/logging.sh"

# Execute zsh shell setup
log-step "Starting zsh shell setup..."

# Step 1: Install zsh shell
log-info "Running zsh installation..."
"$SCRIPT_DIR/zsh/install-zsh.sh" || {
  log-error "Failed to install zsh. Aborting setup."
  exit 1
}

# Step 2: Install Oh My Zsh framework and plugins
log-info "Running Oh My Zsh setup..."
"$SCRIPT_DIR/zsh/install-oh-my-zsh.sh" || {
  log-error "Failed to set up Oh My Zsh. Aborting setup."
  exit 1
}

# Step 3: Install prompt themes
log-info "Running prompts setup..."
"$SCRIPT_DIR/zsh/install-prompts.sh" || {
  log-error "Failed to set up prompts. Aborting setup."
  exit 1
}

log-success "Zsh shell setup completed successfully!"
log-info "Installed components:"
log-info "  ✅ zsh shell"
log-info "  ✅ Oh My Zsh framework"
log-info "  ✅ zsh-syntax-highlighting plugin"
log-info "Next steps will include:"
log-info "  - Setting zsh as default shell"
log-info "  - Creating configuration symlinks"
