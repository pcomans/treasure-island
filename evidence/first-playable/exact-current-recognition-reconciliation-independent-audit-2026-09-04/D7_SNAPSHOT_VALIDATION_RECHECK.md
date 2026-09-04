# D7 snapshot-labeling validation closure recheck

Date: 2026-09-04  
Reviewer: `/root/d6_reference_research`  
Role: independent rechecker; this reviewer did not implement the D7 repair

## Verdict

**CLOSED.**

The D7 README and validator now make the required two time layers explicit:

- `c60e20fb625fa98809975f08357370d71c330443a7546d88fadfcd7df3584d19`
  is labeled only as the historical D7 packet-time registry snapshot receipt.
  The README says those bytes were superseded and are not the current file;
  the validator records the receipt as
  `recorded_receipt_only_not_current_file_bytes` and asserts that its hash is
  different from the current registry authority.
- `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af`
  is separately pinned and hashed as the current registry file. The unchanged
  catalog authority is
  `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.

There is no remaining wording or validator path that presents `c60e20…` as an
exact-current registry claim.

## Exact-current semantics

The new current-state validation is semantic as well as byte-exact. It derives
and requires:

- 213 physical recognition units;
- 214 direct wall receivers;
- 215 source-record memberships;
- the exact five accepted physical-unit IDs in both catalog and registry;
- recognition metric numerator/denominator/display exactly `5 / 213 / 5/213`;
- claim totals exactly 5 accepted and 208 not evaluated; and
- Isle House part records `w1282547786` and `w1282547787` absent from physical
  units and present only in the declared non-numerator source-key boundary.

The exact accepted set remains:

- `physical-building:r16681702`
- `physical-building:w1222720021`
- `physical-building:w1249412093`
- `physical-building:w1249412094`
- `physical-building:w34313540`

## No weakening of D7 packet checks

The pre-existing local contract path remains active before the new provenance
and exact-current checks. A fresh run still:

- derives the same 15 IDs after exactly 106 prior unique packet IDs;
- requires every entity to be a standalone footprint with zero part children,
  one exact direct wall receiver, and one exact direct roof receiver;
- recomputes all 45 chunk/record/geometry hashes;
- checks all 270 exact packet fields and all 60 facing partitions;
- checks all 15 packet links, required headings, confusion/blocker boundaries,
  and no-pixel-retention statements; and
- reproduces readiness `13 prototype / 2 component / 0 blocked`.

Those are the same counters and outcomes recorded by the sealed D7 audit before
the documentation repair. The repair adds historical/current separation and
current recognition invariants; it does not bypass, reduce, or replace the
packet, geometry, source-boundary, or readiness loops.

The D7 directory is presently an untracked milestone directory in the shared
worktree, so Git cannot supply a tracked intra-file before/after diff. I checked
the current source against the prior independent discrepancy description and
the preserved validator counters rather than claiming an unavailable Git
baseline.

## Independent commands

| Gate | Result |
| --- | --- |
| `node discovery/facades/d7_reference_packets/validate_d7_packets.mjs` | PASS — 15 IDs, 45 hashes, 270 fields, 60 partitions, 15 links, readiness 13/2/0; historical `c60e20…`; current `acc04a…`; `5/213` |
| `node tools/build_facade_recognition_registry.mjs --check` | PASS — mode `check`, catalog `2b4579…`, registry `acc04a…`, 213/214/215, exact `5/213` |
| `node tools/validate_godot_world.mjs` | PASS — 38 chunks, 739 source rows, 729 physical objects, content `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164` |

Before and after those commands, the relevant exact file identities were
unchanged:

| File | SHA-256 |
| --- | --- |
| D7 README | `488c4f16766f252102612bfc74a40373ea83f7b1b874a0008d5e46499e9980f5` |
| D7 validator | `e4615df43042dc799bd447fc4a73528d72c8af725cf74239580d8416a8bebdfe` |
| recognition catalog | `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311` |
| runtime registry | `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af` |
| generated-world manifest | `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3` |

The compiler ran only in `--check` mode. This recheck made no D7 packet,
validator, catalog, registry, generated-world, runtime, production, or checksum
edit. No commit or push was made.

## Files changed by this reviewer

- `evidence/first-playable/exact-current-recognition-reconciliation-independent-audit-2026-09-04/D7_SNAPSHOT_VALIDATION_RECHECK.md`
- `discovery/RETRO_LOG.md` (append-only reviewer entry)
