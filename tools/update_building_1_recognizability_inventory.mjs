import { createHash } from "node:crypto";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const PATH = "discovery/FACADE_RECEIVER_INVENTORY.json";
const WRITE = process.argv.includes("--write");
const readJson = (path) => JSON.parse(readFileSync(resolve(ROOT, path), "utf8"));
const sha = (path) => createHash("sha256").update(readFileSync(resolve(ROOT, path))).digest("hex");
const maybeHash = (path) => existsSync(resolve(ROOT, path)) ? sha(path) : "pending_evidence_seal";
const inventory = readJson(PATH);
const batch = inventory.batch_06_lifecycle_reconciliation;
const runtime = inventory.runtime_material_contract;
const progress = inventory.facade_progress_summary;
const priorAcceptedRuns = Array.from({ length: 31 }, (_, index) => index + 21);
const eligibleRuns = [...Array.from({ length: 57 }, (_, index) => index), 58, 60, 93, 94, 95, 96];
const acceptedRuns = eligibleRuns;
const extensionRuns = eligibleRuns.filter((run) => run < 21 || run > 51);
const fieldReviewPath = "discovery/facades/TREASURE_ISLAND_BUILDING_1_LIVE_IVORY_FIELD_ART_REVIEW.md";
const reviewPath = "discovery/facades/TREASURE_ISLAND_BUILDING_1_RECOGNIZABILITY_ART_REVIEW.md";
const registryPath = "game/resources/facades/building_1_recognizability_placements.json";
const adapterPath = "game/scripts/world/facades/building_1_recognizable_facade.gd";
const evidenceRoot = "evidence/first-playable/treasure-island-building-1-recognizability-composition-2026-08-30";

runtime.building_wall_and_part_wall = "plaster_grey_04 baseline, except twelve independently accepted target-specific runtime wall receivers including Building 1's bounded public-run recognizability composition";
runtime.receiver_limitation_profiles.standard_generated_wall_receiver[0] = "One generated wall object is one baseline material surface unless an exact bounded run partition or separately reviewed render overlay is listed below. Chapel, Dormitory, YMCA, w34313564, w34313515, w291196370, w34313520, and w34313525 retain their independently accepted scopes. Building 1 retains its generated receiver surface and adds exactly three watertight B1-MAT-IVORY public-run chains plus 45 complete render-only motifs, all independently accepted with documented limitations and zero collider ownership.";

