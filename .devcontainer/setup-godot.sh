#!/usr/bin/env bash
# Installs the pinned Godot 4.7.2 Linux editor and the Linux, macOS and Web
# export templates into /opt/godot/4.7.2/ (self-contained mode; a volume, see devcontainer.json).
# Skips anything already present, so it is safe to re-run.
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION=4.7.2
BASE="https://github.com/godotengine/godot-builds/releases/download/${VERSION}-stable"
EDITOR_ZIP="Godot_v${VERSION}-stable_linux.x86_64.zip"
EDITOR_SHA256=cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4
TEMPLATES_TPZ="Godot_v${VERSION}-stable_export_templates.tpz"
TEMPLATES_SHA256=f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011

DEST="/opt/godot/${VERSION}"
TEMPLATES_DIR="${DEST}/editor_data/export_templates/${VERSION}.stable"
mkdir -p "${DEST}"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

fetch() { # url sha256 out
  curl -fsSL -o "$3" "$1"
  echo "$2  $3" | sha256sum -c --quiet
}

if [ ! -x "${DEST}/godot" ]; then
  fetch "${BASE}/${EDITOR_ZIP}" "${EDITOR_SHA256}" "${tmp}/editor.zip"
  unzip -q -o "${tmp}/editor.zip" -d "${tmp}/editor"
  mv "${tmp}/editor/Godot_v${VERSION}-stable_linux.x86_64" "${DEST}/godot"
  chmod +x "${DEST}/godot"
fi
# An empty _sc_ file next to the binary keeps editor settings and templates
# inside ${DEST}/editor_data instead of ~/.local/share.
touch "${DEST}/_sc_"

# The templates the export presets use, all from the one archive above. Web is
# the single-threaded ("nothreads") build, which needs no COOP/COEP headers.
TEMPLATES=(version.txt linux_debug.x86_64 linux_release.x86_64 macos.zip
  web_nothreads_debug.zip web_nothreads_release.zip)
missing=()
for name in "${TEMPLATES[@]}"; do
  [ -f "${TEMPLATES_DIR}/${name}" ] || missing+=("templates/${name}")
done
if [ ${#missing[@]} -gt 0 ]; then
  fetch "${BASE}/${TEMPLATES_TPZ}" "${TEMPLATES_SHA256}" "${tmp}/templates.tpz"
  unzip -q -o "${tmp}/templates.tpz" -d "${tmp}/t" "${missing[@]}"
  mkdir -p "${TEMPLATES_DIR}"
  mv "${tmp}"/t/templates/* "${TEMPLATES_DIR}/"
fi

"${DEST}/godot" --version
