#!/usr/bin/env bash
# tools/web_trace/session.sh OUT_DIR: one drive-trace session (tools/web_trace/drive.cjs) of a web build served at
# URL, in Playwright's WebKit or Chrome for Testing, headed on a private headless Weston on the GPU (never xvfb).
# Everything it starts is stopped by PID at the end; its temporary files live in OUT_DIR, its Weston socket in a short
# runtime folder of its own (a socket path must stay under 108 bytes). Run it in an engine slot (GPU work).
# Env: URL (the page, with ?trace=drive&profile_startup=1); BROWSER webkit|chrome; PROFILE phone (874x402 CSS px at
# 3x, touch: an iPhone 16 Pro held sideways, full screen) | phone1x | safari (756x352 at 3x) | desktop (1440x900);
# THROTTLE (Chrome's CPU slowdown, from the start prompt); GL gpu|swiftshader (Chrome); TI_WEBKIT_EXEC (an
# executable starting Playwright's WebKit MiniBrowser with the libraries it needs; default: Playwright's own);
# TI_CHROME_EXEC (default: agent-browser's Chrome for Testing); JSC_* (WebKit: JavaScriptCore options).
set -uo pipefail
export PATH="/usr/local/share/nvm/current/bin:${PATH}"
here="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "${1:?usage: tools/web_trace/session.sh OUT_DIR}"
out="$(cd "$1" && pwd)"
: "${URL:?URL: the page to open, with ?trace=drive&profile_startup=1}"
export TMPDIR="${out}/tmp"; mkdir -p "${TMPDIR}"
mkdir -p "${HOME}/.cache"
# Weston's socket and Chrome's SingletonSocket (under TMPDIR for the browser) need short paths.
xdg="$(mktemp -d "${HOME}/.cache/ti-wt.XXXXXX")"; chmod 700 "${xdg}"
short="$(mktemp -d "${HOME}/.cache/ti-wb.XXXXXX")"
weston=""; driver=""
owned() { env -u XDG_RUNTIME_DIR grep -lzxF "XDG_RUNTIME_DIR=${xdg}" /proc/[0-9]*/environ 2>/dev/null | cut -d/ -f3; }
cleanup() {
  set +e
  if [ -n "${driver}" ] && kill -0 "${driver}" 2>/dev/null; then echo "DRIVER_STILL_RUNNING ${driver}: TERM"; kill -TERM "${driver}"; sleep 5; kill -KILL "${driver}" 2>/dev/null; fi
  [ -n "${driver}" ] && wait "${driver}" 2>/dev/null
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
  for p in ${weston} ${driver}; do kill -0 "${p}" 2>/dev/null && left+="${p} "; done
  echo "SESSION_END $(date -u +%FT%TZ) left_running=[${left}]"
  rm -rf "${TMPDIR}" "${xdg}" "${short}"
}
trap cleanup EXIT
trap 'exit 143' INT TERM
echo "SESSION_START $(date -u +%FT%TZ) out=${out} browser=${BROWSER:-webkit} profile=${PROFILE:-phone} throttle=${THROTTLE:-1} gl=${GL:-gpu}"
# A Weston output big enough for the phone's 2622 x 1206 pixels at 3x.
XDG_RUNTIME_DIR="${xdg}" weston --backend=headless --renderer=gl --socket=wk --width=2700 --height=1300 --idle-time=0 > "${out}/weston.log" 2>&1 &
weston=$!
for _ in $(seq 1200); do [ -S "${xdg}/wk" ] && break; kill -0 "${weston}" 2>/dev/null || break; sleep 0.1; done
[ -S "${xdg}/wk" ] || { echo "SESSION_FAIL Weston did not start"; tail -5 "${out}/weston.log"; exit 3; }
echo "WESTON pid=${weston} $(grep -m1 'GL renderer' "${out}/weston.log" | sed 's/^\[[^]]*\] //')"
chrome_default="$(ls -d "${HOME}"/.agent-browser/browsers/chrome-*/chrome 2>/dev/null | sort -V | tail -1)"
env -u DISPLAY XDG_RUNTIME_DIR="${xdg}" WAYLAND_DISPLAY=wk GDK_BACKEND=wayland TMPDIR="${short}" \
  OUT="${out}" URL="${URL}" BROWSER="${BROWSER:-webkit}" PROFILE="${PROFILE:-phone}" THROTTLE="${THROTTLE:-1}" GL="${GL:-gpu}" \
  PW_MODULE="${PW_MODULE:-$(npm root -g)/playwright}" WK_EXEC="${TI_WEBKIT_EXEC:-}" CHROME_EXEC="${TI_CHROME_EXEC:-${chrome_default}}" \
  node "${here}/drive.cjs" &
driver=$!
echo "DRIVER pid=${driver}"
wait "${driver}"
status=$?
driver=""
echo "DRIVER_EXIT ${status} $(date -u +%FT%TZ)"
exit "${status}"
