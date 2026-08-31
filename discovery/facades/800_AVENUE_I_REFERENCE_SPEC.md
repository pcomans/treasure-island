# 800 Avenue I facade reference specification

Checked: **2026-08-29**  
Target: **unnamed `w34313545` / `building:w34313545:wall`**  
Mode: **research and implementation handoff only**

## Receiver-first verdict

The frozen source identifies the exact address, and two September 2025 official views establish the large footprint as Island Park Storage/self-storage with high confidence. The long public elevation supports a complete upper-bay/material/sign-region vocabulary. Exact bay/run placement, service-yard chains, canopy geometry and target-specific sign policy remain blocked.

## Exact identity and receiver

| Item | Exact local evidence |
|---|---|
| Source | way `34313545`, v7, `2022-03-25T17:56:41Z`; `building=yes`, levels `1`, height `5 m`; no name/use |
| IDs | logical `building:w34313545`; wall `building:w34313545:wall`; roof `building:w34313545:roof` |
| Chunk/path | `x_0__z_-2`; `WorldRoot/PlayableWorld/Buildings/x_0__z_-2__building_w34313545_wall/building_w34313545_wall` |
| Meters | base/top `3.402 / 8.402`; lowest foundation vertex `3.064`; area `8887.470 m²`; serialized/visible perimeter `410.745 / 410.748 m` |
| Mesh | wall `40` runs, `160v/80tri`; roof `14v/12tri`; standalone, no shared parts |
| Normal groups | ENE `61.8° 14/115.524 m`; SSE `151.8° 9/89.843`; WSW `241.8° 10/115.513`; NNW `331.7° 1/2.677`, `331.8° 6/87.192` |
| Materials/roles | wall `building_wall -> plaster_grey_04`, opaque `world_solid`, sole spray receiver; roof `building_roof -> bitumen`, opaque collider/non-spray |

U restarts per run; V is world y/10. Neither encodes facade cadence.

## Provenance and observed coverage

| ID | Exact official source | Coverage / limit |
|---|---|---|
| `800I-SV01` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.826317,-122.369251&heading=263&pitch=0&fov=75); pano `DpzvxoYoYw9a0HnRRm8nnA`; actual `37.8263185,-122.3692567`; **September 2025**; west `263°` | east/service side; containers/screens obscure most inner/service-yard perimeter |
| `800I-SV02` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.825489,-122.3701307&heading=27&pitch=0&fov=75); pano `JUHhZAv7E6uzbk6wiFsTog`; actual `37.8254958,-122.3701556`; **September 2025**; northeast `27°` | long southwest/south-facing public elevation; `800` marker and storage signage |

North/northwest chains, service-yard interior and exact endpoints are unobserved. Google imagery was viewed transiently; no pixels or screenshots are stored.

## Facts, material/scale inference and module grammar

Observed: one tall commercial/storage storey compatible with the frozen `5 m / 1`; smooth light warm-gray/cream field; bright saturated-green roof/parapet line, upper-window register line and canopy fascia; broad dark upper windows in pale frames separated by substantial light piers; mostly solid lower wall with sparse doors/openings and target-specific signs. Muted rust-red/brown canopy posts, canopy depth, stepped parapet and yard geometry are geometry/prop ownership. Containers are excluded.

Reversible production inference: light field reflectance `55–75%`, roughness `0.70–0.90`; green reflectance `18–35%`, roughness `0.50–0.72`; dark glazing roughness `0.12–0.28`; rust posts `12–25%`, roughness `0.65–0.85`. Candidate upper bay width `3–6 m`, low confidence; exact bay period/substrate/lower-door schedule are unknown.

Complete modules: `800I-UPPER-BAY` contains one full upper window, pale frame, both light piers and green register lines; `800I-SOLID-LOWER` is uninterrupted lower field; each `800I-SIGN-REGION` is a unique nonrepeating region after text/current-use policy and exact placement are resolved. Canopy/posts/parapet steps/containers are not wall modules.

