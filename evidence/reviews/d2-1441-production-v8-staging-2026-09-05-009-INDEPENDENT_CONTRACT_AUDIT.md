# D2 1441 Chinook Production v8 `-009` — Independent Mechanical Contract Audit

- Decision: **PASS_FOR_1441_PROMOTION_NO_CREDIT**
- Decision scope: independent mechanical and package-contract review of only the exact immutable `-009` packet, its captured source closure, and the packaged app bound below
- Reviewer: `/root/state_reconcile`
- Review date: `2026-09-07`
- Credit effect: none; accepted authority remains exactly `8/213`, and 1441 Chinook remains unaccepted and uncredited until a separate promotion transaction

## Exact candidate binding

- Evidence root: `evidence/first-playable/d2-1441-production-v8-staging-2026-09-05-009/`
- Inventory: exactly `40` regular files and no symlinks or unsupported entries: 14 static PNGs, 21 visual-motion PNGs, three JSON manifests, one packet-local capture override, and one copied package receipt
- Canonical packet tree SHA-256: `e52d66e479f268a9e75372da111d9c93cc1972dd1fddca9a6cb29bb6e41a4a43`
- Static capture manifest SHA-256: `3c11ba6412da6a062d89142594c7b785bf546b5c1905dc32bdd7ce7806fd6885`
- Consecutive telemetry manifest SHA-256: `21e2b60a8fee1bcfeb984ece6124684c15ae5b1be7fb8a813f18bc0c3b240fcd`
- Visual-motion manifest SHA-256: `c885f6450d3eaac4814bde83beff1bbdccea3ae992e07a62c1e9dd8fc1259cad`
- Package-verification receipt SHA-256: `cbcda89ec1e013c3406cf919d7c7e3bcefe0df7f005be1ea0e250bfbdada1061` (`10,034` bytes)
- Packet capture-override SHA-256: `edbc0b9caa60fa0fc6b83cebb3145bce11ce0bd976403ca1d2fbe9b7142b39c3`
- Capture generator SHA-256: `921acef14ef5503569f8d07bcafdb03f6bccf78570742a8a835962e845a858cf`

The canonical tree was independently recomputed over the exact newline-terminated inner `shasum -a 256` records, `<sha256><two spaces><./packet-relative-path>\n`, with all regular paths NUL-delimited and bytewise sorted under `LC_ALL=C`. The build-local receipt and copied packet receipt are byte-identical. The static manifest's embedded receipt is semantically identical to those bytes after JSON round-trip; the telemetry and visual manifests bind the same receipt hash.

### Packaged app

- App: `build/d2-1441-production-v8-staging-2026-09-05-009/Treasure Island First Playable.app`
- Exact seven-file bundle identity SHA-256: `81ae851ff3dffd90202e903939f1d6cda7eeb3cfff7e2c752492fa7ed0e1e129`
- Executable SHA-256: `e40c888a66f044c5a267ef027d94e99fd8009104462a7ca193b249b6fb6d7cfd` (`170,963,648` bytes)
- PCK SHA-256: `c7660d21680649d137af52e2057a23aaa7efab9292c4e427c3e2ef79d1ea80c3` (`66,163,452` bytes)
- Architectures: exactly `x86_64` and `arm64`

The bundle identity was independently recomputed from ASCII-bytewise sorted `relative_path\0sha256\0bytes\n` records. Its seven paths, hashes, and byte counts exactly equal `bundle_inventory`. Deep-strict and per-slice signing pass; entitlements are an empty dictionary; `Info.plist` and `PrivacyInfo.xcprivacy` validate; privacy tracking is false; no symlink, quarantine attribute, or other extended attribute exists. The app and packet trees were recomputed again after all audit runs and remained unchanged.

### Captured source closure

