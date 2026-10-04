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
	var is_image := source.get_extension().to_lower() in IMAGE_EXTENSIONS or _has_image_bytes(path)
	if is_image and not source.begins_with(IMAGE_FOLDER) and not path.begins_with(".godot/"):
		return "%s is an image outside %s" % [path, IMAGE_FOLDER]
	return ""


## True when the file starts like a PNG, JPEG, WebP, GIF or BMP, whatever its name.
func _has_image_bytes(path: String) -> bool:
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
