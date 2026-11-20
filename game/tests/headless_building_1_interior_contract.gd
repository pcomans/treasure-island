extends SceneTree
## Building 1's hall (building_1_interior.gd), built from the real crescent the way
## the world builds it, behaves as its design says:
## - its shell is closed: rays from points all over the hall meet its collision, and
##   the only ones that leave go out through the open front door;
## - the front door's passage stays open to the player (nothing of the shell or the
##   hero's exterior collision stands in it) while its car blocker, on the cars' ground
##   layer only, spans it;
## - it draws on the interior render layer the Sun leaves out, with no shadows;
## - the hero's roof slabs stand nowhere over the hall's plan below its ceiling (the
##   closure test above meets only the hall's own shell and the hero's walls);
## - the mural's four tile surfaces start on a placeholder in materials that never
##   repeat their texture, and Building1MuralLoader loads the tiles near the door, one a
##   frame, and puts the placeholder back after a while far away, never while anyone is
##   in the hall (every point of the hall is within its load radius of the door); a
##   second build in the same process has its own placeholder and materials;
## - its floor reflections (Building1HallReflections) are there with a mode the node
##   knows (a config with any other fails the hall's plan), and carry the terrazzo
##   surface's own vertex attributes, byte for byte as the hall draws them, beside a
##   plain set of the same layout and size that differs from them (the baked sheen out).
## With -- --use-prebuilt-world it checks the reflections alone, in the island baked for
## desktop exports (tools/prebuild-static-world.sh native, which tools/test.sh bakes),
## loaded as the game loads it: the main scene, whose WorldLoader reads the flag itself.

const HERO := preload("res://game/scripts/world/facades/building_1_hero_model.gd")
const INTERIOR := preload("res://game/scripts/world/facades/building_1_interior.gd")
## How far round the hall's plan a roof slab must stand for the slab check to count.
const SLAB_NEAR_M := 6.0

var failures: Array[String] = []
var _world: Node3D
var _record_node: Node
## Nodes built here outside _world, freed at the end.
var _loose: Array[Node] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if OS.get_cmdline_user_args().has("--use-prebuilt-world"):
		_run_prebuilt()
		return
	var result: Dictionary = HERO.build_record(HERO._record_from_chunk(HERO.MAIN_CHUNK_PATH, HERO.BUILDING_WALL_KEY))
	if not bool(result.get("ok", false)):
		_finish("the hero wall record does not build: %s" % result)
		return
	var extras: Array = result.get("extra_nodes", [])
	if extras.size() != 1 or str((extras[0] as Dictionary).name) != "building_1_interior":
		_finish("the hero wall record returns no hall beside it")
		return
	var hall := (extras[0] as Dictionary).result.node as Node3D
	_record_node = result.get("node") as Node
	var world := Node3D.new()
	_world = world
	root.add_child(world)
	world.add_child(hall)
	var exterior := StaticBody3D.new()
	exterior.collision_layer = 1
	var exterior_shape := CollisionShape3D.new()
	exterior_shape.shape = _exterior_faces(result)
	exterior.add_child(exterior_shape)
	world.add_child(exterior)
	await physics_frame
	await physics_frame
	_check_layers(hall)
	_check_closure(hall)
	_check_door(hall)
	_check_roof(hall)
	_check_mural(hall)
	_check_reflections(hall, "the generated hall")
	_finish("")


## The reflections of the hall in the island baked for desktop exports, loaded through
## the game's main scene. (Loaded on its own, before the game's scripts, the baked scene
## stops on the preload cycle of Hawkins 77 Bruton's massing script, facade scene and
## facade script, which the game's own load order passes.)
func _run_prebuilt() -> void:
	var main := (load("res://game/scenes/main.tscn") as PackedScene).instantiate() as GameMain
	main.capture_mouse_on_ready = false
	main.use_saved_settings = false
	var world := main.get_node("WorldRoot") as WorldLoader
	var load_failures: Array[String] = []
	world.world_failed.connect(func(code: String, message: String, _keys: Array) -> void: load_failures.append("%s: %s" % [code, message]))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while not main.is_play_ready() and load_failures.is_empty() and Time.get_ticks_msec() - started < 180000:
		await process_frame
	var error := ""
	if not load_failures.is_empty() or not main.is_play_ready():
		error = "the baked island did not reach play: %s" % [load_failures]
	elif not world.uses_prebuilt_world():
		error = "the world loader built the island instead of loading the baked one"
	else:
		var node := world.find_child("HallReflections", true, false)
		if node == null:
			error = "the baked island has no hall reflections"
		else:
			_check_reflections(node.get_parent() as Node3D, "the baked hall")
	main.queue_free()
	await process_frame
	_finish(error, "PASS: the baked island, loaded as the game loads it, has the hall's floor reflections with a mode the node knows and the terrazzo surface's own attributes, byte for byte, beside a plain set of the same layout")


