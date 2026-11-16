@tool
extends RefCounted
## The build the pause menu names (owner, 2026-11-16: "Show the build version in
## the pause menu pls"). Every script that makes a build (tools/build-mac.sh, which
## the release workflow runs, tools/build-linux.sh and tools/build-web.sh) gives the
## export its commit's build number (tools/build-number, as the release's tag and
## itch.io's version carry it) and commit, as TI_BUILD_NUMBER and TI_BUILD_COMMIT;
## the export plugin (addons/generated_world_export, which runs this script in the
## editor, hence @tool) writes them into the pack as PATH when from_values takes
## them, and the build content audit (game/tests/shared/build_content_audit.gd)
## fails a pack whose stamp is missing or another build's. PATH lies under
## generated/, which Godot's file list leaves out (generated/.gdignore), so only an
## export carries a stamp: a run from source, a test's included, has none.

const PATH := "res://generated/build_stamp.json"
## A build number: plain digits from 1 to 999,999,999, with no sign, space or
## leading zero. Nine digits at most keep a hand-edited value far inside an int
## (main's history counts four).
const BUILD_PATTERN := "^[1-9][0-9]{0,8}$"
## A commit: 7 to 64 lowercase hex digits.
const COMMIT_PATTERN := "^[0-9a-f]{7,64}$"


## The one rule for a stamp: a build number and commit as text, as the build script
## gives them (TI_BUILD_NUMBER, TI_BUILD_COMMIT) and the stamp file holds them, as
## {"build": int, "commit": String}; {} unless each matches its pattern whole, so
## "2085-rc", "v2085", "+2085", "" or a commit in capitals give {}.
static func from_values(number: String, commit: String) -> Dictionary:
	if not _whole(BUILD_PATTERN, number) or not _whole(COMMIT_PATTERN, commit):
		return {}
	return {"build": number.to_int(), "commit": commit}


## The stamp file's text for a stamp (from_values): both fields as text, as read
## takes them back.
static func file_text(stamp: Dictionary) -> String:
	return JSON.stringify({"build": str(stamp.build), "commit": stamp.commit})


## The stamp at path, through from_values; {} when there is none or it does not read
## as one.
static func read(path := PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	# JSON.parse_string would print an engine error for a stamp that doesn't parse.
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK or not json.data is Dictionary:
		return {}
	var number: Variant = (json.data as Dictionary).get("build")
	var commit: Variant = (json.data as Dictionary).get("commit")
	if not number is String or not commit is String:
		return {}
	return from_values(number, commit)


## The pause menu's line for a stamp (read) in this run: "Build 2084 (ba5ac01)" in a
## build (exported: OS.has_feature("template")) with its stamp, the commit's first
## seven digits as the release's tag has them; "Build unknown" in a build without
## one (exported by hand); "Build source" in a run from source.
static func text(stamp: Dictionary, exported: bool) -> String:
	if not exported:
		return "Build source"
	if stamp.is_empty():
		return "Build unknown"
	return "Build %d (%s)" % [stamp.build, str(stamp.commit).left(7)]


## Whether pattern matches all of value: a pattern's $ also matches before a final
## line break, which would let "2085\n" through.
static func _whole(pattern: String, value: String) -> bool:
	var found := RegEx.create_from_string(pattern).search(value)
	return found != null and found.get_string() == value
