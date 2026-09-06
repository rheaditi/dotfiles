# This file sets the options for oh-my-zsh before sourcing the oh-my-zsh.sh file

# path to oh-my-zsh installation
ZSH=$HOME/.oh-my-zsh

# unset theme
ZSH_THEME=""

# Use this setting if you want to disable marking untracked files under VCS as dirty. This makes repository status checks for large repositories much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

if is-devbox; then
  COMPLETION_WAITING_DOTS="false"
  # the default prompt is set via the devbox platform image which we want to disable (search on slack)
  DISABLE_ZSH_DEFAULT_PROMPT="true"
  zstyle ':omz:update' mode disabled  # disable automatic updates
else
  zstyle ':omz:update' mode auto      # update automatically without asking
  zstyle ':omz:update' frequency 30   # update monthly

  # Use this setting if you want to show the completion dots while waiting for completion to expand.
  COMPLETION_WAITING_DOTS="true"
fi

plugins=(git zsh-syntax-highlighting z)

source $ZSH/oh-my-zsh.sh
