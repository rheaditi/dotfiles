#!/usr/bin/env bash

# alias: generic
alias dotfiles="cd $DIR_DOTFILES"
alias edit-dotfiles="code $DIR_DOTFILES"
alias edit-dotpriv="code $DIR_DOTFILES_PRIVATE"

alias filedate='date +%Y_%m_%d__%H_%M_%S'
alias commitdate='date "+%A - %d %B %Y - %T"'
alias uuid='uuidgen | tr "[:upper:]" "[:lower:]"'

# dir aliases 📁
alias dev="cd $DIR_DEV"
alias play="cd $DIR_DEV/play"
alias personal="cd $DIR_DEV/personal"

# Git things 🌲
alias delete-branches='git branch >/tmp/merged-branches && vi /tmp/merged-branches && xargs git branch -D </tmp/merged-branches'
alias clean-merged-branches='git branch --merged >/tmp/merged-branches && vi /tmp/merged-branches && xargs git branch -d </tmp/merged-branches'
alias clean-remote-branches='git branch -a >/tmp/remote-branches && vi /tmp/merged-branches && xargs git branch -d </tmp/merged-branches'
alias reflog='gitk --all --date-order $(git log -g --pretty=%H)'
alias gbdd='git branch -D'
alias grbim='git rebase -i origin/$(git_main_branch)'
alias gpom='git pull origin $(git_main_branch)'

# alias: typos 👻
alias got='git'
alias tit='git'
alias hit='git'
alias hot='git'

# alias: npm
alias nr='npm run'
alias nt='npm run test'
alias ns='npm start'
alias nb='npm run build'
alias ni='npm install'
alias npmplease='rm -rf node_modules && rm package-lock.json && npm i'
alias npm-globals='npm ls -g --depth=0'
# alias npmnuke='rm -rf node_modules && npm i && lerna exec -- "rm -rf node_modules && npm i"'

# alias: yarn
alias yi='yarn install'
alias ya='yarn add'
alias yr='yarn run'
alias yarnplease='rm -rf node_modules && rm yarn.lock && yarn install'

# alias: other 🤗
alias zsource='source ~/.zshrc'
alias personal='cd ~/dev/personal'
alias tx=tmuxinator

# Quick way to measure zsh startup time
alias timezsh='time zsh -i -c exit'
