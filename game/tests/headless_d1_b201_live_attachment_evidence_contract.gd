extends SceneTree

const ROOT := "res://evidence/first-playable/d1-b201-live-attachment-2026-09-04"
const STILL_MANIFEST := ROOT + "/capture-manifest.json"
const MOTION_MANIFEST := ROOT + "/motion-capture.json"
const MOTION_SEAL := ROOT + "/motion-seal.json"
const MOVIE := ROOT + "/b201-actual-live-normal-forward-approach.avi"
const REVIEW := ROOT + "/INDEPENDENT_LIVE_VISUAL_BAR_RAISER_REVIEW.md"
const MOTION_CLARIFICATION := ROOT + "/INDEPENDENT_MOTION_BOUNDARY_CLARIFICATION.md"
const README := ROOT + "/README.md"
const LEDGER := ROOT + "/CHECKSUMS.sha256"
const HARNESS := "res://game/tests/d1_b201_live_attachment_capture.gd"
const FOCUSED_CONTRACT := "res://game/tests/headless_d1_b201_live_attachment_contract.gd"
const PACKAGE_CONTRACT := "res://game/tests/headless_d1_b201_live_attachment_package_contract.gd"
const ADAPTER := "res://game/scripts/world/facades/d1_b201_live_attachment.gd"
const BUILDER := "res://game/scripts/world/world_chunk_builder.gd"
const CONFIG := "res://game/resources/facades/d1_current/d1_b201_live_attachment.json"
const REGISTRY := "res://game/resources/facades/facade-runtime-registry.json"
const CONTRACTS := "res://game/resources/facades/facade-runtime-adapter-contracts.json"
const CATALOG := "res://discovery/facades/facade-recognition-catalog.json"
const RECEIVER_KEY := "building:w34313545:wall"
const SOURCE_KEY := "w34313545"
const PHYSICAL_UNIT_ID := "physical-building:w34313545"
const REVIEW_STATUS_SCOPE := "runtime_asset_original_detail_provenance_only_not_reference_recognition"
const RECOGNITION_ACCEPTANCE_AUTHORITY := "physical_unit_claim_and_independent_acceptance_record"
const DECORATIVE_SIGNATURE := "705c5345509f77cd91359f66173fff0e1e132d41ebb9acef3f51ff2c467abb3a"
const WORLD := {"rows": 735, "meshes": 950, "surfaces": 964, "triangles": 66636, "bodies": 466, "shapes": 466}
const EXPECTED_EVIDENCE_TREE := [
	"CHECKSUMS.sha256",
	"INDEPENDENT_LIVE_VISUAL_BAR_RAISER_REVIEW.md",
	"INDEPENDENT_MOTION_BOUNDARY_CLARIFICATION.md",
	"README.md",
	"b201-actual-live-normal-forward-approach.avi",
	"capture-manifest.json",
	"capture-override.cfg",
	"images/01-whole-wsw-default.png",
	"images/02-whole-wsw-changed-light.png",
	"images/03-whole-wsw-default-grayscale.png",
	"images/04-wsw-hierarchy-oblique.png",
	"images/05-close-sprayed-host.png",
	"motion-capture.json",
	"motion-seal.json",
]
const IMAGE_BYTES := {
	"01-whole-wsw-default": 949378,
	"02-whole-wsw-changed-light": 845534,
	"03-whole-wsw-default-grayscale": 323233,
	"04-wsw-hierarchy-oblique": 751493,
	"05-close-sprayed-host": 680943,
}
const EXPECTED_RUNTIME_ASSETS := {
	CONFIG: "0f3bf052688ec813b5fa58b077d74c963949574623fe4cf67c12c347e7257229",
	"res://game/resources/materials/world/d1_current/b201_green_hierarchy.tres": "5bdd67e659a0cce14abe3605f5a7fbfd85b0374d0a38be23cda326017235fe13",
	"res://game/resources/materials/world/d1_current/b201_muted_rust_post.tres": "be97cdfd7367cd73172c4429ca212db0d1fc68bed34f4db6ce307d02a5225b94",
	"res://game/resources/materials/world/d1_current/b201_service_leaf.tres": "de9895a808e4d64afc2c727e77ef92b590c9c718266ba118e64c489e84690cfd",
	"res://game/resources/materials/world/d1_current/b201_warm_wall.tres": "6f5f6835790ab338454e72be58c2956deb6e470086797e209be0fab4d37ec788",
	"res://game/resources/materials/world/d1_current/shared_dark_glass.tres": "ad8931db8954fd5ebc8fdd809f70afb279dd74a36e53e1d9ca907c44409f10d3",
	"res://game/resources/materials/world/d1_current/shared_pale_frame.tres": "9a2de298ff545cf80c5da0ed0aa37d9d4ebbf10fec8eb78810af7e4d012d1436",
	ADAPTER: "499f6d2657b593ee5b0801cf1205a2925a993f3b1836922d3656a6d00c51cc19",
}
const EXPECTED_HASHES := {
	REVIEW: "b9ef912df2dd00fa2c456a8e7e03473001cc381cbc2dd5288e9f6ef65d8c2772",
	MOTION_CLARIFICATION: "1c45efd3fae9e4f8c1e8284a8c3e3e935b6599d26fbf4eed460e32436072e88b",
	README: "485ae8ebf83cbd96afdf4eca07f52e271a757320c297b2ef80f589a849470911",
	STILL_MANIFEST: "f169085620a0a9ff0c685e4dfa98442c5c31e4e580f1decdbd80e84b09c74fe3",
	MOTION_MANIFEST: "67d43d12a42a527bc950513186fb5dbf7a18cfcbd6ac1791e5cc6b3fafc20c8b",
	MOTION_SEAL: "9c0a1fbb0cd08a189275b5c7c149cebc233d21b999dc8824e0ba5f90ad6efdcf",
	MOVIE: "9632c289fd5cf5f808e8e6496f81dbc973d29638f26590ca4333b0d23e1ac25d",
	ROOT + "/capture-override.cfg": "edbc0b9caa60fa0fc6b83cebb3145bce11ce0bd976403ca1d2fbe9b7142b39c3",
	ROOT + "/images/01-whole-wsw-default.png": "f64d38211a814502d21da17b277814fbb3f50d47fc0e0f9703ec3727be7f2048",
	ROOT + "/images/02-whole-wsw-changed-light.png": "6224dd7d36c97c2c71f2698417df05bea7e05bb31ce3cf475805d37e19ba85e6",
	ROOT + "/images/03-whole-wsw-default-grayscale.png": "42ef340a3dc5e6b8d00284534ee70b47516abcda0c9b5e791d0a4452119e5e98",
	ROOT + "/images/04-wsw-hierarchy-oblique.png": "bcf3c167612038dc924d9f453d6fc808707a799067db0e588e26ce261fb71ae3",
	ROOT + "/images/05-close-sprayed-host.png": "a0193992eb3067741917355fc0e7a590c4bf3b0de05b1d6d7881cb0c39a106c8",
	HARNESS: "21c465a9e7d0dc1e6d914dcb3e241702b07ce47aeb28d59715e808156229d974",
	FOCUSED_CONTRACT: "9833fee27a34577e228a52d25aabe73461cdd359a61c90a28616e8f8b60f21d0",
	PACKAGE_CONTRACT: "7da2509551bb2f72be552d845c02ab069d0ad22c0ae568cb209cce50d2b4cd2d",
	ADAPTER: "499f6d2657b593ee5b0801cf1205a2925a993f3b1836922d3656a6d00c51cc19",
	BUILDER: "71e391e4fa58afc83e4bcb99a9f8195e398fdf4064bb09a401fb079e9f30491c",
	CONFIG: "0f3bf052688ec813b5fa58b077d74c963949574623fe4cf67c12c347e7257229",
	"res://game/scripts/world/facades/facade_meter_uv_adapter.gd": "47e710b9ea7c5de5122430199e4105cbba5f672d22f59832f13b8004f16c5a1d",
	REGISTRY: "9c46c1a8c809aa9ded82008d35e9c1b257070e9c61f6d6e41f5650ca7b1c3f27",
	CONTRACTS: "f5c1a2fb73ac0343258d4fea35169e2b7efa98accbce0c834b3e2aab45fefafe",
	CATALOG: "a4d9dd474acb09a211f7e0e00d66aeaf7a669927880dd011e24e2f51d13bdd7d",
	"res://discovery/facades/facade-recognition-catalog.schema.json": "07a4b17cbeba4603a2e08b99787dd00fe934eeda83aa6da2e850c327ac77e2c5",
	"res://discovery/facades/facade-recognition-validation-report.json": "4caabace118ebf545c581e0be2c59e680726be3cc7fe658cf35dddfd56b78d26",
	"res://game/scripts/world/facades/facade_runtime_registry_loader.gd": "a191a9c260e471825847c92873fd96763c507b51004be769cba10b9d4b47ce6f",
	"res://tools/build_facade_recognition_registry.mjs": "371289a4d73235165a1aeeba0a3651129dc4ba2655aa18ee52622374a62ac917",
	"res://generated/world/chunks/x_0__z_-2.json": "c0e1f86787410d975ad90272482e5f4971c4aedc7eb83132cd28b22acf1a3456",
	"res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
	"res://discovery/facades/d1_reference_packets/w34313545_building_201.md": "c6fba23d80e95b23c4f3eb172a252baa47767b7a29757096bff329c693db9e5e",
	"res://discovery/facades/PRECOMMIT_PACKAGE_SANITIZATION_SOURCE_PROVENANCE.json": "269558b49e21c6c4f46c7133c3aa6012ca35bc122739c677b3ba5ab318a19333",
	"res://evidence/first-playable/d1-current-standalone-prototype-pair-2026-09-04/INDEPENDENT_BAR_RAISER_REVIEW.md": "8567cd5eb9080f8f7cb563152ae83885330d366cc56ecc8513d5ebdadf491feb",
	"res://game/resources/materials/world/d1_current/b201_green_hierarchy.tres": "5bdd67e659a0cce14abe3605f5a7fbfd85b0374d0a38be23cda326017235fe13",
	"res://game/resources/materials/world/d1_current/b201_muted_rust_post.tres": "be97cdfd7367cd73172c4429ca212db0d1fc68bed34f4db6ce307d02a5225b94",
	"res://game/resources/materials/world/d1_current/b201_service_leaf.tres": "de9895a808e4d64afc2c727e77ef92b590c9c718266ba118e64c489e84690cfd",
	"res://game/resources/materials/world/d1_current/b201_warm_wall.tres": "6f5f6835790ab338454e72be58c2956deb6e470086797e209be0fab4d37ec788",
	"res://game/resources/materials/world/d1_current/shared_dark_glass.tres": "ad8931db8954fd5ebc8fdd809f70afb279dd74a36e53e1d9ca907c44409f10d3",
	"res://game/resources/materials/world/d1_current/shared_pale_frame.tres": "9a2de298ff545cf80c5da0ed0aa37d9d4ebbf10fec8eb78810af7e4d012d1436",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for path: String in EXPECTED_HASHES:
		_require(FileAccess.get_sha256(path) == str(EXPECTED_HASHES[path]), "Evidence/source hash drifted: %s." % path)
	_require(_evidence_tree_matches(), "Evidence tree has a missing, extra, or misnamed file.")
	var stills := _json(STILL_MANIFEST)
	var motion := _json(MOTION_MANIFEST)
	var seal := _json(MOTION_SEAL)
	_require(_stills_match(stills), "Actual-live B201 still manifest or PNG contract failed.")
	_require(_motion_matches(motion), "Actual-live B201 pre-close motion contract failed.")
	_require(_seal_matches(seal), "Finalized B201 AVI seal/container contract failed.")
	_require(_current_authority_matches(), "Current B201 7/213 registry/catalog/package authority drifted.")
	_require(_ledger_matches(), "Evidence checksum ledger is incomplete, duplicated, unsorted, or stale.")
	_require(not FileAccess.file_exists("res://override.cfg"), "Temporary capture override leaked to repository root.")
	if not _failed:
		print("PASS: five exact 1440x900 B201 stills, one 360-sample grounded stock-player approach, and its finalized 252-frame RIFF/AVI/MJPG movie remain byte-sealed at capture-time 6/213; the separate independent receipt and coordinated v7/v6 exact eight-asset authority reconcile exactly one unit to current 7/213 without rewriting capture bytes")
	quit(1 if _failed else 0)


func _stills_match(manifest: Dictionary) -> bool:
	if str(manifest.get("schema_version", "")) != "ti.d1-b201-actual-live-evidence/1" \
	or str(manifest.get("review_status", "")) != "pending_independent_live_visual_static_and_package_review_not_self_accepted" \
	or str(manifest.get("recognition_status", "")) != "pending_independent_review" \
	or str(manifest.get("visual_verdict", "")) != "pending_independent_review" \
	or str(manifest.get("recognition_metric_frozen", "")) != "6/213" \
	or str(manifest.get("generator_sha256", "")) != str(EXPECTED_HASHES[HARNESS]) \
	or str(manifest.get("frozen_generator_sha256_argument", "")) != str(EXPECTED_HASHES[HARNESS]) \
	or not _world_matches(manifest.get("runtime_topology", {}) as Dictionary) \
	or not bool(manifest.get("actual_live_node_resolved", false)) \
	or int(manifest.get("preview_or_standalone_attachment_count", -1)) != 0 \
	or bool(manifest.get("source_photography_shipped", true)) or bool(manifest.get("source_urls_in_runtime", true)) \
	or not _bindings_match(manifest.get("bindings", {}) as Dictionary):
		return false
	var captures := manifest.get("captures", []) as Array
	if captures.size() != 5 or int(manifest.get("capture_count", -1)) != 5:
		return false
	var by_id := {}
	for value: Variant in captures:
		var capture := value as Dictionary
		var id := str(capture.get("id", ""))
		if not IMAGE_BYTES.has(id) or by_id.has(id):
			return false
		by_id[id] = capture
		var path := ROOT.path_join(str(capture.get("file", "")))
		var image := Image.load_from_file(ProjectSettings.globalize_path(path))
		if image == null or image.is_empty() or image.get_size() != Vector2i(1440, 900) \
		or str(capture.get("sha256", "")) != FileAccess.get_sha256(path) or int(capture.get("bytes", -1)) != int(IMAGE_BYTES[id]) \
		or bool(capture.get("crop_or_postprocess", capture.get("crop_or_relight", true))) \
		or str(capture.get("visual_verdict", "")) != "pending_independent_review":
			return false
		if id != "03-whole-wsw-default-grayscale" and (not bool(capture.get("physics_grounded", false)) \
		or not bool(capture.get("ordinary_stock_player_rig", false)) or not bool(capture.get("ordinary_player_rig", false)) \
		or not bool(capture.get("input_reachable_camera_orientation", false)) or bool(capture.get("debug_labels_visible", true)) \
		or bool(capture.get("source_photography_in_frame", true))):
			return false
	var baseline := by_id.get("01-whole-wsw-default", {}) as Dictionary
	var changed := by_id.get("02-whole-wsw-changed-light", {}) as Dictionary
	var grayscale := by_id.get("03-whole-wsw-default-grayscale", {}) as Dictionary
	var oblique := by_id.get("04-wsw-hierarchy-oblique", {}) as Dictionary
	var sprayed := by_id.get("05-close-sprayed-host", {}) as Dictionary
	var projection := baseline.get("whole_wsw_projection", {}) as Dictionary
	var pixel_delta := sprayed.get("rendered_tag_pixel_delta", {}) as Dictionary
	return str(baseline.get("lighting", "")) == "world_default" and str(changed.get("lighting", "")) == "frozen_changed_light" \
		and str(changed.get("same_pose_as", "")) == "01-whole-wsw-default" and bool(changed.get("player_transform_exactly_reused", false)) and bool(changed.get("camera_transform_exactly_reused", false)) \
		and baseline.get("player_position_m", []) == changed.get("player_position_m", []) and baseline.get("camera_position_m", []) == changed.get("camera_position_m", []) and baseline.get("camera_forward", []) == changed.get("camera_forward", []) \
		and bool(projection.get("complete_chain_in_frame", false)) and int(projection.get("visible_vertex_count", -1)) == 40 and float(projection.get("width_pixels", 0.0)) > 800.0 \
		and str(grayscale.get("image_format", "")) == "L8" and str(grayscale.get("derived_from", "")) == "images/01-whole-wsw-default.png" and str(grayscale.get("derived_from_sha256", "")) == str(EXPECTED_HASHES[ROOT + "/images/01-whole-wsw-default.png"]) \
		and str(oblique.get("first_los_hit_receiver", "")) == RECEIVER_KEY and oblique.get("first_los_hit_source_keys", []) == [SOURCE_KEY] \
		and str(sprayed.get("spray_result", "")) == "placed" and str(sprayed.get("spray_first_hit_object", "")) == RECEIVER_KEY and sprayed.get("spray_first_hit_sources", []) == [SOURCE_KEY] \
		and bool(sprayed.get("tag_visible_in_tree", false)) and bool(sprayed.get("tag_clear_of_decorative_bounds", false)) and bool(sprayed.get("sole_host_collider", false)) \
		and bool(pixel_delta.get("ok", false)) and int(pixel_delta.get("changed_pixels_at_or_above_0_03", 0)) >= 800 and float(pixel_delta.get("maximum_rgb_channel_delta", 0.0)) > 0.4


func _motion_matches(motion: Dictionary) -> bool:
	if str(motion.get("schema_version", "")) != "ti.d1-b201-actual-live-motion-evidence/1" \
	or str(motion.get("review_status", "")) != "pending_independent_live_visual_static_and_package_review_not_self_accepted" \
	or str(motion.get("visual_verdict", "")) != "pending_independent_review" or str(motion.get("recognition_metric_frozen", "")) != "6/213" \
	or str(motion.get("generator_sha256", "")) != str(EXPECTED_HASHES[HARNESS]) or str(motion.get("frozen_generator_sha256_argument", "")) != str(EXPECTED_HASHES[HARNESS]) \
	or str(motion.get("movie_sha256", "")) != "sealed_separately_after_movie_writer_close" or int(motion.get("movie_bytes", 0)) != -1 or bool(motion.get("movie_finalized_after_writer_close", true)) \
	or motion.get("render_viewport", []) != [1440.0, 900.0] or int(motion.get("fixed_fps", 0)) != 30 or int(motion.get("physics_ticks_per_second", 0)) != 60 \
	or int(motion.get("motion_physics_frames", 0)) != 360 or not is_equal_approx(float(motion.get("continuous_duration_seconds", 0.0)), 6.0) \
	or str(motion.get("input_action", "")) != "move_forward" or bool(motion.get("run_action_pressed", true)) or bool(motion.get("jetpack_action_pressed", true)) or bool(motion.get("recovery_action_pressed", true)) \
	or int(motion.get("player_transform_writes_after_input_began", -1)) != 0 or int(motion.get("camera_transform_writes_after_input_began", -1)) != 0 or not bool(motion.get("camera_basis_unchanged", false)) \
	or absf(float(motion.get("horizontal_displacement_m", 0.0)) - 23.8790225982666) > 0.0001 \
	or absf(float(motion.get("start_outward_distance_m", 0.0)) - 51.9999961853027) > 0.0001 or absf(float(motion.get("end_outward_distance_m", 0.0)) - 28.1209735870361) > 0.0001 \
	or float(motion.get("direction_dot_inward_normal", 0.0)) < 0.99999 or not bool(motion.get("all_samples_grounded", false)) or not bool(motion.get("all_samples_in_boundary", false)) or not bool(motion.get("all_center_hits_exact_receiver", false)) \
	or int(motion.get("recovery_delta", -1)) != 0 or not _world_matches(motion.get("runtime_topology", {}) as Dictionary) or not _bindings_match(motion.get("bindings", {}) as Dictionary):
		return false
	var process_range := motion.get("review_motion_process_frame_range", []) as Array
	var physics_range := motion.get("review_motion_physics_frame_range", []) as Array
	if process_range != [65.0, 245.0] or physics_range != [131.0, 491.0]:
		return false
	var samples := motion.get("samples", []) as Array
	if samples.size() != 360:
		return false
	var previous_distance := INF
	for index in samples.size():
		var sample := samples[index] as Dictionary
		var distance := float(sample.get("outward_distance_from_chain_mid_m", INF))
		if int(sample.get("frame", 0)) != index + 1 or not bool(sample.get("is_on_floor", false)) or not bool(sample.get("in_boundary", false)) \
		or not bool(sample.get("camera_basis_unchanged", false)) or str(sample.get("center_first_hit_object", "")) != RECEIVER_KEY \
		or sample.get("center_first_hit_sources", []) != [SOURCE_KEY] or distance > previous_distance + 0.001:
			return false
		previous_distance = distance
	var first := samples[0] as Dictionary
	var last := samples[359] as Dictionary
	var first_position := _array_vector3(first.get("player_position_m", []) as Array)
	var last_position := _array_vector3(last.get("player_position_m", []) as Array)
	var post_release_position := _array_vector3(motion.get("end_position_m", []) as Array)
	var sampled_xz_displacement := Vector2(last_position.x - first_position.x, last_position.z - first_position.z).length()
	var post_release_xz_displacement := Vector2(post_release_position.x - first_position.x, post_release_position.z - first_position.z).length()
	var generator := FileAccess.get_file_as_string(HARNESS)
	return first.get("player_position_m", []) == motion.get("start_position_m", []) \
		and absf(float(first.get("outward_distance_from_chain_mid_m", 0.0)) - 51.9999961853027) < 0.00001 \
		and absf(float(last.get("outward_distance_from_chain_mid_m", 0.0)) - 28.2470645904541) < 0.00001 \
		and absf(sampled_xz_displacement - 23.7529758) < 0.0001 \
		and absf((float(first.get("outward_distance_from_chain_mid_m", 0.0)) - float(last.get("outward_distance_from_chain_mid_m", 0.0))) - 23.7529316) < 0.0001 \
		and absf(float(motion.get("start_outward_distance_m", 0.0)) - 51.9999961853027) < 0.00001 \
		and absf(float(motion.get("end_outward_distance_m", 0.0)) - 28.1209735870361) < 0.00001 \
		and absf(float(motion.get("horizontal_displacement_m", 0.0)) - 23.8790225982666) < 0.0001 \
		and absf(post_release_xz_displacement - 23.8790225982666) < 0.0001 \
		and not post_release_position.is_equal_approx(last_position) \
		and generator.contains("Input.action_release(\"move_forward\")\n\tfor _frame in 12:\n\t\tawait physics_frame")


func _seal_matches(seal: Dictionary) -> bool:
	var avi := seal.get("avi_container", {}) as Dictionary
	return str(seal.get("schema_version", "")) == "ti.d1-b201-actual-live-motion-seal/1" \
		and str(seal.get("review_status", "")) == "pending_independent_live_visual_static_and_package_review_not_self_accepted" \
		and str(seal.get("visual_verdict", "")) == "pending_independent_review" and str(seal.get("recognition_metric_frozen", "")) == "6/213" \
		and str(seal.get("generator_sha256", "")) == str(EXPECTED_HASHES[HARNESS]) and str(seal.get("frozen_generator_sha256_argument", "")) == str(EXPECTED_HASHES[HARNESS]) \
		and str(seal.get("stills_manifest_sha256", "")) == str(EXPECTED_HASHES[STILL_MANIFEST]) and str(seal.get("motion_preliminary_sha256", "")) == str(EXPECTED_HASHES[MOTION_MANIFEST]) \
		and str(seal.get("movie_sha256", "")) == str(EXPECTED_HASHES[MOVIE]) and int(seal.get("movie_bytes", 0)) == 27407772 and bool(seal.get("movie_finalized_after_writer_close", false)) \
		and str(avi.get("container", "")) == "RIFF_AVI" and str(avi.get("stream_type", "")) == "vids" and str(avi.get("video_handler", "")) == "MJPG" \
		and int(avi.get("width", 0)) == 1440 and int(avi.get("height", 0)) == 900 and int(avi.get("total_frames", 0)) == 252 and int(avi.get("microseconds_per_frame", 0)) == 33333 \
		and absf(float(avi.get("frame_rate_fps", 0.0)) - 30.000300003) < 0.0001 and absf(float(avi.get("duration_seconds_from_avih", 0.0)) - 8.399916) < 0.0001 and int(avi.get("file_bytes", 0)) == 27407772 \
		and not bool(seal.get("recovered_from_atomic_rename_before_seal", true)) and _world_matches(seal.get("runtime_topology", {}) as Dictionary)


func _bindings_match(bindings: Dictionary) -> bool:
	return str(bindings.get("wall_root_path", "")).ends_with("/building_w34313545_wall") \
		and str(bindings.get("roof_root_path", "")).ends_with("/building_w34313545_roof") \
		and str(bindings.get("attachment_path", "")).ends_with("/building_w34313545_wall/D1B201LiveAttachment") \
		and str(bindings.get("wall_body_path", "")).ends_with("/building_w34313545_wall/Collision") \
		and bindings.get("source_keys", []) == [SOURCE_KEY] and str(bindings.get("decorative_geometry_signature", "")) == DECORATIVE_SIGNATURE \
		and int(bindings.get("host_triangles", -1)) == 80 and int(bindings.get("eligible_warm_triangles", -1)) == 20 and int(bindings.get("protected_generic_triangles", -1)) == 60 \
		and int(bindings.get("decorative_batches", -1)) == 6 and int(bindings.get("decorative_boxes", -1)) == 172 and int(bindings.get("decorative_triangles", -1)) == 2064 \
		and int(bindings.get("structural_body_count", -1)) == 1 and int(bindings.get("structural_shape_count", -1)) == 1 and int(bindings.get("spray_owner_count", -1)) == 1 \
		and int(bindings.get("navigation_owner_count", -1)) == 0 and int(bindings.get("preview_attachment_count", -1)) == 0 \
		and not bool(bindings.get("recognition_accepted", true)) and str(bindings.get("recognition_metric", "")) == "6/213"


func _current_authority_matches() -> bool:
	var registry := _json(REGISTRY)
	var contracts := _json(CONTRACTS)
	var catalog := _json(CATALOG)
	var metric := registry.get("recognition_metric", {}) as Dictionary
	var accepted := metric.get("accepted_physical_unit_ids", []) as Array
	var accepted_matches := accepted.filter(func(value: Variant) -> bool: return str(value) == PHYSICAL_UNIT_ID)
	var adapters := (registry.get("active_runtime_adapters", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == RECEIVER_KEY)
	var plans := (contracts.get("plans", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("receiver_key", "")) == RECEIVER_KEY)
	var units := (registry.get("units", []) as Array).filter(func(value: Variant) -> bool: return str((value as Dictionary).get("unit_id", "")) == PHYSICAL_UNIT_ID)
	if str(catalog.get("schema_version", "")) != "ti.facade-recognition-catalog/7" or str(registry.get("schema_version", "")) != "ti.facade-runtime-registry/7" \
	or str(contracts.get("schema_version", "")) != "ti.facade-runtime-adapter-contracts/6" or accepted_matches.size() != 1 \
	or int(metric.get("numerator", -1)) != 7 or int(metric.get("denominator", -1)) != 213 or str(metric.get("display", "")) != "7/213" \
	or adapters.size() != 1 or plans.size() != 1 or units.size() != 1:
		return false
	var adapter := adapters[0] as Dictionary
	var plan := plans[0] as Dictionary
	var unit := units[0] as Dictionary
	var claim_status := unit.get("claim_status", {}) as Dictionary
	var receipts := unit.get("acceptance_records", []) as Array
	var scope := adapter.get("active_receiver_scope", {}) as Dictionary
	var behavior := plan.get("behavior_contract", {}) as Dictionary
	var acceptance := behavior.get("acceptance_contract", {}) as Dictionary
	var geometry := behavior.get("geometry_contract", {}) as Dictionary
	return str(adapter.get("source_key", "")) == SOURCE_KEY and str(plan.get("source_key", "")) == SOURCE_KEY \
		and str(adapter.get("review_status", "")) == "independent_exact_current_live_pass" \
		and str(adapter.get("review_status_scope", "")) == REVIEW_STATUS_SCOPE \
		and str(adapter.get("recognition_acceptance_authority", "")) == RECOGNITION_ACCEPTANCE_AUTHORITY \
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted" \
		and str(adapter.get("recognition_acceptance_status", "")) == str(claim_status.get("reference_recognizable", "")) \
		and receipts.size() == 1 and str((receipts[0] as Dictionary).get("review_kind", "")) == "independent_reference_recognition" \
		and str((receipts[0] as Dictionary).get("status", "")) == "accept" \
		and str((receipts[0] as Dictionary).get("review_receipt_sha256", "")) == str(EXPECTED_HASHES[REVIEW]) \
		and str((receipts[0] as Dictionary).get("evidence_manifest_sha256", "")) == str(EXPECTED_HASHES[STILL_MANIFEST]) \
		and str(geometry.get("world_topology_scope", "")) == "current_integration_topology" \
		and int(geometry.get("world_records", -1)) == 735 and int(geometry.get("world_mesh_instances", -1)) == 950 \
		and int(geometry.get("world_surfaces", -1)) == 964 and int(geometry.get("world_triangles", -1)) == 66636 \
		and int(geometry.get("world_static_bodies", -1)) == 466 and int(geometry.get("world_shapes", -1)) == 466 \
		and str(adapter.get("runtime_content_mode", "")) == "active_d1_b201_host_partition_attachment" and str(plan.get("content_mode", "")) == "active_d1_b201_host_partition_attachment" \
		and str(scope.get("coverage", "")) == "whole_direct_wall_receiver" and int(scope.get("run_count", -1)) == 40 \
		and _asset_map(adapter.get("runtime_assets", []) as Array) == EXPECTED_RUNTIME_ASSETS and _asset_map(plan.get("runtime_assets", []) as Array) == EXPECTED_RUNTIME_ASSETS and EXPECTED_RUNTIME_ASSETS.size() == 8 \
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty() and (plan.get("projection_descriptor_ids", []) as Array).is_empty() \
		and str(acceptance.get("evidence_manifest_sha256", "")) == str(EXPECTED_HASHES[STILL_MANIFEST]) and str(acceptance.get("independent_live_review_receipt_sha256", "")) == str(EXPECTED_HASHES[REVIEW]) \
		and str(acceptance.get("capture_time_recognition_metric", "")) == "6/213" and int(acceptance.get("numerator_effect", -1)) == 1 and bool(acceptance.get("reference_recognizable", false))


func _world_matches(actual: Dictionary) -> bool:
	for key: String in WORLD:
		if int(actual.get(key, -1)) != int(WORLD[key]):
			return false
	return true


func _evidence_tree_matches() -> bool:
	var actual: Array[String] = []
	_collect_tree(ROOT, ROOT, actual)
	actual.sort()
	var expected: Array[String] = []
	for value: Variant in EXPECTED_EVIDENCE_TREE:
		expected.append(str(value))
	expected.sort()
	return actual == expected


func _collect_tree(directory: String, base: String, output: Array[String]) -> void:
	for file: String in DirAccess.get_files_at(directory):
		output.append(directory.path_join(file).trim_prefix(base + "/"))
	for child: String in DirAccess.get_directories_at(directory):
		_collect_tree(directory.path_join(child), base, output)


func _ledger_matches() -> bool:
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
		if seen.has(path) or (not previous.is_empty() and relative < previous) or not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != hash_value:
			return false
		seen[path] = true
		previous = relative
	for path: String in EXPECTED_HASHES:
		if not seen.has(path):
			return false
	return seen.has("res://game/tests/headless_d1_b201_live_attachment_evidence_contract.gd")


func _asset_map(assets: Array) -> Dictionary:
	var mapped := {}
	for value: Variant in assets:
		var asset := value as Dictionary
		var path := str(asset.get("path", ""))
		if path.is_empty() or mapped.has(path):
			return {}
		mapped[path] = str(asset.get("sha256", ""))
	return mapped


func _array_vector3(values: Array) -> Vector3:
	return Vector3(float(values[0]), float(values[1]), float(values[2])) if values.size() == 3 else Vector3(INF, INF, INF)


func _json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("D1_B201_EVIDENCE_FAIL: %s" % message)
	return false
