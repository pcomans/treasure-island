import { createHash } from "node:crypto";
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { eastNorthToWorld, projectLonLat } from "./lib/coordinates.mjs";

const REPO_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const WRITE = process.argv.includes("--write");

const paths = {
  chunk: "generated/world/chunks/x_-1__z_2.json",
  towerChunk: "generated/world/chunks/x_0__z_2.json",
  osm: "data/osm/treasure-island-2026-08-27.osm",
  spec: "discovery/facades/TREASURE_ISLAND_MUSEUM_BUILDING_1_REFERENCE_SPEC.md",
  observations: "discovery/facades/NEXT_COHORT_STREETVIEW_OBSERVATIONS.md",
  review: "discovery/facades/TREASURE_ISLAND_BUILDING_1_STANDALONE_PROTOTYPE_ART_REVIEW.md",
  prototypes: "game/resources/facades/building_1_standalone_prototypes.json",
  mapping: "discovery/facades/TREASURE_ISLAND_BUILDING_1_RUN_OWNERSHIP.json",
  diagnostic:
    "evidence/first-playable/treasure-island-building-1-run-ownership-mapping-2026-08-30/visibility-diagnostic.json",
  plan:
    "evidence/first-playable/treasure-island-building-1-run-ownership-mapping-2026-08-30/plan-view.svg",
};

function readJson(path) {
  return JSON.parse(readFileSync(resolve(REPO_ROOT, path), "utf8"));
}

function sha256(path) {
  return createHash("sha256").update(readFileSync(resolve(REPO_ROOT, path))).digest("hex");
}

function round(value, digits = 6) {
  const power = 10 ** digits;
  return Math.round((value + Number.EPSILON) * power) / power;
}

function range(first, last) {
  return Array.from({ length: last - first + 1 }, (_, index) => first + index);
}

function complement(values) {
  const set = new Set(values);
  return range(0, 109).filter((run) => !set.has(run));
}

function cardinal16(bearing) {
  const names = [
    "N",
    "NNE",
    "NE",
    "ENE",
    "E",
    "ESE",
    "SE",
    "SSE",
    "S",
    "SSW",
    "SW",
    "WSW",
    "W",
    "WNW",
    "NW",
    "NNW",
  ];
  return names[Math.floor(((bearing + 11.25) % 360) / 22.5)];
}

function normalizedBearing(vector) {
  return ((Math.atan2(vector[0], -vector[1]) * 180) / Math.PI + 360) % 360;
}

function angularDelta(a, b) {
  return Math.abs(((a - b + 540) % 360) - 180);
}

function cross(a, b) {
  return a[0] * b[1] - a[1] * b[0];
}

function segmentBlocker(observer, target, targetRun, runs) {
  const ray = [target[0] - observer[0], target[1] - observer[1]];
  for (const run of runs) {
    if (run.run === targetRun) continue;
    const edge = [run.end[0] - run.start[0], run.end[1] - run.start[1]];
    const offset = [run.start[0] - observer[0], run.start[1] - observer[1]];
    const denominator = cross(ray, edge);
    if (Math.abs(denominator) < 1e-9) continue;
    const rayFraction = cross(offset, edge) / denominator;
    const edgeFraction = cross(offset, ray) / denominator;
    if (
      rayFraction > 1e-5 &&
      rayFraction < 0.99999 &&
      edgeFraction > -1e-6 &&
      edgeFraction < 1.000001
    ) {
      return run.run;
    }
  }
  return null;
}

function componentStats(runs, indices) {
  let perimeter = 0;
  let twiceArea = 0;
  let centroidXTimesSixArea = 0;
  let centroidZTimesSixArea = 0;
  for (const index of indices) {
    const run = runs[index];
    perimeter += run.length_m;
    const areaTerm = run.start[0] * run.end[1] - run.end[0] * run.start[1];
    twiceArea += areaTerm;
    centroidXTimesSixArea += (run.start[0] + run.end[0]) * areaTerm;
    centroidZTimesSixArea += (run.start[1] + run.end[1]) * areaTerm;
  }
  const signedArea = twiceArea / 2;
  return {
    run_count: indices.length,
    run_length_m: round(perimeter),
    signed_plan_area_m2: round(signedArea),
    centroid_xz_m: [
      round(centroidXTimesSixArea / (6 * signedArea)),
      round(centroidZTimesSixArea / (6 * signedArea)),
    ],
    closed_endpoint_chain:
      runs[indices[0]].start[0] === runs[indices.at(-1)].end[0] &&
      runs[indices[0]].start[1] === runs[indices.at(-1)].end[1],
  };
}

