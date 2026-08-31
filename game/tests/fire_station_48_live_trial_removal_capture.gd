extends SceneTree

const ACCEPTED_MATERIAL_RUN_TRIALS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const OUTPUT := "res://evidence/first-playable/fire-station-48-live-trial-removal-2026-08-29"
const CAPTURE_SIZE := Vector2i(1440, 900)
const TIMEOUT_SECONDS := 240.0
const RECEIVER_KEY := "building:w764313741:wall"
const SOURCE_KEY := "w764313741"
const CHUNK_PATH := "res://generated/world/chunks/x_0__z_-2.json"
const MATERIAL_PATH := "res://game/resources/materials/world/fire_station_48/fire_station_48_primary.tres"
const SHADER_PATH := "res://game/resources/materials/world/batch_02/batch_02_homogeneous_field.gdshader"
const REGISTRY_PATH := "res://game/resources/facades/batch_03_material_registry.json"
const REVIEW_PATH := "res://discovery/facades/ACCEPTED_MATERIAL_RUN_TRIALS_ART_REVIEW.md"
const PRIOR_MANIFEST_PATH := "res://evidence/first-playable/accepted-material-run-trials-2026-08-29/capture-manifest.json"
const PRIOR_REJECTION_IMAGE := "res://evidence/first-playable/accepted-material-run-trials-2026-08-29/images/fire-station-48/02-ordinary-gameplay-distance.png"
const REJECTED_RUNS := [0, 1, 2, 3, 5, 6, 8, 9, 24, 25]
const REJECTED_LENGTH_M := 76.157
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_CHUNK_SHA256 := "c0e1f86787410d975ad90272482e5f4971c4aedc7eb83132cd28b22acf1a3456"
const EXPECTED_MATERIAL_SHA256 := "515135c3d0da6bb8eb8681e69d7e3f7818d896d948fe5dcc7c2bd8c6d076b188"
const EXPECTED_SHADER_SHA256 := "1918177080126199ddbfc0715a77b85a9355800479a098ec9b81c9726b7cc4d5"
const EXPECTED_REGISTRY_SHA256 := "31983ae1529e6248e93ec8d231d2b870de3979778b35eef6019cd19e1a964516"
const EXPECTED_REVIEW_SHA256 := "c89d34f28b7a65288182747a8fb866501b5b653ce3dca677e45406f0603663bd"
const EXPECTED_PRIOR_MANIFEST_SHA256 := "d5ac382a622fcec84fe8f3613e4b85461d656d53acec41a8e76ced21f3b72bd8"
const EXPECTED_PRIOR_REJECTION_IMAGE_SHA256 := "eb028d6c1f88a8f70366c85090e423703e5c22737d6ef0e54cb97e4094d49a99"
const EXPECTED_BUILDER_SHA256 := "c770a977e879c0d077acb8fb4d33b52d1bd6aa3b454a50ba8e2125cb71e8ba8d"
const EXPECTED_HELPER_SHA256 := "a0eadb57bfb1ea4fbbfc46ea9261dc7ff85cbdcb5c2975e009ab4d11dce000e9"
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/fire_station_48_live_trial_removal_capture.gd"

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Fire Station removal proof requires the real macOS rendering display.")
		_finish(null)
		return
	if not _input_hashes_match():
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for Fire Station removal proof."):
		_finish(null)
		return
	var main := packed.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var ready_reports: Array[Dictionary] = []
	var load_failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready_reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: load_failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()}))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while ready_reports.is_empty() and load_failures.is_empty() and Time.get_ticks_msec() - started < 40000:
		await process_frame
	if not _require(load_failures.is_empty() and ready_reports.size() == 1, "Full world did not reach one clean world_ready for removal proof.") \
	or not _require(str(ready_reports[0].get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content hash drifted before removal proof."):
		_finish(main)
		return
	var evidence := world.get_runtime_evidence()
	if not _require(evidence.chunks_loaded == 38 and evidence.mesh_instances == 729 and evidence.surfaces == 731 and evidence.triangles == 48389, "Post-removal whole-island topology drifted.") \
	or not _require(evidence.static_bodies == 466 and evidence.shapes == 466, "Post-removal collision totals drifted."):
		_finish(main)
		return
	var receiver := _record_node_for_key(world, RECEIVER_KEY)
	var record := _record_data()
	var receiver_proof := _placeholder_receiver_proof(receiver, record)
	if not _require(bool(receiver_proof.get("ok", false)), str(receiver_proof.get("message", "Fire Station placeholder proof failed."))):
		_finish(main)
		return
	var output_absolute := ProjectSettings.globalize_path(OUTPUT)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images")) == OK, "Could not create Fire Station removal evidence directory."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.hide()
	player.set_gameplay_enabled(false)
	(main.get_node("Interface/HUD") as GameHUD).hide()
	var camera := Camera3D.new()
	camera.name = "FireStationRemovalEvidenceCamera"
	camera.fov = 50.0
	camera.far = 5000.0
	camera.current = true
	main.add_child(camera)
	var sun := main.get_node("Sun") as DirectionalLight3D
	var original_sun_rotation := sun.rotation_degrees
	var overlay := _make_overlay()
	main.add_child(overlay)
	var detail := overlay.get_node("Detail") as Label
	var captures: Array[Dictionary] = []
	for pose: Dictionary in _poses(record):
		detail.text = "FIRE STATION 48 · REJECTED LIVE TRIAL REMOVED\nreceiver %s · all 26 runs restored to generated placeholder\n%s · EXCLUSION PROOF ONLY — NOT ART ACCEPTANCE" % [RECEIVER_KEY, str(pose.view_kind).replace("_", " ").to_upper()]
		camera.position = pose.camera as Vector3
		camera.look_at(pose.target as Vector3, Vector3.UP)
		sun.rotation_degrees = pose.sun as Vector3
		var capture := await _save_view(camera, sun, pose)
		if not _require(bool(capture.get("ok", false)), str(capture.get("message", "Removal capture failed."))):
			_finish(main)
			return
		captures.append(capture.metadata as Dictionary)
	sun.rotation_degrees = original_sun_rotation
	detail.text = "WHOLE-ISLAND POST-REMOVAL LOAD · 38/38 chunks · 729 meshes · 731 surfaces\n48,389 render triangles · 466 collision bodies/shapes\nChapel + Dormitory remain · Fire Station placeholder restored · NOT ART ACCEPTANCE"
	var whole_pose := {"id": "04-whole-island-load", "view_kind": "whole_island_post_removal_load", "camera": Vector3(180.0, 1550.0, 300.0), "target": Vector3(-20.0, 0.0, 30.0), "sun": original_sun_rotation, "representative_run": -1}
	camera.position = whole_pose.camera
	camera.look_at(whole_pose.target, Vector3.UP)
	var whole_capture := await _save_view(camera, sun, whole_pose)
	if not _require(bool(whole_capture.get("ok", false)), str(whole_capture.get("message", "Whole-island removal capture failed."))):
		_finish(main)
		return
	captures.append(whole_capture.metadata as Dictionary)
	var manifest := {
		"schema_version": "ti.fire-station-48-live-trial-removal-evidence/1",
		"status": "live_trial_removed_placeholder_restored_independent_correction_review_pending",
		"evidence_role": "mechanical_exclusion_and_generated_placeholder_restoration_proof_not_art_acceptance",
		"generator": "game/tests/fire_station_48_live_trial_removal_capture.gd", "capture_command": COMMAND,
		"godot_version": Engine.get_version_info().get("string", "unknown"), "display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(), "rendering_method": "Forward+", "rendering_driver": "Metal", "viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"independent_review": {"path": REVIEW_PATH, "sha256": EXPECTED_REVIEW_SHA256, "verdict": "REJECT_CORRECTABLE", "failure": "unsupported repeating broad vertical facade-scale value bands"},
		"before": {"receiver_key": RECEIVER_KEY, "source_key": SOURCE_KEY, "live_material_path": MATERIAL_PATH, "accepted_runs": REJECTED_RUNS, "accepted_length_m": REJECTED_LENGTH_M, "surface_names": ["placeholder_runs", "accepted_material_runs"], "world_surfaces": 732, "prior_manifest": PRIOR_MANIFEST_PATH, "prior_manifest_sha256": EXPECTED_PRIOR_MANIFEST_SHA256, "ordinary_distance_rejection_image": PRIOR_REJECTION_IMAGE, "ordinary_distance_rejection_image_sha256": EXPECTED_PRIOR_REJECTION_IMAGE_SHA256},
		"after": {"receiver_key": RECEIVER_KEY, "source_key": SOURCE_KEY, "live_material": "generated building_wall placeholder", "live_material_resource_name": str(receiver_proof.material_name), "live_material_surface_count": int(receiver_proof.surface_count), "surface_names": receiver_proof.surface_names, "placeholder_runs": receiver_proof.placeholder_runs, "accepted_material_runs": [], "accepted_material_metadata": false, "modules": 0, "world_surfaces": evidence.surfaces},
		"retained_prototype": {"path": MATERIAL_PATH, "sha256": EXPECTED_MATERIAL_SHA256, "registry_path": REGISTRY_PATH, "registry_sha256": EXPECTED_REGISTRY_SHA256, "shared_shader_path": SHADER_PATH, "shared_shader_sha256": EXPECTED_SHADER_SHA256, "correction_status": "not_attempted_not_authorized"},
		"runtime_inputs": {"content_sha256": EXPECTED_CONTENT_SHA256, "generated_manifest_sha256": EXPECTED_MANIFEST_SHA256, "generated_chunk_sha256": EXPECTED_CHUNK_SHA256, "world_chunk_builder_sha256": EXPECTED_BUILDER_SHA256, "accepted_run_helper_sha256": EXPECTED_HELPER_SHA256},
		"world_counts": {"chunks": evidence.chunks_loaded, "records": 729, "meshes": evidence.mesh_instances, "surfaces": evidence.surfaces, "triangles": evidence.triangles, "static_bodies": evidence.static_bodies, "shapes": evidence.shapes},
		"receiver_invariants": {"render_triangles": int(receiver_proof.render_triangles), "collision_triangles": int(receiver_proof.collision_triangles), "duplicate_or_coplanar_render_triangles": false, "collision_unchanged": true, "spray_identity_unchanged": true, "generated_geometry_unchanged": true},
		"preserved_live_trials": [{"receiver_key": "building:w291189336:wall", "runs": [9, 10], "length_m": 16.362}, {"receiver_key": "building:w291189926:wall", "runs": [0, 1, 2, 3, 4, 5], "length_m": 49.124}],
		"captures": captures, "capture_count": captures.size(),
		"remaining_correction_brief": "Do not edit in this round. In a separately authorized correction, make Fire Station albedo phase-neutral at the existing mean Color(0.595, 0.6275, 0.5825, 1), set color_variation to 0.0, retain roughness 0.81 and relief 0.0, add no normal/joint/panel/opening/motif, then recapture the exact receiver and obtain independent acceptance before any reattachment.",
		"limitations": ["This proof establishes exclusion and restored placeholder coverage, not Fire Station material or whole-building art acceptance.", "The rejected prototype and prior failure evidence remain intact for a later separately authorized correction.", "Chapel and Dormitory remain bounded by their independent exact-run limitations; no other coverage is authorized."],
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write Fire Station removal manifest.")
		_finish(main)
		return
	print("PASS: captured Fire Station close/ordinary/changed-light generated-placeholder exclusion proof plus one 731-surface whole-island load proof to %s" % output_absolute)
	_finish(main)


func _input_hashes_match() -> bool:
	var checks := {
		"res://generated/world/manifest.json": EXPECTED_MANIFEST_SHA256,
		CHUNK_PATH: EXPECTED_CHUNK_SHA256,
		MATERIAL_PATH: EXPECTED_MATERIAL_SHA256,
		SHADER_PATH: EXPECTED_SHADER_SHA256,
		REGISTRY_PATH: EXPECTED_REGISTRY_SHA256,
		REVIEW_PATH: EXPECTED_REVIEW_SHA256,
		PRIOR_MANIFEST_PATH: EXPECTED_PRIOR_MANIFEST_SHA256,
		PRIOR_REJECTION_IMAGE: EXPECTED_PRIOR_REJECTION_IMAGE_SHA256,
		"res://game/scripts/world/world_chunk_builder.gd": EXPECTED_BUILDER_SHA256,
		"res://game/scripts/world/facades/accepted_material_run_trials.gd": EXPECTED_HELPER_SHA256,
	}
	for path: String in checks:
		if not _require(FileAccess.get_sha256(path) == str(checks[path]), "Removal proof input hash drifted: %s" % path):
			return false
	return true


func _record_data() -> Dictionary:
	var parsed := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	for value: Variant in parsed.get("records", []):
		var record := value as Dictionary
		if str(record.get("object_key", "")) == RECEIVER_KEY:
			return record
	return {}


func _record_node_for_key(world: WorldLoader, key: String) -> Node3D:
	for value: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if str(value.get_meta("derived_object_key", "")) == key:
			return value as Node3D
	return null


func _placeholder_receiver_proof(receiver: Node3D, record: Dictionary) -> Dictionary:
	if receiver == null or record.is_empty() or receiver.get_meta("source_keys", []) != [SOURCE_KEY]:
		return {"ok": false, "message": "Exact Fire Station receiver/source did not resolve."}
	var mesh_instance := receiver.get_node_or_null("Mesh") as MeshInstance3D
	var body := receiver.get_node_or_null("Collision") as StaticBody3D
	var shape_node := receiver.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	if mesh_instance == null or not (mesh_instance.mesh is ArrayMesh) or body == null or shape == null:
		return {"ok": false, "message": "Fire Station mesh/collision receiver is incomplete."}
	var mesh := mesh_instance.mesh as ArrayMesh
	var material := mesh.surface_get_material(0) as StandardMaterial3D if mesh.get_surface_count() == 1 else null
	var placeholder_runs := _runs_for_surface(mesh, 0) if mesh.get_surface_count() == 1 else []
	var expected_runs: Array[int] = []
	for run_index in int(record.exterior_foundation_segments):
		expected_runs.append(run_index)
	var render_signatures := _triangle_signatures_for_mesh(mesh)
	var collision_signatures := _triangle_signatures_for_faces(shape.get_faces())
	var ok := not ACCEPTED_MATERIAL_RUN_TRIALS.matches_record(record) \
		and ACCEPTED_MATERIAL_RUN_TRIALS.metadata_for(RECEIVER_KEY).is_empty() \
		and not receiver.has_meta("accepted_material_run_trial") \
		and receiver.get_child_count() == 2 \
		and mesh.get_surface_count() == 1 \
		and mesh.surface_get_name(0) == "generated_record" \
		and material != null and material.resource_name == "building_wall" \
		and material.resource_path != MATERIAL_PATH \
		and placeholder_runs == expected_runs \
		and render_signatures.size() == (record.indices as Array).size() / 3 \
		and _sorted_keys(render_signatures) == _sorted_keys(collision_signatures) \
		and mesh.get_faces().size() == (record.indices as Array).size() \
		and shape.get_faces().size() == (record.indices as Array).size() \
		and body.collision_layer == 5 and body.collision_mask == 0 \
		and body.is_in_group("spray_receiver_wall") \
		and (receiver.find_children("*", "MeshInstance3D", true, false) as Array).size() == 1 \
		and (receiver.find_children("*Facade*", "Node", true, false) as Array).is_empty()
	if not ok:
		return {"ok": false, "message": "Fire Station still exposes the rejected live material or its placeholder/physics contract drifted."}
	return {"ok": true, "surface_count": mesh.get_surface_count(), "surface_names": [mesh.surface_get_name(0)], "material_name": material.resource_name, "placeholder_runs": placeholder_runs, "render_triangles": render_signatures.size(), "collision_triangles": collision_signatures.size()}


func _runs_for_surface(mesh: ArrayMesh, surface_index: int) -> Array[int]:
	var indices := mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] as PackedInt32Array
	var counts := {}
	for vertex_index: int in indices:
		var run_index := vertex_index / 4
		counts[run_index] = int(counts.get(run_index, 0)) + 1
	var runs: Array[int] = []
	for run_value: Variant in counts.keys():
		var run_index := int(run_value)
		if int(counts[run_index]) != 6:
			return []
		runs.append(run_index)
	runs.sort()
	return runs


func _triangle_signatures_for_mesh(mesh: ArrayMesh) -> Dictionary:
	var signatures := {}
	for surface_index in mesh.get_surface_count():
		var arrays := mesh.surface_get_arrays(surface_index)
		var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
		var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
		for offset in range(0, indices.size(), 3):
			var signature := _triangle_signature(vertices[indices[offset]], vertices[indices[offset + 1]], vertices[indices[offset + 2]])
			if signatures.has(signature):
				return {}
			signatures[signature] = true
	return signatures


func _triangle_signatures_for_faces(faces: PackedVector3Array) -> Dictionary:
	var signatures := {}
	for offset in range(0, faces.size(), 3):
		var signature := _triangle_signature(faces[offset], faces[offset + 1], faces[offset + 2])
		if signatures.has(signature):
			return {}
		signatures[signature] = true
	return signatures


func _triangle_signature(a: Vector3, b: Vector3, c: Vector3) -> String:
	var points := [_vector_signature(a), _vector_signature(b), _vector_signature(c)]
	points.sort()
	return "|".join(points)


func _vector_signature(value: Vector3) -> String:
	return "%.6f,%.6f,%.6f" % [value.x, value.y, value.z]


func _sorted_keys(values: Dictionary) -> Array:
	var keys := values.keys()
	keys.sort()
	return keys


func _poses(record: Dictionary) -> Array[Dictionary]:
	var representative_run := 2
	var values := record.vertices as Array
	var normal_values := record.normals as Array
	var offset := representative_run * 12
	var v0 := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
	var v1 := Vector3(float(values[offset + 3]), float(values[offset + 4]), float(values[offset + 5]))
	var v2 := Vector3(float(values[offset + 6]), float(values[offset + 7]), float(values[offset + 8]))
	var v3 := Vector3(float(values[offset + 9]), float(values[offset + 10]), float(values[offset + 11]))
	var center := (v0 + v1 + v2 + v3) * 0.25
	var normal := Vector3(float(normal_values[offset]), 0.0, float(normal_values[offset + 2])).normalized()
	var tangent := Vector3(v1.x - v0.x, 0.0, v1.z - v0.z).normalized()
	var base_y := minf(v0.y, v1.y)
	var close_camera := center + normal * 7.0
	close_camera.y = base_y + 2.1
	var ordinary_camera := center + normal * 24.0
	ordinary_camera.y = base_y + 2.1
	return [
		{"id": "01-close-placeholder", "view_kind": "close_generated_placeholder_exclusion", "camera": close_camera, "target": center, "sun": Vector3(-52.0, -28.0, 0.0), "representative_run": representative_run},
		{"id": "02-ordinary-placeholder", "view_kind": "ordinary_gameplay_distance_generated_placeholder_exclusion", "camera": ordinary_camera, "target": center, "sun": Vector3(-52.0, -28.0, 0.0), "representative_run": representative_run},
		{"id": "03-changed-light-oblique-placeholder", "view_kind": "changed_light_oblique_generated_placeholder_exclusion", "camera": center + normal * 15.0 + tangent * 9.0 + Vector3.UP * 3.0, "target": center, "sun": Vector3(-24.0, 118.0, 0.0), "representative_run": representative_run},
	]


func _make_overlay() -> CanvasLayer:
	var overlay := CanvasLayer.new()
	overlay.name = "RemovalEvidenceOverlay"
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.015, 0.02, 0.025, 0.86)
	backdrop.position = Vector2(24, 22)
	backdrop.size = Vector2(1392, 126)
	overlay.add_child(backdrop)
	var detail := Label.new()
	detail.name = "Detail"
	detail.position = Vector2(44, 38)
	detail.add_theme_font_size_override("font_size", 17)
	detail.add_theme_color_override("font_color", Color("f4f0e8"))
	overlay.add_child(detail)
	return overlay


func _save_view(camera: Camera3D, sun: DirectionalLight3D, pose: Dictionary) -> Dictionary:
	paused = false
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != CAPTURE_SIZE:
		return {"ok": false, "message": "%s produced an empty or wrong-sized image." % str(pose.id)}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.08:
		return {"ok": false, "message": "%s appears blank." % str(pose.id)}
	var filename := "%s.png" % str(pose.id)
	var path := OUTPUT.path_join("images").path_join(filename)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save PNG." % str(pose.id)}
	var metadata := {"id": str(pose.id), "view_kind": str(pose.view_kind), "receiver_key": RECEIVER_KEY if int(pose.representative_run) >= 0 else "whole-island", "file": "images/%s" % filename, "sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y], "camera_position_m": [camera.position.x, camera.position.y, camera.position.z], "aim_target_m": [(pose.target as Vector3).x, (pose.target as Vector3).y, (pose.target as Vector3).z], "camera_fov_degrees": camera.fov, "sun_rotation_degrees": [sun.rotation_degrees.x, sun.rotation_degrees.y, sun.rotation_degrees.z], "representative_run": int(pose.representative_run), "sample_unique_colors": int(sample.unique_colors), "sample_luminance_range": float(sample.luminance_range)}
	print("FIRE_STATION_REMOVAL_CAPTURE: image=%s sha256=%s" % [ProjectSettings.globalize_path(path), str(metadata.sha256)])
	return {"ok": true, "metadata": metadata}


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


func _write_json(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value, "  ", false) + "\n")
	file.close()
	return true


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_fail(message)
	return false


func _fail(message: String) -> void:
	if _failure.is_empty():
		_failure = message
	push_error("FIRE_STATION_REMOVAL_CAPTURE_FAIL: %s" % message)


func _on_timeout() -> void:
	if not _finished:
		_fail("Capture timed out after %.0f seconds." % TIMEOUT_SECONDS)
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
		await process_frame
	quit(0 if _failure.is_empty() else 1)
