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
  validateCurrentWorldBuilderDispatch,
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
  "physical-building:w95934105",
  "physical-building:w95934117",
  "physical-building:w95934119",
  "physical-building:w95934144",
  "physical-building:w95934125",
  "physical-building:w764313741",
  "physical-building:r19685981",
  "physical-building:w96215670",
  "physical-building:w96215685",
  "physical-building:w96215688",
  "physical-building:w96215673",
  "physical-building:w96215674",
  "physical-building:w96215682",
  "physical-building:w96215659",
  "physical-building:w96215666",
  "physical-building:w96215661",
  "physical-building:w96215653",
  "physical-building:w96215651",
  "physical-building:w96215649",
  "physical-building:w96215652",
  "physical-building:w96215658",
  "physical-building:w96215677",
  "physical-building:w96215680",
  "physical-building:w96215672",
  "physical-building:w96215669",
  "physical-building:w96215646",
  "physical-building:w95934123",
].sort();
const ACTIVE_REVIEW_STATUS_SCOPE = "runtime_asset_original_detail_provenance_only_not_reference_recognition";
const ACTIVE_RECOGNITION_ACCEPTANCE_AUTHORITY = "physical_unit_claim_and_independent_acceptance_record";
const PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "pre_b201_integration_live_parity";
const PRE_B225_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "pre_b225_integration_live_parity";
const PRE_D2_1441_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "pre_d2_1441_integration_live_parity";
const PRE_D2_1439_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "pre_d2_1439_integration_live_parity";
const PRE_D2_1444_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "pre_d2_1444_integration_live_parity";
const CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "current_integration_topology";
const D2_1441_ACCEPTANCE_RECORD = Object.freeze({
  capture_time_recognition_metric: "8/213",
  evidence_manifest_sha256: "3c11ba6412da6a062d89142594c7b785bf546b5c1905dc32bdd7ce7806fd6885",
  evidence_tree_sha256: "e52d66e479f268a9e75372da111d9c93cc1972dd1fddca9a6cb29bb6e41a4a43",
  mechanical_review_receipt_sha256: "c39800b1632d1e8b5e05720d02d9499e2788aaf9ef2cf0f1bb1f2b20353b7884",
  motion_telemetry_manifest_sha256: "21e2b60a8fee1bcfeb984ece6124684c15ae5b1be7fb8a813f18bc0c3b240fcd",
  numerator_effect: 1,
  package_verification_receipt_sha256: "cbcda89ec1e013c3406cf919d7c7e3bcefe0df7f005be1ea0e250bfbdada1061",
  review_id: "d2-1441-production-v8-staging-2026-09-05-009",
  review_kind: "independent_reference_recognition",
  review_receipt_sha256: "075dfb63e4e015cdcc2201e627da5542566d21f9d1163268f790681729ae7144",
  status: "accept",
  visual_motion_manifest_sha256: "c885f6450d3eaac4814bde83beff1bbdccea3ae992e07a62c1e9dd8fc1259cad",
});
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
  ["building:r19685981:wall", "physical-building:r19685981"],
  ["building:w96215670:wall", "physical-building:w96215670"],
  ["building:w96215685:wall", "physical-building:w96215685"],
  ["building:w96215688:wall", "physical-building:w96215688"],
  ["building:w96215673:wall", "physical-building:w96215673"],
  ["building:w96215674:wall", "physical-building:w96215674"],
  ["building:w96215682:wall", "physical-building:w96215682"],
  ["building:w96215659:wall", "physical-building:w96215659"],
  ["building:w96215666:wall", "physical-building:w96215666"],
  ["building:w96215661:wall", "physical-building:w96215661"],
  ["building:w96215653:wall", "physical-building:w96215653"],
  ["building:w96215651:wall", "physical-building:w96215651"],
  ["building:w96215649:wall", "physical-building:w96215649"],
  ["building:w96215652:wall", "physical-building:w96215652"],
  ["building:w96215658:wall", "physical-building:w96215658"],
  ["building:w96215677:wall", "physical-building:w96215677"],
  ["building:w96215680:wall", "physical-building:w96215680"],
  ["building:w96215672:wall", "physical-building:w96215672"],
  ["building:w96215669:wall", "physical-building:w96215669"],
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
  ["building:r19685981:wall", "independent_exact_current_live_pass"],
  ["building:w96215670:wall", "independent_exact_current_live_pass"],
  ["building:w96215685:wall", "independent_exact_current_live_pass"],
  ["building:w96215688:wall", "independent_exact_current_live_pass"],
  ["building:w96215673:wall", "independent_exact_current_live_pass"],
  ["building:w96215674:wall", "independent_exact_current_live_pass"],
  ["building:w96215682:wall", "independent_exact_current_live_pass"],
  ["building:w96215659:wall", "independent_exact_current_live_pass"],
  ["building:w96215666:wall", "independent_exact_current_live_pass"],
  ["building:w96215661:wall", "independent_exact_current_live_pass"],
  ["building:w96215653:wall", "independent_exact_current_live_pass"],
  ["building:w96215651:wall", "independent_exact_current_live_pass"],
  ["building:w96215649:wall", "independent_exact_current_live_pass"],
  ["building:w96215652:wall", "independent_exact_current_live_pass"],
  ["building:w96215658:wall", "independent_exact_current_live_pass"],
  ["building:w96215677:wall", "independent_exact_current_live_pass"],
  ["building:w96215680:wall", "independent_exact_current_live_pass"],
  ["building:w96215672:wall", "independent_exact_current_live_pass"],
  ["building:w96215669:wall", "independent_exact_current_live_pass"],
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
validateCurrentWorldBuilderDispatch(inputs);
assert(inputs.runtimeContracts.acceptedWorldBuilderSha256 === "7107dc0789e8ca8ee13d53510293a39b3f64e9a92e0ee81bef7317d90a08a87a", "accepted dispatch provenance is not the reviewed D2 1441 builder");
assert(inputs.runtimeContracts.currentWorldBuilderSha256 === sha256Bytes(inputs.runtimeContracts.worldBuilderText), "current builder text/hash binding is not exact");
for (const expectation of [
  { count: 1, marker: 'const D2_1441_CHINOOK_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd")' },
  { count: 1, marker: "D2_1441_CHINOOK_LIVE_REPLACEMENT.prepare_chunk_records(chunk)" },
  { count: 1, marker: "D2_1441_CHINOOK_LIVE_REPLACEMENT.build_chunk_plan(d2_1441_pair)" },
  { count: 1, marker: "D2_1441_CHINOOK_LIVE_REPLACEMENT.claims_record(record)" },
  { count: 1, marker: "D2_1441_CHINOOK_LIVE_REPLACEMENT.consume_record(record, d2_1441_plan)" },
  { count: 1, marker: "D2_1441_CHINOOK_LIVE_REPLACEMENT.plan_was_fully_consumed(d2_1441_plan)" },
  { count: 1, marker: 'rollback_plans.append({"adapter": D2_1441_CHINOOK_LIVE_REPLACEMENT, "plan": d2_1441_plan})' },
]) assert(inputs.runtimeContracts.worldBuilderText.split(expectation.marker).length - 1 === expectation.count, `positive current D2 direct seam marker is not exact: ${expectation.marker}`);
assert(inputs.runtimeContracts.d21441EvidenceTree.file_count === 40 && inputs.runtimeContracts.d21441EvidenceTree.sha256 === D2_1441_ACCEPTANCE_RECORD.evidence_tree_sha256, "D2 1441 exact canonical packet tree is not bound");
assert(inputs.runtimeContracts.d21441EvidenceManifestSha256 === D2_1441_ACCEPTANCE_RECORD.evidence_manifest_sha256 && inputs.runtimeContracts.d21441MotionTelemetryManifestSha256 === D2_1441_ACCEPTANCE_RECORD.motion_telemetry_manifest_sha256 && inputs.runtimeContracts.d21441VisualMotionManifestSha256 === D2_1441_ACCEPTANCE_RECORD.visual_motion_manifest_sha256 && inputs.runtimeContracts.d21441PackageVerificationReceiptSha256 === D2_1441_ACCEPTANCE_RECORD.package_verification_receipt_sha256, "D2 1441 packet manifests/receipt are not rehashed to the acceptance record");
assert(inputs.runtimeContracts.d21441MechanicalReviewSha256 === D2_1441_ACCEPTANCE_RECORD.mechanical_review_receipt_sha256 && inputs.runtimeContracts.d21441VisualReviewSha256 === D2_1441_ACCEPTANCE_RECORD.review_receipt_sha256, "D2 1441 independent review bytes are not rehashed to the acceptance record");
assert(inputs.runtimeContracts.d21441MechanicalReviewText.includes("PASS_FOR_1441_PROMOTION_NO_CREDIT") && inputs.runtimeContracts.d21441VisualReviewText.includes("PASS_FOR_1441_PROMOTION_NO_CREDIT"), "D2 1441 independent reviews do not both contain the exact promotion PASS verdict");
for (const document of [inputs.runtimeContracts.d21441EvidenceManifest, inputs.runtimeContracts.d21441MotionTelemetryManifest, inputs.runtimeContracts.d21441VisualMotionManifest, inputs.runtimeContracts.d21441PackageVerificationReceipt]) {
  assert(document.capture_time_recognition_metric === "8/213" && document.recognition_credit === false && document.additional_recognition_credit === false && document.promotion === false, "D2 1441 frozen capture artifact violates its no-credit boundary");
}
assert(schema.$schema === "https://json-schema.org/draft/2020-12/schema", "catalog schema is not JSON Schema 2020-12");
assert(schema.properties.schema_version.const === CATALOG_SCHEMA, "catalog schema version constraint drifted");
assert(schema.properties.units.minItems === EXPECTED.recognition_units && schema.properties.units.maxItems === EXPECTED.recognition_units, "catalog schema does not pin 213 units");
assert(schema.properties.capture_contracts.items.$ref === "#/$defs/capture_contract", "catalog schema lacks capture contracts");
assert(schema.properties.identity_evidence_records.items.$ref === "#/$defs/identity_evidence_record", "catalog schema lacks separate identity evidence");
assert(schema.properties.active_runtime_adapters.minItems === EXPECTED.active_runtime_adapter_receivers && schema.properties.active_runtime_adapters.maxItems === EXPECTED.active_runtime_adapter_receivers, "catalog schema does not pin the current active runtime adapter count");
const building1AdapterSchema = schema.$defs.building_1_active_runtime_adapter.properties.runtime_asset_paths;
assert(building1AdapterSchema.contains.const === "game/resources/facades/building_1_public_front_believability.json" && building1AdapterSchema.minContains === 1 && building1AdapterSchema.maxContains === 1, "catalog schema does not require exactly one Building 1 public-front config member");
const d21441AdapterSchema = schema.$defs.d2_1441_active_runtime_adapter;
assert(d21441AdapterSchema.properties.adapter_id.const === "active-adapter:d2-1441-live:building:w95934105:wall", "catalog schema does not pin the exact D2 1441 active adapter ID");
assert(d21441AdapterSchema.properties.runtime_asset_paths.minItems === 11 && d21441AdapterSchema.properties.runtime_asset_paths.maxItems === 11 && d21441AdapterSchema.properties.runtime_asset_paths.items.enum.length === 11, "catalog schema does not pin the exact eleven-path D2 1441 asset closure");
for (const field of ["mechanical_review_receipt_sha256", "motion_telemetry_manifest_sha256", "package_verification_receipt_sha256", "visual_motion_manifest_sha256"]) {
  assert(schema.$defs.acceptance_record.properties[field].$ref === "#/$defs/sha256", `catalog schema does not type the D2 1441 acceptance field ${field} as SHA-256`);
}
for (const reference of schema.$defs.active_runtime_adapter.anyOf) {
  const definition = schema.$defs[reference.$ref.slice("#/$defs/".length)];
  assert(definition.required.includes("review_status_scope") && definition.required.includes("recognition_acceptance_authority") && definition.required.includes("recognition_acceptance_status"), `${reference.$ref} does not require the exact active-adapter recognition-authority fields`);
  assert(definition.properties.review_status_scope.const === ACTIVE_REVIEW_STATUS_SCOPE, `${reference.$ref} review-status scope is not exact`);
  assert(definition.properties.recognition_acceptance_authority.const === ACTIVE_RECOGNITION_ACCEPTANCE_AUTHORITY, `${reference.$ref} recognition authority is not exact`);
  assert(definition.properties.recognition_acceptance_status.const === "accepted", `${reference.$ref} recognition acceptance is not fail-closed to accepted`);
  assert(["pending_independent_original_detail_review", "independent_exact_current_live_pass"].includes(definition.properties.review_status.const), `${reference.$ref} review status is not an exact allowed literal`);
}
assert(catalog.schema_version === CATALOG_SCHEMA, "catalog schema drifted");
assert(Array.isArray(catalog.capture_contracts) && catalog.capture_contracts.length === ACCEPTED_REFERENCE_UNIT_IDS.length, "catalog does not contain the accepted ordinary-player capture contracts");
assert(registry.schema_version === RUNTIME_SCHEMA, "runtime registry schema drifted");
assert(report.schema_version === REPORT_SCHEMA && report.status === "pass", "validation report is not passing");
assert(stableJson(registry) === stableJson(compiled.registry), "checked-in runtime registry differs from a clean compile");
assert(stableJson(report) === stableJson(compiled.report), "checked-in validation report differs from a clean compile");
assert(ADAPTER_CONTRACT_CHECK_ID === "adapter_contract_36_ready_6_disabled_13_unique_projection_inputs", "adapter-contract validation check identifier is not exact-current");
assert(report.checks.filter((check) => check.check_id === ADAPTER_CONTRACT_CHECK_ID && check.status === "pass").length === 1, "validation report does not contain exactly one passing exact-current adapter-contract check identifier");
assert(!report.checks.some((check) => check.check_id === "adapter_contract_6_ready_8_disabled_15_unique_projection_inputs"), "validation report retains the stale adapter-contract check identifier");

assert(registry.units.length === EXPECTED.recognition_units, "runtime registry does not contain 213 recognition units");
assert(registry.legacy_adapters.length === EXPECTED.legacy_adapter_receivers, "runtime registry does not contain nine legacy adapters");
assert(registry.active_runtime_adapters.length === EXPECTED.active_runtime_adapter_receivers, "runtime registry does not contain the current active runtime adapter count");
assert(registry.counts.runtime_adapter_receivers === EXPECTED.runtime_adapter_receivers, "runtime registry does not contain 19 receiver adapters");
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
const d21441Unit = registry.units.find((unit) => unit.unit_id === "physical-building:w95934105");
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
assert(d21441Unit.direct_receivers[0].runtime_content_mode === "active_d2_1441_paired_replacement" && d21441Unit.runtime_content_mode === "all_receivers_active_d2_1441_paired_replacement", "D2 1441 wall is not bound to its exact paired wall/roof replacement");
assert(d21441Unit.active_runtime_adapter_ids.length === 1 && d21441Unit.legacy_adapter_ids.length === 0, "D2 1441 retains obsolete legacy membership or lacks its active adapter");
assert(d21441Unit.acceptance_records.length === 1 && stableJson(d21441Unit.acceptance_records[0]) === stableJson(D2_1441_ACCEPTANCE_RECORD), "D2 1441 authority is not exactly one seven-artifact-bound 8/213 +1 acceptance record");

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
assert(registry.claim_totals.reference_recognizable.accepted === ACCEPTED_REFERENCE_UNIT_IDS.length && registry.claim_totals.reference_recognizable.not_evaluated === EXPECTED.recognition_units - ACCEPTED_REFERENCE_UNIT_IDS.length, "reference-recognizable aggregate is not exactly 11/213");
assert(registry.claim_totals.as_built_fidelity.claimed === 0 && registry.claim_totals.as_built_fidelity.limited === 0, "as-built fidelity must remain wholly unclaimed");
assert(JSON.stringify(registry.recognition_metric.accepted_physical_unit_ids) === JSON.stringify(ACCEPTED_REFERENCE_UNIT_IDS), "recognition metric accepted-unit set drifted");
assert(registry.recognition_metric.numerator === 34 && registry.recognition_metric.denominator === 213 && registry.recognition_metric.display === "34/213", "recognition metric is not exactly 34/213");
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
assert(adapterReceivers.length === EXPECTED.runtime_adapter_receivers, "combined adapter array is not 19 receivers");
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

