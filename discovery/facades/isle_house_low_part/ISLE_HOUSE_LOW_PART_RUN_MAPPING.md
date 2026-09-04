# Isle House low-part public-side-to-run mapping

Checked: **2026-09-04**
Status: **mapping complete for the two public live-work sides; prototype placement remains reversible and unaccepted**

## Exact target and result

This packet narrows only the low part `w1282547787` of the Isle House composite
`w1249412094`. Its wall receiver is exactly
`building-composite:w1249412094:w1282547787:wall` in chunk `x_-1__z_2`.
The serialized receiver has 13 exterior runs totaling `144.909 m`, base/top
`4.103 / 19.103 m`, 52 wall vertices and 26 wall triangles. The parent remains
meshless, the high part is `w1282547786`, and the intentionally hidden
`49.094 m` high/low interface is not a low wall.

The public-side join is:

| Low side | Exact runs | Length | Public edge | Mapping result |
| --- | ---: | ---: | --- | --- |
| WSW | `0..4` | `51.698 m` | Avenue of the Palms | mapped, medium-high confidence |
| ENE | `5..9` | `49.797 m` | Garden Walk / shared pedestrian way | mapped, medium-high confidence |
| NNW return | `10..12` | `43.414 m` | no isolated completed-photo side | protected/unmapped |

This is a side-chain mapping, not a photographic survey of individual bays.
It authorizes the observed motif family on the two mapped public sides while
keeping exact count, dimensions, cadence and run-local placement as reversible
production inference.

## Why the join is bounded

`verified_fact` — David Baker Architects states that the nine two-level
live-work homes have private entries, Dutch doors and patios, with half facing
Avenue of the Palms and half facing the shared way. The same primary source
states that brick and handcrafted materials occur near eye level.

`reference_observation` — the completed-project gallery's streetfront live-work
photographs show the live-work row beside a broad landscaped sidewalk and palm
street edge. The completed pedestrian-side view shows the same family beside a
landscaped path, including a half-door entry. Across those public views the
stable cues are warm dark brick pier/field language, large two-level glazing,
individual entries, and a shallow landscaped patio/threshold edge.

`verified_fact` geometry join — in the frozen OSM snapshot the road named
Avenue of the Palms lies directly outside the low receiver chain with normal
`(-0.891, 0.455)`, runs `0..4`. The pedestrian way named Garden Walk lies
directly outside the chain with normal `(0.890, -0.455)`, runs `5..9`. The
remaining NNW chain does not match either named public live-work edge and no
completed photograph isolates its full corners. It is not used.

`production_inference` — prototype assemblies are limited to long internal
runs `2`, `3`, `8` and `9`, each at least `1.8 m` from a run endpoint. Their
width, height, frame proportions, count, spacing, opaque glass proxy and shallow
patio-edge depth are deliberately reversible. Short facets and the other mapped
runs may carry only the bounded warm-brick live-work band in the prototype.

## Exact public references and rights boundary

