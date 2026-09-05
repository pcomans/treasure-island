extends SceneTree

const LIVE := preload("res://game/scripts/world/facades/isle_house_composite_repair_variant_c_live_attachment.gd")
const LIVE_PATH := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_live_attachment.gd"
const FACTORY_PATH := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_repair_only_factory.gd"
const REVIEWED_FACTORY_PATH := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_standalone_v1.gd"
const CONFIG_PATH := "res://game/resources/facades/isle_house_composite_repair_variant_c_standalone_v1.json"
const BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const MANIFEST_PATH := "res://generated/world/manifest.json"
const REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const REVIEW_PATH := "res://evidence/first-playable/isle-house-composite-repair-variant-c-standalone-v1-2026-09-04/INDEPENDENT_BAR_RAISER_REVIEW.md"
const SOURCE_PACKET := "res://discovery/facades/p1_reference_packets/w1249412094_isle_house.md"
const FRESH_EVIDENCE := "res://evidence/first-playable/isle-house-composite-repair-variant-c-live-replacement-2026-09-04/capture-manifest.json"
const LOW_WALL_KEY := "building-composite:w1249412094:w1282547787:wall"
const HIGH_WALL_KEY := "building-composite:w1249412094:w1282547786:wall"
const REVIEW_SHA := "b9877edb51eb9cc09bfd08f33d2664d7d3de08736daa2b96dc6e36c60d0fb5e5"
const REPAIR_SIGNATURE := "41868b77a8b51b56ee7381e5549423e97547270d2dc77d9ce5cf958b31e2cb69"
const LIVE_SIGNATURE := "09eee1517f043c6d82f0de0d2275da5b2a3f76f5842d1b9c90cba11e6e793981"
const SOURCE_HASHES := {
	LIVE_PATH: "e2767b01fab68d7f16ffe2e7f8e0313c711347e2006a72e028c19aaa2195b891",
	FACTORY_PATH: "4336e821e240b973f8d97e5cb46e17332b19dea03869abb1fa81b96a7e380582",
	REVIEWED_FACTORY_PATH: "b24fd72cd12aa0c6c45a123f005fc834ea657c343e8332a872eae07fa017ace7",
	CONFIG_PATH: "bafdef392ee638e860ba15f140c10de61e266ae63005b12e0e310e52c176897a",
	BUILDER_PATH: "71e391e4fa58afc83e4bcb99a9f8195e398fdf4064bb09a401fb079e9f30491c",
	CHUNK_PATH: "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce",
	MANIFEST_PATH: "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
}
const REQUIRED_PACKAGE_RESOURCES := [
	LIVE_PATH, FACTORY_PATH, REVIEWED_FACTORY_PATH, CONFIG_PATH,
	"res://game/scripts/world/facades/isle_house_composite_repair_standalone_v1.gd",
	"res://game/scripts/world/facades/isle_house_39_bruton_high_facade.gd",
	"res://game/scenes/world/facades/isle_house/isle_house_high_facade.tscn",
	"res://game/resources/facades/isle_house_39_bruton_high_se_layout.json",
	"res://game/scripts/world/facades/facade_meter_uv_adapter.gd",
	"res://game/resources/materials/world/facade_shared_v1/muted_brown_red_brick_v1.tres",
	"res://game/resources/textures/world/facade_shared_v1/muted_brown_red_brick_albedo_v1.png",
	"res://game/resources/materials/world/isle_house/isle_house_podium_mid_warm_v1.tres",
	"res://game/resources/materials/world/isle_house/isle_house_return_quiet_v1.tres",
	CHUNK_PATH, MANIFEST_PATH,
	REGISTRY_PATH,
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var mounted := "--mounted" in OS.get_cmdline_user_args()
	for path: String in REQUIRED_PACKAGE_RESOURCES:
		_require(ResourceLoader.exists(path) or FileAccess.file_exists(path), "Package closure is missing %s." % path)
	if mounted:
		_require(not ResourceLoader.exists(REVIEW_PATH) and not FileAccess.file_exists(REVIEW_PATH), "Mounted PCK contains independent review evidence.")
		_require(not ResourceLoader.exists(SOURCE_PACKET) and not FileAccess.file_exists(SOURCE_PACKET), "Mounted PCK contains the discovery-only source packet.")
		_require(not ResourceLoader.exists(FRESH_EVIDENCE) and not FileAccess.file_exists(FRESH_EVIDENCE), "Mounted PCK contains fresh live evidence.")
	else:
		_run_source_checks()
	_require(_registry_topology_scope_matches(), "Variant C package authority does not label its preserved pre-B201 integration topology separately from current integration.")
	var chunk_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH))
	_require(chunk_value is Dictionary, "Packaged exact chunk did not parse.")
	if not (chunk_value is Dictionary):
		_finish(mounted)
		return
	var low := _record_for_key((chunk_value as Dictionary).get("records", []) as Array, LOW_WALL_KEY)
	var result := LIVE.build(low)
	_require(bool(result.get("ok", false)), "Packaged Variant C live adapter failed: %s" % result)
	if bool(result.get("ok", false)):
		var node := result.node as Node3D
		root.add_child(node)
		await process_frame
		var metadata := result.metadata as Dictionary
		_require(str(metadata.get("repair_signature", "")) == REPAIR_SIGNATURE and str(metadata.get("live_signature", "")) == LIVE_SIGNATURE, "Packaged live signature drifted.")
		_require(int(metadata.get("mesh_instances", 0)) == 7 and int(metadata.get("surfaces", 0)) == 11 and int(metadata.get("triangles", 0)) == 2242, "Packaged live topology drifted.")
		_require(str(node.name) == "IsleHouseCompositeRepairVariantCLiveAttachment" and bool(node.get_meta("runtime_attachment", false)) and bool(node.get_meta("live_replacement", false)) and not bool(node.get_meta("standalone_only", true)), "Packaged live truth boundary drifted.")
		_require(not bool(node.get_meta("rejected_overlay_fallback_used", true)) and not bool(node.get_meta("overlay_stacked", true)) and _count_named(node, "IsleHouse39BrutonLowLiveAttachment") == 0, "Packaged live adapter stacked/fell back to the rejected overlay.")
		_require(_count_type(node, CollisionObject3D) == 0 and _count_type(node, CollisionShape3D) == 0 and _count_type(node, NavigationRegion3D) == 0 and not _any_group(node, "spray_receiver") and not _any_group(node, "spray_receiver_wall"), "Packaged live overlay acquired collision/navigation/spray ownership.")
		root.remove_child(node)
		node.free()
	if mounted:
		_require(_mounted_builder_matches(low), "Mounted builder did not attach exactly one Variant C overlay to the exact low receiver.")
	else:
		var world_result := await _world_matches()
		_require(bool(world_result.get("ok", false)), str(world_result.get("message", "Source world check failed.")))
	_finish(mounted)


