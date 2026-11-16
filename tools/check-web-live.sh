#!/usr/bin/env bash
# After a web deploy: the game loads from the deployed commit's files at the
# deploy origin and at the public address, where the website serves it from its
# /game/ folder.
#
#   tools/check-web-live.sh COMMIT [URL...]
#
# COMMIT is the deployed commit's short hash, as the build names its files
# (treasure-island-COMMIT.*: `git rev-parse --short HEAD` in the deployed
# checkout). The URLs, each ending in "/", default to the deploy origin, the
# Vercel project's production domain https://play-grandtreasureisland.vercel.app/,
# and the public address https://grandtreasureisland.vercel.app/game/. Other
# domains the project may have are neither needed nor checked.
#
# At each URL, over HTTP: the page loads (200) and is revalidated on every visit
# (max-age=0, no-cache or no-store: a page kept from an older deploy would name
# files the new one no longer serves), it names COMMIT's files and no others, by
# paths relative to itself (tools/check_web_paths.py), and each of those loads
# from beside it (200, cached for good, and compressed for the engine script, the
# .wasm and the .pck). Then in a browser (tools/browser: a fresh profile on a
# private Weston, so run it in an engine slot like any other GPU work), the page
# with ?profile_startup=1 must reach the start prompt within 8 minutes: the world
# ready, the loading screen gone and the game paused on "Click to play". Every
# file the page fetched must come from beside it, and its engine script, .wasm
# and .pck must be COMMIT's. Prints a CHECK line for each step and a final PASS,
# or FAIL lines; exits 1 on any failure.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
# agent-browser lives here in the devcontainer (node feature); non-login shells lack it.
export PATH="/usr/local/share/nvm/current/bin:${PATH}"
usage="usage: tools/check-web-live.sh COMMIT [URL...]"
if [ "$#" -lt 1 ] || [[ ! "$1" =~ ^[0-9a-f]{7,40}$ ]]; then
  echo "${usage}" >&2
  exit 2
