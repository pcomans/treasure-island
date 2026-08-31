extends SceneTree

const LIVE_MODULES := preload("res://game/scripts/world/facades/w34313520_live_modules.gd")
const REVIEWED_CALIBRATION := preload("res://game/tests/support/w34313520_exact_receiver_calibration.gd")
const ACCEPTED_FIELDS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const RECEIVER_KEY := "building:w34313520:wall"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_0.json"
const REGISTRY_PATH := "res://game/resources/facades/w34313520_exact_receiver_calibration.json"
const REVIEW_PATH := "res://discovery/facades/W34313520_EXACT_RECEIVER_CALIBRATION_ART_REVIEW.md"
const LIVE_ART_REVIEW_PATH := "res://discovery/facades/W34313520_LIVE_FIELD_AND_BAY_ART_REVIEW.md"
const CORRECTION_REVIEW_PATH := "res://discovery/facades/W34313520_LIVE_EVIDENCE_CORRECTION_ART_REVIEW.md"
const INVENTORY_PATH := "res://discovery/FACADE_RECEIVER_INVENTORY.json"
const CAPTURE_HARNESS_PATH := "res://game/tests/w34313520_live_integration_capture.gd"
const CAPTURE_MANIFEST_PATH := "res://evidence/first-playable/w34313520-live-field-and-bay-2026-08-30/capture-manifest.json"
const EXPECTED_REGISTRY_SHA256 := "28ea8b6e506d747299a920e4d456d8676031e18ec3b6d9e959cab31fa33de4f1"
const EXPECTED_HELPER_SHA256 := "d747d9f9ca5798b09909efeeb930cdee119f1b3c310e95f9a2c426a3ee6ceea4"
const EXPECTED_REVIEW_SHA256 := "555eb2fb3a397341cc6ed6412a627b9d84fe8c806de756c2ed4cbd8a3a652870"
const EXPECTED_LIVE_ART_REVIEW_SHA256 := "f0ad7c169c723a2dfb860aa12065af6da9f9dd91f1d8d9142dec024bdad3c865"
const EXPECTED_CORRECTION_REVIEW_SHA256 := "958130a3cc09cf129186562a9e54f4157bbfad3f99846a695238c3ee4b6b1a46"
const EXPECTED_INVENTORY_SHA256 := "0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f"
const EXPECTED_CAPTURE_IMAGE_HASHES := {
	"01-field-join-r6-r7.png": "49b859d0acd6d02c78b897dd5b3466c85599e13bf4f5efb6316f937c40b451ee",
	"02-field-join-r7-r8.png": "1ff24831d842e9e5fcc1b039539e60d92da047d1d975fcb30bba80e2051ac8fd",
	"03-field-join-r8-r9.png": "826d8b15cc3c18f2cc788b8e370b32acf78b2cc9f9bb243119c060f5cbf4783b",
	"04-field-join-r9-r10.png": "91191eaa0bb9139454c2f864c720841908d65bc68ce6a53ddc07cb1c45a56f7f",
	"05-macro-field-runs6-10.png": "ac6fcd14458ed46e3911dfccffe1d9177ed6440ee68b8218b139094024cc1309",
	"06-bay-close.png": "0af1f1a9dfe6856a550a7e632f4669b37da6bc0ea238674ddf7fd166550e9b40",
	"07-bay-oblique.png": "7f735d6c73616d72702e62fd6775c7e65a464bcc6bceb6d819e780cf01a4ed5d",
	"08-all-runs-ordinary.png": "e78e1ef0c4cb2cd4f9828db2602f2e53d7e5065a1b7a15c99d23108bc90158e4",
	"09-building-sse-context.png": "8dcac7f16b53056d0be48a5f7b819eb0db76969f894691278901058a9a93fa2b",
	"10-changed-light-field-and-bay.png": "1dd25442406c74303c4f44b409a5ad4941c8c99de64f14962de6859303572382",
	"11-whole-island.png": "884b19d93eb1c6c495dcb621589edefbcbde1b7eac91f446b9de5ff9f3117e44",
}
const EXPECTED_STANDALONE_HASHES := {
	"res://game/resources/facades/w34313520_standalone_prototypes.json": "ab80f0cd0424c22f7f24e5fc82211353e9aee7c95bea4903022681a48c5620a4",
	"res://game/resources/materials/world/w34313520/w34313520_pale_field.tres": "7944151fd5ab8e977e7052d0cdb8df20132c82f967d8ebfefff83ede8fcf07a4",
	"res://game/resources/materials/world/w34313520/w34313520_pale_exact_trial.tres": "89fbb97ed797275a86c394af7eab13f946cbf23f29cba58b89a2b2d467030ab2",
	"res://game/resources/materials/world/w34313520/w34313520_bay_frame.tres": "445d3bec9d2ef3130aab27c816b27e384c689af68298b2db5ada37e0178f249b",
	"res://game/resources/materials/world/w34313520/w34313520_bay_glass.tres": "40caf8b054b51ebf247a41286dec9efdbf925f09acf698a75285a4321a41bba6",
	"res://game/scripts/world/facades/w34313520_standalone_prototypes.gd": "1244f590ed0854219f50a25a4c7931f4f094ce19fb65cefcf2d61b8ce4cd8566",
	"res://game/scenes/world/facades/batch_06/w34313520_standalone_prototype_set.tscn": "4d0ee0e79ea6fd5a7e85b21cdf4a103d125818626b6c97875737cad44cc65785",
}
const PROTECTED_RECEIVERS := [
	"building:w34313564:wall",
	"building:w34313515:wall",
	"building:w291196370:wall",
	"building:w34313547:wall",
	"building:w291189336:wall",
	"building:w291189926:wall",
	"building:w764313741:wall",
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "Reviewed exact registry bytes drifted.") \
	or not _require(FileAccess.get_sha256("res://game/tests/support/w34313520_exact_receiver_calibration.gd") == EXPECTED_HELPER_SHA256, "Reviewed exact helper bytes drifted.") \
	or not _require(FileAccess.get_sha256(REVIEW_PATH) == EXPECTED_REVIEW_SHA256, "Independent calibration review bytes drifted.") \
	or not _require(FileAccess.get_sha256(LIVE_ART_REVIEW_PATH) == EXPECTED_LIVE_ART_REVIEW_SHA256, "Independent live art review bytes drifted.") \
	or not _require(FileAccess.get_sha256(CORRECTION_REVIEW_PATH) == EXPECTED_CORRECTION_REVIEW_SHA256, "Accepted correction review bytes drifted.") \
	or not _require(FileAccess.get_sha256(INVENTORY_PATH) == EXPECTED_INVENTORY_SHA256, "Canonical facade inventory bytes drifted.") \
	or not _require(_corrected_capture_evidence_matches_review(), "Corrected live capture evidence is absent, contradictory, or image bytes drifted.") \
	or not _require(_current_lifecycle_is_independently_accepted(), "Current lifecycle does not preserve the distinct independently accepted w34313520 and w34313525 exact scopes."):
		_finish()
		return
	for path: String in EXPECTED_STANDALONE_HASHES:
		if not _require(FileAccess.get_sha256(path) == str(EXPECTED_STANDALONE_HASHES[path]), "Accepted standalone byte drift: %s" % path):
			_finish()
			return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	var record := _record_for(RECEIVER_KEY)
	if not _require(not registry.is_empty() and not record.is_empty(), "Reviewed registry or generated receiver did not resolve."):
		_finish()
		return
	var builder := WorldChunkBuilder.new()
	var first := builder._build_record(record, false)
	var second := builder._build_record(record, false)
	var detached := REVIEWED_CALIBRATION.build(record, registry)
	if not _require(bool(first.get("ok", false)) and bool(second.get("ok", false)) and bool(detached.get("ok", false)), "Live or reviewed detached w34313520 build failed: first=%s second=%s detached=%s" % [first.get("message", first.get("code", "unknown")), second.get("message", second.get("code", "unknown")), detached.get("message", detached.get("code", "unknown"))]):
		_free_result(first)
		_free_result(second)
		_free_result(detached)
		_finish()
		return
	var first_node := first.node as Node3D
	var second_node := second.node as Node3D
	var detached_root := detached.node as Node3D
	if not _require(_receiver_matches(first, record), "Exact live field surface, collision, or single-BAY receiver contract failed.") \
	or not _require(_live_matches_reviewed(first_node, detached_root), "Live BAY drifted from the reviewed transform, complete geometry, asset resources, or inference labels.") \
	or not _require(_field_phase_matches(detached_root), "Reviewed 0.0 m exact field join phase contract drifted.") \
	or not _require(_deterministic(first_node, second_node), "Live w34313520 receiver build is nondeterministic.") \
	or not _require(_protected_receivers_exclude_modules(builder), "A protected receiver gained w34313520 field or BAY scope."):
		first_node.free()
		second_node.free()
		detached_root.free()
		_finish()
		return
	first_node.free()
	second_node.free()
	detached_root.free()
	await _whole_island_matches()
	if not _failed:
		print("PASS: W34313520-MAT-PALE remains independently accepted live only on exact SSE runs 6..10 with exactly one complete backing-free CAL-SSE-BAY-01 at run 7 midpoint; its scope stays distinct from the independently accepted bounded w34313525 scope, and loaded topology is 729 records / 1278 meshes / 1288 surfaces / 55,067 triangles / 466 collider pairs")
	_finish()


