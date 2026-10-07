class_name NavyChapel187StandaloneHeroPrototype
extends Node3D

const CONFIG_PATH := "res://game/resources/facades/navy_chapel_187_standalone_hero_prototype.json"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const SOURCE_KEY := "w291189336"
const WALL_KEY := "building:w291189336:wall"
const ROOF_KEY := "building:w291189336:roof"
const WALL_RUN_COUNT := 34
const OBSERVED_SSE_RUNS := [9, 10]
const OBSERVED_PARTIAL_SIDE_RUNS := [11, 12, 13]
const PROTECTED_RUNS := [0, 1, 2, 3, 4, 5, 6, 7, 8, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33]
const PHYSICS_WORLD_SOLID := 1 << 0
const RENDER_WORLD_VISIBLE := 1 << 0
const RENDER_BUILDING_WALL := 1 << 1

const ACCEPTED_CREAM := preload("res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_inferred_cream_structure.tres")
const TIMBER := preload("res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_timber.tres")
const INFERRED_CREAM_STRUCTURE := preload("res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_inferred_cream_structure.tres")
const PROTECTED_NEUTRAL := preload("res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_protected_neutral.tres")
const PALE_TRIM := preload("res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_pale_trim.tres")
const OPAQUE_OPENING := preload("res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_opaque_opening.tres")
const NEUTRAL_ROOF := preload("res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_neutral_roof.tres")

@export var auto_configure_from_frozen_source := true

var _configured := false
var _last_result: Dictionary = {}


func _ready() -> void:
	if auto_configure_from_frozen_source and not _configured:
		var result := configure_from_frozen_source()
		if not bool(result.get("ok", false)):
			push_error("Navy Chapel standalone hero prototype failed closed: %s" % str(result.get("message", "unknown error")))


static func matches_record_pair(wall_record: Dictionary, roof_record: Dictionary) -> bool:
	return _record_contract_matches(wall_record, WALL_KEY, "building_wall", 408, 204) \
		and _record_contract_matches(roof_record, ROOF_KEY, "building_roof", 60, 54)


static func build_for_records(wall_record: Dictionary, roof_record: Dictionary) -> Dictionary:
	var prototype := NavyChapel187StandaloneHeroPrototype.new()
	prototype.auto_configure_from_frozen_source = false
	var result := prototype.configure_records(wall_record, roof_record)
	if not bool(result.get("ok", false)):
		prototype.free()
		return result
	result["node"] = prototype
	return result


func configure_from_frozen_source() -> Dictionary:
	var chunk := _json(CHUNK_PATH)
	if chunk.is_empty():
		return _failure("navy_chapel_source_chunk", "Frozen Chapel source chunk could not be loaded.")
	var wall_record := _record_for_key(chunk.get("records", []) as Array, WALL_KEY)
	var roof_record := _record_for_key(chunk.get("records", []) as Array, ROOF_KEY)
	return configure_records(wall_record, roof_record)


func configure_records(wall_record: Dictionary, roof_record: Dictionary) -> Dictionary:
	if _configured:
		return _failure("navy_chapel_duplicate_configuration", "The standalone Chapel prototype is already configured.")
	var config := _json(CONFIG_PATH)
	if not _config_contract_matches(config):
		return _failure("navy_chapel_config_contract", "The standalone Chapel truth/configuration contract did not match.")
	if not matches_record_pair(wall_record, roof_record):
		return _failure("navy_chapel_source_contract", "The exact w291189336 wall+roof pair did not match the fail-closed prototype seam.")

	return _compose_study(wall_record, roof_record, config)


