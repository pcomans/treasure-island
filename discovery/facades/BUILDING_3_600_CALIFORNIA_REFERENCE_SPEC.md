# Building 3 / 600 California Avenue facade reference specification

Checked: **2026-08-29**  
Mode: **research and implementation handoff only**  
Target source: **`w34313540`**  
Current wall receiver: **`building:w34313540:wall`**

## Handoff verdict

The target is confirmed as the historic **Building 3** hangar at **600 California Avenue, CA**, built for the 1939 Golden Gate International Exposition and formerly named **Palace of Fine Arts**. November 2025 and July 2015 official Street View views establish a stable, bounded treatment for the current ENE end: a very-light warm off-white painted-mineral field, one complete dark-teal/blue hangar door with pale surround, and one shallow horizontal band. The homogeneous material and complete `B3-HANGAR-DOOR` / `B3-BAND` modules are implementation-ready for a bounded ENE-end prototype.

The exact main contiguous ENE receiver group is nine runs / `90.320 m`, but the visual layout has not been metrically surveyed; placement must be calibrated reference-relatively and may not extend to discontiguous minor ENE-normal returns. Both long sides, the opposite WSW end, minor returns, service openings and all cross-side symmetry remain unknown. The curved crown/barrel roof and taller shoulder/pylon-like end elements are silhouette/geometry, so the current flat `20 m` extrusion cannot achieve faithful whole-object profile without violating invariants.

## Evidence labels

- `verified_fact`: exact frozen OSM, generated-world, or locally recorded official-source evidence.
- `reference_observation`: visible in an identified Street View panorama and imported only from the dedicated observation handoff.
- `production_inference`: a reversible bounded art/implementation choice.
- `unknown`: not established and not safe to use as a prompt or acceptance value.

## Confirmed identity and exact receiver

| Item | Exact value | Status |
|---|---|---|
| Canonical identity | Building 3 | `verified_fact`; exact frozen name |
| Address | 600 California Avenue, CA | `verified_fact`; frozen OSM has street, number and state but no city/postcode, so no fuller postal form is asserted |
| Building type | hangar; `aeroway=hangar` | exact frozen tags |
| Historic identity | `old_name:1938-1940=Palace of Fine Arts`; one of three intact exposition remnants | exact frozen tags; not appearance evidence |
| Architect / date | William P. Day and George Kelham; `start_date=1938` | exact frozen tags |
| Heritage | NRHP `08000081`, criteria `A;C`, inscription `2008-02-26` | exact frozen tags |
| Frozen color | `building:colour=white` | coarse verified label only |
| Source | way `34313540`, key `w34313540`, version `13`, timestamp `2026-08-21T23:22:40Z` | exact frozen snapshot |
| Frozen dimensions | `height=20`, `building:levels=3` | exact source tags |
| Logical object | `building:w34313540` | exact generated identity |
| Wall / roof | `building:w34313540:wall`; `building:w34313540:roof` | exact generated objects |
| Chunk | `x_1__z_1` | exact generated chunk |
| Runtime wall path | `WorldRoot/PlayableWorld/Buildings/x_1__z_1__building_w34313540_wall/building_w34313540_wall` | derived exactly from current builder naming |
| Current appearance | `building_wall -> plaster_grey_04` | shared placeholder only; no target-specific Building 3 override |

### Current generated mass and mesh contract

- Height rule `osm_height`, `20 m`; flat base `3.478 m`; top `23.478 m`; lowest terrain foundation vertex `2.806 m`.
- Source/serialized area `13394.520 m²`; serialized perimeter `488.313 m`; generated visible wall length `488.311 m`.
- Wall `59` exterior foundation runs, `236` vertices, `118` triangles, one material surface.
- Roof `29` vertices, `27` triangles; opaque collider, not a spray receiver.
- Wall is opaque `world_solid`, `receiver_kind=building_wall`, `Collision` in `spray_receiver_wall`, render layer `RENDER_BUILDING_WALL`.
- UV1 U restarts on all `59` runs. V is world elevation divided by ten. Use exact side/world coordinates for facade scheduling.

### Dominant receiver sides and minor returns

These are outward-normal geometry groups, not semantic frontage names.

