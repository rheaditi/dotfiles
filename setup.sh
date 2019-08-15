#!/usr/bin/env bash
DIR="../../"

getAbsolutePath() {
  # $1 : relative filename
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

function removeAndSymlink() {
  # source=$1 & dest=$2

  rm -f "$2" 2> /dev/null
  ln -s $(getAbsolutePath "$1") "$2"
}

function doIt() {
  removeAndSymlink ./git/gitconfig ~/.gitconfig
  removeAndSymlink ./git/gitignore ~/.gitignore
  removeAndSymlink ./zsh/zshrc ~/.zshrc

  removeAndSymlink ./.editorconfig ~/.editorconfig
  removeAndSymlink ./.eslintignore ~/.eslintignore
  removeAndSymlink ./.prettierrc.js ~/.prettierrc.js
}

echo ""
if [ "$1" == "--force" -o "$1" == "-f" ]; then
  doIt;
else
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
  echo "";
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    doIt;
    echo "✅ Done"
  else
    echo "🚫 Ok. Skipping setup."
  fi;
fi;
echo ""
unset doIt;
