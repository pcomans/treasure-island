# Exact-current recognition reconciliation discrepancy repair

Date: 2026-09-04  
Implementer: `/root/d5_reference_research`  
Authority: the three bounded hygiene findings in `INDEPENDENT_AUDIT.md`  
Status: **implemented and self-verified; pending independent closure recheck**

## Scope and non-claims

This repair changes only the two obsolete Building 1 topology oracles, the one
documented stale Isle checksum entry, and the loader's incorrect projection
occurrence diagnostic plus its required fail-closed hash cascade. It changes no
visuals, world construction, catalog claim, acceptance receipt, numerator,
schema meaning, D7 packet, or 1439 asset.

The authoritative recognition metric remains exactly **5/213**. This receipt is
not its own independent closure decision.

## 1. Building 1 focused-oracle repair

The two named focused regressions now pin the already independently accepted
current hero and exact world:

- Building 1 main wall: `6 meshes / 6 surfaces / 8,806 triangles`;
- Building 1 roof: `3 / 3 / 1,131` where the four-component test requires it;
- tower wall and roof remain `3 / 3 / 760` and `1 / 1 / 14`;
- four-component total: `13 / 13 / 10,711`; and
- loaded world: `735 records / 940 meshes / 954 surfaces / 64,118 triangles /
  466 bodies / 466 shapes`.

Only the obsolete numeric expectations and matching success prose changed.
The tests retain their exact historical predecessor, source-key identity,
horizontal geometry, supersession, truth-boundary, collision, spray ownership,
single-instance, and no-legacy-stacking assertions.

| Focused test | Before repair SHA-256 | After repair SHA-256 |
| --- | --- | --- |
| `headless_building_1_live_field_integration_contract.gd` | `47973dbf16dedd5d54b3b337c78b490ff6dc21c99490478804a22009a7995d7f` | `31d8e91745728e3a9e177e1b56ac2889a3d700f5e4db5a700357fbbe5fd52b1d` |
| `headless_building_1_recognizability_live_contract.gd` | `bc9d6dd8aa71c88d1ba1c1b50058aae62daedbcdc521de82af961f88e5cffdfb` | `cfda6548a447a3bf01ab4bf092b9c4b70010302d57d92e36cb1c76a4318178da` |

Both focused tests passed twice in independent clean processes.

## 2. Historical Isle checksum bookkeeping

Exactly one line changed in the Variant C live-replacement checksum ledger:

- old expected low-live integration test hash:
  `e2c89f40994547e39f83435a1078738e6593c7a3f213578871f6e3f94c42c419`;
- current documented strengthened-test hash:
  `7ed5cb806c6189a2fb8453a6e0636adf281e9eeaa188dab67e2aac4457f14743`.

The checksum file moved from reconstructed pre-repair SHA-256
`c76be30ee86d0e19baed4248726ad2f97e08217bd3e49d73b558cc466a3dad5d`
to `d1b3d397b8360d3a62ed47c5f2f5fe6b27b99ba86a4164db298719ab0c80fbad`.
All 21 listed entries now verify. Every image, movie, capture/motion manifest,
review, runtime asset, and other checksum pin is byte-unchanged. The historical
README wording is deliberately not rewritten.

## 3. Loader diagnostic and fail-closed hash cascade

The loader invariant already enforced
`EXPECTED_PROJECTION_OCCURRENCE_COUNT == 17`; its failure text now also says
`not 17` instead of `not 14`. No condition, error code, resolution policy,
schema, adapter plan, or executable boundary changed.

Because the loader is hash-bound, the corrected byte changed its SHA and
correctly made `--check` fail until the deterministic compiler regenerated the
dependent hashes. The exact cascade is:

| Artifact | Before SHA-256 | After SHA-256 |
| --- | --- | --- |
| Runtime loader | `1558224d21eeaef1b006e3e2c1e4ac833e8ecd291e8f9358b30401d9ebc58dbe` | `c7f73856b2117de014153a7c61ebfeb79e39d7799e23f23f452f697eee5972c1` |
| Adapter contracts | `016f85579555d25170d42e71352938fef6bad102777bd909ab8fb01eef8d8d2e` | `837d14b02495fe4db4f518fedddba127bef7a632579081d13c183fa7cd0caeaf` |
| Runtime registry | `c60e20fb625fa98809975f08357370d71c330443a7546d88fadfcd7df3584d19` | `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af` |
| Validation report | `34f2ee9350cc3cc966f1de675fc853ffb1e85c89bd6688a1c73200f350cd75b2` | `5c2958069d930c96ef96dc9ee06a7203585e41414fb6cf59d231b743e3542584` |