| Geometry group | Facing / dominant azimuth | Runs / length | Observation mapping |
|---|---|---:|---|
| `SIDE-ENE` | ENE, dominant `62.4°` | total bucket `109.103 m`; main group `9 / 90.320 m` plus minor returns | current broad end observed; mapping to main group high confidence; minor returns not layout-ready |
| `SIDE-SSE` | SSE, dominant `152.0°` | total `136.307 m`; main group `8 / 106.451 m` plus end/return runs | unobserved; no module/symmetry claim |
| `SIDE-WSW` | WSW, dominant `242.2°` | total `104.927 m`; main group `10 / 92.622 m` plus minor returns | unobserved opposite end; do not mirror ENE |
| `SIDE-NNW` | NNW, dominant `331.2-332.2°` | total `127.755 m`; long groups `22.452`, `49.134`, and `44.002 m` plus minor returns | unobserved; no module/symmetry claim |
| `MINOR-N/W` | N/NNE and W/other short returns | N bucket `6.271 m`; W bucket `3.947 m` | do not assign a major-side cadence by nearest-normal guess |

A unique layout must carry exact run endpoints and continuous side-local coordinates. The `59` generated subdivisions, including small chamfers and end returns, are not legal automatic bay boundaries.

The exact observed ENE-main chain is serialized wall runs `27..35`, continuously from `(528.784, 488.910)` through the intermediate run endpoints to `(486.955, 408.860)`, with outward normal approximately `(0.886, -0.463)` and total length `90.320 m`. The layout origin is the first endpoint and increases along that chain. It must not absorb discontiguous same-normal returns elsewhere in the `59`-run wall.

## Source and provenance ledger

No external image may be downloaded, copied, retained, redistributed, uploaded, or committed.

| ID | Source | Access / capture | Supports | Does not support / reuse status |
|---|---|---|---|---|
| `L01` | `data/osm/treasure-island-2026-08-27.osm`, way `w34313540` | Checked 2026-08-29 | exact name, address components, hangar, white color tag, levels/height, architects, date and heritage tags | no material family, finish, detailed appearance, motif cadence or dimensions |
| `L02` | `discovery/FACADE_RECEIVER_INVENTORY.json` and `.md`; `generated/world/logical-objects.json`; `generated/world/chunks/x_1__z_1.json` | Checked 2026-08-29 | exact receiver, massing, mesh, orientation, material/UV/runtime limits | no real facade appearance |
| `L03` | `discovery/ISLAND_EVIDENCE.md` | Checked 2026-08-29 | Building 3's role in the Building 1 / Hangars 2 and 3 arrival ensemble | recognition context only; no facade specification |
| `B3-SV01` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8203,-122.36455&heading=230&pitch=8&fov=75`; panorama `KpAYOuZlkIsuNO4uO3rV4A` | Accessed 2026-08-29; UI displayed **Image capture: Nov 2025**; northeast/east looking SW `230°` | current ENE end, material, central hangar door and band | observation only; no storage/reuse |
| `B3-SV02` | `https://www.google.com/maps/@37.8201886,-122.3639461,3a,75y,230h,98t/data=!3m8!1e1!3m6!1sHRVPEhMO_dUOx-FFubWUXA!2e0!5s20150701T000000!6shttps:%2F%2Fstreetviewpixels-pa.googleapis.com%2Fv1%2Fthumbnail%3Fcb_client%3Dmaps_sv.tactile%26w%3D900%26h%3D600%26pitch%3D-8%26panoid%3DHRVPEhMO_dUOx-FFubWUXA%26yaw%3D230!7i13312!8i6656?entry=ttu`; panorama `HRVPEhMO_dUOx-FFubWUXA` | Accessed 2026-08-29; UI displayed **Image capture: Jul 2015**; northeast/east looking SW `230°`, also west `270°` | historical corroboration of same ENE material/end grammar | observation only; no storage/reuse |
| `SV-HANDOFF` | `discovery/facades/NEXT_COHORT_STREETVIEW_OBSERVATIONS.md` | Checked 2026-08-29 | observation/inference/unknown boundary | no imagery |

## Observed and unobserved facade coverage

### Observed

