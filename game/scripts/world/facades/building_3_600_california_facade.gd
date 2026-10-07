class_name Building3600CaliforniaFacade
extends Node3D

const TARGET_SOURCE_KEY := "w34313540"
const TARGET_LOGICAL_OBJECT_KEY := "building:w34313540"
const TARGET_RECEIVER_OBJECT_KEY := "building:w34313540:wall"
const LAYOUT_PATH := "res://game/resources/facades/building_3_600_california_ene_layout.json"
const RENDER_BUILDING_WALL := 1 << 1
const PAINT_SHADER := preload("res://game/resources/materials/world/building_3/building_3_painted_surface.gdshader")
const PLASTER_TEXTURES := "res://game/resources/textures/world/polyhaven/plaster_grey_04/plaster_grey_04_%s_1k.jpg"

# ENE composition (Nov 2025 Street View, observed side only). Every value below
# is reversible production inference fitted to the frozen 90.32 m ENE run, not a
# surveyed dimension: a broad closed pale lower front under the arched crown, a
# smaller recessed blue central portal under a raised pale bay, and articulated
# corner pylons with channels and stepped caps.
const GROUND_BURY_M := 0.10
const MAX_PROJECTION_M := 1.25
const MAX_HEAD_DEPTH_M := 6.7
const END_OVERHANG_M := 0.6
const PYLON_INNER_U := 7.4
const LOWER_TOP_Y := 13.9
const CORNICE_TOP_Y := 14.45
const BAY_HALF_WIDTH := 8.5
const JAMB_WIDTH := 1.2
const BAY_TOP_Y := 14.85
const HEADER_BOTTOM_Y := 11.6
const CLADDING_TOP_Y := 11.25
const OPENING_HALF_WIDTH := 3.7
const OPENING_TOP_Y := 10.0
const CROWN_SEAM_Y := 18.3
const CROWN_SEAM_COUNT := 7
const FASCIA_DEPTH_M := 0.30
const FASCIA_HEIGHT_M := 0.70
const JOINT_WIDTH_M := 0.16
const JOINT_OFFSET_M := 0.02

var _layout: Dictionary = {}
var _contract: Dictionary = {}
var _boxes_by_material: Dictionary = {}
var _solid_boxes: Array[Dictionary] = []
var _materials: Dictionary = {}
var _signature_parts: PackedStringArray = []
var _side: Dictionary = {}
var _runtime_massing: Dictionary = {}
var _run_u_starts: Array[float] = []
var _run_lengths: Array[float] = []
var _run_bottoms: Array[Vector2] = []
var _ground_y := 0.0
var _errors: PackedStringArray = []


static func matches_target(record: Dictionary) -> bool:
	var source_keys: Array = record.get("source_keys", [])
	return str(record.get("object_key", "")) == TARGET_RECEIVER_OBJECT_KEY \
		and str(record.get("feature_kind", "")) == "building_wall" \
		and str(record.get("material_key", "")) == "building_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false)) \
		and source_keys.size() == 1 \
		and str(source_keys[0]) == TARGET_SOURCE_KEY


