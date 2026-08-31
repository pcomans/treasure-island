# Isle House / 39 Bruton Street facade reference specification

Checked: **2026-08-29**  
Mode: **research and receiver handoff only**  
Target: **Isle House, 39 Bruton Street, Treasure Island**  
Parent source: **`w1249412094`**  
Actual wall receivers: **`building-composite:w1249412094:w1282547786:wall`** and **`building-composite:w1249412094:w1282547787:wall`**

## Handoff verdict

The real-world identity, two-part Godot receiver contract, and a bounded portion of the facade language are confirmed. Three official September 2025 Google Street View panoramas support a **material-plus-complete-module** treatment on the high part's observed SE address elevation, plus material continuity only on the partially observed ENE return.

The first invariant-safe implementation should combine:

1. homogeneous very-light warm tower-panel and charcoal/blue-grey scalar materials;
2. a conservative cool-light small-unit podium field, without claiming an exact masonry product or bond;
3. complete tower-window, wide/medium/narrow podium-window, curtain-wall, ground-glazing, address-entry, louver, and thin-canopy modules;
4. one `unique_elevation` layout restricted to the exact observed high SE receiver group; and
5. material-only or unchanged-placeholder treatment on the partial ENE return, all high shared-above-low runs, high SW/WSW groups, and every low-part side.

The parent still has no direct wall. Every later asset must attach separately to the high or low part, and this round authorizes target-specific modules only on `w1282547786`.

A separate whole-object blocker remains: local official-project evidence records a **seven-level podium and 22-story tower**, while the frozen/generated low part is `5` levels / `15 m`. Under the current no-story/no-massing-change invariant, a facade pass cannot repair that discrepancy or claim faithful whole-building resemblance.

## Evidence labels

- `verified_fact`: exact frozen OSM, generated-world, or locally recorded official-source evidence.
- `reference_observation`: visible in one or more identified Street View panoramas below.
- `production_inference`: a reversible mapping or implementation choice, never promoted to observed appearance truth.
- `unknown`: not established and not safe to turn into pixels, modules, or acceptance values.

## Confirmed identity and exact receiver

| Item | Exact value | Status |
|---|---|---|
| Canonical identity | Isle House | `verified_fact`; frozen parent OSM name |
| Address | 39 Bruton Street, San Francisco, CA 94130 | `verified_fact`; complete frozen parent OSM address |
| Operator / property link | Greystar; `https://www.islehousesf.com/` | `verified_fact`; frozen parent OSM tags, not browsed in this round |
| Parent source | way `1249412094`, key `w1249412094`, version `6`, timestamp `2026-01-22T21:45:19Z` | exact frozen snapshot |
| Parent tags | `building=apartments`, `building:levels=22`, `height=67`, `name=Isle House` | exact frozen snapshot |
| High part source | way `1282547786`, key `w1282547786`, version `1`, timestamp `2024-05-13T18:00:17Z`; `building:part=yes`, `building:levels=22`, `height=67` | exact frozen snapshot |
| Low part source | way `1282547787`, key `w1282547787`, version `1`, timestamp `2024-05-13T18:00:17Z`; `building:part=yes`, `building:levels=5` | exact frozen snapshot |
| Logical object | `building-composite:w1249412094` | exact generated identity |
| Parent receiver | none | intentional composite contract; the parent owns coverage only |
| High wall / roof | `building-composite:w1249412094:w1282547786:wall`; `building-composite:w1249412094:w1282547786:roof` | exact direct part receivers |
| Low wall / roof | `building-composite:w1249412094:w1282547787:wall`; `building-composite:w1249412094:w1282547787:roof` | exact direct part receivers |
| Chunk | `x_-1__z_2` | exact generated chunk |
| High runtime wall path | `WorldRoot/PlayableWorld/Buildings/x_-1__z_2__building_composite_w1249412094_w1282547786_wall/building_composite_w1249412094_w1282547786_wall` | derived exactly from current builder naming |
| Low runtime wall path | `WorldRoot/PlayableWorld/Buildings/x_-1__z_2__building_composite_w1249412094_w1282547787_wall/building_composite_w1249412094_w1282547787_wall` | derived exactly from current builder naming |
| Current appearance | both part walls use shared `building_part_wall -> plaster_grey_04` | placeholder only; not facade evidence |
| Current target-specific override | none for Isle House | verified in current builder/assets |