- Dominant very-light warm off-white/cream matte painted-mineral or smooth stucco/concrete-like field; the coarse OSM `white` tag corroborates only the broad color family.
- One complete large rectangular central hangar door, dark teal/blue, with a pale surround.
- A long shallow horizontal band below the curved crown.
- Two narrow taller shoulder/pylon-like vertical end elements flank the crown; these belong to silhouette/geometry and are not shallow facade modules.
- Low-to-medium weathering consists of diffuse variation and restrained base grime. No panel, rib, masonry or opening repeat is visible.
- Appearance and end grammar are consistent between July 2015 and November 2025 observations.

### Unobserved

- Both long sides, the opposite WSW end, and all minor return schedules.
- Complete flank service block, small ground openings/personnel doors, vents, signs and exact corner returns.
- Exact door/band metre offsets, door subdivision, construction product, coating code and relief depth.
- No official coverage located for other sides in the approved observation session; do not mirror the ENE composition.

## Material regions, motif grammar, and cadence

| Region | Scope | Grammar / status |
|---|---|---|
| `ENE-MAIN` | exact contiguous `62.4°` main group, `9 / 90.320 m` | explicit non-periodic end: `B3-HANGAR-DOOR` once, `B3-BAND` across ordinary field; reference-relative placement |
| `ENE-MINOR` | discontiguous ENE-normal returns outside main group | not layout-ready; homogeneous field only if continuity is proven |
| `SIDE-SSE/WSW/NNW` | remaining major sides | unobserved; no modules or mirroring |
| `FOUNDATION-EXT` | terrain foundation below flat base | geometry only; no openings/modules |
| `ROOF/CROWN/PYLONS` | top/silhouette and taller shoulder elements | geometry-owned, excluded |

There is no architectural repeat. The smallest truthful representation is a homogeneous field plus one complete door module and one band module inside an explicit ENE-main unique elevation.

## Physical scale status

| Element | Value | Confidence / use |
|---|---:|---|
| Current generated wall height | `20 m` | exact receiver contract |
| Frozen levels | `3` | exact tag; not a visible-story cadence until observed |
| Flat base / top | `3.478 / 23.478 m` | exact generated contract |
| Footprint area | `13394.520 m²` | exact source/generated join |
| Wall perimeter | `488.311 m` generated | exact receiver contract |
| `B3-HANGAR-DOOR` prototype bounds | `35..55 m` wide by `9..15 m` tall estimate | low confidence; reference-relative calibration only, not as-built claim |
| `B3-BAND` | `0.25..0.8 m` tall estimate | low confidence; terminate in ordinary field before corners |

## Output classification and repeat/seam blueprint

| Output kind | Readiness | Rationale |
|---|---|---|
| `homogeneous_material_tile` | **ready** | uniform warm off-white painted-mineral field; no facade-scale motif in tile |
| `architectural_pattern_tile` | blocked/not applicable | no panel, rib, masonry, joint or opening period is visible |
| `module_atlas` | **ready, ENE families only** | one complete `B3-HANGAR-DOOR` and one `B3-BAND`; service/small-opening modules blocked |
| `unique_elevation` | **ready for bounded ENE-main prototype** | one non-periodic end schedule across exact main group; placement is reference-relative and must exclude minor returns |

### Legal seams

- Phase-matched seams within one observed homogeneous white material field.
- Verified complete panel/masonry/rib unit boundaries with unchanged edge products.
- Ordinary material field between complete modules.
- Exact side/run boundaries only when a unique layout explicitly ends there in ordinary material.

### Forbidden seams

- Any seam through a hangar door, personnel door, opening, pier, frame, vent, louver, band, sign, panel termination, or unique stain.
- Any generated U reset, chamfer, or minor return treated as an automatic facade-period reset.
- Any major-side schedule wrapped onto an end facade or minor return without observation.
- Any motif clipped by the side endpoint, receiver top, foundation terrain, or corner.

## Godot bill of materials

| ID | Proposed stable path | Godot role | Evidence gate |
|---|---|---|---|
| `MAT-WHITE` | `res://game/resources/materials/world/building_3/building_3_white_primary.tres` | warm off-white painted-mineral field; value `0.72..0.88`, metallic `0`, roughness `0.72..0.90` | **ready** |
| `MAT-DOOR` | `res://game/resources/materials/world/building_3/building_3_teal_door.tres` | dark teal/blue opaque door; value `0.08..0.22`, metallic `0`, roughness `0.48..0.72` | **ready** |
| `MOD` | `res://game/scenes/world/facades/building_3/building_3_ene_modules.tscn` | complete `B3-HANGAR-DOOR` and `B3-BAND` shallow modules | **ready** |
| `LAYOUT` | `res://game/resources/facades/building_3_600_california_ene_layout.json` | explicit layout for main `9 / 90.320 m` ENE group | **ready for reference-relative prototype** |
| `ATTACH` | `res://game/scenes/world/facades/building_3/building_3_600_california_facade.tscn` | exact target noncolliding visual child | ready after visual, endpoint and spray gates |

