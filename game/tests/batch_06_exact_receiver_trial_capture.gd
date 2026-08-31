extends SceneTree

const ACCEPTED_MATERIAL_RUN_TRIALS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const OUTPUT := "res://evidence/first-playable/batch-06-exact-receiver-trials-2026-08-30"
const CAPTURE_SIZE := Vector2i(1440, 900)
const TIMEOUT_SECONDS := 300.0
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/batch_06_exact_receiver_trial_capture.gd"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_BUILDER_SHA256 := "c770a977e879c0d077acb8fb4d33b52d1bd6aa3b454a50ba8e2125cb71e8ba8d"
# Immutable pre-promotion evidence inputs. Current-state contracts intentionally
# pin the promoted helper and accepted lifecycle status separately.
const EXPECTED_CAPTURE_TIME_HELPER_SHA256 := "8fd1d899cf658f84a5044597e1194d6d0450b74b00281b73ad9b1c91914b21d0"
const HISTORICAL_CAPTURE_STATUS := "controlled_exact_receiver_scale_trial_pending_independent_review"
const EXPECTED_ART_REVIEW_SHA256 := "bfaccbf182fb04222b5a65356f3287bd7823f5b692d0da6d2d44b2e2af5599eb"
const EXPECTED_RUN_MAPPING_SHA256 := "0d9ef02bbdf38902bfddb475f96167abd6460163d94c26984ae5b29da0c7497d"
const EXPECTED_REGISTRY_SHA256 := "a599df850a3ca51a51a3223820fc840201559ba26eb5ed514211eaedc2304132"

