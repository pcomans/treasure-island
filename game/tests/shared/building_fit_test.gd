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
## Optional --native-producer chapel-indexed: complete live indexed wall/roof
## partition comparison before the ordinary fit, for the Chapel producer.
## Optional --native-producer building2-indexed: complete B2 material-bucket
## indexed triangles against actual wall/roof collision emission, order independent.
## Optional --native-producer housing-get-faces: complete live shared housing
## role partitions using the installer's Mesh.get_faces() producer.
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
		if flag not in ["--source", "--routes", "--spray", "--diagnose-side", "--adjacent-source", "--native-producer"] or seen.has(flag):
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
	var native_sources := {"chapel-indexed": "w291189336", "building2-indexed": "w24274434", "station48-indexed": "w764313741"}
	var housing_native := str(args.get("native-producer", "")) == "housing-get-faces"
	if args.has("native-producer") and ((not housing_native and str(native_sources.get(str(args["native-producer"]), "")) != source_key) or args.has("diagnose-side") or args.has("adjacent-source")):
		push_error("native producer requires its supported source and cannot combine diagnostic/adjacent modes")
		quit(1)
		return
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
	if args.has("native-producer"):
		var native_error := ""
		if housing_native:
			native_error = _check_housing_faces(h, source_key)
		elif str(args["native-producer"]) == "station48-indexed":
			native_error = _check_station48_indexed(h, source_key)
		elif str(args["native-producer"]) == "building2-indexed":
			native_error = _check_building2_indexed(h, source_key)
		else:
			native_error = _check_indexed_partition(h, source_key)
		if native_error != "":
			print("FAIL: native partition: " + native_error)
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


