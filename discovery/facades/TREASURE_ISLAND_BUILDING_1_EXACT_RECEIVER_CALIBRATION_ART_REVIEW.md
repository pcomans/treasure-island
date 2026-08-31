# Treasure Island Building 1 detached exact-receiver calibration — independent art review

**Reviewer:** Independent art director (`/root/w34313515_art_director`)  
**Date:** 2026-08-30  
**Target:** Treasure Island Administration Building 1 / Treasure Island Museum (`r16681702`; receiver `building:r16681702:wall`)  
**Scope:** Detached exact-receiver calibration only. No live-world attachment was reviewed or authorized.  
**Independence:** I did not create the material, modules, registry, helper, scene, contracts, harness, mapping, or evidence.

## Decision

| Reviewed scope | Verdict | Lifecycle eligibility |
| --- | --- | --- |
| `B1-MAT-IVORY`, exact outer runs `21..51` | **CORRECT** | **Not eligible** to advance to live attachment yet. The material, scale, UV phase, run ownership, and macro read pass, but the independently offset run faces do not form one closed rendered overlay at the sharp internal joins. |
| `FIT-CENTRAL-W-R36` | **ACCEPT_WITH_DOCUMENTED_LIMITATION** | Accepted only as a detached scale/contact fit study on run `36`. It is **not** authorized as an actual placement or for live integration. |
| `FIT-PAV-W-R06` | **ACCEPT_WITH_DOCUMENTED_LIMITATION** | Accepted only as a detached scale/contact fit study on run `6`. It is **not** authorized as an actual placement or for live integration. |
| Aggregate detached package | **CORRECT** | The field correction below is required before the exact field can advance. Neither module fit study may advance as a live placement from this evidence. |

The package has a sound bounded material choice and two sound module fit studies, but the field's source-space `0.0 m` endpoint and UV-phase measurements do not prove its post-offset render geometry. The helper duplicates each run's join vertices and moves them by that run's own normal. At a change in wall direction, the two rendered endpoints therefore separate by `0.018 × ||n_before - n_after||`. This reaches `0.026857801 m` at join `42→43`; the deliberately sampled sharp join `38→39` separates by `0.024844871 m`. The resulting narrow exposed strips are visible at the sharp turns in the close, macro, ordinary, and changed-light evidence. That is a physical field-continuity failure, not a material-phase failure.

## One bounded correction

**Before → after:** for every internal field join `21→22` through `50→51`, replace the two independently offset endpoint pairs

`P + normal_before × 0.018 m` and `P + normal_after × 0.018 m`

with one shared XZ miter point: the intersection of the two adjacent wall-edge lines offset outward by `0.018 m`. Use that identical shared XZ point for the bottom and top vertices of both adjacent faces, retaining the source endpoint Y values, ordered runs `21..51`, accumulated chain-metre U coordinates, material parameters, topology ownership, and `0.018 m` perpendicular face clearance.

Stop after this correction and recapture the join, macro, ordinary, and changed-light proof. Do not change material scale, color, module geometry, study transforms, receiver geometry, or scope to mask the join defect.

## Truth boundary

- The only exact field scope reviewed is the ordered public outer chain `21..51`: `31` runs, `85.939934 m`, `1740.731069 m²`, and `30` intended zero-phase joins. The Godot float32 reconstruction reports `85.939965278 m` / `1740.731683135 m²`, within the package's stated representation tolerance.
- The field is a detached `homogeneous_material_tile` overlay using continuous chain-metre U and source world-Y V, `1.10 m` primary scale, `0.32 m` secondary scale, `0.82` roughness, `0.008` relief, `0.015` color variation, and metallic `0`. These are production assumptions, not surveyed values.
- `FIT-CENTRAL-W-R36` is one deterministic midpoint fit study on run `36`, nominally `1.45 × 4.60 m`, centered `10.0 m` above the run base with a `0.06 m` wall offset. Its origin is `(0.881625, 16.281000, 749.694397) m`. The midpoint, size, and coordinate are not real-opening evidence.
- `FIT-PAV-W-R06` is one deterministic midpoint fit study on run `6`, nominally `5.40 × 10.00 m`, centered `10.0 m` above the run base with a `0.06 m` wall offset. Its origin is `(-56.492283, 14.453499, 709.845093) m`. The midpoint, size, and coordinate are not real-opening evidence.
- The broad CENTRAL and end-pavilion regions are reference-compatible. No observation anchors either module to the chosen run, midpoint, count, cadence, sequence, or neighboring motif order.
- The run-ownership mapping contains a non-consumed metadata overlap: material runs `93..96` appear in both its eligible and ineligible lists. This package consumes only runs `21..51`, so the overlap does not change this verdict; runs `93..96` remain blocked until that separate mapping ambiguity is reconciled.
- This review does not authorize a completed elevation, massing correction, facade sequence, or whole-building resemblance.

