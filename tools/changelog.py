#!/usr/bin/env python3
"""The players' changelog, CHANGELOG.md: what each build changed, newest first.

Every push to main that changes more than Markdown (tools/docs-only) is a build
with a number (tools/build-number), which .github/workflows/mac-build.yml
releases on GitHub and itch.io. CHANGELOG.md has an entry for each such build,
written by whoever assembles the release, in the release head's own commit:

    ## Build 2084 (2026-11-16)

    - The park outside Isle House is in.
    - Web: reflections take about 250 MB less graphics memory.

The heading names the build number and the day (UTC) the entry was written.
Under it come 1 to 12 lines, each "- " and one line of plain text for players,
at most 300 characters, with no "@" (GitHub would notify an account of that
name), no "<" and no control or invisible characters. A build that changes
nothing players see says so ("- No changes to the game."). Entries go newest
first, each number smaller than the one above it; anything before the first
entry is the file's own introduction.

A commit's build number is known before the commit is made: for an ordinary
commit it is one more than its parent's. So the entry goes in the release head's
own commit, and no second commit is needed once the number is known.

  tools/changelog.py next     the heading for a commit made on top of HEAD
  tools/changelog.py check    PASS when the newest entry is HEAD's build, or when
                              HEAD changes only Markdown since origin/main (that
                              push builds nothing and needs no entry), and shows
                              what the release notes will start with. Run it
                              before pushing a release to main.
  tools/changelog.py latest   the newest entry at or before HEAD's build, as
                              CHANGES lines (tools/deploy-web.sh prints them)
  tools/changelog.py notes --build N --out DIR [--link URL]
      For the build job: FAIL unless the newest entry is build N. Otherwise writes
      DIR/notes.md, how the release notes start: build N's entry, then those of
      the builds after the newest release tag (build-<six digits>-...) in its
      history, which got no release of their own (at most 10 entries), between the
      lines "<!-- changelog: build N -->" and "<!-- /changelog -->", which GitHub
      shows as nothing; with URL, a last line links the whole changelog.
  tools/changelog.py extract BODY --build N --out FILE
      For the itch job: writes the lines between those two lines in the release
      notes BODY to FILE (CHANGELOG.txt). Exits 3 when BODY has none, as a release
      from before this changelog does.

A missing or wrong entry is fixed in one more commit: `next` prints its heading.
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


def wrong_entry(entries, number):
    """The FAIL message when the newest entry is not build NUMBER's, or None."""
    if entries and entries[0][0] == number:
        return None
    newest = "its newest is build %d's" % entries[0][0] if entries else "it has no entry"
    heading = next_heading()
    return ("%s has no entry for build %d (commit %s): %s. Each build needs its own entry, newest first. "
            "Fix it in one more commit on top of %s, which will be build %s: give this release's entry "
            "(renumbered, or new) the heading \"%s\", as tools/changelog.py next prints it"
            % (NAME, number, short(), newest, short(), HEADING.fullmatch(heading).group(1), heading))


def since_tag(number):
    """The highest build number below NUMBER with a release tag in HEAD's history."""
    tags = run("git", "tag", "--merged", "HEAD", "--list", "build-[0-9]*")
    found = [int(m.group(1)) for m in map(RELEASE_TAG.fullmatch, tags.stdout.split()) if m] if tags.returncode == 0 else []
    found = [n for n in found if n < number]
    return max(found) if found else None


def notes_block(entries, number, link):
    """The lines that start build NUMBER's release notes."""
    since = since_tag(number)
    chosen = [entry for entry in entries if entry[0] <= number and (since is None or entry[0] > since)]
    chosen = chosen[:1] if since is None else chosen[:MAX_ENTRIES]
    lines = [START % number]
    for build, day, texts in chosen:
        lines += ["Changes in build %d (%s):" % (build, day), ""] + ["- " + text for text in texts] + [""]
    if link:
        lines.append("Every build's changes: %s" % link)
    else:
        lines.pop()
    return lines + [END]


