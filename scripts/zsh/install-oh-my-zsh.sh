#!/usr/bin/env bash

# Oh My Zsh Framework and Plugins Installation
# Handles Oh My Zsh installation, updates, and plugin management

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source utility functions
source "$SCRIPT_DIR/../utils/logging.sh"

# Install or update Oh My Zsh framework
install-oh-my-zsh() {
  log-step "Setting up Oh My Zsh framework..."

  if [ -d "$HOME/.oh-my-zsh" ]; then
    log-info "Oh My Zsh already installed, updating..."
    (cd "$HOME/.oh-my-zsh" && git pull) || log-warning "Could not update Oh My Zsh automatically"
  else
    log-info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || {
      log-error "Failed to install Oh My Zsh"
      return 1
    }
    log-success "Oh My Zsh installed successfully"
  fi
}

# Install or update zsh plugins
install-zsh-plugins() {
  log-step "Setting up zsh plugins..."

  local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

  if [ -d "$plugin_dir" ]; then
    log-info "Updating zsh-syntax-highlighting plugin..."
    (cd "$plugin_dir" && git pull) || log-warning "Could not update zsh-syntax-highlighting plugin"
  else
    log-info "Installing zsh-syntax-highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugin_dir" || {
      log-error "Failed to install zsh-syntax-highlighting plugin"
      return 1
    }
  fi

  log-success "oh-my-zsh plugins setup completed"
}

# Execute Oh My Zsh setup
if ! install-oh-my-zsh; then
  log-error "Failed to set up Oh My Zsh framework"
  exit 1
fi

if ! install-zsh-plugins; then
  log-error "Failed to set up zsh plugins"
  exit 1
fi
