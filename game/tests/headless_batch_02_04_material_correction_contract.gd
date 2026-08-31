extends SceneTree

const ACCEPTED_MATERIAL_RUN_TRIALS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const GENERIC_SHADER_PATH := "res://game/resources/materials/world/batch_02/batch_02_homogeneous_field.gdshader"
const SIDING_SHADER_PATH := "res://game/resources/materials/world/batch_04/batch_04_horizontal_siding_field.gdshader"
const CORRECTION_SHADER_PATH := "res://game/resources/materials/world/batch_02_04_aperiodic_field.gdshader"
const YMCA_WALL_TANGENT_SHADER_PATH := "res://game/resources/materials/world/ti_ymca/ti_ymca_wall_tangent_aperiodic_field.gdshader"
const EXPECTED_GENERIC_SHADER_SHA256 := "1918177080126199ddbfc0715a77b85a9355800479a098ec9b81c9726b7cc4d5"
const EXPECTED_SIDING_SHADER_SHA256 := "63f0be4ab7995f94653298cff1d5a271728209e05ee014c67b76165bc4f0dc8d"
const EXPECTED_CORRECTION_SHADER_SHA256 := "324ba33a7c78f4b05038168a479ebb8e875c56704236492a050cee8da8e5f798"
const EXPECTED_YMCA_WALL_TANGENT_SHADER_SHA256 := "8943853363f5a2571ebf15a6e9711c6310b706d2e4415f3e1f314d8643d55f6c"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EVIDENCE_ROOT := "res://evidence/first-playable/batch-02-04-material-corrections-2026-08-29"

const REGISTRIES := {
	"res://game/resources/facades/batch_02_material_registry.json": "e7d1167869640867e2857de1f08df81e878e68230b59feff3fb947b16ff56cb7",
	"res://game/resources/facades/batch_03_material_registry.json": "31983ae1529e6248e93ec8d231d2b870de3979778b35eef6019cd19e1a964516",
	"res://game/resources/facades/batch_04_material_registry.json": "b4c5983a628d076cda0aaa24d0023fc7a43983fd6c00f82c9806871af0409cf7",
}

const CORRECTED := [
	{
		"path": "res://game/resources/materials/world/ti_ymca/ti_ymca_primary.tres",
		"hash": "b5e44afcf4feb6df6ffba46f4e3b60a25fa6043c07c12c33e31c483cb2bf2399",
		"shader": YMCA_WALL_TANGENT_SHADER_PATH, "field_kind": 5,
		"base": Color(0.25, 0.22, 0.19, 1), "secondary": Color(0.16, 0.15, 0.14, 1),
		"roughness": 0.91, "primary": 0.42, "secondary_scale": 0.095, "relief": 0.08, "variation": 0.065,
	},
	{
		"path": "res://game/resources/materials/world/fire_training_b600/fire_training_primary.tres",
		"hash": "fd1437ed9c0e00508d10d9a3c5d859d9a07c73fb28edc3fad62c473e9d865483",
		"shader": CORRECTION_SHADER_PATH, "field_kind": 0,
		"base": Color(0.76, 0.72, 0.64, 1), "secondary": Color(0.66, 0.63, 0.57, 1),
		"roughness": 0.84, "primary": 0.38, "secondary_scale": 0.22, "relief": 0.018, "variation": 0.03,
	},
	{
		"path": "res://game/resources/materials/world/850_avenue_h/850_h_tan_field.tres",
		"hash": "d92f7137edf2be91b0268659843423764528db58c194cbe5d0b1596a4f8303a8",
		"shader": CORRECTION_SHADER_PATH, "field_kind": 0,
		"base": Color(0.55, 0.47, 0.34, 1), "secondary": Color(0.48, 0.42, 0.32, 1),
		"roughness": 0.80, "primary": 0.75, "secondary_scale": 0.28, "relief": 0.0, "variation": 0.012,
	},
	{
		"path": "res://game/resources/materials/world/bldg_461/bldg_461_gray_field.tres",
		"hash": "e44738c8f1d06a34bfc876b610e2c70a0890c85cbb63342b613094d7b8b80a66",
		"shader": CORRECTION_SHADER_PATH, "field_kind": 0,
		"base": Color(0.40, 0.43, 0.44, 1), "secondary": Color(0.34, 0.37, 0.38, 1),
		"roughness": 0.82, "primary": 0.95, "secondary_scale": 0.38, "relief": 0.0, "variation": 0.006,
	},
	{
		"path": "res://game/resources/materials/world/1318_gateview/1318_gateview_white_trim.tres",
		"hash": "30c896ddb23419a590744572fe4396c00fee942c3654985be97e2f33694a7452",
		"shader": GENERIC_SHADER_PATH, "field_kind": 4,
		"base": Color(0.84, 0.85, 0.82, 1), "secondary": Color(0.84, 0.85, 0.82, 1),
		"roughness": 0.66, "primary": 0.75, "secondary_scale": 0.25, "relief": 0.0, "variation": 0.012,
	},
]