## The hall's floor reflections: a mode the node knows (and a config with another one
## fails the plan), the attributes they swap built for the very surface the hall draws.
func _check_reflections(hall: Node3D, where: String) -> void:
	var node := hall.get_node_or_null("HallReflections") as Building1HallReflections
	if node == null:
		failures.append("%s has no HallReflections node" % where)
		return
	if not node.mode in Building1HallReflections.MODES:
		failures.append("%s's reflections mode \"%s\" is not one the node knows" % [where, node.mode])
	if INTERIOR.reflections_problem({"reflections": {"mode": "sometimes"}}) == "":
		failures.append("a reflections mode the node does not know does not fail the hall's plan")
	var shell := hall.get_node_or_null("Shell") as MeshInstance3D
	var surface := Building1HallReflections.floor_surface(shell)
	if surface < 0:
		failures.append("%s has no terrazzo surface" % where)
		return
	if not node.attributes_fit(shell):
		failures.append("%s: the floor's built attributes do not fit its surface (format %d of %d, %d of %d vertices)" % [where, node.floor_format, shell.mesh.surface_get_format(surface), node.floor_vertex_count, shell.mesh.surface_get_array_len(surface)])
	var drawn := RenderingServer.mesh_get_surface(shell.mesh.get_rid(), surface)
	if drawn.get("attribute_data", PackedByteArray()) != node.sheen_attributes:
		failures.append("%s: the floor's built attributes are not the ones its surface draws" % where)
	if node.plain_attributes.size() != node.sheen_attributes.size() or node.plain_attributes == node.sheen_attributes:
		failures.append("%s: the floor's plain attributes are not a changed set of the same size (%d and %d bytes)" % [where, node.plain_attributes.size(), node.sheen_attributes.size()])
	# For the record, not a test: what the two sets weigh, and where the node's switch is.
	print("REFLECTIONS %s: the floor's attribute sets %d and %d bytes (%d vertices, format %d); hall %s, angles %s, top %.2f m" % [where, node.sheen_attributes.size(), node.plain_attributes.size(), node.floor_vertex_count, node.floor_format, node.hall, node.hall_angles, node.top_y])


## The hero record's exterior collision faces (its collision surfaces), to prove the
## door's passage is clear of them too.
func _exterior_faces(result: Dictionary) -> ConcavePolygonShape3D:
	var shape := ConcavePolygonShape3D.new()
	var faces := PackedVector3Array()
	var node := result.get("node") as Node
	if node != null:
		for body: Node in node.find_children("*", "StaticBody3D", true, false):
			for holder: Node in body.get_children():
				var concave := (holder as CollisionShape3D).shape as ConcavePolygonShape3D if holder is CollisionShape3D else null
				if concave != null:
					faces.append_array(concave.get_faces())
	shape.set_faces(faces)
	return shape


func _check_layers(hall: Node3D) -> void:
	var shell := hall.get_node_or_null("Shell") as MeshInstance3D
	if shell == null:
		failures.append("the hall has no Shell mesh")
		return
	if shell.layers != INTERIOR.RENDER_INTERIOR:
		failures.append("the hall draws on layers %d, not the interior layer the Sun leaves out" % shell.layers)
	if shell.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
		failures.append("the hall casts shadows the Sun never draws")
	var body := hall.get_node_or_null("Collision") as StaticBody3D
	if body == null or body.collision_layer != INTERIOR.PHYSICS_WORLD_SOLID:
		failures.append("the hall's collision is not on the world's solid layer")
	elif not ((body.get_child(0) as CollisionShape3D).shape as ConcavePolygonShape3D).backface_collision:
		failures.append("the hall's collision does not collide from both sides")


