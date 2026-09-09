# Building 1 wing returns v2 — independent source/mechanical audit

Date: **2026-09-08**
Reviewer: **`/root/handoff_state_review`**, independent of the B1 implementer
Candidate: **`building-1-wing-window-returns-v2-2026-09-08`**
Starting checkpoint: **`82043cefd216ac995363fe72cea48763d0247951`**

## Verdict and exact scope

**PASS_FOR_B1_RETURNS_V2_EVIDENCE_CAPTURE** for the frozen source candidate
below. Independent source inspection and all six required executable gates
pass. This licenses the next candidate package/export/capture stage only.
It grants **+0 recognition credit**, no visual acceptance, no promotion, and
no released-app claim. Recognition authority remains **9/213**.

The v2 source contains 30 wing openings with four light return strips each,
using the existing trim material beneath the unchanged frame silhouettes.
It restores the accepted center-only dark-reveal mesh and preserves existing
glazing, accepted trim, roof/tower geometry, collision, and D2 authority.
Substantive visual improvement over the older assets remains unproven until
fresh ordinary-gameplay A/B views and motion receive independent visual review.

## Frozen inputs

The implementer snapshot is retained at:

`/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/b1-v2-001/candidate-source-handoff.json`

Its SHA-256 is
`7a22b9a084d40aad74daa7cf7e54c6f51f826152669621260e780dd412a6adbe`.
I verified that snapshot, the following five file hashes/sizes, and all 34
frozen dependency entries in the focused contract both before and after my
independent runs. All matched. I separately verified the implementer's six
final log hashes and PASS lines; those checks did not replace my own executions.

| Source input | Bytes | SHA-256 |
| --- | ---: | --- |
| `game/resources/facades/building_1_public_front_believability.json` | 4104 | `99117e1af118592db1d1cfa932b44014862cb8be4f47d0b3ea519e24f9e591fb` |
| `game/scripts/world/facades/building_1_hero_model.gd` | 52707 | `ce2f21dab02163b5f45d9d7e457f5d0ce96089bc55cca6e65aa9924c9f199c5a` |
| `game/tests/headless_building_1_wing_returns_v2_contract.gd` | 42268 | `3189ccb938d12f86bd27fa7ac8beb7c412d74d60497cb678d89d48e4dad87e92` |
| `game/tests/headless_building_1_hero_returns_v2_contract.gd` | 25984 | `77349b2d3126c6cb8115983c732a65e1cb038da8b34eb2ab6de37dd2d3d66de3` |
| `game/tests/full_runtime_building_1_returns_v2_integration.gd` | 57343 | `4a245d32d1087662bc2b2dfc61a3882d2f084ee2747ed410c0f7a3a3009c5424` |

The unchanged gameplay contract SHA-256 is
`4b1593313b520d0c9b75950f38ec7f9179247700c5589640d90dd9ad14391dbd`;
the unchanged `game/tests/automated_route_qa.gd` SHA-256 is
`38ee8deff49730d8d59af857ff21e3f661dbe4792538e367a320f2877ad22229`.
Both remain unchanged from the starting checkpoint. The accepted global
runtime oracle remains untouched at
`c3dfefb96eac27b2cd0b73f97accdd6d333d1203115a4198de8302149044ed38`;
its v2 suffix changes only the candidate triangle allowance and explanatory
text, preserving every other runtime assertion.

The 34 frozen dependencies cover the B1 materials/shader and exact source
chunks, hero schedule, accepted global oracle, v1 focused/capture/evidence/
package programs and three audit receipts, D2 product, world builder, and
catalog/compiler/runtime authority. Rejected v1 programs and audit bytes were
not edited or rerun. The frozen v1 source/mechanical/visual dispositions remain
`PASS_FOR_B1_REVEAL_EVIDENCE_CAPTURE`,
`PASS_FOR_B1_REHEARSAL_MECHANICS_ONLY`, and `HOLD_B1_REVEAL_REHEARSAL`.

## Source and geometry findings

- Product changes are limited to the B1 public-front config and hero adapter.
  The schema/pass identity is new. The original two-wing `8 upper + 7 lower`
  schedule, cadence, runs, center/end/tower/rear scope, and source identity stay
  fixed. New v2 proof files preserve the frozen v1 programs.
