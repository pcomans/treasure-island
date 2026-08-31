# `w1222514695` shelter-tagged source facade reference specification

Checked: **2026-08-29**
Target: **unnamed source `w1222514695` / `building:w1222514695:wall`**
Mode: **reference-blocked research handoff; no appearance output authorized**

## Receiver-first verdict

The frozen source is exactly identified by key and tagged `building=shelter`, but official September 2025 coverage does not reveal a target-identifiable wall. Identity remains source-key-only, every side is unobserved, and the frozen `283.567 m²` source versus `43.535 m²` serialized receiver discrepancy prevents ownership of any omitted footprint portion. **All facade outputs are reference-blocked.**

## Exact local receiver

| Item | Local fact |
|---|---|
| Source | OSM way `1222514695`, v2, `2025-03-23T16:25:59Z`; `building=shelter`; no frozen name/address/height/levels |
| Objects | logical `building:w1222514695`; wall `building:w1222514695:wall`; roof `building:w1222514695:roof`; chunk `x_-1__z_3` |
| Geometry | source/serialized area `283.567 / 43.535 m²`; serialized/visible perimeter `26.588 / 26.589 m`; standalone receiver, no shared-above-lower-part runs |
| Massing | generated default height `6 m`; base/top `3.034 / 9.034 m`; not observed shelter massing |
| Topology | `5` exterior runs; ENE `2 / 6.221 m`, SE `1 / 7.087 m`, WSW `1 / 6.270 m`, NW `1 / 7.012 m` |
| Runtime | wall `building_wall -> plaster_grey_04`, opaque/spray receiver; roof `building_roof -> bitumen`, opaque collider/non-spray |

## Evidence, coverage and confidence

| Evidence ID | Source | What it establishes |
|---|---|---|
| `B06-LOCAL-W1222514695` | [`FACADE_RECEIVER_INVENTORY.json`](../FACADE_RECEIVER_INVENTORY.json), [`NEXT_FACADE_BATCH_06.md`](NEXT_FACADE_BATCH_06.md), [`BATCH_06_STREETVIEW_OBSERVATIONS.md`](BATCH_06_STREETVIEW_OBSERVATIONS.md) | exact source/receiver identity, tags, metric topology and source/serialized conflict; no target appearance |
| `B06-W1222514695-SV01` | [official Google Street View pano `-9-3R6HngS2KcuZw9K3C_w`](https://www.google.com/maps/@?api=1&map_action=pano&pano=-9-3R6HngS2KcuZw9K3C_w&heading=202&pitch=1&fov=55), actual `37.8176553,-122.3716066`, SSW, **September 2025** | likely target area is occluded by foreground building/landscaping; no target wall identified |
| `B06-W1222514695-EX01` | excluded contributor pano `CIHM0ogKEICAgID--tjX6gE`, November 2022 | no evidence; contributor imagery was not used |

Observed target sides: **none**. ENE, SE/SSE, WSW, NW, short facets, roof edge, ground interface, materials, openings and motifs are unobserved. Identity confidence is **low/source-key-only**. Nearby coverage does not prove survival or absence. Google imagery was inspected transiently; no pixels are stored.

## Output classification, motif and seam contract

| Output | Status and reason |
|---|---|
| `homogeneous_material_tile` | **reference-blocked**; no target material, value, roughness or physical scale is visible |
| `architectural_pattern_tile` | **reference-blocked**; no cadence or boundary product is visible |
| `module_atlas` | **reference-blocked**; no complete target motif exists in evidence |
| `unique_elevation` | **reference-blocked**; identity/coverage and footprint ownership are unresolved |

Motif inventory: **empty**. Physical-scale status: receiver dimensions are exact local facts, but every real material/module dimension is **unknown**. No legal seam exists. All receiver edges, corners, generated U resets, top/foundation edges and possible motif boundaries are forbidden until target ownership and one uninterrupted visible surface are established.

Do not invent canopy, posts, glazing, openings, sign, trim, color, roof/eave, rear treatment, height, current condition or omitted footprint from the shelter tag, ferry context or neighboring buildings.

## Geometry boundary and invariant example

```text
before: building:w1222514695:wall is the default-6 m, five-run placeholder receiver.
after:  it remains byte-for-byte and visually unchanged; no facade output exists until
        target identity, footprint ownership and official target coverage are proven.
```

No future facade attachment may change silhouette, height/story count, roof, footprint, source/serialized geometry, foundation/terrain, collision, navigation, spray ownership, or generated OSM contracts. Shallow render-only modules are not authorized because no module is observed.

## Acceptance gate and blockers

- [ ] Official target-identifiable coverage establishes at least one named receiver side.
- [ ] Source/serialized area conflict is reconciled before any elevation endpoint ownership.
- [ ] A target material region and physical-scale calibration plan exist before a field prototype.
- [ ] A complete motif plus every boundary product exists before an atlas/pattern output.
- [ ] Exact placement is reviewed separately; no generated U reset is treated as cadence.

Primary blockers: **no identifiable official facade; no material/module evidence; source/serialized footprint conflict; default massing unverified**. Prototype readiness: **none**. Live readiness: **none**. Whole-object resemblance: **unreviewable/reference-blocked**.

```yaml
schema_version: codex.building-texture-research/1
target: {canonical_name: null, id: w1222514695, receiver: 'building:w1222514695:wall', identity_confidence: low}
sources: [B06-LOCAL-W1222514695, B06-W1222514695-SV01]
observed_regions: []
unobserved_regions: [all_receiver_sides, openings, roof_edge, ground_interface]
outputs: {homogeneous_material_tile: reference_blocked, architectural_pattern_tile: reference_blocked, module_atlas: reference_blocked, unique_elevation: reference_blocked}
smallest_cell: {status: unknown, motifs: []}
legal_seams: []
forbidden_seams: [all_receiver_edges, all_possible_motif_boundaries, generated_U_resets]
research_verdict: {ready_for_generation: false, ready_for_attachment: false, blockers: [target_not_visible, identity_source_key_only, source_serialized_area_conflict, physical_scale_unknown]}
```
