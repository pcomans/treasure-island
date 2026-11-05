extends SceneTree

const EXPECTED_AUDIO_DRIVER := "Dummy"
const CATALOG_PATH := "res://discovery/facades/facade-recognition-catalog.json"
const DEMOLISHED_PATH := "res://tools/config/demolished-buildings.json"


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
	var demolished_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(DEMOLISHED_PATH))
	if not (demolished_value is Dictionary) or not (demolished_value as Dictionary).get("entries", null) is Array:
		_fail("The demolished-buildings config did not parse.")
		return
	var listed: Dictionary = {}
	for entry: Dictionary in (demolished_value as Dictionary).entries:
		listed[str(entry.get("source_key", ""))] = true
	# Every building has exactly one recognition status: accepted ones carry the
	# reviewer verdict they were accepted on, and demolished ones are exactly the
	# buildings the demolished-buildings config leaves out of the world. The score
	# counts the accepted buildings among those still standing.
	var units := (catalog_value as Dictionary).get("units", []) as Array
	var accepted := 0
	var standing := 0
	for unit: Dictionary in units:
		var status := str((unit.get("claim_status", {}) as Dictionary).get("reference_recognizable", ""))
		var key := str(unit.get("anchor_source_key", ""))
		if (status == "demolished") != listed.has(key):
			_fail("%s: catalog status '%s' disagrees with %s." % [unit.get("unit_id", "?"), status, DEMOLISHED_PATH])
			return
		if status == "demolished":
			if not unit.get("demolition", null) is Dictionary:
				_fail("%s is demolished without its demolition record." % unit.get("unit_id", "?"))
				return
			listed.erase(key)
			continue
		standing += 1
		if status == "accepted":
			accepted += 1
			if (unit.get("acceptance_records", []) as Array).is_empty():
				_fail("%s is accepted without a reviewer verdict." % unit.get("unit_id", "?"))
				return
		elif status != "not_evaluated":
			_fail("%s has unknown recognition status '%s'." % [unit.get("unit_id", "?"), status])
			return
	if not listed.is_empty():
		_fail("Demolished buildings missing from the catalog: %s" % ", ".join(PackedStringArray(listed.keys())))
		return
	if standing == 0:
		_fail("The catalog lists no standing buildings.")
		return
	print("PASS: Dummy audio selected before AudioServer initialization; catalog score %d/%d (%d demolished)" % [accepted, standing, units.size() - standing])
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
