#!/bin/bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
# author: Hans Fugal

function usage {
    {
        test -n "$1" && echo -e "$1\n"
        echo "usage: $0 VIDEO [OUTDIR]"
        echo
        echo "Extracts the audio from an FB360 video (4+4+2 format)."
        echo "Writes tbe_8.wav, headlocked.wav, and tbe_8.2.wav in"
        echo "OUTDIR (the default is the current directory)"
    } 1>&2
    exit 1
}

# check arg count
test $# -gt 0 || usage
test $# -lt 3 || usage

# check args
vid=$1
test -r "$vid" || usage "no such video '$vid'"
outdir=${2:-.}

mkdir "$outdir"

test -d "$outdir" || usage "no such output directory '$outdir'"

# fail fast
set -e

# assumption: 0:0 is video, 0:1-0:3 is 4+4+2 audio
# amerge in filter_complex is kinda hard to grok in the docs, but basically
# we're listing the inputs in square brackets, saying there are that many
# inputs in the parameters to amerge, and it is just concatenating them channel-wise.

ffmpeg -i "$vid" \
    -filter_complex "[0:1][0:2]amerge=inputs=2" \
    "$outdir"/tbe_8.wav

ffmpeg -i "$vid" \
    -map 0:3 \
    "$outdir"/headlocked.wav

ffmpeg -i "$vid" \
    -filter_complex "[0:1][0:2][0:3]amerge=inputs=3" \
    "$outdir"/tbe_8.2.wav