const chunk = readJson(paths.chunk);
const wall = chunk.records.find((record) => record.object_key === "building:r16681702:wall");
if (!wall) throw new Error("Missing building:r16681702:wall");

const towerChunk = readJson(paths.towerChunk);
const towerWall = towerChunk.records.find(
  (record) => record.object_key === "building:w1222720021:wall",
);
if (!towerWall) throw new Error("Missing separate building:w1222720021:wall");

if (wall.vertices.length !== 110 * 12 || wall.normals.length !== 110 * 12) {
  throw new Error("Building 1 wall is not the frozen 110-quad receiver");
}

const regions = [
  {
    id: "PUBLIC-NORTH-END-CANDIDATE",
    ordered_runs: [...range(93, 96), ...range(0, 8)],
    status: "reference_observation_plus_production_inference",
    side: "outer north/NW/SW end and California Avenue return",
    confidence: "medium",
    observation_ids: ["B1-SV02"],
    rationale:
      "The NW observer directly sees this cyclic end component; the ledger names the north end pavilion and north return, but does not locate individual motifs within it.",
  },
  {
    id: "PUBLIC-NORTH-LINK-CANDIDATE",
    ordered_runs: range(9, 20),
    status: "reference_observation_plus_production_inference",
    side: "outer south-facing link between north end and public curve",
    confidence: "medium-low",
    observation_ids: ["B1-SV01", "B1-SV03"],
    rationale:
      "The WSW and SW observations directly see this link, but retained notes do not disambiguate wing windows, transitions, base details, or band endpoints run by run.",
  },
  {
    id: "PUBLIC-CURVE-CONFIRMED",
    ordered_runs: range(21, 51),
    status: "verified_geometry_plus_reference_observation",
    side: "outer broad curved public/parking-lot elevation",
    confidence: "high_for_region_medium_for_internal_motif_zones",
    observation_ids: ["B1-SV01", "B1-SV02", "B1-SV03"],
    rationale:
      "The continuous curved outer chain is directly visible across the approved WSW/NW/SW views and uniquely matches the repeatedly named broad curved public elevation. The notes do not encode where its central tall-window rhythm begins or ends.",
  },
  {
    id: "PUBLIC-SOUTH-END-OBSERVED-FACES",
    ordered_runs: [52, 53, 54, 55, 56, 58, 60],
    status: "verified_geometry_plus_reference_observation",
    side: "outer south pavilion public faces",
    confidence: "medium-high_for_region_medium_for_motif_run",
    observation_ids: ["B1-SV03"],
    rationale:
      "The SW/south observation directly sees these outward faces and names the south end pavilion; no individual full-height group is tied to one run.",
  },
  {
    id: "SOUTH-END-OCCLUDED-RETURNS",
    ordered_runs: [57, 59, 61],
    status: "unknown_protected",
    side: "outer SE-facing short returns inside the south-end sawtooth",
    confidence: "high_geometry_low_appearance",
    observation_ids: [],
    rationale:
      "The approved observers are not on the outward side of these short return faces; neighboring public-face evidence must not wrap around them.",
  },
  {
    id: "REAR-EAST-UNOBSERVED",
    ordered_runs: range(62, 92),
    status: "unknown_protected",
    side: "main outer rear/east/north chain",
    confidence: "high_geometry_unknown_appearance",
    observation_ids: [],
    rationale:
      "The approved ledger explicitly leaves the east/rear outer elevation unobserved. Apparent line-of-sight to isolated north edges is not facade grammar evidence.",
  },
  {
    id: "SECONDARY-OUTER-UNION-SLIVER",
    ordered_runs: range(97, 99),
    status: "verified_geometry_ineligible",
    side: "tiny secondary generated outer component",
    confidence: "high",
    observation_ids: [],
    rationale:
      "This closed 0.0561 m2 generated outer sliver is not the observed public building elevation and cannot host a facade module. Its exact source-member causality is not used as appearance evidence.",
  },
  {
    id: "INNER-RING-TOWER-HOLE",
    ordered_runs: range(100, 109),
    status: "verified_geometry_excluded",
    side: "r16681702 inner ring facing the separate tower hole",
    confidence: "high",
    observation_ids: [],
    rationale:
      "Every endpoint reverses one run of the separately generated building:w1222720021:wall. Public-outer evidence cannot transfer to it.",
  },
];

