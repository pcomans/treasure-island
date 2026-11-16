extends SceneTree
## The pelicans, cormorants and gulls resting on the ferry breakwater
## (game/scripts/world/breakwater_birds.gd), in the real world, headless (generated
## at startup, or with -- --use-prebuilt-world the baked one desktop exports load,
## which WorldLoader reads itself):
##   1. the placement is the rule's: its seed gives the same birds twice and as
##      built (the Birds node's placements, with the line from the generated
##      context and the cap from ferry_terminal.gd), and another seed gives others;
##   2. every bird stands on the cap: a ray down from above each of its rest
##      points (a foot, or a sitting bird's belly) and round their edges meets the
##      breakwater's own collision first, at the bird's level within 1 cm, and the
##      bird's lowest point is that level: nothing of it lies below the cap's top
##      or floats above it;
##   3. no two birds touch: the plan-view outlines of their meshes (every vertex of
##      their pose, turned, sized and placed as the bird) keep at least 2 cm apart,
##      and the PASS line says how far apart the closest two are;
##   4. every species is there both standing and sitting, and no placed cluster of
##      three birds or more is all one pose; each pose's MultiMesh holds exactly
##      that pose's birds; the birds have no collision; and they are not drawn from
##      the middle of the island.
## Physics and data only (run with --headless): the dummy renderer's MultiMesh
## readback is not trusted, so the birds are read from the placements the
## MultiMeshes were built from.

const BIRDS := preload("res://game/scripts/world/breakwater_birds.gd")
const FERRY := preload("res://game/scripts/world/ferry_terminal.gd")
const BREAKWATER_PATH := "ContextWorld/FerryTerminal/FerryTerminal/Breakwater"
## How close a ray's hit must be to a bird's level, and how far apart two birds'
## outlines must stay (each grown by half of it).
const LEVEL_TOLERANCE_M := 0.01
const GAP_M := 0.02

var _failure := ""
var _finished := false
## The closest two birds' outlines: {distance (m), one, other (the birds)}.
var _closest := {}


