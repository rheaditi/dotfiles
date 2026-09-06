#!/usr/bin/env bash

# VS Code Extension Installer
# Installs the extensions listed in configs/vscode/extensions.txt via the
# VS Code CLI (`code`, or `code-server` on a devbox).
#
# This is intentionally SEPARATE from config symlinking (setup-vscode.sh):
# the `code` CLI is provided by the VS Code GUI app and may not exist yet on a
# fresh machine. Run this stage anytime once the CLI is available:
#
#   ./scripts/setup.vscode-extensions.sh
#
# Idempotent: `--force` installs/upgrades without prompting and treats an
# already-installed extension as success.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/logging.sh"

DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
EXTENSIONS_SRC="$DOTFILES_ROOT/configs/vscode/extensions.txt"

# Resolve the VS Code CLI command (desktop `code` or `code-server`).
# Echoes the command name, or nothing if no CLI is found.
vscode-cli() {
  if command -v code >/dev/null 2>&1; then
    echo "code"
  elif command -v code-server >/dev/null 2>&1; then
    echo "code-server"
  fi
  return 0
}

# Install the extensions listed in extensions.txt.
install-vscode-extensions() {
  if [[ ! -f "$EXTENSIONS_SRC" ]]; then
    log-warning "No extensions list found, skipping: $EXTENSIONS_SRC"
    return 0
  fi

  local cli
  cli="$(vscode-cli)"
  if [[ -z "$cli" ]]; then
    log-warning "VS Code CLI (code/code-server) not on PATH - skipping extensions"
    log-info "Install the 'code' command (VS Code: Cmd+Shift+P > 'Shell Command: Install code command in PATH'), then re-run this script."
    return 0
  fi

  log-info "Installing VS Code extensions via '$cli'..."
  local ext
  while IFS= read -r ext || [[ -n "$ext" ]]; do
    # Strip inline comments and surrounding whitespace; skip blanks/comments.
    ext="${ext%%#*}"
    ext="$(echo "$ext" | xargs)"
    [[ -z "$ext" ]] && continue

    if "$cli" --install-extension "$ext" --force >/dev/null 2>&1; then
      log-success "Extension installed: $ext"
    else
      log-warning "Failed to install extension: $ext"
    fi
  done < "$EXTENSIONS_SRC"
}

# Main execution
install-vscode-extensions
