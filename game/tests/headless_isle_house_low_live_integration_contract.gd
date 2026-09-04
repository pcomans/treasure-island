extends SceneTree

const LIVE := preload("res://game/scripts/world/facades/isle_house_composite_repair_variant_c_live_attachment.gd")
const LIVE_PATH := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_live_attachment.gd"
const FACTORY_PATH := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_repair_only_factory.gd"
const REVIEWED_FACTORY_PATH := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_standalone_v1.gd"
const REVIEW_PATH := "res://evidence/first-playable/isle-house-composite-repair-variant-c-standalone-v1-2026-09-04/INDEPENDENT_BAR_RAISER_REVIEW.md"
const REJECTED_PATH := "res://game/scripts/world/facades/isle_house_39_bruton_low_live_attachment.gd"
const BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const MANIFEST_PATH := "res://generated/world/manifest.json"
const LOW_WALL_KEY := "building-composite:w1249412094:w1282547787:wall"
const HIGH_WALL_KEY := "building-composite:w1249412094:w1282547786:wall"
const LOW_ROOF_KEY := "building-composite:w1249412094:w1282547787:roof"
const CHUNK_SHA := "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce"
const MANIFEST_SHA := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const REVIEW_SHA := "b9877edb51eb9cc09bfd08f33d2664d7d3de08736daa2b96dc6e36c60d0fb5e5"
const REPAIR_SIGNATURE := "41868b77a8b51b56ee7381e5549423e97547270d2dc77d9ce5cf958b31e2cb69"
const LIVE_SIGNATURE := "09eee1517f043c6d82f0de0d2275da5b2a3f76f5842d1b9c90cba11e6e793981"
const REJECTED_SIGNATURE := "5d61ab90e5b798ac4aa26c45fea37a5293f3083dada615f06999faad459112cc"
const SOURCE_HASHES := {
	LIVE_PATH: "e2767b01fab68d7f16ffe2e7f8e0313c711347e2006a72e028c19aaa2195b891",
	FACTORY_PATH: "4336e821e240b973f8d97e5cb46e17332b19dea03869abb1fa81b96a7e380582",
	REVIEWED_FACTORY_PATH: "b24fd72cd12aa0c6c45a123f005fc834ea657c343e8332a872eae07fa017ace7",
	REJECTED_PATH: "1b36a0ad92ded4607e0c1e0df5d5581d1c7afff5843cb75cd4c490790a86c413",
	BUILDER_PATH: "28be094c674108f42be040f2b3ae6d242838d15e2060f6cf4668b0a003f1a682",
	CHUNK_PATH: CHUNK_SHA,
	MANIFEST_PATH: MANIFEST_SHA,
	"res://game/scripts/world/facades/isle_house_39_bruton_high_facade.gd": "f8243cedd3f331cbc37e6343b1b48e76a73a81644c96cc1f80e623e0c71a3113",
	"res://game/scenes/world/facades/isle_house/isle_house_high_facade.tscn": "7ff4a91c402cecea19d2686d29139d2c0f139673b06d21c67d1c14835fd31d12",
	"res://game/resources/facades/isle_house_39_bruton_high_se_layout.json": "c5e6393e90152cef62f6478d7bd87750f3db5598d6ebc36cd307ce20acaa090d",
}
const OVERLAY_TOPOLOGY := {"mesh_instances": 7, "surfaces": 11, "triangles": 2242}
const WORLD_TOPOLOGY := {"rows": 735, "meshes": 940, "surfaces": 954, "triangles": 64118, "bodies": 466, "shapes": 466}
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_require(_hashes_match(SOURCE_HASHES), "A pinned live/factory/builder/high/chunk asset drifted.")
	_require(FileAccess.get_sha256(REVIEW_PATH) == REVIEW_SHA, "Independent Variant C PASS review drifted.")
	_require(_builder_seam_matches(), "World builder lost its one-path replace-not-stack seam.")
	_require(_runtime_boundary_is_clean(), "Variant C executable seam contains a source/evidence path or URL.")
	if _failed:
		_finish()
		return
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	var low_wall := _record_for_key(chunk.records as Array, LOW_WALL_KEY)
	var high_wall := _record_for_key(chunk.records as Array, HIGH_WALL_KEY)
	var low_roof := _record_for_key(chunk.records as Array, LOW_ROOF_KEY)
	_require(not low_wall.is_empty() and not high_wall.is_empty() and not low_roof.is_empty(), "Exact Isle House receiver controls are missing.")
	_require(_target_fails_closed(low_wall, high_wall, low_roof), "Variant C live receiver matching did not fail closed.")
	if _failed:
		_finish()
		return

	var first := LIVE.build(low_wall)
	var second := LIVE.build(low_wall)
	_require(bool(first.get("ok", false)), "First Variant C live build failed: %s" % first)
	_require(bool(second.get("ok", false)), "Second Variant C live build failed: %s" % second)
	if not bool(first.get("ok", false)) or not bool(second.get("ok", false)):
		_free_result(first)
		_free_result(second)
		_finish()
		return
	var first_node := first.node as Node3D
	var second_node := second.node as Node3D
	root.add_child(first_node)
	await process_frame
	_require(_live_node_matches(first_node, first.metadata as Dictionary), "First Variant C live output violated its contract.")
	root.remove_child(first_node)
	root.add_child(second_node)
	await process_frame
	_require(_live_node_matches(second_node, second.metadata as Dictionary), "Second Variant C live output violated its contract.")
	root.remove_child(second_node)
	_require((first.metadata as Dictionary).get("live_signature", "") == LIVE_SIGNATURE, "Variant C live signature drifted.")
	_require((first.metadata as Dictionary).get("live_signature", "") == (second.metadata as Dictionary).get("live_signature", ""), "Two clean Variant C live builds were nondeterministic.")
	_free_result(first)
	_free_result(second)

	var builder := WorldChunkBuilder.new()
	var low_result := builder._build_record(low_wall, false)
	var high_result := builder._build_record(high_wall, false)
	var roof_result := builder._build_record(low_roof, false)
	var context_result := builder._build_record(low_wall, true)
	var controls := [low_result, high_result, roof_result, context_result]
	for value: Variant in controls:
		_require(bool((value as Dictionary).get("ok", false)), "Live/control record failed construction: %s" % (value as Dictionary))
	if _failed:
		_free_results(controls)
		_finish()
		return
	var low := low_result.node as Node3D
	var high := high_result.node as Node3D
	var roof := roof_result.node as Node3D
	var context := context_result.node as Node3D
	var live := low.get_node_or_null("IsleHouseCompositeRepairVariantCLiveAttachment") as Node3D
	_require(live != null and _count_named(low, "IsleHouseCompositeRepairVariantCLiveAttachment") == 1, "Exact low receiver did not receive exactly one Variant C overlay.")
	_require(_count_named(low, "IsleHouse39BrutonLowLiveAttachment") == 0 and _count_named(low, "FailedLiveParentLowOverlay") == 0, "Rejected overlay was stacked or used as fallback.")
	_require(_count_named(high, "IsleHouseCompositeRepairVariantCLiveAttachment") == 0 and _count_named(roof, "IsleHouseCompositeRepairVariantCLiveAttachment") == 0 and _count_named(context, "IsleHouseCompositeRepairVariantCLiveAttachment") == 0, "Variant C overlay spilled to high, roof, or context.")
	_require(int(low_result.mesh_instances) == 8 and int(low_result.surfaces) == 12 and int(low_result.triangles) == 2268, "Low receiver is not its 1/1/26 base plus 7/11/2242 replacement.")
	_require(_sole_owner(low), "Underlying exact low wall is not the sole collision/spray owner.")
	_require(live != null and _live_node_matches(live, low.get_meta("isle_house_low_live_attachment", {}) as Dictionary), "Builder-attached Variant C live node drifted.")
	_require(high.get_node_or_null("IsleHouse39BrutonHighFacade") != null, "Accepted Isle House high facade disappeared.")
	_free_results(controls)
	if _failed:
		_finish()
		return

	var world_result := await _full_world_matches()
	_require(bool(world_result.get("ok", false)), str(world_result.get("message", "Whole-world Variant C live check failed.")))
	print("ISLE_VARIANT_C_LIVE_SIGNATURE: %s" % LIVE_SIGNATURE)
	print("ISLE_VARIANT_C_LIVE_TOPOLOGY: receiver=8/12/2268 overlay=7/11/2242 world=735/940/954/64118/466")
	if not _failed:
		print("PASS: exact w1282547787 receives one independently accepted Variant C render-only replacement, never the rejected overlay; accepted high and sole underlying collision/spray ownership remain unchanged")
	_finish()


