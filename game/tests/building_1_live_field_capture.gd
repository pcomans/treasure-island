extends SceneTree

const HELPER := preload("res://game/tests/support/building_1_exact_receiver_calibration.gd")
const LIVE_FIELD := preload("res://game/scripts/world/facades/building_1_live_field.gd")
const RECEIVER_KEY := "building:r16681702:wall"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const OUTPUT := "res://evidence/first-playable/treasure-island-building-1-live-ivory-field-2026-08-30"
const CAPTURE_SIZE := Vector2i(1440, 900)
const TIMEOUT_SECONDS := 300.0
const CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/building_1_live_field_capture.gd"
const EXPECTED_IMMUTABLE_HASHES := {
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	CHUNK_PATH: "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce",
	"res://game/resources/facades/building_1_exact_receiver_calibration.json": "10ab1f25d0f9d37ccbb20be9dfe77a37c66f63918b1fdf070c1de9c61633414a",
	"res://game/tests/support/building_1_exact_receiver_calibration.gd": "3a494ba38436b9f68ad02ddaf4e454a0a53c84a777a2999111a67dcc55dae75c",
	"res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres": "12d059d9d806c629225254f1aaf945be69a00ce5878db276ce299ad0c8cdbb9a",
	"res://game/resources/materials/world/building_1/building_1_chain_metres_aperiodic_field.gdshader": "a4a5df4fbb8fd4f13187ec284708879b540677ac2c827642b4c3040b4bce4c09",
	"res://discovery/facades/TREASURE_ISLAND_BUILDING_1_EXACT_RECEIVER_MITER_CORRECTION_ART_REVIEW.md": "499f24ae196a42c9c27737fb484c690bd2f228a0ebcc5ba3622606958cd1179e",
	"res://game/resources/facades/building_1_standalone_prototypes.json": "2014040edb3985be4aaae437749063474aacaedc0534b6d54e69b7dfd92612cc",
	"res://game/resources/facades/r133351_standalone_prototypes.json": "ecde7b80ba595f61d03bfd21f57407956c3b8988e381f0457f95bfe1aa580ad9",
	"res://evidence/first-playable/treasure-island-building-1-exact-receiver-miter-correction-2026-08-30/capture-manifest.json": "63ff0b15e9072b6894e78105a780c3aa401ac6ae58af37840dc501af939f1051",
}

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Building 1 live evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	for path: String in EXPECTED_IMMUTABLE_HASHES:
		if not _require(FileAccess.get_sha256(path) == str(EXPECTED_IMMUTABLE_HASHES[path]), "Immutable Building 1 input drifted: %s" % path):
			_finish(null)
			return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for Building 1 actual-world capture."):
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
	while reports.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 50000:
		await process_frame
	if not _require(failures.is_empty() and reports.size() == 1 and str(reports[0].get("content_sha256", "")) == CONTENT_SHA256, "Actual world did not reach one clean content-identical ready state."):
		_finish(main)
		return
	var evidence := world.get_runtime_evidence()
	if not _require(evidence.chunks_loaded == 38 and evidence.mesh_instances == 925 and evidence.surfaces == 935 and evidence.triangles == 50791, "Building 1 live render topology drifted.") \
	or not _require(evidence.static_bodies == 466 and evidence.shapes == 466, "Building 1 live integration changed collider topology."):
		_finish(main)
		return
	var receiver := _record_node_for_key(world)
	var record := _record_data()
	var receiver_contract := _receiver_contract(receiver, record)
	if not _require(bool(receiver_contract.get("ok", false)), str(receiver_contract.get("message", "Building 1 live receiver contract failed."))):
		_finish(main)
		return
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT.path_join("images"))) != OK:
		_fail("Could not create Building 1 live evidence directory.")
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.hide()
	player.set_gameplay_enabled(false)
	(main.get_node("Interface/HUD") as GameHUD).hide()
	var camera := Camera3D.new()
	camera.name = "Building1LiveFieldEvidenceCamera"
	camera.fov = 50.0
	camera.far = 5000.0
	camera.current = true
	main.add_child(camera)
	var sun := main.get_node("Sun") as DirectionalLight3D
	var original_sun := sun.rotation_degrees
	var overlay := _make_overlay()
	main.add_child(overlay)
	var detail := overlay.get_node("Detail") as Label
	var captures: Array[Dictionary] = []
	for pose_value: Variant in _poses(record, original_sun):
		var pose := pose_value as Dictionary
		detail.text = "BUILDING 1 ACTUAL-WORLD FIELD PROOF · B1-MAT-IVORY OUTER RUNS 21..51\n31 RUNS · 85.939934 m · SHARED-MITER JOINS · ZERO LIVE MODULES\n%s · PENDING INDEPENDENT ACTUAL-WORLD REVIEW" % str(pose.view_kind).replace("_", " ").to_upper()
		camera.position = pose.camera as Vector3
		camera.look_at(pose.target as Vector3, Vector3.UP)
		sun.rotation_degrees = pose.sun as Vector3
		var saved := await _save_view(camera, pose)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Building 1 live capture failed."))):
			_finish(main)
			return
		captures.append(saved.metadata as Dictionary)
	sun.rotation_degrees = original_sun
	var manifest := {
		"schema_version": "ti.building-1-live-ivory-field-evidence/1",
		"review_status": "pending_independent_actual_world_art_review_not_self_accepted",
		"evidence_role": "actual loaded-world proof of exactly one reviewed B1-MAT-IVORY shared-miter overlay on outer runs 21..51; zero module placements; no surveyed scale, completed elevation, or whole-building claim",
		"source_key": "r16681702", "receiver_key": RECEIVER_KEY,
		"generator": "game/tests/building_1_live_field_capture.gd", "capture_command": COMMAND,
		"godot_version": Engine.get_version_info().get("string", "unknown"), "display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(), "rendering_method": "Forward+", "rendering_driver": "Metal", "viewport": [1440, 900],
		"content_sha256": CONTENT_SHA256, "immutable_inputs_capture_time": EXPECTED_IMMUTABLE_HASHES,
		"generated_source_and_data_bytes_unchanged": true,
		"runtime_before_live_field": {"records": 729, "meshes": 924, "surfaces": 934, "triangles": 50729, "static_bodies": 466, "shapes": 466},
		"runtime_after_live_field": {"records": 729, "meshes": evidence.mesh_instances, "surfaces": evidence.surfaces, "triangles": evidence.triangles, "static_bodies": evidence.static_bodies, "shapes": evidence.shapes},
		"exact_runtime_delta": {"field_scopes": 1, "field_runs": 31, "overlay_meshes": 1, "overlay_surfaces": 1, "overlay_triangles": 62, "module_placements": 0, "module_meshes": 0, "collision_nodes": 0, "navigation_nodes": 0, "spray_nodes": 0},
		"receiver": receiver_contract,
		"live_field_metadata": receiver.get_meta("building_1_live_field", {}),
		"field_scope": {"field_id": "B1-MAT-IVORY", "asset_kind": "homogeneous_material_tile", "exact_ordered_runs": _runs(), "run_count": 31, "physical_length_m": 85.939934, "surface_area_m2": 1740.731069, "overlay_offset_m": 0.018, "join_geometry": "shared_xz_mitered_offset_junctions", "maximum_join_gap_m": 0.0, "maximum_join_phase_delta_m": 0.0, "primary_scale_m": 1.1, "secondary_scale_m": 0.32, "scale_surveyed": false},
		"truth_boundary": {"actual_world_review_status": LIVE_FIELD.ACTUAL_WORLD_REVIEW_STATUS, "module_placement_count": 0, "central_and_pav_live": false, "wing_base_door_band_live": false, "surveyed_material_scale": false, "completed_public_elevation": false, "whole_building_accepted": false},
		"captures": captures, "capture_count": captures.size(),
		"close_corrected_join_capture_ids": ["01-close-join-38-39", "02-close-join-42-43", "03-close-join-21-22"],
		"ordinary_capture_ids": ["05-nearest-gameplay-curve", "06-ordinary-public-curve"],
		"context_capture_ids": ["07-oblique-public-curve", "08-multiside-building-context", "09-whole-building-context", "11-whole-island"],
		"changed_light_capture_id": "10-changed-light-public-curve",
		"validity_inspection_only": "Inspect exact live field continuity, material behavior, receiver clearance, ordinary read, context, changed light and whole-island noninterference. Executor art acceptance is prohibited."
	}
	var isolation := {"schema_version": "ti.building-1-live-field-runtime-isolation/1", "result": "PASS", "content_sha256": CONTENT_SHA256, "runtime_before": manifest.runtime_before_live_field, "runtime_after": manifest.runtime_after_live_field, "exact_delta": manifest.exact_runtime_delta, "receiver_child_count": 3, "receiver_collision_faces": int((receiver.get_node("Collision/Shape") as CollisionShape3D).shape.get_faces().size()), "actual_world_review_status": LIVE_FIELD.ACTUAL_WORLD_REVIEW_STATUS, "generated_data_changed": false, "receiver_geometry_changed": false, "receiver_collision_changed": false, "navigation_changed": false, "spray_ownership_changed": false, "module_placements": 0}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest) or not _write_json(OUTPUT.path_join("runtime-isolation.json"), isolation):
		_fail("Could not write Building 1 live evidence metadata.")
		_finish(main)
		return
	print("PASS: captured %d native actual-world Building 1 field views at 729/925/935/50,791/466 with zero modules" % captures.size())
	_finish(main)


