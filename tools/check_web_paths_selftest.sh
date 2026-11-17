#!/usr/bin/env bash
# Checks tools/check_web_paths.py, the web build's check that the exported page
# loads every file by a path relative to itself (tools/build-web.sh), on a page
# shaped like Godot's export with tools/build-web.sh's web app manifest: the page
# passes, with a link out of the game and a comment that quotes a root path, and
# names its manifest's icons; it fails when its engine script comes from the
# site's root, when the loader's pack comes from another origin, when a <base>
# element moves every path, when its manifest link starts at the site's root, when
# the manifest's start_url, scope or an icon leaves the page's folder, when its
# start_url is outside its scope, when it sets an id, when it isn't JSON, and when
# a file the page or the manifest loads is missing from the build. No network and
# no engine; well under a second. Part of tools/test.sh.
#
#   tools/check_web_paths_selftest.sh
set -euo pipefail
cd "$(dirname "$0")/.."
check="${PWD}/tools/check_web_paths.py"
work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
failures=0
fail() { echo "FAIL: $*"; failures=$((failures + 1)); }

build="${work}/build"
mkdir -p "${build}"
name=treasure-island-0123abcd
for file in icon.png png js wasm pck audio.worklet.js audio.position.worklet.js icon-192.png icon-maskable-512.png; do
  : > "${build}/${name}.${file}"
done
cat > "${build}/${name}.webmanifest" <<EOF
{
  "name": "Check",
  "start_url": "./",
  "scope": "./",
  "display": "fullscreen",
  "icons": [
    {"src": "${name}.icon-192.png", "sizes": "192x192", "type": "image/png", "purpose": "any"},
    {"src": "${name}.icon-maskable-512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable"}
  ]
}
EOF
cat > "${build}/index.html" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Check</title>
<link rel="manifest" href="${name}.webmanifest">
<link id="-gd-engine-icon" rel="icon" type="image/png" href="${name}.icon.png" />
</head>
<body>
<canvas id="canvas"></canvas>
<img id="status-splash" src="${name}.png" alt="">
<a href="https://github.com/pcomans/treasure-island">The source</a>
<script src="${name}.js"></script>
<script>
const GODOT_CONFIG = {"args":[],"executable":"${name}","fileSizes":{"${name}.pck":1,"${name}.wasm":1},"gdextensionLibs":[]};
// The engine's job, not the page's: it doesn't fetch '/x' from here.
const pack = GODOT_CONFIG.mainPack || GODOT_CONFIG.executable + '.pck';
</script>
</body>
</html>
EOF

# run PAGE: the check's exit status; its output goes to ${work}/out.
run() {
  local status=0
  python3 -I "${check}" "$1" "${build}" > "${work}/out" 2>&1 || status=$?
  echo "${status}"
}
status="$(run "${build}/index.html")"
[ "${status}" = 0 ] || fail "the good page failed (exit ${status}): $(cat "${work}/out")"
grep -q -F "${name}.pck" "${work}/out" && grep -q -F "${name}.audio.worklet.js" "${work}/out" \
  || fail "the good page's PASS does not name the loader's pack and audio worklet: $(cat "${work}/out")"
grep -q -F "${name}.webmanifest" "${work}/out" && grep -q -F "${name}.icon-maskable-512.png" "${work}/out" \
  || fail "the good page's PASS does not name its manifest and the manifest's icons: $(cat "${work}/out")"

# mutate LABEL OLD NEW SHOWN: the good page with OLD replaced by NEW must fail,
# and its failure must show SHOWN.
mutate() {
  local page="${work}/$1.html"
  python3 -I -c 'import sys
text = open(sys.argv[1], encoding="utf-8").read()
if sys.argv[2] not in text:
    sys.exit("not in the good page: " + sys.argv[2])
open(sys.argv[4], "w", encoding="utf-8").write(text.replace(sys.argv[2], sys.argv[3], 1))' \
    "${build}/index.html" "$2" "$3" "${page}"
  status="$(run "${page}")"
  [ "${status}" = 1 ] || fail "$1: exited ${status}, not 1: $(cat "${work}/out")"
  grep -q -F -- "$4" "${work}/out" || fail "$1: the failure does not show $4: $(cat "${work}/out")"
}
mutate root-script "src=\"${name}.js\"" "src=\"/${name}.js\"" "https://site.invalid/${name}.js"
mutate other-origin-pack '"executable":' '"mainPack":"https://cdn.example/x.pck","executable":' "https://cdn.example/x.pck"
mutate base '<head>' '<head><base href="/">' "<base>"
mutate root-manifest "href=\"${name}.webmanifest\"" "href=\"/${name}.webmanifest\"" "https://site.invalid/${name}.webmanifest"

# mutate_manifest LABEL OLD NEW SHOWN: the good page with its manifest's OLD
# replaced by NEW must fail, and its failure must show SHOWN. The good manifest
# goes back after.
mutate_manifest() {
  local manifest="${build}/${name}.webmanifest"
  cp "${manifest}" "${work}/good.webmanifest"
  python3 -I -c 'import sys
text = open(sys.argv[1], encoding="utf-8").read()
if sys.argv[2] not in text:
    sys.exit("not in the good manifest: " + sys.argv[2])
open(sys.argv[1], "w", encoding="utf-8").write(text.replace(sys.argv[2], sys.argv[3], 1))' "${manifest}" "$2" "$3"
  status="$(run "${build}/index.html")"
  [ "${status}" = 1 ] || fail "$1: exited ${status}, not 1: $(cat "${work}/out")"
  grep -q -F -- "$4" "${work}/out" || fail "$1: the failure does not show $4: $(cat "${work}/out")"
  cp "${work}/good.webmanifest" "${manifest}"
}
mutate_manifest root-start-url '"start_url": "./"' '"start_url": "/"' "start_url is '/', which leads to https://site.invalid/,"
mutate_manifest parent-scope '"scope": "./"' '"scope": "../"' "scope is '../', which leads to https://site.invalid/,"
mutate_manifest start-outside-scope '"scope": "./"' '"scope": "./levels/"' "outside its scope /game/levels/"
mutate_manifest root-icon "\"src\": \"${name}.icon-192.png\"" '"src": "/icon.png"' "https://site.invalid/icon.png"
mutate_manifest id '"display":' '"id": "./", "display":' "sets id './'"
mutate_manifest not-json '"scope": "./",' '"scope": "./"' "can't be read as JSON"
rm "${build}/${name}.icon-maskable-512.png"
status="$(run "${build}/index.html")"
[ "${status}" = 1 ] && grep -q -F "${name}.icon-maskable-512.png, which is not in" "${work}/out" \
  || fail "the manifest's missing maskable icon did not fail the check (exit ${status}): $(cat "${work}/out")"
: > "${build}/${name}.icon-maskable-512.png"
rm "${build}/${name}.wasm"
status="$(run "${build}/index.html")"
[ "${status}" = 1 ] && grep -q -F "${name}.wasm, which is not in" "${work}/out" \
  || fail "a missing ${name}.wasm did not fail the check (exit ${status}): $(cat "${work}/out")"

if [ "${failures}" -gt 0 ]; then
  exit 1
fi
echo "PASS: tools/check_web_paths.py passes a page that loads its files and its manifest's icons from beside itself (with a link out of the game and a commented root path), and fails a script from the site's root, a pack from another origin, a <base> element, a manifest from the site's root, a manifest whose start_url, scope or icon leaves the page's folder, whose start_url is outside its scope, that sets an id or isn't JSON, and a file the page or its manifest loads missing from the build"
