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

  log-success "Zsh shell setup (detection/installation) completed successfully!"
  log-info "Next steps will include:"
  log-info "  - Installing Oh My Zsh framework"
  log-info "  - Installing zsh plugins"
  log-info "  - Installing Pure prompt theme"
  log-info "  - Setting zsh as default shell"
  log-info "  - Creating configuration symlinks"

  return 0
}

# Run the setup if this script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup-zsh-shell "$@"
fi
