extends SceneTree

const ART_REVIEW_PATH := "res://discovery/facades/BATCH_06_PROTOTYPE_SET_01_ART_REVIEW.md"
const FIELD_REVIEW_PATH := "res://discovery/facades/BATCH_06_EXACT_RECEIVER_FIELD_TRIALS_ART_REVIEW.md"
const MODULE_REVIEW_PATH := "res://discovery/facades/W34313564_MODULE_CALIBRATION_CORRECTION_ART_REVIEW.md"
const INVENTORY_PATH := "res://discovery/FACADE_RECEIVER_INVENTORY.json"
const HELPER_PATH := "res://game/scripts/world/facades/accepted_material_run_trials.gd"
const LIVE_MODULE_HELPER_PATH := "res://game/scripts/world/facades/w34313564_live_modules.gd"
const W34313515_LIVE_MODULE_HELPER_PATH := "res://game/scripts/world/facades/w34313515_live_modules.gd"
const W34313515_PLACEMENT_REVIEW_PATH := "res://discovery/facades/W34313515_BAY_CALIBRATION_ART_REVIEW.md"
const W34313515_LIVE_REVIEW_PATH := "res://discovery/facades/W34313515_LIVE_MODULES_ART_REVIEW.md"
const W291196370_LIVE_MODULE_HELPER_PATH := "res://game/scripts/world/facades/w291196370_live_modules.gd"
const W291196370_PLACEMENT_REVIEW_PATH := "res://discovery/facades/W291196370_MODULE_CALIBRATION_ART_REVIEW.md"
const W291196370_LIVE_REVIEW_PATH := "res://discovery/facades/W291196370_LIVE_MODULES_ART_REVIEW.md"
const W34313520_LIVE_MODULE_HELPER_PATH := "res://game/scripts/world/facades/w34313520_live_modules.gd"
const W34313520_CALIBRATION_REVIEW_PATH := "res://discovery/facades/W34313520_EXACT_RECEIVER_CALIBRATION_ART_REVIEW.md"
const W34313520_CORRECTION_REVIEW_PATH := "res://discovery/facades/W34313520_LIVE_EVIDENCE_CORRECTION_ART_REVIEW.md"
const W34313525_LIVE_MODULE_HELPER_PATH := "res://game/scripts/world/facades/w34313525_live_modules.gd"
const W34313525_CALIBRATION_REVIEW_PATH := "res://discovery/facades/W34313525_EXACT_RECEIVER_CALIBRATION_ART_REVIEW.md"
const W34313525_LIVE_REVIEW_PATH := "res://discovery/facades/W34313525_LIVE_FIELDS_AND_MODULES_ART_REVIEW.md"
const RUN_MAPPING_PATH := "res://discovery/facades/BATCH_06_RUN_MAPPING.json"
const REGISTRY_PATH := "res://game/resources/facades/batch_06_prototype_registry.json"
const MANIFEST_PATH := "res://generated/world/manifest.json"
const EXPECTED_ART_REVIEW_SHA256 := "bfaccbf182fb04222b5a65356f3287bd7823f5b692d0da6d2d44b2e2af5599eb"
const EXPECTED_FIELD_REVIEW_SHA256 := "ce213c3fb37529eeaefe01da1b555b44b4ea58ab10b36b2150002b8edf6d2bb7"
const EXPECTED_MODULE_REVIEW_SHA256 := "a8f1396e2d126c0c38b37edf770df975c4fa95e25e34fb2c7c1e766630fd1591"
const EXPECTED_INVENTORY_SHA256 := "0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f"
const EXPECTED_HELPER_SHA256 := "d2d4909d5f8cc8a26e7ca77757ceaeebe337131dc33eaece3c7756e2b3d76c9c"
const EXPECTED_LIVE_MODULE_HELPER_SHA256 := "74a7eb9a29750baf47e59194374c2669278bba5af091f5cbe04b13f45c230b8e"
const EXPECTED_W34313515_LIVE_MODULE_HELPER_SHA256 := "8034932d57f8e42ee9c96a1bdd2508d8bf51b52abc0e5d7ff5f2659cbf75ddc7"
const EXPECTED_W34313515_PLACEMENT_REVIEW_SHA256 := "894873141bc589e51bb8ec65e06455461e17a809a18608253db59c7e49e5fedd"
const EXPECTED_W34313515_LIVE_REVIEW_SHA256 := "cebfe328ec5372f8c0d440fcf59bb0b9bae7a490998ed373d8f5c5e418b5b94e"
const EXPECTED_W291196370_LIVE_MODULE_HELPER_SHA256 := "2b4da98b780af42bbc59dce911410c73964f670ce6d58624b77211b7cf981653"
const EXPECTED_W291196370_PLACEMENT_REVIEW_SHA256 := "967ab07d109096a743be01fb0bce959280967f5eab65c82ac0652eb5dcd3023b"
const EXPECTED_W291196370_LIVE_REVIEW_SHA256 := "410ffa891bdebe92d689155b4c7986f7e9a07bef1028900cd0dac00bcb8222ca"
const EXPECTED_W34313520_LIVE_MODULE_HELPER_SHA256 := "765d8546e2fcfca68c855d1e1bcfb93bdcf1b1791c9b71ce4bcd6dcc35fe432e"
const EXPECTED_W34313520_CALIBRATION_REVIEW_SHA256 := "555eb2fb3a397341cc6ed6412a627b9d84fe8c806de756c2ed4cbd8a3a652870"
const EXPECTED_W34313520_CORRECTION_REVIEW_SHA256 := "958130a3cc09cf129186562a9e54f4157bbfad3f99846a695238c3ee4b6b1a46"
const EXPECTED_W34313525_LIVE_MODULE_HELPER_SHA256 := "308cfe8aa3e6320f122f2b81ea74976d30f7d87de91736aeed60e67a01dc121b"
const EXPECTED_W34313525_CALIBRATION_REVIEW_SHA256 := "d19fdae403d11117b13ce1fe04476f0d62edfdd3adbc8238936845e481831de2"
const EXPECTED_W34313525_LIVE_REVIEW_SHA256 := "d11041e1abf41fc11843d2f2631e4c33da25f8fc565f93e6ee822589ad229f45"
const EXPECTED_RUN_MAPPING_SHA256 := "0d9ef02bbdf38902bfddb475f96167abd6460163d94c26984ae5b29da0c7497d"
const EXPECTED_REGISTRY_SHA256 := "a599df850a3ca51a51a3223820fc840201559ba26eb5ed514211eaedc2304132"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const SMOOTH_SHADER_PATH := "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_aperiodic_field.gdshader"
const SIDING_SHADER_PATH := "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader"
const EXPECTED_SMOOTH_SHADER_SHA256 := "d4a9dbb7c58443be93362699b0983b7377dab70698fd782b6710315c31be3e69"
const EXPECTED_SIDING_SHADER_SHA256 := "cb531c7ee029a3cb8d163a644b2adea885606bab89b688df06828c33d3bc6d9a"
const EXPECTED_WORLD_SURFACES := 1288
const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_BUILDING_WALL := 1 << 1

