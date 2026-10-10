# Source packet — Treasure Island Community YMCA (`w34313547`)

Checked: **2026-09-04**; retained observations recovered **2026-10-10**
Readiness: **reference-ready for observed SSE entry and ENE service language**

## Exact binding and present state

| Field | Frozen/project fact |
| --- | --- |
| Source | OSM way `w34313547`, v6, `2024-02-20T01:39:43Z`; `Treasure Island Community YMCA`; no frozen address; `building=yes`, `height=9`, `leisure=sports_centre`, `brand=YMCA`, `check_date=2024-02-19`, `source=Yahoo` |
| Logical / wall receiver | `building:w34313547` / `building:w34313547:wall` |
| Chunk / geometry hash | `x_0__z_-2` / `5a0bf16c56ca9ad76a818a19042cf1b2e582f6e0722df2078c07a7156bc17da7` |
| Generated mass | `9 m`, base/top `4.102 / 13.102 m`; 30 runs / `267.240 m` visible wall |
| Mapped observed scope | SSE runs `3..7`, `72.979 m`; ENE material-safe runs `8..11`, `28.067 m` |
| Runtime/review | Exact homogeneous facade aggregate on runs `3..11` (`101.046 m`) is accepted/live; target-specific entry/site study002 now passes scoped gates below; whole-object recognition remains open. |

Binding authority: `discovery/FACADE_RECEIVER_INVENTORY.json`, YMCA facade
mapping/evidence, and current status ledgers. The accepted aggregate does not establish whole-object recognition or untouched-side fidelity.

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
was reconciled for the bounded 2026-10-10 study below; unobserved ownership remains unknown.

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

## 2026-10-10 observed entry/site closure

Candidate on `0f058e9`; scoped L1 basic envelope/site complete, L2–L5 unknown.
Reuse: retain generated L-shell/flat roof and aggregate material; housing gable/
carport base is structurally unsuitable. Source-bound additive entry/site geometry
uses the existing collision/spray attachment lifecycle. No frozen footprint,
source identity, main roof, neighbour, stock control or unseen architecture change.
The material adjustment uses existing project material/shader coefficients and palette,
with no new bitmap texture and never reference photos.

Dated originals recovered and inspected privately: September2025 `sse01.png` and
`ene02.png`, with the same Y-SV01/Y-SV02 pano IDs above, plus Apple satellite
layout (imagery date UNKNOWN; checked2026-10-10),
https://maps.apple.com/?ll=37.82648,-122.36848&z=19&t=k . Retained originals and
resolved source URLs remain outside Git under
`/workspaces/landmark-progress-20261007/ymca-references-20261010/` and the existing
private `breadth-next-family-note.txt`; no reference image is exported or served.
First SSE failed viewer capture is retained; one resolved-URL recovery succeeded.

Exact source join: `x_0__z_-2.json`, `building:w34313547:wall`,
X182.176..259.565/Z-338.651..-263.276. SSE camera XZ[241.512247,-253.869665],
heading330 intersects run5 at[226.460534,-279.939997] within SSE3..7.
ENE camera[277.652032,-303.117407],heading245 looks obliquely down SSE;
its right sector exposes ENE8..11. Provider658 Avenue M is camera context,
not building identity. Vegetation limits end detail; mural/adjacent low-wing
ownership and opposite-side openings remain unsupported. Apple supports L-body
and site context, not surveyed height or a horizontal-source change.

Study001 was VISUAL REWORK: entry cues existed but the small gray pavilion
underread beneath the tall hall. Study002 coherently widened/raised the complete
pavilion, canopy and glazing, retaining a thin cap and connected direct path/lawn.
Dimensions, anchors, cadence and lawn bounds are `production_inference`.
Independent `ymca_study002_visual` inspected all six current originals beside the
dated SSE/ENE references and Apple context, compared failed001 and baseline,
and all five fixed baseline/current island pairs: SCOPED VISUAL PASS, including
L1 envelope/site. The complete warm-pale entry/glazing/blue-gray cap now reads
as architecture; ENE service door/high louver fit the observed motif family.
No visible broad island regression. Different fallback poses prevent exact
camera-aligned measurement. Cooler/flatter aggregate, schematic roof shading,
uniform lawn and repetitive blank unknown north/west keep whole modern quality,
all-side L2, recognition and as-built acceptance OPEN. No motion claim from stills.

Independent `northpoint_third_family_code` ART/native-adapter CODE PASS
(0a3403/d322f9): exact source lifecycle, complete retained indexed shell and new
native wall/detail roles, source-owned spray, noncolliding ground visuals.
Actual land/visible-area sampling supports the bounded drape; visual paving/lawn
is not colliding support. `northpoint_fourth_mechanics` run27409 terminal0/72f7f8,
releasef64e58 passed native roles, all four stock approaches, entry path out/back
and pavilion spray, each with active supported input-released REST then SAFE_FINAL.
Outward rest[235.7141,-262.567] joins LAND facet113/EntryPath3; return
[228.4887,-276.1072] joins LAND112/EntryPath0. Spray rest[234.6163,-279.182]
joins LAND112/FrontLawn109; placed receiver `building:w34313547:wall` at
[233.2846,5.300004,-281.6848] is PavilionFlank's front plane plus projection offset.
Full `tools/test.sh`37970 terminal0/d16a15, releasebe80a1: ALL TESTS PASS,
49 scored fits, behaviour and world determinism. No rerun for bookkeeping.
Study002 capture21741 terminal0/fb919e, releaseeb49ac; actual Wayland/AMD780M
recorded by executor, with14 TextureRID shutdown warnings retained. Mechanics
retained7 TextureRID warnings without failed terminal. Gate results remain
separate; no new recognition numerator credit (49 historical credits/213 units).
