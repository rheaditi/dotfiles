#!/usr/bin/env bash

# Node.js installer: nvm + latest LTS node + yarn (via corepack).
# Idempotent: detects existing installs and skips them.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/logging.sh"

NVM_VERSION="v0.40.3"
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

# Install nvm if missing, then load it into the current shell.
install-nvm() {
  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    log-already-exists "nvm already installed"
  else
    log-info "Installing nvm ($NVM_VERSION)..."
    /bin/bash -c "$(curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh")" || return 1
    log-success "nvm installed"
  fi

  # Load nvm into the current shell so subsequent commands work.
  # shellcheck disable=SC1091
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
}

# Install the latest LTS Node.js and set it as default.
# Idempotent: if the locally-installed LTS already matches the latest LTS,
# this is a no-op. (Re-running after a new LTS ships will upgrade, by design.)
install-node() {
  if ! command -v nvm &> /dev/null; then
    log-error "nvm is not loaded; cannot install Node.js"
    return 1
  fi

  # Compare the latest available LTS against what's already installed locally
  # to avoid redundant work. `nvm version-remote` / `nvm version` print the
  # resolved version strings (e.g. v20.17.0) or "N/A" if none.
  local latest_lts installed_lts
  latest_lts="$(nvm version-remote --lts 2>/dev/null)"
  installed_lts="$(nvm version 'lts/*' 2>/dev/null)"

  if [[ -n "$latest_lts" && "$latest_lts" != "N/A" && "$installed_lts" == "$latest_lts" ]]; then
    log-already-exists "Latest LTS Node.js already installed: $installed_lts"
  else
    log-info "Installing latest LTS Node.js..."
    nvm install --lts || return 1
  fi

  nvm alias default 'lts/*' &> /dev/null || true
  log-success "Node.js ready: $(node --version 2>/dev/null)"
}

# Enable corepack so it manages yarn/pnpm (incl. per-project versions pinned
# via package.json "packageManager"). corepack ships with modern Node.js.
#
# `corepack enable` is idempotent, so we run it unconditionally — this ensures
# corepack-managed shims are active even if a global yarn already exists.
install-yarn() {
  if ! command -v corepack &> /dev/null; then
    log-warning "corepack not found (Node.js too old?); skipping yarn setup"
    return 0
  fi

  log-info "Enabling corepack (yarn/pnpm)..."
  corepack enable || return 1
  log-success "corepack enabled; yarn available: $(yarn --version 2>/dev/null || echo 'resolves per-project')"
}

main() {
  install-nvm || return 1
  install-node || return 1
  install-yarn || return 1
}

main "$@"