const TARGETS := [
	{
		"source_key": "w34313564",
		"receiver_key": "building:w34313564:wall",
		"chunk": "res://generated/world/chunks/x_0__z_-3.json",
		"chunk_sha256": "6dfa4b8f4b91f309b313428829e37cedd13e4067ff94f896a8e2e5ef05002a1d",
		"run_count": 20,
		"groups": [
			{
				"id": "W34313564-MAT-TAN",
				"surface_name": "trial_w34313564_tan_runs",
				"run_groups": [[5, 6, 7, 8, 9]],
				"runs": [5, 6, 7, 8, 9],
				"length_m": 87.651,
				"mapping_ids": ["B06-34313564-SSE-EAST-RETURN", "B06-34313564-SSE-CENTRAL"],
				"prototype": "res://game/resources/materials/world/w34313564/w34313564_tan_field.tres",
				"prototype_sha256": "2503ee946804bd16db9ca60ae05a0a1b9b6ca7c46422e0997ac2891c79a7ea76",
				"material": "res://game/resources/materials/world/w34313564/w34313564_tan_exact_trial.tres",
				"material_sha256": "3b895743b247a20641cb7564004d2f890bacfc286feaec9044b334b5e8e170bb",
				"shader": SMOOTH_SHADER_PATH,
			},
			{
				"id": "W34313564-MAT-PALE",
				"surface_name": "trial_w34313564_pale_runs",
				"run_groups": [[10, 11, 12, 13, 14, 15, 16, 17, 18, 19]],
				"runs": [10, 11, 12, 13, 14, 15, 16, 17, 18, 19],
				"length_m": 141.340,
				"mapping_ids": ["B06-34313564-ENE-END", "B06-34313564-NNW-OUTER"],
				"prototype": "res://game/resources/materials/world/w34313564/w34313564_pale_field.tres",
				"prototype_sha256": "4523c071e50875db052e98ac39b9d9eff9cfb487aa37344064834ae82c0aae83",
				"material": "res://game/resources/materials/world/w34313564/w34313564_pale_exact_trial.tres",
				"material_sha256": "c7ec2df12b0dcf41e2b5019fd98155dbe3668d16379070210fe9f97ef032a343",
				"shader": SMOOTH_SHADER_PATH,
			},
		],
	},
	{
		"source_key": "w34313515",
		"receiver_key": "building:w34313515:wall",
		"chunk": "res://generated/world/chunks/x_-1__z_1.json",
		"chunk_sha256": "b8696d4feb4157d39969ec039e610af572f25510d712c802d4a96943d6069c8c",
		"run_count": 48,
		"groups": [
			{
				"id": "W34313515-MAT-PALE",
				"surface_name": "trial_w34313515_pale_runs",
				"run_groups": [[0, 1, 2, 3, 4, 5, 6, 7, 8], [43, 44, 45, 46, 47]],
				"runs": [0, 1, 2, 3, 4, 5, 6, 7, 8, 43, 44, 45, 46, 47],
				"length_m": 165.100,
				"mapping_ids": ["B06-34313515-WSW-OUTER", "B06-34313515-NNW-OUTER"],
				"prototype": "res://game/resources/materials/world/w34313515/w34313515_pale_field.tres",
				"prototype_sha256": "0f97c958b35fe8c52e61db532c9caed95566330d9269e4b830e2c319ec47023e",
				"material": "res://game/resources/materials/world/w34313515/w34313515_pale_exact_trial.tres",
				"material_sha256": "0b8704ccc352374adc1d6a553ff3d985ae2b70559d92b5171092450783b4395f",
				"shader": SMOOTH_SHADER_PATH,
			},
		],
	},
	{
		"source_key": "w291196370",
		"receiver_key": "building:w291196370:wall",
		"chunk": "res://generated/world/chunks/x_0__z_-3.json",
		"chunk_sha256": "6dfa4b8f4b91f309b313428829e37cedd13e4067ff94f896a8e2e5ef05002a1d",
		"run_count": 36,
		"groups": [
			{
				"id": "W291196370-SIDING",
				"surface_name": "trial_w291196370_siding_runs",
				"run_groups": [[8, 9, 10], [17, 18, 19, 20, 21, 22]],
				"runs": [8, 9, 10, 17, 18, 19, 20, 21, 22],
				"length_m": 97.893,
				"mapping_ids": ["B06-291196370-SSE-PUBLIC", "B06-291196370-ENE-OUTER"],
				"prototype": "res://game/resources/materials/world/w291196370/w291196370_siding_field.tres",
				"prototype_sha256": "f5c359c34f6e4c61020a49391f0dad04f637730b955ae14195a87260588fce5f",
				"material": "res://game/resources/materials/world/w291196370/w291196370_siding_exact_trial.tres",
				"material_sha256": "715cf02b3c006c1a492ad61def9b2535fbaf04a3b1a41c69c5f092d705fab677",
				"shader": SIDING_SHADER_PATH,
			},
		],
	},
	{
		"source_key": "w34313520",
		"receiver_key": "building:w34313520:wall",
		"chunk": "res://generated/world/chunks/x_-1__z_0.json",
		"chunk_sha256": "b935890b89202fa181248552176364668e506a7630f0024ec86f12a084743d86",
		"run_count": 34,
		"lifecycle_status": "corrected_prototype_accepted_exact_run_trial_live_receiver_review_pending",
		"groups": [
			{
				"id": "W34313520-MAT-PALE",
				"surface_name": "trial_w34313520_pale_runs",
				"run_groups": [[6, 7, 8, 9, 10]],
				"runs": [6, 7, 8, 9, 10],
				"length_m": 68.156,
				"mapping_ids": ["B06-34313520-SSE-OUTER"],
				"prototype": "res://game/resources/materials/world/w34313520/w34313520_pale_field.tres",
				"prototype_sha256": "7944151fd5ab8e977e7052d0cdb8df20132c82f967d8ebfefff83ede8fcf07a4",
				"material": "res://game/resources/materials/world/w34313520/w34313520_pale_exact_trial.tres",
				"material_sha256": "89fbb97ed797275a86c394af7eab13f946cbf23f29cba58b89a2b2d467030ab2",
				"shader": SMOOTH_SHADER_PATH,
			},
		],
	},
	{
		"source_key": "w34313525",
		"receiver_key": "building:w34313525:wall",
		"chunk": "res://generated/world/chunks/x_1__z_-1.json",
		"chunk_sha256": "a952756b1c6d8d547669dffb89723c2be81d6c9a4b3afd2ae7f2dc3702a82b0d",
		"run_count": 30,
		"lifecycle_status": "corrected_prototype_accepted_exact_run_trial_live_receiver_review_pending",
		"groups": [
			{
				"id": "CAL-FIELD-SSE-PALE-01",
				"surface_name": "trial_w34313525_pale_sse_runs",
				"run_groups": [[8, 9, 10, 11, 12]],
				"runs": [8, 9, 10, 11, 12],
				"length_m": 75.310910,
				"mapping_ids": ["B06-34313525-SSE-CENTRAL"],
				"prototype": "res://game/resources/materials/world/w34313525/w34313525_pale_field.tres",
				"prototype_sha256": "00ad40bbc932d7b7d4a3ce77d13a3798f25a35e908bd45a1a5f7f38ba4c80eff",
				"material": "res://game/resources/materials/world/w34313525/w34313525_pale_exact_trial.tres",
				"material_sha256": "d8a4500d3f3ec036b5e0b4c4273caf0644abdc3bda626fb831e2989d63559752",
				"shader": SMOOTH_SHADER_PATH,
			},
			{
				"id": "CAL-FIELD-NNW-PALE-01",
				"surface_name": "trial_w34313525_pale_nnw_runs",
				"run_groups": [[26, 27]],
				"runs": [26, 27],
				"length_m": 15.936560,
				"mapping_ids": ["B06-34313525-NNW-CENTRAL"],
				"prototype": "res://game/resources/materials/world/w34313525/w34313525_pale_field.tres",
				"prototype_sha256": "00ad40bbc932d7b7d4a3ce77d13a3798f25a35e908bd45a1a5f7f38ba4c80eff",
				"material": "res://game/resources/materials/world/w34313525/w34313525_pale_exact_trial.tres",
				"material_sha256": "d8a4500d3f3ec036b5e0b4c4273caf0644abdc3bda626fb831e2989d63559752",
				"shader": SMOOTH_SHADER_PATH,
			},
		],
	},
]

