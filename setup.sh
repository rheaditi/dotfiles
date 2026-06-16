#!/usr/bin/env bash

# Main Dotfiles Setup Script
# Entry point for setting up the development environment

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source logging utilities
source "$SCRIPT_DIR/scripts/utils/logging.sh"

log-step "Starting dotfiles setup..."
log-info "Environment: ${REMOTE_DEV_ENV:-local}"

# Set up shell environment (zsh, oh-my-zsh, plugins, etc.)
log-step "Setting up shell environment..."
if "$SCRIPT_DIR/scripts/setup.zsh.sh"; then
  log-success "Shell setup completed successfully"
else
  log-error "Shell setup failed"
  exit 1
fi

# Set up git configuration
log-step "Setting up git configuration..."
if "$SCRIPT_DIR/scripts/setup.git.sh"; then
  log-success "Git setup completed successfully"
else
  log-error "Git setup failed"
  exit 1
fi

# Set up SSH configuration
log-step "Setting up SSH configuration..."
if "$SCRIPT_DIR/scripts/setup.ssh.sh"; then
  log-success "SSH setup completed successfully"
else
  log-error "SSH setup failed"
  exit 1
fi

# Set up editor configuration (VS Code)
log-step "Setting up editor configuration..."
if "$SCRIPT_DIR/scripts/setup.editor.sh"; then
  log-success "Editor setup completed successfully"
else
  log-error "Editor setup failed"
  exit 1
fi

# Set up terminal configuration (Ghostty + cmux)
log-step "Setting up terminal configuration..."
if "$SCRIPT_DIR/scripts/setup.terminal.sh"; then
  log-success "Terminal setup completed successfully"
else
  log-error "Terminal setup failed"
  exit 1
fi

# Set up AGENTS.md context (build + symlink into agent tools)
log-step "Setting up AGENTS.md context..."
if "$SCRIPT_DIR/scripts/setup.agents.sh"; then
  log-success "AGENTS.md setup completed successfully"
else
  log-error "AGENTS.md setup failed"
  exit 1
fi

log-success "Dotfiles setup completed!"
log-info "Next steps:"
log-info "  - Reload your shell configuration: source ~/.zshrc"
log-info "  - Verify zsh is working: zsh --version"
log-info "  - Verify git configuration: git --no-pager config --list --show-origin"
log-info "  - Verify SSH config: cat ~/.ssh/config"
log-info "  - Verify VS Code settings: ls -la \"\$HOME/Library/Application Support/Code/User/settings.json\""
log-info "  - Verify terminal config: ls -la ~/.config/ghostty/config ~/.config/cmux/cmux.json"
log-info "  - Reload cmux config: Cmd+Shift+,"
log-info "  - Verify Rovo AGENTS.md: ls -la ~/.rovodev/AGENTS.md"

# TODO: Future setup components will be added here:
# - macOS-specific settings (when not in devbox)
