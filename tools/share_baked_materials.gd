extends RefCounted
## The static-world bake's last step (tools/prebuild_static_world.gd): every node, mesh
## surface and next pass in the baked world whose material equals another's points to
## one of them, so the renderer keeps one material (one uniform buffer on the web) where
## it kept several. Nothing else changes: no mesh, value or node, only which of the equal
## materials each points to.
##
## Equal (key()): the merge's equality (MergeBakedBuildings.value_key: one class and
## every stored value the same, numbers by their bytes, resources by identity, metadata
## alike, a shader material's parameters as it reads them), with these added:
## - the name and the local-to-scene flag: run-time code finds materials by name
##   (street_furniture_breaker.gd's lit lenses, ground_dressing.gd's yards and ground
##   families);
## - the same run-time walkers (WALKERS) find it: code that in play writes the
##   materials it finds by walking the world writes a shared material for everything
##   drawing it, so a material is shared only with ones the same walkers find, and their
##   writes reach what they reached;
## - the same next pass: next passes are shared first, so two materials whose next
##   passes were equal copies become equal too.
## A material with a script is never shared.
##
## A material saved in a file of its own keeps its identity, since code may load it by
## its path: the copies equal to it point to it, and two such files are never merged.
## What a resource saved in a file of its own holds (an imported mesh's materials) stays
## as it is: the baked world only refers to that file.
##
## The run-time code that writes one node's material (a felled lamp's lenses, a driven
## car's lamps) writes a copy it makes first. game/tests/headless_material_sharing_contract.gd
## classifies every run-time writer of materials.

const MERGE_BUILDINGS := preload("res://tools/merge_baked_buildings.gd")
const GROUND_DRESSING := preload("res://game/scripts/world/ground_dressing.gd")
## Left out of equality: where a material was loaded from, and its id there.
const IGNORED := ["resource_path", "resource_scene_unique_id"]
## The run-time walkers: code that in play writes the baked world's materials it finds by
## walking the world. DaySun.collect_fills (main.gd) scales the daylight fills' emission
## by the time of day; the ground dressing (desktop) paints its ground cover's lawn
## threads (GroundDressing._set_lawn_threads).
const DAYLIGHT_FILLS := "daylight fills"
const LAWN_THREADS := "lawn threads"
const WALKERS: Array[String] = [DAYLIGHT_FILLS, LAWN_THREADS]


## What `walker` (one of WALKERS) writes in play, found in world (a WorldLoader, or
## anything with its buildings, ground_and_areas and roads_and_paths).
static func walked(walker: String, world: Node) -> Array:
	match walker:
		DAYLIGHT_FILLS:
			return DaySun.building_glows(world.get("buildings"))[DaySun.DAYLIGHT_FILL]
		LAWN_THREADS:
			return GROUND_DRESSING.lawn_materials(world)
	push_error("No walker named " + walker)
	return []


## WALKERS for share(), in world.
static func world_walkers(world: Node) -> Dictionary:
	var walkers := {}
	for walker: String in WALKERS:
		walkers[walker] = func() -> Array: return walked(walker, world)
	return walkers


