if is-devbox; then
  if [[ -f "$HOME/dotfiles/zsh/entry.sh" ]]; then
    source "$HOME/dotfiles/zsh/entry.sh"
  fi
else
  if [[ -f "$HOME/dev/dotfiles-private/atlassian/zsh/entry.sh" ]]; then
    source "$HOME/dev/dotfiles-private/atlassian/zsh/entry.sh"
  fi
fi