const acceptedScope = {
  source_key: "r16681702",
  receiver_key: "building:r16681702:wall",
  scope_id: "B1-IVORY-ACCEPTED-PUBLIC-RUNS",
  field_id: "B1-MAT-IVORY",
  asset_kind: "homogeneous_material_tile",
  face: "verified public outer curve, wing/link, and north/south end regions",
  run_indices: acceptedRuns,
  run_count: 63,
  run_length_m: 206.908708,
  wall_area_m2: 4350.511117,
  runtime_render_note: "accepted semantic scope is represented by three watertight public-run render chains; isolated runs 58 and 60 make no phase claim across protected gaps",
  actual_world_art_review_status: "independently_reviewed_keep_with_documented_limitation",
  independent_live_review_path: reviewPath,
  independent_live_review_sha256: sha(reviewPath),
  predecessor_field_review_path: fieldReviewPath,
  predecessor_field_review_sha256: sha(fieldReviewPath),
  surveyed_material_scale_proven: false,
  completed_public_elevation_proven: false,
  whole_building_accepted: false,
};
batch.accepted_exact_field_scopes = batch.accepted_exact_field_scopes.filter((item) => item.receiver_key !== acceptedScope.receiver_key);
batch.accepted_exact_field_scopes.push(acceptedScope);
batch.accepted_exact_field_summary = {
  ...batch.accepted_exact_field_summary,
  target_receiver_count: 6,
  field_scope_count: 8,
  run_count: 113,
  run_length_m: 858.296178,
  wall_area_m2: 9108.268427,
  target_material_surface_count: 8,
  wall_area_derivation: "sum(field run length × current generated wall heights); all eight accepted semantic scopes are full-height exterior-foundation run surfaces",
  world_mesh_count: 1278,
  world_surface_count: 1288,
  world_triangle_count: 55067,
  world_surface_delta_vs_one_surface_per_generated_mesh: 479,
  batch_06_surface_delta: 476,
};
if (!batch.accepted_exact_run_homogeneous_material_live_with_documented_limitation_source_keys.includes("r16681702")) {
  batch.accepted_exact_run_homogeneous_material_live_with_documented_limitation_source_keys.push("r16681702");
}
batch.pending_independent_actual_world_art_review_exact_field_scopes = batch.pending_independent_actual_world_art_review_exact_field_scopes.filter((item) => item.receiver_key !== acceptedScope.receiver_key);
batch.live_exact_field_summary = {
  target_receiver_count: 6,
  field_scope_count: 8,
  run_count: 113,
  run_length_m: 858.296178,
  wall_area_m2: 9108.268427,
  target_material_surface_count: 8,
  placeholder_surface_count: 5,
  independently_accepted_target_receiver_count: 6,
  independently_accepted_field_scope_count: 8,
  pending_independent_actual_world_art_review_target_receiver_count: 0,
  pending_independent_actual_world_art_review_field_scope_count: 0,
  generated_record_count: 729,
  generated_world_mesh_count: 729,
  generated_world_surface_count: 739,
  generated_world_triangle_count: 48389,
  world_mesh_count: 1278,
  world_surface_count: 1288,
  world_triangle_count: 55067,
  world_collider_pair_count: 466,
  world_surface_delta_vs_one_surface_per_generated_mesh: 479,
  batch_06_surface_delta: 476,
  retained_prior_exact_run_surface_delta: 3,
};
batch.pending_independent_recognizability_review_summary = {
  target_receiver_count: 0,
  source_keys: [],
  receiver_keys: [],
  field_extension_group_count: 0,
  field_extension_run_count: 0,
  field_extension_run_length_m: 0,
  field_extension_wall_area_m2: 0,
  module_placement_count: 0,
  module_mesh_count: 0,
  module_surface_count: 0,
  module_triangle_count: 0,
  status: "no_pending_independent_recognizability_review",
};
const building1ModuleSummary = {
  source_key: "r16681702",
  receiver_key: "building:r16681702:wall",
  placement_count: 45,
  motif_instance_counts: {"B1-WING-W": 8, "B1-CENTRAL-W": 24, "B1-PAV-W": 2, "B1-BASE-O": 6, "B1-DOOR-BLUE": 1, "B1-BAND": 4},
  mesh_instances: 351,
  surfaces: 351,
  triangles: 4212,
  collision_nodes: 0,
  navigation_nodes: 0,
  spray_nodes: 0,
  placement_role: "recognizable_reference_derived_production_inference",
  actual_world_art_review_status: "independently_reviewed_keep_with_documented_limitation",
  independent_live_review_path: reviewPath,
  independent_live_review_sha256: sha(reviewPath),
  surveyed_dimensions_proven: false,
  surveyed_scale_proven: false,
  surveyed_coordinates_proven: false,
  real_count_proven: false,
  cadence_proven: false,
  sequence_proven: false,
  completed_elevation_proven: false,
  whole_building_accepted: false,
};
batch.accepted_live_module_summary_building_1 = building1ModuleSummary;
batch.accepted_live_module_summary = {
  target_receiver_count: 6,
  source_keys: ["w34313564", "w34313515", "w291196370", "w34313520", "w34313525", "r16681702"],
  placement_count: 62,
  module_nodes: 62,
  mesh_instances: 546,
  surfaces: 546,
  triangles: 6552,
  collision_nodes: 0,
  navigation_nodes: 0,
  spray_nodes: 0,
  verdict: "KEEP_WITH_DOCUMENTED_LIMITATION",
  scope_boundary: "the seventeen previously accepted exact placements plus exactly forty-five Building 1 recognizability placements; every receiver retains its separate review and documented limitations",
};
batch.placement_approved_live_module_summary = {
  ...batch.accepted_live_module_summary,
  independently_accepted_target_receiver_count: 6,
  independently_accepted_placement_count: 62,
  pending_independent_actual_world_art_review_target_receiver_count: 0,
  pending_independent_actual_world_art_review_placement_count: 0,
};