func configure(record: Dictionary, runtime_massing: Dictionary = {}) -> Dictionary:
	if not matches_target(record):
		return {"ok": false, "message": "Building 3 facade refused a non-target receiver."}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LAYOUT_PATH))
	if not (parsed is Dictionary):
		return {"ok": false, "message": "Building 3 layout JSON could not be parsed."}
	_layout = parsed as Dictionary
	_contract = _layout.render_contract as Dictionary
	_side = _layout.observed_ene_main as Dictionary
	_runtime_massing = runtime_massing.duplicate(true)
	var target := _layout.target as Dictionary
	if str(target.source_key) != TARGET_SOURCE_KEY \
	or str(target.logical_object_key) != TARGET_LOGICAL_OBJECT_KEY \
	or str(target.receiver_object_key) != TARGET_RECEIVER_OBJECT_KEY \
	or int(target.wall_segments) != 59 \
	or int(target.wall_triangles) != 118 \
	or not _record_massing_matches(record, target) \
	or not _exact_runs_match(record) \
	or not _runtime_massing_matches():
		return {"ok": false, "message": "Building 3 layout identity, ENE run scope, or receiver massing drifted."}
	if _runtime_massing.is_empty():
		return {"ok": false, "message": "Building 3 ENE composition requires the runtime massing profile."}
	_signature_parts.append("massing:%s" % str(_runtime_massing.profile_signature))
	_measure_runs(record)
	var portal_u := _portal_center_u()
	if portal_u - BAY_HALF_WIDTH - JAMB_WIDTH <= PYLON_INNER_U + 6.0 or portal_u + BAY_HALF_WIDTH + JAMB_WIDTH >= _length() - PYLON_INNER_U - 6.0:
		return {"ok": false, "message": "Building 3 portal anchor no longer fits between the ENE pylons."}

	name = "Building3600CaliforniaFacade"
	set_meta("target_source_key", TARGET_SOURCE_KEY)
	set_meta("target_logical_object_key", TARGET_LOGICAL_OBJECT_KEY)
	set_meta("target_receiver_object_key", TARGET_RECEIVER_OBJECT_KEY)
	set_meta("layout_path", LAYOUT_PATH)
	set_meta("render_only", true)
	set_meta("collision", "solid_boxes_owned_by_runtime_massing_receiver")
	set_meta("navigation", "none")
	set_meta("spray_ray_owner", "runtime_massing_receiver")
	set_meta("runtime_massing_bound", true)
	set_meta("runtime_massing_signature", str(_runtime_massing.get("profile_signature", "")))
	set_meta("production_inference_reversible", true)
	set_meta("corrected_nrhp_id", "08000083")
	set_meta("frozen_osm_nrhp_ref", "08000081")
	set_meta("frozen_osm_nrhp_ref_role", "provenance_only_incorrect_for_building_3")
	set_meta("maximum_relief_m", MAX_PROJECTION_M)
	set_meta("composition", "ene_nov2025_closed_lower_front_recessed_blue_portal_channelled_pylons")
	set_meta("styled_run_indices", _int_array(_side.run_indices as Array))
	set_meta("styled_run_length_m", float(_side.length_m))
	set_meta("excluded_run_indices", _int_array(_layout.excluded_run_indices as Array))
	add_to_group("building_3_render_only_facade")

	var field_result := _build_field(record)
	if not bool(field_result.get("ok", false)):
		return field_result
	_build_pylon(false)
	_build_pylon(true)
	_build_lower_front(portal_u)
	_build_portal(portal_u)
	_build_crown_face()
	if not _errors.is_empty():
		return {"ok": false, "message": "Building 3 ENE composition rejected: %s" % "; ".join(_errors)}
	_flush_render_batches()
	set_meta("field_segment_count", int(field_result.segment_count))
	set_meta("solid_box_count", _solid_boxes.size())
	set_meta("ground_y_m", _ground_y)
	set_meta("deterministic_signature", "|".join(_signature_parts).sha256_text())
	return {
		"ok": true,
		"field_segment_count": int(field_result.segment_count),
		"solid_box_count": _solid_boxes.size(),
		"deterministic_signature": str(get_meta("deterministic_signature")),
	}


## Oriented boxes (transform with orthonormal basis, full size) that the owning
## runtime massing adds to the canonical wall receiver body, so projecting
## render geometry is never walk-through or spray-transparent.
func solid_boxes() -> Array[Dictionary]:
	return _solid_boxes.duplicate(true)


func _record_massing_matches(record: Dictionary, target: Dictionary) -> bool:
	var vertices: Array = record.get("vertices", [])
	var indices: Array = record.get("indices", [])
	if vertices.size() != 708 or indices.size() != 354:
		return false
	var top_y := -INF
	for offset in range(1, vertices.size(), 3):
		top_y = maxf(top_y, float(vertices[offset]))
	return is_equal_approx(top_y, float(target.top_y_m)) \
		and is_equal_approx(top_y - float(target.base_y_m), float(target.height_m))


func _exact_runs_match(record: Dictionary) -> bool:
	var expected_runs: Array = _side.runs
	var raw_vertices: Array = record.vertices
	for run_value: Variant in expected_runs:
		var expected := run_value as Dictionary
		var run_index := int(expected.index)
		var offset := run_index * 12
		var start: Array = expected.start_xz_m
		var end: Array = expected.end_xz_m
		if not is_equal_approx(float(raw_vertices[offset]), float(start[0])) \
		or not is_equal_approx(float(raw_vertices[offset + 2]), float(start[1])) \
		or not is_equal_approx(float(raw_vertices[offset + 3]), float(end[0])) \
		or not is_equal_approx(float(raw_vertices[offset + 5]), float(end[1])):
			return false
	return true


