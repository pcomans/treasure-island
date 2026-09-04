# Navy Chapel Building 187 — actual-live replacement evidence

Status: independently accepted for the exact-current live world. The sealed external live bar-raiser receipt at `INDEPENDENT_LIVE_BAR_RAISER_REVIEW.md` is SHA-256 `63bd6c5a79db837e3b53b60eea36887cee8c4c66af791715f964f023b926b5a9`; it authorizes exactly one additional reference-recognizable physical unit for `w291189336`, and no broader receiver-completeness, game-distinctiveness, or as-built-fidelity claim. The canonical recognition rollup is therefore exactly `6/213`.

The world builder consumes the exact `w291189336` wall and roof rows as one fail-closed transaction. It produces one approved Chapel visual root and two structural collision owners: a 94-triangle wall body that remains the sole wall spray receiver, and a 50-triangle roof/gable/belfry/cap/cross body that is world-solid but not a spray receiver. Neither generic row is stacked or available as fallback.

The implementation authority begins with the independently passed standalone review receipt SHA-256 `4232ad42b3600b1d7f945c5d51325bb9698c366e07eb1ddea3fd90f3f49235c6`. Runtime carries only that opaque authoring receipt digest. The later independent live receipt above binds the actual PCK, active adapter, exact topology, grounded stills, continuous motion, landing/ownership evidence, and the `+1` physical-unit decision. The accepted standalone visual signature remains `076e081df86e884f04cf7cb680304c35c64e6f76238de7060528c59097ae5c46`; the live split-ownership signature is `4766c5d562933eb632f1ef3bdcec828fc40be81c996db919c53405f776fa04a7`.

## Measured integration

- Whole world: 735 playable rows, 944 meshes, 957 surfaces, 64,572 triangles, 466 static bodies, 466 shapes.
- Delta from the accepted pre-Chapel baseline `735/940/954/64118/466`: `+0/+4/+3/+454/+0` for rows/meshes/surfaces/triangles/bodies (shapes also unchanged).
- Chapel visual topology: 6 mesh instances, 6 surfaces, 540 triangles.
- Chapel live collision: 94 wall triangles plus 50 roof/cap/cross triangles, exactly two bodies and two shapes, zero navigation owners, one wall-spray owner.
- Canonical full wall row SHA-256: `69769fef402b480f1626fdce47e6d4ad49ecb710dab2b2e7373e5efa5acf0080`.
- Canonical full roof row SHA-256: `54bcd378997d0778bdaee432dc24ecdbb142c5dc5371166cf2d690ebb245b832`.

The active global runtime oracle is reconciled to this independently accepted topology. Catalog v5, runtime registry v5, and the loader keep the paired Chapel wall/roof generated records under one source membership and one physical-building parent; only the wall is a direct facade receiver, and the parent counts exactly once in the `6/213` reference-recognizable numerator.

## Native evidence

- `images/01-whole-public-default.png`: grounded stock-player whole public object under default light.
- `images/02-whole-public-changed-light.png`: the exact same player and camera pose under frozen changed light.
- `images/03-public-oblique-default.png`: second grounded ordinary-player public approach.
- `images/04-stock-player-roof-landing.png`: supplemental technical frame after a real airborne stock-player descent onto the live pitched-roof body.
- `navy-chapel-187-actual-live-public-stock-walk.avi`: native MovieWriter output containing the five-second review interval. The stock player travels 19.879 m along the public front using only `move_right`, remains grounded in all 300 physics samples, keeps the camera fixed, and triggers no recovery. The AVI includes startup/settle frames; `motion-capture.json` identifies the exact useful process/physics interval.

The still harness resolves only the nodes attached by the actual main-scene world load and attaches no preview or standalone instance. `roof-landing.json` records the airborne-to-grounded landing, same-roof post-hit, cap collision hit, zero transform writes after descent began, and zero recovery delta.

The capture payloads remain immutable records from before the external verdict: `capture-manifest.json`, `motion-capture.json`, `roof-landing.json`, and capture-node metadata intentionally retain their packet-time `pending_independent_review` fields. Those fields prove that the producing harness did not self-grade. They are superseded for current acceptance only by the separately authored sealed live-review receipt; they must not be rewritten after review. The pre-review checksum ledger had SHA-256 `3b8cdd7d03b00d9d73d1a269657483bfb33ae6d9a9536d25a26278a41bb8df72`; the current ledger extends that evidence chain with the receipt and reconciled source contracts.

## Truth boundary

This accepted live replacement carries forward the standalone packet's bounded cues: the strong public gable, tall divided public window, shallow entry, pitched roof, belfry/cap/cross, and limited public-side opening family. The external reviewer accepted top-1 recognition and live believability for this exact presentation. Exact dimensions, pane counts, complete side cadence, private/rear design, interiors, operability, receiver completeness, game distinctiveness, and as-built fidelity are not claimed. No source photographs or URLs ship in runtime.

## Reproduction

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --audio-driver Dummy --script game/tests/headless_navy_chapel_187_live_replacement_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --audio-driver Dummy --script game/tests/headless_navy_chapel_187_live_replacement_package_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --audio-driver Dummy --script game/tests/headless_navy_chapel_187_live_replacement_evidence_contract.gd
```

Native stills were produced at 1440×900 with macOS/Metal/Forward+; MovieWriter used 1280×800 at fixed 30 fps. Source and fresh direct-mounted PCK package contracts are run twice before handoff. Exact identities are in `capture-manifest.json`, `motion-capture.json`, `roof-landing.json`, and `CHECKSUMS.sha256`.
