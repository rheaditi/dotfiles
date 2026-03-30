#!/usr/bin/env bash
# Symlink utilities. Source this file to use symlink_file.
# Requires logging.sh to be sourced first.

# symlink_file <source> <target>
# Creates a symlink at <target> pointing to <source>.
# - Skips if a valid symlink already exists.
# - Backs up and replaces if a regular file exists at <target>.
# - Fails if <source> does not exist.
symlink_file() {
  local src="$1"
  local target="$2"

  if [ ! -e "$src" ]; then
    log_error "symlink_file: source does not exist: $src"
    return 1
  fi

  if [ -L "$target" ]; then
    if [ "$(readlink "$target")" = "$src" ]; then
      log_info "  Symlink already correct: $target → $src"
      return 0
    else
      log_warn "  Replacing stale symlink: $target"
      rm "$target"
    fi
  elif [ -e "$target" ]; then
    local backup="${target}.bak"
    log_warn "  Backing up existing file: $target → $backup"
    mv "$target" "$backup"
  fi

  ln -s "$src" "$target"
  log_success "  Symlinked: $target → $src"
}
