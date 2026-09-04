class_name D1B225CumulativeMeterUvV1
extends RefCounted

## Isolated metre-coordinate contract for the eligible B225 NNW run chain.
##
## This helper deliberately knows only the source-supported ordered chain. U
## begins once at run 10 and remains cumulative through runs 11..13. V is the
## facade's local height in metres. A future receiver adapter must rederive its
## own corners from the frozen receiver; this standalone helper is not one.

const CONTRACT_VERSION := "ti.d1-b225-cumulative-metre-uv/1"
const SIDE_ID := "14812-NNW-LONG"
const RUN_INDICES: Array[int] = [10, 11, 12, 13]
const RUN_LENGTHS_M: Array[float] = [10.372629078, 6.510893794, 7.049860211, 22.328585289]
const EXACT_TOTAL_M := 46.261968372
const U_RULE := "one_cumulative_metre_coordinate_across_ordered_runs_10_through_13"
const V_RULE := "standalone_local_height_in_metres"
const FIRST_SEAM_RULE := "reset_u_to_zero_once_at_run_10_chain_start"
const CORNER_SEAM_RULE := "continue_u_without_reset_at_run_10_11_12_13_corners"


static func exact_plan() -> Dictionary:
	var entries: Array[Dictionary] = []
	var cursor_m := 0.0
	for order_index in RUN_INDICES.size():
		var length_m := RUN_LENGTHS_M[order_index]
		entries.append({
			"order_index": order_index,
			"run_index": RUN_INDICES[order_index],
			"length_m": length_m,
			"u_start_m": cursor_m,
			"u_end_m": cursor_m + length_m,
			"seam_before": FIRST_SEAM_RULE if order_index == 0 else CORNER_SEAM_RULE,
		})
		cursor_m += length_m
	var plan := {
		"ok": absf(cursor_m - EXACT_TOTAL_M) <= 0.000000001,
		"contract_version": CONTRACT_VERSION,
		"side_id": SIDE_ID,
		"entries": entries,
		"total_u_m": cursor_m,
		"u_rule": U_RULE,
		"v_rule": V_RULE,
		"first_seam_rule": FIRST_SEAM_RULE,
		"corner_seam_rule": CORNER_SEAM_RULE,
	}
	plan["signature"] = _signature(plan)
	return plan


static func vertical_quad_uvs(u_start_m: float, u_end_m: float, height_m: float) -> PackedVector2Array:
	if u_start_m < 0.0 or u_end_m <= u_start_m or height_m <= 0.0:
		return PackedVector2Array()
	return PackedVector2Array([
		Vector2(u_start_m, 0.0),
		Vector2(u_end_m, 0.0),
		Vector2(u_end_m, height_m),
		Vector2(u_start_m, height_m),
	])


static func entry_for_run(run_index: int) -> Dictionary:
	var plan := exact_plan()
	for entry_value: Variant in plan.get("entries", []) as Array:
		var entry := entry_value as Dictionary
		if int(entry.get("run_index", -1)) == run_index:
			return entry
	return {}


static func _signature(plan: Dictionary) -> String:
	var tokens := PackedStringArray([CONTRACT_VERSION, SIDE_ID, U_RULE, V_RULE])
	for entry_value: Variant in plan.get("entries", []) as Array:
		var entry := entry_value as Dictionary
		tokens.append("%d:%.9f:%.9f" % [
			int(entry.get("run_index", -1)),
			float(entry.get("u_start_m", 0.0)),
			float(entry.get("u_end_m", 0.0)),
		])
	return "|".join(tokens).sha256_text()
