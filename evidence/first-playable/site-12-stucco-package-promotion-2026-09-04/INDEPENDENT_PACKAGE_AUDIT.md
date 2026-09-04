# Independent Site-12 stucco package audit

Date: 2026-09-04  
Reviewer: `/root/d5_reference_research`  
Implementation independence: this reviewer did not implement the promotion.

## Decision

**PASS.** The canonical texture-package blocker identified by the independent
1444 review is cleared for the standalone 1441 Chinook and 1444 Croaker
prototypes.

This is a narrowly scoped technical/package decision. It permits each candidate
to proceed to a separately authorized, fail-closed, exact-current live study and
later independent live review. It does **not** attach either prototype, accept
either prototype in the live world, revise the catalog or registry, or award
recognition credit. Numerator effect: **+0**.

## Material reviewed

The audit read and cross-checked:

- both prior independent bar-raiser reviews;
- this promotion's `README.md`, `promotion-receipt.json`, and
  `CHECKSUMS.sha256`;
- the historical pilot PNG/import/material dependencies and the promoted
  PNG/import/material dependencies;
- the current 1441 and 1444 configs, factories, scenes, focused structural,
  source-package, and immutable-evidence contracts;
- the canonical `macOS Private` export preset;
- the retained promotion PCK and a second independently generated PCK from the
  current canonical preset; and
- the prior 1441/1444 capture manifests, motion manifests, movies, and the 1444
  motion review sheet.

No production asset, runtime config, visual evidence file, catalog, registry,
world builder, or export preset was modified by this audit.

## Bitmap and import equivalence

The source pilot and promoted PNGs compare equal byte for byte (`cmp` exit 0):

| Check | Historical pilot | Promoted package-safe asset | Result |
| --- | --- | --- | --- |
| Raw SHA-256 | `af1c7a8f90ab5e60b9ab40a3bcf087aa26b00892edd48a2b4f1c84533f8be51c` | same | PASS |
| Raw byte count | `2,811,712` | `2,811,712` | PASS |
| Dimensions | `1254 x 1254` | `1254 x 1254` | PASS |
| Decoded size and format | receipt/test authority | equal | PASS |
| Complete decoded pixel+mipmap buffer SHA-256 | `1c6d6019bcfbc9700ab43b80e07f481e51323bb6ac7a12ed03e253ed95545f1a` | same | PASS |

Both `.import` contracts retain lossless compression, generated mipmaps,
normal-map mode off, and roughness-map mode off. Their expected path/UID/cache
identifiers differ because they are distinct resource paths; their intentional
decode behavior does not.

The source promotion contract loaded both resources and compared `get_size()`,
format, and complete `get_data()` buffers, including mip levels. The mounted
promotion contract loaded the promoted imported resource directly from each
PCK and reproduced the decoded buffer hash. No regeneration, resampling,
recompression, or pixel edit was found.

## Consumer behavior is unchanged

The two current materials differ from their frozen visual-evidence versions
only by replacing the pilot texture path with the package-safe texture path.
Substituting the old path back into each current material reproduces the exact
historical hash:

| Entity | Frozen pre-promotion material | Current promoted material | Preserved behavior |
| --- | --- | --- | --- |
| 1441 Chinook | `b30d0d750e70ad4b8c28ddddce65cd88ef4ae04412b38dfef580870a2fd0bb5f` | `81fd15832670516b2cc752e89310acda201f30705b01297639703f76f2111a64` | tint `(0.96, 0.94, 0.87, 1)`, roughness `0.88`, metallic `0`, UV XY `0.333333`, no normal/roughness texture |
| 1444 Croaker | `5cb6000c2ab04a63db92986a02dce4877dc886c6619fa9bef8ed2f7958ead9c3` | `9486ccf52e1f2aff9fc940f60644733d5cf9bf1cb03cebb5332bcc1d7c0aaaf6` | tint `(0.78, 0.61, 0.42, 1)`, roughness `0.88`, metallic `0`, UV XY `0.333333`, no normal/roughness texture |

Fresh focused structural runs and both direct-mounted package runs retain the
reviewed deterministic signatures and topology:

| Entity | Signature | Visual/collision facts | Result |
| --- | --- | --- | --- |
| 1441 Chinook | `b91b373e3bb8238a6f73f05734ef48b3429ae5654eddce89b1981ee41ee89195` | 9 batches, 1,578 visual triangles, 42 collision triangles, 36 rail pickets | PASS |
| 1444 Croaker | `8df0202796d56c019b6b3ddb72916808b72316d2d0edee0ba7425b77efa2b127` | 11 batches, 798 visual triangles, 54 collision triangles, 4 rail pickets | PASS |

No geometry, collision, navigation, spray ownership, live attachment, or
prototype scheduling change is attributable to the texture promotion.

## 1441 semantic corrections

The 1441 independent review found two future-facing metadata defects. The
current config, SHA-256
`ebb6be74a630ad405030938dc7d27bc6fed46b2d6892a847ee653d374df57f75`,
corrects both without rewriting the historical capture record:

1. Its authoritative confusion IDs are exactly `w95934144`, `w95934143`,
   `w95934131`, and `w95934129`.
2. Its stucco application is limited to the exact mapped wall runs, pale
   opening frames, and balcony slabs. `MappedSSEBroadEaves` uses the dark roof
   surrogate.

The old review PCK was mounted read-only to inspect its packaged configs. It
retains the historical 1441 config hash
`e07fba5d50f9bce4d879203ad63c0db62aa6fa5efc1f1f430ef91beb42e444e0`
and the historical 1444 config hash
`fe5cb77ceccadf02c4dac28d82d8b35dc00a4a5a3bac69629558ccaa61cb5c29`.
The observed future-facing config changes are provenance/source wording for
both entities plus the two explicit 1441 corrections above; geometry and
schedule data remain unchanged.

