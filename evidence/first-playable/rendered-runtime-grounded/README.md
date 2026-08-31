# Corrected grounded rendered-runtime evidence

Date: 2026-08-28  
Engine: project-local Godot 4.7.2 stable (`ed1daf0bf`)  
Renderer: Forward+ / Metal on Apple M1 Pro  
Resolution: 1440×900 RGB PNG  
Result: **PASS**

## What passed

The isolated source-project harness loaded the normal `main.tscn` and its fail-closed generated world, then required content SHA `5899ebe131bbf05525fedebdac703a321a7aaf95523a57960cb937085068cfaa`, generated-manifest file SHA `07b8b195e1a05942e38d9bbbcb801394cf9f184051fb5f7a819c75677e46f160`, the exact ferry transform, 38 chunks, 735 playable plus 4 context rows, 701 meshes, 21,210 triangles, and 466 bodies/shapes.

Each regional and scenario capture starts three metres above a generated land hit with input cleared. The real player physics runs until `is_on_floor`, near-zero vertical velocity, and measured ground clearance at most 8 cm all hold within 360 frames. Only then is gameplay disabled for the deterministic render. The final clearances range from −0.0061 m to +0.0002 m; all settle without horizontal drift or recovery. Before every saved frame, the harness forces the tree unpaused, clears the HUD pause state, and refuses to write if the Pause panel remains visible.

The wall scenario recursively finds an eligible generated building record, grounds the real player, aims the live camera, and invokes the real `SprayController.attempt_spray()` path. It produced exactly one tag on `building:w1222514695:wall`, with source `w1222514695`, matching hit identity, and a live tag texture. The saved frame visibly shows the tag and `Tag placed` HUD feedback.

The context scenario is deliberately split into two views. From the grounded ferry pose, the SF billboard center and the runtime-mesh AABB centers for YBI and the Bay Bridge are separately aimed, projected inside the viewport/frustum, and checked for intervening world-solid blockers. These context nodes have no collision. Visual inspection confirms the SF skyline in frame 07 and the current simple YBI/bridge silhouettes in frame 08. This proves current rendering/placement, not geographic detail quality or owner recognition.

## Reproduce

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot \
  --path . \
  --display-driver macos \
  --rendering-method forward_plus \
  --rendering-driver metal \
  --audio-driver Dummy \
  --resolution 1440x900 \
  --script game/tests/rendered_visual_evidence_capture.gd
```

Godot's headless macOS driver is a dummy renderer, so pixel evidence needs this bounded native display process. It requires no GUI automation or user input, has a 60-second watchdog, restores visible mouse mode, and self-quits. Use `-- --visual-evidence-output=/absolute/path` for an isolated run directory. No app bundle is exported, inspected, or launched.

## Artifact identity

| View | Physics result / proof | SHA-256 | Bytes |
|---|---|---|---:|
| [`01-ferry-spawn.png`](01-ferry-spawn.png) | grounded, clearance +0.0001 m | `31035727e462afce0098756c1eacb9eedca7fa392e8bde247a17220d66ec5096` | 129,335 |
| [`02-north.png`](02-north.png) | grounded, clearance −0.0060 m | `55ef4f4032e80efa7c3fbeb8166ff9b81388162d866ce0c459b7bb1c68a558f9` | 121,463 |
| [`03-center.png`](03-center.png) | grounded, clearance −0.0001 m | `652696f09d960e5a61156f5545751f6709962e281cb09fe48a733ec573884569` | 60,350 |
| [`04-southwest.png`](04-southwest.png) | grounded, clearance +0.0001 m | `c0e474d0bac272e495ada9f3d984973766f7662850e72f82ee376d1901bde96f` | 47,153 |
| [`05-east-perimeter.png`](05-east-perimeter.png) | grounded, clearance +0.0001 m | `cfe41bad9ee53b2f77239e89941248fac53a5bcbc2915b4ad102db1d07dd015d` | 69,326 |
| [`06-near-wall-tag.png`](06-near-wall-tag.png) | grounded; one real-controller eligible-wall tag | `1441d1883edb2113cfaaa7faacdef1c3111aa99d8b68da9287291c4be43ed870` | 104,384 |
| [`07-horizon-context.png`](07-horizon-context.png) | grounded; SF center projected, unobstructed | `564704e15b92c89babebf14f2c5af6858150b078b8945eaee5b33e37ebc37ab6` | 72,302 |
| [`08-ybi-bridge-context.png`](08-ybi-bridge-context.png) | grounded; YBI and bridge centers projected, unobstructed | `41a2b17b6c3165a104db406cdacb11706e191c4a5c4f295854548d15343afad9` | 93,378 |

[`capture-manifest.json`](capture-manifest.json) SHA-256: `1f4851db793dee9eba9b2c5e5148bf3e7a2294c4ea87c4bc11644a900424c43e` (13,410 bytes). It records exact transforms, settling measurements, generated source identity, camera projection/occlusion checks, renderer, dimensions, image hashes, and nonblank pixel samples. [`capture.log`](capture.log) retains the sanitized final renderer and post-capture runtime outputs.

## Visual interpretation and limits

All eight final PNGs were inspected after the successful run. None contains a Pause overlay. The avatar visibly meets the ground in the five regional frames; the tag is visible on the wall in frame 06; the SF skyline is visible across the water in frame 07; and simple YBI/bridge context surfaces are visible in frame 08. North and southwest remain intentionally candid, wall-heavy compositions.

These are deterministic source-project scenario captures, not a connected traversal or an exported-app playtest. They do not prove input feel, ordinary camera operation, frame-rate stability, rejection feedback, or owner recognition. The planar terrain, simplified palette, sparse skyline, and especially the flat/simple YBI and bridge silhouettes remain visible quality limitations for owner judgment.

## Supersession and failed attempts

[`../rendered-runtime/`](../rendered-runtime/) is an explicitly superseded hovering baseline. During correction, three further failures were useful and are retained in [`capture.log`](capture.log): stale `is_on_floor` falsely accepted a teleported player until the clearance invariant was added; direct-child proxy scanning missed building records; and a structurally visible context shot was visually occluded. Partial outputs from those attempts are not acceptance evidence. The final directory above contains only the successful eight-frame set and manifest.
