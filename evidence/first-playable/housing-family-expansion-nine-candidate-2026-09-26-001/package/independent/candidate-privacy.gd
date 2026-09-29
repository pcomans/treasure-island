extends "res://game/tests/mounted_pck_content_audit.gd"
# Narrow candidate-authority precondition, followed by the unchanged full audit.
func _initialize() -> void:
	var expected := "ea19f54c0f8b215b797d1cd61359fa1998eb574f97dc56bb4484ed195a0a3258"
	var path := "res://game/resources/facades/facade-runtime-registry.json"
	var actual := FileAccess.get_sha256(path)
	var registry: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if expected.length() != 64 or actual != expected or not registry is Dictionary:
		_fail("candidate_registry", "Exact candidate registry bytes missing or changed")
		return
	if registry.get("recognition_metric", {}).get("display", "") != "34/213" or registry.get("housing_family_acceptance", null) != []:
		_fail("candidate_credit", "Candidate does not retain genuine34/213 empty family authority")
		return
	print("CANDIDATE_FAMILY_AUTHORITY: registry_sha256=", actual, " metric=34/213 family_entries=0")
	super._initialize()
