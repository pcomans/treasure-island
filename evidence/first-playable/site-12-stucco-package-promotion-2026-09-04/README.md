# Site-12 stucco package-safe promotion receipt

Status: **source and fresh canonical mounted contracts pass; pending independent
packaging audit**.

This is a technical promotion receipt, not a new visual review. The reviewed
warm-ivory bitmap was copied byte for byte from the export-excluded pilot path
to `res://game/resources/textures/world/site_12_housing/`. Its raw SHA-256 is
`af1c7a8f90ab5e60b9ab40a3bcf087aa26b00892edd48a2b4f1c84533f8be51c`
at `2,811,712` bytes on both paths. Source tests also loaded both resources and
proved identical dimensions, format, and decoded pixel/mipmap buffers; the
decoded buffer SHA-256 is
`1c6d6019bcfbc9700ab43b80e07f481e51323bb6ac7a12ed03e253ed95545f1a`.
No image was regenerated, resampled, recompressed, or edited.

Both Site-12 materials now reference the promoted path while retaining their
reviewed scalar tints, roughness `0.88`, metallic `0`, no companion normal or
roughness maps, and meter UV scale `0.333333`. Geometry, collision, navigation,
spray ownership, and live routing did not change. Rebuilt signatures remain:

- 1441 Chinook: `b91b373e3bb8238a6f73f05734ef48b3429ae5654eddce89b1981ee41ee89195`
- 1444 Croaker: `8df0202796d56c019b6b3ddb72916808b72316d2d0edee0ba7425b77efa2b127`

The untouched canonical `macOS Private` preset produced a fresh PCK at
`build/site-12-stucco-package-promotion-review/Treasure Island First
Playable.pck`, SHA-256
`cf5dd99349c88cb78fd9d0df39ecedf7c84536b3652ee56e0e1b689a62e75489`,
`65,271,192` bytes. Direct mounting from a new `/tmp` working directory passed
the promotion, 1441, and 1444 package contracts. The promoted imported texture
loads; the pilot-only texture/material do not; `project.binary` is present;
`project.godot`, discovery, and evidence directories are absent. The direct
1441/1444 runtime closure also contains no discovery/evidence/URL/private-path
tokens.

The future-facing 1441 contract now carries the authoritative confusion IDs
`w95934144,w95934143,w95934131,w95934129` and accurately assigns its broad
eaves to the dark roof surrogate. Historical capture manifests were not
rewritten; their old generator/input hashes remain verified as historical
facts, and every prior still/movie hash continues to pass its evidence
contract.

Technical conclusion: the canonical texture-package blocker is closed for the
standalone 1441 and 1444 assets. Both are technically eligible for a later
fail-closed live study, but neither is live-attached or granted new recognition
credit here. Independent packaging audit is the next gate.

See `promotion-receipt.json` for the exact source, material, PCK, test,
immutability, and eligibility records.
