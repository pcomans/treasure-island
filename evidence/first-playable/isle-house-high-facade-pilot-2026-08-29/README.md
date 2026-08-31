# Isle House / 39 Bruton high-part bounded facade pilot

Status: **ready for independent review; not self-accepted**  
Captured: **2026-08-29**, Godot `4.7.2`, Forward+, Metal, Apple M1 Pro, `1440 x 900`

## Exact scope

- Composite parent `w1249412094` remains without a direct receiver. The only attachment target is high part `w1282547786`, receiver `building-composite:w1249412094:w1282547786:wall`.
- Complete `IH-*` modules occur only on observed high-SE runs `5..7`, exactly `42.278 m`. Partial ENE runs `8..9`, exactly `14.442 m`, receive conservative tower/podium material continuity only.
- High shared-above-low runs `10..12`, high runs `0..4`, every low-part run on `w1282547787`, both roofs, and the intentionally omitted low interface receive no facade child or module.
- Homogeneous scalar materials remain separate from complete glazing, podium-window, curtain-wall, ground-glazing, `39` entrance, louver, and canopy motifs. The schedule is explicitly reference-relative and is not asserted as an as-built surveyed count.
- Runtime layout hash: `c5e6393e90152cef62f6478d7bd87750f3db5598d6ebc36cd307ce20acaa090d`; deterministic facade signature: `fdc41a59b4805b49bc6872d4f5e85a7339d328a317c398f3eb7dfb747be5e73c`.

## Comparable evidence

- `01-close.png`: complete entrance/window/curtain-wall language on the observed high-SE frontage.
- `02-close-sprayed.png`: in-range real-controller tag on the unchanged high-part receiver.
- `03-ordinary-gameplay-camera.png`: ordinary third-person whole-high-part reading.
- `04-oblique-gameplay-camera.png`: oblique view showing side-local frontage and restrained return behavior.
- `05-changed-light.png`: same target under a changed deterministic sun direction.
- `capture-manifest.json`: exact camera/player/aim/light transforms, hashes, live receiver identity, run scopes, module counts, world counts, adapter and renderer.
- `ASSET_INVENTORY.sha256`: project assets, integration/test files, generated inputs, manifest and capture hashes.

The final executor check found the intended hierarchy legible: narrow floor-stacked tower windows, subordinate taupe accents, distinct podium opening widths, central dark vertical strip, full-height ground glazing/supports, a separate `39` entrance, localized louver and canopy. The partial ENE remains material-only. This is an evidence comparison, not final art acceptance.

## Exact validation commands and retained results

The full shared command set and retained results are recorded verbatim in the Building 3 evidence README. Target-specific results were:

```text
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_isle_house_facade_contract.gd
# PASS: parent meshless; only high SE 5..7 modules and ENE 8..9 material continuity; low/shared/roofs/collision/spray/Museum/Hawkins unchanged

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_building_3_facade_contract.gd
# PASS: companion target and accepted Hawkins preservation controls

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/full_runtime_integration.gd
# PASS: real main scene world_ready, physics/interactions/spray/cleanup

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/automated_route_qa.gd
# PASS: 14-checkpoint continuous PlayerController route, no stall/recovery/boundary loss

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/next_cohort_facade_capture.gd
# PASS: ten comparable views total; five written here and five to the Building 3 evidence directory
```

All five files here come from the final successful capture pass. Headless runs emit the existing restricted-environment `user://logs` rotation and macOS CA-certificate warnings; assertions and exit codes pass. No unrelated validator failure remains.

## Known limitation and review boundary

The exact generated low part is five levels while the locally recorded real podium is seven levels. Changing that split, silhouette, roof, height or story count is prohibited; the low part therefore remains visibly generic. The independent reviewer should judge the observed high-SE facade language, complete motif boundaries, partial-ENE restraint, ordinary-camera readability, and exact part/overlap isolation separately from the disclosed whole-building massing limitation.

