# Source packet — SFFD Treasure Island Training Facility Building 600 (`w34313548`)

Checked: **2026-09-04**
Readiness: **reference-ready for the observed WSW/public-entrance side**

## Exact binding and present state

| Field | Frozen/project fact |
| --- | --- |
| Source | OSM way `w34313548`, v6, `2026-05-21T20:17:25Z`; `San Francisco Fire Dept Treasure Island Training Facility Building 600`; `750 Avenue M`; `building=yes`, `height=6`, `source=Yahoo`; old name `US Naval Station Treasure Island Shipboard Firefighting School` |
| Logical / wall receiver | `building:w34313548` / `building:w34313548:wall` |
| Chunk / geometry hash | `x_1__z_-2` / `05e283146e348c2f2c7f98daeb0fd7b2370f307fc4252e1cfef7e23670689d0e` |
| Generated mass | `6 m`, base/top `4.064 / 10.064 m`; 24 runs / `243.359 m` visible wall |
| Mapped observed scope | WSW runs `0..9`, `104.122 m` |
| Runtime/review | No target-specific live facade. Corrected prototype was `REJECT_CORRECTABLE` after flattening the required coarse mineral field; its one authorized correction is exhausted. |

Binding authority: `discovery/FACADE_RECEIVER_INVENTORY.json`, Building 600
reference/mapping/evidence, and current lifecycle ledgers. This packet does not
reset or override the recorded rejection/correction budget.

## Identity, dual addresses, and currentness

- `verified_fact` — SFFD’s official facility page identifies **Treasure Island
  Training Facility, Building 600**, at `649 Avenue N`, with entrance on 10th Street.
- `verified_fact` — a November 2025 official TIDA utility notice identifies the
  **SFFD TI Fire Training Facility campus, 750 Avenue M**.
- `verified_fact` — Bay Area UASI’s official 2026 training listing uses **SF Fire
  Dept TI, 750 Avenue M, Building 600**.
- Confidence: **high current identity**. `750 Avenue M` is a campus/delivery
  address while `649 Avenue N`/10th Street describes public approach; this is not
  evidence that either authoritative source is wrong.

## Primary and observation sources

| Source | Access | Supports | Use boundary |
| --- | --- | --- | --- |
| [SFFD facility page](https://sf-fire.org/node/1598) | HTTP 200, 2026-09-04 | current facility/B600 and public entrance address | owner identity/access; not a facade schedule |
| [TIDA November 2025 utility notice](https://media.api.sf.gov/documents/11.19.25_Communications.pdf) | HTTP 200, 2026-09-04 | campus name and `750 Avenue M` | campus/address currentness; no facade |
| [Bay Area UASI 2026 course location](https://bayareauasi-ca.gov/node/376) | HTTP 200, 2026-09-04 | `750 Avenue M, Building 600` | official event location; no facade schedule |
| `B600-SV01`, [entrance-side context](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8262806,-122.3677375&heading=25&pitch=0&fov=75), pano `ifdNQ-gh7K1ryx3rVMvW2w` | capture September 2025; project UI validated | warm coarse field, windows, red portal | Google observation-only |
| `B600-SV02`, [entrance oblique](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82672,-122.36800&heading=80&pitch=0&fov=75), pano `t8V4SOhQFPRXL_vukoMRog` | capture September 2025; project UI validated | portal depth/sign/bollards and facade rhythm | Google observation-only |

## Observed recognition cues and region

- `reference_observation` — a warm light cream/pale-grey **coarse mineral or
  block-like wall field** has visible 0.20–0.50 m-scale depth/variation; it is not
  a smooth flat fill.
- `reference_observation` — a single horizontal row of cool blue-grey windows with
  pale surrounds establishes a restrained institutional rhythm.
- `reference_observation` — the unique entrance is a dark-red arched projecting
  portal/canopy with a dark ribbed/slatted soffit, pale `SFFD FIRE FIGHTING SCHOOL`
  lettering, protective bollards, and red `600` marker.

Observed/mapped boundary: WSW runs `0..9`. ENE, NNW, and remaining sides are not
established well enough for unique schedules.

## Implementation-ready recommendation

Observed inputs:

- make the coarse warm mineral/block field the dominant identity layer and retain
  readable depth at ordinary camera distance;
- build the red entrance portal as actual shallow geometry/prop where permitted,
  including arch/projecting depth and dark soffit, rather than painting a false arch;
- use one restrained window row and one `600` marker/sign zone on the observed side;
  avoid repeating the portal or signage.

Reversible `production_inference`:

- approximate coarse relief without claiming exact block sizes or material;
- fit window and portal spacing reference-relatively within the mapped chain;
- simplify text to a legible, non-trademarked project treatment only if the rights/
  signage policy permits; portal color/shape plus `600` can carry recognition if not;
- retain shared/low-information warm field on unobserved sides.

The prior correction’s flattened surface contradicted the evidence and remains
rejected. A new attempt must be a separately authorized candidate under the normal
lifecycle—not an edit that launders the rejected artifact or silently resets its gate.

## Nonclaims, confusion set, and gate

Unknown/nonclaim: exact masonry/mineral product, module depths, dimensions, full
letterforms, window count/spacing, doors behind portal, unseen sides, roof/interior,
and post-September-2025 facade changes.

Likely confusion set: other pale Job Corps/Navy campus blocks and generic fire
stations. Passing requires at least two independent cues: (1) coarse warm mineral
field, (2) red arched deep portal/dark soffit, or (3) single cool window band with
the side-local `600`/school zone. A flat cream repaint plus red rectangle does not pass.

No human source dependency. Next bounded implementation input is the exact mapped
WSW scope and the two 2025 panoramas. Lifecycle authorization for a fresh candidate
must remain explicit because the earlier correction opportunity was exhausted.
