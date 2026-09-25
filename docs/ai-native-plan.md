# AI-native dotfiles plan

A plan to evolve this repo for the AI-native era while keeping workstation
setup dead simple and fast. Heavily inspired by
[atxtechbro/dotfiles](https://github.com/atxtechbro/dotfiles) but deliberately
pared down — borrowing philosophies, not infrastructure.

> 📖 This is the evolving **roadmap**. For as-built reference (how the repo is
> wired today) see [`ARCHITECTURE.md`](./ARCHITECTURE.md); for fresh-machine
> setup see [`SETUP.md`](./SETUP.md).

> Status: **draft**. Each phase below is independently shippable and
> independently revertible. Nothing here is "all-or-nothing". When in doubt,
> ship the smaller version.

---

## 1. Why now

The current repo is already well-architected for a 2022-era macOS + zsh +
git setup: modular sourcing, conditional gitconfig includes, public/private
split, three-context awareness (macOS-personal, macOS-work, Atlassian
devbox). What it does **not** yet do:

- Treat the editor (Cursor) as a first-class config target. Cursor settings,
  rules, skills, hooks, and MCP config live entirely on the machine today
  and are lost on a wipe.
- Capture GUI-app preference drift automatically (VS Code `settings.json`,
  Cursor `settings.json` drift without symlinks; terminal config too once
  cmux lands — iTerm is now legacy, see §5.2.2).
- Match the README. `README.md` claims `setup.sh` installs Homebrew,
  Node.js, macOS prefs, and VS Code — none of that is true today; those
  scripts live in `old/` and are not wired in.

The goal of this plan: close those three gaps **without** turning the repo
into a 100-script harness.

---

## 2. Principles we're adopting

These four guide every decision below. They're listed in priority order:
when they conflict, the earlier one wins.

### 2.1 Spilled Coffee Principle
A new MacBook should reach "fully productive" in one command and one
afternoon. No tribal knowledge, no terminal heroics, no "oh you also need
to…". Adapted from atxtechbro.

### 2.2 Brent Test
Every state-changing terminal command should live in a script, not in
shell history. If only the author can reproduce it, the system has a
bus-factor of 1. Adapted from atxtechbro / *The Phoenix Project*.

### 2.3 Extend, not replace
When integrating with an app's config, prefer mechanisms that **extend**
the app's own config (sourcing, `[include]`, `PreferencesCustomFolder`,
appended snippets) over wholesale **replacement** (full-file symlinks).
This survives:

- Tool installers that append to `~/.zshrc` (nvm, conda, rustup).
- Apps that atomically rewrite their preferences file and break symlinks.
- App updates that introduce new keys you don't want to fight.

The existing `~/.zshrc` stub-that-sources pattern and the git
`[include]`-chain for `local.gitconfig` are already perfect examples.
Default to that pattern; fall back to direct symlink only when the app
provides no extension point; fall back to a resync script only when the
app actively rewrites the symlink (the "pesky tools" case).

### 2.4 80/20 — momentum over polish
Borrowed from atxtechbro: *"don't get so engrossed in system optimization
that you lose momentum on core work."* This document is itself 20% work.
Each phase below should be < 1 sitting; if a phase grows beyond that,
split it.

---

## 3. Two-tier setup model

> **Status: shipped.** ✅ The two-tier split below is implemented. This
> section is now the as-built reference for it. (The original draft named
> the slow path `bootstrap-macos.sh`; it shipped as `bootstrap.sh`.)

A single `./setup.sh` used to try to be everything and was therefore stale.
It's split cleanly into two entrypoints with a deliberate separation of
concerns:

| Tier | Entrypoint     | Purpose                              | Installs tools? | Prompts? |
|------|----------------|--------------------------------------|-----------------|----------|
| 1    | `setup.sh`     | Apply configuration (symlinks)       | No              | No       |
| 2    | `bootstrap.sh` | Full provisioning of a fresh machine | Yes             | Yes\*    |

\* `bootstrap.sh` confirms each install step in an interactive session, and
auto-proceeds when run unattended (`NONINTERACTIVE=1` or no TTY).

**`bootstrap.sh` is a strict superset of `setup.sh`** — it runs the
installers, then calls `setup.sh` for the symlink/config work. This keeps the
config logic in exactly one place (DRY).

**Cross-platform.** `bootstrap.sh` detects the OS up front (via `$OSTYPE`,
see `is-macos`/`is-linux` in `scripts/utils/environment.sh`). macOS-only steps
(Homebrew) are skipped on other systems with a clear log; cross-platform steps
(Node.js, all config) still run everywhere — so the same command works on a
macOS laptop and a Linux remote-dev box.

```
bootstrap.sh ──► setup.brew.sh ──► brew/Brewfile
            ├──► setup.node.sh ──► node/install-node.sh (nvm, node LTS, yarn)
            └──► setup.sh ───────► setup.zsh.sh
                                   setup.git.sh
                                   setup.ssh.sh
```

### When to use which

- **Daily / after `git pull`:** `./setup.sh` — fast, no installs, idempotent.
  Target runtime: < 30 seconds.
- **New machine / full reinstall:** `./bootstrap.sh` — installs everything,
  then applies config. Run ONCE on a brand-new box.
