#!/usr/bin/env bash
# Builds the game for the owner's Mac, from the current commit.
#
#   tools/build-mac.sh            -> build/mac/treasure-island-mac-<commit>.zip
#
# Unzip on the Mac, then right-click the app -> Open the first time (it is
# ad-hoc signed, not notarized). Before handing it over this
#   1. exports the macOS build and a Linux build of the same commit,
#   2. checks the data pack for reference photos / research material,
#   3. launches the Linux build on the GPU and checks the island loads.
set -euo pipefail
cd "$(dirname "$0")/.."
commit="$(git rev-parse --short HEAD)"
git diff --quiet HEAD || echo "NOTE: uncommitted changes are included in this build"
mkdir -p build/mac build/linux
touch build/.gdignore
zip="build/mac/treasure-island-mac-${commit}.zip"
rm -f "${zip}"

tools/godot --headless --path . --export-release "macOS Private" "${zip}"
tools/godot --headless --path . --export-release "Linux Private" build/linux/treasure-island.x86_64

work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
unzip -q "${zip}" -d "${work}"
pck="$(find "${work}" -name '*.pck' -path '*Contents/Resources*' | head -1)"
[ -n "${pck}" ] || { echo "FAIL: no .pck inside the Mac build"; exit 1; }
# Run from an empty folder so Godot sees only the pack, not the source project.
(cd "${work}" && "${OLDPWD}/tools/godot" --headless --main-pack "${pck}" --script res://game/tests/shared/build_content_audit.gd)

log="${work}/launch.log"
GODOT_BIN="$(pwd)/build/linux/treasure-island.x86_64" tools/godot --audio-driver Dummy --quit-after 3600 >"${log}" 2>&1 || true
if ! grep -q WORLD_READY "${log}" || grep -qE 'WORLD_FAILED|SCRIPT ERROR' "${log}"; then
  grep -E 'WORLD_FAILED|SCRIPT ERROR|ERROR' "${log}" | head -20
  echo "FAIL: the exported build did not load the island cleanly"
  exit 1
fi
echo "PASS: ${zip}"
