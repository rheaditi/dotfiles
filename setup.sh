#!/usr/bin/env bash
set -euo pipefail

DIR_SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# common stuff
source "$DIR_SELF/scripts/logging.sh"
source "$DIR_SELF/scripts/env.sh"
source "$DIR_SELF/scripts/vars.sh"

log_info "Starting dotfiles setup..."

if is_macos; then
  log_info "  Platform : macOS"
elif is_linux; then
  log_info "  Platform : Linux"
else
  log_warn "  Platform : unknown"
fi

is_devbox && log_info "  Devbox   : true" || log_info "  Devbox   : false"

log_info "  DIR_DOTFILES         = $DIR_DOTFILES"
log_info "  DIR_DOTFILES_PRIVATE = $DIR_DOTFILES_PRIVATE"

source "$DIR_SELF/setup/setup.git.sh"

log_success "Done."
