# Hawkins / 77 Bruton targeted facade correction evidence

Date: **2026-08-29**  
Executor: `/root/hawkins_facade_implementation`  
Target: frozen OSM `w1249412093`, exact receiver `building:w1249412093:wall`

## Status

- The one authorized facade-language correction round is **implemented and mechanically passing**.
- The same five Forward+/Metal evidence definitions were recaptured at byte-identical player, camera, aim, and light poses. The prior rejected evidence remains immutable at `../77-bruton-facade-pilot-2026-08-29/`.
- Executor inspection finds the prior dash/sparkle and diagonal-moire failure absent from close, ordinary gameplay, oblique, and changed-light views. The WSW lower band now carries complete observed-side openings, and W-P reads with a low horizontal transom rather than a center split.
- This is **ready for final independent art re-review; it is not self-accepted**.
- Faithful whole-building Hawkins resemblance remains **`blocked_by_current_massing_invariant`** because the required `6.0 m` extrusion is unchanged.

## Exact before -> after correction

| Independent-review failure | Rejected pilot | Finite correction |
|---|---|---|
| Fine `64 mm` P-F response | Individual `18 mm`-wide, `2 mm`-relief box flutes sampled as dashes/sparkle and diagonal moire | No upper flute geometry. A project-owned opaque shader evaluates a `0.064 m` side-local tangent-space normal and attenuates it analytically with `fwidth` from `0.12` to `0.28` cycles/pixel. At undersampled distances the response converges to the continuous base coating instead of aliasing. |
| W-P pane grammar | Complete outer frame plus a center-only vertical mullion | Complete outer frame plus one complete low horizontal transom, creating the observed lower-pane character. No center mullion remains in W-P. |
| WSW lower band | No ground modules; one long smooth blank base | `15` complete `G-W` openings across the owner-photo main region, phase-aligned with its upper bays, plus `2` complete openings across the sparser companion region. The address-specific lobby, sign, doors, garage, and service grammar remains side-local to SE. |

The owner-private photo was reviewed locally and was not copied into the repository. No browser, image generation, download, install, external resource, or account was used.

## Preserved contracts

- Generated target chunk SHA-256: `b8696d4feb4157d39969ec039e610af572f25510d712c802d4a96943d6069c8c`.
- Generated manifest SHA-256: `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`; content SHA-256: `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`.
- `git diff -- generated/world data/osm` produced no output and exited `0`.
- Wall remains `80` vertices, `40` triangles, `20` foundation segments, base `4.274 m`, top `10.274 m`, and current height `6.0 m`.
- The original record-owned wall mesh/material, one `StaticBody3D`, one `ConcavePolygonShape3D`, receiver/source identity, spray eligibility and placement, roof, terrain-aware foundations, navigation, and other buildings are unchanged.
- Added facade content remains render-only, on render layer `2`, with maximum shallow module relief `0.05 m`; it adds no collision, navigation, occluder, or spray receiver.
- ENE and NNW remain material-only with no modules. SE address one-offs remain one each. No `G-W` spills onto SE or either unobserved side.
- Layout SHA-256: `2debe810737a98fef19ceaa0bfe6ec241abf3cafdcac3aea8f005eed42cdd8e6`.
- Deterministic runtime facade signature: `6fc4d5aee82a5a496c3e77d3752fe07f18e798a1dba4364a3671fccc8d0d8161`.

Runtime module counts are unchanged except for the authorized `17` WSW `G-W` complete ground openings: `W-P=30`, `S-H=30`, `R-C=2`, `W-N=2`, `G-W=17`, and one each of `L-G`, `D-P`, `F-SIGN`, `C-B`, `D-S`, and `G-G`.

## Comparable rendered evidence

All five files are `1440 x 900`, Forward+/Metal on Apple M1 Pro, normal third-person camera (`70°` FOV, `5.5 m` spring). `capture-manifest.json` records every exact transform and confirms the prior and corrected transforms are identical.

| View | Rejected pilot SHA-256 | Corrected SHA-256 |
|---|---|---|
| `01-address-close.png` | `90e8039999d19da1ee4779a50a7386bbcd28475efb666935a652fa6f48d2cdf7` | `1bc00ca31d37c5cb1138ddadd386abeefb03b85f784e4b50c3c476e72769af1d` |
| `02-address-close-sprayed.png` | `f62d02229847184dc944068a6e4e7c084d23898b37b72d8831b86cfac6b74f4d` | `870a543aaac1e8171dab293c3e12d0af9031bcdd06c5ab87e0377432a58b0657` |
| `03-broad-gameplay-camera.png` | `87e1ab4e237d37668ed15f807f1d098afb084902ded921b0d07b7598a3dbcd7f` | `cf354fafa9e4daab5af6a3816f9c59538bc8e9d49f8ff64469ee6f8b4cc70ecb` |
| `04-corner-oblique-gameplay.png` | `d181c583a98db6ae77c59e7a84b7bda9c4bd8b65461f14464ac877353b66054d` | `359e19d00add29f727c8fa0d91aae04754b2dc5a63a382fb0024d49f1b00ca93` |
| `05-address-changed-light.png` | `5697bf07e43c1e42beac524137fae5c9bc7ad5bfacaf7e1e4882d1c1ae40555b` | `950bad470c5cbe7146bd100e3ec495dcab90ba7e458c48baa57522433bd460d4` |

The changed-light capture retains sun rotation `(-38, 125, 0)` degrees; the default project sun remains `(-52, -28, 0)` degrees. Capture `02` again places one tag through the real spray controller on the unchanged underlying wall receiver.

## Exact verification commands and retained results

Every retained command below was run from the project root and exited `0`.

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --version
# 4.7.2.stable.official.ed1daf0bf

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit
# project scan and script/shader registration completed

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_scene_parse.gd
# PASS: parsed 4 gameplay scenes

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_gameplay_contract.gd
# PASS: gameplay inputs, movement/jetpack, boundary, scene, water, billboard, layer, and ambient contracts

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_world_material_contract.gd
# PASS: 11 shared Poly Haven semantic materials retain exact maps/scales/filtering/normals

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/validate_generated_world.gd
# PASS: 735 playable + 4 context rows across 38 chunks; pinned content hash

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_hawkins_facade_contract.gd
# PASS: exact target identity, deterministic filtered material/modules, unchanged massing/collider/spray, no spillover, WSW 15+2 grammar, material-only unobserved sides

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
# PASS: captured 5 corrected exact Hawkins facade views
```

The headless runs emit the existing restricted-environment `user://logs` rotation and macOS CA-certificate warnings; assertions and exit codes pass. One development-only full-runtime run exposed that the culling validator recognized only `StandardMaterial3D`; it was corrected with an exact Hawkins shader path/name/cull-mode allowance, after which the retained full-runtime run passed. No pre-existing or unrelated validator failure remains.

## Independent re-review boundary

This evidence is specifically prepared for a new independent semantic/art verdict on the two authorized failures. It does not reopen address-side one-offs, unobserved-side detail, palette, generated data, gameplay, or massing. The executor's visual check is not final art acceptance.

Known limitations remain unchanged: one adapted upper row cannot reproduce the real multi-story volumes; all openings are shallow opaque-glass proxies; module positions are reference-relative rather than rectified as-built measurements; and the frozen `6.0 m` extrusion continues to block faithful whole-object resemblance.
