#!/usr/bin/env bash
# Checks tools/build-number in a throwaway repository shaped like main's
# history: each newer head of main gets a larger number than the one before,
# after an ordinary commit, a merge, and a fast-forward to a branch that merged
# main (whose first-parent line is shorter than main's was). A shallow clone
# is refused, with nothing on standard output, and a partial clone
# (--filter=blob:none, as CI checks out) gives the same numbers as the full
# repository. Takes about a second. Part of tools/test.sh.
#
#   tools/check_build_number.sh
set -euo pipefail
cd "$(dirname "$0")/.."
tool="${PWD}/tools/build-number"
work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
# Nothing of the caller's Git reaches the check: not a repository it points at
# (a hook sets GIT_DIR, for one), nor user or system settings (signing, hooks,
# default branch).
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_COMMON_DIR GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=check GIT_AUTHOR_EMAIL=check@example.invalid
export GIT_COMMITTER_NAME=check GIT_COMMITTER_EMAIL=check@example.invalid
failures=0
fail() { echo "FAIL: $*"; failures=$((failures + 1)); }

repo="${work}/main"
git init -q -b main "${repo}"
git -C "${repo}" config uploadpack.allowFilter true
step=0
# commit: one new commit on the current branch, with a file of its own.
commit() {
  step=$((step + 1))
  echo "${step}" > "${repo}/file-${step}.txt"
  git -C "${repo}" add "file-${step}.txt"
  git -C "${repo}" commit -q -m "commit ${step}"
}
number() { (cd "${repo}" && "${tool}" "$@"); }

heads=()
commit; commit; heads+=("$(git -C "${repo}" rev-parse HEAD)")
commit; heads+=("$(git -C "${repo}" rev-parse HEAD)")
# A branch from main's first commit merges main, and main fast-forwards to it:
# its first-parent line (merge, branch commit, first commit) is shorter than
# main's was.
git -C "${repo}" checkout -q -b release "${heads[0]}~1"
commit
git -C "${repo}" merge -q --no-ff -m "merge main" main
git -C "${repo}" checkout -q main
git -C "${repo}" merge -q --ff-only release
heads+=("$(git -C "${repo}" rev-parse HEAD)")
# An ordinary merge of a topic branch into main.
git -C "${repo}" checkout -q -b topic
commit; commit
git -C "${repo}" checkout -q main
commit
git -C "${repo}" merge -q --no-ff -m "merge topic" topic
heads+=("$(git -C "${repo}" rev-parse HEAD)")

previous=0
for head in "${heads[@]}"; do
  n="$(number "${head}")"
  [ "${n}" -gt "${previous}" ] || fail "main's head ${head:0:7} got ${n}, not more than the previous head's ${previous}"
  previous="${n}"
done
[ "$(number)" = "${previous}" ] || fail "with no argument it did not give HEAD's number ${previous}"
topic="$(number topic)"
[ "${previous}" -gt "${topic}" ] || fail "the merge of topic got ${previous}, not more than topic's ${topic}"
first_parent="$(git -C "${repo}" rev-list --count --first-parent "${heads[2]}")"
[ "${first_parent}" -le "$(number "${heads[1]}")" ] || fail "the fixture's fast-forward does not shorten main's first-parent line, so it shows nothing"

partial="${work}/partial"
git clone -q --filter=blob:none --no-checkout "file://${repo}" "${partial}"
for head in "${heads[@]}"; do
  [ "$(cd "${partial}" && "${tool}" "${head}")" = "$(number "${head}")" ] || fail "a partial clone gave another number for ${head:0:7}"
done

shallow="${work}/shallow"
git clone -q --depth 1 "file://${repo}" "${shallow}"
status=0
(cd "${shallow}" && "${tool}") > "${work}/out" 2> "${work}/err" || status=$?
[ "${status}" -eq 1 ] || fail "a shallow clone exited ${status}, not 1"
[ ! -s "${work}/out" ] || fail "a shallow clone printed a number: $(cat "${work}/out")"
grep -q "shallow" "${work}/err" || fail "a shallow clone's refusal does not say why: $(cat "${work}/err")"

status=0
number HEAD HEAD > /dev/null 2>&1 || status=$?
[ "${status}" -eq 2 ] || fail "two arguments exited ${status}, not 2 (usage)"

if [ "${failures}" -gt 0 ]; then
  exit 1
fi
echo "PASS: tools/build-number gives each newer head of main a larger number (after a commit, a fast-forward to a branch that merged main, and a merge), the same in a partial clone; a shallow clone is refused with nothing printed"
