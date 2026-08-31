# Treasure Island Administration Building 1 / Treasure Island Museum facade reference specification

Checked: **2026-08-29**  
Mode: **research and implementation handoff only**  
Target source: **`r16681702`**  
Current wall receiver: **`building:r16681702:wall`**

## Handoff verdict

The receiver is not merely a colloquial “museum building.” Frozen project evidence identifies it as historic **Treasure Island Administration Building 1**, addressed at **1 Avenue of the Palms**, whose current public gallery/visitor-center use is the **Treasure Island Museum**.

Three official September 2025 Street View panoramas establish bounded warm-ivory/trim/base materials and complete wing-window, central-window, pavilion-window, base-opening, blue-door and shallow-band module families across the public west-facing outer elevations. Those materials and complete modules are implementation-ready as reusable assets. Exact unique-elevation placement is **not** ready: the panoramas have not been reconciled to individual outer-ring run endpoints. The east/rear elevation, all ten inner-ring runs, the separate observation tower, the main entrance/canopy and small high emblems remain excluded.

A whole-object fidelity limit also remains: the observation shows long two-level wings with taller end pavilions and stepped/fluted roof-edge elements, while the receiver is one uniform `20 m` extrusion. The no-massing/no-silhouette invariant forbids correcting that profile in this facade pass.

## Evidence labels

- `verified_fact`: exact frozen OSM, generated-world, or locally recorded official-source evidence.
- `reference_observation`: visible in an identified Street View panorama and to be imported only from the dedicated observation handoff.
- `production_inference`: a reversible bounded art/implementation choice.
- `unknown`: not established and not safe to use as a prompt or acceptance value.

## Confirmed identity and exact receiver

| Item | Exact value | Status |
|---|---|---|
| Building identity | Treasure Island Administration Building 1 / Building One | `verified_fact`; frozen inner address/name node plus local official-source record |
| Current venue/use identity | Treasure Island Museum public gallery and visitor center in Building One | `verified_fact`; relation tags plus locally recorded February 2026 TIDA source `S10` |
| Address | 1 Avenue of the Palms | `verified_fact`; frozen node `n1450130174` inside the building footprint, named `Treasure Island Administration Building 1` |
| Building source | relation `16681702`, key `r16681702`, version `6`, timestamp `2026-08-21T23:22:40Z` | exact frozen snapshot |
| Frozen relation tags | `name=Treasure Island Museum`, `old_name:1940-1996=Administration`, `building=yes`, `tourism=museum`, `museum=history`, `historic=naval`, `start_date=1938`, `height=20` | exact frozen snapshot |
| Architect / heritage | William P. Day and George Kelham; NRHP `08000081`, criteria `A;C`, inscription `2008-02-26` | exact frozen tags; not facade material evidence |
| Relation geometry | outer members `w1169707889` and `w34313541`; inner member `w1222720021` | exact frozen multipolygon |
| Inner member identity | separate `building=yes`, `man_made=tower`, `tower:type=observation` object | must not be styled or targeted as part of `r16681702` facade |
| Logical object | `building:r16681702` | exact generated identity |
| Wall / roof | `building:r16681702:wall`; `building:r16681702:roof` | exact generated physical objects |
| Chunk | `x_-1__z_2` | exact generated chunk |
| Runtime wall path | `WorldRoot/PlayableWorld/Buildings/x_-1__z_2__building_r16681702_wall/building_r16681702_wall` | derived exactly from current builder naming |
| Current appearance | `building_wall -> plaster_grey_04` | shared placeholder only; no target-specific museum override |

### Current generated mass and mesh contract

- Height rule: `osm_height`, `20 m`.
- Flat base `6.281 m`; top `26.281 m`; lowest terrain foundation vertex `3.765 m`.
- Source/serialized area `4239.533 m²`; serialized perimeter `414.381 m`.
- Wall: `110` foundation runs, `414.381 m` total, `440` vertices, `220` triangles, one material surface. Exact serialized ordering is `100` outer-ring runs / `389.121 m`, followed by `10` inner-ring runs / `25.260 m`.
- Roof: `82` vertices, `84` triangles; opaque collider, not a spray receiver.
- Wall: opaque `world_solid`, `receiver_kind=building_wall`, `Collision` in `spray_receiver_wall`, render layer `RENDER_BUILDING_WALL`.
- UV1 U restarts independently on every one of the `110` wall runs. V is world elevation divided by ten. A facade cadence or side layout must not use those resets as architectural boundaries.

