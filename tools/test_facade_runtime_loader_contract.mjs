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
  "building:w34313545:wall",
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
const ACTIVE_REVIEW_STATUS_SCOPE = "runtime_asset_original_detail_provenance_only_not_reference_recognition";
const ACTIVE_RECOGNITION_ACCEPTANCE_AUTHORITY = "physical_unit_claim_and_independent_acceptance_record";
const PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "pre_b201_integration_live_parity";
const CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "current_integration_topology";
const ACTIVE_UNIT_BY_RECEIVER = new Map([
  ["building-composite:w1249412094:w1282547787:wall", "physical-building:w1249412094"],
  ["building:r16681702:wall", "physical-building:r16681702"],
  ["building:w1222720021:wall", "physical-building:w1222720021"],
  ["building:w291189336:wall", "physical-building:w291189336"],
  ["building:w34313540:wall", "physical-building:w34313540"],
  ["building:w34313545:wall", "physical-building:w34313545"],
]);
const ACTIVE_REVIEW_STATUS_BY_RECEIVER = new Map([
  ["building-composite:w1249412094:w1282547787:wall", "independent_exact_current_live_pass"],
  ["building:r16681702:wall", "pending_independent_original_detail_review"],
  ["building:w1222720021:wall", "pending_independent_original_detail_review"],
  ["building:w291189336:wall", "independent_exact_current_live_pass"],
  ["building:w34313540:wall", "pending_independent_original_detail_review"],
  ["building:w34313545:wall", "independent_exact_current_live_pass"],
]);

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
  let thrown = null;
  try {
    callback();
  } catch (error) {
    thrown = error;
  }
  assert(thrown !== null, `accepted ${label}`);
  assert(String(thrown.message).includes(expectedText), `${label} returned unexpected error: ${thrown.message}`);
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

assert(catalog.schema_version === CATALOG_SCHEMA, "catalog schema is not exact-current version-pinned");
assert(CATALOG_SCHEMA === "ti.facade-recognition-catalog/7" && RUNTIME_SCHEMA === "ti.facade-runtime-registry/7" && ADAPTER_CONTRACT_SCHEMA === "ti.facade-runtime-adapter-contracts/6" && LOADER_API_VERSION === "ti.facade-runtime-registry-loader/6" && COMPILER_VERSION === "1.6.0", "D1 B201 promotion version matrix drifted");
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
assert(!inputs.runtimeContracts.worldBuilderText.includes("facade_runtime_registry_loader"), "generic facade registry loader was wired into world construction");

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

for (const adapter of registry.active_runtime_adapters) {
  const unit = registry.units.find((candidate) => candidate.unit_id === ACTIVE_UNIT_BY_RECEIVER.get(adapter.receiver_key));
  assert(unit != null && unit.direct_receivers.some((receiver) => receiver.receiver_key === adapter.receiver_key), `${adapter.adapter_id} does not cross-link to its exact physical recognition unit`);
  assert(adapter.review_status === ACTIVE_REVIEW_STATUS_BY_RECEIVER.get(adapter.receiver_key), `${adapter.adapter_id} review status is not an exact allowed provenance literal`);
  assert(adapter.review_status_scope === ACTIVE_REVIEW_STATUS_SCOPE, `${adapter.adapter_id} review-status scope is ambiguous`);
  assert(adapter.recognition_acceptance_authority === ACTIVE_RECOGNITION_ACCEPTANCE_AUTHORITY, `${adapter.adapter_id} recognition authority drifted`);
  assert(adapter.recognition_acceptance_status === unit.claim_status.reference_recognizable && adapter.recognition_acceptance_status === "accepted", `${adapter.adapter_id} recognition status is not derived from its accepted physical unit`);
  assert(unit.acceptance_records.some((record) => record.review_kind === "independent_reference_recognition" && record.status === "accept"), `${adapter.adapter_id} physical unit lacks an independent recognition acceptance receipt`);
}

