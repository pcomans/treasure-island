# Hawkins / 77 Bruton Street massing implementation specification

Checked: **2026-08-29**

Mode: **approved change specification and proof only; no implementation in this round**

Target: **Hawkins, 77 Bruton Street, frozen OSM `w1249412093`**

Runtime wall receiver: **`building:w1249412093:wall`**

Runtime roof object: **`building:w1249412093:roof`**

## Implementation verdict

The approved Hawkins-only massing correction is implementation-ready as a deterministic runtime override of the unchanged frozen/generated source records.

The target shape is exactly two complementary volumes over the current four-corner footprint:

| Volume | Exact footprint polygon, ordered in current roof-ring order | Stories | Assumed height | World top Y |
|---|---|---:|---:|---:|
| `main_six_story` | `[A, P, Q, C, D]` | `6` | `21.000 m` | `25.274 m` |
| `companion_four_story` | `[P, B, Q]` | `4` | `14.000 m` | `18.274 m` |

The polygons share only edge `P -> Q`; their interiors do not overlap, their union is the exact existing OSM-derived footprint, and their summed area is exactly the existing quantized polygon area. The correction adds no third volume. The actual terrace/pavilion, solar canopy, courtyard articulation, parapets, and roof furniture remain outside this bounded pass.

The exact production assumption is **`3.500 m` gross per story**. This is a reversible game approximation inside the previously documented `3.1-3.6 m` production range. Six stories therefore produce `21.000 m`, within `0.34 m` of the pre-completion planned `70 ft / 21.34 m` gross-height sanity check. It is not an as-built measurement.

## Approval and decision boundary

The owner explicitly approved this exact class of change on **2026-08-29** in the current Codex task; the approval was relayed verbatim in the bounded `/root/hawkins_massing_spec` delegation:

```text
Before: one flat 6 m Hawkins extrusion
After:  a Hawkins-only stepped mass matching the observed six-story main block
        and lower companion volume, with collision and spray surfaces raised to
        match; footprint, terrain, foundation, gameplay, and every other
        building stay unchanged.
```

That approval authorizes the two-height Hawkins override specified here. It does **not** authorize a third mass, courtyard cutout, setback, balcony, roof pavilion, solar canopy, deep canopy, terrain edit, footprint edit, generator edit, facade restyle, new gameplay behavior, or any other building change.

## Evidence roles and provenance

No web access, download, image generation, install, game launch, export, or external account was used for this specification round.

| ID | Evidence | Role | Limit |
|---|---|---|---|
| `P01` | Owner-private `/Users/philipp/Downloads/IMG_7170.HEIC`, inspected through the existing private conversion `/private/tmp/IMG_7170-reference.png`; expected SHA-256 `6b6a0f95902bd48c57c4f69b6bd7b97346c672d71c1b300d394170f6447db5cd` | Directly shows ground plus five upper rows on the main mass, a visibly lower companion, a vertical transition, and the roof/terrace context on the mapped WSW elevation | Perspective photograph, not a rectified elevation or survey; remains outside the repository and must not be uploaded or redistributed |
| `SV01` | Retained official Street View observations in `HAWKINS_77_BRUTON_REFERENCE_SPEC.md`; panorama `CqLfgqkDJF4LkB8NhgB1NQ`, UI date Sep 2025 | Address-side full-height stack, lower/terrace transition, lobby/service program, and mapped SE connector | Observational notes only; no imagery is stored; does not provide metric plan or elevation data |
| `H03` | City source recorded in `TEXTURE_REFERENCE_RESEARCH.md` | Verifies Hawkins is six stories | Does not establish sub-volume plan or as-built height |
| `H04` | Developer/property-manager source recorded in `TEXTURE_REFERENCE_RESEARCH.md` | Verifies six-story mid-rise plus four-story low-rise | Does not establish exact dimensions or the cut line |
| `H07` | City/TIDA pre-completion source recorded in `TEXTURE_REFERENCE_RESEARCH.md` | Planned `70 ft / 21.34 m` coarse height sanity check | Planned gross value, not an as-built wall or story-height measurement |
| `L01` | `game/resources/facades/hawkins_77_bruton_layout.json` | Accepted side-local module schedules and the exact two connector coordinates `WSW u=60.4 m`, `SE u=33.0 m` | Reference-relative facade layout, not survey data |
| `L02` | `evidence/first-playable/77-bruton-facade-correction-2026-08-29/` | Accepted facade language, exact current receiver behavior, hashes, and comparable capture poses | Explicitly blocks whole-building resemblance on the old `6.0 m` mass |
| `L03` | Frozen OSM, generated chunk, logical-object index, coverage ledger, and receiver inventory listed below | Exact game footprint, source identity, terrain foundations, current mesh and receiver state | Proves the game contract, not real vertical form |

