extends SceneTree

const EXPECTED_AUDIO_DRIVER := "Dummy"
const CATALOG_PATH := "res://discovery/facades/facade-recognition-catalog.json"


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
	var catalog_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	if not (catalog_value is Dictionary):
		_fail("The building catalog did not parse.")
		return
	# Every one of the 213 buildings has exactly one recognition status, and the
	# accepted ones carry the reviewer verdict they were accepted on.
	var units := (catalog_value as Dictionary).get("units", []) as Array
	var accepted := 0
	for unit: Dictionary in units:
		var status := str((unit.get("claim_status", {}) as Dictionary).get("reference_recognizable", ""))
		if status == "accepted":
			accepted += 1
			if (unit.get("acceptance_records", []) as Array).is_empty():
				_fail("%s is accepted without a reviewer verdict." % unit.get("unit_id", "?"))
				return
		elif status != "not_evaluated":
			_fail("%s has unknown recognition status '%s'." % [unit.get("unit_id", "?"), status])
			return
	if units.size() != 213:
		_fail("The catalog lists %d buildings, not 213." % units.size())
		return
	print("PASS: Dummy audio selected before AudioServer initialization; catalog score %d/213" % accepted)
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
