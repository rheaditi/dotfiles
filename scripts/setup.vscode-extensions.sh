#!/usr/bin/env bash

# VS Code Extensions Setup (standalone stage)
# Installs extensions from configs/vscode/extensions.txt.
#
# Kept separate from the main setup because the `code` CLI is provided by the
# VS Code GUI app and may not be on PATH on a fresh machine. Run this anytime
# once `code` (or `code-server`) is available:
#
#   ./scripts/setup.vscode-extensions.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/logging.sh"

log-info "Setting up VS Code extensions..."
if "$SCRIPT_DIR/editor/install-vscode-extensions.sh"; then
  log-success "VS Code extensions setup completed"
else
  log-error "VS Code extensions setup failed"
  return 1 2>/dev/null || exit 1
fi
