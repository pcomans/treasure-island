# Pre-commit evidence-ledger migration independent recheck

Date: 2026-09-04

Reviewer: `/root/remote_runtime_auditor/ledger_recheck/evidence_ledger_recheck`

Status: **PASS**. No blocker or repair request.

This is an independent mechanical/provenance recheck. The reviewer did not
implement the ledger migration and did not edit its ledgers, contracts,
provenance receipts, runtime, geometry, manifests, captures, or reviews.

## Reviewed migration boundary

The implementation receipt is
`evidence/first-playable/PRECOMMIT_EVIDENCE_LEDGER_MIGRATION.md`, SHA-256
`0240324663ee2e700240d0a49a9b0292642623d257bf992a373a487e525e1013`.

Working-tree comparison with the inherited staged index found exactly these
migration-time implementation changes:

- D1: one edited `asset-inventory.sha256`, one new
  `capture-time-sanitization-provenance.json`, and the edited
  `headless_d1_current_standalone_evidence_contract.gd`.
- P3: one edited `checksums.sha256` and one new
  `capture-time-runtime-provenance.json`.
- The implementation receipt is new and documentation-only.

Within the D1 and P3 evidence directories, no capture manifest, PNG, README,
review, or verification record has an unstaged implementation diff. The
runtime builder and all geometry, material, generated-world, receiver, source
packet, and acceptance artifacts likewise have no migration-time diff. Every
unchanged entry in both ledgers validates its current bytes.

## D1 historical/current split

The D1 ledger has `36` unique repository-relative entries, no malformed or
absolute path, and SHA-256
`0cbef82469498cbfb3a9da5dbf69b10b39503615f83f13ad2487ce871eac4dd3`.
It passed `shasum -a 256 -c` twice at `36/36`.

The new capture-time receipt has SHA-256
`da887e603e5783a5d3ce61ac9c6fa03ede8374639f55bfc7fa3c6ef498a6b9ce`.
It binds unchanged capture manifest SHA-256
`35e60ea88ce9c932de4ecb02a1cdbb21af50e84497bd24e0738d9d5d7bb26f18`
and source-only sanitization receipt SHA-256
`269558b49e21c6c4f46c7133c3aa6012ca35bc122739c677b3ba5ab318a19333`.
Its four mappings exactly preserve capture-time identity while the path ledger
checks current package-safe bytes:

- B201 config: capture-time `3d53efbb0577c9b5e52a2ada4d79a710b95e41faead0bdcdd41cd4f2d862a0fe`;
  current `30bc1f62e5fa44c60bdcfb1bfd4f6f679d391618fa213373e571080face6ec6c`.
- B225 config: capture-time `63e4f80cc7716146dc1fef46c7678e4da856755377c84ff33f972c0cc0c1f639`;
  current `dc3591df4a68af19b5fa53f402ed15d5e3f83946c4a113f024d5b7d41f2f82b8`.
- Pair config: capture-time `c73f8c8da4d30a4e4ebe3e94cde10d63f98377bf5b636a1e12cee92c9bcaafe4`;
  current `fdf00bba0562036f499a5a64e47e5e1b695d49d6cb4ada7acafd450b3dcfefb9`.
- Prototype contract: capture-time `eafe1f8b20cf4a276ad8cda97112acc6870fca183c6d73916dd5bf306a7d099e`;
  current `f36d49c875a4c0000eaf6b1a21ac2273c02840baed3eab683f70f0027fb7aaed`.

All four capture-time hashes are asserted by the evidence contract and the
new receipt; the three config hashes also remain in the separately sealed
source-only sanitization receipt. The evidence contract SHA-256 is
`37190bac76f6e2267b09a0688eb6a54bcc22964376626ad62407421016d8e2d8`.
It binds the exact new ledger and receipt while continuing to pin the nine
original image hashes and the unchanged `290`-box / `3,480`-triangle topology
with geometry signatures `57573bc1…`, `179d898c…`, and `17c56063…`.