fi
commit="$1"
shift
urls=("$@")
if [ "${#urls[@]}" -eq 0 ]; then
  urls=(https://play-grandtreasureisland.vercel.app/ https://grandtreasureisland.vercel.app/game/)
fi
for url in "${urls[@]}"; do
  if [[ ! "${url}" =~ ^https?://[^/?#]+(/[^?#]*)?/$ ]]; then
    echo "${usage} (each URL ends in /: ${url})" >&2
    exit 2
  fi
done
work="$(mktemp -d)"
# The running tools/browser, if any: stopped (it closes its sessions and Weston)
# however this ends.
handle=""
cleanup() {
  if [ -n "${handle}" ]; then
    kill -TERM "${handle}" 2>/dev/null
    wait "${handle}" 2>/dev/null
  fi
  rm -rf "${work}"
}
trap cleanup EXIT
trap 'exit 143' INT TERM
failures=0
fail() {
  echo "FAIL: $*"
  failures=$((failures + 1))
}
# A response header's value, from a curl -D file: header FILE NAME.
header() {
  tr -d '\r' < "$1" | sed -n "s/^$2: *//Ip" | tail -1
}

# The page and its files over HTTP. Returns 1 if the page itself is wrong.
http_leg() {
  local url="$1" dir="$2" status cache names name number=0 path encoding
  status="$(curl -sS -o "${dir}/index.html" -D "${dir}/index.headers" -w '%{http_code}' --max-time 60 "${url}")" \
    || status="no answer (curl exit $?)"
  if [ "${status}" != 200 ]; then
    fail "${url} answered ${status}, not 200"
    return 1
  fi
  cache="$(header "${dir}/index.headers" cache-control)"
  if [[ ! "${cache}" =~ (max-age=0|no-cache|no-store) ]]; then
    fail "${url}: browsers may keep the page (Cache-Control: ${cache:-none}), so they would not see a new deploy"
  fi
  names="$(grep -o -E 'treasure-island-[0-9a-f]+' "${dir}/index.html" | sort -u | paste -s -d ' ')"
  if [ "${names}" != "treasure-island-${commit}" ]; then
    fail "${url}: the page names ${names:-no treasure-island files}, not treasure-island-${commit} alone"
    return 1
  fi
  if ! python3 -I "${root}/tools/check_web_paths.py" --files "${dir}/index.html" > "${dir}/files.txt" 2> "${dir}/paths.txt"; then
    while IFS= read -r line; do
      fail "${url}: ${line#*index.html: }"
    done < "${dir}/paths.txt"
    return 1
  fi
  while IFS= read -r name; do
    number=$((number + 1))
    path="${dir}/file-${number}.headers"
    status="$(curl -sS -I -o /dev/null -D "${path}" -H 'Accept-Encoding: br, gzip' -w '%{http_code}' --max-time 60 "${url}${name}")" \
      || status="no answer (curl exit $?)"
    cache="$(header "${path}" cache-control)"
    encoding="$(header "${path}" content-encoding)"
    echo "CHECK ${url}${name} ${status} cache=[${cache}] encoding=${encoding:-none}"
    [ "${status}" = 200 ] || fail "${url}${name} answered ${status}, not 200"
    [[ "${cache}" =~ max-age=31536000 && "${cache}" =~ immutable ]] || fail "${url}${name} is not cached for good"
    case "${name}" in
      "treasure-island-${commit}".js | "treasure-island-${commit}".wasm | "treasure-island-${commit}".pck)
        if [ "${encoding}" != br ] && [ "${encoding}" != gzip ]; then
          fail "${url}${name} is not served compressed"
        fi ;;
    esac
  done < "${dir}/files.txt"
  echo "CHECK ${url} serves treasure-island-${commit} by relative paths ($(wc -l < "${dir}/files.txt") files)"
}

# What the page shows, as JSON: the start-up marks, the game's readback
# (?profile_startup=1), the loading screen and every file the page fetched.
read -r -d '' probe <<'EOF'
(() => {
  const marks = new Set(performance.getEntriesByType('mark').map((m) => m.name));
  let state = null;
  try {
    if (typeof window.__tiReadback === 'function') {
      window.__tiReadback();
      state = JSON.parse(window.__tiState || 'null');
    }
  } catch (e) {
    state = {error: String(e)};
  }
  const status = document.getElementById('status');
  const notice = document.getElementById('status-notice');
  return JSON.stringify({
    href: location.href,
    play_ready: marks.has('TI_BOOT:play_ready'),
    failed: marks.has('TI_BOOT:failed'),
    overlay: status ? getComputedStyle(status).visibility : null,
    notice: notice ? notice.textContent : '',
    ready: Boolean(state && state.ready),
    paused: state ? state.paused : null,
    prompt: state ? state.start_prompt : null,
    files: performance.getEntriesByType('resource').map((e) => e.name),
  });
})()
EOF

# Reads an agent-browser eval result on stdin; prints WAIT, READY or STOP with why.
verdict() {
  python3 -I -c '
import json, sys
url, commit = sys.argv[1], sys.argv[2]
try:
    page = json.loads(json.load(sys.stdin)["data"]["result"])
except (ValueError, KeyError, TypeError):
    sys.exit(print("WAIT the page did not answer"))
if page["failed"]:
    sys.exit(print("STOP the game stopped loading: %s" % page["notice"]))
seen = "ready=%s play_ready=%s loading_screen=%s paused=%s prompt=%r" % (
    page["ready"], page["play_ready"], page["overlay"], page["paused"], page["prompt"])
if not (page["ready"] and page["play_ready"] and page["overlay"] == "hidden" and page["paused"] is True and page["prompt"]):
    sys.exit(print("WAIT " + seen))
problems = []
if not page["href"].startswith(url):
    problems.append("the page is at %s, not under %s" % (page["href"], url))
outside = [name for name in page["files"] if not name.startswith(url)]
if outside:
    problems.append("it fetched from outside %s: %s" % (url, ", ".join(outside)))
names = list(dict.fromkeys(name[len(url):].split("?")[0] for name in page["files"] if name.startswith(url)))
builds = sorted({name.split(".")[0] for name in names if name.startswith("treasure-island-")})
if builds != ["treasure-island-" + commit]:
    problems.append("its files are named %s, not treasure-island-%s" % (builds or "nothing", commit))
missing = [kind for kind in (".js", ".wasm", ".pck") if "treasure-island-" + commit + kind not in names]
if missing:
    problems.append("it fetched no %s" % ", ".join("treasure-island-" + commit + kind for kind in missing))
if problems:
    sys.exit(print("STOP at the start prompt %r, but %s" % (page["prompt"], "; ".join(problems))))
print("READY %s; %d files, all from beside the page: %s" % (seen, len(names), ", ".join(names)))
' "$1" "${commit}"
}

# The page in a fresh browser until it reaches the start prompt, then the browser
# stopped. The browser keeps the system's temporary folder: Chromium puts a socket
# in TMPDIR, and a long one (a release folder) makes its path longer than Unix allows.
browser_leg() {
  local url="$1" dir="$2" session="$3" xdg="" line="" last="" deadline stopped
  env -u TMPDIR "${root}/tools/browser" "${session}" "${url}?profile_startup=1" > "${dir}/browser.log" 2>&1 < /dev/null &
  handle=$!
  for _ in $(seq 120); do
    grep -q '^Browser commands: ' "${dir}/browser.log" && break
    kill -0 "${handle}" 2>/dev/null || break
    sleep 1
  done
  xdg="$(sed -n 's/^Browser commands: XDG_RUNTIME_DIR=\([^ ]*\) .*/\1/p' "${dir}/browser.log")"
  if [ -z "${xdg}" ]; then
    fail "${url}: the browser did not start: $(tail -3 "${dir}/browser.log" | tr '\n' ' ')"
  else
    deadline=$(( $(date +%s) + 480 ))
    while :; do
      line="$(printf '%s' "${probe}" | env -u TMPDIR XDG_RUNTIME_DIR="${xdg}" timeout 30 agent-browser --json --session "${session}" eval --stdin 2>/dev/null \
        | verdict "${url}")"
      if [ "${line}" != "${last}" ]; then
        echo "CHECK ${url} $(date -u +%T) ${line}"
        last="${line}"
      fi
      case "${line}" in
        READY*) break ;;
        STOP*) fail "${url}: ${line#STOP }"; break ;;
      esac
      if ! kill -0 "${handle}" 2>/dev/null; then
        fail "${url}: the browser stopped before the start prompt: $(tail -3 "${dir}/browser.log" | tr '\n' ' ')"
        break
      fi
      if [ "$(date +%s)" -ge "${deadline}" ]; then
        fail "${url}: no start prompt within 8 minutes; last: ${line}"
        break
      fi
      sleep 3
    done
  fi
  kill -TERM "${handle}" 2>/dev/null
  wait "${handle}" 2>/dev/null
  handle=""
  stopped="$(grep '^tools/browser: ' "${dir}/browser.log" | tail -1)"
  echo "CHECK ${url} browser closed: ${stopped:-no closing line}"
  [[ "${stopped}" == "tools/browser: stopped;"* ]] || fail "${url}: the browser did not close cleanly: $(tail -3 "${dir}/browser.log" | tr '\n' ' ')"
}

leg=0
for url in "${urls[@]}"; do
  leg=$((leg + 1))
  dir="${work}/${leg}"
  mkdir -p "${dir}"
  echo "CHECK ${url} $(date -u +%FT%TZ) for treasure-island-${commit}"
  http_leg "${url}" "${dir}" && browser_leg "${url}" "${dir}" "live-check-$$-${leg}"
done
if [ "${failures}" -gt 0 ]; then
  echo "FAIL: ${failures} failed check(s) for treasure-island-${commit} at ${urls[*]}"
  exit 1
fi
echo "PASS: treasure-island-${commit} loads by relative paths and reaches the start prompt at ${urls[*]}"