### Receiver orientation coverage

These are outward-normal totals, not semantic frontage or outer-versus-inner ring labels.

| Facing bucket | Visible length | Observation mapping |
|---|---:|---|
| N | `48.450 m` | public north/outer coverage is partial; exact runs unresolved |
| NE | `56.697 m` | no confident public-elevation mapping |
| E | `54.169 m` | east/rear unobserved |
| SE | `61.838 m` | no confident public-elevation mapping |
| S | `30.061 m` | public south/outer coverage is partial; exact runs unresolved |
| SW | `77.429 m` | public west/south outer coverage observed; exact runs unresolved |
| W | `37.219 m` | broad curved public outer elevation observed; exact runs unresolved |
| NW | `48.517 m` | public west/north outer coverage observed; exact runs unresolved |

The relation contains an inner observation-tower footprint. Orientation alone cannot tell an outer public elevation from an inner/courtyard-facing wall. In the current serialized target wall, run indices `0..99` are outer-ring runs and `100..109` are the ten inner-ring runs, whose endpoints exactly reverse the separate tower's ten foundation edges. Any unique layout must carry exact wall-run endpoints plus `outer` or `inner` ring ownership; cardinal bucket matching is insufficient and is a hard stop if the target run cannot be identified.

## Source and provenance ledger

No external image may be downloaded, copied, retained, redistributed, uploaded, or committed.