| ID | Link / gallery token | Access | Supports | Use boundary |
| --- | --- | --- | --- | --- |
| `DBA-COMPLETED-PROJECT` | [David Baker Architects — Isle House](https://www.dbarchitect.com/projects/isle-house) | opened 2026-09-04 | completed identity, live-work count, active ground uses, completed exterior gallery | authoritative text plus observation of credited photography; no pixels retained or redistributed |
| `DBA-LW-STREETFRONT-01` | same gallery, `21851_islehouse_brettjones_live-work2.jpg`; alt: exterior live-work view | link validated 2026-09-04 | broad sidewalk/street context, live-work glazing/entry family | observation only; photographer/site rights retained |
| `DBA-LW-STREETFRONT-02` | same gallery, `21851_islehouse_brettjones_live-work4.jpg`; alt: exterior live-work view | link validated 2026-09-04 | palm-lined street edge, dark brick piers, large glazed bays | observation only; photographer/site rights retained |
| `DBA-LW-PEDESTRIAN-01` | same gallery, `21851_islehouse_briankitts_029.jpg`; alt: ground-floor live-work view | link validated 2026-09-04 | landscaped pedestrian path, half-door entry, glazed live-work bay | observation only; credited Brian Kitts; no copy retained |
| `DBA-DESIGN-INTERVIEW-LIVEWORK` | [DBA design interview](https://www.dbarchitect.com/press/vision-behind-isle-house-first-waterfront-tower-pre-leasing-treasure-island) | opened 2026-09-04 | brick/handcrafted eye-level materials; Dutch doors/private patios; half on Avenue of the Palms, half on shared way | primary text facts; accompanying rendering excluded |
| `FROZEN-OSM-PUBLIC-EDGE-JOIN` | `data/osm/treasure-island-2026-08-27.osm`, ways `1282547787`, `1001544697`, `1249412096` | checked 2026-09-04 | exact low-part polygon and named road/pedestrian-way adjacency | geometry only; no appearance claim |

The project stores no external photograph, screenshot, crop, sampled pixel,
texture or derivative. The runtime package uses only the opaque IDs above; URLs
and source paths stay in this discovery packet.

## Exact run ledger

All coordinates are world XYZ metres; each run tops at `y=19.103`. The bottom
heights below are the untouched generated foundation profile.

| Run | Side | Start -> end | Outward normal | Length | Prototype policy |
| ---: | --- | --- | --- | ---: | --- |
| 0 | WSW / Avenue | `(-156.887,4.027,502.424) -> (-154.702,4.027,506.702)` | `(-0.891,0.455)` | `4.803697` | field only; short/corner-adjacent |
| 1 | WSW / Avenue | `(-154.702,4.027,506.702) -> (-151.997,3.983,512.000)` | `(-0.891,0.455)` | `5.948599` | field only |
| 2 | WSW / Avenue | `(-151.997,3.983,512.000) -> (-143.885,4.103,527.885)` | `(-0.891,0.455)` | `17.836417` | complete live-work prototypes allowed, inset |
| 3 | WSW / Avenue | `(-143.885,4.103,527.885) -> (-135.655,3.993,544.000)` | `(-0.891,0.455)` | `18.094920` | complete live-work prototypes allowed, inset |
| 4 | WSW / Avenue | `(-135.655,3.993,544.000) -> (-133.374,4.065,548.466)` | `(-0.891,0.455)` | `5.014790` | field only; corner-adjacent |
| 5 | ENE / Garden Walk | `(-95.775,4.099,526.591) -> (-96.000,4.103,526.151)` | `(0.890,-0.455)` | `0.494191` | field only; protected short facet |
| 6 | ENE / Garden Walk | `(-96.000,4.103,526.151) -> (-100.787,4.103,516.787)` | `(0.890,-0.455)` | `10.516647` | field only |
| 7 | ENE / Garden Walk | `(-100.787,4.103,516.787) -> (-103.235,4.103,512.000)` | `(0.890,-0.455)` | `5.376623` | field only |
| 8 | ENE / Garden Walk | `(-103.235,4.103,512.000) -> (-111.613,4.103,495.613)` | `(0.890,-0.455)` | `18.404474` | complete live-work prototypes allowed, inset |
| 9 | ENE / Garden Walk | `(-111.613,4.103,495.613) -> (-118.444,4.103,482.253)` | `(0.890,-0.455)` | `15.005071` | complete live-work prototypes allowed, inset |
| 10 | NNW protected | `(-118.444,4.103,482.253) -> (-128.000,4.103,487.267)` | `(-0.465,-0.886)` | `10.791540` | no attachment |
| 11 | NNW protected | `(-128.000,4.103,487.267) -> (-143.289,4.103,495.289)` | `(-0.465,-0.886)` | `17.265747` | no attachment |
| 12 | NNW protected | `(-143.289,4.103,495.289) -> (-156.887,4.027,502.424)` | `(-0.465,-0.886)` | `15.356231` | no attachment |

## Prototype truth boundary

Observed input is limited to the warm brick/live-work/entry/patio/glazing
family and the two public-side identities. The prototype may express that
family with complete shallow assemblies, but it may not claim an exact bay,
exact brick bond, surveyed product/color, transparent interior, operable door,
occupiable patio, balcony, deep recess, private/rear facade or complete upper
schedule. It carries no `39` identifier because that already belongs to the
accepted high address assembly and must not be duplicated by inference.

The NNW runs `10..12`, low roof, y=`10.25..19.103` upper band and hidden
high/low interface are explicit stop zones. Decorative prototype geometry owns
no collision, navigation, occlusion or spray surface. It cannot accept the low
part, cannot accept the Isle House composite, and cannot cure the generated
five-level low part versus the real seven-story podium discrepancy.

## Future integration seam

The isolated scene is intended to be instantiated only after
`IsleHouse39BrutonLowFacadePrototype.matches_target(record)` returns true, then
configured with `prototype.configure(record)`. The factory independently
revalidates all 13 exact run starts, ends, normals and topology before emitting
geometry. A future world-builder owner must make the separate integration and
acceptance decision; this batch does not edit or preload from the builder.
