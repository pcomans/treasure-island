extends SceneTree

const ACCEPTED_MATERIAL_RUN_TRIALS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const OUTPUT := "res://evidence/first-playable/p3-existing-live-material-revalidation-2026-09-04"
const CAPTURE_SIZE := Vector2i(1440, 900)
const WORLD_SOLID_MASK := 1
const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_BUILDING_WALL := 1 << 1
const SETTLE_START_HEIGHT_M := 3.0
const SETTLE_MAX_PHYSICS_FRAMES := 360
const SETTLE_CLEARANCE_TOLERANCE_M := 0.08
const MIN_ACTUAL_SPRING_LENGTH_M := 4.5
const MIN_CAMERA_HEIGHT_ABOVE_GROUND_M := 1.0
const MIN_TARGET_WIDTH_RATIO := 0.12
const MIN_TARGET_HEIGHT_RATIO := 0.025
const MIN_LIVE_SCOPE_WIDTH_RATIO := 0.04
const MIN_LIVE_SCOPE_HEIGHT_RATIO := 0.03
const TIMEOUT_SECONDS := 240.0
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_WORLD_MESHES := 938
const EXPECTED_WORLD_SURFACES := 948
const EXPECTED_WORLD_TRIANGLES := 63720
const EXPECTED_STATIC_BODIES := 466
const EXPECTED_SUN_ROTATION_DEGREES := Vector3(-52.0, -28.0, 0.0)
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/p3_existing_live_material_revalidation_capture.gd"

# Frozen before capture inspection from the exact P3 packets, canonical run
# maps, and current live material contract. Neither confusion sets nor gates may
# be tuned in response to the rendered images.
const TARGETS := {
	"navy-chapel-187": {
		"canonical_name": "Navy Chapel Building 187",
		"source_key": "w291189336",
		"receiver_key": "building:w291189336:wall",
		"receiver_source_keys": ["w291189336"],
		"bounds_receivers": ["building:w291189336:wall", "building:w291189336:roof"],
		"geometry_sha256": "c62a89b238b4831fa2c16e3244c0bffdf17a80ec09498396bc8e582c5c9e696a",
		"chunk_path": "res://generated/world/chunks/x_-1__z_2.json",
		"chunk_sha256": "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce",
		"reference_packet": "res://discovery/facades/p3_reference_packets/w291189336_navy_chapel_building_187.md",
		"reference_packet_sha256": "7eb592503ce8e276c38ef3ecaf7f2d3dd17e1eeb32adbe45d1059c5cb4693330",
		"run_map": "res://discovery/facades/BATCH_02_RUN_MAPPING.json",
		"run_map_sha256": "d076ee125168cd3dfe499bc56e94c324019d7ba70bb731b9c23c045ca6759b5f",
		"material_path": "res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres",
		"material_sha256": "4020e4c75350929359be9c16686ad80a2a0eac46918cc32746089694017a61a5",
		"accepted_runs": [9, 10],
		"accepted_length_m": 16.362,
		"protected_runs": [0, 1, 2, 3, 4, 5, 6, 7, 8, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33],
		"confusion_set_source_ids": ["w291189918", "w291189926", "w34313521"],
		"confusion_set_note": "Oasis, Dormitory 369, Food Service Building 368, and nearby low California Avenue institutional buildings.",
		"reference_supported_cues": [
			"SSE gable with tall divided multipane window over a shallow projecting entry",
			"square belfry with pyramidal cap and cross",
			"warm cream wall field with partial long-side narrow window groups",
		],
		"recognition_gate": "Independent review must distinguish the whole Chapel from the frozen confusion set using at least two real cues. The live treatment supplies only the warm-cream background on runs 9,10; it cannot itself accept the whole object.",
		"current_limitation": "Warm-cream homogeneous albedo/roughness background only on runs 9,10; substrate, relief, openings, gable modules, belfry/roof geometry, protected faces, and whole-object recognition remain blocked.",
		"massing_conflict": false,
	},
	"dormitory-369": {
		"canonical_name": "Job Corps Dormitory Building 369",
		"source_key": "w291189926",
		"receiver_key": "building:w291189926:wall",
		"receiver_source_keys": ["w291189926"],
		"bounds_receivers": ["building:w291189926:wall", "building:w291189926:roof"],
		"geometry_sha256": "4ad2f9d3c0e109d194965149b6e73c078e7796d19ec3efdfd8f78df6e9aee3e9",
		"chunk_path": "res://generated/world/chunks/x_0__z_1.json",
		"chunk_sha256": "a35f63a877588d198e0e905167968bf9948f4616c16e708a6799d0e6c1bde00a",
		"reference_packet": "res://discovery/facades/p3_reference_packets/w291189926_job_corps_dormitory_369.md",
		"reference_packet_sha256": "a43d391239c2fd3ce66b13c39dc56c534253211e7a44a12d512dbe5367b3a9f9",
		"run_map": "res://discovery/facades/BATCH_04_RUN_MAPPING.json",
		"run_map_sha256": "3ec81316f9bdfb6131df55faeabe822b3fdfb2b739b95bd452a50a1d97a29e42",
		"material_path": "res://game/resources/materials/world/job_corps_dormitory_b369/dormitory_b369_warm_field.tres",
		"material_sha256": "fb50d3989b7aa41421753ad4db5d195366d9a2c25c15087e5e3a2b7863c69602",
		"accepted_runs": [0, 1, 2, 3, 4, 5],
		"accepted_length_m": 49.124,
		"protected_runs": [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71],
		"confusion_set_source_ids": ["w34313514", "w34313521", "w291189918"],
		"confusion_set_note": "Advanced Culinary/Dormitory cohort, Food Service Building 368, Oasis, and other long Job Corps blocks.",
		"reference_supported_cues": [
			"warm off-white long field contrasted with blue-gray end/stair volume and dark green eave",
			"five occupied tiers with alternating broad and narrow windows plus green eyebrows",
			"ground bays mixing glazing, blue-gray panels or doors, and base vents",
		],
		"recognition_gate": "Independent review must distinguish the whole Dormitory from the frozen confusion set using at least two real cues while treating the five-visible-tier versus fallback-6-m conflict as a blocking truth, not hiding or texture-faking it.",
		"current_limitation": "Smooth warm-wall albedo/roughness only on runs 0..5; all 66 protected runs, blue-gray end, windows, eyebrows, eave, vents, modules, and whole-object recognition remain blocked.",
		"massing_conflict": true,
		"massing_conflict_text": "The reference shows five occupied tiers, while the exact current generated receiver remains fallback 6 m. This capture must expose the whole generated entity and may not imply that contradiction is resolved.",
	},
}

