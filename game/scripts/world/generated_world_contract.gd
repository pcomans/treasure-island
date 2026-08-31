class_name GeneratedWorldContract
extends RefCounted

const MANIFEST_SCHEMA := "ti.godot-world/2"
const CHUNK_SCHEMA := "ti.godot-world-chunk/2"
const CONTEXT_SCHEMA := "ti.godot-world-context/2"
const EXPECTED_SOURCE_ROWS := 739
const EXPECTED_PLAYABLE_ROWS := 735
const EXPECTED_CONTEXT_ROWS := 4
const EXPECTED_CHUNK_SIZE_M := 256.0
const ROAD_BASE_SURFACE_BIAS_M := 0.078
const ROAD_PEDESTRIAN_SURFACE_BIAS_M := 0.08
const VEGETATION_SCHEMA := "ti.vegetation/1"
const VEGETATION_SEED := 1414092337
const EXPECTED_VEGETATION_COUNT := 124
const VEGETATION_ASSET_ROOT := "res://game/resources/models/vegetation/kenney_nature_kit/"
const VEGETATION_ASSET_SPECIES := {
	"res://game/resources/models/vegetation/kenney_nature_kit/grass.glb": "ornamental_grass",
	"res://game/resources/models/vegetation/kenney_nature_kit/grass_large.glb": "ornamental_grass",
	"res://game/resources/models/vegetation/kenney_nature_kit/grass_leafsLarge.glb": "ornamental_grass",
	"res://game/resources/models/vegetation/kenney_nature_kit/plant_bushDetailed.glb": "shrub",
	"res://game/resources/models/vegetation/kenney_nature_kit/plant_bushLarge.glb": "shrub",
	"res://game/resources/models/vegetation/kenney_nature_kit/plant_bushSmall.glb": "shrub",
	"res://game/resources/models/vegetation/kenney_nature_kit/tree_detailed.glb": "broadleaf",
	"res://game/resources/models/vegetation/kenney_nature_kit/tree_oak.glb": "broadleaf",
	"res://game/resources/models/vegetation/kenney_nature_kit/tree_palmBend.glb": "palm",
	"res://game/resources/models/vegetation/kenney_nature_kit/tree_palmDetailedShort.glb": "palm",
	"res://game/resources/models/vegetation/kenney_nature_kit/tree_palmDetailedTall.glb": "palm",
	"res://game/resources/models/vegetation/kenney_nature_kit/tree_pineTallA_detailed.glb": "conifer",
	"res://game/resources/models/vegetation/kenney_nature_kit/tree_pineTallB_detailed.glb": "conifer",
	"res://game/resources/models/vegetation/kenney_nature_kit/tree_plateau.glb": "broadleaf",
	"res://game/resources/models/vegetation/kenney_nature_kit/tree_thin.glb": "broadleaf",
}
const BOUNDARY_TOLERANCE_M := 0.001
const MIN_TRIANGLE_AREA_M2 := 0.00000001
const BOUNDARY_SOURCE_KEY := "w26767313"
const CONTEXT_SOURCE_KEYS := ["r13543937", "r13543938", "w1011568818", "w26767311"]
const FEATURE_KINDS := [
	"boundary_blocker",
	"building_part_roof",
	"building_part_wall",
	"building_roof",
	"building_wall",
	"land_ground",
	"major_area",
	"road_path",
	"terrain_overlay",
]
const CONTEXT_KINDS := ["bay_bridge", "ybi"]
const BOUNDARY_ATTACHED_SOURCE_KEYS := ["w319406837", "w644986117"]
const ISLE_HOUSE_COMPOSITE_KEY := "building-composite:w1249412094"
const ISLE_HOUSE_COMPOSITE_PART_KEYS := [
	"building-composite:w1249412094:w1282547786:roof",
	"building-composite:w1249412094:w1282547786:wall",
	"building-composite:w1249412094:w1282547787:roof",
	"building-composite:w1249412094:w1282547787:wall",
]
const BOUNDARY_ATTACHED_OBJECTS := {
	"w319406837": {
		"object_key": "boundary_context:w319406837",
		"material_key": "context_boundary_pier",
	},
	"w644986117": {
		"object_key": "boundary_context:w644986117",
		"material_key": "context_boundary_marina",
	},
}
const EXPECTED_MEMBERSHIPS := {
	"land_boundary": 1,
	"terrain_shoreline": 22,
	"roads_paths": 427,
	"major_area": 80,
	"building": 213,
	"building_part": 2,
}
const EXPECTED_MULTI_CATEGORY_KEYS := [
	"w110183752",
	"w1222505177",
	"w1436064757",
	"w291189336",
	"w291189918",
	"w319406837",
	"w34313521",
	"w34313547",
	"w644986117",
	"w764313741",
]
const REQUIRED_SOURCE_ARTIFACTS := {
	"raw_osm": {
		"path": "data/osm/treasure-island-2026-08-27.osm",
		"sha256": "3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549",
	},
	"extraction_polygon": {
		"path": "data/osm/treasure-island-polygon.geojson",
		"sha256": "43adbe335e87f0d839b56c2f5933ae97d35d4f588ce93bd09923a98620dd2b63",
	},
	"proper_extract": {
		"path": "data/osm/treasure-island-proper-2026-08-27.osm.pbf",
		"sha256": "13984ed8f70c9d5d39d4ba14f83c7307eb75428af7b07df5774df29bda4ccaf9",
	},
	"source_ledger": {
		"path": "data/osm/treasure-island-source-inventory.csv",
		"sha256": "fdf57f37f5507a7cb9b64a7fc530eabb22e29f3742324d5347c0f6b1949cb4cb",
	},
	"source_summary": {
		"path": "data/osm/treasure-island-source-inventory-summary.json",
		"sha256": "49eb5c9fadd1b81b3fd687beb59cd9f917eb197069bcb993f5a0a3f2588d90d7",
	},
	"terrain_dem": {
		"path": "data/terrain/treasure-island-ybi-usgs-3dep-2023.tif",
		"sha256": "3af54acdd116f3e253af8ece5ec501a08dff94cfca47b7f05f2c326c9ba33f3f",
	},
}
const COVERAGE_HEADERS := [
	"source_key", "osm_type", "osm_id", "scope", "categories", "source_version",
	"derived_world_status", "derived_object_key", "part_keys", "chunk_ids",
	"representation_kind", "dimension_rule", "height_m", "composite_key", "note",
	"vertex_count", "triangle_count", "collision_triangle_count", "validation",
]
const CHUNK_FIELDS := ["bounds_m", "chunk_id", "records", "schema_version"]
const CHUNK_BOUNDS_FIELDS := ["max_x", "max_z", "min_x", "min_z"]
const CONTEXT_FIELDS := ["boundary_attached_visuals", "records", "schema_version"]
const MESH_RECORD_FIELDS := [
	"collision_kind", "feature_kind", "indices", "material_key", "normals", "object_key",
	"opaque", "receiver_kind", "source_keys", "uvs", "vertices",
]
const SURFACE_RECORD_FIELDS := ["surface_bias_m"]
const BUILDING_LEVEL_FIELDS := ["flat_base_elevation_m", "source_height_m", "top_elevation_m"]
const BUILDING_WALL_FIELDS := ["exterior_foundation_segments", "shared_wall_segments"]
const CONTEXT_RECORD_FIELDS := [
	"collision_kind", "context_kind", "indices", "material_key", "normals", "object_key",
	"opaque", "receiver_kind", "source_keys", "uvs", "vertices",
]


static func load_and_validate(manifest_path: String) -> Dictionary:
	var manifest_result := _read_json_object(manifest_path)
	if not manifest_result.ok:
		return manifest_result
	var manifest: Dictionary = manifest_result.data
	var result := _validate_manifest_shape(manifest)
	if not result.ok:
		return result
	result = _validate_source_artifacts(manifest)
	if not result.ok:
		return result
	result = _validate_artifact_index(manifest, manifest_path)
	if not result.ok:
		return result
	var terrain_path := _resolve_artifact_path(manifest_path, str(manifest.terrain.path))
	var terrain_result := _read_json_object(terrain_path)
	if not terrain_result.ok:
		return terrain_result
	result = _validate_terrain(terrain_result.data)
	if not result.ok:
		return result

	var coverage_path := _resolve_artifact_path(manifest_path, str(manifest.coverage_ledger.path))
	var coverage_result := _read_and_validate_coverage(coverage_path)
	if not coverage_result.ok:
		return coverage_result
	var coverage_rows: Array = coverage_result.rows
	var source_scopes: Dictionary = coverage_result.source_scopes
	var approved_composite_sources: Dictionary = coverage_result.approved_composite_sources

	var chunk_results: Array[Dictionary] = []
	var record_keys: Dictionary = {}
	var represented_playable: Dictionary = {}
	for entry_value: Variant in manifest.chunks:
		var entry: Dictionary = entry_value
		var chunk_path := _resolve_artifact_path(manifest_path, str(entry.path))
		var chunk_result := _read_json_object(chunk_path)
		if not chunk_result.ok:
			return chunk_result
		result = _validate_chunk(chunk_result.data, str(entry.chunk_id), source_scopes, record_keys, represented_playable, manifest.material_keys, manifest.feature_kinds, manifest.playable_boundary)
		if not result.ok:
			return result
		chunk_results.append(chunk_result.data)

	var context_path := _resolve_artifact_path(manifest_path, str(manifest.context.path))
	var context_result := _read_json_object(context_path)
	if not context_result.ok:
		return context_result
	var represented_context: Dictionary = {}
	result = _validate_context(context_result.data, source_scopes, record_keys, represented_context, represented_playable, manifest.material_keys)
	if not result.ok:
		return result
	var vegetation_path := _resolve_artifact_path(manifest_path, str(manifest.vegetation.path))
	var vegetation_result := _read_json_object(vegetation_path)
	if not vegetation_result.ok:
		return vegetation_result
	result = _validate_vegetation(vegetation_result.data, chunk_results, manifest.playable_boundary)
	if not result.ok:
		return result

	result = _validate_coverage_references(coverage_rows, record_keys, represented_playable, represented_context, approved_composite_sources)
	if not result.ok:
		return result
	for key_value: Variant in source_scopes.keys():
		var key := str(key_value)
		if source_scopes[key] == "playable" and not represented_playable.has(key):
			return _failure("coverage_missing_geometry", "Playable source %s has no chunk record." % key, [key])
		if source_scopes[key] == "context" and not represented_context.has(key):
			return _failure("context_missing_geometry", "Context source %s has no context record." % key, [key])

	var boundary: Dictionary = manifest.playable_boundary
	var spawn_result := _spawn_transform(manifest.initial_spawn, boundary)
	if not spawn_result.ok:
		return spawn_result

	return {
		"ok": true,
		"manifest": manifest,
		"manifest_path": manifest_path,
		"chunks": chunk_results,
		"context": context_result.data,
		"terrain": terrain_result.data,
		"vegetation": vegetation_result.data,
		"coverage_rows": coverage_rows,
		"spawn_transform": spawn_result.transform,
		"boundary": boundary,
		"report": {
			"content_sha256": manifest.content_sha256,
			"chunks": chunk_results.size(),
			"playable_rows": EXPECTED_PLAYABLE_ROWS,
			"context_rows": EXPECTED_CONTEXT_ROWS,
			"source_rows": EXPECTED_SOURCE_ROWS,
			"vegetation_seed": int(vegetation_result.data.seed),
			"vegetation_instances": int(vegetation_result.data.counts.total),
			"vegetation_species_counts": vegetation_result.data.counts.by_species.duplicate(true),
			"vegetation_zone_counts": vegetation_result.data.counts.by_zone.duplicate(true),
		},
	}


