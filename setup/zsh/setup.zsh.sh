#!/usr/bin/env bash
# Sourced by setup.sh — logging, env, vars, and symlink are already available.

DIR_ZSH_SETUP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_info "Setting up zsh..."

source "$DIR_ZSH_SETUP/install-zsh.sh"
source "$DIR_ZSH_SETUP/install-omz.sh"

log_success "Zsh setup complete."
