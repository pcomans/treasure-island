# D1 B225 Postpromotion v8 — Independent Full-Resolution Visual Review

- Decision: **PASS_FOR_RELEASE_NO_ADDITIONAL_CREDIT**
- Decision scope: independent visual release approval for only the exact postpromotion v8 packet, authority closure, and packaged app bound below
- Reviewer: `/root/b225_v8_promoter/canonical_test_audit/godot_contract_audit`
- Reviewer role: independent full-resolution visual bar-raiser for recognizability, believability, texture behavior, player-view integrity, and confusion-set separation
- Review timestamp (UTC): `2026-09-05T19:53:57Z`
- Evidence stage: postpromotion v8 current-authority evidence from the ordinary canonical main path; uncommitted candidate pending the independent contract audit

## Exact review receipt binding

- Evidence root: `evidence/first-playable/d1-b225-postpromotion-v8-2026-09-05/`
- Frozen 37-file packet tree SHA-256: `7b0de99e6f4afe07b1767c522517ace3dc1729a3f82f4b9b95716de9483cbd84`
- Static manifest SHA-256: `25948a6f3478534d2b8080ead6ea42bb74ca9c6b79226ac066bcf262ca8bfef0`
- Consecutive telemetry manifest SHA-256: `e0b8457666ada91055c4e17d21c359593a0991dae2202d5d1094ae62f81c6753`
- Visual-motion manifest SHA-256: `e7c26ce099aa7595864f5298ab15cc4ddde14a68aedb66c7424d24fbb36b1c1f`
- Package-verification receipt SHA-256: `160d48acdc71687fd46ea3c14d91723e897e4930a59ffb6504b2d621d776cc1c`
- Capture generator SHA-256: `6c709d81038ce9563181e57db364f11c1ad64d84e7c91e0c78c8ef087c052105`
- Packet capture-override SHA-256: `edbc0b9caa60fa0fc6b83cebb3145bce11ce0bd976403ca1d2fbe9b7142b39c3`

### Current v8 authority and implementation

- Catalog SHA-256: `d95be7bec8f0eabe97a9b5f7fefe1ce54ec7cbf940d85d28518ff6979eeb16ea`
- Catalog schema SHA-256: `44584e92e1652fc930f47882b4a83304f5216c14173eb805bc9ce68ea9927cac`
- Runtime registry SHA-256: `109f83f40450e9c71ef6d39f1659e76eac5f1457fcfab772538b471cc74c0051`
- Adapter contracts SHA-256: `dd2d13e3b0f6eee1f8c5f2957927c4f3caba43b31883beea925f9a91b826d65c`
- Registry loader SHA-256: `12e6c64b23b0783ed240b3d6c02499c3940c2b6a14344caa29778b850db06c04`
- `project.godot` SHA-256: `305bfb3bf0493c485f48ea8a01d4effccb58d9dd74ad6dc9be78a64ed23981af`
- Canonical `main.gd` SHA-256: `14468a67c4dc8d56394b98515c61e7425c130ef74297624bb205957f6a834140`
- Canonical `WorldChunkBuilder` SHA-256: `de4a2924d275a51dfd08aae1f0ef21daac33395b1fcfe98e260fbc90737dd725`
- B225 live attachment SHA-256: `4b1defd92a77b23de692437f044dfaa579fa2ee5b3dee77465ec8404f1644ac9`
- B225 live configuration SHA-256: `80b42c33fce84361aa7512f64305f5bff273e8fed95640ca4f9c19d49d55621d`
- Postpromotion source contract SHA-256: `fd63ced9552dd9a1749de0047d2cebd1b46a1b093ebe1645dd4fcace19186353`
- Postpromotion package contract SHA-256: `6d2d05e28657b5de89bce0cea0c70819b791d886921f4a057c80cf548713cbcc`

The bound authority is catalog `8`, runtime registry `8`, adapter contracts `7`, loader API `7`, and compiler `1.7.0`. It records exactly one accepted B225 catalog record, exactly one accepted B225 registry record, one active B225 runtime adapter, and current topology `735/952/967/67716/466/466`. It also preserves the prior acceptance authority: frozen v7 manifest `96c76fd99960f1345a7c56f7fc6678ac284f98cc601a3ba65ed57020491f18dc`, frozen v7 tree `f42dbec489c6fda55b612aba20c99ee2233857cb60a1ce9c512d024b35d0dcb7`, and prior independent review `87dc2b9febf7110ccd5c1eabed1a290fea5900508561298dd7cf3b6b6fcb1d95`.

### Packaged app

- Bundle identity SHA-256: `3f38c5dcd55b19f12cf7788e1069367075aa22f1b557c5b61288abdfdc30afe0`
- PCK SHA-256: `7315bba99efeeeb86be0bbf44876d391b9c1c95f1638318e0df2b7af367669bf` (`66,073,188` bytes)
- Executable SHA-256: `c485010419591a9556e849e79755d7e816f840e31978c10b371be08a730e2d82` (`170,963,648` bytes)
- Bundle inventory: exactly `7` files; executable slices `x86_64` and `arm64`

I independently reproduced the packet tree and all four top-level receipt/manifest hashes, matched every embedded hash for the 11 static and 21 motion PNGs, matched all 36 current source-dependency hashes in the static manifest, and matched all ordinary-file entries in the package receipt's 17-entry source map. I also independently matched the PCK, executable, seven-file count, architecture list, and bundle-identity digest from the staged app. The project-root capture override is absent after capture.