func _receiver_contract(receiver: Node3D, record: Dictionary) -> Dictionary:
	if receiver == null:
		return {"ok": false, "message": "Building 1 receiver node did not resolve."}
	var receiver_mesh := receiver.get_node_or_null("Mesh") as MeshInstance3D
	var body := receiver.get_node_or_null("Collision") as StaticBody3D
	var shape_node := receiver.get_node_or_null("Collision/Shape") as CollisionShape3D
	var live_root := receiver.get_node_or_null("Building1LiveIvoryField") as Node3D
	var field := live_root.get_node_or_null("B1_MAT_IVORY_Runs21To51") as MeshInstance3D if live_root != null else null
	if receiver_mesh == null or body == null or shape_node == null or live_root == null or field == null \
	or receiver.get_child_count() != 3 or (receiver_mesh.mesh as ArrayMesh).get_surface_count() != 1 \
	or _count_type(live_root, MeshInstance3D) != 1 or _count_surfaces(live_root) != 1 or _count_triangles(live_root) != 62 \
	or _count_type(live_root, CollisionObject3D) != 0 or _count_type(live_root, CollisionShape3D) != 0 \
	or _count_type(live_root, NavigationRegion3D) != 0 or _count_type(live_root, Decal) != 0 \
	or not body.is_in_group("spray_receiver_wall") or body.collision_layer != ((1 << 0) | (1 << 2)) \
	or (shape_node.shape as ConcavePolygonShape3D).get_faces().size() != (record.get("indices", []) as Array).size():
		return {"ok": false, "message": "Building 1 receiver render/collision/ownership contract drifted."}
	return {"ok": true, "child_count": receiver.get_child_count(), "generated_receiver_meshes": 1, "generated_receiver_surfaces": 1, "generated_receiver_triangles": 220, "overlay_meshes": 1, "overlay_surfaces": 1, "overlay_triangles": 62, "collision_triangles": int((shape_node.shape as ConcavePolygonShape3D).get_faces().size() / 3), "module_placements": 0, "collision_navigation_spray_owned_by_overlay": false}


