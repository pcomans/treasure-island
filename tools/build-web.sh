#!/usr/bin/env bash
# Builds the game for web browsers, from the current commit.
#
#   tools/build-web.sh            -> build/web/ (index.html and the files it loads)
#
# build/web is a static site: serve it locally or deploy it to Vercel (see
# README, "Play in a browser"). Godot's web platform only has the Compatibility
# renderer (WebGL 2). Before handing it over this
#   1. exports the single-threaded web build, which needs no special headers,
#   2. checks the data pack contains only game files (no reference photos,
#      research or evidence),
#   3. writes vercel.json so browsers cache the large files for good.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "${root}"
if [ -n "$(git status --porcelain)" ]; then
  echo "FAIL: commit or stash your changes first; the build is named after the commit" >&2
  exit 1
fi
# Every file except index.html is named after the commit, so a new build never
# reuses a cached file name.
name="treasure-island-$(git rev-parse --short HEAD)"
out=build/web
mkdir -p "${out}"
# Clear the previous build but keep .vercel, the Vercel CLI's link to the project.
find "${out}" -mindepth 1 -maxdepth 1 ! -name .vercel -exec rm -rf {} +
touch build/.gdignore

tools/godot --headless --path . --export-release "Web" "${out}/${name}.html"
mv "${out}/${name}.html" "${out}/index.html"

work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
# Run from an empty folder so Godot sees only the pack, not the source project.
(cd "${work}" && timeout 120 "${root}/tools/godot" --headless --main-pack "${root}/${out}/${name}.pck" --script res://game/tests/shared/build_content_audit.gd)

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
echo "PASS: ${out}/index.html ($(du -sh "${out}" | cut -f1))"
