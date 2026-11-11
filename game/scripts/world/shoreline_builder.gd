class_name ShorelineBuilder
extends RefCounted
## Shoreline riprap from generated/world/shoreline.json
## (tools/lib/shoreline-generation.mjs), as GeneratedWorldContract expands it:
## the flat shoulder just outside the island outline, the underlay slope behind
## it and its bare rock faces, the concrete closure faces (pier and platform
## edges, boat ramps), the instanced quarry stones (top row, back row, shoulder
## stones and heap), the low cobbles in the band inside the outline and the
## driftwood, each segment's stones and underlay in their own materials (its
## stone tone, blended into its neighbours' at its ends). Visual only, like the
## Yerba Buena context: no collision and no spray receiver, but for the inland
## stones, which stand on walkable land and get a coarse body of their own
## (_inland_body), and the cars' ground over the riprap (_car_ground) and their
## barrier at the causeway (_car_barrier), which only cars and shoved K-rails
## meet. The band inside the outline is an ordinary chunk overlay; it and the
## shoulder share
## BAND_GROUND_FAMILY, the dry grass-and-dirt verge at the top of the riprap, so
## the verge runs on past the outline to the stones.

const RIPRAP_SHADER := preload("res://game/resources/materials/world/shoreline/riprap.gdshader")
const GROUND_COVER := preload("res://game/scripts/world/ground_cover.gd")
const RIPRAP_ALBEDO := preload("res://game/resources/textures/world/shoreline/riprap_albedo.png")
const BOULDER_ALBEDO := preload("res://game/resources/textures/world/shoreline/boulder_albedo.png")
const RENDER_WORLD_VISIBLE := 1
## The shader's `surface` per material.
const SURFACE_SLOPE := 0
const SURFACE_STONE := 1
const SURFACE_WOOD := 2
const SURFACE_WALL := 3
const SLOPE_MATERIAL := "shoreline_riprap"
const FACE_MATERIAL := "shoreline_face"
const ROCK_GROUND_MATERIAL := "shoreline_rock_ground"
const VERGE_MATERIAL := "shoreline_verge"
const WALL_MATERIAL := "shoreline_wall"
const STONE_MATERIAL := "shoreline_boulder"
const DRIFTWOOD_MATERIAL := "shoreline_driftwood"
## The ground cover family of the verge: the band inside the outline (a chunk
## overlay, see world_chunk_builder.gd) and the shoulder outside it.
const BAND_GROUND_FAMILY := "verge"
## The inland stones' body: what it blocks (a street prop's layer, so the player's mask
## has it and the camera's doesn't), the length of one wedge, how steeply it climbs from
## the land to the stones' tops, how far it reaches below them, and how high in their
## tops it stands, as a share of them from the lowest.
const PHYSICS_STREET_PROP := 1 << 3
const INLAND_BODY_STEP_M := 12.0
const INLAND_BODY_SLOPE := 0.7
const INLAND_BODY_DEPTH_M := 2.0
const INLAND_BODY_TOP_SHARE := 0.7
## The cars' ground over the riprap (owner, 2026-11-10: a car driven off the shore
## rolls down the rocks and splashes where it meets the water). The stones are
## drawn only, so this surface stands in for them for cars alone: its own layer,
## which only drivable_car.gd's body and wheels and the live K-rails
## (vehicle_manager.gd) look for; the player, the cameras and the spray never see
## it. It stands over the riprap in rows (_car_ground, _row), each from inland
## out to the underlay's toe: a climb, a top and the fall, all CAR_LIFT_M over
## the underlay, about the tops of the stones on it (the generated stones stand
## 0.3-0.4 m over the underlay at the median and 0.55-0.7 m at the 90th
## percentile, measured round the island; the big ones of the crest and the
## heap's foot reach higher). The top starts at the shoulder's far edge at the
## crest's height and falls straight out over the crest and the berm below it
## to where the underlay has fallen CAR_TOP_DROP_M under its crest, so there is
## no ridge at the crest for a car's belly to catch on and the car tips over
## onto the fall no more steeply than the slope itself. The fall ends at the
## underlay's toe a little over the water, so a car rolls off its end into the
## bay. The climb runs straight from a foot CAR_RAMP_FOOT_M under the land up to
## the top, no steeper than CAR_CLIMB_MAX: inland of the outline as far as
## CAR_CLIMB_RUN_M, as the open ground allows (never over a drawn road, path or
## paved paint, whose drawn ground stands CAR_WAY_LIFT_M or more over the land),
## so a car climbs over the crest's stones instead of running into them and
## stands over the land in front of the rocks no more than it must. A shore with
## no shoulder (the slope running from the land edge itself) lifts its slope
## gradually instead, fully CAR_LIFT_RUN_M out from the edge. It is frictionless
## (a car's wheels grip it through their own forces), so a car whose belly
## touches it slides on over.
const PHYSICS_CAR_GROUND := 1 << 5
const CAR_LIFT_M := 0.65
const CAR_TOP_DROP_M := 0.35
## The top reaches at most this far out past the crest, and stops at least
## CAR_FALL_MIN_M short of the toe.
const CAR_TOP_MAX_M := 3.0
const CAR_FALL_MIN_M := 1.0
const CAR_CLIMB_RUN_M := 1.1
const CAR_CLIMB_MAX := 0.6
const CAR_RAMP_FOOT_M := 0.1
const CAR_WAY_LIFT_M := 0.07
const CAR_WAY_STEP_M := 0.5
## Where the land falls inland of the outline steeper than this (m per m), the
## edge is a crest of the land itself: no climb inland of it.
const CAR_FALL_SLOPE := 0.25
const CAR_LIFT_RUN_M := 0.6
## The rows: every CAR_ROW_STRIDE-th station of the shoulder strip (about 5 m
## apart), each kept at five points (the climb's foot, the top's two ends and
## CAR_FALL_POINTS down the fall to the toe, which runs on CAR_TOE_PAST_M where it
## falls); a row's underlay vertices lie within CAR_ROW_ON_M of its line, and
## CAR_ROW_SPREAD more a metre out, up to CAR_ROW_REACH_M out, found through
## CAR_CELL_M cells. Stations further apart than CAR_STATION_GAP_M start a new
## run; rows of two runs are joined only where they stand within CAR_ROW_GAP_M of
## each other and the point between them lies within CAR_JOIN_EDGE_M of the
## outline. Neighbouring stations within CAR_SAME_M are one.
const CAR_ROW_STRIDE := 4
const CAR_FALL_POINTS := 2
const CAR_TOE_PAST_M := 1.0
const CAR_ROW_ON_M := 0.06
const CAR_ROW_SPREAD := 0.03
const CAR_ROW_REACH_M := 25.0
const CAR_ROW_PAST_M := 3.0
const CAR_CELL_M := 1.0
const CAR_STATION_GAP_M := 2.5
const CAR_ROW_GAP_M := 8.0
const CAR_JOIN_EDGE_M := 0.5
const CAR_SAME_M := 0.05
## A station whose way out turns from the last kept one's by more than about 15
## degrees (this cosine) gets a row too, and where two rows' cross-sections reach
## out more than CAR_ROW_JUMP_M apart every station between them does.
const CAR_ROW_TURN_COS := 0.966
const CAR_ROW_JUMP_M := 2.0
## A rock face vertex whose normal stands at least this far up lies no steeper
## than a slope (underlay for the rows).
const CAR_FACE_UP := 0.5
## The causeway's barrier (_car_barrier): from this far under the lowest crossing
## point on its edge to this far over the highest.
const CAR_BARRIER_UNDER_M := 1.0
const CAR_BARRIER_OVER_M := 1.5
## A vertex this close to the outline is on it.
const CAR_EDGE_ON_M := 0.02
## The outline's edges are found through a grid of this cell size (m).
const OUTLINE_CELL_M := 32.0

