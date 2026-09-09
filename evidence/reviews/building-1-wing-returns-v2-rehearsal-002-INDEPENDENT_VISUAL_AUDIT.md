# Building 1 wing returns v2 — independent visual audit

Date: **2026-09-08**

Reviewer: **`/root/next_building_prep`**, independent of B1 implementation and its
source/mechanical reviewer.

Verdict: **PASS** for the bounded wing-return visual improvement in rehearsal002.
Recognition credit: **+0**; accepted authority remains **9/213**. This review
permits root to consider the subsequent authority transaction. It does not itself
promote source, change authority, or grant a current release PASS.

## Visual judgment

The candidate clears the quality floor for this specific architectural change.
At ordinary near-oblique views on both wings, the new pale jamb and sill faces
make the windows read as shallow assemblies with thickness and a clearer
relationship between glass, trim and wall. The accepted baseline's narrower
window edges read more like thin frames laid on the wall. The improvement is
especially legible at the lower north windows in image03, the south corner
windows in image05, and the close ordinary spray view in image09. It is a real
local construction-depth improvement, rather than a color-only change or simply
the removal of the rejected v1 defect.

The whole-front gain is **modest**. In image01 and the far image02/image04 pairs,
the wings remain quiet secondary window fields. This is appropriate for the
bounded return pass: the curved center's tall glazing, vertical trim, canopy and
entrance still lead the composition. I do not equate this local PASS with a
comprehensive Building 1 redesign, finished material polish, or a new quality
ceiling for the project.

## Findings from actual originals

| Reviewed set | Independent visual finding |
| --- | --- |
| Whole front and north/south near/far, default light | Attached pale side faces and short sill edges are clearer at near obliques; dark panes remain contained inside the frames. At far range the change is small and does not compete with the center. |
| Same five poses, changed light | The depth cue becomes flatter under the alternate light, but the pale side thickness remains readable at the near windows. No external dark gasket, L-card, or unrelated shadow slab appears. |
| Same five poses, derived grayscale | The near-window improvement remains visible as edge thickness; it does not depend on a new color accent. The center retains the strongest glazing/trim rhythm. These are verified derived images, not a third lighting capture. |
| Real spray, image09 | The close lower windows show connected jamb/sill surfaces behind the front trim; no visible air gap or detached perimeter appears. The spray mark remains on the same blank pier and clear of the window additions. |
| Protected rear and accepted tower, images06–08 | The quiet rear, octagonal tower silhouette and its light frame/dark glazing balance remain visually unchanged. No new hidden facade claim follows. |
| Main-roof landing, image10 | The supplied final landing view remains the same roof/wall relationship. The image supports visual continuity; the actual input-driven landing/ownership result belongs to the independent mechanical receipt. |
| Whole context, image11 | Building 1 retains the same silhouette, setting and center-first hierarchy; no camera change makes the candidate appear larger or hides a wing defect. |
| Elevated image12 | Roof and tower continuity are preserved. This is diagnostic-only and is not used to earn the ordinary-gameplay quality verdict. |

I observed no new external black bracket/card/gasket, detached white return,
white cage/barcode effect, or obvious z-fighting in the reviewed originals.
Fine edge rasterization and shadow grain remain visible in both stages; this
review does not claim their elimination.

## Ordered motion review and its limit

I opened every original A/B motion image in the recorded approach order:
**60 m → 45 m → 30 m → 25 m**, with consecutive samples **0, 1, 2** at each
threshold, separately for north and south. This is 24 images per side across
baseline/candidate, 48 total. At the near thresholds the pale window side faces
become more apparent as distance closes; they remain attached to the same
openings. I found no new edge switching, detached strip, gross shimmer, or
abrupt geometry pop within the supplied consecutive sample groups, or a new
structural inconsistency between their approach thresholds.

These are **sampled motion sequences**, not a continuous video. I did not observe
every intervening rendered frame and cannot certify the absence of transient
artifacts outside the supplied samples. The independent audit, rather than this
pixel review, establishes matching controller telemetry, exact A/B motion poses,
and the absence of post-start transform writes. No new runtime or capture was
requested or executed for this review.

