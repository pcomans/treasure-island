#!/usr/bin/env bash
# Deletes what in /tmp has gone unused for DAYS days (default 7). In this
# devcontainer /tmp is a plain directory on the container's disk, not a tmpfs,
# and nothing else ages it out (PID 1 is a shell, not systemd), so it only grows.
# Every container start runs it (postStartCommand in .devcontainer/devcontainer.json).
#
#   tools/clean-tmp.sh             # delete what has gone unused for 7 days
#   tools/clean-tmp.sh 3           # ... for 3 days (1 to 3650)
#   tools/clean-tmp.sh --dry-run   # list what would be deleted; delete nothing
#
# Unused, as systemd-tmpfiles judges it: a file not modified, read or changed for
# DAYS days; a directory that gained or lost no entries in that time. Old files go
# first, then the old directories that leaves empty. A single find pass deletes:
# it checks each entry's age as it reaches it, stays on the /tmp filesystem,
# never follows symlinks and deletes relative to the directory it has open, so a
# directory swapped for a symlink meanwhile can't lead it out of /tmp. Only
# regular files and directories go: sockets, symlinks and the like take no space,
# and their age says nothing about whether they are still in use. It never touches
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
usage() {
  echo "usage: tools/clean-tmp.sh [--dry-run] [DAYS]   (DAYS from 1 to 3650, default 7)" >&2
  exit 2
}
for arg in "$@"; do
  case "${arg}" in
    --dry-run) dry_run=true ;;
    [0-9]|[0-9][0-9]|[0-9][0-9][0-9]|[0-9][0-9][0-9][0-9]) days=$((10#${arg})) ;;
    *) usage ;;
  esac
done
# 0 days would put the cutoff at now and delete everything that isn't open. Four
# digits and the 3650 cap keep the arithmetic far from overflowing.
{ [ "${days}" -ge 1 ] && [ "${days}" -le 3650 ]; } || usage
# The container is rootless: root's lsof can't see the user's open files.
if [ "$(id -u)" -eq 0 ]; then
  echo "tools/clean-tmp.sh: run it as the devcontainer user, not root; root's lsof can't see that user's open files" >&2
  exit 1
fi
now="$(date +%s)"
cutoff=$((now - days * 86400))

# Inode numbers of what a process has open, mapped or as its working directory.
declare -A in_use=()
if command -v lsof >/dev/null && listing="$(timeout 60 lsof -nP -w -F n 2>/dev/null)"; then
  open_paths=()
  while IFS= read -r line; do
    case "${line}" in "n${root}/"*) open_paths+=("${line#n}") ;; esac
  done <<< "${listing}"
  if [ ${#open_paths[@]} -gt 0 ]; then
    while IFS= read -r inode; do
      in_use["${inode}"]=1
    done < <(stat -c %i -- "${open_paths[@]}" 2>/dev/null || true)
  fi
else
  # DAYS is at least 1, so what was used in the last day stays in any case.
  echo "NOTE: tools/clean-tmp.sh: without lsof it can't tell which files are open; only their age protects them"
fi

# The top-level entries to go through: those on /tmp's own filesystem (not
# mount points), without the skipped names.
device="$(find "${root}" -maxdepth 0 -printf '%D')"
tops=()
while IFS= read -r -d '' record; do
  [ "${record%% *}" = "${device}" ] || continue
  name="${record#* }"
  case "${name}" in
    claude-*|.*-unix|.X*-lock|wayland-*|weston*|xdg-*|ti-browser-*|systemd-private-*|devpod.activity) ;;
    *) tops+=("${root}/${name}") ;;
  esac
