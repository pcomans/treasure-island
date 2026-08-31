# w34313520 live MAT-PALE field + one BAY evidence

Status: **independently accepted live KEEP_WITH_DOCUMENTED_LIMITATION after the accepted evidence correction; runtime, art, transforms, and captures remain unchanged**.

## Evidence-only correction

Independent review `W34313520_LIVE_FIELD_AND_BAY_ART_REVIEW.md` (`f0ad7c169c723a2dfb860aa12065af6da9f9dd91f1d8d9142dec024bdad3c865`) gave both live scopes `KEEP_WITH_DOCUMENTED_LIMITATION` and prescribed one evidence-only correction. The redundant top-level `placement` snapshot and its broken `_module_metadata()` serializer were removed. The corrected manifest retains the authoritative `live_module_metadata`, `resolved_placement`, and `truth_boundary`, which consistently record the `11.144477 m` mechanical safe-domain half-span and false surveyed-dimension/coordinate/count/cadence flags.

No art was recaptured. All eleven PNG hashes remain byte-identical to the reviewed set. Runtime adapter, field helper, world builder, registry, calibration helper, materials, generated data, exact transforms, field scope, and topology remain byte-identical. Independent correction re-review `W34313520_LIVE_EVIDENCE_CORRECTION_ART_REVIEW.md` (`958130a3cc09cf129186562a9e54f4157bbfad3f99846a695238c3ee4b6b1a46`) accepted the correction and authorized lifecycle promotion of exactly the field and single BAY described below, both `KEEP_WITH_DOCUMENTED_LIMITATION`.

This package is a native Godot 4.7.2 Forward+/Metal capture of the actual loaded world. It shows only the independently detached-calibration-reviewed scope:

- `W34313520-MAT-PALE`, a homogeneous material field, live only on SSE runs `6..10` (`68.156 m`, `751.441 m²`) with the accepted `0.95 m × 0.29 m` wall-tangent world-metre projection and `0.0 m` maximum join-phase delta.
- Exactly one complete `W34313520-BAY` module-atlas motif, `CAL-SSE-BAY-01`, at run `7` midpoint `15.894477 m`. Its mechanical safe center domain is `4.750000–27.038953 m` (half-span `11.144477 m`); this is containment clearance, not evidence-derived uncertainty, runtime jitter, or a surveyed coordinate.

The BAY owns 15 render meshes / 15 surfaces / 180 triangles and zero field/backing/collision/navigation/spray geometry. The field adds one record-owned material surface and no mesh or triangles. Loaded topology therefore changes from `729 / 871 / 878 / 50,093 / 466` to `729 / 886 / 894 / 50,273 / 466` (records / meshes / surfaces / triangles / collider pairs). Raw generated source/data bytes remain unchanged.

## Views

| Capture | Review purpose |
|---|---|
| `01-field-join-r6-r7.png` | exact run `6→7` field join |
| `02-field-join-r7-r8.png` | exact run `7→8` field join |
| `03-field-join-r8-r9.png` | exact run `8→9` field join |
| `04-field-join-r9-r10.png` | exact run `9→10` field join |
| `05-macro-field-runs6-10.png` | more-than-50-m macro span and ordinary BAY scale |
| `06-bay-close.png` | complete BAY close receiver view |
| `07-bay-oblique.png` | shallow live separation and frame/glass completeness |
| `08-all-runs-ordinary.png` | ordinary gameplay-readable all-run SSE view |
| `09-building-sse-context.png` | broader building/SSE context |
| `10-changed-light-field-and-bay.png` | changed-light response of exact field and BAY |
| `11-whole-island.png` | actual-loaded-world whole-island context |

The four internal joins are intentionally visually quiet: all five collinear runs share one world-position projection, so a discontinuity marker would contradict the accepted field contract. The manifest names the exact represented run pair and camera pose for each join inspection.

## Truth boundary

This package does not claim surveyed scale, dimensions, coordinates, count, or cadence; a completed SSE elevation; any other side/run; any wing/recess/lower family/endpoints; a second BAY; or whole-building resemblance. It preserves the exact calibration registry/helper and all accepted standalone asset bytes. The accepted lifecycle scope is only the one field and one complete motif stated above; complete-elevation and whole-building verdicts remain separate and blocked.

Reproduce with:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/w34313520_live_integration_capture.gd
```

Machine-readable provenance is in `capture-manifest.json`; the exact before/after accounting is in `runtime-topology-delta.json`; current hashes are in `asset-inventory.sha256`.
