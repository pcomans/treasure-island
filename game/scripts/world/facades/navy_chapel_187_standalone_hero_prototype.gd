class_name NavyChapel187StandaloneHeroPrototype
extends Node3D

const CONFIG_PATH := "res://game/resources/facades/navy_chapel_187_standalone_hero_prototype.json"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const SOURCE_KEY := "w291189336"
const WALL_KEY := "building:w291189336:wall"
const ROOF_KEY := "building:w291189336:roof"
const WALL_RUN_COUNT := 34
const OBSERVED_SSE_RUNS := [9, 10]
# Jul2023 ENE: the complete colinear tall-hall side from the SSE corner to the
# low-junction return 15 (root rescope 2026-10-10).
const OBSERVED_ENE_HALL_RUNS := [11, 12, 13, 14]
const OBSERVED_WSW_RUNS := [6, 7, 8]
# Sep2025 SSE-facing cross-wing front (root rescope 2026-10-10); runs 19-21
# are distinct faces and stay module-free.
const OBSERVED_WING_SSE_RUNS := [17, 18]
# Jul2016 WSW low wing (root rescope 2026-10-10): outer gable, SSE-facing low
# side and WSW-facing junction projection. Door allocation across the run2 /
# runs3-4 corner is production association, not a surveyed anchor.
const OBSERVED_WSW_WING_GABLE_RUNS := [0, 1]
const OBSERVED_WSW_WING_SIDE_RUNS := [2]
const OBSERVED_WSW_JUNCTION_RUNS := [3, 4]
# Jul2023 ENE low-junction projection, partly obstructed: one disclosed
# production-inference door assembly; no observed door count is claimed.
const QUALIFIED_ENE_JUNCTION_RUNS := [16]
# Every recessed opening-group chain, indexed by group "chain". Each chain is
# one colinear run sequence sharing a single outward normal.
const RECESSED_CHAINS := [
	OBSERVED_WSW_RUNS,
	OBSERVED_ENE_HALL_RUNS,
	OBSERVED_WING_SSE_RUNS,
	OBSERVED_WSW_WING_GABLE_RUNS,
	OBSERVED_WSW_WING_SIDE_RUNS,
	OBSERVED_WSW_JUNCTION_RUNS,
	QUALIFIED_ENE_JUNCTION_RUNS,
]
# Chains >= this index take their groups from config "wing_and_junction_assemblies".
const ASSEMBLY_CHAIN_FIRST := 3
const PROTECTED_RUNS := [5, 15, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33]
# Clearance between a group's dressed edge and a chain end or a neighbouring
# group (surround, sill and head overhang are within it).
const GROUP_END_MARGIN_M := 0.3
const GROUP_GAP_M := 0.5
# Lower source-footprint closure plane beneath the pitched roofs.
const LOWER_CAP_Y := 8.0
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
const METAL_CAP := preload("res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_metal_cap.tres")

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
	var groups := _opening_groups(wall, inf, config.get("wing_and_junction_assemblies", []) as Array)
	var fit_error := _groups_fit_chains(wall, groups, c, t, width, eave)
	if not fit_error.is_empty():
		return _failure("navy_chapel_opening_group_bounds", fit_error)
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
			var bucket := protected if run in PROTECTED_RUNS else shell
			var chain := _chain_index(run)
			if chain >= 0:
				_append_group_recesses(shell, glass, wall, chain, run, left, right, top, groups, float(inf.opening_group_recess_depth))
			else:
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
	_append_pocketed_lower_cap(roofing, lower, wall, groups, float(inf.opening_group_recess_depth))
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
	# Opening units only on observed runs/faces; no schedule on unseen faces.
	var metal_cap := _bucket()
	_append_belfry(shell, metal_cap, cross, unused, c, t, n, inf)
	_append_belfry_side_units(glass, trim, c, t, n, inf)
	var stair_decor := _bucket()
	var stair_support := _bucket()
	_append_wsw_landing(trim, stair_decor, stair_support, wall)
	_append_box(trim, c + n * 0.85 + Vector3.UP * 7.25, t, n, 6.0, 0.16, 1.7)
	for i in range(2):
		var x: float = [-2.35, 2.35][i]
		# Actual generated land corner minima; visible area is 40mm above land.
		var base_y: float = [4.02523, 3.991914][i]
		_append_box(trim, c + t * x + n * 1.35 + Vector3.UP * ((base_y + 7.24) * 0.5), t, n, 0.12, 7.24 - base_y, 0.12)
	# Paired timber leaves with a dark meeting joint and shallow raised panels
	# (Dec2016 front hierarchy; leaf/panel sizes are production inference).
	for side: float in [-1.0, 1.0]:
		var leaf := c + t * side * 0.41
		_append_box(wood, leaf + n * 0.045 + Vector3.UP * 5.395, t, n, 0.78, 2.80, 0.08)
		for panel_y: float in [4.85, 6.25]:
			_append_box(wood, leaf + n * 0.095 + Vector3.UP * panel_y, t, n, 0.52, 0.95, 0.03)
	_append_box(glass, c + n * 0.03 + Vector3.UP * 5.395, t, n, 0.06, 2.80, 0.05)
	_append_frame(trim, c + n * 0.11 + Vector3.UP * 5.42, t, n, 1.6, 2.75, 0.12, 0.15)
	for x: float in [-1.30, 1.30]:
		_study_window(glass, trim, c + t * x, 4.35, 6.96, 0.62, t, n, 4)
	_append_box(trim, c + n * 0.07 + Vector3.UP * 7.08, t, n, 3.5, 0.12, 0.14)
	for x: float in [-5.7, 5.7]:
		_study_window(glass, trim, c + t * x, 5.0, 6.25, 0.62, t, n, 1)
	_append_gable_glazing(glass, trim, wood, c, t, n, eave, ridge, width)
	# One shared recessed opening-group family on every observed long-side,
	# wing and junction chain: windows get a dark glass field, pale mullions,
	# host-face surround and sill; closed doors get painted leaves instead.
	for group: Dictionary in groups:
		_append_group_dressing(trim, glass, wall, group, float(inf.opening_group_recess_depth))
	# Thin eave/rake boards, not new hidden facade ornament.
	for sign_value: float in [-1.0, 1.0]:
		var start := c + t * width * 0.5 * sign_value + Vector3.UP * eave
		_append_box(trim, start - n * length * 0.5, t, n, 0.16, 0.18, length + 0.16)
		var end := c + Vector3.UP * ridge
		var axis := (end - start).normalized()
		_append_box(trim, (start + end) * 0.5 + n * 0.06, axis, n, start.distance_to(end) + 0.12, 0.16, 0.18)
		# Matching rake board on the inferred NNW rear gable.
		var rear_offset := -n * length
		_append_box(trim, (start + end) * 0.5 + rear_offset - n * 0.06, axis, n, start.distance_to(end) + 0.12, 0.16, 0.18)
	_append_corner_boards(trim, wall, c, t, width, eave, float(inf.plinth_top_y))
	# Continuous restrained eave and outer-gable rake boards on both low wings.
	for wing: Array in [[1.0, 29.86, 7.93, 8.68], [-1.0, 29.705, 7.93, 9.0]]:
		var direction: float = wing[0]
		var half: float = float(wing[2]) * 0.5
		var wing_length: float = wing[3]
		var axis_center := c - n * float(wing[1]) + t * direction * (width * 0.5 + wing_length * 0.5)
		for sign_value: float in [-1.0, 1.0]:
			_append_box(trim, axis_center + n * half * sign_value + Vector3.UP * 8.0, t, n, wing_length + 0.16, 0.18, 0.16)
			var gable_end := c - n * float(wing[1]) + t * direction * (width * 0.5 + wing_length)
			var low := gable_end + n * half * sign_value + Vector3.UP * 8.0
			var apex := gable_end + Vector3.UP * 10.25
			var rake_axis := (apex - low).normalized()
			_append_box(trim, (low + apex) * 0.5 + t * direction * 0.06, rake_axis, t * direction, low.distance_to(apex) + 0.12, 0.16, 0.18)
	var specs: Array = [
		["QuietWallAndRearClosure", protected, INFERRED_CREAM_STRUCTURE, RENDER_BUILDING_WALL, false],
		["InferredCreamSSEGableBelfryEntry", shell, INFERRED_CREAM_STRUCTURE, RENDER_BUILDING_WALL, false],
		["NeutralRoofAndCap", roofing, NEUTRAL_ROOF, RENDER_WORLD_VISIBLE, true],
		["RibbedMetalCap", metal_cap, METAL_CAP, RENDER_WORLD_VISIBLE, true],
		["WSWFlightDecor", stair_decor, PALE_TRIM, RENDER_WORLD_VISIBLE, true, "decor"],
		["WSWFlightSupport", stair_support, PALE_TRIM, RENDER_WORLD_VISIBLE, true, "support"],
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
		var mesh := _mesh_instance(spec[0], bucket, spec[2], spec[3])
		if spec.size() > 5:
			mesh.set_meta("chapel_flight_role", spec[5])
			mesh.visible = spec[5] != "support"
		add_child(mesh)
		var points: Array = bucket.vertices
		var normals: Array = bucket.normals
		var indices: Array = bucket.indices
		visual_triangles += indices.size() / 3
		if spec.size() > 5 and spec[5] == "decor":
			continue
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
	set_meta("observed_wsw_run_indices", OBSERVED_WSW_RUNS)
	set_meta("vertical_and_roof_geometry_truth_class", "reversible_production_inference")
	set_meta("observed_sse_run_indices", OBSERVED_SSE_RUNS)
	set_meta("observed_ene_hall_run_indices", OBSERVED_ENE_HALL_RUNS)
	set_meta("protected_run_indices", PROTECTED_RUNS)
	set_meta("observed_wing_sse_run_indices", OBSERVED_WING_SSE_RUNS)
	set_meta("observed_wsw_wing_run_indices", OBSERVED_WSW_WING_GABLE_RUNS + OBSERVED_WSW_WING_SIDE_RUNS + OBSERVED_WSW_JUNCTION_RUNS)
	set_meta("qualified_ene_junction_run_indices", QUALIFIED_ENE_JUNCTION_RUNS)
	set_meta("observed_belfry_side_faces", ["+t_ENE", "-t_WSW"])
	set_meta("belfry_side_units_are_relief_not_cavity", true)
	_configured = true
	_last_result = {"ok": true, "node": self, "visual_triangles": visual_triangles, "metadata": {"source_key": SOURCE_KEY, "interior_modeled": false}}
	return _last_result.duplicate(true)


# Opening groups per recessed chain. Jan2023 WSW, Jul2023 complete ENE hall,
# Sep2025 SSE-facing wing front and Jul2016 WSW wing/junction support finite
# framed multi-light groups and closed doors; counts, cadence, widths, heights
# and door host allocation are reversible production inference.
func _opening_groups(wall: Dictionary, inf: Dictionary, assemblies: Array) -> Array[Dictionary]:
	var groups: Array[Dictionary] = []
	var hall_half := float(inf.opening_group_hall_width) * 0.5
	var hall_bottom := float(inf.opening_group_hall_bottom_y)
	var hall_top := float(inf.opening_group_hall_top_y)
	var wsw_count := int(inf.opening_group_wsw_count)
	var wsw_length := _chain_length(wall, OBSERVED_WSW_RUNS)
	for index in wsw_count:
		var center := wsw_length * (float(index) + 0.5) / float(wsw_count)
		groups.append({"chain": 0, "kind": "window", "a": center - hall_half, "b": center + hall_half, "bottom": hall_bottom, "top": hall_top, "lights": 3})
	# ENE-only width variant; the WSW groups above keep the shared hall width.
	var ene_half := float(inf.opening_group_ene_hall_width) * 0.5
	for center_value: Variant in inf.side_window_chain_centers_m as Array:
		var center := float(center_value)
		groups.append({"chain": 1, "kind": "window", "a": center - ene_half, "b": center + ene_half, "bottom": hall_bottom, "top": hall_top, "lights": 3})
	var wing_center := float(inf.opening_group_wing_chain_center_m)
	var wing_half := float(inf.opening_group_wing_width) * 0.5
	groups.append({"chain": 2, "kind": "window", "a": wing_center - wing_half, "b": wing_center + wing_half,
		"bottom": float(inf.opening_group_wing_bottom_y), "top": float(inf.opening_group_wing_top_y), "lights": int(inf.opening_group_wing_lights)})
	for value: Variant in assemblies:
		var assembly := value as Dictionary
		var half := float(assembly.width_m) * 0.5
		var center := float(assembly.center_m)
		var group := {"chain": _chain_for_runs(_int_array(assembly.runs as Array)), "kind": str(assembly.kind),
			"a": center - half, "b": center + half, "top": float(assembly.top_y)}
		if group.kind == "door":
			# Closed door back and jambs run down to the source wall bottom;
			# land_y stays the terrain check; optional support_y raises only
			# the named WSW leaves/jambs onto their common platform.
			group["bottom"] = float(assembly.land_y)
			group["support_y"] = float(assembly.get("support_y", assembly.land_y))
			group["leaves"] = int(assembly.leaves)
		else:
			group["bottom"] = float(assembly.bottom_y)
			group["lights"] = int(assembly.lights)
		groups.append(group)
	return groups


static func _chain_for_runs(runs: Array[int]) -> int:
	for index in RECESSED_CHAINS.size():
		if _int_array(RECESSED_CHAINS[index] as Array) == runs:
			return index
	return -1


# Actual source-bound check before any emission: every group lies inside its
# own chain with dressing margins, groups do not overlap, tops stay under the
# chain's wall top, window sills stay above source bottoms and every closed
# door back/jamb (cut to the source wall bottom) reaches its declared land.
func _groups_fit_chains(wall: Dictionary, groups: Array[Dictionary], c: Vector3, t: Vector3, width: float, eave: float) -> String:
	for chain in RECESSED_CHAINS.size():
		var runs: Array = RECESSED_CHAINS[chain]
		var length := _chain_length(wall, runs)
		var mid: Dictionary = _chain_frame(wall, runs, length * 0.5)
		if mid.is_empty():
			return "chain %d has no source frame" % chain
		var wall_top := LOWER_CAP_Y if absf(((mid.wall_anchor as Vector3) - c).dot(t)) > width * 0.5 + 0.10 else eave
		var stations: Array[float] = [0.0]
		var bottom_max := -INF
		for run: int in runs:
			var f := _run_frame(wall, run)
			bottom_max = maxf(bottom_max, maxf((f.start as Vector3).y, (f.end as Vector3).y))
			stations.append(stations[stations.size() - 1] + float(f.length_m))
		var spans: Array = []
		for group: Dictionary in groups:
			if int(group.chain) != chain:
				continue
			var a := float(group.a)
			var b := float(group.b)
			if a < GROUP_END_MARGIN_M or b > length - GROUP_END_MARGIN_M or b <= a:
				return "chain %d group [%.3f, %.3f] outside [%.2f, %.3f]" % [chain, a, b, GROUP_END_MARGIN_M, length - GROUP_END_MARGIN_M]
			if float(group.top) + 0.3 > wall_top:
				return "chain %d group top %.3f too close to wall top %.3f" % [chain, float(group.top), wall_top]
			if str(group.kind) == "door":
				var land := float(group.bottom)
				var lowest := INF
				var samples: Array[float] = [a, b]
				for station: float in stations:
					if station > a and station < b:
						samples.append(station)
				for s: float in samples:
					var y := ((_chain_frame(wall, runs, s).wall_anchor) as Vector3).y
					lowest = minf(lowest, y)
					# Leaves stop 0.01 below land and must stay above the floor.
					if y > land - 0.01:
						return "chain %d door source bottom %.3f not below declared land %.3f" % [chain, y, land]
				if land - lowest > 0.15:
					return "chain %d door land %.3f inconsistent with source bottom %.3f" % [chain, land, lowest]
			elif float(group.bottom) < bottom_max + 0.5:
				return "chain %d window bottom %.3f too close to source bottom %.3f" % [chain, float(group.bottom), bottom_max]
			spans.append([a, b])
		spans.sort_custom(func(first: Array, second: Array) -> bool: return float(first[0]) < float(second[0]))
		for i in range(1, spans.size()):
			if float(spans[i][0]) - float(spans[i - 1][1]) < GROUP_GAP_M:
				return "chain %d groups overlap or crowd at %.3f" % [chain, float(spans[i][0])]
		if chain >= ASSEMBLY_CHAIN_FIRST and spans.is_empty():
			return "chain %d has no opening assembly" % chain
	return ""


static func _chain_index(run: int) -> int:
	for index in RECESSED_CHAINS.size():
		if run in (RECESSED_CHAINS[index] as Array):
			return index
	return -1


static func _chain_length(wall: Dictionary, runs: Array) -> float:
	var length := 0.0
	for run: int in runs:
		length += float(_run_frame(wall, run).length_m)
	return length


# Subtract each actual run-local pocket that crosses the retained horizontal
# cap. Convex half-plane partition keeps every outside piece; no polygon union
# or holes are needed. Cut boundaries meet the existing jambs and glass backs.
func _append_pocketed_lower_cap(bucket: Dictionary, record: Dictionary, wall: Dictionary, groups: Array[Dictionary], depth: float) -> void:
	var pieces: Array[PackedVector3Array] = []
	var values: Array = record.vertices
	var indices: Array = record.indices
	for i in range(0, indices.size(), 3):
		var triangle := PackedVector3Array()
		for j in 3:
			var k := int(indices[i + j]) * 3
			triangle.append(Vector3(values[k], values[k + 1], values[k + 2]))
		pieces.append(triangle)
	for group: Dictionary in groups:
		if not (float(group.bottom) < LOWER_CAP_Y and float(group.top) > LOWER_CAP_Y):
			continue
		var station := 0.0
		for run: int in RECESSED_CHAINS[int(group.chain)]:
			var f := _run_frame(wall, run)
			var origin: Vector3 = f.start
			var outward: Vector3 = f.normal
			var length: float = f.length_m
			var lo := maxf(0.0, float(group.a) - station)
			var hi := minf(length, float(group.b) - station)
			station += length
			if hi <= lo:
				continue
			# Match the emitted endpoints plus inward vector, not an assumed
			# orthogonal tangent/serialized-normal coordinate system.
			var front_a := origin.lerp(f.end as Vector3, lo / length)
			var front_b := origin.lerp(f.end as Vector3, hi / length)
			front_a.y = LOWER_CAP_Y
			front_b.y = LOWER_CAP_Y
			var inward := -outward * depth
			var pocket: Array[Vector3] = [front_a, front_b, front_b + inward, front_a + inward]
			var center := (front_a + front_b + inward) * 0.5
			var axes: Array[Vector3] = []
			var limits: Array[float] = []
			for edge in 4:
				var a := pocket[edge]
				var b := pocket[(edge + 1) % 4]
				var axis := (b - a).cross(Vector3.UP).normalized()
				if (center - a).dot(axis) > 0.0:
					axis = -axis
				axes.append(axis)
				limits.append((a - origin).dot(axis))
			var retained: Array[PackedVector3Array] = []
			for piece: PackedVector3Array in pieces:
				var remainder := piece
				for plane in 4:
					if remainder.size() < 3:
						break
					var outside := _cap_half_plane(remainder, origin, -axes[plane], -limits[plane])
					if outside.size() >= 3:
						retained.append(outside)
					remainder = _cap_half_plane(remainder, origin, axes[plane], limits[plane])
			pieces = retained
	for piece: PackedVector3Array in pieces:
		for i in range(1, piece.size() - 1):
			if (piece[i] - piece[0]).cross(piece[i + 1] - piece[0]).length_squared() > 0.000000000001:
				_append_triangle(bucket, piece[0], piece[i], piece[i + 1], Vector3.UP)


func _cap_half_plane(polygon: PackedVector3Array, origin: Vector3, axis: Vector3, limit: float) -> PackedVector3Array:
	var result := PackedVector3Array()
	for i in polygon.size():
		var a := polygon[i]
		var b := polygon[(i + 1) % polygon.size()]
		var da := (a - origin).dot(axis) - limit
		var db := (b - origin).dot(axis) - limit
		if da <= 0.0:
			result.append(a)
		if (da < 0.0 and db > 0.0) or (da > 0.0 and db < 0.0):
			result.append(a.lerp(b, da / (da - db)))
	return result


func _append_group_recesses(shell: Dictionary, glass: Dictionary, wall: Dictionary, chain: int, run: int, left: Vector3, right: Vector3, top: float, groups: Array[Dictionary], depth: float) -> void:
	var runs: Array = RECESSED_CHAINS[chain]
	var frame := _run_frame(wall, run)
	var tangent: Vector3 = frame.tangent
	var normal: Vector3 = frame.normal
	var station := 0.0
	for prior: int in runs:
		if prior == run:
			break
		station += float(_run_frame(wall, prior).length_m)
	var sa := station + (left - (frame.start as Vector3)).dot(tangent)
	var sb := station + (right - (frame.start as Vector3)).dot(tangent)
	var chain_groups: Array[Dictionary] = []
	for group: Dictionary in groups:
		if int(group.chain) == chain:
			chain_groups.append(group)
	var cuts: Array[float] = [sa, sb]
	for group: Dictionary in chain_groups:
		for edge: float in [float(group.a), float(group.b)]:
			if edge > sa and edge < sb:
				cuts.append(edge)
	cuts.sort()
	var inward := -normal * depth
	for i in range(cuts.size() - 1):
		var a := left.lerp(right, (cuts[i] - sa) / (sb - sa))
		var b := left.lerp(right, (cuts[i + 1] - sa) / (sb - sa))
		var middle := (cuts[i] + cuts[i + 1]) * 0.5
		var aperture: Dictionary = {}
		for group: Dictionary in chain_groups:
			if middle > float(group.a) and middle < float(group.b):
				aperture = group
		if aperture.is_empty():
			_append_quad(shell, a, b, Vector3(b.x, top, b.z), Vector3(a.x, top, a.z), normal)
			continue
		# Closed doors cut to the actual source wall bottom (no raised sill);
		# their pocket floor below local land closes the source bottom.
		var door := str(aperture.kind) == "door"
		var low_a := a if door else Vector3(a.x, float(aperture.bottom), a.z)
		var low_b := b if door else Vector3(b.x, float(aperture.bottom), b.z)
		var high_a := Vector3(a.x, float(aperture.top), a.z)
		var high_b := Vector3(b.x, float(aperture.top), b.z)
		if not door:
			_append_quad(shell, a, b, low_b, low_a, normal)
		_append_quad(shell, high_a, high_b, Vector3(b.x, top, b.z), Vector3(a.x, top, a.z), normal)
		_append_quad(glass, low_a + inward, low_b + inward, high_b + inward, high_a + inward, normal)
		_append_quad(shell, low_a, low_b, low_b + inward, low_a + inward, Vector3.UP)
		_append_quad(shell, high_a, high_a + inward, high_b + inward, high_b, Vector3.DOWN)
	for group: Dictionary in chain_groups:
		for end in 2:
			var edge := float(group.a) if end == 0 else float(group.b)
			if edge < sa or edge > sb:
				continue
			var p := left.lerp(right, (edge - sa) / (sb - sa))
			var low := p if str(group.kind) == "door" else Vector3(p.x, float(group.bottom), p.z)
			var high := Vector3(p.x, float(group.top), p.z)
			_append_quad(shell, low, low + inward, high + inward, high, tangent if end == 0 else -tangent)


# Shared group dressing: pale mullions/transom inside the closed recess, a
# continuous surround on the exposed host face (outside the aperture, never
# buried in it), a projecting sill and a drip head. Chains are colinear.
func _append_group_dressing(trim: Dictionary, glass: Dictionary, wall: Dictionary, group: Dictionary, depth: float) -> void:
	var runs: Array = RECESSED_CHAINS[int(group.chain)]
	var a := float(group.a)
	var b := float(group.b)
	var bottom := float(group.bottom)
	var top := float(group.top)
	var width := b - a
	var height := top - bottom
	var f := _chain_frame(wall, runs, (a + b) * 0.5)
	var t: Vector3 = f.tangent
	var n: Vector3 = f.normal
	var face: Vector3 = f.wall_anchor
	if str(group.kind) == "door":
		_append_door_dressing(trim, glass, face, t, n, width, float(group.get("support_y", bottom)), top, int(group.leaves), depth)
		return
	var lights := int(group.lights)
	face.y = (bottom + top) * 0.5
	var mullion := 0.12
	var light := (width - mullion * float(lights - 1)) / float(lights)
	# Mullions span from just off the glass back toward the host face.
	var inner := face - n * (depth - 0.085)
	for index in range(1, lights):
		var offset := -width * 0.5 + float(index) * light + (float(index) - 0.5) * mullion
		_append_box(trim, inner + t * offset, t, n, mullion, height, 0.16)
	if height > 3.0:
		var transom := inner
		transom.y = top - 1.0
		_append_box(trim, transom, t, n, width, 0.09, 0.16)
	_append_frame(trim, face + n * 0.05, t, n, width, height, 0.14, 0.10)
	var sill := face + n * 0.09
	sill.y = bottom - 0.14 - 0.04
	_append_box(trim, sill, t, n, width + 0.44, 0.08, 0.18)
	var head := face + n * 0.07
	head.y = top + 0.14 + 0.035
	_append_box(trim, head, t, n, width + 0.36, 0.07, 0.14)


# Closed exterior door variant of the shared family: painted leaves in front
# of the dark closed back, small dark upper lights and a raised lower panel
# per leaf, a three-sided surround on local land or the WSW platform, and
# the shared drip head. Leaf/light/panel sizes are production inference.
func _append_door_dressing(trim: Dictionary, glass: Dictionary, face: Vector3, t: Vector3, n: Vector3, width: float, land: float, top: float, leaves: int, depth: float) -> void:
	var member := 0.14
	var joint := 0.03
	var leaf_w := (width - 0.04 - joint * float(leaves - 1)) / float(leaves)
	# The parameter is dressing support: terrain for ENE, platform for WSW.
	# A 10mm overlap closes the support junction above the source-bottom back.
	var leaf_bottom := land - 0.01
	var leaf_h := top - 0.02 - leaf_bottom
	var leaf_plane := face - n * (depth - 0.045)
	var leaf_front := face - n * (depth - 0.07)
	for index in leaves:
		var offset := -width * 0.5 + 0.02 + leaf_w * 0.5 + float(index) * (leaf_w + joint)
		var leaf := leaf_plane + t * offset
		leaf.y = leaf_bottom + leaf_h * 0.5
		_append_box(trim, leaf, t, n, leaf_w, leaf_h, 0.05)
		for light_y: float in [top - 0.50, top - 0.90]:
			var light := leaf_front + t * offset + n * 0.005
			light.y = light_y
			_append_box(glass, light, t, n, minf(0.22, leaf_w - 0.16), 0.26, 0.02)
		var panel := leaf_front + t * offset + n * 0.01
		panel.y = land + 0.525
		_append_box(trim, panel, t, n, leaf_w - 0.18, 0.75, 0.02)
	var jamb_h := top + member - land
	for side: float in [-1.0, 1.0]:
		var jamb := face + n * 0.05 + t * side * (width + member) * 0.5
		jamb.y = land + jamb_h * 0.5
		_append_box(trim, jamb, t, n, member, jamb_h, 0.10)
	var head := face + n * 0.05
	head.y = top + member * 0.5
	_append_box(trim, head, t, n, width + member * 2.0, member, 0.10)
	var drip := face + n * 0.07
	drip.y = top + member + 0.035
	_append_box(trim, drip, t, n, width + 0.36, 0.07, 0.14)


# Outward layered relief (not a cavity) on the two belfry side faces seen in
# Jan2023 (-t/WSW) and Jun2026 (+t/ENE); front/back faces stay plain.
func _append_belfry_side_units(glass: Dictionary, trim: Dictionary, c: Vector3, t: Vector3, n: Vector3, inf: Dictionary) -> void:
	var center := c - n * float(inf.belfry_center_inward_from_sse_m)
	center.y = float(inf.belfry_side_unit_center_y)
	var unit_w := float(inf.belfry_side_unit_width)
	var unit_h := float(inf.belfry_side_unit_height)
	for side: float in [-1.0, 1.0]:
		var out := t * side
		var face := center + out * float(inf.belfry_plan_width) * 0.5
		_append_box(glass, face + out * 0.03, n, out, unit_w, unit_h, 0.06)
		_append_frame(trim, face + out * 0.06, n, out, unit_w, unit_h, 0.14, 0.12)
		for offset: float in [-unit_w / 6.0, unit_w / 6.0]:
			_append_box(trim, face + out * 0.05 + n * offset, n, out, 0.09, unit_h, 0.10)
		for fraction: float in [-0.30, 0.05, 0.33]:
			for shift: float in [-0.06, 0.06]:
				_append_box(trim, face + out * 0.075 + Vector3.UP * (unit_h * fraction + shift), n, out, unit_w, 0.045, 0.10)
		var sill := face + out * 0.06
		sill.y -= unit_h * 0.5 + 0.18
		_append_box(trim, sill, n, out, unit_w + 0.4, 0.08, 0.12)


# SSE gable glazing: stepped columns between deep pale fins over a broad pale
# lower panel zone (two tiers), a rail, main glazing with horizontal muntins
# and a timber-bordered central panel (Dec2016/Sep2025 hierarchy, not copied
# ornament). Proportions are reversible production inference.
func _append_gable_glazing(glass: Dictionary, trim: Dictionary, wood: Dictionary, c: Vector3, t: Vector3, n: Vector3, eave: float, ridge: float, width: float) -> void:
	var slope := (ridge - eave) / (width * 0.5)
	var base_y := 7.35
	var glass_y := 9.11
	var tops := {}
	for column: Array in [[0.0, 0.86], [0.73, 0.36], [-0.73, 0.36], [1.45, 0.84], [-1.45, 0.84]]:
		var x: float = column[0]
		var w: float = column[1]
		var top := ridge - 0.62 - (absf(x) + w * 0.5) * slope
		tops[x] = top
		var base := c + t * x
		_append_box(trim, base + n * 0.04 + Vector3.UP * ((base_y + glass_y) * 0.5), t, n, w, glass_y - base_y, 0.08)
		_append_box(trim, base + n * 0.10 + Vector3.UP * 8.2, t, n, w, 0.08, 0.06)
		_append_box(glass, base + n * 0.035 + Vector3.UP * ((glass_y + top) * 0.5), t, n, w, top - glass_y, 0.06)
		_append_box(trim, base + n * 0.07 + Vector3.UP * (glass_y - 0.06), t, n, w, 0.12, 0.14)
		var y := glass_y + 1.25
		while y < top - 0.45:
			_append_box(trim, base + n * 0.055 + Vector3.UP * y, t, n, w, 0.06, 0.10)
			y += 1.25
		_append_box(trim, base + n * 0.07 + Vector3.UP * (top + 0.06), t, n, w + 0.24, 0.12, 0.14)
	for fin: Array in [[0.49, 0.0, 0.73], [0.97, 0.73, 1.45], [1.93, 1.45, 1.45]]:
		var fin_top := maxf(float(tops[fin[1]]), float(tops[fin[2]])) + 0.12
		for side: float in [-1.0, 1.0]:
			var x: float = fin[0] * side
			_append_box(trim, c + t * x + n * 0.11 + Vector3.UP * ((7.33 + fin_top) * 0.5), t, n, 0.14, fin_top - 7.33, 0.22)
	_append_box(wood, c + n * 0.10 + Vector3.UP * 10.65, t, n, 0.66, 2.9, 0.07)
	_append_frame(trim, c + n * 0.11 + Vector3.UP * 10.65, t, n, 0.66, 2.9, 0.05, 0.08)


# Restrained pale corner boards on convex footprint corners, standing on the
# painted plinth line (no ground contact). Production inference.
func _append_corner_boards(trim: Dictionary, wall: Dictionary, c: Vector3, t: Vector3, width: float, eave: float, plinth_top: float) -> void:
	for run in range(WALL_RUN_COUNT):
		var prior := _run_frame(wall, (run + WALL_RUN_COUNT - 1) % WALL_RUN_COUNT)
		var next := _run_frame(wall, run)
		if (next.tangent as Vector3).dot(prior.normal as Vector3) > -0.5:
			continue
		var corner: Vector3 = next.start
		var top := LOWER_CAP_Y if absf((corner - c).dot(t)) > width * 0.5 + 0.10 else eave
		var center := corner + ((prior.normal as Vector3) + (next.normal as Vector3)) * 0.06
		center.y = (plinth_top + top) * 0.5
		_append_box(trim, center, prior.tangent, prior.normal, 0.16, top - plinth_top, 0.16)


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


# Shared box emitter, one connected platform and one three-tread flight.
# Actual LAND corner samples: 4.0109..4.0382; visible area is LAND + 0.04.
# Platform and tread heights are deliberately distinct from ground support.
func _append_wsw_landing(trim: Dictionary, decor: Dictionary, support: Dictionary, wall: Dictionary) -> void:
	var frame := _run_frame(wall, 3)
	var corner: Vector3 = frame.start
	corner.y = 0.0
	var u: Vector3 = frame.normal
	var v: Vector3 = frame.tangent
	var floor_y := 3.96
	var top_y := 4.52
	_append_box(trim, corner + u * 0.91 + v * 1.51 + Vector3.UP * ((floor_y + top_y) * 0.5), u, v, 2.38, top_y - floor_y, 3.58)
	for step in range(3):
		var tread_top := 4.40 - float(step) * 0.12
		_append_box(decor, corner + u * (2.24 + float(step) * 0.28) + v * 2.2 + Vector3.UP * ((floor_y + tread_top) * 0.5), u, v, 0.28, tread_top - floor_y, 2.2)
	# Accepted Mersea support grammar: physical surface through step nosings,
	# plus a grounded approach; visible stairs remain an explicit decor role.
	var stations := [[3.27, 4.01], [2.94, 4.16], [2.10, 4.52]]
	for index in range(stations.size() - 1):
		var outer: Array = stations[index]
		var inner: Array = stations[index + 1]
		var a := corner + u * float(outer[0]) + v * 1.1 + Vector3.UP * float(outer[1])
		var b := corner + u * float(outer[0]) + v * 3.3 + Vector3.UP * float(outer[1])
		var c := corner + u * float(inner[0]) + v * 3.3 + Vector3.UP * float(inner[1])
		var d := corner + u * float(inner[0]) + v * 1.1 + Vector3.UP * float(inner[1])
		_append_quad(support, a, b, c, d, _upward_normal(a, b, c))


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
	# Reference hierarchy: flush pale wall-top lip, inset raised square curb,
	# then one projecting metal eave and a complete pitched pyramid.
	_append_box(cream, Vector3(center.x, wall_top_y + 0.08, center.z), tangent, outward, width, 0.16, depth)
	var eave_y := float(inference.belfry_cap_eave_y)
	var cap_width := float(inference.belfry_cap_width)
	var cap_center := Vector3(center.x, eave_y, center.z)
	var curb_bottom := wall_top_y + 0.16
	_append_box(cream, Vector3(center.x, (curb_bottom + eave_y) * 0.5, center.z), tangent, outward, cap_width - 0.40, eave_y - curb_bottom, cap_width - 0.40)
	_append_box(roof, Vector3(center.x, eave_y - 0.045, center.z), tangent, outward, cap_width, 0.09, cap_width)
	var half_w := cap_width * 0.5
	var half_d := cap_width * 0.5
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
		# Restrained seams stay on the solid plane and stop before the apex;
		# avoiding a pile of intersecting rib ends keeps the cap readable.
		for seam in range(1, 7):
			var edge := a.lerp(b, float(seam) / 7.0)
			var low := edge.lerp(apex, 0.025) + normal * 0.018
			var high := edge.lerp(apex, 0.94) + normal * 0.018
			var axis := (high - low).normalized()
			var across := axis.cross(normal).normalized()
			_append_box(roof, (low + high) * 0.5, axis, across, low.distance_to(high), 0.036, 0.04)
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
		var placement := _chain_frame(wall_record, OBSERVED_ENE_HALL_RUNS, float(chain_m_value))
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
	var expected_mapped := [
		OBSERVED_SSE_RUNS,
		OBSERVED_ENE_HALL_RUNS,
		OBSERVED_WSW_RUNS,
		OBSERVED_WING_SSE_RUNS,
		OBSERVED_WSW_WING_GABLE_RUNS,
		OBSERVED_WSW_WING_SIDE_RUNS,
		OBSERVED_WSW_JUNCTION_RUNS,
		QUALIFIED_ENE_JUNCTION_RUNS,
	]
	if mapped.size() != expected_mapped.size() \
		or protected.is_empty() \
		or _int_array((protected[0] as Dictionary).get("run_indices", []) as Array) != PROTECTED_RUNS:
		return false
	for index in expected_mapped.size():
		var runs := _int_array((mapped[index] as Dictionary).get("ordered_run_indices", []) as Array)
		if runs != _int_array(expected_mapped[index] as Array):
			return false
		for run: int in runs:
			if run in PROTECTED_RUNS:
				return false
	if float(inference.get("main_gable_width", 0.0)) > 16.5 \
		or float(inference.get("main_gable_length", 0.0)) > 43.0 \
		or float(inference.get("main_gable_eave_y", 0.0)) <= 4.04 \
		or float(inference.get("main_gable_ridge_y", 0.0)) <= float(inference.get("main_gable_eave_y", 0.0)) \
		or float(inference.get("belfry_cap_apex_y", 0.0)) <= float(inference.get("belfry_wall_top_y", 0.0)) \
		or float(inference.get("cross_vertical_center_y", 0.0)) <= float(inference.get("belfry_cap_apex_y", 0.0)) \
		or (inference.get("side_window_chain_centers_m", []) as Array).size() != 4:
		return false
	# Opening groups stay above source bottoms and below their own eaves; the
	# lower cap pocket assumes the existing closed 0.28m recess.
	var hall_bottom := float(inference.get("opening_group_hall_bottom_y", 0.0))
	var hall_top := float(inference.get("opening_group_hall_top_y", 0.0))
	var wing_bottom := float(inference.get("opening_group_wing_bottom_y", 0.0))
	var wing_top := float(inference.get("opening_group_wing_top_y", 0.0))
	if not is_equal_approx(float(inference.get("opening_group_recess_depth", 0.0)), 0.28) \
		or hall_bottom <= 4.6 or hall_top <= hall_bottom or hall_top + 0.3 >= float(inference.get("main_gable_eave_y", 0.0)) \
		or wing_bottom <= 4.6 or wing_top <= wing_bottom or wing_top + 0.3 >= LOWER_CAP_Y \
		or float(inference.get("opening_group_hall_width", 0.0)) <= 0.0 \
		or float(inference.get("opening_group_ene_hall_width", 0.0)) <= 0.0 \
		or float(inference.get("opening_group_wing_width", 0.0)) <= 0.0 \
		or int(inference.get("opening_group_wsw_count", 0)) < 1 \
		or int(inference.get("opening_group_wing_lights", 0)) < 2:
		return false
	# Corner boards start on the painted plinth line, above every source bottom
	# and below the lowest opening-group sill.
	var plinth_top := float(inference.get("plinth_top_y", 0.0))
	if plinth_top <= 4.04 or plinth_top >= minf(hall_bottom, wing_bottom) - 0.3:
		return false
	# Wing/junction assemblies: each names exactly one assembly chain; windows
	# keep the plinth/sill rule and wing-eave clearance; closed doors are two-
	# leaf at most, 2.0-2.8m tall above land and land stays near source bottoms
	# (exact per-point contact is checked against the source in _groups_fit_chains).
	var assemblies := config.get("wing_and_junction_assemblies", []) as Array
	if assemblies.is_empty():
		return false
	for value: Variant in assemblies:
		if not (value is Dictionary):
			return false
		var assembly := value as Dictionary
		if not assembly.has_all(["id", "runs", "kind", "center_m", "width_m", "top_y"]) or not (assembly.runs is Array):
			return false
		var chain := _chain_for_runs(_int_array(assembly.get("runs", []) as Array))
		var top := float(assembly.top_y)
		if chain < ASSEMBLY_CHAIN_FIRST or float(assembly.width_m) <= 0.0 or top + 0.3 >= LOWER_CAP_Y:
			return false
		match str(assembly.kind):
			"window":
				var bottom := float(assembly.get("bottom_y", 0.0))
				if bottom <= plinth_top + 0.3 or top <= bottom or int(assembly.get("lights", 0)) < 2:
					return false
			"door":
				var land := float(assembly.get("land_y", 0.0))
				var support := float(assembly.get("support_y", land))
				var leaves := int(assembly.get("leaves", 0))
				if assembly.has("support_y") and (chain not in [4, 5] or not is_equal_approx(support, 4.52)):
					return false
				if land <= 3.9 or land >= 4.04 + 0.15 or top - support < 2.0 or top - support > 2.8 \
					or leaves < 1 or leaves > 2:
					return false
			_:
				return false
	# Belfry side relief keeps >=0.55m vertical and >=1.1m horizontal margins.
	var unit_center := float(inference.get("belfry_side_unit_center_y", 0.0))
	var unit_half := float(inference.get("belfry_side_unit_height", 0.0)) * 0.5
	if unit_center - unit_half < float(inference.get("belfry_base_y", 0.0)) + 0.55 \
		or unit_center + unit_half > float(inference.get("belfry_wall_top_y", 0.0)) - 0.55 \
		or float(inference.get("belfry_side_unit_width", 0.0)) > float(inference.get("belfry_plan_depth", 0.0)) - 2.2:
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
