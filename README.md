# Treasure Island First Playable

This private hobby game is now an implemented Godot 4.7.2/GDScript first-playable candidate for Apple-silicon macOS. It builds the complete approved Treasure Island exterior from the frozen OpenStreetMap snapshot, adds sparse deterministic premade vegetation, and supports third-person walking, fast running, endless jetpack lift, recovery, and one predefined spray tag on eligible exterior building walls. Walking remains `4 m/s`; held-Shift running now reaches `20 m/s` (about 45 mph) through the existing character controller. Cars, interiors, missions, NPCs, multiplayer, and public distribution are not part of this milestone.

## Resume on a new machine

This repository root is the Godot project root. Accepted work is on `main`; paused, unreviewed `r133351` work is preserved separately on `codex/r133351-paused-wip` and is not part of accepted `main`.

```sh
git clone https://github.com/pcomans/treasure-island.git
cd treasure-island
git switch main
git status --short --branch
```

Before restoring tools or opening Godot, read [AGENTS.md](AGENTS.md) and the [machine-migration handoff](discovery/MACHINE_MIGRATION_HANDOFF_2026-08-30.md). The handoff records the exact accepted Building 1 state, vetted toolchain restoration, focused smoke commands, evidence caveats, and paused-branch resume gates. The canonical facade skill is project-local at [.agents/skills/building-texture/SKILL.md](.agents/skills/building-texture/SKILL.md).

Human-only follow-ups are kept in the [owner action queue](HUMAN.md); that
queue narrows external gates and never pauses safe independent work.

## Current Fire Station48 release — fifteen recognized buildings

Fire Station48 (`physical-building:w764313741`) adds one accepted physical unit: **15/213**, with **198 not evaluated**. All prior 14 acceptance records and 213 identities remain. Compiler `1.14.0`, catalog/registry v15 and contracts/loader v14 bind 14 active adapters, 23 plans and 17 package-ready plans. Owner package execution and independent review passed on the exact app `build/fire-station48-exact-current-001/Treasure Island First Playable.app`, with actual signed world `735/1023/1038/82,789/466/477`, all six attachments, stock movement/jetpack and separate mounted/privacy checks. PCK `8a5a42c73cc14008a30c9a86ef8187743e1328124d631bae2033a7c41683e012`; seven-file bundle `e8f6280660d251937a77bea97f2a4d8ec50e2f90245fbe24cec230fbdfdda13d`; executable `8136f070a79cb33eef25b496cdb042da9e6727e4ddb117ccdda4468332ed9cd1`. [Release closure](evidence/first-playable/fire-station48-current-release-2026-09-11-001/release-closure.json).

Historical capture/candidate 14, 17 original images and sparse-motion/contact/setup limits remain unchanged. Native macOS smoke supplies no new OS pixels, manual-input/M1 acceptance or universal runtime claim. MAIN transfer, commit/push and ordinary no-argument launch remain pending in this preparation snapshot; HUMAN-001 remains owner-only.

## Historical 1317 Gateview release — fourteen recognized buildings

The separate unit/reference/visual/mechanics and package gates accepted `physical-building:w95934125` as a new unit. Recognition is **14/213**, with **199 not evaluated**, one new credit, all prior 13 acceptance records and 213 identities preserved. Latest 1308/1394 quality improvements remain intact. Compiler `1.13.0`, catalog/registry v14 and contracts/loader v13 bind 13 active adapters, 22 plans and 16 package-ready plans.

Owner and independent exact-current signed runs measured `735/1018/1033/81,761/466/477` rows/meshes/surfaces/triangles/bodies/shapes. The 1317 acceptance record binds the current combined topology; original 1308/1394 quality-batch measurements retain their earlier scope. The reviewed app is `build/d5-1317-exact-current-001/Treasure Island First Playable.app`. Seven-file identity `c62ae8d2878135ace2206755bbb7ee91fee47f68ec8cac4b334be233b710de26`, PCK `9ab4e78f98b10cbc381d4cbd6a4f5e4367ec06766f6b5415cb070174c7ad9adf`, executable `bd004c7d772a1f06be6363c53a2d88be4ca335edd54ba6eea4172cb2122aed7b`. [1317 release closure](evidence/first-playable/d5-1317-current-release-2026-09-10-001/release-closure.json).

The immutable 1317 packet retains 8 PNGs and 9 AVI payload samples, its 17-image tree, capture/candidate 13 app, original failed receipts and sparse-motion/contact limits. The new current 14 app supplies full-world, stock movement/jetpack, mounted component and privacy proof on Apple M2; it supplies no new gameplay pixels or manual/M1 owner acceptance. MAIN transfer, publication and ordinary no-argument launch remain separate pending outcomes in this preparation snapshot. `HUMAN-001` retains its owner-only scope.

## Historical 1308 and 1394 quality revisions — thirteen recognized buildings

The following paragraphs retain the accepted prior 13 quality release and its actual publication outcome; their uses of “current” refer to that earlier app.

Independent source/mechanics, visual, separate unit-packet and package gates accepted the fidelity004 quality revisions of `physical-building:w95934123` and `physical-building:w96215646`. Recognition remains **13/213**, with **zero new credit**, all 213 unit identities preserved and 200 not evaluated. Compiler `1.12.0`, catalog/registry v13 and contracts/loader v12 retain twelve active adapters, twenty-one plans and fifteen package-ready plans.

The owner and independent signed runs measured `735/1006/1021/79,913/466/474` rows/meshes/surfaces/triangles/bodies/shapes. 1394 owns current combined topology; 1308 carries the same-batch combined reference. The reviewed private app is `build/d5-1308-1394-quality-exact-current-001/Treasure Island First Playable.app`. Seven-file identity `d6239ccdb089b01b6ce6839bf393de3ecf8c63f40167a26b79b68c6f73f91e27`, PCK `06f7e4778f791adbf512a16cd6e6900f288ea7d8c41ad53edafc85ad2a8c2be7`, executable `996db8709cbad9bbbe085d54fa828574c03332e94e2cdeecd433482098d1be80`. [Quality release closure](evidence/first-playable/d5-1308-1394-quality-current-release-2026-09-10-001/release-closure.json).

The two immutable unit packets preserve 17 and 14 source images and their original camera/reference/contact and sampled-motion limits. 1308 uses its actual004 roof mechanics; 1394 has three current palette004 stills and unchanged003 motion. The separately tested final app supplies full-world, movement/jetpack, mounted component and privacy proof on Apple M2. Current exported-app pixels, ordinary owner input and Apple M1 Pro acceptance remain unclaimed. Primary commit `cb28dc4d4e873bb7f000c6976a87bb3c2e4ffc5d` was pushed to private `origin/main` with remote equality verified. [Publication outcome](evidence/first-playable/d5-1308-1394-quality-current-release-2026-09-10-001-PUBLICATION.json). An ordinary no-argument launch for these bytes remains pending; older launch outcomes below do not establish it. `HUMAN-001` retains its owner-only scope.

