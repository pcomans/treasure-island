extends SceneTree
## Checks an exported game data pack (.pck) contains only game files: no
## reference photos (Street View etc.), research, evidence or source assets; and
## that it carries the stamp of the build that made it, which the pause menu shows
## (game/scripts/ui/build_stamp.gd): the build number and commit its build script
## gave the export, given here the same way. Run against the pack itself, so
## res:// is exactly what the build contains:
##
##   TI_BUILD_NUMBER=<tools/build-number> TI_BUILD_COMMIT=<commit> tools/godot --headless --main-pack /abs/path/game.pck --script res://game/tests/shared/build_content_audit.gd [-- --beside /abs/path/export/folder]
##
## tools/build-mac.sh, tools/build-linux.sh and tools/build-web.sh run this on
## every build. This script must stay in the export (it runs from inside the
## pack), so don't exclude game/tests/shared/.
##
## One narrow exception (owner, 2026-11-17): Sentry's official Godot add-on, pinned to
## release SENTRY_ADDON_RELEASE, which the desktop builds use for their crash reports.
## A pack may hold exactly SENTRY_ADDON_PACK_FILES under addons/ and nothing else there
## (addon_problem); with --beside, the folder a Linux or Windows build was exported to
## must hold exactly its executable and pack and the add-on's files for that platform,
## SENTRY_ADDON_BESIDE (beside_problem). Nothing else under addons/ may ship.

const BuildStamp := preload("res://game/scripts/ui/build_stamp.gd")
## The only top-level entries a build may contain.
const ALLOWED_TOP_LEVEL := ["game", "generated", ".godot", "project.binary"]
## Images may only come from the game's own asset folder.
const IMAGE_FOLDER := "game/resources/"
const IMAGE_EXTENSIONS := ["png", "jpg", "jpeg", "webp", "bmp", "tga", "exr", "hdr", "svg"]
## Names that suggest a reference photo rather than a game texture.
const SUSPICIOUS_NAMES := ["streetview", "street_view", "street-view", "gsv_", "panorama", "reference", "screenshot"]
## Sentry's Godot add-on, as release 2.5.1 ships it (addons/sentry, INSTALL_LOG.md): the
## files of it a pack may hold (its extension's manifest and its licence), and what an
## export puts beside the executable on Linux and Windows (its release library and
## Crashpad's handler; on a Mac the app's Contents/Frameworks gets its two dylibs). A new
## release of the add-on changes this list with it.
const SENTRY_ADDON_RELEASE := "2.5.1"
const SENTRY_ADDON_PACK_FILES: Array[String] = ["addons/sentry/sentry.gdextension", "addons/sentry/LICENSE.md"]
const SENTRY_ADDON_BESIDE := {
	"linux": ["treasure-island.x86_64", "treasure-island.pck", "libsentry.linux.release.x86_64.so", "crashpad_handler"],
	"windows": ["treasure-island.exe", "treasure-island.pck", "libsentry.windows.release.x86_64.dll", "crashpad_handler.exe", "crashpad_wer.dll"],
}


func _initialize() -> void:
	if FileAccess.file_exists("res://project.godot") or not FileAccess.file_exists("res://project.binary"):
		push_error("FAIL: run this with --main-pack <exported .pck>, not on the source project")
		quit(1)
		return
	var problems: Array[String] = []
	var files := _list("res://")
	for path in files:
		var problem := _check(path.trim_prefix("res://"))
		if problem != "":
			problems.append(problem)
	var stamp := BuildStamp.read()
	var wrong_stamp := stamp_problem(stamp, OS.get_environment("TI_BUILD_NUMBER"), OS.get_environment("TI_BUILD_COMMIT"))
	if wrong_stamp != "":
		problems.append(wrong_stamp)
	var arguments := OS.get_cmdline_user_args()
	var beside := ""
	if arguments.size() == 2 and arguments[0] == "--beside":
		beside = beside_problem(_folder_files(arguments[1]))
	elif not arguments.is_empty():
		beside = "unknown arguments %s: the only one is --beside <the folder the build was exported to>" % [arguments]
	if beside != "":
		problems.append(beside)
	if problems.is_empty():
		print("PASS: %d files in the build, all game files; stamped build %d, commit %s, as its pause menu says: \"%s\"" % [files.size(), stamp.build, stamp.commit, BuildStamp.text(stamp, true)])
		quit(0)
	else:
		for problem in problems:
			print("FAIL: " + problem)
		quit(1)


