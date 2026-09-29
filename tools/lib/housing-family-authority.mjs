import { readFileSync, statSync, readdirSync, existsSync } from "node:fs";
import { createHash } from "node:crypto";
import { dirname, resolve } from "node:path";
import { invariant, sha256File, stableJson } from "./world-contract.mjs";

export const FAMILY_AUTHORITY_PATH = "discovery/facades/housing-family-acceptance.json";
// Updated only when a reviewed batch serializes its actual seven-artifact authority.
export const FAMILY_AUTHORITY_SHA256 = "12c0830ee6f4a08154fc2743dd481acea6ee8e7cde670f2ce348fdac741c704f";
export const FAMILY_MANIFEST_PATH = "game/resources/housing_family/live_instances.json";
export const FAMILY_SHARED_PATHS = Object.freeze([
  "game/scripts/world/world_loader.gd",
  "game/scripts/world/facades/housing_family_live_attachment.gd",
  "game/scripts/world/facades/housing_site_family.gd",
  "game/scripts/world/facades/northpoint_1232_quality_model.gd",
  "game/resources/housing_family/siding.gdshader",
  "game/resources/housing_family/roof.gdshader",
]);
export const FAMILY_ARTIFACT_FIELDS = Object.freeze({
  evidence_manifest_path: "evidence_manifest_sha256",
  motion_telemetry_manifest_path: "motion_telemetry_manifest_sha256",
  visual_motion_manifest_path: "visual_motion_manifest_sha256",
  mechanical_review_receipt_path: "mechanical_review_receipt_sha256",
  package_verification_receipt_path: "package_verification_receipt_sha256",
  review_path: "review_receipt_sha256",
});
const hash = value => typeof value === "string" && /^[0-9a-f]{64}$/u.test(value);
const same = (a, b) => stableJson(a) === stableJson(b);
const keys = (value, expected, label) => invariant(value && same(Object.keys(value).sort(), [...expected].sort()), `${label} fields drifted`);
const read = (root, path) => JSON.parse(readFileSync(resolve(root, path), "utf8"));
function relative(path) {
  invariant(typeof path === "string" && !path.startsWith("/") && !path.includes(":") && !path.split("/").some(p => p === ".." || p === ""), "Family binding requires a repository-relative path");
  return path;
}
function bound(root, binding, parse = true) {
  keys(binding, ["path", "sha256"], "Family file binding");
  invariant(hash(binding.sha256) && sha256File(resolve(root, relative(binding.path))) === binding.sha256, `Family artifact drifted: ${binding.path}`);
  return parse ? read(root, binding.path) : null;
}
export function loadHousingFamilyAuthority(root) {
  invariant(sha256File(resolve(root, FAMILY_AUTHORITY_PATH)) === FAMILY_AUTHORITY_SHA256, "Family authority declaration is not independently allowlisted");
  const document = read(root, FAMILY_AUTHORITY_PATH);
  keys(document, ["schema_version", "entries"], "Family authority");
  invariant(document.schema_version === "ti.housing-family-acceptance/1" && Array.isArray(document.entries), "Unknown family authority schema");
  return document.entries;
}

