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
| Runtime/review | No target facade live. Corrected cool-grey field and pale-end swatches accepted as standalone samples; no full composition accepted. |

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

No external photograph or crop is stored. The linked Navy photograph informs
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