static var _riprap := {}


## The underlay slope's material.
static func slope_material() -> ShaderMaterial:
	return _riprap_material(SLOPE_MATERIAL, SURFACE_SLOPE)


## Every instanced stone: top row, back row, shoulder stones, heap and cobbles.
static func stone_material() -> ShaderMaterial:
	return _riprap_material(STONE_MATERIAL, SURFACE_STONE)


## The driftwood logs and planks.
static func driftwood_material() -> ShaderMaterial:
	return _riprap_material(DRIFTWOOD_MATERIAL, SURFACE_WOOD)


## The concrete closure faces: pier and platform edges, boat ramps.
static func wall_material() -> ShaderMaterial:
	return _riprap_material(WALL_MATERIAL, SURFACE_WALL)


## Land that is stone in the aerial (the flat breakwater overlay left on a rock
## ground): the underlay's bare rock.
static func rock_ground_material() -> ShaderMaterial:
	var material := _riprap_material(ROCK_GROUND_MATERIAL, SURFACE_SLOPE)
	material.set_shader_parameter("rock_face", true)
	return material


## The shoulder strip outside the outline: the verge's own ground cover.
static func verge_material() -> ShaderMaterial:
	return GROUND_COVER.material(BAND_GROUND_FAMILY)


static func _riprap_material(key: String, surface: int) -> ShaderMaterial:
	if not _riprap.has(key):
		var material := ShaderMaterial.new()
		material.resource_name = key
		material.shader = RIPRAP_SHADER
		material.set_shader_parameter("surface", surface)
		material.set_shader_parameter("riprap_albedo", RIPRAP_ALBEDO)
		material.set_shader_parameter("boulder_albedo", BOULDER_ALBEDO)
		_riprap[key] = material
	return _riprap[key]


## A segment's stone or underlay material: the riprap shader with the
## segment's tone and its neighbours' at its ends (document segments' tone), and
## the document's thinning (lod).
static func _segment_material(key: String, surface: int, segment: Dictionary, lod: Dictionary) -> ShaderMaterial:
	var material := (_riprap_material(key, surface).duplicate() as ShaderMaterial)
	material.resource_name = "%s:%s" % [key, str(segment.id)]
	var tone: Dictionary = segment.tone
	material.set_shader_parameter("tone_self", _vector4(tone.stone))
	material.set_shader_parameter("tone_start", _vector4(tone.start.stone))
	material.set_shader_parameter("tone_end", _vector4(tone.end.stone))
	material.set_shader_parameter("joint_start", Vector4(float(tone.start.at[0]), float(tone.start.at[1]), float(tone.start.along[0]), float(tone.start.along[1])))
	material.set_shader_parameter("joint_end", Vector4(float(tone.end.at[0]), float(tone.end.at[1]), float(tone.end.along[0]), float(tone.end.along[1])))
	material.set_shader_parameter("tone_blend_m", float(tone.blend_m))
	material.set_shader_parameter("stone_reach_per_m", float(lod.reach_per_m))
	material.set_shader_parameter("stone_reach_min_m", float(lod.min_m))
	material.set_shader_parameter("stone_reach_max_m", float(lod.max_m))
	material.set_shader_parameter("stone_thin_start", float(lod.start))
	material.set_shader_parameter("underlay_fade_m", Vector2(float(lod.underlay_fade_m[0]), float(lod.underlay_fade_m[1])))
	return material


static func _vector4(values: Array) -> Vector4:
	return Vector4(float(values[0]), float(values[1]), float(values[2]), float(values[3]))


static func _record_material(material_key: String) -> Material:
	match material_key:
		VERGE_MATERIAL:
			return verge_material()
		WALL_MATERIAL:
			return wall_material()
	return slope_material()


