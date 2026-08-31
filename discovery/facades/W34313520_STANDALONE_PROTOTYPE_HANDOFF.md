# `w34313520` standalone facade prototype handoff

Prepared: **2026-08-30**  
Executor: **W34313520 standalone-prototype executor (`/root/w34313515_executor`)**  
Status: **ready for independent standalone art review; not self-accepted**  
Boundary: **audit + standalone prototypes only; no exact calibration, receiver attachment, lifecycle promotion, commit, or push**

## Outcome

The existing approved observation is sufficient for the smallest truthful set of two standalone assets:

1. `W34313520-MAT-PALE` — one motif-free `homogeneous_material_tile` field study.
2. `W34313520-BAY` — one complete bounded three-tier `module_atlas` motif study.

No `architectural_pattern_tile` was built because the smallest bay period, alternates, and cadence are not established. No `unique_elevation` was built because endpoints, occluded ground, inset/wing ownership, and every non-SSE side remain unresolved. The darker lower/recess family was also excluded because its vertical and lateral bounds are unknown.

## Audited identity and exact receiver

| Item | Authoritative current value |
|---|---|
| Identity | unnamed OSM way `w34313520`; high coordinate match; no supported name/address/use/level count |
| Receiver | `building:w34313520:wall` in `x_-1__z_0` |
| Area | `2,871.747 m²` |
| Height | `11.000 m`; base/top `3.065 / 14.065 m` |
| Perimeter | serialized/visible `376.238 / 376.239 m` |
| Run topology | `34` exterior runs; `0` shared runs; `408` vertices, `204` indices, `68` triangles |
| Orientation groups | ENE `7 / 46.774 m` plus `3 / 19.019 m`; SSE `7 / 122.335 m`; WSW `6 / 65.779 m`; NNW `2 / 13.312 m` plus `9 / 109.020 m` |
| Existing runtime | wall `building_wall → plaster_grey_04`, opaque sole spray receiver; unchanged |
| Final mapping partition | `5` mapped / `27` unmapped / `2` protected; mapped `68.156 m` |

The one approved September 2025 observation, `B06-W34313520-SV01`, supports only the long SSE outer elevation family. The target remains source-key-only by name/use. No reference pixels are stored or copied.

### Exact reference-supported run chain — eligibility only, not placement

| Run | Start XZ → end XZ (m) | Length (m) | Bearing | Outward normal / azimuth | Evidence state |
|---:|---|---:|---:|---|---|
| 6 | `-182.088,126.754 → -160.000,114.948` | `25.045` | `61.9°` | `0.471,0.882 / 151.9°` | mapped SSE geometry + observation |
| 7 | `-160.000,114.948 → -131.964,99.964` | `31.789` | `61.9°` | `0.471,0.882 / 151.9°` | mapped SSE geometry + observation |
| 8 | `-131.964,99.964 → -128.000,97.846` | `4.494` | `61.9°` | `0.471,0.882 / 151.9°` | mapped SSE geometry + observation |
| 9 | `-128.000,97.846 → -124.547,96.000` | `3.915` | `61.9°` | `0.471,0.882 / 151.9°` | mapped SSE geometry + observation |
| 10 | `-124.547,96.000 → -121.978,94.627` | `2.913` | `61.9°` | `0.471,0.882 / 151.9°` | mapped SSE geometry + observation |

Runs `20..21` are protected: their similarly oriented inset chain cannot be assigned to the observed glazed/entry wing or recess. Runs `0..5`, `11..19`, and `22..33` are unmapped. The standalone registry names runs `6..10` only as the outer bound of a reference-supported facade family; it contains no run center, anchor, transform, count, or cadence.

## Material families and motif grammar

| Family / grammar | Evidence | Prototype decision |
|---|---|---|
| Pale warm gray/off-white smooth painted concrete/render-like field; matte to low-satin | direct SSE observation | one homogeneous field; reversible finish-scale inference |
| Dark gray/blue full frames and muted glazing | direct SSE observation | complete BAY-owned frames/glazing only |
| Three stacked horizontal-window groups separated/bounded by pale pier space | direct broad grammar; compatible with `11 m`, not measured levels | one complete three-tier BAY; host field provides all pale outer/inter-tier negative space |
| Darker blue-gray lower/recess family | visible but bounds unresolved | excluded |
| Entry/recess/glazed wing fragments | ownership and complete bounds unresolved | excluded; geometry issue, not a tile/module |
| Repeating bay period/alternates | not established | no architectural pattern tile; no cadence encoded |

