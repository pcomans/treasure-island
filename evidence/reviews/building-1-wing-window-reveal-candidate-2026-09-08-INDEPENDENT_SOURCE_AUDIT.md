# Building 1 wing-window reveal candidate — independent source audit

Date: **2026-09-08**  
Reviewer: **`/root/b1_reveal_audit`**  
Scope: **mechanical source and pixel-independent bar-raiser gate only**  
Baseline: **`b4ab09356c8a15843fa295af024434f97027e1fe`**

## Verdict

The bounded candidate may advance to fresh evidence capture. It changes only the
main Building 1 wall's existing dark reveal bucket, adding one closed,
render-only shadow-backing cuboid behind each of the already supported two-wing
`8 upper + 7 lower` window schedules. It does not earn new recognition credit
and this audit is not visual acceptance.

No source-level blocker was found. The exact final candidate is bound below;
any later byte change requires another source gate.

## Exact baseline and candidate binding

The released baseline was clean and published at
`HEAD == origin/main == b4ab09356c8a15843fa295af024434f97027e1fe` before
this candidate began. Its relevant identities were:

| Release input | SHA-256 |
| --- | --- |
| `game/scripts/world/facades/building_1_hero_model.gd` | `e5b11fc7f971ea33bb38c84d3106f8883de0486774f58a5a8310d49d56aa55a5` |
| `game/resources/facades/building_1_public_front_believability.json` | `7b53847c627d6f0a0d4ebefcc790e8fd3bcaeee6fbdebbf5c6a85f2aeb4a5806` |
| `game/tests/headless_building_1_hero_model_contract.gd` | `3a4ebe3b650e84bfd42ab42e879fd5f60543815e9b865ce135837a02a973b26f` |
| `game/tests/headless_building_1_public_front_believability_contract.gd` | `b26307ca94a4af3f524d89c99f1c7601ebcc36df999fd37522f1f4267c94176c` |
| `game/resources/materials/world/building_1/building_1_reveal_shadow.tres` | `2e1f36f163c037fe060a1ecfcdcc5dd062849290a96c508970384585b176e14a` |

The stable candidate reviewed here is exactly:

| Candidate input | SHA-256 |
| --- | --- |
| `game/resources/facades/building_1_public_front_believability.json` | `fca8feba243c4b1b1747050852ab2db7102aae668838ad8265524caa20cc6fc1` |
| `game/scripts/world/facades/building_1_hero_model.gd` | `1b3e9086b9a5628a68fe684736010277219b02f931d09e03f1442be15afe35a8` |
| `game/tests/headless_building_1_public_front_believability_contract.gd` | `0c73a6dbc9028b7a3cb7fac5e474f93b32cf823dc74a44aefba275723f1184e2` |
| `game/tests/headless_building_1_hero_model_contract.gd` | `24831f23cad27004f36851d7dbbedd02ca607190b7543a2f378897e12ba31bf2` |

The index remained empty. Apart from the implementation agent's required
retrospective, those four paths were the complete worktree diff. The release
app process `81751` remained alive and was not used, terminated, or replaced by
this audit.

## Evidence and inference boundary

The unchanged hero specification SHA-256
`135ef9ae411d41892d25d1c679d10fe022193348b6406c4a8abecb55805c9720`
records the NPS-supported recognition grammar: two wings with eight upper and
seven lower window bays per wing. The existence and family/count grammar are
source-supported. The exact host chains, metre dimensions, margins, centers,
depths, and cadence remain reversible game-art `production_inference`; they are
not surveyed or as-built claims.

The target is only physical unit `physical-building:r16681702`, receiver
`building:r16681702:wall`. The separately keyed observation tower
`w1222720021` remains a separate physical unit and is byte-unchanged. No source
photography, image texture, generated texture, interior, opening cut, rear-side
program, or facade-scale motif is added.

## Exact reveal construction

The release reveal surface contained 14 cuboids: eleven center-window backings
followed by three entrance-group backings. Their vertex/normal/UV/index prefix
remains byte-exact at
`ca176003fd3f48d2fb3f08d40232398dfbda33949995cd9a47dec52e4a4de7de`.
This follows both the runtime prefix hash and the source diff: the two existing
reveal builders, their inputs, and their call order are unchanged, and the new
wing calls occur only afterward.

Exactly 30 cuboids are appended in this order: north upper `8`, north lower
`7`, south upper `8`, south lower `7`. Each cuboid contributes 24 vertices and
36 indices / 12 triangles. The final surface is therefore 44 cuboids,
`1056/1056/1056/1584` vertex/normal/UV/index entries, and 528 triangles. Its
complete array hash is
`b3fa18f566ac516bdb94e3e70ddf4da155768277ef2d3c700d256719ce53960c`.
The sole delta is `30 * 12 = 360` triangles.

The two families have these exact candidate planes and extents, all measured
along each source-run outward normal:

| Family | Backing width × height | Existing glass front | Reveal front | Reveal rear | Reveal depth / center |
| --- | ---: | ---: | ---: | ---: | ---: |
| upper wing | `2.67 × 3.12 m` | `+0.070 m` | `+0.030 m` | `-0.010 m` | `0.040 / +0.010 m` |
| lower wing | `2.37 × 2.77 m` | `+0.165 m` | `+0.125 m` | `-0.010 m` | `0.135 / +0.0575 m` |

Thus every reveal has the exact `0.16 m` border, sits `0.04 m` behind the
glass front, and overlaps the host rearward to `-0.01 m`. It cannot float in
front of the glazing. The small rear overlap is occluded by the host wall and
does not invent a rear elevation.

The Godot-built chain schedule resolved exactly as follows:

