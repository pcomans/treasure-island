# Treasure Island Administration Building 1 standalone facade prototype handoff

Status: **native capture complete; ready for independent standalone art review; not self-accepted**  
Date: **2026-08-30**  
Source / receiver: **`r16681702` / `building:r16681702:wall`**  
Identity: **Treasure Island Administration Building 1 / Treasure Island Museum**, the owner-prioritized 1939 World's Fair Pan Am / Building 1 target

## Bounded verdict

The approved local `B1-SV01..03` observation package supports one restrained warm-ivory homogeneous field and six distinct complete shallow module families for the observed public outer facade. This round created exactly those seven standalone outputs and no receiver layout. It performed one initial implementation and one native capture pass; no correction was made.

The six exemplars are separated on one `40 x 10 m` proof host only so their family, scale and shallow relief can be reviewed together. That arrangement is not a proposed elevation, real order, count, cadence, sequence, or placement. Exact outer-run endpoint mapping remains blocked.

## Classification and topology

| ID | Asset kind | Nominal production-inference bounds | Uncertainty / evidence bracket | Meshes / surfaces / triangles |
|---|---|---:|---:|---:|
| `B1-MAT-IVORY` | `homogeneous_material_tile` | `1.10 / 0.32 m` procedural scales; `40 x 10 m` proof | finish scale `0.5..1.8 m`, unsurveyed | `1 / 1 / 12` proof mesh |
| `B1-WING-W` | `module_atlas` | `1.70 x 1.70 m` | observed estimate `1.2..2.0 x 1.3..2.1 m` | `7 / 7 / 84` |
| `B1-CENTRAL-W` | `module_atlas` | `1.45 x 4.60 m` | `0.8..1.8 x 3.0..5.5 m` | `9 / 9 / 108` |
| `B1-PAV-W` | `module_atlas` | `5.40 x 10.00 m` | observed estimate `4..7 x 8..14 m` | `13 / 13 / 156` |
| `B1-BASE-O` | `module_atlas` | `1.25 x 0.90 m` | `0.6..1.4 x 0.45..1.2 m` | `6 / 6 / 72` |
| `B1-DOOR-BLUE` | `module_atlas` | `1.35 x 2.75 m` | `0.9..1.7 x 2.0..3.1 m` | `5 / 5 / 60` |
| `B1-BAND` | `module_atlas` | `4.20 x 0.38 m` | `2..8 x 0.2..0.5 m` | `3 / 3 / 36` |
| **Total** | `1 field + 6 modules` | — | all reversible production inference | **`44 / 44 / 528`** |

The module-only subtotal is `43 meshes / 43 surfaces / 516 triangles`. Every module is a complete motif, not a seamless whole-wall tile. Every module owns zero host-field/backing meshes, collision, navigation, spray, or receiver state. Opaque blue-grey faces avoid unsupported transparency, emission, reflections, interiors, and window-versus-vent claims.

The warm-ivory field reuses the project-native aperiodic metre-space shader (`324ba33a...`). It contains no facade-scale layout, baked lighting, unique stain, ground/roof line, or finite architectural period. Its material record is `572c3165...`; component materials are light trim `6e543d57...`, muted rose base band `dd0ad6a9...`, opaque blue-grey `41c1c31d...`, and opaque blue door `6554b282...`.

## Receiver and evidence boundary

The current generated receiver is exactly `110` wall runs / `414.381 m`: outer `0..99` / `389.121 m`, then inner `100..109` / `25.260 m`; height `20 m`, base/top `6.281 / 26.281 m`, wall `440 vertices / 220 triangles`, roof `82 / 84`. These facts constrain future work but authorize no placement here.

Reference observations support family eligibility only across public west-facing outer wing, central, pavilion, base, and band regions. Exact semantic mapping from those regions to outer ordered runs is absent. Cardinal direction alone cannot distinguish the public outer ring from inner-ring walls. The separate observation tower `w1222720021` is excluded.

Authoritative local pins:

- Reference spec: `79fe7b7cc49ea5e40a8611313defacb07ec23fb1a1a711822e0378b8cc32ac5a`
- Observation ledger: `aee175db92ec39b0ae4f0e2adfe286f297c93d303fee4249cb6f03c25ae12b2a`
- Reference index: `b634412b0fa41cb0eada84c81f44113b30ff579edf0abddfceefbae61883eed8`
- Generated chunk: `dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce`

No Street View pixels were downloaded, copied, stored, uploaded, or embedded. No browser, external service, new resource, install, account, or image-generation call was used.

## Deterministic assets

| File | SHA-256 |
|---|---|
| `game/resources/facades/building_1_standalone_prototypes.json` | `2014040edb3985be4aaae437749063474aacaedc0534b6d54e69b7dfd92612cc` |
| `game/scripts/world/facades/building_1_standalone_prototypes.gd` | `cf18bfcfa40c7770d92aad569cba05da7ac85fe0fc89c0fd8cba6167ef62fb1f` |
| `game/scenes/world/facades/building_1/building_1_standalone_prototype_set.tscn` | `1d205d4d6e176d4ed1e82746d1f1f8c4c2547910b1a71f87a213d9ada14967ef` |
| `game/tests/headless_building_1_standalone_prototype_contract.gd` | `21c11969bb132d6cfcd5657dff688d211d6493ebeeb2a7d78eca047f0ce998f3` |
| `game/tests/building_1_standalone_prototype_capture.gd` | `8f82d5d4f761e9eacadb8f865739692e9fd1af017b8155e734f3a1395a562339` |

