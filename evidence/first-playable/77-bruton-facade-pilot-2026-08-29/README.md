# Hawkins / 77 Bruton facade pilot evidence

Date: **2026-08-29**  
Executor: `/root/hawkins_facade_implementation`  
Target: frozen OSM `w1249412093`, exact receiver `building:w1249412093:wall`

## Status

- Implementation and invariant gates: **pass**.
- Exact-receiver rendered evidence: **complete**.
- Facade-language art direction: **ready for independent review; not self-accepted**.
- Faithful whole-building Hawkins resemblance: **`blocked_by_current_massing_invariant`**.

The facade pass improves material and opening language on the exact current wall. It does not repair the known mismatch between the real six-story/four-story Hawkins composition and the frozen `6.0 m` extrusion. Nothing in this result authorizes a height, story, roof, footprint, foundation, collision, navigation, terrain, or generated-contract change.

## Implemented representation

- `game/resources/facades/hawkins_77_bruton_layout.json` is the target-specific, side-local layout. It pins the four canonical side endpoints and uses continuous metre coordinates rather than the generated U value that restarts at foundation segments.
- Nine scalar, opaque, dielectric `StandardMaterial3D` resources under `game/resources/materials/world/hawkins/` own the light pearl, plain pearl, smooth/ribbed base, frame, opaque glass, spandrel, garage/service, and sign-letter responses.
- The fine upper flutes and dark base ribs are deterministic shallow render geometry. No bitmap window/facade tile, generated whole-cell candidate, external image, borrowed map, transparency, baked facade shadow, displacement, or height map is used.
- `hawkins_upper_modules.tscn` and `hawkins_ground_modules.tscn` declare only complete motifs. The runtime batches their shallow boxes efficiently while retaining one semantic module node per complete opening, spandrel, connector, lobby, door, garage, sign fascia, and shallow band.
- The exact current wall faces receive a `0.012 m` render-only field overlay; maximum outward relief is `0.05 m`. Every facade visual is on render layer `2`, which the existing spray decal targets. The facade adds no body, shape, navigation region/link, occluder, or spray-receiver group.
- `side_se` and `side_wsw` receive reference-bounded complete modules. `side_ene` and `side_nnw` are material-only, with no invented door, window, garage, sign, connector, balcony, or canopy.

Runtime module inventory:

| Motif | Count |
|---|---:|
| `W-P` complete paired upper window | 30 |
| `S-H` complete pale spandrel/sill | 30 |
| `R-C` shallow connector | 2 |
| `W-N` complete narrow opening | 2 |
| `L-G`, `D-P`, `F-SIGN`, `C-B`, `D-S`, `G-G` | 1 each, address side only |

The deterministic runtime facade signature is `cf5b2a3aeb94e1482b1be9f9895f84463ce78e7ee6d1d38ee14e7833b8b8deff`; the layout hash is `ccce9fd2c8027d25e95bb6750e5b23297786c747242eec607de5e4be41d1b4ef`.

## Preserved receiver and gameplay contracts

- Generated chunk `generated/world/chunks/x_-1__z_1.json`: SHA-256 `b8696d4feb4157d39969ec039e610af572f25510d712c802d4a96943d6069c8c`.
- Generated manifest file: SHA-256 `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`; content SHA-256 `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`.
- `git diff -- generated/world data/osm` produced no output and exited `0`.
- Wall remains `80` vertices, `40` triangles, `20` foundation segments, current flat base `4.274 m`, top `10.274 m`, and source height `6.0 m`.
- Its original `Mesh` remains shared `building_wall` / `plaster_grey_04`; its original single `StaticBody3D` and `ConcavePolygonShape3D` remain the only facade collision and the only `spray_receiver_wall` owner.
- Roof `building:w1249412093:roof`, terrain-aware foundations, generated coverage/source identity, other buildings, navigation, and global material assignment are unchanged.
- A focused live physics ray through the address-side modules resolves the underlying exact collider and source identity. Capture `02` uses the real spray controller and retains a visible tag on the render-only facade.
- Full runtime still reports `729` generated meshes, `48,381` generated triangles, `466` bodies, and `466` shapes, and its movement, jetpack, camera, recovery, receiver rejection, spray, and tag-eviction exercise passes.

## Rendered evidence

All captures are `1440 x 900`, Forward+/Metal on Apple M1 Pro with the normal third-person camera (`70°` FOV, `5.5 m` spring). Exact transforms, ground support, hashes, renderer, light rotation, identity, and module counts are in `capture-manifest.json`.

