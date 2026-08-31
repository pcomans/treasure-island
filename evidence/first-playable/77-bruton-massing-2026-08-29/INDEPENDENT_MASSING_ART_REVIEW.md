# Final independent art and massing review — Hawkins stepped mass

Reviewed: **2026-08-29**

Reviewer: `/root/hawkins_texture_v2_review` (independent of implementation)

Target: Hawkins / 77 Bruton Street, wall `building:w1249412093:wall`, roof `building:w1249412093:roof`

Decision: **ACCEPT_WITH_DOCUMENTED_APPROXIMATION**

## Final decision

The owner-approved Hawkins massing change passes the final bounded art gate. The result reads as a six-story main block plus a lower four-story companion, not as the former stretched `6 m` box. The height step is visible at ordinary ground distance, the five upper residential rows over the main ground story remain countable, and the lower mass retains three upper rows over its ground story. The accepted facade language has been remapped by story and volume without losing its complete window/transom grammar, differentiated ground floor, address program, filtered fine-flute response, or regional main-versus-companion cadence.

This is not a surveyed/as-built acceptance. The P/Q split reuses the accepted connector coordinates as a medium-confidence production inference; `3.5 m` per story is reversible; and the two flat roofs omit the observed parapet, terrace/pavilion, rail, solar canopy, courtyard articulation, and roof furniture. Those limitations support `ACCEPT_WITH_DOCUMENTED_APPROXIMATION`, not an unqualified `ACCEPT`.

## Reference and evidence integrity

- Every entry in `asset-inventory.sha256` verifies, including the six PNGs, manifest, implementation inputs, preserved Hawkins materials, unchanged generated chunk/manifest, and cohort controls.
- The owner reference was inspected through `/private/tmp/IMG_7170-reference.png`; its SHA-256 is the expected `6b6a0f95902bd48c57c4f69b6bd7b97346c672d71c1b300d394170f6447db5cd`. No browsing, download, upload, generation, install, or substitute imagery was used.
- The accepted facade materials and filtered flute shader are byte-identical to the prior accepted correction evidence. The new layout SHA-256 is `4de2239af2e18fe4121930d51dee15e081d2f81a40393da2f1f29c69464761d9`; facade signature is `d311c103c9273b94fc982588f46bae6ab67ba6be54b0d0a111dd305e39c22219`; massing signature is `7c4fea5fec624ccfc3963b9fa5eb586b73ca61da0c09ae8539df3e0adb8cf291`.
- All six captures are `1440 x 900`, Godot `4.7.2`, Forward+/Metal on Apple M1 Pro with the normal `70°` third-person camera and `5.5 m` spring.
- Views `01/02` have identical player, camera, aim, FOV, and spring transforms. Views `04/06` also have identical transforms; only the documented sun changes to `(-38,125,0)` in `06`.
- Prior flat-massing and current stepped-massing poses are not identical, so no pixel-exact before/after claim is made. The comparison is absolute against the owner photo/specification and uses the prior flat frames only to identify the removed low-box condition.

## Separated verdicts

| Scope | Verdict | Basis |
|---|---|---|
| Approved geometry contract | **PASS_AS_EVIDENCED** | Exact complementary main/companion footprints, six/four stories, `25.274/18.274 m` tops, one exposed step face, two roof planes, preserved outer footprint/foundation data, and no old `10.274 m` face are supported by verified hashes and focused/full-runtime results. |
| Facade remap | **PASS** | Five main and three companion upper rows retain complete `W-P/S-H` modules; split connectors remain whole on the main volume; address one-offs stay at SE ground; WSW companion cadence stays sparse; ENE, NNW, and the step remain material-only. |
| Exact current receiver and gameplay presentation | **PASS** | Close, ordinary, 40 m oblique, roof/step, spray, and changed-light frames remain coherent; lower and exposed-step tags visibly project while both hits retain the exact wall identity. No visible collision/render disagreement appears. |
| Whole-building real-world resemblance | **PASS_WITH_DOCUMENTED_APPROXIMATION** | The verified six-story main/four-story low-rise hierarchy and broad owner-photo proportions are now present, while the inferred plan cut, reversible story height, flat roofs, opaque shallow modules, and omitted rooftop/courtyard articulation remain explicit. |
| Overall | **ACCEPT_WITH_DOCUMENTED_APPROXIMATION** | The approved massing and preserved facade language pass their bounded gates; residual discrepancies are the predeclared non-survey and omitted-articulation limits, not hidden facade or runtime defects. |

## Massing and silhouette findings

- Six-plus-four hierarchy: **pass**. `03-wsw-ordinary-stepped.png` shows the full main top and five upper window rows over the darker ground story. `04-corner-b-oblique.png` and `06-corner-b-changed-light.png` show the lower companion, its three upper rows, and the taller main continuing behind it. Together they establish the intended stepped reading.
- Proportions: **pass within the approved approximation**. The `21:14 m` height ratio directly expresses six versus four stories, while the WSW `60.4/23.99 m` main/companion partition preserves the owner photo's broad-main/smaller-companion relationship. Neither P/Q nor the exact tops are treated as measured.
- Step and roof hierarchy: **pass**. The lower roof and material-only exposed step are distinct in `05`; the main continues above without a stale intermediate roof. Flat, furniture-free bitumen roofs are visibly simpler than the real terrace/roofline and remain a documented scope limit.
- Stretched-box test: **pass**. The prior low slab is gone. The current object has two legible top elevations, volume-dependent story counts, a real exposed step, and corresponding facade/collision ownership rather than a single tall rectangle with a painted height break.

