#!/usr/bin/env bash
# Builds the game for web browsers, from the current commit.
#
#   tools/build-web.sh            -> build/web/ (index.html and the files it loads)
#
# build/web is a static site: serve it locally or deploy it to Vercel. Godot's web platform only has the Compatibility
# renderer (WebGL 2). Before handing it over this
#   1. exports the single-threaded web build, which needs no special headers,
#   2. checks the data pack contains only game files (no reference photos,
#      research or evidence),
#   3. writes vercel.json so browsers cache the large files for good, and a
#      .vercelignore so the Vercel CLI never uploads an .env file.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "${root}"
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

# Run from an empty folder so Godot sees only the pack, not the source project.
(cd "${work}/mount" && timeout 120 "${root}/tools/godot" --headless --main-pack "${root}/${out}/${name}.pck" --script res://game/tests/shared/build_content_audit.gd)

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
