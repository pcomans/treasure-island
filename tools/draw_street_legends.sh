#!/usr/bin/env bash
# Draws the street-ground legend atlas,
# game/resources/textures/world/street/street_legends.png (2048 x 512): eight
# 256 x 512 cells of white pavement legends on black, the cells of
# STREET_LEGEND_CELLS in tools/lib/street-ground-generation.mjs, read by
# street_paint.gdshader (legend paint kind). In a cell, x runs across the
# legend and y along it, the top toward the far end, as on the STOP legend: a
# legend is drawn at the shape it is painted (its length along by its width
# across) and squeezed into its cell, which the paint stretches back.
#   0 TOUR BUS PARKING, one line across a bus bay (painted about 7.2 m across, 2.2 m along)
#   1 straight arrow, 2 left-turn arrow, 3 right-turn arrow (painted about 1.2 m across, 4.8 m along)
#   4 the International Symbol of Access (painted about 1.5 m square)
#   5-7 spare (black)
# Needs ImageMagick and the DejaVu Sans Bold font, both in the
# devcontainer image; the output is the same byte for byte on every run.
#   tools/draw_street_legends.sh [output.png]
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="${1:-${here}/game/resources/textures/world/street/street_legends.png}"
work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
# 0: TOUR BUS PARKING at 7.2 x 2.2 m (720 x 220 px, 1 cm per px), white capitals.
# Pavement legend letters are long in the direction of travel: the line is set
# flat (700 x 64) and stretched along to the 2.2 m it is painted.
convert -background black -fill white -font DejaVu-Sans-Bold -size 700x64 -gravity center label:'TOUR BUS PARKING' \
  -resize '720x200!' -gravity center -extent 720x220 -resize '256x512!' "${work}/c0.png"
# 1-3: arrows at 1.2 x 4.8 m (120 x 480 px), pointing up (the far end).
convert -size 120x480 xc:black -fill white -draw 'polygon 60,0 120,150 80,150 80,480 40,480 40,150 0,150' -resize '256x512!' "${work}/c1.png"
convert -size 120x480 xc:black -fill none -stroke white -strokewidth 40 -draw "path 'M 70,480 L 70,210 Q 70,130 34,130'" \
  -fill white -stroke none -draw 'polygon 0,130 40,72 40,188' -resize '256x512!' "${work}/c2.png"
convert "${work}/c2.png" -flop "${work}/c3.png"
# 4: the International Symbol of Access at 1.5 x 1.5 m (300 x 300 px), then squeezed into the cell.
convert -size 300x300 xc:black -fill white -stroke white \
  -draw 'circle 150,52 150,22' \
  -draw 'polygon 132,92 168,92 172,168 236,168 236,196 150,196' \
  -fill none -strokewidth 26 -draw 'arc 60,140 220,300 300,600' \
  -fill white -stroke none -draw 'polygon 236,168 262,168 290,262 262,262' -resize '256x512!' "${work}/c4.png"
for cell in 5 6 7; do convert -size 256x512 xc:black "${work}/c${cell}.png"; done
convert "${work}"/c{0,1,2,3,4,5,6,7}.png +append -colorspace Gray -depth 8 -strip -define png:exclude-chunks=date,time "${out}"