## Baseline, rejected v1 and reference comparison

The accepted comparison is the baseline source at
`b4ab09356c8a15843fa295af024434f97027e1fe`, as established by the mechanical audit.
All 46 baseline and 46 candidate rehearsal002 originals were opened at native
1440×900 using original-detail image inspection. No crop, enhancement,
recoloring, generated image, or contact sheet was used to make the decision.

For the explicit rejected-v1 comparison, I reopened four native candidate
originals from rehearsal004: north near/default, south near/changed, and each
wing's 25m-1 motion sample. V1's visible black lateral and bottom cards form
external L-shaped brackets around the pale frames. V2 removes that visual
failure and adds restrained pale construction thickness. V1 remains rejected;
its stronger contrast is not treated as a quality target.

The previously read local reference observations describe warm ivory walls,
lighter trim, dark blue-gray glazing, differentiated center/wing/end window
families, and the center/tower hierarchy. V2 stays consistent with those observed
relationships and does not invent ornament or hidden-rear detail. This is an
assessment against those retained written observations, not a claim of fresh
external-photo inspection or exact physical return-depth measurement. The older
next-pass document is historical context; it is not new acceptance policy.
No external source pixels were downloaded, retained, or reproduced.

## Bounded action and proof boundaries

No corrective visual change is required before root considers this exact
candidate's scoped promotion. Preserve the restrained pale return treatment and
the accepted center/tower/rear relationships. Do not inflate the returns or
reintroduce dark backing to manufacture a larger whole-front difference.

The independent mechanical audit's raw verdict is
`PASS_FOR_B1_RETURNS_V2_REHEARSAL_MECHANICS_ONLY`. It binds rehearsal002's
92 PNGs and six manifests to ordered input-tree SHA-256
`5046e9bb1aaec4b79ecc0649087a33e54c6b87de291d1376ed3ad76bce7d6dff`.
I rehashed the actual reviewed PNGs and the four input documents below to bind
this visual judgment. I did not duplicate the mechanical tests or re-audit the
entire dependency closure.

The candidate PCK is SHA-256
`59b37cf856dd1ece6aaadeee5c6278327997394339bb8450253193cbd89728da`;
seven-file app identity is
`742f325cd7634d01474105f7c2e01b6f254d72385a78341768148b9b87fc2897`.
Those are package identities from the independent audit. The reviewed pixels
are native Metal renders of exact **source checkouts**, with separately proved
corresponding PCK semantics. They are **not package-rendered pixels**.

The ordinary no-argument signed-app observation proves an OS-visible window;
scoped screenshot capture was unavailable, so no independent player-pixel or
ordinary interactive-play claim follows. The historical combined release smoke
still rejected with exit1; current full release checks remain outstanding.
This visual PASS does not override those limits.

## Review input identities

| Input | Absolute path | SHA-256 |
| --- | --- | --- |
| Independent mechanical audit | `/Volumes/Macintosh_HD/Users/user302070/code/treasure-island/evidence/reviews/building-1-wing-returns-v2-rehearsal-2026-09-08-INDEPENDENT_MECHANICAL_AUDIT.md` | `63a3ca3368929982e82a74b2ed00a7afbf063c408e21acad2cc9ceed5fdcf13b` |
| Complete candidate handoff | `/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/b1-v2-001/candidate-package-capture-handoff.json` | `fd746ea5e2645b827e2b65af07d6f70713be5ce20a7da4061700c958ecddb725` |
| Sealed rehearsal002 receipt | `/private/tmp/b1-returns-v2-rehearsal-002/rehearsal-verification-receipt.json` | `cae3db47439fa0e4e70fdbb12a37daa7c431cd7bed6574433a701da740073bb0` |
| Frozen v1 visual HOLD | `/Volumes/Macintosh_HD/Users/user302070/code/treasure-island/evidence/reviews/building-1-wing-window-reveal-rehearsal-004-INDEPENDENT_VISUAL_HOLD.md` | `26c1327118db37f18e7082c99bd9e0b4c96e76b97b30fb2a7f9fe5fd6c3edcba` |

