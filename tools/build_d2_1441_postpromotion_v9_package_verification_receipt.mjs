import { createHash } from "node:crypto";
import { execFileSync } from "node:child_process";
import {
  existsSync,
  lstatSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  statSync,
  writeFileSync,
} from "node:fs";
import { dirname, relative, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const EXPECTED_APP = "build/d2-1441-postpromotion-v9-2026-09-07-001/Treasure Island First Playable.app";
const EXPECTED_RECEIPT = "build/d2-1441-postpromotion-v9-2026-09-07-001/package-verification-receipt.json";
const EXPECTED_GEOMETRY_SIGNATURE = "b91b373e3bb8238a6f73f05734ef48b3429ae5654eddce89b1981ee41ee89195";
const EXPECTED_OWNERSHIP_SIGNATURE = "fcad9968be3d0c9094adef5dcc9c7fabfb7cf1754f780897188a4ec362187e4d";
const EXPECTED_WALL_HASH = "00f3cd8b90e7ae93f802842b59bb10274f1fc388433e5b5c6cae1f3e23f4393c";
const EXPECTED_ROOF_HASH = "e7da0179f012e928f575ac32440e176a0f3b9651fc325a594de80ce7e3fc9d55";
const EXPECTED_MANIFEST_HASH = "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3";
const EXPECTED_CONTENT_HASH = "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164";
const EXPECTED_SEMANTIC_AUDIT_HASH = "3388576780493b6116c126684072426ad22279b9a3508127a0ffc8bcb77f9700";
const EXPECTED_SEMANTIC_AUDIT_VERDICT = "PASS_FOR_V9_POSTPROMOTION_EXPORT";
const EXPECTED_AUTHORITY_HASHES = Object.freeze({
  "discovery/facades/facade-recognition-catalog.json": "dc6d121d48621f98a203f2fea458316a46446a11e5f2a77d4064694322b2baa2",
  "discovery/facades/facade-recognition-catalog.schema.json": "8896fb9dcfd1cb48fc4bf0ed7ddc5fa50fdf7ec31335111291a1e2a2006e106d",
  "game/resources/facades/facade-runtime-registry.json": "26dcf64a34cf92aa7766c60940933190cdb5f9bc595dc23dc2f16fa01752e16c",
  "game/resources/facades/facade-runtime-adapter-contracts.json": "8c61ea5601ab94852ac593b8658963b52cb5253aae22a2ff109f2e46771caa93",
  "game/scripts/world/facades/facade_runtime_registry_loader.gd": "32e63c8774c0589856f15ac2ca0e7458e1cdce1403380e50a6ba99bd5185bd26",
  "tools/build_facade_recognition_registry.mjs": "4d6da1afa587d2dd8aefb24775d6ba838dd39ac60131985c9c899209572d3e74",
});
const RECEIPT_SCHEMA = "ti.d2-1441-postpromotion-v9-package-verification/1";
const BUNDLE_IDENTITY_ALGORITHM = "ascii_relative_path_nul_sha256_nul_bytes_lf_sorted_lc_all_c";

const REQUIRED_BUNDLE_FILES = Object.freeze([
  "Contents/Info.plist",
  "Contents/MacOS/Treasure Island First Playable",
  "Contents/PkgInfo",
  "Contents/Resources/PrivacyInfo.xcprivacy",
  "Contents/Resources/Treasure Island First Playable.pck",
  "Contents/Resources/icon.icns",
  "Contents/_CodeSignature/CodeResources",
]);

const SOURCE_PATHS = Object.freeze([
  "project.godot",
  "game/scripts/main.gd",
  "game/scripts/world/world_chunk_builder.gd",
  "game/resources/facades/d2_1441_chinook_live_replacement.json",
  "game/scripts/world/facades/d2_1441_chinook_live_replacement.gd",
  "game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd",
  "game/resources/facades/d2_1441_chinook_standalone_hero_prototype.json",
  "game/scripts/world/facades/site_12_housing_kit.gd",
  ...Object.keys(EXPECTED_AUTHORITY_HASHES),
  "game/tests/headless_d2_1441_chinook_live_replacement_contract.gd",
  "game/tests/headless_d2_1441_chinook_live_replacement_package_contract.gd",
  "game/tests/headless_d2_1441_postpromotion_v9_contract.gd",
  "game/tests/headless_d2_1441_postpromotion_v9_package_contract.gd",
  "game/tests/d2_1441_postpromotion_v9_capture.gd",
  "game/tests/isle_house_low_live_evidence_capture.gd",
  "game/tests/headless_startup_configuration_contract.gd",
  "game/tests/headless_scene_parse.gd",
  "game/tests/headless_gameplay_contract.gd",
  "game/tests/headless_world_material_contract.gd",
  "game/tests/validate_generated_world.gd",
  "game/tests/mounted_pck_content_audit.gd",
  "export_presets.cfg",
  "generated/world/chunks/x_-1__z_-1.json",
  "generated/world/manifest.json",
  "game/scenes/main.tscn",
  "game/scenes/world/world_root.tscn",
  "game/scripts/player/player_controller.gd",
  "game/scripts/player/player_camera.gd",
  "game/scripts/interaction/spray_controller.gd",
  "game/scripts/interaction/tag_instance_pool.gd",
  "game/resources/textures/tag/predefined_tag.svg",
  "game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres",
  "game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres",
  "game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres",
  "game/resources/materials/world/site_12_housing/site_12_void_shadow.tres",
  "game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres",
  "game/resources/materials/world/site_12_housing/site_12_dark_metal.tres",
  "game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png",
  "game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg",
  "evidence/first-playable/d2-1441-chinook-standalone-hero-2026-09-04/INDEPENDENT_BAR_RAISER_REVIEW.md",
  "evidence/reviews/d2-1441-promotion-v9-2026-09-07-INDEPENDENT_SEMANTIC_AUDIT.md",
  "tools/build_d2_1441_postpromotion_v9_package_verification_receipt.mjs",
]);

const LOG_SPECS = Object.freeze({
  export_release: "Code signing bundle",
  compiler_check: '"mode": "check"',
  compiler_mutation_suite: "PASS facade recognition registry:",
  loader_mutation_suite: "PASS facade runtime loader contract:",
  focused_source_contract: "PASS: D2 1441 postpromotion v9 is exactly 9/213",
  source_package_contract: "PASS: source D2 1441 postpromotion v9 package bridge is exact",
  mounted_package_contract: "PASS: mounted D2 1441 postpromotion v9 PCK is exact and private",
  generic_mounted_pck_content_audit: "PASS: direct-mounted PCK matches the explicit package/world identities",
  headless_exported_main_smoke: "PASS: packaged main scene reached full world_ready",
  native_exported_main_smoke: "PASS: packaged main scene reached full world_ready",
});

function invariant(condition, message) {
  if (!condition) throw new Error(message);
}

function asciiCompare(left, right) {
  return left < right ? -1 : left > right ? 1 : 0;
}

function sha256Bytes(value) {
  return createHash("sha256").update(value).digest("hex");
}

function sha256File(path) {
  return sha256Bytes(readFileSync(path));
}

function absolute(relativePath) {
  return resolve(ROOT, relativePath);
}

function normalizeRelative(path) {
  return relative(ROOT, resolve(path)).split(sep).join("/");
}

function parseArguments(argv) {
  const parsed = {};
  for (const argument of argv) {
    const equals = argument.indexOf("=");
    invariant(argument.startsWith("--") && equals > 2, `Unknown argument: ${argument}`);
    const key = argument.slice(2, equals);
    invariant(!Object.hasOwn(parsed, key), `Duplicate argument: --${key}`);
    parsed[key] = argument.slice(equals + 1);
  }
  const expectedKeys = ["app", "bundle-log", "compiler-check-log", "compiler-test-log", "export-log", "focused-log", "headless-log", "loader-test-log", "mounted-log", "native-log", "output", "pck-audit-log", "source-log"];
  invariant(JSON.stringify(Object.keys(parsed).sort(asciiCompare)) === JSON.stringify(expectedKeys), `Expected exactly ${expectedKeys.map((key) => `--${key}=...`).join(", ")}`);
  invariant(normalizeRelative(parsed.app) === EXPECTED_APP, `App must be fresh suffix 001: ${EXPECTED_APP}`);
  invariant(normalizeRelative(parsed.output) === EXPECTED_RECEIPT, `Receipt must be fresh suffix 001: ${EXPECTED_RECEIPT}`);
  return parsed;
}

function collectBundleFiles(root) {
  const output = [];
  function visit(directory) {
    for (const name of readdirSync(directory).sort(asciiCompare)) {
      const path = resolve(directory, name);
      const status = lstatSync(path);
      invariant(!status.isSymbolicLink(), `Bundle contains a symbolic link: ${relative(root, path)}`);
      if (status.isDirectory()) visit(path);
      else if (status.isFile()) output.push(path);
      else invariant(false, `Bundle contains an unsupported entry: ${relative(root, path)}`);
    }
  }
  visit(root);
  return output.sort((left, right) => asciiCompare(relative(root, left), relative(root, right)));
}

function inspectBundle(appPath, bundleLogPath) {
  invariant(existsSync(appPath) && statSync(appPath).isDirectory(), `Missing app bundle: ${appPath}`);
  const files = collectBundleFiles(appPath);
  const inventory = files.map((path) => ({
    path: relative(appPath, path).split(sep).join("/"),
    sha256: sha256File(path),
    bytes: statSync(path).size,
  }));
  invariant(JSON.stringify(inventory.map((item) => item.path)) === JSON.stringify(REQUIRED_BUNDLE_FILES), "App bundle is not the exact seven-file production boundary");
  const canonical = Buffer.concat(inventory.map((item) => Buffer.from(`${item.path}\0${item.sha256}\0${item.bytes}\n`, "utf8")));
  const bundleIdentity = sha256Bytes(canonical);
  const executablePath = resolve(appPath, "Contents/MacOS/Treasure Island First Playable");
  const pckPath = resolve(appPath, "Contents/Resources/Treasure Island First Playable.pck");
  const privacyPath = resolve(appPath, "Contents/Resources/PrivacyInfo.xcprivacy");
  const plistPath = resolve(appPath, "Contents/Info.plist");

  const architectures = execFileSync("/usr/bin/lipo", ["-archs", executablePath], { encoding: "utf8" }).trim().split(/\s+/u);
  invariant(JSON.stringify(architectures) === JSON.stringify(["x86_64", "arm64"]), `Unexpected architectures: ${architectures.join(" ")}`);
  execFileSync("/usr/bin/plutil", ["-lint", plistPath], { stdio: "pipe" });
  execFileSync("/usr/bin/plutil", ["-lint", privacyPath], { stdio: "pipe" });
  execFileSync("/usr/bin/codesign", ["--verify", "--deep", "--strict", appPath], { stdio: "pipe" });
  for (const architecture of architectures) execFileSync("/usr/bin/codesign", ["--verify", "--strict", "--arch", architecture, appPath], { stdio: "pipe" });
  const entitlements = execFileSync("/usr/bin/codesign", ["-d", "--entitlements", ":-", appPath], { encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] });
  invariant(/<dict>\s*<\/dict>/u.test(entitlements), "App entitlements are not an empty dictionary");
  const privacy = execFileSync("/usr/bin/plutil", ["-p", privacyPath], { encoding: "utf8" });
  invariant(/"NSPrivacyTracking" => false/u.test(privacy), "Privacy manifest does not disable tracking");
  const xattrs = execFileSync("/usr/bin/xattr", ["-lr", appPath], { encoding: "utf8" }).trim();
  invariant(xattrs.length === 0, "App bundle has extended attributes");

  const log = [
    "D2 1441 POSTPROMOTION V9 -001 BUNDLE VERIFICATION",
    `app_relative_path=${EXPECTED_APP}`,
    `file_count=${inventory.length}`,
    `bundle_identity_algorithm=${BUNDLE_IDENTITY_ALGORITHM}`,
    `bundle_identity_sha256=${bundleIdentity}`,
    `pck_sha256=${sha256File(pckPath)}`,
    `pck_bytes=${statSync(pckPath).size}`,
    `executable_sha256=${sha256File(executablePath)}`,
    `executable_bytes=${statSync(executablePath).size}`,
    `architectures=${architectures.join(",")}`,
    "info_plist_valid=true",
    "privacy_manifest_valid=true",
    "codesign_deep_strict_pass=true",
    "codesign_per_slice_pass=true",
    "entitlements_empty_dictionary=true",
    "extended_attributes_absent=true",
    "quarantine_absent=true",
    "RESULT=PASS",
    "",
  ].join("\n");
  invariant(!existsSync(bundleLogPath), `Refusing to overwrite bundle log: ${bundleLogPath}`);
  mkdirSync(dirname(bundleLogPath), { recursive: true });
  writeFileSync(bundleLogPath, log, { encoding: "utf8", flag: "wx" });
  return {
    architectures,
    bundleIdentity,
    bundleInventory: inventory,
    executableBytes: statSync(executablePath).size,
    executableSha256: sha256File(executablePath),
    pckBytes: statSync(pckPath).size,
    pckSha256: sha256File(pckPath),
  };
}

