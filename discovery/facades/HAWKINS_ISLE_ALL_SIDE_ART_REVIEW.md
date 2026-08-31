# Hawkins + Isle House all-side gameplay art review

**Review date:** 2026-08-29

**Reviewer:** independent gameplay art review (`/root/hawkins_reference_spec`); reviewer did not implement or capture this work

**Evidence set:** [`hawkins-isle-all-side-coverage-2026-08-29`](../../evidence/first-playable/hawkins-isle-all-side-coverage-2026-08-29/README.md)

**Overall verdict:** **ACCEPT_WITH_DOCUMENTED_LIMITATION**

**Playable-build decision:** **ready for the next playable build**, within the exact field-only and untouched-part limits below

## Verdicts kept separate

| Review scope | Verdict | Decision |
| --- | --- | --- |
| Hawkins whole object, receiver `building:w1249412093:wall` | **ACCEPT_WITH_DOCUMENTED_LIMITATION** | The accepted WSW/SE visual direction remains intact, and the ENE/NNW/step now read as one intentional Hawkins material hierarchy rather than raw uncovered/default sides. ENE/NNW/step remain deliberately plain and module-free because their architectural schedules are unobserved. |
| Isle House high whole object, receiver `building-composite:w1249412094:w1282547786:wall` | **ACCEPT_WITH_DOCUMENTED_LIMITATION** | The accepted SE address elevation remains intact and recognizable. Runs `0..9` have the building-specific podium/tower field hierarchy, while shared runs `10..12` receive tower field only. The newly covered sides are intentionally less distinctive because no module schedule is authorized there. |
| Isle House low, receiver `building-composite:w1249412094:w1282547787:wall` | **ACCEPT_WITH_DOCUMENTED_LIMITATION** | This is acceptance of demonstrated non-interference only, **not** art acceptance of the low part. The low part remains untouched, unknown, and outside this review; the contextual views do not exhaustively expose all of its faces. |
| Hawkins ENE/NNW/step and Isle high module-free sides | **ACCEPT_WITH_DOCUMENTED_LIMITATION** | Their absence of windows, doors, ribs, signs, louvers, and other facade-scale motifs is the evidence-safe result, not a missing-feature defect. No architectural grammar may be copied around a corner from an accepted front. |

No reviewed scope is `REJECT_CORRECTABLE` or `REJECT_REFERENCE_BLOCKED`. This acceptance does not authorize new modules, massing changes, or work on the Isle low part.

## Evidence and acceptance baseline

The review applies the absolute material/facade criteria in the building-texture skill rather than comparing the result with gray boxes. The governing handoff is [`HAWKINS_ISLE_ALL_SIDE_COVERAGE_SPEC.md`](HAWKINS_ISLE_ALL_SIDE_COVERAGE_SPEC.md), including its exact run ownership, field-only limits, protected facets, and high/low split.

Accepted visual baselines used to detect regression were:

- Hawkins corrected facade: [`FINAL_INDEPENDENT_ART_REVIEW.md`](../../evidence/first-playable/77-bruton-facade-correction-2026-08-29/FINAL_INDEPENDENT_ART_REVIEW.md) and [`final-independent-art-verdict.yaml`](../../evidence/first-playable/77-bruton-facade-correction-2026-08-29/final-independent-art-verdict.yaml);
- Hawkins stepped massing: [`INDEPENDENT_MASSING_ART_REVIEW.md`](../../evidence/first-playable/77-bruton-massing-2026-08-29/INDEPENDENT_MASSING_ART_REVIEW.md) and [`independent-massing-art-verdict.yaml`](../../evidence/first-playable/77-bruton-massing-2026-08-29/independent-massing-art-verdict.yaml);
- Isle House high accepted pilot: [`INDEPENDENT_ART_REVIEW.md`](../../evidence/first-playable/isle-house-high-facade-pilot-2026-08-29/INDEPENDENT_ART_REVIEW.md) and [`independent-art-verdict.yaml`](../../evidence/first-playable/isle-house-high-facade-pilot-2026-08-29/independent-art-verdict.yaml).

