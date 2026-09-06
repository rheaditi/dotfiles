#!/usr/bin/env bash

# Editor Setup Orchestrator
# Sets up editor configuration (currently VS Code).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/logging.sh"

log-info "Starting editor setup..."

log-info "Setting up VS Code..."
if "$SCRIPT_DIR/editor/setup-vscode.sh"; then
  log-success "VS Code setup completed successfully"
else
  log-error "VS Code setup failed"
  return 1
fi

log-success "Editor setup complete"
