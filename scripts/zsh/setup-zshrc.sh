#!/usr/bin/env bash

# Zsh Configuration Setup - Environment-aware zshrc configuration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/../utils/logging.sh"
source "$SCRIPT_DIR/../utils/file-operations.sh"
source "$SCRIPT_DIR/../utils/environment.sh"

log-step "Setting up zsh configuration..."

CONFIG_FILE="$DOTFILES_ROOT/configs/zsh/dotzshrc"
TARGET_FILE="$HOME/.zshrc"

[[ ! -f "$CONFIG_FILE" ]] && { log-error "Config file not found: $CONFIG_FILE"; exit 1; }

# Backup existing .zshrc if it exists
if [[ -f "$TARGET_FILE" || -L "$TARGET_FILE" ]]; then
  # Unset immutable flag in case a previous setup run locked it
  chflags nouchg "$TARGET_FILE" 2>/dev/null || true
  backup-file "$TARGET_FILE" || {
    log-error "Failed to backup existing .zshrc"
    exit 1
  }
fi

# Write a stub that sources the real config by absolute path.
# Using a plain file (not a symlink) so tools that append to ~/.zshrc
# (e.g. nvm, conda) don't break our config — the source line runs first
# regardless of what gets appended below it.
cat > "$TARGET_FILE" <<EOF
# Managed by dotfiles — do not edit this line.
# Additional tool-appended config below this line is fine.
source "$CONFIG_FILE"
EOF
log-success "Created stub: $TARGET_FILE -> source $CONFIG_FILE"

log-success "Zsh configuration setup completed!"

# Check for old zshrc files that could be cleaned up
old_zshrc_files=$(find "$HOME" -maxdepth 1 -name ".zshrc*" ! -name ".zshrc" 2>/dev/null)
if [[ -n "$old_zshrc_files" ]]; then
  log-info "Old zshrc files found (consider cleanup):"
  echo "$old_zshrc_files" | while read -r file; do
    log-info "  $file"
  done
fi
