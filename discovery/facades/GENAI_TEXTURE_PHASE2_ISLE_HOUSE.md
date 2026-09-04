# GenAI texture Phase 2 — Isle House low receiver trial

Date: **2026-09-04**

Status: **bounded technical proof complete; visual verdict pending independent bar-raiser review; not connected to live world construction**

## Outcome

The selected muted brown-red brick from the isolated v1 material lab remains usable on a long, real facade receiver at the requested starting scale. It now appears on the standalone Isle House low prototype's mapped public-run background fields at a `2.5 m` cell, `Color(0.70, 0.66, 0.62, 1)`, and scalar roughness `0.86`. Fixed front/oblique A/B captures and nine native Forward+/Metal motion samples expose the long-field cadence and module contrast.

Executor inspection found no obvious broken course, run-boundary phase reset, distracting seam, shimmer, moire, or foreign object at the tested distances. A mild source-cell cadence remains discoverable when deliberately searching for it, as already recorded in v1. That is below the owner's rejection threshold for this pilot. This is not art acceptance; the bar-raiser owns the visual verdict.

No new image was generated in Phase 2. The exact generation prompt, first source path, rights boundary, rejected-candidate history, and v1 repeat/lab evidence remain in `discovery/facades/GENAI_TEXTURE_PILOT_V1.md`. The selected brick source hash is unchanged:

`0abbb429066966c1cfc1e0209a2a454c41dae73743fc119ffdf7cd82ee3ef35d`

## Metre-authored UV adapter

Reusable implementation:

`res://game/scripts/world/facades/facade_meter_uv_adapter.gd`

Public API:

- `plan_side_chain(runs, ordered_run_indices, expected_side_id, endpoint_tolerance_m = 0.002)` validates a unique, connected, same-side ordered chain and returns one entry per run with `u_start_m`, `u_end_m`, measured XZ length, and explicit seam policy.
- `entry_for_run(plan, run_index)` resolves an immutable plan entry without receiver-specific assumptions.
- `vertical_quad_uvs(corners, u_start_m)` emits UVs for bottom-start, bottom-end, top-end, top-start corners.
- `contract_metadata()` exposes the stable version/rules for runtime metadata and evidence.

Rules:

- U is cumulative XZ distance in metres within one configured side chain.
- U continues through every ordered intra-side corner.
- U resets to `0` only at the first run of each explicit side chain.
- V is the unmodified world-space Y coordinate in metres, including non-flat foundation endpoints.
- Duplicate indices, missing runs, side mismatch, non-positive or drifted lengths, disconnected corners, empty chains, and invalid tolerance fail closed.
- The helper contains no Isle House identifiers and is reusable by later facade receivers.

For the Isle House low prototype this produces:

- `LOW-WSW-AVENUE-OF-THE-PALMS`: `51.6984152793884 m` continuous U over runs `0..4`, then no continuation into another side.
- `LOW-ENE-GARDEN-WALK`: a fresh `U=0` and `49.7970167398453 m` continuous U over runs `5..9`.
- protected runs `10..12`: no prototype field and therefore no prototype UVs.

## Receiver application boundary

Promoted package resources:

- `res://game/resources/textures/world/facade_shared_v1/muted_brown_red_brick_albedo_v1.png`
- `res://game/resources/materials/world/facade_shared_v1/muted_brown_red_brick_v1.tres`

The promoted PNG is byte-identical to the approved v1 pilot brick. It uses repeat, mipmaps, anisotropic filtering, albedo only, metallic `0`, and scalar roughness `0.86`. No normal, roughness, AO, height, or displacement bitmap was fabricated.

Only `ObservedPublicLiveWorkBrickFields_Runs_0_9` uses the promoted material. The existing narrow module-pier BoxMesh batch retains its scalar Isle House brick material: normalized primitive UVs do not preserve physical metres after per-instance scaling, so applying the bitmap there would violate the metre-scale contract. A future module-texture pass must supply metre-aware module meshes or a reviewed projection shader. This limitation does not change module geometry.

The prototype remains:

