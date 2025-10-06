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
| **iTerm2**     | Color schemes downloaded/converted from Visual Studio Code themes via [ditto-cli](https://www.npmjs.com/package/@campvanilla/ditto-cli) 🎨<br>_You can also preview these themes without applying them ([steps here](https://stackoverflow.com/questions/22943676/how-to-export-iterm2-profiles/23356086#23356086))_. |
| **VS Code**    | Settings and keybindings, et al. |
| **Git**        | Configuration, global gitignore |
| **SSH**        | Config template |
| **macOS**      | System preferences via scripts |
| **Homebrew**   | Package management for most tooling |
| **Node.js**    | Development environment with nvm |

## Prerequisites 🛠️

Before diving into _editing_ these files though, make sure you have:
- **Zsh** & [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh#getting-started) installed
- **iTerm2** ([download here](https://www.iterm2.com/downloads.html)) - optional but recommended
- **Xcode Command Line Tools** (will be installed automatically if missing)

## Installation 🎯


```sh
# Create a cozy dev directory
mkdir -p ~/dev && cd ~/dev

# Clone the magic
git clone https://github.com/rheaditi/dotfiles.git

# Let the scripts do their thing
cd dotfiles && ./setup.sh
```

### What Actually Happens

The setup script runs through some additional steps based on the OS / some arguments:
1. **macOS Setup** - Configures system preferences
2. **Dotfiles Setup** - Symlinks config files to your home directory
3. **Homebrew Setup** - Installs essential packages and apps
4. **Node.js Setup** - Installs Node.js and global packages
5. **Zsh Setup** - Configures shell environment

## Manual Steps 📝

After the automated setup, I also do the following:
- **Install Fira Code font** ([download here](https://github.com/tonsky/FiraCode/releases))
- **Reload the shell**: `source ~/.zshrc`
- **Set up VS Code** (if needed): `./scripts/setup.vscode.sh`

## Customization 🎨

Feel free to copy or change anything in here to suit your needs - but again, at your own risk! 

Happy coding! 🎉
