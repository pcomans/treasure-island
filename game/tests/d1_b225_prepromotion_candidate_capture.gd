extends "res://game/tests/isle_house_low_live_evidence_capture.gd"

## Fresh, source-native evidence for the explicitly enabled B225 prepromotion
## live A/B. The canonical builder first produces the exact ordinary 7/213
## world. Only then does this harness call the isolated candidate seam once.
## These pixels can authorize promotion; they cannot grant recognition credit.


class PostPlayerPhysicsSampler:
	extends Node

	signal post_player_physics_tick(snapshot: Dictionary)

	var _player: PlayerController
	var _chain_start := Vector3.ZERO
	var _chain_tangent := Vector3.FORWARD
	var _sequence_index := 0
	var latest_snapshot: Dictionary = {}


	func configure(player: PlayerController, chain_start: Vector3, chain_tangent: Vector3) -> void:
		_player = player
		_chain_start = chain_start
		_chain_tangent = chain_tangent
		process_physics_priority = player.process_physics_priority + 100


	func _physics_process(_delta: float) -> void:
		if not is_instance_valid(_player):
			return
		_sequence_index += 1
		var position := _player.global_position
		latest_snapshot = {
			"engine_physics_frame": Engine.get_physics_frames(),
			"sampler_sequence_index": _sequence_index,
			"player_position_m": [position.x, position.y, position.z],
			"chain_u_m": Vector2(position.x - _chain_start.x, position.z - _chain_start.z).dot(Vector2(_chain_tangent.x, _chain_tangent.z)),
		}
		post_player_physics_tick.emit(latest_snapshot.duplicate(true))

const CANDIDATE_SEAM := preload("res://game/tests/support/d1_b225_prepromotion_candidate_seam.gd")
const ADAPTER := preload("res://game/scripts/world/facades/d1_b225_live_attachment.gd")
const B225_OUTPUT := "res://evidence/first-playable/d1-b225-prepromotion-candidate-r3-2026-09-05"
const REHEARSAL_OUTPUT := "user://d1-b225-prepromotion-candidate-r3-complete-rehearsal-2026-09-05"
const R1_REJECTION_PATH := B225_OUTPUT + "/r1-rejection.json"
const R1_REJECTION_SHA256 := "5379780f58242d028ca0c7373581d2f9182b60a558ae090df3767c924fdec817"
const R2_REJECTION_PATH := B225_OUTPUT + "/r2-rejection.json"
const R2_REJECTION_SHA256 := "0c662d11f34d831687e36bd6411ac4e707871b45755ae7560ee317a1c393d6c1"
const B225_GENERATOR := "res://game/tests/d1_b225_prepromotion_candidate_capture.gd"
const B225_PARENT_HARNESS := "res://game/tests/isle_house_low_live_evidence_capture.gd"
const CAPTURE_OVERRIDE := "res://override.cfg"
const CAPTURE_OVERRIDE_SHA256 := "edbc0b9caa60fa0fc6b83cebb3145bce11ce0bd976403ca1d2fbe9b7142b39c3"
const PROJECT_SETTINGS_PATH := "res://project.godot"
const PHYSICS_INTERPOLATION_SETTING := "physics/common/physics_interpolation"
const FOCUSED_CONTRACT_PATH := "res://game/tests/headless_d1_b225_live_attachment_contract.gd"
const CANDIDATE_SEAM_PATH := "res://game/tests/support/d1_b225_prepromotion_candidate_seam.gd"
const ADAPTER_PATH := "res://game/scripts/world/facades/d1_b225_live_attachment.gd"
const CONFIG_PATH := "res://game/resources/facades/d1_current/d1_b225_live_attachment.json"
const B225_BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const CHUNK_PATH := "res://generated/world/chunks/x_-2__z_-1.json"
const REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const CATALOG_PATH := "res://discovery/facades/facade-recognition-catalog.json"
const DEFAULT_SUN := Vector3(-52.0, -28.0, 0.0)
const CHANGED_SUN := Vector3(-32.0, 132.0, 0.0)
const CHAIN_START := Vector3(-401.020, 2.507, -196.785)
const CHAIN_END := Vector3(-442.066, 2.169, -175.445)
const CHAIN_TANGENT := Vector3(-0.887252, 0.0, 0.461286)
const CHAIN_OUTWARD := Vector3(-0.461286, 0.0, -0.887252)
const CHAIN_TOTAL_M := 46.261968372
const RUN_JOIN_U_M: Array[float] = [10.372629078, 16.883522872, 23.933383083]
const MOTION_START_U_M := 1.5
const MOTION_END_U_M := 31.0
const MOTION_STANDOFF_M := 12.0
const MOTION_MAX_FRAMES := 600
const MOTION_TELEMETRY_FRAMES := 360
const MOTION_BRAKING_FRAMES := 12
const B225_MOTION_PHYSICS_HZ := 60
const VISUAL_FIXED_FPS := 60
const VISUAL_TRIGGER_TOLERANCE_M := 0.18
const MOTION_INPUT_ACTION := "move_right"
const PHYSICS_SPRAY_SURFACE := 1 << 2
const STILL_FILES := [
	"01-whole-nnw-default.png",
	"02-nnw-oblique.png",
	"03-whole-nnw-changed-light.png",
	"04-whole-nnw-default-grayscale.png",
	"05-clerestory-cladding-close.png",
	"06-real-spray-eligible-host.png",
	"07-protected-return-run0.png",
	"08-b225-surrounding-context.png",
	"09-decoy-b201-current.png",
	"10-decoy-b202-current.png",
	"11-decoy-b258-current.png",
]
const DEPENDENCY_HASHES := {
	PROJECT_SETTINGS_PATH: "305bfb3bf0493c485f48ea8a01d4effccb58d9dd74ad6dc9be78a64ed23981af",
	CONFIG_PATH: "76d66f0c3a5d3ebc99c78208f28df8766a19186fe38bff7118e597a99c55c9ac",
	ADAPTER_PATH: "aed52048bc562f2f07c248bd5f571376611c3870fda1704cbd67de163d4d42ce",
	CANDIDATE_SEAM_PATH: "1f86f10df49500821adf03f4c7b90b5c38cd06a2e6ac97c9c2f1a7169f7e8295",
	FOCUSED_CONTRACT_PATH: "f9a2391893fde5f0f7ba1f04ba7ac04503096bfbad18713ade8ccd69a680ad57",
	B225_BUILDER_PATH: "71e391e4fa58afc83e4bcb99a9f8195e398fdf4064bb09a401fb079e9f30491c",
	B225_PARENT_HARNESS: "47768e4b2d6288b9c3dbb4b0ad19cd870b61a8804d72673c53bf3326f8f5636a",
	"res://game/scenes/main.tscn": "959a0f8a14057ea8402790ba374c7839d5f9835ce20ad194846f0a4d45b43d66",
	"res://game/scripts/main.gd": "14a745ccb0b6eaad4af634e2118ad455071011f4ee556acb05c03408a1fb9b5e",
	"res://game/scripts/world/world_loader.gd": "0bfb5c64ede051dadd87da10e85518a2c22c63d36ff9387e8221bdd0c24287af",
	CHUNK_PATH: "6de57eb30f5771f43b33d7b71b53952be5ea6ec17706102be634a781152a3ee2",
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://game/scripts/player/player_controller.gd": "8b114132d66c78dd0bfd09783c7b9a3a3a441a8b1ae14f33f7308bd9b04ed0ea",
	"res://game/scripts/player/player_camera.gd": "90ea739b25eb6cbcf8bacff072599b117fe894fcef08683483e41527d8019636",
	"res://game/scripts/interaction/spray_controller.gd": "9897042fbffc6740ebe3eb4c19da544a0d437391ded9987318edc7238c403da4",
	"res://game/scripts/interaction/tag_instance_pool.gd": "2460b12b9f70945dc88d2e321b72c1779dab4d867fd80f5920f4734213ce0950",
	"res://game/resources/textures/tag/predefined_tag.svg": "9eb345572cd3298ea14bad008fc6405e46123c0243444e4582393d0aa84af885",
	"res://game/resources/materials/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_v1.tres": "7fa7f3165dee560c48f5a092f317900b87b0876f27bb6a0e937b9c406a8d4ea1",
	"res://game/resources/textures/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_albedo_v1.png": "63e755e9fe5a5dcfb662b4265f1e769fc1b371987b55579b1ca4ffb63015015b",
	"res://game/resources/materials/world/d1_current/shared_dark_glass.tres": "ad8931db8954fd5ebc8fdd809f70afb279dd74a36e53e1d9ca907c44409f10d3",
	"res://game/resources/materials/world/d1_current/shared_pale_frame.tres": "9a2de298ff545cf80c5da0ed0aa37d9d4ebbf10fec8eb78810af7e4d012d1436",
	REGISTRY_PATH: "9c46c1a8c809aa9ded82008d35e9c1b257070e9c61f6d6e41f5650ca7b1c3f27",
	CATALOG_PATH: "a4d9dd474acb09a211f7e0e00d66aeaf7a669927880dd011e24e2f51d13bdd7d",
}


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run_b225")


func _run_b225() -> void:
	var mode := _argument_value("--capture-mode=")
	if mode not in ["preflight", "review-stills", "review-telemetry", "review-motion", "stills", "telemetry", "visual-motion"]:
		_fail("Pass exactly --capture-mode=preflight, review-stills, review-telemetry, review-motion, stills, telemetry, or visual-motion.")
		_finish(null)
		return
	var visual_motion_mode := mode in ["review-motion", "visual-motion"]
	if not _require(_native_runtime_matches(), "B225 evidence requires queried Godot 4.7.2, macOS Metal 4.0 Forward+, exact Apple M2, and a 1440x900 native window/viewport.") \
	or not _require(Vector2i(root.get_texture().get_size()) == STILL_SIZE, "B225 native viewport is not exactly 1440x900.") \
	or not _require(_generator_matches(), "B225 frozen generator SHA argument is absent or stale.") \
	or not _require(_capture_override_matches(), "Temporary capture override is absent or drifted.") \
	or not _require(_dependencies_match(), "B225 candidate dependency closure drifted.") \
	or not _require(_rejection_receipts_match(B225_OUTPUT), "B225 r1/r2 rejection receipts are absent or drifted.") \
	or not _require(_json_numeric_contract_self_test(), "B225 strict JSON integral-number self-test failed.") \
	or not _require(not visual_motion_mode or _visual_fixed_fps_receipt_matches(), "B225 visual motion requires the explicit operator-requested fixed-fps 60 invocation receipt.") \
	or not _require(_output_state_allows(mode), "B225 output state would overwrite or mix capture stages."):
		_finish(null)
		return
	var loaded := await _load_candidate_main()
	if not _require(bool(loaded.get("ok", false)), str(loaded.get("message", "B225 candidate main failed."))):
		_finish(loaded.get("main", null) as Node)
		return
	var main := loaded.main as GameMain
	var world := loaded.world as WorldLoader
	var player := loaded.player as PlayerController
	var hud := loaded.hud as GameHUD
	var sun := loaded.sun as DirectionalLight3D
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.show()
	_clean_hud(hud)
	if mode == "preflight":
		await _preflight(world, player, hud, sun)
	elif mode == "review-stills":
		if _prepare_rehearsal_root():
			await _capture_stills_b225(main, world, player, hud, sun, loaded.bindings as Dictionary, REHEARSAL_OUTPUT, false)
		else:
			_fail("Could not create the exact disposable r3 rehearsal rejection boundary.")
	elif mode == "review-telemetry":
		await _capture_motion_telemetry_b225(world, player, hud, sun, loaded.bindings as Dictionary, REHEARSAL_OUTPUT, false)
	elif mode == "review-motion":
		await _capture_visual_motion_b225(world, player, hud, sun, loaded.bindings as Dictionary, REHEARSAL_OUTPUT, false)
	elif mode == "stills":
		await _capture_stills_b225(main, world, player, hud, sun, loaded.bindings as Dictionary, B225_OUTPUT, true)
	elif mode == "telemetry":
		await _capture_motion_telemetry_b225(world, player, hud, sun, loaded.bindings as Dictionary, B225_OUTPUT, true)
	else:
		await _capture_visual_motion_b225(world, player, hud, sun, loaded.bindings as Dictionary, B225_OUTPUT, true)
	_finish(main)


func _load_candidate_main() -> Dictionary:
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if packed == null:
		return {"ok": false, "message": "Main scene did not load."}
	var main := packed.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var hud := main.get_node("Interface/HUD") as GameHUD
	var sun := main.get_node("Sun") as DirectionalLight3D
	var ready: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, sources: Array) -> void: failures.append({"code": code, "message": message, "sources": sources.duplicate()}))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while ready.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 60000:
		await process_frame
	if not failures.is_empty() or ready.size() != 1:
		return {"ok": false, "message": "Ordinary world did not reach one clean world_ready: %s" % failures, "main": main}
	while not player.was_first_reveal_grounded() and Time.get_ticks_msec() - started < 60000:
		await physics_frame
	if not player.was_first_reveal_grounded() or not player.visible:
		return {"ok": false, "message": "Stock player did not complete ordinary startup grounding.", "main": main}
	var evidence := world.get_runtime_evidence()
	var default_topology := _runtime_topology(evidence)
	if default_topology != CANDIDATE_SEAM.DEFAULT_WORLD_TOPOLOGY or not _world_has_no_candidate(world):
		return {"ok": false, "message": "Canonical world was not exact default-off 7/213: %s" % default_topology, "main": main}
	var application := CANDIDATE_SEAM.apply_candidate(world, CANDIDATE_SEAM.activation_request())
	if not bool(application.get("ok", false)):
		return {"ok": false, "message": "Explicit candidate application failed: %s" % application, "main": main}
	await process_frame
	if _runtime_topology(evidence) != CANDIDATE_SEAM.CANDIDATE_WORLD_TOPOLOGY:
		return {"ok": false, "message": "Candidate topology drifted after explicit apply: %s" % _runtime_topology(evidence), "main": main}
	var bindings := _validate_candidate_bindings(world)
	if not bool(bindings.get("ok", false)):
		return {"ok": false, "message": str(bindings.get("message", "Candidate bindings failed.")), "main": main}
	return {"ok": true, "main": main, "world": world, "player": player, "hud": hud, "sun": sun, "bindings": bindings.metadata}


func _validate_candidate_bindings(world: WorldLoader) -> Dictionary:
	var walls := _record_nodes(world, ADAPTER.RECEIVER_KEY)
	var roofs := _record_nodes(world, ADAPTER.ROOF_KEY)
	if walls.size() != 1 or roofs.size() != 1:
		return {"ok": false, "message": "Expected one exact B225 wall/roof, got %d/%d." % [walls.size(), roofs.size()]}
	var wall := walls[0]
	var roof := roofs[0]
	var attachment := wall.get_node_or_null("D1B225PrepromotionCandidateAttachment") as Node3D
	var mesh_instance := wall.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var body := wall.get_node_or_null("Collision") as StaticBody3D
	var shape := wall.get_node_or_null("Collision/Shape") as CollisionShape3D
	var material := mesh.surface_get_material(1) as StandardMaterial3D if mesh != null and mesh.get_surface_count() == 2 else null
	var roof_mesh_instance := roof.get_node_or_null("Mesh") as MeshInstance3D
	var roof_body := roof.get_node_or_null("Collision") as StaticBody3D
	var roof_shape := roof.get_node_or_null("Collision/Shape") as CollisionShape3D
	if attachment == null or mesh == null or body == null or shape == null \
	or roof_mesh_instance == null or roof_body == null or roof_shape == null \
	or not wall.has_meta(CANDIDATE_SEAM.APPLIED_META) or not world.has_meta(CANDIDATE_SEAM.APPLIED_META) \
	or mesh.get_surface_count() != 2 or _surface_triangles(mesh, 0) != 20 or _surface_triangles(mesh, 1) != 8 \
	or mesh.surface_get_name(0) != "generated_record_protected_runs_0_9" \
	or mesh.surface_get_name(1) != "d1_b225_nnw_runs_10_13" \
	or material == null or material.resource_path != "res://game/resources/materials/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_v1.tres" \
	or material.albedo_texture == null or material.albedo_texture.resource_path != "res://game/resources/textures/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_albedo_v1.png" \
	or not material.uv1_scale.is_equal_approx(Vector3(0.125, 0.28735632, 1.0)) \
	or _count_type(attachment, MultiMeshInstance3D) != 2 or _count_type(attachment, CollisionObject3D) != 0 \
	or _count_type(attachment, CollisionShape3D) != 0 or _count_type(attachment, NavigationRegion3D) != 0 or _count_type(attachment, Decal) != 0 \
	or not body.is_in_group("spray_receiver_wall") or body.collision_layer != ((1 << 0) | PHYSICS_SPRAY_SURFACE) \
	or str(body.get_meta("derived_object_key", "")) != ADAPTER.RECEIVER_KEY or body.get_meta("source_keys", []) != [ADAPTER.SOURCE_KEY] \
	or roof.get_node_or_null("D1B225PrepromotionCandidateAttachment") != null \
	or _count_type(roof, MeshInstance3D) != 1 or _count_type(roof, StaticBody3D) != 1 or _count_type(roof, CollisionShape3D) != 1:
		return {"ok": false, "message": "B225 candidate host/material/detail/ownership binding drifted."}
	var candidate_meta := world.get_meta(CANDIDATE_SEAM.APPLIED_META, {}) as Dictionary
	if str(candidate_meta.get("stage", "")) != "prepromotion_live_ab_only" \
	or bool(candidate_meta.get("canonical_entrypoint_reachable", true)) \
	or bool(candidate_meta.get("recognition_credit", true)):
		return {"ok": false, "message": "B225 candidate lifecycle metadata drifted."}
	var postcommit_node_ids := {
		"host_mesh_instance_id": mesh_instance.get_instance_id(),
		"host_body_instance_id": body.get_instance_id(),
		"host_shape_instance_id": shape.get_instance_id(),
		"roof_mesh_instance_id": roof_mesh_instance.get_instance_id(),
		"roof_body_instance_id": roof_body.get_instance_id(),
		"roof_shape_instance_id": roof_shape.get_instance_id(),
	}
	for key: String in postcommit_node_ids:
		if int(candidate_meta.get(key, 0)) != int(postcommit_node_ids[key]):
			return {"ok": false, "message": "B225 within-process preserved node identity drifted for %s." % key}
	var ordinary_mesh_id := int(candidate_meta.get("ordinary_host_array_mesh_instance_id", 0))
	var candidate_mesh_id := mesh.get_instance_id()
	if ordinary_mesh_id == 0 or candidate_mesh_id == 0 or ordinary_mesh_id == candidate_mesh_id:
		return {"ok": false, "message": "B225 ordinary/candidate ArrayMesh resource identity relation drifted."}
	var preserved_receipt := candidate_meta.duplicate(true)
	for key: String in ["host_mesh_instance_id", "host_body_instance_id", "host_shape_instance_id", "ordinary_host_array_mesh_instance_id", "roof_mesh_instance_id", "roof_body_instance_id", "roof_shape_instance_id"]:
		preserved_receipt[key] = str(int(candidate_meta[key]))
	var postcommit_node_id_receipt := {}
	for key: String in postcommit_node_ids:
		postcommit_node_id_receipt[key] = str(int(postcommit_node_ids[key]))
	preserved_receipt["postcommit_node_instance_ids"] = postcommit_node_id_receipt
	preserved_receipt["candidate_host_array_mesh_instance_id"] = str(candidate_mesh_id)
	preserved_receipt["object_id_encoding"] = "canonical_signed_decimal_strings_to_avoid_json_binary64_precision_loss"
	preserved_receipt["object_id_relation_scope"] = "single_candidate_process_precommit_metadata_to_postcommit_live_nodes_only"
	preserved_receipt["all_six_preserved_node_instance_ids_equal_before_after"] = true
	preserved_receipt["ordinary_and_candidate_array_mesh_instance_ids_unequal"] = true
	preserved_receipt["cross_stage_object_id_equality_claimed"] = false
	return {"ok": true, "metadata": {
		"wall_root_path": str(wall.get_path()), "roof_root_path": str(roof.get_path()),
		"attachment_path": str(attachment.get_path()), "wall_body_path": str(body.get_path()),
		"source_keys": [ADAPTER.SOURCE_KEY], "receiver_key": ADAPTER.RECEIVER_KEY,
		"candidate_id": CANDIDATE_SEAM.CANDIDATE_ID, "candidate_stage": "prepromotion_live_ab_only",
		"canonical_entrypoint_reachable": false, "recognition_credit": false,
		"host_triangles": 28, "eligible_cladding_triangles": 8, "protected_generic_triangles": 20,
		"decorative_batches": 2, "decorative_boxes": 90, "decorative_triangles": 1080,
		"structural_body_count": 1, "structural_shape_count": 1, "spray_owner_count": 1,
		"navigation_owner_count": 0, "candidate_topology": CANDIDATE_SEAM.CANDIDATE_WORLD_TOPOLOGY.duplicate(true),
		"preserved_instance_ids": preserved_receipt,
	}}