# Existing indexed producer contract: semantic roof/cross or first indexed
# normal.y above the producer cutoff belongs to the solid non-wall partition.
# No metadata face arrays or regenerated prototype supply expected geometry.
func _check_indexed_partition(h: WorldHarness, source: String) -> String:
	var keys := ["building:" + source + ":wall", "building:" + source + ":roof"]
	var roots: Array[Node3D] = []
	var bodies: Array[StaticBody3D] = []
	for key: String in keys:
		var matches: Array[StaticBody3D] = []
		for node: Node in h.main.find_children("*", "StaticBody3D", true, false):
			if source in node.get_meta("source_keys", []) and str(node.get_meta("derived_object_key", "")) not in keys:
				return "unsupported additional source native owner"
			if str(node.get_meta("derived_object_key", "")) == key:
				matches.append(node as StaticBody3D)
		if matches.size() != 1:
			return "missing or duplicate native partition owner: " + key
		var body := matches[0]
		var root := body.get_parent() as Node3D
		if root == null or str(root.get_meta("derived_object_key", "")) != key or root.get_meta("source_keys", []) != [source]:
			return "native partition producer identity differs"
		roots.append(root)
		bodies.append(body)
	var semantic_roles := {"QuietWallAndRearClosure": false, "InferredCreamSSEGableBelfryEntry": false,
		"NeutralRoofAndCap": true, "RibbedMetalCap": true, "ObservedPaleTrim": false, "ObservedCross": true,
		"WSWFlightDecor": true, "WSWFlightSupport": true,
		"OpaqueExteriorOpenings": false, "ObservedOpaquePanelAndDoor": false}
	for root: Node3D in roots:
		for visual: Node in root.find_children("*", "GeometryInstance3D", true, false):
			if not visual is MeshInstance3D:
				return "unsupported additional producer visual"
	var seen := {}
	var partitions: Array[PackedVector3Array] = [PackedVector3Array(), PackedVector3Array()]
	var poses: Array[Transform3D] = []
	for mesh_node: Node in roots[0].find_children("*", "MeshInstance3D", true, false):
		var mesh := mesh_node as MeshInstance3D
		var name_key := str(mesh.name)
		var flight_support := name_key == "WSWFlightSupport"
		var flight_decor := name_key == "WSWFlightDecor"
		if mesh.get_parent() != roots[0] or not semantic_roles.has(name_key) or seen.has(name_key) or not mesh.mesh is ArrayMesh or mesh.is_visible_in_tree() == flight_support:
			return "unsupported, hidden or duplicate indexed producer mesh"
		if (flight_support or flight_decor) and mesh.get_meta("chapel_flight_role", "") != ("support" if flight_support else "decor"):
			return "flight producer role differs"
		seen[name_key] = true
		var semantic_roof: bool = semantic_roles[name_key]
		# This producer copies raw bucket positions/normals, without baking a
		# per-mesh pose. Reject local edits outside that supported contract.
		if mesh.transform != Transform3D.IDENTITY:
			return "indexed producer requires identity local mesh transform"
		if mesh.layers != (1 if semantic_roof else 2) or mesh.is_set_as_top_level():
			return "indexed semantic render layer or ancestry differs"
		var mesh_world := roots[0].global_transform * mesh.transform
		if not mesh_world.is_finite() or not mesh.global_transform.is_finite() or not mesh_world.is_equal_approx(mesh.global_transform):
			return "indexed mesh world placement differs"
		# Both native holders use the same producer coordinate space. Bind it
		# to actual live body placement before exact local-face comparison.
		for body: StaticBody3D in bodies:
			if not body.global_transform.is_finite() or not body.global_transform.is_equal_approx(roots[0].global_transform):
				return "indexed native body differs from producer world space"
		var one := StudyGeometry.collect(mesh.mesh, [mesh.transform], StudyGeometry.INDEXED_ARRAYS)
		if not one.ok:
			return "indexed collection failed: " + str(one.errors)
		poses.append(mesh.transform)
		var cursor := 0
		for surface in mesh.mesh.get_surface_count():
			var arrays := mesh.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			if not arrays[Mesh.ARRAY_NORMAL] is PackedVector3Array or arrays[Mesh.ARRAY_NORMAL].size() != vertices.size():
				return "missing complete indexed normals"
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			for offset in range(0, indices.size(), 3):
				var normal := normals[indices[offset]]
				if not normal.is_finite() or normal.length_squared() == 0.0:
					return "invalid indexed producer normal"
				if flight_support and normal.dot(Vector3.UP) < cos(deg_to_rad(48.0)):
					return "flight support is not a walkable upward face"
				var partition := 1 if semantic_roof or absf(normal.y) > 0.65 else 0
				for corner in range(3):
					if not flight_decor:
						partitions[partition].append(one.faces[cursor + corner])
				cursor += 3
		if cursor != one.faces.size():
			return "incomplete indexed partition traversal"
	for name_key: String in semantic_roles:
		if not seen.has(name_key):
			return "missing producer semantic mesh: " + name_key
	if not roots[1].find_children("*", "MeshInstance3D", true, false).is_empty():
		return "unexpected duplicate roof visuals"
	for partition in range(2):
		var body := bodies[partition]
		var wall := partition == 0
		var receiver := "building_wall" if wall else "none"
		var ownership := "wall_like" if wall else "roof_cap_cross_landing"
		var world: Variant = PhysicsServer3D.body_get_state(body.get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM)
		if not world is Transform3D or not world.is_finite() or not world.is_equal_approx(body.global_transform):
			return "native server/node world placement differs"
		if body.collision_layer != 5 or body.collision_mask != 0 or body.is_in_group("spray_receiver_wall") != wall:
			return "native partition collision/spray layer differs"
		var owners := body.get_shape_owners()
		if owners.size() != 1 or body.is_shape_owner_disabled(owners[0]) or body.shape_owner_get_shape_count(owners[0]) != 1:
			return "ambiguous native partition holder"
		var holder := body.shape_owner_get_owner(owners[0]) as CollisionShape3D
		if holder == null or holder.get_parent() != body or holder.transform != Transform3D.IDENTITY or not holder.shape is ConcavePolygonShape3D:
			return "unsupported native partition holder"
		for object: Object in [body, holder.shape]:
			if object.get_meta("source_keys", []) != [source] or str(object.get_meta("derived_object_key", "")) != keys[partition] or str(object.get_meta("receiver_kind", "")) != receiver or object.get_meta("opaque", false) != true or str(object.get_meta("ownership_partition", "")) != ownership:
				return "native partition source/receiver ownership differs"
		var shape_index := body.shape_owner_get_shape_index(owners[0], 0)
		if PhysicsServer3D.body_get_shape(body.get_rid(), shape_index) != holder.shape.get_rid() or PhysicsServer3D.body_get_shape_transform(body.get_rid(), shape_index) != holder.transform:
			return "native server shape RID/transform differs"
		var faces := partitions[partition]
		var collection := {"ok": not faces.is_empty(), "faces": faces, "local_faces": faces, "transforms": poses,
			"producer": StudyGeometry.INDEXED_ARRAYS, "errors": [], "minimum_cross_length_squared": -1.0}
		var result := StudyGeometry.compare(collection, (holder.shape as ConcavePolygonShape3D).get_faces(), faces.size())
		print("NATIVE_PARTITION key=%s predicates=%s server_owner=true" % [keys[partition], result.predicates])
		if not result.ok:
			return "complete ordered native partition faces differ"
	print("PASS: complete indexed native wall/roof partitions for " + source)
	return ""


