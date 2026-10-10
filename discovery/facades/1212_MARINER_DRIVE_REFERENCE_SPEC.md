# 1212 Mariner Drive facade reference specification

Current architectural result: see the 2026-10-10 update at the end. Earlier rear-long identification and prototype gates are historical and superseded within that explicit scope.

Checked: **2026-08-29**  
Target: **unnamed residential `w96215649` / `building:w96215649:wall`**  
Mode: **research and implementation handoff only**

## Verdict

The frozen address/use and official Google label `1212` give high identity confidence. March/September 2025 official views cover the complete front long elevation plus rear long elevation/end, supporting a **target-specific material and front/rear/end module set**. It is not the same grammar as 1318 Gateview: 1212 has no pronounced porch canopy. Exact attachment remains blocked by unit-to-run reconciliation, short facets and the unobserved opposite end/notches.

## Exact identity and receiver

| Item | Exact value |
|---|---|
| Source | unnamed residential building, 1212 Mariner Drive; way `96215649`, v5, `2018-01-25T19:29:04Z`; levels `2`, height `6 m` |
| IDs/path | `building:w96215649`; wall `building:w96215649:wall`; roof `building:w96215649:roof`; chunk `x_-1__z_-3`; `WorldRoot/PlayableWorld/Buildings/x_-1__z_-3__building_w96215649_wall/building_w96215649_wall` |
| Contract | base/top `2.650 / 8.650 m`; lowest `2.528`; area `490.003 m²`; serialized/visible `115.694 / 115.696 m` |
| Mesh/groups | wall `28` runs `112v/56tri`; roof `18v/16tri`; ENE `74.5° 1/1.676`, `74.6° 1/10.979`, `74.9° 1/1.280`; SSE `164.6° 7/43.916`; WSW `254.6° 4/12.794`, `254.7° 2/1.131`; NNW `344.6° 9/36.317`, `344.7° 1/4.349`, `344.8° 2/3.254` m |
| Roles | wall `plaster_grey_04`, opaque `world_solid`, sole spray receiver; roof `bitumen`, opaque collider/non-spray |

## Provenance and coverage

| ID | Exact official source | Coverage |
|---|---|---|
| `1212-SV-FRONT` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8291464,-122.3730796&heading=172&pitch=0&fov=75); pano `moV9e3E7bv5UpjOrgfOOKA`; actual `37.8291812,-122.3730340`; **Mar 2025**; south `172°` | complete front long elevation |
| `1212-SV-REAR` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8291844,-122.3727735&heading=230&pitch=0&fov=75); pano `Z0fcNvA78OpNIXJaa9A79A`; actual `37.8291852,-122.3727577`; **Sep 2025**; southwest `230°` | rear long elevation and one end |

Opposite end, notches and exact endpoints are unobserved. No imagery is retained.

## Facts, inference and unknowns

Observed: two-storey attached units; light cool gray-blue horizontal siding; white trim/gutters; gray-brown shallow gable roof. Front units have upper broad sliders and ground broad windows alternating with dark red-brown entries, plus short dark gray-blue privacy/bin wings. There is **no pronounced porch canopy**. Rear units have upper and smaller lower windows behind privacy fences; visible end has stacked windows.

Reversible estimates: siding reflectance `45–65%`, roughness `0.65–0.85`, course `0.12–0.22 m`; white trim `70–90%`, roughness `0.55–0.78`; roof `20–35%`, roughness `0.80–0.95`; glass `0.12–0.28`; candidate unit width `3.5–5.5 m`, **low confidence**. Exact unit widths/counts, alternation period, entry colors, hidden lower rear, opposite end, notches and endpoint ownership remain unknown.

## Output classification and seams

| Output | Status / smallest cell |
|---|---|
| `homogeneous_material_tile` | **reference-ready** for siding/white trim/roof/red-brown and dark privacy fields |
| `architectural_pattern_tile` | **blocked**; variable unit alternation is not a verified cyclic period |
| `module_atlas` | **reference-ready, placement-blocked**: `1212-FRONT-UNIT`, `1212-REAR-UNIT`, unique `1212-END`, `1212-SOLID-SIDING` |
| `unique_elevation` | **reference-ready in front/rear sequence concept, placement-blocked** by exact run/end/notch map |

Legal seams: homogeneous siding and verified complete unit boundaries. Forbidden: inside window/door/slider, privacy wing, end motif, gutter/downspout, notch/corner, top/foundation and generated U reset. Never borrow 1318 Gateview's porch canopy or unit schedule.

## Godot BOM

