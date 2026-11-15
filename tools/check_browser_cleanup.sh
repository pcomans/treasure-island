#!/usr/bin/env bash
# Checks how tools/browser stops. Stand-ins first on PATH replace weston and
# agent-browser, so no GPU, display or Chrome is needed. The stand-in
# agent-browser's "open" starts a stand-in daemon that, like the real one, runs on
# after the command and keeps every descriptor it is given; its "close" stops that
# daemon (with CHECK_MODE=stuck it leaves it running), and a "close" with no daemon
# starts a new one, as the real one does. Each case runs tools/browser while this
# check holds a lock on fd 9, as a step under flock does, and lets go of it before
# probing whether anything still holds it:
#   1. stopped with TERM: it closes its own session and one the lock holder opened
#      through the printed prefix, exits 143, says nothing is left, and nothing
#      holds the lock;
#   2. a daemon that stays after close: it names it, stops it, says so, and nothing
#      holds the lock;
#   3. a session whose daemon has already ended: it does not close it again (that
#      would start a new daemon), and nothing is left;
#   4. killed (SIGKILL, so no cleanup runs): its daemon and Weston run on, but
#      neither holds the lock.
# About 10 s. Part of tools/test.sh.
#
#   tools/check_browser_cleanup.sh
set -euo pipefail
cd "$(dirname "$0")/.."
command -v python3 >/dev/null || { echo "FAIL: python3 is missing (the stand-in Weston needs it)"; exit 1; }
work="$(mktemp -d)"
xdgs=()
# The processes started under a tools/browser runtime directory, found as tools/browser finds them.
owned_by() {
  local path pids=()
  for path in $(env -u XDG_RUNTIME_DIR grep -lzxF "XDG_RUNTIME_DIR=$1" /proc/[0-9]*/environ 2>/dev/null); do
    path="${path#/proc/}"
    pids+=("${path%/environ}")
  done
  echo "${pids[*]}"
}
cleanup() {
  local xdg pids
  exec 9>&- || true
  for xdg in "${xdgs[@]}"; do
    pids="$(owned_by "${xdg}")"
    [ -z "${pids}" ] || kill -KILL ${pids} 2>/dev/null || true
    rm -rf "${xdg}"
  done
  rm -rf "${work}"
}
trap cleanup EXIT
mkdir -p "${work}/bin"

cat > "${work}/bin/weston" <<'EOF'
#!/usr/bin/env bash
# Stand-in weston: opens its --socket at once, then runs until it is stopped.
socket=""
for arg; do case "${arg}" in --socket=*) socket="${arg#--socket=}" ;; esac; done
cd "${XDG_RUNTIME_DIR}"
exec python3 -I -c '
import signal, socket, sys
server = socket.socket(socket.AF_UNIX)
server.bind(sys.argv[1])
server.listen()
signal.pause()
' "${socket}"
EOF

cat > "${work}/bin/agent-browser" <<'EOF'
#!/usr/bin/env bash
# Stand-in agent-browser (tools/check_browser_cleanup.sh): open and close only.
session=default
command=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --session) session="$2"; shift 2 ;;
    --args) shift 2 ;;
    --*) shift ;;
    *) command="$1"; shift; break ;;
  esac
done
dir="${XDG_RUNTIME_DIR}/agent-browser"
mkdir -p "${dir}"
echo "${command} ${session}" >> "${CHECK_WORK}/calls.log"
# A daemon of its own that runs on after this command, keeping every descriptor it
# is given but stdio, as the real daemon does; it keeps <session>.pid while it runs.
start_daemon() {
  sleep 300 </dev/null >/dev/null 2>&1 &
  echo "$!" > "${dir}/${session}.pid"
}
case "${command}" in
  open)
    start_daemon
    echo "stand-in agent-browser: opened ${session}" ;;
  close)
    pid="$(cat "${dir}/${session}.pid" 2>/dev/null || true)"
    if [ -n "${pid}" ] && kill -0 "${pid}" 2>/dev/null; then
      if [ "${CHECK_MODE:-}" != stuck ]; then
        kill "${pid}"
        rm -f "${dir}/${session}.pid"
      fi
      echo "stand-in agent-browser: closed ${session}"
    else
      # No daemon: one starts to serve the command and stays.
      start_daemon
      echo "stand-in agent-browser: no daemon for ${session}, so one started" >&2
      exit 1
    fi ;;
  *) echo "stand-in agent-browser: unexpected command ${command}" >&2; exit 2 ;;
esac
EOF
chmod +x "${work}/bin/weston" "${work}/bin/agent-browser"