## Rays from points in every part of the hall: each meets the hall's collision, or
## leaves through the front door's opening.
func _check_closure(hall: Node3D) -> void:
	var loader := hall.get_node("MuralLoader") as Building1MuralLoader
	var center := Vector2(loader.hall.x, loader.hall.y)
	var floor_y := loader.door.y - 1.5
	var space := hall.get_world_3d().direct_space_state
	var points: Array[Vector3] = []
	for spot: Vector4 in [Vector4(42.8, -30.0, 1.6, 0), Vector4(42.8, -70.0, 3.0, 0), Vector4(42.8, 12.0, 3.0, 0), Vector4(42.8, -30.0, 12.5, 0), Vector4(32.5, -50.0, 6.5, 0), Vector4(32.0, -10.0, 15.5, 0), Vector4(32.5, -29.9, 1.6, 0), Vector4(45.0, -78.8, 1.5, 0), Vector4(42.0, -78.0, 6.4, 0), Vector4(53.2, -15.0, 1.5, 0)]:
		var theta := deg_to_rad(spot.y)
		points.append(Vector3(center.x + spot.x * cos(theta), floor_y + spot.z, center.y + spot.x * sin(theta)))
	var door := loader.door
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var escapes := 0
	var through_door := 0
	for point in points:
		for _i in 300:
			var z := rng.randf_range(-1.0, 1.0)
			var a := rng.randf_range(0.0, TAU)
			var r := sqrt(1.0 - z * z)
			var direction := Vector3(r * cos(a), z, r * sin(a))
			var query := PhysicsRayQueryParameters3D.create(point, point + direction * 150.0, 1)
			var hit := space.intersect_ray(query)
			if not hit.is_empty():
				continue
			escapes += 1
			# Out through the door: the ray passes within the opening, near the door.
			var closest := point + direction * clampf((door - point).dot(direction), 0.0, 150.0)
			if closest.distance_to(door) < 2.6:
				through_door += 1
	if escapes != through_door:
		failures.append("%d of %d rays left the hall other than through the front door" % [escapes - through_door, points.size() * 300])


## The passage: a capsule's worth of clear space walks through the door, and the car
## blocker spans the opening on the cars' ground layer only.
func _check_door(hall: Node3D) -> void:
	var loader := hall.get_node("MuralLoader") as Building1MuralLoader
	var space := hall.get_world_3d().direct_space_state
	var blocker := hall.get_node_or_null("CarBlocker") as StaticBody3D
	if blocker == null or blocker.collision_layer != INTERIOR.PHYSICS_CAR_GROUND:
		failures.append("the door's car blocker is missing or not on the cars' ground layer only")
		return
	var box := (blocker.get_child(0) as CollisionShape3D).shape as BoxShape3D
	if box == null or box.size.x < 3.0 or box.size.y < 3.0:
		failures.append("the car blocker does not span the door")
	var normal := blocker.global_transform.basis.z.normalized()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.8
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.collision_mask = 1
	for step in range(-6, 7):
		var at := Vector3(loader.door.x, loader.door.y - 1.5 + 0.95, loader.door.z) - normal * 0.4 * float(step)
		query.transform = Transform3D(Basis.IDENTITY, at)
		var hits := space.intersect_shape(query, 4)
		if not hits.is_empty():
			failures.append("the player's capsule meets solid ground or wall in the door's passage at %s" % at)
			return