## Historical 1308 and 1394 initial recognition release — thirteen buildings

This section preserves the earlier 76,376-triangle app, its original two-credit acceptance and publication/launch outcomes. Its uses of “current” are historical.

Independent per-unit quality/packet gates and the shared candidate package accepted `physical-building:w95934123` and `physical-building:w96215646`. Serialized authority is **13/213**, preserving the prior eleven units and all 213 identities; **200** remain not evaluated. Compiler `1.12.0`, catalog/registry v13 and contracts/loader v12 agree on twelve active adapters, twenty-one plans and fifteen package-ready plans. Roofs add no credit.

Current topology is `735/993/1008/76,376/466/472` rows/meshes/surfaces/triangles/bodies/shapes. 1394 alone owns current combined topology; 1308’s intermediate combined scope and prior D2/B1 counts stay historical. The current private app is `build/d5-1308-1394-exact-current-001/Treasure Island First Playable.app`. Seven-file identity `2d61652aedcc14f4ddd4fdda0a458037758b5ae103cecf59aaa8b7a998159e6c`, PCK `e3c5c529efc54be1af383cafba678a0130fbd2157524e4d8cf1e3217217de85f`, executable `2dd0e797cf26365109293196c4a9f7e217b80c872832042bfdb63db3e4d7aad5`.

Owner and independent exact-current package checks passed; main source and app are byte-identical copies. [Current release closure](evidence/first-playable/d5-1308-1394-current-release-2026-09-10-001/release-closure.json). Publication readiness passed. Primary commit `001ab0acdd3f8e049060b409b3857f36d7b889f3` was pushed to private `origin/main` with remote equality verified. The exact no-argument app produced an owned onscreen native window and was then intentionally stopped; app/source bytes remained exact. Computer Use RPC failed and the direct observation was cancelled without a result, so pixels and current permission status are unavailable. No manual-input or M1 acceptance is claimed. [Observed publication and launch outcome](evidence/first-playable/d5-1308-1394-current-release-2026-09-10-001-PUBLICATION.json). The immutable upstream closure retains its earlier pending state.

Both immutable packets retain capture/candidate **11/213**, 36 selected native images and sampled-motion review. The 1308 trim correction,06 orientation tolerance and original contact/pose/helper failures remain explicit; no continuous-playback/as-built claim is made. `HUMAN-001` stays pending only for owner recognition and mouse/keyboard acceptance on Apple M1 Pro.

## Historical 1444 Croaker Court — eleventh recognized building

This section preserves its 11/213 release, app and outcomes; “current” refers to that historical release.

Independent source, live mechanics, visual/reference, candidate-package, packet and authority reviews accepted `physical-building:w95934117`. Recognition is **11/213**, adding one physical unit while preserving the previous ten acceptances and all 213 units; **202** remain not evaluated. Compiler `1.10.0`, catalog/registry v11 and contracts/loader v10 agree on ten active adapters, nineteen plans and thirteen package-ready plans. The paired roof adds no credit.

Current loaded topology is `735/977/992/71,828/466/468` rows/meshes/surfaces/triangles/bodies/shapes. 1444 alone carries current topology; prior B1, 1441 and 1439 measurements remain historical. The current private app is `build/d2-1444-quality-v2-current-2026-09-09-001/Treasure Island First Playable.app`. Its seven-file identity is `07fe27f678be4c7d71de77b42a79c6b8c46491034eb6c80a2b3e00eed097b4e6`, PCK `c010390dcfe213134445a352facd0720283818edd279e72851f17af83bcc426c`, and executable `a5a85e48fbd890e661d04a1e191bfe1280141c01c0212cc6fb4fd10591a90c4f`.

Owner and independent current-package checks passed. The exact no-argument app created an owned visible native window, then was intentionally stopped; all app/source bytes remained exact. Computer Use reported an unconfigured node bridge and pending Accessibility/Screen Recording permissions, so no gameplay pixels or manual-input acceptance is claimed. [Ordinary launch evidence](evidence/first-playable/d2-1444-quality-v2-current-release-2026-09-09-001/ordinary-launch.json). Publication readiness passed, and primary commit [b854625](evidence/first-playable/d2-1444-quality-v2-current-release-2026-09-09-001-PUBLICATION.json) was pushed to private `origin/main`; remote equality was verified. The immutable release closure above retains its earlier pending state; this downstream record supplies the observed outcome.
The [current release closure](evidence/first-playable/d2-1444-quality-v2-current-release-2026-09-09-001/release-closure.json) binds actual app/source identities and retained original records. The [immutable unit packet](evidence/first-playable/d2-1444-quality-v2-promotion-candidate-2026-09-09-001/candidate-closure.json) and later independent attestation retain captured **9/213**, candidate-package **10/213**, 33 native originals and sampled temporal review. Its original mechanical and mounted failures remain visible with accepted scoped reconciliations. No as-built claim, continuous-playback claim or current package-pixel equivalence is made.

`HUMAN-001` stays pending only for ordinary owner recognition and mouse/keyboard acceptance on the approved Apple M1 Pro. Technical Apple M2 checks do not replace that feedback or block autonomous work.

## Historical 1439 Chinook Court — tenth recognized building

This section preserves the preceding 10/213 release and its own app/outcomes. Its uses of “current” are historical.

Independent source, live mechanics, visual/reference-recognition, candidate-package,
packet and authority reviews accepted `physical-building:w95934144`. Recognition
is **10/213**, with one new physical unit and **203** still not evaluated. Compiler
`1.9.0`, catalog/registry v10 and contracts/loader v9 agree on nine active adapters,
eighteen plans and twelve package-safe plans. The paired roof adds no extra credit.
Current loaded topology is `735/968/983/71,156/466/467`
rows/meshes/surfaces/triangles/bodies/shapes. Earlier B1/1441 topology and all nine
previous acceptance records remain historical and unchanged.

The current private app is `build/d2-1439-quality-v2-current-release-2026-09-09-001/Treasure Island First Playable.app`.
Its seven-file identity is `64d53753266959fe49119f8363e786c4a53f999232b0299329037094d2f8a986`,
PCK `d4dd89349359ed40e9d1338f2d567a4dfecac899dcc1509aa701989c142befac`, and executable
`569e9350ba9d3fb629dde0efdf047a0faf1d1a7ab640c96b46ded5a867204689`.
Owner, independent current-package and publication-readiness checks passed. The primary release commit `2c51de357e54283ad2aeaea9829b9a1eb4cac09d` is published on private `origin/main`. The exact no-argument app opened a visible native window, then was stopped to release the engine slot. Native screenshot attempts failed; no current gameplay pixels or manual-input acceptance is claimed. See the [observed publication and launch outcome](evidence/first-playable/d2-1439-quality-v2-current-release-2026-09-09-001-PUBLICATION.json).
The [current release closure](evidence/first-playable/d2-1439-quality-v2-current-release-2026-09-09-001/release-closure.json) binds the actual app, source pins and technical receipts.

