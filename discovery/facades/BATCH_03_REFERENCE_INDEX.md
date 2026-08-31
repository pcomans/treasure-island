# Batch 03 facade reference index and implementation priority handoff

Checked: **2026-08-29**
Mode: **research/specification only**
Observation ledger: [`BATCH_03_STREETVIEW_OBSERVATIONS.md`](BATCH_03_STREETVIEW_OBSERVATIONS.md) (**integrated**)

## Cohort verdict

All eight frozen sources have exact direct wall receivers, runtime paths, generated topology and invariant boundaries. No appearance is asserted from tags. Official facade evidence exists only for **Personnel Support Detachment**, **Fire Training Building 600**, and **Fire Station 48**; their conservative material/module briefs are reference-ready, but final generation and placement remain blocked. Education Center 29A is fully occluded. Harvey Milk, Naval Station, Food Service and Advanced Culinary have no approved official target elevation; Advanced Culinary's current identity also remains low confidence.

## Exact receiver inventory and priority

| Order | Target/spec | Wall receiver / chunk | Generated contract | Local readiness | Appearance blocker |
|---:|---|---|---|---|---|
| 1 | [Harvey Milk Administration, 655 Avenue H](HARVEY_MILK_ADMINISTRATION_655_AVENUE_H_REFERENCE_SPEC.md) | `building:w34313513:wall` / `x_0__z_0` | `9 m`; 50 runs / `276.468 m`; wall 100 tri / roof 22 tri | exact | blocked: no official public elevation |
| 2 | [Naval Station Treasure Island, 450 4th Street](NAVAL_STATION_TREASURE_ISLAND_450_4TH_REFERENCE_SPEC.md) | `building:w34313544:wall` / `x_0__z_1` | `7 m`; 31 / `188.865 m`; 62 / 17 tri | exact | blocked: no official target-identifiable elevation |
| 3 | [Personnel Support Detachment, 550 4th Street](PERSONNEL_SUPPORT_DETACHMENT_550_4TH_REFERENCE_SPEC.md) | `building:r133347:wall` / `x_0__z_1` | `6 m`; 28 / `250.796 m`; 56 / 8 tri | material/grid + complete-bay research brief ready | blocked: scale/infill/run map/south-west/courtyard |
| 4 | [Fire Training Facility Building 600, 750 Avenue M](FIRE_TRAINING_FACILITY_BUILDING_600_REFERENCE_SPEC.md) | `building:w34313548:wall` / `x_1__z_-2` | `6 m`; 24 / `243.359 m`; 48 / 2 tri | pale-field/window/portal research briefs ready | blocked: calibration/cadence/run map/hidden sides; portal geometry-dependent |
| 5 | [San Francisco Fire Station 48](FIRE_STATION_48_REFERENCE_SPEC.md) | `building:w764313741:wall` / `x_0__z_-2` | fallback `6 m`; 26 / `187.957 m`; 52 / 10 tri | pale-field/high-window research brief ready; no street address | blocked: substrate/scale/cadence/run map/operational openings/hidden sides |
| 6 | [Job Corps Food Service Building 368, 575 Avenue D](JOB_CORPS_FOOD_SERVICE_BUILDING_368_REFERENCE_SPEC.md) | `building:w34313521:wall` / `x_-1__z_0` | `6 m`; 36 / `352.795 m`; 72 / 10 tri | exact receiver; no visual output | blocked: no approved official elevation; contributor path excluded |
| 7 | [Education Center Building 29A, 550 Avenue H](EDUCATION_CENTER_BUILDING_29A_REFERENCE_SPEC.md) | `building:w109905031:wall` / `x_0__z_-1` | `3 m / 1 level`; 16 / `166.314 m`; 32 / 6 tri | exact viewpoint join; no visual output | blocked: complete facade occlusion |
| 8 | [Advanced Culinary Dormitory, 487–489 4th Street](ADVANCED_CULINARY_DORMITORY_REFERENCE_SPEC.md) | `building:w34313514:wall` / `x_0__z_1` | fallback `6 m`; 44 / `313.900 m`; 88 / 22 tri | receiver exact; current name low confidence | blocked: no official frontage and unresolved current identity |

Run lengths above are generated visible-wall sums; minor serialized-perimeter differences are retained in each target spec. One Godot unit is one metre.

## Local identity and source cautions

- Frozen names/addresses identify source joins; they do not prove present use, signage, material or condition.
- Fire Station 48 has city/state/country but no frozen street address. Keep that absence explicit.
- `r133347` is a relation with outer way `w34313505` and inner way `w34313506`; outer and courtyard runs are different propagation domains even when normals match.
- The Personnel Support Detachment and Education Center `building=abandoned` tags are dated source attributes, not current-condition observations.
- Job Corps Food Service `amenity=restaurant` is not current restaurant/signage evidence.
- Fire Training Building 600 and Fire Station 48 share a service category but no visual vocabulary may transfer between them.
- Education Center 29A cannot inherit from any 29B–29E building without its own evidence.
- Advanced Culinary Dormitory's frozen source note is an explicit identity warning; do not author appearance until the observation ledger reconciles the footprint.

## Official observation coverage