## Builds the validated, expanded document into one Node3D; returns the
## builder report. For the cars' ground and barrier: boundary is the validated
## playable outline (its components' outer rings and holes, as
## WorldBoundary.configure takes it), without which there are none; ways the
## drawn ground's index (VisibleGround, over the world's roads, paths and areas)
## that keeps the climb off roads and paths; crossings the causeway's
## (causeway_crossings).
func build(document: Dictionary, boundary: Dictionary = {}, ways: VisibleGround = null, crossings: Array = []) -> Dictionary:
	var root := Node3D.new()
	root.name = "GeneratedShoreline"
	var triangles := 0
	var mesh_instances := 0
	# Each segment's stones and underlay take their own materials: its tone,
	# blended into its neighbours' at its ends, and the document's thinning.
	var segment_materials := {}
	for segment_value: Variant in document.segments:
		var segment: Dictionary = segment_value
		segment_materials[str(segment.id)] = {
			"stone": _segment_material(STONE_MATERIAL, SURFACE_STONE, segment, document.lod),
			"slope": _segment_material(SLOPE_MATERIAL, SURFACE_SLOPE, segment, document.lod),
			"face": _segment_material(FACE_MATERIAL, SURFACE_SLOPE, segment, document.lod),
		}
		(segment_materials[str(segment.id)].face as ShaderMaterial).set_shader_parameter("rock_face", true)
	for record_value: Variant in document.records:
		var record: Dictionary = record_value
		var instance := MeshInstance3D.new()
		instance.name = str(record.object_key).validate_node_name()
		var record_material := _record_material(str(record.material_key))
		if str(record.material_key) == SLOPE_MATERIAL:
			record_material = segment_materials[str(record.segment)].slope
		elif str(record.material_key) == FACE_MATERIAL:
			record_material = segment_materials[str(record.segment)].face
		instance.mesh = _array_mesh(record, record_material)
		instance.layers = RENDER_WORLD_VISIBLE
		# Like the terrain overlays, the slope, shoulder and closure faces receive shadows but cast none.
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		instance.set_meta("source_keys", (record.source_keys as Array).duplicate())
		instance.set_meta("visual_only", true)
		root.add_child(instance)
		triangles += int(record.indices.size() / 3)
		mesh_instances += 1
	var prototypes := {}
	for prototype_value: Variant in document.prototypes:
		var prototype: Dictionary = prototype_value
		var material: Material = stone_material() if str(prototype.material_key) == STONE_MATERIAL else driftwood_material()
		prototypes[str(prototype.id)] = {"mesh": _array_mesh(prototype, material), "triangles": int(prototype.indices.size() / 3)}
	# One MultiMesh per generated batch (segment, shore section, band and
	# prototype), so each culls and picks its LOD on its own. The stones carry
	# no colour: the shader tints each one from its position and its segment's
	# tone, and thins them out one by one with distance.
	var stones := Node3D.new()
	stones.name = "Stones"
	root.add_child(stones)
	var batches := 0
	var instances := 0
	var inland: Array[AABB] = []
	for batch_value: Variant in document.batches:
		var batch: Dictionary = batch_value
		var prototype: Dictionary = prototypes[str(batch.prototype)]
		var transforms: PackedFloat32Array = batch.transforms
		var count := int(transforms.size() / GeneratedWorldContract.SHORELINE_PLACEMENT_LENGTH)
		var multi_mesh := MultiMesh.new()
		multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
		multi_mesh.use_colors = false
		multi_mesh.use_custom_data = false
		multi_mesh.mesh = prototype.mesh
		multi_mesh.instance_count = count
		for index in count:
			var at := index * GeneratedWorldContract.SHORELINE_PLACEMENT_LENGTH
			var rotation := Quaternion(transforms[at + 3], transforms[at + 4], transforms[at + 5], transforms[at + 6]).normalized()
			var basis := Basis(rotation) * Basis.from_scale(Vector3(transforms[at + 7], transforms[at + 8], transforms[at + 9]))
			var placed := Transform3D(basis, Vector3(transforms[at], transforms[at + 1], transforms[at + 2]))
			multi_mesh.set_instance_transform(index, placed)
			if str(batch.band) == "inland":
				inland.append(placed * (prototype.mesh as ArrayMesh).get_aabb())
		var node := MultiMeshInstance3D.new()
		node.name = str(batch.id).validate_node_name()
		node.multimesh = multi_mesh
		node.layers = RENDER_WORLD_VISIBLE
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if bool(batch.cast_shadow) else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		node.visibility_range_end = float(batch.visibility_end_m)
		node.visibility_range_end_margin = float(batch.visibility_margin_m)
		if str(batch.band) == "driftwood":
			node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		else:
			# The stones thin out one by one in the shader; the batch range only
			# culls it once its last stone has gone.
			node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
			node.material_override = segment_materials[str(batch.segment)].stone
		node.set_meta("band", str(batch.band))
		node.set_meta("placement_count", count)
		node.set_meta("visual_only", true)
		stones.add_child(node)
		batches += 1
		instances += count
		triangles += int(prototype.triangles) * count
	if not inland.is_empty():
		root.add_child(_inland_body(inland))
	var rings := _outline_rings(boundary)
	var car_ground := _car_ground(document, rings, ways)
	if car_ground != null:
		root.add_child(car_ground)
	var barrier := _car_barrier(rings, crossings)
	if barrier != null:
		root.add_child(barrier)
	return {
		"ok": true,
		"node": root,
		"mesh_instances": mesh_instances + batches,
		"surfaces": mesh_instances + batches,
		"triangles": triangles,
		"multimesh_batches": batches,
		"boulders": instances,
	}


## The inland stones stand on walkable land, so their band is solid, in a few coarse
## shapes rather than one a stone: along its length, a wedge every INLAND_BODY_STEP_M that
## climbs from the land to the stones' tops at the band's inner edge and runs on to its outer
## edge, its ends meeting its neighbours' so a foot finds no step. A walker climbs onto the
## rocks instead of wading through them, and goes on to the shore as anywhere else. There is
## one band: the config allows no more. stones are their bounds in the world.
func _inland_body(stones: Array[AABB]) -> StaticBody3D:
	var extremes := [stones[0], stones[0]]
	var middle := Vector2.ZERO
	for stone: AABB in stones:
		var at := stone.get_center()
		middle += Vector2(at.x, at.z) / stones.size()
		if at.z < (extremes[0] as AABB).get_center().z:
			extremes[0] = stone
		if at.z > (extremes[1] as AABB).get_center().z:
			extremes[1] = stone
	var first: Vector3 = (extremes[0] as AABB).get_center()
	var last: Vector3 = (extremes[1] as AABB).get_center()
	var along := Vector2(last.x - first.x, last.z - first.z).normalized()
	# Inland: the side of the band toward the island's middle, the world's origin.
	var inward := Vector2(along.y, -along.x)
	if inward.dot(middle) > 0.0:
		inward = -inward
	var bins := {}
	for stone: AABB in stones:
		var at := stone.get_center()
		var key := int(floor(Vector2(at.x, at.z).dot(along) / INLAND_BODY_STEP_M))
		if not bins.has(key):
			bins[key] = []
		(bins[key] as Array).append(stone)
	var keys: Array = bins.keys()
	keys.sort()
	var rows: Array[Dictionary] = []
	for key: int in keys:
		var tops := PackedFloat32Array()
		var near := -INF
		var far := INF
		for stone: AABB in bins[key]:
			var at := stone.get_center()
			var reach := maxf(stone.size.x, stone.size.z) / 2.0
			near = maxf(near, Vector2(at.x, at.z).dot(inward) + reach)
			far = minf(far, Vector2(at.x, at.z).dot(inward) - reach)
			tops.append(stone.end.y)
		tops.sort()
		rows.append({"key": key, "top": tops[int(tops.size() * INLAND_BODY_TOP_SHARE)], "near": near, "far": far})
	var body := StaticBody3D.new()
	body.name = "InlandStones"
	body.collision_layer = PHYSICS_STREET_PROP
	body.collision_mask = 0
	for index in rows.size():
		var row: Dictionary = rows[index]
		var points := PackedVector3Array()
		for side in 2:
			# Each end stands halfway to its neighbour's wedge.
			var other: Dictionary = rows[clampi(index + side * 2 - 1, 0, rows.size() - 1)]
			var top := (float(row.top) + float(other.top)) / 2.0
			var near := (float(row.near) + float(other.near)) / 2.0
			var far := (float(row.far) + float(other.far)) / 2.0
			var foot := top - INLAND_BODY_DEPTH_M
			var toe := near + INLAND_BODY_DEPTH_M / INLAND_BODY_SLOPE
			for corner: Vector2 in [Vector2(far, foot), Vector2(far, top), Vector2(near, top), Vector2(toe, foot)]:
				var plan := along * ((int(row.key) + side) * INLAND_BODY_STEP_M) + inward * corner.x
				points.append(Vector3(plan.x, corner.y, plan.y))
		var shape := ConvexPolygonShape3D.new()
		shape.points = points
		var holder := CollisionShape3D.new()
		holder.shape = shape
		body.add_child(holder)
	return body


