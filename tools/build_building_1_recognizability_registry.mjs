import { createHash } from "node:crypto";
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const WRITE = process.argv.includes("--write");
const OUTPUT = "game/resources/facades/building_1_recognizability_placements.json";
const CHUNK = "generated/world/chunks/x_-1__z_2.json";
const STANDALONE = "game/resources/facades/building_1_standalone_prototypes.json";
const STANDALONE_FACTORY = "game/scripts/world/facades/building_1_standalone_prototypes.gd";
const BRIEF = "discovery/facades/TREASURE_ISLAND_BUILDING_1_RECOGNIZABILITY_PLACEMENT_BRIEF.md";
const DECISION_LOG = "discovery/DECISION_LOG.md";
const FIELD_REVIEW = "discovery/facades/TREASURE_ISLAND_BUILDING_1_LIVE_IVORY_FIELD_ART_REVIEW.md";
const RUN_MAPPING = "discovery/facades/TREASURE_ISLAND_BUILDING_1_RUN_OWNERSHIP.json";
const FIELD_MATERIAL = "game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres";
const FIELD_SHADER = "game/resources/materials/world/building_1/building_1_chain_metres_aperiodic_field.gdshader";
const WALL_OFFSET_M = 0.075;
const FIELD_OFFSET_M = 0.018;

const readJson = (path) => JSON.parse(readFileSync(resolve(ROOT, path), "utf8"));
const sha256 = (path) => createHash("sha256").update(readFileSync(resolve(ROOT, path))).digest("hex");
const round = (value, digits = 6) => {
  const power = 10 ** digits;
  return Math.round((value + Number.EPSILON) * power) / power;
};
const sub = (a, b) => a.map((value, index) => value - b[index]);
const cross = (a, b) => [
  a[1] * b[2] - a[2] * b[1],
  a[2] * b[0] - a[0] * b[2],
  a[0] * b[1] - a[1] * b[0],
];
const magnitude = (value) => Math.hypot(...value);
const triangleArea = (a, b, c) => magnitude(cross(sub(b, a), sub(c, a))) / 2;

const chunk = readJson(CHUNK);
const standalone = readJson(STANDALONE);
const record = chunk.records.find((item) => item.object_key === "building:r16681702:wall");
if (!record || record.vertices.length !== 1320 || record.indices.length !== 660) {
  throw new Error("Building 1 generated receiver drifted");
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
  const rawNormal = record.normals.slice(offset, offset + 3);
  const normalLength = Math.hypot(rawNormal[0], rawNormal[2]);
  const normal = [rawNormal[0] / normalLength, 0, rawNormal[2] / normalLength];
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
    tangent,
    normal,
  };
}

const moduleById = new Map(standalone.modules.map((item) => [item.motif_id, item]));
const protectedRuns = [
  57,
  59,
  61,
  ...Array.from({ length: 31 }, (_, index) => index + 62),
  ...Array.from({ length: 13 }, (_, index) => index + 97),
];
const fieldChains = [
  { scope_id: "B1-IVORY-PUBLIC-WRAP", runs: [93, 94, 95, 96, ...Array.from({ length: 57 }, (_, i) => i)] },
  { scope_id: "B1-IVORY-PUBLIC-SOUTH-58", runs: [58] },
  { scope_id: "B1-IVORY-PUBLIC-SOUTH-60", runs: [60] },
].map((scope) => {
  const frames = scope.runs.map(frame);
  return {
    scope_id: scope.scope_id,
    field_id: "B1-MAT-IVORY",
    asset_kind: "homogeneous_material_tile",
    exact_ordered_runs: scope.runs,
    run_count: scope.runs.length,
    physical_length_m: round(frames.reduce((sum, item) => sum + item.length_m, 0)),
    generated_mesh_surface_area_m2: round(frames.reduce((sum, item) => sum + item.surface_area_m2, 0)),
    overlay_offset_m: FIELD_OFFSET_M,
    join_geometry: "shared_xz_mitered_offset_junctions",
    internal_join_count: Math.max(0, scope.runs.length - 1),
    maximum_join_phase_delta_m: 0,
    uv_contract: "UV.x cumulative ordered chain metres; UV.y source world Y metres",
    lifecycle_status: scope.runs.every((run) => run >= 21 && run <= 51)
      ? "independently_accepted_live"
      : "recognizability_composition_pending_independent_review",
  };
});

