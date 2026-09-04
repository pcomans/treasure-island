# Pre-commit combined repair independent recheck

Date: 2026-09-04

Reviewer: `/root/remote_runtime_auditor/ledger_recheck/combined_repair_recheck`

Review relationship: independent; this reviewer did not implement the repairs

Verdict: **PASS for exact restaging and the planned local milestone commit**

## Reviewed boundary

The inherited index remained untouched. Relative to that index, the complete
tracked working-tree repair boundary was exactly the twelve named test/packet
files plus append-only retrospective entries. The three implementation receipts
were new untracked files. No runtime, geometry, material, catalog, registry,
generated-world, capture, media, package, or packet-body path appeared in the
working-versus-index diff.

The scoped diff was:

- Isle historical/current seam: `101` insertions and `19` deletions across
  three tests.
- Batch 02/03/04 current builder oracle: `3` insertions and `3` deletions.
- D7-D9 authority migration: `128` insertions and `21` deletions across the
  six README/validator files, exactly matching the implementation receipt.
- Retrospective: append-only entries for the repair implementers. Their claims
  agree with the independently measured diffs and repeated results.

`git diff --check` reported no whitespace errors for all twelve repaired files.

## Exact index-to-working-tree hashes

### Isle House contracts

| Contract | Inherited index SHA-256 | Repaired working SHA-256 |
| --- | --- | --- |
| `headless_isle_house_low_facade_prototype_contract.gd` | `4988bf386b46ba9aa000d5c9a3dfd52ce14596a7c3d729b2dd80d157ce35a8c9` | `a13c8d2c616f3a08076e277ffbd43416f71ed0128dd89e675c349d320e30d9ef` |
| `headless_isle_house_low_genai_brick_phase2_evidence_contract.gd` | `f1ebe95d777422eb2f2cc0b24c197083ec1c50795518523b9af0a0ddd4b3c601` | `b276390f8b418a9429d85945c735641312b82ea251ccfe61054f2a201e5437dc` |
| `headless_isle_house_low_live_evidence_contract.gd` | `7266eb74bd881f71b69c2cdab387abae88a7eb25ad9237643fb2d293e560a7f4` | `87b0f8b599c5c7579308b82d5d334c0b54133bc809190947877ce3ef2fa3029f` |

### Material-batch contracts

| Contract | Inherited index SHA-256 | Repaired working SHA-256 |
| --- | --- | --- |
| `headless_batch_02_material_contract.gd` | `920d3adbc8cc92c611f9ebc8a9ec90fdd974422ee3af254c18373161243b205e` | `89a68c2e9253d1baf2b6f92c4bdc99cbcfb8d8094fb87d57d66b7629e0433daa` |
| `headless_batch_03_material_contract.gd` | `d9998afcd01de93d4c82dbfcea82ca38049fc61baa76db2ab68520186fca4943` | `85ab9ffb5a85efd4bfabb3b9da4cfa8703f70714c83ed275cbda5133620093f8` |
| `headless_batch_04_material_contract.gd` | `3b51fb3dddf878ebb13fb0336b4e9439446f10486b894c0964ec0cd39b2d22e9` | `30cdf86e0e57a7955e17ff53dbfb8d5b253ce745cdb2d653839f57e09a09e71f` |

### D7-D9 README and validators

| File | Inherited index SHA-256 | Repaired working SHA-256 |
| --- | --- | --- |
| D7 `README.md` | `488c4f16766f252102612bfc74a40373ea83f7b1b874a0008d5e46499e9980f5` | `07075177da8a1524f50993f56c496526b40ed67b3d80d9ffe2a7d90724adbee0` |
| D7 validator | `e4615df43042dc799bd447fc4a73528d72c8af725cf74239580d8416a8bebdfe` | `349898eb24267f4b63739e904cec4f59fc8dd056cc0643211da85028cec4179d` |
| D8 `README.md` | `6f9cd470c0e5ef0aa6b621047385ba938c56fda5e26b12e684b795757f8f6e6f` | `4a265b4d521e6f49ccaf9776dbcdb194dc3863bf60da395d6ec82f1d287a20a8` |
| D8 validator | `3bbcfc2dfae5951712849c68840766dcfd7fcb1fc53a1a434860b9fee7941761` | `93f5f2489572d7eb216913182251d1d9dc935f912a9e514ab9cf5eee2a7da6c3` |
| D9 `README.md` | `f243077b0bebbb4285d6937d1600c9b4d588b1c0122ce259a33a19d84887706a` | `095778858821654b998ea1069899631a589996880e49fd2f1a2b973ac8f19ff4` |
| D9 validator | `5d9e3607b7986c482a8348ad003e7006cfdca358337d340825ac84f3b55e3dcd` | `66b25c28ed1f333be6571052e7c11c34317fda7f87b49ed86b6a47a71a682ce2` |

The declared before/after hashes in all three implementation receipts match
these independently calculated values exactly. The receipts themselves hash to:

- Isle historical seam: `15f28db2f5a939c64e128d9fd11b0d637046b95d3262797df95dc0d24cae963e`
- current-oracle seam: `091132ff73a9afeb5a95f458feaddde9ab97ce2f97962ff962570dcc9267d57e`
- D7-D9 authority migration: `e9a14d9fcd27180e946514c8d059c3bef4915d76e2fe4851c12135402cc22fb8`

## Historical truth and current fail-closed authority