## The cars' ground (PHYSICS_CAR_GROUND): one body over the riprap. Where a
## segment section has a shoulder (crest rows), the surface is built in rows: at
## every CAR_ROW_STRIDE-th station of the shoulder strip (the generator's
## stations, about 1.25 m apart), the underlay's own cross-section along that
## station is read from its vertices and kept at five points, the climb in front
## of it, the top and the fall (_row); neighbouring rows are joined by quads, so
## a smooth slope takes a few faces where the underlay takes many. A
## slope section with no shoulder of its own lifts with its distance from the
## outline instead, and the concrete closures (pier faces, the north slipway) are
## solid as drawn, so a car drives down the slipway into the water. ways is the
## drawn ground's index (VisibleGround) that keeps the climb off roads, paths and
## paved paint; rings are the outline's (_outline_rings); with no rings there is
## no body (null).
func _car_ground(document: Dictionary, rings: Array[Dictionary], ways: VisibleGround = null) -> StaticBody3D:
	if rings.is_empty():
		return null
	var shouldered := {}
	for record_value: Variant in document.records:
		var record: Dictionary = record_value
		if str(record.material_key) == VERGE_MATERIAL:
			shouldered[_section_key(record)] = true
	# The underlay's vertices by CAR_CELL_M cell (Vector2i -> Array of Vector3): the
	# slope's, and in a shouldered section the rock face's where it lies no steeper
	# than a slope (a narrow inlet's clamped fill is drawn as a rock face; a capped
	# end's face and the skirts beside a ramp stand upright and are left out). far:
	# the fill's vertices on the outline across the inlet (_place keys), where a
	# cross-section reaches the land again and ends.
	var edges := _edge_grid(rings)
	var underlay := {}
	var far := {}
	for record_value: Variant in document.records:
		var record: Dictionary = record_value
		var key := str(record.material_key)
		var face := key == FACE_MATERIAL and shouldered.has(_section_key(record))
		if key != SLOPE_MATERIAL and not face:
			continue
		var vertices := _vector3s(record.vertices)
		var normals := _vector3s(record.normals)
		for index in vertices.size():
			if face and (index >= normals.size() or normals[index].y < CAR_FACE_UP):
				continue
			var at := vertices[index]
			var cell := Vector2i(floori(at.x / CAR_CELL_M), floori(at.z / CAR_CELL_M))
			if not underlay.has(cell):
				underlay[cell] = []
			(underlay[cell] as Array).append(at)
			if face and float(_nearest_edge(edges, Vector2(at.x, at.z)).distance) <= CAR_EDGE_ON_M * 2.5:
				far[_place(at)] = true
	var faces := PackedVector3Array()
	var lift := Vector3.UP * CAR_LIFT_M
	for record_value: Variant in document.records:
		var record: Dictionary = record_value
		var key := str(record.material_key)
		if key == WALL_MATERIAL:
			var drawn := _vector3s(record.vertices)
			for index_value: int in _clockwise(record.indices):
				faces.append(drawn[index_value])
		elif key == SLOPE_MATERIAL and not shouldered.has(_section_key(record)):
			var vertices := _vector3s(record.vertices)
			var moved := PackedVector3Array()
			moved.resize(vertices.size())
			for index in vertices.size():
				var at := vertices[index]
				var edge := _nearest_edge(edges, Vector2(at.x, at.z))
				moved[index] = at + lift * clampf(float(edge.distance) / CAR_LIFT_RUN_M, 0.0, 1.0)
			for index_value: int in _clockwise(record.indices):
				faces.append(moved[index_value])
	# The stations in the shoulder strips' order round the island, in runs:
	# stations further apart than CAR_STATION_GAP_M start a new one (a pier, a ramp
	# or a capped end lies between). Every CAR_ROW_STRIDE-th of a run, its last, and
	# any that turns away from the last of these by more than CAR_ROW_TURN_COS (the
	# shore's corners) get a row; where such a station's cross-section can't be read
	# (at a sharp corner or a joint its shoulder's far edge may lie on the slope's
	# next row), the nearest station of its run whose can stands in. used: the
	# stations with rows, in order, and profiles their cross-sections.
	var stations := _stations(document, underlay)
	var run_of := PackedInt32Array()
	run_of.resize(stations.size())
	var kept: Array[int] = []
	var run := 0
	var run_start := 0
	var kept_out := Vector2.ZERO
	for index in stations.size():
		run_of[index] = run
		var station_out := Vector2((stations[index].outer as Vector3).x - (stations[index].inner as Vector3).x, (stations[index].outer as Vector3).z - (stations[index].inner as Vector3).z).normalized()
		var next_far := index + 1 >= stations.size() or (stations[index + 1].inner as Vector3).distance_to(stations[index].inner) > CAR_STATION_GAP_M
		if (index - run_start) % CAR_ROW_STRIDE == 0 or next_far or station_out.dot(kept_out) < CAR_ROW_TURN_COS:
			kept.append(index)
			kept_out = station_out
		if next_far:
			run += 1
			run_start = index + 1
			kept_out = Vector2.ZERO
	var used: Array[int] = []
	var profiles: Array[Array] = []
	for index: int in kept:
		for shift: int in [0, 1, -1, 2, -2]:
			var other := index + shift
			if other < 0 or other >= stations.size() or run_of[other] != run_of[index] or (not used.is_empty() and other <= used[used.size() - 1]):
				continue
			var profile := _profile(stations[other], underlay, far)
			if not profile.is_empty():
				used.append(other)
				profiles.append(profile)
				break
	# Where the cross-section's reach jumps between two rows of a run (a narrow
	# inlet's fill gives way to the open slope), every station between them gets a
	# row too.
	var slot_at := 0
	while slot_at + 1 < used.size():
		var here := used[slot_at]
		var there := used[slot_at + 1]
		var inserted := 0
		if run_of[here] == run_of[there] and there - here > 1 \
		and absf(float(profiles[slot_at][profiles[slot_at].size() - 1][0]) - float(profiles[slot_at + 1][profiles[slot_at + 1].size() - 1][0])) > CAR_ROW_JUMP_M:
			for index in range(here + 1, there):
				var profile := _profile(stations[index], underlay, far)
				if not profile.is_empty():
					used.insert(slot_at + 1 + inserted, index)
					profiles.insert(slot_at + 1 + inserted, profile)
					inserted += 1
		slot_at += inserted + 1
	# Neighbouring rows are joined within a run, and across runs (a section's or
	# a segment's joint, the last round to the first) where they stand within
	# CAR_ROW_GAP_M of each other along the outline (the point between them on it,
	# not across a strip of land between two shores). Every station's room for the
	# climb (_climb_run);
	# a row's climb is the least room of the stations from the row before it to the
	# row after it (those it is joined to), so the strip between two rows keeps off
	# a way crossing it too.
	var room := PackedFloat32Array()
	room.resize(stations.size())
	for index in stations.size():
		room[index] = _climb_run(stations[index], ways)
	var climbs := PackedFloat32Array()
	climbs.resize(used.size())
	for slot in used.size():
		climbs[slot] = room[used[slot]]
	var joined := PackedByteArray()
	joined.resize(used.size())
	for slot in used.size():
		var next := (slot + 1) % used.size()
		var here: Vector3 = stations[used[slot]].inner
		var there: Vector3 = stations[used[next]].inner
		if next == slot or (run_of[used[slot]] != run_of[used[next]] and (here.distance_to(there) > CAR_ROW_GAP_M \
		or float(_nearest_edge(edges, Vector2(here.x + there.x, here.z + there.z) * 0.5).distance) > CAR_JOIN_EDGE_M)):
			continue
		joined[slot] = 1
		var least := room[used[next]]
		var index := used[slot]
		while index != used[next]:
			least = minf(least, room[index])
			index = (index + 1) % stations.size()
		climbs[slot] = minf(climbs[slot], least)
		climbs[next] = minf(climbs[next], least)
	var rows: Array[PackedVector3Array] = []
	for slot in used.size():
		var profile: Array = profiles[slot]
		rows.append(_row(stations[used[slot]], profile, climbs[slot], not far.has(_place(profile[profile.size() - 1][1]))))
	for slot in used.size():
		if joined[slot] == 0:
			continue
		var next := (slot + 1) % used.size()
		for point in rows[slot].size() - 1:
			_add_up_quad(faces, rows[slot][point], rows[next][point], rows[next][point + 1], rows[slot][point + 1])
	var body := StaticBody3D.new()
	body.name = "CarGround"
	body.collision_layer = PHYSICS_CAR_GROUND
	body.collision_mask = 0
	var slick := PhysicsMaterial.new()
	slick.friction = 0.0
	slick.bounce = 0.0
	body.physics_material_override = slick
	body.set_meta("feature_kind", "shoreline_car_ground")
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	var holder := CollisionShape3D.new()
	holder.name = "Riprap"
	holder.shape = shape
	body.add_child(holder)
	return body


