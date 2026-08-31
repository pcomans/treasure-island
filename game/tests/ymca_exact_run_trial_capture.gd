extends SceneTree

const ACCEPTED_MATERIAL_RUN_TRIALS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const OUTPUT := "res://evidence/first-playable/ymca-exact-run-correction-2026-08-29"
const CAPTURE_SIZE := Vector2i(1440, 900)
const TIMEOUT_SECONDS := 240.0
const SOURCE_KEY := "w34313547"
const RECEIVER_KEY := "building:w34313547:wall"
const CHUNK_PATH := "res://generated/world/chunks/x_0__z_-2.json"
const MATERIAL_PATH := "res://game/resources/materials/world/ti_ymca/ti_ymca_primary.tres"
const SHADER_PATH := "res://game/resources/materials/world/ti_ymca/ti_ymca_wall_tangent_aperiodic_field.gdshader"
const REGISTRY_PATH := "res://game/resources/facades/batch_02_material_registry.json"
const STANDALONE_REVIEW_PATH := "res://discovery/facades/BATCH_02_04_MATERIAL_CORRECTION_REVIEW.md"
const EXACT_RUN_REVIEW_PATH := "res://discovery/facades/TREASURE_ISLAND_COMMUNITY_YMCA_EXACT_RUN_ART_REVIEW.md"
const MAPPING_PATH := "res://discovery/facades/BATCH_02_RUN_MAPPING.json"
const INVENTORY_PATH := "res://discovery/FACADE_RECEIVER_INVENTORY.json"
const CORRECTION_MANIFEST_PATH := "res://evidence/first-playable/batch-02-04-material-corrections-2026-08-29/treasure-island-community-ymca/capture-manifest.json"
const PREDECESSOR_MANIFEST_PATH := "res://evidence/first-playable/ymca-exact-run-trial-2026-08-29/capture-manifest.json"
const ACCEPTED_RUNS := [3, 4, 5, 6, 7, 8, 9, 10, 11]
const PLACEHOLDER_RUNS := [0, 1, 2, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]
const ACCEPTED_LENGTH_M := 101.046
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_CHUNK_SHA256 := "c0e1f86787410d975ad90272482e5f4971c4aedc7eb83132cd28b22acf1a3456"
const EXPECTED_MATERIAL_SHA256 := "b5e44afcf4feb6df6ffba46f4e3b60a25fa6043c07c12c33e31c483cb2bf2399"
const EXPECTED_SHADER_SHA256 := "8943853363f5a2571ebf15a6e9711c6310b706d2e4415f3e1f314d8643d55f6c"
const EXPECTED_REGISTRY_SHA256 := "e7d1167869640867e2857de1f08df81e878e68230b59feff3fb947b16ff56cb7"
const EXPECTED_STANDALONE_REVIEW_SHA256 := "50f5863a1320a7b5d74e56ffa0612930657fa7060d83ba7f1f455c334bd03e99"
const EXPECTED_EXACT_RUN_REVIEW_SHA256 := "f72125d06ea3b4cf13308651da5505c2a6d05e42e65c1c378db924ad74f75a42"
const EXPECTED_MAPPING_SHA256 := "d076ee125168cd3dfe499bc56e94c324019d7ba70bb731b9c23c045ca6759b5f"
const EXPECTED_INVENTORY_SHA256 := "41fd4b1cdc98b31b33801decb02a1303e9d1b6ee48e86214a90e52656f9a8542"
const EXPECTED_CORRECTION_MANIFEST_SHA256 := "d02fcbe38c56eea263900f89bda13eba044a4ae0af9621f5f1b8da76a465808b"
const EXPECTED_PREDECESSOR_MANIFEST_SHA256 := "73c45af4ea93a7def7d3744ced62f5917231947c14ba2c03bc3835831f1651d5"
const EXPECTED_BUILDER_SHA256 := "c770a977e879c0d077acb8fb4d33b52d1bd6aa3b454a50ba8e2125cb71e8ba8d"
# Historical Y-EXACT-01 capture-time helper identity. Current-state contracts
# intentionally pin the promoted helper separately and no recapture is allowed.
const EXPECTED_CAPTURE_TIME_HELPER_SHA256 := "fcf128208ad1dcf9eaa4a809e4b3a4fc09f5df8e8450f4ade30d68ace85c4efe"
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/ymca_exact_run_trial_capture.gd"

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("YMCA exact-run evidence requires the real macOS rendering display.")
		_finish(null)
		return
	if not _input_hashes_match():
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for YMCA exact-run proof."):
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
	if not _require(load_failures.is_empty() and ready_reports.size() == 1, "Full world did not reach one clean world_ready for YMCA proof.") \
	or not _require(str(ready_reports[0].get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content hash drifted before YMCA proof."):
		_finish(main)
		return
	var evidence := world.get_runtime_evidence()
	if not _require(evidence.chunks_loaded == 38 and evidence.mesh_instances == 729 and evidence.surfaces == 732 and evidence.triangles == 48389, "YMCA trial whole-island topology drifted.") \
	or not _require(evidence.static_bodies == 466 and evidence.shapes == 466, "YMCA trial collision totals drifted."):
		_finish(main)
		return
	var record := _record_data(RECEIVER_KEY)
	var receiver := _record_node_for_key(world, RECEIVER_KEY)
	var receiver_proof := _ymca_receiver_proof(receiver, record)
	if not _require(bool(receiver_proof.get("ok", false)), str(receiver_proof.get("message", "YMCA exact receiver proof failed."))) \
	or not _require(_wall_tangent_projection_matches(record), "YMCA wall-tangent/vertical metre projection proof failed.") \
	or not _require(_preserved_live_trials_match(world), "Chapel or Dormitory exact live scope drifted.") \
	or not _require(_fire_station_remains_placeholder(world), "Rejected Fire Station regained a live accepted-material surface."):
		_finish(main)
		return
	var output_absolute := ProjectSettings.globalize_path(OUTPUT)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images")) == OK, "Could not create YMCA evidence directory."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.hide()
	player.set_gameplay_enabled(false)
	(main.get_node("Interface/HUD") as GameHUD).hide()
	var camera := Camera3D.new()
	camera.name = "YMCAExactRunEvidenceCamera"
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
		detail.text = "TREASURE ISLAND COMMUNITY YMCA · Y-EXACT-01 CORRECTION PROOF\nreceiver %s · runs 3..11 · wall-tangent/vertical metres · aggregate only\n%s · INDEPENDENT GAMEPLAY ART RE-REVIEW PENDING" % [RECEIVER_KEY, str(pose.view_kind).replace("_", " ").to_upper()]
		camera.position = pose.camera as Vector3
		camera.look_at(pose.target as Vector3, Vector3.UP)
		sun.rotation_degrees = pose.sun as Vector3
		var capture := await _save_view(camera, sun, pose)
		if not _require(bool(capture.get("ok", false)), str(capture.get("message", "YMCA capture failed."))):
			_finish(main)
			return
		captures.append(capture.metadata as Dictionary)
	sun.rotation_degrees = original_sun_rotation
	var manifest := {
		"schema_version": "ti.ymca-exact-run-correction-evidence/1",
		"review_status": "ready_for_independent_y_exact_01_gameplay_art_re_review_not_self_accepted",
		"evidence_role": "bounded_y_exact_01_rotation_invariant_projection_proof_not_art_acceptance",
		"correction_id": "Y-EXACT-01",
		"generator": "game/tests/ymca_exact_run_trial_capture.gd", "capture_command": COMMAND,
		"godot_version": Engine.get_version_info().get("string", "unknown"), "display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(), "rendering_method": "Forward+", "rendering_driver": "Metal", "viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"independent_standalone_review": {"path": STANDALONE_REVIEW_PATH, "sha256": EXPECTED_STANDALONE_REVIEW_SHA256, "verdict": "ACCEPT_WITH_LIMITATION"},
		"independent_exact_run_review": {"path": EXACT_RUN_REVIEW_PATH, "sha256": EXPECTED_EXACT_RUN_REVIEW_SHA256, "verdict_before_correction": "REJECT_CORRECTABLE", "correction_brief": "Y-EXACT-01", "verdict_after_correction": "pending_independent_re_review"},
		"predecessor_evidence": {"manifest_path": PREDECESSOR_MANIFEST_PATH, "manifest_sha256": EXPECTED_PREDECESSOR_MANIFEST_SHA256, "retained_unchanged": true, "capture_sha256": ["fa55a506dc9088323cd4b6d668c903c5468e187748ff68acdf687fb39fecf66e", "223be03b7383fb38d957f497b0998c0971775b6641de5e35112a4887952807b7", "19409f1b500cab30d715a8add2a93f3d0a888ce49221e0a70fdb7265731f8f67", "ad9c6fed7ed7bd9865a0ade3139d3c42aa994cc4574043ba8f9c1abc00f5b1e7"]},
		"before": {"receiver_key": RECEIVER_KEY, "source_key": SOURCE_KEY, "material_path": MATERIAL_PATH, "accepted_runs": ACCEPTED_RUNS, "horizontal_projection": "VERTEX.xy world-X/vertical-Y", "sse_status": "locally_passing", "ene_status": "orientation_dependent_and_unproved"},
		"after": {"receiver_key": RECEIVER_KEY, "source_key": SOURCE_KEY, "material_path": MATERIAL_PATH, "accepted_runs": ACCEPTED_RUNS, "accepted_length_m": ACCEPTED_LENGTH_M, "placeholder_runs": PLACEHOLDER_RUNS, "surface_names": [ACCEPTED_MATERIAL_RUN_TRIALS.PLACEHOLDER_SURFACE_NAME, ACCEPTED_MATERIAL_RUN_TRIALS.ACCEPTED_SURFACE_NAME], "receiver_surfaces": 2, "world_surfaces": evidence.surfaces, "modules": 0, "horizontal_projection": "dot(VERTEX.xz, vec2(normalized(NORMAL.xz).y, -normalized(NORMAL.xz).x))", "vertical_projection": "VERTEX.y", "physical_units": "one shader coordinate unit per generated wall-local metre"},
		"runtime_inputs": {"content_sha256": EXPECTED_CONTENT_SHA256, "generated_manifest_sha256": EXPECTED_MANIFEST_SHA256, "generated_chunk_sha256": EXPECTED_CHUNK_SHA256, "world_chunk_builder_sha256": EXPECTED_BUILDER_SHA256, "accepted_run_helper_sha256": EXPECTED_CAPTURE_TIME_HELPER_SHA256, "material_sha256": EXPECTED_MATERIAL_SHA256, "shader_sha256": EXPECTED_SHADER_SHA256, "shared_aperiodic_shader_sha256": "324ba33a7c78f4b05038168a479ebb8e875c56704236492a050cee8da8e5f798", "registry_sha256": EXPECTED_REGISTRY_SHA256, "mapping_sha256": EXPECTED_MAPPING_SHA256, "inventory_sha256": EXPECTED_INVENTORY_SHA256, "standalone_correction_manifest_sha256": EXPECTED_CORRECTION_MANIFEST_SHA256},
		"world_counts": {"chunks": evidence.chunks_loaded, "records": 729, "meshes": evidence.mesh_instances, "surfaces": evidence.surfaces, "triangles": evidence.triangles, "static_bodies": evidence.static_bodies, "shapes": evidence.shapes},
		"receiver_invariants": {"render_triangles": int(receiver_proof.render_triangles), "collision_triangles": int(receiver_proof.collision_triangles), "duplicate_or_coplanar_render_triangles": false, "collision_unchanged": true, "spray_identity_unchanged": true, "generated_geometry_unchanged": true, "run_scope_unchanged": true, "sse_chain_phase_continuous": true, "ene_chain_phase_continuous": true, "sse_to_ene_corner_exact": true, "accepted_run_11_to_placeholder_run_12_boundary_exact": true},
		"preserved_live_trials": [{"receiver_key": "building:w291189336:wall", "runs": [9, 10], "length_m": 16.362}, {"receiver_key": "building:w291189926:wall", "runs": [0, 1, 2, 3, 4, 5], "length_m": 49.124}],
		"rejected_fire_station": {"receiver_key": "building:w764313741:wall", "accepted_runs": [], "current_surface_contract": "one generated placeholder surface across all 26 runs"},
		"captures": captures, "capture_count": captures.size(),
		"limitations": ["YMCA remains a homogeneous aggregate/background field only on runs 3..11; granular scale and substrate remain receiver-calibration assumptions.", "No opening, panel joint, entry, louver, door, mural, low wing, module, WSW/NNW coverage, geometry, massing, collision, or spray claim is added.", "These captures are a handoff for independent Y-EXACT-01 exact-receiver and whole-object re-review, not executor art acceptance."],
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write YMCA exact-run manifest.")
		_finish(main)
		return
	print("PASS: captured six-view YMCA Y-EXACT-01 SSE/ENE/corner/boundary Metal evidence set to %s" % output_absolute)
	_finish(main)


func _input_hashes_match() -> bool:
	var checks := {
		"res://generated/world/manifest.json": EXPECTED_MANIFEST_SHA256,
		CHUNK_PATH: EXPECTED_CHUNK_SHA256,
		MATERIAL_PATH: EXPECTED_MATERIAL_SHA256,
		SHADER_PATH: EXPECTED_SHADER_SHA256,
		REGISTRY_PATH: EXPECTED_REGISTRY_SHA256,
		STANDALONE_REVIEW_PATH: EXPECTED_STANDALONE_REVIEW_SHA256,
		EXACT_RUN_REVIEW_PATH: EXPECTED_EXACT_RUN_REVIEW_SHA256,
		MAPPING_PATH: EXPECTED_MAPPING_SHA256,
		INVENTORY_PATH: EXPECTED_INVENTORY_SHA256,
		CORRECTION_MANIFEST_PATH: EXPECTED_CORRECTION_MANIFEST_SHA256,
		PREDECESSOR_MANIFEST_PATH: EXPECTED_PREDECESSOR_MANIFEST_SHA256,
		"res://game/scripts/world/world_chunk_builder.gd": EXPECTED_BUILDER_SHA256,
		"res://game/scripts/world/facades/accepted_material_run_trials.gd": EXPECTED_CAPTURE_TIME_HELPER_SHA256,
	}
	for path: String in checks:
		if not _require(FileAccess.get_sha256(path) == str(checks[path]), "YMCA proof input hash drifted: %s" % path):
			return false
	return true


func _ymca_receiver_proof(receiver: Node3D, record: Dictionary) -> Dictionary:
	if receiver == null or record.is_empty() or receiver.get_meta("source_keys", []) != [SOURCE_KEY]:
		return {"ok": false, "message": "Exact YMCA receiver/source did not resolve."}
	var metadata := receiver.get_meta("accepted_material_run_trial", {}) as Dictionary
	var mesh_instance := receiver.get_node_or_null("Mesh") as MeshInstance3D
	var body := receiver.get_node_or_null("Collision") as StaticBody3D
	var shape_node := receiver.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	if metadata != ACCEPTED_MATERIAL_RUN_TRIALS.metadata_for(RECEIVER_KEY) \
	or mesh_instance == null or not (mesh_instance.mesh is ArrayMesh) or body == null or shape == null:
		return {"ok": false, "message": "YMCA metadata, mesh, or collision receiver is incomplete."}
	var mesh := mesh_instance.mesh as ArrayMesh
	var material := mesh.surface_get_material(1) as ShaderMaterial if mesh.get_surface_count() == 2 else null
	var render_signatures := _triangle_signatures_for_mesh(mesh)
	var collision_signatures := _triangle_signatures_for_faces(shape.get_faces())
	var ok := receiver.get_child_count() == 2 \
		and mesh.get_surface_count() == 2 \
		and mesh.surface_get_name(0) == ACCEPTED_MATERIAL_RUN_TRIALS.PLACEHOLDER_SURFACE_NAME \
		and mesh.surface_get_name(1) == ACCEPTED_MATERIAL_RUN_TRIALS.ACCEPTED_SURFACE_NAME \
		and _runs_for_surface(mesh, 0) == PLACEHOLDER_RUNS \
		and _runs_for_surface(mesh, 1) == ACCEPTED_RUNS \
		and material != null and material.resource_path == MATERIAL_PATH \
		and material.shader != null and material.shader.resource_path == SHADER_PATH \
		and int(material.get_shader_parameter("field_kind")) == 5 \
		and is_equal_approx(float(material.get_shader_parameter("relief_strength")), 0.08) \
		and int(metadata.get("modules", -1)) == 0 \
		and render_signatures.size() == (record.indices as Array).size() / 3 \
		and _sorted_keys(render_signatures) == _sorted_keys(collision_signatures) \
		and mesh.get_faces().size() == (record.indices as Array).size() \
		and shape.get_faces().size() == (record.indices as Array).size() \
		and mesh_instance.layers == 2 \
		and body.collision_layer == 5 and body.collision_mask == 0 \
		and body.is_in_group("spray_receiver_wall") \
		and (receiver.find_children("*", "MeshInstance3D", true, false) as Array).size() == 1 \
		and (receiver.find_children("*", "CollisionObject3D", true, false) as Array).size() == 1 \
		and (receiver.find_children("*", "NavigationRegion3D", true, false) as Array).is_empty() \
		and (receiver.find_children("*Facade*", "Node", true, false) as Array).is_empty()
	if not ok:
		return {"ok": false, "message": "YMCA exact run/material/geometry/physics contract drifted."}
	return {"ok": true, "render_triangles": render_signatures.size(), "collision_triangles": collision_signatures.size()}


func _wall_tangent_projection_matches(record: Dictionary) -> bool:
	var shader_source := FileAccess.get_file_as_string(SHADER_PATH)
	if not "vec2 horizontal_normal = normalize(NORMAL.xz);" in shader_source \
	or not "vec2 wall_tangent = vec2(horizontal_normal.y, -horizontal_normal.x);" in shader_source \
	or not "field_position_m = vec2(dot(VERTEX.xz, wall_tangent), VERTEX.y);" in shader_source \
	or "field_position_m = VERTEX.xy;" in shader_source:
		return false
	var vertices := record.get("vertices", []) as Array
	var normals := record.get("normals", []) as Array
	if vertices.size() != 360 or normals.size() != 360:
		return false
	for run_index: int in ACCEPTED_RUNS:
		var offset := run_index * 12
		var start := Vector2(float(vertices[offset]), float(vertices[offset + 2]))
		var end := Vector2(float(vertices[offset + 3]), float(vertices[offset + 5]))
		var normal := Vector2(float(normals[offset]), float(normals[offset + 2])).normalized()
		var tangent := Vector2(normal.y, -normal.x)
		var delta := end - start
		if absf(delta.dot(tangent) - delta.length()) > 0.002:
			return false
	for chain: Array in [[3, 4, 5, 6, 7], [8, 9, 10, 11]]:
		for chain_index in chain.size() - 1:
			var run_index := int(chain[chain_index])
			var next_run := int(chain[chain_index + 1])
			if _run_end(record, run_index).distance_to(_run_start(record, next_run)) > 0.002 \
			or _run_tangent(record, run_index).distance_to(_run_tangent(record, next_run)) > 0.002:
				return false
	return _run_end(record, 7).distance_to(_run_start(record, 8)) <= 0.002 \
		and absf(_run_tangent(record, 7).dot(_run_tangent(record, 8))) <= 0.002 \
		and _run_end(record, 11).distance_to(_run_start(record, 12)) <= 0.002


func _preserved_live_trials_match(world: WorldLoader) -> bool:
	var expected := {
		"building:w291189336:wall": [9, 10],
		"building:w291189926:wall": [0, 1, 2, 3, 4, 5],
	}
	for receiver_key: String in expected:
		var receiver := _record_node_for_key(world, receiver_key)
		if receiver == null or receiver.get_meta("accepted_material_run_trial", {}) != ACCEPTED_MATERIAL_RUN_TRIALS.metadata_for(receiver_key):
			return false
		var mesh := (receiver.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh
		if mesh.get_surface_count() != 2 or _runs_for_surface(mesh, 1) != expected[receiver_key]:
			return false
	return true


func _fire_station_remains_placeholder(world: WorldLoader) -> bool:
	var receiver := _record_node_for_key(world, "building:w764313741:wall")
	if receiver == null or receiver.has_meta("accepted_material_run_trial"):
		return false
	var mesh_instance := receiver.get_node_or_null("Mesh") as MeshInstance3D
	if mesh_instance == null or not (mesh_instance.mesh is ArrayMesh):
		return false
	var mesh := mesh_instance.mesh as ArrayMesh
	return not ACCEPTED_MATERIAL_RUN_TRIALS.matches_record({"object_key": "building:w764313741:wall"}) \
		and mesh.get_surface_count() == 1 \
		and mesh.surface_get_name(0) == "generated_record" \
		and _runs_for_surface(mesh, 0) == range(26)


func _record_data(key: String) -> Dictionary:
	var parsed := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	for value: Variant in parsed.get("records", []):
		var record := value as Dictionary
		if str(record.get("object_key", "")) == key:
			return record
	return {}


func _record_node_for_key(world: WorldLoader, key: String) -> Node3D:
	for value: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if str(value.get_meta("derived_object_key", "")) == key:
			return value as Node3D
	return null


func _runs_for_surface(mesh: ArrayMesh, surface_index: int) -> Array[int]:
	var indices := mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] as PackedInt32Array
	var counts := {}
	for vertex_index: int in indices:
		var run_index := vertex_index / 4
		counts[run_index] = int(counts.get(run_index, 0)) + 1
	var runs: Array[int] = []
	for value: Variant in counts.keys():
		var run_index := int(value)
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
	return "%s|%s|%s" % points


func _vector_signature(value: Vector3) -> String:
	return "%.6f,%.6f,%.6f" % [value.x, value.y, value.z]


func _sorted_keys(values: Dictionary) -> Array:
	var keys := values.keys()
	keys.sort()
	return keys


func _run_start(record: Dictionary, run_index: int) -> Vector3:
	var values := record.get("vertices", []) as Array
	var offset := run_index * 12
	return Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))


func _run_end(record: Dictionary, run_index: int) -> Vector3:
	var values := record.get("vertices", []) as Array
	var offset := run_index * 12
	return Vector3(float(values[offset + 3]), float(values[offset + 4]), float(values[offset + 5]))


func _run_tangent(record: Dictionary, run_index: int) -> Vector2:
	var values := record.get("normals", []) as Array
	var offset := run_index * 12
	var normal := Vector2(float(values[offset]), float(values[offset + 2])).normalized()
	return Vector2(normal.y, -normal.x)


func _run_normal_3d(record: Dictionary, run_index: int) -> Vector3:
	var values := record.get("normals", []) as Array
	var offset := run_index * 12
	return Vector3(float(values[offset]), 0.0, float(values[offset + 2])).normalized()


func _chain_target(record: Dictionary, first_run: int, last_run: int) -> Vector3:
	var start := _run_start(record, first_run)
	var end := _run_end(record, last_run)
	var base_y := minf(start.y, end.y)
	return Vector3((start.x + end.x) * 0.5, base_y + 4.5, (start.z + end.z) * 0.5)


func _poses(record: Dictionary) -> Array[Dictionary]:
	var normal_sse := _run_normal_3d(record, 5)
	var tangent_sse_2d := _run_tangent(record, 5)
	var tangent_sse := Vector3(tangent_sse_2d.x, 0.0, tangent_sse_2d.y)
	var sse_target := _chain_target(record, 5, 5)
	var sse_camera := sse_target + normal_sse * 32.0 - tangent_sse * 4.0
	sse_camera.y = minf(_run_start(record, 5).y, _run_end(record, 5).y) + 2.2

	var normal_ene := _run_normal_3d(record, 9)
	var tangent_ene_2d := _run_tangent(record, 9)
	var tangent_ene := Vector3(tangent_ene_2d.x, 0.0, tangent_ene_2d.y)
	var ene_target := _chain_target(record, 9, 10)
	var ene_close_camera := ene_target + normal_ene * 8.0 - tangent_ene * 1.0
	ene_close_camera.y = minf(_run_start(record, 9).y, _run_end(record, 10).y) + 2.2
	var ene_ordinary_camera := ene_target + normal_ene * 33.0 - tangent_ene * 4.0
	ene_ordinary_camera.y = minf(_run_start(record, 9).y, _run_end(record, 10).y) + 2.2

	var corner := _run_end(record, 7)
	var corner_target := Vector3(corner.x, corner.y + 4.5, corner.z)
	var corner_bisector := (_run_normal_3d(record, 7) + _run_normal_3d(record, 8)).normalized()
	var corner_camera := corner_target + corner_bisector * 27.0
	corner_camera.y = corner.y + 6.2

	var boundary := _run_end(record, 11)
	var boundary_target := Vector3(boundary.x, boundary.y + 4.5, boundary.z)
	var boundary_bisector := (_run_normal_3d(record, 11) + _run_normal_3d(record, 12)).normalized()
	var boundary_close_camera := boundary_target + boundary_bisector * 10.0
	boundary_close_camera.y = boundary.y + 2.2
	var boundary_ordinary_camera := boundary_target + boundary_bisector * 35.0
	boundary_ordinary_camera.y = boundary.y + 2.2

	return [
		{"id": "01-sse-ordinary", "view_kind": "representative_sse_ordinary_gameplay_distance", "camera": sse_camera, "target": sse_target, "sun": Vector3(-52.0, -28.0, 0.0), "representative_runs": [5]},
		{"id": "02-ene-close", "view_kind": "representative_ene_close_runs_9_10", "camera": ene_close_camera, "target": ene_target, "sun": Vector3(-52.0, -28.0, 0.0), "representative_runs": [9, 10]},
		{"id": "03-ene-ordinary", "view_kind": "representative_ene_ordinary_gameplay_distance_runs_9_10_ground_edge", "camera": ene_ordinary_camera, "target": ene_target, "sun": Vector3(-52.0, -28.0, 0.0), "representative_runs": [9, 10]},
		{"id": "04-corner-changed-light-oblique", "view_kind": "changed_light_oblique_sse_run_7_to_ene_run_8_corner", "camera": corner_camera, "target": corner_target, "sun": Vector3(-24.0, 118.0, 0.0), "representative_runs": [7, 8], "transition": "accepted_run_7_to_accepted_run_8"},
		{"id": "05-run-11-12-boundary-close", "view_kind": "close_accepted_run_11_to_placeholder_run_12_boundary", "camera": boundary_close_camera, "target": boundary_target, "sun": Vector3(-52.0, -28.0, 0.0), "representative_runs": [11, 12], "transition": "accepted_run_11_to_placeholder_run_12"},
		{"id": "06-run-11-12-boundary-ordinary", "view_kind": "ordinary_whole_object_approach_accepted_run_11_to_placeholder_run_12_boundary", "camera": boundary_ordinary_camera, "target": boundary_target, "sun": Vector3(-52.0, -28.0, 0.0), "representative_runs": [11, 12], "transition": "accepted_run_11_to_placeholder_run_12"},
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
	var relative := "images/%s.png" % str(pose.id)
	var path := OUTPUT.path_join(relative)
	if image.save_png(path) != OK:
		return {"ok": false, "message": "%s could not save PNG." % str(pose.id)}
	var metadata := {
		"id": str(pose.id), "view_kind": str(pose.view_kind), "receiver_key": RECEIVER_KEY, "file": relative,
		"sha256": FileAccess.get_sha256(path), "bytes": FileAccess.get_file_as_bytes(path).size(), "dimensions": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"camera_position_m": [camera.position.x, camera.position.y, camera.position.z], "aim_target_m": [(pose.target as Vector3).x, (pose.target as Vector3).y, (pose.target as Vector3).z],
		"camera_fov_degrees": camera.fov, "sun_rotation_degrees": [sun.rotation_degrees.x, sun.rotation_degrees.y, sun.rotation_degrees.z],
		"representative_runs": (pose.get("representative_runs", []) as Array).duplicate(), "transition": str(pose.get("transition", "none")), "sample_unique_colors": int(sample.unique_colors), "sample_luminance_range": float(sample.luminance_range),
	}
	print("YMCA_EXACT_RUN_CAPTURE: image=%s sha256=%s" % [ProjectSettings.globalize_path(path), str(metadata.sha256)])
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
	push_error("YMCA_EXACT_RUN_CAPTURE_FAIL: %s" % message)


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
