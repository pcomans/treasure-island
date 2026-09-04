extends SceneTree

const EXPECTED_AUDIO_DRIVER := "Dummy"
const EXPECTED_RUNTIME_MESHES := 940
const EXPECTED_RUNTIME_SURFACES := 954
const EXPECTED_RUNTIME_TRIANGLES := 64118


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
		_fail("The packaged main-scene smoke oracle does not match current accepted Building 1/Building 3/Isle House runtime topology 940/954/64118.")
		return
	print("PASS: project startup selects exact Dummy audio before AudioServer initialization and packaged smoke expects current accepted Building 1/Building 3/Isle House runtime topology 940/954/64118")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
