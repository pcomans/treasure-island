# Decision Log

## States

- `explored` — documented as an option; not recommended or approved
- `proposed` — submitted for explicit owner approval
- `approved` — explicitly chosen by the owner
- `rejected` — explicitly declined by the owner

## Approved decisions

| Date | State | Decision | Evidence |
|---|---|---|---|
| 2026-08-27 | approved | This is a private personal hobby project, not intended for public release. | Owner statement |
| 2026-08-27 | approved | The playable world covers Treasure Island only. | Owner answer |
| 2026-08-27 | approved | The setting represents present day. | Owner answer |
| 2026-08-27 | approved | Arcade-style vehicle handling is acceptable. | Owner answer |
| 2026-08-27 | approved | Players can spray-tag eligible building surfaces in the spirit of Half-Life 1's spray interaction. | Owner answer |
| 2026-08-27 | approved | First-playable success means the island is recognizable and the game is playable. | Owner answer |
| 2026-08-27 | approved | Model Treasure Island at island scale: complete terrain/shoreline, roads, major public spaces, and known exterior building footprints/massing; do not model individual apartments or interiors. | Owner clarification |
| 2026-08-27 | approved | Freeze the latest available OpenStreetMap extract as the island-layout baseline. Do not reconcile it against a separate real-world currentness inventory; missing height data may use simple exterior massing. | Owner clarification |
| 2026-08-27 | approved | Recognizable Treasure Island and a playable game are the co-primary outcomes. No additional broad priority-weighting exercise is required. | Owner clarification of answer 5 |
| 2026-08-27 | approved | Use a third-person player perspective for the current milestone. | Owner answer |
| 2026-08-27 | approved | Do not spend effort identifying or reproducing real fenced/private access; treat outdoor OSM snapshot space as generally traversable. | Owner answer |
| 2026-08-27 | approved | Start with simple exterior building massing across the full island snapshot. | Owner answer |
| 2026-08-27 | approved | Defer cars and arcade driving; the current first playable is walking and running. | Owner answer |
| 2026-08-27 | approved | Use one predefined spray tag in the current milestone. | Owner answer |
| 2026-08-27 | approved | Target the owner's Mac with mouse and keyboard only. | Owner answer |
| 2026-08-27 | approved | Use San Francisco as non-playable billboard background scenery. | Owner answer |
| 2026-08-27 | approved | Use simple non-playable polygonal scenery for Yerba Buena Island and the Bay Bridge. | Owner's affirmative background-scenery answer, interpreted under the later KISS instruction |
| 2026-08-27 | approved | Leave detailed third-person camera behavior and shoreline behavior open for now. | Owner answer |
| 2026-08-27 | approved | Use Godot 4.7.2 standard/GDScript with Forward+, one-meter local coordinates, an offline `osmium` + Node conversion step using pinned `polygon-clipping@0.15.7` and `earcut@3.2.3`, ID-traceable generated geometry, a project-owned `CharacterBody3D` walk/run controller with a pivot -> `SpringArm3D` -> `Camera3D` rig, projected `Decal` spray, and a native private Mac build. Official Godot guidance and the Platformer 3D demo are references only; no camera/controller add-on is included. The exact free official Godot/templates and pinned local package downloads are authorized under the install log and trust plan. | Owner replied “approved” to the exact bundle; `discovery/APPROACH_PROPOSAL.md`; `discovery/TRUSTED_INSTALL_PLAN.md` |
| 2026-08-28 | approved | Start the player at the ferry arrival on the land-side Treasure Island approach, safely inside the playable boundary and facing inland. Keep the offshore floating ferry platform non-playable under the Treasure-Island-only boundary. | Owner request: “Can the player start at the ferry terminal?”; frozen OSM terminal/access geometry |
| 2026-08-28 | approved | Add a simple unlimited jetpack: **before:** the player had no jump or vertical traversal; **after:** holding `Space` continuously lifts the player, releasing it produces a slow controlled descent, and horizontal movement remains available in the air. No fuel, inventory, or new asset is required. | Owner request: “give the player a jet pack… float up when pressing space… endless air jump… float down only slowly” |
| 2026-08-28 | approved | Use one Epic account across the two approved model-library sites: Sketchfab for specific real-world/community models and Fab for game-ready assets. Do not require a Trimble/3D Warehouse or other marketplace account; use suitable account-free libraries to fill gaps. | Owner clarified that Sketchfab and Fab both use the same Epic account and that model sourcing is unblocked. |
| 2026-08-28 | approved | Replace the thin polygonal western Bay Bridge placeholder with the non-colliding Sketchfab `Baybridge-western-span` GLB by cdr420 (CC BY 4.0). **Before:** the western span is part of an open, floating polygon sheet. **After:** the premade recognizable western suspension span is placed as visual-only context; Yerba Buena Island and the modern eastern span remain unchanged for now. | Owner instruction: “Stick it… importing it is good enough.”; `third_party_staging/bay_bridge/PROVENANCE.md` |
| 2026-08-28 | approved | Solidify Yerba Buena Island as simple non-playable context. **Before:** its validated top rendered as an open sheet floating above the water. **After:** retain that top, add non-colliding sides down to the waterline, and add one low-poly hill using the frozen `98 m` elevation cue; do not change the playable Treasure Island or frozen/generated OSM contract. | Owner reported the floating-polygon defect and asked to keep the fix simple; refreshed rendered evidence in `evidence/first-playable/ybi-solid-rendered/`. |
| 2026-08-28 | approved | Replace the flat/synthetic terrain with bounded USGS 3DEP bare-earth elevation for both islands. **Before:** playable Treasure Island ground and overlays assume `y=0`, YBI uses a round synthetic mound and dark skirt, and the coarse eastern bridge deck reads nearly black. **After:** use a modest downsampled USGS surface clipped to the existing OSM shorelines; OSM remains authoritative for horizontal geometry and complete feature coverage; roads/areas follow terrain; buildings receive stable level bases; spawn, recovery, route anchors, shoreline collision, and tests adopt terrain height; YBI remains non-playable/non-colliding; the eastern deck receives a light-concrete treatment. | Project lead presented this exact before → after change after locating the official 2023 one-meter `CA_SanFrancisco_B23` DEM; owner replied “yes.” |
| 2026-08-30 | approved | Prioritize recognizable facade composition in ordinary third-person gameplay over survey-level placement precision for this private hobby project. **Before:** complete reference-derived facade modules could remain unplaced unless exact real-world anchors, counts, cadence, and dimensions were established, leaving Building 1 with essentially a color change. **After:** once the target, observed side/region, motif family, and generated host geometry are adequately identified, agents may arrange complete modules using bounded, reversible `production_inference`; unmeasured values remain explicitly non-surveyed and as-built fidelity is unclaimed. Exact receiver ownership, protected regions, complete motifs, physical plausibility, geometry/physics integrity, independent art review, source privacy, and resource approvals remain mandatory. | Owner: “recognizability over surgical precision” and explicit authorization for a Building 1 recognizability-first retry. |

## Explored or proposed decisions

| Date | State | Decision | Evidence |
|---|---|---|---|
No implementation decisions remain proposed in this table.

Research agents must not add decisions here; they report option families in their owned deliverables for lead synthesis.

Godot approach approved by the owner on 2026-08-27.
