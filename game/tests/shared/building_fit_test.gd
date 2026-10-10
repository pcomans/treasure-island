extends SceneTree
## Checks that a building fits into the island and plays right, in the real loaded world.
##
##   tools/godot --path . --script game/tests/shared/building_fit_test.gd -- --source w291189336
##
## 1. Roof: wherever the building is visible from above, the player can stand on it
##    (collision is there, not just a picture of a roof).
## 2. Walls: wherever a wall is visible at chest height, it also blocks the player.
## 3. Grounded: visible walls reach down to the ground next to them (no floating building).
## 4. Walk-up: from each side the stock player walks up to the building, arrives
##    next to it (within 1.5 m), stays on the ground and never needs a fall
##    recovery. Ending up under the building (carport, arcade) is only noted;
##    walking through walls is check 2.
## 5. Stairs: each flight listed in the building's catalog entry as
##    "stairs": [{"bottom": [x, z], "top": [x, z]}] is walked up and back down.
## A check with nothing to sample fails: it would otherwise pass untested.
##
## Prints PASS or FAIL lines and exits non-zero on failure.
## Optional --routes FILE: {"source":"KEY", "routes":[{"name":"passage",
## "start_xz":[x,z], "end_xz":[x,z]}]}. Each route is walked in both directions.
## A route may require_adjacent_support:true with --adjacent-source; this observes
## active floor contact during traversal without changing settle/support rules.
## Optional route return_from_arrival:true returns from the reached pose (like
## stairs), requiring ordinary ground at initial settle and final return.
## Optional --spray FILE: {"source":"KEY", "player_xz":[x,z], "target_xyz":[x,y,z]}.
## Optional --adjacent-source KEY: complete recorded nonreceiver roof/support
## mesh-to-native coverage for a neighboring POI, before ordinary building checks.
## Requires the existing recorded contact_mesh_paths producer; no wall exemption.
## Optional --diagnose-side north|south|west|east: native candidate queries only,
## without placement/movement. Always reports whole-building HOLD and exits1.

