import { createHash } from "node:crypto";
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const WRITE = process.argv.includes("--write");
const OUTPUT = "game/resources/facades/building_1_exact_receiver_calibration.json";
const CHUNK = "generated/world/chunks/x_-1__z_2.json";
const MAPPING = "discovery/facades/TREASURE_ISLAND_BUILDING_1_RUN_OWNERSHIP.json";
const STANDALONE = "game/resources/facades/building_1_standalone_prototypes.json";
const REVIEW = "discovery/facades/TREASURE_ISLAND_BUILDING_1_STANDALONE_PROTOTYPE_ART_REVIEW.md";
const FIELD_MATERIAL =
  "game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres";
const FIELD_SHADER =
  "game/resources/materials/world/building_1/building_1_chain_metres_aperiodic_field.gdshader";
const FIELD_RUNS = Array.from({ length: 31 }, (_, index) => index + 21);
const WALL_OFFSET_M = 0.06;

const readJson = (path) => JSON.parse(readFileSync(resolve(ROOT, path), "utf8"));
const sha256 = (path) =>
  createHash("sha256").update(readFileSync(resolve(ROOT, path))).digest("hex");
const round = (value, digits = 6) => {
  const power = 10 ** digits;
  return Math.round((value + Number.EPSILON) * power) / power;
};
const subtract = (a, b) => a.map((value, index) => value - b[index]);
const cross = (a, b) => [
  a[1] * b[2] - a[2] * b[1],
  a[2] * b[0] - a[0] * b[2],
  a[0] * b[1] - a[1] * b[0],
];
const magnitude = (value) => Math.hypot(...value);
const triangleArea = (a, b, c) => magnitude(cross(subtract(b, a), subtract(c, a))) / 2;
const normalizeXZ = (value) => {
  const length = Math.hypot(value[0], value[2]);
  return [value[0] / length, 0, value[2] / length];
};
const bearing = (normal) =>
  ((Math.atan2(normal[0], -normal[2]) * 180) / Math.PI + 360) % 360;

const chunk = readJson(CHUNK);
const mapping = readJson(MAPPING);
const standalone = readJson(STANDALONE);
const record = chunk.records.find((item) => item.object_key === "building:r16681702:wall");
if (!record || record.vertices.length !== 1320) throw new Error("Building 1 receiver drift");
if (
  mapping.detached_calibration_gate.status !== "partially_authorized" ||
  JSON.stringify(mapping.detached_calibration_gate.authorized_assets) !==
    JSON.stringify(["B1-MAT-IVORY", "B1-CENTRAL-W", "B1-PAV-W"])
) {
  throw new Error("Building 1 mapping gate drift");
}

function frame(run) {
  const offset = run * 12;
  const corners = Array.from({ length: 4 }, (_, corner) =>
    record.vertices.slice(offset + corner * 3, offset + corner * 3 + 3),
  );
  const start = corners[0];
  const end = corners[1];
  const topEnd = corners[2];
  const topStart = corners[3];
  const horizontal = [end[0] - start[0], 0, end[2] - start[2]];
  const length = magnitude(horizontal);
  const tangent = horizontal.map((value) => value / length);
  const normal = normalizeXZ(record.normals.slice(offset, offset + 3));
  return {
    run,
    start,
    end,
    top_start: topStart,
    top_end: topEnd,
    length_m: length,
    surface_area_m2:
      triangleArea(corners[0], corners[2], corners[1]) +
      triangleArea(corners[0], corners[3], corners[2]),
    height_start_m: topStart[1] - start[1],
    height_end_m: topEnd[1] - end[1],
    tangent,
    normal,
    bearing_deg: bearing(normal),
  };
}