## Exact field gates — `B1-MAT-IVORY` on outer runs `21..51`

| Gate | Result | Finding |
| --- | --- | --- |
| Numeric opposite-edge seam | **N/A** | This is a continuous procedural material, not a finite bitmap tile. |
| Source endpoint continuity | **PASS** | All `30` source joins resolve to `0.0 m` endpoint delta. |
| Material phase continuity | **PASS** | Accumulated chain-metre U has `0.0 m` intended phase delta at all `30` joins; there is no per-run UV restart. |
| Rendered overlay geometry continuity | **FAIL** | Independent `0.018 m` face-normal offsets separate duplicated join vertices. Maximum derived gap is `0.026857801 m` at `42→43`; sampled `38→39` is `0.024844871 m`. |
| Material identity | **PASS** | The restrained warm-ivory, matte, painted-mineral/stucco-like field is compatible with the approved public-elevation observations and contains no baked opening, trim, repair, or lighting. |
| Physical scale / channel coherence | **PASS_WITH_DOCUMENTED_LIMITATION** | `1.10/0.32 m`, roughness `0.82`, relief `0.008`, and low color variation behave coherently; absolute target scale, color, and roughness remain unsurveyed. |
| Exact side / run ownership | **PASS** | The field is bounded to the approved smallest public-curve chain `21..51`; the visible old receiver outside the chain in edge frames `01` and `05` correctly discloses the scope boundary. |
| Macro repetition / field continuity | **PASS** for material; **FAIL** for geometry | Image `06` shows no obvious texture period over the full `85.939934 m` chain, but sharp turns expose narrow join strips. |
| Exact receiver — close | **FAIL** | Low-angle join views prove the receiver fit and phase, but frame `03` exposes the sharp-turn offset discontinuity rather than a closed overlay. |
| Exact receiver — ordinary gameplay | **FAIL** | The material remains quiet and plausible at ordinary distance, yet the sharp-turn strips persist in images `06`, `11`, and `14`; they cannot be promoted as a documented survey limitation. |
| Changed-light behavior | **PASS** for material; **FAIL** for closed field | Image `14` shows neutral diffuse darkening without baked light or metallic glare, while the corner lines remain legible. |
| Completed elevation | **UNREVIEWED — BLOCKED** | A homogeneous field supplies no surveyed module schedule, trim sequence, bands, openings, entrance, or emblems. |
| Whole building | **UNREVIEWED — BLOCKED** | The field covers neither all outer runs nor other sides, inner ring, separate tower, silhouette, or massing. |
| Overall field verdict | **CORRECT** | Fix the shared offset geometry and recapture before live attachment. |

The hard patterned-to-ivory changes at the far edges of images `01` and `05` are outside-scope receiver surfaces, not failures at joins `21→22` or `50→51`. The failure is narrower and occurs where adjacent in-scope face normals diverge after the helper applies the overlay offset.

## `FIT-CENTRAL-W-R36` gates

| Gate | Result | Finding |
| --- | --- | --- |
| Numeric opposite-edge seam | **N/A** | Complete `module_atlas` motif; it is not a wall tile. |
| Semantic motif completeness | **PASS** | The full tall narrow opening, outer frame, dark glazing field, central mullion, and three crossbars remain present; no motif piece is missing, duplicated, or resized independently. |
| Reference / region compatibility | **PASS_WITH_DOCUMENTED_LIMITATION** | The tall narrow multipane silhouette belongs to the observed broad curved CENTRAL family, but the actual subsequence and anchor remain unknown. |
| Physical scale / proportions | **PASS_WITH_DOCUMENTED_LIMITATION** | The nominal `1.45 × 4.60 m` study reads as a plausible tall narrow opening on the `20 m` receiver and sits inside the declared `0.8..1.8 × 3.0..5.5 m` production envelope; none of those dimensions is surveyed. |
| Wall contact / shallow depth | **PASS** | Close and oblique views show a shallow, flush frame with a readable edge rather than a floating card. |
| Backing / halo / z-fight / intersection | **PASS** | The module has `9` meshes / `9` surfaces / `108` triangles and zero field/backing/collision/navigation ownership. No surrounding slab, patch halo, flicker, wall penetration, ground conflict, or corner strike appears. |
| Exact receiver — close / oblique | **PASS** | Images `07` and `08` preserve the complete motif, wall contact, and host field around the opening. |
| Ordinary gameplay read | **PASS** | Image `11` keeps the tall-window identity legible without making one exemplar read as a completed sequence. |
| Changed-light behavior | **PASS** | Image `14` preserves dark glazing, light trim, shallow depth, and nonmetallic response. |
| Exact real placement | **UNREVIEWED — BLOCKED** | Run `36` midpoint is a deterministic production-inference fit anchor only. |
| Count / cadence / sequence | **UNREVIEWED — BLOCKED** | One study establishes neither repetition nor order. |
| Overall study verdict | **ACCEPT_WITH_DOCUMENTED_LIMITATION** | Scale and contact study is sound; no live placement eligibility follows. |