## The hero's roof record, built as the world builds it: no slab triangle (drawn or
## solid) at a tier below the hall's top has its middle inside the hall's cut plan,
## while slabs do stand round it (so the check is not empty). A cut that would leave a
## hole in a slab fails the roof's build itself (building_1_hero_model.gd
## _append_cut_polygon).
func _check_roof(hall: Node3D) -> void:
	var built: Dictionary = HERO.build_record(HERO._record_from_chunk(HERO.MAIN_CHUNK_PATH, HERO.BUILDING_ROOF_KEY))
	var roof := built.get("node") as Node3D
	if not bool(built.get("ok", false)) or roof == null:
		if roof != null:
			_loose.append(roof)
		failures.append("the hero roof record does not build: %s" % str(built.get("message", built)))
		return
	_world.add_child(roof)
	var config: Dictionary = HERO._json(HERO.CONFIG_PATH)
	var front := HERO._json(HERO.BAR_CONFIG_PATH).geometry_production_inference_m as Dictionary
	var plan: Dictionary = HERO._interior_plan(HERO._record_from_chunk(HERO.MAIN_CHUNK_PATH, HERO.BUILDING_WALL_KEY), config, front)
	var cut := plan.get("cut_polygon", PackedVector2Array()) as PackedVector2Array
	if cut.size() < 3:
		failures.append("the hall's plan has no cut polygon")
		return
	var shell := hall.get_node("Shell") as MeshInstance3D
	var top := (shell.global_transform * shell.get_aabb()).end.y
	var vertical := config.vertical_production_inference_m as Dictionary
	var tiers: Array[float] = []
	for key: String in ["two_story_roof_y", "three_story_roof_y", "four_story_roof_y"]:
		if float(vertical[key]) < top:
			tiers.append(float(vertical[key]))
	var triangles := PackedVector3Array()
	for mesh_node: Node in roof.find_children("HeroSteppedRoof", "MeshInstance3D", true, false):
		var drawn := mesh_node as MeshInstance3D
		for vertex in drawn.mesh.get_faces():
			triangles.append(drawn.global_transform * vertex)
	for body: Node in roof.find_children("*", "StaticBody3D", true, false):
		for holder: Node in body.get_children():
			var concave := (holder as CollisionShape3D).shape as ConcavePolygonShape3D if holder is CollisionShape3D else null
			if concave != null:
				for vertex in concave.get_faces():
					triangles.append((holder as CollisionShape3D).global_transform * vertex)
	var inside := 0
	var near := 0
	var example := Vector3.ZERO
	for offset in range(0, triangles.size(), 3):
		var a := triangles[offset]
		var b := triangles[offset + 1]
		var c := triangles[offset + 2]
		var tier := false
		for y in tiers:
			tier = tier or (absf(a.y - y) < 0.01 and absf(b.y - y) < 0.01 and absf(c.y - y) < 0.01)
		if not tier:
			continue
		var middle := (a + b + c) / 3.0
		var flat := Vector2(middle.x, middle.z)
		if Geometry2D.is_point_in_polygon(flat, cut):
			inside += 1
			example = middle
		elif _polygon_distance(flat, cut) < SLAB_NEAR_M:
			near += 1
	if inside > 0:
		failures.append("%d roof slab triangles below the hall's top (%.2f) stand inside its plan, as at %s" % [inside, top, example])
	if near == 0:
		failures.append("no roof slab stands within %.0f m of the hall's plan, so the slab check proves nothing" % SLAB_NEAR_M)


func _polygon_distance(point: Vector2, polygon: PackedVector2Array) -> float:
	var best := INF
	for index in polygon.size():
		var closest := Geometry2D.get_closest_point_to_segment(point, polygon[index], polygon[(index + 1) % polygon.size()])
		best = minf(best, closest.distance_to(point))
	return best


