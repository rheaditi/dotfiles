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

  removeAndSymlink ./ssh/config ~/.ssh/config
  removeAndSymlink ./zsh/zshrc ~/.zshrc
  removeAndSymlink ./.vimrc ~/.vimrc

  removeAndSymlink ./.editorconfig ~/.editorconfig
  removeAndSymlink ./.eslintignore ~/.eslintignore
  removeAndSymlink ./.prettierrc.js ~/.prettierrc.js

  # Atlassian
  if [ ! -d ~/dev/atlassian ]; then
    mkdir -p ~/dev/atlassian
  fi

  removeAndSymlink ./git/atlassian.gitconfig ~/dev/atlassian/.gitconfig
}

runIfYes \
  "dotfiles setup" \
  "Copy over config files? This may overwrite existing files in your home directory." \
  symlinkDotFiles;

unset getAbsolutePath;
unset removeAndSymlink;
unset symlinkDotFiles;
