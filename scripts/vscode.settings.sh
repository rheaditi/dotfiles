VSCODE_DIR=~/Library/Application\ Support/Code
VSCODE_DOWNLOAD="https://code.visualstudio.com/download"
VSCODE_USER_SETTINGS_SRC=~/dev/dotfiles/vscode/settings.json
VSCODE_USER_SETTINGS_DEST="$VSCODE_DIR/User/settings.json"

if [ ! -d "$VSCODE_DIR" ]; then
  # Maybe vscode isn't installed? Share the link
  echo "Oops, vscode does not seem to be installed.\nDownload vscode from here and try again:\n"
  echo "$VSCODE_DOWNLOAD"
  exit 0
fi

if [ -f "$VSCODE_USER_SETTINGS_DEST" ]; then
    read -p "Overwrite existing vscode user settings? (y/n) " -n 1;
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "$VSCODE_USER_SETTINGS_DEST"
    else
        echo "🚫 Ok. Skipping vscode setup."
        exit 0
    fi;
fi

ln -s "$VSCODE_USER_SETTINGS_SRC" "$VSCODE_USER_SETTINGS_DEST"

echo "✅ User settings updated."
echo ""

echo "To add vscode to command line, open vscode then:-"
echo "Cmd + Shift + P > Shell Command: Install 'code' command in PATH"