const regionByRun = new Map();
for (const region of regions) {
  for (const run of region.ordered_runs) {
    if (regionByRun.has(run)) throw new Error(`Run ${run} belongs to two mapping regions`);
    regionByRun.set(run, region.id);
  }
}
if (regionByRun.size !== 110) throw new Error(`Mapping partitions ${regionByRun.size}, not 110, runs`);

const rawRuns = range(0, 109).map((run) => {
  const offset = run * 12;
  const start = [wall.vertices[offset], wall.vertices[offset + 2]];
  const end = [wall.vertices[offset + 3], wall.vertices[offset + 5]];
  const normal = [wall.normals[offset], wall.normals[offset + 2]];
  const delta = [end[0] - start[0], end[1] - start[1]];
  const length = Math.hypot(delta[0], delta[1]);
  const facing = normalizedBearing(normal);
  return {
    run,
    start,
    end,
    midpoint: [(start[0] + end[0]) / 2, (start[1] + end[1]) / 2],
    tangent: [delta[0] / length, delta[1] / length],
    outward_normal: normal,
    length_m: length,
    facing_azimuth_deg: facing,
    facing_cardinal_16: cardinal16(facing),
  };
});

const observations = [
  {
    id: "B1-SV01",
    panorama_id: "TpG54H0huRdII4VZxBG0TA",
    capture_display: "Sep 2025",
    latitude: 37.8169175,
    longitude: -122.3719989,
    heading_deg: 55,
    fov_deg: 75,
    observed_description:
      "wide public curved elevation, both wings in context, central tall-window rhythm",
  },
  {
    id: "B1-SV02",
    panorama_id: "_jdZk4lGHsH5qq_VmIyd7g",
    capture_display: "Sep 2025",
    latitude: 37.817523,
    longitude: -122.3720371,
    heading_deg: 105,
    fov_deg: 75,
    observed_description:
      "north end pavilion, curved return, wing windows, base openings and utility door",
  },
  {
    id: "B1-SV03",
    panorama_id: "racCKmRzOLLicCqyLct7vA",
    capture_display: "Sep 2025",
    latitude: 37.8165168,
    longitude: -122.3717125,
    heading_deg: 55,
    fov_deg: 75,
    observed_description: "south end pavilion and broad curved public elevation",
  },
].map((observation) => {
  const world = eastNorthToWorld(
    projectLonLat([observation.longitude, observation.latitude]),
    0,
  );
  return { ...observation, world_xz_m: [round(world[0], 3), round(world[2], 3)] };
});

const sampleFractions = [0.05, 0.15, 0.3, 0.5, 0.7, 0.85, 0.95];
const visibilityByRun = new Map();
for (const run of rawRuns) {
  const perObservation = {};
  for (const observation of observations) {
    const samples = sampleFractions.map((fraction) => {
      const target = [
        run.start[0] + fraction * (run.end[0] - run.start[0]),
        run.start[1] + fraction * (run.end[1] - run.start[1]),
      ];
      const targetToObserver = [
        observation.world_xz_m[0] - target[0],
        observation.world_xz_m[1] - target[1],
      ];
      const outwardSide =
        run.outward_normal[0] * targetToObserver[0] +
          run.outward_normal[1] * targetToObserver[1] >
        0;
      const targetBearing = normalizedBearing([
        target[0] - observation.world_xz_m[0],
        target[1] - observation.world_xz_m[1],
      ]);
      const inFov = angularDelta(targetBearing, observation.heading_deg) <= observation.fov_deg / 2;
      const blocker = segmentBlocker(
        observation.world_xz_m,
        target,
        run.run,
        rawRuns.slice(0, 100),
      );
      return { fraction, outward_side: outwardSide, in_fov: inFov, blocker };
    });
    perObservation[observation.id] = {
      sample_count: samples.length,
      outward_side_sample_count: samples.filter((sample) => sample.outward_side).length,
      in_fov_sample_count: samples.filter((sample) => sample.in_fov).length,
      direct_visible_sample_count: samples.filter(
        (sample) => sample.outward_side && sample.in_fov && sample.blocker === null,
      ).length,
      blocking_runs: [...new Set(samples.map((sample) => sample.blocker).filter(Number.isInteger))],
    };
  }
  visibilityByRun.set(run.run, perObservation);
}