### Current generated mass and mesh contract

| Receiver | Height rule / flat base -> top | Source area / source perimeter | Visible wall runs | Mesh contract |
|---|---|---:|---:|---|
| High `w1282547786` | `osm_height`, `67 m`; `4.103 -> 71.103 m` | `1107.601 m²` / `134.198 m` | `13`, total `134.197 m`: `10` foundation / `85.105 m` plus `3` shared-above-low / `49.092 m` | wall `52` vertices / `26` triangles; roof `7` vertices / `5` triangles; lowest foundation vertex `3.908 m` |
| Low `w1282547787` | `osm_levels`, `15 m`; `4.103 -> 19.103 m` | `2019.661 m²` / `194.003 m` | `13` foundation runs / `144.909 m`; the missing `49.094 m` of source perimeter is the hidden high/low interface | wall `52` vertices / `26` triangles; roof `6` vertices / `4` triangles; lowest foundation vertex `3.983 m` |

Both wall objects are opaque `world_solid` objects with `receiver_kind=building_wall`, one material surface, render layer `RENDER_BUILDING_WALL`, and a `Collision` body in `spray_receiver_wall`. Both roof objects remain opaque colliders but are not spray receivers. Generated U restarts at every wall run; V is world elevation divided by ten.

### Exact visible wall groups

The labels below are outward-normal geometry groups, not semantic frontage names.

| Receiver / role | Facing | Runs | Length | Observation |
|---|---|---:|---:|---|
| high / exterior foundation | `62.9°` ENE | 2 | `14.442 m` | partially visible in an oblique; no complete elevation (`production_inference`, medium mapping confidence) |
| high / exterior foundation | `131.4°` SE | 3 | `42.278 m` | observed address elevation (`production_inference`, high mapping confidence) |
| high / exterior foundation | `221.6°` SW | 2 | `11.363 m` | unobserved |
| high / exterior foundation | `242.9°` WSW | 3 | `17.022 m` | unobserved |
| high / shared above low | `18.5°` NNE | 1 | `12.390 m` | unobserved; begins at `y=19.103`, never a ground facade |
| high / shared above low | `313.3°` NW | 1 | `33.229 m` | unobserved; begins at `y=19.103`, never a ground facade |
| high / shared above low | `332.1°` NNW | 1 | `3.473 m` | unobserved; begins at `y=19.103`, never a ground facade |
| low / exterior foundation | `62.9°` ENE | 5 | `49.797 m` | unobserved |
| low / exterior foundation | `242.9°` WSW | 5 | `51.698 m` | unobserved |
| low / exterior foundation | `332.3°` NNW | 3 | `43.414 m` | unobserved |

The three exact high shared-wall XZ runs are:

1. `(-95.775, 526.591) -> (-107.522, 522.651)`, `12.390 m`;
2. `(-107.522, 522.651) -> (-130.305, 546.840)`, `33.229 m`; and
3. `(-130.305, 546.840) -> (-133.374, 548.466)`, `3.473 m`.

The observed high-SE address elevation is serialized wall runs `5..7`, continuously from `(-117.142, 571.175)` through `(-96.000, 547.172)` and `(-93.206, 544.000)` to `(-89.198, 539.449)`, totaling `42.278 m`. A unique layout uses this continuous world-space chain; it must not select other runs merely because their normals are similar.

Any future side-local layout must distinguish those upper-only runs from the ten high foundation runs and thirteen low foundation runs. It must not create a duplicate low wall along the intentionally omitted `49.094 m` high/low interface.

## Source and provenance ledger

Official Google Street View was viewed transiently by the dedicated observation executor. No image artifact, screenshot, crop, download, copied pixel data, redistribution, upload, or repository asset was retained or committed.

