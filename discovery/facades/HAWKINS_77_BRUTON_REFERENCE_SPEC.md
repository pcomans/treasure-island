# Hawkins / 77 Bruton Street facade reference specification

Checked: **2026-08-29**  
Mode: **research and implementation handoff only**  
Target: **Hawkins, 77 Bruton Street, Treasure Island**  
Current receiver: **`building:w1249412093:wall`**

## Handoff verdict

Hawkins is confirmed as frozen OSM way `w1249412093` and the current Godot wall receiver `building:w1249412093:wall`. The visual evidence supports a **material-plus-complete-module** facade treatment, not another bitmap that mixes cladding and partial windows.

The first invariant-safe implementation should combine:

1. separate homogeneous plain and fine-fluted white-pearlescent rainscreen materials;
2. separate dark smooth and dark ribbed ground-floor materials;
3. complete upper-window, narrow-window, lobby-door, storefront, garage, service-door, spandrel, and sign-band modules;
4. side-specific `unique_elevation` layout data that places only complete modules on the observed sides; and
5. conservative material-only layouts on unobserved sides.

The current receiver is a single `6.0 m`-high rectangular extrusion. The real Hawkins is a six-story mid-rise plus a lower companion mass. Under the explicit instruction not to change silhouette, story count, massing, collision, foundations, terrain, spray eligibility, or generated OSM contracts, a later implementation can improve **facade language** but cannot claim a faithful whole-building Hawkins elevation. That is the principal blocker and must remain visible in every later verdict.

## Evidence labels

- `verified_fact`: stated by an authoritative project/government/property source or exact local generated contract.
- `reference_observation`: visible in an identified owner or Street View reference, but not measured.
- `production_inference`: a reversible bounded art/implementation estimate.
- `unknown`: not established and not safe to present as a measured fact.

## Confirmed identity and exact receiver

| Item | Exact value | Status |
|---|---|---|
| Canonical public identity | Hawkins, 77 Bruton Street, San Francisco, CA 94130 | `verified_fact`; official-property identity already normalized in `discovery/TEXTURE_REFERENCE_RESEARCH.md` |
| Frozen OSM source | way `1249412093`, canonical key `w1249412093`, version `3`, timestamp `2025-04-06T04:37:54Z` | `verified_fact`; frozen snapshot |
| Frozen tags | `building=apartments`, `name=Hawkins` | `verified_fact`; the way has no address, levels, height, facade, or material tag |
| Source inventory | `data/osm/treasure-island-source-inventory.csv` | exact source row |
| Coverage row | `generated/world/coverage-ledger.csv` | exact row: represented, `default_6m`, chunk `x_-1__z_1` |
| Receiver inventory | `discovery/FACADE_RECEIVER_INVENTORY.json`, catalog key `facade-receiver:w1249412093` | exact joined receiver record |
| Logical object | `building:w1249412093` | exact generated identity |
| Wall object | `building:w1249412093:wall` | exact visual/collision/spray receiver |
| Roof object | `building:w1249412093:roof` | exact generated roof; not a spray receiver |
| Serialized receiver | `generated/world/chunks/x_-1__z_1.json` | exact generated record |
| Runtime scene root | `game/scenes/world/world_root.tscn` | current receiver is built under `WorldRoot/PlayableWorld/Buildings` |
| Runtime receiver path | `WorldRoot/PlayableWorld/Buildings/x_-1__z_1__building_w1249412093_wall/building_w1249412093_wall` | derived exactly from current builder node naming; children are `Mesh` and `Collision` |
| Assignment code | `game/scripts/world/world_chunk_builder.gd` | current wall material is shared `building_wall` -> `plaster_grey_04` |
| Current target-specific facade | none | `verified_fact`; rejected experiments are evidence only and current runtime has no Hawkins override |

### Current mass and receiver geometry

- Generated height rule: `default_6m`; source height `6.0 m`.
- Flat base elevation: `4.274 m`; top elevation: `10.274 m` NAVD 88 in the generated world.
- Source/serialized footprint area: `3970.51 m²`; serialized perimeter: `258.976 m`.
- Wall record: `80` vertices, `40` triangles, `20` exterior foundation segments, `0` shared wall segments.
- Collision: `world_solid`; opaque; `receiver_kind=building_wall`.
- Runtime wall physics remains in `spray_receiver_wall` with source key and derived-object metadata.
- Wall render layer is `RENDER_BUILDING_WALL` (`1 << 1`); the spray decal cull mask already targets that visual category.
- Generated UV1 stores U and world Y in tenths of a metre. U restarts at every one of the `20` foundation segments; V is effectively `world_y / 10`. A side-wide facade cadence must therefore not depend on current U continuity.

### Canonical four receiver sides

The side labels below are generated outward-normal orientation groups, not OSM semantic frontage tags.

| Side | Facing | Start XZ -> end XZ (m) | Length | Foundation segments | Observation status |
|---|---|---|---:|---:|---|
| `side_wsw` | azimuth `242.4°` / WSW; normal `(-0.886, 0, 0.464)` | `(-118.795, 451.595)` -> `(-79.648, 526.358)` | `84.392 m` | `7` | Owner-photo elevation; side mapping is a medium-confidence footprint/viewpoint inference |
| `side_se` | azimuth `129.8°` / SE; normal `(0.768, 0, 0.641)` | `(-79.648, 526.358)` -> `(-41.556, 480.728)` | `59.440 m` | `3` | Bruton/address elevation observed in official Street View; side mapping is a high-confidence footprint/viewpoint inference |
| `side_ene` | azimuth `62.4°` / ENE; normal `(0.886, 0, -0.463)` | `(-41.556, 480.728)` -> `(-69.387, 427.417)` | `60.138 m` | `6` | Unobserved as a complete elevation |
| `side_nnw` | azimuth `333.9°` / NNW; normal `(-0.440, 0, -0.898)` | `(-69.387, 427.417)` -> `(-118.795, 451.595)` | `55.007 m` | `4` | Unobserved as a complete elevation |

