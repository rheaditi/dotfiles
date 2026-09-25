#!/usr/bin/env bash

DIR_DEV="$HOME/dev"
DIR_DOTFILES="$DIR_DEV/dotfiles"

if [[ -n "${REMOTE_DEV_ENV:-}" ]]; then
  # RDE/devbox: private dotfiles are checked out flat at ~/dotfiles, so the
  # repo root and the tooling content dir are the same.
  DIR_DOTFILES_PRIVATE_ROOT="$HOME/dotfiles"
  DIR_DOTFILES_PRIVATE="$DIR_DOTFILES_PRIVATE_ROOT"
else
  # Local: the private repo nests its actual content under an "atlassian/"
  # subdir, so the repo root and the content dir differ.
  DIR_DOTFILES_PRIVATE_ROOT="$DIR_DEV/dotfiles-private"
  DIR_DOTFILES_PRIVATE="$DIR_DOTFILES_PRIVATE_ROOT/atlassian"
fi
