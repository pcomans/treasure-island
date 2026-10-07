# Building 2 — w24274434

Hall of Transportation / Building 2, 300 California Avenue. Study preparation
2026-10-06 on baseline main `b9e88fa`; final Astra002 reviewed and accepted by
ROOT on 2026-10-07. Catalog promotion recorded; full suite PASS, no commit.

Current art owner (2026-10-07): `/root/building2_art`, GPT Astra
(`gpt-6-astra`) at effort `low`, following the owner's explicit "astra low"
selection. Building 2 review roles use GPT-6.1 Sol at effort `high` and
coordination/documentation remains Astra Medium. This is a Building 2 override,
not a global routing change. `/root/landmark_art` coordinates the handoff.
The first study was authored by Claude Code `ti-implementation`, Opus 5.5/MAX,
in persistent session `5b5b33bc-c598-40b3-8eb2-42d4cc0902b1`; its failed
corrective turn is retained below as history.

Reference sufficiency (ROOT, actual pixels, 2026-10-06): `building2-wsw-wide-may2019.png`
and `building2-sse-west-apr2017-v2.png` are sufficient for a first coherent exterior:
WSW twin grids, central entry and tapered pylons; SSE ribbed piers, two glazing bands
and the arched silhouette. The close partial WSW view and `building2-side-attempt.png`
(April 2017, the other direction) supplement them. NNW and ENE are unobserved and remain
conservative production inference, not whole-building acceptance. No relief artwork is
reproduced; a simple nonliteral form/value proxy is allowed. No bespoke vegetation.
Private originals are outside Git/game in `/workspaces/landmark-progress-20261006/`:

- `building2-wsw-wide-may2019.png`: complete WSW monumental end, Google Street
  View, May 2019, pano `lnRMuxXwh_bOj4Vg7NCoxw`, 37.8179703,-122.3685661,
  heading 52. Arched crown, paired gridded glazing, central recessed blue-grey
  panel and three dark doors, tapered corner pylons and local grade are visible.
  [Locator](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8179703,-122.3685661&heading=52&pitch=5&fov=90).
- `building2-wsw-reference.png`: closer partial view from the same panorama.
- `building2-side-attempt.png` and `building2-sse-west-apr2017-v2.png`: SSE
  long-side center/east and western oblique, visitor panorama, April 2017,
  `CIHM0ogKEICAgIDq7dzDwAE`, resolved location 37.8180216,-122.3674109,
  headings 330 and 285. Ribbed pale piers, two tiers of grouped glazing,
  occasional service openings, end pylon and local paving are visible.
  [Locator](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.81785,-122.36785&heading=330&pitch=6&fov=90).

The other attempts are retained failures, not evidence: `building2-sse-west-apr2017.png`
is a map loading frame, `building2-ene-attempt.png` is a substantially obstructed
barrel yard, `building2-north-attempt.png` is an interior, and
`building2-nnw-attempt.png` has no resolved panorama. No post-2019 finish,
complete opposite-end schedule or hidden artwork is established.
The existing [source packet](p1_reference_packets/w24274434_building_2.md)
retains NPS identity 08000082 and historical HABS CA-2785-A description.
The frozen NRHP tag is retained as provenance only, not correct identity.

Reuse decision: new B2 base (`game/scripts/world/facades/building_2_hero_model.gd`).
It is structurally justified by the twin monumental end and the ribbed SSE wing. It
reuses the Building 3 arched-profile approach and the existing Building 1/3 materials;
the live Building 3 code and shared massing are untouched.

First source turn (no engine run yet), all heights reversible production inference:
- Frame: `t` runs from run 3's start to run 8's end; `n = (-t.z, t.x)` is WSW-outward
  and matches the normals of run 4 and run 17 to within 1e-6.
- Roles: WSW main face runs 3–8 (65.505 m); ENE end 27–32; NNW long side 38–43.
  Pylon loops close exactly on runs 45/0/1/2/44, 9/10/11, 33–37 and 24–26.
- SSE wing (u 75.96–87.07): runs 12–15, 16–21, 22 and 23. It is 11 m deep and set
  back 5.6 m behind the WSW pylon face, read as the two-tier ribbed wing in the
  April 2017 views.
- Heights: base 3.56; segmental barrel with eave 21.36 and crown 28.16 over
  73.96 m; wing parapet 14.36; pylon shaft/crown stage/cap 24.3/25.7/26.3.
  Barrel and wing roofs replace the source roof triangulation inside the footprint.
