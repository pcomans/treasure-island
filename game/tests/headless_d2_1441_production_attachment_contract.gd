extends "res://game/tests/headless_d2_1441_chinook_live_replacement_contract.gd"

## Fresh production-evidence bridge for the uncredited 1441 Chinook attachment.
## The inherited live contract proves pair construction, deterministic ownership,
## collision, materials, ordinary-main integration, and exact current topology.
## This bridge additionally proves that the downstream evidence harness observes
## that already-integrated world without loading or invoking its construction seam.

const D2_PRODUCTION_CAPTURE_PATH := "res://game/tests/d2_1441_production_attachment_capture.gd"
const D2_PRODUCTION_CAPTURE := preload(D2_PRODUCTION_CAPTURE_PATH)
const D2_PRODUCTION_PACKAGE_PATH := "res://game/tests/headless_d2_1441_production_attachment_package_contract.gd"
const D2_LIVE_CONFIG_PATH := "res://game/resources/facades/d2_1441_chinook_live_replacement.json"
const D2_MAIN_SCRIPT_PATH := "res://game/scripts/main.gd"
const D2_BUILDER_SCRIPT_PATH := "res://game/scripts/world/world_chunk_builder.gd"


func _finish() -> void:
	_require(_production_evidence_source_contract(), "Fresh D2 production capture/package source contract is absent, ambiguous, or construction-capable.")
	_require(_receipt_geometry_mutation_contract(), "D2 production receipt target binding does not accept exact authority and reject a geometry-signature mutation.")
	_require(_visual_motion_timing_mutation_contract(), "D2 visual motion timing payload does not require fixed-fps 60 plus post-draw in-memory staging and deferred encoding.")
	if _failures.is_empty():
		print("PASS: fresh D2 production evidence observes ordinary main already integrated at 735/959/974/69252/466/466 under unchanged v8 8/213 authority; capture has no factory/adapter/standalone activation or player/camera transform write route and grants no credit")
	super._finish()


