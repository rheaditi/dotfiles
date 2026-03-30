#!/usr/bin/env bash
# Environment detection utilities. Source this file to use the is_* functions.

is_macos() {
  [ "$(uname -s)" = "Darwin" ]
}

is_linux() {
  [ "$(uname -s)" = "Linux" ]
}

is_windows() {
  case "$(uname -s)" in
    CYGWIN* | MINGW* | MSYS*) return 0 ;;
    *) return 1 ;;
  esac
}

# A devbox is a remote machine that is not a personal workstation.
# Signal this by setting REMOTE_DEV_ENV=true in the machine's environment.
is_devbox() {
  [ "${REMOTE_DEV_ENV:-}" = "true" ]
}

# Sets PACKAGE_MANAGER to the first available package manager.
# Returns 1 if none is found.
detect_package_manager() {
  if command -v brew &>/dev/null; then
    PACKAGE_MANAGER="brew"
  elif command -v apt-get &>/dev/null; then
    PACKAGE_MANAGER="apt"
  elif command -v yum &>/dev/null; then
    PACKAGE_MANAGER="yum"
  else
    PACKAGE_MANAGER=""
    return 1
  fi
}