- **Unattended:** `NONINTERACTIVE=1 ./bootstrap.sh` — installs all, no
  prompts.

### Directory layout (as built)

```
.
├── setup.sh                  # Tier 1: config-only entrypoint
├── bootstrap.sh              # Tier 2: full provisioning entrypoint
├── configs/                  # Source-of-truth config files (symlink targets)
│   ├── git/
│   ├── ssh/                  # ssh/config -> ~/.ssh/config
│   └── zsh/
├── scripts/
│   ├── setup.zsh.sh          # Tier 1 orchestrators (config)
│   ├── setup.git.sh
│   ├── setup.ssh.sh
│   ├── setup.brew.sh         # Tier 2 orchestrators (install)
│   ├── setup.node.sh
│   ├── brew/Brewfile         # Declarative Homebrew package list
│   ├── node/install-node.sh  # Node.js install logic
│   ├── git/ ssh/ zsh/        # Per-domain sub-scripts
│   └── utils/                # Shared helpers (sourced, not executed)
│       ├── logging.sh        # log-info / log-success / log-step / ...
│       ├── environment.sh    # is-macos / is-linux / is-interactive / ...
│       ├── interactive.sh    # confirm-step / run-if-confirmed
│       ├── file-operations.sh# backup-file / symlink helpers
│       └── package-manager.sh# cross-platform install-package
└── docs/ai-native-plan.md    # this file
```

### Conventions for adding a new component

To add a new tool (e.g. `foo`):

1. Put its config under `configs/foo/`.
2. **Config (Tier 1):** add `scripts/foo/setup-foo-config.sh` (does the work)
   and `scripts/setup.foo.sh` (orchestrator), then wire the orchestrator into
   `setup.sh`.
3. **Install (Tier 2):** if it needs installing, add `scripts/setup.foo.sh`
   guarded by `confirm-step`/`run-if-confirmed`, then wire it into
   `bootstrap.sh`.
4. Make scripts executable (`chmod +x`).
5. Always source helpers from `scripts/utils/` rather than duplicating logic.
6. Update the README table and this document.

### Shared utilities reference

- **`logging.sh`** — consistent, colorized output: `log-info`, `log-success`,
  `log-warning`, `log-error`, `log-step`, `log-already-exists`.
