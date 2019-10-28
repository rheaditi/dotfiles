# create a directory & cd into it
mkcd() { mkdir -p "$@" && cd "$@"; }

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
pkg-versions() {
  npm view $1 versions --json
}

# change default nvm node version to this version
# move-node-version() {
#   current=$(nvm ls default)
#   echo "$current"
# }
