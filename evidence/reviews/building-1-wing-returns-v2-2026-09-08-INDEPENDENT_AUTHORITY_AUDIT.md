# Building 1 returns v2 — independent current authority audit

Date: 2026-09-08

Reviewer: `/root/handoff_state_review`, independent of authority implementation.

**PASS for current authority semantics and proceeding to an exact-current export.**
Recognition remains **9/213, +0**. This audit is not an export, package-release,
ordinary gameplay, or full release-smoke acceptance.

## Scope and identities

The frozen handoff is task scratch `work/b1-v2-001/authority-integration-handoff.json`,
SHA-256 `9640dcb90d197dd469f053ff5f02603d23787564a60c4c1844ae19a9b55ae939`.
All 17 current files, five immutable reviewed source inputs and 29 preserved lineage
entries matched before/after independent checks. The 19 original check-log hashes
also match the frozen handoff.
The comparison base is local source checkpoint `82043cefd216ac995363fe72cea48763d0247951`.

| Current identity | SHA-256 |
| --- | --- |
| Compiler 1.8.1 | `9b6ee97d19e069a0cfc0dc0e043e856e8618c407361b508527ce764b9a71be37` |
| Runtime registry v9 | `c6780895e339919f7ebe0900814afaa46fd15f31958946ec81b4391091a1d46f` |
| Adapter contracts / loader API v8 | `24efc72b3315540f31dc112949ac108509cdc0e4eb9f5e20ef0d4b45ce41ac49` |
| Source-side validation report | `bc2e6bb25f9de9c5c2007c51b3007c4da63081e32328bc9a99d1aed740448a3b` |
| Current focused B1 contract | `6963ffa0775e1d2296afc73e899a8c1abbffcf3bd0e411da984d71fb7fe1cc7a` |
| Current main, smoke target 70,692 triangles | `a5cedea1c9861aca393787f7d1a26bfcee3a8a17b08ec4a8bd889fb79a2c7057` |

## Independent semantic findings

All **213 physical-unit records** in both catalog and registry are structurally
identical to the prior authority, including acceptance records and ownership.
The recognition metric, nine claim-neutral legacy adapters and eight active
adapter identities remain unchanged. The catalog changes only its checked date
and required compiler version; catalog/runtime schemas remain v9.

Exactly two B1 adapters update their executable/public-front config hashes in
the existing 11-asset closures. Their behavior contracts remain null; no invented
B1 behavior schema, extra building/tower credit or receiver was introduced.
The generated source report explicitly binds the current public-front config
and scoped acceptance receipt. Corresponding runtime plans contain the current
source hashes and retain existing ownership and disabled-receiver boundaries.

For D2 1441, independent field comparison proves its only adapter change is
`geometry_contract.world_triangles: 69252 -> 70692`, within the explicitly current
whole-world scope. D2 component geometry, collision, source-record signatures,
capture evidence, acceptance and ownership remain identical. Current world is
`735/959/974/70692/466/466`; `GameMain` changes only its triangle-count oracle.

The compiler now requires the exact raw and canonical accepted receipt, exact
B1 config/adapter bytes, frozen source inputs, independent reviews and the
original 98-file evidence inventory/tree. The added Node negative controls
actually reject ten mutated receipt/claim cases and two config/executable cases.
The current focused bridge retains all **34 methods and its complete executable
body** from the frozen candidate contract: geometry, accepted-prefix, material,
collision and failure predicates were not weakened. Only seven current authority
pins and upstream candidate/review bindings were updated or added.

## Accepted packet and independent execution

Read-only packet verification reconstructed the exact scoped acceptance receipt
`257f16bc314151054b120c2b87e6f8cb20577f5e4a7201478b58272a65dc23a4`.
The accepted packet contains **100 files / 70,195,021 bytes**, tree
`4d62256ec5c6e9d2b144d0b7cd4f0517058f8dcc0588b269ba53ae1d05f5f0b4`.
Its unchanged original 98-input tree remains
`5046e9bb1aaec4b79ecc0649087a33e54c6b87de291d1376ed3ad76bce7d6dff`.
The builder rejects added/missing/changed files, unsafe paths and symlinks;
normal verification needs no private scratch or installed candidate app.

The dependency direction is acyclic: frozen source/proofs and independent leaf
reviews feed acceptance, which feeds current authority. The receipt preserves
the modest local visual scope, source-rendered pixel provenance, sampled-motion
limit, original candidate package failure, and OS-window-only ordinary launch
observation. It makes no complete current-release claim.

All ten independent checks exited **0**: read-only acceptance packet verification;
compiler `--check`; Node registry, loader and B1 run ownership; then Godot current
B1 geometry, registry, loader, source sanitization and startup configuration.
The compiler/loader checks include deterministic recompilation and negative
controls. The five Godot outputs contain no error/failure diagnostics. Previously
independently verified source gameplay/routes and rendered evidence were reused
because their implementation/proof inputs remained frozen.

Commands, actual process identities, exits and complete log hashes are retained
in task scratch `work/b1-v2-authority-independent-001`:

- `node-execution-receipts.json`: `954ec108eccd0148684904070b5b652527ff5649a0e4574acde3bc392b593f8e`.
- `godot-execution-receipts.json`: `44be1e6b0389a9c61fb0a29042d98f6930ad24fa775c2b6776c1bc2398e361ab`.
- `semantic-field-diff.json`: `251ab2d019b97b13df51528b4e6dca24dc105bf2585c325059bed367de61ce58`.

Godot batch session62211 and final PID10941 are terminal with exit0; the heavy
slot was released immediately. No source, authority or proof was edited during
this review. Next: create a new exact-current private app and independently
verify its mounted content and complete current release smoke. Preserve all
historical candidate programs/receipts; do not relabel them as current-release
proof. No export, launch, Git transaction or push occurred in this audit.

PASS_FOR_B1_RETURNS_V2_AUTHORITY_EXPORT
