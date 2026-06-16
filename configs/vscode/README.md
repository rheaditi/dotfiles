# VS Code settings

These files are the source of truth for VS Code configuration. They are
**symlinked** into the VS Code `User/` directory by `scripts/setup.editor.sh`
(run as part of `./setup.sh`), so edits made in the VS Code UI flow straight
back into this repo — no drift, no manual copying.

| File | Symlinked to (macOS) |
|------|----------------------|
| `settings.json` | `~/Library/Application Support/Code/User/settings.json` |
| `keybindings.json` | `~/Library/Application Support/Code/User/keybindings.json` |
| `extensions.txt` | _(not symlinked — list of extensions to auto-install)_ |
| `settings.cursor.json` | _(reserved for a future Cursor setup; not yet wired)_ |

## Setup

Just run the dotfiles setup — VS Code config is handled automatically:

```bash
./setup.sh
```

The installer detects the VS Code (or code-server) User directory, backs up
any existing real `settings.json`/`keybindings.json`, and creates the symlinks.
Re-running is idempotent.

## Extensions

Extensions are listed in [`extensions.txt`](extensions.txt) (one ID per line,
`#` comments allowed) and installed via a **separate stage**:

```bash
./scripts/setup.vscode-extensions.sh
```

This is kept separate from config because the `code` CLI is provided by the
VS Code GUI app and may not be on `PATH` on a fresh machine. `bootstrap.sh`
runs this stage automatically **if** `code` is available, otherwise it prints a
reminder to run it later. Installs are idempotent (already-installed extensions
are treated as success).

To add an extension: append its `publisher.name` ID to `extensions.txt` and
re-run the stage. Find IDs via an extension's Marketplace page or
`code --list-extensions`.

### Currently auto-installed

* `ms-vscode.atom-keybindings` — Atom Keymap
* `esbenp.prettier-vscode` — Prettier
* `dbaeumer.vscode-eslint` — ESLint
* `vscode-icons-team.vscode-icons` — VSCode Icons
* `davidanson.vscode-markdownlint` — markdownlint
* `editorconfig.editorconfig` — EditorConfig

## Add `code` to the command line

`Cmd + Shift + P` > `Shell Command: Install 'code' command in PATH`

[original credit](https://github.com/sapegin/dotfiles/blob/78b87e5/vscode/Readme.md)