function validateLog(path, expectedMarker, label) {
  invariant(existsSync(path) && statSync(path).isFile(), `Missing ${label} log: ${path}`);
  const text = readFileSync(path, "utf8");
  invariant(text.includes(expectedMarker), `${label} log lacks its PASS marker`);
  invariant(!/(?:SCRIPT ERROR|ERROR:|D2_1441_POSTPROMOTION_PACKAGE_FAIL|PCK_AUDIT_FAIL|RESULT=FAIL)/u.test(text), `${label} log contains a failure marker`);
  return sha256File(path);
}

function exactConstant(source, name) {
  const matches = [...source.matchAll(new RegExp(`const\\s+${name}\\s*:=\\s*"([0-9a-f]{64})"`, "gu"))];
  invariant(matches.length === 1, `${name} must occur exactly once`);
  return matches[0][1];
}

function authoritativeTarget() {
  const configPath = "game/resources/facades/d2_1441_chinook_live_replacement.json";
  const adapterPath = "game/scripts/world/facades/d2_1441_chinook_live_replacement.gd";
  const capturePath = "game/tests/d2_1441_postpromotion_v9_capture.gd";
  const config = JSON.parse(readFileSync(absolute(configPath), "utf8"));
  const adapter = readFileSync(absolute(adapterPath), "utf8");
  const capture = readFileSync(absolute(capturePath), "utf8");
  const configGeometry = config.reviewed_art?.factory_geometry_signature;
  const adapterGeometry = exactConstant(adapter, "EXPECTED_GEOMETRY_SIGNATURE");
  const captureGeometry = exactConstant(capture, "D2_FROZEN_GEOMETRY_SIGNATURE");
  const adapterOwnership = exactConstant(adapter, "EXPECTED_LIVE_OWNERSHIP_SIGNATURE");
  const captureOwnership = exactConstant(capture, "D2_FROZEN_OWNERSHIP_SIGNATURE");
  invariant(configGeometry === EXPECTED_GEOMETRY_SIGNATURE && adapterGeometry === EXPECTED_GEOMETRY_SIGNATURE && captureGeometry === EXPECTED_GEOMETRY_SIGNATURE, "Config, adapter, and capture geometry signatures are not the same authoritative value");
  invariant(adapterOwnership === EXPECTED_OWNERSHIP_SIGNATURE && captureOwnership === EXPECTED_OWNERSHIP_SIGNATURE, "Adapter and capture ownership signatures drifted");
  invariant(config.target?.canonical_wall_record_sha256 === EXPECTED_WALL_HASH && config.target?.canonical_roof_record_sha256 === EXPECTED_ROOF_HASH, "Config canonical wall/roof hashes drifted");
  return {
    canonical_name: config.target.canonical_name,
    source_key: config.target.source_key,
    wall_object_key: config.target.wall_object_key,
    roof_object_key: config.target.roof_object_key,
    physical_unit_id: "physical-building:w95934105",
    mapped_public_sse_runs: config.reviewed_art.mapped_public_sse_runs,
    protected_runs: config.reviewed_art.protected_runs,
    confusion_set: ["w95934144", "w95934143", "w95934131", "w95934129"],
    geometry_signature: configGeometry,
    live_ownership_signature: adapterOwnership,
    wall_canonical_hash: config.target.canonical_wall_record_sha256,
    roof_canonical_hash: config.target.canonical_roof_record_sha256,
  };
}

