#!/usr/bin/env bash
# Renders trailer shot files to H.264 MP4s (see tools/trailer/README.md).
#
#   tools/trailer/render-shot.sh SHOT.json OUT.mp4
#   tools/trailer/render-shot.sh --batch OUT_DIR SHOT.json [SHOT.json ...]    # OUT_DIR/NAME.mp4 each
#   tools/trailer/render-shot.sh --stills OUT_DIR SHOT.json [SHOT.json ...]   # a few PNG frames each
#
# Several shots share one load of the island (about five minutes on the M1 Pro).
# The game renders every frame offline on a fixed clock (game/tests/shared/
# trailer_shot.gd under --fixed-fps), writes them raw, and ffmpeg encodes them;
# the raw frames are deleted once each MP4 has every frame. Frames and logs go to
# $TRAILER_WORK_DIR (default ~/Movies/gti-trailer/work), never into the repo.
set -euo pipefail

usage() {
  echo "usage: $0 SHOT.json OUT.mp4 | $0 --batch OUT_DIR SHOT.json... | $0 --stills OUT_DIR SHOT.json..." >&2
  exit 2
}
repo="$(cd "$(dirname "$0")/../.." && pwd)"
case "${1:-}" in
  --batch|--stills)
    [ $# -ge 3 ] || usage
    mode="${1#--}"; out_dir="$2"; shift 2; shot_args=("$@") ;;
  *)
    [ $# -eq 2 ] || usage
    mode=single; out_dir="$(dirname "$2")"; single_out="$2"; shot_args=("$1") ;;
esac
command -v ffmpeg >/dev/null || { echo "ffmpeg is needed" >&2; exit 2; }

# Check every shot file before any engine starts.
shots=()
summaries=()
for shot in "${shot_args[@]}"; do
  [ -f "${shot}" ] || { echo "no shot file ${shot}" >&2; exit 2; }
  shot="$(cd "$(dirname "${shot}")" && pwd)/$(basename "${shot}")"
  shots+=("${shot}")
  summaries+=("$(python3 -I "${repo}/tools/trailer/check_shot.py" "${shot}")")
done
mkdir -p "${out_dir}"
out_dir="$(cd "${out_dir}" && pwd)"

if [ -z "${GODOT_BIN:-}" ] && [ -x "${repo}/.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot" ]; then
  export GODOT_BIN="${repo}/.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
fi
work="${TRAILER_WORK_DIR:-${HOME}/Movies/gti-trailer/work}/render-$(date +%Y%m%d-%H%M%S)"
mkdir -p "${work}"
runner=(python3 -I "${repo}/tools/trailer/run_engine.py")
engine=(--path "${repo}")
[ "$(uname -s)" = Darwin ] && engine+=(--rendering-driver metal)

# A fresh checkout imports its resources once first.
if [ ! -d "${repo}/.godot/imported" ]; then
  "${runner[@]}" "${work}/import.log" 1800 -- --headless --path "${repo}" --import
fi

capture="${work}/frames"
[ "${mode}" = stills ] && capture="${out_dir}/stills-$(date +%H%M%S)"
flags=(--shot "$(IFS=,; echo "${shots[*]}")" --out "${capture}")
[ "${mode}" = stills ] && flags+=(--stills)
fps="$(echo "${summaries[0]}" | cut -d' ' -f2)"
for summary in "${summaries[@]}"; do
  [ "$(echo "${summary}" | cut -d' ' -f2)" = "${fps}" ] || { echo "shots rendered together need the same fps" >&2; exit 2; }
  echo "Shot ${summary}"
done
echo "Log ${work}/render.log"
status=0
"${runner[@]}" "${work}/render.log" 7200 --require-complete -- "${engine[@]}" \
  --resolution 960x540 --disable-vsync --fixed-fps "${fps}" \
  --script res://game/tests/shared/trailer_shot.gd -- "${flags[@]}" || status=$?
if [ "${mode}" = stills ]; then
  echo "Stills in ${capture}"
  exit "${status}"
fi

# The Isle House trailer's colour conversion: full-range RGB to limited BT.709.
convert="scale=in_range=pc:out_range=tv:out_color_matrix=bt709:flags=accurate_rnd+full_chroma_int,format=yuv420p,setsar=1,setparams=range=limited:color_primaries=bt709:color_trc=bt709:colorspace=bt709"
# Shots the driver finished are encoded even when a later one failed.
for summary in "${summaries[@]}"; do
  read -r name fps width height frames <<< "${summary}"
  raw="${capture}/${name}/frames.rgb"
  if ! grep -q "^SHOT_DONE ${capture}/${name}\$" "${work}/render.log"; then
    echo "${name}: not rendered (see ${work}/render.log)" >&2
    rm -f "${raw}"
    status=1
    continue
  fi
  expected=$(( width * height * 3 * frames ))
  actual=$(stat -f %z "${raw}" 2>/dev/null || stat -c %s "${raw}")
  [ "${actual}" = "${expected}" ] || { echo "${raw} is ${actual} bytes, expected ${expected}; kept" >&2; exit 1; }
  partial="${work}/${name}.mp4"
  ffmpeg -nostdin -y -hide_banner -loglevel warning -f rawvideo -pixel_format rgb24 \
    -video_size "${width}x${height}" -framerate "${fps}" -i "${raw}" -vf "${convert}" \
    -an -c:v libx264 -preset slow -crf 17 -g "${fps}" -profile:v high \
    -color_range tv -colorspace bt709 -color_trc bt709 -color_primaries bt709 \
    -movflags +faststart "${partial}"
  encoded=$(ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of csv=p=0 "${partial}")
  [ "${encoded}" = "${frames}" ] || { echo "${partial} has ${encoded} frames, expected ${frames}" >&2; exit 1; }
  out="${single_out:-${out_dir}/${name}.mp4}"
  mv "${partial}" "${out}"
  rm -f "${raw}"
  echo "Wrote ${out}: ${encoded} frames at ${fps} fps ($(ffprobe -v error -show_entries format=duration -of csv=p=0 "${out}") s); raw frames deleted"
done
exit "${status}"
