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
source "$SCRIPT_DIR/utils/paths.sh"

BUILD_DIR="$DOTFILES_ROOT/configs/agents/build"

# Rovo config.yml and mcp.json live in the private dotfiles repo (no secrets,
# but have Atlassian-internal hooks/billing site + MCP servers). The source
# folder is still named rovodev/. Symlinked in if present.
ROVO_PRIVATE_CONFIG="${DIR_DOTFILES_PRIVATE:-}/rovodev/config.yml"
ROVO_PRIVATE_MCP="${DIR_DOTFILES_PRIVATE:-}/rovodev/mcp.json"

# Rovo state dirs to link into. We're mid-migration from the old "rovodev" CLI
# to the new "rovo" CLI, and running both in parallel while rovo stabilizes, so
# the same source files are linked into both. Drop "$HOME/.rovodev" from this
# list once rovo is the sole daily driver.
ROVO_HOMES=("$HOME/.rovo" "$HOME/.rovodev")

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

  # Rovo CLI (linked into every dir in ROVO_HOMES — see note above).
  #
  # config.yml + mcp.json come from the private repo and are skipped on
  # devbox/RDE: the committed files have machine-specific absolute paths
  # (/Users/...) that would be wrong there.
  local skip_private=false
  if is-remote-dev-env; then
    log-info "Devbox detected, skipping Rovo config.yml/mcp.json symlinks (machine-specific paths)"
    skip_private=true
  fi

  local rovo_home
  for rovo_home in "${ROVO_HOMES[@]}"; do
    link-agent-file "$BUILD_DIR/rovo.md" "$rovo_home/AGENTS.md"

    [[ "$skip_private" == true ]] && continue

    if [[ -f "$ROVO_PRIVATE_CONFIG" ]]; then
      link-agent-file "$ROVO_PRIVATE_CONFIG" "$rovo_home/config.yml"
    else
      log-info "Private Rovo config not found, skipping: $ROVO_PRIVATE_CONFIG"
    fi

    if [[ -f "$ROVO_PRIVATE_MCP" ]]; then
      link-agent-file "$ROVO_PRIVATE_MCP" "$rovo_home/mcp.json"
    else
      log-info "Private Rovo mcp.json not found, skipping: $ROVO_PRIVATE_MCP"
    fi
  done

  # Future targets follow the same pattern, e.g.:
  #   link-agent-file "$BUILD_DIR/cursor.md" "$HOME/.cursor/rules/00-shared-agents.mdc"

  log-success "AGENTS.md setup complete"
}

setup-agents
