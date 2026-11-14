#!/usr/bin/env bash
# Native Linux export with the same static bake used by future Mac builds.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
if [ -n "$(git status --porcelain)" ]; then
  echo "FAIL: commit changes before building" >&2
  exit 1
fi
revision="$(git rev-parse HEAD)"
mkdir -p build/linux
touch build/.gdignore
# Optional: the sound files from the private source in TI_SFX_SOURCE, into the
# ignored game/resources/audio/sfx/ (tools/fetch-sfx). Without a source this does
# nothing and the build plays whatever that folder holds, or nothing.
tools/fetch-sfx
baked=generated/native/static_world.scn
work="$(mktemp -d)"
trap 'rm -rf "$work"; rm -f "$baked"' EXIT
# A fresh checkout has nothing imported yet, and the bake and export need it.
# Godot can exit 0 after an import error, so check its output too, as tools/test.sh does.
godot_errors='SCRIPT ERROR|Parse Error|Failed to load script|^ERROR'
status=0
imported="$(timeout 300 tools/godot --headless --path . --import 2>&1)" || status=$?
if [ "$status" -ne 0 ] || grep -qE "$godot_errors" <<< "$imported"; then
  grep -E "$godot_errors|ERROR" <<< "$imported" | head -20 || true
  echo "FAIL: the Godot import exited $status or reported engine errors" >&2
  exit 1
fi
tools/prebuild-static-world.sh native
if [ "$(git rev-parse HEAD)" != "$revision" ] || [ -n "$(git status --porcelain)" ]; then
  echo "FAIL: source changed during the import or static-world bake" >&2
  exit 1
fi
tools/godot --headless --path . --export-release "Linux Private" build/linux/treasure-island.x86_64
(cd "$work" && "$root/tools/godot" --headless --main-pack "$root/build/linux/treasure-island.pck" --script res://game/tests/shared/build_content_audit.gd)
echo "PASS: build/linux/treasure-island.x86_64"