const LIVE_MODULE_IDS := ["W34313564-HWIN", "W34313564-PDOOR", "W34313515-BAY", "W291196370-WINSTACK", "W291196370-ENTRY", "W291196370-SERVICE", "W34313520-BAY", "W34313525-ROLLUP-PALE", "W34313525-ROLLUP-GRAY", "W34313525-PERSONNEL", "W34313525-HIGH-GROUP"]
const EXCLUDED_MODULE_IDS: Array[String] = []

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(ART_REVIEW_PATH) == EXPECTED_ART_REVIEW_SHA256, "Batch 06 independent art review bytes drifted.") \
	or not _require(FileAccess.get_sha256(FIELD_REVIEW_PATH) == EXPECTED_FIELD_REVIEW_SHA256, "Batch 06 exact-receiver art review bytes drifted.") \
	or not _require(FileAccess.get_sha256(MODULE_REVIEW_PATH) == EXPECTED_MODULE_REVIEW_SHA256, "Final corrected w34313564 module review bytes drifted.") \
	or not _require(FileAccess.get_sha256(INVENTORY_PATH) == EXPECTED_INVENTORY_SHA256, "Canonical facade lifecycle inventory bytes drifted.") \
	or not _require(FileAccess.get_sha256(HELPER_PATH) == EXPECTED_HELPER_SHA256, "Promoted Batch 06 accepted-material helper bytes drifted.") \
	or not _require(FileAccess.get_sha256(LIVE_MODULE_HELPER_PATH) == EXPECTED_LIVE_MODULE_HELPER_SHA256, "Approved w34313564 live-module helper bytes drifted.") \
	or not _require(FileAccess.get_sha256(W34313515_LIVE_MODULE_HELPER_PATH) == EXPECTED_W34313515_LIVE_MODULE_HELPER_SHA256, "Placement-approved w34313515 live-module helper bytes drifted.") \
	or not _require(FileAccess.get_sha256(W34313515_PLACEMENT_REVIEW_PATH) == EXPECTED_W34313515_PLACEMENT_REVIEW_SHA256, "Independent w34313515 placement review bytes drifted.") \
	or not _require(FileAccess.get_sha256(W34313515_LIVE_REVIEW_PATH) == EXPECTED_W34313515_LIVE_REVIEW_SHA256, "Independent w34313515 actual-world review bytes drifted.") \
	or not _require(FileAccess.get_sha256(W291196370_LIVE_MODULE_HELPER_PATH) == EXPECTED_W291196370_LIVE_MODULE_HELPER_SHA256, "Placement-approved w291196370 live-module helper bytes drifted.") \
	or not _require(FileAccess.get_sha256(W291196370_PLACEMENT_REVIEW_PATH) == EXPECTED_W291196370_PLACEMENT_REVIEW_SHA256, "Independent w291196370 detached placement review bytes drifted.") \
	or not _require(FileAccess.get_sha256(W34313520_LIVE_MODULE_HELPER_PATH) == EXPECTED_W34313520_LIVE_MODULE_HELPER_SHA256, "Placement-approved w34313520 live-module helper bytes drifted.") \
	or not _require(FileAccess.get_sha256(W34313520_CALIBRATION_REVIEW_PATH) == EXPECTED_W34313520_CALIBRATION_REVIEW_SHA256, "Independent w34313520 exact calibration review bytes drifted.") \
	or not _require(FileAccess.get_sha256(W34313520_CORRECTION_REVIEW_PATH) == EXPECTED_W34313520_CORRECTION_REVIEW_SHA256, "Accepted w34313520 correction review bytes drifted.") \
	or not _require(FileAccess.get_sha256(W34313525_LIVE_MODULE_HELPER_PATH) == EXPECTED_W34313525_LIVE_MODULE_HELPER_SHA256, "Placement-approved w34313525 live-module helper bytes drifted.") \
	or not _require(FileAccess.get_sha256(W34313525_CALIBRATION_REVIEW_PATH) == EXPECTED_W34313525_CALIBRATION_REVIEW_SHA256, "Independent w34313525 calibration review bytes drifted.") \
	or not _require(FileAccess.get_sha256(W34313525_LIVE_REVIEW_PATH) == EXPECTED_W34313525_LIVE_REVIEW_SHA256, "Independent w34313525 actual-world review bytes drifted.") \
	or not _require(FileAccess.get_sha256(RUN_MAPPING_PATH) == EXPECTED_RUN_MAPPING_SHA256, "Final Batch 06 run mapping bytes drifted.") \
	or not _require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "Reviewed Batch 06 prototype registry bytes drifted.") \
	or not _require(FileAccess.get_sha256(MANIFEST_PATH) == EXPECTED_MANIFEST_SHA256, "Generated manifest bytes drifted.") \
	or not _require(FileAccess.get_sha256(SMOOTH_SHADER_PATH) == EXPECTED_SMOOTH_SHADER_SHA256, "Batch 06 wall-tangent smooth shader bytes drifted.") \
	or not _require(FileAccess.get_sha256(SIDING_SHADER_PATH) == EXPECTED_SIDING_SHADER_SHA256, "Batch 06 wall-tangent siding shader bytes drifted.") \
	or not _require(_projection_sources_match(), "Batch 06 shaders lost orientation-invariant wall-tangent/vertical metre projection or opaque filtering.") \
	or not _require(_reviews_and_runtime_scope_match(), "Batch 06 review/lifecycle scope, plinth hold, or standalone-module exclusion drifted."):
		_finish()
		return
	var accepted_keys := AcceptedMaterialRunTrials.BATCH_06_ACCEPTED_TARGETS.keys()
	accepted_keys.sort()
	if not _require(accepted_keys == ["building:w291196370:wall", "building:w34313515:wall", "building:w34313520:wall", "building:w34313525:wall", "building:w34313564:wall"], "Live Batch 06 receiver set broadened or narrowed."):
		_finish()
		return
	var mapping := JSON.parse_string(FileAccess.get_file_as_string(RUN_MAPPING_PATH)) as Dictionary
	var builder := WorldChunkBuilder.new()
	for target_value: Variant in TARGETS:
		var target := target_value as Dictionary
		if not _require(FileAccess.get_sha256(str(target.chunk)) == str(target.chunk_sha256), "Generated chunk bytes drifted for %s." % str(target.source_key)) \
		or not _require(_mapping_groups_match(mapping, target), "Exact observed run groups drifted for %s." % str(target.source_key)) \
		or not _require(_materials_match(target), "Reviewed source or target-specific exact-run material drifted for %s." % str(target.source_key)):
			_finish()
			return
		var record := _load_record(str(target.chunk), str(target.receiver_key))
		var first_result := builder._build_record(record, false)
		var second_result := builder._build_record(record, false)
		if not _require(bool(first_result.get("ok", false)) and bool(second_result.get("ok", false)), "Accepted Batch 06 receiver failed to build for %s." % str(target.source_key)):
			_free_result(first_result)
			_free_result(second_result)
			_finish()
			return
		var first := first_result.node as Node3D
		var second := second_result.node as Node3D
		if not _require(_receiver_matches(first, record, target), "Exact partition/noninterference contract failed for %s." % str(target.source_key)) \
		or not _require(_two_builds_match(first, second), "Accepted Batch 06 partition is nondeterministic for %s." % str(target.source_key)):
			first.free()
			second.free()
			_finish()
			return
		first.free()
		second.free()
	var whole := await _whole_island_matches()
	if not _require(bool(whole.get("ok", false)), str(whole.get("message", "Whole-island accepted-material load failed."))):
		_finish()
		return
	print("PASS: eight Batch 06/Building 1 homogeneous scopes remain independently accepted on 113 runs with 62 exact live module placements across six receivers; Building 1's reversible 63-run/45-module recognizability composition is independently accepted with its production-inference limits, pending review is zero, protected complements stay unchanged, and world topology is 729/1278/1288/55,067/466")
	_finish()