| ID | Source | Access / capture | Supports | Does not support / reuse status |
|---|---|---|---|---|
| `L01` | `data/osm/treasure-island-2026-08-27.osm`: relation `r16681702`, node `n1450130174`, and relation members | Checked 2026-08-29 | exact building/venue names, address, history tags, relation topology | no facade appearance; project-held ODbL source |
| `L02` | `discovery/FACADE_RECEIVER_INVENTORY.json` and `.md`; `generated/world/logical-objects.json`; `generated/world/chunks/x_-1__z_2.json` | Checked 2026-08-29 | exact receiver, massing, mesh, orientation, material/UV/runtime limits | no real facade appearance |
| `L03` | `discovery/ISLAND_EVIDENCE.md`, locally recorded source `S10` | Checked 2026-08-29; underlying TIDA report dated 2026-02-11 | museum gallery/visitor-center use in Building One | no facade material/cadence; source not re-browsed |
| `B1-SV01` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8169,-122.37205&heading=55&pitch=6&fov=75`; panorama `TpG54H0huRdII4VZxBG0TA` | Accessed 2026-08-29; UI displayed **Image capture: Sep 2025**; WSW looking NE `55°` | broad curved public elevation, wings and taller center | observation only; no storage/reuse |
| `B1-SV02` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.81755,-122.37205&heading=105&pitch=6&fov=75`; panorama `_jdZk4lGHsH5qq_VmIyd7g` | Accessed 2026-08-29; UI displayed **Image capture: Sep 2025**; NW looking ESE `105°` | north pavilion, curve, wing, base openings and utility door | observation only; no storage/reuse |
| `B1-SV03` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.81655,-122.37175&heading=55&pitch=6&fov=75`; panorama `racCKmRzOLLicCqyLct7vA` | Accessed 2026-08-29; UI displayed **Image capture: Sep 2025**; SW/south looking NE `55°` | south pavilion and broad curve | observation only; no storage/reuse |
| `SV-HANDOFF` | `discovery/facades/NEXT_COHORT_STREETVIEW_OBSERVATIONS.md` | Checked 2026-08-29 | observation/inference/unknown boundary | project evidence ledger; contains no imagery |

## Observed and unobserved facade coverage

### Observed

`reference_observation` from `B1-SV01..03`:

- The dominant field is smooth painted-mineral/stucco-like warm ivory/off-white, with lighter raised trim, pilaster/fluted strips and roof-edge bands; glazing is dark muted blue-grey, isolated doors dark blue, and the parking-wing base includes a narrow muted salmon/rose band.
- The finish reads matte to low satin with diffuse discoloration/runoff and restrained, low-contrast weathering.
- Long wings use a repeated two-level punched-rectangle window family. The curved central zone uses denser, taller narrow multipane openings separated by plain piers. Taller end pavilions use dominant full-height multipane groups with flanking openings.
- The window families are distinct; they are not interchangeable slots in one universal repeat.
- Shallow horizontal belt/cornice bands and stepped/fluted pilaster-like strips organize the elevation. The north view also shows small base windows/vents and one complete blue utility door.

`production_inference`, medium confidence: this coverage maps across outer west-facing SW/W/NW runs, with B1-SV02 adding outer NW/N and B1-SV03 adding outer SW/S. Exact run endpoints are not yet mapped.

### Unobserved

- East/rear outer elevations and service conditions.
- All inner-ring runs `100..109` and the separate tower.
- The complete main entrance/canopy assembly; it is occluded/incomplete in the available views.
- Exact outer-run endpoints, bay counts, metre dimensions, glazing subdivision, and facade-to-run offsets.
- Small high emblems are visible only as blurry localized marks; do not reproduce them until legible authoritative reference exists.

## Material regions, motif grammar, and cadence

| Region | Scope | Observed grammar / status |
|---|---|---|
| `OUTER-WING` | observed west-facing long wings | `B1-WING-W`: two-level punched rectangular window family in warm-ivory field |
| `OUTER-CENTRAL` | observed broad curved central zone | `B1-CENTRAL-W`: taller narrow multipane opening between plain piers; explicit curved-elevation sequence |
| `OUTER-PAVILION` | observed north and south taller end pavilions | `B1-PAV-W`: dominant full-height multipane group with flanking openings and stepped/fluted trim |
| `OUTER-BASE` | observed north/parking-wing base | `B1-BASE-O` small base opening/vent; `B1-DOOR-BLUE` complete utility door; muted rose base band |
| `OUTER-BANDS` | observed wing/central/pavilion fields | `B1-BAND`: shallow belt/cornice strip, terminated only at observed module/layout boundaries |
| `OUTER-OTHER` | east/rear and all unmapped outer runs | no unique modules; homogeneous continuity only if independently proven |
| `INNER-RING` | runs `100..109` facing tower hole | unobserved; never inherit the public-front schedule |
| `FOUNDATION-EXT` | wall below flat base down to terrain | generated geometry only; no doors/windows/modules |
| `ROOF/TOWER` | roof silhouette and separate `w1222720021` tower | excluded geometry / separate receiver |

There is no universal smallest repeat: the curved center, two pavilion families and wing modules require complete atlas tokens and an eventual explicit elevation. `B1-WING-W` may repeat only as a whole window-plus-ordinary-field bay after its phase is calibrated. Main entrance/canopy and emblem tokens do not exist.

## Physical scale status

| Element | Value | Confidence / use |
|---|---:|---|
| Current generated wall height | `20 m` | exact receiver contract |
| Flat base / top | `6.281 / 26.281 m` | exact generated contract |
| Total wall run | `414.381 m` | exact generated contract |
| Source area | `4239.533 m²` | exact frozen/project join |
| Real start date | `1938` | frozen OSM historical tag; not a module measurement |
| observed wing story band | `3.5..5.0 m` estimate | low confidence; prototype bounding only |
| `B1-WING-W` | `1.2..2.0 m` wide, `1.3..2.1 m` tall estimate | low confidence; reference-relative calibration required |
| `B1-CENTRAL-W` | `0.8..1.3 m` wide, `3..5 m` tall estimate | low confidence |
| `B1-PAV-W` grouped opening | `4..7 m` wide, `8..14 m` tall estimate | low confidence; do not alter receiver silhouette |
| `B1-BASE-O` / `B1-BAND` | opening `0.6..1.2 m`; band `0.2..0.5 m` tall estimate | low confidence |

## Output classification and repeat/seam blueprint

| Output kind | Readiness | Smallest repeat / non-repeat rationale |
|---|---|---|
| `homogeneous_material_tile` | **ready, bounded** | warm-ivory field, lighter trim, rose base and dark-blue opaque fields have no facade-scale period; use non-focal low-frequency variation |
| `architectural_pattern_tile` | blocked | no single period spans wing, curve and pavilion; no edge/corner product is proven |
| `module_atlas` | **ready as asset family** | `B1-WING-W`, `B1-CENTRAL-W`, `B1-PAV-W`, `B1-BASE-O`, `B1-DOOR-BLUE`, `B1-BAND` are complete visible families; keep each whole |
| `unique_elevation` | blocked for integration | the observed composition is non-periodic, but exact outer-run endpoint mapping is unresolved; cardinal buckets are insufficient |

### Legal seams

- Phase-matched seams inside an observed homogeneous field.
- Verified complete architectural-unit boundaries after every edge product is named.
- Ordinary material field between complete modules.
- Explicit unique-layout boundaries at exact outer-run endpoints.

### Forbidden seams

- Any seam through an opening, arch, door, column/pilaster, capital, band, sign, grille, vent, panel termination, or other complete motif.
- Any generated segment U reset treated as a story/bay boundary.
- Any outer facade schedule wrapped onto an inner-ring wall because the outward-normal bucket happens to match.
- Any module crossing a relation ring boundary, corner, wall-run endpoint, receiver top, or terrain foundation.
- Any styling of the separate `w1222720021` tower through the `r16681702` target attachment.

## Godot bill of materials

| ID | Proposed stable path | Godot role | Evidence gate |
|---|---|---|---|
| `MAT-IVORY` | `res://game/resources/materials/world/building_1/building_1_warm_ivory.tres` | value `0.72..0.86`, roughness `0.72..0.90`, metallic `0`; low-amplitude diffuse wear | **ready** |
| `MAT-TRIM` | `res://game/resources/materials/world/building_1/building_1_light_trim.tres` | lighter related mineral trim, value `0.78..0.90`, roughness `0.68..0.86` | **ready** |
| `MAT-BASE` | `res://game/resources/materials/world/building_1/building_1_rose_base.tres` | low-chroma muted salmon/rose, value `0.40..0.60`, roughness `0.70..0.88` | **ready only on observed base region** |
| `MAT-GLASS` | `res://game/resources/materials/world/building_1/building_1_bluegrey_glass.tres` | dark blue-grey, value `0.15..0.30`, roughness `0.20..0.40`; no emissive/interior fiction | **ready** |
| `MAT-DOOR` | `res://game/resources/materials/world/building_1/building_1_blue_door.tres` | dark blue opaque paint, value `0.12..0.30`, roughness `0.55..0.75` | **ready** |
| `MOD` | `res://game/scenes/world/facades/building_1/building_1_modules.tscn` | complete six-family `B1-*` shallow atlas | **ready for asset authoring** |
| `LAYOUT` | `res://game/resources/facades/treasure_island_building_1_layout.json` | endpoint- and ring-aware unique layout | **blocked** until observed outer runs are reconciled |
| `ATTACH` | `res://game/scenes/world/facades/building_1/treasure_island_building_1_facade.tscn` | noncolliding target visual child | blocked until layout and invariant gates pass |

