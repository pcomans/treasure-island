# `w291196370` detached exact-receiver module calibration

Captured: **2026-08-30**  
Renderer: **Godot 4.7.2 / Forward+ / Metal / Apple M1 Pro**  
Review status: **ready for independent detached art review; not self-accepted**

## Bounded result

This package places exactly three detached, capture-scene-only exemplars over the already accepted `W291196370-SIDING` receiver field:

| Placement | Complete motif | Side / region | Exact ordered chain | Anchor | Declared envelope | Truth status |
|---|---|---|---|---:|---:|---|
| `CAL-SSE-WINSTACK-01` | `W291196370-WINSTACK` | SSE / observed public elevation | runs `8, 9, 10` | chain `5.5 m`, run `8`, fraction `0.483398` | center `3.5–7.5 m` (`±2.0 m`) | stylized/reference-derived production inference; not surveyed |
| `CAL-SSE-ENTRY-01` | `W291196370-ENTRY` | SSE / observed public elevation | runs `8, 9, 10` | chain `32.0 m`, run `10`, fraction `0.423166` | center `29.0–35.0 m` (`±3.0 m`) | stylized/reference-derived production inference; not surveyed |
| `CAL-ENE-SERVICE-01` | `W291196370-SERVICE` | ENE / observed outer end | runs `17–22` | chain `39.5 m`, run `20`, fraction `0.504439` | center `35.5–43.5 m` (`±4.0 m`) | stylized/reference-derived production inference; not surveyed |

Each declared center envelope plus the full nominal motif width stays inside its one named accepted run. The exemplar count is not a real opening count. Coordinates, physical scale, count and cadence are unsurveyed; cadence is unknown and was not inferred.

All three assets remain complete bounded `module_atlas` motifs, not seamless wall tiles. Together they produce `24` detached render-only meshes / `24` surfaces / `288` triangles, with zero module-owned field/backing meshes and zero collision, navigation or spray nodes.

## Isolation and immutable receiver state

The calibration root is parented only to the capture scene. It is not a child or descendant of `building:w291196370:wall`. The actual loaded receiver child count stayed `2 → 2`: one exact two-surface generated wall mesh plus its existing collision body. Its accepted siding metadata remained byte-equal to the canonical helper and still reports zero live modules.

Generated data and live runtime inputs are unchanged:

- generated source: `729` records / `729` meshes / `736` surfaces / `48,389` triangles / `466` collider pairs;
- loaded world before the detached overlay: `847` meshes / `854` surfaces / `49,805` triangles / `466` collider pairs;
- generated manifest SHA-256: `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`;
- `x_0__z_-3` SHA-256: `6dfa4b8f4b91f309b313428829e37cedd13e4067ff94f896a8e2e5ef05002a1d`;
- world builder SHA-256: `bd1c9e52e0a36c13092382616dc0ff6e5ce52dfd16e279303491db8c73cfa23f`;
- accepted-field helper SHA-256: `2f547040b38a4d46ca900c0bd8fb3a260bfb4a7df6cda9e8578d084f8b065029`;
- canonical inventory JSON/Markdown SHA-256: `c9ed0671…` / `71d8e2e7…`.

The accepted siding remains sole owner of nonopening pixels on SSE runs `8..10` and ENE runs `17..22`. Placeholder/protected runs, materials, terrain, massing, roof, other buildings and existing live modules are unchanged.

## Native evidence matrix

| Image | Review use |
|---|---|
| `images/01-close-sse-winstack.png` | Close complete three-pane-row WINSTACK, trim depth, siding continuity and grounding. |
| `images/02-close-sse-entry.png` | Close complete ENTRY leaf/frame without stairs, ramp, rails or backing. |
| `images/03-close-ene-service.png` | Close complete SERVICE leaf, full frame and motif-owned leaf seams without host-field reset. |
| `images/04-ordinary-sse-public-context.png` | Ordinary gameplay-height SSE context showing both eligible SSE motifs and the long blank siding span. |
| `images/05-ordinary-ene-outer-context.png` | Ordinary gameplay-height ENE context showing SERVICE in its supported region. |
| `images/06-sse-ene-multi-side-context.png` | Building context with all three exemplars and both supported regions; protected intermediate facets remain visibly outside the siding/module claim. |
| `images/07-changed-light-oblique-sse.png` | Changed-light oblique view of the SSE motifs and shallow trim separation. |

All seven images are native `1440 × 900` Forward+/Metal captures. Executor inspection was limited to validity: nonblank output, target visibility, complete motif silhouettes, receiver continuity, camera diversity and evidence labels. It did not assign an art verdict.

Reproduce with:

```text
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/w291196370_module_calibration_capture.gd
```

The capture manifest records every protected input hash, exact and resolved placement, camera, light, image checksum and isolation count.

## Preserved blockers

- NNW, WSW, runs `0..7`, `11..16` and `23..35`, short/service facets and yard-hidden chains receive zero calibration modules.
- SERVICE is not transferred to SSE; WINSTACK and ENTRY are not transferred to ENE.
- Divider/trim/accent cadence, stairs, ramps, rails, adjacent personnel openings, parapet treatment, access context and yard objects remain excluded.
- Exact real coordinates, physical scale, total opening count, cadence, completed elevations, live attachment, lifecycle acceptance and whole-building resemblance remain blocked.

This package is ready for a separate independent detached exact-receiver art review. It is not authorization to attach any motif to the live receiver.
