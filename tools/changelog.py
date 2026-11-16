#!/usr/bin/env python3
"""The players' changelog, CHANGELOG.md: what each build changed, newest first.

Every push to main that changes more than Markdown (tools/docs-only) is a build
with a number (tools/build-number), which .github/workflows/mac-build.yml
releases on GitHub and itch.io and tags build-<six digits>-<date>-<commit>.
Whoever assembles a release adds an entry to CHANGELOG.md:

    ## Build 2084 (2026-11-16)

    - The park outside Isle House is in.
    - Web: reflections take about 250 MB less graphics memory.

The heading names a build number and the day (UTC) the entry was written. Under
it come 1 to 12 lines, each "- " and one line of plain text for players: at most
300 characters, with no "@" (GitHub would notify an account of that name), no
"<" (HTML or comments), no "&" (HTML entities, such as one for "@"), no "![",
"](" or "]:" (images, links and link definitions; a bare address is fine), and
no control or invisible characters. A build that changes nothing players see says so ("- No
changes to the game."). Entries go newest first, each number smaller than the
one above it; anything before the first entry is the file's own introduction.

The rule: a build N has its entry when the newest entry's number is above the
newest released build before N (the highest build-* tag below N in N's history)
and at most N. The number need not be exact: `next` suggests HEAD's number plus
one, and commits that follow in the same release (a retro, a merge, GitHub's
merge button) keep the entry valid. A history with no build-* tag fails, since
it cannot tell which entries are new (locally: git fetch --tags origin).

A build's release notes start with "Changes in build N:" and the lines of every
entry after the newest released build, up to N (at most 10 entries, newest first;
"No changes to the game." is dropped when other lines come with it), between the
lines "<!-- changelog: build N -->" and "<!-- /changelog -->", which GitHub shows
as nothing.

  tools/changelog.py next     the suggested heading for an entry made on HEAD
  tools/changelog.py check [--hand-run]
                              before pushing a release to main: PASS when HEAD's
                              build has its entry, and shows the notes. When HEAD
                              changes only Markdown since origin/main, the push
                              builds nothing and needs no entry; check still says
                              whether a run started by hand on HEAD would find
                              one, and --hand-run makes that a failure.
  tools/changelog.py latest   the newest entry at or before HEAD's build, as
                              CHANGES lines (tools/deploy-web.sh prints them)
  tools/changelog.py notes --build N --out DIR [--link URL] [--published]
      For the workflow: writes DIR/notes.md (the release notes' start, between
      the two lines above; with URL, a last line links the whole changelog) and
      DIR/CHANGELOG.txt (the same without those two lines, for the downloads).
      Fails unless build N has its entry by the rule. --published is for a build
      already released, from a later commit: it takes the entries after the
      newest released build before N, up to N, and exits 3 when there are none.

Nothing here prints a line of the changelog at the start of an output line, so a
GitHub Actions log never reads one as a workflow command. tools/check_changelog.sh
checks this script.
"""
import argparse
import datetime
import re
import subprocess
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
NAME = "CHANGELOG.md"
HEADING = re.compile(r"## Build ([1-9][0-9]*) \(([0-9]{4}-[0-9]{2}-[0-9]{2})\)")
BULLET = re.compile(r"- (\S.*)")
MAX_LINES = 12
MAX_LENGTH = 300
MAX_ENTRIES = 10
NO_CHANGES = "No changes to the game."
START = "<!-- changelog: build %d -->"
END = "<!-- /changelog -->"
# Control, format (invisible: zero-width, bidirectional overrides), line and
# paragraph separators, private-use and surrogate characters.
HIDDEN = {"Cc", "Cf", "Zl", "Zp", "Co", "Cs"}
RELEASE_TAG = re.compile(r"build-([0-9]{6,})-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9a-f]{7}")


class Bad(Exception):
    pass


def fail(message, status=1):
    print("FAIL: " + message, file=sys.stderr)
    sys.exit(status)


def run(*command, stdin=None):
    return subprocess.run(command, cwd=ROOT, input=stdin, capture_output=True, text=True)


def problem_in(text):
    """Why a line of an entry is not plain text for players, or None."""
    if len(text) > MAX_LENGTH:
        return "it is %d characters long, more than %d" % (len(text), MAX_LENGTH)
    if "@" in text:
        return 'it has an "@", which would notify the GitHub account of that name'
    if "<" in text:
        return 'it has a "<" (no HTML or comments)'
    if "&" in text:
        return 'it has an "&" (no HTML entities, such as one that renders an "@")'
    if "![" in text or "](" in text or "]:" in text:
        return 'it has "![", "](" or "]:" (no images or links; a bare address is fine)'
    for character in text:
        if unicodedata.category(character) in HIDDEN:
            return "it has the invisible or control character U+%04X" % ord(character)
    return None