## Geometry-versus-texture boundary

### Potentially owned by this facade pass

- Observed surface color/value, roughness, low-amplitude normal response, and subordinate weathering.
- Complete shallow render-only modules within `0..0.12 m` opaque relief (`production_inference`).
- Explicit material/module placement on identified `r16681702` outer or inner runs.

### Explicitly excluded

- Gross height, story count, footprint, multipolygon rings, inner hole, separate tower, roofline, silhouette, deep recesses/projections, structural arches/openings, interiors, or private access. In particular, do not reshape the uniform receiver into lower wings/taller pavilions.
- Collision, spray eligibility, foundation terrain extensions, roof receiver status, navigation, terrain, or generated OSM/chunk/coverage/logical-object contracts.

### Representative before -> after preserving invariants

```text
before: building:r16681702:wall is one 20 m-high generated, opaque spray
        receiver with 110 wall runs and one shared plaster_grey_04 surface;
        its multipolygon excludes the separate inner observation-tower object.

after:  that exact wall, roof, rings, uniform height, 110 runs, collision,
        spray target, source ID and generated bytes remain unchanged. A later
        noncolliding visual child applies the bounded warm-ivory material and
        complete B1-* modules only after every public-west run is endpoint-
        mapped; the rear, inner ring and separate tower remain untouched.
```