## `FIT-PAV-W-R06` gates

| Gate | Result | Finding |
| --- | --- | --- |
| Numeric opposite-edge seam | **N/A** | Complete `module_atlas` motif; it is not a wall tile. |
| Semantic motif completeness | **PASS** | The full dominant grouped opening, outer frame, two vertical dividers, and four crossbars remain present. It reads as one complete pavilion-window family token. |
| Reference / region compatibility | **PASS_WITH_DOCUMENTED_LIMITATION** | The full-height grouped proportion is compatible with the observed end-pavilion family; run `6` is only a mechanically eligible north-end study surface, not an observed anchor. |
| Physical scale / proportions | **PASS_WITH_DOCUMENTED_LIMITATION** | The nominal `5.40 × 10.00 m` study is plausible against the `20 m` receiver and inside the declared `4..7 × 8..14 m` envelope; real scale remains unsurveyed. |
| Wall contact / shallow depth | **PASS** | Close and oblique views show consistent shallow relief and a grounded wall fit. |
| Backing / halo / z-fight / intersection | **PASS** | The module has `13` meshes / `13` surfaces / `156` triangles and zero field/backing/collision/navigation ownership. No slab, halo, shimmer, wall penetration, terrain conflict, or corner collision is visible. |
| Surrounding field ownership | **PASS** | The mottled host around the PAV in images `09`, `10`, `12`, and `15` is the unchanged run-6 receiver outside the exact ivory chain, not module backing. |
| Exact receiver — close / oblique | **PASS** | Images `09` and `10` show the full group, proportion, contact, and shallow projection. |
| Ordinary gameplay read | **PASS** | Image `12` keeps the dominant pavilion-group silhouette legible without implying flanking composition or repetition. |
| Changed-light behavior | **PASS** | Image `15` preserves trim/glazing separation and diffuse host response without baked lighting or false metallic behavior. |
| Exact real placement | **UNREVIEWED — BLOCKED** | Run `6` midpoint is a deterministic production-inference fit anchor only. |
| Count / cadence / sequence | **UNREVIEWED — BLOCKED** | One study does not establish the pavilion composition, flanking openings, or either end's schedule. |
| Overall study verdict | **ACCEPT_WITH_DOCUMENTED_LIMITATION** | Scale and contact study is sound; no live placement eligibility follows. |

## Aggregate gates

| Gate | Result | Finding |
| --- | --- | --- |
| Asset-kind separation | **PASS** | One homogeneous field owns the wall finish; CENTRAL and PAV retain complete module semantics and own no backing field. |
| Topology / receiver isolation | **PASS** | Detached overlay totals are `23` meshes / `23` surfaces / `326` triangles: field `1/1/62`, modules `22/22/264`. Receiver children stay `2→2`; the overlay is a sibling, with zero collision, navigation, spray, or runtime attachment. |
| Material identity / macro read | **PASS** | The material is absolutely compatible with the approved warm-ivory observation and does not show a facade-scale repeated blotch over `85 m+`. |
| Exact field physical continuity | **FAIL** | The offset geometry creates render-space gaps even though source endpoints and U phase are exact. |
| Module scale/contact study | **PASS_WITH_DOCUMENTED_LIMITATION** | Both complete motifs fit their selected receiver surfaces plausibly and cleanly, but neither placement is reference-anchored. |
| Sparse-inference truth | **PASS** | Exactly one CENTRAL and one PAV are shown, with persistent labels denying anchor, count, cadence, and sequence. |
| Whole-building context | **PASS as disclosure; BLOCKED as acceptance** | Image `13` locates both studies and the public curve while plainly exposing the uniform extrusion's mismatch to observed lower wings/taller pavilions. |
| Completed public elevation | **UNREVIEWED — BLOCKED** | The field plus two unanchored fit studies does not establish the observed window families, bands, entrance, or ordering. |
| Whole-building resemblance | **UNREVIEWED — BLOCKED** | Other outer runs/sides, inner ring, separate tower, massing, roofline, entrance/canopy, and emblems remain unresolved. |
| Aggregate verdict | **CORRECT** | Correct the field joins; retain the two module results as fit studies only. |