const TARGETS := [
	{
		"slug": "w34313564", "source_key": "w34313564", "receiver_key": "building:w34313564:wall",
		"chunk": "res://generated/world/chunks/x_0__z_-3.json", "run_count": 20,
		"groups": [
			{"id": "W34313564-MAT-TAN", "run_groups": [[5, 6, 7, 8, 9]], "runs": [5, 6, 7, 8, 9], "length_m": 87.651, "surface_name": "trial_w34313564_tan_runs", "prototype": "res://game/resources/materials/world/w34313564/w34313564_tan_field.tres", "prototype_sha256": "2503ee946804bd16db9ca60ae05a0a1b9b6ca7c46422e0997ac2891c79a7ea76", "material": "res://game/resources/materials/world/w34313564/w34313564_tan_exact_trial.tres", "material_sha256": "3b895743b247a20641cb7564004d2f890bacfc286feaec9044b334b5e8e170bb"},
			{"id": "W34313564-MAT-PALE", "run_groups": [[10, 11, 12, 13, 14, 15, 16, 17, 18, 19]], "runs": [10, 11, 12, 13, 14, 15, 16, 17, 18, 19], "length_m": 141.340, "surface_name": "trial_w34313564_pale_runs", "prototype": "res://game/resources/materials/world/w34313564/w34313564_pale_field.tres", "prototype_sha256": "4523c071e50875db052e98ac39b9d9eff9cfb487aa37344064834ae82c0aae83", "material": "res://game/resources/materials/world/w34313564/w34313564_pale_exact_trial.tres", "material_sha256": "c7ec2df12b0dcf41e2b5019fd98155dbe3668d16379070210fe9f97ef032a343"},
		],
		"poses": [
			{"id": "01-close-tan", "view_kind": "close_field", "kind": "face", "run": 7, "distance": 7.0, "lateral": 0.0, "height": 2.3, "sun": Vector3(-52.0, -28.0, 0.0)},
			{"id": "02-ordinary-pale", "view_kind": "ordinary_gameplay_distance", "kind": "face", "run": 16, "distance": 26.0, "lateral": 0.0, "height": 2.3, "sun": Vector3(-52.0, -28.0, 0.0)},
			{"id": "03-changed-light-tan-pale-corner", "view_kind": "changed_light_oblique", "kind": "boundary", "before": 9, "after": 10, "distance": 18.0, "height": 3.4, "sun": Vector3(-24.0, 118.0, 0.0)},
			{"id": "04-pale-orientation-corner", "view_kind": "accepted_orientation_corner", "kind": "boundary", "before": 13, "after": 14, "distance": 16.0, "height": 3.0, "sun": Vector3(-52.0, -28.0, 0.0)},
			{"id": "05-placeholder-to-tan-transition", "view_kind": "accepted_placeholder_transition", "kind": "boundary", "before": 4, "after": 5, "distance": 10.0, "height": 2.4, "sun": Vector3(-52.0, -28.0, 0.0)},
		],
	},
	{
		"slug": "w34313515", "source_key": "w34313515", "receiver_key": "building:w34313515:wall",
		"chunk": "res://generated/world/chunks/x_-1__z_1.json", "run_count": 48,
		"groups": [
			{"id": "W34313515-MAT-PALE", "run_groups": [[0, 1, 2, 3, 4, 5, 6, 7, 8], [43, 44, 45, 46, 47]], "runs": [0, 1, 2, 3, 4, 5, 6, 7, 8, 43, 44, 45, 46, 47], "length_m": 165.100, "surface_name": "trial_w34313515_pale_runs", "prototype": "res://game/resources/materials/world/w34313515/w34313515_pale_field.tres", "prototype_sha256": "0f97c958b35fe8c52e61db532c9caed95566330d9269e4b830e2c319ec47023e", "material": "res://game/resources/materials/world/w34313515/w34313515_pale_exact_trial.tres", "material_sha256": "0b8704ccc352374adc1d6a553ff3d985ae2b70559d92b5171092450783b4395f"},
		],
		"poses": [
			{"id": "01-close-wsw", "view_kind": "close_field", "kind": "face", "run": 3, "distance": 7.0, "lateral": 0.0, "height": 4.0, "sun": Vector3(-52.0, -28.0, 0.0)},
			{"id": "02-ordinary-nnw", "view_kind": "ordinary_gameplay_distance", "kind": "face", "run": 45, "distance": 28.0, "lateral": 0.0, "height": 4.0, "sun": Vector3(-52.0, -28.0, 0.0)},
			{"id": "03-changed-light-oblique-wsw", "view_kind": "changed_light_oblique", "kind": "face", "run": 3, "distance": 18.0, "lateral": 10.0, "height": 5.0, "sun": Vector3(-24.0, 118.0, 0.0)},
			{"id": "04-accepted-wrap-corner", "view_kind": "accepted_orientation_corner", "kind": "boundary", "before": 47, "after": 0, "distance": 18.0, "height": 4.2, "sun": Vector3(-52.0, -28.0, 0.0)},
			{"id": "05-accepted-to-placeholder-transition", "view_kind": "accepted_placeholder_transition", "kind": "boundary", "before": 8, "after": 9, "distance": 12.0, "height": 4.0, "sun": Vector3(-52.0, -28.0, 0.0)},
		],
	},
	{
		"slug": "w291196370", "source_key": "w291196370", "receiver_key": "building:w291196370:wall",
		"chunk": "res://generated/world/chunks/x_0__z_-3.json", "run_count": 36,
		"groups": [
			{"id": "W291196370-SIDING", "run_groups": [[8, 9, 10], [17, 18, 19, 20, 21, 22]], "runs": [8, 9, 10, 17, 18, 19, 20, 21, 22], "length_m": 97.893, "surface_name": "trial_w291196370_siding_runs", "prototype": "res://game/resources/materials/world/w291196370/w291196370_siding_field.tres", "prototype_sha256": "f5c359c34f6e4c61020a49391f0dad04f637730b955ae14195a87260588fce5f", "material": "res://game/resources/materials/world/w291196370/w291196370_siding_exact_trial.tres", "material_sha256": "715cf02b3c006c1a492ad61def9b2535fbaf04a3b1a41c69c5f092d705fab677"},
		],
		"poses": [
			{"id": "01-close-sse", "view_kind": "close_field", "kind": "face", "run": 9, "distance": 7.0, "lateral": 0.0, "height": 2.7, "sun": Vector3(-52.0, -28.0, 0.0)},
			{"id": "02-ordinary-ene", "view_kind": "ordinary_gameplay_distance", "kind": "face", "run": 19, "distance": 27.0, "lateral": 0.0, "height": 2.7, "sun": Vector3(-52.0, -28.0, 0.0)},
			{"id": "03-changed-light-oblique-sse", "view_kind": "changed_light_oblique", "kind": "face", "run": 9, "distance": 17.0, "lateral": 9.0, "height": 3.8, "sun": Vector3(-24.0, 118.0, 0.0)},
			{"id": "04-ene-corner", "view_kind": "accepted_orientation_corner", "kind": "boundary", "before": 22, "after": 23, "distance": 12.0, "height": 3.0, "sun": Vector3(-52.0, -28.0, 0.0)},
			{"id": "05-sse-to-placeholder-transition", "view_kind": "accepted_placeholder_transition", "kind": "boundary", "before": 10, "after": 11, "distance": 11.0, "height": 2.8, "sun": Vector3(-52.0, -28.0, 0.0)},
		],
	},
]

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Batch 06 exact-receiver evidence requires the native macOS display.")
		_finish(null)
		return
	var expected_hashes := {
		"res://generated/world/manifest.json": EXPECTED_MANIFEST_SHA256,
		"res://game/scripts/world/world_chunk_builder.gd": EXPECTED_BUILDER_SHA256,
		"res://game/scripts/world/facades/accepted_material_run_trials.gd": EXPECTED_CAPTURE_TIME_HELPER_SHA256,
		"res://discovery/facades/BATCH_06_PROTOTYPE_SET_01_ART_REVIEW.md": EXPECTED_ART_REVIEW_SHA256,
		"res://discovery/facades/BATCH_06_RUN_MAPPING.json": EXPECTED_RUN_MAPPING_SHA256,
		"res://game/resources/facades/batch_06_prototype_registry.json": EXPECTED_REGISTRY_SHA256,
	}
	for path: String in expected_hashes:
		if not _require(FileAccess.get_sha256(path) == str(expected_hashes[path]), "Protected input drifted before capture: %s" % path):
			_finish(null)
			return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for Batch 06 exact-receiver capture."):
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
	while ready_reports.is_empty() and load_failures.is_empty() and Time.get_ticks_msec() - started < 50000:
		await process_frame
	if not _require(load_failures.is_empty() and ready_reports.size() == 1, "Full world did not reach one clean world_ready for Batch 06 capture.") \
	or not _require(str(ready_reports[0].get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content identity drifted before capture."):
		_finish(main)
		return
	var evidence := world.get_runtime_evidence()
	if not _require(evidence.chunks_loaded == 38 and evidence.mesh_instances == 729 and evidence.surfaces == 736 and evidence.triangles == 48389, "Whole-island render topology drifted before capture.") \
	or not _require(evidence.static_bodies == 466 and evidence.shapes == 466, "Whole-island collision topology drifted before capture."):
		_finish(main)
		return
	var output_absolute := ProjectSettings.globalize_path(OUTPUT)
	if not _require(DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images/whole-island")) == OK, "Could not create evidence directory."):
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.hide()
	player.set_gameplay_enabled(false)
	(main.get_node("Interface/HUD") as GameHUD).hide()
	var camera := Camera3D.new()
	camera.name = "Batch06ExactReceiverEvidenceCamera"
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
	var target_manifests: Array[Dictionary] = []
	for target_value: Variant in TARGETS:
		var target := target_value as Dictionary
		var record := _record_data(target)
		var receiver := _record_node_for_key(world, str(target.receiver_key))
		var live := _live_receiver_contract(receiver, record, target)
		if not _require(bool(live.get("ok", false)), str(live.get("message", "Live Batch 06 receiver contract failed."))):
			_finish(main)
			return
		if DirAccess.make_dir_recursive_absolute(output_absolute.path_join("images").path_join(str(target.slug))) != OK:
			_fail("Could not create target image directory for %s." % str(target.source_key))
			_finish(main)
			return
		var target_captures: Array[Dictionary] = []
		for pose_spec_value: Variant in target.poses:
			var pose_spec := pose_spec_value as Dictionary
			var pose := _pose(record, pose_spec)
			detail.text = "BATCH 06 CONTROLLED EXACT-RECEIVER FIELD TRIAL · %s\n%s · %s\n%s · SCALE LIMITATION RETAINED · NOT ART ACCEPTANCE" % [str(target.source_key), str(target.receiver_key), _scope_text(target), str(pose.view_kind).replace("_", " ").to_upper()]
			camera.position = pose.camera as Vector3
			camera.look_at(pose.target as Vector3, Vector3.UP)
			sun.rotation_degrees = pose.sun as Vector3
			var saved := await _save_view(camera, sun, target, pose)
			if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Batch 06 target capture failed."))):
				_finish(main)
				return
			target_captures.append(saved.metadata as Dictionary)
			captures.append(saved.metadata as Dictionary)
		target_manifests.append({
			"source_key": str(target.source_key), "receiver_key": str(target.receiver_key),
			"field_groups": target.groups, "placeholder_runs": live.placeholder_runs,
			"surface_names": live.surface_names, "modules": 0, "rejected_modules_live": 0,
			"render_triangles": live.render_triangles, "collision_triangles": live.collision_triangles,
			"captures": target_captures, "metadata": receiver.get_meta("accepted_material_run_trial", {}),
		})
	sun.rotation_degrees = original_sun
	detail.text = "WHOLE-ISLAND CONTROLLED FIELD-TRIAL LOAD PROOF\n38/38 chunks · 729 meshes · 736 surfaces · 48,389 triangles · 466 collider pairs\nFOUR FIELD SURFACES · SIX MODULES EXCLUDED · NOT ART ACCEPTANCE"
	var whole_pose := {"id": "01-whole-island-load", "view_kind": "whole_island_load_proof", "camera": Vector3(180.0, 1550.0, 300.0), "target": Vector3(-20.0, 0.0, 30.0), "sun": original_sun}
	camera.position = whole_pose.camera
	camera.look_at(whole_pose.target, Vector3.UP)
	var whole_saved := await _save_view(camera, sun, {"slug": "whole-island", "receiver_key": "whole-island"}, whole_pose)
	if not _require(bool(whole_saved.get("ok", false)), str(whole_saved.get("message", "Whole-island capture failed."))):
		_finish(main)
		return
	captures.append(whole_saved.metadata as Dictionary)
	var manifest := {
		"schema_version": "ti.batch-06-exact-receiver-field-trial-evidence/1",
		"review_status": "ready_for_independent_exact_receiver_gameplay_art_review_not_self_accepted",
		"evidence_role": "controlled runtime field-scale/orientation/boundary proof only; not lifecycle acceptance, module evidence, live attachment acceptance, or whole-building proof",
		"generator": "game/tests/batch_06_exact_receiver_trial_capture.gd", "capture_command": COMMAND,
		"godot_version": Engine.get_version_info().get("string", "unknown"), "display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(), "rendering_method": "Forward+", "rendering_driver": "Metal", "viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"content_sha256": EXPECTED_CONTENT_SHA256, "generated_manifest_sha256": EXPECTED_MANIFEST_SHA256,
		"world_chunk_builder_sha256": EXPECTED_BUILDER_SHA256, "run_partition_helper_sha256": EXPECTED_HELPER_SHA256,
		"independent_art_review_sha256": EXPECTED_ART_REVIEW_SHA256, "run_mapping_sha256": EXPECTED_RUN_MAPPING_SHA256, "prototype_registry_sha256": EXPECTED_REGISTRY_SHA256,
		"generated_world_counts": {"chunks": evidence.chunks_loaded, "records": 729, "meshes": evidence.mesh_instances, "surfaces": evidence.surfaces, "triangles": evidence.triangles, "static_bodies": evidence.static_bodies, "shapes": evidence.shapes},
		"surface_delta": {"baseline_one_surface_per_mesh": 729, "accepted_exact_run_delta": 3, "controlled_batch_06_delta": 4, "actual": 736, "cause": "w34313564 placeholder+tan+pale adds 2; w34313515 placeholder+pale adds 1; w291196370 placeholder+siding adds 1"},
		"targets": target_manifests, "capture_count": captures.size(), "captures": captures,
		"standalone_field_blocker": {"id": "W34313564-MAT-PLINTH", "prototype_path": "res://game/resources/materials/world/w34313564/w34313564_plinth_field.tres", "prototype_sha256": "89a36e7fb036bf8bd3f5db0996076c477641e2c7e97d29537c2c464155b12d88", "runtime_surfaces": 0, "reason": "exact vertical extent and side bounds unresolved; run-only partition cannot isolate plinth without prohibited geometry splitting"},
		"rejected_modules": {"runtime_count": 0, "ids": ["W34313564-HWIN", "W34313564-PDOOR", "W34313515-BAY", "W291196370-WINSTACK", "W291196370-ENTRY", "W291196370-SERVICE"]},
		"projection": {"horizontal": "dot(VERTEX.xz, vec2(normalize(NORMAL.xz).y, -normalize(NORMAL.xz).x))", "vertical": "VERTEX.y", "physical_units": "one shader coordinate unit per generated wall-local metre", "siding_course_phase": "global VERTEX.y / 0.20 m; no generated U dependency"},
		"protected_scope": {"generated_files_modified": false, "geometry_modified": false, "massing_modified": false, "terrain_or_foundations_modified": false, "collision_modified": false, "navigation_modified": false, "spray_or_gameplay_modified": false, "modules_added": 0},
		"validity_inspection_only": "Captured images must be inspected for target visibility, nonblank render, camera diversity, and transition/corner coverage. No executor art acceptance is authorized.",
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write Batch 06 exact-receiver capture manifest.")
		_finish(main)
		return
	print("PASS: captured 15 target views plus one whole-island native Forward+/Metal proof to %s" % output_absolute)
	_finish(main)


func _record_data(target: Dictionary) -> Dictionary:
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(str(target.chunk))) as Dictionary
	for record_value: Variant in chunk.get("records", []):
		var record := record_value as Dictionary
		if str(record.get("object_key", "")) == str(target.receiver_key):
			return record
	return {}


func _record_node_for_key(world: WorldLoader, key: String) -> Node3D:
	for value: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if str(value.get_meta("derived_object_key", "")) == key:
			return value as Node3D
	return null


func _live_receiver_contract(receiver: Node3D, record: Dictionary, target: Dictionary) -> Dictionary:
	if receiver == null or record.is_empty() or receiver.get_meta("source_keys", []) != [str(target.source_key)]:
		return {"ok": false, "message": "Exact receiver/source identity did not resolve for %s." % str(target.source_key)}
	var mesh_instance := receiver.get_node_or_null("Mesh") as MeshInstance3D
	var shape_node := receiver.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	var metadata := receiver.get_meta("accepted_material_run_trial", {}) as Dictionary
	if metadata != ACCEPTED_MATERIAL_RUN_TRIALS.metadata_for(str(target.receiver_key)) \
	or str(metadata.get("status", "")) != HISTORICAL_CAPTURE_STATUS \
	or int(metadata.get("modules", -1)) != 0 or int(metadata.get("rejected_modules_live", -1)) != 0 \
	or mesh_instance == null or not (mesh_instance.mesh is ArrayMesh) or shape == null \
	or receiver.find_children("*", "MeshInstance3D", true, false).size() != 1 \
	or not receiver.find_children("*Facade*", "Node", true, false).is_empty():
		return {"ok": false, "message": "Controlled receiver metadata/module/shape contract drifted for %s." % str(target.source_key)}
	var mesh := mesh_instance.mesh as ArrayMesh
	if mesh.get_surface_count() != 1 + (target.groups as Array).size() \
	or mesh.surface_get_name(0) != ACCEPTED_MATERIAL_RUN_TRIALS.PLACEHOLDER_SURFACE_NAME:
		return {"ok": false, "message": "Controlled receiver surface count/order drifted for %s." % str(target.source_key)}
	var trial_runs: Array[int] = []
	var surface_names: Array[String] = [mesh.surface_get_name(0)]
	for group_index in (target.groups as Array).size():
		var group := (target.groups as Array)[group_index] as Dictionary
		var surface_index := group_index + 1
		if mesh.surface_get_name(surface_index) != str(group.surface_name) \
		or mesh.surface_get_material(surface_index).resource_path != str(group.material) \
		or FileAccess.get_sha256(str(group.material)) != str(group.material_sha256) \
		or FileAccess.get_sha256(str(group.prototype)) != str(group.prototype_sha256) \
		or _runs_for_surface(mesh, surface_index) != _int_array(group.runs as Array):
			return {"ok": false, "message": "Controlled field surface/material/run scope drifted for %s." % str(group.id)}
		trial_runs.append_array(_int_array(group.runs as Array))
		surface_names.append(mesh.surface_get_name(surface_index))
	trial_runs.sort()
	var placeholder_runs: Array[int] = []
	for run_index in int(target.run_count):
		if not trial_runs.has(run_index):
			placeholder_runs.append(run_index)
	if _runs_for_surface(mesh, 0) != placeholder_runs:
		return {"ok": false, "message": "Placeholder complement drifted for %s." % str(target.source_key)}
	var signatures := _triangle_signatures_for_mesh(mesh)
	var collision_signatures := _triangle_signatures_for_faces(shape.get_faces())
	if signatures.is_empty() or signatures.size() != int((record.indices as Array).size() / 3) \
	or _sorted_keys(signatures) != _sorted_keys(collision_signatures):
		return {"ok": false, "message": "Duplicate/coplanar or collision triangle drift found for %s." % str(target.source_key)}
	return {"ok": true, "placeholder_runs": placeholder_runs, "surface_names": surface_names, "render_triangles": signatures.size(), "collision_triangles": collision_signatures.size()}


func _pose(record: Dictionary, spec: Dictionary) -> Dictionary:
	if str(spec.kind) == "boundary":
		return _boundary_pose(record, spec)
	return _face_pose(record, spec)


func _face_pose(record: Dictionary, spec: Dictionary) -> Dictionary:
	var run := _run_frame(record, int(spec.run))
	var center := run.center as Vector3
	var camera := center + (run.normal as Vector3) * float(spec.distance) + (run.tangent as Vector3) * float(spec.lateral)
	camera.y = float(run.base_y) + float(spec.height)
	return {"id": str(spec.id), "view_kind": str(spec.view_kind), "camera": camera, "target": center, "sun": spec.sun, "run": int(spec.run)}


func _boundary_pose(record: Dictionary, spec: Dictionary) -> Dictionary:
	var before := _run_frame(record, int(spec.before))
	var after := _run_frame(record, int(spec.after))
	var junction := ((before.end as Vector3) + (after.start as Vector3)) * 0.5
	var outward := ((before.normal as Vector3) + (after.normal as Vector3)).normalized()
	if outward.length_squared() < 0.25:
		outward = before.normal as Vector3
	var camera := junction + outward * float(spec.distance)
	camera.y = minf(float(before.base_y), float(after.base_y)) + float(spec.height)
	var target := junction
	target.y = (float(before.center_y) + float(after.center_y)) * 0.5
	return {"id": str(spec.id), "view_kind": str(spec.view_kind), "camera": camera, "target": target, "sun": spec.sun, "before_run": int(spec.before), "after_run": int(spec.after)}


func _run_frame(record: Dictionary, run_index: int) -> Dictionary:
	var values := record.vertices as Array
	var normals := record.normals as Array
	var offset := run_index * 12
	var start := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
	var end := Vector3(float(values[offset + 3]), float(values[offset + 4]), float(values[offset + 5]))
	var top_end := Vector3(float(values[offset + 6]), float(values[offset + 7]), float(values[offset + 8]))
	var top_start := Vector3(float(values[offset + 9]), float(values[offset + 10]), float(values[offset + 11]))
	var normal := Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized()
	var tangent := Vector3(end.x - start.x, 0.0, end.z - start.z).normalized()
	var center := (start + end + top_end + top_start) * 0.25
	return {"start": start, "end": end, "normal": normal, "tangent": tangent, "center": center, "center_y": center.y, "base_y": minf(start.y, end.y)}


func _scope_text(target: Dictionary) -> String:
	var parts: Array[String] = []
	for group_value: Variant in target.groups:
		var group := group_value as Dictionary
		parts.append("%s %s %.3f m" % [str(group.id), str(group.run_groups), float(group.length_m)])
	return " · ".join(parts)


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
	detail.add_theme_font_size_override("font_size", 16)
	detail.add_theme_color_override("font_color", Color("f4f0e8"))
	overlay.add_child(detail)
	return overlay


func _save_view(camera: Camera3D, sun: DirectionalLight3D, target: Dictionary, pose: Dictionary) -> Dictionary:
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
		"run": int(pose.get("run", -1)), "before_run": int(pose.get("before_run", -1)), "after_run": int(pose.get("after_run", -1)),
		"sample_unique_colors": int(sample.unique_colors), "sample_luminance_range": float(sample.luminance_range),
	}
	print("BATCH06_EXACT_CAPTURE: image=%s sha256=%s" % [ProjectSettings.globalize_path(path), str(metadata.sha256)])
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


func _runs_for_surface(mesh: ArrayMesh, surface_index: int) -> Array[int]:
	var indices := mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] as PackedInt32Array
	var counts := {}
	for vertex_index: int in indices:
		var run_index := vertex_index / 4
		counts[run_index] = int(counts.get(run_index, 0)) + 1
	var result: Array[int] = []
	for run_value: Variant in counts.keys():
		var run_index := int(run_value)
		if int(counts[run_index]) != 6:
			return []
		result.append(run_index)
	result.sort()
	return result


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


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_fail(message)
	return false


func _fail(message: String) -> void:
	if _failure.is_empty():
		_failure = message
	push_error("BATCH06_EXACT_CAPTURE_FAIL: %s" % message)


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
