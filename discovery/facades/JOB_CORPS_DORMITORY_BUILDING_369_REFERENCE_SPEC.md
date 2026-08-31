# US Dept of Labor Job Corps Dormitory Building 369 / 275 California Avenue facade reference specification

Checked: **2026-08-29**  
Target: **`w291189926` / `building:w291189926:wall`**  
Mode: **research and implementation handoff only**

## Verdict

The frozen identity/address join is exact. A September 2025 official panorama shows the southwest/west long elevation and southeast/end corner well enough for a **bounded material and long-elevation module-atlas study**. It also shows **five occupied tiers**, which conflicts with the generated fallback `6 m` massing. Preserve that conflict: do not compress five tiers into the receiver, change height, or place modules until a separately approved massing decision and canonical run map exist.

## Exact identity and receiver

| Item | Exact value |
|---|---|
| Identity/address | US Dept of Labor Job Corps Dormitory Building 369; 275 California Avenue |
| Frozen source | way `291189926`, v3, `2024-02-20T05:25:18Z`; `building=dormitory`; no height/levels |
| Logical/wall/roof | `building:w291189926`; `building:w291189926:wall`; `building:w291189926:roof` |
| Chunk/runtime | `x_0__z_1`; `WorldRoot/PlayableWorld/Buildings/x_0__z_1__building_w291189926_wall/building_w291189926_wall` |
| Generated massing | `default_6m`; base/top `3.390 / 9.390 m`; lowest foundation vertex `3.141 m` |
| Mesh/extent | area `2942.433 m²`; serialized/visible perimeter `487.831 / 487.830 m`; wall `72` runs, `288v/144tri`; roof `34v/32tri` |
| Facing totals | NE `157.211`; SE `86.691`; SW `157.222`; NW `86.706 m` |
| Materials/roles | wall `plaster_grey_04`, opaque `world_solid`, sole spray receiver; roof `bitumen`, opaque collider/non-spray; no override |

Exact normal groups remain receiver diagnostics, not layout chains: ENE `62.0° 20/153.470 m`, `62.1° 1/1.878`, `62.2° 1/1.863`; SSE `151.8° 1/1.976`, `151.9° 1/2.103`, `152.0° 7/82.612`; WSW `241.6° 2/6.605`, `241.9° 1/1.905`, `242.0° 18/140.243`, `242.1° 1/1.915`, `242.2° 1/6.554`; NNW `331.8° 1/1.297`, `331.9° 1/1.395`, `332.0° 11/67.627`, `332.1° 5/16.387`. U restarts per run; V is world y/10.

## Observation provenance and coverage

| ID | Exact source | Observed fact | Limit |
|---|---|---|---|
| `L01` | frozen OSM/inventory/generated records, checked 2026-08-29 | identity, address, receiver/topology | no appearance or real height |
| `D369-SV01` | [official request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8193228,-122.3711959&heading=56&pitch=0&fov=75); pano `NztWn9fwLieghDTyI_iEyQ`; actual `37.8193190,-122.3712241`; **Sep 2025**; northeast heading `56°` | broad southwest/west long elevation and southeast/end corner | other long side, rear/end, entrances, recesses and endpoints unobserved |
| `D369-NO01` | [official request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8200821,-122.3699753&heading=234&pitch=0&fov=75) | attempted east-side coverage | no approved official panorama/date; supports no visual claim |

No imagery was downloaded, retained or redistributed. The repo stores observations and source locators only.

## Observed facade grammar; fact, inference and unknown

Observed: light warm-gray/off-white smooth wall field; muted blue-gray end/stair volume; thin dark muted-green eave; five occupied tiers; alternating broad multi-lite and narrow windows; many broad windows have green eyebrow elements; ground broad bays mix glazing, opaque blue-gray panels/doors and base vents. The visible end is mostly solid blue-gray; ramp/rail elements are geometry, not texture.

Production inferences, deliberately reversible: wall reflectance `55–75%`, roughness `0.70–0.90`; blue-gray `25–45%`, roughness `0.70–0.90`; green trim `8–18%`, roughness `0.55–0.75`; glass perceptual roughness `0.12–0.28`. Candidate bay width `1.2–2.4 m` and floor-to-floor `2.5–3.3 m` are **low-confidence visual estimates**, not derivable from the `6 m` receiver.

Unknown: substrate, exact dimensions, broad/narrow alternation period, entrance design, opposite-side grammar, all endpoint ownership, and how a five-tier facade is to reconcile with current massing.

## Output classification and seam contract

