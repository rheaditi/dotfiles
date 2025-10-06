#!/usr/bin/env bash

# Zsh Shell Setup Script
# Handles detection, installation, and configuration of zsh shell

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source utility functions
source "$SCRIPT_DIR/utils/logging.sh"
source "$SCRIPT_DIR/utils/package-manager.sh"

# Detect if zsh is available on the system
detect-zsh() {
  log-step "Detecting zsh availability..."

  if command -v zsh &> /dev/null; then
    local zsh_version
    zsh_version=$(zsh --version | cut -d' ' -f2)
    log-already-exists "zsh is already installed (version: $zsh_version)"
    log-info "zsh location: $(which zsh)"
    return 0
  else
    log-info "zsh is not installed on this system"
    return 1
  fi
}

# Install zsh using the appropriate package manager
install-zsh() {
  log-step "Installing zsh shell..."

  # Check if zsh is already installed
  if detect-zsh; then
    return 0
  fi

  # Determine the package name based on the system
  local package_name="zsh"
  local package_manager
  package_manager=$(detect-package-manager)

  case "$package_manager" in
    "brew")
      log-info "Installing zsh using Homebrew..."
      if brew install zsh; then
        log-success "zsh installed successfully via Homebrew"
      else
        log-error "Failed to install zsh via Homebrew"
        return 1
      fi
      ;;
    "apt")
      log-info "Installing zsh using apt..."
      if sudo apt update && sudo apt install -y zsh; then
        log-success "zsh installed successfully via apt"
      else
        log-error "Failed to install zsh via apt"
        return 1
      fi
      ;;
    "yum")
      log-info "Installing zsh using yum..."
      if sudo yum install -y zsh; then
        log-success "zsh installed successfully via yum"
      else
        log-error "Failed to install zsh via yum"
        return 1
      fi
      ;;
    *)
      log-error "Unsupported package manager: $package_manager"
      log-error "Please install zsh manually and run this script again"
      return 1
      ;;
  esac

  # Verify installation
  if detect-zsh; then
    log-success "zsh installation verified"
    return 0
  else
    log-error "zsh installation failed - command not found after installation"
    return 1
  fi
}

# Install or update Oh My Zsh framework
install-oh-my-zsh() {
  log-step "Setting up Oh My Zsh framework..."

  if [ -d "$HOME/.oh-my-zsh" ]; then
    log-info "Oh My Zsh already installed, attempting update..."
    if command -v omz &> /dev/null && omz update; then
      log-success "Oh My Zsh updated successfully"
    else
      log-warning "Could not update Oh My Zsh automatically. Run 'omz update' manually."
    fi
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

# Main function to set up zsh shell
setup-zsh-shell() {
  log-step "Starting zsh shell setup..."

  # Step 1: Detect or install zsh
  if ! detect-zsh; then
    if ! install-zsh; then
      log-error "Failed to install zsh. Aborting setup."
      return 1
    fi
  fi

  # Step 2: Install Oh My Zsh framework
  if ! install-oh-my-zsh; then
    log-error "Failed to install Oh My Zsh. Aborting setup."
    return 1
  fi

  # Step 3: Install zsh plugins
  if ! install-zsh-plugins; then
    log-error "Failed to install zsh plugins. Aborting setup."
    return 1
  fi

  log-success "Zsh shell setup completed successfully!"
  log-info "Installed components:"
  log-info "  ✅ zsh shell"
  log-info "  ✅ Oh My Zsh framework"
  log-info "  ✅ zsh-syntax-highlighting plugin"
  log-info "Next steps will include:"
  log-info "  - Installing Pure prompt theme"
  log-info "  - Setting zsh as default shell"
  log-info "  - Creating configuration symlinks"

  return 0
}

# Run the setup if this script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup-zsh-shell "$@"
fi
