#!/usr/bin/env bash
# Builds the web version of origin/main and deploys it to production on Vercel,
# using your saved Vercel CLI login (once: npx vercel@64.5.0 login).
#
#   tools/deploy-web.sh                    -> checks, link if needed, build, deploy, print the URL
#   tools/deploy-web.sh --dry-run          -> the same checks and build; prints the link and
#                                             deploy commands instead of running them
#   tools/deploy-web.sh --check-sfx-guard  -> the sound guard below and nothing else: no git,
#                                             link, build or upload (tools/check_fetch_sfx.mjs
#                                             runs it offline with stand-in sources)
#   --silent-ok, with any of these         -> go on without every sound (below)
#
# Only a clean checkout whose HEAD is origin/main is deployed. To try the script
# on a branch, --dry-run --any-commit skips that one check; a real deploy never does.
#
# Sounds: the build fetches the game's sounds from the private source named by
# TI_SFX_SOURCE (tools/sfx/README.md), so every deploy sets it. Before anything
# else, the script stops if there is no source, or if a dry run of
# tools/fetch-sfx --require-all finds a sound in the game's catalog with no takes
# in the source (it names each). The build's own fetch then runs with
# --require-all as well, and its result must say that every sound got its takes.
# --silent-ok is the one way past this, for a deliberately silent (or partly
# silent) deploy: the build takes whatever the source has, or nothing, and a
# warning says so at the start and again at the end. A fetch that fails (a refused
# clone, a missing folder) stops the deploy even with --silent-ok. The SOUNDS line
# before the final PASS names the sound source, its commit and the number of takes
# the build fetched, for the release record; credentials never appear in it.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "${root}"
# npm/node live here in the devcontainer (node feature); non-login shells lack it.
export PATH="/usr/local/share/nvm/current/bin:${PATH}"

project=treasure-island
# The pinned CLI with only the saved login and build/web's own link: no token,
# team or project taken from the environment, and never the sound source's token.
vercel=(env -u VERCEL_TOKEN -u VERCEL_ORG_ID -u VERCEL_PROJECT_ID -u NOW_ORG_ID -u NOW_PROJECT_ID
  -u TI_SFX_GIT_TOKEN npx --yes vercel@64.5.0)

usage="usage: tools/deploy-web.sh [--dry-run [--any-commit]] [--silent-ok] | --check-sfx-guard [--silent-ok]"
dry_run=false
any_commit=false
silent_ok=false
guard_only=false
for arg in "$@"; do
  case "${arg}" in
    --dry-run) dry_run=true ;;
    --any-commit) any_commit=true ;;
    --silent-ok) silent_ok=true ;;
    --check-sfx-guard) guard_only=true ;;
    *) echo "${usage}" >&2; exit 2 ;;
  esac
done
if [ "${guard_only}" = true ] && { [ "${dry_run}" = true ] || [ "${any_commit}" = true ]; }; then
  echo "${usage}" >&2
  exit 2
fi
if [ "${any_commit}" = true ] && [ "${dry_run}" = false ]; then
  echo "FAIL: --any-commit only works with --dry-run; a real deploy ships origin/main" >&2
  exit 2
fi

# The sound fetch's results (tools/fetch-sfx --result): the guard's dry run and the build's fetch.
sfx_results="$(mktemp -d)"
trap 'rm -rf "${sfx_results}"' EXIT
preflight="${sfx_results}/preflight.json"
fetched="${sfx_results}/build.json"
build_args=(--sfx-result "${fetched}")
silent_warning=""

# A warning that stands out in a long build log.
loud() {
  local rule="=================================================================="
  printf 'WARNING: %s\n' "${rule}" "$1" "${rule}" >&2
}

# The sound guard (see the header): stops the deploy, or sets how the build fetches.
sound_guard() {
  local status=0
  if [ -z "${TI_SFX_SOURCE:-}" ]; then
    if [ "${silent_ok}" = false ]; then
      echo "FAIL: no sound source: TI_SFX_SOURCE is not set, so the build would ship the game without sound. Set it to the private sound source (tools/sfx/README.md), or pass --silent-ok to deploy a silent game on purpose" >&2
      exit 1
    fi
    silent_warning="SILENT DEPLOY (--silent-ok): TI_SFX_SOURCE is not set, so the game ships WITHOUT SOUND"
    loud "${silent_warning}"
    return
  fi
  tools/fetch-sfx --dry-run --require-all --result "${preflight}" || status=$?
  case "${status}" in
    0) build_args+=(--sfx-require-all) ;;
    3)
      if [ "${silent_ok}" = false ]; then
        echo "FAIL: the sound source has no takes for the sounds listed above, so the build would ship them silent. Add their takes to the source, or pass --silent-ok to deploy without them on purpose" >&2
        exit 1
      fi
      silent_warning="PARTLY SILENT DEPLOY (--silent-ok): sounds with no takes in the source ship SILENT (listed on the SOUNDS line)"
      loud "${silent_warning}" ;;
    *)
      echo "FAIL: the sound fetch failed (tools/fetch-sfx exited ${status}); nothing was built or uploaded" >&2
      exit 1 ;;
  esac
}