Legal seams remain uninterrupted pale field or a complete BAY outer boundary. Cuts through glazing, frame/mullion, pale pier, tier, roof edge, corner, entry/recess, occlusion, lower transition, generated U reset, or uncertain wing junction remain forbidden.

## Exact standalone prototype contract

### `W34313520-MAT-PALE`

- Kind: `homogeneous_material_tile`.
- Implementation: existing shared opaque alias-resistant aperiodic meter-space shader with target-specific material parameters; no raster/source image.
- Channels: low-contrast procedural albedo, subtle procedural tangent-space normal, scalar roughness `0.80`, metallic `0.0`, alpha `1.0`.
- Reversible proof primary scale: `0.95 m`; uncertainty `0.35–1.80 m`; neither surveyed.
- Physical proof span: one continuous `30.0 × 11.0 m` panel.
- Repeat claim: no finite facade motif period by design. The 30 m macro view tests for visible accidental repetition, aliasing, and field phase resets; opposite-edge identity is not a material requirement.
- Facade-scale motifs: zero.
- Runtime attachment: false.

### `W34313520-BAY`

- Kind: complete reusable `module_atlas` motif, represented as deterministic project-native procedural geometry; explicitly not a seamless wall tile.
- Grammar: three unsubdivided horizontal muted-glazing groups, each with a full dark four-bar frame. Internal mullion cadence is unknown and therefore omitted.
- Reversible nominal envelope: `6.8 × 9.4 m`; width uncertainty `4.8–9.5 m`; height uncertainty `7.6–10.5 m`; no value is surveyed.
- Host-field rule: `W34313520-MAT-PALE` owns every nonopening pixel. Pale outer and inter-tier pier boundaries are continuous host-field negative space.
- Module ownership: `15` meshes / `15` surfaces / `180` triangles (`3` glazing + `12` frame); `0` field/backing, collision, navigation, or spray meshes/nodes.
- Placement/count/cadence: none; all remain unknown.

### Whole standalone scene

| Metric | Value |
|---|---:|
| Host field | `1` mesh / `1` surface / `12` triangles |
| BAY | `15` meshes / `15` surfaces / `180` triangles |
| Total | `16` meshes / `16` surfaces / `192` triangles |
| Collision / navigation / spray | `0 / 0 / 0` |
| Runtime/calibration/live placement | `false / false / 0` |

Fresh scene instances produce an identical canonical geometry signature.

## Machine-readable and implementation artifacts

- Registry: `game/resources/facades/w34313520_standalone_prototypes.json`
- Scene: `game/scenes/world/facades/batch_06/w34313520_standalone_prototype_set.tscn`
- Deterministic factory: `game/scripts/world/facades/w34313520_standalone_prototypes.gd`
- Field/frame/glass materials: `game/resources/materials/world/w34313520/`
- Focused contract: `game/tests/headless_w34313520_standalone_prototype_contract.gd`
- Native capture harness: `game/tests/w34313520_standalone_prototype_capture.gd`

The registry pins the authoritative spec, observation ledger, run mapping, generated manifest/chunk, world builder, accepted-run helper, shared prior prototype registry, and canonical inventory. Those runtime/current-state files remain byte-identical.

## Native evidence

Evidence root: `evidence/first-playable/batch-06-w34313520-standalone-prototypes-2026-08-30/`

| View | Purpose | SHA-256 |
|---|---|---|
| `01-neutral-field-close.png` | neutral material close | `bea4fc4e175ed1370fc3979d800a5016bf5ea7371e32f5a63ef115d741f5be62` |
| `02-complete-bay-neutral.png` | complete module, straight-on | `76eb27cd0917c182b361425c0740f03f6eab4ada177c591e2067affd8a1b6618` |
| `03-complete-bay-oblique.png` | depth/backing/halo check | `733a51cc52a02e24873244dc3da453e6ba4370edccb2a0a84ceee2f5e5516847` |
| `04-ordinary-gameplay-scale.png` | ordinary-distance readability | `a409e6b325c46e08c52706a4099f5d746ccd206434cd42e49366e518821ded6a` |
| `05-macro-repeat-span.png` | 30 m macro/alias/repetition control | `44318fc0ab9a6c3b6e4feff6688f0273b0abfcee0d9d68ccbe4209728e97a948` |
| `06-changed-light-oblique.png` | changed-light finish/depth | `fa32e3a35bcdd25d7e6b16fda06e3e125bd07f26792741ddf2429ecfa67c7e72` |