const expectedActiveReceivers = [...ACTIVE_UNIT_BY_RECEIVER.keys()];
assert(JSON.stringify(registry.active_runtime_adapters.map((adapter) => adapter.receiver_key).sort()) === JSON.stringify(expectedActiveReceivers.sort()), "active runtime receiver set drifted");
for (const adapter of registry.active_runtime_adapters.filter((candidate) => ["building:r16681702:wall", "building:w1222720021:wall"].includes(candidate.receiver_key))) {
  assert(adapter.attachment_kind === "active_building_1_hero_replacement" && adapter.state === "active_runtime_target_specific_content", `${adapter.adapter_id} has stale content classification`);
  assert(adapter.active_receiver_scope.coverage === "whole_direct_wall_receiver", `${adapter.adapter_id} is not scoped to its exact direct receiver`);
  assert(adapter.active_runtime_contract.config_summary.target.tower_remains_separately_reviewable === true, `${adapter.adapter_id} config summary collapses the tower`);
  assert(adapter.runtime_assets.length === 11 && adapter.runtime_asset_projections.length === 0, `${adapter.adapter_id} does not account for its hero script, two configs, and eight exact-current materials`);
  assert(adapter.runtime_assets.some((asset) => asset.path === "res://game/resources/facades/building_1_public_front_believability.json" && asset.sha256 === "99117e1af118592db1d1cfa932b44014862cb8be4f47d0b3ea519e24f9e591fb"), `${adapter.adapter_id} omits the exact current public-front runtime config`);
  assert(adapter.active_runtime_contract.public_front_config_sha256 === "99117e1af118592db1d1cfa932b44014862cb8be4f47d0b3ea519e24f9e591fb", `${adapter.adapter_id} public-front contract hash drifted`);
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
assert(d1B225Adapter.active_runtime_contract.adapter_sha256 === "4b1defd92a77b23de692437f044dfaa579fa2ee5b3dee77465ec8404f1644ac9" && d1B225Adapter.active_runtime_contract.config_sha256 === "80b42c33fce84361aa7512f64305f5bff273e8fed95640ca4f9c19d49d55621d" && d1B225Adapter.active_runtime_contract.dispatch_sha256 === "7107dc0789e8ca8ee13d53510293a39b3f64e9a92e0ee81bef7317d90a08a87a", "D1 B225 frozen config/adapter or accepted D2 dispatch pin drifted");
assert(d1B225Behavior.acceptance_contract.accepted_physical_unit_id === "physical-building:w95934119" && d1B225Behavior.acceptance_contract.capture_time_recognition_metric === "7/213" && d1B225Behavior.acceptance_contract.evidence_manifest_sha256 === "96c76fd99960f1345a7c56f7fc6678ac284f98cc601a3ba65ed57020491f18dc" && d1B225Behavior.acceptance_contract.evidence_tree_sha256 === "f42dbec489c6fda55b612aba20c99ee2233857cb60a1ce9c512d024b35d0dcb7" && d1B225Behavior.acceptance_contract.independent_live_review_receipt_sha256 === "87dc2b9febf7110ccd5c1eabed1a290fea5900508561298dd7cf3b6b6fcb1d95" && d1B225Behavior.acceptance_contract.numerator_effect === 1, "D1 B225 frozen acceptance authority drifted");
assert(d1B225Behavior.geometry_contract.decorative_geometry_signature === "02bd8542dea7aa13041728a5244ec962fa121972db17ecf55fad03b3139fe418" && d1B225Behavior.geometry_contract.host_triangles === 28 && d1B225Behavior.geometry_contract.eligible_host_triangles === 8 && d1B225Behavior.geometry_contract.protected_host_triangles === 20 && d1B225Behavior.geometry_contract.decorative_mesh_instances === 2 && d1B225Behavior.geometry_contract.decorative_surfaces === 2 && d1B225Behavior.geometry_contract.decorative_triangles === 1080, "D1 B225 host partition or decorative geometry parity drifted");
assert(d1B225Behavior.geometry_contract.world_topology_scope === PRE_D2_1441_INTEGRATION_WORLD_TOPOLOGY_SCOPE && d1B225Behavior.geometry_contract.world_records === 735 && d1B225Behavior.geometry_contract.world_mesh_instances === 952 && d1B225Behavior.geometry_contract.world_surfaces === 967 && d1B225Behavior.geometry_contract.world_triangles === 67716 && d1B225Behavior.geometry_contract.world_static_bodies === 466 && d1B225Behavior.geometry_contract.world_shapes === 466, "D1 B225 pre-D2 integration topology drifted");
assert(d1B225Behavior.replacement_contract.eligible_run_indices.join(",") === "10,11,12,13" && d1B225Behavior.replacement_contract.protected_run_indices.join(",") === "0,1,2,3,4,5,6,7,8,9", "D1 B225 eligible/protected host partition drifted");
assert(d1B225Behavior.ownership_contract.host_collision_owner_preserved === true && d1B225Behavior.ownership_contract.host_spray_owner_preserved === true && d1B225Behavior.ownership_contract.structural_owner_count === 1 && d1B225Behavior.ownership_contract.shape_count === 1 && d1B225Behavior.ownership_contract.spray_owner_count === 1 && d1B225Behavior.ownership_contract.decorative_collision_nodes === 0 && d1B225Behavior.ownership_contract.decorative_navigation_nodes === 0 && d1B225Behavior.ownership_contract.decorative_spray_nodes === 0, "D1 B225 collision/navigation/spray ownership parity drifted");
const d21441Adapter = registry.active_runtime_adapters.find((adapter) => adapter.receiver_key === "building:w95934105:wall");
const d21441Behavior = d21441Adapter.active_runtime_contract.behavior_contract;
const expectedD21441AssetPaths = [
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
assert(d21441Adapter.adapter_id === "active-adapter:d2-1441-live:building:w95934105:wall" && d21441Adapter.attachment_kind === "active_d2_1441_paired_wall_roof_replacement" && d21441Adapter.runtime_content_mode === "active_d2_1441_paired_replacement" && d21441Adapter.recognition_acceptance_status === "accepted", "D2 1441 active authority classification drifted");
assert(d21441Adapter.active_receiver_scope.coverage === "whole_direct_wall_receiver" && d21441Adapter.active_receiver_scope.run_count === 16, "D2 1441 active receiver scope drifted");
assert(JSON.stringify(d21441Adapter.runtime_assets.map((asset) => asset.path).sort()) === JSON.stringify(expectedD21441AssetPaths) && d21441Adapter.runtime_asset_projections.length === 0, "D2 1441 exact thirteen-asset dependency closure is incomplete or source-bearing");
assert(d21441Adapter.active_runtime_contract.adapter_sha256 === "bf51562a211126c0ea7b631321dfb021171ad68bffd6dd07667ad504d770b9a1" && d21441Adapter.active_runtime_contract.config_sha256 === "aef5717332cda1cf2ba1457ce9e9e92aaaceae46345595a979813b9369ad8111" && d21441Adapter.active_runtime_contract.dispatch_sha256 === "7107dc0789e8ca8ee13d53510293a39b3f64e9a92e0ee81bef7317d90a08a87a", "D2 1441 config/adapter/dispatch pins drifted");
assert(stableJson(d21441Behavior.acceptance_contract) === stableJson({
  accepted_physical_unit_id: "physical-building:w95934105",
  capture_time_recognition_metric: "8/213",
  evidence_manifest_sha256: D2_1441_ACCEPTANCE_RECORD.evidence_manifest_sha256,
  evidence_tree_sha256: D2_1441_ACCEPTANCE_RECORD.evidence_tree_sha256,
  independent_live_review_receipt_sha256: D2_1441_ACCEPTANCE_RECORD.review_receipt_sha256,
  mechanical_review_receipt_sha256: D2_1441_ACCEPTANCE_RECORD.mechanical_review_receipt_sha256,
  motion_telemetry_manifest_sha256: D2_1441_ACCEPTANCE_RECORD.motion_telemetry_manifest_sha256,
  numerator_effect: 1,
  package_verification_receipt_sha256: D2_1441_ACCEPTANCE_RECORD.package_verification_receipt_sha256,
  reference_recognizable: true,
  visual_motion_manifest_sha256: D2_1441_ACCEPTANCE_RECORD.visual_motion_manifest_sha256,
  wall_and_roof_are_one_physical_unit: true,
}), "D2 1441 behavior acceptance closure drifted");
assert(d21441Behavior.geometry_contract.world_topology_scope === PRE_D2_1439_INTEGRATION_WORLD_TOPOLOGY_SCOPE && d21441Behavior.geometry_contract.world_records === 735 && d21441Behavior.geometry_contract.world_mesh_instances === 959 && d21441Behavior.geometry_contract.world_surfaces === 974 && d21441Behavior.geometry_contract.world_triangles === 70692 && d21441Behavior.geometry_contract.world_static_bodies === 466 && d21441Behavior.geometry_contract.world_shapes === 466, "D2 1441 exact-current integration topology drifted");
assert(d21441Behavior.geometry_contract.visual_geometry_signature === "b91b373e3bb8238a6f73f05734ef48b3429ae5654eddce89b1981ee41ee89195" && d21441Behavior.geometry_contract.visual_mesh_instances === 9 && d21441Behavior.geometry_contract.visual_surfaces === 9 && d21441Behavior.geometry_contract.visual_triangles === 1578 && d21441Behavior.geometry_contract.topology_delta_triangles === 1536, "D2 1441 visual/delta geometry drifted");
assert(d21441Behavior.replacement_contract.mapped_public_run_indices.join(",") === "10,12,13,15" && d21441Behavior.replacement_contract.protected_run_indices.join(",") === "0,1,2,3,4,5,6,7,8,9,11,14" && d21441Behavior.replacement_contract.partial_pair_allowed === false && d21441Behavior.replacement_contract.fallback_allowed === false && d21441Behavior.replacement_contract.generic_stack_allowed === false, "D2 1441 mapped/protected or paired fail-closed contract drifted");
assert(d21441Behavior.ownership_contract.live_ownership_signature === "fcad9968be3d0c9094adef5dcc9c7fabfb7cf1754f780897188a4ec362187e4d" && d21441Behavior.ownership_contract.wall_collision_triangles === 32 && d21441Behavior.ownership_contract.roof_collision_triangles === 10 && d21441Behavior.ownership_contract.wall_is_sole_spray_receiver === true && d21441Behavior.ownership_contract.roof_is_wall_spray_receiver === false && d21441Behavior.ownership_contract.roof_world_solid_landing === true && d21441Behavior.ownership_contract.decorative_collision_triangles === 0 && d21441Behavior.ownership_contract.decorative_navigation_nodes === 0, "D2 1441 collision/navigation/spray/landing ownership drifted");
const currentTopologyOwners = registry.active_runtime_adapters.filter((adapter) => adapter.active_runtime_contract?.behavior_contract?.geometry_contract?.world_topology_scope === CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE).map((adapter) => adapter.adapter_id);
assert(JSON.stringify(currentTopologyOwners) === JSON.stringify(["active-adapter:bayside-1226-live:building:w96215685:wall"]), "1226 is not the sole current-integration topology authority");
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
assert(report.input_hashes.active_d2_1441_adapter_sha256 === "bf51562a211126c0ea7b631321dfb021171ad68bffd6dd07667ad504d770b9a1" && report.input_hashes.active_d2_1441_config_sha256 === "aef5717332cda1cf2ba1457ce9e9e92aaaceae46345595a979813b9369ad8111" && report.input_hashes.active_d2_1441_evidence_manifest_sha256 === D2_1441_ACCEPTANCE_RECORD.evidence_manifest_sha256 && report.input_hashes.active_d2_1441_motion_telemetry_manifest_sha256 === D2_1441_ACCEPTANCE_RECORD.motion_telemetry_manifest_sha256 && report.input_hashes.active_d2_1441_visual_motion_manifest_sha256 === D2_1441_ACCEPTANCE_RECORD.visual_motion_manifest_sha256 && report.input_hashes.active_d2_1441_evidence_tree_sha256 === D2_1441_ACCEPTANCE_RECORD.evidence_tree_sha256 && report.input_hashes.active_d2_1441_package_verification_receipt_sha256 === D2_1441_ACCEPTANCE_RECORD.package_verification_receipt_sha256 && report.input_hashes.active_d2_1441_mechanical_review_receipt_sha256 === D2_1441_ACCEPTANCE_RECORD.mechanical_review_receipt_sha256 && report.input_hashes.active_d2_1441_visual_review_receipt_sha256 === D2_1441_ACCEPTANCE_RECORD.review_receipt_sha256, "report D2 1441 seven-artifact acceptance authority hashes drifted");
assert(report.input_hashes.world_chunk_builder_sha256 === inputs.runtimeContracts.acceptedWorldBuilderSha256, "report accepted dispatch provenance hash drifted");
assert(report.reference_dependencies.identity_or_reference_research_required_unit_count === 60, "reference-dependency count is not 60");
assert(report.reference_dependencies.unit_ids.length === 60, "reference-dependency unit list is not 60");
assert(report.reference_recognition_metric.display === "34/213" && JSON.stringify(report.reference_recognition_metric.accepted_physical_unit_ids) === JSON.stringify(ACCEPTED_REFERENCE_UNIT_IDS), "validation report recognition metric is not exactly 34/213");

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

function expectD21441RuntimeContractFailure(mutator, expectedText) {
  const candidateInputs = {
    ...inputs,
    runtimeContracts: structuredClone(inputs.runtimeContracts),
  };
  mutator(candidateInputs.runtimeContracts);
  expectCompileFailureWithInputs(candidateInputs, expectedText);
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

function duplicateExactlyOnce(source, marker, label) {
  return replaceExactlyOnce(source, marker, `${marker}\n${marker}`, label);
}

function swapExactlyOnce(source, first, second, label) {
  const placeholder = `__${label.replaceAll(" ", "_").toUpperCase()}_SWAP__`;
  assert(!source.includes(placeholder), `${label} swap placeholder is not unique`);
  let mutated = replaceExactlyOnce(source, first, placeholder, `${label} first`);
  mutated = replaceExactlyOnce(mutated, second, first, `${label} second`);
  return replaceExactlyOnce(mutated, placeholder, second, `${label} placeholder`);
}

function withWorldBuilderText(worldBuilderText) {
  return {
    ...inputs,
    runtimeContracts: {
      ...inputs.runtimeContracts,
      currentWorldBuilderSha256: sha256Bytes(worldBuilderText),
      worldBuilderText,
    },
  };
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
    const unit = candidate.units.find((item) => item.unit_id === "physical-building:w95934105");
    unit.acceptance_records = [];
  },
  "lacks independent reference-recognition acceptance",
);
expectCompileFailure(
  (candidate) => {
    const unit = candidate.units.find((item) => item.unit_id === "physical-building:w95934105");
    unit.acceptance_records.push(structuredClone(unit.acceptance_records[0]));
  },
  "review IDs contains duplicates",
);
for (const [field, expectedText] of [
  ["evidence_manifest_sha256", "evidence manifest pin drifted"],
  ["motion_telemetry_manifest_sha256", "D2 1441 seven-artifact acceptance closure drifted"],
  ["visual_motion_manifest_sha256", "D2 1441 seven-artifact acceptance closure drifted"],
  ["evidence_tree_sha256", "D2 1441 seven-artifact acceptance closure drifted"],
  ["package_verification_receipt_sha256", "D2 1441 seven-artifact acceptance closure drifted"],
  ["mechanical_review_receipt_sha256", "D2 1441 seven-artifact acceptance closure drifted"],
  ["review_receipt_sha256", "review receipt pin drifted"],
]) expectCompileFailure(
  (candidate) => {
    const unit = candidate.units.find((item) => item.unit_id === "physical-building:w95934105");
    unit.acceptance_records[0][field] = "0".repeat(64);
  },
  expectedText,
);
expectCompileFailure(
  (candidate) => {
    const unit = candidate.units.find((item) => item.unit_id === "physical-building:w95934105");
    unit.acceptance_records[0].capture_time_recognition_metric = "10/213";
  },
  "D2 1441 seven-artifact acceptance closure drifted",
);
expectCompileFailure(
  (candidate) => {
    const unit = candidate.units.find((item) => item.unit_id === "physical-building:w95934105");
    unit.acceptance_records[0].numerator_effect = 0;
  },
  "D2 1441 seven-artifact acceptance closure drifted",
);
expectCompileFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w95934105:wall");
    adapter.runtime_asset_paths.pop();
  },
  "does not match any anyOf branch",
);
expectCompileFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w95934105:wall");
    adapter.adapter_id = "active-adapter:d2-1441-live:building:w95934119:wall";
  },
  "does not match any anyOf branch",
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

const missingHeroDispatchInputs = withWorldBuilderText(replaceExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "return BUILDING_1_HERO_MODEL.build_record(record)",
  "return _build_record_without_hero(record)",
  "Building 1 dispatch",
));
expectCompileFailureWithInputs(missingHeroDispatchInputs, "building 1 build marker must occur exactly once");

const missingBuilding3DispatchInputs = withWorldBuilderText(replaceExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "return BUILDING_3_MASSING.build_record(",
  "return _build_record_without_building_3(",
  "Building 3 dispatch",
));
expectCompileFailureWithInputs(missingBuilding3DispatchInputs, "building 3 build marker must occur exactly once");

const missingIsleHouseDispatchInputs = withWorldBuilderText(replaceExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "var isle_house_low_result := ISLE_HOUSE_LOW_LIVE_ATTACHMENT.build(record)",
  "var isle_house_low_result := _build_record_without_isle_house(record)",
  "Isle House dispatch",
));
expectCompileFailureWithInputs(missingIsleHouseDispatchInputs, "isle house build marker must occur exactly once");

const missingNavyChapelDispatchInputs = withWorldBuilderText(replaceExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "NAVY_CHAPEL_187_LIVE_REPLACEMENT.build_chunk_plan(chapel_pair)",
  "_build_chunk_without_navy_chapel(chapel_pair)",
  "Navy Chapel dispatch",
));
expectCompileFailureWithInputs(missingNavyChapelDispatchInputs, "navy chapel plan marker must occur exactly once");

const missingD21441DispatchInputs = withWorldBuilderText(replaceExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "D2_1441_CHINOOK_LIVE_REPLACEMENT.build_chunk_plan(d2_1441_pair)",
  "_build_chunk_without_d2_1441(d2_1441_pair)",
  "D2 1441 dispatch",
));
expectCompileFailureWithInputs(missingD21441DispatchInputs, "d2 1441 plan marker must occur exactly once");

const missingD1B201DispatchInputs = withWorldBuilderText(replaceExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "D1_B201_LIVE_ATTACHMENT.build_prepared(record, b201_prepared)",
  "_build_record_without_d1_b201(record, b201_prepared)",
  "D1 B201 dispatch",
));
expectCompileFailureWithInputs(missingD1B201DispatchInputs, "d1 b201 build marker must occur exactly once");

const missingD1B225DispatchInputs = withWorldBuilderText(replaceExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "D1_B225_LIVE_ATTACHMENT.build_prepared(record, b225_prepared)",
  "_build_record_without_d1_b225(record, b225_prepared)",
  "D1 B225 dispatch",
));
expectCompileFailureWithInputs(missingD1B225DispatchInputs, "d1 b225 build marker must occur exactly once");

expectCompileFailureWithInputs(withWorldBuilderText(duplicateExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  'const D1_B225_LIVE_ATTACHMENT := preload("res://game/scripts/world/facades/d1_b225_live_attachment.gd")',
  "D1 B225 preload duplication",
)), "d1 b225 preload marker must occur exactly once");

expectCompileFailureWithInputs(withWorldBuilderText(duplicateExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "return NAVY_CHAPEL_187_LIVE_REPLACEMENT.consume_record(record, chapel_plan)",
  "Navy Chapel consume duplication",
)), "navy chapel consume marker must occur exactly once");

expectCompileFailureWithInputs(withWorldBuilderText(duplicateExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  'const D2_1441_CHINOOK_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd")',
  "D2 1441 preload duplication",
)), "d2 1441 preload marker must occur exactly once");

expectCompileFailureWithInputs(withWorldBuilderText(duplicateExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "return D2_1441_CHINOOK_LIVE_REPLACEMENT.consume_record(record, d2_1441_plan)",
  "D2 1441 consume duplication",
)), "d2 1441 consume marker must occur exactly once");

expectCompileFailureWithInputs(withWorldBuilderText(swapExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "if not is_context and NAVY_CHAPEL_187_LIVE_REPLACEMENT.claims_record(record):",
  "return NAVY_CHAPEL_187_LIVE_REPLACEMENT.consume_record(record, chapel_plan)",
  "Navy Chapel claim consume order",
)), "Navy Chapel paired claim must precede paired consumption");

expectCompileFailureWithInputs(withWorldBuilderText(swapExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "NAVY_CHAPEL_187_LIVE_REPLACEMENT.build_chunk_plan(chapel_pair)",
  "if not is_context and NAVY_CHAPEL_187_LIVE_REPLACEMENT.claims_record(record):",
  "Navy Chapel plan dispatch order",
)), "Navy Chapel plan construction must precede per-record dispatch");

expectCompileFailureWithInputs(withWorldBuilderText(swapExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "var record_result := _build_record(record, false, chapel_plan, d2_1441_plan, d2_1439_plan, d2_1444_plan, d5_1308_plan, d5_1394_plan, d5_1317_plan, fs48_plan, maceo_plan, northern_canopy_plan, northpoint_1238_plan, mariner_1206_plan, mariner_1219_plan, mariner_1212_plan, bayside_1220_plan, northpoint_1239_plan, bayside_1222_plan, northpoint_1227_plan, mariner_1202_plan, northpoint_1234_plan, bayside_1215_plan, northpoint_1232_plan, northpoint_1241_plan, mariner_1221_plan, northpoint_1240_plan, gateview_1397_plan, bayside_1226_plan)",
  "NAVY_CHAPEL_187_LIVE_REPLACEMENT.plan_was_fully_consumed(chapel_plan)",
  "Navy Chapel dispatch fully consumed order",
)), "Navy Chapel per-record consumption dispatch must precede the fully-consumed assertion");

expectCompileFailureWithInputs(withWorldBuilderText(swapExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "if not is_context and D2_1441_CHINOOK_LIVE_REPLACEMENT.claims_record(record):",
  "return D2_1441_CHINOOK_LIVE_REPLACEMENT.consume_record(record, d2_1441_plan)",
  "D2 1441 claim consume order",
)), "D2 1441 paired claim must precede paired consumption");

expectCompileFailureWithInputs(withWorldBuilderText(swapExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "D2_1441_CHINOOK_LIVE_REPLACEMENT.build_chunk_plan(d2_1441_pair)",
  "if not is_context and D2_1441_CHINOOK_LIVE_REPLACEMENT.claims_record(record):",
  "D2 1441 plan dispatch order",
)), "D2 1441 plan construction must precede per-record dispatch");

const d21441ConsumedOrderPlaceholder = "__D2_1441_CONSUMED_ORDER_PLACEHOLDER__";
let reorderedD21441ConsumedInputs = replaceExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "var d2_1441_consumed := D2_1441_CHINOOK_LIVE_REPLACEMENT.plan_was_fully_consumed(d2_1441_plan)",
  d21441ConsumedOrderPlaceholder,
  "D2 1441 consumed order marker",
);
reorderedD21441ConsumedInputs = replaceExactlyOnce(
  reorderedD21441ConsumedInputs,
  "var record_result := _build_record(record, false, chapel_plan, d2_1441_plan, d2_1439_plan, d2_1444_plan, d5_1308_plan, d5_1394_plan, d5_1317_plan, fs48_plan, maceo_plan, northern_canopy_plan, northpoint_1238_plan, mariner_1206_plan, mariner_1219_plan, mariner_1212_plan, bayside_1220_plan, northpoint_1239_plan, bayside_1222_plan, northpoint_1227_plan, mariner_1202_plan, northpoint_1234_plan, bayside_1215_plan, northpoint_1232_plan, northpoint_1241_plan, mariner_1221_plan, northpoint_1240_plan, gateview_1397_plan, bayside_1226_plan)",
  "var d2_1441_consumed := D2_1441_CHINOOK_LIVE_REPLACEMENT.plan_was_fully_consumed(d2_1441_plan)",
  "D2 1441 consumed order record",
);
reorderedD21441ConsumedInputs = replaceExactlyOnce(
  reorderedD21441ConsumedInputs,
  "var chapel_consumed := NAVY_CHAPEL_187_LIVE_REPLACEMENT.plan_was_fully_consumed(chapel_plan)",
  "var record_result := _build_record(record, false, chapel_plan, d2_1441_plan, d2_1439_plan, d2_1444_plan, d5_1308_plan, d5_1394_plan, d5_1317_plan, fs48_plan, maceo_plan, northern_canopy_plan, northpoint_1238_plan, mariner_1206_plan, mariner_1219_plan, mariner_1212_plan, bayside_1220_plan, northpoint_1239_plan, bayside_1222_plan, northpoint_1227_plan, mariner_1202_plan, northpoint_1234_plan, bayside_1215_plan, northpoint_1232_plan, northpoint_1241_plan, mariner_1221_plan, northpoint_1240_plan, gateview_1397_plan, bayside_1226_plan)",
  "D2 1441 consumed order chapel",
);
reorderedD21441ConsumedInputs = replaceExactlyOnce(
  reorderedD21441ConsumedInputs,
  d21441ConsumedOrderPlaceholder,
  "var chapel_consumed := NAVY_CHAPEL_187_LIVE_REPLACEMENT.plan_was_fully_consumed(chapel_plan)",
  "D2 1441 consumed order placeholder",
);
expectCompileFailureWithInputs(withWorldBuilderText(reorderedD21441ConsumedInputs), "D2 1441 per-record consumption dispatch must precede the fully-consumed assertion");

