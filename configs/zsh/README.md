# Zsh Configuration

Modular zsh setup. `dotzshrc` is symlinked to `~/.zshrc` by
`scripts/setup.zsh.sh`; it sources the focused `zshrc.*.sh` fragments in order.

## Files

- **`dotzshrc`** — entrypoint (`~/.zshrc`). Resolves paths, sources everything.
- **`zshrc.ohmyzsh.sh`** — oh-my-zsh options.
- **`zshrc.prompt.sh`** — prompt (Pure), activated after oh-my-zsh.
- **`zshrc.platform.sh`** — platform-shared settings.
- **`zshrc.macos.sh`** / **`zshrc.linux.sh`** — OS-specific settings.
- **`zshrc.alias.sh`** — aliases; sources `scripts/utils/paths.sh` for the
  canonical dotfiles path vars (`DIR_DOTFILES`, `DIR_DOTFILES_PRIVATE[_ROOT]`).
- **`zshrc.functions.sh`** — shell functions.
- **`zshrc.private.sh`** — sources the private repo's `entry.sh` if present
  (resolved via `DIR_DOTFILES_PRIVATE`, so it works on local **and** devbox).

## Load order (`dotzshrc`)

1. Resolve `DOTFILES_ROOT` (following the symlink) and source
   `scripts/utils/environment.sh` for `is-macos` / `is-linux` / `is-devbox`.
2. `PATH` setup.
3. oh-my-zsh → prompt.
4. Platform config → OS-specific config.
5. Aliases → functions.
6. Private config (`zshrc.private.sh`) + optional AFM bin-path manager.
7. **Keychain secrets** (macOS only).

## Keychain secrets (macOS)

The final block reads tokens from the macOS Keychain into env vars via a
`keychain_export` helper. Missing items produce a **single, once-per-day**
warning (with the exact `add-generic-password` command) instead of failing the
shell or spamming every startup. Silent on non-macOS.

| Keychain item | Env var(s) |
|---|---|
| `signalfx_auth_token` | `TF_VAR_signalfx_auth_token`, `SIGNALFX_API_TOKEN` |
| `ops_sherpa_atlassian_token` | `ATLASSIAN_API_TOKEN` |
| `bitbucket_token` | `BITBUCKET_TOKEN` |
| `opsj_token` | `OPS_JIRA_TOKEN` |

See [`docs/SETUP.md`](../../docs/SETUP.md#4-populate-keychain-secrets-macos-optional)
for how to populate them.

## Notes

- Fragments are sourced in a fixed order (not auto-globbed) because order
  matters (e.g. prompt must come after oh-my-zsh).
- Detection helpers come from `scripts/utils/environment.sh` — don't redefine
  `is-*` functions here.
