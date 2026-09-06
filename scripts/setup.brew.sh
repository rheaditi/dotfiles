#!/usr/bin/env bash

# Homebrew Setup Script (Tier 2 / bootstrap)
# Installs Homebrew (if missing) and packages from the Brewfile.
# macOS only. Idempotent: safe to re-run.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/logging.sh"
source "$SCRIPT_DIR/utils/environment.sh"
source "$SCRIPT_DIR/utils/interactive.sh"

BREWFILE="$SCRIPT_DIR/brew/Brewfile"

# Install Homebrew itself if it isn't present.
# Idempotent: if brew already exists this is a no-op (no network calls).
install-homebrew() {
  if command -v brew &> /dev/null; then
    log-already-exists "Homebrew already installed"
    return 0
  fi

  log-info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || return 1
  # Load brew into the current shell (Apple Silicon path)
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  log-success "Homebrew installed"

  # Only update right after a fresh install, so re-runs stay a fast no-op.
  log-info "Updating Homebrew (first install)..."
  brew update
}

# Install all packages declared in the Brewfile.
install-brew-bundle() {
  if [[ ! -f "$BREWFILE" ]]; then
    log-error "Brewfile not found: $BREWFILE"
    return 1
  fi
  log-info "Installing packages from Brewfile..."
  brew bundle --file "$BREWFILE"
}

main() {
  if ! is-macos; then
    log-info "Not macOS - skipping Homebrew setup"
    return 0
  fi

  log-step "Setting up Homebrew..."

  run-if-confirmed "Homebrew" "Install/update Homebrew?" install-homebrew || return 1
  run-if-confirmed "Brew packages" "Install packages from the Brewfile?" install-brew-bundle || return 1

  # Tidy up old versions.
  if command -v brew &> /dev/null; then
    brew cleanup
  fi

  log-success "Homebrew setup complete"
}

main "$@"