The six fresh `1440 × 900` images were rendered in Godot `4.7.2-stable (official)`, native macOS, Forward+/Metal on Apple M1 Pro. The manifest pins every camera/light transform, renderer field, topology total, byte count, image hash, and sampled luminance range. The evidence was visually inspected for framing, module completeness, host-field continuity, obvious backing/halo, and changed-light readability; that inspection is a validity check, not an art verdict.

## Isolation and no-live-delta result

| Protected state | Before SHA-256 | After SHA-256 |
|---|---|---|
| `generated/world/manifest.json` | `e501236d…a1fb3` | `e501236d…a1fb3` |
| `generated/world/chunks/x_-1__z_0.json` | `b935890b…d86` | `b935890b…d86` |
| `game/scripts/world/world_chunk_builder.gd` | `84aaf060…183e` | `84aaf060…183e` |
| accepted material-run helper | `4741097b…ae6f` | `4741097b…ae6f` |
| canonical inventory | `efe1c0f5…544` | `efe1c0f5…544` |
| prior shared Batch 06 prototype registry | `a599df85…132` | `a599df85…132` |

Target serialized wall topology remains `1 receiver / 34 runs / 408 vertices / 204 indices / 68 triangles / 0 live facade modules`. No `w34313520` calibration registry or live helper exists.

## Mechanical checks

All checks ran against the current tree with Godot `4.7.2-stable (official)` and exited `0`:

| Gate | Result |
|---|---|
| `headless_w34313520_standalone_prototype_contract.gd` | PASS — exact two-asset classification, two-instance determinism, `16/16/192`, BAY `15/15/180`, zero backing/collision/navigation/spray/live/generated delta |
| `headless_batch_06_prototype_contract.gd` | PASS — prior reviewed Batch 06 registry and all existing accepted fields/modules remain immutable |
| `headless_batch_06_exact_receiver_trial_contract.gd` | PASS — four accepted fields / twelve prior accepted placements; loaded `871/878/50,093/466` topology unchanged |
| `headless_accepted_material_run_trials_contract.gd` | PASS — accepted material and current live-module scope unchanged |
| `headless_w34313564_live_module_integration_contract.gd` | PASS — distinct five-placement live scope unchanged |
| `headless_w34313515_module_calibration_contract.gd` | PASS — detached four-BAY calibration unchanged |
| `headless_w34313515_live_module_integration_contract.gd` | PASS — distinct four-placement live scope unchanged |
| `headless_w291196370_module_calibration_contract.gd` | PASS — detached three-motif calibration unchanged |
| `headless_w291196370_live_module_integration_contract.gd` | PASS — distinct three-placement live scope unchanged |
| `headless_ymca_wall_tangent_projection_contract.gd` | PASS — exact YMCA field scope unchanged |
| `validate_generated_world.gd` | PASS — `735` playable + `4` context rows across `38` chunks; content `01af105e…7164` |
| `full_runtime_integration.gd` | PASS — real main scene `world_ready`, gameplay/physics/interactions/reload; `729` records, `871` meshes, `878` surfaces, `50,093` triangles, `466` collider pairs |

The macOS headless runs emit the known nonfatal system CA-certificate diagnostic. It did not alter an exit code or PASS result.

## Independent review questions

The independent reviewer should grade the following separately:

1. Does the pale field read as the observed warm off-white smooth painted/render-like family at close, ordinary, macro, and changed light, without semantic motifs or obvious artificial repetition?
2. Does `W34313520-BAY` read as one complete three-tier horizontal-window group with appropriate dark frame/glazing hierarchy and host-field pier space, while remaining clearly distinct from `W34313515-BAY`?
3. Is the reversible `6.8 × 9.4 m` exemplar proportion plausible enough to proceed to a separately authorized exact-receiver calibration study, given its explicit broad uncertainty and unknown cadence?
4. Does the module remain visually backing-free at straight and oblique angles?

Acceptance of either standalone asset must not be interpreted as exact placement, surveyed scale, facade cadence/count, completed SSE elevation, non-SSE transfer, live attachment, or whole-building acceptance.

## Remaining blocked scope

- exact ordered placement, along-run coordinate/anchor, count, cadence, and scale;
- real dimensions, level count, material color/roughness measurement;
- architectural pattern cell, alternates, or complete SSE unique elevation;
- runs `20..21`, inset/glazed/entry-wing/recess ownership, occluded ground and endpoints;
- ENE, WSW, NNW and all remaining run chains;
- darker lower family extents, doors/entries, massing/recess changes;
- whole-building resemblance and acceptance.

**Readiness: ready for independent standalone art review, with every later calibration/live/whole-building claim still blocked.**
