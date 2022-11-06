#!/usr/bin/env bash
MINECRAFT_MOUNT_DIR="/mnt/d/Minecraft"

if [ ! -d "$MINECRAFT_MOUNT_DIR" ]; then
  return 0
fi

MINECRAFT_SERVER="$MINECRAFT_MOUNT_DIR/vanilla-server"

# aliases
alias mineserver="cd $MINECRAFT_SERVER"

# functions
push-server() {
  mineserver
  git status

  git add .
  git commit -m "$(commitdate)"

  git push
}

unset MINECRAFT_MOUNT_DIR MINECRAFT_MOUNT_DIR
