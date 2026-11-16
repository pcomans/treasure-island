class_name BreakwaterBirds
extends RefCounted
## Brown pelicans, double-crested cormorants and western gulls resting on the ferry
## terminal's breakwater (frozen OSM w1011830371, the wall ferry_terminal.gd builds
## in the water NW of the float). Owner, 2026-11-15: "There are usually three types
## of birds sitting on the breakwater. Pelicans, cormorants, and seagulls"; the
## Commons photos of the new breakwater (7 Aug 2021) show loose rows of dark birds
## along its cap, with gaps. Two models each (owner, 2026-11-15): the pelican with
## its bill out and with it tucked, the cormorant with its wings folded and with
## them spread to dry, the gull standing and sitting low with its legs folded.
##
## Forms, sizes and colours are production inference from public photos of the
## species (shape, proportion, posture and colour only): a Pacific brown pelican
## about 0.78 m to the crown with its bill out, the bill 0.32 m; a double-crested
## cormorant 0.65 m upright, 0.82 m across its spread wings; a western gull 0.39 m
## standing. Adults, one plumage each. Plumage is vertex colour, one material for
## all (breakwater_birds.gdshader); no texture.
##
## Placement is a rule (place()), seeded so it is the same every run: each species
## gathers in clusters along the cap (centres at random along its length, a
## Poisson number of birds round each, spread normally along it), so there are
## bunches, rows and gaps; gulls in many small loose clusters, cormorants in a few
## long ones, pelicans in a few small bunches; where clusters overlap the species
## mix. A cluster mostly faces one way, most clusters into the prevailing westerly,
## and each bird turns a little from it or, now and then, its own way. Every bird
## keeps its feet on the cap, and no two birds' footprints (the capsule round each
## pose's plan-view outline, spread wings included) come within CLEARANCE_M of each
## other: a bird that would is moved along the cap, or left out.
##
## Scenery: no collision, no sound, no motion. The breakwater lies 79 to 93 m off
## the float, the pier and the island's edge, beyond the 10 m a lifted player may
## float from the shore (recovery_controller.gd), so no player or car reaches them.

const SHADER := preload("res://game/resources/materials/world/birds/breakwater_birds.gdshader")

## The six models, two per species (owner, 2026-11-15).
const POSES := [
	"pelican_bill_out", "pelican_bill_tucked",
	"cormorant_wings_folded", "cormorant_wings_spread",
	"gull_standing", "gull_sitting",
]
const SPECIES_ORDER := ["pelican", "cormorant", "gull"]