## A record's segment and section, as one key.
static func _section_key(record: Dictionary) -> String:
	return "%s:%s" % [str(record.segment), str(record.get("section", 0))]


## The shoulder strips' stations in order round the island: {inner (its point on
## the outline), outer (the shoulder's far edge: the underlay vertex nearest the
## inner point), land (the land's normal at the outline)}. A shoulder vertex the
## underlay shares is a far edge, every other one a station.
static func _stations(document: Dictionary, underlay: Dictionary) -> Array[Dictionary]:
	var stations: Array[Dictionary] = []
	var seen := {}
	for record_value: Variant in document.records:
		var record: Dictionary = record_value
		if str(record.material_key) != VERGE_MATERIAL:
			continue
		var vertices := _vector3s(record.vertices)
		var normals := _vector3s(record.normals)
		for index in vertices.size():
			var at := vertices[index]
			var place := _place(at)
			if seen.has(place):
				continue
			seen[place] = true
			if _on_underlay(underlay, at):
				continue
			# A section's joint repeats its last point a centimetre or so off.
			if not stations.is_empty() and Vector2(at.x, at.z).distance_to(Vector2((stations[stations.size() - 1].inner as Vector3).x, (stations[stations.size() - 1].inner as Vector3).z)) < CAR_SAME_M:
				continue
			var outer := _nearest_underlay(underlay, at, 1.0)
			if outer.is_finite():
				stations.append({"inner": at, "outer": outer, "land": normals[index] if index < normals.size() else Vector3.UP})
	return stations


## A point's place in plan, to the centimetre (a Dictionary key).
static func _place(at: Vector3) -> Vector2i:
	return Vector2i(roundi(at.x * 100.0), roundi(at.z * 100.0))


## Whether the underlay has a vertex at this point (within a centimetre, in plan).
static func _on_underlay(underlay: Dictionary, at: Vector3) -> bool:
	for vertex: Vector3 in underlay.get(Vector2i(floori(at.x / CAR_CELL_M), floori(at.z / CAR_CELL_M)), []):
		if absf(vertex.x - at.x) < 0.01 and absf(vertex.z - at.z) < 0.01:
			return true
	return false


