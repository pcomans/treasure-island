extends "res://game/tests/headless_building_1_wing_returns_v2_candidate_evidence_contract.gd"

## Current metadata is validated exactly, then projected in memory to the frozen
## candidate metadata solely to reuse every inherited pixel/pose/motion predicate.
## Neither historical nor fresh manifest bytes are rewritten by that projection.
const CURRENT_RECEIPT_NAME := "current-release-verification-receipt.json"
const CURRENT_CAPTURE_SHA256 := "e93d3899ff05f1ce8f15b0bfb79a96fab06cab97b81a4073c30cc291d205c632"
var _checking_current := false
var _reference_template: Dictionary = {}

const RELEASE_BINDING_SHA256 := "a9fb95a17c1cbe3b7d9e1d29465a5df3f08ac364d83b80aa58f8f0ea09993cdc"
var _release_bound: Dictionary = {}


func _release_argument(prefix: String) -> String:
	for value: String in OS.get_cmdline_user_args():
		if value.begins_with(prefix):
			return value.trim_prefix(prefix)
	return ""


func _release_sha_is_sealed(value: String) -> bool:
	return value.length() == 64 and value.is_valid_hex_number(false)


func _release_repo_file_matches(item: Dictionary) -> bool:
	var relative := str(item.get("path", ""))
	var expected := str(item.get("sha256", ""))
	return not relative.is_empty() and not relative.is_absolute_path() and not relative.contains("..") \
		and _release_sha_is_sealed(expected) and FileAccess.file_exists("res://" + relative) \
		and FileAccess.get_sha256("res://" + relative) == expected


func _release_file_paths(directory: String, prefix: String = "") -> Array[String]:
	var access := DirAccess.open(directory)
	if access == null:
		return ["__invalid_directory__"]
	access.include_hidden = true
	var result: Array[String] = []
	for name: String in access.get_files():
		if access.is_link(name):
			return ["__forbidden_symlink__"]
		result.append(prefix + name)
	for name: String in access.get_directories():
		if access.is_link(name):
			return ["__forbidden_symlink__"]
		result.append_array(_release_file_paths(directory.path_join(name), prefix + name + "/"))
	result.sort()
	return result


func _release_command_is_fixed60(command: String, executable: String) -> bool:
	# Engine flags are consumed before OS.get_cmdline_args(). Fixed60 must be
	# first, outside every pathname and user argument, in this exact invocation.
	var project_path := ProjectSettings.globalize_path("res://").trim_suffix("/")
	var script_path := ProjectSettings.globalize_path(get_script().resource_path)
	if executable.is_empty() or not script_path.is_absolute_path() or command.contains("\n"):
		return false
	var users := OS.get_cmdline_user_args()
	var suffix := " -- " + " ".join(users) if not users.is_empty() else ""
	var first := executable + " --fixed-fps 60 "
	var capture := first + "--path " + project_path \
		+ " --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script " + script_path + suffix
	var no_render_probe := first + "--headless --path " + project_path + " --script " + script_path + suffix
	return command == capture or command == no_render_probe


func _release_owned_launch_is_fixed60() -> bool:
	var output: Array = []
	var result := OS.execute("/bin/ps", ["-ww", "-p", str(OS.get_process_id()), "-o", "command="], output, true)
	return result == 0 and output.size() == 1 \
		and _release_command_is_fixed60(str(output[0]).strip_edges(), OS.get_executable_path())