func _initialize() -> void:
	create_timer(240.0, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
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
	if not _require(load_failures.is_empty() and main.is_play_ready(), "World did not reach play: %s" % [load_failures]):
		_finish(main)
		return
	for _tick in 4:
		await physics_frame
	var breakwater := world.get_node_or_null(BREAKWATER_PATH) as Node3D
	var birds := breakwater.get_node_or_null("Birds") as Node3D if breakwater != null else null
	var body := breakwater.get_node_or_null("BreakwaterCollision") as StaticBody3D if breakwater != null else null
	if not _require(birds != null and body != null, "The breakwater's Birds and BreakwaterCollision must be at %s." % BREAKWATER_PATH):
		_finish(main)
		return
	var placements: Array = birds.get_meta("placements", [])
	if not _require(not placements.is_empty(), "The breakwater has no birds."):
		_finish(main)
		return
	var problem := _placement_problem(placements)
	if problem.is_empty():
		problem = _standing_problem(placements, body)
	if problem.is_empty():
		problem = _cluster_problem(placements)
	if problem.is_empty():
		problem = _overlap_problem(placements)
	if problem.is_empty():
		problem = _node_problem(placements, birds)
	if not _require(problem.is_empty(), problem):
		_finish(main)
		return
	var counts := {}
	for bird: Dictionary in placements:
		counts[bird.pose] = int(counts.get(bird.pose, 0)) + 1
	var world_kind := "baked" if OS.get_cmdline_user_args().has("--use-prebuilt-world") else "generated"
	var one: Dictionary = _closest.one
	var other: Dictionary = _closest.other
	print("PASS: %d birds rest on the ferry breakwater's cap in the %s world (%s), every species standing and sitting, no cluster of three or more all one pose, the same for the same seed and other for another; every foot or sitting belly is over the cap's own collision at the bird's level, none of them below the cap or above it, no two birds' outlines within %d cm (the closest two %.1f cm apart: the %s at %s and the %s at %s), each pose's MultiMesh holds just its birds, none has collision, and none is drawn from the middle of the island" % [placements.size(), world_kind, ", ".join(PackedStringArray(counts.keys().map(func(pose: String) -> String: return "%s %d" % [pose, counts[pose]]))), roundi(GAP_M * 100.0), float(_closest.distance) * 100.0, one.pose, one.position, other.pose, other.position])
	_finish(main)


## The built birds against the rule, from the generated context's line and the
## cap's own size: the same seed twice and as built, another seed different.
func _placement_problem(placements: Array) -> String:
	var context: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://generated/world/context.json"))
	if not context is Dictionary or not (context as Dictionary).has("ferry_terminal"):
		return "The generated context has no ferry terminal."
	var section: Dictionary = context.ferry_terminal
	var line: Array = section.breakwater.line_xz
	var a := Vector2(float(line[0][0]), float(line[0][1]))
	var b := Vector2(float(line[1][0]), float(line[1][1]))
	var cap_y := float(section.water_y_m) + FERRY.BREAKWATER_TOP_M
	var half := FERRY.BREAKWATER_WIDTH_M * 0.5
	var first: Array = BIRDS.place(a, b, cap_y, half, BIRDS.SEED)
	var second: Array = BIRDS.place(a, b, cap_y, half, BIRDS.SEED)
	if not _same_birds(first, second):
		return "The placement rule gave two different results for the seed %d." % BIRDS.SEED
	if not _same_birds(first, placements):
		return "The built birds are not the rule's for seed %d: %d placed against %d built." % [BIRDS.SEED, first.size(), placements.size()]
	if _same_birds(BIRDS.place(a, b, cap_y, half, BIRDS.SEED + 1), first):
		return "Another seed gave the same birds: the seed does not drive the rule."
	for species: String in BIRDS.SPECIES_ORDER:
		for sitting: bool in [true, false]:
			if not placements.any(func(bird: Dictionary) -> bool: return bird.species == species and (str(bird.pose) in BIRDS.SITTING_POSES) == sitting):
				return "No %s %s on the breakwater." % [species, "sits" if sitting else "stands"]
	return ""


## The same birds in the same order: species, pose, position, turn and size exactly.
func _same_birds(one: Array, other: Array) -> bool:
	if one.size() != other.size():
		return false
	for index in one.size():
		var a: Dictionary = one[index]
		var b: Dictionary = other[index]
		for key: String in ["species", "pose", "position", "yaw", "scale"]:
			if not a.has(key) or not b.has(key) or a[key] != b[key]:
				return false
	return true


## Every rest point (and four points round its edge) straight over the cap's
## collision at the bird's level, and the bird's lowest point at that level.
func _standing_problem(placements: Array, body: StaticBody3D) -> String:
	var space := body.get_world_3d().direct_space_state
	for bird: Dictionary in placements:
		var model: Dictionary = BIRDS.model(str(bird.pose))
		var basis := BIRDS.turn(float(bird.yaw), float(bird.scale))
		var at: Vector3 = bird.position
		var lowest := INF
		for point: Vector3 in model.arrays[Mesh.ARRAY_VERTEX]:
			lowest = minf(lowest, (basis * point).y)
		if absf(lowest) > 1e-4:
			return "The %s at %s has its lowest point %.4f m off its feet's level." % [bird.pose, at, lowest]
		for contact: Dictionary in model.contacts:
			var centre := at + basis * (contact.at as Vector3)
			var reach := float(contact.r) * float(bird.scale)
			for offset: Vector3 in [Vector3.ZERO, Vector3(reach, 0.0, 0.0), Vector3(-reach, 0.0, 0.0), Vector3(0.0, 0.0, reach), Vector3(0.0, 0.0, -reach)]:
				var spot := centre + offset
				var query := PhysicsRayQueryParameters3D.create(spot + Vector3.UP * 3.0, spot + Vector3.DOWN * 3.0)
				var hit := space.intersect_ray(query)
				if hit.is_empty() or hit.collider != body:
					return "Under the %s at %s, the point %s is not over the breakwater's cap (hit %s)." % [bird.pose, at, spot, hit.get("collider")]
				if absf((hit.position as Vector3).y - at.y) > LEVEL_TOLERANCE_M:
					return "The %s at %s stands %.3f m off the cap's top (%.3f)." % [bird.pose, at, at.y - (hit.position as Vector3).y, (hit.position as Vector3).y]
	return ""


## No placed cluster of three birds or more all in one pose.
func _cluster_problem(placements: Array) -> String:
	var poses := {}
	for bird: Dictionary in placements:
		if not poses.has(bird.cluster):
			poses[bird.cluster] = []
		(poses[bird.cluster] as Array).append(bird.pose)
	for cluster: int in poses:
		var mine: Array = poses[cluster]
		if mine.size() >= 3 and mine.all(func(pose: String) -> bool: return pose == mine[0]):
			return "The %d birds of cluster %d are all %s." % [mine.size(), cluster, mine[0]]
	return ""


## No two birds' plan-view outlines, each grown by half the gap, overlap; and how
## far apart the closest two are (_closest).
func _overlap_problem(placements: Array) -> String:
	var outlines: Array[PackedVector2Array] = []
	var hulls: Array[PackedVector2Array] = []
	var centres: Array[Vector2] = []
	var radii: Array[float] = []
	for bird: Dictionary in placements:
		var model: Dictionary = BIRDS.model(str(bird.pose))
		var basis := BIRDS.turn(float(bird.yaw), float(bird.scale))
		var at: Vector3 = bird.position
		var flat := PackedVector2Array()
		for point: Vector3 in model.arrays[Mesh.ARRAY_VERTEX]:
			var placed := at + basis * point
			flat.append(Vector2(placed.x, placed.z))
		var hull := Geometry2D.convex_hull(flat)
		var grown: Array = Geometry2D.offset_polygon(hull, GAP_M * 0.5)
		if grown.size() != 1:
			return "The %s at %s has no single outline." % [bird.pose, at]
		var centre := Vector2.ZERO
		for corner: Vector2 in hull:
			centre += corner
		centre /= float(hull.size())
		var radius := 0.0
		for corner: Vector2 in grown[0]:
			radius = maxf(radius, centre.distance_to(corner))
		outlines.append(grown[0])
		hulls.append(hull)
		centres.append(centre)
		radii.append(radius)
	_closest = {"distance": INF, "one": placements[0], "other": placements[0]}
	for i in placements.size():
		for j in range(i + 1, placements.size()):
			if centres[i].distance_to(centres[j]) > radii[i] + radii[j] + 1.0:
				continue
			if not Geometry2D.intersect_polygons(outlines[i], outlines[j]).is_empty():
				return "The %s at %s and the %s at %s come within %d cm of each other." % [placements[i].pose, placements[i].position, placements[j].pose, placements[j].position, roundi(GAP_M * 100.0)]
			var apart := _hull_distance(hulls[i], hulls[j])
			if apart < float(_closest.distance):
				_closest = {"distance": apart, "one": placements[i], "other": placements[j]}
	return ""


## How far apart two outlines that do not overlap are: the least distance from a
## corner of either to an edge of the other.
func _hull_distance(one: PackedVector2Array, other: PackedVector2Array) -> float:
	var least := INF
	for pair: Array in [[one, other], [other, one]]:
		var corners: PackedVector2Array = pair[0]
		var edges: PackedVector2Array = pair[1]
		for corner: Vector2 in corners:
			for index in edges.size():
				var nearest := Geometry2D.get_closest_point_to_segment(corner, edges[index], edges[(index + 1) % edges.size()])
				least = minf(least, corner.distance_to(nearest))
	return least


## One MultiMesh per pose holding just that pose's birds, no collision under the
## birds, and none of them drawn from the middle of the island.
func _node_problem(placements: Array, birds: Node3D) -> String:
	if not birds.find_children("*", "CollisionObject3D", true, false).is_empty():
		return "The breakwater's birds must have no collision."
	var built := 0
	for instance: Node in birds.get_children():
		var multimesh := instance as MultiMeshInstance3D
		if multimesh == null or multimesh.multimesh == null:
			return "%s under the birds is not a MultiMeshInstance3D." % instance.name
		var pose := str(multimesh.get_meta("pose", ""))
		var mine := placements.filter(func(bird: Dictionary) -> bool: return bird.pose == pose).size()
		if mine == 0 or multimesh.multimesh.instance_count != mine:
			return "The %s MultiMesh holds %d birds, the placements %d." % [pose, multimesh.multimesh.instance_count, mine]
		built += mine
		var reach := multimesh.visibility_range_end + multimesh.visibility_range_end_margin
		var middle := Vector3(0.0, multimesh.global_position.y, 0.0)
		if multimesh.visibility_range_end <= 0.0 or multimesh.global_position.distance_to(middle) <= reach:
			return "The %s birds are drawn %.0f m out, as far as the island's middle." % [pose, reach]
	if built != placements.size():
		return "The MultiMeshes hold %d birds, the placements %d." % [built, placements.size()]
	return ""


func _require(condition: bool, message: String) -> bool:
	if not condition and _failure.is_empty():
		_failure = message
		push_error(message)
	return condition


func _finish(main: Node) -> void:
	if _finished:
		return
	_finished = true
	if main != null and is_instance_valid(main):
		main.queue_free()
		await process_frame
	quit(0 if _failure.is_empty() else 1)


func _on_timeout() -> void:
	if not _finished:
		_finished = true
		_require(false, "The breakwater birds test did not finish within 240 s.")
		quit(1)
