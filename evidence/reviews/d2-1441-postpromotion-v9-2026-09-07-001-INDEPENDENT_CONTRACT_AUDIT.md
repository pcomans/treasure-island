# D2 1441 Chinook postpromotion v9 `-001` — independent mechanical release audit

- Reviewer: `/root/v9_release_mechanical`
- Review date: `2026-09-07`
- Decision: **PASS_FOR_D2_1441_V9_RELEASE**
- Scope: mechanical, data-contract, package, runtime, interaction, motion, and provenance review of only the exact app and 40-file packet bound below
- Credit effect: none; current authority already contains the single reviewed `8/213 -> 9/213` promotion, and this downstream packet grants no additional recognition credit
- Visual boundary: this audit checks that the required images are exact, truthful, usable, and mechanically supported. It does not self-grade facade art or replace the separate independent visual review.

## Exact release-candidate binding

- App: `build/d2-1441-postpromotion-v9-2026-09-07-001/Treasure Island First Playable.app`
- Evidence root: `evidence/first-playable/d2-1441-postpromotion-v9-2026-09-07-001/`
- Evidence inventory: exactly `40` regular files, no symlinks, and no unsupported entries
  - `14` static PNGs
  - `21` visual-motion PNGs
  - `3` JSON manifests
  - `1` packet-local capture-override copy
  - `1` copied package-verification receipt
- Canonical packet-tree SHA-256: `60f9c875d3429347047525beab75310073e971af78e6445b551b6586a79cb45e`
- Static manifest SHA-256: `50ab60b3f509ac30b26dbb98ea03bf8f8cc4b1b4c4054f87204e8af6f16797d1`
- Consecutive telemetry SHA-256: `dbbe6f53bd6f176cf4760faa6684d306265327635fe6b53d8917bfa78ac2f171`
- Visual-motion manifest SHA-256: `5392cb8e2942fdeda033482c2658fd5a842c6d28abedf1ddfe7c7488664790ea`
- Package-verification receipt SHA-256: `61b63b0ad7aac01039e4f1e2125268c5e1900e047b3077e785c00893a85a6a59`
- Capture-override copy SHA-256: `edbc0b9caa60fa0fc6b83cebb3145bce11ce0bd976403ca1d2fbe9b7142b39c3`
- Capture generator SHA-256: `ab315b37b6a7f7f07105bc26f464d0d3e50c02b1d082e2643169eec47949214c`

I independently recomputed the packet tree from bytewise-sorted, newline-terminated inner `shasum -a 256` records over every `./packet-relative-path`. The build-local and packet-local receipts are byte-identical. The receipt embedded in the static manifest is leaf-for-leaf semantically identical after numeric normalization; Godot's JSON round trip spells integral values as exact `.0` numbers inside that embedded object. All three manifests bind the external receipt hash above.

## Packaged app identity and macOS integrity

The app contains exactly the following seven regular files. Each path, SHA-256, and byte count independently matches the receipt.

| Bundle path | SHA-256 | Bytes |
|---|---|---:|
| `Contents/Info.plist` | `12210013168f4197b156c151636a81d27285741b3d2cdd138740d09853a9f085` | 1,885 |
| `Contents/MacOS/Treasure Island First Playable` | `cf0bd6e789e9317248b1aeb2eb626cfd76b837fef362eca449336644cff77941` | 170,963,648 |
| `Contents/PkgInfo` | `7e50a30efad50208a173203ced60818d693bb61266b75aa10927d1a2adce80cb` | 9 |
| `Contents/Resources/PrivacyInfo.xcprivacy` | `0535353bb08c25b8ce5ed9ac7e442a5994f402e0f6cbc4bed668cfc63c2ceac3` | 229 |
| `Contents/Resources/Treasure Island First Playable.pck` | `0945ac7b08ebd2fc5389ffa05a919b7324ecb298dac46032c8fdc30d8c47404a` | 66,300,344 |
| `Contents/Resources/icon.icns` | `779ff524928785811d6d4c61f47a26491160b1092db9b610e85fcdfd9b2d2b2a` | 67,500 |
| `Contents/_CodeSignature/CodeResources` | `8336609812f8569de4527ee0940017cb30c7cb2776dd4775c2c18a4bc4a0955e` | 3,217 |

The canonical ASCII-relative-path/NUL/hash/NUL/byte-count/LF identity is `f83ddd5678086099d66fc433c0851fc2788c42e702d8bffac4eee4d7a7d595cb`. Independent `file` and `lipo` inspection reports exactly `x86_64` and `arm64`. Deep-strict signing and both per-architecture signature checks pass. The bundle and both slices have an empty entitlement dictionary. `Info.plist` and `PrivacyInfo.xcprivacy` pass `plutil`; the bundle identity is `local.treasure-island.first-playable`, version `0.1.0`, package type `APPL`, and privacy tracking is false. There are no extended attributes or quarantine attributes.