## The underlay vertex nearest a point (x and z) within reach, or Vector3.INF.
static func _nearest_underlay(underlay: Dictionary, at: Vector3, reach: float) -> Vector3:
	var best := Vector3.INF
	var best_distance := reach
	var cell := Vector2i(floori(at.x / CAR_CELL_M), floori(at.z / CAR_CELL_M))
	for dx in range(-1, 2):
		for dz in range(-1, 2):
			for vertex: Vector3 in underlay.get(cell + Vector2i(dx, dz), []):
				var distance := Vector2(vertex.x - at.x, vertex.z - at.z).length()
				if distance < best_distance:
					best_distance = distance
					best = vertex
	return best


## How far inland a station's climb may start: CAR_CLIMB_RUN_M, less where a
## drawn road, path or paved paint (ways' lift at least CAR_WAY_LIFT_M) lies in
## front of it, and none where the land falls away inland of the outline (the land
## edge is itself a crest: the climb then runs over the shoulder).
static func _climb_run(station: Dictionary, ways: VisibleGround) -> float:
	var inner: Vector3 = station.inner
	var outer: Vector3 = station.outer
	var inland := Vector2(inner.x - outer.x, inner.z - outer.z).normalized()
	var land: Vector3 = station.land
	if land.y > 0.1 and (land.x * inland.x + land.z * inland.y) / land.y > CAR_FALL_SLOPE:
		return 0.0
	return _way_free(Vector2(inner.x, inner.z), inland, CAR_CLIMB_RUN_M, ways)


## How far from `from` along `inland`, up to run, the ground is clear of drawn
## ways: up to the last of the points CAR_WAY_STEP_M or less apart before the
## first on one.
static func _way_free(from: Vector2, inland: Vector2, run: float, ways: VisibleGround) -> float:
	if ways == null:
		return run
	var steps := maxi(1, ceili(run / CAR_WAY_STEP_M))
	for k in steps + 1:
		var probe := from + inland * (run * k / steps)
		if ways.lift_at(probe.x, probe.y) >= CAR_WAY_LIFT_M:
			return run * maxi(k - 1, 0) / steps
	return run


## The underlay's cross-section at a station: its vertices on the line out from
## the shoulder's far edge, as [distance along it, vertex] in order, read from the
## cells the line's band crosses until it has run CAR_ROW_PAST_M past the last
## one, and up to the first that lies on the outline across a narrow inlet (far,
## _place keys); empty where it has fewer than three (or the station no
## shoulder). The band is CAR_ROW_ON_M wide at the far edge and widens by
## CAR_ROW_SPREAD a metre out, as the shoulder's short line points the way out
## only to a degree or so.
static func _profile(station: Dictionary, underlay: Dictionary, far: Dictionary) -> Array:
	var inner: Vector3 = station.inner
	var outer: Vector3 = station.outer
	var out := Vector2(outer.x - inner.x, outer.z - inner.z)
	if out.length() < 0.01:
		return []
	out = out.normalized()
	var profile: Array = []
	var visited := {}
	var step := 0.0
	var last := 0.0
	while step <= CAR_ROW_REACH_M and step <= last + CAR_ROW_PAST_M:
		var along := Vector2(outer.x, outer.z) + out * step
		var band := CAR_ROW_ON_M + CAR_ROW_SPREAD * (step + CAR_CELL_M) + 0.01
		for cell_x in range(floori((along.x - band) / CAR_CELL_M), floori((along.x + band) / CAR_CELL_M) + 1):
			for cell_z in range(floori((along.y - band) / CAR_CELL_M), floori((along.y + band) / CAR_CELL_M) + 1):
				var cell := Vector2i(cell_x, cell_z)
				if visited.has(cell):
					continue
				visited[cell] = true
				for vertex: Vector3 in underlay.get(cell, []):
					var offset := Vector2(vertex.x - outer.x, vertex.z - outer.z)
					var t := offset.dot(out)
					if t >= -0.05 and absf(offset.cross(out)) <= CAR_ROW_ON_M + CAR_ROW_SPREAD * maxf(t, 0.0):
						profile.append([t, vertex])
						last = maxf(last, t)
		step += CAR_CELL_M * 0.25
	profile.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) < float(b[0]))
	for point in profile.size():
		if float(profile[point][0]) > 0.1 and far.has(_place(profile[point][1])):
			profile.resize(point + 1)
			break
	return profile if profile.size() >= 3 else []


## One row of the cars' ground at a station, from inland out to the underlay's
## toe (profile: its cross-section, _profile): the climb's foot `climb` metres
## inland of the outline (CAR_RAMP_FOOT_M under the land there, read off the
## land's slope at the outline), the top's inner and outer ends, and
## CAR_FALL_POINTS down the fall to the toe (see PHYSICS_CAR_GROUND), which runs
## on (open: not a narrow inlet's fill ending on the land across it). The top
## starts at the shoulder's far edge, or further out where a climb no steeper
## than CAR_CLIMB_MAX needs more room.
static func _row(station: Dictionary, profile: Array, climb: float, open: bool) -> PackedVector3Array:
	var inner: Vector3 = station.inner
	var outer: Vector3 = station.outer
	var out := Vector2(outer.x - inner.x, outer.z - inner.z)
	var shoulder := out.length()
	out /= shoulder
	var crest := 0
	for point in profile.size():
		if (profile[point][1] as Vector3).y > (profile[crest][1] as Vector3).y:
			crest = point
	var crest_y := (profile[crest][1] as Vector3).y
	var toe_t := float(profile[profile.size() - 1][0])
	# The top's outer end: where the underlay first falls CAR_TOP_DROP_M under its crest.
	var end_t := toe_t
	for point in range(crest + 1, profile.size()):
		var below := (profile[point][1] as Vector3).y
		if below < crest_y - CAR_TOP_DROP_M:
			var above := (profile[point - 1][1] as Vector3).y
			end_t = lerpf(float(profile[point - 1][0]), float(profile[point][0]), clampf((above - crest_y + CAR_TOP_DROP_M) / maxf(above - below, 1e-6), 0.0, 1.0))
			break
	end_t = maxf(minf(minf(end_t, float(profile[crest][0]) + CAR_TOP_MAX_M), toe_t - CAR_FALL_MIN_M), 0.0)
	# The foot, and the climb from it, by distance out from the outline (the
	# foot's is -climb).
	var land: Vector3 = station.land
	var inland := Vector3(-out.x, 0.0, -out.y)
	var rise := 0.0 if land.y <= 0.1 else -(land.x * inland.x + land.z * inland.z) / land.y
	var foot := Vector3(inner.x, inner.y + minf(rise, 0.0) * climb - CAR_RAMP_FOOT_M, inner.z) + inland * climb
	var top_y := crest_y + CAR_LIFT_M
	var top_d := maxf(minf(maxf(shoulder, (top_y - foot.y) / CAR_CLIMB_MAX - climb), shoulder + end_t - 0.05), 0.05 - climb)
	var outward := Vector3(out.x, 0.0, out.y)
	var top_at := inner + outward * top_d
	var row := PackedVector3Array([foot, Vector3(top_at.x, minf(top_y, foot.y + CAR_CLIMB_MAX * (top_d + climb)), top_at.z)])
	for k in CAR_FALL_POINTS + 1:
		row.append(_profile_at(profile, end_t + (toe_t - end_t) * float(k) / float(CAR_FALL_POINTS)) + Vector3.UP * CAR_LIFT_M)
	# A falling toe runs on CAR_TOE_PAST_M down its own slope, so where the toe
	# line bends out between two rows the drawn slope there is covered too.
	var toe := row[row.size() - 1]
	var before := row[row.size() - 2]
	var run_out := Vector2(toe.x - before.x, toe.z - before.z).length()
	if open and toe.y < before.y and run_out > 0.01:
		row[row.size() - 1] = toe + (toe - before) * (CAR_TOE_PAST_M / run_out)
	return row


