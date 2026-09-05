import { createHash } from "node:crypto";
import { existsSync, readFileSync, statSync } from "node:fs";
import { dirname, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";

import {
  assertJsonSchema,
  assertSchemaDocument,
} from "./lib/dependency-free-json-schema.mjs";
import { stableJson } from "./lib/world-contract.mjs";
import {
  ADAPTER_CONTRACT_CHECK_ID,
  CATALOG_SCHEMA,
  EXPECTED,
  PATHS,
  REPORT_SCHEMA,
  RUNTIME_SCHEMA,
  assertRuntimeAssetClosures,
  compile,
  inspectRuntimeAssetClosure,
  loadInputs,
  validateActiveHeroDispatch,
  validateRuntimeRegistry,
} from "./build_facade_recognition_registry.mjs";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const ACCEPTED_REFERENCE_UNIT_IDS = [
  "physical-building:r16681702",
  "physical-building:w1222720021",
  "physical-building:w1249412093",
  "physical-building:w1249412094",
  "physical-building:w291189336",
  "physical-building:w34313540",
  "physical-building:w34313545",
  "physical-building:w95934119",
].sort();
const ACTIVE_REVIEW_STATUS_SCOPE = "runtime_asset_original_detail_provenance_only_not_reference_recognition";
const ACTIVE_RECOGNITION_ACCEPTANCE_AUTHORITY = "physical_unit_claim_and_independent_acceptance_record";
const PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "pre_b201_integration_live_parity";
const PRE_B225_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "pre_b225_integration_live_parity";
const CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "current_integration_topology";
const ACTIVE_UNIT_BY_RECEIVER = new Map([
  ["building-composite:w1249412094:w1282547787:wall", "physical-building:w1249412094"],
  ["building:r16681702:wall", "physical-building:r16681702"],
  ["building:w1222720021:wall", "physical-building:w1222720021"],
  ["building:w291189336:wall", "physical-building:w291189336"],
  ["building:w34313540:wall", "physical-building:w34313540"],
  ["building:w34313545:wall", "physical-building:w34313545"],
  ["building:w95934119:wall", "physical-building:w95934119"],
]);
const ACTIVE_REVIEW_STATUS_BY_RECEIVER = new Map([
  ["building-composite:w1249412094:w1282547787:wall", "independent_exact_current_live_pass"],
  ["building:r16681702:wall", "pending_independent_original_detail_review"],
  ["building:w1222720021:wall", "pending_independent_original_detail_review"],
  ["building:w291189336:wall", "independent_exact_current_live_pass"],
  ["building:w34313540:wall", "pending_independent_original_detail_review"],
  ["building:w34313545:wall", "independent_exact_current_live_pass"],
  ["building:w95934119:wall", "independent_exact_current_live_pass"],
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

function inspectRuntimeBoundary(value, label = "registry") {
  if (typeof value === "string") {
    assert(!value.includes("discovery/"), `${label} leaks discovery path ${value}`);
    assert(!value.includes("evidence/"), `${label} leaks evidence path ${value}`);
    assert(!value.includes("/Users/") && !value.includes("/Volumes/"), `${label} leaks absolute path ${value}`);
    assert(!/https?:\/\//u.test(value), `${label} leaks reference URL ${value}`);
    return;
  }
  if (Array.isArray(value)) {
    value.forEach((child, index) => inspectRuntimeBoundary(child, `${label}[${index}]`));
    return;
  }
  if (value != null && typeof value === "object") {
    for (const [key, child] of Object.entries(value)) inspectRuntimeBoundary(child, `${label}.${key}`);
  }
}

const inputs = loadInputs();
const schema = readJson(PATHS.schema);
const catalog = readJson(PATHS.catalog);
const registry = readJson(PATHS.registry);
const report = readJson(PATHS.report);
const compiled = compile(catalog, inputs);

assertSchemaDocument(schema, PATHS.schema);
assertJsonSchema(catalog, schema, PATHS.catalog);
validateActiveHeroDispatch(inputs);
assert(schema.$schema === "https://json-schema.org/draft/2020-12/schema", "catalog schema is not JSON Schema 2020-12");
assert(schema.properties.schema_version.const === CATALOG_SCHEMA, "catalog schema version constraint drifted");
assert(schema.properties.units.minItems === EXPECTED.recognition_units && schema.properties.units.maxItems === EXPECTED.recognition_units, "catalog schema does not pin 213 units");
assert(schema.properties.capture_contracts.items.$ref === "#/$defs/capture_contract", "catalog schema lacks capture contracts");
assert(schema.properties.identity_evidence_records.items.$ref === "#/$defs/identity_evidence_record", "catalog schema lacks separate identity evidence");
assert(schema.properties.active_runtime_adapters.minItems === EXPECTED.active_runtime_adapter_receivers && schema.properties.active_runtime_adapters.maxItems === EXPECTED.active_runtime_adapter_receivers, "catalog schema does not pin seven active runtime adapters");
const building1AdapterSchema = schema.$defs.building_1_active_runtime_adapter.properties.runtime_asset_paths;
assert(building1AdapterSchema.contains.const === "game/resources/facades/building_1_public_front_believability.json" && building1AdapterSchema.minContains === 1 && building1AdapterSchema.maxContains === 1, "catalog schema does not require exactly one Building 1 public-front config member");
for (const reference of schema.$defs.active_runtime_adapter.anyOf) {
  const definition = schema.$defs[reference.$ref.slice("#/$defs/".length)];
  assert(definition.required.includes("review_status_scope") && definition.required.includes("recognition_acceptance_authority") && definition.required.includes("recognition_acceptance_status"), `${reference.$ref} does not require the exact active-adapter recognition-authority fields`);
  assert(definition.properties.review_status_scope.const === ACTIVE_REVIEW_STATUS_SCOPE, `${reference.$ref} review-status scope is not exact`);
  assert(definition.properties.recognition_acceptance_authority.const === ACTIVE_RECOGNITION_ACCEPTANCE_AUTHORITY, `${reference.$ref} recognition authority is not exact`);
  assert(definition.properties.recognition_acceptance_status.const === "accepted", `${reference.$ref} recognition acceptance is not fail-closed to accepted`);
  assert(["pending_independent_original_detail_review", "independent_exact_current_live_pass"].includes(definition.properties.review_status.const), `${reference.$ref} review status is not an exact allowed literal`);
}
assert(catalog.schema_version === CATALOG_SCHEMA, "catalog schema drifted");
assert(Array.isArray(catalog.capture_contracts) && catalog.capture_contracts.length === ACCEPTED_REFERENCE_UNIT_IDS.length, "catalog does not contain exactly eight accepted ordinary-player capture contracts");
assert(registry.schema_version === RUNTIME_SCHEMA, "runtime registry schema drifted");
assert(report.schema_version === REPORT_SCHEMA && report.status === "pass", "validation report is not passing");
assert(stableJson(registry) === stableJson(compiled.registry), "checked-in runtime registry differs from a clean compile");
assert(stableJson(report) === stableJson(compiled.report), "checked-in validation report differs from a clean compile");
assert(ADAPTER_CONTRACT_CHECK_ID === "adapter_contract_10_ready_6_disabled_13_unique_projection_inputs", "adapter-contract validation check identifier is not exact-current");
assert(report.checks.filter((check) => check.check_id === ADAPTER_CONTRACT_CHECK_ID && check.status === "pass").length === 1, "validation report does not contain exactly one passing exact-current adapter-contract check identifier");
assert(!report.checks.some((check) => check.check_id === "adapter_contract_6_ready_8_disabled_15_unique_projection_inputs"), "validation report retains the stale adapter-contract check identifier");

assert(registry.units.length === EXPECTED.recognition_units, "runtime registry does not contain 213 recognition units");
assert(registry.legacy_adapters.length === EXPECTED.legacy_adapter_receivers, "runtime registry does not contain nine legacy adapters");
assert(registry.active_runtime_adapters.length === EXPECTED.active_runtime_adapter_receivers, "runtime registry does not contain seven active runtime adapters");
assert(registry.counts.runtime_adapter_receivers === EXPECTED.runtime_adapter_receivers, "runtime registry does not contain 16 receiver adapters");
assert(registry.counts.source_record_memberships === EXPECTED.source_records, "runtime registry source membership is not 215");
assert(registry.counts.direct_wall_receivers === EXPECTED.direct_wall_receivers, "runtime registry receiver count is not 214");
assert(registry.counts.visible_wall_runs === EXPECTED.visible_wall_runs, "runtime registry visible wall runs are not 4,971");
assert(registry.counts.identity_assertion_summaries === 2, "runtime registry does not contain two identity-correction summaries");
assert(registry.counts.standalone_units === EXPECTED.standalone_units && registry.counts.composite_units === EXPECTED.composite_units, "runtime standalone/composite split is not 212/1");

const sourceRecords = registry.units.flatMap((unit) => unit.source_records);
const receivers = registry.units.flatMap((unit) => unit.direct_receivers);
assert(sourceRecords.length === EXPECTED.source_records, "unit source-record expansion is not 215");
assert(receivers.length === EXPECTED.direct_wall_receivers, "unit receiver expansion is not 214");
assertUnique(sourceRecords.map((source) => source.source_key), "unit source records");
assertUnique(receivers.map((receiver) => receiver.receiver_key), "unit direct receivers");
assert(receivers.reduce((sum, receiver) => sum + receiver.run_count, 0) === EXPECTED.visible_wall_runs, "unit receiver runs do not total 4,971");

for (const receiver of receivers) {
  assert(receiver.collision_kind === "world_solid" && receiver.opaque === true && receiver.spray_receiver_expected === true, `${receiver.receiver_key} lost physics/spray expectations`);
  assert(receiver.vertex_count === receiver.run_count * 4, `${receiver.receiver_key} no longer has four vertices per run`);
  assert(receiver.index_count === receiver.run_count * 6 && receiver.triangle_count === receiver.run_count * 2, `${receiver.receiver_key} no longer has one quad per run`);
  assert(receiver.exterior_foundation_runs + receiver.shared_wall_runs === receiver.run_count, `${receiver.receiver_key} run ownership does not reconcile`);
  assert(/^[0-9a-f]{64}$/u.test(receiver.record_sha256) && /^[0-9a-f]{64}$/u.test(receiver.geometry_sha256), `${receiver.receiver_key} lacks receiver hashes`);
}

const compositeUnits = registry.units.filter((unit) => unit.unit_kind === "composite_building");
assert(compositeUnits.length === 1, "expected one composite recognition unit");
const composite = compositeUnits[0];
assert(composite.unit_id === "physical-building:w1249412094", "unexpected composite unit identity");
assert(
  JSON.stringify(composite.source_records.map((source) => source.source_key)) ===
    JSON.stringify(["w1249412094", "w1282547786", "w1282547787"]),
  "Isle House composite source membership drifted",
);
assert(composite.direct_receivers.length === 2, "Isle House composite must own two direct wall receivers");
assert(composite.direct_receivers.every((receiver) => receiver.feature_kind === "building_part_wall"), "Isle House direct receivers must remain building-part walls");
const isleHigh = composite.direct_receivers.find((receiver) => receiver.receiver_key === "building-composite:w1249412094:w1282547786:wall");
const isleLow = composite.direct_receivers.find((receiver) => receiver.receiver_key === "building-composite:w1249412094:w1282547787:wall");
assert(isleHigh.runtime_content_mode === "legacy_adapter" && isleHigh.runtime_adapter_id != null, "Isle House high receiver lost its adapter");
assert(isleLow.runtime_content_mode === "active_isle_house_variant_c" && isleLow.runtime_adapter_id === "active-adapter:isle-house-variant-c:building-composite:w1249412094:w1282547787:wall", "Isle House low receiver is not bound to the exact active Variant C adapter");
assert(composite.runtime_content_mode === "mixed_legacy_high_and_active_variant_c_low", "Isle House accepted mixed receiver state was collapsed at unit level");
assert(!registry.units.some((unit) => ["physical-building:w1282547786", "physical-building:w1282547787"].includes(unit.unit_id)), "Isle House source receiver records were promoted to numerator units");

const building1Unit = registry.units.find((unit) => unit.unit_id === "physical-building:r16681702");
const building1TowerUnit = registry.units.find((unit) => unit.unit_id === "physical-building:w1222720021");
const building3Unit = registry.units.find((unit) => unit.unit_id === "physical-building:w34313540");
const navyChapelUnit = registry.units.find((unit) => unit.unit_id === "physical-building:w291189336");
const d1B201Unit = registry.units.find((unit) => unit.unit_id === "physical-building:w34313545");
const d1B225Unit = registry.units.find((unit) => unit.unit_id === "physical-building:w95934119");
assert(building1Unit !== building1TowerUnit, "Building 1 and its observation tower were collapsed");
assert(building1Unit.direct_receivers[0].runtime_content_mode === "active_building_1_hero", "Building 1 main wall is not bound to current hero dispatch");
assert(building1TowerUnit.direct_receivers[0].runtime_content_mode === "active_building_1_hero", "Building 1 observation tower wall is not bound to current hero dispatch");
assert(building1Unit.active_runtime_adapter_ids.length === 1 && building1TowerUnit.active_runtime_adapter_ids.length === 1, "Building 1/tower active adapter memberships drifted");
assert(building1Unit.legacy_adapter_ids.length === 0 && building1TowerUnit.legacy_adapter_ids.length === 0, "Building 1/tower retain obsolete legacy adapter membership");
assert(building3Unit.direct_receivers[0].runtime_content_mode === "active_building_3_hero", "Building 3 wall is not bound to its current wall/roof hero dispatch");
assert(building3Unit.active_runtime_adapter_ids.length === 1 && building3Unit.legacy_adapter_ids.length === 0, "Building 3 retains obsolete legacy membership or lacks its active adapter");
assert(navyChapelUnit.direct_receivers[0].runtime_content_mode === "active_navy_chapel_187_paired_replacement", "Navy Chapel wall is not bound to its exact paired wall/roof replacement");
assert(navyChapelUnit.runtime_content_mode === "all_receivers_active_navy_chapel_187_paired_replacement", "Navy Chapel unit content mode does not preserve the paired replacement semantics");
assert(navyChapelUnit.active_runtime_adapter_ids.length === 1 && navyChapelUnit.legacy_adapter_ids.length === 0, "Navy Chapel retains obsolete legacy membership or lacks its active adapter");
assert(d1B201Unit.direct_receivers[0].runtime_content_mode === "active_d1_b201_host_partition_attachment", "D1 B201 wall is not bound to its exact host-partition attachment");
assert(d1B201Unit.runtime_content_mode === "all_receivers_active_d1_b201_host_partition_attachment", "D1 B201 unit content mode does not preserve host-partition semantics");
assert(d1B201Unit.active_runtime_adapter_ids.length === 1 && d1B201Unit.legacy_adapter_ids.length === 0, "D1 B201 retains obsolete legacy membership or lacks its active adapter");
assert(d1B225Unit.direct_receivers[0].runtime_content_mode === "active_d1_b225_host_partition_attachment", "D1 B225 wall is not bound to its exact host-partition attachment");
assert(d1B225Unit.runtime_content_mode === "all_receivers_active_d1_b225_host_partition_attachment", "D1 B225 unit content mode does not preserve host-partition semantics");
assert(d1B225Unit.active_runtime_adapter_ids.length === 1 && d1B225Unit.legacy_adapter_ids.length === 0, "D1 B225 retains obsolete legacy membership or lacks its active adapter");
assert(d1B225Unit.acceptance_records.length === 1 && d1B225Unit.acceptance_records[0].capture_time_recognition_metric === "7/213" && d1B225Unit.acceptance_records[0].numerator_effect === 1, "D1 B225 authority does not preserve its capture-time 7/213 boundary and one-unit numerator effect");
assert(d1B225Unit.acceptance_records[0].evidence_manifest_sha256 === "96c76fd99960f1345a7c56f7fc6678ac284f98cc601a3ba65ed57020491f18dc" && d1B225Unit.acceptance_records[0].evidence_tree_sha256 === "f42dbec489c6fda55b612aba20c99ee2233857cb60a1ce9c512d024b35d0dcb7" && d1B225Unit.acceptance_records[0].review_receipt_sha256 === "87dc2b9febf7110ccd5c1eabed1a290fea5900508561298dd7cf3b6b6fcb1d95", "D1 B225 authority is not bound to the frozen capture-time production evidence and independent review");

for (const unit of registry.units) {
  const accepted = ACCEPTED_REFERENCE_UNIT_IDS.includes(unit.unit_id);
  assert(unit.claim_status.receiver_complete === "verified", `${unit.unit_id} is not receiver-complete`);
  assert(unit.claim_status.game_distinctive === "not_evaluated", `${unit.unit_id} imported game-distinctive acceptance`);
  assert(unit.claim_status.reference_recognizable === (accepted ? "accepted" : "not_evaluated"), `${unit.unit_id} reference-recognition state does not match the independently accepted physical-unit set`);
  assert(unit.claim_status.as_built_fidelity === "unclaimed", `${unit.unit_id} imported as-built fidelity`);
  assert(unit.recognition_contract.game_only_cues_do_not_prove_real_world_recognition === true, `${unit.unit_id} weakens the real-world claim boundary`);
  assert(unit.recognition_contract.capture_status === (accepted ? "configured" : "unconfigured"), `${unit.unit_id} capture status does not match its acceptance state`);
  assert(unit.capture_contract.status === (accepted ? "configured" : "unconfigured"), `${unit.unit_id} runtime capture contract does not match its acceptance state`);
  assert(Array.isArray(unit.recognition_cues) && (accepted ? unit.recognition_cues.length >= 2 : unit.recognition_cues.length === 0), `${unit.unit_id} recognition-cue inventory does not match its acceptance state`);
  assert(Array.isArray(unit.acceptance_records) && (accepted ? unit.acceptance_records.length === 1 : unit.acceptance_records.length === 0), `${unit.unit_id} acceptance-receipt count does not match its acceptance state`);
  if (accepted) {
    const receipt = unit.acceptance_records[0];
    assert(receipt.review_kind === "independent_reference_recognition" && receipt.status === "accept", `${unit.unit_id} lacks independent reference-recognition acceptance`);
    assert(/^[0-9a-f]{64}$/u.test(receipt.review_receipt_sha256) && /^[0-9a-f]{64}$/u.test(receipt.evidence_manifest_sha256), `${unit.unit_id} acceptance hashes are invalid`);
  }
}
for (const adapter of catalog.active_runtime_adapters) {
  const unitId = ACTIVE_UNIT_BY_RECEIVER.get(adapter.receiver_key);
  const unit = catalog.units.find((candidate) => candidate.unit_id === unitId);
  assert(unit != null && unit.receiver_keys.includes(adapter.receiver_key), `${adapter.adapter_id} authoring receiver does not cross-link to its exact physical unit`);
  assert(adapter.review_status === ACTIVE_REVIEW_STATUS_BY_RECEIVER.get(adapter.receiver_key), `${adapter.adapter_id} authoring review status is not an exact allowed literal`);
  assert(adapter.review_status_scope === ACTIVE_REVIEW_STATUS_SCOPE, `${adapter.adapter_id} authoring review-status scope is ambiguous`);
  assert(adapter.recognition_acceptance_authority === ACTIVE_RECOGNITION_ACCEPTANCE_AUTHORITY, `${adapter.adapter_id} authoring recognition authority drifted`);
  assert(adapter.recognition_acceptance_status === unit.claim_status.reference_recognizable && adapter.recognition_acceptance_status === "accepted", `${adapter.adapter_id} authoring recognition status is not derived from its accepted physical unit`);
  assert(unit.acceptance_records.some((record) => record.review_kind === "independent_reference_recognition" && record.status === "accept"), `${adapter.adapter_id} authoring physical unit lacks an independent recognition acceptance receipt`);
}
for (const adapter of registry.active_runtime_adapters) {
  const unitId = ACTIVE_UNIT_BY_RECEIVER.get(adapter.receiver_key);
  const unit = registry.units.find((candidate) => candidate.unit_id === unitId);
  assert(unit != null && unit.direct_receivers.some((receiver) => receiver.receiver_key === adapter.receiver_key), `${adapter.adapter_id} runtime receiver does not cross-link to its exact physical unit`);
  assert(adapter.review_status === ACTIVE_REVIEW_STATUS_BY_RECEIVER.get(adapter.receiver_key), `${adapter.adapter_id} runtime review status is not an exact allowed literal`);
  assert(adapter.review_status_scope === ACTIVE_REVIEW_STATUS_SCOPE, `${adapter.adapter_id} runtime review-status scope is ambiguous`);
  assert(adapter.recognition_acceptance_authority === ACTIVE_RECOGNITION_ACCEPTANCE_AUTHORITY, `${adapter.adapter_id} runtime recognition authority drifted`);
  assert(adapter.recognition_acceptance_status === unit.claim_status.reference_recognizable && adapter.recognition_acceptance_status === "accepted", `${adapter.adapter_id} runtime recognition status is not derived from its accepted physical unit`);
  assert(unit.acceptance_records.some((record) => record.review_kind === "independent_reference_recognition" && record.status === "accept"), `${adapter.adapter_id} runtime physical unit lacks an independent recognition acceptance receipt`);
}
assert(registry.claim_totals.receiver_complete.verified === EXPECTED.recognition_units, "receiver-complete aggregate drifted");
assert(registry.claim_totals.game_distinctive.accepted === 0, "game-distinctive acceptance must start at zero");
assert(registry.claim_totals.reference_recognizable.accepted === ACCEPTED_REFERENCE_UNIT_IDS.length && registry.claim_totals.reference_recognizable.not_evaluated === EXPECTED.recognition_units - ACCEPTED_REFERENCE_UNIT_IDS.length, "reference-recognizable aggregate is not exactly 8/213");
assert(registry.claim_totals.as_built_fidelity.claimed === 0 && registry.claim_totals.as_built_fidelity.limited === 0, "as-built fidelity must remain wholly unclaimed");
assert(JSON.stringify(registry.recognition_metric.accepted_physical_unit_ids) === JSON.stringify(ACCEPTED_REFERENCE_UNIT_IDS), "recognition metric accepted-unit set drifted");
assert(registry.recognition_metric.numerator === 8 && registry.recognition_metric.denominator === 213 && registry.recognition_metric.display === "8/213", "recognition metric is not exactly 8/213");
assert(JSON.stringify(registry.recognition_metric.isle_house_non_numerator_source_keys) === JSON.stringify(["w1282547786", "w1282547787"]), "Isle House source-part exclusion drifted");

const expectedIdentityCorrections = new Map([
  ["physical-building:w24274434", "08000082"],
  ["physical-building:w34313540", "08000083"],
]);
assert(catalog.identity_evidence_records.length === expectedIdentityCorrections.size, "authoring catalog does not contain exactly two identity corrections");
for (const [unitId, evidencedValue] of expectedIdentityCorrections) {
  const sourceKey = unitId.slice("physical-building:".length);
  const inventoryObject = inputs.inventory.objects.find((object) => object.source.source_key === sourceKey);
  const catalogUnit = catalog.units.find((unit) => unit.unit_id === unitId);
  const catalogAssertion = catalog.identity_evidence_records.find((record) => record.unit_id === unitId);
  const runtimeUnit = registry.units.find((unit) => unit.unit_id === unitId);
  assert(inventoryObject.source.tags["ref:nrhp"] === "08000081", `${unitId} immutable NRHP provenance was overwritten`);
  assert(catalogUnit.identity.currentness_claimed === false, `${unitId} frozen identity silently gained a currentness claim`);
  assert(catalogAssertion.evidence_class === "authoritative_correction" && catalogAssertion.frozen_value === "08000081", `${unitId} correction is not separated from frozen identity`);
  assert(catalogAssertion.evidenced_value === evidencedValue && catalogAssertion.currentness_claimed === false, `${unitId} correction value/currentness drifted`);
  assert(catalogAssertion.primary_source_locator.startsWith("https://npgallery.nps.gov/"), `${unitId} correction lacks its authoritative NPS source`);
  assert(runtimeUnit.identity_assertions.length === 1, `${unitId} runtime correction summary is missing or duplicated`);
  const runtimeAssertion = runtimeUnit.identity_assertions[0];
  assert(runtimeAssertion.asserted_value === evidencedValue && runtimeAssertion.frozen_source_value === "08000081", `${unitId} runtime correction values drifted`);
  assert(runtimeAssertion.frozen_value_preserved === true && runtimeAssertion.supersedes_frozen_value === true, `${unitId} runtime correction does not preserve provenance`);
  assert(runtimeAssertion.currentness_claimed === false, `${unitId} runtime correction silently claims currentness`);
}
assert(report.identity_assertions.authoring_record_count === 2 && report.identity_assertions.authoritative_correction_count === 2, "validation report identity-correction counts drifted");
assert(report.identity_assertions.currentness_claimed_count === 0 && report.identity_assertions.runtime_summary_count === 2, "validation report identity currentness/runtime counts drifted");

const allRuntimeAdapters = [...registry.legacy_adapters, ...registry.active_runtime_adapters];
const adapterReceivers = allRuntimeAdapters.map((adapter) => adapter.receiver_key);
assert(adapterReceivers.length === EXPECTED.runtime_adapter_receivers, "combined adapter array is not 16 receivers");
assertUnique(adapterReceivers, "runtime adapter receivers");
for (const adapter of allRuntimeAdapters) {
  assert(adapter.whole_building_recognizability_imported === false && adapter.recognition_claim_effect === "none", `${adapter.adapter_id} improperly transfers recognizability`);
  assert(receivers.some((receiver) => receiver.receiver_key === adapter.receiver_key), `${adapter.adapter_id} targets an unknown receiver`);
  for (const scope of adapter.accepted_run_scopes) {
    const receiver = receivers.find((candidate) => candidate.receiver_key === adapter.receiver_key);
    assert(scope.run_indices.every((run) => Number.isInteger(run) && run >= 0 && run < receiver.run_count), `${adapter.adapter_id}/${scope.scope_id} escapes its receiver`);
    assertUnique(scope.run_indices, `${adapter.adapter_id}/${scope.scope_id} runs`);
  }
  for (const asset of adapter.runtime_assets) {
    assert(asset.path.startsWith("res://game/"), `${adapter.adapter_id} has a non-runtime asset ${asset.path}`);
    const sourcePath = asset.path.slice("res://".length);
    assert(existsSync(absolute(sourcePath)) && statSync(absolute(sourcePath)).isFile(), `${adapter.adapter_id} runtime asset is missing: ${asset.path}`);
    assert(sha256File(sourcePath) === asset.sha256, `${adapter.adapter_id} runtime asset hash drifted: ${asset.path}`);
    assert(inspectRuntimeAssetClosure(sourcePath).closure_clean, `${adapter.adapter_id} runtime asset closure is contaminated: ${asset.path}`);
  }
  for (const projection of adapter.runtime_asset_projections) {
    assert(projection.package_contract === "sanitized_adapter_metadata_summary_only", `${adapter.adapter_id} has an invalid source projection`);
    assert(/^[0-9a-f]{64}$/u.test(projection.source_asset_sha256), `${adapter.adapter_id} projection lacks a source hash`);
  }
}
assertRuntimeAssetClosures(registry);

const expectedActiveReceivers = ["building-composite:w1249412094:w1282547787:wall", "building:r16681702:wall", "building:w1222720021:wall", "building:w291189336:wall", "building:w34313540:wall", "building:w34313545:wall", "building:w95934119:wall"];
assert(JSON.stringify(registry.active_runtime_adapters.map((adapter) => adapter.receiver_key).sort()) === JSON.stringify(expectedActiveReceivers.sort()), "active Building 1/Building 3/Isle House/Navy Chapel/D1 B201/D1 B225 receiver set drifted");
for (const adapter of registry.active_runtime_adapters.filter((candidate) => ["building:r16681702:wall", "building:w1222720021:wall"].includes(candidate.receiver_key))) {
  assert(adapter.attachment_kind === "active_building_1_hero_replacement" && adapter.state === "active_runtime_target_specific_content", `${adapter.adapter_id} has stale content classification`);
  assert(adapter.active_receiver_scope.coverage === "whole_direct_wall_receiver", `${adapter.adapter_id} is not scoped to its exact direct receiver`);
  assert(adapter.active_runtime_contract.config_summary.target.tower_remains_separately_reviewable === true, `${adapter.adapter_id} config summary collapses the tower`);
  assert(adapter.runtime_assets.length === 11 && adapter.runtime_asset_projections.length === 0, `${adapter.adapter_id} does not account for its hero script, two configs, and eight exact-current materials`);
  assert(adapter.runtime_assets.some((asset) => asset.path === "res://game/resources/facades/building_1_public_front_believability.json" && asset.sha256 === "7b53847c627d6f0a0d4ebefcc790e8fd3bcaeee6fbdebbf5c6a85f2aeb4a5806"), `${adapter.adapter_id} omits the exact current public-front runtime config`);
  assert(adapter.active_runtime_contract.public_front_config_sha256 === "7b53847c627d6f0a0d4ebefcc790e8fd3bcaeee6fbdebbf5c6a85f2aeb4a5806", `${adapter.adapter_id} public-front contract hash drifted`);
}
const building3Adapter = registry.active_runtime_adapters.find((adapter) => adapter.receiver_key === "building:w34313540:wall");
const building3AssetPaths = building3Adapter.runtime_assets.map((asset) => asset.path).sort();
const expectedBuilding3AssetPaths = [
  "res://game/resources/facades/building_3_600_california_ene_layout.json",
  "res://game/resources/facades/building_3_hero_massing.json",
  "res://game/resources/materials/world/building_3/building_3_shadow_recess.tres",
  "res://game/resources/materials/world/building_3/building_3_teal_door.tres",
  "res://game/resources/materials/world/building_3/building_3_white_primary.tres",
  "res://game/scenes/world/facades/building_3/building_3_600_california_facade.tscn",
  "res://game/scenes/world/facades/building_3/building_3_ene_modules.tscn",
  "res://game/scripts/world/facades/building_3_600_california_facade.gd",
  "res://game/scripts/world/massing/building_3_600_california_massing.gd",
].sort();
assert(building3Adapter.attachment_kind === "active_building_3_wall_roof_hero_replacement" && building3Adapter.runtime_content_mode === "active_building_3_hero", "Building 3 active classification drifted");
assert(JSON.stringify(building3AssetPaths) === JSON.stringify(expectedBuilding3AssetPaths) && building3Adapter.runtime_asset_projections.length === 0, "Building 3 wrapper/config/facade dependency set is incomplete or source-bearing");
const building3Behavior = building3Adapter.active_runtime_contract.behavior_contract;
assert(building3Behavior.parity_status === "exact_current_behavior_and_dependency_set_verified", "Building 3 parity is not proven");
assert(building3Behavior.replacement_contract.receiver_roles.join("|") === "wall|roof", "Building 3 does not replace wall and roof together");
assert(building3Behavior.geometry_contract.wall_triangles === 236 && building3Behavior.geometry_contract.roof_triangles === 675 && building3Behavior.geometry_contract.topology_delta_triangles === 766, "Building 3 topology parity drifted");
assert(building3Behavior.collision_contract.collision_matches_visible_geometry === true && building3Behavior.collision_contract.roof_landing_world_solid === true && building3Behavior.collision_contract.spray_ownership === "wall_only", "Building 3 collision/landing/spray parity drifted");
assert(building3Behavior.facade_contract.runtime_bound_to_wall_massing === true && building3Behavior.facade_contract.deterministic_signature === "e0b30339bd2ca8642a7b49b5e6153f52017ec4a840e9b0dc1e3841f5373ca5f8", "Building 3 facade parity drifted");
const isleAdapter = registry.active_runtime_adapters.find((adapter) => adapter.receiver_key === "building-composite:w1249412094:w1282547787:wall");
const isleBehavior = isleAdapter.active_runtime_contract.behavior_contract;
assert(isleAdapter.attachment_kind === "active_isle_house_variant_c_low_part_replacement" && isleAdapter.runtime_content_mode === "active_isle_house_variant_c", "Isle House active classification drifted");
assert(isleAdapter.runtime_assets.length === 1 && isleAdapter.runtime_asset_projections.length === 3, "Isle House runtime/source projection boundary drifted");
assert(isleBehavior.acceptance_contract.independent_live_review_receipt_sha256 === "37b6c7dbf6c8769b13628e1070a9c3b5beeb9b25bbe63f0f12f9aaa00c22dab8" && isleBehavior.acceptance_contract.numerator_effect === 1, "Isle House live acceptance receipt or numerator effect drifted");
assert(isleBehavior.geometry_contract.live_signature === "09eee1517f043c6d82f0de0d2275da5b2a3f76f5842d1b9c90cba11e6e793981" && isleBehavior.geometry_contract.overlay_repair_signature === "41868b77a8b51b56ee7381e5549423e97547270d2dc77d9ce5cf958b31e2cb69", "Isle House live signatures drifted");
assert(isleBehavior.geometry_contract.world_topology_scope === PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE && isleBehavior.geometry_contract.world_records === 735 && isleBehavior.geometry_contract.world_mesh_instances === 944 && isleBehavior.geometry_contract.world_surfaces === 957 && isleBehavior.geometry_contract.world_triangles === 64572 && isleBehavior.geometry_contract.world_static_bodies === 466 && isleBehavior.geometry_contract.world_shapes === 466, "Isle House pre-B201 integration world topology parity drifted");
assert(isleBehavior.ownership_contract.low_receiver_is_sole_collision_and_spray_owner === true && isleBehavior.ownership_contract.decorative_collision_nodes === 0 && isleBehavior.ownership_contract.decorative_navigation_nodes === 0 && isleBehavior.ownership_contract.decorative_spray_nodes === 0, "Isle House collision/navigation/spray ownership drifted");
const navyChapelAdapter = registry.active_runtime_adapters.find((adapter) => adapter.receiver_key === "building:w291189336:wall");
const navyChapelAssetPaths = navyChapelAdapter.runtime_assets.map((asset) => asset.path).sort();
const navyChapelBehavior = navyChapelAdapter.active_runtime_contract.behavior_contract;
assert(navyChapelAdapter.attachment_kind === "active_navy_chapel_187_paired_wall_roof_replacement" && navyChapelAdapter.runtime_content_mode === "active_navy_chapel_187_paired_replacement", "Navy Chapel active classification drifted");
assert(navyChapelAssetPaths.length === 9 && navyChapelAssetPaths.includes("res://game/scripts/world/facades/navy_chapel_187_live_replacement.gd") && navyChapelAssetPaths.includes("res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd") && navyChapelAssetPaths.includes("res://game/resources/facades/navy_chapel_187_standalone_hero_prototype.json") && navyChapelAdapter.runtime_asset_projections.length === 0, "Navy Chapel live/config/prototype/material dependency set is incomplete or source-bearing");
assert(navyChapelBehavior.acceptance_contract.independent_live_review_receipt_sha256 === "63bd6c5a79db837e3b53b60eea36887cee8c4c66af791715f964f023b926b5a9" && navyChapelBehavior.acceptance_contract.numerator_effect === 1 && navyChapelBehavior.acceptance_contract.wall_and_roof_are_one_physical_unit === true, "Navy Chapel acceptance receipt or one-unit rollup drifted");
assert(navyChapelBehavior.geometry_contract.visual_geometry_signature === "076e081df86e884f04cf7cb680304c35c64e6f76238de7060528c59097ae5c46" && navyChapelBehavior.geometry_contract.visual_mesh_instances === 6 && navyChapelBehavior.geometry_contract.visual_surfaces === 6 && navyChapelBehavior.geometry_contract.visual_triangles === 540, "Navy Chapel visual geometry parity drifted");
assert(navyChapelBehavior.geometry_contract.world_topology_scope === PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE && navyChapelBehavior.geometry_contract.world_records === 735 && navyChapelBehavior.geometry_contract.world_mesh_instances === 944 && navyChapelBehavior.geometry_contract.world_surfaces === 957 && navyChapelBehavior.geometry_contract.world_triangles === 64572 && navyChapelBehavior.geometry_contract.world_static_bodies === 466 && navyChapelBehavior.geometry_contract.world_shapes === 466, "Navy Chapel pre-B201 integration world topology parity drifted");
assert(navyChapelBehavior.ownership_contract.live_ownership_signature === "4766c5d562933eb632f1ef3bdcec828fc40be81c996db919c53405f776fa04a7" && navyChapelBehavior.ownership_contract.structural_owner_count === 2 && navyChapelBehavior.ownership_contract.shape_count === 2 && navyChapelBehavior.ownership_contract.spray_owner_count === 1 && navyChapelBehavior.ownership_contract.wall_collision_triangles === 94 && navyChapelBehavior.ownership_contract.roof_collision_triangles === 50 && navyChapelBehavior.ownership_contract.wall_is_sole_spray_receiver === true && navyChapelBehavior.ownership_contract.roof_is_wall_spray_receiver === false, "Navy Chapel collision/spray ownership parity drifted");
const d1B201Adapter = registry.active_runtime_adapters.find((adapter) => adapter.receiver_key === "building:w34313545:wall");
const d1B201AssetPaths = d1B201Adapter.runtime_assets.map((asset) => asset.path).sort();
const d1B201Behavior = d1B201Adapter.active_runtime_contract.behavior_contract;
const expectedD1B201AssetPaths = [
  "res://game/resources/facades/d1_current/d1_b201_live_attachment.json",
  "res://game/resources/materials/world/d1_current/b201_green_hierarchy.tres",
  "res://game/resources/materials/world/d1_current/b201_muted_rust_post.tres",
  "res://game/resources/materials/world/d1_current/b201_service_leaf.tres",
  "res://game/resources/materials/world/d1_current/b201_warm_wall.tres",
  "res://game/resources/materials/world/d1_current/shared_dark_glass.tres",
  "res://game/resources/materials/world/d1_current/shared_pale_frame.tres",
  "res://game/scripts/world/facades/d1_b201_live_attachment.gd",
].sort();
assert(d1B201Adapter.attachment_kind === "active_d1_b201_receiver_host_partition_attachment" && d1B201Adapter.runtime_content_mode === "active_d1_b201_host_partition_attachment", "D1 B201 active classification drifted");
assert(d1B201Adapter.active_receiver_scope.coverage === "whole_direct_wall_receiver" && d1B201Adapter.active_receiver_scope.run_count === 40, "D1 B201 active receiver scope drifted");
assert(JSON.stringify(d1B201AssetPaths) === JSON.stringify(expectedD1B201AssetPaths) && d1B201Adapter.runtime_asset_projections.length === 0, "D1 B201 exact eight-asset dependency closure is incomplete or source-bearing");
assert(d1B201Behavior.acceptance_contract.independent_live_review_receipt_sha256 === "b9ef912df2dd00fa2c456a8e7e03473001cc381cbc2dd5288e9f6ef65d8c2772" && d1B201Behavior.acceptance_contract.evidence_manifest_sha256 === "f169085620a0a9ff0c685e4dfa98442c5c31e4e580f1decdbd80e84b09c74fe3" && d1B201Behavior.acceptance_contract.numerator_effect === 1, "D1 B201 acceptance receipt or one-unit rollup drifted");
assert(d1B201Behavior.geometry_contract.decorative_geometry_signature === "705c5345509f77cd91359f66173fff0e1e132d41ebb9acef3f51ff2c467abb3a" && d1B201Behavior.geometry_contract.host_triangles === 80 && d1B201Behavior.geometry_contract.eligible_host_triangles === 20 && d1B201Behavior.geometry_contract.protected_host_triangles === 60 && d1B201Behavior.geometry_contract.decorative_triangles === 2064, "D1 B201 host partition or decorative geometry parity drifted");
assert(d1B201Behavior.geometry_contract.world_topology_scope === PRE_B225_INTEGRATION_WORLD_TOPOLOGY_SCOPE && d1B201Behavior.geometry_contract.world_records === 735 && d1B201Behavior.geometry_contract.world_mesh_instances === 950 && d1B201Behavior.geometry_contract.world_surfaces === 964 && d1B201Behavior.geometry_contract.world_triangles === 66636 && d1B201Behavior.geometry_contract.world_static_bodies === 466 && d1B201Behavior.geometry_contract.world_shapes === 466, "D1 B201 pre-B225 integration world topology drifted");
assert(d1B201Behavior.ownership_contract.host_collision_owner_preserved === true && d1B201Behavior.ownership_contract.host_spray_owner_preserved === true && d1B201Behavior.ownership_contract.structural_owner_count === 1 && d1B201Behavior.ownership_contract.shape_count === 1 && d1B201Behavior.ownership_contract.spray_owner_count === 1 && d1B201Behavior.ownership_contract.decorative_collision_nodes === 0 && d1B201Behavior.ownership_contract.decorative_navigation_nodes === 0 && d1B201Behavior.ownership_contract.decorative_spray_nodes === 0, "D1 B201 collision/navigation/spray ownership parity drifted");
const d1B225Adapter = registry.active_runtime_adapters.find((adapter) => adapter.receiver_key === "building:w95934119:wall");
const d1B225AssetPaths = d1B225Adapter.runtime_assets.map((asset) => asset.path).sort();
const d1B225Behavior = d1B225Adapter.active_runtime_contract.behavior_contract;
const expectedD1B225AssetPaths = [
  "res://game/resources/facades/d1_current/d1_b225_live_attachment.json",
  "res://game/resources/materials/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_v1.tres",
  "res://game/resources/materials/world/d1_current/shared_dark_glass.tres",
  "res://game/resources/materials/world/d1_current/shared_pale_frame.tres",
  "res://game/resources/textures/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_albedo_v1.png",
  "res://game/scripts/world/facades/d1_b225_live_attachment.gd",
].sort();
assert(d1B225Adapter.adapter_id === "active-adapter:d1-b225-live:building:w95934119:wall" && d1B225Adapter.attachment_kind === "active_d1_b225_receiver_host_partition_attachment" && d1B225Adapter.runtime_content_mode === "active_d1_b225_host_partition_attachment" && d1B225Adapter.recognition_acceptance_status === "accepted", "D1 B225 active authority classification drifted");
assert(d1B225Adapter.active_receiver_scope.coverage === "whole_direct_wall_receiver" && d1B225Adapter.active_receiver_scope.run_count === 14, "D1 B225 active receiver scope drifted");
assert(JSON.stringify(d1B225AssetPaths) === JSON.stringify(expectedD1B225AssetPaths) && d1B225Adapter.runtime_asset_projections.length === 0, "D1 B225 exact six-asset dependency closure is incomplete or source-bearing");
assert(d1B225Adapter.active_runtime_contract.adapter_sha256 === "4b1defd92a77b23de692437f044dfaa579fa2ee5b3dee77465ec8404f1644ac9" && d1B225Adapter.active_runtime_contract.config_sha256 === "80b42c33fce84361aa7512f64305f5bff273e8fed95640ca4f9c19d49d55621d" && d1B225Adapter.active_runtime_contract.dispatch_sha256 === "de4a2924d275a51dfd08aae1f0ef21daac33395b1fcfe98e260fbc90737dd725", "D1 B225 frozen config/adapter or exact-current dispatch pin drifted");
assert(d1B225Behavior.acceptance_contract.accepted_physical_unit_id === "physical-building:w95934119" && d1B225Behavior.acceptance_contract.capture_time_recognition_metric === "7/213" && d1B225Behavior.acceptance_contract.evidence_manifest_sha256 === "96c76fd99960f1345a7c56f7fc6678ac284f98cc601a3ba65ed57020491f18dc" && d1B225Behavior.acceptance_contract.evidence_tree_sha256 === "f42dbec489c6fda55b612aba20c99ee2233857cb60a1ce9c512d024b35d0dcb7" && d1B225Behavior.acceptance_contract.independent_live_review_receipt_sha256 === "87dc2b9febf7110ccd5c1eabed1a290fea5900508561298dd7cf3b6b6fcb1d95" && d1B225Behavior.acceptance_contract.numerator_effect === 1, "D1 B225 frozen acceptance authority drifted");
assert(d1B225Behavior.geometry_contract.decorative_geometry_signature === "02bd8542dea7aa13041728a5244ec962fa121972db17ecf55fad03b3139fe418" && d1B225Behavior.geometry_contract.host_triangles === 28 && d1B225Behavior.geometry_contract.eligible_host_triangles === 8 && d1B225Behavior.geometry_contract.protected_host_triangles === 20 && d1B225Behavior.geometry_contract.decorative_mesh_instances === 2 && d1B225Behavior.geometry_contract.decorative_surfaces === 2 && d1B225Behavior.geometry_contract.decorative_triangles === 1080, "D1 B225 host partition or decorative geometry parity drifted");
assert(d1B225Behavior.geometry_contract.world_topology_scope === CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE && d1B225Behavior.geometry_contract.world_records === 735 && d1B225Behavior.geometry_contract.world_mesh_instances === 952 && d1B225Behavior.geometry_contract.world_surfaces === 967 && d1B225Behavior.geometry_contract.world_triangles === 67716 && d1B225Behavior.geometry_contract.world_static_bodies === 466 && d1B225Behavior.geometry_contract.world_shapes === 466, "D1 B225 exact-current integration topology drifted");
assert(d1B225Behavior.replacement_contract.eligible_run_indices.join(",") === "10,11,12,13" && d1B225Behavior.replacement_contract.protected_run_indices.join(",") === "0,1,2,3,4,5,6,7,8,9", "D1 B225 eligible/protected host partition drifted");
assert(d1B225Behavior.ownership_contract.host_collision_owner_preserved === true && d1B225Behavior.ownership_contract.host_spray_owner_preserved === true && d1B225Behavior.ownership_contract.structural_owner_count === 1 && d1B225Behavior.ownership_contract.shape_count === 1 && d1B225Behavior.ownership_contract.spray_owner_count === 1 && d1B225Behavior.ownership_contract.decorative_collision_nodes === 0 && d1B225Behavior.ownership_contract.decorative_navigation_nodes === 0 && d1B225Behavior.ownership_contract.decorative_spray_nodes === 0, "D1 B225 collision/navigation/spray ownership parity drifted");
const currentTopologyOwners = registry.active_runtime_adapters.filter((adapter) => adapter.active_runtime_contract?.behavior_contract?.geometry_contract?.world_topology_scope === CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE).map((adapter) => adapter.adapter_id);
assert(JSON.stringify(currentTopologyOwners) === JSON.stringify(["active-adapter:d1-b225-live:building:w95934119:wall"]), "D1 B225 is not the sole current-integration topology authority");
assert(!inputs.runtimeContracts.worldBuilderText.includes("facade_runtime_registry_loader"), "Generic facade registry loader was wired into world construction");
const registryText = stableJson(registry);
assert(!registryText.includes("building_1_recognizable_facade") && !registryText.includes("building_1_recognizability_placements"), "registry retains obsolete Building 1 facade assets");

const packageBoundary = report.package_boundary;
assert(packageBoundary.registry_json_clean === true && packageBoundary.runtime_referenced_dependency_closure_clean === true, "package boundary is not fully passing");
assert(packageBoundary.projected_direct_asset_count > 0 && packageBoundary.dependency_closure_forbidden_asset_count > 0, "source-bearing assets were not detected and projected");
assert(packageBoundary.clean_direct_asset_count + packageBoundary.projected_direct_asset_count === packageBoundary.direct_asset_count, "package audit direct-asset partition does not reconcile");
assert(packageBoundary.runtime_referenced_asset_count === packageBoundary.clean_direct_asset_count, "registry runtime asset count does not match clean direct assets");

inspectRuntimeBoundary(registry);
const registryBytes = readFileSync(absolute(PATHS.registry));
const registrySha256 = sha256Bytes(registryBytes);
assert(report.runtime_registry_sha256 === registrySha256, "report runtime-registry hash drifted");
assert(registry.build_contract.authoring_catalog_sha256 === sha256File(PATHS.catalog), "registry catalog hash drifted");
assert(report.input_hashes.catalog_schema_sha256 === sha256File(PATHS.schema), "report schema hash drifted");
assert(report.input_hashes.active_building_1_hero_adapter_sha256 === inputs.runtimeContracts.heroAdapterSha256, "report active hero adapter hash drifted");
assert(report.input_hashes.active_building_1_hero_config_sha256 === inputs.runtimeContracts.heroConfigSha256, "report active hero config hash drifted");
assert(report.input_hashes.active_navy_chapel_187_adapter_sha256 === inputs.runtimeContracts.navyChapelLiveAdapterSha256 && report.input_hashes.active_navy_chapel_187_config_sha256 === inputs.runtimeContracts.navyChapelConfigSha256 && report.input_hashes.active_navy_chapel_187_prototype_sha256 === inputs.runtimeContracts.navyChapelPrototypeSha256 && report.input_hashes.active_navy_chapel_187_live_review_receipt_sha256 === "63bd6c5a79db837e3b53b60eea36887cee8c4c66af791715f964f023b926b5a9", "report Navy Chapel authority hashes drifted");
assert(report.input_hashes.active_d1_b201_adapter_sha256 === inputs.runtimeContracts.d1B201LiveAdapterSha256 && report.input_hashes.active_d1_b201_config_sha256 === inputs.runtimeContracts.d1B201ConfigSha256 && report.input_hashes.active_d1_b201_live_review_receipt_sha256 === "b9ef912df2dd00fa2c456a8e7e03473001cc381cbc2dd5288e9f6ef65d8c2772" && report.input_hashes.active_d1_b201_evidence_manifest_sha256 === "f169085620a0a9ff0c685e4dfa98442c5c31e4e580f1decdbd80e84b09c74fe3", "report D1 B201 authority hashes drifted");
assert(report.input_hashes.active_d1_b225_adapter_sha256 === inputs.runtimeContracts.d1B225LiveAdapterSha256 && report.input_hashes.active_d1_b225_config_sha256 === inputs.runtimeContracts.d1B225ConfigSha256 && report.input_hashes.active_d1_b225_live_review_receipt_sha256 === "87dc2b9febf7110ccd5c1eabed1a290fea5900508561298dd7cf3b6b6fcb1d95" && report.input_hashes.active_d1_b225_evidence_manifest_sha256 === "96c76fd99960f1345a7c56f7fc6678ac284f98cc601a3ba65ed57020491f18dc" && report.input_hashes.active_d1_b225_evidence_tree_sha256 === "f42dbec489c6fda55b612aba20c99ee2233857cb60a1ce9c512d024b35d0dcb7", "report D1 B225 frozen authority hashes drifted");
assert(report.input_hashes.world_chunk_builder_sha256 === inputs.runtimeContracts.worldBuilderSha256, "report active dispatch hash drifted");
assert(report.reference_dependencies.identity_or_reference_research_required_unit_count === 60, "reference-dependency count is not 60");
assert(report.reference_dependencies.unit_ids.length === 60, "reference-dependency unit list is not 60");
assert(report.reference_recognition_metric.display === "8/213" && JSON.stringify(report.reference_recognition_metric.accepted_physical_unit_ids) === JSON.stringify(ACCEPTED_REFERENCE_UNIT_IDS), "validation report recognition metric is not exactly 8/213");

const firstSerialization = stableJson(compiled.registry);
const secondSerialization = stableJson(compile(catalog, inputs).registry);
assert(firstSerialization === secondSerialization, "two clean in-memory compiles are not byte-identical");
assert(sha256Bytes(firstSerialization) === registrySha256, "clean compile hash differs from checked-in registry hash");

function expectThrown(callback, expectedText, label) {
  let thrown = null;
  try {
    callback();
  } catch (error) {
    thrown = error;
  }
  assert(thrown !== null, `${label} accepted invalid mutation`);
  assert(String(thrown.message).includes(expectedText), `${label} returned unexpected error: ${thrown.message}`);
}

function expectCompileFailure(mutator, expectedText) {
  const candidate = structuredClone(catalog);
  mutator(candidate);
  expectThrown(() => compile(candidate, inputs), expectedText, "catalog compiler");
}

function expectCompileFailureWithInputs(candidateInputs, expectedText) {
  expectThrown(() => compile(catalog, candidateInputs), expectedText, "runtime-input compiler");
}

function expectRegistryFailure(mutator, expectedText) {
  const candidate = structuredClone(registry);
  mutator(candidate);
  expectThrown(() => validateRuntimeRegistry(candidate), expectedText, "runtime registry validator");
}

function expectSchemaDocumentFailure(mutator, expectedText) {
  const candidate = structuredClone(schema);
  mutator(candidate);
  expectThrown(() => assertSchemaDocument(candidate, "mutated schema"), expectedText, "schema-document validator");
}

function replaceExactlyOnce(source, before, after, label) {
  const occurrenceCount = source.split(before).length - 1;
  assert(occurrenceCount === 1, `${label} mutation token count is ${occurrenceCount}, expected exactly one`);
  const mutated = source.replace(before, after);
  assert(mutated !== source, `${label} mutation was a no-op`);
  return mutated;
}

let negativeControlRejected = false;
try {
  expectThrown(() => {}, "unreachable", "no-op negative control");
} catch (error) {
  negativeControlRejected = String(error.message).includes("no-op negative control accepted invalid mutation");
}
assert(negativeControlRejected, "failure harness did not reject a passing/no-op callback");

expectCompileFailure(
  (candidate) => {
    candidate.units[0].identity.canonical_name = "silently overwritten";
  },
  ".identity drifted from immutable inventory",
);
expectCompileFailure(
  (candidate) => {
    candidate.identity_evidence_records[0].frozen_value = "08000082";
  },
  "frozen value does not exactly match immutable inventory",
);
expectCompileFailure(
  (candidate) => {
    candidate.units.find((unit) => unit.unit_id === "physical-building:w34313515").claim_status.reference_recognizable = "accepted";
  },
  "cannot accept reference recognizability before reference readiness",
);
expectCompileFailure(
  (candidate) => {
    candidate.units[0].claim_status.unexpected_claim = "accepted";
  },
  "additional property unexpected_claim is forbidden",
);
expectCompileFailure(
  (candidate) => {
    candidate.units[0].claim_status.game_distinctive = "fictional_acceptance";
  },
  "outside enum",
);
expectCompileFailure(
  (candidate) => {
    candidate.units.pop();
  },
  "has 212 items; minimum is 213",
);
expectCompileFailure(
  (candidate) => {
    candidate.active_runtime_adapters[0].content_classification = "obsolete_legacy_facade";
  },
  "does not match any anyOf branch",
);
expectCompileFailure(
  (candidate) => {
    delete candidate.active_runtime_adapters[0].review_status_scope;
  },
  "does not match any anyOf branch",
);
expectCompileFailure(
  (candidate) => {
    candidate.active_runtime_adapters[0].review_status_scope = "reference_recognition_pending";
  },
  "does not match any anyOf branch",
);
expectCompileFailure(
  (candidate) => {
    candidate.active_runtime_adapters[0].recognition_acceptance_authority = "runtime_adapter_self_assertion";
  },
  "does not match any anyOf branch",
);
expectCompileFailure(
  (candidate) => {
    candidate.active_runtime_adapters[0].recognition_acceptance_status = "not_evaluated";
  },
  "does not match any anyOf branch",
);
expectCompileFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:r16681702:wall");
    adapter.review_status = "independent_exact_current_live_pass";
  },
  "does not match any anyOf branch",
);
expectCompileFailure(
  (candidate) => {
    const unit = candidate.units.find((item) => item.unit_id === "physical-building:w34313545");
    unit.acceptance_records = [];
  },
  "lacks independent reference-recognition acceptance",
);
expectCompileFailure(
  (candidate) => {
    const unit = candidate.units.find((item) => item.unit_id === "physical-building:w34313545");
    unit.acceptance_records[0].status = "reject";
  },
  "lacks independent reference-recognition acceptance",
);
expectCompileFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:r16681702:wall");
    const index = adapter.runtime_asset_paths.indexOf("game/resources/facades/building_1_public_front_believability.json");
    adapter.runtime_asset_paths[index] = "game/resources/materials/world/building_1/substituted-public-front-config.tres";
  },
  "does not match any anyOf branch",
);
expectSchemaDocumentFailure(
  (candidate) => {
    candidate.properties.units.items.$ref = "#/$defs/missing_unit";
  },
  "unresolved $ref #/$defs/missing_unit",
);
expectSchemaDocumentFailure(
  (candidate) => {
    const paths = candidate.$defs.building_1_active_runtime_adapter.properties.runtime_asset_paths;
    delete paths.contains;
  },
  "minContains/maxContains require contains",
);