static func _validate_manifest_shape(manifest: Dictionary) -> Dictionary:
	if str(manifest.get("schema_version", "")) != MANIFEST_SCHEMA:
		return _failure("manifest_schema", "Expected manifest schema %s." % MANIFEST_SCHEMA)
	if not _is_hex_sha256(str(manifest.get("content_sha256", ""))):
		return _failure("manifest_content_hash", "Manifest content_sha256 is missing or invalid.")
	if str(manifest.get("boundary_source_key", "")) != BOUNDARY_SOURCE_KEY:
		return _failure("manifest_boundary", "Playable boundary must be %s." % BOUNDARY_SOURCE_KEY)
	if str(manifest.get("generator_version", "")).is_empty():
		return _failure("manifest_generator", "Manifest generator version is missing.")
	if not is_equal_approx(float(manifest.get("chunk_size_m", 0.0)), EXPECTED_CHUNK_SIZE_M):
		return _failure("manifest_chunk_size", "Chunk size must be 256 meters.")
	var coordinate_result := _validate_coordinate_system(manifest.get("coordinate_system", {}))
	if not coordinate_result.ok:
		return coordinate_result
	if not manifest.get("counts", null) is Dictionary:
		return _failure("manifest_counts", "Manifest counts object is missing.")
	var counts: Dictionary = manifest.counts
	for count_field: String in ["source_rows", "playable_rows", "context_rows", "unresolved_rows", "duplicate_source_keys", "chunks"]:
		if not _is_nonnegative_json_integer(counts.get(count_field, null)):
			return _failure("manifest_counts", "Manifest count %s must be an exact non-negative integer." % count_field)
	if int(counts.get("source_rows", -1)) != EXPECTED_SOURCE_ROWS \
	or int(counts.get("playable_rows", -1)) != EXPECTED_PLAYABLE_ROWS \
	or int(counts.get("context_rows", -1)) != EXPECTED_CONTEXT_ROWS \
	or int(counts.get("unresolved_rows", -1)) != 0 \
	or int(counts.get("duplicate_source_keys", -1)) != 0:
		return _failure("manifest_coverage_counts", "Manifest must declare 735 playable + 4 context rows, with zero unresolved or duplicate rows.")
	if not counts.get("category_memberships", null) is Dictionary:
		return _failure("manifest_memberships", "Manifest category membership counts are missing.")
	for category_value: Variant in EXPECTED_MEMBERSHIPS.keys():
		var category := str(category_value)
		var membership_value: Variant = counts.category_memberships.get(category, null)
		if not _is_nonnegative_json_integer(membership_value) or int(membership_value) != int(EXPECTED_MEMBERSHIPS[category]):
			return _failure("manifest_memberships", "Manifest membership count differs for %s." % category)
	if not manifest.get("chunks", null) is Array or manifest.chunks.is_empty():
		return _failure("manifest_chunks", "Manifest contains no chunk index.")
	if int(counts.get("chunks", -1)) != manifest.chunks.size():
		return _failure("manifest_chunks", "Manifest chunk count does not match its chunk index.")
	var prior_chunk_id := ""
	var seen_chunk_ids: Dictionary = {}
	for chunk_value: Variant in manifest.chunks:
		if not chunk_value is Dictionary:
			return _failure("manifest_chunks", "Manifest chunk entry is not an object.")
		var chunk_entry: Dictionary = chunk_value
		var chunk_id := str(chunk_entry.get("chunk_id", ""))
		if not _valid_chunk_id(chunk_id) or seen_chunk_ids.has(chunk_id) or (not prior_chunk_id.is_empty() and _compare_chunk_ids(prior_chunk_id, chunk_id) >= 0):
			return _failure("manifest_chunks", "Manifest chunk IDs must be valid, unique, and sorted.")
		if not str(chunk_entry.get("path", "")).ends_with("/%s.json" % chunk_id):
			return _failure("manifest_chunks", "Manifest chunk path does not match chunk ID %s." % chunk_id)
		seen_chunk_ids[chunk_id] = true
		prior_chunk_id = chunk_id
	if not manifest.get("files", null) is Array or manifest.files.is_empty():
		return _failure("manifest_files", "Manifest artifact index is missing.")
	if not manifest.get("coverage_ledger", null) is Dictionary or not manifest.get("context", null) is Dictionary \
	or not manifest.get("terrain", null) is Dictionary or not manifest.get("vegetation", null) is Dictionary:
		return _failure("manifest_required_files", "Manifest coverage, context, terrain, or vegetation entry is missing.")
	if not manifest.get("initial_spawn", null) is Dictionary:
		return _failure("manifest_spawn", "Manifest initial spawn is missing.")
	if not manifest.get("playable_boundary", null) is Dictionary:
		return _failure("manifest_boundary", "Manifest playable boundary geometry is missing.")
	var boundary_result := validate_boundary(manifest.playable_boundary)
	if not boundary_result.ok:
		return boundary_result
	if not manifest.get("feature_kinds", null) is Array:
		return _failure("manifest_feature_kinds", "Manifest feature kind declaration is missing.")
	var declared_features := _sorted_strings(manifest.feature_kinds)
	if declared_features.is_empty():
		return _failure("manifest_feature_kinds", "Manifest feature kind declaration is empty.")
	if _sorted_unique_strings(manifest.feature_kinds) != manifest.feature_kinds:
		return _failure("manifest_feature_kinds", "Manifest feature kinds must be unique and sorted.")
	for feature_value: Variant in declared_features:
		if not FEATURE_KINDS.has(str(feature_value)):
			return _failure("manifest_feature_kinds", "Manifest declares an unknown feature kind: %s" % str(feature_value))
	if not manifest.get("material_keys", null) is Array or manifest.material_keys.is_empty():
		return _failure("manifest_materials", "Manifest material key list is empty.")
	if _sorted_unique_strings(manifest.material_keys) != manifest.material_keys:
		return _failure("manifest_materials", "Manifest material keys must be unique and sorted.")
	return {"ok": true}


static func _validate_source_artifacts(manifest: Dictionary) -> Dictionary:
	if not manifest.get("sources", null) is Dictionary:
		return _failure("source_index", "Manifest source index is missing.")
	var sources: Dictionary = manifest.sources
	if sources.size() != REQUIRED_SOURCE_ARTIFACTS.size():
		return _failure("source_index", "Manifest must name exactly the six frozen source artifacts.")
	for name_value: Variant in REQUIRED_SOURCE_ARTIFACTS.keys():
		var name := str(name_value)
		if not sources.get(name, null) is Dictionary:
			return _failure("source_index", "Manifest source entry %s is missing." % name)
		var entry: Dictionary = sources[name]
		var expected: Dictionary = REQUIRED_SOURCE_ARTIFACTS[name]
		if str(entry.get("path", "")) != str(expected.path) or str(entry.get("sha256", "")) != str(expected.sha256):
			return _failure("source_contract", "Source path or frozen hash differs for %s." % name)
		if not _is_nonnegative_json_integer(entry.get("bytes", null)):
			return _failure("source_contract", "Source byte count is not an exact non-negative integer for %s." % name)
		# Raw/source audit inputs are intentionally absent from the private exported PCK.
		# Their exact recorded paths and hashes remain mandatory in every manifest; the
		# editor additionally proves those bytes still match the frozen local source.
		if not OS.has_feature("editor"):
			continue
		var resource_path := "res://%s" % str(entry.path)
		var file_result := _validate_file(resource_path, str(entry.sha256), int(entry.get("bytes", -1)))
		if not file_result.ok:
			return _failure("source_drift", "%s: %s" % [name, file_result.message])
	return {"ok": true}


static func _validate_artifact_index(manifest: Dictionary, manifest_path: String) -> Dictionary:
	var seen_paths: Dictionary = {}
	var previous_path := ""
	var hash_input := PackedByteArray()
	for entry_value: Variant in manifest.files:
		if not entry_value is Dictionary:
			return _failure("artifact_index", "Manifest file entry is not an object.")
		var entry: Dictionary = entry_value
		var stored_path := str(entry.get("path", ""))
		if stored_path.is_empty() or seen_paths.has(stored_path) or (not previous_path.is_empty() and stored_path < previous_path):
			return _failure("artifact_index", "Manifest file paths must be unique and sorted.")
		seen_paths[stored_path] = true
		previous_path = stored_path
		var expected_hash := str(entry.get("sha256", ""))
		var byte_value: Variant = entry.get("bytes", null)
		if not _is_nonnegative_json_integer(byte_value):
			return _failure("artifact_index", "Manifest byte count must be an exact non-negative integer: %s" % stored_path)
		var expected_bytes := int(byte_value)
		var path := _resolve_artifact_path(manifest_path, stored_path)
		if path.is_empty():
			return _failure("artifact_path", "Unsafe generated artifact path: %s" % stored_path)
		var file_result := _validate_file(path, expected_hash, expected_bytes)
		if not file_result.ok:
			return _failure("artifact_hash", "%s: %s" % [stored_path, file_result.message])
		# GDScript replaces a NUL embedded in a String with U+FFFD. Assemble the
		# documented path\0sha256\0bytes\n stream as bytes so it is identical to Node.
		hash_input.append_array(stored_path.to_utf8_buffer())
		hash_input.append(0)
		hash_input.append_array(expected_hash.to_utf8_buffer())
		hash_input.append(0)
		hash_input.append_array(str(expected_bytes).to_utf8_buffer())
		hash_input.append(10)
	var hashing := HashingContext.new()
	if hashing.start(HashingContext.HASH_SHA256) != OK:
		return _failure("hash_runtime", "Could not initialize SHA-256 validation.")
	if hashing.update(hash_input) != OK:
		return _failure("hash_runtime", "Could not update SHA-256 validation.")
	var actual_content_hash := hashing.finish().hex_encode()
	if actual_content_hash != str(manifest.content_sha256):
		return _failure("manifest_content_hash", "Manifest artifact-index content hash does not match.")

	var required_entries: Array[Dictionary] = [manifest.coverage_ledger, manifest.context, manifest.terrain, manifest.vegetation]
	for chunk_value: Variant in manifest.chunks:
		required_entries.append(chunk_value)
	for required: Dictionary in required_entries:
		var required_path := str(required.get("path", ""))
		if not seen_paths.has(required_path):
			return _failure("artifact_index", "Required file is absent from the manifest file index: %s" % required_path)
		if not _is_nonnegative_json_integer(required.get("bytes", null)):
			return _failure("artifact_index", "Required file byte count must be an exact non-negative integer: %s" % required_path)
		var indexed := _find_file_entry(manifest.files, required_path)
		if str(indexed.get("sha256", "")) != str(required.get("sha256", "")) or int(indexed.get("bytes", -1)) != int(required.get("bytes", -2)):
			return _failure("artifact_index", "Required file metadata differs from the artifact index: %s" % required_path)
	return {"ok": true}


