# Git Configuration System

Environment-aware Git configuration using Git's `[include]` feature.

## Files

- **`base.gitconfig`** — shared Git settings.
- **`global.gitignore`** — shared global ignore patterns.
- **`rheaditi.gitconfig`** — Aditi's Git identity configuration, selected by
  the default profile. Forks should replace it with their own committed file.
- **`local.gitconfig`** — tracked mutable local wrapper created and updated by
  setup. Review tool-managed changes before deciding whether to commit them.
- **`user.gitconfig`** — ignored link to `DOTFILES_USER_GITCONFIG`.
- **`private.gitconfig`** — ignored link to `DOTFILES_PRIVATE_GITCONFIG`.
- **`../rheaditi.env`** — Aditi's default committed user profile. Forks should
  replace it with their own committed profile.
- **`../local.env`** — optional, ignored machine-specific overrides.

## Configure before setup

This repository has exactly one committed user profile in `configs/*.env`.
Before running setup from a fork or clone, replace Aditi's profile and Git
identity configuration with your own:

```sh
# Replace the committed user profile.
cp configs/rheaditi.env configs/<username>.env
rm configs/rheaditi.env

# Replace the configured user Git identity file.
cp configs/git/rheaditi.gitconfig configs/git/<username>.gitconfig
rm configs/git/rheaditi.gitconfig
```

In `configs/<username>.env`, set the path to your replacement identity config:

```sh
DOTFILES_USER_GITCONFIG="$DOTFILES_ROOT/configs/git/<username>.gitconfig"
```

Update `configs/git/<username>.gitconfig` with your name, email, signing key,
and GitHub username, then commit both replacement files. Setup fails when it
finds zero or multiple committed user profiles, preventing accidental use of an
ambiguous identity configuration.

For an additional machine-specific work Git config, create the ignored
`configs/local.env` file:

```sh
DOTFILES_PRIVATE_GITCONFIG="$HOME/src/my-private-dotfiles/git/work.gitconfig"
```

`configs/local.env` overrides values from the committed profile and must not
contain credentials. To omit an optional Git config, set its variable to an
empty value.

## Environment Behavior

### 🏠 Local Environment

Setup links global Git configuration to an ignored mutable file in this
repository:

```text
~/.gitconfig
  -> <dotfiles>/configs/git/local.gitconfig
```

The local wrapper uses absolute paths to its managed includes:

```text
┌──────────────────────────────────────────────────────────────────┐
│ <dotfiles>/configs/git/local.gitconfig                            │
├──────────────────────────────────────────────────────────────────┤
│ [include]                                                         │
│     path = <dotfiles>/configs/git/base.gitconfig                  │ ← Always
│                                                                    │
│ [include]                                                         │
│     path = <dotfiles>/configs/git/private.gitconfig               │ ← Always; empty when unset
│                                                                    │
│ [includeIf "gitdir:~/dev/personal/"]                             │
│     path = <dotfiles>/configs/git/user.gitconfig                  │ ← Personal directories
│                                                                    │
│ [includeIf "gitdir:~/dev/dotfiles/"]                             │
│     path = <dotfiles>/configs/git/user.gitconfig                  │ ← Dotfiles directories
│                                                                    │
│ [includeIf "gitdir:~/dev/dotfiles-private/"]                     │
│     path = <dotfiles>/configs/git/user.gitconfig                  │ ← Private dotfiles directories
└──────────────────────────────────────────────────────────────────┘
```

`local.gitconfig` is tracked intentionally: tool-managed settings, such as Git
tracing or external tooling state, show up in `git diff` for review. Keep an
unwanted automatic change uncommitted; commit it only when it belongs in the
shared wrapper configuration.

`user.gitconfig` and `private.gitconfig` are ignored generated links to the
paths configured by the user profile. Setup refreshes only the managed includes
in `local.gitconfig` and preserves all other settings.

### 🐳 Devbox Environment

Setup preserves the devbox-managed `~/.gitconfig` and appends only the tracked
base include. It does not install the local wrapper or user/private Git config
links:

```text
┌──────────────────────────────────────────────────────────────────┐
│ ~/.gitconfig (Devbox)                                             │
├──────────────────────────────────────────────────────────────────┤
│ [existing configuration...]                                       │ ← Preserved
│                                                                    │
│ [include]                                                         │
│     path = <dotfiles>/configs/git/base.gitconfig                  │ ← Added
└──────────────────────────────────────────────────────────────────┘
```

## Usage

```sh
./scripts/setup.git.sh
```

## Verification

```sh
# Show all configuration sources.
git --no-pager config --list --show-origin

# Check the resolved identity.
git config user.name
git config user.email
```