def parse(text):
    """The entries of CHANGELOG.md's TEXT, newest first: (number, date, lines)."""
    if "\r" in text:
        raise Bad("%s has a carriage return; use plain LF line ends" % NAME)
    entries = []
    for row, line in enumerate(text.split("\n"), 1):
        where = "%s line %d" % (NAME, row)
        if line.startswith("## "):
            match = HEADING.fullmatch(line)
            if not match:
                raise Bad("%s: an entry's heading reads \"## Build <number> (<YYYY-MM-DD>)\", not %r" % (where, line))
            number, day = int(match.group(1)), match.group(2)
            try:
                datetime.date.fromisoformat(day)
            except ValueError:
                raise Bad("%s: %s is not a date" % (where, day))
            if entries and number >= entries[-1][0]:
                raise Bad("%s: build %d comes after build %d; entries go newest first, each number smaller than the one above"
                          % (where, number, entries[-1][0]))
            entries.append((number, day, []))
        elif entries and line.strip():
            match = BULLET.fullmatch(line)
            if not match:
                raise Bad("%s: build %d's entry has %r; each of its lines is \"- \" and one line of text" % (where, entries[-1][0], line))
            why = problem_in(match.group(1))
            if why:
                raise Bad("%s: build %d's line %r is not plain text for players: %s" % (where, entries[-1][0], line, why))
            entries[-1][2].append(match.group(1))
    for number, _, lines in entries:
        if not 1 <= len(lines) <= MAX_LINES:
            raise Bad("build %d's entry has %d lines; an entry has 1 to %d" % (number, len(lines), MAX_LINES))
    return entries


def read_entries():
    try:
        text = (ROOT / NAME).read_bytes().decode("utf-8")
    except FileNotFoundError:
        raise Bad("there is no %s" % NAME)
    except UnicodeDecodeError as error:
        raise Bad("%s is not UTF-8 (%s)" % (NAME, error))
    return parse(text)


def build_number(revision="HEAD"):
    result = run(str(ROOT / "tools" / "build-number"), revision)
    if result.returncode != 0 or not result.stdout.strip().isdigit():
        fail("no build number for %s: %s" % (revision, (result.stderr or result.stdout).strip()))
    return int(result.stdout)


def short(revision="HEAD"):
    return run("git", "rev-parse", "--short=7", revision).stdout.strip() or revision


def next_heading():
    return "## Build %d (%s)" % (build_number() + 1, datetime.datetime.now(datetime.timezone.utc).date().isoformat())


def documentation_only():
    """Why HEAD builds nothing when pushed to origin/main, or None when it builds."""
    if run("git", "rev-parse", "--verify", "--quiet", "origin/main^{commit}").returncode != 0:
        return None
    paths = run("git", "diff", "--name-only", "--no-renames", "origin/main...HEAD")
    if paths.returncode != 0:
        return None
    verdict = run(str(ROOT / "tools" / "docs-only"), stdin=paths.stdout)
    if verdict.returncode == 0:
        return "HEAD changes only Markdown since origin/main"
    if verdict.returncode == 2:
        return "HEAD changes nothing since origin/main"
    return None


def released_before(number):
    """The highest build number below NUMBER with a release tag in HEAD's history.
    Bad when HEAD's history has no release tag below NUMBER at all."""
    tags = run("git", "tag", "--merged", "HEAD", "--list", "build-[0-9]*")
    if tags.returncode != 0:
        raise Bad("git tag failed: %s" % tags.stderr.strip())
    found = [int(m.group(1)) for m in map(RELEASE_TAG.fullmatch, tags.stdout.split()) if m]
    found = [n for n in found if n < number]
    if not found:
        raise Bad("no release tag (build-<six digits>-...) below build %d is in HEAD's history, so which entries are new "
                  "is unknown; fetch the tags first: git fetch --tags origin" % number)
    return max(found)


def unreleased(entries, number):
    """The newest released build before NUMBER, and the entries after it up to NUMBER."""
    released = released_before(number)
    return released, [entry for entry in entries if released < entry[0] <= number]


