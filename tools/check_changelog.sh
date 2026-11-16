#!/usr/bin/env bash
# Checks tools/changelog.py, the players' changelog tool, and the repository's
# own CHANGELOG.md, in a throwaway repository with releases tagged as the Mac
# build workflow tags them:
# - check passes when the newest entry is HEAD's build, and shows the notes;
#   fails when a commit that builds has no entry, naming the next commit's
#   heading; passes a push of Markdown alone with no new entry;
# - every rule of the format fails a file that breaks it: the heading, order,
#   1 to 12 one-line "- " lines, length, "@", "<", invisible characters, CR
#   line ends, UTF-8;
# - notes writes build N's entry with those of builds since the last release
#   tag that got no release, between the markers, and fails without build N's;
# - extract takes them back out of release notes, CRLF as a web edit leaves
#   them, and exits 3 for notes without them;
# - no output line starts with "::", so a GitHub Actions log never reads a line
#   of the changelog as a workflow command.
# Offline, about a second. Part of tools/test.sh.
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
step=0
# commit [MESSAGE]: commits the working tree with a change to the game.
commit() {
  step=$((step + 1))
  echo "${step}" > "${repo}/game.gd"
  git -C "${repo}" add -A
  git -C "${repo}" commit -q -m "commit ${step}"
}
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

commit                                   # build 1: no changelog yet
entries 2; commit                        # build 2, released
head2="$(git -C "${repo}" rev-parse --short=7 HEAD)"
git -C "${repo}" tag "build-000002-2026-11-16-${head2}"
entries 3 2; commit                      # build 3, never released
entries 4 3 2; commit                    # build 4

status="$(tool next)"
[ "${status}" = 0 ] && shows "## Build 5 ($(date -u +%F))" || fail "next did not print build 5's heading: $(cat "${work}/out")"

status="$(tool check)"
{ [ "${status}" = 0 ] && shows "newest entry is build 4's" && shows "Changes in build 4 (2026-11-16):" \
  && shows "Changes in build 3 (2026-11-16):" && ! shows "Changes in build 2"; } \
  || fail "check at build 4 did not pass with builds 4 and 3 in the notes (exit ${status}): $(cat "${work}/out")"

status="$(tool notes --build 4 --out "${work}/notes" --link https://example.invalid/CHANGELOG.md)"
expected="${work}/expected.md"
cat > "${expected}" <<'EOF'
<!-- changelog: build 4 -->
Changes in build 4 (2026-11-16):

- Change 4, first.
- ::warning::change 4, second.

Changes in build 3 (2026-11-16):

- Change 3, first.
- ::warning::change 3, second.

Every build's changes: https://example.invalid/CHANGELOG.md
<!-- /changelog -->
EOF
{ [ "${status}" = 0 ] && cmp -s "${expected}" "${work}/notes/notes.md"; } \
  || fail "notes --build 4 did not write builds 4 and 3 between the markers (exit ${status}): $(cat "${work}/out"; diff "${expected}" "${work}/notes/notes.md" || true)"

# Release notes as GitHub keeps them after an edit on the web: CRLF line ends.
{ cat "${work}/notes/notes.md"; printf '\nThe build itself.\n\nVirusTotal reports, by each file'"'"'s SHA-256\n'; } \
  | sed 's/$/\r/' > "${work}/body.md"
status="$(tool extract "${work}/body.md" --build 4 --out "${work}/CHANGELOG.txt")"
{ [ "${status}" = 0 ] && sed '1d;$d' "${expected}" | cmp -s - "${work}/CHANGELOG.txt"; } \
  || fail "extract did not take build 4's lines back out of CRLF release notes (exit ${status}): $(cat "${work}/out")"
status="$(tool extract "${work}/body.md" --build 3 --out "${work}/none.txt")"
{ [ "${status}" = 3 ] && [ ! -e "${work}/none.txt" ]; } || fail "extract of a build the notes do not hold exited ${status}, not 3"
printf '<!-- changelog: build 4 -->\n- Cut short.\n' > "${work}/cut.md"
status="$(tool extract "${work}/cut.md" --build 4 --out "${work}/cut.txt")"
[ "${status}" = 1 ] || fail "extract of notes without the end line exited ${status}, not 1"

commit                                   # build 5: a change with no entry
status="$(tool check)"
{ [ "${status}" = 1 ] && shows "no entry for build 5" && shows "its newest is build 4's" && shows "## Build 6 ("; } \
  || fail "check at build 5 without an entry did not fail naming build 6's heading (exit ${status}): $(cat "${work}/out")"