# Prints the SOUNDS line for a tools/fetch-sfx result file (a missing file: no
# source). With "require" it fails unless that fetch gave every sound its takes.
#   sounds_summary show|require FILE
sounds_summary() {
  python3 -I - "$@" <<'EOF'
import json, sys
mode, path = sys.argv[1:3]
try:
    with open(path, encoding="utf-8") as handle:
        result = json.load(handle)
    if result.get("schema_version") != "ti.sfx-fetch-result/1":
        raise ValueError("schema_version %r" % result.get("schema_version"))
    source, ref, subdir, commit = result["source"], result["ref"], result["subdir"], result["commit"]
    takes, sounds, with_takes = result["takes"], result["sounds"], result["sounds_with_takes"]
    silent = [entry["id"] for entry in result["silent"]]
    complete = result["complete"] is True
except FileNotFoundError:
    if mode == "require":
        sys.exit("FAIL: the sound fetch wrote no result (%s), so nothing shows every sound got its takes" % path)
    print("SOUNDS: NONE: no sound source (--silent-ok)")
    sys.exit(0)
except (ValueError, KeyError, TypeError) as error:
    sys.exit("FAIL: the sound fetch result %s does not read: %s" % (path, error))
if source is None:
    line = "SOUNDS: NONE: no sound source (--silent-ok); the build has %d takes" % takes
else:
    where = source + (" (ref %s)" % ref if ref else "") + (", %s" % subdir if subdir else "")
    line = "SOUNDS: %d takes for %d of %d sounds, from %s, %s" % (
        takes, with_takes, sounds, where, "commit %s" % commit if commit else "a folder (no commit)")
    if silent:
        line += "; SILENT (--silent-ok): " + ", ".join(silent)
if mode == "require" and not complete:
    sys.exit(line + "\nFAIL: the build's sound fetch did not give every sound its takes, so nothing was uploaded")
print(line)
EOF
}

sound_guard
if [ "${guard_only}" = true ]; then
  sounds_summary show "${preflight}"
  echo "PASS: the sound guard lets this deploy build (--check-sfx-guard: no git, link, build or upload)"
  exit 0
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
# (a .gitignore, and a .env.local holding a VERCEL_OIDC_TOKEN) are then gone
# before the upload.
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

tools/build-web.sh "${build_args[@]}"
# The build's own fetch, from its result: every sound with takes, unless --silent-ok.
if [ "${silent_ok}" = true ]; then
  sounds="$(sounds_summary show "${fetched}")"
else
  sounds="$(sounds_summary require "${fetched}")"
fi

# Only the build may be uploaded. Refuses any .env file, even one the CLI would
# skip, and any other hidden file except the link (.vercel, which the CLI never
# uploads) and build-web.sh's .vercelignore. Checks names only, never contents.
refuse_hidden_files() {
  local hidden
  hidden="$(find build/web -mindepth 1 \( -name '.env*' -o -name '.*' ! -path build/web/.vercel \
    ! -path 'build/web/.vercel/*' ! -path build/web/.vercelignore \) -print)" || return 1
  if [ -n "${hidden}" ]; then
    printf 'FAIL: delete these from build/web; they must not be uploaded:\n%s\n' "${hidden}" >&2
    return 1
  fi
}
refuse_hidden_files || exit 1

# The summary's sound lines: the warning again for a silent deploy, then SOUNDS.
sound_lines() {
  [ -z "${silent_warning}" ] || loud "${silent_warning}"
  echo "${sounds}"
}

deploy=("${vercel[@]}" deploy --prod --json)
if [ "${dry_run}" = true ]; then
  echo "DRY RUN: in build/web, would run: ${deploy[*]}"
  sound_lines
  echo "PASS: dry run for ${head:0:8}; nothing was linked or uploaded"
  exit 0
fi

# Runs the deploy command given as arguments in build/web, then prints PASS with
# the URL or FAIL. With --json, CLI 64.5.0 prints one JSON object on stdout: the
# deployment, or a status object holding it when the CLI detects an AI agent
# (CLAUDECODE, AI_AGENT, CODEX_* and others) while stdin is not a terminal. Its
# progress and the production alias go to stderr.
deploy_to_production() {
  local output status=0 url
  output="$(cd build/web && "$@")" || status=$?
  if [ "${status}" -ne 0 ]; then
    echo "FAIL: the deploy exited ${status}: ${output}" >&2
    return 1
  fi
  url="$(python3 -I -c '
import json, sys
out = sys.stdin.read().strip()
try:
    result = json.loads(out)
    deployment = result.get("deployment", result)
    state = [result.get("status", "ok"), deployment["readyState"], deployment["target"]]
    urls = [deployment["productionUrl"], deployment["url"]]
except (ValueError, KeyError, TypeError, AttributeError):
    sys.exit("FAIL: unexpected deploy output: " + out)
# productionUrl is null unless the production domain now points at this deployment.
if state != ["ok", "READY", "production"] or not urls[0] or deployment.get("error"):
    sys.exit("FAIL: the deploy is not ready on the production domain: " + out)
print("%s (deployment %s)" % tuple(urls))
' <<< "${output}")" || return 1
  sound_lines
  echo "PASS: deployed ${head:0:8} to production: ${url}"
}
deploy_to_production "${deploy[@]}"
