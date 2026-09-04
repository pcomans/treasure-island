# Pre-commit D7–D9 current-authority migration

Date: 2026-09-04

Implementer: `/root/remote_runtime_auditor/ledger_recheck/d7_d9_authority_fix`

Scope: D7–D9 packet README and validator authority boundary only

Status: **implemented and verified; pending release-integrator review/staging**

## Outcome

The D7, D8, and D9 packet validators now distinguish immutable packet-time
registry provenance from the moving exact-current registry authority.

- D7 preserves packet-time registry receipt
  `c60e20fb625fa98809975f08357370d71c330443a7546d88fadfcd7df3584d19`.
- D8 and D9 preserve packet-time registry receipt
  `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af`.
- All three separately pin and hash the current registry at
  `dce268c1547e4e4620faff9d59110ee1214a9a2121c1f83b3eb1c865339360ab`.
- All three validate the unchanged catalog at
  `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`
  and exact current `213 / 214 / 215` recognition-unit, direct-receiver, and
  source-record-membership semantics.
- All three validate exactly five accepted physical units and metric `5/213`.
  The two Isle House part records remain explicit non-numerator sources.

The D7–D9 packet bodies remain byte-unchanged. In particular, the `acc04a…`
value retained by each sealed D9 packet header is packet-time provenance: it
was also the separately checked current registry when D9 sealed. The D9 README
and validator now name `dce268…` as the distinct current authority without
rewriting that historical statement.

## Exact six-file change boundary

| File | Before SHA-256 | After SHA-256 | Change |
| --- | --- | --- | --- |
| `discovery/facades/d7_reference_packets/README.md` | `488c4f16766f252102612bfc74a40373ea83f7b1b874a0008d5e46499e9980f5` | `07075177da8a1524f50993f56c496526b40ed67b3d80d9ffe2a7d90724adbee0` | repin and describe distinct current registry |
| `discovery/facades/d7_reference_packets/validate_d7_packets.mjs` | `e4615df43042dc799bd447fc4a73528d72c8af725cf74239580d8416a8bebdfe` | `349898eb24267f4b63739e904cec4f59fc8dd056cc0643211da85028cec4179d` | repin current registry only; keep historical receipt gate |
| `discovery/facades/d8_reference_packets/README.md` | `6f9cd470c0e5ef0aa6b621047385ba938c56fda5e26b12e684b795757f8f6e6f` | `4a265b4d521e6f49ccaf9776dbcdb194dc3863bf60da395d6ec82f1d287a20a8` | split packet-time and exact-current authority |
| `discovery/facades/d8_reference_packets/validate_d8_packets.mjs` | `3bbcfc2dfae5951712849c68840766dcfd7fcb1fc53a1a434860b9fee7941761` | `93f5f2489572d7eb216913182251d1d9dc935f912a9e514ab9cf5eee2a7da6c3` | add immutable receipt and exact current recognition-state gates |
| `discovery/facades/d9_reference_packets/README.md` | `f243077b0bebbb4285d6937d1600c9b4d588b1c0122ce259a33a19d84887706a` | `095778858821654b998ea1069899631a589996880e49fd2f1a2b973ac8f19ff4` | preserve seal-time receipt and name distinct current registry |
| `discovery/facades/d9_reference_packets/validate_d9_packets.mjs` | `5d9e3607b7986c482a8348ad003e7006cfdca358337d340825ac84f3b55e3dcd` | `66b25c28ed1f333be6571052e7c11c34317fda7f87b49ed86b6a47a71a682ce2` | separate historical/current hashes and strengthen declared/derived count gates |

The six-file diff is 128 insertions and 21 deletions. It changes no packet ID,
packet body, packet field, receiver/run contract, source link, readiness class,
registry/catalog bytes, generated artifact, runtime behavior, or recognition
claim.

## Preserved packet gates

Two consecutive post-change runs produced the same passing results:

| Packet set | Exact repeated result |
| --- | --- |
| D7 | 15 IDs; 45 recomputed hashes; 270 exact fields; 60 facing partitions; 15 links; readiness `13/2/0`; historical `c60e20…`; current `dce268…`; `5/213` |
| D8 | 15 IDs; 45 recomputed hashes; 300 exact fields; 60 facing partitions; 15 links; readiness `10/4/1`; historical `acc04a…`; current `dce268…`; `5/213` |
| D9 | 15 IDs; 45 recomputed hashes; 300 exact fields; 60 facing partitions; 15 links; readiness `9/5/1`; historical `acc04a…`; current `dce268…`; `5/213` |

All three validator syntax checks also exited `0`. The validators continue to
reject cohort drift, part children, non-singular wall/roof bindings, geometry,
record or chunk hash drift, packet field/run/link drift, readiness drift, and
unexpected files or images.

## Compiler and world verification

Both requested independent checks exited `0`:

- `node tools/build_facade_recognition_registry.mjs --check` reported status
  `pass`, catalog `2b4579…`, registry `dce268…`, 213 recognition units, 214
  direct receivers, 215 source records, 4,971 visible wall runs, 14 adapter
  plans (`8` package-safe / `6` disabled), 13 sanitized runtime projections,
  and exact metric `5/213`.
- `node tools/validate_godot_world.mjs` reported status `valid`, 38 chunks,
  739 source rows, 729 physical objects, and generated content SHA-256
  `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`.

## Mutation and Git boundary

This migration changes only the six named D7–D9 README/validator files and this
receipt. It does not edit the recognition catalog, runtime registry, packet
bodies, runtime, tests, generated world, media, package state, or retrospective
log.

The six owned files were already staged as additions before this repair began.
This implementer did not alter the shared index: the six fixes remain unstaged
on top of those inherited staged versions, and this receipt is untracked. No
file was staged, committed, pushed, or uploaded by this implementer.