- `project.godot`: `305bfb3bf0493c485f48ea8a01d4effccb58d9dd74ad6dc9be78a64ed23981af`
- `game/scripts/main.gd`: `1c284eb4d8ee5954500fe36c3ab6845bc7233728da26f5f6848dd8de9a627232`
- `game/scripts/world/world_chunk_builder.gd`: `7107dc0789e8ca8ee13d53510293a39b3f64e9a92e0ee81bef7317d90a08a87a`
- Live config: `aef5717332cda1cf2ba1457ce9e9e92aaaceae46345595a979813b9369ad8111`
- Live adapter: `bf51562a211126c0ea7b631321dfb021171ad68bffd6dd07667ad504d770b9a1`
- Reviewed geometry factory: `6c0bf201bbb38a424453f753471cb7cb8060d0323e2386a9fda3bad84acd5933`
- Reviewed factory config: `ebb6be74a630ad405030938dc7d27bc6fed46b2d6892a847ee653d374df57f75`
- Shared Site 12 kit: `f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd`
- Live focused contract: `5a7e5f7e47e1168490b3a7ef37f9488499cd99540156b2009d9006f9fd559149`
- Live source-package contract: `73a7c945e1a6d2b425a2c829a60803010c6bd8dc374c7e45df592cbde5f5eefe`
- Production focused bridge: `6014498a52676ec93c955ccc672db3d6845c90a0b5e7dbfd1f05df3cf1792986`
- Production package contract: `cc2942797cda2c1cb2bef97bd2ef757fc993a6dfce223bbbd96d91e89230e580`
- Target chunk: `5e3b7efb7a2c61e1092c6a42ca9c04212c7d2603890b7a3f4c5e46777005f17b`
- Generated-world manifest: `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`
- `game/scenes/main.tscn`: `959a0f8a14057ea8402790ba374c7839d5f9835ce20ad194846f0a4d45b43d66`
- `game/scenes/world/world_root.tscn`: `ed6dfaa1933cedf2a70ca6afd677a645d588dbf6c823fb04402aaaea4b709ab8`
- Export preset: `e54969d6127ee55691113217e5129a7c5e9b3e841168a6b91f3fc74ba278456f`
- Deterministic receipt generator: `7f579e7bb347079d543e2e1360b7a6d24189ebd5af13cf5a41591db91e365a1a`

I recomputed all 38 dependency hashes in each of the three manifests and all 20 receipt source hashes from current bytes: all `134` recorded source references matched. A separate semantic pass also reconciled the receipt's six current-authority hashes, for `140` checked source/authority bindings overall. The package receipt derives its target from the config, adapter, and capture constants, not from a prior receipt, and its in-memory historical-typo mutation fails closed.

## Receipt, target, and causal closure

The receipt schema is exactly `ti.d2-1441-production-v8-package-verification/1`. Its target has exactly the required 12 fields and reconciles across the live config, adapter, capture generator, all three evidence manifests, and receipt:

- source `w95934105`, wall `building:w95934105:wall`, roof `building:w95934105:roof`, and physical unit `physical-building:w95934105`
- geometry signature `b91b373e3bb8238a6f73f05734ef48b3429ae5654eddce89b1981ee41ee89195`
- live ownership signature `fcad9968be3d0c9094adef5dcc9c7fabfb7cf1754f780897188a4ec362187e4d`
- canonical wall `00f3cd8b90e7ae93f802842b59bb10274f1fc388433e5b5c6cae1f3e23f4393c`
- canonical roof `e7da0179f012e928f575ac32440e176a0f3b9651fc325a594de80ce7e3fc9d55`
- mapped public SSE runs `[10,12,13,15]`, protected runs `[0,1,2,3,4,5,6,7,8,9,11,14]`, and confusion set `[w95934144,w95934143,w95934131,w95934129]`

This closes the prior `-004` blocker: the obsolete `b91b373edbb41d...` typo is absent from the accepted `-009` target and is explicitly rejected by both receipt and Godot mutation tests.

The receipt binds the exact app plus six verification logs, all independently rehashed from the retained bytes:

- bundle verification: `c2376545046e0043bffaeb5a89a739f1f84a519ad0074e23856ee098b794d6a2`
- source package contract: `7589d90f2f81bbc3f4ba30a1b7ba392117003af8644ccc3646842cc4b47cf1f2`
- mounted package contract: `d7282d8065fa3695a7f2ed29c6bdc78d9d73289118c10c7598abe5dc86db3f16`
- generic mounted-PCK content audit: `964cde177a23f6c4c18cc84dac961b19f09846d33126c62d8ab3b72ee6412d81`
- packaged headless main smoke: `dc588024f625125c5a28c1677dc5d10c4c6fa5f61776ba2afac00cbacde47956`
- packaged native Metal main smoke: `d64e40018bf46b57cc3c7964c5aecf35931f7d4cc50612c6bb52aecd2b9b1c9c`

Each bound log contains its required PASS marker and no script, package, PCK, or result failure marker. The native log records Godot `4.7.2`, Metal `4.0`, Apple M2, exact world readiness, visual/movement defaults, real jetpack rise/descent, and final PASS on the bound app. The receipt stores neither its own future hash nor downstream evidence/review hashes.

