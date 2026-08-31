# Building 3 / 600 California bounded facade pilot

Status: **ready for independent review; not self-accepted**  
Captured: **2026-08-29**, Godot `4.7.2`, Forward+, Metal, Apple M1 Pro, `1440 x 900`

## Exact scope

- Source: `w34313540`; receiver: `building:w34313540:wall`.
- Only the contiguous observed ENE-main chain, serialized runs `27..35`, is styled. Its reference-relative layout is `90.320 m` from `(528.784, 488.910)` to `(486.955, 408.860)`.
- The added language is one homogeneous warm off-white mineral field, one complete `B3-HANGAR-DOOR`, and one complete `B3-BAND`. No architectural repeat or incomplete opening is embedded in a wall tile.
- The remaining `50` wall runs, roof, flat `20 m` extrusion, three-level source contract, footprint, foundation terrain extensions, collision, navigation, and spray receiver remain unchanged.
- Runtime layout hash: `312ed89a5bca6e3eadf3034b8e97689b9a99646837aca8f5f1f7f940a11f8299`; deterministic facade signature: `737a674d63824d574e28c76f75c86212dfe126c3204870cdb2d0452d5bcf6337`.

## Comparable evidence

- `01-close.png`: complete central hangar-door module at a close route-supported camera pose.
- `02-close-sprayed.png`: in-range real-controller tag on the unchanged target receiver.
- `03-ordinary-gameplay-camera.png`: ordinary third-person route-distance reading.
- `04-oblique-gameplay-camera.png`: oblique endpoint/relief reading.
- `05-changed-light.png`: same target under a changed deterministic sun direction.
- `capture-manifest.json`: exact camera/player/aim/light transforms, hashes, live receiver identity, run scope, module counts, world counts, adapter and renderer.
- `ASSET_INVENTORY.sha256`: project assets, integration/test files, generated inputs, manifest and capture hashes.

The final executor check found the bounded facade language readable: one dark teal end door in an ordinary warm-white field, with a subordinate shallow band and no invented cadence on other sides. This is an evidence comparison, not final art acceptance.

## Exact validation commands and retained results

```text
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --version
# 4.7.2.stable.official.ed1daf0bf

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit
# PASS: project import and Building3600CaliforniaFacade registration

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_scene_parse.gd
# PASS: parsed 4 gameplay scenes

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_gameplay_contract.gd
# PASS: gameplay inputs, movement/jetpack/boundary/scene/water/billboard/layer/ambient contracts

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_world_material_contract.gd
# PASS: 11 approved shared world material contracts

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/validate_generated_world.gd
# PASS: 735 playable + 4 context rows across 38 chunks; manifest 01af105e...7164

node tools/validate_godot_world.mjs
# PASS: status valid; 38 chunks, 729 physical objects, content 01af105e...7164

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_hawkins_facade_contract.gd
# PASS: independently accepted Hawkins receiver/facade remains unchanged

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_building_3_facade_contract.gd
# PASS: exact runs 27..35, massing/foundation/spray, deterministic complete modules, no spillover

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_isle_house_facade_contract.gd
# PASS: companion target and Museum/Hawkins preservation controls

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/full_runtime_integration.gd
# PASS: world_ready; 38 chunks, 729 generated meshes, 48,381 generated triangles, gameplay/spray/cleanup

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/automated_route_qa.gd
# PASS: actual PlayerController traversed all 14 checkpoints continuously, no stall/recovery/boundary loss

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/next_cohort_facade_capture.gd
# PASS: ten comparable views total; five written here and five to the Isle House evidence directory
```

The first sandboxed GUI launch exited `134` before rendering. Two development capture passes then correctly hit the Building 3 receiver but rejected spray because the chosen aim point exceeded the controller's `6 m` player-to-hit range. The final evidence separates a complete-door close pose from the in-range lower-door spray pose; this is a deterministic evidence-pose correction only. All five files above come from the final successful recapture.

Headless runs emit the existing restricted-environment `user://logs` rotation and macOS CA-certificate warnings; assertions and exit codes pass. No unrelated validator failure remains.

## Known limitation and review boundary

The current flat `20 m` extrusion cannot reproduce the observed curved crown or taller shoulder/pylon silhouette. Those are prohibited massing changes, not facade defects in this pilot. The independent reviewer should judge material, complete-module boundaries, reference-relative ENE composition, ordinary-camera readability, and target spillover separately from that disclosed whole-building limitation.