| ID | Planned role |
|---|---|
| `MAT-SIDING`, `MAT-WHITE`, `MAT-ROOF`, `MAT-ENTRY`, `MAT-PRIVACY`, `MAT-GLASS` | `res://game/resources/materials/world/1212_mariner/`; target-specific PBR materials |
| `ATLAS-UNITS` | `res://game/resources/textures/buildings/1212_mariner/1212_mariner_modules`; complete front/rear/end RGBA modules/maps |
| `MOD-UNIT`, `MOD-END`, `MOD-PRIVACY` | `res://game/scenes/world/facades/1212_mariner/1212_mariner_modules.tscn`; shallow noncolliding visuals |
| `LAYOUT` | `res://game/resources/facades/1212_mariner_layout.json`; blocked pending ordered endpoint map |
| `ATTACH` | `res://game/scenes/world/facades/1212_mariner/1212_mariner_facade.tscn`; later visual child |

## Invariant example

```text
before: building:w96215649:wall is the 6 m/two-level, 28-run spray receiver.
after:  receiver, story count, silhouette, roof, footprint, structural openings,
        topology, foundation, physics, spray, terrain and source/generated contracts
        remain; complete 1212-specific modules attach only after exact mapping.
```

## Acceptance gates

- [ ] Reviewer confirms both official dates, 1212 label and front vs rear/end coverage.
- [ ] 1212 remains a distinct family: no 1318 porch canopy or schedule is imported.
- [ ] IDs/path/chunk, `6 m / 2`, `28 / 115.696 m`, wall `56` and roof `16` triangles remain.
- [ ] Atlas cells preserve complete units/openings; fences/privacy wings are not baked into siding.
- [ ] Ordered endpoints map units before placement; short facets/notches/U resets never set cadence.
- [ ] Unobserved opposite end stays fallback; no massing/opening/physics/spray/generated change.

```yaml
schema_version: codex.building-texture-research/1
target: {id: w96215649, receiver: 'building:w96215649:wall', identity_confidence: high}
sources: [L01, 1212-SV-FRONT, 1212-SV-REAR]
observed_regions: [complete_front_long, rear_long, one_end]
unobserved_regions: [opposite_end, notches, exact_endpoints, lower_rear_behind_fences]
outputs: {homogeneous_material_tile: reference_ready, architectural_pattern_tile: blocked, module_atlas: reference_ready_placement_blocked, unique_elevation: sequence_reference_ready_placement_blocked}
smallest_cell: {status: variable_complete_unit, modules: [1212-FRONT-UNIT, 1212-REAR-UNIT, 1212-END, 1212-SOLID-SIDING]}
legal_seams: [homogeneous_siding, verified_complete_unit_boundary]
forbidden_seams: [opening, privacy_wing, end_motif, gutter, downspout, notch, corner, receiver_top, foundation, generated_U_reset]
research_verdict: {ready_for_generation: true, ready_subset: [materials, unit_module_atlas, sequence_plan], ready_for_attachment: false}
```

## Final status

- Target-specific materials/modules/sequence concept: **implementation-ready**.
- Exact attachment: **blocked by endpoint/run mapping and unobserved end/notches**.

## 2026-10-10 whole-family architectural study — current scoped result

This update supersedes the earlier prototype-only status and historical side/roof
assumptions below; it does not turn unknown elevations into observed architecture.
Source is published `d7c88e2` plus the bounded, uncommitted Mariner family patch.
**Accepted for integration: full `tools/test.sh` PASS; not yet published.**
The two existing recognition credits are preserved, not earned again.

Reuse: retained `housing_site_family.gd`, its existing live attachment and the two
source-specific housing configs. Opt-in roof orientation/closure and trim preserve
other family instances and original frozen source records. No new asset base,
terrain, controller, camera, shader or hidden opening family was introduced.
Full roof coverage now follows the actual raw wall ring; exact pitch, section
joins, ridge placement and hidden closure are `production_inference`, not survey
or as-built claims. All sides were considered through shared closeups, raised
contexts and fixed island comparisons. Protected unknown walls remain coherent
fallbacks; their blankness is not verified real-world absence of openings.

Dated originals were checked 2026-10-10: March2025 public fronts for both units,
September2025 ENE end for1212; upload dates unknown. Original pixels and full
resolved Google URLs remain outside Git/game in
`/workspaces/landmark-progress-20261007/mariner-family-references` and
`breadth-next-family-note.txt`. Initial inaccessible reader/403 thumbnail attempts
were followed by successful bounded headed recovery. No new rear/opposite-end
observation was established; access and occlusion limits remain explicit.

