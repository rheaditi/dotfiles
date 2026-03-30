#!/usr/bin/env bash
# Logging utilities. Source this file to use the log functions.

# Colors (only emit codes when stdout is a terminal)
if [ -t 1 ]; then
  _LOG_RESET="\033[0m"
  _LOG_GRAY="\033[0;90m"
  _LOG_GREEN="\033[0;32m"
  _LOG_YELLOW="\033[0;33m"
  _LOG_RED="\033[0;31m"
else
  _LOG_RESET=""
  _LOG_GRAY=""
  _LOG_GREEN=""
  _LOG_YELLOW=""
  _LOG_RED=""
fi

log_info() {
  printf "${_LOG_GRAY}[info]${_LOG_RESET}  %s\n" "$*"
}

log_success() {
  printf "${_LOG_GREEN}[ok]${_LOG_RESET}    %s\n" "$*"
}

log_warn() {
  printf "${_LOG_YELLOW}[warn]${_LOG_RESET}  %s\n" "$*" >&2
}

log_error() {
  printf "${_LOG_RED}[error]${_LOG_RESET} %s\n" "$*" >&2
}
