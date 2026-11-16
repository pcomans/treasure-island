#!/usr/bin/env python3
"""Fails when the exported web page would fetch a file from outside its own folder.

Players reach the web build at https://grandtreasureisland.vercel.app/game/: the
game's website serves it from that folder. A file named from the site's root
("/x"), from another origin ("//host/x", "https://host/x") or from a parent
folder ("../x"), and a <base> element, all leave /game/ and miss the game's
files, so the page must name every file relative to itself.

  tools/check_web_paths.py [--files] PAGE [FOLDER]

PAGE is the exported index.html, or a copy of a live page. Each reference is
resolved as a browser resolves it for a page at https://site.invalid/game/, and
must stay inside /game/:
  - every attribute the browser loads a file from (src, srcset, a <link>'s href,
    poster and the like), url() in the page's styles and a refresh's target; a
    hyperlink (<a>, <area>) loads nothing, so it may lead anywhere;
  - the files Godot's loader fetches, from GODOT_CONFIG: its executable (the
    loader names the .wasm and the audio worklets after it), the pack, a service
    worker and GDExtension libraries if there are any;
  - string literals in the page's own scripts that look like a path from the
    root or an address, and any use of the page's host (location.origin, .host,
    .hostname). The engine script beside the page names its files from
    GODOT_CONFIG alone;
  - with FOLDER, the web app manifest a <link rel="manifest"> names, read from
    the folder: its start_url and scope (start_url inside scope) and its
    shortcuts' pages, and the images it fetches (icons, screenshots, the
    shortcuts' icons), each resolved against the manifest's own address as a
    browser resolves it; and no id, which a browser resolves against the site's
    root. So the home screen app opens the page's folder at either address.
The page must load a script and name an executable, so a page this cannot read
fails. With FOLDER, every file the page, its manifest and the loader fetch must
be in it. Prints PASS with the files, or FAIL with each reference that leaves the
folder, and exits 1 on any failure. --files prints only the files' names, one a
line.
"""
import json
import re
import sys
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urljoin, urlsplit

BASE = "https://site.invalid/game/"
# The attributes a browser loads a file from. A hyperlink's href (<a>, <area>), a
# form's action and a citation load nothing until someone follows them, so a link
# out of the game is fine and none of them is checked.
URL_ATTRIBUTES = {"src", "href", "poster", "data", "manifest", "background", "codebase", "xlink:href"}
HYPERLINKS = {"a", "area"}
SRCSET_ATTRIBUTES = {"srcset", "imagesrcset"}
# Schemes that name no file on a server.
LOCAL_SCHEMES = {"data", "blob", "about", "javascript", "mailto", "tel"}
CSS_URL = re.compile(r"""url\(\s*(['"]?)(.*?)\1\s*\)|@import\s+(['"])(.*?)\3""", re.I | re.S)
HOST_USE = re.compile(r"\blocation\s*\.\s*(origin|host|hostname)\b")
# A string that looks like a path from the root ("/x"), an address ("//x",
# "https://x") or a parent folder ("../x").
ABSOLUTE_LITERAL = re.compile(r"^\s*(/[^/\s*]|//\S|[a-z][a-z0-9+.-]*://|\.\./)", re.I)
# What may come before a "/" that starts a regular expression rather than a division.
REGEX_AFTER = set("(,=:[!&|?{};+-*%<>~^") | {"", "return", "typeof", "case", "do", "else",
                                            "in", "of", "new", "delete", "void", "throw",
                                            "yield", "await", "instanceof"}