| ID | Source | Access / capture | Supports | Does not support / reuse status |
|---|---|---|---|---|
| `L01` | `data/osm/treasure-island-2026-08-27.osm`, parent and two part records | Checked 2026-08-29 | exact name, address, levels, height, part membership and timestamps | no facade appearance; project-held ODbL source |
| `L02` | `discovery/FACADE_RECEIVER_INVENTORY.json` and `.md`; `generated/world/logical-objects.json`; `generated/world/chunks/x_-1__z_2.json` | Checked 2026-08-29 | exact composite, paths, visible/shared runs, mesh counts, elevations, UV/material limitations | no real facade appearance |
| `L03` | `discovery/ISLAND_EVIDENCE.md`, locally recorded source `S11` | Checked 2026-08-29; underlying official statement dated 2025-11-10 | seven-level podium, 22-story tower, December 2024 completion at coarse massing level | not a facade reference or permission to change generated massing; source not re-browsed |
| `IH-SV01` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8191991,-122.3715368&heading=230&pitch=5&fov=75`; panorama `CqLfgqkDJF4LkB8NhgB1NQ` | Accessed 2026-08-29; UI displayed **Image capture: Sep 2025**; east-northeast Bruton approach looking southwest `230°` | tower, podium/high-foundation relationship, Bruton context | official Google Street View observation only; no storage/reuse |
| `IH-SV02` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8189914,-122.371764&heading=285&pitch=12&fov=70`; panorama `EDHxU1WC8Nn_wsRU82dC6Q` | Accessed 2026-08-29; UI displayed **Image capture: Sep 2025**; northeast view looking WNW `285°` | tower-panel cadence, podium corner/return, adjacent Bruton frontage | official Google Street View observation only; no storage/reuse |
| `IH-SV03` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8187111,-122.3720646&heading=320&pitch=8&fov=75`; panorama `1UhtZMNvlUs4cxN0JsOUbQ` | Accessed 2026-08-29; UI displayed **Image capture: Sep 2025**; southeast view looking NW `320°`, also inspected at `260°` and `300°` | close address elevation, entrance, ground glazing, podium openings, tower transition | official Google Street View observation only; no storage/reuse |
| `SV-HANDOFF` | `discovery/facades/NEXT_COHORT_STREETVIEW_OBSERVATIONS.md` | Checked 2026-08-29 | exact observation/inference/unknown boundary and must-not-invent rules | project evidence ledger; contains no imagery |

## Observed and unobserved facade coverage

### Observed

`reference_observation` from `IH-SV01..03`:

- The close Bruton elevation and tower/podium transition are visible from southeast and northeast obliques.
- The tower uses very-light warm-white/light-grey smooth panels, narrow muted taupe/grey accent panels, and dark charcoal vertical glazing strips.
- The lower high-part/podium face uses a slightly cooler very-light grey small-unit masonry or brick-like field with deep charcoal window surrounds.
- Tower openings form narrow floor-by-floor vertical stacks between broad light panel fields.
- Podium openings occur as distinct wide, medium and narrow tall-window families aligned in vertical stacks; they do not form one universal bay.
- A central vertical curtain-wall/recess strip interrupts the small-unit field and continues into the tower transition.
- Ground bays are tall glazed fields between full-height medium-light-grey supports. The recessed glazed address entrance includes a complete door/transom assembly and visible `39` identifier.
- A dark horizontal louver/vent band occurs above portions of the glazing. A darker small-unit return and separate boarded/commercial bay with a thin dark canopy/sign band occur toward one end.
- The visible surfaces read clean/new with low weathering. Heavy stains, chipped masonry and repeated focal grime are not supported.

Side mapping is distinct from observation:

- `production_inference`, high confidence: the close address elevation maps to the high receiver's `131.4°` SE exterior-foundation group.
- `production_inference`, medium confidence: the northern oblique includes part of the high receiver's `62.9°` ENE return, but not a complete rectified elevation.

### Unobserved

- All three high `shared above low` runs.
- High SW and WSW groups.
- Every complete low-part side schedule and any cross-part facade phase.
- Rear/courtyard service conditions, low-part doors/windows, balconies, garage doors, exact corner returns, and exact tower accent order on unobserved sides.
- Exact material products, coating codes, small-unit construction/bond, roughness, panel/joint layout, bay dimensions, and as-built counts.

The safe fallback is material-only on the partial ENE return when continuity is visually supportable and the shared placeholder everywhere else. No unique module is authorized outside the observed high SE layout.

## Receiver regions and motif grammar

| Region | Exact scope | Observed grammar and status |
|---|---|---|
| `H-SE-TOWER` | tower portion of the high receiver's `131.4°` SE group | broad very-light panel fields alternating with narrow, floor-stacked dark-glazing columns; narrow muted taupe/grey accents are subordinate, not a new universal period |
| `H-SE-PODIUM` | lower portion of the same exact SE group | cool very-light small-unit field; separate wide, medium and narrow tall-window stacks; a central vertical curtain-wall/recess strip interrupts the field |
| `H-SE-GROUND` | ground band of the same exact SE group | tall glazing between full-height supports; complete `39` door/transom entrance; localized dark louver; darker small-unit/commercial return; thin canopy/sign band |
| `H-ENE-PARTIAL` | visually supported portion of the high `62.9°` ENE group | material continuity and corner-return context only; no complete schedule |
| `H-ABOVE-LOW` | three shared runs, `y=19.103..71.103` only | unobserved; must never receive a ground-floor module |
| `H-SW-WSW` | high SW/WSW exterior groups | unobserved |
| `L-EXTERIOR` | all 13 low-part exterior runs | no complete side schedule observed; no authored opening layout |
| `PART-JUNCTION` | omitted `49.094 m` low perimeter and tower/low roof transition | geometry-owned; no duplicate wall/module may be created |
| `ROOFS` | high and low roofs at `71.103` and `19.103` | geometry/silhouette-owned; excluded |

Observed complete motif families are `IH-TW` (narrow stacked tower window), `IH-PW-W`, `IH-PW-M`, `IH-PW-N` (wide/medium/narrow podium windows), `IH-CW` (vertical curtain-wall/recess strip), `IH-GG` (ground glazing/support bay), `IH-ENTRY39` (complete door/transom/address assembly), `IH-LVR` (localized louver band), and `IH-CANOPY` (thin dark commercial canopy/sign band). They form a side-specific composition, not one periodic texture cell. Exact counts, metre offsets, small-unit bond, louver pitch and tower accent sequence remain unknown; author the observed SE side as an explicit reference-relative layout and keep each atlas token whole.

## Material and physical-scale brief

These are deliberately broad linear-value and roughness starting bands, derived from the visible relationships rather than sampled pixels. Final values must be tuned under neutral game lighting; do not bake panorama illumination or shadows.

| Region | Physically plausible starting description | Confidence |
|---|---|---|
| tower primary | very-light warm-white/light-grey smooth coated panel; linear value about `0.72..0.88`, metallic `0`, roughness `0.55..0.78`; very low micro-normal | medium |
| tower accent | narrow muted taupe/grey coated panel, linear value `0.38..0.58`, metallic `0`, roughness `0.55..0.78` | medium |
| podium field | cooler very-light grey small-unit masonry/brick-like field, value `0.58..0.78`, metallic `0`, roughness `0.72..0.90`; low-amplitude unit/joint relief only after a real bond is established | medium for family/value; low for unit geometry |
| surrounds/supports | medium-light neutral grey, value `0.38..0.60`, metallic `0`, roughness `0.58..0.78` | medium |
| glazing/louver/canopy | dark charcoal to blue-grey, value `0.06..0.20`; glazing roughness `0.12..0.30`, opaque metal roughness `0.40..0.65`; no emissive windows | medium |
| weathering | clean/new, low-amplitude diffuse variation and restrained base grime only; no focal damage or repeated stain | medium |

Verified physical values usable for receiver calibration are:

- parent/high source height `67 m`, parent/high `22` levels;
- low generated height `15 m`, low source `5` levels;
- high and low flat base `4.103 m`; tops `71.103 m` and `19.103 m`;
- locally recorded real composition: seven-level podium plus 22-story tower;
- one Godot unit equals one metre.

Physical module dimensions were not measured. Low-confidence metre estimates for prototype bounding boxes are: tower stack bay `1.2..2.4 m` wide by one generated-story band; podium windows `1.0..3.2 m` wide by `1.8..3.2 m` tall depending on family; ground glazing/support bay `2.0..4.5 m` wide by `3.0..5.0 m` tall; complete entrance `2.0..4.0 m` wide by `3.0..5.0 m` tall; louver/canopy band `0.25..0.8 m` tall. These ranges require reference-relative calibration against the exact `42.278 m` SE group and may not be used to infer missing bay counts. Do not turn `67 / 22` or `15 / 5` into an authored cadence.

## Output classification and repeat/seam blueprint

| Output kind | Status | Smallest repeat / non-repeat rationale | Allowed next step |
|---|---|---|---|
| `homogeneous_material_tile` | **ready, bounded** | uniform tower panel, accent, surround and dark opaque fields need no architectural period; podium unit field may be homogeneous only until its bond is proven | create non-focal scalar/PBR fields at metre scale; no baked window, joint grid or stain |
| `architectural_pattern_tile` | blocked | no complete small-unit bond, louver pitch, tower panel-joint period, or four-corner product is proven | defer; use modules and homogeneous fields |
| `module_atlas` | **ready, high-SE only** | `IH-TW`, `IH-PW-W/M/N`, `IH-CW`, `IH-GG`, `IH-ENTRY39`, `IH-LVR`, `IH-CANOPY` are complete families; none may be cropped into a periodic tile | author complete shallow render-only motifs; reference-relative sizing; no low-part variants |
| `unique_elevation` | **ready, high-SE only** | address entrance, curtain-wall strip, mixed opening families and commercial end make the elevation non-periodic | explicit layout over the three exact `131.4°` SE runs; partial ENE is material-only; all other sides unchanged |

### Legal seams after evidence exists

- A homogeneous tile seam entirely within one verified uniform field, with phase-matched relief and no focal mark.
- A verified architectural-unit boundary whose left+right, top+bottom and four-corner products reproduce unchanged complete tokens.
- An explicit end of a complete module inside ordinary material field.
- The real high/low volume boundary as a layout boundary only; it is not permission to create a new wall, slab, setback, or silhouette.

### Forbidden seams

- Any current generated wall-run U reset used as a facade cadence reset.
- Any seam through an opening, door, balcony, panel termination, rib/fin, band, sign, canopy, garage, vent, or other complete motif.
- Any layout that treats the parent `w1249412094` as a direct wall receiver.
- Any duplicate low wall along the hidden `49.094 m` interface.
- Any ground door/window/module placed on `H-ABOVE-LOW` below its real bottom `y=19.103` or projected down to terrain.
- Any motif carried between part receivers without explicit side/world-space phase and overlap proof.

## Godot bill of materials

| ID | Proposed stable path | Godot role | Evidence gate |
|---|---|---|---|
| `MAT-HIGH-LIGHT` | `res://game/resources/materials/world/isle_house/isle_house_tower_light.tres` | light coated-panel `StandardMaterial3D` | **ready** within broad PBR bands |
| `MAT-HIGH-ACCENT` | `res://game/resources/materials/world/isle_house/isle_house_tower_accent.tres` | muted accent-panel material | **ready**; no invented accent schedule |
| `MAT-PODIUM` | `res://game/resources/materials/world/isle_house/isle_house_podium_light.tres` | conservative cool-light podium field | **ready as homogeneous field**; bond/pattern blocked |
| `MAT-DARK` | `res://game/resources/materials/world/isle_house/isle_house_dark_charcoal.tres` | non-emissive window/louver/canopy family | **ready**; glass and opaque variants remain separate |
| `MOD-HIGH` | `res://game/scenes/world/facades/isle_house/isle_house_high_modules.tscn` | complete `IH-*` shallow modules | **ready for observed high SE families only** |
| `LAYOUT-HIGH-SE` | `res://game/resources/facades/isle_house_39_bruton_high_se_layout.json` | explicit three-run address-elevation schedule | **ready for reference-relative prototype**, with metre offsets reviewed before integration |
| `ATTACH-HIGH` | `res://game/scenes/world/facades/isle_house/isle_house_high_facade.tscn` | noncolliding visual child of exact high wall | ready only after visual and receiver gates pass |
| `MOD/ATTACH-LOW` | reserved; no path allocated | low-part modules/attachment | **blocked** until a complete low-part side is observed |