The headless contract instantiates the scene twice and compares exact geometry signatures. It also pins the source artifacts, shared shader, generated world, world builder, canonical inventory, accepted-material helper, prior Batch 06 registry, and every interrupted `r133351` file.

## Native evidence

Directory: `evidence/first-playable/treasure-island-building-1-standalone-prototypes-2026-08-30/`

Renderer: Godot `4.7.2-stable (official)`, native macOS, Forward+, Metal, `Apple M1 Pro (Apple7)`, `1440x900`.

| Image | Role | SHA-256 |
|---|---|---|
| `01-warm-ivory-neutral-close.png` | field close | `7125865fadb5fbf7da5e465a631c6205bef931dc4876cbccbe0190d0522c84cd` |
| `02-warm-ivory-macro-40m.png` | `40 m` macro behavior | `657056dc0887cc93a84c7c8edbfab9de055c3454423075060b672d9832f9b907` |
| `03-wing-window-close.png` | complete `B1-WING-W` | `7a0dd27e93fbe3fbfe0b6944bb86c33877d06386cccafb2bc5693beb9b7e0ee9` |
| `04-central-window-close.png` | complete `B1-CENTRAL-W` | `1b874f14cc3d091cb4a8c92d546cc92f2401956e0412f5d24919423b9854719a` |
| `05-pavilion-window-close.png` | complete `B1-PAV-W` | `b949aa179ad330456e8b4ffa80f2f097952983af3fc1ef5a27a231d86a5125ec` |
| `06-base-opening-close.png` | complete `B1-BASE-O` | `7e1316cb32ffa8af9918eea32bf8d14f17839251419c6a38b97e720e8bdbc623` |
| `07-blue-door-close.png` | complete `B1-DOOR-BLUE` | `98df9d98b0fe8f84c7ab67ab84801da68015014e4011a64b56dd997eeba4217a` |
| `08-band-oblique-close.png` | complete `B1-BAND`, terminal/depth view | `cbe6fa4dc797f1293faf733d04e237e35bd7bcf5c93331bbabcd307d071883bf` |
| `09-all-modules-oblique.png` | all six / shallow depth | `6246ec0e5fa0ad55e7ebda7f7ee2f459b4ee518933a71e460f71b60aa4c2996f` |
| `10-ordinary-distance-aggregate.png` | ordinary-distance readability | `5a89c000dc9417178bd880d245deadf12eb730239affa379404233fee1455ec9` |
| `11-changed-light-aggregate.png` | changed light / material families | `f90e2dcf769ddf0f47ff8ac09b0254b1eac8d4c51b05cb20cfb1ba981dd6000f` |

Manifest: `db791549...`; runtime isolation: `4de6962d...`; visual verification: `6985c508...`; checksum ledger: `d1e7ab89...`; evidence README: `357ebcbd...`.

All images were inspected after capture. Every named target is complete and readable. The neutral field close includes the separate band low in frame; several close views retain neighboring exemplar margins; the changed-light aggregate is intentionally darker. These are documented framing/exposure limitations for the independent reviewer, not corrected or concealed. The aggregate lineup is explicitly not an elevation.

## Focused verification

- `headless_building_1_standalone_prototype_contract.gd`: **PASS**, deterministic `44 / 44 / 528`, correct kinds, material/channel bounds, complete motifs, zero backing/collision/nav/spray, runtime/generated/source/r133 pins.
- `building_1_standalone_prototype_capture.gd`: **PASS**, eleven native Forward+/Metal images.
- `headless_building_1_standalone_capture_evidence_contract.gd`: **PASS**, image/manifest/checksum/inspection/isolation coherence and no self-acceptance.
- Checksum verification: **PASS**, all `19` listed image/evidence/asset records.
- `validate_generated_world.gd`: **PASS**, `735` playable + `4` context rows across `38` chunks; generated contract unchanged.
- `headless_isle_house_facade_contract.gd`: **PASS**, explicitly pins Museum with no facade change while retaining all accepted Isle House scope.
- `full_runtime_integration.gd`: **PASS**, `729` generated meshes / `739` generated surfaces / `48,389` generated triangles and `924 / 934 / 50,729` reported loaded topology; gameplay and cleanup passed.

Headless Godot emits the known sandbox log-file and macOS CA-certificate diagnostics; all listed contracts exit `0` and emit explicit `PASS` lines.

## Explicit blocked claims and stop condition

- Exact runs/endpoints, anchor/coordinates, count, cadence, sequence, cross-side transfer, or complete outer schedule.
- Main entrance/canopy, emblems/signs, east/rear outer facade, inner ring, separate tower, or private/courtyard conditions.
- Surveyed dimensions, glazing subdivisions, true transparency/reflection/interiors, measured material/color values, or as-built depth.
- Receiver massing, lower-wing/taller-pavilion profile, roofline, structural recesses, exact-receiver acceptance, complete elevation, or whole-building resemblance.

This round stops here. It is ready for a separate independent review of the one homogeneous field and each of the six complete standalone modules. It is not ready for exact-receiver calibration or live integration until that review is complete and exact outer-run evidence is separately established.
