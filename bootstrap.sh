#!/usr/bin/env bash

# Bootstrap Script (Tier 2) - Full machine provisioning
# ============================================================================
# This is the "spilled coffee" entrypoint: run it once on a fresh machine and
# be fully operational. It INSTALLS tooling (Homebrew, Node.js, packages) and
# then runs the quick `setup.sh` to symlink all configuration.
#
# For just (re)applying config without installing anything, run ./setup.sh.
#
# Cross-platform: the OS is detected up front (via $OSTYPE in
# scripts/utils/environment.sh). macOS-only steps (Homebrew) are skipped on
# other systems (e.g. a Linux remote-dev box); cross-platform steps (Node.js,
# config) still run everywhere.
#
# Behavior:
#   - Interactive session: confirms each install step (y/N).
#   - Non-interactive (NONINTERACTIVE=1 or no TTY): auto-proceeds with all steps.
#
# Usage:
#   ./bootstrap.sh
#   NONINTERACTIVE=1 ./bootstrap.sh   # install everything, no prompts
# ============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/utils/logging.sh"
source "$SCRIPT_DIR/scripts/utils/environment.sh"

# Detect OS up front so we can gate platform-specific steps explicitly.
if is-macos; then
  OS_LABEL="macOS"
elif is-linux; then
  OS_LABEL="Linux"
else
  OS_LABEL="$OSTYPE (unsupported - cross-platform steps only)"
fi

log-step "Starting full bootstrap..."
log-info "OS detected: $OS_LABEL${REMOTE_DEV_ENV:+ (remote-dev)}"
if is-interactive; then
  log-info "Interactive session: you'll be asked to confirm each install step."
else
  log-info "Non-interactive session: all install steps will auto-proceed."
fi

# --- Installation steps (Tier 2) --------------------------------------------

# Homebrew + packages (macOS only).
if is-macos; then
  log-step "Homebrew..."
  if ! "$SCRIPT_DIR/scripts/setup.brew.sh"; then
    log-error "Homebrew setup failed"
    exit 1
  fi
else
  log-info "Skipping Homebrew (macOS-only)"
fi

# Node.js (nvm + LTS + yarn) - cross-platform.
log-step "Node.js..."
if ! "$SCRIPT_DIR/scripts/setup.node.sh"; then
  log-error "Node.js setup failed"
  exit 1
fi

# --- Configuration (Tier 1) -------------------------------------------------
# Delegate all symlink/config work to the quick setup so bootstrap is a
# strict superset of `setup.sh` (DRY).
log-step "Applying configuration (delegating to setup.sh)..."
if ! "$SCRIPT_DIR/setup.sh"; then
  log-error "Configuration setup failed"
  exit 1
fi

log-success "Bootstrap completed! 🎉"
log-info "Next steps:"
log-info "  - Reload your shell: source ~/.zshrc"
log-info "  - Install the Fira Code font: https://github.com/tonsky/FiraCode/releases"