func _preflight(world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D) -> void:
	if not _require(sun.rotation_degrees.is_equal_approx(DEFAULT_SUN), "Default sun drifted before B225 preflight."):
		return
	var record := _wall_record(CHUNK_PATH, ADAPTER.RECEIVER_KEY)
	var views := _b225_views(record)
	for view_value: Variant in views:
		var view := view_value as Dictionary
		var pose := await _settle_and_aim(world, player, hud, view.requested_xz as Vector2, view.aim_target as Vector3, str(view.id), float(view.get("minimum_actual_spring_m", 2.0)))
		if not _require(bool(pose.get("ok", false)), str(pose.get("message", "%s pose failed." % view.id))):
			return
		var los := _center_los(player, view.aim_target as Vector3, str(view.expected_receiver), view.expected_sources as Array, str(view.id))
		if not _require(bool(los.get("ok", false)), str(los.get("message", "%s LOS failed." % view.id))):
			return
		if str(view.id) == "01-whole-nnw-default" and not _require(bool(_whole_projection(player.get_camera(), record).get("ok", false)), "Whole NNW projection did not contain the complete candidate chain."):
			return
	var decoys := await _preflight_decoys(world, player, hud)
	if not _require(bool(decoys.get("ok", false)), str(decoys.get("message", "Decoy preflight failed."))):
		return
	var telemetry := await _run_consecutive_motion_telemetry(world, player, hud)
	if not _require(bool(telemetry.get("ok", false)), str(telemetry.get("message", "Motion telemetry rehearsal failed."))):
		return
	print("PASS: B225 r3 no-write preflight resolved all still/decoy poses and exactly 360 consecutive post-PlayerController real-controller movement ticks crossing all three joins at 60 Hz")


func _run_consecutive_motion_telemetry(world: WorldLoader, player: PlayerController, hud: GameHUD) -> Dictionary:
	if Engine.physics_ticks_per_second != B225_MOTION_PHYSICS_HZ:
		return {"ok": false, "message": "B225 telemetry physics ticks are not exactly 60 Hz."}
	var requested := _chain_point(MOTION_START_U_M, 0.0) + Vector2(CHAIN_OUTWARD.x, CHAIN_OUTWARD.z) * MOTION_STANDOFF_M
	var target := _chain_point_3d(MOTION_START_U_M, 4.3)
	var pose := await _settle_and_aim(world, player, hud, requested, target, "telemetry-motion-start", 2.0)
	if not bool(pose.get("ok", false)):
		return pose
	if not _camera_hit_matches(player, ADAPTER.RECEIVER_KEY):
		return {"ok": false, "message": "B225 telemetry start center ray missed the exact host."}
	var recoveries_before := world.get_runtime_evidence().recovery_count
	var camera_basis := player.get_camera().global_basis
	var camera_right_dot_chain := _motion_camera_right_dot_chain(player)
	if camera_right_dot_chain < 0.9999:
		return {"ok": false, "message": "B225 telemetry camera right does not align +chain tangent: dot=%.6f." % camera_right_dot_chain}
	_clear_input()
	_clean_hud(hud)
	var sampler_result := _start_post_player_sampler(player)
	if not bool(sampler_result.get("ok", false)):
		return sampler_result
	var sampler := sampler_result.sampler as PostPlayerPhysicsSampler
	player.set_gameplay_enabled(true)
	var baseline_value: Variant = await sampler.post_player_physics_tick
	var baseline := baseline_value as Dictionary
	var start_u := _player_chain_u(player)
	var baseline_state := _motion_state(world, player, camera_basis, recoveries_before, start_u, false)
	if not _post_player_snapshot_matches(baseline, player) or not bool(baseline_state.get("ok", false)):
		_stop_motion_sampling(player, sampler)
		return {"ok": false, "message": "B225 telemetry post-player baseline failed: %s" % str(baseline_state.get("message", "snapshot incoherent"))}
	var start_position := player.global_position
	var start_physics_frame := int(baseline.engine_physics_frame)
	var baseline_sampler_sequence := int(baseline.sampler_sequence_index)
	var previous_physics_frame := start_physics_frame
	var previous_u := start_u
	var samples: Array[Dictionary] = []
	var joins_crossed: Array[Dictionary] = []
	Input.action_press(MOTION_INPUT_ACTION)
	for frame_index in MOTION_TELEMETRY_FRAMES:
		var snapshot_value: Variant = await sampler.post_player_physics_tick
		var snapshot := snapshot_value as Dictionary
		var physics_frame_now := int(snapshot.get("engine_physics_frame", -1))
		var state := _motion_state(world, player, camera_basis, recoveries_before, previous_u, true)
		if physics_frame_now != previous_physics_frame + 1 \
		or physics_frame_now != start_physics_frame + frame_index + 1 \
		or int(snapshot.get("sampler_sequence_index", -1)) != baseline_sampler_sequence + frame_index + 1 \
		or not _post_player_snapshot_matches(snapshot, player) or not bool(state.get("ok", false)):
			_stop_motion_sampling(player, sampler)
			return {"ok": false, "message": "B225 consecutive telemetry failed at sample %d: engine frame %d after %d; %s" % [frame_index + 1, physics_frame_now, previous_physics_frame, str(state.get("message", "state failed"))]}
		var metadata := state.metadata as Dictionary
		metadata["sample_index"] = frame_index + 1
		metadata["engine_physics_frame"] = physics_frame_now
		metadata["engine_frame_delta"] = 1
		metadata["sampler_sequence_index"] = int(snapshot.sampler_sequence_index)
		metadata["sampled_after_player_physics_process"] = true
		samples.append(metadata)
		var u := float(metadata.chain_u_m)
		for join_index in RUN_JOIN_U_M.size():
			var join_u := RUN_JOIN_U_M[join_index]
			if previous_u < join_u and u >= join_u:
				joins_crossed.append({"join_index": join_index + 1, "join_u_m": join_u, "previous_sample_index": frame_index, "current_sample_index": frame_index + 1, "previous_engine_physics_frame": previous_physics_frame, "current_engine_physics_frame": physics_frame_now, "previous_u_m": previous_u, "current_u_m": u})
		previous_u = u
		previous_physics_frame = physics_frame_now
	var input_end_physics_frame := previous_physics_frame
	var input_end_position := player.global_position
	var input_end_u := _player_chain_u(player)
	Input.action_release(MOTION_INPUT_ACTION)
	var braking_samples: Array[Dictionary] = []
	for braking_index in MOTION_BRAKING_FRAMES:
		var snapshot_value: Variant = await sampler.post_player_physics_tick
		var snapshot := snapshot_value as Dictionary
		var physics_frame_now := int(snapshot.get("engine_physics_frame", -1))
		var state := _motion_state(world, player, camera_basis, recoveries_before, previous_u, false)
		if physics_frame_now != previous_physics_frame + 1 \
		or int(snapshot.get("sampler_sequence_index", -1)) != baseline_sampler_sequence + MOTION_TELEMETRY_FRAMES + braking_index + 1 \
		or not _post_player_snapshot_matches(snapshot, player) or not bool(state.get("ok", false)):
			_stop_motion_sampling(player, sampler)
			return {"ok": false, "message": "B225 braking telemetry failed at sample %d: engine frame %d after %d; %s" % [braking_index + 1, physics_frame_now, previous_physics_frame, str(state.get("message", "state failed"))]}
		var metadata := state.metadata as Dictionary
		metadata["braking_sample_index"] = braking_index + 1
		metadata["engine_physics_frame"] = physics_frame_now
		metadata["engine_frame_delta"] = 1
		metadata["sampler_sequence_index"] = int(snapshot.sampler_sequence_index)
		metadata["sampled_after_player_physics_process"] = true
		braking_samples.append(metadata)
		previous_u = float(metadata.chain_u_m)
		previous_physics_frame = physics_frame_now
	_stop_motion_sampling(player, sampler)
	var input_displacement := Vector2(input_end_position.x - start_position.x, input_end_position.z - start_position.z).length()
	if input_end_physics_frame - start_physics_frame != MOTION_TELEMETRY_FRAMES \
	or samples.size() != MOTION_TELEMETRY_FRAMES or braking_samples.size() != MOTION_BRAKING_FRAMES \
	or joins_crossed.size() != RUN_JOIN_U_M.size() or input_end_u <= RUN_JOIN_U_M[-1] \
	or input_end_u >= MOTION_END_U_M or world.get_runtime_evidence().recovery_count != recoveries_before:
		return {"ok": false, "message": "B225 telemetry closure failed: input ticks=%d samples=%d braking=%d joins=%d end_u=%.3f recovery_delta=%d." % [input_end_physics_frame - start_physics_frame, samples.size(), braking_samples.size(), joins_crossed.size(), input_end_u, world.get_runtime_evidence().recovery_count - recoveries_before]}
	return {"ok": true, "metadata": {
		"pose": pose.metadata, "input_action": MOTION_INPUT_ACTION,
		"input_baseline_engine_physics_frame": start_physics_frame,
		"input_baseline_player_position_m": _vector3(start_position), "input_baseline_chain_u_m": start_u,
		"input_baseline_sampler_sequence_index": baseline_sampler_sequence,
		"input_start_engine_physics_frame": start_physics_frame, "input_end_engine_physics_frame": input_end_physics_frame,
		"input_movement_ticks_from_baseline_to_sample_360": input_end_physics_frame - start_physics_frame,
		"input_sample_1_to_360_endpoint_intervals": MOTION_TELEMETRY_FRAMES - 1,
		"input_elapsed_physics_ticks": input_end_physics_frame - start_physics_frame,
		"input_duration_seconds": float(input_end_physics_frame - start_physics_frame) / B225_MOTION_PHYSICS_HZ,
		"input_sample_count": samples.size(), "all_input_engine_frame_deltas_exactly_one": true,
		"sampler_phase": "dedicated_node_physics_callback_strictly_after_player_controller",
		"player_process_physics_priority": player.process_physics_priority,
		"sampler_process_physics_priority": int(sampler_result.sampler_process_physics_priority),
		"sampler_priority_strictly_after_player": true, "all_samples_after_player_physics_process": true,
		"start_position_m": _vector3(start_position), "input_end_position_m": _vector3(input_end_position),
		"start_chain_u_m": start_u, "input_end_chain_u_m": input_end_u, "input_horizontal_displacement_m": input_displacement,
		"joins_crossed": joins_crossed, "all_three_run_joins_crossed": true,
		"chain_u_monotonic_non_decreasing": true, "camera_planar_right_dot_chain_tangent": camera_right_dot_chain,
		"player_transform_writes_after_input_began": 0, "camera_transform_writes_after_input_began": 0,
		"all_input_samples_grounded": true, "all_input_samples_in_boundary": true, "all_input_center_hits_exact_receiver": true,
		"recovery_delta": 0, "samples": samples,
		"input_release_engine_physics_frame": input_end_physics_frame,
		"braking_sample_count": braking_samples.size(), "braking_samples_recorded_separately": true,
		"all_braking_engine_frame_deltas_exactly_one": true, "braking_samples": braking_samples,
		"post_braking_position_m": _vector3(player.global_position), "post_braking_chain_u_m": _player_chain_u(player),
	}}


func _start_post_player_sampler(player: PlayerController) -> Dictionary:
	var sampler := PostPlayerPhysicsSampler.new()
	sampler.name = "B225PostPlayerPhysicsSampler"
	sampler.configure(player, CHAIN_START, CHAIN_TANGENT)
	if sampler.process_physics_priority <= player.process_physics_priority:
		sampler.queue_free()
		return {"ok": false, "message": "B225 post-player sampler priority does not run after PlayerController."}
	player.get_parent().add_child(sampler)
	return {
		"ok": true,
		"sampler": sampler,
		"player_process_physics_priority": player.process_physics_priority,
		"sampler_process_physics_priority": sampler.process_physics_priority,
	}


func _post_player_snapshot_matches(snapshot: Dictionary, player: PlayerController) -> bool:
	var values := snapshot.get("player_position_m", []) as Array
	if values.size() != 3 or int(snapshot.get("engine_physics_frame", -1)) != Engine.get_physics_frames():
		return false
	var sampled_position := Vector3(float(values[0]), float(values[1]), float(values[2]))
	return sampled_position.is_equal_approx(player.global_position) \
		and absf(float(snapshot.get("chain_u_m", INF)) - _player_chain_u(player)) <= 0.0001


func _stop_motion_sampling(player: PlayerController, sampler: PostPlayerPhysicsSampler) -> void:
	Input.action_release(MOTION_INPUT_ACTION)
	player.set_gameplay_enabled(false)
	if is_instance_valid(sampler):
		sampler.set_physics_process(false)
		sampler.queue_free()


func _motion_state(world: WorldLoader, player: PlayerController, camera_basis: Basis, recoveries_before: int, previous_u: float, input_must_be_pressed: bool) -> Dictionary:
	var u := _player_chain_u(player)
	var collider := _camera_hit_collider(player)
	var input_pressed := Input.is_action_pressed(MOTION_INPUT_ACTION)
	if not player.is_on_floor() or not world.get_boundary().contains_position(player.global_position) \
	or input_pressed != input_must_be_pressed or Input.is_action_pressed("run") or Input.is_action_pressed("jetpack") or Input.is_action_pressed("recover") \
	or not player.get_camera().global_basis.is_equal_approx(camera_basis) \
	or world.get_runtime_evidence().recovery_count != recoveries_before or u < previous_u - 0.0001 \
	or collider == null or str(collider.get_meta("derived_object_key", "")) != ADAPTER.RECEIVER_KEY \
	or collider.get_meta("source_keys", []) != [ADAPTER.SOURCE_KEY]:
		return {"ok": false, "message": "state drift at u=%.3f grounded=%s in_boundary=%s input=%s recovery_delta=%d collider=%s" % [u, player.is_on_floor(), world.get_boundary().contains_position(player.global_position), input_pressed, world.get_runtime_evidence().recovery_count - recoveries_before, str(collider)]}
	return {"ok": true, "metadata": {
		"player_position_m": _vector3(player.global_position), "chain_u_m": u, "velocity_mps": _vector3(player.velocity),
		"grounded": true, "in_boundary": true, "input_action_pressed": input_pressed, "camera_basis_unchanged": true,
		"center_first_hit_object": ADAPTER.RECEIVER_KEY, "center_first_hit_sources": collider.get_meta("source_keys", []),
	}}