- **`environment.sh`** — `is-macos`, `is-linux`, `is-remote-dev-env`,
  `is-interactive` (false when `NONINTERACTIVE=1` or there's no TTY).
- **`interactive.sh`** — `confirm-step "<task>" "<prompt>"` (auto-proceeds when
  non-interactive) and `run-if-confirmed "<task>" "<prompt>" <cmd...>`.
- **`file-operations.sh`** — `backup-file` (timestamped backups before
  overwriting).
- **`package-manager.sh`** — `detect-package-manager`, `install-package`,
  `is-package-installed`, `update-package-manager` (brew/apt/yum/pacman).

The `old/scripts/setup.brew.sh`, `setup.macos.sh`, `setup.nodejs.sh` were the
starting bodies for the Tier-2 installers (brew + node shipped; macOS defaults
still pending — see Phase 5.4).

---

## 4. Current-state honesty pass (before any new work)

Issues to fix before adding new features. These are the README/code-drift
items that will mislead future-me (or anyone else following the README).

| # | Item | Action |
|---|------|--------|
| 4.1 | ✅ **Done.** `README.md` rewritten to describe the **two-tier** model (§3): `setup.sh` (config) vs `bootstrap.sh` (install + config). | — |
| 4.2 | ✅ **Done.** `scripts/setup.editor.sh` was rebuilt as a real symlink-installer (`scripts/editor/setup-vscode.sh`); no dangling references remain. | — |
| 4.3 | ✅ **Done.** `old/` deleted (git history preserves the original "v1" scripts/configs). | — |
| 4.4 | Top-level `.eslintignore`, `.prettierrc.js`, `.editorconfig`, `.vimrc` (10 bytes), `.gitignore` (14 bytes) — these are repo-meta, not env config. They're fine to keep but unrelated to the dotfiles role of the repo. | No action; just note for context. |

---

## 5. Phases (the actual work)

Each phase is shippable on its own. Order matters only weakly: 5.1 → 5.2
is the most testable progression.

### Phase 5.1 — Cleanup / honesty pass

Goal: zero stale claims in the repo. No new features.

- Rewrite `README.md` to describe the two-tier setup model.
- Decide on `old/`: archive or delete. (Suggest archive with a one-line
  README pointing at git log for the original "v1" history.)
- Delete or finish `scripts/setup.editor.sh`. Suggest delete now,
  rebuild cleanly in Phase 5.2 with the symlink + sync approach.
- Commit the existing uncommitted drift (`configs/zsh/dotzshrc`,
  `configs/zsh/zshrc.alias.sh`, `legacy/iterm/com.googlecode.iterm2.plist`,
  `configs/vscode/settings.json`) so the repo starts from a clean baseline.
  Note: the `signalfx_auth_token` keychain export currently in
  `dotzshrc` is work-specific — that line should move to the private
  repo's `entry.sh` before commit.

**Verification:** `git status` is clean. README's "Installation" section
describes only what `setup.sh` actually does. Re-running `./setup.sh`
on this machine still no-ops (idempotency check).

**Rollback:** trivial — single commit, revertible.

---

### Phase 5.2 — Editor + terminal symlink layer ("extend, not replace")

Goal: every GUI-driven config change lands in the repo automatically.
Zero manual copy-paste. Survives app updates.

> Terminal note: the original plan targeted iTerm here. We're moving to
> **cmux**. The terminal sub-phase (§5.2.2) is now **shipped** — Ghostty +
> cmux configs are symlinked via `scripts/setup.terminal.sh`. The editor work
> (§5.2.1) is unaffected.

#### 5.2.1 — Editor and agent-tool leaf-file config

> **Status: VS Code shipped.** ✅ `configs/vscode/{settings.json,keybindings.json}`
> are symlinked into the VS Code User dir by `scripts/setup.editor.sh` →
> `scripts/editor/setup-vscode.sh` (wired into `setup.sh`). The full live
> settings were merged into `configs/vscode/settings.json` (live values win;
> base-only keys added). **Extensions** are managed declaratively in
> `configs/vscode/extensions.txt` and installed by a separate stage,
> `scripts/setup.vscode-extensions.sh` → `scripts/editor/install-vscode-extensions.sh`
> (kept out of the config tier because the `code` CLI isn't present on a fresh
> machine; `bootstrap.sh` runs it only if `code` is on `PATH`, else suggests it).
> Cursor and Rovo Dev CLI below remain **pending**.

Same approach across three apps, because they all store a single
top-level config file alongside a directory of runtime state:

| App | Source-of-truth file | Real location |
|---|---|---|
| VS Code | `settings.json`, `keybindings.json` | `~/Library/Application Support/Code/User/` |
| Cursor | `settings.json`, `keybindings.json` | `~/Library/Application Support/Cursor/User/` |
| Rovo CLI | `config.yml`, `mcp.json` | `~/.rovo/` |

The Cursor and VS Code directories also contain `globalStorage/`,
`workspaceStorage/`, `History/`, `snippets/` — runtime state we never
want to track. The Rovo directory similarly contains `sessions/`,
`logs/`, `prompt_history`, `event_hooks.log`, `config.yml.lock`,
`backup.config.yml` — all runtime/auto-managed, never track.

**Approach:** symlink only the leaf files, not the parent directory.
All three apps preserve symlinks across their atomic writes in
practice. (If any of them ever breaks this — see "pesky tool"
fallback below.)

Repo layout:

```
configs/
  vscode/
    settings.json
    keybindings.json
  cursor/
    settings.json
    keybindings.json
  rovo/
    config.yml
```

(✅ Done for VS Code: `vscode/settings.json` + `vscode/keybindings.json`
moved under `configs/vscode/`. Cursor/Rovo still to move.)

Setup script: ✅ `scripts/setup.editor.sh` is now a real symlink-installer
(VS Code only today). It may grow to handle Cursor/Rovo too — consider
renaming to `setup.tools.sh` or `setup.app-configs.sh` if/when it does.

**Secrets check before committing `rovo/config.yml`:** Rovo's
`config.yml` may carry tokens, API keys, or workspace identifiers.
Audit the current file once, redact anything sensitive into the
private repo or the system keychain (following the pattern of the
`signalfx_auth_token` keychain read in `dotzshrc`), and only then
commit. If too much of it is per-machine state to share publicly,
the alternative is to keep `config.yml` in the **private** repo and
symlink from there instead.

**The "pesky tool" fallback:** if any of these apps atomic-writes
through the symlink (turning the link into a regular file), the resync
script `scripts/sync-prefs.sh` re-establishes it. Run manually when
something feels off; not on a hook (per Q4 answer: explicit > implicit).

#### 5.2.2 — Terminal config: cmux + Ghostty (shipped ✅)

> **Status: cmux/Ghostty shipped.** ✅ cmux is built on libghostty and reads
> `~/.config/ghostty/config` for theme/font/colors; cmux's own app settings
> live in `~/.config/cmux/cmux.json`. Both are now symlinked from
> `configs/ghostty/config` and `configs/cmux/cmux.json` by
> `scripts/setup.terminal.sh` → `scripts/terminal/setup-terminal-config.sh`
> (wired into `setup.sh`). Theme is set via the `theme =` line (this repo uses
> adaptive `dark:Ayu Mirage,light:Ayu Light`). See `configs/cmux/README.md`.

> **iTerm2 (retired).** We moved to **cmux**, so the old iTerm2 config
> (`com.googlecode.iterm2.plist`, color schemes) was **removed** from the repo.
> It's preserved in git history if any preference (color theme, font, key
> behaviors) is ever worth porting to a cmux/Ghostty equivalent.

#### 5.2.3 — Resync script (the "pesky tool" safety net)

`scripts/sync-prefs.sh`. Manually invoked. Does the
*reconciliation*: for each tracked config file, checks whether the
symlink/include is still in place, and re-establishes it if not.
Reports what it changed. **Does not** copy GUI-side changes back into
the repo — that's what symlink/`PrefsCustomFolder` are for. This
script only fixes the *plumbing*, not the *content*.

**Verification:** unlink a tracked file manually, run `sync-prefs.sh`,
confirm the link is restored.

---

### Phase 5.3 — Shared AGENTS.md system (the AI-native core)

