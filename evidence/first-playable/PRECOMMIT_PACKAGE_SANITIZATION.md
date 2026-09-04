# Pre-commit package sanitization

Date: 2026-09-04

Status: technical source, export, mounted-package, and packaged-startup gates
pass; pending independent package-boundary audit. This receipt makes no visual
or recognizability judgment.

## Scope and provenance split

This migration removes workstation paths and source-only locators from the two
active Building 1 configs and five standalone-review configs in the audited
cohort. External reference URLs and repository discovery/evidence locators now
live only in the source receipt
`discovery/facades/PRECOMMIT_PACKAGE_SANITIZATION_SOURCE_PROVENANCE.json`.
That receipt is excluded from the canonical package and is pinned at SHA-256
`269558b49e21c6c4f46c7133c3aa6012ca35bc122739c677b3ba5ab318a19333`.
It records the seven pre-migration config hashes, opaque output IDs, public
source URLs, and repository-relative provenance without publishing a
workstation path.

The migrated package-facing config identities are:

| Config | Role | Current SHA-256 | Historical SHA-256 in source receipt |
| --- | --- | --- | --- |
| Building 1 hero | active runtime | `f10bc92a6e74cbae41347e742e6c68c50faccddbd52ab3ecce210ac8243bc6e9` | `6c99f43550631a1e6bca1f52764ad23c6a5b8b891403f30c78ff9b9545192690` |
| Building 1 public front | active runtime | `fd434eb472f61d93408732841e5993881b23238af8c0518b59181ac0ea535e32` | `e11710374f837e15b45adf3b6df0e762a6793b363e6c3109870e1bf2f7a0ee0e` |
| D1 Building 201 | standalone only | `30bc1f62e5fa44c60bdcfb1bfd4f6f679d391618fa213373e571080face6ec6c` | `3d53efbb0577c9b5e52a2ada4d79a710b95e41faead0bdcdd41cd4f2d862a0fe` |
| D1 Building 225 | standalone only | `dc3591df4a68af19b5fa53f402ed15d5e3f83946c4a113f024d5b7d41f2f82b8` | `63e4f80cc7716146dc1fef46c7678e4da856755377c84ff33f972c0cc0c1f639` |
| D1 pair | standalone only | `fdf00bba0562036f499a5a64e47e5e1b695d49d6cb4ada7acafd450b3dcfefb9` | `c73f8c8da4d30a4e4ebe3e94cde10d63f98377bf5b636a1e12cee92c9bcaafe4` |
| D1 Building 225 cladding repair | standalone only | `7c1c2d508f78236590c6d413604be60b3a5c48865878e69d294177d05c48d166` | `89d34d33b48c93c0a6c90d46ff8120cd36c5f897ebe1fc9ea2ee2cd97a3db22c` |
| Dormitory 369 | standalone only | `b02b098bfeca628cd6a71e7393897d53f5f46dfd0efddd915e316c2dd5204c2e` | `a6086d13a986bdd4a6c281b75ec7fb58524257ae4b8ea6b849840a324cc59dc2` |

All seven current JSON files parse and contain zero URL, discovery, evidence,
source-assets, file-URL, `/Users/`, `/Volumes/`, or
`path_outside_project` tokens. Their standalone/live status and visual,
geometry, collision, navigation, and spray semantics are unchanged.

The specifically requested publishable-document migrations are also clean:

- D1 repair `capture-manifest.json`:
  `22cbe9edec6e33ccbfcc2c71d719c2c1bc646358fb46242be802affe371b2ec5`
- D1 repair `verification-results.txt`:
  `52faf8e6a03d8c96bdfb7b1e5a8120257187cc68dcd2cfa331ae455eae9fd6ad`
- `GENAI_TEXTURE_PILOT_V1.md`:
  `a4dbca10ca3fb8cc419784fac295de0b3f114ad8f9d2a06a4ceb2e8318bfad36`

The D1 evidence manifests retain their capture-time config hashes. Current
sanitized hashes are tested separately through the source receipt; no image,
movie, independent review, or historical capture meaning was rewritten. The
same capture-time/current split is enforced for the Building 1 grounded-tower
evidence contract.