func _capture_stills_b225(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, bindings: Dictionary, output_root: String, authoritative: bool) -> void:
	var absolute := ProjectSettings.globalize_path(output_root)
	if not _require(DirAccess.make_dir_recursive_absolute(absolute.path_join("images")) == OK, "Could not create B225 candidate evidence root."):
		return
	var record := _wall_record(CHUNK_PATH, ADAPTER.RECEIVER_KEY)
	var views := _b225_views(record)
	var captures: Array[Dictionary] = []
	var whole := views[0] as Dictionary
	var pose := await _settle_and_aim(world, player, hud, whole.requested_xz as Vector2, whole.aim_target as Vector3, str(whole.id), 2.0)
	if not _require(bool(pose.get("ok", false)), str(pose.get("message", "Whole pose failed."))):
		return
	var los := _center_los(player, whole.aim_target as Vector3, ADAPTER.RECEIVER_KEY, [ADAPTER.SOURCE_KEY], str(whole.id))
	var projection := _whole_projection(player.get_camera(), record)
	if not _require(bool(los.get("ok", false)) and bool(projection.get("ok", false)), "Whole NNW LOS/projection failed."):
		return
	var extra := pose.metadata as Dictionary
	extra.merge(los.metadata as Dictionary, true)
	extra["whole_chain_projection"] = projection
	extra["sun_rotation_degrees"] = _vector3(sun.rotation_degrees)
	var saved := await _save_candidate_still(main, player, hud, output_root, "01-whole-nnw-default", "grounded_stock_player_whole_candidate_nnw", "world_default", extra)
	if not _append_saved(captures, saved): return
	var frozen_player := player.global_transform
	var frozen_camera := player.get_camera().global_transform
	sun.rotation_degrees = CHANGED_SUN
	extra = extra.duplicate(true)
	extra["same_pose_as"] = "01-whole-nnw-default"
	extra["sun_rotation_degrees"] = _vector3(sun.rotation_degrees)
	extra["player_transform_exactly_reused"] = player.global_transform.is_equal_approx(frozen_player)
	extra["camera_transform_exactly_reused"] = player.get_camera().global_transform.is_equal_approx(frozen_camera)
	saved = await _save_candidate_still(main, player, hud, output_root, "03-whole-nnw-changed-light", "same_grounded_stock_player_pose_changed_light", "frozen_changed_light", extra)
	if not _append_saved(captures, saved): return
	var grayscale := _save_grayscale_b225(output_root, "images/01-whole-nnw-default.png", "images/04-whole-nnw-default-grayscale.png")
	if not _append_saved(captures, grayscale): return
	sun.rotation_degrees = DEFAULT_SUN
	for index in range(1, views.size()):
		var view := views[index] as Dictionary
		pose = await _settle_and_aim(world, player, hud, view.requested_xz as Vector2, view.aim_target as Vector3, str(view.id), float(view.get("minimum_actual_spring_m", 2.0)))
		if not _require(bool(pose.get("ok", false)), str(pose.get("message", "%s pose failed." % view.id))): return
		los = _center_los(player, view.aim_target as Vector3, str(view.expected_receiver), view.expected_sources as Array, str(view.id))
		if not _require(bool(los.get("ok", false)), str(los.get("message", "%s LOS failed." % view.id))): return
		extra = pose.metadata as Dictionary
		extra.merge(los.metadata as Dictionary, true)
		extra["sun_rotation_degrees"] = _vector3(sun.rotation_degrees)
		if str(view.id) == "06-real-spray-eligible-host":
			var spray := await _place_real_spray(main, world, player, hud)
			if not _require(bool(spray.get("ok", false)), str(spray.get("message", "Real spray failed."))): return
			extra.merge(spray.metadata as Dictionary, true)
		saved = await _save_candidate_still(main, player, hud, output_root, str(view.id), str(view.role), "world_default", extra)
		if not _append_saved(captures, saved): return
	var decoy_captures := await _capture_decoys(main, world, player, hud, output_root)
	if not _require(bool(decoy_captures.get("ok", false)), str(decoy_captures.get("message", "Decoy captures failed."))): return
	captures.append_array(decoy_captures.captures as Array)
	var manifest := {
		"schema_version": "ti.d1-b225-prepromotion-candidate-static-evidence/3",
		"review_status": "pending_independent_pass_for_promotion_review_not_self_accepted",
		"recognition_status": "not_promoted_not_credited",
		"recognition_metric_frozen": "7/213",
		"candidate_stage": "prepromotion_live_ab_only",
		"authoritative_r3_evidence": authoritative,
		"canonical_default_world_topology": CANDIDATE_SEAM.DEFAULT_WORLD_TOPOLOGY.duplicate(true),
		"explicit_candidate_world_topology": CANDIDATE_SEAM.CANDIDATE_WORLD_TOPOLOGY.duplicate(true),
		"generator": B225_GENERATOR.trim_prefix("res://"), "generator_sha256": FileAccess.get_sha256(B225_GENERATOR),
		"frozen_generator_sha256_argument": _argument_value("--generator-sha256="),
		"capture_override_sha256": FileAccess.get_sha256(CAPTURE_OVERRIDE),
		"runtime_environment": _runtime_environment_receipt_b225(),
		"source_dependency_hashes": DEPENDENCY_HASHES.duplicate(true),
		"r1_rejection_record": {"file": "r1-rejection.json", "sha256": R1_REJECTION_SHA256},
		"r2_rejection_record": {"file": "r2-rejection.json", "sha256": R2_REJECTION_SHA256},
		"bindings": bindings, "captures": captures, "capture_count": captures.size(),
		"activation": CANDIDATE_SEAM.activation_request(),
		"activation_count": 1, "ordinary_world_loaded_before_activation": true,
		"canonical_entrypoint_reachable": false, "catalog_or_registry_promotion": false, "recognition_credit": false,
		"grayscale_derivation": "lossless default PNG reload, Image FORMAT_L8 conversion, PNG save; no crop, relight, or geometry change",
		"pose_method_disclosure": "after real startup grounding and the single explicit candidate transition, the harness performs one pre-capture player placement and input-reachable stock-camera aim per still; no pose writes occur during each saved render",
		"source_photography_shipped": false, "source_urls_in_runtime": false,
		"visual_verdict": "pending_independent_review",
		"nonclaims": ["recognition credit before production promotion and fresh postpromotion evidence", "perfect texture tiling", "exact pane count, cadence, damage, lower openings, entries, other sides, roof equipment, interior, or as-built realism"],
	}
	if not _write_new_json(output_root.path_join("capture-manifest.json"), manifest):
		_fail("Could not write B225 static manifest.")
		return
	_copy_capture_override(output_root)
	if not _sealed_static_stage_matches(output_root, "static", authoritative):
		_fail("B225 static stage failed its immediate persisted disk validator.")
		return
	print("PASS: captured eleven fresh B225 prepromotion candidate stills at 1440x900; review may authorize promotion but cannot grant recognition credit")


func _capture_motion_telemetry_b225(world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, bindings: Dictionary, output_root: String, authoritative: bool) -> void:
	sun.rotation_degrees = DEFAULT_SUN
	var result := await _run_consecutive_motion_telemetry(world, player, hud)
	if not _require(bool(result.get("ok", false)), str(result.get("message", "B225 telemetry capture failed."))):
		return
	var manifest := {
		"schema_version": "ti.d1-b225-prepromotion-candidate-consecutive-telemetry/3",
		"review_status": "pending_independent_pass_for_promotion_review_not_self_accepted",
		"recognition_status": "not_promoted_not_credited", "recognition_metric_frozen": "7/213",
		"authoritative_r3_evidence": authoritative,
		"proof_role": "baseline_then_exact_360_consecutive_post_player_physics_real_controller_movement_samples_without_render_or_file_io_awaits",
		"generator": B225_GENERATOR.trim_prefix("res://"), "generator_sha256": FileAccess.get_sha256(B225_GENERATOR),
		"frozen_generator_sha256_argument": _argument_value("--generator-sha256="),
		"capture_override_sha256": FileAccess.get_sha256(CAPTURE_OVERRIDE), "runtime_environment": _runtime_environment_receipt_b225(),
		"source_dependency_hashes": DEPENDENCY_HASHES.duplicate(true), "bindings": bindings,
		"runtime_topology": CANDIDATE_SEAM.CANDIDATE_WORLD_TOPOLOGY.duplicate(true),
		"r1_rejection_record": {"file": "r1-rejection.json", "sha256": R1_REJECTION_SHA256},
		"r2_rejection_record": {"file": "r2-rejection.json", "sha256": R2_REJECTION_SHA256},
		"run_action_pressed": false, "jetpack_action_pressed": false, "recovery_action_pressed": false,
		"telemetry_contains_render_awaits": false, "telemetry_contains_image_or_file_writes_before_manifest": false,
		"scene_tree_physics_frame_signal_used_as_post_player_sampler": false,
		"canonical_entrypoint_reachable": false, "catalog_or_registry_promotion": false, "recognition_credit": false,
		"visual_verdict": "pending_independent_review",
	}
	manifest.merge(result.metadata as Dictionary, true)
	if not _write_new_json(output_root.path_join("motion-telemetry.json"), manifest):
		_fail("Could not write B225 consecutive telemetry manifest.")
		return
	if not _sealed_static_stage_matches(output_root, "telemetry", authoritative) \
	or not _sealed_telemetry_stage_matches(output_root, "telemetry", authoritative):
		_fail("B225 telemetry stage failed its immediate persisted disk validator.")
		return
	print("PASS: wrote exact 360-tick / 6.0 s consecutive B225 controller telemetry with three true join brackets and separately recorded braking")


func _capture_visual_motion_b225(world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, bindings: Dictionary, output_root: String, authoritative: bool) -> void:
	if Engine.physics_ticks_per_second != B225_MOTION_PHYSICS_HZ:
		_fail("B225 visual motion physics ticks are not exactly 60 Hz.")
		return
	sun.rotation_degrees = DEFAULT_SUN
	var requested := _chain_point(MOTION_START_U_M, 0.0) + Vector2(CHAIN_OUTWARD.x, CHAIN_OUTWARD.z) * MOTION_STANDOFF_M
	var target := _chain_point_3d(MOTION_START_U_M, 4.3)
	var pose := await _settle_and_aim(world, player, hud, requested, target, "visual-motion-start", 2.0)
	if not _require(bool(pose.get("ok", false)), str(pose.get("message", "Visual motion start failed."))) \
	or not _require(_camera_hit_matches(player, ADAPTER.RECEIVER_KEY), "Visual motion start center ray missed B225."):
		return
	var thresholds := _motion_frame_thresholds()
	var captured: Array[Dictionary] = []
	var observations: Array[Dictionary] = []
	var next_threshold := 0
	var recoveries_before := world.get_runtime_evidence().recovery_count
	var camera_basis := player.get_camera().global_basis
	var camera_right_dot_chain := _motion_camera_right_dot_chain(player)
	if not _require(camera_right_dot_chain >= 0.9999, "B225 visual motion camera right does not align +chain tangent: dot=%.6f." % camera_right_dot_chain):
		return
	_clear_input()
	_clean_hud(hud)
	var sampler_result := _start_post_player_sampler(player)
	if not _require(bool(sampler_result.get("ok", false)), str(sampler_result.get("message", "B225 visual sampler failed."))):
		return
	var sampler := sampler_result.sampler as PostPlayerPhysicsSampler
	player.set_gameplay_enabled(true)
	var baseline_value: Variant = await sampler.post_player_physics_tick
	var baseline := baseline_value as Dictionary
	var previous_u := _player_chain_u(player)
	var baseline_state := _motion_state(world, player, camera_basis, recoveries_before, previous_u, false)
	if not _post_player_snapshot_matches(baseline, player) or not bool(baseline_state.get("ok", false)):
		_stop_motion_sampling(player, sampler)
		_fail("B225 visual post-player baseline failed: %s" % str(baseline_state.get("message", "snapshot incoherent")))
		return
	var start_position := player.global_position
	var start_physics_frame := int(baseline.engine_physics_frame)
	var baseline_sampler_sequence := int(baseline.sampler_sequence_index)
	var last_observed_physics_frame := start_physics_frame
	var last_sampler_sequence := baseline_sampler_sequence
	var motion_dir := output_root.path_join("visual-motion-frames")
	if not _require(not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(motion_dir)), "B225 visual motion directory already exists.") \
	or not _require(DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(motion_dir)) == OK, "Could not create B225 visual motion frame directory."):
		_stop_motion_sampling(player, sampler)
		return
	Input.action_press(MOTION_INPUT_ACTION)
	for outer_iteration in MOTION_MAX_FRAMES:
		var trigger_snapshot_value: Variant = await sampler.post_player_physics_tick
		var trigger_snapshot := trigger_snapshot_value as Dictionary
		var trigger_frame := int(trigger_snapshot.get("engine_physics_frame", -1))
		var trigger_sequence := int(trigger_snapshot.get("sampler_sequence_index", -1))
		var trigger_state := _motion_state(world, player, camera_basis, recoveries_before, previous_u, true)
		if trigger_frame <= last_observed_physics_frame or trigger_sequence <= last_sampler_sequence \
		or not _post_player_snapshot_matches(trigger_snapshot, player) or not bool(trigger_state.get("ok", false)):
			_stop_motion_sampling(player, sampler)
			_fail("B225 visual motion trigger state failed at iteration %d: frame=%d previous=%d %s" % [outer_iteration + 1, trigger_frame, last_observed_physics_frame, str(trigger_state.get("message", "state failed"))])
			return
		var trigger_u := float((trigger_state.metadata as Dictionary).chain_u_m)
		observations.append({"outer_iteration": outer_iteration + 1, "engine_physics_frame": trigger_frame, "engine_tick_gap_from_previous_observation": trigger_frame - last_observed_physics_frame, "sampler_sequence_index": trigger_sequence, "sampler_sequence_gap_from_previous_observation": trigger_sequence - last_sampler_sequence, "chain_u_m": trigger_u, "event": "post_player_physics_sampler_trigger_check"})
		previous_u = trigger_u
		last_observed_physics_frame = trigger_frame
		last_sampler_sequence = trigger_sequence
		if next_threshold < thresholds.size() and trigger_u >= float((thresholds[next_threshold] as Dictionary).trigger_u_m):
			var threshold := thresholds[next_threshold] as Dictionary
			await RenderingServer.frame_post_draw
			var rendered_snapshot := sampler.latest_snapshot.duplicate(true)
			var rendered_physics_frame := int(rendered_snapshot.get("engine_physics_frame", -1))
			var rendered_sampler_sequence := int(rendered_snapshot.get("sampler_sequence_index", -1))
			var rendered_state := _motion_state(world, player, camera_basis, recoveries_before, previous_u, true)
			if rendered_physics_frame < trigger_frame or rendered_sampler_sequence < trigger_sequence \
			or not _post_player_snapshot_matches(rendered_snapshot, player) or not bool(rendered_state.get("ok", false)):
				_stop_motion_sampling(player, sampler)
				_fail("B225 post-render visual state failed for threshold %d: frame=%d trigger=%d %s" % [next_threshold + 1, rendered_physics_frame, trigger_frame, str(rendered_state.get("message", "state failed"))])
				return
			var rendered_metadata := rendered_state.metadata as Dictionary
			var rendered_u := float(rendered_metadata.chain_u_m)
			var frame_result := _save_visual_motion_frame(output_root, threshold, trigger_frame, trigger_sequence, trigger_u, rendered_physics_frame, rendered_sampler_sequence, rendered_u, rendered_metadata.player_position_m as Array)
			if not bool(frame_result.get("ok", false)):
				_stop_motion_sampling(player, sampler)
				_fail(str(frame_result.get("message", "Visual motion frame save failed.")))
				return
			captured.append(frame_result.metadata)
			next_threshold += 1
			previous_u = rendered_u
			last_observed_physics_frame = rendered_physics_frame
			last_sampler_sequence = rendered_sampler_sequence
		if next_threshold == thresholds.size() and previous_u >= MOTION_END_U_M:
			break
	var input_end_physics_frame := last_observed_physics_frame
	var input_end_position := player.global_position
	var input_end_u := _player_chain_u(player)
	Input.action_release(MOTION_INPUT_ACTION)
	var braking_samples: Array[Dictionary] = []
	for braking_index in MOTION_BRAKING_FRAMES:
		var snapshot_value: Variant = await sampler.post_player_physics_tick
		var snapshot := snapshot_value as Dictionary
		var physics_frame_now := int(snapshot.get("engine_physics_frame", -1))
		var sampler_sequence_now := int(snapshot.get("sampler_sequence_index", -1))
		var state := _motion_state(world, player, camera_basis, recoveries_before, previous_u, false)
		if physics_frame_now <= last_observed_physics_frame or sampler_sequence_now <= last_sampler_sequence \
		or not _post_player_snapshot_matches(snapshot, player) or not bool(state.get("ok", false)):
			_stop_motion_sampling(player, sampler)
			_fail("B225 visual braking state failed at sample %d." % (braking_index + 1))
			return
		var metadata := state.metadata as Dictionary
		braking_samples.append({"braking_sample_index": braking_index + 1, "engine_physics_frame": physics_frame_now, "engine_tick_gap_from_previous_observation": physics_frame_now - last_observed_physics_frame, "sampler_sequence_index": sampler_sequence_now, "sampler_sequence_gap_from_previous_observation": sampler_sequence_now - last_sampler_sequence, "sampled_after_player_physics_process": true, "player_position_m": metadata.player_position_m, "chain_u_m": metadata.chain_u_m, "velocity_mps": metadata.velocity_mps, "input_action_pressed": false})
		previous_u = float(metadata.chain_u_m)
		last_observed_physics_frame = physics_frame_now
		last_sampler_sequence = sampler_sequence_now
	_stop_motion_sampling(player, sampler)
	var brackets := _visual_join_brackets(captured)
	var uniqueness := _visual_capture_uniqueness(captured)
	var displacement := Vector2(input_end_position.x - start_position.x, input_end_position.z - start_position.z).length()
	if not _require(next_threshold == thresholds.size() and captured.size() == thresholds.size(), "B225 visual sweep captured %d/%d frames." % [captured.size(), thresholds.size()]) \
	or not _require(input_end_u >= MOTION_END_U_M and input_end_u < CHAIN_TOTAL_M - 2.0, "B225 visual motion end u %.3f escaped scope." % input_end_u) \
	or not _require(bool(brackets.get("ok", false)), str(brackets.get("message", "B225 actual-image join brackets failed."))) \
	or not _require(bool(uniqueness.get("ok", false)), str(uniqueness.get("message", "B225 visual frame uniqueness failed."))) \
	or not _require(world.get_runtime_evidence().recovery_count == recoveries_before, "B225 visual motion triggered recovery."):
		return
	var capture_first_frame := int((captured[0] as Dictionary).actual_engine_physics_frame)
	var capture_last_frame := int((captured[-1] as Dictionary).actual_engine_physics_frame)
	var manifest := {
		"schema_version": "ti.d1-b225-prepromotion-candidate-visual-motion/3",
		"review_status": "pending_independent_pass_for_promotion_review_not_self_accepted",
		"recognition_status": "not_promoted_not_credited", "recognition_metric_frozen": "7/213",
		"proof_role": "fresh_continuous_real_controller_visual_run_with_post_render_actual_state_receipts",
		"authoritative_r3_evidence": authoritative,
		"generator": B225_GENERATOR.trim_prefix("res://"), "generator_sha256": FileAccess.get_sha256(B225_GENERATOR),
		"frozen_generator_sha256_argument": _argument_value("--generator-sha256="),
		"capture_override_sha256": FileAccess.get_sha256(CAPTURE_OVERRIDE), "runtime_environment": _runtime_environment_receipt_b225(),
		"source_dependency_hashes": DEPENDENCY_HASHES.duplicate(true), "bindings": bindings,
		"runtime_topology": CANDIDATE_SEAM.CANDIDATE_WORLD_TOPOLOGY.duplicate(true),
		"r1_rejection_record": {"file": "r1-rejection.json", "sha256": R1_REJECTION_SHA256},
		"r2_rejection_record": {"file": "r2-rejection.json", "sha256": R2_REJECTION_SHA256},
		"visual_fixed_fps_operator_request": VISUAL_FIXED_FPS, "fixed_fps_operator_request_receipt_argument": _argument_value("--fixed-fps-receipt="),
		"fixed_fps_receipt_is_operator_invocation_disclosure_not_engine_observation": true,
		"input_action": MOTION_INPUT_ACTION, "run_action_pressed": false, "jetpack_action_pressed": false, "recovery_action_pressed": false,
		"input_baseline_engine_physics_frame": start_physics_frame, "input_baseline_sampler_sequence_index": baseline_sampler_sequence,
		"input_baseline_player_position_m": _vector3(start_position), "input_baseline_chain_u_m": _player_chain_u_from_position(start_position),
		"input_start_engine_physics_frame": start_physics_frame, "input_end_engine_physics_frame": input_end_physics_frame,
		"input_elapsed_physics_ticks": input_end_physics_frame - start_physics_frame,
		"input_duration_seconds_from_engine_ticks": float(input_end_physics_frame - start_physics_frame) / B225_MOTION_PHYSICS_HZ,
		"start_position_m": _vector3(start_position), "input_end_position_m": _vector3(input_end_position), "input_horizontal_displacement_m": displacement,
		"start_chain_u_m": _player_chain_u_from_position(start_position), "input_end_chain_u_m": input_end_u,
		"player_transform_writes_after_input_began": 0, "camera_transform_writes_after_input_began": 0,
		"camera_planar_right_dot_chain_tangent": camera_right_dot_chain, "chain_u_monotonic_non_decreasing": true,
		"sampler_phase": "dedicated_node_physics_callback_strictly_after_player_controller",
		"player_process_physics_priority": player.process_physics_priority,
		"sampler_process_physics_priority": int(sampler_result.sampler_process_physics_priority),
		"sampler_priority_strictly_after_player": true,
		"visual_outer_observations_are_not_claimed_consecutive": true, "outer_observations": observations,
		"dense_frame_thresholds_are_triggers_not_observed_positions": true, "dense_frame_thresholds": thresholds,
		"dense_visual_frames": captured, "dense_visual_frame_count": captured.size(),
		"all_dense_frame_receipts_queried_after_frame_post_draw": true,
		"all_dense_frame_states_match_latest_post_player_sampler_snapshot": true,
		"all_dense_frame_engine_frames_unique": true, "all_dense_frame_hashes_unique": true,
		"capture_first_engine_physics_frame": capture_first_frame,
		"capture_last_engine_physics_frame": capture_last_frame,
		"capture_endpoint_elapsed_physics_ticks": capture_last_frame - capture_first_frame,
		"capture_inclusive_engine_tick_span": capture_last_frame - capture_first_frame + 1,
		"capture_endpoint_elapsed_seconds": float(capture_last_frame - capture_first_frame) / B225_MOTION_PHYSICS_HZ,
		"actual_join_brackets": brackets.joins, "all_three_joins_bracketed_by_actual_image_positions": true,
		"braking_samples_recorded_separately": true, "braking_sample_count": braking_samples.size(), "braking_samples": braking_samples,
		"recovery_delta": 0, "visual_verdict": "pending_independent_review",
		"canonical_entrypoint_reachable": false, "catalog_or_registry_promotion": false, "recognition_credit": false,
	}
	var manifest_name := "visual-motion.json"
	if not _write_new_json(output_root.path_join(manifest_name), manifest):
		_fail("Could not write B225 visual motion manifest.")
		return
	if not _final_visual_stage_matches(output_root, authoritative, manifest_name):
		_fail("B225 final visual stage failed its complete disk-roundtrip tree validator.")
		return
	print("PASS: wrote %d post-render-truthful B225 visual frames across actual brackets at all three joins; input elapsed %d real physics ticks" % [captured.size(), input_end_physics_frame - start_physics_frame])


