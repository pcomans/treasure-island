#!/usr/bin/env bash
# Checks tools/docs-only, which decides that a push to main changes only
# documentation and so builds nothing: Markdown anywhere is documentation;
# everything else is code, including the JSON, images, scripts and Godot
# settings that sit beside Markdown, and a .md name that differs only in case.
# A change with no path at all is not documentation only. Takes well under a
# second. Part of tools/test.sh.
#
#   tools/check_docs_only.sh
set -euo pipefail
cd "$(dirname "$0")/.."
failures=0
# expect STATUS PATH...: tools/docs-only on these paths exits STATUS.
expect() {
  local want="$1" status=0
  shift
  printf '%s\n' "$@" | tools/docs-only > /dev/null || status=$?
  if [ "${status}" -ne "${want}" ]; then
    echo "FAIL: tools/docs-only exited ${status}, not ${want}, for: $*"
    failures=$((failures + 1))
  fi
}
expect 0 README.md
expect 0 AGENTS.md CLAUDE.md KNOWN_ISSUES.md LEARNINGS.md INSTALL_LOG.md HUMAN.md PLAYTEST.md
expect 0 discovery/RETRO_LOG.md discovery/facades/FIRE_STATION_48_REFERENCE_SPEC.md
expect 0 evidence/building-quality-drafts/notes.md game/resources/ui/PROVENANCE.md tools/sfx/README.md
expect 0 ".claude/agents/ti-implementation.md" "discovery/a folder with spaces/note.md"
expect 1 discovery/facades/facade-recognition-catalog.json
expect 1 README.md discovery/facades/facade-recognition-catalog.json
expect 1 README.md .github/workflows/mac-build.yml
expect 1 README.md docs/screenshot.png
expect 1 discovery/.gdignore
expect 1 game/scripts/main.gd
expect 1 project.godot
expect 1 export_presets.cfg
expect 1 generated/world/manifest.json
expect 1 tools/docs-only
expect 1 README.MD
expect 1 notes.markdown
expect 1 README.md.orig
expect 2
expect 2 ""
if [ "${failures}" -gt 0 ]; then
  exit 1
fi
echo "PASS: tools/docs-only counts Markdown anywhere as documentation and everything else as code (the building catalog JSON, workflow, images, scripts, Godot settings, generated data, .gdignore, .MD and .markdown names), and an empty change as neither"
