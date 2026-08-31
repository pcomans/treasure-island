extends SceneTree

const ACCEPTED_MATERIAL_RUN_TRIALS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const OUTPUT := "res://evidence/first-playable/accepted-material-run-trials-2026-08-29"
const CAPTURE_SIZE := Vector2i(1440, 900)
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_BUILDER_SHA256 := "c770a977e879c0d077acb8fb4d33b52d1bd6aa3b454a50ba8e2125cb71e8ba8d"
const EXPECTED_HELPER_SHA256 := "9c86fcbccf878a0786cb3d6bed12192c1e131759ab2d0f5ee002ce0e4685309f"
const TIMEOUT_SECONDS := 240.0
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/accepted_material_run_trials_capture.gd"

const TARGETS := [
	{
		"slug": "navy-chapel-187", "canonical_name": "Navy Chapel", "source_key": "w291189336",
		"receiver_key": "building:w291189336:wall", "chunk": "res://generated/world/chunks/x_-1__z_2.json",
		"accepted_runs": [9, 10], "accepted_length_m": 16.362, "representative_run": 9,
		"material_path": "res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres",
		"material_sha256": "4020e4c75350929359be9c16686ad80a2a0eac46918cc32746089694017a61a5",
	},
	{
		"slug": "fire-station-48", "canonical_name": "Fire Station 48", "source_key": "w764313741",
		"receiver_key": "building:w764313741:wall", "chunk": "res://generated/world/chunks/x_0__z_-2.json",
		"accepted_runs": [0, 1, 2, 3, 5, 6, 8, 9, 24, 25], "accepted_length_m": 76.157, "representative_run": 2,
		"material_path": "res://game/resources/materials/world/fire_station_48/fire_station_48_primary.tres",
		"material_sha256": "515135c3d0da6bb8eb8681e69d7e3f7818d896d948fe5dcc7c2bd8c6d076b188",
	},
	{
		"slug": "dormitory-369", "canonical_name": "Dormitory 369", "source_key": "w291189926",
		"receiver_key": "building:w291189926:wall", "chunk": "res://generated/world/chunks/x_0__z_1.json",
		"accepted_runs": [0, 1, 2, 3, 4, 5], "accepted_length_m": 49.124, "representative_run": 2,
		"material_path": "res://game/resources/materials/world/job_corps_dormitory_b369/dormitory_b369_warm_field.tres",
		"material_sha256": "fb50d3989b7aa41421753ad4db5d195366d9a2c25c15087e5e3a2b7863c69602",
	},
]

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Accepted-material evidence requires the real macOS rendering display.")
		_finish(null)
		return
	if not _require(FileAccess.get_sha256("res://generated/world/manifest.json") == EXPECTED_MANIFEST_SHA256, "Generated manifest bytes drifted before capture.") \
	or not _require(FileAccess.get_sha256("res://game/scripts/world/world_chunk_builder.gd") == EXPECTED_BUILDER_SHA256, "Runtime builder bytes drifted before capture.") \
	or not _require(FileAccess.get_sha256("res://game/scripts/world/facades/accepted_material_run_trials.gd") == EXPECTED_HELPER_SHA256, "Exact-run helper bytes drifted before capture."):
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for accepted-material capture."):
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
	var wait_started := Time.get_ticks_msec()
	while ready_reports.is_empty() and load_failures.is_empty() and Time.get_ticks_msec() - wait_started < 40000:
		await process_frame
	if not _require(load_failures.is_empty() and ready_reports.size() == 1, "Full world did not reach one clean world_ready for accepted-material capture.") \
	or not _require(str(ready_reports[0].get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content hash drifted before capture."):
		_finish(main)
		return
	var evidence := world.get_runtime_evidence()
	if not _require(evidence.chunks_loaded == 38 and evidence.mesh_instances == 729 and evidence.surfaces == 732 and evidence.triangles == 48389, "Whole-island runtime totals drifted before capture.") \
	or not _require(evidence.static_bodies == 466 and evidence.shapes == 466, "Whole-island collision totals drifted before capture."):
		_finish(main)
		return
	var output_absolute := ProjectSettings.globalize_path(OUTPUT)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images")) == OK, "Could not create accepted-material evidence directory."):
		_finish(main)
		return
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images/whole-island")) == OK, "Could not create whole-island evidence directory."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.hide()
	player.set_gameplay_enabled(false)
	(main.get_node("Interface/HUD") as GameHUD).hide()
	var camera := Camera3D.new()
	camera.name = "AcceptedMaterialEvidenceCamera"
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
	var target_manifests: Array[Dictionary] = []
	for target_value: Variant in TARGETS:
		var target := target_value as Dictionary
		var record_data := _record_data(target)
		var receiver := _record_node_for_key(world, str(target.receiver_key))
		var live_contract := _live_receiver_contract(receiver, target, record_data)
		if not _require(bool(live_contract.get("ok", false)), str(live_contract.get("message", "Live receiver contract failed."))):
			_finish(main)
			return
		if DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images").path_join(str(target.slug))) != OK:
			_fail("Could not create image directory for %s." % str(target.canonical_name))
			_finish(main)
			return
		var target_captures: Array[Dictionary] = []
		for pose: Dictionary in _poses(record_data, int(target.representative_run)):
			detail.text = "%s · accepted homogeneous material trial\nreceiver %s · exact runs %s · %.3f m\n%s · INDEPENDENT GAMEPLAY ART REVIEW PENDING" % [str(target.canonical_name), str(target.receiver_key), str(target.accepted_runs), float(target.accepted_length_m), str(pose.view_kind).replace("_", " ").to_upper()]
			camera.position = pose.camera as Vector3
			camera.look_at(pose.target as Vector3, Vector3.UP)
			sun.rotation_degrees = pose.sun as Vector3
			var capture := await _save_view(camera, sun, target, pose)
			if not _require(bool(capture.get("ok", false)), str(capture.get("message", "Target capture failed."))):
				_finish(main)
				return
			target_captures.append(capture.metadata as Dictionary)
			captures.append(capture.metadata as Dictionary)
		var target_manifest := {
			"canonical_name": str(target.canonical_name), "source_key": str(target.source_key), "receiver_key": str(target.receiver_key),
			"accepted_runs": target.accepted_runs, "accepted_length_m": float(target.accepted_length_m),
			"material_path": str(target.material_path), "material_sha256": str(target.material_sha256),
			"surface_names": [ACCEPTED_MATERIAL_RUN_TRIALS.PLACEHOLDER_SURFACE_NAME, ACCEPTED_MATERIAL_RUN_TRIALS.ACCEPTED_SURFACE_NAME],
			"modules": 0, "render_triangles": int(live_contract.render_triangles), "collision_triangles": int(live_contract.collision_triangles),
			"captures": target_captures, "limitation": str((receiver.get_meta("accepted_material_run_trial") as Dictionary).limitation),
		}
		target_manifests.append(target_manifest)

	sun.rotation_degrees = original_sun_rotation
	detail.text = "WHOLE-ISLAND LOAD PROOF · 38/38 chunks · 729 meshes · 732 surfaces\n48,389 render triangles · 466 collision bodies/shapes\nthree exact-run homogeneous material trials · INDEPENDENT GAMEPLAY ART REVIEW PENDING"
	var whole_pose := {"id": "whole-island-load", "view_kind": "whole_island_load_proof", "camera": Vector3(180.0, 1550.0, 300.0), "target": Vector3(-20.0, 0.0, 30.0), "sun": original_sun_rotation}
	camera.position = whole_pose.camera
	camera.look_at(whole_pose.target, Vector3.UP)
	var whole_capture := await _save_view(camera, sun, {"slug": "whole-island", "receiver_key": "whole-island"}, whole_pose)
	if not _require(bool(whole_capture.get("ok", false)), str(whole_capture.get("message", "Whole-island capture failed."))):
		_finish(main)
		return
	captures.append(whole_capture.metadata as Dictionary)

	var manifest := {
		"schema_version": "ti.accepted-material-run-trials-evidence/1",
		"review_status": "ready_for_independent_gameplay_art_review_not_self_accepted",
		"evidence_role": "live_receiver_runtime_and_render_proof_with_preserved_review_limitations",
		"generator": "game/tests/accepted_material_run_trials_capture.gd", "capture_command": COMMAND,
		"godot_version": Engine.get_version_info().get("string", "unknown"), "display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(), "rendering_method": "Forward+", "rendering_driver": "Metal", "viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"content_sha256": EXPECTED_CONTENT_SHA256, "generated_manifest_sha256": EXPECTED_MANIFEST_SHA256,
		"world_chunk_builder_sha256": EXPECTED_BUILDER_SHA256, "accepted_run_helper_sha256": EXPECTED_HELPER_SHA256,
		"shared_shader_sha256": "1918177080126199ddbfc0715a77b85a9355800479a098ec9b81c9726b7cc4d5",
		"generated_world_counts": {"chunks": evidence.chunks_loaded, "records": 729, "meshes": evidence.mesh_instances, "surfaces": evidence.surfaces, "triangles": evidence.triangles, "static_bodies": evidence.static_bodies, "shapes": evidence.shapes},
		"surface_delta": {"baseline_one_surface_per_mesh": 729, "actual": 732, "delta": 3, "cause": "one disjoint accepted-run surface on each of exactly three target receivers"},
		"targets": target_manifests, "capture_count": captures.size(), "captures": captures,
		"protected_scope": {"generated_files_modified": false, "geometry_modified": false, "massing_modified": false, "terrain_or_foundations_modified": false, "collision_modified": false, "spray_or_gameplay_modified": false, "modules_added": 0},
		"limitations": ["Navy Chapel is accepted only as a warm-cream homogeneous albedo/roughness background on runs 9..10; substrate and relief remain blocked.", "Fire Station 48 is accepted only as a flat pale sage-gray/warm-gray albedo/roughness field on runs 0,1,2,3,5,6,8,9,24,25; substrate, scale, normals, and relief remain blocked.", "Dormitory 369 is accepted only as a smooth warm-wall albedo/roughness field on runs 0..5; the five-visible-tier versus fallback-6-m discrepancy remains unresolved.", "No image in this set is an independent gameplay art acceptance."],
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write accepted-material capture manifest.")
		_finish(main)
		return
	print("PASS: captured nine target views plus one whole-island Forward+/Metal load proof for exactly three accepted-with-limitation homogeneous material trials to %s" % output_absolute)
	_finish(main)


func _record_data(target: Dictionary) -> Dictionary:
	var parsed := JSON.parse_string(FileAccess.get_file_as_string(str(target.chunk))) as Dictionary
	for record_value: Variant in parsed.get("records", []):
		var record := record_value as Dictionary
		if str(record.get("object_key", "")) == str(target.receiver_key):
			return record
	return {}


func _record_node_for_key(world: WorldLoader, key: String) -> Node3D:
	for value: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if str(value.get_meta("derived_object_key", "")) == key:
			return value as Node3D
	return null


func _live_receiver_contract(receiver: Node3D, target: Dictionary, record_data: Dictionary) -> Dictionary:
	if receiver == null or record_data.is_empty() or receiver.get_meta("source_keys", []) != [str(target.source_key)]:
		return {"ok": false, "message": "Exact live receiver/source did not resolve for %s." % str(target.canonical_name)}
	var metadata := receiver.get_meta("accepted_material_run_trial", {}) as Dictionary
	var mesh_instance := receiver.get_node_or_null("Mesh") as MeshInstance3D
	var collision := receiver.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := collision.shape as ConcavePolygonShape3D if collision != null else null
	if metadata != ACCEPTED_MATERIAL_RUN_TRIALS.metadata_for(str(target.receiver_key)) \
	or mesh_instance == null or mesh_instance.mesh == null or mesh_instance.mesh.get_surface_count() != 2 \
	or mesh_instance.mesh.surface_get_name(0) != ACCEPTED_MATERIAL_RUN_TRIALS.PLACEHOLDER_SURFACE_NAME \
	or mesh_instance.mesh.surface_get_name(1) != ACCEPTED_MATERIAL_RUN_TRIALS.ACCEPTED_SURFACE_NAME \
	or mesh_instance.mesh.surface_get_material(1).resource_path != str(target.material_path) \
	or FileAccess.get_sha256(str(target.material_path)) != str(target.material_sha256) \
	or int(metadata.get("modules", -1)) != 0 or receiver.find_children("*", "MeshInstance3D", true, false).size() != 1 \
	or shape == null:
		return {"ok": false, "message": "Live exact-run material/collision contract drifted for %s." % str(target.canonical_name)}
	var render_triangles := 0
	var triangle_signatures := {}
	for surface_index in mesh_instance.mesh.get_surface_count():
		var arrays := mesh_instance.mesh.surface_get_arrays(surface_index)
		var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
		var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
		render_triangles += int(indices.size() / 3)
		for index_offset in range(0, indices.size(), 3):
			var signature := _triangle_signature(vertices[indices[index_offset]], vertices[indices[index_offset + 1]], vertices[indices[index_offset + 2]])
			if triangle_signatures.has(signature):
				return {"ok": false, "message": "Duplicate/coplanar render triangle found for %s." % str(target.canonical_name)}
			triangle_signatures[signature] = true
	var collision_triangles := int(shape.get_faces().size() / 3)
	if render_triangles != int((record_data.indices as Array).size() / 3) or collision_triangles != render_triangles:
		return {"ok": false, "message": "Render/collision triangle count drifted for %s." % str(target.canonical_name)}
	return {"ok": true, "render_triangles": render_triangles, "collision_triangles": collision_triangles}


func _triangle_signature(a: Vector3, b: Vector3, c: Vector3) -> String:
	var values := [_vector_signature(a), _vector_signature(b), _vector_signature(c)]
	values.sort()
	return "|".join(values)


func _vector_signature(value: Vector3) -> String:
	return "%.4f,%.4f,%.4f" % [value.x, value.y, value.z]


func _poses(record: Dictionary, representative_run: int) -> Array[Dictionary]:
	var values := record.vertices as Array
	var normal_values := record.normals as Array
	var vertex_offset := representative_run * 12
	var v0 := Vector3(float(values[vertex_offset]), float(values[vertex_offset + 1]), float(values[vertex_offset + 2]))
	var v1 := Vector3(float(values[vertex_offset + 3]), float(values[vertex_offset + 4]), float(values[vertex_offset + 5]))
	var v2 := Vector3(float(values[vertex_offset + 6]), float(values[vertex_offset + 7]), float(values[vertex_offset + 8]))
	var v3 := Vector3(float(values[vertex_offset + 9]), float(values[vertex_offset + 10]), float(values[vertex_offset + 11]))
	var center := (v0 + v1 + v2 + v3) * 0.25
	var normal := Vector3(float(normal_values[vertex_offset]), 0.0, float(normal_values[vertex_offset + 2])).normalized()
	var tangent := Vector3(v1.x - v0.x, 0.0, v1.z - v0.z).normalized()
	var base_y := minf(v0.y, v1.y)
	var close_camera := center + normal * 7.0
	close_camera.y = base_y + 2.1
	var ordinary_camera := center + normal * 24.0
	ordinary_camera.y = base_y + 2.1
	var oblique_camera := center + normal * 15.0 + tangent * 9.0 + Vector3.UP * 3.0
	return [
		{"id": "01-close", "view_kind": "close_live_receiver", "camera": close_camera, "target": center, "sun": Vector3(-52.0, -28.0, 0.0), "representative_run": representative_run},
		{"id": "02-ordinary-gameplay-distance", "view_kind": "ordinary_gameplay_distance_live_receiver", "camera": ordinary_camera, "target": center, "sun": Vector3(-52.0, -28.0, 0.0), "representative_run": representative_run},
		{"id": "03-changed-light-oblique", "view_kind": "changed_light_oblique_live_receiver", "camera": oblique_camera, "target": center, "sun": Vector3(-24.0, 118.0, 0.0), "representative_run": representative_run},
	]


func _make_overlay() -> CanvasLayer:
	var overlay := CanvasLayer.new()
	overlay.name = "EvidenceOverlay"
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.015, 0.02, 0.025, 0.84)
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


func _save_view(camera: Camera3D, sun: DirectionalLight3D, target: Dictionary, pose: Dictionary) -> Dictionary:
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
	var relative := "images/%s/%s.png" % [str(target.slug), str(pose.id)]
	var path := OUTPUT.path_join(relative)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save PNG." % str(pose.id)}
	var metadata := {
		"id": str(pose.id), "view_kind": str(pose.view_kind), "receiver_key": str(target.receiver_key), "file": relative,
		"sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"camera_position_m": [camera.position.x, camera.position.y, camera.position.z], "aim_target_m": [(pose.target as Vector3).x, (pose.target as Vector3).y, (pose.target as Vector3).z],
		"camera_fov_degrees": camera.fov, "sun_rotation_degrees": [sun.rotation_degrees.x, sun.rotation_degrees.y, sun.rotation_degrees.z],
		"representative_run": int(pose.get("representative_run", -1)), "sample_unique_colors": int(sample.unique_colors), "sample_luminance_range": float(sample.luminance_range),
	}
	print("ACCEPTED_MATERIAL_CAPTURE: image=%s sha256=%s" % [ProjectSettings.globalize_path(path), str(metadata.sha256)])
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
	push_error("ACCEPTED_MATERIAL_CAPTURE_FAIL: %s" % message)


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
