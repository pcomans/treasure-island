#!/usr/bin/env bash
# Deletes what in /tmp has gone unused for DAYS days (default 7). In this
# devcontainer /tmp is a plain directory on the container's disk, not a tmpfs,
# and nothing else ages it out (PID 1 is a shell, not systemd), so it only grows.
# Every container start runs it (postStartCommand in .devcontainer/devcontainer.json).
#
#   tools/clean-tmp.sh             # delete what has gone unused for 7 days
#   tools/clean-tmp.sh 3           # ... for 3 days
#   tools/clean-tmp.sh --dry-run   # list what would be deleted; delete nothing
#
# Unused, as systemd-tmpfiles judges it: a file not modified, read or changed for
# DAYS days; a directory that gained or lost no entries in that time. Old files go
# first, then the old directories that leaves empty. It stays on the /tmp
# filesystem, never follows symlinks and deletes only regular files and
# directories: sockets, symlinks and the like take no space, and their age says
# nothing about whether they are still in use. It never touches
#   - Claude Code's session scratch (claude-*),
#   - X11, ICE and font socket directories (.X11-unix, .ICE-unix, .font-unix, ...)
#     and X display locks (.X0-lock, ...),
#   - Wayland and Weston sockets and runtime directories (wayland-*, weston*, and
#     xdg-* and ti-browser-*, the runtime directories of tools/godot and tools/browser),
#   - systemd-private-* and DevPod's devpod.activity,
#   - anything a process has open, mapped or as its working directory (lsof).
set -euo pipefail

root=/tmp
dry_run=false
days=7
for arg in "$@"; do
  case "${arg}" in
    --dry-run) dry_run=true ;;
    ''|*[!0-9]*) echo "usage: tools/clean-tmp.sh [--dry-run] [DAYS]" >&2; exit 2 ;;
    *) days=$((10#${arg})) ;;
  esac
done
# The container is rootless: root's lsof can't see the user's open files.
if [ "$(id -u)" -eq 0 ]; then
  echo "tools/clean-tmp.sh: run it as the devcontainer user, not root; root's lsof can't see that user's open files" >&2
  exit 1
fi

# Paths under /tmp that a process has open, mapped or as its working directory.
declare -A in_use=()
min_age=$((days * 86400))
if command -v lsof >/dev/null && listing="$(lsof -nP -w -F n 2>/dev/null)"; then
  while IFS= read -r line; do
    case "${line}" in "n${root}/"*) in_use["${line#n}"]=1 ;; esac
  done <<< "${listing}"
else
  echo "NOTE: tools/clean-tmp.sh: without lsof it can't tell which files are open, so it keeps everything used in the last day"
  [ "${min_age}" -ge 86400 ] || min_age=86400
fi
cutoff=$(($(date +%s) - min_age))

# Every entry except the skipped top-level ones, parents before children, as
# "type 512-byte-blocks mtime atime ctime path" (times in seconds.fraction).
skip=(-name 'claude-*' -o -name '.*-unix' -o -name '.X*-lock' -o -name 'wayland-*' -o -name 'weston*'
  -o -name 'xdg-*' -o -name 'ti-browser-*' -o -name 'systemd-private-*' -o -name devpod.activity)
kinds=() blocks=() paths=() old=()
while IFS= read -r -d '' record; do
  kind="${record%% *}"; record="${record#* }"
  size="${record%% *}"; record="${record#* }"
  mtime="${record%%.*}"; record="${record#* }"
  atime="${record%%.*}"; record="${record#* }"
  ctime="${record%%.*}"; record="${record#* }"
  is_old=0
  case "${kind}" in
    f) ((mtime < cutoff && atime < cutoff && ctime < cutoff)) && is_old=1 ;;
    # Listing a directory updates its atime, so only entry changes count.
    d) ((mtime < cutoff && ctime < cutoff)) && is_old=1 ;;
  esac
  kinds+=("${kind}"); blocks+=("${size}"); paths+=("${record}"); old+=("${is_old}")
done < <(find "${root}" -xdev -mindepth 1 \( ! -path "${root}/*/*" \( "${skip[@]}" \) -prune \) \
  -o -printf '%y %b %T@ %A@ %C@ %p\0' 2>/dev/null)

# Whether this user may delete PATH (of type KIND) from PARENT: it needs write
# access to PARENT and, in a sticky directory such as /tmp itself, must own the
# entry or PARENT. A directory must also be readable, or what is in it is unknown.
deletable() {
  local path="$1" parent="$2" kind="$3"
  { [ -w "${parent}" ] && [ -x "${parent}" ]; } || return 1
  { [ ! -k "${parent}" ] || [ -O "${path}" ] || [ -O "${parent}" ]; } || return 1
  [ "${kind}" != d ] || { [ -r "${path}" ] && [ -x "${path}" ]; }
}

# Children before parents, so a directory goes only if everything in it goes.
declare -A keeps=()  # directories that keep at least one entry
files=() file_blocks=() dirs=() plan=()
planned=0 skipped_open=0 skipped_denied=0
for ((i = ${#paths[@]} - 1; i >= 0; i--)); do
  path="${paths[i]}"
  parent="${path%/*}"
  if [ "${old[i]}" = 1 ] && [ -z "${keeps[${path}]:-}" ]; then
    if [ -n "${in_use[${path}]:-}" ]; then
      skipped_open=$((skipped_open + 1))
    elif ! deletable "${path}" "${parent}" "${kinds[i]}"; then
      skipped_denied=$((skipped_denied + 1))
    elif [ "${kinds[i]}" = f ]; then
      files+=("${path}"); file_blocks+=("${blocks[i]}"); plan+=("${path}")
      planned=$((planned + blocks[i] * 512))
      continue
    else
      dirs+=("${path}"); plan+=("${path}/")
      continue
    fi
  fi
  keeps["${parent}"]=1
done

summary() { # verb, files, bytes, directories
  printf 'tools/clean-tmp.sh: %s %d files (%s) and %d directories unused for %d days; skipped %d in use, %d without permission\n' \
    "$1" "$2" "$(numfmt --to=iec-i --suffix=B "$3")" "$4" "$((min_age / 86400))" "${skipped_open}" "${skipped_denied}"
}

if [ "${dry_run}" = true ]; then
  for ((i = ${#plan[@]} - 1; i >= 0; i--)); do printf '%s\n' "${plan[i]}"; done
  summary "would delete" "${#files[@]}" "${planned}" "${#dirs[@]}"
  exit 0
fi

# rm and rmdir report anything they can't delete; the counts are of what is gone.
if [ ${#files[@]} -gt 0 ]; then printf '%s\0' "${files[@]}" | xargs -0 rm -f -- || true; fi
if [ ${#dirs[@]} -gt 0 ]; then printf '%s\0' "${dirs[@]}" | xargs -0 rmdir --ignore-fail-on-non-empty -- || true; fi
deleted=0 freed=0 removed=0
for i in "${!files[@]}"; do
  if [ ! -e "${files[i]}" ] && [ ! -L "${files[i]}" ]; then
    deleted=$((deleted + 1))
    freed=$((freed + file_blocks[i] * 512))
  fi
done
for dir in "${dirs[@]}"; do
  if [ ! -e "${dir}" ] && [ ! -L "${dir}" ]; then removed=$((removed + 1)); fi
done
summary deleted "${deleted}" "${freed}" "${removed}"
left=$((${#files[@]} - deleted + ${#dirs[@]} - removed))
[ "${left}" -eq 0 ] || echo "tools/clean-tmp.sh: ${left} of them are still there"
