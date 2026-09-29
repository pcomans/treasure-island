import assert from "node:assert/strict";
import { readFileSync, mkdtempSync, mkdirSync, writeFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { sha256File } from "./lib/world-contract.mjs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { loadHousingFamilyAuthority, validateHousingFamilyInstances, validateHousingFamilyAuthority, validateFamilyImageTree, familyCapturePaths, validateFamilyCapture, familyCurrentBinding, familySiteDelta, validateFamilyCurrentAttachment } from "./lib/housing-family-authority.mjs";
import { compile, loadInputs, PATHS, validateRuntimeRegistry } from "./build_facade_recognition_registry.mjs";
const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const read = path => JSON.parse(readFileSync(resolve(root,path),"utf8"));
const manifest = read("game/resources/housing_family/live_instances.json");
const world = read("generated/world/manifest.json");
let negatives = 0;
const reject = (action, message) => { assert.throws(action,message); negatives++; };
const acceptedFamily = loadHousingFamilyAuthority(root);
assert.equal(acceptedFamily.length, 9, "Reviewed nine-unit authority must remain complete");
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
// File-binding fixtures have no PASS decisions, receipts, or recognition claims.
const sandbox = mkdtempSync(resolve(tmpdir(),"family-capture-bindings-"));
try {
  const put = (path, text="{}") => { mkdirSync(dirname(resolve(sandbox,path)),{recursive:true}); writeFileSync(resolve(sandbox,path),text); return {path,sha256:sha256File(resolve(sandbox,path))}; };
  for (const dir of ["game/scripts","game/scenes","game/resources"]) mkdirSync(resolve(sandbox,dir),{recursive:true});
  const draft = {unit_id:"physical-building:w1",source_key:"w1",receiver_key:"building:w1:wall",config:put("game/resources/housing_family/w1.json"),chunk:put("generated/world/chunks/a.json"),dependencies:{}};
  put("game/resources/example-material.tres","material input");
  const frozenWorld = {chunks:[{path:"chunks/a.json"}]};
  for (const path of familyCapturePaths(sandbox,draft,frozenWorld)) put(path);
  const dependencies = Object.fromEntries(familyCapturePaths(sandbox,draft,frozenWorld).map(p => [p,sha256File(resolve(sandbox,p))]));
  const map = Object.fromEntries(Object.entries(dependencies).map(([p,h]) => [`/original/${p}`,h]));
  const retained = ["driver.gd","driver.py","instances.json","trace.json"].map(name => {
    const original_path=`/original/game/tests/${name}`, file=put(`retained/${name}`);
    map[original_path]=file.sha256; return {original_path,file};
  });
  draft.capture={project_root:"/original",input_map:put("retained/map.json",JSON.stringify(map)),dependencies,retained_inputs:retained};
  assert.deepEqual(validateFamilyCapture(sandbox,draft,frozenWorld),map);
  for (const mutate of [
    d => d.config.path="game/resources/housing_family/w2.json",
    d => d.capture.dependencies["game/scripts/world/world_loader.gd"]="0".repeat(64),
    d => d.capture.dependencies["game/resources/example-material.tres"]="0".repeat(64),
    d => d.capture.input_map.sha256="0".repeat(64),
    d => d.capture.retained_inputs[0].original_path="/original/wrong.gd",
    d => d.capture.retained_inputs[0].file.sha256="0".repeat(64),
  ]) { const d=structuredClone(draft); mutate(d); reject(()=>validateFamilyCapture(sandbox,d,frozenWorld),/Family/); }
  const current = familyCurrentBinding(draft,{instances:[{source_key:"w1"}],expected_visible_active_topology:{active_bodies:1}});
  const attachment={source_binding:current,pck_sha256:"1".repeat(64),build_valid:true,normal_loader_owned:true,roles:Object.fromEntries(["ground","roof","support","wall"].map(role=>[role,{object_key:`building:w1:${role==="roof"?"roof":"wall"}`,collision_layer:role==="wall"?5:1,visual_layer:role==="wall"?2:1,spray_receiver:role==="wall"}]))};
  validateFamilyCurrentAttachment(attachment,current,attachment.pck_sha256);
  for (const mutate of [a=>a.pck_sha256="2".repeat(64),a=>a.source_binding.source_key="w2",a=>a.source_binding.expected_visible_active_topology.active_bodies=2,a=>a.roles.wall.object_key="building:w2:wall",a=>a.normal_loader_owned=false]) {
    const a=structuredClone(attachment); mutate(a); reject(()=>validateFamilyCurrentAttachment(a,current,attachment.pck_sha256),/Family candidate/);
  }
  draft.dependencies={"game/resources/housing_family/w2.json":"2".repeat(64)};
  const delta=familySiteDelta(sandbox,draft,map);
  assert(delta.some(d=>d.path.endsWith("w2.json") && d.capture_sha256===null));
  assert(!delta.some(d=>d.path.endsWith("w1.json")), "Unchanged config outside current dependency declaration is not a removal");
} finally { rmSync(sandbox,{recursive:true,force:true}); }
const inputs = loadInputs();
const catalog = read(PATHS.catalog);
const result = compile(catalog,inputs);
assert.equal(result.registry.recognition_metric.display,`${34 + acceptedFamily.length}/213`);
assert.equal(result.registry.housing_family_acceptance.length, acceptedFamily.length);
const forged = structuredClone(result.registry);
forged.housing_family_acceptance.push({unit_id:"physical-building:w96215693"});
reject(() => validateRuntimeRegistry(forged,result.adapterContracts),/family authority summary/);
const forgedRecord = structuredClone(catalog);
const unit = forgedRecord.units.find(u => u.unit_id === "physical-building:w96215693");
unit.acceptance_records.push({review_id:"unreviewed-family-draft",review_kind:"independent_reference_recognition",status:"reject",evidence_manifest_sha256:"0".repeat(64),review_receipt_sha256:"0".repeat(64)});
reject(() => compile(forgedRecord,inputs),/not an allowlisted/);
console.log(`PASS housing family authority: reviewed route preserves historical34 plus9, dynamic source membership, ${negatives} negative checks; no fabricated PASS artifacts`);