The generic mounted-PCK audit was rerun from `/private/tmp`, not beside the source project. It proves that the explicit PCK has the exact hash and size above, `905` virtual files, `47` generated-world files, all `38` chunks, generated manifest `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`, generated content `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`, `739/735/4` total/playable/context rows, all required runtime resources, movement `4/20/30/40`, physical Space, and `private_paths=0`, `private_raw=0`, `banned=0`.

## Receipt, source closure, and acyclic provenance

The three manifest dependency maps are identical and contain exactly `40` entries each. I rehashed all `120` recorded manifest dependencies from current bytes. I also rehashed all `47` receipt `source_hashes`, all six repeated `current_v9_authority_hashes`, and all eleven bound verification logs. Every value matches.

The eleven retained log hashes independently match the receipt:

- bundle verification `19e3f9c745801f2ea38bf72a579f48d8b0a0d1b3b9cc63655eb63d6fce02220a`
- export `59b320dfefe7f9e2c201dbc5801e697aa1842ca1bb6b2a0260b88184d711c4e6`
- compiler check `a514eaa664767c73977f5c7c6e99de810c47bc03cb7446fae2b9cb7fe34d6dd3`
- compiler mutation suite `01a1f39215449201114b1bb47d65e681ffea3b12d30d27426555a5b36b06fd39`
- loader mutation suite `363f5e4a4ee421eb68c30045025496f5f087bd4165ae8c0a1ff50105a16bfd29`
- focused source contract `7f253ee9c3821e9d0d3f95cf679905678278eaa4e2d72cd8ff14b4f536c0235a`
- source package contract `f1eed7cb0807f51c514137ec6cd9bd8648ce8446cb20a1ac7993c6a6c8296bde`
- mounted package contract `08b4cf942ba49c3c9025d94bfc59831b5b3c2f011d96bd91f1fc1c8e676b1771`
- generic mounted-PCK audit `fe867bf46bdddb85f51d558c313149c69bf6f545e3df92e58e2b87d84312045f`
- packaged headless smoke `d5ec6c5670f9ad5e42f4bb405949a5ea21531dc2b09f23f2ac129e6fbfd92e09`
- packaged native-Metal smoke `af63ed4a6a9c075ee094872b3c6e21e047889d5fcba2a57b20f78586b6f7218f`

Each bound log contains its expected pass marker and no failure marker. Two separately retained `initial-cwd-failed` logs are explicitly not bound by the receipt; they document source-project mount-boundary operator mistakes, not candidate results.

The upstream semantic audit is exact at `3388576780493b6116c126684072426ad22279b9a3508127a0ffc8bcb77f9700` and ends with raw verdict `PASS_FOR_V9_POSTPROMOTION_EXPORT`. The receipt is generated from current source/app/log inputs, stores neither its own hash nor an absolute PCK path, and binds no downstream postpromotion review. Searches across the current catalog, schema, report, registry, adapter contracts, loader, compiler, and upstream semantic audit find none of this packet's tree/manifest/receipt/app/PCK/executable hashes. The direction is therefore frozen prepromotion evidence and reviews -> v9 authority -> semantic audit -> v9 app/receipt/postpromotion packet -> independent release reviews. There is no reverse edge or sibling-review edge.

Packet JSON and override bytes contain no workspace/home/temp absolute path, username, file URI, credential marker, token pattern, or private identifier. The raw-PCK and decompressed resource-graph audits independently report no private or banned source paths.

## Current authority and exact one-unit accounting

Current authority hashes are:

| Artifact | SHA-256 |
|---|---|
| Catalog | `dc6d121d48621f98a203f2fea458316a46446a11e5f2a77d4064694322b2baa2` |
| Catalog schema | `8896fb9dcfd1cb48fc4bf0ed7ddc5fa50fdf7ec31335111291a1e2a2006e106d` |
| Validation report | `bc12d0e95917c650e47d7c6c008345328ed2c3ddb49744613359073999a9d3bb` |
| Runtime registry | `26dcf64a34cf92aa7766c60940933190cdb5f9bc595dc23dc2f16fa01752e16c` |
| Adapter contracts | `8c61ea5601ab94852ac593b8658963b52cb5253aae22a2ff109f2e46771caa93` |
| Registry loader | `32e63c8774c0589856f15ac2ca0e7458e1cdce1403380e50a6ba99bd5185bd26` |
| Compiler | `4d6da1afa587d2dd8aefb24775d6ba838dd39ac60131985c9c899209572d3e74` |