## Shares equal materials under roots (each of them and their descendants). walkers:
## name -> Callable returning the materials that walker writes in play. Returns the
## counts and "problems" (empty when every check holds): after it every node and mesh
## surface that pointed to a material points to one equal to it, as does every next
## pass, each walker's materials are pointed to from the same places as before, and no
## two distinct materials it may share are equal.
static func share(roots: Array[Node], walkers: Dictionary) -> Dictionary:
	var before := _references(roots)
	var reached := _reached(walkers)
	var signatures := _signatures(reached)
	var counts := {"materials_before": before.materials.size(), "kinds_before": _kinds(before.materials), "kept_in_files": 0,
		"kept_scripted": 0, "files_alike": 0, "shared_groups": 0, "references_moved": 0, "next_passes_moved": 0}
	var value_keys := {}
	var passes := {}
	for material: Material in before.materials:
		value_keys[material] = MERGE_BUILDINGS.value_key(material, IGNORED)
		if material.next_pass != null:
			passes[material] = material.next_pass
	# Materials in depth order (next passes first): a next pass is shared before the
	# materials pointing to it are compared, and materials of different depths are never
	# equal (their next passes differ).
	var depths := {}
	var by_depth := {}
	for material: Material in before.materials:
		var depth := _depth(material, depths)
		if not by_depth.has(depth):
			by_depth[depth] = []
		(by_depth[depth] as Array).append(material)
	var depth_list := by_depth.keys()
	depth_list.sort()
	var shared_to := {}
	for depth: int in depth_list:
		var groups := {}
		for material: Material in by_depth[depth]:
			if material.next_pass != null and not _kept(material, before.in_files):
				var pass_to: Material = shared_to[material.next_pass]
				if pass_to != material.next_pass:
					material.next_pass = pass_to
					counts.next_passes_moved += 1
					value_keys[material] = MERGE_BUILDINGS.value_key(material, IGNORED)
			var key := _key(material, value_keys[material], signatures)
			if key == "" or before.in_files.has(material):
				counts.kept_scripted += 1 if key == "" else 0
				counts.kept_in_files += 0 if key == "" else 1
				shared_to[material] = material
				continue
			if not groups.has(key):
				groups[key] = []
			(groups[key] as Array).append(material)
		for key: String in groups:
			var members: Array = groups[key]
			# A material of a file of its own keeps itself and takes its copies; otherwise
			# the first found takes the rest.
			var to: Material = members[0]
			for member: Material in members:
				if _own_file(member):
					to = member
					break
			for member: Material in members:
				if _own_file(member):
					shared_to[member] = member
					counts.files_alike += 1 if member != to else 0
				else:
					shared_to[member] = to
			if members.size() > 1:
				counts.shared_groups += 1
	for reference: Array in before.references:
		var to: Material = shared_to[reference[4]]
		if to != reference[4] and not reference[3]:
			_point(reference, to)
			counts.references_moved += 1
	var after := _references(roots)
	counts.materials_after = after.materials.size()
	counts.kinds_after = _kinds(after.materials)
	counts.walkers = {}
	for walker: String in reached:
		counts.walkers[walker] = (reached[walker] as Dictionary).size()
	counts.apart_by_name = _apart_by(after.materials, signatures, ["resource_name"])
	counts.problems = _check(before, after, value_keys, passes, reached, walkers)
	return counts


## A material's sharing key: "" for one never shared (one with a script), otherwise its
## value key and the walkers that find it.
static func _key(material: Material, value_key: String, signatures: Dictionary) -> String:
	if material.get_script() != null:
		return ""
	return value_key + "|walkers " + str(signatures.get(material, ""))


## Every reference to a material from a node or a mesh surface under roots, as [holder,
## property or surface index, "node" or "mesh" (a mesh's surface) or "resource" (a
## PrimitiveMesh's material), whether a file of its own holds it, the material]; the
## materials these and their next passes point to, in the order found; and those a
## file of its own holds (as keys).
static func _references(roots: Array[Node]) -> Dictionary:
	var found := {"references": [], "materials": [], "in_files": {}, "seen": {}}
	for root: Node in roots:
		var nodes: Array[Node] = [root]
		nodes.append_array(root.find_children("*", "", true, false))
		for node: Node in nodes:
			for property: Dictionary in node.get_property_list():
				if int(property.type) != TYPE_OBJECT or int(property.usage) & PROPERTY_USAGE_STORAGE == 0:
					continue
				var value: Variant = node.get(property.name)
				if value is Material:
					_reference(found, [node, property.name, "node", false, value])
				elif value is Mesh:
					_mesh(found, value as Mesh)
				elif value is MultiMesh and (value as MultiMesh).mesh != null:
					_mesh(found, (value as MultiMesh).mesh)
	found.erase("seen")
	return found


static func _mesh(found: Dictionary, mesh: Mesh) -> void:
	if (found.seen as Dictionary).has(mesh):
		return
	found.seen[mesh] = true
	var in_file := _own_file(mesh)
	if mesh is PrimitiveMesh:
		if (mesh as PrimitiveMesh).material != null:
			_reference(found, [mesh, "material", "resource", in_file, (mesh as PrimitiveMesh).material])
		return
	for surface in mesh.get_surface_count():
		var material := mesh.surface_get_material(surface)
		if material != null:
			# Only an ArrayMesh's surfaces are set again; another kind keeps its own.
			_reference(found, [mesh, surface, "mesh", in_file or not mesh is ArrayMesh, material])


static func _reference(found: Dictionary, reference: Array) -> void:
	(found.references as Array).append(reference)
	_material(found, reference[4], reference[3])


## A material found, and its next passes; in_file: held by a file of its own.
static func _material(found: Dictionary, material: Material, in_file: bool) -> void:
	if in_file:
		found.in_files[material] = true
	if (found.seen as Dictionary).has(material):
		return
	found.seen[material] = true
	(found.materials as Array).append(material)
	if material.next_pass != null:
		_material(found, material.next_pass, in_file or _own_file(material))


static func _point(reference: Array, material: Material) -> void:
	if reference[2] == "mesh":
		(reference[0] as ArrayMesh).surface_set_material(int(reference[1]), material)
	else:
		(reference[0] as Object).set(reference[1], material)


