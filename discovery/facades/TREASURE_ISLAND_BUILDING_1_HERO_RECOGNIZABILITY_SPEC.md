# Treasure Island Building 1 hero recognizability specification

Checked: **2026-09-04**  
Runtime targets: **`r16681702`** and separately reviewable nested source **`w1222720021`**  
Status: **bounded implementation authorized; visual acceptance pending independent original-detail review**

## Purpose and truth boundary

This pass replaces the visibly incorrect uniform-height runtime placeholder with a deterministic exterior-only recognizability proxy. It does not alter the frozen OpenStreetMap source data, the exact horizontal outer footprint, the octagonal tower plan, or either source identity. It does alter runtime vertical massing and its matching collision as a reversible production inference.

The pass makes **no** surveyed-height, surveyed-cadence, completed-elevation, interior, or as-built claim. No source photograph is copied, stored, textured onto geometry, or shipped. The current implementation remains pending independent art review.

## Authority and provenance

- Frozen local horizontal authority: `generated/world/chunks/x_-1__z_2.json` for `building:r16681702:*` and `generated/world/chunks/x_0__z_2.json` for `building:w1222720021:*`.
- National Park Service, National Register of Historic Places registration **08000081**, Section 7 pp. 5-7: <https://npgallery.nps.gov/NRHP/GetAsset/NRHP/08000081_text>.
- Treasure Island Museum, “Building the Bay Bridge & Treasure Island”: <https://www.treasureislandmuseum.org/youarehere/building-the-bay-bridge-&-treasure-island>.
- Treasure Island Museum sculpture context: <https://www.treasureislandmuseum.org/sculptures-and-island> and <https://www.treasureislandmuseum.org/spirit-of-india>.

The NPS description establishes the recognition grammar used here: a central four-story stepped section; two three-story wings surrounded by two-story elements; eleven two-story 18-light front windows; a full cantilevered stucco canopy; a rusticated projecting first floor; three glazed-bronze triple-door groups; eight upper and seven lower window bays per wing; projecting end compositions with paired two-story 20-light windows, flanks, and airplane reliefs; and an octagonal control tower on a wider platform with a balustrade and pyramidal raised-seam roof.

## Exact preserved geometry and identity

- Building wall/roof remain keyed `building:r16681702:wall` and `building:r16681702:roof` with source `r16681702`.
- Tower wall/roof remain keyed `building:w1222720021:wall` and `building:w1222720021:roof` with source `w1222720021`.
- The first 100 outer wall runs and ten relation inner-ring runs are rebuilt directly from the frozen Building 1 receiver coordinates.
- The two-story roof uses the frozen relation roof triangulation at its inferred new elevation.
- The tower glazing uses every exact `w1222720021` wall run at its inferred rooftop elevation. The wider platform is explicitly inferred; the tower plan itself is not rescaled.
- Every visible replacement has congruent runtime collision. Wall bodies retain eligible spray-receiver ownership; roof bodies do not.

## Reversible vertical assumptions

All values below are game-art inference in metres in the project coordinate system:

| Element | Runtime value |
|---|---:|
| two-story roof | `y=14.75` |
| three-story wing roof | `y=20.25` |
| four-story center roof | `y=26.281` |
| north/south tier inward depth | `11.0` |
| central tier inward depth | `25.0` |
| tower platform / glass base | `y=27.35` |
| tower glass top | `y=32.65` |
| pyramidal roof peak | `y=35.4` |
| inferred platform scale around exact tower plan | `1.28` |

Run-chain ownership and the complete machine-readable schedule are in `game/resources/facades/building_1_hero_model.json`. These values should be revised if better dimensional evidence becomes available; they must never be restated as measurements.

## Runtime and review gates

- Generic slab/tower mesh and collision construction must be intercepted before it occurs; no hidden legacy slab collision may remain.
- Four generated records remain four independently keyed runtime objects and four collider/shape owners.
- Wall and roof geometry must be deterministic under repeated construction.
- Spray must resolve on both wall identities and must not resolve on either roof identity.
- A player must be able to land on exposed two-, three-, and four-story roofs and the tower platform/roof without invisible legacy planes.
- Visual acceptance requires same-pose before/after frames at ordinary third-person height, north and south end views, a front/tower silhouette view, changed light, and a separate tower review. Executor self-acceptance is prohibited.
