#!/usr/bin/env bash
# Fetch and assemble the dated aerial tools/build_ybi_land_cover.mjs reads, into a
# directory outside Git (the aerial never enters the repository):
#
#   tools/fetch_ybi_aerial.sh DIR
#   node tools/build_ybi_land_cover.mjs --mosaic DIR
#
# Esri World Imagery Wayback release 43291 (2026-10-29), public and account-free, zoom
# 19, tiles x 83923-83947 and y 202572-202591 (25 x 20 tiles of 256 px): over Yerba Buena
# Island its imagery is the 2026-05-26 Vantor capture (0.34 m; World_Imagery_Metadata_
# 2026_r10 layer 4 at five points on the island, queried 2026-11-07). Writes DIR/t/Y_X.jpg,
# DIR/mosaic.rgb (the tiles north-up, raw 8-bit RGB) and DIR/mosaic.json.
set -euo pipefail
out="${1:?usage: tools/fetch_ybi_aerial.sh DIR}"
release=43291; z=19; x0=83923; y0=202572; nx=25; ny=20
url="https://wayback.maptiles.arcgis.com/arcgis/rest/services/World_Imagery/WMTS/1.0.0/default028mm/MapServer/tile/${release}/${z}"
mkdir -p "${out}/t"
tiles=()
for ((y = y0; y < y0 + ny; y++)); do
  for ((x = x0; x < x0 + nx; x++)); do
    tile="${out}/t/${y}_${x}.jpg"
    [ -s "${tile}" ] || curl -sSf -m 30 -L -o "${tile}" "${url}/${y}/${x}"
    tiles+=("${tile}")
  done
done
magick montage "${tiles[@]}" -tile "${nx}x${ny}" -geometry 256x256+0+0 -depth 8 "rgb:${out}/mosaic.rgb"
printf '{"release":"%s","z":%d,"X0":%d,"Y0":%d,"nx":%d,"ny":%d,"tile_px":256}\n' "${release}" "${z}" "${x0}" "${y0}" "${nx}" "${ny}" > "${out}/mosaic.json"
echo "${out}/mosaic.rgb: $((nx * 256))x$((ny * 256)) RGB from ${#tiles[@]} tiles"
