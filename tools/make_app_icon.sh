#!/usr/bin/env bash
# Builds the game's app icon, the owner's treasure chest (owner-supplied,
# 2026-11-08; game/resources/ui/PROVENANCE.md), into game/resources/ui/:
#   app_icon.png      the master: the owner's 980 x 980 picture, unscaled, centred
#                     on a transparent 1024 x 1024 square. The macOS export builds
#                     its .icns from it (export_presets.cfg application/icon, 32 to
#                     1024 px with Lanczos), so no size is ever upscaled.
#   app_icon_360.png  360 x 360 (Lanczos): application/config/icon, the window icon
#                     on Linux, the web favicon, and the web's 180 x 180
#                     apple-touch-icon, which the exporter halves from it.
# The background stays transparent. Fully transparent pixels are made black (the
# art's outline colour) so a resize that doesn't premultiply alpha draws no light
# fringe. Needs ImageMagick; the output is the same byte for byte on every run.
#   tools/make_app_icon.sh [owner-picture]   with the owner's picture, rebuilds the
#                                            master from it first
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ui="${here}/game/resources/ui"
png=(-depth 8 -strip -define png:exclude-chunks=date,time)
if [ "$#" -ge 1 ]; then
  magick "$1" -background black -alpha background \
    -background none -gravity center -extent 1024x1024 "${png[@]}" "PNG32:${ui}/app_icon.png"
fi
# Alpha under half an 8-bit step (Lanczos' faint ringing) is zeroed first, so every
# pixel saved transparent is also black.
magick "${ui}/app_icon.png" -filter Lanczos -resize 360x360 \
  -channel A -black-threshold 0.2% +channel \
  -background black -alpha background "${png[@]}" "PNG32:${ui}/app_icon_360.png"
