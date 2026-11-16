#!/usr/bin/env bash
# Builds the game for web browsers, from the current commit.
#
#   tools/build-web.sh            -> build/web/ (index.html and the files it loads)
#   tools/build-web.sh --sfx-require-all --sfx-result FILE
#                                 the same, for players (tools/deploy-web.sh): the sound
#                                 fetch must give every sound the game plays its takes, or
#                                 the build stops there (tools/fetch-sfx --require-all), and
#                                 it writes what it fetched to FILE as JSON (--result).
#                                 Either flag may be given alone.
#
# build/web is a static site: serve it locally or deploy it to Vercel. Godot's web platform only has the Compatibility
# renderer (WebGL 2). Before handing it over this
#   1. exports the single-threaded web build, which needs no special headers,
#   2. checks the data pack contains only game files (no reference photos,
#      research or evidence),
#   3. writes the web app manifest and its icons for a phone's home screen,
#   4. checks the page, the manifest and Godot's loader fetch every file by a path
#      relative to the page (tools/check_web_paths.py): players reach the game in
#      a folder of its website, https://grandtreasureisland.vercel.app/game/,
#   5. writes vercel.json so browsers cache the large files for good, and a
#      .vercelignore so the Vercel CLI never uploads an .env file.
set -euo pipefail
fetch_args=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --sfx-require-all) fetch_args+=(--require-all) ;;
    --sfx-result)
      [ "$#" -ge 2 ] || { echo "tools/build-web.sh: --sfx-result needs a file" >&2; exit 2; }
      fetch_args+=(--result "$2")
      shift ;;
    *) echo "usage: tools/build-web.sh [--sfx-require-all] [--sfx-result FILE]" >&2; exit 2 ;;
  esac
  shift
done
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "${root}"
command -v magick > /dev/null || { echo "FAIL: the home screen icons need ImageMagick's magick command, which .devcontainer/post-create.sh installs (apt package imagemagick)" >&2; exit 1; }
if [ -n "$(git status --porcelain)" ]; then
  echo "FAIL: commit or stash your changes first; the build is named after the commit" >&2
  exit 1
fi
# Every file except index.html is named after the commit, so a new build never
# reuses a cached file name.
revision="$(git rev-parse HEAD)"
name="treasure-island-$(git rev-parse --short HEAD)"
out=build/web
mkdir -p "${out}"
# Clear the previous build but keep .vercel, the Vercel CLI's link to the project.
find "${out}" -mindepth 1 -maxdepth 1 ! -name .vercel -exec rm -rf {} +
touch build/.gdignore
# Use committed files and a disposable import cache so the Web cap cannot affect
# the editor, native builds, or another checkout.
work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
project="${work}/project"
mkdir -p "${project}" "${work}/mount"
git archive "${revision}" | tar -xf - -C "${project}"
# The sound files from the private source in TI_SFX_SOURCE, into this copy's
# game/resources/audio/sfx/ (tools/fetch-sfx; never in Git, so not in the archive).
# Without a source this does nothing and the web build is silent, unless
# --sfx-require-all asked for every sound.
tools/fetch-sfx --project "${project}" "${fetch_args[@]}"
# The token was for the fetch alone.
unset TI_SFX_GIT_TOKEN

# Godot can exit 0 after an import error, so check its output too.
import_project() {
  local output status=0
  local errors='SCRIPT ERROR|Parse Error|Failed to load script|^ERROR'
  output="$(cd "${project}" && timeout 300 tools/godot --headless --path . --import 2>&1)" || status=$?
  if [ "${status}" -ne 0 ] || grep -qE "${errors}" <<< "${output}"; then
    grep -E "${errors}|ERROR" <<< "${output}" | head -20 || true
    echo "FAIL: the Godot import exited ${status} or reported engine errors" >&2
    exit 1
  fi
}

# Bake with the original imports. Only the texture payloads in the export are
# resized. Keep the bake outside the import scan while updating those textures.
# Each line of the cap list names a texture's .import and, where 512 would leave a
# side that isn't a multiple of 4, a smaller cap that doesn't
# (game/tests/headless_world_material_contract.gd checks every capped size).
import_project
(cd "${project}" && tools/prebuild-static-world.sh web)
baked="${project}/generated/web/static_world.scn"
mv "${baked}" "${work}/static_world.scn"
while read -r sidecar cap; do
  source="${project}/${sidecar}"
  if ! awk -v cap="${cap:-512}" '
    /^process\/size_limit=/ { count++; if ($0 != "process/size_limit=0") exit 1; $0 = "process/size_limit=" cap }
    { print }
    END { if (count != 1) exit 1 }
  ' "${source}" > "${work}/texture.import"; then
    echo "FAIL: expected an uncapped import setting in ${sidecar}" >&2
    exit 1
  fi
  mv "${work}/texture.import" "${source}"
