# 810 Avenue D facade reference specification

Checked: **2026-08-29**  
Target: **unnamed `w96698660` / `building:w96698660:wall`**  
Mode: **research and implementation handoff only**

## Verdict

Google and the frozen source both identify 810 Avenue D with high confidence. The building is hidden by a green enclosure in March 2025; current existence is unknown. May 2011 official imagery supports a **historical front module set** and partial side vocabulary only. Current representation and exact placement remain blocked.

## Exact receiver

| Item | Exact value |
|---|---|
| Source | unnamed 810 Avenue D; way `96698660`, v4, `2018-01-22T18:56:15Z`; `building=yes`, levels `1`, height `4 m`; no name/use |
| IDs/path | `building:w96698660`; wall `building:w96698660:wall`; roof `building:w96698660:roof`; chunk `x_-1__z_-1`; `WorldRoot/PlayableWorld/Buildings/x_-1__z_-1__building_w96698660_wall/building_w96698660_wall` |
| Contract | base/top `3.298 / 7.298 m`; lowest `3.246`; area `136.896 m²`; serialized/visible `51.995 / 51.994 m` |
| Mesh/groups | wall `6` runs `24v/12tri`; roof `4v/2tri`; NNE `18.3° 2/18.656 m`; ESE `108.3° 1/7.339`; SSW `198.4° 1/18.667`; WNW `288.4° 2/7.332` |
| Roles | wall `plaster_grey_04`, opaque `world_solid`, sole spray receiver; roof `bitumen`, collider/non-spray |

## Provenance and temporal coverage

Both official panoramas use [this request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8242283,-122.3727535&heading=33&pitch=0&fov=75).

| ID | Panorama/date | Coverage |
|---|---|---|
| `810D-CURRENT` | `le1q7oLYgiyaWBAv2NBF2w`; actual `37.8242274,-122.3727145`; **Mar 2025** | green enclosure; facade invisible; current existence unknown |
| `810D-HIST` | `IYcYMdJYTtaGjJVxo7eraA`; actual `37.8241971,-122.3727396`; **May 2011** | front/southwest end and partial southeast side of low one-storey modular building |

Other sides, side-window sequence and exact endpoints are unobserved. No imagery is retained.

## Historic facts, inference and unknowns

May 2011 shows pale gray/off-white horizontal siding, dark-brown trim, two broad front windows flanking a dark-brown double door, small `810` identifier, wood-slat deck/rail, shallow light-metal gable roof with vertical seams, and partial side windows plus a utility unit. Deck/rail, roof and utility unit are geometry/props, not baked texture.

Reversible estimates: siding reflectance `65–85%`, roughness `0.62–0.85`, course `0.12–0.25 m`; brown reflectance `8–20%`, roughness `0.55–0.75`; glass roughness `0.12–0.28`; front window `1.2–2.0 m` wide, low confidence. Exact opening dimensions, side cadence, substrate, current existence and endpoint ownership remain unknown.

## Output and seams

| Output | Status |
|---|---|
| `homogeneous_material_tile` | **historical reference-ready** for siding/brown trim/light roof swatches |
| `architectural_pattern_tile` | **blocked**; no repeating period proven |
| `module_atlas` | **historical reference-ready, placement-blocked**: `810D-FRONT-WINDOW`, unique entry group (door/810/deck-rail), provisional side window, solid siding |
| `unique_elevation` | **front-only historical reference-ready, placement-blocked**; incomplete sides/current enclosure prevent whole-building output |

Legal seams: siding field and outside complete front window units. The central entry is unique/nonrepeating. Forbidden: inside openings/number/entry, deck/rail, roof seam, utility, corners, top/foundation, U reset. Never clone the front around the building.

## Godot BOM

| ID | Planned role |
|---|---|
| `MAT-SIDING`, `MAT-BROWN`, `MAT-ROOF` | `res://game/resources/materials/world/810_avenue_d/`; historic PBR fields |
| `ATLAS-HIST` | `res://game/resources/textures/buildings/810_avenue_d/810_avenue_d_historic_modules` |
| `MOD-FRONT`, `MOD-SIDE` | `res://game/scenes/world/facades/810_avenue_d/810_avenue_d_modules.tscn`; render-only prototypes; entry unique |
| `LAYOUT` | `res://game/resources/facades/810_avenue_d_layout.json`; blocked pending six-run endpoint map/current-time decision |
| `ATTACH` | `res://game/scenes/world/facades/810_avenue_d/810_avenue_d_facade.tscn`; later visual child |

## Invariant example and gates

```text
before: building:w96698660:wall is the 4 m/one-level, six-run spray receiver.
after:  the exact receiver, roof, footprint, height, topology, collision, spray,
        foundation, terrain and OSM/generated contracts remain; only a clearly
        historical, unattached front vocabulary is added.
```

- [ ] Reviewer confirms high address identity, May 2011 facade and March 2025 full enclosure.
- [ ] Current existence remains unknown; no current facade is fabricated.
- [ ] IDs/path/chunk, `6 / 51.994 m`, wall `12` and roof `2` triangles remain exact.
- [ ] `810`/entry stays unique; deck/rail/roof/utility are not baked into repeating material.
- [ ] Exact six-run endpoint ownership precedes placement; unobserved sides retain fallback.
- [ ] No silhouette/story/opening/physics/spray/source change.

```yaml
schema_version: codex.building-texture-research/1
target: {id: w96698660, receiver: 'building:w96698660:wall', identity_confidence: high}
sources: [L01, 810D-CURRENT, 810D-HIST]
temporal_state: {historic: facade_visible_may_2011, current: fully_enclosed_march_2025_existence_unknown}
observed_regions: [historic_front_southwest, historic_partial_southeast]
unobserved_regions: [current_facade, other_sides, exact_endpoints]
outputs: {homogeneous_material_tile: historical_reference_ready, architectural_pattern_tile: blocked, module_atlas: historical_reference_ready_placement_blocked, unique_elevation: front_only_historical_reference_ready_placement_blocked}
legal_seams: [homogeneous_siding, complete_front_window]
forbidden_seams: [opening, unique_entry, number_810, deck_rail, roof, utility, corner, generated_U_reset]
research_verdict: {ready_for_generation: true, ready_subset: [historic_materials, historic_front_modules], ready_for_attachment: false}
```

## Final status

- Historical front/material subset: **implementation-ready**.
- Current/whole-building placement: **blocked by enclosure, current-existence and endpoint unknowns**.
