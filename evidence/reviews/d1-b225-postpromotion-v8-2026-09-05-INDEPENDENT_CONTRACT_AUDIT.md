# D1 B225 Postpromotion v8 — Independent Mechanical Contract Audit

- Decision: **PASS_FOR_RELEASE_NO_ADDITIONAL_CREDIT**
- Decision scope: independent mechanical release approval for only the exact postpromotion v8 evidence packet, current authority closure, and packaged app bound below
- Reviewer: `/root/b225_contract_audit`
- Review date: `2026-09-05`
- Credit effect: none; the current authority already includes B225 at `8/213`

## Exact binding

- Evidence root: `evidence/first-playable/d1-b225-postpromotion-v8-2026-09-05/`
- Frozen packet: exactly `37` regular files
- Canonical packet tree SHA-256: `7b0de99e6f4afe07b1767c522517ace3dc1729a3f82f4b9b95716de9483cbd84`
- Static capture manifest SHA-256: `25948a6f3478534d2b8080ead6ea42bb74ca9c6b79226ac066bcf262ca8bfef0`
- Consecutive telemetry manifest SHA-256: `e0b8457666ada91055c4e17d21c359593a0991dae2202d5d1094ae62f81c6753`
- Visual-motion manifest SHA-256: `e7c26ce099aa7595864f5298ab15cc4ddde14a68aedb66c7424d24fbb36b1c1f`
- Package-verification receipt SHA-256: `160d48acdc71687fd46ea3c14d91723e897e4930a59ffb6504b2d621d776cc1c`
- Packet capture-override SHA-256: `edbc0b9caa60fa0fc6b83cebb3145bce11ce0bd976403ca1d2fbe9b7142b39c3`

### Packaged app

- App: `build/d1-b225-postpromotion-v8-2026-09-05-001/Treasure Island First Playable.app`
- Seven-file bundle identity SHA-256: `3f38c5dcd55b19f12cf7788e1069367075aa22f1b557c5b61288abdfdc30afe0`
- Executable SHA-256: `c485010419591a9556e849e79755d7e816f840e31978c10b371be08a730e2d82` (`170963648` bytes)
- PCK SHA-256: `7315bba99efeeeb86be0bbf44876d391b9c1c95f1638318e0df2b7af367669bf` (`66073188` bytes)
- Architectures: exactly `x86_64` and `arm64`

### Current authority, implementation, and evidence producers

- Catalog SHA-256: `d95be7bec8f0eabe97a9b5f7fefe1ce54ec7cbf940d85d28518ff6979eeb16ea`
- Catalog schema SHA-256: `44584e92e1652fc930f47882b4a83304f5216c14173eb805bc9ce68ea9927cac`
- Validation report SHA-256: `b52a83a8cad6c31828d4b5026359769e516d95e91079cc2a34aeef5ec801cf9b`
- Runtime registry SHA-256: `109f83f40450e9c71ef6d39f1659e76eac5f1457fcfab772538b471cc74c0051`
- Adapter contracts SHA-256: `dd2d13e3b0f6eee1f8c5f2957927c4f3caba43b31883beea925f9a91b826d65c`
- Registry loader SHA-256: `12e6c64b23b0783ed240b3d6c02499c3940c2b6a14344caa29778b850db06c04`
- Compiler SHA-256: `5a3924a22f1242c8a6e7c94a4ae81809ec17c26f53a59bffd7835b5701da7365`
- Postpromotion source bridge SHA-256: `fd63ced9552dd9a1749de0047d2cebd1b46a1b093ebe1645dd4fcace19186353`
- Postpromotion package contract SHA-256: `6d2d05e28657b5de89bce0cea0c70819b791d886921f4a057c80cf548713cbcc`
- Postpromotion capture generator SHA-256: `6c709d81038ce9563181e57db364f11c1ad64d84e7c91e0c78c8ef087c052105`
- `project.godot` SHA-256: `305bfb3bf0493c485f48ea8a01d4effccb58d9dd74ad6dc9be78a64ed23981af`
- Canonical `main.gd` SHA-256: `14468a67c4dc8d56394b98515c61e7425c130ef74297624bb205957f6a834140`
- `WorldChunkBuilder` SHA-256: `de4a2924d275a51dfd08aae1f0ef21daac33395b1fcfe98e260fbc90737dd725`
- B225 configuration SHA-256: `80b42c33fce84361aa7512f64305f5bff273e8fed95640ca4f9c19d49d55621d`
- B225 live attachment SHA-256: `4b1defd92a77b23de692437f044dfaa579fa2ee5b3dee77465ec8404f1644ac9`
- Cladding material SHA-256: `7fa7f3165dee560c48f5a092f317900b87b0876f27bb6a0e937b9c406a8d4ea1`
- Cladding albedo SHA-256: `63e755e9fe5a5dcfb662b4265f1e769fc1b371987b55579b1ca4ffb63015015b`
- Shared dark glass SHA-256: `ad8931db8954fd5ebc8fdd809f70afb279dd74a36e53e1d9ca907c44409f10d3`
- Shared pale frame SHA-256: `9a2de298ff545cf80c5da0ed0aa37d9d4ebbf10fec8eb78810af7e4d012d1436`