func _runtime_massing_matches() -> bool:
	if _runtime_massing.is_empty():
		return true
	var samples: Array = _runtime_massing.get("wall_run_top_y_samples", [])
	return str(_runtime_massing.get("schema_version", "")) == "ti.building-3-massing-runtime/1" \
		and str(_runtime_massing.get("target_source_key", "")) == TARGET_SOURCE_KEY \
		and str(_runtime_massing.get("target_wall_key", "")) == TARGET_RECEIVER_OBJECT_KEY \
		and str(_runtime_massing.get("corrected_nrhp_id", "")) == "08000083" \
		and str(_runtime_massing.get("frozen_osm_nrhp_ref_role", "")) == "provenance_only_incorrect_for_building_3" \
		and int(_runtime_massing.get("wall_subdivisions", 0)) >= 1 \
		and samples.size() == 59 \
		and str(_runtime_massing.get("profile_signature", "")) != ""


## Exact source run lengths and wall-bottom elevations along the ENE side. The
## lowest exact bottom, buried slightly, is where every grounded box starts, so
## nothing floats where the local land dips toward the portal.
func _measure_runs(record: Dictionary) -> void:
	var raw_vertices: Array = record.vertices
	var u := 0.0
	_ground_y = INF
	for index_value: Variant in _side.run_indices:
		var offset := int(index_value) * 12
		var start := Vector3(float(raw_vertices[offset]), float(raw_vertices[offset + 1]), float(raw_vertices[offset + 2]))
		var end := Vector3(float(raw_vertices[offset + 3]), float(raw_vertices[offset + 4]), float(raw_vertices[offset + 5]))
		var run_length := Vector2(start.x, start.z).distance_to(Vector2(end.x, end.z))
		_run_u_starts.append(u)
		_run_lengths.append(run_length)
		_run_bottoms.append(Vector2(start.y, end.y))
		_ground_y = minf(_ground_y, minf(start.y, end.y))
		u += run_length
	_ground_y -= GROUND_BURY_M


func _length() -> float:
	return float(_side.length_m)


func _portal_center_u() -> float:
	for module_value: Variant in _side.modules:
		var module := module_value as Dictionary
		if str(module.kind) == "B3-HANGAR-DOOR":
			return float(module.u_m)
	return _length() * 0.5


## Exact visible wall top at u, interpolated between the same runtime samples
## the receiver mesh uses, so crown trim follows the arch without gaps.
func _top_y_at(u: float) -> float:
	var samples: Array = _runtime_massing.wall_run_top_y_samples
	var subdivisions := int(_runtime_massing.wall_subdivisions)
	var run_values: Array = _side.run_indices
	for local_index in run_values.size():
		var run_start := _run_u_starts[local_index]
		var run_length := _run_lengths[local_index]
		if u <= run_start + run_length or local_index == run_values.size() - 1:
			var step := clampf((u - run_start) / run_length, 0.0, 1.0) * float(subdivisions)
			var first := mini(int(floor(step)), subdivisions - 1)
			var run_samples: Array = samples[int(run_values[local_index])]
			return lerpf(float(run_samples[first]), float(run_samples[first + 1]), step - float(first))
	return float(_runtime_massing.eave_y_m)


func _build_field(record: Dictionary) -> Dictionary:
	var group := _empty_surface_group()
	var raw_vertices: Array = record.vertices
	var raw_normals: Array = record.normals
	var subdivisions := int(_runtime_massing.get("wall_subdivisions", 1))
	var runtime_samples: Array = _runtime_massing.get("wall_run_top_y_samples", [])
	var segment_count := 0
	for index_value: Variant in _side.run_indices:
		var run_index := int(index_value)
		var offset := run_index * 12
		var start_bottom := Vector3(float(raw_vertices[offset]), float(raw_vertices[offset + 1]), float(raw_vertices[offset + 2]))
		var end_bottom := Vector3(float(raw_vertices[offset + 3]), float(raw_vertices[offset + 4]), float(raw_vertices[offset + 5]))
		var normal := Vector3(float(raw_normals[offset]), 0.0, float(raw_normals[offset + 2])).normalized()
		var outward := normal * float(_contract.field_offset_m)
		var top_samples: Array = runtime_samples[run_index] as Array
		if top_samples.size() != subdivisions + 1:
			return {"ok": false, "message": "Building 3 runtime wall samples do not match facade subdivisions."}
		for subdivision in subdivisions:
			var first_fraction := float(subdivision) / float(subdivisions)
			var second_fraction := float(subdivision + 1) / float(subdivisions)
			var first_bottom := start_bottom.lerp(end_bottom, first_fraction)
			var second_bottom := start_bottom.lerp(end_bottom, second_fraction)
			_append_quad(group, [
				first_bottom + outward,
				second_bottom + outward,
				Vector3(second_bottom.x, float(top_samples[subdivision + 1]), second_bottom.z) + outward,
				Vector3(first_bottom.x, float(top_samples[subdivision]), first_bottom.z) + outward,
			], normal)
			segment_count += 1
	_add_mesh("FacadeFields_Runs_27_35", group, "plaster_pale")
	_signature_parts.append("fields:27-35:%d:plaster" % segment_count)
	return {"ok": true, "segment_count": segment_count}


