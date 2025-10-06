if is-devbox; then
  DIR_DEV="$HOME/dev"
  DIR_DOTFILES="$DIR_DEV/dotfiles"
  DIR_DOTFILES_PRIVATE="$HOME/dotfiles"
  LOCAL_EDITOR="code-server"
else
  DIR_DEV="$HOME/dev"
  DIR_DOTFILES="$DIR_DEV/dotfiles"
  DIR_DOTFILES_PRIVATE="$DIR_DEV/dotfiles-private"
  LOCAL_EDITOR="cursor"
fi

# dotfiles related aliases
alias edit-dotfiles="$LOCAL_EDITOR $DIR_DOTFILES"
alias edit-dotfiles-private="$LOCAL_EDITOR $DIR_DOTFILES_PRIVATE"

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
