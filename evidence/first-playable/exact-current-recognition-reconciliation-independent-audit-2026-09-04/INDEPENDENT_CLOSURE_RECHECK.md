# Exact-current reconciliation discrepancy repair — independent closure recheck

Date: 2026-09-04

Reviewer: `/root/d6_reference_research`

Inputs:

- prior independent audit SHA-256
  `3fc0d21ba0685937f23b9dc0d8900e8c4da0d8081515320b02d21aa489e67a13`;
- repair receipt SHA-256
  `fcd2c6c06422defbd28d319decc6115b94872913e9bbcf925e529af0b150772a`;
- current source checkout and retained repair PCK.

This was an independent read-only recheck. No production, generated, test, or
evidence artifact was edited by the reviewer.

## Verdict: CLOSED

All three discrepancies in `INDEPENDENT_AUDIT.md` are closed:

1. Both stale Building 1 focused oracles now pin and pass the independently
   accepted current hero topology and ownership boundary without removing any
   assertion during this repair.
2. The Isle checksum ledger now pins exactly the strengthened low-live test;
   all 21 entries pass, including every unchanged image and manifest.
3. The loader message now says 17, matching the already enforced 17 projection
   occurrences. Its deterministic hash cascade is exact and all unsafe plans
   remain fail closed.

The authoritative catalog/registry metric remains exactly **5/213**. The D7
packet-time registry-hash ambiguity described below is separate documentation
and validator debt; it does not reopen these three repairs or alter any D7
receiver geometry.

## 1. Building 1 focused tests

The repaired files have the receipt's exact hashes:

| Test | Current SHA-256 | Result |
| --- | --- | --- |
| `headless_building_1_live_field_integration_contract.gd` | `31d8e91745728e3a9e177e1b56ac2889a3d700f5e4db5a700357fbbe5fd52b1d` | PASS |
| `headless_building_1_recognizability_live_contract.gd` | `cfda6548a447a3bf01ab4bf092b9c4b70010302d57d92e36cb1c76a4318178da` | PASS |

An in-memory reversal of only the documented topology values and their success
prose reconstructs the exact pre-repair hashes:

- live-field test:
  `47973dbf16dedd5d54b3b337c78b490ff6dc21c99490478804a22009a7995d7f`;
- recognizability-live test:
  `bc9d6dd8aa71c88d1ba1c1b50058aae62daedbcdc521de82af961f88e5cffdfb`.

This proves the repair did not delete or relax an assertion. It changed only
the obsolete main-wall/main-roof/world expectations and matching status prose.

The live-field test continues to require the historical runs 21–51 field's
exact ordered runs, material, shared miter join, zero gap, 124 vertices, 186
indices, and zero collision ownership. It then requires the live main hero
wall at `6 meshes / 6 surfaces / 8,806 triangles`, exact reviewed/truth
metadata, absence of both predecessor attachments, the retained ivory
material, wall collision layer, spray group, one loaded receiver instance, and
whole-world topology
`735/940/954/64118/466/466`.

The recognizability-live test continues to build and bound the historical
composition at `354/354/4338` with zero collision ownership and its review
provenance. It then requires all four separately keyed live hero components:

| Component | Meshes / surfaces / triangles |
| --- | ---: |
| Building 1 wall | `6 / 6 / 8,806` |
| Building 1 roof | `3 / 3 / 1,131` |
| Tower wall | `3 / 3 / 760` |
| Tower roof | `1 / 1 / 14` |
| Total | `13 / 13 / 10,711` |

For every component it checks source identity, supersession, vertical
inference/truth status, accepted visual-review status, and absence of the
historical attachment. In the loaded world it checks exact global topology,
exactly one instance of every key, and no live historical facade.

The unchanged current hero contract also passed. It independently checks all
four exact horizontal source plans, deterministic repeated geometry, exactly
one body and shape per component, exact collision-face topology, collision
mask/layers, roof non-spray ownership, wall-only spray ownership, and live
physics rays. Thus the repaired focused tests are consistent with, and do not
weaken, the acceptance-level geometry and ownership oracle.

