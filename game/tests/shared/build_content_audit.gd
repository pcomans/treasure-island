extends SceneTree
## Checks an exported game data pack (.pck) for material that must not ship:
## reference photos (Street View etc.), research/evidence folders, source assets.
## Run against the pack itself, so res:// is exactly what the build contains:
##
##   tools/godot --headless --main-pack /abs/path/game.pck --script res://game/tests/shared/build_content_audit.gd
##
## tools/build-mac.sh runs this on every Mac build.

## Folders that hold research, references and tooling, never game content.
const FORBIDDEN_FOLDERS := [
	"discovery/", "evidence/", "source_assets/", "data/", "tools/", "build/", ".tools/",
	"third_party_staging/", "node_modules/", "unused-assets/",
]
## Images may only come from the game's own asset folders.
const IMAGE_FOLDERS := ["game/resources/", "generated/", "addons/"]
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
		print("PASS: %d files in the build, no reference or research material" % files.size())
		quit(0)
	else:
		for problem in problems:
			print("FAIL: " + problem)
		quit(1)


func _check(path: String) -> String:
	for folder: String in FORBIDDEN_FOLDERS:
		if path.begins_with(folder):
			return "%s is from %s, which must not ship" % [path, folder]
	# Imported images keep their source path in the .import file name and in
	# the cached .godot/imported/<name>-<hash>.ctex name.
	var source := path.trim_suffix(".import")
	var lower := source.get_file().to_lower()
	for name: String in SUSPICIOUS_NAMES:
		if name in lower:
			return "%s looks like a reference photo" % path
	if source.get_extension().to_lower() in IMAGE_EXTENSIONS and not path.begins_with(".godot/"):
		var allowed := false
		for folder: String in IMAGE_FOLDERS:
			allowed = allowed or source.begins_with(folder)
		if not allowed:
			return "%s is an image outside the game asset folders" % path
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
