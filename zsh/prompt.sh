# SPACESHIP_PROMPT_ORDER=(
#   user
#   dir
#   git_branch
#   git_status
#   line_sep
#   char
# )

# SPACESHIP_CHAR_SYMBOL="❯"
# SPACESHIP_CHAR_SUFFIX=" "
# SPACESHIP_GIT_BRANCH_PREFIX=""
# # SPACESHIP_GIT_BRANCH_SUFFIX=' '
# SPACESHIP_GIT_BRANCH_COLOR="240"
# SPACESHIP_DIR_COLOR='magenta'
# SPACESHIP_GIT_STATUS_COLOR='061'

autoload -U promptinit; promptinit
prompt pure # pure prompt
# prompt spaceship # Set Spaceship ZSH as a prompt

# https://github.com/denysdovhan/spaceship-prompt/issues/426#issuecomment-576036367
# () {
#   local z=$'\0'
#   PROMPT='${${${$(spaceship_prompt)//\%\%/'$z'}//\%B}//'$z'/%%}'
# }
