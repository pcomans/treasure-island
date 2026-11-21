@tool
extends EditorExportPlugin
## Exported games load the static-world bake, which this plugin adds, and no pack
## carries the bake's inputs: generated/.gdignore keeps the raw world under
## generated/world out of Godot's file list, and export_presets.cfg leaves out the
## shared families' JSON configs. It also stamps every pack with the build the pause
## menu names (_add_build_stamp), and gives web packs a file's web copy in its place
## (_export_file).

const BuildStamp := preload("res://game/scripts/ui/build_stamp.gd")
## A file's web copy sits beside it under its name plus this (a name Godot neither
## imports nor exports): Building 1's weathering map at 0.5 m cells
## (tools/bake_building_1_weathering.gd).
const WEB_COPY_SUFFIX := ".web"


func _get_name() -> String:
	return "GeneratedWorldExport"


func _export_begin(features: PackedStringArray, _is_debug: bool, _path: String, _flags: int) -> void:
	_add_build_stamp()
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


## A web export carries a file that has a web copy beside it (PATH.web) with the copy's
## bytes, under the file's own path, so everything that loads it loads the copy there;
## other exports carry the file itself.
func _export_file(path: String, _type: String, features: PackedStringArray) -> void:
	if not "web" in features:
		return
	var copy := path + WEB_COPY_SUFFIX
	if FileAccess.file_exists(copy):
		skip()
		add_file(path, FileAccess.get_file_as_bytes(copy), false)


## The build stamp (game/scripts/ui/build_stamp.gd): the build number and commit
## the build script gives the export as TI_BUILD_NUMBER and TI_BUILD_COMMIT, at
## BuildStamp.PATH, only when BuildStamp.from_values takes them as they are. An
## export without them (by hand, in the editor), or with ones that don't read
## ("2085-rc", "v2085", an empty commit), carries none: the pause menu then says
## "Build unknown". The export still completes, as without the bake, and the build
## scripts' content audit fails a pack without its stamp.
func _add_build_stamp() -> void:
	var number := OS.get_environment("TI_BUILD_NUMBER")
	var commit := OS.get_environment("TI_BUILD_COMMIT")
	var stamp := BuildStamp.from_values(number, commit)
	if stamp.is_empty():
		push_error("No build stamp: TI_BUILD_NUMBER (\"%s\") and TI_BUILD_COMMIT (\"%s\") are no build number and commit; export through the platform build script" % [number, commit])
		return
	add_file(BuildStamp.PATH, BuildStamp.file_text(stamp).to_utf8_buffer(), false)
