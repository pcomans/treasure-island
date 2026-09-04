extends SceneTree

const OUTPUT := "res://evidence/first-playable/building-1-tower-grounded-correction-2026-09-04"
const CONFIG_PATH := "res://game/resources/facades/building_1_hero_model.json"
const TOWER_CHUNK_PATH := "res://generated/world/chunks/x_0__z_2.json"
const TOWER_WALL_KEY := "building:w1222720021:wall"
const TOWER_ROOF_KEY := "building:w1222720021:roof"
const TOWER_SOURCE_KEY := "w1222720021"
const CAPTURE_SIZE := Vector2i(1440, 900)
const WORLD_SOLID_MASK := 1 << 0
const TOWER_LOS_MASK := (1 << 0) | (1 << 2)
const TIMEOUT_SECONDS := 240.0
const MIN_TOWER_PROJECTED_HEIGHT_PX := 72.0
const MIN_TOWER_PROJECTED_WIDTH_PX := 42.0
const MIN_VIEW_SEPARATION_DEGREES := 24.0
const MIN_CAMERA_HEIGHT_ABOVE_GROUND_M := 1.0
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/building_1_tower_grounded_capture.gd"

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Tower grounded evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for tower grounded capture."):
		_finish(null)
		return
	var main := packed.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var reports: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, keys: Array) -> void: failures.append({"code": code, "message": message, "keys": keys.duplicate()}))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while reports.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 60000:
		await process_frame
	if not _require(failures.is_empty() and reports.size() == 1, "Actual world did not reach one clean ready state for tower grounded capture."):
		_finish(main)
		return
	var tower_wall := _record_node_for_key(world, TOWER_WALL_KEY)
	var tower_roof := _record_node_for_key(world, TOWER_ROOF_KEY)
	if not _require(tower_wall != null and tower_roof != null, "Both separately keyed tower runtime nodes must exist.") \
	or not _require(bool(tower_wall.get_meta("tower_separate_recognition_entity", false)) and bool(tower_roof.get_meta("tower_separate_recognition_entity", false)), "Tower runtime nodes lost separate-recognition metadata."):
		_finish(main)
		return
	var config := _json(CONFIG_PATH)
	var wall_record := _tower_record(TOWER_WALL_KEY)
	if not _require(not config.is_empty() and not wall_record.is_empty(), "Tower config/source record did not resolve."):
		_finish(main)
		return
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT.path_join("images"))) != OK:
		_fail("Could not create tower grounded evidence directory.")
		_finish(main)
		return

	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.set_gameplay_enabled(false)
	player.hide()
	var hud := main.get_node("Interface/HUD") as GameHUD
	hud.set_paused(false)
	hud.hide()
	var camera := player.get_camera()
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	if not _require(is_equal_approx(camera.fov, 70.0) and is_equal_approx(arm.spring_length, 5.5), "Capture must retain the shipped 70-degree, 5.5 m third-person camera."):
		_finish(main)
		return

	var selected := _frozen_candidates(wall_record)
	if not _require(selected.size() == 2, "Grounded tower candidates did not provide two distinct viewing azimuths."):
		_finish(main)
		return

	var captures: Array[Dictionary] = []
	var capture_ids := ["01-grounded-tower-family", "02-grounded-oblique-silhouette"]
	var view_kinds := ["ordinary_grounded_tower_family", "ordinary_grounded_oblique_tower_silhouette"]
	for index in 2:
		var candidate := selected[index] as Dictionary
		var posed := await _pose_candidate(main, world, player, wall_record, config, candidate)
		if not _require(bool(posed.get("ok", false)), str(posed.get("message", "Selected grounded tower pose no longer validates."))):
			_finish(main)
			return
		var saved := await _save_view(camera, capture_ids[index], view_kinds[index], posed.metadata as Dictionary)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Grounded tower image save failed."))):
			_finish(main)
			return
		captures.append(saved.metadata as Dictionary)

	var separation := _angle_separation(float(captures[0].view_azimuth_degrees), float(captures[1].view_azimuth_degrees))
	if not _require(separation >= MIN_VIEW_SEPARATION_DEGREES, "Retained grounded tower views are not angularly distinct."):
		_finish(main)
		return
	var runtime := world.get_runtime_evidence()
	var rejected_manifest := "res://evidence/first-playable/building-1-hero-2026-09-04/capture-manifest.json"
	var manifest := {
		"schema_version": "ti.building-1-tower-grounded-evidence/1",
		"review_status": "pending_independent_tower_re_review_not_self_accepted",
		"evidence_role": "capture-only correction for the separately keyed Building 1 observation tower; ordinary-height shipped player camera on physics-proven playable ground",
		"supersedes_tower_view_in": "evidence/first-playable/building-1-hero-2026-09-04/INDEPENDENT_REVIEW.md",
		"superseded_review_sha256": FileAccess.get_sha256("res://evidence/first-playable/building-1-hero-2026-09-04/INDEPENDENT_REVIEW.md"),
		"superseded_rejected_manifest_sha256": FileAccess.get_sha256(rejected_manifest),
		"correction_kind": "capture_only",
		"runtime_changed_for_correction": false,
		"runtime_files_changed_for_correction": [],
		"capture_command": COMMAND,
		"generator": "game/tests/building_1_tower_grounded_capture.gd",
		"generator_sha256": FileAccess.get_sha256("res://game/tests/building_1_tower_grounded_capture.gd"),
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"rendering_method": "Forward+",
		"rendering_driver": "Metal",
		"viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"shipped_player_camera": {"fov_degrees": camera.fov, "spring_length_m": arm.spring_length},
		"debug_overlays_visible": false,
		"hud_visible": hud.visible,
		"config_path": CONFIG_PATH,
		"config_sha256": FileAccess.get_sha256(CONFIG_PATH),
		"adapter_path": "res://game/scripts/world/facades/building_1_hero_model.gd",
		"adapter_sha256": FileAccess.get_sha256("res://game/scripts/world/facades/building_1_hero_model.gd"),
		"world_builder_sha256": FileAccess.get_sha256("res://game/scripts/world/world_chunk_builder.gd"),
		"generated_source_bytes_unchanged": true,
		"source_photography_shipped": false,
		"target_source_key": TOWER_SOURCE_KEY,
		"target_object_keys": [TOWER_WALL_KEY, TOWER_ROOF_KEY],
		"target_identity": "separately keyed observation/control tower associated with Building 1",
		"primary_reference": "https://npgallery.nps.gov/NRHP/GetAsset/NRHP/08000081_text",
		"reference_scope": "NPS NRHP 08000081 Section 7 pp. 6-7: octagonal plan, wider viewing platform, metal balustrade, pyramidal raised-seam roof, mixed/divided-light fenestration and rib/flute details",
		"truth_boundary": "exact source plan and runtime identity; vertical values and platform scale remain reversible production inference; no surveyed, as-built, interior or present-condition claim",
		"runtime_topology": {"records": runtime.playable_rows, "meshes": runtime.mesh_instances, "surfaces": runtime.surfaces, "triangles": runtime.triangles, "static_bodies": runtime.static_bodies, "shapes": runtime.shapes},
		"selection_contract": {"selection_mode": "two_source_run_anchored_fixed_ground_poses_after_bounded_search", "minimum_camera_height_above_ground_m": MIN_CAMERA_HEIGHT_ABOVE_GROUND_M, "minimum_projected_height_px": MIN_TOWER_PROJECTED_HEIGHT_PX, "minimum_projected_width_px": MIN_TOWER_PROJECTED_WIDTH_PX, "minimum_view_separation_degrees": MIN_VIEW_SEPARATION_DEGREES, "actual_view_separation_degrees": separation, "retained_pose_count": selected.size()},
		"captures": captures,
		"capture_count": captures.size(),
		"reviewer_instruction": "Open both PNGs at original detail before reading implementation metadata. Independently re-review w1222720021 only: require two distinct ordinary grounded views, a blind top-1 match, and at least two visible NPS-supported cues without relying on Building 1 location, color, IDs or this manifest. A recognition-undermining limitation is FAIL.",
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write grounded tower capture manifest.")
		_finish(main)
		return
	print("PASS: captured two pending-re-review fixed grounded tower views separation=%.2f topology=%d/%d/%d/%d" % [separation, runtime.mesh_instances, runtime.surfaces, runtime.triangles, runtime.static_bodies])
	_finish(main)


func _frozen_candidates(wall_record: Dictionary) -> Array[Dictionary]:
	var selected: Array[Dictionary] = []
	for spec in [
		{"run_index": 5, "distance_m": 44.0, "tangent_offset_m": 16.0, "camera_pitch_degrees": 0.0},
		{"run_index": 8, "distance_m": 42.0, "tangent_offset_m": -32.0, "camera_pitch_degrees": 0.0},
	]:
		var run_index := int(spec.run_index)
		var frame := _run_frame(wall_record, run_index)
		var midpoint := (frame.start as Vector3).lerp(frame.end as Vector3, 0.5)
		var approach := Vector3(midpoint.x, 0.0, midpoint.z) + (frame.normal as Vector3) * float(spec.distance_m) + (frame.tangent as Vector3) * float(spec.tangent_offset_m)
		selected.append({"run_index": run_index, "distance_m": float(spec.distance_m), "tangent_offset_m": float(spec.tangent_offset_m), "camera_pitch_degrees": float(spec.camera_pitch_degrees), "approach": approach, "target": Vector3(midpoint.x, 32.25, midpoint.z)})
	return selected


func _pose_candidate(main: GameMain, world: WorldLoader, player: PlayerController, wall_record: Dictionary, config: Dictionary, candidate: Dictionary, settle_render := true) -> Dictionary:
	var approach := candidate.approach as Vector3
	var ground_hit := _ground_hit(player, Vector2(approach.x, approach.z))
	if ground_hit.is_empty():
		return {"ok": false, "stage": "ground_empty"}
	var ground_collider := ground_hit.get("collider") as Node
	var ground_record := ground_collider.get_parent() if ground_collider != null else null
	var feature := "" if ground_record == null else str(ground_record.get_meta("feature_kind", ""))
	var ground_normal := ground_hit.get("normal", Vector3.ZERO) as Vector3
	if ground_record == null or feature not in ["land_ground", "road_path"] or ground_normal.dot(Vector3.UP) < 0.7:
		return {"ok": false, "stage": "ground_feature_%s" % feature}
	var ground_y := float((ground_hit.position as Vector3).y)
	player.set_gameplay_enabled(false)
	player.global_transform = Transform3D(Basis.IDENTITY, Vector3(approach.x, ground_y, approach.z))
	player.velocity = Vector3.ZERO
	player.force_update_transform()
	_aim_shipped_camera(player, candidate.target as Vector3, float(candidate.camera_pitch_degrees))
	if settle_render:
		if not await _wait_for_render(main, player):
			return {"ok": false, "message": "Grounded tower pose could not settle."}
	else:
		await physics_frame
		player.force_update_transform()
	var camera := player.get_camera()
	var camera_height := camera.global_position.y - ground_y
	if camera_height < MIN_CAMERA_HEIGHT_ABOVE_GROUND_M:
		return {"ok": false, "stage": "camera_height_%.3f" % camera_height}
	var los_screen := camera.unproject_position(candidate.target as Vector3)
	var viewport_rect := camera.get_viewport().get_visible_rect()
	if camera.is_position_behind(candidate.target as Vector3) or not viewport_rect.has_point(los_screen):
		return {"ok": false, "stage": "los_target_outside_viewport"}
	var los := _tower_los(player, candidate.target as Vector3)
	var collider := los.get("collider") as CollisionObject3D if not los.is_empty() else null
	if collider == null or str(collider.get_meta("derived_object_key", "")) != TOWER_WALL_KEY or collider.get_meta("source_keys", []) != [TOWER_SOURCE_KEY]:
		return {"ok": false, "stage": "los_%s" % ("empty" if collider == null else str(collider.get_meta("derived_object_key", "unknown")))}
	var bounds := _projected_tower_bounds(camera, wall_record, config)
	if not bool(bounds.get("ok", false)):
		return {"ok": false, "stage": "projection_invalid"}
	if float(bounds.height_px) < MIN_TOWER_PROJECTED_HEIGHT_PX or float(bounds.width_px) < MIN_TOWER_PROJECTED_WIDTH_PX:
		return {"ok": false, "stage": "projection_small"}
	if not bool(bounds.fully_inside_viewport):
		return {"ok": false, "stage": "projection_outside"}
	var center := _plan_centroid_from_wall(wall_record)
	var camera_delta := camera.global_position - center
	var azimuth := fposmod(rad_to_deg(atan2(camera_delta.z, camera_delta.x)), 360.0)
	var arm := (player.get_node("CameraPivot/SpringArm3D") as SpringArm3D)
	return {"ok": true, "metadata": {
		"physics_grounded_pose": true,
		"ground_y_m": ground_y,
		"ground_feature_kind": feature,
		"ground_object": str(ground_record.get_meta("derived_object_key", "")),
		"ground_sources": ground_record.get_meta("source_keys", []),
		"in_playable_boundary": world.get_boundary().contains_position(player.global_position),
		"player_position_m": _vector(player.global_position),
		"camera_position_m": _vector(camera.global_position),
		"camera_height_above_ground_m": camera_height,
		"camera_forward": _vector(-camera.global_basis.z),
		"camera_fov_degrees": camera.fov,
		"spring_length_m": arm.spring_length,
		"camera_pitch_degrees": rad_to_deg(arm.rotation.x),
		"view_azimuth_degrees": azimuth,
		"candidate_source_run": int(candidate.run_index),
		"candidate_outward_distance_m": float(candidate.distance_m),
		"candidate_tangent_offset_m": float(candidate.tangent_offset_m),
		"aim_target_m": _vector(candidate.target as Vector3),
		"exact_los_ray_kind": "direct_camera_to_in_frame_tower_point",
		"exact_los_target_viewport_px": [los_screen.x, los_screen.y],
		"exact_los_hit_object": str(collider.get_meta("derived_object_key", "")),
		"exact_los_hit_sources": collider.get_meta("source_keys", []),
		"exact_los_hit_position_m": _vector(los.get("position", Vector3.ZERO) as Vector3),
		"exact_los_distance_m": camera.global_position.distance_to(los.get("position", Vector3.ZERO) as Vector3),
		"tower_projected_bounds_px": bounds.bounds,
		"tower_projected_width_px": float(bounds.width_px),
		"tower_projected_height_px": float(bounds.height_px),
		"tower_fully_inside_viewport": bool(bounds.fully_inside_viewport),
		"hud_visible": false,
		"debug_overlays_visible": false,
	}}


func _aim_shipped_camera(player: PlayerController, target: Vector3, pitch_degrees: float) -> void:
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	rig.rotation = Vector3.ZERO
	arm.rotation = Vector3.ZERO
	rig.force_update_transform()
	var flat_target := Vector3(target.x, rig.global_position.y, target.z)
	rig.look_at(flat_target, Vector3.UP)
	rig.force_update_transform()
	arm.rotation.x = clampf(deg_to_rad(pitch_degrees), deg_to_rad(rig.minimum_pitch_degrees), deg_to_rad(rig.maximum_pitch_degrees))
	arm.force_update_transform()


func _tower_los(player: PlayerController, target: Vector3) -> Dictionary:
	var camera := player.get_camera()
	var origin := camera.global_position
	var direction := (target - origin).normalized()
	var distance := origin.distance_to(target) + 2.0
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * distance, TOWER_LOS_MASK, [player.get_rid()])
	return player.get_world_3d().direct_space_state.intersect_ray(query)


