#!/usr/bin/env bash

# VS Code Settings Setup with Private Repo Integration
# Handles VS Code with configurable private repo paths

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/logging.sh"
source "$SCRIPT_DIR/../utils/file-operations.sh"
source "$SCRIPT_DIR/../../common/utils/paths.sh"

# Configuration paths using path utilities
BASE_SETTINGS="$(get-vscode-base-settings)"
PRIVATE_SETTINGS="$(get-vscode-private-settings)"
PRIVATE_KEYBINDINGS="$(get-vscode-private-keybindings)"
MERGED_SETTINGS="$(get-vscode-merged-settings)"
MERGED_KEYBINDINGS="$(get-vscode-merged-keybindings)"

# Detect VS Code environment
detect-vscode-environment() {
  if [[ -d "$HOME/.local/share/code-server" ]]; then
    echo "code-server"
    echo "$HOME/.local/share/code-server/User/settings.json"
    echo "$HOME/.local/share/code-server/User/keybindings.json"
  elif [[ -d "$HOME/.config/Code" ]]; then
    echo "vscode"
    echo "$HOME/.config/Code/User/settings.json"
    echo "$HOME/.config/Code/User/keybindings.json"
  else
    echo "none"
  fi
}

# Merge JSON files with conflict logging
merge-json-files() {
  local output_file="$1"
  shift
  local input_files=("$@")

  log-info "Merging JSON files: ${input_files[*]}"

  # Use jq for robust JSON merging
  if command -v jq >/dev/null 2>&1; then
    # Merge files in order (later files override earlier ones)
    jq -s 'reduce .[] as $item ({}; . * $item)' "${input_files[@]}" > "$output_file.tmp" && \
    mv "$output_file.tmp" "$output_file"
    log-success "Successfully merged JSON files using jq"
  else
    log-error "jq is required for JSON merging. Please install jq."
    return 1
  fi
}

# Setup for local environment (base + private → merged file → symlink)
setup-local-vscode() {
  log-info "Setting up VS Code settings for local environment..."

  local env_info=($(detect-vscode-environment))
  local env_type="${env_info[0]}"
  local settings_target="${env_info[1]}"
  local keybindings_target="${env_info[2]}"

  if [[ "$env_type" == "none" ]]; then
    log-warning "No VS Code installation detected"
    return 0
  fi

  log-info "Detected environment: $env_type"

  # Ensure private vscode directory exists
  mkdir -p "$PRIVATE_VSCODE_DIR"

  # Merge base + private settings
  if [[ -f "$BASE_SETTINGS" ]] && [[ -f "$PRIVATE_SETTINGS" ]]; then
    merge-json-files "$MERGED_SETTINGS" "$BASE_SETTINGS" "$PRIVATE_SETTINGS"
  elif [[ -f "$BASE_SETTINGS" ]]; then
    cp "$BASE_SETTINGS" "$MERGED_SETTINGS"
    log-info "Copied base settings (no private overrides found)"
  else
    log-error "Base settings file not found: $BASE_SETTINGS"
    return 1
  fi

  # Merge base + private keybindings
  if [[ -f "$BASE_KEYBINDINGS" ]] && [[ -f "$PRIVATE_KEYBINDINGS" ]]; then
    merge-json-files "$MERGED_KEYBINDINGS" "$BASE_KEYBINDINGS" "$PRIVATE_KEYBINDINGS"
  elif [[ -f "$BASE_KEYBINDINGS" ]]; then
    cp "$BASE_KEYBINDINGS" "$MERGED_KEYBINDINGS"
    log-info "Copied base keybindings (no private overrides found)"
  else
    log-warning "Base keybindings file not found: $BASE_KEYBINDINGS"
  fi

  # Ensure target directories exist
  mkdir -p "$(dirname "$settings_target")"
  mkdir -p "$(dirname "$keybindings_target")"

  # Backup existing settings
  if [[ -f "$settings_target" ]]; then
    backup-file "$settings_target"
  fi
  if [[ -f "$keybindings_target" ]]; then
    backup-file "$keybindings_target"
  fi

  # Create symlinks to merged files
  ln -sf "$MERGED_SETTINGS" "$settings_target"
  log-success "Created settings symlink: $settings_target -> $MERGED_SETTINGS"

  if [[ -f "$MERGED_KEYBINDINGS" ]]; then
    ln -sf "$MERGED_KEYBINDINGS" "$keybindings_target"
    log-success "Created keybindings symlink: $keybindings_target -> $MERGED_KEYBINDINGS"
  fi

  log-success "Local VS Code settings setup complete"
}

