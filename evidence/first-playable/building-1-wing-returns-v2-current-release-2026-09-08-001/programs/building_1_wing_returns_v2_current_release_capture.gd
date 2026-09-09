extends "res://game/tests/building_1_wing_returns_v2_candidate_capture.gd"

## External current-release provenance wrapper. Every camera, controller, lighting,
## grayscale, spray, landing and image-writing method is inherited unchanged.

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


func _source_and_provenance_match(stage: String) -> bool:
	if _release_preflight(true).is_empty() or stage != "candidate":
		return false
	var output_root := _release_argument("--output-root=")
	var generator := _release_argument("--generator=")
	var generator_sha256 := _release_argument("--generator-sha256=")
	var actual_script := ProjectSettings.globalize_path(get_script().resource_path)
	return output_root.begins_with("/private/tmp/b1-returns-v2-current-release-") \
		and generator.is_absolute_path() and generator == actual_script \
		and _release_sha_is_sealed(generator_sha256) and FileAccess.get_sha256(generator) == generator_sha256


func _common_manifest(stage: String, bindings: Dictionary, runtime: Variant) -> Dictionary:
	var result := super._common_manifest(stage, bindings, runtime)
	var current := _release_metadata(_release_argument("--generator-sha256="))
	for key: String in current:
		result[key] = current[key]
	return result
