extends SceneTree

const MANIFEST_PATH := "res://generated/world/manifest.json"
const GENERATED_ROOT := "res://generated/world/"
const EXPECTED_PROJECT_NAME := "Treasure Island First Playable"
const EXPECTED_MAIN_SCENE := "res://game/scenes/main.tscn"
const EXPECTED_AUDIO_DRIVER := "Dummy"
const EXPECTED_MANIFEST_SCHEMA := "ti.godot-world/2"
const EXPECTED_CONTENT_FILES := 46
const EXPECTED_GENERATED_FILES := 47
const EXPECTED_CHUNKS := 38
const EXPECTED_SOURCE_ROWS := 739
const EXPECTED_PLAYABLE_ROWS := 735
const EXPECTED_CONTEXT_ROWS := 4
const EXPECTED_SPAWN := Vector3(-104.364, 3.457, 786.024)
const EXPECTED_SPAWN_YAW := -0.119
const EXPECTED_VEGETATION_SCHEMA := "ti.vegetation/1"
const EXPECTED_VEGETATION_SEED := 1414092337
const EXPECTED_VEGETATION_ASSETS := 15
const EXPECTED_VEGETATION_PLACEMENTS := 124
const EXPECTED_NAIP_SHRUBS := 22
const EXPECTED_PAVEMENT_SCHEMA := "ti.pavement-skin/1"
const EXPECTED_PAVEMENT_SOURCES := 427
const EXPECTED_VEHICLE_SOURCES := 208
const EXPECTED_PEDESTRIAN_SOURCES := 219
const EXPECTED_PAVED_AREA_SOURCES := 17
const EXPECTED_SKYLINE_PATH := "res://game/resources/textures/context/sf_skyline_owner_silhouette_final.png"
const EXPECTED_SKYLINE_SIZE := Vector2i(2212, 340)
const EXPECTED_BRIDGE_PATH := "res://game/resources/models/context/baybridge-western-span.glb"
const EXPECTED_TAG_PATH := "res://game/resources/textures/tag/predefined_tag.svg"
const EXPECTED_TAG_SIZE := Vector2i(512, 256)
const EXPECTED_MOVEMENT := {
	"walk_speed_mps": 4.0,
	"run_speed_mps": 20.0,
	"acceleration_mps2": 30.0,
	"braking_mps2": 40.0,
	"jetpack_ascent_speed_mps": 5.0,
	"jetpack_descent_speed_mps": 1.5,
	"jetpack_vertical_response_mps2": 12.0,
}
const BANNED_PREFIXES := [
	"res://addons/",
	"res://build/",
	"res://data/",
	"res://discovery/",
	"res://evidence/",
	"res://node_modules/",
	"res://third_party_staging/",
	"res://tools/",
	"res://.tools/",
]
const BANNED_ROOT_FILES := [
	"res://INSTALL_LOG.md",
	"res://package.json",
	"res://package-lock.json",
]
const REQUIRED_SCENES := [
	"res://game/scenes/main.tscn",
	"res://game/scenes/player/player.tscn",
	"res://game/scenes/ui/hud.tscn",
	"res://game/scenes/world/world_root.tscn",
]
const POLY_HAVEN_TEXTURES := [
	"res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg",
	"res://game/resources/textures/world/polyhaven/bitumen/bitumen_nor_gl_1k.jpg",
	"res://game/resources/textures/world/polyhaven/bitumen/bitumen_rough_1k.jpg",
	"res://game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_diff_1k.jpg",
	"res://game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_nor_gl_1k.jpg",
	"res://game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_rough_1k.jpg",
	"res://game/resources/textures/world/polyhaven/concrete_floor_03/concrete_floor_03_diff_1k.jpg",
	"res://game/resources/textures/world/polyhaven/concrete_floor_03/concrete_floor_03_nor_gl_1k.jpg",
	"res://game/resources/textures/world/polyhaven/concrete_floor_03/concrete_floor_03_rough_1k.jpg",
	"res://game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_diff_1k.jpg",
	"res://game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_nor_gl_1k.jpg",
	"res://game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_rough_1k.jpg",
	"res://game/resources/textures/world/polyhaven/plaster_grey_04/plaster_grey_04_diff_1k.jpg",
	"res://game/resources/textures/world/polyhaven/plaster_grey_04/plaster_grey_04_nor_gl_1k.jpg",
	"res://game/resources/textures/world/polyhaven/plaster_grey_04/plaster_grey_04_rough_1k.jpg",
	"res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_diff_1k.jpg",
	"res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_nor_gl_1k.jpg",
	"res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_rough_1k.jpg",
]