func _production_evidence_source_contract() -> bool:
	if not FileAccess.file_exists(D2_PRODUCTION_CAPTURE_PATH) \
	or not FileAccess.file_exists(D2_PRODUCTION_PACKAGE_PATH) \
	or not ResourceLoader.exists(D2_PRODUCTION_CAPTURE_PATH) \
	or not ResourceLoader.exists(D2_PRODUCTION_PACKAGE_PATH):
		push_error("D2_PRODUCTION_SOURCE_DIAGNOSTIC: file/resource existence failed %s/%s/%s/%s" % [FileAccess.file_exists(D2_PRODUCTION_CAPTURE_PATH), FileAccess.file_exists(D2_PRODUCTION_PACKAGE_PATH), ResourceLoader.exists(D2_PRODUCTION_CAPTURE_PATH), ResourceLoader.exists(D2_PRODUCTION_PACKAGE_PATH)])
		return false
	var capture := FileAccess.get_file_as_string(D2_PRODUCTION_CAPTURE_PATH)
	var package := FileAccess.get_file_as_string(D2_PRODUCTION_PACKAGE_PATH)
	var config := _json(D2_LIVE_CONFIG_PATH)
	var truth := config.get("truth_boundary", {}) as Dictionary
	var live_pair := config.get("live_pair_contract", {}) as Dictionary
	var combined := live_pair.get("combined", {}) as Dictionary
	var wall := live_pair.get("wall", {}) as Dictionary
	var roof := live_pair.get("roof", {}) as Dictionary
	var relief := live_pair.get("decorative_relief", {}) as Dictionary
	if not bool(truth.get("runtime_attachment", false)) \
	or not bool(truth.get("candidate_is_uncredited", false)) \
	or bool(truth.get("catalog_or_registry_promoted", true)) \
	or bool(truth.get("recognition_accepted", true)) \
	or bool(truth.get("believability_accepted", true)) \
	or str(truth.get("accepted_authority_schema", "")) != "ti.facade-runtime-registry/8" \
	or str(truth.get("accepted_recognition_metric", "")) != "8/213" \
	or int(combined.get("mesh_instances", -1)) != 9 or int(combined.get("surfaces", -1)) != 9 \
	or int(combined.get("visual_triangles", -1)) != 1578 or int(combined.get("static_bodies", -1)) != 2 \
	or int(combined.get("shapes", -1)) != 2 or int(combined.get("collision_triangles", -1)) != 42 \
	or int(wall.get("mesh_instances", -1)) != 8 or int(wall.get("surfaces", -1)) != 8 \
	or int(wall.get("visual_triangles", -1)) != 1568 or int(wall.get("collision_triangles", -1)) != 32 \
	or int(roof.get("mesh_instances", -1)) != 1 or int(roof.get("surfaces", -1)) != 1 \
	or int(roof.get("visual_triangles", -1)) != 10 or int(roof.get("collision_triangles", -1)) != 10 \
	or not bool(roof.get("spray_ray_blocking", false)) or not bool(roof.get("truthful_world_solid_landing", false)) \
	or int(relief.get("visual_triangles", -1)) != 1536 or int(relief.get("collision_triangles", -1)) != 0:
		push_error("D2_PRODUCTION_SOURCE_DIAGNOSTIC: live config truth/topology failed truth=%s live_pair=%s" % [truth, live_pair])
		return false
	for marker: String in [
		'const D2_PRODUCTION_WORLD := {"rows": 735, "meshes": 959, "surfaces": 974, "triangles": 69252, "bodies": 466, "shapes": 466}',
		'const D2_CAPTURE_TIME_METRIC := "8/213"',
		'const D2_MAPPED_RUNS: Array[int] = [10, 12, 13, 15]',
		'const D2_PROTECTED_RUNS: Array[int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 14]',
		'const D2_CONFUSION_SOURCES := ["w95934144", "w95934143", "w95934131", "w95934129"]',
		'const D2_MOTION_TELEMETRY_FRAMES := 360',
		'const D2_MOTION_BRAKING_FRAMES := 12',
		'const D2_VISUAL_TRIGGER_TOLERANCE_M := 0.22',
		'_d2_visual_fixed_fps_receipt_matches()',
		'pending_frames.append(staged)',
		'_d2_write_motion_frames(output_root, pending_frames)',
		'Input.parse_input_event(event)',
		'Input.action_press("jetpack")',
		'Input.action_press(D2_MOTION_INPUT_ACTION)',
		'ordinary_main_already_integrated',
		'"recognition_credit": false',
		'"additional_recognition_credit": false',
		'"promotion": false',
		'"player_transform_writes": 0',
		'"camera_transform_writes": 0',
		'"tag_render_visible": true',
		'"tag_cyan_pixels": cyan_pixels',
		'"tag_yellow_pixels": yellow_pixels',
	]:
		if marker not in capture:
			push_error("D2_PRODUCTION_SOURCE_DIAGNOSTIC: missing capture marker %s" % marker)
			return false
	for forbidden: String in [
		'preload("res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd")',
		'preload("res://game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd")',
		"d2_1441_chinook_standalone_hero_prototype.tscn",
		"build_for_records(",
		"prepare_chunk_records(",
		"build_chunk_plan(",
		"consume_record(",
		"_settle_and_aim(",
		"_aim_stock_camera(",
		"apply_look_delta(",
		"player.global_transform =",
		"player.global_position =",
		"camera.global_transform =",
		"camera.global_position =",
		"rig.rotation =",
		"arm.rotation =",
	]:
		if forbidden in capture:
			push_error("D2_PRODUCTION_SOURCE_DIAGNOSTIC: forbidden capture token %s" % forbidden)
			return false
	for marker: String in [
		"--mounted-d2-1441-production-pck=",
		"--mounted-d2-1441-production-pck-sha256=",
		'FileAccess.file_exists("res://project.binary")',
		'not FileAccess.file_exists("res://project.godot")',
		D2_PRODUCTION_CAPTURE_PATH,
		D2_PRODUCTION_PACKAGE_PATH,
		"recognition_credit=false",
		"promotion=false",
	]:
		if marker not in package:
			push_error("D2_PRODUCTION_SOURCE_DIAGNOSTIC: missing package marker %s" % marker)
			return false
	var main_source := FileAccess.get_file_as_string(D2_MAIN_SCRIPT_PATH)
	var builder_source := FileAccess.get_file_as_string(D2_BUILDER_SCRIPT_PATH)
	var final_matches := main_source.count('world_root.call_deferred("load_world")') == 1 \
		and builder_source.count('preload("res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd")') == 1 \
		and builder_source.count("D2_1441_CHINOOK_LIVE_REPLACEMENT.consume_record(record, d2_1441_plan)") == 1
	if not final_matches:
		push_error("D2_PRODUCTION_SOURCE_DIAGNOSTIC: main/builder route counts=%d/%d/%d" % [main_source.count('world_root.call_deferred("load_world")'), builder_source.count('preload("res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd")'), builder_source.count("D2_1441_CHINOOK_LIVE_REPLACEMENT.consume_record(record, d2_1441_plan)")])
	return final_matches


