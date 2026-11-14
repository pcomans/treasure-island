#!/usr/bin/env bash
# Runs every test. Must pass before anything is pushed to main.
#
#   tools/test.sh
#
# 1. Junk check: changes since origin/main (committed or not) must not add
#    screenshots, videos, builds, logs, reference photos or huge files outside
#    the game's own asset folders (game/resources/, generated/).
# 2. The street cars' mesh check (tools/check_street_car_meshes.mjs), the
#    sound-effect prompt sheet and tool check (tools/check_sfx.mjs) and the sound
#    folder's fetch (tools/check_fetch_sfx.mjs).
# 3. tools/godot's wait for its private Weston (tools/check_godot_weston_wait.sh):
#    it waits through a slow start and stops at once when Weston exits; every run
#    gets the Dummy audio driver unless it names its own.
# 4. The behaviour tests: the game parses, loads and plays, and every building
#    in the score is present and fits (game/tests/shared/island_test.gd), both
#    in the world generated at startup and in the baked world desktop exports load.
# 5. The generated-world checks, including the street-detail clearance check:
#    with all street-detail layers on, nothing intrudes on doors, stairs, their
#    approaches, the spawn or the QA corridors. They run in the background
#    beside the long Godot stages, and their results come last.
set -uo pipefail
cd "$(dirname "$0")/.."
# npm/node live here in the devcontainer (node feature); non-login shells lack it.
export PATH="/usr/local/share/nvm/current/bin:${PATH}"
failed=()

# Godot can exit 0 after a script or engine error, so its output is checked too.
# A clean run prints no ERROR lines at all.
godot_errors='SCRIPT ERROR|Parse Error|Failed to load script|^ERROR'

echo "== junk check"
command -v file >/dev/null || { echo "FAIL: the 'file' tool is missing; rebuild the devcontainer"; failed+=("junk check"); }
git fetch -q origin main || echo "NOTE: could not fetch origin/main; using the local copy"
if ! base="$(git merge-base HEAD origin/main)"; then
  echo "FAIL: no origin/main to compare against"
  failed+=("junk check")