## The rule's seed and its numbers (production inference: the 2021 photos and the
## owner's "usually three types" set the character, not counts). Each species:
## how many clusters, the mean number of birds in one and its bounds, how far its
## birds spread along the cap (standard deviation, m), its poses with their
## weights, the share of clusters facing into the wind, the share of a cluster's
## birds facing its way, and the spread of sizes.
const SEED := 1115
const SPECIES := {
	"pelican": {"clusters": 4, "mean": 3.2, "min": 1, "max": 6, "spread_m": 2.2,
		"poses": [["pelican_bill_out", 0.6], ["pelican_bill_tucked", 0.4]],
		"into_wind": 0.6, "follow": 0.8, "scale_sd": 0.035},
	"cormorant": {"clusters": 5, "mean": 6.5, "min": 2, "max": 12, "spread_m": 3.6,
		"poses": [["cormorant_wings_folded", 0.75], ["cormorant_wings_spread", 0.25]],
		"into_wind": 0.6, "follow": 0.8, "scale_sd": 0.04},
	"gull": {"clusters": 10, "mean": 1.6, "min": 1, "max": 4, "spread_m": 6.0,
		"poses": [["gull_standing", 0.55], ["gull_sitting", 0.45]],
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
const NUDGES := 12

## Drawn to this far from the breakwater's middle (and out to the margin past it):
## the ferry plaza, the pier and the west shore near them, not the far island.
const VISIBLE_TO_M := 420.0
const VISIBLE_MARGIN_M := 30.0

## Colours (sRGB; alpha is gloss). Western gull.
const GULL_WHITE := Color(0.93, 0.94, 0.94, 0.0)
const GULL_MANTLE := Color(0.35, 0.37, 0.41, 0.0)
const GULL_PRIMARY := Color(0.07, 0.07, 0.08, 0.1)
const GULL_MIRROR := Color(0.9, 0.9, 0.9, 0.0)
const GULL_BILL := Color(0.96, 0.8, 0.26, 0.9)
const GULL_GONYS := Color(0.86, 0.22, 0.12, 0.9)
const GULL_LEG := Color(0.87, 0.63, 0.6, 0.6)
const GULL_EYE := Color(0.24, 0.2, 0.12, 0.9)
## Double-crested cormorant.
const CORMORANT_BLACK := Color(0.06, 0.065, 0.06, 0.35)
const CORMORANT_COVERT := Color(0.2, 0.18, 0.13, 0.25)
const CORMORANT_FLIGHT := Color(0.1, 0.09, 0.08, 0.15)
const CORMORANT_GULAR := Color(0.95, 0.58, 0.18, 0.6)
const CORMORANT_BILL := Color(0.3, 0.29, 0.27, 0.8)
const CORMORANT_EYE := Color(0.12, 0.6, 0.52, 1.0)
const CORMORANT_FOOT := Color(0.07, 0.07, 0.07, 0.4)
## Brown pelican (a Pacific adult: the head white with a yellow wash, a dark
## hindneck, silvery grey-brown back, dark belly and wing tips).
const PELICAN_WHITE := Color(0.95, 0.94, 0.9, 0.0)
const PELICAN_CROWN := Color(0.95, 0.86, 0.58, 0.0)
const PELICAN_HINDNECK := Color(0.33, 0.2, 0.12, 0.0)
const PELICAN_BACK := Color(0.56, 0.53, 0.49, 0.05)
const PELICAN_STREAK := Color(0.4, 0.37, 0.33, 0.05)
const PELICAN_BELLY := Color(0.2, 0.17, 0.14, 0.0)
const PELICAN_PRIMARY := Color(0.13, 0.11, 0.1, 0.1)
const PELICAN_BILL := Color(0.72, 0.66, 0.6, 0.7)
const PELICAN_BILL_TIP := Color(0.85, 0.45, 0.25, 0.8)
const PELICAN_POUCH := Color(0.33, 0.32, 0.27, 0.5)
const PELICAN_LEG := Color(0.17, 0.17, 0.17, 0.4)
const PELICAN_EYE := Color(0.3, 0.3, 0.28, 0.9)

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
	for species: String in SPECIES_ORDER:
		counts[species] = 0
	for pose: String in POSES:
		var mine := placements.filter(func(bird: Dictionary) -> bool: return bird.pose == pose)
		if mine.is_empty():
			continue
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.use_custom_data = true
		multimesh.mesh = mesh(pose)
		multimesh.instance_count = mine.size()
		for index in mine.size():
			var bird: Dictionary = mine[index]
			var at: Vector3 = bird.position
			multimesh.set_instance_transform(index, Transform3D(turn(float(bird.yaw), float(bird.scale)), at - middle))
			# The shader reads the bird's world position and size (its distance and tone).
			multimesh.set_instance_custom_data(index, Color(at.x, at.y, at.z, float(bird.scale)))
			counts[str(bird.species)] += 1
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
	node.set_meta("species_counts", counts)
	return node


## A bird's turn about +Y (it faces -Z at yaw 0) and size: its instance basis.
static func turn(yaw: float, size: float) -> Basis:
	return Basis(Vector3.UP, yaw).scaled(Vector3.ONE * size)


## The placement rule: [{species, pose, position (world, its feet's level on the
## cap), yaw (radians about +Y; 0 faces -Z), scale}], in the order placed. The
## same arguments always give the same birds.
static func place(a: Vector2, b: Vector2, cap_y: float, half_width: float, seed: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var length := a.distance_to(b)
	var along := (b - a) / length
	var across := Vector2(-along.y, along.x)
	var wind_yaw := _yaw_facing(-WIND_TOWARD)
	var candidates: Array[Dictionary] = []
	for species: String in SPECIES_ORDER:
		var rule: Dictionary = SPECIES[species]
		for _cluster in int(rule.clusters):
			var centre := rng.randf_range(END_MARGIN_M, length - END_MARGIN_M)
			var heading := wind_yaw if rng.randf() < float(rule.into_wind) else rng.randf_range(-PI, PI)
			var count := clampi(_poisson(rng, float(rule.mean)), int(rule.min), int(rule.max))
			for _bird in count:
				var yaw := heading + deg_to_rad(rng.randfn(0.0, HEADING_SD_DEG))
				if rng.randf() >= float(rule.follow):
					yaw = rng.randf_range(-PI, PI)
				candidates.append({
					"species": species,
					"pose": _pick(rng, rule.poses),
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
			"species": candidate.species,
			"pose": candidate.pose,
			"position": Vector3(at.x, cap_y, at.y),
			"yaw": float(candidate.yaw),
			"scale": float(candidate.scale),
		})
	return placed


## Where on the cap a candidate stands: its own spot (a spot past an end reflected
## back onto the cap), else the nearest of NUDGES steps along the cap either way,
## every other step on the other side of the middle, where all its feet are on
## the cap and its footprint keeps CLEARANCE_M from every placed one.
## {at (world XZ), footprint {a, b, r}}, or {} when none is.
static func _fit(candidate: Dictionary, a: Vector2, along: Vector2, across: Vector2, length: float, half_width: float, shapes: Array[Dictionary]) -> Dictionary:
	var shape := model(str(candidate.pose))
	var size := float(candidate.scale)
	var basis := turn(float(candidate.yaw), size)
	# The ranges along (s) and across (t) the cap that keep every foot on it.
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
		return {}
	var s0 := float(candidate.s)
	if s0 < s_lo:
		s0 = minf(2.0 * s_lo - s0, s_hi)
	elif s0 > s_hi:
		s0 = maxf(2.0 * s_hi - s0, s_lo)
	var t0 := clampf(float(candidate.t), t_lo, t_hi)
	var footprint: Dictionary = shape.footprint
	var end_a := basis * Vector3((footprint.a as Vector2).x, 0.0, (footprint.a as Vector2).y)
	var end_b := basis * Vector3((footprint.b as Vector2).x, 0.0, (footprint.b as Vector2).y)
	var reach_r := float(footprint.r) * size
	for attempt in NUDGES * 2 + 1:
		var step := (attempt + 1) / 2
		var s := s0 + (1.0 if attempt % 2 == 1 else -1.0) * NUDGE_M * float(step)
		if s < s_lo or s > s_hi:
			continue
		var t := t0 if step % 2 == 0 else clampf(-t0, t_lo, t_hi)
		var at := a + along * s + across * t
		var mine := {"a": at + Vector2(end_a.x, end_a.z), "b": at + Vector2(end_b.x, end_b.z), "r": reach_r}
		var clear := true
		for other: Dictionary in shapes:
			if _segment_distance(mine.a, mine.b, other.a, other.b) < reach_r + float(other.r) + CLEARANCE_M:
				clear = false
				break
		if clear:
			return {"at": at, "footprint": mine}
	return {}


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
## round each: the feet, or a sitting bird's belly), footprint (the capsule round
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
			# The belly rests on the stone where its lowest rings meet it.
			m.contacts.append({"at": Vector3(0.0, 0.0, 0.045), "r": 0.05})
		"cormorant_wings_folded":
			_cormorant(m, false)
		"cormorant_wings_spread":
			_cormorant(m, true)
		"pelican_bill_out":
			_pelican(m, false)
		"pelican_bill_tucked":
			_pelican(m, true)
		_:
			push_error("BreakwaterBirds: no pose %s" % pose)
			return {}
	# A belly pressed on the stone is flat: no ring between two that meet it dips under.
	m.floor_at(0.0)
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
	multimesh.use_custom_data = true
	multimesh.mesh = mesh(prop)
	multimesh.instance_count = 1
	multimesh.set_instance_transform(0, Transform3D(placement.basis.scaled(Vector3.ONE * size), placement.origin))
	multimesh.set_instance_custom_data(0, Color(placement.origin.x, placement.origin.y, placement.origin.z, size))
	var instance := MultiMeshInstance3D.new()
	instance.name = prop.to_pascal_case()
	instance.multimesh = multimesh
	var holder := Node3D.new()
	holder.name = "Bird"
	holder.add_child(instance)
	return holder


# ------------------------------------------------------------------ western gull

## A western gull facing -Z, its feet on y = 0: standing on pink legs, or sitting
## low with its belly on the stone, its legs folded out of sight and its head drawn
## in onto its shoulders.
static func _gull(m: Mesher, sitting: bool) -> void:
	var body := [
		_ring(Vector3(0.0, 0.176, 0.205), Vector3.UP, 0.03, 0.022),
		_ring(Vector3(0.0, 0.173, 0.15), Vector3.UP, 0.058, 0.05),
		_ring(Vector3(0.0, 0.178, 0.08), Vector3.UP, 0.08, 0.072),
		_ring(Vector3(0.0, 0.189, 0.01), Vector3.UP, 0.088, 0.085),
		_ring(Vector3(0.0, 0.205, -0.055), Vector3.UP, 0.082, 0.082),
		_ring(Vector3(0.0, 0.229, -0.105), Vector3.UP, 0.064, 0.068),
		_ring(Vector3(0.0, 0.259, -0.13), Vector3.UP, 0.04, 0.046),
	]
	var neck := [
		_ring(Vector3(0.0, 0.24, -0.09), Vector3.BACK, 0.054, 0.054),
		_ring(Vector3(0.0, 0.282, -0.118), Vector3.BACK, 0.047, 0.049),
		_ring(Vector3(0.0, 0.312, -0.128), Vector3(0.0, 0.3, 1.0), 0.042, 0.044),
		_ring(Vector3(0.0, 0.338, -0.136), Vector3(0.0, 0.8, 0.8), 0.038, 0.04),
	]
	# The head's rise over a standing gull's.
	var head_y := 0.0
	if sitting:
		# Settled and fluffed: fuller, the breast lower, the belly flat on the stone,
		# no neck showing.
		body = [
			_ring(Vector3(0.0, 0.074, 0.205), Vector3.UP, 0.032, 0.024),
			_ring(Vector3(0.0, 0.07, 0.15), Vector3.UP, 0.064, 0.058),
			_ring(Vector3(0.0, 0.075, 0.08), Vector3.UP, 0.09, 0.075),
			_ring(Vector3(0.0, 0.082, 0.01), Vector3.UP, 0.095, 0.082),
			_ring(Vector3(0.0, 0.093, -0.055), Vector3.UP, 0.088, 0.08),
			_ring(Vector3(0.0, 0.115, -0.105), Vector3.UP, 0.068, 0.068),
			_ring(Vector3(0.0, 0.145, -0.13), Vector3.UP, 0.042, 0.046),
		]
		neck = [
			_ring(Vector3(0.0, 0.135, -0.09), Vector3.BACK, 0.054, 0.054),
			_ring(Vector3(0.0, 0.17, -0.112), Vector3.BACK, 0.048, 0.05),
			_ring(Vector3(0.0, 0.19, -0.124), Vector3(0.0, 0.6, 1.0), 0.043, 0.045),
			_ring(Vector3(0.0, 0.203, -0.136), Vector3(0.0, 0.9, 0.7), 0.039, 0.041),
		]
		head_y = -0.137
	var tail: Dictionary = body[0]
	var tail_top := float((tail.c as Vector3).y) + float(tail.h)
	var body_paint := func(t: float, up: float, _side: float) -> Color:
		# The grey mantle along the back; the tail end white.
		return GULL_MANTLE if up > 0.55 and t > 0.12 and t < 0.92 else GULL_WHITE
	var front: Dictionary = body[-1]
	m.loft(body, 12, 2, body_paint, Vector3(0.0, (tail.c as Vector3).y, 0.228), (front.c as Vector3) + Vector3(0.0, 0.016, -0.012))
	# Neck and head in one: up from inside the breast, then forward to a flat
	# crown and a sloping forehead.
	var head := neck.duplicate()
	for ring: Array in [
		[0.352, -0.156, 0.036, 0.036], [0.355, -0.18, 0.033, 0.032],
		[0.349, -0.203, 0.026, 0.026], [0.343, -0.218, 0.017, 0.019],
	]:
		head.append(_ring(Vector3(0.0, float(ring[0]) + head_y, float(ring[1])), Vector3.UP, float(ring[2]), float(ring[3])))
	m.loft(head, 10, 2, _solid(GULL_WHITE), null, Vector3(0.0, 0.341 + head_y, -0.225))
	# The strong bill: deep at the base, the gonys' angle and its red spot near the tip.
	var bill_paint := func(t: float, up: float, _side: float) -> Color:
		return GULL_GONYS if up < -0.35 and t > 0.5 and t < 0.85 else GULL_BILL
	m.loft([
		_ring(Vector3(0.0, 0.343 + head_y, -0.212), Vector3.UP, 0.0105, 0.0155),
		_ring(Vector3(0.0, 0.341 + head_y, -0.232), Vector3.UP, 0.0088, 0.014),
		_ring(Vector3(0.0, 0.338 + head_y, -0.251), Vector3.UP, 0.007, 0.0122),
		_ring(Vector3(0.0, 0.339 + head_y, -0.265), Vector3.UP, 0.005, 0.0082),
	], 8, 1, bill_paint, null, Vector3(0.0, 0.334 + head_y, -0.274))
	_eyes(m, Vector3(0.028, 0.359 + head_y, -0.186), 0.0055, GULL_EYE)
	# The folded wings along the upper flanks: grey coverts, the narrow white
	# tertial crescent, then the black primaries with a white mirror and tip,
	# crossed over the tail and reaching well past it.
	var wing_paint := func(t: float, _up: float, _side: float) -> Color:
		if t < 0.5:
			return GULL_MANTLE
		if t < 0.535:
			return GULL_WHITE
		if t > 0.965 or (t > 0.86 and t < 0.9):
			return GULL_MIRROR
		return GULL_PRIMARY
	for side: float in [1.0, -1.0]:
		m.loft([
			_wing_on(body, 4.7, 42.0, 0.004, 0.03, 0.009, side),
			_wing_on(body, 4.0, 38.0, 0.007, 0.045, 0.011, side),
			_wing_on(body, 3.0, 36.0, 0.009, 0.048, 0.011, side),
			_wing_on(body, 2.0, 38.0, 0.009, 0.04, 0.01, side),
			_wing_on(body, 1.2, 50.0, 0.008, 0.03, 0.008, side),
			_wing_on(body, 0.4, 68.0, 0.007, 0.022, 0.006, side),
			_ring(Vector3(0.012 * side, tail_top + 0.006, 0.255), Vector3(0.25 * side, 1.0, 0.0), 0.016, 0.005),
		], 6, 2, wing_paint, null, Vector3(0.004 * side, tail_top + 0.004, 0.335))
	if sitting:
		return
	# Pink legs from inside the belly to webbed feet flat on the stone; far off
	# they draw in to a point inside the belly.
	for side: float in [1.0, -1.0]:
		m.thin_to = 0.15
		m.loft([
			_ring(Vector3(0.027 * side, 0.13, 0.012), Vector3.BACK, 0.0068, 0.0068),
			_ring(Vector3(0.029 * side, 0.07, 0.006), Vector3.BACK, 0.0058, 0.0058),
			_ring(Vector3(0.03 * side, 0.008, 0.0), Vector3.BACK, 0.0055, 0.0055),
		], 5, 1, _solid(GULL_LEG), null, null)
		_foot(m, Vector3(0.03 * side, 0.0, -0.002), 1.0, side, GULL_LEG)
		m.thin_to = NAN


# ------------------------------------------------------------------ double-crested cormorant

## A double-crested cormorant facing -Z, upright on short legs and big webbed
## feet, its stiff tail down to the stone behind; wings folded close along its
## back and sides, or held out half open to dry with the wrists high and the
## hands hanging.
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
	var body_paint := func(t: float, up: float, side: float) -> Color:
		# The bronze-brown, scaled wing coverts on the back between the wings.
		if up > 0.45 and absf(side) < 0.9 and t > 0.25 and t < 0.92:
			return CORMORANT_COVERT
		return CORMORANT_BLACK
	m.loft(body, 12, 2, body_paint, Vector3(0.0, 0.068, 0.058), Vector3(0.0, 0.428, -0.092))
	# The stiff tail, down and back until its tip rests on the stone.
	m.loft([
		_ring(Vector3(0.0, 0.1, 0.062), Vector3(0.0, 0.8, 0.6), 0.03, 0.012),
		_ring(Vector3(0.0, 0.052, 0.125), Vector3(0.0, 0.8, 0.6), 0.026, 0.008),
		_ring(Vector3(0.0, 0.016, 0.18), Vector3(0.0, 0.8, 0.6), 0.02, 0.006),
	], 6, 1, _solid(CORMORANT_FLIGHT), null, Vector3(0.0, 0.0, 0.208))
	# Neck (the kink of a cormorant at rest) and the small head, the orange gular
	# skin under the bill's base.
	var head_paint := func(t: float, up: float, _side: float) -> Color:
		return CORMORANT_GULAR if t > 0.83 and up < -0.25 else CORMORANT_BLACK
	m.loft([
		_ring(Vector3(0.0, 0.38, -0.07), Vector3.BACK, 0.045, 0.045),
		_ring(Vector3(0.0, 0.435, -0.08), Vector3.BACK, 0.036, 0.038),
		_ring(Vector3(0.0, 0.485, -0.082), Vector3.BACK, 0.03, 0.032),
		_ring(Vector3(0.0, 0.53, -0.075), Vector3.BACK, 0.027, 0.028),
		_ring(Vector3(0.0, 0.57, -0.072), Vector3(0.0, 0.3, 1.0), 0.026, 0.027),
		_ring(Vector3(0.0, 0.602, -0.085), Vector3(0.0, 1.0, 0.7), 0.028, 0.03),
		_ring(Vector3(0.0, 0.62, -0.105), Vector3(0.0, 1.0, 0.2), 0.03, 0.032),
		_ring(Vector3(0.0, 0.625, -0.128), Vector3.UP, 0.026, 0.027),
		_ring(Vector3(0.0, 0.62, -0.148), Vector3.UP, 0.017, 0.019),
	], 10, 2, head_paint, null, Vector3(0.0, 0.617, -0.157))
	# The slim hooked bill, held a little up.
	var bill_paint := func(t: float, up: float, _side: float) -> Color:
		return CORMORANT_GULAR if t < 0.25 and up < 0.0 else CORMORANT_BILL
	m.loft([
		_ring(Vector3(0.0, 0.616, -0.143), Vector3.UP, 0.0105, 0.011),
		_ring(Vector3(0.0, 0.62, -0.168), Vector3.UP, 0.0072, 0.0082),
		_ring(Vector3(0.0, 0.624, -0.194), Vector3.UP, 0.0055, 0.0062),
		_ring(Vector3(0.0, 0.626, -0.21), Vector3.UP, 0.0046, 0.0052),
	], 6, 1, bill_paint, null, Vector3(0.0, 0.621, -0.219))
	_eyes(m, Vector3(0.0225, 0.628, -0.127), 0.0045, CORMORANT_EYE)
	var tips := (body[0].c as Vector3) + dorsal * (float(body[0].h) + 0.004)
	for side: float in [1.0, -1.0]:
		if spread:
			_spread_wing(m, side)
		else:
			# The folded wing close along the back and side, its dark flight
			# feathers meeting over the tail's base.
			var wing_paint := func(t: float, _up: float, _side: float) -> Color:
				return CORMORANT_COVERT if t < 0.55 else CORMORANT_FLIGHT
			m.loft([
				_wing_on(body, 5.2, 40.0, 0.003, 0.03, 0.008, side),
				_wing_on(body, 4.4, 36.0, 0.005, 0.042, 0.01, side),
				_wing_on(body, 3.5, 34.0, 0.006, 0.046, 0.01, side),
				_wing_on(body, 2.5, 36.0, 0.006, 0.042, 0.009, side),
				_wing_on(body, 1.6, 45.0, 0.005, 0.032, 0.008, side),
				_wing_on(body, 0.8, 60.0, 0.004, 0.02, 0.006, side),
			], 6, 2, wing_paint, null, tips + Vector3(0.006 * side, 0.0, 0.0))
		m.thin_to = 0.19
		m.loft([
			_ring(Vector3(0.033 * side, 0.13, 0.012), Vector3.BACK, 0.012, 0.012),
			_ring(Vector3(0.035 * side, 0.065, 0.0), Vector3.BACK, 0.009, 0.009),
			_ring(Vector3(0.036 * side, 0.01, -0.006), Vector3.BACK, 0.0085, 0.0085),
		], 5, 1, _solid(CORMORANT_FOOT), null, null)
		_foot(m, Vector3(0.036 * side, 0.0, -0.01), 1.55, side, CORMORANT_FOOT)
		m.thin_to = NAN


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
## half height].
const PELICAN_BODY := [
	[0.0, 0.03, 0.02], [0.06, 0.075, 0.045], [0.14, 0.12, 0.085], [0.24, 0.148, 0.115],
	[0.34, 0.158, 0.128], [0.44, 0.15, 0.126], [0.52, 0.126, 0.11], [0.58, 0.09, 0.084],
]

## A brown pelican facing -Z on short dark legs: its body raised at the breast,
## the neck up in an S with the long bill held down in front of it (bill out), or
## the body low and level, the neck folded and the head laid back on the
## shoulders with the bill under the scapulars (bill tucked).
static func _pelican(m: Mesher, tucked: bool) -> void:
	# The body's axis from the tail's tip toward the breast, and its back.
	var origin := Vector3(0.0, 0.16, 0.33) if tucked else Vector3(0.0, 0.07, 0.33)
	var lean := deg_to_rad(8.0 if tucked else 32.0)
	var axis := Vector3(0.0, sin(lean), -cos(lean))
	var dorsal := Vector3(0.0, cos(lean), sin(lean))
	var body := []
	for ring: Array in PELICAN_BODY:
		body.append(_ring(origin + axis * float(ring[0]), dorsal, float(ring[1]), float(ring[2])))
	var body_paint := func(_t: float, up: float, _side: float) -> Color:
		if up < -0.45:
			return PELICAN_BELLY
		if up < -0.15:
			return PELICAN_BELLY.lerp(PELICAN_BACK, (up + 0.45) / 0.3)
		return PELICAN_BACK
	m.loft(body, 12, 2, body_paint, origin - axis * 0.02, origin + axis * 0.64)
	# The folded wings over the sides and back: silvery coverts, darker along the
	# lower edge, then the dark secondaries and primaries crossing over the tail.
	for side: float in [1.0, -1.0]:
		var wing_paint := func(t: float, _up: float, lateral: float) -> Color:
			if t > 0.6:
				return PELICAN_PRIMARY
			return PELICAN_STREAK if lateral * side < -0.4 else PELICAN_BACK
		m.loft([
			_wing_on(body, 6.6, 58.0, 0.006, 0.05, 0.016, side),
			_wing_on(body, 5.8, 50.0, 0.009, 0.085, 0.019, side),
			_wing_on(body, 4.8, 45.0, 0.011, 0.1, 0.02, side),
			_wing_on(body, 3.8, 44.0, 0.011, 0.098, 0.019, side),
			_wing_on(body, 2.8, 48.0, 0.01, 0.08, 0.016, side),
			_wing_on(body, 1.8, 58.0, 0.009, 0.055, 0.012, side),
			_wing_on(body, 1.0, 72.0, 0.007, 0.035, 0.009, side),
			_ring(origin - axis * 0.02 + dorsal * 0.03 + Vector3(0.02 * side, 0.0, 0.0), dorsal + Vector3(0.3 * side, 0.0, 0.0), 0.022, 0.007),
		], 6, 2, wing_paint, null, origin - axis * 0.07 + dorsal * 0.022 + Vector3(0.005 * side, 0.0, 0.0))
	var neck_paint := func(t: float, up: float, _side: float) -> Color:
		# White in front, the dark hindneck behind, up to the white head with its
		# yellow-washed crown.
		if t > 0.62:
			return PELICAN_CROWN if up > 0.45 and t < 0.9 else PELICAN_WHITE
		return PELICAN_HINDNECK if up > 0.2 else PELICAN_WHITE
	if tucked:
		# The neck folded up from the breast and back over the shoulders, the head
		# lying on them facing back: the hindneck is the outside of the fold, so its
		# dark stripe shows at the front, under the head.
		m.loft([
			_ring(Vector3(0.0, 0.25, -0.24), Vector3(0.0, 0.2, -1.0), 0.08, 0.075),
			_ring(Vector3(0.0, 0.31, -0.262), Vector3(0.0, 0.3, -1.0), 0.074, 0.07),
			_ring(Vector3(0.0, 0.365, -0.245), Vector3(0.0, 0.8, -0.6), 0.069, 0.065),
			_ring(Vector3(0.0, 0.392, -0.2), Vector3(0.0, 1.0, -0.1), 0.064, 0.06),
			_ring(Vector3(0.0, 0.398, -0.155), Vector3.UP, 0.058, 0.052),
			_ring(Vector3(0.0, 0.396, -0.115), Vector3.UP, 0.055, 0.05),
			_ring(Vector3(0.0, 0.39, -0.08), Vector3.UP, 0.046, 0.044),
			_ring(Vector3(0.0, 0.381, -0.055), Vector3.UP, 0.032, 0.032),
		], 10, 2, neck_paint, null, Vector3(0.0, 0.377, -0.042))
		# The bill laid back along the shoulders, sinking under the scapulars.
		_pelican_bill(m, Vector3(0.0, 0.383, -0.05), Vector3(0.0, -0.6, 1.0).normalized(), Vector3(0.0, 1.0, 0.6).normalized(), 0.3)
		_eyes(m, Vector3(0.039, 0.398, -0.072), 0.006, PELICAN_EYE)
	else:
		# The neck raised in a gentle S from the breast, the long head on top.
		m.loft([
			_ring(Vector3(0.0, 0.38, -0.135), Vector3(0.0, 0.2, 1.0), 0.08, 0.075),
			_ring(Vector3(0.0, 0.46, -0.165), Vector3(0.0, 0.1, 1.0), 0.07, 0.066),
			_ring(Vector3(0.0, 0.54, -0.172), Vector3.BACK, 0.058, 0.056),
			_ring(Vector3(0.0, 0.61, -0.158), Vector3.BACK, 0.051, 0.05),
			_ring(Vector3(0.0, 0.665, -0.138), Vector3(0.0, 0.4, 1.0), 0.048, 0.048),
			_ring(Vector3(0.0, 0.708, -0.128), Vector3(0.0, 1.0, 0.6), 0.05, 0.051),
			_ring(Vector3(0.0, 0.733, -0.148), Vector3(0.0, 1.0, 0.2), 0.049, 0.048),
			_ring(Vector3(0.0, 0.734, -0.178), Vector3(0.0, 1.0, -0.1), 0.044, 0.043),
			_ring(Vector3(0.0, 0.721, -0.204), Vector3(0.0, 1.0, -0.3), 0.036, 0.036),
			_ring(Vector3(0.0, 0.704, -0.225), Vector3(0.0, 1.0, -0.5), 0.026, 0.028),
		], 10, 2, neck_paint, null, Vector3(0.0, 0.697, -0.236))
		# The bill held down in front of the neck, about 52 degrees below level.
		_pelican_bill(m, Vector3(0.0, 0.706, -0.215), Vector3(0.0, -0.788, -0.616), Vector3(0.0, 0.616, -0.788), 0.32)
		_eyes(m, Vector3(0.032, 0.728, -0.198), 0.006, PELICAN_EYE)
	# Short thick legs and broad webbed feet; far off they draw in to a point inside
	# the belly.
	var hip := 0.15 if tucked else 0.18
	for side: float in [1.0, -1.0]:
		m.thin_to = 0.17 if tucked else 0.21
		m.loft([
			_ring(Vector3(0.062 * side, hip, 0.03), Vector3.BACK, 0.02, 0.02),
			_ring(Vector3(0.07 * side, hip * 0.5, -0.004), Vector3.BACK, 0.016, 0.016),
			_ring(Vector3(0.075 * side, 0.012, -0.012), Vector3.BACK, 0.014, 0.014),
		], 6, 1, _solid(PELICAN_LEG), null, null)
		_foot(m, Vector3(0.075 * side, 0.0, -0.018), 2.0, side, PELICAN_LEG)
		m.thin_to = NAN


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


## A folded wing's ring lying on a body (its rings from the tail forward): at
## `at` rings along it (2.5: half way from ring 2 to ring 3), its middle
## `angle_deg` up round the body from the side toward the back, `lift` off its
## surface, `depth` across the wing and `thickness` through it (half extents);
## side +1 the right.
static func _wing_on(body: Array, at: float, angle_deg: float, lift: float, depth: float, thickness: float, side: float) -> Dictionary:
	var index := clampi(int(floor(at)), 0, body.size() - 2)
	var f := clampf(at - float(index), 0.0, 1.0)
	var back: Dictionary = body[index]
	var front: Dictionary = body[index + 1]
	var centre := (back.c as Vector3).lerp(front.c, f)
	var along := ((front.c as Vector3) - (back.c as Vector3)).normalized()
	var up := (back.u as Vector3).lerp(front.u, f)
	up = (up - along * up.dot(along)).normalized()
	var across := along.cross(up).normalized() * side
	var w := lerpf(back.w, front.w, f)
	var h := lerpf(back.h, front.h, f)
	var angle := deg_to_rad(angle_deg)
	var normal := (across * (h * cos(angle)) + up * (w * sin(angle))).normalized()
	return _ring(centre + across * (w * cos(angle)) + up * (h * sin(angle)) + normal * lift, normal, depth, thickness)


## Both eyes (small balls), mirrored about x = 0.
static func _eyes(m: Mesher, right: Vector3, radius: float, color: Color) -> void:
	for side: float in [1.0, -1.0]:
		var centre := Vector3(right.x * side, right.y, right.z)
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
	## draws in to the point this high (bird units) over the bird's feet, inside its
	## body: UV2 (1, the height). NAN: not thin.
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