Any later shallow modules must be render-only, use complete motifs, remain within the exact receiver sides and tops, preserve spray projection onto the underlying wall, and use continuous side/world coordinates rather than generated UV U. Keep opaque relief shallow (`0..0.12 m`, `production_inference`) and inside the wall's silhouette projection; recess illusion belongs in texture/normal response, not true holes or deep cavities.

## Geometry-versus-texture boundary

### Potentially owned by a later facade pass

- Evidence-backed color, value, roughness, low-amplitude normal response, and subordinate variation.
- Complete shallow render-only facade modules whose dimensions and placement are established by reference.
- Separate run-role-aware layouts for the two exact part receivers.

### Explicitly excluded

- Changing the five-level generated low part into the locally recorded seven-level podium.
- Tower/podium height, story count, footprint, volume split, roofline, silhouette, setbacks, balconies with meaningful depth, deep recesses, true glazing holes, interiors, or private access.
- Adding the parent wall, restoring the intentionally omitted low interface, or changing the three high shared-above-low walls.
- Collision, spray eligibility, collision layers/groups/metadata, foundation terrain extension, roof receiver status, navigation, terrain, or generated OSM/chunk/coverage/logical-object contracts.

### Representative before -> after preserving invariants

```text
before: building-composite:w1249412094 has no parent mesh; its exact high and
        low part walls are separate opaque spray receivers using shared
        plaster_grey_04. The high wall includes 10 foundation runs plus 3
        runs exposed only above the low roof at y=19.103; the low wall omits
        the hidden 49.094 m interface.

after:  those exact two walls, roofs, heights, runs, collision, source IDs and
        generated bytes remain unchanged. A noncolliding visual child of the
        high wall adds observed SE material fields and complete IH-* modules
        over only the three 131.4-degree SE runs; the partial ENE return is
        material-only and every low/shared/unobserved run remains unchanged,
        preserving the shared/hidden interface.
```