## Geometry-versus-texture boundary

### Potentially owned by this facade pass

- Observed white/secondary surface color and value, roughness, low-amplitude normal response, and subordinate weathering.
- Complete shallow render-only `B3-*` modules, opaque relief `0..0.12 m` (`production_inference`).
- Explicit material/module placement on identified sides and returns.

### Explicitly excluded

- Gross height, three-level massing, hangar roof/crown profile, taller shoulder/pylon silhouette, parapet, footprint, deep door/recess volumes, structural openings, interiors, or real access.
- Collision, spray eligibility, foundation terrain extensions, roof receiver status, navigation, terrain, or generated OSM/chunk/coverage/logical-object contracts.

### Representative before -> after preserving invariants

```text
before: building:w34313540:wall is one 20 m-high generated, opaque spray
        receiver with 59 wall runs and one shared plaster_grey_04 surface.

after:  that exact wall, flat roof, height, footprint, 59 runs, collision,
        spray target, source ID and generated bytes remain unchanged. A
        noncolliding child adds the warm off-white field plus one complete
        teal hangar-door module and one shallow band only over the contiguous
        9-run / 90.320 m ENE-main group; every other run remains unchanged.
```

## Executable acceptance checklist

### Research and implementer gates

- [x] `B3-SV01..02` record exact URL, panorama ID, access/capture date, view direction and coverage without stored imagery.
- [x] Every appearance claim is traceable to the handoff; side mapping is separately labeled inference with confidence.
- [ ] Target is exact Building 3 at frozen address `600 California Avenue, CA`, not Building 2 or another hangar.
- [ ] Receiver remains `building:w34313540:wall` in `x_1__z_1`, `20 m` high, base/top `3.478/23.478 m`, `59` runs, `118` wall triangles, `27` roof triangles.
- [ ] `building:colour=white` is treated as a coarse corroborating fact, not as proof of material, value, roughness or repeat.
- [ ] Side layouts use exact endpoints/continuous coordinates and do not reset at the `59` generated subdivisions.
- [ ] ENE layout targets only wall runs `27..35`, the contiguous `9 / 90.320 m` main group, and never discontiguous minor ENE-normal returns.
- [ ] Material proofs preserve all seam products; every atlas/module motif is complete.
- [ ] Modules are render-only; underlying collision remains the only collider/spray target and decals remain visible.
- [ ] No silhouette, story, massing, roof, footprint, foundation, terrain, collision, spray or generated-contract change occurs.

### Independent reviewer gates

- [ ] Compare only mapped observed sides to identified panoramas; mark every other side/return unobserved.
- [ ] Reject motifs invented from “hangar,” “Palace of Fine Arts,” exposition, naval, historic, or white category labels.
- [ ] Reject a single universal facade cadence unless the observation proves it on both long sides and both ends.
- [ ] Reject any cadence restart at a generated subdivision or motif clipping at a chamfer/return.
- [ ] Keep material, module, receiver and whole-building verdicts separate; “better than plaster” is not acceptance.

## Explicit unknowns and blockers

| Unknown | Impact | Safe fallback | Stop condition |
|---|---|---|---|
| Exact door/band metre offsets and door subdivision | no as-built placement claim | reference-relative prototype on exact ENE-main group | stop if surveyed precision is required |
| Long sides, WSW end and minor returns | no schedules or symmetry claim | leave unchanged; do not mirror ENE | stop if unique motifs are requested there |
| Service block, small doors/openings, vents and signs | incomplete/unobserved motifs | omit | stop before authoring those modules |
| Curved crown/barrel roof and taller shoulder elements versus flat receiver | faithful silhouette impossible under invariant | preserve receiver and disclose mismatch | always stop before roof/silhouette/massing change |

## Normalized research handoff

