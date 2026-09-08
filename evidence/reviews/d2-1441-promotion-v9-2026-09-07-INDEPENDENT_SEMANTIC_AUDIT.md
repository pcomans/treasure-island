# D2 1441 Chinook v9 promotion — independent semantic and authority audit

- Reviewer: `/root/v9_semantic_audit`
- Review date: `2026-09-07`
- Scope: current source authority after the one-unit D2 1441 promotion, plus the immutable prepromotion `-009` packet/app/reviews it cites
- Decision: **PASS_FOR_V9_POSTPROMOTION_EXPORT**
- Credit effect of this review: none; this is a downstream audit and is not an input to v9 authority

## Exact current-authority binding

I rehashed the live files from bytes after two compiler writes and the complete audit run.

| Artifact | SHA-256 |
|---|---|
| `discovery/facades/facade-recognition-catalog.json` | `dc6d121d48621f98a203f2fea458316a46446a11e5f2a77d4064694322b2baa2` |
| `discovery/facades/facade-recognition-catalog.schema.json` | `8896fb9dcfd1cb48fc4bf0ed7ddc5fa50fdf7ec31335111291a1e2a2006e106d` |
| `discovery/facades/facade-recognition-validation-report.json` | `bc12d0e95917c650e47d7c6c008345328ed2c3ddb49744613359073999a9d3bb` |
| `game/resources/facades/facade-runtime-adapter-contracts.json` | `8c61ea5601ab94852ac593b8658963b52cb5253aae22a2ff109f2e46771caa93` |
| `game/resources/facades/facade-runtime-registry.json` | `26dcf64a34cf92aa7766c60940933190cdb5f9bc595dc23dc2f16fa01752e16c` |
| `game/scripts/world/facades/facade_runtime_registry_loader.gd` | `32e63c8774c0589856f15ac2ca0e7458e1cdce1403380e50a6ba99bd5185bd26` |
| `tools/build_facade_recognition_registry.mjs` | `4d6da1afa587d2dd8aefb24775d6ba838dd39ac60131985c9c899209572d3e74` |
| `game/tests/headless_d2_1441_postpromotion_v9_contract.gd` | `64a7bdc8d770254df26a56b51493d9e8c7e29a1f786e2ed5888822b7747b870b` |
| `game/tests/headless_d2_1441_postpromotion_v9_package_contract.gd` | `03a2276ec072a27ddc63ad1b0b8551a9c8e2d30586c317c67883b9b3f2965630` |

The coordinated versions are compiler `1.8.0`, catalog/runtime schema `9`, adapter-contract schema `8`, and loader API `8`. The exact inventory is unchanged at `213` physical recognition units, `215` source-record memberships, `214` direct wall receivers, and `4,971` visible wall runs. Runtime authority contains eight active adapters and seventeen total plans, of which eleven are package-safe and six are hard-disabled.

Recognition authority is exactly `9/213`: nine accepted and 204 not evaluated. The accepted-unit delta from frozen capture-time v8 is only `physical-building:w95934105`. That unit has exactly one acceptance record with `capture_time_recognition_metric=8/213` and `numerator_effect=1`, and exactly one active adapter:

`active-adapter:d2-1441-live:building:w95934105:wall`

There is no D2 1441 roof-indexed adapter, legacy adapter, second receiver, relief unit, composite unit, or additional acceptance record. The paired roof is behavior-bound without spray or recognition ownership. The catalog, registry, contracts, Node tests, and Godot tests all independently reject duplicate credit and forged roof credit.

## Immutable prepromotion input

The cited evidence root is exactly `evidence/first-playable/d2-1441-production-v8-staging-2026-09-05-009/`. It contains 40 regular files, no symlinks, and recomputes to canonical packet-tree SHA-256 `e52d66e479f268a9e75372da111d9c93cc1972dd1fddca9a6cb29bb6e41a4a43` using bytewise-sorted, newline-terminated inner `shasum -a 256` records.