For any overlay or side-local shader, define side-local `u=0` at the stated start point and increase continuously toward the end point. Never restart the facade schedule at the current foundation subdivisions.

## Source and provenance ledger

No external image was downloaded, copied to the project, redistributed, or committed in this task.

| ID | Source | Access / capture | Role and supported observations | Reuse/privacy status |
|---|---|---|---|---|
| `P01` | Owner file `/Users/philipp/Downloads/IMG_7170.HEIC`; readable existing temporary conversion `/private/tmp/IMG_7170-reference.png`, `5712x4284`, SHA-256 `6b6a0f95902bd48c57c4f69b6bd7b97346c672d71c1b300d394170f6447db5cd` | Inspected 2026-08-29; capture date not asserted | Identity/context, broad WSW elevation, six-story main mass, lower companion, local cadence, materials, base/roof differentiation | Owner-private, local-only reference. Not copied to the repository and not authorized for upload or redistribution. The HEIC itself was not transformed in this task. |
| `SV01` | [Google Street View request at 77 Bruton](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8191991,-122.3715368&heading=311.09&pitch=0&fov=75); resolved official panorama ID `CqLfgqkDJF4LkB8NhgB1NQ` at `37.8191991,-122.3715368` | Accessed 2026-08-29; UI displayed **Image capture: Sep 2025** | Bruton/address elevation, headings `270°` to `311.09°`, pitch `0°` to `-22.55°`: full-height upper stack, lobby, sign band, service ribbing, garage, terrace/volume transition | Visual observation only. No screenshots or Street View imagery stored in the repo; no download, account, credentials, CAPTCHA, or upload used. Google imagery remains subject to its own copyright/terms. |
| `L01` | `discovery/TEXTURE_REFERENCE_RESEARCH.md` | Checked 2026-08-29 | Normalized public-source identity, official six-story + four-story description, white pearlescent asymmetric rainscreen, prior motif research | Project research; not a substitute for a measured elevation |
| `L02` | `discovery/FACADE_RECEIVER_INVENTORY.json` and `.md` | Checked 2026-08-29 | Exact current receiver, orientation groups, material and UV limitations | Project/generated-contract evidence |
| `L03` | `evidence/first-playable/77-bruton-texture-experiment-2026-08-29/` and `evidence/first-playable/77-bruton-texture-v2-2026-08-29/` | Checked 2026-08-29 | Rejection evidence: invented edge window, false period, baked lighting, current exact-wall scale and UV behavior | Prior generated candidates are not reference truth and are not accepted assets |

The panorama observation is distinct from inference: Street View directly shows the address elevation and capture month; mapping it to the generated `side_se` normal comes from comparing the panorama coordinate with the frozen footprint.

## Observed and unobserved facade coverage

### Observed: Bruton/address elevation (`side_se`, inferred mapping)

`reference_observation` from `SV01`:

- A taller upper mass reads as ground floor plus five upper residential rows, consistent with a six-story building.
- Upper openings form aligned vertical stacks. They are tall and oversized, with charcoal/slate frames and muted blue-grey glass.
- Broad light fluted piers separate stacks. Pale, smoother horizontal spandrel/sill bands separate successive upper rows.
- A darker narrow glazed/recessed vertical connector occurs at a volume transition; it is not a normal repeated main-plane bay.
- The upper light material has fine, dense, vertical fluting. The relief frequency is materially finer than a bay or window.
- The ground/arrival level is distinctly darker and more varied: smooth grey fields, darker vertical rib/fins, a wide glazed lobby/storefront, paired glazed entrance doors, a dark service door, and a wide dark garage grille.
- A dark ribbed sign fascia carries the word `HAWKINS` above the glazed entry.
- The lower volume/terrace portion has a deep horizontal slab/rail condition. Its actual projection belongs to massing; this brief may use only a shallow visual proxy.
- The facade is clean and recently completed; no strong stains or aged streaking are visible.

### Observed: owner-photo broad elevation (`side_wsw`, inferred mapping)

`reference_observation` from `P01`:

- The broad main mass has a differentiated darker ground floor plus five upper window rows.
- The main upper plane uses consistent full tall window modules separated by broad fine-fluted light piers.
- Pale horizontal spandrels/sills create a restrained story cadence.
- A darker recessed connector splits large planes and uses a narrower opening family.
- A lower right-hand companion volume uses sparser openings and broader solid fields; it is not the same repeat as the main upper plane.
- The roof edge includes parapet, terrace/pavilion, glass rail, and solar-canopy elements. These are one-off roof/silhouette features, not facade-tile content.
- The light cladding reads silver-grey under the photographed light but is consistent with the authoritative white pearlescent description.

### Unobserved

- `side_ene` as a full elevation.
- `side_nnw` as a full elevation.
- Courtyard-facing elevations, courtyard doors/windows, and private/rear service conditions.
- Exact corner returns, module phase at all four corners, and complete schedules of narrow windows.
- Exact panel layout, manufacturer/profile, rib pitch/depth, coating code, joint schedule, flashing, and weathering.

No unique opening, door, garage, canopy, balcony, sign, vent, or recess may be invented for an unobserved side. The safe fallback is the material-only base/upper zoning described below.

## Region and motif grammar

### Region partition

