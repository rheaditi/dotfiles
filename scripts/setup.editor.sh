#!/usr/bin/env bash

# Editor Setup Orchestrator
# Sets up both VS Code and Cursor with shared configuration

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/logging.sh"

log-info "Starting editor setup..."

# Setup VS Code
log-info "Setting up VS Code..."
if "$SCRIPT_DIR/editor/vscode/setup-vscode.sh"; then
  log-success "VS Code setup completed successfully"
else
  log-error "VS Code setup failed"
  return 1
fi

# Setup Cursor
log-info "Setting up Cursor..."
if "$SCRIPT_DIR/editor/cursor/setup-cursor.sh"; then
  log-success "Cursor setup completed successfully"
else
  log-error "Cursor setup failed"
  return 1
fi

log-success "Editor setup complete"
