# Isle House Variant C — actual-live replacement evidence

Status: technically sealed and pending independent exact-current live review. This packet does not self-grade recognition or believability and does not change the recognition numerator.

The world builder now selects one package-safe Variant C attachment for exact low wall receiver `building-composite:w1249412094:w1282547787:wall`. It replaces the rejected `5/5/1844` live overlay; it is never stacked with it and has no fallback to it. The accepted high receiver `w1282547786` remains unchanged.

The promotion authority is the standalone Variant C `PASS` review with SHA-256 `b9877edb51eb9cc09bfd08f33d2664d7d3de08736daa2b96dc6e36c60d0fb5e5`. Runtime stores that opaque digest but no evidence/discovery path or URL. The approved repair signature remains `41868b77a8b51b56ee7381e5549423e97547270d2dc77d9ce5cf958b31e2cb69`; the actual-live wrapper signature is `09eee1517f043c6d82f0de0d2275da5b2a3f76f5842d1b9c90cba11e6e793981`.

## Measured integration

- Replacement overlay: 7 mesh instances, 11 surfaces, 2,242 triangles.
- Exact low record including its unchanged generic receiver: 8 mesh instances, 12 surfaces, 2,268 triangles.
- Whole world: 735 playable rows, 940 meshes, 954 surfaces, 64,118 triangles, 466 static bodies, 466 shapes.
- Delta from the rejected-live exact-current parent `735/938/948/63720/466`: `+0/+2/+6/+398/+0`.
- Decorative collision, navigation, and spray ownership: zero. The underlying `w1282547787` wall remains the sole collision and spray receiver.
- Accepted high signature: `e624a40551efb5bb5b137b731ebcd4ffbdcafbb70e8c5560c5cc07e8c10637a1`.

The global `full_runtime_integration.gd` oracle intentionally remains at the accepted pre-Isle-review state `735/933/943/61876/466`; therefore its `940/954/64118` mismatch is expected until an independent exact-current live verdict authorizes a global repin. Catalog, registry, and recognition counts are intentionally unchanged.

## Native evidence

- `images/01-wsw-whole-composite-default.png`: grounded stock-player whole high+low composite, default light.
- `images/02-wsw-whole-composite-changed-light.png`: the exact same player/camera pose under frozen changed light.
- `images/03-ene-public-supplemental.png`: grounded ENE public-side supplemental view.
- `images/04-nnw-quiet-return-direct.png`: grounded direct check of the quiet protected NNW return.
- `isle-house-variant-c-actual-live-public-corner-stock-walk.avi`: native MovieWriter output. The review interval is a continuous five-second, 300-physics-sample stock-player walk across the WSW runs 2/3 corner: 19.8834915 m, all samples grounded, no recovery, no player transform write after input began, fixed camera orientation. The AVI contains 222 encoded frames at 30 fps including startup/settle frames; the manifest identifies the exact motion interval.

Every frame resolves the actual world-attached `IsleHouseCompositeRepairVariantCLiveAttachment`; the harness attaches no preview or standalone geometry. The still manifest includes receiver/source LOS and useful high+low screen projection for the WSW whole-composite pose. The motion manifest records every physics sample and is sealed after MovieWriter close.

## Truth boundary

The packet carries forward the approved Variant C source boundary: no exact upper opening/floor/story schedule, no literal seven-story geometry claim, no NNW opening schedule or as-built private cladding claim, no private/rear schedule, no roof alteration, no interiors or operability, and no as-built-fidelity claim. Lower module order and dimensions remain reversible production inference. Source photographs and URLs are not packaged.

## Reproduction

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_isle_house_low_live_integration_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_isle_house_variant_c_live_replacement_package_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_isle_house_variant_c_live_replacement_evidence_contract.gd
```

Native captures were produced at 1440×900 with macOS/Metal/Forward+; MovieWriter used a 1280×800 target at fixed 30 fps. The source and direct-mounted PCK package contracts are run twice before handoff. See `capture-manifest.json`, `motion-capture.json`, and `CHECKSUMS.sha256` for exact identities.