# Reuse the Chapel source frame and complete mesh emitters. Exterior dimensions
# are production inference from the September 2025 SSE view, never surveyed.
func _compose_study(wall: Dictionary, roof_record: Dictionary, config: Dictionary) -> Dictionary:
	var shell := _bucket()
	var protected := _bucket()
	var roofing := _bucket()
	var trim := _bucket()
	var cross := _bucket()
	var glass := _bucket()
	var wood := _bucket()
	var inf := (config.production_inference_m as Dictionary).duplicate(true)
	var frame := _chain_basis(wall, OBSERVED_SSE_RUNS)
	var c: Vector3 = (frame.start as Vector3).lerp(frame.end as Vector3, 0.5)
	c.y = 0.0
	var t: Vector3 = frame.tangent
	var n: Vector3 = frame.normal
	var width := float(inf.main_gable_width)
	var eave := float(inf.main_gable_eave_y)
	var ridge := float(inf.main_gable_ridge_y)
	var length := float(inf.main_gable_length)
	var wing_junctions := [[], []]
	for run in range(WALL_RUN_COUNT):
		var f := _run_frame(wall, run)
		var start: Vector3 = f.start
		var finish: Vector3 = f.end
		var cuts: Array[float] = [0.0, 1.0]
		for side in range(2):
			var axis: Vector3 = t if side == 0 else -t
			var av := (start - c).dot(axis)
			var bv := (finish - c).dot(axis)
			if absf(bv - av) > 0.00001:
				var fraction := (width * 0.5 + 0.10 - av) / (bv - av)
				if fraction > 0.0 and fraction < 1.0:
					cuts.append(fraction)
					wing_junctions[side].append(start.lerp(finish, fraction))
		cuts.sort()
		for i in range(cuts.size() - 1):
			var left := start.lerp(finish, cuts[i])
			var right := start.lerp(finish, cuts[i + 1])
			var middle := (left + right) * 0.5
			var top := 8.0 if absf((middle - c).dot(t)) > width * 0.5 + 0.10 else eave
			var bucket := shell if run in OBSERVED_SSE_RUNS or run in OBSERVED_PARTIAL_SIDE_RUNS else protected
			_append_quad(bucket, left, right, Vector3(right.x, top, right.z), Vector3(left.x, top, left.z), f.normal)
	# Neutral nave-side infill across the source-footprint wing projections.
	# The roof helper supplies slopes/end gables, not these internal junctions.
	# Derive both ends from the existing high/low perimeter-wall transitions;
	# inset the infill 30mm beneath the unchanged eave, inside the footprint.
	for side in range(2):
		var joins: Array = wing_junctions[side]
		assert(joins.size() == 2, "Chapel wing junction requires two source transitions")
		var outward: Vector3 = t if side == 0 else -t
		var first: Vector3 = joins[0]
		var last: Vector3 = joins[1]
		if (first - c).dot(n) < (last - c).dot(n):
			var swap := first
			first = last
			last = swap
		first.y = 8.0
		last.y = 8.0
		var front := first - outward * 0.13
		var rear := last - outward * 0.13
		var rise := Vector3.UP * (eave - 8.0)
		_append_quad(protected, front, rear, rear + rise, front + rise, outward)
		_append_quad(protected, first, front, front + rise, first + rise, n)
		_append_quad(protected, rear, last, last + rise, rear + rise, -n)
	# Lower source-footprint closure remains beneath the pitched nave/wing.
	var lower := roof_record.duplicate(true)
	for k in range(1, lower.vertices.size(), 3):
		lower.vertices[k] = 8.0
	_append_record_mesh(roofing, lower)
	var unused := _bucket()
	_append_gabled_roof(shell, protected, roofing, unused, c + Vector3.UP * eave, t, n, inf)
	for wing: Array in [[1.0, 29.86, 7.93, 8.68], [-1.0, 29.705, 7.93, 9.0]]:
		var direction: float = wing[0]
		var wi := inf.duplicate(true)
		wi.main_gable_width = wing[2]
		wi.main_gable_length = wing[3]
		wi.main_gable_eave_y = 8.0
		wi.main_gable_ridge_y = 10.25
		var wc := c + t * 8.18 * direction - n * float(wing[1]) + Vector3.UP * 8.0
		_append_gabled_roof(protected, protected, roofing, unused, wc, -n, -t * direction, wi)
	# No opening schedule on protected runs 17/18 or any other unseen face.
	_append_belfry(shell, roofing, cross, unused, c, t, n, inf)
	_append_box(trim, c + n * 0.85 + Vector3.UP * 7.25, t, n, 6.0, 0.16, 1.7)
	for i in range(2):
		var x: float = [-2.35, 2.35][i]
		# Actual generated land corner minima; visible area is 40mm above land.
		var base_y: float = [4.02523, 3.991914][i]
		_append_box(trim, c + t * x + n * 1.35 + Vector3.UP * ((base_y + 7.24) * 0.5), t, n, 0.12, 7.24 - base_y, 0.12)
	_append_box(wood, c + n * 0.045 + Vector3.UP * 5.395, t, n, 1.6, 2.80, 0.08)
	_append_frame(trim, c + n * 0.11 + Vector3.UP * 5.42, t, n, 1.6, 2.75, 0.12, 0.15)
	for x: float in [-1.55, 1.55]:
		_study_window(glass, trim, c + t * x, 4.35, 6.96, 1.04, t, n, 2)
	for x: float in [-5.7, 5.7]:
		_study_window(glass, trim, c + t * x, 5.0, 6.25, 0.62, t, n, 1)
	# Finite peaked glazing follows the observed gable, opaque central panel.
	for column in range(7):
		var x := (column - 3) * 0.57
		_study_window(glass, trim, c + t * x, 8.05, ridge - 0.58 - absf(x) * 0.68, 0.48, t, n, 2)
	_append_box(wood, c + n * 0.105 + Vector3.UP * 9.73, t, n, 1.02, 3.2, 0.07)
	for station: float in [2.0, 5.4, 8.8]:
		var f := _chain_frame(wall, OBSERVED_PARTIAL_SIDE_RUNS, station)
		for x: float in [-0.62, 0.0, 0.62]:
			_study_window(glass, trim, (f.wall_anchor as Vector3) + (f.tangent as Vector3) * x, 5.25, 9.1, 0.5, f.tangent, f.normal, 1)
	# Thin eave/rake boards, not new hidden facade ornament.
	for sign_value: float in [-1.0, 1.0]:
		var start := c + t * width * 0.5 * sign_value + Vector3.UP * eave
		_append_box(trim, start - n * length * 0.5, t, n, 0.16, 0.18, length + 0.16)
		var end := c + Vector3.UP * ridge
		var axis := (end - start).normalized()
		_append_box(trim, (start + end) * 0.5 + n * 0.06, axis, n, start.distance_to(end) + 0.12, 0.16, 0.18)
	var specs: Array = [
		["ProtectedExactWallAndRearClosure", protected, PROTECTED_NEUTRAL, RENDER_BUILDING_WALL, false],
		["InferredCreamSSEGableBelfryEntry", shell, INFERRED_CREAM_STRUCTURE, RENDER_BUILDING_WALL, false],
		["NeutralRoofAndCap", roofing, NEUTRAL_ROOF, RENDER_WORLD_VISIBLE, true],
		["ObservedPaleTrim", trim, PALE_TRIM, RENDER_BUILDING_WALL, false],
		["ObservedCross", cross, PALE_TRIM, RENDER_WORLD_VISIBLE, true],
		["OpaqueExteriorOpenings", glass, OPAQUE_OPENING, RENDER_BUILDING_WALL, false],
		["ObservedOpaquePanelAndDoor", wood, TIMBER, RENDER_BUILDING_WALL, false],
	]
	var wall_faces := PackedVector3Array()
	var roof_faces := PackedVector3Array()
	var visual_triangles := 0
	for spec: Array in specs:
		var bucket: Dictionary = spec[1]
		add_child(_mesh_instance(spec[0], bucket, spec[2], spec[3]))
		var points: Array = bucket.vertices
		var normals: Array = bucket.normals
		var indices: Array = bucket.indices
		visual_triangles += indices.size() / 3
		for offset in range(0, indices.size(), 3):
			# Semantic roof/cross objects reject spray; top/bottom faces of wall
			# details also remain solid non-wall landing/occlusion surfaces.
			var landing := bool(spec[4]) or absf((normals[int(indices[offset])] as Vector3).y) > 0.65
			for corner in range(3):
				if landing:
					roof_faces.append(points[int(indices[offset + corner])])
				else:
					wall_faces.append(points[int(indices[offset + corner])])
	var combined := _bucket()
	for point: Vector3 in wall_faces + roof_faces:
		(combined.vertices as Array).append(point)
		(combined.indices as Array).append((combined.indices as Array).size())
	add_child(_collision_body(combined))
	set_meta("chapel_wall_faces", wall_faces)
	set_meta("chapel_roof_faces", roof_faces)
	set_meta("source_key", SOURCE_KEY)
	set_meta("horizontal_source_footprint_changed", false)
	set_meta("protected_runs_have_modules", false)
	set_meta("vertical_and_roof_geometry_truth_class", "reversible_production_inference")
	set_meta("observed_sse_run_indices", OBSERVED_SSE_RUNS)
	set_meta("observed_partial_side_run_indices", OBSERVED_PARTIAL_SIDE_RUNS)
	set_meta("protected_run_indices", PROTECTED_RUNS)
	_configured = true
	_last_result = {"ok": true, "node": self, "visual_triangles": visual_triangles, "metadata": {"source_key": SOURCE_KEY, "interior_modeled": false}}
	return _last_result.duplicate(true)


