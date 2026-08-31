# Batch 04 facade reference index and implementation priority handoff

Checked: **2026-08-29**  
Mode: **research/specification only**  
Authoritative observation ledger: [`BATCH_04_STREETVIEW_OBSERVATIONS.md`](BATCH_04_STREETVIEW_OBSERVATIONS.md)

## Cohort verdict

All eight frozen targets have exact standalone direct wall/roof receivers. Official observations make bounded prototype work defensible for seven targets, but **none is ready for live receiver attachment**. Education Center 29B is completely screened. Dormitory 369 has a five-tier-versus-`6 m` massing conflict. 449 H and 810 D are historical-only references with current clearance/enclosure conflicts. 850 H and Bldg 461 permit only conservative partial material/module work. 1318 Gateview and 1212 Mariner support distinct target-specific module families, pending exact unit/run mapping.

## Exact receivers, evidence state and priority

| Order | Target/spec | Receiver / chunk | Frozen generated contract | Evidence-backed implementation subset | Attachment blocker |
|---:|---|---|---|---|---|
| 1 | [Education Center 29B / 768 Avenue H](EDUCATION_CENTER_BUILDING_29B_REFERENCE_SPEC.md) | `building:w34313523:wall` / `x_0__z_-1` | `3 m / 1`; 20 runs / `163.385 m`; wall/roof `40/8` tri | **none** | March/Sep 2025 perimeter enclosure; facade unseen; current existence unknown |
| 2 | [Job Corps Dormitory 369 / 275 California Avenue](JOB_CORPS_DORMITORY_BUILDING_369_REFERENCE_SPEC.md) | `building:w291189926:wall` / `x_0__z_1` | fallback `6 m`; 72 / `487.830 m`; `144/32` tri | warm/blue/green materials and observed-side bay atlas | five visible tiers conflict with fallback height; other sides/endpoints and 72-run map unknown |
| 3 | [449 Avenue H](449_AVENUE_H_REFERENCE_SPEC.md) | `building:w34313512:wall` / `x_0__z_0` | `10 m / 2`; 20 / `226.094 m`; `40/2` tri | **May 2011 historical** siding/trim and two-tier modules | Sep 2025 cleared lot; Google 395/440 vs frozen 449; temporal choice/endpoints absent |
| 4 | [850 Avenue H](850_AVENUE_H_REFERENCE_SPEC.md) | `building:w34313546:wall` / `x_0__z_-2` | `4 m / 1`; 25 / `237.592 m`; `50/11` tri | conservative tan/teal swatches and provisional high-window pair | medium identity; container occlusion; long sides/endpoints/map unknown |
| 5 | [810 Avenue D](810_AVENUE_D_REFERENCE_SPEC.md) | `building:w96698660:wall` / `x_-1__z_-1` | `4 m / 1`; 6 / `51.994 m`; `12/2` tri | **May 2011 historical** materials/front modules | March 2025 enclosure; current existence, other sides and six-run mapping unknown |
| 6 | [Bldg 461](BLDG_461_REFERENCE_SPEC.md) | `building:w34313569:wall` / `x_-1__z_-4` | `8 m`; 27 / `207.182 m`; `54/10` tri | neutral gray/end swatches only | medium distant identity; suspected details unusable; sides/endpoints/27-run map unknown |
| 7 | [1318 Gateview Avenue](1318_GATEVIEW_AVENUE_REFERENCE_SPEC.md) | `building:w95934092:wall` / `x_-3__z_-2` | `6 m / 2`; 26 / `163.714 m`; `52/14` tri | target-specific siding/trim/roof and front/rear/end unit modules/sequence | exact units-to-runs, small returns and hidden rear-lower regions |
| 8 | [1212 Mariner Drive](1212_MARINER_DRIVE_REFERENCE_SPEC.md) | `building:w96215649:wall` / `x_-1__z_-3` | `6 m / 2`; 28 / `115.696 m`; `56/16` tri | target-specific materials and front/rear/end unit modules/sequence | exact units-to-runs, short facets/notches and opposite end |

Run lengths above are generated visible-wall sums; each target spec retains serialized-perimeter deltas, base/top/foundation elevations, complete normal groups, mesh counts and exact runtime path. One Godot unit is one metre.

## Recommended implementation order