const fieldFrames = FIELD_RUNS.map(frame);
let cumulative = 0;
const fieldRunRecords = fieldFrames.map((item, index) => {
  const startPhase = cumulative;
  const endPhase = cumulative + item.length_m;
  const result = {
    run_index: item.run,
    start_world_m: item.start.map((value) => round(value, 3)),
    end_world_m: item.end.map((value) => round(value, 3)),
    top_start_world_m: item.top_start.map((value) => round(value, 3)),
    top_end_world_m: item.top_end.map((value) => round(value, 3)),
    length_m: round(item.length_m, 6),
    surface_area_m2: round(item.surface_area_m2, 6),
    height_start_m: round(item.height_start_m, 6),
    height_end_m: round(item.height_end_m, 6),
    tangent_world_xz: [round(item.tangent[0]), round(item.tangent[2])],
    outward_normal_world_xz: [round(item.normal[0]), round(item.normal[2])],
    facing_azimuth_deg: round(item.bearing_deg, 1),
    chain_phase_start_m: round(startPhase, 9),
    chain_phase_end_m: round(endPhase, 9),
    previous_join_phase_delta_m: 0,
    previous_endpoint_delta_m:
      index === 0
        ? 0
        : round(
            magnitude(subtract(fieldFrames[index - 1].end, item.start)),
            9,
          ),
  };
  cumulative = endPhase;
  return result;
});

const modulesById = new Map(standalone.modules.map((module) => [module.motif_id, module]));

function fitStudy({ id, motifId, run, centerHeight, side, region, observations, reason }) {
  const runFrame = frame(run);
  const module = modulesById.get(motifId);
  if (!module) throw new Error(`Missing accepted module ${motifId}`);
  const halfMaximumWidth = module.uncertainty_bounds_m.width[1] / 2;
  const halfMaximumHeight = module.uncertainty_bounds_m.height[1] / 2;
  const along = runFrame.length_m / 2;
  const fraction = 0.5;
  const wallAnchor = runFrame.start.map(
    (value, index) => value + (runFrame.end[index] - value) * fraction,
  );
  const baseY = wallAnchor[1];
  const topY = runFrame.top_start[1] + (runFrame.top_end[1] - runFrame.top_start[1]) * fraction;
  const origin = [
    wallAnchor[0] + runFrame.normal[0] * WALL_OFFSET_M,
    baseY + centerHeight,
    wallAnchor[2] + runFrame.normal[2] * WALL_OFFSET_M,
  ];
  const horizontalDomain = [halfMaximumWidth, runFrame.length_m - halfMaximumWidth];
  const verticalDomain = [halfMaximumHeight, topY - baseY - halfMaximumHeight];
  if (
    along < horizontalDomain[0] ||
    along > horizontalDomain[1] ||
    centerHeight < verticalDomain[0] ||
    centerHeight > verticalDomain[1]
  ) {
    throw new Error(`${id} leaves its full uncertainty containment domain`);
  }
  return {
    fit_study_id: id,
    motif_id: motifId,
    asset_kind: "module_atlas",
    study_kind: "detached_scale_contact_fit_only_not_actual_world_anchor",
    exact_ordered_runs: [run],
    representative_run: run,
    side,
    region,
    observation_ids: observations,
    evidence_status: "production_inference_inside_reference_mapped_receiver_region",
    selection_rule: reason,
    run_length_m: round(runFrame.length_m, 6),
    run_height_at_center_m: round(topY - baseY, 6),
    along_run_center_m: round(along, 9),
    along_run_fraction: 0.5,
    mechanically_eligible_center_domain_m: horizontalDomain.map((value) => round(value, 9)),
    center_uncertainty_half_span_m: round(
      Math.min(along - horizontalDomain[0], horizontalDomain[1] - along),
      9,
    ),
    center_height_above_base_m: centerHeight,
    mechanically_eligible_center_height_domain_m: verticalDomain.map((value) => round(value, 6)),
    wall_anchor_world_m: wallAnchor.map((value) => round(value, 6)),
    expected_module_origin_world_m: origin.map((value) => round(value, 6)),
    tangent_world_xz: [round(runFrame.tangent[0]), round(runFrame.tangent[2])],
    outward_normal_world_xz: [round(runFrame.normal[0]), round(runFrame.normal[2])],
    facing_azimuth_deg: round(runFrame.bearing_deg, 1),
    nominal_bounds_m: module.nominal_bounds_m,
    uncertainty_bounds_m: module.uncertainty_bounds_m,
    prototype_topology: module.prototype_topology,
    wall_offset_m: WALL_OFFSET_M,
    surveyed_dimensions: false,
    surveyed_coordinates: false,
    surveyed_count: false,
    surveyed_cadence: false,
    real_placement_authorized: false,
    completed_elevation: false,
    whole_building_accepted: false,
    runtime_attachment: false,
  };
}