function validateTarget(target) {
  invariant(target.geometry_signature === EXPECTED_GEOMETRY_SIGNATURE, "Receipt D2 geometry signature differs from authoritative config/adapter/capture value");
  invariant(target.live_ownership_signature === EXPECTED_OWNERSHIP_SIGNATURE, "Receipt D2 ownership signature drifted");
  invariant(target.wall_canonical_hash === EXPECTED_WALL_HASH && target.roof_canonical_hash === EXPECTED_ROOF_HASH, "Receipt D2 canonical wall/roof hashes drifted");
}

function sourceHashes() {
  return Object.fromEntries(SOURCE_PATHS.map((path) => {
    invariant(existsSync(absolute(path)) && statSync(absolute(path)).isFile(), `Missing source dependency: ${path}`);
    return [path, sha256File(absolute(path))];
  }));
}

function authorityHashes(sources) {
  const paths = [
    "discovery/facades/facade-recognition-catalog.json",
    "discovery/facades/facade-recognition-catalog.schema.json",
    "game/resources/facades/facade-runtime-registry.json",
    "game/resources/facades/facade-runtime-adapter-contracts.json",
    "game/scripts/world/facades/facade_runtime_registry_loader.gd",
    "tools/build_facade_recognition_registry.mjs",
  ];
  const result = {};
  for (const path of paths) result[path] = sources[path] ?? sha256File(absolute(path));
  for (const [path, expected] of Object.entries(EXPECTED_AUTHORITY_HASHES)) {
    invariant(result[path] === expected, `Current v9 authority bytes drifted: ${path}`);
  }
  return result;
}