const placements = [];
function addPlacement({ id, motif, run, fraction = 0.5, height, region, side, observations, rationale }) {
  const runFrame = frame(run);
  const module = moduleById.get(motif);
  if (!module) throw new Error(`Missing module ${motif}`);
  const width = module.nominal_bounds_m[0];
  const moduleHeight = module.nominal_bounds_m[1];
  const along = runFrame.length_m * fraction;
  const horizontalMargin = Math.min(along - width / 2, runFrame.length_m - along - width / 2);
  const baseY = runFrame.start[1] + (runFrame.end[1] - runFrame.start[1]) * fraction;
  const topY = runFrame.top_start[1] + (runFrame.top_end[1] - runFrame.top_start[1]) * fraction;
  const wallHeight = topY - baseY;
  const verticalMargin = Math.min(height - moduleHeight / 2, wallHeight - height - moduleHeight / 2);
  if (horizontalMargin < 0.05 || verticalMargin < 0.05) {
    throw new Error(`${id} escapes nominal receiver containment`);
  }
  const wallAnchor = runFrame.start.map(
    (value, index) => value + (runFrame.end[index] - value) * fraction,
  );
  const origin = [
    wallAnchor[0] + runFrame.normal[0] * WALL_OFFSET_M,
    baseY + height,
    wallAnchor[2] + runFrame.normal[2] * WALL_OFFSET_M,
  ];
  placements.push({
    placement_id: id,
    motif_id: motif,
    asset_kind: "module_atlas",
    complete_motif: true,
    exact_ordered_runs: [run],
    anchor_run: run,
    along_run_center_m: round(along, 9),
    along_run_fraction: fraction,
    center_height_above_base_m: height,
    nominal_bounds_m: module.nominal_bounds_m,
    selected_scale: [1, 1, 1],
    wall_offset_m: WALL_OFFSET_M,
    wall_anchor_world_m: wallAnchor.map((value) => round(value, 6)),
    expected_module_origin_world_m: origin.map((value) => round(value, 6)),
    tangent_world_xz: [round(runFrame.tangent[0], 9), round(runFrame.tangent[2], 9)],
    outward_normal_world_xz: [round(runFrame.normal[0], 9), round(runFrame.normal[2], 9)],
    host_run_length_m: round(runFrame.length_m),
    host_wall_height_m: round(wallHeight),
    nominal_horizontal_containment_margin_m: round(horizontalMargin, 9),
    nominal_vertical_containment_margin_m: round(verticalMargin, 9),
    side,
    region,
    observation_ids: observations,
    evidence_status: "recognizable_reference_derived_production_inference",
    selection_rationale: rationale,
    placement_lifecycle: "pending_independent_recognizability_review",
    reversible: true,
    surveyed_dimensions: false,
    surveyed_scale: false,
    surveyed_coordinates: false,
    surveyed_count: false,
    surveyed_cadence: false,
    surveyed_sequence: false,
    completed_elevation: false,
    whole_building_accepted: false,
  });
}

for (const run of [9, 13, 16, 20]) {
  addPlacement({ id: `REC-WING-R${String(run).padStart(2, "0")}-LOW`, motif: "B1-WING-W", run, height: 6.5, region: "PUBLIC-NORTH-LINK-CANDIDATE", side: "public wing/link", observations: ["B1-SV01", "B1-SV02"], rationale: "two-level wing-window rhythm at nominal reviewed scale" });
  addPlacement({ id: `REC-WING-R${String(run).padStart(2, "0")}-HIGH`, motif: "B1-WING-W", run, height: 14.0, region: "PUBLIC-NORTH-LINK-CANDIDATE", side: "public wing/link", observations: ["B1-SV01", "B1-SV02"], rationale: "two-level wing-window rhythm at nominal reviewed scale" });
}

for (const run of [21, 22, 24, 26, 28, 33, 35, 36, 44, 46, 49, 51]) {
  for (const [column, fraction] of [["A", 0.3], ["B", 0.7]]) {
    addPlacement({ id: `REC-CENTRAL-R${String(run).padStart(2, "0")}-${column}`, motif: "B1-CENTRAL-W", run, fraction, height: 10.5, region: "PUBLIC-CURVE-CONFIRMED", side: "outer public curve", observations: ["B1-SV01", "B1-SV02", "B1-SV03"], rationale: "dense tall-window cluster separated by retained plain ivory piers" });
  }
}