func _target_fails_closed(low: Dictionary, high: Dictionary, roof: Dictionary) -> bool:
	if not LIVE.matches_record(low) or LIVE.matches_record(high) or LIVE.matches_record(roof):
		return false
	for mutation: Dictionary in [
		{"object_key": HIGH_WALL_KEY}, {"source_keys": ["w1282547786"]},
		{"feature_kind": "building_wall"}, {"material_key": "building_wall"},
		{"receiver_kind": "building_roof"}, {"collision_kind": "none"},
		{"opaque": false}, {"top_elevation_m": 19.104},
	]:
		var changed := low.duplicate(true)
		for key: String in mutation:
			changed[key] = mutation[key]
		if LIVE.matches_record(changed):
			return false
	var drift := low.duplicate(true)
	drift.vertices[0] = float(drift.vertices[0]) + 0.01
	var result := LIVE.build(drift)
	return not bool(result.get("ok", true)) and str(result.get("code", "")) == "isle_house_variant_c_live_build"


func _live_node_matches(node: Node3D, metadata: Dictionary) -> bool:
	if str(node.name) != "IsleHouseCompositeRepairVariantCLiveAttachment" \
	or not bool(node.get_meta("runtime_attachment", false)) or not bool(node.get_meta("live_replacement", false)) or bool(node.get_meta("standalone_only", true)) \
	or str(node.get_meta("integration_mode", "")) != "approved_variant_c_live_replacement" \
	or str(node.get_meta("standalone_independent_grade", "")) != "PASS" \
	or str(node.get_meta("approval_review_sha256", "")) != REVIEW_SHA \
	or str(node.get_meta("repair_signature", "")) != REPAIR_SIGNATURE \
	or str(node.get_meta("live_deterministic_signature", "")) != LIVE_SIGNATURE \
	or str(node.get_meta("replaces_rejected_live_signature", "")) != REJECTED_SIGNATURE \
	or bool(node.get_meta("rejected_overlay_fallback_used", true)) or bool(node.get_meta("overlay_stacked", true)) \
	or bool(node.get_meta("part_recognition_accepted", true)) or bool(node.get_meta("whole_composite_recognition_accepted", true)) \
	or bool(node.get_meta("believability_accepted", true)) or bool(node.get_meta("as_built_fidelity", true)) \
	or "pending_independent" not in str(node.get_meta("recognition_review_status", "")) \
	or str(node.get_meta("spray_ray_owner", "")) != "unchanged_underlying_receiver" \
	or not node.is_in_group("isle_house_variant_c_live_render_only") or node.is_in_group("isle_house_composite_variant_c_standalone_only"):
		return false
	if int(metadata.get("mesh_instances", 0)) != 7 or int(metadata.get("surfaces", 0)) != 11 or int(metadata.get("triangles", 0)) != 2242 \
	or int(metadata.get("collision_nodes", -1)) != 0 or int(metadata.get("navigation_nodes", -1)) != 0 or int(metadata.get("spray_nodes", -1)) != 0 \
	or bool(metadata.get("rejected_overlay_fallback_used", true)) or bool(metadata.get("overlay_stacked", true)):
		return false
	if _count_type(node, CollisionObject3D) != 0 or _count_type(node, CollisionShape3D) != 0 or _count_type(node, NavigationRegion3D) != 0 \
	or _any_group(node, "spray_receiver_wall") or _any_group(node, "spray_receiver") \
	or _count_named(node, "IsleHouse39BrutonLowLiveAttachment") != 0 or _count_named(node, "FailedLiveParentLowOverlay") != 0:
		return false
	var fields := node.get_node_or_null("VariantC_PublicFieldsAndQuietNNW") as MeshInstance3D
	if fields == null or fields.mesh == null or fields.mesh.get_surface_count() != 5 \
	or fields.get_meta("quiet_nnw_run_indices", []) != [10, 11, 12] or int(fields.get_meta("quiet_nnw_opening_count", -1)) != 0:
		return false
	var totals := fields.get_meta("public_side_chain_totals_m", {}) as Dictionary
	return is_equal_approx(float(totals.get("LOW-WSW-AVENUE-OF-THE-PALMS", 0.0)), 51.6984152793884) \
		and is_equal_approx(float(totals.get("LOW-ENE-GARDEN-WALK", 0.0)), 49.7970167398453) \
		and _topology(node) == OVERLAY_TOPOLOGY