function validateSemanticAudit() {
  const path = "evidence/reviews/d2-1441-promotion-v9-2026-09-07-INDEPENDENT_SEMANTIC_AUDIT.md";
  invariant(sha256File(absolute(path)) === EXPECTED_SEMANTIC_AUDIT_HASH, "Independent semantic-audit bytes drifted");
  const lines = readFileSync(absolute(path), "utf8").trim().split(/\r?\n/u);
  invariant(lines.at(-1)?.trim() === EXPECTED_SEMANTIC_AUDIT_VERDICT, "Independent semantic audit does not end in the required postpromotion export verdict");
  return path;
}

function validateAuthority() {
  const registry = JSON.parse(readFileSync(absolute("game/resources/facades/facade-runtime-registry.json"), "utf8"));
  const unit = registry.units.find((candidate) => candidate.unit_id === "physical-building:w95934105");
  invariant(registry.schema_version === "ti.facade-runtime-registry/9", "Runtime registry schema is not v9");
  const contracts = JSON.parse(readFileSync(absolute("game/resources/facades/facade-runtime-adapter-contracts.json"), "utf8"));
  const accepted = registry.recognition_metric?.accepted_physical_unit_ids ?? [];
  const adapters = registry.active_runtime_adapters ?? [];
  const plans = contracts.plans ?? [];
  invariant(registry.recognition_metric?.display === "9/213" && registry.recognition_metric?.numerator === 9 && registry.recognition_metric?.denominator === 213, "Recognition metric is not exactly 9/213");
  invariant(accepted.length === 9 && accepted.filter((id) => id === "physical-building:w95934105").length === 1, "1441 is not exactly once in the accepted 9-unit inventory");
  invariant(unit?.claim_status?.reference_recognizable === "accepted" && unit?.acceptance_records?.length === 1 && unit?.active_runtime_adapter_ids?.length === 1, "1441 current authority is not exactly accepted/active");
  invariant(unit.runtime_content_mode === "all_receivers_active_d2_1441_paired_replacement", "1441 current runtime content mode drifted");
  invariant(adapters.length === 8 && adapters.filter((item) => item.receiver_key === "building:w95934105:wall").length === 1, "Current active-adapter inventory drifted");
  invariant(contracts.schema_version === "ti.facade-runtime-adapter-contracts/8" && plans.length === 17, "Current adapter contract inventory drifted");
  invariant(plans.filter((item) => item.integration_state === "package_safe_ready_for_integration").length === 11 && plans.filter((item) => item.integration_state === "hard_disabled_source_projection").length === 6, "Current adapter integration-state counts drifted");
}

