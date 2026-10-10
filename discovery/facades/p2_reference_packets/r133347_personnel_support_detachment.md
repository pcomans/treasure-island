# Source packet — Personnel Support Detachment (`r133347`)

Checked: **2026-09-04**
Readiness: **reference-ready for mapped outer east and north runs**

## Exact binding and present state

| Field | Frozen/project fact |
| --- | --- |
| Source | OSM relation `r133347`, v2, `2017-04-25T16:17:43Z`; Treasure Island Personnel Support Detachment; `550 4th Street`; `building=abandoned`, `building:levels=2` |
| Logical / wall receiver | `building:r133347` / `building:r133347:wall` |
| Chunk / geometry hash | `x_0__z_1` / `4deddd70679c4c9dc8c9308eebedf3395b92e2f8312cda3550a47a70e28a1745` |
| Generated mass | `6 m`, base/top `4.051 / 10.051 m`; 28 runs / `250.796 m` visible wall |
| Ring boundary | outer runs `0..17`, `201.334 m`; inner/courtyard runs `18..27`, `49.462 m` |
| Runtime/review | Shared wall live. Prototype accepted off receiver; east runs `8..12` (`49.234 m`) and north runs `13..17` (`51.429 m`) mapped; attachment remains blocked. |

Binding authority: `discovery/FACADE_RECEIVER_INVENTORY.json`, the existing PSD
reference specification, and its retained mapping/evidence records.

## Identity and currentness

- `verified_fact` — the 1995 Federal Register lists **Personnel Support Activity
  Detachment Treasure Island** at **550 4th Street**. It also lists Naval Legal
  Service Office Detachment at the same address, so exclusive occupancy is not
  established.
- Confidence: **high historical footprint/address binding**. The 2021 and 2025
  public observations show the building, but no authoritative current tenant/use
  source was found. “Personnel Support Detachment” remains the frozen/historical
  identity rather than a claimed 2026 use.

## Primary and observation sources

| Source | Access | Supports | Use boundary |
| --- | --- | --- | --- |
| [Federal Register, 1995 base directory](https://www.govinfo.gov/content/pkg/FR-1995-08-17/pdf/95-20417.pdf) | HTTP 200, 2026-09-04 | federal unit and exact `550 4th Street` address | textual identity only; no facade evidence |
| `PSD-SV01`, [east outer side](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82145,-122.36730&heading=255&pitch=0&fov=75), pano `GAuBhldmLlZOQwXj8qav3w` | capture June 2021; project UI validated | broad east outer elevation | Google observation-only |
| `PSD-SV02`, [north/east corner](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82170,-122.36815&heading=205&pitch=0&fov=80), pano `_rk3B0PasMLUEPCQCA_sJw` | capture September 2025; project UI validated | north/east corner and upper volume | Google observation-only |

## Observed recognition cues and region

- `reference_observation` — a near-charcoal structural/mullion grid organizes
  cool grey-blue glazing and near-black lower opaque panels.
- `reference_observation` — gray-tan opaque infill interrupts that darker glazed
  grid; the two facade tiers include a distinct upper transom row.
- `reference_observation` — a thin flat roof edge is backed by a screened/louvered
  rooftop volume, legible above the north/east corner.

Observed/mapped boundary: east outer runs `8..12` and north outer runs `13..17`.
South, west, and every courtyard run remain unobserved. The inner ring is a hard
protected scope, not a place to mirror the outer facade.

## Implementation-ready recommendation

Observed inputs:

- preserve the hierarchy `charcoal grid > blue-grey glazing > black lower panels
  > gray-tan infill`, with two tiers and a thin transom band;
- keep the rooftop louver/screen as a separate massing cue if an approved prop or
  massing path exists; do not paint it into the wall as a false silhouette;
- limit unique layouts to the exact mapped east and north outer chains.

Reversible `production_inference`:

- fit a small set of reference-relative grid bays to each mapped side rather than
  tiling one window cell around the building;
- use the same low-information material family on unmapped outer sides only if a
  whole-object pass requires continuity; retain the shared facade on courtyard runs;
- make pane/transom contrast readable at ordinary camera distance without claiming
  surveyed bay counts or dimensions.

## Nonclaims, confusion set, and gate

Unknown/nonclaim: current tenant and name; south/west/courtyard appearance; exact
glass products, bay counts, dimensions, rooftop equipment, entrances, signage,
interiors, and post-September-2025 alterations.

Likely confusion set: nearby Job Corps institutional blocks and other low flat-roof
campus buildings. A passing review must show at least two independent cues:
(1) dark structural grid with blue-grey glazing/black lower panels, (2) gray-tan
infill plus two-tier transom rhythm, or (3) the screened rooftop volume. A generic
blue-window office texture or identity label does not pass.

No human dependency: use the already mapped east+north prototype boundary for the
next bounded review. Any request to cover the courtyard or claim exact all-side
layouts requires new dated elevation evidence first.

## 2026-10-10 readiness hold — no modeling authorization

Named readiness owner austin461_lower_family_art found no retained actual PSD
exterior/layout pixels in the bounded local search; existing PSD images are
synthetic material prototypes. Earlier reference-ready prose is not sufficient
current pixel evidence. Recover/inspect the retained June2021 east pano
`GAuBhldmLlZOQwXj8qav3w` and September2025 north/corner pano
`_rk3B0PasMLUEPCQCA_sJw`, plus useful Apple courtyard/roof context, before ROOT's
source-sufficiency decision. No acquisition or modeling occurred in this round.
Existing private lower-family-correction-note.txt retains the concrete readiness
assignment and URLs. Exact source is relationr133347 (outerw34313505,
innerw34313506), receiverbuilding:r133347:wall inx_0__z_1. Protect courtyard18–27,
unknown south/west and frozen shell; outer east8–12/north13–17 remain the bounded
candidate. Shared panel-hall integration is potentially reusable, but a two-tier
grid/transom family must follow actual pixels, not inherited slot dimensions.
All current stage/recognition claims remain unchanged; no new research undertaken.

## 2026-10-10 recovered pixels and baseline — scoped readiness adequate

The earlier missing-pixel HOLD above is retained as history. Actual private
`psd-references-20261010/east01.png` (June2021), `northeast02.png` (September2025)
and `apple-layout03.png` (imagery date UNKNOWN) are now acquired and inspected
by the named author and ROOT. The two exact pano IDs above resolve the east and
north/east corner, supporting the charcoal two-tier grid/transom family, varied
blue-gray/dark/tan fields, thin roof edge and bounded roof-screen interpretation.
Apple layout https://maps.apple.com/frame?z=19&map=satellite&center=37.821650%2C-122.368000&span=0.001684%2C0.001966
supports outer rectangle/inner courtyard topology only, not courtyard elevations
or measured screen heights. Lower doors/base remain occluded; detailed infill
sequence and exact screen bounds remain production inference. Courtyard18–27 and
unknown west/south remain protected. No physical fence/access restriction implied.

Browser80677 terminal143/fee2ec followed intentional shutdown; global absence
a30f03 confirms release. Current shared baseline38499 terminal0/c80a42 and
release303081 contains all four closeups, two contexts and five fixed island
views. Sourcef02652b plus tested461 WIP; exact PSD shell/roof/source/courtyard
unchanged. Blank pale baseline lacks the observed complete grid/transom/screen
family. Actual Wayland/AMD780M and14 TextureRID shutdown warnings retained in
private ordinary source/baseline note. No model has been authored: source readiness
is adequate for this bounded observed family, modeling still awaits ROOT GO.
Reference originals remain private outside Git/game/gallery; no reacquisition or
additional research was performed for this documentation update.