# Fixed XZ anchors are ordinary ground approaches selected from generated
# geometry and public-side orientation before inspecting this batch. Both views
# keep the full wall+roof bounds in frame. Dorm whole intentionally centers a
# protected SSE run while the oblique centers accepted WSW run 2, so untreated
# context and the bounded treatment are both exposed rather than hidden.
const VIEWS := [
	{
		"id": "01-navy-chapel-whole-object",
		"target": "navy-chapel-187",
		"role": "whole_object_ordinary_player_view",
		"requested_xz": Vector2(-52.0, 675.0),
		"aim_target": Vector3(-100.468506, 9.019500, 648.694946),
		"expected_receiver": "building:w291189336:wall",
		"expected_source_keys": ["w291189336"],
		"expected_run_index": 9,
		"center_scope": "accepted_warm_field_run_9",
	},
	{
		"id": "02-navy-chapel-oblique",
		"target": "navy-chapel-187",
		"role": "oblique_ordinary_player_view",
		"requested_xz": Vector2(-36.0, 668.0),
		"aim_target": Vector3(-100.468506, 9.019500, 648.694946),
		"expected_receiver": "building:w291189336:wall",
		"expected_source_keys": ["w291189336"],
		"expected_run_index": 9,
		"center_scope": "accepted_warm_field_run_9_with_protected_long_side_context",
	},
	{
		"id": "03-dormitory-369-whole-object",
		"target": "dormitory-369",
		"role": "whole_object_ordinary_player_view",
		"requested_xz": Vector2(-25.0, 620.0),
		"aim_target": Vector3(41.174000, 6.379000, 489.094000),
		"expected_receiver": "building:w291189926:wall",
		"expected_source_keys": ["w291189926"],
		"expected_run_index": 12,
		"center_scope": "protected_placeholder_run_12_full_entity_truth_view",
	},
	{
		"id": "04-dormitory-369-oblique",
		"target": "dormitory-369",
		"role": "oblique_ordinary_player_view",
		"requested_xz": Vector2(-70.0, 600.0),
		"aim_target": Vector3(-4.169500, 6.338500, 464.195500),
		"expected_receiver": "building:w291189926:wall",
		"expected_source_keys": ["w291189926"],
		"expected_run_index": 2,
		"center_scope": "accepted_warm_field_run_2_with_protected_side_context",
	},
]

