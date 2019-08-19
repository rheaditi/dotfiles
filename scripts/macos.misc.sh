#!/usr/bin/env bash

# Installs some stuff

# # Ask for the administrator password upfront
# sudo -v

# Install Homebrew
#command -v brew >/dev/null 2>&1 || ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
echo ""
if command -v brew 2>/dev/null; then
  echo "✅ Homebrew already installed."
else
  echo "▶️ Installing HomeBrew.."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  echo "✅ done installing homebrew"
fi
echo ""

# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade

# GNU core utilities (those that come with macOS are outdated)
brew install coreutils tree

# work-related
brew install git-tracker # pivotal tracker

# very important commands for daily functioning
brew install fortune cowsay lolcat


NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

echo ""
if command -v nvm 2>/dev/null; then
  echo "✅ nvm already installed."
else
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
  echo "✅ Done installing nvm."
fi
echo ""

# get nvm stuff
nvm install node
nvm alias default node
nvm use default

# npm stuff
npm i -g npm-merge-driver
npm i -g tldr
npm install --global pure-prompt

# Remove outdated versions from the cellar
brew cleanup
