extends RefCounted
## The build the pause menu names (owner, 2026-11-16: "Show the build version in
## the pause menu pls"). Every script that makes a build (tools/build-mac.sh, which
## the release workflow runs, tools/build-linux.sh and tools/build-web.sh) gives the
## export its commit's build number (tools/build-number, as the release's tag and
## itch.io's version carry it) and commit, as TI_BUILD_NUMBER and TI_BUILD_COMMIT;
## the export plugin (addons/generated_world_export) writes them into the pack as
## PATH, and the build content audit (game/tests/shared/build_content_audit.gd)
## fails a pack whose stamp is missing or another build's. PATH lies under
## generated/, which Godot's file list leaves out (generated/.gdignore), so only an
## export carries a stamp: a run from source, a test's included, has none.

const PATH := "res://generated/build_stamp.json"


## The stamp at path as {"build": int, "commit": String}, or {} when there is none or
## it does not read as one: a build number of 1 or more, and a commit of 7 to 64
## lowercase hex digits.
static func read(path := PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	# JSON.parse_string would print an engine error for a stamp that doesn't parse.
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK or not json.data is Dictionary:
		return {}
	var build: Variant = (json.data as Dictionary).get("build")
	var commit: Variant = (json.data as Dictionary).get("commit")
	if not build is float or build < 1.0 or build != floorf(build):
		return {}
	if not commit is String or RegEx.create_from_string("^[0-9a-f]{7,64}$").search(commit) == null:
		return {}
	return {"build": int(build), "commit": commit}


## The pause menu's line for a stamp (read) in this run: "Build 2084 (ba5ac01)" in a
## build (exported: OS.has_feature("template")) with its stamp, the commit's first
## seven digits as the release's tag has them; "Build: unknown" in a build without
## one (exported by hand); "Build: source" in a run from source.
static func text(stamp: Dictionary, exported: bool) -> String:
	if not exported:
		return "Build: source"
	if stamp.is_empty():
		return "Build: unknown"
	return "Build %d (%s)" % [stamp.build, str(stamp.commit).left(7)]
