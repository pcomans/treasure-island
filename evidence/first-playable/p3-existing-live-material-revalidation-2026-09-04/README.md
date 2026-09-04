# P3 Chapel and Dormitory exact-current evidence

Status: **technical capture valid; whole-object recognition and believability
remain pending independent review**.

This is a no-change evidence batch for the two bounded material treatments that
were already live before P3 research:

- Navy Chapel Building 187 — source `w291189336`, exact receiver
  `building:w291189336:wall`, warm-cream material only on runs `9,10`.
- Job Corps Dormitory Building 369 — source `w291189926`, exact receiver
  `building:w291189926:wall`, warm-wall material only on runs `0..5`.

Nothing here changes a visual, material, receiver, generated file, collision,
navigation, spray ownership, or runtime. Nothing here accepts either whole
building as recognizable. The frozen P3 packets, run maps, materials, chunks,
world manifest, builder, stock player, and camera bytes are pinned in
`capture-manifest.json`.

## Capture provenance

- Renderer: Godot 4.7.2, native macOS display, Forward+, Metal, Apple M2.
- Originals: four uncropped `1440x900` PNGs; no source photography is shipped.
- Camera: the visible stock-player `CameraPivot/SpringArm3D/Camera3D`, `70°`
  FOV and `5.5 m` configured spring arm. There is no detached camera, hidden
  context, FOV change, light change, crop, or post-process.
- Grounding: every fixed XZ pose settled through `CharacterBody3D` physics on
  generated `land_ground`, remained inside the gameplay boundary, drifted
  `0.000 m`, and incurred zero recovery.
- HUD: the ordinary reticle and player body are visible; debug, feedback,
  loading, and pause panels are absent.
- LOS: the viewport-center physics ray first-hits the exact receiver, exact
  source-key array, and intended accepted or protected run. Final target error
  is below `0.0005 m` in all four views.
- Framing: every image contains the complete wall-plus-roof bounds and complete
  accepted-run bounds. The live scope is at least `0.04` of frame width and
  `0.03` of frame height; the whole target is at least `0.12` by `0.025`.
- Captured world topology: `735` playable rows, `4` context rows, `938` meshes,
  `948` surfaces, `63,720` triangles, `466` bodies, and `466` shapes. This is
  exact-current load provenance only; concurrent Isle House topology is not
  evidence for either P3 target.

Capture command:

```text
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/p3_existing_live_material_revalidation_capture.gd
```

## Frozen review scope

The confusion sets and cue lists were copied from the completed P3 packets and
frozen before these originals were inspected.

| Target | Frozen close confusion set | Reference-supported cues the reviewer must test |
| --- | --- | --- |
| Navy Chapel 187 | Oasis `w291189918`; Dormitory 369 `w291189926`; Food Service 368 `w34313521`; nearby low California Avenue institutional buildings | SSE gable with tall divided multipane window and shallow entry; square belfry with pyramidal cap and cross; warm cream field with partial narrow long-side window groups |
| Dormitory 369 | Advanced Culinary/Dorm cohort `w34313514`; Food Service 368 `w34313521`; Oasis `w291189918`; other long Job Corps blocks | warm off-white field against blue-gray end/stair volume and dark-green eave; five occupied tiers with alternating windows and green eyebrows; ground glazing/panels or doors/base vents |

The current treatments do not purport to supply those complete cue sets. The
Chapel has only a homogeneous background material on two runs. The Dormitory
has only a smooth warm-wall background on six runs; its other 66 runs and all
recognition modules remain protected/untreated. Cue visibility and
confusion-set discrimination therefore require an independent visual verdict
and cannot be inferred from this batch's technical PASS.

## Technical results

All four final PNGs were opened at original resolution. They decode, are
nonblank, show the intended target and surrounding world without corruption or
debug overlays, and leave protected/untreated context visible. This inspection
did not score facade fidelity, recognition, or believability.

| View | Center hit | Ground / camera height | Target W × H | Live scope W × H | LOS distance |
| --- | --- | ---: | ---: | ---: | ---: |
| Chapel whole object | run `9` accepted | land / `1.706 m` | `0.346 × 0.142` | `0.107 × 0.132` | `60.726 m` |
| Chapel oblique | run `9` accepted | land / `1.757 m` | `0.308 × 0.115` | `0.076 × 0.111` | `72.863 m` |
| Dormitory whole object | run `12` protected | land / `2.002 m` | `0.324 × 0.039` | `0.093 × 0.032` | `152.181 m` |
| Dormitory oblique | run `2` accepted | land / `2.000 m` | `0.347 × 0.038` | `0.119 × 0.031` | `156.419 m` |

Dormitory whole-object framing intentionally centers protected run `12`; the
oblique centers accepted run `2`. Together they expose rather than conceal the
bounded live treatment and untreated faces.

## Required unresolved gates

1. An independent reviewer must open both originals per target at full size,
   compare only with its cited P3 packet and frozen confusion set, and record a
   cue-by-cue and confusion-set verdict.
2. The Chapel still lacks reference-supported openings, entry/gable treatment,
   belfry/cross geometry, substrate/relief, and most public-side coverage.
3. The Dormitory reference shows five occupied tiers while the exact generated
   object is still a fallback `6 m` mass. The low silhouette in these complete,
   ordinary views makes that contradiction visible; it is a blocking truth,
   not a resolved or texture-faked feature.
4. Dormitory blue-gray end/stair volume, green eave and eyebrows, windows,
   ground glazing/doors/panels/vents, and all protected faces remain unresolved.
5. No whole-object acceptance, facade/as-built claim, or denominator credit may
   be entered until those review and implementation gates are separately met.

## Pre-seal technical iterations

- The initial Chapel whole-view anchor `(-52,705)` was rejected before image
  capture because its vertical ground probe hit an unrelated building roof.
  It was moved to generated land at `(-52,675)`; no target, FOV, light, gate, or
  confusion set changed.
- The initial Dormitory whole-view anchor `(-25,640)` framed the accepted scope
  only `0.0279` of frame height, below the frozen `0.03` technical minimum. It
  was moved 20 m closer on the same public approach to `(-25,620)`. Complete
  target bounds, protected faces, stock rig, and exact protected-run LOS remain.
- A second full native pass repeated all geometric, grounding, LOS, and framing
  metrics. Three PNGs were byte-identical. The grass-containing Dormitory whole
  view produced a different pre-seal PNG encoding, so only the second-pass file
  and hash are sealed; this batch makes no byte-deterministic rendering claim.

Run the focused seal check with:

```text
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --headless --audio-driver Dummy --script game/tests/headless_p3_existing_live_material_revalidation_evidence_contract.gd
```
