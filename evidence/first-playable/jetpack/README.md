# Jetpack source-runtime evidence

Checked: 2026-08-28

The source project now maps physical `Space` to an endless, hold-to-rise jetpack. Vertical response is capped at `5.0 m/s` upward and `1.5 m/s` downward with a `12.0 m/s²` response. Releasing Space transitions to the capped slow descent; pressing it again in mid-air resumes ascent. Existing camera-relative walk/run steering remains active in the air. There is no fuel, cooldown, UI, asset, dependency, or terrain change.

The clean Godot 4.7.2 headless checks passed against the real generated island:

- Scene/script parse and the input/controller contract exited `0`; Space and the three conservative controller defaults are pinned.
- The full runtime rose `4.000 m` during the held-input window, moved `1.598 m` at air-walk speed and `3.280 m` at air-run speed, held descent to `0.500 m` over 20 physics frames, resumed a `1.210 m` ascent in mid-air, and landed normally without an automatic recovery.
- Walk/run, manual and boundary recovery, spray behavior, tag eviction, fail-closed reload, and scene cleanup still passed.
- The normal source `--mac-export-smoke` path now requires the packaged `jetpack` action to be bound to physical Space, then performs its own bounded jetpack gate after full `world_ready`: `2.751 m` rise at the `5.000 m/s` cap and `0.300 m` slow descent at the `-1.500 m/s` cap.

The exact sanitized output is in [`headless-suite.log`](headless-suite.log). These are source-project results only. No app was launched, changed, or exported in this round; a later isolated export must emit `MAC_EXPORT_JETPACK` before it can count as the current package.

Terrain remains planar. Generated playable land is at `y = 0`; `0.02–0.05 m` surface-overlay offsets only prevent visual overlap, and building heights do not create ground elevation.