The split line is therefore an **evidence-bounded production inference**: its endpoints reuse the already accepted visible connector positions rather than introducing a new eyeballed ratio. It is deterministic and coherent with the accepted facade layout, but it must never be described as an as-built property boundary or surveyed volume edge.

## Current exact source and runtime state

### Frozen source identity

- Frozen way: `1249412093`, canonical source key `w1249412093`, version `3`, timestamp `2025-04-06T04:37:54Z`.
- Tags: `building=apartments`, `name=Hawkins`; no OSM `height`, `building:levels`, address, material, or facade tag.
- OSM ring node order: `11612843864 -> 11612843863 -> 11612843862 -> 11612843861 -> 11612843864`.
- The source row is line `732` of `data/osm/treasure-island-source-inventory.csv`.
- The coverage row is line `732` of `generated/world/coverage-ledger.csv`: `represented`, `direct`, `default_6m`, chunk `x_-1__z_1`.
- Logical object: `building:w1249412093`; physical keys remain exactly `building:w1249412093:wall` and `building:w1249412093:roof`.
- Generated representation files are authoritative inputs and must remain byte-for-byte unchanged:
  - `generated/world/chunks/x_-1__z_1.json`
  - `generated/world/logical-objects.json`
  - `generated/world/manifest.json`
  - `generated/world/coverage-ledger.csv`
  - all `data/osm/**` files.
- Current retained hashes:
  - target chunk SHA-256 `b8696d4feb4157d39969ec039e610af572f25510d712c802d4a96943d6069c8c`;
  - generated manifest SHA-256 `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`;
  - generated content SHA-256 `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`;
  - receiver geometry SHA-256 in the inventory `611ed64a5fd1f359553f14649504b553eda17707057eefe536dac61cd4168311`.

### Current footprint and four canonical runs

One Godot unit is one metre. The exact quantized local XZ footprint is:

| Vertex | Local XZ (m) | Frozen OSM node | Frozen lat/lon |
|---|---|---|---|
| `A` | `(-118.795, 451.595)` | `11612843864` | `37.8190332, -122.3718958` |
| `B` | `(-79.648, 526.358)` | `11612843863` | `37.8194431, -122.3714626` |
| `C` | `(-41.556, 480.728)` | `11612843862` | `37.8199220, -122.3717791` |
| `D` | `(-69.387, 427.417)` | `11612843861` | `37.8197048, -122.3723410` |

| Side | Directed run | Exact computed length | Serialized/inventory length | Outward normal XZ | Source foundation subdivisions |
|---|---|---:|---:|---|---:|
| `side_wsw` | `A -> B` | `84.391906 m` | `84.392 m` | `(-0.886, 0.464)` | `7` |
| `side_se` | `B -> C` | `59.439863 m` | `59.440 m` | `(0.768, 0.641)` | `3` |
| `side_ene` | `C -> D` | `60.138401 m` | `60.138 m` | `(0.886, -0.463)` | `6` |
| `side_nnw` | `D -> A` | `55.006601 m` | `55.007 m` | `(-0.440, -0.898)` | `4` |

- Quantized polygon area: `3970.518806 m²`; serialized/source inventory rounds to `3970.51 m²`.
- Computed exterior perimeter: `258.976771 m`; serialized perimeter is `258.976 m` and receiver-inventory wall reconstruction is `258.977 m`.
- The roof record is the four vertices `[A, B, C, D]`, `4` vertices, `2` triangles.
- The wall record has `80` vertices, `40` triangles, `20` exterior foundation quads, and `0` shared-wall quads.

### Current terrain-aware foundation runs

The first number after each XZ point is its current wall-bottom Y. All tops are currently `10.274`. These exact source subdivisions are inputs to the runtime override; they are not regenerated or replaced.