func _initialize() -> void:
	var arguments := _parse_arguments()
	if not arguments.ok:
		_fail(str(arguments.code), str(arguments.message))
		return
	var pck_path := str(arguments.pck_path)
	var identity := _audit_pck_identity(pck_path, str(arguments.pck_sha256))
	if not identity.ok:
		_fail(str(identity.code), str(identity.message))
		return
	var mount := _audit_mounted_project()
	if not mount.ok:
		_fail(str(mount.code), str(mount.message))
		return
	var inventory := _enumerate_resource_files()
	if not inventory.ok:
		_fail(str(inventory.code), str(inventory.message))
		return
	var files: Array[String] = inventory.files
	var exclusions := _audit_exclusions(files, pck_path)
	if not exclusions.ok:
		_fail(str(exclusions.code), str(exclusions.message))
		return
	var manifest := _audit_manifest(
		str(arguments.manifest_sha256),
		str(arguments.content_sha256),
		files,
	)
	if not manifest.ok:
		_fail(str(manifest.code), str(manifest.message))
		return
	var vegetation := _audit_vegetation()
	if not vegetation.ok:
		_fail(str(vegetation.code), str(vegetation.message))
		return
	var pavement := _audit_pavement()
	if not pavement.ok:
		_fail(str(pavement.code), str(pavement.message))
		return
	var resources := _audit_resource_graph()
	if not resources.ok:
		_fail(str(resources.code), str(resources.message))
		return
	print("PCK_CONTENT_AUDIT: pck_sha256=%s pck_bytes=%d virtual_files=%d generated_world=%d chunks=%d manifest_sha256=%s content_sha256=%s rows=%d/%d/%d polyhaven_maps=%d vegetation_assets=%d vegetation_placements=%d naip_shrubs=%d pavement=%d/%d/%d movement=4/20/30/40 physical_space=true private_paths=0 private_raw=0 banned=0" % [
		str(identity.sha256),
		int(identity.bytes),
		files.size(),
		int(manifest.generated_files),
		int(manifest.chunks),
		str(manifest.manifest_sha256),
		str(manifest.content_sha256),
		EXPECTED_SOURCE_ROWS,
		EXPECTED_PLAYABLE_ROWS,
		EXPECTED_CONTEXT_ROWS,
		POLY_HAVEN_TEXTURES.size(),
		int(vegetation.assets),
		int(vegetation.placements),
		int(vegetation.naip_shrubs),
		EXPECTED_PAVEMENT_SOURCES,
		EXPECTED_VEHICLE_SOURCES,
		EXPECTED_PEDESTRIAN_SOURCES,
	])
	print("PASS: direct-mounted PCK matches the explicit package/world identities, complete generated artifact index, current resource graph, movement/input defaults, and exclusion boundary")
	quit(0)