function buildReceipt(args, bundle) {
  validateAuthority();
  const semanticAuditPath = validateSemanticAudit();
  const target = authoritativeTarget();
  validateTarget(target);
  const sources = sourceHashes();
  const logPaths = {
    bundle_verification: args["bundle-log"],
    export_release: args["export-log"],
    compiler_check: args["compiler-check-log"],
    compiler_mutation_suite: args["compiler-test-log"],
    loader_mutation_suite: args["loader-test-log"],
    focused_source_contract: args["focused-log"],
    source_package_contract: args["source-log"],
    mounted_package_contract: args["mounted-log"],
    generic_mounted_pck_content_audit: args["pck-audit-log"],
    headless_exported_main_smoke: args["headless-log"],
    native_exported_main_smoke: args["native-log"],
  };
  const verificationLogHashes = {
    bundle_verification: validateLog(logPaths.bundle_verification, "RESULT=PASS", "bundle verification"),
  };
  for (const [label, marker] of Object.entries(LOG_SPECS)) verificationLogHashes[label] = validateLog(logPaths[label], marker, label.replaceAll("_", " "));
  return {
    schema_version: RECEIPT_SCHEMA,
    capture_date: "2026-09-07",
    candidate_status: "uncommitted_v9_candidate_pending_two_independent_postpromotion_audits",
    review_status: "pending_independent_postpromotion_contract_and_visual_audits_not_self_accepted",
    production_stage: "d2_1441_postpromotion_v9_current_authority_uncommitted_candidate",
    capture_time_recognition_metric: "9/213",
    catalog_schema_version: "ti.facade-recognition-catalog/9",
    runtime_registry_schema_version: "ti.facade-runtime-registry/9",
    adapter_contracts_schema_version: "ti.facade-runtime-adapter-contracts/8",
    loader_api_version: "ti.facade-runtime-registry-loader/8",
    compiler_version: "1.8.0",
    current_authority_target_accepted: true,
    recognition_credit: false,
    additional_recognition_credit: false,
    promotion: false,
    app_bundle_relative_path: EXPECTED_APP,
    app_bundle_name: "Treasure Island First Playable.app",
    architectures: bundle.architectures,
    bundle_file_count: bundle.bundleInventory.length,
    bundle_identity_algorithm: BUNDLE_IDENTITY_ALGORITHM,
    bundle_identity_sha256: bundle.bundleIdentity,
    bundle_inventory: bundle.bundleInventory,
    pck_sha256: bundle.pckSha256,
    pck_bytes: bundle.pckBytes,
    executable_sha256: bundle.executableSha256,
    executable_bytes: bundle.executableBytes,
    runtime_topology: { rows: 735, meshes: 959, surfaces: 974, triangles: 69252, bodies: 466, shapes: 466 },
    accepted_b225_baseline_topology: { rows: 735, meshes: 952, surfaces: 967, triangles: 67716, bodies: 466, shapes: 466 },
    generic_pair_replaced: { meshes: 2, surfaces: 2, triangles: 42, bodies: 2, shapes: 2 },
    d2_live_pair: {
      meshes: 9,
      surfaces: 9,
      triangles: 1578,
      bodies: 2,
      shapes: 2,
      collision_triangles: 42,
      wall_meshes: 8,
      wall_surfaces: 8,
      wall_triangles: 1568,
      wall_collision_triangles: 32,
      roof_meshes: 1,
      roof_surfaces: 1,
      roof_triangles: 10,
      roof_collision_triangles: 10,
      decorative_relief_triangles: 1536,
      decorative_relief_collision_triangles: 0,
    },
    d2_target: target,
    geometry_signature_binding: {
      adapter_path: "game/scripts/world/facades/d2_1441_chinook_live_replacement.gd",
      capture_path: "game/tests/d2_1441_postpromotion_v9_capture.gd",
      config_path: "game/resources/facades/d2_1441_chinook_live_replacement.json",
      reconciled: true,
      value: EXPECTED_GEOMETRY_SIGNATURE,
    },
    current_v9_authority_hashes: authorityHashes(sources),
    semantic_audit_path: semanticAuditPath,
    semantic_audit_sha256: EXPECTED_SEMANTIC_AUDIT_HASH,
    semantic_audit_verdict: EXPECTED_SEMANTIC_AUDIT_VERDICT,
    source_hashes: sources,
    receipt_generator: {
      path: "tools/build_d2_1441_postpromotion_v9_package_verification_receipt.mjs",
      sha256: sources["tools/build_d2_1441_postpromotion_v9_package_verification_receipt.mjs"],
      source: "fresh_current_v9_authoritative_inputs_and_verified_001_app_not_prior_receipt",
    },
    verification_log_hashes: verificationLogHashes,
    source_package_contract_pass: true,
    mounted_package_contract_pass: true,
    generic_mounted_pck_content_audit_pass: true,
    headless_exported_main_smoke_pass: true,
    native_exported_main_smoke_pass: true,
    mounted_standalone_activation_routes_absent: true,
    mounted_d2_runtime_closure_present: true,
    mounted_ordinary_main_present: true,
    mounted_override_absent: true,
    codesign_deep_strict_pass: true,
    codesign_per_slice_pass: true,
    entitlements_empty_dictionary: true,
    privacy_manifest_present: true,
    privacy_manifest_valid: true,
    extended_attributes_absent: true,
    quarantine_absent: true,
    pck_path_stored: false,
    receipt_self_hash_stored: false,
    downstream_postpromotion_evidence_hashes_bound_into_v9_authority: false,
    postcapture_catalog_or_registry_mutation: false,
  };
}

