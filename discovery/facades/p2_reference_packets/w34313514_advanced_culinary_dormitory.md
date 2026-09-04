# Source packet — frozen “Advanced Culinary Dormitory” (`w34313514`)

Checked: **2026-09-04**
Readiness: **blocked on exact identity crosswalk and target facade evidence**

## Exact binding and present state

| Field | Frozen/project fact |
| --- | --- |
| Source | OSM way `w34313514`, v3, `2011-05-01T10:26:03Z`; name `Advanced Culinary Dormitory`; address `487-489 4th Street`; `building=residential`, `source=Yahoo`; source note says “I may have misread what the sign said from the distance ;)” |
| Logical / wall receiver | `building:w34313514` / `building:w34313514:wall` |
| Chunk / geometry hash | `x_0__z_1` / `043d533eb531cb0f8a06d94defd9e1c6e6f4229593ce9d70dbc7126f6f0a2b78` |
| Generated mass | `6 m`, base/top `3.719 / 9.719 m`; 44 runs / `313.900 m` visible wall |
| Runtime/review | Shared placeholder live; target evidence remains blocked. |

The frozen source and receiver are authoritative for the game object. The frozen
name is **not** authoritative proof of the real-world identity.

## Identity reconciliation and currentness

- `verified_fact` — the 1995 federal transfer record treats **Building 363** as
  the existing Job Corps Culinary Arts school, **Building 368** as the cafeteria,
  and Buildings **487, 488, and 489** as separate structures planned for minor
  rehabilitation. The record explicitly identifies 488 and 489 as dormitories;
  treating 487 as the same dormitory type would be a `production_inference`, not
  a verified fact.
- `verified_fact` — the current Job Corps center offers **Advanced Culinary Arts**,
  but its public program page does not bind that program to this footprint or to
  Buildings 487–489.
- `verified_fact` — the 2023 official SF site map depicts separate Buildings 487,
  488, and 489 in Job Corps property context. It does not provide a validated
  one-to-one crosswalk from this single transformed OSM way to one building or to
  the whole group.
- Confidence: **low exact real-world identity**, despite a stable frozen game
  binding. Treat “Advanced Culinary Dormitory” as a provenance string pending a
  crosswalk, not a verified current or historical proper name.

## Primary sources

| Source | Access | Supports | Use boundary |
| --- | --- | --- | --- |
| [1995 Job Corps transfer record](https://www.govinfo.gov/content/pkg/FR-1995-01-11/pdf/95-673.pdf) | HTTP 200, 2026-09-04 | distinct B363 culinary school, B368 cafeteria, and B487–489 rehabilitation/dormitory roles | identity correction; no target facade |
| [Current Advanced Culinary Arts program](https://treasureisland.jobcorps.gov/jobs/advanced-culinary-arts) | HTTP 200, 2026-09-04 | current program exists at center | campus/program only; no footprint or facade binding |
| [2023 SF revised SGMP](https://www.sf.gov/sites/default/files/2023-12/SGMP_0004-007-005%20Treasure%20Island_Rev%2003-17-23-compressed.pdf) | HTTP 200, 2026-09-04 | separate mapped B487, B488, B489 structures | plan context; not a receiver crosswalk or elevation |

An attempted public frontage observation did not expose a reliably attributable
target elevation. It supplies no visual claim.

## Supported cues and implementation boundary

There are **zero building-specific visual cues** supported for this exact unit.
The building-number series and dormitory/rehabilitation history are identity
leads, not facade motifs. Do not visually combine three separate real buildings
onto one receiver, and do not turn the current culinary program’s branding into
a facade claim.

Safe reversible `production_inference`: retain the shared placeholder and exact
receiver until the crosswalk is resolved. If a future authoritative plan proves
that the game polygon aggregates the 487–489 group, treat that aggregation as a
documented abstraction and still require side-specific exterior evidence before
authoring unique modules.

## Nonclaims, confusion set, and resolution gate

Unknown/nonclaim: whether `w34313514` represents B487, B488, B489, or an OSM
compound; whether “Advanced Culinary Dormitory” ever appeared on the target;
current use/survival; all elevations, materials, colors, openings, entrances,
signage, roof, and interiors.

Likely confusion set: B487 vs B488 vs B489, culinary Building 363, cafeteria
Building 368, and nearby Building 442. No visual acceptance is possible until the
real-world identity is bound; after that, at least two target-specific visible cues
on a proven side are required.

No art should be generated yet. Next autonomous step: search authoritative DOL,
TIDA/SF demolition-planning, environmental, and facilities records for a marked
plan containing B487/B488/B489 outlines and compare those outlines/orientations to
the frozen polygon without altering it. If those records cannot disambiguate it,
the narrow `HUMAN.md` request is: **ask Job Corps/TIDA for a dated marked campus
plan crosswalking Buildings 487, 488, and 489 to street-facing footprints, plus
one rights-cleared exterior view of the matched unit**.
