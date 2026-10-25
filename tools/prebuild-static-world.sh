#!/usr/bin/env bash
# Shared rendered bake; callers own artifact lifetime through export/checks.
set -euo pipefail
cd "$(dirname "$0")/.."
case "${1:-}" in
  web) renderer=(--rendering-method gl_compatibility --rendering-driver opengl3); flag=--web-world-bake ;;
  native) renderer=(--rendering-method forward_plus --rendering-driver vulkan); flag=--native-world-bake ;;
  *) echo "Usage: tools/prebuild-static-world.sh web|native" >&2; exit 1 ;;
esac
baked="generated/$1/static_world.scn"
mkdir -p "$(dirname "$baked")"
rm -f "$baked"
tools/godot "${renderer[@]}" --path . --script tools/prebuild_static_world.gd -- "$flag"
test -s "$baked"