The two focused Godot registry/loader tests were updated only to pin the new
generated registry/adapter hashes. Their resulting SHA-256 values are:

- `headless_facade_recognition_registry_contract.gd`:
  `3e841c2e30146adcb1e01e72192e9fccc1d5d276e248c687c0aa30932a7dbaec`;
- `headless_facade_runtime_registry_loader_contract.gd`:
  `9d00e7b48649dda2d567b336b0782d082c9674bd082ac8e3babc7dc5abe4e980`.

Two subsequent compiler `--check` passes were byte-identical. The authored
catalog remains
`2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`;
the catalog schema remains
`0b7b433caed61c894cbdbdf53d112c06d6161bd0d14951fe795482b38af73e04`;
the compiler remains
`734720fe1c09282ea09e8791e53d8a54933618ad7074b64f3893d797818bfb99`;
and the world builder remains
`28be094c674108f42be040f2b3ae6d242838d15e2060f6cf4668b0a003f1a682`.
Counts remain 213 physical units, 214 direct receivers, 215 source records,
4,971 visible runs, 14 plans, 6 package-safe plans, 8 hard-disabled plans, 15
unique projection inputs, 17 projection occurrences, and 5/213 accepted units.

## Verification ledger

The following source-checkout gates passed under Godot 4.7.2 or Node 26.3.0:

- Building 1 live-field integration contract, rounds 1 and 2;
- Building 1 recognizability-live contract, rounds 1 and 2;
- registry compiler `--check`, rounds 1 and 2;
- Node recognition-registry and runtime-loader contracts;
- Godot loader `--check-only`, recognition-registry contract, and
  runtime-loader contract;
- current Building 1 hero-model and public-front contracts;
- current Isle low-live integration, immutable-evidence, and source-package
  contracts;
- current full runtime at `735/940/954/64118/466/466`; and
- the complete 21-entry corrected Isle checksum ledger.

A fresh PCK from the untouched canonical `macOS Private` preset was mounted
from an empty external working directory:

- SHA-256:
  `ecaaa6cf48b7a2d5ac8206bd7bb409ae768d40df00ed0f3ca049a17ce650c8e6`;
- bytes: `65,421,188`;
- official mounted Isle Variant C package contract: PASS at overlay
  `7/11/2242` and exact receiver `8/12/2268`, with discovery/evidence absent,
  no rejected fallback/stacking, and no decorative ownership; and
- temporary external target-specific Building 1 package audit: PASS for all
  four packaged components at `13/13/10711`, with exact source/object identity,
  one collider per component, and wall-only spray ownership.

The existing Building 1 focused scripts are source-oriented, not mounted-mode
package contracts. Invoking them directly from the PCK reproduced the already
documented generic export-remap seam in their historical-source/whole-world
branches; those invocations are not counted as mounted passes and no source
hash assertion was weakened. The bounded target-specific mounted checks above
test the packaged behaviors this repair could affect.

## Files changed by this repair

- `game/tests/headless_building_1_live_field_integration_contract.gd`
- `game/tests/headless_building_1_recognizability_live_contract.gd`
- `game/scripts/world/facades/facade_runtime_registry_loader.gd`
- `game/resources/facades/facade-runtime-adapter-contracts.json`
- `game/resources/facades/facade-runtime-registry.json`
- `discovery/facades/facade-recognition-validation-report.json`
- `game/tests/headless_facade_recognition_registry_contract.gd`
- `game/tests/headless_facade_runtime_registry_loader_contract.gd`
- `evidence/first-playable/isle-house-composite-repair-variant-c-live-replacement-2026-09-04/CHECKSUMS.sha256`
- `evidence/first-playable/exact-current-recognition-reconciliation-independent-audit-2026-09-04/DISCREPANCY_REPAIR.md`
- `discovery/RETRO_LOG.md`

No commit or push was made. Independent closure recheck is the next gate.