```yaml
schema_version: codex.building-texture-research/1
job:
  job_id: building_3_600_california_facade_reference_spec
  checked_date: 2026-08-29
  intended_use: bounded_ENE_facade_implementation_handoff
  target_asset_kind: unique_elevation
target:
  canonical_name: Building 3 / 600 California Avenue
  local_object_ids: [w34313540, building:w34313540, building:w34313540:wall]
  identity_confidence: high
  receiver_path: WorldRoot/PlayableWorld/Buildings/x_1__z_1__building_w34313540_wall/building_w34313540_wall
reference_roles:
  identity_context: [L01]
  massing: [L01, L02]
  pattern_region: [B3-SV01, B3-SV02]
  cadence_and_seams: [B3-SV01, B3-SV02]
  material_surface: [B3-SV01, B3-SV02]
  scale: [L02, B3-SV01, B3-SV02]
  rejection_example: []
pattern_regions:
  - {region_id: ENE_MAIN, local_scope: contiguous_9_run_90.320m_group, periodicity: unique_end_elevation, must_not_share_tile_with: [ENE_MINOR, SSE, WSW, NNW]}
motif_inventory: [B3-HANGAR-DOOR, B3-BAND]
motif_sequences:
  - {region_id: ENE_MAIN, horizontal: ordinary_field_one_center_door_ordinary_field, vertical: door_below_band_below_geometry_owned_crown}
repeat_blueprint:
  region_id: ENE_MAIN
  smallest_cell_status: no_repeat_unique_end
  period_tokens_horizontal: null
  period_tokens_vertical: null
  period_m: {x: null, y: null}
  cell_contents_full_motifs: [B3-HANGAR-DOOR, B3-BAND]
  edge_fragments: {left: [], right: [], top: [], bottom: []}
  edge_compositions_expected: {left_plus_right: [], top_plus_bottom: [], corners: []}
  legal_seam_zones: [uniform_warmwhite_field, complete_module_boundary]
  forbidden_seam_zones: [B3-HANGAR-DOOR, B3-BAND, generated_U_resets, side_end_and_return_corners, ENE_minor_returns]
  fallback_if_not_proven: unique_elevation
material_brief:
  surface_family: painted_mineral_or_smooth_stucco_concrete_like
  base_color: very_light_warm_offwhite_cream
  finish: matte
  relief_direction_and_frequency: very_low_amplitude_nonperiodic_surface
  roughness: 0.72_0.90
  variation_and_weathering: low_medium_diffuse_variation_and_restrained_base_grime
  maps_requested: [albedo, roughness, low_amplitude_normal]
  maps_forbidden: [height_displacement, baked_lighting, photographic_reflections]
  tile_scale_status: homogeneous_field_ready_module_dimensions_low_confidence
  tile_scale_m: {x: null, y: null}
excluded_architectural_features:
  - {feature: massing_roofline_silhouette_and_structural_hangar_openings, owner: geometry, reason: invariant}
  - {feature: all_unobserved_facade_motifs, owner: facade_module, reason: missing_reference}
hard_mismatch_gates:
  - {scope: identity, reject_if: target_is_not_w34313540_or_is_confused_with_Building_2, proof_required: frozen_source_and_runtime_metadata}
  - {scope: evidence, reject_if: visual_claim_lacks_B3_SV_support, proof_required: panorama_ledger}
  - {scope: geometry, reject_if: massing_roof_collision_spray_foundation_terrain_or_generated_contract_changes, proof_required: exact_receiver_audit}
  - {scope: repeat, reject_if: one_universal_cadence_is_assumed_without_observation, proof_required: side_specific_repeat_blueprint}
research_verdict:
  ready_for_generation: true
  recommended_output_kind: homogeneous_material_tile_plus_module_atlas_plus_unique_elevation
  ready_scope: contiguous_ENE_main_group_only
  blockers:
    - no_modules_or_mirroring_on_long_sides_WSW_end_or_minor_returns
    - exact_door_and_band_offsets_are_reference_relative_not_surveyed
    - whole_object_crown_and_pylon_silhouette_cannot_be_reproduced_under_invariant
```

## Final research status

- Identity and exact receiver contract: **ready**.
- Homogeneous material, `B3-*` modules and bounded ENE-main unique elevation: **ready**.
- Other sides, returns and service motifs: **blocked/unobserved**.
- Whole-building fidelity: **limited by the invariant-preserved flat receiver versus observed curved crown and taller shoulder elements**.
