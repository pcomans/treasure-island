extends SceneTree

const PROTOTYPE := preload("res://game/scripts/world/facades/d2_1439_chinook_standalone_hero_prototype.gd")
const OUTPUT := "res://evidence/first-playable/d2-1439-chinook-standalone-hero-2026-09-04"
const PROTOTYPE_SCENE_PATH := "res://game/scenes/world/facades/site_12_housing/d2_1439_chinook_standalone_hero_prototype.tscn"
const CONFIG_PATH := "res://game/resources/facades/d2_1439_chinook_standalone_hero_prototype.json"
const CHUNK_PATH := "res://generated/world/chunks/x_-2__z_0.json"
const PACKET_PATH := "res://discovery/facades/d2_reference_packets/w95934144_1439_chinook_court.md"
const WALL_KEY := "building:w95934144:wall"
const ROOF_KEY := "building:w95934144:roof"
const SOURCE_KEY := "w95934144"
const MAPPED_RUNS := [11, 12, 16, 17, 18, 19, 22, 23]
const MOTIF_HOST_RUNS := [11, 19, 23]
const MAPPED_MOTIF_FREE_RUNS := [12, 16, 17, 18, 22]
const TINY_FRAGMENT_RUNS := [17, 18]
const PROTECTED_RUNS := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 15, 20, 21]
const EXPECTED_CHUNK_SHA256 := "3e7d1cb020d4a8f8a2852121a181a1e2d441fee40de42d744d37fbbcba59168b"
const EXPECTED_PACKET_SHA256 := "050ceb6195bf1f7a4b1c753cde5a509c30b0911599af9233db5746605b9cfeb6"
const STILL_SIZE := Vector2i(1440, 900)
const MOTION_SIZE := Vector2i(1280, 800)
const WORLD_SOLID_MASK := 1
const SETTLE_START_HEIGHT_M := 3.0
const SETTLE_MAX_PHYSICS_FRAMES := 360
const SETTLE_CLEARANCE_TOLERANCE_M := 0.08
const MIN_ACTUAL_SPRING_LENGTH_M := 4.2
const TIMEOUT_SECONDS := 300.0
const DEFAULT_SUN := Vector3(-52.0, -28.0, 0.0)
const CHANGED_SUN := Vector3(-26.0, 126.0, 0.0)
const MOTION_PHYSICS_FRAMES := 240
const MOTION_PHYSICS_HZ := 60
const MOTION_FIXED_FPS := 30
const MOTION_FILE := "d2-1439-chinook-sse-stock-walk.avi"
const TARGET_POINT := Vector3(-292.060, 6.15, 2.018)
const PUBLIC_TANGENT := Vector3(-0.891, 0.0, 0.454)
const PUBLIC_OUTWARD := Vector3(-0.454, 0.0, -0.891)
const CONFUSION_SET := ["w95934113", "w95934105", "w95934131"]
const CONFUSION_SET_NAMED := [
	{"name": "1437 Chinook Court", "source_key": "w95934113", "evidence_state": "appearance_lifecycle_blocked"},
	{"name": "1441 Chinook Court", "source_key": "w95934105", "evidence_state": "independently_reviewed_standalone_comparator"},
	{"name": "1438 Chinook Court", "source_key": "w95934131", "evidence_state": "appearance_blocked"},
]
const IMPLEMENTED_COMPARATORS := ["w95934105", "w95934117"]
const FROZEN_SUPPORTED_CUES := [
	"one strongly recessed two-level balcony stack near one end of the exact SSE chain",
	"a broad quiet central upper register with separated dark rectangular opening groups and no inferred lower schedule",
	"a near-blank opposite upper end over one offset deep passage, held together by a shallow dark gable and continuous SSE eaves",
]
const VIEWS := [
	{
		"id": "01-whole-sse",
		"role": "whole_object_grounded_public_sse_view",
		"requested_xz": Vector2(-311.1, -35.4),
		"aim_target": TARGET_POINT,
		"expected_run_index": 19,
		"sun": DEFAULT_SUN,
	},
	{
		"id": "02-sse-oblique",
		"role": "grounded_public_sse_oblique_approach",
		"requested_xz": Vector2(-297.0, -35.7),
		"aim_target": TARGET_POINT,
		"expected_run_index": 19,
		"sun": DEFAULT_SUN,
	},
	{
		"id": "03-sse-oblique-changed-light",
		"role": "same_grounded_public_sse_oblique_under_materially_changed_light",
		"requested_xz": Vector2(-297.0, -35.7),
		"aim_target": TARGET_POINT,
		"expected_run_index": 19,
		"sun": CHANGED_SUN,
	},
]

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	var mode := _argument_value("--capture-mode=")
	if mode == "finalize-motion":
		_finalize_motion_manifest()
		_finish(null)
		return
	if mode not in ["stills", "motion"]:
		_fail("Pass exactly --capture-mode=stills, motion, or finalize-motion.")
		_finish(null)
		return
	if DisplayServer.get_name() == "headless":
		_fail("1439 Chinook evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	if not _require(FileAccess.get_sha256(CHUNK_PATH) == EXPECTED_CHUNK_SHA256, "Frozen source chunk drifted before capture.") \
	or not _require(FileAccess.get_sha256(PACKET_PATH) == EXPECTED_PACKET_SHA256, "Authoritative 1439 packet drifted before capture."):
		_finish(null)
		return
	var chunk := _json(CHUNK_PATH)
	var wall_record := _record_for_key(chunk.get("records", []) as Array, WALL_KEY)
	var roof_record := _record_for_key(chunk.get("records", []) as Array, ROOF_KEY)
	if not _require(PROTOTYPE.matches_record_pair(wall_record, roof_record), "Exact 1439 wall+roof pair failed the standalone seam."):
		_finish(null)
		return
	var fixture_result := await _load_capture_fixture(wall_record, roof_record)
	if not _require(bool(fixture_result.get("ok", false)), str(fixture_result.get("message", "Isolated capture fixture failed."))):
		_finish(fixture_result.get("fixture", null) as Node)
		return
	var fixture := fixture_result.fixture as Node3D
	var player := fixture_result.player as PlayerController
	var hud := fixture_result.hud as GameHUD
	var sun := fixture_result.sun as DirectionalLight3D
	var binding := fixture_result.binding as Dictionary
	var observed_size := Vector2i(root.get_texture().get_size())
	var size_ok := observed_size == STILL_SIZE if mode == "stills" else (
		observed_size.x >= 960 and observed_size.y >= 600
		and absf(float(observed_size.x) / float(observed_size.y) - 1.6) <= 0.005
	)
	if not _require(size_ok, "%s render viewport %s violates its native capture-size contract." % [mode, observed_size]):
		_finish(fixture)
		return
	var output_absolute := ProjectSettings.globalize_path(OUTPUT)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images")) == OK, "Could not create 1439 evidence directory."):
		_finish(fixture)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.show()
	_clean_hud(hud)
	if mode == "stills":
		await _capture_stills(fixture, player, hud, sun, binding, wall_record)
	else:
		await _capture_motion(fixture, player, hud, sun, binding, wall_record)
	_finish(fixture)


func _load_capture_fixture(wall_record: Dictionary, roof_record: Dictionary) -> Dictionary:
	var player_scene := load("res://game/scenes/player/player.tscn") as PackedScene
	var hud_scene := load("res://game/scenes/ui/hud.tscn") as PackedScene
	if player_scene == null or hud_scene == null:
		return {"ok": false, "message": "Stock player or HUD scene did not load."}
	var baseline := _build_exact_source_baseline(wall_record, roof_record)
	if baseline == null:
		return {"ok": false, "message": "Exact frozen baseline could not be built."}
	var result := PROTOTYPE.build_for_records(wall_record, roof_record)
	if not bool(result.get("ok", false)):
		baseline.free()
		return result
	var prototype := result.node as D21439ChinookStandaloneHeroPrototype
	prototype.name = "CaptureOnly_D2_1439_Chinook_StandaloneHero"
	prototype.set_meta("capture_only_replacement", true)
	var fixture := Node3D.new()
	fixture.name = "D2_1439_IsolatedNeutralGroundCaptureFixture"
	fixture.set_meta("capture_only", true)
	fixture.set_meta("live_world_loaded", false)
	fixture.set_meta("neutral_ground_top_y_m", 3.15)
	fixture.set_meta("exact_source_baseline", true)
	var environment := WorldEnvironment.new()
	environment.name = "CaptureWorldEnvironment"
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color(0.46, 0.69, 0.86, 1.0)
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color(0.71, 0.77, 0.82, 1.0)
	environment.environment.ambient_light_energy = 0.65
	environment.environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	fixture.add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = DEFAULT_SUN
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 200.0
	fixture.add_child(sun)
	var ground := _build_neutral_ground()
	fixture.add_child(ground)
	var architecture := Node3D.new()
	architecture.name = "Architecture"
	fixture.add_child(architecture)
	architecture.add_child(baseline)
	architecture.add_child(prototype)
	var player := player_scene.instantiate() as PlayerController
	player.name = "Player"
	fixture.add_child(player)
	var interface := CanvasLayer.new()
	interface.name = "Interface"
	fixture.add_child(interface)
	var hud := hud_scene.instantiate() as GameHUD
	hud.name = "HUD"
	interface.add_child(hud)
	var recovery_events: Array[Dictionary] = []
	player.recovered.connect(func(cause: String, from_position: Vector3) -> void: recovery_events.append({"cause": cause, "from_position_m": _vector3(from_position)}))
	root.add_child(fixture)
	_set_prototype_enabled(prototype, false)
	_set_baseline_enabled([baseline], true)
	for _frame in 2:
		await process_frame
		await physics_frame
	return {
		"ok": true,
		"fixture": fixture,
		"player": player,
		"hud": hud,
		"sun": sun,
		"binding": {
			"prototype": prototype,
			"baseline": [baseline],
			"recovery_events": recovery_events,
			"fixture_contract": {
				"isolated_neutral_ground": true,
				"live_world_loaded": false,
				"neutral_ground_top_y_m": 3.15,
				"neutral_ground_extent_m": [130.0, 130.0],
				"exact_source_wall_triangles": 48,
				"exact_flat_source_roof_triangles": 10,
				"baseline_collision_triangles": 58,
				"stock_player_scene": "res://game/scenes/player/player.tscn",
				"stock_hud_scene": "res://game/scenes/ui/hud.tscn",
			},
		},
	}


func _build_exact_source_baseline(wall_record: Dictionary, roof_record: Dictionary) -> Node3D:
	if not PROTOTYPE.matches_record_pair(wall_record, roof_record):
		return null
	var baseline := Node3D.new()
	baseline.name = "ExactFrozenFlatWallRoofBaseline"
	baseline.set_meta("capture_only", true)
	baseline.set_meta("source_keys", [SOURCE_KEY])
	baseline.set_meta("wall_record_sha256", PROTOTYPE.record_signature(wall_record))
	baseline.set_meta("roof_record_sha256", PROTOTYPE.record_signature(roof_record))
	var wall_material := StandardMaterial3D.new()
	wall_material.resource_name = "capture_only_neutral_frozen_wall_baseline"
	wall_material.albedo_color = Color(0.71, 0.66, 0.57, 1.0)
	wall_material.roughness = 0.92
	var roof_material := StandardMaterial3D.new()
	roof_material.resource_name = "capture_only_neutral_frozen_roof_baseline"
	roof_material.albedo_color = Color(0.36, 0.32, 0.29, 1.0)
	roof_material.roughness = 0.94
	var wall_mesh := _source_record_mesh(wall_record, wall_material, "ExactFrozenWall", 1 << 1)
	var roof_mesh := _source_record_mesh(roof_record, roof_material, "ExactFrozenFlatRoof", 1 << 0)
	if wall_mesh == null or roof_mesh == null:
		baseline.free()
		return null
	baseline.add_child(wall_mesh)
	baseline.add_child(roof_mesh)
	var faces := PackedVector3Array()
	for record: Dictionary in [wall_record, roof_record]:
		var vertices := record.vertices as Array
		var indices := record.indices as Array
		for index_offset in range(0, indices.size(), 3):
			for local_index: int in [0, 2, 1]:
				var offset := int(indices[index_offset + local_index]) * 3
				faces.append(Vector3(float(vertices[offset]), float(vertices[offset + 1]), float(vertices[offset + 2])))
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	shape.set_meta("derived_object_key", WALL_KEY)
	shape.set_meta("source_keys", [SOURCE_KEY])
	shape.set_meta("capture_only_exact_source_baseline", true)
	var collision_shape := CollisionShape3D.new()
	collision_shape.name = "ExactFrozenWallRoofShape"
	collision_shape.shape = shape
	var body := StaticBody3D.new()
	body.name = "ExactFrozenWallRoofCollision"
	body.collision_layer = WORLD_SOLID_MASK
	body.collision_mask = 0
	body.set_meta("derived_object_key", WALL_KEY)
	body.set_meta("source_keys", [SOURCE_KEY])
	body.set_meta("feature_kind", "building_wall")
	body.set_meta("receiver_kind", "building_wall")
	body.set_meta("capture_only_exact_source_baseline", true)
	body.add_child(collision_shape)
	baseline.add_child(body)
	return baseline


func _source_record_mesh(record: Dictionary, material: Material, node_name: String, layers: int) -> MeshInstance3D:
	var source_vertices := record.vertices as Array
	var source_normals := record.normals as Array
	var source_uvs := record.uvs as Array
	var source_indices := record.indices as Array
	if source_vertices.is_empty() or source_indices.is_empty():
		return null
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for offset in range(0, source_vertices.size(), 3):
		vertices.append(Vector3(float(source_vertices[offset]), float(source_vertices[offset + 1]), float(source_vertices[offset + 2])))
		normals.append(Vector3(float(source_normals[offset]), float(source_normals[offset + 1]), float(source_normals[offset + 2])))
	for offset in range(0, source_uvs.size(), 2):
		uvs.append(Vector2(float(source_uvs[offset]), float(source_uvs[offset + 1])))
	for offset in range(0, source_indices.size(), 3):
		indices.append(int(source_indices[offset]))
		indices.append(int(source_indices[offset + 2]))
		indices.append(int(source_indices[offset + 1]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_name(0, node_name.to_snake_case())
	mesh.surface_set_material(0, material)
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.layers = layers
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return instance


func _build_neutral_ground() -> Node3D:
	var record := Node3D.new()
	record.name = "CaptureOnlyNeutralGround"
	record.position = Vector3(-291.0, 3.00, -5.0)
	record.set_meta("feature_kind", "capture_neutral_ground")
	record.set_meta("derived_object_key", "capture-only:neutral-ground")
	record.set_meta("source_keys", [])
	var box := BoxMesh.new()
	box.size = Vector3(130.0, 0.30, 130.0)
	var material := StandardMaterial3D.new()
	material.resource_name = "capture_only_neutral_ground"
	material.albedo_color = Color(0.41, 0.48, 0.36, 1.0)
	material.roughness = 1.0
	box.material = material
	var visual := MeshInstance3D.new()
	visual.name = "NeutralGroundVisual"
	visual.mesh = box
	visual.layers = 1 << 0
	record.add_child(visual)
	var shape := BoxShape3D.new()
	shape.size = box.size
	var collision_shape := CollisionShape3D.new()
	collision_shape.name = "NeutralGroundShape"
	collision_shape.shape = shape
	var body := StaticBody3D.new()
	body.name = "NeutralGroundCollision"
	body.collision_layer = WORLD_SOLID_MASK
	body.collision_mask = 0
	body.set_meta("capture_only", true)
	body.add_child(collision_shape)
	record.add_child(body)
	return record


func _capture_stills(fixture: Node3D, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, binding: Dictionary, wall_record: Dictionary) -> void:
	var prototype := binding.prototype as D21439ChinookStandaloneHeroPrototype
	var baseline := binding.baseline as Array
	var captures: Array[Dictionary] = []
	var pairs: Array[Dictionary] = []
	var original_sun := sun.rotation_degrees
	for view_value: Variant in VIEWS:
		var view := view_value as Dictionary
		sun.rotation_degrees = view.sun as Vector3
		_set_prototype_enabled(prototype, false)
		_set_baseline_enabled(baseline, true)
		await physics_frame
		var posed := await _settle_and_aim(player, hud, view.requested_xz as Vector2, view.aim_target as Vector3, str(view.id))
		if not _require(bool(posed.get("ok", false)), str(posed.get("message", "%s pose failed." % str(view.id)))):
			return
		var camera := player.get_camera()
		var frozen_camera := camera.global_transform
		var frozen_player := player.global_transform
		var before_projection := _framing_metadata(camera, baseline)
		var before_los := _center_los(player, view.aim_target as Vector3, wall_record, WALL_KEY, int(view.expected_run_index), str(view.id))
		if not _require(_framing_is_valid(before_projection), "%s baseline framing failed: %s" % [view.id, before_projection]) \
		or not _require(bool(before_los.get("ok", false)), str(before_los.get("message", "%s baseline LOS failed." % str(view.id)))):
			return
		var before_extra := (posed.metadata as Dictionary).duplicate(true)
		before_extra.merge(before_projection.metadata as Dictionary, true)
		before_extra.merge(before_los.metadata as Dictionary, true)
		var before := await _save_still(fixture, player, hud, sun, view, "before", before_extra)
		if not _require(bool(before.get("ok", false)), str(before.get("message", "Baseline save failed."))):
			return

		_set_baseline_enabled(baseline, false)
		_set_prototype_enabled(prototype, true)
		await physics_frame
		for _frame in 2:
			await process_frame
			await RenderingServer.frame_post_draw
		var camera_error := camera.global_position.distance_to(frozen_camera.origin)
		var basis_error := _basis_error(camera.global_basis, frozen_camera.basis)
		var player_error := player.global_position.distance_to(frozen_player.origin)
		var after_projection := _framing_metadata(camera, [prototype])
		var after_los := _center_los(player, view.aim_target as Vector3, wall_record, "prototype:%s" % WALL_KEY, int(view.expected_run_index), str(view.id))
		if not _require(camera_error <= 0.0001 and basis_error <= 0.0001 and player_error <= 0.0001, "%s camera/player moved during swap." % view.id) \
		or not _require(_framing_is_valid(after_projection), "%s prototype framing failed: %s" % [view.id, after_projection]) \
		or not _require(bool(after_los.get("ok", false)), str(after_los.get("message", "%s prototype LOS failed." % str(view.id)))):
			return
		var after_extra := (posed.metadata as Dictionary).duplicate(true)
		after_extra.merge(after_projection.metadata as Dictionary, true)
		after_extra.merge(after_los.metadata as Dictionary, true)
		after_extra["pair_camera_translation_error_m"] = camera_error
		after_extra["pair_camera_basis_error"] = basis_error
		after_extra["pair_player_translation_error_m"] = player_error
		var after := await _save_still(fixture, player, hud, sun, view, "after", after_extra)
		if not _require(bool(after.get("ok", false)), str(after.get("message", "Prototype save failed."))):
			return
		captures.append(before.metadata as Dictionary)
		captures.append(after.metadata as Dictionary)
		pairs.append({
			"view_id": str(view.id),
			"before_capture_id": str((before.metadata as Dictionary).id),
			"after_capture_id": str((after.metadata as Dictionary).id),
			"camera_transform_exactly_reused": true,
			"camera_translation_error_m": camera_error,
			"camera_basis_error": basis_error,
			"player_translation_error_m": player_error,
			"sun_rotation_degrees": _vector3(view.sun as Vector3),
		})
	_set_prototype_enabled(prototype, false)
	_set_baseline_enabled(baseline, true)
	sun.rotation_degrees = original_sun
	var manifest := {
		"schema_version": "ti.d2-1439-chinook-standalone-hero-evidence/1",
		"review_status": "technical_capture_valid_recognition_and_believability_pending_independent_bar_raiser_review",
		"evidence_role": "Native technical same-pose baseline/prototype evidence in an isolated neutral-ground fixture only; executor verified exact frozen source binding, grounded stock player, framing, transform reuse, changed light, and PNG integrity without grading visual quality.",
		"target": {
			"canonical_name": "1439 Chinook Court",
			"source_key": SOURCE_KEY,
			"wall_object_key": WALL_KEY,
			"roof_object_key": ROOF_KEY,
			"source_geometry_sha256": PROTOTYPE.SOURCE_GEOMETRY_SHA256,
			"wall_record_sha256": PROTOTYPE.EXPECTED_WALL_RECORD_SHA256,
			"roof_record_sha256": PROTOTYPE.EXPECTED_ROOF_RECORD_SHA256,
			"mapped_public_sse_runs": MAPPED_RUNS,
			"motif_host_runs": MOTIF_HOST_RUNS,
			"mapped_motif_free_runs": MAPPED_MOTIF_FREE_RUNS,
			"tiny_fragment_runs": TINY_FRAGMENT_RUNS,
			"protected_runs": PROTECTED_RUNS,
			"source_base_wall_top_y_m": [3.536, 9.536],
		},
		"truth_boundary": {
			"standalone_capture_only": true,
			"isolated_neutral_ground_fixture": true,
			"live_world_loaded": false,
			"runtime_attachment": false,
			"recognition_accepted": false,
			"believability_accepted": false,
			"as_built_claim": false,
			"interior_modeled": false,
			"all_module_dimensions_and_counts_and_roof_rise": "reversible_production_inference",
			"source_photography_stored_or_shown": false,
			"protected_runs_have_modules": false,
			"mapped_motif_free_runs_have_addressable_motifs": false,
			"tiny_fragments_receive_standalone_motifs": false,
			"fallback_collider_retained": false,
		},
		"confusion_set_source_ids_frozen_before_capture": CONFUSION_SET,
		"confusion_set_named_frozen_before_capture": CONFUSION_SET_NAMED,
		"implemented_comparator_source_ids": IMPLEMENTED_COMPARATORS,
		"reference_supported_cues_frozen_before_capture": FROZEN_SUPPORTED_CUES,
		"capture_command": ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/d2_1439_chinook_standalone_hero_capture.gd -- --capture-mode=stills",
		"generator": "game/tests/d2_1439_chinook_standalone_hero_capture.gd",
		"generator_sha256": FileAccess.get_sha256("res://game/tests/d2_1439_chinook_standalone_hero_capture.gd"),
		"pinned_inputs": _package_hashes(),
		"capture_fixture_inputs": _fixture_hashes(),
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"rendering_method": "Forward+",
		"rendering_driver": "Metal",
		"viewport": [STILL_SIZE.x, STILL_SIZE.y],
		"lighting": {"default_sun_rotation_degrees": _vector3(DEFAULT_SUN), "changed_sun_rotation_degrees": _vector3(CHANGED_SUN), "changed_light_pair_id": "03-sse-oblique-changed-light"},
		"capture_fixture_contract": binding.fixture_contract,
		"prototype_topology": _prototype_topology(prototype),
		"camera_contract": {"rig": "actual Player/CameraPivot/SpringArm3D/Camera3D", "player_visible": true, "physics_grounded": true, "fov_degrees": 70.0, "configured_spring_length_m": 5.5, "before_after_pair_transform_rule": "exact same live Camera3D and Player transforms within 0.0001"},
		"capture_pairs": pairs,
		"captures": captures,
		"technical_self_check_only": true,
		"visual_verdict": "pending_independent_bar_raiser_review",
		"reviewer_instruction": "Open all six PNGs at original detail before reading labels. Against authoritative close-confusion targets 1437, 1441, and 1438 Chinook, and implemented comparators 1441 Chinook and 1444 Croaker, decide whether the after views are top-1 1439 using at least two supported cues: one offset two-level end stack plus the upper-only quiet register and opposite single passage. Check the shallow dark roof/eave and reused stucco under both lights without relying on warm-white hue, address, location, or source ID. Treat every module dimension, count, anchor, spacing, and roof rise as reversible production inference; do not infer unseen or screened schedules.",
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write 1439 capture manifest.")
		return
	print("PASS: captured %d native grounded 1439 same-pose baseline/prototype stills; recognition and believability remain pending independent review" % captures.size())


func _capture_motion(fixture: Node3D, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, binding: Dictionary, wall_record: Dictionary) -> void:
	if Engine.physics_ticks_per_second != MOTION_PHYSICS_HZ:
		_fail("Physics tick rate drifted from %d Hz." % MOTION_PHYSICS_HZ)
		return
	var prototype := binding.prototype as D21439ChinookStandaloneHeroPrototype
	var baseline := binding.baseline as Array
	_set_baseline_enabled(baseline, false)
	_set_prototype_enabled(prototype, true)
	sun.rotation_degrees = DEFAULT_SUN
	var start_wall := TARGET_POINT - PUBLIC_TANGENT * 8.0
	var requested := Vector2(start_wall.x + PUBLIC_OUTWARD.x * 22.0, start_wall.z + PUBLIC_OUTWARD.z * 22.0)
	var posed := await _settle_and_aim(player, hud, requested, TARGET_POINT, "sse-stock-walk-start")
	if not _require(bool(posed.get("ok", false)), str(posed.get("message", "Motion pose failed."))):
		return
	var los := _center_los(player, TARGET_POINT, wall_record, "prototype:%s" % WALL_KEY, 19, "sse-stock-walk-start")
	if not _require(bool(los.get("ok", false)), str(los.get("message", "Motion LOS failed."))):
		return
	var recovery_before := (binding.recovery_events as Array).size()
	var start_position := player.global_position
	var start_basis := player.get_camera().global_basis
	var start_process_frame := Engine.get_process_frames()
	var start_physics_frame := Engine.get_physics_frames()
	var samples: Array[Dictionary] = []
	var review_images: Array[Image] = []
	var review_frame_numbers: Array[int] = []
	player.set_gameplay_enabled(true)
	Input.action_press("move_right")
	for frame_index in MOTION_PHYSICS_FRAMES:
		paused = false
		_clean_hud(hud)
		await physics_frame
		if not player.is_on_floor():
			Input.action_release("move_right")
			player.set_gameplay_enabled(false)
			_fail("Stock player left the isolated neutral capture ground at motion frame %d." % (frame_index + 1))
			return
		var position := player.global_position
		samples.append({"frame": frame_index + 1, "player_position_m": _vector3(position), "velocity_mps": _vector3(player.velocity), "is_on_floor": true, "along_public_tangent_m": (position - TARGET_POINT).dot(PUBLIC_TANGENT), "outward_from_target_m": (position - TARGET_POINT).dot(PUBLIC_OUTWARD), "camera_position_m": _vector3(player.get_camera().global_position)})
		if frame_index % 20 == 0 or frame_index == MOTION_PHYSICS_FRAMES - 1:
			var review_image := root.get_texture().get_image()
			if not _require(review_image != null and not review_image.is_empty(), "Motion review frame %d was empty." % (frame_index + 1)):
				Input.action_release("move_right")
				player.set_gameplay_enabled(false)
				return
			review_images.append(review_image)
			review_frame_numbers.append(frame_index + 1)
	var input_end_process_frame := Engine.get_process_frames()
	var input_end_physics_frame := Engine.get_physics_frames()
	Input.action_release("move_right")
	for _frame in 12:
		await physics_frame
	player.set_gameplay_enabled(false)
	var end_position := player.global_position
	var displacement := Vector2(end_position.x - start_position.x, end_position.z - start_position.z).length()
	var direction := Vector3(end_position.x - start_position.x, 0.0, end_position.z - start_position.z).normalized()
	if not _require(displacement >= 10.0, "Stock walk displaced only %.3f m." % displacement) \
	or not _require((binding.recovery_events as Array).size() == recovery_before, "Stock walk triggered recovery.") \
	or not _require(start_basis.is_equal_approx(player.get_camera().global_basis), "Camera orientation changed during stock walk."):
		return
	var review_sheet := _write_motion_review_sheet(review_images)
	if not _require(bool(review_sheet.get("ok", false)), str(review_sheet.get("message", "Motion review contact sheet failed."))):
		return
	var manifest := {
		"schema_version": "ti.d2-1439-chinook-standalone-motion-evidence/1",
		"review_status": "technical_motion_valid_visual_review_pending",
		"evidence_role": "Continuous stock-player public-side walk in an isolated neutral-ground fixture for facade cadence, meter-repeat, seam, shimmer, and stability review; standalone prototype only, with no live world loaded.",
		"capture_command": ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1280x800 --write-movie evidence/first-playable/d2-1439-chinook-standalone-hero-2026-09-04/%s --fixed-fps 30 --script game/tests/d2_1439_chinook_standalone_hero_capture.gd -- --capture-mode=motion" % MOTION_FILE,
		"generator": "game/tests/d2_1439_chinook_standalone_hero_capture.gd",
		"generator_sha256": FileAccess.get_sha256("res://game/tests/d2_1439_chinook_standalone_hero_capture.gd"),
		"package_hashes": _package_hashes(),
		"capture_fixture_inputs": _fixture_hashes(),
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"render_viewport": [root.get_texture().get_width(), root.get_texture().get_height()],
		"movie_dimensions": [MOTION_SIZE.x, MOTION_SIZE.y],
		"movie_file": MOTION_FILE,
		"movie_sha256": "pending_after_movie_writer_close",
		"movie_bytes": -1,
		"movie_total_frames_expected_after_close": Engine.get_process_frames() + 1,
		"movie_contains_startup_before_motion": true,
		"motion_review_contact_sheet": str(review_sheet.file),
		"motion_review_contact_sheet_sha256": str(review_sheet.sha256),
		"motion_review_contact_sheet_dimensions": review_sheet.dimensions,
		"motion_review_sample_physics_frames": review_frame_numbers,
		"motion_review_contact_sheet_is_derived_non_authoritative": true,
		"review_motion_process_frame_range": [start_process_frame, input_end_process_frame],
		"review_motion_physics_frame_range": [start_physics_frame, input_end_physics_frame],
		"fixed_fps": MOTION_FIXED_FPS,
		"physics_ticks_per_second": MOTION_PHYSICS_HZ,
		"input_action": "move_right",
		"run_action_pressed": false,
		"configured_walk_speed_mps": player.walk_speed_mps,
		"motion_physics_frames": MOTION_PHYSICS_FRAMES,
		"continuous_duration_seconds": float(MOTION_PHYSICS_FRAMES) / float(MOTION_PHYSICS_HZ),
		"start_position_m": _vector3(start_position),
		"end_position_m": _vector3(end_position),
		"horizontal_displacement_m": displacement,
		"direction_dot_public_tangent_abs": absf(direction.dot(PUBLIC_TANGENT)),
		"direction_contract": "stock camera-right public-side walk; absolute dot with the declared public tangent must remain at least 0.90 but is not asserted to be exact tangent alignment",
		"player_transform_writes_after_input_began": 0,
		"camera_orientation_changed_during_motion": false,
		"all_samples_grounded": true,
		"recovery_delta": (binding.recovery_events as Array).size() - recovery_before,
		"capture_fixture_contract": binding.fixture_contract,
		"confusion_set_source_ids_frozen_before_capture": CONFUSION_SET,
		"confusion_set_named_frozen_before_capture": CONFUSION_SET_NAMED,
		"implemented_comparator_source_ids": IMPLEMENTED_COMPARATORS,
		"reference_supported_cues_frozen_before_capture": FROZEN_SUPPORTED_CUES,
		"mapped_public_runs_under_review": MAPPED_RUNS,
		"meter_uv_rule_under_review": "one geometry UV unit per modeled meter; 3 m stucco and 5 m roof material repeat assumptions",
		"architecture_under_review": "entity-specific offset two-level balcony stack on run 11, upper-only quiet register on run 19, and blank-upper single-passage end on run 23; mapped tiny runs 17/18 have no standalone motifs",
		"samples": samples,
		"visual_verdict": "pending_independent_bar_raiser_review",
	}
	if not _write_json(OUTPUT.path_join("motion-capture.json"), manifest):
		_fail("Could not write 1439 motion manifest.")
		return
	print("PASS: drove a %.3f m, %.1f s grounded stock-player walk beside standalone 1439 with zero transform writes and recoveries; movie finalization remains post-close" % [displacement, float(MOTION_PHYSICS_FRAMES) / MOTION_PHYSICS_HZ])


func _write_motion_review_sheet(images: Array[Image]) -> Dictionary:
	if images.size() != 13:
		return {"ok": false, "message": "Expected exactly 13 evenly sampled motion review frames, got %d." % images.size()}
	const CELL := Vector2i(320, 200)
	const GRID := Vector2i(4, 4)
	var sheet := Image.create_empty(CELL.x * GRID.x, CELL.y * GRID.y, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.02, 0.02, 0.02, 1.0))
	for index in images.size():
		var sample := images[index]
		sample.convert(Image.FORMAT_RGBA8)
		sample.resize(CELL.x, CELL.y, Image.INTERPOLATE_LANCZOS)
		var destination := Vector2i((index % GRID.x) * CELL.x, (index / GRID.x) * CELL.y)
		sheet.blit_rect(sample, Rect2i(Vector2i.ZERO, CELL), destination)
	var relative := "images/d2-1439-chinook-sse-motion-review-sheet.png"
	var path := OUTPUT.path_join(relative)
	if sheet.save_png(path) != OK:
		return {"ok": false, "message": "Could not save the 1439 motion review contact sheet."}
	return {
		"ok": true,
		"file": relative,
		"sha256": FileAccess.get_sha256(path),
		"dimensions": [sheet.get_width(), sheet.get_height()],
	}


func _finalize_motion_manifest() -> void:
	var expected_hash := _argument_value("--movie-sha256=")
	var expected_bytes := int(_argument_value("--movie-bytes="))
	var movie_path := OUTPUT.path_join(MOTION_FILE)
	var manifest_path := OUTPUT.path_join("motion-capture.json")
	var manifest := _json(manifest_path)
	if not _require(expected_hash.length() == 64 and expected_hash == FileAccess.get_sha256(movie_path), "Movie finalizer received a missing or incorrect SHA-256.") \
	or not _require(expected_bytes > 0 and expected_bytes == FileAccess.get_file_as_bytes(movie_path).size(), "Movie finalizer received a missing or incorrect byte count.") \
	or not _require(str(manifest.get("movie_sha256", "")) == "pending_after_movie_writer_close", "Motion manifest was not in post-close state."):
		return
	manifest["movie_sha256"] = expected_hash
	manifest["movie_bytes"] = expected_bytes
	manifest["movie_finalized_after_writer_close"] = true
	manifest["finalizer_command"] = "headless finalizer received exact observed movie SHA-256 and byte count"
	if not _write_json(manifest_path, manifest):
		_fail("Could not finalize 1439 motion manifest.")
		return
	print("PASS: finalized 1439 motion movie sha256=%s bytes=%d" % [expected_hash, expected_bytes])


func _set_baseline_enabled(nodes: Array, enabled: bool) -> void:
	for node_value: Variant in nodes:
		var node := node_value as Node3D
		node.visible = enabled
		for body_value: Variant in node.find_children("*", "CollisionObject3D", true, false):
			var body := body_value as CollisionObject3D
			if not body.has_meta("d2_1439_capture_original_collision_layer"):
				body.set_meta("d2_1439_capture_original_collision_layer", body.collision_layer)
			body.collision_layer = int(body.get_meta("d2_1439_capture_original_collision_layer", 0)) if enabled else 0


func _set_prototype_enabled(prototype: Node3D, enabled: bool) -> void:
	prototype.visible = enabled
	var body := prototype.get_node("ExactFootprintStructuralCollision_NoSprayOwnership") as StaticBody3D
	body.collision_layer = 1 if enabled else 0


func _settle_and_aim(player: PlayerController, hud: GameHUD, requested_xz: Vector2, target: Vector3, pose_id: String) -> Dictionary:
	var initial_hit := _ground_hit(player, requested_xz)
	var initial_ground := _ground_metadata(initial_hit)
	if not bool(initial_ground.get("ok", false)):
		return {"ok": false, "message": "%s anchor has no walkable support: %s" % [pose_id, initial_ground]}
	_clear_gameplay_input()
	player.set_gameplay_enabled(false)
	var ground_y := float(initial_hit.position.y)
	var spawn := Vector3(requested_xz.x, ground_y + SETTLE_START_HEIGHT_M, requested_xz.y)
	player.global_transform = Transform3D(Basis.IDENTITY, spawn)
	player.velocity = Vector3.DOWN * 0.1
	player.force_update_transform()
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
	_clear_gameplay_input()
	player.set_gameplay_enabled(false)
	if not settled:
		return {"ok": false, "message": "%s did not physics-settle." % pose_id}
	var final_hit := _ground_hit(player, Vector2(settled_position.x, settled_position.z))
	var final_ground := _ground_metadata(final_hit)
	if not bool(final_ground.get("ok", false)):
		return {"ok": false, "message": "%s lost walkable support after settling." % pose_id}
	var clearance := settled_position.y - float(final_hit.position.y)
	var drift := Vector2(settled_position.x - requested_xz.x, settled_position.z - requested_xz.y).length()
	if absf(clearance) > SETTLE_CLEARANCE_TOLERANCE_M or drift > 0.05:
		return {"ok": false, "message": "%s invalid settle clearance=%.3f drift=%.3f." % [pose_id, clearance, drift]}
	var aimed := _aim_stock_player_camera(player, target)
	if not bool(aimed.get("ok", false)):
		return {"ok": false, "message": "%s %s" % [pose_id, aimed.get("message", "aim failed")]}
	if not await _wait_for_render(player.get_parent() as Node3D, player, hud):
		return {"ok": false, "message": "%s did not stabilize." % pose_id}
	var camera := player.get_camera()
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	var actual_spring := camera.global_position.distance_to(rig.global_position)
	if not is_equal_approx(camera.fov, 70.0) or not is_equal_approx(arm.spring_length, 5.5) or actual_spring < MIN_ACTUAL_SPRING_LENGTH_M:
		return {"ok": false, "message": "%s stock camera contract failed." % pose_id}
	return {"ok": true, "metadata": {"scenario_reset": "fixed_xz_then_real_character_physics_settle_on_capture_neutral_ground", "physics_grounded": true, "ordinary_player_rig": true, "input_reachable_camera_orientation": true, "requested_xz": [requested_xz.x, requested_xz.y], "settle_spawn_y_m": spawn.y, "player_position_m": _vector3(settled_position), "ground_y_m": float(final_hit.position.y), "ground_clearance_m": clearance, "settle_horizontal_drift_m": drift, "settle_physics_frames": settle_frames, "settle_recovery_delta": 0, "ground_feature": str(final_ground.feature), "ground_object": str(final_ground.object_key), "ground_sources": final_ground.source_keys, "aim_target_m": _vector3(target), "camera_position_m": _vector3(camera.global_position), "camera_forward": _vector3(-camera.global_basis.z), "camera_fov_degrees": camera.fov, "configured_spring_length_m": arm.spring_length, "actual_spring_length_m": actual_spring, "camera_yaw_degrees": float(aimed.yaw_degrees), "camera_pitch_degrees": float(aimed.pitch_degrees)}}


func _aim_stock_player_camera(player: PlayerController, target: Vector3) -> Dictionary:
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	var delta := target - rig.global_position
	var horizontal := Vector2(delta.x, delta.z).length()
	if horizontal < 0.001:
		return {"ok": false, "message": "target is vertically singular."}
	var yaw := atan2(-delta.x, -delta.z)
	var pitch := atan2(delta.y, horizontal)
	if pitch < deg_to_rad(rig.minimum_pitch_degrees) or pitch > deg_to_rad(rig.maximum_pitch_degrees):
		return {"ok": false, "message": "target pitch is outside stock camera limits."}
	rig.rotation = Vector3(0.0, yaw, 0.0)
	arm.rotation = Vector3(pitch, 0.0, 0.0)
	rig.force_update_transform()
	arm.force_update_transform()
	return {"ok": true, "yaw_degrees": rad_to_deg(yaw), "pitch_degrees": rad_to_deg(pitch)}


func _center_los(player: PlayerController, target: Vector3, record: Dictionary, expected_key: String, expected_run: int, view_id: String) -> Dictionary:
	var camera := player.get_camera()
	var center := camera.get_viewport().get_visible_rect().size * 0.5
	var projected := camera.unproject_position(target)
	if projected.distance_to(center) > 1.0:
		return {"ok": false, "message": "%s target is %.3f px from center." % [view_id, projected.distance_to(center)]}
	var origin := camera.project_ray_origin(center)
	var direction := camera.project_ray_normal(center).normalized()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 2000.0, WORLD_SOLID_MASK, [player.get_rid()])
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return {"ok": false, "message": "%s center LOS hit nothing." % view_id}
	var collider := hit.get("collider") as CollisionObject3D
	var hit_key := "" if collider == null else str(collider.get_meta("derived_object_key", ""))
	var hit_sources: Array = [] if collider == null else collider.get_meta("source_keys", [])
	var hit_run := _nearest_run_index(record, hit.position as Vector3)
	var target_error := (hit.position as Vector3).distance_to(target)
	if hit_key != expected_key or hit_sources != [SOURCE_KEY] or hit_run != expected_run or target_error > 0.4:
		return {"ok": false, "message": "%s LOS hit %s %s run %d error %.3f; expected %s run %d." % [view_id, hit_key, hit_sources, hit_run, target_error, expected_key, expected_run]}
	return {"ok": true, "metadata": {"viewport_center_px": [center.x, center.y], "aim_target_center_error_px": projected.distance_to(center), "first_los_hit_receiver": hit_key, "first_los_hit_source_keys": hit_sources, "first_los_hit_run_index": hit_run, "expected_los_run_index": expected_run, "first_los_hit_position_m": _vector3(hit.position as Vector3), "first_los_hit_distance_m": origin.distance_to(hit.position as Vector3), "first_los_hit_target_error_m": target_error, "receiver_source_run_first_los": true}}


func _framing_metadata(camera: Camera3D, nodes: Array) -> Dictionary:
	var points: Array[Vector3] = []
	for node_value: Variant in nodes:
		var node := node_value as Node3D
		for child_value: Variant in node.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance := child_value as MeshInstance3D
			if mesh_instance == null or mesh_instance.mesh == null or not mesh_instance.is_visible_in_tree():
				continue
			var bounds := mesh_instance.get_aabb()
			for x_index in 2:
				for y_index in 2:
					for z_index in 2:
						points.append(mesh_instance.global_transform * (bounds.position + Vector3(bounds.size.x * x_index, bounds.size.y * y_index, bounds.size.z * z_index)))
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
	var size := maximum - minimum
	return {"ok": behind < points.size(), "metadata": {"target_bounds_point_count": points.size(), "target_bounds_points_behind_camera": behind, "target_projected_min_px": [minimum.x, minimum.y], "target_projected_max_px": [maximum.x, maximum.y], "target_projected_width_ratio": size.x / STILL_SIZE.x, "target_projected_height_ratio": size.y / STILL_SIZE.y, "target_bounds_fully_in_frame": minimum.x >= 0.0 and minimum.y >= 0.0 and maximum.x <= STILL_SIZE.x and maximum.y <= STILL_SIZE.y}}


func _framing_is_valid(result: Dictionary) -> bool:
	if not bool(result.get("ok", false)):
		return false
	var data := result.metadata as Dictionary
	return int(data.target_bounds_points_behind_camera) == 0 and bool(data.target_bounds_fully_in_frame) and float(data.target_projected_width_ratio) >= 0.12 and float(data.target_projected_height_ratio) >= 0.035 and float(data.target_projected_width_ratio) <= 0.96 and float(data.target_projected_height_ratio) <= 0.96


func _save_still(fixture: Node3D, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, view: Dictionary, stage: String, extra: Dictionary) -> Dictionary:
	if not await _wait_for_render(fixture, player, hud):
		return {"ok": false, "message": "%s %s did not stabilize." % [view.id, stage]}
	var hud_state := _hud_state(hud)
	if bool(hud_state.debug_panel_visible) or bool(hud_state.feedback_panel_visible) or bool(hud_state.load_panel_visible) or bool(hud_state.pause_panel_visible) or not bool(hud_state.reticle_visible):
		return {"ok": false, "message": "%s %s HUD is not clean." % [view.id, stage]}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != STILL_SIZE:
		return {"ok": false, "message": "%s %s image is empty or wrong-sized." % [view.id, stage]}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.1:
		return {"ok": false, "message": "%s %s image appears blank." % [view.id, stage]}
	var capture_id := "%s-%s" % [str(view.id), stage]
	var relative := "images/%s.png" % capture_id
	var path := OUTPUT.path_join(relative)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save." % capture_id}
	var metadata := {"id": capture_id, "stage": stage, "target": "1439-chinook-court", "source_identity": SOURCE_KEY, "role": str(view.role), "recognition_verdict": "pending_independent_bar_raiser_review", "believability_verdict": "pending_independent_bar_raiser_review", "confusion_set_source_ids_frozen_before_capture": CONFUSION_SET, "reference_supported_cues_frozen_before_capture": FROZEN_SUPPORTED_CUES, "file": relative, "sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [image.get_width(), image.get_height()], "sample_unique_colors": int(sample.unique_colors), "sample_luminance_range": float(sample.luminance_range), "hud": hud_state, "player_visible": player.visible, "debug_labels_visible": false, "source_photography_in_frame": false, "lighting_changed": not (view.sun as Vector3).is_equal_approx(DEFAULT_SUN), "sun_rotation_degrees": _vector3(sun.rotation_degrees), "full_entity_required_and_in_frame": true, "protected_untreated_faces_intentionally_not_hidden": true, "capture_only_prototype_swap": stage == "after"}
	metadata.merge(extra, true)
	print("D2_1439_CAPTURE: id=%s grounded=%s frame=%.3fx%.3f sha256=%s" % [capture_id, metadata.physics_grounded, metadata.target_projected_width_ratio, metadata.target_projected_height_ratio, metadata.sha256])
	return {"ok": true, "metadata": metadata}


func _package_hashes() -> Dictionary:
	var paths := [CONFIG_PATH, CHUNK_PATH, PACKET_PATH, "res://game/scripts/world/facades/site_12_housing_kit.gd", "res://game/scripts/world/facades/d2_1439_chinook_standalone_hero_prototype.gd", PROTOTYPE_SCENE_PATH, "res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres", "res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres", "res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres", "res://game/resources/materials/world/site_12_housing/site_12_void_shadow.tres", "res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres", "res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres", "res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png", "res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg"]
	var hashes := {}
	for path: String in paths:
		hashes[path] = FileAccess.get_sha256(path)
	return hashes


func _fixture_hashes() -> Dictionary:
	var paths := [
		"res://game/scenes/player/player.tscn",
		"res://game/scripts/player/player_controller.gd",
		"res://game/scripts/player/player_camera.gd",
		"res://game/scripts/player/recovery_controller.gd",
		"res://game/scripts/interaction/spray_controller.gd",
		"res://game/scripts/interaction/tag_instance_pool.gd",
		"res://game/scenes/ui/hud.tscn",
		"res://game/scripts/ui/hud.gd",
	]
	var hashes := {}
	for path: String in paths:
		hashes[path] = FileAccess.get_sha256(path)
	return hashes


func _prototype_topology(prototype: Node3D) -> Dictionary:
	return {"mesh_instances": int(prototype.get_meta("mesh_instances", 0)), "surfaces": int(prototype.get_meta("surfaces", 0)), "visual_triangles": int(prototype.get_meta("visual_triangles", 0)), "visual_batch_triangles": prototype.get_meta("visual_batch_triangles", {}), "static_bodies": int(prototype.get_meta("static_bodies", 0)), "shapes": int(prototype.get_meta("shapes", 0)), "collision_triangles": int(prototype.get_meta("collision_triangles", 0)), "deterministic_signature": str(prototype.get_meta("deterministic_signature", "")), "balcony_void_count": int(prototype.get_meta("balcony_void_count", 0)), "rail_picket_count": int(prototype.get_meta("rail_picket_count", 0)), "quiet_upper_opening_count": int(prototype.get_meta("quiet_upper_opening_count", 0)), "passage_void_count": int(prototype.get_meta("passage_void_count", 0)), "passage_pier_count": int(prototype.get_meta("passage_pier_count", 0)), "mapped_eave_chain_count": int(prototype.get_meta("mapped_eave_chain_count", 0))}


func _record_for_key(records: Array, key: String) -> Dictionary:
	for value: Variant in records:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == key:
			return record
	return {}


func _nearest_run_index(record: Dictionary, hit: Vector3) -> int:
	var values := record.vertices as Array
	var best_index := -1
	var best_distance := INF
	for run_index in 24:
		var offset := run_index * 12
		var distance := _point_segment_distance(Vector2(hit.x, hit.z), Vector2(float(values[offset]), float(values[offset + 2])), Vector2(float(values[offset + 3]), float(values[offset + 5])))
		if distance < best_distance:
			best_distance = distance
			best_index = run_index
	return best_index


func _point_segment_distance(point: Vector2, start: Vector2, end: Vector2) -> float:
	var segment := end - start
	if segment.length_squared() <= 0.0000001:
		return point.distance_to(start)
	return point.distance_to(start + segment * clampf((point - start).dot(segment) / segment.length_squared(), 0.0, 1.0))


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
	if record == null or feature != "capture_neutral_ground" or normal.dot(Vector3.UP) < 0.7:
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
	return {"debug_panel_visible": hud.debug_panel.visible, "feedback_panel_visible": hud.feedback_panel.visible, "load_panel_visible": hud.load_panel.visible, "pause_panel_visible": hud.pause_panel.visible, "reticle_visible": hud.reticle.visible}


func _wait_for_render(fixture: Node3D, player: PlayerController, hud: GameHUD) -> bool:
	for _index in 2:
		paused = false
		player.set_gameplay_enabled(false)
		_clean_hud(hud)
		await process_frame
		await RenderingServer.frame_post_draw
	return not paused and not bool(_hud_state(hud).debug_panel_visible) and not bool(_hud_state(hud).pause_panel_visible) and fixture.visible


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


func _basis_error(a: Basis, b: Basis) -> float:
	return maxf(maxf(a.x.distance_to(b.x), a.y.distance_to(b.y)), a.z.distance_to(b.z))


func _json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _write_json(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value, "  ", false) + "\n")
	file.close()
	return true


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""


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
		_fail("1439 Chinook native evidence timed out after %.0f seconds." % TIMEOUT_SECONDS)
		_finish(null)


func _finish(main: Node) -> void:
	if _finished:
		return
	_finished = true
	_clear_gameplay_input()
	if main != null and is_instance_valid(main):
		main.queue_free()
	quit(1 if not _failure.is_empty() else 0)