addPlacement({ id: "REC-PAV-NORTH-R93", motif: "B1-PAV-W", run: 93, height: 10.0, region: "PUBLIC-NORTH-END-CANDIDATE", side: "north/end public face", observations: ["B1-SV01", "B1-SV02"], rationale: "one dominant complete pavilion group at the mapped north end" });
addPlacement({ id: "REC-PAV-SOUTH-R60", motif: "B1-PAV-W", run: 60, height: 10.0, region: "PUBLIC-SOUTH-END-OBSERVED-FACES", side: "south/end observed face", observations: ["B1-SV03"], rationale: "one dominant complete pavilion group at the mapped south end" });

for (const [run, fractions] of [[94, [0.2, 0.5, 0.8]], [96, [0.2, 0.5, 0.8]]]) {
  fractions.forEach((fraction, index) => addPlacement({ id: `REC-BASE-R${run}-${index + 1}`, motif: "B1-BASE-O", run, fraction, height: 1.2, region: "PUBLIC-NORTH-END-CANDIDATE", side: "north-view public base", observations: ["B1-SV01", "B1-SV02"], rationale: "small opaque base-opening rhythm; window-versus-vent semantics unresolved" }));
}

addPlacement({ id: "REC-DOOR-BLUE-R06", motif: "B1-DOOR-BLUE", run: 6, fraction: 0.73, height: 1.45, region: "PUBLIC-NORTH-END-CANDIDATE", side: "north-view public service face", observations: ["B1-SV02"], rationale: "isolated personnel/utility door, explicitly not the main entrance" });

for (const [run, height] of [[9, 3.45], [52, 3.45], [56, 3.45], [58, 3.45]]) {
  addPlacement({ id: `REC-BAND-R${String(run).padStart(2, "0")}`, motif: "B1-BAND", run, height, region: run <= 51 ? "PUBLIC-NORTH-LINK-CANDIDATE" : "PUBLIC-SOUTH-END-OBSERVED-FACES", side: run <= 51 ? "public wing/link" : "south/end observed face", observations: run <= 51 ? ["B1-SV01", "B1-SV02"] : ["B1-SV03"], rationale: "finite muted-rose organizing accent with finished terminals, not a continuous belt" });
}

const topologyByMotif = Object.fromEntries(
  [...moduleById.entries()].map(([id, module]) => [id, module.prototype_topology]),
);
const motifCounts = Object.fromEntries([...moduleById.keys()].map((id) => [id, placements.filter((item) => item.motif_id === id).length]));
const moduleMeshes = placements.reduce((sum, item) => sum + topologyByMotif[item.motif_id].mesh_instances, 0);
const moduleSurfaces = placements.reduce((sum, item) => sum + topologyByMotif[item.motif_id].surfaces, 0);
const moduleTriangles = placements.reduce((sum, item) => sum + topologyByMotif[item.motif_id].triangles, 0);
const eligibleRuns = [...Array.from({ length: 57 }, (_, i) => i), 58, 60, 93, 94, 95, 96];
const eligibleFrames = eligibleRuns.map(frame);

