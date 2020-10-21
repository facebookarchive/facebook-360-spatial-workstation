#!/bin/bash

# Copy and paste this into Terminal on macOS:
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/facebookincubator/facebook-360-spatial-workstation/master/scripts/ffmpeg-workaround.sh)"

spatworks="$HOME/Library/Application Support/FB360 Spatial Workstation"
ffmpeg_cellar="/usr/local/Cellar/ffmpeg@3.4/3.4.2"

# download homebrew and xcode command line tools if required
test -x /usr/local/bin/brew || \
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

set -ex

# install ffmpeg version 3.4.2 if necessary
if [ ! -x "$ffmpeg_cellar/bin/ffmpeg" ]; then
    # If brew can't link because of permissions on /usr/local, keg-only is
    # still ok, so we test again after trying to install
    brew install sy1vain/ffmpeg/ffmpeg@3.4 || test -x "$ffmpeg_cellar/bin/ffmpeg"
fi

# prepare directory, backing up what exists if needed
mkdir -p "$spatworks"
cd "$spatworks"
if [ -d ffmpeg-3.2 ]; then
    if [ ! -d ffmpeg-3.2-old ]; then
        mv ffmpeg-3.2 ffmpeg-3.2-old
    fi
fi
mkdir -p ffmpeg-3.2/bin

# symlink files into place
cd ffmpeg-3.2/bin
ln -sf "$ffmpeg_cellar/bin/"* .
ln -sf "$ffmpeg_cellar/lib/"*dylib .