const PROTECTED_MATERIALS := {
	"res://game/resources/materials/world/building_2/building_2_primary.tres": "e936dc561b653e43eafdef633dc2260c7489a713b5d8da5521b5b118a9b8f8a9",
	"res://game/resources/materials/world/490_avenue_palms/490_thin_brick.tres": "76ae45e057f1d6502c09c6a937d45256c388ee01a67c450a249dffce82cbce39",
	"res://game/resources/materials/world/star_view_court/star_view_grey_base.tres": "c7cd8fc95b76539a9bf20d6aa05cba5b494efdbb27ff93ba74a9a0077f60dc9c",
	"res://game/resources/materials/world/maceo_may/maceo_may_sse_rib.tres": "da68584fa85647d611f825743e3e58164133b51312199fd7955267bc047721bf",
	"res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres": "4020e4c75350929359be9c16686ad80a2a0eac46918cc32746089694017a61a5",
	"res://game/resources/materials/world/personnel_support_detachment/psd_outer.tres": "ec103e8a030903e17c3d863e80f6c904fafd0806b24db0385c8aac999c821692",
	"res://game/resources/materials/world/fire_station_48/fire_station_48_primary.tres": "515135c3d0da6bb8eb8681e69d7e3f7818d896d948fe5dcc7c2bd8c6d076b188",
	"res://game/resources/materials/world/job_corps_dormitory_b369/dormitory_b369_warm_field.tres": "fb50d3989b7aa41421753ad4db5d195366d9a2c25c15087e5e3a2b7863c69602",
	"res://game/resources/materials/world/job_corps_dormitory_b369/dormitory_b369_blue_end.tres": "03f46e12f4b6b671fc0859e9d68d73ab0fbadd957af97855bbab698b467c4a41",
	"res://game/resources/materials/world/job_corps_dormitory_b369/dormitory_b369_green_trim.tres": "ad4387598f23a327420043f7971ffc4db34274245b639e531071a5f917699ffa",
	"res://game/resources/materials/world/449_avenue_h/449_h_historical_siding.tres": "a4b6858a9f1997874e74321463429546e10acdaf6eac58521d5239f3360ec34d",
	"res://game/resources/materials/world/449_avenue_h/449_h_historical_trim.tres": "10e22c5ce4a5f43140a383b5387e8b83e9eeadcd7672b77a1613f88f22832c68",
	"res://game/resources/materials/world/850_avenue_h/850_h_teal_edge.tres": "76cf6b1231952c05362bf41e29ee473452a87aa6aa6f663404b0fed10e42481f",
	"res://game/resources/materials/world/810_avenue_d/810_d_historical_siding.tres": "9c3f2cf0fbc237910652f93fb384444f957b77552f662942f728ec804aae7180",
	"res://game/resources/materials/world/810_avenue_d/810_d_historical_brown_trim.tres": "d8810705d79ba8b79c5fb742b32c65b343a607aba0ed86b989d7aa35760e5a65",
	"res://game/resources/materials/world/bldg_461/bldg_461_pale_end.tres": "fb07e022a7a58c593f97c8aeabede62d849587593dbbaffb629658783dd4874d",
	"res://game/resources/materials/world/1318_gateview/1318_gateview_siding.tres": "abf1e18a2e55ae511957a92aca271bda811fe683f813d09b1591fc7b51d54327",
	"res://game/resources/materials/world/1212_mariner/1212_mariner_siding.tres": "fcf16d01599d9152e4c69c29243005efafb7128ebc989f8ef2ca49b2f76e662e",
	"res://game/resources/materials/world/1212_mariner/1212_mariner_white_trim.tres": "21bdf88cbc0acf6de4a6a02a470d4925722ad6232dc7d39eed0b8e0903f23482",
	"res://game/resources/materials/world/1212_mariner/1212_mariner_entry_accent.tres": "8b48483e70b6365b67d3d492d4f2e611ea1d09fc6c3fe8cf74f69628f0170f61",
	"res://game/resources/materials/world/1212_mariner/1212_mariner_privacy_accent.tres": "719ca1fa5e74d298a338e4985a4951551bae47cd3a8a003aee39340a6013d857",
}