| Frozen input | SHA-256 |
|---|---|
| Static capture manifest | `3c11ba6412da6a062d89142594c7b785bf546b5c1905dc32bdd7ce7806fd6885` |
| Consecutive motion telemetry | `21e2b60a8fee1bcfeb984ece6124684c15ae5b1be7fb8a813f18bc0c3b240fcd` |
| Visual-motion manifest | `c885f6450d3eaac4814bde83beff1bbdccea3ae992e07a62c1e9dd8fc1259cad` |
| Package-verification receipt | `cbcda89ec1e013c3406cf919d7c7e3bcefe0df7f005be1ea0e250bfbdada1061` |
| Packet capture override | `edbc0b9caa60fa0fc6b83cebb3145bce11ce0bd976403ca1d2fbe9b7142b39c3` |
| Independent mechanical review | `c39800b1632d1e8b5e05720d02d9499e2788aaf9ef2cf0f1bb1f2b20353b7884` |
| Independent visual review | `075dfb63e4e015cdcc2201e627da5542566d21f9d1163268f790681729ae7144` |
| Frozen focused production validator | `6014498a52676ec93c955ccc672db3d6845c90a0b5e7dbfd1f05df3cf1792986` |
| Frozen package validator | `cc2942797cda2c1cb2bef97bd2ef757fc993a6dfce223bbbd96d91e89230e580` |
| Frozen capture generator | `921acef14ef5503569f8d07bcafdb03f6bccf78570742a8a835962e845a858cf` |

All capture documents still say v8, `8/213`, `recognition_credit=false`, `additional_recognition_credit=false`, and `promotion=false`. The reviewed implementation bytes also remain exact: config `aef5717332cda1cf2ba1457ce9e9e92aaaceae46345595a979813b9369ad8111`, adapter `bf51562a211126c0ea7b631321dfb021171ad68bffd6dd07667ad504d770b9a1`, factory `6c0bf201bbb38a424453f753471cb7cb8060d0323e2386a9fda3bad84acd5933`, builder `7107dc0789e8ca8ee13d53510293a39b3f64e9a92e0ee81bef7317d90a08a87a`, and geometry signature `b91b373e3bb8238a6f73f05734ef48b3429ae5654eddce89b1981ee41ee89195`.

The frozen seven-file app rehashes to bundle identity `81ae851ff3dffd90202e903939f1d6cda7eeb3cfff7e2c752492fa7ed0e1e129`; its executable is `e40c888a66f044c5a267ef027d94e99fd8009104462a7ca193b249b6fb6d7cfd` (`170,963,648` bytes) and its PCK is `c7660d21680649d137af52e2057a23aaa7efab9292c4e427c3e2ef79d1ea80c3` (`66,163,452` bytes). The bundle inventory matches the copied receipt 7/7.

## Causal and topology audit

The hash-reference graph is acyclic. The frozen packet and both prepromotion reviews contain no current-v9 artifact or bridge hashes; the reviews do not hash one another. The direction is frozen evidence/reviews into the promoted catalog, catalog into registry/contracts, and focused bridge into the package bridge. No reverse edge exists. Neither bridge is an input to the compiler or generated authority, and this audit is downstream of all v9 artifacts.

The compiler separates current semantic route validation from the frozen accepted dispatch provenance. It hashes and validates the current builder text directly, while the accepted D2 contract retains reviewed builder SHA-256 `7107dc0789e8ca8ee13d53510293a39b3f64e9a92e0ee81bef7317d90a08a87a`. This prevents unrelated future builder edits from silently rewriting capture-time provenance while still failing on semantic route drift.

Topology scope ownership is exact:

- Isle House and Navy Chapel remain `pre_b201_integration_live_parity` at `735/944/957/64,572/466/466`.
- D1 B201 remains `pre_b225_integration_live_parity` at `735/950/964/66,636/466/466`.
- D1 B225 is relabeled only to `pre_d2_1441_integration_live_parity` and retains `735/952/967/67,716/466/466`.
- D2 1441 alone owns `current_integration_topology` at `735/959/974/69,252/466/466`.