const d21441CleanupMarker = 'rollback_plans.append({"adapter": D2_1441_CHINOOK_LIVE_REPLACEMENT, "plan": d2_1441_plan})';
expectCompileFailureWithInputs(withWorldBuilderText(inputs.runtimeContracts.worldBuilderText.replace(d21441CleanupMarker, "")), "d2_1441_plan cleanup registration marker must occur exactly once");
expectCompileFailureWithInputs(withWorldBuilderText(`${inputs.runtimeContracts.worldBuilderText}\n${d21441CleanupMarker}\n`), "d2_1441_plan cleanup registration marker must occur exactly once");

expectCompileFailureWithInputs(withWorldBuilderText(swapExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "D1_B201_LIVE_ATTACHMENT.validate_chunk_records(chunk)",
  "if not is_context and D1_B201_LIVE_ATTACHMENT.claims_record(record):",
  "D1 B201 validate claim order",
)), "D1 B201 chunk validation must precede its per-record claim");

expectCompileFailureWithInputs(withWorldBuilderText(swapExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "b201_prepared = D1_B201_LIVE_ATTACHMENT.prepare(record)",
  "var vertices := PackedVector3Array()",
  "D1 B201 prepare generic order",
)), "D1 B201 preparation must precede generic construction");

expectCompileFailureWithInputs(withWorldBuilderText(swapExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "D1_B201_LIVE_ATTACHMENT.host_uvs(record, b201_prepared)",
  "D1_B201_LIVE_ATTACHMENT.partition_host(record, indices, placeholder_material, b201_prepared)",
  "D1 B201 host UV partition order",
)), "D1 B201 host UV dispatch must precede host partitioning");

expectCompileFailureWithInputs(withWorldBuilderText(swapExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "var body := StaticBody3D.new()",
  "D1_B225_LIVE_ATTACHMENT.build_prepared(record, b225_prepared)",
  "D1 B225 body build order",
)), "D1 B225 build_prepared must follow retained generic body construction");

expectCompileFailureWithInputs(withWorldBuilderText(swapExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "D1_B225_LIVE_ATTACHMENT.validate_chunk_records(chunk)",
  "if not is_context and D1_B225_LIVE_ATTACHMENT.claims_record(record):",
  "D1 B225 validate claim order",
)), "D1 B225 chunk validation must precede its per-record claim");

expectCompileFailureWithInputs(withWorldBuilderText(swapExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  "if not is_context and ISLE_HOUSE_LOW_LIVE_ATTACHMENT.matches_record(record):",
  "var isle_house_low_result := ISLE_HOUSE_LOW_LIVE_ATTACHMENT.build(record)",
  "Isle House claim build order",
)), "Isle House low claim must precede its attachment build");

for (const mutation of [
  {
    expected: "forbidden generic facade registry loader",
    source: `${inputs.runtimeContracts.worldBuilderText}\nconst MUTATED_REGISTRY_LOADER := preload("res://game/scripts/world/facades/facade_runtime_registry_loader.gd")\n`,
  },
  {
    expected: "forbidden runtime resource load",
    source: `${inputs.runtimeContracts.worldBuilderText}\nvar mutated_runtime_adapter := load("res://game/scripts/world/facades/d1_b225_live_attachment.gd")\n`,
  },
  {
    expected: "forbidden preload-by-runtime-string dispatch",
    source: `${inputs.runtimeContracts.worldBuilderText}\nconst MUTATED_ADAPTER_PATH := "res://game/scripts/world/facades/d1_b225_live_attachment.gd"\nconst MUTATED_ADAPTER := preload(MUTATED_ADAPTER_PATH)\n`,
  },
  {
    expected: "forbidden ProjectSettings dispatch",
    source: `${inputs.runtimeContracts.worldBuilderText}\nvar mutated_dispatch_setting := ProjectSettings.get_setting("facades/adapter")\n`,
  },
  {
    expected: "forbidden environment-controlled dispatch",
    source: `${inputs.runtimeContracts.worldBuilderText}\nvar mutated_dispatch_environment := OS.get_environment("FACADE_ADAPTER")\n`,
  },
  {
    expected: "forbidden command-line-controlled dispatch",
    source: `${inputs.runtimeContracts.worldBuilderText}\nvar mutated_dispatch_arguments := OS.get_cmdline_user_args()\n`,
  },
  {
    expected: "forbidden feature-flag-controlled dispatch",
    source: `${inputs.runtimeContracts.worldBuilderText}\nconst FEATURE_FACADE_DISPATCH := true\n`,
  },
  {
    expected: "forbidden fallback or alternate dispatch",
    source: `${inputs.runtimeContracts.worldBuilderText}\nfunc _fallback_adapter_dispatch(record):\n\treturn record\n`,
  },
  {
    expected: "forbidden fallback or alternate dispatch",
    source: `${inputs.runtimeContracts.worldBuilderText}\nfunc _alternate_dispatch(record):\n\treturn record\n`,
  },
]) expectCompileFailureWithInputs(withWorldBuilderText(mutation.source), mutation.expected);

const missingAcceptedPackageDependency = replaceExactlyOnce(
  inputs.runtimeContracts.worldBuilderText,
  'const HAWKINS_MASSING := preload("res://game/scripts/world/massing/hawkins_77_bruton_massing.gd")',
  "const HAWKINS_MASSING := null",
  "accepted B225 Hawkins dependency",
);
expectCompileFailureWithInputs(withWorldBuilderText(missingAcceptedPackageDependency), "lost accepted D2 1441 package dependency game/scripts/world/massing/hawkins_77_bruton_massing.gd");

expectCompileFailureWithInputs({
  ...inputs,
  runtimeContracts: {
    ...inputs.runtimeContracts,
    acceptedWorldBuilderSha256: "0".repeat(64),
  },
}, "Accepted world-builder provenance no longer names the independently reviewed D2 1441 production closure");

expectCompileFailureWithInputs({
  ...inputs,
  runtimeContracts: {
    ...inputs.runtimeContracts,
    currentWorldBuilderSha256: "0".repeat(64),
  },
}, "Current world-builder text/hash binding drifted");

for (const [pathField, expectedText] of [
  ["d21441EvidenceManifestPath", "D2 1441 static evidence manifest path drifted"],
  ["d21441MotionTelemetryManifestPath", "D2 1441 motion telemetry manifest path drifted"],
  ["d21441VisualMotionManifestPath", "D2 1441 visual motion manifest path drifted"],
  ["d21441PackageVerificationReceiptPath", "D2 1441 package verification receipt path drifted"],
  ["d21441MechanicalReviewPath", "D2 1441 mechanical review path drifted"],
  ["d21441VisualReviewPath", "D2 1441 visual review path drifted"],
]) expectD21441RuntimeContractFailure(
  (contract) => {
    contract[pathField] = "discovery/facades/evidence/d2-1441-production-v8/forged-artifact";
  },
  expectedText,
);

for (const [hashField, expectedText] of [
  ["d21441EvidenceManifestSha256", "D2 1441 static evidence manifest bytes drifted"],
  ["d21441MotionTelemetryManifestSha256", "D2 1441 motion telemetry manifest bytes drifted"],
  ["d21441VisualMotionManifestSha256", "D2 1441 visual motion manifest bytes drifted"],
  ["d21441PackageVerificationReceiptSha256", "D2 1441 package verification receipt bytes drifted"],
  ["d21441MechanicalReviewSha256", "D2 1441 mechanical review bytes drifted"],
  ["d21441VisualReviewSha256", "D2 1441 visual review bytes drifted"],
]) expectD21441RuntimeContractFailure(
  (contract) => {
    contract[hashField] = "0".repeat(64);
  },
  expectedText,
);

expectD21441RuntimeContractFailure(
  (contract) => {
    contract.d21441EvidenceTree.file_count = 39;
  },
  "D2 1441 canonical 40-file evidence tree drifted",
);
expectD21441RuntimeContractFailure(
  (contract) => {
    contract.d21441EvidenceTree.sha256 = "0".repeat(64);
  },
  "D2 1441 canonical 40-file evidence tree drifted",
);
expectD21441RuntimeContractFailure(
  (contract) => {
    contract.d21441MechanicalReviewText = contract.d21441MechanicalReviewText.replace("PASS_FOR_1441_PROMOTION_NO_CREDIT", "FORGED_PASS");
  },
  "D2 1441 mechanical review text/hash binding drifted",
);
expectD21441RuntimeContractFailure(
  (contract) => {
    contract.d21441VisualReviewText = contract.d21441VisualReviewText.replace("PASS_FOR_1441_PROMOTION_NO_CREDIT", "FORGED_PASS");
  },
  "D2 1441 visual review text/hash binding drifted",
);
expectD21441RuntimeContractFailure(
  (contract) => {
    contract.d21441EvidenceManifest.package_verification_receipt_sha256 = "0".repeat(64);
  },
  "D2 1441 static evidence manifest package receipt binding drifted",
);
expectD21441RuntimeContractFailure(
  (contract) => {
    contract.d21441EvidenceManifest.bindings.mapped_public_sse_runs.reverse();
  },
  "D2 1441 static evidence manifest mapped/protected run binding drifted",
);
expectD21441RuntimeContractFailure(
  (contract) => {
    contract.d21441MotionTelemetryManifest.recognition_credit = true;
  },
  "D2 1441 motion telemetry manifest improperly self-grants recognition credit or promotion",
);
expectD21441RuntimeContractFailure(
  (contract) => {
    contract.d21441VisualMotionManifest.runtime_topology.triangles -= 1;
  },
  "D2 1441 visual motion manifest runtime topology drifted",
);
expectD21441RuntimeContractFailure(
  (contract) => {
    contract.d21441MotionTelemetryManifest.production_path_observation.ordinary_main_already_integrated = false;
  },
  "D2 1441 motion telemetry manifest no longer proves the ordinary-main activation route",
);
expectD21441RuntimeContractFailure(
  (contract) => {
    contract.d21441PackageVerificationReceipt.source_hashes["game/scripts/world/facades/d2_1441_chinook_live_replacement.gd"] = "0".repeat(64);
  },
  "D2 1441 package receipt source closure drifted",
);
expectD21441RuntimeContractFailure(
  (contract) => {
    contract.d21441PackageVerificationReceipt.mounted_override_absent = false;
  },
  "D2 1441 package receipt route or postcapture-mutation boundary drifted",
);
expectD21441RuntimeContractFailure(
  (contract) => {
    contract.d21441Config.reviewed_art.mapped_public_sse_runs.reverse();
  },
  "D2 1441 reviewed art/run partition drifted",
);
expectD21441RuntimeContractFailure(
  (contract) => {
    contract.d21441LiveAdapterSha256 = "0".repeat(64);
  },
  "D2 1441 reviewed adapter bytes drifted from capture-time authority",
);

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
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w95934119:wall");
    adapter.active_runtime_contract.behavior_contract.geometry_contract.world_topology_scope = CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE;
  },
  "Active D1 B225 acceptance, dependency, host-partition, or ownership parity contract drifted",
);

expectRegistryFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w95934105:wall");
    adapter.active_runtime_contract.behavior_contract.geometry_contract.world_topology_scope = PRE_D2_1441_INTEGRATION_WORLD_TOPOLOGY_SCOPE;
  },
  "Active D2 1441 acceptance, paired dependency, topology, or ownership parity contract drifted",
);

expectRegistryFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w95934105:wall");
    adapter.active_runtime_contract.behavior_contract.geometry_contract.world_triangles -= 1;
  },
  "Active D2 1441 acceptance, paired dependency, topology, or ownership parity contract drifted",
);

expectRegistryFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w95934105:wall");
    adapter.active_runtime_contract.behavior_contract.acceptance_contract.package_verification_receipt_sha256 = "0".repeat(64);
  },
  "Active D2 1441 acceptance, paired dependency, topology, or ownership parity contract drifted",
);

expectRegistryFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w95934105:wall");
    adapter.active_runtime_contract.behavior_contract.replacement_contract.mapped_public_run_indices.reverse();
  },
  "Active D2 1441 acceptance, paired dependency, topology, or ownership parity contract drifted",
);

expectRegistryFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w95934105:wall");
    adapter.active_runtime_contract.behavior_contract.ownership_contract.live_ownership_signature = "0".repeat(64);
  },
  "Active D2 1441 acceptance, paired dependency, topology, or ownership parity contract drifted",
);

expectRegistryFailure(
  (candidate) => {
    const adapter = candidate.active_runtime_adapters.find((item) => item.receiver_key === "building:w95934105:wall");
    adapter.runtime_assets.pop();
  },
  "Active D2 1441 exact thirteen-asset runtime closure is incomplete or source-bearing",
);

expectRegistryFailure(
  (candidate) => {
    const unit = candidate.units.find((item) => item.unit_id === "physical-building:w95934105");
    unit.acceptance_records[0].mechanical_review_receipt_sha256 = "0".repeat(64);
  },
  "D2 1441 seven-artifact acceptance closure drifted",
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
  "Runtime physical-entity recognition metric drifted from the accepted-unit rollup",
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

// The accepted quality packet is upstream of authority; it grants no new recognition or release claim.
assert(report.input_hashes.active_building_1_returns_v2_acceptance_receipt_sha256 === inputs.runtimeContracts.heroReturnsAcceptanceSha256 &&
  report.input_hashes.active_building_1_public_front_config_sha256 === inputs.runtimeContracts.heroPublicFrontConfigSha256,
"source-only current report does not expose the accepted B1 returns receipt and config bindings");
for (const mutate of [
  (contract) => { contract.heroReturnsAcceptanceSha256 = "0".repeat(64); },
  (contract) => { contract.heroReturnsAcceptance.recognition_credit_delta = 1; },
  (contract) => { contract.heroReturnsAcceptance.recognition_metric = "8/213"; },
  (contract) => { contract.heroReturnsAcceptance.reviews[2].token = "HOLD"; },
  (contract) => { contract.heroReturnsAcceptance.source_inputs[0].sha256 = "0".repeat(64); },
  (contract) => { contract.heroReturnsAcceptance.candidate_verification.input_inventory.pop(); },
  (contract) => { contract.heroReturnsAcceptance.candidate_verification.input_inventory[0].sha256 = "0".repeat(64); },
  (contract) => { contract.heroReturnsAcceptance.motion_reuse.copied_byte_identically = false; },
  (contract) => { contract.heroReturnsAcceptance.proof_boundaries.full_current_release_pass = true; },
  (contract) => { contract.heroReturnsAcceptance.proof_boundaries.source_renders_are_package_pixels = true; },
]) {
  const candidateInputs = { ...inputs, runtimeContracts: structuredClone(inputs.runtimeContracts) };
  mutate(candidateInputs.runtimeContracts);
  expectThrown(() => validateActiveHeroDispatch(candidateInputs), "exact source-only acceptance receipt drifted", "B1 returns quality acceptance");
}
for (const mutate of [
  (contract) => { contract.heroPublicFrontConfig.geometry_production_inference_m.wing_window_jamb_frame_overlap = 0.02; },
  (contract) => { contract.heroAdapterText += "\n# changed accepted source\n"; },
]) {
  const candidateInputs = { ...inputs, runtimeContracts: structuredClone(inputs.runtimeContracts) };
  mutate(candidateInputs.runtimeContracts);
  expectThrown(() => validateActiveHeroDispatch(candidateInputs), "accepted executable source drifted", "B1 returns executable source");
}

// D2 1439 promotion binds one physical unit to the accepted seven artifacts.
const d21439Unit = registry.units.find((unit) => unit.unit_id === "physical-building:w95934144");
const d21439Adapter = registry.active_runtime_adapters.find((adapter) => adapter.receiver_key === "building:w95934144:wall");
const d21439Acceptance = d21439Unit.acceptance_records[0];
const expectedD21439Bindings = {
  "evidence_manifest_sha256": "32454a02699ebce9e29e8313e70fe93894c52bd3a4ddb46c08ffeaee54891a6a",
  "motion_telemetry_manifest_sha256": "af5f7501b08cd36629123ad14b169da764d0c375f53a6167fee80843d7a1c863",
  "visual_motion_manifest_sha256": "262183b9dd5424df20527ad097bc2a07921c1f24c2ce5d359a6d7aa096052683",
  "package_verification_receipt_sha256": "56b93dc9a3e4300d6c64261618add170488002e8c305d34889d30fd55ad41af1",
  "mechanical_review_receipt_sha256": "f55d7a4df3fea5a1cf936d75ff0b8690b9c94f005992e5cc26da793304402119",
  "evidence_tree_sha256": "bd5c009e49545f5ef84b8f0c2032c1f59dd2054d4afe0aa1f9145f74a03e2426",
  "review_receipt_sha256": "cf1723b330fbd208fe92e27f5593c5f203b8f8cb99ff383ec8b389005fcc745c"
};
assert(d21439Unit.acceptance_records.length === 1 && d21439Unit.direct_receivers.length === 1 && d21439Unit.active_runtime_adapter_ids.length === 1 && d21439Acceptance.capture_time_recognition_metric === "9/213" && d21439Acceptance.numerator_effect === 1, "D2 1439 single wall-indexed unit/credit drifted");
for (const [field, hash] of Object.entries(expectedD21439Bindings)) {
  assert(d21439Acceptance[field] === hash, `D2 1439 ${field} binding drifted`);
  expectCompileFailure((candidate) => { candidate.units.find((unit) => unit.unit_id === d21439Unit.unit_id).acceptance_records[0][field] = "0".repeat(64); }, field === "review_receipt_sha256" ? "review receipt pin drifted" : field === "evidence_manifest_sha256" ? "evidence manifest pin drifted" : "seven-artifact acceptance closure drifted");
}
expectCompileFailure((candidate) => { const unit = candidate.units.find((unit) => unit.unit_id === d21439Unit.unit_id); unit.acceptance_records.push(structuredClone(unit.acceptance_records[0])); }, "duplicate");
expectCompileFailure((candidate) => { candidate.units.find((unit) => unit.unit_id === d21439Unit.unit_id).acceptance_records[0].numerator_effect = 2; }, "number exceeds maximum 1");
expectCompileFailure((candidate) => { candidate.units.find((unit) => unit.unit_id === d21439Unit.unit_id).receiver_keys.push("building:w95934144:roof"); }, "string does not match");
for (const field of ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "package_verification_receipt_sha256", "mechanical_review_receipt_sha256", "evidence_tree_sha256", "review_receipt_sha256"]) {
  expectCompileFailure((candidate) => { delete candidate.units.find((unit) => unit.unit_id === d21439Unit.unit_id).acceptance_records[0][field]; }, field === "evidence_manifest_sha256" || field === "review_receipt_sha256" ? "required property" : "seven-artifact acceptance closure drifted");
}
const d21439Geometry = d21439Adapter.active_runtime_contract.behavior_contract.geometry_contract;
assert(d21439Geometry.world_topology_scope === PRE_D2_1444_INTEGRATION_WORLD_TOPOLOGY_SCOPE && d21439Geometry.world_records === 735 && d21439Geometry.world_mesh_instances === 968 && d21439Geometry.world_surfaces === 983 && d21439Geometry.world_triangles === 71156 && d21439Geometry.world_static_bodies === 466 && d21439Geometry.world_shapes === 467, "D2 1439 historical measured topology drifted");
const d21439Ownership = d21439Adapter.active_runtime_contract.behavior_contract.ownership_contract;
assert(d21439Ownership.eligible_exterior_collision_triangles === 62 && d21439Ownership.noneligible_closed_recess_collision_triangles === 30 && d21439Ownership.shape_count === 3 && d21439Ownership.roof_is_wall_spray_receiver === false && JSON.stringify(d21439Ownership.wall_shape_order) === JSON.stringify(["eligible_exterior", "noneligible_closed_recess"]), "D2 1439 closed-recess ownership drifted");
for (const mutate of [
  (b) => { b.geometry_contract.world_topology_scope = PRE_D2_1439_INTEGRATION_WORLD_TOPOLOGY_SCOPE; },
  (b) => { b.geometry_contract.world_shapes = 466; },
  (b) => { b.ownership_contract.roof_is_wall_spray_receiver = true; },
  (b) => { b.ownership_contract.wall_shape_order.reverse(); },
]) expectRegistryFailure((candidate) => { mutate(candidate.active_runtime_adapters.find((adapter) => adapter.receiver_key === "building:w95934144:wall").active_runtime_contract.behavior_contract); }, "Active D2 1439 acceptance, paired dependency, topology, or ownership parity contract drifted");