function mutationSelfTest() {
  const target = authoritativeTarget();
  validateTarget(target);
  const mutated = structuredClone(target);
  mutated.geometry_signature = "b91b373edbb41d5bf8ec67517b2150a519022a25466f66d9b6ca609834689195";
  let rejected = false;
  try {
    validateTarget(mutated);
  } catch (error) {
    rejected = String(error.message).includes("differs from authoritative");
  }
  invariant(rejected, "Historical geometry-signature typo mutation was not rejected");
}

function main() {
  const args = parseArguments(process.argv.slice(2));
  invariant(!existsSync(resolve(args.output)), `Refusing to overwrite receipt: ${args.output}`);
  invariant(!existsSync(resolve(args["bundle-log"])), `Refusing to overwrite bundle log: ${args["bundle-log"]}`);
  mutationSelfTest();
  const bundle = inspectBundle(resolve(args.app), resolve(args["bundle-log"]));
  const receipt = buildReceipt(args, bundle);
  invariant(receipt.d2_target.geometry_signature === receipt.geometry_signature_binding.value, "Receipt target and explicit geometry binding differ");
  mkdirSync(dirname(resolve(args.output)), { recursive: true });
  writeFileSync(resolve(args.output), `${JSON.stringify(receipt, null, 2)}\n`, { encoding: "utf8", flag: "wx" });
  process.stdout.write(`${JSON.stringify({
    app_bundle_relative_path: EXPECTED_APP,
    bundle_identity_sha256: receipt.bundle_identity_sha256,
    geometry_signature: receipt.d2_target.geometry_signature,
    output: EXPECTED_RECEIPT,
    receipt_sha256: sha256File(resolve(args.output)),
    status: "pass",
  }, null, 2)}\n`);
}

main();
