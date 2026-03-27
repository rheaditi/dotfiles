# macOS specific configurations

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Ruby
export PATH="/usr/local/opt/ruby/bin:/$HOME/.gem/ruby/2.6.0/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"

# MongoDB
export PATH="/opt/homebrew/opt/mongodb-community@4.4/bin:$PATH"

# Yarn
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$PATH" 

# Python/pyenv setup
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export npm_config_python="$PYENV_ROOT/3.10.14/bin/python"

# Java/jenv setup with lazy loading
export PATH="$HOME/.jenv/bin:$PATH"
jenv() {
    unset -f jenv
    eval "$(jenv init -)"
    jenv "$@"
}

# Wrap common Java commands
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