const missingHeroDispatchInputs = {
  ...inputs,
  runtimeContracts: {
    ...inputs.runtimeContracts,
    worldBuilderText: replaceExactlyOnce(inputs.runtimeContracts.worldBuilderText,
      "return BUILDING_1_HERO_MODEL.build_record(record)",
      "return _build_record_without_hero(record)",
      "Building 1 dispatch",
    ),
  },
};
expectCompileFailureWithInputs(missingHeroDispatchInputs, "no longer dispatches Building 1/tower records through the hero adapter");

const missingBuilding3DispatchInputs = {
  ...inputs,
  runtimeContracts: {
    ...inputs.runtimeContracts,
    worldBuilderText: replaceExactlyOnce(inputs.runtimeContracts.worldBuilderText,
      "return BUILDING_3_MASSING.build_record(",
      "return _build_record_without_building_3(",
      "Building 3 dispatch",
    ),
  },
};
expectCompileFailureWithInputs(missingBuilding3DispatchInputs, "no longer dispatches Building 3 wall/roof through the hero massing adapter");

const missingNavyChapelDispatchInputs = {
  ...inputs,
  runtimeContracts: {
    ...inputs.runtimeContracts,
    worldBuilderText: replaceExactlyOnce(inputs.runtimeContracts.worldBuilderText,
      "NAVY_CHAPEL_187_LIVE_REPLACEMENT.build_chunk_plan(chapel_pair)",
      "_build_chunk_without_navy_chapel(chapel_pair)",
      "Navy Chapel dispatch",
    ),
  },
};
expectCompileFailureWithInputs(missingNavyChapelDispatchInputs, "World builder Navy Chapel paired dispatch drifted");

