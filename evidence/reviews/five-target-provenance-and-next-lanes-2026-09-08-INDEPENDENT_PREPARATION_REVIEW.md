# Independent five-target provenance and next-lane preparation review

Date: 2026-09-08  
Reviewer: `/root/next_building_prep`  
Worktree: `treasure-island-d2-provenance`, branch `codex/d2-provenance-1431-1436`  
Checked HEAD: `b4ab09356c8a15843fa295af024434f97027e1fe`

## Decision and independence

**PASS for local documentation integrity, with the scope notes below.** This
review did not author the five-target patch, implement any candidate, or inspect
new external references. It reviewed the complete current main `AGENTS.md` and
`NEXT_AGENT_HANDOFF_2026-09-08.md`, the isolated patch, validator, local source
contracts, and the named historical reviews. The source-page observations are
inherited research claims, not independently re-observed facts from this round.
This is no live source gate, visual acceptance, integration permission, or
recognition credit. Catalog authority remains 9/213; all five targets, 1439,
1444, and Dormitory 369 remain unaccepted as physical recognition units.

The independent reviewer made no product, authority, export, Git transaction,
capture, or launch changes. The only authored paths are this new review and an
appended named section in the isolated `discovery/RETRO_LOG.md`. Main and the
1439 worktree were read only.

## Five-target patch checks

The pre-review dirty scope exactly matches the handoff: seven tracked Markdown
documents and one untracked JavaScript validator. All eight input hashes below
match the handoff. `git diff --check` passes. The validator exits 0 and reports
15 D2 packets, five ledger targets, matching local receiver identities and
geometry hashes, resolved local links, the written no-pixel boundary, and no
acceptance records for these targets. Inspection of the diff finds no product,
catalog, runtime, source-geometry, or binary addition.

| Checked input | SHA-256 |
| --- | --- |
| D2 index | `515de1e601339a04d08a356efd3febe5dff4703fe1b0e5613a4e6b1c7327cd1a` |
| 1437 packet | `4944702f81f1b8a40a2ed50e45b420b83867a4f245e7416a2785fab91ceca7e0` |
| 1449 packet | `9a703aeab66c61a590a6ed81b22548ee83520a34c628f20aae32d5fcf8afed2d` |
| 1438 packet | `336d295f7316d3e49970c24f06da122ae1a0d11e9034839181ed9d15af8b4d31` |
| 1436 packet | `bcdcf517ad5f0c619b0c5cddf7412a661967ec1db9c761c8a98d0643f951ce4e` |
| 1431 packet | `a8088602e0ecad9985e3603e676dba1cc90a33e071ed56016ac36e7030c0406d` |
| Validator | `a0fe2c6c9b1da2e0072afd3429628d4f60e2c506a830a86a7ba5393c8a18f4e2` |
| RETRO before this review | `739e68b929d0edee177c426c295f2b22bd0d36c6f27962c47023c5fd4a8a04c4` |

The isolated catalog and registry hashes remain respectively
`dc6d121d48621f98a203f2fea458316a46446a11e5f2a77d4064694322b2baa2`
and `26dcf64a34cf92aa7766c60940933190cdb5f9bc595dc23dc2f16fa01752e16c`.

The changed packets correctly separate EAS base/address identifiers, civic
identity, management lifecycle, visible cues, inferred compass association, and
unknown sides. 1431 remains D5 and does not inflate the D2 cohort. 1436 is limited
to an attributed 2016 front and inferred ENE runs `0,1,8,16`; 1431 remains a
March 2025 NNW/WSW corner study. 1437, 1438, and 1449 gain zero transferable
appearance cues. No local claim promotes any of these units.

Two qualifications matter when using this patch:

- The validator checks the presence of the no-pixel policy and target status;
  its labels alone do not establish a whole-tree privacy audit, unchanged global
  authority, external URL validity, or visual truth. The checked Git scope and
  exact authority hashes separately support the local conclusions above.
- The inherited 1437/1449 instruction to seek both post-removal lifecycle and
  a target exterior must not become a requirement to reconcile the frozen
  inventory against 2026 survival. Current `AGENTS.md` explicitly rules out
  that reconciliation. Appearance is the actual blocking gap; later lifecycle
  is an unknown. A documentation follow-up should clarify this distinction,
  without inventing appearance cues or altering frozen units.

Before any documentation integration, preserve the dirty candidate, perform the
assigned bounded rebase/transplant and deliberate RETRO merge, then check the
new diff and authority hashes. Preserve the external observation attribution;
any new implementation still requires its independent source gate.

## 1444: canonical texture blocker was already cleared