## 2. Isle historical evidence and checksum

The current checksum ledger SHA-256 is
`d1b3d397b8360d3a62ed47c5f2f5fe6b27b99ba86a4164db298719ab0c80fbad`.
All 21 entries pass from the repository root.

Replacing only the strengthened low-live test hash

`7ed5cb806c6189a2fb8453a6e0636adf281e9eeaa188dab67e2aac4457f14743`

with its prior value

`e2c89f40994547e39f83435a1078738e6593c7a3f213578871f6e3f94c42c419`

reconstructs the documented pre-repair checksum-file SHA-256 exactly:

`c76be30ee86d0e19baed4248726ad2f97e08217bd3e49d73b558cc466a3dad5d`.

Therefore the checksum edit is exactly one entry. The four PNGs, AVI,
capture manifest, motion manifest, review receipt, README, runtime inputs, and
the other test pins remain byte-identical to their ledger values. The README's
older topology wording remains an intentionally historical capture statement,
not an exact-current runtime claim.

The strengthened Isle low-live, immutable-evidence, and source-package tests
all pass. Current exact state remains one Variant C low replacement with
overlay `7/11/2242`, receiver `8/12/2268`, world
`735/940/954/64118/466/466`, unchanged high receiver, no rejected fallback or
stacking, and the low underlying receiver as sole collision/spray owner.

## 3. Loader diagnostic and generated hash cascade

`facade_runtime_registry_loader.gd` now both enforces
`EXPECTED_PROJECTION_OCCURRENCE_COUNT := 17` and reports “not 17” on failure.
Changing only that message back to “not 14” in memory reconstructs its exact
pre-repair SHA-256
`1558224d21eeaef1b006e3e2c1e4ac833e8ecd291e8f9358b30401d9ebc58dbe`.
The current loader hash is
`c7f73856b2117de014153a7c61ebfeb79e39d7799e23f23f452f697eee5972c1`.

The downstream artifacts contain only the required upstream-hash cascade.
Replacing the new upstream pins in memory reconstructs all exact prior hashes:

| Artifact | Current SHA-256 | Reconstructed prior SHA-256 |
| --- | --- | --- |
| Adapter contracts | `837d14b02495fe4db4f518fedddba127bef7a632579081d13c183fa7cd0caeaf` | `016f85579555d25170d42e71352938fef6bad102777bd909ab8fb01eef8d8d2e` |
| Runtime registry | `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af` | `c60e20fb625fa98809975f08357370d71c330443a7546d88fadfcd7df3584d19` |
| Validation report | `5c2958069d930c96ef96dc9ee06a7203585e41414fb6cf59d231b743e3542584` | `34f2ee9350cc3cc966f1de675fc853ffb1e85c89bd6688a1c73200f350cd75b2` |

Two fresh compiler `--check` runs passed and left all checked inputs and
outputs byte-identical. The following authority hashes remain unchanged:

- catalog:
  `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`;
- schema:
  `0b7b433caed61c894cbdbdf53d112c06d6161bd0d14951fe795482b38af73e04`;
- compiler:
  `734720fe1c09282ea09e8791e53d8a54933618ad7074b64f3893d797818bfb99`;
- receiver inventory:
  `0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f`;
- generated content:
  `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`;
- generated manifest:
  `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`;
- world builder:
  `28be094c674108f42be040f2b3ae6d242838d15e2060f6cf4668b0a003f1a682`.

The current plan arithmetic independently recomputes as 14 plans: 10 legacy
plus 4 active, partitioned into 6 package-safe resolve-only plans and 8
hard-disabled plans. All eight disabled plans have no executable assets, exact
disabled reasons, and `deny_all_executable_resolution`. There are 15 unique
projection descriptors across 17 disabled-plan occurrences. Registry and
loader source tests, mutation tests, and Godot loader parsing all pass with the
new exact pins.

