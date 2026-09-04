# D2 source packet — 1439 Chinook Court (`w95934144`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; lower facade constrained by occlusion**

## Exact binding and state

| Field | Exact value |
| --- | --- |
| Frozen source | OSM way `w95934144`, v5, `2018-08-12T13:53:23Z`; `building=apartments`, `building:levels=2`, `height=6` |
| Logical / wall / roof | `building:w95934144` / `building:w95934144:wall` / `building:w95934144:roof` |
| Chunk / geometry hash | `x_-2__z_0` / `a59bd2abf2020c25071a55ecb96f32b7871a810e8d1bdd95c213b512273f87f2` |
| Generated mass | area `475.525 m²`; base/top `3.536 / 9.536 m`; 24 runs / `110.863 m` perimeter |
| Exact facing runs | ENE `0,1,3,13,14,15`; NNW `2,4,5,7`; WSW `6,8,9,10,20,21`; SSE `11,12,16,17,18,19,22,23` |
| Relationship / runtime | standalone direct footprint; shared placeholder only |

## Identity, currentness, and sources

- `verified_fact` — City EAS `725380` binds 1439 Chinook Court at
  `-122.3742292,37.8238505`, parcel `1939001`; identity confidence **high**.
- `verified_fact` — Navy 2015 assigns it to The Villages; City 2014 and TIDA
  2025 managed lists retain it in the rentable/managed cohort.
- `reference_observation` — `D2-PANO-C` shows the target in July 2023. Later
  appearance and present occupancy are unknown.

Shared sources and rights boundary: [README](README.md).

## Exact observed side and recognition cues

The panorama is about 22.1 m SE of the footprint centroid; target-to-camera
bearing about `142°`. The public side maps to SSE-facing runs
**`11,12,16,17,18,19,22,23`**, total `32.866 m`. Tiny runs `17,18` are genuine
clipping fragments and must not receive standalone motifs. Lower areas are
substantially screened by fencing/signs.

Target-bound `reference_observation` cues:

- a long warm-white two-storey block under a continuous shallow brown-shingle
  gable/eave has a deep recessed two-level balcony stack near one end;
- the exposed central upper register is unusually quiet: separated dark
  rectangular windows across broad solid panels, rather than a continuous bay;
- the opposite end resolves as a near-blank gable/return with another deep
  passage, producing an asymmetric solid/recess/quiet-field silhouette.

Recognition pair: **one strongly recessed balcony stack plus the broad quiet
upper-window field / blank-end hierarchy**. White stucco or address signage fails.

## High-quality reversible prototype guidance

- Build complete motifs across contiguous nontrivial SSE runs, treating tiny
  split fragments as part of their parent field. Prioritize deep shadow and rail
  silhouette at the visible balcony stack, then sparse upper windows and the
  blank end. Do not invent the occluded lower opening schedule.
- Use generated tileable warm-white stucco and brown shingle, with broad
  nonperiodic weathering overlays. Imperfect tile seams are acceptable for the
  prototype; no high-contrast checker repetition.
- Preserve footprint, 6 m envelope, collision/navigation/spray, roof and
  generated data. Recess geometry remains render-only pending physical review.

Nonclaims: lower facade behind fences, other sides, exact opening counts and
dimensions, current use, substrate. Close confusion: 1437, 1441 and 1438
Chinook; the observed SSE void/window distribution must remain distinct.