> **Status: shipped (Rovo).** ✅ Modular `.md` fragments under
> `configs/agents/sources/` (+ a private overlay at
> `$DIR_DOTFILES_PRIVATE/agents/sources/`) are composed by
> `scripts/agents/build-agents.sh` into `configs/agents/build/rovo.md`
> (gitignored) and symlinked to `~/.rovo/AGENTS.md` by
> `scripts/setup.agents.sh` (wired into `setup.sh`). The former hand-maintained
> agent memory was split: "Communication Style" → public
> `sources/30-communication.md`; Socrates + Pollinator → private sources.
> `--diff` previews source edits; build is idempotent/byte-stable. **Cursor**
> and **cmux** remain future targets (add a `TARGETS` entry + one symlink line).

The **highest-priority** AI-native deliverable. A single source of
truth for agent context — "how I work, what I expect, what I prefer" —
composed from modular fragments at setup time and installed into the
global location each tool reads.

Primary target: **Atlassian Rovo CLI** (daily driver, reads
`~/.rovo/AGENTS.md`).
Secondary target: **Cursor** (used alongside, must see the same
context).
Future target: **cmux** (agent multiplexer) — flagged so the design
accommodates it as a new case in the build script's target list when
the time comes.

#### 5.3.1 — Design constraints (from prior decisions)

- **Global, not per-project.** One file per tool, applied to every
  project. Per-project AGENTS.md is out of scope here (any individual
  repo can still commit its own; this system doesn't fight that).
- **Composed, not hand-merged.** Sources are modular `.md` fragments
  across public + private repos; a build script concatenates the
  fragments into per-tool output files. Generated files are
  gitignored — sources are the only thing humans edit.
- **Public + private overlay.** Public dotfiles hold tool-agnostic and
  generic content. Private dotfiles hold work/Atlassian-specific
  content. The build script merges both when the private repo is
  present and falls back gracefully when it isn't.
- **Tool-specific tweaks are small.** The bulk is shared. Per-tool
  files are short addenda (a few lines each), not parallel rewrites.
- **No content scoped by tool inside a single file.** If something is
  Rovo-only, it lives in the `rovo/` source dir — not as a
  `<!-- rovo-only -->` block in a shared file. Keeps the build trivial.

#### 5.3.2 — Repo layout

Public dotfiles:

```
configs/
  agents/
    sources/
      00-principles.md        # who I am as an engineer, top-of-context
      10-workflow.md          # PR / commit / review preferences
      20-style.md             # coding-style preferences
      30-communication.md     # tone, formatting, when to ask vs. act
      cursor/
        01-cursor-tweaks.md   # Cursor-specific addenda (small)
      rovo/
        01-rovo-tweaks.md     # Rovo-specific addenda (small)
    build/                    # generated; .gitignore'd
      base.md                 # tool-agnostic composite
      cursor.md               # base + cursor tweaks (+ private overlay)
      rovo.md                 # base + rovo tweaks (+ private overlay)
    .gitignore                # ignores build/

scripts/
  agents/
    build-agents.sh           # the composer
  setup.agents.sh             # build + symlink into each tool's location
```

Private dotfiles (parallel structure):

```
agents/                       # at the root of dotfiles-private
  sources/
    00-work-context.md        # who I work for, where the work lives
    10-work-conventions.md    # work-specific dos and don'ts
    rovo/
      01-rovo-work-tweaks.md  # Rovo + Atlassian-specific
    cursor/                   # optional, only if needed
      01-cursor-work-tweaks.md
```

Numeric prefixes (`00-`, `10-`, `20-`, …) give explicit, glob-sortable
ordering. Convention: 00–09 foundational, 10–29 workflow/conventions,
30+ stylistic / cosmetic, tool-specific dirs always sorted after
general content.

#### 5.3.3 — Build script behavior

`scripts/agents/build-agents.sh`:

For each target in `{base, cursor, rovo}`:

1. Collect public general sources: `configs/agents/sources/*.md`,
   sorted.
2. Collect public tool-specific sources (skip for `base`):
   `configs/agents/sources/<tool>/*.md`, sorted.
3. If `$DIR_DOTFILES_PRIVATE/agents/sources/` exists, collect private
   general sources, sorted.
4. If `$DIR_DOTFILES_PRIVATE/agents/sources/<tool>/` exists (and not
   `base`), collect private tool-specific sources, sorted.
5. Concatenate in collection order, with a configurable separator
   between fragments (default: blank line + `---` + blank line, so
   the seams are visible in the rendered file).
6. Write to `configs/agents/build/<tool>.md`.
7. Stderr a per-target summary: source count, byte count, final
   path. (Cheap CI-friendly trace.)

Idempotent: re-running with no source changes produces byte-identical
output (use `mtime`-stable concat, no timestamps in body).

`--diff` flag: rebuild into a temp dir and `diff` against current
`build/` so you can preview what a source edit will change before it
lands.

#### 5.3.4 — Setup wiring

`scripts/setup.agents.sh` (new):

1. Run `build-agents.sh` (always — fast).
2. Symlink each `build/<tool>.md` into its tool's global location:
   - **Rovo**: `~/.rovo/AGENTS.md` → `configs/agents/build/rovo.md`.
     Confirmed path. If `~/.rovo/` doesn't exist yet (e.g. fresh
     machine before Rovo is installed), create it.
   - **Cursor**: per the Cursor user-rules convention, symlink to
     `~/.cursor/rules/00-shared-agents.mdc`. If MDC frontmatter is
     required (`alwaysApply: true` or similar), the build script
     prepends it for the cursor target only. Exact frontmatter
     contract still TBD — flagged in §7.
   - **cmux** (future): when added, follow the same pattern — new
     target case in `build-agents.sh`, new symlink line here.
