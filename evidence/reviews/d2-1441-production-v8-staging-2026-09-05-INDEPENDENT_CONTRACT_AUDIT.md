# D2 1441 Chinook Production v8 Staging — Independent Mechanical Contract Audit

- Decision: **HOLD_NO_PROMOTION_NO_CREDIT**
- Decision scope: independent mechanical review of only the exact immutable `-004` production packet, captured source closure, and packaged app bound below
- Reviewer: `/root/b225_contract_audit`
- Review date: `2026-09-05`
- Credit effect: none; current authority remains `8/213`, and 1441 Chinook remains unaccepted and uncredited

## Exact rejected-packet binding

- Evidence root: `evidence/first-playable/d2-1441-production-v8-staging-2026-09-05/`
- Frozen packet: exactly `40` regular files: 14 static PNGs, 21 visual-motion PNGs, three JSON manifests, one packet-local capture override, and one copied package receipt
- Canonical packet tree SHA-256: `3a68fffd0f8dfe606667e83d954e2a53af3303c98da4aad200e112fce99e2d16`
- Static capture manifest SHA-256: `d22ec4ecaec51c58b85014798c98d4935530ecbf2e3491470265da87fae0fc7f`
- Consecutive telemetry manifest SHA-256: `18d5f91592564adb07ab3db75e072e4b56c4793b4119b62282c69a8334885895`
- Visual-motion manifest SHA-256: `ec80cca9bfe7324957d7dd367db3fb41e11f1dc993075936274e16056cba2403`
- Package-verification receipt SHA-256: `1f6ea93b575a0a9e55b439a4b491279ee586417e13ed61ba1de4b3b7f49b53f1`
- Packet capture-override SHA-256: `edbc0b9caa60fa0fc6b83cebb3145bce11ce0bd976403ca1d2fbe9b7142b39c3`
- Capture generator SHA-256: `4528e81567df1c2ca76016d1e85700e6bc5c46dd230ef38b959e6a5b21b1d435`

### Packaged app

- App: `build/d2-1441-production-v8-staging-2026-09-05-004/Treasure Island First Playable.app`
- Seven-file bundle identity SHA-256: `37d04f282ec791e54fe483e412c7fd730b300eee31f3f1c8819f1b78037b70e0`
- Executable SHA-256: `eb300c78a9ac79f248d924d450e3120477871a3f1cc7298d3c79d9c34f9f9f1a` (`170963648` bytes)
- PCK SHA-256: `f8ba980cb54d524d72c79e4a32bac2593559cc7fd998bd48e0feb145761f2342` (`66151916` bytes)
- Architectures: exactly `x86_64` and `arm64`

### Captured `-004` source closure

- `project.godot`: `305bfb3bf0493c485f48ea8a01d4effccb58d9dd74ad6dc9be78a64ed23981af`
- `game/scripts/main.gd`: `1c284eb4d8ee5954500fe36c3ab6845bc7233728da26f5f6848dd8de9a627232`
- `game/scripts/world/world_chunk_builder.gd`: `7107dc0789e8ca8ee13d53510293a39b3f64e9a92e0ee81bef7317d90a08a87a`
- `game/resources/facades/d2_1441_chinook_live_replacement.json`: `aef5717332cda1cf2ba1457ce9e9e92aaaceae46345595a979813b9369ad8111`
- `game/scripts/world/facades/d2_1441_chinook_live_replacement.gd`: `de5b0886b51f8aa3ea031c77d2fd130ec0bc51d4d1bd4ab4b4c661f125f6660f`
- `game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd`: `df3b644c4a708d53b2fd2c7cb8862cb922da5c2033b824e88b80877da311542d`
- `game/resources/facades/d2_1441_chinook_standalone_hero_prototype.json`: `ebb6be74a630ad405030938dc7d27bc6fed46b2d6892a847ee653d374df57f75`
- `game/scripts/world/facades/site_12_housing_kit.gd`: `f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd`
- Live focused contract: `f3ac6e81d9db0fa2c17d988acb7d6a95f7d17b63d89de99455271ee83fbba295`
- Live source-package contract: `368e68f621f7e1754c71496a66b484fd8b02cbc6f2e3640e4896d6f560a44bfa`
- Live replacement contract: `bdb38e706624adbb8a01e655aaeaf8f3b67a14c76048e6ef06bda735ea7b67b8`
- Live replacement package contract: `98ca044d298b21ee98273bbec6bada18ddafa1b2cbf1188a5d3564c630178447`
- `export_presets.cfg`: `e54969d6127ee55691113217e5129a7c5e9b3e841168a6b91f3fc74ba278456f`
- Target chunk `generated/world/chunks/x_-1__z_-1.json`: `5e3b7efb7a2c61e1092c6a42ca9c04212c7d2603890b7a3f4c5e46777005f17b`
- Generated-world manifest: `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`
- `game/scenes/main.tscn`: `959a0f8a14057ea8402790ba374c7839d5f9835ce20ad194846f0a4d45b43d66`
- `game/scenes/world/world_root.tscn`: `ed6dfaa1933cedf2a70ca6afd677a645d588dbf6c823fb04402aaaea4b709ab8`
- Frozen standalone bar-raiser review: `8b259934a3771642efb5902c1fcbba590613e8f1f80e4b7d00a1b4a391862c55`

