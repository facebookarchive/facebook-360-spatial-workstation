#!/bin/bash

# REQUIRES WINDOWS 10
# Compile FFmpeg on Windows using with the Windows Subsystem for Linux.
# To enable the Windows Subsystem for Linux:
# 1. Press the Windows key on your keyboard to bring up Windows search on your computer
# 2. Type "Turn Windows features on and off". Click on the result called "Turn Windows features on and off"
# 3. The "Windows Features" window should now show
# 4. Enable "Windows Subsystem for Linux" and click OK. You may be asked to restart your computer.
# 5. Open "Microsoft Store", search for "Ubuntu" and install it
# 6. Once Ubuntu is installed, launch it and you should see a terminal window
# 7. You will be asked to setup a username and password. Do so.
# 8. You can now run this script by copy-pasting the following into the Ubuntu terminal window (you may need to right-click to paste):
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/facebookincubator/facebook-360-spatial-workstation/master/scripts/ffmpeg-workaround-win.sh)"

echo ' '
echo ' '
echo '*************************************************'
echo 'Downloading, compiling, and installing FFmpeg with the Windows Subsystem for Linux.'
echo 'If you run into issues: https://www.facebook.com/groups/audio360support/'
echo '*************************************************'
echo ' '
echo ' '

set -ex

sudo apt-get install gcc-mingw-w64-i686 g++-mingw-w64-i686 yasm make automake autoconf git pkg-config libtool-bin nasm gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64 -y

ffmpeg_tag=n3.2.14

spatworks="/mnt/c/ProgramData/FB360 Spatial Workstation"
dest_ffmpeg='ffmpeg-3.2-win64-shared'

host=x86_64-w64-mingw32
prefix=$HOME/ffmpeg_win64_build

mkdir -p "$prefix"
cd "$prefix"

cpu="$(grep -c processor /proc/cpuinfo 2>/dev/null)" 
if [ -z "$cpu" ]; then
  cpu = 1
fi

if [[ ! -f $prefix/lib/libx264.a ]]; then
  rm -rf x264
  git clone --depth 1 http://repo.or.cz/r/x264.git || exit 1
  cd x264
    ./configure --host=$host --enable-static --cross-prefix=$host- --prefix=$prefix || exit 1
    make -j$cpu
    make install
  cd ..
fi

# skip libopus and use FFmpeg's native implementation
# if [[ ! -f $prefix/lib/libopus.a ]]; then
#   opus_dir=opus_git
#   rm -rf $opus_dir
#   git clone --depth 1 https://github.com/xiph/opus.git $opus_dir || exit 1
#   cd $opus_dir
#   ./autogen.sh
#   ./configure --prefix=$prefix --host=x86_64-w64-mingw32 --disable-doc --disable-extra-programs LDFLAGS=-fstack-protector
#   make -j$cpu
#   make install
#   cd ..
# fi

ffmpeg_dir=ffmpeg_git
if [[ ! -d $ffmpeg_dir ]]; then
  rm -rf $ffmpeg_dir
  git clone --depth 1 --branch $ffmpeg_tag https://github.com/FFmpeg/FFmpeg.git $ffmpeg_dir
fi

PKG_CONFIG_PATH="$(realpath $prefix/lib/pkgconfig)"
export PKG_CONFIG_PATH
cd $ffmpeg_dir
if [[ ! -f ./config.mak ]]; then
  arch=x86_64
  ./configure --enable-gpl --enable-libx264 --enable-nonfree \
  --disable-static --enable-shared --enable-libx264 \
  --arch=$arch --target-os=mingw32 \
  --cross-prefix=$host- --pkg-config=pkg-config --pkg-config-flags="--static" --prefix=$prefix || exit 1
fi
make -j$cpu && make install

if [ -d "$spatworks/$dest_ffmpeg" ]; then
    if [ ! -d "$spatworks/ffmpeg-3.2-old" ]; then
        sudo mv "$spatworks/$dest_ffmpeg" "$spatworks/ffmpeg-3.2-old"
    fi
fi

mkdir -p "$spatworks/$dest_ffmpeg/bin"
cp -a "$prefix/bin/." "$spatworks/$dest_ffmpeg/bin/"

set +ex

echo ' '
echo ' '
echo '*************************************************'
echo 'Completed!'
echo 'If you run into issues: https://www.facebook.com/groups/audio360support/'
echo '*************************************************'
