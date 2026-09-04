# Pre-commit evidence AVI Git LFS policy

Date: 2026-09-04

Executor: `/root/d8_reference_research`

Scope: seven untracked evidence AVIs and their storage boundary

Status: **local Git LFS implementation PASS; remote pre-push acceptance pending**

## Decision

Store the seven native evidence AVIs with Git LFS using the repository-owned
rule:

```gitattributes
*.avi filter=lfs diff=lfs merge=lfs -text
```

This is the safest progress-oriented option. It keeps the exact reviewed AVI
payloads and their existing evidence-contract hashes while preventing
`107,513,596` binary bytes from entering ordinary Git object history. Silent
ignore and ordinary Git blobs are rejected. Compressed derivatives or an
external release/artifact store remain possible later optimizations, but
neither is a byte-preserving substitute for these already reviewed authority
files.

The local implementation is complete and verified. Nothing is staged,
committed, pushed, or uploaded. A separate pre-push review must confirm staged
pointer bytes and owner quota/budget availability before remote publication.

## Exact AVI inventory

All seven files are untracked, unignored RIFF Motion JPEG AVIs at
`1280 × 800`, `30 fps`, with no reported audio stream. Their current bytes
match the hashes and sizes pinned by their motion manifests and Godot evidence
contracts.

| Evidence AVI | Bytes | SHA-256 | Canonical pointer bytes |
| --- | ---: | --- | ---: |
| `d2-1439-chinook-standalone-hero-2026-09-04/d2-1439-chinook-sse-stock-walk.avi` | 6,332,942 | `a7ad0649b4b9a805fe4cdefb1f8f38326aaf597ab381cb5aee101c3b87f2e7aa` | 132 |
| `d2-1441-chinook-standalone-hero-2026-09-04/d2-1441-chinook-sse-stock-walk.avi` | 15,553,064 | `1f7b42f4b83c0225146044cfc9794f71575d19e06147e15ebc7f0aa46b3f7d03` | 133 |
| `d2-1444-croaker-standalone-hero-2026-09-04/d2-1444-croaker-wsw-stock-walk.avi` | 6,078,080 | `3afe7d57f60d8c2b7330f49fa3bc414d915404a23ea774778407fa58710770b4` | 132 |
| `isle-house-composite-repair-standalone-v1-2026-09-04/isle-house-composite-repair-public-corner-stock-walk.avi` | 18,648,756 | `18bebf8f60f2c8a201f7ad7f8d392da6edd6c820dd1a8eee261d5af1d39031b0` | 133 |
| `isle-house-composite-repair-variant-c-live-replacement-2026-09-04/isle-house-variant-c-actual-live-public-corner-stock-walk.avi` | 19,833,852 | `930c444e5599bb5dad82883d7f29331c0fbfdc9be3039967fb3fc59f9491f957` | 133 |
| `isle-house-composite-repair-variant-c-standalone-v1-2026-09-04/isle-house-composite-repair-variant-c-public-corner-stock-walk.avi` | 19,017,750 | `99623c498180eba8475fda0e3c99eda30fa45608a15ee747c4db62c55b614245` | 133 |
| `isle-house-low-live-integration-2026-09-04/isle-house-low-public-corner-stock-walk.avi` | 22,049,152 | `d45ce3e3e28497c46f3828508175b301f13be9368e8879d4920a2641fb3d934d` | 133 |

Total: **107,513,596 bytes / 102.533 MiB / 0.100130 GiB**. Largest file:
22,049,152 bytes / 21.028 MiB.

Six packet checksum ledgers also pin their AVI directly. The 1441 packet has no
separate checksum file, but its evidence contract and motion manifest pin and
read the same exact `15,553,064` bytes and SHA-256. Thus none of the seven is a
disposable render by contract.

## Pre-implementation findings

- Git LFS was not installed or configured.
- `.gitattributes`, `.lfsconfig`, `.git/info/attributes`, and all
  `filter.lfs.*` settings were absent.