const missingD1B201DispatchInputs = {
  ...inputs,
  runtimeContracts: {
    ...inputs.runtimeContracts,
    worldBuilderText: replaceExactlyOnce(inputs.runtimeContracts.worldBuilderText,
      "D1_B201_LIVE_ATTACHMENT.build_prepared(record, b201_prepared)",
      "_build_record_without_d1_b201(record, b201_prepared)",
      "D1 B201 dispatch",
    ),
  },
};
expectCompileFailureWithInputs(missingD1B201DispatchInputs, "World builder D1 B201 dispatch drifted");

const missingD1B225DispatchInputs = {
  ...inputs,
  runtimeContracts: {
    ...inputs.runtimeContracts,
    worldBuilderText: replaceExactlyOnce(inputs.runtimeContracts.worldBuilderText,
      "D1_B225_LIVE_ATTACHMENT.build_prepared(record, b225_prepared)",
      "_build_record_without_d1_b225(record, b225_prepared)",
      "D1 B225 dispatch",
    ),
  },
};
expectCompileFailureWithInputs(missingD1B225DispatchInputs, "World builder D1 B225 dispatch drifted");

expectRegistryFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w34313540:wall");
    adapter.active_runtime_contract.behavior_contract.collision_contract.spray_ownership = "wall_and_roof";
  },
  "Building 3 dependency or wall/roof behavior parity contract drifted",
);

expectRegistryFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building-composite:w1249412094:w1282547787:wall");
    const geometry = adapter.active_runtime_contract.behavior_contract.geometry_contract;
    const original = geometry.world_topology_scope;
    geometry.world_topology_scope = CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE;
    assert(geometry.world_topology_scope !== original, "Isle House topology-scope mutation was a no-op");
  },
  "Active Isle House low receiver acceptance, dependency, or behavior parity contract drifted",
);

expectRegistryFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w291189336:wall");
    const geometry = adapter.active_runtime_contract.behavior_contract.geometry_contract;
    const original = geometry.world_topology_scope;
    geometry.world_topology_scope = CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE;
    assert(geometry.world_topology_scope !== original, "Navy Chapel topology-scope mutation was a no-op");
  },
  "Active Navy Chapel acceptance, paired dependency, or ownership parity contract drifted",
);

expectRegistryFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w34313545:wall");
    const geometry = adapter.active_runtime_contract.behavior_contract.geometry_contract;
    const original = geometry.world_topology_scope;
    geometry.world_topology_scope = PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE;
    assert(geometry.world_topology_scope !== original, "D1 B201 topology-scope mutation was a no-op");
  },
  "Active D1 B201 acceptance, dependency, host-partition, or ownership parity contract drifted",
);

expectRegistryFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w95934119:wall");
    adapter.active_runtime_contract.behavior_contract.geometry_contract.world_triangles = 67715;
  },
  "Active D1 B225 acceptance, dependency, host-partition, or ownership parity contract drifted",
);

expectRegistryFailure(
  (candidate) => {
    const unit = candidate.units.find((item) => item.unit_id === "physical-building:w95934119");
    unit.acceptance_records[0].evidence_tree_sha256 = "0".repeat(64);
  },
  "evidence tree pin drifted",
);

expectRegistryFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w34313545:wall");
    adapter.review_status_scope = "reference_recognition_pending";
  },
  "review status scope does not isolate runtime-asset original-detail provenance",
);

expectRegistryFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w34313545:wall");
    adapter.recognition_acceptance_authority = "runtime_adapter_self_assertion";
  },
  "recognition authority does not belong to the physical-unit claim and independent receipt",
);

expectRegistryFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w34313545:wall");
    adapter.recognition_acceptance_status = "not_evaluated";
  },
  "recognition acceptance status does not equal its accepted physical-unit claim",
);

expectRegistryFailure(
  (candidate) => {
    const unit = candidate.units.find((item) => item.unit_id === "physical-building:w34313545");
    unit.acceptance_records = [];
  },
  "physical recognition unit lacks an independent acceptance receipt",
);