func _parse_arguments() -> Dictionary:
	var values := {}
	var prefixes := {
		"pck_path": "--pck-audit-pck=",
		"pck_sha256": "--pck-audit-pck-sha256=",
		"manifest_sha256": "--pck-audit-manifest-sha256=",
		"content_sha256": "--pck-audit-content-sha256=",
	}
	for argument: String in OS.get_cmdline_user_args():
		var matched := false
		for key: String in prefixes:
			var prefix := str(prefixes[key])
			if argument.begins_with(prefix):
				if values.has(key):
					return _error("arguments", "Duplicate argument for %s." % key)
				var value := argument.substr(prefix.length())
				if value.is_empty():
					return _error("arguments", "Empty argument for %s." % key)
				values[key] = value
				matched = true
				break
		if not matched:
			return _error("arguments", "Unexpected user argument: %s" % argument)
	for key: String in prefixes:
		if not values.has(key):
			return _error("arguments", "Missing required %s argument." % str(prefixes[key]).trim_suffix("="))
	var pck_path := str(values.pck_path)
	if not pck_path.begins_with("/") or pck_path.get_extension().to_lower() != "pck":
		return _error("arguments", "--pck-audit-pck must be an absolute .pck path.")
	for key: String in ["pck_sha256", "manifest_sha256", "content_sha256"]:
		if not _is_lower_sha256(str(values[key])):
			return _error("arguments", "%s must be exactly 64 lowercase hexadecimal characters." % key)
	return {
		"ok": true,
		"pck_path": pck_path,
		"pck_sha256": str(values.pck_sha256),
		"manifest_sha256": str(values.manifest_sha256),
		"content_sha256": str(values.content_sha256),
	}


func _audit_pck_identity(pck_path: String, expected_sha256: String) -> Dictionary:
	if not FileAccess.file_exists(pck_path):
		return _error("pck_missing", "PCK does not exist at the explicit path.")
	var file := FileAccess.open(pck_path, FileAccess.READ)
	if file == null:
		return _error("pck_open", "Could not open the explicit PCK path: %s" % error_string(FileAccess.get_open_error()))
	var byte_count := file.get_length()
	file = null
	var actual_sha256 := FileAccess.get_sha256(pck_path)
	if actual_sha256 != expected_sha256:
		return _error("pck_hash", "PCK SHA-256 mismatch: expected %s, got %s." % [expected_sha256, actual_sha256])
	return {"ok": true, "sha256": actual_sha256, "bytes": byte_count}


func _audit_mounted_project() -> Dictionary:
	if not FileAccess.file_exists("res://project.binary") or FileAccess.file_exists("res://project.godot"):
		return _error("mount_boundary", "The resource root is not an exported project.binary-only mount.")
	if str(ProjectSettings.get_setting("application/config/name", "")) != EXPECTED_PROJECT_NAME:
		return _error("project_name", "Mounted project name does not match the first playable.")
	if str(ProjectSettings.get_setting("application/run/main_scene", "")) != EXPECTED_MAIN_SCENE:
		return _error("main_scene", "Mounted project main scene does not match the first playable.")
	if str(ProjectSettings.get_setting("audio/driver/driver", "")) != EXPECTED_AUDIO_DRIVER:
		return _error("audio_driver", "Mounted project does not select the exact case-sensitive Dummy audio driver.")
	return {"ok": true}


func _enumerate_resource_files() -> Dictionary:
	var files: Array[String] = []
	var result := _collect_resource_files("res://", files)
	if not result.ok:
		return result
	files.sort()
	return {"ok": true, "files": files}


func _collect_resource_files(root: String, files: Array[String]) -> Dictionary:
	var directory := DirAccess.open(root)
	if directory == null:
		return _error("inventory_open", "Could not open mounted directory %s: %s" % [root, error_string(DirAccess.get_open_error())])
	var begin_error := directory.list_dir_begin()
	if begin_error != OK:
		return _error("inventory_list", "Could not enumerate mounted directory %s: %s" % [root, error_string(begin_error)])
	var names: Array[String] = []
	var directory_names := {}
	var name := directory.get_next()
	while not name.is_empty():
		if name != "." and name != "..":
			names.append(name)
			directory_names[name] = directory.current_is_dir()
		name = directory.get_next()
	directory.list_dir_end()
	names.sort()
	for child_name: String in names:
		var child_path := root + child_name if root.ends_with("/") else "%s/%s" % [root, child_name]
		if bool(directory_names[child_name]):
			var child_result := _collect_resource_files("%s/" % child_path, files)
			if not child_result.ok:
				return child_result
		else:
			files.append(child_path)
	return {"ok": true}


