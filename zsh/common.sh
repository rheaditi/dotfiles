# Common configurations for all environments

if [[ "$REMOTE_DEV_ENV" != "true" ]]; then
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
fi

