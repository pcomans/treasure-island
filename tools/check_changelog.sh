#!/usr/bin/env bash
# Checks tools/changelog.py, the players' changelog tool, and the repository's
# own CHANGELOG.md, in a throwaway repository with releases tagged as the Mac
# build workflow tags them (build-<six digits>-<date>-<commit>):
# - the rule: build N has its entry when the newest entry is above the newest
#   released build before N in N's history and at most N; its edges (equal to
#   the release, one above it, N itself, N + 1), a tag on a side branch, a tag
#   on HEAD itself (a published build), no tag at all, and an entry followed by
#   a retro commit and a merge commit before the release;
# - check fails a build without its entry, passes a push of Markdown alone and
#   says whether a run started by hand would stop (--hand-run fails then);
# - the notes start with the fixed header (the game and its website) exactly
#   once, for one entry and for several, then say "Changes in build N:" with
#   N's real number and the lines of every unreleased entry, newest first, at
#   most 10 entries, a shared line once, without "No changes to the game."
#   beside other lines; notes.md's first line is still the marker the publish
#   job checks, and no VirusTotal section marker can occur in it; notes
#   --published re-makes a released build's notes from a later commit, or
#   exits 3 without an entry;
# - every rule of the format fails a file that breaks it, and a bare address
#   passes;
# - latest prints CHANGES lines, never FAIL;
# - no output line starts with "::", so a GitHub Actions log never reads a line
#   of the changelog as a workflow command.
# Offline, a few seconds. Part of tools/test.sh.
#
#   tools/check_changelog.sh
set -euo pipefail
cd "$(dirname "$0")/.."
work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_COMMON_DIR GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=check GIT_AUTHOR_EMAIL=check@example.invalid
export GIT_COMMITTER_NAME=check GIT_COMMITTER_EMAIL=check@example.invalid
failures=0
fail() { echo "FAIL: $*"; failures=$((failures + 1)); }

repo="${work}/repo"
git init -q -b main "${repo}"
mkdir -p "${repo}/tools"
cp tools/changelog.py tools/build-number tools/docs-only "${repo}/tools/"
log="${work}/log"
: > "${log}"
# tool ARGS...: runs the repository's copy, output in ${work}/out (and the log);
# prints the exit status.
tool() {
  local status=0
  (cd "${repo}" && python3 -I tools/changelog.py "$@") > "${work}/out" 2>&1 || status=$?
  cat "${work}/out" >> "${log}"
  echo "${status}"
}
shows() { grep -q -F -- "$1" "${work}/out"; }
number() { (cd "${repo}" && tools/build-number); }
step=0
# commit: commits the working tree with a change to the game.
commit() {
  step=$((step + 1))
  echo "${step}" > "${repo}/game.gd"
  git -C "${repo}" add -A
  git -C "${repo}" commit -q -m "commit ${step}"
}
# release NUMBER: tags HEAD as that build's release.
release() { git -C "${repo}" tag "build-$(printf %06d "$1")-2026-11-16-$(git -C "${repo}" rev-parse --short=7 HEAD)"; }
# entries NUMBER...: writes CHANGELOG.md with an entry for each, newest first.
entries() {
  {
    echo "# Changes"
    echo ""
    echo "Introduction."
    for number in "$@"; do
      echo ""
      echo "## Build ${number} (2026-11-16)"
      echo ""
      echo "- Change ${number}, first."
      echo "- ::warning::change ${number}, second."
    done
  } > "${repo}/CHANGELOG.md"
}
# header_once DIR LABEL: DIR/CHANGELOG.txt starts with the header and a blank
# line and holds each header line once; DIR/notes.md is the marker line, then
# the same text, then the end marker, with no VirusTotal section marker in it.
header_once() {
  local text="$1/CHANGELOG.txt" notes="$1/notes.md"
  { [ "$(sed -n 1p "${text}")" = "Grand Treasure Island" ] \
    && [ "$(sed -n 2p "${text}")" = "https://grandtreasureisland.vercel.app/" ] && [ -z "$(sed -n 3p "${text}")" ] \
    && [ "$(sed -n 4p "${text}")" = "Changes in build $3:" ] \
    && [ "$(grep -c -x -F "Grand Treasure Island" "${text}")" = 1 ] \
    && [ "$(grep -c -F "grandtreasureisland.vercel.app" "${text}")" = 1 ]; } \
    || fail "$2: CHANGELOG.txt does not start with the header once, then build $3's changes: $(cat "${text}")"
  { [ "$(sed -n 1p "${notes}")" = "<!-- changelog: build $3 -->" ] && sed '1d;$d' "${notes}" | cmp -s - "${text}" \
    && [ "$(tail -n 1 "${notes}")" = "<!-- /changelog -->" ] && ! grep -q "^VirusTotal reports" "${notes}"; } \
    || fail "$2: notes.md is not the marker line, CHANGELOG.txt's text and the end line: $(cat "${notes}")"
}
# passes|stops LABEL ARGS...: the tool with ARGS exits 0 | 1.
passes() { local label="$1"; shift; status="$(tool "$@")"; [ "${status}" = 0 ] || fail "${label}: exited ${status}, not 0: $(cat "${work}/out")"; }
stops() { local label="$1"; shift; status="$(tool "$@")"; [ "${status}" = 1 ] || fail "${label}: exited ${status}, not 1: $(cat "${work}/out")"; }

