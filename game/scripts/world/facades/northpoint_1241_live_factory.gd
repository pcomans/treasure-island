extends RefCounted
## Unaccepted whole-building revision. Frozen source identity survives; old visual/physics proxies do not.
const MODEL := preload("res://game/scripts/world/facades/northpoint_1241_quality_model.gd")
const SUPPORT := preload("res://game/scripts/world/facades/housing_quality_support.gd")
const CONFIG_PATH := "res://game/resources/facades/northpoint_1241_quality_revision.json"
const SELF_PATH := "res://game/scripts/world/facades/northpoint_1241_live_factory.gd"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_-3.json"
const WALL_KEY := "building:w96215674:wall"
const ROOF_KEY := "building:w96215674:roof"
const EXPECTED_CHUNK_SHA256 := "d82a0767672898b348115d9df812a1a33bee96bca0d5d58713c52087591011bc"

static func _json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}

static func _record(records: Array, key: String) -> Dictionary:
	for row: Dictionary in records:
		if str(row.get("object_key", "")) == key: return row
	return {}

static func matches_record_pair(wall: Dictionary, roof: Dictionary) -> bool:
	if FileAccess.get_sha256(CHUNK_PATH) != EXPECTED_CHUNK_SHA256: return false
	var records: Array = _json(CHUNK_PATH).get("records", [])
	return not wall.is_empty() and not roof.is_empty() and wall == _record(records, WALL_KEY) and roof == _record(records, ROOF_KEY)

static func build_for_records(wall: Dictionary, roof: Dictionary, source_builder: Callable, tangent_builder: Callable, baseline: bool = false) -> Dictionary:
	if baseline or not source_builder.is_valid() or not tangent_builder.is_valid() or not matches_record_pair(wall, roof):
		return {"ok": false, "message": "Exact source pair and live caller required; no baseline fallback."}
	var cfg := _json(CONFIG_PATH)
	var land := SUPPORT.land_triangles(cfg.get("ground_chunks", {}))
	if not bool(land.get("ok", false)): return land
	var misses: Array = []
	var ground := func(p: Vector2) -> float:
		var value := SUPPORT.height_at(p, land.triangles)
		if not is_finite(value):
			misses.append(p)
			return 0.0
		return value
	var model: Node3D = MODEL.build(wall, ground)
	if not misses.is_empty():
		model.free()
		return {"ok": false, "message": "Reviewed local ground sample outside frozen colliding land."}
	return SUPPORT.attach(model, wall, roof, cfg)