- Every AVI's filter/diff/merge/text attributes were unspecified.
- No AVI was ignored, staged, tracked, or present anywhere in repository
  history.
- An ordinary `git add` would therefore have stored full binary Git blobs.

## Local installation and trust receipt

Homebrew identified `git-lfs` `3.8.0` as its current stable formula, but its
shared `/opt/homebrew` prefix is not writable by this user. `brew install
git-lfs` stopped before installation, and a read-only bottle fetch hit this
host's invalid bottle-tag error. No `sudo`, `chown`, permission change, tap
trust, or Homebrew state mutation was used.

The fallback is deliberately project-local:

- installed path: `.tools/git-lfs/3.8.0/git-lfs-3.8.0/git-lfs`;
- official release: `git-lfs/git-lfs` tag `v3.8.0`, stable/non-draft/
  non-prerelease;
- macOS arm64 archive: `5,550,634` bytes, SHA-256
  `caff76a7d070d8160c89bc39b6e85d98f24135b6fed038a3b4de2590d25102d8`,
  matching the GitHub release API digest;
- ZIP verification: integrity PASS; 82 paths; zero unsafe, duplicate, symlink,
  or wrong-prefix entries;
- executable: `13,255,424` bytes, SHA-256
  `8cb21d1fa650af82a06eaa98c6078303bacf2f101199be3d77ab7370ec712bd0`,
  thin arm64 Mach-O;
- strict signature: PASS, Developer ID Application `GitHub (VEKTX9H2N7)`;
- version: `git-lfs/3.8.0 (GitHub; darwin arm64; go 1.27.0; git aece9221)`.

`git lfs install --local` was run with the project-local executable on the
process PATH. Exactly these private repository settings were created in
`.git/config`:

```text
filter.lfs.clean   git-lfs clean -- %f
filter.lfs.smudge  git-lfs smudge -- %f
filter.lfs.process git-lfs filter-process
filter.lfs.required true
```

It also created the normal private `.git/hooks/pre-push` hook. Global and
system LFS filter settings remain unset. Because the project-local tool is
ignored and not globally linked, every local LFS command in this checkout must
put this exact directory on PATH:

```bash
LFS_BIN_DIR="$PWD/.tools/git-lfs/3.8.0/git-lfs-3.8.0"
PATH="$LFS_BIN_DIR:$PATH" git lfs version
```

The repository-owned, presently untracked `.gitattributes` is 42 bytes with SHA-256
`c62631e7a4a6cdd6909574ec9574bcc1dfa56e7add59a456ee37019ac47f1405`.
All seven AVIs resolve to `filter=lfs`, `diff=lfs`, `merge=lfs`, `text=unset`.
A complete tracked/untracked path scan found zero non-AVI paths with any of
those LFS attributes.

## Clean/smudge proof and evidence-contract behavior

Each original AVI was streamed through `git lfs clean` without staging. Every
result passed strict canonical pointer validation and contained:

```text
version https://git-lfs.github.com/spec/v1
oid sha256:<the exact evidence SHA-256 above>
size <the exact evidence byte count above>
```

Each pointer was then streamed through `git lfs smudge` into a temporary file.
All seven hydrated outputs matched their originals by size, SHA-256, and
byte-for-byte comparison. All seven originals were rehashed afterward and
remained unchanged. Temporary files were removed. The clean operation created
exactly seven local, non-uploaded objects under `.git/lfs/objects`, totaling
the same `107,513,596` bytes.

This proves the current contracts retain their intended semantics under LFS:

- Git stores a small pointer in a future commit.
- A hydrated working tree still contains the exact native AVI bytes.
- The LFS object OID is the same SHA-256 already pinned by the packet.
- Existing manifests, checksum ledgers, reviews, and Godot contracts require
  no hash or filename rewrite.
- A pointer-only checkout fails the AVI hash/size/header checks rather than
  silently passing incomplete evidence.