func _audit_exclusions(files: Array[String], pck_path: String) -> Dictionary:
	var private_needles := _private_needles()
	for path: String in files:
		for prefix: String in BANNED_PREFIXES:
			if path.begins_with(prefix):
				return _error("banned_path", "Mounted package contains banned authoring path: %s" % path)
		if path in BANNED_ROOT_FILES:
			return _error("banned_path", "Mounted package contains banned root file: %s" % path)
		var lower_path := path.to_lower()
		for needle: PackedByteArray in private_needles:
			if lower_path.contains(needle.get_string_from_ascii()):
				return _error("private_path", "Mounted package path inventory contains configured private-source fragment.")
	var file := FileAccess.open(pck_path, FileAccess.READ)
	if file == null:
		return _error("private_scan", "Could not reopen PCK for private-source byte scan.")
	var pck_bytes := file.get_buffer(file.get_length())
	file = null
	var lowercase_pck := pck_bytes.get_string_from_ascii().to_lower()
	for needle: PackedByteArray in private_needles:
		if lowercase_pck.contains(needle.get_string_from_ascii()):
			return _error("private_raw", "Raw PCK bytes contain configured private-source fragment.")
	return {"ok": true}


func _private_needles() -> Array[PackedByteArray]:
	# Numeric assembly keeps the auditor from introducing the strings it is meant to detect.
	return [
		PackedByteArray([105, 109, 103, 95, 55, 49, 54, 57]),
		PackedByteArray([46, 104, 101, 105, 99]),
		PackedByteArray([115, 111, 117, 114, 99, 101, 95, 97, 115, 115, 101, 116, 115, 47, 99, 111, 110, 116, 101, 120, 116, 47, 115, 102, 95, 115, 107, 121, 108, 105, 110, 101, 95, 112, 104, 111, 116, 111, 47]),
		PackedByteArray([103, 101, 110, 101, 114, 97, 116, 101, 100, 95, 118, 97, 114, 105, 97, 110, 116, 115, 47]),
		PackedByteArray([47, 100, 111, 119, 110, 108, 111, 97, 100, 115, 47]),
	]