| Region ID | Scope | Periodicity / output rule |
|---|---|---|
| `U-MAIN` | Main six-story upper planes | Piecewise periodic at a coarse one-complete-window-bay by one-upper-story level. Prefer explicit complete modules over a window-bearing seamless bitmap. |
| `U-NARROW` | Narrow stacks in recesses/connectors | Separate complete motif family; never edge-compose it from fragments of a main window. |
| `U-LOW` | Lower companion/terrace upper planes | Separate short explicit sequence or unique layout. Do not share the `U-MAIN` schedule globally. |
| `G-LOBBY` | Glazed address lobby/entry | Nonperiodic `unique_elevation` zone. |
| `G-SERVICE` | Ribbed service panel, service door, garage grille, smooth base fields | Nonperiodic address-side sequence with complete modules. |
| `G-GENERIC` | Unobserved side base fallback | Material assignment only; no openings. |
| `ROOF` | Parapet, rail, terrace, pavilion, solar canopy, plant | Geometry/silhouette owner; excluded from this facade pass. |

### Motif inventory

| ID | Kind | Complete canonical motif | Edge / placement rule |
|---|---|---|---|
| `P-F` | material field | Fine vertical white/very-light-silver pearlescent fluted rainscreen | Preferred material seam field; rib phase must continue. No frame shadow or panel termination at tile edge. |
| `P-P` | material field | Plain/smooth white pearlescent coated panel field | Homogeneous tile; joints subordinate and never form a facade-scale grid. |
| `B-S` | material field | Smooth medium-dark neutral grey base/podium field | Homogeneous material; no baked door/window or ground line. |
| `B-R` | ribbed field | Darker ground-floor vertical rib/finned screen | Separate pattern/material; complete fin-and-gap period only. Do not reuse upper fine-flute normal at a larger scale. |
| `W-P` | opening module | One complete tall upper opening with complete head, sill, both jambs, charcoal/slate frame, and its internal glass/mullion pattern | Must be a full atlas/module element. No edge fragment. Place on `U-MAIN` only. |
| `W-N` | opening module | One complete genuinely narrow tall opening with both jambs/head/sill | Separate atlas element for explicit connector sequences only. |
| `S-H` | band/module | Complete pale horizontal spandrel/sill band between vertically aligned upper openings | May be its own module or part of a complete `W-P+S-H` story module. Never split so a repeat doubles or drops the band. |
| `R-C` | connector module | Dark recessed vertical connector with narrow glazing stack | Unique/short-sequence placement. Shallow proxy only; no massing recess. |
| `L-G` | lobby glazing module | Complete storefront/lobby glass span with full frame boundary | Address-side unique layout only. |
| `D-P` | door module | Complete paired glazed entrance doors with head, sill/threshold, outer jambs and center meeting rails | Address-side unique layout only. |
| `D-S` | door module | Complete opaque/dark service door | Address-side unique layout only. |
| `G-G` | garage module | Complete wide dark garage grille/door with full surround | Address-side unique layout only. |
| `F-SIGN` | sign fascia module | Complete dark ribbed fascia with the word `HAWKINS` centered as separate shallow letters | One address-side instance. Do not bake text into a repeating tile. |
| `C-B` | shallow band | Thin horizontal entrance/terrace/canopy visual band | Maximum shallow proxy depth only; actual projection remains excluded geometry. |

### Cadence tokens

Main upper plane:

```text
horizontal: ... P-F | W-P | P-F | W-P | P-F ...
vertical:   ... S-H | W-P | S-H | W-P | S-H ...
```

Connector:

```text
... U-MAIN | R-C/W-N stack | U-MAIN or U-LOW ...
```

Address ground floor:

```text
explicit sequence only: B-R / L-G / D-P / F-SIGN / D-S / G-G / B-S
```

The exact horizontal ground-floor order and metre offsets remain a side-specific layout problem; it is not legal to turn that list into a repeating sequence.

## Material brief

All numeric values below are `production_inference` starting bands unless marked otherwise. They are deliberately broad because no measured product data exists.

| Material | Physically plausible game brief | Godot starting values |
|---|---|---|
| Upper fluted pearlescent metal (`P-F`) | Very light warm-neutral to silver-white coated dielectric metal; low chroma; fine vertical relief; satin response that changes under light without mirror glare | Albedo sRGB value about `0.78-0.90`, chroma under about `0.05`; metallic `0.0`; roughness `0.45-0.65`; low-strength `normal_gl`; no height/displacement; no baked highlight/AO |
| Upper plain pearlescent metal (`P-P`) | Same coating family with flat/subtle panel surface; no bay-scale brightness bands | Same albedo/metallic band; roughness `0.48-0.68`; flat or extremely low-amplitude normal |
| Smooth base (`B-S`) | Medium dark neutral grey coated panel/concrete-like field, visually smoother and darker than the upper cladding | Albedo sRGB value `0.32-0.48`; low chroma; metallic `0.0`; roughness `0.62-0.80`; restrained micro-normal |
| Dark ribbed base (`B-R`) | Charcoal/graphite vertical rib or fin field, stronger and wider cadence than the upper fine fluting | Albedo sRGB value `0.22-0.36`; metallic `0.0`; roughness `0.55-0.72`; normal or shallow fins, not painted light/dark stripes |
| Frames / mullions | Charcoal to slate-grey coated metal; complete, slim and consistent | Albedo sRGB value `0.16-0.30`; metallic `0.0`; roughness `0.48-0.68` |
| Glass proxy | Muted dark blue-grey dielectric glass; use an opaque proxy because no interiors exist and the wall must remain opaque/sprayable | Albedo sRGB value `0.18-0.36` with cool bias; metallic `0.0`; roughness `0.12-0.28`; no photographic scenery reflection baked into color |
| Pale spandrel | Light neutral/silver band, quieter than glazing and distinct from fluted pier | Albedo sRGB value `0.68-0.84`; metallic `0.0`; roughness `0.50-0.68` |
| Garage/service | Dark grey grille and door; clean, non-glossy | Albedo sRGB value `0.12-0.28`; metallic `0.0`; roughness `0.58-0.78` |
| Sign letters | Off-white/light grey separate letters, non-emissive by default | Albedo sRGB value `0.75-0.90`; metallic `0.0`; roughness `0.45-0.65` |