- Facade:
  - WSW: two 26.25 m gridded fields (24×10 lights, dark band, 0.9 m reveals); a 5.8 m
    blue-grey entry 1.25 m deep with three dark doors and a stacked nonliteral relief
    proxy; two small vents.
  - SSE: 20 recessed bays between 0.9 m piers with stepped crowns, grouped lower and
    upper glazing, and two service doors.
  - NNW: seven shallow panels with no openings. ENE end and the wing clerestory are
    plain.
- Every face keeps exact source bottoms and stays within the frozen footprint;
  recesses go inward only.
- Local land preflight (read-only sampling of chunks x_0/x_1 × z_1/z_2):
  - All 46 run bottoms (3.198–3.56) are at or below adjacent land 0.3 m outside
    (3.34–6.86).
  - Land continues under the footprint: 3.66 at the WSW entry, 3.41–3.96 behind the
    fields, about 3.76 behind the SSE bays.
  - The NNW and ENE berms bury up to 3.3 m of the walls, so their panels start 4.0 m
    above base.
  - No stairs are emitted; doors sit at grade.

Actual execution and current hold (2026-10-06):

- Baseline shared shots and island views passed before source edits, followed by
  the maintained headless scene parse and the first coherent shared shots.
  Originals/logs: `/workspaces/landmark-progress-20261006/baseline/`,
  `first-study/`, `baseline.log`, `preflight-parse.log`, `first-study.log`.
  The pixel runs reported AMD Radeon 780M Graphics (RADV PHOENIX) / Wayland;
  baseline and candidate share the existing Wayland pointer warning and seven
  texture RID leak warning. These are recorded, not suppressed.
- Independent early visual verdict: recognition gain yes, whole-building HOLD.
  Preserve the useful WSW twin-grid/central-entry/curved-crown identity. Recompose
  the observed SSE into a taller integrated ribbed-pier/glazing rhythm toward the
  pylon shoulders: the first candidate's low strip and dominant blank backing wall
  do not match the reference. No global illumination changes are authorized.
- The same Claude session's correction failed with a session cap, exit 1, reporting
  reset at **23:50 UTC**. Failed run retained in `claude-building2-correct.jsonl`.
  Only the snapshot-cardinality guard was partly corrected; SSE geometry was not
  changed and no corrective artwork capture ran. The owner resolved the routing
  question on 2026-10-07 by explicitly selecting Astra Low; no Claude retry or
  silent fallback was used.
- The interruption removed `RUN_COUNT` but left one metadata use. ROOT authorized
  a non-modeling one-line recovery: derive `exact_source_wall_runs` as an integer
  from the actual complete wall-array stride. No geometry, materials or guard
  behavior changed in that recovery. `recovery-parse.log` retains its result.
- Full fit, actual stock spray, final independent reviews and whole test suite are
  still pending. Catalog status/credit remains unchanged. The finite budget is now
  seven Godot invocations: baseline, initial parse, first shots, explicit recovery
  parse, two possible corrective captures and final shared fit. No commits, exports
  or promotion have been authorized.

Resumption preflight (2026-10-07): main remains `b9e88fa`, with the existing
uncommitted B2 source/hook and preparation notes. Fresh process inspection found
no live prior Claude, Godot or private Weston/browser process; all prior terminal
results remain consumed. No baseline, parse or screenshot was repeated. The B2
budget remains **4/7 used**: two corrective captures and final shared fit remain.
The separate B3 reference/current-baseline preparation is complete and grants no
B3 authoring authority. Existing recognition remains 48/213.

Coalesce the next B2 correction: observed SSE tall integrated rib/glazing/pylon
shoulder hierarchy; inspect north dotted upper-panel joins without claiming a
known cause; reconcile curved wall/roof edge tessellation (review sampled a
4.73 mm slit and 5.44 mm overlap); supply a UV-aligned tangent basis or a B2-local
geometric-normal material for the borrowed cream shader's NORMAL_MAP. Preserve
the already-reviewed structural source guard and derived metadata count. The
first-study references and captures remain in `/workspaces/landmark-progress-20261006/`.
No acceptance, code promotion, commit, push or export follows from this handoff.


Astra correction 001 (2026-10-07, `/root/building2_art`):
- Accepted explicit SOURCE/ENGINE/WRITER release from `landmark_art`; preserved
  prior terminal outcomes and did not replay baseline or parsing.