done < "${project}/tools/web-texture-cap-512.txt"
import_project
mv "${work}/static_world.scn" "${baked}"
if [ "$(git rev-parse HEAD)" != "${revision}" ] || [ -n "$(git status --porcelain)" ]; then
  echo "FAIL: source changed during the import or static-world bake; commit and rebuild" >&2
  exit 1
fi

(cd "${project}" && tools/godot --headless --path . --export-release "Web" "${root}/${out}/${name}.html")
mv "${out}/${name}.html" "${out}/index.html"

# The home screen (owner, 2026-11-16; game/web/shell.html): the web app manifest,
# which opens the game full screen from a phone's home screen, and its icons, the
# app icon's chest (game/resources/ui/PROVENANCE.md) from the committed master:
# 192 and 512 px on a transparent square (Android's splash screen puts them on the
# background colour) and a 512 px maskable one for Android's launcher, every
# pixel of the chest inside the middle 80 % circle its mask keeps, on the loading
# screen's colour. An iPhone takes the exporter's apple-touch-icon instead. Named
# after the commit like the game's files, so cached for good (vercel.json); its
# start_url and scope are the page's own folder, at the site's root and under
# /game/ alike. The manifest leaves orientation free: the game fills either shape.
home_colour='#242424'
master="${project}/game/resources/ui/app_icon.png"
png=(-depth 8 -strip -define png:exclude-chunks=date,time)
for size in 192 512; do
  magick "${master}" -filter Lanczos -resize "${size}x${size}" "${png[@]}" "PNG32:${out}/${name}.icon-${size}.png"
done
magick -size 512x512 "xc:${home_colour}" \( "${master}" -filter Lanczos -resize 352x352 \) \
  -gravity center -composite -alpha off "${png[@]}" "PNG24:${out}/${name}.icon-maskable-512.png"
python3 -I - "${out}" "${name}" "${home_colour}" <<'EOF'
import json, sys
from pathlib import Path
out, name, colour = Path(sys.argv[1]), sys.argv[2], sys.argv[3]
icon = lambda file, size, purpose: {"src": file, "sizes": size, "type": "image/png", "purpose": purpose}
manifest = {
    "name": "Grand Treasure Island",
    "short_name": "Treasure Island",
    "start_url": "./",
    "scope": "./",
    "display": "fullscreen",
    "background_color": colour,
    "theme_color": colour,
    "icons": [
        icon(name + ".icon-192.png", "192x192", "any"),
        icon(name + ".icon-512.png", "512x512", "any"),
        icon(name + ".icon-maskable-512.png", "512x512", "maskable"),
    ],
}
(out / (name + ".webmanifest")).write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
page = out / "index.html"
text = page.read_text(encoding="utf-8")
link = 'href="$TI_WEB_MANIFEST"'
if text.count(link) != 1:
    sys.exit("FAIL: %s has %d manifest links to fill (%s in game/web/shell.html), not 1" % (page, text.count(link), link))
page.write_text(text.replace(link, 'href="%s.webmanifest"' % name), encoding="utf-8")
EOF

# Run from an empty folder so Godot sees only the pack, not the source project.
(cd "${work}/mount" && timeout 120 "${root}/tools/godot" --headless --main-pack "${root}/${out}/${name}.pck" --script res://game/tests/shared/build_content_audit.gd)
# The website serves the game from its /game/ folder, so a file named from the
# site's root or another origin would not load there.
python3 -I tools/check_web_paths.py "${out}/index.html" "${out}"

cat >"${out}/vercel.json" <<'EOF'
{
  "headers": [
    {
      "source": "/treasure-island-(.*)",
      "headers": [{ "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }]
    },
    {
      "source": "/(.*).wasm",
      "headers": [{ "key": "Content-Type", "value": "application/wasm" }]
    }
  ]
}
EOF
# The CLI skips its own list (.vercel, .env.local, ...) and these patterns.
printf '.env*\n' >"${out}/.vercelignore"
echo "PASS: ${out}/index.html ($(du -sh "${out}" | cut -f1))"