if (!progress.accepted_exact_run_material_source_keys.includes("r16681702")) {
  progress.accepted_exact_run_material_source_keys.push("r16681702");
}
progress.corrected_prototype_exact_run_trial_live_pending_review_source_keys = [];
progress.recognizability_composition_pending_independent_review_source_keys = [];
if (!progress.accepted_source_keys.includes("r16681702")) progress.accepted_source_keys.push("r16681702");
if (!progress.accepted_live_module_source_keys.includes("r16681702")) progress.accepted_live_module_source_keys.push("r16681702");
progress.source_entity_status_counts.accepted_exact_run_homogeneous_material_live_with_documented_limitation = 9;
progress.source_entity_status_counts.corrected_prototype_exact_run_trial_live_pending_review = 0;
progress.direct_receiver_status_counts.accepted_exact_run_homogeneous_material_live_with_documented_limitation = 9;
progress.direct_receiver_status_counts.corrected_prototype_exact_run_trial_live_pending_review = 0;
progress.count_invariant = "All lifecycle buckets exactly mirror facade_tracker_status.lifecycle_status and sum to 215 sources. Removing the one meshless Isle House parent yields 214 direct receivers. Twelve direct receivers retain independently accepted target-specific runtime content. The independently accepted exact-run set is eleven field scopes / 130 runs / 1,024.828178 m / 10,476.046427 m². Independently accepted live modules are six receivers / 62 placements / 546 meshes / 546 surfaces / 6,552 triangles. Pending actual-world and recognizability review counts are zero.";

runtime.accepted_target_specific_runtime_attachment_count = 12;
runtime.accepted_exact_run_material_attachment_count = 9;
runtime.accepted_exact_field_scope_count = 11;
runtime.accepted_exact_run_material_surface_count = 11;
runtime.accepted_exact_run_count = 130;
runtime.accepted_exact_run_length_m = 1024.828178;
runtime.accepted_exact_run_wall_area_m2 = 10476.046427;
runtime.live_exact_run_count = 130;
runtime.live_exact_run_length_m = 1024.828178;
runtime.live_exact_run_wall_area_m2 = 10476.046427;
runtime.accepted_live_module_target_receiver_count = 6;
runtime.accepted_live_module_placement_count = 62;
runtime.accepted_live_module_mesh_count = 546;
runtime.accepted_live_module_surface_count = 546;
runtime.accepted_live_module_triangle_count = 6552;
runtime.placement_approved_live_module_target_receiver_count = 6;
runtime.placement_approved_live_module_placement_count = 62;
runtime.placement_approved_live_module_mesh_count = 546;
runtime.placement_approved_live_module_surface_count = 546;
runtime.placement_approved_live_module_triangle_count = 6552;
runtime.pending_independent_actual_world_art_review_exact_field_target_receiver_count = 0;
runtime.pending_independent_actual_world_art_review_exact_field_scope_count = 0;
runtime.pending_independent_actual_world_art_review_exact_field_run_count = 0;
runtime.pending_independent_actual_world_art_review_exact_field_run_length_m = 0;
runtime.pending_independent_actual_world_art_review_exact_field_wall_area_m2 = 0;
runtime.pending_independent_recognizability_target_receiver_count = 0;
runtime.pending_independent_recognizability_field_extension_group_count = 0;
runtime.pending_independent_recognizability_field_extension_run_count = 0;
runtime.pending_independent_recognizability_live_module_placement_count = 0;
runtime.pending_independent_recognizability_live_module_mesh_count = 0;
runtime.pending_independent_recognizability_live_module_surface_count = 0;
runtime.pending_independent_recognizability_live_module_triangle_count = 0;
runtime.accepted_target_specific_runtime_attachments = runtime.accepted_target_specific_runtime_attachments.filter((item) => item.receiver_key !== acceptedScope.receiver_key);
runtime.accepted_target_specific_runtime_attachments.push({
  source_key: "r16681702",
  receiver_key: "building:r16681702:wall",
  attachment_kind: "accepted_recognizability_field_and_complete_module_composition",
  field_id: "B1-MAT-IVORY",
  accepted_runs: acceptedRuns,
  accepted_length_m: 206.908708,
  accepted_wall_area_m2: 4350.511117,
  accepted_module_placement_count: 45,
  accepted_module_mesh_count: 351,
  accepted_module_triangle_count: 4212,
  material_path: "game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres",
  material_sha256: "12d059d9d806c629225254f1aaf945be69a00ce5878db276ce299ad0c8cdbb9a",
  independent_live_review_path: reviewPath,
  independent_live_review_sha256: sha(reviewPath),
  verdict: "KEEP_WITH_DOCUMENTED_LIMITATION",
  predecessor_field_review_path: fieldReviewPath,
  predecessor_field_review_sha256: sha(fieldReviewPath),
  disposition: "B1-MAT-IVORY is independently accepted on exactly 63 verified public runs and exactly 45 complete motifs are independently accepted as recognizable reference-derived production inference; protected runs, surveyed/as-built claims, completed elevation and whole-building fidelity remain unaccepted",
});
runtime.pending_independent_actual_world_art_review_runtime_attachments = (runtime.pending_independent_actual_world_art_review_runtime_attachments || []).filter((item) => item.receiver_key !== acceptedScope.receiver_key);
runtime.pending_independent_recognizability_review_runtime_attachments = [];