func _study_window(glass: Dictionary, trim: Dictionary, anchor: Vector3, bottom: float, top: float, width: float, t: Vector3, n: Vector3, dividers: int) -> void:
	var center := Vector3(anchor.x, (bottom + top) * 0.5, anchor.z) + n * 0.035
	_append_box(glass, center, t, n, width, top - bottom, 0.06)
	_append_frame(trim, center + n * 0.055, t, n, width, top - bottom, 0.065, 0.12)
	for i in range(1, dividers + 1):
		var bar := center + n * 0.055
		bar.y = lerpf(bottom, top, float(i) / float(dividers + 1))
		_append_box(trim, bar, t, n, width, 0.055, 0.12)


func get_build_result() -> Dictionary:
	return _last_result.duplicate(true)


func _append_gabled_roof(
		cream: Dictionary,
		protected: Dictionary,
		roof: Dictionary,
		collision: Dictionary,
		front_center: Vector3,
		tangent: Vector3,
		outward: Vector3,
		inference: Dictionary) -> void:
	var width := float(inference.main_gable_width)
	var length := float(inference.main_gable_length)
	var eave_y := float(inference.main_gable_eave_y)
	var ridge_y := float(inference.main_gable_ridge_y)
	var inward := -outward
	var start_center := front_center + inward * float(inference.main_gable_front_inset)
	start_center.y = eave_y
	var end_center := start_center + inward * length
	var front_left := start_center - tangent * width * 0.5
	var front_right := start_center + tangent * width * 0.5
	var rear_left := end_center - tangent * width * 0.5
	var rear_right := end_center + tangent * width * 0.5
	var front_ridge := Vector3(start_center.x, ridge_y, start_center.z)
	var rear_ridge := Vector3(end_center.x, ridge_y, end_center.z)
	var left_normal := _upward_normal(front_left, rear_left, rear_ridge)
	var right_normal := _upward_normal(front_ridge, rear_ridge, rear_right)
	_append_quad(roof, front_left, rear_left, rear_ridge, front_ridge, left_normal)
	_append_quad(collision, front_left, rear_left, rear_ridge, front_ridge, left_normal)
	_append_quad(roof, front_ridge, rear_ridge, rear_right, front_right, right_normal)
	_append_quad(collision, front_ridge, rear_ridge, rear_right, front_right, right_normal)
	_append_triangle(cream, front_left, front_right, front_ridge, outward)
	_append_triangle(collision, front_left, front_right, front_ridge, outward)
	_append_triangle(protected, rear_right, rear_left, rear_ridge, inward)
	_append_triangle(collision, rear_right, rear_left, rear_ridge, inward)


