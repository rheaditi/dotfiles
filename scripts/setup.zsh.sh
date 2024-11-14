#!/usr/bin/env bash

source ./scripts/util.sh

function setupOhMyZshPlugins() {
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
}

function setupPurePrompt() {
  mkdir -p "$HOME/.zsh"
  rm -rf "$HOME/.zsh/pure"
  git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
}

runIfYes \
  "pure-prompt" \
  "Install pure-prompt?" \
  setupPurePrompt;

runIfYes \
  "oh-my-zsh plugins" \
  "Install zsh-syntax-highlighting & other plugins?" \
  setupOhMyZshPlugins;