const registry = {
  schema_version: "1.0.0",
  registry_id: "TREASURE-ISLAND-BUILDING-1-RECOGNIZABILITY-COMPOSITION-01",
  target: {
    human_name: "1939 World's Fair Pan Am / Treasure Island Administration Building 1",
    source_key: "r16681702",
    receiver_key: "building:r16681702:wall",
    receiver_kind: "building_wall",
    generated_wall_run_count: 110,
    outer_ring_runs: [0, 96],
    protected_sliver_runs: [97, 99],
    protected_inner_ring_runs: [100, 109],
    separate_protected_tower_source_key: "w1222720021",
    receiver_topology: { vertices: 440, triangles: 220, collider_face_vertices: 660 },
  },
  authority: {
    placement_brief_path: BRIEF,
    placement_brief_sha256: sha256(BRIEF),
    decision_log_path: DECISION_LOG,
    decision_log_sha256: sha256(DECISION_LOG),
    accepted_live_field_review_path: FIELD_REVIEW,
    accepted_live_field_review_sha256: sha256(FIELD_REVIEW),
    run_mapping_path: RUN_MAPPING,
    run_mapping_sha256: sha256(RUN_MAPPING),
    standalone_registry_path: STANDALONE,
    standalone_registry_sha256: sha256(STANDALONE),
    standalone_factory_path: STANDALONE_FACTORY,
    standalone_factory_sha256: sha256(STANDALONE_FACTORY),
    generated_chunk_path: CHUNK,
    generated_chunk_sha256: sha256(CHUNK),
    field_material_path: FIELD_MATERIAL,
    field_material_sha256: sha256(FIELD_MATERIAL),
    field_shader_path: FIELD_SHADER,
    field_shader_sha256: sha256(FIELD_SHADER),
  },
  truth_boundary: {
    role: "recognizable_reference_derived_production_inference",
    goal: "ordinary_third_person_recognizability_not_surveyed_reconstruction",
    reversible: true,
    as_built_fidelity_claimed: false,
    surveyed_dimensions: false,
    surveyed_scale: false,
    surveyed_coordinates: false,
    surveyed_count: false,
    surveyed_cadence: false,
    surveyed_sequence: false,
    completed_elevation: false,
    whole_building_accepted: false,
  },
  field_composition: {
    field_id: "B1-MAT-IVORY",
    asset_kind: "homogeneous_material_tile",
    exact_eligible_runs: eligibleRuns,
    run_count: eligibleRuns.length,
    physical_length_m: round(eligibleFrames.reduce((sum, item) => sum + item.length_m, 0)),
    generated_mesh_surface_area_m2: round(eligibleFrames.reduce((sum, item) => sum + item.surface_area_m2, 0)),
    render_chains: fieldChains,
    independently_accepted_prior_scope: {
      exact_ordered_runs: Array.from({ length: 31 }, (_, index) => index + 21),
      run_count: 31,
      physical_length_m: 85.939934,
      generated_mesh_surface_area_m2: 1740.731069,
      verdict: "KEEP_WITH_DOCUMENTED_LIMITATION",
      review_sha256: sha256(FIELD_REVIEW),
    },
    recognizability_extension_runs_pending_review: eligibleRuns.filter((run) => run < 21 || run > 51),
    overlay_offset_m: FIELD_OFFSET_M,
    maximum_join_phase_delta_m: 0,
    material_scale_status: "reviewed_reversible_world_metre_projection_not_surveyed",
  },
  placements,
  placement_summary: {
    placement_count: placements.length,
    motif_instance_counts: motifCounts,
    module_meshes: moduleMeshes,
    module_surfaces: moduleSurfaces,
    module_triangles: moduleTriangles,
    module_field_or_backing_meshes: 0,
    module_collision_nodes: 0,
    module_navigation_nodes: 0,
    module_spray_nodes: 0,
  },
  live_render_topology: {
    field_meshes: fieldChains.length,
    field_surfaces: fieldChains.length,
    field_triangles: eligibleRuns.length * 2,
    module_placements: placements.length,
    module_meshes: moduleMeshes,
    module_surfaces: moduleSurfaces,
    module_triangles: moduleTriangles,
    total_meshes: fieldChains.length + moduleMeshes,
    total_surfaces: fieldChains.length + moduleSurfaces,
    total_triangles: eligibleRuns.length * 2 + moduleTriangles,
    collision_nodes: 0,
    navigation_nodes: 0,
    spray_nodes: 0,
  },
  protected_scope: {
    protected_runs: protectedRuns,
    protected_geometry: ["runs_57_59_61", "runs_62_92", "runs_97_109", "inner_ring", "w1222720021_tower", "entrance_canopy_emblems", "massing_roof_source_geometry", "collision_navigation_spray_terrain_generated_data", "other_buildings", "r133351"],
  },
  lifecycle: {
    accepted_field_scope_count: 1,
    accepted_field_run_count: 31,
    pending_recognizability_field_extension_run_count: eligibleRuns.length - 31,
    pending_recognizability_module_placement_count: placements.length,
    composition_status: "pending_independent_recognizability_art_review",
  },
};

const serialized = `${JSON.stringify(registry, null, 2)}\n`;
if (WRITE) writeFileSync(resolve(ROOT, OUTPUT), serialized);
else process.stdout.write(serialized);