else
  junk=""
  while IFS= read -r -d '' path; do
    [ -f "${path}" ] || continue
    lower="$(printf '%s' "${path%.import}" | tr '[:upper:]' '[:lower:]')"
    case "${lower}" in
      *streetview*|*street_view*|*street-view*|*gsv_*)
        junk+="${path}  (looks like a reference photo; those never go in the repo)"$'\n'; continue ;;
    esac
    case "${lower}" in
      game/resources/*|generated/*) continue ;;
      *.png|*.jpg|*.jpeg|*.webp|*.bmp|*.tga|*.exr|*.avi|*.mp4|*.mov|*.webm|*.pck|*.zip|*.dmg|*.x86_64|*.log)
        junk+="${path}  (screenshots, videos, builds and logs stay out of the repo)"$'\n'; continue ;;
    esac
    # Renamed media (e.g. a photo saved as .dat) is still media.
    case "$(file -b --mime-type "${path}" 2>/dev/null || echo missing-file-tool)" in
      image/*|video/*)
        junk+="${path}  (an image or video, whatever its name; those belong in game/resources/)"$'\n'; continue ;;
    esac
    if [ "$(stat -c %s "${path}")" -gt 5000000 ]; then
      junk+="${path}  (over 5 MB)"$'\n'
    fi
  done < <( { git diff -z --name-only --no-renames --diff-filter=A "${base}"; git ls-files -z --others --exclude-standard; } )
  if [ -n "${junk}" ]; then
    printf 'FAIL: these new files should not be committed:\n%s' "${junk}"
    failed+=("junk check")
  else
    echo "PASS"
  fi
fi

# The street cars' meshes as committed (street_clutter_kit.glb and
# street_car_hero_kit.glb): no face turned over, no broken or wedge-ended
# groove, no see-through crack wider than a third of the owner's pixel, the
# side windows, plates, glass and lamps in their materials at every level,
# and no cabin poking out of the hero shell. Node only, a few seconds.
echo "== tools/check_street_car_meshes.mjs"
node tools/check_street_car_meshes.mjs || failed+=("tools/check_street_car_meshes.mjs")

# The sound-effect prompt sheet and its tool (tools/sfx/), offline: the sheet
# is valid; the dry run prices it; the tool refuses an in-repository --out and
# a real run without a key; against a stand-in for the API on the loopback it
# keeps to the plan's concurrency, waits out a 429, never requests a candidate
# twice and never prints the key; its post-processing cuts one-shots and closes
# loop seams (when ffmpeg is on PATH); and Git tracks no audio. A few seconds.
echo "== tools/check_sfx.mjs"
node tools/check_sfx.mjs || failed+=("tools/check_sfx.mjs")

# tools/fetch-sfx, offline in temporary folders: nothing without a source; from a
# folder or a Git repository only the game's sounds' takes, with their manifest's
# gains; safe to repeat, removing only its own stale takes; a token never
# printed; a linked sound folder or a source in the project refused. Seconds.
echo "== tools/check_fetch_sfx.mjs"
node tools/check_fetch_sfx.mjs || failed+=("tools/check_fetch_sfx.mjs")

# How tools/godot waits for its private Weston, with stand-ins for Weston and
# Godot (no GPU or engine): through a slow start, and not after Weston has
# exited. About 7 s.
echo "== tools/check_godot_weston_wait.sh"
tools/check_godot_weston_wait.sh || failed+=("tools/check_godot_weston_wait.sh")

echo "== import"
output="$(timeout 300 tools/godot --headless --path . --import 2>&1)"
if [ $? -ne 0 ] || grep -qE "${godot_errors}" <<< "${output}"; then
  grep -E "${godot_errors}|ERROR" <<< "${output}" | head -20
  failed+=("import")
else
  echo "PASS"
fi

# Runs a Godot command, shows its PASS/FAIL/NOTE and error lines, and records
# NAME as failed on a nonzero exit or engine error output.
#   check_godot NAME TIMEOUT_SECONDS COMMAND...
check_godot() {
  local name="$1" limit="$2" output status
  shift 2
  output="$(timeout "${limit}" "$@" 2>&1)"
  status=$?
  grep -E "^(PASS|FAIL|NOTE)|${godot_errors}" <<< "${output}"
  if [ "${status}" -ne 0 ] || grep -qE "${godot_errors}" <<< "${output}"; then
    echo "FAIL: ${name} process status=${status} (nonzero exit or engine error output)"
    echo "Last 30 raw output lines:"
    tail -n 30 <<< "${output}"
    failed+=("${name}")
  fi
}

# The generated-world checks read only committed files and their own temporary
# copies, so they run in the background, side by side, from the first
# whole-island stage on: the stages from there (island tests, bake) leave
# their load and time limits wide room, unlike the short contracts before.
# Each check's output goes to its own file; the results come last, in this
# order, under their headings. As before, only the clearance check's stdout
# is shown. Each runs in a subshell that waits for it, so a check killed by a
# signal is reported in its own output, as it was in the foreground. On any
# exit, checks still running (an interrupted suite) are stopped with all
# their processes, and the files removed, with the baked world once the bake
# has begun.
node_checks=(tools/validate_godot_world.mjs tools/check_godot_world_determinism.mjs tools/check_street_detail_clearance.mjs)
node_pids=()
node_logs=""
baked=""
# A process and every process under it, each parent before its children.
process_tree() {
  local child
  echo "$1"
  for child in $(pgrep -P "$1"); do process_tree "${child}"; done
}
cleanup() {
  local job pid pids=()
  # This shell's background jobs still running (a check that has ended is not
  # listed, so its old PID, which another process may hold by now, is never
  # signalled) and every process under them, all listed first and signalled
  # parents first. A child runs on when its parent stops, so each process is
  # still running at its own signal; children first, a subshell would end
  # with its node process and could be reaped before its own.
  for job in $(jobs -pr); do pids+=($(process_tree "${job}")); done
  for pid in "${pids[@]}"; do kill "${pid}" 2>/dev/null; done
  [ -z "${node_logs}" ] || rm -rf "${node_logs}"
  [ -z "${baked}" ] || rm -f "${baked}"
}
trap cleanup EXIT
start_node_checks() {
  node_logs="$(mktemp -d)"
  ( node tools/validate_godot_world.mjs >/dev/null; exit ) 2>"${node_logs}/0" &
  node_pids[0]=$!
  ( node tools/check_godot_world_determinism.mjs >/dev/null; exit ) 2>"${node_logs}/1" &
  node_pids[1]=$!
  ( node tools/check_street_detail_clearance.mjs; exit ) >"${node_logs}/2" 2>&1 &
  node_pids[2]=$!
}

for test in \
  game/tests/headless_scene_parse.gd \
  game/tests/headless_startup_configuration_contract.gd \
  game/tests/validate_generated_world.gd \
  game/tests/headless_gameplay_contract.gd \
  game/tests/headless_touch_controls.gd \
  game/tests/headless_credits_contract.gd \
  game/tests/headless_shadow_options_contract.gd \
  game/tests/headless_world_material_contract.gd \
  game/tests/headless_ground_dressing_contract.gd \
  game/tests/headless_facade_meter_uv_adapter_contract.gd \
  game/tests/headless_building_study_geometry_contract.gd \
  game/tests/headless_bake_merge_contract.gd \
  game/tests/headless_facade_grid_contract.gd \
  game/tests/headless_shore_lift.gd \
  game/tests/headless_fast_drop.gd \
  game/tests/headless_vehicle_contract.gd \
  game/tests/headless_car_stance.gd \
  game/tests/headless_car_pileup.gd \
  game/tests/headless_touch_drive.gd \
  game/tests/headless_sound_contract.gd \
  game/tests/automated_route_qa.gd \
  game/tests/shared/island_test.gd
do
  echo "== ${test}"
  # --fixed-fps 60: physics (the island test's walk-ups) runs as fast as the CPU allows.
  display_args=(--headless)
  time_limit=600
  # The dummy renderer does not retain the visible MultiMesh transforms that
  # the shared island fit check compares against collision and stock movement.
  # It walks every scored building, so its hang guard is longer than the others'.
  if [ "${test}" = game/tests/shared/island_test.gd ]; then
    display_args=()
    time_limit=900
    start_node_checks
  fi
  check_godot "${test}" "${time_limit}" tools/godot "${display_args[@]}" --fixed-fps 60 --path . --audio-driver Dummy --script "${test}"
done

# Desktop exports load a baked world instead of generating it at startup
# (tools/build-linux.sh, tools/build-mac.sh). Bake it the same way and run the
# whole-island check on it too. The bake is a build product, removed afterwards
# (and on any exit, by cleanup).
baked=generated/native/static_world.scn
echo "== tools/prebuild-static-world.sh native"
check_godot "tools/prebuild-static-world.sh native" 900 tools/prebuild-static-world.sh native
if [ -s "${baked}" ]; then
  echo "== game/tests/shared/island_test.gd -- --use-prebuilt-world"
  check_godot "game/tests/shared/island_test.gd (prebuilt world)" 900 tools/godot --fixed-fps 60 --path . --audio-driver Dummy --script game/tests/shared/island_test.gd -- --use-prebuilt-world
fi
rm -f "${baked}"

# The generated-world checks' results (started above; here if they were not).
[ "${#node_pids[@]}" -gt 0 ] || start_node_checks
for index in "${!node_checks[@]}"; do
  echo "== ${node_checks[index]}"
  wait "${node_pids[index]}"
  status=$?
  cat "${node_logs}/${index}"
  [ "${status}" -eq 0 ] || failed+=("${node_checks[index]}")
done

echo
if [ ${#failed[@]} -eq 0 ]; then
  echo "ALL TESTS PASS"
else
  printf 'FAILED: %s\n' "${failed[@]}"
  exit 1
fi
