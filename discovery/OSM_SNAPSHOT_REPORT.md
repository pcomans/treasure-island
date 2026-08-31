# OpenStreetMap Snapshot Report

## Status and scope

The approved raw OpenStreetMap snapshot now exists and has been inventoried without selecting an engine or production pipeline. This report treats the frozen OSM data as the layout baseline exactly as requested; it does not compare the snapshot with present-day reality.

Playable coverage is Treasure Island proper. Yerba Buena Island and the Bay Bridge are retained only as simple non-playable context, while San Francisco remains a separate billboard-background task.

## Acquisition and integrity record

### Authoritative raw snapshot

| Field | Verified value |
|---|---|
| File | `data/osm/treasure-island-2026-08-27.osm` |
| Acquired | `2026-08-28T04:35:57Z` |
| Source request | `https://api.openstreetmap.org/api/0.6/map?bbox=-122.386,37.805,-122.350,37.836` |
| Requested bbox (west, south, east, north) | `-122.386,37.805,-122.350,37.836` |
| Size | `5,594,888` bytes |
| SHA-256 | `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549` |
| Raw objects | `13,119` nodes; `1,494` ways; `167` relations |
| Latest included object timestamp | `2026-08-28T03:08:38Z` |
| API generator | `openstreetmap-cgimap 2.1.0` |
| Attribution/license | `© OpenStreetMap contributors`; ODbL 1.0 |

The query bbox tightly covers all of Treasure Island and YBI while intersecting the bridge objects needed for context. OSM returns complete ways that touch a requested bbox, so referenced geometry extends beyond the header bbox; that is expected and is not evidence that the wrong area was requested.

### Playable boundary and proper-island derivative

- OSM way `26767313`, version `29`, is named `Treasure Island` and tagged `place=island`.
- Its exact bbox is `-122.3790725,37.8151916,-122.3629075,37.8323315` in west/south/east/north order.
- `data/osm/treasure-island-polygon.geojson` is the mechanically isolated `MultiPolygon` used as the playable extraction boundary; SHA-256 `43adbe335e87f0d839b56c2f5933ae97d35d4f588ce93bd09923a98620dd2b63`.
- `data/osm/treasure-island-proper-2026-08-27.osm.pbf` is a smart polygon extract containing `7,016` nodes, `827` ways, and `29` relations; size `103,207` bytes; SHA-256 `13984ed8f70c9d5d39d4ba14f83c7307eb75428af7b07df5774df29bda4ccaf9`.
- The proper-island extract has zero missing node references in ways. Some unrelated route and large parent relations remain incomplete because the bounded API response does not contain their remote members. The building/building-part subset has zero missing node, way, or relation references.

### Reproducibility checks required before conversion

Any conversion experiment should first verify all of the following:

1. The raw file hash, byte size, source URL, request bbox, acquisition timestamp, attribution, and license match the values above.
2. `osmium fileinfo -e` reproduces the raw and proper-extract object counts and header bounds above.
3. The playable boundary remains OSM way `26767313`; YBI way `26767311` must not become playable merely because it shares the southern connection area.
4. The polygon and proper-extract hashes match the recorded derivatives.
5. `osmium check-refs` reports zero missing nodes in ways for the proper extract.
6. Any admitted multipolygon subset is reference-complete before geometry assembly. This is already proven for buildings/building parts; other chosen categories need the same bounded check.
7. Every derived feature retains a stable source key such as `w26767313` or `r16681702`, so coverage can prove that an admitted OSM object was represented exactly once.

The raw API response remains authoritative. Derived PBF or GeoJSON files are reproducible working views, not replacements for the snapshot.

## Counting method and caveat

Counts below come from the smart extract against the exact Treasure Island polygon. The extract admits an OSM way when its geometry touches the polygon and then completes the way; it also completes relevant multipolygons. Consequently, counts are source-object counts, not mesh counts, distinct street counts, or promises that every completed coordinate lies inside the playable polygon.

Known cross-boundary parents are called out explicitly. A later converter must clip or classify geometry against the Treasure Island polygon rather than blindly converting every parent relation in the proper extract.

## Terrain, shoreline, and coastal objects