## Canonical export and package boundary

The current `export_presets.cfg` hash is exactly the receipt-pinned
`6860fbd8409e5f74b7389da23707db9524fb843a9f3f41429556a3d5d2329294`.
The unmodified `macOS Private` preset still excludes both shallow and recursive
pilot texture/material directories and does not exclude the promoted
`site_12_housing` texture directory. No isolated preset workaround was used.

Two canonical artifacts were mounted directly from outside the checkout:

| Artifact | SHA-256 | Bytes | Mounted promotion / 1441 / 1444 |
| --- | --- | ---: | --- |
| Retained receipt PCK | `cf5dd99349c88cb78fd9d0df39ecedf7c84536b3652ee56e0e1b689a62e75489` | 65,271,192 | PASS / PASS / PASS |
| Independent fresh-current PCK | `4a0c3ba72612638583ca60dee83ef61092b404d1c2626c2a59568702dae06155` | 65,319,320 | PASS / PASS / PASS |

The fresh-current PCK is not globally byte-identical to the retained receipt
PCK. The checkout is shared and received unrelated exact-current Isle House
registry/config additions after the receipt export; a bounded strings diff
found those unrelated fields in the fresh artifact. This is not treated as
Site-12 byte drift: both artifacts load the same promoted Site-12 texture and
the exact Site-12 material/config/signature contracts pass in both. The retained
receipt PCK remains present with its exact receipt hash and size.

Each direct mount established:

- `project.binary` is present and source `project.godot` is absent;
- the promoted imported texture loads and has the expected decoded buffer;
- the pilot-only texture and pilot-only material do not load;
- discovery and evidence directories are absent;
- the 1441 and 1444 direct runtime closures load with the expected current
  config/material/topology/signature facts; and
- those direct Site-12 closures contain none of `res://discovery/`,
  `res://evidence/`, `https://`, `http://`, `file://`, `/volumes/`, or
  `/users/`.

The package-leakage conclusion is intentionally closure-scoped. A raw strings
scan of the complete all-resources PCK finds unrelated URLs and provenance
strings from other runtime configs/tests. That does not make them Site-12
dependencies, and this audit does not certify the whole game PCK as globally
token-free. The source-only
`game/resources/textures/world/site_12_housing/README.md` also records the
discovery provenance authority; it is not in either consumer's runtime closure
and is not exported as a loadable dependency.

## Prior visual evidence immutability

Fresh hashes match the frozen evidence authorities exactly:

| Evidence | SHA-256 |
| --- | --- |
| 1441 capture manifest | `8b4bbea9eb24a084058420100a7c5a1dd4305fb15668118aaf0d6bed56ce8b94` |
| 1441 motion manifest | `f6c9053db6603ad0095312a37566a5ade14627bea077f0585c055503942f5142` |
| 1441 movie | `1f7b42f4b83c0225146044cfc9794f71575d19e06147e15ebc7f0aa46b3f7d03` |
| 1444 capture manifest | `e802bccc45ec25bd5ecccc2aa79a06a37220ae61f6e44a67c14f9e916711ac0b` |
| 1444 motion manifest | `49e861d1d154858e7f0cfbbccdc732e5948be4d32f346978affb6f423a55d61d` |
| 1444 movie | `3afe7d57f60d8c2b7330f49fa3bc414d915404a23ea774778407fa58710770b4` |
| 1444 motion review sheet | `63aada9bd3ec5f489f4930d46b80bfc41955efc4db449c8c7e7f17618661eefb` |

Both immutable-evidence contracts pass while deliberately distinguishing the
old frozen config/material hashes from the separately audited current
future-facing files. No prior still, movie, manifest, or review sheet was
rewritten or recaptured.

## Fresh test ledger

Read-only source-checkout runs under Godot 4.7.2:

- `headless_site_12_stucco_package_promotion_contract.gd`: PASS
- `headless_d2_1441_chinook_standalone_hero_contract.gd`: PASS
- `headless_d2_1444_croaker_standalone_hero_contract.gd`: PASS
- `headless_d2_1441_chinook_standalone_hero_package_contract.gd`: PASS
- `headless_d2_1444_croaker_standalone_hero_package_contract.gd`: PASS
- `headless_d2_1441_chinook_standalone_hero_evidence_contract.gd`: PASS
- `headless_d2_1444_croaker_standalone_hero_evidence_contract.gd`: PASS

Outside-checkout direct-mounted runs against both canonical PCKs:

- Site-12 stucco promotion package contract: PASS / PASS
- 1441 package contract: PASS / PASS
- 1444 package contract: PASS / PASS

The promotion directory's checksum manifest also verifies its listed
`README.md` and `promotion-receipt.json` from the directory-relative working
directory.

## Cleared gate and remaining gates

The package-safe promotion is adequate to clear the prior canonical packaging
blocker. The next allowable work is one separately authorized fail-closed live
study per entity, followed by exact-current independent visual/live review.
That later work must still prove exact wall+roof replacement, no fallback
stacking, navigation preservation, explicit spray restoration, material and
texture closure, and recognizability against the entity's honest confusion
set. This audit supplies no visual re-grade and no shortcut around those gates.

Files changed by this independent reviewer:

- `evidence/first-playable/site-12-stucco-package-promotion-2026-09-04/INDEPENDENT_PACKAGE_AUDIT.md`
- `discovery/RETRO_LOG.md`