func _current_lifecycle_is_independently_accepted() -> bool:
	var inventory := JSON.parse_string(FileAccess.get_file_as_string(INVENTORY_PATH)) as Dictionary
	if inventory.is_empty():
		return false
	var runtime := inventory.get("runtime_material_contract", {}) as Dictionary
	var batch := inventory.get("batch_06_lifecycle_reconciliation", {}) as Dictionary
	var live_fields := batch.get("live_exact_field_summary", {}) as Dictionary
	var live_modules := batch.get("accepted_live_module_summary", {}) as Dictionary
	var w34313520 := batch.get("accepted_live_module_summary_w34313520", {}) as Dictionary
	var w34313525 := batch.get("accepted_live_module_summary_w34313525", {}) as Dictionary
	var object_record := {}
	for value: Variant in inventory.get("objects", []):
		var candidate := value as Dictionary
		if str((candidate.get("source", {}) as Dictionary).get("source_key", "")) == "w34313520":
			object_record = candidate
			break
	var tracker := object_record.get("facade_tracker_status", {}) as Dictionary
	var assignment := object_record.get("runtime_material_assignment", {}) as Dictionary
	return int(runtime.get("accepted_exact_run_material_attachment_count", -1)) == 9 \
		and int(runtime.get("accepted_exact_field_scope_count", -1)) == 11 \
		and int(runtime.get("accepted_exact_run_count", -1)) == 130 \
		and int(runtime.get("accepted_live_module_target_receiver_count", -1)) == 6 \
		and int(runtime.get("accepted_live_module_placement_count", -1)) == 62 \
		and int(runtime.get("accepted_live_module_mesh_count", -1)) == 546 \
		and int(runtime.get("pending_independent_actual_world_art_review_live_module_target_receiver_count", -1)) == 0 \
		and int(runtime.get("pending_independent_actual_world_art_review_live_module_placement_count", -1)) == 0 \
		and int(live_fields.get("independently_accepted_target_receiver_count", -1)) == 6 \
		and int(live_fields.get("independently_accepted_field_scope_count", -1)) == 8 \
		and int(live_fields.get("pending_independent_actual_world_art_review_target_receiver_count", -1)) == 0 \
		and int(live_modules.get("target_receiver_count", -1)) == 6 \
		and int(live_modules.get("placement_count", -1)) == 62 \
		and str(w34313520.get("live_review_verdict", "")) == "KEEP_WITH_DOCUMENTED_LIMITATION" \
		and str(w34313520.get("actual_world_art_review_status", "")) == "independently_reviewed_keep_with_documented_limitation" \
		and int(w34313520.get("placement_count", -1)) == 1 \
		and not bool(w34313520.get("surveyed_dimensions_proven", true)) \
		and not bool(w34313520.get("surveyed_coordinates_proven", true)) \
		and not bool(w34313520.get("real_opening_count_proven", true)) \
		and not bool(w34313520.get("cadence_proven", true)) \
		and not bool(w34313520.get("completed_sse_elevation_proven", true)) \
		and not bool(w34313520.get("whole_building_accepted", true)) \
		and str(w34313525.get("live_review_verdict", "")) == "KEEP_WITH_DOCUMENTED_LIMITATION" \
		and str(w34313525.get("actual_world_art_review_status", "")) == "independently_reviewed_keep_with_documented_limitation" \
		and int(w34313525.get("placement_count", -1)) == 4 \
		and not bool(w34313525.get("surveyed_dimensions_proven", true)) \
		and not bool(w34313525.get("completed_sse_elevation_proven", true)) \
		and not bool(w34313525.get("completed_nnw_elevation_proven", true)) \
		and not bool(w34313525.get("whole_building_accepted", true)) \
		and (batch.get("pending_independent_actual_world_art_review_exact_field_scopes", []) as Array).is_empty() \
		and str(tracker.get("lifecycle_status", "")) == "accepted_exact_run_homogeneous_material_live_with_documented_limitation" \
		and str(assignment.get("target_specific_actual_world_art_review_status", "")) == "independently_reviewed_keep_with_documented_limitation"