# B2 shares every emitted triangle between a material bucket and one collision
# bucket. Material grouping changes triangle order, but not oriented triangles.
func _check_building2_indexed(h: WorldHarness, source: String) -> String:
	var roles := {
		"wall": ["Building2Cream", "Building2SSEInfill", "Building2FieldGlass", "Building2FieldGlassBand", "Building2FieldGrid", "Building2EntryPanel", "Building2ReliefProxy", "Building2Doors", "Building2EntryGlass", "Building2EntryFrames", "Building2PylonInsets", "Building2Vents", "Building2WingGlass", "Building2WingMullions"],
		"roof": ["Building2BarrelRoof", "Building2WingRoof"],
	}
	var keys := ["building:" + source + ":wall", "building:" + source + ":roof"]
	for node: Node in h.main.find_children("*", "StaticBody3D", true, false):
		if source in node.get_meta("source_keys", []) and str(node.get_meta("derived_object_key", "")) not in keys:
			return "additional B2 native source owner"
	for role: String in roles:
		var key := "building:" + source + ":" + role
		var wall := role == "wall"
		var matches: Array[StaticBody3D] = []
		for node: Node in h.main.find_children("*", "StaticBody3D", true, false):
			if str(node.get_meta("derived_object_key", "")) == key:
				matches.append(node as StaticBody3D)
		if matches.size() != 1:
			return "missing or duplicate B2 native owner: " + key
		var body := matches[0]
		var root := body.get_parent() as Node3D
		if root == null or root.get_meta("derived_object_key", "") != key or root.get_meta("source_keys", []) != [source] or root.get_meta("building_2_hero_component", "") != "building_" + role:
			return "B2 producer identity differs"
		if body.transform != Transform3D.IDENTITY or body.is_set_as_top_level() or not root.global_transform.is_finite() or not body.global_transform.is_equal_approx(root.global_transform):
			return "B2 native producer placement differs"
		var server_pose: Variant = PhysicsServer3D.body_get_state(body.get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM)
		if not server_pose is Transform3D or not server_pose.is_finite() or not server_pose.is_equal_approx(body.global_transform):
			return "B2 server placement differs"
		if body.collision_layer != (5 if wall else 1) or body.collision_mask != 0 or body.is_in_group("spray_receiver_wall") != wall:
			return "B2 native collision/spray layer differs"
		var owners := body.get_shape_owners()
		if owners.size() != 1 or body.is_shape_owner_disabled(owners[0]) or body.shape_owner_get_shape_count(owners[0]) != 1:
			return "B2 native shape ownership ambiguous"
		var holder := body.shape_owner_get_owner(owners[0]) as CollisionShape3D
		if holder == null or holder.get_parent() != body or holder.transform != Transform3D.IDENTITY or not holder.shape is ConcavePolygonShape3D:
			return "unsupported B2 native shape"
		for object: Object in [body, holder.shape]:
			if object.get_meta("source_keys", []) != [source] or object.get_meta("derived_object_key", "") != key or object.get_meta("receiver_kind", "") != ("building_wall" if wall else "none") or object.get_meta("opaque", false) != true or object.get_meta("building_2_hero", false) != true:
				return "B2 native source/receiver identity differs"
		var shape_index := body.shape_owner_get_shape_index(owners[0], 0)
		if PhysicsServer3D.body_get_shape(body.get_rid(), shape_index) != holder.shape.get_rid() or PhysicsServer3D.body_get_shape_transform(body.get_rid(), shape_index) != holder.transform:
			return "B2 server shape RID/transform differs"
		var seen := {}
		var faces := PackedVector3Array()
		for visual: Node in root.find_children("*", "GeometryInstance3D", true, false):
			if not visual is MeshInstance3D:
				return "unsupported B2 producer visual"
			var mesh := visual as MeshInstance3D
			var mesh_name := str(mesh.name)
			if mesh.get_parent() != root or mesh_name not in roles[role] or seen.has(mesh_name) or not mesh.is_visible_in_tree() or not mesh.mesh is ArrayMesh:
				return "unknown, hidden or duplicate B2 material bucket"
			if mesh.transform != Transform3D.IDENTITY or mesh.is_set_as_top_level() or mesh.layers != (2 if wall else 1) or not mesh.global_transform.is_equal_approx(root.global_transform):
				return "B2 visual placement/layer differs"
			var one := StudyGeometry.collect(mesh.mesh, [mesh.transform], StudyGeometry.INDEXED_ARRAYS)
			if not one.ok:
				return "B2 indexed collection failed: " + str(one.errors)
			seen[mesh_name] = true
			faces.append_array(one.faces)
		for mesh_name: String in roles[role]:
			if not seen.has(mesh_name):
				return "missing positive B2 material bucket: " + mesh_name
		var result := StudyGeometry.compare_triangle_multiset(faces, (holder.shape as ConcavePolygonShape3D).get_faces())
		print("B2_NATIVE key=%s predicates=%s server_owner=true" % [key, result.predicates])
		if not result.ok:
			return "complete B2 indexed/native triangles differ"
	print("PASS: complete B2 indexed wall/roof native geometry for " + source)
	return ""


