# D3 source packet — 1318 Gateview Avenue (`w95934092`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; no recognition or live attachment authorized**

## Exact binding

| Field | Exact value |
| --- | --- |
| Frozen source | OSM way `w95934092`, v5, `2020-07-09T13:50:42Z`; `building=residential`, `building:levels=2`, `height=6`, `addr:housenumber=1318`, `addr:street=Gateview Avenue` |
| Logical / wall / roof | `building:w95934092` / `building:w95934092:wall` / `building:w95934092:roof` |
| Relationship / chunk | standalone direct footprint; `x_-3__z_-2`; no `building_part` child or shared wall run |
| Mass / perimeter | area `734.700 m²`; height `6 m`; NAVD88 base/top `2.522 / 8.522 m`; serialized/visible perimeter `163.715 / 163.714 m`; `26` runs |
| Exact orientation partition | WSW `242.7°`: `0–1,4–5,7–8,10,12,15–16,24`; SSE `152.6–152.7°`: `2–3,9,13–14,17`; ENE `62.7°`: `18–22`; NNW `332.7°`: `6,11,23,25` |
| Source geometry SHA-256 | `c70546b00437f3676a0b8af5809df2f17d94bfab8f292cd678a04afbc5defc55` |
| Wall geometry / record SHA-256 | `cf3e4243a92261609c2545373f4d9e698f6a7b742b1edb652fc32784ed8c93d7` / `7953c40463b7a50d3ba0399b22005e845394e50aa2ba22139e9752866c7aad02` |
| Chunk SHA-256 | `35bf23d64e860d39c5b79a98be7830f4f477143f7e9490c6739dec0627062d11` |

## Identity and lifecycle

- `verified_fact` — the frozen source binds **1318 Gateview Avenue** directly.
  Live City EAS record `1318 GATEVIEW AVE`, point
  `-122.377404241,37.826701478`, agrees spatially; `CITY-XWALK` maps old
  `280 Gateview Av` to current `1318 Gateview Av` / Building 1318. Identity
  confidence is high exact-source join.
- `reference_observation` — the target is visibly standing in March and
  November 2025. Neither an active civic address nor those captures prove
  current occupancy or an unchanged exterior after November 2025.
- `unknown` — tenancy, interior use, later alteration, surveyed roof pitch,
  structural substrate, and whether every front privacy/add-on element is
  original architecture.

## Dated public-side evidence and exact mapped scope

| Observation | Provenance | Exact safe geometry scope |
| --- | --- | --- |
| `1318G-SV01` | [Google pano `qGPa9ZjJlrtlQpnP52eiAA`](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8267942,-122.3776632&heading=126&pitch=0&fov=75), Mar 2025; resolved camera `37.8267503,-122.3776812`, heading `126°` | seven public/front WSW facets `0–1,4–5,7–8,10,12,15–16,24` (`47.508 m`) and outer NNW end run `23` (`12.601 m`) |
| `1318G-SV02` | [Google pano `GmuTsOm1-FO47a4FOWEQHA`](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8266681,-122.3770043&heading=245&pitch=0&fov=75), Nov 2025; resolved camera `37.8266407,-122.3769985`, heading `245°` | rear ENE runs `18–22`, `47.512 m`; lower facade partly fence-occluded |

Mapped: `0–1,4–5,7–8,10,12,15–16,18–24` (`17` runs). Unmapped
narrow returns/notches: `2–3,6,9,11,13–14,17,25`. The Street View label
`1327` refers to the opposite building, not this target. No panorama pixels are
stored or redistributed.

Target-bound observations support cool gray-blue horizontal siding; white
trim/gutters/downspouts; a muted-brown low gable roof; front upper sliders plus
ground door/window/privacy-enclosure groupings under a shallow multi-bay porch
canopy with gable accents and posts; stacked end-gable windows; rear upper
sliders with lower zones partly hidden by fences.

Unproven: exact unit widths/count/order, door alternation, course pitch, porch
projection, lower-rear grammar, narrow-return continuation, endpoint ownership
inside modules, and whether trellis/privacy additions are base-family elements.

## Recognition and prototype handoff

The minimum recognition pair is **the shallow porch/canopy-and-post rhythm over
varied complete front unit groups plus the cool siding / white trim / low-gable
hierarchy**. Address numerals or siding color alone fail. Close confusion: 1317
Gateview (`w95934125`), 1316 Gateview (`w96215648`), 1315 Gateview
(`w96698651`), 1400 Sturgeon (`w95934126`), 1418 Striped Bass
(`w95934112`), and 1212 Mariner; none may donate an opening schedule.

A detached prototype may use a mostly tileable siding field and complete
front-unit, rear-unit, and end-gable modules on the exact mapped facets. Early
tile seams are acceptable; obvious repeating dirt, partial opening/canopy seams,
uniform invented unit repeats, copied fences/trellises, or wrap onto the nine
unmapped returns are not. Canopies/posts/downspouts need shallow render geometry
where silhouette matters; preserve the exact receiver, height, roof/footprint,
foundation/terrain, collision/navigation/spray, and generated data.

The current catalog has no accepted reference-recognition claim. Prototype
blocker: **none for a detached mapped-side study**. Live/whole-building blockers:
physical scale and exact unit-module placement, narrow-return ownership,
occluded lower rear, independent grayscale/motion review, and fail-closed
integration.

Sources and rights boundaries: [shared D3 index](README.md),
[`1318_GATEVIEW_AVENUE_REFERENCE_SPEC.md`](../1318_GATEVIEW_AVENUE_REFERENCE_SPEC.md),
and [`BATCH_04_RUN_MAPPING.json`](../BATCH_04_RUN_MAPPING.json).
