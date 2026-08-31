# Whole-island visual coverage evidence

This evidence is deterministically rendered from the actual generated chunk and context triangle records for content `5899ebe131bbf05525fedebdac703a321a7aaf95523a57960cb937085068cfaa`. It does not read Godot scenes, invent geometry, or mutate generated data.

- `whole-island-derived.svg`: clean north-up source/derived comparison with every playable visible layer and a separate context-orientation inset.
- `whole-island-derived.png`: rasterization of the clean SVG for visual inspection.
- `whole-island-diagnostic.svg`: the same view with the 256 m chunk grid.
- `coverage-comparison-summary.json`: independent source-ledger, artifact-hash, physical-reference, category, context-isolation, and extent checks.
- `determinism-report.json`: hashes from two clean evidence renders compared byte-for-byte.

The source polygon and derived playable edge coincide at the established 0.001 m coordinate precision. Building roofs represent footprint coverage in plan view; vertical wall triangles are intentionally not filled because they project to zero area from above.

Rebuild and validate with:

```sh
node tools/render_world_coverage_evidence.mjs
node tools/render_world_coverage_evidence.mjs --validate-only evidence/first-playable/coverage
```