const mistaken = inventory.objects.find((item) => item.source?.source_key === "r133347");
if (mistaken) {
  for (const key of Object.keys(mistaken.runtime_material_assignment)) {
    if (key.startsWith("target_specific_live_")) delete mistaken.runtime_material_assignment[key];
  }
}
const building1 = inventory.objects.find((item) => item.source?.source_key === "r16681702");
if (!building1) throw new Error("Building 1 canonical receiver record missing");
building1.runtime_material_assignment = {
  ...building1.runtime_material_assignment,
  assignment_code_path: "game/scripts/world/world_chunk_builder.gd",
  target_specific_facade_adapter_path: adapterPath,
  target_specific_field_id: "B1-MAT-IVORY",
  accepted_field_runs: acceptedRuns,
  recognizability_total_field_runs: eligibleRuns,
  recognizability_module_placement_count: 45,
  recognizability_review_status: "independently_reviewed_keep_with_documented_limitation",
  recognizability_review_path: reviewPath,
  recognizability_review_sha256: sha(reviewPath),
  accepted_field_review_status: "independently_reviewed_keep_with_documented_limitation",
};
delete building1.runtime_material_assignment.recognizability_field_runs_pending_review;
building1.research_texture_status = {
  ...building1.research_texture_status,
  current_runtime_texture: "independently accepted B1-MAT-IVORY on exactly 63 verified public runs plus exactly 45 accepted complete recognizability motifs",
  accepted_target_specific_texture: true,
  generation_readiness: "completed_for_independently_accepted_public_run_field_and_recognizability_composition_with_documented_limitations",
  status_note: "B1-MAT-IVORY on 63 verified public runs and exactly 45 complete motifs are independently accepted live as reversible production inference; as-built fidelity and protected scope remain unclaimed.",
};
building1.facade_tracker_status = {
  ...building1.facade_tracker_status,
  lifecycle_status: "accepted_exact_run_homogeneous_material_live_with_documented_limitation",
  facade_language_status: "standalone_family_and_exact_public_run_recognizability_composition_independently_accepted_with_documented_limitations",
  runtime_integration_status: "independently accepted B1-MAT-IVORY on exactly 63 verified public runs plus exactly 45 complete production-inference motifs",
  accepted_scope: [
    "Standalone B1-MAT-IVORY and six complete module families retain their separate independent standalone verdicts.",
    "B1-MAT-IVORY on exactly 63 verified public runs is independently accepted live KEEP_WITH_DOCUMENTED_LIMITATION.",
    "Exactly 45 live motif placements are independently accepted KEEP_WITH_DOCUMENTED_LIMITATION as recognizable reference-derived production inference.",
  ],
  untouched_or_unknown_scope: [
    "Runs 57/59/61, 62-92, 97-109, inner ring, separate tower w1222720021, roof, entrance/canopy/emblems, massing, collision/navigation/spray/terrain and generated source/data remain untouched.",
    "All module and field-extension counts/cadence/coordinates are reversible production inference; as-built fidelity, completed elevation, and whole-building acceptance remain unclaimed.",
  ],
  evidence_paths: [...new Set([...(building1.facade_tracker_status.evidence_paths || []), fieldReviewPath, reviewPath, "discovery/facades/TREASURE_ISLAND_BUILDING_1_RECOGNIZABILITY_PLACEMENT_BRIEF.md", registryPath, `${evidenceRoot}/README.md`, `${evidenceRoot}/capture-manifest.json`])],
  data_gaps: [
    "Scale, coordinates, counts, cadence, sequence, facade completion, and as-built fidelity are not surveyed or accepted.",
  ],
};