const fitStudies = [
  fitStudy({
    id: "FIT-CENTRAL-W-R36",
    motifId: "B1-CENTRAL-W",
    run: 36,
    centerHeight: 10,
    side: "outer west-facing public curve",
    region: "PUBLIC-CURVE-CONFIRMED",
    observations: ["B1-SV01", "B1-SV02", "B1-SV03"],
    reason:
      "run 36 is the mechanically eligible run whose midpoint is nearest the exact 85.939934 m curve-chain midpoint; midpoint use is deterministic and not a real opening coordinate",
  }),
  fitStudy({
    id: "FIT-PAV-W-R06",
    motifId: "B1-PAV-W",
    run: 6,
    centerHeight: 10,
    side: "outer SW-facing north public end",
    region: "PUBLIC-NORTH-END-CANDIDATE",
    observations: ["B1-SV01", "B1-SV02"],
    reason:
      "run 6 is the longest mechanically eligible run in the mapped pavilion candidate regions; midpoint use is deterministic and not a real pavilion-window coordinate",
  }),
];

const fieldLength = fieldFrames.reduce((sum, item) => sum + item.length_m, 0);
const fieldArea = fieldFrames.reduce((sum, item) => sum + item.surface_area_m2, 0);
const minimumHeight = Math.min(
  ...fieldFrames.flatMap((item) => [item.height_start_m, item.height_end_m]),
);
const maximumHeight = Math.max(
  ...fieldFrames.flatMap((item) => [item.height_start_m, item.height_end_m]),
);