The [unchanged native evidence](evidence/first-playable/d2-1439-quality-v2-promotion-candidate-2026-09-09-001/candidate-closure.json) contains seven live stills,
seven motion PNGs and seventeen reviewed original AVI frame payloads. It remains
a source capture at **9/213**, with sampled temporal review and no continuous
playback claim. Rendering source stayed unchanged through the reviewed smoke-only
main correction and authority promotion; these images are not current exported-app
pixels. The accepted facade has inward balcony and passage depth, a quiet upper
window field, and a blank opposite end. No as-built fidelity is claimed.

`HUMAN-001` remains pending for ordinary owner recognition and mouse/keyboard
acceptance on the approved Apple M1 Pro. Technical checks on the Apple M2 verifier
do not replace that owner play and do not block continued autonomous work.

## Historical Building 1 wing returns v2 release — 2026-09-08

This section records the preceding 9/213 release and its own exact app, evidence,
publication and launch outcomes. Its uses of “current” are historical.

The accepted Building 1 upgrade adds attached pale jamb and sill depth to the
30 supported wing openings. Independent source, mechanical, and visual quality
reviews accepted this local improvement; the whole-front change is modest.
Recognition remains `9/213`, with `+0` credit and `204` physical buildings still
not evaluated. Compiler `1.8.1` retains catalog/runtime v9 and adapter/loader v8.
Current loaded topology is `735/959/974/70,692/466/466`
rows/meshes/surfaces/triangles/bodies/shapes. The additional `1,440` triangles
are render-only; collision, navigation, spray ownership, and D2 component and
capture-time identities are unchanged. B1 `behavior_contract` remains null.

The accepted [100-file quality packet](evidence/first-playable/building-1-wing-returns-v2-accepted-2026-09-08-001/acceptance-receipt.json) binds the original
source-render A/B evidence and separate candidate-package proof. Source
renders are not screenshots of the exported app. The quality receipt SHA-256
is `257f16bc314151054b120c2b87e6f8cb20577f5e4a7201478b58272a65dc23a4`.

A fresh exact-current private app is retained at
`build/building-1-wing-returns-v2-current-2026-09-08-001/Treasure Island First Playable.app`.
Its seven-file bundle identity is `fd91b1c5598dc2fe436a756eb5fb7561c96989fe18734c59580de92b13fa4171`,
executable SHA-256 `ac0aa612c576e039b04b743c2da5783fd0736a7312be4c88e31210b672845031`
(`170,963,648` bytes), and PCK SHA-256 `454b913537742c8b605f41db8730c860de3ab37d08c4a3bfab5e15dc40f69403`
(`66,600,060` bytes). Strict signing, universal inventory, privacy, mounted
current B1/D2 graph checks, and complete headless and native internal smoke
passed, including grounded player, jetpack rise, and capped descent. The
[independent package audit](evidence/reviews/building-1-wing-returns-v2-current-package-2026-09-08-INDEPENDENT_MECHANICAL_AUDIT.md)
SHA-256 is `c6f4c47a998619143f5f8b56b91c4441d9cda5500ee643911dbdeba8be575ee7` and returns
`PASS_FOR_B1_RETURNS_V2_CURRENT_PACKAGE_MECHANICS_ONLY`. Native execution was
on the Apple M2 verifier host; owner acceptance on the Apple M1 Pro is pending.

The [durable current release packet](evidence/first-playable/building-1-wing-returns-v2-current-release-2026-09-08-001/release-closure.json) preserves all 50 raw capture
files (46 PNGs, three manifests, and the owner receipt) plus unchanged programs.
Its owner receipt is `b75d7943dee504ddc984d5a6c8fd954d11442e7b60f21637183dc9b2d77f42c3`;
the canonical 49-input tree is
`341b6545fc22b103813fcd5a65f5487388bdce521ab43b89d0c42b214b7a0272`.
All 46 fresh PNGs match their accepted v2 counterparts byte-for-byte, with
zero motion pose delta. The [independent evidence mechanics audit](evidence/reviews/building-1-wing-returns-v2-current-release-2026-09-08-INDEPENDENT_EVIDENCE_MECHANICAL_AUDIT.md)
(`98ab5b0d5990bc9665a3ac335863d95ee34440b4cfd168558e573ec84d3243ae`)
and [independent visual audit](evidence/reviews/building-1-wing-returns-v2-current-release-2026-09-08-INDEPENDENT_VISUAL_AUDIT.md)
(`8f9123170532ca60f0ecd693e6675fdf0bc15008af68f3b2982bfff100767fed`)
pass their separate scoped gates. The visual audit reuses the complete prior
review after exact image identity checks and freshly reopens four still pairs;
it does not claim a new motion inspection or continuous interactive play.

The downstream closure SHA-256 is
`1459483fb45acb336f902d7bdbeae25b1d61a7ecd3a66564ffbf99c2c3b22d8a`.
Its sanitized provenance summaries are explicitly derived; original binding,
commands, logs, and failure records remain byte-identical in private storage.
Raw capture-time pending/status fields are preserved as history, and the
downstream audits establish the later scoped result.

Primary release commit `c82a1b6e7208d2b9c7a6d34c23d98545be6238ae` was committed and
pushed normally to `origin/main`. The exact reviewed app was then launched
with no arguments; its owned PID `24426` had a visible `1280 × 832` window
and an empty startup log at observation. All seven app files remained exact.
The [publication and ordinary-launch receipt](evidence/first-playable/building-1-wing-returns-v2-current-release-2026-09-08-001-PUBLICATION.json)
(SHA-256 `08132b658720dabe57dbb6849f5b1c27274c3785dc1aa977512555c6913202bb`) records these actual outcomes
separately from the immutable closure snapshot above. This observation does
not establish native gameplay pixels or manual input.
`HUMAN-001` remains pending for owner recognition and mouse/keyboard
acceptance on the Apple M1 Pro; it does not block autonomous work. No export,
source screenshot, technical review, or smoke result substitutes for owner play.

## Historical D2 1441 v9 release closure — 2026-09-07

This section preserves the accepted D2 release and its capture-time identities.
Its then-current counts, app, and pending Building 1 status are historical.


The deterministic recognition authority is compiler `1.8.0`, catalog/runtime
registry v9, adapter contracts/loader API v8, and exact recognition `9/213`.
It contains eight active adapters, seventeen total plans, eleven package-safe
plans, and six disabled plans. Exactly one new accepted physical-unit record
and one wall-indexed active plan cover 1441 Chinook Court source `w95934105`;
the paired roof and decorative relief remain part of that one behavior without
creating extra receivers or recognition credit. Current loaded topology is
`735/959/974/69,252/466/466`
rows/meshes/surfaces/triangles/bodies/shapes. B225 retains its accepted
`735/952/967/67,716/466/466` snapshot under
`pre_d2_1441_integration_live_parity`; 1441 alone owns
`current_integration_topology`. Exactly `204` physical buildings remain not
evaluated, and the requested further Building 1 quality pass remains pending.

