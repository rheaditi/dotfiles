#!/usr/bin/env bash

# Environment Detection Utility Functions
# Detects OS, remote dev environment, and interactive session state.
# Source this file to use these helpers in setup/bootstrap scripts.

# Is the current OS macOS?
is-macos() {
  [[ "$OSTYPE" == 'darwin'* ]]
}

# Is the current OS Linux?
is-linux() {
  [[ "$OSTYPE" == "linux-gnu"* ]]
}

# Are we running in a remote dev environment (e.g. devbox)?
is-remote-dev-env() {
  [[ "${REMOTE_DEV_ENV:-}" == "true" ]]
}

# Alias kept for callers that use the older name.
is-devbox() {
  is-remote-dev-env
}

# Is this a plain local machine (not a devbox/RDE)?
is-local() {
  ! is-remote-dev-env
}

# Are we running under WSL?
is-wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
}

# Echo a short platform identifier: macos | linux | unknown
detect-platform() {
  if is-macos; then
    echo "macos"
  elif is-linux; then
    echo "linux"
  else
    echo "unknown"
  fi
}

# Echo a short environment identifier: devbox | wsl | local
detect-environment() {
  if is-remote-dev-env; then
    echo "devbox"
  elif is-wsl; then
    echo "wsl"
  else
    echo "local"
  fi
}

# Is this an interactive session where we can prompt the user?
#
# Returns non-zero (non-interactive) when:
#   - stdin or stdout is not a terminal
#   - NONINTERACTIVE is set (explicit opt-out for unattended runs)
is-interactive() {
  [[ -t 0 && -t 1 && -z "${NONINTERACTIVE:-}" ]]
}
