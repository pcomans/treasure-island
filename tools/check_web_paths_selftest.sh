#!/usr/bin/env bash
# Checks tools/check_web_paths.py, the web build's check that the exported page
# loads every file by a path relative to itself (tools/build-web.sh), on a page
# shaped like Godot's export: the page passes, with a link out of the game and a
# comment that quotes a root path; it fails when its engine script comes from the
# site's root, when the loader's pack comes from another origin, when a <base>
# element moves every path, and when a file it loads is missing from the build.
# No network and no engine; well under a second. Part of tools/test.sh.
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
for file in icon.png png js wasm pck audio.worklet.js audio.position.worklet.js; do
  : > "${build}/${name}.${file}"
done
cat > "${build}/index.html" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Check</title>
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
rm "${build}/${name}.wasm"
status="$(run "${build}/index.html")"
[ "${status}" = 1 ] && grep -q -F "${name}.wasm, which is not in" "${work}/out" \
  || fail "a missing ${name}.wasm did not fail the check (exit ${status}): $(cat "${work}/out")"

if [ "${failures}" -gt 0 ]; then
  exit 1
fi
echo "PASS: tools/check_web_paths.py passes a page that loads its files from beside itself (with a link out of the game and a commented root path), and fails a script from the site's root, a pack from another origin, a <base> element and a file missing from the build"
