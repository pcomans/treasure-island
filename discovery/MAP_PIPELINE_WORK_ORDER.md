# Proposed Treasure Island Map-Pipeline Work Order

Checked: 2026-08-27

Status: implementation-ready specification for the approach in `discovery/APPROACH_PROPOSAL.md`; this document does not approve that approach, install its dependencies, or implement it.

## Work-order boundary

This work order specifies only the proposed offline OSM-to-world-data pipeline and its runtime handoff. It must preserve the complete-island scope while keeping these items outside the generator:

- Godot project scaffolding, player/camera/spray code, editor/export installation, and package installation;
- detailed facades, interiors, apartments, rooms, bespoke roofs, vehicles, traffic, access restrictions, and currentness reconciliation;
- San Francisco geometry: the skyline remains a separately authored non-playable billboard; and
- shoreline failure/recovery behavior. The pipeline emits the exact boundary geometry but does not make an invisible wall, water system, kill plane, or reset rule.

Every rule below remains part of the proposed bundle. An implementer must not silently substitute another projection, clip boundary, coverage denominator, source-key convention, or context scope.

## Fixed source contract

The proposed generator reads these existing files and no live map service:

| Role | Exact path | Required SHA-256 or invariant |
|---|---|---|
| Authoritative source | `data/osm/treasure-island-2026-08-27.osm` | `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; 5,594,888 bytes; 13,119 nodes, 1,494 ways, 167 relations |
| Exact playable polygon | `data/osm/treasure-island-polygon.geojson` | `43adbe335e87f0d839b56c2f5933ae97d35d4f588ce93bd09923a98620dd2b63`; derived from `w26767313` |
| Smart working view | `data/osm/treasure-island-proper-2026-08-27.osm.pbf` | `13984ed8f70c9d5d39d4ba14f83c7307eb75428af7b07df5774df29bda4ccaf9`; 7,016 nodes, 827 ways, 29 relations |
| Source obligations | `data/osm/treasure-island-source-inventory.csv` | `fdf57f37f5507a7cb9b64a7fc530eabb22e29f3742324d5347c0f6b1949cb4cb`; 739 unique rows |
| Source audit summary | `data/osm/treasure-island-source-inventory-summary.json` | `49eb5c9fadd1b81b3fd687beb59cd9f917eb197069bcb993f5a0a3f2588d90d7` |

The raw XML remains authoritative. The other inputs are reproducible views or audit artifacts; generated world data is disposable. Stop before writing output if a required hash, object count, ledger count, or explicit source ID differs.

The exact denominator is 735 playable rows plus four context anchors (`w26767311`, `w1011568818`, `r13543937`, `r13543938`), hence 739 total unique rows. The 745 playable memberships are exactly: 1 `land_boundary`, 22 `terrain_shoreline`, 427 `roads_paths`, 80 `major_area`, 213 `building`, and 2 `building_part`. Exactly ten playable rows have two categories and none has three. No node amenity, YBI internal feature, bridge member way, San Francisco feature, remote parent relation, or live-OSM object may enter the denominator.

## Proposed repository interface

If authorized, add only these pipeline-owned source/configuration files:

| Path | Contract |
|---|---|
| `package.json` | Declares the map commands and exact direct dependencies `earcut@3.0.2` and `polygon-clipping@0.15.7`. |
| `package-lock.json` | Locks every dependency transitively; floating semver is not reproducible. |
| `map/map-pipeline.config.json` | Holds all constants in this work order. A source hash, boundary, projection, scale, width, height, clip, or chunk change requires a schema-version change and review. |
| `tools/generate_map_data.mjs` | Sole generator entry point; may invoke the already-installed `osmium`. |
| `tools/validate_map_data.mjs` | Read-only structural, geometry, coverage, and hash validator. |
| `tools/check_map_determinism.mjs` | Generates twice in temporary directories, validates both, and byte-compares paths and hashes. |

The exact package script interfaces are:

| Script | Command target |
|---|---|
| `map:generate` | `node tools/generate_map_data.mjs --output generated/map` |
| `map:validate` | `node tools/validate_map_data.mjs generated/map` |
| `map:determinism` | `node tools/check_map_determinism.mjs` |

The generator owns this output tree and no other path:

```text
generated/map/
  manifest.json
  logical-objects.json
  coverage-ledger.csv
  coverage-summary.json
  collision.json
  context.json
  chunks/
    c_<signed-x>_<signed-z>.json
  qa/
    derived-footprints.geojson
    top-down.svg
    validation-report.json