## Recognition metric

The current catalog and runtime registry each contain 213 physical units. The
registry contains 215 unique source memberships and 214 unique direct
receivers. Neither Isle part source has a physical-unit entry. The accepted set
is exactly:

- `physical-building:r16681702`
- `physical-building:w1222720021`
- `physical-building:w1249412093`
- `physical-building:w1249412094`
- `physical-building:w34313540`

The metric remains `5/213`, with Isle House counted once at the composite
parent and `w1282547786` / `w1282547787` explicitly excluded from the
numerator as non-unit source records.

## Bounded execution ledger

PASS:

- compiler `--check`, two successive byte-stable runs;
- Node recognition-registry and runtime-loader contracts;
- generated-world validation;
- Godot loader `--check-only`;
- Godot recognition-registry and runtime-loader contracts;
- both repaired Building 1 focused contracts;
- current Building 1 hero-model contract;
- Isle low-live, immutable-evidence, and source-package contracts;
- full runtime at `735/940/954/64118/466/466`;
- all 21 Isle checksum entries;
- official mounted Isle contract against retained PCK; and
- independent target-specific mounted Building 1 audit against the same PCK.

The retained PCK is 65,421,188 bytes with SHA-256
`ecaaa6cf48b7a2d5ac8206bd7bb409ae768d40df00ed0f3ca049a17ce650c8e6`.
The external Building 1 audit passed all four packaged components at
`13/13/10711`, exact source/object identities and horizontal plans,
deterministic repeated builds, one collider each, and wall-only spray
ownership. Its temporary script was outside the repository; SHA-256
`94b4c807260ccebce922b94592aff306c713df0823eeb8d3d3c98cf18d78e2d3`.

## Export-remap seam remains disclosed

Running the generic source-oriented registry and loader tests from an empty
external directory against the retained PCK still exits 1 on absent/remapped
raw `.gd`, `.tscn`, and `.tres` paths. Running the complete source-oriented B1
hero test against the PCK builds and measures all four target components
correctly, then exits 1 in its raw-source whole-world branch. These are the
same known export-remap limitations documented in the original audit.

No raw-byte or fail-closed assertion was removed to manufacture a mounted
pass. Instead, the official Isle mounted test and bounded B1 target-specific
mounted audit verify transformed package behavior, while source-checkout tests
continue to verify exact raw bytes and dependency closure. Generic exported
loader promotion still requires an export-aware integrity contract.

## D7 packet-time registry hash assessment

D7 pins pre-repair registry hash
`c60e20fb625fa98809975f08357370d71c330443a7546d88fadfcd7df3584d19`.
That is a genuine sealed packet-time snapshot: it matches the registry audited
immediately before this diagnostic-only loader cascade. D7's catalog,
inventory, OSM, generated-manifest, cohort, direct receivers, chunk records,
and geometry hashes did not change.

However, the D7 README currently calls the old hash a “sealed direct runtime
wall/record binding” and presents its audit as a fresh pass, while
`validate_d7_packets.mjs` compares that pin to the moving current registry.
The validator now completes its local D7 contract derivation and then fails at
the full-file registry hash. Without an explicit packet-time qualifier, this
is misleading as an exact-current claim.

**Nonblocking correction needed:** label `c60e20...` explicitly as the D7
packet-time registry snapshot and either separate current invariant validation
from historical full-file sealing or add a dated supersession/current hash.
Do not silently replace the old snapshot. This documentation/validator issue
does not alter D7's 15 physical IDs or reopen the discrepancy repair.

## Files changed by this closure recheck

- `evidence/first-playable/exact-current-recognition-reconciliation-independent-audit-2026-09-04/INDEPENDENT_CLOSURE_RECHECK.md`
- `discovery/RETRO_LOG.md`

No production, generated, existing test, acceptance, checksum, D7 packet, or
runtime file was modified by this reviewer. No commit or push was made.
