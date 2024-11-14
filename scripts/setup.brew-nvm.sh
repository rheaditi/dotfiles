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

# NVM ############################################################################################

function installNvm() {
  if command -v nvm 2>/dev/null; then
    echo "nvm already installed."
  else
    /bin/bash -c "$(curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh)"

    NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm for the current shell

    # Get latest node & set as default
    nvm install node
    nvm alias default node
    nvm use default
  fi
}

runIfYes \
  "nvm" \
  "Install nvm?" \
  installNvm;

# Node ###########################################################################################

function installNodeGlobalUtils() {
  npm i -g npm-merge-driver
  npm i -g tldr
}

runIfYes \
  "node global utils" \
  "Install npm-merge-driver, tldr?" \
  installNodeGlobalUtils;

function installYarnBolt() {
  # Install yarn
  npx check-node-version --node '>= 16' >> /dev/null
  if [ $? -eq 1 ]; then
    corepack enable
  else
    npm i -g corepack
  fi

  # Install bolt
  npm i -g bolt
}

runIfYes \
  "yarn & bolt" \
  "Install yarn & bolt globally?" \
  installYarnBolt;
