class_name AcceptedMaterialRunTrials
extends RefCounted

const RUN_VERTEX_VALUES := 12
const RUN_INDEX_VALUES := 6
const PLACEHOLDER_SURFACE_NAME := "placeholder_runs"
const ACCEPTED_SURFACE_NAME := "accepted_material_runs"
const BATCH_06_ACCEPTED_STATUS := "accepted_exact_run_homogeneous_material_live_with_documented_limitation"

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

# Surface names remain stable because the canonical lifecycle inventory and the
# immutable pre-promotion evidence identify these exact renderer surfaces.
const BATCH_06_ACCEPTED_TARGETS := {
	"building:w34313564:wall": {
		"source_key": "w34313564",
		"run_count": 20,
		"material_groups": [
			{
				"id": "W34313564-MAT-TAN",
				"surface_name": "trial_w34313564_tan_runs",
				"run_groups": [[5, 6, 7, 8, 9]],
				"accepted_length_m": 87.651,
				"mapping_ids": ["B06-34313564-SSE-EAST-RETURN", "B06-34313564-SSE-CENTRAL"],
				"prototype_material_path": "res://game/resources/materials/world/w34313564/w34313564_tan_field.tres",
				"material_path": "res://game/resources/materials/world/w34313564/w34313564_tan_exact_trial.tres",
				"material": preload("res://game/resources/materials/world/w34313564/w34313564_tan_exact_trial.tres"),
				"limitation": "Muted tan SSE homogeneous field only; 0.82 m finish scale remains an unmeasured reversible assumption.",
			},
			{
				"id": "W34313564-MAT-PALE",
				"surface_name": "trial_w34313564_pale_runs",
				"run_groups": [[10, 11, 12, 13, 14, 15, 16, 17, 18, 19]],
				"accepted_length_m": 141.340,
				"mapping_ids": ["B06-34313564-ENE-END", "B06-34313564-NNW-OUTER"],
				"prototype_material_path": "res://game/resources/materials/world/w34313564/w34313564_pale_field.tres",
				"material_path": "res://game/resources/materials/world/w34313564/w34313564_pale_exact_trial.tres",
				"material": preload("res://game/resources/materials/world/w34313564/w34313564_pale_exact_trial.tres"),
				"limitation": "Off-white/light-gray ENE and NNW homogeneous field only; 0.88 m finish scale remains an unmeasured reversible assumption.",
			},
		],
		"standalone_blocker": "W34313564-MAT-PLINTH remains standalone because exact vertical extent and side bounds are unresolved; a run-only partition cannot attach it without prohibited geometry splitting.",
		"live_module_instances": 5,
	},
	"building:w34313515:wall": {
		"source_key": "w34313515",
		"run_count": 48,
		"material_groups": [
			{
				"id": "W34313515-MAT-PALE",
				"surface_name": "trial_w34313515_pale_runs",
				"run_groups": [[0, 1, 2, 3, 4, 5, 6, 7, 8], [43, 44, 45, 46, 47]],
				"accepted_length_m": 165.100,
				"mapping_ids": ["B06-34313515-WSW-OUTER", "B06-34313515-NNW-OUTER"],
				"prototype_material_path": "res://game/resources/materials/world/w34313515/w34313515_pale_field.tres",
				"material_path": "res://game/resources/materials/world/w34313515/w34313515_pale_exact_trial.tres",
				"material": preload("res://game/resources/materials/world/w34313515/w34313515_pale_exact_trial.tres"),
				"limitation": "Pale warm-gray/off-white WSW and NNW homogeneous field only; 1.10 m grain scale remains an unmeasured reversible assumption.",
			},
		],
		"standalone_blocker": "No other Batch 06 field is authorized for this receiver; ENE, SSE, lower regions, openings, and cadence remain placeholder-only.",
		"live_module_instances": 4,
		"live_module_motif_types": 1,
		"module_placement_role": "stylized/reference-derived production inference",
		"module_position_uncertainty_by_placement_m": {
			"CAL-WSW-BAY-01": 1.2,
			"CAL-WSW-BAY-02": 3.0,
			"CAL-NNW-BAY-01": 3.0,
			"CAL-NNW-BAY-02": 3.0,
		},
	},
	"building:w291196370:wall": {
		"source_key": "w291196370",
		"run_count": 36,
		"material_groups": [
			{
				"id": "W291196370-SIDING",
				"surface_name": "trial_w291196370_siding_runs",
				"run_groups": [[8, 9, 10], [17, 18, 19, 20, 21, 22]],
				"accepted_length_m": 97.893,
				"mapping_ids": ["B06-291196370-SSE-PUBLIC", "B06-291196370-ENE-OUTER"],
				"prototype_material_path": "res://game/resources/materials/world/w291196370/w291196370_siding_field.tres",
				"material_path": "res://game/resources/materials/world/w291196370/w291196370_siding_exact_trial.tres",
				"material": preload("res://game/resources/materials/world/w291196370/w291196370_siding_exact_trial.tres"),
				"limitation": "Cool gray-blue horizontal siding on observed SSE and ENE groups only; 0.20 m course height remains an unmeasured reversible assumption.",
			},
		],
		"standalone_blocker": "Exactly three independently detached-placement-reviewed module exemplars are live pending independent actual-world art review. NNW, WSW, short service facets, every additional opening/divider, access geometry, and yard-obscured runs remain placeholder-only or blocked.",
		"live_module_instances": 3,
		"live_module_motif_types": 3,
		"module_placement_role": "stylized/reference-derived production inference",
		"module_position_uncertainty_by_placement_m": {
			"CAL-SSE-WINSTACK-01": 2.0,
			"CAL-SSE-ENTRY-01": 3.0,
			"CAL-ENE-SERVICE-01": 4.0,
		},
	},
	"building:w34313520:wall": {
		"source_key": "w34313520",
		"run_count": 34,
		"material_groups": [
			{
				"id": "W34313520-MAT-PALE",
				"surface_name": "trial_w34313520_pale_runs",
				"run_groups": [[6, 7, 8, 9, 10]],
				"accepted_length_m": 68.156,
				"mapping_ids": ["B06-34313520-SSE-OUTER"],
				"prototype_material_path": "res://game/resources/materials/world/w34313520/w34313520_pale_field.tres",
				"material_path": "res://game/resources/materials/world/w34313520/w34313520_pale_exact_trial.tres",
				"material": preload("res://game/resources/materials/world/w34313520/w34313520_pale_exact_trial.tres"),
				"limitation": "Pale homogeneous field on observed SSE runs 6..10 only; 0.95 m / 0.29 m finish scales remain unmeasured production inference and actual-world art review is pending.",
			},
		],
		"lifecycle_status": "corrected_prototype_accepted_exact_run_trial_live_receiver_review_pending",
		"field_actual_world_review_status": "pending_independent_actual_world_art_review",
		"standalone_blocker": "Exactly one independently detached-calibration-reviewed BAY is live at run 7 midpoint pending independent actual-world art review. Every other run/side, runs 20..21, wing/recess/lower family, endpoints, additional BAY, cadence, complete SSE elevation, and whole building remain placeholder-only or blocked.",
		"live_module_instances": 1,
		"live_module_motif_types": 1,
		"module_placement_role": "stylized/reference-derived production inference",
		"module_position_uncertainty_by_placement_m": {
			"CAL-SSE-BAY-01": 11.144477,
		},
	},
	"building:w34313525:wall": {
		"source_key": "w34313525",
		"run_count": 30,
		"material_groups": [
			{
				"id": "CAL-FIELD-SSE-PALE-01",
				"surface_name": "trial_w34313525_pale_sse_runs",
				"run_groups": [[8, 9, 10, 11, 12]],
				"accepted_length_m": 75.310910,
				"mapping_ids": ["B06-34313525-SSE-CENTRAL"],
				"prototype_material_path": "res://game/resources/materials/world/w34313525/w34313525_pale_field.tres",
				"material_path": "res://game/resources/materials/world/w34313525/w34313525_pale_exact_trial.tres",
				"material": preload("res://game/resources/materials/world/w34313525/w34313525_pale_exact_trial.tres"),
				"limitation": "Pale homogeneous field on observed SSE runs 8..12 only; 0.88 m / 0.31 m scales remain unmeasured production inference and actual-world art review is pending.",
			},
			{
				"id": "CAL-FIELD-NNW-PALE-01",
				"surface_name": "trial_w34313525_pale_nnw_runs",
				"run_groups": [[26, 27]],
				"accepted_length_m": 15.936560,
				"mapping_ids": ["B06-34313525-NNW-CENTRAL"],
				"prototype_material_path": "res://game/resources/materials/world/w34313525/w34313525_pale_field.tres",
				"material_path": "res://game/resources/materials/world/w34313525/w34313525_pale_exact_trial.tres",
				"material": preload("res://game/resources/materials/world/w34313525/w34313525_pale_exact_trial.tres"),
				"limitation": "Pale homogeneous field on observed NNW runs 26..27 only; phase continuity is claimed only within this scope, scale is unmeasured production inference, and actual-world art review is pending.",
			},
		],
		"lifecycle_status": "corrected_prototype_accepted_exact_run_trial_live_receiver_review_pending",
		"field_actual_world_review_status": "pending_independent_actual_world_art_review",
		"standalone_blocker": "Exactly four independently detached-calibration-reviewed type exemplars are live on runs 9, 10, 26, and 27 pending independent actual-world art review. All other runs/sides/modules, real count/cadence/sequence, maximum uncertainty-envelope containment, completed SSE/NNW elevations, and whole building remain placeholder-only or blocked.",
		"live_module_instances": 4,
		"live_module_motif_types": 4,
		"module_placement_role": "stylized/reference-derived production inference",
		"module_position_uncertainty_by_placement_m": {
			"CAL-SSE-ROLLUP-PALE-01": 11.262233,
			"CAL-SSE-ROLLUP-GRAY-01": 13.403442,
			"CAL-NNW-PERSONNEL-01": 3.444684,
			"CAL-NNW-HIGH-GROUP-01": 1.298596,
		},
	},
}