const registry = {
  schema_version: "ti.building-1-detached-exact-receiver-calibration/1",
  status: "detached_calibration_ready_for_independent_exact_receiver_art_review_not_self_accepted",
  evidence_role:
    "exact detached MAT-IVORY field scale/chain-phase study on outer runs 21..51 plus two complete calibration-only CENTRAL/PAV fit studies; not actual-world anchors, real placements, count, cadence, sequence, completed elevation, or live attachment",
  target: {
    canonical_identity: "Treasure Island Administration Building 1 / Treasure Island Museum",
    source_key: "r16681702",
    receiver_key: "building:r16681702:wall",
    chunk: "x_-1__z_2",
    run_count: 110,
    height_m: 20,
    flat_base_elevation_m: record.flat_base_elevation_m,
    top_elevation_m: record.top_elevation_m,
    generated_wall_topology: {
      vertices: record.vertices.length / 3,
      indices: record.indices.length,
      triangles: record.indices.length / 3,
      surfaces: 1,
      collision_kind: record.collision_kind,
      opaque: record.opaque,
    },
  },
  authorization: {
    run_ownership_mapping_path: `res://${MAPPING}`,
    run_ownership_mapping_sha256: sha256(MAPPING),
    mapping_gate: mapping.detached_calibration_gate,
    standalone_review_path: `res://${REVIEW}`,
    standalone_review_sha256: sha256(REVIEW),
    standalone_review_verdict: "PASS_WITH_DOCUMENTED_LIMITATION",
    one_calibration_pass: true,
    correction_count: 0,
  },
  exact_field_scope: {
    material_id: "B1-MAT-IVORY",
    asset_kind: "homogeneous_material_tile",
    side: "outer broad curved public/parking-lot elevation",
    region: "PUBLIC-CURVE-CONFIRMED",
    observation_ids: ["B1-SV01", "B1-SV02", "B1-SV03"],
    evidence_status: "reference_observation_plus_verified_exact_generated_geometry",
    exact_ordered_runs: FIELD_RUNS,
    run_count: FIELD_RUNS.length,
    physical_wall_length_m: round(fieldLength, 6),
    authoritative_mapping_rounded_length_m: 85.94,
    generated_mesh_surface_area_m2: round(fieldArea, 6),
    wall_height_m: {
      nominal: 20,
      minimum: round(minimumHeight, 6),
      maximum: round(maximumHeight, 6),
      reason:
        "generated terrain-following lower edge varies while every top vertex remains at 26.281 m",
    },
    runs: fieldRunRecords,
    standalone_material_path:
      "res://game/resources/materials/world/building_1/building_1_warm_ivory.tres",
    standalone_material_sha256: sha256(
      "game/resources/materials/world/building_1/building_1_warm_ivory.tres",
    ),
    exact_trial_material_path: `res://${FIELD_MATERIAL}`,
    exact_trial_material_sha256: sha256(FIELD_MATERIAL),
    exact_trial_shader_path: `res://${FIELD_SHADER}`,
    exact_trial_shader_sha256: sha256(FIELD_SHADER),
    material_parameters: {
      base_color: [0.82, 0.79, 0.69, 1],
      secondary_color: [0.74, 0.715, 0.64, 1],
      roughness_value: 0.82,
      field_kind: 0,
      primary_scale_m: 1.1,
      secondary_scale_m: 0.32,
      relief_strength: 0.008,
      color_variation: 0.015,
      filter_start_cycles_per_pixel: 0.12,
      filter_end_cycles_per_pixel: 0.34,
    },
    meter_and_uv_contract: {
      one_godot_unit_m: 1,
      generated_uv1_role: "retained only in source; detached overlay rebuilds exact chain metre UV",
      overlay_uv_formula:
        "UV.x = cumulative ordered horizontal run length from run 21 start; UV.y = source world Y metres",
      shader_formula: "field_position_m = UV",
      horizontal_phase_origin: "0.0 m at ordered run 21 start",
      vertical_phase_origin: "absolute source world Y metres",
      internal_join_count: 30,
      maximum_endpoint_delta_m: 0,
      maximum_join_phase_delta_m: 0,
      finite_repeat_period: "none_by_design_aperiodic",
      physical_span_m: [round(fieldLength, 6), round(maximumHeight, 6)],
    },
    scale_status: "accepted_standalone_scale_preserved_as_unsurveyed_production_inference",
    assignment_status: "detached_proposal_pending_independent_exact_receiver_art_review",
    runtime_attachment: false,
    surveyed_scale: false,
    surveyed_color: false,
    surveyed_roughness: false,
    completed_elevation: false,
    whole_building_accepted: false,
  },
  fit_study_policy: {
    fit_study_count: 2,
    actual_world_placement_count: 0,
    position_status: "deterministic_calibration_only_production_inference_not_real_anchor",
    count_status: "two_distinct_family_fit_studies_not_real_count",
    cadence_status: "unknown_not_inferred",
    sequence_status: "unknown_not_inferred",
    orientation: "local X run tangent, local Y world up, local Z outward wall normal",
    wall_offset_m: WALL_OFFSET_M,
    module_owns_field_geometry: false,
    module_owned_backing_meshes: 0,
    collision_nodes: 0,
    navigation_nodes: 0,
    spray_nodes: 0,
    runtime_attachment: false,
  },
  fit_studies: fitStudies,
  detached_overlay_contract: {
    parent: "detached_scene_or_capture_harness_only_never_receiver",
    field_meshes: 1,
    field_surfaces: 1,
    field_vertices: FIELD_RUNS.length * 4,
    field_triangles: FIELD_RUNS.length * 2,
    module_fit_study_instances: 2,
    module_meshes: 22,
    module_surfaces: 22,
    module_triangles: 264,
    total_meshes: 23,
    total_surfaces: 23,
    total_triangles: 326,
    module_field_or_backing_meshes: 0,
    collision_nodes: 0,
    navigation_nodes: 0,
    spray_nodes: 0,
    runtime_attachment: false,
  },
  excluded_checksum_locked_assets: [
    {
      motif_id: "B1-WING-W",
      reason: "exact run blocker retained",
      prototype_topology: modulesById.get("B1-WING-W").prototype_topology,
    },
    {
      motif_id: "B1-BASE-O",
      reason: "exact run and window-versus-vent blockers retained",
      prototype_topology: modulesById.get("B1-BASE-O").prototype_topology,
    },
    {
      motif_id: "B1-DOOR-BLUE",
      reason: "exact run blocker retained",
      prototype_topology: modulesById.get("B1-DOOR-BLUE").prototype_topology,
    },
    {
      motif_id: "B1-BAND",
      reason: "exact run and terminal blockers retained",
      prototype_topology: modulesById.get("B1-BAND").prototype_topology,
    },
  ],
  protected_input_hashes: {
    standalone_registry: sha256(STANDALONE),
    standalone_scene: sha256(
      "game/scenes/world/facades/building_1/building_1_standalone_prototype_set.tscn",
    ),
    standalone_factory: sha256(
      "game/scripts/world/facades/building_1_standalone_prototypes.gd",
    ),
    standalone_evidence_ledger: sha256(
      "evidence/first-playable/treasure-island-building-1-standalone-prototypes-2026-08-30/checksums.sha256",
    ),
    run_ownership_mapping: sha256(MAPPING),
    run_ownership_handoff: sha256(
      "discovery/facades/TREASURE_ISLAND_BUILDING_1_RUN_OWNERSHIP_HANDOFF.md",
    ),
    run_ownership_evidence_ledger: sha256(
      "evidence/first-playable/treasure-island-building-1-run-ownership-mapping-2026-08-30/checksums.sha256",
    ),
    generated_manifest: sha256("generated/world/manifest.json"),
    generated_chunk: sha256(CHUNK),
    world_builder: sha256("game/scripts/world/world_chunk_builder.gd"),
    accepted_material_helper: sha256(
      "game/scripts/world/facades/accepted_material_run_trials.gd",
    ),
    canonical_inventory: sha256("discovery/FACADE_RECEIVER_INVENTORY.json"),
    r133351_registry: sha256("game/resources/facades/r133351_standalone_prototypes.json"),
  },
  preserved_false_claims: {
    actual_world_anchor: false,
    surveyed_dimensions: false,
    surveyed_coordinates: false,
    surveyed_material_scale: false,
    surveyed_real_count: false,
    surveyed_or_inferred_cadence: false,
    surveyed_or_inferred_sequence: false,
    architectural_pattern_tile: false,
    wing_base_door_band_calibrated: false,
    east_rear_or_inner_scope: false,
    completed_public_elevation: false,
    whole_building_accepted: false,
    live_attachment: false,
    lifecycle_promotion: false,
  },
};

const contents = `${JSON.stringify(registry, null, 2)}\n`;
const absolute = resolve(ROOT, OUTPUT);
if (WRITE) {
  writeFileSync(absolute, contents);
  console.log(`WROTE ${OUTPUT}`);
} else {
  if (readFileSync(absolute, "utf8") !== contents) throw new Error(`Generated drift: ${OUTPUT}`);
  console.log(`PASS ${OUTPUT}`);
}
console.log(
  `PASS Building 1 detached registry: ${FIELD_RUNS.length} runs / ${round(fieldLength, 6)} m / ${round(fieldArea, 6)} m2, two fit studies, zero actual placements`,
);
