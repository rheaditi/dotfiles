#!/usr/bin/env bash

# Load exactly one committed user profile plus optional machine-local overrides.
# Callers must define DOTFILES_ROOT before invoking this function.
load-user-config() {
  local config_dir="$DOTFILES_ROOT/configs"
  local local_file="$config_dir/local.env"
  local profile_file
  local -a profile_files=()

  for profile_file in "$config_dir"/*.env; do
    [[ -f "$profile_file" ]] || continue
    [[ "$profile_file" == "$local_file" ]] && continue
    profile_files+=("$profile_file")
  done

  if [[ ${#profile_files[@]} -eq 0 ]]; then
    echo "No committed user profile found in $config_dir" >&2
    echo "Copy configs/rheaditi.env to configs/<username>.env before running setup." >&2
    return 1
  fi

  if [[ ${#profile_files[@]} -gt 1 ]]; then
    echo "Multiple committed user profiles found in $config_dir:" >&2
    printf '  - %s\n' "${profile_files[@]##*/}" >&2
    echo "Keep exactly one profile before running setup." >&2
    return 1
  fi

  # shellcheck source=/dev/null
  source "${profile_files[0]}"

  if [[ -f "$local_file" ]]; then
    # shellcheck source=/dev/null
    source "$local_file"
  fi
}