| Index | Side | Start XZ/Y -> end XZ/Y | Length |
|---:|---|---|---:|
| `0` | WSW | `(-118.795,451.595)/4.274 -> (-112.197,464.197)/4.274` | `14.225` |
| `1` | WSW | `(-112.197,464.197)/4.274 -> (-103.922,480.000)/4.274` | `17.838` |
| `2` | WSW | `(-103.922,480.000)/4.274 -> (-101.199,485.199)/4.274` | `5.869` |
| `3` | WSW | `(-101.199,485.199)/4.274 -> (-96.000,495.129)/4.274` | `11.209` |
| `4` | WSW | `(-96.000,495.129)/4.274 -> (-90.202,506.202)/4.222` | `12.499` |
| `5` | WSW | `(-90.202,506.202)/4.222 -> (-87.166,512.000)/4.226` | `6.545` |
| `6` | WSW | `(-87.166,512.000)/4.226 -> (-79.648,526.358)/4.043` | `16.207` |
| `7` | SE | `(-79.648,526.358)/4.043 -> (-67.663,512.000)/4.156` | `18.703` |
| `8` | SE | `(-67.663,512.000)/4.156 -> (-64.000,507.613)/4.132` | `5.715` |
| `9` | SE | `(-64.000,507.613)/4.132 -> (-41.556,480.728)/4.232` | `35.022` |
| `10` | ENE | `(-41.556,480.728)/4.232 -> (-41.936,480.000)/4.227` | `0.821` |
| `11` | ENE | `(-41.936,480.000)/4.227 -> (-49.504,465.504)/4.234` | `16.353` |
| `12` | ENE | `(-49.504,465.504)/4.234 -> (-58.641,448.000)/4.274` | `19.745` |
| `13` | ENE | `(-58.641,448.000)/4.274 -> (-60.479,444.479)/4.274` | `3.972` |
| `14` | ENE | `(-60.479,444.479)/4.274 -> (-64.000,437.735)/4.274` | `7.608` |
| `15` | ENE | `(-64.000,437.735)/4.274 -> (-69.387,427.417)/4.274` | `11.640` |
| `16` | NNW | `(-69.387,427.417)/4.274 -> (-81.196,433.196)/4.274` | `13.147` |
| `17` | NNW | `(-81.196,433.196)/4.274 -> (-96.000,440.440)/4.274` | `16.481` |
| `18` | NNW | `(-96.000,440.440)/4.274 -> (-111.448,448.000)/4.274` | `17.199` |
| `19` | NNW | `(-111.448,448.000)/4.274 -> (-118.795,451.595)/4.274` | `8.179` |

### Current height, roof, collision, spray, and facade state

- Generated rule/height: `default_6m`, height `6.000 m`, flat base `4.274 m`, current top `10.274 m` NAVD 88.
- Runtime wall path: `WorldRoot/PlayableWorld/Buildings/x_-1__z_1__building_w1249412093_wall/building_w1249412093_wall`.
- Runtime roof path: `WorldRoot/PlayableWorld/Buildings/x_-1__z_1__building_w1249412093_roof/building_w1249412093_roof`.
- Each physical object currently owns one `MeshInstance3D` named `Mesh`, one `StaticBody3D` named `Collision`, and one `CollisionShape3D` named `Shape` using `ConcavePolygonShape3D` faces copied from its runtime-wound mesh.
- Wall body metadata: `receiver_kind=building_wall`, `opaque=true`, `derived_object_key=building:w1249412093:wall`, `source_keys=[w1249412093]`; it is in `spray_receiver_wall`.
- Wall body collision layer is `PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE = 1 | 4 = 5`; collision mask is `0`.
- Roof body is also opaque and therefore on layer `5`, but has `receiver_kind=none` and is **not** in `spray_receiver_wall`; a spray ray can first-hit it and the controller must reject it as an ineligible receiver.
- Wall mesh and every accepted facade visual use render layer `RENDER_BUILDING_WALL = 2`. Roof mesh uses `RENDER_WORLD_VISIBLE = 1`. Spray decals use cull mask `2`.
- Current target facade is accepted with documented massing limitation. Layout SHA-256 is `2debe810737a98fef19ceaa0bfe6ec241abf3cafdcac3aea8f005eed42cdd8e6`; deterministic facade signature is `6fc4d5aee82a5a496c3e77d3752fe07f18e798a1dba4364a3671fccc8d0d8161`.
- Current facade remains render-only, maximum relief `0.05 m`, no collision/navigation/occluder/spray group, and uses the underlying wall body for ray selection. Accepted current module counts are `W-P=30`, `S-H=30`, `R-C=2`, `W-N=2`, `G-W=17`, and one each of `L-G`, `D-P`, `F-SIGN`, `C-B`, `D-S`, `G-G`.
- `discovery/FACADE_RECEIVER_INVENTORY.json` predates the accepted Hawkins facade integration. Its source, footprint, massing, receiver, material-assignment, and run geometry remain authoritative; its `current runtime texture` status is historical and must not be used to erase the later accepted facade evidence.

## Exact subdivision contract

### One source of truth for the split

The massing split must reuse the accepted facade connector coordinates, not a new screen-space measurement:

```text
P = A + normalize(B - A) * 60.400
Q = B + normalize(C - B) * 33.000
```

Using the exact quantized endpoints above:

| Point | Source side coordinate | Normalized side coordinate | Exact computed XZ |
|---|---:|---:|---|
| `P` | WSW `u=60.400 m` | `60.4 / |A-B| = 0.7157084482` | `(-90.7771613773, 505.1035107148)` |
| `Q` | SE `u=33.000 m` | `33.0 / |B-C| = 0.5551829715` | `(-58.4999702509, 501.0250010119)` |

Runtime geometry must compute `P` and `Q` from the formula and full-precision endpoints. Three-decimal forms `P=(-90.777,505.104)` and `Q=(-58.500,501.025)` are display values only, not a second source of truth.