const exactRuns = rawRuns.map((run) => ({
  run: run.run,
  ring_ownership:
    run.run <= 96
      ? "main_outer_component"
      : run.run <= 99
        ? "secondary_outer_union_sliver"
        : "inner_ring_tower_hole",
  mapping_region: regionByRun.get(run.run),
  start_xz_m: run.start.map((value) => round(value, 3)),
  end_xz_m: run.end.map((value) => round(value, 3)),
  midpoint_xz_m: run.midpoint.map((value) => round(value, 3)),
  length_m: round(run.length_m, 3),
  tangent_xz: run.tangent.map((value) => round(value)),
  outward_normal_xz: run.outward_normal.map((value) => round(value)),
  facing_azimuth_deg: round(run.facing_azimuth_deg, 1),
  facing_cardinal_16: run.facing_cardinal_16,
  visibility_diagnostic: visibilityByRun.get(run.run),
}));

const directPublicRuns = [
  ...range(0, 56),
  58,
  60,
  ...range(93, 96),
];
const centralRuns = range(21, 51);
const pavilionRuns = [...range(0, 8), 52, 53, 54, 55, 56, 58, 60, ...range(93, 96)];
const northDetailCandidates = [...range(0, 20), ...range(93, 96)];
const wingCandidates = range(9, 51);
const bandCandidates = [...range(9, 56), 58, 60];
const lengthOfRuns = (runs) =>
  round(runs.reduce((sum, run) => sum + rawRuns[run].length_m, 0), 3);

const assetEligibility = [
  {
    asset_id: "B1-MAT-IVORY",
    asset_kind: "homogeneous_material_tile",
    mapping_status: "eligible_exact_observed_public_outer_field",
    eligible_runs: directPublicRuns,
    eligible_run_count: directPublicRuns.length,
    eligible_run_length_m: lengthOfRuns(directPublicRuns),
    preferred_smallest_detached_scope_runs: centralRuns,
    preferred_smallest_detached_scope_length_m: lengthOfRuns(centralRuns),
    unresolved_runs: [57, 59, 61],
    ineligible_runs: range(62, 109),
    detached_calibration_authorized: true,
    limitation:
      "Eligibility is material ownership only. It establishes no measured field scale and no module, cadence, completed elevation, or whole-building claim.",
  },
  {
    asset_id: "B1-WING-W",
    asset_kind: "module_atlas",
    mapping_status: "reference_region_unresolved",
    eligible_runs: [],
    unresolved_candidate_runs: wingCandidates,
    unresolved_candidate_run_count: wingCandidates.length,
    unresolved_candidate_run_length_m: lengthOfRuns(wingCandidates),
    ineligible_runs: complement(wingCandidates),
    detached_calibration_authorized: false,
    blocker:
      "The notes identify wing windows and a central rhythm but do not tie the wing/central transition to a frozen endpoint; the uniform 20 m receiver mass has no independent semantic break.",
  },
  {
    asset_id: "B1-CENTRAL-W",
    asset_kind: "module_atlas",
    mapping_status: "eligible_region_anchor_unresolved",
    eligible_receiver_region_runs: centralRuns,
    eligible_receiver_region_run_count: centralRuns.length,
    eligible_receiver_region_run_length_m: lengthOfRuns(centralRuns),
    eligible_runs: [],
    ineligible_runs: complement(centralRuns),
    detached_calibration_authorized: true,
    exact_anchor_authorized_by_this_mapping: false,
    limitation:
      "The broad curved public region is exact, but the tall-window subsequence and every real opening coordinate/count/cadence remain unknown. A later detached study may choose only a sparse stylized exemplar and must identify its anchor as production inference.",
  },
  {
    asset_id: "B1-PAV-W",
    asset_kind: "module_atlas",
    mapping_status: "eligible_regions_anchor_unresolved",
    eligible_receiver_region_runs: pavilionRuns,
    eligible_receiver_region_run_count: pavilionRuns.length,
    eligible_receiver_region_run_length_m: lengthOfRuns(pavilionRuns),
    eligible_runs: [],
    ineligible_runs: complement(pavilionRuns),
    detached_calibration_authorized: true,
    exact_anchor_authorized_by_this_mapping: false,
    limitation:
      "The north and south end regions are exact, while the individual dominant-window run, adjacent openings, and real pavilion composition remain unknown. A later detached study may use at most one sparse stylized exemplar per separately justified end region.",
  },
  {
    asset_id: "B1-BASE-O",
    asset_kind: "module_atlas",
    mapping_status: "reference_region_unresolved",
    eligible_runs: [],
    unresolved_candidate_runs: northDetailCandidates,
    unresolved_candidate_run_count: northDetailCandidates.length,
    unresolved_candidate_run_length_m: lengthOfRuns(northDetailCandidates),
    ineligible_runs: complement(northDetailCandidates),
    detached_calibration_authorized: false,
    blocker:
      "B1-SV02 records base openings on the north view but does not locate them within the north end, return, or link runs; window-versus-vent semantics also remain unresolved.",
  },
  {
    asset_id: "B1-DOOR-BLUE",
    asset_kind: "module_atlas",
    mapping_status: "reference_region_unresolved",
    eligible_runs: [],
    unresolved_candidate_runs: northDetailCandidates,
    unresolved_candidate_run_count: northDetailCandidates.length,
    unresolved_candidate_run_length_m: lengthOfRuns(northDetailCandidates),
    ineligible_runs: complement(northDetailCandidates),
    detached_calibration_authorized: false,
    blocker:
      "B1-SV02 proves a complete blue utility/personnel door in the north view but supplies no endpoint-relative location within the north end, return, or link runs.",
  },
  {
    asset_id: "B1-BAND",
    asset_kind: "module_atlas",
    mapping_status: "reference_region_unresolved",
    eligible_runs: [],
    unresolved_candidate_runs: bandCandidates,
    unresolved_candidate_run_count: bandCandidates.length,
    unresolved_candidate_run_length_m: lengthOfRuns(bandCandidates),
    ineligible_runs: complement(bandCandidates),
    detached_calibration_authorized: false,
    blocker:
      "The retained observation says only that a muted rose base accent occurs on portions of the parking-lot wing; it records neither the wing/run identity nor either terminal.",
  },
];