Weathering is minimal and subordinate. Reject unique stains, heavy runoff, edge grime, or repeated focal blemishes. The building was completed recently and both direct references read clean.

### Map sets

- `P-F`: `albedo`, `normal_gl`, `roughness` from the same authored surface and scale.
- `P-P`: `albedo`, optional very subtle `normal_gl`, `roughness`.
- `B-S`: `albedo`, subtle `normal_gl`, `roughness`.
- `B-R`: `albedo`, `normal_gl`, `roughness`, or shallow repeated fin geometry; choose one relief owner and do not double it.
- Frames, glass, spandrels, garage and letters: scalar material values are sufficient for the first pass.
- Forbidden: displacement/height that moves the silhouette, ambient-occlusion baked into albedo, unrelated borrowed maps, metalness maps that make the coating conductive, transparency/interior reveal, or scenery reflections baked into glass.

## Physical scale estimates and confidence

| Element | Estimate / bound | Confidence and permitted use |
|---|---|---|
| Real building main mass | Six stories | High `verified_fact`; whole-building reference gate only |
| Real building composition | Six-story mid-rise plus four-story low-rise | High `verified_fact`; massing reference only, not authorized geometry |
| Planned gross height | `70 ft` / `21.34 m` | Medium; pre-completion City/TIDA coarse sanity check, not as-built measurement |
| Gross story band | about `3.1-3.6 m` | Low-medium `production_inference`; module calibration range only |
| Ground/arrival story | about `3.4-4.2 m` | Low `production_inference`; reference comparison only |
| Upper opening outer width | about `1.7-2.3 m` | Low; prototype module range, never a measured claim |
| Upper opening visible height | about `2.2-2.8 m` | Low; prototype module range |
| Main bay pitch | about `3.2-4.2 m` | Low; explicit placement range. Do not revive the rejected `3.8 m` assumption as source evidence. |
| Upper flute pitch | target calibration `0.04-0.08 m`; many flutes per bay | Low; qualitative owner/Street View observation bounded for a prototype |
| Upper flute apparent relief | normal-only or shallow visual amplitude equivalent below `0.02 m` | Low; render calibration, not physical-product claim |
| Dark base rib/fin pitch | target calibration `0.08-0.16 m` | Low; address-side prototype only |
| Shallow module relief | frames/spandrels `0.04-0.10 m`; maximum outward proxy `0.12 m` | Production constraint; prevents the facade pass from becoming massing |
| Garage module | width about `4.5-6.0 m`, height `2.2-2.8 m` | Low; Street View-relative prototype bound |
| Current receiver banding | `3.0 m` base (`y=4.274..7.274`) + `3.0 m` upper (`y=7.274..10.274`) | Exact chosen adaptation to the current `6.0 m` receiver; not a real Hawkins dimension |

### Candidate material repeat scales

- `P-F`: `0.8 m x 1.0 m` candidate tile containing a phase-exact fine-flute field; target roughly `12-20` ribs across the width. Vertical content must remain homogeneous enough that its arbitrary `1.0 m` repeat cannot create a floor band.
- `P-P`: `1.0 m x 1.0 m` homogeneous tile with no visible panel-boundary grid.
- `B-S`: `1.5 m x 1.5 m` homogeneous tile; no ground line or door-like marks.
- `B-R`: smallest cell is one complete rib/fin plus one complete gap, horizontally; vertical field is homogeneous. Use explicit physical pitch in the material/module rather than stretching to fit a bay.

These are bounded first-pass calibration values, not measured product dimensions. The independent receiver review must tune or reject them beside the player and complete door/window modules.

## Output classification and repeat/seam blueprint

### `homogeneous_material_tile`

1. `hawkins_pearl_fluted`
   - Smallest repeat: material field only, candidate `0.8 x 1.0 m`.
   - Full motifs: complete flute cycles only.
   - Legal seams: between complete flute cycles on left/right; any neutral homogeneous point vertically.
   - Expected products: `left+right` recreates the same flute/gap cadence; `top+bottom` and corners remain ordinary field.
   - Forbidden seams: panel termination, shadow/highlight band, joint, stain, window, spandrel, parapet, or story line.

2. `hawkins_pearl_plain`
   - Smallest repeat: homogeneous local coating field, candidate `1.0 x 1.0 m`.
   - All edges legal only when color/roughness/normal fields are phase-neutral.
   - No panel outline is allowed to hit an edge unless a full measured panel period is later established.

3. `hawkins_base_smooth`
   - Smallest repeat: homogeneous local surface, candidate `1.5 x 1.5 m`.
   - No opening, curb, sidewalk, ground contact, joint grid, or directional stain in the tile.

### `architectural_pattern_tile`

4. `hawkins_base_rib_period`
   - Smallest repeat: exactly one complete dark rib/fin plus one complete gap, with explicit pitch in the `0.08-0.16 m` calibration range.
   - Legal seam: mid-gap or a phase-matched repeat boundary.
   - Forbidden: half-fin products, doubled gaps, story bands, sign letters, doors or garage fragments.

No window-bearing `architectural_pattern_tile` is recommended for the first implementation. A one-bay x one-story cell remains only a candidate because no rectified measured schedule proves a universal period and prior whole-cell generation exhausted its correction budget without passing all hard gates.

### `module_atlas`

5. `hawkins_upper_modules`
   - Complete atlas elements: `W-P`, `W-N`, `S-H`, `R-C` shallow proxy.
   - Every element includes its complete frame/band boundary and padding; no element is completed by the atlas edge.
   - Placement is explicit per side/region. Atlas UV borders are not facade seams.

