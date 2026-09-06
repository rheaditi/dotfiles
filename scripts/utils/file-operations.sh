#!/usr/bin/env bash

# File Operations Utility Functions
# Handles common file operations like backup, symlinks, etc.

# Source logging functions.
# Use a util-local var name so we never clobber a caller's $SCRIPT_DIR.
UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$UTILS_DIR/logging.sh"

# Create a backup of a file with timestamp
backup-file() {
  local file_path="$1"

  if [[ -z "$file_path" ]]; then
    log-error "backup-file: No file path provided"
    return 1
  fi

  if [[ ! -f "$file_path" && ! -L "$file_path" ]]; then
    log-info "backup-file: File does not exist, no backup needed: $file_path"
    return 0
  fi

  local timestamp=$(date +%Y%m%d_%H%M%S)
  local backup_path="${file_path}.${timestamp}.bak"

  log-info "Creating backup: $file_path -> $backup_path"

  if mv "$file_path" "$backup_path"; then
    log-success "Backup created: $backup_path"
    return 0
  else
    log-error "Failed to create backup of: $file_path"
    return 1
  fi
}
