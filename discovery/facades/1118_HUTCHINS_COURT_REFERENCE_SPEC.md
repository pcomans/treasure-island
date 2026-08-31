# 1118 Hutchins Court facade reference specification

Checked: **2026-08-29**  
Target: **unnamed residential `w96665885` / `building:w96665885:wall`**  
Mode: **research and implementation handoff only**

## Receiver-first verdict

April 2019 official views establish the row/footprint area but display neighboring 1116 and 1114, not 1118. Exact unit ownership is therefore medium confidence. Conservative warm-gray siding research is defensible; target-specific unit/end placement remains blocked by address boundary, rear coverage and run mapping.

## Exact identity and receiver

| Item | Exact local evidence |
|---|---|
| Source | way `96665885`, v5, `2020-07-09T13:50:42Z`; `building=residential`, levels `2`, height `6 m`; no name |
| IDs/path | `building:w96665885`; wall `building:w96665885:wall`; roof `building:w96665885:roof`; chunk `x_-2__z_-2`; `WorldRoot/PlayableWorld/Buildings/x_-2__z_-2__building_w96665885_wall/building_w96665885_wall` |
| Meters | base/top `2.351 / 8.351`; lowest foundation `2.081`; area `306.747 m²`; serialized/visible `77.780 / 77.779 m` |
| Mesh/groups | wall `12` runs `48v/24tri`; roof `4v/2tri`; NNE `16.7° 3/27.897`; ESE `106.8° 2/10.998`; SSW `196.7° 3/27.887`; WNW `286.7° 4/10.996` m |
| Roles | wall `plaster_grey_04`, opaque `world_solid`, sole spray receiver; roof `bitumen`, opaque collider/non-spray; no shared parts |

## Provenance and coverage

| ID | Exact official source | Coverage / identity limit |
|---|---|---|
| `1118H-SV01` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8279184,-122.3764576&heading=287&pitch=0&fov=75); pano `XU1w3TFYLhKboWObJpe76A`; actual `37.8279285,-122.3764638`; **April 2019**; WNW `287°` | ESE/end/return area; Google displayed neighboring 1116 |
| `1118H-SV02` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8282685,-122.3767654&heading=166&pitch=0&fov=75); pano `I2Dk_vOGXwebdfpTi5JLzg`; actual `37.8282512,-122.3767328`; **April 2019**; SSE `166°` | NNE/public long row; Google displayed neighboring 1114 |

SSW/rear, WNW end, exact 1118 unit boundary and endpoints are unobserved. No imagery is stored.

## Facts, cautious inference, modules and seams

Row observations: two storeys; muted warm-gray/taupe horizontal siding; white trim/gutters/downspouts; shallow muted-gray roof; broad upper sliders; ground broad windows, dark navy doors and blue-gray privacy/bin enclosures with thin caps/hoods. End is mostly blank siding below shallow gable but tree/fence occluded. No masonry belt/rib/porch canopy/large opening. Cars/bins/trees/fences excluded.

Reversible inference: siding reflectance `40–60%`, roughness `0.65–0.85`, course `0.12–0.22 m`; white trim `70–90%`; navy `8–20%`; unit width `3.5–5.5 m`, low confidence. Exact 1118 door/window states and ownership remain unknown.

`1118H-SIDING` is target-area conservative field. `1118H-ROW-UNIT-CANDIDATE` and `1118H-END-CANDIDATE` are provisional study cells only, not target placement authority.

| Output | Status |
|---|---|
| `homogeneous_material_tile` | **conservative reference-ready** for warm-gray siding/white trim |
| `architectural_pattern_tile` | **blocked**; exact 1118 unit period/ownership absent |
| `module_atlas` | **provisional study only, placement-blocked** by neighboring-address ambiguity |
| `unique_elevation` | **blocked** by unit/address ambiguity and missing rear/end |

Legal seams: uninterrupted siding only; unit seam becomes legal only after exact ownership. Forbidden: U reset, opening/door/privacy/hood, gutter/downspout/eave/gable, corner, tree/fence and any borrowed 1114/1116 feature.

## Reserved Godot BOM

| ID | Planned path / status |
|---|---|
| `MAT` | `res://game/resources/materials/world/1118_hutchins/` — conservative siding/trim fields |
| `ATLAS` | `res://game/resources/textures/buildings/1118_hutchins/1118_hutchins_modules` — provisional study only |
| `MOD` | `res://game/scenes/world/facades/1118_hutchins/1118_hutchins_modules.tscn` — blocked from attachment |
| `LAYOUT` | `res://game/resources/facades/1118_hutchins_layout.json` — ordered endpoints required |
| `ATTACH` | `res://game/scenes/world/facades/1118_hutchins/1118_hutchins_facade.tscn` — later visual child |

## Boundary and invariant example

```text
before: building:w96665885:wall is the 6 m/two-level, 12-run spray receiver.
after:  exact target massing, silhouette, roof, footprint, openings, topology,
        foundation, terrain, physics, spray, OSM and generated data remain; only
        independently observed complete visuals may attach after endpoint mapping.
```

## Acceptance gates

- [ ] Reviewer confirms the views display neighboring 1114/1116 and that exact 1118 unit ownership remains unproven.
- [ ] IDs/path/chunk, `6 m / 2`, `12 / 77.779 m`, wall `24` and roof `2` triangles remain.
- [ ] No adjacent-court/Gateview/Mariner material or module transfers.
- [ ] Only conservative siding/provisional study is produced; no target unit/end placement occurs.
- [ ] Ordered endpoints—not four groups/U resets—control placement.
- [ ] Visual child has no physics/navigation/spray role and preserves massing/source/generated data.

```yaml
schema_version: codex.building-texture-research/1
target: {id: w96665885, receiver: 'building:w96665885:wall', identity_confidence: high}
sources: [L01, 1118H-SV01, 1118H-SV02]
observed_regions: [row_nne_front, row_ese_end_return]
unobserved_regions: [exact_1118_unit, ssw_rear, wnw_end, exact_endpoints]
outputs: {homogeneous_material_tile: conservative_reference_ready, architectural_pattern_tile: blocked, module_atlas: provisional_study_placement_blocked, unique_elevation: blocked}
smallest_cell: {status: target_ownership_unproven, modules: [1118H-SIDING, 1118H-ROW-UNIT-CANDIDATE, 1118H-END-CANDIDATE]}
legal_seams: [uninterrupted_siding]
forbidden_seams: [generated_U_reset, opening, door, privacy_enclosure, hood, gutter, downspout, eave, gable, corner, tree, fence, neighboring_unit_feature]
research_verdict: {ready_for_generation: true, ready_subset: [conservative_siding_material, provisional_row_study], ready_for_attachment: false, blockers: [1118_unit_address_ambiguity, rear_end_unobserved, physical_scale_unknown, endpoint_mapping_missing]}
```

## Final status

- Conservative material/provisional row study: **implementation-ready**.
- Target modules/attachment: **blocked by 1114/1116 versus 1118 ownership ambiguity**.