commit                                   # build 1: no changelog yet
entries 2; commit; release 2             # build 2, released
git -C "${repo}" checkout -q -b side
commit                                   # build 3 on a side branch: its tag is not in main's history
release 3
git -C "${repo}" checkout -q main
entries 3 2; commit                      # build 3, never released
entries 4 3 2; commit                    # build 4

[ "$(number)" = 4 ] || fail "the throwaway history is not at build 4"
passes "next" next
shows "## Build 5 ($(date -u +%F))" || fail "next did not suggest build 5's heading: $(cat "${work}/out")"
passes "check at build 4" check
{ shows "build 4 (commit" && shows "Changes in build 4:" && shows "- Change 4, first." && shows "- Change 3, first." \
  && ! shows "Change 2"; } || fail "check at build 4 did not show builds 4 and 3 since release 2 (the side branch's tag 3 is not in HEAD's history): $(cat "${work}/out")"

passes "notes --build 4" notes --build 4 --out "${work}/notes" --link https://example.invalid/CHANGELOG.md
cat > "${work}/expected.md" <<'EOF'
<!-- changelog: build 4 -->
Grand Treasure Island
https://grandtreasureisland.vercel.app/

Changes in build 4:

- Change 4, first.
- ::warning::change 4, second.
- Change 3, first.
- ::warning::change 3, second.

Every build's changes: https://example.invalid/CHANGELOG.md
<!-- /changelog -->
EOF
cmp -s "${work}/expected.md" "${work}/notes/notes.md" || fail "notes.md for build 4: $(diff "${work}/expected.md" "${work}/notes/notes.md" || true)"
sed '1d;$d' "${work}/expected.md" | cmp -s - "${work}/notes/CHANGELOG.txt" || fail "CHANGELOG.txt for build 4 is not notes.md without its two marker lines"
header_once "${work}/notes" "two unreleased entries" 4

# Build 4 published: its own tag must not count as the release before it.
release 4
passes "notes --build 4 with build 4's own tag" notes --build 4 --out "${work}/notes4"
grep -q -F "Change 3, first." "${work}/notes4/notes.md" || fail "with build 4 tagged, its notes lost build 3's entry"

# The range rule's edges at one head.
commit; commit                           # builds 5 and 6, release 4 the newest
entries 4 3 2; stops "newest entry equal to the newest release" check
shows "no entry since build 4" && shows "## Build 7 (" || fail "check without a new entry did not name release 4 and suggest build 7: $(cat "${work}/out")"
stops "notes without a new entry" notes --build 6 --out "${work}/none"
[ ! -e "${work}/none/notes.md" ] || fail "notes wrote notes.md for a build without its entry"
entries 5 4 3 2; passes "newest entry one above the release" check
entries 6 4 3 2; passes "newest entry equal to the build" check
entries 7 4 3 2; stops "newest entry above the build" check
shows "after build 6" && shows "renumber that entry to at most 6" && ! shows "add the entry" \
  || fail "an entry above the build was not named with the advice to renumber it: $(cat "${work}/out")"