static func _validate_terrain(terrain: Dictionary) -> Dictionary:
	if str(terrain.get("schema_version", "")) != "ti.usgs-terrain/1":
		return _failure("terrain_schema", "Generated terrain metadata schema is invalid.")
	if str(terrain.get("source_tile_id", "")) != "USGS_1M_10_x55y419_CA_SanFrancisco_B23.tif" \
	or int(terrain.get("locked_raster_object_id", -1)) != 71423 \
	or str(terrain.get("vertical_datum", "")) != "NAVD 88" \
	or not is_equal_approx(float(terrain.get("mesh_grid_size_m", 0.0)), 32.0) \
	or str(terrain.get("shoreline_plan_authority", "")) != "frozen OSM snapshot":
		return _failure("terrain_source", "Generated terrain source, datum, grid, or shoreline authority drifted.")
	var export_size: Array = terrain.get("export_size_pixels", [])
	if export_size.size() != 2 or int(export_size[0]) != 1669 or int(export_size[1]) != 2048:
		return _failure("terrain_raster", "USGS terrain export dimensions drifted.")
	var statistics: Dictionary = terrain.get("statistics", {})
	if int(statistics.get("valid_sample_count", -1)) != 2492288 \
	or not is_equal_approx(float(statistics.get("minimum_elevation_m", INF)), -1.08) \
	or not is_equal_approx(float(statistics.get("maximum_elevation_m", -INF)), 104.756):
		return _failure("terrain_raster", "USGS terrain valid-sample count or elevation range drifted.")
	var samples: Array = terrain.get("pinned_samples", [])
	if samples.size() != 5:
		return _failure("terrain_samples", "USGS terrain must retain exactly five pinned samples.")
	var pinned: Dictionary = {}
	for sample_value: Variant in samples:
		if not sample_value is Dictionary:
			return _failure("terrain_samples", "USGS terrain pinned sample is malformed.")
		var sample: Dictionary = sample_value
		pinned[str(sample.get("id", ""))] = float(sample.get("elevation_m", INF))
	if not pinned.has("ferry_vicinity") or not is_equal_approx(float(pinned.ferry_vicinity), 4.037) \
	or not pinned.has("treasure_island_center") or not is_equal_approx(float(pinned.treasure_island_center), 3.265) \
	or not pinned.has("treasure_island_north") or not is_equal_approx(float(pinned.treasure_island_north), 3.467) \
	or not pinned.has("ybi_high_ground") or not is_equal_approx(float(pinned.ybi_high_ground), 104.756) \
	or not pinned.has("ybi_low_shoreline") or not is_equal_approx(float(pinned.ybi_low_shoreline), 0.0):
		return _failure("terrain_samples", "USGS terrain pinned samples drifted.")
	var surface_anchors: Array = terrain.get("surface_anchors", [])
	if surface_anchors.size() != 18:
		return _failure("terrain_anchors", "Generated terrain must retain exactly eighteen traversal/capture surface anchors.")
	var ferry_surface_found := false
	for anchor_value: Variant in surface_anchors:
		if anchor_value is Dictionary and str(anchor_value.get("id", "")) == "01-ferry-spawn" \
		and is_equal_approx(float(anchor_value.get("elevation_m", INF)), 3.457):
			ferry_surface_found = true
	if not ferry_surface_found:
		return _failure("terrain_anchors", "Generated ferry terrain-surface anchor drifted.")
	var conformance: Dictionary = terrain.get("playable_surface_conformance", {})
	if int(conformance.get("sample_points", 0)) <= 0 \
	or float(conformance.get("maximum_bias_deviation_m", INF)) > float(conformance.get("maximum_serialization_tolerance_m", -INF)) \
	or float(conformance.get("minimum_clearance_m", -INF)) < 0.019 \
	or float(conformance.get("maximum_clearance_m", INF)) > 0.081:
		return _failure("terrain_conformance", "Playable overlays do not retain their exact land-plane conformance audit.")
	var foundations: Dictionary = terrain.get("building_foundations", {})
	if int(foundations.get("sample_points", 0)) <= 0 \
	or not is_zero_approx(float(foundations.get("maximum_positive_gap_m", INF))) \
	or float(foundations.get("maximum_positive_gap_m", INF)) > float(foundations.get("tolerance_m", -INF)) \
	or float(foundations.get("maximum_roof_elevation_range_m", INF)) > float(foundations.get("tolerance_m", -INF)) \
	or float(foundations.get("maximum_height_deviation_m", INF)) > float(foundations.get("tolerance_m", -INF)):
		return _failure("building_foundations", "Building foundation, roof-flatness, or source-height audit drifted.")
	return {"ok": true}


