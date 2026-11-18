#!/usr/bin/env bash
# The web build's shader proof: once loading has ended, no shader program is compiled
# (the shader warm-up, game/scripts/world/shader_warm_up.gd). Run it on a web export
# before a web release:
#
#   tools/web_shader_proof.sh EXPORT_DIR OUT_DIR
#
# EXPORT_DIR is a web export (tools/build-web.sh's build/web). It is served on
# loopback (a secure context: Godot's web engine refuses plain HTTP anywhere else),
# and the drive trace (?trace=drive, game/scripts/debug/drive_trace.gd: the drive round
# the island, the foot and jetpack legs, then a fence bay broken, a street prop felled,
# a car's splash, goal confetti and the web's 3D resolutions in turn) runs in two
# browsers, one after the other, each headed on a private Weston on the GPU
# (tools/web_trace/session.sh): Playwright's WebKit as an iPhone 16 Pro held sideways
# (874 x 402 CSS px at 3x, touch) and Chrome for Testing as a desktop (1440 x 900).
# For each, tools/web_trace/after_loading.mjs lists every WebGL program the page saw
# compiled after the game's play handoff, with the window it fell in and its decoded
# variant (OUT_DIR/BROWSER/programs.txt, with each loading line's time). PASS when
# neither browser compiled one; FAIL lines and exit 1 otherwise (2: a session did not
# complete). Nothing is sent anywhere: the trace keeps its records in the page, and
# the rig reads them there. Each session takes about 10 minutes.
#
# A pass writes build/shader-proof/COMMIT.pass (COMMIT this checkout's full HEAD, which
# the export must be the build of), which tools/deploy-web.sh requires.
# Run it in an engine slot, like any other GPU work (tools/check-web-live.sh).
# Needs: Playwright 1.65.1 installed with npm's global root (PW_MODULE overrides), its
# WebKit build, and Chrome for Testing (agent-browser's, from .devcontainer/
# setup-browser.sh; TI_CHROME_EXEC overrides). TI_WEBKIT_EXEC names an executable that
# starts Playwright's WebKit MiniBrowser with the libraries it needs, where they are not
# installed system wide. PORT (default 8653) is the loopback port it serves on.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="/usr/local/share/nvm/current/bin:${PATH}"
usage="usage: tools/web_shader_proof.sh EXPORT_DIR OUT_DIR"
export_dir="${1:?${usage}}"
out_arg="${2:?${usage}}"
[ -f "${export_dir}/index.html" ] || { echo "FAIL: ${export_dir} has no index.html: not a web export" >&2; exit 2; }
mkdir -p "${out_arg}"
out="$(cd "${out_arg}" && pwd)"
port="${PORT:-8653}"
python3 -m http.server "${port}" --bind 127.0.0.1 --directory "${export_dir}" > "${out}/server.log" 2>&1 &
server=$!
trap 'kill "${server}" 2>/dev/null; wait "${server}" 2>/dev/null' EXIT
for _ in $(seq 50); do
  curl -sf -o /dev/null "http://127.0.0.1:${port}/index.html" && break
  sleep 0.2
done
url="http://127.0.0.1:${port}/?trace=drive&profile_startup=1"
failed=0
incomplete=0
for session in webkit:phone chrome:desktop; do
  browser="${session%%:*}"
  profile="${session##*:}"
  dir="${out}/${browser}-${profile}"
  if [ -e "${dir}" ]; then
    echo "FAIL: ${dir} exists; give the proof a fresh OUT_DIR" >&2
    exit 2
  fi
  echo "== ${browser} ${profile}: ${url}"
  URL="${url}" BROWSER="${browser}" PROFILE="${profile}" "${root}/tools/web_trace/session.sh" "${dir}" > "${dir}.session.log" 2>&1
  status=$?
  grep -E "DRIVER_EXIT|SESSION_END|SESSION_FAIL" "${dir}.session.log" | tail -3
  if [ "${status}" -ne 0 ]; then
    echo "FAIL: the ${browser} session did not complete (exit ${status}; ${dir}.session.log, ${dir}/progress.txt)"
    incomplete=1
  fi
  result="$(node "${root}/tools/web_trace/after_loading.mjs" "${dir}")"
  check=$?
  echo "${result}"
  if [ "${check}" -eq 1 ]; then
    echo "FAIL: ${browser} compiled programs after loading: ${dir}/programs.txt"
    failed=1
  elif [ "${check}" -ne 0 ]; then
    incomplete=1
  fi
done
if [ "${incomplete}" -ne 0 ]; then
  exit 2
fi
if [ "${failed}" -ne 0 ]; then
  exit 1
fi
# The receipt tools/deploy-web.sh asks for, named by this checkout's full HEAD, written
# only when the export is that commit's build (its files' treasure-island-COMMIT
# prefix, however long, starts HEAD): the proof and the deploy run in one checkout.
named="$(ls "${export_dir}" | sed -n 's/^treasure-island-\([0-9a-f]\{7,40\}\)\.js$/\1/p' | head -1)"
head="$(git -C "${root}" rev-parse HEAD)"
if [ -z "${named}" ] || [ "${head#"${named}"}" = "${head}" ]; then
  echo "FAIL: no program compiled after loading, but no receipt: the export names commit '${named:-none}', not this checkout's HEAD ${head:0:12} (build it here and prove that): ${out}"
  exit 1
fi
mkdir -p "${root}/build/shader-proof"
printf 'PASS %s commit %s, %s\n' "$(date -u +%FT%TZ)" "${head}" "${out}" > "${root}/build/shader-proof/${head}.pass"
echo "PASS: no shader program compiled after loading, in WebKit (phone, 3x) or Chrome (desktop): ${out}"
echo "RECEIPT: build/shader-proof/${head}.pass"