func _append_belfry(
		cream: Dictionary,
		roof: Dictionary,
		trim: Dictionary,
		collision: Dictionary,
		front_center: Vector3,
		tangent: Vector3,
		outward: Vector3,
		inference: Dictionary) -> void:
	var center := front_center - outward * float(inference.belfry_center_inward_from_sse_m)
	var base_y := float(inference.belfry_base_y)
	var wall_top_y := float(inference.belfry_wall_top_y)
	center.y = (base_y + wall_top_y) * 0.5
	var width := float(inference.belfry_plan_width)
	var depth := float(inference.belfry_plan_depth)
	_append_box(cream, center, tangent, outward, width, wall_top_y - base_y, depth)
	_append_box(collision, center, tangent, outward, width, wall_top_y - base_y, depth)
	var cap_center := Vector3(center.x, wall_top_y, center.z)
	var half_w := width * 0.5
	var half_d := depth * 0.5
	var fl := cap_center - tangent * half_w + outward * half_d
	var fr := cap_center + tangent * half_w + outward * half_d
	var br := cap_center + tangent * half_w - outward * half_d
	var bl := cap_center - tangent * half_w - outward * half_d
	var apex := Vector3(center.x, float(inference.belfry_cap_apex_y), center.z)
	for triangle: Array in [[fl, fr, apex], [fr, br, apex], [br, bl, apex], [bl, fl, apex]]:
		var a := triangle[0] as Vector3
		var b := triangle[1] as Vector3
		var c := triangle[2] as Vector3
		var normal := _outward_up_normal(a, b, c, center)
		_append_triangle(roof, a, b, c, normal)
		_append_triangle(collision, a, b, c, normal)
	var member := float(inference.cross_member_thickness)
	var vertical_center := Vector3(center.x, float(inference.cross_vertical_center_y), center.z)
	_append_box(trim, vertical_center, tangent, outward, member, float(inference.cross_vertical_height), member)
	_append_box(collision, vertical_center, tangent, outward, member, float(inference.cross_vertical_height), member)
	var horizontal_center := Vector3(center.x, float(inference.cross_horizontal_center_y), center.z)
	_append_box(trim, horizontal_center, tangent, outward, float(inference.cross_horizontal_width), member, member)
	_append_box(collision, horizontal_center, tangent, outward, float(inference.cross_horizontal_width), member, member)