func _b225_views(record: Dictionary) -> Array[Dictionary]:
	var midpoint := (CHAIN_START + CHAIN_END) * 0.5
	var run0 := _run_target(record, 0, 0.5, 4.2)
	var corner_position := CHAIN_END + (run0.outward as Vector3) * 15.0 + CHAIN_OUTWARD * 6.0
	var run0_position := Vector2(corner_position.x, corner_position.z)
	return [
		{"id": "01-whole-nnw-default", "role": "grounded_stock_player_whole_candidate_nnw", "requested_xz": _chain_point(-4.0, 0.0) + Vector2(CHAIN_OUTWARD.x, CHAIN_OUTWARD.z) * 25.0, "aim_target": Vector3(midpoint.x, 5.3, midpoint.z), "expected_receiver": ADAPTER.RECEIVER_KEY, "expected_sources": [ADAPTER.SOURCE_KEY]},
		{"id": "02-nnw-oblique", "role": "grounded_stock_player_candidate_nnw_oblique", "requested_xz": _chain_point(2.0, 0.0) + Vector2(CHAIN_OUTWARD.x, CHAIN_OUTWARD.z) * 27.0, "aim_target": _chain_point_3d(23.0, 5.5), "expected_receiver": ADAPTER.RECEIVER_KEY, "expected_sources": [ADAPTER.SOURCE_KEY]},
		{"id": "05-clerestory-cladding-close", "role": "grounded_stock_player_clerestory_and_cladding_close", "requested_xz": _chain_point(27.0, 0.0) + Vector2(CHAIN_OUTWARD.x, CHAIN_OUTWARD.z) * 14.0, "aim_target": _chain_point_3d(27.0, 6.4), "expected_receiver": ADAPTER.RECEIVER_KEY, "expected_sources": [ADAPTER.SOURCE_KEY]},
		{"id": "06-real-spray-eligible-host", "role": "grounded_stock_player_real_spray_on_eligible_sole_host", "requested_xz": _chain_point(29.0, 0.0) + Vector2(CHAIN_OUTWARD.x, CHAIN_OUTWARD.z) * 4.5, "aim_target": _chain_point_3d(29.0, 4.25), "expected_receiver": ADAPTER.RECEIVER_KEY, "expected_sources": [ADAPTER.SOURCE_KEY], "minimum_actual_spring_m": 1.5},
		{"id": "07-protected-return-run0", "role": "grounded_stock_player_three_quarter_protected_generic_run0_plus_selected_nnw_corner", "requested_xz": run0_position, "aim_target": run0.point, "expected_receiver": ADAPTER.RECEIVER_KEY, "expected_sources": [ADAPTER.SOURCE_KEY]},
		{"id": "08-b225-surrounding-context", "role": "grounded_stock_player_wide_candidate_and_nearby_building_context", "requested_xz": _chain_point(-13.0, 0.0) + Vector2(CHAIN_OUTWARD.x, CHAIN_OUTWARD.z) * 18.0, "aim_target": _chain_point_3d(23.0, 5.7), "expected_receiver": ADAPTER.RECEIVER_KEY, "expected_sources": [ADAPTER.SOURCE_KEY]},
	]


func _preflight_decoys(world: WorldLoader, player: PlayerController, hud: GameHUD) -> Dictionary:
	for spec: Dictionary in _decoy_specs():
		var resolved := await _resolve_decoy_pose(world, player, hud, spec)
		if not bool(resolved.get("ok", false)): return resolved
	return {"ok": true}


func _capture_decoys(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, output_root: String) -> Dictionary:
	var captures: Array[Dictionary] = []
	for spec: Dictionary in _decoy_specs():
		var resolved := await _resolve_decoy_pose(world, player, hud, spec)
		if not bool(resolved.get("ok", false)): return resolved
		var extra := (resolved.get("metadata", {}) as Dictionary).duplicate(true)
		extra["decoy_role"] = str(spec.role)
		extra["b225_candidate_attached_to_decoy"] = false
		var saved := await _save_candidate_still(main, player, hud, output_root, str(spec.id), str(spec.role), "world_default", extra)
		if not bool(saved.get("ok", false)): return saved
		captures.append(saved.metadata)
	return {"ok": true, "captures": captures}


func _decoy_specs() -> Array[Dictionary]:
	return [
		{"id": "09-decoy-b201-current", "role": "exact_current_b201_confusion_set_context", "source": "w34313545", "receiver": "building:w34313545:wall", "chunk": "res://generated/world/chunks/x_0__z_-2.json", "preferred_requested_xz": Vector2(-8.000708, -214.743366), "preferred_aim_target": Vector3(64.282, 5.8, -253.463)},
		{"id": "10-decoy-b202-current", "role": "exact_current_b202_confusion_set_context", "source": "w34313546", "receiver": "building:w34313546:wall", "chunk": "res://generated/world/chunks/x_0__z_-2.json"},
		{"id": "11-decoy-b258-current", "role": "exact_current_b258_confusion_set_context", "source": "w34313512", "receiver": "building:w34313512:wall", "chunk": "res://generated/world/chunks/x_0__z_0.json"},
	]


func _resolve_decoy_pose(world: WorldLoader, player: PlayerController, hud: GameHUD, spec: Dictionary) -> Dictionary:
	var candidates := _decoy_candidate_views(spec)
	var failures: Array[String] = []
	for view_value: Variant in candidates:
		var view := view_value as Dictionary
		var requested := view.requested_xz as Vector2
		if not bool(_ground_metadata(_ground_hit(player, requested)).get("ok", false)):
			continue
		var pose := await _settle_and_aim(world, player, hud, requested, view.aim_target as Vector3, str(spec.id), 1.5)
		if not bool(pose.get("ok", false)):
			failures.append(str(pose.get("message", "settle failed")))
			continue
		var los := _center_los(player, view.aim_target as Vector3, str(spec.receiver), [str(spec.source)], str(spec.id))
		if not bool(los.get("ok", false)):
			failures.append(str(los.get("message", "LOS failed")))
			continue
		var metadata := pose.metadata as Dictionary
		metadata.merge(los.metadata as Dictionary, true)
		metadata["decoy_pose_search_candidate_index"] = candidates.find(view_value)
		return {"ok": true, "metadata": metadata}
	return {"ok": false, "message": "%s had no grounded unoccluded exact-receiver context pose after %d candidates: %s" % [spec.id, candidates.size(), failures.slice(maxi(0, failures.size() - 3))]}


func _decoy_candidate_views(spec: Dictionary) -> Array[Dictionary]:
	var record := _wall_record(str(spec.chunk), str(spec.receiver))
	var result: Array[Dictionary] = []
	if record.is_empty(): return result
	if spec.has("preferred_requested_xz") and spec.has("preferred_aim_target"):
		result.append({"requested_xz": spec.preferred_requested_xz, "aim_target": spec.preferred_aim_target})
	var vertices := record.get("vertices", []) as Array
	var normals := record.get("normals", []) as Array
	var runs: Array[Dictionary] = []
	for run_index in int(vertices.size() / 12):
		var offset := run_index * 12
		var start := Vector3(float(vertices[offset]), float(vertices[offset + 1]), float(vertices[offset + 2]))
		var end := Vector3(float(vertices[offset + 3]), float(vertices[offset + 4]), float(vertices[offset + 5]))
		var length := Vector2(start.x, start.z).distance_to(Vector2(end.x, end.z))
		runs.append({"length": length, "point": (start + end) * 0.5, "outward": Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized(), "tangent": Vector3(end.x - start.x, 0.0, end.z - start.z).normalized(), "mid_y": (float(vertices[offset + 1]) + float(vertices[offset + 7])) * 0.5})
	runs.sort_custom(func(left: Dictionary, right: Dictionary) -> bool: return float(left.length) > float(right.length))
	for run_value: Variant in runs.slice(0, mini(6, runs.size())):
		var run := run_value as Dictionary
		for distance_m: float in [38.0, 48.0, 58.0, 28.0, 68.0]:
			for tangent_offset_m: float in [0.0, -10.0, 10.0, -20.0, 20.0]:
				var point := run.point as Vector3
				var outward := run.outward as Vector3
				var tangent := run.tangent as Vector3
				result.append({"requested_xz": Vector2(point.x + outward.x * distance_m + tangent.x * tangent_offset_m, point.z + outward.z * distance_m + tangent.z * tangent_offset_m), "aim_target": Vector3(point.x, float(run.mid_y), point.z)})
	return result


func _run_target(record: Dictionary, run_index: int, fraction: float, world_y: float) -> Dictionary:
	var vertices := record.get("vertices", []) as Array
	var normals := record.get("normals", []) as Array
	var offset := run_index * 12
	var start := Vector3(float(vertices[offset]), world_y, float(vertices[offset + 2]))
	var end := Vector3(float(vertices[offset + 3]), world_y, float(vertices[offset + 5]))
	return {"point": start.lerp(end, fraction), "outward": Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized()}


func _whole_projection(camera: Camera3D, _record: Dictionary) -> Dictionary:
	var corners := [
		Vector3(CHAIN_START.x, 2.15, CHAIN_START.z), Vector3(CHAIN_START.x, 7.55, CHAIN_START.z),
		Vector3(CHAIN_END.x, 2.15, CHAIN_END.z), Vector3(CHAIN_END.x, 7.55, CHAIN_END.z),
	]
	var viewport := camera.get_viewport().get_visible_rect()
	var pixels: Array[Vector2] = []
	for corner: Vector3 in corners:
		if camera.is_position_behind(corner): return {"ok": false, "message": "chain corner behind camera"}
		var pixel := camera.unproject_position(corner)
		if not viewport.grow(-20.0).has_point(pixel): return {"ok": false, "message": "chain corner outside viewport", "pixel": [pixel.x, pixel.y]}
		pixels.append(pixel)
	return {"ok": true, "projected_pixels": pixels.map(func(pixel: Vector2) -> Array: return [pixel.x, pixel.y]), "complete_chain_visible": true}


func _place_real_spray(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD) -> Dictionary:
	var hit := _camera_spray_hit(player)
	var wall := _record_nodes(world, ADAPTER.RECEIVER_KEY)[0]
	var body := wall.get_node("Collision") as StaticBody3D
	if hit.is_empty() or hit.get("collider", null) != body or player.global_position.distance_to(hit.position as Vector3) > player.get_spray_controller().maximum_range_m:
		return {"ok": false, "message": "Eligible spray pose did not first-hit the sole B225 host in range."}
	var controller := player.get_spray_controller()
	var before := controller.tag_instances.active_count()
	var placed_before := int((world.get_runtime_evidence().spray_counts as Dictionary).placed)
	controller.attempt_spray()
	await process_frame
	if not await _wait_for_render(main, player, hud): return {"ok": false, "message": "Spray render did not settle."}
	if controller.tag_instances.active_count() != before + 1 or int((world.get_runtime_evidence().spray_counts as Dictionary).placed) != placed_before + 1:
		return {"ok": false, "message": "Real SprayController did not place exactly one tag."}
	var tag := controller.tag_instances.get_child(controller.tag_instances.get_child_count() - 1) as Decal
	if tag == null or str(tag.get_meta("derived_object_key", "")) != ADAPTER.RECEIVER_KEY or tag.get_meta("source_keys", []) != [ADAPTER.SOURCE_KEY]:
		return {"ok": false, "message": "Placed tag identity drifted."}
	return {"ok": true, "metadata": {"spray_result": "placed", "spray_first_hit_object": ADAPTER.RECEIVER_KEY, "spray_first_hit_sources": [ADAPTER.SOURCE_KEY], "spray_first_hit_position_m": _vector3(hit.position as Vector3), "spray_first_hit_normal": _vector3(hit.normal as Vector3), "tag_position_m": _vector3(tag.global_position), "tag_visible_in_tree": tag.is_visible_in_tree(), "sole_host_collider": true}}


