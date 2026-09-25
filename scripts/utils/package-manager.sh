#!/usr/bin/env bash

# Package manager detection and operations utility functions

# Detect the available package manager for the current system
detect-package-manager() {
  if command -v brew &> /dev/null; then
    echo "brew"
  elif command -v apt-get &> /dev/null; then
    echo "apt"
  elif command -v yum &> /dev/null; then
    echo "yum"
  elif command -v pacman &> /dev/null; then
    echo "pacman"
  else
    echo "unknown"
  fi
}

# Install a package using the appropriate package manager
install-package() {
  local package_name="$1"
  local package_manager
  package_manager=$(detect-package-manager)

  case "$package_manager" in
    "brew")
      log-info "Installing $package_name using Homebrew..."
      brew install "$package_name"
      ;;
    "apt")
      log-info "Installing $package_name using apt..."
      sudo apt update
      sudo apt install -y "$package_name"
      ;;
    "yum")
      log-info "Installing $package_name using yum..."
      sudo yum install -y "$package_name"
      ;;
    "pacman")
      log-info "Installing $package_name using pacman..."
      sudo pacman -S --noconfirm "$package_name"
      ;;
    *)
      log-error "Unknown package manager. Cannot install $package_name"
      return 1
      ;;
  esac
}

# Check if a package is installed
is-package-installed() {
  local package_name="$1"
  local package_manager
  package_manager=$(detect-package-manager)

  case "$package_manager" in
    "brew")
      brew list "$package_name" &> /dev/null
      ;;
    "apt")
      dpkg -l | grep -q "^ii.*$package_name"
      ;;
    "yum")
      yum list installed "$package_name" &> /dev/null
      ;;
    "pacman")
      pacman -Q "$package_name" &> /dev/null
      ;;
    *)
      return 1
      ;;
  esac
}

# Update package manager repositories
update-package-manager() {
  local package_manager
  package_manager=$(detect-package-manager)

  case "$package_manager" in
    "brew")
      log-info "Updating Homebrew..."
      brew update
      ;;
    "apt")
      log-info "Updating apt repositories..."
      sudo apt update
      ;;
    "yum")
      log-info "Updating yum repositories..."
      sudo yum update -y
      ;;
    "pacman")
      log-info "Updating pacman repositories..."
      sudo pacman -Sy
      ;;
    *)
      log-warning "Unknown package manager. Skipping repository update."
      ;;
  esac
}