The after state must still disclose that whole-building resemblance is limited by the current five-level low part versus locally recorded seven-level podium.

## Executable acceptance checklist

### Research prerequisite gates (satisfied by this handoff)

- [x] Street View was observed without login, new account, CAPTCHA, credentials, upload, download, or alternate service.
- [x] Every used panorama has exact URL, panorama ID, access/capture dates, direction and coverage.
- [x] Visual claims are observations; side mapping is inference with confidence.
- [x] Coherent material regions bound plausible color/value/finish/roughness.
- [x] Proposed modules are complete on the observed high SE address elevation.
- [x] Unobserved sides are explicitly excluded from unique modules.

### Later implementer gates

- [ ] Target matching requires part key `w1282547786` or `w1282547787` and its exact wall object; it never matches parent `w1249412094` as a wall.
- [ ] The unique layout matches only high wall runs `5..7`, the `131.4°` SE chain totaling `42.278 m`; it does not extend by normal-angle coincidence.
- [ ] High and low paths, heights, bases/tops, wall/roof triangle counts, run counts, and total visible lengths remain exact.
- [ ] The high layout distinguishes `85.105 m` foundation walls from `49.092 m` shared-above-low walls.
- [ ] No ground module is created on a shared-above-low run and no low wall is created along the hidden `49.094 m` interface.
- [ ] Generated U resets do not reset a facade sequence.
- [ ] No visual child adds physics, collision, navigation, occluder ownership, or spray-receiver membership.
- [ ] A ray through module-covered space still resolves to the underlying exact part wall and its spray decal remains visible.
- [ ] Material proofs predict and preserve left+right, top+bottom and four-corner products; every atlas motif is complete.
- [ ] No story, podium, tower, silhouette, roof, footprint, foundation, terrain, collision, spray, generated data, or source-ID change occurs.
- [ ] Whole-object review remains limited by the five-level-versus-seven-level podium mismatch.

