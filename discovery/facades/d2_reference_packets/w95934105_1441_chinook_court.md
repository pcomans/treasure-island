# D2 source packet — 1441 Chinook Court (`w95934105`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; no live attachment authorized**

## Exact binding and state

| Field | Exact value |
| --- | --- |
| Frozen source | OSM way `w95934105`, v5, `2018-08-12T13:53:19Z`; `building=apartments`, `building:levels=2`, `height=6` |
| Logical / wall / roof | `building:w95934105` / `building:w95934105:wall` / `building:w95934105:roof` |
| Chunk / geometry hash | `x_-1__z_-1` / `952df7a4edca5dbaec7d74cb795b564cb1fa5567ea737d1a861e222b29ddf07f` |
| Generated mass | area `475.379 m²`; base/top `3.332 / 9.332 m`; 16 runs / `110.805 m` perimeter |
| Exact facing runs | ENE `0,2,11`; NNW `1,3,4,5,8`; WSW `6,7,9,14`; SSE `10,12,13,15` |
| Relationship / runtime | standalone direct footprint; shared placeholder only |

Authority: frozen source, `discovery/FACADE_RECEIVER_INVENTORY.json`, and
generated chunk geometry.

## Identity, currentness, and sources

- `verified_fact` — City EAS record `725381` binds 1441 Chinook Court at
  `-122.3739127,37.8239946`, parcel `1939001`. Identity confidence is **high**.
- `verified_fact` — Navy's 2015 Site 12 table assigns the address to Swords to
  Plowshares. MOHCD's 2025 register groups 1441 and 1443 as **Chinook Family
  Apartments**. These establish administrative identity, not signage.
- `reference_observation` — `D2-PANO-A` shows the target in July 2023.
  Survival/current appearance after that date and current occupancy are unknown.

Shared source IDs and rights boundaries are defined in [README](README.md).

## Exact observed side and recognition cues

The panorama viewpoint is about 20.5 m SSE of the frozen footprint centroid;
the target-to-camera bearing is about `162°`. It maps the visible public long
side to SSE-facing receiver runs **`10,12,13,15`**, total `32.848 m`. Mapping
confidence is high for target and orientation; trees/fence occlude lower pieces.

Target-bound `reference_observation` cues:

- a shallow dark-brown shingle side-gable with a broad, visibly projecting eave
  caps the low two-storey zigzag mass;
- the long side is articulated by projecting pale stucco blocks and deep
  two-level recessed balcony/breezeway voids, not a flat window strip;
- dark simple metal rails, grouped rectangular upper/lower openings, and a
  mostly quiet warm-white field create strong solid/void contrast.

The recognition pair is **projecting block / recessed two-level void cadence
plus the shallow dark gable and deep eave**. White color, a satellite dish,
fence signs, or the address alone fails.

## High-quality reversible prototype guidance

- Build a side-local module study on runs `10,12,13,15`: complete recessed
  two-level voids with rail silhouettes, quieter window groups on the projecting
  blocks, and a real eave shadow break. Counts and dimensions are
  `production_inference`, chosen for ordinary player-scale reading.
- Use a generated, mostly tileable warm off-white stucco field with subtle
  aggregate and broad vertical grime variation; use a separate tileable dark
  shingle roof. A visible seam is acceptable in this first prototype, but avoid
  high-contrast periodic dirt.
- Preserve exact receiver, footprint, 6 m source height, collision, navigation,
  spray, roof, terrain and foundation. Recesses are render-only until collision
  honesty is separately proven.

Nonclaims: exact opening/balcony counts or dimensions; unseen ENE/NNW/WSW
sides; current occupancy; structural substrate; alterations after July 2023.
Close confusion: 1439, 1443, 1438 and 1440 Chinook. The exact SSE solid/void
cadence—not the shared palette—must distinguish this unit.

