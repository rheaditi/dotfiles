#!/usr/bin/env bash

# Platform Detection Utility
# Shared between configuration files and setup scripts
# Provides consistent platform detection across the dotfiles system

# Detect the current platform and return the platform identifier
detect-platform() {
  # Detect operating system
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Further detect Linux variants
    if [[ -n "$REMOTE_DEV_ENV" ]]; then
      echo "linux"
    elif grep -q WSL /proc/version 2>/dev/null; then
      echo "linux"
    else
      echo "linux"
    fi
  else
    echo "unknown"
  fi
}

# Detect the current environment type
detect-environment() {
  if [[ -n "$REMOTE_DEV_ENV" ]]; then
    echo "devbox"
  elif grep -q WSL /proc/version 2>/dev/null; then
    echo "wsl"
  else
    echo "local"
  fi
}

# Platform helper functions
is-macos() {
  [[ "$(detect-platform)" == "macos" ]]
}

is-linux() {
  [[ "$(detect-platform)" == "linux" ]]
}

# Environment helper functions
is-local() {
  [[ "$(detect-environment)" == "local" ]]
}

is-devbox() {
  [[ "$(detect-environment)" == "devbox" ]]
}

is-wsl() {
  [[ "$(detect-environment)" == "wsl" ]]
}
