#!/usr/bin/env bash
# Runs every test. Must pass before a change to the game, its data or its tests
# is pushed to main (AGENTS.md, Tests).
#
#   tools/test.sh
#
# 1. Junk check: changes since origin/main (committed or not) must not add
#    screenshots, videos, builds, logs, reference photos or huge files outside
#    the game's own asset folders (game/resources/, generated/).
# 2. The street cars' mesh check (tools/check_street_car_meshes.mjs), the
#    sound-effect prompt sheet and tool check (tools/check_sfx.mjs) and the sound
#    folder's fetch with the web deploy's sound guard (tools/check_fetch_sfx.mjs).
# 3. tools/godot's wait for its private Weston (tools/check_godot_weston_wait.sh):
#    it waits through a slow start and stops at once when Weston exits; every run
#    gets the Dummy audio driver unless it names its own. And how tools/browser
#    stops (tools/check_browser_cleanup.sh): it closes its sessions, names and
#    stops what is left, and nothing it starts holds its caller's lock. And
#    tools/build-number (tools/check_build_number.sh): each newer head of main
#    gets a larger build number, and a shallow clone is refused. And
#    tools/docs-only (tools/check_docs_only.sh): only Markdown counts as
#    documentation, so only a push of Markdown alone skips the Mac build. And
#    the web build's path check (tools/check_web_paths_selftest.sh): a page
#    that loads a file from outside its own folder fails. And the players'
#    changelog tool and CHANGELOG.md (tools/check_changelog.sh): a build
#    without its entry, or a badly written entry, fails. And the web page's
#    build cache (tools/check_web_build_files.mjs): a pack stored on the device
#    loads without a download, and a short or failed download is never stored;
#    and once play is ready the page frees the pack's released files, and keeps
#    every byte the game may still read.
#    And the page's side of the drive trace (tools/check_web_trace.mjs): without
#    ?trace=drive it does nothing at all.
# 4. Every shader under game/ compiles and draws, with each define it tests, on
#    Forward+ and on the Compatibility renderer the web build uses
#    (game/tests/shader_compile_check.gd). And the mid-rise door landings the
#    street generators read (data/street_detail/door_landings.json) are the ones
#    the game builds (tools/export_door_landings.gd --check).
# 5. The behaviour tests: the game parses, loads and plays, and every building
#    in the score is present and fits (game/tests/shared/island_test.gd), both
#    in the world generated at startup and in the baked world desktop exports load.
#    Where the private sounds are fetched, the tests marked "# sfx:
#    takes-dependent" run again without them (--no-sfx): a checkout without the
#    sounds must pass too, and a test that reads what the sound manager plays
#    without the mark or takes of its own fails the suite.
# 6. The generated-world checks, including the street-detail clearance check:
#    with all street-detail layers on, nothing intrudes on doors, stairs, their
#    approaches, the spawn or the QA corridors. They run in the background
#    beside the long Godot stages, and their results come last.
set -uo pipefail
cd "$(dirname "$0")/.."
# npm/node live here in the devcontainer (node feature); non-login shells lack it.
export PATH="/usr/local/share/nvm/current/bin:${PATH}"
failed=()

# Godot can exit 0 after a script or engine error, so its output is checked too.
# A clean run prints no ERROR lines at all, and no shader error.
godot_errors='SCRIPT ERROR|Parse Error|Failed to load script|^ERROR|SHADER ERROR'

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
# printed; a linked sound folder or a source in the project refused; with
# --require-all, no source or a missing sound refused. And tools/deploy-web.sh's
# sound guard, with stand-in sources (no git, Vercel or build). Seconds.
echo "== tools/check_fetch_sfx.mjs"
node tools/check_fetch_sfx.mjs || failed+=("tools/check_fetch_sfx.mjs")

# How tools/godot waits for its private Weston, with stand-ins for Weston and
# Godot (no GPU or engine): through a slow start, and not after Weston has
# exited. About 7 s.
echo "== tools/check_godot_weston_wait.sh"
tools/check_godot_weston_wait.sh || failed+=("tools/check_godot_weston_wait.sh")

# How tools/browser stops, with stand-ins for Weston and agent-browser (no GPU,
# display or Chrome): it closes its sessions, names and stops a daemon left
# running, and nothing it starts holds its caller's lock. About 7 s.
echo "== tools/check_browser_cleanup.sh"
tools/check_browser_cleanup.sh || failed+=("tools/check_browser_cleanup.sh")

# tools/build-number, the releases' build number, in a throwaway repository
# shaped like main's history (commits, merges, a fast-forward to a branch that
# merged main): each newer head gets a larger number, a partial clone gives the
# same, and a shallow clone is refused. About a second.
echo "== tools/check_build_number.sh"
tools/check_build_number.sh || failed+=("tools/check_build_number.sh")