## One articulated corner pylon: a broad lower shaft, a set-back upper shaft,
## both with two recessed vertical channels, a head standing on the roof
## corner and a stepped cap. `south` mirrors the shaft to the far ENE end.
func _build_pylon(south: bool) -> void:
	var lower := [-0.35, PYLON_INNER_U]
	var upper := [-0.25, 7.1]
	var shaft_top := 24.9
	_pylon_shaft(south, lower[0], lower[1], _ground_y, CORNICE_TOP_Y + 0.15, 0.75, 1.10)
	_pylon_box(south, "plaster_light", lower[0], lower[1], CORNICE_TOP_Y + 0.15, CORNICE_TOP_Y + 0.45, 0.0, 1.10, true)
	_pylon_shaft(south, upper[0], upper[1], CORNICE_TOP_Y + 0.45, shaft_top, 0.62, 0.95)
	# Head: stands inside the footprint on the roof corner; its base is below
	# the runtime roof surface there, so no gap opens under it.
	_pylon_box(south, "plaster_pale", upper[0], upper[1], 22.4, shaft_top + 0.4, -6.4, 0.0, true)
	_pylon_box(south, "plaster_light", upper[0], upper[1], shaft_top, shaft_top + 0.4, 0.0, 0.95, true)
	_pylon_box(south, "plaster_light", -0.5, 7.35, shaft_top + 0.4, shaft_top + 0.8, -6.65, 1.2, true)
	_pylon_box(south, "plaster_pale", 0.6, 6.25, shaft_top + 0.8, shaft_top + 1.7, -5.6, 0.2, true)
	_pylon_box(south, "plaster_light", 1.5, 5.35, shaft_top + 1.7, shaft_top + 2.0, -4.7, -0.7, true)
	_signature_parts.append("pylon:%s:channelled:stepped-cap" % ("south" if south else "north"))


func _pylon_shaft(south: bool, u0: float, u1: float, y0: float, y1: float, core_depth: float, front_depth: float) -> void:
	_pylon_box(south, "plaster_shade", u0, u1, y0, y1, 0.0, core_depth, true)
	var width := u1 - u0
	var edge := width * 0.21
	var channel := 0.45
	var strips := [
		[u0, u0 + edge],
		[u0 + edge + channel, u1 - edge - channel],
		[u1 - edge, u1],
	]
	for strip: Array in strips:
		_pylon_box(south, "plaster_pale", float(strip[0]), float(strip[1]), y0, y1, core_depth, front_depth, true)


func _pylon_box(south: bool, material_key: String, u0: float, u1: float, y0: float, y1: float, d0: float, d1: float, solid: bool) -> void:
	if south:
		_add_box(material_key, _length() - u1, _length() - u0, y0, y1, d0, d1, solid)
	else:
		_add_box(material_key, u0, u1, y0, y1, d0, d1, solid)


