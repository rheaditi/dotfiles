#!/usr/bin/env bash
# Sourced by setup.zsh.sh — logging, env, and vars are already available.

_install_zsh() {
  if ! detect_package_manager; then
    log_error "No supported package manager found (brew / apt / dnf / yum)"
    return 1
  fi

  log_info "  Installing zsh via $PACKAGE_MANAGER..."

  case "$PACKAGE_MANAGER" in
    brew)    brew install zsh ;;
    apt)     sudo apt-get install -y zsh ;;
    dnf)     sudo dnf install -y zsh ;;
    yum)     sudo yum install -y zsh ;;
  esac
}

log_info "Checking zsh..."

if command -v zsh &>/dev/null; then
  log_success "  zsh already installed: $(command -v zsh) ($(zsh --version))"
else
  log_warn "  zsh not found — installing..."
  if _install_zsh; then
    if command -v zsh &>/dev/null; then
      log_success "  zsh installed: $(command -v zsh) ($(zsh --version))"
    else
      log_error "  zsh installation failed — not found after install"
      return 1
    fi
  else
    return 1
  fi
fi
