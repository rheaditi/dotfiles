# Common configurations for all environments

# NVM lazy loading
export NVM_DIR="$HOME/.nvm"
nvm() {
    unset -f nvm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    nvm "$@"
}

node() {
    unset -f node
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    node "$@"
}

npm() {
    unset -f npm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    npm "$@"
}

# Pure prompt optimization
zstyle :prompt:pure:git:stash show yes
PURE_CMD_MAX_EXEC_TIME=1
PURE_GIT_PULL=0
PURE_GIT_UNTRACKED_DIRTY=0

