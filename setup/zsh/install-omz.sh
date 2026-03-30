#!/usr/bin/env bash
# Sourced by setup.zsh.sh — logging, env, and vars are already available.

OMZ_DIR="$DIR_HOME/.oh-my-zsh"

log_info "Checking Oh My Zsh..."

if [ -d "$OMZ_DIR" ]; then
  log_success "  Oh My Zsh already installed: $OMZ_DIR"
  log_info "  Updating Oh My Zsh..."
  zsh -i -c "omz update --unattended" && log_success "  Oh My Zsh updated" || log_warn "  Oh My Zsh update failed — continuing"
else
  log_warn "  Oh My Zsh not found — installing..."

  if command -v curl &>/dev/null; then
    RUNZSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  elif command -v wget &>/dev/null; then
    RUNZSH=no KEEP_ZSHRC=yes \
      sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    log_error "  Neither curl nor wget found — cannot install Oh My Zsh"
    return 1
  fi

  if [ -d "$OMZ_DIR" ]; then
    log_success "  Oh My Zsh installed: $OMZ_DIR"
  else
    log_error "  Oh My Zsh installation failed — directory not found after install"
    return 1
  fi
fi