- Actual `ArrayMesh` vertex/normal/UV/index arrays are checked. The contract
  resolves every opening against its generated source frame and verifies all
  four return-box bounds and unchanged glazing bounds; it does not infer
  geometry from node labels or declared counts alone.
- Each return connects from `-0.010 m` behind its host plane to `0.065 m`
  on the upper row or `0.165 m` on the lower row. It overlaps the unchanged
  perimeter-frame back by `0.005 m`. Its lateral and vertical footprint matches
  those existing perimeter bars. The dark surface remains the existing
  aperture glazing; no new dark backing box is emitted. Dimensions remain
  production inference, not surveyed/as-built measurements.
- The new 120 boxes contribute exactly **1,440 render-only triangles** above
  the accepted baseline, or **1,080** above rejected v1. The unchanged box/quad
  helper supplies closed, consistently oriented faces. The return code writes
  only the existing trim bucket and adds no collision, navigation, or spray
  owner. Potential visual seams, aliasing, and believability still require the
  downstream pixel/motion gate.
- The complete 567-box accepted trim prefix matches its frozen array hash.
  The restored 168-triangle center-reveal mesh matches the previously sealed
  accepted prefix hash. Every other B1 wall/roof/tower mesh array matches its
  required unchanged hash.
- Loaded trim and glazing are checked as actual `StandardMaterial3D` values:
  light trim `(0.865, 0.84, 0.76, 1)`, roughness `0.78`, metallic `0`;
  dark glazing `(0.145, 0.205, 0.235, 1)`, roughness `0.32`, metallic `0.14`.
  They remain opaque, untextured, and non-emissive. Hash pins and material-copy
  mutations cover same-path recoloring/roughness changes as well as role swaps.
- The executed mutation matrix rejects missing/extra-opening array lengths,
  cadence and run/end/center/rear routing changes, a dark vertex beyond the
  frame, a displaced/floating return, light/dark material changes, collision
  byte changes, and changed D2/authority/frozen-lineage digests. Positive checks
  bind the actual loaded geometry and materials to the independently inspected
  source and immutable inputs.

## Independently measured result

| Scope | Meshes | Surfaces | Triangles | Bodies / shapes |
| --- | ---: | ---: | ---: | --- |
| B1 main wall | 6 | 6 | 10,246 | 1 / 1 |
| B1 roof/canopy | 3 | 3 | 1,131 | 1 / 1 |
| Separate tower wall | 3 | 3 | 760 | 1 / 1 |
| Separate tower roof | 1 | 1 | 14 | 1 / 1 |
| B1 combined | 13 | 13 | 12,151 | 4 / 4 |
| Candidate world, 735 playable rows | 959 | 974 | 70,692 | 466 / 466 |

`HeroTrim` contains **16,488 vertices / 16,488 normals / 16,488 UVs /
24,732 indices**, or **8,244 triangles**. Its full array hash is
`72f4b3305ec451504c9cafda98ba1439fcee02b50c529c036e54defe0cd179b0`;
accepted trim-prefix hash is
`8a1f4ba50ab041457f420a95ee371a304b2cd0d4509b9d644b89ed722262a6e3`.
The 168-triangle center-reveal hash is
`ca176003fd3f48d2fb3f08d40232398dfbda33949995cd9a47dec52e4a4de7de`.

Main wall collision remains 2,046 face vertices with SHA-256
`21d69032bdba73c0406545b0b7d2c8efefd423fe8263815c3edc57bdc3756db5`;
roof/canopy collision remains 1,737 face vertices with SHA-256
`bb2c36915cba6d9d5f5d1a8239888ef1c913b1e4396eb6ce1cd2145c1a38e337`.
The hero gate independently exercises actual roof-tier/tower landing rays and
eligible-wall rays. D2 retains its exact mapped/protected geometry, material
semantics, wall spray owner, paired roof blocker, source closure, and authority.

