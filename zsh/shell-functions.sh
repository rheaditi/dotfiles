#!/usr/bin/env bash

# create a directory & cd into it
mkcd() { mkdir -p "$@" && cd "$@" || return; }

# get the source code of a chrome extensions
get-extension-source() {
  curl -L -o "$1.zip" "https://clients2.google.com/service/update2/crx?response=redirect&os=mac&arch=x86-64&nacl_arch=x86-64&prod=chromecrx&prodchannel=stable&prodversion=44.0.2403.130&x=id%3D$1%26uc"
  unzip -d "$1-source" "$1.zip"
  rm -rf "$1.zip"
}

# format a number to money
format-money() {
  printf "%'.3f\n" $1
}

# list all published versions of an npm package
npm-all-versions() {
  npm view $1 versions --json
}

# recently changed files git
git-sort-modified() {
  while read file; do echo $(git log --pretty=format:%ad -n 1 --date=raw -- $file) $file; done < <(git ls-tree -r --name-only HEAD) | sort -k1,1n
}

ytw() {
  yarn test $1 --watch --verbose
}

ytcov() {
  yarn test $1 --collectCoverage
}

# find all directories named "node_modules" and remove them
rmr-node-modules() {
  local max_depth=2

  # Parse args
  while [[ "$1" =~ ^- ]]; do
    case "$1" in
      -d|--depth)
        shift
        max_depth="$1"
        ;;
      *)
        echo "Unknown option: $1"
        return 1
        ;;
    esac
    shift
  done

  echo "🔥 Removing node_modules directories up to depth $max_depth..."

  for ((depth=1; depth<=max_depth; depth++)); do
    echo "🔎 Checking depth $depth..."
    find . -maxdepth "$depth" -type d -name "node_modules" -prune | while read -r dir; do
      echo "🧹 Deleting $dir"
      rm -rf "$dir"
    done
  done

  echo "✅ All done. Breathe easy, the bloat is gone."
}