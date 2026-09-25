#!/usr/bin/env bash

# Terminal Setup Orchestrator
# Sets up terminal configuration (Ghostty config + cmux app settings).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/logging.sh"

log-info "Starting terminal setup..."

if "$SCRIPT_DIR/terminal/setup-terminal-config.sh"; then
  log-success "Terminal setup completed successfully"
else
  log-error "Terminal setup failed"
  return 1
fi