These are the `-004` capture-time source identities, independently matched before the later authorized fresh-suffix remediation began. They are not attributed to that later worktree state.

### Current unchanged v8 authority

- Catalog SHA-256: `d95be7bec8f0eabe97a9b5f7fefe1ce54ec7cbf940d85d28518ff6979eeb16ea`
- Catalog schema SHA-256: `44584e92e1652fc930f47882b4a83304f5216c14173eb805bc9ce68ea9927cac`
- Validation report SHA-256: `b52a83a8cad6c31828d4b5026359769e516d95e91079cc2a34aeef5ec801cf9b`
- Runtime registry SHA-256: `109f83f40450e9c71ef6d39f1659e76eac5f1457fcfab772538b471cc74c0051`
- Adapter contracts SHA-256: `dd2d13e3b0f6eee1f8c5f2957927c4f3caba43b31883beea925f9a91b826d65c`
- Registry loader SHA-256: `12e6c64b23b0783ed240b3d6c02499c3940c2b6a14344caa29778b850db06c04`
- Compiler SHA-256: `eee17772b1beb71b3d6bd87800035a0c1c47a7c80473014c578bb055a5ddf0c9`

Authority remains catalog/registry schema 8, adapter contracts/loader API 7, compiler `1.7.0`, and exact recognition `8/213`. It contains no 1441 Chinook acceptance, adapter, or credit. This receipt deliberately binds neither a visual review nor its own future hash.

## Blocking inconsistency

The package receipt's `d2_target.geometry_signature` asserts:

`b91b373edbb41d5bf8ec67517b2150a519022a25466f66d9b6ca609834689195`

The authoritative reviewed/live/captured D2 geometry signature is instead:

`b91b373e3bb8238a6f73f05734ef48b3429ae5654eddce89b1981ee41ee89195`

The incorrect assertion is in `package-verification-receipt.json` line 139 and is copied into the static manifest's embedded receipt at line 1794. The correct value is independently present in the live configuration and adapter, frozen standalone configuration and contracts, capture generator, and all three packet manifests' top-level `bindings.geometry_signature`. A repository-wide definition scan found no valid alternate geometry signature; the incorrect value occurs only in rejected `-002`, `-003`, and `-004` receipt lineage.

This is an identity failure, not a cosmetic typo: the immutable `-004` packet simultaneously binds two different signatures for the geometry it claims to prove. The persisted packet validator accepted it because its package-receipt checks cover schema, topology, authority/credit state, acyclicity, and the receipt hash, but do not cross-bind `d2_target.geometry_signature` to the manifest/live geometry signature. The exact receipt and packet therefore cannot support promotion.

## Checks that otherwise passed

Independent recomputation confirmed the exact 40-file tree and every manifest, receipt, override, PNG, app-inventory, executable, PCK, captured-source, and authority hash above. All 35 PNGs match their embedded hashes, byte counts, unique filenames, and `1440x900` dimensions.

The ordinary production path otherwise reports exact topology `735/959/974/69252/466/466`, target `w95934105`, wall `building:w95934105:wall`, and roof `building:w95934105:roof`. The factory pair remains exactly `9/9/1578`, with wall `8/8/1568`, roof `1/1/10`, 32 wall collision triangles as the sole spray receiver, ten solid roof collision triangles with no receiver, and 1,536 non-collision relief triangles. Protected runs, pair identities, production metadata, activation count zero, no harness factory/adapter call, and no fallback all reconcile.

Telemetry contains exactly 360 consecutive post-player movement samples over 360 ticks and 6.0 seconds, followed by 12 braking samples. Chain-u is strictly monotonic; all three joins have true adjacent brackets; every sample remains grounded, in boundary, and on the exact receiver; player/camera transform writes and recovery are zero. All 21 unique post-draw frames are coherent with their sampled state and provide the required join brackets.

Fresh source, mounted-target, generic mounted-PCK, and packaged-headless checks passed. The app contains exactly seven regular files and no symlinks. Its package inventory, universal slices, deep/per-slice signing, empty entitlements, plist/privacy validation, absence of quarantine/xattrs, ordinary main route, private-route exclusions, and v8/no-credit snapshot otherwise reconcile. The project-root override is absent and no Godot/game process remains.

## Decision

**HOLD_NO_PROMOTION_NO_CREDIT.** Preserve the exact `-004` app and 40-file packet as rejected, immutable history. They cannot authorize 1441 promotion because their bound package receipt asserts a different geometry signature from the authoritative source and evidence bindings. A fresh suffix must be generated from a deterministic receipt whose target signature is cross-checked against the live/capture binding, then independently audited. Current authority remains exactly `8/213`; this review grants no recognition credit and performs no promotion.
