extends SceneTree

## One-shot recovery for a truthful capture that was stopped by an overly
## strict JSON float read-back comparison. This script never renders, captures,
## or rewrites pixels/movie bytes. It validates the entire frozen A/B closure,
## preserves the preliminary B manifest byte-for-byte, promotes the already
## closed B pending AVI once, and writes the final B/combined receipts.

const ROOT := "res://evidence/first-playable/building-1-entrance-group-gap-calibration-2026-09-04"
const GENERATOR := "res://game/tests/building_1_entrance_gap_calibration_capture.gd"
const PARENT_HARNESS := "res://game/tests/building_1_public_front_believability_capture.gd"
const CONFIG := "res://game/resources/facades/building_1_public_front_believability.json"
const REGISTRY := "res://game/resources/facades/facade-runtime-registry.json"
const OVERRIDE := "res://override.cfg"
const GENERATOR_SHA256 := "b1565b71cbda76a8c63204b18d7cac99ad78a6882667bafcd798de5b8dbaf160"
const PARENT_SHA256 := "763bc0aa3ba95e7fa2f82ae0e897bbdadd42391f2c0afe13387c828701c96e0e"
const A_CONFIG_SHA256 := "fd434eb472f61d93408732841e5993881b23238af8c0518b59181ac0ea535e32"
const B_CONFIG_SHA256 := "7b53847c627d6f0a0d4ebefcc790e8fd3bcaeee6fbdebbf5c6a85f2aeb4a5806"
const CAPTURE_REGISTRY_SHA256 := "36eef28d1abce9d9838da6e959222ad6767e40e198b90b734496e6d2dc2cd79b"
const OVERRIDE_SHA256 := "edbc0b9caa60fa0fc6b83cebb3145bce11ce0bd976403ca1d2fbe9b7142b39c3"
const A_STILLS_SHA256 := "d0193298acb3068722ba63ce6858b698296d4b93a1d75a2b410dd7890b2f2a74"
const A_MOTION_SHA256 := "8fe4e052bdb0a5c1c89eb5103bfdb3b7a58169a77d3d32bf6c998d92a6181ba8"
const B_STILLS_SHA256 := "9468170d4f93153c2fe8ae5b282bd99d46bcbd941a4e420072a6068d5c1e0e2a"
const B_PRELIMINARY_SHA256 := "5e541a144aee83d19a26f364454b5bed7b7659a18bdcaff96d9db0f530a26040"
const A_MOVIE_SHA256 := "cf51e56538ba640b083d67c12d3f79e9f1864b57f70cf3ba0015e76c7a66b6ff"
const B_MOVIE_SHA256 := "318718deb113bc9d639db6bed28cd0e8eb30459c3b7754fe39dba5728b6a1e82"
const A_MOVIE_BYTES := 45838270
const B_MOVIE_BYTES := 45825536
const EXPECTED_TOPOLOGY := {"rows": 735, "meshes": 944, "surfaces": 957, "triangles": 64572, "bodies": 466, "shapes": 466}
const EXPECTED_B1_TOPOLOGY := {"meshes": 13, "surfaces": 13, "triangles": 10711, "bodies": 4, "shapes": 4}
const EXPECTED_COMPONENT_TOPOLOGY := {
	"building:r16681702:wall": {"meshes": 6, "surfaces": 6, "triangles": 8806, "bodies": 1, "shapes": 1, "source_keys": ["r16681702"]},
	"building:r16681702:roof": {"meshes": 3, "surfaces": 3, "triangles": 1131, "bodies": 1, "shapes": 1, "source_keys": ["r16681702"]},
	"building:w1222720021:wall": {"meshes": 3, "surfaces": 3, "triangles": 760, "bodies": 1, "shapes": 1, "source_keys": ["w1222720021"]},
	"building:w1222720021:roof": {"meshes": 1, "surfaces": 1, "triangles": 14, "bodies": 1, "shapes": 1, "source_keys": ["w1222720021"]},
}
const EXPECTED_RUNTIME_DEPENDENCY_HASHES := {
	"res://game/tests/building_1_public_front_believability_capture.gd": "763bc0aa3ba95e7fa2f82ae0e897bbdadd42391f2c0afe13387c828701c96e0e",
	"res://game/scripts/player/player_controller.gd": "8b114132d66c78dd0bfd09783c7b9a3a3a441a8b1ae14f33f7308bd9b04ed0ea",
	"res://game/scripts/player/player_camera.gd": "90ea739b25eb6cbcf8bacff072599b117fe894fcef08683483e41527d8019636",
	"res://game/scenes/main.tscn": "959a0f8a14057ea8402790ba374c7839d5f9835ce20ad194846f0a4d45b43d66",
	"res://game/scripts/main.gd": "d948c8e4900ac88cfe4d40a701eedbbe2070df42c2414e39f2e9b8112d92620f",
	"res://game/scripts/world/facades/facade_runtime_registry_loader.gd": "5975480c124cb3dd4b4f61a2099e284286d7c5c6b808f4c7ecef1cd7b5332395",
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://generated/world/chunks/x_-1__z_2.json": "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce",
	"res://generated/world/chunks/x_0__z_2.json": "886f4e6ecfbf570dac9cb36f682a089a0cfe51b735692e3220df4d5b4ac3d7b6",
	"res://project.godot": "305bfb3bf0493c485f48ea8a01d4effccb58d9dd74ad6dc9be78a64ed23981af",
	"res://game/resources/facades/building_1_hero_model.json": "f10bc92a6e74cbae41347e742e6c68c50faccddbd52ab3ecce210ac8243bc6e9",
	"res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres": "12d059d9d806c629225254f1aaf945be69a00ce5878db276ce299ad0c8cdbb9a",
	"res://game/resources/materials/world/building_1/building_1_light_trim.tres": "6e543d57ff078c267e952f633f4cee232e0743e30218d2f341dc3f31e4a4c8d9",
	"res://game/resources/materials/world/building_1/building_1_bluegrey_glass.tres": "41c1c31d4a78da25d4abfac59e82fe919fbb539afa479ab7601d0fb51939d59f",
	"res://game/resources/materials/world/building_1/building_1_bronze.tres": "7948c9fca74345f4ff5e57a44191beb59300847b66cc54ddc176c5ca1b315ca3",
	"res://game/resources/materials/world/building_1/building_1_roof_metal.tres": "8bee442442f8b7bc3004cd3f703ce4e21eb9bc3b1f4d3d8800b02a77268329c8",
	"res://game/resources/materials/world/building_1/building_1_projecting_base_stone.tres": "8bdd85aa10ac78c9225c59aad5ed9d26266ae517ea3f5910b8be3daf41f131ab",
	"res://game/resources/materials/world/building_1/building_1_reveal_shadow.tres": "2e1f36f163c037fe060a1ecfcdcc5dd062849290a96c508970384585b176e14a",
	"res://game/resources/materials/world/building_1/building_1_canopy_underside.tres": "661a7b8cfaef2394e47a42f9bbd04df5fdfbb2cd4be9e6733d5bf3101817cea9",
	"res://game/scripts/world/facades/building_1_hero_model.gd": "e5b11fc7f971ea33bb38c84d3106f8883de0486774f58a5a8310d49d56aa55a5",
	"res://game/scripts/world/world_chunk_builder.gd": "d3d3dc1ba3aace541dc07ce437d242787ce2e4efe66877368ac2907e3facf17c",
}
const EXPECTED_ACCEPTED_IDS := [
	"physical-building:r16681702", "physical-building:w1222720021",
	"physical-building:w1249412093", "physical-building:w1249412094",
	"physical-building:w291189336", "physical-building:w34313540",
]
const EXPECTED_IMAGES := {
	"images/a/01-public-front-whole-default-color.png": "d2189c1b70d0368f53de624d45f4cf41436b4f8972ae4e34afcd1045efd93c91",
	"images/a/01-public-front-whole-changed-light-color.png": "404583d92ba176b97d77c40f52890241ed459fb07ce5db91e545feeb5098f346",
	"images/a/02-public-front-entrances-default-color.png": "4ea83c8a367e9c2a0b63f2e395241cc6daa62381c3c3992b9769cbdb33a19e9d",
	"images/a/02-public-front-entrances-default-grayscale.png": "3382d7dceb216453bfbd1c87fc7c8f9c916b368656e3e84339b606a5ba2dc9d5",
	"images/b/01-public-front-whole-default-color.png": "04f287178f125645dd2205feb619e08379b18e5d5784b2e7d4baf4fddfa45c09",
	"images/b/01-public-front-whole-changed-light-color.png": "cd569f5452b0f34124e0cd09dd53a885a089a402741229a591cb2fc47d892c55",
	"images/b/02-public-front-entrances-default-color.png": "dee2b8c3a41b1cd95d2f4c364e9d98faf333316e888897221855356ad1b6e686",
	"images/b/02-public-front-entrances-default-grayscale.png": "5db49499ed724bcde9d69c1ba4e7325f3a4f33bfd4d236051a3b5c211ae23dad",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var mode := _argument("--salvage-mode=")
	if mode not in ["validate", "commit"]:
		_fail("Pass --salvage-mode=validate or --salvage-mode=commit.")
		_finish()
		return
	var state := _validate_frozen_inputs()
	if not bool(state.get("ok", false)):
		_fail(str(state.get("message", "Frozen capture validation failed.")))
		_finish()
		return
	if mode == "validate":
		print("PASS: frozen Building 1 A/B bytes are salvageable without recapture; preliminary B remains %s" % B_PRELIMINARY_SHA256)
		_finish()
		return
	_commit_once(state)
	_finish()


func _validate_frozen_inputs() -> Dictionary:
	if FileAccess.get_sha256(GENERATOR) != GENERATOR_SHA256 \
	or FileAccess.get_sha256(PARENT_HARNESS) != PARENT_SHA256 \
	or FileAccess.get_sha256(CONFIG) != B_CONFIG_SHA256 \
	or FileAccess.get_sha256(REGISTRY) != CAPTURE_REGISTRY_SHA256 \
	or FileAccess.get_sha256(OVERRIDE) != OVERRIDE_SHA256:
		return {"ok": false, "message": "Generator/config/capture-registry/override closure drifted."}
	var config := _json(CONFIG)
	if not is_equal_approx(float((config.get("geometry_production_inference_m", {}) as Dictionary).get("entrance_group_gap", -1.0)), 0.90) \
	or FileAccess.get_file_as_bytes(CONFIG).size() != 4020:
		return {"ok": false, "message": "Candidate config is not literal 0.90 / 4,020-byte authority."}
	var a_stills_path := ROOT.path_join("a-stills.json")
	var a_motion_path := ROOT.path_join("a-motion.json")
	var b_stills_path := ROOT.path_join("b-stills.json")
	var b_preliminary_path := _preliminary_path()
	if FileAccess.get_sha256(a_stills_path) != A_STILLS_SHA256 \
	or FileAccess.get_sha256(a_motion_path) != A_MOTION_SHA256 \
	or FileAccess.get_sha256(b_stills_path) != B_STILLS_SHA256 \
	or FileAccess.get_sha256(b_preliminary_path) != B_PRELIMINARY_SHA256:
		return {"ok": false, "message": "One of the four frozen capture manifests drifted."}
	for path: String in EXPECTED_IMAGES:
		if FileAccess.get_sha256(ROOT.path_join(path)) != str(EXPECTED_IMAGES[path]):
			return {"ok": false, "message": "Frozen image drifted: %s." % path}
		var image := Image.load_from_file(ROOT.path_join(path))
		if image == null or image.is_empty() or image.get_size() != Vector2i(1440, 900):
			return {"ok": false, "message": "Frozen image is not a decoded 1440x900 frame: %s." % path}
	if not _grayscale_matches("images/a/02-public-front-entrances-default-color.png", "images/a/02-public-front-entrances-default-grayscale.png") \
	or not _grayscale_matches("images/b/02-public-front-entrances-default-color.png", "images/b/02-public-front-entrances-default-grayscale.png"):
		return {"ok": false, "message": "A/B entrance grayscale no longer rederives byte-exact pixel data."}
	var a_stills := _json(a_stills_path)
	var a_motion := _json(a_motion_path)
	var b_stills := _json(b_stills_path)
	var b_motion := _json(b_preliminary_path)
	if not _dependency_receipt_valid(a_stills) or not _dependency_receipt_valid(a_motion) \
	or not _dependency_receipt_valid(b_stills) or not _dependency_receipt_valid(b_motion):
		return {"ok": false, "message": "Capture-time runtime dependency closure no longer matches current files."}
	if not _stills_valid(a_stills, "a", A_CONFIG_SHA256) \
	or not _stills_valid(b_stills, "b", B_CONFIG_SHA256) \
	or not _motion_valid(a_motion, "a", A_CONFIG_SHA256, true) \
	or not _motion_valid(b_motion, "b", B_CONFIG_SHA256, false):
		return {"ok": false, "message": "Frozen still/motion semantic contract failed."}
	if not _stills_pair(a_stills, b_stills) or not _motion_pair(a_motion, b_motion):
		return {"ok": false, "message": "A/B pose, dependency, trajectory, or LOS pair drifted."}
	var a_movie_path := ROOT.path_join("building-1-entrance-gap-a-normal-forward-approach.avi")
	var b_movie_path := _b_movie_source_path()
	if FileAccess.get_sha256(a_movie_path) != A_MOVIE_SHA256 or FileAccess.get_file_as_bytes(a_movie_path).size() != A_MOVIE_BYTES \
	or FileAccess.get_sha256(b_movie_path) != B_MOVIE_SHA256 or FileAccess.get_file_as_bytes(b_movie_path).size() != B_MOVIE_BYTES:
		return {"ok": false, "message": "A canonical or B closed-pending movie bytes drifted."}
	var a_avi := _avi_metadata(a_movie_path)
	var b_avi := _avi_metadata(b_movie_path)
	if not _avi_valid(a_avi) or not _avi_valid(b_avi) \
	or int(a_avi.total_frames) != 337 or int(b_avi.total_frames) != 337:
		return {"ok": false, "message": "A/B AVI container authority is not 1440x900/337f/30fps."}
	var a_recorded := a_motion.get("avi_container", {}) as Dictionary
	var max_float_delta := maxf(
		absf(float(a_avi.frame_rate_fps) - float(a_recorded.get("frame_rate_fps", 0.0))),
		absf(float(a_avi.duration_seconds_from_avih) - float(a_recorded.get("duration_seconds_from_avih", 0.0)))
	)
	if not _avi_fieldwise_matches(a_avi, a_recorded, 0.000000001) or max_float_delta > 0.000000001:
		return {"ok": false, "message": "A AVI fieldwise read-back exceeds the 1e-9 recovery tolerance."}
	return {
		"ok": true, "a_stills": a_stills, "a_motion": a_motion,
		"b_stills": b_stills, "b_motion": b_motion,
		"a_avi": a_avi, "b_avi": b_avi, "json_float_readback_max_delta": max_float_delta,
	}


func _commit_once(state: Dictionary) -> void:
	var b_preliminary_path := _preliminary_path()
	var b_final_path := ROOT.path_join("b-motion.json")
	var pending_movie := ROOT.path_join("building-1-entrance-gap-b-normal-forward-approach.pending.avi")
	var canonical_movie := ROOT.path_join("building-1-entrance-gap-b-normal-forward-approach.avi")
	var preserved_preliminary := ROOT.path_join("b-motion-preliminary-unfinalized.json")
	var combined_path := ROOT.path_join("capture-manifest.json")
	var final_temp := ROOT.path_join(".b-motion.salvage-final.tmp.json")
	var combined_temp := ROOT.path_join(".capture-manifest.salvage-final.tmp.json")
	var journal_path := ROOT.path_join(".entrance-gap-salvage-transaction.json")
	var finalizer_sha := FileAccess.get_sha256("res://game/tests/building_1_entrance_gap_salvage_finalizer.gd")
	var b_final := (state.b_motion as Dictionary).duplicate(true)
	b_final["pending_movie_file"] = ""
	b_final["movie_sha256"] = B_MOVIE_SHA256
	b_final["movie_bytes"] = B_MOVIE_BYTES
	b_final["movie_finalized_after_writer_close"] = true
	b_final["avi_container"] = state.b_avi
	b_final["finalizer"] = "separate one-shot fieldwise AVI recovery; capture generator and all pixel/movie bytes unchanged"
	b_final["salvage_finalizer"] = "game/tests/building_1_entrance_gap_salvage_finalizer.gd"
	b_final["salvage_finalizer_sha256"] = finalizer_sha
	b_final["preliminary_manifest_preserved_as"] = "b-motion-preliminary-unfinalized.json"
	b_final["preliminary_manifest_sha256"] = B_PRELIMINARY_SHA256
	b_final["false_negative_reason"] = "JSON serialization rounded AVI FPS from 30.00030000300003 to 30.000300003; exact Dictionary equality failed although fieldwise delta was below 1e-9"
	b_final["json_float_readback_max_delta"] = float(state.json_float_readback_max_delta)
	b_final["recapture_performed"] = false
	b_final["pixels_or_movie_bytes_rewritten"] = false
	var b_final_text := JSON.stringify(b_final, "  ", false) + "\n"
	var b_final_sha := _sha256_text(b_final_text)
	var combined := {
		"schema_version": "ti.building-1-entrance-group-gap-evidence/1",
		"review_status": "pending_independent_visual_and_static_review_not_self_accepted",
		"recognition_status": "accepted_before_and_unchanged; no_numerator_effect",
		"base_commit": "798a4dc90b2405f8ff9f336c7bdf95403a0352a1",
		"experiment": {"field": "geometry_production_inference_m.entrance_group_gap", "a_m": 0.55, "b_m": 0.90, "delta_m": 0.35},
		"a_stills": "a-stills.json", "a_stills_sha256": A_STILLS_SHA256,
		"a_motion": "a-motion.json", "a_motion_sha256": A_MOTION_SHA256,
		"b_stills": "b-stills.json", "b_stills_sha256": B_STILLS_SHA256,
		"b_motion": "b-motion.json", "b_motion_sha256": b_final_sha,
		"b_preliminary_manifest": "b-motion-preliminary-unfinalized.json",
		"b_preliminary_manifest_sha256": B_PRELIMINARY_SHA256,
		"capture_generator_sha256": GENERATOR_SHA256,
		"salvage_finalizer": "game/tests/building_1_entrance_gap_salvage_finalizer.gd",
		"salvage_finalizer_sha256": finalizer_sha,
		"salvage_scope": "manifest/container float-readback recovery only; no recapture and no pixel/movie mutation",
		"capture_time_registry_sha256": CAPTURE_REGISTRY_SHA256,
		"capture_time_building_1_runtime_asset_count_each": 10,
		"post_capture_registry_closure_status": "pending separate 11th-dependency compiler reconciliation",
		"same_pose_still_pairs": true, "paired_normal_forward_stock_controller_motion": true,
		"deterministic_entrance_grayscale_pair": true,
		"runtime_topology_unchanged": EXPECTED_TOPOLOGY.duplicate(true),
		"building_1_and_tower_topology_unchanged": EXPECTED_B1_TOPOLOGY.duplicate(true),
		"collision_hashes_unchanged": ["21d69032bdba73c0406545b0b7d2c8efefd423fe8263815c3edc57bdc3756db5", "bb2c36915cba6d9d5f5d1a8239888ef1c913b1e4396eb6ce1cd2145c1a38e337"],
		"recognition_metric_unchanged": "6/213",
		"reviewer_instruction": "Judge original-detail same-pose A/B color and grayscale first, then both normal-forward stock-player movies. Confirm three groups become countable without splitting the one-canopy composition or weakening mild-oblique curved-front fit; reject visible shimmer, clipping, or float. No self-grade is claimed.",
		"visual_verdict": "pending_independent_review",
	}
	var combined_text := JSON.stringify(combined, "  ", false) + "\n"
	var combined_sha := _sha256_text(combined_text)
	var journal := {
		"schema_version": "ti.building-1-entrance-gap-salvage-transaction/1",
		"preliminary_manifest_sha256": B_PRELIMINARY_SHA256,
		"pending_and_canonical_movie_sha256": B_MOVIE_SHA256,
		"final_manifest_sha256": b_final_sha,
		"combined_manifest_sha256": combined_sha,
		"salvage_finalizer_sha256": finalizer_sha,
	}
	var journal_text := JSON.stringify(journal, "  ", false) + "\n"
	var journal_sha := _sha256_text(journal_text)
	if _final_state_valid(b_final_sha, combined_text):
		if FileAccess.file_exists(journal_path) and not _remove_exact(journal_path, journal_sha):
			_fail("Final salvage bytes are valid but the exact transaction journal could not be removed.")
			return
		print("PASS: exact salvage transaction was already complete; no capture bytes changed")
		return
	if not FileAccess.file_exists(journal_path):
		if b_preliminary_path != b_final_path or FileAccess.file_exists(preserved_preliminary) \
		or FileAccess.file_exists(canonical_movie) or FileAccess.file_exists(combined_path) \
		or FileAccess.file_exists(final_temp) or FileAccess.file_exists(combined_temp) \
		or not FileAccess.file_exists(pending_movie) or FileAccess.get_sha256(pending_movie) != B_MOVIE_SHA256:
			_fail("No transaction journal exists and salvage destinations are not pristine; refusing mutation.")
			return
		if not _write_new_exact(journal_path, journal_text):
			_fail("Could not create the exact salvage transaction journal before mutation.")
			return
	elif FileAccess.get_sha256(journal_path) != journal_sha:
		_fail("Existing salvage transaction journal conflicts with the exact frozen transaction.")
		return
	if not _ensure_temp_or_installed(final_temp, b_final_path, b_final_text, B_PRELIMINARY_SHA256) \
	or not _ensure_temp_or_installed(combined_temp, combined_path, combined_text):
		_fail("Could not create or recover exact salvage temp receipts.")
		return
	if not _preserve_preliminary(b_final_path, preserved_preliminary, b_final_sha):
		_fail("Could not preserve/recover the preliminary B manifest byte-for-byte.")
		return
	if not _promote_movie(pending_movie, canonical_movie):
		_fail("Could not promote/recover the already-closed B movie without byte drift.")
		return
	if not _install_exact(final_temp, b_final_path, b_final_sha) \
	or not _install_exact(combined_temp, combined_path, combined_sha):
		_fail("Could not install/recover the exact final B and combined manifests.")
		return
	if FileAccess.file_exists(pending_movie) or FileAccess.file_exists(final_temp) or FileAccess.file_exists(combined_temp) \
	or not _final_state_valid(b_final_sha, combined_text):
		_fail("Salvage transaction final state did not revalidate.")
		return
	if not _remove_exact(journal_path, journal_sha):
		_fail("Salvage completed, but its exact transaction journal could not be removed.")
		return
	print("PASS: salvaged frozen B without recapture/pixel/movie mutation; b_manifest=%s combined=%s" % [b_final_sha, FileAccess.get_sha256(combined_path)])


func _preliminary_path() -> String:
	var active := ROOT.path_join("b-motion.json")
	var preserved := ROOT.path_join("b-motion-preliminary-unfinalized.json")
	if FileAccess.file_exists(active) and FileAccess.get_sha256(active) == B_PRELIMINARY_SHA256:
		return active
	if FileAccess.file_exists(preserved) and FileAccess.get_sha256(preserved) == B_PRELIMINARY_SHA256:
		return preserved
	return active


func _b_movie_source_path() -> String:
	var pending := ROOT.path_join("building-1-entrance-gap-b-normal-forward-approach.pending.avi")
	var canonical := ROOT.path_join("building-1-entrance-gap-b-normal-forward-approach.avi")
	return pending if FileAccess.file_exists(pending) else canonical


func _dependency_receipt_valid(manifest: Dictionary) -> bool:
	var receipt := manifest.get("stable_runtime_dependency_hashes", {}) as Dictionary
	if receipt != EXPECTED_RUNTIME_DEPENDENCY_HASHES:
		return false
	for path: String in EXPECTED_RUNTIME_DEPENDENCY_HASHES:
		if not FileAccess.file_exists(path) \
		or FileAccess.get_sha256(path) != str(EXPECTED_RUNTIME_DEPENDENCY_HASHES[path]):
			return false
	return true


func _bindings_valid(bindings: Dictionary) -> bool:
	return _values_close(bindings.get("component_topology", {}), EXPECTED_COMPONENT_TOPOLOGY, 0.0) \
		and _values_close(bindings.get("building_1_and_tower_topology", {}), EXPECTED_B1_TOPOLOGY, 0.0) \
		and str(bindings.get("main_wall_collision_sha256", "")) == "21d69032bdba73c0406545b0b7d2c8efefd423fe8263815c3edc57bdc3756db5" \
		and str(bindings.get("main_roof_collision_sha256", "")) == "bb2c36915cba6d9d5f5d1a8239888ef1c913b1e4396eb6ce1cd2145c1a38e337" \
		and int(bindings.get("structural_body_count", -1)) == 4 \
		and int(bindings.get("structural_shape_count", -1)) == 4 \
		and int(bindings.get("wall_spray_owner_count", -1)) == 2 \
		and int(bindings.get("roof_spray_owner_count", -1)) == 0 \
		and int(bindings.get("navigation_owner_count", -1)) == 0 \
		and str(bindings.get("recognition_metric", "")) == "6/213" \
		and bindings.get("accepted_physical_unit_ids", []) == EXPECTED_ACCEPTED_IDS \
		and _values_close(bindings.get("runtime_asset_counts", {}), {"building:r16681702:wall": 10, "building:w1222720021:wall": 10}, 0.0) \
		and str(bindings.get("registry_sha256", "")) == CAPTURE_REGISTRY_SHA256


func _stills_valid(manifest: Dictionary, stage: String, config_sha: String) -> bool:
	if str(manifest.get("schema_version", "")) != "ti.building-1-entrance-group-gap-stills/1" \
	or str(manifest.get("stage", "")) != stage \
	or str(manifest.get("generator_sha256", "")) != GENERATOR_SHA256 \
	or str(manifest.get("parent_harness_sha256", "")) != PARENT_SHA256 \
	or str(manifest.get("public_front_config_sha256", "")) != config_sha \
	or str(manifest.get("capture_override_sha256", "")) != OVERRIDE_SHA256 \
	or str(manifest.get("registry_sha256", "")) != CAPTURE_REGISTRY_SHA256 \
	or not _values_close(manifest.get("runtime_topology", {}), EXPECTED_TOPOLOGY, 0.0) \
	or int(manifest.get("capture_count", -1)) != 3:
		return false
	if not _bindings_valid(manifest.get("bindings", {}) as Dictionary):
		return false
	var captures := manifest.get("captures", []) as Array
	if captures.size() != 3:
		return false
	var expected_capture_roles := [
		["01-public-front-whole-default", "world_default", false],
		["01-public-front-whole-changed-light", "frozen_changed_light", false],
		["02-public-front-entrances-default", "world_default", true],
	]
	var grayscale_count := 0
	for index in captures.size():
		var value: Variant = captures[index]
		var capture := value as Dictionary
		var hud := capture.get("hud", {}) as Dictionary
		var expected := expected_capture_roles[index] as Array
		if not _values_close(capture.get("dimensions", []), [1440, 900], 0.0) or not bool(capture.get("physics_grounded", false)) \
		or str(capture.get("id", "")) != str(expected[0]) or str(capture.get("lighting", "")) != str(expected[1]) \
		or bool(capture.get("grayscale_derived", false)) != bool(expected[2]) \
		or not is_equal_approx(float(capture.get("camera_fov_degrees", -1.0)), 70.0) \
		or not is_equal_approx(float(capture.get("configured_spring_length_m", -1.0)), 5.5) \
		or bool(hud.get("debug_panel_visible", true)) or bool(hud.get("feedback_panel_visible", true)) \
		or bool(hud.get("load_panel_visible", true)) or bool(hud.get("pause_panel_visible", true)) \
		or not bool(hud.get("reticle_visible", false)) \
		or not bool(capture.get("ordinary_player_rig", false)) \
		or not bool(capture.get("input_reachable_camera_orientation", false)) \
		or bool(capture.get("debug_labels_visible", true)) \
		or bool(capture.get("source_photography_in_frame", true)) \
		or bool(capture.get("color_crop_or_postprocess", true)) \
		or str(capture.get("first_los_hit_receiver", "")) != "building:r16681702:wall" \
		or capture.get("first_los_hit_source_keys", []) != ["r16681702"]:
			return false
		if bool(capture.get("grayscale_derived", false)):
			grayscale_count += 1
		if str(capture.get("lighting", "")) == "frozen_changed_light" \
		and (not bool(capture.get("player_transform_exactly_reused", false)) or not bool(capture.get("camera_transform_exactly_reused", false))):
			return false
	return grayscale_count == 1


func _motion_valid(manifest: Dictionary, stage: String, config_sha: String, finalized: bool) -> bool:
	if str(manifest.get("schema_version", "")) != "ti.building-1-entrance-group-gap-motion/1" \
	or str(manifest.get("stage", "")) != stage \
	or str(manifest.get("generator_sha256", "")) != GENERATOR_SHA256 \
	or str(manifest.get("parent_harness_sha256", "")) != PARENT_SHA256 \
	or str(manifest.get("public_front_config_sha256", "")) != config_sha \
	or str(manifest.get("capture_override_sha256", "")) != OVERRIDE_SHA256 \
	or str(manifest.get("registry_sha256", "")) != CAPTURE_REGISTRY_SHA256 \
	or not _values_close(manifest.get("runtime_topology", {}), EXPECTED_TOPOLOGY, 0.0) \
	or int(manifest.get("motion_physics_frames", -1)) != 529 \
	or int(manifest.get("path_sample_count", -1)) != 529 \
	or int(manifest.get("los_sample_count", -1)) != 529 \
	or str(manifest.get("input_action", "")) != "move_forward" \
	or not bool(manifest.get("normal_forward_walk", false)) \
	or int(manifest.get("player_transform_writes_after_input_began", -1)) != 0 \
	or int(manifest.get("camera_transform_writes_after_input_began", -1)) != 0 \
	or not bool(manifest.get("all_samples_grounded", false)) \
	or int(manifest.get("recovery_delta", -1)) != 0 \
	or bool(manifest.get("sprint_used", true)) or bool(manifest.get("jetpack_used", true)) \
	or bool(manifest.get("manual_recovery_used", true)) \
	or bool(manifest.get("movie_finalized_after_writer_close", false)) != finalized \
	or bool(manifest.get("camera_orientation_changed_during_motion", true)) \
	or not bool(manifest.get("wall_range_monotonically_decreased", false)) \
	or bool(manifest.get("run_action_pressed", true)) or bool(manifest.get("jetpack_action_pressed", true)) \
	or not _values_close(manifest.get("movie_dimensions", []), [1440, 900], 0.0) \
	or not is_equal_approx(float(manifest.get("fixed_fps", 0.0)), 30.0) \
	or not is_equal_approx(float(manifest.get("physics_ticks_per_second", 0.0)), 60.0) \
	or not is_equal_approx(float(manifest.get("continuous_duration_seconds", 0.0)), 529.0 / 60.0) \
	or not _values_close(manifest.get("review_motion_physics_frame_range", []), [131, 660], 0.0) \
	or not _values_close(manifest.get("review_motion_process_frame_range", []), [65, 330], 0.0) \
	or float(manifest.get("start_horizontal_range_to_facade_m", 0.0)) < 59.9 \
	or float(manifest.get("end_horizontal_range_to_facade_m", 999.0)) > 25.1 \
	or float(manifest.get("horizontal_displacement_m", 0.0)) < 35.0 \
	or float(manifest.get("maximum_lateral_deviation_m", 1.0)) > 0.08 \
	or float(manifest.get("direction_dot_normal_approach", 0.0)) < 0.999 \
	or not _bindings_valid(manifest.get("bindings", {}) as Dictionary):
		return false
	var path_samples := manifest.get("path_samples", []) as Array
	var los_samples := manifest.get("los_samples", []) as Array
	if path_samples.size() != 529 or los_samples.size() != 529:
		return false
	var initial_basis := path_samples[0] as Dictionary
	var previous_range := INF
	for index in path_samples.size():
		var value: Variant = path_samples[index]
		var sample := value as Dictionary
		var wall_range := float(sample.get("range_to_wall_anchor_m", INF))
		if int(sample.get("frame", -1)) != index + 1 \
		or not bool(sample.get("is_on_floor", false)) or not bool(sample.get("in_world_boundary", false)) \
		or not bool(sample.get("move_forward_pressed", false)) or bool(sample.get("run_pressed", true)) \
		or bool(sample.get("jetpack_pressed", true)) or float(sample.get("ground_normal_up_dot", 0.0)) < 0.7 \
		or absf(float(sample.get("ground_clearance_m", 1.0))) > 0.08 \
		or float(sample.get("lateral_deviation_from_normal_route_m", 1.0)) > 0.08 \
		or wall_range >= previous_range \
		or not _values_close(sample.get("camera_basis_x", []), initial_basis.get("camera_basis_x", []), 0.00001) \
		or not _values_close(sample.get("camera_basis_y", []), initial_basis.get("camera_basis_y", []), 0.00001) \
		or not _values_close(sample.get("camera_basis_z", []), initial_basis.get("camera_basis_z", []), 0.00001) \
		or not _values_close(sample.get("camera_forward", []), initial_basis.get("camera_forward", []), 0.00001):
			return false
		previous_range = wall_range
	for index in los_samples.size():
		var value: Variant = los_samples[index]
		var los := value as Dictionary
		if int(los.get("frame", -1)) != index + 1 \
		or str(los.get("receiver_key", "")) != "building:r16681702:wall" \
		or los.get("source_keys", []) != ["r16681702"]:
			return false
	return true


func _stills_pair(a: Dictionary, b: Dictionary) -> bool:
	if a.get("stable_runtime_dependency_hashes", {}) != b.get("stable_runtime_dependency_hashes", {}) \
	or str(a.get("registry_sha256", "")) != str(b.get("registry_sha256", "")) \
	or not _values_close(a.get("fixed_view_definitions", []), b.get("fixed_view_definitions", []), 0.000000001):
		return false
	var first := a.get("captures", []) as Array
	var second := b.get("captures", []) as Array
	if first.size() != second.size():
		return false
	for index in first.size():
		var left := first[index] as Dictionary
		var right := second[index] as Dictionary
		for key in ["id", "lighting", "requested_xz", "player_position_m", "ground_y_m", "aim_target_m", "camera_position_m", "camera_forward", "camera_fov_degrees", "configured_spring_length_m", "sun_rotation_degrees"]:
			if not _values_close(left.get(key), right.get(key), 0.000000001):
				return false
	return true


func _motion_pair(a: Dictionary, b: Dictionary) -> bool:
	return a.get("stable_runtime_dependency_hashes", {}) == b.get("stable_runtime_dependency_hashes", {}) \
		and str(a.get("registry_sha256", "")) == str(b.get("registry_sha256", "")) \
		and _values_close(a.get("requested_start_xz", []), b.get("requested_start_xz", []), 0.000000001) \
		and _values_close(a.get("aim_target_m", []), b.get("aim_target_m", []), 0.000000001) \
		and _values_close(a.get("start_player_transform", {}), b.get("start_player_transform", {}), 0.000000001) \
		and _values_close(a.get("start_camera_transform", {}), b.get("start_camera_transform", {}), 0.000000001) \
		and _values_close(a.get("path_samples", []), b.get("path_samples", []), 0.000000001) \
		and _values_close(a.get("los_samples", []), b.get("los_samples", []), 0.000000001)


func _avi_valid(value: Dictionary) -> bool:
	return str(value.get("container", "")) == "RIFF_AVI" \
		and str(value.get("video_codec", "")) == "Motion_JPEG" \
		and int(value.get("width", -1)) == 1440 and int(value.get("height", -1)) == 900 \
		and int(value.get("microseconds_per_frame", -1)) == 33333 \
		and absf(float(value.get("frame_rate_fps", 0.0)) - 30.000300003) <= 0.000000001


func _avi_fieldwise_matches(observed: Dictionary, recorded: Dictionary, tolerance: float) -> bool:
	for key in ["container", "video_codec"]:
		if observed.get(key) != recorded.get(key):
			return false
	for key in ["width", "height", "total_frames", "microseconds_per_frame"]:
		if int(observed.get(key, -1)) != int(recorded.get(key, -2)):
			return false
	return absf(float(observed.frame_rate_fps) - float(recorded.get("frame_rate_fps", 0.0))) <= tolerance \
		and absf(float(observed.duration_seconds_from_avih) - float(recorded.get("duration_seconds_from_avih", 0.0))) <= tolerance


func _avi_metadata(path: String) -> Dictionary:
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.size() < 12 or _ascii(bytes, 0, 4) != "RIFF" or _ascii(bytes, 8, 4) != "AVI ":
		return {}
	var offset := _fourcc(bytes, "avih")
	if offset < 0 or offset + 48 > bytes.size():
		return {}
	var codec_fourcc := _video_codec_fourcc(bytes)
	var micros := int(bytes.decode_u32(offset + 8))
	var frames := int(bytes.decode_u32(offset + 24))
	return {
		"container": "RIFF_AVI",
		"video_codec": "Motion_JPEG" if codec_fourcc == "MJPG" else "unknown:%s" % codec_fourcc,
		"width": int(bytes.decode_u32(offset + 40)), "height": int(bytes.decode_u32(offset + 44)),
		"total_frames": frames, "microseconds_per_frame": micros,
		"frame_rate_fps": 1000000.0 / float(micros),
		"duration_seconds_from_avih": float(frames * micros) / 1000000.0,
	}


func _video_codec_fourcc(bytes: PackedByteArray) -> String:
	var search_offset := 0
	while search_offset + 16 <= bytes.size():
		var relative := _fourcc(bytes.slice(search_offset), "strh")
		if relative < 0:
			return ""
		var offset := search_offset + relative
		if offset + 16 <= bytes.size() and _ascii(bytes, offset + 8, 4) == "vids":
			return _ascii(bytes, offset + 12, 4)
		search_offset = offset + 4
	return ""


func _ascii(bytes: PackedByteArray, offset: int, length: int) -> String:
	if offset < 0 or length < 0 or offset + length > bytes.size():
		return ""
	return bytes.slice(offset, offset + length).get_string_from_ascii()


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


func _grayscale_matches(color_relative: String, gray_relative: String) -> bool:
	var color := Image.load_from_file(ROOT.path_join(color_relative))
	var gray := Image.load_from_file(ROOT.path_join(gray_relative))
	if color == null or gray == null or color.is_empty() or gray.is_empty():
		return false
	color.convert(Image.FORMAT_L8)
	gray.convert(Image.FORMAT_L8)
	return color.get_size() == Vector2i(1440, 900) and color.get_data() == gray.get_data()


func _values_close(left: Variant, right: Variant, tolerance: float) -> bool:
	if left is Array and right is Array:
		if left.size() != right.size():
			return false
		for index in left.size():
			if not _values_close(left[index], right[index], tolerance):
				return false
		return true
	if left is Dictionary and right is Dictionary:
		if left.size() != right.size():
			return false
		for key: Variant in left:
			if not right.has(key) or not _values_close(left[key], right[key], tolerance):
				return false
		return true
	if left is float or left is int:
		return absf(float(left) - float(right)) <= tolerance
	return left == right


func _final_state_valid(b_final_sha: String, combined_text: String) -> bool:
	return FileAccess.get_sha256(ROOT.path_join("b-motion-preliminary-unfinalized.json")) == B_PRELIMINARY_SHA256 \
		and FileAccess.get_sha256(ROOT.path_join("building-1-entrance-gap-b-normal-forward-approach.avi")) == B_MOVIE_SHA256 \
		and FileAccess.get_sha256(ROOT.path_join("b-motion.json")) == b_final_sha \
		and FileAccess.get_sha256(ROOT.path_join("capture-manifest.json")) == _sha256_text(combined_text) \
		and not FileAccess.file_exists(ROOT.path_join("building-1-entrance-gap-b-normal-forward-approach.pending.avi")) \
		and not FileAccess.file_exists(ROOT.path_join(".b-motion.salvage-final.tmp.json")) \
		and not FileAccess.file_exists(ROOT.path_join(".capture-manifest.salvage-final.tmp.json"))


func _ensure_temp_or_installed(temp_path: String, installed_path: String, text: String, allowed_existing_sha := "") -> bool:
	var expected_sha := _sha256_text(text)
	if FileAccess.file_exists(installed_path) and FileAccess.get_sha256(installed_path) == expected_sha:
		return not FileAccess.file_exists(temp_path) or _remove_exact(temp_path, expected_sha)
	if FileAccess.file_exists(installed_path) and FileAccess.get_sha256(installed_path) != allowed_existing_sha:
		return false
	return _write_new_exact(temp_path, text)


func _preserve_preliminary(active_path: String, preserved_path: String, final_sha: String) -> bool:
	if FileAccess.file_exists(preserved_path):
		if FileAccess.get_sha256(preserved_path) != B_PRELIMINARY_SHA256:
			return false
		return not FileAccess.file_exists(active_path) or FileAccess.get_sha256(active_path) == final_sha
	if not FileAccess.file_exists(active_path) or FileAccess.get_sha256(active_path) != B_PRELIMINARY_SHA256:
		return false
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(active_path), ProjectSettings.globalize_path(preserved_path)) == OK \
		and FileAccess.get_sha256(preserved_path) == B_PRELIMINARY_SHA256


