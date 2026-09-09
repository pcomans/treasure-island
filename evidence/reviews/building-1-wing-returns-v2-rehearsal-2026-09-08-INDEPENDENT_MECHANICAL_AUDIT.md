# Building 1 wing returns v2 — independent rehearsal mechanical audit

Date: **2026-09-08**

Reviewer: **`/root/handoff_state_review`**, separate from the artist

Scope: **candidate package semantics, evidence integrity and rehearsal mechanics; +0 recognition credit**

The sealed rehearsal passes independent mechanical review. The composite package
proof was independently rerun, and the evidence verifier reproduced its existing
receipt byte for byte. This licenses the separate visual bar-raiser review; it
does not grant visual acceptance, promotion, or a complete release-smoke PASS.

## Frozen inputs and receipts

All five source-gated inputs and four downstream programs still match the complete
artist handoff at task scratch `work/b1-v2-001/candidate-package-capture-handoff.json`,
SHA-256 `fd746ea5e2645b827e2b65af07d6f70713be5ce20a7da4061700c958ecddb725`.
The independent source audit remains
`building-1-wing-returns-v2-2026-09-08-INDEPENDENT_SOURCE_AUDIT.md`, SHA-256
`beced0b7bb42589a1214559e193855e46a90a1a0578f5e2a323995a9f2d77958`.

| Input | SHA-256 |
| --- | --- |
| Sealed capture program | `667b7fde2844d798eb2d13cafaa0fbe802ada1239335c300df40c5e0f0a89fb2` |
| Sealed evidence verifier | `2e8d103f1db851d0a9dd3a16036abb52ab5e1ecaac24a49e2de9e6bcbfc05540` |
| Mounted component contract | `658775e336ac1b582467b4327e34545f5b3bf665708834ef56853a9cfd792289` |
| Composite Python package verifier | `c1abee8975c3ffab69ff00390a16b50712c364688b4cf4956bb798caaae18c7b` |
| Signed candidate executable | `7d47d442cf8b19fab0e2628c79d7b5994961f8f2096b58046a14884e9f8f0af6` |
| Candidate PCK, 66,572,928 bytes | `59b37cf856dd1ece6aaadeee5c6278327997394339bb8450253193cbd89728da` |
| Exact seven-file app bundle identity | `742f325cd7634d01474105f7c2e01b6f254d72385a78341768148b9b87fc2897` |
| Original package receipt required by captures | `20a54f0a274d1f750aa4d2c5d48cb6cde34c7b95357426b0766c4d1e7a0e0b04` |
| Fresh independent package receipt | `2c48d4444e1c944196232fb6ad9506ad4d16c985c674338dc8f74c5c9131d2b1` |
| Rehearsal002 receipt, independently reproduced | `cae3db47439fa0e4e70fdbb12a37daa7c431cd7bed6574433a701da740073bb0` |
| Rehearsal002 ordered 98-input tree | `5046e9bb1aaec4b79ecc0649087a33e54c6b87de291d1376ed3ad76bce7d6dff` |

## Independently executed package and evidence checks

I ran `tools/verify_building_1_wing_returns_v2_candidate_package.py` with fresh
output `/private/tmp/b1-returns-v2-package-proof-independent-001`. Its process
runner explicitly supplies that directory as `cwd` to every subprocess. I checked
the resolved directory and absence of source-project markers. The mounted graph
requires `res://project.binary` and rejects `res://project.godot`; builders and
resources resolve from the exact PCK, with no source runtime fallback.

Strict signing, mounted B1/D2 components and privacy checks exited 0. Actual B1
mesh arrays resolve to `13/13/12151`, including 168 accepted center-reveal and
8,244 trim triangles; light/dark material semantics, wall/roof collision hashes,
D2 ownership, and unchanged v9 authority pass. Privacy checks measured 923
virtual files, 47 generated artifacts and 38 chunks, with zero private paths,
private raw content or banned entries. Exact app/source pins match before and
after, and the native telemetry parser rejects all 17 supplied negative controls.

The unchanged signed release executable ran **headlessly** with its internal
`--mac-export-smoke` argument. Both its engine log and merged stdout/stderr
independently match the restricted parser: world `735/959/974/70692/466/466`,
four context rows, expected printed spawn/visual/movement defaults, and 5,946 ms
load time. The historical combined smoke oracle still rejects with exit 1.
That failure is retained: the logs do not establish that triangle count was the
sole failing predicate, do not prove every unprinted predicate, and do not reach
the subsequent jetpack exercise. This is candidate world-ready telemetry proof,
not a complete current release smoke.

