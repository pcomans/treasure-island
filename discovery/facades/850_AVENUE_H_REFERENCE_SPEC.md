# 850 Avenue H facade reference specification

Checked: **2026-08-29**  
Target: **unnamed `w34313546` / `building:w34313546:wall`**  
Mode: **research and implementation handoff only**

## Verdict

The frozen address is exact, but official views are container-obscured and carry different displayed labels; spatial identity confidence is **medium**. Only a conservative tan field, teal roof-edge swatch and provisional paired-high-window study are defensible. Exact placement and a unique elevation are blocked by occlusion, identity reconciliation and unresolved 25-run topology.

## Exact receiver contract

| Item | Exact value |
|---|---|
| Source | unnamed 850 Avenue H; way `34313546`, v5, `2018-01-22T18:55:35Z`; `building=yes`, levels `1`, height `4 m`, `source=Yahoo`; no use/name |
| IDs | `building:w34313546`; wall `building:w34313546:wall`; roof `building:w34313546:roof` |
| Chunk/path | `x_0__z_-2`; `WorldRoot/PlayableWorld/Buildings/x_0__z_-2__building_w34313546_wall/building_w34313546_wall` |
| Meters | base/top `3.247 / 7.247`; lowest `2.870`; area `2512.346 m²`; serialized/visible `237.593 / 237.592 m` |
| Mesh | wall `25` runs, `100v/50tri`; roof `13v/11tri`; no shared parts |
| Groups | ENE `62.7° 3/22.347`, `62.8° 3/17.173`; SSE `151.2° 2/18.510`, `152.7° 2/38.122`, `152.8° 2/19.210`; SSW `194.1° 2/14.406`; WSW `244.4° 2/14.700`; WNW `286.0° 2/21.827`; NNW `332.8° 3/22.830`, `332.9° 4/48.466` m |
| Roles | wall `plaster_grey_04`, opaque `world_solid`, sole spray receiver; roof `bitumen`, opaque collider/non-spray |

U restarts per run and cannot phase architecture.

## Provenance and coverage

| ID | Exact official source | Coverage / limit |
|---|---|---|
| `850H-SV01` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8271144,-122.369789&heading=240&pitch=0&fov=75); pano `U1HtZQlUKomn07I4TT93ug`; actual `37.8271222,-122.3698007`; **Sep 2025**; southwest `240°` | east/end; exposed part appears one-storey; containers obscure much of target |
| `850H-SV02` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8273062,-122.3701219&heading=205&pitch=0&fov=75); pano `QO4Mk2OE0ky1D7lGPsSciQ`; actual `37.8273120,-122.3701921`; **Mar 2025**; south-southwest `205°` | north-side context; target largely hidden |
| `850H-EX01` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8268578,-122.3710464&heading=78&pitch=0&fov=75) | no official coverage; contributor imagery excluded and supports nothing |

Long sides, south side, entrances and most endpoints are unobserved. No imagery is stored.

## Facts, production inference and unknowns

Observed on exposed end: tan/beige smooth or lightly textured field; two paired high windows with pale frames and dark mesh/opaque coverings; a flush plain door at left; teal roof edge; no canopy. A large pale repair patch is condition-specific and excluded. Window ownership/glazing is not fully resolved.

Reversible estimates: tan reflectance `35–55%`, roughness `0.70–0.90`; teal `10–25%`, roughness `0.55–0.78`; paired opening group `1.2–2.4 m` wide and `0.4–0.8 m` high, **low confidence**. Exact substrate, dimensions, window function, door state, repetition, side ownership and identity/address alignment remain unknown.

## Output and seam plan

| Output | Status / smallest-cell rationale |
|---|---|
| `homogeneous_material_tile` | **reference-ready** for conservative tan and teal swatches only |
| `architectural_pattern_tile` | **blocked**; no repeat proven |
| `module_atlas` | **provisional reference-ready, placement-blocked** for one complete high-window pair; door is not a reusable module |
| `unique_elevation` | **blocked** by identity/occlusion/endpoints |

Legal seams: uninterrupted tan field and outside a complete provisional window pair. Forbidden: inside pair, door, repair patch, roof edge, corners, top/foundation and U resets.

## Godot BOM

| ID | Planned role |
|---|---|
| `MAT-TAN`, `MAT-TEAL` | `res://game/resources/materials/world/850_avenue_h/`; neutral PBR swatches |
| `ATLAS-HIGH-PAIR` | `res://game/resources/textures/buildings/850_avenue_h/850_avenue_h_high_pair`; provisional complete RGBA module/maps |
| `MOD-END` | `res://game/scenes/world/facades/850_avenue_h/850_avenue_h_modules.tscn`; shallow noncolliding prototype |
| `LAYOUT` | `res://game/resources/facades/850_avenue_h_layout.json`; blocked |
| `ATTACH` | `res://game/scenes/world/facades/850_avenue_h/850_avenue_h_facade.tscn`; blocked visual child |

## Boundary and invariant example

```text
before: building:w34313546:wall is the 4 m/one-level, 25-run spray receiver.
after:  the same massing, silhouette, roof, footprint, topology, foundation,
        physics, spray, terrain and source/generated contracts remain; only
        conservative unattached material/module prototypes are available.
```

No structural openings, collision, navigation, spray eligibility or story/massing change is allowed.

## Acceptance gates

- [ ] Reviewer confirms both official dates/view directions and medium identity confidence.
- [ ] Only exposed-end facts are authored; labels, obscured sides and window function are not invented.
- [ ] Repair patch and contributor imagery are excluded.
- [ ] IDs/path/chunk, `4 m / 1`, `25 / 237.592 m`, `50/11` triangle counts remain.
- [ ] Pair stays whole; no layout until exact endpoint reconciliation.
- [ ] Materials contain no baked light/reflection/displacement; visual child has no physics/spray role.

```yaml
schema_version: codex.building-texture-research/1
target: {id: w34313546, receiver: 'building:w34313546:wall', identity_confidence: medium}
sources: [L01, 850H-SV01, 850H-SV02, 850H-EX01]
observed_regions: [partial_east_end, occluded_north_context]
unobserved_regions: [long_sides, south_side, entrances, exact_endpoints]
outputs: {homogeneous_material_tile: reference_ready, architectural_pattern_tile: blocked, module_atlas: provisional_reference_ready_placement_blocked, unique_elevation: blocked}
legal_seams: [homogeneous_tan_field, complete_high_window_pair]
forbidden_seams: [inside_window_pair, door, repair_patch, roof_edge, corner, receiver_top, foundation, generated_U_reset]
research_verdict: {ready_for_generation: true, ready_subset: [tan_teal_swatches, provisional_high_pair], ready_for_attachment: false}
```

## Final status

- Conservative prototype subset: **implementation-ready**.
- Placement/elevation: **blocked by medium identity, occlusion and run mapping**.