func _corrected_capture_evidence_matches_review() -> bool:
	var manifest := JSON.parse_string(FileAccess.get_file_as_string(CAPTURE_MANIFEST_PATH)) as Dictionary
	var harness_source := FileAccess.get_file_as_string(CAPTURE_HARNESS_PATH)
	if manifest.is_empty() or manifest.has("placement") \
	or "func _module_metadata" in harness_source \
	or not manifest.has("live_module_metadata") or not manifest.has("resolved_placement") or not manifest.has("truth_boundary"):
		push_error("Corrected capture schema mismatch: empty=%s placement=%s serializer=%s live=%s resolved=%s truth=%s" % [manifest.is_empty(), manifest.has("placement"), "func _module_metadata" in harness_source, manifest.has("live_module_metadata"), manifest.has("resolved_placement"), manifest.has("truth_boundary")])
		return false
	var live_metadata := manifest.get("live_module_metadata", {}) as Dictionary
	var resolved := manifest.get("resolved_placement", {}) as Dictionary
	var truth := manifest.get("truth_boundary", {}) as Dictionary
	if str(resolved.get("placement_id", "")) != "CAL-SSE-BAY-01" \
	or not is_equal_approx(float(resolved.get("center_uncertainty_half_span_m", -1.0)), 11.144477) \
	or bool(live_metadata.get("surveyed_dimensions", true)) \
	or bool(live_metadata.get("surveyed_coordinates", true)) \
	or bool(live_metadata.get("surveyed_count", true)) \
	or bool(live_metadata.get("surveyed_cadence", true)) \
	or bool(truth.get("dimensions_surveyed", true)) \
	or bool(truth.get("coordinates_surveyed", true)) \
	or bool(truth.get("count_surveyed", true)) \
	or bool(truth.get("cadence_surveyed", true)) \
	or not is_equal_approx(float(truth.get("center_uncertainty_half_span_m", -1.0)), 11.144477):
		push_error("Corrected capture canonical metadata mismatch: live=%s resolved=%s truth=%s" % [JSON.stringify(live_metadata), JSON.stringify(resolved), JSON.stringify(truth)])
		return false
	for filename: String in EXPECTED_CAPTURE_IMAGE_HASHES:
		var path := "res://evidence/first-playable/w34313520-live-field-and-bay-2026-08-30/images/%s" % filename
		if FileAccess.get_sha256(path) != str(EXPECTED_CAPTURE_IMAGE_HASHES[filename]):
			push_error("Corrected capture image hash mismatch: %s expected=%s actual=%s" % [path, EXPECTED_CAPTURE_IMAGE_HASHES[filename], FileAccess.get_sha256(path)])
			return false
	return true