This promotion is bound to the immutable 40-file
[`-009` prepromotion packet](evidence/first-playable/d2-1441-production-v8-staging-2026-09-05-009/capture-manifest.json)
with tree SHA-256
`e52d66e479f268a9e75372da111d9c93cc1972dd1fddca9a6cb29bb6e41a4a43`,
package receipt
`cbcda89ec1e013c3406cf919d7c7e3bcefe0df7f005be1ea0e250bfbdada1061`,
and separate mechanical and visual review receipts. The frozen v8 app used by
that packet has bundle identity
`81ae851ff3dffd90202e903939f1d6cda7eeb3cfff7e2c752492fa7ed0e1e129`;
its PCK is
`c7660d21680649d137af52e2057a23aaa7efab9292c4e427c3e2ef79d1ea80c3`
and its executable is
`e40c888a66f044c5a267ef027d94e99fd8009104462a7ca193b249b6fb6d7cfd`.
It remains capture-time evidence rather than the current handoff. The
postpromotion authority was separately audited by
[`PASS_FOR_V9_POSTPROMOTION_EXPORT`](evidence/reviews/d2-1441-promotion-v9-2026-09-07-INDEPENDENT_SEMANTIC_AUDIT.md)
at SHA-256
`3388576780493b6116c126684072426ad22279b9a3508127a0ffc8bcb77f9700`.

The current locally retained private handoff is
`build/d2-1441-postpromotion-v9-2026-09-07-001/Treasure Island First Playable.app`.
Its canonical seven-file bundle identity is
`f83ddd5678086099d66fc433c0851fc2788c42e702d8bffac4eee4d7a7d595cb`;
its executable is
`cf0bd6e789e9317248b1aeb2eb626cfd76b837fef362eca449336644cff77941`
(`170,963,648` bytes), and its PCK is
`0945ac7b08ebd2fc5389ffa05a919b7324ecb298dac46032c8fdc30d8c47404a`
(`66,300,344` bytes). The exact
[`40-file postpromotion packet`](evidence/first-playable/d2-1441-postpromotion-v9-2026-09-07-001/capture-manifest.json)
has canonical tree SHA-256
`60f9c875d3429347047525beab75310073e971af78e6445b551b6586a79cb45e`,
static manifest
`50ab60b3f509ac30b26dbb98ea03bf8f8cc4b1b4c4054f87204e8af6f16797d1`,
motion telemetry
`dbbe6f53bd6f176cf4760faa6684d306265327635fe6b53d8917bfa78ac2f171`,
visual-motion manifest
`5392cb8e2942fdeda033482c2658fd5a842c6d28abedf1ddfe7c7488664790ea`,
and package receipt
`61b63b0ad7aac01039e4f1e2125268c5e1900e047b3077e785c00893a85a6a59`.
Its independent
[`mechanical audit`](evidence/reviews/d2-1441-postpromotion-v9-2026-09-07-001-INDEPENDENT_CONTRACT_AUDIT.md)
and
[`full-resolution visual review`](evidence/reviews/d2-1441-postpromotion-v9-2026-09-07-001-INDEPENDENT_VISUAL_REVIEW.md)
have SHA-256 values
`08d08ddc4a7e9cb773e5cacf8c175040f8dd7583d16268533b62899c56175055`
and `67e459baa98b34ef246136b898ac3ab2a4dba91c65979b7b3007747d8fa3aade`;
both return `PASS_FOR_D2_1441_V9_RELEASE` and grant no additional credit.

The release proves the corrected visible roof winding and positive-Y collision,
real predefined spray on the exact wall owner, real input-only player landing
on the paired roof, and a six-second fixed-60-FPS disclosure with deferred
image encoding/I/O. All 21 motion images are pixel-identical to the accepted
prepromotion `-009` route, while the fresh stills preserve the same recognition
cues. Full runtime, traversal, Building 1, B225, mounted-package, privacy,
Universal-signing, headless, and native Metal gates pass. Ordinary recognition
and mouse/keyboard acceptance on the approved Apple M1 Pro remain the sole
owner action; technical work continues independently.

The immutable unsuffixed packet and its `-004` app remain formal rejected
history under `HOLD_NO_PROMOTION_NO_CREDIT` because the old receipt contained
an inconsistent geometry signature. The partial unreviewed `-008` rehearsal
was removed from release scope and moved recoverably to local Trash; it is not
authority or evidence.

## Historical local B225 v8 release closure — 2026-09-05

The historical locally retained private handoff is
`build/d1-b225-postpromotion-v8-2026-09-05-001/Treasure Island First Playable.app`.
The B225 v8 source and evidence integration is accepted on `main` at commit
`7448f081d510e56c598f41b68612ffd86e4afa5f`. The exact app remains ignored and
locally available on the verifier; cloning `main` transfers the integrated
source and evidence but not this app, which must be transferred separately or
re-exported on another machine.
Its canonical seven-file bundle identity is
`3f38c5dcd55b19f12cf7788e1069367075aa22f1b557c5b61288abdfdc30afe0`;
its executable is
`c485010419591a9556e849e79755d7e816f840e31978c10b371be08a730e2d82`
(`170,963,648` bytes), and its PCK is
`7315bba99efeeeb86be0bbf44876d391b9c1c95f1638318e0df2b7af367669bf`
(`66,073,188` bytes).

At this historical closure, authority was compiler `1.7.0`, catalog/runtime
registry v8, adapter contracts/loader v7, and exact recognition `8/213`. Its loaded topology was
`735/952/967/67,716/466/466` rows/meshes/surfaces/triangles/bodies/shapes.
The [37-file postpromotion packet](evidence/first-playable/d1-b225-postpromotion-v8-2026-09-05/capture-manifest.json)
has canonical tree SHA-256
`7b0de99e6f4afe07b1767c522517ace3dc1729a3f82f4b9b95716de9483cbd84`.
Its independent [mechanical audit](evidence/reviews/d1-b225-postpromotion-v8-2026-09-05-INDEPENDENT_CONTRACT_AUDIT.md)
(`9c909d047786d4f7feab138b4d7c597bba1bac2adcf78cc8bcdfb568de0a0ec2`)
and [full-resolution visual review](evidence/reviews/d1-b225-postpromotion-v8-2026-09-05-INDEPENDENT_VISUAL_REVIEW.md)
(`881b04d696bfe842c39a220be5f4da3087f30d8ef8e9c0493c9c62067a826c99`)
both return `PASS_FOR_RELEASE_NO_ADDITIONAL_CREDIT`. After integration, these
exact local app bytes were also visibly launched with no app arguments through
the normal macOS application path on an Apple M2 verifier; the expected
executable remained alive in an onscreen Metal window with no crash or GPU-fault
record during the bounded observation. Ordinary recognition and mouse/keyboard
play on the approved Apple M1 Pro owner target remain pending and are not
implied by the audits or verifier launch. Candidate `024605` and its B201/v7
measurements below are retained as historical package context, not as the
current handoff.

