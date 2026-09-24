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

The gallery selects final run `all23-006`: 46 originals for 23 provisional
comparisons. 1237, 1204, 1205, 1229 and 1397 remain incomplete regional studies, with
blank lower fields and unverified elevations. The farther three-quarter 1229
view does not establish whole-building roof fidelity. The other 52 of the
75 shortlisted buildings remain unconfirmed. Earlier run 005 stays unchanged locally. Independent visual review calls the final result a useful provisional A/B experiment, with shared trim/screen regressions substantially repaired and 1221 roof variation restored. 1229 roof/apron fidelity remains unresolved; 1227/1234 screens are denser than A, and 1226 is partly occluded. No whole-building acceptance follows.