// Validates declared instances against the frozen world, independently of credit.
export function validateHousingFamilyInstances(root, manifest, world) {
  keys(manifest, ["instances", "expected_visible_active_topology"], "Family live manifest");
  keys(manifest.expected_visible_active_topology, ["visible_meshes", "visible_surfaces", "visible_triangles", "active_bodies", "active_shapes", "disabled_bodies"], "Family expected topology");
  invariant(Object.values(manifest.expected_visible_active_topology).every(n => Number.isSafeInteger(n) && n >= 0), "Family topology requires exact nonnegative integer counts");
  invariant(Array.isArray(manifest.instances) && manifest.instances.length > 0, "Family manifest has no declared targets");
  const seen = new Set();
  for (const item of manifest.instances) {
    keys(item, ["source_key", "config", "chunk"], "Family instance");
    invariant(/^w[0-9]+$/u.test(item.source_key) && !seen.has(item.source_key), "Duplicate or invalid family target");
    seen.add(item.source_key);
    invariant(item.config === `res://game/resources/housing_family/${item.source_key}.json`, "Family config escapes its target");
    const config = read(root, item.config.slice(6));
    invariant(!/(?:discovery\/|evidence\/|https?:\/\/|\/Users\/|\/Volumes\/)/u.test(JSON.stringify(config)), "Family config leaks private source paths or URLs");
    invariant(config.target?.source_key === item.source_key, "Family config target drifted");
    const chunk = world.chunks.find(c => item.chunk === `res://generated/world/${c.path}`);
    invariant(chunk && sha256File(resolve(root, item.chunk.slice(6))) === chunk.sha256, "Family target chunk is not frozen world membership");
    const records = read(root, item.chunk.slice(6)).records;
    for (const role of ["wall", "roof"]) {
      const matches = records.filter(r => r.object_key === `building:${item.source_key}:${role}`);
      invariant(matches.length === 1 && same(matches[0].source_keys, [item.source_key]), "Family exact wall/roof receiver membership drifted");
    }
  }
  return [...seen].sort();
}

export function validateFamilyImageTree(root, treePath, tree, expectedDigest, imageCount) {
  invariant(tree.algorithm === "ascii_relative_path_nul_sha256_nul_bytes_lf_sorted_lc_all_c" && Array.isArray(tree.files) && Number.isInteger(imageCount) && imageCount > 0 && tree.files.length === imageCount, "Family image tree algorithm/count drifted");
  const ordered = [...tree.files].sort((a,b) => Buffer.compare(Buffer.from(a.path), Buffer.from(b.path)));
  invariant(same(ordered, tree.files), "Family image tree paths are not in canonical byte order");
  const seen = new Set(), digest = createHash("sha256");
  for (const file of tree.files) {
    relative(file.path);
    const path = resolve(root, dirname(treePath), file.path);
    invariant(/^[\x20-\x7e]+$/u.test(file.path) && !seen.has(file.path) && hash(file.sha256) && sha256File(path) === file.sha256 && Number.isSafeInteger(file.bytes) && statSync(path).size === file.bytes, "Family image bytes/count missing, duplicate, or drifted");
    seen.add(file.path);
    digest.update(`${file.path}\0${file.sha256}\0${file.bytes}\n`);
  }
  invariant(digest.digest("hex") === expectedDigest && tree.tree_sha256 === expectedDigest, "Family image tree digest drifted");
}

// Capture inputs are immutable, while unrelated family membership may grow.
// Keep all runtime executables/scenes/shaders and canonical world bytes: a changed
// shared dependency is never made reusable by a reviewer saying it is unrelated.
// The authority-only registry loader is bound by the current package, because
// serializing genuine credit necessarily updates its allowlist after capture.
export function familyCapturePaths(root, entry, world) {
  const walk = dir => readdirSync(resolve(root, dir), {withFileTypes:true}).flatMap(item =>
    item.isDirectory() ? walk(`${dir}/${item.name}`) : [`${dir}/${item.name}`]);
  const authorityFiles = new Set([
    "game/scripts/world/facades/facade_runtime_registry_loader.gd",
    "game/resources/facades/facade-runtime-registry.json",
    "game/resources/facades/facade-runtime-adapter-contracts.json",
    "game/resources/housing_family/live_adoption.json", FAMILY_MANIFEST_PATH,
  ]);
  const runtimeInputs = walk("game").filter(path => !path.startsWith("game/tests/") && !authorityFiles.has(path)
    && (!/^game\/resources\/housing_family\/w[0-9]+\.json$/u.test(path) || path === entry.config.path));
  return [...new Set([...FAMILY_SHARED_PATHS, "project.godot", entry.config.path, entry.chunk.path,
    ...runtimeInputs, "generated/world/manifest.json",
    ...world.chunks.map(c => `generated/world/${c.path}`)])].sort();
}

