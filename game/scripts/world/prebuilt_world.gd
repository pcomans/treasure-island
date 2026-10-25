extends RefCounted
## Transient web build product. Native play continues to use WorldLoader's generator.
const PATH := "res://generated/web/static_world.scn"
const SCHEMA := "ti.web-static-world/1"
const EVIDENCE_FIELDS := ["chunks_expected", "chunks_loaded", "playable_rows", "context_rows", "mesh_instances", "surfaces", "triangles", "static_bodies", "shapes", "vegetation_seed", "vegetation_instances", "vegetation_assets", "vegetation_multimesh_batches", "vegetation_rendered_triangles", "vegetation_species_counts", "vegetation_zone_counts"]

static func pack_world(world: Node) -> PackedScene:
	var static_root := Node3D.new()
	static_root.name = "StaticWorld"
	var evidence: Node = world.get_runtime_evidence()
	var values := {}
	for field: String in EVIDENCE_FIELDS:
		values[field] = evidence.get(field)
	static_root.set_meta("schema", SCHEMA)
	static_root.set_meta("spawn", world.get_spawn_transform())
	static_root.set_meta("boundary", world.get_boundary().get_boundary_data())
	static_root.set_meta("evidence", values)
	static_root.set_meta("report", {"content_sha256": evidence.manifest_hash, "chunks": evidence.chunks_loaded, "playable_rows": evidence.playable_rows, "context_rows": evidence.context_rows})
	for name: String in ["PlayableWorld", "ContextWorld"]:
		var child := world.get_node(name)
		child.reparent(static_root, false)
		_own_descendants(child, static_root)
	var packed := PackedScene.new()
	var error := packed.pack(static_root)
	# Return the original tree to its loader for same-run source/reload comparisons.
	for child: Node in static_root.get_children():
		_clear_owners(child)
		child.reparent(world, false)
	static_root.free()
	if error != OK:
		push_error("Could not pack static world: %s" % error_string(error))
		return null
	return packed

static func _own_descendants(node: Node, owner_root: Node) -> void:
	node.owner = owner_root
	# Flatten imported scene instances: all actual descendants are serialized below.
	node.scene_file_path = ""
	for group: StringName in node.get_groups():
		if not str(group).begins_with("_"):
			node.remove_from_group(group)
			node.add_to_group(group, true)
	for child: Node in node.get_children():
		_own_descendants(child, owner_root)

static func _clear_owners(node: Node) -> void:
	node.owner = null
	for child: Node in node.get_children():
		_clear_owners(child)
