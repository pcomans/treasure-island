#!/usr/bin/env bash
# Builds the web version of origin/main and deploys it to production on Vercel,
# using your saved Vercel CLI login (once: npx vercel@64.5.0 login).
#
#   tools/deploy-web.sh             -> checks, link if needed, build, deploy, print the URL
#   tools/deploy-web.sh --dry-run   -> the same checks and build; prints the link and
#                                      deploy commands instead of running them
#
# Only a clean checkout whose HEAD is origin/main is deployed. To try the script
# on a branch, --dry-run --any-commit skips that one check; a real deploy never does.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "${root}"
# npm/node live here in the devcontainer (node feature); non-login shells lack it.
export PATH="/usr/local/share/nvm/current/bin:${PATH}"

project=treasure-island
# The pinned CLI with only the saved login and build/web's own link: no token,
# team or project taken from the environment.
vercel=(env -u VERCEL_TOKEN -u VERCEL_ORG_ID -u VERCEL_PROJECT_ID -u NOW_ORG_ID -u NOW_PROJECT_ID
  npx --yes vercel@64.5.0)

dry_run=false
any_commit=false
for arg in "$@"; do
  case "${arg}" in
    --dry-run) dry_run=true ;;
    --any-commit) any_commit=true ;;
    *) echo "usage: tools/deploy-web.sh [--dry-run [--any-commit]]" >&2; exit 2 ;;
  esac
done
if [ "${any_commit}" = true ] && [ "${dry_run}" = false ]; then
  echo "FAIL: --any-commit only works with --dry-run; a real deploy ships origin/main" >&2
  exit 2
fi

git fetch -q origin main
if [ -n "$(git status --porcelain)" ]; then
  echo "FAIL: commit or stash your changes first; only a clean checkout of main is deployed" >&2
  exit 1
fi
head="$(git rev-parse HEAD)"
main="$(git rev-parse origin/main)"
if [ "${head}" != "${main}" ]; then
  if [ "${any_commit}" = false ]; then
    echo "FAIL: HEAD ${head:0:8} is not origin/main ${main:0:8}; push to main and check it out first" >&2
    exit 1
  fi
  echo "NOTE: --any-commit: HEAD ${head:0:8} is not origin/main ${main:0:8}; dry run only"
fi

# build/web/.vercel is the Vercel CLI's link to the project. tools/build-web.sh
# keeps it and clears everything else, so link first: the link's other files
# (a .gitignore) are then gone before the upload.
link_file=build/web/.vercel/project.json
linked_project() {
  python3 -I -c 'import json, sys; print(json.load(open(sys.argv[1])).get("projectName", ""))' \
    "${link_file}" 2>/dev/null || true
}
linked="$(linked_project)"
if [ -z "${linked}" ]; then
  # --non-interactive without --yes links an existing project only, never a new
  # one, and stops if the login has several teams: then link once by hand with --team.
  link=("${vercel[@]}" link --non-interactive --project "${project}")
  if [ "${dry_run}" = true ]; then
    echo "DRY RUN: in build/web, would run: ${link[*]}"
  else
    mkdir -p build/web
    (cd build/web && "${link[@]}")
    linked="$(linked_project)"
    if [ "${linked}" != "${project}" ]; then
      echo "FAIL: linking did not link build/web to ${project}" >&2
      exit 1
    fi
  fi
elif [ "${linked}" != "${project}" ]; then
  echo "FAIL: build/web is linked to the Vercel project '${linked}', not '${project}'" >&2
  exit 1
fi

tools/build-web.sh

deploy=("${vercel[@]}" deploy --prod)
if [ "${dry_run}" = true ]; then
  echo "DRY RUN: in build/web, would run: ${deploy[*]}"
  echo "PASS: dry run for ${head:0:8}; nothing was linked or uploaded"
  exit 0
fi
# With stdout captured the CLI prints only the deployment URL there; its
# progress and the production alias go to stderr.
url="$(cd build/web && "${deploy[@]}")"
case "${url}" in
  https://*) echo "PASS: deployed ${head:0:8} to production: ${url}" ;;
  *) echo "FAIL: unexpected deploy output: ${url}" >&2; exit 1 ;;
esac
