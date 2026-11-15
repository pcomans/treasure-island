#!/usr/bin/env bash
set -euo pipefail
if [[ $# -lt 2 || $# -gt 3 || "$2" != *.mp4 || -e "$2" ]]; then
  echo "Usage: encode.sh /path/to/frames.rgb /path/to/new-output.mp4 [frame-count]" >&2
  exit 1
fi
frames=${3:-900}
if [[ ! $frames =~ ^[1-9][0-9]{0,3}$ ]]; then
  echo "Frame count must be between 1 and 9999." >&2
  exit 1
fi
bytes=$(wc -c < "$1")
expected=$((1920 * 1080 * 3 * frames))
if [[ $bytes -ne $expected ]]; then
  echo "Expected $expected bytes ($frames RGB24 frames), got $bytes." >&2
  exit 1
fi
ffmpeg -nostdin -n -hide_banner -loglevel warning -stats_period 5 -stats \
  -f rawvideo -pixel_format rgb24 -video_size 1920x1080 -framerate 30 -i "$1" \
  -vf 'scale=in_range=pc:out_range=tv:out_color_matrix=bt709:flags=accurate_rnd+full_chroma_int,format=yuv420p,setsar=1,setparams=range=limited:color_primaries=bt709:color_trc=bt709:colorspace=bt709' \
  -frames:v "$frames" -an -c:v libx264 -preset slow -crf 18 -g 60 -profile:v high -level:v 4.1 \
  -maxrate 18M -bufsize 18M -color_range tv -colorspace bt709 -color_trc bt709 -color_primaries bt709 \
  -video_track_timescale 30000 -movflags +faststart "$2"
