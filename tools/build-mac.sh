#!/usr/bin/env bash
# Builds the game for the owner's Mac, from the current commit.
#
#   tools/build-mac.sh            -> build/mac/treasure-island-mac-<commit>.zip
#
# Unzip on the Mac, then right-click the app -> Open the first time (it is
# ad-hoc signed, not notarized). Before handing it over this
#   1. exports the macOS build and a Linux build of the same commit,
#   2. checks both data packs contain only game files (no reference photos,
#      research or evidence),
#   3. launches the Linux build on the GPU and checks the island loads.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "${root}"
if [ -n "$(git status --porcelain)" ]; then
  echo "FAIL: commit or stash your changes first; the build is named after the commit" >&2
  exit 1
fi
revision="$(git rev-parse HEAD)"
commit="$(git rev-parse --short HEAD)"
baked=generated/native/static_world.scn
work="$(mktemp -d)"
trap 'rm -rf "${work}"; rm -f "${baked}"' EXIT
tools/prebuild-static-world.sh native
if [ "$(git rev-parse HEAD)" != "${revision}" ] || [ -n "$(git status --porcelain)" ]; then
  echo "FAIL: source changed during static-world baking" >&2
  exit 1
fi
mkdir -p build/mac build/linux
touch build/.gdignore
zip="build/mac/treasure-island-mac-${commit}.zip"
rm -f "${zip}"

tools/godot --headless --path . --export-release "macOS Private" "${zip}"
tools/godot --headless --path . --export-release "Linux Private" build/linux/treasure-island.x86_64

unzip -q "${zip}" -d "${work}"
mac_pck="$(find "${work}" -name '*.pck' -path '*Contents/Resources*' | head -1)"
[ -n "${mac_pck}" ] || { echo "FAIL: no .pck inside the Mac build"; exit 1; }
for pck in "${mac_pck}" "${root}/build/linux/treasure-island.pck"; do
  # Run from an empty folder so Godot sees only the pack, not the source project.
  (cd "${work}" && timeout 120 "${root}/tools/godot" --headless --main-pack "${pck}" --script res://game/tests/shared/build_content_audit.gd)
done

log="${work}/launch.log"
# The only expected error: the game asks to capture a mouse the headless display doesn't have.
errors() { grep -E '^ERROR|SCRIPT ERROR' "${log}" | grep -v 'Parameter "ss" is null'; }
if ! GODOT_BIN="${root}/build/linux/treasure-island.x86_64" timeout 300 tools/godot --audio-driver Dummy -- --quit-on-ready >"${log}" 2>&1 \
  || ! grep -q WORLD_READY "${log}" || errors >/dev/null; then
  errors | head -20
  echo "FAIL: the exported build did not load the island cleanly and exit"
  exit 1
fi
echo "PASS: ${zip}"