func _sole_owner(low: Node3D) -> bool:
	var mesh := low.get_node_or_null("Mesh") as MeshInstance3D
	var body := low.get_node_or_null("Collision") as StaticBody3D
	var shape_node := low.get_node_or_null("Collision/Shape") as CollisionShape3D
	if mesh == null or mesh.mesh == null or body == null or shape_node == null or not (shape_node.shape is ConcavePolygonShape3D):
		return false
	var shape := shape_node.shape as ConcavePolygonShape3D
	return mesh.mesh.get_faces().size() / 3 == 26 and shape.get_faces().size() / 3 == 26 \
		and body.collision_layer == (PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE) \
		and body.is_in_group("spray_receiver_wall") and body.get_meta("source_keys", []) == ["w1282547787"] \
		and str(body.get_meta("derived_object_key", "")) == LOW_WALL_KEY \
		and _count_type(low, CollisionObject3D) == 1 and _count_type(low, CollisionShape3D) == 1


func _full_world_matches() -> Dictionary:
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
	var started := Time.get_ticks_msec()
	while reports.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 30000:
		await process_frame
	var lows := _nodes_for_key(world, LOW_WALL_KEY)
	var highs := _nodes_for_key(world, HIGH_WALL_KEY)
	var e := world.get_runtime_evidence()
	var actual := {"rows": e.playable_rows, "meshes": e.mesh_instances, "surfaces": e.surfaces, "triangles": e.triangles, "bodies": e.static_bodies, "shapes": e.shapes}
	var ok := failures.is_empty() and reports.size() == 1 and lows.size() == 1 and highs.size() == 1 and actual == WORLD_TOPOLOGY
	if ok:
		ok = _count_named(lows[0], "IsleHouseCompositeRepairVariantCLiveAttachment") == 1 \
			and _count_named(lows[0], "IsleHouse39BrutonLowLiveAttachment") == 0 \
			and (highs[0] as Node).get_node_or_null("IsleHouse39BrutonHighFacade") != null \
			and _sole_owner(lows[0] as Node3D)
	var message := "World drift: failures=%s reports=%d low=%d high=%d topology=%s." % [failures, reports.size(), lows.size(), highs.size(), actual]
	root.remove_child(world)
	world.free()
	return {"ok": ok, "message": message}