def extract(body, number):
    """The lines between build NUMBER's markers in release notes BODY, or None."""
    lines = body.splitlines()
    if START % number not in lines:
        return None
    start = lines.index(START % number)
    if END not in lines[start:]:
        raise Bad("build %d's changelog in the release notes has no end line %r" % (number, END))
    inner = lines[start + 1:lines.index(END, start)]
    if not any(line.strip() for line in inner) or sum(len(line) + 1 for line in inner) > 100000:
        raise Bad("build %d's changelog in the release notes is empty or too long" % number)
    for line in inner:
        if any(unicodedata.category(c) in HIDDEN for c in line):
            raise Bad("build %d's changelog in the release notes has an invisible or control character" % number)
    return inner


def positive(value):
    if not re.fullmatch(r"[1-9][0-9]*", value):
        raise argparse.ArgumentTypeError("not a build number: %r" % value)
    return int(value)


def main(argv):
    parser = argparse.ArgumentParser(prog="tools/changelog.py", description="The players' changelog, CHANGELOG.md.")
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("next", help="the heading for a commit made on top of HEAD")
    commands.add_parser("check", help="before pushing a release: the newest entry is HEAD's build")
    commands.add_parser("latest", help="the newest entry at or before HEAD's build, as CHANGES lines")
    notes = commands.add_parser("notes", help="the build job: build N's entry, as the release notes start")
    notes.add_argument("--build", type=positive, required=True)
    notes.add_argument("--out", type=Path, required=True)
    notes.add_argument("--link")
    pull = commands.add_parser("extract", help="the itch job: build N's changelog from its release notes")
    pull.add_argument("body", type=Path)
    pull.add_argument("--build", type=positive, required=True)
    pull.add_argument("--out", type=Path, required=True)
    args = parser.parse_args(argv)
    try:
        if args.command == "next":
            print(next_heading())
        elif args.command == "check":
            entries = read_entries()
            docs = documentation_only()
            if docs:
                print("PASS: %s reads well; %s, so the push builds nothing and needs no entry" % (NAME, docs))
                return
            number = build_number()
            message = wrong_entry(entries, number)
            if message:
                fail(message)
            print("PASS: %s's newest entry is build %d's, this commit's (%s). Its release notes will start:" % (NAME, number, short()))
            for line in notes_block(entries, number, None)[1:-1]:
                print("  | " + line)
        elif args.command == "latest":
            number = build_number()
            entries = [entry for entry in read_entries() if entry[0] <= number]
            if not entries:
                fail("%s has no entry at or before build %d" % (NAME, number))
            build, day, texts = entries[0]
            print("CHANGES: build %d (%s)%s:" % (build, day, "" if build == number else ", the newest entry at or before build %d" % number))
            for text in texts:
                print("CHANGES:   - " + text)
        elif args.command == "notes":
            entries = read_entries()
            message = wrong_entry(entries, args.build)
            if message:
                fail(message)
            block = notes_block(entries, args.build, args.link)
            args.out.mkdir(parents=True, exist_ok=True)
            (args.out / "notes.md").write_text("\n".join(block) + "\n", encoding="utf-8")
            builds = re.findall(r"^Changes in build ([0-9]+)", "\n".join(block), re.M)
            print("PASS: %s has build %d's entry; %s holds how the release notes start, with the entries of builds %s"
                  % (NAME, args.build, args.out / "notes.md", ", ".join(builds)))
        else:
            try:
                text = args.body.read_bytes().decode("utf-8")
            except UnicodeDecodeError:
                raise Bad("the release notes %s are not UTF-8" % args.body)
            inner = extract(text, args.build)
            if inner is None:
                print("NONE: the release notes have no changelog for build %d (a release from before CHANGELOG.md)" % args.build)
                sys.exit(3)
            args.out.write_text("\n".join(inner) + "\n", encoding="utf-8")
            print("PASS: wrote build %d's changelog from its release notes to %s (%d lines)" % (args.build, args.out, len(inner)))
    except Bad as error:
        fail(str(error))


if __name__ == "__main__":
    main(sys.argv[1:])
