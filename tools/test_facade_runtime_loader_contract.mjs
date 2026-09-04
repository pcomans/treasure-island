import { createHash } from "node:crypto";
import { existsSync, readFileSync, statSync } from "node:fs";
import { dirname, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";

import { stableJson } from "./lib/world-contract.mjs";
import {
  ADAPTER_CONTRACT_SCHEMA,
  CATALOG_SCHEMA,
  COMPILER_VERSION,
  EXPECTED,
  EXPECTED_ADAPTER_CONTRACTS,
  LOADER_API_VERSION,
  PATHS,
  RUNTIME_SCHEMA,
  compile,
  inspectRuntimeAssetClosure,
  loadInputs,
  validateAdapterContracts,
  validateRuntimeRegistry,
} from "./build_facade_recognition_registry.mjs";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const READY_RECEIVERS = [
  "building-composite:w1249412094:w1282547786:wall",
  "building:r16681702:wall",
  "building:w1222720021:wall",
  "building:w1249412093:wall",
  "building:w291189336:wall",
  "building:w291189926:wall",
  "building:w34313540:wall",
  "building:w34313547:wall",
].sort();
const DISABLED_RECEIVERS = [
  "building-composite:w1249412094:w1282547787:wall",
  "building:w291196370:wall",
  "building:w34313515:wall",
  "building:w34313520:wall",
  "building:w34313525:wall",
  "building:w34313564:wall",
].sort();

function absolute(relativePath) {
  const result = resolve(ROOT, relativePath);
  assert(result === ROOT || result.startsWith(`${ROOT}${sep}`), `path escapes project: ${relativePath}`);
  return result;
}

function readJson(relativePath) {
  return JSON.parse(readFileSync(absolute(relativePath), "utf8"));
}

function sha256Bytes(value) {
  return createHash("sha256").update(value).digest("hex");
}

function sha256File(relativePath) {
  return sha256Bytes(readFileSync(absolute(relativePath)));
}

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

function assertUnique(values, label) {
  assert(new Set(values).size === values.length, `${label} contains duplicates`);
}

function expectFailure(callback, expectedText, label) {
  try {
    callback();
    assert(false, `accepted ${label}`);
  } catch (error) {
    assert(String(error.message).includes(expectedText), `${label} returned unexpected error: ${error.message}`);
  }
}

function assertPackageBoundary(value, label = "adapter contracts") {
  if (typeof value === "string") {
    assert(!value.includes("discovery/"), `${label} leaks a discovery path`);
    assert(!value.includes("evidence/"), `${label} leaks an evidence path`);
    assert(!value.includes("/Users/") && !value.includes("/Volumes/"), `${label} leaks an absolute path`);
    assert(!value.includes("http://") && !value.includes("https://"), `${label} leaks a URL`);
    return;
  }
  if (Array.isArray(value)) {
    value.forEach((child, index) => assertPackageBoundary(child, `${label}[${index}]`));
    return;
  }
  if (value != null && typeof value === "object") {
    Object.entries(value).forEach(([key, child]) => assertPackageBoundary(child, `${label}.${key}`));
  }
}

const inputs = loadInputs();
const catalog = readJson(PATHS.catalog);
const registry = readJson(PATHS.registry);
const adapterContracts = readJson(PATHS.adapterContracts);
const report = readJson(PATHS.report);
const compiledFirst = compile(catalog, inputs);
const compiledSecond = compile(catalog, inputs);

assert(catalog.schema_version === CATALOG_SCHEMA, "catalog schema is not Phase 1.5 version-pinned");
assert(catalog.compiler_contract.required_compiler_version === COMPILER_VERSION, "catalog compiler version pin drifted");
assert(catalog.compiler_contract.emitted_runtime_schema_version === RUNTIME_SCHEMA, "catalog runtime version pin drifted");
assert(catalog.compiler_contract.unknown_version_policy === "reject", "catalog does not reject unknown forward versions");
assert(registry.schema_version === RUNTIME_SCHEMA, "runtime registry schema version drifted");
assert(registry.compatibility_contract.loader_api_version === LOADER_API_VERSION, "runtime loader API version drifted");
assert(registry.compatibility_contract.forward_compatible === false && registry.compatibility_contract.unknown_version_policy === "reject", "runtime registry does not reject forward versions");
assert(adapterContracts.schema_version === ADAPTER_CONTRACT_SCHEMA, "adapter contract schema version drifted");
assert(adapterContracts.loader_contract.api_version === LOADER_API_VERSION, "adapter contract loader version drifted");
assert(adapterContracts.loader_contract.loader_path === "res://game/scripts/world/facades/facade_runtime_registry_loader.gd", "adapter contract loader path drifted");
assert(adapterContracts.loader_contract.loader_sha256 === sha256File("game/scripts/world/facades/facade_runtime_registry_loader.gd"), "adapter contract loader hash drifted");
assert(adapterContracts.loader_contract.instantiation_authorized === false, "adapter contract unexpectedly authorizes instantiation");
assert(adapterContracts.loader_contract.projection_execution_policy === "forbidden", "adapter contract permits projection execution");

validateAdapterContracts(adapterContracts, registry);
validateRuntimeRegistry(registry, adapterContracts);
assert(stableJson(compiledFirst.adapterContracts) === stableJson(adapterContracts), "checked-in adapter contracts differ from a clean compile");
assert(stableJson(compiledFirst.registry) === stableJson(registry), "checked-in runtime registry differs from a clean compile");
assert(stableJson(compiledFirst.adapterContracts) === stableJson(compiledSecond.adapterContracts), "two clean adapter-contract compiles are not byte-identical");
assert(stableJson(compiledFirst.registry) === stableJson(compiledSecond.registry), "two clean registry compiles are not byte-identical");
assert(registry.adapter_contract.path === `res://${PATHS.adapterContracts}`, "registry adapter-contract path drifted");
assert(registry.adapter_contract.sha256 === sha256File(PATHS.adapterContracts), "registry adapter-contract hash drifted");
assert(report.input_hashes.adapter_contracts_sha256 === sha256File(PATHS.adapterContracts), "validation report adapter-contract hash drifted");
assert(report.input_hashes.facade_runtime_loader_sha256 === sha256File("game/scripts/world/facades/facade_runtime_registry_loader.gd"), "validation report loader hash drifted");

assert(JSON.stringify(adapterContracts.counts) === JSON.stringify(EXPECTED_ADAPTER_CONTRACTS), "adapter contract counts drifted");
assert(adapterContracts.plans.length === EXPECTED.runtime_adapter_receivers, "adapter contract does not cover 14 receiver plans");
const readyPlans = adapterContracts.plans.filter((plan) => plan.integration_state === "package_safe_ready_for_integration");
const disabledPlans = adapterContracts.plans.filter((plan) => plan.integration_state === "hard_disabled_source_projection");
assert(JSON.stringify(readyPlans.map((plan) => plan.receiver_key).sort()) === JSON.stringify(READY_RECEIVERS), "package-safe receiver set drifted");
assert(JSON.stringify(disabledPlans.map((plan) => plan.receiver_key).sort()) === JSON.stringify(DISABLED_RECEIVERS), "hard-disabled receiver set drifted");
assert(disabledPlans.every((plan) => plan.executable_assets.length === 0 && plan.resolution_policy === "deny_all_executable_resolution"), "a disabled plan exposes executable resolution");

assert(adapterContracts.projection_descriptors.length === EXPECTED_ADAPTER_CONTRACTS.disabled_unique_projection_inputs, "adapter contract does not materialize the exact disabled unique-input set");
assertUnique(adapterContracts.projection_descriptors.map((descriptor) => `${descriptor.source_asset_type}:${descriptor.source_asset_sha256}`), "pathless projection source identities");
assertUnique(adapterContracts.projection_descriptors.map((descriptor) => descriptor.descriptor_id), "pathless projection descriptor IDs");
for (const descriptor of adapterContracts.projection_descriptors) {
  assert(!Object.hasOwn(descriptor, "path"), `${descriptor.descriptor_id} leaks a source path`);
  assert(descriptor.execution_state === "hard_disabled" && descriptor.execution_policy === "never_resolve_or_execute", `${descriptor.descriptor_id} is executable`);
  assert(descriptor.disabled_reason_code === "source_bearing_dependency_closure_requires_independent_package_safe_normalization", `${descriptor.descriptor_id} lacks its exact disabled reason`);
}
assertPackageBoundary(adapterContracts);
for (const path of [
  "game/scripts/world/facades/facade_runtime_registry_loader.gd",
  PATHS.adapterContracts,
  PATHS.registry,
]) {
  const audit = inspectRuntimeAssetClosure(path);
  assert(audit.closure_clean && audit.violation_count === 0, `${path} runtime dependency closure is not package-safe`);
}

for (const plan of readyPlans) {
  for (const asset of plan.runtime_assets) {
    const relativePath = asset.path.slice("res://".length);
    assert(asset.path.startsWith("res://game/") && existsSync(absolute(relativePath)) && statSync(absolute(relativePath)).isFile(), `${plan.adapter_id} runtime asset is unavailable`);
    assert(sha256File(relativePath) === asset.sha256, `${plan.adapter_id} runtime asset hash drifted`);
  }
  for (const asset of plan.executable_assets) {
    assert(["gdscript", "packed_scene"].includes(asset.resource_kind), `${plan.adapter_id} has an unknown executable kind`);
    assert(asset.path.startsWith("res://game/scripts/world/") || asset.path.startsWith("res://game/scenes/world/"), `${plan.adapter_id} executable path escapes its allowlist`);
    assert(plan.runtime_assets.some((candidate) => candidate.path === asset.path && candidate.sha256 === asset.sha256), `${plan.adapter_id} executable asset is not a runtime-asset subset`);
  }
}

const building3Plan = readyPlans.find((plan) => plan.receiver_key === "building:w34313540:wall");
const building3RuntimePaths = building3Plan.runtime_assets.map((asset) => asset.path).sort();
assert(building3Plan.content_mode === "active_building_3_hero", "Building 3 ready plan has stale legacy content mode");
assert(building3Plan.behavior_contract.parity_status === "exact_current_behavior_and_dependency_set_verified", "Building 3 ready plan lacks exact-current parity");
assert(building3Plan.behavior_contract.replacement_contract.receiver_roles.join("|") === "wall|roof", "Building 3 plan does not replace wall and roof together");
assert(building3Plan.behavior_contract.geometry_contract.wall_triangles === 236 && building3Plan.behavior_contract.geometry_contract.roof_triangles === 675, "Building 3 plan geometry parity drifted");
assert(building3Plan.behavior_contract.collision_contract.roof_landing_world_solid === true && building3Plan.behavior_contract.collision_contract.spray_ownership === "wall_only", "Building 3 plan collision/landing/spray parity drifted");
assert(building3RuntimePaths.includes("res://game/scripts/world/massing/building_3_600_california_massing.gd") && building3RuntimePaths.includes("res://game/resources/facades/building_3_hero_massing.json") && building3RuntimePaths.length === 9, "Building 3 ready plan dependency set is incomplete");

const acceptedUnitIds = [
  "physical-building:r16681702",
  "physical-building:w1222720021",
  "physical-building:w1249412093",
  "physical-building:w1249412094",
  "physical-building:w291189336",
  "physical-building:w34313540",
].sort();
assert(registry.recognition_metric.numerator === 6 && registry.recognition_metric.denominator === 213 && registry.recognition_metric.display === "6/213", "runtime recognition metric is not exactly 6/213");
assert(JSON.stringify(registry.recognition_metric.accepted_physical_unit_ids) === JSON.stringify(acceptedUnitIds), "runtime accepted physical-unit set drifted");
assert(JSON.stringify(registry.recognition_metric.isle_house_non_numerator_source_keys) === JSON.stringify(["w1282547786", "w1282547787"]), "Isle House source parts entered the physical-unit numerator");
const islePlan = disabledPlans.find((plan) => plan.receiver_key === "building-composite:w1249412094:w1282547787:wall");
assert(islePlan.content_mode === "active_isle_house_variant_c" && islePlan.runtime_assets.length === 1 && islePlan.projection_descriptor_ids.length === 3, "Isle House plan does not preserve its active content mode and fail-closed package boundary");
assert(islePlan.behavior_contract.acceptance_contract.independent_live_review_receipt_sha256 === "37b6c7dbf6c8769b13628e1070a9c3b5beeb9b25bbe63f0f12f9aaa00c22dab8", "Isle House plan acceptance receipt drifted");
assert(islePlan.behavior_contract.geometry_contract.live_signature === "09eee1517f043c6d82f0de0d2275da5b2a3f76f5842d1b9c90cba11e6e793981" && islePlan.behavior_contract.geometry_contract.overlay_repair_signature === "41868b77a8b51b56ee7381e5549423e97547270d2dc77d9ce5cf958b31e2cb69", "Isle House plan signatures drifted");
assert(islePlan.behavior_contract.geometry_contract.world_records === 735 && islePlan.behavior_contract.geometry_contract.world_mesh_instances === 944 && islePlan.behavior_contract.geometry_contract.world_surfaces === 957 && islePlan.behavior_contract.geometry_contract.world_triangles === 64572 && islePlan.behavior_contract.geometry_contract.world_static_bodies === 466 && islePlan.behavior_contract.geometry_contract.world_shapes === 466, "Isle House exact-current world topology drifted");
const navyChapelPlan = readyPlans.find((plan) => plan.receiver_key === "building:w291189336:wall");
const navyChapelRuntimePaths = navyChapelPlan.runtime_assets.map((asset) => asset.path).sort();
assert(navyChapelPlan.content_mode === "active_navy_chapel_187_paired_replacement", "Navy Chapel ready plan has stale legacy content mode");
assert(navyChapelRuntimePaths.length === 9 && navyChapelRuntimePaths.includes("res://game/scripts/world/facades/navy_chapel_187_live_replacement.gd") && navyChapelRuntimePaths.includes("res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd") && navyChapelRuntimePaths.includes("res://game/resources/facades/navy_chapel_187_standalone_hero_prototype.json"), "Navy Chapel ready plan dependency set is incomplete");
assert(navyChapelPlan.behavior_contract.acceptance_contract.independent_live_review_receipt_sha256 === "63bd6c5a79db837e3b53b60eea36887cee8c4c66af791715f964f023b926b5a9" && navyChapelPlan.behavior_contract.acceptance_contract.numerator_effect === 1 && navyChapelPlan.behavior_contract.acceptance_contract.wall_and_roof_are_one_physical_unit === true, "Navy Chapel acceptance receipt or one-unit rollup drifted");
assert(navyChapelPlan.behavior_contract.geometry_contract.visual_geometry_signature === "076e081df86e884f04cf7cb680304c35c64e6f76238de7060528c59097ae5c46" && navyChapelPlan.behavior_contract.geometry_contract.visual_triangles === 540 && navyChapelPlan.behavior_contract.geometry_contract.world_records === 735 && navyChapelPlan.behavior_contract.geometry_contract.world_mesh_instances === 944 && navyChapelPlan.behavior_contract.geometry_contract.world_surfaces === 957 && navyChapelPlan.behavior_contract.geometry_contract.world_triangles === 64572 && navyChapelPlan.behavior_contract.geometry_contract.world_static_bodies === 466 && navyChapelPlan.behavior_contract.geometry_contract.world_shapes === 466, "Navy Chapel geometry/world parity drifted");
assert(navyChapelPlan.behavior_contract.ownership_contract.live_ownership_signature === "4766c5d562933eb632f1ef3bdcec828fc40be81c996db919c53405f776fa04a7" && navyChapelPlan.behavior_contract.ownership_contract.structural_owner_count === 2 && navyChapelPlan.behavior_contract.ownership_contract.shape_count === 2 && navyChapelPlan.behavior_contract.ownership_contract.spray_owner_count === 1 && navyChapelPlan.behavior_contract.ownership_contract.wall_collision_triangles === 94 && navyChapelPlan.behavior_contract.ownership_contract.roof_collision_triangles === 50 && navyChapelPlan.behavior_contract.ownership_contract.wall_is_sole_spray_receiver === true && navyChapelPlan.behavior_contract.ownership_contract.roof_is_wall_spray_receiver === false, "Navy Chapel collision/spray ownership parity drifted");

expectFailure(() => {
  const candidate = structuredClone(catalog);
  candidate.schema_version = "ti.facade-recognition-catalog/999";
  compile(candidate, inputs);
}, "does not equal const", "future catalog schema version");
expectFailure(() => {
  const candidate = structuredClone(catalog);
  candidate.compiler_contract.required_compiler_version = "99.0.0";
  compile(candidate, inputs);
}, "does not equal const", "future compiler version");
expectFailure(() => {
  const candidate = structuredClone(registry);
  candidate.schema_version = "ti.facade-runtime-registry/999";
  validateRuntimeRegistry(candidate, adapterContracts);
}, "unknown or forward-incompatible", "future runtime registry version");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  candidate.schema_version = "ti.facade-runtime-adapter-contracts/999";
  validateAdapterContracts(candidate, registry);
}, "unknown or forward-incompatible", "future adapter-contract version");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  candidate.projection_descriptors[0].path = "res://game/resources/facades/source-bearing.json";
  validateAdapterContracts(candidate);
}, "keys drifted", "path smuggled into a disabled projection");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  const disabled = candidate.plans.find((plan) => plan.integration_state === "hard_disabled_source_projection");
  disabled.executable_assets.push({ path: "res://game/scripts/world/facades/forbidden.gd", resource_kind: "gdscript", sha256: "0".repeat(64) });
  validateAdapterContracts(candidate);
}, "exposes executable assets while hard-disabled", "executable asset on a hard-disabled plan");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const isle = candidate.units.find((unit) => unit.unit_id === "physical-building:w1249412094");
  const low = isle.direct_receivers.find((receiver) => receiver.receiver_key.endsWith(":w1282547787:wall"));
  low.runtime_content_mode = "legacy_adapter";
  low.runtime_adapter_id = "legacy-adapter:building-composite:w1249412094:w1282547786:wall";
  validateRuntimeRegistry(candidate);
}, "Isle House low receiver is not bound to its exact active Variant C adapter", "collapsed Isle House mixed receiver state");
expectFailure(() => {
  const candidate = structuredClone(registry);
  candidate.recognition_metric.numerator = 7;
  candidate.recognition_metric.display = "7/213";
  validateRuntimeRegistry(candidate, adapterContracts);
}, "Runtime physical-entity recognition metric drifted from exactly 6/213", "drifted recognition numerator");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  const plan = candidate.plans.find((item) => item.receiver_key === "building-composite:w1249412094:w1282547787:wall");
  plan.behavior_contract.ownership_contract.decorative_spray_nodes = 1;
  validateAdapterContracts(candidate);
}, "Isle House exact-current acceptance/parity contract drifted", "drifted Isle House ownership parity");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  const plan = candidate.plans.find((item) => item.receiver_key === "building:w34313540:wall");
  plan.behavior_contract.geometry_contract.roof_triangles = 674;
  validateAdapterContracts(candidate);
}, "Building 3 behavior parity contract drifted", "drifted Building 3 wall/roof behavior parity");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  const plan = candidate.plans.find((item) => item.receiver_key === "building:w291189336:wall");
  plan.behavior_contract.ownership_contract.roof_collision_triangles = 49;
  validateAdapterContracts(candidate);
}, "Navy Chapel exact-current acceptance/parity contract drifted", "drifted Navy Chapel collision ownership parity");

console.log(
  `PASS facade runtime loader contract: ${EXPECTED.recognition_units} units / ${EXPECTED.direct_wall_receivers} receivers / ${adapterContracts.plans.length} plans / ${readyPlans.length} package-safe / ${disabledPlans.length} hard-disabled receivers / ${adapterContracts.projection_descriptors.length} pathless projection inputs; registry ${sha256File(PATHS.registry)}; adapter contracts ${sha256File(PATHS.adapterContracts)}`,
);