func _append_front_composition(
		cream: Dictionary,
		trim: Dictionary,
		opening: Dictionary,
		collision: Dictionary,
		front_center: Vector3,
		tangent: Vector3,
		outward: Vector3,
		inference: Dictionary) -> void:
	var entry_base := float(inference.entry_base_y)
	var entry_height := float(inference.entry_height)
	var entry_depth := float(inference.entry_depth)
	var entry_center := Vector3(front_center.x, entry_base + entry_height * 0.5, front_center.z) + outward * entry_depth * 0.5
	_append_box(cream, entry_center, tangent, outward, float(inference.entry_width), entry_height, entry_depth)
	_append_box(collision, entry_center, tangent, outward, float(inference.entry_width), entry_height, entry_depth)

	var opening_center := Vector3(front_center.x, entry_base + float(inference.entry_opening_height) * 0.5, front_center.z) + outward * (entry_depth + 0.06)
	_append_box(opening, opening_center, tangent, outward, float(inference.entry_opening_width), float(inference.entry_opening_height), 0.1)
	_append_frame(trim, opening_center + outward * 0.07, tangent, outward, float(inference.entry_opening_width), float(inference.entry_opening_height), 0.18, 0.12)

	var window_bottom := float(inference.tall_window_bottom_y)
	var window_top := float(inference.tall_window_top_y)
	var window_height := window_top - window_bottom
	var window_width := float(inference.tall_window_width)
	var glass_center := Vector3(front_center.x, (window_bottom + window_top) * 0.5, front_center.z) + outward * float(inference.front_reveal_depth)
	_append_box(opening, glass_center, tangent, outward, window_width, window_height, 0.12)
	var frame_center := glass_center + outward * (float(inference.front_frame_projection) - float(inference.front_reveal_depth))
	_append_frame(trim, frame_center, tangent, outward, window_width, window_height, 0.2, 0.14)
	var vertical_dividers := int(inference.tall_window_vertical_dividers)
	for divider_index in range(vertical_dividers):
		var fraction := float(divider_index + 1) / float(vertical_dividers + 1) - 0.5
		_append_box(trim, frame_center + tangent * window_width * fraction, tangent, outward, 0.11, window_height, 0.14)
	var horizontal_dividers := int(inference.tall_window_horizontal_dividers)
	for divider_index in range(horizontal_dividers):
		var fraction := float(divider_index + 1) / float(horizontal_dividers + 1) - 0.5
		var bar_center := frame_center
		bar_center.y += window_height * fraction
		_append_box(trim, bar_center, tangent, outward, window_width, 0.11, 0.14)


func _append_partial_side_openings(trim: Dictionary, opening: Dictionary, wall_record: Dictionary, inference: Dictionary) -> void:
	var width := float(inference.side_window_width)
	var bottom_y := float(inference.side_window_bottom_y)
	var top_y := float(inference.side_window_top_y)
	var height := top_y - bottom_y
	for chain_m_value: Variant in inference.side_window_chain_centers_m as Array:
		var placement := _chain_frame(wall_record, OBSERVED_PARTIAL_SIDE_RUNS, float(chain_m_value))
		if placement.is_empty():
			continue
		var tangent := placement.tangent as Vector3
		var normal := placement.normal as Vector3
		var anchor := placement.wall_anchor as Vector3
		var center := Vector3(anchor.x, (bottom_y + top_y) * 0.5, anchor.z) + normal * 0.12
		_append_box(opening, center, tangent, normal, width, height, 0.1)
		var frame_center := center + normal * (float(inference.side_frame_projection) - 0.12)
		_append_frame(trim, frame_center, tangent, normal, width, height, 0.16, 0.12)
		_append_box(trim, frame_center, tangent, normal, 0.1, height, 0.12)