| Source feature | Count | Conversion implication |
|---|---:|---|
| Treasure Island `place=island` boundary | `1` | OSM way `26767313` is the playable land boundary. |
| YBI `place=island` boundary | `1` | OSM way `26767311` touches the extract but is context only. |
| `natural=coastline` | `1` way | Way `29399800` spans Treasure Island and YBI; it must be clipped or replaced by the exact TI boundary for playable land. |
| `natural=sand` | `4` ways | Local area features. |
| `natural=wetland` | `1` way | Local area feature. |
| `man_made=breakwater` | `8` objects (`7` ways, `1` multipolygon relation) | Preserve multipolygon assembly where applicable. |
| `man_made=pier` | `6` ways | Includes area-shaped pier geometry. |
| `leisure=marina` | `2` ways | Both are area features in Clipper Cove. |

No local object uses `water=*` or `waterway=*`. A completed parent relation tagged `natural=bay` represents all of San Francisco Bay and is not an island feature to convert wholesale. OSM supplies plan geometry, not a terrain elevation surface or bathymetry; this snapshot therefore does not provide a DEM.

## Roads and paths

There are `427` highway-tagged ways. These are OSM segments, not `427` distinct named roads.

| Highway value | Ways |
|---|---:|
| `service` | `116` |
| `residential` | `69` |
| `tertiary` | `18` |
| `unclassified` | `3` |
| `track` | `2` |
| `footway` | `197` |
| `cycleway` | `13` |
| `path` | `4` |
| `pedestrian` | `4` |
| `platform` | `1` |

Useful attribute coverage among those ways:

- `surface`: `187` of `427` (`106` concrete, `72` asphalt, `4` paved, `3` unpaved, `2` dirt).
- `name`: `106` of `427` segments.
- `access`: `76`; these tags do not override the approved gameplay rule that outdoor snapshot space is generally traversable.
- `lanes`: `12`; `maxspeed`: `16`; `bridge=yes`: `3`; `width`: `0`.

Road and path centerlines are well represented, but consistent widths are not. Any later width-by-class rule would be a reversible conversion default, not information contained in this snapshot.

## Public space and land use

The proper extract contains `80` area-shaped objects carrying one of the three main public-space/land-use keys: `77` ways and `3` multipolygon relations.

| Key | Area objects | Values |
|---|---:|---|
| `landuse` | `30` | construction `8`; grass `18`; industrial `2`; recreation ground `1`; residential `1` |
| `leisure` | `26` | common `1`; marina `2`; park `7`; pitch `12`; playground `1`; sports centre `3` |
| `amenity` | `24` | parking `17`; restaurant `2`; college, fire station, place of worship, school, and shelter `1` each |

There are also `59` amenity-tagged nodes and `4` leisure-tagged nodes. They include benches, bicycle parking, toilets, waste baskets, picnic tables, and a fitness centre, but they are not themselves major land-use areas. The snapshot has `7` parks and `1` playground; no `leisure=garden` object appears.

`landuse=construction` remains part of the frozen layout inventory. It is not subjected to a real-world currency check.

## Buildings, parts, heights, and levels

The snapshot yields `213` building footprint objects: `209` closed ways and `4` multipolygon relations. It also contains `2` closed `building:part=yes` ways. All `215` building-related objects can be assembled as polygon geometry, and the four building multipolygons are reference-complete.

| `building` value | Objects |
|---|---:|
| `yes` | `98` |
| `residential` | `75` |
| `apartments` | `17` |
| `abandoned` | `14` |
| `hangar` | `2` |
| `service` | `2` |
| `condominium` | `1` |
| `dormitory` | `1` |
| `public` | `1` |
| `retail` | `1` |
| `shelter` | `1` |

Dimension coverage for the `213` building footprints:

- `176` have `height`.
- `110` have `building:levels`.
- `100` have both, `76` have height only, and `10` have levels only.
- `186` have at least one of those two dimension fields.
- `27` have neither and need the already-approved simple provisional massing default.
- Numeric building heights range from `1` to `67`; building levels range from `1` to `22`.

Both building parts have `building:levels`; one also has `height`. They subdivide the broader Isle House footprint, so a converter must establish parent-footprint/part precedence to avoid extruding overlapping full-height volumes while still retaining every source identity.

