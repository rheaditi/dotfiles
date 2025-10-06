#!/usr/bin/env bash

# Interactive Utility Functions
# Handles user interaction, confirmation prompts, and environment detection

# Source logging functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logging.sh"

# Check if running in interactive terminal
is-interactive() {
  [[ -t 0 && -t 1 ]]
}

# Ask for confirmation with timeout (auto-proceed after timeout)
ask-with-timeout() {
  local message="$1"
  local timeout="${2:-5}"

  log-info "$message"
  log-info "Press 'y' to confirm, any other input to deny, or wait $timeout seconds to proceed automatically..."

  if read -t $timeout -n 1 -r response; then
    echo  # New line after input
    case "$response" in
      [Yy])
        log-info "User confirmed"
        return 0
        ;;
      *)
        log-info "User declined"
        return 1
        ;;
    esac
  else
    echo  # New line after timeout
    log-info "Timeout reached, proceeding automatically"
    return 0
  fi
}
