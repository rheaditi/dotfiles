#!/usr/bin/env bash

source ./scripts/util.sh

VSCODE_DIR=~/Library/Application\ Support/Code

function setupUserSettings() {
  local VSCODE_USER_SETTINGS_SRC=~/dev/dotfiles/vscode/settings.json
  local VSCODE_KEYBINDINGS_SRC=~/dev/dotfiles/vscode/keybindings.json
  local VSCODE_USER_SETTINGS_DEST="$VSCODE_DIR/User/settings.json"
  local VSCODE_KEYBINDINGS_DEST="$VSCODE_DIR/User/keybindings.json"

  rm "$VSCODE_USER_SETTINGS_DEST"
  rm "$VSCODE_KEYBINDINGS_DEST"

  ln -s "$VSCODE_USER_SETTINGS_SRC" "$VSCODE_USER_SETTINGS_DEST"
  ln -s "$VSCODE_KEYBINDINGS_SRC" "$VSCODE_KEYBINDINGS_DEST"
}

function installExtensions() {
  local VSCODE_EXTENSIONS=(
    "ms-vscode.atom-keybindings"
    "editorconfig.editorconfig"
    "eamodio.gitlens"
    "esbenp.prettier-vscode"
    "naumovs.color-highlight"
    "davidanson.vscode-markdownlint"
    "vscode-icons-team.vscode-icons"
    "chakrounanas.turbo-console-log"
    "dbaeumer.vscode-eslint"
    "alefragnani.bookmarks"
    "mquandalle.graphql"
    "redhat.vscode-yaml"

    "styled-components.vscode-styled-components"
    "flowtype.flow-for-vscode"
    "Atlassian.atlascode"
    "Orta.vscode-jest"

    # themes/color schemes
    "cev.overnight"
    "sdras.night-owl"
    "enkia.tokyo-night"
  )

  # temporarily add vscode to path
  PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

  for extension in ${VSCODE_EXTENSIONS[@]}; do
    code --install-extension "$extension" > /dev/null
  done
}

function setupVscode() {
  local VSCODE_DOWNLOAD="https://code.visualstudio.com/download"
  if [ ! -d "$VSCODE_DIR" ]; then
    # Maybe vscode isn't installed? Share the link
    echo "Oops, vscode does not seem to be installed.\nDownload vscode from here and try again:\n"
    echo "$VSCODE_DOWNLOAD"
    exit 0
  fi

  runIfYes \
    "vscode user settings" \
    "Overwrite user settings & keybindings?" \
    setupUserSettings;

  runIfYes \
    "vscode extensions" \
    "Install extensions?" \
    installExtensions;

  echo "To add vscode to command line, open vscode then:-"
  echo "Cmd + Shift + P > Shell Command: Install 'code' command in PATH"
  echo ""
}

runIfYes \
  "vscode" \
  "Setup vscode?" \
  setupVscode;

unset setupVscode;
unset installExtensions;
unset setupUserSettings;
unset VSCODE_DIR;
