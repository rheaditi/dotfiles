#!/usr/bin/env bash

# parse and set all options required during setup
# this file is sourced by other setup files

function is-macos() {
  if [[ $OSTYPE == 'darwin'* ]]; then
    return 0
  else
    return 1
  fi
}

function is-linux() {
  if [[ $OSTYPE == "linux-gnu"* ]]; then
    return 0
  else
    return 1
  fi
}

function is-remote-dev-env() {
  if [[ "$REMOTE_DEV_ENV" == "true" ]]; then
    return 0
  else
    return 1
  fi
}

function is-interactive() {
  # Check multiple indicators of interactive session:
  # -t 0: stdin is a terminal
  # -t 1: stdout is a terminal
  # PS1: prompt is set (interactive shell)
  # TERM: terminal type is set
  # Not in CI/automated environment
  [[ -t 0 && -t 1 && -n "${PS1:-}" && -n "${TERM:-}" && -z "${CI:-}" && -z "${NONINTERACTIVE:-}" ]]
}