func _receiver_matches(result: Dictionary, record: Dictionary) -> bool:
	var node := result.node as Node3D
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	var live := node.get_node_or_null("W34313520LiveModules") as Node3D
	var field_metadata := node.get_meta("accepted_material_run_trial", {}) as Dictionary
	var live_metadata := node.get_meta("w34313520_live_modules", {}) as Dictionary
	if node.get_child_count() != 3 or mesh == null or body == null or shape == null or live == null \
	or int(result.mesh_instances) != 16 or int(result.surfaces) != 17 or int(result.triangles) != 248 \
	or mesh.get_surface_count() != 2 \
	or mesh.surface_get_name(0) != ACCEPTED_FIELDS.PLACEHOLDER_SURFACE_NAME \
	or mesh.surface_get_name(1) != "trial_w34313520_pale_runs" \
	or mesh.surface_get_material(1).resource_path != "res://game/resources/materials/world/w34313520/w34313520_pale_exact_trial.tres" \
	or _surface_triangles(mesh, 0) != 58 or _surface_triangles(mesh, 1) != 10 \
	or field_metadata != ACCEPTED_FIELDS.metadata_for(RECEIVER_KEY) \
	or str(field_metadata.get("status", "")) != "corrected_prototype_accepted_exact_run_trial_live_receiver_review_pending" \
	or str(field_metadata.get("field_actual_world_review_status", "")) != LIVE_MODULES.ACTUAL_WORLD_REVIEW_STATUS \
	or int(field_metadata.get("modules", -1)) != 1 \
	or int(field_metadata.get("module_motif_types_live", -1)) != 1 \
	or field_metadata.get("module_position_uncertainty_by_placement_m", {}) != {"CAL-SSE-BAY-01": 11.144477} \
	or int(live_metadata.get("module_instances", -1)) != 1 \
	or int(live_metadata.get("mesh_instances", -1)) != 15 \
	or int(live_metadata.get("surfaces", -1)) != 15 \
	or int(live_metadata.get("triangles", -1)) != 180 \
	or int(live_metadata.get("field_meshes", -1)) != 0 \
	or int(live_metadata.get("backing_meshes", -1)) != 0 \
	or int(live_metadata.get("collision_nodes", -1)) != 0 \
	or int(live_metadata.get("navigation_nodes", -1)) != 0 \
	or int(live_metadata.get("spray_nodes", -1)) != 0 \
	or str(live_metadata.get("actual_world_review_status", "")) != LIVE_MODULES.ACTUAL_WORLD_REVIEW_STATUS \
	or bool(live_metadata.get("surveyed_dimensions", true)) \
	or bool(live_metadata.get("surveyed_coordinates", true)) \
	or bool(live_metadata.get("surveyed_scale", true)) \
	or bool(live_metadata.get("surveyed_count", true)) \
	or bool(live_metadata.get("surveyed_cadence", true)) \
	or bool(live_metadata.get("completed_sse_elevation", true)) \
	or bool(live_metadata.get("cross_side_transfer_accepted", true)) \
	or bool(live_metadata.get("whole_building_accepted", true)) \
	or body.collision_layer != ((1 << 0) | (1 << 2)) or body.collision_mask != 0 \
	or not body.is_in_group("spray_receiver_wall") \
	or shape.get_faces().size() != (record.get("indices", []) as Array).size():
		return false
	var material := mesh.surface_get_material(1) as ShaderMaterial
	return material != null \
		and is_equal_approx(float(material.get_shader_parameter("primary_scale_m")), 0.95) \
		and is_equal_approx(float(material.get_shader_parameter("secondary_scale_m")), 0.29)


