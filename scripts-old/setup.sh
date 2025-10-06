#!/usr/bin/env bash

echo ""

./scripts/setup.macos.sh
./scripts/setup.dotfiles.sh
./scripts/setup.brew.sh
./scripts/setup.nodejs.sh
./scripts/setup.zsh.sh

cat << EOF
Other things to manually setup:
  → Font: Fira Code (https://github.com/tonsky/FiraCode/releases)

Reload the .zshrc:-
  $ source ~/.zshrc
EOF

