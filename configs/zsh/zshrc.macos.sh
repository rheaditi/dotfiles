# macOS specific configurations

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Ruby (comes with macos)
export PATH="/usr/local/opt/ruby/bin:/$HOME/.gem/ruby/2.6.0/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"

# MongoDB
export PATH="/opt/homebrew/opt/mongodb-community@4.4/bin:$PATH"

# Yarn
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# Java
export PATH="$HOME/.jenv/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "/Users/amohanty/.bun/_bun" ] && source "/Users/amohanty/.bun/_bun"

# Wrap common Java commands to load asynchronously
# This is done to speed up the zsh startup time
jenv() {
  unset -f jenv
  eval "$(jenv init -)"
  jenv "$@"
}

java() {
  unset -f java
  eval "$(jenv init -)"
  java "$@"
}

javac() {
  unset -f javac
  eval "$(jenv init -)"
  javac "$@"
}

mvn() {
  unset -f mvn
  eval "$(jenv init -)"
  mvn "$@"
}

gradle() {
  unset -f gradle
  eval "$(jenv init -)"
  gradle "$@"
}

[ -f "$HOME/.iterm2_shell_integration.zsh" ] && source ~/.iterm2_shell_integration.zsh