func _receipt_geometry_mutation_contract() -> bool:
	var target := {
		"canonical_name": "1441 Chinook Court",
		"source_key": "w95934105",
		"wall_object_key": "building:w95934105:wall",
		"roof_object_key": "building:w95934105:roof",
		"physical_unit_id": "physical-building:w95934105",
		"mapped_public_sse_runs": [10, 12, 13, 15],
		"protected_runs": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 14],
		"confusion_set": ["w95934144", "w95934143", "w95934131", "w95934129"],
		"geometry_signature": ADAPTER.EXPECTED_GEOMETRY_SIGNATURE,
		"live_ownership_signature": ADAPTER.EXPECTED_LIVE_OWNERSHIP_SIGNATURE,
		"wall_canonical_hash": ADAPTER.CANONICAL_WALL_RECORD_SHA256,
		"roof_canonical_hash": ADAPTER.CANONICAL_ROOF_RECORD_SHA256,
	}
	var encoded := JSON.stringify({"d2_target": target})
	var round_trip: Variant = JSON.parse_string(encoded)
	if not round_trip is Dictionary:
		return false
	var exact_receipt := round_trip as Dictionary
	if not D2_PRODUCTION_CAPTURE.d2_receipt_target_payload_matches(
		exact_receipt,
		ADAPTER.EXPECTED_GEOMETRY_SIGNATURE,
		ADAPTER.EXPECTED_LIVE_OWNERSHIP_SIGNATURE,
	):
		return false
	var mutated_receipt := exact_receipt.duplicate(true)
	(mutated_receipt.d2_target as Dictionary).geometry_signature = "b91b373edbb41d5bf8ec67517b2150a519022a25466f66d9b6ca609834689195"
	return not D2_PRODUCTION_CAPTURE.d2_receipt_target_payload_matches(
		mutated_receipt,
		ADAPTER.EXPECTED_GEOMETRY_SIGNATURE,
		ADAPTER.EXPECTED_LIVE_OWNERSHIP_SIGNATURE,
	)


func _visual_motion_timing_mutation_contract() -> bool:
	var payload := {
		"visual_fixed_fps_operator_request": 60,
		"fixed_fps_receipt_argument": "60",
		"fixed_fps_receipt_is_operator_invocation_disclosure_not_engine_observation": true,
		"all_images_copied_in_memory_before_next_physics_await": true,
		"png_encoding_deferred_until_after_input_release_and_braking": true,
		"png_encoding_or_file_write_during_live_input_loop": false,
	}
	var round_trip: Variant = JSON.parse_string(JSON.stringify(payload))
	if not round_trip is Dictionary or not D2_PRODUCTION_CAPTURE.d2_visual_motion_payload_matches(round_trip as Dictionary):
		return false
	for mutation in [
		{"fixed_fps_receipt_argument": ""},
		{"fixed_fps_receipt_argument": "61"},
		{"visual_fixed_fps_operator_request": 60.5},
		{"all_images_copied_in_memory_before_next_physics_await": false},
		{"png_encoding_deferred_until_after_input_release_and_braking": false},
		{"png_encoding_or_file_write_during_live_input_loop": true},
	]:
		var mutated := (round_trip as Dictionary).duplicate(true)
		mutated.merge(mutation as Dictionary, true)
		if D2_PRODUCTION_CAPTURE.d2_visual_motion_payload_matches(mutated):
			return false
	return true
