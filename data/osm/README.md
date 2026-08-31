# Frozen OpenStreetMap snapshot

This directory contains the approved raw-vector layout baseline for the Treasure Island game. It uses OpenStreetMap data rather than public raster or vector map tiles.

## Acquisition

- Acquired: `2026-08-28T04:35:57Z`
- Source: [OpenStreetMap map API](https://api.openstreetmap.org/api/0.6/map?bbox=-122.386,37.805,-122.350,37.836)
- Requested bounding box, west/south/east/north: `-122.386,37.805,-122.350,37.836`
- Attribution: `© OpenStreetMap contributors`
- License: [Open Data Commons Open Database License 1.0](https://www.openstreetmap.org/copyright)

## Files and integrity

### `treasure-island-2026-08-27.osm`

- Purpose: unmodified shared raw API response covering Treasure Island, Yerba Buena Island, and nearby bridge context.
- Bytes: `5,594,888`
- SHA-256: `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`
- OSM objects: `13,119` nodes, `1,494` ways, `167` relations.
- Latest included object timestamp: `2026-08-28T03:08:38Z`.

### `treasure-island-boundary.osm.pbf`

- Purpose: OSM way `26767313` plus referenced nodes. The way is tagged `place=island` and named `Treasure Island`.
- SHA-256: `fe6e0cc64ada69bcdb04b515396f83d0e5bfa646ca17f1b95d0276a800a08781`

### `treasure-island-boundary.geojson`

- Purpose: direct export of the boundary PBF for inspection.
- SHA-256: `ff8709129a049cb59aa6924d554cb38f96da422c3694bc25c1006bcd0f84ff34`
- Note: the exporter emits the source line, its interpreted area, and a tagged gate node.

### `treasure-island-polygon.geojson`

- Purpose: mechanically filtered single Treasure Island `MultiPolygon` used as the extraction boundary.
- SHA-256: `43adbe335e87f0d839b56c2f5933ae97d35d4f588ce93bd09923a98620dd2b63`

### `treasure-island-proper-2026-08-27.osm.pbf`

- Purpose: smart polygon extract for Treasure Island proper. Complete ways and relevant multipolygon members may extend beyond the polygon.
- Header bounds, west/south/east/north: `-122.3790725,37.8151916,-122.3629075,37.8323315`.
- Bytes: `103,207`.
- SHA-256: `13984ed8f70c9d5d39d4ba14f83c7307eb75428af7b07df5774df29bda4ccaf9`.
- OSM objects: `7,016` nodes, `827` ways, `29` relations.
- Reference check: zero missing node references in ways. Some non-world parent relations are incomplete because the bounded API response does not contain their remote members; the building/building-part subset has zero missing node, way, or relation references.

### `treasure-island-source-inventory.csv`

- Purpose: approach-neutral source ledger with one row per canonical OSM source key admitted to playable or coarse context scope. It records source membership, not derived game geometry or implementation completion.
- Bytes: `195,590`.
- SHA-256: `fdf57f37f5507a7cb9b64a7fc530eabb22e29f3742324d5347c0f6b1949cb4cb`.

### `treasure-island-source-inventory-summary.json`

- Purpose: machine-readable summary and validation state for the source ledger.
- Bytes: `1,220`.
- SHA-256: `49eb5c9fadd1b81b3fd687beb59cd9f917eb197069bcb993f5a0a3f2588d90d7`.

## Artifact roles

- The [raw OSM snapshot](treasure-island-2026-08-27.osm) is the authoritative frozen source and includes Treasure Island, Yerba Buena Island, and nearby bridge context.
- The [extraction polygon](treasure-island-polygon.geojson) is the exact Treasure Island spatial boundary derived from OSM way `w26767313`.
- The [Treasure Island proper PBF](treasure-island-proper-2026-08-27.osm.pbf) is a smart polygon extract and reproducible working view of the raw snapshot. It is not a replacement for that snapshot, and completed source objects can extend outside the polygon.
- The [source ledger CSV](treasure-island-source-inventory.csv) and [summary JSON](treasure-island-source-inventory-summary.json) are derived inventory artifacts. They identify source obligations and validation state; they contain no game geometry and select no conversion or implementation approach.
- The [boundary PBF](treasure-island-boundary.osm.pbf) and [boundary GeoJSON](treasure-island-boundary.geojson) are inspection helpers for the source boundary. They are distinct from both the exact extraction polygon and the proper extract.

The exact classification, canonical-ID, spatial-admission, overlap, and exclusion rules are recorded in the [source-ledger specification](../../discovery/SOURCE_LEDGER_SPEC.md).

## Verified source-ledger counts

The ledger has `739` unique source rows: `735` playable rows and `4` non-playable context rows. Its exact playable categories follow the linked specification and are distinct from the broader neutral tag totals below. Category counts are overlapping memberships:

| Playable category | Memberships |
|---|---:|
| `land_boundary` | 1 |
| `terrain_shoreline` | 22 |
| `roads_paths` | 427 |
| `major_area` | 80 |
| `building` | 213 |
| `building_part` | 2 |
| **Membership sum** | **745** |

Exactly `10` playable rows belong to two categories, and none belongs to three or more. Thus `745 - 10 = 735` playable unique rows; adding `4` context rows gives `739` total unique rows. The context rows are one Yerba Buena Island anchor and three Bay Bridge anchors. All `739` source keys are unique, all have `derived_world_status=not_started`, and all have an empty `derived_object_key`.

## Source-ledger regeneration

From the project root, the exact generator command is:

```sh
node tools/build_source_inventory.mjs
```

The [generator](../../tools/build_source_inventory.mjs) reads the frozen raw snapshot and proper extract and regenerates only the source-ledger CSV and summary JSON. It does not regenerate the raw snapshot, boundary helpers, extraction polygon, or proper PBF. The command requires the local `osmium` executable; the audited artifacts above were verified with Osmium `1.19.1`.

## Initial neutral inventory

Counts below describe tagged OSM objects in the Treasure Island proper extract. They are evidence for approach comparison, not a selected conversion pipeline.

- Buildings: `213` (`209` ways and `4` relations).
- Building parts: `2`.
- Buildings with `height` or `building:levels`: `186`.
- Buildings without either height field: `27`; these receive the approved simple massing default later.
- Highway-tagged ways, including roads and paths: `427`.
- Land-use objects: `30`.
- Park, garden, or playground objects: `8`.

The raw snapshot remains authoritative. Any derived geometry must retain enough source identity to prove that every admitted Treasure Island feature was represented exactly once.

No implementation approach selected.