func _save_candidate_still(main: GameMain, player: PlayerController, hud: GameHUD, output_root: String, id: String, role: String, lighting: String, extra: Dictionary) -> Dictionary:
	if not await _wait_for_render(main, player, hud): return {"ok": false, "message": "%s did not stabilize." % id}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != STILL_SIZE: return {"ok": false, "message": "%s image was empty/wrong size." % id}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.1: return {"ok": false, "message": "%s appears blank." % id}
	var relative := "images/%s.png" % id
	var path := output_root.path_join(relative)
	if FileAccess.file_exists(path) or image.save_png(path) != OK: return {"ok": false, "message": "%s would overwrite or failed save." % id}
	var metadata := {"id": id, "role": role, "lighting": lighting, "file": relative, "sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [image.get_width(), image.get_height()], "sample_unique_colors": int(sample.unique_colors), "sample_luminance_range": float(sample.luminance_range), "debug_labels_visible": false, "source_photography_in_frame": false, "crop_or_postprocess": false, "candidate_stage": "prepromotion_live_ab_only", "visual_verdict": "pending_independent_review"}
	metadata.merge(extra, true)
	print("B225_CANDIDATE_CAPTURE: id=%s image=%s sha256=%s" % [id, ProjectSettings.globalize_path(path), metadata.sha256])
	return {"ok": true, "metadata": metadata}


func _save_grayscale_b225(output_root: String, source_relative: String, target_relative: String) -> Dictionary:
	var source_path := output_root.path_join(source_relative)
	var target_path := output_root.path_join(target_relative)
	if FileAccess.file_exists(target_path): return {"ok": false, "message": "Grayscale target exists."}
	var image := Image.load_from_file(source_path)
	if image == null or image.is_empty() or image.get_size() != STILL_SIZE: return {"ok": false, "message": "Grayscale source failed."}
	image.convert(Image.FORMAT_L8)
	if image.save_png(target_path) != OK: return {"ok": false, "message": "Grayscale save failed."}
	return {"ok": true, "metadata": {"id": "04-whole-nnw-default-grayscale", "role": "lossless_grayscale_legibility_derivative", "lighting": "derived_from_world_default", "file": target_relative, "sha256": FileAccess.get_sha256(target_path), "bytes": FileAccess.get_file_as_bytes(target_path).size(), "dimensions": [image.get_width(), image.get_height()], "derivation_source": source_relative, "derivation_source_sha256": FileAccess.get_sha256(source_path), "crop_or_postprocess": false, "grayscale_only": true, "visual_verdict": "pending_independent_review"}}


func _motion_frame_thresholds() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for u: float in [2.0, 5.0, 8.0, 27.0, 29.0, 30.8]:
		result.append({"trigger_u_m": u, "role": "far_mid_near", "join_index": 0, "join_u_m": 0.0, "intended_join_offset_m": 0.0, "actual_trigger_tolerance_m": VISUAL_TRIGGER_TOLERANCE_M})
	for join_index in RUN_JOIN_U_M.size():
		var join_u := RUN_JOIN_U_M[join_index]
		for offset: float in [-0.20, -0.07, 0.0, 0.07, 0.20]:
			result.append({"trigger_u_m": join_u + offset, "role": "join_%d_adjacent" % (join_index + 1), "join_index": join_index + 1, "join_u_m": join_u, "intended_join_offset_m": offset, "actual_trigger_tolerance_m": VISUAL_TRIGGER_TOLERANCE_M})
	result.sort_custom(func(left: Dictionary, right: Dictionary) -> bool: return float(left.trigger_u_m) < float(right.trigger_u_m))
	for index in result.size():
		result[index]["index"] = index + 1
	return result


func _save_visual_motion_frame(output_root: String, threshold: Dictionary, trigger_frame: int, trigger_sampler_sequence: int, trigger_u: float, actual_frame: int, actual_sampler_sequence: int, actual_u: float, actual_position: Array) -> Dictionary:
	var trigger_deviation := actual_u - float(threshold.trigger_u_m)
	if trigger_deviation < -0.0001 or trigger_deviation > float(threshold.actual_trigger_tolerance_m):
		return {"ok": false, "message": "Visual frame %d post-render actual u %.3f escaped trigger %.3f + tolerance %.3f." % [int(threshold.index), actual_u, float(threshold.trigger_u_m), float(threshold.actual_trigger_tolerance_m)]}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != STILL_SIZE: return {"ok": false, "message": "Motion frame image failed."}
	var relative := "visual-motion-frames/%02d-%s-trigger-u%05.2f.png" % [int(threshold.index), str(threshold.role), float(threshold.trigger_u_m)]
	var path := output_root.path_join(relative)
	if FileAccess.file_exists(path) or image.save_png(path) != OK: return {"ok": false, "message": "Motion frame would overwrite or failed: %s" % relative}
	if Engine.get_physics_frames() != actual_frame:
		return {"ok": false, "message": "Physics advanced during synchronous PNG save for visual frame %d." % int(threshold.index)}
	var metadata := {
		"index": int(threshold.index), "file": relative, "sha256": FileAccess.get_sha256(path),
		"bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [image.get_width(), image.get_height()],
		"role": str(threshold.role), "join_index": int(threshold.join_index),
		"threshold_trigger_u_m": float(threshold.trigger_u_m), "trigger_engine_physics_frame": trigger_frame,
		"trigger_sampler_sequence_index": trigger_sampler_sequence, "trigger_observed_u_m": trigger_u,
		"actual_engine_physics_frame": actual_frame, "actual_sampler_sequence_index": actual_sampler_sequence,
		"actual_player_position_m": actual_position, "actual_u_m": actual_u,
		"post_render_engine_tick_delta": actual_frame - trigger_frame,
		"post_render_sampler_sequence_delta": actual_sampler_sequence - trigger_sampler_sequence,
		"actual_minus_trigger_u_m": trigger_deviation,
		"actual_within_declared_trigger_tolerance": true,
		"state_queried_after_frame_post_draw_before_image_read": true,
		"latest_post_player_sampler_snapshot_read_after_frame_post_draw": true,
		"actual_state_matches_latest_post_player_sampler_snapshot": true,
		"no_await_between_actual_state_query_and_image_read_or_save": true,
	}
	if int(threshold.join_index) > 0:
		metadata["join_u_m"] = float(threshold.join_u_m)
		metadata["intended_join_offset_m"] = float(threshold.intended_join_offset_m)
		metadata["actual_join_offset_m"] = actual_u - float(threshold.join_u_m)
	return {"ok": true, "metadata": metadata}


func _visual_capture_uniqueness(captured: Array[Dictionary]) -> Dictionary:
	var frames := {}
	var hashes := {}
	var previous_frame := -1
	var previous_u := -INF
	for capture: Dictionary in captured:
		var frame := int(capture.actual_engine_physics_frame)
		var hash := str(capture.sha256)
		var u := float(capture.actual_u_m)
		if frames.has(frame) or hashes.has(hash) or frame <= previous_frame or u <= previous_u:
			return {"ok": false, "message": "Dense visual frames were not unique and strictly ordered at index %d." % int(capture.index)}
		frames[frame] = true
		hashes[hash] = true
		previous_frame = frame
		previous_u = u
	return {"ok": true}


func _visual_join_brackets(captured: Array[Dictionary]) -> Dictionary:
	var result: Array[Dictionary] = []
	for join_index in RUN_JOIN_U_M.size():
		var members: Array[Dictionary] = []
		for capture: Dictionary in captured:
			if int(capture.join_index) == join_index + 1:
				members.append(capture)
		if members.size() != 5:
			return {"ok": false, "message": "Join %d has %d/5 actual visual frames." % [join_index + 1, members.size()]}
		var minimum_offset := INF
		var maximum_offset := -INF
		var before_count := 0
		var after_count := 0
		var actual_offsets: Array[float] = []
		for member: Dictionary in members:
			var offset := float(member.actual_join_offset_m)
			actual_offsets.append(offset)
			minimum_offset = minf(minimum_offset, offset)
			maximum_offset = maxf(maximum_offset, offset)
			if offset < -0.02: before_count += 1
			if offset > 0.02: after_count += 1
		if before_count < 1 or after_count < 1 or minimum_offset < -0.40 or maximum_offset > 0.40:
			return {"ok": false, "message": "Join %d actual visual offsets do not form a tight before/after bracket: %s." % [join_index + 1, actual_offsets]}
		result.append({"join_index": join_index + 1, "join_u_m": RUN_JOIN_U_M[join_index], "actual_offsets_m": actual_offsets, "before_count": before_count, "after_count": after_count, "minimum_offset_m": minimum_offset, "maximum_offset_m": maximum_offset})
	return {"ok": true, "joins": result}


func _append_saved(captures: Array[Dictionary], result: Dictionary) -> bool:
	if not _require(bool(result.get("ok", false)), str(result.get("message", "Capture save failed."))): return false
	captures.append(result.metadata as Dictionary)
	return true


func _camera_spray_hit(player: PlayerController) -> Dictionary:
	var camera := player.get_camera()
	var center := camera.get_viewport().get_visible_rect().size * 0.5
	var origin := camera.project_ray_origin(center)
	var direction := camera.project_ray_normal(center).normalized()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 1000.0, PHYSICS_SPRAY_SURFACE, [player.get_rid()])
	return player.get_world_3d().direct_space_state.intersect_ray(query)


func _camera_hit_collider(player: PlayerController) -> CollisionObject3D:
	return _camera_spray_hit(player).get("collider", null) as CollisionObject3D


func _camera_hit_matches(player: PlayerController, receiver: String) -> bool:
	var collider := _camera_hit_collider(player)
	return collider != null and str(collider.get_meta("derived_object_key", "")) == receiver and collider.get_meta("source_keys", []) == [ADAPTER.SOURCE_KEY]


func _chain_point(u_m: float, _unused: float) -> Vector2:
	var point := CHAIN_START + CHAIN_TANGENT * u_m
	return Vector2(point.x, point.z)


func _chain_point_3d(u_m: float, y: float) -> Vector3:
	var point := CHAIN_START + CHAIN_TANGENT * u_m
	return Vector3(point.x, y, point.z)


func _player_chain_u(player: PlayerController) -> float:
	return _player_chain_u_from_position(player.global_position)


func _player_chain_u_from_position(position: Vector3) -> float:
	var delta := position - CHAIN_START
	return Vector3(delta.x, 0.0, delta.z).dot(CHAIN_TANGENT)


func _motion_camera_right_dot_chain(player: PlayerController) -> float:
	var camera_rig := player.get_node("CameraPivot") as PlayerCamera
	return camera_rig.planar_right().dot(CHAIN_TANGENT)


func _wall_record(path: String, key: String) -> Dictionary:
	var chunk := _json(path)
	for value: Variant in chunk.get("records", []):
		if value is Dictionary and str((value as Dictionary).get("object_key", "")) == key: return value as Dictionary
	return {}


func _surface_triangles(mesh: ArrayMesh, surface: int) -> int:
	return int(((mesh.surface_get_arrays(surface) as Array)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3)


func _runtime_topology(evidence: RuntimeEvidence) -> Dictionary:
	return {"rows": evidence.playable_rows, "meshes": evidence.mesh_instances, "surfaces": evidence.surfaces, "triangles": evidence.triangles, "bodies": evidence.static_bodies, "shapes": evidence.shapes}


func _world_has_no_candidate(world: Node) -> bool:
	if world.has_meta(CANDIDATE_SEAM.APPLIED_META): return false
	for node: Node in world.find_children("*", "", true, false):
		if node.has_meta(CANDIDATE_SEAM.APPLIED_META) or node.name in ["D1B225PrepromotionCandidateAttachment", "D1B225LiveAttachment"]: return false
	return true


func _dependencies_match() -> bool:
	for path: String in DEPENDENCY_HASHES:
		if FileAccess.get_sha256(path) != str(DEPENDENCY_HASHES[path]):
			print("B225_CAPTURE_DEPENDENCY_DRIFT path=", path, " actual=", FileAccess.get_sha256(path), " expected=", DEPENDENCY_HASHES[path])
			return false
	return true


func _rejection_receipts_match(output_root: String) -> bool:
	var r1_path := output_root.path_join("r1-rejection.json")
	var r2_path := output_root.path_join("r2-rejection.json")
	if not FileAccess.file_exists(r1_path) or FileAccess.get_sha256(r1_path) != R1_REJECTION_SHA256 \
	or not FileAccess.file_exists(r2_path) or FileAccess.get_sha256(r2_path) != R2_REJECTION_SHA256:
		return false
	var r1 := _json(r1_path)
	var r2 := _json(r2_path)
	return str(r1.get("status", "")) == "rejected_non_authoritative_superseded_by_r2" \
		and str((r1.get("r1_canonical_tree_inventory", {}) as Dictionary).get("sha256", "")) == "21a5badf29ac760c9ab50700bb2c2f46b2c2b5928cf5c09b0b5592ccfa9bd27f" \
		and _json_int_equals((r1.get("r1_canonical_tree_inventory", {}) as Dictionary).get("file_count"), 35) \
		and _json_bool_equals(r1.get("recognition_credit"), false) and _json_bool_equals(r1.get("promotion_authorized"), false) \
		and str(r2.get("status", "")) == "rejected_non_authoritative_superseded_by_r3" \
		and str((r2.get("r2_canonical_tree_inventory", {}) as Dictionary).get("sha256", "")) == "8c10e4fc4541855e4e7cc5ad6812bcd93ed372c09045d78f74e33d32a601a4ca" \
		and _json_int_equals((r2.get("r2_canonical_tree_inventory", {}) as Dictionary).get("file_count"), 14) \
		and str((r2.get("r2_manifest_sha256", {}) as Dictionary).get("capture-manifest.json", "")) == "0469b3e36607d8bc412e8c5a4a152ad555179c004ec27992abd4aed079ece8bb" \
		and _json_int_equals((r2.get("rejection_reason", {}) as Dictionary).get("telemetry_files_written"), 0) \
		and _json_int_equals((r2.get("rejection_reason", {}) as Dictionary).get("visual_motion_files_written"), 0) \
		and _json_bool_equals(r2.get("recognition_credit"), false) and _json_bool_equals(r2.get("promotion_authorized"), false)


func _json_integral_number(value: Variant) -> bool:
	if typeof(value) not in [TYPE_INT, TYPE_FLOAT]:
		return false
	var number := float(value)
	return not is_nan(number) and not is_inf(number) and number == floor(number) \
		and number >= -9007199254740991.0 and number <= 9007199254740991.0


func _json_int_equals(value: Variant, expected: int) -> bool:
	return _json_integral_number(value) and int(value) == expected


func _json_bool_equals(value: Variant, expected: bool) -> bool:
	return typeof(value) == TYPE_BOOL and bool(value) == expected


func _canonical_object_id_string(value: Variant, require_positive: bool) -> bool:
	if typeof(value) != TYPE_STRING:
		return false
	var text := str(value)
	if text.is_empty() or not text.is_valid_int():
		return false
	var parsed := int(text)
	return parsed != 0 and str(parsed) == text and (not require_positive or parsed > 0)


func _finite_float(value: Variant) -> bool:
	if typeof(value) not in [TYPE_INT, TYPE_FLOAT]:
		return false
	var number := float(value)
	return not is_nan(number) and not is_inf(number)


func _json_float_matches(value: Variant, expected: float, tolerance: float = 0.0001) -> bool:
	return _finite_float(value) and not is_nan(expected) and not is_inf(expected) \
		and absf(float(value) - expected) <= tolerance


func _json_numeric_contract_self_test() -> bool:
	var round_trip := JSON.parse_string(JSON.stringify({"value": 735})) as Dictionary
	return _json_int_equals(round_trip.get("value"), 735) \
		and _json_int_equals(735, 735) and _json_int_equals(735.0, 735) \
		and not _json_int_equals(735.5, 735) and not _json_int_equals(734.9, 735) \
		and not _json_int_equals("735", 735) and not _json_int_equals(true, 1) \
		and not _json_int_equals(null, 0) and not _json_int_equals(INF, 0) \
		and not _json_int_equals(NAN, 0)


func _json_topology_matches(value: Variant, expected: Dictionary) -> bool:
	if not value is Dictionary:
		return false
	var actual := value as Dictionary
	var exact_keys := ["bodies", "meshes", "rows", "shapes", "surfaces", "triangles"]
	var actual_keys := Array(actual.keys())
	actual_keys.sort()
	if actual_keys != exact_keys:
		return false
	for key: String in exact_keys:
		if not _json_int_equals(actual.get(key), int(expected.get(key, -1))):
			return false
	return true


func _json_vector3_matches_u(value: Variant, expected_u: float, tolerance: float = 0.002) -> bool:
	if not value is Array:
		return false
	var values := value as Array
	return values.size() == 3 and _finite_float(values[0]) and _finite_float(values[1]) and _finite_float(values[2]) \
		and absf(_player_chain_u_from_position(Vector3(float(values[0]), float(values[1]), float(values[2]))) - expected_u) <= tolerance


func _json_vector3_matches(value: Variant, expected: Vector3, tolerance: float = 0.0001) -> bool:
	if not value is Array:
		return false
	var values := value as Array
	return values.size() == 3 \
		and _json_float_matches(values[0], expected.x, tolerance) \
		and _json_float_matches(values[1], expected.y, tolerance) \
		and _json_float_matches(values[2], expected.z, tolerance)


func _json_vector3_pair_matches(left: Variant, right: Variant, tolerance: float = 0.0001) -> bool:
	if not left is Array or not right is Array:
		return false
	var left_values := left as Array
	var right_values := right as Array
	return left_values.size() == 3 and right_values.size() == 3 \
		and _finite_float(right_values[0]) and _json_float_matches(left_values[0], float(right_values[0]), tolerance) \
		and _finite_float(right_values[1]) and _json_float_matches(left_values[1], float(right_values[1]), tolerance) \
		and _finite_float(right_values[2]) and _json_float_matches(left_values[2], float(right_values[2]), tolerance)


func _visual_fixed_fps_receipt_matches() -> bool:
	return _argument_value("--fixed-fps-receipt=") == str(VISUAL_FIXED_FPS)


func _generator_matches() -> bool:
	var expected := _argument_value("--generator-sha256=")
	return expected.length() == 64 and expected == FileAccess.get_sha256(B225_GENERATOR)


func _capture_override_matches() -> bool:
	return FileAccess.file_exists(CAPTURE_OVERRIDE) \
		and FileAccess.get_sha256(CAPTURE_OVERRIDE) == CAPTURE_OVERRIDE_SHA256 \
		and int(ProjectSettings.get_setting("display/window/size/window_width_override", -1)) == STILL_SIZE.x \
		and int(ProjectSettings.get_setting("display/window/size/window_height_override", -1)) == STILL_SIZE.y


func _native_runtime_matches() -> bool:
	return str(Engine.get_version_info().get("string", "")).begins_with("4.7.2-stable") \
		and DisplayServer.get_name() == "macOS" \
		and str(RenderingServer.get_current_rendering_method()) == "forward_plus" \
		and str(RenderingServer.get_current_rendering_driver_name()) == "metal" \
		and str(RenderingServer.get_video_adapter_api_version()) == "4.0" \
		and str(RenderingServer.get_video_adapter_name()).begins_with("Apple M2") \
		and not bool(ProjectSettings.get_setting(PHYSICS_INTERPOLATION_SETTING, false)) \
		and not is_physics_interpolation_enabled() \
		and DisplayServer.window_get_size() == STILL_SIZE \
		and Vector2i(root.get_texture().get_size()) == STILL_SIZE


func _output_state_allows(mode: String) -> bool:
	if mode == "preflight":
		return _r3_rejection_only_state(B225_OUTPUT)
	if mode == "review-stills":
		return _r3_rejection_only_state(B225_OUTPUT) \
			and not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(REHEARSAL_OUTPUT))
	if mode == "review-telemetry":
		return _r3_rejection_only_state(B225_OUTPUT) \
			and _sealed_static_stage_matches(REHEARSAL_OUTPUT, "static", false)
	if mode == "review-motion":
		return _r3_rejection_only_state(B225_OUTPUT) \
			and _sealed_static_stage_matches(REHEARSAL_OUTPUT, "telemetry", false) \
			and _sealed_telemetry_stage_matches(REHEARSAL_OUTPUT, "telemetry", false)
	if mode == "stills":
		return _r3_rejection_only_state(B225_OUTPUT)
	if mode == "telemetry":
		return _sealed_static_stage_matches(B225_OUTPUT, "static", true) \
			and not FileAccess.file_exists(B225_OUTPUT.path_join("motion-telemetry.json")) \
			and not FileAccess.file_exists(B225_OUTPUT.path_join("visual-motion.json")) \
			and not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(B225_OUTPUT.path_join("visual-motion-frames")))
	if mode == "visual-motion":
		return _sealed_static_stage_matches(B225_OUTPUT, "telemetry", true) \
			and _sealed_telemetry_stage_matches(B225_OUTPUT, "telemetry", true) \
			and not FileAccess.file_exists(B225_OUTPUT.path_join("visual-motion.json")) \
			and not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(B225_OUTPUT.path_join("visual-motion-frames")))
	return false


