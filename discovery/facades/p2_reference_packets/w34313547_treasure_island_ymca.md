# Source packet — Treasure Island Community YMCA (`w34313547`)

Checked: **2026-09-04**
Readiness: **reference-ready for observed SSE entry and ENE service language**

## Exact binding and present state

| Field | Frozen/project fact |
| --- | --- |
| Source | OSM way `w34313547`, v6, `2024-02-20T01:39:43Z`; `Treasure Island Community YMCA`; no frozen address; `building=yes`, `height=9`, `leisure=sports_centre`, `brand=YMCA`, `check_date=2024-02-19`, `source=Yahoo` |
| Logical / wall receiver | `building:w34313547` / `building:w34313547:wall` |
| Chunk / geometry hash | `x_0__z_-2` / `5a0bf16c56ca9ad76a818a19042cf1b2e582f6e0722df2078c07a7156bc17da7` |
| Generated mass | `9 m`, base/top `4.102 / 13.102 m`; 30 runs / `267.240 m` visible wall |
| Mapped observed scope | SSE runs `3..7`, `72.979 m`; ENE material-safe runs `8..11`, `28.067 m` |
| Runtime/review | Exact homogeneous facade aggregate on runs `3..11` (`101.046 m`) is accepted/live; target-specific modules and whole-object recognition remain blocked. |

Binding authority: `discovery/FACADE_RECEIVER_INVENTORY.json`, YMCA facade
mapping/evidence, and current status ledgers. The accepted aggregate does not
automatically authorize entry/service modules or untouched sides.

## Identity and currentness

- `verified_fact` — the YMCA of San Francisco currently identifies this location
  as **Treasure Island Community YMCA**, **749 9th Street**.
- `verified_fact` — a July 2024 official TIDA directors report independently lists
  Treasure Island Community YMCA at `749 9th Street`.
- Confidence: **high identity/address and current operation** as checked. The
  official address supplements the addressless frozen record; it does not alter it.

## Primary and observation sources

| Source | Access | Supports | Use boundary |
| --- | --- | --- | --- |
| [YMCA of San Francisco location page](https://www.ymcasf.org/location/embarcadero-ymca/treasure-island-community-ymca/) | HTTP 200, 2026-09-04 | current name, programs, `749 9th Street` | owner identity/currentness; no exact elevation schedule |
| [TIDA July 2024 directors report](https://www.sf.gov/sites/default/files/2024-07/071024%20Item%20Directors%20Report_1.pdf) | HTTP 200, 2026-09-04 | independent exact name/address | current location context; no elevation |
| `Y-SV01`, [SSE entrance](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82605,-122.36825&heading=330&pitch=6&fov=78), pano `d0oKpsvA2eE-WM-C7gVokA` | capture September 2025; project UI validated | entrance-side material and portal | Google observation-only |
| `Y-SV02`, [ENE service side](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82645,-122.36785&heading=245&pitch=5&fov=78), pano `BM2ooxp-6GhmR934Ah2PVA` | capture September 2025; project UI validated | louver and service-door region | Google observation-only |
| `Y-SV03`, [partial NNW](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82688,-122.36855&heading=155&pitch=5&fov=78), pano `NVAmGBSgPlk8h5g-8-od9g` | capture May 2019; project UI validated | partial rear/context only | Google observation-only; currentness weaker |

## Observed recognition cues and region

- `reference_observation` — the main mass has dark warm-grey/brown, visibly rough
  exposed-aggregate/pebbled precast fields separated by thin cool blue-grey joints.
- `reference_observation` — the SSE entrance is a projected warm-white vestibule/
  portal with a blue-grey canopy/fascia and glazed door/sidelight composition.
- `reference_observation` — the ENE service side includes a high light-grey louver
  and a dark-blue service door against the rough darker field.

Observed regions: SSE entry side, ENE service region, and only a partial 2019 NNW
context. Ownership/extent of a mural and adjacent low wing is not proven; neither
may be absorbed into this receiver. The side chains are mapped, but exact
within-run placement/ownership for the distinctive portal and service modules
still requires layout reconciliation.

## Implementation-ready recommendation

Observed inputs:

- retain the accepted low-frequency rough aggregate field and cool joint logic;
- place one warm-white projected entrance/canopy/glazing composition only within
  mapped SSE runs `3..7`, after its within-run placement is reconciled;
- place one light louver/dark-blue service-door composition only on mapped ENE
  runs `8..11`, after its within-run placement is reconciled;
  service region; neither motif repeats around the mass.

Reversible `production_inference`:

- simplify aggregate depth into a legible coarse, non-flat relief that survives
  ordinary camera distance without imitating exact stones;
- fit portal/louver proportions reference-relatively to the receiver; do not claim
  surveyed dimensions or bay counts;
- leave NNW/other unknown regions on the accepted material family without unique
  windows, murals, or entrances.

## Nonclaims, confusion set, and gate

Unknown/nonclaim: exact run endpoints for modules; unseen sides; exact aggregate
product/stone sizes; joint dimensions; door hardware; signage lettering; mural
ownership; adjacent low-wing ownership; roof/interior; post-September-2025 changes.

Likely confusion set: other dark precast campus/community buildings. A passing
result must show at least two independent cues: (1) coarse warm-dark aggregate
with cool joints, (2) the warm-white projected SSE vestibule and blue-grey canopy,
or (3) the ENE high louver/dark-blue service door. Generic dark concrete, a YMCA
logo, or accepted material alone does not establish whole-object recognition.

No human dependency. Next bounded step: reconcile module placement inside the
already mapped SSE `3..7` and ENE `8..11` chains, produce only the two non-repeating
modules, and retain the current accepted aggregate elsewhere. Require before/after
ordinary-distance evidence for whole-object status.