## The cross-section's point at distance t out (between its vertices).
static func _profile_at(profile: Array, t: float) -> Vector3:
	for point in range(1, profile.size()):
		var t1 := float(profile[point][0])
		if t1 >= t:
			var t0 := float(profile[point - 1][0])
			var share := 0.0 if t1 - t0 < 1e-6 else (t - t0) / (t1 - t0)
			return (profile[point - 1][1] as Vector3).lerp(profile[point][1] as Vector3, clampf(share, 0.0, 1.0))
	return profile[profile.size() - 1][1]


## The causeway's barrier (owner, 2026-11-10: cars stop where the island's
## outline crosses the Yerba Buena causeway, as the player on foot does): a
## car-only wall on PHYSICS_CAR_GROUND along every outline edge that the roads and
## paths running on onto Yerba Buena cross (their boundary-attached records,
## GeneratedWorldContract.YBI_CONTINUATION_SOURCE_KEYS: crossings, each a
## PackedVector3Array of a record's vertices), from CAR_BARRIER_UNDER_M under the
## lowest of their points on it to CAR_BARRIER_OVER_M over the highest. Solid both
## ways, with ordinary friction and bounce; null when nothing crosses.
func _car_barrier(rings: Array[Dictionary], crossings: Array) -> StaticBody3D:
	if rings.is_empty() or crossings.is_empty():
		return null
	var edges := _edge_grid(rings)
	# Each crossed edge's lowest and highest crossing point.
	var heights := {}
	for vertices: PackedVector3Array in crossings:
		for vertex: Vector3 in vertices:
			var nearest := _nearest_edge(edges, Vector2(vertex.x, vertex.z))
			if float(nearest.distance) <= CAR_EDGE_ON_M * 2.5:
				var span: Vector2 = heights.get(int(nearest.edge), Vector2(INF, -INF))
				heights[int(nearest.edge)] = Vector2(minf(span.x, vertex.y), maxf(span.y, vertex.y))
	if heights.is_empty():
		return null
	var faces := PackedVector3Array()
	for edge: int in heights:
		var a: Vector2 = edges.starts[edge]
		var b: Vector2 = edges.ends[edge]
		var span: Vector2 = heights[edge]
		var low := span.x - CAR_BARRIER_UNDER_M
		var high := span.y + CAR_BARRIER_OVER_M
		var corners := [Vector3(a.x, low, a.y), Vector3(b.x, low, b.y), Vector3(b.x, high, b.y), Vector3(a.x, high, a.y)]
		faces.append_array(PackedVector3Array([corners[0], corners[1], corners[2], corners[0], corners[2], corners[3]]))
	var body := StaticBody3D.new()
	body.name = "CarBarrier"
	body.collision_layer = PHYSICS_CAR_GROUND
	body.collision_mask = 0
	body.set_meta("feature_kind", "shoreline_car_barrier")
	var shape := ConcavePolygonShape3D.new()
	shape.backface_collision = true
	shape.set_faces(faces)
	var holder := CollisionShape3D.new()
	holder.name = "Causeway"
	holder.shape = shape
	body.add_child(holder)
	return body


## The vertices of the context's boundary-attached records of the roads and paths
## that run on from the causeway onto Yerba Buena (the crossings _car_barrier
## takes): one PackedVector3Array a record.
static func causeway_crossings(context: Dictionary) -> Array:
	var crossings: Array = []
	for record_value: Variant in context.get("boundary_attached_visuals", []):
		var record: Dictionary = record_value
		for key_value: Variant in record.get("source_keys", []):
			if str(key_value) in GeneratedWorldContract.YBI_CONTINUATION_SOURCE_KEYS:
				crossings.append(_vector3s(record.vertices))
				break
	return crossings


