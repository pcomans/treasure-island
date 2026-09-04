# Source packet — 490 Avenue of the Palms (`w1272162518`)

Checked: **2026-09-04**  
Readiness: **reference-ready for bounded WSW and NW work; massing gap explicit**

## Exact binding and present state

| Field | Frozen/project fact |
| --- | --- |
| Source | OSM way `w1272162518`, v3, `2025-11-16T03:53:10Z`; 490 Avenue of the Palms, complete San Francisco address, `building:levels=5` |
| Logical / wall receiver | `building:w1272162518` / `building:w1272162518:wall` |
| Chunk / geometry hash | `x_-1__z_1` / `9af2cedbb41dbf565f63a939ad3d800fdb09dcbd4debfc5878665fcad06af9f3` |
| Generated mass | `15 m`, base/top `0.818 / 15.818 m`; 26 runs / `305.101 m` |
| Side chains | WSW `0..7`; SSE `8..11`; ENE `12..22`; NW `23..25` |
| Runtime/review | Shared placeholder remains live. Taupe thin-brick prototype is independently accepted with limitation; WSW mapping exists; attachment remains blocked. |

Binding authority: `discovery/FACADE_RECEIVER_INVENTORY.json`,
`discovery/facades/490_AVENUE_OF_THE_PALMS_REFERENCE_SPEC.md`, and Batch 02
mapping/evidence.

## Identity and currentness

- `verified_fact` — developer Wilson Meany identifies 490 Avenue of the Palms as
  a **complete six-story** 148-residence project by Anne Fougeron and Mark
  Cavagnero Associates.
- `verified_fact` — Mark Cavagnero Associates marks it completed in 2025 and
  describes three large two-to-three-story portals and floor-to-ceiling windows.
- Confidence: **high**. The current six-story primary-source record conflicts
  with the frozen five-level receiver and must remain explicit.

## Primary and observation sources

| Source | Access | Supports | Use boundary |
| --- | --- | --- | --- |
| [Wilson Meany project page](https://wilsonmeany.com/project/490-avenue-of-the-palms/) | opened 2026-09-04 | exact identity, complete status, six stories, 148 residences, architects | developer facts; imagery observation-only |
| [Mark Cavagnero project page](https://www.cavagnero.com/project/490-avenue-of-the-palms/) | opened 2026-09-04 | completed 2025; three portals; two/three-story scale; floor-to-ceiling windows; courtyard/terraces | architect facts; Bruce Damonte photos and Hayes Davidson renderings observation-only/distinguished |
| [Official residence site](https://rent490.com/residences/) | HTTP 200 on 2026-09-04 after browser timeout | current identity/address and residence marketing context | marketing facts; imagery observation-only |
| `P490-SV01`, [WSW entry](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82115,-122.37405&heading=70&pitch=6&fov=75), pano `bjPnIkM1MVTV2DXoZa2jRw` | UI validated 2026-08-29; capture Nov 2025 | WSW entry/material hierarchy | Google observation-only |
| `P490-SV02`, [north corner](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82155,-122.37430&heading=125&pitch=7&fov=78), pano `92eDcHBL7oSzMdVAC4wfkA` | UI validated 2026-08-29; capture Nov 2025 | WSW/NW corner and upper openings | Google observation-only |
| `P490-SV03`, [south WSW](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82072,-122.37398&heading=45&pitch=7&fov=78), pano `_7_jhPOXMBLR2zGQkhH2hw` | UI validated 2026-08-29; capture Nov 2025 | southern WSW composition | Google observation-only |
| `P490-SV04`, [NW/north](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82178,-122.37372&heading=160&pitch=7&fov=78), pano `qezst3shU9xoH-7A1tk_FQ` | UI validated 2026-08-29; capture Nov 2025 | NW/north oblique | Google observation-only |

## Observed recognition cues

- `reference_observation` — a **warm-white smooth primary field, dark taupe thin
  brick, restrained greige accents, and charcoal frames** form a clear layered
  palette rather than a uniform white apartment block.
- `reference_observation` and architect fact — **large floor-to-ceiling dark
  windows, deep portals and exterior terrace/open-air cuts** interrupt the mass.
- `verified_fact` — exactly **three large portals**, each two to three stories,
  are a primary project concept and likely whole-object recognizer.
- `reference_observation` — the WSW address elevation includes a one-off **490
  entry** and nonuniform wide/medium/narrow opening families.

Observed region boundary: most WSW and an NW/north oblique. ENE/rear, complete
SSE, courtyard/interior faces, and exact subregion-to-run boundaries are unknown.

## Implementation-ready recommendation

Observed inputs:

- retain separate warm-white, taupe thin-brick, greige, charcoal-frame/glass,
  and entry materials; never flatten them into one sampled image;
- use complete wide/medium/narrow window, ground-glazing, brick-bay, terrace-edge,
  and unique `490` entry families on mapped observed sides;
- preserve irregular, side-local placement and deep-value contrast.

Reversible `production_inference`:

- attach/review the existing WSW material prototype and a complete side-local
  motif layout without inventing ENE/SSE schedules;
- treat portal/terrace depth as geometry-owned. A facade-only pass may reserve
  dark/recessed regions but must not claim to create through-building voids;
- if unobserved sides need coherence, continue only low-information white/brick
  material families without copying entry, terrace, portal or window phase.

Massing: prepare the six-story and three-portal geometry as one separately
reviewable proposal if recognition fails. The current 15 m/five-level receiver
and solid mass cannot claim faithful portal or story silhouette.

## Nonclaims, confusion set, and gate

Unknown/nonclaim: exact cladding products/bond/pitch, window dimensions/counts,
full SSE/ENE/rear/courtyard schedules, portal geometry in receiver coordinates,
terrace depth/railings, interiors/transparency, roof profile, and surveyed height.

Likely confusion set: Hawkins, Star View Court, and Maceo May. A passing facade
result must retain at least two independent cues: (1) white/taupe-thin-brick/
greige hierarchy, (2) broad floor-to-ceiling dark openings, (3) one-off `490`
entry. Whole-object acceptance should additionally see the three portals after a
separate geometry decision. Fine white fluting would incorrectly read as Hawkins.

No human dependency is required for the bounded observed-side pass. Surveyed
portal geometry would require licensed drawings but is not necessary for a
reversible recognition-scale proposal.