## Visual findings

1. The warm-ivory field is materially credible rather than merely better than the generated placeholder. It is restrained, motif-free, matte, and consistent with the approved public-elevation observations under both sun directions.
2. Chain-metre projection succeeds: there is no run-by-run texture reset, obvious macro period, repeated repair patch, baked shadow, or metallic response. The field defect is geometric and localized to the post-offset joins.
3. The source-space join proof is incomplete for rendered truth. A single surface and `0.0 m` source endpoint delta do not close duplicated vertices after different normal offsets. The sharp-turn strips are the reason for `CORRECT`.
4. CENTRAL remains a complete tall multipane motif at close, oblique, ordinary, and changed light. Its narrow scale is plausible against the host, but it cannot establish a curved-center schedule.
5. PAV remains a complete dominant grouped opening and reads plausibly at the tall north-end study surface. The existing mottled receiver around it correctly demonstrates that the module owns no ivory backing.
6. Neither module floats, sinks into terrain, strikes a corner, carries a host-colored slab, or creates visible z-fight. Both are sound fit studies independent of the field correction.
7. The aerial context is useful precisely because it is not flattering: it shows that these studies do not repair the known uniform-`20 m` massing mismatch or create whole-building resemblance.

## Lifecycle decision

The lifecycle **may not advance** `B1-MAT-IVORY` on outer runs `21..51` to live attachment / pending actual-world review from this package. After the single shared-miter correction and a sealed native recapture proving all sharp joins closed at close and ordinary distance, the unchanged bounded field scope may return for re-review.

`FIT-CENTRAL-W-R36` and `FIT-PAV-W-R06` are independently accepted only as detached calibration fit studies. This review gives them **no** placement-approved status and **no** live-integration eligibility. Advancing either module would require new approved local evidence that anchors a real run/coordinate and supports its count/cadence/sequence claim, followed by a new detached exact-placement review.

## Remaining blocked claims

- `B1-WING-W`, `B1-BASE-O`, `B1-DOOR-BLUE`, and `B1-BAND` exact receiver calibration or placement.
- Any actual CENTRAL or PAV run, coordinate, count, cadence, interval, flanking composition, or sequence; any second module instance.
- Field use outside ordered outer runs `21..51`, including all other outer runs/sides, ambiguous runs `93..96`, the ten-run inner ring, the tiny secondary union/sliver, and the separate observation tower.
- Any claim that the field's `1.10/0.32 m` scale, color, roughness, wall dimensions, coordinates, or module dimensions are surveyed.
- Main entrance, canopy, high emblems, doors/openings not represented by the two studies, repairs, edge trims, roofline, and deep architectural projection.
- Lower-wing/taller-pavilion massing, story/silhouette correction, completed public elevation, complete facade, or whole-building resemblance.
- Any live-world visual, lifecycle, runtime, collision, gameplay, or integration acceptance.

## Evidence integrity

The sealed `checksums.sha256` ledger verifies **26/26** listed files. It hashes to `1578935f859522342396c98feb3116350ff8ae5c43cbddefea278f0b6440ce65`; `capture-manifest.json` hashes to `9e84fb33d095546a422469dc8c5d6433eae194b7300aa1595968cc5a9d2005bb`. All `15` manifest-listed captures are native Godot 4.7.2 Forward+/Metal `1440 × 900` PNGs; file bytes and SHA-256 values agree with both the manifest and ledger.

The current applicable exact-calibration and evidence contracts are present and sealed by the ledger. The older standalone sentinel first preserves its standalone/source/runtime pins and then intentionally rejects the later exact registry; it is lifecycle-obsolete and is not art evidence against this package. The capture records zero live attachment and zero actual module placements. Its isolation record preserves receiver children `2→2` and the loaded-world topology snapshot (`729` records, `924` meshes, `934` surfaces, `50,729` triangles, `466` bodies/shapes) without overlay mutation.

