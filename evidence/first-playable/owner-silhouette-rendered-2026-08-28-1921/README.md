# Owner-photo skyline silhouette — rendered evidence

This is the current source-project Forward+/Metal evidence for the owner-photo-derived San Francisco billboard after replacing the architectural outline with one filled slate-blue silhouette. The complete 12-frame harness exited `0` on the local Apple M1 Pro using Godot `4.7.2.stable`.

## Result

- **Style accepted by project lead:** the ferry-facing frame reads as one continuous distant city mass rather than white/cartoon linework. The approved landmark profile and existing scale were retained.
- Active texture: `res://game/resources/textures/context/sf_skyline_owner_silhouette_final.png`.
- Texture SHA-256: `9c499ca3db08769142aac69b61e7d8fdf2aa84cd084b6716a19e7c504ba0b0c5`; `2212x340`; exactly one opaque visible color (`#526979`) plus transparency.
- Billboard: `1950x300 m` at `(-2500,132.5,750)`, projected width `521.130 px` (`36.190%` of the `1440x900` viewport), no collision or world blocker.
- Full real-main-scene integration also exited `0`: the exact current world reached `world_ready`, the first player frame was grounded, and movement, jetpack, recovery, tagging, generated physics, and fail-closed reload contracts passed.

## Key files

- `07-horizon-context.png` — current ferry/west-facing skyline judgment; SHA-256 `426909bc0a934f7215e2e2bfc02f6bf02d3630efff3172ac296daa948814d6ff`.
- `01-ferry-spawn.png` — normal ferry spawn context; SHA-256 `977ebe55668fa7dbe70ab0665ffd6a1357e399fc77409125edf288ceda926d9b`.
- `08-ybi-bridge-context.png` — opposite context-isolation check; SHA-256 `0fa9d2bfaaba32844957c53bdeafa64941edc6feab2f66e905f7e9bd42d2079e`.
- `capture-manifest.json` — complete geometry, grounding, camera, resource, and per-frame facts; SHA-256 `a94ad40bc89c533bafbf21fe2ec56291f3aec29b6886dca45769ecdcd195322c`.

## Reproduction

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot \
  --path . \
  --display-driver macos \
  --rendering-method forward_plus \
  --rendering-driver metal \
  --audio-driver Dummy \
  --resolution 1440x900 \
  --script game/tests/rendered_visual_evidence_capture.gd \
  -- --visual-evidence-output=evidence/first-playable/owner-silhouette-rendered-2026-08-28-1921
```

This evidence proves the source render and the stated geometric/runtime contracts. Package identity and bounded exported-app launch belong to the separately recorded current Mac-export evidence.