```

Examples are `c_-2_0.json` and `c_1_-3.json`. Artifact paths are project-relative. No absolute path, username, temporary path, timestamp, or machine identifier may appear. Generate into a sibling staging directory under `generated/`, validate it, then replace only `generated/map/`. A failed run leaves the prior valid tree untouched.

## Extraction and canonical source selection

Create temporary GeoJSONSeq streams with Osmium 1.19.1:

```sh
osmium export -u type_id -a type,id,version,timestamp -f geojsonseq \
  -o <temporary-directory>/proper.geojsonseq --overwrite \
  data/osm/treasure-island-proper-2026-08-27.osm.pbf

osmium export -u type_id -a type,id,version,timestamp -f geojsonseq \
  -o <temporary-directory>/raw.geojsonseq --overwrite \
  data/osm/treasure-island-2026-08-27.osm
```

The process-local temporary directory is deleted and never recorded. Canonical identity is original `@type` plus `@id`: `n<ID>`, `w<ID>`, or `r<ID>`. Never use Osmium's synthetic `a…` polygon feature ID. Multiple exported views of one source must agree on tags, version, and timestamp.

Geometry selection is exact:

- `selected_geometry_family=area` uses the one `Polygon` or `MultiPolygon` view;
- `selected_geometry_family=line` uses the one `LineString` view;
- `w29399800` uses its line identity only and follows the shared-coastline composite rule;
- context site relations without direct geometry resolve from raw XML membership; and
- zero, multiple, or wrong-family candidates for any other row are fatal.

Every generated row must match the source ledger's type, ID, version, timestamp, categories, selected family, and stable tags. The pipeline does not reclassify or expand the source inventory.

## Coordinate system and projection

All topology uses double-precision local east/north meters with these exact constants:

- WGS84 input (`EPSG:4326`);
- Earth radius `R = 6378137.0` meters;
- origin `lon0 = -122.3709900000`, `lat0 = 37.8237615500` degrees, the midpoint of the recorded `w26767313` bbox;
- one Godot unit per meter; `+X` east, `+Y` up, `-Z` north; and
- terrain datum `Y=0.0`, because OSM supplies no elevation surface.

For `lon,lat`:

```text
east_m  = R * radians(lon - lon0) * cos(radians(lat0))
north_m = R * radians(lat - lat0)
world   = [east_m, elevation_m, -north_m]
```

QA inverse:

```text
lon = lon0 + degrees(east_m / (R * cos(radians(lat0))))
lat = lat0 + degrees(north_m / R)
```

No Web Mercator, UTM lookup, per-layer origin, recentering, degrees-as-meters, or runtime reprojection is allowed. Boolean operations run before output rounding. Round final coordinates/heights once to 0.001 meter and serialize negative zero as zero. A ring that collapses, self-intersects, reverses topology, or exceeds area tolerance after rounding fails rather than being simplified.

## Exact Treasure Island clipping

Let `B` be the projected `MultiPolygon` from `data/osm/treasure-island-polygon.geojson`, with semantic identity `w26767313`. Use `B` with no buffer, bbox substitution, simplification, smoothing, hand edit, or YBI union.

1. Playable land is exactly `B`.
2. Every playable area is `polygon-clipping.intersection(source_area, B)`.
3. Every playable line except `w29399800` becomes its deterministic ribbon and is then intersected with `B`.
4. Buildings and parts are also intersected, even if currently wholly inside.
5. Chunk rectangles apply only after TI intersection and may not admit new area.
6. No serialized playable vertex may be outside `B` beyond the 0.001-meter serialization tolerance.

An empty/zero-measure result is fatal unless explicitly composited below. Touch admission does not authorize an inward marker or out-of-scope geometry.

Shared coastline `w29399800` is the one predeclared playable clip composite: represent its TI portion by the exact outer edge of `land:w26767313`; mark it `represented_composite`, not as a YBI-spanning ribbon. The other audited no-interior-vertex rows—`w28353163`, `w644986117`, and `w319406837`—must yield positive clipped ribbon/polygon area. If one does not, stop and amend the work order with evidence.

## Polygons, multipolygons, and holes

Osmium supplies assembled area views, including all eight admitted multipolygon relations. Normalize and validate each polygon in `[east_m,north_m]` space:

- remove exact consecutive duplicates and the duplicate terminal closure point during mesh work;
- require three distinct points and non-zero signed area per ring;
- orient outers counter-clockwise and holes clockwise;
- rotate each ring to its lexicographically smallest vertex, tie-breaking by its following sequence;
- sort holes by canonical first vertex then absolute area;
- sort components by outer first vertex then descending absolute area; and
- restore a closing coordinate only in GeoJSON QA output.

Use `polygon-clipping` for intersection, difference, and union. Keep each returned outer with its holes; never triangulate a hole as a separate filled polygon. Flatten one outer followed by holes, give their zero-based start indices to `earcut`, and rewind returned top triangles to point `+Y` after mapping north to `-Z`. Emit side walls edge-by-edge: outer walls face outward and hole walls into the void. Reject degenerate triangles.

Generated top-triangle area must match clipped polygon area, subtracting holes, within `max(0.01 m², clipped_area * 1e-8)`, before and after chunk division. A malformed result is unresolved, never omittable.

## One logical object per source row

Do not modify the source CSV's `derived_world_status=not_started`. The derived side is `generated/map/coverage-ledger.csv`, with exactly the same 739 source keys and these columns:

```text
source_key,scope,categories,source_version,representation_status,
logical_object_key,physical_object_keys,chunk_keys,geometry_role,clip_result,
source_measure,clipped_measure,height_rule,height_m,geometry_sha256,notes
```

Quote all cells. Multi-value fields are sorted and semicolon-separated. Measures are meters for lines or square meters for areas, to three decimals. Allowed statuses are only `represented_direct` and `represented_composite`. Missing, skipped, unresolved, duplicate, or empty is unacceptable. The logical key stays singular when triangles span chunks; physical and chunk keys carry the one-to-many mapping.

Known multi-category sources remain one row/object: the four `terrain_shoreline|major_area` sources use one area with both roles, and the six `major_area|building` sources use one building mass with both roles instead of a coplanar duplicate.

Predeclared composites are limited to:

| Source key(s) | Logical composite | Reason |
|---|---|---|
| `w29399800` | `land:w26767313` | Shared TI/YBI coastline is the exact playable land edge. |
| `w1249412094` | `building-composite:w1249412094` | Isle House parent owns residual parent mass, if any, plus parts `w1282547786` and `w1282547787`. |
| `w1011568818`, `r13543937`, `r13543938` | `context:bay-bridge` | Three coarse bridge anchors deliberately share one scenery composite. |

Any other composite requires an explicit revision. A physical road batch is not an exception: each road retains a direct logical object and pre-batch geometry hash.

## Terrain, shoreline, and major areas

`land:w26767313` has a flat top at `Y=0.0`, triangulated once for global collision and by 256-meter render chunk. Emit the ordered outer/inner boundary rings separately as `world_boundary_candidate`; runtime decides shoreline behavior.

Visual-only vertical offsets prevent depth fighting:

| Role | `Y` meters |
|---|---:|
| Land | 0.000 |
| `landuse=*` area | 0.020 |
| terrain/shoreline area | 0.030 |
| `leisure=*` area | 0.040 |
| `amenity=*` area | 0.050 |
| road/path | 0.080 |

For multi-tag major areas, precedence is `amenity`, `leisure`, `landuse`; full tags stay on the object. A shoreline/major-area overlap uses one shoreline surface. Area overlays have no separate collision. Access, fence, private, construction, and hazard tags never filter sand, wetland, construction, parking, parks, pitches, playground, marina, pier, or breakwater geometry.

Line shoreline features other than `w29399800` use the road ribbon algorithm at width 3.0 meters for breakwaters and 4.0 meters for piers. An unknown line shoreline class is fatal for this frozen classification.

## Roads and paths

Represent all 427 `highway=*` ways. Do not remove them for access, fence, construction, bridge, lanes, or maxspeed tags. With no source `width`, use:

| `highway` | Width meters |
|---|---:|
| `tertiary` | 12.0 |
| `residential` | 8.0 |
| `unclassified` | 7.0 |
| `service` | 5.0 |
| `pedestrian` | 5.0 |
| `platform` | 4.0 |
| `track` | 4.0 |
| `cycleway` | 3.0 |
| `path` | 2.0 |
| `footway` | 2.0 |

An unknown frozen highway value is fatal. Form a deterministic round-join ribbon by unioning a closed half-width rectangle for every non-zero segment with a regular 12-gon at every vertex. Vertex zero is due east; subsequent vertices are counter-clockwise. Remove zero-length segments; a source with none fails. Intersect the union with `B`, canonicalize it, and record its per-source clipped area/hash.

Within each chunk, union all clipped road/path footprints into physical surface `roads:<chunk-key>` before triangulation, preventing coplanar overlap. Each row still has direct logical key `road:<source-key>` and references the relevant batch/chunk keys. Roads add no collision or vehicle semantics.

## Buildings and parts

All 213 buildings and two parts must have polygon geometry. Height priority is exact:

1. trimmed `height` parsed as one finite positive decimal meter value;
2. otherwise finite positive decimal `building:levels * 3.0` meters; or
3. fixed 6.0-meter fallback.

Invalid/compound values fall through. Expected building rules are 176 `osm_height`, 10 `osm_levels`, and 27 `default_6m`; parts are one `osm_height` and one `osm_levels`. Record `height_rule` and `height_m`. There is no roof inference, source-external research, height cap, terrain drape, or invented `min_height`; bases are `Y=0.0`.

Part-parent resolution must reproduce Isle House:

1. A candidate parent has `difference(part,parent) <= 0.01 m²` after TI clipping.
2. Each part must have exactly one candidate.
3. `w1282547786` and `w1282547787` must resolve to `w1249412094`.
4. Part interiors may touch but must not overlap by more than 0.01 m².
5. Compute `parent_residual = difference(parent, union(parts))`.
6. Extrude each part at its own height and only positive parent residual at parent height; never extrude the full parent too.

`building-composite:w1249412094` owns residual plus part objects. If the parts exhaust the parent, the parent remains a documented composite without duplicate volume.

For each ordinary building and non-overlapping parent/part cell: triangulate its roof with holes; emit exterior/courtyard walls; between cells of different height emit only the upper exposed interval; omit equal-height interior walls and bottom faces. Mark wall triangles `receiver_role=building_wall_opaque`; roofs are `none`. This prevents double massing and limits spray receivers to generated opaque walls.

## Context and exclusions

Context uses the same projection, never enters the 735-row denominator, and has no collision or spray receiver. Subtract `B` from each final context footprint so the scenery cannot contribute a second surface over playable land.

- `w26767311` becomes `context:ybi`: subtract `B`, triangulate the remaining simple flat polygon at `Y=-0.050`, and retain no YBI internal roads, areas, or buildings.
- `w1011568818` supplies the West Span area.
- Resolve all 23 way members of `r13543937` from raw XML. A closed member is its polygon; an open member gets an 8.0-meter 12-gon ribbon. Union them with the West Span, subtract `B`, and store the result as `context:bay-bridge`, triangulated at `Y=12.0`.
- `r13543938` adds no duplicate geometry and points to that bridge composite.

Bridge members support scenery but do not become ledger rows. San Francisco has no OSM generator record; if later authored, proposed paths are `game/assets/context/san-francisco-skyline.png` and `game/assets/context/san-francisco-skyline.provenance.md`.

## Chunking, render handoff, and collision

Chunk size is 256.0 meters, grid-anchored at origin:

```text
chunk_x = floor(east_m / 256.0)
chunk_z = floor((-north_m) / 256.0)
```

Shared closed chunk edges have zero area and identical rounded coordinates. Intersect land, area, and road surfaces with chunk rectangles before triangulation. Do not cut buildings: assign a complete building/composite to the chunk containing its area centroid, breaking an exact grid-line tie toward the lower integer. Chunking is organization only; the first playable loads every chunk and introduces no streaming or omission.

Each `chunks/c_<x>_<z>.json` has `schema_version=1`, `chunk_key`, `bounds_m:{min_x,min_z,max_x,max_z}`, and `physical_objects` sorted by key. Each physical object has:

```text
physical_object_key: string
roles: sorted string array
material_key: string
receiver_role: "building_wall_opaque" | "none"
positions: flat numeric [x,y,z,...]
normals: flat numeric [x,y,z,...]
indices: flat zero-based integer triangle indices
logical_object_keys: sorted unique string array
```

Positions/normals have equal vertex counts; indices are in range and a multiple of three; triangles have positive area and correct winding. One physical object has one material and one receiver role so Godot can build one inspectable `ArrayMesh` surface.

`collision.json` contains one global concave static land surface from unchunked `B`, building wall/roof triangles grouped by centroid chunk, and the non-colliding `world_boundary_candidate` rings. Proposed runtime ownership is one `StaticBody3D` for land and one per nonempty building chunk. Roads, overlays, context, building bottoms, and boundary candidates add no collision. Render/collision building triangles share canonical vertices and logical/source keys. Shoreline outcome remains deliberately undecided.

## Manifest and logical-object contracts

`manifest.json` has `schema_version=1` and:

```text
generator: {node_version,osmium_version,package_lock_sha256,config_sha256}
sources: [{path,sha256,bytes,role}, ...]
coordinate_system: {
  source_crs,earth_radius_m,origin_lon,origin_lat,
  world_axes,meters_per_unit,coordinate_rounding_m
}
playable_boundary_source_key: "w26767313"
chunk_size_m: 256.0
counts: {source_rows,playable_rows,context_rows,logical_objects,chunks}
files: [{path,sha256,bytes}, ...]
```

`files` covers every other output in lexicographic order and excludes the manifest to avoid a self-hash. There is no timestamp.

`logical-objects.json` has `schema_version=1` and objects sorted by `logical_object_key`, each with:

```text
logical_object_key: string
source_keys: sorted non-empty string array
scope: "playable" | "context"
roles: sorted string array
representation: "direct" | "composite"
component_object_keys: sorted string array
physical_object_keys: sorted string array
chunk_keys: sorted string array
source_measure: number
clipped_measure: number
geometry_sha256: lowercase hex
height: null | {rule,height_m}
```

Geometry hashes cover canonical three-decimal source-owned clipped 2D geometry before batching/chunking. Thus roads remain auditable after union and cross-chunk sources keep one identity.

`coverage-summary.json` repeats the denominator, memberships, status totals, height totals, composites, error counts, and hashes. `qa/validation-report.json` has deterministic check names, values, thresholds, and pass/fail only. `qa/derived-footprints.geojson` inverse-projects logical footprints with source keys/roles/object/chunks. `qa/top-down.svg` draws land, areas/shoreline, roads, buildings/parts, then context with a fixed palette/view box and no timestamp.

## Deterministic generation

- Audit the initial implementation with Node 26.7.0 and Osmium 1.19.1; a tool-version change requires a new two-run audit.
- Lock dependency versions and integrity hashes in `package-lock.json`.
- Verify input hashes before export.
- Sort sources by scope, specification category order, OSM type, numeric ID; sort keys, chunks, rings, files, and JSON fields as specified.
- Canonicalize boolean output, round once to 0.001 meter, reject non-finite values, normalize negative zero.
- Use UTF-8, two-space JSON indentation, fully quoted CSV, and one terminal newline in every text artifact.
- Use no randomness, clock, locale-dependent format, filesystem enumeration order, network, absolute path, or parallel floating-point reduction.
- Stage a complete tree so stale chunks cannot survive.
- Require two clean runs to have identical relative paths, byte lengths, and SHA-256 hashes.

## Commands and acceptance checks

Run these only after approach/download authorization; they were not run to write this work order.

```sh
shasum -a 256 \
  data/osm/treasure-island-2026-08-27.osm \
  data/osm/treasure-island-polygon.geojson \
  data/osm/treasure-island-proper-2026-08-27.osm.pbf \
  data/osm/treasure-island-source-inventory.csv \
  data/osm/treasure-island-source-inventory-summary.json