static func _validate_vegetation(vegetation: Dictionary, chunks: Array[Dictionary], boundary: Dictionary) -> Dictionary:
	if str(vegetation.get("schema_version", "")) != VEGETATION_SCHEMA:
		return _failure("vegetation_schema", "Generated vegetation schema is invalid.")
	if int(vegetation.get("seed", -1)) != VEGETATION_SEED or vegetation.get("visual_only", false) != true:
		return _failure("vegetation_contract", "Vegetation must use the pinned seed and remain visual-only.")
	if str(vegetation.get("asset_root", "")) != VEGETATION_ASSET_ROOT:
		return _failure("vegetation_assets", "Vegetation asset root is not the curated Kenney directory.")
	var assets: Array = vegetation.get("assets", [])
	if assets.size() != VEGETATION_ASSET_SPECIES.size():
		return _failure("vegetation_assets", "Vegetation allowed-asset palette is incomplete.")
	var prior_asset_path := ""
	for asset_value: Variant in assets:
		if not asset_value is Dictionary:
			return _failure("vegetation_assets", "Vegetation asset entry is not an object.")
		var asset: Dictionary = asset_value
		var asset_path := str(asset.get("path", ""))
		if not asset_path.begins_with(VEGETATION_ASSET_ROOT) or not asset_path.ends_with(".glb") \
		or not VEGETATION_ASSET_SPECIES.has(asset_path) \
		or str(asset.get("species", "")) != str(VEGETATION_ASSET_SPECIES[asset_path]) \
		or (not prior_asset_path.is_empty() and asset_path <= prior_asset_path) \
		or not ResourceLoader.exists(asset_path, "PackedScene"):
			return _failure("vegetation_assets", "Missing, unsafe, unsorted, or mismatched vegetation asset: %s" % asset_path)
		prior_asset_path = asset_path
	var clearances: Dictionary = vegetation.get("clearances_m", {})
	var expected_clearances := {
		"boundary_shoreline": 14.0,
		"roads_paths": 4.0,
		"buildings_foundations": 5.0,
		"terrain_shoreline_overlays": 3.0,
		"ferry_spawn": 24.0,
		"ferry_arrival_path": 16.0,
		"normal_qa_route": 7.0,
		"whole_island_qa_route": 5.0,
	}
	for key_value: Variant in expected_clearances.keys():
		var key := str(key_value)
		if not is_equal_approx(float(clearances.get(key, -1.0)), float(expected_clearances[key])):
			return _failure("vegetation_clearance", "Vegetation clearance contract drifted for %s." % key)
	var counts: Dictionary = vegetation.get("counts", {})
	var placements: Array = vegetation.get("placements", [])
	if placements.size() != EXPECTED_VEGETATION_COUNT or int(counts.get("total", -1)) != EXPECTED_VEGETATION_COUNT:
		return _failure("vegetation_count", "Expected the pinned 124-placement vegetation pass.")
	var expected_species_counts := {
		"broadleaf": 28,
		"conifer": 21,
		"ornamental_grass": 21,
		"palm": 13,
		"shrub": 41,
	}
	var expected_zone_counts := {
		"central_conifer_groves": 21,
		"legacy_grid_broadleaf": 20,
		"naip_unknown_shrubs": 22,
		"north_west_lawn_broadleaf": 8,
		"south_ornamental_beds": 34,
		"south_palm_rows": 13,
		"south_shrub_groups": 6,
	}
	if not _integer_counts_match(counts.get("by_species", {}), expected_species_counts) \
	or not _integer_counts_match(counts.get("by_zone", {}), expected_zone_counts):
		return _failure("vegetation_density", "Vegetation species or zone density drifted.")
	var by_asset: Dictionary = counts.get("by_asset", {})
	if by_asset.size() != VEGETATION_ASSET_SPECIES.size():
		return _failure("vegetation_assets", "Vegetation per-asset counts are incomplete.")
	for asset_path_value: Variant in VEGETATION_ASSET_SPECIES.keys():
		if int(by_asset.get(str(asset_path_value), 0)) <= 0:
			return _failure("vegetation_assets", "Every curated vegetation asset must have a placement.")
	var land_records: Dictionary = {}
	var road_records: Array[Dictionary] = []
	var building_records: Array[Dictionary] = []
	var shoreline_overlay_records: Array[Dictionary] = []
	for chunk: Dictionary in chunks:
		for record_value: Variant in chunk.records:
			var record: Dictionary = record_value
			if str(record.feature_kind) == "land_ground":
				land_records[str(record.object_key)] = record
			elif str(record.feature_kind) == "road_path":
				road_records.append(record)
			elif str(record.feature_kind) in ["building_roof", "building_part_roof"]:
				building_records.append(record)
			elif str(record.feature_kind) == "terrain_overlay":
				shoreline_overlay_records.append(record)
	var seen_ids: Dictionary = {}
	var prior_id := ""
	var computed_species_counts := {"broadleaf": 0, "conifer": 0, "ornamental_grass": 0, "palm": 0, "shrub": 0}
	var computed_zone_counts := expected_zone_counts.duplicate()
	for zone_value: Variant in computed_zone_counts.keys():
		computed_zone_counts[zone_value] = 0
	for placement_value: Variant in placements:
		if not placement_value is Dictionary:
			return _failure("vegetation_placement", "Vegetation placement is not an object.")
		var placement: Dictionary = placement_value
		var placement_id := str(placement.get("id", ""))
		var asset_path := str(placement.get("asset_path", ""))
		var species := str(placement.get("species", ""))
		var zone := str(placement.get("zone", ""))
		if not placement_id.begins_with("vegetation:") or seen_ids.has(placement_id) \
		or (not prior_id.is_empty() and placement_id <= prior_id):
			return _failure("vegetation_order", "Vegetation IDs must be canonical, unique, and sorted.")
		if not VEGETATION_ASSET_SPECIES.has(asset_path) or str(VEGETATION_ASSET_SPECIES[asset_path]) != species \
		or not computed_species_counts.has(species) or not computed_zone_counts.has(zone):
			return _failure("vegetation_palette", "Vegetation placement has an unknown zone/species/asset.")
		var position: Array = placement.get("position_m", [])
		var yaw := float(placement.get("yaw_radians", INF))
		var uniform_scale := float(placement.get("uniform_scale", -1.0))
		if position.size() != 3 or not is_finite(float(position[0])) or not is_finite(float(position[1])) \
		or not is_finite(float(position[2])) or not is_finite(yaw) or yaw < -PI or yaw > PI \
		or not is_finite(uniform_scale) or uniform_scale < 2.8 or uniform_scale > 7.4:
			return _failure("vegetation_transform", "Vegetation placement transform is invalid: %s" % placement_id)
		var xz := Vector2(float(position[0]), float(position[2]))
		if not contains_xz(boundary, xz):
			return _failure("vegetation_boundary", "Vegetation placement is outside Treasure Island: %s" % placement_id)
		var support: Dictionary = placement.get("terrain_support", {})
		var support_key := str(support.get("object_key", ""))
		var triangle_index_value: Variant = support.get("triangle_index", null)
		if not land_records.has(support_key) or not _is_nonnegative_json_integer(triangle_index_value):
			return _failure("vegetation_grounding", "Vegetation placement lacks playable terrain support: %s" % placement_id)
		var terrain_sample := _terrain_triangle_sample(land_records[support_key], int(triangle_index_value), xz)
		if not terrain_sample.ok or absf(float(terrain_sample.elevation_m) - float(position[1])) > 0.001001 \
		or not is_equal_approx(float(support.get("elevation_m", INF)), float(position[1])):
			return _failure("vegetation_grounding", "Vegetation placement is not exactly grounded: %s" % placement_id)
		if _minimum_plan_distance_to_records(xz, shoreline_overlay_records) < 2.998:
			return _failure("vegetation_shoreline_overlay", "Vegetation placement enters a terrain/shoreline overlay: %s" % placement_id)
		if zone == "naip_unknown_shrubs":
			if species != "shrub" or str(placement.get("annotation_tree_type", "")) != "unknown" \
			or str(placement.get("annotation_id", "")).is_empty() \
			or _minimum_plan_distance_to_records(xz, road_records) < 0.001 \
			or _minimum_plan_distance_to_records(xz, building_records) < 0.001:
				return _failure("vegetation_naip_unknown", "NAIP unknown shrub identity or surface-exterior contract failed: %s" % placement_id)
		seen_ids[placement_id] = true
		prior_id = placement_id
		computed_species_counts[species] += 1
		computed_zone_counts[zone] += 1
	if not _integer_counts_match(computed_species_counts, expected_species_counts) \
	or not _integer_counts_match(computed_zone_counts, expected_zone_counts):
		return _failure("vegetation_counts", "Vegetation placement rows do not match declared counts.")
	var audit: Dictionary = vegetation.get("audit", {})
	if int(audit.get("terrain_grounded_count", -1)) != EXPECTED_VEGETATION_COUNT or int(audit.get("ybi_placements", -1)) != 0:
		return _failure("vegetation_audit", "Vegetation grounding or no-YBI audit drifted.")
	var annotation_audit: Dictionary = audit.get("naip_unknown_annotations", {})
	var annotation_clearances: Dictionary = annotation_audit.get("clearance_policy_m", {})
	if int(annotation_audit.get("input_count", -1)) != 22 \
	or int(annotation_audit.get("placed_count", -1)) != 22 \
	or int(annotation_audit.get("rejected_count", -1)) != 0 \
	or (annotation_audit.get("procedural_buffer_exceptions", []) as Array).size() != 7 \
	or annotation_audit.get("fixed_projected_locations", false) != true \
	or not is_equal_approx(float(annotation_clearances.get("roads_paths", -1.0)), 0.001) \
	or not is_equal_approx(float(annotation_clearances.get("buildings_foundations", -1.0)), 0.001):
		return _failure("vegetation_naip_unknown", "NAIP unknown-to-shrub audit drifted.")
	var observed_clearances: Dictionary = audit.get("minimum_observed_clearances_m", {})
	if float(observed_clearances.get("terrain_shoreline_overlays", -1.0)) < 3.0:
		return _failure("vegetation_shoreline_overlay", "Vegetation terrain/shoreline overlay clearance audit failed.")
	return {"ok": true}


static func _integer_counts_match(actual_value: Variant, expected: Dictionary) -> bool:
	if not actual_value is Dictionary:
		return false
	var actual: Dictionary = actual_value
	if actual.size() != expected.size():
		return false
	for key_value: Variant in expected.keys():
		var key := str(key_value)
		if not actual.has(key) or int(actual[key]) != int(expected[key]):
			return false
	return true


static func _terrain_triangle_sample(record: Dictionary, triangle_index: int, point: Vector2) -> Dictionary:
	var indices: Array = record.get("indices", [])
	var vertices: Array = record.get("vertices", [])
	var offset := triangle_index * 3
	if offset < 0 or offset + 2 >= indices.size():
		return {"ok": false}
	var points: Array[Vector3] = []
	for index_offset in 3:
		var vertex_index := int(indices[offset + index_offset])
		if vertex_index < 0 or vertex_index * 3 + 2 >= vertices.size():
			return {"ok": false}
		points.append(Vector3(
			float(vertices[vertex_index * 3]),
			float(vertices[vertex_index * 3 + 1]),
			float(vertices[vertex_index * 3 + 2])
		))
	var a := points[0]
	var b := points[1]
	var c := points[2]
	var denominator := (b.z - c.z) * (a.x - c.x) + (c.x - b.x) * (a.z - c.z)
	if absf(denominator) <= 0.0000000001:
		return {"ok": false}
	var weight_a := ((b.z - c.z) * (point.x - c.x) + (c.x - b.x) * (point.y - c.z)) / denominator
	var weight_b := ((c.z - a.z) * (point.x - c.x) + (a.x - c.x) * (point.y - c.z)) / denominator
	var weight_c := 1.0 - weight_a - weight_b
	if weight_a < -0.0000001 or weight_b < -0.0000001 or weight_c < -0.0000001:
		return {"ok": false}
	return {"ok": true, "elevation_m": weight_a * a.y + weight_b * b.y + weight_c * c.y}


static func _minimum_plan_distance_to_records(point: Vector2, records: Array[Dictionary]) -> float:
	var minimum := INF
	for record: Dictionary in records:
		var indices: Array = record.indices
		var vertices: Array = record.vertices
		for offset in range(0, indices.size(), 3):
			var triangle: Array[Vector2] = []
			for index_offset in 3:
				var vertex_index := int(indices[offset + index_offset])
				triangle.append(Vector2(float(vertices[vertex_index * 3]), float(vertices[vertex_index * 3 + 2])))
			if _point_in_triangle_2d(point, triangle):
				return 0.0
			for edge_index in 3:
				minimum = minf(minimum, _point_to_segment_distance_2d(point, triangle[edge_index], triangle[(edge_index + 1) % 3]))
	return minimum


static func _point_in_triangle_2d(point: Vector2, triangle: Array[Vector2]) -> bool:
	var signs: Array[float] = []
	for index in 3:
		var left := triangle[index]
		var right := triangle[(index + 1) % 3]
		signs.append((point.x - right.x) * (left.y - right.y) - (left.x - right.x) * (point.y - right.y))
	var has_negative := false
	var has_positive := false
	for sign_value: float in signs:
		has_negative = has_negative or sign_value < -0.0000001
		has_positive = has_positive or sign_value > 0.0000001
	return not (has_negative and has_positive)


static func _point_to_segment_distance_2d(point: Vector2, start: Vector2, end: Vector2) -> float:
	var delta := end - start
	var length_squared := delta.length_squared()
	if length_squared <= 0.0:
		return point.distance_to(start)
	var fraction := clampf((point - start).dot(delta) / length_squared, 0.0, 1.0)
	return point.distance_to(start + delta * fraction)