The current export preset excludes `evidence/*` and `evidence/**/*`, and no
runtime asset depends on these AVIs. Therefore a pointer-only clone can still
build/run/export the game, but the seven evidence-contract tests require LFS
hydration.

## GitHub operational boundary

Read-only remote checks found:

- origin: `https://github.com/pcomans/treasure-island.git`;
- public, non-template repository; default branch `main`; GitHub Pages off;
- authenticated `pcomans-bot` has write but not admin permission;
- Git LFS endpoint resolves locally as
  `https://github.com/pcomans/treasure-island.git/info/lfs`;
- no LFS pointers or `.gitattributes` exist on the current remote default
  branch.

GitHub supports LFS for this repository type. Its current Free/Pro allowance
is 10 GiB of LFS storage and 10 GiB/month download bandwidth; this cohort alone
is approximately 1.001% of that storage allowance. However, LFS usage and
budget are charged to repository owner `pcomans`, and the collaborator bot
cannot inspect that owner's billing state. The attempted billing API reads
returned 404 / insufficient owner-user scope. Actual remaining headroom and a
budget that permits upload are therefore not yet proven.

Relevant official documentation:

- <https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-git-large-file-storage>
- <https://docs.github.com/en/billing/concepts/product-billing/git-lfs>
- <https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/managing-repository-settings/managing-git-lfs-objects-in-archives-of-your-repository>

## Clone, archive, and build behavior

- A normal clone made with Git LFS installed hydrates the AVIs during checkout.
- In an existing clone, `git lfs pull` hydrates pointer files after LFS is
  installed.
- A clone without Git LFS, with smudge skipped, or after a quota/download
  failure contains pointer text. Game build/run/export remains independent;
  AVI evidence contracts fail closed.
- GitHub-generated ZIP/tar source archives contain only LFS pointers by
  default. Repository admin `pcomans` may enable “Include Git LFS objects in
  archives” if archive consumers must run the evidence contracts; archive
  downloads then count against LFS bandwidth. `pcomans-bot` cannot change this
  admin setting.

## Alternatives considered

### Git LFS — selected

Advantages: exact current evidence bytes; SHA/OID alignment; Git-versioned
paths and manifests; no ordinary-history bloat; no visual re-review. Costs:
LFS-aware clone setup, owner storage/bandwidth accounting, and pointer-only
source archives unless admin inclusion is enabled.

### Durable release or artifact references — fallback only

A GitHub Release asset or durable object store could keep videos out of clones,
but the seven source contracts currently read exact local `res://evidence/...`
paths. Promotion would require an immutable asset inventory, authenticated or
public retrieval policy, explicit hydration command, offline/failure behavior,
and new verification that the downloaded bytes match the current hashes.
Release assets can also be deleted or replaced administratively and are not
intrinsically tied to a tree entry. This is more operational machinery than
the current 102.53 MiB cohort warrants.

### Compressed derivatives — optional access copies, not authority replacement

H.264/HEVC/WebM derivatives would likely be smaller and easier to preview, but
transcoding changes the reviewed bytes, codec/container, frame behavior, and
all pinned hashes/sizes. Replacing the AVIs would require contract/manifest/
checksum edits and fresh motion/visual re-review. A future derivative may be
added beside the exact AVI for convenience, with its own provenance, but it
must not silently supersede the current authority.

### Silent ignore — rejected

Ignoring the AVIs would publish checksum ledgers and evidence contracts whose
required payloads cannot be obtained from the repository. It would make a
missing-evidence state look clean and is incompatible with fail-closed review.

### Ordinary Git blobs — rejected

Each file is under GitHub's 100 MiB hard per-object limit, but ordinary Git
would add the full 102.53 MiB cohort to every full clone and retain every future
binary revision in history. The absence of a server rejection is not a sound
storage policy.

## Exact pre-push handoff

Nothing below was run by this task. The separate staging/pre-push owner should
use the project-local binary explicitly and name the seven files—never stage a
broad dirty-worktree path:

