#!/usr/bin/env bash
# Builds the game's app icon, the owner's treasure chest (owner-supplied,
# 2026-11-13, replacing the 2026-11-08 picture; game/resources/ui/PROVENANCE.md),
# into game/resources/ui/:
#   app_icon.png      the master: the owner's 864 x 864 picture, unscaled, centred
#                     on a transparent 968 x 968 square. Its chest nearly fills the
#                     picture, so the square is tighter than the old 1024: the chest
#                     covers as much of each icon as the 2026-11-08 one did. The
#                     macOS export builds its .icns from it (export_presets.cfg
#                     application/icon, 16 to 1024 px with Lanczos); only the
#                     1024 px size is enlarged, by 6%.
#   app_icon_360.png  360 x 360 (Lanczos): application/config/icon, the window icon
#                     on Linux, the web favicon (also the web page's loading chest,
#                     game/web/shell.html), and the web's 180 x 180
#                     apple-touch-icon, which the exporter halves from it; and the
#                     game's loading screen chest (game/scenes/ui/hud.tscn).
# The background stays transparent. Fully transparent pixels are made black (the
# art's outline colour) so a resize that doesn't premultiply alpha draws no light
# fringe. The exporters resize the imported image, so app_icon.png.import keeps
# that black with process/fix_alpha_border off: on, it would fill them from the
# art's grey anti-aliased rim, a light rim on the .icns. Needs ImageMagick; the
# output is deterministic for a given ImageMagick version.
#   tools/make_app_icon.sh [owner-picture]   with the owner's picture, rebuilds the
#                                            master from it first; with no argument,
#                                            rebuilds app_icon_360.png from the
#                                            committed master
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ui="${here}/game/resources/ui"
png=(-depth 8 -strip -define png:exclude-chunks=date,time)
master=968
if [ "$#" -ge 1 ]; then
  # -extent would crop a picture larger than the square; refuse instead.
  size="$(magick identify -format '%w %h' "$1[0]")"
  if [ "${size% *}" -gt "${master}" ] || [ "${size#* }" -gt "${master}" ]; then
    echo "FAIL: $1 is ${size/ / x }, larger than the ${master} x ${master} master; choose a larger master" >&2
    exit 1
  fi
  magick "$1" -background black -alpha background \
    -background none -gravity center -extent "${master}x${master}" "${png[@]}" "PNG32:${ui}/app_icon.png"
fi
# Alpha under half an 8-bit step (Lanczos' faint ringing) is zeroed first, so every
# pixel saved transparent is also black.
magick "${ui}/app_icon.png" -filter Lanczos -resize 360x360 \
  -channel A -black-threshold 0.2% +channel \
  -background black -alpha background "${png[@]}" "PNG32:${ui}/app_icon_360.png"
