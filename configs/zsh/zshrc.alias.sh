# Single source of truth for dotfiles path vars (DIR_DEV, DIR_DOTFILES,
# DIR_DOTFILES_PRIVATE, DIR_DOTFILES_PRIVATE_ROOT). Resolved relative to this
# file so it works regardless of where the shell was started.
source "${0:A:h}/../../scripts/utils/paths.sh"

if is-devbox; then
  LOCAL_EDITOR="code-server"
else
  LOCAL_EDITOR="cursor"
fi

# dotfiles related aliases
alias edit-dotfiles="$LOCAL_EDITOR $DIR_DOTFILES"
# Open the private repo root (not the nested content dir) in the editor.
alias edit-dotfiles-private="$LOCAL_EDITOR $DIR_DOTFILES_PRIVATE_ROOT"
# Rebuild the composed AGENTS.md files from sources (after editing fragments)
alias rebuild-agents="$DIR_DOTFILES/scripts/agents/build-agents.sh"

# generic stuff
alias get-date-filename='date +%Y_%m_%d__%H_%M_%S'
alias get-date-commitmsg='date "+%A - %d %B %Y - %T"'
alias uuid='uuidgen | tr "[:upper:]" "[:lower:]"'

# aliases for cd-ing to directories
alias dev="cd $DIR_DEV"
alias play="cd $DIR_DEV/play || echo 'No play directory found'"
alias personal="cd $DIR_DEV/personal || echo 'No personal directory found'"


# aliases for git
alias delete-branches='git branch >/tmp/merged-branches && vi /tmp/merged-branches && xargs git branch -D </tmp/merged-branches'
alias clean-merged-branches='git branch --merged >/tmp/merged-branches && vi /tmp/merged-branches && xargs git branch -d </tmp/merged-branches'
alias clean-remote-branches='git branch -a >/tmp/remote-branches && vi /tmp/merged-branches && xargs git branch -d </tmp/merged-branches'
alias reflog='gitk --all --date-order $(git log -g --pretty=%H)'
alias gbdd='git branch -D'
alias grbim='git rebase -i origin/$(git_main_branch)'
alias gpom='git pull origin $(git_main_branch)'

# aliases for typos 👻
alias got='git'
alias tit='git'
alias hit='git'
alias hot='git'

# aliases for npm
alias nr='npm run'
alias nt='npm run test'
alias ns='npm start'
alias nb='npm run build'
alias ni='npm install'
alias npm-please='rm -rf node_modules && rm package-lock.json && npm i'
alias npm-globals='npm ls -g --depth=0'

# aliases for yarn
alias yi='yarn install'
alias ya='yarn add'
alias yr='yarn run'
alias ye='yarn exec'
alias yarn-please='rm -rf node_modules && rm yarn.lock && yarn install'
alias yw='yarn workspace'

# alias: other 🤗
alias zsource='source ~/.zshrc'
alias tx=tmuxinator

# Quick way to measure zsh startup time
alias timezsh='time zsh -i -c exit'
