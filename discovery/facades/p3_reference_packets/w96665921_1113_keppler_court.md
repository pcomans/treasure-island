# Source packet — 1113 Keppler Court (`w96665921`)

Checked: **2026-09-04**

Readiness: **reference-ready for one bounded front material prototype; modules and whole object blocked**

## Exact binding and present state

| Field | Frozen/project fact |
| --- | --- |
| Source | OSM way `w96665921`, v6, `2020-07-09T13:50:42Z`; `1113 Keppler Court`; `building=residential`, `building:levels=2`, `height=6` |
| Logical / wall receiver | `building:w96665921` / `building:w96665921:wall` |
| Chunk / geometry hash | `x_-2__z_-2` / `de76334ed54af41e5d8d36d7502cc8c0691c2fceafbce02dd5a0d560a4422ece` |
| Generated mass | `6 m`, base/top `2.454 / 8.454 m`; 22 runs / `144.427 m` visible wall |
| Runtime/review | Shared placeholder only; no target prototype or live attachment |

Exact run partition from Batch 05:

- front NNE homogeneous-material candidate: runs `11,12,14,15,16,17,18`,
  `58.334 m`, high confidence;
- rear SSW provenance/context only: runs `0,2,3,4,5,8,9`, `58.340 m`,
  high geometry / medium appearance confidence, **no attachment**;
- protected/unmapped: runs `1,6,7,10,13,19,20,21`.

The receiver inventory and Batch 05 map are the authority for this partition.
No panorama-derived guess may add a return, bridge a run reset, or turn the rear
context set into an attachment set.

## Identity and currentness

- `verified_fact` — the frozen snapshot binds the name and street number directly
  to this footprint.
- `verified_fact` — an SFPUC communications packet lists `1109`, `1111`, `1113`,
  `1115`, and `1117` Keppler Court in the same service context.
- `verified_fact` — TIDA's March 2026 Director's Report records a planned natural-
  gas interruption affecting **all buildings on Keppler Court**. This supports
  the court's continuing building/service context, not the tenancy or exact
  condition of `1113`.
- Confidence: **high exact identity/address and 2025 exterior survival; current
  occupancy, ownership, and post-November-2025 alterations unknown**.

## Primary and observation sources

| Source | Access | Supports | Use boundary |
| --- | --- | --- | --- |
| [SFPUC August 2021 communications](https://media.api.sf.gov/documents/081121_Item_4_Communications.pdf) | HTTP 200, 2026-09-04 | exact Keppler address cohort/service context | factual identity context only; no facade rights |
| [TIDA March 2026 Director's Report](https://media.api.sf.gov/documents/031126_Directors_Report.pdf), p. 3 | HTTP 200, 2026-09-04 | all-Keppler-buildings utility context | survival/context inference only; not occupancy or appearance |
| `1113K-SV01`, [front context](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8276235,-122.376855&heading=175&pitch=0&fov=75), pano `wwffTkz2DyE-wnlL73JVtA` | capture February 2018; locator rechecked 2026-09-04 | broad public/front context | Google observation only; no pixels stored/reused |
| `1113K-SV02`, [close public front](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8272912,-122.376818&heading=184&pitch=0&fov=75), pano `tgMj9xpYL0zAAAwf82nR8g` | capture April 2019; locator rechecked 2026-09-04 | NNE facade and displayed address | observation only; exact unit widths/alternation unresolved |
| `1113K-SV03`, [distant rear](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82689,-122.3771609&heading=49&pitch=0&fov=75), pano `BrOH3kQaEK0IOVN30IM9FQ` | capture November 2025; locator rechecked 2026-09-04 | SSW geometry/provenance and continued exterior presence | fence-hidden/distant; no rear material attachment |

No source image or crop is stored. Exact-item licensing must precede any later
pixel reuse; this packet needs only written observations.

## Observed public regions and recognition cues

Front NNE, February 2018 / April 2019:

- `reference_observation` — muted cool gray-blue horizontal lap/vinyl-like wall
  field with bright white trim, gutters, and downspouts;
- `reference_observation` — a shallow muted-gray shingle roof and a repeated
  two-storey unit-face rhythm: upper slider above a ground window plus dark
  burgundy/red-brown door;
- `reference_observation` — dark blue-gray privacy/bin enclosures interrupt the
  lighter siding, while full-height pale trim/downspouts mark some boundaries.

Rear SSW, November 2025:

- `reference_observation` — the long rear mass survives and appears lighter under
  different illumination, with upper opening groups;
- the lower rear is fence-hidden and the view is too distant to authorize a rear
  material, opening schedule, or unit module.

The two strongest target cues are the cool gray-blue/white-trim siding language
and the burgundy-door plus dark-enclosure unit rhythm. They are reference evidence,
but only the first is currently run-mapped at material-only confidence.

## Implementation-ready recommendation

Observed inputs:

- keep the front field cool gray-blue, matte/low-satin, with white trim as a
  later separate value family;
- preserve the observed shallow gray roof and opening/enclosure vocabulary as
  review targets, but do not bake them into this first material.

Reversible `production_inference`:

- first study: flat albedo/roughness only on a standalone panel and then, after
  independent review, exact front runs `11,12,14..18`;
- reasonable initial field bounds are linear value `0.40–0.60` and roughness
  `0.65–0.85`; these are production tuning bounds, not measured paint values;
- use cumulative metre-space mapping across each ordered side chain. Do not use
  generated U resets as semantic seams and do not add directional siding relief
  until physical course scale is independently supported;
- any future unit module must own a complete upper/ground opening state, door or
  no-door state, privacy enclosure, and trim/downspout boundary. No partial motif
  may cross a run or corner.

## Nonclaims, confusion set, and gate

Unknown/nonclaim: current occupants; exact siding substrate/course size; physical
unit widths; complete door/window alternation; both end elevations; lower rear;
return ownership; current colors; roof construction; interiors. Trees, dishes,
bins, vehicles, fences, and cast shadows are context, never facade motifs.

Pre-implementation confusion set: `1109` (`w96665915`), `1111`
(`w96665890`), `1115` (`w96665887`), and `1117` (`w96665928`) Keppler Court.
A generic gray-blue court-house repaint is not enough. Whole-object acceptance
must show at least two independent target cues at ordinary gameplay distance,
including one structural/cadence cue; a name label, address metadata, hue alone,
or the shared residential silhouette cannot count.

No human dependency for the first flat front prototype. A future module pass
requires a rights-cleared close, current, end-to-end front elevation (and a rear
view if rear authoring is desired), followed by exact endpoint mapping. Until
then, all modules, rear art, returns, and whole-unit recognition remain blocked.
