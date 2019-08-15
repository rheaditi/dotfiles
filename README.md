# rheaditi's dotfiles

![image](https://user-images.githubusercontent.com/6426069/63123690-30d25a80-bfc7-11e9-9f73-9dcf249ce3dd.png)

## Installation

Warning: If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use my settings unless you know what that entails. Use at your own risk!

## pre-requisites

* Install zsh & [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh#getting-started)
* Maybe [iTerm](https://www.iterm2.com/downloads.html)

### git it

_Note: There's a private directory which has some work-related info in `./private/work.sh`, make sure you download that from a backup / remove the source line for it in [./zsh/zshrc](./zsh/zshrc)._

```sh
cd ~ && mkdir dev && cd dev
git clone git@github.com:rheaditi/dotfiles.git
cd dotfiles && ./setup.sh
```