### Independent reviewer gates

- [ ] Confirm no appearance claim came from the name, OSM height/levels, shared placeholder, or model recollection.
- [ ] Confirm the two part receivers and parent-without-direct-mesh contract are represented exactly.
- [ ] Reject any motif outside the observed `IH-*` inventory or any invented low-part/rear variant.
- [ ] Reject any motif created, resized, duplicated, or deleted at a seam or part boundary even if numeric pixel-edge scores pass.
- [ ] Keep material, module, exact-receiver, overlap, and whole-building verdicts separate.
- [ ] Keep implementation verdicts separate: observed high SE ready, partial ENE material-only, every other side blocked.

## Explicit unknowns and blockers

| Unknown / blocker | Impact | Safe fallback | Stop condition |
|---|---|---|---|
| Exact product/coating code, masonry bond and panel joints | no truthful architectural pattern tile | use broad homogeneous fields | stop before authoring a masonry/panel-joint repeat |
| Exact metre offsets, bay counts and louver pitch | no as-built dimensional claim | calibrate reference-relative layout across exact `42.278 m` group and review proportions | stop if surveyed/as-built precision is required |
| Complete ENE, high SW/WSW, shared-above-low and low-part sides | no unique layout outside high SE | material-only partial ENE; leave all other runs unchanged | stop if modules are requested outside high SE |
| Cross-part facade phase | no safe motif continuation | end high layout in ordinary field before junction; author no low layout | stop if a motif must cross the part boundary |
| Real seven-level podium versus generated five-level low part | faithful whole-object claim impossible under invariant | preserve exact generated mass | always stop before story/massing change |

