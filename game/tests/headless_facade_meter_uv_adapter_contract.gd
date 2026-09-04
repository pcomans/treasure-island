extends SceneTree

const ADAPTER := preload("res://game/scripts/world/facades/facade_meter_uv_adapter.gd")
const ISLE_CONFIG_PATH := "res://game/resources/facades/isle_house_39_bruton_low_facade_prototype.json"

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var config_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(ISLE_CONFIG_PATH))
	if not _require(config_value is Dictionary, "Could not parse the Isle House metre-UV fixture."):
		_finish()
		return
	var config := config_value as Dictionary
	var runs := config.get("runs", []) as Array
	var sides := config.get("side_groups", []) as Array
	if not _require(_synthetic_chain_matches(), "Synthetic metre-UV chain continuity, corner, reset, or V contract failed.") \
	or not _require(_isle_public_chains_match(runs, sides), "Isle House public-side metre-UV plans drifted.") \
	or not _require(_invalid_inputs_fail_closed(), "Metre-UV adapter accepted a duplicate, disconnected, wrong-side, or length-drifted chain."):
		_finish()
		return
	print("PASS: facade metre-UV adapter keeps U continuous through explicitly ordered intra-side corners, resets U to zero at each side start, preserves world-Y metres as V, emits deterministic signatures, and fails closed on ambiguous chains")
	_finish()


func _synthetic_chain_matches() -> bool:
	var runs := [
		{"index": 4, "side_id": "TEST-SIDE", "start_xyz_m": [0.0, 2.0, 0.0], "end_xyz_m": [3.0, 2.0, 0.0], "length_m": 3.0},
		{"index": 9, "side_id": "TEST-SIDE", "start_xyz_m": [3.0, 5.0, 0.0], "end_xyz_m": [3.0, 5.0, 4.0], "length_m": 4.0},
	]
	var first := ADAPTER.plan_side_chain(runs, [4, 9], "TEST-SIDE") as Dictionary
	var second := ADAPTER.plan_side_chain(runs, [4, 9], "TEST-SIDE") as Dictionary
	if not bool(first.get("ok", false)) \
	or str(first.get("signature", "")).length() != 64 \
	or first.get("signature", "") != second.get("signature", "") \
	or not is_equal_approx(float(first.get("total_u_m", 0.0)), 7.0) \
	or str(first.get("u_phase_rule", "")) != ADAPTER.U_PHASE_RULE \
	or str(first.get("corner_rule", "")) != ADAPTER.CORNER_RULE \
	or str(first.get("v_phase_rule", "")) != ADAPTER.V_PHASE_RULE:
		return false
	var entries := first.get("entries", []) as Array
	if entries.size() != 2:
		return false
	var entry_a := entries[0] as Dictionary
	var entry_b := entries[1] as Dictionary
	if not is_zero_approx(float(entry_a.get("u_start_m", -1.0))) \
	or not is_equal_approx(float(entry_a.get("u_end_m", 0.0)), 3.0) \
	or not is_equal_approx(float(entry_b.get("u_start_m", 0.0)), 3.0) \
	or not is_equal_approx(float(entry_b.get("u_end_m", 0.0)), 7.0) \
	or str(entry_a.get("seam_before", "")) != ADAPTER.FIRST_SEAM_RULE \
	or str(entry_b.get("seam_before", "")) != ADAPTER.CONTINUOUS_SEAM_RULE \
	or ADAPTER.entry_for_run(first, 9) != entry_b \
	or not ADAPTER.entry_for_run(first, 99).is_empty():
		return false
	var uvs := ADAPTER.vertical_quad_uvs([
		Vector3(3.0, 2.25, 0.0),
		Vector3(3.0, 2.50, 4.0),
		Vector3(3.0, 9.50, 4.0),
		Vector3(3.0, 9.50, 0.0),
	], float(entry_b.get("u_start_m", 0.0)))
	return uvs == PackedVector2Array([
		Vector2(3.0, 2.25),
		Vector2(7.0, 2.50),
		Vector2(7.0, 9.50),
		Vector2(3.0, 9.50),
	])


func _isle_public_chains_match(runs: Array, sides: Array) -> bool:
	if sides.size() < 2:
		return false
	var expected_run_sets := [[0, 1, 2, 3, 4], [5, 6, 7, 8, 9]]
	for side_index in 2:
		var side := sides[side_index] as Dictionary
		var plan := ADAPTER.plan_side_chain(
			runs,
			side.get("ordered_run_indices", []) as Array,
			str(side.get("id", ""))
		) as Dictionary
		if not bool(plan.get("ok", false)) \
		or absf(float(plan.get("total_u_m", 0.0)) - float(side.get("length_m", 0.0))) > 0.002 \
		or str(plan.get("signature", "")).length() != 64:
			return false
		var entries := plan.get("entries", []) as Array
		if entries.size() != 5:
			return false
		for entry_index in entries.size():
			var entry := entries[entry_index] as Dictionary
			if int(entry.get("run_index", -1)) != int(expected_run_sets[side_index][entry_index]):
				return false
			if entry_index == 0:
				if not is_zero_approx(float(entry.get("u_start_m", -1.0))) \
				or str(entry.get("seam_before", "")) != ADAPTER.FIRST_SEAM_RULE:
					return false
			else:
				var previous := entries[entry_index - 1] as Dictionary
				if absf(float(previous.get("u_end_m", 0.0)) - float(entry.get("u_start_m", -1.0))) > 0.000001 \
				or str(entry.get("seam_before", "")) != ADAPTER.CONTINUOUS_SEAM_RULE:
					return false
	return true


func _invalid_inputs_fail_closed() -> bool:
	var valid := [
		{"index": 0, "side_id": "A", "start_xyz_m": [0.0, 0.0, 0.0], "end_xyz_m": [1.0, 0.0, 0.0], "length_m": 1.0},
		{"index": 1, "side_id": "A", "start_xyz_m": [1.0, 0.0, 0.0], "end_xyz_m": [2.0, 0.0, 0.0], "length_m": 1.0},
	]
	var wrong_side := valid.duplicate(true)
	(wrong_side[1] as Dictionary)["side_id"] = "B"
	var disconnected := valid.duplicate(true)
	(disconnected[1] as Dictionary)["start_xyz_m"] = [1.1, 0.0, 0.0]
	var wrong_length := valid.duplicate(true)
	(wrong_length[1] as Dictionary)["length_m"] = 2.0
	return not bool(ADAPTER.plan_side_chain(valid, [0, 0], "A").get("ok", true)) \
		and not bool(ADAPTER.plan_side_chain(wrong_side, [0, 1], "A").get("ok", true)) \
		and not bool(ADAPTER.plan_side_chain(disconnected, [0, 1], "A").get("ok", true)) \
		and not bool(ADAPTER.plan_side_chain(wrong_length, [0, 1], "A").get("ok", true)) \
		and not bool(ADAPTER.plan_side_chain(valid, [], "A").get("ok", true)) \
		and ADAPTER.vertical_quad_uvs([Vector3.ZERO], 0.0).is_empty()


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
