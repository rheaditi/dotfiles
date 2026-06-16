# DIR_DOTFILES_PRIVATE resolves to the private repo's content dir for both
# local (~/dev/dotfiles-private/atlassian) and devbox (~/dotfiles) subtree
# clones. Source paths.sh so this works regardless of load order.
source "${0:A:h}/../../scripts/utils/paths.sh"

if [[ -f "$DIR_DOTFILES_PRIVATE/zsh/entry.sh" ]]; then
  source "$DIR_DOTFILES_PRIVATE/zsh/entry.sh"
fi
