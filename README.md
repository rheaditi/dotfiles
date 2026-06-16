# rheaditi's dotfiles ✨

A painstakingly curated collection of configs, scripts, and digital comfort blankets for macOS development on my personal and work machines (with some Ubuntu compatibility thrown in). Proceed with caution and a sense of adventure! 🚀

<img width="419" alt="image" src="https://user-images.githubusercontent.com/6426069/159650696-f50e5175-0c2b-472e-a99d-01a3a0ee149c.png">


## ⚠️ Friendly Warning

If you want to give these dotfiles a try, you should **first fork this repository**, review the code (or ask an LLM to do it for you with a custom prompt for your use case), and remove things you don't want or need. 
Don't blindly use my settings unless you know what that entails. Use at your own risk! (But also, have fun with it!)

## What's Inside? 📦

This setup includes configurations for:

| Component      | Description |
|----------------|-------------|
| **Zsh**        | oh-my-zsh, custom aliases, functions, and prompt |
| **Terminal**   | **cmux** + Ghostty. Theme/font/colors in [`configs/ghostty/config`](configs/ghostty/config) (read by cmux via libghostty); cmux app settings in [`configs/cmux/cmux.json`](configs/cmux/). Symlinked by `setup.sh`. (The old iTerm2 config was removed — see git history if needed.) |
| **VS Code**    | Settings and keybindings, et al. |
| **Git**        | Configuration, global gitignore |
| **SSH**        | Config template |
| **macOS**      | System preferences via scripts |
| **Homebrew**   | Package management for most tooling |
| **Node.js**    | Development environment with nvm |
| **AI agents**  | Shared `AGENTS.md` context composed from modular fragments ([`configs/agents/`](configs/agents/)) and symlinked to `~/.rovodev/AGENTS.md` |

## Prerequisites 🛠️

Before diving into _editing_ these files though, make sure you have:
- **Zsh** & [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh#getting-started) installed
- A terminal of your choice (**cmux** going forward; iTerm2 is now legacy)
- **Xcode Command Line Tools** (will be installed automatically if missing)

## Installation 🎯

There are **two entrypoints**, depending on what you need:

```sh
# Create a cozy dev directory
mkdir -p ~/dev && cd ~/dev

# Clone the magic
git clone https://github.com/rheaditi/dotfiles.git
cd dotfiles
```

### Quick: apply configuration only

`setup.sh` only symlinks/applies config (zsh, git, ssh). It installs nothing,
never prompts, and is safe to re-run anytime (e.g. after `git pull`):

```sh
./setup.sh
```

### Full: provision a fresh machine 🪄

`bootstrap.sh` is the "spilled coffee" path — run it once on a new machine to
**install tooling** (Homebrew, Node.js, packages) _and then_ apply all config.
In an interactive terminal it asks you to confirm each install step; when run
unattended (`NONINTERACTIVE=1`) it installs everything automatically. It also
works cross-platform — macOS-only steps (Homebrew) are skipped on Linux:

```sh
./bootstrap.sh                    # confirm each install step
NONINTERACTIVE=1 ./bootstrap.sh   # install everything, no prompts
```

### What Actually Happens

`bootstrap.sh` is a strict superset of `setup.sh`:

1. **Homebrew Setup** *(macOS)* - Installs Homebrew + packages from `scripts/brew/Brewfile`
2. **Node.js Setup** - Installs nvm, Node.js (LTS), and yarn
3. **Configuration** *(delegates to `setup.sh`)*:
   - **Zsh** - oh-my-zsh, plugins, prompt
   - **Git** - config + global gitignore
   - **SSH** - symlinks `configs/ssh/config` → `~/.ssh/config`
   - **Editor** - symlinks VS Code settings + keybindings
   - **Terminal** - symlinks Ghostty config + cmux settings
   - **AGENTS.md** - builds shared AI-agent context and symlinks it to
     `~/.rovodev/AGENTS.md`
4. **VS Code extensions** - installs from `configs/vscode/extensions.txt`, but
   only if the `code` CLI is on `PATH` (otherwise it's skipped with a reminder
   to run `./scripts/setup.vscode-extensions.sh` later)

For the full design rationale, architecture, and evolution plan, see
[docs/ai-native-plan.md](docs/ai-native-plan.md).

## Manual Steps 📝

After the automated setup, I also do the following:
- **Install Fira Code font** ([download here](https://github.com/tonsky/FiraCode/releases))
- **Reload the shell**: `source ~/.zshrc`
- **Install VS Code extensions** (once the `code` command is on `PATH`):
  `./scripts/setup.vscode-extensions.sh`

## Customization 🎨

Feel free to copy or change anything in here to suit your needs - but again, at your own risk! 

Happy coding! 🎉
