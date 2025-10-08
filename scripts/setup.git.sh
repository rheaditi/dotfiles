#!/usr/bin/env bash

# Git Setup Orchestrator Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/logging.sh"

log-info "Starting git setup..."

log-info "Step 1: Setting up git configuration..."
if "$SCRIPT_DIR/git/setup-git-config.sh"; then
  log-success "✓ Git configuration setup completed"
else
  log-error "✗ Git configuration setup failed"
  return 1
fi

log-success "Git setup completed successfully!"
log-info "Next steps:"
log-info "  - Run 'git --no-pager config --list --show-origin' to verify configuration"
log-info "  - User-specific configurations will be added in future setup steps"
