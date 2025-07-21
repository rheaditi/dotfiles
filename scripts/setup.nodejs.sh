#!/usr/bin/env bash

function setupNvm() {
  if command -v nvm 2>/dev/null; then
    echo "☑️ nvm already installed,"
  else
    /bin/bash -c "$(curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh)"
    echo "✅ nvm installed"
  fi

  NVM_DIR="$HOME/.nvm"
  # This loads nvm for the current shell with default node version
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}

function setupYarn() {
  # check if yarn is installed
  if command -v yarn 2>/dev/null; then
    echo "☑️ yarn already installed"
  else
    npm install -g corepack
    corepack enable
    echo "✅ yarn (corepack) installed"
  fi
}

setupNvm;
setupYarn;
