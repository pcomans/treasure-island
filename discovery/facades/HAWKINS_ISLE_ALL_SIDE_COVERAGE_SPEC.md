# Hawkins + Isle House high: all-side facade coverage specification

**Status:** evidence-bounded implementation handoff; no runtime or massing change authorized

**Prepared:** 2026-08-29

**Targets:** Hawkins `w1249412093`; Isle House high part `w1282547786` of parent `w1249412094`

**Explicit exclusion:** Isle House low part `w1282547787` remains separate, unknown, and unchanged.

## Owner acceptance and the remaining question

The owner playtested the current Hawkins and Isle House high pilots on 2026-08-29 and said they **“look really good”**, then asked why only one side is decorated. Treat this as:

- acceptance of the current visual direction and the already accepted observed-side facades;
- identification of an all-side coverage gap, not permission to invent unobserved elevations;
- no change to massing, collision, navigation, terrain, footprints, spray receivers, roofs, accepted front-facade layouts, or the Isle House low part.

The answer is evidence scope: the pilots deliberately put complete architectural modules only on directly observed elevations, while unobserved or only partially observed sides remained material-only or untouched. This specification closes the safe **homogeneous material-field** gap and identifies one newly observed Isle House high elevation that can support a later side-specific module layout. It does not authorize asset creation or attachment by itself.

## Evidence classes used here

- **Visible fact:** directly visible in an admissible reference.
- **Generated fact:** read from the frozen generated record or current accepted runtime contract.
- **Production inference:** mapping a visible elevation to a generated normal/run chain, or choosing a conservative field fallback. It is not a survey/as-built fact.
- **Unknown:** not supported by admissible evidence; no module may be invented from it.

Official Google imagery was observed in-place only. No imagery was downloaded, saved, captured, copied, redistributed, uploaded, or committed. Contributor and interior panoramas were excluded.

## Frozen receiver and accepted-result ledger

| Target | Exact live receiver | Authoritative generated record | Accepted runtime state that must remain unchanged |
| --- | --- | --- | --- |
| Hawkins | `building:w1249412093:wall` | `generated/world/chunks/x_-1__z_1.json` | Hawkins-only stepped mass; 20 source foundation runs become 22 outer runtime quads plus one exposed step quad; accepted WSW/SE fields and modules; ENE/NNW/step material-only |
| Isle high | `building-composite:w1249412094:w1282547786:wall` | `generated/world/chunks/x_-1__z_2.json` | exactly 13 wall runs / 26 triangles; current facade child fields on runs `5..9`; complete modules only on runs `5..7`; render-only |
| Isle low, excluded | `building-composite:w1249412094:w1282547787:wall` | `generated/world/chunks/x_-1__z_2.json` | separate receiver; no Isle-high facade attachment; unchanged |

Accepted baselines reviewed for this handoff:

- `discovery/facades/HAWKINS_77_BRUTON_REFERENCE_SPEC.md`
- `discovery/facades/HAWKINS_MASSING_IMPLEMENTATION_SPEC.md`
- `discovery/facades/ISLE_HOUSE_39_BRUTON_REFERENCE_SPEC.md`
- accepted Hawkins facade-correction and massing evidence/reviews/verdicts under `evidence/first-playable/`
- accepted Isle House high pilot evidence/review/verdict under `evidence/first-playable/`
- current layouts `game/resources/facades/hawkins_77_bruton_layout.json` and `game/resources/facades/isle_house_39_bruton_high_se_layout.json`
- current facade scripts/scenes/materials and the exact attachment path in `game/scripts/world/world_chunk_builder.gd`.

This handoff does not supersede the accepted layout hashes or deterministic signatures. Any future implementation must first refresh its expected hashes from the then-current accepted files and prove that unrelated accepted results remain unchanged.

## Official reference observation ledger

### Hawkins

