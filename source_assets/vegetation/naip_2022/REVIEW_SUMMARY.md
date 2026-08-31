# NAIP 2022 tree annotation candidate review

This is a review-only, hobby-scale candidate inventory of 80 visually distinct mature tree crowns and deliberate rows on Treasure Island. It is source data, not generated-world or runtime placement data.

## Counts

| Coarse type | Count |
| --- | ---: |
| palm | 0 |
| conifer | 0 |
| broadleaf | 58 |
| unknown | 22 |

| Confidence | Count |
| --- | ---: |
| high | 51 |
| medium | 29 |
| low | 0 |

| Review cell | Candidates |
| --- | ---: |
| tile-00 | 1 |
| tile-01 | 7 |
| tile-02 | 0 |
| tile-03 | 0 |
| tile-04 | 12 |
| tile-05 | 11 |
| tile-06 | 5 |
| tile-07 | 10 |
| tile-08 | 5 |
| tile-09 | 5 |
| tile-10 | 5 |
| tile-11 | 11 |
| tile-12 | 0 |
| tile-13 | 0 |
| tile-14 | 8 |
| tile-15 | 0 |
| tile-16 | 0 |
| tile-17 | 0 |
| tile-18 | 0 |
| tile-19 | 0 |

## Method

- Inspected every one of the 20 lossless review cells at original detail.
- Marked integer crown-center pixels manually; GeoJSON positions are deterministic pixel-to-WGS84 conversions over the exact export bbox.
- Used only 'palm', 'conifer', 'broadleaf', or 'unknown'. Rounded, visually clear mature crowns are 'broadleaf'; small or ambiguous forms are 'unknown'. No crown was strong enough in this natural-color crop to label palm or conifer without overclaiming.
- Omitted shrubs, ornamental grasses, tiny seedlings, hidden crowns, and most ambiguous canopy fragments.
- Did not consult or copy current generated vegetation placements.

## Limitations

- The imagery is a snapshot from 2022-05-18 and does not establish current 2026 presence.
- Points estimate visible crown centers, not surveyed trunk positions. Tall crowns may be displaced by view geometry, and overlapping canopy/shadow lowers confidence.
- Natural-color 0.6 m imagery is suitable for coarse crown form, not botanical species identification. Zero palm/conifer labels means “not safely distinguished here,” not “absent from the island.”
- Construction, demolition, leaf condition, building shadow, and the western source seam can hide trees.
- This candidate set prioritizes mature, visually distinct crowns and repeated rows; it is deliberately incomplete.
- The separate validator proves containment and rejects point intersections with the existing world’s serialized road and building surfaces. That is a consistency screen, not a claim that the frozen OSM inventory exactly matches the 2022 photo.
- Thirty otherwise visible-crown marks that intersected those surfaces were omitted without snapping; their original IDs and exact rejection evidence remain in 'tree_annotations_rejection_audit.geojson'.

## Files

- 'tree_annotations_candidate.geojson': canonical, deterministically sorted candidate points.
- 'treasure_island_footprint.geojson': existing generated-world Treasure Island boundary converted to WGS84; no YBI polygon.
- 'tree_annotations_review.svg' and 'tree_annotations_review.png': visual review aids.
- 'tree_annotations_rejection_audit.geojson': 30 omitted marks with exact surface-intersection reasons; not accepted candidates.
- 'validation_report.json': persisted result from the independent deterministic validator.
- 'naip_vs_generated_vegetation_review.svg' and '.png': post-acceptance source comparison; never annotation or runtime input.
- Staged source imagery and review cells: 'third_party_staging/naip_2022_treasure_island/' (export-excluded).
