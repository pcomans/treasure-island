# Source packet — Austin Hall / Building 461 (`w34313569`)

Checked: **2026-09-04**
Readiness: **reference-ready with explicit 2006-historic / 2025-current split**

## Exact binding and present state

| Field | Frozen/project fact |
| --- | --- |
| Source | OSM way `w34313569`, v5, `2018-01-22T18:58:54Z`; `Bldg 461`; no frozen address/use/levels; `building=yes`, `height=8`, `source=Yahoo` |
| Logical / wall receiver | `building:w34313569` / `building:w34313569:wall` |
| Chunk / geometry hash | `x_-1__z_-4` / `2d83069b1999087c4a685500d0b90516349ffa1b55e239656083ae7d789ddd02` |
| Generated mass | `8 m`, base/top `3.525 / 11.525 m`; 27 runs / `207.182 m` visible wall |
| Mapped scope | medium-confidence runs `4..10`, `86.020 m` |
| Runtime/review | Study002 observed facade/site WIP on f02652b; scoped VISUAL/CODE/native/full suite PASS. L1 complete; whole modern quality remains open. |

Binding authority: `discovery/FACADE_RECEIVER_INVENTORY.json`, Building 461
mapping/evidence, and current lifecycle ledgers.

## Identity and currentness

- `verified_fact` — the Navy’s 2006 historical resources assessment identifies
  **Building 461**, constructed in 1970, as part of the Damage Control School
  complex with Buildings 462/463 and USS *Pandemonium*. It records Damage Control
  classrooms, Naval Technical Training Center headquarters, and fire-training use,
  and says the building was vacant in 2006.
- `reference_observation` — the report’s Building 461 photograph labels the entry
  **AUSTIN HALL**, establishing a historically observed building-specific name.
- `verified_fact` — the Navy’s 2014 HRA update again crosswalks B461 and says it
  was leased to TIDA while retaining the Damage Control history.
- `reference_observation` — a November 2025 panorama shows the long Building 461
  mass still standing from a distant southeast/east view.
- Confidence: **high identity/crosswalk and 2025 survival; current use/name/sign
  and fine facade details unknown**.

## Primary and observation sources

