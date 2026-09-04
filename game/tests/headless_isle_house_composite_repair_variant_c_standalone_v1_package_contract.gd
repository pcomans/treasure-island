extends SceneTree

const SCENE_PATH := "res://game/scenes/world/facades/isle_house/isle_house_composite_repair_variant_c_standalone_v1.tscn"
const FACTORY_PATH := "res://game/scripts/world/facades/isle_house_composite_repair_variant_c_standalone_v1.gd"
const CONFIG_PATH := "res://game/resources/facades/isle_house_composite_repair_variant_c_standalone_v1.json"
const MID_MATERIAL := "res://game/resources/materials/world/isle_house/isle_house_podium_mid_warm_v1.tres"
const QUIET_MATERIAL := "res://game/resources/materials/world/isle_house/isle_house_return_quiet_v1.tres"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const LIVE_PATH := "res://game/scripts/world/facades/isle_house_39_bruton_low_live_attachment.gd"
const SOURCE_PACKET := "res://discovery/facades/p1_reference_packets/w1249412094_isle_house.md"
const FAILED_REVIEW := "res://evidence/first-playable/isle-house-composite-repair-standalone-v1-2026-09-04/INDEPENDENT_BAR_RAISER_REVIEW.md"
const NEW_EVIDENCE := "res://evidence/first-playable/isle-house-composite-repair-variant-c-standalone-v1-2026-09-04/capture-manifest.json"
const EXPECTED_NEW_HASHES := {
	CONFIG_PATH: "bafdef392ee638e860ba15f140c10de61e266ae63005b12e0e310e52c176897a",
	FACTORY_PATH: "b24fd72cd12aa0c6c45a123f005fc834ea657c343e8332a872eae07fa017ace7",
	SCENE_PATH: "568cf7b229ff10aec5aade61562c7a8f48e84119d650b1529af7f84071721d39",
	MID_MATERIAL: "a9c7230ff52d37327e6d98e0f14953eee2bd3eec7426dc993c0b7cf90e0ec037",
	QUIET_MATERIAL: "15d4848127a5153724d873dceea9d46121c0d65e5b53be61abed6e70a2f964c1",
}
const EXPECTED_PARENT_HASHES := {
	LIVE_PATH: "1b36a0ad92ded4607e0c1e0df5d5581d1c7afff5843cb75cd4c490790a86c413",
	"res://game/scripts/world/facades/isle_house_composite_repair_standalone_v1.gd": "b23d9cb3acbedacb323197fd38660f45b13e532dd11c1cca1fafe785338037d8",
	"res://game/resources/facades/isle_house_composite_repair_standalone_v1.json": "a3e1865d18cfbb4155cf01df3b5eb265ca67e4ee80acfc07986c84d0cd7db393",
	"res://game/scenes/world/facades/isle_house/isle_house_composite_repair_standalone_v1.tscn": "e16cd72955169e199f7631677f09e75441bea143c4f1b39d08e2409aaefdbb9a",
}
const EXPECTED_SOURCE_HASHES := {
	SOURCE_PACKET: "04f1009fd240cde4765095c49ba8174f90b80dbad54281d8036ef1df04c2874d",
	FAILED_REVIEW: "a5dd6b61a0adc25ad8d10879fcd342870ae11c71b18f52892287685ced36cad8",
}
const EXPECTED_REPAIR_SIGNATURE := "41868b77a8b51b56ee7381e5549423e97547270d2dc77d9ce5cf958b31e2cb69"
const EXPECTED_COMPOSITE_SIGNATURE := "d57d5088854d68b80d3747f4382da2f08fdbfc8c64e7acae0f342a2a72f435ec"
const EXPECTED_B_TOPOLOGY := {"mesh_instances": 16, "surfaces": 19, "triangles": 14375}
const EXPECTED_C_TOPOLOGY := {"mesh_instances": 17, "surfaces": 22, "triangles": 14301}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var mounted := "--mounted" in OS.get_cmdline_user_args()
	for path: String in [SCENE_PATH, FACTORY_PATH, CONFIG_PATH, MID_MATERIAL, QUIET_MATERIAL, CHUNK_PATH]:
		_require(ResourceLoader.exists(path) or FileAccess.file_exists(path), "Variant C package closure is missing %s." % path)
	if mounted:
		_require(not ResourceLoader.exists(SOURCE_PACKET) and not FileAccess.file_exists(SOURCE_PACKET), "Mounted package contains the discovery-only Isle House packet.")
		_require(not ResourceLoader.exists(FAILED_REVIEW) and not FileAccess.file_exists(FAILED_REVIEW), "Mounted package contains the sealed failed review.")
		_require(not ResourceLoader.exists(NEW_EVIDENCE) and not FileAccess.file_exists(NEW_EVIDENCE), "Mounted package contains Variant C evidence.")
	else:
		_run_source_boundary_checks()
	var packed := load(SCENE_PATH) as PackedScene
	_require(packed != null, "Variant C package scene did not load.")
	if packed != null:
		var standalone := packed.instantiate()
		_require(standalone != null and standalone.has_method("configure_from_chunk"), "Variant C package scene did not instantiate its factory.")
		if standalone != null and standalone.has_method("configure_from_chunk"):
			var configured: Dictionary = standalone.call("configure_from_chunk")
			_require(bool(configured.get("ok", false)), "Variant C package factory failed closed unexpectedly: %s" % configured)
			_require(str(configured.get("variant_c_repair_signature", "")) == EXPECTED_REPAIR_SIGNATURE, "Variant C package repair signature drifted.")
			_require(str(configured.get("variant_c_composite_signature", "")) == EXPECTED_COMPOSITE_SIGNATURE, "Variant C package composite signature drifted.")
			_require(configured.get("variant_b_topology", {}) == EXPECTED_B_TOPOLOGY, "Sealed Variant B package topology drifted.")
			_require(configured.get("variant_c_topology", {}) == EXPECTED_C_TOPOLOGY, "Variant C package topology drifted.")
			_require(bool(standalone.get_meta("standalone_only", false)) and not bool(standalone.get_meta("runtime_attachment", true)) and not bool(standalone.get_meta("live_replacement", true)), "Variant C package truth boundary drifted.")
			_require(not bool(standalone.get_meta("recognition_accepted", true)) and not bool(standalone.get_meta("believability_accepted", true)), "Variant C package self-promoted a visual claim.")
			_require(_count_type(standalone, CollisionObject3D) == 0 and _count_type(standalone, CollisionShape3D) == 0 and _count_type(standalone, NavigationRegion3D) == 0, "Variant C package acquired collision or navigation ownership.")
			_require(not _any_node_in_group(standalone, "spray_receiver") and not _any_node_in_group(standalone, "spray_receiver_wall"), "Variant C package acquired spray ownership.")
			standalone.free()
	if not _failed:
		print("PASS: %s Variant C package closure rebuilds exact sealed-B/C signatures and topology without discovery/evidence payloads, source URLs, live promotion, or decorative ownership" % ("mounted" if mounted else "source"))
	quit(1 if _failed else 0)


