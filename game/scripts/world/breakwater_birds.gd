class_name BreakwaterBirds
extends RefCounted
## Brown pelicans, double-crested cormorants and western gulls resting on the ferry
## terminal's breakwater (frozen OSM w1011830371, the wall ferry_terminal.gd builds
## in the water NW of the float). Owner, 2026-11-15: "There are usually three types
## of birds sitting on the breakwater. Pelicans, cormorants, and seagulls"; the
## Commons photos of the new breakwater (7 Aug 2021) show loose rows of dark birds
## along its cap, with gaps. The owner chose the models: a standing and a sitting
## version of every bird, the pelican standing with its bill out and with it
## tucked, the cormorant standing with its wings folded and with them spread to
## dry; about a hundred birds (2026-11-16).
##
## Forms, sizes and colours are production inference from public photos of the
## species (shape, proportion, posture and colour only): a Pacific brown pelican
## about 0.84 m to the crown with its bill out, its bill 0.37 m, the heaviest of
## the three; a double-crested cormorant 0.65 m upright, 0.82 m across its spread
## wings; a western gull 0.39 m standing, 0.68 m from bill to wingtip, with a long
## flat-backed body, a dark slate back, crossed black wingtips, a flat-crowned head
## small for its body, a deep hooked bill and a pale eye. Sitting, a pelican lies
## on its belly with its bill laid down its breast and a cormorant lies low, its
## tail along the stone and its neck up in an S (the Pismo Beach pier and Niagara
## rock photos); a gull settles its long body on the stone, its head drawn in and
## its wingtips flat over the tail. Adults, one plumage each. Plumage is vertex
## colour, one material for all (breakwater_birds.gdshader); no texture. Folded
## wings are painted on the body, so its outline stays whole from any side; only
## the long primaries stand free, crossed over the tail.
##
## Placement is a rule (place()), seeded so it is the same every run: a few
## colonies along the cap, where most of each species' clusters gather (a
## Poisson number of birds round each cluster's centre, spread normally along
## the cap); some clusters, most of all the gulls', settle anywhere. So there are
## bunches, rows and clear gaps, and where clusters meet the species mix. A
## cluster is resting (its birds mostly sitting or tucked) or alert (mostly
## standing); placed with three birds or more all in one pose, one of them takes
## another pose wherever one fits where it stands. A cluster mostly faces one
## way, most into the prevailing westerly, each bird turning a little from it or,
## now and then, its own way. Every bird keeps its feet (or belly) on the cap,
## and no two birds' footprints (the capsule round each pose's plan-view outline,
## spread wings included) come within CLEARANCE_M of each other: a bird that would
## is moved along the cap, or left out.
##
## Scenery: no collision, no sound, no motion. The breakwater lies 79 to 93 m off
## the float, the pier and the island's edge, beyond the 10 m a lifted player may
## float from the shore (recovery_controller.gd), so no player or car reaches them.

const SHADER := preload("res://game/resources/materials/world/birds/breakwater_birds.gdshader")

## The eight models (owner, 2026-11-15/16): every bird standing and sitting.
const POSES := [
	"pelican_bill_out", "pelican_bill_tucked", "pelican_sitting",
	"cormorant_wings_folded", "cormorant_wings_spread", "cormorant_sitting",
	"gull_standing", "gull_sitting",
]
const SITTING_POSES := ["pelican_sitting", "cormorant_sitting", "gull_sitting"]
const SPECIES_ORDER := ["pelican", "cormorant", "gull"]

## The rule's seed and its numbers (production inference: the 2021 photos and the
## owner's "usually three types" and "twice as many birds" set the character).
## Colonies: how many (one in each stretch of the cap), and how far each spreads
## its clusters along it (standard deviation, between the two values). Each
## species: how many birds (its clusters keep coming until they are drawn; a few
## that find no room are left out), the share of its clusters that settle anywhere
## rather than at a colony, the mean number of birds in one and its bounds, how
## far they spread along the cap (standard deviation, m), the share of clusters
## resting, the poses a resting and an alert cluster take with their weights, the
## share of clusters facing into the wind, the share of a cluster's birds facing
## its way, and the spread of sizes.
const SEED := 1115
const COLONIES := 5
const COLONY_SPREAD_M := Vector2(3.0, 9.0)
const SPECIES := {
	"pelican": {"birds": 24, "loners": 0.1, "mean": 4.5, "min": 1, "max": 9, "spread_m": 2.5, "rest": 0.5,
		"poses": {
			"resting": [["pelican_sitting", 0.5], ["pelican_bill_tucked", 0.35], ["pelican_bill_out", 0.15]],
			"alert": [["pelican_bill_out", 0.65], ["pelican_bill_tucked", 0.2], ["pelican_sitting", 0.15]],
		},
		"into_wind": 0.6, "follow": 0.8, "scale_sd": 0.035},
	"cormorant": {"birds": 50, "loners": 0.1, "mean": 6.8, "min": 2, "max": 15, "spread_m": 3.8, "rest": 0.4,
		"poses": {
			"resting": [["cormorant_wings_folded", 0.55], ["cormorant_sitting", 0.4], ["cormorant_wings_spread", 0.05]],
			"alert": [["cormorant_wings_folded", 0.71], ["cormorant_wings_spread", 0.17], ["cormorant_sitting", 0.12]],
		},
		"into_wind": 0.6, "follow": 0.8, "scale_sd": 0.04},
	"gull": {"birds": 28, "loners": 0.45, "mean": 2.0, "min": 1, "max": 5, "spread_m": 6.0, "rest": 0.5,
		"poses": {
			"resting": [["gull_sitting", 0.7], ["gull_standing", 0.3]],
			"alert": [["gull_standing", 0.75], ["gull_sitting", 0.25]],
		},
		"into_wind": 0.75, "follow": 0.7, "scale_sd": 0.05},
}
## The westerly the street trees sway in (vegetation_wind.gdshaderinc's
## wind_direction): it blows toward +X and a little +Z, so a bird facing into it
## looks toward -X.
const WIND_TOWARD := Vector2(0.95, 0.3)
## How far a cluster's birds turn from its heading (standard deviation, degrees).
const HEADING_SD_DEG := 22.0
## No foot nearer the cap's ends than END_MARGIN_M, nor nearer its long edges than
## EDGE_MARGIN_M; birds stand mostly near its middle (ACROSS_SD_M).
const END_MARGIN_M := 0.5
const EDGE_MARGIN_M := 0.05
const ACROSS_SD_M := 0.14
## The gap two birds' footprints keep at least, and how a crowded bird is moved
## along the cap (steps of NUDGE_M either way, NUDGES times) before it is left out.
const CLEARANCE_M := 0.06
const NUDGE_M := 0.2
const NUDGES := 20
## How far one bird's plumage may sit lighter or darker than another's.
const TONE_SPREAD := 0.06
## The pelican models' size over the shapes they are drawn in below.
const PELICAN_SIZE := 1.15

## Drawn to this far from the breakwater's middle (and out to the margin past it):
## the ferry plaza, the pier and the west shore near them, not the far island.
const VISIBLE_TO_M := 420.0
const VISIBLE_MARGIN_M := 30.0

## Colours (sRGB; alpha is gloss). Western gull.
const GULL_WHITE := Color(0.93, 0.94, 0.94, 0.0)
const GULL_MANTLE := Color(0.215, 0.23, 0.262, 0.0)
const GULL_PRIMARY := Color(0.06, 0.06, 0.07, 0.1)
const GULL_MIRROR := Color(0.88, 0.88, 0.88, 0.0)
const GULL_BILL := Color(0.95, 0.79, 0.27, 0.8)
const GULL_GONYS := Color(0.84, 0.2, 0.12, 0.8)
const GULL_LEG := Color(0.85, 0.6, 0.58, 0.5)
const GULL_IRIS := Color(0.92, 0.88, 0.6, 0.9)
const GULL_PUPIL := Color(0.07, 0.06, 0.05, 1.0)
## Double-crested cormorant.
const CORMORANT_BLACK := Color(0.06, 0.065, 0.06, 0.3)
const CORMORANT_COVERT := Color(0.2, 0.18, 0.13, 0.2)
const CORMORANT_FLIGHT := Color(0.1, 0.09, 0.08, 0.1)
const CORMORANT_GULAR := Color(0.84, 0.54, 0.24, 0.15)
const CORMORANT_BILL := Color(0.3, 0.29, 0.27, 0.6)
const CORMORANT_EYE := Color(0.1, 0.42, 0.34, 0.6)
const CORMORANT_FOOT := Color(0.07, 0.07, 0.07, 0.3)
## Brown pelican (a Pacific adult: the head white with a yellow wash, a dark
## stripe down the hindneck, silvery grey-brown back, dark belly and wing tips).
const PELICAN_WHITE := Color(0.95, 0.94, 0.9, 0.0)
const PELICAN_CROWN := Color(0.95, 0.86, 0.58, 0.0)
const PELICAN_HINDNECK := Color(0.33, 0.2, 0.12, 0.0)
const PELICAN_BACK := Color(0.56, 0.53, 0.49, 0.0)
const PELICAN_BELLY := Color(0.2, 0.17, 0.14, 0.0)
const PELICAN_PRIMARY := Color(0.13, 0.11, 0.1, 0.05)
const PELICAN_BILL := Color(0.72, 0.66, 0.6, 0.6)
const PELICAN_BILL_TIP := Color(0.85, 0.45, 0.25, 0.6)
const PELICAN_POUCH := Color(0.33, 0.32, 0.27, 0.4)
const PELICAN_LEG := Color(0.17, 0.17, 0.17, 0.3)
const PELICAN_EYE := Color(0.82, 0.82, 0.76, 0.8)

