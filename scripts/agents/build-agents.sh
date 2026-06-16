#!/usr/bin/env bash

# AGENTS.md composer
# Concatenates modular .md source fragments (public + optional private overlay)
# into a single per-tool output file under configs/agents/build/.
#
# Sources are the source of truth; build/ is generated and gitignored.
#
# Usage:
#   ./scripts/agents/build-agents.sh           # build all targets
#   ./scripts/agents/build-agents.sh --diff    # preview changes vs current build/
#
# Add a new target (e.g. cursor, cmux): add its name to TARGETS, create
# configs/agents/sources/<target>/ for any tool-specific addenda, and add a
# symlink line in scripts/setup.agents.sh.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$DOTFILES_ROOT/scripts/utils/logging.sh"
# Single source of truth for DIR_DOTFILES_PRIVATE (and friends).
source "$DOTFILES_ROOT/common/utils/paths.sh"

PUBLIC_SOURCES="$DOTFILES_ROOT/configs/agents/sources"
PRIVATE_SOURCES="${DIR_DOTFILES_PRIVATE:-}/agents/sources"
BUILD_DIR="$DOTFILES_ROOT/configs/agents/build"

# Tools we generate context for. Extend this list to add targets.
TARGETS=(rovo)

# Separator between fragments — visible seams in the rendered file.
SEPARATOR=$'\n\n---\n\n'

# Collect sorted *.md files from a directory into the given array name.
# Usage: collect_md <dir> <array_name>
collect_md() {
  local dir="$1" __arr="$2"
  [[ -d "$dir" ]] || return 0
  local f
  # Sorted, glob-safe; skip if no matches.
  while IFS= read -r f; do
    [[ -n "$f" ]] && eval "$__arr+=(\"\$f\")"
  done < <(find "$dir" -maxdepth 1 -type f -name '*.md' | sort)
}

# Build the ordered fragment list for a target.
# Order: public general -> public <target> -> private general -> private <target>
fragments_for_target() {
  local target="$1"
  local -a frags=()

  collect_md "$PUBLIC_SOURCES" frags
  collect_md "$PUBLIC_SOURCES/$target" frags
  collect_md "$PRIVATE_SOURCES" frags
  collect_md "$PRIVATE_SOURCES/$target" frags

  printf '%s\n' "${frags[@]}"
}

# Concatenate fragments for a target to stdout.
compose_target() {
  local target="$1"
  local -a frags=()
  while IFS= read -r f; do [[ -n "$f" ]] && frags+=("$f"); done < <(fragments_for_target "$target")

  local i
  for i in "${!frags[@]}"; do
    (( i > 0 )) && printf '%s' "$SEPARATOR"
    cat "${frags[$i]}"
  done
  # Ensure trailing newline.
  printf '\n'
}

# Count fragments for a target (for the summary).
count_fragments() {
  fragments_for_target "$1" | grep -c . || true
}

build_all() {
  mkdir -p "$BUILD_DIR"
  local target out bytes count
  for target in "${TARGETS[@]}"; do
    out="$BUILD_DIR/$target.md"
    compose_target "$target" > "$out"
    count="$(count_fragments "$target")"
    bytes="$(wc -c < "$out" | tr -d ' ')"
    log-info "built $target: $count fragment(s), ${bytes} bytes -> $out" >&2
  done
}

# --diff: build into a temp dir and diff against current build/.
diff_all() {
  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "${tmp:-}"' EXIT
  local target changed=0
  for target in "${TARGETS[@]}"; do
    compose_target "$target" > "$tmp/$target.md"
    if [[ -f "$BUILD_DIR/$target.md" ]]; then
      if ! diff -u "$BUILD_DIR/$target.md" "$tmp/$target.md" --label "current/$target.md" --label "rebuilt/$target.md"; then
        changed=1
      fi
    else
      log-info "$target.md: no current build (would be created)" >&2
      changed=1
    fi
  done
  [[ "$changed" -eq 0 ]] && log-success "No changes — build/ is up to date." >&2
}

main() {
  case "${1:-}" in
    --diff) diff_all ;;
    "")     build_all ;;
    *)      log-error "Unknown argument: $1 (use --diff or no args)"; return 1 ;;
  esac
}

main "$@"
