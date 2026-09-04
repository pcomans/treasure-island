extends SceneTree

const OUTPUT := "res://evidence/first-playable/building-1-hero-2026-09-04"
const CONFIG_PATH := "res://game/resources/facades/building_1_hero_model.json"
const CAPTURE_SIZE := Vector2i(1440, 900)
const TIMEOUT_SECONDS := 240.0
const COMMAND := ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/building_1_hero_capture.gd"
const BUILDING_KEYS := [
	"building:r16681702:wall",
	"building:r16681702:roof",
	"building:w1222720021:wall",
	"building:w1222720021:roof",
]

var _failure := ""
var _finished := false


func _initialize() -> void:
	create_timer(TIMEOUT_SECONDS, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Building 1 hero evidence requires native macOS Forward+/Metal.")
		_finish(null)
		return
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene did not load for Building 1 hero capture."):
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
	if not _require(failures.is_empty() and reports.size() == 1, "Actual world did not reach one clean ready state for Building 1 hero capture."):
		_finish(main)
		return
	for key in BUILDING_KEYS:
		var nodes := _record_nodes(world, key)
		if not _require(nodes.size() == 1 and bool((nodes[0] as Node3D).get_meta("runtime_supersedes_generated_placeholder", false)), "%s hero runtime node is absent." % key):
			_finish(main)
			return
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT.path_join("images"))) != OK:
		_fail("Could not create Building 1 hero evidence directory.")
		_finish(main)
		return
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.set_gameplay_enabled(false)
	player.hide()
	(main.get_node("Interface/HUD") as GameHUD).hide()
	var camera := Camera3D.new()
	camera.name = "Building1HeroEvidenceCamera"
	camera.fov = 50.0
	camera.far = 5000.0
	camera.current = true
	main.add_child(camera)
	var sun := main.get_node("Sun") as DirectionalLight3D
	var original_sun := sun.rotation_degrees
	var captures: Array[Dictionary] = []
	for pose_value in _poses(original_sun):
		var pose := pose_value as Dictionary
		player.visible = bool(pose.get("show_player", false))
		if player.visible:
			var player_position := pose.player_position as Vector3
			player.global_position = player_position
		camera.global_position = pose.camera as Vector3
		camera.look_at(pose.target as Vector3, Vector3.UP)
		sun.rotation_degrees = pose.sun as Vector3
		for _frame in 3:
			await process_frame
		var saved := await _save_view(camera, pose)
		if not _require(bool(saved.get("ok", false)), str(saved.get("message", "Building 1 hero capture failed."))):
			_finish(main)
			return
		captures.append(saved.metadata as Dictionary)
	player.hide()
	sun.rotation_degrees = original_sun
	var runtime := world.get_runtime_evidence()
	var manifest := {
		"schema_version": "ti.building-1-hero-evidence/1",
		"review_status": "pending_independent_original_detail_review_not_self_accepted",
		"evidence_role": "actual-loaded-world inspection of a reversible exterior-only Building 1 hero proxy; not surveyed or as-built reconstruction",
		"capture_command": COMMAND,
		"generator": "game/tests/building_1_hero_capture.gd",
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_driver": DisplayServer.get_name(),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"rendering_method": "Forward+",
		"rendering_driver": "Metal",
		"viewport": [CAPTURE_SIZE.x, CAPTURE_SIZE.y],
		"config_path": CONFIG_PATH,
		"config_sha256": FileAccess.get_sha256(CONFIG_PATH),
		"adapter_path": "res://game/scripts/world/facades/building_1_hero_model.gd",
		"adapter_sha256": FileAccess.get_sha256("res://game/scripts/world/facades/building_1_hero_model.gd"),
		"world_builder_sha256": FileAccess.get_sha256("res://game/scripts/world/world_chunk_builder.gd"),
		"generated_source_bytes_unchanged": true,
		"source_photography_shipped": false,
		"source_keys": ["r16681702", "w1222720021"],
		"object_keys": BUILDING_KEYS,
		"tower_separate_recognition_entity": true,
		"runtime_topology": {
			"records": runtime.playable_rows,
			"meshes": runtime.mesh_instances,
			"surfaces": runtime.surfaces,
			"triangles": runtime.triangles,
			"static_bodies": runtime.static_bodies,
			"shapes": runtime.shapes,
		},
		"captures": captures,
		"capture_count": captures.size(),
		"representative_before_after_pairs": [
			["evidence/first-playable/exact-current-visual-repair-2026-09-03-104510/06-building-1-public-curve.png", "images/01-public-curve-same-camera-after.png"],
			["evidence/first-playable/treasure-island-building-1-recognizability-composition-2026-08-30/images/04-after-ordinary-north-end.png", "images/02-north-end-after.png"],
			["evidence/first-playable/treasure-island-building-1-recognizability-composition-2026-08-30/images/15-south-end-ordinary.png", "images/04-south-end-after.png"],
			["evidence/first-playable/treasure-island-building-1-recognizability-composition-2026-08-30/images/06-after-whole-building.png", "images/05-whole-building-after.png"],
		],
		"reviewer_instruction": "Open every output and paired before at original detail. Judge ordinary-distance stepped silhouette, center/wing/end hierarchy, 11-bay read, entrance/canopy, separate octagonal tower identity, material contrast, gaps/overlaps, and changed-light behavior. Executor acceptance is prohibited.",
	}
	if not _write_json(OUTPUT.path_join("capture-manifest.json"), manifest):
		_fail("Could not write Building 1 hero capture manifest.")
		_finish(main)
		return
	print("PASS: captured %d pending-review Building 1 hero views at %d/%d/%d/%d" % [captures.size(), runtime.mesh_instances, runtime.surfaces, runtime.triangles, runtime.static_bodies])
	_finish(main)