The current [`capture-manifest.json`](../../evidence/first-playable/hawkins-isle-all-side-coverage-2026-08-29/capture-manifest.json) fixes the exact receivers, run scopes, camera poses, renderer, and accepted facade signatures. Visual findings below are bounded to the captured close and realized ordinary-distance views.

## Absolute art findings

| Criterion | Hawkins finding | Isle House high finding |
| --- | --- | --- |
| Preserved accepted direction | The SE address close view retains the accepted sign, lobby/door grouping, canopy, dark ribbed base, fluted pearl upper, and opening cadence. The WSW gameplay view retains its accepted facade rhythm and stepped silhouette. | The SE close and ordinary views retain the accepted `39` entry, dark opening families, localized louver/glazing grammar, podium/tower hierarchy, and tall-building identity. |
| All-side building-specific field coverage | ENE and NNW visibly carry the Hawkins light pearl/plain upper over the dark smooth base; the exposed step reads as the same restrained light family. The tonal hierarchy is intentional and target-specific even though the sides are homogeneous. | Newly covered WSW/SW runs visibly carry the Isle light tower over the cooler light podium. Shared runs read as tower-only above the low part, consistent with their non-ground ownership. |
| Raw generic/gray surfaces | No promised Hawkins side presents as a leftover default-gray hole or unrelated material. The plain upper is visually sparse, but it is coherent with the accepted Hawkins palette and dark base. | No promised high-part side is visibly raw or uncovered. The shared face is a very large plain light field, but it matches the declared Isle tower family and does not introduce a foreign gray-box material. |
| Terrain and lower edges | Paired ENE/NNW views show the dark base meeting the varying ground with no daylight gap or visibly floating field. A thin edge at some close contacts reads as contact shadow, not a detached quad. | The ordinary WSW view shows the podium field meeting terrain without a floating strip. Shared runs start above the low part, so terrain contact is inapplicable there; the low part visually occludes/protects the shared lower edge. |
| Seams, z-fighting, and transitions | No double edge, coplanar flicker pattern, triangle seam, corner leak, or field gap is visible in the close/ordinary stills. Base/upper boundaries and the stepped-volume transition remain crisp. | No double edge, coplanar artifact, field gap, or spill onto the low receiver is visible. Podium/tower, corner/return, and shared-face transitions remain clean in the captured views. Temporal shimmer cannot be proved from stills and remains a documented evidence limit. |
| Motif integrity | No facade-scale motif has been invented on ENE, NNW, or the step. Accepted WSW/SE complete modules remain confined to their original sides. | No `39` identifier, window schedule, door, louver, or front motif is copied onto runs `0..4` or `8..12`. Accepted modules remain on runs `5..7`; blank sides are contractually correct. |
| Physical scale and repetition | Existing accepted front modules retain their established scale. The added homogeneous fields have no visible directional repeat, false opening, giant procedural cell, or facade-scale tiling artifact. | Existing accepted SE modules retain their scale. New podium/tower fields are phase-neutral at gameplay distance and introduce no visible cadence, false slit/window, or repeating facade motif. |
| Lighting robustness | Values and material identity remain legible under the captured Metal lighting, and the preserved Hawkins materials have prior accepted changed-light evidence. This suite contains no changed-light view of the newly exposed normals, so receiver-specific changed-light behavior is not newly proved. | Values and podium/tower separation remain legible under the captured Metal lighting, and the preserved Isle materials have prior accepted changed-light evidence. This suite contains no changed-light view of the new/shared normals, so receiver-specific changed-light behavior is not newly proved. |
| Recognizability | The address facade and stepped Hawkins mass remain the recognition anchors; plain rear/side fields do not dilute them in ordinary play. | The accepted SE facade, height, and podium/tower split remain the recognition anchors. Module-free sides are less distinctive in isolation but do not undermine whole-object recognition. |

