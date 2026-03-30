# Git Configuration

Environment-aware git configuration using git's native `[include]` and `[includeIf]`
directives. There is no monolithic `~/.gitconfig` — instead a thin root config
includes the right pieces based on where you are.

## Files

| File | Repo | Purpose |
|------|------|---------|
| `base.gitconfig` | public | Aliases, colors, diff/merge settings — everything that is not identity-specific |
| `rheaditi.gitconfig` | public | Personal identity (name, email, GitHub user, signing key) — applied only to personal directories |
| `atlassian/git/*.gitconfig` | private | Work identity and company-specific settings |
| `gitconfig.local` | public (template) | Template for `~/.gitconfig` on a local machine — written by `setup.git.sh` |
| `gitconfig.devbox` | public (template) | Snippet appended to an existing `~/.gitconfig` on a devbox — written by `setup.git.sh` |

## How it works

### Local environment

`setup.git.sh` creates a new `~/.gitconfig` from the `gitconfig.local` template:

```
~/.gitconfig
├── [include] base.gitconfig           ← always applied
├── [include] atlassian/.gitconfig     ← always applied (work identity, private)
├── [includeIf "gitdir:~/dev/personal/"] rheaditi.gitconfig  ← personal dirs only
└── [includeIf "gitdir:~/dev/dotfiles/"] rheaditi.gitconfig  ← dotfiles dirs only
```

The `includeIf "gitdir:..."` rules mean that `rheaditi.gitconfig` (personal email /
GitHub handle) is **only active inside personal project directories**. Any other
directory (e.g. work repos) picks up the work identity from the private config
instead.

### Devbox environment

Devboxes already have a `~/.gitconfig` managed by the company (e.g. pre-populated
via cloud-init). `setup.git.sh` **appends** the `gitconfig.devbox` snippet to the
existing file rather than replacing it, so the company config is preserved and
`base.gitconfig` is layered on top.

```
~/.gitconfig
├── [existing company configuration...]   ← preserved
└── [include] base.gitconfig              ← appended
```

## Verification

```bash
# Check all config sources and where each value comes from
git --no-pager config --list --show-origin

# Check specific values
git config user.name
git config user.email
```
