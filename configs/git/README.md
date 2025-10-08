# Git Configuration System

Environment-aware Git configuration using Git's `[include]` feature.

## Files

- **`base.gitconfig`** - Common settings for all environments
- **`global.gitignore`** - Global gitignore patterns
- **`rheaditi.gitconfig`** - Personal config (conditional)
- **`~/dev/dotfiles-private/...../*.gitconfig`** - Private user config

## Environment Behavior

### 🏠 Local Environment

Creates new `~/.gitconfig` with conditional includes:

```
┌─────────────────────────────────────────┐
│ ~/.gitconfig (Local)                     │
├─────────────────────────────────────────┤
│ [include]                               │
│     path = base.gitconfig               │ ← Always
│                                         │
│ [include]                               │
│     path = ~/dev/dotfiles-private/...   │ ← Always
│                                         │
│ [includeIf "gitdir:~/dev/personal/"]    │
│     path = rheaditi.gitconfig           │ ← Personal dirs
│                                         │
│ [includeIf "gitdir:~/dev/dotfiles/"]    │
│     path = rheaditi.gitconfig           │ ← Personal dirs
└─────────────────────────────────────────┘
```

### 🐳 Devbox Environment

Appends base config to existing `~/.gitconfig`:

```
┌─────────────────────────────────────────┐
│ ~/.gitconfig (Devbox)                   │
├─────────────────────────────────────────┤
│ [existing configuration...]             │ ← Preserved
│                                         │
│ [include]                               │
│     path = base.gitconfig               │ ← Added
└─────────────────────────────────────────┘
```

## Usage

```bash
# Setup from any directory
./scripts/setup.git.sh

# personal in personal/dotfiles directories
cd ~/dev/personal/my-project
git status  # Automatically includes personal config

cd ~/dev/dotfiles
git status  # Automatically includes personal config

cd ~/somewhere/else
git status  # Uses base + private config only
```

## Verification

```bash
# Check all config sources
git --no-pager config --list --show-origin

# Check specific values
git config user.name
git config user.email
```

## Requirements

- **Local**: `~/dev/dotfiles-private/atlassian/git/amohanty.local.gitconfig` must exist
- **All**: `base.gitconfig` and `global.gitignore` must exist in this repo
