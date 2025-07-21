#!/usr/bin/env bash

source ./scripts/util.sh

function getAbsolutePath() {
  # $1 : relative filename
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

function removeAndSymlink() {
  # source=$1 & dest=$2
  rm -f "$2" 2> /dev/null
  ln -s $(getAbsolutePath "$1") "$2"
}

function symlinkDotFiles() {
  removeAndSymlink ./git/gitconfig ~/.gitconfig
  removeAndSymlink ./git/gitignore ~/.gitignore

  removeAndSymlink ./zsh/zshrc ~/.zshrc
  removeAndSymlink ./.vimrc ~/.vimrc

  removeAndSymlink ./.editorconfig ~/.editorconfig
  removeAndSymlink ./.eslintignore ~/.eslintignore
  removeAndSymlink ./.prettierrc.js ~/.prettierrc.js

  if [[ -n "$REMOTE_DEV_ENV" ]]; then
    removeAndSymlink ./ssh/config ~/.ssh/config
  fi

  # atlassian dir setup
  if [[ -n "$REMOTE_DEV_ENV" ]] && [ ! -d ~/dev/atlassian ]; then
    mkdir -p ~/dev/atlassian
  fi

  # TODO: fix this for private dotfiles
  # if [ -d ~/dev/dotfiles-private ]; then
  #   removeAndSymlink ~/dev/dotfiles-private/atlassian/git/gitconfig ~/dev/atlassian/.gitconfig
  # fi

  # TODO: fix this for private dotfiles
  # local TMUX_CONFIG_FILE="$HOME/dev/dotfiles-private/atlassian/tmuxinator/amkt-frontend.yml"
  # if [ -f "$TMUX_CONFIG_FILE" ]; then
  #   mkdir -p ~/.config/tmuxinator
  #   removeAndSymlink "$TMUX_CONFIG_FILE" ~/.config/tmuxinator/amkt-frontend.yml
  # fi
}

if [[ "$REMOTE_DEV_ENV" == "true" ]]; then
  symlinkDotFiles;
else
  runIfYes \
  "dotfiles setup" \
  "Copy over config files? This may overwrite existing files in your home directory." \
  symlinkDotFiles;
fi

unset getAbsolutePath;
unset removeAndSymlink;
unset symlinkDotFiles;
