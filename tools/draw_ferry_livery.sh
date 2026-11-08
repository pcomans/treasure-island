#!/usr/bin/env bash
# Draws the ferry terminal's livery atlas,
# game/resources/textures/world/ferry/ferry_livery.png (1024 x 1024), read by
# game/scripts/world/ferry_terminal.gd: the Sammy J's lettering and the mooring
# dolphins' fender stencil, each in its own cell, with a plain white cell the
# painted parts sample (their colour is the vertex colour). Cells, in pixels:
#   white        0,0     256 x 256   plain white
#   hull name    256,0   512 x 128   SAMMY J, as on the bow (Jun 2025)
#   fender       256,128 512 x 128   OCEAN DONUT / MARINE FENDERS, white on black (Jun 2025)
#   bow panel    0,256   1024 x 256  TREASURE / ISLAND / SAN FRANCISCO, the upper deck's front (Jun 2025, May 2025)
#   side panel   0,512   1024 x 256  YERBA BUENA ISLAND / SAN FRANCISCO, the upper deck's side (Jun 2025)
#   transom      0,768   1024 x 192  SAMMY J / EMERYVILLE, CA / PROP, TREASURE ISLAND,
#                                    FINDWHATYOUSEEKTI.COM (Feb 2022)
#   spare        0,960   1024 x 64   white
# The words are the ones in the dated photos; the typefaces are stand-ins (a
# Times-like serif for the boat's serif capitals, a bold sans for the PROP mark
# and the stencil). Needs ImageMagick with the FreeSerif and DejaVu Sans fonts,
# both in the devcontainer image; the output is the same on every run.
#   tools/draw_ferry_livery.sh [output.png]
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="${1:-${here}/game/resources/textures/world/ferry/ferry_livery.png}"
serif=/usr/share/fonts/truetype/freefont/FreeSerif.ttf
sans_bold=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
for font in "${serif}" "${sans_bold}"; do
  [ -f "${font}" ] || { echo "missing font ${font}" >&2; exit 1; }
done
work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
navy='#141c33'
# The hull name: small serif capitals on the white bulwark near the bow.
convert -background white -fill "${navy}" -font "${serif}" -kerning 6 -size 420x96 -gravity center label:'SAMMY J' \
  -gravity center -extent 512x128 "${work}/hull.png"
# The fender stencil: white capitals on the black foam drum.
convert -size 512x128 xc:black -fill white -font "${sans_bold}" -gravity center \
  -pointsize 46 -kerning 3 -annotate +0-22 'OCEAN DONUT' \
  -pointsize 26 -kerning 2 -annotate +0+28 'MARINE FENDERS' "${work}/fender.png"
# The upper deck's front: TREASURE / ISLAND in wide serif capitals over a small SAN FRANCISCO.
convert -size 1024x256 xc:white -fill "${navy}" -font "${serif}" -gravity center \
  -pointsize 92 -kerning 14 -annotate +0-72 'TREASURE' \
  -pointsize 92 -kerning 14 -annotate +0+18 'ISLAND' \
  -pointsize 34 -kerning 6 -annotate +0+92 'SAN FRANCISCO' "${work}/bow.png"
# The upper deck's side: one line of serif capitals over a small SAN FRANCISCO.
convert -size 1024x256 xc:white -fill "${navy}" -font "${serif}" -gravity center \
  -pointsize 62 -kerning 5 -annotate +0-20 'YERBA BUENA ISLAND' \
  -pointsize 26 -kerning 5 -annotate +0+44 'SAN FRANCISCO' "${work}/side.png"
# The transom: the hull name and port of registry with the PROP mark on the
# left, TREASURE ISLAND on the right, the web address under it.
convert -size 1024x192 xc:white -fill "${navy}" \
  -font "${serif}" -gravity northwest -pointsize 40 -kerning 2 -annotate +36+20 'SAMMY J' \
  -pointsize 36 -kerning 1 -annotate +36+66 'EMERYVILLE, CA' \
  -font "${sans_bold}" -pointsize 46 -kerning 4 -annotate +36+112 'PROP' \
  -font "${serif}" -gravity northeast -pointsize 50 -kerning 8 -annotate +40+20 'TREASURE' \
  -pointsize 50 -kerning 8 -annotate +62+76 'ISLAND' \
  -pointsize 22 -kerning 3 -gravity southeast -annotate +30+14 'FINDWHATYOUSEEKTI.COM' "${work}/transom.png"
convert -size 1024x1024 xc:white \
  "${work}/hull.png" -geometry +256+0 -composite \
  "${work}/fender.png" -geometry +256+128 -composite \
  "${work}/bow.png" -geometry +0+256 -composite \
  "${work}/side.png" -geometry +0+512 -composite \
  "${work}/transom.png" -geometry +0+768 -composite \
  -type TrueColor -depth 8 -strip -define png:exclude-chunks=date,time "${out}"