The exact polygons are:

```text
outer footprint: [A, B, C, D]
main footprint:  [A, P, Q, C, D]
lower footprint: [P, B, Q]
shared edge:     P -> Q
```

`main` owns the `P -> Q` step face. Its outward XZ normal toward the lower volume is `(0.1253620420, 0.9921110615)` and the shared-edge length is `32.533848657 m`.

### Footprint-preservation proof

Using the shoelace formula on the exact points:

| Polygon | Area |
|---|---:|
| Existing `[A,B,C,D]` | `3970.518805999996 m²` |
| Main `[A,P,Q,C,D]` | `3604.806003192094 m²` |
| Companion `[P,B,Q]` | `365.712802807902 m²` |
| Main + companion | `3970.518805999996 m²` |
| Area delta | **`0.000000000000 m²`** |

The outer boundary remains `A -> B -> C -> D -> A`. `P` lies exactly on `A -> B`, `Q` lies exactly on `B -> C`, and `P -> Q` is internal. Therefore the union preserves both footprint and exterior perimeter exactly. No point moves outside the current OSM polygon and no terrain is newly covered or uncovered.

Recommended deterministic roof triangulation in ring order:

```text
main vertices: [A, P, Q, C, D]
main faces:    [A,P,Q], [A,Q,C], [A,C,D]
lower vertices:[P, B, Q]
lower face:    [P,B,Q]
```

All four face areas are positive (`920.687727`, `1030.674373`, `1653.443903`, and `365.712803 m²`) and sum to the outer area. Adapt triangle winding once through the same runtime convention used by `WorldChunkBuilder`; do not change the stored generated indices.

## Proposed vertical contract

### Story grid

```text
flat reference base B0 = 4.274 m
gross story height Hs  = 3.500 m

B1 =  7.774 m  top of ground story
B2 = 11.274 m
B3 = 14.774 m
B4 = 18.274 m  companion roof / four-story top
B5 = 21.774 m
B6 = 25.274 m  main roof / six-story top
```

- `main_six_story`: wall height `21.000 m`, outer wall tops `25.274 m`.
- `companion_four_story`: wall height `14.000 m`, outer wall tops `18.274 m`.
- Exposed step face `P -> Q`: bottom `18.274 m`, top `25.274 m`; exactly `7.000 m` high.
- The story grid is measured from current flat reference base `4.274`; terrain-aware foundation bottoms remain those in the generated wall record.
- No old horizontal face, collision, or hidden roof may remain at `10.274 m`.

### Roof/top treatment

- Create two flat bitumen roof planes: main at `25.274`, companion at `18.274`.
- The roof planes and their collision are owned by the existing roof object key `building:w1249412093:roof`.
- Use the current `building_roof` material and render layer `1`.
- Treat the upper wall edge as a clean simple flat roof/parapet line. Add **no separate parapet height**, terrace pavilion, glass rail, canopy, solar rack, plant, or roof furniture in this bounded pass.
- The absence of those one-off elements is a documented approximation, not permission to paint them into a wall or roof texture.

## Runtime override architecture

### Preserve generated bytes and source IDs

The implementation must not run or modify the world generator. `GeneratedWorldContract` must first validate the unchanged manifest/chunk exactly as it does now. Only after validation, `WorldChunkBuilder` may choose a Hawkins-specific runtime construction path when all of these exact predicates match:

```text
source_keys == [w1249412093]
object_key in [building:w1249412093:wall, building:w1249412093:roof]
wall/roof feature, material, receiver, collision, opacity and current generated
6.0 m massing fields match the pinned source records
target chunk bytes and massing layout contract match expected hashes
```

The runtime override changes how those two validated records are built in memory. It does not mutate the dictionaries, their serialized files, the logical-object index, the coverage ledger, or the OSM source.

Recommended ownership:

- Add a dedicated target-specific helper, `game/scripts/world/massing/hawkins_77_bruton_massing.gd`, with pure matching, split, wall, roof, and signature functions.
- In `WorldChunkBuilder._build_record`, dispatch the exact Hawkins wall and roof records to that helper before generic mesh construction.
- Return the same root names, object metadata, parent category, one mesh instance, one body, and one shape per physical record so the current runtime paths and body/shape counts remain stable.
- Attach the accepted `Hawkins77BrutonFacade` only to the rebuilt wall root.
- Hard-fail loading on source/layout drift; never silently fall back to a short generic Hawkins while claiming the correction is active.

### Wall geometry and ownership

Clip the current `20` terrain-aware outer foundation quads at `P` and `Q`:

- `P` falls inside source segment `4`; linearly interpolate its current bottom Y to `4.227158575 m`.
- `Q` falls inside source segment `9`; linearly interpolate its current bottom Y to `4.156504860 m`.
- All other outer bottom vertices remain byte-derived values from the current wall record.
- Segment `4` becomes one main and one companion outer quad; segment `9` becomes one companion and one main outer quad.
- This yields `22` runtime outer quads while retaining metadata `source_exterior_foundation_segments=20`.