## Broad closed pale front between pylon and portal bay: a backing slab, panels
## separated by shallow joints and one projecting cornice. The cornice is a
## single deep block; thin stacked steps would leave sub-pixel faces at range.
func _build_lower_front(portal_u: float) -> void:
	var bay_outer := BAY_HALF_WIDTH + JAMB_WIDTH
	for span: Array in [[PYLON_INNER_U, portal_u - bay_outer], [portal_u + bay_outer, _length() - PYLON_INNER_U]]:
		var u0 := float(span[0])
		var u1 := float(span[1])
		_add_box("plaster_shade", u0, u1, _ground_y, LOWER_TOP_Y, 0.0, 0.40, true)
		var panel_count := maxi(1, int(round((u1 - u0) / 6.5)))
		var joint := 0.12
		var pitch := (u1 - u0) / float(panel_count)
		for panel in panel_count:
			var a := u0 + pitch * float(panel) + (joint * 0.5 if panel > 0 else 0.0)
			var b := u0 + pitch * float(panel + 1) - (joint * 0.5 if panel < panel_count - 1 else 0.0)
			_add_box("plaster_pale", a, b, _ground_y, LOWER_TOP_Y - 0.3, 0.40, 0.55, true)
		_add_box("plaster_light", u0, u1, LOWER_TOP_Y - 0.3, CORNICE_TOP_Y, 0.0, 0.88, true)
	_signature_parts.append("lower-front:closed-panels:%.2f:%.2f" % [LOWER_TOP_Y, CORNICE_TOP_Y])


## Smaller recessed blue portal: pale jamb piers and a raised header bay frame
## blue ribbed cladding set back from the lower front, around a dark opening.
func _build_portal(portal_u: float) -> void:
	var half := BAY_HALF_WIDTH
	for direction: float in [-1.0, 1.0]:
		var inner := portal_u + direction * half
		var outer := portal_u + direction * (half + JAMB_WIDTH)
		_add_box("plaster_pale", minf(inner, outer), maxf(inner, outer), _ground_y, BAY_TOP_Y - 0.35, 0.0, 0.95, true)
	_add_box("plaster_light", portal_u - half, portal_u + half, HEADER_BOTTOM_Y, BAY_TOP_Y - 0.35, 0.0, 0.95, true)
	_add_box("plaster_pale", portal_u - half - JAMB_WIDTH, portal_u + half + JAMB_WIDTH, BAY_TOP_Y - 0.35, BAY_TOP_Y, 0.0, 0.95, true)
	_add_box("trim_green", portal_u - half, portal_u + half, CLADDING_TOP_Y, HEADER_BOTTOM_Y, 0.0, 0.30, false)
	var opening := OPENING_HALF_WIDTH
	# Cladding around the opening (left, right and lintel), with standing ribs.
	_add_box("blue_cladding", portal_u - half, portal_u - opening, _ground_y, CLADDING_TOP_Y, 0.0, 0.16, false)
	_add_box("blue_cladding", portal_u + opening, portal_u + half, _ground_y, CLADDING_TOP_Y, 0.0, 0.16, false)
	_add_box("blue_cladding", portal_u - opening, portal_u + opening, OPENING_TOP_Y, CLADDING_TOP_Y, 0.0, 0.16, false)
	var rib_pitch := 0.9
	var rib := portal_u - half + rib_pitch * 0.5
	while rib < portal_u + half - 0.1:
		if absf(rib - portal_u) > opening + 0.35:
			_add_box("blue_rib", rib - 0.05, rib + 0.05, _ground_y, CLADDING_TOP_Y, 0.16, 0.22, false)
		rib += rib_pitch
	# Opening frame and a dark roll-up door with faint horizontal slats.
	_add_box("blue_rib", portal_u - opening - 0.28, portal_u - opening, _ground_y, OPENING_TOP_Y + 0.28, 0.0, 0.26, false)
	_add_box("blue_rib", portal_u + opening, portal_u + opening + 0.28, _ground_y, OPENING_TOP_Y + 0.28, 0.0, 0.26, false)
	_add_box("blue_rib", portal_u - opening, portal_u + opening, OPENING_TOP_Y, OPENING_TOP_Y + 0.28, 0.0, 0.26, false)
	_add_box("door_dark", portal_u - opening, portal_u + opening, _ground_y, OPENING_TOP_Y, 0.0, 0.05, false)
	var slat_y := _ground_y + GROUND_BURY_M + 0.6
	while slat_y < OPENING_TOP_Y - 0.2:
		_add_box("door_line", portal_u - opening, portal_u + opening, slat_y, slat_y + 0.05, 0.05, 0.07, false)
		slat_y += 0.6
	_signature_parts.append("portal:%.3f:%.2f:%.2f:recessed-blue" % [portal_u, half, opening])