func _r3_rejection_only_state(output_root: String) -> bool:
	if not _rejection_receipts_match(output_root):
		return false
	var files := Array(DirAccess.get_files_at(output_root))
	var directories := Array(DirAccess.get_directories_at(output_root))
	files.sort()
	directories.sort()
	return files == ["r1-rejection.json", "r2-rejection.json"] and directories.is_empty()


func _sealed_static_stage_matches(output_root: String, stage: String, authoritative: bool, manifest_override: Variant = null, run_mutations: bool = true) -> bool:
	var manifest_path := output_root.path_join("capture-manifest.json")
	if not _rejection_receipts_match(output_root) or not FileAccess.file_exists(manifest_path) \
	or FileAccess.get_sha256(output_root.path_join("capture-override.cfg")) != CAPTURE_OVERRIDE_SHA256 \
	or not _root_stage_matches(output_root, stage):
		return false
	var manifest_value: Variant = _json(manifest_path) if manifest_override == null else manifest_override
	if not manifest_value is Dictionary:
		return false
	var manifest := manifest_value as Dictionary
	var static_mutations_match := not run_mutations or _static_disk_numeric_mutations_reject(output_root, stage, authoritative, manifest)
	if str(manifest.get("schema_version", "")) != "ti.d1-b225-prepromotion-candidate-static-evidence/3" \
	or str(manifest.get("generator_sha256", "")) != FileAccess.get_sha256(B225_GENERATOR) \
	or str(manifest.get("frozen_generator_sha256_argument", "")) != FileAccess.get_sha256(B225_GENERATOR) \
	or str(manifest.get("capture_override_sha256", "")) != CAPTURE_OVERRIDE_SHA256 \
	or not _json_int_equals(manifest.get("capture_count"), STILL_FILES.size()) \
	or not _json_int_equals(manifest.get("activation_count"), 1) \
	or not _json_bool_equals(manifest.get("ordinary_world_loaded_before_activation"), true) \
	or not _json_bool_equals(manifest.get("authoritative_r3_evidence"), authoritative) \
	or str((manifest.get("r1_rejection_record", {}) as Dictionary).get("sha256", "")) != R1_REJECTION_SHA256 \
	or str((manifest.get("r2_rejection_record", {}) as Dictionary).get("sha256", "")) != R2_REJECTION_SHA256 \
	or manifest.get("source_dependency_hashes", {}) != DEPENDENCY_HASHES \
	or not _json_topology_matches(manifest.get("canonical_default_world_topology"), CANDIDATE_SEAM.DEFAULT_WORLD_TOPOLOGY) \
	or not _json_topology_matches(manifest.get("explicit_candidate_world_topology"), CANDIDATE_SEAM.CANDIDATE_WORLD_TOPOLOGY) \
	or not _activation_receipt_matches(manifest.get("activation")) \
	or not _runtime_receipt_matches(manifest.get("runtime_environment")) \
	or not _bindings_receipt_matches(manifest.get("bindings")) \
	or not _json_bool_equals(manifest.get("canonical_entrypoint_reachable"), false) \
	or not _json_bool_equals(manifest.get("catalog_or_registry_promotion"), false) \
	or not _json_bool_equals(manifest.get("recognition_credit"), false) \
	or not static_mutations_match:
		return false
	var images_root := output_root.path_join("images")
	var actual_files := Array(DirAccess.get_files_at(images_root))
	var expected_files := Array(STILL_FILES).duplicate()
	actual_files.sort()
	expected_files.sort()
	if actual_files != expected_files or not Array(DirAccess.get_directories_at(images_root)).is_empty():
		return false
	var captures := manifest.get("captures", []) as Array
	var seen := {}
	if captures.size() != STILL_FILES.size():
		return false
	for capture_value: Variant in captures:
		if not capture_value is Dictionary:
			return false
		var capture := capture_value as Dictionary
		var relative := str(capture.get("file", ""))
		var filename := relative.get_file()
		var path := output_root.path_join(relative)
		if not relative.begins_with("images/") or filename not in STILL_FILES or seen.has(filename) \
		or str(capture.get("id", "")) != filename.trim_suffix(".png") \
		or not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != str(capture.get("sha256", "")) \
		or not _json_int_equals(capture.get("bytes"), FileAccess.get_file_as_bytes(path).size()):
			return false
		var image := Image.load_from_file(path)
		var dimensions := capture.get("dimensions", []) as Array
		if image == null or image.is_empty() or dimensions.size() != 2 \
		or not _json_int_equals(dimensions[0], image.get_width()) or not _json_int_equals(dimensions[1], image.get_height()) \
		or image.get_size() != STILL_SIZE:
			return false
		if capture.has("sample_unique_colors") and (not _json_integral_number(capture.sample_unique_colors) \
		or not _json_int_equals(capture.sample_unique_colors, int(capture.sample_unique_colors)) \
		or int(capture.sample_unique_colors) < 8):
			return false
		if capture.has("sample_luminance_range") and (not _finite_float(capture.sample_luminance_range) or float(capture.sample_luminance_range) < 0.1):
			return false
		seen[filename] = capture
	if seen.size() != STILL_FILES.size():
		return false
	var default_capture := seen.get("01-whole-nnw-default.png", {}) as Dictionary
	var changed_capture := seen.get("03-whole-nnw-changed-light.png", {}) as Dictionary
	var grayscale_capture := seen.get("04-whole-nnw-default-grayscale.png", {}) as Dictionary
	var grayscale_path := output_root.path_join(str(grayscale_capture.get("file", "")))
	var grayscale_image := Image.load_from_file(grayscale_path)
	var capture_semantics_match := not default_capture.is_empty() and not changed_capture.is_empty() and not grayscale_capture.is_empty() \
		and str(default_capture.get("lighting", "")) == "world_default" \
		and _json_vector3_matches(default_capture.get("sun_rotation_degrees"), DEFAULT_SUN, 0.001) \
		and str(changed_capture.get("lighting", "")) == "frozen_changed_light" \
		and str(changed_capture.get("same_pose_as", "")) == "01-whole-nnw-default" \
		and _json_bool_equals(changed_capture.get("player_transform_exactly_reused"), true) \
		and _json_bool_equals(changed_capture.get("camera_transform_exactly_reused"), true) \
		and _json_vector3_matches(changed_capture.get("sun_rotation_degrees"), CHANGED_SUN, 0.001) \
		and _json_vector3_pair_matches(changed_capture.get("player_position_m"), default_capture.get("player_position_m")) \
		and _json_vector3_pair_matches(changed_capture.get("camera_position_m"), default_capture.get("camera_position_m")) \
		and _json_vector3_pair_matches(changed_capture.get("camera_forward"), default_capture.get("camera_forward")) \
		and _finite_float(default_capture.get("camera_fov_degrees")) \
		and _json_float_matches(changed_capture.get("camera_fov_degrees"), float(default_capture.get("camera_fov_degrees", INF))) \
		and _finite_float(default_capture.get("camera_pitch_degrees")) \
		and _json_float_matches(changed_capture.get("camera_pitch_degrees"), float(default_capture.get("camera_pitch_degrees", INF))) \
		and _finite_float(default_capture.get("camera_yaw_degrees")) \
		and _json_float_matches(changed_capture.get("camera_yaw_degrees"), float(default_capture.get("camera_yaw_degrees", INF))) \
		and str(changed_capture.get("sha256", "")) != str(default_capture.get("sha256", "")) \
		and str(grayscale_capture.get("lighting", "")) == "derived_from_world_default" \
		and str(grayscale_capture.get("derivation_source", "")) == "images/01-whole-nnw-default.png" \
		and str(grayscale_capture.get("derivation_source_sha256", "")) == str(default_capture.get("sha256", "")) \
		and _json_bool_equals(grayscale_capture.get("grayscale_only"), true) \
		and _json_bool_equals(grayscale_capture.get("crop_or_postprocess"), false) \
		and str(grayscale_capture.get("sha256", "")) != str(default_capture.get("sha256", "")) \
		and grayscale_image != null and not grayscale_image.is_empty() and grayscale_image.get_format() == Image.FORMAT_L8
	return capture_semantics_match


func _static_disk_numeric_mutations_reject(output_root: String, stage: String, authoritative: bool, manifest: Dictionary) -> bool:
	var round_trip_value: Variant = JSON.parse_string(JSON.stringify(manifest))
	if not round_trip_value is Dictionary \
	or not _sealed_static_stage_matches(output_root, stage, authoritative, round_trip_value, false):
		return false
	var mutations: Array[Dictionary] = []
	var mutation := manifest.duplicate(true)
	(mutation["canonical_default_world_topology"] as Dictionary)["rows"] = 735.5
	mutations.append(mutation)
	mutation = manifest.duplicate(true)
	(mutation["canonical_default_world_topology"] as Dictionary)["rows"] = 734.0
	mutations.append(mutation)
	mutation = manifest.duplicate(true)
	mutation["capture_count"] = float(STILL_FILES.size()) + 0.5
	mutations.append(mutation)
	mutation = manifest.duplicate(true)
	var captures := mutation.get("captures", []) as Array
	if captures.is_empty() or not captures[0] is Dictionary:
		return false
	(captures[0] as Dictionary)["bytes"] = float((captures[0] as Dictionary).get("bytes", 0)) + 0.5
	mutations.append(mutation)
	mutation = manifest.duplicate(true)
	captures = mutation.get("captures", []) as Array
	var dimensions := (captures[0] as Dictionary).get("dimensions", []) as Array
	if dimensions.size() != 2:
		return false
	dimensions[0] = float(dimensions[0]) + 0.5
	mutations.append(mutation)
	mutation = manifest.duplicate(true)
	var preserved := ((mutation.get("bindings", {}) as Dictionary).get("preserved_instance_ids", {}) as Dictionary)
	preserved["host_mesh_instance_id"] = 123.0
	mutations.append(mutation)
	mutation = manifest.duplicate(true)
	preserved = ((mutation.get("bindings", {}) as Dictionary).get("preserved_instance_ids", {}) as Dictionary)
	preserved["host_mesh_instance_id"] = "malformed-id"
	mutations.append(mutation)
	mutation = manifest.duplicate(true)
	preserved = ((mutation.get("bindings", {}) as Dictionary).get("preserved_instance_ids", {}) as Dictionary)
	preserved["host_mesh_instance_id"] = "0" + str(preserved.get("host_mesh_instance_id", ""))
	mutations.append(mutation)
	mutation = manifest.duplicate(true)
	preserved = ((mutation.get("bindings", {}) as Dictionary).get("preserved_instance_ids", {}) as Dictionary)
	var postcommit := preserved.get("postcommit_node_instance_ids", {}) as Dictionary
	postcommit["host_mesh_instance_id"] = "1" if str(preserved.get("host_mesh_instance_id", "")) != "1" else "2"
	mutations.append(mutation)
	mutation = manifest.duplicate(true)
	preserved = ((mutation.get("bindings", {}) as Dictionary).get("preserved_instance_ids", {}) as Dictionary)
	preserved["candidate_host_array_mesh_instance_id"] = str(preserved.get("ordinary_host_array_mesh_instance_id", ""))
	mutations.append(mutation)
	for mutated: Dictionary in mutations:
		var parsed_mutation: Variant = JSON.parse_string(JSON.stringify(mutated))
		if not parsed_mutation is Dictionary \
		or _sealed_static_stage_matches(output_root, stage, authoritative, parsed_mutation, false):
			return false
	return true


func _sealed_telemetry_stage_matches(output_root: String, stage: String, authoritative: bool, manifest_override: Variant = null, run_mutations: bool = true) -> bool:
	var path := output_root.path_join("motion-telemetry.json")
	if not FileAccess.file_exists(path) or not _root_stage_matches(output_root, stage):
		return false
	var manifest_value: Variant = _json(path) if manifest_override == null else manifest_override
	if not manifest_value is Dictionary:
		return false
	var manifest := manifest_value as Dictionary
	if str(manifest.get("schema_version", "")) != "ti.d1-b225-prepromotion-candidate-consecutive-telemetry/3" \
	or str(manifest.get("generator_sha256", "")) != FileAccess.get_sha256(B225_GENERATOR) \
	or str(manifest.get("frozen_generator_sha256_argument", "")) != FileAccess.get_sha256(B225_GENERATOR) \
	or str(manifest.get("capture_override_sha256", "")) != CAPTURE_OVERRIDE_SHA256 \
	or str(manifest.get("input_action", "")) != MOTION_INPUT_ACTION \
	or not _json_bool_equals(manifest.get("authoritative_r3_evidence"), authoritative) \
	or not _json_int_equals(manifest.get("input_elapsed_physics_ticks"), MOTION_TELEMETRY_FRAMES) \
	or not _json_int_equals(manifest.get("input_movement_ticks_from_baseline_to_sample_360"), MOTION_TELEMETRY_FRAMES) \
	or not _json_int_equals(manifest.get("input_sample_1_to_360_endpoint_intervals"), MOTION_TELEMETRY_FRAMES - 1) \
	or not _json_int_equals(manifest.get("input_sample_count"), MOTION_TELEMETRY_FRAMES) \
	or not _finite_float(manifest.get("input_duration_seconds")) or absf(float(manifest.input_duration_seconds) - 6.0) > 0.000001 \
	or not _json_bool_equals(manifest.get("all_input_engine_frame_deltas_exactly_one"), true) \
	or not _json_bool_equals(manifest.get("all_three_run_joins_crossed"), true) \
	or str(manifest.get("sampler_phase", "")) != "dedicated_node_physics_callback_strictly_after_player_controller" \
	or not _json_int_equals(manifest.get("sampler_process_physics_priority"), 100) \
	or not _json_int_equals(manifest.get("player_process_physics_priority"), 0) \
	or not _json_bool_equals(manifest.get("sampler_priority_strictly_after_player"), true) \
	or not _json_bool_equals(manifest.get("all_samples_after_player_physics_process"), true) \
	or not _json_bool_equals(manifest.get("telemetry_contains_render_awaits"), false) \
	or not _json_bool_equals(manifest.get("telemetry_contains_image_or_file_writes_before_manifest"), false) \
	or not _json_bool_equals(manifest.get("scene_tree_physics_frame_signal_used_as_post_player_sampler"), false) \
	or not _json_bool_equals(manifest.get("run_action_pressed"), false) \
	or not _json_bool_equals(manifest.get("jetpack_action_pressed"), false) \
	or not _json_bool_equals(manifest.get("recovery_action_pressed"), false) \
	or not _json_bool_equals(manifest.get("chain_u_monotonic_non_decreasing"), true) \
	or not _json_bool_equals(manifest.get("all_input_samples_grounded"), true) \
	or not _json_bool_equals(manifest.get("all_input_samples_in_boundary"), true) \
	or not _json_bool_equals(manifest.get("all_input_center_hits_exact_receiver"), true) \
	or not _json_int_equals(manifest.get("player_transform_writes_after_input_began"), 0) \
	or not _json_int_equals(manifest.get("camera_transform_writes_after_input_began"), 0) \
	or not _json_int_equals(manifest.get("recovery_delta"), 0) \
	or not _json_bool_equals(manifest.get("canonical_entrypoint_reachable"), false) \
	or not _json_bool_equals(manifest.get("catalog_or_registry_promotion"), false) \
	or not _json_bool_equals(manifest.get("recognition_credit"), false) \
	or str((manifest.get("r1_rejection_record", {}) as Dictionary).get("sha256", "")) != R1_REJECTION_SHA256 \
	or str((manifest.get("r2_rejection_record", {}) as Dictionary).get("sha256", "")) != R2_REJECTION_SHA256 \
	or manifest.get("source_dependency_hashes", {}) != DEPENDENCY_HASHES \
	or not _json_topology_matches(manifest.get("runtime_topology"), CANDIDATE_SEAM.CANDIDATE_WORLD_TOPOLOGY) \
	or not _runtime_receipt_matches(manifest.get("runtime_environment")) \
	or not _bindings_receipt_matches(manifest.get("bindings")) \
	or (run_mutations and not _telemetry_disk_numeric_mutations_reject(output_root, stage, authoritative, manifest)):
		return false
	for field: String in ["input_start_engine_physics_frame", "input_end_engine_physics_frame", "input_baseline_engine_physics_frame", "input_baseline_sampler_sequence_index", "input_release_engine_physics_frame"]:
		if not _json_integral_number(manifest.get(field)):
			return false
	var samples := manifest.get("samples", []) as Array
	var braking := manifest.get("braking_samples", []) as Array
	var joins := manifest.get("joins_crossed", []) as Array
	var start_frame := int(manifest.input_start_engine_physics_frame)
	var end_frame := int(manifest.input_end_engine_physics_frame)
	var baseline_frame := int(manifest.input_baseline_engine_physics_frame)
	var baseline_sequence := int(manifest.input_baseline_sampler_sequence_index)
	if not _finite_float(manifest.get("start_chain_u_m")) or not _finite_float(manifest.get("input_baseline_chain_u_m")):
		return false
	var previous_frame := start_frame
	var previous_u := float(manifest.start_chain_u_m)
	var recomputed_joins: Array[Dictionary] = []
	if samples.size() != MOTION_TELEMETRY_FRAMES or braking.size() != MOTION_BRAKING_FRAMES \
	or baseline_frame != start_frame or end_frame - start_frame != MOTION_TELEMETRY_FRAMES \
	or not _json_int_equals(manifest.get("input_release_engine_physics_frame"), end_frame) \
	or absf(float(manifest.input_baseline_chain_u_m) - previous_u) > 0.0001 \
	or not _json_vector3_matches_u(manifest.get("input_baseline_player_position_m"), previous_u):
		return false
	for index in samples.size():
		if not samples[index] is Dictionary:
			return false
		var sample := samples[index] as Dictionary
		if not _json_integral_number(sample.get("engine_physics_frame")) or not _finite_float(sample.get("chain_u_m")):
			return false
		var frame := int(sample.engine_physics_frame)
		var u := float(sample.chain_u_m)
		if not _json_int_equals(sample.get("sample_index"), index + 1) or frame != previous_frame + 1 \
		or not _json_int_equals(sample.get("engine_frame_delta"), 1) or u < previous_u - 0.0001 \
		or not _json_int_equals(sample.get("sampler_sequence_index"), baseline_sequence + index + 1) \
		or not _json_bool_equals(sample.get("sampled_after_player_physics_process"), true) \
		or not _json_vector3_matches_u(sample.get("player_position_m"), u) or not _json_vector3_finite(sample.get("velocity_mps")) \
		or not _json_bool_equals(sample.get("grounded"), true) or not _json_bool_equals(sample.get("in_boundary"), true) \
		or not _json_bool_equals(sample.get("input_action_pressed"), true) or not _json_bool_equals(sample.get("camera_basis_unchanged"), true) \
		or str(sample.get("center_first_hit_object", "")) != ADAPTER.RECEIVER_KEY or sample.get("center_first_hit_sources", []) != [ADAPTER.SOURCE_KEY]:
			return false
		for join_index in RUN_JOIN_U_M.size():
			var join_u := RUN_JOIN_U_M[join_index]
			if previous_u < join_u and u >= join_u:
				recomputed_joins.append({"join_index": join_index + 1, "join_u_m": join_u, "previous_sample_index": index, "current_sample_index": index + 1, "previous_engine_physics_frame": previous_frame, "current_engine_physics_frame": frame, "previous_u_m": previous_u, "current_u_m": u})
		previous_frame = frame
		previous_u = u
	if previous_frame != end_frame or joins.size() != RUN_JOIN_U_M.size() or recomputed_joins.size() != RUN_JOIN_U_M.size() \
	or not _finite_float(manifest.get("input_end_chain_u_m")) or absf(float(manifest.input_end_chain_u_m) - previous_u) > 0.0001:
		return false
	for join_index in joins.size():
		if not joins[join_index] is Dictionary:
			return false
		var actual := joins[join_index] as Dictionary
		var expected := recomputed_joins[join_index] as Dictionary
		for key: String in ["join_index", "previous_sample_index", "current_sample_index", "previous_engine_physics_frame", "current_engine_physics_frame"]:
			if not _json_int_equals(actual.get(key), int(expected[key])):
				return false
		for key: String in ["join_u_m", "previous_u_m", "current_u_m"]:
			if not _finite_float(actual.get(key)) or absf(float(actual[key]) - float(expected[key])) > 0.0001:
				return false
	for index in braking.size():
		if not braking[index] is Dictionary:
			return false
		var sample := braking[index] as Dictionary
		if not _json_integral_number(sample.get("engine_physics_frame")) or not _finite_float(sample.get("chain_u_m")):
			return false
		var frame := int(sample.engine_physics_frame)
		var u := float(sample.chain_u_m)
		if not _json_int_equals(sample.get("braking_sample_index"), index + 1) or frame != previous_frame + 1 \
		or not _json_int_equals(sample.get("engine_frame_delta"), 1) or u < previous_u - 0.0001 \
		or not _json_int_equals(sample.get("sampler_sequence_index"), baseline_sequence + MOTION_TELEMETRY_FRAMES + index + 1) \
		or not _json_bool_equals(sample.get("sampled_after_player_physics_process"), true) \
		or not _json_bool_equals(sample.get("input_action_pressed"), false) \
		or not _json_bool_equals(sample.get("grounded"), true) or not _json_bool_equals(sample.get("in_boundary"), true) \
		or not _json_bool_equals(sample.get("camera_basis_unchanged"), true) \
		or not _json_vector3_matches_u(sample.get("player_position_m"), u) or not _json_vector3_finite(sample.get("velocity_mps")) \
		or str(sample.get("center_first_hit_object", "")) != ADAPTER.RECEIVER_KEY or sample.get("center_first_hit_sources", []) != [ADAPTER.SOURCE_KEY]:
			return false
		previous_frame = frame
		previous_u = u
	return _json_int_equals(manifest.get("braking_sample_count"), MOTION_BRAKING_FRAMES) \
		and _json_bool_equals(manifest.get("braking_samples_recorded_separately"), true) \
		and _json_bool_equals(manifest.get("all_braking_engine_frame_deltas_exactly_one"), true) \
		and _finite_float(manifest.get("post_braking_chain_u_m")) \
		and absf(float(manifest.post_braking_chain_u_m) - previous_u) <= 0.0001


