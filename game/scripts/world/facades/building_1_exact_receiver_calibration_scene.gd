extends Node3D

const HELPER := preload("res://game/tests/support/building_1_exact_receiver_calibration.gd")
const REGISTRY_PATH := "res://game/resources/facades/building_1_exact_receiver_calibration.json"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const RECEIVER_KEY := "building:r16681702:wall"


func _ready() -> void:
	if get_node_or_null("DetachedBuilding1ExactReceiverCalibration") == null:
		_build_detached()


func _build_detached() -> void:
	var registry_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	var chunk_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH))
	if not registry_value is Dictionary or not chunk_value is Dictionary:
		push_error("Building 1 detached calibration could not parse registry or generated chunk.")
		return
	var record := {}
	for record_value: Variant in (chunk_value as Dictionary).get("records", []):
		var candidate := record_value as Dictionary
		if str(candidate.get("object_key", "")) == RECEIVER_KEY:
			record = candidate
			break
	var result := HELPER.build(record, registry_value as Dictionary)
	if not bool(result.get("ok", false)):
		push_error(str(result.get("message", "Building 1 detached calibration build failed.")))
		return
	add_child(result.node as Node3D)
	set_meta("resolved_field_scope", result.resolved_field_scope)
	set_meta("resolved_fit_studies", result.resolved_fit_studies)