status="$(tool notes --build 5 --out "${work}/notes5")"
{ [ "${status}" = 1 ] && [ ! -e "${work}/notes5/notes.md" ]; } || fail "notes --build 5 without an entry exited ${status}, not 1, or wrote notes"
status="$(tool latest)"
{ [ "${status}" = 0 ] && shows "CHANGES: build 4 (2026-11-16), the newest entry at or before build 5:" \
  && shows "CHANGES:   - Change 4, first."; } || fail "latest at build 5 did not show build 4's entry: $(cat "${work}/out")"

# Markdown alone since origin/main builds nothing and needs no entry; anything
# else does.
git -C "${repo}" update-ref refs/remotes/origin/main HEAD
echo "notes" > "${repo}/README.md"
git -C "${repo}" add README.md
git -C "${repo}" commit -q -m "docs"
status="$(tool check)"
{ [ "${status}" = 0 ] && shows "changes only Markdown since origin/main"; } \
  || fail "check of a push of Markdown alone did not pass (exit ${status}): $(cat "${work}/out")"
echo "x" > "${repo}/data.json"
git -C "${repo}" add data.json
git -C "${repo}" commit -q -m "data"
status="$(tool check)"
[ "${status}" = 1 ] || fail "check of a push with a JSON change and no entry exited ${status}, not 1"

# broken LABEL SHOWN: CHANGELOG.md as ${work}/broken.md now stands must fail
# check, and the failure must show SHOWN.
broken() {
  cp "${work}/broken.md" "${repo}/CHANGELOG.md"
  status="$(tool check)"
  { [ "${status}" = 1 ] && shows "$2"; } || fail "$1: exited ${status}, not 1 showing $2: $(cat "${work}/out")"
}
good() { printf '# Changes\n\n## Build 9 (2026-11-16)\n\n- Fine.\n\n## Build 8 (2026-11-15)\n\n- Fine.\n'; }
good > "${work}/broken.md"; cp "${work}/broken.md" "${repo}/CHANGELOG.md"
status="$(tool check)"
{ [ "${status}" = 1 ] && shows "no entry for build"; } || fail "the well-formed variant did not get past the format to the build check: $(cat "${work}/out")"
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
good | sed 's/^- Fine\.$/- Hidden\xe2\x80\x8bspace./' > "${work}/broken.md"; broken "a zero-width space" "U+200B"
good | sed 's/^- Fine\.$/- Right\xe2\x80\xaeleft./' > "${work}/broken.md"; broken "a bidirectional override" "U+202E"
good | sed "s/^- Fine\\.\$/- $(printf 'x%.0s' $(seq 301))/" > "${work}/broken.md"; broken "a line of 301 characters" "more than 300"
good | sed 's/$/\r/' > "${work}/broken.md"; broken "CRLF line ends" "carriage return"
good | sed 's/^- Fine\.$/- Caf\xe9./' > "${work}/broken.md"; broken "Latin-1, not UTF-8" "is not UTF-8"
rm "${repo}/CHANGELOG.md"
status="$(tool check)"
{ [ "${status}" = 1 ] && shows "there is no CHANGELOG.md"; } || fail "check without CHANGELOG.md exited ${status}, not 1"

# No output line starts with "::": the entries above hold "::warning::" lines.
if grep -n '^::' "${log}"; then
  fail "an output line starts with \"::\", which GitHub Actions would read as a workflow command"
fi
grep -q -F 'warning::change 4' "${log}" || fail "the log never showed the \"::warning::\" entry line, so the check above checked nothing"

# The repository's own CHANGELOG.md reads well (its build check is for a release
# head: tools/changelog.py check). -B: no __pycache__ in tools/.
if ! python3 -I -B -c 'import importlib.util
spec = importlib.util.spec_from_file_location("changelog", "tools/changelog.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
module.read_entries()' 2> "${work}/own"; then
  fail "the repository's CHANGELOG.md does not read: $(cat "${work}/own")"
fi

if [ "${failures}" -gt 0 ]; then
  exit 1
fi
echo "PASS: tools/changelog.py passes the newest entry for HEAD's build and a push of Markdown alone, fails a build without its entry (naming the next heading) and every break of the format, writes and extracts the release notes' changelog with builds since the last release, never starts an output line with \"::\"; the repository's CHANGELOG.md reads well"