## Roof render and collision correction

Fresh focused Godot execution passed the roof-specific contract and its historical mutation. Independent source inspection confirms all required orientation facts:

- The factory first makes the authored roof lighting normal point upward, then emits each roof triangle as `[a,c,b]`. That produces Godot's clockwise visible front/top order while preserving upward vertex normals.
- The live adapter requires ordinary back-face culling, negative-Y mathematical raster winding for all ten Godot-clockwise roof triangles, and positive-Y lighting normals for every vertex.
- The collision split preserves the exact visual vertex order for all ten roof faces. The contract compares every visual and collision corner in order, not merely as an unordered vertex set.
- Top-down solid and spray-blocking rays hit the exact roof body with a positive-Y hit normal; the roof remains `receiver_kind=none`, outside `spray_receiver_wall`, while retaining truthful world-solid landing.
- An in-memory recreation of the historical reversed/CCW render indices is rejected by `roof_render_front_face_matches`.

The static roof capture independently reports support on `building:w95934105:roof`, world-solid landing, no spray ownership, real PlayerController jetpack input, zero player/camera transform writes, and zero recovery. The original-resolution frame visibly contains a substantial dark roof plane, an eave/edge, the grounded capsule, and its contact shadow; this is supporting mechanical legibility only, not a substitute for the separate visual review.

## Topology, ownership, interaction, and static evidence

All three manifests agree on ordinary-main world topology `735/959/974/69252/466/466`. The accepted B225 baseline remains `735/952/967/67716/466/466`; the sole live delta is `+0/+7/+7/+1536/+0/+0`. The replaced generic pair is `2/2/42/2/2`; the reviewed D2 pair is exactly `9/9/1578/2/2`, split into:

- wall `8/8/1568/1/1`, with exactly 32 structural collision triangles and sole wall-spray ownership
- roof `1/1/10/1/1`, with exactly ten solid, spray-blocking, nonreceiver collision triangles
- exactly 1,536 render-only decorative-relief triangles and zero decorative collision triangles

Fresh live and production focused contracts proved one supplied wall+roof pair is prepared, built, and consumed exactly once in either record order, with missing/duplicate/moved/drifted/third-member inputs rejected, no fallback or generic stack, deterministic reconstruction, exact material semantics, and ordinary-main integration.

All 14 static images match their paths, hashes, byte counts, `1440x900` dimensions, and PNG types. The 13 native RGB stills report real input-only travel/aim, stock camera, grounded/in-boundary state, exact first line of sight, zero player/camera transform writes, zero recovery, no source photography, and no crop/postprocess. The grayscale image is an 8-bit lossless derivation whose bound source is static frame 01. Frames 02/03 reuse the exact player/camera pose under materially changed light. The spray frame records a real `SprayController` placement on the sole exact wall owner and independently visible cyan/yellow tag pixels. The protected-return view binds run 11, while the four comparator views bind the declared confusion set.

## Consecutive and visual motion

Independent JSON and image validation passed the complete motion contract:

- Telemetry contains exactly `360` consecutive post-PlayerController input ticks at 60 Hz (`6.0 s`), frames `3283..3642` after baseline `3282`, followed by exactly 12 separately recorded braking ticks `3643..3654`.
- Every input sample is grounded, in boundary, center-hit on exact wall `building:w95934105:wall`, camera-basis stable, and monotonic in chain-u. Run, jetpack, recovery, player transform writes, and camera transform writes are all zero.
- Adjacent telemetry samples bracket all three exact joins at `u=10.583`, `15.223`, and `20.780 m`.
- The authoritative visual invocation used the engine request `--fixed-fps 60` before the project arguments and the user receipt `--fixed-fps-receipt=60`. The persisted payload accurately labels the latter as operator-invocation disclosure rather than pretending it is an engine observation. A wrong-receipt rehearsal failed closed; its retained log hashes to `67f25c81054703fdc8b3abe0783199cfa74ef79b3529788586255f52dfb9c32a`.
- The visual run releases real `move_right` input at sampler sequence `361`, exactly `360` controller ticks after baseline sequence `1`, then records exactly 12 braking ticks. It neither pauses simulation nor writes player/camera transforms or performs recovery.
- All 21 frames were queried after `frame_post_draw`, copied as Images in memory before the next physics await, and PNG-encoded only after input release and braking. The live input loop contains no PNG encoding or file write.
- All 21 frame paths, PNG hashes, actual engine frames, sampler sequences, and chain-u values are unique and strictly ordered. Each actual frame/sequence equals its trigger frame/sequence in this run. All images are 8-bit RGB PNGs at `1440x900`.
- The maximum measured `actual_u_m - threshold_trigger_u_m` is `0.0661554336547852 m`, safely below the unchanged `0.22 m` tolerance. Each join has five ordered adjacent frames with at least two negative and two nonnegative actual offsets; far, mid, and near frames are present.

