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
  "building:w95934105:wall",
  "building:w95934117:wall",
  "building:w95934119:wall",
  "building:w95934144:wall",
  "building:w95934125:wall",
  "building:w764313741:wall",
  "building:w96215646:wall",
  "building:w95934123:wall",
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
const PRE_B225_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "pre_b225_integration_live_parity";
const PRE_D2_1441_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "pre_d2_1441_integration_live_parity";
const PRE_D2_1439_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "pre_d2_1439_integration_live_parity";
const PRE_D2_1444_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "pre_d2_1444_integration_live_parity";
const CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "current_integration_topology";
const ACTIVE_UNIT_BY_RECEIVER = new Map([
  ["building-composite:w1249412094:w1282547787:wall", "physical-building:w1249412094"],
  ["building:r16681702:wall", "physical-building:r16681702"],
  ["building:w1222720021:wall", "physical-building:w1222720021"],
  ["building:w291189336:wall", "physical-building:w291189336"],
  ["building:w34313540:wall", "physical-building:w34313540"],
  ["building:w34313545:wall", "physical-building:w34313545"],
  ["building:w95934105:wall", "physical-building:w95934105"],
  ["building:w95934119:wall", "physical-building:w95934119"],
  ["building:w95934144:wall", "physical-building:w95934144"],
  ["building:w95934117:wall", "physical-building:w95934117"],
  ["building:w95934125:wall", "physical-building:w95934125"],
  ["building:w764313741:wall", "physical-building:w764313741"],
  ["building:w96215646:wall", "physical-building:w96215646"],
  ["building:w95934123:wall", "physical-building:w95934123"],
]);
const ACTIVE_REVIEW_STATUS_BY_RECEIVER = new Map([
  ["building-composite:w1249412094:w1282547787:wall", "independent_exact_current_live_pass"],
  ["building:r16681702:wall", "pending_independent_original_detail_review"],
  ["building:w1222720021:wall", "pending_independent_original_detail_review"],
  ["building:w291189336:wall", "independent_exact_current_live_pass"],
  ["building:w34313540:wall", "pending_independent_original_detail_review"],
  ["building:w34313545:wall", "independent_exact_current_live_pass"],
  ["building:w95934105:wall", "independent_exact_current_live_pass"],
  ["building:w95934119:wall", "independent_exact_current_live_pass"],
  ["building:w95934144:wall", "independent_exact_current_live_pass"],
  ["building:w95934117:wall", "independent_exact_current_live_pass"],
  ["building:w95934125:wall", "independent_exact_current_live_pass"],
  ["building:w764313741:wall", "independent_exact_current_live_pass"],
  ["building:w96215646:wall", "independent_exact_current_live_pass"],
  ["building:w95934123:wall", "independent_exact_current_live_pass"],
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
assert(CATALOG_SCHEMA === "ti.facade-recognition-catalog/15" && RUNTIME_SCHEMA === "ti.facade-runtime-registry/15" && ADAPTER_CONTRACT_SCHEMA === "ti.facade-runtime-adapter-contracts/14" && LOADER_API_VERSION === "ti.facade-runtime-registry-loader/14" && COMPILER_VERSION === "1.14.0", "D2 1441 promotion version matrix drifted");
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
assert(adapterContracts.plans.length === EXPECTED.runtime_adapter_receivers, "adapter contract does not cover 23 receiver plans");
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
  assert(plan.runtime_assets.some((asset) => asset.path === "res://game/resources/facades/building_1_public_front_believability.json" && asset.sha256 === "99117e1af118592db1d1cfa932b44014862cb8be4f47d0b3ea519e24f9e591fb"), `${receiverKey} omits the exact current public-front runtime config`);
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
  "physical-building:w95934105",
  "physical-building:w95934117",
  "physical-building:w95934119",
  "physical-building:w95934144",
  "physical-building:w95934125",
  "physical-building:w764313741",
  "physical-building:w96215646",
  "physical-building:w95934123",
].sort();
assert(registry.recognition_metric.numerator === 15 && registry.recognition_metric.denominator === 213 && registry.recognition_metric.display === "15/213", "runtime recognition metric is not exactly 15/213");
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
assert(d1B201Plan.behavior_contract.geometry_contract.world_topology_scope === PRE_B225_INTEGRATION_WORLD_TOPOLOGY_SCOPE && d1B201Plan.behavior_contract.geometry_contract.world_records === 735 && d1B201Plan.behavior_contract.geometry_contract.world_mesh_instances === 950 && d1B201Plan.behavior_contract.geometry_contract.world_surfaces === 964 && d1B201Plan.behavior_contract.geometry_contract.world_triangles === 66636 && d1B201Plan.behavior_contract.geometry_contract.world_static_bodies === 466 && d1B201Plan.behavior_contract.geometry_contract.world_shapes === 466, "D1 B201 pre-B225 integration world topology drifted");
assert(d1B201Plan.behavior_contract.ownership_contract.host_collision_owner_preserved === true && d1B201Plan.behavior_contract.ownership_contract.host_spray_owner_preserved === true && d1B201Plan.behavior_contract.ownership_contract.structural_owner_count === 1 && d1B201Plan.behavior_contract.ownership_contract.shape_count === 1 && d1B201Plan.behavior_contract.ownership_contract.spray_owner_count === 1 && d1B201Plan.behavior_contract.ownership_contract.decorative_collision_nodes === 0 && d1B201Plan.behavior_contract.ownership_contract.decorative_navigation_nodes === 0 && d1B201Plan.behavior_contract.ownership_contract.decorative_spray_nodes === 0, "D1 B201 collision/navigation/spray ownership parity drifted");
const d1B225Plan = readyPlans.find((plan) => plan.receiver_key === "building:w95934119:wall");
const d1B225RuntimePaths = d1B225Plan.runtime_assets.map((asset) => asset.path).sort();
const expectedD1B225RuntimePaths = [
  "res://game/resources/facades/d1_current/d1_b225_live_attachment.json",
  "res://game/resources/materials/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_v1.tres",
  "res://game/resources/materials/world/d1_current/shared_dark_glass.tres",
  "res://game/resources/materials/world/d1_current/shared_pale_frame.tres",
  "res://game/resources/textures/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_albedo_v1.png",
  "res://game/scripts/world/facades/d1_b225_live_attachment.gd",
].sort();
assert(d1B225Plan.content_mode === "active_d1_b225_host_partition_attachment", "D1 B225 ready plan has stale content mode");
assert(JSON.stringify(d1B225RuntimePaths) === JSON.stringify(expectedD1B225RuntimePaths) && d1B225Plan.projection_descriptor_ids.length === 0, "D1 B225 ready plan does not contain its exact six-asset package-safe closure");
assert(d1B225Plan.executable_assets.length === 1 && d1B225Plan.executable_assets[0].path === "res://game/scripts/world/facades/d1_b225_live_attachment.gd" && d1B225Plan.executable_assets[0].sha256 === "4b1defd92a77b23de692437f044dfaa579fa2ee5b3dee77465ec8404f1644ac9", "D1 B225 executable subset drifted");
assert(d1B225Plan.behavior_contract.acceptance_contract.accepted_physical_unit_id === "physical-building:w95934119" && d1B225Plan.behavior_contract.acceptance_contract.capture_time_recognition_metric === "7/213" && d1B225Plan.behavior_contract.acceptance_contract.evidence_manifest_sha256 === "96c76fd99960f1345a7c56f7fc6678ac284f98cc601a3ba65ed57020491f18dc" && d1B225Plan.behavior_contract.acceptance_contract.evidence_tree_sha256 === "f42dbec489c6fda55b612aba20c99ee2233857cb60a1ce9c512d024b35d0dcb7" && d1B225Plan.behavior_contract.acceptance_contract.independent_live_review_receipt_sha256 === "87dc2b9febf7110ccd5c1eabed1a290fea5900508561298dd7cf3b6b6fcb1d95" && d1B225Plan.behavior_contract.acceptance_contract.numerator_effect === 1, "D1 B225 frozen receipt authority or one-unit rollup drifted");
assert(d1B225Plan.behavior_contract.geometry_contract.decorative_geometry_signature === "02bd8542dea7aa13041728a5244ec962fa121972db17ecf55fad03b3139fe418" && d1B225Plan.behavior_contract.geometry_contract.host_triangles === 28 && d1B225Plan.behavior_contract.geometry_contract.eligible_host_triangles === 8 && d1B225Plan.behavior_contract.geometry_contract.protected_host_triangles === 20 && d1B225Plan.behavior_contract.geometry_contract.decorative_mesh_instances === 2 && d1B225Plan.behavior_contract.geometry_contract.decorative_surfaces === 2 && d1B225Plan.behavior_contract.geometry_contract.decorative_triangles === 1080, "D1 B225 host partition or decorative geometry parity drifted");
assert(d1B225Plan.behavior_contract.geometry_contract.world_topology_scope === PRE_D2_1441_INTEGRATION_WORLD_TOPOLOGY_SCOPE && d1B225Plan.behavior_contract.geometry_contract.world_records === 735 && d1B225Plan.behavior_contract.geometry_contract.world_mesh_instances === 952 && d1B225Plan.behavior_contract.geometry_contract.world_surfaces === 967 && d1B225Plan.behavior_contract.geometry_contract.world_triangles === 67716 && d1B225Plan.behavior_contract.geometry_contract.world_static_bodies === 466 && d1B225Plan.behavior_contract.geometry_contract.world_shapes === 466, "D1 B225 pre-D2-1441 integration world topology drifted");
assert(d1B225Plan.behavior_contract.replacement_contract.eligible_run_indices.join(",") === "10,11,12,13" && d1B225Plan.behavior_contract.replacement_contract.protected_run_indices.join(",") === "0,1,2,3,4,5,6,7,8,9", "D1 B225 eligible/protected run partition drifted");
assert(d1B225Plan.behavior_contract.ownership_contract.host_collision_owner_preserved === true && d1B225Plan.behavior_contract.ownership_contract.host_spray_owner_preserved === true && d1B225Plan.behavior_contract.ownership_contract.structural_owner_count === 1 && d1B225Plan.behavior_contract.ownership_contract.shape_count === 1 && d1B225Plan.behavior_contract.ownership_contract.spray_owner_count === 1 && d1B225Plan.behavior_contract.ownership_contract.decorative_collision_nodes === 0 && d1B225Plan.behavior_contract.ownership_contract.decorative_navigation_nodes === 0 && d1B225Plan.behavior_contract.ownership_contract.decorative_spray_nodes === 0, "D1 B225 collision/navigation/spray ownership parity drifted");

const d21441Plan = readyPlans.find((plan) => plan.receiver_key === "building:w95934105:wall");
const d21441Adapter = registry.active_runtime_adapters.find((adapter) => adapter.receiver_key === "building:w95934105:wall");
const d21441Unit = registry.units.find((unit) => unit.unit_id === "physical-building:w95934105");
const expectedD21441RuntimePaths = [
  "res://game/resources/facades/d2_1441_chinook_live_replacement.json",
  "res://game/resources/facades/d2_1441_chinook_standalone_hero_prototype.json",
  "res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres",
  "res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres",
  "res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres",
  "res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres",
  "res://game/resources/materials/world/site_12_housing/site_12_void_shadow.tres",
  "res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres",
  "res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg",
  "res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png",
  "res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd",
  "res://game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd",
  "res://game/scripts/world/facades/site_12_housing_kit.gd",
].sort();
const expectedD21441ExecutablePaths = [
  "res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd",
  "res://game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd",
  "res://game/scripts/world/facades/site_12_housing_kit.gd",
].sort();
assert(d21441Plan != null && d21441Adapter != null && d21441Unit != null, "D2 1441 generated authority record is missing");
assert(d21441Plan.adapter_id === "active-adapter:d2-1441-live:building:w95934105:wall" && d21441Plan.content_mode === "active_d2_1441_paired_replacement", "D2 1441 plan identity/content mode drifted");
assert(JSON.stringify(d21441Plan.runtime_assets.map((asset) => asset.path).sort()) === JSON.stringify(expectedD21441RuntimePaths), "D2 1441 exact 13-asset runtime closure drifted");
assert(JSON.stringify(d21441Plan.executable_assets.map((asset) => asset.path).sort()) === JSON.stringify(expectedD21441ExecutablePaths) && d21441Plan.executable_assets.every((asset) => asset.resource_kind === "gdscript"), "D2 1441 exact three-script executable closure drifted");
assert(stableJson(d21441Plan.behavior_contract) === stableJson(d21441Adapter.active_runtime_contract.behavior_contract), "D2 1441 registry/plan behavior contract diverged");
const d21441Acceptance = d21441Plan.behavior_contract.acceptance_contract;
assert(d21441Acceptance.accepted_physical_unit_id === "physical-building:w95934105" && d21441Acceptance.capture_time_recognition_metric === "8/213" && d21441Acceptance.numerator_effect === 1 && d21441Acceptance.reference_recognizable === true && d21441Acceptance.wall_and_roof_are_one_physical_unit === true, "D2 1441 single-credit acceptance boundary drifted");
assert(d21441Acceptance.evidence_manifest_sha256 === "3c11ba6412da6a062d89142594c7b785bf546b5c1905dc32bdd7ce7806fd6885" && d21441Acceptance.motion_telemetry_manifest_sha256 === "21e2b60a8fee1bcfeb984ece6124684c15ae5b1be7fb8a813f18bc0c3b240fcd" && d21441Acceptance.visual_motion_manifest_sha256 === "c885f6450d3eaac4814bde83beff1bbdccea3ae992e07a62c1e9dd8fc1259cad" && d21441Acceptance.evidence_tree_sha256 === "e52d66e479f268a9e75372da111d9c93cc1972dd1fddca9a6cb29bb6e41a4a43" && d21441Acceptance.package_verification_receipt_sha256 === "cbcda89ec1e013c3406cf919d7c7e3bcefe0df7f005be1ea0e250bfbdada1061" && d21441Acceptance.mechanical_review_receipt_sha256 === "c39800b1632d1e8b5e05720d02d9499e2788aaf9ef2cf0f1bb1f2b20353b7884" && d21441Acceptance.independent_live_review_receipt_sha256 === "075dfb63e4e015cdcc2201e627da5542566d21f9d1163268f790681729ae7144", "D2 1441 seven-artifact acceptance closure drifted");
assert(d21441Unit.acceptance_records.length === 1 && d21441Unit.active_runtime_adapter_ids.length === 1 && d21441Unit.active_runtime_adapter_ids[0] === d21441Plan.adapter_id && d21441Unit.direct_receivers.length === 1 && d21441Unit.direct_receivers[0].receiver_key === "building:w95934105:wall", "D2 1441 gained duplicate credit, adapter, or receiver ownership");
const d21441Geometry = d21441Plan.behavior_contract.geometry_contract;
assert(d21441Geometry.world_topology_scope === PRE_D2_1439_INTEGRATION_WORLD_TOPOLOGY_SCOPE && d21441Geometry.world_records === 735 && d21441Geometry.world_mesh_instances === 959 && d21441Geometry.world_surfaces === 974 && d21441Geometry.world_triangles === 70692 && d21441Geometry.world_static_bodies === 466 && d21441Geometry.world_shapes === 466, "D2 1441 current-integration world topology drifted");
assert(d21441Geometry.visual_geometry_signature === "b91b373e3bb8238a6f73f05734ef48b3429ae5654eddce89b1981ee41ee89195" && d21441Geometry.canonical_wall_record_sha256 === "00f3cd8b90e7ae93f802842b59bb10274f1fc388433e5b5c6cae1f3e23f4393c" && d21441Geometry.canonical_roof_record_sha256 === "e7da0179f012e928f575ac32440e176a0f3b9651fc325a594de80ce7e3fc9d55" && d21441Geometry.horizontal_source_footprint_preserved === true && d21441Geometry.visual_mesh_instances === 9 && d21441Geometry.visual_surfaces === 9 && d21441Geometry.visual_triangles === 1578, "D2 1441 geometry identity or topology drifted");
const d21441Ownership = d21441Plan.behavior_contract.ownership_contract;
assert(d21441Ownership.live_ownership_signature === "fcad9968be3d0c9094adef5dcc9c7fabfb7cf1754f780897188a4ec362187e4d" && d21441Ownership.structural_owner_count === 2 && d21441Ownership.shape_count === 2 && d21441Ownership.spray_owner_count === 1 && d21441Ownership.wall_collision_triangles === 32 && d21441Ownership.roof_collision_triangles === 10 && d21441Ownership.decorative_relief_triangles === 1536 && d21441Ownership.decorative_collision_triangles === 0 && d21441Ownership.decorative_navigation_nodes === 0 && d21441Ownership.wall_is_sole_spray_receiver === true && d21441Ownership.roof_is_wall_spray_receiver === false && d21441Ownership.roof_world_solid_landing === true, "D2 1441 collision/navigation/spray ownership parity drifted");
const d21441Replacement = d21441Plan.behavior_contract.replacement_contract;
assert(d21441Replacement.source_key === "w95934105" && d21441Replacement.wall_object_key === "building:w95934105:wall" && d21441Replacement.roof_object_key === "building:w95934105:roof" && d21441Replacement.actual_supplied_chunk_pair_required === true && d21441Replacement.partial_pair_allowed === false && d21441Replacement.fallback_allowed === false && d21441Replacement.generic_stack_allowed === false && d21441Replacement.mapped_public_run_indices.join(",") === "10,12,13,15" && d21441Replacement.protected_run_indices.join(",") === "0,1,2,3,4,5,6,7,8,9,11,14", "D2 1441 paired replacement/run partition drifted");
assert(d21441Plan.behavior_contract.truth_boundary.capture_time_candidate_promoted === false && d21441Plan.behavior_contract.truth_boundary.capture_time_recognition_credit === false && d21441Plan.behavior_contract.truth_boundary.reference_pixels_packaged === false && d21441Plan.behavior_contract.truth_boundary.as_built_fidelity_claimed === false, "D2 1441 capture-time truth boundary was rewritten by promotion");
const d21444Plan = readyPlans.find((plan) => plan.receiver_key === "building:w95934117:wall");
const expectedD21444Behavior = {
  "acceptance_contract": {
    "accepted_physical_unit_id": "physical-building:w95934117",
    "capture_time_recognition_metric": "9/213",
    "evidence_manifest_sha256": "9f1101abb3e4d6ac54f27a8a6db7d72ccd098721d0f59e8a6f72a6aa4c1293ef",
    "evidence_tree_sha256": "6872fe9f286370de3ab11ce27124583689a7fa0c4992bb4de4f2b9e8e1073003",
    "independent_live_review_receipt_sha256": "89c301ccdf5d02b71c5f4d79eacfee55521440edfbe2c6d780cd7c1d059d72c7",
    "mechanical_review_receipt_sha256": "7e62e914074646e438bc7c88a1f15fbc71eb40bfa00a0b04acf20e22e319c205",
    "motion_telemetry_manifest_sha256": "b569a5dc8b72c99c873a85c4fbc49b701ba72647a0299a4f8e7b0ff06b7309bc",
    "numerator_effect": 1,
    "package_verification_receipt_sha256": "b738e35d58ef6e75d0c4d98ae32d6157532703984fd48730281629211fe355a4",
    "reference_recognizable": true,
    "visual_motion_manifest_sha256": "327d9980de0798d7412ea691bd656f278a5e04da383c24fdb1cb272305b29e38",
    "wall_and_roof_are_one_physical_unit": true
  },
  "geometry_contract": {
    "canonical_roof_record_sha256": "0119a96ef2f8baf3e7a66a3db952cfd34930490b86dd25bf3693472728dadae1",
    "canonical_wall_record_sha256": "5a872a7e700aec63a2c276bb28c341e3f501ac8122f51267b05fb8a620d15950",
    "horizontal_source_footprint_preserved": true,
    "topology_delta_mesh_instances": 9,
    "topology_delta_records": 0,
    "topology_delta_shapes": 1,
    "topology_delta_static_bodies": 0,
    "topology_delta_surfaces": 9,
    "topology_delta_triangles": 672,
    "visual_geometry_signature": "1dba8f84003a0818c2ddb91504f41c3437a63fe0856ade70d1c194ca1be8d141",
    "visual_mesh_instances": 11,
    "visual_surfaces": 11,
    "visual_triangles": 726,
    "world_mesh_instances": 977,
    "world_records": 735,
    "world_shapes": 468,
    "world_static_bodies": 466,
    "world_surfaces": 992,
    "world_topology_scope": "pre_d5_batch_integration_live_parity",
    "world_triangles": 71828
  },
  "ownership_contract": {
    "closed_recess_render_layer": 1,
    "decorative_collision_triangles": 0,
    "decorative_navigation_nodes": 0,
    "decorative_relief_triangles": 612,
    "eligible_exterior_collision_triangles": 64,
    "live_ownership_signature": "979910c4d53486b86db04cdf04528789f668a01c41dc27114e481c843b91b92d",
    "navigation_owner_count": 0,
    "noneligible_closed_recess_collision_triangles": 40,
    "roof_collision_triangles": 10,
    "roof_is_wall_spray_receiver": false,
    "roof_world_solid_landing": true,
    "shape_count": 3,
    "spray_owner_count": 1,
    "structural_owner_count": 2,
    "wall_collision_triangles": 104,
    "wall_decal_cull_mask": 2,
    "wall_is_sole_spray_receiver": true,
    "wall_shape_order": [
      "eligible_exterior",
      "noneligible_closed_recess"
    ]
  },
  "replacement_contract": {
    "actual_supplied_chunk_pair_required": true,
    "fallback_allowed": false,
    "generic_stack_allowed": false,
    "mapped_public_run_indices": [
      8,
      9,
      11,
      12,
      15,
      16,
      17
    ],
    "partial_pair_allowed": false,
    "protected_run_indices": [
      0,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      10,
      13,
      14,
      18,
      19,
      20,
      21
    ],
    "roof_object_key": "building:w95934117:roof",
    "source_key": "w95934117",
    "wall_object_key": "building:w95934117:wall"
  },
  "schema_version": "ti.d2-1444-production-live-parity/1",
  "truth_boundary": {
    "as_built_fidelity_claimed": false,
    "capture_time_candidate_promoted": false,
    "capture_time_recognition_credit": false,
    "game_distinctive_claimed": false,
    "receiver_complete_inferred_from_art": false,
    "reference_pixels_packaged": false,
    "unobserved_sides_protected": true,
    "unsurveyed_opening_roof_void_rail_dimensions_and_counts_are_production_inference": true
  }
};
assert(d21444Plan && stableJson(d21444Plan.behavior_contract) === stableJson(expectedD21444Behavior), "D2 1444 literal seven-binding and ownership/topology plan drifted");
assert(d21444Plan.executable_assets.length === 3 && d21444Plan.runtime_assets.length === 13, "D2 1444 exact runtime/executable closure drifted");

const currentTopologyPlans = adapterContracts.plans.filter((plan) => plan.behavior_contract?.geometry_contract?.world_topology_scope === CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE).map((plan) => plan.adapter_id);
assert(JSON.stringify(currentTopologyPlans) === JSON.stringify(["active-adapter:fire-station48-live:building:w764313741:wall"]), "Station48 is not the sole current-integration topology plan authority");

expectFailure(() => {
  const candidate = structuredClone(catalog);
  candidate.schema_version = "ti.facade-recognition-catalog/1099";
  compile(candidate, inputs);
}, "does not equal const", "future catalog schema version");
expectFailure(() => {
  const candidate = structuredClone(catalog);
  candidate.compiler_contract.required_compiler_version = "99.0.0";
  compile(candidate, inputs);
}, "does not equal const", "future compiler version");
expectFailure(() => {
  const candidate = structuredClone(registry);
  candidate.schema_version = "ti.facade-runtime-registry/1099";
  validateRuntimeRegistry(candidate, adapterContracts);
}, "unknown or forward-incompatible", "future runtime registry version");
expectFailure(() => {
  const candidate = structuredClone(registry);
  candidate.schema_version = "ti.facade-runtime-registry/8";
  candidate.build_contract.compiler_version = "1.7.0";
  candidate.compatibility_contract.catalog_schema_version = "ti.facade-recognition-catalog/8";
  candidate.compatibility_contract.compiler_version = "1.7.0";
  candidate.compatibility_contract.loader_api_version = "ti.facade-runtime-registry-loader/7";
  validateRuntimeRegistry(candidate, adapterContracts);
}, "unknown or forward-incompatible", "newly superseded runtime registry version 8");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  candidate.schema_version = "ti.facade-runtime-adapter-contracts/999";
  validateAdapterContracts(candidate, registry);
}, "unknown or forward-incompatible", "future adapter-contract version");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  candidate.schema_version = "ti.facade-runtime-adapter-contracts/7";
  candidate.build_contract.compiler_version = "1.7.0";
  candidate.build_contract.runtime_registry_schema_version = "ti.facade-runtime-registry/8";
  candidate.loader_contract.api_version = "ti.facade-runtime-registry-loader/7";
  validateAdapterContracts(candidate, registry);
}, "unknown or forward-incompatible", "newly superseded adapter-contract version 7");
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
}, "Runtime physical-entity recognition metric drifted from the accepted-unit rollup", "drifted recognition numerator");
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
  geometry.world_topology_scope = CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE;
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
  geometry.world_topology_scope = CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE;
  assert(original === PRE_B225_INTEGRATION_WORLD_TOPOLOGY_SCOPE && geometry.world_topology_scope !== original, "D1 B201 plan topology-scope mutation was a no-op");
  validateAdapterContracts(candidate);
}, "D1 B201 pre-B225 acceptance/parity contract drifted", "same-version D1 B201 plan topology-scope mutation");
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
}, "D1 B201 pre-B225 acceptance/parity contract drifted", "same-version D1 B201 ownership mutation");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w95934119:wall");
  adapter.active_receiver_scope.run_count = 13;
  validateRuntimeRegistry(candidate, adapterContracts);
}, "Active D1 B225 acceptance, dependency, host-partition, or ownership parity contract drifted", "same-version D1 B225 active receiver run-count mutation");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w95934119:wall");
  adapter.active_runtime_contract.behavior_contract.geometry_contract.world_topology_scope = PRE_B225_INTEGRATION_WORLD_TOPOLOGY_SCOPE;
  validateRuntimeRegistry(candidate, adapterContracts);
}, "Active D1 B225 acceptance, dependency, host-partition, or ownership parity contract drifted", "same-version D1 B225 current-topology scope mutation");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const unit = candidate.units.find((item) => item.unit_id === "physical-building:w95934119");
  unit.acceptance_records[0].evidence_tree_sha256 = "0".repeat(64);
  validateRuntimeRegistry(candidate, adapterContracts);
}, "evidence tree pin drifted", "same-version D1 B225 evidence-tree mutation");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  const plan = candidate.plans.find((item) => item.receiver_key === "building:w95934119:wall");
  plan.behavior_contract.geometry_contract.world_triangles = 67715;
  validateAdapterContracts(candidate);
}, "D1 B225 pre-D2 acceptance/parity contract drifted", "same-version D1 B225 plan topology mutation");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  const plan = candidate.plans.find((item) => item.receiver_key === "building:w95934119:wall");
  plan.runtime_assets.pop();
  validateAdapterContracts(candidate);
}, "executable asset is not an exact runtime-asset subset", "same-version D1 B225 runtime-closure mutation");
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

