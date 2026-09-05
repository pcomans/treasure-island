extends SceneTree

const ADAPTER := preload("res://game/scripts/world/facades/navy_chapel_187_live_replacement.gd")
const ADAPTER_PATH := "res://game/scripts/world/facades/navy_chapel_187_live_replacement.gd"
const BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const MANIFEST_PATH := "res://generated/world/manifest.json"
const REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const WALL_KEY := "building:w291189336:wall"
const ROOF_KEY := "building:w291189336:roof"
const PRIVATE_REVIEW := "res://evidence/first-playable/navy-chapel-187-standalone-hero-2026-09-04/INDEPENDENT_BAR_RAISER_REVIEW.md"
const PRIVATE_PACKET := "res://discovery/facades/p3_reference_packets/w291189336_navy_chapel_building_187.md"
const FRESH_EVIDENCE := "res://evidence/first-playable/navy-chapel-187-live-replacement-2026-09-04/capture-manifest.json"
const EXPECTED_TOPOLOGY := {"rows": 735, "meshes": 950, "surfaces": 964, "triangles": 66636, "bodies": 466, "shapes": 466}
const REQUIRED_PACKAGE_RESOURCES := [
	ADAPTER_PATH,
	"res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd",
	"res://game/resources/facades/navy_chapel_187_standalone_hero_prototype.json",
	"res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_protected_neutral.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_inferred_cream_structure.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_pale_trim.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_opaque_opening.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_neutral_roof.tres",
	BUILDER_PATH, CHUNK_PATH, MANIFEST_PATH,
	REGISTRY_PATH,
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var mounted := "--mounted" in OS.get_cmdline_user_args()
	for path: String in REQUIRED_PACKAGE_RESOURCES:
		_require(ResourceLoader.exists(path) or FileAccess.file_exists(path), "Package closure is missing %s." % path)
	if mounted:
		_require(not ResourceLoader.exists(PRIVATE_REVIEW) and not FileAccess.file_exists(PRIVATE_REVIEW), "Mounted package contains the private Chapel review.")
		_require(not ResourceLoader.exists(PRIVATE_PACKET) and not FileAccess.file_exists(PRIVATE_PACKET), "Mounted package contains the discovery-only Chapel packet.")
		_require(not ResourceLoader.exists(FRESH_EVIDENCE) and not FileAccess.file_exists(FRESH_EVIDENCE), "Mounted package contains live review evidence.")
	else:
		_source_boundary_checks()
	_require(_registry_topology_scope_matches(), "Navy Chapel authority does not distinguish its pre-B201 integration parity snapshot from current integration topology.")
	var chunk_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH))
	if not _require(chunk_value is Dictionary, "Packaged Chapel source chunk did not parse."):
		_finish(mounted)
		return
	var chunk := chunk_value as Dictionary
	var parent_nodes := {"ground": Node3D.new(), "roads": Node3D.new(), "buildings": Node3D.new()}
	var report := WorldChunkBuilder.new().build_chunk(chunk, parent_nodes)
	if not _require(bool(report.get("ok", false)), "Packaged builder rejected the exact Chapel chunk: %s" % report):
		for parent: Node3D in parent_nodes.values():
			parent.free()
		_finish(mounted)
		return
	var staging := report.node as Node3D
	var walls := _nodes_for_key(staging, WALL_KEY)
	var roofs := _nodes_for_key(staging, ROOF_KEY)
	_require(walls.size() == 1 and roofs.size() == 1, "Packaged chunk did not emit exactly one Chapel wall and roof replacement.")
	if walls.size() == 1 and roofs.size() == 1:
		_require(_pair_matches(walls[0], roofs[0]), "Packaged Chapel pair topology, signature, or ownership drifted.")
	staging.free()
	for parent: Node3D in parent_nodes.values():
		parent.free()
	if not mounted:
		var world_result := await _world_matches()
		_require(bool(world_result.get("ok", false)), str(world_result.get("message", "Source Chapel world check failed.")))
	_finish(mounted)


func _source_boundary_checks() -> void:
	_require(FileAccess.get_sha256(PRIVATE_REVIEW) == ADAPTER.APPROVAL_RECEIPT_SHA256, "Independent Chapel standalone PASS receipt drifted.")
	_require(FileAccess.get_sha256(CHUNK_PATH) == "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce", "Chapel source chunk drifted.")
	_require(ADAPTER.source_dependency_hashes_match(), "An approved Chapel source dependency byte drifted.")
	var closure := ""
	for path: String in REQUIRED_PACKAGE_RESOURCES:
		if path.ends_with(".gd") or path.ends_with(".json") or path.ends_with(".tres"):
			closure += FileAccess.get_file_as_string(path).to_lower() + "\n"
	for token: String in ["res://" + "discovery/", "res://" + "evidence/", "http" + "://", "https" + "://", "file" + "://", "/" + "volumes/", "/" + "users/", "source_assets"]:
		_require(token not in closure, "Executable Chapel closure contains forbidden token %s." % token)
	var builder := FileAccess.get_file_as_string(BUILDER_PATH)
	_require(builder.count(ADAPTER_PATH) == 1 and builder.count("NAVY_CHAPEL_187_LIVE_REPLACEMENT.claims_record(record)") == 1, "Builder does not expose exactly one Chapel adapter dispatch.")
	var preset := FileAccess.get_file_as_string("res://export_presets.cfg")
	for boundary: String in ["discovery/*", "discovery/**/*", "evidence/*", "evidence/**/*"]:
		_require(boundary in preset, "Export preset lost private boundary %s." % boundary)