```bash
LFS_BIN_DIR="$PWD/.tools/git-lfs/3.8.0/git-lfs-3.8.0"
PATH="$LFS_BIN_DIR:$PATH" git lfs version
git check-attr filter diff merge text -- \
  evidence/first-playable/d2-1439-chinook-standalone-hero-2026-09-04/d2-1439-chinook-sse-stock-walk.avi \
  evidence/first-playable/d2-1441-chinook-standalone-hero-2026-09-04/d2-1441-chinook-sse-stock-walk.avi \
  evidence/first-playable/d2-1444-croaker-standalone-hero-2026-09-04/d2-1444-croaker-wsw-stock-walk.avi \
  evidence/first-playable/isle-house-composite-repair-standalone-v1-2026-09-04/isle-house-composite-repair-public-corner-stock-walk.avi \
  evidence/first-playable/isle-house-composite-repair-variant-c-live-replacement-2026-09-04/isle-house-variant-c-actual-live-public-corner-stock-walk.avi \
  evidence/first-playable/isle-house-composite-repair-variant-c-standalone-v1-2026-09-04/isle-house-composite-repair-variant-c-public-corner-stock-walk.avi \
  evidence/first-playable/isle-house-low-live-integration-2026-09-04/isle-house-low-public-corner-stock-walk.avi
PATH="$LFS_BIN_DIR:$PATH" git add -- \
  .gitattributes \
  evidence/first-playable/d2-1439-chinook-standalone-hero-2026-09-04/d2-1439-chinook-sse-stock-walk.avi \
  evidence/first-playable/d2-1441-chinook-standalone-hero-2026-09-04/d2-1441-chinook-sse-stock-walk.avi \
  evidence/first-playable/d2-1444-croaker-standalone-hero-2026-09-04/d2-1444-croaker-wsw-stock-walk.avi \
  evidence/first-playable/isle-house-composite-repair-standalone-v1-2026-09-04/isle-house-composite-repair-public-corner-stock-walk.avi \
  evidence/first-playable/isle-house-composite-repair-variant-c-live-replacement-2026-09-04/isle-house-variant-c-actual-live-public-corner-stock-walk.avi \
  evidence/first-playable/isle-house-composite-repair-variant-c-standalone-v1-2026-09-04/isle-house-composite-repair-variant-c-public-corner-stock-walk.avi \
  evidence/first-playable/isle-house-low-live-integration-2026-09-04/isle-house-low-public-corner-stock-walk.avi
PATH="$LFS_BIN_DIR:$PATH" git lfs ls-files --long
PATH="$LFS_BIN_DIR:$PATH" git lfs status
git diff --cached --name-only
```

The auditor must inspect each staged blob as a three-line canonical pointer,
confirm all seven pointer OIDs/sizes against the inventory above, verify no
ordinary AVI blob is staged, and obtain owner quota/budget confidence before
allowing a push. Any push must also run with `LFS_BIN_DIR` prepended to PATH so
the repository-local pre-push hook can find `git-lfs`.

## Files and private state changed by this implementation

Tracked/untracked repository files authored by this task:

- `.gitattributes`
- `INSTALL_LOG.md` (this exact acquisition/verification entry)
- this policy receipt
- `discovery/RETRO_LOG.md` (append-only entry)

Private/ignored local state:

- `.tools/git-lfs/3.8.0/`
- `.git/config` repository-local `filter.lfs.*` settings
- `.git/hooks/pre-push`
- `.git/lfs/objects/` with seven local objects

The seven AVI payload files were not edited. No stage, commit, push, remote LFS
batch request, or upload occurred.

## Remaining user dependency

Only owner `pcomans` can reliably confirm account-wide LFS usage/budget and
change the repository's “Include Git LFS objects in archives” setting. Quota
confirmation is required before promising a successful first upload; archive
inclusion is required only if downloadable GitHub source archives must contain
the real videos. Neither blocks continued local work or a carefully reviewed
local commit.
