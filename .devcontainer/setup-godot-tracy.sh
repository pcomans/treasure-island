#!/usr/bin/env bash
# Optional native profiling toolchain. Does not replace the pinned stock editor.
set -euo pipefail
root="${GODOT_TRACY_ROOT:-/opt/godot/tracy-4.7.2}"
jobs="${GODOT_TRACY_JOBS:-8}"
sudo apt-get update -qq
sudo apt-get install -y -qq build-essential scons cmake ninja-build pkg-config \
  libx11-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev libglu1-mesa-dev \
  libasound2-dev libpulse-dev libudev-dev libxi-dev libxrandr-dev libwayland-dev \
  libxkbcommon-dev libdbus-1-dev libzstd-dev
mkdir -p "$root"
if [ ! -d "$root/godot/.git" ]; then
  git clone --depth 1 --branch 4.7.2-stable https://github.com/godotengine/godot.git "$root/godot"
fi
if [ ! -d "$root/tracy/.git" ]; then
  git clone --depth 1 --branch v0.13.0 https://github.com/wolfpld/tracy.git "$root/tracy"
fi
[ "$(git -C "$root/godot" rev-parse HEAD)" = ed1daf0bf001b61586d9930840f2f1394092c079 ]
[ "$(git -C "$root/tracy" rev-parse HEAD)" = e6b9ea460993a6f093283055ef3c98025b19f909 ]
# Reused sources must remain upstream stock, including local SCons configuration.
for source in "$root/godot" "$root/tracy"; do
  [ -z "$(git -C "$source" status --porcelain --untracked-files=normal -- . ':!capture/build' ':!csvexport/build')" ] || {
    echo "Refusing modified profiling source: $source" >&2
    exit 1
  }
done
[ ! -e "$root/godot/custom.py" ] || {
  echo "Refusing local Godot custom.py build overrides" >&2
  exit 1
}
for app in capture csvexport; do
  cmake -S "$root/tracy/$app" -B "$root/tracy/$app/build" -G Ninja -DCMAKE_BUILD_TYPE=Release
  cmake --build "$root/tracy/$app/build" --parallel "$jobs"
done
cd "$root/godot"
scons -j"$jobs" platform=linuxbsd target=template_release production=yes \
  debug_symbols=yes profiler=tracy profiler_path="$root/tracy"
