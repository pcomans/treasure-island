extends "res://game/tests/mounted_pck_content_audit.gd"
func _initialize() -> void:
	var expected := "1570eceb96f69b8df1e8ad0df0a627f884a9622ae9a27c293661cc696975427c"
	var path := "res://game/resources/facades/facade-runtime-registry.json"
	var registry: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if FileAccess.get_sha256(path) != expected or not registry is Dictionary:
		_fail("final_registry", "Exact final registry bytes missing or changed")
		return
	var ids: Array = []
	for entry in registry.get("housing_family_acceptance", []):
		ids.append(str(entry.get("unit_id", "")))
	ids.sort()
	if registry.get("recognition_metric", {}).get("display", "") != "43/213" or ids != ["physical-building:w96215668", "physical-building:w96215693", "physical-building:w96215698", "physical-building:w96665893", "physical-building:w96665908", "physical-building:w96665916", "physical-building:w96698619", "physical-building:w96698643", "physical-building:w96698648"]:
		_fail("final_credit", "Final43 exact nine family authority differs")
		return
	print("FINAL_FAMILY_AUTHORITY: registry_sha256=", expected, " metric=43/213 family_entries=9")
	super._initialize()
