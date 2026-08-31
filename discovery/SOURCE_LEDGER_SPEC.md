# Approach-neutral OSM source-ledger specification

## Purpose and status

`data/osm/treasure-island-source-inventory.csv` is the immutable-source side of the milestone coverage ledger. It records the frozen OSM objects that a later approved build must map to visible geometry or to an identified composite. It does not contain game geometry, choose a conversion method, or assert that any row has been implemented. Every current row therefore has `derived_world_status=not_started` and an empty `derived_object_key`.

The audited generator is `tools/build_source_inventory.mjs`. Its inputs and outputs are:

| Role | Path | Audited SHA-256 |
|---|---|---|
| Authoritative raw source | `data/osm/treasure-island-2026-08-27.osm` | `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549` |
| Exact extraction polygon | `data/osm/treasure-island-polygon.geojson` | `43adbe335e87f0d839b56c2f5933ae97d35d4f588ce93bd09923a98620dd2b63` |
| Smart Treasure Island view | `data/osm/treasure-island-proper-2026-08-27.osm.pbf` | `13984ed8f70c9d5d39d4ba14f83c7307eb75428af7b07df5774df29bda4ccaf9` |
| Source ledger | `data/osm/treasure-island-source-inventory.csv` | `fdf57f37f5507a7cb9b64a7fc530eabb22e29f3742324d5347c0f6b1949cb4cb` |
| Machine-readable summary | `data/osm/treasure-island-source-inventory-summary.json` | `49eb5c9fadd1b81b3fd687beb59cd9f917eb197069bcb993f5a0a3f2588d90d7` |

The smart PBF is a reproducible view, not a replacement for the raw source. With the audited local Osmium version, this command reproduces it byte for byte, including its header bounds:

```sh
osmium extract \
  -p data/osm/treasure-island-polygon.geojson \
  -s smart \
  --set-bounds \
  -o /tmp/treasure-island-proper-audit.osm.pbf \
  --overwrite \
  data/osm/treasure-island-2026-08-27.osm
```

Omitting `--set-bounds` preserves the same OSM object set but does not reproduce the frozen PBF bytes or recorded header, so it is not the exact regeneration command.

## Canonical source identity

One row means one original OSM object, keyed as `n<ID>`, `w<ID>`, or `r<ID>`. The key comes from Osmium's exported `@type` and `@id`, never from the GeoJSON feature ID.

This distinction is required because `osmium export -u type_id` emits polygon views with synthetic `a…` feature IDs. The audited proper export contained `2,003` GeoJSON features but only `1,697` canonical OSM sources. It contained `328` `a…` area-view features, and `306` canonical sources had multiple exported views, normally a `LineString` `w…` view plus a `MultiPolygon` `a…` view. Grouping on the GeoJSON feature ID would duplicate those sources and would misidentify relation polygons. Grouping on `@type/@id` preserves their original source keys.

For a canonical source with multiple views:

- tags, version, and timestamp must agree across views;
- `source_geometry_types` is the sorted union of the exported geometry types; and
- classification occurs once for the canonical source.

The audit found no cross-view property disagreement, no duplicate ledger key, and no mismatch between the CSV's type, ID, version, timestamp, tags, categories, or geometry-type union and an independent parse of the frozen export.

## Spatial admission rule

Playable candidates come from Osmium's `smart` extract against the exact Treasure Island polygon derived from way `w26767313`. Under the recorded source contract, an object is spatially admitted when its geometry touches that polygon. Osmium then completes admitted ways and relevant multipolygons, so a source row can contain coordinates outside Treasure Island. This is a source-object denominator, not a claim that every coordinate is playable or that every source object will become a separate mesh.

The audit independently tested every one of the `735` playable rows against the exact polygon and found no non-touching row. The touch rule deliberately retains boundary-connected and coastal sources. Four admitted sources have no exported vertex strictly inside the land polygon: bridge footway `w28353163`, shared coastline `w29399800`, Treasure Island Yacht Harbor `w644986117`, and pier `w319406837`. Their inclusion follows the already recorded touch-based source rule; it does not authorize a later conversion to turn YBI or arbitrary out-of-bound coordinates into playable land.

A later approved geometry stage must still clip or classify completed coordinates against `w26767313`, or document a visible parent/composite for a retained boundary-connected object. Presence in the smart PBF alone must never expand the playable world.

## Exact category rules

After canonicalization and explicit YBI removal, a source receives every matching category below. It enters the playable ledger if it receives at least one category.

| Category | Exact frozen-snapshot admission rule |
|---|---|
| `land_boundary` | Exact source key `w26767313`. |
| `terrain_shoreline` | A way or relation that is exact source `w29399800`, or has `natural=sand`, `natural=wetland`, `man_made=breakwater`, `man_made=pier`, or `leisure=marina`. |
| `roads_paths` | A way with any `highway=*` value. Highway-tagged nodes do not qualify. |
| `major_area` | A way or relation with exported `Polygon` or `MultiPolygon` geometry and at least one of `landuse=*`, `leisure=*`, or `amenity=*`. Point amenities and point leisure features do not qualify. |
| `building` | A way or relation with `building=*`. All `213` current matches independently prove polygon geometry. |
| `building_part` | A way or relation with `building:part=*`. Both current matches independently prove polygon geometry. |