func _live_matches_reviewed(live_receiver: Node3D, detached_root: Node3D) -> bool:
	var live_root := live_receiver.get_node("W34313520LiveModules") as Node3D
	var live_bay := live_root.get_node_or_null("CAL_SSE_BAY_01") as Node3D
	var detached_bay := detached_root.get_node_or_null("CAL_SSE_BAY_01") as Node3D
	if live_root.get_child_count() != 1 or live_bay == null or detached_bay == null \
	or not live_bay.transform.is_equal_approx(detached_bay.transform) \
	or live_bay.get_child_count() != 15 \
	or _count_type(live_root, MeshInstance3D) != 15 \
	or _count_surfaces(live_root) != 15 or _count_triangles(live_root) != 180 \
	or _count_type(live_root, CollisionObject3D) != 0 \
	or _count_type(live_root, CollisionShape3D) != 0 \
	or _count_type(live_root, NavigationRegion3D) != 0 \
	or _count_type(live_root, Decal) != 0 \
	or str(live_bay.get_meta("placement_id", "")) != "CAL-SSE-BAY-01" \
	or live_bay.get_meta("run_ownership", []) != [7] \
	or not is_equal_approx(float(live_bay.get_meta("along_run_center_m", -1.0)), 15.894477) \
	or str(live_bay.get_meta("host_material_id", "")) != "W34313520-MAT-PALE" \
	or str(live_bay.get_meta("placement_role", "")) != LIVE_MODULES.PLACEMENT_ROLE \
	or not bool(live_bay.get_meta("runtime_attachment", false)) \
	or bool(live_bay.get_meta("coordinates_surveyed", true)) \
	or bool(live_bay.get_meta("dimensions_surveyed", true)) \
	or bool(live_bay.get_meta("scale_surveyed", true)) \
	or bool(live_bay.get_meta("count_surveyed", true)) \
	or bool(live_bay.get_meta("cadence_inferred", true)) \
	or bool(live_bay.get_meta("module_owns_field_geometry", true)) \
	or not bool(live_bay.get_meta("complete_motif", false)) \
	or not bool(live_bay.get_meta("module_not_seamless_tile", false)):
		return false
	for child: Node in live_bay.get_children():
		var live_mesh := child as MeshInstance3D
		var detached_mesh := detached_bay.get_node_or_null(NodePath(str(child.name))) as MeshInstance3D
		if live_mesh == null or detached_mesh == null \
		or not (live_mesh.mesh is BoxMesh) or not (detached_mesh.mesh is BoxMesh) \
		or (live_mesh.mesh as BoxMesh).size != (detached_mesh.mesh as BoxMesh).size \
		or live_mesh.material_override != detached_mesh.material_override \
		or live_mesh.transform != detached_mesh.transform \
		or live_mesh.layers != (1 << 1) \
		or "field" in str(live_mesh.name).to_lower() \
		or "backing" in str(live_mesh.name).to_lower() \
		or "surround" in str(live_mesh.name).to_lower():
			return false
	return true


