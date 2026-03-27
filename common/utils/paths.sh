#!/usr/bin/env bash

if [[ -n "$REMOTE_DEV_ENV" ]]; then
  # this is the RDE environment
  DIR_DEV="$HOME/dev"
  DIR_DOTFILES="$DIR_DEV/dotfiles"
  DIR_DOTFILES_PRIVATE="$HOME/dotfiles"
else
  # this is the local environment
  DIR_DEV="$HOME/dev"
  DIR_DOTFILES="$DIR_DEV/dotfiles"
  DIR_DOTFILES_PRIVATE="$DIR_DEV/dotfiles-private/atlassian"
fi
