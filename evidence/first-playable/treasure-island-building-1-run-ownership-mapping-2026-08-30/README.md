# Building 1 exact-run ownership evidence

Status: **mapping prerequisite complete; no placement or art acceptance**  
Target: `r16681702` / `building:r16681702:wall`

This evidence reconciles the three approved `B1-SV01..03` observer records to the current generated Building 1 plan. It proves exact run/component ownership and bounded candidate public regions. It contains no Street View pixels and does not claim a real module coordinate, count, cadence, sequence, completed elevation, or whole-building resemblance.

## Outputs

- `plan-view.svg` is the deterministic vector plan generated directly from the frozen wall vertices/normals. It labels all `110` runs, region colors, observer positions, and headings.
- `plan-view.png` is a `1400x980` review raster derived from the SVG with ImageMagick `7.1.2-30`, Arial, Q16-HDRI.
- `visibility-diagnostic.json` records seven samples per run for outward-side, recorded-FOV, and plan-occlusion tests.
- The canonical machine mapping is `../../../discovery/facades/TREASURE_ISLAND_BUILDING_1_RUN_OWNERSHIP.json`.

No Godot/native evidence was captured because this prerequisite examines source/run ownership only. A native render would not add observation-to-plan truth and could be mistaken for placement approval.

## Reproduction

From the repository root:

```text
node tools/build_building_1_run_ownership_mapping.mjs --write
node tools/build_building_1_run_ownership_mapping.mjs
node tools/test_building_1_run_ownership_mapping.mjs
magick -font /System/Library/Fonts/Supplemental/Arial.ttf -background white -density 144 evidence/first-playable/treasure-island-building-1-run-ownership-mapping-2026-08-30/plan-view.svg -resize 1400x980 -strip evidence/first-playable/treasure-island-building-1-run-ownership-mapping-2026-08-30/plan-view.png
```

Run `shasum -a 256 -c checksums.sha256` from this evidence directory.

## Inspection findings

- The plan is nonblank and legible at `1400x980`; all three observer positions/headings and all run labels are present.
- Runs `0..96` form the main outer component; `97..99` form a tiny separate union sliver; `100..109` form the red/dashed inner ring.
- The inner ring lies around the separately generated tower footprint and is not visually merged with the public outer mapping.
- The broad public curve `21..51`, cyclic north-end candidate `93..96,0..8`, and observed south faces `52..56,58,60` are distinct from rear/east and occluded-return scope.
- Visibility results are diagnostic only. Semantic family statements remain bounded by the approved textual observation ledger.

## Integrity boundary

The generator pins the generated Building 1 chunk, separate tower chunk, frozen OSM snapshot, Building 1 reference spec, observation ledger, independent standalone review, and accepted standalone registry. The original standalone evidence checksum remains independently sealed and unchanged.

The exact receiver is still live with its prior shared material only. This package creates no Godot resource, scene, adapter, attachment, collision, navigation, spray, generated-data, or runtime change.