func _projected_tower_bounds(camera: Camera3D, wall_record: Dictionary, config: Dictionary) -> Dictionary:
	var vertical := config.vertical_production_inference_m as Dictionary
	var center := _plan_centroid_from_wall(wall_record)
	var scale := float(vertical.tower_platform_plan_scale)
	var points: Array[Vector3] = []
	for run_index in 10:
		var frame := _run_frame(wall_record, run_index)
		var source := frame.start as Vector3
		var scaled := center + (source - center) * scale
		for y in [float(vertical.four_story_roof_y), float(vertical.tower_platform_top_y) + 1.1]:
			points.append(Vector3(scaled.x, y, scaled.z))
		for y in [float(vertical.tower_glass_base_y), float(vertical.tower_glass_top_y)]:
			points.append(Vector3(source.x, y, source.z))
	points.append(Vector3(center.x, float(vertical.tower_roof_peak_y), center.z))
	var minimum := Vector2(INF, INF)
	var maximum := Vector2(-INF, -INF)
	for point in points:
		if camera.is_position_behind(point):
			return {"ok": false}
		var screen := camera.unproject_position(point)
		minimum.x = minf(minimum.x, screen.x)
		minimum.y = minf(minimum.y, screen.y)
		maximum.x = maxf(maximum.x, screen.x)
		maximum.y = maxf(maximum.y, screen.y)
	var viewport := Vector2(CAPTURE_SIZE)
	var inside := minimum.x >= 16.0 and minimum.y >= 16.0 and maximum.x <= viewport.x - 16.0 and maximum.y <= viewport.y - 16.0
	return {"ok": true, "bounds": [minimum.x, minimum.y, maximum.x - minimum.x, maximum.y - minimum.y], "width_px": maximum.x - minimum.x, "height_px": maximum.y - minimum.y, "fully_inside_viewport": inside}


