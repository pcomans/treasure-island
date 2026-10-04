#!/usr/bin/env bash
# Runs every test. Must pass before anything is pushed to main.
#
#   tools/test.sh
#
# 1. Junk check: changes since origin/main (committed or not) must not add
#    screenshots, videos, builds, logs, reference photos or huge files outside
#    the game's own asset folders (game/resources/, generated/).
# 2. The behaviour tests: the game parses, loads and plays, and every building
#    in the score is present and fits (game/tests/shared/island_test.gd).
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

echo "== import"
output="$(timeout 300 tools/godot --headless --path . --import 2>&1)"
if [ $? -ne 0 ] || grep -qE "${godot_errors}" <<< "${output}"; then
  grep -E "${godot_errors}|ERROR" <<< "${output}" | head -20
  failed+=("import")
else
  echo "PASS"
fi

for test in \
  game/tests/headless_scene_parse.gd \
  game/tests/headless_startup_configuration_contract.gd \
  game/tests/validate_generated_world.gd \
  game/tests/headless_gameplay_contract.gd \
  game/tests/headless_world_material_contract.gd \
  game/tests/headless_facade_meter_uv_adapter_contract.gd \
  game/tests/headless_building_study_geometry_contract.gd \
  game/tests/automated_route_qa.gd \
  game/tests/shared/island_test.gd
do
  echo "== ${test}"
  # --fixed-fps 60: physics (the island test's walk-ups) runs as fast as the CPU allows.
  output="$(timeout 600 tools/godot --headless --fixed-fps 60 --path . --audio-driver Dummy --script "${test}" 2>&1)"
  status=$?
  grep -E "^(PASS|FAIL|NOTE)|${godot_errors}" <<< "${output}"
  if [ "${status}" -ne 0 ] || grep -qE "${godot_errors}" <<< "${output}"; then
    failed+=("${test}")
  fi
done

echo "== tools/validate_godot_world.mjs"
node tools/validate_godot_world.mjs >/dev/null || failed+=("tools/validate_godot_world.mjs")

echo "== tools/check_godot_world_determinism.mjs"
node tools/check_godot_world_determinism.mjs >/dev/null || failed+=("tools/check_godot_world_determinism.mjs")

echo
if [ ${#failed[@]} -eq 0 ]; then
  echo "ALL TESTS PASS"
else
  printf 'FAILED: %s\n' "${failed[@]}"
  exit 1
fi