class Page(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.references = []  # (where, value)
        self.scripts = []  # the page's own script text
        self.styles = []
        self.script_sources = 0
        self.bases = 0
        self.manifests = []  # the hrefs of <link rel="manifest">
        self._inline = None

    def handle_starttag(self, tag, attrs):
        if tag == "link" and "manifest" in (dict(attrs).get("rel") or "").lower().split():
            if dict(attrs).get("href") is not None:
                self.manifests.append(dict(attrs)["href"])
        for name, value in attrs:
            if value is None:
                continue
            if name in URL_ATTRIBUTES:
                if tag not in HYPERLINKS:
                    self.references.append(("<%s %s>" % (tag, name), value))
            elif name in SRCSET_ATTRIBUTES:
                for candidate in value.split(","):
                    if candidate.strip():
                        self.references.append(("<%s %s>" % (tag, name), candidate.split()[0]))
            elif name == "style":
                self.styles.append(value)
            elif name == "content" and tag == "meta" and dict(attrs).get("http-equiv", "").lower() == "refresh":
                target = re.search(r"url\s*=\s*['\"]?([^'\"\s;]+)", value, re.I)
                if target:
                    self.references.append(("<meta refresh>", target.group(1)))
        if tag == "base":
            self.bases += 1
        if tag == "script" and dict(attrs).get("src") is not None:
            self.script_sources += 1
        self._inline = [] if tag in ("script", "style") else None

    def handle_endtag(self, tag):
        if self._inline is not None and tag in ("script", "style"):
            (self.scripts if tag == "script" else self.styles).append("".join(self._inline))
        self._inline = None

    def handle_data(self, data):
        if self._inline is not None:
            self._inline.append(data)


def script_strings(code):
    """The string and template literals of a script, without its comments and
    regular expressions."""
    i, n, previous = 0, len(code), ""
    while i < n:
        c = code[i]
        if c.isspace():
            i += 1
        elif code.startswith("//", i):
            end = code.find("\n", i)
            i = n if end < 0 else end
        elif code.startswith("/*", i):
            end = code.find("*/", i + 2)
            i = n if end < 0 else end + 2
        elif c in "'\"`":
            j, value = i + 1, []
            while j < n and code[j] != c and (c == "`" or code[j] != "\n"):
                step = 2 if code[j] == "\\" else 1
                value.append(code[j:j + step])
                j += step
            yield "".join(value)
            i, previous = j + 1, c
        elif c == "/" and previous in REGEX_AFTER:
            j, in_class = i + 1, False
            while j < n and code[j] != "\n" and (in_class or code[j] != "/"):
                in_class = (code[j] == "[") or (in_class and code[j] != "]")
                j += 2 if code[j] == "\\" else 1
            i, previous = j + 1, "/"
            while i < n and code[i].isalnum():
                i += 1
        elif c.isalnum() or c in "_$":
            j = i
            while j < n and (code[j].isalnum() or code[j] in "_$"):
                j += 1
            word = code[i:j]
            i, previous = j, word if word in REGEX_AFTER else "a"
        else:
            i, previous = i + 1, c


def godot_config(scripts):
    """GODOT_CONFIG's object, from the page's own scripts (None if absent)."""
    for code in scripts:
        found = re.search(r"\bGODOT_CONFIG\s*=\s*\{", code)
        if found:
            try:
                return json.JSONDecoder().raw_decode(code, found.end() - 1)[0]
            except ValueError:
                return "unreadable"
    return None


def resolve(value, against=BASE):
    """Where a browser fetches VALUE from when it reads it against AGAINST (the
    page's address, BASE, unless given): (file name, resolved) with the name
    relative to the page's folder; the name is None outside it; nothing for a
    local scheme or a fragment."""
    # Browsers drop tabs and newlines, trim spaces and read "\" as "/" in http(s) URLs.
    value = re.sub(r"[\t\n\r]", "", value).strip().replace("\\", "/")
    if not value or value.startswith("#"):
        return None
    scheme = urlsplit(value).scheme.lower()
    if scheme in LOCAL_SCHEMES:
        return None
    resolved = urljoin(against, value)
    parts = urlsplit(resolved)
    base = urlsplit(BASE)
    if (parts.scheme, parts.netloc) != (base.scheme, base.netloc) or not parts.path.startswith(base.path):
        return (None, resolved)
    return (unquote(parts.path[len(base.path):]), resolved)


def manifest_files(name, address, folder, problems):
    """The files the web app manifest NAME in FOLDER (fetched from ADDRESS) has a
    browser fetch: its icons, screenshots and shortcuts' icons. Every address in
    it must stay in the page's folder: those files, start_url and scope (start_url
    inside scope, or a browser drops the scope) and the shortcuts' pages; and it
    sets no id, which a browser resolves against the site's root, not the
    manifest. Each problem goes in PROBLEMS."""
    where = "the manifest %s" % name
    try:
        manifest = json.loads((folder / name).read_text(encoding="utf-8"))
    except (OSError, ValueError) as error:
        problems.append("%s can't be read as JSON: %s" % (where, error))
        return []
    if not isinstance(manifest, dict):
        problems.append("%s is not a JSON object" % where)
        return []
    shortcuts = manifest.get("shortcuts") if isinstance(manifest.get("shortcuts"), list) else []
    pages = [(member, manifest.get(member)) for member in ("start_url", "scope")]
    pages += [("a shortcut's url", shortcut.get("url")) for shortcut in shortcuts if isinstance(shortcut, dict)]
    images = []
    for member, entries in [("icons", manifest.get("icons")), ("screenshots", manifest.get("screenshots"))] + \
            [("a shortcut's icons", shortcut.get("icons")) for shortcut in shortcuts if isinstance(shortcut, dict)]:
        if entries is not None and not isinstance(entries, list):
            problems.append("%s's %s is %r, not a list" % (where, member, entries))
            continue
        images += [(member, entry) for entry in entries or []]
    resolved = {}
    for member, value in pages:
        if value is None:
            continue
        result = resolve(value, address) if isinstance(value, str) else None
        if not isinstance(value, str):
            problems.append("%s's %s is %r, not an address" % (where, member, value))
        elif result is not None and result[0] is None:
            problems.append("%s's %s is %r, which leads to %s, outside the page's folder" % (where, member, value, result[1]))
        elif result is not None:
            resolved[member] = urlsplit(result[1]).path
    if "start_url" in resolved and "scope" in resolved and not resolved["start_url"].startswith(resolved["scope"]):
        problems.append("%s's start_url %s is outside its scope %s, so a browser ignores the scope"
                        % (where, resolved["start_url"], resolved["scope"]))
    if "id" in manifest:
        problems.append("%s sets id %r, which a browser resolves against the site's root, not the manifest: no id "
                        "names the page's folder at the site's root and under /game/ alike, so leave it out (it is "
                        "start_url then)" % (where, manifest["id"]))
    files = []
    for member, entry in images:
        value = entry.get("src") if isinstance(entry, dict) else None
        if not isinstance(value, str):
            problems.append("%s's %s has an entry without a src: %r" % (where, member, entry))
            continue
        result = resolve(value, address)
        if result is None:
            continue
        if result[0] is None:
            problems.append("%s's %s has %r, which a browser fetches from %s, outside the page's folder" % (where, member, value, result[1]))
        elif result[0] not in files:
            files.append(result[0])
    return files


def main(argv):
    files_only = bool(argv) and argv[0] == "--files"
    args = argv[1:] if files_only else argv
    if len(args) not in (1, 2):
        sys.exit("usage: tools/check_web_paths.py [--files] PAGE [FOLDER]")
    page_path, folder = Path(args[0]), (Path(args[1]) if len(args) == 2 else None)
    page = Page()
    page.feed(page_path.read_text(encoding="utf-8"))
    page.close()
    problems = []
    references = list(page.references)
    for style in page.styles:
        for match in CSS_URL.finditer(style):
            references.append(("a style's url()", match.group(2) if match.group(2) is not None else match.group(4)))
    if page.bases:
        problems.append("the page has a <base> element, which moves where every relative path resolves")
    for code in page.scripts:
        for literal in script_strings(code):
            if ABSOLUTE_LITERAL.match(literal):
                problems.append("a script on the page has the string %r, a path from the site's root or an address" % literal)
        for use in HOST_USE.finditer(code):
            problems.append("a script on the page uses %s, the page's host" % use.group(0))
    config = godot_config(page.scripts)
    if not page.script_sources:
        problems.append("the page loads no script, so it is not a Godot web export this can check")
    if not isinstance(config, dict) or not isinstance(config.get("executable"), str) or not config["executable"]:
        problems.append("the page's GODOT_CONFIG names no executable (%s), so the loader's files are unknown"
                        % ("not found" if config is None else "unreadable" if config == "unreadable" else "no executable"))
    else:
        executable = config["executable"]
        loader = [executable + ".wasm", config.get("mainPack") or executable + ".pck",
                  executable + ".audio.worklet.js", executable + ".audio.position.worklet.js"]
        loader += list(config.get("fileSizes") or {}) + list(config.get("gdextensionLibs") or [])
        if config.get("serviceWorker"):
            loader.append(config["serviceWorker"])
        references += [("GODOT_CONFIG (the loader)", value) for value in loader]
    files = []
    for where, value in references:
        if not isinstance(value, str):
            problems.append("%s has %r, not a file name" % (where, value))
            continue
        result = resolve(value)
        if result is None:
            continue
        name, resolved = result
        if name is None:
            problems.append("%s has %r, which a page at %s fetches from %s, outside its folder" % (where, value, BASE, resolved))
        elif name not in files:
            files.append(name)
    if folder is not None:
        for href in page.manifests:
            result = resolve(href)
            if result is not None and result[0] is not None and (folder / result[0]).is_file():
                files += [name for name in manifest_files(result[0], result[1], folder, problems) if name not in files]
        for name in files:
            if not (folder / name).is_file():
                problems.append("the page or its loader fetches %s, which is not in %s" % (name, folder))
    if problems:
        for problem in problems:
            print("FAIL: %s: %s" % (page_path, problem), file=sys.stderr)
        sys.exit(1)
    if files_only:
        print("\n".join(files))
    else:
        print("PASS: %s fetches every file by a path relative to itself%s: %s"
              % (page_path, " and finds it in %s" % folder if folder is not None else "", ", ".join(files)))


if __name__ == "__main__":
    main(sys.argv[1:])