func _poses(record: Dictionary, original_sun: Vector3) -> Array[Dictionary]:
	return [
		_boundary_pose(record, 38, 39, "01-close-join-38-39", "close_exact_live_sharp_join_38_to_39", 13.0, 17.0, original_sun),
		_boundary_pose(record, 42, 43, "02-close-join-42-43", "close_exact_live_maximum_miter_join_42_to_43", 13.0, 17.0, original_sun),
		_boundary_pose(record, 21, 22, "03-close-join-21-22", "close_exact_live_scope_start_join_21_to_22", 13.0, 17.0, original_sun),
		_chain_pose(record, 43.0, "04-macro-public-curve-85m", "full_85m_live_public_curve_macro", 82.0, 24.0, 0.0, original_sun),
		_chain_pose(record, 43.0, "05-nearest-gameplay-curve", "nearest_ordinary_gameplay_live_curve", 8.0, 8.2, 0.0, original_sun),
		_chain_pose(record, 43.0, "06-ordinary-public-curve", "ordinary_gameplay_live_public_curve", 28.0, 11.0, 0.0, original_sun),
		_chain_pose(record, 43.0, "07-oblique-public-curve", "oblique_actual_world_public_curve", 35.0, 16.0, 18.0, original_sun),
		{"id": "08-multiside-building-context", "view_kind": "multiside_actual_world_building_context", "camera": Vector3(-135.0, 48.0, 710.0), "target": Vector3(-7.0, 15.0, 744.0), "sun": original_sun, "representative_runs": [0, 21, 38, 51, 96]},
		{"id": "09-whole-building-context", "view_kind": "whole_building_context_not_acceptance", "camera": Vector3(-165.0, 72.0, 750.0), "target": Vector3(-8.0, 15.0, 737.0), "sun": original_sun, "representative_runs": [0, 21, 38, 51, 96, 100]},
		_chain_pose(record, 43.0, "10-changed-light-public-curve", "changed_light_full_live_public_curve", 55.0, 20.0, 8.0, Vector3(-18.0, 118.0, 0.0)),
		{"id": "11-whole-island", "view_kind": "whole_island_actual_loaded_world_context", "camera": Vector3(180.0, 1550.0, 300.0), "target": Vector3(-20.0, 0.0, 30.0), "sun": original_sun, "representative_runs": []},
	]


func _boundary_pose(record: Dictionary, before: int, after: int, id: String, kind: String, distance: float, camera_y: float, sun: Vector3) -> Dictionary:
	var frame := HELPER.boundary_frame(record, before, after)
	var target := frame.junction as Vector3
	target.y = 15.0
	var camera := target + (frame.normal as Vector3) * distance
	camera.y = camera_y
	return {"id": id, "view_kind": kind, "camera": camera, "target": target, "sun": sun, "representative_runs": [before, after]}


