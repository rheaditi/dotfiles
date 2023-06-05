#!/usr/bin/env bash

if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
  # pure-prompt
  fpath+=("$(brew --prefix)/share/zsh/site-functions")
  autoload -U promptinit; promptinit
  prompt pure
fi