const PRIOR_MANIFESTS := {
	"res://evidence/first-playable/batch-02-material-prototypes-2026-08-29/treasure-island-community-ymca/capture-manifest.json": "bb46853fd86ea58080121f801a78a5c28db7f5cba959ce88ba02461cd73dbe92",
	"res://evidence/first-playable/batch-03-material-prototypes-2026-08-29/fire-training-b600/capture-manifest.json": "ccdad3ba144c7011bbfa887a27ccc497f3455f27372f69b065f012d25a9f2138",
	"res://evidence/first-playable/batch-04-material-prototypes-2026-08-29/850-avenue-h/tan_wall/capture-manifest.json": "03ea10d1872a90f10f0d94cda267f2cdffbe19875023eeb2f0d0fb90a569aac2",
	"res://evidence/first-playable/batch-04-material-prototypes-2026-08-29/bldg-461/medium_gray/capture-manifest.json": "3c5eda55b675f752a8767b6d8fa5336d05926d02d8405dfc64632ed269dd7e50",
	"res://evidence/first-playable/batch-04-material-prototypes-2026-08-29/1318-gateview/white_trim/capture-manifest.json": "ff12b15bfa4c60c60a4a6bbd420b59c2fd6e7ce3ae5bbff19eb73a22a5db4d3f",
}

const PRIOR_PNGS := {
	"res://evidence/first-playable/batch-02-material-prototypes-2026-08-29/treasure-island-community-ymca/01-close.png": "f14ca823ed1a398eb21388a15f8c8b290297230012e6dddd0b82e110393c6c34",
	"res://evidence/first-playable/batch-02-material-prototypes-2026-08-29/treasure-island-community-ymca/02-ordinary-distance.png": "ca07673d248a7f1d3d8c43c454ca991c6d4c968c27af665af008fd9dd29c70f6",
	"res://evidence/first-playable/batch-02-material-prototypes-2026-08-29/treasure-island-community-ymca/03-changed-light-oblique.png": "acb45bb5582630a0b237c1865934e4e8606d7dd5f35d0fbeda04d7be6f54ec51",
	"res://evidence/first-playable/batch-03-material-prototypes-2026-08-29/fire-training-b600/01-close.png": "48c240a6ada0ed7f45d9952e9a2fcfe376be979c0aeef1737778f26b8ffa72e3",
	"res://evidence/first-playable/batch-03-material-prototypes-2026-08-29/fire-training-b600/02-ordinary-distance.png": "20ee719f040f6d4e86a703d6d5eb3f78156f7914243375e97f58104b29f045d1",
	"res://evidence/first-playable/batch-03-material-prototypes-2026-08-29/fire-training-b600/03-changed-light-oblique.png": "ac4cb509c126f915d4c3900bbf1bad4ed33e8ec0cfaea3251bb3dc76a183b12b",
	"res://evidence/first-playable/batch-04-material-prototypes-2026-08-29/850-avenue-h/tan_wall/01-close.png": "8a892487cb8c7e8b1e513646df8a9a072006a1dedf301f4f6a89ac5b3df417a2",
	"res://evidence/first-playable/batch-04-material-prototypes-2026-08-29/850-avenue-h/tan_wall/02-ordinary-distance.png": "da531fe5ca713982c91be6df106371ce57ced09caf575e92be5214fd9dd8cce0",
	"res://evidence/first-playable/batch-04-material-prototypes-2026-08-29/850-avenue-h/tan_wall/03-changed-light-oblique.png": "aa36596dc2dbe0f5cca43652cb295c4d1b9b3c59114dce8774703f7ead0626b8",
	"res://evidence/first-playable/batch-04-material-prototypes-2026-08-29/bldg-461/medium_gray/01-close.png": "626823c3517de2e9b815f178a6a724a00cf27e0c825cd2d6e203ccca42f1e2ce",
	"res://evidence/first-playable/batch-04-material-prototypes-2026-08-29/bldg-461/medium_gray/02-ordinary-distance.png": "2852b4ae9efdd130f40310710d308f60508a6bede9f2792e61705325371aebcf",
	"res://evidence/first-playable/batch-04-material-prototypes-2026-08-29/bldg-461/medium_gray/03-changed-light-oblique.png": "d10d9abd6862a922d223b4b6bb1cb93c0a5d95143f89d7ff33d034f452855e6d",
	"res://evidence/first-playable/batch-04-material-prototypes-2026-08-29/1318-gateview/white_trim/01-close.png": "55daa73d763a8a6138e6125f1adc367bb63d4519251535d3e280874aa2f07c43",
	"res://evidence/first-playable/batch-04-material-prototypes-2026-08-29/1318-gateview/white_trim/02-ordinary-distance.png": "208e0f0ab926175db469f0d2d8ae6efcaa07826382e4b28bd5f19e507ae6194f",
	"res://evidence/first-playable/batch-04-material-prototypes-2026-08-29/1318-gateview/white_trim/03-changed-light-oblique.png": "53bb850301e05191f391eebb63088b06136e72f1c904c51f4f78bf8a2fccb6a8",
}