## Crown face above the cornice: faint flush panel joints and a projecting
## fascia that follows the exact runtime arch top between the pylon heads.
## Joints are single front-facing strips (no 3-4 cm side faces) that cast no
## shadow, and the fascia soffit is chamfered back to the wall, so neither
## leaves sub-pixel dark faces that read as dashed cracks at gameplay range.
func _build_crown_face() -> void:
	var u0 := PYLON_INNER_U
	var u1 := _length() - PYLON_INNER_U
	var normal := _side_basis().z
	var joints := _empty_surface_group()
	var pitch := (u1 - u0) / float(CROWN_SEAM_COUNT + 1)
	var half_joint := JOINT_WIDTH_M * 0.5
	for seam in CROWN_SEAM_COUNT:
		var u := u0 + pitch * float(seam + 1)
		var top := _top_y_at(u) - FASCIA_HEIGHT_M - FASCIA_DEPTH_M - 0.15
		if top > CORNICE_TOP_Y + 1.0:
			_append_oriented_quad(joints, [
				_side_point(u - half_joint, CORNICE_TOP_Y, JOINT_OFFSET_M),
				_side_point(u + half_joint, CORNICE_TOP_Y, JOINT_OFFSET_M),
				_side_point(u + half_joint, top, JOINT_OFFSET_M),
				_side_point(u - half_joint, top, JOINT_OFFSET_M),
			], normal)
	# Slightly further out than the vertical joints, so the crossing is not coplanar.
	_append_oriented_quad(joints, [
		_side_point(u0, CROWN_SEAM_Y - half_joint, JOINT_OFFSET_M + 0.004),
		_side_point(u1, CROWN_SEAM_Y - half_joint, JOINT_OFFSET_M + 0.004),
		_side_point(u1, CROWN_SEAM_Y + half_joint, JOINT_OFFSET_M + 0.004),
		_side_point(u0, CROWN_SEAM_Y + half_joint, JOINT_OFFSET_M + 0.004),
	], normal)
	_add_mesh("CrownJoints", joints, "seam", false)
	var group := _empty_surface_group()
	var points: Array[float] = [u0 - 0.4]
	for local_index in _run_u_starts.size():
		var subdivisions := int(_runtime_massing.wall_subdivisions)
		for step in subdivisions + 1:
			var u := _run_u_starts[local_index] + _run_lengths[local_index] * float(step) / float(subdivisions)
			if u > points[points.size() - 1] + 0.01 and u < u1 + 0.4:
				points.append(u)
	points.append(u1 + 0.4)
	for index in points.size() - 1:
		var ua := points[index]
		var ub := points[index + 1]
		var ya := _top_y_at(ua)
		var yb := _top_y_at(ub)
		var front_a_top := _side_point(ua, ya, FASCIA_DEPTH_M)
		var front_b_top := _side_point(ub, yb, FASCIA_DEPTH_M)
		var front_a_low := _side_point(ua, ya - FASCIA_HEIGHT_M, FASCIA_DEPTH_M)
		var front_b_low := _side_point(ub, yb - FASCIA_HEIGHT_M, FASCIA_DEPTH_M)
		var back_a_low := _side_point(ua, ya - FASCIA_HEIGHT_M - FASCIA_DEPTH_M, 0.0)
		var back_b_low := _side_point(ub, yb - FASCIA_HEIGHT_M - FASCIA_DEPTH_M, 0.0)
		var back_a_top := _side_point(ua, ya, 0.0)
		var back_b_top := _side_point(ub, yb, 0.0)
		_append_oriented_quad(group, [front_a_low, front_b_low, front_b_top, front_a_top], normal)
		_append_oriented_quad(group, [back_a_low, back_b_low, front_b_low, front_a_low], normal + Vector3.DOWN)
		_append_oriented_quad(group, [front_a_top, front_b_top, back_b_top, back_a_top], Vector3.UP)
	_add_mesh("CrownFascia", group, "plaster_light")
	_signature_parts.append("crown-face:%d-flush-joints:chamfered-fascia:%d" % [CROWN_SEAM_COUNT, points.size()])


func _add_box(material_key: String, u0: float, u1: float, y0: float, y1: float, d0: float, d1: float, solid: bool) -> void:
	if not (u1 > u0 and y1 > y0 and d1 > d0) \
	or u0 < -END_OVERHANG_M or u1 > _length() + END_OVERHANG_M \
	or d1 > MAX_PROJECTION_M or d0 < -MAX_HEAD_DEPTH_M \
	or y0 < _ground_y - 0.001:
		_errors.append("%s box out of bounds u[%.2f,%.2f] y[%.2f,%.2f] d[%.2f,%.2f]" % [material_key, u0, u1, y0, y1, d0, d1])
		return
	var center := _side_point((u0 + u1) * 0.5, (y0 + y1) * 0.5, (d0 + d1) * 0.5)
	var size := Vector3(u1 - u0, y1 - y0, d1 - d0)
	var basis := _side_basis()
	var scaled := Basis(basis.x * size.x, basis.y * size.y, basis.z * size.z)
	if not _boxes_by_material.has(material_key):
		_boxes_by_material[material_key] = []
	(_boxes_by_material[material_key] as Array).append(Transform3D(scaled, center))
	if solid:
		_solid_boxes.append({"transform": Transform3D(basis, center), "size": size, "material_key": material_key})


