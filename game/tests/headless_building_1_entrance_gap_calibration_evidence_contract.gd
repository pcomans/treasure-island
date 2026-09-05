extends SceneTree

const ROOT := "res://evidence/first-playable/building-1-entrance-group-gap-calibration-2026-09-04"
const REJECTED_ROOT := "res://evidence/first-playable/building-1-entrance-group-gap-calibration-rejected-attempt-001-2026-09-04"
const CONFIG_PATH := "res://game/resources/facades/building_1_public_front_believability.json"
const CATALOG_PATH := "res://discovery/facades/facade-recognition-catalog.json"
const SCHEMA_PATH := "res://discovery/facades/facade-recognition-catalog.schema.json"
const REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const ADAPTER_CONTRACTS_PATH := "res://game/resources/facades/facade-runtime-adapter-contracts.json"
const REPORT_PATH := "res://discovery/facades/facade-recognition-validation-report.json"
const COMPILER_PATH := "res://tools/build_facade_recognition_registry.mjs"
const SCHEMA_VALIDATOR_PATH := "res://tools/lib/dependency-free-json-schema.mjs"
const LOADER_PATH := "res://game/scripts/world/facades/facade_runtime_registry_loader.gd"
const GENERATOR_PATH := "res://game/tests/building_1_entrance_gap_calibration_capture.gd"
const FINALIZER_PATH := "res://game/tests/building_1_entrance_gap_salvage_finalizer.gd"
const CAPTURE_REGISTRY_SHA256 := "36eef28d1abce9d9838da6e959222ad6767e40e198b90b734496e6d2dc2cd79b"
const CURRENT_CONFIG_SHA256 := "7b53847c627d6f0a0d4ebefcc790e8fd3bcaeee6fbdebbf5c6a85f2aeb4a5806"
const POST_CAPTURE_CATALOG_SHA256 := "ab8797e86d5985c4b64670a22577394656c6388bb463f83c157a411663fa7b57"
const POST_CAPTURE_SCHEMA_SHA256 := "03174de9b4a8cae13ef573c93b3a8bf4dbb9615ef3f953c1a29f90332c8c3f43"
const POST_CAPTURE_REGISTRY_SHA256 := "65edf085437bc3fa2b22869406cc8a2c33297b6cc9d48b205e301e367efc734b"
const POST_CAPTURE_ADAPTER_CONTRACTS_SHA256 := "503c8d02439d0846389d5d57e2b2a26d8e42ee6156ff08f489de6e9dc4325222"
const POST_CAPTURE_REPORT_SHA256 := "64bcfe0607a4f7c3a4bdaa53f01573d335891e828b9f2ee518cc9f96394f90d7"
const POST_CAPTURE_COMPILER_SHA256 := "a05b46ad52256444873599c2ed0483c9e27d8821f0ff0b56036c3b0712f23b51"
const CURRENT_SCHEMA_VALIDATOR_SHA256 := "eeee5d9a22bd81fdaf8df56bd7f680b62c88a133aebf33424ccc1336a98d84e0"
const POST_CAPTURE_LOADER_SHA256 := "4c9af1ffcf5724e8c35e4b591a85697f1667f8d120af41a74fac511bfcb4f356"
const CURRENT_CATALOG_SHA256 := "a4d9dd474acb09a211f7e0e00d66aeaf7a669927880dd011e24e2f51d13bdd7d"
const CURRENT_SCHEMA_SHA256 := "07a4b17cbeba4603a2e08b99787dd00fe934eeda83aa6da2e850c327ac77e2c5"
const CURRENT_REGISTRY_SHA256 := "9c46c1a8c809aa9ded82008d35e9c1b257070e9c61f6d6e41f5650ca7b1c3f27"
const CURRENT_ADAPTER_CONTRACTS_SHA256 := "f5c1a2fb73ac0343258d4fea35169e2b7efa98accbce0c834b3e2aab45fefafe"
const CURRENT_REPORT_SHA256 := "4caabace118ebf545c581e0be2c59e680726be3cc7fe658cf35dddfd56b78d26"
const CURRENT_COMPILER_SHA256 := "371289a4d73235165a1aeeba0a3651129dc4ba2655aa18ee52622374a62ac917"
const CURRENT_LOADER_SHA256 := "a191a9c260e471825847c92873fd96763c507b51004be769cba10b9d4b47ce6f"
const CURRENT_RECOGNITION_RECEIPTS := {
	"building:r16681702:wall": {
		"unit_id": "physical-building:r16681702",
		"run_count": 110,
		"review_receipt_sha256": "b12858438d6522b7f3cf42fa06392648d16ee3e0c418eb5e807a3ee1be770c2a",
		"evidence_manifest_sha256": "ebeef887b37c6845c6c8fa3f25e06706351fe7c1dab0e1a3b0eaf47dfb773017",
	},
	"building:w1222720021:wall": {
		"unit_id": "physical-building:w1222720021",
		"run_count": 10,
		"review_receipt_sha256": "fb952a31151805078d1e386117ed965aa0649ffddcd17874d13493b5dd4239bb",
		"evidence_manifest_sha256": "dbe9745f5356b2309e820c2b47987ee4463518eaf4afd77fcd37df0edc8d437a",
	},
}
const GENERATOR_SHA256 := "b1565b71cbda76a8c63204b18d7cac99ad78a6882667bafcd798de5b8dbaf160"
const FINALIZER_SHA256 := "85c2bc869787dcf466540ec40d284419d75acb9e6205ac2e86e69edd50850078"
const INDEPENDENT_REVIEW_SHA256 := "44c0bde816efbf9acfedd45d1d45c663319cb4e421afcd2551812e6c4a1b7659"
const CAPTURE_TOPOLOGY := {"rows": 735, "meshes": 944, "surfaces": 957, "triangles": 64572, "bodies": 466, "shapes": 466}
const EXPECTED_FILES := {
	"INDEPENDENT_VISUAL_BAR_RAISER_REVIEW.md": INDEPENDENT_REVIEW_SHA256,
	"README.md": "90c2daf6e9738d64106d4c5947b61f9cbde2bcc1fb26f5dc1a45e6c460c823fe",
	"a-motion.json": "8fe4e052bdb0a5c1c89eb5103bfdb3b7a58169a77d3d32bf6c998d92a6181ba8",
	"a-stills.json": "d0193298acb3068722ba63ce6858b698296d4b93a1d75a2b410dd7890b2f2a74",
	"avi-container-validation.json": "b49a0ac505f0488ed0ce7684c64945e60bb9ad78e70972016e480ece92441838",
	"b-motion-preliminary-unfinalized.json": "5e541a144aee83d19a26f364454b5bed7b7659a18bdcaff96d9db0f530a26040",
	"b-motion.json": "5448bd69ed81588be75c0eff5b47f2185d392b132dd7403577463d63a6f390fd",
	"b-stills.json": "9468170d4f93153c2fe8ae5b282bd99d46bcbd941a4e420072a6068d5c1e0e2a",
	"building-1-entrance-gap-a-normal-forward-approach.avi": "cf51e56538ba640b083d67c12d3f79e9f1864b57f70cf3ba0015e76c7a66b6ff",
	"building-1-entrance-gap-b-normal-forward-approach.avi": "318718deb113bc9d639db6bed28cd0e8eb30459c3b7754fe39dba5728b6a1e82",
	"capture-manifest.json": "7dac2b94933dd74642dc0c164e0ce7d6a3b774b7ec265e078e96e34dea199dd2",
	"capture-window-override.cfg": "edbc0b9caa60fa0fc6b83cebb3145bce11ce0bd976403ca1d2fbe9b7142b39c3",
	"images/a/01-public-front-whole-changed-light-color.png": "404583d92ba176b97d77c40f52890241ed459fb07ce5db91e545feeb5098f346",
	"images/a/01-public-front-whole-default-color.png": "d2189c1b70d0368f53de624d45f4cf41436b4f8972ae4e34afcd1045efd93c91",
	"images/a/02-public-front-entrances-default-color.png": "4ea83c8a367e9c2a0b63f2e395241cc6daa62381c3c3992b9769cbdb33a19e9d",
	"images/a/02-public-front-entrances-default-grayscale.png": "3382d7dceb216453bfbd1c87fc7c8f9c916b368656e3e84339b606a5ba2dc9d5",
	"images/b/01-public-front-whole-changed-light-color.png": "cd569f5452b0f34124e0cd09dd53a885a089a402741229a591cb2fc47d892c55",
	"images/b/01-public-front-whole-default-color.png": "04f287178f125645dd2205feb619e08379b18e5d5784b2e7d4baf4fddfa45c09",
	"images/b/02-public-front-entrances-default-color.png": "dee2b8c3a41b1cd95d2f4c364e9d98faf333316e888897221855356ad1b6e686",
	"images/b/02-public-front-entrances-default-grayscale.png": "5db49499ed724bcde9d69c1ba4e7325f3a4f33bfd4d236051a3b5c211ae23dad",
	"post-capture-runtime-closure.json": "1a0ea691eae1998cb488e0453d8897a49b0c2d77c2b2caaff0cf1ccc60af527f",
}
const REJECTED_LEDGER_SHA256 := "cd52cb57aae4b92bf81e4fefd86e36640d40e2b722f8d4548eb634f2cc533165"
const REJECTED_FILES := {
	"REJECTED_ATTEMPT.md": "ba15791d2dc966b23ba879a2dfdd01b2dad56c2e7810bf8667c827c90fc2f932",
	"a-stills.json": "0b8ffa8655372dea6e3cc207373eaccb38d284b84b726668820290ec2fe9997f",
	"building-1-entrance-gap-a-normal-forward-approach.avi": "14b347e1adefaeb9164845e1874c285aa5ecfe70dc700c3239e63a99c77385c5",
	"images/a/01-public-front-whole-changed-light-color.png": "a837f9e5aef6a7979257f46246b2416479236a0d407a22a6252cf910566cc7d0",
	"images/a/01-public-front-whole-default-color.png": "d2189c1b70d0368f53de624d45f4cf41436b4f8972ae4e34afcd1045efd93c91",
	"images/a/02-public-front-entrances-default-color.png": "4ea83c8a367e9c2a0b63f2e395241cc6daa62381c3c3992b9769cbdb33a19e9d",
	"images/a/02-public-front-entrances-default-grayscale.png": "3382d7dceb216453bfbd1c87fc7c8f9c916b368656e3e84339b606a5ba2dc9d5",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_require(FileAccess.get_sha256(GENERATOR_PATH) == GENERATOR_SHA256, "Capture generator bytes drifted.")
	_require(FileAccess.get_sha256(FINALIZER_PATH) == FINALIZER_SHA256, "One-shot salvage finalizer bytes drifted.")
	_require(not FileAccess.file_exists("res://override.cfg"), "Temporary capture override remains in the product root.")
	_require(_evidence_hashes_match(), "A sealed Building 1 A/B evidence artifact drifted.")
	_require(_checksum_ledger_matches(), "Building 1 A/B checksum ledger is incomplete or stale.")
	_require(_canonical_tree_matches(), "Building 1 A/B evidence tree contains an unsealed extra, pending, journal, temporary, or unexpected directory entry.")
	_require(_rejected_attempt_matches(), "Rejected 1280x800 attempt provenance is incomplete, mutable, or misrepresented as evidence.")
	_require(_capture_pair_matches(), "Building 1 A/B capture pairing, motion, or topology contract drifted.")
	_require(_media_matches(), "Building 1 A/B image or AVI technical evidence drifted.")
	_require(_sealed_post_capture_runtime_closure_matches(), "Sealed post-capture v6/v5 11-asset runtime closure drifted.")
	_require(_current_runtime_bridge_matches(), "Current v7/v6 11-asset runtime bridge drifted.")
	if not _failed:
		print("PASS: Building 1 entrance-gap A/B is byte-sealed and matched; 0.55->0.90 m only; 1440x900 stills + 529-tick stock motion; capture topology 735/944/957/64572/466/466 and recognition 6/213 remain historical; current v7/v6 11-asset B1/tower closure derives accepted recognition from physical-unit receipts at 7/213")
	quit(1 if _failed else 0)


func _evidence_hashes_match() -> bool:
	for relative_value: Variant in EXPECTED_FILES:
		var relative := str(relative_value)
		if FileAccess.get_sha256(ROOT.path_join(relative)) != str(EXPECTED_FILES[relative_value]):
			return false
	return FileAccess.get_file_as_bytes(ROOT.path_join("building-1-entrance-gap-a-normal-forward-approach.avi")).size() == 45838270 \
		and FileAccess.get_file_as_bytes(ROOT.path_join("building-1-entrance-gap-b-normal-forward-approach.avi")).size() == 45825536


func _checksum_ledger_matches() -> bool:
	var path := ROOT.path_join("CHECKSUMS.sha256")
	if not FileAccess.file_exists(path):
		return false
	var seen := {}
	for line: String in FileAccess.get_file_as_string(path).split("\n", false):
		var separator := line.find("  ")
		if separator != 64:
			return false
		var sha := line.left(separator)
		var relative := line.substr(separator + 2)
		if not EXPECTED_FILES.has(relative) or seen.has(relative) or sha != str(EXPECTED_FILES[relative]):
			return false
		seen[relative] = true
	return seen.size() == EXPECTED_FILES.size()


func _canonical_tree_matches() -> bool:
	var expected_root_files := ["CHECKSUMS.sha256"]
	var expected_a_files: Array[String] = []
	var expected_b_files: Array[String] = []
	for relative_value: Variant in EXPECTED_FILES:
		var relative := str(relative_value)
		if relative.begins_with("images/a/"):
			expected_a_files.append(relative.trim_prefix("images/a/"))
		elif relative.begins_with("images/b/"):
			expected_b_files.append(relative.trim_prefix("images/b/"))
		else:
			expected_root_files.append(relative)
	expected_root_files.sort()
	expected_a_files.sort()
	expected_b_files.sort()
	var root_files := Array(DirAccess.get_files_at(ROOT))
	var root_directories := Array(DirAccess.get_directories_at(ROOT))
	var image_root_files := Array(DirAccess.get_files_at(ROOT.path_join("images")))
	var image_directories := Array(DirAccess.get_directories_at(ROOT.path_join("images")))
	var a_files := Array(DirAccess.get_files_at(ROOT.path_join("images/a")))
	var b_files := Array(DirAccess.get_files_at(ROOT.path_join("images/b")))
	root_files.sort()
	root_directories.sort()
	image_root_files.sort()
	image_directories.sort()
	a_files.sort()
	b_files.sort()
	return root_files == expected_root_files \
		and root_directories == ["images"] \
		and image_root_files.is_empty() \
		and image_directories == ["a", "b"] \
		and a_files == expected_a_files \
		and b_files == expected_b_files \
		and (DirAccess.get_directories_at(ROOT.path_join("images/a")) as PackedStringArray).is_empty() \
		and (DirAccess.get_directories_at(ROOT.path_join("images/b")) as PackedStringArray).is_empty()


func _rejected_attempt_matches() -> bool:
	if FileAccess.get_sha256(REJECTED_ROOT.path_join("CHECKSUMS.sha256")) != REJECTED_LEDGER_SHA256:
		return false
	for relative_value: Variant in REJECTED_FILES:
		var relative := str(relative_value)
		if FileAccess.get_sha256(REJECTED_ROOT.path_join(relative)) != str(REJECTED_FILES[relative_value]):
			return false
	var seen := {}
	for line: String in FileAccess.get_file_as_string(REJECTED_ROOT.path_join("CHECKSUMS.sha256")).split("\n", false):
		var separator := line.find("  ")
		if separator != 64:
			return false
		var sha := line.left(separator)
		var relative := line.substr(separator + 2)
		if not REJECTED_FILES.has(relative) or seen.has(relative) or sha != str(REJECTED_FILES[relative]):
			return false
		seen[relative] = true
	if seen.size() != REJECTED_FILES.size():
		return false
	var root_files := Array(DirAccess.get_files_at(REJECTED_ROOT))
	var root_directories := Array(DirAccess.get_directories_at(REJECTED_ROOT))
	var image_root_files := Array(DirAccess.get_files_at(REJECTED_ROOT.path_join("images")))
	var image_directories := Array(DirAccess.get_directories_at(REJECTED_ROOT.path_join("images")))
	root_files.sort()
	root_directories.sort()
	image_root_files.sort()
	image_directories.sort()
	var image_files := Array(DirAccess.get_files_at(REJECTED_ROOT.path_join("images/a")))
	var image_nested_directories := Array(DirAccess.get_directories_at(REJECTED_ROOT.path_join("images/a")))
	image_files.sort()
	image_nested_directories.sort()
	if root_files != ["CHECKSUMS.sha256", "REJECTED_ATTEMPT.md", "a-stills.json", "building-1-entrance-gap-a-normal-forward-approach.avi"] \
	or root_directories != ["images"] \
	or not image_root_files.is_empty() \
	or image_directories != ["a"] \
	or image_files != ["01-public-front-whole-changed-light-color.png", "01-public-front-whole-default-color.png", "02-public-front-entrances-default-color.png", "02-public-front-entrances-default-grayscale.png"] \
	or not image_nested_directories.is_empty():
		return false
	for forbidden: String in ["a-motion.json", "b-stills.json", "b-motion.json", "capture-manifest.json"]:
		if FileAccess.file_exists(REJECTED_ROOT.path_join(forbidden)):
			return false
	var rejected_text := FileAccess.get_file_as_string(REJECTED_ROOT.path_join("REJECTED_ATTEMPT.md"))
	var rejected_stills := _json(REJECTED_ROOT.path_join("a-stills.json"))
	var rejected_avi := _avi(REJECTED_ROOT.path_join("building-1-entrance-gap-a-normal-forward-approach.avi"))
	return rejected_text.contains("rejected before candidate implementation; never admissible as A/B evidence") \
		and rejected_text.contains("No `a-motion.json` was produced") \
		and str(rejected_stills.get("stage", "")) == "a" \
		and absf(float(rejected_stills.get("entrance_group_gap_m", -1.0)) - 0.55) <= 0.000000001 \
		and int(rejected_avi.get("width", -1)) == 1280 \
		and int(rejected_avi.get("height", -1)) == 800 \
		and int(rejected_avi.get("total_frames", -1)) == 2 \
		and FileAccess.get_file_as_bytes(REJECTED_ROOT.path_join("building-1-entrance-gap-a-normal-forward-approach.avi")).size() == 89488


func _capture_pair_matches() -> bool:
	var a_stills := _json(ROOT.path_join("a-stills.json"))
	var b_stills := _json(ROOT.path_join("b-stills.json"))
	var a_motion := _json(ROOT.path_join("a-motion.json"))
	var b_motion := _json(ROOT.path_join("b-motion.json"))
	var preliminary := _json(ROOT.path_join("b-motion-preliminary-unfinalized.json"))
	var combined := _json(ROOT.path_join("capture-manifest.json"))
	if str(a_stills.get("public_front_config_sha256", "")) != "fd434eb472f61d93408732841e5993881b23238af8c0518b59181ac0ea535e32" \
	or str(a_motion.get("public_front_config_sha256", "")) != "fd434eb472f61d93408732841e5993881b23238af8c0518b59181ac0ea535e32" \
	or str(b_stills.get("public_front_config_sha256", "")) != CURRENT_CONFIG_SHA256 \
	or str(b_motion.get("public_front_config_sha256", "")) != CURRENT_CONFIG_SHA256 \
	or str(preliminary.get("public_front_config_sha256", "")) != CURRENT_CONFIG_SHA256:
		return false
	for manifest: Dictionary in [a_stills, b_stills, a_motion, b_motion, preliminary]:
		var bindings := manifest.get("bindings", {}) as Dictionary
		var counts := bindings.get("runtime_asset_counts", {}) as Dictionary
		if str(manifest.get("generator_sha256", "")) != GENERATOR_SHA256 \
		or str(manifest.get("registry_sha256", "")) != CAPTURE_REGISTRY_SHA256 \
		or not _numeric_structure_equal(manifest.get("runtime_topology", {}), CAPTURE_TOPOLOGY, 0.0) \
		or int(counts.get("building:r16681702:wall", -1)) != 10 \
		or int(counts.get("building:w1222720021:wall", -1)) != 10 \
		or str(bindings.get("recognition_metric", "")) != "6/213":
			return false
	if a_stills.get("stable_runtime_dependency_hashes", {}) != b_stills.get("stable_runtime_dependency_hashes", {}) \
	or a_motion.get("stable_runtime_dependency_hashes", {}) != b_motion.get("stable_runtime_dependency_hashes", {}) \
	or not _numeric_structure_equal(a_stills.get("fixed_view_definitions", []), b_stills.get("fixed_view_definitions", []), 0.000000001) \
	or not _numeric_structure_equal(a_motion.get("path_samples", []), b_motion.get("path_samples", []), 0.000000001) \
	or not _numeric_structure_equal(a_motion.get("los_samples", []), b_motion.get("los_samples", []), 0.000000001):
		return false
	for motion: Dictionary in [a_motion, b_motion, preliminary]:
		if int(motion.get("motion_physics_frames", -1)) != 529 \
		or (motion.get("path_samples", []) as Array).size() != 529 \
		or (motion.get("los_samples", []) as Array).size() != 529 \
		or not bool(motion.get("all_samples_grounded", false)) \
		or bool(motion.get("camera_orientation_changed_during_motion", true)) \
		or not bool(motion.get("wall_range_monotonically_decreased", false)) \
		or int(motion.get("player_transform_writes_after_input_began", -1)) != 0 \
		or int(motion.get("camera_transform_writes_after_input_began", -1)) != 0 \
		or bool(motion.get("sprint_used", true)) or bool(motion.get("jetpack_used", true)) \
		or bool(motion.get("manual_recovery_used", true)) or int(motion.get("recovery_delta", -1)) != 0:
			return false
	return bool(a_motion.get("movie_finalized_after_writer_close", false)) \
		and bool(b_motion.get("movie_finalized_after_writer_close", false)) \
		and not bool(preliminary.get("movie_finalized_after_writer_close", true)) \
		and str(b_motion.get("preliminary_manifest_sha256", "")) == str(EXPECTED_FILES["b-motion-preliminary-unfinalized.json"]) \
		and str(b_motion.get("salvage_finalizer_sha256", "")) == FINALIZER_SHA256 \
		and not bool(b_motion.get("recapture_performed", true)) \
		and not bool(b_motion.get("pixels_or_movie_bytes_rewritten", true)) \
		and str(combined.get("capture_time_registry_sha256", "")) == CAPTURE_REGISTRY_SHA256 \
		and int(combined.get("capture_time_building_1_runtime_asset_count_each", -1)) == 10 \
		and str(combined.get("recognition_metric_unchanged", "")) == "6/213"


func _media_matches() -> bool:
	for relative_value: Variant in EXPECTED_FILES:
		var relative := str(relative_value)
		if not relative.ends_with(".png"):
			continue
		var image := Image.load_from_file(ROOT.path_join(relative))
		if image == null or image.is_empty() or image.get_size() != Vector2i(1440, 900):
			return false
	if not _grayscale_matches("images/a/02-public-front-entrances-default-color.png", "images/a/02-public-front-entrances-default-grayscale.png") \
	or not _grayscale_matches("images/b/02-public-front-entrances-default-color.png", "images/b/02-public-front-entrances-default-grayscale.png"):
		return false
	var a := _avi(ROOT.path_join("building-1-entrance-gap-a-normal-forward-approach.avi"))
	var b := _avi(ROOT.path_join("building-1-entrance-gap-b-normal-forward-approach.avi"))
	for avi: Dictionary in [a, b]:
		if str(avi.get("container", "")) != "RIFF_AVI" or str(avi.get("codec_fourcc", "")) != "MJPG" \
		or int(avi.get("width", -1)) != 1440 or int(avi.get("height", -1)) != 900 \
		or int(avi.get("total_frames", -1)) != 337 or int(avi.get("microseconds_per_frame", -1)) != 33333 \
		or absf(float(avi.get("frame_rate_fps", 0.0)) - 30.000300003) > 0.000000001:
			return false
	var receipt := _json(ROOT.path_join("avi-container-validation.json"))
	var observations := (receipt.get("dependency_free_riff_parser", {}) as Dictionary).get("observations", {}) as Dictionary
	return str(receipt.get("status", "")) == "pass" \
		and str((receipt.get("external_file_utility", {}) as Dictionary).get("status", "")) == "pass" \
		and _avi_receipt_matches(a, observations.get("a", {}) as Dictionary, 45838270) \
		and _avi_receipt_matches(b, observations.get("b", {}) as Dictionary, 45825536)


func _sealed_post_capture_runtime_closure_matches() -> bool:
	var closure := _json(ROOT.path_join("post-capture-runtime-closure.json"))
	# This sealed file used "current_authority" when it was written. It is now
	# immutable post-capture history, not a claim about the live project files.
	var post_capture := closure.get("current_authority", {}) as Dictionary
	var invariants := closure.get("invariants", {}) as Dictionary
	var review := closure.get("independent_visual_acceptance", {}) as Dictionary
	var versions := post_capture.get("version_matrix", {}) as Dictionary
	return str(closure.get("status", "")) == "pass" \
		and str(post_capture.get("catalog_sha256", "")) == POST_CAPTURE_CATALOG_SHA256 \
		and str(post_capture.get("catalog_schema_sha256", "")) == POST_CAPTURE_SCHEMA_SHA256 \
		and str(post_capture.get("registry_sha256", "")) == POST_CAPTURE_REGISTRY_SHA256 \
		and str(post_capture.get("adapter_contracts_sha256", "")) == POST_CAPTURE_ADAPTER_CONTRACTS_SHA256 \
		and str(post_capture.get("validation_report_sha256", "")) == POST_CAPTURE_REPORT_SHA256 \
		and str(post_capture.get("compiler_path", "")) == COMPILER_PATH.trim_prefix("res://") \
		and str(post_capture.get("compiler_sha256", "")) == POST_CAPTURE_COMPILER_SHA256 \
		and str(post_capture.get("dependency_free_schema_validator_path", "")) == SCHEMA_VALIDATOR_PATH.trim_prefix("res://") \
		and str(post_capture.get("dependency_free_schema_validator_sha256", "")) == CURRENT_SCHEMA_VALIDATOR_SHA256 \
		and str(post_capture.get("loader_path", "")) == LOADER_PATH.trim_prefix("res://") \
		and str(post_capture.get("loader_sha256", "")) == POST_CAPTURE_LOADER_SHA256 \
		and str(post_capture.get("public_front_config_sha256", "")) == CURRENT_CONFIG_SHA256 \
		and int(post_capture.get("runtime_asset_count_each", -1)) == 11 \
		and str(versions.get("catalog_schema", "")) == "ti.facade-recognition-catalog/6" \
		and str(versions.get("runtime_registry_schema", "")) == "ti.facade-runtime-registry/6" \
		and str(versions.get("adapter_contract_schema", "")) == "ti.facade-runtime-adapter-contracts/5" \
		and str(versions.get("loader_api", "")) == "ti.facade-runtime-registry-loader/5" \
		and str(versions.get("compiler", "")) == "1.5.0" \
		and str(versions.get("report_schema", "")) == "ti.facade-recognition-validation-report/4" \
		and str(review.get("decision", "")) == "PASS" \
		and str(review.get("receipt_path", "")) == "INDEPENDENT_VISUAL_BAR_RAISER_REVIEW.md" \
		and str(review.get("receipt_sha256", "")) == INDEPENDENT_REVIEW_SHA256 \
		and str(review.get("recognition_metric_unchanged", "")) == "6/213" \
		and str(invariants.get("accepted_reference_recognition_metric", "")) == "6/213" \
		and bool(invariants.get("catalog_schema_version_changed", false)) \
		and _numeric_structure_equal(invariants.get("world_topology", {}), CAPTURE_TOPOLOGY, 0.0)


func _current_runtime_bridge_matches() -> bool:
	if FileAccess.get_sha256(CONFIG_PATH) != CURRENT_CONFIG_SHA256 \
	or FileAccess.get_sha256(CATALOG_PATH) != CURRENT_CATALOG_SHA256 \
	or FileAccess.get_sha256(SCHEMA_PATH) != CURRENT_SCHEMA_SHA256 \
	or FileAccess.get_sha256(REGISTRY_PATH) != CURRENT_REGISTRY_SHA256 \
	or FileAccess.get_sha256(ADAPTER_CONTRACTS_PATH) != CURRENT_ADAPTER_CONTRACTS_SHA256 \
	or FileAccess.get_sha256(REPORT_PATH) != CURRENT_REPORT_SHA256 \
	or FileAccess.get_sha256(COMPILER_PATH) != CURRENT_COMPILER_SHA256 \
	or FileAccess.get_sha256(SCHEMA_VALIDATOR_PATH) != CURRENT_SCHEMA_VALIDATOR_SHA256 \
	or FileAccess.get_sha256(LOADER_PATH) != CURRENT_LOADER_SHA256:
		return false
	if not FileAccess.get_file_as_string(CONFIG_PATH).contains("\"entrance_group_gap\": 0.90"):
		return false
	var registry := _json(REGISTRY_PATH)
	var adapter_contracts := _json(ADAPTER_CONTRACTS_PATH)
	var metric := registry.get("recognition_metric", {}) as Dictionary
	var compatibility := registry.get("compatibility_contract", {}) as Dictionary
	var loader_contract := adapter_contracts.get("loader_contract", {}) as Dictionary
	if str(registry.get("schema_version", "")) != "ti.facade-runtime-registry/7" \
	or str(compatibility.get("catalog_schema_version", "")) != "ti.facade-recognition-catalog/7" \
	or str(compatibility.get("compiler_version", "")) != "1.6.0" \
	or str(compatibility.get("loader_api_version", "")) != "ti.facade-runtime-registry-loader/6" \
	or str(adapter_contracts.get("schema_version", "")) != "ti.facade-runtime-adapter-contracts/6" \
	or str(loader_contract.get("api_version", "")) != "ti.facade-runtime-registry-loader/6" \
	or str(loader_contract.get("loader_sha256", "")) != CURRENT_LOADER_SHA256 \
	or int(metric.get("numerator", -1)) != 7 or int(metric.get("denominator", -1)) != 213 or str(metric.get("display", "")) != "7/213":
		return false
	var accepted_unit_ids := metric.get("accepted_physical_unit_ids", []) as Array
	if accepted_unit_ids.size() != 7:
		return false
	for receiver_value: Variant in CURRENT_RECOGNITION_RECEIPTS:
		var receiver_key := str(receiver_value)
		var expected := CURRENT_RECOGNITION_RECEIPTS[receiver_value] as Dictionary
		var unit_id := str(expected.get("unit_id", ""))
		var adapter := _adapter_for(registry.get("active_runtime_adapters", []) as Array, receiver_key)
		var assets := adapter.get("runtime_assets", []) as Array
		var contract := adapter.get("active_runtime_contract", {}) as Dictionary
		var scope := adapter.get("active_receiver_scope", {}) as Dictionary
		var unit := _unit_for(registry.get("units", []) as Array, unit_id)
		var claim := unit.get("claim_status", {}) as Dictionary
		if assets.size() != 11 or not (adapter.get("runtime_asset_projections", []) as Array).is_empty() \
		or str(contract.get("public_front_config_sha256", "")) != CURRENT_CONFIG_SHA256 \
		or not _has_asset(assets, CONFIG_PATH, CURRENT_CONFIG_SHA256) \
		or str(scope.get("coverage", "")) != "whole_direct_wall_receiver" \
		or int(scope.get("run_count", -1)) != int(expected.get("run_count", -1)) \
		or str(adapter.get("review_status", "")) != "pending_independent_original_detail_review" \
		or str(adapter.get("review_status_scope", "")) != "runtime_asset_original_detail_provenance_only_not_reference_recognition" \
		or str(adapter.get("recognition_acceptance_authority", "")) != "physical_unit_claim_and_independent_acceptance_record" \
		or str(claim.get("reference_recognizable", "")) != "accepted" \
		or str(adapter.get("recognition_acceptance_status", "")) != str(claim.get("reference_recognizable", "")) \
		or unit_id not in accepted_unit_ids \
		or not _has_acceptance_receipt(unit, str(expected.get("review_receipt_sha256", "")), str(expected.get("evidence_manifest_sha256", ""))):
			return false
	return true


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


func _has_asset(assets: Array, path: String, sha256: String) -> bool:
	for value: Variant in assets:
		var asset := value as Dictionary
		if str(asset.get("path", "")) == path and str(asset.get("sha256", "")) == sha256:
			return true
	return false


func _grayscale_matches(color_relative: String, grayscale_relative: String) -> bool:
	var color := Image.load_from_file(ROOT.path_join(color_relative))
	var grayscale := Image.load_from_file(ROOT.path_join(grayscale_relative))
	if color == null or grayscale == null or color.is_empty() or grayscale.is_empty():
		return false
	color.convert(Image.FORMAT_L8)
	grayscale.convert(Image.FORMAT_L8)
	return color.get_size() == Vector2i(1440, 900) and color.get_data() == grayscale.get_data()


func _avi(path: String) -> Dictionary:
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.size() < 48 or _ascii(bytes, 0, 4) != "RIFF" or _ascii(bytes, 8, 4) != "AVI ":
		return {}
	var avih := _fourcc(bytes, "avih")
	var strh := _fourcc(bytes, "strh")
	if avih < 0 or avih + 48 > bytes.size() or strh < 0 or strh + 16 > bytes.size() \
	or _ascii(bytes, strh + 8, 4) != "vids":
		return {}
	var micros := int(bytes.decode_u32(avih + 8))
	var frames := int(bytes.decode_u32(avih + 24))
	return {
		"container": "RIFF_AVI",
		"codec_fourcc": _ascii(bytes, strh + 12, 4),
		"width": int(bytes.decode_u32(avih + 40)),
		"height": int(bytes.decode_u32(avih + 44)),
		"total_frames": frames,
		"microseconds_per_frame": micros,
		"frame_rate_fps": 1000000.0 / float(micros),
		"duration_seconds_from_avih": float(frames * micros) / 1000000.0,
	}


func _avi_receipt_matches(observed: Dictionary, receipt: Dictionary, size_bytes: int) -> bool:
	return str(receipt.get("codec_fourcc", "")) == str(observed.get("codec_fourcc", "")) \
		and int(receipt.get("width", -1)) == int(observed.get("width", -2)) \
		and int(receipt.get("height", -1)) == int(observed.get("height", -2)) \
		and int(receipt.get("total_frames", -1)) == int(observed.get("total_frames", -2)) \
		and int(receipt.get("microseconds_per_frame", -1)) == int(observed.get("microseconds_per_frame", -2)) \
		and int(receipt.get("size_bytes", -1)) == size_bytes \
		and absf(float(receipt.get("frame_rate_fps", 0.0)) - float(observed.get("frame_rate_fps", -1.0))) <= 0.000000001 \
		and absf(float(receipt.get("duration_seconds_from_avih", 0.0)) - float(observed.get("duration_seconds_from_avih", -1.0))) <= 0.000000001


func _fourcc(bytes: PackedByteArray, value: String) -> int:
	var needle := value.to_ascii_buffer()
	for offset in range(0, bytes.size() - needle.size() + 1):
		var matched := true
		for index in needle.size():
			if bytes[offset + index] != needle[index]:
				matched = false
				break
		if matched:
			return offset
	return -1


func _ascii(bytes: PackedByteArray, offset: int, length: int) -> String:
	if offset < 0 or offset + length > bytes.size():
		return ""
	return bytes.slice(offset, offset + length).get_string_from_ascii()


func _numeric_structure_equal(left: Variant, right: Variant, tolerance: float) -> bool:
	if left is Array and right is Array:
		if left.size() != right.size():
			return false
		for index in left.size():
			if not _numeric_structure_equal(left[index], right[index], tolerance):
				return false
		return true
	if left is Dictionary and right is Dictionary:
		if left.size() != right.size():
			return false
		for key: Variant in left:
			if not right.has(key) or not _numeric_structure_equal(left[key], right[key], tolerance):
				return false
		return true
	if left is float or left is int:
		return (right is float or right is int) and absf(float(left) - float(right)) <= tolerance
	return left == right


func _json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _require(condition: bool, message: String) -> bool:
	if not condition:
		_failed = true
		push_error(message)
	return condition
