# The max execution time of a process before its run time is shown when it exits.
PURE_CMD_MAX_EXEC_TIME=1

# Turn this off because in large repos it is way too slow
PURE_GIT_PULL=0

# Do not include untracked files in dirtiness check. Mostly useful on large repos (like WebKit).
PURE_GIT_UNTRACKED_DIRTY=0

# Delay dirtiness check until after prompt is drawn. Mostly useful on large repos (like WebKit).
PURE_GIT_DELAY_DIRTY_CHECK=1

# Show stash status in git prompt
zstyle :prompt:pure:git:stash show yes

# Only show fetch status for current local branch upstream
zstyle :prompt:pure:git:fetch only_upstream yes

zstyle :prompt:pure:environment:nix-shell show no

fpath+=("$HOME/.zsh/pure")
autoload -U promptinit; promptinit
prompt pure
