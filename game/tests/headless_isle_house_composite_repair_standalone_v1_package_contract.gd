extends SceneTree

const FACTORY_SCENE := "res://game/scenes/world/facades/isle_house/isle_house_composite_repair_standalone_v1.tscn"
const FACTORY_SCRIPT := "res://game/scripts/world/facades/isle_house_composite_repair_standalone_v1.gd"
const CONFIG_PATH := "res://game/resources/facades/isle_house_composite_repair_standalone_v1.json"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const LANDSCAPE_MATERIAL := "res://game/resources/materials/world/isle_house/isle_house_low_landscape_proxy.tres"
const SOURCE_PACKET := "res://discovery/facades/p1_reference_packets/w1249412094_isle_house.md"
const FAILED_REVIEW := "res://evidence/first-playable/isle-house-low-live-integration-2026-09-04/INDEPENDENT_COMPOSITE_REVIEW.md"
const EXPECTED_REPAIR_SIGNATURE := "a58d9b963b0dc19b5a9fa1cba4872294a2ea2803459a9ba455e276dc1ff5b5bf"
const EXPECTED_TOPOLOGY_A := {"mesh_instances": 15, "surfaces": 16, "triangles": 13903}
const EXPECTED_TOPOLOGY_B := {"mesh_instances": 16, "surfaces": 19, "triangles": 14375}
const EXPECTED_CONFIG_SHA256 := "a3e1865d18cfbb4155cf01df3b5eb265ca67e4ee80acfc07986c84d0cd7db393"

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var mounted := "--mounted" in OS.get_cmdline_user_args()
	for path: String in [FACTORY_SCENE, FACTORY_SCRIPT, CONFIG_PATH, CHUNK_PATH, LANDSCAPE_MATERIAL]:
		_require(ResourceLoader.exists(path) or FileAccess.file_exists(path), "Standalone Isle House package closure is missing %s." % path)
	_require(FileAccess.get_sha256(CONFIG_PATH) == EXPECTED_CONFIG_SHA256, "Standalone Isle House package config bytes drifted.")
	if mounted:
		_require(not ResourceLoader.exists(SOURCE_PACKET) and not FileAccess.file_exists(SOURCE_PACKET), "Mounted package contains the discovery-only Isle House packet.")
		_require(not ResourceLoader.exists(FAILED_REVIEW) and not FileAccess.file_exists(FAILED_REVIEW), "Mounted package contains prior evidence/review material.")
	else:
		_run_source_boundary_checks()
	var packed := load(FACTORY_SCENE) as PackedScene
	_require(packed != null, "Standalone Isle House package scene did not load.")
	if packed != null:
		var standalone := packed.instantiate()
		_require(standalone != null and standalone.has_method("configure_from_chunk"), "Standalone Isle House package scene did not instantiate its factory.")
		if standalone != null and standalone.has_method("configure_from_chunk"):
			var configured: Dictionary = standalone.call("configure_from_chunk")
			_require(bool(configured.get("ok", false)), "Standalone Isle House package factory failed closed unexpectedly: %s" % configured)
			_require(str(configured.get("repair_signature", "")) == EXPECTED_REPAIR_SIGNATURE, "Standalone Isle House mounted repair signature drifted.")
			_require(_topology_matches(configured.get("variant_a_topology", {}) as Dictionary, EXPECTED_TOPOLOGY_A), "Standalone Isle House mounted Variant A topology drifted.")
			_require(_topology_matches(configured.get("variant_b_topology", {}) as Dictionary, EXPECTED_TOPOLOGY_B), "Standalone Isle House mounted Variant B topology drifted.")
			_require(bool(standalone.get_meta("standalone_only", false)) and not bool(standalone.get_meta("runtime_attachment", true)), "Standalone Isle House mounted truth boundary drifted.")
			_require(_count_type(standalone, CollisionObject3D) == 0 and _count_type(standalone, CollisionShape3D) == 0 and _count_type(standalone, NavigationRegion3D) == 0, "Standalone Isle House mounted package acquired collision or navigation ownership.")
			_require(not _any_node_in_group(standalone, "spray_receiver") and not _any_node_in_group(standalone, "spray_receiver_wall"), "Standalone Isle House mounted package acquired spray ownership.")
			standalone.free()
	if not _failed:
		print("PASS: %s Isle House standalone package closure loads and deterministically builds exact A/B topology/signature without discovery/evidence payloads or decorative ownership" % ("mounted" if mounted else "source"))
	quit(1 if _failed else 0)


func _run_source_boundary_checks() -> void:
	var config := FileAccess.get_file_as_string(CONFIG_PATH)
	var factory := FileAccess.get_file_as_string(FACTORY_SCRIPT)
	var scene := FileAccess.get_file_as_string(FACTORY_SCENE)
	var closure_text := (config + "\n" + factory + "\n" + scene).to_lower()
	for token: String in ["res://discovery/", "res://evidence/", "https://", "http://", "/volumes/", "/users/"]:
		_require(token not in closure_text, "Standalone Isle House executable closure contains forbidden source/runtime token %s." % token)
	var builder := FileAccess.get_file_as_string("res://game/scripts/world/world_chunk_builder.gd")
	_require("isle_house_composite_repair_standalone_v1" not in builder, "Standalone Isle House factory was connected to world construction before independent review.")
	var preset := FileAccess.get_file_as_string("res://export_presets.cfg")
	for token: String in ["discovery/*", "discovery/**/*", "evidence/*", "evidence/**/*"]:
		_require(token in preset, "Private export preset lost its source/evidence exclusion %s." % token)


func _topology_matches(actual: Dictionary, expected: Dictionary) -> bool:
	return int(actual.get("mesh_instances", -1)) == int(expected.mesh_instances) \
		and int(actual.get("surfaces", -1)) == int(expected.surfaces) \
		and int(actual.get("triangles", -1)) == int(expected.triangles)


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
	push_error("ISLE_COMPOSITE_REPAIR_PACKAGE_FAIL: %s" % message)
	return false