The generated-data and exact-current source-runtime gates pass with USGS 3DEP
bare-earth terrain on both islands, coherent terrain-following roads/areas,
terrain-reaching building foundations, exactly grounded visual-only
vegetation, a grounded first visible player frame, jetpack, eligible-wall tag,
imported western bridge, and continuous route coverage. The current source uses
the owner-photo-derived single-color San Francisco silhouette
`sf_skyline_owner_silhouette_final.png` (`2212x340`, SHA-256
`9c499ca3db08769142aac69b61e7d8fdf2aa84cd084b6716a19e7c504ba0b0c5`)
on a `3900x600 m` billboard at `(-1875,264.85,4306.4)`, 250 m beyond
the western bridge's San Francisco endpoint. The frozen generated artifacts
remain `729 meshes / 739 surfaces / 48,389 triangles`. At load, four Building 1
and tower placeholder records are intercepted before generic visual/collision
construction, leaving a `725 / 735 / 48,059` placeholder-free record baseline.
Building 3's accepted congruent arched wall/roof replacement raises the active
record-owned triangle total to `48,825` without changing mesh, surface, or body
counts. Navy Chapel's accepted paired wall/roof replacement then supersedes its
two generic record meshes, leaving the pre-B201 active record-root topology at
`723 / 732 / 48,739`; its descendant hero geometry owns `6 / 6 / 540` with the
same two structural owners. The accepted four-component Building 1/tower hero owns
`13 / 13 / 10,711`; the accepted Isle House Variant C overlay owns
`7 / 11 / 2,242` without decorative collision. B201 preserves its 80 host
triangles while splitting its host into one additional surface and adds
`6 / 6 / 2,064` render-only attachment geometry, leaving its stage's
record-root topology at `723 / 733 / 48,739`. With the unchanged other runtime
attachments and context, all `735` playable rows load as
`950 meshes / 964 surfaces / 66,636 triangles`, with `466` body/shape pairs at
the B201 stage. B225 then splits its physical host into one additional
record-root surface and adds `2 / 2 / 1,080` render-only
meshes/surfaces/triangles. B225-stage record-root topology is therefore
`723 / 734 / 48,739`, while total loaded topology changes by
`2 / 3 / 1,080` to `952 / 967 / 67,716`; collider counts remain `466 / 466`.
The accepted 1441 pair then consumes its two generic record meshes/surfaces
and 42 triangles, leaving exact-current active record-root topology
`721 / 732 / 48,697`; its reviewed `9 / 9 / 1,578` replacement produces the
net `+7 / +7 / +1,536` total recorded above without changing collider counts.
The Isle House and Navy Chapel derived contracts preserve their shared
pre-B201 `735/944/957/64,572/466/466` live-parity snapshot under exact scope
`pre_b201_integration_live_parity`; B201 retains
`pre_b225_integration_live_parity`; in v9, B225 carries
`pre_d2_1441_integration_live_parity` and 1441 alone carries exact-current
`current_integration_topology`. The B225-stage replacements are present in the
historical B225 v8 app above.
Movement remains `4/20 m/s` with `30/40 m/s²` acceleration/braking.

The previous B201 private handoff was
`build/b201-promotion-staging-2026-09-05-024605/Treasure Island First Playable.app`;
the following B201 verification summary is retained as historical package
context.
Two complete B201-stage source matrices (35 valid fast/core gates plus four slow
end-to-end gates per round), two 28-contract evidence sweeps, three
outside-project mounted-PCK audits,
strict signing/architecture/privacy checks, packaged headless smoke, and the
first bounded Apple M2 Metal smoke all passed. The smoke watchdog measured
60 seconds of monotonic wall time, so accelerated headless scheduling cannot
consume it early. A no-argument ordinary launch also started the exact B201
app on the verifier host. The packaged-test predecessors `014223` and `002922`
are withdrawn and retained only as non-authoritative diagnostics. B201 has a separate independently accepted five-view
and continuous-motion evidence set; the `104510`, `111725`, `190724`, `231815`,
`224622`, and August 13-frame records are historical. Ordinary owner
recognition and mouse/keyboard play on the approved Apple M1 Pro remain pending.

## Play from the project

Run these commands from the project root. The executable below is the exact trusted, self-contained project-local Godot install recorded in [INSTALL_LOG.md](INSTALL_LOG.md):

```sh
GODOT=".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
"$GODOT" --version
"$GODOT" --path .
```

The expected version is `4.7.2.stable.official.ed1daf0bf`. The game validates and builds all 38 chunks before enabling the player; wait for the loading panel to disappear and the center reticle to appear.

## Controls

| Input | Action |
|---|---|
| `W`, `A`, `S`, `D` | Walk relative to the camera |
| Hold `Shift` | Fast run at up to `20 m/s` (about 45 mph) |
| Hold `Space` | Rise with the jetpack; release to float down slowly |
| Mouse | Orbit the third-person camera |
| Primary mouse click | Spray the center-reticle target; only an opaque exterior building wall within 6 m is eligible |
| `R` | Recover to the latest safe position |
| `Esc` | Pause or resume and release/capture the mouse |
| `F3` | Toggle runtime evidence/debug text |
| `Q` while paused | Quit |

The pause panel also provides Resume and Exit buttons. Tags are session-only; at 64 active tags, the oldest is removed.

Horizontal movement keeps the simple constant tuning: `4 m/s` walk, `20 m/s` held-Shift run, `30 m/s²` acceleration, and `40 m/s²` braking. From rest the fast run reaches its cap in about `0.67 s`; releasing movement stops it from the cap in about `0.5 s`. Releasing Shift while continuing to move eases back toward walking speed. Jetpack tuning and all bindings are unchanged.

The ground now uses a deterministic 32 m USGS 3DEP bare-earth mesh clipped to the frozen OSM shorelines. Its serialized collision triangles are the single height authority for roads and public-space overlays. Buildings retain flat base/roof references and source heights while their exterior wall foundations split at terrain-triangle crossings and extend into the exact land surface. Treasure Island is playable/colliding while YBI remains non-playable and non-colliding. OSM is still authoritative for all horizontal geometry and the complete `739`-row inventory. Exact raster provenance, integrity pins, and sparse-tile handling are in [data/terrain/README.md](data/terrain/README.md).

The visual-only pavement skin keeps one filled union for all `427` OSM road/path sources, then overlays the `219` footway/path-like sources after subtracting the `208` vehicle-road sources at crossings. Seventeen `amenity=parking` polygons use a separate paved-area material key. The live eleven-key semantic material set is backed by six restrained Poly Haven CC0 families and 18 packaged 1K albedo, normal, and roughness maps: asphalt for vehicle roads, concrete for pedestrian and paved areas, sparse grass for land, plaster for walls, and bitumen for roofs. Collision, terrain, foundations, and source footprints are unchanged by this visual pass.