func _audit_manifest(expected_manifest_sha256: String, expected_content_sha256: String, files: Array[String]) -> Dictionary:
	if FileAccess.get_sha256(MANIFEST_PATH) != expected_manifest_sha256:
		return _error("manifest_hash", "Mounted manifest does not match the explicit expected SHA-256.")
	var read_result := _read_json_object(MANIFEST_PATH)
	if not read_result.ok:
		return read_result
	var manifest: Dictionary = read_result.data
	if str(manifest.get("schema_version", "")) != EXPECTED_MANIFEST_SCHEMA:
		return _error("manifest_schema", "Unexpected generated-world manifest schema.")
	if str(manifest.get("content_sha256", "")) != expected_content_sha256:
		return _error("content_identity", "Mounted manifest does not match the explicit expected content SHA-256.")
	var counts := manifest.get("counts", {}) as Dictionary
	if int(counts.get("source_rows", -1)) != EXPECTED_SOURCE_ROWS \
	or int(counts.get("playable_rows", -1)) != EXPECTED_PLAYABLE_ROWS \
	or int(counts.get("context_rows", -1)) != EXPECTED_CONTEXT_ROWS \
	or int(counts.get("unresolved_rows", -1)) != 0 \
	or int(counts.get("duplicate_source_keys", -1)) != 0 \
	or int(counts.get("chunks", -1)) != EXPECTED_CHUNKS:
		return _error("manifest_counts", "Generated-world coverage counts drifted.")
	var spawn := manifest.get("initial_spawn", {}) as Dictionary
	var origin := spawn.get("origin", []) as Array
	if origin.size() != 3 \
	or not Vector3(float(origin[0]), float(origin[1]), float(origin[2])).is_equal_approx(EXPECTED_SPAWN) \
	or not is_equal_approx(float(spawn.get("yaw", INF)), EXPECTED_SPAWN_YAW):
		return _error("manifest_spawn", "Generated-world ferry spawn or yaw drifted.")
	var entries := manifest.get("files", []) as Array
	if entries.size() != EXPECTED_CONTENT_FILES:
		return _error("artifact_count", "Manifest must index exactly %d generated content files." % EXPECTED_CONTENT_FILES)
	var seen_paths := {}
	var previous_path := ""
	var hash_input := PackedByteArray()
	for entry_value: Variant in entries:
		if not entry_value is Dictionary:
			return _error("artifact_index", "Manifest file entry is not an object.")
		var entry: Dictionary = entry_value
		var stored_path := str(entry.get("path", ""))
		var expected_hash := str(entry.get("sha256", ""))
		var byte_value: Variant = entry.get("bytes", null)
		if not _is_safe_relative_path(stored_path) \
		or seen_paths.has(stored_path) \
		or (not previous_path.is_empty() and stored_path <= previous_path):
			return _error("artifact_index", "Manifest file paths must be safe, unique, and strictly sorted: %s" % stored_path)
		if not _is_lower_sha256(expected_hash) or not _is_nonnegative_json_integer(byte_value):
			return _error("artifact_index", "Manifest hash or byte count is invalid for %s." % stored_path)
		var expected_bytes := int(byte_value)
		var resource_path := "%s%s" % [GENERATED_ROOT, stored_path]
		var file_result := _audit_file(resource_path, expected_hash, expected_bytes)
		if not file_result.ok:
			return file_result
		seen_paths[stored_path] = entry
		previous_path = stored_path
		hash_input.append_array(stored_path.to_utf8_buffer())
		hash_input.append(0)
		hash_input.append_array(expected_hash.to_utf8_buffer())
		hash_input.append(0)
		hash_input.append_array(str(expected_bytes).to_utf8_buffer())
		hash_input.append(10)
	var hashing := HashingContext.new()
	if hashing.start(HashingContext.HASH_SHA256) != OK or hashing.update(hash_input) != OK:
		return _error("content_hash_runtime", "Could not compute generated artifact-index hash.")
	var actual_content_sha256 := hashing.finish().hex_encode()
	if actual_content_sha256 != expected_content_sha256:
		return _error("content_hash", "Generated artifact-index content SHA-256 mismatch.")
	var chunks := manifest.get("chunks", []) as Array
	if chunks.size() != EXPECTED_CHUNKS:
		return _error("chunk_count", "Manifest must name exactly %d chunks." % EXPECTED_CHUNKS)
	var required_entries: Array = [
		manifest.get("coverage_ledger", {}),
		manifest.get("context", {}),
		manifest.get("terrain", {}),
		manifest.get("vegetation", {}),
	]
	required_entries.append_array(chunks)
	for required_value: Variant in required_entries:
		if not required_value is Dictionary:
			return _error("artifact_reference", "Required manifest artifact reference is malformed.")
		var required: Dictionary = required_value
		var required_path := str(required.get("path", ""))
		if not seen_paths.has(required_path):
			return _error("artifact_reference", "Required artifact is absent from the manifest index: %s" % required_path)
		var indexed: Dictionary = seen_paths[required_path]
		if str(indexed.get("sha256", "")) != str(required.get("sha256", "")) \
		or int(indexed.get("bytes", -1)) != int(required.get("bytes", -2)):
			return _error("artifact_reference", "Required artifact metadata differs from its index entry: %s" % required_path)
	if not seen_paths.has("qa/pavement-skin.json"):
		return _error("pavement_reference", "Pavement semantic audit is absent from the manifest index.")
	var actual_generated: Array[String] = []
	for path: String in files:
		if path.begins_with(GENERATED_ROOT):
			actual_generated.append(path.trim_prefix(GENERATED_ROOT))
	var expected_generated: Array[String] = ["manifest.json"]
	for stored_path: Variant in seen_paths.keys():
		expected_generated.append(str(stored_path))
	expected_generated.sort()
	actual_generated.sort()
	if actual_generated != expected_generated or actual_generated.size() != EXPECTED_GENERATED_FILES:
		return _error("generated_inventory", "Mounted generated-world file set differs from manifest plus manifest.json.")
	return {
		"ok": true,
		"manifest_sha256": expected_manifest_sha256,
		"content_sha256": actual_content_sha256,
		"generated_files": actual_generated.size(),
		"chunks": chunks.size(),
	}