export function validateFamilyCapture(root, entry, world) {
  const capture = entry.capture;
  keys(capture, ["project_root", "input_map", "dependencies", "retained_inputs"], "Family frozen capture");
  invariant(typeof capture.project_root === "string" && capture.project_root.startsWith("/") && !capture.project_root.endsWith("/"), "Family capture project root missing");
  const map = bound(root, capture.input_map);
  const required = familyCapturePaths(root, entry, world);
  invariant(same(Object.keys(capture.dependencies).sort(), required), "Family capture dependency set drifted");
  for (const path of required) {
    const digest = capture.dependencies[path];
    invariant(hash(digest) && map[`${capture.project_root}/${path}`] === digest && sha256File(resolve(root,path)) === digest, `Family frozen capture dependency drifted: ${path}`);
  }
  invariant(Array.isArray(capture.retained_inputs) && capture.retained_inputs.length > 0, "Family original capture inputs missing");
  const retained = new Set();
  for (const input of capture.retained_inputs) {
    keys(input, ["original_path", "file"], "Family retained original");
    invariant(typeof input.original_path === "string" && !retained.has(input.original_path) && map[input.original_path] === input.file.sha256, "Family original/input-map binding drifted");
    retained.add(input.original_path); bound(root,input.file,false);
  }
  // Preserve the actual producer and its configuration, not a rewritten driver.
  for (const suffix of [".gd", ".py", ".json"]) invariant([...retained].some(p => p.startsWith(`${capture.project_root}/game/tests/`) && p.endsWith(suffix)), "Family original capture producer/configuration missing");
  return map;
}

export function familyCurrentBinding(entry, manifest) {
  return {unit_id:entry.unit_id, source_key:entry.source_key, receiver_key:entry.receiver_key,
    config:entry.config, chunk:entry.chunk, dependencies:entry.dependencies,
    capture_dependencies:entry.capture.dependencies,
    instances:manifest.instances, expected_visible_active_topology:manifest.expected_visible_active_topology};
}

export function familySiteDelta(root, entry, map) {
  // Includes removed and newly added configs, not only today's declared targets.
  const prefix = `${entry.capture.project_root}/`;
  const paths = new Set([...Object.keys(entry.dependencies), ...readdirSync(resolve(root,"game/resources/housing_family")).filter(p => /^w[0-9]+\.json$/u.test(p)).map(p => `game/resources/housing_family/${p}`), ...Object.keys(map)
    .filter(p => p.startsWith(`${prefix}game/resources/housing_family/`) && /\/w[0-9]+\.json$/u.test(p))
    .map(p => p.slice(prefix.length))]);
  return [...paths].sort().flatMap(path => {
    const before = map[prefix+path] ?? null, after = entry.dependencies[path] ?? (existsSync(resolve(root,path)) ? sha256File(resolve(root,path)) : null);
    return before === after ? [] : [{path, capture_sha256:before, current_sha256:after}];
  });
}

export function validateFamilyCurrentAttachment(attachment, currentBinding, pckSha) {
  invariant(hash(pckSha) && attachment.pck_sha256 === pckSha && same(attachment.source_binding,currentBinding), "Family candidate exact app/target attachment drifted");
  invariant(attachment.build_valid === true && attachment.normal_loader_owned === true, "Family candidate normal-loader ownership missing");
  const expected = Object.fromEntries(["ground","roof","support","wall"].map(role => [role, {
    object_key:`building:${currentBinding.source_key}:${role === "roof" ? "roof" : "wall"}`,
    collision_layer:role === "wall" ? 5 : 1, visual_layer:role === "wall" ? 2 : 1,
    spray_receiver:role === "wall"}]));
  invariant(same(attachment.roles,expected), "Family candidate actual target roles drifted");
}

export function familyRuntimeSummary(entry) {
  return {unit_id: entry.unit_id, source_key: entry.source_key, receiver_key: entry.receiver_key,
    config: entry.config, chunk: entry.chunk, dependencies: entry.dependencies,
    acceptance_record: entry.acceptance};
}