func _telemetry_disk_numeric_mutations_reject(output_root: String, stage: String, authoritative: bool, manifest: Dictionary) -> bool:
	var round_trip_value: Variant = JSON.parse_string(JSON.stringify(manifest))
	if not round_trip_value is Dictionary \
	or not _sealed_telemetry_stage_matches(output_root, stage, authoritative, round_trip_value, false):
		return false
	var mutations: Array[Dictionary] = []
	var mutation := manifest.duplicate(true)
	mutation["input_sample_count"] = float(MOTION_TELEMETRY_FRAMES) + 0.5
	mutations.append(mutation)
	mutation = manifest.duplicate(true)
	var samples := mutation.get("samples", []) as Array
	if samples.is_empty() or not samples[0] is Dictionary:
		return false
	(samples[0] as Dictionary)["engine_physics_frame"] = float((samples[0] as Dictionary).get("engine_physics_frame", 0)) + 0.5
	mutations.append(mutation)
	mutation = manifest.duplicate(true)
	samples = mutation.get("samples", []) as Array
	(samples[0] as Dictionary)["sample_index"] = 1.5
	mutations.append(mutation)
	mutation = manifest.duplicate(true)
	samples = mutation.get("samples", []) as Array
	(samples[0] as Dictionary)["engine_physics_frame"] = float((samples[0] as Dictionary).get("engine_physics_frame", 0)) + 1.0
	mutations.append(mutation)
	for mutated: Dictionary in mutations:
		var parsed_mutation: Variant = JSON.parse_string(JSON.stringify(mutated))
		if not parsed_mutation is Dictionary \
		or _sealed_telemetry_stage_matches(output_root, stage, authoritative, parsed_mutation, false):
			return false
	return true


func _final_visual_stage_matches(output_root: String, authoritative: bool, manifest_name: String = "visual-motion.json", manifest_override: Variant = null, run_mutations: bool = true) -> bool:
	if manifest_name != "visual-motion.json" or not _root_stage_matches(output_root, "visual") \
	or not _sealed_static_stage_matches(output_root, "visual", authoritative, null, run_mutations) \
	or not _sealed_telemetry_stage_matches(output_root, "visual", authoritative, null, run_mutations):
		return false
	var path := output_root.path_join(manifest_name)
	var manifest_value: Variant = _json(path) if manifest_override == null else manifest_override
	if not manifest_value is Dictionary:
		return false
	var manifest := manifest_value as Dictionary
	if str(manifest.get("schema_version", "")) != "ti.d1-b225-prepromotion-candidate-visual-motion/3" \
	or str(manifest.get("generator_sha256", "")) != FileAccess.get_sha256(B225_GENERATOR) \
	or str(manifest.get("frozen_generator_sha256_argument", "")) != FileAccess.get_sha256(B225_GENERATOR) \
	or str(manifest.get("capture_override_sha256", "")) != CAPTURE_OVERRIDE_SHA256 \
	or not _json_bool_equals(manifest.get("authoritative_r3_evidence"), authoritative) \
	or str((manifest.get("r1_rejection_record", {}) as Dictionary).get("sha256", "")) != R1_REJECTION_SHA256 \
	or str((manifest.get("r2_rejection_record", {}) as Dictionary).get("sha256", "")) != R2_REJECTION_SHA256 \
	or manifest.get("source_dependency_hashes", {}) != DEPENDENCY_HASHES \
	or not _json_topology_matches(manifest.get("runtime_topology"), CANDIDATE_SEAM.CANDIDATE_WORLD_TOPOLOGY) \
	or not _runtime_receipt_matches(manifest.get("runtime_environment")) \
	or not _bindings_receipt_matches(manifest.get("bindings")) \
	or str(manifest.get("input_action", "")) != MOTION_INPUT_ACTION \
	or not _json_int_equals(manifest.get("visual_fixed_fps_operator_request"), VISUAL_FIXED_FPS) \
	or str(manifest.get("fixed_fps_operator_request_receipt_argument", "")) != str(VISUAL_FIXED_FPS) \
	or not _json_bool_equals(manifest.get("fixed_fps_receipt_is_operator_invocation_disclosure_not_engine_observation"), true) \
	or str(manifest.get("sampler_phase", "")) != "dedicated_node_physics_callback_strictly_after_player_controller" \
	or not _json_bool_equals(manifest.get("sampler_priority_strictly_after_player"), true) \
	or not _json_int_equals(manifest.get("sampler_process_physics_priority"), 100) \
	or not _json_int_equals(manifest.get("player_process_physics_priority"), 0) \
	or not _json_bool_equals(manifest.get("visual_outer_observations_are_not_claimed_consecutive"), true) \
	or not _json_bool_equals(manifest.get("dense_frame_thresholds_are_triggers_not_observed_positions"), true) \
	or not _json_bool_equals(manifest.get("all_dense_frame_receipts_queried_after_frame_post_draw"), true) \
	or not _json_bool_equals(manifest.get("all_dense_frame_states_match_latest_post_player_sampler_snapshot"), true) \
	or not _json_bool_equals(manifest.get("all_dense_frame_engine_frames_unique"), true) \
	or not _json_bool_equals(manifest.get("all_dense_frame_hashes_unique"), true) \
	or not _json_bool_equals(manifest.get("all_three_joins_bracketed_by_actual_image_positions"), true) \
	or not _json_bool_equals(manifest.get("braking_samples_recorded_separately"), true) \
	or not _json_bool_equals(manifest.get("run_action_pressed"), false) \
	or not _json_bool_equals(manifest.get("jetpack_action_pressed"), false) \
	or not _json_bool_equals(manifest.get("recovery_action_pressed"), false) \
	or not _json_bool_equals(manifest.get("chain_u_monotonic_non_decreasing"), true) \
	or not _json_bool_equals(manifest.get("canonical_entrypoint_reachable"), false) \
	or not _json_bool_equals(manifest.get("catalog_or_registry_promotion"), false) \
	or not _json_bool_equals(manifest.get("recognition_credit"), false) \
	or not _json_int_equals(manifest.get("player_transform_writes_after_input_began"), 0) \
	or not _json_int_equals(manifest.get("camera_transform_writes_after_input_began"), 0) \
	or not _json_int_equals(manifest.get("recovery_delta"), 0) \
	or (run_mutations and not _visual_disk_numeric_mutations_reject(output_root, authoritative, manifest_name, manifest)):
		return false
	for field: String in ["input_baseline_engine_physics_frame", "input_baseline_sampler_sequence_index", "input_start_engine_physics_frame", "input_end_engine_physics_frame", "input_elapsed_physics_ticks", "capture_first_engine_physics_frame", "capture_last_engine_physics_frame", "capture_endpoint_elapsed_physics_ticks", "capture_inclusive_engine_tick_span", "dense_visual_frame_count", "braking_sample_count"]:
		if not _json_integral_number(manifest.get(field)):
			return false
	var start_frame := int(manifest.input_start_engine_physics_frame)
	var end_frame := int(manifest.input_end_engine_physics_frame)
	if int(manifest.input_baseline_engine_physics_frame) != start_frame \
	or int(manifest.input_elapsed_physics_ticks) != end_frame - start_frame \
	or not _finite_float(manifest.get("input_duration_seconds_from_engine_ticks")) \
	or absf(float(manifest.input_duration_seconds_from_engine_ticks) - float(end_frame - start_frame) / B225_MOTION_PHYSICS_HZ) > 0.000001 \
	or not _finite_float(manifest.get("input_baseline_chain_u_m")) \
	or not _finite_float(manifest.get("start_chain_u_m")) \
	or not _finite_float(manifest.get("input_end_chain_u_m")) \
	or not _json_vector3_matches_u(manifest.get("input_baseline_player_position_m"), float(manifest.get("input_baseline_chain_u_m", INF))) \
	or not _json_vector3_matches_u(manifest.get("start_position_m"), float(manifest.get("start_chain_u_m", INF))) \
	or not _json_vector3_matches_u(manifest.get("input_end_position_m"), float(manifest.get("input_end_chain_u_m", INF))):
		return false
	var thresholds := manifest.get("dense_frame_thresholds", []) as Array
	var frames := manifest.get("dense_visual_frames", []) as Array
	var expected_thresholds := _motion_frame_thresholds()
	if thresholds.size() != 21 or frames.size() != 21 \
	or expected_thresholds.size() != frames.size() \
	or not _json_int_equals(manifest.get("dense_visual_frame_count"), frames.size()):
		return false
	var observations := manifest.get("outer_observations", []) as Array
	var previous_observation_frame := start_frame
	var previous_observation_sequence := int(manifest.input_baseline_sampler_sequence_index)
	var previous_observation_u := float(manifest.input_baseline_chain_u_m)
	var observations_by_frame := {}
	for observation_index in observations.size():
		var observation_value: Variant = observations[observation_index]
		if not observation_value is Dictionary:
			return false
		var observation := observation_value as Dictionary
		for field: String in ["outer_iteration", "engine_physics_frame", "engine_tick_gap_from_previous_observation", "sampler_sequence_index", "sampler_sequence_gap_from_previous_observation"]:
			if not _json_integral_number(observation.get(field)):
				return false
		if not _json_int_equals(observation.get("outer_iteration"), observation_index + 1) \
		or not _finite_float(observation.get("chain_u_m")) \
		or int(observation.engine_physics_frame) <= previous_observation_frame \
		or int(observation.sampler_sequence_index) <= previous_observation_sequence \
		or not _json_int_equals(observation.get("engine_tick_gap_from_previous_observation"), int(observation.engine_physics_frame) - previous_observation_frame) \
		or not _json_int_equals(observation.get("sampler_sequence_gap_from_previous_observation"), int(observation.sampler_sequence_index) - previous_observation_sequence) \
		or float(observation.chain_u_m) < previous_observation_u - 0.0001:
			return false
		previous_observation_frame = int(observation.engine_physics_frame)
		previous_observation_sequence = int(observation.sampler_sequence_index)
		previous_observation_u = float(observation.chain_u_m)
		observations_by_frame[previous_observation_frame] = observation
	if observations.is_empty() or previous_observation_frame != end_frame \
	or not _json_float_matches(manifest.get("input_end_chain_u_m"), previous_observation_u):
		return false
	var expected_image_files: Array[String] = []
	var frame_ids := {}
	var sampler_ids := {}
	var image_hashes := {}
	var previous_frame := -1
	var previous_sequence := -1
	var previous_u := -INF
	var frame_offsets_by_join: Array = [[], [], []]
	for index in frames.size():
		if not frames[index] is Dictionary or not thresholds[index] is Dictionary:
			return false
		var frame := frames[index] as Dictionary
		var threshold := thresholds[index] as Dictionary
		var expected_threshold := expected_thresholds[index] as Dictionary
		if not _json_int_equals(threshold.get("index"), index + 1) \
		or not _json_int_equals(threshold.get("join_index"), int(expected_threshold.join_index)) \
		or str(threshold.get("role", "")) != str(expected_threshold.role) \
		or not _json_float_matches(threshold.get("trigger_u_m"), float(expected_threshold.trigger_u_m)) \
		or not _json_float_matches(threshold.get("join_u_m"), float(expected_threshold.join_u_m)) \
		or not _json_float_matches(threshold.get("intended_join_offset_m"), float(expected_threshold.intended_join_offset_m)) \
		or not _json_float_matches(threshold.get("actual_trigger_tolerance_m"), VISUAL_TRIGGER_TOLERANCE_M):
			return false
		for field: String in ["index", "join_index", "trigger_engine_physics_frame", "trigger_sampler_sequence_index", "actual_engine_physics_frame", "actual_sampler_sequence_index", "post_render_engine_tick_delta", "post_render_sampler_sequence_delta", "bytes"]:
			if not _json_integral_number(frame.get(field)):
				return false
		if not _json_int_equals(frame.get("index"), index + 1) \
		or not _json_int_equals(frame.get("join_index"), int(threshold.get("join_index", -1))) \
		or str(frame.get("role", "")) != str(threshold.role):
			return false
		var trigger_frame := int(frame.trigger_engine_physics_frame)
		var trigger_sequence := int(frame.trigger_sampler_sequence_index)
		var actual_frame := int(frame.actual_engine_physics_frame)
		var actual_sequence := int(frame.actual_sampler_sequence_index)
		var trigger_observation := observations_by_frame.get(trigger_frame, {}) as Dictionary
		if actual_frame < trigger_frame or actual_sequence < trigger_sequence \
		or actual_frame <= previous_frame or actual_sequence <= previous_sequence or frame_ids.has(actual_frame) or sampler_ids.has(actual_sequence) \
		or trigger_observation.is_empty() \
		or not _json_int_equals(trigger_observation.get("sampler_sequence_index"), trigger_sequence) \
		or not _json_float_matches(trigger_observation.get("chain_u_m"), float(frame.get("trigger_observed_u_m", INF))) \
		or actual_frame - trigger_frame != actual_sequence - trigger_sequence \
		or not _json_int_equals(frame.get("post_render_engine_tick_delta"), actual_frame - trigger_frame) \
		or not _json_int_equals(frame.get("post_render_sampler_sequence_delta"), actual_sequence - trigger_sequence):
			return false
		for field: String in ["threshold_trigger_u_m", "trigger_observed_u_m", "actual_u_m", "actual_minus_trigger_u_m"]:
			if not _finite_float(frame.get(field)):
				return false
		var actual_u := float(frame.actual_u_m)
		var threshold_u := float(threshold.trigger_u_m)
		var trigger_u := float(frame.trigger_observed_u_m)
		var trigger_tolerance := float(threshold.actual_trigger_tolerance_m)
		if actual_u <= previous_u \
		or not _json_float_matches(frame.get("threshold_trigger_u_m"), threshold_u) \
		or trigger_u < threshold_u - 0.0001 or trigger_u > actual_u + 0.0001 \
		or absf(actual_u - threshold_u) > trigger_tolerance + 0.0001 \
		or not _json_float_matches(frame.get("actual_minus_trigger_u_m"), actual_u - threshold_u) \
		or not _json_vector3_matches_u(frame.get("actual_player_position_m"), actual_u) \
		or not _json_bool_equals(frame.get("actual_within_declared_trigger_tolerance"), true) \
		or not _json_bool_equals(frame.get("state_queried_after_frame_post_draw_before_image_read"), true) \
		or not _json_bool_equals(frame.get("latest_post_player_sampler_snapshot_read_after_frame_post_draw"), true) \
		or not _json_bool_equals(frame.get("actual_state_matches_latest_post_player_sampler_snapshot"), true) \
		or not _json_bool_equals(frame.get("no_await_between_actual_state_query_and_image_read_or_save"), true):
			return false
		var join_index := int(threshold.join_index)
		if join_index > 0:
			var join_u := float(threshold.join_u_m)
			var intended_offset := float(threshold.intended_join_offset_m)
			var actual_offset := actual_u - join_u
			if not _json_float_matches(threshold_u, join_u + intended_offset) \
			or not _json_float_matches(frame.get("join_u_m"), join_u) \
			or not _json_float_matches(frame.get("intended_join_offset_m"), intended_offset) \
			or not _json_float_matches(frame.get("actual_join_offset_m"), actual_offset):
				return false
			(frame_offsets_by_join[join_index - 1] as Array).append(actual_offset)
		elif frame.has("join_u_m") or frame.has("intended_join_offset_m") or frame.has("actual_join_offset_m"):
			return false
		var relative := str(frame.get("file", ""))
		var image_path := output_root.path_join(relative)
		var dimensions := frame.get("dimensions", []) as Array
		if not relative.begins_with("visual-motion-frames/") or FileAccess.get_sha256(image_path) != str(frame.get("sha256", "")) \
		or image_hashes.has(str(frame.get("sha256", ""))) \
		or not _json_int_equals(frame.get("bytes"), FileAccess.get_file_as_bytes(image_path).size()) \
		or dimensions.size() != 2 or not _json_int_equals(dimensions[0], STILL_SIZE.x) or not _json_int_equals(dimensions[1], STILL_SIZE.y):
			return false
		var image := Image.load_from_file(image_path)
		if image == null or image.is_empty() or image.get_size() != STILL_SIZE:
			return false
		expected_image_files.append(relative.get_file())
		frame_ids[actual_frame] = true
		sampler_ids[actual_sequence] = true
		image_hashes[str(frame.sha256)] = true
		previous_frame = actual_frame
		previous_sequence = actual_sequence
		previous_u = actual_u
	var actual_image_files := Array(DirAccess.get_files_at(output_root.path_join("visual-motion-frames")))
	actual_image_files.sort()
	expected_image_files.sort()
	var first_capture_frame := int((frames[0] as Dictionary).actual_engine_physics_frame)
	if actual_image_files != expected_image_files or not Array(DirAccess.get_directories_at(output_root.path_join("visual-motion-frames"))).is_empty() \
	or not _json_int_equals(manifest.get("capture_first_engine_physics_frame"), first_capture_frame) \
	or not _json_int_equals(manifest.get("capture_last_engine_physics_frame"), int((frames[-1] as Dictionary).actual_engine_physics_frame)) \
	or not _json_int_equals(manifest.get("capture_endpoint_elapsed_physics_ticks"), previous_frame - first_capture_frame) \
	or not _json_int_equals(manifest.get("capture_inclusive_engine_tick_span"), previous_frame - first_capture_frame + 1) \
	or not _finite_float(manifest.get("capture_endpoint_elapsed_seconds")) \
	or absf(float(manifest.capture_endpoint_elapsed_seconds) - float(previous_frame - first_capture_frame) / B225_MOTION_PHYSICS_HZ) > 0.000001:
		return false
	var joins := manifest.get("actual_join_brackets", []) as Array
	if joins.size() != RUN_JOIN_U_M.size():
		return false
	for index in joins.size():
		if not joins[index] is Dictionary:
			return false
		var join := joins[index] as Dictionary
		var offsets := join.get("actual_offsets_m", []) as Array
		var recomputed_offsets := frame_offsets_by_join[index] as Array
		if not _json_int_equals(join.get("join_index"), index + 1) or not _finite_float(join.get("join_u_m")) \
		or absf(float(join.join_u_m) - RUN_JOIN_U_M[index]) > 0.0001 or offsets.size() != 5 \
		or recomputed_offsets.size() != 5 \
		or not _json_integral_number(join.get("before_count")) or int(join.before_count) < 1 \
		or not _json_integral_number(join.get("after_count")) or int(join.after_count) < 1:
			return false
		var recomputed_before := 0
		var recomputed_after := 0
		var recomputed_minimum := INF
		var recomputed_maximum := -INF
		for offset_index in offsets.size():
			var offset: Variant = offsets[offset_index]
			var recomputed_offset: Variant = recomputed_offsets[offset_index]
			if not _finite_float(offset) or not _json_float_matches(offset, float(recomputed_offset)):
				return false
			var offset_m := float(recomputed_offset)
			if offset_m < -0.02: recomputed_before += 1
			if offset_m > 0.02: recomputed_after += 1
			recomputed_minimum = minf(recomputed_minimum, offset_m)
			recomputed_maximum = maxf(recomputed_maximum, offset_m)
		if not _json_int_equals(join.get("before_count"), recomputed_before) \
		or not _json_int_equals(join.get("after_count"), recomputed_after) \
		or not _finite_float(join.get("minimum_offset_m")) or absf(float(join.minimum_offset_m) - recomputed_minimum) > 0.0001 \
		or not _finite_float(join.get("maximum_offset_m")) or absf(float(join.maximum_offset_m) - recomputed_maximum) > 0.0001:
			return false
	var braking := manifest.get("braking_samples", []) as Array
	if braking.size() != MOTION_BRAKING_FRAMES or not _json_int_equals(manifest.get("braking_sample_count"), braking.size()):
		return false
	for index in braking.size():
		if not braking[index] is Dictionary:
			return false
		var sample := braking[index] as Dictionary
		if not _json_int_equals(sample.get("braking_sample_index"), index + 1) \
		or not _json_integral_number(sample.get("engine_physics_frame")) \
		or not _json_integral_number(sample.get("sampler_sequence_index")) \
		or not _json_integral_number(sample.get("engine_tick_gap_from_previous_observation")) \
		or not _json_integral_number(sample.get("sampler_sequence_gap_from_previous_observation")) \
		or not _json_bool_equals(sample.get("sampled_after_player_physics_process"), true) \
		or not _finite_float(sample.get("chain_u_m")) or not _json_vector3_matches_u(sample.get("player_position_m"), float(sample.chain_u_m)) \
		or not _json_vector3_finite(sample.get("velocity_mps")) or not _json_bool_equals(sample.get("input_action_pressed"), false):
			return false
	return true