## Deterministic registry regeneration

Two consecutive compiler `--write` runs emitted byte-identical artifacts, and
a following `--check` passed:

- catalog: `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`
- runtime adapter contracts:
  `f1ffc7061a8d02bd7f78a1ec4457b36c4adc5618755f730638bfedfcc9d4437d`
- runtime registry:
  `dce268c1547e4e4620faff9d59110ee1214a9a2121c1f83b3eb1c865339360ab`
- validation report:
  `7d1562694c71e56976681f827421801f2c35e223230fe0543919dcaa1fcf26f7`
- runtime loader:
  `7a245be61167cf774f5f693944fe3adc6640b5dd7f7cb98fcb6425a7c82f7832`

The stable result remains 213 physical units, 214 direct receivers, 215 source
records, 4,971 visible wall runs, and exactly 5/213 independently accepted
reference-recognizable physical entities. Adapter accounting is 14 receiver
plans: 4 active plus 10 legacy; 8 plans are package-safe and 6 are hard
disabled, with 13 unique pathless projection inputs across 13 occurrences.

## Fresh canonical export

The unmodified `macOS Private` preset exported a new app bundle in a unique
outside-checkout staging directory at exit `0`. The staged artifact is
disposable and is not part of this evidence or commit.

- PCK bytes: `65,263,184`
- PCK SHA-256:
  `265635b899ae6674e44f673661af09a24ce61c977830cc137c6ea0efdee137c5`
- generated-world manifest SHA-256:
  `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`
- generated-world content SHA-256:
  `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`

Two outside-checkout direct mounts of this exact PCK passed the canonical
content audit: 850 virtual files, 47 generated files, 38 chunks, 739/735/4
source/playable/context rows, and zero banned virtual paths, configured private
paths, or configured private raw-byte hits. `res://discovery/`,
`res://evidence/`, and `res://source_assets/` are absent. The pilot-only GenAI
texture and material are absent, while the separately promoted Site-12 texture
loads byte/pixel-identically. The seven-config mounted contract reports zero
URLs, local/private paths, discovery/evidence/source locators, and reference
source pixels in its exact package-facing scope. A separate raw-container scan
found zero occurrences of the audited workstation identity/path fragments.

Two runs of the exported app binary's bounded `--mac-export-smoke` also passed:
38/38 chunks, 735 records, 940 meshes, 954 surfaces, 64,118 triangles, and 466
bodies/shapes, followed by movement and jetpack gates.

## Test record

The following gates passed twice against the final source state (all exit
`0`): compiler syntax/check, recognition Node contract, loader Node contract,
Godot recognition registry, Godot runtime loader, Building 1 hero, Building 1
public-front structure and evidence, grounded-tower historical/current
migration, D1 pair structure and evidence, D1 cladding-repair structure and
evidence, Dormitory 369 structure and evidence, Site-12 texture promotion, and
the pre-commit sanitization contract. D1 and Dormitory deterministic geometry
signatures remain unchanged.

The mounted sanitization, mounted D1 repair, mounted Site-12 promotion, and
canonical PCK content audits each passed twice. Source-mode registry tests
retain raw-source hash checks and are intentionally not reused as mounted
tests, because exported GDScript and scenes are compiler-remapped; the mounted
contracts validate loadable packaged resources and semantic identities instead.

## Truthful boundary and remaining review item

This receipt proves the audited config/runtime closure, the absence of the
authoring roots, and the exact mounted resource graph. It does not claim that
every byte in the PCK lacks words such as `discovery` or `https`: the canonical
export still contains compiled `game/tests` scripts, including negative-test
literals, because existing production facade modules preload helpers under
`game/tests/support`. Excluding the whole test tree made those production
scripts fail to compile and was reverted. Moving those helpers into a runtime
namespace and then excluding non-runtime tests is a separate release cleanup;
it is not required to make the seven audited configs or active runtime closure
package-safe and was not attempted here.

Independent review should verify the source-receipt exclusion, seven mounted
config hashes/semantics, PCK identity, and this explicit compiled-test boundary
before the reviewed milestone is committed.