func _projection_sources_match() -> bool:
	for path in [SMOOTH_SHADER_PATH, SIDING_SHADER_PATH]:
		var source := FileAccess.get_file_as_string(path)
		if not "render_mode depth_draw_opaque, cull_back;" in source \
		or not "vec2 horizontal_normal = normalize(NORMAL.xz);" in source \
		or not "vec2 wall_tangent = vec2(horizontal_normal.y, -horizontal_normal.x);" in source \
		or not "field_position_m = vec2(dot(VERTEX.xz, wall_tangent), VERTEX.y);" in source \
		or not "fwidth(" in source:
			return false
		for forbidden in ["UV", "TIME", "discard", "ALPHA =", "sampler2D"]:
			if forbidden in source:
				return false
	return "course_phase = field_position_m.y / max(course_height_m" in FileAccess.get_file_as_string(SIDING_SHADER_PATH)


func _reviews_and_runtime_scope_match() -> bool:
	var prototype_review := FileAccess.get_file_as_string(ART_REVIEW_PATH)
	if not "Five homogeneous fields: ACCEPT_WITH_SCALE_LIMITATION as standalone prototypes" in prototype_review \
	or not "Plinth stays proxy-only until its vertical extent and side bounds are calibrated" in prototype_review \
	or not "Six complete modules: REJECT_CORRECTABLE" in prototype_review:
		return false
	var field_review := FileAccess.get_file_as_string(FIELD_REVIEW_PATH)
	if not "All four exact-receiver homogeneous-field scopes: ACCEPT_WITH_LIMITATION" in field_review \
	or not "eligible for a separate lifecycle-promotion decision" in field_review \
	or not "W34313564-MAT-PLINTH" in field_review:
		return false
	var module_review := FileAccess.get_file_as_string(MODULE_REVIEW_PATH)
	if not "Aggregate five-exemplar detached layout" in module_review \
	or not "ELIGIBLE_WITH_DOCUMENTED_LIMITATION" in module_review \
	or not "stylized/reference-derived production inference" in module_review:
		return false
	var bay_review := FileAccess.get_file_as_string(W34313515_PLACEMENT_REVIEW_PATH)
	if not "Aggregate calibration verdict: `ACCEPT_WITH_DOCUMENTED_LIMITATION`" in bay_review \
	or not "Eligible as one bounded four-exemplar integration set" in bay_review \
	or not "stylized, reference-derived production inference" in bay_review:
		return false
	var live_bay_review := FileAccess.get_file_as_string(W34313515_LIVE_REVIEW_PATH)
	if not "Aggregate live verdict: `KEEP_WITH_DOCUMENTED_LIMITATION`" in live_bay_review \
	or not "The lifecycle **may promote exactly these four rows**" in live_bay_review \
	or not "whole-building acceptance" in live_bay_review:
		return false
	var live_w291196370_review := FileAccess.get_file_as_string(W291196370_LIVE_REVIEW_PATH)
	if FileAccess.get_sha256(W291196370_LIVE_REVIEW_PATH) != EXPECTED_W291196370_LIVE_REVIEW_SHA256 \
	or not "Aggregate actual-world verdict: `KEEP_WITH_DOCUMENTED_LIMITATION`" in live_w291196370_review \
	or not "The lifecycle may promote **exactly these three rows**" in live_w291196370_review \
	or not "whole-building resemblance" in live_w291196370_review:
		return false
	var w34313520_review := FileAccess.get_file_as_string(W34313520_CORRECTION_REVIEW_PATH)
	if not "Correction verdict: ACCEPT." in w34313520_review \
	or not "KEEP_WITH_DOCUMENTED_LIMITATION" in w34313520_review \
	or not "CAL-SSE-BAY-01" in w34313520_review \
	or not "whole-building" in w34313520_review:
		return false
	var w34313525_review := FileAccess.get_file_as_string(W34313525_LIVE_REVIEW_PATH)
	if not "Aggregate exact live scope" in w34313525_review \
	or not "KEEP_WITH_DOCUMENTED_LIMITATION" in w34313525_review \
	or not "Promote precisely two field scopes / seven runs and four placements" in w34313525_review \
	or not "whole-building resemblance" in w34313525_review:
		return false
	var inventory := JSON.parse_string(FileAccess.get_file_as_string(INVENTORY_PATH)) as Dictionary
	var lifecycle := inventory.get("batch_06_lifecycle_reconciliation", {}) as Dictionary
	var runtime_contract := inventory.get("runtime_material_contract", {}) as Dictionary
	var progress_summary := inventory.get("facade_progress_summary", {}) as Dictionary
	var aggregate_modules := lifecycle.get("accepted_live_module_summary", {}) as Dictionary
	var placement_approved_modules := lifecycle.get("placement_approved_live_module_summary", {}) as Dictionary
	var w34313515_modules := lifecycle.get("accepted_live_module_summary_w34313515", {}) as Dictionary
	var w291196370_modules := lifecycle.get("accepted_live_module_summary_w291196370", {}) as Dictionary
	var w34313520_modules := lifecycle.get("accepted_live_module_summary_w34313520", {}) as Dictionary
	var w34313525_modules := lifecycle.get("accepted_live_module_summary_w34313525", {}) as Dictionary
	var building_1_modules := lifecycle.get("accepted_live_module_summary_building_1", {}) as Dictionary
	var live_fields := lifecycle.get("live_exact_field_summary", {}) as Dictionary
	var pending_recognizability := lifecycle.get("pending_independent_recognizability_review_summary", {}) as Dictionary
	if lifecycle.get("accepted_exact_run_homogeneous_material_live_with_documented_limitation_source_keys", []) != ["w34313515", "w34313564", "w291196370", "w34313520", "w34313525", "r16681702"] \
	or int((lifecycle.get("accepted_exact_field_summary", {}) as Dictionary).get("field_scope_count", -1)) != 8 \
	or int((lifecycle.get("accepted_exact_field_summary", {}) as Dictionary).get("run_count", -1)) != 113 \
	or int(aggregate_modules.get("target_receiver_count", -1)) != 6 \
	or int(aggregate_modules.get("placement_count", -1)) != 62 \
	or int(aggregate_modules.get("mesh_instances", -1)) != 546 \
	or int(aggregate_modules.get("triangles", -1)) != 6552 \
	or int(placement_approved_modules.get("target_receiver_count", -1)) != 6 \
	or int(placement_approved_modules.get("placement_count", -1)) != 62 \
	or int(live_fields.get("target_receiver_count", -1)) != 6 \
	or int(live_fields.get("field_scope_count", -1)) != 8 \
	or int(live_fields.get("run_count", -1)) != 113 \
	or int(live_fields.get("independently_accepted_target_receiver_count", -1)) != 6 \
	or int(live_fields.get("independently_accepted_field_scope_count", -1)) != 8 \
	or int(live_fields.get("pending_independent_actual_world_art_review_target_receiver_count", -1)) != 0 \
	or int(live_fields.get("pending_independent_actual_world_art_review_field_scope_count", -1)) != 0 \
	or int(pending_recognizability.get("target_receiver_count", -1)) != 0 \
	or int(pending_recognizability.get("field_extension_run_count", -1)) != 0 \
	or int(pending_recognizability.get("module_placement_count", -1)) != 0 \
	or str(pending_recognizability.get("status", "")) != "no_pending_independent_recognizability_review" \
	or int(building_1_modules.get("placement_count", -1)) != 45 \
	or int(building_1_modules.get("mesh_instances", -1)) != 351 \
	or int(building_1_modules.get("triangles", -1)) != 4212 \
	or str(building_1_modules.get("independent_live_review_sha256", "")) != "328973362b873b80ec8255c78ad7851369db850d3d9bc3f95b31064f83bb584c" \
	or bool(building_1_modules.get("surveyed_coordinates_proven", true)) \
	or bool(building_1_modules.get("real_count_proven", true)) \
	or bool(building_1_modules.get("cadence_proven", true)) \
	or bool(building_1_modules.get("completed_elevation_proven", true)) \
	or bool(building_1_modules.get("whole_building_accepted", true)) \
	or int(w34313515_modules.get("placement_count", -1)) != 4 \
	or str(w34313515_modules.get("live_review_verdict", "")) != "KEEP_WITH_DOCUMENTED_LIMITATION" \
	or str(w34313515_modules.get("actual_world_art_review_status", "")) != "independently_reviewed_keep_with_documented_limitation" \
	or bool(w34313515_modules.get("completed_elevation_proven", true)) \
	or bool(w34313515_modules.get("whole_building_accepted", true)) \
	or int(w291196370_modules.get("placement_count", -1)) != 3 \
	or str(w291196370_modules.get("live_review_verdict", "")) != "KEEP_WITH_DOCUMENTED_LIMITATION" \
	or str(w291196370_modules.get("actual_world_art_review_status", "")) != "independently_reviewed_keep_with_documented_limitation" \
	or bool(w291196370_modules.get("surveyed_scale_proven", true)) \
	or bool(w291196370_modules.get("surveyed_coordinates_proven", true)) \
	or bool(w291196370_modules.get("real_opening_count_proven", true)) \
	or bool(w291196370_modules.get("cadence_proven", true)) \
	or bool(w291196370_modules.get("cross_side_transfer_proven", true)) \
	or bool(w291196370_modules.get("completed_sse_elevation_proven", true)) \
	or bool(w291196370_modules.get("completed_ene_elevation_proven", true)) \
	or bool(w291196370_modules.get("whole_building_accepted", true)) \
	or int(w34313520_modules.get("placement_count", -1)) != 1 \
	or str(w34313520_modules.get("live_review_verdict", "")) != "KEEP_WITH_DOCUMENTED_LIMITATION" \
	or str(w34313520_modules.get("actual_world_art_review_status", "")) != "independently_reviewed_keep_with_documented_limitation" \
	or bool(w34313520_modules.get("surveyed_dimensions_proven", true)) \
	or bool(w34313520_modules.get("surveyed_coordinates_proven", true)) \
	or bool(w34313520_modules.get("real_opening_count_proven", true)) \
	or bool(w34313520_modules.get("cadence_proven", true)) \
	or bool(w34313520_modules.get("completed_sse_elevation_proven", true)) \
	or bool(w34313520_modules.get("whole_building_accepted", true)) \
	or int(w34313525_modules.get("placement_count", -1)) != 4 \
	or str(w34313525_modules.get("live_review_verdict", "")) != "KEEP_WITH_DOCUMENTED_LIMITATION" \
	or str(w34313525_modules.get("actual_world_art_review_status", "")) != "independently_reviewed_keep_with_documented_limitation" \
	or str(w34313525_modules.get("independent_live_review_sha256", "")) != EXPECTED_W34313525_LIVE_REVIEW_SHA256 \
	or bool(w34313525_modules.get("surveyed_dimensions_proven", true)) \
	or bool(w34313525_modules.get("surveyed_scale_proven", true)) \
	or bool(w34313525_modules.get("surveyed_coordinates_proven", true)) \
	or bool(w34313525_modules.get("real_opening_count_proven", true)) \
	or bool(w34313525_modules.get("cadence_proven", true)) \
	or bool(w34313525_modules.get("sequence_proven", true)) \
	or bool(w34313525_modules.get("maximum_uncertainty_envelope_contained_for_all_modules", true)) \
	or bool(w34313525_modules.get("high_group_semantic_face_resolved", true)) \
	or bool(w34313525_modules.get("completed_sse_elevation_proven", true)) \
	or bool(w34313525_modules.get("completed_nnw_elevation_proven", true)) \
	or bool(w34313525_modules.get("whole_building_accepted", true)) \
	or int(runtime_contract.get("accepted_exact_run_material_attachment_count", -1)) != 9 \
	or int(runtime_contract.get("accepted_exact_field_scope_count", -1)) != 11 \
	or int(runtime_contract.get("accepted_exact_run_count", -1)) != 130 \
	or not is_equal_approx(float(runtime_contract.get("accepted_exact_run_length_m", -1.0)), 1024.828178) \
	or not is_equal_approx(float(runtime_contract.get("accepted_exact_run_wall_area_m2", -1.0)), 10476.046427) \
	or int(runtime_contract.get("accepted_live_module_target_receiver_count", -1)) != 6 \
	or int(runtime_contract.get("accepted_live_module_placement_count", -1)) != 62 \
	or int(runtime_contract.get("accepted_live_module_mesh_count", -1)) != 546 \
	or int(runtime_contract.get("accepted_live_module_triangle_count", -1)) != 6552 \
	or int(runtime_contract.get("live_exact_run_material_attachment_count", -1)) != 9 \
	or int(runtime_contract.get("live_exact_field_scope_count", -1)) != 11 \
	or int(runtime_contract.get("live_exact_run_count", -1)) != 130 \
	or int(runtime_contract.get("placement_approved_live_module_target_receiver_count", -1)) != 6 \
	or int(runtime_contract.get("placement_approved_live_module_placement_count", -1)) != 62 \
	or int(runtime_contract.get("pending_independent_actual_world_art_review_live_module_target_receiver_count", -1)) != 0 \
	or int(runtime_contract.get("pending_independent_actual_world_art_review_live_module_placement_count", -1)) != 0 \
	or (runtime_contract.get("pending_independent_actual_world_art_review_runtime_attachments", []) as Array).size() != 0 \
	or (lifecycle.get("pending_independent_actual_world_art_review_exact_field_scopes", []) as Array).size() != 0 \
	or int(runtime_contract.get("pending_independent_recognizability_live_module_placement_count", -1)) != 0 \
	or (runtime_contract.get("pending_independent_recognizability_review_runtime_attachments", []) as Array).size() != 0 \
	or progress_summary.get("accepted_live_module_source_keys", []) != ["w34313515", "w34313564", "w291196370", "w34313520", "w34313525", "r16681702"] \
	or progress_summary.get("corrected_prototype_exact_run_trial_live_pending_review_source_keys", []) != [] \
	or progress_summary.get("recognizability_composition_pending_independent_review_source_keys", []) != []:
		return false
	var helper := FileAccess.get_file_as_string(HELPER_PATH)
	if not "W34313564-MAT-PLINTH remains standalone" in helper \
	or "w34313564_plinth_exact_trial" in helper:
		return false
	for module_id in LIVE_MODULE_IDS + EXCLUDED_MODULE_IDS:
		if module_id in helper:
			return false
	for forbidden_path in ["w34313564_door.tres", "w34313564_frame.tres", "w34313564_glass.tres", "w34313515_frame.tres", "w34313515_glass.tres", "w291196370_entry.tres", "w291196370_service.tres", "w291196370_trim.tres", "w291196370_glass.tres", "w34313520_bay_frame.tres", "w34313520_bay_glass.tres", "w34313525_rollup_pale.tres", "w34313525_rollup_gray.tres", "w34313525_personnel.tres", "w34313525_high_group.tres"]:
		if forbidden_path in helper:
			return false
	return FileAccess.get_sha256("res://game/resources/materials/world/w34313564/w34313564_plinth_field.tres") == "89a36e7fb036bf8bd3f5db0996076c477641e2c7e97d29537c2c464155b12d88"


