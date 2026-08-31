extends SceneTree

const REGIONAL_QA_ANCHORS := preload("res://game/tests/regional_qa_anchors.gd")
const OUTPUT_ARG_PREFIX := "--visual-evidence-output="
const VEGETATION_QUICK_ARG := "--vegetation-evidence-quick"
const DEFAULT_OUTPUT_DIRECTORY := "res://evidence/first-playable/rendered-runtime-grounded"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_FERRY_SPAWN := Vector3(-104.364, 3.457, 786.024)
const EXPECTED_FERRY_YAW := -0.119
const EXPECTED_CHUNKS := 38
const EXPECTED_PLAYABLE_ROWS := 735
const EXPECTED_CONTEXT_ROWS := 4
const EXPECTED_MESHES := 729
const EXPECTED_TRIANGLES := 48381
const EXPECTED_BODIES := 466
const EXPECTED_VEGETATION_SEED := 1414092337
const EXPECTED_VEGETATION_INSTANCES := 124
const EXPECTED_VEGETATION_ASSETS := 15
const EXPECTED_VEGETATION_BATCHES := 19
const WORLD_SOLID_MASK := 1
const SPRAY_SURFACE_MASK := 1 << 2
const CAPTURE_WIDTH := 1440
const CAPTURE_HEIGHT := 900
const MIN_BILLBOARD_PROJECTED_WIDTH_RATIO := 0.30
const CAPTURE_PITCH_RADIANS := -0.13962634015954636
const SETTLE_START_HEIGHT_M := 3.0
const SETTLE_MAX_PHYSICS_FRAMES := 360
const SETTLE_CLEARANCE_TOLERANCE_M := 0.08
const CAPTURE_TIMEOUT_SECONDS := 180.0