- Reused the current B2 base and immutable Building 1/3 materials. Raised the SSE
  wing roof to the 21.36 m eave, deepened bay recesses to 0.95 m, broadened glazing
  within existing bays, and raised upper glazing to 12.56–16.66 m. These are
  reversible production inferences from the April 2017 tall ribbed elevation.
  Front composition, source footprint, exact source bottoms, land and visible
  area geometry are unchanged. No new ground details or stairs were introduced;
  retained local-land preflight remains applicable to exterior face lines.
- End walls split at barrel-strip boundaries and evaluate the same piecewise
  linear arch as the roof. Additional opening cuts interpolate that profile.
  Local per-face orthonormal metre UV bases now supply matching authored tangents;
  shared material files are unchanged.
- Shared capture session 48408 reached actual exit 0 and screenshots PASS;
  subsequent process inspection found no Godot/Weston. Eleven actual captures:
  `/workspaces/landmark-progress-20261006/correction-astra-001/`, adjacent `.log`.
  Actual reported renderer/display: AMD Radeon 780M Graphics (RADV PHOENIX) /
  Wayland. Existing pointer-constraint null and seven Texture RID warnings remain.
- Author inspected actual south, north and west pixels: integrated taller side
  gain is visible, WSW composition retained, but north dotted panel-head edges
  persist. Their cause is still unproved; tangent completion did not remove them.
  Source frozen for independent review. Five of seven Godot invocations are used;
  one corrective capture and final fit remain. No acceptance, commit or promotion.


Astra correction 002 (2026-10-07):
- Independent Astra001 CODE PASS and SSE recognition gain retained. The final
  bounded correction changes only `_emit_nnw_long_side`: remove unsupported
  shallow panels and their returns/backs, emit the complete canonical NNW chain
  to the unchanged eave in the same cream wall/collision/spray bucket. No overlay,
  new motif, footprint, bottom, local land or visible-area change.
- Shared capture28392 exited0/PASS with eleven fresh images in
  `/workspaces/landmark-progress-20261006/correction-astra-002/` and adjacent log.
  Actual process inspection found no Godot/Weston. AMD Radeon 780M Graphics (RADV
  PHOENIX) / Wayland; ss-null remains and the terminal Texture RID warning is14,
  versus7 previously. The count change is recorded without claiming its cause.
- Author inspected actual north: repeated dashed heads and broken pale lower
  panel edges are removed. Source is frozen for independent final code/visual
  review. Six of seven calls used; final fit plus stock spray remains reserved.


Final separate gates and ROOT-authorized acceptance (2026-10-07):
- `building2-astra002-code-20261007`: independent CODE PASS by
  `mersea_placement_review`, localized002 review reusing001/core/guard findings.
- `building2-astra002-whole-building-visual-20261007`: independent whole-building
  game-art and context/island PASS by `mersea_visual027`; all four ordinary views,
  two raised views and five matched baseline/final island pairs compared with
  dated observed WSW/SSE originals. ENE/NNW remain conservative production inference.
  Neither verdict claims surveyed dimensions, as-built fidelity or physical
  material measurement. Runtime warning causes remain unresolved.
- Actual final source fit and stock spray: session60246 exited0, shared
  `building_fit_test.gd -- --source w24274434 --spray` with private source-bound
  `building2-final-spray.json`; log `building2-final-fit.log` in the progress folder.
  Roof0/34, wall0/19 and ground0/19 bad samples; four stock walk-ups; one actual
  `placed` decal on `building:w24274434:wall`. All five active REST cases were
  input-released, grounded, supported and stopped before all five safe disabled
  finals. No engine process remained after terminal consumption.
  The south AABB note ends0.712m inward of run17 in the0.95m-deep open bay;
  actual south pixels independently show the ground-reaching recess.
- ROOT accepted these independent gates and authorized catalog promotion. Only
  w24274434 gains credit:49 accepted of the unchanged213 units; prior48 preserved.
  Complete `tools/test.sh` now pending. No commit, push or export this round.


Final full suite: `tools/test.sh`, session15705, actual terminal exit0,
`ALL TESTS PASS`, including all49 scored buildings and generator determinism.
Log: `/workspaces/landmark-progress-20261006/building2-full-suite.log`.
Process inspection after terminal consumption found no Godot, Weston, test shell
or determinism process. Explicit tracked/new-file whitespace checks passed.
All study gates passed; commit/push remain outside this round's authorization.