## Whether a resource is saved in a file of its own (not inside a scene or another
## resource's file), which the baked world refers to by path.
static func _own_file(resource: Resource) -> bool:
	var path := resource.resource_path
	return path != "" and not path.contains("::") and not path.begins_with("local://")


## Whether a material keeps what it points to: one in a file of its own, or one a file
## of its own holds.
static func _kept(material: Material, in_files: Dictionary) -> bool:
	return _own_file(material) or in_files.has(material)


static func _depth(material: Material, depths: Dictionary) -> int:
	if not depths.has(material):
		depths[material] = 0 if material.next_pass == null else _depth(material.next_pass, depths) + 1
	return depths[material]


## Each walker's materials as keys: name -> {material: true}.
static func _reached(walkers: Dictionary) -> Dictionary:
	var reached := {}
	for walker: String in walkers:
		var materials := {}
		for material: Material in (walkers[walker] as Callable).call():
			materials[material] = true
		reached[walker] = materials
	return reached


## The walkers that find each material, as one text: material -> "name,name".
static func _signatures(reached: Dictionary) -> Dictionary:
	var names := reached.keys()
	names.sort()
	var signatures := {}
	for walker: String in names:
		for material: Material in reached[walker]:
			signatures[material] = (str(signatures.get(material, "")) + "," + walker).trim_prefix(",")
	return signatures


## What must hold after sharing: the same references, each pointing to a material equal
## to the one it pointed to, and every next pass equal to the one it was; each walker
## finds materials pointed to from the same places as before; and no two distinct
## materials that may be shared are equal.
static func _check(before: Dictionary, after: Dictionary, value_keys: Dictionary, passes: Dictionary, reached: Dictionary, walkers: Dictionary) -> PackedStringArray:
	var problems := PackedStringArray()
	if before.references.size() != after.references.size():
		problems.append("%d references before, %d after" % [before.references.size(), after.references.size()])
		return problems
	for index in before.references.size():
		var was: Array = before.references[index]
		var now: Array = after.references[index]
		if was[0] != now[0] or was[1] != now[1]:
			problems.append("reference %d moved: %s/%s, then %s/%s" % [index, was[0], was[1], now[0], now[1]])
			return problems
		if MERGE_BUILDINGS.value_key(now[4], IGNORED) != value_keys[was[4]]:
			problems.append("%s/%s points to %s, which differs from %s" % [now[0], now[1], now[4], was[4]])
	# A next pass that was moved compares with what its first one is now (its own next
	# pass moved too, if it had one).
	for material: Material in after.materials:
		if material.next_pass != null and (not passes.has(material) or MERGE_BUILDINGS.value_key(material.next_pass, IGNORED) != value_keys[passes[material]]):
			problems.append("%s's next pass %s differs from the one it had" % [material, material.next_pass])
	var reached_after := _reached(walkers)
	for walker: String in reached:
		var was_at := _places(before.references, reached[walker])
		var now_at := _places(after.references, reached_after[walker])
		if was_at != now_at:
			problems.append("walker %s finds materials pointed to from %d places, %d before" % [walker, now_at.size(), was_at.size()])
	var keys := {}
	var signatures := _signatures(reached_after)
	for material: Material in after.materials:
		if _kept(material, after.in_files):
			continue
		var key := _key(material, MERGE_BUILDINGS.value_key(material, IGNORED), signatures)
		if key == "":
			continue
		if keys.has(key):
			problems.append("%s and %s are equal and both kept" % [keys[key], material])
		keys[key] = material
	return problems


## Where the references to materials (as keys) are, as sorted texts.
static func _places(references: Array, materials: Dictionary) -> PackedStringArray:
	var places := PackedStringArray()
	for reference: Array in references:
		if materials.has(reference[4]):
			places.append("%d/%s" % [(reference[0] as Object).get_instance_id(), reference[1]])
	places.sort()
	return places


## Materials by class name: name -> count.
static func _kinds(materials: Array) -> Dictionary:
	var kinds := {}
	for material: Material in materials:
		kinds[material.get_class()] = int(kinds.get(material.get_class(), 0)) + 1
	return kinds


## How many more materials would be shared if `ignored` properties were left out of
## equality too (to say what the name keeps apart).
static func _apart_by(materials: Array, signatures: Dictionary, ignored: Array) -> int:
	var keys := {}
	var shareable := 0
	for material: Material in materials:
		if material.get_script() != null or _own_file(material):
			continue
		shareable += 1
		keys[MERGE_BUILDINGS.value_key(material, IGNORED + ignored) + "|walkers " + str(signatures.get(material, ""))] = true
	return shareable - keys.size()