func _field_phase_matches(detached_root: Node3D) -> bool:
	var scope := detached_root.get_meta("resolved_field_scope", {}) as Dictionary
	if scope.get("exact_ordered_runs", []) != [6, 7, 8, 9, 10] \
	or not is_zero_approx(float(scope.get("maximum_junction_phase_delta_m", -1.0))):
		return false
	for value: Variant in scope.get("run_records", []):
		if not is_zero_approx(float((value as Dictionary).get("previous_junction_phase_delta_m", -1.0))):
			return false
	return true


func _deterministic(first: Node3D, second: Node3D) -> bool:
	var first_root := first.get_node("W34313520LiveModules") as Node3D
	var second_root := second.get_node("W34313520LiveModules") as Node3D
	var first_bay := first_root.get_child(0) as Node3D
	var second_bay := second_root.get_child(0) as Node3D
	return first_bay.transform == second_bay.transform \
		and first.get_meta("accepted_material_run_trial", {}) == second.get_meta("accepted_material_run_trial", {}) \
		and first.get_meta("w34313520_live_modules", {}) == second.get_meta("w34313520_live_modules", {})


func _protected_receivers_exclude_modules(builder: WorldChunkBuilder) -> bool:
	for receiver_key: String in PROTECTED_RECEIVERS:
		var record := _record_for(receiver_key)
		if record.is_empty():
			return false
		var result := builder._build_record(record, false)
		if not bool(result.get("ok", false)):
			return false
		var node := result.node as Node3D
		var ok := node.find_children("W34313520LiveModules", "Node3D", true, false).is_empty()
		node.free()
		if not ok:
			return false
	return true