# Shared housing installs every immediate mesh in a source-owned role bucket,
# translating its world-space faces into the body's local origin in that order.
func _check_housing_faces(h: WorldHarness, source: String) -> String:
	var roots: Array[Node3D] = []
	for node: Node in h.main.find_children("SharedHousing_*", "Node3D", true, false):
		if node.get_meta("source_key", "") == source:
			roots.append(node as Node3D)
	if roots.size() != 1:
		return "missing or duplicate shared housing producer"
	var root := roots[0]
	if root.global_transform != Transform3D.IDENTITY or not root.get_meta("build_valid", false) or root.get_meta("scope", "") != "approved_shared_family_normal_play":
		return "unsupported housing producer placement or identity"
	var meshes := {"wall": [], "roof": [], "support": [], "ground": []}
	var bodies := {}
	for node: Node in root.get_children():
		if node is MeshInstance3D:
			var role := str(node.get_meta("family_role", "support"))
			if not meshes.has(role) or not node.is_visible_in_tree() or node.is_set_as_top_level() or not node.transform.is_finite() or node.layers != (2 if role == "wall" else 1):
				return "unsupported housing visible role/placement/layer"
			meshes[role].append(node)
		elif node is StaticBody3D:
			var role := str(node.get_meta("family_role", ""))
			if not meshes.has(role) or bodies.has(role):
				return "unknown or duplicate housing contact role"
			bodies[role] = node
		else:
			return "unsupported housing producer child"
	for node: Node in h.main.find_children("*", "StaticBody3D", true, false):
		if source in node.get_meta("source_keys", []) and node.collision_layer != 0 and node.get_parent() != root:
			return "additional active housing source body"
	for role: String in meshes:
		if meshes[role].is_empty():
			if role in ["wall", "roof"] or bodies.has(role):
				return "missing positive housing role coverage"
			continue
		if not bodies.has(role):
			return "missing housing native role"
		var body: StaticBody3D = bodies[role]
		var wall := role == "wall"
		var key := "building:" + source + (":roof" if role == "roof" else ":wall")
		if body.get_meta("source_keys", []) != [source] or body.get_meta("derived_object_key", "") != key or body.get_meta("receiver_kind", "") != ("building_wall" if wall else "none") or bool(body.get_meta("opaque", false)) != wall:
			return "housing source/receiver identity differs"
		if body.is_set_as_top_level() or body.basis != Basis.IDENTITY or not body.position.is_finite() or body.collision_layer != (5 if wall else 1) or body.collision_mask != 0 or body.is_in_group("spray_receiver_wall") != wall:
			return "housing body placement/layer differs"
		var owners := body.get_shape_owners()
		if owners.size() != 1 or body.is_shape_owner_disabled(owners[0]) or body.shape_owner_get_shape_count(owners[0]) != 1:
			return "ambiguous housing shape owner"
		var holder := body.shape_owner_get_owner(owners[0]) as CollisionShape3D
		if holder == null or holder.get_parent() != body or holder.transform != Transform3D.IDENTITY or not holder.shape is ConcavePolygonShape3D or not holder.shape.backface_collision:
			return "unsupported housing native shape"
		var shape_index := body.shape_owner_get_shape_index(owners[0], 0)
		var server_pose: Variant = PhysicsServer3D.body_get_state(body.get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM)
		if not server_pose is Transform3D or not server_pose.is_equal_approx(body.global_transform) or PhysicsServer3D.body_get_shape(body.get_rid(), shape_index) != holder.shape.get_rid() or PhysicsServer3D.body_get_shape_transform(body.get_rid(), shape_index) != holder.transform:
			return "housing native server ownership/placement differs"
		var faces := PackedVector3Array()
		var roof_up := 0
		var roof_down := 0
		for mesh: MeshInstance3D in meshes[role]:
			var one := StudyGeometry.collect(mesh.mesh, [mesh.transform], StudyGeometry.MESH_GET_FACES)
			if not one.ok:
				return "housing get_faces collection failed: " + str(one.errors)
			# The installer first stores transformed vertices in a packed array,
			# then subtracts the body origin in a second packed-array pass.
			for vertex: Vector3 in one.faces:
				faces.append(vertex - body.position)
			if role == "roof":
				for i in range(0, one.faces.size(), 3):
					var cross_y: float = (one.faces[i + 1] - one.faces[i]).cross(one.faces[i + 2] - one.faces[i]).y
					if cross_y < -0.000001: roof_up += 1
					elif cross_y > 0.000001: roof_down += 1
		var collection := {"ok": not faces.is_empty(), "faces": faces, "local_faces": faces, "transforms": [], "producer": StudyGeometry.MESH_GET_FACES, "errors": [], "minimum_cross_length_squared": -1.0}
		var result := StudyGeometry.compare(collection, holder.shape.get_faces(), faces.size())
		print("HOUSING_NATIVE source=%s role=%s predicates=%s server_owner=true clockwise_up=%d clockwise_down=%d" % [source, role, result.predicates, roof_up, roof_down])
		if not result.ok:
			return "complete housing visible/native ordered faces differ"
	print("PASS: complete housing get_faces native partitions for " + source)
	return ""


