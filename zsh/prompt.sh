#!/usr/bin/env bash

if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
  # pure-prompt
  fpath+=("$HOME/.zsh/pure")
  autoload -U promptinit; promptinit
  prompt pure
fi