def missing_entry(entries, number):
    """Why build NUMBER has no entry by the rule, with the fix, or None."""
    released, chosen = unreleased(entries, number)
    if entries and entries[0][0] > number:
        return ("%s's newest entry is build %d's, after build %d. To fix it, renumber that entry to at most %d "
                "(and above %d, the newest released build)" % (NAME, entries[0][0], number, number, released))
    if not chosen:
        newest = "its newest is build %d's" % entries[0][0] if entries else "it has none"
        return ("%s has no entry since build %d, the newest released build: %s. To fix it, add the entry in one more "
                "commit, under a heading such as \"%s\" (tools/changelog.py next); any number above the newest released "
                "build and at most the build's own will do" % (NAME, released, newest, next_heading()))
    return None


def problem_for(entries, number):
    """Why build NUMBER cannot be released with its entry, with the fix, or None."""
    try:
        return missing_entry(entries, number)
    except Bad as error:
        return str(error)


def notes_lines(entries, number, link):
    """The release notes' start for build NUMBER, without the two marker lines."""
    _, chosen = unreleased(entries, number)
    lines = []
    for _, _, texts in chosen[:MAX_ENTRIES]:
        lines += [text for text in texts if text not in lines]
    if len(lines) > 1 and NO_CHANGES in lines:
        lines.remove(NO_CHANGES)
    body = ["Changes in build %d:" % number, ""] + ["- " + text for text in lines]
    if link:
        body += ["", "Every build's changes: %s" % link]
    return body


def write_notes(out, number, lines):
    out.mkdir(parents=True, exist_ok=True)
    (out / "notes.md").write_text("\n".join([START % number] + lines + [END]) + "\n", encoding="utf-8")
    (out / "CHANGELOG.txt").write_text("\n".join(lines) + "\n", encoding="utf-8")


def positive(value):
    if not re.fullmatch(r"[1-9][0-9]*", value):
        raise argparse.ArgumentTypeError("not a build number: %r" % value)
    return int(value)


def main(argv):
    parser = argparse.ArgumentParser(prog="tools/changelog.py", description="The players' changelog, CHANGELOG.md.")
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("next", help="the suggested heading for an entry made on HEAD")
    check = commands.add_parser("check", help="before pushing a release: HEAD's build has its entry")
    check.add_argument("--hand-run", action="store_true",
                       help="also fail a push of Markdown alone whose head a run started by hand would stop on")
    commands.add_parser("latest", help="the newest entry at or before HEAD's build, as CHANGES lines")
    notes = commands.add_parser("notes", help="the workflow: build N's release notes start and CHANGELOG.txt")
    notes.add_argument("--build", type=positive, required=True)
    notes.add_argument("--out", type=Path, required=True)
    notes.add_argument("--link")
    notes.add_argument("--published", action="store_true", help="build N is already released (a re-push)")
    args = parser.parse_args(argv)
    try:
        if args.command == "next":
            print(next_heading())
        elif args.command == "check":
            entries = read_entries()
            number = build_number()
            docs = documentation_only()
            problem = problem_for(entries, number)
            if docs and not args.hand_run:
                print("PASS: %s reads well; %s, so the push builds nothing and needs no entry" % (NAME, docs))
                if problem:
                    print("NOTE: a run started by hand on this head, build %d (%s), would stop: %s "
                          "(tools/changelog.py check --hand-run fails on this)" % (number, short(), problem))
                else:
                    print("NOTE: a run started by hand on this head, build %d (%s), would find its entry" % (number, short()))
                return
            if problem:
                fail("build %d (commit %s): %s" % (number, short(), problem))
            print("PASS: build %d (commit %s) has its entry. Its release notes will start:" % (number, short()))
            for line in notes_lines(entries, number, None):
                print("  | " + line)
        elif args.command == "latest":
            number = build_number()
            entries = [entry for entry in read_entries() if entry[0] <= number]
            if not entries:
                print("CHANGES: none: %s has no entry at or before build %d" % (NAME, number))
                return
            build, day, texts = entries[0]
            print("CHANGES: build %d (%s)%s:" % (build, day, "" if build == number else ", the newest entry at or before build %d" % number))
            for text in texts:
                print("CHANGES:   - " + text)
        else:
            entries = read_entries()
            if args.published:
                if not unreleased(entries, args.build)[1]:
                    print("NONE: %s has no entry for build %d" % (NAME, args.build))
                    sys.exit(3)
            else:
                problem = problem_for(entries, args.build)
                if problem:
                    fail("build %d (commit %s): %s" % (args.build, short(), problem))
            write_notes(args.out, args.build, notes_lines(entries, args.build, args.link))
            print("PASS: build %d's release notes start in %s and its CHANGELOG.txt beside it" % (args.build, args.out / "notes.md"))
    except Bad as error:
        fail(str(error))


if __name__ == "__main__":
    main(sys.argv[1:])
