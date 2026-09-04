# Pre-commit evidence AVI Git LFS independent audit

Date: 2026-09-04  
Independent reviewer: `/root/remote_runtime_auditor/ledger_recheck`  
Implementation under review: `/root/d8_reference_research`  
Policy receipt: `PRECOMMIT_AVI_LFS_POLICY.md`, SHA-256
`a45e71083c731133ddebdbeb92bb078de512176354ca90d7f1429bfe05c66300`  
Verdict: **PASS for explicit local staging as Git LFS pointers**

## Decision

The scoped local Git LFS implementation is independently accepted for the
next reversible step: explicitly stage `.gitattributes` and the seven named
AVI paths, then inspect the staged blobs as pointers before any commit.

The implementation is fail-closed and byte preserving:

- exactly seven repository evidence files are AVIs;
- all seven and only those seven resolve to `filter=lfs`, `diff=lfs`,
  `merge=lfs`, `text=unset`;
- every clean-filter result is a strict canonical three-line pointer whose
  OID and declared size equal the evidence artifact's SHA-256 and byte count;
- every pointer smudges from the private local object store to output that is
  byte-identical to the original working file;
- all seven originals retain their pre-audit hashes and sizes;
- the Git index remains empty, and no commit, push, LFS upload, or ordinary
  AVI Git blob was created by this review.

The unresolved repository-owner storage/budget question does **not** block
local staging. It remains a hard pre-push/upload gate: the dry runs do not
exercise server-side quota acceptance, and this reviewer does not claim that
the owner's remaining LFS capacity can accept the 107,513,596-byte cohort.

## Exact payload and pointer ledger

| Evidence AVI | Bytes | Working/LFS OID SHA-256 | Pointer bytes | Result |
| --- | ---: | --- | ---: | --- |
| `d2-1439-chinook-standalone-hero-2026-09-04/d2-1439-chinook-sse-stock-walk.avi` | 6,332,942 | `a7ad0649b4b9a805fe4cdefb1f8f38326aaf597ab381cb5aee101c3b87f2e7aa` | 132 | PASS |
| `d2-1441-chinook-standalone-hero-2026-09-04/d2-1441-chinook-sse-stock-walk.avi` | 15,553,064 | `1f7b42f4b83c0225146044cfc9794f71575d19e06147e15ebc7f0aa46b3f7d03` | 133 | PASS |
| `d2-1444-croaker-standalone-hero-2026-09-04/d2-1444-croaker-wsw-stock-walk.avi` | 6,078,080 | `3afe7d57f60d8c2b7330f49fa3bc414d915404a23ea774778407fa58710770b4` | 132 | PASS |
| `isle-house-composite-repair-standalone-v1-2026-09-04/isle-house-composite-repair-public-corner-stock-walk.avi` | 18,648,756 | `18bebf8f60f2c8a201f7ad7f8d392da6edd6c820dd1a8eee261d5af1d39031b0` | 133 | PASS |
| `isle-house-composite-repair-variant-c-live-replacement-2026-09-04/isle-house-variant-c-actual-live-public-corner-stock-walk.avi` | 19,833,852 | `930c444e5599bb5dad82883d7f29331c0fbfdc9be3039967fb3fc59f9491f957` | 133 | PASS |
| `isle-house-composite-repair-variant-c-standalone-v1-2026-09-04/isle-house-composite-repair-variant-c-public-corner-stock-walk.avi` | 19,017,750 | `99623c498180eba8475fda0e3c99eda30fa45608a15ee747c4db62c55b614245` | 133 | PASS |
| `isle-house-low-live-integration-2026-09-04/isle-house-low-public-corner-stock-walk.avi` | 22,049,152 | `d45ce3e3e28497c46f3828508175b301f13be9368e8879d4920a2641fb3d934d` | 133 | PASS |

Total: **7 objects / 107,513,596 bytes / 102.533 MiB**. The local object
store contains exactly these seven hashes at exactly these seven sizes, both
before and after the independent round trips.

## Attribute and repository boundary

`.gitattributes` is exactly 42 bytes, SHA-256
`c62631e7a4a6cdd6909574ec9574bcc1dfa56e7add59a456ee37019ac47f1405`,
and contains one effective rule:

```gitattributes
*.avi filter=lfs diff=lfs merge=lfs -text
```

A batched `git check-attr` over every tracked and nonignored untracked path
reported:

- LFS-filtered paths: `7`;
- LFS-filtered non-AVI paths: `0`;
- repository AVIs outside private `.git`/`.tools` state: `7`;
- AVI paths in the index: `0`;
- AVI paths in `HEAD`: `0`;
- AVI paths in all existing repository history: `0`.

All seven are presently untracked and unignored. `.tools/` is ignored by the
repository, no `.tools` path is tracked, and the executable/archive therefore
remain private to this checkout. `.git/config`, `.git/hooks/pre-push`, and
`.git/lfs/objects` are Git-private metadata, not worktree publication paths.
There is no `.lfsconfig` or `.git/info/attributes` override.

## Installation and trust receipt

The exact project-local tool reports:

`git-lfs/3.8.0 (GitHub; darwin arm64; go 1.27.0; git aece9221)`

