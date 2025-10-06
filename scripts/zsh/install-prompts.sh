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

# Install or update Starship prompt
install-starship-prompt() {
  log-step "Setting up Starship prompt..."

  # Ensure ~/local/bin is in PATH for current session
  if [[ ":$PATH:" != *":$HOME/local/bin:"* ]]; then
    log-info "Adding $HOME/local/bin to PATH for current session"
    export PATH="$HOME/local/bin:$PATH"
  fi

  # Check if starship is already installed
  if command -v starship &> /dev/null; then
    log-info "Starship already installed, attempting update..."
    local package_manager
    package_manager=$(detect-package-manager)

    case "$package_manager" in
      "brew")
        brew upgrade starship || log-warning "Could not update Starship via Homebrew"
        ;;
      *)
        log-warning "Starship update not supported for $package_manager. Install manually if needed."
        ;;
    esac
  else
    log-info "Installing Starship prompt..."
    local package_manager
    package_manager=$(detect-package-manager)

    case "$package_manager" in
      "brew")
        brew install starship || {
          log-error "Failed to install Starship via Homebrew"
          return 1
        }
        ;;
       "apt"|"yum")
         # Use official installer for Linux with user directory
         log-info "Installing Starship to user directory..."
         mkdir -p "$HOME/local/bin"
         curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$HOME/local/bin" --yes || {
           log-error "Failed to install Starship via official installer"
           return 1
         }
         ;;
      *)
        log-error "Unsupported package manager for Starship: $package_manager"
        log-info "Please install Starship manually: https://starship.rs/guide/#step-1-install-starship"
        return 1
        ;;
    esac
    log-success "Starship prompt installed successfully"
  fi
}

# Execute prompts setup
log-step "Installing zsh prompts..."

# Install Pure prompt
if ! install-pure-prompt; then
  log-error "Failed to install Pure prompt"
  exit 1
fi

# Install Starship prompt
if ! install-starship-prompt; then
  log-error "Failed to install Starship prompt"
  exit 1
fi

log-success "Zsh prompts installation completed!"
log-info "Installed prompts:"
log-info "  ✅ Pure prompt (available at ~/.zsh/pure)"
log-info "  ✅ Starship prompt (available via 'starship' command)"
log-info "Note: Prompts are installed but not activated yet"