Outer wall ownership:

| Run | Owner | Bottom | Top |
|---|---|---|---|
| `A -> P` (`60.400 m`) | main | current terrain profile | `25.274` |
| `P -> B` (`23.991906 m`) | companion | current terrain profile | `18.274` |
| `B -> Q` (`33.000 m`) | companion | current terrain profile | `18.274` |
| `Q -> C` (`26.439863 m`) | main | current terrain profile | `25.274` |
| `C -> D` (`60.138401 m`) | main | current terrain profile | `25.274` |
| `D -> A` (`55.006601 m`) | main | current terrain profile | `25.274` |
| `P -> Q` (`32.533849 m`) | main exposed step face | `18.274` | `25.274` |

There must be **no** internal `P -> Q` face from terrain/base to `18.274`, because the volumes meet there. There must be no coincident main/companion faces, no double collider, and no internal roof at the old `10.274` top.

Expected target raw geometry after deterministic clipping:

- wall: `22` exterior quads + `1` exposed step quad = `23` quads, `92` unshared vertices, `46` triangles;
- roof: main pentagon `3` triangles + companion triangle `1` = `4` triangles;
- one wall mesh/body/shape and one roof mesh/body/shape, as before.

### Collision and spray contract

Wall root:

- Build one `ConcavePolygonShape3D` containing the same `46` exposed vertical faces as the wall mesh.
- Preserve body and shape metadata exactly: `receiver_kind=building_wall`, `opaque=true`, `derived_object_key=building:w1249412093:wall`, `source_keys=[w1249412093]`.
- Preserve body name `Collision`, shape child `Shape`, collision layer `5`, collision mask `0`, and `spray_receiver_wall` membership.
- All outer main, outer companion, and exposed step-wall triangles are eligible spray receivers. Their normals must be vertical enough to pass the current `abs(normal dot UP) <= 0.3` gate.
- Do not add collision to the facade child or its modules. The accepted `0.012 m` field offset and maximum `0.05 m` relief remain visual-only; the ray continues to resolve the underlying wall body.

Roof root:

- Build one `ConcavePolygonShape3D` containing the four horizontal roof faces at the two new tops.
- Preserve `receiver_kind=none`, `opaque=true`, `derived_object_key=building:w1249412093:roof`, `source_keys=[w1249412093]`, collision layer `5`, mask `0`, and absence from `spray_receiver_wall`.
- Both roofs must be standable world collision and must reject spray as roofs do now.

### Terrain and foundation continuity

- Do not change `generated/world/terrain.json`, terrain meshes, roads, overlays, surface bias, building flat base, or any ground object.
- Do not resample terrain. Reuse the current wall-bottom endpoints and only linearly interpolate the two new points within their existing straight generated foundation segments.
- Preserve every current outer wall-bottom slope. There must be no below-ground opening or module.
- The companion/main polygons partition only the roof/wall ownership above the same ground footprint. They do not create a new slab, excavation, curb, or terrain seam.
- Assert the minimum and maximum target wall-bottom values remain `4.043` and `4.274 m`.

## Accepted facade remapping

The accepted facade materials, module shapes, side-local U coordinates, one-off address program, relief limits, and unobserved-side restraint remain the appearance contract. Only vertical repetition and split ownership change.

### Story-local Y mapping

Keep all current ground modules at their accepted absolute Y values. They remain within the new ground-story band `terrain/base .. B1=7.774` and keep their existing human scale.

For upper residential modules, use story centers:

```text
main upper centers:      [9.524, 13.024, 16.524, 20.024, 23.524]
companion upper centers: [9.524, 13.024, 16.524]
```

At each center place the accepted complete `W-P` geometry with the low horizontal transom. Place its `S-H` band at the corresponding story-bottom plus `0.160 m`: main/companion start at `7.934`, followed by `11.434`, `14.934`, and, for main only, `18.434`, `21.934`.

### Horizontal module ownership

| Side/volume | Accepted U positions to repeat | Upper rows |
|---|---|---:|
| WSW main (`u < 60.4`) | `3.0, 6.8, 10.6, 14.4, 18.2, 22.0, 25.8, 29.6, 33.4, 37.2, 41.0, 44.8, 48.6, 52.4, 56.2` | `5` |
| WSW companion (`u > 60.4`) | `65.8, 71.8, 77.8` | `3` |
| SE companion (`u < 33.0`) | `3.0, 6.8, 10.6, 14.4, 18.2, 22.0, 25.8, 29.6` | `3` |
| SE main (`u > 33.0`) | `38.0, 44.0, 50.0, 56.0` | `5` |

Expected remapped complete upper counts are `W-P=128` and `S-H=128`.