func _release_preflight(require_fixed_fps: bool) -> Dictionary:
	# This first guard applies uniformly before every inherited capture mode.
	if not _release_sha_is_sealed(RELEASE_BINDING_SHA256):
		return {}
	var path := _release_argument("--release-binding=")
	if not path.is_absolute_path() or not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != RELEASE_BINDING_SHA256:
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		return {}
	var binding := parsed as Dictionary
	if str(binding.get("schema_version", "")) != "ti.building-1-wing-returns-v2-current-release-binding/1" \
	or not FileAccess.file_exists("res://project.godot") or FileAccess.file_exists("res://project.binary"):
		return {}
	var reviews := binding.get("reviews", []) as Array
	if reviews.size() != 2:
		return {}
	for review: Dictionary in reviews:
		if not _release_repo_file_matches(review) or not str(review.get("token", "")).begins_with("PASS_FOR_") \
		or not FileAccess.get_file_as_string("res://" + str(review.path)).contains(str(review.token)):
			return {}
	var audited := binding.get("audited_files", []) as Array
	var parents := binding.get("parent_files", []) as Array
	if audited.size() != 51 or parents.size() != 3:
		return {}
	for item: Dictionary in audited + parents:
		if not _release_repo_file_matches(item):
			return {}
	var app_relative := str(binding.get("app_relative_path", ""))
	var app_files := binding.get("app_files", []) as Array
	if not app_relative.begins_with("build/") or app_relative.contains("..") or app_files.size() != 7:
		return {}
	var expected_app_paths: Array[String] = []
	for item: Dictionary in app_files:
		expected_app_paths.append(str(item.get("path", "")))
	expected_app_paths.sort()
	if _release_file_paths("res://" + app_relative) != expected_app_paths:
		return {}
	for item: Dictionary in app_files:
		var file := {"path": app_relative + "/" + str(item.get("path", "")), "sha256": item.get("sha256", "")}
		if not _release_repo_file_matches(file):
			return {}
		var opened := FileAccess.open("res://" + str(file.path), FileAccess.READ)
		if opened == null or opened.get_length() != int(item.get("bytes", -1)):
			return {}
	var proofs := binding.get("package_receipts", []) as Array
	if proofs.size() != 2:
		return {}
	for item: Dictionary in proofs:
		var proof_path := str(item.get("path", ""))
		var expected := str(item.get("sha256", ""))
		if not _release_sha_is_sealed(expected) or not proof_path.is_absolute_path() \
		or not FileAccess.file_exists(proof_path) or FileAccess.get_sha256(proof_path) != expected:
			return {}
		var proof_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(proof_path))
		if not proof_value is Dictionary:
			return {}
		var proof := proof_value as Dictionary
		if str(proof.get("status", "")) != str(item.get("token", "")) \
		or str(proof.get("status", "")) != "PASS_FOR_B1_RETURNS_V2_CURRENT_PACKAGE_REVIEW" \
		or proof.get("inputs_before", {}) != proof.get("inputs_after", {}) \
		or not bool(proof.get("all_owned_processes_terminal", false)):
			return {}
		for mode in ["headless", "native"]:
			var smoke := (proof.get("complete_internal_smokes", {}) as Dictionary).get(mode, {}) as Dictionary
			if not bool(smoke.get("full_internal_smoke_pass", false)) or not bool(smoke.get("player_grounded", false)):
				return {}
	var reference := binding.get("accepted_reference", {}) as Dictionary
	var reference_receipt := {"path": str(reference.get("root_relative_path", "")) + "/" + str(reference.get("acceptance_receipt_path", "")), "sha256": reference.get("acceptance_receipt_sha256", "")}
	if not _release_repo_file_matches(reference_receipt):
		return {}
	if require_fixed_fps and not _release_owned_launch_is_fixed60():
		return {}
	_release_bound = binding
	return binding


func _release_metadata(generator_sha256: String) -> Dictionary:
	var metadata := (_release_bound.get("current_manifest_metadata", {}) as Dictionary).duplicate(true)
	metadata["generator_sha256"] = generator_sha256
	var provenance := metadata.get("release_binding", {}) as Dictionary
	provenance["binding_sha256"] = RELEASE_BINDING_SHA256
	metadata["release_binding"] = provenance
	return metadata


func _run() -> void:
	var root_path := _argument("--capture-root=")
	var mode := _argument("--receipt-mode=")
	if not root_path.is_absolute_path() or mode not in ["create", "verify"]:
		_fail("Pass an absolute --capture-root and --receipt-mode=create or verify.")
		_finish()
		return
	var result := _validate(root_path, mode)
	if not bool(result.get("ok", false)):
		_fail(str(result.get("message", "Current release evidence validation failed.")))
		_finish()
		return
	var receipt_path := root_path.path_join(CURRENT_RECEIPT_NAME)
	var receipt_text := JSON.stringify(result.receipt, "  ", false) + "\n"
	var receipt_sha := _sha256_text(receipt_text)
	if mode == "create":
		if FileAccess.file_exists(receipt_path) or not _write_new(receipt_path, receipt_text) or FileAccess.get_sha256(receipt_path) != receipt_sha:
			_fail("Could not create the exact current release receipt once.")
			_finish()
			return
	else:
		var expected_receipt_sha := _argument("--receipt-sha256=")
		if expected_receipt_sha.length() != 64 or FileAccess.get_sha256(receipt_path) != expected_receipt_sha \
		or expected_receipt_sha != receipt_sha or FileAccess.get_file_as_string(receipt_path) != receipt_text:
			_fail("Existing current release receipt is missing, drifted, or not exactly reproducible.")
			_finish()
			return
	print("PASS: current B1 release source evidence is exact: 46 fresh PNGs + 3 manifests; accepted v2 originals unchanged, inherited pose/controller/light/grayscale checks pass; receipt=%s" % receipt_sha)
	_finish()



