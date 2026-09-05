extends SceneTree

const ROOT := "res://evidence/first-playable/navy-chapel-187-live-replacement-2026-09-04"
const STILL_MANIFEST := ROOT + "/capture-manifest.json"
const MOTION_MANIFEST := ROOT + "/motion-capture.json"
const LANDING_RECEIPT := ROOT + "/roof-landing.json"
const MOVIE := ROOT + "/navy-chapel-187-actual-live-public-stock-walk.avi"
const README := ROOT + "/README.md"
const LEDGER := ROOT + "/CHECKSUMS.sha256"
const HARNESS := "res://game/tests/navy_chapel_187_live_replacement_capture.gd"
const ADAPTER := "res://game/scripts/world/facades/navy_chapel_187_live_replacement.gd"
const BUILDER := "res://game/scripts/world/world_chunk_builder.gd"
const REGISTRY := "res://game/resources/facades/facade-runtime-registry.json"
const FACTORY := "res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd"
const CONFIG := "res://game/resources/facades/navy_chapel_187_standalone_hero_prototype.json"
const FOCUSED_CONTRACT := "res://game/tests/headless_navy_chapel_187_live_replacement_contract.gd"
const PACKAGE_CONTRACT := "res://game/tests/headless_navy_chapel_187_live_replacement_package_contract.gd"
const STANDALONE_CONTRACT := "res://game/tests/headless_navy_chapel_187_standalone_hero_contract.gd"
const LIVE_REVIEW := ROOT + "/INDEPENDENT_LIVE_BAR_RAISER_REVIEW.md"
const REVIEW := "res://evidence/first-playable/navy-chapel-187-standalone-hero-2026-09-04/INDEPENDENT_BAR_RAISER_REVIEW.md"
const PACKET := "res://discovery/facades/p3_reference_packets/w291189336_navy_chapel_building_187.md"
const CHUNK := "res://generated/world/chunks/x_-1__z_2.json"
const WALL_KEY := "building:w291189336:wall"
const ROOF_KEY := "building:w291189336:roof"
const SOURCE_KEY := "w291189336"
const GEOMETRY_SIGNATURE := "076e081df86e884f04cf7cb680304c35c64e6f76238de7060528c59097ae5c46"
const OWNERSHIP_SIGNATURE := "4766c5d562933eb632f1ef3bdcec828fc40be81c996db919c53405f776fa04a7"
const REVIEW_SHA := "4232ad42b3600b1d7f945c5d51325bb9698c366e07eb1ddea3fd90f3f49235c6"
const LEDGER_SHA := "256fa689d8042644759d4a90ec68f657475687bf0561428422f2cb185b4724f9"
const CAPTURE_EVIDENCE_CONTRACT_SHA := "1cf02d4f4a9b03522d696eb52c560b7a67753e3ba2708fa578a1952278d7eb1d"
const CAPTURE_ONLY_PATHS := [BUILDER, FOCUSED_CONTRACT, PACKAGE_CONTRACT, STANDALONE_CONTRACT]
const CURRENT_HASHES := {
	BUILDER: "71e391e4fa58afc83e4bcb99a9f8195e398fdf4064bb09a401fb079e9f30491c",
	REGISTRY: "9c46c1a8c809aa9ded82008d35e9c1b257070e9c61f6d6e41f5650ca7b1c3f27",
	FOCUSED_CONTRACT: "f758d77ee84eea80b7523da686787f504843b57ce263c55e1d5d760e16e49e68",
	PACKAGE_CONTRACT: "c11fd425473bd2f9d9b46c8b228e9c6b22d3dfcddff9c1d21af66fb3df734d45",
	STANDALONE_CONTRACT: "6ff2115ca0c80c07487d811d7d9982790c03ccfe0ef582a76e634603cfb2d0e5",
}
const WALL_SHA := "69769fef402b480f1626fdce47e6d4ad49ecb710dab2b2e7373e5efa5acf0080"
const ROOF_SHA := "54bcd378997d0778bdaee432dc24ecdbb142c5dc5371166cf2d690ebb245b832"
const WORLD := {"rows": 735, "meshes": 944, "surfaces": 957, "triangles": 64572, "bodies": 466, "shapes": 466}
const PUBLIC_TANGENT := Vector3(0.88402567, 0.0, -0.46743835)
const EXPECTED_HASHES := {
	STILL_MANIFEST: "54d434c9283a0e2d86aa836e6a21672a8756e5a170cb5724d66066e799223930",
	MOTION_MANIFEST: "bdd385dcbd3d93bac38e159eb6251ab6f43b2b857a813df2ada6b50f2b97cde4",
	LANDING_RECEIPT: "75ff3d5eaf9c81a10188c21f68e9ff0072ad937f9550fe8fa7fa01816636ef79",
	MOVIE: "742f55233fa72775dbf9d9be73cd7e555253d41372ebf680d8c27a45e573432b",
	README: "9a9289a0cc8aa04f8ad3311bb62c9399422585752c143be7c7ab1e17f7cf2650",
	HARNESS: "cfdd474531bb47b072b1e0f8b09e84257c181501b9bc9385389b0ebffbcb926b",
	ADAPTER: "deffb5956d8e808565d1c557208647a89dff4730c15f97aa9b1085a087968cad",
	BUILDER: "d3d3dc1ba3aace541dc07ce437d242787ce2e4efe66877368ac2907e3facf17c",
	FACTORY: "067c12e29c9fd352915ef2a501fcd7687b450081c79a4281d63bbfef1c19e7db",
	CONFIG: "c8f2ab09f3943a5ec8abea7cb9a108f49990bff1d83003c3b3622187a269dea2",
	FOCUSED_CONTRACT: "61174d461360b2499b09a0f2d343e518e049577946d96bacaa14c45df9f4c670",
	PACKAGE_CONTRACT: "10520475c43d6f0e07ba6e80ba76f35dd3dc59fd3712bba1a00b83bbadabe93d",
	STANDALONE_CONTRACT: "a5d43e7005263c655dd3521ce79ecd864eaa2c8290053299ef22d9b6523be5e8",
	LIVE_REVIEW: "63bd6c5a79db837e3b53b60eea36887cee8c4c66af791715f964f023b926b5a9",
	REVIEW: REVIEW_SHA,
	PACKET: "7eb592503ce8e276c38ef3ecaf7f2d3dd17e1eeb32adbe45d1059c5cb4693330",
	CHUNK: "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce",
	ROOT + "/images/01-whole-public-default.png": "b464cc9ba0d237900012f64f3598a11fb49893432f61a7b6a30cec362eba27ad",
	ROOT + "/images/02-whole-public-changed-light.png": "0d552b96bcb74642b88cccb2a59cff2e93f4bc6758efc697ae785cd01b1aeeb3",
	ROOT + "/images/03-public-oblique-default.png": "8b63620d127741eb5e577ccbb7e33af85ef6097661e13389b51ff1fed0525f18",
	ROOT + "/images/04-stock-player-roof-landing.png": "fe3f5f7b2db6db0ce15f400f1cf256cf627efdacb8d8d02b392e20c941c83f4e",
}
const IMAGE_BYTES := {
	"01-whole-public-default": 602604,
	"02-whole-public-changed-light": 586958,
	"03-public-oblique-default": 583689,
	"04-stock-player-roof-landing": 676798,
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for path: String in EXPECTED_HASHES:
		if path not in CAPTURE_ONLY_PATHS:
			_require(FileAccess.get_sha256(path) == str(EXPECTED_HASHES[path]), "Evidence/immutable source hash drifted: %s." % path)
	var stills := _json(STILL_MANIFEST)
	var motion := _json(MOTION_MANIFEST)
	var landing := _json(LANDING_RECEIPT)
	_require(_current_runtime_bridge_matches(), "Current Navy Chapel builder, tests, registry authority, or acceptance bridge drifted.")
	_require(_bindings_match(stills.get("bindings", {}) as Dictionary), "Actual-live binding contract failed.")
	_require(_stills_match(stills, landing), "Actual-live still or landing evidence contract failed.")
	_require(_motion_matches(motion), "Actual-live continuous-motion evidence contract failed.")
	_require(_ledger_matches(), "Evidence checksum ledger is incomplete, duplicated, unsorted, or stale.")
	if not _failed:
		print("PASS: three grounded actual-live Chapel public frames, one real roof landing, and one 300-sample stock-player motion interval remain exact at capture topology 735/944/957/64572/466/466; the sealed ledger retains capture dependencies while a separate current bridge binds builder, focused/package/standalone tests, and accepted v7 physical-unit authority")
	quit(1 if _failed else 0)


func _stills_match(manifest: Dictionary, landing: Dictionary) -> bool:
	if str(manifest.get("schema_version", "")) != "ti.navy-chapel-187-actual-live-evidence/1" \
	or str(manifest.get("review_status", "")) != "pending_independent_exact_current_live_review_not_self_accepted" \
	or str(manifest.get("recognition_status", "")) != "pending_independent_review" \
	or str(manifest.get("believability_status", "")) != "pending_independent_review" \
	or str(manifest.get("visual_verdict", "")) != "pending_independent_review" \
	or str(manifest.get("generator_sha256", "")) != str(EXPECTED_HASHES[HARNESS]) \
	or str(manifest.get("live_adapter_sha256", "")) != str(EXPECTED_HASHES[ADAPTER]) \
	or str(manifest.get("world_builder_sha256", "")) != str(EXPECTED_HASHES[BUILDER]) \
	or not _world_matches(manifest.get("runtime_topology", {}) as Dictionary) \
	or not bool(manifest.get("actual_live_node_resolved", false)) \
	or int(manifest.get("preview_attachment_count", -1)) != 0 \
	or bool(manifest.get("source_photography_shipped", true)) or bool(manifest.get("source_urls_in_runtime", true)):
		return false
	var captures := manifest.get("captures", []) as Array
	if captures.size() != 4 or int(manifest.get("capture_count", 0)) != 4:
		return false
	var by_id: Dictionary = {}
	for value: Variant in captures:
		var capture := value as Dictionary
		var id := str(capture.get("id", ""))
		if not IMAGE_BYTES.has(id) or by_id.has(id):
			return false
		by_id[id] = capture
		var path := ROOT.path_join(str(capture.get("file", "")))
		var image := Image.load_from_file(ProjectSettings.globalize_path(path))
		if image == null or image.is_empty() or image.get_size() != Vector2i(1440, 900) \
		or str(capture.get("sha256", "")) != FileAccess.get_sha256(path) \
		or int(capture.get("bytes", 0)) != int(IMAGE_BYTES[id]) \
		or bool(capture.get("debug_labels_visible", true)) or bool(capture.get("source_photography_in_frame", true)) \
		or bool(capture.get("crop_or_postprocess", true)) or not bool(capture.get("actual_live_node", false)) \
		or int(capture.get("preview_attachment_count", -1)) != 0 \
		or str(capture.get("visual_verdict", "")) != "pending_independent_review":
			return false
	for id: String in ["01-whole-public-default", "02-whole-public-changed-light", "03-public-oblique-default"]:
		var capture := by_id[id] as Dictionary
		if not bool(capture.get("physics_grounded", false)) or not bool(capture.get("ordinary_player_rig", false)) \
		or not bool(capture.get("input_reachable_camera_orientation", false)) \
		or not bool(capture.get("target_bounds_fully_in_frame", false)) \
		or str(capture.get("first_los_hit_receiver", "")) != WALL_KEY \
		or capture.get("first_los_hit_source_keys", []) != [SOURCE_KEY] \
		or int(capture.get("first_los_hit_run_index", -1)) != 9:
			return false
	var baseline := by_id.get("01-whole-public-default", {}) as Dictionary
	var changed := by_id.get("02-whole-public-changed-light", {}) as Dictionary
	if str(baseline.get("lighting", "")) != "world_default" \
	or str(changed.get("lighting", "")) != "frozen_changed_light" \
	or str(changed.get("same_pose_as", "")) != "01-whole-public-default" \
	or not bool(changed.get("player_transform_exactly_reused", false)) \
	or not bool(changed.get("camera_transform_exactly_reused", false)) \
	or changed.get("player_position_m", []) != baseline.get("player_position_m", []) \
	or changed.get("camera_position_m", []) != baseline.get("camera_position_m", []) \
	or changed.get("camera_forward", []) != baseline.get("camera_forward", []):
		return false
	var landing_capture := by_id.get("04-stock-player-roof-landing", {}) as Dictionary
	return str(landing_capture.get("role", "")) == "actual_live_stock_player_physics_landing_on_non_spray_roof" \
		and landing.get("capture", {}) == landing_capture \
		and bool(landing.get("physics_grounded", false)) and bool(landing.get("saw_airborne_before_landing", false)) \
		and str(landing.get("roof_object_key", "")) == ROOF_KEY and str(landing.get("roof_receiver", "invalid")) == "none" \
		and not bool(landing.get("roof_in_wall_spray_group", true)) \
		and bool(landing.get("post_landing_collider_is_same_roof_body", false)) \
		and float(landing.get("landing_clearance_m", 1.0)) >= -0.005 and float(landing.get("landing_clearance_m", 1.0)) <= 0.08 \
		and float((landing.get("roof_hit_normal", [0.0, 0.0, 0.0]) as Array)[1]) > 0.4 \
		and float((landing.get("cap_hit_position_m", [0.0, 0.0, 0.0]) as Array)[1]) > 21.0 \
		and float((landing.get("cap_hit_normal", [0.0, 0.0, 0.0]) as Array)[1]) > 0.25 \
		and int(landing.get("recovery_delta", -1)) == 0 \
		and int(landing.get("player_transform_writes_after_descent_began", -1)) == 0


func _motion_matches(motion: Dictionary) -> bool:
	if str(motion.get("schema_version", "")) != "ti.navy-chapel-187-actual-live-motion-evidence/1" \
	or str(motion.get("review_status", "")) != "pending_independent_exact_current_live_review_not_self_accepted" \
	or str(motion.get("visual_verdict", "")) != "pending_independent_review" \
	or str(motion.get("generator_sha256", "")) != str(EXPECTED_HASHES[HARNESS]) \
	or str(motion.get("movie_sha256", "")) != str(EXPECTED_HASHES[MOVIE]) \
	or int(motion.get("movie_bytes", 0)) != 21580734 \
	or not bool(motion.get("movie_finalized_after_writer_close", false)) \
	or motion.get("movie_dimensions", []) != [1280.0, 800.0] \
	or int(motion.get("fixed_fps", 0)) != 30 or int(motion.get("physics_ticks_per_second", 0)) != 60 \
	or int(motion.get("motion_physics_frames", 0)) != 300 \
	or not is_equal_approx(float(motion.get("continuous_duration_seconds", 0.0)), 5.0) \
	or absf(float(motion.get("horizontal_displacement_m", 0.0)) - 19.8790435791016) > 0.0001 \
	or float(motion.get("start_along_public_chain_m", 0.0)) >= -7.0 \
	or float(motion.get("end_along_public_chain_m", 0.0)) <= 10.0 \
	or float(motion.get("direction_dot_public_tangent", 0.0)) <= 0.995 \
	or int(motion.get("player_transform_writes_after_input_began", -1)) != 0 \
	or bool(motion.get("camera_orientation_changed_during_motion", true)) \
	or not bool(motion.get("all_samples_grounded", false)) or int(motion.get("recovery_delta", -1)) != 0 \
	or not _world_matches(motion.get("runtime_topology", {}) as Dictionary) \
	or not _bindings_match(motion.get("bindings", {}) as Dictionary):
		return false
	var ranges := motion.get("review_motion_physics_frame_range", []) as Array
	if ranges.size() != 2 or int(ranges[1]) - int(ranges[0]) != 300:
		return false
	var samples := motion.get("samples", []) as Array
	if samples.size() != 300:
		return false
	var start_position := _array_vector3((samples[0] as Dictionary).get("player_position_m", []) as Array)
	var previous_along := -INF
	for index in samples.size():
		var sample := samples[index] as Dictionary
		var position := _array_vector3(sample.get("player_position_m", []) as Array)
		var along := (position - start_position).dot(PUBLIC_TANGENT)
		if int(sample.get("frame", 0)) != index + 1 or not bool(sample.get("is_on_floor", false)) or along + 0.001 < previous_along:
			return false
		previous_along = along
	return true


func _bindings_match(bindings: Dictionary) -> bool:
	return str(bindings.get("wall_root_path", "")).ends_with("/NavyChapel187LiveWallVisualAndCollisionReplacement") \
		and str(bindings.get("roof_root_path", "")).ends_with("/NavyChapel187LiveRoofCollisionReplacement") \
		and bindings.get("wall_source_keys", []) == [SOURCE_KEY] and bindings.get("roof_source_keys", []) == [SOURCE_KEY] \
		and str(bindings.get("geometry_signature", "")) == GEOMETRY_SIGNATURE \
		and str(bindings.get("live_ownership_signature", "")) == OWNERSHIP_SIGNATURE \
		and str(bindings.get("canonical_wall_record_sha256", "")) == WALL_SHA \
		and str(bindings.get("canonical_roof_record_sha256", "")) == ROOF_SHA \
		and str(bindings.get("approval_receipt_sha256", "")) == REVIEW_SHA \
		and int(bindings.get("wall_collision_triangles", 0)) == 94 and int(bindings.get("roof_collision_triangles", 0)) == 50 \
		and int(bindings.get("structural_body_count", 0)) == 2 and int(bindings.get("structural_shape_count", 0)) == 2 \
		and int(bindings.get("spray_owner_count", 0)) == 1 and int(bindings.get("navigation_owner_count", -1)) == 0 \
		and int(bindings.get("generic_wall_or_roof_stack_count", -1)) == 0 and int(bindings.get("preview_attachment_count", -1)) == 0 \
		and not bool(bindings.get("recognition_accepted", true)) and not bool(bindings.get("believability_accepted", true))


func _world_matches(actual: Dictionary) -> bool:
	for key: String in WORLD:
		if int(actual.get(key, -1)) != int(WORLD[key]):
			return false
	return true


func _current_runtime_bridge_matches() -> bool:
	for path_value: Variant in CURRENT_HASHES:
		var path := str(path_value)
		if FileAccess.get_sha256(path) != str(CURRENT_HASHES[path_value]):
			return false
	var registry := _json(REGISTRY)
	var metric := registry.get("recognition_metric", {}) as Dictionary
	var compatibility := registry.get("compatibility_contract", {}) as Dictionary
	if str(registry.get("schema_version", "")) != "ti.facade-runtime-registry/7" \
	or str(compatibility.get("catalog_schema_version", "")) != "ti.facade-recognition-catalog/7" \
	or str(compatibility.get("compiler_version", "")) != "1.6.0" \
	or str(compatibility.get("loader_api_version", "")) != "ti.facade-runtime-registry-loader/6" \
	or int(metric.get("numerator", -1)) != 7 or int(metric.get("denominator", -1)) != 213 or str(metric.get("display", "")) != "7/213":
		return false
	var adapter := _adapter_for(registry.get("active_runtime_adapters", []) as Array, WALL_KEY)
	var unit := _unit_for(registry.get("units", []) as Array, "physical-building:w291189336")
	var claim := unit.get("claim_status", {}) as Dictionary
	var scope := adapter.get("active_receiver_scope", {}) as Dictionary
	var active_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	var behavior := active_contract.get("behavior_contract", {}) as Dictionary
	var geometry := behavior.get("geometry_contract", {}) as Dictionary
	return str(adapter.get("source_key", "")) == SOURCE_KEY \
		and str(adapter.get("review_status", "")) == "independent_exact_current_live_pass" \
		and str(adapter.get("review_status_scope", "")) == "runtime_asset_original_detail_provenance_only_not_reference_recognition" \
		and str(adapter.get("recognition_acceptance_authority", "")) == "physical_unit_claim_and_independent_acceptance_record" \
		and str(claim.get("reference_recognizable", "")) == "accepted" \
		and str(adapter.get("recognition_acceptance_status", "")) == str(claim.get("reference_recognizable", "")) \
		and str(scope.get("coverage", "")) == "whole_direct_wall_receiver" and int(scope.get("run_count", -1)) == 34 \
		and str(active_contract.get("adapter_sha256", "")) == str(EXPECTED_HASHES[ADAPTER]) \
		and str(active_contract.get("dispatch_sha256", "")) == str(CURRENT_HASHES[BUILDER]) \
		and str(geometry.get("world_topology_scope", "")) == "pre_b201_integration_live_parity" \
		and _has_acceptance_receipt(unit, "63bd6c5a79db837e3b53b60eea36887cee8c4c66af791715f964f023b926b5a9", str(EXPECTED_HASHES[STILL_MANIFEST]))


func _adapter_for(adapters: Array, receiver_key: String) -> Dictionary:
	for value: Variant in adapters:
		var adapter := value as Dictionary
		if str(adapter.get("receiver_key", "")) == receiver_key:
			return adapter
	return {}


func _unit_for(units: Array, unit_id: String) -> Dictionary:
	for value: Variant in units:
		var unit := value as Dictionary
		if str(unit.get("unit_id", "")) == unit_id:
			return unit
	return {}


func _has_acceptance_receipt(unit: Dictionary, receipt_sha256: String, manifest_sha256: String) -> bool:
	for value: Variant in unit.get("acceptance_records", []) as Array:
		var record := value as Dictionary
		if str(record.get("review_kind", "")) == "independent_reference_recognition" \
		and str(record.get("status", "")) == "accept" \
		and str(record.get("review_receipt_sha256", "")) == receipt_sha256 \
		and str(record.get("evidence_manifest_sha256", "")) == manifest_sha256:
			return true
	return false


func _ledger_matches() -> bool:
	if FileAccess.get_sha256(LEDGER) != LEDGER_SHA:
		return false
	var lines := FileAccess.get_file_as_string(LEDGER).strip_edges().split("\n", false)
	if lines.size() != EXPECTED_HASHES.size() + 1:
		return false
	var seen := {}
	var previous := ""
	for line: String in lines:
		if line.length() < 67 or line.substr(64, 2) != "  ":
			return false
		var hash_value := line.substr(0, 64)
		var relative := line.substr(66)
		var path := "res://" + relative
		var expected_hash := CAPTURE_EVIDENCE_CONTRACT_SHA if path == "res://game/tests/headless_navy_chapel_187_live_replacement_evidence_contract.gd" else str(EXPECTED_HASHES.get(path, ""))
		if seen.has(path) or (not previous.is_empty() and relative < previous) or expected_hash.is_empty() or hash_value != expected_hash:
			return false
		seen[path] = true
		previous = relative
	for path: String in EXPECTED_HASHES:
		if not seen.has(path):
			return false
	return seen.has("res://game/tests/headless_navy_chapel_187_live_replacement_evidence_contract.gd")


func _array_vector3(values: Array) -> Vector3:
	return Vector3(float(values[0]), float(values[1]), float(values[2])) if values.size() == 3 else Vector3(INF, INF, INF)


func _json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("NAVY_CHAPEL_187_LIVE_EVIDENCE_FAIL: %s" % message)
	return false