3. Wire into the main `setup.sh` so the symlinks get re-established
   on every setup run, not just first install.

#### 5.3.5 — Content-collection step (the actual writing)

Infrastructure first, content second. Once 5.3.1–5.3.4 are in place
and the symlinks are working with empty/placeholder source files, the
ongoing work is to **populate** the sources with real content. That's
an iterative interview process — not a one-shot — and happens
separately from the mechanism work. Initial seed: pull anything
already implicit in your shell aliases, repo-functions, gitconfig
preferences (e.g. `pull.rebase=true`, `rebase.autoStash=true`,
"clean-merged-branches" alias — these reveal preferences worth
codifying).

#### 5.3.6 — Verification

- `./scripts/agents/build-agents.sh` runs cleanly; outputs appear
  under `configs/agents/build/`.
- `./scripts/agents/build-agents.sh --diff` after editing
  `00-principles.md` shows the diff in every relevant target.
- Open a fresh project in Cursor, ask the agent a probe question
  (e.g. *"What are my commit-message preferences?"*). The answer
  should reflect the content in your sources.
- Run Rovo in the same project, same probe. Same answer.
- Delete `~/.cursor/rules/00-shared-agents.mdc` and the Rovo
  symlink; re-run `./setup.sh`; confirm both come back.

#### 5.3.7 — Rollback

`unlink` the two symlinks. Tools fall back to their built-in defaults.
All source content remains in the repo, undamaged. Re-run
`./setup.sh` to restore.

#### 5.3.8 — Known tradeoffs (called out so we don't pretend)

- **Generated files aren't in git.** PR review can't see the
  composite. Mitigation: `--diff` flag + a short "what's in each
  target" table in this doc as we add sources.
- **Build is at setup time, not every shell start.** Edit a source →
  must re-run `./setup.sh` (or `./scripts/agents/build-agents.sh`).
  An optional shell alias `rebuild-agents` keeps friction low.
- **Tools may diverge on context-loading semantics.** Cursor reads
  `.mdc` with frontmatter; Rovo reads plain `.md` (probably). The
  build script absorbs this asymmetry per-target. New target = new
  case in the script, not a new architecture.

---

### Phase 5.4 — `bootstrap.sh` (partially shipped)

Goal: a brand-new MacBook reaches "fully productive" in one command.
Shipped as `bootstrap.sh` (not `bootstrap-macos.sh` — see §3).

Scope, with current status:

- ✅ Homebrew bootstrap (`scripts/setup.brew.sh`).
- ✅ `scripts/brew/Brewfile` — single source of truth for installed
  packages/casks via `brew bundle`. Replaces the ad-hoc lists in
  `old/scripts/setup.brew.sh`.
- ✅ Node.js via `nvm` + LTS + yarn (`scripts/node/install-node.sh`).
- ✅ SSH config: symlink `configs/ssh/config` → `~/.ssh/config`
  (via `setup.sh` → `setup.ssh.sh`).
- ✅ Calls `./setup.sh` at the end for the fast-path config layer.
- ⬜ Xcode Command Line Tools (`xcode-select --install`) — **pending**;
  should become the first bootstrap step (macOS prerequisite).
- ⬜ macOS defaults (the `defaults write ...` block from
  `old/scripts/setup.macos.sh`). Audit for what's still relevant on
  current macOS. **Pending.**
- ⬜ Fonts (Fira Code, etc.) via brew cask — **pending**; fold into the
  Brewfile casks section.

**Idempotency requirement:** running `bootstrap.sh` twice in a row on a
healthy machine is a no-op. How each step achieves this:

- **Homebrew:** install is guarded by `command -v brew`; `brew update` runs
  *only* on a fresh install, so re-runs make no network calls for brew itself.
- **Brew packages:** `brew bundle` natively skips already-installed
  formulae/casks.
- **nvm:** guarded by the presence of `$NVM_DIR/nvm.sh`.
- **Node.js:** compares latest remote LTS against the installed LTS and skips
  if they match (re-running *after* a new LTS ships will upgrade, by design).
- **yarn:** guarded by `command -v yarn`.
- **Config:** delegated to `setup.sh`, which is already idempotent (symlink
  checks).

Verify per-step as the remaining items (Xcode CLT, macOS defaults, fonts) land.

**Out of scope (deliberately):** anything Atlassian-specific. Bootstrap
stays in the public repo and assumes no work-context.

---

### Phase 5.5 — Deferred: `$DOT_DEN`

Per Q5 answer, **not now**. Documented here so it doesn't get lost:

If we ever want multi-machine clone-location flexibility, introduce
`$DOT_DEN` (default `~/dev/dotfiles`) read from
`~/.bash_exports.local`. Replace hardcoded `~/dev/dotfiles` references
in:

