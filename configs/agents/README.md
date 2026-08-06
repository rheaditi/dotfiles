# AGENTS.md system

Shared context for AI coding agents ("how I work, what I expect"), composed
from modular `.md` fragments and installed into each tool's global location.

## How it works

```
configs/agents/
  sources/              # ← edit these (the source of truth)
    00-principles.md
    10-workflow.md
    30-communication.md
    rovo/               # tool-specific addenda (small)
  build/                # ← generated, gitignored — do not edit
    rovo.md
```

A build script concatenates the fragments (public + an optional private
overlay) into one file per tool, then symlinks it into place:

| Tool | Built file | Symlinked to |
|------|-----------|--------------|
| Rovo CLI | `build/rovo.md` | `~/.rovo/AGENTS.md` |

## Public + private overlay

Generic content (how I communicate, git/PR preferences) lives here in the
public repo. Work-specific content (internal hosts, APIs, table names) lives
in the **private** dotfiles repo at `$DIR_DOTFILES_PRIVATE/agents/sources/`
(see `scripts/utils/paths.sh`). The build merges both when the private repo is
present and falls back gracefully when it isn't.

## Fragment ordering

Files are concatenated in sorted order, in this sequence:

1. public general — `sources/*.md`
2. public tool-specific — `sources/<tool>/*.md`
3. private general — `$DIR_DOTFILES_PRIVATE/agents/sources/*.md`
4. private tool-specific — `$DIR_DOTFILES_PRIVATE/agents/sources/<tool>/*.md`

Use numeric prefixes for explicit ordering: `00-09` foundational,
`10-29` workflow/conventions, `30+` stylistic.

## Rovo `config.yml` + `mcp.json`

Beyond `AGENTS.md`, `scripts/setup.agents.sh` also symlinks Rovo's `config.yml`
(model, UI, tool-permission, and hook settings) and `mcp.json` (MCP server
config) from the **private** dotfiles repo:

```
$DIR_DOTFILES_PRIVATE/rovo/config.yml  →  ~/.rovo/config.yml
$DIR_DOTFILES_PRIVATE/rovo/mcp.json    →  ~/.rovo/mcp.json
```

Setup links these private source files only into Rovo's `~/.rovo/` runtime
home. They live in the private repo because they reference Atlassian-internal
hooks, the billing site, and internal MCP servers (no secrets, but internal-ish).
Notes:

- **Symlinked**, so Rovo's runtime rewrites flow back into the private repo
  (expect occasional churn in app-managed fields like `announcementTracking`).
- **Skipped on devbox/RDE** (`REMOTE_DEV_ENV=true`): the committed files have
  machine-specific absolute paths (`/Users/...`) that would be wrong there, so
  the devbox keeps Rovo's own native config.
- **Skipped if the private repo isn't present** — public-only setups just won't
  get them.

## Usage

```bash
./scripts/agents/build-agents.sh          # rebuild build/ from sources
./scripts/agents/build-agents.sh --diff   # preview changes vs current build/
./scripts/setup.agents.sh                 # build + (re)create the symlinks
```

`setup.sh` runs `setup.agents.sh` automatically, so the symlinks are
re-established on every setup. After editing a source, re-run the build (or
just `./setup.sh`).

## Legacy Rovo Dev archive

`~/.rovodev` is no longer managed or referenced by Rovo's active configuration.
It is retained as an archive until the week of **August 10, 2026**. Before
archiving it, run a normal Rovo session; its remaining `skills/`, `hooks/`,
`logs/`, and `prompt_history/` do not need migration unless Rovo develops a
specific dependency on them.

## Add a fragment

Drop a new `*.md` into `sources/` (or `sources/<tool>/` for tool-specific
content), then rebuild. That's it.

## Add a new target (e.g. Cursor, cmux)

1. Add the target name to `TARGETS` in `scripts/agents/build-agents.sh`.
2. Create `sources/<target>/` for any tool-specific addenda.
3. Add a `link-agent-file` line in `scripts/setup.agents.sh` pointing at the
   tool's global config location.

The architecture doesn't change — a new target is just a new case.
