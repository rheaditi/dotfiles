# vscode settings

[credit](https://github.com/sapegin/dotfiles/blob/78b87e5/vscode/Readme.md)

## sync settings

```bash
rm ~/Library/Application\ Support/Code/User/settings.json
ln -s ~/dev/dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
```

## add `code` to command line

`Cmd + Shift + P` > `Shell Command: Install 'code' command in PATH`

## plugins [must have]

* Atom Keymap
* Color Highlight
* Editorconfig for VS Code
* Encode Decoe (base64/json/html-entities)
* Eslint
* Gitlens
* Markdownlint
* Night Owl Theme
* Prettier
* Vscode Icons
