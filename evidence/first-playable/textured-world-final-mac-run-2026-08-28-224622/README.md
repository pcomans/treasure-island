# Final textured-world private Mac export

Date: 2026-08-28

App: `/Users/philipp/cowork/treasure-island-game/build/textured-world-final-staging-2026-08-28-224622/Treasure Island First Playable.app`

Engine/preset: Godot `4.7.2.stable.official.ed1daf0bf`, `macOS Private`

## Result

**PASS for the technical private-package gates; this is the sole current Mac handoff candidate.** The app was exported to a fresh staging directory and is bound to generated content SHA-256 `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164` and manifest SHA-256 `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`.

The packaged main-scene smoke passes in both forms:

```sh
APP_BINARY="build/textured-world-final-staging-2026-08-28-224622/Treasure Island First Playable.app/Contents/MacOS/Treasure Island First Playable"
"$APP_BINARY" --headless -- --mac-export-smoke
"$APP_BINARY" --rendering-method forward_plus --rendering-driver metal -- --mac-export-smoke
```

The native Forward+/Metal run uses normal VSync. The previously used uncapped `--disable-vsync` form is no longer recommended because its renderer can race the smoke's internal timer; that timing behavior is not a game-content failure.

Both passing smokes load all `38` chunks and `735 + 4` source rows, instantiate `729` meshes with `48,381` triangles and `466` bodies/shapes, validate `124` vegetation instances across `15` assets and `19` MultiMesh batches, check the live eleven-key semantic Poly Haven material contract backed by 18 1K texture maps, and exercise the packaged visual defaults and Space-bound jetpack rise/slow descent.

The final source-project art evidence is the [13-frame Metal pass](../textured-world-final-rendered-2026-08-28-223242/README.md), which received final art-direction `PASS`. That source render and these automated package gates do not replace ordinary play of this exact app; owner acceptance remains pending.

## Mounted-PCK audit

The independent mounted-PCK audit passes and reports:

- `185` virtual files total.
- `47` generated files, including all `38` chunk files.
- `18` packaged texture maps supporting the eleven semantic Poly Haven materials.
- `15` vegetation imports and all `22` accepted NAIP shrub records.
- Pavement classification includes all `208` vehicle-road and `219` pedestrian sources.
- Private-source scan: `private=0`.
- Banned-path/content scan: `banned=0`.

No raw private owner-photo source or banned authoring path is present in the mounted package.

## Artifact identity and platform checks

- Executable SHA-256: `fb1073de2d4a52691f3b2300a10ffefac70b2bd094c76c2a7799b942a6515364`; size: `170,963,648` bytes.
- PCK SHA-256: `b45dd77d1930c65756acaf5ad094c8a2be6e2629c50e6afee0d348632bdf55a0`; size: `54,045,108` bytes.
- Sorted seven-file bundle inventory SHA-256: `9aa6c99370d15e3a138ffa43ce6d95612a635c15ea8a4c1f54d2eca1cc1daeef`.
- Architectures: universal `x86_64 arm64`.
- Strict deep code-sign verification: `PASS`.
- arm64 full CodeDirectory SHA-256: `8e3b8aaa1822979fe07ff0e336a8ab55fff8cbce3a392e8403e711a20793e6c6`.
- Signing: ad hoc; no `TeamIdentifier`; not notarized.
- `Info.plist` requests no sensitive permissions.

This is a private local build, not a public distribution artifact.

## Superseded failed staging export

The earlier `224144` staging export failed only the stale flat-palette packaged-smoke assertion after the project had moved to the semantic Poly Haven material contract. It is not the current candidate and must not be used for handoff or owner play. The `224622` bundle above is the only current app.

## Proof boundary

This record proves exact bundle identity, packaged content, privacy exclusions, architecture, ad-hoc signature validity, plist scope, and bounded headless/native startup behavior. It does not prove ordinary mouse/keyboard responsiveness, sustained interactive performance, or owner acceptance. Complete the exact-app checklist in [`PLAYTEST.md`](../../../PLAYTEST.md).
