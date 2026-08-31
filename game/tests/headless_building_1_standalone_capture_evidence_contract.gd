extends SceneTree

const ROOT := "res://evidence/first-playable/treasure-island-building-1-standalone-prototypes-2026-08-30"
const EXPECTED_RECORD_HASHES := {
	"res://evidence/first-playable/treasure-island-building-1-standalone-prototypes-2026-08-30/capture-manifest.json": "db791549eccb0f43848dd59d483c2178ea4191a199397e2e4a0cc6e4a0513024",
	"res://evidence/first-playable/treasure-island-building-1-standalone-prototypes-2026-08-30/runtime-isolation.json": "4de6962d553aa7addc76d533bb94b7173cc042b55d3089d8ab4b94a88bcdc668",
	"res://evidence/first-playable/treasure-island-building-1-standalone-prototypes-2026-08-30/visual-verification.json": "6985c508cc9c5b896c258b3249b3e5d0a7193bf64f2efeb23d4d90fcdf0a8237",
	"res://evidence/first-playable/treasure-island-building-1-standalone-prototypes-2026-08-30/checksums.sha256": "d1e7ab8987f64d01165555fdade3b52dfa042b1ef1a9d5eb2b32ec88cb85ac65",
	"res://evidence/first-playable/treasure-island-building-1-standalone-prototypes-2026-08-30/README.md": "357ebcbd8275bd5ce0b714864f6e5f36840b1395ec0c56dbd011da46a563fca7",
	"res://game/resources/facades/building_1_standalone_prototypes.json": "2014040edb3985be4aaae437749063474aacaedc0534b6d54e69b7dfd92612cc",
	"res://game/tests/building_1_standalone_prototype_capture.gd": "8f82d5d4f761e9eacadb8f865739692e9fd1af017b8155e734f3a1395a562339",
}
const EXPECTED_IMAGES := {
	"01-warm-ivory-neutral-close.png": "7125865fadb5fbf7da5e465a631c6205bef931dc4876cbccbe0190d0522c84cd",
	"02-warm-ivory-macro-40m.png": "657056dc0887cc93a84c7c8edbfab9de055c3454423075060b672d9832f9b907",
	"03-wing-window-close.png": "7a0dd27e93fbe3fbfe0b6944bb86c33877d06386cccafb2bc5693beb9b7e0ee9",
	"04-central-window-close.png": "1b874f14cc3d091cb4a8c92d546cc92f2401956e0412f5d24919423b9854719a",
	"05-pavilion-window-close.png": "b949aa179ad330456e8b4ffa80f2f097952983af3fc1ef5a27a231d86a5125ec",
	"06-base-opening-close.png": "7e1316cb32ffa8af9918eea32bf8d14f17839251419c6a38b97e720e8bdbc623",
	"07-blue-door-close.png": "98df9d98b0fe8f84c7ab67ab84801da68015014e4011a64b56dd997eeba4217a",
	"08-band-oblique-close.png": "cbe6fa4dc797f1293faf733d04e237e35bd7bcf5c93331bbabcd307d071883bf",
	"09-all-modules-oblique.png": "6246ec0e5fa0ad55e7ebda7f7ee2f459b4ee518933a71e460f71b60aa4c2996f",
	"10-ordinary-distance-aggregate.png": "5a89c000dc9417178bd880d245deadf12eb730239affa379404233fee1455ec9",
	"11-changed-light-aggregate.png": "f90e2dcf769ddf0f47ff8ac09b0254b1eac8d4c51b05cb20cfb1ba981dd6000f",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(_hashes_match(EXPECTED_RECORD_HASHES), "A Building 1 evidence or harness record drifted.") \
	or not _require(_images_match(), "A Building 1 native evidence PNG drifted or failed size/import checks."):
		_finish()
		return
	var manifest := JSON.parse_string(FileAccess.get_file_as_string(ROOT.path_join("capture-manifest.json"))) as Dictionary
	var isolation := JSON.parse_string(FileAccess.get_file_as_string(ROOT.path_join("runtime-isolation.json"))) as Dictionary
	var verification := JSON.parse_string(FileAccess.get_file_as_string(ROOT.path_join("visual-verification.json"))) as Dictionary
	if not _require(_manifest_matches(manifest), "Building 1 capture manifest lost renderer, classification, topology, per-family coverage, or truth boundaries.") \
	or not _require(_isolation_matches(isolation), "Building 1 runtime/generated or interrupted-r133351 isolation record failed.") \
	or not _require(_verification_matches(verification), "Building 1 manual visual-verification record is incomplete or overclaims acceptance."):
		_finish()
		return
	print("PASS: Building 1 standalone evidence contains 11 immutable native 1440x900 Forward+/Metal PNGs with close coverage for one warm-ivory field and six complete modules, 40 m macro, ordinary/oblique and changed-light views; manifest, checksums, visual inspection and runtime isolation are coherent, limitations are explicit, and no self-acceptance or placement claim occurred")
	_finish()


func _manifest_matches(manifest: Dictionary) -> bool:
	if str(manifest.get("schema_version", "")) != "ti.building-1-standalone-prototype-evidence/1" \
	or str(manifest.get("source_key", "")) != "r16681702" \
	or str(manifest.get("receiver_key", "")) != "building:r16681702:wall" \
	or str(manifest.get("review_status", "")) != "ready_for_independent_standalone_art_review_not_self_accepted" \
	or bool(manifest.get("runtime_attachment", true)) \
	or bool(manifest.get("exact_receiver_calibration", true)) \
	or str(manifest.get("display_driver", "")) != "macOS" \
	or str(manifest.get("rendering_method", "")) != "Forward+" \
	or str(manifest.get("rendering_driver", "")) != "Metal" \
	or "Apple M1 Pro" not in str(manifest.get("video_adapter", "")) \
	or manifest.get("viewport", []) != [1440.0, 900.0]:
		return false
	var kinds := manifest.get("asset_kinds", {}) as Dictionary
	if (kinds.get("homogeneous_material_tile", []) as Array) != ["B1-MAT-IVORY"] \
	or (kinds.get("module_atlas", []) as Array) != ["B1-WING-W", "B1-CENTRAL-W", "B1-PAV-W", "B1-BASE-O", "B1-DOOR-BLUE", "B1-BAND"] \
	or not (kinds.get("architectural_pattern_tile", []) as Array).is_empty() \
	or not (kinds.get("unique_elevation", []) as Array).is_empty():
		return false
	var topology := manifest.get("topology", {}) as Dictionary
	if int(topology.get("total_meshes", 0)) != 44 \
	or int(topology.get("total_surfaces", 0)) != 44 \
	or int(topology.get("total_triangles", 0)) != 528 \
	or int(topology.get("module_meshes", 0)) != 43 \
	or int(topology.get("module_triangles", 0)) != 516 \
	or int(topology.get("collision_nodes", -1)) != 0 \
	or int(topology.get("navigation_nodes", -1)) != 0 \
	or int(topology.get("spray_nodes", -1)) != 0:
		return false
	var module_proof := manifest.get("module_proof", {}) as Dictionary
	if int(module_proof.get("complete_motifs", 0)) != 6 \
	or int(module_proof.get("field_or_backing_meshes", -1)) != 0:
		return false
	var captures := manifest.get("captures", []) as Array
	if captures.size() != EXPECTED_IMAGES.size():
		return false
	var seen: Array[String] = []
	for value: Variant in captures:
		var capture := value as Dictionary
		var file := str(capture.get("file", ""))
		seen.append(file)
		if not EXPECTED_IMAGES.has(file) \
		or str(capture.get("sha256", "")) != str(EXPECTED_IMAGES[file]) \
		or capture.get("dimensions", []) != [1440.0, 900.0] \
		or int(capture.get("bytes", 0)) <= 50000 \
		or float((capture.get("sampled_luminance", {}) as Dictionary).get("range", 0.0)) <= 0.1:
			return false
	seen.sort()
	var expected_names: Array[String] = []
	for name: Variant in EXPECTED_IMAGES:
		expected_names.append(str(name))
	expected_names.sort()
	if seen != expected_names:
		return false
	var blocked := JSON.stringify(manifest.get("blocked_claims", [])).to_lower()
	return "placement" in blocked and "count" in blocked and "canopy" in blocked and "inner ring" in blocked and "whole-building" in blocked


func _isolation_matches(isolation: Dictionary) -> bool:
	return str(isolation.get("result", "")) == "PASS" \
		and bool(isolation.get("standalone_only", false)) \
		and not bool(isolation.get("runtime_attachment", true)) \
		and not bool(isolation.get("exact_receiver_calibration", true)) \
		and int(isolation.get("live_placement_count", -1)) == 0 \
		and not bool(isolation.get("generated_data_changed", true)) \
		and not bool(isolation.get("world_builder_changed", true)) \
		and not bool(isolation.get("canonical_inventory_changed", true)) \
		and not bool(isolation.get("separate_tower_w1222720021_touched", true)) \
		and bool(isolation.get("interrupted_r133351_bytes_unchanged", false)) \
		and str(isolation.get("interrupted_r133351_review_status", "")) == "unreviewed_held_uncommitted" \
		and (isolation.get("interrupted_r133351_hashes", []) as Array).size() == 9


func _verification_matches(verification: Dictionary) -> bool:
	if str(verification.get("result", "")) != "PASS_WITH_DOCUMENTED_FRAMING_LIMITATIONS_PENDING_INDEPENDENT_ART_REVIEW" \
	or bool(verification.get("self_acceptance", true)) \
	or bool(verification.get("recapture_or_art_correction_performed", true)) \
	or (verification.get("images", []) as Array).size() != 11:
		return false
	var text := JSON.stringify(verification).to_lower()
	for phrase in ["neighboring", "illustrative", "not an elevation", "window-versus-vent", "darker exposure", "whole-building"]:
		if phrase not in text:
			return false
	return true


func _images_match() -> bool:
	for file_value: Variant in EXPECTED_IMAGES:
		var file := str(file_value)
		var path := ROOT.path_join(file)
		if FileAccess.get_sha256(path) != str(EXPECTED_IMAGES[file_value]):
			return false
		var image := Image.load_from_file(path)
		if image == null or image.is_empty() or image.get_size() != Vector2i(1440, 900):
			return false
	return true


func _hashes_match(expected: Dictionary) -> bool:
	for path_value: Variant in expected:
		var path := str(path_value)
		if FileAccess.get_sha256(path) != str(expected[path_value]):
			return false
	return true


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