The accepted WSW ground openings remain exactly `15` `region=main` modules below `u=60.4` and `2` `region=companion` modules above it. The six SE address one-offs remain one each and at their accepted U/Y values. Do not copy the lobby, sign, doors, service field, garage, or canopy band to another side or story.

### Connector remap

The current `R-C/W-N` connector modules define the split endpoints but must not protrude above the lower silhouette on the wrong volume.

- Repeat one complete `R-C` plus one complete `W-N` in each of the five main upper story bands at both split endpoints: expected `R-C=10`, `W-N=10`.
- On WSW, the main side is `u < 60.4`; place the full `1.45 m` connector module at `u=59.675` so its split-side edge is exactly `60.4`.
- On SE, the main side is `u > 33.0`; place the full `1.45 m` connector module at `u=33.725` so its split-side edge is exactly `33.0`.
- Treat the exposed internal step face `P -> Q` as `pearl_plain` material-only. Do not invent windows, doors, rails, or a continuation of the exterior connector schedule there.

This half-width shift is the only horizontal facade remap. It keeps complete motifs on existing geometry and prevents either connector from floating above the four-story wall.

### Material fields and render layers

- Ground/base field: current `base_smooth`, from each outer terrain bottom through `B1=7.774`, except current accepted SE ribbed subregions and their shallow complete modules.
- Observed WSW and SE upper fields: accepted `pearl_fluted`, repeated over their owning volume from `B1` to that volume's top.
- Unobserved ENE and NNW upper fields: accepted `pearl_plain`, material-only, now extended to main top `25.274`; no modules.
- Internal step face: `pearl_plain`, material-only.
- Roofs: existing `building_roof`/bitumen, render layer `1`.
- All wall fields and modules: render layer `2`, so the existing spray decal cull mask projects across them.
- Preserve `field_offset_m=0.012`, `maximum_relief_m=0.05`, the band-limited `0.064 m` flute response, and all accepted material resources unchanged.
- Suppress generic facade fields on internal/nonexistent faces. No old `6 m` overlay may remain.

Expected remapped module counts:

```text
W-P=128, S-H=128, R-C=10, W-N=10, G-W=17,
L-G=1, D-P=1, F-SIGN=1, C-B=1, D-S=1, G-G=1
```

## Deterministic reload behavior

- Keep the public scene paths and root/object names unchanged.
- `WorldLoader.load_world()` continues to validate all generated content before any attachment and continues to clear generated category children before rebuild.
- The Hawkins override must be pure with respect to its two source records and the versioned layout: fixed vertex order `A,B,C,D`, fixed split formulas, fixed volume order `main,companion`, fixed outer-run order, fixed internal-step order, fixed story order bottom-to-top, and sorted material-batch order.
- Record a `massing_layout_sha256` and a deterministic massing signature that includes full-precision split points, story height, volume tops, ordered wall faces, ordered roof faces, module transforms, collision metadata, and render layers.
- Two direct builds of the exact wall and roof records must produce identical signatures and face arrays.
- Two full `load_world()` calls, with one processed frame after generated-child clearing, must produce one wall root, one roof root, one facade child, two target bodies, two target shapes, no stale short mesh, no duplicate modules, and identical signatures.
- Any chunk/layout/source drift must fail with a Hawkins-specific load error and `source_keys=[w1249412093]`; it must not apply the override to a near match.

## Hard invariants and no-spillover gates

### Source and footprint

- [ ] `git diff -- generated/world data/osm` is empty.
- [ ] The pinned chunk, manifest, content, and source/receiver geometry hashes remain exact.
- [ ] `w1249412093`, both physical object keys, chunk `x_-1__z_1`, and the logical/coverage rows remain unchanged.
- [ ] `P` and `Q` are recomputed from accepted U coordinates and exact side endpoints; no alternate rounded constants are used as inputs.
- [ ] Main plus companion area equals `3970.518806 m²` within `1e-6 m²`; union outer boundary equals `[A,B,C,D]`; intersection area is zero.
- [ ] No target vertex lies outside the existing footprint in XZ.

### Geometry, terrain, and roofs

- [ ] Main top is `25.274`, companion top is `18.274`, and no visible/collision face remains at old top `10.274`.
- [ ] Runtime target wall is `23` quads / `46` triangles and roof is `4` triangles.
- [ ] There are `22` outer runtime quads derived from all `20` source foundation segments plus one exposed step quad.
- [ ] The only internal wall is `P -> Q` over `18.274..25.274`; no internal face exists below `18.274`.
- [ ] All original terrain-bottom endpoints remain exact; only P/Y `4.227158575` and Q/Y `4.156504860` are linearly interpolated.
- [ ] No terrain, road, area, foundation source, navigation, boundary, spawn, recovery, or gameplay parameter changes.
- [ ] Roofs are flat at the two tops, bitumen, collision-enabled, spray-ineligible, and contain no new roof furniture.