func _side_basis() -> Basis:
	var start: Array = _side.start_xz_m
	var end: Array = _side.end_xz_m
	var normal_values: Array = _side.normal_xz
	var tangent := Vector3(float(end[0]) - float(start[0]), 0.0, float(end[1]) - float(start[1])).normalized()
	var normal := Vector3(float(normal_values[0]), 0.0, float(normal_values[1])).normalized()
	return Basis(tangent, Vector3.UP, normal).orthonormalized()


func _side_point(u: float, y: float, outward: float) -> Vector3:
	var start: Array = _side.start_xz_m
	var basis := _side_basis()
	return Vector3(float(start[0]), y, float(start[1])) + basis.x * u + basis.z * outward


func _material(key: String) -> Material:
	if _materials.has(key):
		return _materials[key] as Material
	var m := ShaderMaterial.new()
	m.shader = PAINT_SHADER
	m.resource_name = "building_3_ene_%s" % key
	var tints := {
		"plaster_pale": Color(0.78, 0.755, 0.675),
		"plaster_light": Color(0.82, 0.80, 0.735),
		"plaster_shade": Color(0.68, 0.665, 0.605),
		"seam": Color(0.64, 0.625, 0.575),
		"blue_cladding": Color(0.225, 0.335, 0.445),
		"blue_rib": Color(0.20, 0.30, 0.40),
		"trim_green": Color(0.235, 0.325, 0.275),
		"door_dark": Color(0.10, 0.09, 0.08),
		"door_line": Color(0.18, 0.17, 0.15),
	}
	if not tints.has(key):
		_errors.append("unknown material %s" % key)
		return m
	var mineral := key.begins_with("plaster") or key == "seam"
	m.set_shader_parameter("paint_color", tints[key])
	m.set_shader_parameter("surface_color", load(PLASTER_TEXTURES % "diff"))
	m.set_shader_parameter("surface_normal", load(PLASTER_TEXTURES % "nor_gl"))
	m.set_shader_parameter("surface_roughness", load(PLASTER_TEXTURES % "rough"))
	m.set_shader_parameter("tile_span_m", 1.5 if mineral else 0.65)
	m.set_shader_parameter("relief_strength", 0.13 if mineral else 0.025)
	m.set_shader_parameter("color_variation", 0.22 if mineral else 0.075)
	m.set_shader_parameter("coating_variation", 0.16 if key.begins_with("plaster") else 0.0)
	m.set_shader_parameter("roughness_base", 0.86 if mineral else 0.63)
	m.set_shader_parameter("stain_strength", 0.26 if mineral else 0.025)
	m.set_shader_parameter("facade_origin", _side_point(0.0, 0.0, 0.0))
	m.set_shader_parameter("facade_tangent", _side_basis().x)
	m.set_shader_parameter("facade_outward", _side_basis().z)
	m.set_shader_parameter("facade_length", _length())
	m.set_shader_parameter("ledge_y", CORNICE_TOP_Y)

	_materials[key] = m
	return m


func _add_mesh(node_name: String, group: Dictionary, material_key: String, casts_shadow := true) -> void:
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = group.vertices
	arrays[Mesh.ARRAY_NORMAL] = group.normals
	arrays[Mesh.ARRAY_TANGENT] = group.tangents
	arrays[Mesh.ARRAY_INDEX] = group.indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, _material(material_key))
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.layers = RENDER_BUILDING_WALL
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if casts_shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta("facade_visual", true)
	instance.set_meta("exact_receiver_run_indices", _int_array(_side.run_indices as Array))
	instance.set_meta("foundation_geometry_untouched", true)
	add_child(instance)


