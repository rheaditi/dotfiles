# VS Code settings

These files are the source of truth for VS Code configuration. They are
**symlinked** into the VS Code `User/` directory by `scripts/setup.editor.sh`
(run as part of `./setup.sh`), so edits made in the VS Code UI flow straight
back into this repo — no drift, no manual copying.

| File | Symlinked to (macOS) |
|------|----------------------|
| `settings.json` | `~/Library/Application Support/Code/User/settings.json` |
| `keybindings.json` | `~/Library/Application Support/Code/User/keybindings.json` |
| `settings.cursor.json` | _(reserved for a future Cursor setup; not yet wired)_ |

## Setup

Just run the dotfiles setup — VS Code is handled automatically:

```bash
./setup.sh
```

The installer detects the VS Code (or code-server) User directory, backs up
any existing real `settings.json`/`keybindings.json`, and creates the symlinks.
Re-running is idempotent.

## Add `code` to the command line

`Cmd + Shift + P` > `Shell Command: Install 'code' command in PATH`

## Plugins [must have]

* Atom Keymap
* Color Highlight
* Editorconfig for VS Code
* Encode Decode (base64/json/html-entities)
* Eslint
* Gitlens
* Markdownlint
* Night Owl Theme
* Prettier
* Vscode Icons

[original credit](https://github.com/sapegin/dotfiles/blob/78b87e5/vscode/Readme.md)