| ID | Exact request URL | Resolved panorama / actual viewpoint | Displayed date | Direction and admissible coverage | Result |
| --- | --- | --- | --- | --- | --- |
| `H-SV-SE-01` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8191991,-122.3715368&heading=311.09&pitch=0&fov=75` | `CqLfgqkDJF4LkB8NhgB1NQ`; `37.8191991,-122.3715368` | Sep 2025 | view northwest from Bruton/Seven Seas context; accepted SE address elevation, mapped to runs `7..9` | visible fact plus high-confidence footprint mapping |
| `H-SV-SE-02` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.81983,-122.37150&heading=240&pitch=7&fov=75` | `c4GjFTeMKRn-SoqwN08OSQ`; `37.8198333,-122.3715781` | Sep 2025 | view southwest from Seven Seas Avenue; additional oblique of the same SE elevation/window grammar | no new ENE/NNW face |
| `H-SV-W-TRY` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8197,-122.3725&heading=120&pitch=5&fov=75` | no official panorama | checked 2026-08-29 | requested east/southeast toward the west side | no admissible coverage |
| `H-SV-N-TRY` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82010,-122.37192&heading=175&pitch=5&fov=75` | official coverage unavailable; Google offered contributor pano `CIHM0ogKEICAgICpvKmlXA` | contributor date Jul 2023 | requested south toward the north side | contributor source excluded |
| `H-SV-W2-TRY` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.81945,-122.37260&heading=85&pitch=5&fov=75` | official coverage unavailable; Google offered contributor/interior pano `CIHM0ogKEICAgICnnJmv8wE` | contributor date Sep 2024 | requested east toward the west side | contributor/interior source excluded |

The accepted owner-private WSW photograph was also re-used only through its existing project evidence description. Its capture date is not asserted. It directly supports the accepted WSW runs `0..6` but is not redistributed here.

**Hawkins coverage conclusion:** WSW and SE remain observed. The new official boundary check extends only the SE oblique. ENE and NNW have no admissible direct official coverage; the exposed step is generated geometry, not a photographed exterior elevation. No new Hawkins architectural module is authorized.

### Isle House high

| ID | Exact request URL | Resolved panorama / actual viewpoint | Displayed date | Direction and admissible coverage | Result |
| --- | --- | --- | --- | --- | --- |
| `I-SV-SE-01` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8189914,-122.371764&heading=285&pitch=25&fov=90` | `EDHxU1WC8Nn_wsRU82dC6Q`; `37.8189914,-122.371764` | Sep 2025 | west/northwest toward the accepted SE address elevation and partial ENE return | runs `5..7` direct; runs `8..9` partial/material-level |
| `I-SV-SW-01` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.81860,-122.37258&heading=45&pitch=10&fov=75` | `NO1BZPQbHhPLhsZ-wCqKpw`; `37.8186315,-122.3725511` | Sep 2025 | northeast from 3rd Street; inspected at heading 45 and 20 | direct exterior coverage of high runs `0..4` |
| `I-SV-W-01` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.81890,-122.37272&heading=90&pitch=10&fov=75` | `4TPHVLYevxQyWZaEMMdG6Q`; `37.8188731,-122.3727111` | Sep 2025 | east from 3rd Street; also inspected at heading 78, pitch 30, FOV 90 | complete context for runs `0..4`; oblique upper context for shared western face, especially run `11` |
| `I-SV-N-TRY` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.81918,-122.37217&heading=180&pitch=25&fov=90` | official coverage unavailable; Google offered contributor/interior pano `CIABIhAGbzzgih_etGfTgyMACub8` | contributor date Mar 2025 | requested south toward shared/northern upper faces | contributor/interior source excluded |

**Isle high coverage conclusion:** runs `0..4` are newly directly observed in official September 2025 imagery. Runs `5..7` remain the accepted directly observed SE address elevation. Runs `8..9` remain partial. Run `11` has oblique upper-face evidence sufficient for material identity and window-family presence, but not for deterministic run-local count or phase. Runs `10` and `12` are not isolated. No official direct north view was available.

## Hawkins authoritative run map

Coordinates are world XZ metres. Normals are the generated outward XZ normals; side names are established normal groups, not semantic frontage claims. All rows are `source_exterior_foundation`. Source terrain bottoms remain authoritative and are not changed by this appearance specification.

| Run | Side | Exact start -> end XZ | Outward normal XZ | Coverage / allowed detail |
| ---: | --- | --- | --- | --- |
| 0 | WSW | `(-118.795,451.595) -> (-112.197,464.197)` | `(-0.886,0.464)` | observed owner reference; accepted WSW fields/modules |
| 1 | WSW | `(-112.197,464.197) -> (-103.922,480.000)` | `(-0.886,0.464)` | observed owner reference; accepted WSW fields/modules |
| 2 | WSW | `(-103.922,480.000) -> (-101.199,485.199)` | `(-0.886,0.464)` | observed owner reference; accepted WSW fields/modules |
| 3 | WSW | `(-101.199,485.199) -> (-96.000,495.129)` | `(-0.886,0.464)` | observed owner reference; accepted WSW fields/modules |
| 4 | WSW | `(-96.000,495.129) -> (-90.202,506.202)` | `(-0.886,0.464)` | observed; runtime split at `P`; accepted modules must respect the split |
| 5 | WSW | `(-90.202,506.202) -> (-87.166,512.000)` | `(-0.886,0.464)` | observed owner reference; accepted WSW fields/modules |
| 6 | WSW | `(-87.166,512.000) -> (-79.648,526.358)` | `(-0.886,0.464)` | observed owner reference; accepted WSW fields/modules |
| 7 | SE | `(-79.648,526.358) -> (-67.663,512.000)` | `(0.768,0.641)` | observed official Sep 2025; accepted SE fields/modules |
| 8 | SE | `(-67.663,512.000) -> (-64.000,507.613)` | `(0.768,0.641)` | observed official Sep 2025; accepted SE fields/modules |
| 9 | SE | `(-64.000,507.613) -> (-41.556,480.728)` | `(0.768,0.641)` | observed; runtime split at `Q`; accepted modules must respect the split |
| 10 | ENE | `(-41.556,480.728) -> (-41.936,480.000)` | `(0.886,-0.463)` | unobserved short facet, `0.821 m`; material-only; no module |
| 11 | ENE | `(-41.936,480.000) -> (-49.504,465.504)` | `(0.886,-0.463)` | unobserved; material-only; no module |
| 12 | ENE | `(-49.504,465.504) -> (-58.641,448.000)` | `(0.886,-0.463)` | unobserved; material-only; no module |
| 13 | ENE | `(-58.641,448.000) -> (-60.479,444.479)` | `(0.886,-0.463)` | unobserved short facet, `3.972 m`; material-only; no module |
| 14 | ENE | `(-60.479,444.479) -> (-64.000,437.735)` | `(0.886,-0.463)` | unobserved; material-only; no module |
| 15 | ENE | `(-64.000,437.735) -> (-69.387,427.417)` | `(0.886,-0.463)` | unobserved; material-only; no module |
| 16 | NNW | `(-69.387,427.417) -> (-81.196,433.196)` | `(-0.440,-0.898)` | unobserved; material-only; no module |
| 17 | NNW | `(-81.196,433.196) -> (-96.000,440.440)` | `(-0.440,-0.898)` | unobserved; material-only; no module |
| 18 | NNW | `(-96.000,440.440) -> (-111.448,448.000)` | `(-0.440,-0.898)` | unobserved; material-only; no module |
| 19 | NNW | `(-111.448,448.000) -> (-118.795,451.595)` | `(-0.440,-0.898)` | unobserved; material-only; no module |

### Hawkins runtime split and protected step

- Source run `4` is subdivided at `P = (-90.7771613773,505.1035107148)`; source run `9` is subdivided at `Q = (-58.4999702509,501.0250010119)`. These are established volume connectors, not legal repeat resets.
- The derived exposed step is `P -> Q`, length `32.533848657 m`, outward normal XZ `(0.1253620420,0.9921110615)`, vertical interval `y=18.274..25.274`. It has no source run index.
- The step stays homogeneous `hawkins_pearl_plain`, material-only. No window, door, sign, band, rib, canopy, address element, or copied SE/WSW motif may be placed on it.
- The outer source chain still owns side/world-space U continuity. Generated triangulation subdivisions, chunk boundaries, `P`, and `Q` are forbidden motif seams.

## Isle House high authoritative run map

Coordinates are world XYZ metres. Normals are generated outward XZ normals. Runs `10..12` begin at `y=19.103`; they are shared-above-low tower faces and are never ground facades.

| Run | Geometry group | Exact start -> end XYZ | Outward normal XZ | Coverage / allowed detail |
| ---: | --- | --- | --- | --- |
| 0 | exterior, WSW | `(-133.374,4.065,548.466) -> (-133.067,4.074,549.067)` | `(-0.891,0.455)` | direct Sep 2025; short facet, about `0.675 m`; fields only |
| 1 | exterior, WSW | `(-133.067,4.074,549.067) -> (-128.000,3.932,558.996)` | `(-0.891,0.455)` | direct Sep 2025; side-specific module layout eligible |
| 2 | exterior, WSW | `(-128.000,3.932,558.996) -> (-125.636,3.923,563.627)` | `(-0.891,0.455)` | direct Sep 2025; side-specific module layout eligible |
| 3 | exterior, SW return | `(-125.636,3.923,563.627) -> (-120.336,3.908,568.336)` | `(-0.664,0.748)` | direct Sep 2025; side-specific module layout eligible |
| 4 | exterior, SW return | `(-120.336,3.908,568.336) -> (-117.142,3.942,571.175)` | `(-0.664,0.748)` | direct Sep 2025; side-specific module layout eligible |
| 5 | exterior, SE address | `(-117.142,3.942,571.175) -> (-96.000,3.927,547.172)` | `(0.750,0.661)` | accepted direct Sep 2025 fields/modules |
| 6 | exterior, SE address | `(-96.000,3.927,547.172) -> (-93.206,3.968,544.000)` | `(0.750,0.661)` | accepted direct Sep 2025 fields/modules |
| 7 | exterior, SE address | `(-93.206,3.968,544.000) -> (-89.198,3.990,539.449)` | `(0.750,0.661)` | accepted direct Sep 2025 fields/modules |
| 8 | exterior, ENE | `(-89.198,3.990,539.449) -> (-89.959,3.954,537.959)` | `(0.890,-0.455)` | partial Sep 2025; short facet, about `1.673 m`; fields only |
| 9 | exterior, ENE | `(-89.959,3.954,537.959) -> (-95.775,4.099,526.591)` | `(0.890,-0.455)` | partial Sep 2025; fields only |
| 10 | shared above low, NNE | `(-95.775,19.103,526.591) -> (-107.522,19.103,522.651)` | `(0.318,-0.948)` | not isolated; tower field only; no ground zone/module |
| 11 | shared above low, NW | `(-107.522,19.103,522.651) -> (-130.305,19.103,546.840)` | `(-0.728,-0.686)` | oblique upper evidence; tower field only until exact phase/count is observed |
| 12 | shared above low, NNW | `(-130.305,19.103,546.840) -> (-133.374,19.103,548.466)` | `(-0.468,-0.884)` | not isolated short facet, `3.473 m`; tower field only |

All runs top at `y=71.103`. Exterior foundation runs `0..9` total `85.105 m`; shared-above-low runs `10..12` total `49.092 m`. Do not reconstruct the intentionally absent high/low interface, bridge modules across a part boundary, or attach any high-part field to `w1282547787`.

## Safe homogeneous material-field coverage

The building-texture research/repeat split is mandatory: homogeneous fields may wrap where building-wide material identity is supported; windows, doors, louvers, ribs, trim, signs, canopies, and bands remain complete architectural modules with side-local evidence.

| Target / run scope | Safe field coverage | Confidence | Not authorized by the field decision |
| --- | --- | --- | --- |
| Hawkins WSW `0..6` and SE `7..9` | retain accepted `hawkins_base_smooth` below the established base boundary and `hawkins_pearl_fluted` above | accepted / high for current visual result | no layout/hash/cadence change; address one-offs stay SE-only |
| Hawkins ENE `10..15` and NNW `16..19` | `hawkins_base_smooth` below the established base boundary; `hawkins_pearl_plain` above, through each owning volume top | medium production inference for building-wide value/material family; low for exact rear construction | no fluting claim, no ribbed-base claim, no opening, trim, sign, canopy, band, recess, service feature, or roof-edge motif |
| Hawkins exposed step | `hawkins_pearl_plain` over `y=18.274..25.274` | generated geometry plus conservative material continuity | no base zone and no module |
| Isle exterior runs `0..9` | `isle_house_podium_light` from each authoritative terrain bottom to `y=19.103`; `isle_house_tower_light` from `y=19.103..71.103` | high on observed `0..7`, medium on partial `8..9` | no automatic tower-accent stripe, window/door/louver, identifier, support, glass, or address feature |
| Isle shared-above-low runs `10..12` | `isle_house_tower_light` only, exactly `y=19.103..71.103` | medium building-wide material identity; low for exact hidden/oblique detail | never create podium/ground fields or modules; never touch the low part |

`hawkins_pearl_fluted` is not safe to extend to unobserved Hawkins ENE/NNW merely because the observed sides use it. `hawkins_base_ribbed` is localized architectural surface grammar, not a building-wide base. Likewise, `isle_house_tower_accent`, dark charcoal, glazing, support grey, and identifier are side-specific/module materials, not all-side homogeneous fields.

## Architectural module and trim scope

### Hawkins

- Keep the accepted WSW upper and ground-window schedules on side-local WSW U only. Keep the established connector boundary at `u=60.4 m`; no module crosses it.
- Keep the accepted SE upper schedule and exactly one each of the address lobby, paired door, identifier/sign, canopy band, service door, and garage on side-local SE U only. Keep the established connector boundary at `u=33.0 m`; no module crosses it.
- The Sep 2025 boundary panorama is a second oblique of the same SE side, not evidence for copying SE modules around a corner.
- No direct evidence supports modules on ENE `10..15`, NNW `16..19`, or the exposed step. These remain field-only stop zones.

### Isle House high

- Keep the accepted SE runs `5..7` layout unchanged: complete `IH-ENTRY39`, tower/podium windows, ground glazing, localized louver/door/support/trim families, and address-specific identifier stay on their accepted side-local schedule.
- Newly observed runs `0..4` have enough direct Sep 2025 evidence for a **separate future side-local unique layout**, after reference-relative U mapping and independent review. The visible module families are mixed wide/narrow dark-surrounded tower windows, smaller podium windows, tall ground glazing, localized dark louver bands, dark pedestrian/service doors, one broad light-grey roll-up/grille opening, and a thin canopy/overhang.
- Future runs `0..4` authoring may reuse an existing module family only when the complete motif and scale match the direct side evidence. It must add explicit complete service-door and roll-up/grille families if no complete existing family fits. It must not copy the accepted SE U schedule or `IH-ENTRY39`/identifier.
- Run `0` is too short for an opening module. Corner/return assignment on runs `3..4` must be decided from side-local reference-relative U; no motif may fold through the corner.
- Runs `8..9` remain partial/material-only. Run `11` shows tower-window-family presence obliquely, but its exact endpoints, counts, and phase are not isolated; runs `10..12` therefore remain tower-field-only in this handoff.

## Legal seams, forbidden seams, and protected facets

Legal seams are only phase-neutral seams inside a homogeneous field or explicit boundaries between independently complete architectural modules. The following are protected:

- every generated run corner and triangulation boundary;
- Hawkins source-run subdivisions at `P` and `Q`, the derived step, and the short Hawkins ENE runs `10` and `13`, where an architectural module would not be complete;
- Isle runs `0`, `8`, and `12` as short facets;
- Isle shared-above-low runs `10..12`, their `y=19.103` lower edge, and the hidden `49.094 m` high/low interface;
- the entire Isle low receiver `w1282547787` and every high/low part boundary;
- terrain-varying foundation bottoms, existing tops/roof edges, collision, spray surfaces, and accepted silhouette.

Forbidden seams/resets include generated triangle edges, chunk boundaries, source-run subdivisions inside a continuous side, `P`/`Q`, a material repeat cut through a window/door/louver/band, and any module cut at a high/low part boundary. Homogeneous field phase may continue across a compatible side only if its directional appearance remains correct; architectural modules never wrap corners.

## Implementable handoff

This is the maximum evidence-supported future scope:

1. Preserve both exact receiver keys and every generated vertex/index, massing override, collision/navigation/spray identity, terrain bottom, top, roof, footprint, and accepted module layout.
2. Hawkins: ensure the existing conservative all-side field policy remains complete—accepted fluted upper fields on WSW/SE, plain upper fields on ENE/NNW/step, and smooth base fields on all outer sides. Do not add Hawkins modules.
3. Isle high: extend only homogeneous podium/tower fields to previously uncovered exterior runs `0..4` and tower-only fields to shared runs `10..12`; preserve existing fields on `5..9`. Do not attach anything to the low part.
4. Treat the newly observed runs `0..4` module layout as a separate follow-up, not part of a material-wrap change. It requires side-local U mapping, complete-module definitions, exact run containment, ordinary-distance proof, and independent facade review.
5. Keep runs `8..12` module-blocked until official direct coverage isolates a complete side/run-local schedule. Oblique evidence alone does not unblock counts or phase.
6. Any future runtime work must remain render-only and shallow, preserve spray projection onto the underlying wall, retain the accepted fronts exactly, and prove no spillover to roofs, parent, low part, non-targets, or accepted other facades.

## Confidence and stop conditions

| Claim | Confidence | Stop condition |
| --- | --- | --- |
| Exact receiver IDs, run counts, endpoints, normals, shared/exterior classification | high generated fact | stop on any generated-record mismatch or receiver ambiguity |
| Current accepted WSW/SE Hawkins and SE Isle visual direction | owner accepted | stop if an implementation changes existing layout, hashes, silhouette, or ordinary-distance reading |
| Hawkins all-side plain-upper/smooth-base material wrap | medium conservative production inference | stop if a request requires rear-specific fluting, openings, trim, address, service, canopy, rib, band, or roof detail |
| Hawkins ENE/NNW modules | blocked / unknown | stop; obtain admissible direct evidence first |
| Isle runs `0..4` material fields | high direct Sep 2025 evidence | stop if a field changes the accepted part split or terrain/massing |
| Isle runs `0..4` future modules | medium-high evidence readiness, not yet layout-ready | stop until exact reference-relative U, complete module boundaries, and independent review exist |
| Isle runs `8..9` or `10..12` modules | blocked / partial or oblique only | stop; material-only until a direct complete elevation isolates count and phase |
| Isle low part appearance | unknown and out of scope | stop on any attempted field/module attachment to `w1282547787` |

Details that must not be invented include exact products, surveyed dimensions, rear Hawkins openings, rear Hawkins ribbing/fluting, hidden service equipment, Isle north/shared-face counts and phase, low-part appearance, address signage on any non-address side, roof/parapet mechanics, true recess depth, interior content, reflections, tenant objects, trees, vehicles, bins, fences, and temporary street furniture.

## Validation checklist for a future implementation

- [ ] Hawkins receiver is exactly `building:w1249412093:wall`; all source runs `0..19`, their normals, `P`, `Q`, and the step match the authoritative generated/massing records.
- [ ] Isle receiver is exactly `building-composite:w1249412094:w1282547786:wall`; all runs `0..12`, normals, and shared/exterior ownership match the authoritative generated record.
- [ ] Isle low `building-composite:w1249412094:w1282547787:wall` has no new facade child or material attachment.
- [ ] Hawkins accepted WSW/SE and Isle accepted SE layouts/signatures are unchanged.
- [ ] Every new field segment is homogeneous and phase-neutral; every module is complete and run-contained.
- [ ] No new module exists on Hawkins ENE/NNW/step or Isle `8..12`.
- [ ] Collision, navigation, terrain, generated files, footprints, roofs, spray receiver identity, and massing are byte/behavior unchanged.
- [ ] Controlled close, ordinary-distance, and changed-light proof is reviewed separately from receiver-fit and gameplay acceptance.

## Final verdict

- **Hawkins:** owner-accepted direction; all-side homogeneous coverage is evidence-safe only as the current smooth-base plus conservative plain-upper fallback on ENE/NNW/step. No additional module-bearing side was found.
- **Isle House high:** owner-accepted direction; homogeneous podium/tower fields are safe across all exterior high runs, with tower-only fields on shared-above-low runs. Newly direct-observed runs `0..4` are eligible for a later separate side-specific module-layout pass. Runs `8..12` remain module-blocked.
- **Isle House low:** unchanged and unknown.