func _mapping_groups_match(mapping: Dictionary, target: Dictionary) -> bool:
	var mapped_target := {}
	for target_value: Variant in mapping.get("targets", []):
		var candidate := target_value as Dictionary
		if str(candidate.get("source_key", "")) == str(target.source_key):
			mapped_target = candidate
			break
	if mapped_target.is_empty() or str(mapped_target.get("receiver", "")) != str(target.receiver_key) \
	or int(mapped_target.get("height_m", -1)) <= 0:
		return false
	var mappings_by_id := {}
	for mapping_value: Variant in mapped_target.get("mappings", []):
		var group := mapping_value as Dictionary
		mappings_by_id[str(group.mapping_id)] = group
	for group_value: Variant in target.groups:
		var expected := group_value as Dictionary
		var mapped_runs: Array[int] = []
		var mapped_length := 0.0
		for mapping_id: String in expected.mapping_ids:
			if not mappings_by_id.has(mapping_id):
				return false
			var mapped := mappings_by_id[mapping_id] as Dictionary
			if not bool(mapped.get("contiguous", false)):
				return false
			mapped_runs.append_array(_int_array(mapped.get("run_indices", []) as Array))
			mapped_length += float(mapped.get("total_length_m", 0.0))
		mapped_runs.sort()
		if mapped_runs != _int_array(expected.runs as Array) or absf(mapped_length - float(expected.length_m)) > 0.002:
			return false
	return true