func _poses(original_sun: Vector3) -> Array[Dictionary]:
	return [
		{
			"id": "01-public-curve-same-camera-after",
			"view_kind": "ordinary_third_person_exact_current_camera_continuity",
			"camera": Vector3(-78.332703, 5.625095, 757.697632),
			"target": Vector3(0.941, 16.281, 749.703),
			"sun": original_sun,
			"show_player": true,
			"player_position": Vector3(-72.908752, 4.354177, 757.150635),
			"paired_before": "evidence/first-playable/exact-current-visual-repair-2026-09-03-104510/06-building-1-public-curve.png",
		},
		{
			"id": "02-north-end-after",
			"view_kind": "ordinary_height_north_end_and_wing",
			"camera": Vector3(-76.422760, 7.0, 648.677063),
			"target": Vector3(-46.729500, 14.0, 688.899536),
			"sun": original_sun,
			"paired_before": "evidence/first-playable/treasure-island-building-1-recognizability-composition-2026-08-30/images/04-after-ordinary-north-end.png",
		},
		{
			"id": "03-front-and-tower-after",
			"view_kind": "ordinary_height_front_entrance_and_tower_silhouette",
			"camera": Vector3(-135.0, 8.0, 710.0),
			"target": Vector3(0.0, 18.0, 738.0),
			"sun": original_sun,
		},
		{
			"id": "04-south-end-after",
			"view_kind": "ordinary_height_south_end_and_wing",
			"camera": Vector3(-38.394756, 7.0, 824.480713),
			"target": Vector3(-5.548500, 14.25, 796.457520),
			"sun": original_sun,
			"paired_before": "evidence/first-playable/treasure-island-building-1-recognizability-composition-2026-08-30/images/15-south-end-ordinary.png",
		},
		{
			"id": "05-whole-building-after",
			"view_kind": "elevated_diagnostic_not_ordinary_acceptance",
			"camera": Vector3(-165.0, 72.0, 750.0),
			"target": Vector3(-8.0, 16.0, 737.0),
			"sun": original_sun,
			"paired_before": "evidence/first-playable/treasure-island-building-1-recognizability-composition-2026-08-30/images/06-after-whole-building.png",
		},
		{
			"id": "06-tower-separate-entity-after",
			"view_kind": "separate_w1222720021_exact_plan_rooftop_tower_review",
			"camera": Vector3(-80.0, 34.0, 748.0),
			"target": Vector3(14.590, 30.5, 722.344),
			"sun": original_sun,
		},
		{
			"id": "07-rear-east-after",
			"view_kind": "rear_east_exterior_truth_view",
			"camera": Vector3(82.0, 9.0, 738.0),
			"target": Vector3(4.0, 18.0, 738.0),
			"sun": original_sun,
		},
		{
			"id": "08-public-curve-changed-light-after",
			"view_kind": "ordinary_public_curve_changed_light",
			"camera": Vector3(-78.332703, 5.625095, 757.697632),
			"target": Vector3(0.941, 16.281, 749.703),
			"sun": Vector3(-18.0, 118.0, 0.0),
		},
	]


func _save_view(camera: Camera3D, pose: Dictionary) -> Dictionary:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.get_width() != CAPTURE_SIZE.x or image.get_height() != CAPTURE_SIZE.y:
		return {"ok": false, "message": "Building 1 hero capture returned the wrong image dimensions."}
	var path := OUTPUT.path_join("images/%s.png" % str(pose.id))
	var absolute := ProjectSettings.globalize_path(path)
	var error := image.save_png(absolute)
	if error != OK:
		return {"ok": false, "message": "Could not save %s." % path}
	var file := FileAccess.open(path, FileAccess.READ)
	var metadata := {
		"id": str(pose.id),
		"file": "images/%s.png" % str(pose.id),
		"view_kind": str(pose.view_kind),
		"camera_position_m": _vector(camera.global_position),
		"target_position_m": _vector(pose.target as Vector3),
		"camera_forward": _vector(-camera.global_basis.z),
		"sun_rotation_degrees": _vector(pose.sun as Vector3),
		"player_visible": bool(pose.get("show_player", false)),
		"paired_before": str(pose.get("paired_before", "")),
		"dimensions": [image.get_width(), image.get_height()],
		"bytes": file.get_length() if file != null else -1,
		"sha256": FileAccess.get_sha256(path),
	}
	if file != null:
		file.close()
	return {"ok": true, "metadata": metadata}


func _record_nodes(world: WorldLoader, key: String) -> Array[Node]:
	var result: Array[Node] = []
	for child in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if str(child.get_meta("derived_object_key", "")) == key and child.get_parent() != null and str(child.get_parent().name).contains("__"):
			result.append(child)
	return result


func _write_json(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value, "  ", false) + "\n")
	file.close()
	return true


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
	_fail("Building 1 hero capture timed out.")
	_finish(null)