Independent source CODE002 and narrow1219 CODE003: **PASS**, `b2_family024_code`.
Native adapter transform-list HOLD was corrected and independently rereviewed;
ordered packed mesh-transform then body-origin subtraction matches the producer.
Independent whole-family visual:1212 study002 **scoped architecture PASS**
(originally termed scoped L1/L2; not complete all-side L2),
`mariner_whole_family_visual`;1219 study003 **scoped whole-roof game-art PASS**,
`mariner_final_visual_fresh`. Distinct progress **PASS**,
`mariner_checkpoint_independent`, finds substantial complete roof/end architecture
progress and directs the next family to Station48 readiness after closure.
These are separate decisions; none establishes unobserved-side fidelity.

Actual shared `building_shots.gd` baselines and final1212 study002 /1219 study003
captures completed terminal0 with owned processes absent before slot release.
Before/after island comparisons show no visible broad composition regression;
facade detail is below their resolving scale.1219 default closeup-south is
obstructed by the opposite row and excluded from fidelity; complete donor-focused
front/oblique views provide the useful public-front comparison. All originals,
including invalid framing and earlier studies, remain privately retained in
`/workspaces/landmark-progress-20261007/mariner-family-study-20261010`.

Fresh combined shared native-fit/spray checks, rendered at fixed60fps:
1212 handle60995 terminal0, owned-process absence759919;1219 handle78231 terminal0
receipt9e7ba1, owned-process absence202307. Both passed complete ordered native
wall/roof/support/ground faces and source/server ownership, all four actual stock
approaches, supported grounded input-released active REST before SAFE, and one
actual source-wall tag followed by LAND REST/SAFE.1212 sprayed newly observed ENE
run13;1219 sprayed its correct public frontage.1219's roof winding diagnostic
includes deliberate undersides/edges, not upward-only faces. No new walkable
stairs were added. Existing seven TextureRID shutdown warnings remain despite
terminal0; no performance or universal shutdown-repair claim follows.

History retained: first headless fit exited1 before geometry; private roof builder
exhausted memory (exit134) after repeated near-endpoint crossing insertion; an
area preflight compared the raw wall ring to an older simplified roof and failed
before study001's shell incorrectly continued to capture. Bounded crossing and
actual-ring comparison corrected those causes; study002/003 observed successful
preflight before separate capture commands, with zero failed-preflight dependent
launches. Study001 visual REWORK and1219 study002 REWORK remain historical, not
rewritten PASS. Final separate visual and fresh runtime results supersede their
pending current-gate statements only. Required scoped roof/envelope study gates are now closed; all-side L2 opening
completeness and integration/publication remain pending.

1212 scope: only ENE run13 moves from protected to observed ownership for the
three complete openings (small high-left, narrow upper/lower-right), shallow
siding-filled gable and continuous sloping white rake trim. Protected runs0–12,
18,23 remain unchanged; existing frontage14–17,19–22,24–27 remains intact.
The September panorama is the ENE end, not a rear-long elevation;1414 Gateview is
the camera label. The earlier rear-long observations above supply no rear claim.
The final roof/end now reads as coherent gray planar roofing and one continuous
gable, rather than baseline holes or study001's cap and straight band.

Final suite closure: complete `tools/test.sh` handle73786 reached terminal0
(receipt21fc9a), all nine nested script statuses0, junk/import, all49 scored
building fits, Node validation and world determinism PASS. Actual owned-process
absence and empty Godot/Weston scan e60b38 preceded engine release. Runtime source
was frozen; only ordinary closure metadata changes afterward. Both units are
accepted for scoped roof/envelope game-art integration, not yet published. Only
L1 shape/site is complete; coherent inferred envelopes and fresh four-side fits
support that stage. Complete all-side L2 doors/windows/roof remains U, not I: roof,
front and1212 end repairs do not establish rear/opposite-end opening completeness.
As-built accuracy and newly observed hidden elevations remain unclaimed. Historical49 recognition
credits remain unchanged. No further render/test replay accompanies this note.

Stage clarification: independent `mariner_final_visual_fresh` directly inspected
current1219 north and1212 south blank rear views. Available references cover the
fronts and1212 ENE end, not those rear opening schedules. The scoped visual PASS
and all CODE/native-fit/spray/suite PASS results stand; they cannot supply complete
all-side L2. Before a future L2 assignment, seek bounded rear/other-end sources
and resolve the remaining coverage; unknown is neither a demonstrated defect nor
permission to invent hidden motifs. This corrects the earlier checklist overclaim
without changing geometry or revoking historical recognition credit.