func _check(path: String) -> String:
	if path.begins_with("addons/"):
		return addon_problem(path)
	if path.get_slice("/", 0) not in ALLOWED_TOP_LEVEL:
		return "%s is outside game/ and generated/; it must not ship" % path
	# Imported images keep their source path in the .import file name and
	# their file name in the cached .godot/imported/<name>-<hash>.ctex.
	var source := path.trim_suffix(".import")
	for name: String in SUSPICIOUS_NAMES:
		if name in source.get_file().to_lower():
			return "%s looks like a reference photo" % path
	var is_image := source.get_extension().to_lower() in IMAGE_EXTENSIONS or has_image_bytes(path)
	if is_image and not source.begins_with(IMAGE_FOLDER) and not path.begins_with(".godot/"):
		return "%s is an image outside %s" % [path, IMAGE_FOLDER]
	return ""


## Why a pack's build stamp (as BuildStamp.read gives it) is not the stamp of the
## build its script made, whose number (tools/build-number) and commit it gave the
## export and this check as TI_BUILD_NUMBER and TI_BUILD_COMMIT, read by the
## export's own rule (BuildStamp.from_values); "" when it is.
static func stamp_problem(stamp: Dictionary, number: String, commit: String) -> String:
	var expected := BuildStamp.from_values(number, commit)
	if expected.is_empty():
		return "TI_BUILD_NUMBER (\"%s\") and TI_BUILD_COMMIT (\"%s\") must give this build's number and commit: its build script sets them, for the export that stamps the pack and for this check" % [number, commit]
	if stamp.is_empty():
		return "%s is missing or unreadable: the export plugin (addons/generated_world_export) stamps each export with TI_BUILD_NUMBER and TI_BUILD_COMMIT" % BuildStamp.PATH
	if stamp != expected:
		return "%s names build %d, commit %s, not this build's %d, commit %s" % [BuildStamp.PATH, stamp.build, stamp.commit, expected.build, expected.commit]
	return ""


## Why a file under addons/ must not ship, or "" for one of the pinned Sentry add-on's
## files a pack may hold (SENTRY_ADDON_PACK_FILES).
static func addon_problem(path: String) -> String:
	if path in SENTRY_ADDON_PACK_FILES:
		return ""
	return "%s is under addons/ and is not one of the files of Sentry's add-on (release %s) a build may carry: %s" % [path, SENTRY_ADDON_RELEASE, ", ".join(SENTRY_ADDON_PACK_FILES)]


## Why the files in a Linux or Windows build's export folder (names, any order) are not
## exactly its executable, its pack and the pinned Sentry add-on's files for that
## platform (SENTRY_ADDON_BESIDE), or "".
static func beside_problem(files: PackedStringArray) -> String:
	var platform := "linux" if files.has("treasure-island.x86_64") else ("windows" if files.has("treasure-island.exe") else "")
	if platform.is_empty():
		return "the export folder holds neither treasure-island.x86_64 nor treasure-island.exe: %s" % ", ".join(files)
	var expected: Array = SENTRY_ADDON_BESIDE[platform].duplicate()
	expected.sort()
	var found := Array(files)
	found.sort()
	if found != expected:
		return "the %s export folder must hold exactly %s (the game and Sentry's add-on, release %s), but holds %s" % [platform, ", ".join(expected), SENTRY_ADDON_RELEASE, ", ".join(found)]
	return ""


## The names of the files and folders directly in a folder outside the pack.
static func _folder_files(path: String) -> PackedStringArray:
	var names := PackedStringArray()
	var dir := DirAccess.open(path)
	if dir == null:
		return names
	dir.include_hidden = true
	names.append_array(dir.get_files())
	names.append_array(dir.get_directories())
	return names


## True when the file starts like a PNG, JPEG, WebP, GIF or BMP, whatever its name.
static func has_image_bytes(path: String) -> bool:
	var file := FileAccess.open("res://" + path, FileAccess.READ)
	if file == null or file.get_length() < 12:
		return false
	var head := file.get_buffer(12)
	return (head[0] == 0x89 and head[1] == 0x50 and head[2] == 0x4E and head[3] == 0x47) \
		or (head[0] == 0xFF and head[1] == 0xD8 and head[2] == 0xFF) \
		or (head.slice(0, 4).get_string_from_ascii() == "RIFF" and head.slice(8, 12).get_string_from_ascii() == "WEBP") \
		or head.slice(0, 4).get_string_from_ascii() == "GIF8" \
		or (head[0] == 0x42 and head[1] == 0x4D)


func _list(dir_path: String) -> Array[String]:
	var found: Array[String] = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return found
	dir.include_hidden = true
	for file in dir.get_files():
		found.append(dir_path.path_join(file))
	for sub in dir.get_directories():
		found.append_array(_list(dir_path.path_join(sub)))
	return found