The full runtime loaded all 38 chunks and 729 generated records, measured
959/974/70,692 rendered topology, and exercised grounded player enable,
walk/run, jetpack rise/descent/renewed rise/landing, camera collision,
recovery, real spray placement/rejections, and the 64-tag cap. Failed reload
left no partial world; scene nodes returned from one to one after teardown.

The ordinary route traversed **14 checkpoints / 262.349 m**, with zero
airborne frames, stalls, or recoveries and no captures. The whole-island route
traversed **3,449.107 m**, visited five regions, made five landings, and measured
a maximum step of **0.348 m**, with zero stalls/recoveries/teleports and passing
boundary checks. Its logged wall time was `52.071 s`, simulated time `415.817 s`.

## Independent execution receipts

All six commands were executed sequentially by this reviewer from
`/Volumes/Macintosh_HD/Users/user302070/code/treasure-island`, using
`.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script`.
The observed engine was `4.7.2.stable.official.ed1daf0bf`. Console output was
recorded with `tee` under `set -o pipefail`; each process terminal returned `0`
and its expected PASS line, with no SCRIPT ERROR/ERROR/Parse Error/FAIL output.
No candidate export, screenshot, rendered capture, or ordinary app launch was
performed. These are fresh independent runs; deterministic log bytes can
coincide with implementer logs.

| Log | Script under `game/tests/` | Additional arguments |
| --- | --- | --- |
| `01-focused.log` | `headless_building_1_wing_returns_v2_contract.gd` | none |
| `02-hero.log` | `headless_building_1_hero_returns_v2_contract.gd` | none |
| `03-gameplay.log` | `headless_gameplay_contract.gd` | none |
| `04-full-runtime.log` | `full_runtime_building_1_returns_v2_integration.gd` | none |
| `05-ordinary-route.log` | `automated_route_qa.gd` | none |
| `06-whole-island-route.log` | `automated_route_qa.gd` | `-- --whole-island-route` |

Raw logs are retained in the existing workspace scratch area:

`/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/b1-v2-independent-001/`

| Log | Bytes | SHA-256 | Exit |
| --- | ---: | --- | ---: |
| `01-focused.log` | 2207 | `08eb8968c38df9a5c8a7bf8cd988e9393ecd22c509884171d6e01b9f71155d3e` | 0 |
| `02-hero.log` | 2218 | `30497159ba74102e1f48c538b04b4ae68a97d65f4232aad1d1c3bac53bc1b261` | 0 |
| `03-gameplay.log` | 280 | `6d2e1c9cabc284ada09f4f241c6116168e5819b2a6ed9d4994967b19de0d713b` | 0 |
| `04-full-runtime.log` | 1285 | `0b304ce9434e25ecdfee59f48f7227de5e44fee6b5d8b6f74e4d51010a8c7269` | 0 |
| `05-ordinary-route.log` | 2786 | `8a9211a92c2dfc6cc561aa2f57c0d44e63c9c339c9862a802789cdc6772277fa` | 0 |
| `06-whole-island-route.log` | 3788 | `63eee6b7ca4f016ff407c65f347640637221f7f8fa04ed0c883af0c62234716f` | 0 |

The final job, session `98152`, reached terminal exit `0`. The heavy-test slot
was released before documentation closure. This reviewer changed only this
audit and its own RETRO entry, with raw independent logs in the scratch area.

## Downstream boundary

This receipt is acyclic: it binds the frozen source/test inputs, implementer
snapshot, and completed independent logs. It does not pin unfinished capture,
package, or evidence-verifier scripts, nor any future app. Those downstream
programs may pin this completed audit hash after it is frozen.

Next require a fresh candidate app, signing/inventory/privacy and direct-mounted
PCK checks, exact source/package provenance, and the unchanged ordinary A/B
camera/light/fixed-60 motion definitions. Then require separate mechanical
receipt review and an independent pixel-first bar-raiser. Reject exterior black
brackets/cards/gaskets, white cages, floating returns, shimmer/pop/z-fighting,
or lost center-first hierarchy. No authority transaction occurs before visual
PASS; Building 1 already belongs to the nine accepted units, so its quality
pass still adds no physical-building credit.

PASS_FOR_B1_RETURNS_V2_EVIDENCE_CAPTURE