const towerRuns = range(0, 9).map((run) => {
  const offset = run * 12;
  return {
    run,
    start: [towerWall.vertices[offset], towerWall.vertices[offset + 2]],
    end: [towerWall.vertices[offset + 3], towerWall.vertices[offset + 5]],
  };
});
const reversedTowerMatches = range(100, 109).map((innerRun) => {
  const inner = rawRuns[innerRun];
  const match = towerRuns.find(
    (towerRun) =>
      towerRun.start[0] === inner.end[0] &&
      towerRun.start[1] === inner.end[1] &&
      towerRun.end[0] === inner.start[0] &&
      towerRun.end[1] === inner.start[1],
  );
  return { inner_run: innerRun, separate_tower_run: match?.run ?? null };
});
if (reversedTowerMatches.some((match) => match.separate_tower_run === null)) {
  throw new Error("Inner ring no longer reverses the separate tower endpoints");
}

const mapping = {
  schema_version: "ti.building-1-run-ownership/1",
  generated_at: "2026-08-30",
  source_key: "r16681702",
  receiver_key: "building:r16681702:wall",
  purpose: "exact run ownership and bounded observation-to-plan reconciliation; no placement",
  runtime_attachment: false,
  exact_module_placement_count: 0,
  facts: {
    chunk: "x_-1__z_2",
    wall_height_m: 20,
    flat_base_elevation_m: wall.flat_base_elevation_m,
    top_elevation_m: wall.top_elevation_m,
    run_count: 110,
    main_outer_runs: [0, 96],
    secondary_outer_union_sliver_runs: [97, 99],
    all_outer_runs: [0, 99],
    inner_ring_runs: [100, 109],
    main_outer_component: componentStats(rawRuns, range(0, 96)),
    secondary_outer_union_sliver: componentStats(rawRuns, range(97, 99)),
    inner_ring_component: componentStats(rawRuns, range(100, 109)),
    relation_members: {
      outer: ["w1169707889", "w34313541"],
      inner: ["w1222720021"],
    },
    separate_tower_receiver: "building:w1222720021:wall",
    inner_to_separate_tower_reversed_run_matches: reversedTowerMatches,
  },
  observations: observations.map((observation) => ({
    ...observation,
    evidence_status: "reference_observation",
    reference_pixels_stored_or_copied: false,
  })),
  diagnostic_method: {
    coordinate_source: "tools/lib/coordinates.mjs projectLonLat/eastNorthToWorld",
    world_axes: "+X east,+Y up,-Z north; plan coordinates are [X,Z] metres",
    view_test:
      "Seven samples at along-run fractions 0.05,0.15,0.30,0.50,0.70,0.85,0.95; sample must be on outward side, inside recorded horizontal FOV, and not occluded by another outer run.",
    semantic_limit:
      "Plan visibility supports candidate observed segments only. Retained textual observations, not pixels, supply appearance grammar; no feature location is inferred from visibility alone.",
  },
  run_regions: regions.map((region) => ({
    ...region,
    run_count: region.ordered_runs.length,
    run_length_m: round(
      region.ordered_runs.reduce((sum, run) => sum + rawRuns[run].length_m, 0),
      3,
    ),
  })),
  asset_family_eligibility: assetEligibility,
  detached_calibration_gate: {
    status: "partially_authorized",
    authorized_assets: ["B1-MAT-IVORY", "B1-CENTRAL-W", "B1-PAV-W"],
    blocked_assets: ["B1-WING-W", "B1-BASE-O", "B1-DOOR-BLUE", "B1-BAND"],
    authorization_boundary:
      "A later detached study may calibrate the ivory field over a narrowed subset of exact eligible public runs and may test sparse CENTRAL/PAV exemplars only inside their exact candidate regions. This mapping supplies no anchor, count, cadence, sequence, scale acceptance, completed elevation, or live attachment.",
  },
  exact_runs: exactRuns,
  truth_boundary: {
    verified_facts: [
      "receiver identity, run order, endpoints, lengths, normals, ring/component ownership",
      "main outer runs 0..96, secondary generated outer union sliver 97..99, inner ring 100..109",
      "inner runs reverse the independently generated w1222720021 wall endpoints",
    ],
    reference_observations: [
      "public curve, north return/end, south pavilion, material and module-family grammar recorded in B1-SV01..03",
    ],
    production_inferences: [
      "observation-to-plan region reconciliation and future sparse calibration eligibility",
    ],
    unknown_or_blocked: [
      "real module coordinates, counts, cadence, order, sequence, story stack, field scale and exact family transitions",
      "east/rear outer appearance, short south return appearance, inner ring, separate tower, entrance/canopy and emblems",
      "complete elevation and whole-building resemblance",
    ],
  },
  source_pins: Object.fromEntries(
    ["chunk", "towerChunk", "osm", "spec", "observations", "review", "prototypes"].map(
      (key) => [key, { path: paths[key], sha256: sha256(paths[key]) }],
    ),
  ),
};