const PINNED_INPUTS := {
	"res://generated/world/manifest.json": EXPECTED_MANIFEST_SHA256,
	"res://game/scripts/world/world_chunk_builder.gd": "9525ead815e95d7bc0b5fa8beae389954e232a9bbf51b54ed049a84a3613b9c0",
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "d2d4909d5f8cc8a26e7ca77757ceaeebe337131dc33eaece3c7756e2b3d76c9c",
	"res://game/scenes/main.tscn": "959a0f8a14057ea8402790ba374c7839d5f9835ce20ad194846f0a4d45b43d66",
	"res://game/scenes/player/player.tscn": "a37b00ecc620b4f3106a14d1dc9ec22a519f81481e5e6c68252389e13488a793",
	"res://game/scripts/player/player_controller.gd": "8b114132d66c78dd0bfd09783c7b9a3a3a441a8b1ae14f33f7308bd9b04ed0ea",
	"res://game/scripts/player/player_camera.gd": "90ea739b25eb6cbcf8bacff072599b117fe894fcef08683483e41527d8019636",
}

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("P3 exact-current evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	for path: String in PINNED_INPUTS:
		if not _require(FileAccess.get_sha256(path) == str(PINNED_INPUTS[path]), "Pinned capture input drifted: %s." % path):
			_finish(null)
			return
	for target_id: String in TARGETS:
		var target := TARGETS[target_id] as Dictionary
		for pair: Array in [
			[target.chunk_path, target.chunk_sha256],
			[target.reference_packet, target.reference_packet_sha256],
			[target.run_map, target.run_map_sha256],
			[target.material_path, target.material_sha256],
		]:
			if not _require(FileAccess.get_sha256(str(pair[0])) == str(pair[1]), "%s pinned target input drifted: %s." % [target_id, str(pair[0])]):
				_finish(null)
				return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for P3 exact-current evidence."):
		_finish(null)
		return
	var main := packed.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var hud := main.get_node("Interface/HUD") as GameHUD
	var sun := main.get_node("Sun") as DirectionalLight3D
	var ready_reports: Array[Dictionary] = []
	var load_failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready_reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void:
		load_failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()})
	)
	root.add_child(main)
	var wait_started := Time.get_ticks_msec()
	while ready_reports.is_empty() and load_failures.is_empty() and Time.get_ticks_msec() - wait_started < 60000:
		await process_frame
	if not _require(load_failures.is_empty() and ready_reports.size() == 1, "Actual world did not reach one clean ready state for P3 evidence: %s." % str(load_failures)):
		_finish(main)
		return
	var runtime := world.get_runtime_evidence()
	if not _require(str(ready_reports[0].get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content hash drifted before P3 capture.") \
	or not _require(Vector2i(root.get_texture().get_size()) == CAPTURE_SIZE, "P3 capture viewport is not exactly 1440x900.") \
	or not _require(sun.rotation_degrees.is_equal_approx(EXPECTED_SUN_ROTATION_DEGREES), "Default sun rotation drifted before capture.") \
	or not _require(runtime.playable_rows == 735 and runtime.context_rows == 4, "P3 evidence world is not 735 playable + 4 context rows.") \
	or not _require(runtime.mesh_instances == EXPECTED_WORLD_MESHES and runtime.surfaces == EXPECTED_WORLD_SURFACES and runtime.triangles == EXPECTED_WORLD_TRIANGLES, "P3 evidence runtime topology drifted.") \
	or not _require(runtime.static_bodies == EXPECTED_STATIC_BODIES and runtime.shapes == EXPECTED_STATIC_BODIES, "P3 evidence collision totals drifted."):
		_finish(main)
		return
	var bindings := _validate_bindings(world)
	if not _require(bool(bindings.get("ok", false)), str(bindings.get("message", "P3 target binding validation failed."))):
		_finish(main)
		return
	var output_absolute := ProjectSettings.globalize_path(OUTPUT)
	for target_id: String in TARGETS:
		if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images/%s" % target_id)) == OK, "Could not create evidence image directory for %s." % target_id):
			_finish(main)
			return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.show()
	_clean_hud(hud)
	var captures: Array[Dictionary] = []
	for view_value: Variant in VIEWS:
		var view := view_value as Dictionary
		var target := TARGETS[str(view.target)] as Dictionary
		var posed := await _settle_and_aim(world, player, hud, view)
		if not _require(bool(posed.get("ok", false)), str(posed.get("message", "%s pose failed." % str(view.id)))):
			_finish(main)
			return
		var whole_framing := _framing_metadata(player.get_camera(), _nodes_for_keys(world, target.bounds_receivers as Array), "target")
		var receiver_nodes := _record_nodes(world, str(target.receiver_key))
		var live_framing := _run_scope_framing(player.get_camera(), receiver_nodes[0], _load_record(str(target.chunk_path), str(target.receiver_key)), _int_array(target.accepted_runs as Array))
		if not _require(bool(whole_framing.get("ok", false)) and bool(live_framing.get("ok", false)), "%s target/live bounds could not be projected." % str(view.id)) \
		or not _require(_framing_is_technical_valid(whole_framing, live_framing), "%s failed full-entity/live-scope framing: whole=%s live=%s." % [str(view.id), JSON.stringify(whole_framing), JSON.stringify(live_framing)]):
			_finish(main)
			return
		var los := _center_los(player, view, _load_record(str(target.chunk_path), str(target.receiver_key)))
		if not _require(bool(los.get("ok", false)), str(los.get("message", "%s exact first-hit LOS failed." % str(view.id)))):
			_finish(main)
			return
		var metadata := posed.metadata as Dictionary
		metadata.merge(whole_framing.metadata as Dictionary, true)
		metadata.merge(live_framing.metadata as Dictionary, true)
		metadata.merge(los.metadata as Dictionary, true)
		var saved := await _save_view(main, player, hud, sun, view, metadata)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "%s image save failed." % str(view.id)))):
			_finish(main)
			return
		captures.append(saved.metadata as Dictionary)
	if not _require(sun.rotation_degrees.is_equal_approx(EXPECTED_SUN_ROTATION_DEGREES), "Default sun changed during P3 capture."):
		_finish(main)
		return
	var manifest := {
		"schema_version": "ti.p3-existing-live-material-revalidation-evidence/1",
		"review_status": "technical_capture_valid_recognition_and_believability_pending_independent_review",
		"recognition_verdicts": {
			"navy-chapel-187": "pending_independent_whole_object_review",
			"dormitory-369": "pending_independent_whole_object_review_with_unresolved_five_tier_vs_6m_conflict",
		},
		"evidence_role": "No-change exact-current technical evidence. The executor validates current bytes, live run partitions, physics-grounded stock-player provenance, full-entity framing, useful live-scope projection, clean HUD, exact receiver/source/run first-hit LOS, and native image integrity, but makes no recognition or believability judgment.",
		"capture_command": COMMAND,
		"generator": "game/tests/p3_existing_live_material_revalidation_capture.gd",
		"generator_sha256": FileAccess.get_sha256("res://game/tests/p3_existing_live_material_revalidation_capture.gd"),
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"rendering_method": "Forward+",
		"rendering_driver": "Metal",
		"viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"camera_contract": {
			"rig": "actual Player/CameraPivot/SpringArm3D/Camera3D",
			"player_visible": true,
			"fov_degrees": 70.0,
			"configured_spring_length_m": 5.5,
			"minimum_actual_spring_length_m": MIN_ACTUAL_SPRING_LENGTH_M,
			"minimum_camera_height_above_ground_m": MIN_CAMERA_HEIGHT_ABOVE_GROUND_M,
			"orientation": "input-reachable stock PlayerCamera yaw plus clamped SpringArm pitch",
			"detached_camera": false,
			"camera_tricks": false,
			"context_hidden": false,
			"lighting_changed": false,
			"sun_rotation_degrees": _vector3(EXPECTED_SUN_ROTATION_DEGREES),
			"crop_or_postprocess": false,
			"debug_labels_visible": false,
		},
		"generated_world": {
			"content_sha256": EXPECTED_CONTENT_SHA256,
			"manifest_sha256": EXPECTED_MANIFEST_SHA256,
			"playable_rows": runtime.playable_rows,
			"context_rows": runtime.context_rows,
			"meshes": runtime.mesh_instances,
			"surfaces": runtime.surfaces,
			"triangles": runtime.triangles,
			"static_bodies": runtime.static_bodies,
			"shapes": runtime.shapes,
		},
		"pinned_inputs": PINNED_INPUTS,
		"targets": bindings.metadata,
		"frozen_confusion_sets_selected_before_capture_inspection": true,
		"source_photography_shipped": false,
		"capture_count": captures.size(),
		"captures": captures,
		"protected_scope": {
			"visuals_or_materials_changed": false,
			"runtime_or_world_changed": false,
			"generated_files_changed": false,
			"geometry_or_massing_changed": false,
			"collision_navigation_or_spray_changed": false,
			"modules_added": 0,
			"protected_placeholder_runs_remain_visible_in_full_entity_context": true,
		},
		"technical_inspection_scope": [
			"native image decodes at original 1440x900 resolution and is nonblank",
			"actual visible stock player rig physics-settles on generated walkable collision inside the boundary",
			"debug, feedback, loading, and pause panels are absent while the normal reticle remains",
			"viewport-center physics LOS first-hits the exact receiver, source array, and intended accepted or protected run",
			"whole wall-plus-roof bounds and exact accepted-run bounds are fully in frame at useful projected size",
			"default lighting and surrounding world context remain unchanged",
		],
		"recognition_review_prohibited_for_executor": true,
		"dormitory_massing_conflict_unresolved": str((TARGETS["dormitory-369"] as Dictionary).massing_conflict_text),
		"reviewer_instruction": "Open all four native PNGs at original detail. Compare each whole entity only with its cited P3 packet and frozen confusion set. Score cue visibility, protected placeholder faces, ordinary-distance believability, and confusion-set discrimination. Do not infer whole-object acceptance from the technically valid capture or the already accepted bounded material. Dormitory review must treat the five-visible-tier versus fallback-6-m contradiction as unresolved.",
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write P3 exact-current capture manifest.")
		_finish(main)
		return
	print("PASS: captured %d no-change pending-review P3 views on native %s/%s to %s" % [captures.size(), DisplayServer.get_name(), RenderingServer.get_video_adapter_name(), output_absolute])
	_finish(main)


