# Source packet — Oasis / 401 California Avenue (`w291189918`)

Checked: **2026-09-04**

Readiness: **blocked on current identity-to-footprint and target-specific facade evidence**

## Exact binding and present state

| Field | Frozen/project fact |
| --- | --- |
| Source | OSM way `w291189918`, v2, `2025-11-07T19:02:35Z`; `Oasis - pizzeria & event venue`; `401 California Avenue, 94130`; restaurant/pizza/opening-hours/phone/website tags |
| Logical / wall receiver | `building:w291189918` / `building:w291189918:wall` |
| Chunk / geometry hash | `x_0__z_1` / `573aa4d8f2e47a1dae0d154c2d115c701c36cd32ef39fad1d6f191c1b475f9bb` |
| Generated mass | fallback `6 m`, base/top `3.630 / 9.630 m`; 34 runs / `216.121 m` visible wall |
| Run gate | all exact runs `0..33` protected; distant WSW/SSE observation is not endpoint-mapped |
| Runtime/review | Shared placeholder only; no target prototype or live attachment |

Frozen tags remain the game identity contract, but their 2025 edit timestamp does
not prove that the business values were current when copied. The `6 m` height is
a generator fallback, not a measured building fact.

## Identity and lifecycle reconciliation

- `verified_fact` — the current City business-location API returns six exact
  `401 California Ave` records. Oasis Bar and Grill and Treasure Island Event
  Venue both have May 15, 2018 location/end dates; other venue/business records
  end between 2015 and 2021, with Lev Probiotics' location ending in 2020.
- `verified_fact` — no active exact-address location was returned by that bounded
  query. This is evidence against assuming current Oasis operation, not proof
  that no unregistered/new operator exists.
- `verified_fact` — `treasureislandevent.com`, copied into the frozen source,
  returned no A/AAAA DNS answer on 2026-09-04.
- `reference_observation` — a low building is visible at the likely frozen
  footprint in September 2025, but no legible Oasis, pizzeria, venue, or `401`
  marker binds that appearance to the frozen business name.
- Confidence: **high frozen source/receiver identity; medium likely footprint
  observation; low current brand/use confidence**.

## Primary and observation sources

| Source | Access | Supports | Use boundary |
| --- | --- | --- | --- |
| [SF Registered Business Locations API, exact-address query](https://data.sfgov.org/resource/g8m3-pdis.json?%24limit=100&%24where=lower%28full_business_address%29%3D%27401%20california%20ave%27) | HTTP 200, 2026-09-04; six returned records | historical DBA/location names and end dates | absence is query-bounded; no facade evidence |
| Frozen `treasureislandevent.com` | DNS A/AAAA lookup returned no answer, 2026-09-04 | frozen website currently unresolved | not proof of demolition/vacancy |
| `OAS-SV01`, [distant likely WSW](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8190093,-122.3709789&heading=65&pitch=5&fov=72), pano `wWF9QvLiOmqohwnoD77DTg` | capture September 2025; locator rechecked 2026-09-04 | low light building and broad value hierarchy | Google observation only; no legible identity or exact runs |
| `OAS-SV02`, [distant WSW/SSE oblique](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.81882,-122.37080&heading=55&pitch=4&fov=68), pano `-pPwIOsi3zTgQd5N_VaeqQ` | capture September 2025; locator rechecked 2026-09-04 | partial second angle and mass continuity | distant/occluded; no brand, counts, dimensions, or endpoint ownership |

No external image is stored. Google pixels are observation-only, and City data
supports factual reconciliation rather than source-image reuse.

## Observed public regions and cue boundary

Likely WSW and partial SSE, September 2025:

- `reference_observation` — a low, light warm-cream mass with a dark gray-blue
  shallow roof/edge;
- `reference_observation` — an apparent broad central horizontal glazing/door
  band beneath a dark fascia/canopy-like edge.

These are real scene observations but **not yet target-specific recognition
cues**, because the distant views do not establish that the frozen Oasis business
occupies this exact structure. Counts, material substrate, sign, entry, canopy
depth, and opening boundaries are unreadable. ENE/rear, NNW, complete SSE, and
exact run endpoints are unobserved.

## Implementation recommendation

Observed inputs after identity resolution: warm light opaque field; dark shallow
roof/edge; broad central transparent/dark band on the resolved public side.

Reversible `production_inference` only after a primary or clear dated current
crosswalk:

- start with a flat cream albedo/roughness field on a newly endpoint-mapped
  uninterrupted public run subset;
- treat linear value `0.70–0.86`, roughness `0.60–0.84`, and a non-directional
  substrate as tuning bounds, not measured material data;
- hold glazing, doors, fascia/canopy, signs, pizza/venue branding, patio objects,
  and all other sides until complete motif boundaries are visible;
- never use the frozen name/website/phone as visual proof or acceptance cues.

Current safe implementation is **no target-specific output**. Shared placeholder
is less misleading than inventing a branded Oasis facade.

## Nonclaims, confusion set, and resolution gate

Unknown/nonclaim: current operator/use/name/opening hours/phone/website; precise
address-to-visible-building association; demolition/renovation history; all signs;
material substrate; opening/canopy counts and dimensions; patio ownership; exact
height/stories; all unobserved sides and interiors.

Pre-implementation confusion set: Dormitory Building 369 (`w291189926`), Job
Corps Food Service Building 368 (`w34313521`), Navy Chapel (`w291189336`), and
other low warm institutional buildings near California Avenue. Cream color, a
generic glazing band, `Oasis` text, or metadata cannot pass exact recognition.

Next autonomous step: search TIDA leasing/property records, DBI permits, assessor/
business filings, and current operator pages for an exact-address/footprint/use
crosswalk; then obtain a clear dated public-front view with a legible invariant.
If those sources remain exhausted, the narrow future `HUMAN.md` request is:
**confirm the current occupant/use of the exact 401 California footprint and
provide one rights-cleared current public-front and oblique exterior set**. Do not
stop progress on the other P3 units while this remains blocked.
