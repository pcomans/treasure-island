extends SceneTree

const HERO := preload("res://game/scripts/world/facades/building_1_hero_model.gd")
const LEGACY_FACADE := preload("res://game/scripts/world/facades/building_1_recognizable_facade.gd")
const MAIN_CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const TOWER_CHUNK_PATH := "res://generated/world/chunks/x_0__z_2.json"
const EXPECTED_COMPONENT_TOPOLOGY := {
	"building:r16681702:wall": [6, 6, 8806],
	"building:r16681702:roof": [3, 3, 1131],
	"building:w1222720021:wall": [3, 3, 760],
	"building:w1222720021:roof": [1, 1, 14],
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var records := _records()
	_require(records.size() == 4, "The current Building 1/tower source-record set did not resolve.")
	if records.size() != 4:
		_finish()
		return

	# Keep the independently reviewed predecessor byte- and topology-checkable,
	# but prove that it is no longer attached to the actual world.
	var legacy := LEGACY_FACADE.build(records[HERO.BUILDING_WALL_KEY] as Dictionary)
	_require(bool(legacy.get("ok", false)), "The historical Building 1 recognizability artifact no longer builds from its sealed inputs.")
	if bool(legacy.get("ok", false)):
		var legacy_root := legacy.node as Node3D
		_require(
			int(legacy.mesh_instances) == 354 \
			and int(legacy.surfaces) == 354 \
			and int(legacy.triangles) == 4338 \
			and _count_type(legacy_root, CollisionObject3D) == 0 \
			and str(legacy_root.get_meta("composition_review_status", "")) == LEGACY_FACADE.COMPOSITION_REVIEW_STATUS,
			"The historical Building 1 composition topology or review provenance drifted.",
		)
		legacy_root.free()

	for key in HERO.TARGET_KEYS:
		var result := WorldChunkBuilder.new()._build_record(records[key] as Dictionary, false)
		_require(bool(result.get("ok", false)), "%s did not build through the current hero interception." % key)
		if not bool(result.get("ok", false)):
			continue
		var node := result.node as Node3D
		var expected := EXPECTED_COMPONENT_TOPOLOGY[key] as Array
		_require(
			[int(result.mesh_instances), int(result.surfaces), int(result.triangles)] == expected,
			"%s current hero topology drifted." % key,
		)
		_require(
			str(node.get_meta("derived_object_key", "")) == key \
			and bool(node.get_meta("runtime_supersedes_generated_placeholder", false)) \
			and str(node.get_meta("vertical_massing_role", "")) == "reversible_production_inference" \
			and str(node.get_meta("visual_review_status", "")) == HERO.VISUAL_REVIEW_STATUS \
			and not node.has_node("Building1RecognizableFacade") \
			and not bool(node.get_meta("as_built_fidelity_claimed", true)),
			"%s current identity, supersession, or truth boundary drifted." % key,
		)
		node.free()

	await _whole_world_contract()
	if not _failed:
		print("PASS: historical Building 1 recognizability remains sealed but inert; four separately keyed accepted-current hero components supersede the generic placeholders at 13 meshes / 13 surfaces / 10,711 triangles with world 735/940/954/64,118/466")
	_finish()


func _whole_world_contract() -> void:
	var world := (load("res://game/scenes/world/world_root.tscn") as PackedScene).instantiate() as WorldLoader
	var reports: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: failures.append({"code": code, "message": message, "source_keys": source_keys}))
	root.add_child(world)
	world.load_world("res://generated/world/manifest.json")
	await process_frame
	await process_frame
	var evidence := world.get_runtime_evidence()
	_require(
		failures.is_empty() and reports.size() == 1 and evidence != null \
		and evidence.playable_rows == 735 and evidence.context_rows == 4 \
		and evidence.mesh_instances == 940 and evidence.surfaces == 954 \
		and evidence.triangles == 64118 and evidence.static_bodies == 466 and evidence.shapes == 466,
		"Whole-island topology or load drifted after Building 1 hero supersession.",
	)
	for key in HERO.TARGET_KEYS:
		var nodes := _nodes_for_key(world, key)
		_require(nodes.size() == 1 and bool((nodes[0] as Node3D).get_meta("runtime_supersedes_generated_placeholder", false)), "%s is not represented exactly once by the current hero." % key)
	_require(world.find_children("Building1RecognizableFacade", "Node3D", true, false).is_empty(), "The historical Building 1 render attachment is still live in the actual world.")
	root.remove_child(world)
	world.free()


func _records() -> Dictionary:
	var result := {}
	for path in [MAIN_CHUNK_PATH, TOWER_CHUNK_PATH]:
		for value in _json(path).get("records", []):
			var record := value as Dictionary
			if str(record.get("object_key", "")) in HERO.TARGET_KEYS:
				result[str(record.object_key)] = record
	return result


func _nodes_for_key(node: Node, key: String) -> Array[Node]:
	var result: Array[Node] = []
	for child: Node in node.find_children("*", "Node3D", true, false):
		if str(child.get_meta("derived_object_key", "")) == key and child.get_parent() != null and str(child.get_parent().name).contains("__"):
			result.append(child)
	return result


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _require(condition: bool, message: String) -> bool:
	if not condition:
		_failed = true
		push_error(message)
	return condition


func _finish() -> void:
	quit(1 if _failed else 0)