# Station48 partitions indexed visual buckets into six named contact roles.
# Public/protected wall subsets reorder source runs, so compare oriented multisets.
func _check_station48_indexed(h:WorldHarness,source:String) -> String:
	var groups:Dictionary={
		"ExactClosedSourceWalls":["ProtectedExactNeutralWallRuns","ObservedWSWNNWPaleWallFields"],
		"ExactSourceNeutralRoof":["ExactSourceNeutralRoof"],
		"RaisedMetalAccess":["RaisedMetalAccess"],"ClosedEntryDoor":["ClosedEntryDoor"],
		"EntrySurround":["EntrySurround"],"StationSign":["StationSign"]}
	var decor:Array[String]=["CompletePaleWindowSurrounds","OpaqueHighWindowGlass","ThinWindowMullions","ThinStraightPublicRoofEdge"]
	var roots:Dictionary={};var seen_meshes:Dictionary={};var seen_roles:Dictionary={}
	for node:Node in h.main.find_children("*","StaticBody3D",true,false):
		if source not in node.get_meta("source_keys",[]):continue
		var body:=node as StaticBody3D
		var key:=str(body.get_meta("derived_object_key",""))
		var wall:=key=="building:"+source+":wall"
		if not wall and key!="building:"+source+":roof":return "unexpected Station48 body source owner"
		if roots.has(key):return "duplicate Station48 body source owner"
		if body.get_meta("source_keys",[])!=[source] or str(body.get_meta("receiver_kind",""))!=("building_wall" if wall else "none") or body.get_meta("opaque",false)!=true:return "Station48 body source/receiver identity differs"
		var root:=body.get_parent() as Node3D
		if root==null or root.get_meta("source_keys",[])!=[source] or str(root.get_meta("derived_object_key",""))!=key:return "Station48 root identity differs"
		roots[key]=root
		if body.collision_layer!=5 or body.collision_mask!=0 or body.is_in_group("spray_receiver_wall")!=wall:return "Station48 collision layer/group differs"
		if body.transform!=Transform3D.IDENTITY or body.is_set_as_top_level():return "Station48 body local transform differs"
		var world:Variant=PhysicsServer3D.body_get_state(body.get_rid(),PhysicsServer3D.BODY_STATE_TRANSFORM)
		if not world is Transform3D or not world.is_finite() or not world.is_equal_approx(body.global_transform):return "Station48 native world placement differs"
		for owner in body.get_shape_owners():
			if body.is_shape_owner_disabled(owner) or body.shape_owner_get_shape_count(owner)!=1:return "Station48 shape owner is disabled or ambiguous"
			var holder:=body.shape_owner_get_owner(owner) as CollisionShape3D
			if holder==null or holder.get_parent()!=body or holder.transform!=Transform3D.IDENTITY or not holder.shape is ConcavePolygonShape3D:return "unsupported Station48 native holder"
			var role:=str(holder.name)
			if not groups.has(role) or seen_roles.has(role) or (role=="ExactSourceNeutralRoof")==wall:return "Station48 contact role partition differs"
			seen_roles[role]=true
			var receiver:="building_wall" if role=="ExactClosedSourceWalls" else "none"
			for object:Object in [holder,holder.shape]:
				if object.get_meta("source_keys",[])!=[source] or str(object.get_meta("derived_object_key",""))!=key or str(object.get_meta("receiver_kind",""))!=receiver or object.get_meta("opaque",false)!=true:return "Station48 shape source/receiver identity differs"
			var index:=body.shape_owner_get_shape_index(owner,0)
			if PhysicsServer3D.body_get_shape(body.get_rid(),index)!=holder.shape.get_rid() or PhysicsServer3D.body_get_shape_transform(body.get_rid(),index)!=holder.transform:return "Station48 native shape RID/pose differs"
			var faces:=PackedVector3Array()
			for label:String in groups[role]:
				var mesh:=root.get_node_or_null(label) as MeshInstance3D
				if mesh==null or not mesh.mesh is ArrayMesh or not mesh.is_visible_in_tree() or mesh.is_set_as_top_level() or mesh.transform!=Transform3D.IDENTITY or seen_meshes.has(label):return "Station48 indexed visual missing, hidden or transformed"
				if mesh.get_meta("source_keys",[])!=[source] or str(mesh.get_meta("derived_object_key",""))!=key or mesh.layers!=(2 if role=="ExactClosedSourceWalls" else 1):return "Station48 visual identity/layer differs"
				if not mesh.global_transform.is_equal_approx(body.global_transform):return "Station48 visual/body placement differs"
				seen_meshes[label]=true
				var collected:=StudyGeometry.collect(mesh.mesh,[mesh.transform],StudyGeometry.INDEXED_ARRAYS)
				if not collected.ok:return "Station48 indexed collection failed: "+str(collected.errors)
				faces.append_array(collected.faces)
			var compared:=StudyGeometry.compare_triangle_multiset(faces,holder.shape.get_faces())
			print("STATION48_NATIVE role=%s result=%s native_owner=true" % [role,compared])
			if not compared.ok:return "Station48 visible/native oriented faces differ"
	if roots.size()!=2 or seen_roles.size()!=groups.size():return "Station48 complete source/contact coverage missing"
	for root:Node3D in roots.values():
		for visual:Node in root.find_children("*","GeometryInstance3D",true,false):
			if visual is Label3D:
				if str(visual.name)!="Station48Lettering" or str(visual.text)!="SFFD STATION 48":return "unexpected Station48 lettering visual"
			elif visual is MeshInstance3D:
				if str(visual.name) not in decor and not seen_meshes.has(str(visual.name)):return "unmapped Station48 visual geometry"
			else:return "unsupported Station48 visual producer"
	print("PASS: Station48 complete indexed wall/roof/entry native geometry")
	return ""
