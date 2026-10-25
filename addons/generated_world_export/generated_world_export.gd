@tool
extends EditorExportPlugin

const GENERATED_WORLD_ROOT := "res://generated/world"


func _get_name() -> String:
	return "GeneratedWorldExport"


func _export_begin(features: PackedStringArray, _is_debug: bool, _path: String, _flags: int) -> void:
	if "web" in features or "prebuilt_native_world" in features:
		var baked := "res://generated/web/static_world.scn" if "web" in features else "res://generated/native/static_world.scn"
		if not FileAccess.file_exists(baked):
			push_error("Missing static world: export through the platform build script")
		else:
			add_file(baked, FileAccess.get_file_as_bytes(baked), false)
	var paths: Array[String] = []
	_collect_files(GENERATED_WORLD_ROOT, paths)
	paths.sort()
	for resource_path: String in paths:
		add_file(resource_path, FileAccess.get_file_as_bytes(resource_path), false)


func _collect_files(directory_path: String, paths: Array[String]) -> void:
	var directory := DirAccess.open(directory_path)
	if directory == null:
		push_error("Generated-world export root is unavailable: %s" % directory_path)
		return
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		if entry != "." and entry != "..":
			var resource_path := directory_path.path_join(entry)
			if directory.current_is_dir():
				_collect_files(resource_path, paths)
			else:
				paths.append(resource_path)
		entry = directory.get_next()
	directory.list_dir_end()
