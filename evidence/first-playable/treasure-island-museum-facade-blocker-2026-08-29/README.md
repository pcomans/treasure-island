# Treasure Island Museum / Building One facade integration blocker

Status: **blocked before runtime integration; no facade assets or attachment authored**  
Target: source `r16681702`; wall receiver `building:r16681702:wall`

The existing local receiver is mechanically clear: one opaque `world_solid` spray wall with `440` vertices, `220` triangles and `110` serialized runs. Runs `0..99` form the outer ring and `100..109` the inner ring. The locally recorded observation handoff identifies broad public-facing orientation groups, but it does not reconcile those semantic public elevations to exact outer-ring run endpoints.

Orientation buckets and ring order alone cannot distinguish the intended curved public subchains from adjacent outer runs at high confidence. The reference specification explicitly blocks unique-elevation placement until that endpoint mapping exists. Guessing from nearest normal would risk wrapping complete motifs across unobserved runs, so this cohort makes no Museum material, module, layout, scene, builder branch, or screenshot.

The Isle House focused contract builds `building:r16681702:wall` as a spillover control and asserts that it has no facade child. Generated data, wall collision, spray eligibility and appearance therefore remain unchanged.

## Reconciliation evidence hashes

```text
79fe7b7cc49ea5e40a8611313defacb07ec23fb1a1a711822e0378b8cc32ac5a  discovery/facades/TREASURE_ISLAND_MUSEUM_BUILDING_1_REFERENCE_SPEC.md
aee175db92ec39b0ae4f0e2adfe286f297c93d303fee4249cb6f03c25ae12b2a  discovery/facades/NEXT_COHORT_STREETVIEW_OBSERVATIONS.md
461bf7f72355bf8b5b3fa8e09b88154c80a40e9d3b0823c10f914c234dbc68e4  discovery/FACADE_RECEIVER_INVENTORY.json
dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce  generated/world/chunks/x_-1__z_2.json
```

Unblock condition: a reviewed local handoff that maps each observed public elevation to explicit outer-ring start/end run indices and endpoints, without requiring footprint/massing changes or an unapproved external resource.

