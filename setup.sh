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
  removeAndSymlink ./ssh/config ~/.ssh/config
  removeAndSymlink ./zsh/zshrc ~/.zshrc
  removeAndSymlink ./.vimrc ~/.vimrc

  removeAndSymlink ./.editorconfig ~/.editorconfig
  removeAndSymlink ./.eslintignore ~/.eslintignore
  removeAndSymlink ./.prettierrc.js ~/.prettierrc.js
}

echo ""

read -p "Copy over config files? This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
echo "";
if [[ $REPLY =~ ^[Yy]$ ]]; then
  doIt;
  echo "✅ Done"
else
  echo "🚫 Ok. Skipping config file setup."
fi;

read -p "Apply macOS settings overrides? (y/n) " -n 1;
  echo "";
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./scripts/macos.settings.sh;
    echo "✅ Done"
  else
    echo "🚫 Ok. Skipping macOS settings overrides."
  fi;
echo ""

read -p "Install brew, nvm & other packages? (y/n) " -n 1;
  echo "";
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./scripts/macos.misc.sh;
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    echo "✅ Done"
  else
    echo "🚫 Ok. Skipping brew/nvm installation."
  fi;
echo ""

read -p "Setup vscode? (y/n) " -n 1;
  echo "";
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./scripts/vscode.settings.sh;
    echo "✅ Done"
  else
    echo "🚫 Ok. Skipping vscode setup."
  fi;
echo ""

unset doIt;
unset removeAndSymlink;
unset getAbsolutePath;

cat << EOF
Other things to manually setup:
→ Font: Fira Code (https://github.com/tonsky/FiraCode/releases)
EOF

source ~/.zshrc
