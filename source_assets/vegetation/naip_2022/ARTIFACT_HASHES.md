# NAIP 2022 candidate annotation artifact hashes

Final verified hashes from 2026-08-28 UTC. The source TIFF and lossless PNG hashes are also recorded with the exact request in `third_party_staging/naip_2022_treasure_island/PROVENANCE.md`.

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| staged source TIFF | 23,351,192 | `0d69c3cad642539581afffbfbb332c58ee1a7bd046b0f434a13545ec7bbe479d` |
| staged lossless PNG | 13,552,529 | `ffde33201323aa40d20e8b2e778354669eef584f4fbfe2563a18b76c7cd86b36` |
| `tree_annotations_candidate.geojson` | 63,633 | `03f858180c6ff0d25b974b1fbb0fc82a91139afe91e83b2e3291ef2dd49ade11` |
| `tree_annotations_rejection_audit.geojson` | 30,925 | `d284eb2eb5cb6ae59b56d3242786644c0e0b63c6b3fd36013daef3bcb04183d3` |
| `treasure_island_footprint.geojson` | 12,596 | `743dee7cbb306ef25b520eec8b25394f94d339fde61163e142d758842e4985f0` |
| `tree_annotations_review.svg` | 13,469 | `c2268396e2015797f182d622a0ba2021e1b78e11bf37fbf35947f1de41f238e1` |
| `tree_annotations_review.png` | 347,824 | `b0d5002aad7730ca78a9aeb1c699f4c2c6885505fae9080f8924e1c2a3dd75d7` |
| `naip_vs_generated_vegetation_review.svg` | 27,891 | `20947c954e21056daecd71c5ef67f23e30a8c23444b9041e1ab156e383b3c041` |
| `naip_vs_generated_vegetation_review.png` | 289,249 | `f70afb04fb47a8e1ebe228ef4c5577a3a2ad87c1403eb77f8ea1e5c42c950656` |
| `validation_report.json` | 580 | `6a78234bad24ee94fe680d89e9426db7f56a6f29913bc6da95ac20cb02c25ba7` |

Reproduce canonical data and SVGs with:

```sh
node tools/build_naip_tree_annotations.mjs
node tools/validate_naip_tree_annotations.mjs
node tools/render_naip_generated_vegetation_comparison.mjs
```

The PNGs are review derivatives rendered from the SVGs with existing trusted ImageMagick and `/System/Library/Fonts/Helvetica.ttc`; no new package was installed.