The rejected Isle predecessor remains reproducible rather than silently
reclassified as current:

- still manifest: `9b72ca941c1d96699d67060f3e75312074364ab5b027591827514bee335aebe7`
- motion manifest: `ee99617b2a9e17cb73825900b0af8295656ba4e2c63e6c6c54598b5af6fd584f`
- capture generator: `47768e4b2d6288b9c3dbb4b0ad19cd870b61a8804d72673c53bf3326f8f5636a`
- capture-time rejected adapter: `1b36a0ad92ded4607e0c1e0df5d5581d1c7afff5843cb75cd4c490790a86c413`
- manifest-recorded capture-time builder: `9525ead815e95d7bc0b5fa8beae389954e232a9bbf51b54ed049a84a3613b9c0`
- retained movie: `d45ce3e3e28497c46f3828508175b301f13be9368e8879d4920a2641fb3d934d`,
  exactly `22,049,152` bytes.

The repaired tests separately require the accepted current seam:

- world builder: `28be094c674108f42be040f2b3ae6d242838d15e2060f6cf4668b0a003f1a682`
- Variant C live adapter: `e2767b01fab68d7f16ffe2e7f8e0313c711347e2006a72e028c19aaa2195b891`
- Variant C reviewed factory: `b24fd72cd12aa0c6c45a123f005fc834ea657c343e8332a872eae07fa017ace7`
- promoted material: `488ad52ae9aa0155fd0356eaff128b3ab88ba0c23528c6ae332e7e54c772ffb6`
- promoted texture: `0abbb429066966c1cfc1e0209a2a454c41dae73743fc119ffdf7cd82ee3ef35d`
- catalog: `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`
- registry: `dce268c1547e4e4620faff9d59110ee1214a9a2121c1f83b3eb1c865339360ab`
- generated manifest: `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`.

Static review found no weakening. The prototype contract still validates its
full sealed geometry/material/topology/truth package, adds an exact rejected
adapter byte pin, rejects the predecessor from builder and registry, and
requires one Variant C builder dispatch. The Phase 2 contract retains every
manifest, capture, package, UV, topology, and zero-ownership check; its sole
new allowance is the exact promoted shared brick through the exact accepted
Variant C boundary, with source/evidence/pilot/URL/private-path and predecessor
dependencies rejected. The live-evidence contract now reads the old builder
hash from the immutable capture manifest while independently pinning current
Variant C-only dispatch. No old-adapter stack or fallback is permitted.

Batch 02/03/04 each change only the stale builder SHA constant; every semantic,
protected-complement, material, ownership, geometry, topology, and non-target
assertion remains intact.

D7 preserves historical registry receipt `c60e20fb625fa98809975f08357370d71c330443a7546d88fadfcd7df3584d19`.
D8 and D9 preserve historical receipt
`acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af`.
All three separately hash current registry `dce268…`, derive and assert
`213 / 214 / 215`, assert the exact five accepted physical-unit IDs and
`5/213`, and reject the two Isle part records as numerator units. The validators
recomputed all packet/source/receiver/record/chunk hashes; the packet bodies
remain byte-unchanged.

## Independent execution

The exact project-local engine reported
`4.7.2.stable.official.ed1daf0bf`. Every requested command exited `0`, with no
engine warning or error in the captured output.

| Gate | Independent result |
| --- | --- |
| Repaired Isle prototype contract, twice | PASS twice; deterministic signature `7f299bf99599c2f3f9feb982fb857663355645ffbf1eaa36e6714000b8c8d4cc` both runs |
| Repaired Phase 2 brick evidence contract, twice | PASS twice; historical trial sealed and only exact Variant C promotion live |
| Repaired rejected-parent live evidence contract, twice | PASS twice; six stills plus exact 222-frame movie preserved, Variant C-only current seam |
| Batch 02/03/04, twice each | PASS twice each with all existing semantic checks |
| Batch 06, twice | PASS twice; exact topology `735 / 940 / 954 / 64,118 / 466` |
| D7 validator, twice | PASS twice; 15 IDs, 45 hashes, 270 fields, 60 partitions, 15 links, readiness `13/2/0` |
| D8 validator, twice | PASS twice; 15 IDs, 45 hashes, 300 fields, 60 partitions, 15 links, readiness `10/4/1` |
| D9 validator, twice | PASS twice; 15 IDs, 45 hashes, 300 fields, 60 partitions, 15 links, readiness `9/5/1` |
| Registry compiler `--check`, twice | PASS twice; catalog `2b4579…`, registry `dce268…`, 213 units, 214 receivers, 215 source memberships, 4,971 runs, `5/213` |
| Node registry test | PASS; exact current catalog/registry counts and accepted set |
| Node loader test | PASS; 14 plans, 8 package-safe, 6 disabled, 13 pathless projections |
| Generated-world validator | valid; 38 chunks, 739 source rows, 729 physical objects, content `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164` |
| Full runtime | PASS; world ready, player enabled, gameplay/physics/interactions exercised, topology `735 / 940 / 954 / 64,118 / 466 / 466`, baseline/final scene nodes `1/1` |

## Conclusion

The repairs correctly separate immutable historical provenance from moving
exact-current authority and close the stale seams without changing product
content or weakening the sealed contracts. The twelve repaired files, three
implementation receipts, this independent recheck, and append-only RETRO
entries are approved for exact restaging. This review did not stage, commit,
push, upload, or edit any other file.