const WorldHarness := preload("res://game/tests/shared/world_harness.gd")
const BuildingFit := preload("res://game/tests/shared/building_fit.gd")
const StudyGeometry := preload("res://game/tests/support/building_study_geometry.gd")
const Catalog := preload("res://game/tests/shared/catalog.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	# Validate exact option/value pairs before the permissive shared parser.
	# Consumed paths are values, even when their filenames resemble options.
	var raw_args := OS.get_cmdline_user_args()
	var seen := {}
	var index := 0
	while index < raw_args.size():
		var flag := raw_args[index]
		if flag not in ["--source", "--routes", "--spray", "--diagnose-side", "--adjacent-source"] or seen.has(flag):
			push_error("unsupported or duplicate option: " + flag)
			quit(1)
			return
		if index + 1 >= raw_args.size() or raw_args[index + 1].is_empty() or raw_args[index + 1].begins_with("--"):
			push_error("missing value for " + flag)
			quit(1)
			return
		seen[flag] = true
		index += 2
	var args := WorldHarness.user_args()
	if not args.has("source"):
		push_error("usage: -- --source KEY")
		quit(1)
		return
	var source_key := str(args.source)
	var adjacent_source := str(args.get("adjacent-source", ""))
	if args.has("adjacent-source") and (adjacent_source == "" or adjacent_source == source_key):
		push_error("adjacent source must be nonempty and distinct from the building")
		quit(1)
		return
	var diagnostic_side := str(args.get("diagnose-side", ""))
	if args.has("diagnose-side"):
		if diagnostic_side not in ["north", "south", "west", "east"] or args.has("routes") or args.has("spray") or args.has("adjacent-source"):
			push_error("--diagnose-side needs one cardinal side and cannot combine routes/spray/adjacent-source")
			quit(1)
			return
		print("DIAGNOSTIC ONLY: whole-building HOLD; no four-side, fit or acceptance credit")
	var routes: Array = []
	if args.has("routes"):
		var plan: Variant = JSON.parse_string(FileAccess.get_file_as_string(str(args.routes)))
		if not plan is Dictionary or plan.get("source", "") != source_key or not plan.get("routes") is Array or plan.routes.is_empty():
			push_error("routes need a nonempty route list bound to --source")
			quit(1)
			return
		routes = plan.routes
	var spray_case: Dictionary = {}
	if args.has("spray"):
		var plan: Variant = JSON.parse_string(FileAccess.get_file_as_string(str(args.spray)))
		if not plan is Dictionary or plan.get("source", "") != source_key:
			push_error("spray needs a source-bound plan")
			quit(1)
			return
		spray_case = plan
	var h := WorldHarness.new(self)
	var error := await h.load_world()
	if error != "":
		push_error(error)
		quit(1)
		return
	if diagnostic_side != "":
		var diagnostic_error := BuildingFit.new(h).diagnose_side(source_key, diagnostic_side)
		print("DIAGNOSTIC ONLY: " + ("candidate queries completed" if diagnostic_error == "" else diagnostic_error))
		print("HOLD: whole-building fit and four actual approaches were not tested")
		h.main.queue_free()
		quit(1)
		return
	if adjacent_source != "":
		var adjacent_error := _check_adjacent_geometry(h, adjacent_source)
		if adjacent_error != "":
			print("FAIL: adjacent geometry: " + adjacent_error)
			h.main.queue_free()
			quit(1)
			return
	var stairs: Array = Catalog.unit_for(source_key).get("stairs", [])
	var failures := await BuildingFit.new(h).check(source_key, true, "", stairs, routes, spray_case, adjacent_source)
	if failures.is_empty():
		print("PASS: building %s fits and plays" % source_key)
	else:
		for message in failures:
			print("FAIL: " + message)
	h.main.queue_free()
	quit(0 if failures.is_empty() else 1)


# Recorded-path producer adapter. No synthetic wall receiver or movement setup.
# Every nondecor mesh must appear in exactly one legitimate native role group.
func _check_adjacent_geometry(h: WorldHarness, source: String) -> String:
	var expected: Dictionary = {}
	var bodies: Array[StaticBody3D] = []
	for node: Node in h.main.find_children("*", "Node3D", true, false):
		if node.get_meta("source_keys", []) != [source]:
			continue
		if node is MeshInstance3D and str(node.get_meta("mersea_role", "")) != "decor":
			if str(node.get_meta("mersea_role", "")) not in ["roof", "support"]:
				return "unsupported adjacent mesh role: " + str(node.get_path())
			expected[node] = false
		if node is StaticBody3D:
			bodies.append(node)
	if expected.is_empty() or bodies.is_empty():
		return "missing positive adjacent mesh/native coverage: " + source
	var roles := {}
	for body: StaticBody3D in bodies:
		var role := str(body.get_meta("mersea_role", ""))
		var key := str(body.get_meta("derived_object_key", ""))
		if role not in ["roof", "support"] or roles.has(role) or key != "site:" + source:
			return "ambiguous adjacent native role/identity: " + str(body.get_path())
		roles[role] = true
		var server_world: Variant = PhysicsServer3D.body_get_state(body.get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM)
		if not server_world is Transform3D or not server_world.is_finite() or not body.global_transform.is_finite() or not server_world.is_equal_approx(body.global_transform):
			return "adjacent server body world transform differs from its node"
		if body.collision_layer != WorldHarness.WORLD_SOLID_MASK or body.collision_mask != 0 or body.is_in_group("spray_receiver_wall") or str(body.get_meta("receiver_kind", "")) != "none":
			return "adjacent native role/layer mismatch: " + str(body.get_path())
		var owners := body.get_shape_owners()
		if owners.size() != 1 or body.is_shape_owner_disabled(owners[0]) or body.shape_owner_get_shape_count(owners[0]) != 1:
			return "ambiguous or disabled adjacent shape owner"
		var holder := body.shape_owner_get_owner(owners[0]) as CollisionShape3D
		if holder == null or not holder.shape is ConcavePolygonShape3D or holder.transform != Transform3D.IDENTITY:
			return "unsupported adjacent native shape/transform"
		for object: Object in [holder, holder.shape]:
			if object.get_meta("source_keys", []) != [source] or str(object.get_meta("derived_object_key", "")) != key or str(object.get_meta("mersea_role", "")) != role or str(object.get_meta("receiver_kind", "")) != "none":
				return "adjacent shape metadata mismatch"
		var paths: Variant = body.get_meta("contact_mesh_paths", null)
		if not paths is Array or paths.is_empty():
			return "missing recorded adjacent mesh paths"
		var faces := PackedVector3Array()
		var local_faces := PackedVector3Array()
		var transforms: Array[Transform3D] = []
		for path: Variant in paths:
			if not path is String or NodePath(path).is_absolute():
				return "invalid recorded relative mesh path"
			var mesh := body.get_parent().get_node_or_null(NodePath(path)) as MeshInstance3D
			if mesh == null or mesh.mesh == null or not expected.has(mesh) or expected[mesh] or str(mesh.get_meta("mersea_role", "")) != role or str(mesh.get_meta("derived_object_key", "")) != key or str(mesh.get_meta("receiver_kind", "")) != "none":
				return "missing, duplicate or wrong-role recorded mesh: " + str(path)
			if mesh.layers != 1:
				return "adjacent roof/support mesh render layer mismatch: " + str(path)
			if mesh.has_meta("native_contact_only"):
				var declared: Variant = mesh.get_meta("native_contact_only")
				var parent := mesh.get_parent() as Node3D
				if not declared is bool or declared != true or role != "support" or mesh.get_child_count() != 0 or mesh.visible or parent == null or not parent.is_visible_in_tree():
					return "invalid declared hidden leaf support proxy: " + str(path)
			elif not mesh.is_visible_in_tree():
				return "adjacent roof/support mesh is not visible: " + str(path)
			expected[mesh] = true
			# Match the actual producer: compose local ancestry to the assembly,
			# then move the vertices into the translated native body's space.
			if mesh.is_set_as_top_level():
				return "unsupported top-level recorded mesh"
			var chain: Array[Transform3D] = [mesh.transform]
			var ancestor := mesh.get_parent() as Node3D
			while ancestor != body.get_parent():
				if ancestor == null:
					return "recorded mesh is outside its native assembly"
				if ancestor.is_set_as_top_level():
					return "unsupported top-level recorded mesh ancestor"
				chain.push_front(ancestor.transform)
				ancestor = ancestor.get_parent() as Node3D
			var pose := Transform3D.IDENTITY
			for transform: Transform3D in chain:
				pose = pose * transform
			var assembly := body.get_parent() as Node3D
			if assembly == null:
				return "missing recorded producer assembly"
			var mesh_world := assembly.global_transform * pose
			if not mesh_world.is_finite() or not mesh.global_transform.is_finite() or not mesh_world.is_equal_approx(mesh.global_transform):
				return "recorded mesh ancestry differs from actual mesh world placement"
			var body_world := assembly.global_transform * body.transform
			if body.is_set_as_top_level() or body.basis != Basis.IDENTITY or not body_world.is_finite() or not body_world.is_equal_approx(body.global_transform):
				return "unsupported recorded producer body transform/ancestry"
			pose.origin -= body.position
			var one := StudyGeometry.collect(mesh.mesh, [pose], StudyGeometry.MESH_GET_FACES)
			if not one.ok:
				return "adjacent face collection failed: " + str(one.errors)
			faces.append_array(one.faces)
			local_faces.append_array(one.local_faces)
			transforms.append(pose)
		var collection := {"ok": not faces.is_empty(), "faces": faces, "local_faces": local_faces, "transforms": transforms,
			"producer": StudyGeometry.MESH_GET_FACES, "errors": [], "minimum_cross_length_squared": -1.0}
		var result := StudyGeometry.compare(collection, (holder.shape as ConcavePolygonShape3D).get_faces(), local_faces.size())
		var shape_index := body.shape_owner_get_shape_index(owners[0], 0)
		var server_shape := PhysicsServer3D.body_get_shape(body.get_rid(), shape_index)
		var native_ok := server_shape == holder.shape.get_rid() and PhysicsServer3D.body_get_shape_transform(body.get_rid(), shape_index) == holder.transform
		print("ADJACENT_GEOMETRY source=%s role=%s body=%s predicates=%s native_owner=%s" % [source, role, body.get_path(), result.predicates, native_ok])
		if not result.ok or not native_ok:
			print("ADJACENT_GEOMETRY_FAILURE " + JSON.stringify(result))
			return "adjacent complete visible/native faces or server ownership differ"
	for mesh: Node in expected:
		if not expected[mesh]:
			return "uncovered adjacent mesh: " + str(mesh.get_path())
	if not roles.has("roof") or not roles.has("support"):
		return "adjacent roof/support role coverage incomplete"
	print("PASS: adjacent %s complete recorded roof/support native geometry" % source)
	return ""