### Collision, spray, and render

- [ ] Wall root owns exactly one body/shape on layer `5`, in `spray_receiver_wall`, with exact wall/source metadata.
- [ ] Roof root owns exactly one body/shape on layer `5`, outside `spray_receiver_wall`, with exact roof/source metadata.
- [ ] A low outer-wall ray, high main-wall ray, companion upper-wall ray, and exposed step-wall ray all resolve the same `building:w1249412093:wall` identity and can place a tag when vertical/in range.
- [ ] Rays to both roofs resolve `building:w1249412093:roof` and are rejected by the spray controller.
- [ ] All Hawkins wall/facade visuals use render layer `2`; roofs use layer `1`; spray decals retain cull mask `2`.
- [ ] No facade node owns collision, navigation, occlusion, or spray group membership.
- [ ] No invisible old roof stops the player at `10.274`.

### Facade acceptance preservation

- [ ] Accepted material resources, flute filtering, field offset, relief limit, complete motif shapes, colors, and ground one-offs remain unchanged.
- [ ] Module counts equal the remapped exact count block above.
- [ ] WSW/SE U schedules partition at `60.4/33.0`; no window crosses a volume edge.
- [ ] ENE, NNW, and internal step face remain material-only.
- [ ] Every exterior connector module is complete and wholly owned by the main volume.
- [ ] No address-specific module appears outside SE ground level.

### No spillover

- [ ] A non-target wall and roof from the same chunk build through the generic path and receive no Hawkins massing/facade child.
- [ ] Building 3 and Isle House accepted layouts/signatures remain unchanged.
- [ ] Museum Building One remains blocked/no-attachment as currently recorded.
- [ ] Full generated coverage remains `735 playable + 4 context rows across 38 chunks`; all source coverage validation passes.
- [ ] World body/shape counts stay unchanged because Hawkins retains one wall and one roof body/shape. Any triangle-count change is confined to the exact Hawkins wall/roof meshes and remapped facade visuals.
- [ ] A runtime inventory diff shows no changed object path, geometry, collision, or material assignment outside `w1249412093`.

## Acceptance route and rendered proof plan

Use Godot `4.7.2`, Forward+/Metal, `1440x900`, the normal third-person `70°` FOV and `5.5 m` spring. Preserve every final player/camera/aim/light transform in a new manifest. Camera support must resolve validated `land_ground` or `road_path`, never an adjacent roof fallback.

### Ordinary-camera, jetpack, collision, and spray route

1. Load the full main scene and assert the exact wall/roof paths, source IDs, massing signature, story tops, and absence of any `10.274` roof face.
2. Walk on generated ground to the existing close SE address approach at side `u=15.5`, no farther than `5 m` from the wall. Place one real-controller spray at the accepted lobby/entry ground module; assert the hit identity is the unchanged wall key.
3. From generated ground, traverse the ordinary WSW route without teleporting. Capture the stepped silhouette from a validated ground approach around WSW `u=35`, requested outward distance `35-45 m`, aimed near `y=14.774`. The ground-level player and ordinary camera must frame both four- and six-story tops.
4. Hold `Space` and retain horizontal control along the observed WSW side. Pass the old `10.274` elevation without an invisible collision, stop against the high main wall at an upper-story test point, and place a second real-controller spray from within `6 m` around `y=20.024`.
5. Release `Space` over the companion footprint and land on the companion roof at `18.274`; verify stable floor contact. Rise again above `25.274`, release over the main footprint, and land on the main roof at `25.274`.
6. From the companion roof, collide against and spray the exposed `P -> Q` step face within range. The tag must resolve the same wall identity and render across the material-only step field.
7. Aim at each roof. Both hits must be world collision and must be rejected as spray receivers.
8. Walk/jetpack away and return; reload the world once and repeat the identity/body/shape/signature counts to prove no accumulation or state leak.

### Required capture suite

| ID | View | Required evidence |
|---|---|---|
| `01-address-close` | Existing SE `u=15.5`, `5 m` ground approach, default sun | Preserved lobby/sign/door grammar, four-story companion continuing above it, no clipped modules |
| `02-address-close-sprayed` | Same exact pose after real spray | Visible tag plus exact wall/source hit identity |
| `03-wsw-ordinary-stepped` | Ground-level ordinary camera, WSW `u≈35`, `35-45 m` outward, default sun | Whole main six-story silhouette, lower companion, ground/upper cadence, normal gameplay readability |
| `04-corner-oblique-stepped` | Ground-level oblique outside corner `B`, about `40 m` outward | Both observed sides, the P/Q step logic, no floating connector, no corner clipping or doubled internal face |
| `05-jetpack-low-roof-step` | Player stably on companion roof looking toward the main step face | Companion roof collision at `18.274`, exposed step wall, high main continuation, no old roof plane |
| `06-corner-oblique-changed-light` | Exact pose from `04`, sun rotation `(-38,125,0)` | Height step and accepted pearlescent/fluted response remain coherent without baked lighting or sampling regression |