1. **1318 Gateview and 1212 Mariner** — strongest current coverage and complete target-specific front/rear vocabularies. Author material/module libraries independently; do not attach before ordered endpoint maps.
2. **Dormitory 369** — author prototype materials/modules only. Stop before vertical layout or attachment; five tiers vs fallback `6 m` requires a separate approved geometry decision.
3. **449 H and 810 D** — author only if the project explicitly wants the May 2011/frozen-era lifecycle. Keep all outputs labelled historical and unattached.
4. **850 H and Bldg 461** — conservative swatches/provisional study only; no unique elevation.
5. **Education Center 29B** — no generation; retain placeholder until facade/current-existence evidence exists.

## Temporal, identity and reuse controls

- Current and historic official panoramas are separate evidence states. May 2011 cannot silently stand for current 2025.
- 449 H's footprint match is medium-high but address confidence medium because Google labels 440/395; 850 H and Bldg 461 also remain medium identity.
- Google `1327` in the Gateview front view labels the opposite building, not `w95934092`.
- 1318 and 1212 share a broad housing-era palette, not an asset family. 1318 has a pronounced multi-bay porch canopy; 1212 does not. Materials, modules and layouts remain target-specific.
- 29A, site containers, redevelopment fences, repair patches, broken panes, trellises, utilities and contributor panoramas are forbidden appearance sources.

## Shared receiver and seam contract

- Every wall currently uses `building_wall -> plaster_grey_04`; every roof uses `building_roof -> bitumen`. These are placeholders, not appearance evidence.
- Walls are opaque `world_solid` and sole spray receivers; roofs are opaque colliders/non-spray. There are no shared-part walls in this cohort.
- U restarts on every generated run and V is world y/10. Neither is an architectural phase signal.
- Legal seams: uninterrupted homogeneous field, verified complete repeat-cell boundary, complete module/unit boundary, or exact unique-elevation endpoint.
- Forbidden seams: opening/motif interior, canopy/eave/ledge/end transition, small/reentrant return, corner/notch, receiver top/foundation, generated U reset, unobserved region and cross-target propagation.
- Exact ordered source-edge/run reconciliation precedes placement. Orientation totals are diagnostics only.

## Geometry boundary and representative before -> after

Only evidence-backed PBR fields and complete shallow noncolliding render modules are facade-owned.

```text
before: each target is its exact generated opaque wall/roof receiver using shared
        placeholders, with recorded massing, topology, collision and spray roles.

after:  those exact IDs, paths, footprints, heights/stories, roofs/silhouettes,
        structural openings, runs, foundations, terrain, collision, navigation,
        spray roles, OSM records and generated bytes remain unchanged; only the
        evidence-bounded prototype subsets above exist, unattached until mapped.
```

Any story/height, removed-building/current-lifecycle or structural-opening change is outside facade scope and requires a separate representative before -> after plus explicit approval.

## Cohort executable acceptance checklist

- [ ] Every spec's Google URL, pano ID, actual viewpoint, displayed month/year, direction and coverage matches the observer ledger.
- [ ] Current, historical, cleared/redeveloped, enclosed/occluded and unobserved states remain explicit and separate.
- [ ] All eight IDs/paths/chunks/heights/levels/runs/lengths/mesh counts match frozen inventory/generated evidence.
- [ ] All four output classes are classified per target with smallest-repeat/non-repeat reasoning and scale confidence.
- [ ] Only the implementation subset in the table is generated; placement-blocked and evidence-blocked content remains absent.
- [ ] Complete motifs survive atlas edges; neutral materials contain no baked light, photographic reflection or displacement.
- [ ] Exact ordered endpoints, not U resets/normals, control any eventual placement.
- [ ] 1318/1212 remain separate; 29A/containers/damage/contributor imagery never transfer.
- [ ] Dormitory's five-tier conflict triggers a hard stop before attachment or massing edit.
- [ ] Visual children contain no collider/navigation/spray ownership and preserve every source/generated/massing invariant.
- [ ] Independent reviewer accepts identity, temporal scope, visual fidelity, seam proof and receiver scope before attachment.

## Final readiness

- **Prototype implementation-ready:** Dormitory 369; historical-only 449 H; conservative 850 H; historical-only 810 D; conservative Bldg 461; 1318 Gateview; 1212 Mariner.
- **No facade output ready:** Education Center 29B.
- **Live attachment ready:** none.
