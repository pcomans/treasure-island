# Final textured-world Metal evidence

Date: 2026-08-28

Engine: Godot `4.7.2.stable.official.ed1daf0bf`

Renderer: Forward+ / Metal on Apple M1 Pro

Viewport: `1440x900`

## Result

**PASS.** The complete fixed 13-view pass received final art-direction sign-off for the private hobby-project first playable. Vehicle asphalt, pedestrian concrete, paved/parking concrete, textured ground, plaster walls, and bitumen roofs read as a coherent hierarchy. The reviewed ground, road, area, and building contacts read as continuous rather than torn or floating. Remaining grass and blank-wall repetition is visible but acceptable at this scope.

The same pass also retains the recognizable, non-colliding San Francisco silhouette, western Bay Bridge, YBI terrain, and water context; shows a real-controller tag on an eligible building wall; and proves that the deterministic NAIP-derived shrub row uses six visually separate premade shrub variants. No geometry, collision, gameplay, skyline, bridge, or YBI change was requested by the final art review.

## Bound revision

- Generated content SHA-256: `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`.
- Manifest file SHA-256: `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`.
- Captures: `13`; world counts: `38` chunks, `729` meshes, `48,381` triangles, `466` bodies/shapes, and `124` vegetation instances in `19` MultiMesh batches.
- All five ordinary-height regional captures settled on generated collision at `0.000–0.001 m` clearance.
- The eligible-wall spray capture placed exactly one predefined tag at `3.917 m` from the real player controller.
- The context capture projected the San Francisco billboard at `633.8 px` (`44.0%` of viewport width) with zero context collision nodes.
- Contact sheet SHA-256: `ba00c71a7e6510e2ad7e21d5beff2c65c239fcc287bf6455f4cc5c7e4766777b`.
- Focused shrub frame SHA-256: `12f514acbf806f896f959f89edeef1fcf9104c8c24dd33e7e3b474d8be99196e`.

`capture-manifest.json` records every camera/player transform, ground clearance, intent, image path, image hash, renderer, adapter, and exact runtime count. `contact-sheet.png` is review convenience only; the original PNGs and manifest are authoritative.

## Scope of proof

This is real Metal rendered evidence of the exact source revision and a bounded art-direction pass. It does not replace the packaged-app audit or the owner's ordinary hands-on playtest.