The following previously read local documents supplied policy/reference context:

| Path relative to repository | SHA-256 |
| --- | --- |
| `AGENTS.md` | `636b50961962268ab8587e8190256e7db533210c08b5bea8957f1e721b0f7b63` |
| `discovery/facades/TREASURE_ISLAND_MUSEUM_BUILDING_1_REFERENCE_SPEC.md` | `79fe7b7cc49ea5e40a8611313defacb07ec23fb1a1a711822e0378b8cc32ac5a` |
| `discovery/facades/TREASURE_ISLAND_BUILDING_1_HERO_RECOGNIZABILITY_SPEC.md` | `135ef9ae411d41892d25d1c679d10fe022193348b6406c4a8abecb55805c9720` |
| `discovery/facades/BUILDING_1_BAR_RAISER_NEXT_PASS_2026-09-04.md` | `52834965da21def3328c343dab651c04b86e7477ca488d378ef103e569ae8264` |

## Complete reviewed-image list and hashes

All paths in the following table are relative to
`/private/tmp/b1-returns-v2-rehearsal-002`. Each file was opened as an original
image; sorting here is for reproducibility, not playback order.

| Reviewed original | SHA-256 | Bytes |
| --- | --- | ---: |
| `stages/baseline/images/01-whole-front-changed.png` | `195a791d053bd04096510fa5b7d100338a7a19fe08797a5a0bd2d06899b54032` | 729725 |
| `stages/baseline/images/01-whole-front-default.png` | `063d756ef18b7b63cd146b07e8dcd7ca6457eb987cb9fb4f238cf040bee2c644` | 835203 |
| `stages/baseline/images/01-whole-front-grayscale.png` | `3cc0bc964909bbfe1824ce69096b29c8c71d59e29727d851b37c19b75147a884` | 295021 |
| `stages/baseline/images/02-north-wing-far-changed.png` | `8b8849450116250f6c827a20fbcfc1284b7b7a0c8305d7eee473f1682f24eaae` | 765322 |
| `stages/baseline/images/02-north-wing-far-default.png` | `a34c846faa9abd2f73e041c650f66d326b6a3aa9761c4600bd7383d4c5099e98` | 890842 |
| `stages/baseline/images/02-north-wing-far-grayscale.png` | `0e7caded2d63e1d4929d04d64f2212a6aef948035ef668b523d34fb14d1a5cae` | 313187 |
| `stages/baseline/images/03-north-wing-near-changed.png` | `2d13ed5d22c0c477559a52598a55ff2cf011be9c97aff8a8d2440416dc72024c` | 490610 |
| `stages/baseline/images/03-north-wing-near-default.png` | `c56261e433991d7c5ba9f1d1e93b58b8f59c6dd72aecb64fe37fa1a50b2b7b5d` | 716222 |
| `stages/baseline/images/03-north-wing-near-grayscale.png` | `1117332069ab98c2fe414e2aef62997b1eb59734f6fd104bfc2a47a8e3c3254c` | 269377 |
| `stages/baseline/images/04-south-wing-far-changed.png` | `1a8c13398f40fd3ece4192fed56e5d99860939a9a1d9f113f13db94811f73a4a` | 657447 |
| `stages/baseline/images/04-south-wing-far-default.png` | `40f734a9d1e56c83dba5ec33b05372b750c6899bb02d34a873d14eedf714fc78` | 741693 |
| `stages/baseline/images/04-south-wing-far-grayscale.png` | `a94ad6336fad02704a98bf462a20a8b92526ae119b7774db009ae05d17fb2ea0` | 272647 |
| `stages/baseline/images/05-south-wing-near-changed.png` | `efcd1796a0a289a58a59723ace70f34c3460ffefc2cef198206a4479cc3cc704` | 585214 |
| `stages/baseline/images/05-south-wing-near-default.png` | `e856e69bcb94aa39bdf22d128df9e2c42164bd4d362ed1c860b96822b2f0545b` | 790143 |
| `stages/baseline/images/05-south-wing-near-grayscale.png` | `5d1b514c5eee5887cddaac8c997a3fd447678ba50d6e45635605b629182cb6c6` | 281750 |
| `stages/baseline/images/06-protected-rear-east.png` | `065794cd34e9e6aa4eef6dbdf5c44490005944226e5d0ec2fd8501eccd7ae9ae` | 757675 |
| `stages/baseline/images/07-tower-accepted-pose-one.png` | `bd21f8e86445365fdc8b0a091146789676dba177468f79def1dbc64cc6de1543` | 954144 |
| `stages/baseline/images/08-tower-accepted-pose-two.png` | `c597cf4404a0e7ab9d648f735e09f7c761500292b92cda9d6f4655111662bed6` | 976007 |
| `stages/baseline/images/09-real-spray-blank-wing-pier.png` | `bc6c14067e0142135e7090f5048be1548b20259d2aa209ae93089e23200bab89` | 823516 |
| `stages/baseline/images/10-real-player-main-roof-landing.png` | `bffa0d4fb6ca61662167494ebf10d817eb2817ca272a8d576cd75a3a1ec55404` | 129652 |
| `stages/baseline/images/11-whole-context.png` | `a90426e20b5fa6db2e20af1113c7ebd372b751ee403668d88b5315d97af51a9c` | 847979 |
| `stages/baseline/images/12-elevated-overview-diagnostic-only.png` | `4df17bc38a4a50a9c89be662de2e305004fdb06bde6a7e94616aab70e71da20c` | 369910 |
| `stages/baseline/motion/north/25m-0.png` | `27837895b840daa8032c927586f67e2c818d8feb28a399fcea94180f442fd2db` | 851185 |
| `stages/baseline/motion/north/25m-1.png` | `05bb1effbaa255f2d7f0f3ab67500cea1b67cdd8de64496f678aeece824c2f99` | 851749 |
| `stages/baseline/motion/north/25m-2.png` | `7948b4027899850f8c125fba496bd91716d609eba735f489b67b38f9de304466` | 851404 |
| `stages/baseline/motion/north/30m-0.png` | `c81be4a24bf77a442fdbec1a79ca68bd7931319609327db6ee799399ef16f9d2` | 890499 |
| `stages/baseline/motion/north/30m-1.png` | `53963bd6972a33af30721f1a2686a43a1200faf74091e0dcf63c3f76e1977305` | 889299 |
| `stages/baseline/motion/north/30m-2.png` | `b5d717972a07c48c5167652b0bbd7e10597bcc9bb477bdcf9b81663492ecc2dc` | 890140 |
| `stages/baseline/motion/north/45m-0.png` | `d3ff2471036a146bf2bd55e47a99b2052f485c869d260a0f307bc70ad8eb03e7` | 932029 |
| `stages/baseline/motion/north/45m-1.png` | `b83443b5d68a78c6e2e48e221a7f8eb7c650f61836a0588341d404ed725434da` | 931024 |
| `stages/baseline/motion/north/45m-2.png` | `224030c9930a9807cd8e0e610c7ec8bbe629bfe4613039ab5927a02c18ebcdc4` | 931137 |
| `stages/baseline/motion/north/60m-0.png` | `5ca33d11d03da3a0da47f92701f106c1a952c349289f48aa4eb167deb5214f9d` | 890696 |
| `stages/baseline/motion/north/60m-1.png` | `546af4b46e8ca1fc6c6dac4b31b43c9644236a7c3a2b8fe947d0c17cd3dc27b0` | 891280 |
| `stages/baseline/motion/north/60m-2.png` | `ec29d29696bd1a2600e995ec02da8d0b2e5e77df1a490a3abbd1ef76317e64b7` | 891162 |
| `stages/baseline/motion/south/25m-0.png` | `5c6b71522f1913019eac7d1cc7b56993c68ed6ea41f84b962e12a88c6235a564` | 929953 |
| `stages/baseline/motion/south/25m-1.png` | `1146b450351112c8a5c7477dfa36672c064d4e72606585e8a20e37b2d8b5f3c8` | 929483 |
| `stages/baseline/motion/south/25m-2.png` | `c253e5735b5784b621b118749687c4054993b50ba1119c7128cc7db759f7035c` | 929308 |
| `stages/baseline/motion/south/30m-0.png` | `4a6bdfafb6de24a2520de30ff0be115480b173f34c994ba1e025963827a0f10e` | 876063 |
| `stages/baseline/motion/south/30m-1.png` | `d5e9d8f80d4feec28cbd8f118186515024d047c1a3380c3e4e148e3d4960d8e3` | 876780 |
| `stages/baseline/motion/south/30m-2.png` | `7d559d5d70864fca43c8f6c4f99467fa9711dc634aeb888fe5e2afcea7f204a1` | 878532 |
| `stages/baseline/motion/south/45m-0.png` | `c29a686eb9348150c9b83e945b5d2be5a2818ddb93cef965d81f7841477edb08` | 924048 |
| `stages/baseline/motion/south/45m-1.png` | `ecd1401a212d81c3fd3f467da3c9ef5e4c083a371d90b58684869f1669fe9158` | 924365 |
| `stages/baseline/motion/south/45m-2.png` | `494fe5e4f1794b163c6442a667731e74c78ede4f8ab1ed0ca5f5a48043d7f71f` | 923809 |
| `stages/baseline/motion/south/60m-0.png` | `d81355afe01dd7c46473c79208f73e881aac23b458f2cd21435cbb59ab949cbb` | 741628 |
| `stages/baseline/motion/south/60m-1.png` | `212e72c2ad31cf12fd2f6bd604f671b2f3936277fce23cb6f07bafe378698e16` | 741261 |
| `stages/baseline/motion/south/60m-2.png` | `1a26ad7bd215d0e7305771889b2a44c878c5f800ab00123d19187e64d3910bba` | 740866 |
| `stages/candidate/images/01-whole-front-changed.png` | `8bd8f2e9230a52be562bffe9d3c6ea8bed25be90dd46719148538b944254e640` | 729262 |
| `stages/candidate/images/01-whole-front-default.png` | `2ffc50f8af3c5777bf7250f05f67fe405c0e1f48678541968f32b86aab2f131e` | 834888 |
| `stages/candidate/images/01-whole-front-grayscale.png` | `1675e48bea3f26e97f1eb66d75fe5e2adab425997a2a2abe330f0f234d2b685c` | 294977 |
| `stages/candidate/images/02-north-wing-far-changed.png` | `dbeb6d7095c5aeed0955e0d5d5659f3f1234dbe06830d2c334b9e0f61c3e8cff` | 765220 |
| `stages/candidate/images/02-north-wing-far-default.png` | `4e1484102e1fdcc69bbff6714a1b138b1ef2bfe2102dd2991e518148dd6e5178` | 890873 |
| `stages/candidate/images/02-north-wing-far-grayscale.png` | `bca0d54ee97ed949c96b1de27cd79a2be5f078b2e68d2d214ec32f661f497eef` | 313218 |
| `stages/candidate/images/03-north-wing-near-changed.png` | `05ebad04213e23e2d99362d2b44ee6c5c5327474c26b0255e34f3c2d75e02b2a` | 489864 |
| `stages/candidate/images/03-north-wing-near-default.png` | `34e005f7353e6e2427ea55c40bb50d97c8b2f6473e808140d2929a6478b07d19` | 717216 |
| `stages/candidate/images/03-north-wing-near-grayscale.png` | `e7dca16c5a57572089992de56ff38e85b801ba24ef9938f7504c8107f0118053` | 269977 |
| `stages/candidate/images/04-south-wing-far-changed.png` | `c073b3b99aa3b773f5e5cc928f999c75e5a73a400051c3f9c1b6e3b13364068b` | 657354 |
| `stages/candidate/images/04-south-wing-far-default.png` | `453800a0bb521f92e7273b30c8e519e3a5ef868761557bc87e726e06e410da0f` | 741458 |
| `stages/candidate/images/04-south-wing-far-grayscale.png` | `0bdb2b2504eaf512c1f5eed12194943d1debe226d877a4c0d04884f23ed9ba52` | 272593 |
| `stages/candidate/images/05-south-wing-near-changed.png` | `997329bec0bb576d6e9ba8d99860340cb4510f0103daea0194364f402dc49ebf` | 584828 |
| `stages/candidate/images/05-south-wing-near-default.png` | `99b9e004ed4e1aa80d3b7a58c21aab1c2875828e2a1eebf1fe4692a3b26d4106` | 789448 |
| `stages/candidate/images/05-south-wing-near-grayscale.png` | `283770469b0daad371b9c91523a87aafa68a11580e1752acafec0205a11f16dc` | 281538 |
| `stages/candidate/images/06-protected-rear-east.png` | `065794cd34e9e6aa4eef6dbdf5c44490005944226e5d0ec2fd8501eccd7ae9ae` | 757675 |
| `stages/candidate/images/07-tower-accepted-pose-one.png` | `bd21f8e86445365fdc8b0a091146789676dba177468f79def1dbc64cc6de1543` | 954144 |
| `stages/candidate/images/08-tower-accepted-pose-two.png` | `c597cf4404a0e7ab9d648f735e09f7c761500292b92cda9d6f4655111662bed6` | 976007 |
| `stages/candidate/images/09-real-spray-blank-wing-pier.png` | `9ab3441629bfff5719327dd7864c98f1600fe0510b8a9657d84490f2ffd1f3db` | 824846 |
| `stages/candidate/images/10-real-player-main-roof-landing.png` | `bffa0d4fb6ca61662167494ebf10d817eb2817ca272a8d576cd75a3a1ec55404` | 129652 |
| `stages/candidate/images/11-whole-context.png` | `ec07e45bedc5c90b2a6385cf028a83f8521a1e20d4eebb61fa3ff2cb66f956de` | 847915 |
| `stages/candidate/images/12-elevated-overview-diagnostic-only.png` | `e045ccb4caba24fed99fbb3c4a0895bac10b631b6cbf639bb2bc34f1f3998a0e` | 369787 |
| `stages/candidate/motion/north/25m-0.png` | `150c2ca4d2111aa20b3120834edea3c6c2fc477d8482b29a0ebfe31f95bb8b04` | 852017 |
| `stages/candidate/motion/north/25m-1.png` | `138152c69aebf3d1ae4647839bfbb5cfc69f67e3778a90b569951a173383c926` | 852627 |
| `stages/candidate/motion/north/25m-2.png` | `f04e9d3f9c824e456292b0d0acf51086c3eddc9e7397c796509a8cb175023601` | 852372 |
| `stages/candidate/motion/north/30m-0.png` | `234d55d7c66b1a68b92c8f341db9f3b637f1f72fc9d78406eb68ea856c765af8` | 891055 |
| `stages/candidate/motion/north/30m-1.png` | `85d75a70900ac3ec9c96bfa4b3a0cb3f2bffca3b86c54c40a5d9b4585c97e9c5` | 890014 |
| `stages/candidate/motion/north/30m-2.png` | `26758b04a63e38b61323530a1d22fdb603c2d57b23d4a1d8944e228ecb75ec3e` | 890822 |
| `stages/candidate/motion/north/45m-0.png` | `a72689c15c9258be0747f877de03970d0a68de9311ca9cc58c71d20f7ca44215` | 932207 |
| `stages/candidate/motion/north/45m-1.png` | `400868e22df3370879a02120adc0117b38407597310182edf07aff58cd40aa1b` | 931314 |
| `stages/candidate/motion/north/45m-2.png` | `d07b7d3e75e7eee75b05100ab2d904e5687f266711f324c9ff87e4df64ce7564` | 931414 |
| `stages/candidate/motion/north/60m-0.png` | `3d68f5b456f6e53bb63ff5c055074298382ae0105f89272d2e772e546990a751` | 890748 |
| `stages/candidate/motion/north/60m-1.png` | `0a533f655ce75baff22f624bb99b8b1fe74a0bfd28fd2e6c3af7f8898207b866` | 891296 |
| `stages/candidate/motion/north/60m-2.png` | `d67051bdbcb3a25c55b33f9f51c850b84c926d8b7973760ccb38a194246d1ace` | 891225 |
| `stages/candidate/motion/south/25m-0.png` | `b3c614c3975beffe8355364e2ff9167f5b26486004a7ebadee4b96467e96924f` | 929359 |
| `stages/candidate/motion/south/25m-1.png` | `664225cc6a6426e1a00fa417c90e0a6a65cf35beee20913b55fafcedd09a898b` | 928691 |
| `stages/candidate/motion/south/25m-2.png` | `8d7f06a6c0b50b3db327bfd65cc187f7f87d395912ff1e180197298bad1037f4` | 928466 |
| `stages/candidate/motion/south/30m-0.png` | `64fc31d58b2e3790d49781c8ca40740c3ac292c877da571d6f656b22ba1d7d53` | 875633 |
| `stages/candidate/motion/south/30m-1.png` | `d396f8b2f0d879c1aa02af7d785aa003cd706ea4b07e315c66bf169f2ccefb0e` | 876351 |
| `stages/candidate/motion/south/30m-2.png` | `33a3af56188a5def59c6a5f98e4cda747b41cc186aba3e0372cc24ebbd57095b` | 878094 |
| `stages/candidate/motion/south/45m-0.png` | `9b1807c4b94f6cb6be6583e5d419847a2130109bd3a45922e21e2b04bcf14528` | 923779 |
| `stages/candidate/motion/south/45m-1.png` | `b867a29126c582621649449c627bcce9419cbd5bdbbcb6ec2a04de0a358705f3` | 924159 |
| `stages/candidate/motion/south/45m-2.png` | `28351fc77c65247eb5b7217c85538dfe6c8b9ea009aeecd67376c96ce1e63fa3` | 923681 |
| `stages/candidate/motion/south/60m-0.png` | `cac869ba0fbb808c478ba01d1451579ca03e41fcaa2836eee72256f6c59024d7` | 741405 |
| `stages/candidate/motion/south/60m-1.png` | `46b3fc3e1124125ad440d31740317bb39f19e81561de5c0f900c5216041d7baf` | 741086 |
| `stages/candidate/motion/south/60m-2.png` | `ba220ee3856bf5f5bce5ad499219702ab475c93db37e369b7936d8dd84ada9b1` | 740716 |

Rejected-v1 comparison originals, relative to
`/private/tmp/b1-reveal-rehearsal-004/stages/candidate`:

| Reviewed original | SHA-256 | Bytes |
| --- | --- | ---: |
| `images/03-north-wing-near-default.png` | `f43de7e5f982e96c4cd6af48bd5a209ae45f57094ac54ab31cbb1f17a9bd2e7c` | 717515 |
| `images/05-south-wing-near-changed.png` | `237d1beb86417033e5dfb4f0531fde61a24eb666d6923145760eff32b71a5e9f` | 586270 |
| `motion/north/25m-1.png` | `a3d34a2cc3ddb1a18887c2bea2eb78bae4492ffc90fad1902f88be374176ea37` | 853080 |
| `motion/south/25m-1.png` | `e14c449e0ec085c65ca6e50f24387044827fb7032602c8df87a2edc7ef6d2f08` | 930685 |

PASS_FOR_B1_RETURNS_V2_REHEARSAL_VISUAL_ONLY
