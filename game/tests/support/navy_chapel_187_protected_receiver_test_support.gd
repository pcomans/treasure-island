extends RefCounted

## Shared current-state isolation probe for legacy module contracts. Chapel's
## wall cannot be built as a standalone record: the accepted adapter requires
## the exact wall+roof pair from the supplied chunk. This helper proves that
## pair is the approved replacement and that it contains none of the caller's
## target-specific module family.

const ADAPTER := preload("res://game/scripts/world/facades/navy_chapel_187_live_replacement.gd")
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const WALL_KEY := "building:w291189336:wall"
const ROOF_KEY := "building:w291189336:roof"


static func exact_pair_excludes_module_family(module_root_name: String) -> bool:
	var chunk_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH))
	if not (chunk_value is Dictionary):
		return false
	var prepared := ADAPTER.prepare_chunk_records((chunk_value as Dictionary).get("records", []) as Array)
	if not bool(prepared.get("ok", false)) or not bool(prepared.get("contains_target", false)):
		return false
	var plan := ADAPTER.build_chunk_plan(prepared)
	if not bool(plan.get("ok", false)) or not bool(plan.get("contains_target", false)):
		ADAPTER.free_unconsumed(plan)
		return false
	var wall_result := ADAPTER.consume_record(prepared.get("wall", {}) as Dictionary, plan)
	var roof_result := ADAPTER.consume_record(prepared.get("roof", {}) as Dictionary, plan)
	var wall := wall_result.get("node", null) as Node3D
	var roof := roof_result.get("node", null) as Node3D
	var metadata := wall.get_meta("navy_chapel_187_live_replacement", {}) as Dictionary if wall != null else {}
	var matches := bool(wall_result.get("ok", false)) and bool(roof_result.get("ok", false)) \
		and wall != null and roof != null and ADAPTER.plan_was_fully_consumed(plan) \
		and wall.name == "NavyChapel187LiveWallVisualAndCollisionReplacement" \
		and roof.name == "NavyChapel187LiveRoofCollisionReplacement" \
		and str(metadata.get("geometry_signature", "")) == ADAPTER.EXPECTED_GEOMETRY_SIGNATURE \
		and str(metadata.get("live_ownership_signature", "")) == ADAPTER.EXPECTED_LIVE_OWNERSHIP_SIGNATURE \
		and wall.find_children(module_root_name, "Node3D", true, false).is_empty() \
		and roof.find_children(module_root_name, "Node3D", true, false).is_empty()
	if wall != null:
		wall.free()
	if roof != null:
		roof.free()
	ADAPTER.free_unconsumed(plan)
	return matches