func _run_source_boundary_checks() -> void:
	for path: String in EXPECTED_NEW_HASHES:
		_require(FileAccess.get_sha256(path) == str(EXPECTED_NEW_HASHES[path]), "Variant C package-safe asset drifted: %s." % path)
	for path: String in EXPECTED_PARENT_HASHES:
		_require(FileAccess.get_sha256(path) == str(EXPECTED_PARENT_HASHES[path]), "A sealed parent/live/builder asset drifted: %s." % path)
	for path: String in EXPECTED_SOURCE_HASHES:
		_require(FileAccess.get_sha256(path) == str(EXPECTED_SOURCE_HASHES[path]), "Variant C source/review authority drifted: %s." % path)
	var runtime_text := ""
	for path: String in [CONFIG_PATH, FACTORY_PATH, SCENE_PATH, MID_MATERIAL, QUIET_MATERIAL]:
		runtime_text += FileAccess.get_file_as_string(path).to_lower() + "\n"
	for token: String in ["res://discovery/", "res://evidence/", "http://", "https://", "file://", "/volumes/", "/users/"]:
		_require(token not in runtime_text, "Variant C executable closure contains forbidden source/runtime token %s." % token)
	var builder := FileAccess.get_file_as_string(BUILDER_PATH).to_lower()
	_require("isle_house_composite_repair_variant_c_standalone_v1.tscn" not in builder, "Historical Variant C standalone scene was wired directly into world construction.")
	_require("isle_house_composite_repair_variant_c_live_attachment.gd" in builder, "Approved Variant C live promotion does not use its narrow adapter.")
	var preset := FileAccess.get_file_as_string("res://export_presets.cfg")
	for token: String in ["discovery/*", "discovery/**/*", "evidence/*", "evidence/**/*"]:
		_require(token in preset, "Private export preset lost source/evidence exclusion %s." % token)


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


func _any_node_in_group(node: Node, group_name: StringName) -> bool:
	if node.is_in_group(group_name):
		return true
	for child: Node in node.get_children():
		if _any_node_in_group(child, group_name):
			return true
	return false


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ISLE_COMPOSITE_VARIANT_C_PACKAGE_FAIL: %s" % message)
	return false