## Normalized research handoff

```yaml
schema_version: codex.building-texture-research/1
job:
  job_id: isle_house_39_bruton_facade_reference_spec
  checked_date: 2026-08-29
  intended_use: bounded_two_receiver_facade_implementation_handoff
  target_asset_kind: unique_elevation

target:
  canonical_name: Isle House / 39 Bruton Street
  local_object_ids: [w1249412094, w1282547786, w1282547787, building-composite:w1249412094]
  identity_confidence: high
  receiver_path: null

sources:
  - id: L01
    authority: project
    url_or_local_path: discovery/FACADE_RECEIVER_INVENTORY.json
    checked_date: 2026-08-29
    page_or_section: facade-receiver:w1249412094_and_part_records
    supports: [identity, address, composite, exact_receivers, wall_roles, scale]
    does_not_support: [facade_appearance, cadence, materials]
    image_reuse_permission: not_needed
    stored_in_repo: false
  - id: IH-SV01
    authority: secondary
    url_or_local_path: https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8191991,-122.3715368&heading=230&pitch=5&fov=75
    checked_date: 2026-08-29
    page_or_section: panorama_CqLfgqkDJF4LkB8NhgB1NQ_capture_Sep_2025
    supports: [tower, podium, Bruton_context]
    does_not_support: [exact_dimensions, rear_sides, pixel_reuse]
    image_reuse_permission: observation_only
    stored_in_repo: false
  - id: IH-SV02
    authority: secondary
    url_or_local_path: https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8189914,-122.371764&heading=285&pitch=12&fov=70
    checked_date: 2026-08-29
    page_or_section: panorama_EDHxU1WC8Nn_wsRU82dC6Q_capture_Sep_2025
    supports: [tower_panel_cadence, podium_corner]
    does_not_support: [complete_ENE_schedule, pixel_reuse]
    image_reuse_permission: observation_only
    stored_in_repo: false
  - id: IH-SV03
    authority: secondary
    url_or_local_path: https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8187111,-122.3720646&heading=320&pitch=8&fov=75
    checked_date: 2026-08-29
    page_or_section: panorama_1UhtZMNvlUs4cxN0JsOUbQ_capture_Sep_2025
    supports: [high_SE_address_elevation, entrance_39, podium_windows, ground_glazing, transition]
    does_not_support: [low_receiver_complete_side, exact_dimensions, pixel_reuse]
    image_reuse_permission: observation_only
    stored_in_repo: false

reference_roles:
  identity_context: [L01, IH-SV03]
  massing: [L01]
  pattern_region: [IH-SV01, IH-SV02, IH-SV03]
  cadence_and_seams: [IH-SV02, IH-SV03]
  material_surface: [IH-SV01, IH-SV02, IH-SV03]
  scale: [L01, IH-SV03]
  rejection_example: []

pattern_regions:
  - region_id: H_SE_TOWER
    local_scope: high_receiver_SE_group_tower_band
    periodicity: side_specific_stacked_modules
    must_not_share_tile_with: [H_SE_PODIUM, H_SE_GROUND]
  - region_id: H_SE_PODIUM
    local_scope: high_receiver_SE_group_podium_band
    periodicity: mixed_module_families_no_universal_cell
    must_not_share_tile_with: [H_SE_TOWER, H_SE_GROUND]
  - region_id: H_SE_GROUND
    local_scope: high_receiver_SE_group_ground_band
    periodicity: unique_address_sequence
    must_not_share_tile_with: [all_unobserved_sides]

motif_inventory: [IH-TW, IH-PW-W, IH-PW-M, IH-PW-N, IH-CW, IH-GG, IH-ENTRY39, IH-LVR, IH-CANOPY]
motif_sequences:
  - {region_id: H_SE_TOWER, horizontal: reference_relative_panel_and_window_stack_sequence, vertical: floor_stacked_openings}
  - {region_id: H_SE_PODIUM, horizontal: explicit_mixed_window_and_curtainwall_sequence, vertical: aligned_opening_stacks}
  - {region_id: H_SE_GROUND, horizontal: explicit_glazing_entry_louver_commercial_sequence, vertical: one_ground_band}

repeat_blueprint:
  region_id: H_SE_ALL
  smallest_cell_status: no_universal_repeat_use_complete_modules_and_unique_layout
  period_tokens_horizontal: null
  period_tokens_vertical: null
  period_m: {x: null, y: null}
  cell_contents_full_motifs: [IH-TW, IH-PW-W, IH-PW-M, IH-PW-N, IH-CW, IH-GG, IH-ENTRY39, IH-LVR, IH-CANOPY]
  edge_fragments: {left: [], right: [], top: [], bottom: []}
  edge_compositions_expected: {left_plus_right: [], top_plus_bottom: [], corners: []}
  legal_seam_zones: [verified_uniform_field, explicit_complete_module_boundary]
  forbidden_seam_zones: [all_complete_motifs, generated_segment_U_resets, hidden_low_interface, part_boundary, unobserved_sides]
  fallback_if_not_proven: unique_elevation

material_brief:
  surface_family: coated_panel_plus_small_unit_podium
  base_color: very_light_warm_tower_and_cool_light_podium_with_charcoal_openings
  finish: matte_to_low_satin
  relief_direction_and_frequency: low_amplitude_panel_and_unit_response_exact_joint_period_unknown
  roughness: tower_0.55_0.78_podium_0.72_0.90
  variation_and_weathering: clean_new_low_amplitude_only
  maps_requested: [albedo, roughness, low_amplitude_normal]
  maps_forbidden: [height_displacement, baked_lighting, focal_repeated_stains, emissive_windows]
  tile_scale_status: bounded_by_receiver_and_reference_relative_modules
  tile_scale_m: {x: null, y: null}

excluded_architectural_features:
  - {feature: tower_podium_story_massing_and_silhouette, owner: geometry, reason: invariant}
  - {feature: high_low_shared_and_hidden_interfaces, owner: geometry, reason: generated_composite_contract}
  - {feature: all_unobserved_facade_motifs, owner: facade_module, reason: missing_reference}

uncertainty:
  - unknown: low_part_and_unobserved_side_schedules
    impact: no_modules_outside_high_SE
    safe_fallback: retain_shared_placeholder_or_partial_ENE_material_only
    stop_if_required: true
  - unknown: exact_products_dimensions_counts_bond_and_joint_period
    impact: no_as_built_claim_or_architectural_pattern_tile
    safe_fallback: broad_PBR_fields_and_reference_relative_complete_modules
    stop_if_required: false

hard_mismatch_gates:
  - scope: identity
    reject_if: parent_is_treated_as_direct_wall_or_either_part_key_is_lost
    proof_required: runtime_metadata_and_composite_coverage_audit
  - scope: evidence
    reject_if: any_visual_claim_lacks_identified_observation
    proof_required: panorama_ledger_and_side_mapping
  - scope: geometry
    reject_if: any_story_massing_silhouette_overlap_foundation_collision_spray_or_generated_contract_changes
    proof_required: exact_receiver_and_generated_diff_audit
  - scope: repeat
    reject_if: any_unproven_repeat_or_edge_composition_is_authored
    proof_required: repeat_blueprint_and_absolute_review

research_verdict:
  ready_for_generation: true
  recommended_output_kind: module_atlas_plus_unique_elevation
  ready_scope: high_receiver_SE_group_only_with_partial_ENE_material_only
  blockers:
    - no_unique_modules_on_low_shared_SW_WSW_or_partial_ENE_sides
    - no_architectural_pattern_tile_without_complete_period_and_edge_products
    - whole_building_resemblance_limited_by_five_level_generated_low_part_versus_recorded_seven_level_podium
```

## Final research status

- Identity and exact receiver contract ready: **yes**.
- Ready for homogeneous material generation: **yes, within the observed PBR bands**.
- Ready for architectural pattern generation: **no**.
- Ready for module authoring: **yes, complete `IH-*` families for the high SE side only**.
- Ready for a unique elevation: **yes, the exact high `131.4°` SE group only**.
- Ready for runtime integration: **only after the later implementation and independent-review gates pass**.
- Remaining blockers: **all low/shared/high-SW/high-WSW schedules, complete ENE layout, exact products/dimensions, and whole-building resemblance under the five-versus-seven-level podium mismatch**.