## Executable acceptance checklist

### Research and implementer gates

- [x] `B1-SV01..03` record exact URL, panorama ID, access/capture date, view direction and coverage without stored imagery.
- [x] Every appearance claim is traceable to the handoff; side mapping is separately labeled inference with confidence.
- [ ] Target is identified as Building One at 1 Avenue of the Palms with Treasure Island Museum use, not by venue name alone.
- [ ] Receiver remains `building:r16681702:wall` in chunk `x_-1__z_2`, `20 m` high, base/top `6.281/26.281 m`, `110` runs (`100` outer + `10` inner), `220` wall triangles, `84` roof triangles.
- [ ] Layout entries include exact run endpoints and outer/inner ring role; cardinal buckets alone are rejected.
- [ ] No unique-elevation integration begins until the observed west/north/south public coverage is reconciled to exact outer-run endpoints.
- [ ] No attachment targets or visually alters separate `w1222720021`.
- [ ] Material tiles contain no facade-scale motifs, ground/roof line, unique stain, baked light, or photographic reflection.
- [ ] Every pattern/atlas boundary preserves unchanged complete motifs in `3x3`, roll, corner and macro proofs.
- [ ] Modules are render-only; underlying collision remains the only collider/spray target and decals remain visible.
- [ ] No silhouette, story, massing, ring, roof, foundation, terrain, collision, spray or generated-contract change occurs.

### Independent reviewer gates

- [ ] Compare only endpoint-mapped observed runs to the identified panoramas; leave every other run explicitly unobserved.
- [ ] Reject any motif invented from Streamline Moderne, exposition, naval, museum, or “historic” category labels rather than observation.
- [ ] Reject any cadence restart at one of the `110` generated runs.
- [ ] Reject any outer/inner ring misassignment or tower styling through the target receiver.
- [ ] Keep material, motif, receiver, and whole-building verdicts separate; “better than shared plaster” is not acceptance.

## Explicit unknowns and blockers

| Unknown | Impact | Safe fallback | Stop condition |
|---|---|---|---|
| Exact outer-run endpoints for observed public elevations | no unique layout/integration | author materials/modules only; retain placeholder on receiver | stop before placement |
| East/rear and inner-ring coverage | no unique motifs there | placeholder, or homogeneous field only after continuity proof | stop if a unique motif is required |
| Main entrance/canopy and small high emblems | incomplete/illegible motif evidence | omit; use ordinary field | stop before authoring either motif |
| Exact dimensions, bay counts and glazing subdivisions | no as-built claim | use low-confidence prototype bounds and reference-relative calibration | stop if surveyed precision is required |
| Real lower-wing/taller-pavilion profile versus uniform 20 m receiver | faithful whole-object silhouette impossible under invariant | preserve receiver massing and disclose mismatch | always stop before massing/story/silhouette change |

## Normalized research handoff