# An entry written at the suggested number, then a retro commit and a merge
# commit (as the integrator's last steps and GitHub's merge button make): the
# entry still counts, and the notes carry the release head's real number.
entries 7 4 3 2; commit                  # build 7 with its entry
echo "retro" > "${repo}/RETRO.md"; git -C "${repo}" add RETRO.md; git -C "${repo}" commit -q -m retro
git -C "${repo}" checkout -q -b feature HEAD~1
echo "x" > "${repo}/feature.gd"; git -C "${repo}" add feature.gd; git -C "${repo}" commit -q -m feature
git -C "${repo}" checkout -q main
git -C "${repo}" merge -q --no-ff -m merge feature
head_number="$(number)"
[ "$(git -C "${repo}" rev-list --parents -n 1 HEAD | wc -w)" = 3 ] || fail "the release head is not a merge commit"
passes "a merge commit after the entry" check
shows "Changes in build ${head_number}:" && shows "- Change 7, first." && ! shows "Change 4" \
  || fail "the merge head's notes do not carry its number ${head_number} and build 7's entry: $(cat "${work}/out")"

# A published build's notes, re-made from this later head (an itch.io re-push).
passes "notes --published for build 4" notes --build 4 --published --out "${work}/again"
cmp -s "${work}/notes4/notes.md" "${work}/again/notes.md" || fail "notes --published for build 4 differ from its own: $(diff "${work}/notes4/notes.md" "${work}/again/notes.md" || true)"
release "${head_number}"
commit                                   # a build with no entry, after that release
status="$(tool notes --build "$(number)" --published --out "${work}/empty")"
{ [ "${status}" = 3 ] && [ ! -e "${work}/empty/notes.md" ]; } || fail "notes --published without an entry exited ${status}, not 3, or wrote notes"

# Eleven unreleased entries: the notes take the newest 10; "No changes to the
# game." goes when other lines come with it.
for _ in $(seq 12); do commit; done
top="$(number)"; base="${head_number}"
{
  echo "# Changes"
  for i in $(seq 11 -1 1); do
    echo ""; echo "## Build $((base + i)) (2026-11-16)"; echo ""
    if [ "${i}" = 11 ]; then echo "- No changes to the game."; else echo "- Line ${i}."; fi
  done
  echo ""; echo "## Build ${base} (2026-11-16)"; echo ""; echo "- Released."
} > "${repo}/CHANGELOG.md"
passes "eleven unreleased entries" notes --build "${top}" --out "${work}/eleven"
{ grep -q -F -- "- Line 10." "${work}/eleven/notes.md" && grep -q -F -- "- Line 2." "${work}/eleven/notes.md" \
  && ! grep -q -F -- "- Line 1." "${work}/eleven/notes.md" && ! grep -q -F "No changes" "${work}/eleven/notes.md" \
  && ! grep -q -F "Released" "${work}/eleven/notes.md"; } \
  || fail "the notes of 11 unreleased entries are not the newest 10 without \"No changes\": $(cat "${work}/eleven/notes.md")"
header_once "${work}/eleven" "eleven unreleased entries" "${top}"
{ printf '# Changes\n\n## Build %s (2026-11-16)\n\n- No changes to the game.\n' "${top}"; } > "${repo}/CHANGELOG.md"
passes "an entry of no changes alone" notes --build "${top}" --out "${work}/nochange"
grep -q -F -- "- No changes to the game." "${work}/nochange/notes.md" || fail "an entry of \"No changes to the game.\" alone lost its line"
header_once "${work}/nochange" "one entry" "${top}"
# Two unreleased entries sharing a line: the notes carry it once, where the
# newer entry has it.
printf '# Changes\n\n## Build %s (2026-11-16)\n\n- Shared.\n- Newer.\n\n## Build %s (2026-11-16)\n\n- Older.\n- Shared.\n' \
  "${top}" "$((top - 1))" > "${repo}/CHANGELOG.md"
passes "two entries sharing a line" notes --build "${top}" --out "${work}/shared"
printf 'Grand Treasure Island\nhttps://grandtreasureisland.vercel.app/\n\nChanges in build %s:\n\n- Shared.\n- Newer.\n- Older.\n' "${top}" \
  | cmp -s - "${work}/shared/CHANGELOG.txt" \
  || fail "the notes of two entries sharing a line do not carry it once: $(cat "${work}/shared/CHANGELOG.txt")"