func _registry_topology_scope_matches() -> bool:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	if not (parsed is Dictionary):
		return false
	var adapters := ((parsed as Dictionary).get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == WALL_KEY)
	if adapters.size() != 1:
		return false
	var behavior := ((adapters[0] as Dictionary).get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary
	var geometry := behavior.get("geometry_contract", {}) as Dictionary
	return str(geometry.get("world_topology_scope", "")) == "pre_b201_integration_live_parity" \
		and int(geometry.get("world_records", -1)) == 735 and int(geometry.get("world_mesh_instances", -1)) == 944 \
		and int(geometry.get("world_surfaces", -1)) == 957 and int(geometry.get("world_triangles", -1)) == 64572 \
		and int(geometry.get("world_static_bodies", -1)) == 466 and int(geometry.get("world_shapes", -1)) == 466


func _pair_matches(wall: Node, roof: Node) -> bool:
	var wall_body := wall.get_node_or_null("Collision") as StaticBody3D
	var roof_body := roof.get_node_or_null("Collision") as StaticBody3D
	var wall_shape := wall.get_node_or_null("Collision/Shape") as CollisionShape3D
	var roof_shape := roof.get_node_or_null("Collision/Shape") as CollisionShape3D
	var metadata := wall.get_meta("navy_chapel_187_live_replacement", {}) as Dictionary
	return wall.name == "NavyChapel187LiveWallVisualAndCollisionReplacement" \
		and roof.name == "NavyChapel187LiveRoofCollisionReplacement" \
		and wall.find_children("*", "MeshInstance3D", true, false).size() == 6 \
		and roof.find_children("*", "MeshInstance3D", true, false).is_empty() \
		and wall_body != null and roof_body != null and wall_shape != null and roof_shape != null \
		and wall_shape.shape is ConcavePolygonShape3D and roof_shape.shape is ConcavePolygonShape3D \
		and (wall_shape.shape as ConcavePolygonShape3D).get_faces().size() == 282 \
		and (roof_shape.shape as ConcavePolygonShape3D).get_faces().size() == 150 \
		and wall_body.is_in_group("spray_receiver_wall") and not roof_body.is_in_group("spray_receiver_wall") \
		and str(wall_body.get_meta("receiver_kind", "")) == "building_wall" \
		and str(roof_body.get_meta("receiver_kind", "invalid")) == "none" \
		and str(metadata.get("geometry_signature", "")) == ADAPTER.EXPECTED_GEOMETRY_SIGNATURE \
		and str(metadata.get("live_ownership_signature", "")) == ADAPTER.EXPECTED_LIVE_OWNERSHIP_SIGNATURE \
		and ADAPTER.material_semantics_match(wall as Node3D) \
		and not bool(metadata.get("recognition_accepted", true)) \
		and not bool(metadata.get("fallback_allowed", true)) and not bool(metadata.get("stack_allowed", true))


func _world_matches() -> Dictionary:
	var packed := load("res://game/scenes/world/world_root.tscn") as PackedScene
	if packed == null:
		return {"ok": false, "message": "WorldRoot did not load."}
	var world := packed.instantiate() as WorldLoader
	var reports: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()}))
	root.add_child(world)
	world.load_world(MANIFEST_PATH)
	var started := Time.get_ticks_msec()
	while reports.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 45000:
		await process_frame
	var e := world.get_runtime_evidence()
	var actual := {"rows": e.playable_rows, "meshes": e.mesh_instances, "surfaces": e.surfaces, "triangles": e.triangles, "bodies": e.static_bodies, "shapes": e.shapes}
	var walls := _nodes_for_key(world, WALL_KEY)
	var roofs := _nodes_for_key(world, ROOF_KEY)
	var ok := failures.is_empty() and reports.size() == 1 and actual == EXPECTED_TOPOLOGY and walls.size() == 1 and roofs.size() == 1 and _pair_matches(walls[0], roofs[0])
	var message := "Chapel package world drift: failures=%s reports=%d nodes=%d/%d topology=%s" % [failures, reports.size(), walls.size(), roofs.size(), actual]
	root.remove_child(world)
	world.free()
	return {"ok": ok, "message": message}


func _nodes_for_key(root_node: Node, key: String) -> Array[Node]:
	var result: Array[Node] = []
	for node: Node in root_node.find_children("*", "Node3D", true, false):
		if node.has_meta("feature_kind") and str(node.get_meta("derived_object_key", "")) == key:
			result.append(node)
	return result


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("NAVY_CHAPEL_187_PACKAGE_FAIL: %s" % message)
	return false


func _finish(mounted: bool) -> void:
	if not _failed:
		print("PASS: %s Navy Chapel live wall+roof replacement resolves approved 6/6/540 visuals, split 94/50 collision ownership, no generic stack/fallback, and no private source/evidence payload" % ("mounted" if mounted else "source"))
	quit(1 if _failed else 0)
