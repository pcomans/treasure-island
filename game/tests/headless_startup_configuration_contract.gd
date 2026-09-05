extends SceneTree

const EXPECTED_AUDIO_DRIVER := "Dummy"
const RUNTIME_REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const EXPECTED_RUNTIME_SCHEMA := "ti.facade-runtime-registry/8"
const EXPECTED_RECOGNITION_NUMERATOR := 8
const EXPECTED_RECOGNITION_DENOMINATOR := 213
const EXPECTED_RUNTIME_MESHES := 952
const EXPECTED_RUNTIME_SURFACES := 967
const EXPECTED_RUNTIME_TRIANGLES := 67716


func _initialize() -> void:
	var project_config := ConfigFile.new()
	var load_error := project_config.load("res://project.godot")
	if load_error != OK:
		_fail("Could not load project.godot: %s" % error_string(load_error))
		return
	if not project_config.has_section_key("audio", "driver/driver") \
	or str(project_config.get_value("audio", "driver/driver", "")) != EXPECTED_AUDIO_DRIVER:
		_fail("project.godot must select the exact case-sensitive Dummy audio driver before AudioServer initialization.")
		return
	if str(ProjectSettings.get_setting("audio/driver/driver", "")) != EXPECTED_AUDIO_DRIVER:
		_fail("Godot did not load audio/driver/driver as the exact case-sensitive Dummy value.")
		return
	if AudioServer.get_driver_name() != EXPECTED_AUDIO_DRIVER:
		_fail("The focused startup process did not initialize the Dummy audio driver.")
		return
	if GameMain.EXPECTED_MESHES != EXPECTED_RUNTIME_MESHES \
	or GameMain.EXPECTED_SURFACES != EXPECTED_RUNTIME_SURFACES \
	or GameMain.EXPECTED_TRIANGLES != EXPECTED_RUNTIME_TRIANGLES:
		_fail("The packaged main-scene smoke oracle does not match current B225-integrated runtime topology 952/967/67716.")
		return
	var registry_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUNTIME_REGISTRY_PATH))
	if not (registry_value is Dictionary):
		_fail("The packaged facade runtime registry did not parse.")
		return
	var registry := registry_value as Dictionary
	var metric := registry.get("recognition_metric", {}) as Dictionary
	var accepted_ids := metric.get("accepted_physical_unit_ids", []) as Array
	if str(registry.get("schema_version", "")) != EXPECTED_RUNTIME_SCHEMA \
	or int(metric.get("numerator", -1)) != EXPECTED_RECOGNITION_NUMERATOR \
	or int(metric.get("denominator", -1)) != EXPECTED_RECOGNITION_DENOMINATOR \
	or str(metric.get("display", "")) != "%d/%d" % [EXPECTED_RECOGNITION_NUMERATOR, EXPECTED_RECOGNITION_DENOMINATOR] \
	or accepted_ids.size() != EXPECTED_RECOGNITION_NUMERATOR:
		_fail("The packaged facade authority is not exact runtime-registry v8 at 8/213.")
		return
	print("PASS: project startup selects exact Dummy audio before AudioServer initialization, packaged smoke expects current B225-integrated topology 952/967/67716, and packaged facade authority is exact runtime-registry v8 at 8/213")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