const diagnostic = {
  schema_version: "ti.building-1-run-visibility-diagnostic/1",
  source_key: mapping.source_key,
  receiver_key: mapping.receiver_key,
  evidence_role:
    "deterministic plan/visibility and ring-ownership diagnostic only; not imagery, art acceptance, module placement, or whole-building evidence",
  observations: mapping.observations,
  sample_fractions: sampleFractions,
  regions: mapping.run_regions,
  per_run: exactRuns.map((run) => ({
    run: run.run,
    ring_ownership: run.ring_ownership,
    mapping_region: run.mapping_region,
    start_xz_m: run.start_xz_m,
    end_xz_m: run.end_xz_m,
    outward_normal_xz: run.outward_normal_xz,
    visibility_diagnostic: run.visibility_diagnostic,
  })),
};

function svgPlan() {
  const width = 1400;
  const height = 980;
  const padding = 90;
  const allPoints = [
    ...rawRuns.flatMap((run) => [run.start, run.end]),
    ...observations.map((observation) => observation.world_xz_m),
  ];
  const minX = Math.min(...allPoints.map((point) => point[0])) - 4;
  const maxX = Math.max(...allPoints.map((point) => point[0])) + 4;
  const minZ = Math.min(...allPoints.map((point) => point[1])) - 4;
  const maxZ = Math.max(...allPoints.map((point) => point[1])) + 4;
  const scale = Math.min((width - padding * 2) / (maxX - minX), (height - padding * 2) / (maxZ - minZ));
  const project = (point) => [
    padding + (point[0] - minX) * scale,
    padding + (point[1] - minZ) * scale,
  ];
  const colors = {
    "PUBLIC-NORTH-END-CANDIDATE": "#3288bd",
    "PUBLIC-NORTH-LINK-CANDIDATE": "#f6a62d",
    "PUBLIC-CURVE-CONFIRMED": "#2ca25f",
    "PUBLIC-SOUTH-END-OBSERVED-FACES": "#8e63c7",
    "SOUTH-END-OCCLUDED-RETURNS": "#d95f0e",
    "REAR-EAST-UNOBSERVED": "#969696",
    "SECONDARY-OUTER-UNION-SLIVER": "#d7308f",
    "INNER-RING-TOWER-HOLE": "#d73027",
  };
  const lines = rawRuns
    .map((run) => {
      const a = project(run.start);
      const b = project(run.end);
      const color = colors[regionByRun.get(run.run)];
      const dash = run.run >= 97 ? ' stroke-dasharray="7 5"' : "";
      return `<line x1="${round(a[0], 2)}" y1="${round(a[1], 2)}" x2="${round(b[0], 2)}" y2="${round(b[1], 2)}" stroke="${color}" stroke-width="${run.run >= 100 ? 4 : 6}"${dash}/>`;
    })
    .join("\n");
  const labels = rawRuns
    .map((run) => {
      const midpoint = project(run.midpoint);
      const offset = run.run >= 100 ? 9 : 12;
      return `<text x="${round(midpoint[0] + run.outward_normal[0] * offset, 2)}" y="${round(midpoint[1] + run.outward_normal[1] * offset, 2)}" font-size="8" text-anchor="middle" fill="#111">${run.run}</text>`;
    })
    .join("\n");
  const observerMarks = observations
    .map((observation) => {
      const point = project(observation.world_xz_m);
      const length = 34;
      const headingRadians = (observation.heading_deg * Math.PI) / 180;
      const direction = [Math.sin(headingRadians), -Math.cos(headingRadians)];
      const target = [point[0] + direction[0] * length, point[1] + direction[1] * length];
      return `<g><circle cx="${round(point[0], 2)}" cy="${round(point[1], 2)}" r="7" fill="#111"/><line x1="${round(point[0], 2)}" y1="${round(point[1], 2)}" x2="${round(target[0], 2)}" y2="${round(target[1], 2)}" stroke="#111" stroke-width="3" marker-end="url(#arrow)"/><text x="${round(point[0] + 10, 2)}" y="${round(point[1] - 10, 2)}" font-size="16" font-weight="700">${observation.id} ${observation.heading_deg}°</text></g>`;
    })
    .join("\n");
  const legend = Object.entries(colors)
    .map(([id, color], index) => {
      const y = 42 + index * 20;
      return `<line x1="930" y1="${y}" x2="960" y2="${y}" stroke="${color}" stroke-width="6"/><text x="970" y="${y + 5}" font-size="13">${id}</text>`;
    })
    .join("\n");
  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">
<rect width="100%" height="100%" fill="#fbfaf6"/>
<defs><marker id="arrow" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 z" fill="#111"/></marker></defs>
<text x="40" y="38" font-size="24" font-weight="700">Building 1 exact run ownership — detached plan diagnostic</text>
<text x="40" y="62" font-size="14">World plan: +X east, +Z south. Run labels are generated order. Observer arrows use recorded headings; visibility is numeric in visibility-diagnostic.json.</text>
${lines}
${labels}
${observerMarks}
${legend}
<text x="930" y="220" font-size="13">Facts: runs 0–96 main outer; 97–99 secondary union sliver;</text>
<text x="930" y="240" font-size="13">100–109 inner ring reversing separate w1222720021 wall.</text>
<text x="930" y="270" font-size="13">This plan establishes candidate receiver regions only.</text>
<text x="930" y="290" font-size="13">It does not establish a real module anchor, count, cadence, or sequence.</text>
</svg>
`;
}

const outputs = {
  [paths.mapping]: `${JSON.stringify(mapping, null, 2)}\n`,
  [paths.diagnostic]: `${JSON.stringify(diagnostic, null, 2)}\n`,
  [paths.plan]: svgPlan(),
};

for (const [path, contents] of Object.entries(outputs)) {
  const absolute = resolve(REPO_ROOT, path);
  if (WRITE) {
    writeFileSync(absolute, contents);
    console.log(`WROTE ${path}`);
  } else {
    const current = readFileSync(absolute, "utf8");
    if (current !== contents) throw new Error(`Generated output drift: ${path}`);
    console.log(`PASS ${path}`);
  }
}

console.log(
  `PASS Building 1 mapping: ${mapping.facts.run_count} runs, ${mapping.detached_calibration_gate.authorized_assets.length} partially authorized assets, no placement`,
);