| Output | Readiness and smallest-repeat rationale |
|---|---|
| `homogeneous_material_tile` | **reference-ready** for warm field, blue-gray field and green trim; author neutral PBR swatches, `1–2 m` test tile, no baked lighting |
| `architectural_pattern_tile` | **blocked**; no complete verified horizontal period or opposite edges |
| `module_atlas` | **reference-ready, placement-blocked**: `D369-WIDE-BAY`, `D369-NARROW`, ground glazed/opaque/door after-states, and `D369-SOLID-END`; each module contains a complete opening/trim unit |
| `unique_elevation` | **blocked** by five-tier/6 m conflict, incomplete sides and unresolved 72-run canonical map |

Legal seams: uninterrupted material field and complete module boundaries. Forbidden: windows/doors/vents/eyebrows, eave, end-volume transition, corners, top/foundation, generated U resets and foundation-split same-normal runs. Never propagate the observed schedule to the unobserved parallel elevation.

## Godot bill of materials

| ID | Planned path / role |
|---|---|
| `MAT-WARM`, `MAT-BLUE`, `MAT-GREEN`, `MAT-GLASS` | `res://game/resources/materials/world/job_corps_dormitory_b369/`; evidence-bounded PBR materials |
| `ATLAS-LONG` | `res://game/resources/textures/buildings/job_corps_dormitory_b369/dormitory_b369_long_modules`; complete RGBA modules plus normal/roughness |
| `MOD-LONG`, `MOD-END` | `res://game/scenes/world/facades/job_corps_dormitory_b369/dormitory_b369_modules.tscn`; shallow noncolliding render quads only |
| `LAYOUT` | `res://game/resources/facades/job_corps_dormitory_b369_275_california_layout.json`; blocked pending canonical endpoints/massing decision |
| `ATTACH` | `res://game/scenes/world/facades/job_corps_dormitory_b369/dormitory_b369_facade.tscn`; later visual child |

## Geometry boundary and invariant before -> after

Only surface PBR and complete shallow render modules are facade-owned. No silhouette, story count, height, roof, footprint, structural opening, collision, spray eligibility/ownership, navigation, foundation, terrain, OSM or generated contract may change here.

```text
before: building:w291189926:wall is a fallback-6 m, 72-run opaque spray receiver.
after:  the exact receiver and every massing/physics/source invariant remain; only
        bounded material/module prototypes exist, with placement withheld pending
        the five-tier conflict and canonical edge map.
```

## Executable acceptance gates

- [ ] Reviewer opens `D369-SV01` and confirms only the stated southwest/end coverage and September 2025 date.
- [ ] Five visible tiers are recorded as a conflict; no asset is vertically compressed and no massing edit is bundled.
- [ ] IDs/path/chunk, `72 / 487.830 m`, wall `144` and roof `32` triangles remain exact.
- [ ] Atlas cells contain complete motifs; material maps contain no lighting, reflections or displacement.
- [ ] A canonical source-edge-to-run table precedes placement; U resets/normals never set phase.
- [ ] Unobserved sides receive only the neutral shared fallback, not inferred cadence.
- [ ] Visual children have no collider/navigation/spray role and preserve all generated bytes.

## Normalized handoff

```yaml
schema_version: codex.building-texture-research/1
target: {id: w291189926, receiver: 'building:w291189926:wall', identity_confidence: high}
sources: [L01, D369-SV01, D369-NO01]
observed_regions: [southwest_west_long, southeast_end_corner]
unobserved_regions: [opposite_long, rear_end, entrances, recesses, exact_endpoints]
outputs: {homogeneous_material_tile: reference_ready, architectural_pattern_tile: blocked, module_atlas: reference_ready_placement_blocked, unique_elevation: blocked}
smallest_cell: {status: module_only, modules: [D369-WIDE-BAY, D369-NARROW, D369-GROUND-AFTER-STATES, D369-SOLID-END]}
legal_seams: [homogeneous_field, complete_module_boundary]
forbidden_seams: [opening, eyebrow, eave, end_transition, corner, receiver_top, foundation, generated_U_reset]
uncertainty: [five_tiers_vs_default_6m, exact_scale, alternation_period, opposite_side, canonical_run_map]
research_verdict: {ready_for_generation: true, ready_subset: [material_swatches, module_atlas_prototypes], ready_for_attachment: false}
```

## Final status

- Materials/module prototypes: **implementation-ready within observed bounds**.
- Receiver attachment/unique elevation: **blocked** by massing conflict, incomplete coverage and run mapping.