func _save_view(camera: Camera3D, id: String, view_kind: String, extra: Dictionary) -> Dictionary:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE:
		return {"ok": false, "message": "%s produced an empty or wrong-sized image." % id}
	var path := OUTPUT.path_join("images/%s.png" % id)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save PNG." % id}
	var metadata := {
		"id": id,
		"file": "images/%s.png" % id,
		"view_kind": view_kind,
		"dimensions": [image.get_width(), image.get_height()],
		"bytes": FileAccess.get_file_as_bytes(path).size(),
		"sha256": FileAccess.get_sha256(path),
		"player_visible": false,
	}
	metadata.merge(extra, true)
	print("TOWER_GROUNDED_CAPTURE: image=%s sha256=%s" % [ProjectSettings.globalize_path(path), str(metadata.sha256)])
	return {"ok": true, "metadata": metadata}


func _wait_for_render(main: GameMain, player: PlayerController) -> bool:
	for _frame in 2:
		paused = false
		(main.get_node("Interface/HUD") as GameHUD).hide()
		player.set_gameplay_enabled(false)
		await physics_frame
		await process_frame
	await RenderingServer.frame_post_draw
	return not paused and not (main.get_node("Interface/HUD") as GameHUD).visible


func _ground_hit(player: PlayerController, xz: Vector2) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(Vector3(xz.x, 200.0, xz.y), Vector3(xz.x, -20.0, xz.y), WORLD_SOLID_MASK, [player.get_rid()])
	return player.get_world_3d().direct_space_state.intersect_ray(query)