```yaml
schema_version: codex.building-texture-research/1
job:
  job_id: treasure_island_building_1_museum_facade_reference_spec
  checked_date: 2026-08-29
  intended_use: bounded_material_and_module_implementation_handoff
  target_asset_kind: unique_elevation
target:
  canonical_name: Treasure Island Administration Building 1 / Treasure Island Museum
  local_object_ids: [r16681702, building:r16681702, building:r16681702:wall]
  identity_confidence: high
  receiver_path: WorldRoot/PlayableWorld/Buildings/x_-1__z_2__building_r16681702_wall/building_r16681702_wall
reference_roles:
  identity_context: [L01, L03]
  massing: [L01, L02]
  pattern_region: [B1-SV01, B1-SV02, B1-SV03]
  cadence_and_seams: [B1-SV01, B1-SV02, B1-SV03]
  material_surface: [B1-SV01, B1-SV02, B1-SV03]
  scale: [L02, B1-SV01, B1-SV02, B1-SV03]
  rejection_example: []
pattern_regions:
  - {region_id: OUTER_WING, local_scope: observed_public_wing, periodicity: complete_window_bays, must_not_share_tile_with: [OUTER_CENTRAL, OUTER_PAVILION, INNER_RING]}
  - {region_id: OUTER_CENTRAL, local_scope: observed_curved_public_center, periodicity: explicit_sequence, must_not_share_tile_with: [OUTER_WING, INNER_RING]}
  - {region_id: OUTER_PAVILION, local_scope: observed_taller_end_pavilions, periodicity: unique_group, must_not_share_tile_with: [OUTER_WING, INNER_RING]}
motif_inventory: [B1-WING-W, B1-CENTRAL-W, B1-PAV-W, B1-BASE-O, B1-DOOR-BLUE, B1-BAND]
motif_sequences:
  - {region_id: OUTER_WING, horizontal: repeated_complete_B1-WING-W_bays, vertical: observed_two_level_alignment}
  - {region_id: OUTER_CENTRAL, horizontal: explicit_tall_window_and_pier_sequence, vertical: tall_multipane_openings}
  - {region_id: OUTER_PAVILION, horizontal: grouped_full_height_window_with_flanks, vertical: unique_pavilion_group}
repeat_blueprint:
  region_id: OBSERVED_PUBLIC_OUTER
  smallest_cell_status: no_universal_cell_use_complete_modules
  period_tokens_horizontal: null
  period_tokens_vertical: null
  period_m: {x: null, y: null}
  cell_contents_full_motifs: [B1-WING-W, B1-CENTRAL-W, B1-PAV-W, B1-BASE-O, B1-DOOR-BLUE, B1-BAND]
  edge_fragments: {left: [], right: [], top: [], bottom: []}
  edge_compositions_expected: {left_plus_right: [], top_plus_bottom: [], corners: []}
  legal_seam_zones: [verified_uniform_field, complete_module_boundary, exact_outer_run_endpoint]
  forbidden_seam_zones: [complete_motifs, generated_U_resets, outer_inner_ring_confusion, separate_tower, unmapped_runs]
  fallback_if_not_proven: unique_elevation
material_brief:
  surface_family: smooth_painted_mineral_or_stucco_like
  base_color: warm_ivory_with_lighter_trim_rose_base_and_dark_bluegrey_openings
  finish: matte_to_low_satin
  relief_direction_and_frequency: low_amplitude_mineral_surface_plus_shallow_bands
  roughness: ivory_0.72_0.90_glass_0.20_0.40_door_0.55_0.75
  variation_and_weathering: diffuse_low_contrast_discoloration_and_runoff
  maps_requested: [albedo, roughness, low_amplitude_normal]
  maps_forbidden: [height_displacement, baked_lighting, photographic_reflections]
  tile_scale_status: broad_material_bands_ready_exact_motif_dimensions_low_confidence
  tile_scale_m: {x: null, y: null}
excluded_architectural_features:
  - {feature: massing_roofline_rings_and_separate_tower, owner: geometry, reason: invariant}
  - {feature: all_unobserved_motifs, owner: facade_module, reason: missing_reference}
hard_mismatch_gates:
  - {scope: identity, reject_if: target_is_not_r16681702_or_is_described_only_as_colloquial_museum, proof_required: frozen_relation_node_and_runtime_metadata}
  - {scope: evidence, reject_if: visual_claim_lacks_B1_SV_support, proof_required: panorama_ledger}
  - {scope: geometry, reject_if: massing_ring_tower_collision_spray_foundation_terrain_or_generated_contract_changes, proof_required: exact_receiver_audit}
  - {scope: module, reject_if: outer_layout_is_applied_to_inner_ring_or_separate_tower, proof_required: endpoint_and_ring_role_layout_audit}
research_verdict:
  ready_for_generation: true
  recommended_output_kind: homogeneous_material_tile_plus_module_atlas
  ready_scope: asset_authoring_for_observed_public_families_not_receiver_placement
  blockers:
    - unique_elevation_and_integration_blocked_until_exact_outer_run_endpoint_mapping
    - east_rear_inner_ring_main_entry_canopy_and_emblems_unobserved_or_incomplete
    - whole_object_profile_limited_by_uniform_20m_receiver
```

## Final research status

- Identity and exact receiver contract: **ready**.
- Homogeneous material and complete `B1-*` module asset authoring: **ready**.
- Unique elevation and receiver integration: **blocked pending exact outer-run endpoint mapping**.
- Whole-building fidelity: **limited by the invariant-preserved uniform `20 m` extrusion versus observed lower wings/taller pavilions**.
