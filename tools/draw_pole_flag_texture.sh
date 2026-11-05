#!/usr/bin/env bash
# Draws the yard kit's pole flag texture,
# game/resources/textures/world/street/street_pole_flag.png (512 x 512): three
# horizontal bands, red, white and blue, after the two flags above the 9th St
# storage yard (Google Street View, Sep 2025). The upper half carries SELF
# STORAGE in blue capitals on the white band, as legible in that photo; the
# lower half is plain. Each flag is drawn at its 5:3 shape (480 x 288) and the
# pair is packed into the square. Needs ImageMagick and the DejaVu Sans Bold
# font, both in the devcontainer image; the output is the same byte for byte
# on every run.
#   tools/draw_pole_flag_texture.sh [output.png]
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="${1:-${here}/game/resources/textures/world/street/street_pole_flag.png}"
work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
convert -size 480x96 xc:'#b8282d' "${work}/red.png"
convert -size 480x96 xc:'#ecebe6' "${work}/white.png"
convert -size 480x96 xc:'#ecebe6' -font DejaVu-Sans-Bold -pointsize 52 -fill '#1e3179' -gravity center -annotate +0+3 'SELF STORAGE' "${work}/white_text.png"
convert -size 480x96 xc:'#20357f' "${work}/blue.png"
convert "${work}/red.png" "${work}/white_text.png" "${work}/blue.png" -append "${work}/text.png"
convert "${work}/red.png" "${work}/white.png" "${work}/blue.png" -append "${work}/plain.png"
convert "${work}/text.png" "${work}/plain.png" -append -resize '512x512!' -depth 8 -strip -define png:exclude-chunks=date,time "${out}"