assert(JSON.stringify(adapterContracts.counts) === JSON.stringify(EXPECTED_ADAPTER_CONTRACTS), "adapter contract counts drifted");
assert(adapterContracts.plans.length === EXPECTED.runtime_adapter_receivers, "adapter contract does not cover 15 receiver plans");
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

let negativeControlRejected = false;
try {
  expectFailure(() => {}, "unreachable", "no-op negative control");
} catch (error) {
  negativeControlRejected = String(error.message).includes("accepted no-op negative control");
}
assert(negativeControlRejected, "failure harness did not reject a passing/no-op callback");

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

for (const receiverKey of ["building:r16681702:wall", "building:w1222720021:wall"]) {
  const plan = readyPlans.find((candidate) => candidate.receiver_key === receiverKey);
  assert(plan.runtime_assets.length === 11, `${receiverKey} runtime closure is not exactly 11 assets`);
  assert(plan.runtime_assets.some((asset) => asset.path === "res://game/resources/facades/building_1_public_front_believability.json" && asset.sha256 === "7b53847c627d6f0a0d4ebefcc790e8fd3bcaeee6fbdebbf5c6a85f2aeb4a5806"), `${receiverKey} omits the exact current public-front runtime config`);
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
  "physical-building:w34313545",
].sort();
assert(registry.recognition_metric.numerator === 7 && registry.recognition_metric.denominator === 213 && registry.recognition_metric.display === "7/213", "runtime recognition metric is not exactly 7/213");
assert(JSON.stringify(registry.recognition_metric.accepted_physical_unit_ids) === JSON.stringify(acceptedUnitIds), "runtime accepted physical-unit set drifted");
assert(JSON.stringify(registry.recognition_metric.isle_house_non_numerator_source_keys) === JSON.stringify(["w1282547786", "w1282547787"]), "Isle House source parts entered the physical-unit numerator");
const islePlan = disabledPlans.find((plan) => plan.receiver_key === "building-composite:w1249412094:w1282547787:wall");
assert(islePlan.content_mode === "active_isle_house_variant_c" && islePlan.runtime_assets.length === 1 && islePlan.projection_descriptor_ids.length === 3, "Isle House plan does not preserve its active content mode and fail-closed package boundary");
assert(islePlan.behavior_contract.acceptance_contract.independent_live_review_receipt_sha256 === "37b6c7dbf6c8769b13628e1070a9c3b5beeb9b25bbe63f0f12f9aaa00c22dab8", "Isle House plan acceptance receipt drifted");
assert(islePlan.behavior_contract.geometry_contract.live_signature === "09eee1517f043c6d82f0de0d2275da5b2a3f76f5842d1b9c90cba11e6e793981" && islePlan.behavior_contract.geometry_contract.overlay_repair_signature === "41868b77a8b51b56ee7381e5549423e97547270d2dc77d9ce5cf958b31e2cb69", "Isle House plan signatures drifted");
assert(islePlan.behavior_contract.geometry_contract.world_topology_scope === PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE && islePlan.behavior_contract.geometry_contract.world_records === 735 && islePlan.behavior_contract.geometry_contract.world_mesh_instances === 944 && islePlan.behavior_contract.geometry_contract.world_surfaces === 957 && islePlan.behavior_contract.geometry_contract.world_triangles === 64572 && islePlan.behavior_contract.geometry_contract.world_static_bodies === 466 && islePlan.behavior_contract.geometry_contract.world_shapes === 466, "Isle House pre-B201 integration world topology parity drifted");
const navyChapelPlan = readyPlans.find((plan) => plan.receiver_key === "building:w291189336:wall");
const navyChapelRuntimePaths = navyChapelPlan.runtime_assets.map((asset) => asset.path).sort();
assert(navyChapelPlan.content_mode === "active_navy_chapel_187_paired_replacement", "Navy Chapel ready plan has stale legacy content mode");
assert(navyChapelRuntimePaths.length === 9 && navyChapelRuntimePaths.includes("res://game/scripts/world/facades/navy_chapel_187_live_replacement.gd") && navyChapelRuntimePaths.includes("res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd") && navyChapelRuntimePaths.includes("res://game/resources/facades/navy_chapel_187_standalone_hero_prototype.json"), "Navy Chapel ready plan dependency set is incomplete");
assert(navyChapelPlan.behavior_contract.acceptance_contract.independent_live_review_receipt_sha256 === "63bd6c5a79db837e3b53b60eea36887cee8c4c66af791715f964f023b926b5a9" && navyChapelPlan.behavior_contract.acceptance_contract.numerator_effect === 1 && navyChapelPlan.behavior_contract.acceptance_contract.wall_and_roof_are_one_physical_unit === true, "Navy Chapel acceptance receipt or one-unit rollup drifted");
assert(navyChapelPlan.behavior_contract.geometry_contract.world_topology_scope === PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE && navyChapelPlan.behavior_contract.geometry_contract.visual_geometry_signature === "076e081df86e884f04cf7cb680304c35c64e6f76238de7060528c59097ae5c46" && navyChapelPlan.behavior_contract.geometry_contract.visual_triangles === 540 && navyChapelPlan.behavior_contract.geometry_contract.world_records === 735 && navyChapelPlan.behavior_contract.geometry_contract.world_mesh_instances === 944 && navyChapelPlan.behavior_contract.geometry_contract.world_surfaces === 957 && navyChapelPlan.behavior_contract.geometry_contract.world_triangles === 64572 && navyChapelPlan.behavior_contract.geometry_contract.world_static_bodies === 466 && navyChapelPlan.behavior_contract.geometry_contract.world_shapes === 466, "Navy Chapel pre-B201 integration geometry/world parity drifted");
assert(navyChapelPlan.behavior_contract.ownership_contract.live_ownership_signature === "4766c5d562933eb632f1ef3bdcec828fc40be81c996db919c53405f776fa04a7" && navyChapelPlan.behavior_contract.ownership_contract.structural_owner_count === 2 && navyChapelPlan.behavior_contract.ownership_contract.shape_count === 2 && navyChapelPlan.behavior_contract.ownership_contract.spray_owner_count === 1 && navyChapelPlan.behavior_contract.ownership_contract.wall_collision_triangles === 94 && navyChapelPlan.behavior_contract.ownership_contract.roof_collision_triangles === 50 && navyChapelPlan.behavior_contract.ownership_contract.wall_is_sole_spray_receiver === true && navyChapelPlan.behavior_contract.ownership_contract.roof_is_wall_spray_receiver === false, "Navy Chapel collision/spray ownership parity drifted");
const d1B201Plan = readyPlans.find((plan) => plan.receiver_key === "building:w34313545:wall");
const d1B201RuntimePaths = d1B201Plan.runtime_assets.map((asset) => asset.path).sort();
const expectedD1B201RuntimePaths = [
  "res://game/resources/facades/d1_current/d1_b201_live_attachment.json",
  "res://game/resources/materials/world/d1_current/b201_green_hierarchy.tres",
  "res://game/resources/materials/world/d1_current/b201_muted_rust_post.tres",
  "res://game/resources/materials/world/d1_current/b201_service_leaf.tres",
  "res://game/resources/materials/world/d1_current/b201_warm_wall.tres",
  "res://game/resources/materials/world/d1_current/shared_dark_glass.tres",
  "res://game/resources/materials/world/d1_current/shared_pale_frame.tres",
  "res://game/scripts/world/facades/d1_b201_live_attachment.gd",
].sort();
assert(d1B201Plan.content_mode === "active_d1_b201_host_partition_attachment", "D1 B201 ready plan has stale content mode");
assert(JSON.stringify(d1B201RuntimePaths) === JSON.stringify(expectedD1B201RuntimePaths) && d1B201Plan.projection_descriptor_ids.length === 0, "D1 B201 ready plan does not contain its exact eight-asset package-safe closure");
assert(d1B201Plan.executable_assets.length === 1 && d1B201Plan.executable_assets[0].path === "res://game/scripts/world/facades/d1_b201_live_attachment.gd", "D1 B201 executable subset drifted");
assert(d1B201Plan.behavior_contract.acceptance_contract.independent_live_review_receipt_sha256 === "b9ef912df2dd00fa2c456a8e7e03473001cc381cbc2dd5288e9f6ef65d8c2772" && d1B201Plan.behavior_contract.acceptance_contract.evidence_manifest_sha256 === "f169085620a0a9ff0c685e4dfa98442c5c31e4e580f1decdbd80e84b09c74fe3" && d1B201Plan.behavior_contract.acceptance_contract.numerator_effect === 1, "D1 B201 receipt or one-unit rollup drifted");
assert(d1B201Plan.behavior_contract.geometry_contract.decorative_geometry_signature === "705c5345509f77cd91359f66173fff0e1e132d41ebb9acef3f51ff2c467abb3a" && d1B201Plan.behavior_contract.geometry_contract.host_triangles === 80 && d1B201Plan.behavior_contract.geometry_contract.eligible_host_triangles === 20 && d1B201Plan.behavior_contract.geometry_contract.protected_host_triangles === 60 && d1B201Plan.behavior_contract.geometry_contract.decorative_triangles === 2064, "D1 B201 host partition or decorative geometry parity drifted");
assert(d1B201Plan.behavior_contract.geometry_contract.world_topology_scope === CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE && d1B201Plan.behavior_contract.geometry_contract.world_records === 735 && d1B201Plan.behavior_contract.geometry_contract.world_mesh_instances === 950 && d1B201Plan.behavior_contract.geometry_contract.world_surfaces === 964 && d1B201Plan.behavior_contract.geometry_contract.world_triangles === 66636 && d1B201Plan.behavior_contract.geometry_contract.world_static_bodies === 466 && d1B201Plan.behavior_contract.geometry_contract.world_shapes === 466, "D1 B201 current-integration world topology drifted");
assert(d1B201Plan.behavior_contract.ownership_contract.host_collision_owner_preserved === true && d1B201Plan.behavior_contract.ownership_contract.host_spray_owner_preserved === true && d1B201Plan.behavior_contract.ownership_contract.structural_owner_count === 1 && d1B201Plan.behavior_contract.ownership_contract.shape_count === 1 && d1B201Plan.behavior_contract.ownership_contract.spray_owner_count === 1 && d1B201Plan.behavior_contract.ownership_contract.decorative_collision_nodes === 0 && d1B201Plan.behavior_contract.ownership_contract.decorative_navigation_nodes === 0 && d1B201Plan.behavior_contract.ownership_contract.decorative_spray_nodes === 0, "D1 B201 collision/navigation/spray ownership parity drifted");

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
  const candidate = structuredClone(registry);
  candidate.schema_version = "ti.facade-runtime-registry/6";
  candidate.build_contract.compiler_version = "1.5.0";
  candidate.compatibility_contract.catalog_schema_version = "ti.facade-recognition-catalog/6";
  candidate.compatibility_contract.compiler_version = "1.5.0";
  candidate.compatibility_contract.loader_api_version = "ti.facade-runtime-registry-loader/5";
  validateRuntimeRegistry(candidate, adapterContracts);
}, "unknown or forward-incompatible", "newly superseded runtime registry version 6");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  candidate.schema_version = "ti.facade-runtime-adapter-contracts/999";
  validateAdapterContracts(candidate, registry);
}, "unknown or forward-incompatible", "future adapter-contract version");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  candidate.schema_version = "ti.facade-runtime-adapter-contracts/5";
  candidate.build_contract.compiler_version = "1.5.0";
  candidate.build_contract.runtime_registry_schema_version = "ti.facade-runtime-registry/6";
  candidate.loader_contract.api_version = "ti.facade-runtime-registry-loader/5";
  validateAdapterContracts(candidate, registry);
}, "unknown or forward-incompatible", "newly superseded adapter-contract version 5");
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
  candidate.recognition_metric.numerator = 8;
  candidate.recognition_metric.display = "8/213";
  validateRuntimeRegistry(candidate, adapterContracts);
}, "Runtime physical-entity recognition metric drifted from exactly 7/213", "drifted recognition numerator");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:r16681702:wall");
  adapter.review_status_scope = "reference_recognition_pending";
  validateRuntimeRegistry(candidate, adapterContracts);
}, "review status scope does not isolate runtime-asset original-detail provenance", "same-version active-adapter review-status scope mutation");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:r16681702:wall");
  adapter.recognition_acceptance_authority = "runtime_adapter_self_assertion";
  validateRuntimeRegistry(candidate, adapterContracts);
}, "recognition authority does not belong to the physical-unit claim and independent receipt", "same-version active-adapter recognition authority mutation");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:r16681702:wall");
  adapter.recognition_acceptance_status = "not_evaluated";
  validateRuntimeRegistry(candidate, adapterContracts);
}, "recognition acceptance status does not equal its accepted physical-unit claim", "same-version active-adapter duplicated recognition status mutation");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const unit = candidate.units.find((item) => item.unit_id === "physical-building:r16681702");
  unit.acceptance_records = [];
  validateRuntimeRegistry(candidate, adapterContracts);
}, "physical recognition unit lacks an independent acceptance receipt", "same-version active-unit missing acceptance receipt");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const unit = candidate.units.find((item) => item.unit_id === "physical-building:r16681702");
  unit.acceptance_records[0].status = "reject";
  validateRuntimeRegistry(candidate, adapterContracts);
}, "physical recognition unit lacks an independent acceptance receipt", "same-version active-unit non-accept receipt");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const geometry = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building-composite:w1249412094:w1282547787:wall").active_runtime_contract.behavior_contract.geometry_contract;
  const original = geometry.world_topology_scope;
  geometry.world_topology_scope = CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE;
  assert(geometry.world_topology_scope !== original, "Isle House topology-scope mutation was a no-op");
  validateRuntimeRegistry(candidate, adapterContracts);
}, "Active Isle House low receiver acceptance, dependency, or behavior parity contract drifted", "same-version Isle House topology-scope mutation");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const geometry = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w291189336:wall").active_runtime_contract.behavior_contract.geometry_contract;
  const original = geometry.world_topology_scope;
  geometry.world_topology_scope = CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE;
  assert(geometry.world_topology_scope !== original, "Navy Chapel topology-scope mutation was a no-op");
  validateRuntimeRegistry(candidate, adapterContracts);
}, "Active Navy Chapel acceptance, paired dependency, or ownership parity contract drifted", "same-version Navy Chapel topology-scope mutation");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const geometry = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w34313545:wall").active_runtime_contract.behavior_contract.geometry_contract;
  const original = geometry.world_topology_scope;
  geometry.world_topology_scope = PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE;
  assert(geometry.world_topology_scope !== original, "D1 B201 topology-scope mutation was a no-op");
  validateRuntimeRegistry(candidate, adapterContracts);
}, "Active D1 B201 acceptance, dependency, host-partition, or ownership parity contract drifted", "same-version D1 B201 topology-scope mutation");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  const geometry = candidate.plans.find((item) => item.receiver_key === "building-composite:w1249412094:w1282547787:wall").behavior_contract.geometry_contract;
  const original = geometry.world_topology_scope;
  geometry.world_topology_scope = CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE;
  assert(original === PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE && geometry.world_topology_scope !== original, "Isle House plan topology-scope mutation was a no-op");
  validateAdapterContracts(candidate);
}, "Isle House pre-B201 integration live parity contract drifted", "same-version Isle House plan topology-scope mutation");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  const geometry = candidate.plans.find((item) => item.receiver_key === "building:w291189336:wall").behavior_contract.geometry_contract;
  const original = geometry.world_topology_scope;
  geometry.world_topology_scope = CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE;
  assert(original === PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE && geometry.world_topology_scope !== original, "Navy Chapel plan topology-scope mutation was a no-op");
  validateAdapterContracts(candidate);
}, "Navy Chapel pre-B201 integration live parity contract drifted", "same-version Navy Chapel plan topology-scope mutation");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  const geometry = candidate.plans.find((item) => item.receiver_key === "building:w34313545:wall").behavior_contract.geometry_contract;
  const original = geometry.world_topology_scope;
  geometry.world_topology_scope = PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE;
  assert(original === CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE && geometry.world_topology_scope !== original, "D1 B201 plan topology-scope mutation was a no-op");
  validateAdapterContracts(candidate);
}, "D1 B201 exact-current acceptance/parity contract drifted", "same-version D1 B201 plan topology-scope mutation");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w34313545:wall");
  adapter.active_receiver_scope.coverage = "eligible_runs_only";
  validateRuntimeRegistry(candidate, adapterContracts);
}, "Active D1 B201 acceptance, dependency, host-partition, or ownership parity contract drifted", "same-version D1 B201 active receiver coverage mutation");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w34313545:wall");
  adapter.active_receiver_scope.run_count = 39;
  validateRuntimeRegistry(candidate, adapterContracts);
}, "Active D1 B201 acceptance, dependency, host-partition, or ownership parity contract drifted", "same-version D1 B201 active receiver run-count mutation");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  const plan = candidate.plans.find((item) => item.receiver_key === "building:w34313545:wall");
  plan.behavior_contract.ownership_contract.decorative_spray_nodes = 1;
  validateAdapterContracts(candidate);
}, "D1 B201 exact-current acceptance/parity contract drifted", "same-version D1 B201 ownership mutation");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const main = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:r16681702:wall");
  const tower = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w1222720021:wall");
  [main.source_key, tower.source_key] = [tower.source_key, main.source_key];
  validateRuntimeRegistry(candidate, adapterContracts);
}, "receiver/source mapping, or exact 11-asset closure drifted", "Building 1/tower source swap");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:r16681702:wall");
  const target = adapter.runtime_assets.findIndex((asset) => asset.path.endsWith("building_1_bronze.tres"));
  adapter.runtime_assets[target] = structuredClone(adapter.runtime_assets.find((asset) => asset.path.endsWith("building_1_bluegrey_glass.tres")));
  validateRuntimeRegistry(candidate, adapterContracts);
}, "receiver/source mapping, or exact 11-asset closure drifted", "Building 1 non-public asset substitution");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  const plan = candidate.plans.find((item) => item.receiver_key === "building-composite:w1249412094:w1282547787:wall");
  plan.behavior_contract.ownership_contract.decorative_spray_nodes = 1;
  validateAdapterContracts(candidate);
}, "Isle House pre-B201 integration live parity contract drifted", "drifted Isle House ownership parity");
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
}, "Navy Chapel pre-B201 integration live parity contract drifted", "drifted Navy Chapel collision ownership parity");

console.log(
  `PASS facade runtime loader contract: ${EXPECTED.recognition_units} units / ${EXPECTED.direct_wall_receivers} receivers / ${adapterContracts.plans.length} plans / ${readyPlans.length} package-safe / ${disabledPlans.length} hard-disabled receivers / ${adapterContracts.projection_descriptors.length} pathless projection inputs; registry ${sha256File(PATHS.registry)}; adapter contracts ${sha256File(PATHS.adapterContracts)}`,
);
