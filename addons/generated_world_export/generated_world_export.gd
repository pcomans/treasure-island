@tool
extends EditorExportPlugin
## Exported games load the static-world bake, which this plugin adds, and no pack
## carries the bake's inputs: generated/.gdignore keeps the raw world under
## generated/world out of Godot's file list, and export_presets.cfg leaves out the
## shared families' JSON configs.


func _get_name() -> String:
	return "GeneratedWorldExport"


func _export_begin(features: PackedStringArray, _is_debug: bool, _path: String, _flags: int) -> void:
	var baked := ""
	if "web" in features:
		baked = "res://generated/web/static_world.scn"
	elif "prebuilt_native_world" in features:
		baked = "res://generated/native/static_world.scn"
	# An export without the bake has no world to load (it carries no raw world either).
	# push_error only reports that: the export still completes and exits 0. The build
	# scripts bake first, and tools/build-mac.sh's launch check fails a desktop build
	# that loads no world.
	if baked.is_empty() or not FileAccess.file_exists(baked):
		push_error("Missing static world: export through the platform build script")
		return
	add_file(baked, FileAccess.get_file_as_bytes(baked), false)