func _append_frame(bucket: Dictionary, center: Vector3, tangent: Vector3, normal: Vector3, width: float, height: float, member: float, depth: float) -> void:
	_append_box(bucket, center - tangent * (width + member) * 0.5, tangent, normal, member, height + member * 2.0, depth)
	_append_box(bucket, center + tangent * (width + member) * 0.5, tangent, normal, member, height + member * 2.0, depth)
	var top := center
	top.y += (height + member) * 0.5
	var bottom := center
	bottom.y -= (height + member) * 0.5
	_append_box(bucket, top, tangent, normal, width, member, depth)
	_append_box(bucket, bottom, tangent, normal, width, member, depth)


func _append_record_wall_run(bucket: Dictionary, record: Dictionary, run_index: int) -> void:
	var values := record.vertices as Array
	var normals := record.normals as Array
	var source_indices := record.indices as Array
	var value_offset := run_index * 12
	var vertex_offset := run_index * 4
	var index_offset := run_index * 6
	var base := (bucket.vertices as Array).size()
	for local_index in range(4):
		var offset := value_offset + local_index * 3
		(bucket.vertices as Array).append(Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2])))
		(bucket.normals as Array).append(Vector3(float(normals[offset]), float(normals[offset + 1]), float(normals[offset + 2])))
		(bucket.uvs as Array).append(Vector2(float(values[offset]) + float(values[offset + 2]), float(values[offset + 1])))
	# Generated source triangles use the canonical serialized order. Mirror the
	# live WorldChunkBuilder's first/third/second winding so exterior rendering
	# and one-sided world-solid collision agree with the exact current receiver.
	for triangle_offset in range(0, 6, 3):
		var first := base + int(source_indices[index_offset + triangle_offset]) - vertex_offset
		var second := base + int(source_indices[index_offset + triangle_offset + 1]) - vertex_offset
		var third := base + int(source_indices[index_offset + triangle_offset + 2]) - vertex_offset
		(bucket.indices as Array).append_array([first, third, second])


func _append_record_mesh(bucket: Dictionary, record: Dictionary) -> void:
	var values := record.vertices as Array
	var normals := record.normals as Array
	var source_indices := record.indices as Array
	var base := (bucket.vertices as Array).size()
	for offset in range(0, values.size(), 3):
		var point := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
		(bucket.vertices as Array).append(point)
		(bucket.normals as Array).append(Vector3(float(normals[offset]), float(normals[offset + 1]), float(normals[offset + 2])))
		(bucket.uvs as Array).append(Vector2(point.x + point.z, point.y))
	for source_offset in range(0, source_indices.size(), 3):
		var first := base + int(source_indices[source_offset])
		var second := base + int(source_indices[source_offset + 1])
		var third := base + int(source_indices[source_offset + 2])
		(bucket.indices as Array).append_array([first, third, second])


func _append_box(bucket: Dictionary, center: Vector3, tangent_value: Vector3, normal_value: Vector3, width: float, height: float, depth: float) -> void:
	# Callers supply a board axis and outward face normal. Orthogonalize
	# explicitly so pitched rake boards retain their requested cross-section.
	assert(tangent_value.length_squared() > 0.000001)
	var tangent := tangent_value.normalized()
	var perpendicular := normal_value - tangent * normal_value.dot(tangent)
	assert(perpendicular.length_squared() > 0.000001)
	var normal := perpendicular.normalized()
	var up := normal.cross(tangent).normalized()
	var tx := tangent * width * 0.5
	var nz := normal * depth * 0.5
	var uy := up * height * 0.5
	var fbl := center - tx - uy + nz
	var fbr := center + tx - uy + nz
	var ftr := center + tx + uy + nz
	var ftl := center - tx + uy + nz
	var bbl := center - tx - uy - nz
	var bbr := center + tx - uy - nz
	var btr := center + tx + uy - nz
	var btl := center - tx + uy - nz
	_append_quad(bucket, fbl, fbr, ftr, ftl, normal)
	_append_quad(bucket, bbr, bbl, btl, btr, -normal)
	_append_quad(bucket, ftl, ftr, btr, btl, up)
	_append_quad(bucket, bbl, bbr, fbr, fbl, -up)
	_append_quad(bucket, bbl, fbl, ftl, btl, -tangent)
	_append_quad(bucket, fbr, bbr, btr, ftr, tangent)