expectRegistryFailure(
  (candidate) => {
    const unit = candidate.units.find((item) => item.unit_id === "physical-building:w34313545");
    unit.acceptance_records[0].status = "reject";
  },
  "physical recognition unit lacks an independent acceptance receipt",
);

expectRegistryFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w291189336:wall");
    adapter.active_runtime_contract.behavior_contract.ownership_contract.roof_collision_triangles = 49;
  },
  "Active Navy Chapel acceptance, paired dependency, or ownership parity contract drifted",
);

expectRegistryFailure(
  (candidate) => {
    const main = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:r16681702:wall");
    const tower = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w1222720021:wall");
    [main.source_key, tower.source_key] = [tower.source_key, main.source_key];
  },
  "receiver/source mapping, or exact 11-asset closure drifted",
);

expectRegistryFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:r16681702:wall");
    const target = adapter.runtime_assets.findIndex((asset) => asset.path.endsWith("building_1_bronze.tres"));
    adapter.runtime_assets[target] = structuredClone(adapter.runtime_assets.find((asset) => asset.path.endsWith("building_1_bluegrey_glass.tres")));
  },
  "receiver/source mapping, or exact 11-asset closure drifted",
);

expectRegistryFailure(
  (candidate) => {
    const adapter = candidate.legacy_adapters.find((item) => item.receiver_key === "building:w34313515:wall");
    const dirtyPath = "game/resources/facades/w34313515_module_calibration.json";
    adapter.runtime_assets.push({ path: `res://${dirtyPath}`, sha256: sha256File(dirtyPath) });
  },
  "runtime asset dependency closure contains a source-only path or URL",
);
expectRegistryFailure(
  (candidate) => {
    const adapter = candidate.legacy_adapters.find((item) => item.runtime_asset_projections.length > 0);
    adapter.runtime_asset_projections[0].path = "res://game/resources/facades/source-bearing.json";
  },
  "runtime projection keys drifted",
);
expectRegistryFailure(
  (candidate) => {
    const isle = candidate.units.find((unit) => unit.unit_id === "physical-building:w1249412094");
    const low = isle.direct_receivers.find((receiver) => receiver.receiver_key.endsWith(":w1282547787:wall"));
    low.runtime_content_mode = "legacy_adapter";
    low.runtime_adapter_id = "legacy-adapter:building-composite:w1249412094:w1282547786:wall";
  },
  "Isle House low receiver is not bound to its exact active Variant C adapter",
);