osmium fileinfo -e data/osm/treasure-island-2026-08-27.osm
osmium fileinfo -e data/osm/treasure-island-proper-2026-08-27.osm.pbf
osmium check-refs data/osm/treasure-island-proper-2026-08-27.osm.pbf

npm ci
npm run map:generate
npm run map:validate
npm run map:determinism
```

The validator exits non-zero unless:

1. All hashes and raw/proper counts match; proper ways have zero missing node references.
2. Coverage joins one-to-one across 739 rows: 735 playable, four exact context keys, exact memberships, ten multi-category rows, and no playable YBI.
3. Every row is direct or an explicit composite; none is missing, duplicated, unresolved, empty, or backed only outside `B`.
4. Projection round-trip error is at most `1e-9` degree before rounding; all numbers are finite.
5. Land equals `B` within 0.01 m²; no playable vertex is outside beyond 0.001 m; context has no playable/collision/receiver role.
6. Rings are valid/canonical, holes remain holes, mesh area meets `max(0.01 m², area*1e-8)`, and no triangle is degenerate/out-of-range.
7. All 427 roads have known width, positive clip, source hash, physical batch, and no collision.
8. All 80 major-area and 22 shoreline memberships resolve once, including four dual rows and the coastline composite.
9. All 213 buildings/two parts have positive footprints/massing; height counts are 176/10/27 and 1/1.
10. Both parts resolve only to `w1249412094`; overlap is <=0.01 m²; residual plus parts equals parent within 0.01 m²; no duplicate volume/internal equal-height wall remains.
11. Land/building collision matches render geometry; no road, overlay, context, or shoreline wall collides; only opaque building walls receive spray.
12. Every physical object appears once, manifest references/hashes resolve, chunk assignment is exact, and logical/physical references resolve both ways.
13. Context is exactly `context:ybi` plus `context:bay-bridge`; three bridge anchors share the documented composite and no member becomes a coverage row.
14. Two clean generations are byte-identical.

Then open `generated/map/qa/top-down.svg` and compare it with the source polygon and `qa/derived-footprints.geojson`. Human acceptance is limited to gross omission, inversion, relative-position error, lost hole, YBI leakage, or bridge-direction error; it cannot waive failed ID/geometry checks.

## Proposed implementation order

1. Add config, locked package metadata, and generator/validator shells only after authorization.
2. Implement input verification, Osmium export, 739-row joins, and projection; produce no world output until all resolve.
3. Add polygon normalization, TI clipping, holes, triangulation, and area checks across the full ledger.
4. Add land, areas, and all 427 road ribbons before batching.
5. Add all building masses and exact Isle House decomposition; derive collision/receiver ownership from generated triangles.
6. Add context, chunks, manifest/hashes, QA, and coverage outputs.
7. Pass validation and determinism twice before Godot consumes the contract.
8. Then test all chunks and collision on the target Mac. A blocker may revise physical batching, never source keys or island scope.

## Unresolved implementation risks

- Narrow/touching coastal results may collapse after 0.001-meter serialization; the three non-coastline touch rows must be proven positive.
- The simple 12-gon ribbon can look bulbous or merge parallel paths. Changing it alters plan geometry and requires a schema/work-order update.
- A different Osmium, Node, or dependency version can perturb ordering/numerics; two-run determinism proves a pinned toolchain, not universal cross-version identity.
- Static concave building collision and all-at-once loading are untested on the target Mac; physical batching may need revision while preserving all 739 rows.
- Chunked render land versus one global collider can still expose a runtime seam despite matching plan vertices.
- The relation/part rules are exact for this frozen source. Invalid geometry, ambiguous parentage, or member incompleteness must stop rather than trigger heuristic repair.
- Coarse bridge/YBI heights are not survey geometry and require a runtime view check while remaining non-playable.
- A coverage-perfect blockout can still fail owner recognition; later recognition tuning cannot silently rewrite the frozen layout.

## Resource requests

No request is added beyond `APPROACH-002`: project-local `polygon-clipping@0.15.7` and `earcut@3.0.2` only after authorization, with transitive versions and registry integrity locked in `package-lock.json`. No hosted service, new data, image generation, account, paid asset, GDAL/PROJ install, or OSM request is needed.

No approach selected.