| Chain/family | Chain length | Count / end margin | Equal spacing | Exact centers along chain (m) |
| --- | ---: | ---: | ---: | --- |
| north upper, runs `9..20` | `35.451525` | `8 / 2.2 m` | `4.435932` | `2.2, 6.635932, 11.071864, 15.507796, 19.943729, 24.379661, 28.815593, 33.251525` |
| north lower, runs `9..20` | `35.451525` | `7 / 2.5 m` | `5.075254` | `2.5, 7.575254, 12.650508, 17.725763, 22.801017, 27.876271, 32.951525` |
| south upper, runs `44..56` | `43.891406` | `8 / 2.2 m` | `5.641629` | `2.2, 7.841629, 13.483259, 19.124888, 24.766518, 30.408147, 36.049777, 41.691406` |
| south lower, runs `44..56` | `43.891406` | `7 / 2.5 m` | `6.481901` | `2.5, 8.981901, 15.463802, 21.945703, 28.427604, 34.909505, 41.391406` |

The exact schedules are fail-closed in the hero validator. Reordered or
substituted north/south chains, altered `8/7` counts, changed end-run ownership,
missing reveal parameters, wrong schema, changed values, wrong material/bucket,
zero border, lost front lag, positive rear plane, argument swapping, collision
routing, and end-composition reveal routing are all rejected by the candidate
mutation matrix.

## Scope, topology, and protected-state result

The existing scalar reveal material path and SHA-256 remain exact. No bright
trim, sill, extra frame, subdivision, or material was added, so this is a dark
opening-depth cue rather than a white-cage escalation. The generic end-window
builder remains reveal-free, so runs `93` and `60` receive no new backing.

All non-reveal Building 1 mesh-array hashes remain exact, including glass and
trim despite routing the same arguments through the dedicated wing helper.
All three roof/canopy hashes and all four separately keyed tower mesh hashes
also remain exact. Collision is unchanged byte-for-byte:

- main Building 1 wall:
  `21d69032bdba73c0406545b0b7d2c8efefd423fe8263815c3edc57bdc3756db5`;
- main Building 1 roof:
  `bb2c36915cba6d9d5f5d1a8239888ef1c913b1e4396eb6ce1cd2145c1a38e337`.

Exact resulting topology is:

| Scope | Meshes / surfaces / triangles / bodies / shapes | Delta from release |
| --- | --- | --- |
| `r16681702` wall | `6 / 6 / 9166 / 1 / 1` | `0 / 0 / +360 / 0 / 0` |
| `r16681702` roof | `3 / 3 / 1131 / 1 / 1` | none |
| `w1222720021` wall | `3 / 3 / 760 / 1 / 1` | none |
| `w1222720021` roof | `1 / 1 / 14 / 1 / 1` | none |
| combined Building 1 pair + tower pair | `13 / 13 / 11071 / 4 / 4` | `0 / 0 / +360 / 0 / 0` |
| prospective current world | `735 / 959 / 974 / 69612 / 466 / 466` | `0 / 0 / 0 / +360 / 0 / 0` |

The main-wall collision remains the sole Building 1 spray receiver; roof and
tower ownership, the four independent body/shape owners, roof landing rays,
exact 110-run horizontal plan, generated chunks, world builder, navigation,
and decals are unchanged. The accepted D2 1441 pair also remains exactly
`8/8/1568` wall plus `1/1/10` roof with its `10,12,13,15` mapped runs,
protected-run partition, nine material batches, collision, and ownership intact.

## Authority and regression checks

The catalog, schema, generated report, runtime registry, adapter contracts,
loader, compiler, hero config, both generated source chunks, world builder, and
main entrypoint are byte-identical to release. Current authority therefore
remains compiler `1.8.0`, catalog/runtime schema `9`, contracts/loader API `8`,
and exactly `9/213` accepted physical units with 204 not evaluated. This
candidate is intentionally uncredited.

I independently ran these source-side gates against the exact hashes above;
all exited `0`:

1. `headless_building_1_public_front_believability_contract.gd` — exact
   30/44-box geometry, prefix/full hashes, material, mutation matrix, topology,
   deterministic reconstruction, and collision hashes.
2. `headless_building_1_hero_model_contract.gd` — all four source identities,
   exact mesh hashes, combined topology, prospective full-world topology, roof
   rays, wall spray rays, and D2 1441 preservation.
3. `headless_gameplay_contract.gd` — unchanged input map, `4/20 m/s`
   walk/run, `30/40 m/s²` response, unlimited hold-to-rise jetpack defaults,
   camera, boundary, scene, render, and layer contracts.
4. `automated_route_qa.gd` — 14 checkpoints, `262.349 m` real
   player-controller traversal, zero recovery, boundary loss, stalls, or
   teleport.
5. `automated_route_qa.gd -- --whole-island-route` — `3449.107 m`, all five
   regions and landings, `0.348 m` maximum step, and zero recovery, boundary
   escape, stalls, or post-start transform writes.

## Pixel-independent bar-raiser judgment

At source level this is the right bounded experiment. It addresses the accepted
sticker-like wing-window limitation through restrained physical depth while
preserving the stronger center, canopy, entrance, stepped massing, and tower
identity cues. It does not counterfeit realism with signs, hue, copied center
subdivision, unsupported rear detail, or dense bright framing.

Pixels are still mandatory. Fresh evidence must show both wings at ordinary
ground/player height, whole-building and useful obliques, default and changed
light, grayscale, and continuous approach/parallel motion. The independent
visual reviewer must reject for black halos, a repeated dark barcode, bright
frame/reveal cage, z-fighting, corner bleed, moire, shimmer/crawl, depth pop,
or any loss of the center-first hierarchy. Modest regularity alone is not a
source blocker because cadence is explicitly production inference, but it must
remain believable in motion.

PASS_FOR_B1_REVEAL_EVIDENCE_CAPTURE
