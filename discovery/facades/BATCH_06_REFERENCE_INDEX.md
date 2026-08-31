# Batch 06 facade reference index and prototype-priority handoff

Checked: **2026-08-29**
Mode: **research/specification only**
Authoritative observation ledger: [`BATCH_06_STREETVIEW_OBSERVATIONS.md`](BATCH_06_STREETVIEW_OBSERVATIONS.md)

## Cohort verdict

Eight exact generated wall receivers were reconciled to the finalized observation ledger. Six coordinate-matched standing targets have bounded local material fields and complete-module families suitable for prototype/scale studies. `w1222514695` and `w1222720021` have no target-identifiable official facade coverage and are reference-blocked for every output. **No Batch 06 target is ready for live attachment or whole-object acceptance.**

All eight sources lack a frozen human-readable name and address. Descriptors such as shelter, observation tower and retail are frozen tags, not proof of current appearance, occupant, business identity or public-side ownership.

## Exact receiver and readiness inventory

| # | Target/spec | Exact receiver / chunk | Generated contract | Observed evidence | Prototype-ready subset | Live / whole-object blocker |
|---:|---|---|---|---|---|---|
| 1 | [`w1222514695` shelter-tagged](W1222514695_SHELTER_REFERENCE_SPEC.md) | `building:w1222514695:wall` / `x_-1__z_3` | default `6 m`; `5 / 26.589 m`; source/serialized area `283.567 / 43.535 m²` | none; September 2025 area occluded | **none — reference-blocked** | identity/coverage, footprint conflict, massing/material/module/scale unknown |
| 2 | [`w1222720021` observation-tower-tagged](W1222720021_OBSERVATION_TOWER_REFERENCE_SPEC.md) | `building:w1222720021:wall` / `x_0__z_2` | default `6 m`; `10 / 25.260 m`; 8 groups | none; May 2019 and September 2025 nearby views do not identify tower | **none — reference-blocked** | target not seen; tower silhouette/material/scale unknown; default-prism conflict |
| 3 | [`w34313515`](W34313515_REFERENCE_SPEC.md) | `building:w34313515:wall` / `x_-1__z_1` | `11 m`; `48 / 546.656 m`; 5 groups | September 2025 WSW + NNW | pale field scale study; complete stacked bay/recess atlas study | scale/cadence/lower-region/endpoints; ENE/SSE absent; whole object blocked |
| 4 | [`w34313520`](W34313520_REFERENCE_SPEC.md) | `building:w34313520:wall` / `x_-1__z_0` | `11 m`; `34 / 376.239 m`; 6 groups | September 2025 SSE only | pale field scale study; complete stacked bay atlas study | scale/endpoints/wing ownership; other sides absent; whole object blocked |
| 5 | [`w34313525`](W34313525_REFERENCE_SPEC.md) | `building:w34313525:wall` / `x_1__z_-1` | `5 m / 1`; `30 / 354.736 m`; 4 groups | March 2025 NNW/inset + SSE | aged pale field; complete roll-up/personnel/high-window atlas studies | scale, irregular chain ownership, ends/re-entrants, eave geometry; whole object blocked |
| 6 | [`w34313564`](W34313564_REFERENCE_SPEC.md) | `building:w34313564:wall` / `x_0__z_-3` | `5 m`; `20 / 282.680 m`; 4 groups | September 2025 SSE + NNW + ENE | separate tan/pale/plinth fields; complete window/door atlas studies | scale/endpoints/NNW occlusion; WSW absent; whole object blocked |
| 7 | [`w291196370`](W291196370_REFERENCE_SPEC.md) | `building:w291196370:wall` / `x_0__z_-3` | `6 m`; `36 / 258.421 m`; 10 groups/short facets | September 2025 SSE + ENE | siding/trim scale study; complete window/entry/service atlas studies | siding scale/divider cadence/endpoints; NNW/WSW absent; whole object blocked |
| 8 | [`r133351` retail-tagged relation](R133351_RETAIL_REFERENCE_SPEC.md) | `building:r133351:wall` / `x_-2__z_-2` | `3 m / 1`; `78 / 541.627 m`; 33 outer/inner groups | March 2025 central/east + western public regions | separate light/olive/red-brown field studies; complete public module studies | outer/inner/wing membership, scale, north/courtyard, adjacent volume; whole object blocked |

Run lengths are generated visible-wall sums. One Godot unit is one metre. Every wall uses `building_wall -> plaster_grey_04`, is opaque and is the sole spray receiver; every roof uses `building_roof -> bitumen`, is opaque/colliding and non-spray. No target has shared-above-lower-part walls.

## Output classification matrix