No older topology values changed. The D2 live delta over B225 is only `+0 rows / +7 meshes / +7 surfaces / +1,536 triangles / +0 bodies / +0 shapes`.

## Independent execution results

Two consecutive `node tools/build_facade_recognition_registry.mjs --write` runs emitted byte-identical outputs and the expected hashes above; a following strict `--check` passed. `tools/test_facade_recognition_registry.mjs` and `tools/test_facade_runtime_loader_contract.mjs` both passed. Their mutation matrices cover every accepted dispatch class and reject missing/duplicate/reordered routes, dynamic/preload-variable dispatch, ProjectSettings/environment/command-line/flag/fallback forgeries, lifecycle reordering, duplicate D2 acceptance, forged roof ownership, missing runtime assets, review or geometry hash drift, mapped-run reorder, and multiple/absent current-topology owners.

Godot `4.7.2.stable.official.ed1daf0bf` passed:

- editor import/parse; startup; four gameplay scenes; input/controller; eleven semantic materials; generated-world contract;
- Building 1 hero: four source identities retained, deterministic replacement, exact full-world `735/959/974/69,252/466` topology;
- v9 registry and loader contracts;
- focused D2 v9 and source-package v9 bridges;
- bounded native Metal 4.0 / Forward+ focused D2 v9 execution on Apple M2;
- full runtime at `959/974/69,252/466/466`, current record roots `721/732/48,697`, real walk/run/jetpack/camera/spray/reload behavior, and clean node teardown;
- default continuous route: `262.349 m`, 14 checkpoints, zero stalls/recoveries/boundary failures;
- whole-island route: `3,449.107 m`, five landings, maximum step `0.348 m`, zero teleports/recoveries/boundary failures.

The independent Node world validator passed the unchanged `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164` generated-content identity, 38 chunks, 739/735/4 rows, terrain, pavement, vegetation, and coherent surfaces. Building 1 ownership and NAIP vegetation validators passed. Source precommit sanitization found zero runtime source locators, private paths, or source pixels.

From an outside-project working directory, the exact D2 `-009` PCK passed its frozen mounted production contract at v8 `8/213` and the generic mounted content/privacy audit: 899 virtual files, 47 generated files, all 38 chunks, physical Space, exact movement `4/20/30/40`, 18 Poly Haven maps, 15 vegetation assets, 124 placements, and `private_paths=0`, `private_raw=0`, `banned=0`. The historical B225 v8 PCK separately passed its exact mounted v8 contract, generic privacy/content audit, and mounted standalone-resource contract.

The D2 app passes deep-strict and per-architecture signing, has exactly `x86_64 arm64` slices, valid Info/privacy plists, `NSPrivacyTracking=false`, empty entitlements, and no extended or quarantine attributes. `git diff --check` passed; no override or Godot/game process remained.

`osmium` is not installed on this host, so I did not download a tool or run the optional two-clean-world-generation wrapper. That is nonblocking for this authority-only promotion: no world generation is part of the transaction, while the current world passed independent Node, Godot, runtime, route, and mounted-PCK validation against its exact manifest/content hashes.

### Retired lifecycle probes

As an extra diagnostic, I invoked three source-only standalone/pre-live validators that are intentionally absent from the current v9 suite. They reject current source because their historical assertions require an unwired standalone, the earlier standalone-factory byte pin, or v8 uncredited authority—conditions intentionally superseded by the live replacement and v9 promotion. Their correct successors above pass, and the immutable mounted artifacts remain valid. I did not edit or relabel the retired validators; their failures are not evidence of current-v9 drift and are not counted as passing gates.

## Verdict

The current v9 authority is deterministic, exact, one-credit-only, package-safe, byte-bound to immutable independently reviewed evidence, acyclic, and regression-clean. No discrepancy or blocker was found.

PASS_FOR_V9_POSTPROMOTION_EXPORT
