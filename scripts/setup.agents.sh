#!/usr/bin/env bash

# AGENTS.md setup
# Builds the composed agent-context files and symlinks them into each tool's
# global location. Idempotent and safe to re-run.
#
#   ./scripts/setup.agents.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/utils/logging.sh"
source "$SCRIPT_DIR/utils/file-operations.sh"
source "$SCRIPT_DIR/utils/environment.sh"
# Single source of truth for DIR_DOTFILES_PRIVATE.
source "$DOTFILES_ROOT/common/utils/paths.sh"

BUILD_DIR="$DOTFILES_ROOT/configs/agents/build"

# Rovo Dev config.yml lives in the private dotfiles repo (no secrets, but has
# Atlassian-internal hooks/billing site). Symlinked in if present.
ROVO_PRIVATE_CONFIG="${DIR_DOTFILES_PRIVATE:-}/rovodev/config.yml"

# Link a built target file into its tool's global location.
# Usage: link-agent-file <built-file> <destination>
link-agent-file() {
  local src="$1" dest="$2" dest_dir
  dest_dir="$(dirname "$dest")"

  if [[ ! -f "$src" ]]; then
    log-warning "Built agent file missing, skipping: $src"
    return 0
  fi

  mkdir -p "$dest_dir"

  # Already the correct symlink? Nothing to do.
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    log-info "Already linked: $dest"
    return 0
  fi

  # Back up any real file (or wrong symlink) before linking.
  if [[ -e "$dest" || -L "$dest" ]]; then
    backup-file "$dest"
  fi

  ln -s "$src" "$dest"
  log-success "Linked: $dest -> $src"
}

setup-agents() {
  log-info "Setting up AGENTS.md context..."

  # Always rebuild first (fast, idempotent).
  if ! "$DOTFILES_ROOT/scripts/agents/build-agents.sh"; then
    log-error "Failed to build agent context files"
    return 1
  fi

  # Rovo Dev CLI.
  link-agent-file "$BUILD_DIR/rovo.md" "$HOME/.rovodev/AGENTS.md"

  # Future targets follow the same pattern, e.g.:
  #   link-agent-file "$BUILD_DIR/cursor.md" "$HOME/.cursor/rules/00-shared-agents.mdc"

  # Rovo Dev config.yml from the private repo (skipped if not present).
  # Skipped on devbox/RDE: the committed file has machine-specific absolute
  # paths (/Users/...) that would be wrong there.
  if is-remote-dev-env; then
    log-info "Devbox detected, skipping Rovo config.yml symlink (machine-specific paths)"
  elif [[ -f "$ROVO_PRIVATE_CONFIG" ]]; then
    link-agent-file "$ROVO_PRIVATE_CONFIG" "$HOME/.rovodev/config.yml"
  else
    log-info "Private Rovo config not found, skipping: $ROVO_PRIVATE_CONFIG"
  fi

  log-success "AGENTS.md setup complete"
}

setup-agents
