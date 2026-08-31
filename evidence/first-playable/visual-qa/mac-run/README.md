# Final visual-QA macOS export evidence

Date: 2026-08-28  
Target: private/local Apple-silicon Mac playtest  
Engine: project-local Godot 4.7.2 stable (`ed1daf0bf`) with matching installed templates  
Current handoff: `/Users/philipp/cowork/treasure-island-game/build/visual-qa-staging/Treasure Island First Playable.app`

## Result

**PASS with no P0/P1 package blocker.** This is the only current app handoff. `build/mac/`, `build/ferry-spawn-staging/`, and `build/jetpack-staging/` remain historical and were not accessed, overwritten, launched, or modified by the authoritative export/audit round.

The final source parse, gameplay/ambient contract, generated-world validator, full-runtime integration, and source `--mac-export-smoke` all exited `0` outside the restricted process sandbox. The source smoke printed the exact ferry/world identity plus:

```text
MAC_EXPORT_VISUAL: ambient_source=2 ambient_color=(0.71,0.77,0.82,1.00) ambient_energy=0.65 sky_contribution=0.00 camera_pivot_y=2.00 spring_length=5.50 pitch=-8.0deg semantic_palette=pass
MAC_EXPORT_JETPACK: rise=2.751m ascent_velocity=5.000mps slow_descent=0.300m minimum_velocity=-1.500mps
```

The current source was exported with:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot \
  --headless --path . \
  --export-release "macOS Private" \
  "build/visual-qa-staging/Treasure Island First Playable.app"
```

The final export exited `0` in 4.86 seconds and completed PCK packing plus Godot's built-in ad-hoc signing without warning/error output.

## Packaged world and source inventory

The PCK was mounted directly with the cleared Godot binary. Its complete per-file SHA-256 inventory is in [`package-audit.log`](package-audit.log):

- 95 packaged virtual files.
- All 44 generated-world files and all 38 chunks.
- Generated manifest file SHA-256 `07b8b195e1a05942e38d9bbbcb801394cf9f184051fb5f7a819c75677e46f160`.
- Generated content SHA-256 `5899ebe131bbf05525fedebdac703a321a7aaf95523a57960cb937085068cfaa`.
- Ferry spawn `(-104.364, 1.000, 786.024)`, yaw `-0.119`.
- Physical Space bound to `jetpack`.
- Current remapped/compiled `main`, player scene/camera, world root/palette builder, automated route, and rendered-evidence harness resources present. [`source-identity.txt`](source-identity.txt) records the corresponding tested source-file hashes; packaged behavior is independently pinned by both smoke runs.
- Zero paths from `addons`, `build`, raw `data`, `discovery`, `evidence`, `node_modules`, `tools`, `.tools`, install records, or package-manager files.

## Packaged launch results

The packaged headless executable ran the normal fail-closed main scene and exited `0` in 5.11 seconds. It loaded all exact world counts in 1,319 ms, printed the required visual line, exercised physical-Space rise/slow descent, printed `MAC_EXPORT_JETPACK`, and reached PASS. [`packaged-headless.log`](packaged-headless.log) contains no engine error, authored warning, crash, debugger, or leak text.

One bounded ordinary launch used Metal 4.0 / Forward+ on the Apple M1 Pro and self-closed with exit `0` in 4.17 seconds. It loaded the exact world in 1,354 ms and printed both `MAC_EXPORT_VISUAL` and `MAC_EXPORT_JETPACK` before PASS. [`ordinary-launch.log`](ordinary-launch.log) is technical native-renderer startup evidence; it is not an interactive play session, screenshot, owner recognition judgment, or input-feel acceptance.

An earlier superseded ordinary attempt during this round reached renderer/world/visual readiness but lost focus to an already-running historical owner window, paused physics, and hit the smoke watchdog. The lead authorized a test-only correction: normal gameplay still pauses on focus-out, while `--mac-export-smoke` ignores focus-out so its deterministic physics gate can finish. All source gates were then rerun, the app was re-exported, every identity recomputed, and both final packaged smokes passed. The retained authoritative logs contain only the clean final runs.

## Exact artifact identity

- Executable SHA-256: `78ac62154990ff97ddd9340d70c1a19b10c5bb9981ea37e895d1d60ebeb3fae9` (`170,963,648` bytes).
- PCK SHA-256: `0af209e03f4b511c260570969433ecd2ce7701e5c64da8dfed7ae977a9d98bb5` (`5,959,788` bytes).
- Sorted seven-file bundle inventory SHA-256: `c19ea2b1ad9e77917fdf997ec50eadb26876e5b4659eb3f10e9b73c9c1909ace`.
- Bundle logical size: `176,996,276` bytes; allocated size: `172,868 KiB`.
- Actual architectures: Universal `x86_64 arm64`; this host used arm64. No Intel runtime certification was performed.
- Bundle identifier/version: `local.treasure-island.first-playable`, `0.1.0` (`0.1.0`).
- Signing: Godot-produced ad-hoc hardened runtime, no TeamIdentifier. Strict deep and arm64 signature verification both exited `0`; arm64 full CDHash is `90d273225f6c6f05f72a2f1c8e4577e6a5e5acdef7a9873e027c20877ddc8819`.
- Gatekeeper: expected rejection, `spctl` exit `3`. This private app is neither Developer-ID signed nor notarized and is not public-distribution ready.
- Extended attributes: `com.apple.provenance` only; no quarantine attribute.

See [`artifact-and-signing.txt`](artifact-and-signing.txt), [`bundle-inventory.txt`](bundle-inventory.txt), and [`release-identity.json`](release-identity.json) for the exact machine-readable identity.

## Remaining owner checks

No technical package P0/P1 remains. The owner still needs the ordinary interactive pass in [`PLAYTEST.md`](../../../../PLAYTEST.md): recognition of Treasure Island and simple horizon context, north/center/southwest/perimeter travel, real mouse/camera feel, jetpack feel, eligible/ineligible spray appearance, recovery, pause/resume, and in-app exit. The successful auto-close launch does not claim those judgments.