6. `hawkins_ground_modules`
   - Complete atlas/scene elements: `L-G`, `D-P`, `D-S`, `G-G`, `F-SIGN`, `C-B` shallow band.
   - Sign letters are separate geometry/text/decal data, never a repeating texture.
   - Lobby and garage modules may appear only on `side_se` until another side is observed.

### `unique_elevation`

7. `hawkins_side_se_layout`
   - Physical receiver span: `59.440 x 6.000 m` current invariant-safe adaptation.
   - Address-side nonperiodic placement of complete lobby/sign/service/garage modules plus one adapted upper row.
   - It is explicitly **not** a rectified as-built six-story elevation.

8. `hawkins_side_wsw_layout`
   - Physical receiver span: `84.392 x 6.000 m` current invariant-safe adaptation.
   - Preserve the owner-photo regional idea: main full-window cadence, one explicit connector break, then a sparser low-volume cadence. Use only one adapted upper row on the unchanged receiver.
   - It is explicitly **not** an as-built elevation.

9. `hawkins_side_ene_fallback` and `hawkins_side_nnw_fallback`
   - Physical spans: `60.138 x 6.000 m` and `55.007 x 6.000 m`.
   - Material assignment only: dark smooth base band below `y=7.274`, light fluted/plain upper band above. No unique openings, doors, garage, sign, balcony, recess, or canopy.

### Legal and forbidden facade seams

Legal:

- Within an uninterrupted homogeneous `P-F`, `P-P`, or `B-S` field whose albedo/normal/roughness phase matches.
- At the explicit boundary between the complete `3.0 m` current-receiver base band and complete `3.0 m` upper band.
- At a side corner only when both side layouts end in ordinary material field with no clipped module.
- Between complete explicitly placed modules with their full frames/spandrels intact.

Forbidden:

- Any of the current `20` foundation-subdivision U resets becoming a facade module reset.
- A seam through glass, frame, mullion, jamb, sill, spandrel, door, sign, garage grille, rib/fin, connector, canopy proxy, panel termination, joint, or stain.
- Any boundary product that creates a narrower/wider window, doubled/missing mullion, doubled/missing spandrel, half door, clipped garage, half sign letter, doubled fin, or four-way focal mark.
- Wrapping the `U-MAIN` cadence through a connector, low companion plane, ground zone, corner, unobserved side, or roof.

## Godot module and material bill of materials

Proposed stable paths are a later implementation contract; this task creates none of them.

| ID | Proposed path | Godot form | Classification / contents |
|---|---|---|---|
| `MAT-PF` | `res://game/resources/materials/world/hawkins/hawkins_pearl_fluted.tres` | `StandardMaterial3D` or bounded custom shader | `homogeneous_material_tile`; albedo + normal_gl + roughness |
| `TEX-PF` | `res://game/resources/textures/world/hawkins/pearl_fluted/` | three texture maps | Same-source albedo/normal_gl/roughness; mipmapped repeat |
| `MAT-PP` | `res://game/resources/materials/world/hawkins/hawkins_pearl_plain.tres` | `StandardMaterial3D` | `homogeneous_material_tile` |
| `MAT-BS` | `res://game/resources/materials/world/hawkins/hawkins_base_smooth.tres` | `StandardMaterial3D` | `homogeneous_material_tile` |
| `MAT-BR` | `res://game/resources/materials/world/hawkins/hawkins_base_ribbed.tres` | material or shallow repeated fin mesh | `architectural_pattern_tile` with one complete rib/gap period |
| `MAT-FR` | `res://game/resources/materials/world/hawkins/hawkins_frame_charcoal.tres` | scalar `StandardMaterial3D` | Frames/mullions |
| `MAT-GL` | `res://game/resources/materials/world/hawkins/hawkins_glass_proxy.tres` | opaque scalar `StandardMaterial3D` | Muted blue-grey glass proxy; no interior/transparency |
| `MAT-SH` | `res://game/resources/materials/world/hawkins/hawkins_spandrel_pale.tres` | scalar `StandardMaterial3D` | Pale spandrel/sill |
| `MAT-GG` | `res://game/resources/materials/world/hawkins/hawkins_garage_dark.tres` | scalar `StandardMaterial3D` | Garage/service |
| `MOD-U` | `res://game/scenes/world/facades/hawkins/hawkins_upper_modules.tscn` | `Node3D` library of shallow `MeshInstance3D` children | Complete `W-P`, `W-N`, `S-H`, `R-C` modules |
| `MOD-G` | `res://game/scenes/world/facades/hawkins/hawkins_ground_modules.tscn` | `Node3D` library | Complete `L-G`, `D-P`, `D-S`, `G-G`, `F-SIGN`, `C-B` modules |
| `LAYOUT` | `res://game/resources/facades/hawkins_77_bruton_layout.json` | side-local placement/material manifest | Four `unique_elevation` layouts keyed to exact receiver and side endpoints |
| `ATTACH` | `res://game/scenes/world/facades/hawkins_77_bruton_facade.tscn` | target-specific noncolliding visual child | Material fields plus placed modules; exact receiver key metadata |

### Module construction constraints

- One Godot unit equals one metre.
- All modules are render-only: no `StaticBody3D`, `CollisionShape3D`, navigation, occluder, or spray receiver group.
- Set module visual layers so the existing spray `Decal` can project across them while ray selection still resolves to the unchanged underlying `building:w1249412093:wall` collision.
- Offset coplanar fields only enough to prevent z-fighting (`0.01-0.02 m`); keep frame/spandrel/fin relief inside the `0.12 m` outward envelope.
- Never extend a module beyond a side endpoint, top `y=10.274`, or the existing roof/footprint silhouette.
- Foundation extensions below flat base `y=4.274` keep base material and receive no doors/windows.
- Use side-local world-space coordinates from the canonical endpoints, not serialized UV U, for all module placement.
- Keep modules cacheable/reusable, but keep the side layout target-specific and keyed to `w1249412093`.

