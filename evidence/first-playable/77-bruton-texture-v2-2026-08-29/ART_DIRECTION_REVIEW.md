# Hawkins texture v2 — independent art-direction review

Date: **2026-08-29**  
Reviewer: `/root/hawkins_texture_v2_review`  
Stage: candidate source/proof review only; no texture was integrated or viewed on the exact Godot receiver.

## Verdict

**No candidate passes all application-stage hard gates. No candidate is ranked, selected, or advanced to receiver trial. The single correction budget is exhausted.**

The declared cell is one complete paired-window assembly (`W-P`) by one upper residential story. Every border must remain an uninterrupted homogeneous seam-safe field, and repetition must add no panel termination, jamb/frame fragment, balcony-like rail, or other undeclared motif. Numeric edge results are used only to reject.

| Candidate | Numeric edge screen | Semantic repeat | Border-field continuity | Material / facade resemblance | Albedo neutrality | 8x8 macro repetition | Candidate-stage overall |
|---|---|---|---|---|---|---|---|
| 01 | pass candidate screen | **fail** | **fail** | **fail** | **fail** | **fail** | **fail** |
| 02 | **fail** (X) | **fail** | **fail** | **fail** | **fail** | **fail** | **fail** |
| 03 | **fail** (X) | **fail** | **fail** | **fail** | **fail** | **fail** | **fail** |
| 04 correction | pass candidate screen | **pass** | **fail** | **fail** | **fail** | **fail** | **fail** |

Exact-receiver scale/UV behavior, changed-light response, whole-object resemblance, and overall integrated acceptance remain **unreviewed**.

## Candidate findings

### Candidate 01

- The complete paired window remains one-per-cell in the 3x3 and roll proofs; no slit window is synthesized. That is necessary but insufficient.
- The top and bottom borders are not homogeneous: fluted side fields, a smooth central field, and two panel-termination lines all reach the tile edge. Half-Y/XY rolls expose a horizontal join, while the 3x3 and macro proofs turn the smooth field into strong story-height vertical columns and synchronized horizontal bands. This violates the declared seam and panel-cadence grammar.
- Charcoal paired glazing and light fine-fluted cladding are directionally Hawkins-like, but the continuous smooth center columns are not the reference's broad fluted pier plus pale inter-story-band rhythm.
- Frame/reveal shadows, glass falloff, panel gradients, and rib light/dark striping are fixed in the albedo rather than neutral surface color.

### Candidate 02

- The left/right numeric screen fails (`MAE 0.0636301`, `RMSE 0.0646907`), and the half-X/XY proofs expose the join.
- Although one paired glazing unit remains per repeated cell, the side members extend below the glazing into a second lower rail. Together with the doubled horizontal bars, this reads as an undeclared balcony/frame assembly rather than the canonical `W-P` plus simple spandrel.
- The heavy, deep charcoal surround and balcony-like lower module diverge from the reference's slimmer window boxes, pale spandrels, and broad fluted piers.
- Strong recess shadows, rib shading, glass gradients, and rail shadows are baked into the albedo. The macro proof repeats the false rail as a dominant grid.

### Candidate 03

- The left/right numeric screen fails (`MAE 0.0310525`; threshold `0.03`), and the half-X/XY and macro proofs retain a vertical field discontinuity.
- One complete paired window remains inside every cell and no edge window is created. However, the pale panels above and below are enclosed by extra side returns/ledge lines, creating an undeclared frame-fragment/panel motif and a cadence beyond the canonical `W-P` plus homogeneous `S-H/P-F` fields.
- The small, squat opening and large blank fluted allocation read much sparser than Hawkins' tall oversized upper openings and local bay rhythm.
- Soft recess shadows, glass/frame gradients, and strongly fixed rib highlights prevent neutral-albedo passage. The 8x8 proof reads as a sparse cloned-window grid.

### Candidate 04 correction

- The numeric screen passes both axes (`X MAE/RMSE 0.0120295/0.0144214`; `Y 0.013739/0.0169552`).
- **Semantic motif topology passes:** exactly one complete `W-P` remains per tile in the 3x3 and every roll; no join creates, resizes, deletes, merges, or splits a window, and no extra jamb, rail, panel, door, vent, or balcony motif appears.
- **Border-field continuity fails:** the half-X/XY rolls expose a centered vertical value/phase discontinuity, while the half-Y/XY rolls and borderless 3x3 expose a low-contrast horizontal join/exposure band. The border pixels are numerically close, but the surrounding field is not visually phase-neutral.
- The tall paired glazing, charcoal frame, and silver-white fine fluting are directionally Hawkins-like. However, the opening occupies only roughly one third of the repeat width, the blank inter-row field is too expansive, and the pale Hawkins inter-story spandrel rhythm is absent; the 8x8 reads materially sparser than the owner reference.
- Broad background brightness variation, fixed rib light/dark response, frame/reveal shading, and glass falloff remain baked into the albedo. In the macro proof they synchronize into horizontal bands and broad vertical bay columns, so repetition is not subordinate.

## Production-method change after exhausted correction budget

Do not generate another whole-cell bitmap. The next method should be proposed as the following explicit asset-boundary change and approved before implementation:

```text
before: one generated square albedo encodes fluted cladding + paired window and repeats as the facade cell
after:  one deterministic homogeneous fluted material tile + one separately authored complete W-P/S-H facade module or atlas element placed explicitly per bay/story
```

Constructing the material and module separately makes the material edges exact, removes generated exposure bands, keeps the window/spandrel cadence explicit, and allows neutral albedo plus independent normal/roughness behavior. This is a proposed production change, not an implemented or accepted receiver solution.

## Evidence reviewed

- Owner reference: `/private/tmp/IMG_7170-reference.png` (`5712x4284`, SHA-256 `6b6a0f95902bd48c57c4f69b6bd7b97346c672d71c1b300d394170f6447db5cd`)
- Each of the four candidate source images, including the one permitted correction.
- For each candidate: borderless 3x3, boundary-overlay 3x3, half-X, half-Y, half-XY, and 8x8 macro proofs under `proofs/candidate-0N/` and `proofs/candidate-04-correction/`.
- Numeric values and proof hashes in each `proof-report.json`.

No annotated derivative was needed; candidate sources and proof images were not altered.
