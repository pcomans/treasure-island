extends SceneTree
## Checks an exported game data pack (.pck) contains only game files: no
## reference photos (Street View etc.), research, evidence or source assets.
## Run against the pack itself, so res:// is exactly what the build contains:
##
##   tools/godot --headless --main-pack /abs/path/game.pck --script res://game/tests/shared/build_content_audit.gd
##
## tools/build-mac.sh runs this on every build. This script must stay in the
## export (it runs from inside the pack), so don't exclude game/tests/shared/.

## The only top-level entries a build may contain.
const ALLOWED_TOP_LEVEL := ["game", "generated", ".godot", "project.binary"]
## Images may only come from the game's own asset folder.
const IMAGE_FOLDER := "game/resources/"
const IMAGE_EXTENSIONS := ["png", "jpg", "jpeg", "webp", "bmp", "tga", "exr", "hdr", "svg"]
## Names that suggest a reference photo rather than a game texture.
const SUSPICIOUS_NAMES := ["streetview", "street_view", "street-view", "gsv_", "panorama", "reference", "screenshot"]


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
	if problems.is_empty():
		print("PASS: %d files in the build, all game files" % files.size())
		quit(0)
	else:
		for problem in problems:
			print("FAIL: " + problem)
		quit(1)


func _check(path: String) -> String:
	if path.get_slice("/", 0) not in ALLOWED_TOP_LEVEL:
		return "%s is outside game/ and generated/; it must not ship" % path
	# Imported images keep their source path in the .import file name and
	# their file name in the cached .godot/imported/<name>-<hash>.ctex.
	var source := path.trim_suffix(".import")
	for name: String in SUSPICIOUS_NAMES:
		if name in source.get_file().to_lower():
			return "%s looks like a reference photo" % path
	if source.get_extension().to_lower() in IMAGE_EXTENSIONS and not source.begins_with(IMAGE_FOLDER):
		return "%s is an image outside %s" % [path, IMAGE_FOLDER]
	return ""


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