func _flush_render_batches() -> void:
	var batches := Node3D.new()
	batches.name = "RenderBatches"
	batches.set_meta("render_only", true)
	add_child(batches)
	var keys := _boxes_by_material.keys()
	keys.sort()
	for key_value: Variant in keys:
		var material_key := str(key_value)
		var transforms := _boxes_by_material[material_key] as Array
		var box := BoxMesh.new()
		box.size = Vector3.ONE
		box.material = _material(material_key)
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = box
		multimesh.instance_count = transforms.size()
		for index in transforms.size():
			var instance_transform := transforms[index] as Transform3D
			multimesh.set_instance_transform(index, instance_transform)
			_signature_parts.append("box:%s:%s" % [material_key, _transform_token(instance_transform)])
		var instance := MultiMeshInstance3D.new()
		instance.name = "Batch_%s" % material_key
		instance.multimesh = multimesh
		instance.layers = RENDER_BUILDING_WALL
		instance.set_meta("facade_visual", true)
		instance.set_meta("material_key", material_key)
		instance.set_meta("instance_count", transforms.size())
		batches.add_child(instance)


func _empty_surface_group() -> Dictionary:
	return {"vertices": PackedVector3Array(), "normals": PackedVector3Array(), "tangents": PackedFloat32Array(), "indices": PackedInt32Array()}


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _append_quad(group: Dictionary, corners: Array, normal: Vector3) -> void:
	var vertices := group.vertices as PackedVector3Array
	var normals := group.normals as PackedVector3Array
	var tangents := group.tangents as PackedFloat32Array
	var indices := group.indices as PackedInt32Array
	var base := vertices.size()
	var tangent := Vector3(normal.z, 0.0, -normal.x).normalized()
	for corner_value: Variant in corners:
		vertices.append(corner_value as Vector3)
		normals.append(normal)
		tangents.append_array(PackedFloat32Array([tangent.x, tangent.y, tangent.z, 1.0]))
	indices.append_array(PackedInt32Array([base, base + 2, base + 1, base, base + 3, base + 2]))
	group["vertices"] = vertices
	group["normals"] = normals
	group["tangents"] = tangents
	group["indices"] = indices


## Planar quad (corners in order around the edge) facing the side of `facing`.
## Its normal is the actual plane normal, its tangent the first edge made
## orthogonal to that normal, and the tangent sign makes the binormal follow
## the second edge, so normal mapping is consistent on sloped faces. Triangles
## keep Godot's clockwise front-face rule (geometric cross product pointing
## away from the viewer).
func _append_oriented_quad(group: Dictionary, corners: Array, facing: Vector3) -> void:
	var c0 := corners[0] as Vector3
	var first_edge := (corners[1] as Vector3) - c0
	var second_edge := (corners[3] as Vector3) - c0
	var normal := first_edge.cross(second_edge).normalized()
	if normal.dot(facing) < 0.0:
		normal = -normal
	var tangent := (first_edge - normal * normal.dot(first_edge)).normalized()
	var handedness := 1.0 if normal.cross(tangent).dot(second_edge) >= 0.0 else -1.0
	var vertices := group.vertices as PackedVector3Array
	var normals := group.normals as PackedVector3Array
	var tangents := group.tangents as PackedFloat32Array
	var indices := group.indices as PackedInt32Array
	var base := vertices.size()
	for corner_value: Variant in corners:
		vertices.append(corner_value as Vector3)
		normals.append(normal)
		tangents.append_array(PackedFloat32Array([tangent.x, tangent.y, tangent.z, handedness]))
	for triangle: Array in [[0, 1, 2], [0, 2, 3]]:
		var a := corners[int(triangle[0])] as Vector3
		var b := corners[int(triangle[1])] as Vector3
		var c := corners[int(triangle[2])] as Vector3
		if (b - a).cross(c - a).dot(normal) > 0.0:
			indices.append_array(PackedInt32Array([base + int(triangle[0]), base + int(triangle[2]), base + int(triangle[1])]))
		else:
			indices.append_array(PackedInt32Array([base + int(triangle[0]), base + int(triangle[1]), base + int(triangle[2])]))
	group["vertices"] = vertices
	group["normals"] = normals
	group["tangents"] = tangents
	group["indices"] = indices


func _transform_token(value: Transform3D) -> String:
	return "%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f" % [
		value.basis.x.x, value.basis.x.y, value.basis.x.z,
		value.basis.y.x, value.basis.y.y, value.basis.y.z,
		value.basis.z.x, value.basis.z.y, value.basis.z.z,
		value.origin.x, value.origin.y, value.origin.z,
	]
