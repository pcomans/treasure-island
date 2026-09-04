# Site-12 shared housing textures

This directory is the package-safe runtime home for reviewed shared Site-12
housing bitmaps. It is intentionally outside the export-excluded
`genai_pilot_v1` namespace.

## `warm_ivory_mineral_albedo_v2.png`

- Raw PNG SHA-256: `af1c7a8f90ab5e60b9ab40a3bcf087aa26b00892edd48a2b4f1c84533f8be51c`
- Raw byte size: `2,811,712`
- Dimensions/source format: `1254 x 1254`, RGB PNG, no alpha
- Promoted from:
  `res://game/resources/textures/world/genai_pilot_v1/warm_ivory_mineral_albedo_v2.png`
- Promotion method: exact byte-for-byte copy. No regeneration, resampling,
  recompression, filtering, color edit, or pixel edit occurred.
- Provenance authority:
  `res://discovery/facades/GENAI_TEXTURE_PILOT_V1.md` records the complete
  text-only generation/edit prompts, tool boundary, original saved output,
  hashes, and nonclaims. No target photograph or third-party reference pixels
  were used as generator input or embedded in the bitmap.
- Review boundary: the source pilot and both Site-12 standalone hero reviews
  accepted this albedo at a reversible 3 m repeat with a faint recurrence
  limitation. It is a shared believable mineral field, not a surveyed material,
  target-specific facade, exact color sample, or pixel-perfect seamless claim.
- Runtime users:
  `site_12_warm_ivory_stucco.tres` (1441 scalar warm-ivory tint) and
  `site_12_ochre_tan_stucco.tres` (1444 scalar ochre tint). Both retain scalar
  roughness `0.88`, metallic `0.0`, no generated normal/roughness maps, and
  meter-authored UV scale `1 / 3`.

The historical pilot copy remains in place so immutable evidence manifests can
continue to verify the exact bytes they originally pinned. Canonical exports
must include this promoted copy and must continue excluding the pilot-only
directory.
