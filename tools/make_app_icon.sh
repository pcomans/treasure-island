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
# fringe. The exporters and the loading screen use the imported images, so both
# .import files keep process/fix_alpha_border off
# (game/tests/headless_world_material_contract.gd checks it): on, the import would
# refill those pixels from the art's grey anti-aliased rim, a light rim on the
# icons. Needs ImageMagick; the output is deterministic for a given ImageMagick
# version.
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
# Lanczos leaves faint alpha round the art in whatever colour the resize gave it,
# some near white, and the PNG writer truncates alpha to 8 bits. So the resize is
# written at 8 bits and read back, and every pixel whose stored alpha is under
# 20/255 (the transparent ones and that faint fringe; the cut Godot's own
# alpha-border fix uses) takes the outline's black: a filter or resize that
# doesn't premultiply alpha (the loading screen's, the exporters') then draws no
# light specks, and correctly blended they change by under 8 grey levels. Every
# pixel keeps its alpha, so the outline's anti-aliased edge stays at full weight.
# (This replaces "-channel A -black-threshold 0.2%", which in ImageMagick 7 zeroed
# every alpha below fully opaque and so cut the outline's outer edge away.)
magick "${ui}/app_icon.png" -filter Lanczos -resize 360x360 -depth 8 png32:- \
  | magick png:- -channel RGB -fx 'a < 19.5/255 ? 0 : u' +channel "${png[@]}" "PNG32:${ui}/app_icon_360.png"
