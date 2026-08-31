# Current-source private Mac export evidence

Date: 2026-08-28  
App: `/Users/philipp/cowork/treasure-island-game/build/current-source-staging-2026-08-28-183204/Treasure Island First Playable.app`  
Engine: Godot `4.7.2.stable.official.ed1daf0bf`

## Result

**PASS for the private local packaged-app path.** The fresh uniquely named bundle exported at exit `0`; no historical build was overwritten or deleted. The app executable itself then launched headlessly, loaded the normal main scene and current resources, passed its bounded world/visual/jetpack gate, and self-closed at exit `0`. No visible Metal smoke was run, so the owner's current live playtest window was not driven or disturbed.

No installation, download, account access, or acquisition occurred. `INSTALL_LOG.md` was not changed.

## Exact commands

The full command list is retained in [`commands.txt`](commands.txt). The export and authoritative launch were:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot \
  --headless --path . \
  --export-release "macOS Private" \
  "build/current-source-staging-2026-08-28-183204/Treasure Island First Playable.app"

"build/current-source-staging-2026-08-28-183204/Treasure Island First Playable.app/Contents/MacOS/Treasure Island First Playable" \
  --headless -- --mac-export-smoke
```

The export exited `0` in `8.60 s`, packed the current generated world and current imported vegetation/tag/context resources, and completed Godot's built-in code-sign stage. [`final-export.log`](final-export.log) retains the command, result, warning, and key pack-stage lines.

## Packaged launch and mounted-PCK audit

The direct app-binary smoke exited `0` in `6.99 s`; the normal main scene reported:

- generated content SHA-256 `1c9fd3ec5a814e48a696267e9ec3b0318543b8b84df407baee6d18b164b03aeb`;
- ferry spawn `(-104.364,3.457,786.024)`, yaw `-0.119`;
- `38/38` chunks, `735+4` coverage rows, `701` meshes, `40,826` triangles, and `466/466` bodies/shapes;
- the current vegetation contract: `102` instances, seed `1414092337`, `15` assets, and `19` MultiMesh batches;
- current visual defaults and semantic palette;
- physical-Space jetpack rise and capped slow descent; and
- `PASS: packaged main scene reached full world_ready, enabled the player, and exercised jetpack rise/slow descent`.

See [`packaged-headless.log`](packaged-headless.log) for the attached startup output.

An independent direct mount of the PCK exited `0`. It found `142` virtual files, the exact `46` generated-world files (`38` chunks), the exact manifest file hash, `13` required current main/player/HUD/world/spray/tag/context/vegetation resource entries, all `15` curated vegetation imports, the physical Space mapping, and zero paths under the configured banned roots (`addons`, `build`, `data`, `discovery`, `evidence`, `node_modules`, `third_party_staging`, `tools`, or `.tools`). It verified every generated file against the packaged manifest. See [`package-audit.log`](package-audit.log).

## Artifact identity

- Executable SHA-256: `ef44bf47983147b5b1b66286b47af11b64f3658b798412b7ede33ae829e28749` (`170,963,648` bytes).
- PCK SHA-256: `a6c37a783771a38cb323a87dad9f73a9e740ca6fa4cd179563b8083129fbdbc4` (`24,108,540` bytes).
- Sorted seven-file bundle descriptor SHA-256: `c3f60f4f236304a5d8456a6e6b37af571c31285b595e845dfa5081cbb14d1520` (`path\0sha256\0bytes\n` records).
- Bundle logical size: `195,145,028` bytes; allocated size: `190,588 KiB`.
- Architectures: universal `x86_64 arm64`.
- Bundle identifier/version: `local.treasure-island.first-playable`, `0.1.0`.
- Signing: Godot-produced ad-hoc hardened runtime; no TeamIdentifier. Strict deep verification exited `0`; the arm64 full CodeDirectory SHA-256 is `d5b7a856121d5e84bd426d233dcb79690de1f4069443861aa2803d0e6280a049`.
- Extended attributes: `com.apple.provenance` only; no quarantine attribute was present.

See [`artifact-and-signing.txt`](artifact-and-signing.txt), [`bundle-inventory.txt`](bundle-inventory.txt), [`release-identity.json`](release-identity.json), and [`source-identity.txt`](source-identity.txt).

## Warnings and scope

- The restricted-process environment could not rotate `user://logs` or read macOS system CA certificates. These messages appeared before the clean app/PCK gates and did not affect local file loading, export, signing, or either exit status.
- The unchanged `export_filter="all_resources"` policy does not exclude `source_assets/`. The PCK therefore contains five small review-source virtual paths (four `.import` descriptors and `validation_report.json`) plus four derived review textures totaling `179,020` bytes. Their exact paths, bytes, and hashes are in [`package-audit.log`](package-audit.log). It does **not** contain the raw NAIP crop, review tiles, GeoJSON annotations, or original review PNG/SVG source bytes. Export behavior was not silently changed.
- The pre-export scan generated/refreshed `.import` metadata for `45` newly visible NAIP review/staging images. It did not rewrite the source imagery, gameplay source, generated world, controls, schemas, or resource policy.
- This is an ad-hoc-signed private build, not a Developer-ID-signed or notarized public distribution artifact. The bounded headless launch proves packaged startup/resource loading, not interactive feel, owner recognition, or native rendered appearance.