`generated/world/vegetation.json` deterministically places `124` premade Kenney Nature Kit instances with seed `1414092337`: `13` palms, `21` ornamental grasses, `41` shrubs, `28` broadleaf trees, and `21` conifers. The procedural 102-placement pass is unchanged; all `22` accepted NAIP `unknown` crown centers now add fixed-location shrubs whose approved asset, yaw, and scale derive only from the seed plus annotation ID. Every origin names its exact serialized land triangle/elevation. The annotation row retains shoreline, overlay, ferry, and QA-route buffers and has zero actual road/building overlap; its fixed source points use a documented 1 mm surface-exterior test instead of the procedural 4–5 m aesthetic buffer. YBI receives zero vegetation. Runtime rendering uses `19` shared-asset MultiMesh batches and adds no collision.

## Verified whole-island handoff

- Generated content SHA-256: `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`.
- Manifest file SHA-256: `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`.
- Vegetation file SHA-256: `e843ac78c4f5ba769241f330f83b41fd8431fbe06073c9ffd4907c413baad32f`.
- Initial spawn: the frozen OSM ferry arrival at foot-level local world `[-104.364, 3.457, 786.024]`, yaw `-0.119` radians toward the island interior. The hidden startup settles on collision before the player is revealed.
- `739` unique source rows: `735` playable and `4` non-playable context, with zero unresolved or duplicate rows.
- Overlapping playable memberships: `1` land boundary, `22` terrain/shoreline, `427` roads/paths, `80` major areas, `213` buildings, and `2` building parts.
- `38` generated chunks and `729` physical records for all `735` playable rows.
  Their frozen serialized
  topology remains `729 meshes / 739 surfaces / 48,389 triangles`. The B201-stage
  runtime used `723 / 733 / 48,739` record-root topology after intercepting the four
  Building 1/tower records, replacing the Building 3 and Navy Chapel wall/roof pairs,
  and partitioning the retained B201 host into two surfaces; the
  B201-stage Building 1/tower replacement owns `13 / 13 / 10,711` and four
  congruent body/shape pairs, while the accepted Isle House Variant C overlay
  owns `7 / 11 / 2,242` and no decorative collision. The accepted Navy Chapel
  hero owns `6 / 6 / 540` and replaces, rather than duplicates, two structural
  owners. The accepted B201 attachment owns `6 / 6 / 2,064` render-only
  geometry while its retained host remains the sole collider and spray owner.
  B225 retains those structural owners, splits its physical host into one
  additional record-root surface, and adds only its reviewed render attachment.
  At the accepted B225 stage the loaded source project instantiated `952`
  meshes, `967` surfaces, and `67,716` triangles. The accepted 1441 atomic
  pair replaces generic `2 / 2 / 42` wall/roof geometry with reviewed
  `9 / 9 / 1,578` geometry. The accepted B1 v2 returns add `1,440`
  render-only triangles, bringing the B1/tower replacement to `13 / 13 / 12,151`.
  That preceding B1 release instantiated `959` meshes, `974` surfaces,
  `70,692` triangles, and `466` body/shape pairs. The accepted 1439 pair replaces
  generic `2 / 2 / 58` wall/roof geometry with `11 / 11 / 522`, adding one
  noneligible closed-recess collision shape. That historical 1439 package
  instantiated `968` meshes, `983` surfaces, `71,156` triangles, `466` bodies
  and `467` shapes. The accepted 1444 pair adds nine meshes/surfaces, 672
  triangles and one closure shape: the current package has `977` meshes,
  `992` surfaces, `71,828` triangles, `466` bodies and `468` shapes. The additional `28`
  records are visual-only pedestrian pavement skins. Other facade attachments
  and pavement skins do not change physical collision. YBI, both bridges, and
  the SF billboard remain context-only and non-colliding.
- Vegetation stays outside the fixed OSM denominator/record counts: `124` logical instances, all `15` curated GLBs, `19` MultiMesh batches, `20,178` instanced source triangles, and zero added bodies/shapes. The unchanged procedural set retains minimum clearances of `4.017 m` from roads, `7.274 m` from buildings, `3.625 m` from terrain/shoreline overlays, and `25.517 m` from the shoreline edge. The fixed NAIP shrub row's minima are `0.102 m`, `1.109 m`, `14.450 m`, and `19.267 m` respectively, with all 22 points outside the actual road/building polygons and zero rejections.
- The independent Node audit checks `206,339` road/area sample points against exact land planes and `14,904` exterior-foundation samples; maximum positive foundation gap, roof flatness error, and source-height deviation are all `0`. The runtime's first visible player clearance is `0.000 m`; walk/run stays within `-0.002..+0.001 m`, and jetpack landing/recovery clearance is `0.000 m`.
- The standalone automated route drove the real player continuously from the ferry through Waterfront Plaza and along Trade Winds Avenue with the current movement tuning: `262.349 m` traveled across 14 terrain-aware checkpoints in about `18.1 s` wall time, with walk/run input, continuous grounding, and zero stalls, recoveries, boundary escapes, or discontinuities; see the retained [normal-route log](evidence/first-playable/final-verification-2026-09-03-105408/logs/42_normal_route_after_export_guard.log).
- Its bounded whole-island mode traveled `3,449.107 m` in about `52.2 s` wall time (`415.817 s` simulated), completed all five landings, stayed below a `0.348 m` maximum physics-tick step, and had zero stalls, recoveries, boundary escapes, or post-start transform writes; see the retained [whole-island route log](evidence/first-playable/final-verification-2026-09-03-105408/logs/43_whole_island_route_after_export_guard.log). The retained [coherent-surface route evidence](evidence/first-playable/coherent-surface-route-2026-08-28-1458/README.md) remains historical geometry evidence from the earlier movement tuning.
- The historical pre-B201 `1440×900` 12-view Forward+/Metal set covers
  ferry, north, center, southwest, east perimeter, Building 1,
  SF/YBI/bridge context, an eligible-wall tag, south vegetation, and a
  time-connected public-input jetpack ascent/descent pair. Independent review
  returned `PASS_WITH_LIMITATION`; it remains byte-valid source-project evidence
  for its own prior topology and does not establish current package pixels or
  owner recognition. Exact hashes and the proof boundary are in
  [the 104510 visual evidence](evidence/first-playable/exact-current-visual-repair-2026-09-03-104510/README.md).
  The August 13-frame textured-world set is historical for the later exact
  source.

See [the first-playable evidence index](evidence/first-playable/README.md) for the precise proof boundary and [the current coverage view](evidence/first-playable/coherent-surface-coverage-2026-08-28-1458/whole-island-derived.png).

## Regenerate and validate