Independent local checks reproduced:

| Artifact/check | Exact result |
| --- | --- |
| executable | 13,255,424 bytes; `8cb21d1fa650af82a06eaa98c6078303bacf2f101199be3d77ab7370ec712bd0`; thin arm64 Mach-O |
| executable signature | strict `codesign` PASS; Developer ID Application `GitHub (VEKTX9H2N7)`; Team ID `VEKTX9H2N7` |
| source archive | 5,550,634 bytes; `caff76a7d070d8160c89bc39b6e85d98f24135b6fed038a3b4de2590d25102d8` |
| archive integrity | PASS; 82 entries; zero absolute/traversal/backslash/wrong-prefix/duplicate/symlink paths |
| ambient executable | no `git-lfs` on the ordinary process PATH |
| hook | executable 350-byte repository-local `.git/hooks/pre-push`; normal `git lfs pre-push "$@"` delegation |

`INSTALL_LOG.md` records the same installation boundary and has current
SHA-256 `6a36809498a673226305b5ceb6f860b2f42e9be8d2b0d3450645e30f6adb5419`.
The only LFS filter configuration observed is the expected four-key block in
the repository's `.git/config`:

```text
filter.lfs.clean   git-lfs clean -- %f
filter.lfs.smudge  git-lfs smudge -- %f
filter.lfs.process git-lfs filter-process
filter.lfs.required true
```

`git config --show-origin` attributes all four to `.git/config`. Global and
system `filter.lfs.*` queries are unset. The default `.git/hooks` path remains
active. These checks find no global/system Git or shell-PATH mutation.

## Evidence contract and hash audit

All seven motion manifests name the expected AVI and pin the exact SHA-256 and
byte size in the payload table. The six packets that carry checksum ledgers
all pass their AVI ledger entry through `shasum -a 256 -c`. The 1441 packet
has no separate checksum ledger; its motion manifest and Godot evidence
contract independently pin and read its exact hash and 15,553,064-byte size.

After the LFS round trips, the six exact-current/standalone evidence contracts
each passed twice under Godot `4.7.2.stable.official.ed1daf0bf`:

- D2 1439 Chinook;
- D2 1441 Chinook;
- D2 1444 Croaker;
- Isle House standalone Variant B;
- Isle House actual-live Variant C replacement;
- Isle House standalone Variant C.

The seventh test,
`headless_isle_house_low_live_evidence_contract.gd`, reproducibly exits `1`
at its intentionally immutable capture-time world-builder SHA before it reads
the movie. The already accepted topology-oracle recheck explicitly classifies
that older rejected Isle-low contract as historical rather than a current
Variant C gate. Its AVI remains independently valid: motion-manifest pin,
checksum-ledger entry, actual RIFF/AVI header, actual size/hash, canonical LFS
pointer, and clean/smudge byte comparison all pass. This pre-existing
historical runtime-pin failure is not caused or hidden by LFS and does not
block pointer staging.

## LFS plumbing and remote-safe checks

With only the exact project-local binary prepended to PATH:

- `git lfs fsck`: exit `0`, `Git LFS fsck OK`;
- `git lfs status`: exit `0`, no objects to commit or push;
- `git lfs ls-files --long`: exit `0`, empty because nothing is staged or
  tracked yet;
- `git diff --cached --quiet`: exit `0`;
- `git ls-remote --exit-code origin HEAD`: exit `0`, current remote HEAD
  `5d0f853c38a95c35ef73a045c6ad87362cc35014`;
- remote HEAD contains zero AVIs, zero LFS pointer markers, and no
  `.gitattributes`;
- `git lfs locks --limit=1`: exit `0` with an empty read-only result;
- `git lfs push --dry-run origin HEAD`: exit `0`, no candidates;
- explicit `git lfs push --dry-run --object-id origin <seven OIDs>`: exit `0`
  and enumerates exactly the seven private local objects above.

The explicit object dry run is selection proof only. It did not upload or
make a remote LFS batch request and therefore does not prove upload
authorization, server quota, owner billing state, or archive-inclusion policy.

## Next safe step and stop condition

Proceed with one explicitly scoped local staging action naming only:

1. `.gitattributes`;
2. the seven AVI paths in the payload ledger.

Immediately afterward, an independent staged-state check must require exactly
eight newly staged paths, read each staged AVI blob with `git show :<path>`,
require a strict three-line LFS pointer, and match all seven OIDs/sizes to this
ledger. It must also prove no staged AVI blob contains RIFF payload bytes and
rerun `git lfs status`/`git lfs fsck` with the project-local binary on PATH.

Do not push until owner `pcomans` confirms acceptable remaining LFS
storage/budget for **102.533 MiB** and the pre-push review passes. Source-
archive LFS inclusion is a separate optional owner decision; it does not block
local staging or a local pointer commit.

## Mutation boundary

This independent audit writes only this report and one append-only
`discovery/RETRO_LOG.md` entry. It does not edit an AVI, manifest, checksum
ledger, evidence contract, production/package/config/topology file,
`.gitattributes`, installation receipt, private LFS state, or Git index. It
does not stage, commit, push, or upload anything.
