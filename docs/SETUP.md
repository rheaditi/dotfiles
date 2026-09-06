# Setup — fresh machine runbook

The "spilled coffee" recovery guide: from a clean machine to fully operational.
For how things are wired, see [`ARCHITECTURE.md`](./ARCHITECTURE.md).

## 0. Prerequisites (macOS)

A fresh Mac needs Apple's Command Line Tools (provides `git`, `clang`, etc.):

```sh
xcode-select --install
```

> Use Apple's bundled `ssh` (it supports `UseKeychain`). If a Homebrew `openssh`
> shadows it, `which -a ssh` will show `/opt/homebrew/bin/ssh` first — uninstall
> it (`brew uninstall openssh`) so `/usr/bin/ssh` wins.

## 1. Clone

```sh
git clone <public-dotfiles-url> ~/dev/dotfiles
cd ~/dev/dotfiles
```

The **private** repo is separate. See
[ARCHITECTURE.md → subtree model](./ARCHITECTURE.md#public--private-subtree-model)
for where it lands (`~/dev/dotfiles-private` locally, `~/dotfiles` on a devbox).
Private config (agents overlay, private gitconfig, keychain-backed secrets) is
optional — everything degrades gracefully when the private repo is absent.

## 2. Choose your path

| You want... | Run |
|---|---|
| Full provisioning (installs tools **and** applies config) | `./bootstrap.sh` |
| Just (re)apply config/symlinks — tools already present | `./setup.sh` |

`bootstrap.sh` is interactive and confirms each install step. For an unattended
run that auto-accepts everything:

```sh
NONINTERACTIVE=1 ./bootstrap.sh
```

Both are **idempotent** — safe to re-run; they install/link only what's missing.

### What `bootstrap.sh` does

1. **Homebrew + packages** from `scripts/brew/Brewfile` *(macOS only)*
2. **Node.js** — nvm + Node + corepack (yarn/pnpm)
3. **Applies all configuration** by delegating to `setup.sh`:
   zsh → git → ssh → editor → terminal → AGENTS.md
4. **VS Code extensions** — only if the `code` CLI is on `PATH` (otherwise it
   tells you to run the stage later)

## 3. VS Code extensions (if skipped)

The `code` CLI often isn't available until after VS Code's first launch
(Cmd+Shift+P → "Shell Command: Install 'code' command in PATH"). Then run the
stage any time:

```sh
./scripts/setup.vscode-extensions.sh
```

Extensions are listed in `configs/vscode/extensions.txt`.

## 4. Populate Keychain secrets (macOS, optional)

Keychain-backed secrets are managed by the **private** repo (they're
Atlassian-specific). Shell startup reads them via the private repo's
`zsh/secrets.sh`; until each item exists you'll see a once-a-day warning (the
shell still works fine, and there's no warning at all without the private repo).

The warning lists each missing item and the exact `security add-generic-password`
command to add it. See the private repo for the full list of items and the env
vars they populate.

## 5. Verify

```sh
exec zsh            # reload the shell; should start with no errors
ssh -G github.com   # personal identity key
ssh -G bitbucket.org # atlassian identity key
node --version && git config --get user.email
```

## Re-running later

- Pulled new dotfiles changes? `./setup.sh` re-applies config.
- New machine or new tools needed? `./bootstrap.sh`.
- Just want one area? Run its orchestrator, e.g. `./scripts/setup.git.sh`.