The coordinated versions are compiler `1.8.0`, catalog/runtime schema `9`, adapter-contract schema `8`, and loader API `8`. Exact inventory is `213` physical units, `214` direct wall receivers, `215` source-record memberships, and `4,971` wall runs. Runtime authority contains eight active adapters and seventeen plans: eleven package-safe and six hard-disabled. Recognition is exactly `9/213`: nine accepted and 204 not evaluated.

`physical-building:w95934105` has exactly one accepted record with capture-time metric `8/213` and numerator effect `+1`, plus exactly one active wall-indexed route, `active-adapter:d2-1441-live:building:w95934105:wall`. There is no roof-indexed adapter, second receiver, relief unit, composite unit, duplicate record, or extra credit. The roof is behavior-bound to the same physical building while remaining a non-spray recognition non-owner. Compiler, Node, Godot, and direct-mounted mutation gates reject duplicate credit, forged roof credit, route drift, missing assets, version drift, and topology-scope drift.

The postpromotion packet correctly says `recognition_credit=false`, `additional_recognition_credit=false`, and `promotion=false`: current v9 authority already accepted the unit, while this downstream packet performs no new promotion. The live adapter's embedded prepromotion metadata remains frozen no-credit provenance; the v9 registry and bridges supply the distinct current-authority layer.

## Topology, replacement, collision, and interaction

All current manifests, receipt, source/runtime bridges, mounted package, and packaged-main smokes agree on `735 rows / 959 meshes / 974 surfaces / 69,252 triangles / 466 bodies / 466 shapes`. B225 retains `735/952/967/67,716/466/466` under `pre_d2_1441_integration_live_parity`. D2 1441 alone owns `current_integration_topology`. Earlier accepted scopes remain unchanged: Isle House and Navy Chapel `735/944/957/64,572/466/466`, and B201 `735/950/964/66,636/466/466`.

The generic D2 wall/roof pair `2 meshes / 2 surfaces / 42 triangles / 2 bodies / 2 shapes` is atomically replaced by the reviewed pair `9/9/1,578/2/2`. The sole world delta over B225 is `+0 rows / +7 meshes / +7 surfaces / +1,536 triangles / +0 bodies / +0 shapes`. The pair splits into:

- wall: `8` meshes, `8` surfaces, `1,568` visual triangles, one body/shape, and exactly `32` structural collision triangles;
- roof: one mesh/surface, `10` visual triangles, one body/shape, and exactly `10` collision triangles;
- decorative relief: `1,536` visual triangles, zero collision triangles, and zero navigation owners.

The current focused contract rebuilds the actual supplied pair in both record orders, checks deterministic identity, consumes each member once, rejects partial/duplicate/moved/drifted/extra inputs and fallback/stack paths, verifies ordinary-main ownership, and ray-tests wall/roof solidity and spray layers.

For the roof, source inspection and fresh execution agree: the factory first makes the authored lighting normal positive-Y, then emits each roof triangle in Godot's visible clockwise order `[a,c,b]`. Every visual triangle has negative-Y mathematical cross-product winding while every vertex lighting normal remains positive-Y. The collision split preserves the same ordered corners for all ten faces. A historical reversed-render mutation is rejected. Top-down solid and spray-layer rays hit the exact roof body with a positive-Y normal, but that body has `receiver_kind=none` and is not in `spray_receiver_wall`.

Static frame 10 reports real PlayerController jetpack input, grounded support on `building:w95934105:roof`, zero transform writes and recovery, and a positive-Y roof normal. Original-resolution inspection shows a substantial visible dark roof plane, the player capsule, its contact shadow, and surrounding context; the landing is not an edge-only metadata claim.

Static frame 09 reports a real `SprayController.attempt_spray` result of `placed` on the sole exact wall owner `building:w95934105:wall`, source `w95934105`, with the tag present in the tree and visible cyan/yellow tag pixels around the projected hit. Frame 08 binds the deliberately protected run-11 return next to the selected SSE treatment. The target contract consistently maps runs `[10,12,13,15]` and protects `[0,1,2,3,4,5,6,7,8,9,11,14]`.

## Static and motion evidence integrity

All 35 PNGs match their manifest paths, SHA-256 values, byte counts, PNG signatures, and `1440x900` IHDR dimensions. The 13 native static stills and all 21 motion frames are 8-bit RGB; the lossless grayscale derivative is 8-bit grayscale and binds static frame 01 by exact hash. All 35 image hashes are unique. Static frames 02 and 03 reuse the same player/camera pose under materially changed light.

Every non-derived static view reports real input-only travel and aim, stock `70°` FOV and `5.5 m` spring configuration, grounded/in-boundary state, exact first-line-of-sight receiver/source, zero player/camera transform writes, zero recovery, no crop/postprocess, no camera trick, and no source photography. The set includes whole, oblique, changed-light, grayscale, close cue, gable/eaves, context, protected return, spray, roof landing, and all four declared confusion comparators.