func _run_source_checks() -> void:
	for path: String in SOURCE_HASHES:
		_require(FileAccess.get_sha256(path) == str(SOURCE_HASHES[path]), "Source package asset drifted: %s." % path)
	_require(FileAccess.get_sha256(REVIEW_PATH) == REVIEW_SHA, "Independent Variant C PASS review drifted.")
	var closure := ""
	for path: String in [LIVE_PATH, FACTORY_PATH, REVIEWED_FACTORY_PATH, CONFIG_PATH]:
		closure += FileAccess.get_file_as_string(path).to_lower() + "\n"
	for token: String in _forbidden_tokens():
		_require(token not in closure, "Executable closure contains forbidden token %s." % token)
	var builder := FileAccess.get_file_as_string(BUILDER_PATH)
	_require(builder.count("isle_house_composite_repair_variant_c_live_attachment.gd") == 1 and "isle_house_39_bruton_low_live_attachment.gd" not in builder, "Builder does not exclusively select the Variant C live adapter.")
	var preset := FileAccess.get_file_as_string("res://export_presets.cfg")
	for token: String in ["discovery/*", "discovery/**/*", "evidence/*", "evidence/**/*"]:
		_require(token in preset, "Export preset lost private boundary %s." % token)


func _registry_topology_scope_matches() -> bool:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	if not (parsed is Dictionary):
		return false
	var adapters := ((parsed as Dictionary).get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == LOW_WALL_KEY)
	if adapters.size() != 1:
		return false
	var behavior := ((adapters[0] as Dictionary).get("active_runtime_contract", {}) as Dictionary).get("behavior_contract", {}) as Dictionary
	var geometry := behavior.get("geometry_contract", {}) as Dictionary
	return str(geometry.get("world_topology_scope", "")) == "pre_b201_integration_live_parity" \
		and int(geometry.get("world_records", -1)) == 735 and int(geometry.get("world_mesh_instances", -1)) == 944 \
		and int(geometry.get("world_surfaces", -1)) == 957 and int(geometry.get("world_triangles", -1)) == 64572 \
		and int(geometry.get("world_static_bodies", -1)) == 466 and int(geometry.get("world_shapes", -1)) == 466


