# Source packet — Education Center Building 29B (`w34313523`)

Checked: **2026-09-04**
Readiness: **blocked on exact current state and target facade evidence**

## Exact binding and present state

| Field | Frozen/project fact |
| --- | --- |
| Source | OSM way `w34313523`, v4, `2011-05-01T10:26:03Z`; `Education Center Building 29B`; `768 Avenue H`; `building=abandoned`, `building:levels=1`, `source=Yahoo` |
| Logical / wall receiver | `building:w34313523` / `building:w34313523:wall` |
| Chunk / geometry hash | `x_0__z_-1` / `113b1a9fdc5d6b07d2fe6b6863fe601db268debb6bd37151fe7bb247f8f6ad45` |
| Generated mass | `3 m`, base/top `3.515 / 6.515 m`; 20 runs / `163.385 m` visible wall |
| Runtime/review | Shared placeholder live; target evidence remains blocked. |

The frozen name/address remain the game identity contract. No checked independent
source enumerates the `29B` suffix strongly enough to promote it to a current
real-world claim.

## Identity and demolition-state reconciliation

- `verified_fact` — official Navy/TIDA February 2024 minutes say TIDA removed a
  drip line at the **former Building 29** site on January 16, 2024.
- `verified_fact` — official May 2024 meeting minutes say TIDA demolished
  **buildings at the site of former Building 29** on February 14–15, 2024.
- `unknown` — neither record enumerates Building 29B or supplies a sub-building
  crosswalk. It is therefore plausible, but **not verified**, that `w34313523` was
  among the removed structures.
- Confidence: **high frozen historical game binding; unresolved independent 29B
  identity and current survival**. Do not silently delete the frozen game unit or
  relabel it “demolished.”

## Primary and observation sources

| Source | Access | Supports | Use boundary |
| --- | --- | --- | --- |
| [NSTI February 2024 meeting minutes](https://media.defense.gov/2024/May/16/2003467241/-1/-1/0/NSTI_FEB0624_MTG_MINUTES_FINAL.PDF) | readable in research; CLI returned 403, 2026-09-04 | former-B29-site drip-line removal date | site-level lifecycle only; no 29B enumeration/facade |
| [NSTI May 2024 meeting minutes](https://media.defense.gov/2024/Aug/21/2003530260/-1/-1/0/NSTI_RAB_MTGMINS_050724.PDF) | readable in research; CLI returned 403, 2026-09-04 | Feb. 14–15 demolition of buildings at former-B29 site | site-level lifecycle only; no 29B enumeration/facade |
| `EC29B-SV01`, [obstructed site view](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8247245,-122.3684129&heading=224&pitch=0&fov=75), pano `gnRrpIe5wBUEXwYoTcE6NQ` | capture March 2025; project UI validated | green corrugated perimeter/container barrier obscures site | negative visibility evidence only |
| `EC29B-SV02`, [obstructed site view](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8244589,-122.3694416&heading=95&pitch=0&fov=75), pano `xPpjSLPIE2h--fbX_TB8OA` | capture September 2025; project UI validated | redevelopment enclosure; no attributable target elevation | negative visibility evidence only |

The green corrugated barrier/container belongs to site work, not to the frozen
building facade, and must never be copied onto this receiver.

## Supported cues and implementation boundary

There are **zero target-facade recognition cues** in the checked evidence. The low
one-story frozen mass and education/address metadata are project facts, not observed
materials or motifs. No “schoolhouse,” Navy classroom, demolition fence, or generic
Job Corps treatment is supportable.

Safe reversible `production_inference`: preserve the frozen receiver and shared
placeholder while resolving whether the product depicts the historical frozen
world state or a current redeveloped state. That product choice cannot by itself
supply an appearance; a historic representation still needs historic evidence.

## Nonclaims, confusion set, and resolution gate

Unknown/nonclaim: exact 29/29B relationship, whether 29B was removed, demolition
scope, surviving fabric, all historical elevations/materials/openings/signage,
exact current site use, and interiors.

Likely confusion set: Building 29 versus subunit 29B, adjacent Job Corps education
buildings, and the 2025 construction enclosure. No visual acceptance is possible
until current-state scope is resolved and at least two real cues are sourced.

Next autonomous step: obtain the TIDA demolition permit/contract, hazardous-material
appendices, parcel exhibit, or as-built completion record and search for explicit
`29B`/`768 Avenue H` enumeration plus a marked footprint. If 29B was removed but
the frozen historical representation remains in scope, search Navy HRA/HABS and
transfer-condition records for a dated elevation. If those sources remain
exhausted, the narrow `HUMAN.md` request is: **ask TIDA/Naval Facilities for a
marked demolition exhibit resolving Building 29B and one rights-cleared historic
exterior view if the frozen building must remain visually represented**.
