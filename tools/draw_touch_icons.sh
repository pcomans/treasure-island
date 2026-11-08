#!/usr/bin/env bash
# Draws the touch controls' use-button icons (game/scripts/ui/touch_use_button.gd)
# into game/resources/ui/touch/ (256 x 256, white on transparent), in the style of
# the vendored RISE and RUN icons (game/resources/ui/selgesel): a ring as thick and
# as wide as theirs, with a solid white glyph inside.
#   icon-car.png   a car from the side, its windows and wheel arches cut out
#                  (get in or out of a car);
#   icon-drop.png  a down arrow onto the ground segment of the RISE icon, mirroring
#                  its up arrow (hold to drop fast);
#   icon-brake.png the dashboard handbrake lamp, a P in a ring between two arcs
#                  (RISE's glyph in a car, where it is the handbrake).
# Each is drawn as a white mask, with antialiasing, and used as the alpha of a
# white image. Needs ImageMagick (in the devcontainer image); the output is the
# same byte for byte on every run.
#   tools/draw_touch_icons.sh [output-dir]
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="${1:-${here}/game/resources/ui/touch}"
work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
mkdir -p "${out}"
# The vendored icons' ring, scaled from 1024 to 256: centre radius 123.2, 8 thick.
ring=(-fill none -stroke white -strokewidth 8 -draw "circle 128,128 128,4.8")

# The car: body and cabin as one outline; then the two side windows (a pillar
# between them), the wheel arches cut out and the wheels drawn back inside them.
# Drawn 1.12 times its outline's size about the centre, to fill the ring as the
# vendored feet do.
car="affine 1.12,0,0,1.12,-15.36,-15.36"
magick -size 256x256 xc:black -stroke none \
  -fill white -draw "${car} polygon 40,152 40,128 50.67,117.33 77.33,114.67 98.67,80 152,80 176,114.67 202.67,120 216,130.67 216,152 208,157.33 45.33,157.33" \
  -fill black -draw "${car} polygon 130,89.33 147.73,89.33 164.4,113.33 130,113.33" \
  -draw "${car} polygon 103.6,89.33 120.67,89.33 120.67,113.33 88.8,113.33" \
  -draw "${car} circle 77.33,157.33 77.33,132" -draw "${car} circle 178.67,157.33 178.67,132" \
  -fill white -draw "${car} circle 77.33,157.33 77.33,138.67" -draw "${car} circle 178.67,157.33 178.67,138.67" \
  "${ring[@]}" "${work}/car.png"

# The drop: the RISE icon's ground (the inner circle below its chord), then the arrow.
magick -size 256x256 xc:black -stroke none \
  -fill white -draw "circle 128,128 128,16.8" \
  -fill black -draw "rectangle 0,0 256,195.5" \
  -fill white -draw "polygon 110.67,42.67 145.33,42.67 145.33,122.67 178.67,122.67 128,181.33 77.33,122.67 110.67,122.67" \
  "${ring[@]}" "${work}/drop.png"

# The handbrake lamp: the ring, the arcs either side and the P's stem and bowl,
# all one stroke weight.
magick -size 256x256 xc:black -fill none -stroke white -strokewidth 14 \
  -draw "circle 128,128 128,78" -draw "arc 44,44 212,212 138,222" -draw "arc 44,44 212,212 -42,42" \
  -draw "path 'M 115,106 L 130,106 A 14,14 0 0,1 130,134 L 115,134'" \
  -stroke none -fill white -draw "rectangle 108,99 122,157" \
  "${ring[@]}" "${work}/brake.png"

for name in car drop brake; do
  magick -size 256x256 xc:white "${work}/${name}.png" -alpha off -compose CopyOpacity -composite \
    -depth 8 -strip -define png:exclude-chunks=date,time "${out}/icon-${name}.png"
done
