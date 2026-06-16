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

# Is this an interactive session where we can prompt the user?
#
# Returns non-zero (non-interactive) when:
#   - stdin or stdout is not a terminal
#   - NONINTERACTIVE is set (explicit opt-out for unattended runs)
is-interactive() {
  [[ -t 0 && -t 1 && -z "${NONINTERACTIVE:-}" ]]
}
