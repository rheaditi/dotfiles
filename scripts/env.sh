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
# Update this detection as you see fit.
is_devbox() {
  [ "${REMOTE_DEV_ENV:-}" = "true" ]
}
