# Jetpack staged macOS export evidence

Date: 2026-08-28  
Target: Apple-silicon M1 Pro host, macOS private/local build  
Engine: project-local Godot 4.7.2 stable (`ed1daf0bf`) with the installed matching 4.7.2 templates  
Output: `/Users/philipp/cowork/treasure-island-game/build/jetpack-staging/Treasure Island First Playable.app`

## Result

PASS. The current jetpack source was exported only to the new isolated staging path. No older app bundle was accessed, overwritten, launched, or modified, and no non-headless process was run.

The staged PCK was mounted directly and passed an exact audit:

- 91 packaged runtime files.
- All 44 generated-world files, including all 38 chunk JSON files.
- Manifest file SHA-256 `07b8b195e1a05942e38d9bbbcb801394cf9f184051fb5f7a819c75677e46f160`.
- Ferry spawn `(-104.364, 1.000, 786.024)` and yaw `-0.119`.
- Packaged `jetpack` input has physical Space (`physical_keycode=32`).
- No packaged `addons`, `build`, `data`, `discovery`, `evidence`, `node_modules`, `tools`, `.tools`, install log, or package-manager files.

The staged executable then ran only as:

```text
.../Contents/MacOS/Treasure Island First Playable --headless -- --mac-export-smoke
```

It exited 0 deterministically in 5.55 seconds. The real fail-closed loader reached `world_ready` in 1,347 ms with content hash `5899ebe131bbf05525fedebdac703a321a7aaf95523a57960cb937085068cfaa`, exact ferry transform, 38/38 chunks, 735+4 coverage, 701 meshes, 21,210 triangles, and 466 bodies/shapes. It printed:

```text
MAC_EXPORT_JETPACK: rise=2.751m ascent_velocity=5.000mps slow_descent=0.300m minimum_velocity=-1.500mps
PASS: packaged main scene reached full world_ready, enabled the player, and exercised jetpack rise/slow descent
```

The output contained no engine error, warning, debugger break, or leak report.

## Exact artifact identity

- Executable SHA-256: `eb82dabcaa777956778fd40504f2c94a08300bf900ac7bb99c14472f1dd70e10`
- PCK SHA-256: `6fe39d87544a087d2743cdcecd0033177e5657c9f779fd0ca76ebea9169f5579`
- Sorted bundle file-content inventory SHA-256: `8a35e58e043291c096e7755a286593d59945106feb145bda7e708645f786763e`
- Logical bundle size: 176,946,180 bytes across 7 files; allocated size: 172,816 KiB.
- Executable size: 170,963,648 bytes; PCK size: 5,909,692 bytes.
- Actual architectures: Universal `x86_64 arm64` (despite the preset's arm64 selection); the staged run was on the M1 Pro host.
- Bundle ID: `local.treasure-island.first-playable`.
- Signature: Godot-produced ad-hoc hardened runtime, no TeamIdentifier. Strict deep verification and explicit arm64 verification both exited 0. Arm64 full CDHash: `75543c1a1e0433e24020c89434dd903d55af16c2baf641973ac46d11467ff055`.
- Gatekeeper: expected private-build rejection, `spctl` exit 3. This app is neither Developer-ID signed nor notarized and is not a public-distribution artifact.
- Extended attributes: `com.apple.provenance` only; no quarantine attribute was present.

See `baseline.log`, `final-export.log`, `package-audit.log`, `packaged-headless.log`, `artifact-and-signing.txt`, and `release-identity.json` beside this file.