The immutable OSM snapshot remains authoritative for horizontal geometry, while the pinned USGS crop is authoritative for bare-earth elevation. Source hashes and acquisition details are in [data/osm/README.md](data/osm/README.md) and [data/terrain/README.md](data/terrain/README.md). The commands below require Node `v26.7.0`, Osmium `1.19.1`, and dependencies restored from the committed lockfile.

```sh
npm ci --ignore-scripts --registry=https://registry.npmjs.org/ --cache=.tools/npm-cache
node tools/build_source_inventory.mjs
node tools/build_godot_world.mjs
node tools/validate_godot_world.mjs generated/world
node tools/check_godot_world_determinism.mjs
node tools/render_world_coverage_evidence.mjs
node tools/render_world_coverage_evidence.mjs --validate-only evidence/first-playable/coherent-surface-coverage-2026-08-28-1458
```

`build_source_inventory.mjs` rewrites only the derived source-ledger CSV and summary. `build_godot_world.mjs` atomically replaces `generated/world`, including canonical `vegetation.json`; the validator and two-clean-generation check compare that file byte-for-byte and should pass before running Godot. Re-rendering coverage atomically replaces the coverage evidence directory. Do not edit frozen source or generated world artifacts by hand.

The exact headless commands and their assertions are documented in [game/tests/README.md](game/tests/README.md).

## Export

The exact current private package is `build/d2-1444-quality-v2-current-2026-09-09-001/Treasure Island First Playable.app`.
Bundle identity `07fe27f678be4c7d71de77b42a79c6b8c46491034eb6c80a2b3e00eed097b4e6`; PCK `c010390dcfe213134445a352facd0720283818edd279e72851f17af83bcc426c` (`66,708,800` bytes); executable `a5a85e48fbd890e661d04a1e191bfe1280141c01c0212cc6fb4fd10591a90c4f` (`170,963,648` bytes).

Owner and independent current-package checks passed. The exact no-argument app created an owned visible native window, then was intentionally stopped; all app/source bytes remained exact. Computer Use reported an unconfigured node bridge and pending Accessibility/Screen Recording permissions, so no gameplay pixels or manual-input acceptance is claimed. [Ordinary launch evidence](evidence/first-playable/d2-1444-quality-v2-current-release-2026-09-09-001/ordinary-launch.json). Publication review, commit and push remain pending.
See the [current release closure](evidence/first-playable/d2-1444-quality-v2-current-release-2026-09-09-001/release-closure.json). All prior B1 and D2 apps remain retained historical artifacts.

### Historical B201 package

The previous private handoff was
`build/b201-promotion-staging-2026-09-05-024605/Treasure Island First Playable.app`.
It was exported from the B201 promotion working tree after the deterministic
compiler and full source matrix passed. It contains
generated content SHA-256
`01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`,
manifest SHA-256
`e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`,
the generated `729/739/48,389`, runtime record-root `723/733/48,739`,
and loaded `950/964/66,636` topologies, B201-stage `7/213` recognition,
`4/20/30/40` movement defaults, all accepted facade attachments, and
project-level `Dummy` audio selection. Its executable SHA-256 is
`23f8f5cfda04749bb6e2b00659d5f9e46086c55c8dde0cc00d1b2f8b5235146c`
(`170,963,648` bytes); PCK SHA-256 is
`3425018ee32f645c3bf157deb9f9a548efe3c9e0bca1e40fd588318aa31f54d6`
(`65,708,948` bytes); canonical ASCII path-sorted seven-file inventory
SHA-256 is
`ef300ab3f97d077f3db61fad53094cbc3a540175e6475e549d5cd0a3ab9e8f98`
over `236,745,436` logical bytes. The persisted inventory artifacts are
`bundle-inventory.records` (the canonical identity above) and
`bundle-inventory.tsv` (SHA-256
`92ecdade90c53593dd68f9d19c28e99c56909d9ee794f4ee77164543115d7d69`).
The B201 source, capture, review, closure,
and checksum boundary is in
[the B201 evidence record](evidence/first-playable/d1-b201-live-attachment-2026-09-04/README.md).

The `111725` final-verification app is historical pre-B201/pre-current-hero
package evidence. Its exact hashes and limits remain valid only for its own
bytes in [the historical final-verification record](evidence/first-playable/final-verification-2026-09-03-105408/README.md).

The prior `190724` startup-repair app is historical. Its static and plain
native-launch observations remain valid for its own bytes, while its PCK is now
also an expected mounted-auditor `node_modules` negative; see
[the historical startup-repair record](evidence/first-playable/startup-repair-mac-run-2026-08-31-190724/README.md).
The `231815` car-speed package remains historical because it predates both
the accepted facade attachment stack and startup repair; its package-smoke and
mounted-PCK evidence remain valid only for its own bytes in
[the historical car-speed record](evidence/first-playable/car-speed-mac-run-2026-08-28-231815/README.md).
The still-earlier `224622` textured-world app is historical pre-tuning
evidence in [its Mac record](evidence/first-playable/textured-world-final-mac-run-2026-08-28-224622/README.md).

An earlier export in the `224144` staging directory failed only the superseded flat-palette smoke assertion. It is not current and must not be used for playtest or handoff.

### Current export procedure

Build another candidate with the approved `macOS Private` preset only when needed, always choosing a fresh unused staging directory rather than overwriting this handoff:

```sh
GODOT=".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
mkdir -p "build/final-verification-staging-YYYY-MM-DD-HHMMSS"
"$GODOT" --headless --path . --export-release "macOS Private" "build/final-verification-staging-YYYY-MM-DD-HHMMSS/Treasure Island First Playable.app"

APP_BINARY="build/final-verification-staging-YYYY-MM-DD-HHMMSS/Treasure Island First Playable.app/Contents/MacOS/Treasure Island First Playable"
"$APP_BINARY" --headless -- --mac-export-smoke
"$APP_BINARY" --max-fps 60 --rendering-method forward_plus --rendering-driver metal -- --mac-export-smoke
```

The packaged smoke starts the exported PCK's normal main scene and fails after
60 seconds of monotonic wall time if its checks do not finish. It exits nonzero if
the exact ferry spawn/yaw, approved hash, source-current `977/992/71,828`
topology, grounded player-enable gate, exact `4/20 m/s` speed and
`30/40 m/s²` response defaults, ambient/camera defaults, live eleven-key
Poly Haven texture identities/effective repeats/filtering/normals, Space-bound
jetpack rise, or capped slow descent drift. It retains the
`semantic_palette=pass` output field for log compatibility, but that field
now represents the current semantic-material contract rather than the
superseded flat-color palette. It prints separate `MAC_EXPORT_VISUAL`,
`MAC_EXPORT_MOVEMENT`, and `MAC_EXPORT_JETPACK` lines before passing.
Serialize resource-heavy Godot checks and use explicit `--max-fps 60` for
non-headless Metal/Forward+ smoke. For historical comparison, exact candidate
`024605` passed its first
packaged headless and first Apple M2 Metal invocations through world, visual,
movement, grounding, jetpack ascent, and capped descent. The earlier `014223`
package predates the final evidence-contract bridge repairs and is withdrawn;
the `002922` first-Metal timeout likewise remains a withdrawn pre-scope
diagnostic. Neither is evidence for the current B1 v2 package.