## Manifest-indexed image accounting

Each manifest role is reviewed at both declared distances. Every PNG below appears exactly once in this accounting table.

| ID / manifest role | Exact capture | Art-review finding |
| --- | --- | --- |
| `01-front-close` / Hawkins `accepted_front`, close, runs `7..9` | [`01-front-close.png`](../../evidence/first-playable/hawkins-isle-all-side-coverage-2026-08-29/images/hawkins/01-front-close.png) | Accepted SE address language is preserved; close edges and material transitions are clean. |
| `02-front-ordinary` / Hawkins `accepted_front`, ordinary, runs `0..6` | [`02-front-ordinary.png`](../../evidence/first-playable/hawkins-isle-all-side-coverage-2026-08-29/images/hawkins/02-front-ordinary.png) | WSW cadence and stepped mass remain readable. The manifest records a realized outward distance of `12 m`, not the requested `40 m`; the verdict is bounded to that realized view. |
| `03-ene-covered-close` / Hawkins `conservative_all_side_field`, close, runs `10..15` | [`03-ene-covered-close.png`](../../evidence/first-playable/hawkins-isle-all-side-coverage-2026-08-29/images/hawkins/03-ene-covered-close.png) | Plain pearl upper and dark smooth base cover the face continuously; no invented module, floating gap, or coplanar artifact is visible. |
| `04-ene-covered-ordinary` / Hawkins `conservative_all_side_field`, ordinary, runs `10..15` | [`04-ene-covered-ordinary.png`](../../evidence/first-playable/hawkins-isle-all-side-coverage-2026-08-29/images/hawkins/04-ene-covered-ordinary.png) | The full side and step context read as one restrained Hawkins hierarchy; corners and terrain contact are coherent. |
| `05-nnw-module-free-close` / Hawkins `unobserved_module_free`, close, runs `16..19` | [`05-nnw-module-free-close.png`](../../evidence/first-playable/hawkins-isle-all-side-coverage-2026-08-29/images/hawkins/05-nnw-module-free-close.png) | Field coverage and base/upper boundary are clean; the side correctly contains no architectural module. |
| `06-nnw-module-free-ordinary` / Hawkins `unobserved_module_free`, ordinary, runs `16..19` | [`06-nnw-module-free-ordinary.png`](../../evidence/first-playable/hawkins-isle-all-side-coverage-2026-08-29/images/hawkins/06-nnw-module-free-ordinary.png) | The module-free side remains intentionally plain but visually complete; no raw side, corner leak, or unstable repeat is visible. |
| `07-front-close` / Isle `accepted_front`, close, runs `5..7` | [`07-front-close.png`](../../evidence/first-playable/hawkins-isle-all-side-coverage-2026-08-29/images/isle-house/07-front-close.png) | Accepted entry, `39`, glazing/louver, and opening grammar are intact without field spill. |
| `08-front-ordinary` / Isle `accepted_front`, ordinary, runs `5..7` | [`08-front-ordinary.png`](../../evidence/first-playable/hawkins-isle-all-side-coverage-2026-08-29/images/isle-house/08-front-ordinary.png) | Whole-object SE recognizability and podium/tower reading remain strong at the realized `84 m` view. |
| `09-new-wsw-close` / Isle `new_homogeneous_field`, close, runs `0..2` | [`09-new-wsw-close.png`](../../evidence/first-playable/hawkins-isle-all-side-coverage-2026-08-29/images/isle-house/09-new-wsw-close.png) | New tower/podium fields are continuous and phase-neutral; no module or corner-folded front grammar is invented. Ground contact is mostly occluded in this upward close framing and is judged with the paired ordinary view. |
| `10-new-wsw-ordinary` / Isle `new_homogeneous_field`, ordinary, runs `0..4` | [`10-new-wsw-ordinary.png`](../../evidence/first-playable/hawkins-isle-all-side-coverage-2026-08-29/images/isle-house/10-new-wsw-ordinary.png) | Full new-side coverage, terrain contact, material split, and return transitions read cleanly without a floating strip or repeat artifact. |
| `11-shared-module-free-close` / Isle `shared_tower_module_free`, close, runs `10..12` | [`11-shared-module-free-close.png`](../../evidence/first-playable/hawkins-isle-all-side-coverage-2026-08-29/images/isle-house/11-shared-module-free-close.png) | Jetpack-reachable close view shows a clean tower-only field with no podium spill, invented module, seam, or visible z-fight. The low part occludes the exact shared lower edge. |
| `12-shared-module-free-ordinary` / Isle `shared_tower_module_free`, ordinary, runs `10..12` | [`12-shared-module-free-ordinary.png`](../../evidence/first-playable/hawkins-isle-all-side-coverage-2026-08-29/images/isle-house/12-shared-module-free-ordinary.png) | Shared tower face and low-part context remain visually separated and stable; the very plain face is the required module-free limitation, not a reference claim. |

