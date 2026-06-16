#!/usr/bin/env bash

# SSH Setup Orchestrator Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/logging.sh"

log-info "Starting SSH setup..."

log-info "Step 1: Setting up SSH config..."
if "$SCRIPT_DIR/ssh/setup-ssh-config.sh"; then
  log-success "✓ SSH config setup completed"
else
  log-error "✗ SSH config setup failed"
  return 1
fi

log-success "SSH setup completed successfully!"
log-info "Next steps:"
log-info "  - Verify SSH config: cat ~/.ssh/config"