## The mural's surfaces, materials and its loader's states.
func _check_mural(hall: Node3D) -> void:
	var loader := hall.get_node("MuralLoader") as Building1MuralLoader
	if loader.materials.size() != 4 or loader.tiles.size() != 4:
		failures.append("the mural has %d surfaces for %d tiles, not four" % [loader.materials.size(), loader.tiles.size()])
		return
	for material in loader.materials:
		if material.albedo_texture != loader.placeholder or material.texture_repeat:
			failures.append("a mural surface starts without its placeholder or repeats its texture")
			return
	# Every point of the hall is within the load radius of the door: nobody inside sees
	# the mural unload.
	var shell := hall.get_node("Shell") as MeshInstance3D
	var farthest := 0.0
	for surface in shell.mesh.get_surface_count():
		for vertex: Vector3 in shell.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]:
			farthest = maxf(farthest, Vector2(vertex.x - loader.door.x, vertex.z - loader.door.z).length())
	if farthest >= loader.load_radius:
		failures.append("part of the hall lies %.1f m from the door, past the mural's %.0f m load radius" % [farthest, loader.load_radius])
	loader.set_process(false)
	loader.step(loader.load_radius + 5.0, 0.1)
	if loader.state != Building1MuralLoader.State.UNLOADED:
		failures.append("the mural loads while the player is far from the door")
	loader.step(loader.load_radius - 1.0, 0.1)
	for _tile in loader.tiles.size():
		loader.step(loader.load_radius - 1.0, 0.1)
	if loader.state != Building1MuralLoader.State.LOADED:
		failures.append("the mural is not loaded one tile a frame near the door")
	for index in loader.tiles.size():
		var texture := loader.materials[index].albedo_texture
		if texture == loader.placeholder or texture == null or texture.resource_path != loader.tiles[index]:
			failures.append("mural surface %d does not show its tile once loaded" % (index + 1))
	_check_second_build(loader)
	loader.step(loader.unload_radius + 5.0, loader.unload_delay * 0.5)
	if loader.state != Building1MuralLoader.State.LOADED:
		failures.append("the mural is released too soon after the player leaves")
	loader.step(loader.unload_radius - 5.0, loader.unload_delay * 2.0)
	loader.step(loader.unload_radius + 5.0, loader.unload_delay * 0.6)
	if loader.state != Building1MuralLoader.State.LOADED:
		failures.append("the mural's release does not wait for the player to stay away")
	loader.step(loader.unload_radius + 5.0, loader.unload_delay * 0.6)
	if loader.state != Building1MuralLoader.State.UNLOADED or loader.tiles_loaded != 0:
		failures.append("the mural is not released after the player stays far away")
	for material in loader.materials:
		if material.albedo_texture != loader.placeholder or material.emission_texture != loader.placeholder:
			failures.append("a released mural surface does not show its placeholder")
			return


## A second build of the hall in the same process, while the first shows its tiles: it
## starts on a plain placeholder of its own, in materials of its own, so neither build
## can take a tile for its placeholder.
func _check_second_build(first: Building1MuralLoader) -> void:
	var again: Dictionary = HERO.build_record(HERO._record_from_chunk(HERO.MAIN_CHUNK_PATH, HERO.BUILDING_WALL_KEY))
	var record_node := again.get("node") as Node
	if record_node != null:
		_loose.append(record_node)
	var extras: Array = again.get("extra_nodes", [])
	var second := (extras[0] as Dictionary).result.node as Node3D if extras.size() == 1 else null
	if not bool(again.get("ok", false)) or second == null:
		failures.append("a second build of the hall in one process fails")
		return
	_world.add_child(second)
	var other := second.get_node("MuralLoader") as Building1MuralLoader
	var plain := other.placeholder
	if plain == null or plain == first.placeholder or plain.resource_path != "":
		failures.append("a second build's mural placeholder is not a plain texture of its own")
	if other.materials.size() != first.materials.size():
		failures.append("a second build's hall has %d mural surfaces, not %d" % [other.materials.size(), first.materials.size()])
	for material in other.materials:
		if material in first.materials or material.albedo_texture != plain or material.emission_texture != plain:
			failures.append("a second build's mural surfaces share the first build's materials or show its tiles")
			break
	second.free()


func _finish(error: String, passed := "") -> void:
	if error != "":
		failures.append(error)
	# Leave nothing behind: the nodes built here, and the hall's shared materials.
	if is_instance_valid(_world):
		_world.free()
	if is_instance_valid(_record_node):
		_record_node.free()
	for node in _loose:
		if is_instance_valid(node):
			node.free()
	INTERIOR._materials.clear()
	if failures.is_empty():
		if passed != "":
			print(passed)
		else:
			print("PASS: Building 1's hall is a closed shell left only through its front door, whose passage stays clear while its car blocker spans it; no roof slab stands over its plan below its top; it draws on the interior layer without shadows; its mural starts on a placeholder, loads near the door one tile a frame and is released only after the player stays far away, never from inside the hall; a second build has its own placeholder and materials; its floor reflections have a mode the node knows and carry the floor's own attributes beside a plain set")
		quit(0)
		return
	for message in failures:
		print("FAIL: " + message)
	quit(1)