# tools/docs-only, which lets a push to main of documentation alone skip the
# Mac build: Markdown is documentation, and the building catalog JSON, workflow,
# images, scripts, Godot settings and generated data are code. Instant.
echo "== tools/check_docs_only.sh"
tools/check_docs_only.sh || failed+=("tools/check_docs_only.sh")

# tools/check_web_paths.py, which tools/build-web.sh runs on the exported page,
# on a page shaped like Godot's export: it passes, a link out of the game
# included, and fails a script from the site's root, a pack from another origin,
# a <base> element and a missing file. Offline, under a second.
echo "== tools/check_web_paths_selftest.sh"
tools/check_web_paths_selftest.sh || failed+=("tools/check_web_paths_selftest.sh")

# tools/changelog.py, which the release workflow and the integrator run, in a
# throwaway repository with tagged releases: a build with an entry since the
# last release passes and one without fails, every break of CHANGELOG.md's
# format fails, the notes carry the build's real number and every unreleased
# entry, and the repository's own CHANGELOG.md reads well. Offline, a few
# seconds.
echo "== tools/check_changelog.sh"
tools/check_changelog.sh || failed+=("tools/check_changelog.sh")

# tools/housing_1232_roof.py, which writes 1232 Northpoint's segment roof into its
# housing family config: the config's roof_plane, retained closures and vents to
# avoid are what it writes from the frozen wall record. Offline, under a second.
echo "== tools/housing_1232_roof.py --check"
python3 tools/housing_1232_roof.py --check || failed+=("tools/housing_1232_roof.py --check")

# The web page's build cache (tiBuildFiles in game/web/shell.html), with stand-ins
# for the browser's file system, locks, HTTP cache and network: a stored pack loads
# without a download, a new build replaces the old one, a short or failed download is
# never stored, and without storage (or storage that never answers) the pack comes
# from the network. Node only, about 30 s.
echo "== tools/check_web_build_files.mjs"
node tools/check_web_build_files.mjs || failed+=("tools/check_web_build_files.mjs")

# The drive trace's page side (game/web/shell.html, ?trace=drive): without the
# parameter it wraps, starts, stores and leaves nothing; with it, it names what a
# long frame's time went to. Node only, under a second.
echo "== tools/check_web_trace.mjs"
node tools/check_web_trace.mjs || failed+=("tools/check_web_trace.mjs")

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
solar_table=""
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
  [ -z "${solar_table}" ] || rm -f "${solar_table}"
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

# The day-clock contract checks the game's sun against the sun tools/solar_position.mjs
# gives, as it gives it now: printed here, outside the repository, and named to the
# contract (removed on any exit, by cleanup).
solar_table="$(mktemp)"
node tools/solar_position.mjs --table > "${solar_table}" || echo "NOTE: tools/solar_position.mjs --table failed; the day-clock contract will say so"