done < <(find "${root}" -mindepth 1 -maxdepth 1 -printf '%D %f\0' 2>/dev/null)
# find -files0-from reads them from stdin, however many there are.
find_tops() {
  [ ${#tops[@]} -eq 0 ] || printf '%s\0' "${tops[@]}" | find -files0-from - -xdev "$@" 2>/dev/null
}

# Old, as find sees the entry when it reaches it. Listing a directory updates
# its atime, so for directories only entry changes count.
old=(\( -type f ! -newermt "@${cutoff}" ! -newerat "@${cutoff}" ! -newerct "@${cutoff}"
  -o -type d ! -newermt "@${cutoff}" ! -newerct "@${cutoff}" \))
in_use_test=(-false)
for inode in "${!in_use[@]}"; do in_use_test+=(-o -inum "${inode}"); done

skipped_open=0 skipped_denied=0
summary() { # verb, files, bytes, directories
  printf 'tools/clean-tmp.sh: %s %d files (%s) and %d directories unused for %d days; skipped %d in use, %d without permission\n' \
    "$1" "$2" "$(numfmt --to=iec-i --suffix=B "$3")" "$4" "${days}" "${skipped_open}" "${skipped_denied}"
}

if [ "${dry_run}" = true ]; then
  # Every entry, parents before children, as "type 512-byte-blocks inode old path".
  kinds=() blocks=() inodes=() olds=() paths=()
  while IFS= read -r -d '' record; do
    kinds+=("${record%% *}"); record="${record#* }"
    blocks+=("${record%% *}"); record="${record#* }"
    inodes+=("${record%% *}"); record="${record#* }"
    olds+=("${record%% *}"); paths+=("${record#* }")
  done < <(find_tops -printf '%y %b %i ' \( "${old[@]}" -printf '1 ' -o -printf '0 ' \) -printf '%p\0')
  # What the find pass below will do, children before parents: an old directory
  # that keeps an entry or can't be read stays, what is open stays, and the rest
  # goes if this user may delete it (write access to the parent and, in a sticky
  # directory such as /tmp itself, owning the entry or the parent).
  declare -A keeps=()  # directories that keep at least one entry
  plan=() files=0 dirs=0 planned=0
  for ((i = ${#paths[@]} - 1; i >= 0; i--)); do
    path="${paths[i]}"
    parent="${path%/*}"
    if [ "${olds[i]}" = 1 ] && [ -z "${keeps[${path}]:-}" ] \
      && { [ "${kinds[i]}" != d ] || { [ -r "${path}" ] && [ -x "${path}" ]; }; }; then
      if [ -n "${in_use[${inodes[i]}]:-}" ]; then
        skipped_open=$((skipped_open + 1))
      elif { [ -w "${parent}" ] && [ -x "${parent}" ]; } \
        && { [ ! -k "${parent}" ] || [ -O "${path}" ] || [ -O "${parent}" ]; }; then
        if [ "${kinds[i]}" = f ]; then
          plan+=("${path}"); files=$((files + 1)); planned=$((planned + blocks[i] * 512))
        else
          plan+=("${path}/"); dirs=$((dirs + 1))
        fi
        continue
      else
        skipped_denied=$((skipped_denied + 1))
      fi
    fi
    keeps["${parent}"]=1
  done
  for ((i = ${#plan[@]} - 1; i >= 0; i--)); do printf '%s\n' "${plan[i]}"; done
  summary "would delete" "${files}" "${planned}" "${dirs}"
  exit 0
fi

# Children before parents (-depth). find judges a directory's age by the times it
# had before its contents went, and deletes each entry from the directory it has
# open, so nothing is reached through a symlink.
deleted=0 freed=0 removed=0
while IFS= read -r -d '' record; do
  case "${record}" in
    u) skipped_open=$((skipped_open + 1)) ;;
    x) skipped_denied=$((skipped_denied + 1)) ;;
    d) removed=$((removed + 1)) ;;
    f*) deleted=$((deleted + 1)); freed=$((freed + ${record#f} * 512)) ;;
  esac
done < <(find_tops -depth "${old[@]}" \( \( -type d ! -empty \) -o \( "${in_use_test[@]}" \) -printf 'u\0' \
  -o -delete \( -type f -printf 'f%b\0' -o -printf 'd\0' \) -o -printf 'x\0' \))
summary deleted "${deleted}" "${freed}" "${removed}"