func _validate_bindings(world: WorldLoader) -> Dictionary:
	var result := {}
	for target_id: String in TARGETS:
		var target := TARGETS[target_id] as Dictionary
		var receivers := _record_nodes(world, str(target.receiver_key))
		if receivers.size() != 1:
			return {"ok": false, "message": "%s receiver count is %d rather than one." % [target_id, receivers.size()]}
		var receiver := receivers[0]
		var roofs := _record_nodes(world, str(target.bounds_receivers[1]))
		if roofs.size() != 1 or receiver.get_meta("source_keys", []) != target.receiver_source_keys or roofs[0].get_meta("source_keys", []) != target.receiver_source_keys:
			return {"ok": false, "message": "%s wall/roof source binding drifted." % target_id}
		var record := _load_record(str(target.chunk_path), str(target.receiver_key))
		if record.is_empty():
			return {"ok": false, "message": "%s generated receiver record is missing." % target_id}
		var exact := _exact_live_receiver(receiver, record, target)
		if not bool(exact.get("ok", false)):
			return {"ok": false, "message": "%s: %s" % [target_id, str(exact.get("message", "live receiver mismatch"))]}
		var metadata := target.duplicate(true)
		metadata["runtime_receiver_count"] = receivers.size()
		metadata["runtime_receiver_path"] = str(receiver.get_path())
		metadata["runtime_roof_path"] = str(roofs[0].get_path())
		metadata["live_surface_names"] = [ACCEPTED_MATERIAL_RUN_TRIALS.PLACEHOLDER_SURFACE_NAME, ACCEPTED_MATERIAL_RUN_TRIALS.ACCEPTED_SURFACE_NAME]
		metadata["actual_accepted_runs"] = exact.accepted_runs
		metadata["actual_protected_runs"] = exact.protected_runs
		metadata["render_triangles"] = exact.render_triangles
		metadata["collision_triangles"] = exact.collision_triangles
		metadata["modules"] = 0
		metadata["whole_object_recognition_status"] = "pending_independent_review"
		result[target_id] = metadata
	return {"ok": true, "metadata": result}


