#!/usr/bin/env bash
# Checks how tools/godot waits for its private Weston. Stand-ins replace weston
# (first on PATH) and Godot (GODOT_BIN), so no GPU, display or engine is needed:
#   1. A Weston that opens its socket only after 7 s, past the fixed 5 s wait that
#      failed on a GitHub runner without a GPU (2026-11-13): tools/godot keeps
#      waiting, notes the slow start, starts Godot only once the socket exists and
#      exits with Godot's status.
#   2. A Weston that exits at once: tools/godot stops waiting at once (within this
#      check's 30 s guard, well inside its 120 s limit), prints "Weston did not
#      start:", Weston's log and how Weston ended, exits 1 and never starts Godot.
#   3. Sound (owner, 2026-11-14: the game has sound, so project.godot no longer
#      forces Godot's Dummy audio driver): a rendering run and a headless one both
#      get --audio-driver Dummy, and a run that names its own driver keeps it alone.
# Takes about 7 s. Part of tools/test.sh.
#
#   tools/check_godot_weston_wait.sh
set -euo pipefail
cd "$(dirname "$0")/.."
command -v python3 >/dev/null || { echo "FAIL: python3 is missing (the stand-in Weston needs it)"; exit 1; }
work="$(mktemp -d)"
cleanup() {
  # tools/godot stops the stand-in Weston itself; this only covers a failed run.
  [ ! -s "${work}/weston.pid" ] || kill "$(cat "${work}/weston.pid")" 2>/dev/null || true
  rm -rf "${work}"
}
trap cleanup EXIT
mkdir -p "${work}/slow" "${work}/dead" "${work}/fast" "${work}/xdg"

cat > "${work}/fast/weston" <<'EOF'
#!/usr/bin/env bash
# Stand-in weston: opens its --socket at once, then runs until it is stopped.
echo "$$" > "${CHECK_WORK}/weston.pid"
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

cat > "${work}/godot-args" <<'EOF'
#!/usr/bin/env bash
# Stand-in Godot for a headless run: says what it was given.
echo "stand-in godot: ran with $*"
EOF

cat > "${work}/slow/weston" <<'EOF'
#!/usr/bin/env bash
# Stand-in weston: opens its --socket after 7 s, then runs until it is stopped.
echo "$$" > "${CHECK_WORK}/weston.pid"
echo "stand-in weston: starting slowly"
socket=""
for arg; do case "${arg}" in --socket=*) socket="${arg#--socket=}" ;; esac; done
# A relative name, so a long XDG_RUNTIME_DIR can't exceed the socket path limit.
cd "${XDG_RUNTIME_DIR}"
exec python3 -I -c '
import signal, socket, sys, time
time.sleep(7)
server = socket.socket(socket.AF_UNIX)
server.bind(sys.argv[1])
server.listen()
signal.pause()
' "${socket}"
EOF

cat > "${work}/dead/weston" <<'EOF'
#!/usr/bin/env bash
# Stand-in weston: fails at once, as Weston does when it cannot start at all.
echo "stand-in weston: fatal: cannot start" >&2
exit 3
EOF

cat > "${work}/godot" <<'EOF'
#!/usr/bin/env bash
# Stand-in Godot: it may only start once Weston's socket exists.
if [ ! -S "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}" ]; then
  echo "stand-in godot: started before Weston's socket existed" >&2
  exit 99
fi
echo "stand-in godot: ran with $*"
exit 7
EOF
chmod +x "${work}/slow/weston" "${work}/dead/weston" "${work}/fast/weston" "${work}/godot" "${work}/godot-args"

# run GUARD_SECONDS STANDIN [ENGINE ARGS...]: a rendering tools/godot run with that
# stand-in Weston (engine arguments --path . unless given).
run() {
  local guard="$1" standin="$2"
  shift 2
  [ "$#" -gt 0 ] || set -- --path .
  status=0
  output="$(PATH="${work}/${standin}:${PATH}" XDG_RUNTIME_DIR="${work}/xdg" GODOT_BIN="${work}/godot" \
    CHECK_WORK="${work}" timeout "${guard}" tools/godot "$@" 2>&1)" || status=$?
}
failures=()

run 60 slow
slow_status="${status}" slow_output="${output}"
[ "${status}" -eq 7 ] || failures+=("slow start: tools/godot exited ${status}, not with the stand-in Godot's 7")
grep -q '^stand-in godot: ran' <<< "${output}" || failures+=("slow start: Godot was never started")
grep -qE '^NOTE: tools/godot: Weston took [0-9]+\.[0-9] s to open its socket' <<< "${output}" \
  || failures+=("slow start: no NOTE saying how long Weston took")

run 30 dead
dead_status="${status}" dead_output="${output}"
[ "${status}" -eq 1 ] || failures+=("dead Weston: tools/godot exited ${status}, not 1 (124: it kept waiting after Weston exited)")
expected="tools/godot: Weston did not start:
stand-in weston: fatal: cannot start
tools/godot: Weston exited with status 3 after N s"
[ "$(sed -E 's/ after [0-9]+\.[0-9] s$/ after N s/' <<< "${output}")" = "${expected}" ] \
  || failures+=("dead Weston: the output is not the error line, Weston's log and how Weston ended")

# 3. The audio driver: Dummy unless the run names one.
run 30 fast --path .
grep -qE '^stand-in godot: ran with .*--audio-driver Dummy .*--path \.' <<< "${output}" \
  || failures+=("sound: a rendering run did not get --audio-driver Dummy: ${output}")
run 30 fast --audio-driver ALSA --path .
{ grep -q -- '--audio-driver ALSA' <<< "${output}" && ! grep -q 'Dummy' <<< "${output}"; } \
  || failures+=("sound: a rendering run that names its driver did not keep it alone: ${output}")
headless="$(GODOT_BIN="${work}/godot-args" timeout 30 tools/godot --headless --path . 2>&1)" || true
grep -qE '^stand-in godot: ran with --audio-driver Dummy --headless --path \.$' <<< "${headless}" \
  || failures+=("sound: a headless run did not get --audio-driver Dummy: ${headless}")

if [ "${#failures[@]}" -gt 0 ]; then
  printf 'FAIL: %s\n' "${failures[@]}"
  printf -- '--- slow start (status %s):\n%s\n--- dead Weston (status %s):\n%s\n' \
    "${slow_status}" "${slow_output}" "${dead_status}" "${dead_output}"
  exit 1
fi
echo "PASS: tools/godot waits through a slow Weston start and stops at once when Weston exits; every run gets the Dummy audio driver unless it names its own"