# Each view faces a fixed island-side target so the result does not depend on
# input timing, mouse state, or GUI automation.
const CAPTURES := REGIONAL_QA_ANCHORS.CAPTURES
const OWNER_AERIAL_CAPTURES := [
	{
		"id": "09-owner-aerial-center",
		"region": "owner_aerial_center",
		"requested_xz": Vector2(-159.292, -104.818),
		"height_above_ground_m": 48.0,
		"yaw": 0.0,
		"pitch": -0.48,
		"intent": "Elevated owner-comparison view along the central/northern road and area surfaces",
	},
	{
		"id": "10-owner-aerial-east",
		"region": "owner_aerial_east",
		"requested_xz": Vector2(390.0, 385.0),
		"height_above_ground_m": 48.0,
		"yaw": 0.0,
		"pitch": -0.55,
		"intent": "Elevated owner-comparison view along the eastern shoreline road and area surfaces",
	},
]
const VEGETATION_GROUND_CAPTURES := [
	{
		"id": "11-vegetation-south-ground",
		"region": "vegetation_south_ground",
		"requested_xz": Vector2(-350.0, 140.0),
		"terrain_y_m": 2.884,
		"yaw": 0.0,
		"intent": "Ground view from serialized non-overlay land along the deliberate south palm rows",
	},
]
const VEGETATION_AERIAL_CAPTURES := [
	{
		"id": "12-vegetation-south-aerial",
		"region": "vegetation_south_aerial",
		"requested_xz": Vector2(-350.0, 140.0),
		"height_above_ground_m": 32.0,
		"yaw": 0.0,
		"pitch": -0.62,
		"intent": "Elevated view from serialized non-overlay land across the repeated south palm rows",
	},
	{
		"id": "13-naip-unknown-shrub-row",
		"region": "naip_unknown_shrub_row",
		"requested_xz": Vector2(454.0, -219.0),
		"height_above_ground_m": 35.0,
		"yaw": -0.927,
		"pitch": -1.42,
		"intent": "Elevated perpendicular view across six separate deterministic shrubs derived from NAIP unknown annotations",
	},
]

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(CAPTURE_TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Rendered evidence requires a real rendering display; the headless driver is dummy-only in this Godot build.")
		_finish(null)
		return
	var main_scene := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(main_scene != null, "Main scene could not be loaded."):
		_finish(null)
		return
	var main := main_scene.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var hud := main.get_node("Interface/HUD") as GameHUD
	var ready_reports: Array[Dictionary] = []
	var load_failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready_reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void:
		load_failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()})
	)
	root.add_child(main)
	var wait_started := Time.get_ticks_msec()
	while ready_reports.is_empty() and load_failures.is_empty() and Time.get_ticks_msec() - wait_started < 30000:
		await process_frame
	if not _require(load_failures.is_empty(), "Full-world load failed: %s" % [load_failures]) \
	or not _require(ready_reports.size() == 1, "Expected one world_ready signal, got %d." % ready_reports.size()):
		_finish(main)
		return

	var report: Dictionary = ready_reports[0]
	var evidence := world.get_runtime_evidence()
	var spawn := world.get_spawn_transform()
	if not _require(world.is_world_validated(), "World was not retained as validated.") \
	or not _require(str(report.get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content hash drifted.") \
	or not _require(FileAccess.get_sha256("res://generated/world/manifest.json") == EXPECTED_MANIFEST_SHA256, "Manifest file hash drifted.") \
	or not _require(spawn.origin.is_equal_approx(EXPECTED_FERRY_SPAWN), "Ferry spawn origin drifted.") \
	or not _require(spawn.basis.is_equal_approx(Basis(Vector3.UP, EXPECTED_FERRY_YAW)), "Ferry spawn yaw drifted.") \
	or not _require(evidence.chunks_loaded == EXPECTED_CHUNKS and evidence.chunks_expected == EXPECTED_CHUNKS, "Full chunk set was not loaded.") \
	or not _require(evidence.playable_rows == EXPECTED_PLAYABLE_ROWS and evidence.context_rows == EXPECTED_CONTEXT_ROWS, "Coverage counts drifted.") \
	or not _require(evidence.mesh_instances == EXPECTED_MESHES and evidence.triangles == EXPECTED_TRIANGLES, "Rendered geometry counts drifted.") \
	or not _require(evidence.static_bodies == EXPECTED_BODIES and evidence.shapes == EXPECTED_BODIES, "Physics counts drifted."):
		_finish(main)
		return
	if not _require(evidence.vegetation_seed == EXPECTED_VEGETATION_SEED and evidence.vegetation_instances == EXPECTED_VEGETATION_INSTANCES, "Vegetation seed/count drifted.") \
	or not _require(evidence.vegetation_assets == EXPECTED_VEGETATION_ASSETS and evidence.vegetation_multimesh_batches == EXPECTED_VEGETATION_BATCHES, "Vegetation batching drifted."):
		_finish(main)
		return

	var output_directory := _output_directory()
	var absolute_output := ProjectSettings.globalize_path(output_directory)
	var directory_error := DirAccess.make_dir_recursive_absolute(absolute_output)
	if not _require(directory_error == OK, "Could not create capture output directory: %s" % absolute_output):
		_finish(main)
		return

	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.set_gameplay_enabled(false)
	hud.set_paused(false)
	await physics_frame
	var captures: Array[Dictionary] = []
	var quick_vegetation_capture := VEGETATION_QUICK_ARG in OS.get_cmdline_user_args()
	if not quick_vegetation_capture:
		for definition: Dictionary in CAPTURES:
			var result := await _capture_view(definition, output_directory, world, player)
			if not _require(bool(result.get("ok", false)), str(result.get("message", "Capture failed."))):
				_finish(main)
				return
			captures.append(result.metadata)
		for definition: Dictionary in OWNER_AERIAL_CAPTURES:
			var result := await _capture_elevated_view(definition, output_directory, world, player)
			if not _require(bool(result.get("ok", false)), str(result.get("message", "Elevated owner-comparison capture failed."))):
				_finish(main)
				return
			captures.append(result.metadata)
	for definition: Dictionary in VEGETATION_GROUND_CAPTURES:
		var result := await _capture_view(definition, output_directory, world, player)
		if not _require(bool(result.get("ok", false)), str(result.get("message", "Vegetation ground capture failed."))):
			_finish(main)
			return
		captures.append(result.metadata)
	for definition: Dictionary in VEGETATION_AERIAL_CAPTURES:
		var result := await _capture_elevated_view(definition, output_directory, world, player)
		if not _require(bool(result.get("ok", false)), str(result.get("message", "Vegetation aerial capture failed."))):
			_finish(main)
			return
		captures.append(result.metadata)
	if not quick_vegetation_capture:
		var tag_result := await _capture_near_wall_tag(output_directory, world, player, evidence)
		if not _require(bool(tag_result.get("ok", false)), str(tag_result.get("message", "Near-wall tag capture failed."))):
			_finish(main)
			return
		captures.append(tag_result.metadata)
		var context_result := await _capture_context_views(output_directory, world, player)
		if not _require(bool(context_result.get("ok", false)), str(context_result.get("message", "Horizon-context captures failed."))):
			_finish(main)
			return
		for context_metadata: Dictionary in context_result.captures:
			captures.append(context_metadata)

	var manifest := {
		"schema_version": 2,
		"generator": "game/tests/rendered_visual_evidence_capture.gd",
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"project_rendering_contract": "Forward+",
		"viewport": [CAPTURE_WIDTH, CAPTURE_HEIGHT],
		"content_sha256": EXPECTED_CONTENT_SHA256,
		"manifest_sha256": EXPECTED_MANIFEST_SHA256,
		"world_counts": {
			"chunks": evidence.chunks_loaded,
			"playable_rows": evidence.playable_rows,
			"context_rows": evidence.context_rows,
			"meshes": evidence.mesh_instances,
			"triangles": evidence.triangles,
			"bodies": evidence.static_bodies,
			"shapes": evidence.shapes,
			"vegetation_seed": evidence.vegetation_seed,
			"vegetation_instances": evidence.vegetation_instances,
			"vegetation_assets": evidence.vegetation_assets,
			"vegetation_multimesh_batches": evidence.vegetation_multimesh_batches,
			"vegetation_rendered_triangles": evidence.vegetation_rendered_triangles,
		},
		"captures": captures,
	}
	var manifest_path := output_directory.path_join("capture-manifest.json")
	var manifest_file := FileAccess.open(manifest_path, FileAccess.WRITE)
	if not _require(manifest_file != null, "Could not write capture manifest: %s" % manifest_path):
		_finish(main)
		return
	manifest_file.store_string(JSON.stringify(manifest, "  ", false) + "\n")
	manifest_file.close()
	print("VISUAL_CAPTURE_MANIFEST: path=%s captures=%d content=%s manifest=%s" % [
		ProjectSettings.globalize_path(manifest_path), captures.size(), EXPECTED_CONTENT_SHA256, EXPECTED_MANIFEST_SHA256,
	])
	print("PASS: captured %d deterministic rendered views including south vegetation and the NAIP shrub row" % captures.size())
	_finish(main)


func _capture_view(definition: Dictionary, output_directory: String, world: WorldLoader, player: PlayerController) -> Dictionary:
	var requested_xz: Vector2 = definition.requested_xz
	var settlement := await _settle_player(requested_xz, definition.id, world, player, float(definition.terrain_y_m))
	if not bool(settlement.get("ok", false)):
		return settlement
	var yaw := float(definition.yaw)
	player.global_transform = Transform3D(Basis(Vector3.UP, yaw), player.global_position)
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	var pitch := float(definition.get("pitch", CAPTURE_PITCH_RADIANS))
	rig.rotation = Vector3.ZERO
	arm.rotation = Vector3(pitch, 0.0, 0.0)
	player.force_update_transform()
	rig.force_update_transform()
	arm.force_update_transform()
	if not await _wait_for_render(player):
		return {"ok": false, "message": "%s could not keep the pause overlay hidden for capture." % definition.id}
	var extra_metadata: Dictionary = settlement.metadata.duplicate(true)
	extra_metadata["yaw"] = yaw
	extra_metadata["pitch"] = pitch
	if definition.has("aim_target"):
		var aim_target := definition.aim_target as Vector3
		extra_metadata["camera_aim_target"] = [aim_target.x, aim_target.y, aim_target.z]
	return _save_current_view(definition, output_directory, player, extra_metadata)


func _capture_elevated_view(definition: Dictionary, output_directory: String, world: WorldLoader, player: PlayerController) -> Dictionary:
	var requested_xz: Vector2 = definition.requested_xz
	if not world.get_boundary().contains_position(Vector3(requested_xz.x, 0.0, requested_xz.y)):
		return {"ok": false, "message": "%s aerial anchor is outside the playable boundary." % definition.id}
	var ground_hit := _ground_hit(requested_xz, player)
	if ground_hit.is_empty():
		return {"ok": false, "message": "%s aerial anchor has no generated land support." % definition.id}
	_clear_gameplay_input()
	player.set_gameplay_enabled(false)
	var ground_y := float(ground_hit.position.y)
	var height := float(definition.height_above_ground_m)
	player.global_transform = Transform3D(Basis(Vector3.UP, float(definition.yaw)), Vector3(requested_xz.x, ground_y + height, requested_xz.y))
	player.velocity = Vector3.ZERO
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	rig.rotation = Vector3.ZERO
	arm.rotation = Vector3(float(definition.pitch), 0.0, 0.0)
	player.force_update_transform()
	rig.force_update_transform()
	arm.force_update_transform()
	if not await _wait_for_render(player):
		return {"ok": false, "message": "%s could not keep the pause overlay hidden for aerial capture." % definition.id}
	return _save_current_view(definition, output_directory, player, {
		"physics_grounded": false,
		"elevated_owner_comparison": true,
		"ground_y": ground_y,
		"ground_clearance_m": height,
		"yaw": float(definition.yaw),
		"pitch": float(definition.pitch),
	})


func _capture_near_wall_tag(output_directory: String, world: WorldLoader, player: PlayerController, evidence: RuntimeEvidence) -> Dictionary:
	var wall_face := _find_near_wall_face(world, player)
	if wall_face.is_empty():
		return {"ok": false, "message": "Could not find a deterministic eligible wall with an in-bound ground approach."}
	var approach: Vector3 = wall_face.approach
	var settlement := await _settle_player(Vector2(approach.x, approach.z), "06-near-wall-tag", world, player)
	if not bool(settlement.get("ok", false)):
		return settlement
	var target: Vector3 = wall_face.center
	player.global_transform = Transform3D(Basis.IDENTITY, player.global_position)
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	rig.rotation = Vector3.ZERO
	arm.rotation = Vector3.ZERO
	rig.look_at(target, Vector3.UP)
	player.force_update_transform()
	rig.force_update_transform()
	arm.force_update_transform()
	if not await _wait_for_render(player):
		return {"ok": false, "message": "Near-wall aim could not keep the pause overlay hidden."}
	var spray_hit := _camera_spray_hit(player)
	if spray_hit.is_empty():
		return {"ok": false, "message": "Near-wall camera ray did not hit a spray surface."}
	var hit_collider := spray_hit.get("collider") as CollisionObject3D
	var expected_object := str(wall_face.object_key)
	if hit_collider == null or not hit_collider.is_in_group("spray_receiver_wall") \
	or str(hit_collider.get_meta("derived_object_key", "")) != expected_object:
		return {"ok": false, "message": "Near-wall camera did not resolve the selected eligible wall first."}
	var controller := player.get_spray_controller()
	var pool := controller.tag_instances
	var active_before := pool.active_count()
	var placed_before := int(evidence.spray_counts.placed)
	controller.attempt_spray()
	await process_frame
	if not await _wait_for_render(player):
		return {"ok": false, "message": "Tagged-wall view could not keep the pause overlay hidden."}
	if pool.active_count() != active_before + 1 or int(evidence.spray_counts.placed) != placed_before + 1:
		return {"ok": false, "message": "Real spray controller did not place exactly one tag."}
	var tag := pool.get_child(pool.get_child_count() - 1) as Decal
	var tag_sources: Array = wall_face.source_keys
	if tag == null or str(tag.get_meta("derived_object_key", "")) != expected_object \
	or tag.get_meta("source_keys", []) != tag_sources \
	or tag.texture_albedo == null \
	or tag.global_position.distance_to(spray_hit.position) > 0.05:
		return {"ok": false, "message": "Placed tag identity, texture, or transform did not match the live wall hit."}
	var definition := {
		"id": "06-near-wall-tag",
		"region": "near_wall_tag",
		"intent": "Physics-grounded close wall view after one real-controller eligible spray placement",
	}
	var extra_metadata: Dictionary = settlement.metadata.duplicate(true)
	extra_metadata.merge({
		"camera_aim_target": [target.x, target.y, target.z],
		"spray_result": "placed",
		"tag_active_count": pool.active_count(),
		"tag_object": expected_object,
		"tag_sources": tag_sources,
		"tag_position": [tag.global_position.x, tag.global_position.y, tag.global_position.z],
		"tag_wall_normal": [spray_hit.normal.x, spray_hit.normal.y, spray_hit.normal.z],
		"tag_player_distance_m": player.global_position.distance_to(spray_hit.position),
		"tag_identity_matches_hit": true,
		"tag_texture_present": true,
	}, true)
	var saved := _save_current_view(definition, output_directory, player, extra_metadata)
	if bool(saved.get("ok", false)):
		print("VISUAL_TAG: object=%s sources=%s active=%d player_distance=%.3f tag=(%.3f,%.3f,%.3f)" % [
			expected_object, ",".join(tag_sources), pool.active_count(), player.global_position.distance_to(spray_hit.position),
			tag.global_position.x, tag.global_position.y, tag.global_position.z,
		])
	return saved


func _capture_context_views(output_directory: String, world: WorldLoader, player: PlayerController) -> Dictionary:
	var settlement := await _settle_player(Vector2(EXPECTED_FERRY_SPAWN.x, EXPECTED_FERRY_SPAWN.z), "07-08-horizon-context", world, player, 3.457)
	if not bool(settlement.get("ok", false)):
		return settlement
	var context_world := world.get_node("ContextWorld") as Node3D
	var billboard := context_world.get_node("SanFranciscoBillboard") as MeshInstance3D
	var ybi := context_world.get_node("YerbaBuenaIsland") as MeshInstance3D
	var bridge := context_world.get_node("BayBridge") as Node3D
	if billboard == null or ybi == null or bridge == null:
		return {"ok": false, "message": "Required billboard/YBI/bridge context nodes are missing."}
	var context_collisions := context_world.find_children("*", "CollisionObject3D", true, false)
	var billboard_collisions := billboard.find_children("*", "CollisionObject3D", true, false)
	var ybi_runtime_meshes := ybi.find_children("*", "MeshInstance3D", true, false)
	var bridge_runtime_meshes := bridge.find_children("*", "MeshInstance3D", true, false)
	var billboard_mesh := billboard.mesh as QuadMesh
	var billboard_material := billboard_mesh.material as StandardMaterial3D if billboard_mesh != null else null
	var billboard_texture := billboard_material.albedo_texture if billboard_material != null else null
	if billboard_mesh == null or billboard_material == null or billboard_texture == null \
	or not billboard.is_visible_in_tree() \
	or billboard.layers & 1 == 0 \
	or not billboard_collisions.is_empty() \
	or not context_collisions.is_empty() \
	or not ybi.is_visible_in_tree() \
	or ybi_runtime_meshes.is_empty() \
	or bridge_runtime_meshes.is_empty():
		return {"ok": false, "message": "Billboard/YBI/bridge visibility or collision-free context contract failed."}
	var camera := player.get_camera()
	var viewport_rect := root.get_visible_rect()
	var billboard_target := billboard.global_position
	_aim_camera_at(player, billboard_target)
	if not await _wait_for_render(player):
		return {"ok": false, "message": "SF-billboard view could not keep the pause overlay hidden."}
	var billboard_screen := camera.unproject_position(billboard_target)
	var billboard_projected_bounds := _project_billboard_bounds(camera, billboard_target, billboard_mesh.size)
	var billboard_projected_width_ratio := billboard_projected_bounds.size.x / viewport_rect.size.x
	var billboard_blocker := _world_blocker_between(camera.global_position, billboard_target, player)
	if camera.is_position_behind(billboard_target) \
	or not camera.is_position_in_frustum(billboard_target) \
	or not viewport_rect.has_point(billboard_screen) \
	or not viewport_rect.encloses(billboard_projected_bounds) \
	or billboard_projected_width_ratio < MIN_BILLBOARD_PROJECTED_WIDTH_RATIO \
	or not billboard_blocker.is_empty():
		return {"ok": false, "message": "SF billboard is not fully projected at a readable width inside the unobstructed camera view."}
	var sf_definition := {
		"id": "07-horizon-context",
		"region": "sf_horizon_context",
		"intent": "Physics-grounded ferry/southwest-facing view with unobstructed bridge-aligned SF billboard center",
	}
	var sf_metadata: Dictionary = settlement.metadata.duplicate(true)
	sf_metadata.merge({
		"camera_aim_target": [billboard_target.x, billboard_target.y, billboard_target.z],
		"billboard_visible": billboard.is_visible_in_tree(),
		"billboard_mesh_present": billboard.mesh != null,
		"billboard_render_layer_1": billboard.layers & 1 != 0,
		"billboard_collision_nodes": billboard_collisions.size(),
		"billboard_position": [billboard_target.x, billboard_target.y, billboard_target.z],
		"billboard_size": [billboard_mesh.size.x, billboard_mesh.size.y],
		"billboard_texture": billboard_texture.resource_path,
		"billboard_center_in_frustum": true,
		"billboard_center_screen": [billboard_screen.x, billboard_screen.y],
		"billboard_projected_bounds": [
			billboard_projected_bounds.position.x,
			billboard_projected_bounds.position.y,
			billboard_projected_bounds.size.x,
			billboard_projected_bounds.size.y,
		],
		"billboard_projected_width_px": billboard_projected_bounds.size.x,
		"billboard_projected_width_ratio": billboard_projected_width_ratio,
		"billboard_world_blocker": false,
		"context_collision_nodes": context_collisions.size(),
	}, true)
	var sf_saved := _save_current_view(sf_definition, output_directory, player, sf_metadata)
	if not bool(sf_saved.get("ok", false)):
		return sf_saved

	var ybi_mesh := ybi_runtime_meshes[0] as MeshInstance3D
	var bridge_mesh := bridge_runtime_meshes[0] as MeshInstance3D
	var ybi_target := ybi_mesh.global_transform * ybi_mesh.get_aabb().get_center()
	var bridge_target := bridge_mesh.global_transform * bridge_mesh.get_aabb().get_center()
	var context_target := (ybi_target + bridge_target) * 0.5
	_aim_camera_at(player, context_target)
	if not await _wait_for_render(player):
		return {"ok": false, "message": "YBI/bridge view could not keep the pause overlay hidden."}
	var ybi_screen := camera.unproject_position(ybi_target)
	var bridge_screen := camera.unproject_position(bridge_target)
	var ybi_blocker := _world_blocker_between(camera.global_position, ybi_target, player)
	var bridge_blocker := _world_blocker_between(camera.global_position, bridge_target, player)
	if camera.is_position_behind(ybi_target) or camera.is_position_behind(bridge_target) \
	or not camera.is_position_in_frustum(ybi_target) or not camera.is_position_in_frustum(bridge_target) \
	or not viewport_rect.has_point(ybi_screen) or not viewport_rect.has_point(bridge_screen) \
	or not ybi_blocker.is_empty() or not bridge_blocker.is_empty():
		return {"ok": false, "message": "YBI/bridge runtime mesh centers are not both unobstructed inside the rendered camera frustum."}
	var ybi_bridge_definition := {
		"id": "08-ybi-bridge-context",
		"region": "ybi_bridge_context",
		"intent": "Physics-grounded ferry/southeast-facing view with unobstructed projected YBI and Bay Bridge runtime-mesh centers",
	}
	var ybi_bridge_metadata: Dictionary = settlement.metadata.duplicate(true)
	ybi_bridge_metadata.merge({
		"camera_aim_target": [context_target.x, context_target.y, context_target.z],
		"ybi_visible": ybi.is_visible_in_tree(),
		"ybi_runtime_meshes": ybi_runtime_meshes.size(),
		"ybi_aabb_center": [ybi_target.x, ybi_target.y, ybi_target.z],
		"ybi_center_in_frustum": true,
		"ybi_center_screen": [ybi_screen.x, ybi_screen.y],
		"ybi_world_blocker": false,
		"bridge_runtime_meshes": bridge_runtime_meshes.size(),
		"bridge_aabb_center": [bridge_target.x, bridge_target.y, bridge_target.z],
		"bridge_center_in_frustum": true,
		"bridge_center_screen": [bridge_screen.x, bridge_screen.y],
		"bridge_world_blocker": false,
		"context_collision_nodes": context_collisions.size(),
	}, true)
	var ybi_bridge_saved := _save_current_view(ybi_bridge_definition, output_directory, player, ybi_bridge_metadata)
	if not bool(ybi_bridge_saved.get("ok", false)):
		return ybi_bridge_saved
	print("VISUAL_CONTEXT: billboard_screen=(%.1f,%.1f) billboard_width=%.1f billboard_collision=%d ybi_screen=(%.1f,%.1f) bridge_screen=(%.1f,%.1f) context_collision=%d" % [
		billboard_screen.x, billboard_screen.y, billboard_projected_bounds.size.x, billboard_collisions.size(), ybi_screen.x, ybi_screen.y,
		bridge_screen.x, bridge_screen.y, context_collisions.size(),
	])
	return {"ok": true, "captures": [sf_saved.metadata, ybi_bridge_saved.metadata]}


func _project_billboard_bounds(camera: Camera3D, center: Vector3, size: Vector2) -> Rect2:
	var half_right := camera.global_basis.x.normalized() * size.x * 0.5
	var half_up := camera.global_basis.y.normalized() * size.y * 0.5
	var screen_min := Vector2(INF, INF)
	var screen_max := Vector2(-INF, -INF)
	for world_corner: Vector3 in [
		center - half_right - half_up,
		center + half_right - half_up,
		center + half_right + half_up,
		center - half_right + half_up,
	]:
		var screen_corner := camera.unproject_position(world_corner)
		screen_min = screen_min.min(screen_corner)
		screen_max = screen_max.max(screen_corner)
	return Rect2(screen_min, screen_max - screen_min)


func _aim_camera_at(player: PlayerController, target: Vector3) -> void:
	player.global_transform = Transform3D(Basis.IDENTITY, player.global_position)
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	rig.rotation = Vector3.ZERO
	arm.rotation = Vector3.ZERO
	rig.look_at(target, Vector3.UP)
	player.force_update_transform()
	rig.force_update_transform()
	arm.force_update_transform()


func _world_blocker_between(origin: Vector3, target: Vector3, player: PlayerController) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(origin, target, WORLD_SOLID_MASK, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return player.get_world_3d().direct_space_state.intersect_ray(query)


func _settle_player(requested_xz: Vector2, capture_id: String, world: WorldLoader, player: PlayerController, expected_terrain_y_m := INF) -> Dictionary:
	var boundary := world.get_boundary()
	var requested_position := Vector3(requested_xz.x, 0.0, requested_xz.y)
	if not boundary.contains_position(requested_position):
		return {"ok": false, "message": "%s anchor is outside the playable boundary." % capture_id}
	var hit := _ground_hit(requested_xz, player)
	if hit.is_empty():
		return {"ok": false, "message": "%s anchor did not ray-hit generated collision." % capture_id}
	var collider := hit.get("collider") as Node
	var record := collider.get_parent() if collider != null else null
	var feature_kind := "" if record == null else str(record.get_meta("feature_kind", ""))
	if feature_kind != "land_ground":
		return {"ok": false, "message": "%s anchor hit %s rather than land_ground." % [capture_id, feature_kind]}
	_clear_gameplay_input()
	player.set_gameplay_enabled(false)
	var ground_y := float(hit.position.y)
	if not is_inf(expected_terrain_y_m) and absf(ground_y - expected_terrain_y_m) > 0.35:
		return {"ok": false, "message": "%s terrain elevation %.3f differs from its USGS anchor %.3f." % [capture_id, ground_y, expected_terrain_y_m]}
	var spawn_position := Vector3(requested_xz.x, ground_y + SETTLE_START_HEIGHT_M, requested_xz.y)
	player.global_transform = Transform3D(Basis.IDENTITY, spawn_position)
	player.velocity = Vector3.ZERO
	player.force_update_transform()
	var recovery_count_before := world.get_runtime_evidence().recovery_count
	paused = false
	player.set_gameplay_enabled(true)
	var settled := false
	var settle_frames := 0
	for frame in SETTLE_MAX_PHYSICS_FRAMES:
		paused = false
		await physics_frame
		settle_frames = frame + 1
		if player.is_on_floor() \
		and absf(player.global_position.y - ground_y) <= SETTLE_CLEARANCE_TOLERANCE_M \
		and absf(player.velocity.y) <= 0.05:
			settled = true
			break
	var settled_position := player.global_position
	var recovery_delta := world.get_runtime_evidence().recovery_count - recovery_count_before
	_clear_gameplay_input()
	player.set_gameplay_enabled(false)
	if not settled:
		return {"ok": false, "message": "%s player did not settle within %d physics frames." % [capture_id, SETTLE_MAX_PHYSICS_FRAMES]}
	var horizontal_drift := Vector2(settled_position.x - requested_xz.x, settled_position.z - requested_xz.y).length()
	var clearance := settled_position.y - ground_y
	if horizontal_drift > 0.05 or absf(clearance) > SETTLE_CLEARANCE_TOLERANCE_M or recovery_delta != 0:
		return {"ok": false, "message": "%s invalid settlement: drift=%.3f clearance=%.3f recovery_delta=%d." % [capture_id, horizontal_drift, clearance, recovery_delta]}
	print("VISUAL_SETTLED: id=%s spawn_y=%.3f settled_y=%.3f ground_y=%.3f clearance=%.3f frames=%d recovery_delta=%d" % [
		capture_id, spawn_position.y, settled_position.y, ground_y, clearance, settle_frames, recovery_delta,
	])
	return {
		"ok": true,
		"metadata": {
			"physics_grounded": true,
			"settle_spawn_y": spawn_position.y,
			"settled_y": settled_position.y,
			"ground_y": ground_y,
			"ground_clearance_m": clearance,
			"settle_physics_frames": settle_frames,
			"settle_horizontal_drift_m": horizontal_drift,
			"settle_recovery_delta": recovery_delta,
			"ground_feature": feature_kind,
			"ground_object": "" if record == null else str(record.get_meta("derived_object_key", record.name)),
			"ground_sources": [] if record == null else record.get_meta("source_keys", []),
			"in_boundary": boundary.contains_position(settled_position),
		},
	}


func _ground_hit(requested_xz: Vector2, player: PlayerController) -> Dictionary:
	var ray_from := Vector3(requested_xz.x, 200.0, requested_xz.y)
	var ray_to := Vector3(requested_xz.x, -20.0, requested_xz.y)
	var query := PhysicsRayQueryParameters3D.create(ray_from, ray_to, WORLD_SOLID_MASK, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return player.get_world_3d().direct_space_state.intersect_ray(query)


func _find_near_wall_face(world: WorldLoader, player: PlayerController) -> Dictionary:
	var best: Dictionary = {}
	var best_score := INF
	for record_value: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		var record := record_value as Node3D
		if record == null or str(record.get_meta("feature_kind", "")) != "building_wall":
			continue
		var collision_shape := record.get_node_or_null("Collision/Shape") as CollisionShape3D
		if collision_shape == null or not (collision_shape.shape is ConcavePolygonShape3D):
			continue
		var faces := (collision_shape.shape as ConcavePolygonShape3D).get_faces()
		for index in range(0, faces.size(), 3):
			var a: Vector3 = collision_shape.global_transform * faces[index]
			var b: Vector3 = collision_shape.global_transform * faces[index + 1]
			var c: Vector3 = collision_shape.global_transform * faces[index + 2]
			var cross := (b - a).cross(c - a)
			if cross.length_squared() < 0.04:
				continue
			var normal := -cross.normalized()
			var center := (a + b + c) / 3.0
			if absf(normal.y) > 0.1:
				continue
			for side_value: Variant in [1.0, -1.0]:
				var side := float(side_value)
				var approach: Vector3 = center + normal * side * 3.5
				if not world.get_boundary().contains_position(approach):
					continue
				var ground_hit := _ground_hit(Vector2(approach.x, approach.z), player)
				var ground_collider := ground_hit.get("collider") as Node if not ground_hit.is_empty() else null
				var ground_record := ground_collider.get_parent() if ground_collider != null else null
				if ground_record == null or str(ground_record.get_meta("feature_kind", "")) != "land_ground":
					continue
				var height_above_ground := center.y - float(ground_hit.position.y)
				if height_above_ground < 0.8 or height_above_ground > 4.5:
					continue
				var grounded_approach := Vector3(approach.x, float(ground_hit.position.y), approach.z)
				if grounded_approach.distance_to(center) > player.get_spray_controller().maximum_range_m - 0.1:
					continue
				var pivot_position := grounded_approach + Vector3(0.0, 2.0, 0.0)
				var aim_direction := (center - pivot_position).normalized()
				var expected_camera := pivot_position - aim_direction * 5.5
				var visibility_query := PhysicsRayQueryParameters3D.create(expected_camera, center + aim_direction, SPRAY_SURFACE_MASK, [player.get_rid()])
				visibility_query.collide_with_areas = false
				visibility_query.collide_with_bodies = true
				var visible_hit := player.get_world_3d().direct_space_state.intersect_ray(visibility_query)
				var visible_collider := visible_hit.get("collider") as CollisionObject3D if not visible_hit.is_empty() else null
				var object_key := str(record.get_meta("derived_object_key", record.name))
				if visible_collider == null or str(visible_collider.get_meta("derived_object_key", "")) != object_key:
					continue
				var score := Vector2(center.x - EXPECTED_FERRY_SPAWN.x, center.z - EXPECTED_FERRY_SPAWN.z).length_squared() + absf(height_above_ground - 1.5) * 100.0
				if score < best_score:
					best_score = score
					best = {
						"center": center,
						"normal": visible_hit.normal,
						"approach": grounded_approach,
						"object_key": object_key,
						"source_keys": record.get_meta("source_keys", []).duplicate(),
					}
	return best


func _camera_spray_hit(player: PlayerController) -> Dictionary:
	var camera := player.get_camera()
	var viewport_center := camera.get_viewport().get_visible_rect().size * 0.5
	var origin := camera.project_ray_origin(viewport_center)
	var direction := camera.project_ray_normal(viewport_center).normalized()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 1000.0, SPRAY_SURFACE_MASK, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return player.get_world_3d().direct_space_state.intersect_ray(query)


func _wait_for_render(player: PlayerController) -> bool:
	_force_unpaused(player)
	await physics_frame
	_force_unpaused(player)
	await process_frame
	_force_unpaused(player)
	await RenderingServer.frame_post_draw
	_force_unpaused(player)
	await process_frame
	_force_unpaused(player)
	await RenderingServer.frame_post_draw
	return _force_unpaused(player)


func _save_current_view(definition: Dictionary, output_directory: String, player: PlayerController, extra_metadata: Dictionary) -> Dictionary:
	var hud := player.get_parent().get_node("Interface/HUD") as GameHUD
	var pause_panel := hud.get_node("PausePanel") as Control
	if paused or pause_panel.visible:
		return {"ok": false, "message": "%s refused to save with the pause overlay visible." % definition.id}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		return {"ok": false, "message": "%s produced an empty viewport image." % definition.id}
	var image_size := image.get_size()
	if image_size != Vector2i(CAPTURE_WIDTH, CAPTURE_HEIGHT):
		return {"ok": false, "message": "%s image was %s, expected %dx%d." % [definition.id, image_size, CAPTURE_WIDTH, CAPTURE_HEIGHT]}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.1:
		return {"ok": false, "message": "%s image looks blank (sample colors=%d, luminance range=%.3f)." % [definition.id, sample.unique_colors, sample.luminance_range]}
	var filename := "%s.png" % definition.id
	var image_path := output_directory.path_join(filename)
	var save_error := image.save_png(image_path)
	if save_error != OK:
		return {"ok": false, "message": "%s could not save PNG (error %d)." % [definition.id, save_error]}
	var camera := player.get_camera()
	var metadata := {
		"id": definition.id,
		"region": definition.region,
		"intent": definition.intent,
		"file": filename,
		"sha256": FileAccess.get_sha256(image_path),
		"bytes": FileAccess.get_file_as_bytes(image_path).size(),
		"dimensions": [image_size.x, image_size.y],
		"player_position": [player.global_position.x, player.global_position.y, player.global_position.z],
		"camera_position": [camera.global_position.x, camera.global_position.y, camera.global_position.z],
		"camera_forward": [-camera.global_basis.z.x, -camera.global_basis.z.y, -camera.global_basis.z.z],
		"pause_overlay_visible": false,
		"sample_unique_colors": sample.unique_colors,
		"sample_luminance_range": sample.luminance_range,
	}
	metadata.merge(extra_metadata, true)
	print("VISUAL_CAPTURE: id=%s region=%s player=(%.3f,%.3f,%.3f) camera=(%.3f,%.3f,%.3f) grounded=%s clearance=%.3f image=%s sha256=%s colors=%d luminance_range=%.3f" % [
		definition.id, definition.region,
		player.global_position.x, player.global_position.y, player.global_position.z,
		camera.global_position.x, camera.global_position.y, camera.global_position.z,
		str(metadata.get("physics_grounded", false)), float(metadata.get("ground_clearance_m", INF)),
		ProjectSettings.globalize_path(image_path), metadata.sha256,
		int(sample.unique_colors), float(sample.luminance_range),
	])
	return {"ok": true, "metadata": metadata}


func _clear_gameplay_input() -> void:
	for action: StringName in ["move_forward", "move_back", "move_left", "move_right", "run", "jetpack"]:
		if InputMap.has_action(action):
			Input.action_release(action)


func _force_unpaused(player: PlayerController) -> bool:
	paused = false
	var hud := player.get_parent().get_node("Interface/HUD") as GameHUD
	hud.set_paused(false)
	return not paused and not (hud.get_node("PausePanel") as Control).visible


func _sample_image(image: Image) -> Dictionary:
	var colors := {}
	var minimum_luminance := 1.0
	var maximum_luminance := 0.0
	for sample_y in 20:
		var y := mini(image.get_height() - 1, int((float(sample_y) + 0.5) * image.get_height() / 20.0))
		for sample_x in 32:
			var x := mini(image.get_width() - 1, int((float(sample_x) + 0.5) * image.get_width() / 32.0))
			var color := image.get_pixel(x, y)
			colors[color.to_rgba32()] = true
			var luminance := color.get_luminance()
			minimum_luminance = minf(minimum_luminance, luminance)
			maximum_luminance = maxf(maximum_luminance, luminance)
	return {
		"unique_colors": colors.size(),
		"luminance_range": maximum_luminance - minimum_luminance,
	}


func _output_directory() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(OUTPUT_ARG_PREFIX):
			var value := argument.trim_prefix(OUTPUT_ARG_PREFIX).strip_edges()
			if not value.is_empty():
				return value.trim_suffix("/")
	return DEFAULT_OUTPUT_DIRECTORY


func _require(condition: bool, message: String) -> bool:
	if not condition:
		_fail(message)
		return false
	return true


func _fail(message: String) -> void:
	if _failure.is_empty():
		_failure = message
	push_error("VISUAL_CAPTURE_FAIL: %s" % message)


func _on_timeout() -> void:
	if not _finished:
		_fail("Capture did not finish within %.0f seconds." % CAPTURE_TIMEOUT_SECONDS)
		_finished = true
		quit(1)


func _finish(main: Node) -> void:
	if _finished:
		return
	_finished = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	paused = false
	if main != null and is_instance_valid(main):
		main.queue_free()
		await process_frame
	quit(0 if _failure.is_empty() else 1)