func _whole_island_matches() -> void:
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	if not _require(packed != null, "Main scene failed to load for w34313520 live proof."):
		return
	var main := packed.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var ready_reports: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready_reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: failures.append({"code": code, "message": message, "source_keys": source_keys.duplicate()}))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while ready_reports.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 50000:
		await process_frame
	if not _require(failures.is_empty() and ready_reports.size() == 1, "Whole island did not reach one clean world_ready."):
		main.queue_free()
		await process_frame
		return
	var evidence := world.get_runtime_evidence()
	var receiver: Node3D = null
	var live_root_count := 0
	for candidate: Node in world.get_node("PlayableWorld/Buildings").find_children("*", "Node3D", true, false):
		if candidate.name == "W34313520LiveModules":
			live_root_count += 1
		if str(candidate.get_meta("derived_object_key", "")) == RECEIVER_KEY and candidate.get_node_or_null("Mesh") != null:
			receiver = candidate as Node3D
	_require(evidence.chunks_loaded == 38 \
		and evidence.mesh_instances == 1278 and evidence.surfaces == 1288 and evidence.triangles == 55067 \
		and evidence.static_bodies == 466 and evidence.shapes == 466 \
		and live_root_count == 1 and receiver != null \
		and receiver.get_child_count() == 3 \
		and _count_type(receiver.get_node("W34313520LiveModules"), MeshInstance3D) == 15,
		"Whole-island w34313520 live field/module topology or isolation drifted: %s" % JSON.stringify(evidence))
	main.queue_free()
	await process_frame


func _record_for(receiver_key: String) -> Dictionary:
	var manifest := JSON.parse_string(FileAccess.get_file_as_string("res://generated/world/manifest.json")) as Dictionary
	for chunk_value: Variant in manifest.get("chunks", []):
		var chunk_path := "res://generated/world/chunks/%s.json" % str((chunk_value as Dictionary).get("chunk_id", ""))
		var chunk := JSON.parse_string(FileAccess.get_file_as_string(chunk_path)) as Dictionary
		for value: Variant in chunk.get("records", []):
			var record := value as Dictionary
			if str(record.get("object_key", "")) == receiver_key:
				return record
	return {}


func _surface_triangles(mesh: ArrayMesh, surface_index: int) -> int:
	return int((mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3)


func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


func _count_surfaces(node: Node) -> int:
	var count := 0
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		count = (node as MeshInstance3D).mesh.get_surface_count()
	for child: Node in node.get_children():
		count += _count_surfaces(child)
	return count


func _count_triangles(node: Node) -> int:
	var count := 0
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		var mesh := (node as MeshInstance3D).mesh
		for surface_index in mesh.get_surface_count():
			count += int((mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3)
	for child: Node in node.get_children():
		count += _count_triangles(child)
	return count


func _free_result(result: Dictionary) -> void:
	var node := result.get("node") as Node
	if node != null:
		node.free()


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