The handoff and original standalone bar-raiser repeat a historical blocker.
The later existing [independent package audit](../first-playable/site-12-stucco-package-promotion-2026-09-04/INDEPENDENT_PACKAGE_AUDIT.md)
explicitly clears it; its checked SHA-256 is
`285ad681634bfa4ec800be0a935bb17b3e850e384581300357ce1e56b1ff09b1`.
The promotion directory's two-entry `CHECKSUMS.sha256` verifies successfully.
The canonical retained PCK still exists in main at
`build/site-12-stucco-package-promotion-review/Treasure Island First Playable.pck`,
with independently rehashed size `65,271,192` and SHA-256
`cf5dd99349c88cb78fd9d0df39ecedf7c84536b3652ee56e0e1b689a62e75489`.
The historical audit records successful outside-checkout mounts of that PCK
and a second canonical export. No mount or export was repeated this round.

The exact existing stucco closure is:

- `site_12_ochre_tan_stucco.tres` references only the accepted
  `game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png`.
- Material SHA-256 is
  `9486ccf52e1f2aff9fc940f60644733d5cf9bf1cb03cebb5332bcc1d7c0aaaf6`;
  tint `(0.78,0.61,0.42,1)`, roughness `0.88`, metallic `0`, meter UV XY
  `0.333333`, no normal or roughness maps are preserved.
- Promoted and historical pilot PNGs both hash to
  `af1c7a8f90ab5e60b9ab40a3bcf087aa26b00892edd48a2b4f1c84533f8be51c`.
  The canonical `.import` points to the promoted resource and its own imported
  `.ctex`; historical evidence keeps the excluded pilot copy.
- The current preset hash is
  `e54969d6127ee55691113217e5129a7c5e9b3e841168a6b91f3fc74ba278456f`.
  It still excludes pilot texture/material and discovery/evidence trees, and
  leaves the canonical Site-12 texture available. It is newer than the 2026-09-04
  receipt preset; the old PCK is not an exact-current whole-game package proof.

The existing 1444 package contract enumerates the complete 13-path runtime
closure: config, factory, standalone scene, frozen chunk, Site-12 kit, six
materials, promoted stucco, and existing Poly Haven bitumen. Its checked hash
is `6efc37e395da2ca02633d56159bf15b8b53b4ee68ebf599cb095416453bbdccc`;
current config and factory hashes are respectively
`1176b20c7ab350733dc0f07cb7ab2d46b88077f6378bd9380af3756a069e9fae`
and `0c5cada54350d0a8dcd37fb1ecd737d91c5eab3ce1c469e423683ab30285cfc8`.

**Minimum next action:** reuse this closure in a new isolated fail-closed live
wall+roof replacement for `w95934117`. Do not copy/regenerate the texture or
relax exclusions again. Preserve mapped runs `8,9,11,12,15,16,17` and the fifteen
protected runs. Test two undercroft fields, far balcony, roof/collision, sole
wall spray ownership, and ordinary-player motion. The new candidate still needs
fresh source/mechanical, exact-current mounted-package, and independent visual
gates; the historical texture audit supplies no live acceptance.

## Dormitory 369 and 1439 next steps

Dormitory's initial P3 material-only packet is historical phase context. The
later standalone bar-raiser explicitly grants `PASS_WITH_LIMITATION` for one
paired live study; checked review hash is
`0e2292aa35748bd71b869ff2a735a4bcf23050f0b80c6c0a4319f556ca98d5bb`.
Current standalone config hash is
`b02b098bfeca628cd6a71e7393897d53f5f46dfd0efddd915e316c2dd5204c2e`.
Existing source observations support five occupied tiers, broad/narrow opening
rhythm, ground band, end/stair volume, and eave. No new source search is necessary
to start the already bounded live study.

Use exact `w291189926` wall+roof in `x_0__z_1`, intercept both before generic
construction, remove the fallback 6 m collider/visual pair, preserve source XZ
and wall bottoms, and lift the roof congruently to inferred `Y=18.39 m`. Keep
modules on source edge 5/runs `0..5`, all `6..71` neutral, with explicit sole
wall spray ownership. The first live gate should target fine-edge aliasing,
protected-shell coherence, near ground band, real roof landing, and stair/eave
collision. Its existing standalone signature/topology is a starting contract,
not a reason to avoid substantive ordinary-gameplay improvement.

1439's dirty path set is unchanged, and its isolated review rehashes to
`ba04c761f02908c36890d3b06f7c7ae049f07857325db7a8d680c8db235ef47d`,
with literal `PASS_FOR_1439_POST_B1_REBASE`. Preserve that explicit post-B1
rebase/re-audit boundary. No 1439 worktree bytes were written.

**Independent progress:** 1444 and Dormitory may each start isolated bounded
live implementation while B1 proceeds; documentation clarification and later
1436/1431 detached studies are also independent. Serialize authority integration
and refresh exact-current gates after it. 1439's next transplant waits for an
independently accepted B1 baseline. Every lane currently earns `+0`.
