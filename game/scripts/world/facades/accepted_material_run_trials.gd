class_name AcceptedMaterialRunTrials
extends RefCounted

const RUN_VERTEX_VALUES := 12
const RUN_INDEX_VALUES := 6
const PLACEHOLDER_SURFACE_NAME := "placeholder_runs"
const ACCEPTED_SURFACE_NAME := "accepted_material_runs"

const TARGETS := {
	"building:w291189336:wall": {
		"source_key": "w291189336",
		"run_count": 34,
		"accepted_runs": [9, 10],
		"accepted_length_m": 16.362,
		"material_path": "res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres",
		"material": preload("res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres"),
		"limitation": "Warm-cream homogeneous albedo/roughness background only; substrate and relief remain blocked.",
	},
	"building:w291189926:wall": {
		"source_key": "w291189926",
		"run_count": 72,
		"accepted_runs": [0, 1, 2, 3, 4, 5],
		"accepted_length_m": 49.124,
		"material_path": "res://game/resources/materials/world/job_corps_dormitory_b369/dormitory_b369_warm_field.tres",
		"material": preload("res://game/resources/materials/world/job_corps_dormitory_b369/dormitory_b369_warm_field.tres"),
		"limitation": "Smooth warm-wall albedo/roughness only; five visible tiers versus fallback 6 m remains unresolved.",
	},
	"building:w34313547:wall": {
		"source_key": "w34313547",
		"run_count": 30,
		"accepted_runs": [3, 4, 5, 6, 7, 8, 9, 10, 11],
		"accepted_length_m": 101.046,
		"material_path": "res://game/resources/materials/world/ti_ymca/ti_ymca_primary.tres",
		"material": preload("res://game/resources/materials/world/ti_ymca/ti_ymca_primary.tres"),
		"limitation": "Dark exposed-aggregate homogeneous background only on the observed SSE and ENE chains; granular scale/substrate, openings, joints, entry, louver, door, mural, low wing, WSW/NNW, modules, and whole object remain blocked.",
	},
}

static func matches_record(record: Dictionary) -> bool:
	return TARGETS.has(str(record.get("object_key", "")))


static func partition(record: Dictionary, indices: PackedInt32Array, placeholder_material: Material) -> Dictionary:
	var object_key := str(record.get("object_key", ""))
	if not TARGETS.has(object_key):
		return {
			"ok": true,
			"surfaces": [{"name": "generated_record", "indices": indices, "material": placeholder_material}],
		}
	var target := TARGETS[object_key] as Dictionary
	var validation := _validate_target_record(record, indices, target)
	if not bool(validation.get("ok", false)):
		return validation
	var accepted_lookup := {}
	for run_value: Variant in target.accepted_runs:
		accepted_lookup[int(run_value)] = true
	var placeholder_indices := PackedInt32Array()
	var accepted_indices := PackedInt32Array()
	for run_index in int(target.run_count):
		var destination := accepted_indices if accepted_lookup.has(run_index) else placeholder_indices
		var offset := run_index * RUN_INDEX_VALUES
		for index_offset in RUN_INDEX_VALUES:
			destination.append(indices[offset + index_offset])
	return {
		"ok": true,
		"surfaces": [
			{"name": PLACEHOLDER_SURFACE_NAME, "indices": placeholder_indices, "material": placeholder_material},
			{"name": ACCEPTED_SURFACE_NAME, "indices": accepted_indices, "material": target.material},
		],
		"metadata": metadata_for(object_key),
	}


static func metadata_for(object_key: String) -> Dictionary:
	if TARGETS.has(object_key):
		var target := TARGETS[object_key] as Dictionary
		return {
			"source_key": str(target.source_key),
			"receiver_key": object_key,
			"accepted_runs": (target.accepted_runs as Array).duplicate(),
			"accepted_length_m": float(target.accepted_length_m),
			"material_path": str(target.material_path),
			"limitation": str(target.limitation),
			"modules": 0,
		}
	return {}


static func _validate_target_record(record: Dictionary, indices: PackedInt32Array, target: Dictionary) -> Dictionary:
	var object_key := str(record.get("object_key", ""))
	var expected_runs := int(target.run_count)
	if record.get("source_keys", []) != [str(target.source_key)] \
	or str(record.get("feature_kind", "")) != "building_wall" \
	or str(record.get("receiver_kind", "")) != "building_wall" \
	or str(record.get("material_key", "")) != "building_wall" \
	or str(record.get("collision_kind", "")) != "world_solid" \
	or not bool(record.get("opaque", false)) \
	or int(record.get("exterior_foundation_segments", -1)) != expected_runs \
	or int(record.get("shared_wall_segments", -1)) != 0 \
	or (record.get("vertices", []) as Array).size() != expected_runs * RUN_VERTEX_VALUES \
	or (record.get("indices", []) as Array).size() != expected_runs * RUN_INDEX_VALUES \
	or indices.size() != expected_runs * RUN_INDEX_VALUES:
		return {
			"ok": false,
			"code": "accepted_material_receiver_contract",
			"message": "Accepted material exact-run receiver drifted for %s." % object_key,
			"source_keys": record.get("source_keys", []),
		}
	var accepted_runs := target.accepted_runs as Array
	var seen := {}
	for run_value: Variant in accepted_runs:
		var run_index := int(run_value)
		if run_index < 0 or run_index >= expected_runs or seen.has(run_index):
			return {
				"ok": false,
				"code": "accepted_material_run_scope",
				"message": "Accepted material run scope is invalid for %s." % object_key,
				"source_keys": record.get("source_keys", []),
			}
		seen[run_index] = true
	return {"ok": true}