## Geometry-versus-texture boundary

### Owned by this facade pass

- Surface color, roughness, and low-amplitude normal response.
- Complete shallow frames, mullions, spandrels, door/glass/garage proxies, rib/fins, and sign letters within the stated relief envelope.
- Side-specific material zoning and explicit module placement.
- Visual variation that remains subordinate to the references and does not alter collision.

### Explicitly excluded

- Six-story/four-story height correction, story count, roof height, parapet, terrace slab, deep canopy, balconies, setbacks, interlocking volumes, courtyard, recess depth, silhouette, or footprint.
- Window/door holes, interior visibility, true recessed glazing, or structural openings.
- Collision, spray ray target, spray eligibility, collider groups/layers/metadata, terrain, foundations, roof receiver status, navigation, or player access.
- Generated OSM/chunk/coverage/logical-object contracts, source hashes, receiver IDs, or generator output.
- Real private/fenced access, interiors, apartments, rooms, or floor plans.

### Representative before -> after preserving invariants

```text
before: building:w1249412093:wall is one 6.0 m-high, 258.977 m-perimeter,
        20-foundation-segment generated wall using shared plaster_grey_04;
        its unchanged StaticBody3D is the opaque spray_receiver_wall.

after:  that exact generated wall, height, roof, footprint, terrain foundations,
        collision, spray receiver, source IDs and generated bytes remain unchanged;
        a target-specific noncolliding visual child keyed to w1249412093 adds
        side-continuous Hawkins materials and complete shallow modules, with
        conservative material-only treatment on unobserved sides.
```

This before/after does not claim to repair the real six-story/four-story massing. The whole-object resemblance verdict must remain blocked while the no-massing-change invariant is in force.

## Implementation sequence for a later executor

1. Re-read this brief and `discovery/FACADE_RECEIVER_INVENTORY.json`; assert receiver/source identity before creating assets.
2. Author the three homogeneous tile candidates and the base-rib period independently. Build mechanical repeat proofs before any module work.
3. Independently review materials under neutral and changed light. Reject baked rib lighting or facade-scale repeats.
4. Author complete shallow upper and ground modules with the stated physical ranges. Do not derive them by cropping a generated whole facade.
5. Build one side-local attachment scene and one layout manifest. Attach only when the exact receiver metadata includes `w1249412093` and derived key `building:w1249412093:wall`.
6. Use canonical side endpoints and continuous world-space `u`; verify no phase reset at any of the `20` foundation subdivisions.
7. Apply observed-specific modules only to `side_se` and `side_wsw`. Apply material-only fallback to `side_ene` and `side_nnw`.
8. Validate collision/source/spray invariants before rendered review.
9. Capture close, ordinary-play, oblique, changed-light, and whole-object views on the exact receiver. Keep material, module, receiver, and whole-object verdicts separate.
10. Stop rather than alter height/story/massing. Any future proposal to repair those items requires a separate exact before -> after and explicit owner approval.

## Executable acceptance checklist

### Implementer gates

- [ ] `git diff -- generated/world data/osm` shows no changes.
- [ ] `w1249412093`, `building:w1249412093`, `building:w1249412093:wall`, chunk `x_-1__z_1`, height `6.0`, base `4.274`, top `10.274`, `20` foundation segments, `40` wall triangles and roof object all remain exact.
- [ ] Runtime receiver path resolves and its `Collision` remains the only collider for the facade.
- [ ] No facade child joins `spray_receiver_wall` or adds a physics body/shape.
- [ ] A spray ray on a module-covered area still resolves to `building:w1249412093:wall`, and the decal remains visible across the visual child.
- [ ] Material tiles contain no windows, doors, spandrels, signs, ground line, roof line, panel-scale focal joint, or unique stain.
- [ ] Borderless `3x3`, half-X/Y/XY roll and `8x8` macro proofs preserve every material period and expose no seam, band, four-way mark or cloned focal feature.
- [ ] Every atlas/module element is complete; no jamb, mullion, sill, band, door, garage, letter, rib or fin is completed by a texture edge.
- [ ] `side_se` and `side_wsw` placements use continuous side-local coordinates and do not reset at foundation segments.
- [ ] `side_ene` and `side_nnw` contain no invented unique module.
- [ ] Base/upper adaptation is exactly `y=4.274..7.274` and `y=7.274..10.274`; modules stay below `y=10.274` and within side endpoints.
- [ ] Coplanar offset is `0.01-0.02 m`; maximum shallow relief is at or below `0.12 m`.
- [ ] No silhouette, roof, story count, massing, footprint, terrain, foundation, collision, navigation, or generated contract changes occur.
- [ ] Current scene-parse, generated-world, material, gameplay, spray and full-runtime contracts pass after integration.
- [ ] Close, ordinary gameplay, oblique and changed-light captures are retained with exact pose/receiver identity and absolute verdicts.

### Independent reviewer gates

- [ ] Confirm the reviewed object is the exact Hawkins receiver, not a generic test wall.
- [ ] Compare `side_se` against `SV01` and `side_wsw` against `P01`; do not use rejected candidates as appearance truth.
- [ ] Grade identity, material, module grammar, receiver behavior and whole-object resemblance separately.
- [ ] Reject medium-grey plaster, coarse bay-scale ribs, mirror-like metal, heavy grime, baked highlights/shadows, photographic glass reflections, or one uniform window cadence over all regions.
- [ ] Reject any new/resized/duplicated/deleted motif at a seam, regardless of pixel edge metrics.
- [ ] Reject any facade cadence restart at one of the `20` foundation subdivisions or a corner-clipped module.
- [ ] Reject any unique door/garage/sign/recess on the unobserved sides.
- [ ] Verify lobby, service door, garage, and `HAWKINS` sign appear once and only on the address layout.
- [ ] Verify actual Hawkins reads as the material/cadence reference, while the integrated whole-object verdict is explicitly limited by the unchanged `6.0 m` mass.
- [ ] Do not accept “better than grey plaster” as an absolute facade or whole-building verdict.
- [ ] Mark whole-building Hawkins resemblance `blocked_by_current_massing_invariant`, even if the bounded facade-language pass succeeds.