- `10` field quads / `20` field triangles;
- `8` complete module nodes / `152` boxes / `1,824` module triangles;
- `1,844` total visual triangles;
- zero collision, navigation, and spray ownership;
- no attachment in `world_chunk_builder.gd`, the facade catalog, registry, or loader;
- no change to B1, B3, high Isle House, generated source records, or existing evidence.

## Native evidence

Root:

`res://evidence/first-playable/isle-house-low-genai-brick-phase2-2026-09-04/`

- `images/01-flat-front.png` and `images/02-generated-front.png`: same-camera flat-control/generated front A/B.
- `images/03-flat-oblique.png` and `images/04-generated-oblique.png`: same-camera flat-control/generated oblique A/B.
- `images/motion/05-generated-walk-00.png` through `05-generated-walk-08.png`: nine native frames on a path parallel to the WSW public facade, `1.25 m` steps, `16 m` outward distance.
- `capture-manifest.json`: exact poses, material/texture/helper hashes, package facts, output hashes, renderer, topology, and nonclaims.

The final capture reproduced all thirteen PNG hashes across consecutive runs. It ran with Godot `4.7.2`, the macOS display driver, Forward+/Metal, Apple M2, at `1440 × 900`. The motion set is a deterministic native camera-path diagnostic, not a physics/player traversal and not live-world acceptance.

## Package audit

The existing `all_resources` preset bundled every isolated pilot resource. The baseline PCK proved that both v1 albedos and both v1 materials were loadable, including unused stucco. Phase 2 keeps every source artifact on disk but adds explicit exclusions for both `genai_pilot_v1` resource directories, then promotes only the accepted brick into `facade_shared_v1`.

| PCK | Bytes | SHA-256 |
|---|---:|---|
| Before: both isolated pilot families bundled | `62,134,828` | `56f3543720030633ae6688a1baafe086765e8be4bd39186b093d7a54b07cc92a` |
| After: promoted brick only | `59,524,324` | `c84d8f3654d02eb17d7fc97907d66a6c26bc5e12a0a97753c84b3ff331f71263` |
| Delta | `-2,610,504` (`-2.490 MiB`, `-4.201%`) | — |

Measured promoted resource cost:

- source PNG: `2,704,384` bytes;
- local lossless imported `.ctex` with mipmaps: `2,711,916` bytes;
- conservative decoded RGBA8 plus full-mipmap estimate: about `8.0 MiB` renderer memory, not a measured profiler value.

A mounted-PCK test confirms the final pack can load the promoted texture, material, helper, config, scene, and factory, while none of the two pilot textures or two pilot materials exist in the mounted resource namespace. Stucco remains a source/test pilot only and does not enter the final PCK.

## Verification

Passing checks:

```text
headless_facade_meter_uv_adapter_contract.gd
headless_isle_house_low_facade_prototype_contract.gd
headless_genai_texture_phase2_package_contract.gd (source and clean mounted-PCK modes)
headless_isle_house_low_genai_brick_phase2_evidence_contract.gd
headless_scene_parse.gd
native isle_house_low_genai_brick_phase2_capture.gd
```

The integration seam for any later reviewed promotion is intentionally small: instantiate the standalone scene only after `matches_target(record)`, then call `configure(record)`. The metre-UV helper and shared material are already package-safe; attaching this prototype to the live builder remains a separate acceptance decision.

## Recommendation

Use GenAI albedo generation in production only for a small shared family library with the v1/Phase-2 gates: text-only rights boundary, exact prompt/hash log, raw repeat proof, receiver-scale A/B, metre-authored UV contract, mipmaps, motion inspection, package audit, and independent visual review. Do not use it for whole elevations or as a substitute for massing, window/door modules, entrances, signage, or silhouettes.

For this brick, do not regenerate because of mild edge phase. If the independent review rejects it, first try a reversible receiver-only cell/tint adjustment or offline edge cleanup while retaining provenance. Regenerate only for a genuine material rejection such as distracting cadence, baked lighting, objects, or unfixable scale behavior.
