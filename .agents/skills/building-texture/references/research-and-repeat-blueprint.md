# Web research and repeat blueprint

Read this reference before sourcing or generating a building texture. Research must identify the real target, the local surface material, and the architectural pattern before pixels are made.

## Source hierarchy and evidence labels

Use the strongest source that actually supports each claim:

1. Owner-supplied references for intended appearance and direct rejection evidence. Treat private files as local-only unless the owner explicitly authorizes upload or reuse.
2. Project-owned identity and receiver data for the exact in-game object, frozen source ID, asset path, and implementation contract.
3. Government, architect, and project-specific manufacturer sources for identity, massing, material system, measured dimensions, and product behavior.
4. Developer, property, engineer, or contractor sources for corroborating project facts.
5. Identified secondary field photographs for observations that primary sources do not show.
6. Generic manufacturer catalogs only for generic material behavior, never as proof that a named building uses that product.

Search snippets, unattributed images, mood boards, and model recollection are leads, not evidence. Record the URL/local path, page or section, checked date, supported claims, unsupported claims, reuse status, and whether anything was stored. Browsing does not authorize downloading.

Label every claim as one of:

- `verified_fact`: explicitly supported by a primary or authoritative source;
- `reference_observation`: visible in an identified image, but not measured;
- `production_inference`: a reversible art or implementation choice, which may have a precise implementation value without becoming source truth;
- `unknown`: not established and not safely bounded for the requested use.

## Region and motif method

1. Partition the facade into regions whenever material, orientation, motif family, spacing, base/roof condition, or cadence changes.
2. Inventory complete motifs, not fragments. Motifs can be ribs, panels, masonry units, openings, doors, vents, louvers, trim, bands, joints, balconies, or stains.
3. Record measured dimensions when authoritative. Otherwise preserve image-relative ratios and tolerances as observations. If implementation needs metre values, choose a plausible bounded range from receiver, human, door, story, and neighboring-motif cues; label the selected value `production_inference` and keep it adjustable.
4. Tokenize horizontal and vertical cadence when the reference establishes it. Otherwise record cadence as observed-local, inferred, irregular, or unknown rather than manufacturing survey evidence.
5. For a periodic asset, choose the smallest translation cell that reproduces the same tokens and dimensions. Rectangular cells are valid. If no true period exists, choose `module_atlas` or `unique_elevation` instead of requiring one.
6. Predeclare legal seams in homogeneous fields or verified unit boundaries. A motif-midline seam is legal only when both halves reconstruct the same canonical motif under an explicit contract. A complete module or finite elevation edge is a placement boundary, not automatically a tile seam.
7. Predict left+right, top+bottom, and four-corner products for every axis that claims repetition. The blueprint fails before generation if any claimed repeat product is unnamed, resized, duplicated, or deleted.

## Normalized research handoff

Emit a machine-readable YAML block with this shape. Add fields only when they change downstream decisions.

```yaml
schema_version: codex.building-texture-research/1
job:
  job_id: string
  checked_date: YYYY-MM-DD
  intended_use: string
  target_asset_kind: homogeneous_material_tile | architectural_pattern_tile | module_atlas | unique_elevation
  placement_goal: surveyed_reconstruction | recognizable_game_art

target:
  canonical_name: string
  local_object_ids: [string]
  identity_confidence: high | medium | low
  receiver_path: string | null

sources:
  - id: string
    authority: owner_reference | project | government | architect | manufacturer | developer | property | secondary
    url_or_local_path: string
    checked_date: YYYY-MM-DD
    page_or_section: string | null
    supports: [string]
    does_not_support: [string]
    image_reuse_permission: owner_private | not_needed | permitted | unknown
    stored_in_repo: false

reference_roles:
  identity_context: [source_id]
  massing: [source_id]
  pattern_region: [source_id]
  cadence_and_seams: [source_id]
  material_surface: [source_id]
  scale: [source_id]
  rejection_example: [source_id]

pattern_regions:
  - region_id: string
    local_scope: string
    periodicity: verified_periodic | candidate_periodic | nonperiodic | unknown
    must_not_share_tile_with: [string]

placement_inference:
  allowed: true | false
  basis: string
  confidence: high | medium | low | null
  candidate_receiver_regions: [string]
  protected_regions: [string]
  scale_range_m: {x_min: number | null, x_max: number | null, y_min: number | null, y_max: number | null}
  count_or_cadence_status: observed | inferred | irregular | unknown | null
  reversible: true | false
  survey_required_for_safety: true | false

motif_inventory:
  - motif_id: string
    kind: rib | panel | masonry_unit | opening | door | vent | louver | trim | band | joint | balcony | stain | other
    canonical_full_description: string
    dimensions_m: {width: number | null, height: number | null}
    ratios: {width_to_period: number | null, height_to_period: number | null, tolerance: string | null}
    evidence_status: verified_fact | reference_observation | production_inference | unknown
    may_cross_edge: true | false
    edge_composition_contract: string | null

motif_sequences:
  - region_id: string
    axis: horizontal | vertical | two_dimensional
    token_sequence: string
    evidence_status: verified_fact | reference_observation | production_inference | unknown

repeat_blueprint:
  region_id: string
  smallest_cell_status: verified | candidate | none | unknown
  period_tokens_horizontal: string | null
  period_tokens_vertical: string | null
  period_m: {x: number | null, y: number | null}
  cell_contents_full_motifs: [string]
  edge_fragments:
    left: [string]
    right: [string]
    top: [string]
    bottom: [string]
  edge_compositions_expected:
    left_plus_right: [string]
    top_plus_bottom: [string]
    corners: [string]
  legal_seam_zones: [string]
  forbidden_seam_zones: [string]
  fallback_if_not_proven: homogeneous_material_tile | module_atlas | unique_elevation

material_brief:
  surface_family: string
  base_color: string
  finish: string
  relief_direction_and_frequency: string
  roughness: string
  variation_and_weathering: string
  maps_requested: [albedo, normal_gl, roughness]
  maps_forbidden: [string]
  tile_scale_status: verified | bounded | production_inference | unknown
  tile_scale_m: {x: number | null, y: number | null}

excluded_architectural_features:
  - feature: string
    owner: geometry | facade_module | material_assignment
    reason: string

uncertainty:
  - unknown: string
    impact: string
    safe_fallback: string
    stop_if_required: true | false

hard_mismatch_gates:
  - scope: identity | repeat | geometry | module | material | evidence
    reject_if: string
    proof_required: string

research_verdict:
  ready_for_generation: true | false
  ready_for_placement_inference: true | false
  recommended_output_kind: homogeneous_material_tile | architectural_pattern_tile | module_atlas | unique_elevation | null
  blockers: [string]
```

Generation may begin when the handoff identifies one coherent region, distinguishes facts from observations and inferences, states a measured span or bounded calibration/inference plan, and predicts every boundary product applicable to the declared asset kind. Placement inference may begin when target and side/region identity are adequate, protected regions are explicit, and plausible containment can be tested; surveyed anchors, counts, cadence, and dimensions are not required unless safety or geometry integrity depends on them. A surface close-up cannot prove facade cadence, and a facade photograph cannot substitute for a neutral material sample.