## Documented limitations and stop conditions

1. The all-side suite has close and ordinary views only. It does **not** contain a changed-light capture for Hawkins ENE/NNW/step or Isle runs `0..4`/`10..12`. Prior changed-light acceptance covers the reused material families, but not these exact new receiver normals. A later lighting-regression concern requires a new independent changed-light capture; it does not block this field-only build.
2. Hawkins `02-front-ordinary` realized `12 m` outward distance despite requesting `40 m`. This is a valid gameplay-context regression view, but not a broad `40 m` proof.
3. Still PNGs can expose visible double edges and coplanar artifacts but cannot prove absence of time-dependent shimmer. No such artifact is visible in any paired close/ordinary view.
4. Hawkins ENE/NNW/step and Isle high module-free sides are not as-built elevation claims. They are conservative homogeneous coverage. Do not interpret this verdict as permission to add openings, bands, ribs, signs, louvers, doors, service details, or copied front schedules.
5. Isle runs `0..4` remain module-free until a separate exact side-local layout is mapped and independently accepted. Runs `8..12` remain module-blocked. The low receiver remains unknown and untouched.
6. The review does not approve changes to story count, silhouette, massing, terrain, foundation bottoms, collision, navigation, spray eligibility, generated OSM contracts, roofs, accepted layout hashes, or receiver ownership.

## Mechanical and link validation

- Manifest declaration, disk inventory, and review accounting each contain exactly `12` PNGs at `1440x900`, with `12` unique paths and no missing or extra image.
- All `12` PNG SHA-256 values match their manifest records. Each of the six target/role combinations appears once at close and once at ordinary distance.
- The capture-manifest SHA-256 matches [`evidence-index.json`](../../evidence/first-playable/hawkins-isle-all-side-coverage-2026-08-29/evidence-index.json). The index hashes for the implementation, focused contracts, capture harness, accepted layouts, frozen chunk records, and generated manifest also match the files reviewed on 2026-08-29.
- Before the required review-status edit, the README SHA-256 matched its evidence-index record (`14fa7c1b1fce6d1147fcbdb816d3af26cfe2556834e2af7bdac0d782873ac94c`). This review updates only the mutable README status/link, so that capture-time README hash is intentionally superseded; `evidence-index.json` remains untouched under the review edit boundary.
- All local links in this review and the evidence README were checked after authoring.

## Final build gate

The owner-requested coverage improvement is **ready for the next playable build** as **ACCEPT_WITH_DOCUMENTED_LIMITATION**. Hawkins is accepted as a whole object with its evidence-safe module-free ENE/NNW/step. Isle House high is accepted as a whole object with homogeneous coverage on all promised high-part sides, accepted modules preserved only on runs `5..7`, and tower-only coverage on shared runs `10..12`. Isle House low remains untouched and receives no art-acceptance claim.