## Facade, joins, and material findings

- Story cadence and scale: **pass**. The repeated `3.5 m` bands keep the accepted human-scale openings and lower transoms intact. Main rows remain aligned and companion rows end at the lower roof instead of floating above it.
- Module completeness: **pass**. No window, transom, sill, jamb, connector, sign letter, lobby, door, service field, garage, or band is visibly clipped, doubled, stretched, or completed by a volume edge. The shifted WSW/SE connectors remain wholly on the main mass.
- Address language: **pass**. `01` and `02` preserve the one-off `HAWKINS` sign, lobby/storefront, paired entrance, service/garage language, and darker ribbed base without copying them to another story or side.
- Regional cadence: **pass**. The broad main WSW stack and sparser companion sequence remain distinct. The exposed step uses conservative plain material rather than invented windows or a wrapped connector cadence.
- Material behavior: **pass**. The light pearlescent field, dark base, charcoal frames, muted opaque glass, and pale spandrels remain low-chroma and dielectric. `04/06` change illumination without fixed baked highlights, renewed dashed sparkle, diagonal moire, screen-door shimmer, or facade-scale interference.
- Joins and surface stability: **pass**. No z-fighting, doubled internal face, clipped corner, relief silhouette break, roof overlap, or cadence reset at a source foundation subdivision is visible.

## Exact receiver and gameplay findings

- Foundation and terrain continuity: **pass visually and as evidenced**. Ground-contact edges in `01`, `03`, and `04` show no daylight gap, exposed underside, newly buried opening, or terrain crack; retained results preserve the original terrain-bottom endpoints plus the two specified interpolations.
- Lower-wall spray: **pass**. `02-address-close-sprayed.png` visibly shows the real tag over the facade; the manifest records `building:w1249412093:wall` and source `w1249412093`.
- Companion roof and exposed-step spray: **pass**. `05-companion-roof-upper-step-sprayed.png` shows stable support on the dark companion roof, a clean roof/step junction, and a visible tag on the upper step; the manifest records the roof as non-spray support and the exact wall as the spray hit.
- Collision/presentation agreement: **pass as evidenced**. No invisible old roof, double wall, collision-offset appearance, or decal discontinuity is exposed by the six views. Mechanical landing, roof rejection, wall eligibility, one-body/shape ownership, and reload contracts support this visual result but do not substitute for it.
- Jetpack-view qualification: `05` is a deterministic supported roof pose after the unchanged jetpack contract, not a recorded manual flight path. It is sufficient for roof/step presentation and spray ownership; traversal itself remains mechanical evidence.

## Capture adequacy and per-view findings

- `01-address-close.png`: strongest proof that the accepted address grammar survived the vertical remap; complete modules and stable fine relief remain readable at human scale.
- `02-address-close-sprayed.png`: exact-pose lower-wall spray proof; tag projection does not expose a facade/collider mismatch.
- `03-wsw-ordinary-stepped.png`: the authoritative transform is a **12 m** supported fallback at WSW `u=35`, despite the manifest intent string still saying `40 m`. It clearly proves the main six-story count, story spacing, ordinary-camera module scale, and full main roofline, but does not by itself frame the companion or satisfy the originally requested broad WSW distance.
- `04-corner-b-oblique.png`: exact 40 m ground view supplying the missing whole-step context across both observed sides; the contextual Isle House at left does not obscure the Hawkins companion/step relationship.
- `05-companion-roof-upper-step-sprayed.png`: utilitarian rather than compositional, but directly proves the lower roof surface, plain exposed step, junction cleanliness, and real wall spray.
- `06-corner-b-changed-light.png`: exact-pose counterpart to `04`; height hierarchy and facade sampling remain coherent after the light change.

The `12 m` WSW fallback is adequate **only in combination** with the `04/06` exact 40 m corner pair. The suite proves full main cadence in `03` and whole step/context in `04/06`; it does not provide one unoccluded `35–45 m` WSW broadside containing both complete rooflines. That is a documented evidence limitation, not a rejector, because the required facts are independently visible across reproducible ordinary-camera views. The stale `40 m` prose inside capture `03` should not be reused as a transform claim.

## Residual approximation

The accepted result remains a two-volume game abstraction over the exact frozen footprint. It does not establish the P/Q line, `3.5 m` story height, window counts, connector offsets, or tops as surveyed facts. It omits the real parapet, terrace/pavilion, rail, solar canopy, courtyard/setbacks, deeper projections, transparent interiors, and smaller articulated planes visible or described in the references. Unobserved ENE/NNW and the step remain intentionally material-only. These limits are material to a fully as-built claim but do not conceal a defect in the owner-approved bounded change. No routine correction round is indicated by this review.
