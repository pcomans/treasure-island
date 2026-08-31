# Treasure Island Administration Building 1 — detached exact-receiver calibration handoff

Status: `ready_for_independent_detached_exact_receiver_art_review_not_self_accepted`

Date: 2026-08-30  
Executor: `/root/w34313515_executor`  
Source: `r16681702`  
Exact receiver: `building:r16681702:wall`

## Reviewable scope

| Scope | Exact receiver region | Deterministic study coordinate | Evidence status | Explicitly not claimed |
|---|---|---|---|---|
| `B1-MAT-IVORY` homogeneous field | outer runs `21..51`, 31 ordered runs | cumulative chain origin `0.0 m` at run 21 start | exact generated geometry plus reference-derived production-inference material scale | surveyed color/scale, other runs/sides, complete elevation, whole building |
| `FIT-CENTRAL-W-R36` complete module | representative outer public-curve run 36 | midpoint `2.008051045 m`; center `10.0 m` above interpolated base; safe along-run domain `0.9..3.11610209 m` | production-inference scale/contact study inside mapped CENTRAL-eligible region | actual anchor, real placement, count, cadence, sequence, surveyed dimensions/coordinates |
| `FIT-PAV-W-R06` complete module | representative outer north-end candidate run 6 | midpoint `5.511163693 m`; center `10.0 m` above interpolated base; safe along-run domain `3.5..7.522327386 m` | production-inference scale/contact study inside mapped PAV-eligible region | actual anchor, real placement, count, cadence, sequence, surveyed dimensions/coordinates |

The CENTRAL and PAV studies are not lifecycle placement records. Their midpoint positions were selected mechanically to test containment/contact and must not be copied into a live adapter without a later exact-placement authorization.

## Exact field contract

- Horizontal length: `85.939934 m` from the source JSON mesh in double precision.
- Generated triangle surface area: `1740.731069 m²`.
- Generated heights across the scope: `20.0..21.139 m` because the receiver follows terrain at its lower edge and shares top elevation `26.281 m`.
- UV convention: `UV.x = cumulative ordered horizontal chain metres from run 21 start`; `UV.y = source world Y metres`.
- Internal joins: 30; maximum endpoint delta `0.0 m`; maximum chain-phase delta `0.0 m`.
- Material parameters preserved from accepted standalone production inference: primary `1.10 m`, secondary `0.32 m`, roughness `0.82`, relief `0.008`.
- Overlay offset: `0.018 m`, detached only.

Godot's float32 rebuild resolves `85.939965278 m / 1740.731683135 m²`; the helper accepts only sub-millimetre representation tolerance against the double-precision registry and the exact registry values remain authoritative.

## Module transforms and topology

- CENTRAL origin: `[0.881625, 16.281, 749.694364]`; tangent XZ `[-0.144419, 0.989517]`; outward normal XZ `[-0.989586, -0.14394]`.
- PAV origin: `[-56.492276, 14.4535, 709.845098]`; tangent XZ `[0.460338, 0.887744]`; outward normal XZ `[-0.887936, 0.459967]`.
- Field: 1 mesh / 1 surface / 124 vertices / 62 triangles.
- CENTRAL: 9 meshes / 9 surfaces / 108 triangles.
- PAV: 13 meshes / 13 surfaces / 156 triangles.
- Total detached overlay: 23 meshes / 23 surfaces / 326 triangles.
- Module-owned field/backing, collision, navigation and spray: all zero.

`B1-WING-W`, `B1-BASE-O`, `B1-DOOR-BLUE` and `B1-BAND` are not included. Their standalone bytes are checksum-locked only.

## Native evidence

Evidence root: `evidence/first-playable/treasure-island-building-1-exact-receiver-calibration-2026-08-30/`

- Renderer: Godot `4.7.2`, native macOS, Forward+, Metal, Apple M1 Pro.
- 15 images at 1440×900.
- Views 01–05 visually sample joins `21/22`, `30/31`, `38/39`, `45/46`, and `50/51`; the registry/helper provide complete proof for all 30 joins.
- View 06 shows the full `85.939934 m` macro span.
- Views 07–12 show complete CENTRAL/PAV close, oblique and ordinary-distance behavior.
- View 13 shows both bounded study regions in whole-building context without a whole-building verdict.
- Views 14–15 show changed light for CENTRAL/ivory and PAV/north-end context.
- Pale-field contrast is weak in join views 02 and 04; this is recorded as a limitation, not concealed with a recapture or art change.

Evidence ledger SHA-256: `1578935f859522342396c98feb3116350ff8ae5c43cbddefea278f0b6440ce65`.

## Isolation and checks

Passing:

- Registry regeneration: 31 runs / `85.939934 m` / `1740.731069 m²`; two fit studies; zero placements.
- Exact calibration contract: 23/23/326 topology; deterministic repeat build; 30 zero-delta joins; no backing/collision/navigation/spray/runtime ownership.
- Native evidence contract: all 15 PNG hashes, dimensions, luminance, renderer metadata, transforms, truth boundaries and protected hashes sealed.
- Run ownership: 110 runs; outer main/sliver 97/3; inner 10; partial gate 3 authorized families / 4 blocked; zero placements.
- Accepted-material runtime: 729 records / 924 meshes / 934 surfaces / 50,729 triangles.
- Generated-world validation: 735 playable + 4 context rows over 38 chunks; content SHA `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`.
- Full runtime: 38 chunks / 729 records / 924 meshes / 934 surfaces / 50,729 triangles / 466 bodies and shapes; gameplay interactions and cleanup passed.

The earlier standalone-only contract now intentionally fails its lifecycle sentinel because it asserts that no Building 1 calibration registry may exist. Its asset, material, source, runtime, generated, inventory and interrupted-r133351 hash pins all pass before that sentinel. The current standalone bytes remain unchanged; the exact-calibration and evidence contracts are the applicable lifecycle contracts for this round.

## Independent-review decisions

The reviewer should return separate verdicts for:

1. `B1-MAT-IVORY` exact scale/phase on runs 21..51.
2. `B1-CENTRAL-W` representative run-36 contact/scale fitness only.
3. `B1-PAV-W` representative run-6 contact/scale fitness only.
4. Aggregate evidence sufficiency without whole-building acceptance.

If independently accepted, the maximum lifecycle scope that may advance is one exact field proposal for one receiver / one scope / 31 runs / `85.939934 m` / `1740.731069 m²`, plus two accepted detached fit-study verdicts. The modules cannot advance to live placement counts because actual anchors remain deliberately unauthorized. Live integration, placement selection, lifecycle promotion and whole-building acceptance require separate bounded rounds.