func _audit_file(path: String, expected_sha256: String, expected_bytes: int) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _error("artifact_missing", "Could not open mounted generated artifact: %s" % path)
	var actual_bytes := file.get_length()
	file = null
	if actual_bytes != expected_bytes:
		return _error("artifact_bytes", "Generated artifact byte count mismatch: %s" % path)
	var actual_sha256 := FileAccess.get_sha256(path)
	if actual_sha256 != expected_sha256:
		return _error("artifact_hash", "Generated artifact SHA-256 mismatch: %s" % path)
	return {"ok": true}


func _audit_vegetation() -> Dictionary:
	var result := _read_json_object("%svegetation.json" % GENERATED_ROOT)
	if not result.ok:
		return result
	var vegetation: Dictionary = result.data
	var assets := vegetation.get("assets", []) as Array
	var placements := vegetation.get("placements", []) as Array
	var counts := vegetation.get("counts", {}) as Dictionary
	var audit := vegetation.get("audit", {}) as Dictionary
	var naip := audit.get("naip_unknown_annotations", {}) as Dictionary
	if str(vegetation.get("schema_version", "")) != EXPECTED_VEGETATION_SCHEMA \
	or int(vegetation.get("seed", -1)) != EXPECTED_VEGETATION_SEED \
	or vegetation.get("visual_only", false) != true \
	or assets.size() != EXPECTED_VEGETATION_ASSETS \
	or placements.size() != EXPECTED_VEGETATION_PLACEMENTS \
	or int(counts.get("total", -1)) != EXPECTED_VEGETATION_PLACEMENTS \
	or int(audit.get("terrain_grounded_count", -1)) != EXPECTED_VEGETATION_PLACEMENTS \
	or int(audit.get("ybi_placements", -1)) != 0 \
	or int(naip.get("input_count", -1)) != EXPECTED_NAIP_SHRUBS \
	or int(naip.get("placed_count", -1)) != EXPECTED_NAIP_SHRUBS \
	or int(naip.get("rejected_count", -1)) != 0:
		return _error("vegetation_contract", "Vegetation schema, seed, counts, grounding, or NAIP shrub contract drifted.")
	var asset_paths := {}
	var prior_path := ""
	for asset_value: Variant in assets:
		if not asset_value is Dictionary:
			return _error("vegetation_asset", "Vegetation asset entry is malformed.")
		var asset: Dictionary = asset_value
		var path := str(asset.get("path", ""))
		if not path.begins_with("res://game/resources/models/vegetation/kenney_nature_kit/") \
		or not path.ends_with(".glb") \
		or asset_paths.has(path) \
		or (not prior_path.is_empty() and path <= prior_path):
			return _error("vegetation_asset", "Vegetation assets must be safe, unique, and strictly sorted: %s" % path)
		var resource := ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE)
		if not resource is PackedScene:
			return _error("vegetation_asset", "Packaged vegetation asset cannot load as PackedScene: %s" % path)
		asset_paths[path] = true
		prior_path = path
	for placement_value: Variant in placements:
		if not placement_value is Dictionary \
		or not asset_paths.has(str((placement_value as Dictionary).get("asset_path", ""))):
			return _error("vegetation_placement", "Vegetation placement references an unapproved packaged asset.")
	return {"ok": true, "assets": assets.size(), "placements": placements.size(), "naip_shrubs": int(naip.placed_count)}


