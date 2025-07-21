#!/usr/bin/env bash

# Pure prompt optimization
zstyle :prompt:pure:git:stash show yes
PURE_CMD_MAX_EXEC_TIME=1
PURE_GIT_PULL=0
PURE_GIT_UNTRACKED_DIRTY=0

fpath+=("$HOME/.zsh/pure")
autoload -U promptinit; promptinit
prompt pure