expectFailure(() => {
  const candidate = structuredClone(registry);
  const unit = candidate.units.find((item) => item.unit_id === "physical-building:w95934105");
  unit.acceptance_records[0].package_verification_receipt_sha256 = "0".repeat(64);
  validateRuntimeRegistry(candidate, adapterContracts);
}, "D2 1441 seven-artifact acceptance closure drifted", "D2 1441 package-receipt mutation");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const unit = candidate.units.find((item) => item.unit_id === "physical-building:w95934105");
  unit.acceptance_records.push(structuredClone(unit.acceptance_records[0]));
  validateRuntimeRegistry(candidate, adapterContracts);
}, "D2 1441 physical unit lacks its exact seven-artifact frozen production/review/+1 acceptance authority", "D2 1441 duplicate acceptance mutation");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w95934105:wall");
  adapter.adapter_id = "active-adapter:d2-1441-live:building:w95934105:roof";
  validateRuntimeRegistry(candidate, adapterContracts);
}, "Active D2 1441 acceptance, paired dependency, topology, or ownership parity contract drifted", "D2 1441 forged roof adapter mutation");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w95934105:wall");
  adapter.runtime_assets.pop();
  validateRuntimeRegistry(candidate, adapterContracts);
}, "Active D2 1441 exact thirteen-asset runtime closure is incomplete or source-bearing", "D2 1441 missing runtime asset mutation");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w95934105:wall");
  adapter.active_runtime_contract.behavior_contract.geometry_contract.world_topology_scope = PRE_D2_1441_INTEGRATION_WORLD_TOPOLOGY_SCOPE;
  validateRuntimeRegistry(candidate, adapterContracts);
}, "Active D2 1441 acceptance, paired dependency, topology, or ownership parity contract drifted", "D2 1441 lost current-topology scope mutation");
expectFailure(() => {
  const candidate = structuredClone(registry);
  const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w95934119:wall");
  adapter.active_runtime_contract.behavior_contract.geometry_contract.world_topology_scope = CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE;
  validateRuntimeRegistry(candidate, adapterContracts);
}, "Active D1 B225 acceptance, dependency, host-partition, or ownership parity contract drifted", "D1 B225 forged current-topology scope mutation");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  const plan = candidate.plans.find((item) => item.receiver_key === "building:w95934105:wall");
  plan.behavior_contract.acceptance_contract.mechanical_review_receipt_sha256 = "0".repeat(64);
  validateAdapterContracts(candidate);
}, "D2 1441 exact-current acceptance/parity contract drifted", "D2 1441 mechanical-review hash mutation");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  const plan = candidate.plans.find((item) => item.receiver_key === "building:w95934105:wall");
  plan.behavior_contract.geometry_contract.visual_geometry_signature = "0".repeat(64);
  validateAdapterContracts(candidate);
}, "D2 1441 exact-current acceptance/parity contract drifted", "D2 1441 geometry-signature mutation");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  const plan = candidate.plans.find((item) => item.receiver_key === "building:w95934105:wall");
  plan.behavior_contract.replacement_contract.mapped_public_run_indices.reverse();
  validateAdapterContracts(candidate);
}, "D2 1441 exact-current acceptance/parity contract drifted", "D2 1441 mapped-run reorder mutation");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  const plan = candidate.plans.find((item) => item.receiver_key === "building:w95934105:wall");
  plan.behavior_contract.ownership_contract.roof_is_wall_spray_receiver = true;
  validateAdapterContracts(candidate);
}, "D2 1441 exact-current acceptance/parity contract drifted", "D2 1441 roof spray-credit mutation");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  const plan = candidate.plans.find((item) => item.receiver_key === "building:w95934105:wall");
  plan.runtime_assets.pop();
  validateAdapterContracts(candidate);
}, "executable asset is not an exact runtime-asset subset", "D2 1441 runtime/executable closure mutation");
expectFailure(() => {
  const candidate = structuredClone(adapterContracts);
  const plan = candidate.plans.find((item) => item.receiver_key === "building:w95934105:wall");
  candidate.plans.push(structuredClone(plan));
  validateAdapterContracts(candidate);
}, "Facade runtime adapter plans do not cover 23 receivers", "D2 1441 duplicate plan mutation");