| Target | Official source result | Observed / unobserved | Usable subset |
|---|---|---|---|
| Harvey Milk | `HMA-NO01/02`, no imagery; no capture date | none / all sides | none |
| Naval Station | `NSTI-NO01`, no imagery; no capture date | none / all sides | none |
| Personnel Support | `GAuBhldmLlZOQwXj8qav3w`, Jun 2021; `_rk3B0PasMLUEPCQCA_sJw`, Sep 2025 | east+north outer / south+west+all courtyard | dark grid/material hierarchy and complete-bay grammar |
| Building 600 | `ifdNQ-gh7K1ryx3rVMvW2w`, Sep 2025; `t8V4SOhQFPRXL_vukoMRog`, Sep 2025 | SSE entry+WSW / ENE+NNW+occluded bays | pale coarse field, horizontal window, unique red portal brief |
| Fire Station 48 | `UQGBH77cFgLZE2Utr1MI4Q`, May 2019; `U1HtZQlUKomn07I4TT93ug`, Sep 2025 | portions NNW+WSW / SSE+ENE+occluded base | pale field and high-window grammar |
| Food Service B368 | `B368-NO01/02`, no official imagery; contributor path excluded | none / all sides | none |
| Education 29A | `o96ZjQzRGjybIV2jQd6hDw`, Mar 2025; `emqMw-XLaeQ03pPhEs3v-Q`, Mar 2025 | no usable facade; NNW/WSW area fully occluded / ENE+SSE unviewed | none |
| Advanced Culinary | `ACD-NO01`, no imagery; no capture date | none / all sides | none; current identity unresolved |

All exact request URLs, actual viewpoints, directions, displayed capture dates, visible facts and exclusions are in the target specs and observer ledger. Imagery was observed transiently only; no image or pixel data was downloaded, retained, copied, redistributed or committed.

## Shared receiver and implementation boundary

- Direct walls use `building_wall -> plaster_grey_04`; roofs use `building_roof -> bitumen`; these are placeholders, not appearance evidence.
- Every wall is the opaque `world_solid` and sole spray receiver. Every roof is opaque collider/non-spray.
- U restarts on every serialized run; V uses world y divided by `10`. Neither coordinate provides architectural cadence.
- No Batch 03 target has shared-above-lower-part runs.
- A future facade child may contain only evidence-backed, shallow, noncolliding render modules and PBR fields.
- Footprint, height/stories, silhouette/roof, structural openings, wall/roof topology, collision, spray eligibility/ownership, navigation, foundation/terrain, OSM IDs/tags and generated bytes remain invariant unless separately approved.

Representative invariant-preserving change:

```text
before: each target is its exact generated wall/roof receiver using shared
        placeholder materials, with its recorded runs and collision/spray roles.

after:  those same IDs, paths, footprints, heights, roofs, run topology,
        foundations, collision and spray roles remain byte-for-byte unchanged;
        a noncolliding child adds only observed fields and complete shallow modules
        to exact endpoint-mapped run chains.
```

## Output and seam policy

Each spec evaluates all four required classes: `homogeneous_material_tile`, `architectural_pattern_tile`, `module_atlas`, and `unique_elevation`. Personnel Support, Building 600 and Fire Station 48 now have reference-ready homogeneous-field/module briefs, but calibrated generation remains blocked. No architectural pattern tile or placed unique elevation is ready anywhere in the cohort.

Legal future seams are confined to uninterrupted homogeneous fields, full repeat-cell boundaries, complete module boundaries or exact elevation endpoints. Forbidden seams include generated U resets, motif interiors, corners, receiver top/foundation, ring changes and unobserved regions. Cardinal labels are lookup aids only: exact ordered endpoints and observation-to-run reconciliation must precede deterministic placement.

## Batch acceptance gates

- [x] The observer ledger is integrated without adding unrecorded appearance claims.
- [x] Each current claim carries exact official panorama URL/ID, access/capture date, direction, coverage, label and confidence.
- [x] Observed and unobserved sides remain explicit; public-road views never fill hidden rear/courtyard faces.
- [ ] All eight receiver IDs, chunks, heights/height sources, run counts/lengths and triangle counts match their specs and inventory.
- [ ] `r133347` layouts assert outer `0..17` versus inner `18..27`; no ring transfer.
- [ ] Every deterministic placement is tied to exact endpoint chains; same-normal returns and reentrant chains remain separate unless reconciled.
- [ ] Every output uses the smallest proven repeat/non-repeat rationale and a physical scale with confidence.
- [ ] Complete motifs and required seam products are present; no texture sheet or unique-elevation crop cuts a legal unit.
- [ ] Advanced Culinary Dormitory remains blocked unless independently reconciled to `w34313514`.
- [ ] Fire Station 48 retains “no frozen street address” and fallback-height uncertainty.
- [ ] No present use, current abandonment, signage, story count, material or condition is derived from local tags alone.
- [ ] Shallow visual children add no physics/navigation/spray ownership and change no massing/generated/source contract.
- [ ] An independent reviewer accepts exact-ID/receiver proof, visual fidelity, seam proof and invariant preservation before attachment.

## Current priority state

1. Use only the three reference-ready material/module research subsets; calibrate substrate/scale before generation.
2. Reconcile any future placement to exact ordered receiver endpoints while preserving every hidden-side, identity and geometry blocker.
3. Defer runtime attachment until independent visual/receiver review and an exact observation-to-run map exist.

At this revision, exact receiver handoffs are ready for all eight, while Advanced Culinary's current human-readable identity remains provisional. **Three conservative material/module briefs are implementation-ready as specifications, not as generated or attachable assets.** All other target-specific facade outputs are blocked.