static var _models := {}
static var _meshes := {}
static var _material: ShaderMaterial


## The birds on a breakwater cap from `a` to `b` (world, its centre line's ends),
## its top at cap_y and half_width wide each side: a "Birds" node with one
## MultiMeshInstance3D per pose that has birds, its "placements" meta the rule's
## result. Counts go into `report` as the shoreline counts its instanced stones.
static func build(a: Vector3, b: Vector3, cap_y: float, half_width: float, report: Dictionary) -> Node3D:
	var node := Node3D.new()
	node.name = "Birds"
	node.set_meta("source_keys", ["w1011830371"])
	node.set_meta("derived_object_key", "context:ferry-terminal:breakwater-birds")
	node.set_meta("dimensions", "production_inference_from_species_photos")
	var placements := place(Vector2(a.x, a.z), Vector2(b.x, b.z), cap_y, half_width, SEED)
	node.set_meta("seed", SEED)
	node.set_meta("placements", placements)
	var middle := Vector3((a.x + b.x) * 0.5, 0.0, (a.z + b.z) * 0.5)
	var counts := {}
	for pose: String in POSES:
		var mine := placements.filter(func(bird: Dictionary) -> bool: return bird.pose == pose)
		counts[pose] = mine.size()
		if mine.is_empty():
			continue
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.use_colors = true
		multimesh.use_custom_data = true
		multimesh.mesh = mesh(pose)
		multimesh.instance_count = mine.size()
		for index in mine.size():
			var bird: Dictionary = mine[index]
			var at: Vector3 = bird.position
			multimesh.set_instance_transform(index, Transform3D(turn(float(bird.yaw), float(bird.scale)), at - middle))
			multimesh.set_instance_color(index, Color.WHITE)
			# The shader reads the bird's tone (r) and size (a).
			multimesh.set_instance_custom_data(index, Color(_tone(at), 0.0, 0.0, float(bird.scale)))
		var instance := MultiMeshInstance3D.new()
		instance.name = pose.to_pascal_case()
		instance.multimesh = multimesh
		instance.position = middle
		instance.visibility_range_end = VISIBLE_TO_M
		instance.visibility_range_end_margin = VISIBLE_MARGIN_M
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		instance.set_meta("pose", pose)
		node.add_child(instance)
		report.mesh_instances = int(report.get("mesh_instances", 0)) + 1
		report.surfaces = int(report.get("surfaces", 0)) + 1
		report.triangles = int(report.get("triangles", 0)) + int(model(pose).triangles) * mine.size()
	node.set_meta("pose_counts", counts)
	return node


## A bird's own tone, 1 give or take TONE_SPREAD, the same for the same spot.
static func _tone(at: Vector3) -> float:
	var noise := fposmod(sin(at.x * 12.9898 + at.z * 78.233) * 43758.5453, 1.0)
	return 1.0 + TONE_SPREAD * (noise * 2.0 - 1.0)


## A bird's turn about +Y (it faces -Z at yaw 0) and size: its instance basis.
static func turn(yaw: float, size: float) -> Basis:
	return Basis(Vector3.UP, yaw).scaled(Vector3.ONE * size)


