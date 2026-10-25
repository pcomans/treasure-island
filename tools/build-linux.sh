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
baked=generated/native/static_world.scn
work="$(mktemp -d)"
trap 'rm -rf "$work"; rm -f "$baked"' EXIT
tools/prebuild-static-world.sh native
if [ "$(git rev-parse HEAD)" != "$revision" ] || [ -n "$(git status --porcelain)" ]; then
  echo "FAIL: source changed during static-world baking" >&2
  exit 1
fi
tools/godot --headless --path . --export-release "Linux Private" build/linux/treasure-island.x86_64
(cd "$work" && "$root/tools/godot" --headless --main-pack "$root/build/linux/treasure-island.pck" --script res://game/tests/shared/build_content_audit.gd)
echo "PASS: build/linux/treasure-island.x86_64"