I separately executed the sealed evidence contract in **verify** mode against
`/private/tmp/b1-returns-v2-rehearsal-002`, supplying its exact existing receipt
and original package-receipt paths. Exit 0 reproduced the receipt byte for byte.
Independent enumeration confirms 92 PNGs plus six manifests, 70,133,929 bytes.
The ordered material is `relative_path|sha256|bytes\n` with bytewise-sorted path
strings; the downstream receipt is excluded from those 98 inputs.

## Capture, source and preservation closure

All 405 tracked runtime/project/resource blobs in the retained baseline source
match accepted commit `b4ab09356c8a15843fa295af024434f97027e1fe`. The candidate
differs in exactly the two source-gated B1 config/adapter files. Both stages use
one absolute, sealed capture script; baseline supplementary editor review inputs
also match their recorded hashes. The actual still runner explicitly requests
fixed 60 FPS and uses the corresponding source checkout for each stage.

Against frozen v1, 23 named capture methods are byte-identical. The two still/motion
methods differ only in schema identifiers and human log wording. Resolution,
camera rig, FOV, default/changed light, all ordinary/context/trajectory definitions,
fixed-60 behavior and tolerances remain exact. The verifier checks saved grayscale
pixel buffers against their original default images, exact still pairing, and
matching controller telemetry/engine ticks. Observed A/B motion pose delta is
0.0 m: north uses 530 ticks, south 531, with zero recovery or transform writes
after motion begins. Real spray targets the same B1 wall at 3.93954 m; both roof
routes use 533 ticks, including 223 jetpack ticks and 159 descent ticks, land on
the correct roof with 0.38280 m horizontal error, and record zero recoveries or
post-start transform writes. Protected rear, accepted tower, whole context and
diagnostic-only elevated views also pass the sealed contract.

Rehearsal002 preserves all 48 motion PNGs and four motion manifests from001
byte-identically. I checked both copies against reuse provenance SHA-256
`a95ceff16effb10ffe918349007539ce363de9434419ff96e1df5c0aec36ee11`.
Only 44 still PNGs and two manifests were recaptured after001 failed exact still
pairing; no tolerance or sealed program changed. Rehearsal001 remains present.
All three v1 proof programs, its three reviews and the handoff match `f377dcac`.
Rejected rehearsal004 retains its 98-input tree
`4af8dd0e395efb798548c710c3c72c99f170a6b22711017a377dab07827e7aaf`
and receipt `4fc7a1e0d64f23df62c3e919f56a48120c20ab5beeb5aca27548af8b49bb8460`.

The pixels are native Metal renders of exact **source checkouts**, with separately
proved corresponding PCK semantics. They are not package-rendered pixels. The
artist's ordinary signed-app observation establishes an OS-visible no-argument
window and empty log only: scoped screenshot capture failed, so no native player
pixel or interaction claim follows. Its observation/process receipts remain
`3a9488a15488a485b8537a2132fdc9573ba884d212010356d719eee4f1e92fba` /
`a8f561b734dbb3516ffca6bbe834b40fd021ec2aa7a558836846501159ca9c1d`.

## Independent records and next gate

Fresh package logs and process identities are bound by the independent package
receipt above. Supplemental records are in task scratch
`work/b1-v2-independent-mechanics-001`:

| Record | SHA-256 |
| --- | --- |
| `01-independent-package.log` | `41c91ec131f34e6849a585baa88746d3a8d4db21e4db8e5bc23ca25809b9e6af` |
| `02-independent-evidence.log` | `4c345a425a8c77af26b73cbb89f352876e323820d1dc49e005e3f4c3fdc80a19` |
| `03-independent-static-closure.json` | `52f2bfaed172fd7750926113c8f208195a8a9c03066476c99ee9102a06ea4ef1` |
| `evidence-run.json` | `b7c194cb7fdc7740485ecae36ba244d3b12ca9fa94cc79fd50a122cc0df67c0d` |

Final evidence process PID93321/session43114 is terminal with exit 0; package
wrapper session40195 is terminal with exit 0, with native PID93122's expected
exit 1 retained. The heavy slot was released at that final terminal. No fresh
render, source gameplay/route rerun, product/proof edit, integration or promotion
was performed. Authority remains **9/213, +0**. Next gate: separate pixel-first
bar-raiser review; full current release checks remain required after any approved
promotion.

PASS_FOR_B1_RETURNS_V2_REHEARSAL_MECHANICS_ONLY