- `configs/zsh/zshrc.alias.sh` (the `DIR_DOTFILES` variable)
- `configs/git/local.gitconfig` (`includeIf "gitdir:~/dev/dotfiles/"`)
- `scripts/git/setup-git-config.sh` (`PRIVATE_GITCONFIG` path)
- `setup.sh` / `bootstrap.sh`

Decision trigger: first time we want to clone this somewhere other
than `~/dev/dotfiles`. Until then, the simplicity is worth more than
the abstraction.

---

### Phase 5.6 — Deferred: deep AI-tool config sync

Explicitly deferred from the initial AI-native push. Phase 5.3 covers
the *content* shared across tools (AGENTS.md). Phase 5.2.1 covers each
tool's top-level *config file* (`settings.json`, `config.yml`). This
phase covers everything that's left: MCP server configs, hooks, skills,
CLI defaults, and the extra rules files.

#### Cursor leftovers

Cursor splits its config across two roots:

```
~/.cursor/                                            ← agent / CLI / skills config
  mcp.json                                            track later
  hooks.json                                          track later
  hooks/                                              track later (dir)
  skills-cursor/                                      track later (dir)
    <skill-name>/SKILL.md                             track later
    .cursor-managed-skills-manifest.json              never track (Cursor-managed)
    .sync-manifest.json                               never track (Cursor-managed)
  cli-config.json                                     track later
  rules/                                              partially covered by Phase 5.3
                                                      (00-shared-agents.mdc lives here)
  argv.json, ide_state.json, blocklist,
  unified_repo_list.json                              never track (runtime)
  extensions/, plugins/, projects/, snapshots/,
  plans/, ai-tracking/, feature-gates/                never track (runtime)

~/Library/Application Support/Cursor/User/            ← editor config
  settings.json                                       ✅ covered by Phase 5.2.1
  keybindings.json                                    ✅ covered by Phase 5.2.1
```

#### Rovo CLI leftovers

```
~/.rovo/
  AGENTS.md                                           ✅ covered by Phase 5.3
  config.yml                                          ✅ covered by Phase 5.2.1
  mcp.json                                            ✅ covered by Phase 5.2.1
  backup.config.yml                                   never track (Rovo-managed backup)
  config.yml.lock                                     never track (runtime lock)
  event_hooks.log                                     never track (runtime log)
  hooks/                                              track later (dir)
  logs/, sessions/, prompt_history                    never track (runtime)
```

#### What's left to track after 5.2 + 5.3