tests=(
  game/tests/headless_scene_parse.gd
  game/tests/headless_startup_configuration_contract.gd
  game/tests/headless_drive_trace_contract.gd
  game/tests/headless_shader_warm_up_contract.gd
  game/tests/validate_generated_world.gd
  game/tests/headless_gameplay_contract.gd
  game/tests/headless_touch_controls.gd
  game/tests/headless_credits_contract.gd
  game/tests/headless_build_label_contract.gd
  game/tests/headless_pack_release_contract.gd
  game/tests/headless_shadow_options_contract.gd
  game/tests/headless_day_clock_contract.gd
  game/tests/headless_world_material_contract.gd
  game/tests/headless_material_sharing_contract.gd
  game/tests/headless_ground_dressing_contract.gd
  game/tests/headless_facade_meter_uv_adapter_contract.gd
  game/tests/headless_building_study_geometry_contract.gd
  game/tests/headless_bake_merge_contract.gd
  game/tests/headless_building_1_interior_contract.gd
  game/tests/headless_street_detail_batches_contract.gd
  game/tests/headless_facade_grid_contract.gd
  game/tests/headless_midrise_open_cover_contract.gd
  game/tests/headless_midrise_wall_detail_contract.gd
  game/tests/headless_housing_unit_detail_contract.gd
  game/tests/headless_shore_lift.gd
  game/tests/headless_breakwater_birds.gd
  game/tests/headless_fast_drop.gd
  game/tests/headless_vehicle_contract.gd
  game/tests/headless_car_stance.gd
  game/tests/headless_car_pileup.gd
  game/tests/headless_touch_drive.gd
  game/tests/headless_sound_contract.gd
  game/tests/automated_route_qa.gd
  game/tests/shared/island_test.gd
)
# One of the tests above as the suite runs it, recorded as NAME, with any further
# user arguments after its own.
#   run_test NAME TEST [USER_ARGUMENTS...]
run_test() {
  local name="$1" test="$2" display_args=(--headless) time_limit=600 user_args=() script_args=()
  shift 2
  # --fixed-fps 60: physics (the island test's walk-ups) runs as fast as the CPU allows.
  # The dummy renderer does not retain the visible MultiMesh transforms that
  # the shared island fit check compares against collision and stock movement.
  # It walks every scored building, so its hang guard is longer than the others'.
  if [ "${test}" = game/tests/shared/island_test.gd ]; then
    display_args=()
    time_limit=900
  fi
  [ "${test}" != game/tests/headless_day_clock_contract.gd ] || user_args=(--solar-table "${solar_table}")
  user_args+=("$@")
  [ "${#user_args[@]}" -eq 0 ] || script_args=(-- "${user_args[@]}")
  check_godot "${name}" "${time_limit}" tools/godot "${display_args[@]}" --fixed-fps 60 --path . --audio-driver Dummy --script "${test}" "${script_args[@]}"
}
# A checkout without the private sounds runs the game, its tests and its builds
# silent (tools/sfx/README.md), so a test that reads what the sound manager plays
# from the real takes says so with the line "# sfx: takes-dependent", and where
# tools/fetch-sfx has filled the sound folder it runs a second time with --no-sfx,
# which loads no takes (the silent pass, after the tests). A listed test whose
# code (its comment lines aside) reads the play state (sfx_reads) with neither
# that line nor a manifest of its own (Sound.manifest_path) fails the suite here,
# so no such test can be added outside the silent pass.
sfx_reads='loop_playing|has_takes|takes_of|played_counts|voices_of|loop_level|bed_level|"played"|loop_start'
# Prints the tests given that carry the line; names each one that reads the play
# state without it or takes of its own, and then returns 1.
#   sfx_selection TEST...
sfx_selection() {
  local test code status=0
  for test in "$@"; do
    code="$(grep -vE '^[[:space:]]*#' "${test}")"
    if grep -qx '# sfx: takes-dependent' "${test}"; then
      echo "${test}"
    elif grep -qE "${sfx_reads}" <<< "${code}" && ! grep -q 'Sound.manifest_path =' <<< "${code}"; then
      echo "FAIL: ${test} reads what the sound manager plays but has neither the line '# sfx: takes-dependent' (the silent pass) nor takes of its own (Sound.manifest_path)" >&2
      status=1
    fi
  done
  return "${status}"
}
# Every shader compiles on both renderers the game ships with: Forward+ (desktop) and
# the Compatibility renderer (the web build's), which alone compiles each shader's
# CURRENT_RENDERER == RENDERER_COMPATIBILITY branches. Drawn, so not headless.
for method in forward_plus gl_compatibility; do
  echo "== game/tests/shader_compile_check.gd (${method})"
  driver=()
  [ "${method}" != gl_compatibility ] || driver=(--rendering-driver opengl3)
  check_godot "game/tests/shader_compile_check.gd (${method})" 300 tools/godot --rendering-method "${method}" "${driver[@]}" --path . --audio-driver Dummy --script game/tests/shader_compile_check.gd
done

# The street generators keep plants and props off the mid-rise door landings in
# data/street_detail/door_landings.json and pave the grass beside them; the family's
# own build must still draw exactly those (headless, seconds). A failure names each door.
echo "== tools/export_door_landings.gd --check"
check_godot "tools/export_door_landings.gd --check" 300 tools/godot --headless --path . --audio-driver Dummy --script tools/export_door_landings.gd -- --check

echo "== sound-state tests"
silent_tests=()
if selection="$(sfx_selection "${tests[@]}")"; then
  shown="${selection//$'\n'/ }"
  echo "PASS: the silent pass takes ${shown:-no test}"
else
  failed+=("sound-state tests")
fi
[ -z "${selection}" ] || mapfile -t silent_tests <<< "${selection}"

for test in "${tests[@]}"; do
  echo "== ${test}"
  [ "${test}" != game/tests/shared/island_test.gd ] || start_node_checks
  run_test "${test}" "${test}"
done

echo "== silent pass (--no-sfx)"
if [ ! -f game/resources/audio/sfx/sfx.json ]; then
  echo "NOTE: no sounds fetched (game/resources/audio/sfx/sfx.json), so the pass above was silent: ${silent_tests[*]:-no test}"
else
  for test in "${silent_tests[@]}"; do
    echo "== ${test} -- --no-sfx"
    run_test "${test} (silent)" "${test}" --no-sfx
  done
fi

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