# A push of Markdown alone builds nothing and needs no entry; check says what a
# run started by hand on it would need, and --hand-run fails then.
entries 4 3 2; git -C "${repo}" add -A; git -C "${repo}" commit -q -m "changelog"
git -C "${repo}" update-ref refs/remotes/origin/main HEAD
echo "notes" > "${repo}/README.md"; git -C "${repo}" add README.md; git -C "${repo}" commit -q -m docs
passes "check of Markdown alone" check
shows "changes only Markdown since origin/main" && shows "NOTE: a run started by hand on this head" && shows "would stop" \
  || fail "check of Markdown alone did not pass with a note that a run by hand would stop: $(cat "${work}/out")"
stops "check --hand-run of Markdown alone without an entry" check --hand-run
entries "$(number)" 4 3 2; git -C "${repo}" add -A; git -C "${repo}" commit -q -m "entry"
passes "check --hand-run with a recovery entry" check --hand-run
passes "check of a recovery entry" check
shows "would find its entry" || fail "check of a recovery entry did not say a run by hand would find it: $(cat "${work}/out")"
echo "x" > "${repo}/data.json"; git -C "${repo}" add data.json; git -C "${repo}" commit -q -m data
passes "check of a JSON change under a still-unreleased entry" check
release "$(number)"; commit
stops "check of a change after the newest release with no entry" check

passes "latest" latest
shows "CHANGES: build" && ! shows "FAIL" || fail "latest did not print CHANGES lines: $(cat "${work}/out")"
printf '# Changes\n' > "${repo}/CHANGELOG.md"
passes "latest without entries" latest
shows "CHANGES: none" && ! shows "FAIL" || fail "latest without entries printed FAIL or no CHANGES line: $(cat "${work}/out")"

# No release tag in the history: which entries are new is unknown, so it fails.
bare="${work}/bare"
git init -q -b main "${bare}"; mkdir -p "${bare}/tools"; cp tools/changelog.py tools/build-number tools/docs-only "${bare}/tools/"
printf '# Changes\n\n## Build 1 (2026-11-16)\n\n- First.\n' > "${bare}/CHANGELOG.md"
git -C "${bare}" add -A; git -C "${bare}" commit -q -m first
status=0; (cd "${bare}" && python3 -I tools/changelog.py check) > "${work}/out" 2>&1 || status=$?
cat "${work}/out" >> "${log}"
{ [ "${status}" = 1 ] && shows "git fetch --tags origin"; } || fail "check with no release tag exited ${status}, not 1 with the fetch hint: $(cat "${work}/out")"