failures=()
# start CASE SESSION [VARIABLE=VALUE...]: tools/browser for SESSION with the stand-ins,
# while this check holds work/CASE.lock on fd 9; sets browser (its PID) and xdg (its
# runtime directory, empty if it never printed its prefix).
start() {
  local case="$1" session="$2"
  shift 2
  mkdir -p "${work}/${case}"
  exec 9>"${work}/${case}.lock"
  flock 9
  env PATH="${work}/bin:${PATH}" CHECK_WORK="${work}/${case}" "$@" \
    tools/browser "${session}" about:blank > "${work}/${case}.out" 2>&1 &
  browser=$!
  xdg=""
  for _ in {1..300}; do
    xdg="$(sed -n 's/^Browser commands: XDG_RUNTIME_DIR=\([^ ]*\) .*/\1/p' "${work}/${case}.out")"
    [ -n "${xdg}" ] && break
    kill -0 "${browser}" 2>/dev/null || break
    sleep 0.1
  done
  if [ -n "${xdg}" ]; then
    xdgs+=("${xdg}")
  else
    failures+=("${case}: tools/browser never printed its command prefix: $(cat "${work}/${case}.out")")
  fi
}
# finish CASE SIGNAL: stops tools/browser with SIGNAL and waits for it (30 s at most),
# then lets go of the lock; sets status (its exit) and lock (free or held).
finish() {
  local case="$1" signal="$2"
  status=0
  kill "-${signal}" "${browser}" 2>/dev/null || true
  for _ in {1..300}; do
    kill -0 "${browser}" 2>/dev/null || break
    sleep 0.1
  done
  if kill -0 "${browser}" 2>/dev/null; then
    failures+=("${case}: tools/browser was still running 30 s after ${signal}")
    kill -KILL "${browser}"
  fi
  # (Quiet: bash would report the job a signal ended.)
  wait "${browser}" 2>/dev/null || status=$?
  exec 9>&-
  if flock -n "${work}/${case}.lock" true; then lock=free; else lock=held; fi
}
calls() { cat "${work}/$1/calls.log" 2>/dev/null || true; }
nothing_left='tools/browser: stopped; nothing it started is still running'

# 1. Stopped with TERM, with a second session the lock holder opened through the prefix.
start term chk-term
if [ -n "${xdg}" ]; then
  XDG_RUNTIME_DIR="${xdg}" PATH="${work}/bin:${PATH}" CHECK_WORK="${work}/term" \
    agent-browser --session chk-term-2 open about:blank >/dev/null
fi
finish term TERM
[ "${status}" -eq 143 ] || failures+=("1: stopped with TERM it exited ${status}, not 143")
{ grep -qx 'close chk-term' <<< "$(calls term)" && grep -qx 'close chk-term-2' <<< "$(calls term)"; } \
  || failures+=("1: it did not close both sessions; the stand-in was asked: $(calls term | tr '\n' ';')")
grep -qx "${nothing_left}" "${work}/term.out" || failures+=("1: no line saying nothing is left: $(cat "${work}/term.out")")
[ "${lock}" = free ] || failures+=("1: after it stopped, a process it started still held its caller's lock")
[ -z "$(owned_by "${xdg}")" ] || failures+=("1: still running after it stopped: $(owned_by "${xdg}")")

# 2. A daemon that stays after close.
start stuck chk-stuck CHECK_MODE=stuck
finish stuck TERM
[ "${status}" -eq 143 ] || failures+=("2: stopped with TERM it exited ${status}, not 143")
grep -qE '^tools/browser: LEFT RUNNING after its sessions closed: PID [0-9]+ \(sleep\); stopping it$' "${work}/stuck.out" \
  || failures+=("2: the daemon left after close was not named: $(cat "${work}/stuck.out")")
grep -qx 'tools/browser: stopped; what it had left running is stopped too (named above)' "${work}/stuck.out" \
  || failures+=("2: no line saying what was left is stopped: $(cat "${work}/stuck.out")")
[ "${lock}" = free ] || failures+=("2: after it stopped, a process it started still held its caller's lock")
[ -z "$(owned_by "${xdg}")" ] || failures+=("2: still running after it stopped: $(owned_by "${xdg}")")

# 3. The session's daemon has ended before the handle is stopped.
start gone chk-gone
if [ -n "${xdg}" ]; then
  kill "$(cat "${xdg}/agent-browser/chk-gone.pid")"
fi
finish gone TERM
[ "${status}" -eq 143 ] || failures+=("3: stopped with TERM it exited ${status}, not 143")
! grep -qx 'close chk-gone' <<< "$(calls gone)" \
  || failures+=("3: it closed a session whose daemon had ended, which starts a new daemon")
grep -qx "${nothing_left}" "${work}/gone.out" || failures+=("3: no line saying nothing is left: $(cat "${work}/gone.out")")
[ "${lock}" = free ] || failures+=("3: after it stopped, a process it started still held its caller's lock")
[ -z "$(owned_by "${xdg}")" ] || failures+=("3: still running after it stopped: $(owned_by "${xdg}")")

# 4. Killed, so no cleanup runs: what it started runs on without the caller's lock.
start killed chk-killed
daemon=""
weston=""
if [ -n "${xdg}" ]; then
  daemon="$(cat "${xdg}/agent-browser/chk-killed.pid")"
  weston="$(sed -n 's/^Owned Weston PID: \([0-9]*\);.*/\1/p' "${work}/killed.out")"
fi
finish killed KILL
[ "${status}" -eq 137 ] || failures+=("4: killed it exited ${status}, not 137")
{ [ -n "${daemon}" ] && kill -0 "${daemon}" 2>/dev/null && [ -n "${weston}" ] && kill -0 "${weston}" 2>/dev/null; } \
  || failures+=("4: its stand-in daemon (${daemon:-none}) and Weston (${weston:-none}) should still run after it was killed")
[ "${lock}" = free ] || failures+=("4: its daemon or Weston, running on after it was killed, held its caller's lock")

if [ "${#failures[@]}" -gt 0 ]; then
  printf 'FAIL: %s\n' "${failures[@]}"
  exit 1
fi
echo "PASS: tools/browser closes its sessions and those opened through its prefix, names and stops a daemon left after close, never closes one already ended, and nothing it starts holds its caller's lock, even when it is killed"