## Explicit unknowns and safe fallbacks

| Unknown | Impact | Safe fallback | Stop condition |
|---|---|---|---|
| Exact manufacturer/profile, rib pitch/depth, coating code | Prevents measured material claim | Use bounded fine-flute prototype and label inference | Stop if a manufacturer-accurate claim is requested |
| Rectified as-built elevations and bay schedule | Prevents metre-exact unique facade | Use complete modules and reference-relative visual calibration | Stop if exact as-built placement is required |
| Complete ENE/NNW/courtyard coverage | Prevents unique motifs on those sides | Material-only base/upper zoning | Stop if those sides need building-specific doors/windows |
| Exact corner return/phase | Prevents carrying modules around corners | End each side in ordinary material field | Stop if a module must cross a corner |
| Real six-story/four-story geometry on current receiver | Prevents whole-building resemblance | Preserve `6.0 m` mass and make only a two-band facade-language adaptation | Always stop before changing massing under this brief |
| Real transparency/interiors behind glass | Prevents transparent glazing | Use opaque blue-grey glass proxy | Stop if interior visibility is requested |

## Normalized research handoff

```yaml
schema_version: codex.building-texture-research/1
job:
  job_id: hawkins_77_bruton_facade_reference_spec
  checked_date: 2026-08-29
  intended_use: invariant_safe_building_specific_facade_language_for_current_godot_receiver
  target_asset_kind: module_atlas

target:
  canonical_name: Hawkins / 77 Bruton Street
  local_object_ids: [w1249412093, building:w1249412093, building:w1249412093:wall]
  identity_confidence: high
  receiver_path: WorldRoot/PlayableWorld/Buildings/x_-1__z_1__building_w1249412093_wall/building_w1249412093_wall

sources:
  - id: P01
    authority: owner_reference
    url_or_local_path: /Users/philipp/Downloads/IMG_7170.HEIC
    checked_date: 2026-08-29
    page_or_section: full_image_via_existing_local_temp_conversion
    supports: [identity_context, broad_wsw_elevation, region_cadence, material_character]
    does_not_support: [metric_dimensions, rectified_elevation, exact_panel_product]
    image_reuse_permission: owner_private
    stored_in_repo: false
  - id: SV01
    authority: secondary
    url_or_local_path: https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8191991,-122.3715368&heading=311.09&pitch=0&fov=75
    checked_date: 2026-08-29
    page_or_section: official_google_street_view_panorama_CqLfgqkDJF4LkB8NhgB1NQ_capture_Sep_2025
    supports: [address_elevation, lobby, garage, upper_stack, cladding_rhythm, displayed_capture_date]
    does_not_support: [rear_courtyard_sides, exact_dimensions, reuse_rights]
    image_reuse_permission: unknown
    stored_in_repo: false
  - id: L01
    authority: project
    url_or_local_path: discovery/FACADE_RECEIVER_INVENTORY.json
    checked_date: 2026-08-29
    page_or_section: facade-receiver:w1249412093
    supports: [exact_receiver, dimensions, orientations, material_and_uv_contract]
    does_not_support: [real_facade_appearance]
    image_reuse_permission: not_needed
    stored_in_repo: false
  - id: L02
    authority: project
    url_or_local_path: discovery/TEXTURE_REFERENCE_RESEARCH.md
    checked_date: 2026-08-29
    page_or_section: hawkins_worked_example
    supports: [public_identity, verified_six_and_four_story_massing, pearlescent_rainscreen, coarse_scale_bounds]
    does_not_support: [rectified_as_built_elevation, exact_product_dimensions]
    image_reuse_permission: not_needed
    stored_in_repo: false
  - id: L03
    authority: project
    url_or_local_path: evidence/first-playable/77-bruton-texture-experiment-2026-08-29/
    checked_date: 2026-08-29
    page_or_section: rejected_candidate_and_exact_receiver_evidence
    supports: [rejection_example, current_uv_reset_behavior, false_repeat_failure]
    does_not_support: [accepted_appearance, real_facade_dimensions]
    image_reuse_permission: not_needed
    stored_in_repo: false

reference_roles:
  identity_context: [P01, L01, L02]
  massing: [P01, L02]
  pattern_region: [P01, SV01]
  cadence_and_seams: [P01, SV01]
  material_surface: [P01, SV01]
  scale: [L01, L02]
  rejection_example: [L03]

pattern_regions:
  - region_id: U-MAIN
    local_scope: observed_main_upper_planes
    periodicity: candidate_periodic
    must_not_share_tile_with: [U-NARROW, U-LOW, G-LOBBY, G-SERVICE, ROOF]
  - region_id: U-NARROW
    local_scope: observed_connector_stacks
    periodicity: nonperiodic
    must_not_share_tile_with: [U-MAIN]
  - region_id: G-LOBBY_SERVICE
    local_scope: address_side_ground_floor
    periodicity: nonperiodic
    must_not_share_tile_with: [all_other_regions]

motif_inventory:
  - motif_id: P-F
    kind: rib
    canonical_full_description: fine_vertical_white_pearlescent_fluted_field
    dimensions_m: {width: null, height: null}
    ratios: {width_to_period: null, height_to_period: null, tolerance: bounded_0.04_to_0.08_m_candidate_pitch}
    evidence_status: reference_observation
    may_cross_edge: true
    edge_composition_contract: same_rib_gap_phase_only
  - motif_id: W-P
    kind: opening
    canonical_full_description: complete_tall_upper_window_with_head_sill_both_jambs_frame_glass_and_mullions
    dimensions_m: {width: null, height: null}
    ratios: {width_to_period: null, height_to_period: null, tolerance: prototype_width_1.7_to_2.3_m_height_2.2_to_2.8_m}
    evidence_status: production_inference
    may_cross_edge: false
    edge_composition_contract: null
  - motif_id: W-N
    kind: opening
    canonical_full_description: complete_narrow_connector_window
    dimensions_m: {width: null, height: null}
    ratios: {width_to_period: null, height_to_period: null, tolerance: unknown}
    evidence_status: reference_observation
    may_cross_edge: false
    edge_composition_contract: null
  - motif_id: G-G
    kind: door
    canonical_full_description: complete_wide_garage_grille_with_full_surround
    dimensions_m: {width: null, height: null}
    ratios: {width_to_period: null, height_to_period: null, tolerance: prototype_width_4.5_to_6.0_m_height_2.2_to_2.8_m}
    evidence_status: production_inference
    may_cross_edge: false
    edge_composition_contract: null

motif_sequences:
  - region_id: U-MAIN
    axis: horizontal
    token_sequence: P-F | W-P | P-F | W-P | P-F
    evidence_status: reference_observation
  - region_id: U-MAIN
    axis: vertical
    token_sequence: S-H | W-P | S-H | W-P | S-H
    evidence_status: reference_observation

repeat_blueprint:
  region_id: U-MAIN
  smallest_cell_status: candidate
  period_tokens_horizontal: one_complete_W-P_bay_plus_allocated_P-F
  period_tokens_vertical: one_upper_story_plus_complete_S-H_allocation
  period_m: {x: null, y: null}
  cell_contents_full_motifs: [W-P, S-H, P-F]
  edge_fragments: {left: [], right: [], top: [], bottom: []}
  edge_compositions_expected:
    left_plus_right: [homogeneous_P-F_only]
    top_plus_bottom: [homogeneous_S-H_or_material_field_only]
    corners: [ordinary_material_field_only]
  legal_seam_zones: [middle_of_phase_matched_P-F, middle_of_homogeneous_S-H]
  forbidden_seam_zones: [glass, frame, mullion, jamb, sill, door, garage, sign, connector, panel_termination, current_foundation_uv_reset]
  fallback_if_not_proven: module_atlas

material_brief:
  surface_family: white_pearlescent_coated_metal_rainscreen_plain_and_fine_fluted
  base_color: very_light_warm_neutral_to_silver_white
  finish: satin_directional_clean_recent
  relief_direction_and_frequency: fine_vertical_many_cycles_per_window_bay
  roughness: production_starting_band_0.45_to_0.65
  variation_and_weathering: very_low_amplitude_no_unique_stain_no_baked_light
  maps_requested: [albedo, normal_gl, roughness]
  maps_forbidden: [height_displacement, baked_ao, unrelated_borrowed_maps, photographic_reflections]
  tile_scale_status: bounded
  tile_scale_m: {x: 0.8, y: 1.0}

excluded_architectural_features:
  - {feature: six_and_four_story_massing, owner: geometry, reason: explicitly_invariant}
  - {feature: parapet_terrace_solar_canopy_deep_canopy, owner: geometry, reason: silhouette_or_depth_bearing}
  - {feature: window_and_door_holes, owner: geometry, reason: no_interior_or_collision_change}
  - {feature: observed_complete_openings_and_ground_modules, owner: facade_module, reason: explicit_complete_module_placement}

uncertainty:
  - unknown: exact_manufacturer_profile_rib_pitch_and_coating_code
    impact: no_measured_material_claim
    safe_fallback: bounded_fine_flute_prototype
    stop_if_required: true
  - unknown: full_ENE_NNW_and_courtyard_elevations
    impact: no_unique_modules_on_those_sides
    safe_fallback: material_only_base_upper_zoning
    stop_if_required: true
  - unknown: rectified_as_built_elevation
    impact: no_metre_exact_module_schedule
    safe_fallback: complete_modules_and_reference_relative_calibration
    stop_if_required: true

hard_mismatch_gates:
  - scope: identity
    reject_if: receiver_is_not_building_w1249412093_wall
    proof_required: runtime_metadata_and_source_key_capture
  - scope: repeat
    reject_if: any_boundary_creates_resizes_duplicates_or_deletes_a_motif
    proof_required: tokenized_3x3_roll_and_macro_proofs
  - scope: geometry
    reject_if: silhouette_story_massing_collision_foundation_terrain_roof_or_generated_contract_changes
    proof_required: generated_diff_runtime_contract_and_whole_object_capture
  - scope: module
    reject_if: unique_module_is_invented_on_unobserved_side_or_crosses_side_boundary
    proof_required: side_local_layout_audit
  - scope: material
    reject_if: medium_grey_plaster_bay_scale_ribs_baked_lighting_or_heavy_weathering
    proof_required: neutral_and_changed_light_receiver_views

research_verdict:
  ready_for_generation: true
  recommended_output_kind: module_atlas
  blockers:
    - whole_building_resemblance_blocked_by_unchanged_6m_massing
    - metric_as_built_elevation_blocked_by_missing_rectified_schedule
    - unique_unobserved_side_facades_blocked_by_missing_coverage
```

## Final research status

- Ready for a bounded homogeneous material batch: **yes**.
- Ready for deterministic complete shallow module authoring: **yes**, within the stated prototype ranges.
- Ready for an address-side current-receiver `unique_elevation` adaptation: **yes**, with the non-as-built limitation attached.
- Ready for unique ENE/NNW/courtyard motifs: **no**.
- Ready for a faithful whole-building Hawkins claim on the current receiver: **no**; blocked by the explicit no-massing/story-change invariant.
