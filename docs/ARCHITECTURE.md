# Architecture

> **As-built reference** for how this dotfiles repo is wired. For the evolving
> roadmap and rationale, see [`ai-native-plan.md`](./ai-native-plan.md). For
> first-time / fresh-machine instructions, see [`SETUP.md`](./SETUP.md).

## Guiding philosophy

This repo follows the **"spilled coffee" principle**: you should be able to
destroy your machine and be fully operational again the same afternoon. In
practice that means:

- All configuration is **reproducible** across machines.
- Setup scripts handle file operations (symlinks, dirs) — never manual steps.
- Installers **detect and create** what they need, and are **idempotent**
  (safe to re-run; they install only what's missing).
- We bias toward **global** configuration ("should this apply everywhere I
  code?") and keep repo-specific behavior documented here.

---

## Two-tier setup

The repo separates **configuration** from **installation** into two entrypoints.

| Tier | Entrypoint | What it does | Installs tools? | Prompts? |
|------|-----------|--------------|-----------------|----------|
| 1 | `setup.sh` | Symlinks + config only | No | Never |
| 2 | `bootstrap.sh` | Installs tooling, **then runs `setup.sh`** | Yes | Yes (interactive) |

### Tier 1 — `setup.sh` (quick, idempotent, no installs)

Safe to run any time. Applies configuration by symlinking repo files into
`$HOME`. Steps, in order:

1. **zsh** (`scripts/setup.zsh.sh`)
2. **git** (`scripts/setup.git.sh`)
3. **ssh** (`scripts/setup.ssh.sh`)
4. **editor / VS Code** (`scripts/setup.editor.sh`)
5. **terminal / cmux + ghostty** (`scripts/setup.terminal.sh`)
6. **AGENTS.md context** (`scripts/setup.agents.sh`)

### Tier 2 — `bootstrap.sh` (full provisioning, interactive)

The fresh-machine path. It **installs** tooling, then delegates **all**
configuration to `setup.sh` (so bootstrap is a strict superset of the quick
path — no duplicated config logic). Flow:

1. **Homebrew + packages** (`scripts/setup.brew.sh`) — *macOS only; skipped on Linux*
2. **Node.js** (`scripts/setup.node.sh`) — nvm + Node + corepack/yarn
3. **Apply configuration** — delegates to `setup.sh` (all 6 tier-1 steps)
4. **VS Code extensions** (`scripts/setup.vscode-extensions.sh`) — only if the
   `code` CLI is available; otherwise it logs a hint to run the stage later.

In unattended runs (`NONINTERACTIVE=1` or no TTY) each step auto-proceeds.

```
bootstrap.sh ── installs ──> brew ─> node
     │
     └── delegates config ──> setup.sh ─> zsh ─> git ─> ssh ─> editor ─> terminal ─> agents
                                   (then) ──> vscode extensions (if `code` present)
```

---

## Repository layout

```
.
├── bootstrap.sh            # Tier 2: install tooling, then run setup.sh
├── setup.sh                # Tier 1: symlink/config only (idempotent)
├── configs/                # Source of truth for all configuration
│   ├── agents/             # Composable AGENTS.md fragments + build output
│   ├── cmux/               # cmux terminal config
│   ├── ghostty/            # ghostty (cmux's renderer) config
│   ├── git/                # base/local/identity gitconfigs + global ignore
│   ├── ssh/                # ssh client config
│   ├── vscode/             # settings.json + extensions.txt
│   └── zsh/                # dotzshrc + modular zshrc.*.sh fragments
├── scripts/
│   ├── setup.<area>.sh     # orchestrators (one per area)
│   ├── <area>/             # the per-area "do the work" sub-scripts
│   └── utils/              # shared shell helpers (sourced, not run)
└── docs/
    ├── ARCHITECTURE.md     # this file (as-built reference)
    ├── SETUP.md            # fresh-machine runbook
    └── ai-native-plan.md   # evolving roadmap / rationale
```

**Convention for adding a component:** create `scripts/setup.<area>.sh`
(orchestrator) that calls `scripts/<area>/...` (the worker), put the config
under `configs/<area>/`, and wire the orchestrator into `setup.sh`. Each config
dir carries its own `README.md`.

---

## Public / private subtree model

This is the most subtle part of the repo — read carefully before touching
private paths.

There are **two** repos:

- **Public** (this repo) → lives at `~/dev/dotfiles`.
- **Private** → an Atlassian-internal repo whose content lives in an
  **`atlassian/` subtree**.

The two environments lay these out **differently**:

| | Local machine | Devbox / RDE |
|---|---|---|
| Public dotfiles | `~/dev/dotfiles` | `~/dev/dotfiles` |
| Private repo root | `~/dev/dotfiles-private` | `~/dotfiles` |
| Private **content** dir | `~/dev/dotfiles-private/`**`atlassian`** | `~/dotfiles` |

Why the difference: on a **devbox**, only the `atlassian/` **subtree** is
cloned — directly (flat) into `~/dotfiles`. So on devbox the repo root *is* the
content dir; locally the content is nested one level under `atlassian/`. The
private repo's own setup is what clones the public repo to `~/dev/dotfiles`.

```
LOCAL                                  DEVBOX / RDE
~/dev/dotfiles            (public)     ~/dev/dotfiles        (public)
~/dev/dotfiles-private/   (root)       ~/dotfiles/           (root == content,
        atlassian/        (content)                            atlassian subtree)
```

> ⚠️ Because of this split, **never hardcode the private path**. Always derive
> it from `scripts/utils/paths.sh` (see below). Several bugs have come from
> hardcoding `.../atlassian/...`, which silently breaks on devbox.

---

## Path contract — `scripts/utils/paths.sh`

This file is the **single source of truth** for dotfiles locations. Source it;
don't redefine these anywhere.

| Variable | Meaning | Local | Devbox |
|---|---|---|---|
| `DIR_DEV` | dev root | `~/dev` | `~/dev` |
| `DIR_DOTFILES` | public repo | `~/dev/dotfiles` | `~/dev/dotfiles` |
| `DIR_DOTFILES_PRIVATE_ROOT` | private repo **root** | `~/dev/dotfiles-private` | `~/dotfiles` |
| `DIR_DOTFILES_PRIVATE` | private **content** dir (use this for tooling) | `~/dev/dotfiles-private/atlassian` | `~/dotfiles` |

- Use **`DIR_DOTFILES_PRIVATE`** when reading content (agents sources, the
  private gitconfig, the private zsh `entry.sh`, Rovo `config.yml`/`mcp.json`).
- Use **`DIR_DOTFILES_PRIVATE_ROOT`** only when you mean the repo root (e.g. the
  `edit-dotfiles-private` editor alias).

Environment selection keys off `REMOTE_DEV_ENV` (see detection below).

Consumers that source `paths.sh`: `scripts/agents/build-agents.sh`,
`scripts/setup.agents.sh`, `scripts/git/setup-git-config.sh`,
`configs/zsh/zshrc.alias.sh`, `configs/zsh/zshrc.private.sh`.

---

## Environment detection — `scripts/utils/environment.sh`

Shared, sourced by both setup scripts and the zsh runtime (so it must be
**zsh-and-bash compatible**). Public helpers:

| Function | True when |
|---|---|
| `is-macos` | `$OSTYPE` is darwin |
| `is-linux` | `$OSTYPE` is linux |
| `is-remote-dev-env` / `is-devbox` | `$REMOTE_DEV_ENV` is set (devbox/RDE) |
| `is-local` | **not** a devbox |
| `is-wsl` | running under WSL |
| `is-interactive` | a TTY is attached **and** `NONINTERACTIVE` is unset |
| `detect-platform` | echoes `macos` / `linux` / ... |
| `detect-environment` | echoes `local` / `devbox` / ... |

> Note: `environment.sh` is the **only** home for OS detection. It absorbed the
> former `common/utils/platform-detection.sh` (now deleted) to remove
> duplication.

---

## Secrets — macOS Keychain

Keychain-backed secrets are **Atlassian-specific**, so they live entirely in the
**private** repo (`zsh/secrets.sh`), sourced via `zshrc.private.sh` → the private
`entry.sh`. The public repo defines no keychain logic, so a public-only checkout
has no secrets wiring and prints no warnings.

The private `secrets.sh` is self-contained (it detects macOS inline rather than
depending on `environment.sh`, since it also runs on Linux devboxes where it's a
no-op). It reads each item via a `keychain_export` helper and, if any are
missing, prints a single throttled warning (about once a day) listing what to
add rather than failing the shell.

See the private repo for the list of items and the env vars they populate.

