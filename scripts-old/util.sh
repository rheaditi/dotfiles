#!/usr/bin/env bash

export COLOR_TEXT_RESET='\033[0m'
export COLOR_TEXT_RED='\033[0;31m'
export COLOR_TEXT_GREEN='\033[0;32m'
export COLOR_TEXT_CYAN='\033[0;36m'

function runIfYes() {
  local TASK=$1; local PREFIX=$2; local CMD=$3;

  echo -e "↠ ${COLOR_TEXT_CYAN}$PREFIX${COLOR_TEXT_RESET}"
  read -p "Are you sure? (y/N) " -n 1;
  echo ""

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    $CMD
    echo -e "${COLOR_TEXT_GREEN}$TASK: ✅ Done.${COLOR_TEXT_RESET}"
  else
    echo -e "${COLOR_TEXT_RED}$TASK: 🚫 Skipped.${COLOR_TEXT_RESET}"
  fi;

  echo ""
}

function runOnlyIfMacOS() {
  if [[ $OSTYPE == 'darwin'* ]]; then
    $1;
  fi
}

function runOnlyIfLinux() {
  if [[ $OSTYPE == "linux-gnu"* ]]; then
    $1;
  fi
}

export runIfYes;
export runOnlyIfMacOS;
export runOnlyIfLinux;
