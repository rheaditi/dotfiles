#!/usr/bin/env bash

# Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Show the ~/Library folder
chflags nohidden ~/Library

# Empty Trash securely by default
defaults write com.apple.finder EmptyTrashSecurely -bool true

# Disable startup sound
sudo nvram SystemAudioVolume="%80"

echo ""
echo "Done. Note that some of these changes require a logout/restart to take effect."
