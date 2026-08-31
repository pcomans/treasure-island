# `w1222720021` observation-tower-tagged source facade reference specification

Checked: **2026-08-29**
Target: **unnamed source `w1222720021` / `building:w1222720021:wall`**
Mode: **reference-blocked research handoff; no appearance output authorized**

## Receiver-first verdict

The frozen source is exactly keyed and tagged `man_made=tower`, `tower:type=observation`, `layer=1`, but neither May 2019 nor September 2025 official coverage reveals a target-identifiable structure. The separate generated object is not part of the Museum facade receiver. Its default `6 m` prism is a documented massing concern, not facade evidence. **All facade outputs are reference-blocked.**

## Exact local receiver

| Item | Local fact |
|---|---|
| Source | OSM way `1222720021`, v1, `2023-11-11T11:40:09Z`; `building=yes`, `man_made=tower`, `tower:type=observation`, `layer=1`; no name/address/height/levels |
| Objects | logical `building:w1222720021`; wall `building:w1222720021:wall`; roof `building:w1222720021:roof`; chunk `x_0__z_2` |
| Geometry | source/serialized area `48.132 / 48.132 m²`; serialized/visible perimeter `25.261 / 25.260 m`; standalone direct receiver, separate from Museum `r16681702`; no shared runs |
| Massing | generated default height `6 m`; base/top `5.415 / 11.415 m`; tower silhouette/height unobserved |
| Topology | `10` exterior runs / `8` groups: NNE `2/3.156 m`; ENE `1/3.089`; ESE `1/3.043`; SSE `1/3.340`; SSW `1/3.159`; WSW `2/3.093`; WNW `1/3.032`; NNW `1/3.348` |
| Runtime | wall `building_wall -> plaster_grey_04`, opaque/spray receiver; roof `building_roof -> bitumen`, opaque collider/non-spray |

## Evidence, coverage and confidence

| Evidence ID | Source | What it establishes |
|---|---|---|
| `B06-LOCAL-W1222720021` | [`FACADE_RECEIVER_INVENTORY.json`](../FACADE_RECEIVER_INVENTORY.json), [`NEXT_FACADE_BATCH_06.md`](NEXT_FACADE_BATCH_06.md), [`BATCH_06_STREETVIEW_OBSERVATIONS.md`](BATCH_06_STREETVIEW_OBSERVATIONS.md) | exact source/receiver and tower tag; no target appearance |
| `B06-W1222720021-SV01` | [official pano `-9-3R6HngS2KcuZw9K3C_w`](https://www.google.com/maps/@?api=1&map_action=pano&pano=-9-3R6HngS2KcuZw9K3C_w&heading=125&pitch=1&fov=75), actual `37.8176553,-122.3716066`, southeast, **September 2025** | target area blocked by a curved foreground building |
| `B06-W1222720021-SV02` | [official pano `MGLja7KGZ2kmIQSXa35Pgg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=MGLja7KGZ2kmIQSXa35Pgg&heading=258&pitch=1&fov=80), actual `37.8178183,-122.3684619`, WSW, **May 2019** | nearby fenced/construction context; no identifiable tower |
| `B06-W1222720021-EX01` | excluded contributor pano `CIHM0ogKEICAgID7-sfhQg` | no evidence; contributor imagery was not used |

Observed target sides: **none**. All eight orientation groups, base, top/platform, rail/guard, openings and access elements are unobserved. Identity confidence is **low/source-key-only**. Official nearby coverage proves neither survival nor demolition. No imagery is stored.

## Output classification, motif and seam contract

`homogeneous_material_tile`, `architectural_pattern_tile`, `module_atlas` and `unique_elevation` are all **reference-blocked**. No material field, repeat, complete motif or elevation boundary is visible. Motif inventory is empty; all physical material, rail, opening and structural dimensions are unknown. No legal seam is established; every receiver edge and generated U reset is protected.

Do not invent railings, platform/deck bands, glazing, columns, stairs, access doors, tower height/silhouette, structural rhythm, material, color or roof/top from the frozen tags, nearby curved building, Museum evidence or distant structures.

## Geometry boundary and invariant example

```text
before: building:w1222720021:wall is the default-6 m, ten-run placeholder receiver.
after:  it remains unchanged; the tower tag is not painted into a facade and no
        visual output exists until the exact structure and target sides are observed.
```

Facade work cannot solve the probable massing mismatch. Any future silhouette, height, platform, column, stair or deck change requires separate geometry approval. Collision, navigation, spray, terrain/foundation, source and generated contracts remain untouched.

## Acceptance gate and blockers

- [ ] Official target-identifiable coverage resolves the separate tower object and at least one side.
- [ ] Geometry review decides tower massing independently of facade work.
- [ ] Material identity, physical scale and at least one complete motif are evidenced before prototypes.
- [ ] Museum modules/materials are never propagated to this separate receiver.

Primary blockers: **no identifiable official facade; tower form/material unknown; default-prism massing conflict**. Prototype readiness: **none**. Live readiness: **none**. Whole-object resemblance: **unreviewable/reference-blocked**.

```yaml
schema_version: codex.building-texture-research/1
target: {canonical_name: null, id: w1222720021, receiver: 'building:w1222720021:wall', identity_confidence: low}
sources: [B06-LOCAL-W1222720021, B06-W1222720021-SV01, B06-W1222720021-SV02]
observed_regions: []
unobserved_regions: [all_eight_orientation_groups, base, platform_top, openings, access]
outputs: {homogeneous_material_tile: reference_blocked, architectural_pattern_tile: reference_blocked, module_atlas: reference_blocked, unique_elevation: reference_blocked}
smallest_cell: {status: unknown, motifs: []}
legal_seams: []
forbidden_seams: [all_receiver_edges, all_possible_motif_boundaries, generated_U_resets]
research_verdict: {ready_for_generation: false, ready_for_attachment: false, blockers: [target_not_visible, identity_source_key_only, tower_massing_unknown, physical_scale_unknown]}
```