## The placement rule: [{cluster (which of the rule's clusters the bird came in),
## species, pose, position (world, its feet's level on the cap), yaw (radians about
## +Y; 0 faces -Z), scale}], in the order placed. The same arguments always give
## the same birds.
static func place(a: Vector2, b: Vector2, cap_y: float, half_width: float, seed: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var length := a.distance_to(b)
	var along := (b - a) / length
	var across := Vector2(-along.y, along.x)
	var wind_yaw := _yaw_facing(-WIND_TOWARD)
	# One colony in each of COLONIES stretches of the cap, anywhere in its middle
	# three fifths: so no long end stays bare, yet each is its own size.
	var colonies: Array[Vector2] = []
	var stretch := (length - 2.0 * END_MARGIN_M) / float(COLONIES)
	for index in COLONIES:
		var centre := END_MARGIN_M + stretch * (float(index) + rng.randf_range(0.2, 0.8))
		colonies.append(Vector2(centre, rng.randf_range(COLONY_SPREAD_M.x, COLONY_SPREAD_M.y)))
	var candidates: Array[Dictionary] = []
	var moods: Array = []
	for species: String in SPECIES_ORDER:
		var rule: Dictionary = SPECIES[species]
		var drawn := 0
		while drawn < int(rule.birds):
			var centre := 0.0
			if rng.randf() < float(rule.loners):
				centre = rng.randf_range(END_MARGIN_M, length - END_MARGIN_M)
			else:
				var colony := colonies[rng.randi_range(0, colonies.size() - 1)]
				centre = colony.x + rng.randfn(0.0, colony.y)
			var mood := "resting" if rng.randf() < float(rule.rest) else "alert"
			var weighted: Array = rule.poses[mood]
			var heading := wind_yaw if rng.randf() < float(rule.into_wind) else rng.randf_range(-PI, PI)
			var count := mini(clampi(_poisson(rng, float(rule.mean)), int(rule.min), int(rule.max)), int(rule.birds) - drawn)
			drawn += count
			moods.append(weighted)
			for _bird in count:
				var yaw := heading + deg_to_rad(rng.randfn(0.0, HEADING_SD_DEG))
				if rng.randf() >= float(rule.follow):
					yaw = rng.randf_range(-PI, PI)
				candidates.append({
					"cluster": moods.size() - 1,
					"species": species,
					"pose": _pick(rng, weighted),
					"s": centre + rng.randfn(0.0, float(rule.spread_m)),
					"t": rng.randfn(0.0, ACROSS_SD_M),
					"yaw": wrapf(yaw, -PI, PI),
					"scale": clampf(1.0 + rng.randfn(0.0, float(rule.scale_sd)), 0.88, 1.12),
				})
	var placed: Array[Dictionary] = []
	var shapes: Array[Dictionary] = []
	for candidate: Dictionary in candidates:
		var spot := _fit(candidate, a, along, across, length, half_width, shapes)
		if spot.is_empty():
			continue
		shapes.append(spot.footprint)
		var at: Vector2 = spot.at
		placed.append({
			"cluster": candidate.cluster,
			"species": candidate.species,
			"pose": candidate.pose,
			"position": Vector3(at.x, cap_y, at.y),
			"yaw": float(candidate.yaw),
			"scale": float(candidate.scale),
		})
	# A placed cluster of three or more all in one pose: one of its birds, the last
	# placed first, takes its mood's likeliest other pose that fits where it stands
	# (feet on the cap, its footprint clear of the others'). Nothing random is drawn
	# here, so every bird drawn before stays as it was.
	var members := {}
	for index in placed.size():
		var key: int = placed[index].cluster
		if not members.has(key):
			members[key] = []
		(members[key] as Array).append(index)
	for key: int in members:
		var mine: Array = members[key]
		if mine.size() < 3 or not mine.all(func(index: int) -> bool: return placed[index].pose == placed[mine[0]].pose):
			continue
		var switched := false
		for back in mine.size():
			var index: int = mine[mine.size() - 1 - back]
			var bird := placed[index]
			for entry: Array in _by_weight(moods[key]):
				if entry[0] == bird.pose:
					continue
				var footprint := _footprint_at(str(entry[0]), bird, a, along, across, length, half_width, shapes, index)
				if not footprint.is_empty():
					bird.pose = entry[0]
					shapes[index] = footprint
					switched = true
					break
			if switched:
				break
	return placed


## The weighted poses, the heaviest first.
static func _by_weight(weighted: Array) -> Array:
	var sorted := weighted.duplicate()
	sorted.sort_custom(func(one: Array, other: Array) -> bool: return float(one[1]) > float(other[1]))
	return sorted


## Where on the cap a candidate stands: its own spot (a spot past an end reflected
## back onto the cap), else the nearest of NUDGES steps along the cap either way,
## every other step on the other side of the middle, where all its feet are on
## the cap and its footprint keeps CLEARANCE_M from every placed one.
## {at (world XZ), footprint {a, b, r}}, or {} when none is.
static func _fit(candidate: Dictionary, a: Vector2, along: Vector2, across: Vector2, length: float, half_width: float, shapes: Array[Dictionary]) -> Dictionary:
	var pose := str(candidate.pose)
	var ranges := _cap_ranges(pose, float(candidate.yaw), float(candidate.scale), along, across, length, half_width)
	if ranges.is_empty():
		return {}
	var s_lo: float = ranges[0]
	var s_hi: float = ranges[1]
	var t_lo: float = ranges[2]
	var t_hi: float = ranges[3]
	var s0 := float(candidate.s)
	if s0 < s_lo:
		s0 = minf(2.0 * s_lo - s0, s_hi)
	elif s0 > s_hi:
		s0 = maxf(2.0 * s_hi - s0, s_lo)
	var t0 := clampf(float(candidate.t), t_lo, t_hi)
	for attempt in NUDGES * 2 + 1:
		var step := (attempt + 1) / 2
		var s := s0 + (1.0 if attempt % 2 == 1 else -1.0) * NUDGE_M * float(step)
		if s < s_lo or s > s_hi:
			continue
		var t := t0 if step % 2 == 0 else clampf(-t0, t_lo, t_hi)
		var at := a + along * s + across * t
		var mine := _placed_capsule(pose, float(candidate.yaw), float(candidate.scale), at)
		if _clear(mine, shapes, -1):
			return {"at": at, "footprint": mine}
	return {}


## The footprint a placed bird would have in `pose` where it stands, if that pose
## keeps its feet on the cap and its footprint CLEARANCE_M from every other placed
## one (all of `shapes` but its own, at `own`); else {}.
static func _footprint_at(pose: String, bird: Dictionary, a: Vector2, along: Vector2, across: Vector2, length: float, half_width: float, shapes: Array[Dictionary], own: int) -> Dictionary:
	var ranges := _cap_ranges(pose, float(bird.yaw), float(bird.scale), along, across, length, half_width)
	if ranges.is_empty():
		return {}
	var at := Vector2((bird.position as Vector3).x, (bird.position as Vector3).z)
	var s := (at - a).dot(along)
	var t := (at - a).dot(across)
	if s < float(ranges[0]) or s > float(ranges[1]) or t < float(ranges[2]) or t > float(ranges[3]):
		return {}
	var mine := _placed_capsule(pose, float(bird.yaw), float(bird.scale), at)
	return mine if _clear(mine, shapes, own) else {}


## The ranges along (s) and across (t) the cap where a bird in `pose`, turned and
## sized so, keeps every foot on it: [s_lo, s_hi, t_lo, t_hi], or [] when none.
static func _cap_ranges(pose: String, yaw: float, size: float, along: Vector2, across: Vector2, length: float, half_width: float) -> Array:
	var shape := model(pose)
	var basis := turn(yaw, size)
	var s_lo := -INF
	var s_hi := INF
	var t_lo := -INF
	var t_hi := INF
	for contact: Dictionary in shape.contacts:
		var turned := basis * (contact.at as Vector3)
		var offset := Vector2(turned.x, turned.z)
		var radius := float(contact.r) * size
		s_lo = maxf(s_lo, END_MARGIN_M + radius - offset.dot(along))
		s_hi = minf(s_hi, length - END_MARGIN_M - radius - offset.dot(along))
		var reach := half_width - EDGE_MARGIN_M - radius
		t_lo = maxf(t_lo, -reach - offset.dot(across))
		t_hi = minf(t_hi, reach - offset.dot(across))
	if s_lo > s_hi or t_lo > t_hi:
		return []
	return [s_lo, s_hi, t_lo, t_hi]


## A bird's footprint in `pose` at `at` (world XZ): the capsule round its plan-view
## outline, turned and sized, {a, b, r}.
static func _placed_capsule(pose: String, yaw: float, size: float, at: Vector2) -> Dictionary:
	var footprint: Dictionary = model(pose).footprint
	var basis := turn(yaw, size)
	var end_a := basis * Vector3((footprint.a as Vector2).x, 0.0, (footprint.a as Vector2).y)
	var end_b := basis * Vector3((footprint.b as Vector2).x, 0.0, (footprint.b as Vector2).y)
	return {"a": at + Vector2(end_a.x, end_a.z), "b": at + Vector2(end_b.x, end_b.z), "r": float(footprint.r) * size}


## Whether a footprint keeps CLEARANCE_M from every one of `shapes` but the one at
## `own` (-1: none of them is its own).
static func _clear(mine: Dictionary, shapes: Array[Dictionary], own: int) -> bool:
	for index in shapes.size():
		if index == own:
			continue
		var other := shapes[index]
		if _segment_distance(mine.a, mine.b, other.a, other.b) < float(mine.r) + float(other.r) + CLEARANCE_M:
			return false
	return true


static func _yaw_facing(direction: Vector2) -> float:
	# Facing -Z at yaw 0, turned about +Y: forward is (-sin yaw, -cos yaw).
	return atan2(-direction.x, -direction.y)


static func _pick(rng: RandomNumberGenerator, weighted: Array) -> String:
	var total := 0.0
	for entry: Array in weighted:
		total += float(entry[1])
	var roll := rng.randf() * total
	for entry: Array in weighted:
		roll -= float(entry[1])
		if roll < 0.0:
			return str(entry[0])
	return str(weighted[-1][0])


## A Poisson count with this mean (Knuth's product of uniforms).
static func _poisson(rng: RandomNumberGenerator, mean: float) -> int:
	var limit := exp(-mean)
	var product := rng.randf()
	var count := 0
	while product > limit:
		count += 1
		product *= rng.randf()
	return count


## The distance between two segments in the plane (0 where they cross).
static func _segment_distance(a0: Vector2, a1: Vector2, b0: Vector2, b1: Vector2) -> float:
	var d1 := (a1 - a0).cross(b0 - a0)
	var d2 := (a1 - a0).cross(b1 - a0)
	var d3 := (b1 - b0).cross(a0 - b0)
	var d4 := (b1 - b0).cross(a1 - b0)
	if d1 * d2 < 0.0 and d3 * d4 < 0.0:
		return 0.0
	return minf(minf(_point_segment(a0, b0, b1), _point_segment(a1, b0, b1)), minf(_point_segment(b0, a0, a1), _point_segment(b1, a0, a1)))


static func _point_segment(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var t := 0.0 if ab.length_squared() < 1e-12 else clampf((p - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
	return p.distance_to(a + ab * t)


## A pose's mesh with the birds' material (one per pose, shared by every use).
static func mesh(pose: String) -> ArrayMesh:
	if not _meshes.has(pose):
		var made := ArrayMesh.new()
		made.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, model(pose).arrays)
		made.surface_set_material(0, material())
		made.resource_name = "bird_" + pose
		_meshes[pose] = made
	return _meshes[pose]


static func material() -> ShaderMaterial:
	if _material == null:
		_material = ShaderMaterial.new()
		_material.resource_name = "breakwater_birds"
		_material.shader = SHADER
	return _material


## A pose's model: {arrays (Mesh.ARRAY_MAX: vertex, normal, colour, UV2, index),
## contacts (where it rests on the stone: [{at, r}], points on y = 0 and the radius
## round each: its feet, or a sitting bird's belly), footprint (the capsule round
## its plan-view outline: segment ends a and b in local XZ and radius r),
## triangles, height}. Built once. Nothing of it lies below y = 0.
static func model(pose: String) -> Dictionary:
	if _models.has(pose):
		return _models[pose]
	var m := Mesher.new()
	match pose:
		"gull_standing":
			_gull(m, false)
		"gull_sitting":
			_gull(m, true)
		"cormorant_wings_folded":
			_cormorant(m, false)
		"cormorant_wings_spread":
			_cormorant(m, true)
		"cormorant_sitting":
			_cormorant_sitting(m)
		"pelican_bill_out":
			_pelican(m, "out")
		"pelican_bill_tucked":
			_pelican(m, "tucked")
		"pelican_sitting":
			_pelican(m, "sitting")
		_:
			push_error("BreakwaterBirds: no pose %s" % pose)
			return {}
	if pose.begins_with("pelican"):
		m.scale_all(PELICAN_SIZE)
	# A belly pressed on the stone is flat: no ring between two that meet it dips
	# under; and the model's lowest point is on the stone.
	m.floor_at(0.0)
	m.settle()
	if m.contacts.is_empty():
		m.contacts.append(m.belly())
	var height := 0.0
	for point: Vector3 in m.points:
		height = maxf(height, point.y)
	var made := {
		"arrays": m.arrays(),
		"contacts": m.contacts,
		"footprint": _capsule(m.points),
		"triangles": m.indices.size() / 3,
		"height": height,
	}
	_models[pose] = made
	return made


## The capsule round a model's plan-view outline (x, z): along whichever of its
## two axes gives the smaller capsule, through the middle of its extent across.
static func _capsule(points: PackedVector3Array) -> Dictionary:
	var best := {}
	for axis: Vector2 in [Vector2(1.0, 0.0), Vector2(0.0, 1.0)]:
		var normal := Vector2(-axis.y, axis.x)
		var lo := INF
		var hi := -INF
		var near := INF
		var far := -INF
		for point: Vector3 in points:
			var flat := Vector2(point.x, point.z)
			lo = minf(lo, flat.dot(axis))
			hi = maxf(hi, flat.dot(axis))
			near = minf(near, flat.dot(normal))
			far = maxf(far, flat.dot(normal))
		var middle := (near + far) * 0.5
		var half := (far - near) * 0.5
		var start := minf(lo + half, (lo + hi) * 0.5)
		var finish := maxf(hi - half, (lo + hi) * 0.5)
		var a := axis * start + normal * middle
		var b := axis * finish + normal * middle
		var radius := 0.0
		for point: Vector3 in points:
			radius = maxf(radius, _point_segment(Vector2(point.x, point.z), a, b))
		var area := PI * radius * radius + 2.0 * radius * a.distance_to(b)
		if best.is_empty() or area < float(best.area):
			best = {"a": a, "b": b, "r": radius, "area": area}
	best.erase("area")
	return best


## For the kit gallery (game/tests/shared/kit_gallery.gd, a plan with "kit":
## "birds"): one bird of pose `prop` at `placement`, drawn as the world draws it
## (a one-instance MultiMesh, under a plain node as the gallery's other kits'
## items are). params may set "scale"; there is one detail level.
func preview(prop: String, params: Dictionary, _level: String, placement: Transform3D) -> Node3D:
	if not prop in POSES:
		return null
	var size := float(params.get("scale", 1.0))
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = true
	multimesh.use_custom_data = true
	multimesh.mesh = mesh(prop)
	multimesh.instance_count = 1
	multimesh.set_instance_transform(0, Transform3D(placement.basis.scaled(Vector3.ONE * size), placement.origin))
	multimesh.set_instance_color(0, Color.WHITE)
	multimesh.set_instance_custom_data(0, Color(1.0, 0.0, 0.0, size))
	var instance := MultiMeshInstance3D.new()
	instance.name = prop.to_pascal_case()
	instance.multimesh = multimesh
	var holder := Node3D.new()
	holder.name = "Bird"
	holder.add_child(instance)
	return holder


# ------------------------------------------------------------------ western gull

## A western gull facing -Z, its feet on y = 0: a long, flat-backed body, the folded
## wings painted dark slate along its back and sides, the black primaries crossed
## over the tail and reaching past it, a flat-crowned head with a sloping
## forehead, a pale eye under a heavy brow and a deep, hooked yellow bill with the
## red gonys spot. Standing on thick pink legs, or sitting with its body low on the
## stone, its head drawn in and its legs folded out of sight.
static func _gull(m: Mesher, sitting: bool) -> void:
	# The body: [z, y, half width, half height], from the tail to the breast.
	var body_rings := [
		[0.255, 0.205, 0.028, 0.016], [0.2, 0.205, 0.05, 0.033], [0.13, 0.205, 0.072, 0.052],
		[0.05, 0.203, 0.082, 0.072], [-0.03, 0.202, 0.084, 0.079], [-0.1, 0.21, 0.077, 0.079],
		[-0.15, 0.232, 0.058, 0.064], [-0.175, 0.262, 0.04, 0.044],
	]
	# A thick neck merging into the breast, narrowing up into the head.
	var neck_rings := [
		[0.25, -0.13, 0.056, 0.056, Vector3.BACK], [0.29, -0.148, 0.048, 0.05, Vector3.BACK],
		[0.318, -0.155, 0.042, 0.044, Vector3(0.0, 0.4, 1.0)],
	]
	# How much lower, and how much further back, the head sits than a standing gull's.
	var head_shift := Vector3.ZERO
	var tail_tip_z := 0.275
	if sitting:
		# Long and low, the breast down on the stone and the head drawn in onto the
		# shoulders.
		body_rings = [
			[0.27, 0.098, 0.026, 0.015], [0.2, 0.096, 0.054, 0.035], [0.13, 0.089, 0.078, 0.055],
			[0.05, 0.081, 0.088, 0.073], [-0.03, 0.079, 0.09, 0.079], [-0.1, 0.084, 0.082, 0.078],
			[-0.15, 0.1, 0.064, 0.066], [-0.175, 0.124, 0.044, 0.048],
		]
		neck_rings = [
			[0.125, -0.12, 0.056, 0.056, Vector3.BACK], [0.16, -0.137, 0.05, 0.051, Vector3.BACK],
			[0.19, -0.146, 0.044, 0.046, Vector3(0.0, 0.5, 1.0)],
		]
		head_shift = Vector3(0.0, -0.13, 0.015)
		tail_tip_z = 0.29
	var body := []
	for ring: Array in body_rings:
		body.append(_ring(Vector3(0.0, float(ring[1]), float(ring[0])), Vector3.UP, float(ring[2]), float(ring[3])))
	var tail: Dictionary = body[0]
	var tail_top := float((tail.c as Vector3).y) + float(tail.h)
	var body_paint := func(t: float, up: float, _side: float) -> Color:
		if t < 0.1:
			return GULL_WHITE
		# The narrow white tertial crescent at the back of the grey, on each side.
		if t > 0.205 and t < 0.235 and up > 0.1 and up < 0.6:
			return GULL_WHITE
		# The folded wing covers the upper side down to about its middle, the lower
		# flank white, rising to the top of the shoulder over the white breast.
		var edge := lerpf(0.1, 0.8, smoothstep(0.62, 1.0, t))
		return GULL_MANTLE if up > edge else GULL_WHITE
	var front: Dictionary = body[-1]
	m.loft(body, 12, 2, body_paint, Vector3(0.0, (tail.c as Vector3).y, tail_tip_z), (front.c as Vector3) + Vector3(0.0, 0.023, -0.013))
	# Neck and head in one: up from inside the breast, then forward to a flat crown
	# and a sloping forehead; a head smaller than the body would suggest, the bill
	# big for it.
	var head := []
	for ring: Array in neck_rings:
		head.append(_ring(Vector3(0.0, float(ring[0]), float(ring[1])), ring[4], float(ring[2]), float(ring[3])))
	for ring: Array in [
		[0.3436, -0.1664, 0.0386, 0.0386, Vector3(0.0, 0.9, 0.5)], [0.3537, -0.1858, 0.0378, 0.0353, Vector3.UP],
		[0.3503, -0.2069, 0.0328, 0.0302, Vector3.UP], [0.3428, -0.2263, 0.0235, 0.0227, Vector3(0.0, 1.0, -0.2)],
		[0.336, -0.2404, 0.0151, 0.0168, Vector3(0.0, 1.0, -0.3)],
	]:
		head.append(_ring(Vector3(0.0, float(ring[0]), float(ring[1])) + head_shift, ring[4], float(ring[2]), float(ring[3])))
	m.loft(head, 10, 2, _solid(GULL_WHITE), null, Vector3(0.0, 0.3344, -0.2456) + head_shift)
	# The bill: a deep upper mandible with a hooked tip, and the lower mandible
	# swelling at the gonys, its red spot there.
	var upper := []
	for ring: Array in [[0.3384, -0.2336, 0.011, 0.0105], [0.3374, -0.2576, 0.009, 0.009], [0.3354, -0.2776, 0.0072, 0.0077], [0.3324, -0.2926, 0.0052, 0.0055]]:
		upper.append(_ring(Vector3(0.0, float(ring[0]), float(ring[1])) + head_shift, Vector3.UP, float(ring[2]), float(ring[3])))
	m.loft(upper, 8, 1, _solid(GULL_BILL), null, Vector3(0.0, 0.3244, -0.3056) + head_shift)
	var lower := []
	for ring: Array in [[0.3264, -0.2356, 0.0098, 0.0092], [0.3224, -0.2596, 0.0084, 0.0086], [0.3184, -0.2776, 0.0068, 0.0102], [0.3234, -0.2916, 0.0042, 0.0048]]:
		lower.append(_ring(Vector3(0.0, float(ring[0]), float(ring[1])) + head_shift, Vector3.UP, float(ring[2]), float(ring[3])))
	var gonys := func(t: float, _up: float, _side: float) -> Color:
		return GULL_GONYS if t > 0.45 and t < 0.85 else GULL_BILL
	m.loft(lower, 8, 1, gonys, null, Vector3(0.0, 0.3264, -0.2986) + head_shift)
	# The small pale eye under a heavy brow, its dark pupil.
	for side: float in [1.0, -1.0]:
		var eye := Vector3(0.0311 * side, 0.3612, -0.1999) + head_shift
		_ball(m, eye, 0.004, GULL_IRIS)
		_ball(m, eye + Vector3(0.0032 * side, 0.0004, -0.0011), 0.0016, GULL_PUPIL)
		m.loft([
			_ring(Vector3(0.029 * side, 0.37, -0.1902) + head_shift, Vector3(0.5 * side, 1.0, 0.0), 0.0055, 0.0038),
			_ring(Vector3(0.0298 * side, 0.3692, -0.2016) + head_shift, Vector3(0.5 * side, 1.0, 0.0), 0.0063, 0.0042),
			_ring(Vector3(0.026 * side, 0.3667, -0.2139) + head_shift, Vector3(0.5 * side, 1.0, 0.0), 0.0046, 0.0034),
		], 6, 1, _solid(GULL_WHITE), null, null)
	# The black primaries, from inside the body out over the tail, crossed past it,
	# a small white mirror near the tip: standing, over the tail as the folded wing
	# carries them; sitting, laid flat along the tail.
	var lift := tail_top - 0.221
	var rise := [0.245 + lift, 0.248 + lift, 0.243 + lift, 0.238 + lift, 0.234 + lift]
	if sitting:
		rise = [0.136, 0.132, 0.122, 0.116, 0.112]
	var primaries := func(t: float, up: float, _side: float) -> Color:
		return GULL_MIRROR if t > 0.76 and t < 0.84 and up > 0.3 else GULL_PRIMARY
	for side: float in [1.0, -1.0]:
		var low := 0.0 if side > 0.0 else -0.004
		m.loft([
			_ring(Vector3(0.05 * side, float(rise[0]) + low, 0.06), Vector3.UP, 0.022, 0.006),
			_ring(Vector3(0.042 * side, float(rise[1]) + low, 0.16), Vector3.UP, 0.024, 0.006),
			_ring(Vector3(0.025 * side, float(rise[2]) + low, 0.25), Vector3.UP, 0.018, 0.005),
			_ring(Vector3(0.008 * side, float(rise[3]) + low, 0.31), Vector3.UP, 0.01, 0.004),
		], 6, 2, primaries, null, Vector3(-0.008 * side, float(rise[4]) + low, 0.37))
	if sitting:
		return
	# Thick pink legs from inside the belly, bent at the ankle, to webbed feet flat
	# on the stone; far off they draw in to a point inside the body.
	for side: float in [1.0, -1.0]:
		m.thin_to = 0.2
		m.loft([
			_ring(Vector3(0.028 * side, 0.14, 0.004), Vector3.BACK, 0.0092, 0.0092),
			_ring(Vector3(0.03 * side, 0.075, 0.012), Vector3.BACK, 0.0082, 0.0082),
			_ring(Vector3(0.031 * side, 0.01, 0.0), Vector3.BACK, 0.0075, 0.0075),
		], 6, 1, _solid(GULL_LEG), null, null)
		_foot(m, Vector3(0.031 * side, 0.0, -0.004), 1.15, side, GULL_LEG)
		m.thin_to = NAN


# ------------------------------------------------------------------ double-crested cormorant

## A double-crested cormorant facing -Z, upright on short legs and big webbed
## feet, its stiff tail down to the stone behind, a slim kinked neck and the
## orange skin under its hooked bill; its folded wings painted bronze-brown on its
## back, or held out half open to dry with the wrists high and the hands hanging.
static func _cormorant(m: Mesher, spread: bool) -> void:
	var dorsal := Vector3(0.0, 0.39, 0.92)
	var body := [
		_ring(Vector3(0.0, 0.085, 0.05), dorsal, 0.04, 0.034),
		_ring(Vector3(0.0, 0.13, 0.03), dorsal, 0.072, 0.064),
		_ring(Vector3(0.0, 0.195, 0.005), dorsal, 0.085, 0.078),
		_ring(Vector3(0.0, 0.265, -0.023), dorsal, 0.084, 0.078),
		_ring(Vector3(0.0, 0.325, -0.05), dorsal, 0.074, 0.068),
		_ring(Vector3(0.0, 0.375, -0.073), dorsal, 0.055, 0.052),
		_ring(Vector3(0.0, 0.41, -0.085), dorsal, 0.04, 0.04),
	]
	m.loft(body, 12, 2, _cormorant_paint(), Vector3(0.0, 0.068, 0.058), Vector3(0.0, 0.428, -0.092))
	# The stiff tail, down and back until its tip rests on the stone.
	m.loft([
		_ring(Vector3(0.0, 0.1, 0.062), Vector3(0.0, 0.8, 0.6), 0.03, 0.012),
		_ring(Vector3(0.0, 0.052, 0.125), Vector3(0.0, 0.8, 0.6), 0.026, 0.008),
		_ring(Vector3(0.0, 0.016, 0.18), Vector3(0.0, 0.8, 0.6), 0.02, 0.006),
	], 6, 1, _solid(CORMORANT_FLIGHT), null, Vector3(0.0, 0.0, 0.208))
	_cormorant_head(m, [
		[0.38, -0.07, 0.042, 0.04, Vector3.BACK], [0.435, -0.088, 0.026, 0.03, Vector3.BACK],
		[0.485, -0.083, 0.021, 0.025, Vector3.BACK], [0.53, -0.07, 0.019, 0.022, Vector3.BACK],
		[0.57, -0.07, 0.02, 0.022, Vector3(0.0, 0.3, 1.0)],
	], Vector3.ZERO)
	for side: float in [1.0, -1.0]:
		if spread:
			_spread_wing(m, side)
		m.thin_to = 0.16
		m.loft([
			_ring(Vector3(0.033 * side, 0.13, 0.012), Vector3.BACK, 0.012, 0.012),
			_ring(Vector3(0.035 * side, 0.065, 0.0), Vector3.BACK, 0.009, 0.009),
			_ring(Vector3(0.036 * side, 0.01, -0.006), Vector3.BACK, 0.0085, 0.0085),
		], 5, 1, _solid(CORMORANT_FOOT), null, null)
		_foot(m, Vector3(0.036 * side, 0.0, -0.01), 1.55, side, CORMORANT_FOOT)
		m.thin_to = NAN


## A double-crested cormorant lying low on the stone, as a few do on the Niagara
## rock among the standing birds: its long body down on its belly but still raised
## at the breast, its tail along the stone behind, its neck up in an S and its head
## held high on it, the hooked bill level.
static func _cormorant_sitting(m: Mesher) -> void:
	var body := _axis_body(Vector3(0.0, 0.015, 0.15), 22.0, [
		[0.0, 0.034, 0.028], [0.06, 0.058, 0.052], [0.13, 0.072, 0.066], [0.21, 0.076, 0.07],
		[0.29, 0.07, 0.064], [0.35, 0.055, 0.051], [0.39, 0.04, 0.04],
	])
	m.loft(body, 12, 2, _cormorant_paint(), (body[0].c as Vector3) + Vector3(0.0, -0.006, 0.02), (body[-1].c as Vector3) + Vector3(0.0, 0.006, -0.018))
	m.loft([
		_ring(Vector3(0.0, 0.03, 0.155), Vector3(0.0, 1.0, 0.15), 0.028, 0.008),
		_ring(Vector3(0.0, 0.012, 0.225), Vector3(0.0, 1.0, 0.15), 0.024, 0.006),
		_ring(Vector3(0.0, 0.006, 0.285), Vector3(0.0, 1.0, 0.15), 0.019, 0.005),
	], 6, 1, _solid(CORMORANT_FLIGHT), null, Vector3(0.0, 0.003, 0.32))
	_cormorant_head(m, [
		[0.165, -0.19, 0.042, 0.042, Vector3.BACK], [0.22, -0.212, 0.027, 0.029, Vector3.BACK],
		[0.265, -0.21, 0.021, 0.024, Vector3.BACK], [0.31, -0.196, 0.019, 0.021, Vector3.BACK],
		[0.355, -0.188, 0.02, 0.021, Vector3(0.0, 0.3, 1.0)],
	], Vector3(0.0, -0.215, -0.115))


static func _cormorant_paint() -> Callable:
	return func(t: float, up: float, side: float) -> Color:
		# The bronze-brown, scaled wing coverts on the back.
		if up > 0.3 and absf(side) < 0.95 and t > 0.2 and t < 0.92:
			return CORMORANT_COVERT
		return CORMORANT_BLACK


## A cormorant's neck (`neck`: [y, z, half width, half height, dorsal] rings, up
## from inside its breast), its small head and its slim hooked bill, the head
## `shift` from where a standing bird's is.
static func _cormorant_head(m: Mesher, neck: Array, shift: Vector3) -> void:
	var head_paint := func(t: float, up: float, _side: float) -> Color:
		return CORMORANT_GULAR if t > 0.83 and up < -0.25 else CORMORANT_BLACK
	var rings := []
	for ring: Array in neck:
		rings.append(_ring(Vector3(0.0, float(ring[0]), float(ring[1])), ring[4], float(ring[2]), float(ring[3])))
	for ring: Array in [
		[0.6, -0.09, 0.024, 0.026, Vector3(0.0, 1.0, 0.7)], [0.618, -0.11, 0.026, 0.028, Vector3(0.0, 1.0, 0.2)],
		[0.622, -0.132, 0.023, 0.024, Vector3.UP], [0.616, -0.152, 0.016, 0.018, Vector3.UP],
	]:
		rings.append(_ring(Vector3(0.0, float(ring[0]), float(ring[1])) + shift, ring[4], float(ring[2]), float(ring[3])))
	m.loft(rings, 10, 2, head_paint, null, Vector3(0.0, 0.612, -0.16) + shift)
	# A heavy bill, deep at the base, its tip hooked down.
	var bill_paint := func(t: float, up: float, _side: float) -> Color:
		return CORMORANT_GULAR if t < 0.25 and up < 0.0 else CORMORANT_BILL
	var bill := []
	for ring: Array in [[0.612, -0.146, 0.0115, 0.0125], [0.617, -0.17, 0.008, 0.0092], [0.621, -0.194, 0.0062, 0.0072], [0.623, -0.208, 0.0052, 0.006]]:
		bill.append(_ring(Vector3(0.0, float(ring[0]), float(ring[1])) + shift, Vector3.UP, float(ring[2]), float(ring[3])))
	m.loft(bill, 6, 1, bill_paint, null, Vector3(0.0, 0.613, -0.218) + shift)
	for side: float in [1.0, -1.0]:
		_ball(m, Vector3(0.0215 * side, 0.626, -0.128) + shift, 0.0042, CORMORANT_EYE)


## One spread wing (side +1 the bird's right, +X): a thin sheet between its
## leading edge (shoulder, up and out to the high wrist, then down the outer
## primary) and its trailing edge, the feather tips uneven and the outer
## primaries parted.
static func _spread_wing(m: Mesher, side: float) -> void:
	var leading := PackedVector3Array([
		Vector3(0.05, 0.37, -0.058), Vector3(0.13, 0.43, -0.054), Vector3(0.23, 0.482, -0.044),
		Vector3(0.31, 0.44, -0.03), Vector3(0.37, 0.36, -0.016), Vector3(0.41, 0.25, -0.004),
	])
	var trailing := PackedVector3Array([
		Vector3(0.055, 0.245, 0.0), Vector3(0.1, 0.195, 0.015), Vector3(0.16, 0.165, 0.024),
		Vector3(0.23, 0.155, 0.027), Vector3(0.29, 0.165, 0.023), Vector3(0.35, 0.188, 0.015),
		Vector3(0.4, 0.232, 0.005),
	])
	# How far each column's feather tip falls short of the trailing edge, as a share
	# of the wing's depth there: uneven, deepest between the outer primaries.
	var short := [0.0, 0.06, 0.02, 0.1, 0.03, 0.12, 0.04, 0.08, 0.0, 0.15, 0.03, 0.18, 0.0]
	var columns := short.size()
	var rows := 4
	var lead := Mesher.resample(leading, columns)
	var trail := Mesher.resample(trailing, columns)
	var grid: Array[PackedVector3Array] = []
	for row in rows:
		var v := float(row) / float(rows - 1)
		var line := PackedVector3Array()
		for column in columns:
			var front := lead[column]
			var back := trail[column]
			if row == rows - 1:
				back = back.lerp(front, float(short[column]))
			var point := front.lerp(back, v)
			# A slight cup, the inner feathers bowed back.
			point.z += 0.018 * sin(PI * v) * (1.0 - float(column) / float(columns - 1))
			line.append(Vector3(point.x * side, point.y, point.z))
		grid.append(line)
	var paint := func(_u: float, v: float, front: bool) -> Color:
		return CORMORANT_COVERT if v < 0.34 and front else CORMORANT_FLIGHT
	m.sheet(grid, 0.009, Vector3(0.0, 0.0, -1.0), paint)


# ------------------------------------------------------------------ brown pelican

## The pelican's body along its axis: [distance from the tail's tip, half width,
## half height]; lying down, a taller, narrower dome (the back raised over the
## folded wings, as on the Pismo Beach pier photo).
const PELICAN_BODY := [
	[0.0, 0.03, 0.02], [0.06, 0.075, 0.045], [0.14, 0.12, 0.085], [0.24, 0.148, 0.115],
	[0.34, 0.158, 0.128], [0.44, 0.15, 0.126], [0.52, 0.126, 0.11], [0.58, 0.09, 0.084],
]
const PELICAN_SITTING_BODY := [
	[0.0, 0.028, 0.024], [0.06, 0.07, 0.054], [0.14, 0.113, 0.102], [0.24, 0.139, 0.138],
	[0.34, 0.149, 0.154], [0.44, 0.141, 0.151], [0.52, 0.118, 0.132], [0.58, 0.085, 0.1],
]

## A brown pelican facing -Z (drawn here PELICAN_SIZE times smaller than it
## stands): "out", on short stout legs with its breast raised, its slim neck up in
## an S and the long bill held down in front of it; "tucked", crouched low with the
## neck folded and the head laid back on the shoulders, the bill under the
## scapulars; "sitting", lying on its belly with its head on its shoulders and the
## bill laid down its breast (the Pismo Beach pier photo). The folded wings are
## painted silvery on the back, the dark primaries crossed over the tail.
static func _pelican(m: Mesher, pose: String) -> void:
	var origin := Vector3(0.0, 0.02, 0.33)
	var lean := 32.0
	if pose == "tucked":
		origin = Vector3(0.0, 0.115, 0.33)
		lean = 8.0
	elif pose == "sitting":
		origin = Vector3(0.0, 0.125, 0.33)
		lean = 4.0
	var body := _axis_body(origin, lean, PELICAN_SITTING_BODY if pose == "sitting" else PELICAN_BODY)
	var axis := Vector3(0.0, sin(deg_to_rad(lean)), -cos(deg_to_rad(lean)))
	var dorsal := Vector3(0.0, cos(deg_to_rad(lean)), sin(deg_to_rad(lean)))
	var body_paint := func(t: float, up: float, _side: float) -> Color:
		if up < -0.45:
			return PELICAN_BELLY
		if up < -0.15:
			return PELICAN_BELLY.lerp(PELICAN_BACK, (up + 0.45) / 0.3)
		# The dark secondaries and tail at the back.
		if t < 0.2:
			return PELICAN_PRIMARY.lerp(PELICAN_BACK, t / 0.2)
		return PELICAN_BACK
	m.loft(body, 12, 2, body_paint, origin - axis * 0.02, origin + axis * 0.64)
	# The dark primaries, from inside the body out over the tail, crossed at its tip.
	for side: float in [1.0, -1.0]:
		var low := 0.0 if side > 0.0 else -0.005
		var rings := []
		for step: Array in [[0.2, 0.08, 0.08], [0.1, 0.06, 0.075], [0.02, 0.03, 0.052], [-0.04, 0.01, 0.042]]:
			rings.append(_ring(origin + axis * float(step[0]) + Vector3(float(step[1]) * side, 0.0, 0.0) + dorsal * (float(step[2]) + low), dorsal, lerpf(0.012, 0.035, clampf(float(step[0]) / 0.2, 0.0, 1.0)), 0.008))
		m.loft(rings, 6, 2, _solid(PELICAN_PRIMARY), null, origin - axis * 0.09 + Vector3(-0.008 * side, 0.0, 0.0) + dorsal * (0.036 + low))
	var neck_paint := func(t: float, up: float, _side: float) -> Color:
		# White in front, a dark stripe down the hindneck, the white head with its
		# yellow-washed crown. Tucked, the hindneck shows only as a narrow dark patch
		# on the front of the fold under the head, not a band round it.
		if t > 0.6:
			return PELICAN_CROWN if up > 0.45 and t < 0.9 else PELICAN_WHITE
		if pose == "tucked":
			return PELICAN_HINDNECK if up > 0.88 and t > 0.12 and t < 0.5 else PELICAN_WHITE
		return PELICAN_HINDNECK if up > 0.62 else PELICAN_WHITE
	match pose:
		"tucked":
			# The neck folded up from the breast and back over the shoulders, the head
			# lying on them facing back: the hindneck is the outside of the fold, so
			# its dark stripe shows at the front, under the head.
			m.loft([
				_ring(Vector3(0.0, 0.205, -0.24), Vector3(0.0, 0.2, -1.0), 0.08, 0.075),
				_ring(Vector3(0.0, 0.265, -0.262), Vector3(0.0, 0.3, -1.0), 0.074, 0.07),
				_ring(Vector3(0.0, 0.32, -0.245), Vector3(0.0, 0.8, -0.6), 0.069, 0.065),
				_ring(Vector3(0.0, 0.347, -0.2), Vector3(0.0, 1.0, -0.1), 0.064, 0.06),
				_ring(Vector3(0.0, 0.353, -0.155), Vector3.UP, 0.058, 0.052),
				_ring(Vector3(0.0, 0.351, -0.115), Vector3.UP, 0.055, 0.05),
				_ring(Vector3(0.0, 0.345, -0.08), Vector3.UP, 0.046, 0.044),
				_ring(Vector3(0.0, 0.336, -0.055), Vector3.UP, 0.032, 0.032),
			], 10, 2, neck_paint, null, Vector3(0.0, 0.332, -0.042))
			# The bill laid back along the shoulders, sinking under the scapulars.
			_pelican_bill(m, Vector3(0.0, 0.338, -0.05), Vector3(0.0, -0.6, 1.0).normalized(), Vector3(0.0, 1.0, 0.6).normalized(), 0.3)
			_pelican_eyes(m, Vector3(0.039, 0.353, -0.072))
		"sitting":
			# The head resting on the shoulders, the bill laid down the breast.
			m.loft([
				_ring(Vector3(0.0, 0.235, -0.205), Vector3(0.0, 0.3, 1.0), 0.078, 0.074),
				_ring(Vector3(0.0, 0.305, -0.24), Vector3(0.0, 0.2, 1.0), 0.064, 0.062),
				_ring(Vector3(0.0, 0.36, -0.235), Vector3(0.0, 0.5, 1.0), 0.056, 0.055),
				_ring(Vector3(0.0, 0.398, -0.215), Vector3(0.0, 1.0, 0.5), 0.051, 0.05),
				_ring(Vector3(0.0, 0.41, -0.235), Vector3.UP, 0.048, 0.047),
				_ring(Vector3(0.0, 0.402, -0.258), Vector3(0.0, 1.0, -0.4), 0.04, 0.04),
				_ring(Vector3(0.0, 0.386, -0.278), Vector3(0.0, 1.0, -0.7), 0.028, 0.03),
			], 10, 2, neck_paint, null, Vector3(0.0, 0.378, -0.29))
			_pelican_bill(m, Vector3(0.0, 0.383, -0.27), Vector3(0.0, -0.906, -0.423), Vector3(0.0, 0.423, -0.906), 0.3)
			_pelican_eyes(m, Vector3(0.036, 0.408, -0.25))
		_:
			# The slim neck up from the breast in an S, the long head on top.
			m.loft([
				_ring(Vector3(0.0, 0.32, -0.12), Vector3(0.0, 0.2, 1.0), 0.075, 0.07),
				_ring(Vector3(0.0, 0.38, -0.17), Vector3(0.0, 0.1, 1.0), 0.058, 0.056),
				_ring(Vector3(0.0, 0.45, -0.19), Vector3.BACK, 0.047, 0.046),
				_ring(Vector3(0.0, 0.52, -0.175), Vector3.BACK, 0.042, 0.042),
				_ring(Vector3(0.0, 0.58, -0.145), Vector3.BACK, 0.04, 0.041),
				_ring(Vector3(0.0, 0.63, -0.13), Vector3(0.0, 0.5, 1.0), 0.042, 0.044),
				_ring(Vector3(0.0, 0.683, -0.148), Vector3(0.0, 1.0, 0.2), 0.049, 0.048),
				_ring(Vector3(0.0, 0.684, -0.178), Vector3(0.0, 1.0, -0.1), 0.044, 0.043),
				_ring(Vector3(0.0, 0.671, -0.204), Vector3(0.0, 1.0, -0.3), 0.036, 0.036),
				_ring(Vector3(0.0, 0.654, -0.225), Vector3(0.0, 1.0, -0.5), 0.026, 0.028),
			], 10, 2, neck_paint, null, Vector3(0.0, 0.647, -0.236))
			# The bill held down in front of the neck, about 52 degrees below level.
			_pelican_bill(m, Vector3(0.0, 0.656, -0.215), Vector3(0.0, -0.788, -0.616), Vector3(0.0, 0.616, -0.788), 0.32)
			_pelican_eyes(m, Vector3(0.032, 0.678, -0.198))
	if pose == "sitting":
		return
	# Short stout legs and broad webbed feet; far off they draw in to a point
	# inside the body.
	var hip := 0.07 if pose == "tucked" else 0.11
	for side: float in [1.0, -1.0]:
		m.thin_to = 0.15 if pose == "tucked" else 0.2
		m.loft([
			_ring(Vector3(0.062 * side, hip, 0.03), Vector3.BACK, 0.024, 0.024),
			_ring(Vector3(0.068 * side, hip * 0.5, 0.0), Vector3.BACK, 0.02, 0.02),
			_ring(Vector3(0.074 * side, 0.012, -0.012), Vector3.BACK, 0.018, 0.018),
		], 6, 1, _solid(PELICAN_LEG), null, null)
		_foot(m, Vector3(0.075 * side, 0.0, -0.018), 2.0, side, PELICAN_LEG)
		m.thin_to = NAN


## A pelican's pale eyes with their dark pupils, mirrored about x = 0.
static func _pelican_eyes(m: Mesher, right: Vector3) -> void:
	for side: float in [1.0, -1.0]:
		var eye := Vector3(right.x * side, right.y, right.z)
		_ball(m, eye, 0.006, PELICAN_EYE)
		_ball(m, eye + Vector3(0.0045 * side, 0.0, -0.0015), 0.0022, GULL_PUPIL)


## The pelican's bill from `base` along `direction` for `length`: the flat upper
## mandible (culmen toward `top`) ending in the orange hook, and the pouch hung
## below it, deep at the base and narrowing to the tip.
static func _pelican_bill(m: Mesher, base: Vector3, direction: Vector3, top: Vector3, length: float) -> void:
	var scale := length / 0.3
	var mandible := []
	for step: Array in [[0.0, 0.024, 0.012], [0.06, 0.021, 0.011], [0.14, 0.018, 0.01], [0.22, 0.015, 0.009], [0.28, 0.012, 0.008]]:
		mandible.append(_ring(base + direction * float(step[0]) * scale, top, float(step[1]), float(step[2])))
	var mandible_paint := func(t: float, _up: float, _side: float) -> Color:
		return PELICAN_BILL_TIP if t > 0.9 else PELICAN_BILL
	m.loft(mandible, 8, 1, mandible_paint, null, base + direction * length * 1.02 - top * 0.013)
	var pouch := []
	for step: Array in [[0.02, 0.016, 0.03], [0.1, 0.014, 0.026], [0.18, 0.011, 0.018], [0.25, 0.008, 0.01], [0.285, 0.005, 0.005]]:
		var depth := float(step[2])
		pouch.append(_ring(base + direction * float(step[0]) * scale - top * (0.008 + depth), top, float(step[1]), depth))
	m.loft(pouch, 8, 1, _solid(PELICAN_POUCH), null, base + direction * length * 0.98 - top * 0.01)


# ------------------------------------------------------------------ shared parts

static func _ring(centre: Vector3, up: Vector3, half_width: float, half_height: float) -> Dictionary:
	return {"c": centre, "u": up.normalized(), "w": half_width, "h": half_height}


static func _solid(color: Color) -> Callable:
	return func(_t: float, _up: float, _side: float) -> Color: return color


## A body's rings along an axis from `origin` (its tail end), leaning up
## `lean_deg` toward -Z: `profile` is [distance along the axis, half width, half
## height] per ring, the dorsal side square to the axis, up and back.
static func _axis_body(origin: Vector3, lean_deg: float, profile: Array) -> Array:
	var lean := deg_to_rad(lean_deg)
	var axis := Vector3(0.0, sin(lean), -cos(lean))
	var dorsal := Vector3(0.0, cos(lean), sin(lean))
	var rings := []
	for ring: Array in profile:
		rings.append(_ring(origin + axis * float(ring[0]), dorsal, float(ring[1]), float(ring[2])))
	return rings


## A small ball (an eye, a pupil) at `centre`, of `radius`.
static func _ball(m: Mesher, centre: Vector3, radius: float, color: Color) -> void:
	m.loft([
		_ring(centre + Vector3(-radius * 0.7, 0.0, 0.0), Vector3.UP, radius * 0.71, radius * 0.71),
		_ring(centre, Vector3.UP, radius, radius),
		_ring(centre + Vector3(radius * 0.7, 0.0, 0.0), Vector3.UP, radius * 0.71, radius * 0.71),
	], 6, 1, _solid(color), centre - Vector3(radius, 0.0, 0.0), centre + Vector3(radius, 0.0, 0.0))


## A webbed foot flat on y = 0 at `heel`, toes forward (-Z), `size` times a
## gull's (about 6 cm long), mirrored for the left foot. Records where it rests.
static func _foot(m: Mesher, heel: Vector3, size: float, side: float, color: Color) -> void:
	var outline := PackedVector2Array()
	for corner: Vector2 in [
		Vector2(-0.006, 0.01), Vector2(0.008, 0.009), Vector2(0.024, -0.04), Vector2(0.012, -0.031),
		Vector2(0.002, -0.054), Vector2(-0.008, -0.031), Vector2(-0.02, -0.042),
	]:
		outline.append(Vector2(heel.x + corner.x * size * side, heel.z + corner.y * size))
	m.flat(outline, heel.y, 0.005 * maxf(1.0, size * 0.7), color)
	var centre := Vector2.ZERO
	for corner: Vector2 in outline:
		centre += corner
	centre /= float(outline.size())
	var radius := 0.0
	for corner: Vector2 in outline:
		radius = maxf(radius, centre.distance_to(corner))
	m.contacts.append({"at": Vector3(centre.x, 0.0, centre.y), "r": radius})


class Mesher:
	extends RefCounted
	var points := PackedVector3Array()
	var normals := PackedVector3Array()
	var colors := PackedColorArray()
	var uv2s := PackedVector2Array()
	var indices := PackedInt32Array()
	## Where the model rests: [{at, r}] (the feet).
	var contacts: Array[Dictionary] = []
	## While set, added vertices belong to a thin part (legs, feet) that far off
	## draws in to one point this high (bird units) over the feet, inside the body:
	## UV2 (1, the height). NAN: not thin.
	var thin_to := NAN

	func add(point: Vector3, color: Color) -> int:
		points.append(point)
		normals.append(Vector3.ZERO)
		colors.append(color)
		uv2s.append(Vector2.ZERO if is_nan(thin_to) else Vector2(1.0, thin_to))
		return points.size() - 1

	## One triangle whose front faces `outward` (wound as the kits' Builder.triangle
	## winds Godot's fronts); its area-weighted normal goes to its corners.
	func tri(a: int, b: int, c: int, outward: Vector3) -> void:
		var normal := (points[b] - points[a]).cross(points[c] - points[a])
		if normal.dot(outward) > 0.0:
			indices.append_array(PackedInt32Array([a, c, b]))
		else:
			indices.append_array(PackedInt32Array([a, b, c]))
			normal = -normal
		normals[a] += normal
		normals[b] += normal
		normals[c] += normal

	## A tube through `rings` ({c, u, w, h}: centre, dorsal direction, half width and
	## half height), `steps` rings per span (Catmull-Rom between them), `sides`
	## round. paint(t, up, side) colours a vertex: t from 0 at the first ring to 1 at
	## the last, up and side the sine and cosine of its angle round the ring (up
	## toward u). Each end closes on a tip point (start_tip, end_tip) or, given
	## null, a flat cap.
	func loft(rings: Array, sides: int, steps: int, paint: Callable, start_tip: Variant, end_tip: Variant) -> void:
		var fine := Mesher.refine(rings, steps)
		var count := fine.size()
		var rows: Array[PackedInt32Array] = []
		var centres := PackedVector3Array()
		var tangents := PackedVector3Array()
		for index in count:
			var ring: Dictionary = fine[index]
			var centre: Vector3 = ring.c
			var tangent := ((fine[mini(index + 1, count - 1)].c as Vector3) - (fine[maxi(index - 1, 0)].c as Vector3)).normalized()
			var up: Vector3 = ring.u
			up = (up - tangent * up.dot(tangent)).normalized()
			var across := tangent.cross(up).normalized()
			var t := float(index) / float(count - 1)
			var row := PackedInt32Array()
			for step in sides:
				var angle := TAU * float(step) / float(sides)
				var rise := sin(angle)
				var lateral := cos(angle)
				row.append(add(centre + across * (lateral * float(ring.w)) + up * (rise * float(ring.h)), paint.call(t, rise, lateral)))
			rows.append(row)
			centres.append(centre)
			tangents.append(tangent)
		for index in range(1, count):
			var middle := (centres[index - 1] + centres[index]) * 0.5
			for step in sides:
				var a := rows[index - 1][step]
				var b := rows[index - 1][(step + 1) % sides]
				var c := rows[index][(step + 1) % sides]
				var d := rows[index][step]
				var outward := (points[a] + points[b] + points[c] + points[d]) * 0.25 - middle
				tri(a, b, c, outward)
				tri(a, c, d, outward)
		_close(rows[0], centres[0], -tangents[0], start_tip, paint.call(0.0, 0.0, 0.0))
		_close(rows[count - 1], centres[count - 1], tangents[count - 1], end_tip, paint.call(1.0, 0.0, 0.0))

	func _close(row: PackedInt32Array, centre: Vector3, out: Vector3, tip: Variant, color: Color) -> void:
		var hub := add(tip if tip is Vector3 else centre, color)
		var inner := centre - out * 0.005
		for step in row.size():
			var a := row[step]
			var b := row[(step + 1) % row.size()]
			tri(hub, a, b, (points[a] + points[b] + points[hub]) / 3.0 - inner)

	## A thin plate lying flat: `outline` (x, z) from y = bottom up `thickness`.
	func flat(outline: PackedVector2Array, bottom: float, thickness: float, color: Color) -> void:
		var triangles := Geometry2D.triangulate_polygon(outline)
		var centre := Vector2.ZERO
		for corner: Vector2 in outline:
			centre += corner
		centre /= float(outline.size())
		for face: float in [1.0, 0.0]:
			var y := bottom + thickness * face
			var first := points.size()
			for corner: Vector2 in outline:
				add(Vector3(corner.x, y, corner.y), color)
			var outward := Vector3.UP if face > 0.5 else Vector3.DOWN
			for index in range(0, triangles.size(), 3):
				tri(first + triangles[index], first + triangles[index + 1], first + triangles[index + 2], outward)
		for index in outline.size():
			var p := outline[index]
			var q := outline[(index + 1) % outline.size()]
			var a := add(Vector3(p.x, bottom, p.y), color)
			var b := add(Vector3(q.x, bottom, q.y), color)
			var c := add(Vector3(q.x, bottom + thickness, q.y), color)
			var d := add(Vector3(p.x, bottom + thickness, p.y), color)
			var middle := (p + q) * 0.5 - centre
			var outward := Vector3(middle.x, 0.0, middle.y)
			tri(a, b, c, outward)
			tri(a, c, d, outward)

	## A thin curved sheet through `grid` (rows of equal length), `thickness` thick:
	## a face each side (the front toward `facing`) and a rim round its edge.
	## paint(u, v, front) colours it: u across the columns, v down the rows.
	func sheet(grid: Array[PackedVector3Array], thickness: float, facing: Vector3, paint: Callable) -> void:
		var rows := grid.size()
		var columns := grid[0].size()
		var middle := Vector3.ZERO
		var lay := []
		for row in rows:
			var line := []
			for column in columns:
				var du := grid[row][mini(column + 1, columns - 1)] - grid[row][maxi(column - 1, 0)]
				var dv := grid[mini(row + 1, rows - 1)][column] - grid[maxi(row - 1, 0)][column]
				var normal := du.cross(dv).normalized()
				if normal.dot(facing) < 0.0:
					normal = -normal
				line.append(normal)
				middle += grid[row][column]
			lay.append(line)
		middle /= float(rows * columns)
		var faces := {}
		for front: bool in [true, false]:
			var sign := 1.0 if front else -1.0
			var ids := []
			for row in rows:
				var line := PackedInt32Array()
				for column in columns:
					var normal: Vector3 = lay[row][column]
					line.append(add(grid[row][column] + normal * (0.5 * thickness * sign), paint.call(float(column) / float(columns - 1), float(row) / float(rows - 1), front)))
				ids.append(line)
			faces[front] = ids
			for row in range(1, rows):
				for column in range(1, columns):
					var a: int = ids[row - 1][column - 1]
					var b: int = ids[row - 1][column]
					var c: int = ids[row][column]
					var d: int = ids[row][column - 1]
					var outward: Vector3 = (lay[row][column] as Vector3) * sign
					tri(a, b, c, outward)
					tri(a, c, d, outward)
		# The rim, round the edge: top row, last column, bottom row, first column.
		var ring := []
		for column in columns:
			ring.append(Vector2i(0, column))
		for row in range(1, rows):
			ring.append(Vector2i(row, columns - 1))
		for column in range(columns - 2, -1, -1):
			ring.append(Vector2i(rows - 1, column))
		for row in range(rows - 2, 0, -1):
			ring.append(Vector2i(row, 0))
		for index in ring.size():
			var p: Vector2i = ring[index]
			var q: Vector2i = ring[(index + 1) % ring.size()]
			var u := float(p.y) / float(columns - 1)
			var v := float(p.x) / float(rows - 1)
			var front_p := add(points[faces[true][p.x][p.y]], paint.call(u, v, true))
			var front_q := add(points[faces[true][q.x][q.y]], paint.call(u, v, true))
			var back_q := add(points[faces[false][q.x][q.y]], paint.call(u, v, false))
			var back_p := add(points[faces[false][p.x][p.y]], paint.call(u, v, false))
			var outward := (points[front_p] + points[front_q]) * 0.5 - middle
			tri(front_p, front_q, back_q, outward)
			tri(front_p, back_q, back_p, outward)

	## Scales the whole model about its feet: its points, the point its thin parts
	## draw in to and where it rests.
	func scale_all(factor: float) -> void:
		for index in points.size():
			points[index] = points[index] * factor
			uv2s[index] = Vector2(uv2s[index].x, uv2s[index].y * factor)
		for contact: Dictionary in contacts:
			contact.at = (contact.at as Vector3) * factor
			contact.r = float(contact.r) * factor

	## Where a bird lying on the stone rests: the middle of its points within 2 mm of
	## it and the radius round them.
	func belly() -> Dictionary:
		var low := PackedVector3Array()
		for point: Vector3 in points:
			if point.y <= 0.002:
				low.append(Vector3(point.x, 0.0, point.z))
		var centre := Vector3.ZERO
		for point: Vector3 in low:
			centre += point
		centre /= maxf(1.0, float(low.size()))
		var radius := 0.0
		for point: Vector3 in low:
			radius = maxf(radius, centre.distance_to(point))
		return {"at": centre, "r": radius}

	## Lowers the model, and the point its thin parts draw in to, until its lowest
	## point is at y = 0.
	func settle() -> void:
		var lowest := INF
		for point: Vector3 in points:
			lowest = minf(lowest, point.y)
		for index in points.size():
			points[index] = Vector3(points[index].x, points[index].y - lowest, points[index].z)
			if uv2s[index].x > 0.5:
				uv2s[index] = Vector2(1.0, uv2s[index].y - lowest)

	## Raises every point below `y` to it.
	func floor_at(y: float) -> void:
		for index in points.size():
			if points[index].y < y:
				points[index] = Vector3(points[index].x, y, points[index].z)

	## The mesh arrays, normals normalized.
	func arrays() -> Array:
		var finished := PackedVector3Array()
		finished.resize(normals.size())
		for index in normals.size():
			var normal := normals[index]
			finished[index] = normal.normalized() if normal.length_squared() > 1e-20 else Vector3.UP
		var made := []
		made.resize(Mesh.ARRAY_MAX)
		made[Mesh.ARRAY_VERTEX] = points
		made[Mesh.ARRAY_NORMAL] = finished
		made[Mesh.ARRAY_COLOR] = colors
		made[Mesh.ARRAY_TEX_UV2] = uv2s
		made[Mesh.ARRAY_INDEX] = indices
		return made

	## Rings refined `steps` times per span: Catmull-Rom centres, widths and
	## heights, dorsal directions blended.
	static func refine(rings: Array, steps: int) -> Array:
		if steps <= 1 or rings.size() < 2:
			return rings
		var fine := []
		var count := rings.size()
		for index in count - 1:
			var r0: Dictionary = rings[maxi(index - 1, 0)]
			var r1: Dictionary = rings[index]
			var r2: Dictionary = rings[index + 1]
			var r3: Dictionary = rings[mini(index + 2, count - 1)]
			for step in steps:
				var f := float(step) / float(steps)
				fine.append({
					"c": (r1.c as Vector3).cubic_interpolate(r2.c, r0.c, r3.c, f),
					"u": (r1.u as Vector3).lerp(r2.u, f).normalized(),
					"w": maxf(0.001, cubic_interpolate(float(r1.w), float(r2.w), float(r0.w), float(r3.w), f)),
					"h": maxf(0.001, cubic_interpolate(float(r1.h), float(r2.h), float(r0.h), float(r3.h), f)),
				})
		fine.append(rings[count - 1])
		return fine

	## `count` points evenly along a polyline's length (Catmull-Rom through it).
	static func resample(line: PackedVector3Array, count: int) -> PackedVector3Array:
		var lengths := PackedFloat32Array([0.0])
		for index in range(1, line.size()):
			lengths.append(lengths[index - 1] + line[index].distance_to(line[index - 1]))
		var total := lengths[line.size() - 1]
		var made := PackedVector3Array()
		var segment := 0
		for step in count:
			var at := total * float(step) / float(count - 1)
			while segment < line.size() - 2 and lengths[segment + 1] < at:
				segment += 1
			var span := maxf(lengths[segment + 1] - lengths[segment], 1e-6)
			var f := clampf((at - lengths[segment]) / span, 0.0, 1.0)
			made.append(line[segment].cubic_interpolate(line[segment + 1], line[maxi(segment - 1, 0)], line[mini(segment + 2, line.size() - 1)], f))
		return made