func _audit_pavement() -> Dictionary:
	var result := _read_json_object("%sqa/pavement-skin.json" % GENERATED_ROOT)
	if not result.ok:
		return result
	var pavement: Dictionary = result.data
	var classification := pavement.get("source_classification", {}) as Dictionary
	var visual_counts := classification.get("by_visual_class", {}) as Dictionary
	var materials := pavement.get("materials", {}) as Dictionary
	var paved_area := materials.get("paved_area", {}) as Dictionary
	var topology := pavement.get("topology", {}) as Dictionary
	if str(pavement.get("schema_version", "")) != EXPECTED_PAVEMENT_SCHEMA \
	or pavement.get("visual_only", false) != true \
	or int(classification.get("source_count", -1)) != EXPECTED_PAVEMENT_SOURCES \
	or int(visual_counts.get("vehicle", -1)) != EXPECTED_VEHICLE_SOURCES \
	or int(visual_counts.get("pedestrian", -1)) != EXPECTED_PEDESTRIAN_SOURCES \
	or int(paved_area.get("source_count", -1)) != EXPECTED_PAVED_AREA_SOURCES \
	or int(topology.get("base_source_count", -1)) != EXPECTED_PAVEMENT_SOURCES \
	or int(topology.get("pedestrian_source_count", -1)) != EXPECTED_PEDESTRIAN_SOURCES \
	or topology.get("physical_collision_changed", true) != false \
	or topology.get("vehicle_precedence_at_crossings", false) != true \
	or topology.get("continuous_filled_base_union", false) != true:
		return _error("pavement_contract", "Pavement source classification or visual-only topology contract drifted.")
	return {"ok": true}