func _promote_movie(pending_path: String, canonical_path: String) -> bool:
	if FileAccess.file_exists(canonical_path):
		return FileAccess.get_sha256(canonical_path) == B_MOVIE_SHA256 and not FileAccess.file_exists(pending_path)
	if not FileAccess.file_exists(pending_path) or FileAccess.get_sha256(pending_path) != B_MOVIE_SHA256:
		return false
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(pending_path), ProjectSettings.globalize_path(canonical_path)) == OK \
		and FileAccess.get_sha256(canonical_path) == B_MOVIE_SHA256


func _install_exact(temp_path: String, destination_path: String, expected_sha: String) -> bool:
	if FileAccess.file_exists(destination_path):
		if FileAccess.get_sha256(destination_path) != expected_sha:
			return false
		return not FileAccess.file_exists(temp_path) or _remove_exact(temp_path, expected_sha)
	if not FileAccess.file_exists(temp_path) or FileAccess.get_sha256(temp_path) != expected_sha:
		return false
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(temp_path), ProjectSettings.globalize_path(destination_path)) == OK \
		and FileAccess.get_sha256(destination_path) == expected_sha


func _remove_exact(path: String, expected_sha: String) -> bool:
	if not FileAccess.file_exists(path):
		return true
	if FileAccess.get_sha256(path) != expected_sha:
		return false
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) == OK and not FileAccess.file_exists(path)


func _write_new_exact(path: String, text: String) -> bool:
	if FileAccess.file_exists(path):
		return FileAccess.get_sha256(path) == _sha256_text(text)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(text)
	file.close()
	return FileAccess.get_sha256(path) == _sha256_text(text)


func _sha256_text(text: String) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(text.to_utf8_buffer())
	return context.finish().hex_encode()


func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _argument(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""


func _fail(message: String) -> void:
	_failed = true
	push_error(message)


func _finish() -> void:
	quit(1 if _failed else 0)
