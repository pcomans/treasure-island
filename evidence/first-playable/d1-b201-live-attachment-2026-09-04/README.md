# D1 B201 `w34313545` — actual-live host-partition attachment evidence

Status: independently accepted for the exact-current live world. The sealed
external bar-raiser receipt at
`INDEPENDENT_LIVE_VISUAL_BAR_RAISER_REVIEW.md` is SHA-256
`b9ef912df2dd00fa2c456a8e7e03473001cc381cbc2dd5288e9f6ef65d8c2772`.
It authorizes exactly one additional reference-recognizable physical unit for
`physical-building:w34313545`, moving the canonical rollup from the frozen
capture-time `6/213` to exact-current `7/213`. It does not authorize separate
credit for the wall, roof, canopy, windows, posts, service leaves, or spray tag.

## Measured integration

The world builder claims exactly `building:w34313545:wall`. It preserves the
single 80-triangle generated wall mesh, its one collider, and its sole spray
ownership. Runs `0..9` become one 20-triangle metre-UV warm-wall surface;
protected runs `10..39` remain one 60-triangle generic surface. The adapter
adds six render-only MultiMesh batches containing 172 grounded detail boxes and
2,064 triangles. Those details add zero collision, shape, navigation, decal, or
spray owners. The exact roof row remains untouched.

- Whole world: 735 playable rows, 950 meshes, 964 surfaces, 66,636 triangles,
  466 static bodies, and 466 shapes.
- Delta from the accepted pre-B201 world `735/944/957/64572/466/466`:
  `+0/+6/+7/+2064/+0/+0`.
- Receiver result: 7 meshes, 8 surfaces, 2,144 triangles, one body, one shape,
  and one wall-spray owner.
- Host partition: 80 triangles total; 20 eligible warm-wall triangles; 60
  protected generic triangles.
- Decorative signature:
  `705c5345509f77cd91359f66173fff0e1e132d41ebb9acef3f51ff2c467abb3a`.
- Canonical wall row SHA-256:
  `024b2ed0af4de1a7e8456fcd171e1abc27a212dd72d054a9d9d1d487effa98b3`.
- Canonical protected roof row SHA-256:
  `53994e07ee99632a338d8c577427efac3ca3c584148f4d9ef92a251a49e589ff`.

The active package plan is exactly one whole-direct-wall-receiver scope with
`run_count: 40`. Its exact eight-asset metadata closure is the config, adapter,
and six `d1_current` materials. It has one executable asset (the adapter), no
projection descriptors, no fallback or stacking permission, and no generic
registry-loader dispatch in world construction. Catalog/runtime registry are
version 7; adapter contracts/loader API are version 6; compiler is `1.6.0`.
Its geometry contract labels the measured `735/950/964/66636/466/466`
snapshot with exact `world_topology_scope: current_integration_topology`.
The Isle House receipt originally measured `735/940/954/64118/466/466`.
The subsequent Navy Chapel promotion deliberately advanced the shared live
integration baseline to `735/944/957/64572/466/466` and stored that same
pre-B201 snapshot for both Isle House and Navy Chapel. Those preserved derived
snapshots now carry exact
`world_topology_scope: pre_b201_integration_live_parity`; they are not either
unit's receipt-time claim and are not current whole-world oracles. The current
B201 integration totals above are authoritative.
The adapter's `review_status: independent_exact_current_live_pass` describes
the provenance review of its exact runtime assets; its exact
`review_status_scope` explicitly excludes reference-recognition authority.
Recognition acceptance instead derives from the mapped physical unit's
`claim_status.reference_recognizable: accepted` plus its separately sealed
independent reference-recognition acceptance receipt. The catalog, compiler,
runtime registry, and loader reject a missing or contradictory scope,
authority, derived status, physical-unit claim, or receipt.

## Native evidence

- `images/01-whole-wsw-default.png`: grounded stock-player whole WSW side under
  default light.
- `images/02-whole-wsw-changed-light.png`: exact same player/camera pose under
  frozen changed light.
- `images/03-whole-wsw-default-grayscale.png`: deterministic luminance
  derivative of the exact default PNG, without crop or relight.
- `images/04-wsw-hierarchy-oblique.png`: grounded ordinary-player oblique view
  of the register, canopy, frame, post, and service hierarchy.
- `images/05-close-sprayed-host.png`: real predefined spray tag placed on the
  retained sole host collider, with a measured rendered pixel delta.
- `b201-actual-live-normal-forward-approach.avi`: canonical 1440×900 Motion-JPEG
  MovieWriter output. The useful interval covers 360 grounded physics samples
  over 6 seconds using only `move_forward`, approaching from 51.9999962 m to
  28.2470646 m outward and moving 23.7529758 m in XZ between its first and
  360th samples. The top-level 28.1209736 m / 23.8790226 m endpoint is recorded
  after input release and 12 additional braking physics frames. The camera basis
  stays fixed, every center sample hits the exact receiver, and no recovery
  occurs. `INDEPENDENT_MOTION_BOUNDARY_CLARIFICATION.md` preserves this exact
  distinction without changing the sealed motion, movie, or review bytes.

`motion-capture.json` is the pre-close motion log. `motion-seal.json` separately
binds the finalized 252-frame, 27,407,772-byte AVI after MovieWriter close and
validates its RIFF/AVI/MJPG container. `capture-override.cfg` is evidence-local;
the repository root and exported package must not contain `override.cfg`.

## Immutable capture and acceptance boundary

The capture payload predates external review and is intentionally immutable.
`capture-manifest.json`, `motion-capture.json`, `motion-seal.json`, and attached
node metadata retain `pending_independent_review`, `recognition_accepted:
false`, and capture-time `6/213`. Those fields prove the harness did not
self-grade. They are superseded for current acceptance only by the separately
authored sealed review receipt and the coordinated exact-current catalog and
runtime registry at `7/213`; the capture bytes must never be rewritten to mimic
post-review state.

The accepted visual claim is bounded to the observed long WSW public side: a
broad dark upper opening register with pale frames/piers, a mostly solid lower
field, and continuous green parapet/eave/canopy hierarchy with restrained rust
posts and sparse service leaves. Counts, cadence, dimensions, canopy endpoints,
minor openings, and hidden sides are production inference. Address, tenant,
signage, interiors, operability, exact as-built fidelity, whole-building
receiver completeness, and game distinctiveness are not claimed. No source
photographs or URLs ship in runtime.

## Reproduction

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --audio-driver Dummy --script game/tests/headless_d1_b201_live_attachment_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --audio-driver Dummy --script game/tests/headless_d1_b201_live_attachment_package_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --audio-driver Dummy --script game/tests/headless_d1_b201_live_attachment_evidence_contract.gd
```

For a mounted export, run the compiled package contract from an outside-project
working directory with the same absolute PCK path supplied to `--main-pack` and
`--mounted-b201-pck`, plus its independently computed SHA-256 in
`--mounted-b201-pck-sha256`. The contract rejects source-project fallback,
missing private-root exclusions, any root override, wrong PCK identity,
unloadable remaps, version/count drift, closure drift, or topology/ownership
drift. Exact evidence and source identities are in `CHECKSUMS.sha256`.