func _audit_resource_graph() -> Dictionary:
	var scenes := {}
	for path: String in REQUIRED_SCENES:
		var resource := ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE)
		if not resource is PackedScene:
			return _error("scene_load", "Packaged scene cannot load: %s" % path)
		scenes[path] = resource
	for path: String in POLY_HAVEN_TEXTURES:
		var resource := ResourceLoader.load(path, "Texture2D", ResourceLoader.CACHE_MODE_IGNORE)
		if not resource is Texture2D \
		or Vector2i((resource as Texture2D).get_width(), (resource as Texture2D).get_height()) != Vector2i(1024, 1024):
			return _error("polyhaven_texture", "Packaged Poly Haven map is missing or not 1024x1024: %s" % path)
	var tag := ResourceLoader.load(EXPECTED_TAG_PATH, "Texture2D", ResourceLoader.CACHE_MODE_IGNORE)
	if not tag is Texture2D \
	or (tag as Texture2D).resource_path != EXPECTED_TAG_PATH \
	or Vector2i((tag as Texture2D).get_width(), (tag as Texture2D).get_height()) != EXPECTED_TAG_SIZE:
		return _error("tag_resource", "Packaged predefined spray-tag texture identity or dimensions drifted.")
	var player := (scenes["res://game/scenes/player/player.tscn"] as PackedScene).instantiate()
	if player == null:
		return _error("player_instance", "Packaged player scene could not instantiate.")
	for property: String in EXPECTED_MOVEMENT:
		var actual: Variant = player.get(property)
		if actual == null or not is_equal_approx(float(actual), float(EXPECTED_MOVEMENT[property])):
			player.free()
			return _error("movement_defaults", "Packaged player property drifted: %s" % property)
	player.free()
	if not _action_has_physical_key("jetpack", KEY_SPACE):
		return _error("jetpack_input", "Mounted project does not bind physical Space to jetpack.")
	var bridge_resource := ResourceLoader.load(EXPECTED_BRIDGE_PATH, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE)
	if not bridge_resource is PackedScene:
		return _error("bridge_resource", "Packaged western Bay Bridge model cannot load.")
	var world := (scenes["res://game/scenes/world/world_root.tscn"] as PackedScene).instantiate()
	if world == null:
		return _error("world_instance", "Packaged world scene could not instantiate.")
	var bridge := world.get_node_or_null("ContextWorld/WesternBayBridgeModel")
	if bridge == null \
	or str(bridge.get_meta("license", "")) != "CC BY 4.0" \
	or bridge.find_children("*", "MeshInstance3D", true, false).is_empty() \
	or not bridge.find_children("*", "CollisionObject3D", true, false).is_empty():
		world.free()
		return _error("bridge_context", "Packaged western Bay Bridge context is missing, unattributed, invisible, or colliding.")
	var billboard := world.get_node_or_null("ContextWorld/SanFranciscoBillboard") as MeshInstance3D
	var billboard_mesh := billboard.mesh as QuadMesh if billboard != null else null
	var billboard_material := billboard_mesh.material as StandardMaterial3D if billboard_mesh != null else null
	var skyline := billboard_material.albedo_texture if billboard_material != null else null
	if skyline == null \
	or skyline.resource_path != EXPECTED_SKYLINE_PATH \
	or Vector2i(skyline.get_width(), skyline.get_height()) != EXPECTED_SKYLINE_SIZE:
		world.free()
		return _error("skyline_context", "Packaged active skyline texture identity or dimensions drifted.")
	world.free()
	var main := (scenes[EXPECTED_MAIN_SCENE] as PackedScene).instantiate()
	if main == null \
	or not main.has_node("WorldRoot") \
	or not main.has_node("Player") \
	or not main.has_node("Interface/HUD"):
		if main != null:
			main.free()
		return _error("main_graph", "Packaged main scene graph is incomplete.")
	main.free()
	return {"ok": true}


func _action_has_physical_key(action: StringName, keycode: Key) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey and (event as InputEventKey).physical_keycode == keycode:
			return true
	return false


func _read_json_object(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _error("json_open", "Could not open mounted JSON file: %s" % path)
	var text := file.get_as_text()
	file = null
	var parser := JSON.new()
	var parse_error := parser.parse(text)
	if parse_error != OK:
		return _error("json_parse", "%s:%d: %s" % [path, parser.get_error_line(), parser.get_error_message()])
	if not parser.data is Dictionary:
		return _error("json_shape", "Mounted JSON root is not an object: %s" % path)
	return {"ok": true, "data": parser.data}


func _is_safe_relative_path(path: String) -> bool:
	if path.is_empty() or path.begins_with("/") or path.begins_with("res://") or path.contains("\\"):
		return false
	for component: String in path.split("/"):
		if component.is_empty() or component == "." or component == "..":
			return false
	return true


func _is_nonnegative_json_integer(value: Variant) -> bool:
	if not value is int and not value is float:
		return false
	var number := float(value)
	return not is_nan(number) and not is_inf(number) and number >= 0.0 and number == floorf(number)


func _is_lower_sha256(value: String) -> bool:
	if value.length() != 64:
		return false
	for index: int in range(value.length()):
		var code := value.unicode_at(index)
		if not (code >= 48 and code <= 57) and not (code >= 97 and code <= 102):
			return false
	return true


func _error(code: String, message: String) -> Dictionary:
	return {"ok": false, "code": code, "message": message}


func _fail(code: String, message: String) -> void:
	push_error("PCK_AUDIT_FAIL [%s]: %s" % [code, message])
	quit(1)