The fresh production bridge's mutation matrix accepts only fixed FPS `60`, receipt string `"60"`, true in-memory staging and deferred encoding, and false live-loop writing. Missing/wrong receipt values, fractional FPS, disabled staging/defer, and enabled live writing all fail closed. The packet's own read-only validator also passes its exact 40-file disk round trip.

## Authority, compiler, generated world, and B225 invariants

Current authority is byte-exact and unchanged:

- catalog `d95be7bec8f0eabe97a9b5f7fefe1ce54ec7cbf940d85d28518ff6979eeb16ea`
- catalog schema `44584e92e1652fc930f47882b4a83304f5216c14173eb805bc9ce68ea9927cac`
- validation report `b52a83a8cad6c31828d4b5026359769e516d95e91079cc2a34aeef5ec801cf9b`
- runtime registry `109f83f40450e9c71ef6d39f1659e76eac5f1457fcfab772538b471cc74c0051`
- adapter contracts `dd2d13e3b0f6eee1f8c5f2957927c4f3caba43b31883beea925f9a91b826d65c`
- registry loader `12e6c64b23b0783ed240b3d6c02499c3940c2b6a14344caa29778b850db06c04`
- compiler `eee17772b1beb71b3d6bd87800035a0c1c47a7c80473014c578bb055a5ddf0c9`

Fresh compiler `--check`, compiler regression, and runtime-loader regression passes reproduce exact catalog/registry/contracts bytes and counts: 213 physical units, 214 receivers, 215 source records, 4,971 runs, seven active adapters, 16 plans, ten package-safe, six disabled, and recognition `8/213`. The 1441 unit remains `not_evaluated`, has zero acceptance records, zero authority adapters, and `all_receivers_generated_placeholder`. Exact packet, manifest, receipt, bundle, executable, PCK, and `-009` suffix values occur zero times in the v8 authority/compiler surface.

The checked-in generated world independently validates as 38 chunks, 739 source rows (`735+4`), content identity `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`, and exact manifest bytes above. The optional clean-world two-build wrapper could not start because this host PATH lacks the already-known `osmium` executable; this is a nonblocking audit-environment limitation, not a candidate discrepancy. It caused no repository or toolchain mutation. Current generated-state validation, compiler check-mode regeneration comparison, source/runtime contracts, and mounted PCK hashes all pass.

Fresh B225 focused, source-package, and direct-mounted package contracts pass. They preserve exactly one accepted B225 increment, accepted B225 topology `735/952/967/67716/466/466`, the exact semantic direct route and six-asset closure, while correctly distinguishing the current live world containing uncredited 1441 at `735/959/974/69252/466/466`.

## Package and cleanliness results

Fresh read-only source-package, source-focused, direct-mounted D2, generic mounted-PCK, B225 source/mounted, packet-validation, and packaged-headless runs all exit `0`. The generic mounted audit independently reports the exact PCK hash/size, 899 virtual files, 47 generated files, 38 chunks, generated identities, runtime resource graph, movement `4/20/30/40`, vegetation/pavement contracts, and zero private/raw/banned paths. Packaged headless main reaches exact world-ready topology, visual defaults, movement defaults, and real jetpack rise/slow descent.

The project-root `override.cfg` is absent and no Godot or packaged-game process remains. Packet JSON contains no host absolute path, home path, temporary path, file URI, credential marker, or private identifier. The packet has no reference to this review or the sibling `-009` visual review. Its only review dependency is the frozen upstream standalone bar-raiser receipt already included in the source closure, so the promotion review graph remains acyclic.

## Decision

The exact bound `-009` candidate is mechanically coherent, fail-closed, package-safe, and ready for a separate 1441 authority-promotion transaction. This audit grants no recognition credit, performs no promotion, and does not decide visual quality. Authority therefore remains exactly `8/213` at this boundary.

PASS_FOR_1441_PROMOTION_NO_CREDIT