const CORRECTION_EVIDENCE := {
	"treasure-island-community-ymca": "C1",
	"fire-training-b600": "C2",
	"850-avenue-h/tan_wall": "C3",
	"bldg-461/medium_gray": "C4",
	"1318-gateview/white_trim": "C5",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_hash(GENERIC_SHADER_PATH, EXPECTED_GENERIC_SHADER_SHA256, "Accepted generic shader")
	_check_hash(SIDING_SHADER_PATH, EXPECTED_SIDING_SHADER_SHA256, "Accepted siding shader")
	_check_hash(CORRECTION_SHADER_PATH, EXPECTED_CORRECTION_SHADER_SHA256, "Rejected-only correction shader")
	_check_hash(YMCA_WALL_TANGENT_SHADER_PATH, EXPECTED_YMCA_WALL_TANGENT_SHADER_SHA256, "YMCA-only wall-tangent correction shader")
	_check_hash("res://generated/world/manifest.json", EXPECTED_MANIFEST_SHA256, "Generated manifest")
	for path: String in REGISTRIES:
		_check_hash(path, str(REGISTRIES[path]), "Corrected registry")
	for path: String in PROTECTED_MATERIALS:
		_check_hash(path, str(PROTECTED_MATERIALS[path]), "Protected accepted material")
	for path: String in PRIOR_MANIFESTS:
		_check_hash(path, str(PRIOR_MANIFESTS[path]), "Prior rejected evidence manifest")
	for path: String in PRIOR_PNGS:
		_check_hash(path, str(PRIOR_PNGS[path]), "Prior rejected evidence PNG")
	_require(PROTECTED_MATERIALS.size() == 21, "Protected accepted candidate set must contain exactly 21 materials.")
	_require(CORRECTED.size() == 5, "Correction set must contain exactly five materials.")
	_require(PRIOR_PNGS.size() == 15, "Prior rejected evidence lineage must contain exactly 15 PNGs.")
	_require(_correction_shader_matches(), "Correction shader lost its aperiodic, opaque, deterministic, texture-free contract.")
	for expected_value: Variant in CORRECTED:
		_require(_material_matches(expected_value as Dictionary), "Corrected material contract failed for %s." % str((expected_value as Dictionary).path))
	_require(_registries_scope_only_the_rejected_materials(), "Registry correction-shader scope or corrected hashes drifted.")
	_require(_runtime_correction_scope_matches(), "Corrected-resource runtime scope is not exactly YMCA runs 3..11 through the accepted-run helper, or the builder directly references a corrected prototype.")
	_new_evidence_matches()
	if not _failed:
		print("PASS: exactly five corrected prototypes satisfy their mechanical briefs; 15 correction-proof PNGs validate; YMCA alone is live through the exact-run helper on runs 3..11, the other four corrected resources remain detached, and 21 accepted candidate resources, two accepted shaders, generated bytes, and all 15 prior rejected proof PNGs remain hash-identical")
	quit(1 if _failed else 0)


func _material_matches(expected: Dictionary) -> bool:
	if FileAccess.get_sha256(str(expected.path)) != str(expected.hash):
		return false
	var material := load(str(expected.path)) as ShaderMaterial
	if material == null or material.shader == null or material.shader.resource_path != str(expected.shader):
		return false
	return int(material.get_shader_parameter("field_kind")) == int(expected.field_kind) \
		and (material.get_shader_parameter("base_color") as Color).is_equal_approx(expected.base as Color) \
		and (material.get_shader_parameter("secondary_color") as Color).is_equal_approx(expected.secondary as Color) \
		and is_equal_approx(float(material.get_shader_parameter("roughness_value")), float(expected.roughness)) \
		and is_equal_approx(float(material.get_shader_parameter("primary_scale_m")), float(expected.primary)) \
		and is_equal_approx(float(material.get_shader_parameter("secondary_scale_m")), float(expected.secondary_scale)) \
		and is_equal_approx(float(material.get_shader_parameter("relief_strength")), float(expected.relief)) \
		and is_equal_approx(float(material.get_shader_parameter("color_variation")), float(expected.variation))


func _correction_shader_matches() -> bool:
	var source := FileAccess.get_file_as_string(CORRECTION_SHADER_PATH)
	if not "render_mode depth_draw_opaque, cull_back" in source \
		or not "hash21" in source \
		or not "value_noise" in source \
		or source.count("mat2(") < 3 \
		or source.count("fwidth(") < 1 \
		or not "METALLIC = 0.0" in source \
		or not "NORMAL_MAP" in source:
		return false
	for forbidden in ["discard", "ALPHA =", "TIME", "SCREEN_TEXTURE", "sampler2D", "texture(", "sin(", "vertex displacement"]:
		if forbidden in source:
			return false
	return true


func _registries_scope_only_the_rejected_materials() -> bool:
	var batch_02 := JSON.parse_string(FileAccess.get_file_as_string("res://game/resources/facades/batch_02_material_registry.json")) as Dictionary
	var batch_03 := JSON.parse_string(FileAccess.get_file_as_string("res://game/resources/facades/batch_03_material_registry.json")) as Dictionary
	var batch_04 := JSON.parse_string(FileAccess.get_file_as_string("res://game/resources/facades/batch_04_material_registry.json")) as Dictionary
	if str((batch_02.correction_shader as Dictionary).path) != CORRECTION_SHADER_PATH \
		or str((batch_03.correction_shader as Dictionary).path) != CORRECTION_SHADER_PATH:
		return false
	var correction_contracts := 0
	for shader_value: Variant in batch_04.shader_contracts:
		var shader := shader_value as Dictionary
		if str(shader.get("path", "")) == CORRECTION_SHADER_PATH:
			correction_contracts += 1
	if correction_contracts != 1:
		return false
	var correction_paths: Array[String] = []
	for target_value: Variant in batch_02.targets:
		var target := target_value as Dictionary
		if str(target.source_key) == "w34313547":
			correction_paths.append(str(target.material_path))
	for target_value: Variant in batch_03.targets:
		var target := target_value as Dictionary
		if str(target.source_key) == "w34313548":
			correction_paths.append(str(target.material_path))
	for target_value: Variant in batch_04.targets:
		for material_value: Variant in (target_value as Dictionary).materials:
			var material := material_value as Dictionary
			if str(material.get("shader_kind", "")).begins_with("aperiodic_"):
				correction_paths.append(str(material.path))
	correction_paths.sort()
	var expected_paths: Array[String] = []
	for index in 4:
		expected_paths.append(str((CORRECTED[index] as Dictionary).path))
	expected_paths.sort()
	return correction_paths == expected_paths


func _runtime_correction_scope_matches() -> bool:
	var source := FileAccess.get_file_as_string("res://game/scripts/world/world_chunk_builder.gd").to_lower()
	for token in ["batch_02_04_aperiodic_field", "ti_ymca_primary", "fire_training_primary", "850_h_tan_field", "bldg_461_gray_field", "1318_gateview_white_trim"]:
		if token in source:
			return false
	var ymca := ACCEPTED_MATERIAL_RUN_TRIALS.TARGETS.get("building:w34313547:wall", {}) as Dictionary
	if str(ymca.get("source_key", "")) != "w34313547" \
	or ymca.get("accepted_runs", []) != [3, 4, 5, 6, 7, 8, 9, 10, 11] \
	or not is_equal_approx(float(ymca.get("accepted_length_m", 0.0)), 101.046) \
	or str(ymca.get("material_path", "")) != "res://game/resources/materials/world/ti_ymca/ti_ymca_primary.tres":
		return false
	for rejected_index in range(1, CORRECTED.size()):
		var rejected_path := str((CORRECTED[rejected_index] as Dictionary).path)
		for target_value: Variant in ACCEPTED_MATERIAL_RUN_TRIALS.TARGETS.values():
			if str((target_value as Dictionary).get("material_path", "")) == rejected_path:
				return false
	return true


func _new_evidence_matches() -> bool:
	var matches := true
	var png_count := 0
	for slug: String in CORRECTION_EVIDENCE:
		var directory := EVIDENCE_ROOT.path_join(slug)
		var manifest_path := directory.path_join("capture-manifest.json")
		if not _require(FileAccess.file_exists(manifest_path), "New correction manifest is missing: %s." % manifest_path):
			matches = false
			continue
		var manifest := JSON.parse_string(FileAccess.get_file_as_string(manifest_path)) as Dictionary
		if not _require(str(manifest.get("schema_version", "")) == "ti.batch-02-04-material-correction-proof/1" \
			and str(manifest.get("review_status", "")) == "ready_for_independent_re_review_not_self_accepted" \
			and str(manifest.get("correction_id", "")) == str(CORRECTION_EVIDENCE[slug]) \
			and not bool(manifest.get("runtime_attachment", true)) \
			and str(manifest.get("rendering_method", "")) == "Forward+" \
			and str(manifest.get("rendering_driver", "")) == "Metal" \
			and "forward_plus" in str(manifest.get("capture_command", "")) \
			and "metal" in str(manifest.get("capture_command", "")), "Correction manifest metadata drifted: %s." % manifest_path):
			matches = false
		var captures := manifest.get("captures", []) as Array
		if not _require(captures.size() == 3, "Correction manifest must contain three captures: %s." % manifest_path):
			matches = false
		for capture_value: Variant in captures:
			var capture := capture_value as Dictionary
			var png_path := directory.path_join(str(capture.get("file", "")))
			var dimensions := capture.get("dimensions", []) as Array
			if not _require(FileAccess.get_sha256(png_path) == str(capture.get("sha256", "")), "Correction PNG hash drifted: %s." % png_path): matches = false
			if not _require(int(capture.get("bytes", -1)) == FileAccess.get_file_as_bytes(png_path).size(), "Correction PNG byte count drifted: %s." % png_path): matches = false
			if not _require(dimensions.size() == 2 and int(dimensions[0]) == 1440 and int(dimensions[1]) == 900, "Correction PNG dimensions metadata drifted: %s." % png_path): matches = false
			if not _require(bool(capture.get("proof_receiver_only", false)), "Correction PNG lost its proof-only label: %s." % png_path): matches = false
			var image := Image.new()
			if not _require(image.load(ProjectSettings.globalize_path(png_path)) == OK and image.get_size() == Vector2i(1440, 900), "Correction PNG is unreadable or wrong-sized: %s." % png_path):
				matches = false
			png_count += 1
	return _require(png_count == 15, "Correction evidence must contain exactly 15 PNGs, found %d." % png_count) and matches


func _check_hash(path: String, expected: String, label: String) -> void:
	_require(FileAccess.file_exists(path), "%s is missing: %s." % [label, path])
	if FileAccess.file_exists(path):
		_require(FileAccess.get_sha256(path) == expected, "%s bytes drifted: %s." % [label, path])


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false
