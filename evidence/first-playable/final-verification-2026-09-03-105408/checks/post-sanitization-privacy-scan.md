# Post-sanitization privacy scan

The final scan covers every regular text file reported by
`git ls-files -m -o --exclude-standard` after canonical reconciliation,
including this record and its deterministic path list. Binary files are
classified separately. The exact text-file list is
`post-sanitization-publishable-text-files.txt`.

- changed/new publishable text files: `123`
- changed/new binary files: `24`
- text path-list SHA-256:
  `f27f6bb998e62836ad53d74ff17ce86af844b8d3be1beeb5ec7d0b299e67a696`
- configured private/account hits across those text files: `0`
- configured private/account hits in the exact candidate PCK raw bytes: `0`

Configured text and raw-container needles cover account-bearing
`/Volumes/<volume>/Users/<account>`, `/Users/<account>`,
`file:///Users/<account>`, Windows `C:\Users\<account>` forms, and the
known migration account token. `$ROOT`, repository-relative paths,
`/private/tmp`, and non-unique renderer hardware such as
`Apple M2 (Apple8)` are intentionally allowed.

The candidate scan target is the PCK at
`build/final-verification-staging-2026-09-03-111725/Treasure Island First Playable.app/Contents/Resources/Treasure Island First Playable.pck`,
SHA-256
`4d9e1d47f8777dbe2d7ca57f9a93d840a708dfcc35c18e99e54a77c36eeb266e`.
The PCK result is a literal raw-container scan only. The separate mounted
auditor hashes and parses every manifest-indexed generated file but does not
claim decompressed privacy scanning of every arbitrary packaged resource.

The exact unsanitized originals remain only under ignored
`build/private-evidence-preservation-2026-09-03-115715/`, whose README warns
that they contain account-bearing paths and must not be committed.
