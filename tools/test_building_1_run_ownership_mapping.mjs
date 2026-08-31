import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const readJson = (path) => JSON.parse(readFileSync(resolve(ROOT, path), "utf8"));
const sha256 = (path) =>
  createHash("sha256").update(readFileSync(resolve(ROOT, path))).digest("hex");
const assert = (condition, message) => {
  if (!condition) throw new Error(message);
};
const range = (first, last) =>
  Array.from({ length: last - first + 1 }, (_, index) => first + index);

const mappingPath = "discovery/facades/TREASURE_ISLAND_BUILDING_1_RUN_OWNERSHIP.json";
const mapping = readJson(mappingPath);
const chunk = readJson("generated/world/chunks/x_-1__z_2.json");
const towerChunk = readJson("generated/world/chunks/x_0__z_2.json");
const wall = chunk.records.find((record) => record.object_key === "building:r16681702:wall");
const tower = towerChunk.records.find(
  (record) => record.object_key === "building:w1222720021:wall",
);

assert(mapping.schema_version === "ti.building-1-run-ownership/1", "schema drift");
assert(mapping.receiver_key === "building:r16681702:wall", "receiver drift");
assert(mapping.runtime_attachment === false, "mapping must remain detached");
assert(mapping.exact_module_placement_count === 0, "mapping must contain no placements");
assert(wall && wall.vertices.length === 1320, "expected frozen 110-run Building 1 wall");
assert(tower && tower.vertices.length === 120, "expected separate 10-run tower wall");
assert(mapping.exact_runs.length === 110, "mapping must contain all 110 exact runs");

const partition = mapping.run_regions.flatMap((region) => region.ordered_runs);
assert(partition.length === 110, "region partition must contain 110 runs");
assert(new Set(partition).size === 110, "region partition must not duplicate runs");
assert(
  [...partition].sort((a, b) => a - b).every((run, index) => run === index),
  "region partition must cover ordered runs 0..109 exactly",
);

for (const exact of mapping.exact_runs) {
  const offset = exact.run * 12;
  assert(
    exact.start_xz_m[0] === wall.vertices[offset] &&
      exact.start_xz_m[1] === wall.vertices[offset + 2] &&
      exact.end_xz_m[0] === wall.vertices[offset + 3] &&
      exact.end_xz_m[1] === wall.vertices[offset + 5],
    `run ${exact.run} endpoint drift`,
  );
  const expectedOwnership =
    exact.run <= 96
      ? "main_outer_component"
      : exact.run <= 99
        ? "secondary_outer_union_sliver"
        : "inner_ring_tower_hole";
  assert(exact.ring_ownership === expectedOwnership, `run ${exact.run} ownership drift`);
}

assert(
  mapping.facts.main_outer_component.run_count === 97 &&
    mapping.facts.main_outer_component.closed_endpoint_chain,
  "main outer component contract drift",
);
assert(
  mapping.facts.secondary_outer_union_sliver.run_count === 3 &&
    mapping.facts.secondary_outer_union_sliver.closed_endpoint_chain &&
    mapping.facts.secondary_outer_union_sliver.signed_plan_area_m2 === 0.0561,
  "secondary outer sliver contract drift",
);
assert(
  mapping.facts.inner_ring_component.run_count === 10 &&
    mapping.facts.inner_ring_component.closed_endpoint_chain,
  "inner ring contract drift",
);
assert(
  JSON.stringify(
    mapping.facts.inner_to_separate_tower_reversed_run_matches.map((item) => [
      item.inner_run,
      item.separate_tower_run,
    ]),
  ) ===
    JSON.stringify(range(0, 9).map((index) => [100 + index, 9 - index])),
  "inner ring must reverse the separate tower run order exactly",
);

const assets = new Map(
  mapping.asset_family_eligibility.map((asset) => [asset.asset_id, asset]),
);
assert(assets.size === 7, "expected exactly seven standalone family mappings");
assert(
  JSON.stringify(mapping.detached_calibration_gate.authorized_assets) ===
    JSON.stringify(["B1-MAT-IVORY", "B1-CENTRAL-W", "B1-PAV-W"]),
  "partial detached authorization drift",
);
assert(
  JSON.stringify(mapping.detached_calibration_gate.blocked_assets) ===
    JSON.stringify(["B1-WING-W", "B1-BASE-O", "B1-DOOR-BLUE", "B1-BAND"]),
  "blocked asset list drift",
);
for (const id of mapping.detached_calibration_gate.blocked_assets) {
  assert(assets.get(id).eligible_runs.length === 0, `${id} must not gain an eligible run`);
  assert(assets.get(id).blocker, `${id} must retain its exact blocker`);
}
assert(
  assets.get("B1-CENTRAL-W").exact_anchor_authorized_by_this_mapping === false &&
    assets.get("B1-PAV-W").exact_anchor_authorized_by_this_mapping === false,
  "region mapping must not authorize module anchors",
);

for (const [pinName, pin] of Object.entries(mapping.source_pins)) {
  assert(sha256(pin.path) === pin.sha256, `${pinName} source pin drift`);
}
assert(
  mapping.source_pins.chunk.sha256 ===
    "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce",
  "generated Building 1 chunk changed",
);
assert(
  mapping.source_pins.prototypes.sha256 ===
    "2014040edb3985be4aaae437749063474aacaedc0534b6d54e69b7dfd92612cc",
  "accepted standalone registry bytes changed",
);

console.log(
  `PASS Building 1 exact run ownership: ${mapping.exact_runs.length} runs, outer main/sliver 97/3, inner 10, partial detached gate 3 authorized / 4 blocked, zero placements`,
);