func _materials_match(target: Dictionary) -> bool:
	for group_value: Variant in target.groups:
		var group := group_value as Dictionary
		if FileAccess.get_sha256(str(group.prototype)) != str(group.prototype_sha256) \
		or FileAccess.get_sha256(str(group.material)) != str(group.material_sha256):
			return false
		var prototype := load(str(group.prototype)) as ShaderMaterial
		var exact_receiver_material := load(str(group.material)) as ShaderMaterial
		var expected_name_suffix := "exact_receiver_detached_trial" if str(target.source_key) == "w34313520" else "exact_receiver_trial"
		if prototype == null or exact_receiver_material == null or exact_receiver_material.shader == null \
		or exact_receiver_material.shader.resource_path != str(group.shader) \
		or not exact_receiver_material.resource_name.ends_with(expected_name_suffix):
			return false
		var parameters := ["base_color", "roughness_value", "relief_strength", "color_variation", "filter_start_cycles_per_pixel", "filter_end_cycles_per_pixel"]
		parameters.append("seam_color" if str(group.id) == "W291196370-SIDING" else "secondary_color")
		parameters.append("course_height_m" if str(group.id) == "W291196370-SIDING" else "primary_scale_m")
		if str(group.id) != "W291196370-SIDING":
			parameters.append_array(["field_kind", "secondary_scale_m"])
		for parameter: String in parameters:
			if not _values_match(prototype.get_shader_parameter(parameter), exact_receiver_material.get_shader_parameter(parameter)):
				return false
	return true


