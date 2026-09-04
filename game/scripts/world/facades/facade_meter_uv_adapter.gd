class_name FacadeMeterUvAdapter
extends RefCounted

## Metre-authored UV planning for vertical facade runs.
##
## U is cumulative XZ distance within one explicitly ordered side chain. The
## first run on every side starts at U=0, so an intentional side boundary is
## also the deterministic reset boundary. V is the unmodified world-space Y
## coordinate in metres. Material UV scale therefore defines metres per repeat
## without coupling texture cadence to source mesh segmentation.

const CONTRACT_VERSION := "ti.facade-meter-uv/1"
const U_PHASE_RULE := "continuous_xz_metres_within_ordered_side_chain"
const CORNER_RULE := "continue_at_ordered_intra_side_corner_reset_at_side_start"
const V_PHASE_RULE := "absolute_world_y_metres"
const FIRST_SEAM_RULE := "reset_u_zero_at_side_start"
const CONTINUOUS_SEAM_RULE := "continue_u_at_ordered_corner"


static func plan_side_chain(
		runs: Array,
		ordered_run_indices: Array,
		expected_side_id: String,
		endpoint_tolerance_m: float = 0.002
	) -> Dictionary:
	if expected_side_id.is_empty():
		return _failure("missing_side_id")
	if ordered_run_indices.is_empty():
		return _failure("empty_ordered_chain")
	if endpoint_tolerance_m <= 0.0:
		return _failure("invalid_endpoint_tolerance")

	var run_by_index: Dictionary = {}
	for run_value: Variant in runs:
		if not (run_value is Dictionary):
			return _failure("run_is_not_dictionary")
		var run := run_value as Dictionary
		var run_index := int(run.get("index", -1))
		if run_index < 0 or run_by_index.has(run_index):
			return _failure("invalid_or_duplicate_run_index")
		run_by_index[run_index] = run

	var seen: Dictionary = {}
	var entries: Array[Dictionary] = []
	var cumulative_u_m := 0.0
	var previous_end := Vector3.ZERO
	for order_index in ordered_run_indices.size():
		var run_index := int(ordered_run_indices[order_index])
		if seen.has(run_index):
			return _failure("duplicate_ordered_run")
		seen[run_index] = true
		if not run_by_index.has(run_index):
			return _failure("ordered_run_missing")
		var run := run_by_index[run_index] as Dictionary
		if str(run.get("side_id", "")) != expected_side_id:
			return _failure("run_side_mismatch")
		var start_result := _vector3_from_array(run.get("start_xyz_m", []))
		var end_result := _vector3_from_array(run.get("end_xyz_m", []))
		if not bool(start_result.get("ok", false)) or not bool(end_result.get("ok", false)):
			return _failure("invalid_run_endpoint")
		var start := start_result.get("value", Vector3.ZERO) as Vector3
		var end := end_result.get("value", Vector3.ZERO) as Vector3
		var measured_length_m := _xz_distance(start, end)
		var declared_length_m := float(run.get("length_m", -1.0))
		if measured_length_m <= endpoint_tolerance_m or declared_length_m <= 0.0:
			return _failure("non_positive_run_length")
		if absf(measured_length_m - declared_length_m) > endpoint_tolerance_m:
			return _failure("declared_length_mismatch")
		if order_index > 0 and _xz_distance(previous_end, start) > endpoint_tolerance_m:
			return _failure("disconnected_ordered_corner")
		var entry := {
			"order_index": order_index,
			"run_index": run_index,
			"side_id": expected_side_id,
			"length_m": measured_length_m,
			"u_start_m": cumulative_u_m,
			"u_end_m": cumulative_u_m + measured_length_m,
			"seam_before": FIRST_SEAM_RULE if order_index == 0 else CONTINUOUS_SEAM_RULE,
		}
		entries.append(entry)
		cumulative_u_m += measured_length_m
		previous_end = end

	var plan := {
		"ok": true,
		"contract_version": CONTRACT_VERSION,
		"side_id": expected_side_id,
		"entries": entries,
		"total_u_m": cumulative_u_m,
		"u_phase_rule": U_PHASE_RULE,
		"corner_rule": CORNER_RULE,
		"v_phase_rule": V_PHASE_RULE,
		"endpoint_tolerance_m": endpoint_tolerance_m,
	}
	plan["signature"] = _plan_signature(plan)
	return plan


static func entry_for_run(plan: Dictionary, run_index: int) -> Dictionary:
	if not bool(plan.get("ok", false)):
		return {}
	for entry_value: Variant in plan.get("entries", []) as Array:
		var entry := entry_value as Dictionary
		if int(entry.get("run_index", -1)) == run_index:
			return entry
	return {}


static func vertical_quad_uvs(corners: Array, u_start_m: float) -> PackedVector2Array:
	if corners.size() != 4:
		return PackedVector2Array()
	var bottom_start := corners[0] as Vector3
	var bottom_end := corners[1] as Vector3
	var top_end := corners[2] as Vector3
	var top_start := corners[3] as Vector3
	var u_end_m := u_start_m + _xz_distance(bottom_start, bottom_end)
	return PackedVector2Array([
		Vector2(u_start_m, bottom_start.y),
		Vector2(u_end_m, bottom_end.y),
		Vector2(u_end_m, top_end.y),
		Vector2(u_start_m, top_start.y),
	])


static func contract_metadata() -> Dictionary:
	return {
		"contract_version": CONTRACT_VERSION,
		"coordinate_unit": "metre",
		"u_phase_rule": U_PHASE_RULE,
		"corner_rule": CORNER_RULE,
		"v_phase_rule": V_PHASE_RULE,
	}


static func _plan_signature(plan: Dictionary) -> String:
	var tokens: PackedStringArray = [
		str(plan.get("contract_version", "")),
		str(plan.get("side_id", "")),
		str(plan.get("u_phase_rule", "")),
		str(plan.get("corner_rule", "")),
		str(plan.get("v_phase_rule", "")),
	]
	for entry_value: Variant in plan.get("entries", []) as Array:
		var entry := entry_value as Dictionary
		tokens.append("%d:%d:%.6f:%.6f:%s" % [
			int(entry.get("order_index", -1)),
			int(entry.get("run_index", -1)),
			float(entry.get("u_start_m", 0.0)),
			float(entry.get("u_end_m", 0.0)),
			str(entry.get("seam_before", "")),
		])
	return "|".join(tokens).sha256_text()


static func _vector3_from_array(value: Variant) -> Dictionary:
	if not (value is Array) or (value as Array).size() != 3:
		return _failure("invalid_vector3")
	var values := value as Array
	return {
		"ok": true,
		"value": Vector3(float(values[0]), float(values[1]), float(values[2])),
	}


static func _xz_distance(first: Vector3, second: Vector3) -> float:
	return Vector2(first.x, first.z).distance_to(Vector2(second.x, second.z))


static func _failure(code: String) -> Dictionary:
	return {"ok": false, "code": code}
