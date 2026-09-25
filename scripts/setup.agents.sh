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

# Rovo runtime configuration lives in the private dotfiles repo. config.yml and
# mcp.json can contain local absolute paths, while the prompt registry and its
# content directory are portable and can also be linked on devbox.
ROVO_PRIVATE_CONFIG="${DIR_DOTFILES_PRIVATE:-}/rovo/config.yml"
ROVO_PRIVATE_MCP="${DIR_DOTFILES_PRIVATE:-}/rovo/mcp.json"
ROVO_PRIVATE_PROMPTS="${DIR_DOTFILES_PRIVATE:-}/rovo/prompts.yml"
ROVO_PRIVATE_PROMPT_DIR="${DIR_DOTFILES_PRIVATE:-}/rovo/prompts"

# Rovo CLI runtime home.
ROVO_HOME="$HOME/.rovo"

# Link a file or directory into a tool's global location.
# Usage: link-agent-path <source> <destination>
link-agent-path() {
  local src="$1" dest="$2" dest_dir
  dest_dir="$(dirname "$dest")"

  if [[ ! -e "$src" ]]; then
    log-warning "Agent source missing, skipping: $src"
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

  # Rovo CLI runtime home.
  link-agent-path "$BUILD_DIR/rovo.md" "$ROVO_HOME/AGENTS.md"

  # Saved prompts are portable: the registry uses paths relative to ~/.rovo and
  # its Markdown bodies are linked as a directory beside it.
  if [[ -f "$ROVO_PRIVATE_PROMPTS" ]]; then
    link-agent-path "$ROVO_PRIVATE_PROMPTS" "$ROVO_HOME/prompts.yml"
  else
    log-info "Private Rovo prompts registry not found, skipping: $ROVO_PRIVATE_PROMPTS"
  fi

  if [[ -d "$ROVO_PRIVATE_PROMPT_DIR" ]]; then
    link-agent-path "$ROVO_PRIVATE_PROMPT_DIR" "$ROVO_HOME/prompts"
  else
    log-info "Private Rovo prompts directory not found, skipping: $ROVO_PRIVATE_PROMPT_DIR"
  fi

  # config.yml + mcp.json come from the private repo and are skipped on
  # devbox/RDE: the committed files have machine-specific absolute paths
  # (/Users/...) that would be wrong there.
  if is-remote-dev-env; then
    log-info "Devbox detected, skipping Rovo config.yml/mcp.json symlinks (machine-specific paths)"
    return 0
  fi

  if [[ -f "$ROVO_PRIVATE_CONFIG" ]]; then
    link-agent-path "$ROVO_PRIVATE_CONFIG" "$ROVO_HOME/config.yml"
  else
    log-info "Private Rovo config not found, skipping: $ROVO_PRIVATE_CONFIG"
  fi

  if [[ -f "$ROVO_PRIVATE_MCP" ]]; then
    link-agent-path "$ROVO_PRIVATE_MCP" "$ROVO_HOME/mcp.json"
  else
    log-info "Private Rovo mcp.json not found, skipping: $ROVO_PRIVATE_MCP"
  fi

  # Future targets follow the same pattern, e.g.:
  #   link-agent-file "$BUILD_DIR/cursor.md" "$HOME/.cursor/rules/00-shared-agents.mdc"

  log-success "AGENTS.md setup complete"
}

setup-agents