| Output | Classification / smallest-repeat rationale |
|---|---|
| `homogeneous_material_tile` | **reference-ready** for light wall and green trim fields; `1–2 m` neutral PBR test span |
| `architectural_pattern_tile` | **blocked**; exact bay period and opposite boundary products are not proven |
| `module_atlas` | **reference-ready, placement-blocked** for complete upper bay and solid-lower modules |
| `unique_elevation` | **sign-region/public-sequence reference-ready, placement-blocked** by sign policy, canopy/run reconciliation and unobserved chains |

Legal seams: uninterrupted light field or verified full upper-bay outer boundary. Forbidden: generated U reset, window, green register line, canopy/fascia/post, sign, door, parapet step, corner, utility opening, screen/container, top/foundation. Never phase public bays around the service side.

## Reserved Godot BOM

| ID | Planned path / status |
|---|---|
| `MAT-LIGHT`, `MAT-GREEN`, `MAT-GLASS` | `res://game/resources/materials/world/800_avenue_i/` — reference-ready PBR fields |
| `ATLAS` | `res://game/resources/textures/buildings/800_avenue_i/800_avenue_i_modules` — complete upper-bay/solid-lower atlas |
| `MOD` | `res://game/scenes/world/facades/800_avenue_i/800_avenue_i_modules.tscn` — shallow noncolliding render modules |
| `LAYOUT` | `res://game/resources/facades/800_avenue_i_layout.json` — blocked pending ordered endpoint/canopy/sign reconciliation |
| `ATTACH` | `res://game/scenes/world/facades/800_avenue_i/800_avenue_i_facade.tscn` — later noncolliding visual child; blocked |

## Geometry boundary and before -> after

```text
before: building:w34313545:wall is the 5 m/one-level, 40-run opaque spray receiver.
after:  that exact receiver, height/story, silhouette, roof, footprint, structural
        openings, topology, foundation, terrain, collision, navigation, spray,
        OSM and generated contracts remain; only evidence-backed visuals may attach.
```

## Acceptance gates and blockers

- [ ] Every visual claim cites exact official URL/pano/date/viewpoint/direction and observed side.
- [ ] IDs/path/chunk, `5 m / 1`, `40 / 410.748 m`, wall `80` and roof `12` triangles remain exact.
- [ ] Storage identity/signs are sourced only to the stated current public elevation; no legacy-grid facade is inherited.
- [ ] Ordered source endpoints, not normals/U resets, control placement.
- [ ] Complete upper bays survive atlas edges; canopy/posts/parapet/containers remain geometry/props.
- [ ] North/northwest/service-yard chains retain fallback; sign regions remain unique.
- [ ] Visual child has no physics/navigation/spray role and changes no massing/source/generated data.

Primary blocker: reconciliation of the public bays, canopy/sign regions and unobserved service chains to the large 40-run footprint.

```yaml
schema_version: codex.building-texture-research/1
target: {id: w34313545, receiver: 'building:w34313545:wall', identity_confidence: high}
sources: [L01, 800I-SV01, 800I-SV02]
observed_regions: [long_public_elevation, partial_east_service_side]
unobserved_regions: [north_northwest_chains, inner_service_yard, exact_endpoints]
outputs: {homogeneous_material_tile: reference_ready, architectural_pattern_tile: blocked, module_atlas: reference_ready_placement_blocked, unique_elevation: sign_and_sequence_reference_ready_placement_blocked}
smallest_cell: {status: complete_module_only, modules: [800I-UPPER-BAY, 800I-SOLID-LOWER, 800I-SIGN-REGION]}
legal_seams: [uninterrupted_light_field, verified_complete_upper_bay_boundary]
forbidden_seams: [generated_U_reset, window, green_register, canopy, post, sign, door, parapet_step, corner, utility_opening, screen, container]
research_verdict: {ready_for_generation: true, ready_subset: [materials, upper_bay_atlas, sign_region_plan], ready_for_attachment: false, blockers: [ordered_40_run_mapping_missing, canopy_geometry_reconciliation, sign_policy, unobserved_service_chains]}
```

## Final status

- Materials/public-side module prototypes: **implementation-ready**.
- Exact placement/live attachment: **blocked by run, canopy/sign and service-chain reconciliation**.
