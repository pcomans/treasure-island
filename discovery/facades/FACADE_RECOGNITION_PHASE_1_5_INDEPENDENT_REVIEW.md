# Facade recognition Phase 1.5 independent review

Reviewed: **2026-09-04**

Verdict: **FAIL — the versioned loader boundary is mechanically safe, but one
declared-ready adapter plan is not exact-current.**

The compiler, version contracts, pathless projection descriptors, loader, and
focused tests all fail closed under the exercised mutations. They remain
topology-neutral and are not connected to world construction. However,
`building:w34313540:wall` is classified as one of six package-safe plans using
only the earlier Building 3 facade assets, while the current world dispatch now
replaces both Building 3 wall and roof through a new massing wrapper and config.
That wrapper/config pair is absent from the plan. The direct facade hashes were
correctly regenerated after the concurrent edit; the semantic dependency set
was not.

This is not a current gameplay regression because the loader is unused and
instantiates nothing. It does prevent approval of the claimed six-receiver
integration set. A bounded migration may proceed only for the five unaffected
ready receivers listed below, one receiver at a time and without removing the
existing dispatch until parity passes. Building 3 must remain excluded.

## Scope and method

This review was independent of implementation. It read the frozen facade
inventory and all 38 hashed world chunks directly, inspected the catalog,
schema, compiler, validation report, registry, adapter contracts, loader and
both focused test suites, and ran the following read-only checks twice:

```text
node tools/build_facade_recognition_registry.mjs --check
node tools/test_facade_recognition_registry.mjs
node tools/test_facade_runtime_loader_contract.mjs
Godot --headless --path . --script game/tests/headless_facade_recognition_registry_contract.gd
Godot --headless --path . --script game/tests/headless_facade_runtime_registry_loader_contract.gd
```

It also ran the real `full_runtime_integration.gd` once, exercised 19 additional
version/path mutations in memory, traversed runtime dependency closures, checked
syntax and whitespace, and inspected the complete dirty-tree name set. No
implementation, building, generated-world, catalog, registry, or test artifact
was edited by this review.

## Independently re-derived canonical partition

The counts below come from `discovery/FACADE_RECEIVER_INVENTORY.json` and the
hashed chunk files named by `generated/world/manifest.json`, not from registry
summary fields.

| Item | Independent result | Verdict |
| --- | ---: | --- |
| standalone building footprints | `212` | PASS |
| composite parent footprints | `1` (`w1249412094`) | PASS |
| building parts | `2` (`w1282547786`, `w1282547787`) | PASS |
| physical recognition units | `212 + 1 = 213` | PASS |
| uniquely partitioned source records | `215` | PASS |
| direct wall receivers in 38 chunks | `214` | PASS |
| visible wall runs | `4,971` | PASS |

The 214 receiver modes are exactly:

- `201` `generated_placeholder`;
- `11` `legacy_adapter`; and
- `2` `active_building_1_hero`.

At unit level this becomes 200 all-placeholder units, 10 all-legacy units, two
Building 1 hero units, and one mixed unit. Isle House remains one physical unit
with three source records and two direct receivers:

- high `building-composite:w1249412094:w1282547786:wall` is
  `legacy_adapter` and has the exact high adapter;
- low `building-composite:w1249412094:w1282547787:wall` is
  `generated_placeholder` with a null adapter; and
- unit `physical-building:w1249412094` is
  `mixed_legacy_adapter_and_generated_placeholder`.

The low receiver has no adapter plan and is not accidentally covered by the
high plan.

## Exact plan sets

The checked-in adapter contract contains 13 exact receiver plans, 12 unique
pathless projection descriptors and 14 projection occurrences.

Declared package-safe set (`6`):

1. `building-composite:w1249412094:w1282547786:wall` — Isle House high
2. `building:w1249412093:wall` — Hawkins
3. `building:w291189336:wall`
4. `building:w291189926:wall`
5. `building:w34313540:wall` — Building 3; **not approved as exact-current**
6. `building:w34313547:wall`

Hard-disabled set (`7`):

1. `building:r16681702:wall`
2. `building:w1222720021:wall`
3. `building:w291196370:wall`
4. `building:w34313515:wall`
5. `building:w34313520:wall`
6. `building:w34313525:wall`
7. `building:w34313564:wall`