func _append_quad(bucket: Dictionary, a: Vector3, b: Vector3, c: Vector3, d: Vector3, normal_value: Vector3) -> void:
	var normal := normal_value.normalized()
	var vertices := bucket.vertices as Array
	var normals := bucket.normals as Array
	var uvs := bucket.uvs as Array
	var indices := bucket.indices as Array
	var base := vertices.size()
	for point: Vector3 in [a, b, c, d]:
		vertices.append(point)
		normals.append(normal)
		uvs.append(Vector2(point.x + point.z, point.y))
	if (b - a).cross(c - a).dot(normal) > 0.0:
		indices.append_array([base, base + 2, base + 1, base, base + 3, base + 2])
	else:
		indices.append_array([base, base + 1, base + 2, base, base + 2, base + 3])


func _append_triangle(bucket: Dictionary, a: Vector3, b: Vector3, c: Vector3, normal_value: Vector3) -> void:
	var normal := normal_value.normalized()
	var vertices := bucket.vertices as Array
	var normals := bucket.normals as Array
	var uvs := bucket.uvs as Array
	var indices := bucket.indices as Array
	var base := vertices.size()
	for point: Vector3 in [a, b, c]:
		vertices.append(point)
		normals.append(normal)
		uvs.append(Vector2(point.x + point.z, point.y))
	if (b - a).cross(c - a).dot(normal) > 0.0:
		indices.append_array([base, base + 2, base + 1])
	else:
		indices.append_array([base, base + 1, base + 2])


func _mesh_instance(node_name: String, bucket: Dictionary, material: Material, layers: int) -> MeshInstance3D:
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array(bucket.vertices as Array)
	arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array(bucket.normals as Array)
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array(bucket.uvs as Array)
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array(bucket.indices as Array)
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_name(0, node_name.to_snake_case())
	mesh.surface_set_material(0, material)
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.layers = layers
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return instance


func _collision_body(bucket: Dictionary) -> StaticBody3D:
	if (bucket.indices as Array).is_empty():
		return null
	var source_vertices := bucket.vertices as Array
	var faces := PackedVector3Array()
	for index_value: Variant in bucket.indices as Array:
		faces.append(source_vertices[int(index_value)] as Vector3)
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	shape.set_meta("receiver_kind", "none")
	shape.set_meta("opaque", true)
	shape.set_meta("derived_object_key", "prototype:%s" % WALL_KEY)
	shape.set_meta("source_keys", [SOURCE_KEY])
	shape.set_meta("structural_visible_collision_congruent", true)
	var shape_node := CollisionShape3D.new()
	shape_node.name = "StructuralShape"
	shape_node.shape = shape
	var body := StaticBody3D.new()
	body.name = "StructuralCollision_NoSprayOwnership"
	body.collision_layer = PHYSICS_WORLD_SOLID
	body.collision_mask = 0
	body.set_meta("receiver_kind", "none")
	body.set_meta("opaque", true)
	body.set_meta("derived_object_key", "prototype:%s" % WALL_KEY)
	body.set_meta("source_keys", [SOURCE_KEY])
	body.set_meta("spray_ownership", "none_standalone")
	body.set_meta("structural_visible_collision_congruent", true)
	body.add_child(shape_node)
	return body


static func _record_contract_matches(record: Dictionary, object_key: String, feature_kind: String, vertex_value_count: int, index_count: int) -> bool:
	return not record.is_empty() \
		and str(record.get("object_key", "")) == object_key \
		and record.get("source_keys", []) == [SOURCE_KEY] \
		and str(record.get("feature_kind", "")) == feature_kind \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false)) \
		and (record.get("vertices", []) as Array).size() == vertex_value_count \
		and (record.get("normals", []) as Array).size() == vertex_value_count \
		and (record.get("indices", []) as Array).size() == index_count \
		and is_equal_approx(float(record.get("top_elevation_m", 0.0)), 14.04)