static func _read_and_validate_coverage(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _failure("coverage_open", "Could not open coverage ledger: %s" % path)
	var headers := Array(file.get_csv_line(","))
	if headers != COVERAGE_HEADERS:
		return _failure("coverage_schema", "Coverage ledger headers do not match the runtime contract.")
	var rows: Array = []
	var source_scopes: Dictionary = {}
	var membership_counts: Dictionary = {}
	for key_value: Variant in EXPECTED_MEMBERSHIPS.keys():
		membership_counts[str(key_value)] = 0
	var context_keys: Array[String] = []
	var multi_category_keys: Array[String] = []
	var derived_groups: Dictionary = {}
	var derived_group_composites: Dictionary = {}
	var derived_group_rows: Dictionary = {}
	var building_rules := {"osm_height": 0, "osm_levels": 0, "default_6m": 0}
	var part_rules := {"osm_height": 0, "osm_levels": 0, "default_6m": 0}
	while not file.eof_reached():
		var cells := Array(file.get_csv_line(","))
		if cells.size() == 1 and str(cells[0]).is_empty() and file.eof_reached():
			break
		if cells.size() != COVERAGE_HEADERS.size():
			return _failure("coverage_row", "Coverage row %d has %d cells; expected %d." % [rows.size() + 2, cells.size(), COVERAGE_HEADERS.size()])
		var row: Dictionary = {}
		for index in COVERAGE_HEADERS.size():
			row[COVERAGE_HEADERS[index]] = str(cells[index])
		var source_key := str(row.source_key)
		if source_key.is_empty() or source_scopes.has(source_key):
			return _failure("coverage_duplicate", "Coverage source key is empty or duplicated: %s" % source_key, [source_key])
		if not _source_identity_matches(row):
			return _failure("coverage_identity", "Coverage OSM identity is inconsistent for %s." % source_key, [source_key])
		if not str(row.source_version).is_valid_int() or int(row.source_version) <= 0:
			return _failure("coverage_version", "Coverage source version is invalid for %s." % source_key, [source_key])
		var scope := str(row.scope)
		if scope != "playable" and scope != "context":
			return _failure("coverage_scope", "Invalid coverage scope for %s." % source_key, [source_key])
		var status := str(row.derived_world_status)
		if scope == "playable" and status != "represented" and status != "composite_member":
			return _failure("coverage_unresolved", "Playable source %s is not represented." % source_key, [source_key])
		if scope == "context":
			var expected_context_status := "context" if source_key == "w26767311" else "composite_member"
			if status != expected_context_status:
				return _failure("coverage_context_status", "Context source %s has incorrect direct/composite status." % source_key, [source_key])
		if status == "composite_member" and str(row.composite_key).is_empty():
			return _failure("coverage_composite", "Composite member %s has no composite key." % source_key, [source_key])
		var representation_kind := str(row.representation_kind)
		if representation_kind != "direct" and representation_kind != "composite":
			return _failure("coverage_representation", "Coverage row %s has an unknown representation kind." % source_key, [source_key])
		if (status == "composite_member") != (representation_kind == "composite"):
			return _failure("coverage_representation", "Coverage status and representation kind disagree for %s." % source_key, [source_key])
		if str(row.validation) != "pass" or str(row.derived_object_key).is_empty() or str(row.part_keys).is_empty():
			return _failure("coverage_validation", "Coverage row %s is incomplete or failed." % source_key, [source_key])
		if not str(row.vertex_count).is_valid_int() or not str(row.triangle_count).is_valid_int() or not str(row.collision_triangle_count).is_valid_int():
			return _failure("coverage_geometry_counts", "Coverage geometry counts are invalid for %s." % source_key, [source_key])
		if int(row.vertex_count) <= 0 or int(row.triangle_count) <= 0:
			return _failure("coverage_empty_geometry", "Coverage geometry is empty for %s." % source_key, [source_key])
		var categories := _split_semicolon(str(row.categories))
		if categories.is_empty():
			return _failure("coverage_categories", "Coverage row %s has no category." % source_key, [source_key])
		if categories != _sorted_unique_strings(categories):
			return _failure("coverage_categories", "Coverage categories must be unique and sorted for %s." % source_key, [source_key])
		for category: String in categories:
			if scope == "context":
				if category != "context_island" and category != "context_bridge":
					return _failure("coverage_categories", "Context row %s has unknown category %s." % [source_key, category], [source_key])
			elif not membership_counts.has(category):
				return _failure("coverage_categories", "Coverage row %s has unknown category %s." % [source_key, category], [source_key])
			else:
				membership_counts[category] += 1
		if scope == "playable" and categories.size() == 2:
			multi_category_keys.append(source_key)
		elif scope == "playable" and categories.size() > 2:
			return _failure("coverage_categories", "Playable source %s has more than two categories." % source_key, [source_key])
		var rule_result := _count_dimension_rule(row, categories, building_rules, part_rules)
		if not rule_result.ok:
			return rule_result
		if scope == "context":
			context_keys.append(source_key)
		elif str(row.chunk_ids).is_empty() and not BOUNDARY_ATTACHED_SOURCE_KEYS.has(source_key):
			return _failure("coverage_chunks", "Playable row %s has no chunk reference." % source_key, [source_key])
		if BOUNDARY_ATTACHED_SOURCE_KEYS.has(source_key):
			var expected_boundary_object := str(BOUNDARY_ATTACHED_OBJECTS[source_key].object_key)
			if status != "composite_member" or str(row.derived_object_key) != expected_boundary_object \
			or str(row.part_keys) != expected_boundary_object or not str(row.chunk_ids).is_empty() \
			or str(row.composite_key) != expected_boundary_object:
				return _failure("coverage_boundary_visual", "Boundary-attached source %s does not use its exact approved context composite." % source_key, [source_key])
		var derived_key := str(row.derived_object_key)
		if not derived_groups.has(derived_key):
			derived_groups[derived_key] = []
			derived_group_composites[derived_key] = []
			derived_group_rows[derived_key] = []
		derived_groups[derived_key].append(source_key)
		derived_group_composites[derived_key].append(str(row.composite_key))
		derived_group_rows[derived_key].append(row)
		source_scopes[source_key] = scope
		rows.append(row)
	file.close()
	if rows.size() != EXPECTED_SOURCE_ROWS:
		return _failure("coverage_count", "Coverage ledger must contain exactly 739 rows.")
	var playable_count := 0
	for scope_value: Variant in source_scopes.values():
		if scope_value == "playable":
			playable_count += 1
	if playable_count != EXPECTED_PLAYABLE_ROWS or context_keys.size() != EXPECTED_CONTEXT_ROWS:
		return _failure("coverage_count", "Coverage ledger must contain 735 playable and 4 context rows.")
	context_keys.sort()
	if context_keys != CONTEXT_SOURCE_KEYS:
		return _failure("coverage_context_keys", "Coverage context anchors do not match the exact four-source contract.", context_keys)
	for category_value: Variant in EXPECTED_MEMBERSHIPS.keys():
		var category := str(category_value)
		if int(membership_counts[category]) != int(EXPECTED_MEMBERSHIPS[category]):
			return _failure("coverage_memberships", "Coverage membership count differs for %s." % category)
	multi_category_keys.sort()
	if multi_category_keys != EXPECTED_MULTI_CATEGORY_KEYS:
		return _failure("coverage_overlap", "Coverage does not preserve the exact ten multi-category source rows.", multi_category_keys)
	if building_rules != {"osm_height": 176, "osm_levels": 10, "default_6m": 27}:
		return _failure("coverage_building_dimensions", "Building dimension rules must total 176 source heights, 10 level defaults, and 27 six-meter defaults.")
	if part_rules != {"osm_height": 1, "osm_levels": 1, "default_6m": 0}:
		return _failure("coverage_part_dimensions", "Building-part dimension rules must total one source height and one level default.")
	var approved_composite_sources: Dictionary = {}
	for derived_value: Variant in derived_groups.keys():
		var derived_key := str(derived_value)
		var group: Array = derived_groups[derived_key]
		if group.size() > 1:
			if not _is_approved_shared_group(group):
				return _failure("coverage_composite", "An undocumented group shares one derived object.", group)
			var composite_keys := _sorted_unique_strings(derived_group_composites[derived_key])
			if composite_keys.size() != 1 or str(composite_keys[0]) != derived_key:
				return _failure("coverage_composite", "Shared derived object %s lacks one common composite declaration." % derived_key, group)
			var group_rows: Array = derived_group_rows[derived_key]
			var first_row: Dictionary = group_rows[0]
			var shared_signature := [
				str(first_row.part_keys), str(first_row.chunk_ids), str(first_row.vertex_count),
				str(first_row.triangle_count), str(first_row.collision_triangle_count),
			]
			for group_row_value: Variant in group_rows:
				var group_row: Dictionary = group_row_value
				var row_signature := [
					str(group_row.part_keys), str(group_row.chunk_ids), str(group_row.vertex_count),
					str(group_row.triangle_count), str(group_row.collision_triangle_count),
				]
				if row_signature != shared_signature:
					return _failure("coverage_composite", "Composite members do not declare identical parts, chunks, and geometry counts for %s." % derived_key, group)
				approved_composite_sources[str(group_row.source_key)] = true
			if derived_key == ISLE_HOUSE_COMPOSITE_KEY and _split_semicolon(str(first_row.part_keys)) != ISLE_HOUSE_COMPOSITE_PART_KEYS:
				return _failure("coverage_composite", "Isle House composite does not declare its exact four approved part records.", group)
	for boundary_source_key: String in BOUNDARY_ATTACHED_SOURCE_KEYS:
		approved_composite_sources[boundary_source_key] = true
	return {
		"ok": true,
		"rows": rows,
		"source_scopes": source_scopes,
		"approved_composite_sources": approved_composite_sources,
	}


static func _validate_chunk(chunk: Dictionary, expected_chunk_id: String, source_scopes: Dictionary, record_keys: Dictionary, represented_playable: Dictionary, material_keys: Array, declared_feature_kinds: Array, boundary: Dictionary) -> Dictionary:
	if not _has_exact_fields(chunk, CHUNK_FIELDS):
		return _failure("chunk_schema", "Chunk %s has missing or unknown top-level fields." % expected_chunk_id)
	if str(chunk.get("schema_version", "")) != CHUNK_SCHEMA or str(chunk.get("chunk_id", "")) != expected_chunk_id:
		return _failure("chunk_schema", "Chunk schema or ID mismatch for %s." % expected_chunk_id)
	if not _valid_chunk_id(expected_chunk_id):
		return _failure("chunk_id", "Invalid deterministic chunk ID: %s" % expected_chunk_id)
	if not chunk.get("records", null) is Array:
		return _failure("chunk_records", "Chunk %s has no record array." % expected_chunk_id)
	if chunk.records.is_empty():
		return _failure("chunk_records", "Chunk %s is empty and must not be indexed." % expected_chunk_id)
	if not chunk.get("bounds_m", null) is Dictionary or not _has_exact_fields(chunk.bounds_m, CHUNK_BOUNDS_FIELDS):
		return _failure("chunk_bounds", "Chunk %s has no bounds." % expected_chunk_id)
	var bounds_result := _validate_chunk_bounds(expected_chunk_id, chunk.bounds_m)
	if not bounds_result.ok:
		return bounds_result
	var prior_object_key := ""
	for record_value: Variant in chunk.records:
		if not record_value is Dictionary:
			return _failure("chunk_record", "Chunk %s contains a non-object record." % expected_chunk_id)
		var expected_record_fields := MESH_RECORD_FIELDS.duplicate()
		var feature_kind := str(record_value.get("feature_kind", ""))
		if feature_kind in ["road_path", "major_area", "terrain_overlay"]:
			expected_record_fields.append_array(SURFACE_RECORD_FIELDS)
		if feature_kind in ["building_roof", "building_part_roof", "building_wall", "building_part_wall"]:
			expected_record_fields.append_array(BUILDING_LEVEL_FIELDS)
		if feature_kind in ["building_wall", "building_part_wall"]:
			expected_record_fields.append_array(BUILDING_WALL_FIELDS)
		if not _has_exact_fields(record_value, expected_record_fields):
			return _failure("record_schema", "Chunk %s contains a record with missing or unknown fields." % expected_chunk_id)
		var result := _validate_mesh_record(record_value, declared_feature_kinds, source_scopes, "playable", expected_chunk_id, record_keys, material_keys)
		if not result.ok:
			return result
		var object_key := str(record_value.object_key)
		if not prior_object_key.is_empty() and object_key < prior_object_key:
			return _failure("chunk_record_order", "Chunk %s records are not sorted by object key." % expected_chunk_id)
		prior_object_key = object_key
		for key_value: Variant in record_value.source_keys:
			var source_key := str(key_value)
			if BOUNDARY_ATTACHED_SOURCE_KEYS.has(source_key):
				return _failure("boundary_visual_in_chunk", "Boundary-attached visual source %s must not create playable chunk geometry." % source_key, [source_key])
			represented_playable[source_key] = true
		for vertex_index in range(0, record_value.vertices.size(), 3):
			var point := Vector2(float(record_value.vertices[vertex_index]), float(record_value.vertices[vertex_index + 2]))
			if not contains_xz(boundary, point):
				return _failure("playable_vertex_outside_boundary", "Chunk record %s has geometry outside the exact playable boundary." % str(record_value.object_key), record_value.source_keys)
	return {"ok": true}


static func _validate_context(context: Dictionary, source_scopes: Dictionary, record_keys: Dictionary, represented_context: Dictionary, represented_playable: Dictionary, material_keys: Array) -> Dictionary:
	if not _has_exact_fields(context, CONTEXT_FIELDS) \
	or str(context.get("schema_version", "")) != CONTEXT_SCHEMA \
	or not context.get("records", null) is Array \
	or not context.get("boundary_attached_visuals", null) is Array:
		return _failure("context_schema", "Context file schema is invalid.")
	if context.records.size() != 2:
		return _failure("context_count", "Context must contain exactly one YBI and one Bay Bridge record.")
	var kinds_seen: Dictionary = {}
	var prior_main_object_key := ""
	for record_value: Variant in context.records:
		if not record_value is Dictionary:
			return _failure("context_record", "Context contains a non-object record.")
		var record: Dictionary = record_value
		if not _has_exact_fields(record, CONTEXT_RECORD_FIELDS):
			return _failure("context_record", "Context record has missing or unknown fields.")
		var adapted := record.duplicate(true)
		adapted["feature_kind"] = str(record.get("context_kind", ""))
		var result := _validate_mesh_record(adapted, CONTEXT_KINDS, source_scopes, "context", "context", record_keys, material_keys)
		if not result.ok:
			return result
		var main_object_key := str(record.object_key)
		if not prior_main_object_key.is_empty() and main_object_key < prior_main_object_key:
			return _failure("context_order", "Context records must be sorted by object key.")
		prior_main_object_key = main_object_key
		if str(record.get("collision_kind", "")) != "none" or str(record.get("receiver_kind", "")) != "none" or bool(record.get("opaque", true)):
			return _failure("context_isolation", "Context record %s has gameplay collision or receiver semantics." % str(record.get("object_key", "")))
		if str(record.context_kind) == "ybi":
			var minimum_elevation := INF
			var maximum_elevation := -INF
			for vertex_index in range(1, record.vertices.size(), 3):
				var elevation := float(record.vertices[vertex_index])
				minimum_elevation = minf(minimum_elevation, elevation)
				maximum_elevation = maxf(maximum_elevation, elevation)
			if not is_equal_approx(minimum_elevation, 0.0) or maximum_elevation < 100.0:
				return _failure("context_terrain", "YBI must retain USGS high ground and shoreline sides meeting the waterline.", record.source_keys)
		elif str(record.get("material_key", "")) != "context_bay_bridge":
			return _failure("context_bridge_material", "Bay Bridge context material key drifted.", record.source_keys)
		var expected_sources := ["w26767311"] if str(record.context_kind) == "ybi" else ["r13543937", "r13543938", "w1011568818"]
		if record.source_keys != expected_sources:
			return _failure("context_sources", "Context record %s has incorrect anchor ownership." % str(record.object_key), record.source_keys)
		kinds_seen[str(record.context_kind)] = true
		for key_value: Variant in record.source_keys:
			represented_context[str(key_value)] = true
	if not kinds_seen.has("ybi") or not kinds_seen.has("bay_bridge"):
		return _failure("context_completeness", "Context must contain both YBI and Bay Bridge geometry.")
	var context_keys := _sorted_strings(represented_context.keys())
	if context_keys != CONTEXT_SOURCE_KEYS:
		return _failure("context_sources", "Context geometry must resolve exactly the four context anchors.", context_keys)
	if context.boundary_attached_visuals.size() != BOUNDARY_ATTACHED_SOURCE_KEYS.size():
		return _failure("boundary_visual_count", "Context must contain exactly two approved boundary-attached visuals.")
	var prior_object_key := ""
	var boundary_keys_seen: Array[String] = []
	for record_value: Variant in context.boundary_attached_visuals:
		if not record_value is Dictionary:
			return _failure("boundary_visual_record", "Boundary-attached visual is not an object.")
		var record: Dictionary = record_value
		if not _has_exact_fields(record, CONTEXT_RECORD_FIELDS):
			return _failure("boundary_visual_record", "Boundary-attached visual has missing or unknown fields.")
		if not record.get("source_keys", null) is Array or record.source_keys.size() != 1:
			return _failure("boundary_visual_source", "Boundary-attached visual must claim exactly one approved source.")
		var source_key := str(record.source_keys[0])
		if not BOUNDARY_ATTACHED_OBJECTS.has(source_key):
			return _failure("boundary_visual_source", "Unapproved out-of-bound playable source %s." % source_key, [source_key])
		var expected: Dictionary = BOUNDARY_ATTACHED_OBJECTS[source_key]
		var object_key := str(record.get("object_key", ""))
		if object_key != str(expected.object_key) or str(record.get("material_key", "")) != str(expected.material_key) \
		or str(record.get("context_kind", "")) != "boundary_attached_visual" \
		or str(record.get("collision_kind", "")) != "none" \
		or str(record.get("receiver_kind", "")) != "none" or bool(record.get("opaque", true)):
			return _failure("boundary_visual_contract", "Boundary-attached visual %s violates its exact non-playable contract." % source_key, [source_key])
		if not prior_object_key.is_empty() and object_key < prior_object_key:
			return _failure("boundary_visual_order", "Boundary-attached visuals must be sorted by object key.")
		prior_object_key = object_key
		var adapted := record.duplicate(true)
		adapted["feature_kind"] = "boundary_attached_visual"
		var result := _validate_mesh_record(adapted, ["boundary_attached_visual"], source_scopes, "playable", "boundary_context", record_keys, material_keys)
		if not result.ok:
			return result
		boundary_keys_seen.append(source_key)
		represented_playable[source_key] = true
	boundary_keys_seen.sort()
	if boundary_keys_seen != BOUNDARY_ATTACHED_SOURCE_KEYS:
		return _failure("boundary_visual_sources", "Boundary-attached visuals do not resolve the exact two approved playable sources.", boundary_keys_seen)
	return {"ok": true}


static func _validate_mesh_record(record: Dictionary, allowed_kinds: Array, source_scopes: Dictionary, expected_scope: String, owner_id: String, record_keys: Dictionary, material_keys: Array) -> Dictionary:
	for field: String in ["object_key", "feature_kind", "source_keys", "material_key", "vertices", "normals", "uvs", "indices", "collision_kind", "receiver_kind", "opaque"]:
		if not record.has(field):
			return _failure("record_schema", "Mesh record in %s is missing required field %s." % [owner_id, field])
	var object_key := str(record.get("object_key", ""))
	var feature_kind := str(record.get("feature_kind", ""))
	if object_key.is_empty() or record_keys.has(object_key):
		return _failure("record_key", "Mesh record key is empty or duplicated: %s" % object_key)
	if not allowed_kinds.has(feature_kind):
		return _failure("feature_kind", "Unknown feature kind %s in %s." % [feature_kind, owner_id])
	if str(record.get("material_key", "")).is_empty() or not material_keys.has(str(record.get("material_key", ""))):
		return _failure("material_key", "Record %s has no material key." % object_key)
	if not record.get("source_keys", null) is Array or record.source_keys.is_empty():
		return _failure("record_sources", "Record %s has no source keys." % object_key)
	if _sorted_unique_strings(record.source_keys) != record.source_keys:
		return _failure("record_sources", "Record %s source keys must be unique and sorted." % object_key)
	for key_value: Variant in record.source_keys:
		var key := str(key_value)
		if not source_scopes.has(key) or str(source_scopes[key]) != expected_scope:
			return _failure("record_sources", "Record %s references an unknown or wrong-scope source %s." % [object_key, key], [key])
	var vertices: Array = record.get("vertices", [])
	var normals: Array = record.get("normals", [])
	var uvs: Array = record.get("uvs", [])
	var indices: Array = record.get("indices", [])
	if not record.opaque is bool:
		return _failure("record_schema", "Record %s opaque field is not boolean." % object_key)
	if vertices.size() < 9 or vertices.size() % 3 != 0 or normals.size() != vertices.size() or indices.size() < 3 or indices.size() % 3 != 0:
		return _failure("record_mesh", "Record %s has inconsistent vertex, normal, or index arrays." % object_key)
	var vertex_count := int(vertices.size() / 3)
	if not uvs.is_empty() and uvs.size() != vertex_count * 2:
		return _failure("record_uv", "Record %s has an invalid UV array." % object_key)
	for value: Variant in vertices:
		if not _is_finite_number(value):
			return _failure("record_numeric", "Record %s has a non-finite vertex." % object_key)
	for value: Variant in normals:
		if not _is_finite_number(value):
			return _failure("record_numeric", "Record %s has a non-finite normal." % object_key)
	for value: Variant in uvs:
		if not _is_finite_number(value):
			return _failure("record_numeric", "Record %s has a non-finite UV." % object_key)
	for index_value: Variant in indices:
		# Godot's JSON parser represents JSON numbers as floats, including serialized
		# integer indices. Require exact integral value and the same vertex range.
		if not _is_finite_number(index_value):
			return _failure("record_index", "Record %s has a non-numeric index." % object_key)
		var numeric_index := float(index_value)
		if numeric_index != floorf(numeric_index):
			return _failure("record_index", "Record %s has a non-integral index." % object_key)
		if numeric_index < 0.0 or numeric_index >= float(vertex_count):
			return _failure("record_index", "Record %s has an out-of-range index." % object_key)
	for triangle_index in range(0, indices.size(), 3):
		var a := _vertex_at(vertices, int(indices[triangle_index]))
		var b := _vertex_at(vertices, int(indices[triangle_index + 1]))
		var c := _vertex_at(vertices, int(indices[triangle_index + 2]))
		var triangle_area_m2 := (b - a).cross(c - a).length() * 0.5
		if not _is_finite_number(triangle_area_m2) or triangle_area_m2 <= MIN_TRIANGLE_AREA_M2:
			return _failure("record_triangle", "Record %s contains a degenerate triangle." % object_key)
	var collision_kind := str(record.get("collision_kind", ""))
	var receiver_kind := str(record.get("receiver_kind", ""))
	if collision_kind != "none" and collision_kind != "world_solid":
		return _failure("record_collision", "Record %s has an unknown collision kind." % object_key)
	if receiver_kind != "none" and receiver_kind != "building_wall":
		return _failure("record_receiver", "Record %s has an unknown receiver kind." % object_key)
	if receiver_kind == "building_wall":
		if collision_kind != "world_solid" or not bool(record.get("opaque", false)) or (feature_kind != "building_wall" and feature_kind != "building_part_wall"):
			return _failure("record_receiver", "Record %s violates the opaque building-wall receiver contract." % object_key)
	if expected_scope == "playable":
		if feature_kind in ["road_path", "major_area", "terrain_overlay"] \
		and not _is_finite_number(record.get("surface_bias_m", null)):
			return _failure("surface_conformance", "Record %s has no finite coherent-surface bias." % object_key)
		if feature_kind == "road_path":
			var road_material := str(record.get("material_key", ""))
			var road_bias := float(record.get("surface_bias_m", INF))
			if road_material == "road_path":
				if not is_equal_approx(road_bias, ROAD_BASE_SURFACE_BIAS_M) or not object_key.begins_with("roads:"):
					return _failure("pavement_skin", "Record %s violates the continuous vehicle-road base contract." % object_key)
			elif road_material == "road_path_pedestrian":
				if not is_equal_approx(road_bias, ROAD_PEDESTRIAN_SURFACE_BIAS_M) or not object_key.begins_with("roads-pedestrian:"):
					return _failure("pavement_skin", "Record %s violates the raised pedestrian-skin contract." % object_key)
			else:
				return _failure("pavement_skin", "Record %s has an unknown pavement material." % object_key)
		if str(record.get("material_key", "")) == "major_area_paved" and feature_kind != "major_area":
			return _failure("pavement_skin", "Record %s applies paved-area material outside a major area." % object_key)
		if feature_kind in ["building_roof", "building_part_roof", "building_wall", "building_part_wall"]:
			for level_field: String in BUILDING_LEVEL_FIELDS:
				if not _is_finite_number(record.get(level_field, null)):
					return _failure("building_levels", "Record %s has no finite %s." % [object_key, level_field])
			if absf(float(record.top_elevation_m) - float(record.flat_base_elevation_m) - float(record.source_height_m)) > BOUNDARY_TOLERANCE_M:
				return _failure("building_levels", "Record %s changed its flat base, roof, or source height." % object_key)
		if feature_kind in ["building_wall", "building_part_wall"]:
			if not _is_nonnegative_json_integer(record.get("exterior_foundation_segments", null)) \
			or not _is_nonnegative_json_integer(record.get("shared_wall_segments", null)):
				return _failure("building_foundations", "Record %s has invalid foundation/shared-wall counts." % object_key)
		var must_collide := feature_kind in ["land_ground", "building_wall", "building_roof", "building_part_wall", "building_part_roof", "boundary_blocker"]
		if must_collide != (collision_kind == "world_solid"):
			return _failure("record_collision", "Record %s collision semantics do not match its feature kind." % object_key)
		var must_receive := feature_kind == "building_wall" or feature_kind == "building_part_wall"
		if must_receive != (receiver_kind == "building_wall"):
			return _failure("record_receiver", "Record %s receiver semantics do not match its feature kind." % object_key)
		if collision_kind == "world_solid" and feature_kind != "boundary_blocker" and not bool(record.get("opaque", false)):
			return _failure("record_opacity", "Record %s must occlude the first-hit spray ray." % object_key)
	record_keys[object_key] = {
		"owner_id": owner_id,
		"vertex_count": vertex_count,
		"triangle_count": indices.size() / 3,
		"collision_triangle_count": indices.size() / 3 if collision_kind == "world_solid" else 0,
	}
	return {"ok": true}


static func _validate_coverage_references(rows: Array, record_keys: Dictionary, represented_playable: Dictionary, represented_context: Dictionary, approved_composite_sources: Dictionary) -> Dictionary:
	for row_value: Variant in rows:
		var row: Dictionary = row_value
		var source_key := str(row.source_key)
		var parts := _split_semicolon(str(row.part_keys))
		var chunks := _split_semicolon(str(row.chunk_ids))
		if parts != _sorted_unique_strings(parts) or chunks != _sorted_unique_chunk_ids(chunks):
			return _failure("coverage_reference_order", "Coverage part/chunk references are not sorted for %s." % source_key, [source_key])
		var referenced_chunks: Dictionary = {}
		var referenced_vertex_count := 0
		var referenced_triangle_count := 0
		var referenced_collision_triangle_count := 0
		for part: String in parts:
			if not record_keys.has(part):
				return _failure("coverage_part_reference", "Coverage source %s references missing part %s." % [source_key, part], [source_key])
			var record_info: Dictionary = record_keys[part]
			referenced_chunks[str(record_info.owner_id)] = true
			referenced_vertex_count += int(record_info.vertex_count)
			referenced_triangle_count += int(record_info.triangle_count)
			referenced_collision_triangle_count += int(record_info.collision_triangle_count)
		if referenced_vertex_count != int(row.vertex_count) \
		or referenced_triangle_count != int(row.triangle_count) \
		or referenced_collision_triangle_count != int(row.collision_triangle_count):
			return _failure("coverage_geometry_counts", "Coverage geometry counts disagree with referenced parts for %s." % source_key, [source_key])
		var scope := str(row.scope)
		if scope == "playable" and BOUNDARY_ATTACHED_SOURCE_KEYS.has(source_key):
			if _sorted_strings(referenced_chunks.keys()) != ["boundary_context"] or not chunks.is_empty():
				return _failure("coverage_boundary_reference", "Boundary-attached source %s has invalid part/chunk references." % source_key, [source_key])
		elif scope == "playable" and _sorted_chunk_ids(_string_array(referenced_chunks.keys())) != chunks:
			return _failure("coverage_chunk_reference", "Coverage source %s part/chunk references disagree." % source_key, [source_key])
		if scope == "context" and (_sorted_strings(referenced_chunks.keys()) != ["context"] or not chunks.is_empty()):
			return _failure("coverage_context_reference", "Context source %s has invalid part/chunk references." % source_key, [source_key])
		var status := str(row.derived_world_status)
		if scope == "playable" and not represented_playable.has(source_key):
			if status == "composite_member" and approved_composite_sources.has(source_key):
				represented_playable[source_key] = true
			else:
				return _failure("coverage_source_reference", "No playable record claims source %s." % source_key, [source_key])
		if scope == "context" and not represented_context.has(source_key):
			if status == "composite_member" and approved_composite_sources.has(source_key):
				represented_context[source_key] = true
			else:
				return _failure("coverage_source_reference", "No context record claims source %s." % source_key, [source_key])
	return {"ok": true}


static func validate_boundary(boundary: Dictionary) -> Dictionary:
	if not boundary.get("components", null) is Array or boundary.components.is_empty():
		return _failure("boundary_geometry", "Playable boundary has no polygon components.")
	for component_value: Variant in boundary.components:
		if not component_value is Dictionary:
			return _failure("boundary_geometry", "Playable boundary component is invalid.")
		var component: Dictionary = component_value
		if not _valid_ring(component.get("outer", [])):
			return _failure("boundary_geometry", "Playable boundary outer ring is invalid.")
		if absf(_ring_signed_area(component.outer)) <= 0.001:
			return _failure("boundary_geometry", "Playable boundary outer ring has zero area.")
		if not component.get("holes", []) is Array:
			return _failure("boundary_geometry", "Playable boundary holes are invalid.")
		for hole_value: Variant in component.get("holes", []):
			if not _valid_ring(hole_value):
				return _failure("boundary_geometry", "Playable boundary hole is invalid.")
			if absf(_ring_signed_area(hole_value)) <= 0.001:
				return _failure("boundary_geometry", "Playable boundary hole has zero area.")
	return {"ok": true}


static func contains_xz(boundary: Dictionary, point: Vector2) -> bool:
	for component_value: Variant in boundary.get("components", []):
		var component: Dictionary = component_value
		if not _point_in_ring(point, component.get("outer", [])):
			continue
		var inside_hole := false
		for hole_value: Variant in component.get("holes", []):
			if _point_in_ring(point, hole_value):
				inside_hole = true
				break
		if not inside_hole:
			return true
	return false


static func _spawn_transform(spawn: Dictionary, boundary: Dictionary) -> Dictionary:
	var origin_values: Array = spawn.get("origin", [])
	if origin_values.size() != 3 or not _is_finite_number(origin_values[0]) or not _is_finite_number(origin_values[1]) or not _is_finite_number(origin_values[2]):
		return _failure("spawn_transform", "Initial spawn origin is invalid.")
	var yaw_value: Variant = spawn.get("yaw", 0.0)
	if not _is_finite_number(yaw_value):
		return _failure("spawn_transform", "Initial spawn yaw is invalid.")
	var origin := Vector3(float(origin_values[0]), float(origin_values[1]), float(origin_values[2]))
	if not contains_xz(boundary, Vector2(origin.x, origin.z)):
		return _failure("spawn_boundary", "Initial spawn lies outside the playable boundary.")
	return {"ok": true, "transform": Transform3D(Basis(Vector3.UP, float(yaw_value)), origin)}


static func _valid_ring(value: Variant) -> bool:
	if not value is Array or value.size() < 3:
		return false
	var seen: Dictionary = {}
	var previous := Vector2(INF, INF)
	for point_value: Variant in value:
		if not point_value is Array or point_value.size() != 2 or not _is_finite_number(point_value[0]) or not _is_finite_number(point_value[1]):
			return false
		var point := Vector2(float(point_value[0]), float(point_value[1]))
		if point == previous:
			return false
		seen["%.3f,%.3f" % [point.x, point.y]] = true
		previous = point
	var first: Array = value[0]
	var last: Array = value[value.size() - 1]
	if Vector2(float(first[0]), float(first[1])) == Vector2(float(last[0]), float(last[1])):
		return false
	if seen.size() < 3:
		return false
	return true


static func _point_in_ring(point: Vector2, ring: Array) -> bool:
	var inside := false
	var j := ring.size() - 1
	for i in ring.size():
		var a: Array = ring[i]
		var b: Array = ring[j]
		var ax := float(a[0])
		var az := float(a[1])
		var bx := float(b[0])
		var bz := float(b[1])
		if _point_on_segment(point, Vector2(ax, az), Vector2(bx, bz)):
			return true
		if ((az > point.y) != (bz > point.y)) and point.x < (bx - ax) * (point.y - az) / (bz - az) + ax:
			inside = not inside
		j = i
	return inside


static func _point_on_segment(point: Vector2, a: Vector2, b: Vector2) -> bool:
	var segment := b - a
	var segment_length := segment.length()
	if segment_length <= 0.0:
		return point.distance_to(a) <= BOUNDARY_TOLERANCE_M
	var cross := segment.cross(point - a)
	if absf(cross) / segment_length > BOUNDARY_TOLERANCE_M:
		return false
	var dot := (point - a).dot(segment)
	var endpoint_tolerance := BOUNDARY_TOLERANCE_M * segment_length
	return dot >= -endpoint_tolerance and dot <= segment.length_squared() + endpoint_tolerance


static func _ring_signed_area(ring: Array) -> float:
	var area := 0.0
	var previous := ring.size() - 1
	for index in ring.size():
		var a: Array = ring[previous]
		var b: Array = ring[index]
		area += float(a[0]) * float(b[1]) - float(b[0]) * float(a[1])
		previous = index
	return area * 0.5


static func _read_json_object(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _failure("file_open", "Could not open required JSON: %s" % path)
	var parser := JSON.new()
	var error := parser.parse(file.get_as_text())
	file.close()
	if error != OK:
		return _failure("json_parse", "Invalid JSON in %s at line %d: %s" % [path, parser.get_error_line(), parser.get_error_message()])
	if not parser.data is Dictionary:
		return _failure("json_shape", "Required JSON root is not an object: %s" % path)
	return {"ok": true, "data": parser.data}


static func _validate_file(path: String, expected_sha256: String, expected_bytes: int) -> Dictionary:
	if path.is_empty() or not FileAccess.file_exists(path):
		return {"ok": false, "message": "Required file is missing."}
	if not _is_hex_sha256(expected_sha256) or FileAccess.get_sha256(path) != expected_sha256:
		return {"ok": false, "message": "SHA-256 mismatch."}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "message": "Required file cannot be read."}
	var actual_bytes := file.get_length()
	file.close()
	if expected_bytes < 0 or actual_bytes != expected_bytes:
		return {"ok": false, "message": "Byte length mismatch."}
	return {"ok": true}


static func _resolve_artifact_path(manifest_path: String, stored_path: String) -> String:
	if stored_path.is_empty() or stored_path.is_absolute_path() or stored_path.begins_with("res://") or stored_path.begins_with("user://"):
		return ""
	var clean := stored_path.simplify_path()
	if clean == ".." or clean.begins_with("../") or clean.contains("/../"):
		return ""
	if clean.begins_with("generated/world/"):
		return "res://%s" % clean
	var resolved := manifest_path.get_base_dir().path_join(clean).simplify_path()
	if not resolved.begins_with(manifest_path.get_base_dir().simplify_path() + "/"):
		return ""
	return resolved


static func _source_identity_matches(row: Dictionary) -> bool:
	var source_key := str(row.source_key)
	var osm_type := str(row.osm_type)
	var osm_id := str(row.osm_id)
	if not osm_id.is_valid_int() or int(osm_id) <= 0:
		return false
	if osm_type == "way":
		return source_key == "w%s" % osm_id
	if osm_type == "relation":
		return source_key == "r%s" % osm_id
	if osm_type == "node":
		return source_key == "n%s" % osm_id
	return false


static func _validate_coordinate_system(value: Variant) -> Dictionary:
	if not value is Dictionary:
		return _failure("coordinate_system", "Manifest coordinate system is missing.")
	var coordinates: Dictionary = value
	if str(coordinates.get("source_crs", "")) != "EPSG:4326" \
	or not is_equal_approx(float(coordinates.get("earth_radius_m", 0.0)), 6378137.0) \
	or not is_equal_approx(float(coordinates.get("origin_lon", 0.0)), -122.37099) \
	or not is_equal_approx(float(coordinates.get("origin_lat", 0.0)), 37.82376155) \
	or str(coordinates.get("world_axes", "")) != "+X east,+Y up,-Z north" \
	or not is_equal_approx(float(coordinates.get("meters_per_unit", 0.0)), 1.0) \
	or str(coordinates.get("ground_model", "")) != "USGS 3DEP bare-earth terrain" \
	or str(coordinates.get("vertical_datum", "")) != "NAVD 88" \
	or not is_equal_approx(float(coordinates.get("coordinate_rounding_m", 0.0)), 0.001):
		return _failure("coordinate_system", "Manifest coordinate/terrain transform differs from the approved one-meter Treasure Island contract.")
	return {"ok": true}


static func _count_dimension_rule(row: Dictionary, categories: Array[String], building_rules: Dictionary, part_rules: Dictionary) -> Dictionary:
	var is_building := categories.has("building")
	var is_part := categories.has("building_part")
	var dimension_rule := str(row.dimension_rule)
	var height_text := str(row.height_m)
	if not is_building and not is_part:
		if not dimension_rule.is_empty() or not height_text.is_empty():
			return _failure("coverage_dimensions", "Non-building source %s carries a building dimension." % str(row.source_key), [str(row.source_key)])
		return {"ok": true}
	if not building_rules.has(dimension_rule) or not height_text.is_valid_float() or float(height_text) <= 0.0:
		return _failure("coverage_dimensions", "Building source %s has an invalid height rule/value." % str(row.source_key), [str(row.source_key)])
	if is_building:
		building_rules[dimension_rule] += 1
	if is_part:
		part_rules[dimension_rule] += 1
	return {"ok": true}


static func _is_approved_shared_group(group: Array) -> bool:
	var sorted := _sorted_strings(group)
	var approved := [
		["w26767313", "w29399800"],
		["w1249412094", "w1282547786", "w1282547787"],
		["r13543937", "r13543938", "w1011568818"],
	]
	for candidate: Array in approved:
		if sorted == candidate:
			return true
	return false


static func _find_file_entry(files: Array, stored_path: String) -> Dictionary:
	for value: Variant in files:
		if value is Dictionary and str(value.get("path", "")) == stored_path:
			return value
	return {}


static func _split_semicolon(value: String) -> Array[String]:
	var result: Array[String] = []
	if value.is_empty():
		return result
	for part: String in value.split(";", false):
		result.append(part)
	return result


static func _sorted_strings(values: Array) -> Array:
	var result: Array = []
	for value: Variant in values:
		result.append(str(value))
	result.sort()
	return result


static func _string_array(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value: Variant in values:
		result.append(str(value))
	return result


static func _sorted_unique_strings(values: Array) -> Array:
	var result: Array = []
	var seen: Dictionary = {}
	for value: Variant in values:
		var string_value := str(value)
		if seen.has(string_value):
			continue
		seen[string_value] = true
		result.append(string_value)
	result.sort()
	return result


static func _valid_chunk_id(value: String) -> bool:
	if not value.begins_with("x_") or not value.contains("__z_"):
		return false
	var pieces := value.trim_prefix("x_").split("__z_", false)
	return pieces.size() == 2 and str(pieces[0]).is_valid_int() and str(pieces[1]).is_valid_int()


static func _compare_chunk_ids(left: String, right: String) -> int:
	var left_parts := left.trim_prefix("x_").split("__z_", false)
	var right_parts := right.trim_prefix("x_").split("__z_", false)
	var x_order := int(left_parts[0]) - int(right_parts[0])
	if x_order != 0:
		return x_order
	return int(left_parts[1]) - int(right_parts[1])


static func _sorted_chunk_ids(values: Array[String]) -> Array[String]:
	var result: Array[String] = values.duplicate()
	for left_index in result.size():
		var minimum_index := left_index
		for right_index in range(left_index + 1, result.size()):
			if _compare_chunk_ids(result[right_index], result[minimum_index]) < 0:
				minimum_index = right_index
		if minimum_index != left_index:
			var temporary := result[left_index]
			result[left_index] = result[minimum_index]
			result[minimum_index] = temporary
	return result


static func _sorted_unique_chunk_ids(values: Array[String]) -> Array[String]:
	var seen: Dictionary = {}
	for value: String in values:
		if not _valid_chunk_id(value) or seen.has(value):
			return []
		seen[value] = true
	return _sorted_chunk_ids(values)


static func _has_exact_fields(value: Dictionary, expected_fields: Array) -> bool:
	return _sorted_strings(value.keys()) == _sorted_strings(expected_fields)


static func _validate_chunk_bounds(chunk_id: String, bounds: Dictionary) -> Dictionary:
	var pieces := chunk_id.trim_prefix("x_").split("__z_", false)
	var chunk_x := int(pieces[0])
	var chunk_z := int(pieces[1])
	var expected_min_x := chunk_x * EXPECTED_CHUNK_SIZE_M
	var expected_min_z := chunk_z * EXPECTED_CHUNK_SIZE_M
	if not is_equal_approx(float(bounds.get("min_x", INF)), expected_min_x) \
	or not is_equal_approx(float(bounds.get("min_z", INF)), expected_min_z) \
	or not is_equal_approx(float(bounds.get("max_x", -INF)), expected_min_x + EXPECTED_CHUNK_SIZE_M) \
	or not is_equal_approx(float(bounds.get("max_z", -INF)), expected_min_z + EXPECTED_CHUNK_SIZE_M):
		return _failure("chunk_bounds", "Chunk %s bounds do not match the deterministic 256-meter grid." % chunk_id)
	return {"ok": true}


static func _vertex_at(vertices: Array, index: int) -> Vector3:
	var offset := index * 3
	return Vector3(float(vertices[offset]), float(vertices[offset + 1]), float(vertices[offset + 2]))


static func _is_finite_number(value: Variant) -> bool:
	if not value is int and not value is float:
		return false
	var number := float(value)
	return not is_nan(number) and not is_inf(number)


static func _is_nonnegative_json_integer(value: Variant) -> bool:
	if not _is_finite_number(value):
		return false
	var number := float(value)
	return number >= 0.0 and number == floorf(number)


static func _is_hex_sha256(value: String) -> bool:
	if value.length() != 64:
		return false
	for character in value:
		if not str(character).to_lower() in "0123456789abcdef":
			return false
	return value == value.to_lower()


static func _failure(code: String, message: String, source_keys: Array = []) -> Dictionary:
	return {"ok": false, "code": code, "message": message, "source_keys": source_keys}
