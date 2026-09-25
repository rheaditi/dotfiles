#!/usr/bin/env bash

# Terminal Configuration Setup Script
# Symlinks the dotfiles terminal configs into place:
#   configs/ghostty/config -> ~/.config/ghostty/config   (theme/font/colors; read by cmux)
#   configs/cmux/cmux.json -> ~/.config/cmux/cmux.json    (cmux app settings)

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/logging.sh"
source "$SCRIPT_DIR/../utils/file-operations.sh"

DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

GHOSTTY_SRC="$DOTFILES_ROOT/configs/ghostty/config"
GHOSTTY_DEST="$HOME/.config/ghostty/config"

CMUX_SRC="$DOTFILES_ROOT/configs/cmux/cmux.json"
CMUX_DEST="$HOME/.config/cmux/cmux.json"

# Symlink a single config file: ensure parent dir, back up real files, link.
# Idempotent: skips if the symlink already points to the source.
link-config() {
  local src="$1" dest="$2" label="$3"
  local dest_dir
  dest_dir="$(dirname "$dest")"

  if [[ ! -f "$src" ]]; then
    log-error "$label source not found: $src"
    return 1
  fi

  # Ensure destination directory exists
  if [[ ! -d "$dest_dir" ]]; then
    log-info "Creating $dest_dir ..."
    mkdir -p "$dest_dir"
  fi

  # Already linked correctly?
  if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]; then
    log-already-exists "$label already linked: $dest -> $src"
    return 0
  fi

  # Back up an existing real file (not a symlink)
  if [[ -f "$dest" && ! -L "$dest" ]]; then
    backup-file "$dest"
  fi

  ln -sf "$src" "$dest"
  log-success "Linked $label: $dest -> $src"
}

setup-terminal-config() {
  log-info "Setting up terminal (Ghostty + cmux) config..."
  link-config "$GHOSTTY_SRC" "$GHOSTTY_DEST" "Ghostty config" || return 1
  link-config "$CMUX_SRC" "$CMUX_DEST" "cmux config" || return 1
}

# Main execution
setup-terminal-config
