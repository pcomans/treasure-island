# Pre-commit evidence-ledger migration

Date: 2026-09-04

Status: implementation gates pass; pending independent ledger recheck. This
receipt records checksum-provenance maintenance only and makes no visual,
recognition, or acceptance judgment.

## D1 standalone-pair ledger

The path-addressed `asset-inventory.sha256` now checks the exact current
package-safe bytes at all four paths changed by the earlier sanitization:

| Path | Capture-time SHA-256 | Current SHA-256 |
| --- | --- | --- |
| `game/resources/facades/d1_current/d1_b201_public_wsw.json` | `3d53efbb0577c9b5e52a2ada4d79a710b95e41faead0bdcdd41cd4f2d862a0fe` | `30bc1f62e5fa44c60bdcfb1bfd4f6f679d391618fa213373e571080face6ec6c` |
| `game/resources/facades/d1_current/d1_b225_nnw_long.json` | `63e4f80cc7716146dc1fef46c7678e4da856755377c84ff33f972c0cc0c1f639` | `dc3591df4a68af19b5fa53f402ed15d5e3f83946c4a113f024d5b7d41f2f82b8` |
| `game/resources/facades/d1_current/d1_current_standalone_pair.json` | `c73f8c8da4d30a4e4ebe3e94cde10d63f98377bf5b636a1e12cee92c9bcaafe4` | `fdf00bba0562036f499a5a64e47e5e1b695d49d6cb4ada7acafd450b3dcfefb9` |
| `game/tests/headless_d1_current_standalone_prototype_contract.gd` | `eafe1f8b20cf4a276ad8cda97112acc6870fca183c6d73916dd5bf306a7d099e` | `f36d49c875a4c0000eaf6b1a21ac2273c02840baed3eab683f70f0027fb7aaed` |

The four capture-time hashes remain immutable in
`capture-time-sanitization-provenance.json`, SHA-256
`da887e603e5783a5d3ce61ac9c6fa03ede8374639f55bfc7fa3c6ef498a6b9ce`.
That receipt also binds the unchanged capture manifest and the source-only
package-migration receipt. The new 36-entry ledger SHA-256 is
`0cbef82469498cbfb3a9da5dbf69b10b39503615f83f13ad2487ce871eac4dd3`.
The evidence contract SHA-256 is
`37190bac76f6e2267b09a0688eb6a54bcc22964376626ad62407421016d8e2d8`.

## P3 existing-live material ledger

The P3 evidence ledger no longer compares the mutable
`game/scripts/world/world_chunk_builder.gd` path to its capture-time bytes.
Instead it checks the immutable
`capture-time-runtime-provenance.json`, SHA-256
`08350acfd1f33bc9e8750efa5d72e48d08729eb8dc3f4f5dd5f5461f8212853a`.
That receipt binds capture-time builder SHA-256
`9525ead815e95d7bc0b5fa8beae389954e232a9bbf51b54ed049a84a3613b9c0`
to the unchanged capture manifest. Current authority stays separate: active
Batch 02/03/04 tests pin accepted builder SHA-256
`28be094c674108f42be040f2b3ae6d242838d15e2060f6cf4668b0a003f1a682`.
The new 24-entry evidence ledger SHA-256 is
`72a44af243e9594e7abc2aae63ead865375769b6d37950ccf4385bf1a3f08dc9`.

No manifest, PNG, review, runtime, geometry, material, topology, receiver,
source packet, generated file, or acceptance metric changed.

## Implementation gates

- D1 ledger: `36/36` entries pass, twice.
- P3 ledger: `24/24` entries pass, twice.
- D1 standalone prototype and D1 evidence contracts: pass twice; signatures
  remain `57573bc1…`, `179d898c…`, and `17c56063…`, with `290` boxes and
  `3,480` triangles.
- P3 evidence contract: pass twice with the unchanged capture-time
  `735/938/948/63,720/466/466` manifest provenance.
- Active Batch 02 and Batch 04 material contracts, accepted-material contract,
  and package-sanitization source contract: pass.
- Full runtime integration: pass at exact current
  `735/940/954/64,118/466/466`, content SHA-256
  `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`.

Independent review must re-run the two ledgers and focused evidence contracts,
verify the historical/current split, and confirm the migration did not weaken
the package or current-runtime authority gates before these paths are staged.