Historical candidate `024605` passes strict deep and per-architecture ad-hoc
hardened-runtime signature verification and contains universal
`x86_64 arm64` slices. Only arm64 was exercised, on an Apple M2 verifier
host rather than the approved Apple M1 Pro target. The x86_64 slice is
statically present and strictly signed but unexecuted. The app is neither
Developer ID signed nor notarized, has no TeamIdentifier or entitlements,
requests no sensitive permissions in `Info.plist`, and is only for approved
private local use. A no-argument ordinary launch started these exact bytes on
the Apple M2 verifier host; that process observation is neither pixel review
nor owner play on the approved Apple M1 Pro.

Every active adapter's `review_status` is explicitly scoped only to original
runtime-asset detail provenance. Reference-recognition acceptance does not
derive from that field: it derives from the mapped physical unit's exact
`claim_status.reference_recognizable` value and an independent acceptance
receipt. The compiler, runtime loader, Node tests, Godot tests, and mounted B1,
B201, B225, and D2 1441 consumers fail closed on missing or contradictory scope, authority,
status, receipt, topology-scope, or exact asset-closure data.

An export or packaged smoke command succeeding is not owner acceptance. Check the precise exported-app proof in [the first-playable evidence index](evidence/first-playable/README.md), then follow [PLAYTEST.md](PLAYTEST.md).

## Project map and cleanup

- [Approved approach](discovery/APPROACH_PROPOSAL.md) and [decision log](discovery/DECISION_LOG.md)
- [Frozen OSM provenance and hashes](data/osm/README.md)
- [Frozen USGS terrain provenance and hashes](data/terrain/README.md)
- [Generated manifest](generated/world/manifest.json) and [coverage summary](generated/world/coverage-summary.json)
- [First-playable evidence](evidence/first-playable/README.md)
- [Current B1 v2 release closure](evidence/first-playable/building-1-wing-returns-v2-current-release-2026-09-08-001/release-closure.json)
- [Current B1 v2 evidence mechanics](evidence/reviews/building-1-wing-returns-v2-current-release-2026-09-08-INDEPENDENT_EVIDENCE_MECHANICAL_AUDIT.md)
- [Current B1 v2 visual review](evidence/reviews/building-1-wing-returns-v2-current-release-2026-09-08-INDEPENDENT_VISUAL_AUDIT.md)
- [Historical D2 1441 v9 postpromotion evidence](evidence/first-playable/d2-1441-postpromotion-v9-2026-09-07-001/capture-manifest.json)
- [Historical D2 1441 v9 independent mechanical audit](evidence/reviews/d2-1441-postpromotion-v9-2026-09-07-001-INDEPENDENT_CONTRACT_AUDIT.md)
- [Historical D2 1441 v9 independent visual review](evidence/reviews/d2-1441-postpromotion-v9-2026-09-07-001-INDEPENDENT_VISUAL_REVIEW.md)
- [Historical B225 postpromotion evidence](evidence/first-playable/d1-b225-postpromotion-v8-2026-09-05/capture-manifest.json)
- [Historical accepted B201 live evidence](evidence/first-playable/d1-b201-live-attachment-2026-09-04/README.md)
- [Historical pre-B201 exact-source 12-view evidence](evidence/first-playable/exact-current-visual-repair-2026-09-03-104510/README.md)
- [Historical pre-B201 final-verification Mac package evidence](evidence/first-playable/final-verification-2026-09-03-105408/README.md)
- [Jetpack source-runtime evidence](evidence/first-playable/jetpack/README.md)
- [Historical coherent-surface route evidence](evidence/first-playable/coherent-surface-route-2026-08-28-1458/README.md)
- [Historical August textured-world rendered evidence](evidence/first-playable/textured-world-final-rendered-2026-08-28-223242/README.md)
- [Historical startup-repair Mac export evidence](evidence/first-playable/startup-repair-mac-run-2026-08-31-190724/README.md)
- [Historical car-speed Mac export evidence](evidence/first-playable/car-speed-mac-run-2026-08-28-231815/README.md)
- [Historical pre-tuning textured-world Mac export evidence](evidence/first-playable/textured-world-final-mac-run-2026-08-28-224622/README.md)
- [Historical coherent-surface rendered evidence](evidence/first-playable/coherent-surface-rendered-2026-08-28-1458/README.md)
- [Historical bridge-connected skyline rendered evidence](evidence/first-playable/owner-bridge-connected-rendered-2026-08-28-1944-retry/README.md)
- [Historical bridge-connected Mac export evidence](evidence/first-playable/owner-bridge-connected-mac-run-2026-08-28-194611/README.md)
- [Historical pre-placement solid-silhouette rendered evidence](evidence/first-playable/owner-silhouette-rendered-2026-08-28-1921/README.md)
- [Historical owner-outline skyline rendered evidence](evidence/first-playable/owner-skyline-rendered-2026-08-28-1900/README.md)
- [Current corrected vegetation rendered evidence](evidence/first-playable/vegetation-corrected-quick-rendered-2026-08-28-1556/README.md)
- [Historical pre-placement solid-silhouette Mac export evidence](evidence/first-playable/owner-silhouette-mac-run-2026-08-28-192220/README.md)
- [Historical owner-outline Mac export evidence](evidence/first-playable/owner-skyline-mac-run-2026-08-28-190242/README.md)
- [Historical pre-skyline current-source Mac export evidence](evidence/first-playable/current-source-mac-run-2026-08-28-183204/README.md)
- [Historical pre-vegetation coherent-surface Mac export evidence](evidence/first-playable/coherent-surface-mac-run-2026-08-28-1500/README.md)
- [Historical full visual-QA Mac package audit](evidence/first-playable/visual-qa/mac-run/README.md)
- [Historical staged jetpack Mac export evidence](evidence/first-playable/jetpack/mac-run/README.md)
- [Historical ferry-only Mac export evidence](evidence/first-playable/spawn/mac-run/README.md)
- [Historical pre-ferry Mac export evidence](evidence/first-playable/mac-run/README.md)
- [Acceptance audit and remaining requirement gaps](evidence/first-playable/acceptance-audit.md)
- [Install provenance and narrow removal steps](INSTALL_LOG.md)

Disposable outputs have narrow boundaries: close the game/editor before cleanup; remove an exported app only from its exact staging path under `build/`; regenerate `generated/world` instead of hand-editing it; and use the reviewed Godot/npm removal procedures in [INSTALL_LOG.md](INSTALL_LOG.md). Do not delete the frozen `data/osm/` or `data/terrain/` inputs when cleaning build or tool output.
