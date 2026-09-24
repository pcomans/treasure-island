# Housing family source experiment

This branch provides one shared assembly, `housing_site_family.gd`, and 23 data
instances in `game/resources/housing_family/w*.json`. The assembly uses the
existing 1232 recessed-window and entry primitives. Source edges, opening
schedules, palette, canopy segments and roof variants belong to each instance.
Dimensions and hidden roof construction are bounded production inference.

The capture driver loads the ordinary production world first. **Existing (A)**
is the production visual state from baseline
`9c7f2440d3db6a7f2d0a5d474c612c0362a01c16`. **Shared family (B)** hides only the
selected wall/roof owner's mesh descendants and adds the shared render-only
assembly. The same settled stock-player camera, sun and environment are used.
It restores the original meshes and removes the added assembly before the next
building. Production loaders, authority, receivers, collision shapes and player
controls remain unchanged. This is a visual comparison, not playable integration,
physics verification, independent acceptance or recognition credit.

1232 and 1241 explicitly retain their richer production roof and tagged ground
components; those components are not claimed as newly generated family geometry.
Other instances replace target-owned ground visuals using existing per-site
triangle data. 1397 has no authored canopy because its ownership is unresolved.
Unobserved elevations retain plain exterior massing; no hidden opening schedule is
invented. Private source photos are excluded from runtime data and the gallery.

From the repository root, check identity and complete opening containment:

```sh
python3 game/tests/housing_family_experiment/check_instances.py
```

For this installation, the owned native runner captures all 23 pairs and retains
logs, original PNGs, the child PID, terminal result and engine-slot release:

```sh
python3 game/tests/housing_family_experiment/run_capture.py fresh-run-name game/tests/housing_family_experiment/all23.json
```

Each run name must be new. The runner defaults to the existing sibling MAIN
Godot 4.7.2 binary. The equivalent portable native command is below; replace the
binary and choose a fresh absolute output directory. Import a new checkout once
with that binary's `--headless --editor --path . --quit` before capturing.

```sh
/path/to/Godot --path . --rendering-method forward_plus --rendering-driver metal --display-driver macos --audio-driver Dummy --resolution 1440x900 --script game/tests/housing_family_experiment/capture.gd -- --manifest=res://game/tests/housing_family_experiment/all23.json --output=/absolute/fresh/output
```

The source capture uses Metal/macOS, matching the retained original source driver.
Its default save log prints grounding metadata defaults; the `VISUAL_SETTLED`
rows are the actual settle observations. Neither supplies changed collision fit.
The original failure and earlier visual HOLD attempts remain locally in
`evidence/housing-family-experiment` outside this committed checkpoint; do not replace their outputs or relabel
those attempts as successful. The HTML gallery links full-resolution originals.

The main gallery selects the latest reviewed matching A/B pair: 1204/1229 from `quality-round1-003`, 1205/1237 from `quality-round2-004`, and the other 19 from `all23-006`. These unchanged-instance captures are reused historical evidence, not current-source proof. The explicit override mapping in `build_gallery.py` preserves original images and links the earlier pairs.

Historical run `all23-006` contains 46 originals for 23 provisional comparisons. 1237, 1204, 1205, 1229 and 1397 remain incomplete regional studies, with
blank lower fields and unverified elevations. The farther three-quarter 1229
view does not establish whole-building roof fidelity. Current reference coverage is maintained in the [canonical inventory](../../../discovery/HOUSING_FAMILY_INSTANCES.md); this paragraph describes the frozen 006 checkpoint. Earlier run 005 stays unchanged locally. Independent visual review calls the final result a useful provisional A/B experiment, with shared trim/screen regressions substantially repaired and 1221 roof variation restored. 1229 roof/apron fidelity remains unresolved; 1227/1234 screens are denser than A, and 1226 is partly occluded. No whole-building acceptance follows.

## Focused quality round 1

`quality_round1.json` selects 1204 and 1229 plus the 1237 hip-roof and 1220
broad-band controls. `quality_round1_targets.json` selects only the two edited
targets. Pass either manifest to the same runner with a fresh run name.
The three-way comparison is `evidence/housing-family-experiment/quality-round1.html`:
production A, previous shared B from all23-006, and revised shared B. Final
target images are quality-round1-003; unchanged controls use quality-round1-002.

1204 adds only the newly observed left lower frontage and a pale closed-door
variant. 1229 adds visible closures/entries, framed pale closure panels, a deeper
closed apron and segmented shallow hips. Its 1.10 m rise and 7.64 m absolute
eave wall height are bounded reference-relative art proportions, not measured
roof dimensions. The original collision remains at its baseline geometry and
may diverge; this is still a visual experiment. Native roof diagnostics report
actual mesh bounds and the first generated normal per surface, not every normal.
Runs 002 and 003 include original images, native records and rendered-inputs.zip in this checkpoint; run 001 and its original inputs remain locally retained. Independent visual review found useful provisional improvements to both fronts, with simplified recesses/screens/ground and incomplete regions still unresolved. Factual review confirmed final archived input bytes, image hashes, opt-in material isolation and unchanged production scope. It supplies no collision-fit or whole-building acceptance.

## Focused quality round 2

Use `quality_round2.json` with the existing runner to capture 1205 and 1237.
The final comparison is `evidence/housing-family-experiment/quality-round2.html`,
using run 004 A/B alongside prior all23-006 B at the same camera poses.
1205's observed central lower gap and 1237's omitted first-field run 0/lower
groups are restored through instance data. Window sizes stay fixed; upper
positions and eaves are lowered 0.35 m from the first draft to match the
reference-relative composition. The 1.25 m shallow roof rise and 0.32 m eave
depth are bounded inference. Broad versus thin story bands remain distinct.
Screen return heights/materials and pipe-to-eave clamping are explicit opt-ins.

Runs 001 and 003 failed technical checks and remain failed. Their diagnostic logs/results/input archives and run 002’s superseded numerical behavior are included; earlier screenshots remain local. The final repair
triangulates in local coordinates while emitting original points; it removes
only exact duplicate vertices and rejects genuine positive-area failures.
Each run retains its changed inputs in `rendered-inputs.zip`. No new imagery
was acquired and no production collision/acceptance status changed.

Final round-2 004 native records and four originals are included. Independent visual review found the numerical repair preserved the art gains without a new substantive regression: provisional branch checkpoint only. Low roof contrast, simplified entry-screen depth and ground/path subdivision remain, and the 1.25 m rise is inferred. No whole-building, physics or release credit.