func _chain_pose(record: Dictionary, chain_m: float, id: String, kind: String, distance: float, camera_y: float, lateral: float, sun: Vector3) -> Dictionary:
	var frame := HELPER.chain_frame(record, _runs(), chain_m)
	var target := frame.wall_anchor as Vector3
	target.y = 15.0
	var camera := target + (frame.normal as Vector3) * distance + (frame.tangent as Vector3) * lateral
	camera.y = camera_y
	return {"id": id, "view_kind": kind, "camera": camera, "target": target, "sun": sun, "representative_runs": [21, 38, 42, 51]}


func _runs() -> Array[int]:
	var result: Array[int] = []
	for run_index in range(21, 52): result.append(run_index)
	return result


func _record_data() -> Dictionary:
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	for value: Variant in chunk.get("records", []):
		if str((value as Dictionary).get("object_key", "")) == RECEIVER_KEY: return value as Dictionary
	return {}


func _record_node_for_key(world: WorldLoader) -> Node3D:
	for value: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if str(value.get_meta("derived_object_key", "")) == RECEIVER_KEY and value.get_parent() != null and str(value.get_parent().name).contains("__"): return value as Node3D
	return null


func _make_overlay() -> CanvasLayer:
	var layer := CanvasLayer.new()
	var backdrop := ColorRect.new(); backdrop.color = Color(0.015, 0.02, 0.025, 0.86); backdrop.position = Vector2(24, 22); backdrop.size = Vector2(1392, 108); layer.add_child(backdrop)
	var detail := Label.new(); detail.name = "Detail"; detail.position = Vector2(44, 36); detail.add_theme_font_size_override("font_size", 15); detail.add_theme_color_override("font_color", Color("f4f0e8")); layer.add_child(detail)
	return layer


func _save_view(camera: Camera3D, pose: Dictionary) -> Dictionary:
	camera.force_update_transform()
	await process_frame; await RenderingServer.frame_post_draw; await process_frame; await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE: return {"ok": false, "message": "%s produced an invalid image." % str(pose.id)}
	var stats := _luminance_stats(image)
	if float(stats.range) < 0.1: return {"ok": false, "message": "%s lacks visual range." % str(pose.id)}
	var relative := "images/%s.png" % str(pose.id)
	var path := OUTPUT.path_join(relative)
	if image.save_png(path) != OK: return {"ok": false, "message": "%s could not save." % str(pose.id)}
	return {"ok": true, "metadata": {"id": pose.id, "view_kind": pose.view_kind, "file": relative, "sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [1440, 900], "sampled_luminance": stats, "camera_position_m": [camera.position.x, camera.position.y, camera.position.z], "target_position_m": [pose.target.x, pose.target.y, pose.target.z], "sun_rotation_degrees": [pose.sun.x, pose.sun.y, pose.sun.z], "representative_runs": pose.representative_runs}}


func _luminance_stats(image: Image) -> Dictionary:
	var low := 1.0; var high := 0.0; var total := 0.0; var count := 0
	for y in range(0, image.get_height(), 18):
		for x in range(0, image.get_width(), 18):
			var value := image.get_pixel(x, y).get_luminance(); low = minf(low, value); high = maxf(high, value); total += value; count += 1
	return {"minimum": snappedf(low, 0.000001), "maximum": snappedf(high, 0.000001), "range": snappedf(high - low, 0.000001), "mean": snappedf(total / float(count), 0.000001), "sample_count": count}


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children(): count += _count_type(child, node_type)
	return count


func _count_surfaces(node: Node) -> int:
	var count := (node as MeshInstance3D).mesh.get_surface_count() if node is MeshInstance3D and (node as MeshInstance3D).mesh != null else 0
	for child: Node in node.get_children(): count += _count_surfaces(child)
	return count


func _count_triangles(node: Node) -> int:
	var count := 0
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		var mesh := (node as MeshInstance3D).mesh
		for surface_index in mesh.get_surface_count(): count += int((mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3)
	for child: Node in node.get_children(): count += _count_triangles(child)
	return count


func _write_json(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(value, "  ") + "\n"); file.close(); return true


func _require(condition: bool, message: String) -> bool:
	if condition: return true
	_fail(message); return false


func _fail(message: String) -> void:
	if _failure.is_empty(): _failure = message
	push_error(message)


func _on_timeout() -> void:
	if not _finished: _fail("Timed out while capturing Building 1 live field evidence."); _finish(null)


func _finish(main: Node) -> void:
	if _finished: return
	_finished = true
	if main != null: main.queue_free()
	quit(1 if not _failure.is_empty() else 0)