// D2 1444 promotion binds one physical unit to the accepted seven artifacts.
const d21444Unit = registry.units.find((unit) => unit.unit_id === "physical-building:w95934117");
const d21444Adapter = registry.active_runtime_adapters.find((adapter) => adapter.receiver_key === "building:w95934117:wall");
const d21444Acceptance = d21444Unit.acceptance_records[0];
const expectedD21444Bindings = {
  "evidence_manifest_sha256": "9f1101abb3e4d6ac54f27a8a6db7d72ccd098721d0f59e8a6f72a6aa4c1293ef",
  "motion_telemetry_manifest_sha256": "b569a5dc8b72c99c873a85c4fbc49b701ba72647a0299a4f8e7b0ff06b7309bc",
  "visual_motion_manifest_sha256": "327d9980de0798d7412ea691bd656f278a5e04da383c24fdb1cb272305b29e38",
  "package_verification_receipt_sha256": "b738e35d58ef6e75d0c4d98ae32d6157532703984fd48730281629211fe355a4",
  "mechanical_review_receipt_sha256": "7e62e914074646e438bc7c88a1f15fbc71eb40bfa00a0b04acf20e22e319c205",
  "evidence_tree_sha256": "6872fe9f286370de3ab11ce27124583689a7fa0c4992bb4de4f2b9e8e1073003",
  "review_receipt_sha256": "89c301ccdf5d02b71c5f4d79eacfee55521440edfbe2c6d780cd7c1d059d72c7"
};
assert(d21444Unit.acceptance_records.length === 1 && d21444Unit.direct_receivers.length === 1 && d21444Unit.active_runtime_adapter_ids.length === 1 && d21444Acceptance.capture_time_recognition_metric === "9/213" && d21444Acceptance.numerator_effect === 1, "D2 1444 single wall-indexed unit/credit drifted");
for (const [field, hash] of Object.entries(expectedD21444Bindings)) {
  assert(d21444Acceptance[field] === hash, `D2 1444 ${field} binding drifted`);
  expectCompileFailure((candidate) => { candidate.units.find((unit) => unit.unit_id === d21444Unit.unit_id).acceptance_records[0][field] = "0".repeat(64); }, field === "review_receipt_sha256" ? "review receipt pin drifted" : field === "evidence_manifest_sha256" ? "evidence manifest pin drifted" : "seven-artifact acceptance closure drifted");
}
expectCompileFailure((candidate) => { const unit = candidate.units.find((unit) => unit.unit_id === d21444Unit.unit_id); unit.acceptance_records.push(structuredClone(unit.acceptance_records[0])); }, "duplicate");
expectCompileFailure((candidate) => { candidate.units.find((unit) => unit.unit_id === d21444Unit.unit_id).acceptance_records[0].numerator_effect = 2; }, "number exceeds maximum 1");
expectCompileFailure((candidate) => { candidate.units.find((unit) => unit.unit_id === d21444Unit.unit_id).receiver_keys.push("building:w95934117:roof"); }, "string does not match");
for (const field of ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "package_verification_receipt_sha256", "mechanical_review_receipt_sha256", "evidence_tree_sha256", "review_receipt_sha256"]) {
  expectCompileFailure((candidate) => { delete candidate.units.find((unit) => unit.unit_id === d21444Unit.unit_id).acceptance_records[0][field]; }, field === "evidence_manifest_sha256" || field === "review_receipt_sha256" ? "required property" : "seven-artifact acceptance closure drifted");
}
const d21444Geometry = d21444Adapter.active_runtime_contract.behavior_contract.geometry_contract;
assert(d21444Geometry.world_topology_scope === "pre_d5_batch_integration_live_parity" && d21444Geometry.world_records === 735 && d21444Geometry.world_mesh_instances === 977 && d21444Geometry.world_surfaces === 992 && d21444Geometry.world_triangles === 71828 && d21444Geometry.world_static_bodies === 466 && d21444Geometry.world_shapes === 468, "D2 1444 measured current topology drifted");
const d21444Ownership = d21444Adapter.active_runtime_contract.behavior_contract.ownership_contract;
assert(d21444Ownership.eligible_exterior_collision_triangles === 64 && d21444Ownership.noneligible_closed_recess_collision_triangles === 40 && d21444Ownership.shape_count === 3 && d21444Ownership.roof_is_wall_spray_receiver === false && JSON.stringify(d21444Ownership.wall_shape_order) === JSON.stringify(["eligible_exterior", "noneligible_closed_recess"]), "D2 1444 closed-recess ownership drifted");
for (const mutate of [
  (b) => { b.geometry_contract.world_topology_scope = PRE_D2_1444_INTEGRATION_WORLD_TOPOLOGY_SCOPE; },
  (b) => { b.geometry_contract.world_shapes = 466; },
  (b) => { b.ownership_contract.roof_is_wall_spray_receiver = true; },
  (b) => { b.ownership_contract.wall_shape_order.reverse(); },
]) expectRegistryFailure((candidate) => { mutate(candidate.active_runtime_adapters.find((adapter) => adapter.receiver_key === "building:w95934117:wall").active_runtime_contract.behavior_contract); }, "Active D2 1444 acceptance, paired dependency, topology, or ownership parity contract drifted");

expectCompileFailureWithInputs(withWorldBuilderText(duplicateExactlyOnce(inputs.runtimeContracts.worldBuilderText,
  'const D2_1444_CROAKER_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/d2_1444_croaker_quality_v2_live_replacement.gd")', "D2 1444 preload duplication")), "d2 1444 preload marker must occur exactly once");
