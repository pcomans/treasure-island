# Source packet — Maceo May (`r19685981`)

Checked: **2026-09-04**  
Readiness: **reference-ready for bounded outer ENE and SSE/SE work**

## Exact binding and present state

| Field | Frozen/project fact |
| --- | --- |
| Source | OSM relation `r19685981`, v1, `2025-10-07T00:49:31Z`; `building=apartments`, `building:levels=6`, `name=Maceo May` |
| Logical / wall receiver | `building:r19685981` / `building:r19685981:wall` |
| Chunk / geometry hash | `x_-1__z_1` / `3512c784e273edc8ed08e66c944dd6d198115afe8c8fa5073c9e386c693778ad` |
| Generated mass | `18 m`, flat base/top `4.430 / 22.430 m` NAVD 88 |
| Wall topology | 40 runs / `328.836 m`: outer `0..20` / `218.589 m`; inner courtyard `21..39` / `110.247 m` |
| Runtime/review | Shared placeholder remains live. Batch 02 material prototype is independently accepted with limitation; mapped outer SSE/SE runs `7..10` and outer ENE runs `11..16`; live attachment remains blocked by the recorded receiver/spec gates. |

Binding authority: `discovery/FACADE_RECEIVER_INVENTORY.json`,
`discovery/facades/MACEO_MAY_REFERENCE_SPEC.md`, and
`discovery/facades/BATCH_02_RUN_MAPPING.json`. The public address below augments
identity context; it does not mutate the frozen addressless source.

## Identity and currentness

- `verified_fact` — San Francisco legislation identifies the Maceo May project at
  **55 Cravath Street (formerly 401 Avenue of the Palms)** and describes 105
  rental units plus one staff unit. This is an exact name/project/address match.
- `verified_fact` — Mithun identifies its project as a six-story modular building
  on Treasure Island. SFPUC describes it as occupied housing in November 2023.
- Confidence: **high**. Currentness: identity/address and completed use are
  corroborated by owner/government sources; exact facade state is bounded by the
  September 2025 Street View observations.

## Primary and observation sources

| Source | Access | Supports | Use boundary |
| --- | --- | --- | --- |
| [SF Board file 221172](https://sfgov.legistar.com/LegislationDetail.aspx?GUID=EAC5FF9F-18C9-4E11-A402-4A2BC07BFD89&ID=5941804) | 2026-09-04 | exact name, current address/former address, unit program | text facts; no facade appearance |
| [Mithun project page](https://mithun.com/project/maceo-may-apartments/) | 2026-09-04 | architect/owner association, six-story modular identity, active-ground/place-based wayfinding intent | text facts; photographs copyright/observation-only |
| [Mithun heat-resilience article](https://mithun.com/2023/12/14/climate-approaches-heat-resilience/) | 2026-09-04 | exterior rainscreen, mineral-wool enclosure, argon glazing, modeled south/west shrouds and awnings | text facts; not exact elevation placement |
| [SFPUC occupied-project article](https://www.sfpuc.gov/about-us/news/coming-full-circle-veterans-coming-home-maceo-may-apartments) | 2026-09-04 | completed/occupied context and durable-material intent | text facts; photographs observation-only |
| `MM-SV01`, [broad ENE](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82095,-122.37220&heading=275&pitch=7&fov=78), pano `kEX8mV7OsuHLoA4oK69_KA` | UI validated 2026-08-29; capture Sep 2025 | outer ENE material, opening and graphite grammar | Google observation-only; no pixels retained |
| `MM-SV02`, [SSE entrance](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82060,-122.37225&heading=320&pitch=7&fov=78), pano `OKiASMGBFciyCsC9neeygg` | UI validated 2026-08-29; capture Sep 2025 | outer SSE/SE rib, rust, curtain wall, sign/address entrance | Google observation-only; no pixels retained |

## Observed recognition cues

- `reference_observation` — the ENE side reads as a **light/white rectilinear
  facade grid against substantial graphite regions**, rather than as one grey
  apartment texture.
- `reference_observation` — the SSE/SE entry side uses **fine vertical ribbing,
  warm rust-toned frames/accents, and a tall curtain-wall entry composition**.
- `reference_observation` — a vertical **MACEO MAY** name element and an entrance
  identifier beginning with `55` create a unique address-side anchor. Reproduce
  lettering only as a deliberate one-off, not as a repeating texture.
- `verified_fact` plus observation — solar shrouds/awnings belong specifically to
  modeled south/west conditions; they are not generic decoration for every side.

Observed region boundary: outer ENE and outer SSE/SE only. WSW, NNW, all inner
courtyard faces, roofs, and exact outer subregion endpoints are not observed.

## Implementation-ready recommendation

Observed inputs:

- retain distinct `MM-ENE-W`, `MM-SSE-W`, `MM-GROUND-N`, `MM-CW`, and unique
  `MM-ENTRY55` families from the existing spec;
- preserve the ENE light/graphite hierarchy and the SSE fine-rib/rust hierarchy;
- keep each complete window, curtain-wall, entrance, and sign motif whole.

Reversible `production_inference`:

- use facade-local metre-space layouts on the already mapped outer chains, with
  neutral PBR colors tuned under game lighting rather than sampled pixels;
- allow phase-neutral rainscreen/rib fields to repeat only inside one proven
  region; never reset at triangulation or chunk seams;
- if a conservative unobserved-side treatment is required for whole-object
  coherence, use only the dominant light enclosure family without copying the
  entry, sign, rust, window cadence, or shroud schedule.

Massing: keep the current six-level/18 m baseline. No primary source reviewed
here authorizes a footprint, roof, courtyard, balcony, or story correction.

## Nonclaims, confusion set, and gate

Unknown/nonclaim: exact products, rib pitch/depth, window dimensions/counts,
balcony/screen depth, WSW/NNW elevations, courtyard grammar, roof profile, and
transparent interiors. The current address is not a frozen OSM fact.

Likely confusion set: Star View Court, Hawkins, and 490 Avenue of the Palms. A
passing Maceo result must retain at least two of these independent cues at an
ordinary camera: (1) light/graphite ENE grid, (2) fine-rib/rust SSE language,
(3) the one-off Maceo/55 entry. Generic white apartment windows do not pass.

No human dependency is required for the bounded outer-side pass. Surveyed rear
or courtyard fidelity would require a separately licensed elevation set.