Detailed appearance is sparse: there is no `roof:height`, `roof:shape`, `building:material`, `min_height`, or `building:min_level` on the building set. Only one building has `roof:levels`, and only one has `building:colour`. OSM therefore supports complete footprint massing much better than detailed roofs or materials, which is consistent with the approved simple first pass.

## Non-playable YBI and Bay Bridge context

The same raw snapshot contains enough source geometry for the approved simple polygonal context:

- YBI boundary: way `26767311`.
- Bay Bridge West Span area: way `1011568818`.
- Bay Bridge East Span site: relation `13543937`, containing `23` member ways.
- Whole bridge site: relation `13543938`, linking the west-span way and east-span relation.

A reference-expanded bridge subset contains `737` nodes, `24` ways, and `2` relations with zero missing node, way, or relation references. These identities are context candidates only; their presence does not expand the playable world.

## Data gaps and concrete conversion implications

- **Playable clipping:** the coastline and several parent objects cross the scope boundary. Always clip/classify against way `26767313`; do not equate “present in the smart extract” with “playable.”
- **Projection:** source coordinates are WGS84 longitude/latitude. A local metric/world coordinate transform and origin are required later, but neither has been selected.
- **Relations and holes:** four buildings and several land/coastal areas are multipolygons. Any candidate conversion must prove that outer and inner rings survive.
- **One source object, one representation:** objects can carry more than one semantic tag, and building parts can overlap their parent footprint. Preserve source IDs through mapping, triangulation, and extrusion to prevent accidental duplicates or omissions.
- **Terrain:** no elevation raster or terrain surface is present. The OSM polygon can define the island plan, while any vertical land shaping remains a later reversible default or separately justified resource.
- **Road width:** no highway way has a `width` tag. Centerlines are available; consistent rendered widths require a documented class-based rule or another approved source.
- **Building massing:** `27` footprints need fallback height. Roof form and materials are overwhelmingly absent.
- **Gameplay semantics:** OSM does not define collision, walkability, spray eligibility, spawn points, camera behavior, or recovery. Those remain runtime/gameplay concerns rather than map facts.
- **Completeness accounting:** the approved “model the island” requirement needs an admitted-feature ledger keyed by OSM type and ID. Visual inspection alone cannot prove that all source features were represented.

No separate real-world freshness, fence, private-access, or property audit is needed. That omission is deliberate and matches the approved brief.

## Installed local tooling

- `osmium` 1.19.1 with libosmium 2.23.1 is installed and successfully performs file inspection, smart polygon extraction, tag filtering, reference checks, and GeoJSON/GeoJSONSeq export.
- `jq` 1.7.1, `curl` 8.7.1, Node.js 26.7.0, and Python 3.14.7 are present.
- `ogr2ogr`/GDAL is not installed.
- Python packages `osmium`, `pyrosm`, `osmnx`, `geopandas`, `shapely`, `pyproj`, and `fiona` are not installed.

The existing tools are sufficient for snapshot verification and neutral inventory. Additional geospatial packages or import plugins should be requested only after a concrete approach comparison shows that they enable an agreed task.

## Neutral conversion option families

These remain unranked:

1. **CLI-derived interchange:** use `osmium` to isolate, filter, and export source objects to GeoJSON/GeoJSONSeq, then consume that interchange in a later chosen runtime.
2. **Geospatial-library conversion:** add a small GDAL/PROJ or language-specific geometry stack for clipping, local projection, polygon repair, and attribute mapping before runtime import.
3. **Runtime-native or plugin import:** give the frozen XML/PBF or a filtered derivative to an importer supplied by a later chosen runtime, then independently verify IDs, multipolygon holes, and dimensions.
4. **Purpose-built minimal converter:** parse the needed OSM object/tag subset, transform coordinates, triangulate areas, and extrude massing with project-owned rules.
5. **Hybrid conversion:** use `osmium` for reproducible extraction and source identity, then a smaller geometry/runtime-specific stage for projection, meshes, and gameplay metadata.

Each option must be evaluated against the same frozen snapshot and feature-ID coverage evidence. None is selected here.

## Resource requests

No new resource or access request is needed for snapshot inventory. Image generation, an asset store, paid data, accounts, additional compute, and software installation are not needed at this step.

No approach selected.