func _validate(root_path: String, mode: String) -> Dictionary:
	if not _release_sha_is_sealed(CURRENT_CAPTURE_SHA256) or _release_preflight(false).is_empty():
		return _bad("Current release binding/audits/app/proofs are unsealed or changed.")
	var capture_program := _release_argument("--capture-program=")
	if not capture_program.is_absolute_path() or FileAccess.get_sha256(capture_program) != CURRENT_CAPTURE_SHA256:
		return _bad("Exact current capture wrapper is missing or changed.")
	if not root_path.begins_with("/private/tmp/b1-returns-v2-current-release-"):
		return _bad("Current capture root is outside its isolated prefix.")
	var evidence_paths: Array[String] = []
	for path: String in super._expected_paths():
		if path.begins_with("stages/candidate/"):
			evidence_paths.append(path)
	var expected_paths := evidence_paths.duplicate()
	if mode == "verify":
		expected_paths.append(CURRENT_RECEIPT_NAME)
		expected_paths.sort()
	if evidence_paths.size() != 49 or _relative_files(root_path) != expected_paths:
		return _bad("Fresh current evidence inventory is not exactly 46 PNGs and 3 manifests.")
	var reference := _release_bound.get("accepted_reference", {}) as Dictionary
	var reference_root := "res://" + str(reference.get("root_relative_path", ""))
	var reference_inventory := _inventory(reference_root, evidence_paths)
	if not _release_inventory_matches(reference_inventory, reference.get("inputs", [])):
		return _bad("The 49 accepted v2 reference inputs changed; do not rewrite or recapture them.")
	var current_manifests := {}
	var reference_manifests := {}
	for name in ["stills", "motion-north", "motion-south"]:
		var relative := "stages/candidate/%s.json" % name
		var current := _json(root_path.path_join(relative))
		var accepted := _json(reference_root.path_join(relative))
		if current.is_empty() or accepted.is_empty() or _contains_absolute_string(current) or _contains_absolute_string(accepted):
			return _bad("A manifest is missing, invalid or contains an absolute path.")
		current_manifests[name] = current
		reference_manifests[name] = accepted
	_reference_template = reference_manifests.stills as Dictionary
	_checking_current = false
	if not _stills_valid(reference_root, _reference_template, "candidate"):
		return _bad("Accepted v2 stills no longer satisfy the frozen verifier.")
	for side in ["north", "south"]:
		if not _motion_valid(reference_root, reference_manifests["motion-" + side] as Dictionary, "candidate", side):
			return _bad("Accepted v2 motion no longer satisfies the frozen verifier.")
	_checking_current = true
	if not _stills_valid(root_path, current_manifests.stills as Dictionary, "candidate") \
	or not _stills_pair_valid(_reference_template, current_manifests.stills as Dictionary):
		return _bad("Current still/camera/light/gray/spray/landing/context comparison failed at unchanged tolerances.")
	var max_motion_pose_delta := 0.0
	for side in ["north", "south"]:
		var current := current_manifests["motion-" + side] as Dictionary
		if not _motion_valid(root_path, current, "candidate", side):
			return _bad("Current fixed-60 motion failed the inherited verifier.")
		var pair := _motion_pair_valid(reference_manifests["motion-" + side] as Dictionary, current)
		if not bool(pair.get("ok", false)):
			return _bad("Current versus accepted motion comparison failed: %s" % pair.get("message", "unknown"))
		max_motion_pose_delta = maxf(max_motion_pose_delta, float(pair.max_pose_delta_m))
	var inventory := _inventory(root_path, evidence_paths)
	if inventory.size() != 49:
		return _bad("Fresh current inputs could not be hashed exactly.")
	var tree := ""
	var total_bytes := 0
	var pixel_comparison := []
	var identical_pngs := 0
	for index in inventory.size():
		var item := inventory[index] as Dictionary
		var original := reference_inventory[index] as Dictionary
		tree += "%s|%s|%d\n" % [item.path, item.sha256, int(item.bytes)]
		total_bytes += int(item.bytes)
		if str(item.path).ends_with(".png"):
			var equal_bytes := str(item.sha256) == str(original.sha256)
			identical_pngs += 1 if equal_bytes else 0
			pixel_comparison.append({"path": item.path, "accepted_sha256": original.sha256, "current_sha256": item.sha256, "byte_identical": equal_bytes})
	var receipt := {
		"schema_version": "ti.building-1-wing-returns-v2-current-release-verification/1",
		"packet_id": _release_bound.packet_id,
		"status": "PASS_FOR_INDEPENDENT_CURRENT_RELEASE_EVIDENCE_REVIEW",
		"recognition_metric": "9/213", "recognition_credit_delta": 0,
		"independent_release_visual_review_pending": true,
		"source_renders_are_package_pixels": false,
		"release_binding_sha256": RELEASE_BINDING_SHA256,
		"release_provenance": (_release_metadata(CURRENT_CAPTURE_SHA256).release_binding as Dictionary),
		"capture_generator": "building_1_wing_returns_v2_current_release_capture.gd",
		"capture_generator_sha256": CURRENT_CAPTURE_SHA256,
		"evidence_verifier": "headless_building_1_wing_returns_v2_current_release_evidence_contract_004.gd",
		"evidence_verifier_sha256": FileAccess.get_sha256(get_script().resource_path),
		"counts": {"fresh_pngs": 46, "fresh_manifests": 3, "fresh_inputs": 49, "accepted_reference_pngs": 46, "accepted_reference_manifests": 3},
		"accepted_reference": reference,
		"reference_files_recaptured": false, "reference_manifests_rewritten": false,
		"metadata_projection": "Only already-validated current provenance fields are projected in memory to their immutable reference values so inherited capture-mechanics predicates remain unchanged; no file is rewritten.",
		"pairing": {"static_tolerance": PAIR_FLOAT_TOLERANCE, "motion_pose_tolerance_m": POSE_TOLERANCE_M, "observed_max_motion_pose_delta_m": max_motion_pose_delta, "lights_views_and_controller_ticks_match_inherited_contract": true},
		"pixel_hash_comparison": pixel_comparison, "byte_identical_png_pairs": identical_pngs,
		"pixel_hash_equality_is_not_a_visual_acceptance_gate": true,
		"current_input_inventory": inventory, "current_input_total_bytes": total_bytes,
		"current_input_tree_sha256": _sha256_text(tree),
	}
	return {"ok": true, "receipt": receipt}


