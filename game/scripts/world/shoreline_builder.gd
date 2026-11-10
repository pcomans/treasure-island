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
## (_inland_body), and the cars' ground over the riprap (_car_ground), which only
## cars and shoved K-rails meet. The band inside the outline is an ordinary chunk
## overlay; it and the shoulder share
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
## (vehicle_manager.gd) look for, and the chase camera's arm stops at; the
## player, the on-foot camera and the spray never see it. It is the underlay
## slope and the shoulder lifted CAR_LIFT_M, about the tops of the stones on them
## (the generated stones stand 0.3-0.4 m over the underlay at the median and
## 0.55-0.7 m at the 90th percentile, measured round the island), with a ramp up
## to that at the outline from CAR_RAMP_IN_M inside it, its foot CAR_RAMP_FOOT_M
## under the land edge (about 16 degrees), so a car climbs over the crest's
## stones instead of running into them. A shore with no shoulder (the slope
## running from the land edge itself) lifts its slope gradually instead, fully
## CAR_LIFT_RUN_M out from the edge. It ends at the underlay's toe a little over
## the water, so a car rolls off its end into the bay. It is frictionless (a
## car's wheels grip it through their own forces), so a car whose belly touches
## the crest slides on over it instead of hanging there.
const PHYSICS_CAR_GROUND := 1 << 5
const CAR_LIFT_M := 0.55
const CAR_RAMP_IN_M := 2.2
const CAR_RAMP_FOOT_M := 0.1
const CAR_LIFT_RUN_M := 0.6
## A shoulder vertex this close to the outline is on it (the ramp's inner edge).
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
## builder report. boundary is the validated playable outline (its components'
## outer rings and holes, as WorldBoundary.configure takes it), for the cars'
## ground; without it there is none.
func build(document: Dictionary, boundary: Dictionary = {}) -> Dictionary:
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
	var car_ground := _car_ground(document, _outline_rings(boundary))
	if car_ground != null:
		root.add_child(car_ground)
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


## The cars' ground (PHYSICS_CAR_GROUND): one body, a shape for each underlay
## slope record and each shoulder record, both lifted CAR_LIFT_M, the shoulder's
## with a ramp from its edge on the outline down to feet CAR_RAMP_IN_M inland and
## CAR_RAMP_FOOT_M lower, so they make one surface from the land to the toe and
## a car is up at the stones' tops before the crest's first stones. A slope whose
## segment has no shoulder lifts with its distance from the outline instead. The
## concrete closures (pier faces, the north slipway) are solid as drawn, so a car
## drives down the slipway into the water. rings are the outline's
## (_outline_rings); with none there is no body (null).
func _car_ground(document: Dictionary, rings: Array[Dictionary]) -> StaticBody3D:
	if rings.is_empty():
		return null
	var edges := _edge_grid(rings)
	var shouldered := {}
	for record_value: Variant in document.records:
		var record: Dictionary = record_value
		if str(record.material_key) == VERGE_MATERIAL:
			shouldered[str(record.segment)] = true
	var body := StaticBody3D.new()
	body.name = "CarGround"
	body.collision_layer = PHYSICS_CAR_GROUND
	body.collision_mask = 0
	var slick := PhysicsMaterial.new()
	slick.friction = 0.0
	slick.bounce = 0.0
	body.physics_material_override = slick
	body.set_meta("feature_kind", "shoreline_car_ground")
	var lift := Vector3.UP * CAR_LIFT_M
	for record_value: Variant in document.records:
		var record: Dictionary = record_value
		var key := str(record.material_key)
		if key != SLOPE_MATERIAL and key != VERGE_MATERIAL and key != WALL_MATERIAL:
			continue
		var vertices := _vector3s(record.vertices)
		var moved := PackedVector3Array()
		moved.resize(vertices.size())
		# A shoulder vertex on the outline: where its ramp's foot lies (else INF).
		var feet := PackedVector3Array()
		feet.resize(vertices.size())
		var gradual := key == SLOPE_MATERIAL and not shouldered.has(str(record.segment))
		for index in vertices.size():
			var at := vertices[index]
			feet[index] = Vector3.INF
			if key == WALL_MATERIAL:
				moved[index] = at
				continue
			if key == SLOPE_MATERIAL and not gradual:
				moved[index] = at + lift
				continue
			var edge := _nearest_edge(edges, Vector2(at.x, at.z))
			if gradual:
				moved[index] = at + lift * clampf(float(edge.distance) / CAR_LIFT_RUN_M, 0.0, 1.0)
				continue
			moved[index] = at + lift
			if float(edge.distance) < CAR_EDGE_ON_M:
				var inland: Vector2 = -(edge.outward as Vector2) * CAR_RAMP_IN_M
				feet[index] = Vector3(at.x + inland.x, at.y - CAR_RAMP_FOOT_M, at.z + inland.y)
		var faces := PackedVector3Array()
		var turned := _clockwise(record.indices)
		for index_value: int in turned:
			faces.append(moved[index_value])
		# The ramp: below each shoulder edge on the outline (a triangle's two
		# vertices on it), a quad from the lifted edge down to its feet inland.
		for at in range(0, turned.size(), 3):
			var on: Array[int] = []
			for corner in 3:
				if feet[turned[at + corner]].is_finite():
					on.append(turned[at + corner])
			if on.size() == 2:
				_add_up_quad(faces, feet[on[0]], feet[on[1]], moved[on[1]], moved[on[0]])
		var shape := ConcavePolygonShape3D.new()
		shape.set_faces(faces)
		var holder := CollisionShape3D.new()
		holder.name = str(record.object_key).validate_node_name()
		holder.shape = shape
		body.add_child(holder)
	return body


## Two triangles of the quad a, b, c, d (in order round it) facing up, wound as
## the other collision faces are (Godot's clockwise front, seen from above).
static func _add_up_quad(faces: PackedVector3Array, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	for triangle: Array in [[a, b, c], [a, c, d]]:
		var first: Vector3 = triangle[0]
		var second: Vector3 = triangle[1]
		var third: Vector3 = triangle[2]
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
## outward (unit, away from the land; at a corner the mean of both edges')};
## distance INF when no edge is that near.
static func _nearest_edge(edges: Dictionary, point: Vector2) -> Dictionary:
	var cell := Vector2i(floori(point.x / OUTLINE_CELL_M), floori(point.y / OUTLINE_CELL_M))
	var near: Array = edges.cells.get(cell, [])
	var best := INF
	var distances := PackedFloat32Array()
	distances.resize(near.size())
	for slot in near.size():
		var a: Vector2 = edges.starts[int(near[slot])]
		var run: Vector2 = (edges.ends[int(near[slot])] as Vector2) - a
		var t := clampf((point - a).dot(run) / maxf(run.length_squared(), 1e-9), 0.0, 1.0)
		distances[slot] = point.distance_to(a + run * t)
		best = minf(best, distances[slot])
	var outward := Vector2.ZERO
	for slot in near.size():
		if distances[slot] <= best + 0.001:
			outward += edges.outward[int(near[slot])]
	return {"distance": best, "outward": outward.normalized() if outward.length() > 1e-6 else Vector2.ZERO}


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