func _builder_seam_matches() -> bool:
	var source := FileAccess.get_file_as_string(BUILDER_PATH)
	return source.count("isle_house_composite_repair_variant_c_live_attachment.gd") == 1 \
		and "ISLE_HOUSE_LOW_LIVE_ATTACHMENT.matches_record(record)" in source \
		and "ISLE_HOUSE_LOW_LIVE_ATTACHMENT.build(record)" in source \
		and "isle_house_39_bruton_low_live_attachment.gd" not in source


func _runtime_boundary_is_clean() -> bool:
	for path: String in [LIVE_PATH, FACTORY_PATH, REVIEWED_FACTORY_PATH, "res://game/resources/facades/isle_house_composite_repair_variant_c_standalone_v1.json"]:
		var source := FileAccess.get_file_as_string(path).to_lower()
		for token: String in _forbidden_tokens():
			if token in source:
				return false
	return true


func _forbidden_tokens() -> Array[String]:
	return ["res://" + "discovery/", "res://" + "evidence/", "http" + "://", "https" + "://", "file" + "://", "/" + "volumes/", "/" + "users/"]


func _topology(node: Node) -> Dictionary:
	var meshes := 0
	var surfaces := 0
	var triangles := 0
	for item: Node in _all(node):
		if item is MeshInstance3D:
			var mesh := (item as MeshInstance3D).mesh
			if mesh != null:
				meshes += 1
				surfaces += mesh.get_surface_count()
				triangles += mesh.get_faces().size() / 3
		elif item is MultiMeshInstance3D:
			var mm := (item as MultiMeshInstance3D).multimesh
			if mm != null and mm.mesh != null:
				meshes += 1
				surfaces += mm.mesh.get_surface_count()
				triangles += int(mm.mesh.get_faces().size() / 3) * mm.instance_count
	return {"mesh_instances": meshes, "surfaces": surfaces, "triangles": triangles}


func _nodes_for_key(root_node: Node, key: String) -> Array[Node]:
	var result: Array[Node] = []
	for node: Node in root_node.find_children("*", "Node3D", true, false):
		if str(node.get_meta("derived_object_key", "")) == key and node.get_parent() != null and str(node.get_parent().name).contains("__"):
			result.append(node)
	return result


func _record_for_key(records: Array, key: String) -> Dictionary:
	for value: Variant in records:
		if str((value as Dictionary).get("object_key", "")) == key:
			return value as Dictionary
	return {}


func _all(node: Node) -> Array[Node]:
	var result: Array[Node] = [node]
	for child: Node in node.get_children():
		result.append_array(_all(child))
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


func _hashes_match(expected: Dictionary) -> bool:
	for path_value: Variant in expected:
		var path := str(path_value)
		if FileAccess.get_sha256(path) != str(expected[path]):
			push_error("Hash drift: %s expected=%s actual=%s" % [path, expected[path], FileAccess.get_sha256(path)])
			return false
	return true


func _free_result(result: Dictionary) -> void:
	var node := result.get("node", null) as Node
	if node != null:
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()


func _free_results(results: Array) -> void:
	for value: Variant in results:
		_free_result(value as Dictionary)


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ISLE_VARIANT_C_LIVE_FAIL: %s" % message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