## P3 historical/current split

The P3 ledger has `24` unique repository-relative entries, no malformed or
absolute path, and SHA-256
`72a44af243e9594e7abc2aae63ead865375769b6d37950ccf4385bf1a3f08dc9`.
It passed `shasum -a 256 -c` twice at `24/24`.

The mutable `game/scripts/world/world_chunk_builder.gd` path is absent from
that evidence ledger. Its replacement entry is the immutable capture-time
runtime receipt, SHA-256
`08350acfd1f33bc9e8750efa5d72e48d08729eb8dc3f4f5dd5f5461f8212853a`.
That receipt binds unchanged P3 capture manifest SHA-256
`f48dc2db29228caaad418d01e15288ce7ff1e673bff8819fc70837d24aaa66e7`
to capture-time builder SHA-256
`9525ead815e95d7bc0b5fa8beae389954e232a9bbf51b54ed049a84a3613b9c0`.
The same historical builder identity remains in the untouched capture manifest
and verification record.

Current builder SHA-256 is separately and exactly
`28be094c674108f42be040f2b3ae6d242838d15e2060f6cf4668b0a003f1a682`.
Active Batch 02, 03, and 04 contracts all pin that value; their respective
test-file SHA-256 values are
`89a68c2e9253d1baf2b6f92c4bdc99cbcfb8d8094fb87d57d66b7629e0433daa`,
`85ab9ffb5a85efd4bfabb3b9da4cfa8703f70714c83ed275cbda5133620093f8`,
and `30cdf86e0e57a7955e17ff53dbfb8d5b253ce745cdb2d653839f57e09a09e71f`.
This keeps capture-time provenance and moving current authority independent.

The unchanged P3 evidence contract SHA-256 is
`1a587550198756e13c9a62ae39200a2f6e9646494e0b407c1b67a0811cbfd18d`.
It revalidated all four original capture hashes and historical manifest totals
`735` playable rows, `938` meshes, `948` surfaces, `63,720` triangles, `466`
static bodies, and `466` shapes without promoting either pending art verdict.

## Package/source boundary

Canonical export preset SHA-256
`c78293b912682fd5607c0c04b305db5f8eb6a2859269c147faf77094f6b9a2da`
continues to exclude `discovery/`, `evidence/`, and `source_assets/`. Both new
historical receipts therefore remain source evidence and cannot enter the
canonical game package. Static inspection found no absolute `/Users/` or
`/Volumes/` path, `file://` locator, or URL in either new receipt or either
ledger. The three current D1 configs contain no discovery/evidence/source-asset
locator.

The source-mode package-sanitization contract passed twice with exact result:
`7` current config hashes, `7` historical receipt bindings, `3` publishable
source files, `0` runtime source locators, `0` private paths, and `0` source
pixels. The migration does not weaken the source/package separation.

## Independent execution

All tests used project-local Godot
`4.7.2.stable.official.ed1daf0bf`. Each of these passed twice:

- D1 standalone prototype contract.
- D1 standalone evidence contract.
- P3 existing-live material evidence contract.
- Batch 02, Batch 03, and Batch 04 material contracts.
- Pre-commit package-sanitization contract in source mode.
- Full runtime integration.

The diagnostic full-runtime rerun reproduced content SHA-256
`01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`,
`38` chunks, `729` loaded records, `940` reported meshes, `954` reported
surfaces, `64,118` reported triangles, and `466` bodies plus `466` shapes.
The generated manifest remains at `735` playable plus `4` context rows.

Both provenance JSON files parse successfully. Both ledgers have exact unique
path counts matching their entry counts, and the scoped implementation diff
passes `git diff --check`.

## Verdict

**PASS.** The migration repairs mechanical checksum validity without changing
historical evidence or conflating capture-time and current runtime authority.
No blocker remains before explicit restaging and the wider release gate.