// D5 batch receipts are separate unit authorities over one immutable candidate app.
const expectedD5Batch = [
  {
    "unit_id": "physical-building:w95934123",
    "wall": "building:w95934123:wall",
    "roof": "building:w95934123:roof",
    "adapter_id": "active-adapter:d5-1308-live:building:w95934123:wall",
    "acceptance": {
      "evidence_manifest_sha256": "7c01ff32b1da4276ec330aee0d034dce4f0cbe8caa510f96d99504084cb314b5",
      "motion_telemetry_manifest_sha256": "f139576c7b45eb76774315745504992f6bd726cd698faab6b88e79f491197960",
      "visual_motion_manifest_sha256": "f0d21bb4dc14d8a12aba1fc37614e3cced7ff331521dda06a802bfc6fbd69dc9",
      "package_verification_receipt_sha256": "c892d30b9c06f280077712c2bbad710eefac67f9fa1dd4b1f92c8f07c0b329dc",
      "evidence_tree_sha256": "e17f311ea69445d8da9b4029e9d4d93fba19ea2cd2901efa2e2ec1d7dd90556a",
      "mechanical_review_receipt_sha256": "9c094ed7a52506404a6763298504b71706b75ade1f44e4cfe2ad3fb6ea81380f",
      "review_receipt_sha256": "87a2af8c5ab11082337265f53ca5fcd3aa9f0dbfdd22f97e7a8968653ad71a06",
      "capture_time_recognition_metric": "13/213",
      "numerator_effect": 0,
      "review_id": "d5-1308-fidelity-quality-candidate-2026-09-10-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.d5-1308-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "7c01ff32b1da4276ec330aee0d034dce4f0cbe8caa510f96d99504084cb314b5",
        "motion_telemetry_manifest_sha256": "f139576c7b45eb76774315745504992f6bd726cd698faab6b88e79f491197960",
        "visual_motion_manifest_sha256": "f0d21bb4dc14d8a12aba1fc37614e3cced7ff331521dda06a802bfc6fbd69dc9",
        "package_verification_receipt_sha256": "c892d30b9c06f280077712c2bbad710eefac67f9fa1dd4b1f92c8f07c0b329dc",
        "evidence_tree_sha256": "e17f311ea69445d8da9b4029e9d4d93fba19ea2cd2901efa2e2ec1d7dd90556a",
        "mechanical_review_receipt_sha256": "9c094ed7a52506404a6763298504b71706b75ade1f44e4cfe2ad3fb6ea81380f",
        "review_receipt_sha256": "87a2af8c5ab11082337265f53ca5fcd3aa9f0dbfdd22f97e7a8968653ad71a06",
        "accepted_physical_unit_id": "physical-building:w95934123",
        "capture_time_recognition_metric": "13/213",
        "numerator_effect": 0,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w95934123",
        "wall_object_key": "building:w95934123:wall",
        "roof_object_key": "building:w95934123:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": true,
        "mapped_public_run_indices": [
          0,
          1,
          2,
          3,
          5,
          7,
          8,
          9,
          10,
          11,
          12,
          13,
          14,
          17,
          18,
          19,
          20,
          21,
          27,
          32
        ],
        "protected_run_indices": [
          4,
          6,
          15,
          16,
          22,
          23,
          24,
          25,
          26,
          28,
          29,
          30,
          31,
          33
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1
      },
      "geometry_contract": {
        "source_geometry_sha256": "6028c89be31ebfd095777b86f6d5d4a9094002b7b5fd73efb2fc940f9a9f3917",
        "canonical_wall_record_sha256": "5bf75fcc75fdbc83d45a97a6a4168a439e8c31bcbc473105147f831a09458abd",
        "canonical_roof_record_sha256": "34d0a95387fc6f17a889aac602ce5e630a67b4d0d9f8b5fb6264291d674b7b00",
        "canonical_terrain_records": {
          "area:r17241151:x_-2__z_-1": "0c1ca3e7d64c4fe9c5d561a00832651fa634b7a0c3bfae9f8434fa9526c58e53",
          "land:w26767313:x_-2__z_-1": "5508f75d3cc82559353123a3af167a0bb5b375eea73b84537d38a82b595579f7"
        },
        "horizontal_source_footprint_preserved": true,
        "visual_mesh_instances": 17,
        "visual_surfaces": 17,
        "visual_triangles": 4871,
        "world_records": 735,
        "world_mesh_instances": 1006,
        "world_surfaces": 1021,
        "world_triangles": 79913,
        "world_static_bodies": 466,
        "world_shapes": 474,
        "world_topology_scope": "same_batch_combined_topology_reference",
        "capture_isolated_world_mesh_instances": 1002,
        "capture_isolated_world_surfaces": 1017,
        "capture_isolated_world_triangles": 78685,
        "capture_isolated_world_shapes": 474
      },
      "ownership_contract": {
        "structural_owner_count": 2,
        "shape_count": 6,
        "spray_owner_count": 1,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": true,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "eligible_exterior",
          "noneligible_canopy_posts",
          "noneligible_grade_pads",
          "noneligible_closed_lower"
        ],
        "eligible_exterior_collision_triangles": 68,
        "noneligible_canopy_post_collision_triangles": 240,
        "noneligible_ground_collision_triangles": 96,
        "wall_collision_triangles": 1196,
        "roof_collision_triangles": 1402,
        "roof_is_wall_spray_receiver": false,
        "roof_world_solid_landing": true,
        "eligible_render_layer": 2,
        "noneligible_render_layer": 1,
        "terrain_geometry_and_ownership_unchanged": true,
        "noneligible_closed_lower_collision_triangles": 792,
        "roof_shape_order": [
          "exact_source_roof",
          "added_public_roof"
        ],
        "roof_shape_collision_triangles": [
          22,
          1380
        ]
      },
      "truth_boundary": {
        "as_built_fidelity_claimed": false,
        "interior_modeled": false,
        "hidden_schedule_invented": false,
        "capture_time_recognition_credit": false,
        "capture_time_candidate_promoted": false,
        "reference_pixels_packaged": false,
        "receiver_complete_inferred_from_art": false,
        "game_distinctive_claimed": false,
        "unobserved_sides_protected": true,
        "unsurveyed_dimensions_and_counts_are_production_inference": true,
        "direct_continuous_outgoing_land_contact_ownership_claimed": false
      }
    },
    "runtime_asset_count": 7
  },
  {
    "unit_id": "physical-building:w96215646",
    "wall": "building:w96215646:wall",
    "roof": "building:w96215646:roof",
    "adapter_id": "active-adapter:d5-1394-live:building:w96215646:wall",
    "acceptance": {
      "evidence_manifest_sha256": "ec327adb9239a902f40fd7e2ede7afedcd19bf1869b392e9646544721eaec316",
      "motion_telemetry_manifest_sha256": "0ad7ff068f42b8230ba724d9143c9c563130de3c9d40c37837f1ed21f95ecc60",
      "visual_motion_manifest_sha256": "6a057c2b0236e90d11861499c299b723b35da37ee3590a0a154d0c3390f0b2cb",
      "package_verification_receipt_sha256": "9be91b038dc142ac84d3947ed68733c2346aa5756e4ccbb433bf0a173b8ca364",
      "evidence_tree_sha256": "464224831dfadcc4657fdb3575fc47501190ad41c44163a7dd05885284772689",
      "mechanical_review_receipt_sha256": "c2c4ee90347b458e44fda87d900a4a2031b2cf4883c16a0db1ceac0ffeec02cd",
      "review_receipt_sha256": "c7b5079a3a59847b80e201ef8107928381f9370dd74001f2675f0c68de82dbc8",
      "capture_time_recognition_metric": "13/213",
      "numerator_effect": 0,
      "review_id": "d5-1394-fidelity-quality-candidate-2026-09-10-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.d5-1394-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "ec327adb9239a902f40fd7e2ede7afedcd19bf1869b392e9646544721eaec316",
        "motion_telemetry_manifest_sha256": "0ad7ff068f42b8230ba724d9143c9c563130de3c9d40c37837f1ed21f95ecc60",
        "visual_motion_manifest_sha256": "6a057c2b0236e90d11861499c299b723b35da37ee3590a0a154d0c3390f0b2cb",
        "package_verification_receipt_sha256": "9be91b038dc142ac84d3947ed68733c2346aa5756e4ccbb433bf0a173b8ca364",
        "evidence_tree_sha256": "464224831dfadcc4657fdb3575fc47501190ad41c44163a7dd05885284772689",
        "mechanical_review_receipt_sha256": "c2c4ee90347b458e44fda87d900a4a2031b2cf4883c16a0db1ceac0ffeec02cd",
        "review_receipt_sha256": "c7b5079a3a59847b80e201ef8107928381f9370dd74001f2675f0c68de82dbc8",
        "accepted_physical_unit_id": "physical-building:w96215646",
        "capture_time_recognition_metric": "13/213",
        "numerator_effect": 0,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w96215646",
        "wall_object_key": "building:w96215646:wall",
        "roof_object_key": "building:w96215646:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": true,
        "mapped_public_run_indices": [
          1,
          2,
          3,
          4,
          15,
          16,
          17,
          18,
          20,
          21,
          22,
          23
        ],
        "protected_run_indices": [
          0,
          5,
          6,
          7,
          8,
          9,
          10,
          11,
          12,
          13,
          14,
          19
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1
      },
      "geometry_contract": {
        "source_geometry_sha256": "b0e6c7426ac41c995f96a647ff5102b4d85963d2b7a45f21ad1b81455e451220",
        "canonical_wall_record_sha256": "222fc29f2d1526d983f4653dc8ae157aa98575dbbfb16c89898827a26dc26019",
        "canonical_roof_record_sha256": "299f27cd69cc90668bdd31cb076d083ee1bf98e28b0031cdbe4e38bfd0c2cc51",
        "canonical_terrain_records": {
          "area:r17241151:x_-2__z_-3": "462c4532716ddaa63c66d0c11300771ee7eb1089c27565037fb2e148b85c5d7c",
          "land:w26767313:x_-2__z_-3": "17c60f0f623bf919bd05c0ebc4ae93c06cce0c33a5603725175f3c4754572c02"
        },
        "horizontal_source_footprint_preserved": true,
        "visual_mesh_instances": 16,
        "visual_surfaces": 16,
        "visual_triangles": 3368,
        "world_records": 735,
        "world_mesh_instances": 1006,
        "world_surfaces": 1021,
        "world_triangles": 79913,
        "world_static_bodies": 466,
        "world_shapes": 474,
        "world_topology_scope": "pre_d5_1317_integration_quality_batch_topology",
        "capture_isolated_world_mesh_instances": 997,
        "capture_isolated_world_surfaces": 1012,
        "capture_isolated_world_triangles": 77604,
        "capture_isolated_world_shapes": 472
      },
      "ownership_contract": {
        "structural_owner_count": 2,
        "shape_count": 4,
        "spray_owner_count": 1,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": true,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "eligible_exterior",
          "noneligible_canopy_posts",
          "noneligible_closed_modules"
        ],
        "eligible_exterior_collision_triangles": 48,
        "noneligible_canopy_post_collision_triangles": 204,
        "noneligible_ground_collision_triangles": 2016,
        "wall_collision_triangles": 2268,
        "roof_collision_triangles": 16,
        "roof_is_wall_spray_receiver": false,
        "roof_world_solid_landing": true,
        "eligible_render_layer": 2,
        "noneligible_render_layer": 1,
        "terrain_geometry_and_ownership_unchanged": true
      },
      "truth_boundary": {
        "as_built_fidelity_claimed": false,
        "interior_modeled": false,
        "hidden_schedule_invented": false,
        "capture_time_recognition_credit": false,
        "capture_time_candidate_promoted": false,
        "reference_pixels_packaged": false,
        "receiver_complete_inferred_from_art": false,
        "game_distinctive_claimed": false,
        "unobserved_sides_protected": true,
        "unsurveyed_dimensions_and_counts_are_production_inference": true,
        "direct_continuous_outgoing_land_contact_ownership_claimed": false
      }
    },
    "runtime_asset_count": 7
  },
  {
    "unit_id": "physical-building:w95934125",
    "wall": "building:w95934125:wall",
    "roof": "building:w95934125:roof",
    "adapter_id": "active-adapter:d5-1317-live:building:w95934125:wall",
    "acceptance": {
      "evidence_manifest_sha256": "4fcdd7f900dfadb12187f558bf0e545038d8386134ed1e7f9830810be763ddb5",
      "motion_telemetry_manifest_sha256": "a1e3d98ebacaf73c5fb985a2fa2ee4597fe4c2b334cc102c3d3ea460bf361214",
      "visual_motion_manifest_sha256": "088c0a0df84440cf2ddb35996aabc5d1b1aa5e1fcafe47217cd92dbbca08fc15",
      "package_verification_receipt_sha256": "d6041941c9ec59d6a6d8fac4cbb79964fe842cdc135baf5c7a36df3a65a2c98e",
      "evidence_tree_sha256": "18da75ad3394e86f3129449bbf113efd14d2e845acd767acba995545b3e5f6ee",
      "mechanical_review_receipt_sha256": "7cd3ef79e13c19bbb34b601338f86533b9de429d274d35e55e8e6f8fbd8afdce",
      "review_receipt_sha256": "19edda17a50fd957ec09bd9a2ea310b7f82524e717c63467d5198e2e3f9500df",
      "capture_time_recognition_metric": "13/213",
      "numerator_effect": 1,
      "review_id": "d5-1317-quality-candidate-2026-09-10-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.d5-1317-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "4fcdd7f900dfadb12187f558bf0e545038d8386134ed1e7f9830810be763ddb5",
        "motion_telemetry_manifest_sha256": "a1e3d98ebacaf73c5fb985a2fa2ee4597fe4c2b334cc102c3d3ea460bf361214",
        "visual_motion_manifest_sha256": "088c0a0df84440cf2ddb35996aabc5d1b1aa5e1fcafe47217cd92dbbca08fc15",
        "package_verification_receipt_sha256": "d6041941c9ec59d6a6d8fac4cbb79964fe842cdc135baf5c7a36df3a65a2c98e",
        "evidence_tree_sha256": "18da75ad3394e86f3129449bbf113efd14d2e845acd767acba995545b3e5f6ee",
        "mechanical_review_receipt_sha256": "7cd3ef79e13c19bbb34b601338f86533b9de429d274d35e55e8e6f8fbd8afdce",
        "review_receipt_sha256": "19edda17a50fd957ec09bd9a2ea310b7f82524e717c63467d5198e2e3f9500df",
        "accepted_physical_unit_id": "physical-building:w95934125",
        "capture_time_recognition_metric": "13/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w95934125",
        "wall_object_key": "building:w95934125:wall",
        "roof_object_key": "building:w95934125:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": true,
        "mapped_public_run_indices": [
          10,
          13,
          14,
          15,
          17,
          20,
          22,
          24,
          26,
          27,
          29,
          31
        ],
        "protected_run_indices": [
          0,
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
          9,
          11,
          12,
          16,
          18,
          19,
          21,
          23,
          25,
          28,
          30,
          32,
          33
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1
      },
      "geometry_contract": {
        "source_geometry_sha256": "48ba2658a74b4e51ab43fb07b3940a737ffa351350081063c45908e878a5bcf9",
        "canonical_wall_record_sha256": "3537997ae045f8022bbe4c6449cec82655797411e417397d15ace85fedc3a6ef",
        "canonical_roof_record_sha256": "ae444960fc7ae2d8cae3a7fa28637ecd06b9c17d691d3c69c146564d5c6874ef",
        "canonical_terrain_records": {
          "area:r17241151:x_-3__z_-2": "336bb7c5d763d853c19184da045cf4a114f25493ecf02a367ca1e0523d8bebd1",
          "area:r17241152:x_-3__z_-2": "104faf44f5234729b0411e75595abeec1888f867d0efa6a3d765aaa4f93d991e",
          "land:w26767313:x_-3__z_-2": "9ff2ddf4241136939a8dbe377679ef9f30e4c17e229b91ffbafc117c03d47c04"
        },
        "horizontal_source_footprint_preserved": true,
        "visual_mesh_instances": 14,
        "visual_surfaces": 14,
        "visual_triangles": 1938,
        "world_records": 735,
        "world_mesh_instances": 1018,
        "world_surfaces": 1033,
        "world_triangles": 81761,
        "world_static_bodies": 466,
        "world_shapes": 477,
        "world_topology_scope": "pre_station48_integration_live_parity",
        "capture_isolated_world_mesh_instances": 1005,
        "capture_isolated_world_surfaces": 1020,
        "capture_isolated_world_triangles": 78224,
        "capture_isolated_world_shapes": 475
      },
      "ownership_contract": {
        "structural_owner_count": 2,
        "shape_count": 5,
        "spray_owner_count": 1,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": true,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "eligible_source_wall",
          "noneligible_canopies_posts_braces",
          "noneligible_closed_lower_modules"
        ],
        "wall_shape_collision_triangles": [
          68,
          192,
          648
        ],
        "roof_shape_order": [
          "exact_source_roof",
          "added_public_roof"
        ],
        "roof_shape_collision_triangles": [
          22,
          108
        ],
        "eligible_exterior_collision_triangles": 68,
        "noneligible_canopy_post_collision_triangles": 192,
        "noneligible_closed_lower_collision_triangles": 648,
        "wall_collision_triangles": 908,
        "roof_collision_triangles": 130,
        "visual_ground_triangles": 36,
        "added_ground_collision_triangles": 0,
        "roof_is_wall_spray_receiver": false,
        "roof_world_solid_landing": true,
        "eligible_render_layer": 2,
        "noneligible_render_layer": 1,
        "terrain_geometry_and_ownership_unchanged": true
      },
      "truth_boundary": {
        "as_built_fidelity_claimed": false,
        "interior_modeled": false,
        "hidden_schedule_invented": false,
        "capture_time_recognition_credit": false,
        "capture_time_candidate_promoted": false,
        "reference_pixels_packaged": false,
        "receiver_complete_inferred_from_art": false,
        "game_distinctive_claimed": false,
        "unobserved_sides_protected": true,
        "unsurveyed_dimensions_and_counts_are_production_inference": true,
        "direct_continuous_outgoing_land_contact_ownership_claimed": false,
        "continuous_motion_review_claimed": false
      }
    },
    "runtime_asset_count": 8
  },
  {
    "unit_id": "physical-building:w764313741",
    "wall": "building:w764313741:wall",
    "roof": "building:w764313741:roof",
    "adapter_id": "active-adapter:fire-station48-live:building:w764313741:wall",
    "acceptance": {
      "evidence_manifest_sha256": "f68b77fa5c6e8983288ad9f9ca36a4fd827e716cc1c99877270eeceb547786b6",
      "motion_telemetry_manifest_sha256": "4e3a0ea032384bc1381468db84ae15c4ebc1eb75212a9fec20156d165414b028",
      "visual_motion_manifest_sha256": "708692fe592b56c9b18cbf5d9bbc086dadb1c053153d37afbd5c37c6a91c0a3e",
      "package_verification_receipt_sha256": "502c87a102c90ef446a1e3415b1bb6eca7050d46689c550c18609c3c9dc43b0b",
      "evidence_tree_sha256": "6e8e1a6d8ff3ee12e961d7adaa78cdc72e8aa57dbb607251d5a1361c171eb895",
      "mechanical_review_receipt_sha256": "fb4802671d8ec92d2cdff091a221fc6fe8f3d1dae6780446aa5604227f7cfed4",
      "review_receipt_sha256": "cb06367c7de02d2379c855dfe33915d8bd54b85a33666f0582e949752f9310cf",
      "capture_time_recognition_metric": "14/213",
      "numerator_effect": 1,
      "review_id": "fire-station48-quality-candidate-2026-09-11-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.fire-station48-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "f68b77fa5c6e8983288ad9f9ca36a4fd827e716cc1c99877270eeceb547786b6",
        "motion_telemetry_manifest_sha256": "4e3a0ea032384bc1381468db84ae15c4ebc1eb75212a9fec20156d165414b028",
        "visual_motion_manifest_sha256": "708692fe592b56c9b18cbf5d9bbc086dadb1c053153d37afbd5c37c6a91c0a3e",
        "package_verification_receipt_sha256": "502c87a102c90ef446a1e3415b1bb6eca7050d46689c550c18609c3c9dc43b0b",
        "evidence_tree_sha256": "6e8e1a6d8ff3ee12e961d7adaa78cdc72e8aa57dbb607251d5a1361c171eb895",
        "mechanical_review_receipt_sha256": "fb4802671d8ec92d2cdff091a221fc6fe8f3d1dae6780446aa5604227f7cfed4",
        "review_receipt_sha256": "cb06367c7de02d2379c855dfe33915d8bd54b85a33666f0582e949752f9310cf",
        "accepted_physical_unit_id": "physical-building:w764313741",
        "capture_time_recognition_metric": "14/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w764313741",
        "wall_object_key": "building:w764313741:wall",
        "roof_object_key": "building:w764313741:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
          0,
          1,
          2,
          3,
          5,
          6,
          8,
          9,
          24,
          25
        ],
        "protected_run_indices": [
          4,
          7,
          10,
          11,
          12,
          13,
          14,
          15,
          16,
          17,
          18,
          19,
          20,
          21,
          22,
          23
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1
      },
      "geometry_contract": {
        "source_geometry_sha256": "e198f49df39671d489bb96cd553ec257df12156a0921b489f434d2c2b37d7597",
        "canonical_wall_record_sha256": "0e3b5283ff9c055dc0a642d3608af13057ed6d1c87293d4b845991d9e96f9a8d",
        "canonical_roof_record_sha256": "a64186052e8331d3ee744718f19ba8dc6350da4f67c8b51f29b9469c903c89d2",
        "source_chunk_sha256": "c0e1f86787410d975ad90272482e5f4971c4aedc7eb83132cd28b22acf1a3456",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 7,
        "visual_surfaces": 7,
        "visual_triangles": 1090,
        "world_records": 735,
        "world_mesh_instances": 1023,
        "world_surfaces": 1038,
        "world_triangles": 82789,
        "world_static_bodies": 466,
        "world_shapes": 477,
        "world_topology_scope": "current_integration_topology"
      },
      "ownership_contract": {
        "structural_owner_count": 2,
        "shape_count": 2,
        "spray_owner_count": 1,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": true,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall"
        ],
        "wall_shape_collision_triangles": [
          52
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof"
        ],
        "roof_shape_collision_triangles": [
          10
        ],
        "eligible_exterior_collision_triangles": 52,
        "wall_collision_triangles": 52,
        "roof_collision_triangles": 10,
        "added_collision_triangles": 0,
        "all_additions_render_only": true,
        "visual_ground_triangles": 0,
        "added_ground_collision_triangles": 0,
        "roof_is_wall_spray_receiver": false,
        "roof_world_solid_landing": true,
        "eligible_render_layer": 2,
        "noneligible_render_layer": 1,
        "terrain_geometry_and_ownership_unchanged": true
      },
      "truth_boundary": {
        "as_built_fidelity_claimed": false,
        "interior_modeled": false,
        "hidden_schedule_invented": false,
        "capture_time_recognition_credit": false,
        "capture_time_candidate_promoted": false,
        "reference_pixels_packaged": false,
        "receiver_complete_inferred_from_art": false,
        "game_distinctive_claimed": false,
        "unobserved_sides_protected": true,
        "unsurveyed_dimensions_and_counts_are_production_inference": true,
        "continuous_motion_review_claimed": false,
        "ground_to_roof_traversal_claimed": false,
        "roof_support_setup_is_separate": true,
        "spray_input_event_dispatch_claimed": false
      }
    },
    "runtime_asset_count": 7
  }
];
for (const d of expectedD5Batch) {
  const unit = registry.units.find((u) => u.unit_id === d.unit_id);
  const adapter = registry.active_runtime_adapters.find((a) => a.receiver_key === d.wall);
  assert(unit.acceptance_records.length === 1 && unit.direct_receivers.length === 1 && unit.active_runtime_adapter_ids.length === 1 && stableJson(unit.acceptance_records[0]) === stableJson(d.acceptance), `${d.unit_id} exact single-unit seven-artifact authority drifted`);
  assert(adapter.runtime_assets.length === d.runtime_asset_count && adapter.runtime_asset_projections.length === 0 && stableJson(adapter.active_runtime_contract.behavior_contract) === stableJson(d.behavior), `${d.unit_id} live pair/terrain/ownership boundary drifted`);
}

console.log(
  `PASS facade runtime loader contract: ${EXPECTED.recognition_units} units / ${EXPECTED.direct_wall_receivers} receivers / ${adapterContracts.plans.length} plans / ${readyPlans.length} package-safe / ${disabledPlans.length} hard-disabled receivers / ${adapterContracts.projection_descriptors.length} pathless projection inputs; registry ${sha256File(PATHS.registry)}; adapter contracts ${sha256File(PATHS.adapterContracts)}`,
);