# Setup for devbox environment (existing + base + private → code-server file)
setup-devbox-vscode() {
  log-info "Setting up VS Code settings for devbox environment..."

  local env_info=($(detect-vscode-environment))
  local env_type="${env_info[0]}"
  local settings_target="${env_info[1]}"
  local keybindings_target="${env_info[2]}"

  if [[ "$env_type" != "code-server" ]]; then
    log-warning "Expected code-server environment, found: $env_type"
    return 0
  fi

  log-info "Detected environment: $env_type"

  # Ensure target directories exist
  mkdir -p "$(dirname "$settings_target")"
  mkdir -p "$(dirname "$keybindings_target")"

  # Merge existing + base + private settings
  local merge_files=()

  # Add existing settings if they exist
  if [[ -f "$settings_target" ]]; then
    merge_files+=("$settings_target")
    log-info "Including existing code-server settings in merge"
  fi

  # Add base settings
  if [[ -f "$BASE_SETTINGS" ]]; then
    merge_files+=("$BASE_SETTINGS")
  else
    log-error "Base settings file not found: $BASE_SETTINGS"
    return 1
  fi

  # Add private settings if they exist
  if [[ -f "$PRIVATE_SETTINGS" ]]; then
    merge_files+=("$PRIVATE_SETTINGS")
  else
    log-warning "Private settings file not found: $PRIVATE_SETTINGS"
  fi

  # Merge and write to code-server location
  merge-json-files "$settings_target" "${merge_files[@]}"
  log-success "Generated code-server settings: $settings_target"

  # Handle keybindings
  if [[ -f "$BASE_KEYBINDINGS" ]]; then
    local keybindings_merge_files=()

    # Add existing keybindings if they exist
    if [[ -f "$keybindings_target" ]]; then
      keybindings_merge_files+=("$keybindings_target")
    fi

    keybindings_merge_files+=("$BASE_KEYBINDINGS")

    # Add private keybindings if they exist
    if [[ -f "$PRIVATE_KEYBINDINGS" ]]; then
      keybindings_merge_files+=("$PRIVATE_KEYBINDINGS")
    fi

    # Merge and write to code-server location
    merge-json-files "$keybindings_target" "${keybindings_merge_files[@]}"
    log-success "Generated code-server keybindings: $keybindings_target"
  fi

  log-success "Devbox VS Code settings setup complete"
}

# Main setup function
setup-vscode() {
  log-info "Setting up VS Code..."

  # Check if private dotfiles path exists
  if [[ ! -d "$PRIVATE_DOTFILES_PATH" ]]; then
    log-error "Private dotfiles repository not found: $PRIVATE_DOTFILES_PATH"
    log-error "Please set PRIVATE_DOTFILES_PATH environment variable"
    return 1
  fi

  # Check if base settings exist
  if [[ ! -f "$BASE_SETTINGS" ]]; then
    log-error "Base settings file not found: $BASE_SETTINGS"
    return 1
  fi

  # Environment-specific setup
  if [[ -n "$REMOTE_DEV_ENV" ]]; then
    setup-devbox-vscode
  else
    setup-local-vscode
  fi

  log-success "VS Code setup complete"
}

# Main execution
setup-vscode
