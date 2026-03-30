#!/usr/bin/env bash
# Core directory variables. Source this file early in any script that needs
# to know where things live. Requires env.sh to be sourced first.

# Home directory — where configs are symlinked / gitconfigs are written
export DIR_HOME="$HOME"

# Root of all development work (usually)
export DIR_DEV="$HOME/dev"

# Public dotfiles repo location
export DIR_DOTFILES="$DIR_DEV/dotfiles"

# Private dotfiles repo location.
# On devboxes the private repo is cloned directly into $HOME (no dev/ prefix)
# so it is always at a predictable, short path regardless of machine layout.
if is_devbox; then
  export DIR_DOTFILES_PRIVATE="$HOME/dotfiles"
else
  export DIR_DOTFILES_PRIVATE="$DIR_DEV/dotfiles-private"
fi