The independent reviewer must keep these verdicts separate: source/footprint, massing/story hierarchy, collision/spray, accepted facade preservation, roof approximation, and overall Hawkins resemblance. “Taller than before” is not an acceptance criterion.

## Known approximations and confidence limits

| Item | Confidence | Limit |
|---|---|---|
| Frozen source and exact game footprint/receiver identity | High/exact for this snapshot | OSM is authoritative for this game's horizontal layout, not a property survey |
| Six-story main and four-story low-rise | High verified fact | Does not give exact wall tops or footprint partition |
| Main/companion visible distinction | High reference observation | Perspective views do not rectify the plan |
| P/Q cut from accepted WSW/SE connectors | Medium production inference | Deterministic and facade-coherent, but not an as-built plan dimension |
| `3.500 m` story height | Low-medium production inference | Reversible game assumption; planned `70 ft` is only a sanity check |
| Exact `25.274/18.274` world tops | Exact implementation result from the assumption | Not claimed as surveyed elevations |
| Flat roofs with no extra parapet/furniture | High scope decision, low as-built resemblance | Actual photo shows roof terrace/pavilion/rail/canopy context that this pass omits |
| Accepted facade module placement | Medium, already independently accepted for facade language | Reference-relative, opaque and shallow; not a rectified as-built elevation |
| ENE/NNW/internal step appearance | Low | Material-only fallback; no unique openings may be inferred |
| Terrain bottom continuity | Exact for generated game data | USGS-derived terrain is not a finished-floor survey |

If later evidence requires a materially different split polygon, story height, courtyard, setback, or roof volume, that is a new massing contract and needs a new representative before -> after plus explicit owner approval. Do not silently “improve” this implementation.

## Expected implementation file scope and rollback

### Expected files in a later implementation round

Required:

- new `game/scripts/world/massing/hawkins_77_bruton_massing.gd` and Godot UID;
- `game/scripts/world/world_chunk_builder.gd` for exact wall/roof dispatch only;
- `game/resources/facades/hawkins_77_bruton_layout.json` for versioned massing/story/split contract and remapped facade schedule;
- `game/scripts/world/facades/hawkins_77_bruton_facade.gd` for multi-story volume-aware fields/modules;
- `game/tests/headless_hawkins_facade_contract.gd` for exact geometry, collision, spray, facade, deterministic reload, and no-spillover gates;
- `game/tests/hawkins_facade_capture.gd` for the six-view capture/route manifest.

Conditionally required only if their exact global assertions need Hawkins-aware expected values:

- `game/tests/full_runtime_integration.gd`;
- `game/tests/automated_route_qa.gd`;
- cross-target facade tests that pin the old Hawkins layout hash/signature.

Expected evidence output in the later implementation/review round:

- a new immutable Hawkins massing evidence directory under `evidence/first-playable/` containing the six captures, manifest, hashes, mechanical results, and independent review.

Explicitly out of scope:

- all `generated/world/**`, `data/osm/**`, terrain, material, shader, module-library scene, player, camera, spray-controller, gameplay, other-building, and source-photo files.

### Exact rollback boundary

Rollback is target-local and does not regenerate the world:

1. Remove the new Hawkins massing helper and its UID.
2. Revert only the Hawkins dispatch branch in `world_chunk_builder.gd`.
3. Revert the Hawkins layout, facade script, Hawkins tests/capture harness, and only Hawkins-specific expectation changes in conditional tests to the accepted facade-correction versions and hashes.
4. Remove or archive only the new massing evidence directory according to the evidence retention decision; do not alter the accepted prior facade evidence.
5. Confirm the exact current generic `6.0 m` Hawkins wall/roof records build again with accepted facade signature `6fc4d5aee82a5a496c3e77d3752fe07f18e798a1dba4364a3671fccc8d0d8161` and layout hash `2debe810737a98fef19ceaa0bfe6ec241abf3cafdcac3aea8f005eed42cdd8e6`.

No OSM, generated, terrain, or other-building rollback is permitted or necessary because those files never change.

## Specification completion status

- Exact target/source/receiver join: **validated**.
- Current chunk, massing, roof, foundation, collision, spray, and facade state: **validated against current files and accepted evidence**.
- Split endpoint formulas and coordinates: **validated**.
- Main/companion polygon convexity and deterministic triangulation: **validated**.
- Footprint union area and exterior-perimeter preservation: **validated; zero computed area delta**.
- Story/top arithmetic and module ownership/count remap: **validated for internal consistency**.
- External/as-built metric accuracy: **not claimed**.
- Implementation blocker: **none within the approved approximation contract**.
