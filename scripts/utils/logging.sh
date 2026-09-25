#!/usr/bin/env bash

# Logging utility functions for consistent output formatting

# Color definitions
export COLOR_TEXT_RESET='\033[0m'
export COLOR_TEXT_RED='\033[0;31m'
export COLOR_TEXT_GREEN='\033[0;32m'
export COLOR_TEXT_YELLOW='\033[0;33m'
export COLOR_TEXT_BLUE='\033[0;34m'
export COLOR_TEXT_CYAN='\033[0;36m'
export COLOR_TEXT_WHITE='\033[0;37m'
export COLOR_TEXT_BOLD='\033[1m'

# Log levels
LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_WARNING=2
LOG_LEVEL_ERROR=3

# Default log level (can be overridden by setting LOG_LEVEL environment variable)
export LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_INFO}

# Internal logging function
_log() {
  local level="$1"
  local color="$2"
  local prefix="$3"
  shift 3
  local message="$*"

  if [[ $level -ge $LOG_LEVEL ]]; then
    echo -e "${color}${prefix}${COLOR_TEXT_RESET} $message"
  fi
}

# Log debug message (only shown when LOG_LEVEL=0)
log-debug() {
  _log $LOG_LEVEL_DEBUG "$COLOR_TEXT_WHITE" "[DEBUG]" "$@"
}

# Log info message
log-info() {
  _log $LOG_LEVEL_INFO "$COLOR_TEXT_CYAN" "[INFO]" "$@"
}

# Log success message
log-success() {
  _log $LOG_LEVEL_INFO "$COLOR_TEXT_GREEN" "[✅]" "$@"
}

# Log warning message
log-warning() {
  _log $LOG_LEVEL_WARNING "$COLOR_TEXT_YELLOW" "[⚠️ WARNING]" "$@"
}

# Log error message
log-error() {
  _log $LOG_LEVEL_ERROR "$COLOR_TEXT_RED" "[❌ ERROR]" "$@"
}

# Log a step in the setup process
log-step() {
  _log $LOG_LEVEL_INFO "$COLOR_TEXT_BLUE$COLOR_TEXT_BOLD" "[STEP]" "$@"
}

# Log that something already exists/is installed
log-already-exists() {
  _log $LOG_LEVEL_INFO "$COLOR_TEXT_GREEN" "[☑️]" "$@"
}

