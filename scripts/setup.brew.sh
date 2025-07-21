#!/usr/bin/env bash

source ./scripts/util.sh

# Homebrew #######################################################################################

function installBrewCoreUtils() {
  brew install coreutils tree gpg
}

function installBrew() {
  if command -v brew 2>/dev/null; then
    echo "Homebrew already installed."
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  # Make sure we're using the latest Homebrew
  brew update

  # Upgrade any already-installed formulae
  brew upgrade

  runIfYes \
    "GNU core utilities" \
    "Install some core utilities via brew (those that come with macOS are outdated)?" \
    installBrewCoreUtils;
}

function installBrewIfYes() {
  runIfYes \
    "Homebrew" \
    "Install Homebrew?" \
    installBrew;

  # Remove outdated versions from the cellar
  brew cleanup
}

runOnlyIfMacOS installBrewIfYes;