| Target | `homogeneous_material_tile` | `architectural_pattern_tile` | `module_atlas` | `unique_elevation` |
|---|---|---|---|---|
| `w1222514695` | reference-blocked | reference-blocked | reference-blocked | reference-blocked |
| `w1222720021` | reference-blocked | reference-blocked | reference-blocked | reference-blocked |
| `w34313515` | pale field reference-ready; scale blocked | blocked; no proven cell | complete bay/recess reference-ready; scale/placement blocked | WSW/NNW concept-ready; mapping blocked |
| `w34313520` | pale field reference-ready; scale blocked | blocked; no proven cell | complete stacked bay reference-ready; scale/placement blocked | SSE concept-ready; mapping/wing blocked |
| `w34313525` | aged pale field reference-ready; scale blocked | blocked; irregular openings/eave geometry | complete roll-up/door/window groups reference-ready; scale/placement blocked | two-side concept-ready; footprint mapping blocked |
| `w34313564` | separate tan/pale/plinth fields reference-ready; scale blocked | blocked; irregular cadence/side split | complete window/door reference-ready; scale/placement blocked | SSE/NNW/ENE concept-ready; mapping blocked |
| `w291196370` | siding field reference-ready; course scale blocked | blocked; dividers are not a proven period | complete window/entry/service modules reference-ready; scale/placement blocked | SSE/ENE concept-ready; mapping blocked |
| `r133351` | separate light/olive/red-brown fields reference-ready; scale blocked | blocked; no relation-wide cell | complete public window/entry/west-lower modules; scale/placement blocked | separate region concepts; relation mapping blocked |

No target proves an `architectural_pattern_tile`. Complete motifs belong in atlases; region-specific nonperiodic compositions belong in unique-elevation plans after ordered endpoint ownership is established.

## Shared motif and seam policy

- Complete modules include their full frame/surround and every semantic boundary. A partial window, door, pier, recess, divider or panel is not a module.
- Legal seams occur only inside one uninterrupted homogeneous field or at a verified complete-module outer boundary. For siding, course height/phase must also remain continuous.
- Generated U restarts are never legal architectural seams or cadence evidence.
- Forbidden joins include openings, mullions, piers, recess/depth changes, material transitions, plinth/base transitions, repair-patch bounds, parapet/eave/roof edges, corners/re-entrants/short facets, outer/inner relation boundaries, access geometry, occlusions, signs and yard objects.
- Left+right, top+bottom and four-corner products must remain the same homogeneous field or reconstruct the same canonical complete motif. Any invented slit, pane, bay, divider, patch or opening is a hard failure.
- Physical feature scale is unmeasured across the six evidence-bearing targets. Prototype scale must remain explicit and adjustable; no target may reach art acceptance or live attachment until exact-receiver scale review passes.

## Geometry-versus-texture boundary

Shallow, noncolliding render-only modules may eventually represent already observed complete openings or trim. They may not alter silhouette, height/story count, roof/parapet/eave projection, columns/recess depth, structural openings, ramps/stairs/rails, courtyard/wing geometry, footprint/rings, foundation/terrain, collision, navigation, spray eligibility/ownership, receiver topology, OSM data or generated bytes.

```text
before: eight exact generated wall/roof receivers use shared placeholder materials.
after:  every ID, ring, run, height, roof/silhouette, footprint, structural opening,
        foundation/terrain, collision/navigation/spray and generated contract remains;
        only independently observed, scale-reviewed, endpoint-mapped visuals attach.
```

## Prototype priority

1. `w34313564`: strongest three-side, side-specific material split with manageable 20-run topology.
2. `w291196370`: coherent siding identity and three complete opening families; protect short facets and hidden rear.
3. `w34313525`: strong two-side industrial opening evidence; keep irregular repair/eave/footprint conditions separate.
4. `w34313515`: high-salience two-side material/module study, but long perimeter and unmeasured cadence raise review cost.
5. `w34313520`: one-side pale field/bay study only; no wing or other-side transfer.
6. `r133351`: local region/material studies only until the 78-run outer/inner relation is reconciled.
7. `w1222514695` and `w1222720021`: stop; no prototypes until target-identifiable official evidence exists.

This order is a reversible production recommendation, not permission to generate, map, integrate or launch.

## Batch acceptance checklist

- [x] Eight exact sources/receivers/chunks/heights/runs/lengths are represented once.
- [x] Final observer facts, pano IDs/dates/directions, side bounds and contributor exclusions are preserved.
- [x] Two no-identifiable-coverage targets are reference-blocked without neighbor substitution.
- [x] Six evidence-bearing targets separate materials, complete modules, nonperiodic regions and unobserved sides.
- [ ] A later implementer records physical-scale calibration and proof for every candidate.
- [ ] A separate mapping pass binds only observed regions/modules to ordered run endpoints; this handoff maps no runs.
- [ ] Semantic repeat proof rejects every motif-changing edge/corner join.
- [ ] Independent art review separates standalone material/module, exact receiver and whole-object verdicts.
- [ ] Runtime work, if later authorized, preserves every geometry/physics/navigation/spray/source/generated invariant above.

## Current status

- **Reference-blocked:** `w1222514695`, `w1222720021`.
- **Bounded material/module prototype specification ready:** `w34313515`, `w34313520`, `w34313525`, `w34313564`, `w291196370`, `r133351`.
- **Architectural pattern tile ready:** none.
- **Exact placement/live attachment ready:** none.
- **Whole-object resemblance accepted:** none.
