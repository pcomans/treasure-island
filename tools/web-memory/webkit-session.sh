#!/usr/bin/env bash
# tools/web-memory/webkit-session.sh OUT_DIR SITE_DIR [full|short|probe]: one measured session of a built web site
# (tools/build-web.sh's build/web, or a copy of the live site's files) in WebKit, the engine of every iPhone
# browser, with every process's memory sampled from /proc each second. Nothing here is an iPhone measurement: see
# "What it shares with iOS" below.
#
# The browser is Playwright's Linux build of WebKit main (its GTK MiniBrowser; .devcontainer/setup-browser.sh installs
# it and its libraries), driven by route.cjs, run headed as a Wayland client of a private headless Weston on the GPU,
# as tools/browser runs Chrome (never xvfb, where WebGL falls back to the CPU). Everything the session starts is
# stopped by PID at the end, and its runtime directory and temporary files live inside OUT_DIR, not /tmp. Run it
# under an engine lock (flock -o on the shared locks), like any other engine or browser run.
#
# ROUTE full (default): open the site with ?profile_startup=1 (the game's readback), wait until it is ready, click the
# start prompt with a trusted click, look at the breakwater 45 s, walk to the forecourt sedan, drive five circles,
# jetpack to Pier 1 and back, look at the breakwater 60 s (about 7 min); short: the start prompt and 60 s of looking;
# probe: about:blank only (WebGL 2, WebAssembly, AudioContext and the page memory APIs).
#
# Writes to OUT_DIR: proc.jsonl (sampler.py: every WebKit process's RSS, anon, file, shmem, HWM and the GPU memory
# its DRM clients hold, each second), labels.jsonl (the route's phases), states.jsonl, readback.log, env.json,
# console.txt, hook-end.json (memhook.js: wasm memory, WebGL allocations, AudioBuffers), screenshots, the browser,
# server and Weston logs. `python3 -I tools/web-memory/summarize.py OUT_DIR [--series 30]` prints the load peak,
# the start-prompt level, the play range and slope per process.
#
# Env: CIRCLES, FLIGHTS (route length); WK_EXEC (another MiniBrowser executable for Playwright to start, such as a
# wrapper that adds libraries; default: Playwright's own); WK_ARGS (MiniBrowser arguments, such as
# --features=+UseGPUProcessForWebGL, which moves WebGL into a GPU process as on iOS); JSC_* (JavaScriptCore options
# for the web process, such as JSC_forceRAMSize=2147483648, which sizes the JavaScript heap for an iPhone's 2,048 MB
# WebContent limit as iOS WebKit does from its jetsam limit; JSC_dumpOptions=1 with DEBUG=pw:browser prints them).
#
# What it shares with iOS: WebCore, JavaScriptCore with its garbage collector and allocators, WebKit's WebAssembly
# and Web Audio code. What it does not: iOS runs WebGL in a separate GPU process on Metal (here it runs inside the
# web process on Mesa through ANGLE's OpenGL back end, unless WK_ARGS moves it), 16 KiB pages (4 KiB here), jetsam
# limits and memory warnings (none here; JSC sizes its heap from this machine's RAM unless JSC_forceRAMSize says
# otherwise), and Apple's media stack (GStreamer here). RSS on Linux is not iOS's phys_footprint.
set -uo pipefail
export PATH="/usr/local/share/nvm/current/bin:${PATH}"
here="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "${1:?usage: webkit-session.sh OUT_DIR SITE_DIR [full|short|probe]}"
out="$(cd "$1" && pwd)"; route="${3:-full}"; site="${2:-}"
if [ "${route}" != probe ]; then site="$(cd "${site:?site dir}" && pwd)"; fi
export TMPDIR="${out}/tmp"; mkdir -p "${TMPDIR}"
xdg="${out}/xdg"; mkdir -p "${xdg}"; chmod 700 "${xdg}"
if [ $(( ${#xdg} + 4 )) -ge 100 ]; then echo "SESSION_FAIL the Wayland socket path ${xdg}/wk is too long; use a shorter OUT_DIR"; exit 2; fi
server=""; weston=""; sampler=""; driver=""
owned() { env -u XDG_RUNTIME_DIR grep -lzxF "XDG_RUNTIME_DIR=${xdg}" /proc/[0-9]*/environ 2>/dev/null | cut -d/ -f3; }
cleanup() {
  set +e
  if [ -n "${driver}" ] && kill -0 "${driver}" 2>/dev/null; then echo "DRIVER_STILL_RUNNING ${driver}: TERM"; kill -TERM "${driver}"; sleep 5; kill -KILL "${driver}" 2>/dev/null; fi
  [ -n "${driver}" ] && wait "${driver}" 2>/dev/null
  [ -n "${sampler}" ] && kill -TERM "${sampler}" 2>/dev/null && wait "${sampler}" 2>/dev/null
  [ -n "${server}" ] && kill "${server}" 2>/dev/null && wait "${server}" 2>/dev/null
  # Weston last but one: its own clients (weston-keyboard, the desktop shell) end with it.
  if [ -n "${weston}" ]; then kill "${weston}" 2>/dev/null; wait "${weston}" 2>/dev/null; fi
  sleep 1
  local left="" p
  for p in $(owned); do [ "${p}" = "$$" ] || left+="${p}:$(tr -d '\n' < "/proc/${p}/comm" 2>/dev/null) "; done
  if [ -n "${left}" ]; then
    echo "LEFT_RUNNING [${left}]: TERM"
    for p in ${left}; do kill -TERM "${p%%:*}" 2>/dev/null; done; sleep 3
    for p in ${left}; do kill -0 "${p%%:*}" 2>/dev/null && kill -KILL "${p%%:*}" 2>/dev/null; done
  fi
  left=""
  for p in $(owned); do [ "${p}" = "$$" ] || left+="${p} "; done
  for p in ${server} ${weston} ${sampler} ${driver}; do kill -0 "${p}" 2>/dev/null && left+="${p} "; done
  echo "SESSION_END $(date -u +%FT%TZ) left_running=[${left}]"
  rm -rf "${TMPDIR}" "${xdg}"
}
trap cleanup EXIT
trap 'exit 143' INT TERM
echo "SESSION_START $(date -u +%FT%TZ) out=${out} site=${site:-none} route=${route}"
url=""
if [ "${route}" != probe ]; then
  port=$(python3 -I -c 'import socket; s = socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1]); s.close()')
  python3 -m http.server "${port}" --bind 127.0.0.1 --directory "${site}" > "${out}/server.log" 2>&1 &
  server=$!
  url="http://127.0.0.1:${port}/?profile_startup=1"
  echo "SERVER pid=${server} port=${port}"
fi
XDG_RUNTIME_DIR="${xdg}" weston --backend=headless --renderer=gl --socket=wk --width=1600 --height=1000 --idle-time=0 > "${out}/weston.log" 2>&1 &
weston=$!
for _ in $(seq 1200); do [ -S "${xdg}/wk" ] && break; kill -0 "${weston}" 2>/dev/null || break; sleep 0.1; done
[ -S "${xdg}/wk" ] || { echo "SESSION_FAIL Weston did not start"; tail -5 "${out}/weston.log"; exit 3; }
echo "WESTON pid=${weston} $(grep -m1 'GL renderer' "${out}/weston.log" | sed 's/^\[[^]]*\] //')"
python3 -I "${here}/sampler.py" "${xdg}" "${out}/proc.jsonl" 1.0 &
sampler=$!
env -u DISPLAY XDG_RUNTIME_DIR="${xdg}" WAYLAND_DISPLAY=wk GDK_BACKEND=wayland \
  OUT="${out}" URL="${url}" ROUTE="${route}" HOOK="${HOOK:-${here}/memhook.js}" HELPER="${here}/page-helper.js" \
  PW_MODULE="$(npm root -g)/playwright" CIRCLES="${CIRCLES:-5}" FLIGHTS="${FLIGHTS:-1}" \
  node "${here}/route.cjs" &
driver=$!
echo "DRIVER pid=${driver} SAMPLER pid=${sampler}"
wait "${driver}"
status=$?
driver=""
echo "DRIVER_EXIT ${status} $(date -u +%FT%TZ)"
exit "${status}"