| Evidence file | SHA-256 |
| --- | --- |
| `README.md` | `8ef6448a5dd609575f09a4a8738bcb1441bab28b020cf67eaea90f4d8b170a1a` |
| `capture-manifest.json` | `9e84fb33d095546a422469dc8c5d6433eae194b7300aa1595968cc5a9d2005bb` |
| `runtime-isolation.json` | `b7d77ef861ce0e5f17a0577e9680f153111b95a477fa330af8ee420894489878` |
| `visual-verification.json` | `2d7672d43cb6ae67d6bfdb65fda272a18a97fdc1138bdb1590214f8725825f58` |
| `checksums.sha256` | `1578935f859522342396c98feb3116350ff8ae5c43cbddefea278f0b6440ce65` |

| Native capture | SHA-256 |
| --- | --- |
| `01-field-join-21-22.png` | `dac664de10f7d85e16f4cd9d7542bf457f66a5c901bff728f4ecc87245a21229` |
| `02-field-join-30-31.png` | `c5882a75f47061a58b88929d8b6d56186e5a94d35a632d60721806bcf10c5e42` |
| `03-field-join-38-39.png` | `ff71bec44e2c9c7a6e04b8fc5c3268a675ac83f01074271db4c2242d74f0370e` |
| `04-field-join-45-46.png` | `29c88df108519e0820bea52380a631157a0096fcc7596879be1e6b1ea7952d3b` |
| `05-field-join-50-51.png` | `1bbed6cc060df8e06f8c52e714e7d9e051cf3ae5c5f60982728b5ebc22ee1e65` |
| `06-field-macro-85m.png` | `a31db222dbb28534835cf87a12d6408261a47646f8d969dc9f912e28c96a5a19` |
| `07-central-close.png` | `49e4fb3d9cb31f0d1994090c5213296374c3e00c58fc54cb2ed9803ca8c992f2` |
| `08-central-oblique.png` | `98d827cb998aa0e2176fa7fd31328cd17c0a1e0b2181461a033406c5c8541e00` |
| `09-pavilion-close.png` | `089c52b7ed2ce17c56373de569ed719bf26073e7a9d637800fe4c83f4c72dbba` |
| `10-pavilion-oblique.png` | `6d91c4082ebd617b9ede946902f072a5c1e42319088b0d04d9af1bfaa33f1a07` |
| `11-central-ordinary.png` | `53790b5ea4464fc9a6d391b5e838c2b88ace1545f52f87daf21ac0e0bffeb901` |
| `12-pavilion-ordinary.png` | `a14d94d642a43c381be253799340942f81bb9aaaf2b6a3f7d7b9670f17a4b67e` |
| `13-whole-building-context.png` | `a324ec70b13a56a8d98f24d49ad78cd4aa9630fd3006a20b1e87bd64e0451764` |
| `14-central-changed-light.png` | `74bf13322d27d7d76a2591cd5c9716e692bf29c11fba0b2bba14a3d7b8e0cdb5` |
| `15-pavilion-changed-light.png` | `9a16b78a89457a6bb7725d47ba06702fc3e9be2cda4b67903d3a1b4bd9810459` |

## Reviewed source pins

| Source | SHA-256 |
| --- | --- |
| Exact registry | `10ab1f25d0f9d37ccbb20be9dfe77a37c66f63918b1fdf070c1de9c61633414a` |
| Exact helper | `b31bda7a510b2f343f0db0f0199128b0c945cb5e7afc60b69e0d9801aff5be79` |
| Exact scene | `3fb0c925cec5d65e0d7ed3ca86c1d8d464c4f43965997545af5c0b575978b0cb` |
| Exact scene script | `2b21baff993ee30652072e3f51d95a239d2d22a77e0ff025f0dfe44fb1baa730` |
| Exact material | `12d059d9d806c629225254f1aaf945be69a00ce5878db276ce299ad0c8cdbb9a` |
| Procedural field shader | `a4a5df4fbb8fd4f13187ec284708879b540677ac2c827642b4c3040b4bce4c09` |
| Capture harness | `d642d7a7bdf90ad42b3c1dd0364ae4a005c7666fc99f69e1d26ddf1e4bf8f276` |
| Run-ownership mapping | `716f90b9d7cb3267e901d438a5c583047c8eaeb912e544a459005c2dbe6a4359` |
| Accepted standalone art review | `8d33bf21c29bf6347a17eabf98e7a8c66eb23a38649a0e3af0f03c0a82feedcb` |

No runtime, asset, registry, helper, material, test, contract, harness, evidence, inventory, or `r133351` file was changed by this review.