func _common_manifest_valid(manifest: Dictionary, stage: String) -> bool:
	if not _checking_current:
		return super._common_manifest_valid(manifest, stage)
	var expected := _release_metadata(CURRENT_CAPTURE_SHA256)
	for key: String in expected:
		if not manifest.has(key) or typeof(manifest[key]) != typeof(expected[key]) or manifest[key] != expected[key]:
			return false
	var projected := manifest.duplicate(true)
	for key: String in expected:
		if _reference_template.has(key):
			projected[key] = _reference_template[key]
		else:
			projected.erase(key)
	return super._common_manifest_valid(projected, stage)


func _release_inventory_matches(actual: Array[Dictionary], expected: Variant) -> bool:
	# JSON parses integral byte values as floats; compare exact validated values,
	# preserving order/schema and rejecting coercion or fractional counts.
	if not expected is Array or actual.size() != 49 or expected.size() != 49:
		return false
	for index in 49:
		if not expected[index] is Dictionary:
			return false
		var observed := actual[index] as Dictionary
		var pinned := expected[index] as Dictionary
		for item: Dictionary in [observed, pinned]:
			if item.size() != 3 or not item.has("path") or not item.has("sha256") or not item.has("bytes") \
			or not item.path is String or not item.sha256 is String:
				return false
		if observed.path != pinned.path or observed.sha256 != pinned.sha256 \
		or not _release_sha_is_sealed(pinned.sha256) or not observed.bytes is int or observed.bytes < 0:
			return false
		var count: Variant = pinned.bytes
		if not count is int and not count is float:
			return false
		if count is float and (not is_finite(count) or count > 9007199254740991.0 or count != floor(count)):
			return false
		if count < 0 or int(count) != observed.bytes:
			return false
	return true