func _record_node_for_key(world: WorldLoader, key: String) -> Node3D:
	for value: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if str(value.get_meta("derived_object_key", "")) == key and value.get_parent() != null and str(value.get_parent().name).contains("__"):
			return value as Node3D
	return null


func _tower_record(key: String) -> Dictionary:
	for value in _json(TOWER_CHUNK_PATH).get("records", []):
		var record := value as Dictionary
		if str(record.get("object_key", "")) == key:
			return record
	return {}


func _run_frame(record: Dictionary, run_index: int) -> Dictionary:
	var vertices := record.vertices as Array
	var normals := record.normals as Array
	var offset := run_index * 12
	var start := Vector3(float(vertices[offset]), float(vertices[offset + 1]), float(vertices[offset + 2]))
	var end := Vector3(float(vertices[offset + 3]), float(vertices[offset + 4]), float(vertices[offset + 5]))
	return {"start": start, "end": end, "tangent": (end - start).normalized(), "normal": Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized()}


func _plan_centroid_from_wall(record: Dictionary) -> Vector3:
	var sum := Vector3.ZERO
	for run_index in 10:
		sum += _run_frame(record, run_index).start as Vector3
	return sum / 10.0


func _angle_separation(first: float, second: float) -> float:
	var delta := absf(first - second)
	return minf(delta, 360.0 - delta)


func _write_json(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value, "  ", false) + "\n")
	file.close()
	return true


func _json(path: String) -> Dictionary:
	var value = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _vector(value: Vector3) -> Array[float]:
	return [value.x, value.y, value.z]


func _require(condition: bool, message: String) -> bool:
	if not condition:
		_fail(message)
	return condition


func _fail(message: String) -> void:
	if _failure.is_empty():
		_failure = message
	push_error(message)


func _finish(main: Node) -> void:
	if _finished:
		return
	_finished = true
	if main != null:
		root.remove_child(main)
		main.free()
	quit(1 if not _failure.is_empty() else 0)


func _on_timeout() -> void:
	if _finished:
		return
	_fail("Tower grounded capture timed out.")
	_finish(null)
