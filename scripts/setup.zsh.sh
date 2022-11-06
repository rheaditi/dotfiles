#!/usr/bin/env bash

source ./scripts/util.sh

function setupOhMyZshPlugins() {
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
}

runIfYes \
  "oh-my-zsh plugins" \
  "Install zsh-syntax-highlighting & other plugins?" \
  setupOhMyZshPlugins;