runtime.building_1_recognizability_registry_path = registryPath;
runtime.building_1_recognizability_registry_sha256 = sha(registryPath);
runtime.building_1_recognizability_adapter_path = adapterPath;
runtime.building_1_recognizability_adapter_sha256 = sha(adapterPath);
runtime.building_1_live_field_review_path = reviewPath;
runtime.building_1_live_field_review_sha256 = sha(reviewPath);
runtime.building_1_predecessor_field_review_path = fieldReviewPath;
runtime.building_1_predecessor_field_review_sha256 = sha(fieldReviewPath);
runtime.building_1_recognizability_capture_manifest_path = `${evidenceRoot}/capture-manifest.json`;
runtime.building_1_recognizability_capture_manifest_sha256 = maybeHash(`${evidenceRoot}/capture-manifest.json`);
runtime.building_1_recognizability_runtime_isolation_path = `${evidenceRoot}/runtime-isolation.json`;
runtime.building_1_recognizability_runtime_isolation_sha256 = maybeHash(`${evidenceRoot}/runtime-isolation.json`);
runtime.world_builder_path = "game/scripts/world/world_chunk_builder.gd";
runtime.world_builder_sha256 = sha("game/scripts/world/world_chunk_builder.gd");
runtime.current_loaded_world_topology = {records: 729, meshes: 1278, surfaces: 1288, triangles: 55067, collider_pairs: 466};

batch.runtime_identity.building_1_recognizability_registry_path = registryPath;
batch.runtime_identity.building_1_recognizability_registry_sha256 = sha(registryPath);
batch.runtime_identity.building_1_recognizability_adapter_path = adapterPath;
batch.runtime_identity.building_1_recognizability_adapter_sha256 = sha(adapterPath);
batch.runtime_identity.building_1_live_field_review_path = reviewPath;
batch.runtime_identity.building_1_live_field_review_sha256 = sha(reviewPath);
batch.runtime_identity.building_1_predecessor_field_review_path = fieldReviewPath;
batch.runtime_identity.building_1_predecessor_field_review_sha256 = sha(fieldReviewPath);
batch.runtime_identity.building_1_recognizability_capture_manifest_path = `${evidenceRoot}/capture-manifest.json`;
batch.runtime_identity.building_1_recognizability_capture_manifest_sha256 = maybeHash(`${evidenceRoot}/capture-manifest.json`);
batch.runtime_identity.world_builder_path = "game/scripts/world/world_chunk_builder.gd";
batch.runtime_identity.world_builder_sha256 = sha("game/scripts/world/world_chunk_builder.gd");
batch.current_state_maintenance_pins = {
  status: "building_1_public_ivory_field_and_recognizability_composition_independently_accepted",
  note: "B1-MAT-IVORY on exactly 63 verified public runs and exactly 45 complete placements are independently accepted KEEP_WITH_DOCUMENTED_LIMITATION as reversible production inference; no surveyed, completed-elevation, as-built, protected-scope, or whole-building claim is introduced.",
  paths: [
    "game/tests/headless_batch_06_exact_receiver_trial_contract.gd",
    "game/tests/headless_accepted_material_run_trials_contract.gd",
    "game/tests/headless_building_1_live_field_integration_contract.gd",
    "game/tests/headless_building_1_recognizability_live_contract.gd",
  ],
};
for (const path of [fieldReviewPath, reviewPath, "discovery/facades/TREASURE_ISLAND_BUILDING_1_RECOGNIZABILITY_PLACEMENT_BRIEF.md", registryPath, `${evidenceRoot}/README.md`, `${evidenceRoot}/capture-manifest.json`, `${evidenceRoot}/runtime-isolation.json`]) {
  if (!batch.evidence_paths.includes(path)) batch.evidence_paths.push(path);
}

const serialized = `${JSON.stringify(inventory, null, 2)}\n`;
if (WRITE) writeFileSync(resolve(ROOT, PATH), serialized);
else process.stdout.write(serialized);
