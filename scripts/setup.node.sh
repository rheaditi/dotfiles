#!/usr/bin/env bash

# Node.js Setup Orchestrator (Tier 2 / bootstrap)
# Installs nvm, Node.js (LTS), and yarn. Idempotent.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/logging.sh"
source "$SCRIPT_DIR/utils/interactive.sh"

main() {
  log-step "Setting up Node.js..."

  if confirm-step "Node.js" "Install Node.js (nvm + LTS) and yarn?"; then
    if "$SCRIPT_DIR/node/install-node.sh"; then
      log-success "Node.js setup complete"
    else
      log-error "Node.js setup failed"
      return 1
    fi
  fi
}

main "$@"