Every disabled plan has `deny_all_executable_resolution`, an exact disabled
reason, at least one descriptor, and zero executable assets. Every descriptor
has only IDs, source type/hash, consumers and occurrences; it has no path,
uses `hard_disabled` plus `never_resolve_or_execute`, and cannot be mapped back
to a source file by the runtime loader.

For the declared-ready plans, executable entries are only `gdscript` below
`res://game/scripts/world/` or `packed_scene` below
`res://game/scenes/world/`. They are exact subsets of hash-checked
`res://game/` runtime assets. The Godot loader resolved every declared-ready
entry as a Resource, returned `instantiated: false`, and left the scene-tree
node count unchanged. The two material-only plans truthfully returned an empty
executable-resource list rather than inventing an executable adapter.

## Version and package boundary

The exact supported version matrix is:

| Layer | Supported version/policy |
| --- | --- |
| compiler | `1.1.0` |
| catalog | `ti.facade-recognition-catalog/2` |
| runtime registry | `ti.facade-runtime-registry/2` |
| adapter contract | `ti.facade-runtime-adapter-contracts/1` |
| loader API | `ti.facade-runtime-registry-loader/1` |
| unknown/forward policy | `reject`; `forward_compatible=false` |

Nineteen additional mutations independently changed the catalog version,
compiler version, emitted registry version, unknown-version policy, registry
version, registry catalog/compiler/loader compatibility, forward flag, adapter
schema/compiler/registry/policy, loader API/policy/instantiation authority,
projection shape, disabled executability, and ready executable root. All 19
were rejected.

Recursive package traversal independently produced:

| Root | Assets reached | Forbidden dependencies |
| --- | ---: | ---: |
| loader | `71` | `0` |
| adapter contracts | `71` | `0` |
| runtime registry | `71` | `0` |
| union of declared-ready plan assets | `56` | `0` |

The source-side report correctly records 45 unique direct inputs split into 33
clean runtime references and 12 sanitized projections. Source-bearing inputs
do have discovery/evidence/URL findings in the source-side audit; none of those
paths or URLs reaches the packaged registry, descriptor contract, or loader
closure.

## Claim neutrality

There is no recognition promotion in the current catalog or registry:

- receiver-complete: `213 verified`;
- game-distinctive: `0 accepted`, `213 not_evaluated`;
- reference-recognizable: `0 accepted`, `213 not_evaluated`;
- as-built fidelity: `0 claimed/limited`, `213 unclaimed`;
- recognition cues: `0`; configured capture contracts: `0`; and
- every one of the 13 adapters has `recognition_claim_effect: none` and does
  not import whole-building recognizability.

The two NRHP identity corrections remain summaries separate from frozen source
truth and make no currentness or recognition claim.

## Topology and runtime result

The loader is a `RefCounted` lookup/resolution object. It contains no
`instantiate`, `add_child`, collision, navigation or spray construction call.
Repository-wide lookup found no loader/registry preload or call from
`world_chunk_builder.gd`, `main.gd`, or a live scene. Only the loader itself,
its packaged data and focused tests refer to the Phase 1.5 API.

Both Godot passes produced the same deterministic lookup snapshot:

`0ac01b8f4b5c7c630b1949613b5e80f54e462ef8eb00b5da202a9018cd8e9a85`

The full runtime still passed gameplay, collision/spray, failed reload and
cleanup. Its current topology was 38 chunks / 729 records, 725 generated meshes
/ 735 generated surfaces / 48,825 generated triangles, 931 total meshes / 941
surfaces / 60,544 triangles, and 466 static bodies / 466 shapes. Baseline and
final scene-tree counts were both one. The additional Building 3 massing is
already reflected in those current runtime totals; it is not a loader effect.

## Ranked defects

### P1 — Building 3 is falsely included in the exact-current ready set

The frozen facade inventory still records Building 3 with
`runtime_massing_override_path: null`, disposition
`facade_language_accepted_with_documented_massing_limitation`, and an unchanged
flat extrusion limitation (`discovery/FACADE_RECEIVER_INVENTORY.json`, lines
193–200 and 6469–6506). The compiler therefore emits only the layout, facade
scene and facade script for `building:w34313540:wall`
(`facade-runtime-adapter-contracts.json`, lines 336–370).

Current live construction is different. `world_chunk_builder.gd` preloads
`building_3_600_california_massing.gd` and dispatches it before generic wall or
roof construction (lines 11 and 179–186). That wrapper owns both
`building:w34313540:wall` and `building:w34313540:roof`, replaces their visible
and collision geometry, loads `building_3_hero_massing.json`, and passes its
runtime massing contract into the facade. The massing config currently contains
an NPS URL, so it is source-bearing under the Phase 1.5 package policy.