static func matches_record(record: Dictionary) -> bool:
	return TARGETS.has(str(record.get("object_key", "")))


static func matches_batch_06_accepted_record(record: Dictionary) -> bool:
	return BATCH_06_ACCEPTED_TARGETS.has(str(record.get("object_key", "")))


static func partition(record: Dictionary, indices: PackedInt32Array, placeholder_material: Material) -> Dictionary:
	var object_key := str(record.get("object_key", ""))
	if BATCH_06_ACCEPTED_TARGETS.has(object_key):
		return _partition_accepted_material_groups(record, indices, placeholder_material, BATCH_06_ACCEPTED_TARGETS[object_key] as Dictionary)
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


static func _partition_accepted_material_groups(record: Dictionary, indices: PackedInt32Array, placeholder_material: Material, target: Dictionary) -> Dictionary:
	var validation := _validate_target_record(record, indices, target)
	if not bool(validation.get("ok", false)):
		return validation
	var run_owner := {}
	var grouped_indices: Array[PackedInt32Array] = []
	for group_index in (target.material_groups as Array).size():
		grouped_indices.append(PackedInt32Array())
		var group := (target.material_groups as Array)[group_index] as Dictionary
		for run_group_value: Variant in group.run_groups:
			for run_value: Variant in (run_group_value as Array):
				var run_index := int(run_value)
				if run_index < 0 or run_index >= int(target.run_count) or run_owner.has(run_index):
					return {
						"ok": false,
						"code": "accepted_material_group_run_scope",
						"message": "Accepted material group run scope is invalid for %s." % str(record.get("object_key", "")),
						"source_keys": record.get("source_keys", []),
					}
				run_owner[run_index] = group_index
	var placeholder_indices := PackedInt32Array()
	for run_index in int(target.run_count):
		var destination := placeholder_indices
		if run_owner.has(run_index):
			destination = grouped_indices[int(run_owner[run_index])]
		var offset := run_index * RUN_INDEX_VALUES
		for index_offset in RUN_INDEX_VALUES:
			destination.append(indices[offset + index_offset])
	var surfaces: Array[Dictionary] = [
		{"name": PLACEHOLDER_SURFACE_NAME, "indices": placeholder_indices, "material": placeholder_material},
	]
	for group_index in (target.material_groups as Array).size():
		var group := (target.material_groups as Array)[group_index] as Dictionary
		surfaces.append({
			"name": str(group.surface_name),
			"indices": grouped_indices[group_index],
			"material": group.material,
		})
	return {
		"ok": true,
		"surfaces": surfaces,
		"metadata": metadata_for(str(record.get("object_key", ""))),
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
	if not BATCH_06_ACCEPTED_TARGETS.has(object_key):
		return {}
	var target := BATCH_06_ACCEPTED_TARGETS[object_key] as Dictionary
	var groups: Array[Dictionary] = []
	for group_value: Variant in target.material_groups:
		var group := group_value as Dictionary
		groups.append({
			"id": str(group.id),
			"surface_name": str(group.surface_name),
			"run_groups": (group.run_groups as Array).duplicate(true),
			"accepted_length_m": float(group.accepted_length_m),
			"mapping_ids": (group.mapping_ids as Array).duplicate(),
			"prototype_material_path": str(group.prototype_material_path),
			"material_path": str(group.material_path),
			"limitation": str(group.limitation),
		})
	return {
		"status": str(target.get("lifecycle_status", BATCH_06_ACCEPTED_STATUS)),
		"source_key": str(target.source_key),
		"receiver_key": object_key,
		"material_groups": groups,
		"standalone_blocker": str(target.standalone_blocker),
		"field_actual_world_review_status": str(target.get("field_actual_world_review_status", "independently_reviewed_accepted_with_documented_limitation")),
		"modules": int(target.get("live_module_instances", 0)),
		"standalone_modules_live": int(target.get("live_module_instances", 0)),
		"module_motif_types_live": int(target.get("live_module_motif_types", 2 if object_key == "building:w34313564:wall" else 0)),
		"module_placement_role": str(target.get("module_placement_role", "stylized/reference-derived production inference" if object_key == "building:w34313564:wall" else "")),
		"module_position_uncertainty_m": 4.0 if object_key == "building:w34313564:wall" else 0.0,
		"module_position_uncertainty_by_placement_m": (target.get("module_position_uncertainty_by_placement_m", {}) as Dictionary).duplicate(true),
		"module_cadence_inferred": false,
		"module_total_opening_count_inferred": false,
	}


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
	if target.has("accepted_runs"):
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
