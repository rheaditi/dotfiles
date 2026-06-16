# SSH Configuration

SSH client config symlinked to `~/.ssh/config` by `scripts/setup.ssh.sh`.

## Files

- **`config`** — the SSH client config (identity routing + includes).

## Identity routing

Keys are selected **per host**, so the right identity is used automatically:

| Host pattern | Identity file | Used for |
|---|---|---|
| `github.com` | `~/.ssh/id_ed25519_personal` | Personal repos (incl. these dotfiles) |
| `bitbucket.org` | `~/.ssh/id_ed25519_atlassian` | Atlassian work |
| `*` (default) | `~/.ssh/id_ed25519_atlassian` | Everything else |

All hosts use `AddKeysToAgent yes` and `UseKeychain yes` so passphrases are
stored in the macOS Keychain.

## Notes

- **`UseKeychain` is Apple-specific.** It only works with Apple's bundled
  `/usr/bin/ssh`. If a Homebrew `openssh` shadows it on `PATH`, you'll get
  `Bad configuration option: usekeychain`. Fix: `brew uninstall openssh` so
  `/usr/bin/ssh` wins (`which -a ssh` to check).
- **Devbox/RDE is skipped.** `scripts/setup.ssh.sh` does **not** symlink on a
  devbox — those are configured manually with machine-specific settings.
- The `Include` lines pull in machine-managed fragments (devbox, port-forward,
  DNS, dev-env) that live outside this repo.
