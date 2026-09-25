#!/usr/bin/env bash

# Interactive Utility Functions
# Handles user interaction, confirmation prompts, and environment detection

# Source logging and environment functions.
# Use a util-local var name so we never clobber a caller's $SCRIPT_DIR.
UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$UTILS_DIR/logging.sh"
source "$UTILS_DIR/environment.sh"

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

# Confirm whether a setup step should run.
#
# Usage:
#   confirm-step "Node.js" "Install Node.js (via nvm) and yarn?"
#
# Behavior:
#   - Interactive session: prompts "y/N" and returns 0 only on yes.
#   - Non-interactive session (NONINTERACTIVE=1 or no TTY): auto-proceeds
#     (returns 0), following the "spilled coffee" principle of full,
#     reproducible provisioning.
#
# Returns 0 to proceed with the step, non-zero to skip it.
confirm-step() {
  local task="$1"
  local prompt="${2:-Proceed with $task?}"

  if ! is-interactive; then
    log-info "Non-interactive session: auto-proceeding with '$task'"
    return 0
  fi

  log-info "$prompt"
  local reply
  read -p "  → Proceed? (y/N) " -n 1 -r reply
  echo  # New line after input

  if [[ "$reply" =~ ^[Yy]$ ]]; then
    return 0
  else
    log-info "Skipped: $task"
    return 1
  fi
}

# Run a step's command only if confirmed (wrapper around confirm-step).
#
# Usage:
#   run-if-confirmed "Homebrew" "Install Homebrew?" install_homebrew
#
# The third argument and beyond are the command (and args) to execute.
run-if-confirmed() {
  local task="$1"
  local prompt="$2"
  shift 2

  if confirm-step "$task" "$prompt"; then
    if "$@"; then
      log-success "$task: done"
      return 0
    else
      log-error "$task: failed"
      return 1
    fi
  fi

  return 0
}