The prior production-path acceptance remains immutable: v7 capture manifest `96c76fd99960f1345a7c56f7fc6678ac284f98cc601a3ba65ed57020491f18dc`, v7 37-file tree `f42dbec489c6fda55b612aba20c99ee2233857cb60a1ce9c512d024b35d0dcb7`, and its independent visual receipt `87dc2b9febf7110ccd5c1eabed1a290fea5900508561298dd7cf3b6b6fcb1d95` all still match the hashes accepted by v8 authority.

This receipt deliberately does not bind the sibling postpromotion visual review or its result, and it cannot bind its own future hash. The mechanical and visual reviews therefore remain independent and the authority/evidence graph remains acyclic.

## Independent results

I independently recomputed all packet, manifest, image, package-receipt, source-dependency, app-inventory, executable, and PCK hashes above. The three evidence manifests contain semantically identical embedded package receipts and authority snapshots. Canonical inventory recomputation still yields exactly 37 packet files and the bound tree hash.

Fresh compiler, Node, Godot, and runtime checks passed. They establish catalog/registry schema `8`, adapter contracts/loader API `7`, compiler `1.7.0`, exact recognition `8/213`, immutable counts `213/214/215/4971`, seven active adapters, 16 total receivers, ten package-safe plans, and six disabled plans. B225 has exactly one catalog acceptance, one registry acceptance, and one active adapter; there is no candidate array or second credit. Other accepted units retain their prior semantics.

The sole B225 current topology is `735/952/967/67716/466/466`. B201's `735/950/964/66636/466/466` topology is confined to `pre_b225_integration_live_parity`; historical scopes remain historical. Exact downstream packet, receipt, bundle, executable, PCK, capture-generator, and package-contract hashes occur zero times in the v8 authority/compiler inputs.

Ordinary `main.tscn` observation reports the production attachment present at `world_ready`, candidate activation count zero, and no adapter or candidate-seam call by the harness. The exact wall partition remains 28 host triangles: 20 protected generic plus eight eligible. The attachment adds two decorative batches, three surfaces, 90 boxes, and 1,080 triangles while retaining one structural body, one shape, the sole spray owner, zero navigation owners, the protected wall identity, and the separate roof identity. The six direct production assets are exact and package-present.

All 11 static PNGs and all 21 visual-motion PNGs match their embedded hashes, byte counts, and `1440x900` dimensions. The independent telemetry check confirms exactly 360 consecutive post-player movement samples over 360 ticks and 6.0 seconds, followed by 12 separately recorded braking samples. Frame deltas are one, chain-u is monotonic, and the three joins are crossed by exact adjacent sample pairs `135/136`, `233/234`, and `339/340`. Every input sample remains grounded, in boundary, and center-hit on the exact receiver. The 21 saved visual states are unique, queried after frame-post-draw, coherent with the latest post-player sampler state, and include actual-position brackets around all three joins. Player/camera transform writes, run, jetpack, and recovery use are zero. Independent in-memory fractional-number, malformed-ID, candidate-activation, topology, and numerator mutation probes fail closed.

The source package contract, mounted v8 package contract, generic mounted-PCK audit, and packaged headless main smoke all passed. The mounted PCK contains ordinary main, the six exact B225 assets, and the v8 contract while excluding the historical candidate routes, private evidence/authority paths, and override. The app has exactly seven regular files and no symlinks, quarantine, or extended attributes. Deep-strict and per-architecture code-sign verification pass; entitlements are an empty dictionary, both plists validate, and the privacy manifest says tracking is false. The project-root override is absent and no Godot/game process remains.

## Decision

**PASS_FOR_RELEASE_NO_ADDITIONAL_CREDIT.** The exact bound postpromotion v8 mechanical closure is internally consistent, fail-closed, package-safe, and release-ready. Current authority already grants B225's single recognition increment and remains exactly `8/213`; this audit changes neither numerator nor denominator and grants no additional credit. Visual quality is outside this receipt's scope and remains the responsibility of the separately independent visual review.