static func _config_contract_matches(config: Dictionary) -> bool:
	if config.is_empty() or str(config.get("schema_version", "")) != "ti.navy-chapel-187-standalone-hero-prototype/1":
		return false
	var target := config.get("target", {}) as Dictionary
	var inference := config.get("production_inference_m", {}) as Dictionary
	if str(target.get("source_key", "")) != SOURCE_KEY \
		or str(target.get("wall_object_key", "")) != WALL_KEY \
		or str(target.get("roof_object_key", "")) != ROOF_KEY \
		or int(target.get("wall_run_count", 0)) != WALL_RUN_COUNT \
		or int(target.get("wall_vertices", 0)) != 136 \
		or int(target.get("wall_triangles", 0)) != 68 \
		or int(target.get("roof_plan_vertices", 0)) != 20 \
		or int(target.get("roof_triangles", 0)) != 18:
		return false
	var mapped := config.get("mapped_runs", []) as Array
	var protected := config.get("protected_regions", []) as Array
	if mapped.size() != 2 \
		or _int_array((mapped[0] as Dictionary).get("ordered_run_indices", []) as Array) != OBSERVED_SSE_RUNS \
		or _int_array((mapped[1] as Dictionary).get("ordered_run_indices", []) as Array) != OBSERVED_PARTIAL_SIDE_RUNS \
		or protected.is_empty() \
		or _int_array((protected[0] as Dictionary).get("run_indices", []) as Array) != PROTECTED_RUNS:
		return false
	if float(inference.get("main_gable_width", 0.0)) > 16.5 \
		or float(inference.get("main_gable_length", 0.0)) > 43.0 \
		or float(inference.get("main_gable_eave_y", 0.0)) <= 4.04 \
		or float(inference.get("main_gable_ridge_y", 0.0)) <= float(inference.get("main_gable_eave_y", 0.0)) \
		or float(inference.get("belfry_cap_apex_y", 0.0)) <= float(inference.get("belfry_wall_top_y", 0.0)) \
		or float(inference.get("cross_vertical_center_y", 0.0)) <= float(inference.get("belfry_cap_apex_y", 0.0)) \
		or (inference.get("side_window_chain_centers_m", []) as Array).size() != 3:
		return false
	return true


static func _chain_basis(record: Dictionary, runs: Array) -> Dictionary:
	if runs.is_empty():
		return {}
	var first := _run_frame(record, int(runs[0]))
	var last := _run_frame(record, int(runs[runs.size() - 1]))
	if first.is_empty() or last.is_empty():
		return {}
	return {
		"start": first.start,
		"end": last.end,
		"tangent": first.tangent,
		"normal": first.normal,
	}


static func _chain_frame(record: Dictionary, runs: Array, chain_m: float) -> Dictionary:
	var accumulated := 0.0
	for run_value: Variant in runs:
		var run_index := int(run_value)
		var frame := _run_frame(record, run_index)
		if frame.is_empty():
			return {}
		var length := float(frame.length_m)
		if chain_m <= accumulated + length + 0.0001:
			var fraction := clampf((chain_m - accumulated) / length, 0.0, 1.0)
			return {
				"wall_anchor": (frame.start as Vector3).lerp(frame.end as Vector3, fraction),
				"tangent": frame.tangent,
				"normal": frame.normal,
				"run_index": run_index,
			}
		accumulated += length
	return {}


static func _run_frame(record: Dictionary, run_index: int) -> Dictionary:
	var values := record.get("vertices", []) as Array
	var normals := record.get("normals", []) as Array
	var offset := run_index * 12
	if run_index < 0 or offset + 11 >= values.size():
		return {}
	var start := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
	var end := Vector3(float(values[offset + 3]), float(values[offset + 4]), float(values[offset + 5]))
	var tangent := end - start
	tangent.y = 0.0
	if tangent.length_squared() <= 0.000001:
		return {}
	return {
		"start": start,
		"end": end,
		"length_m": tangent.length(),
		"tangent": tangent.normalized(),
		"normal": Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized(),
	}


static func _record_for_key(records: Array, key: String) -> Dictionary:
	for value: Variant in records:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == key:
			return record
	return {}


static func _json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


static func _bucket() -> Dictionary:
	return {"vertices": [], "normals": [], "uvs": [], "indices": []}


static func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


static func _upward_normal(a: Vector3, b: Vector3, c: Vector3) -> Vector3:
	var normal := (b - a).cross(c - a).normalized()
	return -normal if normal.y < 0.0 else normal


static func _outward_up_normal(a: Vector3, b: Vector3, c: Vector3, center: Vector3) -> Vector3:
	var normal := (b - a).cross(c - a).normalized()
	var face_center := (a + b + c) / 3.0
	var outward := face_center - center
	outward.y = maxf(outward.y, 0.25)
	return -normal if normal.dot(outward) < 0.0 else normal


func _clear_children_now() -> void:
	for child in get_children():
		remove_child(child)
		child.free()


static func _failure(code: String, message: String) -> Dictionary:
	return {"ok": false, "code": code, "message": message}