| File | Role | SHA-256 |
|---|---|---|
| `01-address-close.png` | Close address-side lobby/entry/sign/window review under project light | `90e8039999d19da1ee4779a50a7386bbcd28475efb666935a652fa6f48d2cdf7` |
| `02-address-close-sprayed.png` | Same close exact receiver after one real-controller spray | `f62d02229847184dc944068a6e4e7c084d23898b37b72d8831b86cfac6b74f4d` |
| `03-broad-gameplay-camera.png` | Ordinary WSW gameplay-route view | `87e1ab4e237d37668ed15f807f1d098afb084902ded921b0d07b7598a3dbcd7f` |
| `04-corner-oblique-gameplay.png` | Ordinary oblique view across the two observed sides | `d181c583a98db6ae77c59e7a84b7bda9c4bd8b65461f14464ac877353b66054d` |
| `05-address-changed-light.png` | Address-side exact receiver with sun changed from `(-52,-28,0)` to `(-38,125,0)` degrees | `5697bf07e43c1e42beac524137fae5c9bc7ad5bfacaf7e1e4882d1c1ae40555b` |

## Exact verification commands and results

Run from the project root. Every retained command below exited `0`.

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --version
# 4.7.2.stable.official.ed1daf0bf

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit
# project scan and script registration completed

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_scene_parse.gd
# PASS: parsed 4 gameplay scenes

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_gameplay_contract.gd
# PASS: gameplay inputs, movement/jetpack, boundary, scene, water, billboard, layer, and ambient contracts

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_world_material_contract.gd
# PASS: 11 shared Poly Haven semantic materials retain exact maps/scales/filtering/normals

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/validate_generated_world.gd
# PASS: 735 playable + 4 context rows across 38 chunks; pinned content hash

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_hawkins_facade_contract.gd
# PASS: exact Hawkins target, deterministic facade, unchanged massing/collider/material/spray, no spillover, observed/unobserved side policy

node tools/validate_godot_world.mjs
# status: valid; 38 chunks, 729 physical objects, 124 vegetation instances

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/full_runtime_integration.gd
# PASS: real main scene/world/gameplay integration; 729 meshes, 48,381 triangles, 466 bodies/shapes

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/automated_route_qa.gd
# PASS: 14-checkpoint continuous PlayerController route, no teleport/stall/boundary loss/recovery

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot \
  --path . --display-driver macos --rendering-method forward_plus \
  --rendering-driver metal --audio-driver Dummy --resolution 1440x900 \
  --script game/tests/hawkins_facade_capture.gd
# PASS: captured 5 exact Hawkins facade views
```

The headless Godot runs emit the existing restricted-environment `user://logs` rotation and macOS CA-certificate warnings; all assertions and exit codes pass. No pre-existing or unrelated validator failure was observed. Two development-only capture anchors initially landed on an adjacent `building_part_roof`; the final capture harness now deterministically selects nearby generated walkable ground and the retained run passes.

## Comparison to the reference specification

- Identity and receiver: exact.
- Material family: light low-chroma upper field, fine vertical shallow flute language, dark smooth/ribbed base, charcoal frames, opaque cool blue-grey glass, pale spandrels, and restrained clean response are present.
- Motif topology: windows, narrow openings, storefront, paired entry, service door, garage, sign fascia/letters, connector, and band are complete modules; no motif is completed by a texture edge.
- Side policy: detailed modules are restricted to observed `side_se` and `side_wsw`; unobserved sides are conservative material fields.
- Repeat/UV policy: there is no facade bitmap or atlas edge to seam-test. Ribs are complete, explicit geometry periods; module coordinates are continuous per side and independent of the twenty generated U resets.
- Gameplay and geometry boundary: pass under automated contracts and live spray capture.
- Whole-object resemblance: remains blocked by the required unchanged `6.0 m` massing.

## Known limitations for independent review

- The one adapted upper row and one ground band cannot reproduce the real six-story plus four-story massing or roof/terrace composition.
- Module placements are reference-relative production estimates, not a rectified as-built elevation.
- Opaque glass has no interior and all recesses are shallow visual proxies.
- Fine `64 mm` rib geometry was reduced to `2 mm` outward relief and had its own shadow casting disabled after close review, but pixel-scale sampling can still resolve as a sparse vertical cadence at some angles. This should be judged independently rather than presumed accepted.
- The ordinary WSW gameplay capture shows the deliberately conservative dark lower band; the available broad owner view did not authorize address-side lobby/garage motifs there.
- Adjacent simple generated massing is visible in close and oblique frames. It is outside this target and was not altered.

The pilot is ready for an independent semantic/art and whole-object review. This executor does not accept final art direction.
