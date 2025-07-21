#!/usr/bin/env bash

function setupOhMyZshPlugins() {
  local plugin_dir="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

  if [ ! -d "$plugin_dir" ]; then
    echo "zsh-syntax-highlighting plugin not found; installing..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugin_dir"
  else
    echo "☑️ zsh-syntax-highlighting plugin already exists at \"$plugin_dir\""
  fi
}

function setupPurePrompt() {
  local pure_dir="$HOME/.zsh/pure"

  if [ ! -d "$pure_dir" ]; then
    echo "pure-prompt not found; installing..."
    mkdir -p "$HOME/.zsh"
    rm -rf "$HOME/.zsh/pure"
    git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
  else
    echo "☑️ pure-prompt already exists at \"$pure_dir\""
  fi
}

function setupZsh() {
  if ! command -v zsh &> /dev/null; then
    echo "zsh shell not found; installing..."

    if [[ $OSTYPE == 'darwin'* ]]; then
      brew install zsh
    else
      sudo apt update
      sudo apt install -y zsh
    fi
    echo "✅ zsh installed"
  fi

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✅ Oh My Zsh installed"
  else
    echo "☑️ Oh My Zsh already exists at \"$HOME/.oh-my-zsh\""
  fi
}

setupZsh;
setupOhMyZshPlugins;
setupPurePrompt;
