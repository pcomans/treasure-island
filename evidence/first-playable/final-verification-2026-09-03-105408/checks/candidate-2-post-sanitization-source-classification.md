# Candidate 2 post-export source classification

Candidate `111725` was exported from the 496-file snapshot retained in
`candidate-2-source-inventory-pre.tsv`. That inventory has SHA-256
`808dbdba8b90cc7b6c2b74cae52f3a5dd9bf0560e2ec827d9af6dd3f726c3872`.

After the test registry and canonical documentation were reconciled, the same
inventory algorithm produced
`candidate-2-source-inventory-post-sanitization.tsv`: 496 rows, SHA-256
`6fa2989e4a7a9c9fc93f6cf519e67731088ff875c545592da6d68c14e576d98c`.
The candidate is therefore **not** claimed to match the subsequently edited
full 496-file inventory.

The only changed row is:

| Path | Export-snapshot SHA-256 / bytes | Reconciled SHA-256 / bytes | Classification |
|---|---|---|---|
| `game/tests/README.md` | `1cdbde5b6b3ad9c163f5c617431ea354c34f592c9da2a83051a1a77891695ba8` / `16,362` | `9ebec1bc5b725b698897cb83dfb5509e48bb51dd5a122042e53df8ea7d1ca8e2` / `18,503` | documentation only, made after export |

Filtering that one path from both inventories leaves 495 byte-identical rows.
The filtered export-snapshot and current inventories both hash to
`dd70d46ce100951ac9ce7713bd771582dfe6787015b631cc12721b13f01fd0c0`.
This is the scoped proof that no other product, project configuration, test
script, generated-world byte, or source asset in the recorded export-input
inventory changed after the export snapshot. Canonical documentation outside
those five source roots was never part of the 496-file package binding.

Inventory algorithm:

```sh
git ls-files -co --exclude-standard -- \
  export_presets.cfg project.godot game generated source_assets |
  LC_ALL=C sort -u
# For each regular file:
# path<TAB>sha256<TAB>bytes<LF>
```

The comparison required 496 rows in each inventory, selected
`game/tests/README.md` as the only differing path, and used a byte comparison
of the remaining 495 normalized rows. It exited `0`.
