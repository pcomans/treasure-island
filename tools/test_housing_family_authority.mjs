import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { loadHousingFamilyAuthority, validateHousingFamilyInstances, validateHousingFamilyAuthority, validateFamilyImageTree } from "./lib/housing-family-authority.mjs";
import { compile, loadInputs, PATHS, validateRuntimeRegistry } from "./build_facade_recognition_registry.mjs";
const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const read = path => JSON.parse(readFileSync(resolve(root,path),"utf8"));
const manifest = read("game/resources/housing_family/live_instances.json");
const world = read("generated/world/manifest.json");
let negatives = 0;
const reject = (action, message) => { assert.throws(action,message); negatives++; };
assert.deepEqual(loadHousingFamilyAuthority(root), [], "No new acceptance evidence exists yet");
assert.equal(validateHousingFamilyInstances(root, manifest, world).length, manifest.instances.length);
const subset = structuredClone(manifest); subset.instances = subset.instances.slice(0,2);
assert.equal(validateHousingFamilyInstances(root, subset, world).length, 2, "Target count must follow validated declarations");
for (const [mutate, message] of [
  [m => m.instances.push(m.instances[0]), /Duplicate/],
  [m => m.instances[0].config = m.instances[1].config, /config escapes/],
  [m => m.instances[0].chunk = m.instances[1].chunk, /receiver membership/],
  [m => m.instances[0].chunk = "res://generated/world/chunks/absent.json", /frozen world/],
  [m => m.expected_visible_active_topology.active_bodies = 1.5, /integer counts/],
  [m => m.expected_visible_active_topology.active_bodies = "512", /integer counts/],
  [m => m.instances = [], /no declared targets/],
]) { const changed = structuredClone(manifest); mutate(changed); reject(() => validateHousingFamilyInstances(root,changed,world),message); }
const context = {manifest, world, units:[], historicalUnitIds:[]};
assert.deepEqual(validateHousingFamilyAuthority(root,[],context),[]);
reject(() => validateHousingFamilyAuthority(root,[{status:"draft"}],context), /entry fields/);
// Reuse real immutable historical images only to test the image-tree algorithm;
// this does not produce or accept a synthetic family packet.
const treePath = "evidence/first-playable/northern-1397-quality-candidate-2026-09-22-001/evidence-tree.json";
const tree = read(treePath);
validateFamilyImageTree(root,treePath,tree,tree.tree_sha256,tree.files.length);
const wrongTree = structuredClone(tree); wrongTree.tree_sha256 = "0".repeat(64);
reject(() => validateFamilyImageTree(root,treePath,wrongTree,wrongTree.tree_sha256,tree.files.length),/digest drifted/);
const wrongBytes = structuredClone(tree); wrongBytes.files[0].bytes++;
reject(() => validateFamilyImageTree(root,treePath,wrongBytes,tree.tree_sha256,tree.files.length),/image bytes/);
const inputs = loadInputs();
const catalog = read(PATHS.catalog);
const result = compile(catalog,inputs);
assert.equal(result.registry.recognition_metric.display,"34/213");
assert.deepEqual(result.registry.housing_family_acceptance,[]);
const forged = structuredClone(result.registry);
forged.housing_family_acceptance.push({unit_id:"physical-building:w96215693"});
reject(() => validateRuntimeRegistry(forged,result.adapterContracts),/family authority summary/);
const forgedRecord = structuredClone(catalog);
const unit = forgedRecord.units.find(u => u.unit_id === "physical-building:w96215693");
unit.acceptance_records.push({review_id:"unreviewed-family-draft",review_kind:"independent_reference_recognition",status:"reject",evidence_manifest_sha256:"0".repeat(64),review_receipt_sha256:"0".repeat(64)});
reject(() => compile(forgedRecord,inputs),/not an allowlisted/);
console.log(`PASS housing family authority: empty route retains34/213, dynamic source membership, ${negatives} negative checks; no fabricated PASS artifacts`);