func _mounted_builder_matches(low_record: Dictionary) -> bool:
	var builder := WorldChunkBuilder.new()
	var result := builder._build_record(low_record, false)
	if not bool(result.get("ok", false)):
		return false
	var receiver := result.node as Node3D
	var live_count := _count_named(receiver, "IsleHouseCompositeRepairVariantCLiveAttachment")
	var rejected_count := _count_named(receiver, "IsleHouse39BrutonLowLiveAttachment") + _count_named(receiver, "FailedLiveParentLowOverlay")
	var body := receiver.get_node_or_null("Collision") as StaticBody3D
	var ok := live_count == 1 and rejected_count == 0 \
		and int(result.mesh_instances) == 8 and int(result.surfaces) == 12 and int(result.triangles) == 2268 \
		and body != null and body.is_in_group("spray_receiver_wall") \
		and _count_type(receiver, CollisionObject3D) == 1 and _count_type(receiver, CollisionShape3D) == 1
	receiver.free()
	return ok


func _world_matches() -> Dictionary:
	var packed := load("res://game/scenes/world/world_root.tscn") as PackedScene
	if packed == null:
		return {"ok": false, "message": "WorldRoot did not load."}
	var world := packed.instantiate() as WorldLoader
	var reports: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()}))
	root.add_child(world)
	world.load_world(MANIFEST_PATH)
	var start := Time.get_ticks_msec()
	while reports.is_empty() and failures.is_empty() and Time.get_ticks_msec() - start < 30000:
		await process_frame
	var lows := _nodes_for_key(world, LOW_WALL_KEY)
	var highs := _nodes_for_key(world, HIGH_WALL_KEY)
	var e := world.get_runtime_evidence()
	var topology_ok := e.playable_rows == 735 and e.mesh_instances == 950 and e.surfaces == 964 and e.triangles == 66636 and e.static_bodies == 466 and e.shapes == 466
	var ok := failures.is_empty() and reports.size() == 1 and lows.size() == 1 and highs.size() == 1 and topology_ok
	if ok:
		ok = _count_named(lows[0], "IsleHouseCompositeRepairVariantCLiveAttachment") == 1 \
			and _count_named(lows[0], "IsleHouse39BrutonLowLiveAttachment") == 0 \
			and (highs[0] as Node).get_node_or_null("IsleHouse39BrutonHighFacade") != null
	var message := "Package world drift: failures=%s reports=%d low=%d high=%d topology=%d/%d/%d/%d/%d/%d." % [failures, reports.size(), lows.size(), highs.size(), e.playable_rows, e.mesh_instances, e.surfaces, e.triangles, e.static_bodies, e.shapes]
	root.remove_child(world)
	world.free()
	return {"ok": ok, "message": message}


func _forbidden_tokens() -> Array[String]:
	return ["res://" + "discovery/", "res://" + "evidence/", "http" + "://", "https" + "://", "file" + "://", "/" + "volumes/", "/" + "users/"]


func _record_for_key(records: Array, key: String) -> Dictionary:
	for value: Variant in records:
		if str((value as Dictionary).get("object_key", "")) == key:
			return value as Dictionary
	return {}


func _nodes_for_key(root_node: Node, key: String) -> Array[Node]:
	var result: Array[Node] = []
	for node: Node in root_node.find_children("*", "Node3D", true, false):
		if str(node.get_meta("derived_object_key", "")) == key and node.get_parent() != null and str(node.get_parent().name).contains("__"):
			result.append(node)
	return result


func _count_named(node: Node, wanted: String) -> int:
	var count := 1 if str(node.name) == wanted else 0
	for child: Node in node.get_children():
		count += _count_named(child, wanted)
	return count


func _count_type(node: Node, type: Variant) -> int:
	var count := 1 if is_instance_of(node, type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, type)
	return count


func _any_group(node: Node, group: StringName) -> bool:
	if node.is_in_group(group):
		return true
	for child: Node in node.get_children():
		if _any_group(child, group):
			return true
	return false


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ISLE_VARIANT_C_PACKAGE_FAIL: %s" % message)
	return false


func _finish(mounted: bool) -> void:
	if not _failed:
		if mounted:
			print("PASS: mounted Variant C live replacement package resolves exact 7/11/2242 output and 8/12/2268 receiver without discovery/evidence payloads, fallback stacking, or decorative ownership")
		else:
			print("PASS: source Variant C live replacement package resolves exact 7/11/2242 output and current 735/950/964/66636/466/466 world without discovery/evidence payloads, fallback stacking, or decorative ownership")
	quit(1 if _failed else 0)