func _receiver_matches(node: Node3D, record: Dictionary, target: Dictionary) -> bool:
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	if mesh_instance == null or body == null or shape == null or not (mesh_instance.mesh is ArrayMesh):
		return false
	var mesh := mesh_instance.mesh as ArrayMesh
	var is_w34313564_live_receiver := str(target.source_key) == "w34313564"
	var is_w34313515_live_receiver := str(target.source_key) == "w34313515"
	var is_w291196370_live_receiver := str(target.source_key) == "w291196370"
	var is_w34313520_live_receiver := str(target.source_key) == "w34313520"
	var is_w34313525_live_receiver := str(target.source_key) == "w34313525"
	var is_live_module_receiver := is_w34313564_live_receiver or is_w34313515_live_receiver or is_w291196370_live_receiver or is_w34313520_live_receiver or is_w34313525_live_receiver
	var expected_child_count := 3 if is_live_module_receiver else 2
	var expected_mesh_count := 35 if is_w34313564_live_receiver else (85 if is_w34313515_live_receiver else (25 if is_w291196370_live_receiver else (16 if is_w34313520_live_receiver else (39 if is_w34313525_live_receiver else 1))))
	var expected_module_count := 5 if is_w34313564_live_receiver else (4 if is_w34313515_live_receiver or is_w34313525_live_receiver else (3 if is_w291196370_live_receiver else (1 if is_w34313520_live_receiver else 0)))
	var expected_status := str(target.get("lifecycle_status", AcceptedMaterialRunTrials.BATCH_06_ACCEPTED_STATUS))
	var metadata_text := JSON.stringify(node.get_meta("accepted_material_run_trial", {}))
	var limitation_matches := ("unmeasured production inference" in metadata_text) if is_w34313520_live_receiver or is_w34313525_live_receiver else ("unmeasured reversible assumption" in metadata_text)
	if node.transform != Transform3D.IDENTITY \
	or node.get_child_count() != expected_child_count \
	or mesh.get_surface_count() != 1 + (target.groups as Array).size() \
	or mesh.surface_get_name(0) != AcceptedMaterialRunTrials.PLACEHOLDER_SURFACE_NAME \
	or not (mesh.surface_get_material(0) is StandardMaterial3D) \
	or mesh.surface_get_material(0).resource_name != "building_wall":
		return false
	var accepted_runs: Array[int] = []
	for group_index in (target.groups as Array).size():
		var group := (target.groups as Array)[group_index] as Dictionary
		var surface_index := group_index + 1
		if mesh.surface_get_name(surface_index) != str(group.surface_name) \
		or mesh.surface_get_material(surface_index).resource_path != str(group.material) \
		or _runs_for_surface(mesh, surface_index) != _int_array(group.runs as Array) \
		or absf(_run_length(record, _int_array(group.runs as Array)) - float(group.length_m)) > 0.002 \
		or not _projection_matches_runs(record, _int_array(group.runs as Array)):
			return false
		accepted_runs.append_array(_int_array(group.runs as Array))
	accepted_runs.sort()
	var placeholder_expected: Array[int] = []
	for run_index in int(target.run_count):
		if not accepted_runs.has(run_index):
			placeholder_expected.append(run_index)
	if _runs_for_surface(mesh, 0) != placeholder_expected:
		return false
	var metadata := node.get_meta("accepted_material_run_trial", {}) as Dictionary
	if metadata != AcceptedMaterialRunTrials.metadata_for(str(target.receiver_key)) \
	or str(metadata.get("status", "")) != expected_status \
	or int(metadata.get("modules", -1)) != expected_module_count \
	or int(metadata.get("standalone_modules_live", -1)) != expected_module_count \
	or not limitation_matches \
	or not "placeholder-only" in str(metadata.get("standalone_blocker", "")) and str(target.source_key) != "w34313564":
		return false
	var render_triangles := _triangle_signatures_for_mesh(mesh)
	var collision_triangles := _triangle_signatures_for_faces(shape.get_faces())
	return not render_triangles.is_empty() \
		and render_triangles.size() == (record.indices as Array).size() / 3 \
		and _sorted_keys(render_triangles) == _sorted_keys(collision_triangles) \
		and mesh.get_faces().size() == (record.indices as Array).size() \
		and shape.get_faces().size() == (record.indices as Array).size() \
		and mesh_instance.layers == RENDER_BUILDING_WALL \
		and body.collision_layer == (1 | PHYSICS_SPRAY_SURFACE) and body.collision_mask == 0 \
		and body.is_in_group("spray_receiver_wall") \
		and str(body.get_meta("derived_object_key", "")) == str(target.receiver_key) \
		and body.get_meta("source_keys", []) == [str(target.source_key)] \
		and (node.find_children("*", "MeshInstance3D", true, false) as Array).size() == expected_mesh_count \
		and (node.find_children("*", "CollisionObject3D", true, false) as Array).size() == 1 \
		and (node.find_children("*", "NavigationRegion3D", true, false) as Array).is_empty() \
		and (node.find_children("*Facade*", "Node", true, false) as Array).is_empty() \
		and ((node.get_node_or_null("W34313564LiveModules") as Node3D) != null) == is_w34313564_live_receiver \
		and ((node.get_node_or_null("W34313515LiveModules") as Node3D) != null) == is_w34313515_live_receiver \
		and ((node.get_node_or_null("W291196370LiveModules") as Node3D) != null) == is_w291196370_live_receiver \
		and ((node.get_node_or_null("W34313520LiveModules") as Node3D) != null) == is_w34313520_live_receiver \
		and ((node.get_node_or_null("W34313525LiveModules") as Node3D) != null) == is_w34313525_live_receiver