# broken LABEL SHOWN: CHANGELOG.md as ${work}/broken.md now stands must fail
# check, and the failure must show SHOWN.
broken() {
  cp "${work}/broken.md" "${repo}/CHANGELOG.md"
  status="$(tool check)"
  { [ "${status}" = 1 ] && shows "$2"; } || fail "$1: exited ${status}, not 1 showing $2: $(cat "${work}/out")"
}
good() { printf '# Changes\n\n## Build 9 (2026-11-16)\n\n- Fine.\n\n## Build 8 (2026-11-15)\n\n- Fine.\n'; }
good | sed 's/## Build 9 (2026-11-16)/## Build 9/' > "${work}/broken.md"; broken "heading without a date" "an entry's heading reads"
good | sed 's/## Build 9/## build 9/' > "${work}/broken.md"; broken "lower-case heading" "an entry's heading reads"
good | sed 's/2026-11-16/2026-02-30/' > "${work}/broken.md"; broken "impossible date" "is not a date"
good | sed 's/## Build 8/## Build 10/' > "${work}/broken.md"; broken "oldest first" "entries go newest first"
good | sed 's/## Build 8/## Build 9/' > "${work}/broken.md"; broken "two entries for one build" "entries go newest first"
good | sed '5d' > "${work}/broken.md"; broken "an entry without lines" "build 9's entry has 0 lines"
{ good | sed -n '1,4p'; for i in $(seq 13); do echo "- Line ${i}."; done; } > "${work}/broken.md"; broken "13 lines" "has 13 lines"
good | sed 's/^- Fine\.$/A paragraph./' > "${work}/broken.md"; broken "a paragraph" "each of its lines is"
good | sed 's/^- Fine\.$/- Fine.\n  - Nested./' > "${work}/broken.md"; broken "a nested line" "each of its lines is"
good | sed 's/^- Fine\.$/- Thanks @someone./' > "${work}/broken.md"; broken "an @mention" 'has an "@"'
good | sed 's/^- Fine\.$/- A <b>bold<\/b> change./' > "${work}/broken.md"; broken "HTML" 'has a "<"'
good | sed 's/^- Fine\.$/- See ![a picture](x.png)./' > "${work}/broken.md"; broken "an image" 'no images or links'
good | sed 's/^- Fine\.$/- See [the page](https:\/\/example.invalid)./' > "${work}/broken.md"; broken "a link" 'no images or links'
good | sed 's/^- Fine\.$/- [page]: https:\/\/example.invalid/' > "${work}/broken.md"; broken "a link definition" 'no images or links'
good | sed 's/^- Fine\.$/- Thanks \&#64;someone./' > "${work}/broken.md"; broken "an HTML entity" 'has an "&"'
# The header is the tool's own text: an entry can neither link the website nor
# write a line of the header itself.
good | sed 's/^- Fine\.$/- [Grand Treasure Island](https:\/\/grandtreasureisland.vercel.app\/)/' > "${work}/broken.md"; broken "the website as a link" 'no images or links'
good | sed 's/^- Fine\.$/https:\/\/grandtreasureisland.vercel.app\//' > "${work}/broken.md"; broken "the website as a header line" "each of its lines is"
good | sed 's/^- Fine\.$/Grand Treasure Island/' > "${work}/broken.md"; broken "the game's name as a header line" "each of its lines is"
# A bare address stays allowed.
good | sed 's/^- Fine\.$/- More at https:\/\/example.invalid\/page./' > "${repo}/CHANGELOG.md"
passes "a bare address" latest
shows "CHANGES:   - More at https://example.invalid/page." || fail "a bare address did not read: $(cat "${work}/out")"
good | sed 's/^- Fine\.$/- Hidden\xe2\x80\x8bspace./' > "${work}/broken.md"; broken "a zero-width space" "U+200B"
good | sed 's/^- Fine\.$/- Right\xe2\x80\xaeleft./' > "${work}/broken.md"; broken "a bidirectional override" "U+202E"
good | sed "s/^- Fine\\.\$/- $(printf 'x%.0s' $(seq 301))/" > "${work}/broken.md"; broken "a line of 301 characters" "more than 300"
good | sed 's/$/\r/' > "${work}/broken.md"; broken "CRLF line ends" "carriage return"
good | sed 's/^- Fine\.$/- Caf\xe9./' > "${work}/broken.md"; broken "Latin-1, not UTF-8" "is not UTF-8"
rm "${repo}/CHANGELOG.md"
broken_missing="$(tool check)"
{ [ "${broken_missing}" = 1 ] && shows "there is no CHANGELOG.md"; } || fail "check without CHANGELOG.md exited ${broken_missing}, not 1"

# No output line starts with "::": the entries above hold "::warning::" lines.
if grep -n '^::' "${log}"; then
  fail "an output line starts with \"::\", which GitHub Actions would read as a workflow command"
fi
grep -q -F 'warning::change 4' "${log}" || fail "the log never showed the \"::warning::\" entry line, so the check above checked nothing"

# The repository's own CHANGELOG.md reads well (its build check is for a release
# head: tools/changelog.py check), and its introduction has the website the
# header names on a line of its own. -B: no __pycache__ in tools/.
if ! python3 -I -B -c 'import importlib.util
spec = importlib.util.spec_from_file_location("changelog", "tools/changelog.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
module.read_entries()
introduction = open("CHANGELOG.md", encoding="utf-8").read().split("\n## ", 1)[0]
if module.HEADER[1] not in introduction.split("\n"):
    raise SystemExit("its introduction has no line that is the website " + module.HEADER[1])' 2> "${work}/own"; then
  fail "the repository's CHANGELOG.md does not read: $(cat "${work}/own")"
fi

if [ "${failures}" -gt 0 ]; then
  exit 1
fi
echo "PASS: tools/changelog.py takes the newest entry above the newest release in HEAD's history and at most HEAD's build (edges, side-branch and own tags, no tag, a merge head after the entry), fails a build without one, notes a push of Markdown alone that a run by hand would stop on, writes notes under the game's name and website once, with the real build number and up to 10 unreleased entries, re-makes a published build's notes, rejects every break of the format, never prints FAIL from latest or starts an output line with \"::\"; the repository's CHANGELOG.md reads well and names the website"