This is a closed classification for this frozen source ledger. In particular, it excludes:

- nodes, including `59` amenity nodes and `4` leisure nodes in the proper extract;
- generic or remote parent features such as the San Francisco Bay `natural=bay` relation;
- untagged relation member ways that do not independently match a category;
- individual apartments, rooms, levels, interiors, and address-only objects;
- YBI way `w26767311` from the playable denominator; and
- feature-by-feature YBI and bridge internals from the context denominator.

Access, fence, private, and construction tags do not remove an otherwise admitted object. That preserves the frozen layout baseline and the approved permissive outdoor-traversal rule without starting a currentness or legal-access audit.

## Treasure Island, shared coastline, and context

- `w26767313` is the exact Treasure Island land boundary and is the sole `land_boundary` row.
- `w26767311` is the YBI island boundary. The smart extract contains it because the islands meet at the southern connection, but the generator explicitly removes it from playable scope and adds it once as `context_island` from the raw snapshot.
- `w29399800` spans both Treasure Island and YBI. It remains one playable `terrain_shoreline` source row because it carries Treasure Island's recorded coastline. Its selected geometry family is `line`, and its note requires clipping to `w26767313` or a documented composite. It does not make YBI playable.
- `w1011568818`, `r13543937`, and `r13543938` are the three explicit `context_bridge` rows. Along with YBI, these four rows are coarse context anchors and are excluded from the playable completeness denominator.

The two bridge relations are `type=site`, so Osmium does not emit direct GeoJSON geometry for them. The generator correctly falls back to their original raw XML metadata and records their geometry family as `collection`; it does not invent a polygon. Recursive extraction proves that the bridge anchors resolve to `737` nodes, `24` ways, and `2` relations with zero missing references. Adding the YBI boundary produces `987` nodes, `25` ways, and `2` relations, also with zero missing references. Those referenced members support later simple context scenery but are deliberately not detailed context-ledger rows.

## Proven counts and union math

The playable category numbers are membership counts, not disjoint row counts:

| Playable category | Memberships | Source-type detail |
|---|---:|---|
| `land_boundary` | 1 | 1 way |
| `terrain_shoreline` | 22 | coastline 1; sand 4; wetland 1; breakwater 8; pier 6; marina 2 |
| `roads_paths` | 427 | 427 ways |
| `major_area` | 80 | 77 ways; 3 relations |
| `building` | 213 | 209 ways; 4 relations |
| `building_part` | 2 | 2 ways |
| **Membership sum** | **745** | Not a unique-row total |

Exactly `10` playable rows have two categories and none has three or more. Four are `terrain_shoreline|major_area`: `w110183752`, `w319406837`, `w644986117`, and `w1222505177`. Six are `major_area|building`: `w34313521`, `w34313547`, `w291189336`, `w291189918`, `w764313741`, and `w1436064757`.

Therefore the unique-row arithmetic is:

```text
745 playable memberships - 10 second memberships = 735 playable unique rows
735 playable unique rows + 4 context unique rows = 739 total unique rows
```

All `739` source keys are unique. All have `derived_world_status=not_started`. YBI has no playable row, and all four explicit context keys have exactly one context row.

## Geometry and dimension integrity

The proper PBF contains `7,016` nodes, `827` ways, and `29` relations and has zero missing node references in ways. The eight admitted multipolygon relations were recursively isolated from the authoritative raw snapshot; their subset contains `325` nodes, `19` ways, and `8` relations with zero missing node, way, or relation references.

All `213` building rows and both building-part rows export polygon geometry. The four building relations preserve multipolygon assembly. Building dimension coverage is:

| Building dimension state | Rows |
|---|---:|
| `height` and `building:levels` | 100 |
| `height` only | 76 |
| `building:levels` only | 10 |
| Neither | 27 |
| **Total** | **213** |

Thus `186` buildings have at least one source dimension and `27` require the approved later provisional massing default. The summary's `building_rows_missing_height_and_levels=27` intentionally counts `building` rows, not the two separate `building_part` rows. Both parts have `building:levels`; one also has `height`. Their overlap with parent `w1249412094` must later be resolved without losing any of the three source identities.

## Deterministic regeneration checks

Run the ledger generator from the project root:

```sh
node tools/build_source_inventory.mjs
```

Two consecutive audited runs were byte-identical to the candidate files and to each other. They reproduced the CSV and summary hashes recorded above. The generator also stops instead of writing a plausible-looking ledger if any frozen category count changes, any source key duplicates, the TI boundary or shared coastline is missing, YBI leaks into playable scope, or the explicit context set is incomplete.

The ledger is ready to serve as the source side of a later source-to-derived mapping. It is not evidence that derived geometry exists or that the milestone has been built.

No approach selected.