Consecutive telemetry contains exactly `360` post-PlayerController samples at `60 Hz` (`6.0 s`) after baseline engine frame `3283`: samples occupy frames `3284..3643`, followed by exactly twelve separately recorded braking frames `3644..3655`. Sample indexes, sampler sequences, and engine frames are consecutive. Every input and braking sample is grounded, in bounds, camera-basis stable, recovery-free, centered on exact wall `building:w95934105:wall`, and monotonic in chain-u. Run, jetpack, and recovery input remain false. Player and camera transform-write counts are zero.

Adjacent consecutive samples cross all three signature joins at `u=10.583`, `15.223`, and `20.780 m`. The visual invocation records fixed-FPS request `60` and exact receipt string `"60"`, explicitly labeled as an operator invocation disclosure rather than an engine observation. Input release occurs at sampler sequence `361`, exactly 360 controller ticks after baseline sequence `1`, followed by twelve braking samples.

All 21 post-draw frames have unique paths, hashes, engine frames, sampler sequences, and strictly increasing chain-u values. Each was queried after `frame_post_draw`, copied to an in-memory `Image` before the next physics await, and encoded only after input release and braking; the live input loop performs no PNG encoding or file write. The maximum measured `actual_u_m - threshold_trigger_u_m` is `0.0661554336547896 m`, below the `0.22 m` gate. Each join has five ordered adjacent frames and at least two actual frames on each side under the manifest's `±0.02 m` before/after classification; six additional far/mid/near frames span the route.

## Fresh independent execution

Fresh audit execution passed:

- Godot `4.7.2.stable.official.ed1daf0bf` editor import/parse;
- compiler `--check`, compiler mutation suite, and loader mutation suite;
- startup, four-scene parse, gameplay/input, all eleven semantic materials, generated-world, Building 1 hero, registry, and loader Godot gates;
- current D2 v9 focused and source-package bridges, plus the bounded native Apple M2 Metal 4.0 focused gate;
- full real-main runtime at `959/974/69,252/466/466`, including walk/run, unlimited hold-to-rise jetpack and capped released descent, camera, boundary/recovery, real spray placement and rejection, reload failure, and clean teardown;
- default continuous route: `262.349 m`, fourteen checkpoints, zero recoveries/stalls/boundary failures;
- whole-island route: `3,449.107 m`, five landings, maximum step `0.348 m`, zero teleports/recoveries/boundary failures;
- independent Node world validator: 38 chunks, 739 rows, content `01af105e...`, 206,339 coherent-surface samples, 14,904 foundation samples, 214 roof cells, and 124 vegetation instances;
- Building 1 exact 110-run ownership partition and its current hero-world topology `735/959/974/69,252/466`;
- current v9 direct-mounted package contract and generic mounted content/privacy audit;
- packaged headless and native Metal/Forward+ main smokes, each reaching exact world-ready topology and exercising movement defaults plus jetpack rise `2.751 m` and slow descent `0.300 m`;
- frozen B225 v8 direct-mounted package contract at exact `8/213` and its six-asset closure;
- packet's own read-only `validate` mode, which independently accepts exactly 40 acyclic files.

One source-only prepromotion validator was inadvertently invoked against v9 and correctly rejected the new authority because its historical assertion requires v8 `8/213` with 1441 unaccepted. It is not a current gate and is not counted as a pass. Its current v9 successor and the appropriate frozen mounted fixture both pass.

## Frozen input and final cleanliness

The immutable prepromotion `-009` packet remains exactly 40 files with tree `e52d66e479f268a9e75372da111d9c93cc1972dd1fddca9a6cb29bb6e41a4a43`; its static/telemetry/visual/receipt hashes remain `3c11ba64...`, `21e2b60a...`, `c885f645...`, and `cbcda89e...`. Its two promotion-review receipts remain `c39800b1...` and `075dfb63...`. Its app identity remains `81ae851ff3dffd90202e903939f1d6cda7eeb3cfff7e2c752492fa7ed0e1e129`, executable `e40c888a...` (`170,963,648` bytes), and PCK `c7660d21...` (`66,163,452` bytes). Reviewed config, adapter, factory, builder, frozen focused bridge, frozen package bridge, and frozen capture generator all match their v9-bound hashes.

After all audit runs, the postpromotion packet tree, its three manifest hashes, receipt, seven-file app identity, executable, and PCK rehashed unchanged. Project-root `override.cfg` is absent; no Godot or game process remains; and `git diff --check` passes.

No mechanical release blocker was found.

PASS_FOR_D2_1441_V9_RELEASE