expectRegistryFailure(
  (candidate) => {
    candidate.recognition_metric.numerator = 7;
    candidate.recognition_metric.display = "7/213";
  },
  "Runtime physical-entity recognition metric drifted from exactly 8/213",
);

expectRegistryFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w34313545:wall");
    adapter.active_receiver_scope.coverage = "eligible_runs_only";
  },
  "Active D1 B201 acceptance, dependency, host-partition, or ownership parity contract drifted",
);

expectRegistryFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w34313545:wall");
    adapter.active_receiver_scope.run_count = 39;
  },
  "Active D1 B201 acceptance, dependency, host-partition, or ownership parity contract drifted",
);

expectRegistryFailure(
  (candidate) => {
    const isle = candidate.units.find((unit) => unit.unit_id === "physical-building:w1249412094");
    isle.acceptance_records[0].review_receipt_sha256 = "0".repeat(64);
  },
  "review receipt pin drifted",
);

console.log(
  `PASS facade recognition registry: ${EXPECTED.recognition_units} physical units / ${EXPECTED.direct_wall_receivers} receivers / ${EXPECTED.source_records} source records / ${EXPECTED.visible_wall_runs} runs / 8/213 independently accepted reference-recognizable physical units / ${EXPECTED.legacy_adapter_receivers} claim-neutral legacy adapters + ${EXPECTED.active_runtime_adapter_receivers} exact-current active adapters / ${packageBoundary.projected_direct_asset_count} sanitized asset projections / 2 separated identity corrections / 60 reference dependencies; catalog ${sha256File(PATHS.catalog)}; registry ${registrySha256}`,
);