func _visual_disk_numeric_mutations_reject(output_root: String, authoritative: bool, manifest_name: String, manifest: Dictionary) -> bool:
	var round_trip_value: Variant = JSON.parse_string(JSON.stringify(manifest))
	if not round_trip_value is Dictionary \
	or not _final_visual_stage_matches(output_root, authoritative, manifest_name, round_trip_value, false):
		return false
	var mutations: Array[Dictionary] = []
	var mutation := manifest.duplicate(true)
	mutation["dense_visual_frame_count"] = 21.5
	mutations.append(mutation)
	mutation = manifest.duplicate(true)
	var frames := mutation.get("dense_visual_frames", []) as Array
	if frames.is_empty() or not frames[0] is Dictionary:
		return false
	(frames[0] as Dictionary)["actual_engine_physics_frame"] = float((frames[0] as Dictionary).get("actual_engine_physics_frame", 0)) + 0.5
	mutations.append(mutation)
	mutation = manifest.duplicate(true)
	frames = mutation.get("dense_visual_frames", []) as Array
	(frames[0] as Dictionary)["bytes"] = float((frames[0] as Dictionary).get("bytes", 0)) + 0.5
	mutations.append(mutation)
	mutation = manifest.duplicate(true)
	frames = mutation.get("dense_visual_frames", []) as Array
	var dimensions := (frames[0] as Dictionary).get("dimensions", []) as Array
	if dimensions.size() != 2:
		return false
	dimensions[1] = float(dimensions[1]) + 0.5
	mutations.append(mutation)
	mutation = manifest.duplicate(true)
	frames = mutation.get("dense_visual_frames", []) as Array
	(frames[0] as Dictionary)["actual_engine_physics_frame"] = float((frames[0] as Dictionary).get("actual_engine_physics_frame", 0)) + 1.0
	mutations.append(mutation)
	for mutated: Dictionary in mutations:
		var parsed_mutation: Variant = JSON.parse_string(JSON.stringify(mutated))
		if not parsed_mutation is Dictionary \
		or _final_visual_stage_matches(output_root, authoritative, manifest_name, parsed_mutation, false):
			return false
	return true


func _json_vector3_finite(value: Variant) -> bool:
	if not value is Array:
		return false
	var values := value as Array
	return values.size() == 3 and _finite_float(values[0]) and _finite_float(values[1]) and _finite_float(values[2])


func _activation_receipt_matches(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	var receipt := value as Dictionary
	var expected := CANDIDATE_SEAM.activation_request()
	var actual_keys := Array(receipt.keys())
	var expected_keys := Array(expected.keys())
	actual_keys.sort()
	expected_keys.sort()
	if actual_keys != expected_keys:
		return false
	for key: String in ["schema_version", "candidate_id", "mode", "source_key", "receiver_key", "roof_key", "target_chunk_id", "adapter_config_path", "adapter_config_sha256"]:
		if str(receipt.get(key, "")) != str(expected.get(key, "")):
			return false
	return _json_topology_matches(receipt.get("expected_default_world_topology"), CANDIDATE_SEAM.DEFAULT_WORLD_TOPOLOGY) \
		and _json_topology_matches(receipt.get("expected_candidate_world_topology"), CANDIDATE_SEAM.CANDIDATE_WORLD_TOPOLOGY) \
		and _json_topology_matches(receipt.get("expected_candidate_delta"), CANDIDATE_SEAM.CANDIDATE_DELTA)


func _bindings_receipt_matches(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	var receipt := value as Dictionary
	var preserved := receipt.get("preserved_instance_ids", {}) as Dictionary
	if str(receipt.get("candidate_id", "")) != CANDIDATE_SEAM.CANDIDATE_ID \
	or str(receipt.get("candidate_stage", "")) != "prepromotion_live_ab_only" \
	or str(receipt.get("receiver_key", "")) != ADAPTER.RECEIVER_KEY \
	or receipt.get("source_keys", []) != [ADAPTER.SOURCE_KEY] \
	or not _json_bool_equals(receipt.get("canonical_entrypoint_reachable"), false) \
	or not _json_bool_equals(receipt.get("recognition_credit"), false) \
	or not _json_topology_matches(receipt.get("candidate_topology"), CANDIDATE_SEAM.CANDIDATE_WORLD_TOPOLOGY):
		return false
	var exact_counts := {
		"host_triangles": 28,
		"eligible_cladding_triangles": 8,
		"protected_generic_triangles": 20,
		"decorative_batches": 2,
		"decorative_boxes": 90,
		"decorative_triangles": 1080,
		"structural_body_count": 1,
		"structural_shape_count": 1,
		"spray_owner_count": 1,
		"navigation_owner_count": 0,
	}
	for key: String in exact_counts:
		if not _json_int_equals(receipt.get(key), int(exact_counts[key])):
			return false
	var postcommit := preserved.get("postcommit_node_instance_ids", {}) as Dictionary
	var node_id_keys := ["host_mesh_instance_id", "host_body_instance_id", "host_shape_instance_id", "roof_mesh_instance_id", "roof_body_instance_id", "roof_shape_instance_id"]
	var postcommit_keys := Array(postcommit.keys())
	var exact_node_id_keys := Array(node_id_keys)
	postcommit_keys.sort()
	exact_node_id_keys.sort()
	if postcommit_keys != exact_node_id_keys:
		return false
	for key: String in node_id_keys:
		if not _canonical_object_id_string(preserved.get(key), true) \
		or not _canonical_object_id_string(postcommit.get(key), true) \
		or str(preserved.get(key)) != str(postcommit.get(key)):
			return false
	var ordinary_mesh_id: Variant = preserved.get("ordinary_host_array_mesh_instance_id")
	var candidate_mesh_id: Variant = preserved.get("candidate_host_array_mesh_instance_id")
	if not _canonical_object_id_string(ordinary_mesh_id, false) \
	or not _canonical_object_id_string(candidate_mesh_id, false) \
	or str(ordinary_mesh_id) == str(candidate_mesh_id):
		return false
	return str(preserved.get("receiver_key", "")) == ADAPTER.RECEIVER_KEY \
		and str(preserved.get("source_key", "")) == ADAPTER.SOURCE_KEY \
		and str(preserved.get("object_id_encoding", "")) == "canonical_signed_decimal_strings_to_avoid_json_binary64_precision_loss" \
		and str(preserved.get("object_id_relation_scope", "")) == "single_candidate_process_precommit_metadata_to_postcommit_live_nodes_only" \
		and _json_bool_equals(preserved.get("all_six_preserved_node_instance_ids_equal_before_after"), true) \
		and _json_bool_equals(preserved.get("ordinary_and_candidate_array_mesh_instance_ids_unequal"), true) \
		and _json_bool_equals(preserved.get("cross_stage_object_id_equality_claimed"), false) \
		and _json_bool_equals(preserved.get("host_mesh_instance_preserved"), true) \
		and _json_bool_equals(preserved.get("host_array_mesh_resource_replaced_for_material_partition"), true) \
		and _json_bool_equals(preserved.get("host_collision_and_spray_nodes_preserved"), true) \
		and _json_bool_equals(preserved.get("protected_roof_nodes_preserved"), true) \
		and _json_bool_equals(preserved.get("recognition_credit"), false)


func _runtime_receipt_matches(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	var receipt := value as Dictionary
	var native_window := receipt.get("native_window", []) as Array
	var viewport := receipt.get("viewport", []) as Array
	return str(receipt.get("godot_version", "")).begins_with("4.7.2-stable") \
		and str(receipt.get("display_server", "")) == "macOS" \
		and str(receipt.get("rendering_method", "")) == "forward_plus" \
		and str(receipt.get("rendering_driver", "")) == "metal" \
		and str(receipt.get("video_adapter_api", "")) == "4.0" \
		and str(receipt.get("video_adapter", "")).begins_with("Apple M2") \
		and native_window.size() == 2 and _json_int_equals(native_window[0], STILL_SIZE.x) and _json_int_equals(native_window[1], STILL_SIZE.y) \
		and viewport.size() == 2 and _json_int_equals(viewport[0], STILL_SIZE.x) and _json_int_equals(viewport[1], STILL_SIZE.y) \
		and _json_int_equals(receipt.get("physics_ticks_per_second"), B225_MOTION_PHYSICS_HZ) \
		and str(receipt.get("physics_interpolation_setting_key", "")) == PHYSICS_INTERPOLATION_SETTING \
		and _json_bool_equals(receipt.get("physics_interpolation_project_setting_effective"), false) \
		and _json_bool_equals(receipt.get("scene_tree_physics_interpolation_enabled"), false) \
		and str(receipt.get("project_godot_sha256", "")) == str(DEPENDENCY_HASHES[PROJECT_SETTINGS_PATH])


func _root_stage_matches(output_root: String, stage: String) -> bool:
	if stage not in ["static", "telemetry", "visual"]:
		return false
	var actual_files := Array(DirAccess.get_files_at(output_root))
	var actual_directories := Array(DirAccess.get_directories_at(output_root))
	var expected_files := ["capture-manifest.json", "capture-override.cfg", "r1-rejection.json", "r2-rejection.json"]
	var expected_directories := ["images"]
	if stage in ["telemetry", "visual"]:
		expected_files.append("motion-telemetry.json")
	if stage == "visual":
		expected_files.append("visual-motion.json")
		expected_directories.append("visual-motion-frames")
	actual_files.sort()
	actual_directories.sort()
	expected_files.sort()
	expected_directories.sort()
	return actual_files == expected_files and actual_directories == expected_directories


func _runtime_environment_receipt_b225() -> Dictionary:
	return {"godot_version": Engine.get_version_info().get("string", "unknown"), "display_server": DisplayServer.get_name(), "rendering_method": str(RenderingServer.get_current_rendering_method()), "rendering_driver": str(RenderingServer.get_current_rendering_driver_name()), "video_adapter_api": str(RenderingServer.get_video_adapter_api_version()), "video_adapter": RenderingServer.get_video_adapter_name(), "native_window": [DisplayServer.window_get_size().x, DisplayServer.window_get_size().y], "viewport": [root.get_texture().get_width(), root.get_texture().get_height()], "physics_ticks_per_second": Engine.physics_ticks_per_second, "physics_interpolation_setting_key": PHYSICS_INTERPOLATION_SETTING, "physics_interpolation_project_setting_effective": bool(ProjectSettings.get_setting(PHYSICS_INTERPOLATION_SETTING, false)), "scene_tree_physics_interpolation_enabled": is_physics_interpolation_enabled(), "project_godot_sha256": FileAccess.get_sha256(PROJECT_SETTINGS_PATH)}


func _write_new_json(path: String, value: Dictionary) -> bool:
	if FileAccess.file_exists(path): return false
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(value, "  ") + "\n")
	file.close()
	return true


func _prepare_rehearsal_root() -> bool:
	var absolute := ProjectSettings.globalize_path(REHEARSAL_OUTPUT)
	if DirAccess.dir_exists_absolute(absolute) or DirAccess.make_dir_recursive_absolute(absolute) != OK:
		return false
	return _copy_new_file(R1_REJECTION_PATH, REHEARSAL_OUTPUT.path_join("r1-rejection.json"), R1_REJECTION_SHA256) \
		and _copy_new_file(R2_REJECTION_PATH, REHEARSAL_OUTPUT.path_join("r2-rejection.json"), R2_REJECTION_SHA256)


func _copy_new_file(source: String, target: String, expected_sha256: String) -> bool:
	if not FileAccess.file_exists(source) or FileAccess.file_exists(target) \
	or FileAccess.get_sha256(source) != expected_sha256:
		return false
	var file := FileAccess.open(target, FileAccess.WRITE)
	if file == null:
		return false
	file.store_buffer(FileAccess.get_file_as_bytes(source))
	file.close()
	return FileAccess.get_sha256(target) == expected_sha256


func _copy_capture_override(output_root: String) -> void:
	var target := output_root.path_join("capture-override.cfg")
	if FileAccess.file_exists(target): return
	var file := FileAccess.open(target, FileAccess.WRITE)
	if file != null:
		file.store_buffer(FileAccess.get_file_as_bytes(CAPTURE_OVERRIDE))
		file.close()
