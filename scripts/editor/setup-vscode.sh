#!/usr/bin/env bash

# VS Code Configuration Setup
# Symlinks the dotfiles VS Code settings + keybindings into the VS Code User
# directory. Using symlinks (not copies) means edits made in the VS Code UI
# flow straight back to the repo — no drift, bidirectional, no merge step.

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/logging.sh"
source "$SCRIPT_DIR/../utils/file-operations.sh"
source "$SCRIPT_DIR/../utils/environment.sh"

DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_DIR="$DOTFILES_ROOT/configs/vscode"
SETTINGS_SRC="$CONFIG_DIR/settings.json"
KEYBINDINGS_SRC="$CONFIG_DIR/keybindings.json"

# Resolve the VS Code "User" config directory for this platform/install.
# Echoes the directory path, or nothing if no install is detected.
#
# Detection order (code-server first — it's the strongest "devbox" signal,
# and on a remote dev box the macOS desktop path may also exist but isn't
# the editor actually in use):
#   1. code-server  -> ~/.local/share/code-server/User
#   2. desktop VS Code (Linux) -> ~/.config/Code/User
#   3. desktop VS Code (macOS) -> ~/Library/Application Support/Code/User
vscode-user-dir() {
  local code_server="$HOME/.local/share/code-server/User"
  local linux_desktop="$HOME/.config/Code/User"
  local macos_desktop="$HOME/Library/Application Support/Code/User"

  # 1. code-server (devbox / RDE) — prefer if present or if we're in an RDE.
  if [[ -d "$HOME/.local/share/code-server" ]] || is-remote-dev-env; then
    echo "$code_server"
    return 0
  fi

  # 2. Linux desktop VS Code.
  if [[ -d "$HOME/.config/Code" ]]; then
    echo "$linux_desktop"
    return 0
  fi

  # 3. macOS desktop VS Code (default on a Mac when no other install found).
  if is-macos; then
    echo "$macos_desktop"
    return 0
  fi

  # Nothing detected.
  return 0
}

# Symlink a single source file into the target, backing up any real file first.
link-config() {
  local src="$1" dest="$2" label="$3"

  if [[ ! -f "$src" ]]; then
    log-warning "Source not found, skipping $label: $src"
    return 0
  fi

  # Already correctly linked? No-op.
  if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]; then
    log-already-exists "$label already linked: $dest -> $src"
    return 0
  fi

  # Back up an existing real file (not a symlink) before replacing.
  if [[ -f "$dest" && ! -L "$dest" ]]; then
    backup-file "$dest"
  fi

  ln -sf "$src" "$dest"
  log-success "Linked $label: $dest -> $src"
}

setup-vscode() {
  log-info "Setting up VS Code configuration..."

  local user_dir
  user_dir="$(vscode-user-dir)"

  if [[ -z "$user_dir" ]]; then
    log-warning "No VS Code installation detected - skipping VS Code setup"
    return 0
  fi

  mkdir -p "$user_dir"
  log-info "VS Code User dir: $user_dir"

  link-config "$SETTINGS_SRC" "$user_dir/settings.json" "settings"
  link-config "$KEYBINDINGS_SRC" "$user_dir/keybindings.json" "keybindings"

  log-success "VS Code configuration setup complete"
}

# Main execution
setup-vscode