func _projection_matches_runs(record: Dictionary, runs: Array[int]) -> bool:
	var vertices := record.vertices as Array
	var normals := record.normals as Array
	for run_index: int in runs:
		var offset := run_index * 12
		var start := Vector3(float(vertices[offset]), float(vertices[offset + 1]), float(vertices[offset + 2]))
		var end := Vector3(float(vertices[offset + 3]), float(vertices[offset + 4]), float(vertices[offset + 5]))
		var horizontal_normal := Vector2(float(normals[offset]), float(normals[offset + 2])).normalized()
		var tangent := Vector2(horizontal_normal.y, -horizontal_normal.x)
		var horizontal_delta := Vector2(end.x - start.x, end.z - start.z)
		if absf(absf(horizontal_delta.dot(tangent)) - horizontal_delta.length()) > 0.002:
			return false
	return true


func _whole_island_matches() -> Dictionary:
	var packed := load("res://game/scenes/world/world_root.tscn") as PackedScene
	if packed == null:
		return {"ok": false, "message": "Could not load WorldRoot."}
	var world := packed.instantiate() as WorldLoader
	var reports: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: failures.append({"code": code, "message": message, "source_keys": source_keys}))
	root.add_child(world)
	world.load_world(MANIFEST_PATH)
	await process_frame
	await process_frame
	var evidence := world.get_runtime_evidence()
	var ok := failures.is_empty() and reports.size() == 1 and evidence != null \
		and evidence.mesh_instances == 1278 and evidence.surfaces == EXPECTED_WORLD_SURFACES \
		and evidence.triangles == 55067 and evidence.static_bodies == 466 and evidence.shapes == 466
	if ok:
		for target_value: Variant in TARGETS:
			var target := target_value as Dictionary
			var nodes := _nodes_for_key(world, str(target.receiver_key))
			var record := _load_record(str(target.chunk), str(target.receiver_key))
			if nodes.size() != 1 or not _receiver_matches(nodes[0] as Node3D, record, target):
				ok = false
				break
	root.remove_child(world)
	world.free()
	return {"ok": ok, "message": "Whole-island accepted-material mismatch: failures=%s reports=%d surfaces=%s" % [failures, reports.size(), evidence.surfaces if evidence != null else "null"]}


func _runs_for_surface(mesh: ArrayMesh, surface_index: int) -> Array[int]:
	var indices := mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] as PackedInt32Array
	var counts := {}
	for vertex_index: int in indices:
		var run_index := vertex_index / 4
		counts[run_index] = int(counts.get(run_index, 0)) + 1
	var result: Array[int] = []
	for run_value: Variant in counts.keys():
		var run_index := int(run_value)
		if int(counts[run_index]) != 6:
			return []
		result.append(run_index)
	result.sort()
	return result


func _run_length(record: Dictionary, runs: Array[int]) -> float:
	var vertices := record.vertices as Array
	var result := 0.0
	for run_index: int in runs:
		var offset := run_index * 12
		var start := Vector2(float(vertices[offset]), float(vertices[offset + 2]))
		var end := Vector2(float(vertices[offset + 3]), float(vertices[offset + 5]))
		result += start.distance_to(end)
	return result


func _triangle_signatures_for_mesh(mesh: ArrayMesh) -> Dictionary:
	var signatures := {}
	for surface_index in mesh.get_surface_count():
		var arrays := mesh.surface_get_arrays(surface_index)
		var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
		var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
		for offset in range(0, indices.size(), 3):
			var signature := _triangle_signature(vertices[indices[offset]], vertices[indices[offset + 1]], vertices[indices[offset + 2]])
			if signatures.has(signature):
				return {}
			signatures[signature] = true
	return signatures


func _triangle_signatures_for_faces(faces: PackedVector3Array) -> Dictionary:
	var signatures := {}
	for offset in range(0, faces.size(), 3):
		var signature := _triangle_signature(faces[offset], faces[offset + 1], faces[offset + 2])
		if signatures.has(signature):
			return {}
		signatures[signature] = true
	return signatures


func _triangle_signature(a: Vector3, b: Vector3, c: Vector3) -> String:
	var points := [_vector_signature(a), _vector_signature(b), _vector_signature(c)]
	points.sort()
	return "%s|%s|%s" % points


func _vector_signature(value: Vector3) -> String:
	return "%.6f,%.6f,%.6f" % [value.x, value.y, value.z]


func _sorted_keys(values: Dictionary) -> Array:
	var keys := values.keys()
	keys.sort()
	return keys


func _two_builds_match(first: Node3D, second: Node3D) -> bool:
	var first_mesh := (first.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh
	var second_mesh := (second.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh
	if first_mesh.get_surface_count() != second_mesh.get_surface_count():
		return false
	for surface_index in first_mesh.get_surface_count():
		if first_mesh.surface_get_name(surface_index) != second_mesh.surface_get_name(surface_index) \
		or first_mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] != second_mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] \
		or first_mesh.surface_get_material(surface_index).resource_path != second_mesh.surface_get_material(surface_index).resource_path:
			return false
	return (first.get_node("Collision/Shape") as CollisionShape3D).shape.get_faces() == (second.get_node("Collision/Shape") as CollisionShape3D).shape.get_faces()


func _nodes_for_key(root_node: Node, key: String) -> Array[Node]:
	var result: Array[Node] = []
	for node: Node in root_node.find_children("*", "Node3D", true, false):
		if str(node.get_meta("derived_object_key", "")) == key and node.get_parent() != null and str(node.get_parent().name).contains("__"):
			result.append(node)
	return result


func _load_record(chunk_path: String, object_key: String) -> Dictionary:
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(chunk_path)) as Dictionary
	for record_value: Variant in chunk.get("records", []):
		var record := record_value as Dictionary
		if str(record.get("object_key", "")) == object_key:
			return record
	return {}


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _values_match(first: Variant, second: Variant) -> bool:
	if first is Color and second is Color:
		return (first as Color).is_equal_approx(second as Color)
	if first is float or first is int:
		return is_equal_approx(float(first), float(second))
	return first == second


func _free_result(result: Dictionary) -> void:
	var node := result.get("node", null) as Node
	if node != null and not node.is_inside_tree():
		node.free()


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