// New authority is serialized only after candidate package and independent seventh
// attestation. This route never manufactures a PASS, claim, reference, or cue.
export function validateHousingFamilyAuthority(root, entries, {manifest, world, units, historicalUnitIds}) {
  validateHousingFamilyInstances(root, manifest, world);
  const seenUnits = new Set(), seenReviews = new Set();
  for (const entry of entries) {
    keys(entry, ["unit_id", "source_key", "receiver_key", "config", "chunk", "dependencies", "capture", "acceptance", "receipt", "tree_document_sha256", "image_count", "author_id", "mechanical_reviewer_id", "visual_reviewer_id"], "Family authority entry");
    invariant(entry.unit_id === `physical-building:${entry.source_key}` && entry.receiver_key === `building:${entry.source_key}:wall`, "Family physical-unit/receiver identity drifted");
    invariant(!seenUnits.has(entry.unit_id) && !historicalUnitIds.includes(entry.unit_id), "Family authority duplicates existing credit");
    seenUnits.add(entry.unit_id);
    const unit = units.find(u => u.unit_id === entry.unit_id);
    invariant(unit && same(unit.receiver_keys, [entry.receiver_key]), "Family authority not in frozen physical-unit inventory");
    const instance = manifest.instances.find(i => i.source_key === entry.source_key);
    invariant(instance && instance.config === `res://${entry.config.path}` && instance.chunk === `res://${entry.chunk.path}`, "Accepted family target is not installed by normal loader");
    bound(root, entry.config); bound(root, entry.chunk);
    const requiredPaths = [...new Set([...FAMILY_SHARED_PATHS, FAMILY_MANIFEST_PATH, ...manifest.instances.flatMap(item => [item.config.slice(6), item.chunk.slice(6)]), "generated/world/manifest.json"])].sort();
    invariant(same(Object.keys(entry.dependencies).sort(), requiredPaths), "Family executable/config/chunk dependency set drifted");
    for (const path of requiredPaths) invariant(hash(entry.dependencies[path]) && sha256File(resolve(root, path)) === entry.dependencies[path], `Family dependency drifted: ${path}`);
    const captureMap = validateFamilyCapture(root,entry,world);
    const currentBinding = familyCurrentBinding(entry,manifest);
    const siteDelta = familySiteDelta(root,entry,captureMap);
    const a = entry.acceptance;
    keys(a, [...Object.values(FAMILY_ARTIFACT_FIELDS), "evidence_tree_sha256", "capture_time_recognition_metric", "numerator_effect", "review_id", "review_kind", "status"], "Family seven-artifact acceptance");
    invariant(a.status === "accept" && a.review_kind === "independent_reference_recognition" && a.numerator_effect === 1 && /^\d+\/213$/u.test(a.capture_time_recognition_metric), "Family acceptance semantics drifted");
    invariant(Number(a.capture_time_recognition_metric.split("/")[0]) < historicalUnitIds.length + entries.length, "Family capture-time numerator is not a pre-credit authority");
    invariant(typeof a.review_id === "string" && a.review_id.length > 0 && !seenReviews.has(a.review_id), "Family review identity duplicate or missing");
    seenReviews.add(a.review_id);
    invariant(Object.values(FAMILY_ARTIFACT_FIELDS).every(k => hash(a[k])) && hash(a.evidence_tree_sha256), "Family acceptance hash malformed");
    invariant([entry.author_id, entry.mechanical_reviewer_id, entry.visual_reviewer_id].every(x => typeof x === "string" && x.length > 0) && new Set([entry.author_id, entry.mechanical_reviewer_id, entry.visual_reviewer_id]).size === 3, "Family independent reviewers must be separate from author and each other");
    const receipt = entry.receipt;
    keys(receipt, [...Object.keys(FAMILY_ARTIFACT_FIELDS), "evidence_tree_path"], "Family artifact paths");
    const artifacts = {};
    for (const [pathKey, hashKey] of Object.entries(FAMILY_ARTIFACT_FIELDS)) {
      artifacts[pathKey] = bound(root, {path: receipt[pathKey], sha256: a[hashKey]});
    }
    const tree = bound(root, {path: receipt.evidence_tree_path, sha256: entry.tree_document_sha256});
    validateFamilyImageTree(root, receipt.evidence_tree_path, tree, a.evidence_tree_sha256, entry.image_count);
    const sourceBinding = {unit_id: entry.unit_id, source_key: entry.source_key, receiver_key: entry.receiver_key, config: entry.config, chunk: entry.chunk, capture: entry.capture};
    for (const field of ["evidence_manifest_path", "motion_telemetry_manifest_path", "visual_motion_manifest_path", "mechanical_review_receipt_path"]) {
      const artifact = artifacts[field];
      invariant(artifact.decision === "PASS" && same(artifact.source_binding, sourceBinding) && artifact.capture_time_recognition_metric === a.capture_time_recognition_metric, `Family ${field} source/capture decision drifted`);
    }
    // Every image is an original in the frozen map; retained relocation is allowed.
    for (const file of tree.files) {
      const imagePath = resolve(root,dirname(receipt.evidence_tree_path),file.path);
      invariant(entry.capture.retained_inputs.some(input => resolve(root,input.file.path) === imagePath && input.file.sha256 === file.sha256), "Family image is not a retained original");
    }
    for (const field of ["evidence_manifest_path","motion_telemetry_manifest_path","visual_motion_manifest_path"]) {
      const originals = artifacts[field].original_inputs;
      invariant(Array.isArray(originals) && originals.length > 0 && originals.every(input => entry.capture.retained_inputs.some(retained => same(input,retained))), "Family source/motion original artifact binding missing");
    }
    const applicability = {capture_input_map:entry.capture.input_map, current_binding:currentBinding, site_delta:siteDelta};
    for (const artifact of [artifacts.mechanical_review_receipt_path,artifacts.review_path]) {
      invariant(same(artifact.site_context_binding,applicability) && artifact.site_context_applicable === true && typeof artifact.site_context_reason === "string" && artifact.site_context_reason.trim().length > 0, "Family changed site context lacks independent applicability review");
    }
    invariant(artifacts.mechanical_review_receipt_path.reviewer_id === entry.mechanical_reviewer_id, "Family mechanical independence drifted");
    const pkg = artifacts.package_verification_receipt_path;
    invariant(pkg.owner_decision === "PASS" && pkg.independent_exact_app_decision === "PASS" && pkg.independent_exact_app_review_pending === false && pkg.physical_unit_id === entry.unit_id && pkg.candidate_authority === a.capture_time_recognition_metric && pkg.unit_acceptance_granted === false && pkg.recognition_credit_granted === false, "Family candidate-before-credit package decision drifted");
    validateFamilyCurrentAttachment(pkg.unit_actual_attachment,currentBinding,pkg.pck_sha256);
    // Raw runs and independent release/privacy review remain bound, not transcribed
    // into a per-unit fake native execution.
    for (const binding of [pkg.independent_review, pkg.signature_privacy_binding, ...pkg.terminal_slot_releases, ...pkg.unit_actual_attachment.raw_runs]) bound(root, binding, false);
    invariant(pkg.terminal_slot_releases.length > 0 && pkg.unit_actual_attachment.raw_runs.length > 0, "Family package raw execution/terminal bindings missing");
    const review = artifacts.review_path;
    const six = Object.fromEntries(Object.entries(a).filter(([k]) => k.endsWith("_sha256") && k !== "review_receipt_sha256"));
    invariant(review.decision === "PASS" && review.physical_unit_id === entry.unit_id && review.reviewer_id === entry.visual_reviewer_id && same(review.acceptance_bindings, six) && review.evidence_tree_document_sha256 === entry.tree_document_sha256 && same(review.source_binding, sourceBinding), "Family seventh independent reference/visual attestation drifted");
  }
  return entries.map(familyRuntimeSummary);
}