## Two triangles of the quad a, b, c, d (in order round it) facing up, wound as
## the other collision faces are (Godot's clockwise front, seen from above);
## a triangle with no area (two of its corners at one place) is left out.
static func _add_up_quad(faces: PackedVector3Array, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	for triangle: Array in [[a, b, c], [a, c, d]]:
		var first: Vector3 = triangle[0]
		var second: Vector3 = triangle[1]
		var third: Vector3 = triangle[2]
		if (second - first).cross(third - first).length_squared() < 1e-8:
			continue
		if Plane(first, second, third).normal.y < 0.0:
			var swap := second
			second = third
			third = swap
		faces.append(first)
		faces.append(second)
		faces.append(third)


## The playable outline's rings as [{points (x, z), hole}], from the validated
## boundary's components (WorldBoundary.configure's shape).
static func _outline_rings(boundary: Dictionary) -> Array[Dictionary]:
	var rings: Array[Dictionary] = []
	for component_value: Variant in boundary.get("components", []):
		var component: Dictionary = component_value
		var all: Array = [component.get("outer", [])]
		all.append_array(component.get("holes", []))
		for index in all.size():
			var points := PackedVector2Array()
			for point: Variant in all[index]:
				points.append(Vector2(float(point[0]), float(point[1])))
			if points.size() >= 3:
				rings.append({"points": points, "hole": index > 0})
	return rings


## The outline's edges for _nearest_edge: their ends, their unit normals away
## from the land, and the edges near each OUTLINE_CELL_M cell (within 1 m of it).
static func _edge_grid(rings: Array[Dictionary]) -> Dictionary:
	var starts := PackedVector2Array()
	var ends := PackedVector2Array()
	var outward := PackedVector2Array()
	var cells := {}
	for ring: Dictionary in rings:
		var points: PackedVector2Array = ring.points
		var area := 0.0
		for index in points.size():
			var previous := points[(index + points.size() - 1) % points.size()]
			area += previous.x * points[index].y - points[index].x * previous.y
		# The land lies left of an outer ring's edges when its points turn
		# counterclockwise in x and z (positive area), right of them otherwise; a
		# hole's the other way round.
		var away := (-1.0 if area > 0.0 else 1.0) * (-1.0 if bool(ring.hole) else 1.0)
		for index in points.size():
			var a := points[(index + points.size() - 1) % points.size()]
			var b := points[index]
			if a.distance_to(b) < 1e-6:
				continue
			var along := (b - a).normalized()
			var edge := starts.size()
			starts.append(a)
			ends.append(b)
			outward.append(Vector2(-along.y, along.x) * away)
			var low := Vector2i(floori((minf(a.x, b.x) - 1.0) / OUTLINE_CELL_M), floori((minf(a.y, b.y) - 1.0) / OUTLINE_CELL_M))
			var high := Vector2i(floori((maxf(a.x, b.x) + 1.0) / OUTLINE_CELL_M), floori((maxf(a.y, b.y) + 1.0) / OUTLINE_CELL_M))
			for cell_x in range(low.x, high.x + 1):
				for cell_z in range(low.y, high.y + 1):
					var cell := Vector2i(cell_x, cell_z)
					# An Array, which the dictionary holds by reference: appending to a
					# packed array taken out of it would change only a copy.
					if not cells.has(cell):
						cells[cell] = []
					(cells[cell] as Array).append(edge)
	return {"starts": starts, "ends": ends, "outward": outward, "cells": cells}


## The outline's nearest edge to a point (x, z) within about 1 m: {distance,
## edge (its number in edges), outward (unit, away from the land; at a corner the
## mean of both edges')}; distance INF and edge -1 when no edge is that near.
static func _nearest_edge(edges: Dictionary, point: Vector2) -> Dictionary:
	var cell := Vector2i(floori(point.x / OUTLINE_CELL_M), floori(point.y / OUTLINE_CELL_M))
	var near: Array = edges.cells.get(cell, [])
	var best := INF
	var best_edge := -1
	var distances := PackedFloat32Array()
	distances.resize(near.size())
	for slot in near.size():
		var a: Vector2 = edges.starts[int(near[slot])]
		var run: Vector2 = (edges.ends[int(near[slot])] as Vector2) - a
		var t := clampf((point - a).dot(run) / maxf(run.length_squared(), 1e-9), 0.0, 1.0)
		distances[slot] = point.distance_to(a + run * t)
		if distances[slot] < best:
			best = distances[slot]
			best_edge = int(near[slot])
	var outward := Vector2.ZERO
	for slot in near.size():
		if distances[slot] <= best + 0.001:
			outward += edges.outward[int(near[slot])]
	return {"distance": best, "edge": best_edge, "outward": outward.normalized() if outward.length() > 1e-6 else Vector2.ZERO}


## An ArrayMesh from a mesh dictionary: vertices and normals (packed Vector3
## arrays, or flat number arrays as in the prototypes), indices, and optional
## uvs and lods ([{error_m, indices}]). The generated contract winds triangles
## counterclockwise around their outward normals; Godot treats clockwise as
## front-facing, so each triplet is turned once here, as world_chunk_builder.gd
## does for chunk records. A mesh with UVs (the shoulder) also gets tangents
## for the ground cover's normal map.
static func _array_mesh(record: Dictionary, material: Material) -> ArrayMesh:
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = _vector3s(record.vertices)
	arrays[Mesh.ARRAY_NORMAL] = _vector3s(record.normals)
	arrays[Mesh.ARRAY_INDEX] = _clockwise(record.indices)
	# Coarser index sets over the same vertices, keyed by their error for a 1 m stone.
	var lods := {}
	for lod_value: Variant in record.get("lods", []):
		var lod: Dictionary = lod_value
		lods[float(lod.error_m)] = _clockwise(lod.indices)
	var mesh := ArrayMesh.new()
	if record.has("uvs"):
		var uvs := PackedVector2Array()
		var source: Variant = record.uvs
		if source is PackedVector2Array:
			uvs = source
		else:
			var flat: Array = source
			for index in range(0, flat.size(), 2):
				uvs.append(Vector2(float(flat[index]), float(flat[index + 1])))
		arrays[Mesh.ARRAY_TEX_UV] = uvs
		var tool := SurfaceTool.new()
		tool.create_from_arrays(arrays)
		tool.generate_tangents()
		mesh = tool.commit()
	else:
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, [], lods)
	mesh.surface_set_material(0, material)
	mesh.resource_name = str(record.get("object_key", record.get("id", "shoreline")))
	return mesh


## Packed Vector3 values as they are, or a flat [x, y, z, ...] number array as Vector3s.
static func _vector3s(source: Variant) -> PackedVector3Array:
	if source is PackedVector3Array:
		return source
	var values := PackedVector3Array()
	var flat: Array = source
	for index in range(0, flat.size(), 3):
		values.append(Vector3(float(flat[index]), float(flat[index + 1]), float(flat[index + 2])))
	return values


## Index triplets turned from counterclockwise to Godot's clockwise.
static func _clockwise(source: Variant) -> PackedInt32Array:
	var values: PackedInt32Array = source if source is PackedInt32Array else PackedInt32Array(source as Array)
	var indices := PackedInt32Array()
	indices.resize(values.size())
	for index in range(0, values.size(), 3):
		indices[index] = values[index]
		indices[index + 1] = values[index + 2]
		indices[index + 2] = values[index + 1]
	return indices