expectCompileFailureWithInputs(withWorldBuilderText(swapExactlyOnce(inputs.runtimeContracts.worldBuilderText,
  "if not is_context and D2_1444_CROAKER_LIVE_REPLACEMENT.claims_record(record):",
  "return D2_1444_CROAKER_LIVE_REPLACEMENT.consume_record(record, d2_1444_plan)", "D2 1444 claim consume order")), "D2 1444 paired claim must precede paired consumption");

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
        "world_topology_scope": "pre_maceo_may_integration_live_parity"
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
  },
  {
    "unit_id": "physical-building:r19685981",
    "wall": "building:r19685981:wall",
    "roof": "building:r19685981:roof",
    "adapter_id": "active-adapter:maceo-may-live:building:r19685981:wall",
    "acceptance": {
      "evidence_manifest_sha256": "82543ad09bc51281499280965d9bc949ecc99781d80520801742bd3643404862",
      "motion_telemetry_manifest_sha256": "83a8637cd539efa3899b8d97147a82a02d976aa8baed4209824e2724a2ac7e2b",
      "visual_motion_manifest_sha256": "3c7c3e933062d4cf3994f47cb48a62c41b7c1cf42fa41693ff82474cec1db86d",
      "package_verification_receipt_sha256": "e903e64348aa003ca957b1e1efebc57a516395134f40d56e1ba1c5ebc3ad877f",
      "evidence_tree_sha256": "916457b92cee4b002cab5c47b6ecd29a8c8d398a9ad685c05e7bc8f5d9874e0a",
      "mechanical_review_receipt_sha256": "749cd826a0ea791b696ab98464e5c19548f14d45734d88111a79376a74dd5c8c",
      "review_receipt_sha256": "e08d71c45bfc67e05ab2fd2a8d4e8362ef7692f96d5817d60856a251b473b14e",
      "capture_time_recognition_metric": "14/213",
      "numerator_effect": 1,
      "review_id": "maceo-may-quality-candidate-2026-09-11-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.maceo-may-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "82543ad09bc51281499280965d9bc949ecc99781d80520801742bd3643404862",
        "motion_telemetry_manifest_sha256": "83a8637cd539efa3899b8d97147a82a02d976aa8baed4209824e2724a2ac7e2b",
        "visual_motion_manifest_sha256": "3c7c3e933062d4cf3994f47cb48a62c41b7c1cf42fa41693ff82474cec1db86d",
        "package_verification_receipt_sha256": "e903e64348aa003ca957b1e1efebc57a516395134f40d56e1ba1c5ebc3ad877f",
        "evidence_tree_sha256": "916457b92cee4b002cab5c47b6ecd29a8c8d398a9ad685c05e7bc8f5d9874e0a",
        "mechanical_review_receipt_sha256": "749cd826a0ea791b696ab98464e5c19548f14d45734d88111a79376a74dd5c8c",
        "review_receipt_sha256": "e08d71c45bfc67e05ab2fd2a8d4e8362ef7692f96d5817d60856a251b473b14e",
        "accepted_physical_unit_id": "physical-building:r19685981",
        "capture_time_recognition_metric": "14/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "r19685981",
        "wall_object_key": "building:r19685981:wall",
        "roof_object_key": "building:r19685981:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
          8,
          9,
          10,
          11,
          12,
          13,
          14,
          15,
          16
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
          17,
          18,
          19,
          20,
          21,
          22,
          23,
          24,
          25,
          26,
          27,
          28,
          29,
          30,
          31,
          32,
          33,
          34,
          35,
          36,
          37,
          38,
          39
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1
      },
      "geometry_contract": {
        "source_geometry_sha256": "4caf46d6c3ebb1ef497fbe8012e5f1fd938a055e11a4132c04ed8e6827da12b3",
        "canonical_wall_record_sha256": "c68403647a2a1f39a1957813e44c161882c88911d8f0eae574f7f9806ae07b44",
        "canonical_roof_record_sha256": "86a5ea5b74ab4713f75ff1c6c35cf5132b70c7e33c228f988983c6c7303139cc",
        "source_chunk_sha256": "b8696d4feb4157d39969ec039e610af572f25510d712c802d4a96943d6069c8c",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 11,
        "visual_surfaces": 11,
        "visual_triangles": 16436,
        "world_records": 735,
        "world_mesh_instances": 1032,
        "world_surfaces": 1047,
        "world_triangles": 99129,
        "world_static_bodies": 466,
        "world_shapes": 478,
        "world_topology_scope": "pre_northern_batch_integration_live_parity"
      },
      "ownership_contract": {
        "structural_owner_count": 2,
        "shape_count": 3,
        "spray_owner_count": 1,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": true,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall",
          "noneligible_entrance_columns"
        ],
        "wall_shape_collision_triangles": [
          80,
          320
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof"
        ],
        "roof_shape_collision_triangles": [
          16
        ],
        "eligible_exterior_collision_triangles": 80,
        "wall_collision_triangles": 400,
        "roof_collision_triangles": 16,
        "added_collision_triangles": 320,
        "all_additions_render_only": false,
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
  },
  {
    "unit_id": "physical-building:w96215672",
    "wall": "building:w96215672:wall",
    "roof": "building:w96215672:roof",
    "adapter_id": "active-adapter:northern-canopy-free-live:building:w96215672:wall",
    "acceptance": {
      "evidence_manifest_sha256": "fc250debbc032d160e3de5e3e0148f13934a7e3bb17cc882a19f4d5b336fab95",
      "motion_telemetry_manifest_sha256": "5a5de738ac8e8ed4490d4c83d63a739d5cdb9598ce66021984579dac1bf6e0c4",
      "visual_motion_manifest_sha256": "c0fcacf741e513402d0b04aa35c7d5927b4205ebb80c85890a62bd2b5456c77d",
      "package_verification_receipt_sha256": "21be51860e8e35dcdf76df4753d22155cbca013f134250b365764e873b8eac86",
      "evidence_tree_sha256": "df08d70aa4307e2b7689e6c8e3ff0ad31005806b14c2420251456ddb4c60db92",
      "mechanical_review_receipt_sha256": "f449c7863040df9873f5bcd268e0eac506a9c26d6e0613881e1b294e9355bb1f",
      "review_receipt_sha256": "11f87bb5defc8432d5ba53e8e2eb586f631cd81db920f5fa85dc61cc34261589",
      "capture_time_recognition_metric": "15/213",
      "numerator_effect": 1,
      "review_id": "northern-1201-quality-candidate-2026-09-13-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.northern-1201-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "fc250debbc032d160e3de5e3e0148f13934a7e3bb17cc882a19f4d5b336fab95",
        "motion_telemetry_manifest_sha256": "5a5de738ac8e8ed4490d4c83d63a739d5cdb9598ce66021984579dac1bf6e0c4",
        "visual_motion_manifest_sha256": "c0fcacf741e513402d0b04aa35c7d5927b4205ebb80c85890a62bd2b5456c77d",
        "package_verification_receipt_sha256": "21be51860e8e35dcdf76df4753d22155cbca013f134250b365764e873b8eac86",
        "evidence_tree_sha256": "df08d70aa4307e2b7689e6c8e3ff0ad31005806b14c2420251456ddb4c60db92",
        "mechanical_review_receipt_sha256": "f449c7863040df9873f5bcd268e0eac506a9c26d6e0613881e1b294e9355bb1f",
        "review_receipt_sha256": "11f87bb5defc8432d5ba53e8e2eb586f631cd81db920f5fa85dc61cc34261589",
        "accepted_physical_unit_id": "physical-building:w96215672",
        "capture_time_recognition_metric": "15/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w96215672",
        "wall_object_key": "building:w96215672:wall",
        "roof_object_key": "building:w96215672:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
          11,
          12,
          14,
          15,
          17,
          18
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
          10,
          13,
          16,
          19
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1,
        "raw_source_constructor_callback_required": true,
        "tangent_callback_required": true
      },
      "geometry_contract": {
        "source_chunk_sha256": "7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 11,
        "visual_surfaces": 11,
        "visual_triangles": 4950,
        "wall_native_counts": [
          10,
          10,
          4940,
          2,
          8
        ],
        "roof_native_counts": [
          1,
          1,
          10,
          1,
          1
        ],
        "world_records": 735,
        "world_mesh_instances": 1050,
        "world_surfaces": 1065,
        "world_triangles": 108921,
        "world_static_bodies": 468,
        "world_shapes": 492,
        "world_topology_scope": "shared_northern_1201_1238_candidate_live_parity"
      },
      "ownership_contract": {
        "structural_owner_count": 3,
        "shape_count": 9,
        "spray_owner_count": 1,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": true,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall",
          "PaleCompleteTrim",
          "BlueOpaqueGlazing",
          "DarkOpaqueGlazing",
          "MaroonClosedDoors",
          "LocalPrivacyScreens",
          "PaleDrainageAndFascia",
          "DoorHardware"
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof"
        ],
        "all_additions_render_only": false,
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
        "spray_input_event_dispatch_claimed": false,
        "separate_setup_poses_retained": true,
        "sparse_movie_samples_only": true,
        "raw_door_station_failure_retained": false,
        "station_held_claimed": true
      }
    },
    "runtime_asset_count": 5
  },
  {
    "unit_id": "physical-building:w96215669",
    "wall": "building:w96215669:wall",
    "roof": "building:w96215669:roof",
    "adapter_id": "active-adapter:northpoint-1238-live:building:w96215669:wall",
    "acceptance": {
      "evidence_manifest_sha256": "5eb7648cb03fa1ae73c9733c31456539d39c40a462219be43d4a92ecf7d0ce62",
      "motion_telemetry_manifest_sha256": "fb3f03daae24bb385cbf6e86ee665a2752017ee9c5c32f54c6e21d00dbc7faf3",
      "visual_motion_manifest_sha256": "35edd4f41d0cf9009aa59f66b0345992a93bb08ecd1eda8b61086b6eb5dc09db",
      "package_verification_receipt_sha256": "5b6b2455b8068568e2b877b9f155982af76e4cc81f7be3341e9ec663c7c260de",
      "evidence_tree_sha256": "a2e2b8aade40eebd01d900728e65c5cabd2cb1f43465399db2ed90329d49a741",
      "mechanical_review_receipt_sha256": "6e5961faa00944e793c213e444a96732494a6fe15e1799f06636bdd1dd7ad276",
      "review_receipt_sha256": "805f12798185ad8504cfac0742a27bdcb83c9da79b9aa9a192ba84081117fbab",
      "capture_time_recognition_metric": "16/213",
      "numerator_effect": 1,
      "review_id": "northern-1238-quality-candidate-2026-09-13-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.northern-1238-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "5eb7648cb03fa1ae73c9733c31456539d39c40a462219be43d4a92ecf7d0ce62",
        "motion_telemetry_manifest_sha256": "fb3f03daae24bb385cbf6e86ee665a2752017ee9c5c32f54c6e21d00dbc7faf3",
        "visual_motion_manifest_sha256": "35edd4f41d0cf9009aa59f66b0345992a93bb08ecd1eda8b61086b6eb5dc09db",
        "package_verification_receipt_sha256": "5b6b2455b8068568e2b877b9f155982af76e4cc81f7be3341e9ec663c7c260de",
        "evidence_tree_sha256": "a2e2b8aade40eebd01d900728e65c5cabd2cb1f43465399db2ed90329d49a741",
        "mechanical_review_receipt_sha256": "6e5961faa00944e793c213e444a96732494a6fe15e1799f06636bdd1dd7ad276",
        "review_receipt_sha256": "805f12798185ad8504cfac0742a27bdcb83c9da79b9aa9a192ba84081117fbab",
        "accepted_physical_unit_id": "physical-building:w96215669",
        "capture_time_recognition_metric": "16/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w96215669",
        "wall_object_key": "building:w96215669:wall",
        "roof_object_key": "building:w96215669:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
          8,
          9,
          10,
          11,
          13,
          14,
          15,
          17,
          18,
          19,
          20,
          21
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
          12,
          16,
          22,
          23
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1,
        "raw_source_constructor_callback_required": true,
        "tangent_callback_required": true
      },
      "geometry_contract": {
        "source_chunk_sha256": "bb21618ff0bc88549e3a600d981880415817747475c2c3a0d368a7da8db4d3ac",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 11,
        "visual_surfaces": 11,
        "visual_triangles": 4956,
        "wall_native_counts": [
          10,
          10,
          4940,
          2,
          8
        ],
        "roof_native_counts": [
          1,
          1,
          16,
          1,
          1
        ],
        "world_records": 735,
        "world_mesh_instances": 1050,
        "world_surfaces": 1065,
        "world_triangles": 108921,
        "world_static_bodies": 468,
        "world_shapes": 492,
        "world_topology_scope": "pre_mariner_batch_integration_live_parity"
      },
      "ownership_contract": {
        "structural_owner_count": 3,
        "shape_count": 9,
        "spray_owner_count": 1,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": true,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall",
          "PaleCompleteTrim",
          "BlueOpaqueGlazing",
          "DarkOpaqueGlazing",
          "DarkBlueClosedDoors",
          "LocalPrivacyScreens",
          "PaleDrainageAndFascia",
          "DoorHardware"
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof"
        ],
        "all_additions_render_only": false,
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
        "spray_input_event_dispatch_claimed": false,
        "separate_setup_poses_retained": true,
        "sparse_movie_samples_only": true,
        "raw_door_station_failure_retained": true,
        "station_held_claimed": false
      }
    },
    "runtime_asset_count": 5
  },
  {
    "unit_id": "physical-building:w96215677",
    "wall": "building:w96215677:wall",
    "roof": "building:w96215677:roof",
    "adapter_id": "active-adapter:mariner-1206-live:building:w96215677:wall",
    "acceptance": {
      "evidence_manifest_sha256": "2ef58e0ef4ab39375107bf4d5354b83399eceda0bc36599b7bbb5e98bb79e6b9",
      "motion_telemetry_manifest_sha256": "bd5aacf373d887cddf2c25ed0788ab0286faa0c9daa7cc0e9e03a81ad744bd0e",
      "visual_motion_manifest_sha256": "6bee171a27e3a10b3f1927f332a678ec0826e982faa6085e71db525bcdb30096",
      "package_verification_receipt_sha256": "03f2cf746dc931dd816f28f337b12ae9f11d7cb5ef3c3087601a46bb9df427c7",
      "evidence_tree_sha256": "70f69ef17176b2810b073f4304fd17f6bc7143a70ac031d1a20922996422661c",
      "mechanical_review_receipt_sha256": "c806dc1fd6f146f8573e83b3fd8ac8523d87fba1d57e8f5e9d29a066b481f3bd",
      "review_receipt_sha256": "b3549c8b8616163a06c8fa2209562bda58ad9ce03ad3ae68751c9ca256b9e09a",
      "capture_time_recognition_metric": "16/213",
      "numerator_effect": 1,
      "review_id": "northern-1206-quality-candidate-2026-09-13-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.northern-1206-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "2ef58e0ef4ab39375107bf4d5354b83399eceda0bc36599b7bbb5e98bb79e6b9",
        "motion_telemetry_manifest_sha256": "bd5aacf373d887cddf2c25ed0788ab0286faa0c9daa7cc0e9e03a81ad744bd0e",
        "visual_motion_manifest_sha256": "6bee171a27e3a10b3f1927f332a678ec0826e982faa6085e71db525bcdb30096",
        "package_verification_receipt_sha256": "03f2cf746dc931dd816f28f337b12ae9f11d7cb5ef3c3087601a46bb9df427c7",
        "evidence_tree_sha256": "70f69ef17176b2810b073f4304fd17f6bc7143a70ac031d1a20922996422661c",
        "mechanical_review_receipt_sha256": "c806dc1fd6f146f8573e83b3fd8ac8523d87fba1d57e8f5e9d29a066b481f3bd",
        "review_receipt_sha256": "b3549c8b8616163a06c8fa2209562bda58ad9ce03ad3ae68751c9ca256b9e09a",
        "accepted_physical_unit_id": "physical-building:w96215677",
        "capture_time_recognition_metric": "16/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w96215677",
        "wall_object_key": "building:w96215677:wall",
        "roof_object_key": "building:w96215677:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
          11,
          12,
          13,
          15,
          16,
          17,
          18,
          19,
          21,
          22,
          23
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
          10,
          14,
          20,
          24,
          25
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1,
        "raw_source_constructor_callback_required": true,
        "tangent_callback_required": true
      },
      "geometry_contract": {
        "source_chunk_sha256": "7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 14,
        "visual_surfaces": 14,
        "visual_triangles": 5132,
        "wall_native_counts": [
          12,
          12,
          5068,
          2,
          8
        ],
        "roof_native_counts": [
          2,
          2,
          64,
          2,
          2
        ],
        "world_records": 735,
        "world_mesh_instances": 1074,
        "world_surfaces": 1089,
        "world_triangles": 119049,
        "world_static_bodies": 472,
        "world_shapes": 508,
        "world_topology_scope": "shared_mariner_1206_1219_candidate_live_parity"
      },
      "ownership_contract": {
        "structural_owner_count": 4,
        "shape_count": 10,
        "spray_owner_count": 1,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": true,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall",
          "PaleCompleteTrim",
          "BlueOpaqueGlazing",
          "DarkOpaqueGlazing",
          "GreenClosedDoors",
          "LocalPrivacyScreens",
          "PaleDrainageAndFascia",
          "DoorHardware"
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof",
          "ObservedPublicRoof"
        ],
        "added_public_roof_triangles": 48,
        "original_flat_roof_preserved": true,
        "added_public_roof_is_nonreceiver": true,
        "all_additions_render_only": false,
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
        "spray_input_event_dispatch_claimed": false,
        "separate_setup_poses_retained": true,
        "sparse_movie_samples_only": true,
        "raw_door_station_failure_retained": false,
        "station_held_claimed": true
      }
    },
    "runtime_asset_count": 5
  },
  {
    "unit_id": "physical-building:w96215680",
    "wall": "building:w96215680:wall",
    "roof": "building:w96215680:roof",
    "adapter_id": "active-adapter:mariner-1219-live:building:w96215680:wall",
    "acceptance": {
      "evidence_manifest_sha256": "892c34c422283ba7eadd3b5a8d005f34b8736e4b359ffc67ba7194a6c4fc110d",
      "motion_telemetry_manifest_sha256": "98fe533ab07e2ff5f098094ad68e2b32b20712e13de75881e679eb84fb107c0f",
      "visual_motion_manifest_sha256": "754b234c8806726b70400dcd759abbed3a309fad42be12669b2cf877e6e5b415",
      "package_verification_receipt_sha256": "4c2e64ec36a96058c8d48a7cb5f5e9c29c0e1154ff2c2db179071cc8f7553e62",
      "evidence_tree_sha256": "bd06a1a34a11937410f82ad5d6903de68e8d0a1660b5a9b2d8815afeee990ea6",
      "mechanical_review_receipt_sha256": "03003e86b6fb4b7fb28099876e6a788e9c8596bd14f25a794d8a1adce6fd4ecd",
      "review_receipt_sha256": "f58284bed7ac7fce861a282a344bac1cdb12d6b69286d0cfbde3936f9022139b",
      "capture_time_recognition_metric": "16/213",
      "numerator_effect": 1,
      "review_id": "northern-1219-quality-candidate-2026-09-13-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.northern-1219-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "892c34c422283ba7eadd3b5a8d005f34b8736e4b359ffc67ba7194a6c4fc110d",
        "motion_telemetry_manifest_sha256": "98fe533ab07e2ff5f098094ad68e2b32b20712e13de75881e679eb84fb107c0f",
        "visual_motion_manifest_sha256": "754b234c8806726b70400dcd759abbed3a309fad42be12669b2cf877e6e5b415",
        "package_verification_receipt_sha256": "4c2e64ec36a96058c8d48a7cb5f5e9c29c0e1154ff2c2db179071cc8f7553e62",
        "evidence_tree_sha256": "bd06a1a34a11937410f82ad5d6903de68e8d0a1660b5a9b2d8815afeee990ea6",
        "mechanical_review_receipt_sha256": "03003e86b6fb4b7fb28099876e6a788e9c8596bd14f25a794d8a1adce6fd4ecd",
        "review_receipt_sha256": "f58284bed7ac7fce861a282a344bac1cdb12d6b69286d0cfbde3936f9022139b",
        "accepted_physical_unit_id": "physical-building:w96215680",
        "capture_time_recognition_metric": "16/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w96215680",
        "wall_object_key": "building:w96215680:wall",
        "roof_object_key": "building:w96215680:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
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
          10,
          11,
          12,
          13
        ],
        "protected_run_indices": [
          14,
          15,
          16,
          17,
          18,
          19,
          20,
          21,
          22,
          23,
          24,
          25
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1,
        "raw_source_constructor_callback_required": true,
        "tangent_callback_required": true
      },
      "geometry_contract": {
        "source_chunk_sha256": "7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 14,
        "visual_surfaces": 14,
        "visual_triangles": 5132,
        "wall_native_counts": [
          12,
          12,
          5068,
          2,
          8
        ],
        "roof_native_counts": [
          2,
          2,
          64,
          2,
          2
        ],
        "world_records": 735,
        "world_mesh_instances": 1074,
        "world_surfaces": 1089,
        "world_triangles": 119049,
        "world_static_bodies": 472,
        "world_shapes": 508,
        "world_topology_scope": "pre_northern_three_unit_integration_live_parity"
      },
      "ownership_contract": {
        "structural_owner_count": 4,
        "shape_count": 10,
        "spray_owner_count": 1,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": true,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall",
          "PaleCompleteTrim",
          "BlueOpaqueGlazing",
          "DarkOpaqueGlazing",
          "DarkBlueClosedDoors",
          "LocalPrivacyScreens",
          "PaleDrainageAndFascia",
          "DoorHardware"
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof",
          "ObservedPublicRoof"
        ],
        "added_public_roof_triangles": 48,
        "original_flat_roof_preserved": true,
        "added_public_roof_is_nonreceiver": true,
        "all_additions_render_only": false,
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
        "spray_input_event_dispatch_claimed": false,
        "separate_setup_poses_retained": true,
        "sparse_movie_samples_only": true,
        "raw_door_station_failure_retained": false,
        "station_held_claimed": true
      }
    },
    "runtime_asset_count": 5
  },
  {
    "unit_id": "physical-building:w96215649",
    "wall": "building:w96215649:wall",
    "roof": "building:w96215649:roof",
    "adapter_id": "active-adapter:mariner-1212-live:building:w96215649:wall",
    "acceptance": {
      "evidence_manifest_sha256": "e639c2fe4ca2beebdd067a8d804d231ba4e4a9e55e4d85699496533479267de2",
      "motion_telemetry_manifest_sha256": "e78ac76b320df4869bc882a52e5e37ad56a863f5e99734d9b45e2d84764a6424",
      "visual_motion_manifest_sha256": "e094b27c9dc69797035270a9acfedcb4db9832338f4915178e101f05621b49af",
      "package_verification_receipt_sha256": "276b71133a8ae9c1f0fd8caecdbd0365f16c3ca4655d49e99149bbaec61b0ae0",
      "evidence_tree_sha256": "0c46621cf3d43660a7e7d8168dcdf0be5556d96b5ff1a63b0715295311565d35",
      "mechanical_review_receipt_sha256": "6f67a10d85551c5e4226ff47edcd15a15ce25f3a179ffa0e3670d3c0981be3fb",
      "review_receipt_sha256": "bbc33d45ea0708df973adc24897b27ceaa052117c4f002546df64b2fdb30ef3d",
      "capture_time_recognition_metric": "18/213",
      "numerator_effect": 1,
      "review_id": "northern-1212-quality-candidate-2026-09-14-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.northern-1212-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "e639c2fe4ca2beebdd067a8d804d231ba4e4a9e55e4d85699496533479267de2",
        "motion_telemetry_manifest_sha256": "e78ac76b320df4869bc882a52e5e37ad56a863f5e99734d9b45e2d84764a6424",
        "visual_motion_manifest_sha256": "e094b27c9dc69797035270a9acfedcb4db9832338f4915178e101f05621b49af",
        "package_verification_receipt_sha256": "276b71133a8ae9c1f0fd8caecdbd0365f16c3ca4655d49e99149bbaec61b0ae0",
        "evidence_tree_sha256": "0c46621cf3d43660a7e7d8168dcdf0be5556d96b5ff1a63b0715295311565d35",
        "mechanical_review_receipt_sha256": "6f67a10d85551c5e4226ff47edcd15a15ce25f3a179ffa0e3670d3c0981be3fb",
        "review_receipt_sha256": "bbc33d45ea0708df973adc24897b27ceaa052117c4f002546df64b2fdb30ef3d",
        "accepted_physical_unit_id": "physical-building:w96215649",
        "capture_time_recognition_metric": "18/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w96215649",
        "wall_object_key": "building:w96215649:wall",
        "roof_object_key": "building:w96215649:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
          14,
          15,
          16,
          17,
          19,
          20,
          21,
          22,
          24,
          25,
          26,
          27
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
          10,
          11,
          12,
          13,
          18,
          23
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1,
        "raw_source_constructor_callback_required": true,
        "tangent_callback_required": true
      },
      "geometry_contract": {
        "source_chunk_sha256": "d82a0767672898b348115d9df812a1a33bee96bca0d5d58713c52087591011bc",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 14,
        "visual_surfaces": 14,
        "visual_triangles": 5140,
        "wall_native_counts": [
          12,
          12,
          5076,
          2,
          8
        ],
        "roof_native_counts": [
          2,
          2,
          64,
          2,
          2
        ],
        "world_records": 735,
        "world_mesh_instances": 1111,
        "world_surfaces": 1126,
        "world_triangles": 138057,
        "world_static_bodies": 478,
        "world_shapes": 533,
        "world_topology_scope": "shared_northern_1212_1220_1239_candidate_live_parity"
      },
      "ownership_contract": {
        "structural_owner_count": 4,
        "shape_count": 10,
        "spray_owner_count": 1,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": true,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall",
          "PaleCompleteTrim",
          "BlueOpaqueGlazing",
          "DarkOpaqueGlazing",
          "DarkReddishClosedDoors",
          "LocalPrivacyScreens",
          "PaleDrainageAndFascia",
          "DoorHardware"
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof",
          "ObservedPublicRoof"
        ],
        "added_public_roof_triangles": 48,
        "original_flat_roof_preserved": true,
        "added_public_roof_is_nonreceiver": true,
        "all_additions_render_only": false,
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
        "spray_input_event_dispatch_claimed": false,
        "separate_setup_poses_retained": true,
        "sparse_movie_samples_only": true,
        "raw_door_station_failure_retained": true,
        "station_held_claimed": false,
        "prior_clipped_tag_failure_retained": false,
        "scoped_hairline_observation_retained": false,
        "native_support_qualification_mm": 4
      }
    },
    "runtime_asset_count": 5
  },
  {
    "unit_id": "physical-building:w96215652",
    "wall": "building:w96215652:wall",
    "roof": "building:w96215652:roof",
    "adapter_id": "active-adapter:bayside-1220-live:building:w96215652:wall",
    "acceptance": {
      "evidence_manifest_sha256": "410d90ee3599491993fddcc0ed8accea3de05bb4e905be9076078629b36f7835",
      "motion_telemetry_manifest_sha256": "94994da3f3db23d5bc81d4892e7ddcbafe91228aa891890198b9afee0339e961",
      "visual_motion_manifest_sha256": "db006b21c253ea7dbcc937ff6ba5bf7805894f9b00b8ef6164396ee9f6b3af23",
      "package_verification_receipt_sha256": "dbef975d3b3afedac4694ea49c57f4e98e50a41f67ed2a61621dae3cc0c12176",
      "evidence_tree_sha256": "1d2e5d2682e0b72c9c81b5962680e11c9cdba200d0ab13b11db1c6dac54f1aef",
      "mechanical_review_receipt_sha256": "923517f30c75e83af49c039111fdac548d8a20c0486cdf202863e04cca41c3ef",
      "review_receipt_sha256": "ca45fe7f855fb98ecadecddf7a04e8b9e13f73355bed128cfc4c8ef83a13fc1c",
      "capture_time_recognition_metric": "18/213",
      "numerator_effect": 1,
      "review_id": "northern-1220-quality-candidate-2026-09-14-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.northern-1220-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "410d90ee3599491993fddcc0ed8accea3de05bb4e905be9076078629b36f7835",
        "motion_telemetry_manifest_sha256": "94994da3f3db23d5bc81d4892e7ddcbafe91228aa891890198b9afee0339e961",
        "visual_motion_manifest_sha256": "db006b21c253ea7dbcc937ff6ba5bf7805894f9b00b8ef6164396ee9f6b3af23",
        "package_verification_receipt_sha256": "dbef975d3b3afedac4694ea49c57f4e98e50a41f67ed2a61621dae3cc0c12176",
        "evidence_tree_sha256": "1d2e5d2682e0b72c9c81b5962680e11c9cdba200d0ab13b11db1c6dac54f1aef",
        "mechanical_review_receipt_sha256": "923517f30c75e83af49c039111fdac548d8a20c0486cdf202863e04cca41c3ef",
        "review_receipt_sha256": "ca45fe7f855fb98ecadecddf7a04e8b9e13f73355bed128cfc4c8ef83a13fc1c",
        "accepted_physical_unit_id": "physical-building:w96215652",
        "capture_time_recognition_metric": "18/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w96215652",
        "wall_object_key": "building:w96215652:wall",
        "roof_object_key": "building:w96215652:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
          0,
          1,
          3,
          4,
          5,
          6,
          7,
          8,
          10,
          11
        ],
        "protected_run_indices": [
          2,
          9,
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
          23,
          24,
          25
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1,
        "raw_source_constructor_callback_required": true,
        "tangent_callback_required": true
      },
      "geometry_contract": {
        "source_chunk_sha256": "7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 14,
        "visual_surfaces": 14,
        "visual_triangles": 7118,
        "wall_native_counts": [
          12,
          12,
          7040,
          2,
          8
        ],
        "roof_native_counts": [
          2,
          2,
          78,
          2,
          2
        ],
        "world_records": 735,
        "world_mesh_instances": 1111,
        "world_surfaces": 1126,
        "world_triangles": 138057,
        "world_static_bodies": 478,
        "world_shapes": 533,
        "world_topology_scope": "shared_northern_1212_1220_1239_candidate_live_parity"
      },
      "ownership_contract": {
        "structural_owner_count": 4,
        "shape_count": 10,
        "spray_owner_count": 1,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": true,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall",
          "PaleCompleteTrim",
          "BlueOpaqueGlazing",
          "DarkOpaqueGlazing",
          "DarkBlueClosedDoors",
          "LocalPrivacyScreens",
          "PaleDrainageAndFascia",
          "DoorHardware"
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof",
          "ObservedPublicRoof"
        ],
        "added_public_roof_triangles": 64,
        "original_flat_roof_preserved": true,
        "added_public_roof_is_nonreceiver": true,
        "all_additions_render_only": false,
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
        "spray_input_event_dispatch_claimed": false,
        "separate_setup_poses_retained": true,
        "sparse_movie_samples_only": true,
        "raw_door_station_failure_retained": false,
        "station_held_claimed": false,
        "prior_clipped_tag_failure_retained": true,
        "scoped_hairline_observation_retained": false,
        "native_support_qualification_mm": 4
      }
    },
    "runtime_asset_count": 5
  },
  {
    "unit_id": "physical-building:w96215658",
    "wall": "building:w96215658:wall",
    "roof": "building:w96215658:roof",
    "adapter_id": "active-adapter:northpoint-1239-live:building:w96215658:wall",
    "acceptance": {
      "evidence_manifest_sha256": "640768775dc2090c5742eb1b8468f0a9992086fbe06cca8ae8f5982309b20ee6",
      "motion_telemetry_manifest_sha256": "be716635b72e105c8440c51836735e149360f20eda1fdc95b9a0bfd83f39a6e2",
      "visual_motion_manifest_sha256": "47f2d83b04b14b988f9b72c22b8384120201eba933a0a9fd7ca1dd7163eda22c",
      "package_verification_receipt_sha256": "2e57bb89f4e646abc95a7db1a7cea82100c058121ad6755ff08edd1fd6403be2",
      "evidence_tree_sha256": "7da899b63a2f906a643ac3eeb3a92a793fa3b502e9fa60f395b58fe60139d3e0",
      "mechanical_review_receipt_sha256": "d45db6575672f8c713ce96ec41d577d507722a57c14417657f7c2cc564f70f81",
      "review_receipt_sha256": "f46366f21b1cc5ed5fb2a230fd35cdc144d02b24833292b9c1ad617f58191c55",
      "capture_time_recognition_metric": "18/213",
      "numerator_effect": 1,
      "review_id": "northern-1239-quality-candidate-2026-09-14-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.northern-1239-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "640768775dc2090c5742eb1b8468f0a9992086fbe06cca8ae8f5982309b20ee6",
        "motion_telemetry_manifest_sha256": "be716635b72e105c8440c51836735e149360f20eda1fdc95b9a0bfd83f39a6e2",
        "visual_motion_manifest_sha256": "47f2d83b04b14b988f9b72c22b8384120201eba933a0a9fd7ca1dd7163eda22c",
        "package_verification_receipt_sha256": "2e57bb89f4e646abc95a7db1a7cea82100c058121ad6755ff08edd1fd6403be2",
        "evidence_tree_sha256": "7da899b63a2f906a643ac3eeb3a92a793fa3b502e9fa60f395b58fe60139d3e0",
        "mechanical_review_receipt_sha256": "d45db6575672f8c713ce96ec41d577d507722a57c14417657f7c2cc564f70f81",
        "review_receipt_sha256": "f46366f21b1cc5ed5fb2a230fd35cdc144d02b24833292b9c1ad617f58191c55",
        "accepted_physical_unit_id": "physical-building:w96215658",
        "capture_time_recognition_metric": "18/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w96215658",
        "wall_object_key": "building:w96215658:wall",
        "roof_object_key": "building:w96215658:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
          0,
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
          10,
          11,
          12,
          13,
          14,
          15,
          16,
          17,
          18
        ],
        "protected_run_indices": [
          9,
          19,
          20,
          21,
          22,
          23,
          24,
          25,
          26,
          27,
          28,
          29,
          30,
          31,
          32,
          33
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1,
        "raw_source_constructor_callback_required": true,
        "tangent_callback_required": true
      },
      "geometry_contract": {
        "source_chunk_sha256": "bb21618ff0bc88549e3a600d981880415817747475c2c3a0d368a7da8db4d3ac",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 15,
        "visual_surfaces": 15,
        "visual_triangles": 6978,
        "wall_native_counts": [
          13,
          13,
          6892,
          2,
          9
        ],
        "roof_native_counts": [
          2,
          2,
          86,
          2,
          2
        ],
        "world_records": 735,
        "world_mesh_instances": 1111,
        "world_surfaces": 1126,
        "world_triangles": 138057,
        "world_static_bodies": 478,
        "world_shapes": 533,
        "world_topology_scope": "pre_northern_1222_1227_1202_integration_live_parity"
      },
      "ownership_contract": {
        "structural_owner_count": 4,
        "shape_count": 11,
        "spray_owner_count": 1,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": true,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall",
          "PaleCompleteTrim",
          "BlueOpaqueGlazing",
          "DarkOpaqueGlazing",
          "OchreClosedDoors",
          "MutedRoseClosedDoors",
          "LocalPrivacyScreens",
          "PaleDrainageAndFascia",
          "DoorHardware"
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof",
          "ObservedPublicRoof"
        ],
        "added_public_roof_triangles": 64,
        "original_flat_roof_preserved": true,
        "added_public_roof_is_nonreceiver": true,
        "all_additions_render_only": false,
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
        "spray_input_event_dispatch_claimed": false,
        "separate_setup_poses_retained": true,
        "sparse_movie_samples_only": true,
        "raw_door_station_failure_retained": false,
        "station_held_claimed": false,
        "prior_clipped_tag_failure_retained": false,
        "scoped_hairline_observation_retained": true,
        "native_support_qualification_mm": 4
      }
    },
    "runtime_asset_count": 5
  },
  {
    "unit_id": "physical-building:w96215661",
    "wall": "building:w96215661:wall",
    "roof": "building:w96215661:roof",
    "adapter_id": "active-adapter:bayside-1222-live:building:w96215661:wall",
    "acceptance": {
      "evidence_manifest_sha256": "c9bdee01510d7e0c2f43be4c454b154437009583b2c59c15ba211f07ee16f259",
      "motion_telemetry_manifest_sha256": "ac2950c05d8472b5a8edb0ce2f7b4437159d6af963145dfd142ec5bc59019b98",
      "visual_motion_manifest_sha256": "0976e8393145f40ce9e07c861bdc1a032f15b0cf70e6c984244318e2adfb92d3",
      "package_verification_receipt_sha256": "a6ea228918898454c56fd5aebe1affbd94d0bc7c1878c966c14fc704409e028b",
      "evidence_tree_sha256": "4870b6e92d8d9d42c7107a27f38af1f115f39cd934e920d297363c018d3d2822",
      "mechanical_review_receipt_sha256": "ec1e740bd93a8325094811bf634d90d43c672574a002a90c96a1a454662996cf",
      "review_receipt_sha256": "20a5a14b31c9918f7e9e4c3884c1ca3deef55af1ccd5720c4c9d581710c42f76",
      "capture_time_recognition_metric": "23/213",
      "numerator_effect": 1,
      "review_id": "northern-1222-quality-candidate-2026-09-14-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.northern-1222-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "c9bdee01510d7e0c2f43be4c454b154437009583b2c59c15ba211f07ee16f259",
        "motion_telemetry_manifest_sha256": "ac2950c05d8472b5a8edb0ce2f7b4437159d6af963145dfd142ec5bc59019b98",
        "visual_motion_manifest_sha256": "0976e8393145f40ce9e07c861bdc1a032f15b0cf70e6c984244318e2adfb92d3",
        "package_verification_receipt_sha256": "a6ea228918898454c56fd5aebe1affbd94d0bc7c1878c966c14fc704409e028b",
        "evidence_tree_sha256": "4870b6e92d8d9d42c7107a27f38af1f115f39cd934e920d297363c018d3d2822",
        "mechanical_review_receipt_sha256": "ec1e740bd93a8325094811bf634d90d43c672574a002a90c96a1a454662996cf",
        "review_receipt_sha256": "20a5a14b31c9918f7e9e4c3884c1ca3deef55af1ccd5720c4c9d581710c42f76",
        "accepted_physical_unit_id": "physical-building:w96215661",
        "capture_time_recognition_metric": "23/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w96215661",
        "wall_object_key": "building:w96215661:wall",
        "roof_object_key": "building:w96215661:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
          10,
          11,
          12,
          13,
          14,
          15,
          16,
          19
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
          17,
          18
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1,
        "raw_source_constructor_callback_required": true,
        "tangent_callback_required": true
      },
      "geometry_contract": {
        "source_chunk_sha256": "7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 16,
        "visual_surfaces": 16,
        "visual_triangles": 5346,
        "wall_native_counts": [
          15,
          15,
          5336,
          3,
          11
        ],
        "roof_native_counts": [
          1,
          1,
          10,
          1,
          1
        ],
        "world_records": 735,
        "world_mesh_instances": 1159,
        "world_surfaces": 1174,
        "world_triangles": 153873,
        "world_static_bodies": 484,
        "world_shapes": 569,
        "world_topology_scope": "shared_northern_1222_1227_1202_candidate_live_parity"
      },
      "ownership_contract": {
        "structural_owner_count": 4,
        "shape_count": 12,
        "spray_owner_count": 2,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": false,
        "original_wall_and_projected_front_are_receivers": true,
        "projected_receiver_runs": [
          10,
          11,
          12,
          15,
          16,
          19
        ],
        "projected_receiver_triangles": 6,
        "projected_receiver_shape_order": [
          "ProjectedUpperSiding"
        ],
        "projected_receiver_physics_layer": 5,
        "projected_receiver_cull_mask": 2,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall",
          "ProjectedUpperClosures",
          "PaleCompleteTrim",
          "BlueOpaqueGlazing",
          "DarkOpaqueGlazing",
          "BlueGrayClosedDoors",
          "PaleClosedDoor",
          "LocalPrivacyScreens",
          "PaleDrainageAndFascia",
          "DoorHardware"
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof"
        ],
        "added_public_roof_triangles": 0,
        "original_flat_roof_preserved": true,
        "added_public_roof_is_nonreceiver": true,
        "all_additions_render_only": false,
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
        "spray_input_event_dispatch_claimed": false,
        "separate_setup_poses_retained": true,
        "sparse_movie_samples_only": true,
        "raw_door_station_failure_retained": false,
        "original_visual_hold_retained": true,
        "metadata_only_observer_retained": true,
        "unexecuted_central_carport_proposal_retained": false,
        "motion_route_scope": "one_door_one_screen_finite_routes",
        "station_held_claimed": false,
        "prior_clipped_tag_failure_retained": false,
        "scoped_hairline_observation_retained": false,
        "native_support_qualification_mm": 4
      }
    },
    "runtime_asset_count": 5
  },
  {
    "unit_id": "physical-building:w96215653",
    "wall": "building:w96215653:wall",
    "roof": "building:w96215653:roof",
    "adapter_id": "active-adapter:northpoint-1227-live:building:w96215653:wall",
    "acceptance": {
      "evidence_manifest_sha256": "f240c0a442a66cdb5e20fffa4883e2b9098ce681d0fdefa3c30e846e376d517b",
      "motion_telemetry_manifest_sha256": "c45ad15c677f1413d106695f8a1c6e339c0b6da6f4fb67eea0d9b6ae53b64018",
      "visual_motion_manifest_sha256": "a28bf431f24e58cc147b3adc6df9983784f68d6f0335c61bea3bda7d02e0cfa8",
      "package_verification_receipt_sha256": "802e3287f84f0363a688d35454e88aebef7d34b93db88b88d16785311ec3d7d4",
      "evidence_tree_sha256": "34e252f76805cd5e152fd58056f95852ba5c4ebfdc2e73ceeb20f1410c74eadb",
      "mechanical_review_receipt_sha256": "45cf53232bcb34f4bf43b2370a7ce0e84ade628dc23e9aa7a8439f70eb102c03",
      "review_receipt_sha256": "8957bff439a37e22880af8b0df5c6641e348bb19e13207bd65ac8e94cb1484ad",
      "capture_time_recognition_metric": "23/213",
      "numerator_effect": 1,
      "review_id": "northern-1227-quality-candidate-2026-09-14-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.northern-1227-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "f240c0a442a66cdb5e20fffa4883e2b9098ce681d0fdefa3c30e846e376d517b",
        "motion_telemetry_manifest_sha256": "c45ad15c677f1413d106695f8a1c6e339c0b6da6f4fb67eea0d9b6ae53b64018",
        "visual_motion_manifest_sha256": "a28bf431f24e58cc147b3adc6df9983784f68d6f0335c61bea3bda7d02e0cfa8",
        "package_verification_receipt_sha256": "802e3287f84f0363a688d35454e88aebef7d34b93db88b88d16785311ec3d7d4",
        "evidence_tree_sha256": "34e252f76805cd5e152fd58056f95852ba5c4ebfdc2e73ceeb20f1410c74eadb",
        "mechanical_review_receipt_sha256": "45cf53232bcb34f4bf43b2370a7ce0e84ade628dc23e9aa7a8439f70eb102c03",
        "review_receipt_sha256": "8957bff439a37e22880af8b0df5c6641e348bb19e13207bd65ac8e94cb1484ad",
        "accepted_physical_unit_id": "physical-building:w96215653",
        "capture_time_recognition_metric": "23/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w96215653",
        "wall_object_key": "building:w96215653:wall",
        "roof_object_key": "building:w96215653:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
          4,
          5,
          6,
          7,
          8,
          9,
          10,
          11,
          13,
          14,
          15,
          16,
          17
        ],
        "protected_run_indices": [
          0,
          1,
          2,
          3,
          12,
          18,
          19,
          20,
          21
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1,
        "raw_source_constructor_callback_required": true,
        "tangent_callback_required": true
      },
      "geometry_contract": {
        "source_chunk_sha256": "932c924b845a382d746e7900710c0c4e8b7603ab205cb07173ad51933c1341b4",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 20,
        "visual_surfaces": 20,
        "visual_triangles": 5544,
        "wall_native_counts": [
          19,
          19,
          5528,
          3,
          15
        ],
        "roof_native_counts": [
          1,
          1,
          16,
          1,
          1
        ],
        "world_records": 735,
        "world_mesh_instances": 1159,
        "world_surfaces": 1174,
        "world_triangles": 153873,
        "world_static_bodies": 484,
        "world_shapes": 569,
        "world_topology_scope": "shared_northern_1222_1227_1202_candidate_live_parity"
      },
      "ownership_contract": {
        "structural_owner_count": 4,
        "shape_count": 16,
        "spray_owner_count": 2,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": false,
        "original_wall_and_projected_front_are_receivers": true,
        "projected_receiver_runs": [
          4,
          5,
          6,
          7,
          9,
          10,
          11,
          13,
          14,
          15,
          16
        ],
        "projected_receiver_triangles": 6,
        "projected_receiver_shape_order": [
          "ProjectedUpperSiding"
        ],
        "projected_receiver_physics_layer": 5,
        "projected_receiver_cull_mask": 2,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall",
          "ObservedPublicRoof",
          "NorthGableSiding",
          "CarportRoof",
          "CarportPosts",
          "ProjectedUpperClosures",
          "PaleCompleteTrim",
          "BlueOpaqueGlazing",
          "DarkOpaqueGlazing",
          "BlueGrayClosedDoors",
          "PaleClosedDoor",
          "LocalPrivacyScreens",
          "PaleDrainageAndFascia",
          "DoorHardware"
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof"
        ],
        "added_public_roof_triangles": 92,
        "original_flat_roof_preserved": true,
        "added_public_roof_is_nonreceiver": true,
        "all_additions_render_only": false,
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
        "spray_input_event_dispatch_claimed": false,
        "separate_setup_poses_retained": true,
        "sparse_movie_samples_only": true,
        "raw_door_station_failure_retained": false,
        "original_visual_hold_retained": true,
        "metadata_only_observer_retained": false,
        "unexecuted_central_carport_proposal_retained": false,
        "motion_route_scope": "one_door_one_screen_finite_routes",
        "station_held_claimed": false,
        "prior_clipped_tag_failure_retained": false,
        "scoped_hairline_observation_retained": true,
        "native_support_qualification_mm": 4
      }
    },
    "runtime_asset_count": 5
  },
  {
    "unit_id": "physical-building:w96215651",
    "wall": "building:w96215651:wall",
    "roof": "building:w96215651:roof",
    "adapter_id": "active-adapter:mariner-1202-live:building:w96215651:wall",
    "acceptance": {
      "evidence_manifest_sha256": "497ce96296ada0265a26c4d24215db320b278cff8883be00b5d637a94d2cfd64",
      "motion_telemetry_manifest_sha256": "8205cf8904929d56d9e90842922a6be37cf64869f283c60aac666e42e571c236",
      "visual_motion_manifest_sha256": "4de165e49df045101b1fd7156f0f7595c0026617db255ab3c23412b1a4424081",
      "package_verification_receipt_sha256": "1da322cc863b923b4befee6eac8f3876c1fa0360a1848527c88cba774c935769",
      "evidence_tree_sha256": "3c30e9c73026a885f2ee2b3941b28e7ed6be799571c58fa733d2e209adfad7fe",
      "mechanical_review_receipt_sha256": "669f108baf4c343f766da111c808232e6b4b611d13cf919526372e54f8642d34",
      "review_receipt_sha256": "6a7813fc1a94f816bd01f55f6901a61f7d421b67e085663b6e51ad865408754e",
      "capture_time_recognition_metric": "23/213",
      "numerator_effect": 1,
      "review_id": "northern-1202-quality-candidate-2026-09-14-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.northern-1202-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "497ce96296ada0265a26c4d24215db320b278cff8883be00b5d637a94d2cfd64",
        "motion_telemetry_manifest_sha256": "8205cf8904929d56d9e90842922a6be37cf64869f283c60aac666e42e571c236",
        "visual_motion_manifest_sha256": "4de165e49df045101b1fd7156f0f7595c0026617db255ab3c23412b1a4424081",
        "package_verification_receipt_sha256": "1da322cc863b923b4befee6eac8f3876c1fa0360a1848527c88cba774c935769",
        "evidence_tree_sha256": "3c30e9c73026a885f2ee2b3941b28e7ed6be799571c58fa733d2e209adfad7fe",
        "mechanical_review_receipt_sha256": "669f108baf4c343f766da111c808232e6b4b611d13cf919526372e54f8642d34",
        "review_receipt_sha256": "6a7813fc1a94f816bd01f55f6901a61f7d421b67e085663b6e51ad865408754e",
        "accepted_physical_unit_id": "physical-building:w96215651",
        "capture_time_recognition_metric": "23/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w96215651",
        "wall_object_key": "building:w96215651:wall",
        "roof_object_key": "building:w96215651:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
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
          21
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
          20,
          22,
          23,
          24,
          25
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1,
        "raw_source_constructor_callback_required": true,
        "tangent_callback_required": true
      },
      "geometry_contract": {
        "source_chunk_sha256": "7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 18,
        "visual_surfaces": 18,
        "visual_triangles": 5104,
        "wall_native_counts": [
          17,
          17,
          5088,
          3,
          13
        ],
        "roof_native_counts": [
          1,
          1,
          16,
          1,
          1
        ],
        "world_records": 735,
        "world_mesh_instances": 1159,
        "world_surfaces": 1174,
        "world_triangles": 153873,
        "world_static_bodies": 484,
        "world_shapes": 569,
        "world_topology_scope": "pre_northern_1234_1215_integration_live_parity"
      },
      "ownership_contract": {
        "structural_owner_count": 4,
        "shape_count": 14,
        "spray_owner_count": 2,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": false,
        "original_wall_and_projected_front_are_receivers": true,
        "projected_receiver_runs": [
          10,
          11,
          12,
          13,
          14,
          16,
          17,
          18,
          19,
          21
        ],
        "projected_receiver_triangles": 6,
        "projected_receiver_shape_order": [
          "ProjectedUpperSiding"
        ],
        "projected_receiver_physics_layer": 5,
        "projected_receiver_cull_mask": 2,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall",
          "ObservedPublicRoof",
          "CarportRoof",
          "CarportPosts",
          "ProjectedUpperClosures",
          "PaleCompleteTrim",
          "BlueOpaqueGlazing",
          "DarkOpaqueGlazing",
          "BlueGrayClosedDoors",
          "LocalPrivacyScreens",
          "PaleDrainageAndFascia",
          "DoorHardware"
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof"
        ],
        "added_public_roof_triangles": 108,
        "original_flat_roof_preserved": true,
        "added_public_roof_is_nonreceiver": true,
        "all_additions_render_only": false,
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
        "spray_input_event_dispatch_claimed": false,
        "separate_setup_poses_retained": true,
        "sparse_movie_samples_only": true,
        "raw_door_station_failure_retained": false,
        "original_visual_hold_retained": true,
        "metadata_only_observer_retained": false,
        "unexecuted_central_carport_proposal_retained": true,
        "motion_route_scope": "uncovered_run21",
        "station_held_claimed": false,
        "prior_clipped_tag_failure_retained": false,
        "scoped_hairline_observation_retained": false,
        "native_support_qualification_mm": 4
      }
    },
    "runtime_asset_count": 5
  },
  {
    "unit_id": "physical-building:w96215659",
    "wall": "building:w96215659:wall",
    "roof": "building:w96215659:roof",
    "adapter_id": "active-adapter:northpoint-1234-live:building:w96215659:wall",
    "acceptance": {
      "evidence_manifest_sha256": "29b8208ce1d2061557f5e440b73b29f19d9832f6341ce55d6a00f16d71abdb75",
      "motion_telemetry_manifest_sha256": "d5aa947c9f8ccd189bdbfc1fb93089b3423ff39dc082da017b5df46bdabe7ce0",
      "visual_motion_manifest_sha256": "9ac0894c8d7f52729f25294d24b666f97a9a8ebca91a4ed7892e766c99a8dae9",
      "package_verification_receipt_sha256": "ee10c9345a74c96e2c85b919679405e8d3ec08a296994895ec357dafd2d3fde1",
      "evidence_tree_sha256": "f8941af510bc00e6e14ea5125f06b7503514b674449e84a543ffdc1765f64852",
      "mechanical_review_receipt_sha256": "48995f50883a6ff1d36af054f545dd0cd7ff9739e68749d5efcce34c119701d2",
      "review_receipt_sha256": "607c60defc1825ff28afa0dd591d50e42669a140496ea06afaa14699209e1ef4",
      "capture_time_recognition_metric": "23/213",
      "numerator_effect": 1,
      "review_id": "northern-1234-quality-candidate-2026-09-22-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.northern-1234-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "29b8208ce1d2061557f5e440b73b29f19d9832f6341ce55d6a00f16d71abdb75",
        "motion_telemetry_manifest_sha256": "d5aa947c9f8ccd189bdbfc1fb93089b3423ff39dc082da017b5df46bdabe7ce0",
        "visual_motion_manifest_sha256": "9ac0894c8d7f52729f25294d24b666f97a9a8ebca91a4ed7892e766c99a8dae9",
        "package_verification_receipt_sha256": "ee10c9345a74c96e2c85b919679405e8d3ec08a296994895ec357dafd2d3fde1",
        "evidence_tree_sha256": "f8941af510bc00e6e14ea5125f06b7503514b674449e84a543ffdc1765f64852",
        "mechanical_review_receipt_sha256": "48995f50883a6ff1d36af054f545dd0cd7ff9739e68749d5efcce34c119701d2",
        "review_receipt_sha256": "607c60defc1825ff28afa0dd591d50e42669a140496ea06afaa14699209e1ef4",
        "accepted_physical_unit_id": "physical-building:w96215659",
        "capture_time_recognition_metric": "23/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w96215659",
        "wall_object_key": "building:w96215659:wall",
        "roof_object_key": "building:w96215659:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
          0,
          1,
          2,
          3,
          4,
          17,
          18,
          19,
          20,
          22,
          23,
          24,
          25
        ],
        "protected_run_indices": [
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
          15,
          16,
          21
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1,
        "raw_source_constructor_callback_required": true,
        "tangent_callback_required": true,
        "continuity_run_indices": [
          0
        ],
        "partial_run_20_observed_fraction": 0.3293396850039768,
        "partial_run_20_hidden_tail_protected": true
      },
      "geometry_contract": {
        "source_chunk_sha256": "932c924b845a382d746e7900710c0c4e8b7603ab205cb07173ad51933c1341b4",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 19,
        "visual_surfaces": 19,
        "visual_triangles": 5500,
        "wall_native_counts": [
          18,
          18,
          5484,
          3,
          14
        ],
        "roof_native_counts": [
          1,
          1,
          16,
          1,
          1
        ],
        "world_records": 735,
        "world_mesh_instances": 1192,
        "world_surfaces": 1207,
        "world_triangles": 164001,
        "world_static_bodies": 488,
        "world_shapes": 594,
        "world_topology_scope": "shared_northern_1234_1215_candidate_live_parity"
      },
      "ownership_contract": {
        "structural_owner_count": 4,
        "shape_count": 15,
        "spray_owner_count": 2,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": false,
        "original_wall_and_projected_front_are_receivers": true,
        "projected_receiver_runs": [
          1,
          2,
          3,
          4,
          17,
          18,
          19,
          20,
          22,
          23,
          24,
          25
        ],
        "projected_receiver_triangles": 6,
        "projected_receiver_shape_order": [
          "ProjectedUpperSiding"
        ],
        "projected_receiver_physics_layer": 5,
        "projected_receiver_cull_mask": 2,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall",
          "ObservedPublicRoof",
          "CarportRoof",
          "CarportPosts",
          "ProjectedUpperClosures",
          "PaleCompleteTrim",
          "BlueOpaqueGlazing",
          "DarkOpaqueGlazing",
          "BlueGrayClosedDoors",
          "PlumClosedDoors",
          "LocalPrivacyScreens",
          "PaleDrainageAndFascia",
          "DoorHardware"
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof"
        ],
        "added_public_roof_triangles": 100,
        "original_flat_roof_preserved": true,
        "added_public_roof_is_nonreceiver": true,
        "all_additions_render_only": false,
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
        "spray_input_event_dispatch_claimed": false,
        "separate_setup_poses_retained": true,
        "sparse_movie_samples_only": true,
        "raw_door_station_failure_retained": false,
        "original_visual_hold_retained": true,
        "metadata_only_observer_retained": false,
        "unexecuted_central_carport_proposal_retained": false,
        "motion_route_scope": "finite_observed_entry_routes_uncovered_run2",
        "station_held_claimed": false,
        "prior_clipped_tag_failure_retained": false,
        "scoped_hairline_observation_retained": false,
        "native_support_qualification_mm": 4,
        "original_failed_mechanics_attempts_retained": false
      }
    },
    "runtime_asset_count": 5
  },
  {
    "unit_id": "physical-building:w96215666",
    "wall": "building:w96215666:wall",
    "roof": "building:w96215666:roof",
    "adapter_id": "active-adapter:bayside-1215-live:building:w96215666:wall",
    "acceptance": {
      "evidence_manifest_sha256": "685725ca0d2454610a5e304dc5fef6c968fc35cfb98819b0a5a88c64dbfdf084",
      "motion_telemetry_manifest_sha256": "7ed10c2427be78afaa26e950c76cb54ccbec6e73d1a4bc3781b7fb1b9e5d9737",
      "visual_motion_manifest_sha256": "d25f30eff4d7d0fd4f7c0de034c9f2f88e34f93ce0f7b35e8de7e1c5c9f76462",
      "package_verification_receipt_sha256": "191674762a5d82a363698fb5155dc659cba5cc06f20294b26efd1a8789af8a7e",
      "evidence_tree_sha256": "7e192e071997d82a527192e787ae7290f5ef4c18c2417afe57348f0da49e35fe",
      "mechanical_review_receipt_sha256": "b211c1ad80d9c864d47dc9933985d661af01d25b6bc0d0d211d59bf8edd58feb",
      "review_receipt_sha256": "5c6678ebd09028ee5f17c7ada899aaa93aff0baf8bc6dea05f9606638b546b23",
      "capture_time_recognition_metric": "23/213",
      "numerator_effect": 1,
      "review_id": "northern-1215-quality-candidate-2026-09-22-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.northern-1215-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "685725ca0d2454610a5e304dc5fef6c968fc35cfb98819b0a5a88c64dbfdf084",
        "motion_telemetry_manifest_sha256": "7ed10c2427be78afaa26e950c76cb54ccbec6e73d1a4bc3781b7fb1b9e5d9737",
        "visual_motion_manifest_sha256": "d25f30eff4d7d0fd4f7c0de034c9f2f88e34f93ce0f7b35e8de7e1c5c9f76462",
        "package_verification_receipt_sha256": "191674762a5d82a363698fb5155dc659cba5cc06f20294b26efd1a8789af8a7e",
        "evidence_tree_sha256": "7e192e071997d82a527192e787ae7290f5ef4c18c2417afe57348f0da49e35fe",
        "mechanical_review_receipt_sha256": "b211c1ad80d9c864d47dc9933985d661af01d25b6bc0d0d211d59bf8edd58feb",
        "review_receipt_sha256": "5c6678ebd09028ee5f17c7ada899aaa93aff0baf8bc6dea05f9606638b546b23",
        "accepted_physical_unit_id": "physical-building:w96215666",
        "capture_time_recognition_metric": "23/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w96215666",
        "wall_object_key": "building:w96215666:wall",
        "roof_object_key": "building:w96215666:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
          0,
          1,
          2,
          3,
          4,
          5,
          19
        ],
        "protected_run_indices": [
          6,
          7,
          8,
          9,
          10,
          11,
          12,
          13,
          14,
          15,
          16,
          17,
          18
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1,
        "raw_source_constructor_callback_required": true,
        "tangent_callback_required": true,
        "continuity_run_indices": [
          0,
          2
        ],
        "partial_run_ownership": {
          "5": {
            "skin_fraction_interval": [
              0.0,
              0.5
            ],
            "unestablished_outer_half_protected": true
          },
          "19": {
            "skin_fraction_interval": [
              0.15,
              1.0
            ],
            "cropped_outer_endpoint_protected": true
          }
        }
      },
      "geometry_contract": {
        "source_chunk_sha256": "7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 18,
        "visual_surfaces": 18,
        "visual_triangles": 4746,
        "wall_native_counts": [
          17,
          17,
          4736,
          3,
          13
        ],
        "roof_native_counts": [
          1,
          1,
          10,
          1,
          1
        ],
        "world_records": 735,
        "world_mesh_instances": 1192,
        "world_surfaces": 1207,
        "world_triangles": 164001,
        "world_static_bodies": 488,
        "world_shapes": 594,
        "world_topology_scope": "pre_northern_1232_1241_1221_integration_live_parity"
      },
      "ownership_contract": {
        "structural_owner_count": 4,
        "shape_count": 14,
        "spray_owner_count": 2,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": false,
        "original_wall_and_projected_front_are_receivers": true,
        "projected_receiver_runs": [
          1,
          3,
          4,
          5,
          19
        ],
        "projected_receiver_triangles": 6,
        "projected_receiver_shape_order": [
          "ProjectedUpperSiding"
        ],
        "projected_receiver_physics_layer": 5,
        "projected_receiver_cull_mask": 2,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall",
          "ObservedPublicRoof",
          "CarportRoof",
          "CarportPosts",
          "ProjectedUpperClosures",
          "PaleCompleteTrim",
          "BlueOpaqueGlazing",
          "DarkOpaqueGlazing",
          "BlueGrayClosedDoors",
          "LocalPrivacyScreens",
          "PaleDrainageAndFascia",
          "DoorHardware"
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof"
        ],
        "added_public_roof_triangles": 100,
        "original_flat_roof_preserved": true,
        "added_public_roof_is_nonreceiver": true,
        "all_additions_render_only": false,
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
        "spray_input_event_dispatch_claimed": false,
        "separate_setup_poses_retained": true,
        "sparse_movie_samples_only": true,
        "raw_door_station_failure_retained": false,
        "original_visual_hold_retained": true,
        "metadata_only_observer_retained": false,
        "unexecuted_central_carport_proposal_retained": false,
        "motion_route_scope": "finite_first_contact_retreat_and_three_spray_cases",
        "station_held_claimed": false,
        "prior_clipped_tag_failure_retained": false,
        "scoped_hairline_observation_retained": false,
        "native_support_qualification_mm": 0,
        "original_failed_mechanics_attempts_retained": true
      }
    },
    "runtime_asset_count": 5
  },
  {
    "unit_id": "physical-building:w96215673",
    "wall": "building:w96215673:wall",
    "roof": "building:w96215673:roof",
    "adapter_id": "active-adapter:northpoint-1232-live:building:w96215673:wall",
    "acceptance": {
      "evidence_manifest_sha256": "d2d9bd3d7f643d92b45d4c1ca974892d3b35210ae2d2cfe55b89fb4afb94df26",
      "motion_telemetry_manifest_sha256": "1fd9e52c06c062e48dfc3d6489dfaba4350ba1413a97923f9a44371b052dad39",
      "visual_motion_manifest_sha256": "26d44f6abccabc4c3075a214a22feff4ba4f6d5b2f6b1b2815d4c32301c37577",
      "package_verification_receipt_sha256": "f38bbb66dce45b62bdb82705335b55547f571992a8389f6b8346b16f56e32c1f",
      "evidence_tree_sha256": "c323d879c100e3ac1898905a9841e7f52cc4a76022e7329638ae7feeb586739d",
      "mechanical_review_receipt_sha256": "2560c1e1032fd997a2cf8db74de48d0430d9bb0fb61165cc09312efba5e9af5f",
      "review_receipt_sha256": "1cbb4737ed14190e9f6a744b152eaaeddf8d18c39f827cfab784ec94f07c16be",
      "capture_time_recognition_metric": "26/213",
      "numerator_effect": 1,
      "review_id": "northern-1232-quality-candidate-2026-09-22-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.northern-1232-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "d2d9bd3d7f643d92b45d4c1ca974892d3b35210ae2d2cfe55b89fb4afb94df26",
        "motion_telemetry_manifest_sha256": "1fd9e52c06c062e48dfc3d6489dfaba4350ba1413a97923f9a44371b052dad39",
        "visual_motion_manifest_sha256": "26d44f6abccabc4c3075a214a22feff4ba4f6d5b2f6b1b2815d4c32301c37577",
        "package_verification_receipt_sha256": "f38bbb66dce45b62bdb82705335b55547f571992a8389f6b8346b16f56e32c1f",
        "evidence_tree_sha256": "c323d879c100e3ac1898905a9841e7f52cc4a76022e7329638ae7feeb586739d",
        "mechanical_review_receipt_sha256": "2560c1e1032fd997a2cf8db74de48d0430d9bb0fb61165cc09312efba5e9af5f",
        "review_receipt_sha256": "1cbb4737ed14190e9f6a744b152eaaeddf8d18c39f827cfab784ec94f07c16be",
        "accepted_physical_unit_id": "physical-building:w96215673",
        "capture_time_recognition_metric": "26/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w96215673",
        "wall_object_key": "building:w96215673:wall",
        "roof_object_key": "building:w96215673:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
          10,
          11,
          12,
          13,
          14,
          15,
          16,
          17,
          18
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
          19,
          20,
          21,
          22,
          23
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1,
        "raw_source_constructor_callback_required": true,
        "tangent_callback_required": true
      },
      "geometry_contract": {
        "source_chunk_sha256": "7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 19,
        "visual_surfaces": 19,
        "visual_triangles": 2576,
        "wall_native_counts": [
          18,
          18,
          2560,
          3,
          14
        ],
        "roof_native_counts": [
          1,
          1,
          16,
          1,
          1
        ],
        "world_records": 735,
        "world_mesh_instances": 1244,
        "world_surfaces": 1259,
        "world_triangles": 173181,
        "world_static_bodies": 494,
        "world_shapes": 633,
        "world_topology_scope": "shared_northern_1232_1241_1221_candidate_live_parity"
      },
      "ownership_contract": {
        "structural_owner_count": 4,
        "shape_count": 15,
        "spray_owner_count": 2,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": false,
        "original_wall_and_projected_front_are_receivers": true,
        "projected_receiver_runs": [
          10,
          11,
          12,
          13,
          15,
          16,
          17,
          18
        ],
        "projected_receiver_triangles": 6,
        "projected_receiver_shape_order": [
          "ProjectedUpperSiding"
        ],
        "projected_receiver_physics_layer": 5,
        "projected_receiver_cull_mask": 2,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall",
          "ObservedPublicRoof",
          "CarportRoof",
          "CarportPosts",
          "CarportFascia",
          "ProjectedUpperClosures",
          "PaleCompleteTrim",
          "BlueOpaqueGlazing",
          "DarkOpaqueGlazing",
          "BlueGrayClosedDoors",
          "LocalPrivacyScreens",
          "PaleDrainageAndFascia",
          "DoorHardware"
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof"
        ],
        "added_public_roof_triangles": 36,
        "original_flat_roof_preserved": true,
        "added_public_roof_is_nonreceiver": true,
        "all_additions_render_only": false,
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
        "spray_input_event_dispatch_claimed": false,
        "separate_setup_poses_retained": true,
        "sparse_movie_samples_only": true,
        "native_support_qualification_mm": 4,
        "scope_authority": "exact_unit_seventh_attestation_and_retained_first_five",
        "unit_packet_limits_retained": true,
        "motion_route_scope": "selected_door10_screen11_three_sprays_separate_setups"
      }
    },
    "runtime_asset_count": 5
  },
  {
    "unit_id": "physical-building:w96215674",
    "wall": "building:w96215674:wall",
    "roof": "building:w96215674:roof",
    "adapter_id": "active-adapter:northpoint-1241-live:building:w96215674:wall",
    "acceptance": {
      "evidence_manifest_sha256": "465fd62a4b0ce93e7185b6eb17bdf50ede9127e60c492e59848d830d1fb0d2f7",
      "motion_telemetry_manifest_sha256": "c2e401e59485819a039b4b40bf0f025edabf9691673b179e89c338927a10939c",
      "visual_motion_manifest_sha256": "690e653a17e8adcebe8908ffa06c8a6dd7b2c5e6886d42f9415e1b03f2ecfd9a",
      "package_verification_receipt_sha256": "c7a8caf732d9d50ba481b3a889ab9c8aff72833fb2277c56fb997d7af3baef98",
      "evidence_tree_sha256": "4b293afae85d79015d9f6c0a0b22dff50962db7bf8b05d9f4ba52e152cb13a32",
      "mechanical_review_receipt_sha256": "6c956cd7f3b7502ab73505d11297efa68d365f7f393f8419fd9293fb71a99cb9",
      "review_receipt_sha256": "b89b6e90ed0cd33dcf4a540a62965a71ff75c3d8d2eb9ec1e8368b6e3016f869",
      "capture_time_recognition_metric": "28/213",
      "numerator_effect": 1,
      "review_id": "northern-1241-quality-candidate-2026-09-22-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.northern-1241-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "465fd62a4b0ce93e7185b6eb17bdf50ede9127e60c492e59848d830d1fb0d2f7",
        "motion_telemetry_manifest_sha256": "c2e401e59485819a039b4b40bf0f025edabf9691673b179e89c338927a10939c",
        "visual_motion_manifest_sha256": "690e653a17e8adcebe8908ffa06c8a6dd7b2c5e6886d42f9415e1b03f2ecfd9a",
        "package_verification_receipt_sha256": "c7a8caf732d9d50ba481b3a889ab9c8aff72833fb2277c56fb997d7af3baef98",
        "evidence_tree_sha256": "4b293afae85d79015d9f6c0a0b22dff50962db7bf8b05d9f4ba52e152cb13a32",
        "mechanical_review_receipt_sha256": "6c956cd7f3b7502ab73505d11297efa68d365f7f393f8419fd9293fb71a99cb9",
        "review_receipt_sha256": "b89b6e90ed0cd33dcf4a540a62965a71ff75c3d8d2eb9ec1e8368b6e3016f869",
        "accepted_physical_unit_id": "physical-building:w96215674",
        "capture_time_recognition_metric": "28/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w96215674",
        "wall_object_key": "building:w96215674:wall",
        "roof_object_key": "building:w96215674:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
          0,
          1,
          2,
          3,
          5,
          6,
          7,
          8,
          10,
          11,
          12
        ],
        "protected_run_indices": [
          4,
          9,
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
          23,
          24,
          25
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1,
        "raw_source_constructor_callback_required": true,
        "tangent_callback_required": true
      },
      "geometry_contract": {
        "source_chunk_sha256": "d82a0767672898b348115d9df812a1a33bee96bca0d5d58713c52087591011bc",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 19,
        "visual_surfaces": 19,
        "visual_triangles": 3432,
        "wall_native_counts": [
          18,
          18,
          3416,
          3,
          14
        ],
        "roof_native_counts": [
          1,
          1,
          16,
          1,
          1
        ],
        "world_records": 735,
        "world_mesh_instances": 1244,
        "world_surfaces": 1259,
        "world_triangles": 173181,
        "world_static_bodies": 494,
        "world_shapes": 633,
        "world_topology_scope": "shared_northern_1232_1241_1221_candidate_live_parity"
      },
      "ownership_contract": {
        "structural_owner_count": 4,
        "shape_count": 15,
        "spray_owner_count": 2,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": false,
        "original_wall_and_projected_front_are_receivers": true,
        "projected_receiver_runs": [
          0,
          1,
          2,
          3,
          5,
          6,
          7,
          8,
          10,
          11,
          12
        ],
        "projected_receiver_triangles": 6,
        "projected_receiver_shape_order": [
          "ProjectedUpperSiding"
        ],
        "projected_receiver_physics_layer": 5,
        "projected_receiver_cull_mask": 2,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall",
          "ObservedPublicRoof",
          "CarportRoof",
          "CarportPosts",
          "CarportFascia",
          "ProjectedUpperClosures",
          "PaleCompleteTrim",
          "BlueOpaqueGlazing",
          "DarkOpaqueGlazing",
          "MaroonClosedDoors",
          "LocalPrivacyScreens",
          "PaleDrainageAndFascia",
          "DoorHardware"
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof"
        ],
        "added_public_roof_triangles": 36,
        "original_flat_roof_preserved": true,
        "added_public_roof_is_nonreceiver": true,
        "all_additions_render_only": false,
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
        "spray_input_event_dispatch_claimed": false,
        "separate_setup_poses_retained": true,
        "sparse_movie_samples_only": true,
        "native_support_qualification_mm": 4,
        "scope_authority": "exact_unit_seventh_attestation_and_retained_first_five",
        "unit_packet_limits_retained": true,
        "motion_route_scope": "selected_run7_door2_screen_partial_run12_spray_separate_setups"
      }
    },
    "runtime_asset_count": 5
  },
  {
    "unit_id": "physical-building:w96215682",
    "wall": "building:w96215682:wall",
    "roof": "building:w96215682:roof",
    "adapter_id": "active-adapter:mariner-1221-live:building:w96215682:wall",
    "acceptance": {
      "evidence_manifest_sha256": "cb80718812047da42fb907917cafe4ce59a15eada7b2dc9aaef1b26b56697970",
      "motion_telemetry_manifest_sha256": "cffac7d9d8bda08c1651fa0db0f4969ddf9de5ce9065548dd25e1aab415e571f",
      "visual_motion_manifest_sha256": "a00772f32f2b9a68adc9607638b4045bb1abafa6455c906a718e6e9cc6ef2259",
      "package_verification_receipt_sha256": "80140a7a02f241033157e6f22813a98b56ddf718193298ee0237f040562d8885",
      "evidence_tree_sha256": "b3861383f25ceb1f14f6f068dcabf145b3afe9fb5ba8b0056f1e6b79a145e757",
      "mechanical_review_receipt_sha256": "76517f928240abbe44a989e29546135711039869f595b0d7f6073a3cf8262153",
      "review_receipt_sha256": "235ae67b88d48acccd234af320e5a2c439318f9bff2fa1af66744858a01cb41f",
      "capture_time_recognition_metric": "28/213",
      "numerator_effect": 1,
      "review_id": "northern-1221-quality-candidate-2026-09-22-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.northern-1221-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "cb80718812047da42fb907917cafe4ce59a15eada7b2dc9aaef1b26b56697970",
        "motion_telemetry_manifest_sha256": "cffac7d9d8bda08c1651fa0db0f4969ddf9de5ce9065548dd25e1aab415e571f",
        "visual_motion_manifest_sha256": "a00772f32f2b9a68adc9607638b4045bb1abafa6455c906a718e6e9cc6ef2259",
        "package_verification_receipt_sha256": "80140a7a02f241033157e6f22813a98b56ddf718193298ee0237f040562d8885",
        "evidence_tree_sha256": "b3861383f25ceb1f14f6f068dcabf145b3afe9fb5ba8b0056f1e6b79a145e757",
        "mechanical_review_receipt_sha256": "76517f928240abbe44a989e29546135711039869f595b0d7f6073a3cf8262153",
        "review_receipt_sha256": "235ae67b88d48acccd234af320e5a2c439318f9bff2fa1af66744858a01cb41f",
        "accepted_physical_unit_id": "physical-building:w96215682",
        "capture_time_recognition_metric": "28/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w96215682",
        "wall_object_key": "building:w96215682:wall",
        "roof_object_key": "building:w96215682:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
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
          10,
          11,
          12
        ],
        "protected_run_indices": [
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
          23,
          24,
          25
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1,
        "raw_source_constructor_callback_required": true,
        "tangent_callback_required": true
      },
      "geometry_contract": {
        "source_chunk_sha256": "7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 20,
        "visual_surfaces": 20,
        "visual_triangles": 3372,
        "wall_native_counts": [
          19,
          19,
          3356,
          3,
          14
        ],
        "roof_native_counts": [
          1,
          1,
          16,
          1,
          1
        ],
        "world_records": 735,
        "world_mesh_instances": 1244,
        "world_surfaces": 1259,
        "world_triangles": 173181,
        "world_static_bodies": 494,
        "world_shapes": 633,
        "world_topology_scope": "pre_northern_1240_integration_live_parity"
      },
      "ownership_contract": {
        "structural_owner_count": 4,
        "shape_count": 15,
        "spray_owner_count": 2,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": false,
        "original_wall_and_projected_front_are_receivers": true,
        "projected_receiver_runs": [
          0,
          1,
          2,
          4,
          5,
          6,
          9,
          10,
          11,
          12
        ],
        "projected_receiver_triangles": 6,
        "projected_receiver_shape_order": [
          "ProjectedUpperSiding"
        ],
        "projected_receiver_physics_layer": 5,
        "projected_receiver_cull_mask": 2,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall",
          "ObservedPublicRoof",
          "CarportRoof",
          "CarportPosts",
          "CarportFascia",
          "ProjectedUpperClosures",
          "PaleCompleteTrim",
          "BlueOpaqueGlazing",
          "DarkOpaqueGlazing",
          "MaroonClosedDoors",
          "LocalPrivacyScreens",
          "PaleDrainageAndFascia",
          "DoorHardware"
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof"
        ],
        "added_public_roof_triangles": 36,
        "original_flat_roof_preserved": true,
        "added_public_roof_is_nonreceiver": true,
        "all_additions_render_only": false,
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
        "spray_input_event_dispatch_claimed": false,
        "separate_setup_poses_retained": true,
        "sparse_movie_samples_only": true,
        "native_support_qualification_mm": 4,
        "scope_authority": "exact_unit_seventh_attestation_and_retained_first_five",
        "unit_packet_limits_retained": true,
        "motion_route_scope": "selected_door1_screen_first_contact_retreat_three_sprays_separate_setups"
      }
    },
    "runtime_asset_count": 5
  },
  {
    "unit_id": "physical-building:w96215688",
    "wall": "building:w96215688:wall",
    "roof": "building:w96215688:roof",
    "adapter_id": "active-adapter:northpoint-1240-live:building:w96215688:wall",
    "acceptance": {
      "evidence_manifest_sha256": "35ca950b839ba5337ec6aa1afa23c3a41b541ddbcc72d8cd948fd3ff945f357e",
      "motion_telemetry_manifest_sha256": "6940be3303a7bb398e89594dbbe029913b6199836e96b58ca5ed6f8cfdab6d3d",
      "visual_motion_manifest_sha256": "cef4880c25f45a6d11699843dce565efd2620fc48a0904aa5af2e6f4aa8b2b9e",
      "package_verification_receipt_sha256": "aa9865bc070916b027cb58759259bd8ee0b27d1ca36ac413360d4b9d261c1ad4",
      "evidence_tree_sha256": "d272fe5677097e67016ea21af2e9eb5e9a5daff69ad7f86deb1d343b02b7e18c",
      "mechanical_review_receipt_sha256": "0a6727056299a7bbf91fc97137ff794d5350128c9b3f15276f7680de9aa921d3",
      "review_receipt_sha256": "deee84ad808e2a740f79f3c796b87c18b242e18f005a902646d3645d9c580939",
      "capture_time_recognition_metric": "31/213",
      "numerator_effect": 1,
      "review_id": "northern-1240-quality-candidate-2026-09-22-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.northern-1240-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "35ca950b839ba5337ec6aa1afa23c3a41b541ddbcc72d8cd948fd3ff945f357e",
        "motion_telemetry_manifest_sha256": "6940be3303a7bb398e89594dbbe029913b6199836e96b58ca5ed6f8cfdab6d3d",
        "visual_motion_manifest_sha256": "cef4880c25f45a6d11699843dce565efd2620fc48a0904aa5af2e6f4aa8b2b9e",
        "package_verification_receipt_sha256": "aa9865bc070916b027cb58759259bd8ee0b27d1ca36ac413360d4b9d261c1ad4",
        "evidence_tree_sha256": "d272fe5677097e67016ea21af2e9eb5e9a5daff69ad7f86deb1d343b02b7e18c",
        "mechanical_review_receipt_sha256": "0a6727056299a7bbf91fc97137ff794d5350128c9b3f15276f7680de9aa921d3",
        "review_receipt_sha256": "deee84ad808e2a740f79f3c796b87c18b242e18f005a902646d3645d9c580939",
        "accepted_physical_unit_id": "physical-building:w96215688",
        "capture_time_recognition_metric": "31/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w96215688",
        "wall_object_key": "building:w96215688:wall",
        "roof_object_key": "building:w96215688:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
          15,
          16,
          18,
          19,
          20,
          21,
          23,
          24,
          25
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
          10,
          11,
          12,
          13,
          14,
          17,
          22,
          26,
          27
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1,
        "raw_source_constructor_callback_required": true,
        "tangent_callback_required": true
      },
      "geometry_contract": {
        "source_chunk_sha256": "bb21618ff0bc88549e3a600d981880415817747475c2c3a0d368a7da8db4d3ac",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 18,
        "visual_surfaces": 18,
        "visual_triangles": 3056,
        "wall_native_counts": [
          17,
          17,
          3040,
          3,
          14
        ],
        "roof_native_counts": [
          1,
          1,
          16,
          1,
          1
        ],
        "world_records": 735,
        "world_mesh_instances": 1260,
        "world_surfaces": 1275,
        "world_triangles": 176165,
        "world_static_bodies": 496,
        "world_shapes": 646,
        "world_topology_scope": "pre_northern_1397_1226_integration_live_parity"
      },
      "ownership_contract": {
        "structural_owner_count": 4,
        "shape_count": 15,
        "spray_owner_count": 2,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": false,
        "original_wall_and_projected_front_are_receivers": true,
        "projected_receiver_runs": [
          15,
          16,
          18,
          19,
          20,
          21,
          23,
          24,
          25
        ],
        "projected_receiver_triangles": 6,
        "projected_receiver_shape_order": [
          "ProjectedUpperSiding"
        ],
        "projected_receiver_physics_layer": 5,
        "projected_receiver_cull_mask": 2,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall",
          "ObservedPublicRoof",
          "CarportRoof",
          "CarportPosts",
          "CarportFascia",
          "ProjectedUpperClosures",
          "PaleCompleteTrim",
          "BlueOpaqueGlazing",
          "DarkOpaqueGlazing",
          "MaroonClosedDoors",
          "LocalPrivacyScreens",
          "PaleDrainageAndFascia",
          "DoorHardware"
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof"
        ],
        "added_public_roof_triangles": 36,
        "original_flat_roof_preserved": true,
        "added_public_roof_is_nonreceiver": true,
        "all_additions_render_only": false,
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
        "spray_input_event_dispatch_claimed": false,
        "separate_setup_poses_retained": true,
        "sparse_movie_samples_only": true,
        "native_support_qualification_mm": 4,
        "scope_authority": "exact_unit_seventh_attestation_and_retained_first_five",
        "unit_packet_limits_retained": true,
        "motion_route_scope": "six_selected_stock_approaches_returns_four_spray_callbacks_separate_setups_activation_limit_retained"
      }
    },
    "runtime_asset_count": 5
  },
  {
    "unit_id": "physical-building:w96215670",
    "wall": "building:w96215670:wall",
    "roof": "building:w96215670:roof",
    "adapter_id": "active-adapter:gateview-1397-live:building:w96215670:wall",
    "acceptance": {
      "evidence_manifest_sha256": "cde59334d381c071cb3b79c5591b07b33d0d40e7cfd9533c9bb411729f0389e5",
      "motion_telemetry_manifest_sha256": "9b1d6a56ca2c1700d3e7013b878b07bf1651822d8869ae5bb351f090ff75abfb",
      "visual_motion_manifest_sha256": "967714aaac2103a6e6a4db329943c8102aac83da9eded80b5a0b40bbc329dfb1",
      "package_verification_receipt_sha256": "0f365d480a4e65c08ec9dd16d90d5137db1d79b1ea126e62268f0f7d05c7343e",
      "evidence_tree_sha256": "612b7acc1e2a7f81abe8c6a4939c484861766ab2a22678c5bffe17a1659c178d",
      "mechanical_review_receipt_sha256": "6b7fc9735392613c74b96919f49845787a9f2814cd3d45b9487c5173b75f455d",
      "review_receipt_sha256": "8cd5135999eee64795decf6957b78668d51c31c8f232144a1506680759b0315c",
      "capture_time_recognition_metric": "31/213",
      "numerator_effect": 1,
      "review_id": "northern-1397-quality-candidate-2026-09-22-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.northern-1397-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "cde59334d381c071cb3b79c5591b07b33d0d40e7cfd9533c9bb411729f0389e5",
        "motion_telemetry_manifest_sha256": "9b1d6a56ca2c1700d3e7013b878b07bf1651822d8869ae5bb351f090ff75abfb",
        "visual_motion_manifest_sha256": "967714aaac2103a6e6a4db329943c8102aac83da9eded80b5a0b40bbc329dfb1",
        "package_verification_receipt_sha256": "0f365d480a4e65c08ec9dd16d90d5137db1d79b1ea126e62268f0f7d05c7343e",
        "evidence_tree_sha256": "612b7acc1e2a7f81abe8c6a4939c484861766ab2a22678c5bffe17a1659c178d",
        "mechanical_review_receipt_sha256": "6b7fc9735392613c74b96919f49845787a9f2814cd3d45b9487c5173b75f455d",
        "review_receipt_sha256": "8cd5135999eee64795decf6957b78668d51c31c8f232144a1506680759b0315c",
        "accepted_physical_unit_id": "physical-building:w96215670",
        "capture_time_recognition_metric": "31/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w96215670",
        "wall_object_key": "building:w96215670:wall",
        "roof_object_key": "building:w96215670:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
          17,
          18,
          19,
          20,
          23,
          24,
          25,
          26,
          27,
          28,
          30,
          31,
          32,
          33,
          34,
          35,
          36,
          37
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
          10,
          11,
          12,
          13,
          14,
          15,
          16,
          21,
          22,
          29
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1,
        "raw_source_constructor_callback_required": true,
        "tangent_callback_required": true
      },
      "geometry_contract": {
        "source_chunk_sha256": "d82a0767672898b348115d9df812a1a33bee96bca0d5d58713c52087591011bc",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 15,
        "visual_surfaces": 15,
        "visual_triangles": 4278,
        "wall_native_counts": [
          14,
          14,
          4256,
          3,
          11
        ],
        "roof_native_counts": [
          1,
          1,
          22,
          1,
          1
        ],
        "world_records": 735,
        "world_mesh_instances": 1287,
        "world_surfaces": 1302,
        "world_triangles": 183761,
        "world_static_bodies": 500,
        "world_shapes": 667,
        "world_topology_scope": "pre_northern_1226_authority_serialization_live_parity"
      },
      "ownership_contract": {
        "structural_owner_count": 4,
        "shape_count": 12,
        "spray_owner_count": 2,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": false,
        "original_wall_and_projected_front_are_receivers": true,
        "projected_receiver_runs": [
          17,
          18,
          19,
          20,
          23,
          24,
          25,
          26,
          27,
          28,
          30,
          31,
          32,
          33,
          34,
          35,
          36,
          37
        ],
        "projected_receiver_triangles": 8,
        "projected_receiver_shape_order": [
          "ProjectedUpperSiding"
        ],
        "projected_receiver_physics_layer": 5,
        "projected_receiver_cull_mask": 2,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall",
          "ObservedPublicRoof",
          "ProjectedUpperClosures",
          "PaleCompleteTrim",
          "BlueOpaqueGlazing",
          "DarkOpaqueGlazing",
          "MaroonClosedDoors",
          "LocalPrivacyScreens",
          "PaleDrainageAndFascia",
          "DoorHardware"
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof"
        ],
        "added_public_roof_triangles": 48,
        "original_flat_roof_preserved": true,
        "added_public_roof_is_nonreceiver": true,
        "all_additions_render_only": false,
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
        "spray_input_event_dispatch_claimed": false,
        "separate_setup_poses_retained": true,
        "sparse_movie_samples_only": true,
        "native_support_qualification_mm": 4,
        "scope_authority": "exact_unit_seventh_attestation_and_retained_first_five",
        "unit_packet_limits_retained": true,
        "motion_route_scope": "Preserve original sampled motion/source/static/spray scope; source actual PASS adds no visual/motion claim."
      }
    },
    "runtime_asset_count": 5
  },
  {
    "unit_id": "physical-building:w96215685",
    "wall": "building:w96215685:wall",
    "roof": "building:w96215685:roof",
    "adapter_id": "active-adapter:bayside-1226-live:building:w96215685:wall",
    "acceptance": {
      "evidence_manifest_sha256": "d22c4ea98b753531685b40ff1f05c3087ee029bb4fc78cbf0c106fff4e0189b5",
      "motion_telemetry_manifest_sha256": "a188d596b298c6ed5d45552aae62cf8ea90b1a234ed00c52a7e669b6f75760d7",
      "visual_motion_manifest_sha256": "9c7620c3980d6904b5d11d8de53e4f37147814e3da30c0c1b0bd9ae94f25fbd1",
      "package_verification_receipt_sha256": "ac58f77b8ebbe04fe5398fdd6f48f1aa009bcb80b81710161bfd7a90259cfbfd",
      "evidence_tree_sha256": "7f71cadbe18c72b605a1eb624fe817427dd2d7454fb5f951abcb26563b2b3774",
      "mechanical_review_receipt_sha256": "6a60ae2b4d8f78e64b8bcb7b8e6af47aa178fca74a7ad5bf0119b2bf058e3938",
      "review_receipt_sha256": "9b9d209e3c61376dd96ded5869754a5261407602b4647473e321fff1454c6727",
      "capture_time_recognition_metric": "31/213",
      "numerator_effect": 1,
      "review_id": "northern-1226-quality-candidate-2026-09-22-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "behavior": {
      "schema_version": "ti.northern-1226-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "d22c4ea98b753531685b40ff1f05c3087ee029bb4fc78cbf0c106fff4e0189b5",
        "motion_telemetry_manifest_sha256": "a188d596b298c6ed5d45552aae62cf8ea90b1a234ed00c52a7e669b6f75760d7",
        "visual_motion_manifest_sha256": "9c7620c3980d6904b5d11d8de53e4f37147814e3da30c0c1b0bd9ae94f25fbd1",
        "package_verification_receipt_sha256": "ac58f77b8ebbe04fe5398fdd6f48f1aa009bcb80b81710161bfd7a90259cfbfd",
        "evidence_tree_sha256": "7f71cadbe18c72b605a1eb624fe817427dd2d7454fb5f951abcb26563b2b3774",
        "mechanical_review_receipt_sha256": "6a60ae2b4d8f78e64b8bcb7b8e6af47aa178fca74a7ad5bf0119b2bf058e3938",
        "review_receipt_sha256": "9b9d209e3c61376dd96ded5869754a5261407602b4647473e321fff1454c6727",
        "accepted_physical_unit_id": "physical-building:w96215685",
        "capture_time_recognition_metric": "31/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w96215685",
        "wall_object_key": "building:w96215685:wall",
        "roof_object_key": "building:w96215685:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
          5,
          6,
          7,
          8,
          9,
          11,
          12,
          14
        ],
        "protected_run_indices": [
          0,
          1,
          2,
          3,
          4,
          10,
          13,
          15,
          16,
          17,
          18,
          19,
          20,
          21,
          22,
          23,
          24,
          25
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1,
        "raw_source_constructor_callback_required": true,
        "tangent_callback_required": true
      },
      "geometry_contract": {
        "source_chunk_sha256": "7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 16,
        "visual_surfaces": 16,
        "visual_triangles": 3482,
        "wall_native_counts": [
          15,
          15,
          3468,
          3,
          12
        ],
        "roof_native_counts": [
          1,
          1,
          14,
          1,
          1
        ],
        "world_records": 735,
        "world_mesh_instances": 1287,
        "world_surfaces": 1302,
        "world_triangles": 183761,
        "world_static_bodies": 500,
        "world_shapes": 667,
        "world_topology_scope": "current_integration_topology"
      },
      "ownership_contract": {
        "structural_owner_count": 4,
        "shape_count": 13,
        "spray_owner_count": 2,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": false,
        "original_wall_and_projected_front_are_receivers": true,
        "projected_receiver_runs": [
          5,
          6,
          7,
          8,
          9,
          11,
          12,
          14
        ],
        "projected_receiver_triangles": 8,
        "projected_receiver_shape_order": [
          "ProjectedUpperSiding"
        ],
        "projected_receiver_physics_layer": 5,
        "projected_receiver_cull_mask": 2,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall",
          "ObservedPublicRoof",
          "ShallowStoryBands",
          "ProjectedUpperClosures",
          "PaleCompleteTrim",
          "BlueOpaqueGlazing",
          "DarkOpaqueGlazing",
          "MaroonClosedDoors",
          "LocalPrivacyScreens",
          "PaleDrainageAndFascia",
          "DoorHardware"
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof"
        ],
        "added_public_roof_triangles": 48,
        "original_flat_roof_preserved": true,
        "added_public_roof_is_nonreceiver": true,
        "all_additions_render_only": false,
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
        "spray_input_event_dispatch_claimed": false,
        "separate_setup_poses_retained": true,
        "sparse_movie_samples_only": true,
        "native_support_qualification_mm": 4,
        "scope_authority": "exact_unit_seventh_attestation_and_retained_first_five",
        "unit_packet_limits_retained": true,
        "motion_route_scope": "Preserve original raw HOLD, corrected DERIVED925 routes and later3 ACTUAL sprays separately."
      }
    },
    "runtime_asset_count": 5
  }
];
for (const d of expectedD5Batch) {
  const unit = registry.units.find((u) => u.unit_id === d.unit_id);
  const adapter = registry.active_runtime_adapters.find((a) => a.receiver_key === d.wall);
  assert(unit.acceptance_records.length === 1 && unit.direct_receivers.length === 1 && unit.active_runtime_adapter_ids.length === 1 && stableJson(unit.acceptance_records[0]) === stableJson(d.acceptance), `${d.unit_id} exact single-unit seven-artifact authority drifted`);
  assert(adapter.runtime_assets.length === d.runtime_asset_count && adapter.runtime_asset_projections.length === 0 && stableJson(adapter.active_runtime_contract.behavior_contract) === stableJson(d.behavior), `${d.unit_id} live pair/terrain/ownership boundary drifted`);
}
for (const d of expectedD5Batch) {
  for (const field of ["evidence_manifest_sha256","motion_telemetry_manifest_sha256","visual_motion_manifest_sha256","package_verification_receipt_sha256","mechanical_review_receipt_sha256","evidence_tree_sha256","review_receipt_sha256"]) {
    expectCompileFailure((candidate) => { candidate.units.find((u) => u.unit_id === d.unit_id).acceptance_records[0][field] = "0".repeat(64); }, field === "review_receipt_sha256" ? "review receipt pin drifted" : field === "evidence_manifest_sha256" ? "evidence manifest pin drifted" : "seven-artifact acceptance closure drifted");
    expectCompileFailure((candidate) => { delete candidate.units.find((u) => u.unit_id === d.unit_id).acceptance_records[0][field]; }, ["evidence_manifest_sha256","review_receipt_sha256"].includes(field) ? "required property" : "seven-artifact acceptance closure drifted");
  }
  expectCompileFailure((candidate) => { const u = candidate.units.find((u) => u.unit_id === d.unit_id); u.acceptance_records.push(structuredClone(u.acceptance_records[0])); }, "duplicate");
  expectCompileFailure((candidate) => { candidate.units.find((u) => u.unit_id === d.unit_id).acceptance_records[0].numerator_effect = 2; }, "number exceeds maximum 1");
  expectCompileFailure((candidate) => { candidate.units.find((u) => u.unit_id === d.unit_id).acceptance_records[0].numerator_effect = d.acceptance.numerator_effect === 1 ? 0 : 1; }, "seven-artifact acceptance closure drifted");
  expectCompileFailure((candidate) => { candidate.units.find((u) => u.unit_id === d.unit_id).receiver_keys.push(d.roof); }, "string does not match");
  expectCompileFailure((candidate) => { candidate.units.find((u) => u.unit_id === d.unit_id).acceptance_records[0].capture_time_recognition_metric = "11/213"; }, "seven-artifact acceptance closure drifted");
  for (const mutate of [
    (b) => { b.replacement_contract.mapped_public_run_indices[0] += 0.5; },
    (b) => { b.replacement_contract.protected_run_indices[0] += 0.5; },
    (b) => { if (["physical-building:w764313741", "physical-building:r19685981", "physical-building:w96215672", "physical-building:w96215669", "physical-building:w96215677", "physical-building:w96215680", "physical-building:w96215649", "physical-building:w96215652", "physical-building:w96215658", "physical-building:w96215661", "physical-building:w96215653", "physical-building:w96215651", "physical-building:w96215659", "physical-building:w96215666", "physical-building:w96215673", "physical-building:w96215674", "physical-building:w96215682", "physical-building:w96215688", "physical-building:w96215670", "physical-building:w96215685"].includes(d.unit_id)) b.geometry_contract.source_chunk_sha256 = "0".repeat(64); else b.geometry_contract.canonical_terrain_records[Object.keys(b.geometry_contract.canonical_terrain_records)[0]] = "0".repeat(64); },
    (b) => { b.ownership_contract.roof_is_wall_spray_receiver = true; },
    (b) => { if (d.unit_id === "physical-building:w764313741") b.ownership_contract.wall_shape_order[0] = "invalid_source_role"; else b.ownership_contract.wall_shape_order.reverse(); },
    (b) => { b.geometry_contract.world_shapes = 470; },
  ]) expectRegistryFailure((candidate) => { mutate(candidate.active_runtime_adapters.find((a) => a.receiver_key === d.wall).active_runtime_contract.behavior_contract); }, "acceptance, source, terrain, topology or ownership parity drifted");
}

console.log(
  `PASS facade recognition registry: ${EXPECTED.recognition_units} physical units / ${EXPECTED.direct_wall_receivers} receivers / ${EXPECTED.source_records} source records / ${EXPECTED.visible_wall_runs} runs / 34/213 independently accepted reference-recognizable physical units / ${EXPECTED.legacy_adapter_receivers} claim-neutral legacy adapters + ${EXPECTED.active_runtime_adapter_receivers} exact-current active adapters / ${packageBoundary.projected_direct_asset_count} sanitized asset projections / 2 separated identity corrections / 60 reference dependencies; catalog ${sha256File(PATHS.catalog)}; registry ${registrySha256}`,
);
