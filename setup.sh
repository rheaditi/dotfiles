#!/usr/bin/env bash
DIR="../../"

echo ""

./scripts/setup.macos.sh
./scripts/setup.dotfiles.sh
./scripts/setup.brew-nvm.sh

cat << EOF
Other things to manually setup:
  → Font: Fira Code (https://github.com/tonsky/FiraCode/releases)

Reload the .zshrc:-
  $ source ~/.zshrc
EOF

