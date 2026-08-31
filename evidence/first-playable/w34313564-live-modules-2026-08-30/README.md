# `w34313564` five-module live integration evidence

Status: `ready_for_independent_live_gameplay_art_review_not_self_accepted`

This evidence set proves that exactly the five independently approved corrected calibration exemplars are attached to the actual generated receiver `building:w34313564:wall`:

| Placement | Motif | Face / host | Exact anchor |
|---|---|---|---|
| `CAL-SSE-PDOOR-01` | `W34313564-PDOOR` | SSE / tan | run `7`, face-chain center `47.5 m` |
| `CAL-SSE-HWIN-01` | `W34313564-HWIN` | SSE / tan | run `8`, face-chain center `68.0 m` |
| `CAL-ENE-HWIN-01` | `W34313564-HWIN` | ENE / pale | run `12`, face-chain center `18.0 m` |
| `CAL-NNW-PDOOR-01` | `W34313564-PDOOR` | NNW / pale | run `16`, face-chain center `32.0 m` |
| `CAL-NNW-HWIN-01` | `W34313564-HWIN` | NNW / pale | run `17`, face-chain center `54.0 m` |

Every live row is labelled `stylized/reference-derived production inference`. The documented `±4 m` value remains same-run calibration provenance only: it is not runtime jitter, a surveyed accuracy claim, a cadence, or an inferred real opening count.

## Reused reviewed geometry

The live adapter reuses the reviewed detached module geometry without artistic changes:

- corrected registry SHA-256: `45a47d333c997887cef7d1c97a633d37ae050efda597186430c7af6d52116f0f`;
- reviewed geometry helper SHA-256: `b49b8c20fbbe40f2728c0acadf8d53f0593856091e6df897a613d4f2f8680b71`;
- final correction review SHA-256: `a8f1396e2d126c0c38b37edf770df975c4fa95e25e34fb2c7c1e766630fd1591`.

The predecessor calibration manifest (`c664d7e0…`) and correction manifest (`d1fcc1a1…`) remain unchanged. No module factory, module material, field material, shader, registry, detached helper, or historical evidence file was edited.

## Mechanical result

The generated world remains `729` meshes, `736` surfaces, `48,389` triangles, and `466` body/shape pairs. The live module-only delta is:

- `5` module nodes: `3` HWIN and `2` PDOOR;
- `34` render-only mesh instances, `34` surfaces, and `408` triangles;
- `0` module-owned field meshes;
- `0` collision, navigation, or spray nodes.

The loaded-world result is therefore `763` meshes, `770` surfaces, `48,797` triangles, and the same `466` body/shape pairs. The generated receiver wall remains the sole collision/spray authority. All module faces have positive outward clearance from the host wall (focused-contract minimum `0.06 m`), so no duplicate or coplanar face was introduced.

Accepted tan runs `5..9`, accepted pale runs `10..19`, placeholder runs `0..4`, the plinth, all other module motifs, other receivers, roofs, massing, terrain, foundations, generated data, collision, navigation, and spray ownership are unchanged.

## Native evidence

Eight fresh 1440×900 images were captured from the actual loaded world using Godot 4.7.2, Forward+, Metal, and Apple M1 Pro:

1. `01-close-sse-pdoor.png` — close live tan PDOOR;
2. `02-close-nnw-hwin.png` — close live pale HWIN;
3. `03-ordinary-sse-layout.png` — ordinary-distance SSE door/window pair;
4. `04-ordinary-nnw-layout.png` — ordinary-distance NNW door/window pair;
5. `05-changed-light-oblique-ene-hwin.png` — ENE HWIN under changed light;
6. `06-pale-orientation-corner.png` — ENE-to-NNW corner and orientation change;
7. `07-tan-pale-host-boundary.png` — accepted tan-to-pale host transition;
8. `08-whole-island-load.png` — whole-island loaded-world proof.

All eight were inspected only for evidence validity: nonblank output, live-target visibility, requested camera diversity, host continuity, grounding, transform readability, transition coverage, and absence of apparent z-fight/duplicate faces. This executor does not claim artistic acceptance or lifecycle promotion.

Renderer, resolved transforms, exact input hashes, topology, placement dictionaries, camera/light settings, and per-image hashes are recorded in `capture-manifest.json`. Test and route results are recorded in `verification-results.txt`.

## Remaining truth boundary

- Exact real-world opening coordinates, total count, and cadence remain unknown.
- The five fixed centers are approved stylized/reference-derived production inferences, not a reconstruction of the real facade.
- Plinth, WSW/runs `0..4`, pipes/vents, eaves, access geometry, unseen details, and any additional cadence remain outside live module scope.
- Independent gameplay art review must grade the actual attached result; the executor's validity inspection is not acceptance.