- `~/.cursor/mcp.json` (MCP server config — Rovo's `~/.rovo/mcp.json` is
  already tracked via Phase 5.2.1; the two are potentially symmetric content,
  a candidate for a shared source like Phase 5.3's pattern)
- `~/.cursor/hooks.json`, `~/.cursor/hooks/`, `~/.rovo/hooks/`
  (per-tool hook scripts — likely tool-specific, less reusable)
- `~/.cursor/skills-cursor/` (the skills library — portable IP, worth
  preserving across machines)
- `~/.cursor/cli-config.json` (Cursor CLI defaults)
- The rest of `~/.cursor/rules/*.mdc` (anything beyond the
  `00-shared-agents.mdc` installed in Phase 5.3)

When we pick this up:

- Same public/private split rule as everywhere else. Skills that
  reference any internal Atlassian system → private repo. Skills
  about Cursor/Rovo themselves or public OSS tools → public repo.
- Cursor skills dir needs a `.gitignore` for
  `.cursor-managed-skills-manifest.json` and `.sync-manifest.json`
  (Cursor rewrites those constantly).
- The existing `~/.cursor/hooks/aloc-managed/` subdir is auto-written
  by something — confirm before tracking the parent dir.
- MCP configs might warrant a Phase-5.3-style composition (shared
  source → per-tool output) if the same servers end up registered in
  both Cursor and Rovo. Decide at lift time.

No commitment on timing. Trigger: a real loss event (machine wipe,
new laptop, devbox restart) where the absence is felt, *or* a desire
to share the skills library across machines.

---

## 6. Out of scope (explicitly)

Borrowed from atxtechbro but **deliberately not** adopted:

- **OpenTelemetry / Grafana observability stack.** Overkill for a
  personal dotfiles repo.
- **Tmux + git worktrees parallel agent harness.** Only if/when the
  workflow actually demands parallel-agent execution.
- **Claude Code, Amazon Q, Codex multi-harness symmetry.** Cursor (+
  Rovo for work) is the harness we use; no need to abstract.
- **Slash-commands plugin marketplace.** Cursor-native skills already
  cover this need.
- **PPV ("Pillars / Pipelines / Vaults") directory taxonomy.** Our
  two-repo split is simpler and already serves the same purpose.
(See §9 for the `knowledge/` directory question — promoted out of
this list because it's a real open design decision, not a clear
"skip".)

---

## 7. Open questions / things to confirm later

Listed here so they don't get lost. None block Phase 5.1.

1. **Cursor user-rule MDC frontmatter contract.** For Phase 5.3 to
   install at `~/.cursor/rules/00-shared-agents.mdc` and have Cursor
   auto-apply it, we need to confirm the exact frontmatter (e.g.
   `alwaysApply: true` vs. `description: ...` vs. `globs: "*"`).
   Verify against current Cursor docs before writing the build
   script's MDC-prepend logic. **Blocks Phase 5.3b.**
2. **Rovo `config.yml` secrets audit.** Before this file gets
   committed (Phase 5.2.1), enumerate what's in it that's
   machine-specific, work-specific, or sensitive. Result determines
   whether the file lives in the **public** repo (clean enough),
   the **private** repo (sensitive but stable), or stays
   unsymlinked with only a redacted template tracked. **Blocks
   Phase 5.2.1 for Rovo.**
3. **`knowledge/` directory pattern — adopt or skip?** Open design
   question. Discussed in §9. Decision determines whether sources for
   Phase 5.3 live in `configs/agents/sources/` (current design,
   AI-only) or in `knowledge/` (atxtechbro-style, dual-purpose
   human-doc + AI-context).
4. **Rovo overlay overlap with Cursor.** If both tools end up
   reading byte-identical composed files (because the work-context is
   identical regardless of tool), we may want a single merged target
   instead of two separate composed files. Revisit after the first
   content pass — currently designed as two independent targets for
   safety.
5. **Public vs. private content interview.** Before Phase 5.3 reaches
   "useful", we need to actually decide what goes in `00-principles.md`,
   `10-workflow.md`, etc. Iterative conversation, not a one-shot.
   Out of scope for plan-doc; in scope for Phase 5.3c execution.
6. **`old/` disposition.** Delete vs. archive. (Tracked as item 4.3.)
7. **Atlassian devbox handoff.** Phase 5.2 (editor symlinks) and Phase
   5.3 (AGENTS.md) are largely macOS-local concerns, but Rovo on a
   devbox may want the same composed AGENTS.md. Confirm
   `is-devbox` short-circuits the *editor* symlinks while still
   running the AGENTS.md build + Rovo symlink.
8. **cmux integration.** When adopted, add a new `cmux` target to
   the build script and a new symlink in `setup.agents.sh`. The
   path cmux reads is TBD — confirm at adoption time. Same pattern
   as Rovo, additive change.
9. **Pre-existing hook subdir `~/.cursor/hooks/aloc-managed/`** —
   appears auto-managed by something. Relevant only when Phase 5.6
   lands; tracked here so it isn't forgotten.
10. **Brewfile generation.** Generate from current state (`brew bundle dump`)
    as Phase 5.4 starting point, or curate by hand from
    `old/scripts/setup.brew.sh`? (Probably: dump, then trim.)

---

## 8. Suggested execution order

Re-ordered to put the **AI-native core** (Phase 5.3, AGENTS.md) ahead
of broader symlink work, because (a) it's the user's stated top
priority, and (b) its dependencies — the editor symlinks for
`settings.json` — are the smallest slice of Phase 5.2 and can ride
alongside.

1. **Phase 5.1** (cleanup/honesty pass) — ship as one PR / commit.
   Low risk, high readability win. Unblocks everything below by
   committing current drift and getting the README honest.
2. **Phase 5.2.1** (editor `settings.json` + `keybindings.json`
   symlinks for VS Code and Cursor only) — the minimal slice. Skip
   5.2.2 (terminal) and 5.2.3 (sync-prefs) for now; they're useful
   polish but not on the AI-native critical path.
3. **Phase 5.3** (AGENTS.md system) — the headline. Split into
   testable sub-commits:
   - **5.3a**: scaffold the source dir, build script, and target
     paths with placeholder content. Verify build + symlinks work
     end-to-end with empty files.
   - **5.3b**: resolve the Cursor MDC frontmatter contract (open
     question #1) and decide on the `knowledge/` directory question
     (§9, open question #3). Update build script accordingly.
   - **5.3c**: first content pass — populate `00-principles.md`,
     `10-workflow.md`, `20-style.md`, `30-communication.md` from
     existing implicit knowledge (gitconfig, shell aliases,
     repo-functions, prior conversations). Ship even if rough.
   - **5.3d**: private overlay — mirror the structure in
     `dotfiles-private/agents/sources/` and verify the build
     correctly merges.
   - Each sub-commit is safely revertible; tools fall back to
     defaults if anything breaks.
4. **Phase 5.2.2 + 5.2.3** (terminal config + the `sync-prefs` script) —
   5.2.2 shipped (cmux + Ghostty); 5.2.3 (the `sync-prefs` script) can land
   independently when GUI-drift becomes a pain.
5. **Phase 5.4** (`bootstrap.sh`) — core shipped (brew/node/ssh);
   defer remaining items (Xcode CLT, macOS defaults, fonts) until next clean-OS
   install is actually planned, then build incrementally.
6. **Phase 5.5** (`$DOT_DEN`) — only when triggered.
7. **Phase 5.6** (deep AI-tool config sync — MCP, hooks, skills,
   etc., across Cursor and Rovo) — only when a real loss event
   makes the absence felt, or when sharing the skills library
   across machines becomes the actual need.

Each phase delivers value standalone, and the repo is in a coherent
state after every commit.

---

## 9. Design decision: `knowledge/` directory — adopt or skip?

This is the question raised in feedback on the first plan revision.
Documenting the framing here so the decision is auditable, then
calling it as a *recommendation* — the actual decision is yours.

### What atxtechbro's `knowledge/` directory actually is

In their repo, a top-level dir like:

```
knowledge/
  principles/
    snowball-method.md
    spilled-coffee.md
    throughput-definition.md
  procedures/
    tmux-git-worktrees-claude-code.md
    close-issue.md
  README.md
```

It serves **two purposes simultaneously**:

1. **AI-context integration.** Their Claude Code alias adds the
   directory to context: `claude --add-dir "$DOT_DEN/knowledge"`.
   Every agent invocation pulls every file in.
2. **Human-readable documentation.** Each file is a standalone essay
   a human can read and link to. Their README cites them directly
   (e.g. `[Snowball Method](knowledge/principles/snowball-method.md)`).

The directory is essentially a **personal engineering manifesto** that
doubles as AI fuel. They clearly enjoy writing engineering essays —
their README itself reads like one.

### How it differs from our current Phase 5.3 design

| | atxtechbro `knowledge/` | Our Phase 5.3 `configs/agents/sources/` |
|---|---|---|
| Storage shape | Directory of markdown files | Same |
| Audience | Human + AI (dual-purpose docs) | AI only (build inputs) |
| Tool integration | Tool reads the dir directly via flag (e.g. Claude `--add-dir`) | We compose a per-tool single-file output |
| Composition control | Tool decides what to pull when | We control exact order + content |
| Works with single-file tools (like Rovo) | No (tool must support directory loading) | Yes |
| Works with directory-aware tools (like Cursor `--add-dir`) | Yes | Yes (via the composed file) |
| Edits require rebuild | No (tool re-reads each invocation) | Yes (`./scripts/agents/build-agents.sh`) |
| Survives PR review | Yes (each file is a doc) | No (build output is gitignored) |

### Why the two patterns can coexist, and why they probably shouldn't

You *could* run both: have a `knowledge/` directory for human-facing
essays AND a `configs/agents/sources/` directory for AI build inputs.
This is fine but adds a meta-question: when you write a new principle,
which directory does it go in? If it's a tight one-liner → `sources/`.
If it's a 200-word essay → `knowledge/`. The boundary is fuzzy and
will rot over time.

The cleaner moves are:

**Option A — Just `configs/agents/sources/` (current Phase 5.3 design).**
AI plumbing only. If you ever want to publish a principle as a public
essay, you copy it out into a blog post / readme. The dotfiles repo
stays mechanical.

**Option B — Just `knowledge/`, replacing `configs/agents/sources/`.**
Same fragments, just lives at repo root and is named for its
human-readable purpose. The build script reads `knowledge/**/*.md`
(plus optional `knowledge/<tool>/**/*.md` for tool-specific). Each
file is *also* readable as a standalone document. The README links
to individual files. The "manifesto" angle is on the table whether
or not you take it.

### My recommendation

Go with **Option B (rename `configs/agents/sources/` → `knowledge/`),
but treat the human-readable purpose as optional, not mandatory.**

Reasoning:

- `knowledge/` is a more discoverable name than
  `configs/agents/sources/`. New collaborators (or future-you with
  cold cache) immediately understand what's inside.
- The naming costs nothing now and *enables* the manifesto path
  later. If you never write a single essay, the dir is still a clean
  bag of fragments that the build script consumes. No downside.
- The path under `configs/` implies "machine configuration"; the
  path at root implies "intellectual content". The latter framing
  is more accurate for what we're actually doing — those `.md`
  fragments encode preferences and principles, not config values.
- The atxtechbro structure has a real-world track record of being
  useful as a human-readable manifesto. We can adopt the shape
  without committing to their writing volume.

What we deliberately don't take from atxtechbro on this front:

- **The automatic `--add-dir` flag on a tool alias.** We're staying
  with the build-and-symlink approach (works with Rovo which
  doesn't support directory loading; works with Cursor too via
  `~/.cursor/rules/00-shared-agents.mdc`). No tool-alias gymnastics.
- **Their `principles/` vs. `procedures/` sub-taxonomy.** Probably
  premature for our volume. Start flat (`knowledge/00-principles.md`,
  `knowledge/10-workflow.md`, etc.); add subdirs only when there are
  enough files to warrant it (heuristic: > 5 files per category).

### Concrete impact if we adopt Option B

The Phase 5.3 layout becomes:

```
knowledge/                       # was configs/agents/sources/
  00-principles.md
  10-workflow.md
  20-style.md
  30-communication.md
  cursor/
    01-cursor-tweaks.md
  rovo/
    01-rovo-tweaks.md
  README.md                      # short — explains the dir's role

configs/
  agents/
    build/                       # generated outputs (unchanged)
      base.md
      cursor.md
      rovo.md
    .gitignore                   # ignores build/

scripts/
  agents/
    build-agents.sh              # reads knowledge/, writes configs/agents/build/
  setup.agents.sh
```

Private overlay similarly becomes `dotfiles-private/knowledge/...`.

If you go with Option A instead, nothing else in the plan changes —
the current Phase 5.3 layout already works.

### Decision needed

Pick **A** (stay mechanical, `configs/agents/sources/`) or **B**
(adopt `knowledge/` framing). Either way, Phase 5.3 ships the same
mechanism — only the directory name and the README convention
differ. Cheap to choose now, expensive to change after content lands.