The three facade asset hashes in the registry exactly match their current
bytes, and the validation report pins the current world-builder hash. Thus the
concurrent edit was regenerated, not bypassed. But hashes for an incomplete
asset set cannot establish current runtime parity. Resolving the emitted B3
plan would expose the facade scene/script without the wall-and-roof massing,
collision, roof or spray semantics that currently wrap it.

Minimal exact repair:

1. Until the pending Building 3 massing is independently accepted and
   canonicalized, classify `building:w34313540:wall` as hard-disabled and
   remove it from the ready expectation.
2. Reconcile the canonical B3 runtime attachment with both the current massing
   wrapper and its exact config. The config must either be normalized to a
   package-safe runtime file with source URLs retained only in discovery, or
   both current inputs must remain pathless projections with no executable
   resolution.
3. Recompile adapter contracts, registry and report; update exact counts, hashes
   and ready/disabled test sets. Add a focused assertion that a ready B3 plan
   names the currently dispatched wrapper and preserves its paired wall/roof,
   topology, collision and spray contract.

No repair should simply add the source-bearing config as an executable runtime
path or instantiate the older facade scene directly.

### P3 — Checked-in mutation coverage does not exercise every version field

The checked-in tests assert all version values and mutate representative
catalog, compiler, registry, adapter and loader versions. They do not mutate
every individual compatibility/policy field. Direct inspection shows exact
comparisons, and this review's 19-case mutation pass rejected every omitted
case, so this is not a current safety failure. Preserve those extra cases in a
future focused contract to make the complete version matrix regression-proof.

## Dirty-tree and integration decision

`git diff --check`, JavaScript syntax checks and the generated-world/data
no-diff check passed. The shared tree contains substantial concurrent Building
1, Building 3, evidence and runtime-test work. No generated world or frozen OSM
file changed, and this review does not accept unrelated dirty changes.

**Integration decision:** do not begin a six-plan or Building 3 migration from
this contract. A bounded integration may begin for exactly these five unaffected
receivers: Isle House high, Hawkins, `w291189336`, `w291189926`, and
`w34313547`. Each must retain its old dispatch until semantic, transform,
material, topology, collision, navigation, spray and visual parity passes. The
seven original disabled receivers, Isle House low, and Building 3 remain out of
scope until their stated gates close.

## Reviewed hashes

| Artifact | SHA-256 |
| --- | --- |
| facade receiver inventory | `0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f` |
| generated manifest | `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3` |
| compiler | `9fc3e55b0f80f3decb021e0b7f45580f98d7ba4d7d75066298308d0809eaaa88` |
| registry Node test | `db5de97b536442d0b9f6ca626ea8b873d727e612065a51644030eea0700ff570` |
| loader Node test | `c313e51352eab76fc9472578cde2ddd3b82597e681607e2a1141bdc91d6e6966` |
| schema validator | `e2c883ec6f834aa8339204f0eb444e86e73830ec98d421449445321c98e9e79a` |
| catalog schema | `b43e1221d5fe850a88168c78ea712f6c74328da452f6ae78fe04c25314936a77` |
| authoring catalog | `e6933a31532be6a56ebbf857b559cd267ac20cec80a0ae9c3b49943b05f1c394` |
| validation report | `4783d437341827eafba312441901c41ff48af77131444041e5979c9995be4ee8` |
| runtime registry | `8de46603e79c99753f0692a766edfaae228b304eff21a2bcc39ab25567086bd3` |
| adapter contracts | `e8599081a73a0ca5affe6964beeacaccac13146439211563a6e5cd594610acc6` |
| runtime loader | `108a0b549959ae7bd61644334389c35e1ba804f8cd7c3a973c09cfde95e04ef6` |
| registry Godot test | `cad4999061ce36a9f248e4d1c76cbb42dc735d1e7bb65f145e588c3d2b1c1bd4` |
| loader Godot test | `a65cf41418fe104a6772b55d27be6321ee2abaf97dc7affa650720c5b3e811c2` |
| full runtime integration test | `8083e8aa5ab324f7484e6c0c483913dc6159321a867058f14f45fb35e2cca4e8` |
| current world builder | `952b2e55369895b44baf624d11bbd5c76551be67a233caabff49df0a5313c14c` |