func _exact_live_receiver(receiver: Node3D, record: Dictionary, target: Dictionary) -> Dictionary:
	var mesh_instance := receiver.get_node_or_null("Mesh") as MeshInstance3D
	var body := receiver.get_node_or_null("Collision") as StaticBody3D
	var shape_node := receiver.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	if mesh_instance == null or body == null or shape == null or not (mesh_instance.mesh is ArrayMesh):
		return {"ok": false, "message": "wall mesh/collision topology is missing"}
	var mesh := mesh_instance.mesh as ArrayMesh
	if mesh.get_surface_count() != 2 \
	or mesh.surface_get_name(0) != ACCEPTED_MATERIAL_RUN_TRIALS.PLACEHOLDER_SURFACE_NAME \
	or mesh.surface_get_name(1) != ACCEPTED_MATERIAL_RUN_TRIALS.ACCEPTED_SURFACE_NAME:
		return {"ok": false, "message": "two-surface names or count drifted"}
	var placeholder := mesh.surface_get_material(0) as StandardMaterial3D
	var accepted := mesh.surface_get_material(1) as ShaderMaterial
	if placeholder == null or placeholder.resource_name != "building_wall" \
	or accepted == null or accepted.resource_path != str(target.material_path):
		return {"ok": false, "message": "placeholder or accepted material identity drifted"}
	var accepted_runs := _runs_for_surface(mesh, 1)
	var protected_runs := _runs_for_surface(mesh, 0)
	if accepted_runs != _int_array(target.accepted_runs as Array) or protected_runs != _int_array(target.protected_runs as Array):
		return {"ok": false, "message": "accepted/protected run partition drifted: %s / %s" % [str(accepted_runs), str(protected_runs)]}
	var metadata := receiver.get_meta("accepted_material_run_trial", {}) as Dictionary
	var expected_metadata := ACCEPTED_MATERIAL_RUN_TRIALS.metadata_for(str(target.receiver_key)) as Dictionary
	if metadata != expected_metadata \
	or str(metadata.get("source_key", "")) != str(target.source_key) \
	or _int_array(metadata.get("accepted_runs", []) as Array) != accepted_runs \
	or int(metadata.get("modules", -1)) != 0 \
	or not is_equal_approx(float(metadata.get("accepted_length_m", 0.0)), float(target.accepted_length_m)):
		return {"ok": false, "message": "live trial metadata drifted"}
	if absf(_run_length(record, accepted_runs) - float(target.accepted_length_m)) > 0.002:
		return {"ok": false, "message": "accepted run length drifted"}
	var render_triangles := 0
	for surface_index in mesh.get_surface_count():
		render_triangles += int((mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3)
	var collision_triangles := int(shape.get_faces().size() / 3)
	if render_triangles != int((record.indices as Array).size() / 3) or collision_triangles != render_triangles:
		return {"ok": false, "message": "render/collision triangle parity drifted"}
	if mesh_instance.layers != RENDER_BUILDING_WALL \
	or body.collision_layer != (1 | PHYSICS_SPRAY_SURFACE) \
	or body.collision_mask != 0 \
	or not body.is_in_group("spray_receiver_wall") \
	or str(body.get_meta("derived_object_key", "")) != str(target.receiver_key) \
	or body.get_meta("source_keys", []) != target.receiver_source_keys \
	or receiver.find_children("*", "MeshInstance3D", true, false).size() != 1 \
	or receiver.find_children("*", "CollisionObject3D", true, false).size() != 1 \
	or not receiver.find_children("*", "NavigationRegion3D", true, false).is_empty() \
	or not receiver.find_children("*Facade*", "Node", true, false).is_empty():
		return {"ok": false, "message": "render/physics/spray/module ownership drifted"}
	return {
		"ok": true,
		"accepted_runs": accepted_runs,
		"protected_runs": protected_runs,
		"render_triangles": render_triangles,
		"collision_triangles": collision_triangles,
	}


func _settle_and_aim(world: WorldLoader, player: PlayerController, hud: GameHUD, view: Dictionary) -> Dictionary:
	var requested_xz := view.requested_xz as Vector2
	if not world.get_boundary().contains_position(Vector3(requested_xz.x, 0.0, requested_xz.y)):
		return {"ok": false, "message": "%s fixed anchor is outside the playable boundary." % str(view.id)}
	var initial_hit := _ground_hit(player, requested_xz)
	var initial_ground := _ground_metadata(initial_hit)
	if not bool(initial_ground.get("ok", false)):
		return {"ok": false, "message": "%s fixed anchor has no walkable generated support: %s" % [str(view.id), str(initial_ground.get("message", "unknown"))]}
	_clear_gameplay_input()
	player.set_gameplay_enabled(false)
	var ground_y := float(initial_hit.position.y)
	var spawn := Vector3(requested_xz.x, ground_y + SETTLE_START_HEIGHT_M, requested_xz.y)
	player.global_transform = Transform3D(Basis.IDENTITY, spawn)
	player.velocity = Vector3.DOWN * 0.1
	player.force_update_transform()
	var recovery_before := int(world.get_runtime_evidence().recovery_count)
	player.set_gameplay_enabled(true)
	var settled := false
	var settle_frames := 0
	for frame in SETTLE_MAX_PHYSICS_FRAMES:
		paused = false
		_clean_hud(hud)
		await physics_frame
		settle_frames = frame + 1
		if player.is_on_floor() and absf(player.global_position.y - ground_y) <= SETTLE_CLEARANCE_TOLERANCE_M and absf(player.velocity.y) <= 0.05:
			settled = true
			break
	var settled_position := player.global_position
	var recovery_delta := int(world.get_runtime_evidence().recovery_count) - recovery_before
	_clear_gameplay_input()
	player.set_gameplay_enabled(false)
	if not settled:
		return {"ok": false, "message": "%s did not physics-settle within %d frames." % [str(view.id), SETTLE_MAX_PHYSICS_FRAMES]}
	var final_hit := _ground_hit(player, Vector2(settled_position.x, settled_position.z))
	var final_ground := _ground_metadata(final_hit)
	if not bool(final_ground.get("ok", false)):
		return {"ok": false, "message": "%s lost walkable support after settling." % str(view.id)}
	var clearance := settled_position.y - float(final_hit.position.y)
	var drift := Vector2(settled_position.x - requested_xz.x, settled_position.z - requested_xz.y).length()
	if absf(clearance) > SETTLE_CLEARANCE_TOLERANCE_M or drift > 0.05 or recovery_delta != 0:
		return {"ok": false, "message": "%s invalid settle: clearance=%.3f drift=%.3f recovery=%d." % [str(view.id), clearance, drift, recovery_delta]}
	var aimed := _aim_stock_player_camera(player, view.aim_target as Vector3)
	if not bool(aimed.get("ok", false)):
		return {"ok": false, "message": "%s %s" % [str(view.id), str(aimed.get("message", "camera aim failed."))]}
	if not await _wait_for_render(player.get_parent() as GameMain, player, hud):
		return {"ok": false, "message": "%s did not stabilize without overlays." % str(view.id)}
	var camera := player.get_camera()
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	var actual_spring := camera.global_position.distance_to(rig.global_position)
	var camera_height := camera.global_position.y - float(final_hit.position.y)
	if not is_equal_approx(camera.fov, 70.0) or not is_equal_approx(arm.spring_length, 5.5) or actual_spring < MIN_ACTUAL_SPRING_LENGTH_M or camera_height < MIN_CAMERA_HEIGHT_ABOVE_GROUND_M:
		return {"ok": false, "message": "%s stock camera contract failed: fov=%.3f configured=%.3f actual=%.3f height=%.3f." % [str(view.id), camera.fov, arm.spring_length, actual_spring, camera_height]}
	return {
		"ok": true,
		"metadata": {
			"scenario_reset": "fixed_xz_then_real_character_physics_settle",
			"physics_grounded": true,
			"ordinary_player_rig": true,
			"input_reachable_camera_orientation": true,
			"requested_xz": [requested_xz.x, requested_xz.y],
			"settle_spawn_y_m": spawn.y,
			"player_position_m": _vector3(settled_position),
			"ground_y_m": float(final_hit.position.y),
			"ground_clearance_m": clearance,
			"settle_horizontal_drift_m": drift,
			"settle_physics_frames": settle_frames,
			"settle_recovery_delta": recovery_delta,
			"ground_feature": str(final_ground.feature),
			"ground_object": str(final_ground.object_key),
			"ground_sources": final_ground.source_keys,
			"ground_normal_up_dot": float((final_hit.normal as Vector3).dot(Vector3.UP)),
			"in_boundary": world.get_boundary().contains_position(settled_position),
			"aim_target_m": _vector3(view.aim_target as Vector3),
			"center_scope": str(view.center_scope),
			"camera_position_m": _vector3(camera.global_position),
			"camera_height_above_ground_m": camera_height,
			"camera_forward": _vector3(-camera.global_basis.z),
			"camera_fov_degrees": camera.fov,
			"configured_spring_length_m": arm.spring_length,
			"actual_spring_length_m": actual_spring,
			"camera_yaw_degrees": float(aimed.yaw_degrees),
			"camera_pitch_degrees": float(aimed.pitch_degrees),
		},
	}


func _aim_stock_player_camera(player: PlayerController, target: Vector3) -> Dictionary:
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	var delta := target - rig.global_position
	var horizontal := Vector2(delta.x, delta.z).length()
	if horizontal < 0.001:
		return {"ok": false, "message": "target is vertically singular for the stock camera."}
	var yaw := atan2(-delta.x, -delta.z)
	var pitch := atan2(delta.y, horizontal)
	if pitch < deg_to_rad(rig.minimum_pitch_degrees) or pitch > deg_to_rad(rig.maximum_pitch_degrees):
		return {"ok": false, "message": "target pitch %.2f is outside stock PlayerCamera limits." % rad_to_deg(pitch)}
	rig.rotation = Vector3(0.0, yaw, 0.0)
	arm.rotation = Vector3(pitch, 0.0, 0.0)
	rig.force_update_transform()
	arm.force_update_transform()
	return {"ok": true, "yaw_degrees": rad_to_deg(yaw), "pitch_degrees": rad_to_deg(pitch)}


func _center_los(player: PlayerController, view: Dictionary, record: Dictionary) -> Dictionary:
	var camera := player.get_camera()
	var viewport_center := camera.get_viewport().get_visible_rect().size * 0.5
	var projected_target := camera.unproject_position(view.aim_target as Vector3)
	if projected_target.distance_to(viewport_center) > 1.0:
		return {"ok": false, "message": "%s aim target is %.3f px from viewport center." % [str(view.id), projected_target.distance_to(viewport_center)]}
	var origin := camera.project_ray_origin(viewport_center)
	var direction := camera.project_ray_normal(viewport_center).normalized()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 2000.0, WORLD_SOLID_MASK, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return {"ok": false, "message": "%s viewport-center LOS hit nothing." % str(view.id)}
	var collider := hit.get("collider") as CollisionObject3D
	var hit_key := "" if collider == null else str(collider.get_meta("derived_object_key", ""))
	var hit_sources: Array = [] if collider == null else collider.get_meta("source_keys", [])
	var hit_run := _nearest_run_index(record, hit.position as Vector3)
	var hit_target_error := (hit.position as Vector3).distance_to(view.aim_target as Vector3)
	if hit_key != str(view.expected_receiver) or hit_sources != view.expected_source_keys or hit_run != int(view.expected_run_index) or hit_target_error > 0.25:
		return {"ok": false, "message": "%s first LOS hit %s %s run %d error %.3f instead of %s %s run %d." % [str(view.id), hit_key, str(hit_sources), hit_run, hit_target_error, str(view.expected_receiver), str(view.expected_source_keys), int(view.expected_run_index)]}
	return {
		"ok": true,
		"metadata": {
			"viewport_center_px": [viewport_center.x, viewport_center.y],
			"aim_target_screen_px": [projected_target.x, projected_target.y],
			"aim_target_center_error_px": projected_target.distance_to(viewport_center),
			"first_los_hit_receiver": hit_key,
			"first_los_hit_source_keys": hit_sources,
			"first_los_hit_run_index": hit_run,
			"expected_los_run_index": int(view.expected_run_index),
			"first_los_hit_position_m": _vector3(hit.position as Vector3),
			"first_los_hit_normal": _vector3(hit.normal as Vector3),
			"first_los_hit_distance_m": origin.distance_to(hit.position as Vector3),
			"first_los_hit_target_error_m": hit_target_error,
			"first_los_collision_mask": WORLD_SOLID_MASK,
			"receiver_source_run_first_los": true,
		},
	}


func _framing_metadata(camera: Camera3D, record_nodes: Array[Node3D], prefix: String) -> Dictionary:
	var points: Array[Vector3] = []
	for record: Node3D in record_nodes:
		for child_value: Variant in record.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance := child_value as MeshInstance3D
			if mesh_instance == null or mesh_instance.mesh == null or not mesh_instance.is_visible_in_tree():
				continue
			var bounds := mesh_instance.get_aabb()
			for x_index in 2:
				for y_index in 2:
					for z_index in 2:
						var local := bounds.position + Vector3(bounds.size.x * x_index, bounds.size.y * y_index, bounds.size.z * z_index)
						points.append(mesh_instance.global_transform * local)
	return _projected_points(camera, points, prefix)


func _run_scope_framing(camera: Camera3D, receiver: Node3D, record: Dictionary, runs: Array[int]) -> Dictionary:
	var values := record.get("vertices", []) as Array
	var points: Array[Vector3] = []
	for run_index: int in runs:
		var offset := run_index * 12
		for vertex_index in 4:
			var value_offset := offset + vertex_index * 3
			points.append(receiver.global_transform * Vector3(float(values[value_offset]), float(values[value_offset + 1]), float(values[value_offset + 2])))
	return _projected_points(camera, points, "live_scope")


func _projected_points(camera: Camera3D, points: Array[Vector3], prefix: String) -> Dictionary:
	if points.is_empty():
		return {"ok": false}
	var minimum := Vector2(INF, INF)
	var maximum := Vector2(-INF, -INF)
	var behind := 0
	for point: Vector3 in points:
		if camera.is_position_behind(point):
			behind += 1
			continue
		var screen := camera.unproject_position(point)
		minimum = minimum.min(screen)
		maximum = maximum.max(screen)
	if behind == points.size():
		return {"ok": false}
	var size := maximum - minimum
	var metadata := {}
	metadata["%s_bounds_point_count" % prefix] = points.size()
	metadata["%s_bounds_points_behind_camera" % prefix] = behind
	metadata["%s_projected_min_px" % prefix] = [minimum.x, minimum.y]
	metadata["%s_projected_max_px" % prefix] = [maximum.x, maximum.y]
	metadata["%s_projected_width_ratio" % prefix] = size.x / CAPTURE_SIZE.x
	metadata["%s_projected_height_ratio" % prefix] = size.y / CAPTURE_SIZE.y
	metadata["%s_bounds_fully_in_frame" % prefix] = minimum.x >= 0.0 and minimum.y >= 0.0 and maximum.x <= CAPTURE_SIZE.x and maximum.y <= CAPTURE_SIZE.y
	return {"ok": true, "metadata": metadata}


func _framing_is_technical_valid(whole: Dictionary, live: Dictionary) -> bool:
	var target := whole.metadata as Dictionary
	var scope := live.metadata as Dictionary
	return int(target.target_bounds_points_behind_camera) == 0 \
		and bool(target.target_bounds_fully_in_frame) \
		and float(target.target_projected_width_ratio) >= MIN_TARGET_WIDTH_RATIO \
		and float(target.target_projected_height_ratio) >= MIN_TARGET_HEIGHT_RATIO \
		and float(target.target_projected_width_ratio) <= 0.96 \
		and float(target.target_projected_height_ratio) <= 0.96 \
		and int(scope.live_scope_bounds_points_behind_camera) == 0 \
		and bool(scope.live_scope_bounds_fully_in_frame) \
		and float(scope.live_scope_projected_width_ratio) >= MIN_LIVE_SCOPE_WIDTH_RATIO \
		and float(scope.live_scope_projected_height_ratio) >= MIN_LIVE_SCOPE_HEIGHT_RATIO


func _save_view(main: GameMain, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, view: Dictionary, extra: Dictionary) -> Dictionary:
	if not await _wait_for_render(main, player, hud):
		return {"ok": false, "message": "%s did not stabilize for image capture." % str(view.id)}
	var hud_state := _hud_state(hud)
	if bool(hud_state.debug_panel_visible) or bool(hud_state.feedback_panel_visible) or bool(hud_state.load_panel_visible) or bool(hud_state.pause_panel_visible) or not bool(hud_state.reticle_visible):
		return {"ok": false, "message": "%s HUD state is not clean and ordinary: %s" % [str(view.id), JSON.stringify(hud_state)]}
	if not sun.rotation_degrees.is_equal_approx(EXPECTED_SUN_ROTATION_DEGREES):
		return {"ok": false, "message": "%s default lighting changed." % str(view.id)}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE:
		return {"ok": false, "message": "%s returned an empty or wrong-sized native image." % str(view.id)}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.1:
		return {"ok": false, "message": "%s native image appears blank." % str(view.id)}
	var relative := "images/%s/%s.png" % [str(view.target), str(view.id)]
	var path := OUTPUT.path_join(relative)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save its PNG." % str(view.id)}
	var target := TARGETS[str(view.target)] as Dictionary
	var metadata := {
		"id": str(view.id),
		"target": str(view.target),
		"source_identity": str(target.source_key),
		"role": str(view.role),
		"recognition_verdict": "pending_independent_review",
		"believability_verdict": "pending_independent_review",
		"confusion_set_source_ids_frozen_before_capture": target.confusion_set_source_ids,
		"reference_supported_cues_frozen_before_capture": target.reference_supported_cues,
		"file": relative,
		"sha256": FileAccess.get_sha256(path),
		"bytes": FileAccess.get_file_as_bytes(path).size(),
		"dimensions": [image.get_width(), image.get_height()],
		"sample_unique_colors": int(sample.unique_colors),
		"sample_luminance_range": float(sample.luminance_range),
		"hud": hud_state,
		"player_visible": player.visible,
		"debug_labels_visible": false,
		"source_photography_in_frame": false,
		"lighting_changed": false,
		"sun_rotation_degrees": _vector3(sun.rotation_degrees),
		"full_entity_required_and_in_frame": true,
		"protected_untreated_faces_intentionally_not_hidden": true,
	}
	metadata.merge(extra, true)
	print("P3_CURRENT_CAPTURE: id=%s receiver=%s run=%d grounded=%s target=%.3fx%.3f live=%.3fx%.3f image=%s sha256=%s" % [
		str(view.id), str(metadata.first_los_hit_receiver), int(metadata.first_los_hit_run_index), str(metadata.physics_grounded),
		float(metadata.target_projected_width_ratio), float(metadata.target_projected_height_ratio),
		float(metadata.live_scope_projected_width_ratio), float(metadata.live_scope_projected_height_ratio),
		ProjectSettings.globalize_path(path), str(metadata.sha256),
	])
	return {"ok": true, "metadata": metadata}


func _record_nodes(world: WorldLoader, key: String) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for value: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if str(value.get_meta("derived_object_key", "")) == key and value.has_meta("feature_kind"):
			result.append(value as Node3D)
	return result


func _nodes_for_keys(world: WorldLoader, keys: Array) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for key_value: Variant in keys:
		result.append_array(_record_nodes(world, str(key_value)))
	return result


func _load_record(chunk_path: String, receiver_key: String) -> Dictionary:
	var parsed := JSON.parse_string(FileAccess.get_file_as_string(chunk_path)) as Dictionary
	for value: Variant in parsed.get("records", []):
		var record := value as Dictionary
		if str(record.get("object_key", "")) == receiver_key:
			return record
	return {}


func _runs_for_surface(mesh: ArrayMesh, surface_index: int) -> Array[int]:
	var arrays := mesh.surface_get_arrays(surface_index)
	var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
	var counts := {}
	for vertex_index: int in indices:
		var run_index := vertex_index / 4
		counts[run_index] = int(counts.get(run_index, 0)) + 1
	var runs: Array[int] = []
	for run_value: Variant in counts:
		var run_index := int(run_value)
		if int(counts[run_index]) != 6:
			return []
		runs.append(run_index)
	runs.sort()
	return runs


func _run_length(record: Dictionary, runs: Array[int]) -> float:
	var values := record.vertices as Array
	var result := 0.0
	for run_index: int in runs:
		var offset := run_index * 12
		var start := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
		var end := Vector3(float(values[offset + 3]), float(values[offset + 4]), float(values[offset + 5]))
		result += Vector2(start.x, start.z).distance_to(Vector2(end.x, end.z))
	return result


func _nearest_run_index(record: Dictionary, hit: Vector3) -> int:
	var values := record.vertices as Array
	var best_index := -1
	var best_distance := INF
	for run_index in int(record.exterior_foundation_segments):
		var offset := run_index * 12
		var start := Vector2(float(values[offset]), float(values[offset + 2]))
		var end := Vector2(float(values[offset + 3]), float(values[offset + 5]))
		var distance := _point_segment_distance(Vector2(hit.x, hit.z), start, end)
		if distance < best_distance:
			best_distance = distance
			best_index = run_index
	return best_index


func _point_segment_distance(point: Vector2, start: Vector2, end: Vector2) -> float:
	var segment := end - start
	var length_squared := segment.length_squared()
	if length_squared <= 0.0000001:
		return point.distance_to(start)
	var t := clampf((point - start).dot(segment) / length_squared, 0.0, 1.0)
	return point.distance_to(start + segment * t)


func _ground_hit(player: PlayerController, xz: Vector2) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(Vector3(xz.x, 200.0, xz.y), Vector3(xz.x, -20.0, xz.y), WORLD_SOLID_MASK, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return player.get_world_3d().direct_space_state.intersect_ray(query)


func _ground_metadata(hit: Dictionary) -> Dictionary:
	if hit.is_empty():
		return {"ok": false, "message": "ray hit nothing"}
	var collider := hit.get("collider") as Node
	var record := collider.get_parent() if collider != null else null
	var feature := "" if record == null else str(record.get_meta("feature_kind", ""))
	var normal: Vector3 = hit.get("normal", Vector3.ZERO)
	if record == null or feature not in ["land_ground", "road_path"] or normal.dot(Vector3.UP) < 0.7:
		return {"ok": false, "message": "hit %s with up-dot %.3f" % [feature, normal.dot(Vector3.UP)]}
	return {"ok": true, "feature": feature, "object_key": str(record.get_meta("derived_object_key", "")), "source_keys": record.get_meta("source_keys", [])}


func _clean_hud(hud: GameHUD) -> void:
	paused = false
	hud.set_paused(false)
	hud.debug_panel.hide()
	hud.feedback_panel.hide()
	hud.load_panel.hide()
	hud.pause_panel.hide()
	hud.reticle.show()


func _hud_state(hud: GameHUD) -> Dictionary:
	return {
		"debug_panel_visible": hud.debug_panel.visible,
		"feedback_panel_visible": hud.feedback_panel.visible,
		"load_panel_visible": hud.load_panel.visible,
		"pause_panel_visible": hud.pause_panel.visible,
		"reticle_visible": hud.reticle.visible,
	}


func _wait_for_render(main: GameMain, player: PlayerController, hud: GameHUD) -> bool:
	for _index in 2:
		paused = false
		player.set_gameplay_enabled(false)
		_clean_hud(hud)
		await process_frame
		await RenderingServer.frame_post_draw
	return not paused and not bool(_hud_state(hud).debug_panel_visible) and not bool(_hud_state(hud).pause_panel_visible) and main.visible


func _sample_image(image: Image) -> Dictionary:
	var colors := {}
	var minimum := 1.0
	var maximum := 0.0
	for sample_y in 20:
		var y := mini(image.get_height() - 1, int((float(sample_y) + 0.5) * image.get_height() / 20.0))
		for sample_x in 32:
			var x := mini(image.get_width() - 1, int((float(sample_x) + 0.5) * image.get_width() / 32.0))
			var color := image.get_pixel(x, y)
			colors[color.to_rgba32()] = true
			minimum = minf(minimum, color.get_luminance())
			maximum = maxf(maximum, color.get_luminance())
	return {"unique_colors": colors.size(), "luminance_range": maximum - minimum}


func _clear_gameplay_input() -> void:
	for action: StringName in ["move_forward", "move_back", "move_left", "move_right", "run", "jetpack"]:
		if InputMap.has_action(action):
			Input.action_release(action)


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _write_json(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value, "  ", false) + "\n")
	file.close()
	return true


func _vector3(value: Vector3) -> Array[float]:
	return [value.x, value.y, value.z]


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_fail(message)
	return false


func _fail(message: String) -> void:
	if _failure.is_empty():
		_failure = message
	push_error(message)


func _on_timeout() -> void:
	if not _finished:
		_fail("P3 exact-current native evidence timed out after %.0f seconds." % TIMEOUT_SECONDS)
		_finish(null)


func _finish(main: Node) -> void:
	if _finished:
		return
	_finished = true
	if main != null and is_instance_valid(main):
		main.queue_free()
	quit(1 if not _failure.is_empty() else 0)