This visual receipt deliberately binds the packet tree, three evidence manifests, package receipt, current authority/implementation, and packaged-app bytes. It does **not** bind or inherit the sibling mechanical/contract review, and it cannot self-bind its own future hash. Those omissions keep the two audits independent and the release graph acyclic.

## Full-resolution inspection

- Static images inspected at original `1440x900`: `11/11`
- Dense visual-motion images inspected at original `1440x900`: `21/21`
- Total images inspected at original resolution: `32/32`
- Actual and declared dimensions: `1440x900` for all `32/32`
- Recorded runtime: Godot `4.7.2-stable (official)`, macOS, Metal, Forward+, Apple M2, API 4.0, 60 physics ticks/s, with project and SceneTree physics interpolation disabled

I opened every PNG rather than sampling thumbnails. The static pass covered whole (`01`), oblique (`02`), changed-light (`03`), grayscale (`04`), close (`05`), real-spray (`06`), protected-return (`07`), surrounding-context (`08`), and exact-current B201/B202/B258 confusion-set views (`09`-`11`). The motion pass covered every far/mid/near frame (`01`-`03`, `19`-`21`) and every adjacent frame around join 1 (`04`-`08`), join 2 (`09`-`13`), and join 3 (`14`-`18`).

## Recognizability and believability verdict

B225 is label-free top-1 recognizable against B201, B202, and B258. Its stable ranked cues are:

1. A continuous high clerestory with visibly varied pane widths and mullion cadence.
2. A low, elongated shed mass rather than a tall block or storefront volume.
3. Pale, aged horizontal cladding with restrained surface variation.

Those cues survive the whole, oblique, close, and wider contextual views, changed lighting, lossless grayscale, real spray, the protected-return composition, and the complete motion sequence. The grayscale view confirms that recognition does not depend on hue. The whole, oblique, context, close, and moving player views confirm it does not depend on a privileged camera. B201 reads instead as a green-capped lower storefront program; B202 is a generic low blank mass without the continuous clerestory treatment; B258 is a taller blank block.

The result is believable at the requested game-view quality bar without pretending to perfect realism. No signage, building name, invented lower opening/program, or special color supplies the identity. The clerestory variation avoids a sterile repeated-window strip, while the cladding remains subordinate enough not to compete with the massing.

## Texture, joins, motion, and protected surfaces

Across the far/mid/near sequence and all 15 dense join-bracket frames, I found no visible material seam, UV reset, repeating stamp, crawl, shimmer, moire, pop, geometry float, or decorative bleed. The horizontal courses and clerestory remain attached and coherent while the stock player traverses all three joins. A small stepped host/grade silhouette is visible along the lower edge in join-3 frames `14`-`18`; it stays fixed to the host and does not interrupt the cladding or clerestory, so it is not a join seam or release hold.

The close view `05` shows mild broad cladding softness and a slightly synthetic grain under scrutiny. It does not become an obvious tile boundary or motion artifact in any other view and is nonblocking under the stated progress-over-perfection bar.

The real spray in `06` is visibly applied to the eligible selected host. The protected generic return in `07` remains intact, and the B225 treatment does not leak onto it. That protected surface retains conspicuous pre-existing generic repetition, but it is correctly unchanged content rather than a B225 defect. The roof remains the unchanged simple host roof across the whole, oblique, protected-return, context, and motion views; no facade treatment, spray, or material bleeds onto it.

## Motion and production-path truth

The consecutive telemetry manifest records exactly `360` post-player physics controller samples over `360` movement ticks and `6.0` seconds, followed by `12` separately recorded braking samples. Every input sample is grounded, inside the declared chain boundary, sampled after the player controller, and advances by exactly one engine physics frame. Chain-u is monotonic and crosses all three real joins. The three join crossings occur between samples `135/136`, `233/234`, and `339/340`; the visual manifest independently supplies actual-position brackets around every join.

Both motion manifests report zero player-transform writes and zero camera-transform writes after input begins. No run, jetpack, or recovery action is used. The consecutive telemetry contains no render awaits and no image/file writes before its manifest. The visual-motion run records 21 unique post-render frame receipts; every saved state matches the latest post-player sampler snapshot, all frame hashes and engine-frame IDs are unique, and the outer observations are correctly not claimed to be consecutive telemetry.

The static, telemetry, and visual manifests agree that canonical `main.tscn` was instantiated, the production attachment was already present at `world_ready`, candidate activation count was zero, and the capture harness loaded or called neither the production adapter nor the candidate seam. The attachment adds two decorative batches, 90 boxes, and 1,080 triangles to the exact selected wall partition while preserving the sole structural body, shape, and spray owner, zero navigation owners, 20 protected generic host triangles, and the separately recorded roof root.

## Release decision and non-credit state

**PASS_FOR_RELEASE_NO_ADDITIONAL_CREDIT.** I found no visual reason to hold the exact bound v8 closure. The only visible limitations are mild close-only cladding softness and unchanged repetition on the protected generic return; neither compromises B225 recognizability, believability, motion stability, surface ownership, or confusion-set separation.

The reviewed authority already says `8/213`: eight accepted physical units, with B225's one prior acceptance already included. All three evidence manifests and the package receipt say `additional_recognition_credit: false`, and this review preserves that state. It authorizes no numerator or denominator change and creates no new recognition credit. Release still requires the separately independent mechanical/contract verdict for the same exact closure; this visual receipt makes no claim about that sibling audit's result.
