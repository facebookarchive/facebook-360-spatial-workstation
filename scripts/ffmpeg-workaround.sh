#!/bin/bash

# Copy and paste this into Terminal on macOS:
# /bin/bash -c "$(curl -fsSL https://gist.githubusercontent.com/fugalh/695c94d135ed2ed3534be9adc04e7b88/raw/9a69ed700146ad997334c69f5591f6e3bce18e40/fb360_spatial_workstation-ffmpeg-workaround.sh)"

spatworks="$HOME/Library/Application Support/FB360 Spatial Workstation"
ffmpeg_cellar="/usr/local/Cellar/ffmpeg@3.4/3.4.2"

# download homebrew and xcode command line tools if required
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

set -ex

# install ffmpeg version 3.4.2 if necessary
test -d "$ffmpeg_cellar" || brew install ffmpeg@3.4 || test -x "$ffmpeg_cellar/bin/ffmpeg"

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
