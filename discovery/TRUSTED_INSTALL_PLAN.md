# Trusted Acquisition and Install Plan

Checked: 2026-08-27

Status: research and planned ledger entries only. No artifact or package was downloaded, installed, extracted, or executed during this review. The project lead subsequently relayed the owner's approval of the exact approach bundle and vetted, logged installs; acquisition still must not begin until the lead has made the shared approval record authoritative and the applicable `planned` entries have been copied into [`INSTALL_LOG.md`](../INSTALL_LOG.md).

## Result

The exact acquisition candidates are available from official publisher or registry sources:

| Resource | Exact candidate | Official source | Publisher | Primary integrity evidence |
|---|---|---|---|---|
| Godot standard macOS editor | `Godot_v4.7.2-stable_macos.universal.zip` | [Godot's official build release](https://github.com/godotengine/godot-builds/releases/tag/4.7.2-stable) and [versioned Godot download page](https://godotengine.org/download/archive/4.7.2-stable/) | Godot Engine official builds; macOS signing/notarization identity documented as Prehensile Tales B.V. | SHA-256 `c58a24e31d720be9d62f60cb5627c4e695fb72f21b0cfe1bc9ccaa9a3b3ba63e` |
| Matching standard export templates | `Godot_v4.7.2-stable_export_templates.tpz` | [Godot's official build release](https://github.com/godotengine/godot-builds/releases/tag/4.7.2-stable) and [versioned Godot download page](https://godotengine.org/download/archive/4.7.2-stable/) | Godot Engine official builds | SHA-256 `f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011` |
| Polygon Boolean package | `polygon-clipping@0.15.7` | [versioned npm page](https://www.npmjs.com/package/polygon-clipping/v/0.15.7) and [public-registry metadata](https://registry.npmjs.org/polygon-clipping/0.15.7) | Mike Fogel / npm user `mfogel`; upstream [`mfogel/polygon-clipping`](https://github.com/mfogel/polygon-clipping/tree/v0.15.7) | npm SRI `sha512-nhfdr83ECBg6xtqOAJab1tbksbBAOMUltN60bU+llHVOL0e5Onm1WpAXXWXVB39L8AJFssoIhEVuy/S90MmotA==` plus registry ECDSA signature |
| Triangulation package | `earcut@3.2.3` | [versioned npm page](https://www.npmjs.com/package/earcut/v/3.2.3) and [public-registry metadata](https://registry.npmjs.org/earcut/3.2.3) | npm publisher Vladimir Agafonkin / user `mourner`; maintained in [`mapbox/earcut`](https://github.com/mapbox/earcut/tree/v3.2.3) | npm SRI `sha512-vnS4AVwp1KHAF13i1vp1/2D5evWy3k5u/iW/B81QVsUZtV8cv2tU0b2VNFlqvh4kYwrFMDdjPCfAmfyJW9y14Q==` plus registry ECDSA signature |

Godot's [official asset list](https://github.com/godotengine/godot-builds/releases/expanded_assets/4.7.2-stable) publishes both SHA-256 values above. The [official macOS page](https://godotengine.org/download/macos/) identifies 4.7.2 as a Universal Apple-silicon/Intel build, says it is extract-and-run and self-contained, and says the macOS build is code-signed and notarized by Prehensile Tales B.V. Godot's source tag resolves to commit [`ed1daf0bf001b61586d9930840f2f1394092c079`](https://github.com/godotengine/godot/commit/ed1daf0bf001b61586d9930840f2f1394092c079), whose commit signature GitHub reports as verified. That source signature is useful corroboration but is not a detached signature over either binary artifact.

The two npm versions are the registry's current `latest` versions as checked on 2026-08-27. Exact registry tarball URLs are:

- `https://registry.npmjs.org/polygon-clipping/-/polygon-clipping-0.15.7.tgz`
- `https://registry.npmjs.org/earcut/-/earcut-3.2.3.tgz`

Do not acquire those tarballs manually. Use the existing npm CLI against `https://registry.npmjs.org/` so npm verifies SRI, records every resolved package and integrity value in `package-lock.json`, and can verify registry signatures. The npm documentation explains [exact saves and script suppression](https://docs.npmjs.com/cli/install/), [lockfile reproducibility and integrity](https://docs.npmjs.com/cli/v11/configuring-npm/package-lock-json/), and [`npm audit signatures`](https://docs.npmjs.com/verifying-registry-signatures/).

## Trust limits and stop conditions

- The Godot release supplies artifact SHA-256 digests and a separate `SHA512-SUMS.txt`, but no detached publisher signature over the ZIP or TPZ was found. Use the published SHA-256 digest plus macOS code-signing/notarization checks for the editor. The TPZ has hash provenance only; do not claim that the archive or every non-macOS template within it is Apple-notarized.
- The expected Godot signer name is Prehensile Tales B.V. because that is what the official macOS page currently documents. No Team ID is recorded here because an official source establishing an expected Team ID was not found. Record the complete live `codesign` output and stop if the signer name, signature validity, notarization assessment, version, or architecture is unexpected.
- `polygon-clipping@0.15.7` has npm `gitHead` `25f2a460ca7bd750d958d3d83b0037a32fcf75f6`, matching upstream tag `v0.15.7`. GitHub reports that commit signature as verified, but the signing key is now expired. The npm version has a registry signature but no published provenance attestation.
- `earcut@3.2.3` has npm `gitHead` `f183d7a06535290bc22163ca5ca2248e4d5a04c5`, matching upstream tag `v3.2.3`. The upstream tag and commit are unsigned, and the npm version has no published provenance attestation. Its npm registry ECDSA signature protects the name/version/integrity tuple from registry-mirror tampering, but it is not an upstream author signature. This publisher-to-source provenance gap remains unresolved and must be recorded, not promoted into a stronger claim.
- `polygon-clipping@0.15.7` declares transitive ranges `robust-predicates@^3.0.2` and `splaytree@^3.1.0`; therefore the direct version alone does not freeze the whole tree. The generated and committed `package-lock.json` is mandatory. Record the actual transitive versions and SRI values from that lockfile rather than predicting them here.
- Stop on any hash mismatch, missing or invalid npm registry signature, package tarball resolved outside `registry.npmjs.org`, unreviewed lifecycle-script execution, unexpected Godot publisher, failed Gatekeeper/notarization result, version mismatch, architecture mismatch, OS malware warning, or unexplained installer behavior. Do not disable Gatekeeper globally and do not use an installer script or mirror.

No exact version conflict currently prevents a later approved installation. The unresolved signature/provenance limitations above are evidence-quality limits, not hidden version substitutions.

## Safest scoped acquisition method

### Godot editor and templates

Use one ignored project-local directory, proposed as `/Users/philipp/cowork/treasure-island-game/.tools/godot/4.7.2/`. Place the official ZIP and TPZ in a staging subdirectory, verify both before extraction, extract `Godot.app` into that exact version directory, and place an empty `_sc_` file beside—not inside—the `.app` bundle. Godot documents that [self-contained mode](https://docs.godotengine.org/en/4.7/classes/class_editorpaths.html) keeps editor configuration, data, cache, and export templates in adjacent `editor_data/`; it also warns that putting `_sc_` inside the app breaks its signature.

Before first execution, run these checks from the exact staged paths, substituting no different filenames:

```sh
shasum -a 256 "/Users/philipp/cowork/treasure-island-game/.tools/godot/4.7.2/staging/Godot_v4.7.2-stable_macos.universal.zip"
shasum -a 256 "/Users/philipp/cowork/treasure-island-game/.tools/godot/4.7.2/staging/Godot_v4.7.2-stable_export_templates.tpz"
codesign --verify --deep --strict --verbose=2 "/Users/philipp/cowork/treasure-island-game/.tools/godot/4.7.2/Godot.app"
codesign --display --verbose=4 "/Users/philipp/cowork/treasure-island-game/.tools/godot/4.7.2/Godot.app"
spctl --assess --type execute --verbose=4 "/Users/philipp/cowork/treasure-island-game/.tools/godot/4.7.2/Godot.app"
xcrun stapler validate "/Users/philipp/cowork/treasure-island-game/.tools/godot/4.7.2/Godot.app"
lipo -archs "/Users/philipp/cowork/treasure-island-game/.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
```

The two `shasum` results must equal the table values, `codesign` must validate and display the documented signer, `spctl` must accept the app as a notarized Developer ID application, `stapler` must validate a ticket, and `lipo` must report both `arm64` and `x86_64`. Stop rather than bypass any failed result. After those independent checks, follow Godot's documented macOS/self-contained guidance to remove quarantine only from this exact verified app if required; never use `spctl --master-disable`. Then create `_sc_` beside the app while it is not running.

Only after all trust checks pass, verify the executable version:

```sh
"/Users/philipp/cowork/treasure-island-game/.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot" --version
```

The output must identify `4.7.2.stable.official`; record its full output and reconcile its build hash with the official 4.7.2 release commit. Install the already-hashed TPZ through `Editor > Manage Export Templates… > Install from File`. Godot's [export documentation](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_projects.html) documents this TPZ workflow. In self-contained mode the resulting version-specific templates must appear under `editor_data/export_templates/4.7.2.stable/`; record the exact displayed template version and location.

Scope is limited to the versioned `.tools/godot/4.7.2/` directory plus ordinary project import metadata created later when the approved project is opened. No `/Applications` copy, Homebrew cask, Steam/itch/Epic install, account, privileged installer, shell profile change, or global Godot template directory is needed.

Removal: close Godot, move only `/Users/philipp/cowork/treasure-island-game/.tools/godot/4.7.2/` to Trash, and update the install-log entry to `removed`. Because self-contained mode keeps editor data and templates there, that one recoverable move removes the editor, templates, cache, and settings for this version. Separately review any project-owned `.godot/` import cache before removing it; do not delete project source or exported builds as part of tool removal.

### npm packages

Run the acquisition only from `/Users/philipp/cowork/treasure-island-game` after a project-owned `package.json` exists. Use the already-installed Node/npm toolchain, the public npm registry explicitly, exact direct versions, suppressed lifecycle scripts, and a project-local npm cache:

```sh
npm install --save-dev --save-exact --ignore-scripts --registry=https://registry.npmjs.org/ --cache=.tools/npm-cache polygon-clipping@0.15.7 earcut@3.2.3
npm audit signatures --registry=https://registry.npmjs.org/ --cache=.tools/npm-cache
npm ls polygon-clipping earcut --depth=0
npm audit --audit-level=high --registry=https://registry.npmjs.org/ --cache=.tools/npm-cache
```

The install must write exact `devDependencies`, generate/update `package-lock.json`, and place packages only under project `node_modules/`; the cache stays under `.tools/npm-cache/`. Commit `package.json` and `package-lock.json`, but never `node_modules/` or `.tools/`. `npm audit signatures` must exit successfully with no missing or invalid registry signatures; record any provenance-attestation count exactly as printed and do not claim provenance for these two packages when none is reported. Record the direct and transitive versions, `resolved` registry hosts, and `integrity` fields from the live lockfile. A clean later reproduction should use:

```sh
npm ci --ignore-scripts --registry=https://registry.npmjs.org/ --cache=.tools/npm-cache
npm audit signatures --registry=https://registry.npmjs.org/ --cache=.tools/npm-cache
```

Removal: from the same project root, run `npm uninstall --save-dev --ignore-scripts polygon-clipping earcut`, review the resulting `package.json` and `package-lock.json` diff, and retain the lockfile for any remaining dependencies. Remove only now-unused entries and transitive directories; do not delete the manifests wholesale unless they are confirmed to have been created solely for these packages. Move `.tools/npm-cache/` to Trash if no longer needed, then mark both install-log entries `removed`.

## Planned `INSTALL_LOG.md` entries

Copy these entries into the install log before acquisition. Replace the UTC placeholders and complete every result field immediately after the corresponding operation.

### 2026-08-27 — Godot Engine standard editor and export templates

- Date and time (UTC): `TBD immediately before acquisition`
- Status: `planned`
- Exact package and version: Godot Engine `4.7.2-stable`, standard/GDScript Universal macOS editor `Godot_v4.7.2-stable_macos.universal.zip`; matching standard templates `Godot_v4.7.2-stable_export_templates.tpz`; no .NET build.
- Publisher and source URL: Godot Engine official builds, [release](https://github.com/godotengine/godot-builds/releases/tag/4.7.2-stable); exact [editor asset](https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_macos.universal.zip); exact [template asset](https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz); documented macOS signer/notarization identity Prehensile Tales B.V.
- Checksum, signature, notarization, or registry integrity evidence: editor SHA-256 `c58a24e31d720be9d62f60cb5627c4e695fb72f21b0cfe1bc9ccaa9a3b3ba63e`; TPZ SHA-256 `f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011`; release also publishes `SHA512-SUMS.txt`; record live `codesign`, `spctl`, and `stapler` results. No detached artifact signature found.
- Exact command or installation method: download the two exact official release assets into the versioned project-local staging directory; verify SHA-256; extract the ZIP with macOS Archive Utility or `ditto -x -k`; validate signature/notarization/architectures; enable documented self-contained mode with `_sc_` beside the intact app; install the verified TPZ with `Editor > Manage Export Templates… > Install from File`.
- Purpose: proposed native editor/runtime and matching private macOS export support for the approved first-playable bundle.
- Scope and install location: `/Users/philipp/cowork/treasure-island-game/.tools/godot/4.7.2/`, including adjacent `editor_data/`; no system-wide install.
- Authorizing decision or request: owner's approval of the exact bundle in [`APPROACH_PROPOSAL.md`](APPROACH_PROPOSAL.md), relayed by the project lead on 2026-08-27; replace this text with the canonical recorded decision reference before acquisition.
- Trust and malware checks: exact hashes; strict code-signature validation; expected signer inspection; Gatekeeper/notarization assessment; stapled-ticket validation; allow macOS malware checks; stop on any mismatch or warning and never disable Gatekeeper globally.
- Verification and result: `planned`; later record full `--version`, `lipo`, `codesign`, `spctl`, `stapler`, installed-template version/path, and result.
- Removal steps: close Godot and move only `/Users/philipp/cowork/treasure-island-game/.tools/godot/4.7.2/` to Trash; separately review disposable project `.godot/` cache; update status to `removed`.

### 2026-08-27 — polygon-clipping npm package

- Date and time (UTC): `TBD immediately before acquisition`
- Status: `planned`
- Exact package and version: `polygon-clipping@0.15.7` as a development dependency.
- Publisher and source URL: Mike Fogel / npm user `mfogel`; [npm version](https://www.npmjs.com/package/polygon-clipping/v/0.15.7); [registry metadata](https://registry.npmjs.org/polygon-clipping/0.15.7); [upstream tag](https://github.com/mfogel/polygon-clipping/releases/tag/v0.15.7).
- Checksum, signature, notarization, or registry integrity evidence: npm SRI `sha512-nhfdr83ECBg6xtqOAJab1tbksbBAOMUltN60bU+llHVOL0e5Onm1WpAXXWXVB39L8AJFssoIhEVuy/S90MmotA==`; SHA-1 registry shasum `3823ca1e372566f350795ce9dd9a7b19e97bdaad`; registry ECDSA signature present; npm `gitHead` matches upstream `25f2a460ca7bd750d958d3d83b0037a32fcf75f6`; upstream commit signature verified but key now expired; no npm provenance attestation found.
- Exact command or installation method: the combined exact, project-local `npm install --save-dev --save-exact --ignore-scripts --registry=https://registry.npmjs.org/ --cache=.tools/npm-cache polygon-clipping@0.15.7 earcut@3.2.3`, followed by `npm audit signatures` and lockfile inspection.
- Purpose: deterministic polygon Boolean operations in the approved offline OSM conversion step.
- Scope and install location: project `devDependencies`, `node_modules/`, `package-lock.json`, and `.tools/npm-cache/`; no global package install.
- Authorizing decision or request: owner's approval of APPROACH-002 in [`APPROACH_PROPOSAL.md`](APPROACH_PROPOSAL.md), relayed by the project lead on 2026-08-27; replace with canonical decision reference before acquisition.
- Trust and malware checks: SRI enforced by npm/lockfile; registry signatures must verify; lifecycle scripts suppressed; registry hosts and full dependency tree reviewed; `npm audit` result recorded. Stop on missing/invalid signatures, unexpected hosts, lifecycle execution, or high-severity audit failure pending review.
- Verification and result: `planned`; later record exact direct/transitive versions, lockfile integrities, `npm audit signatures`, `npm ls`, and `npm audit` results.
- Removal steps: `npm uninstall --save-dev --ignore-scripts polygon-clipping earcut`; review manifest/lockfile diff; remove only unused transitive content and move the project-local npm cache to Trash if unused; update status to `removed`.

### 2026-08-27 — earcut npm package

- Date and time (UTC): `TBD immediately before acquisition`
- Status: `planned`
- Exact package and version: `earcut@3.2.3` as a development dependency.
- Publisher and source URL: Vladimir Agafonkin / npm user `mourner`, maintained in the Mapbox repository; [npm version](https://www.npmjs.com/package/earcut/v/3.2.3); [registry metadata](https://registry.npmjs.org/earcut/3.2.3); [upstream release](https://github.com/mapbox/earcut/releases/tag/v3.2.3).
- Checksum, signature, notarization, or registry integrity evidence: npm SRI `sha512-vnS4AVwp1KHAF13i1vp1/2D5evWy3k5u/iW/B81QVsUZtV8cv2tU0b2VNFlqvh4kYwrFMDdjPCfAmfyJW9y14Q==`; SHA-1 registry shasum `74aec19555a7e28773429826729d2e4bfeb19022`; registry ECDSA signature present; npm `gitHead` matches upstream `f183d7a06535290bc22163ca5ca2248e4d5a04c5`; upstream tag/commit unsigned and no npm provenance attestation found.
- Exact command or installation method: the same combined exact, project-local npm command above, followed by signature audit and lockfile inspection.
- Purpose: triangulate validated polygons and holes in the approved offline OSM conversion step.
- Scope and install location: project `devDependencies`, `node_modules/`, `package-lock.json`, and `.tools/npm-cache/`; no global package install.
- Authorizing decision or request: owner's approval of APPROACH-002 in [`APPROACH_PROPOSAL.md`](APPROACH_PROPOSAL.md), relayed by the project lead on 2026-08-27; replace with canonical decision reference before acquisition.
- Trust and malware checks: SRI enforced by npm/lockfile; registry signatures must verify; lifecycle scripts suppressed; registry hosts and full dependency tree reviewed; unsigned upstream/no-provenance limitation explicitly retained; `npm audit` result recorded.
- Verification and result: `planned`; later record exact direct/transitive versions, lockfile integrities, `npm audit signatures`, `npm ls`, and `npm audit` results.
- Removal steps: remove through the combined `npm uninstall --save-dev --ignore-scripts polygon-clipping earcut`; review manifest/lockfile diff; remove only unused transitive content and move the project-local npm cache to Trash if unused; update status to `removed`.

## Resource-register consequence

The artifact identities, versions, price, account requirements, and requested scope in [`RESOURCE_REQUESTS.md`](RESOURCE_REQUESTS.md) were factually correct at the time of this review, so this agent made no edit there. Its status transition after the owner's later approval belongs to the project lead's canonical decision/request update and must occur before acquisition; this plan does not silently change shared status ownership.

No approach selected.