| Source | Access | Supports | Use boundary |
| --- | --- | --- | --- |
| [Navy 2006 Historical Resources Assessment](https://media.defense.gov/2022/Mar/22/2002960667/-1/-1/0/TI_200602_HRA.PDF) | readable in research; CLI returned 403, 2026-09-04 | B461 construction/use/context; labeled facade photo and Austin Hall sign | government-hosted contractor report; linked/observation-only; verify exact photo rights before reuse |
| [Navy 2014 HRA Update, part 1](https://media.defense.gov/2022/Mar/22/2002960669/-1/-1/0/TI_20140701_HRASTM_PT1OF2.PDF) | readable in research; CLI returned 403, 2026-09-04 | B461 crosswalk, lease context, Damage Control history | identity/lifecycle; no claim of 2026 use |
| [2023 SF revised SGMP](https://www.sf.gov/sites/default/files/2023-12/SGMP_0004-007-005%20Treasure%20Island_Rev%2003-17-23-compressed.pdf) | HTTP 200, 2026-09-04 | mapped B461 site context | footprint context; not detailed elevation |
| `B461-SV01`, [distant southeast/east](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8310739,-122.370928&heading=312&pitch=0&fov=75), pano `JMpuxlpS4Re0BFnlc7D1pA` | capture November 2025; project UI validated | current survival, mass, broad value divisions | Google observation-only; insufficient for sign/windows |

No external photograph or crop is stored in Git/game. Actual2025 originals were
recovered privately on2026-10-10, as recorded below. The linked Navy photograph informs
observations; its government host does not by itself settle contractor-photo rights.

## Observed recognition cues and regions

Current, November 2025:

- `reference_observation` — a long, low/two-story industrial-institutional mass
  with a flat/parapet roofline, cool-grey main field, and thin darker roof edge;
- `reference_observation` — dark vertical divisions interrupt the broad field,
  while a pale warm-grey/tan end region provides a strong value change.

Historical, 2006 Navy photograph:

- `reference_observation` — the long plain grey-brown elevation is articulated by
  strong dark vertical structural bands;
- `reference_observation` — two recessed entrance areas sit near left-of-center,
  with an `AUSTIN HALL` sign above them; open paved foreground/trees/fence frame
  the view but are context, not facade modules.

Mapped candidate boundary: runs `4..10` (`86.020 m`), medium confidence. The exact
relationship of the 2006 photographed elevation and entrance offsets to transformed
receiver runs must be checked before layout attachment.

## Implementation-ready recommendation

Observed inputs:

- use the accepted cool-grey main and pale warm-end value families;
- establish several non-uniform dark vertical divisions rather than a repeated
  generic window grid;
- treat the paired recessed-entry rhythm as historically observed, side-local,
  and currentness-limited; do not claim the sign survives in 2025.

Reversible `production_inference`:

- fit the broad current value fields first to mapped runs `4..10`;
- if the game intentionally represents the frozen/historical building, proxy the
  two shallow recesses with geometry and a restrained sign zone; label review
  evidence “historic-reference reconstruction,” not current as-built;
- if current-only representation is required, omit sign lettering and retain only
  current-visible mass/value/band cues until a closer dated view is obtained;
- do not paint roof depth, foreground fence, trees, or paved apron into the wall.

## Nonclaims, confusion set, and gate

Unknown/nonclaim: current tenant/use/Austin Hall sign; current windows/doors and
entrance survival; exact colors/materials/dimensions; unobserved sides; transformed
historic offset; roof/interior; post-November-2025 changes.

Likely confusion set: Buildings 462/463, other long Navy training/warehouse blocks,
and generic grey campus buildings. A passing historical-snapshot result must show
at least two independent cues: (1) long cool-grey field with dark structural bands,
(2) paired recessed entrances left-of-center, or (3) pale warm end/value break and
thin dark roof edge. A grey repaint or `461` label does not pass. A current-only
result cannot rely on the unverified Austin Hall sign.

No human dependency for a bounded historical/current-value candidate. Next step:
reconcile the Navy photograph’s side and entrance region to runs `4..10`, then
review a reversible composition with the evidence date visible. A licensed close
current exterior set would improve certainty but must not block the other P2 units.

## 2026-10-10 source-grounded study002 — WIP

ROOT accepted scoped L1 basic architecture/site only after all separate gates.
L2–L5 remain U; catalog reference_recognizable remains not_evaluated, with a scoped
numerator_effect0 record. Whole recognition/as-built unclaimed;49 historical
credits/213 units unchanged. The historical
reconstruction option above is not the chosen current study: no2006 sign or paired
entry is invented. Reuse exact generated institutional shell/roof and shared
source-bound collision/spray infrastructure; housing gable/carport base is unsuitable.

Actual private originals: November2025 `se01.png` (panoJMpuxlpS4Re0BFnlc7D1pA),
March2025 `front02.png` (panoHuJnJWLYqiMKqqogJNf3oA), and Apple layout with imagery
date UNKNOWN, checked2026-10-10. Source folder:
`/workspaces/landmark-progress-20261007/austin461-references-20261010/`.
Resolved Google URLs and recovery notes remain in the existing private
`breadth-next-family-note.txt`. March view required one resolved-URL recovery;
failed original retained. Apple request:
https://maps.apple.com/?ll=37.83148,-122.37145&z=19&t=k . It supports footprint/
roof/site context, not measured height or current facade appearance.
November camera XZ[13.365565,-813.049731],heading312 first hits run8 at
[-13.567561,-837.300427]; March camera[0.615519,-818.170427],heading350 hits run9
at[-7.148856,-862.204389]. Both observe ENE and adjacent SSE obliquely;
Google1298 Avenue M is camera context, not source identity. Exact target remains
`building:w34313569:wall`, chunk`x_-1__z_-4`. Vehicles/graffiti obscure door
identity. Unknown NNW/WSW openings, historic sign and neighboring industrial
structures remain excluded. Reference photos remain outside Git/game/gallery.

The current observed family comprises warm-tan upper fields, muted gray-green
lower fields, upper narrow slots on SSE4..7, ENE8..10 lower recessed infill/piers,
thin coping, pale end projection and an immediate apron connected to roads.
Dimensions/cadence/anchors are reversible production_inference. Source footprint,
height, roof and unknown rear remain unchanged. Apron is visual-only, sampled
above actual LAND/visibleAREA and clipped against frozen roads/buildings; it does
not replace LAND collision. No new bitmap material/reference-photo texture.

Study001 capture66877 terminal0/002796, releasec2ff27 improved the blank baseline
but early independent VISUAL REWORK and checkpoint_461_progress identified its
full-height black lower backs against March's pale infill/short dark heads. This
was an early scoped finding, not a completed final001 visual verdict. Author
transfer retained prior work; no inactivity cause is asserted. Named correction
owner austin461_lower_family_art reused the complete emitter/roles, changing the
whole lower row to1.12m pale recessed bays and0.34m dark heads. Source shell,
upper slots, terminal projection and apron remained. Study002 capture37734
terminal0/0804ff and actual process release; north view unavailable,14 TextureRID
shutdown warnings retained. Available views do not supply an all-side claim.

Independent austin461_code passed initial source/hook, shared mixed descriptor,
and final changed lower-family seams. Explicit physical roles preserve opaque
source-owned wall spray and complete native coverage. northpoint_fourth_mechanics
current native/four stock approaches/apron out-back/exact opaque spray PASS96107
terminal0/9471db; all cases active supported input-released zero REST then SAFE.
Actual out[-46.10793,-842.549] joins LAND80/apron4; return[-55.05934,-845.2118]
joins LAND79/apron3; spray rest[-50.16104,-845.3194] joins LAND80/apron4.
Full tools/test.sh80401 terminal0/116992, release997a76, ALL TESTS PASS3dc64b:
49 scored fits,213 inventory, behaviour, world validation/determinism. No rerun.
Final independent checkpoint_461_progress VISUAL study002 PASS followed actual
March/November references, unknown-date Apple layout, all five available current
views, both contexts and all five fixed baseline/current island pairs. The pale
infill/short dark heads resolve the substantive lower-family mismatch; no broad
island regression observed. Missing north, unknown rear and schematic materials
keep all-side L2, whole modern quality/recognition and as-built OPEN. This is a new
independent visual decision, not inferred from prior progress or technical proof. austin461_code's later progress sample found a
substantive correction and no sampled island-scale regression, with unknown rear
and omitted north still open. Whole modern quality/as-built remain unclaimed.

Runtime boundary: `panel_hall_facade.gd` and normal `.uid`,
`austin461_observed.json`, exact-source hook in `world_chunk_builder.gd`, and
shared descriptor extension in `building_fit_test.gd` (five paths). No source edits
in this documentation round. Existing gallery carries two untouched study002
originals,100 total; scoped gates PASS labels retain WIP/unpublished status until an actual commit.
