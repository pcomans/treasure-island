# Pre-commit Isle House historical-seam repair

Date: 2026-09-04

## Scope

This is a test-contract migration only. It reconciles two sealed prototype-era
contracts with the later independently accepted Variant C live replacement.
It does not change world construction, facade geometry, materials, captures,
collision, navigation, spray ownership, topology, or recognition acceptance.

## Findings and repairs

- `headless_isle_house_low_facade_prototype_contract.gd` still required the
  rejected 5-mesh attachment in `world_chunk_builder.gd`. The repaired
  contract keeps the rejected attachment byte-pinned and reproducible, but
  requires it to be absent from the builder and registry. It now requires the
  accepted Variant C attachment to be the sole low-receiver builder seam and
  rejects predecessor stacking or fallback.
- `headless_isle_house_low_genai_brick_phase2_evidence_contract.gd` still
  prohibited the exact brick material that was later independently promoted.
  The repaired contract preserves the historical trial manifest, captures,
  PCK comparison, topology, and hashes. It permits only the exact promoted
  package-safe shared material and texture through accepted Variant C, while
  rejecting pilot/source-only paths and the rejected live attachment.
- `headless_isle_house_low_live_evidence_contract.gd` compared the mutable
  current builder file directly to its rejected-parent capture hash. The
  repaired contract validates `9525ead8...` from the immutable capture
  manifest, keeps the rejected adapter and all media hashes exact, and adds a
  separate current-builder check for `28be094c...`, Variant C-only dispatch,
  and absence of the rejected stack/fallback.

## Byte migration

| Contract | Before SHA-256 | After SHA-256 |
| --- | --- | --- |
| Isle low prototype | `4988bf386b46ba9aa000d5c9a3dfd52ce14596a7c3d729b2dd80d157ce35a8c9` | `a13c8d2c616f3a08076e277ffbd43416f71ed0128dd89e675c349d320e30d9ef` |
| Phase 2 brick evidence | `f1ebe95d777422eb2f2cc0b24c197083ec1c50795518523b9af0a0ddd4b3c601` | `b276390f8b418a9429d85945c735641312b82ea251ccfe61054f2a201e5437dc` |
| Rejected-parent live evidence | `7266eb74bd881f71b69c2cdab387abae88a7eb25ad9237643fb2d293e560a7f4` | `87b0f8b599c5c7579308b82d5d334c0b54133bc809190947877ce3ef2fa3029f` |

The unchanged active boundary remains:

- world builder: `28be094c674108f42be040f2b3ae6d242838d15e2060f6cf4668b0a003f1a682`
- rejected attachment: `1b36a0ad92ded4607e0c1e0df5d5581d1c7afff5843cb75cd4c490790a86c413`
- accepted Variant C attachment: `e2767b01fab68d7f16ffe2e7f8e0313c711347e2006a72e028c19aaa2195b891`
- runtime registry: `dce268c1547e4e4620faff9d59110ee1214a9a2121c1f83b3eb1c865339360ab`
- promoted brick material: `488ad52ae9aa0155fd0356eaff128b3ab88ba0c23528c6ae332e7e54c772ffb6`
- promoted brick texture: `0abbb429066966c1cfc1e0209a2a454c41dae73743fc119ffdf7cd82ee3ef35d`

## Focused verification

All three repaired contracts passed twice with Godot
`4.7.2.stable.official.ed1daf0bf`. The prototype retained deterministic
signature
`7f299bf99599c2f3f9feb982fb857663355645ffbf1eaa36e6714000b8c8d4cc`.
Independent recheck remains required before the milestone commit.
