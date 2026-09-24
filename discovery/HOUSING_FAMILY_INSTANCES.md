# Housing family instances — A/B experiment

Baseline: `9c7f2440d3db6a7f2d0a5d474c612c0362a01c16`; branch: `experiment/housing-family-instances`. The owner authorized a separate shared-family experiment for comparison with MAIN. No merge, production promotion or recognition credit follows from this inventory.

The [frozen catalog](facades/facade-recognition-catalog.json) contains 213 physical buildings represented by 215 source records (213 footprints and 2 parts). Named reference packets cover 152 physical units; packet presence is not exhaustive visual proof. The current 75-unit candidate shortlist has 24 photo-confirmed targets (23 captured in the A/B experiment and one not modeled), 21 written matches requiring pixel validation, and 30 candidates requiring imagery. The original frozen capture selection remains 23 targets. The other 138 catalog units are not proven unrelated. Physical unit IDs use `physical-building:<source ID>`.

Reuse decision: evolve the [shared housing family](../game/resources/housing_family/README.md) with target-specific stepped runs, opening schedules, roof/canopy variants and semantic palettes; the straight six-metre prototype is not a drop-in fit for these targets. Preserve frozen source identity/footprints, orientation, grade, gameplay and independent per-building verification.

Evidence is the inventory agent's completed catalog/packet review and the independent reference agent's direct frontage review. Reference photographs remain private and outside Git/runtime; links below name existing written source packets. Observed structure is distinct from inferred module dimensions, cadence and hidden faces.

## Photo-reviewed initial targets (23)

Direct frontage pixels were reviewed from March 2025 imagery. This supports structural family selection on visible faces, not surveyed dimensions, unseen elevations, site fit or whole-unit acceptance.

| Source ID | Address | Written evidence | Variant / uncertainty |
|---|---|---|---|
| `w96215673` | 1232 Northpoint Drive | [D7 packet](facades/d7_reference_packets/w96215673_1232_northpoint_drive.md) | flat carport |
| `w96215674` | 1241 Northpoint Drive | [D7 packet](facades/d7_reference_packets/w96215674_1241_northpoint_drive.md) | flat canopy |
| `w96215659` | 1234 Northpoint Drive | [D6 packet](facades/d6_reference_packets/w96215659_1234_northpoint_drive.md) | flat canopy |
| `w96215688` | 1240 Northpoint Drive | [D7 packet](facades/d7_reference_packets/w96215688_1240_northpoint_drive.md) | flat canopy |
| `w96215651` | 1202 Mariner Drive | [D6 packet](facades/d6_reference_packets/w96215651_1202_mariner_drive.md) | flat canopy |
| `w96215691` | 1204 Mariner Drive | [D7 packet](facades/d7_reference_packets/w96215691_1204_mariner_drive.md) | offset two-part canopy |
| `w96215666` | 1215 Bayside Drive | [D6 packet](facades/d6_reference_packets/w96215666_1215_bayside_drive.md) | flat canopy |
| `w96215653` | 1227 Northpoint Drive | [D6 packet](facades/d6_reference_packets/w96215653_1227_northpoint_drive.md) | partial canopy/end gable |
| `w96215682` | 1221 Mariner Drive | [D7 packet](facades/d7_reference_packets/w96215682_1221_mariner_drive.md) | flat canopy |
| `w96215658` | 1239 Northpoint Drive | [D6 packet](facades/d6_reference_packets/w96215658_1239_northpoint_drive.md) | canopy-free, mixed openings |
| `w96215649` | 1212 Mariner Drive | [D6 packet](facades/d6_reference_packets/w96215649_1212_mariner_drive.md) | canopy-free |
| `w96215680` | 1219 Mariner Drive | [D7 packet](facades/d7_reference_packets/w96215680_1219_mariner_drive.md) | canopy-free, end step |
| `w96215656` | 1224 Bayside Drive | [D6 packet](facades/d6_reference_packets/w96215656_1224_bayside_drive.md) | canopy-free |
| `w96215661` | 1222 Bayside Drive | [D6 packet](facades/d6_reference_packets/w96215661_1222_bayside_drive.md) | canopy-free, weathered |
| `w96215669` | 1238 Northpoint Drive | [D7 packet](facades/d7_reference_packets/w96215669_1238_northpoint_drive.md) | canopy-free |
| `w96215672` | 1201 Bayside Drive | [D7 packet](facades/d7_reference_packets/w96215672_1201_bayside_drive.md) | canopy-free |
| `w96665904` | 1237 Northpoint Drive | [D9 packet](facades/d9_reference_packets/w96665904_1237_northpoint_drive.md) | canopy-free, shallow hip |
| `w96215652` | 1220 Bayside Drive | [D6 packet](facades/d6_reference_packets/w96215652_1220_bayside_drive.md) | broad sloped story-band/opening variant |
| `w96215677` | 1206 Mariner Drive | [D7 packet](facades/d7_reference_packets/w96215677_1206_mariner_drive.md) | broad sloped story-band/opening variant |
| `w96215678` | 1205 Bayside Drive | [D7 packet](facades/d7_reference_packets/w96215678_1205_bayside_drive.md) | broad sloped story-band/opening variant |
| `w96215685` | 1226 Bayside Drive | [D7 packet](facades/d7_reference_packets/w96215685_1226_bayside_drive.md) | stepped, sloped story-band/awning variant |
| `w96665911` | 1229 Northpoint Drive | [D9 packet](facades/d9_reference_packets/w96665911_1229_northpoint_drive.md) | boarded/blank-opening variant |
| `w96215670` | frozen 1246/current 1397 Gateview Court | [D7 packet](facades/d7_reference_packets/w96215670_1246_1397_gateview_court.md) | stepped row, mixed openings; canopy ownership unresolved |

## Additional photo-confirmed target, not modeled (1)

| Source ID | Address | Evidence | Variant / uncertainty |
|---|---|---|---|
| `w96215646` | frozen 1230/current 1394 Gateview | [D5 packet](facades/d5_reference_packets/w96215646_1230_1394_gateview.md); [March 2025 source](https://www.google.com/maps/@?api=1&map_action=pano&pano=j3ugQSzJZtl9lpbb5i58bQ&heading=90&pitch=0&fov=90) | Direct pixels confirm shared row/continuous canopy; exact D5 panorama/camera/heading and address crosswalk independently checked. Hidden schedules remain unknown; no new model or acceptance. |

## Written matches requiring pixel validation (21)

| Source ID | Address | Evidence | Variant / uncertainty |
|---|---|---|---|
| `w96215667` | 1248/1395 Gateview Court | [D6 packet](facades/d6_reference_packets/w96215667_1248_1395_gateview_court.md) | April 2019 pale row, flat canopy; address crosswalk |
| `w96215668` | 1236 Northpoint Drive | [D6 packet](facades/d6_reference_packets/w96215668_1236_northpoint_drive.md) | March 2025 boarded/secured opening pattern |
| `w96215676` | 1143 Ozbourn Court | [D7 packet](facades/d7_reference_packets/w96215676_1143_ozbourn_court.md) | April 2019 pale row, red-brown roof, green doors; no deep canopy |
| `w96215693` | 1208 Mariner Drive | [D8 packet](facades/d8_reference_packets/w96215693_1208_mariner_drive.md) | shallow hip, no canopy |
| `w96215698` | 1228/1390 Gateview Court | [D8 packet](facades/d8_reference_packets/w96215698_1228_1390_gateview_court.md) | continuous flat canopy, slender rust posts |
| `w96665890` | 1111 Keppler Court | [D8 packet](facades/d8_reference_packets/w96665890_1111_keppler_court.md) | compact row, shallow hip, privacy boxes |
| `w96665893` | 1210 Mariner Drive | [D8 packet](facades/d8_reference_packets/w96665893_1210_mariner_drive.md) | compact row, shallow hip, mixed doors |
| `w96665897` | 1112 Hutchins Court | [D8 packet](facades/d8_reference_packets/w96665897_1112_hutchins_court.md) | compact row, blue doors, privacy boxes |
| `w96665903` | 1124 Reeves Court | [D8 packet](facades/d8_reference_packets/w96665903_1124_reeves_court.md) | central projecting gable mass |
| `w96665906` | 1147 Ozbourn Court | [D9 packet](facades/d9_reference_packets/w96665906_1147_ozbourn_court.md) | long row, shallow hip, lower enclosures |
| `w96665908` | 1203 Bayside Drive | [D9 packet](facades/d9_reference_packets/w96665908_1203_bayside_drive.md) | compact block, shallow gable end, screened entry |
| `w96665909` | 1149 Ozbourn Court | [D9 packet](facades/d9_reference_packets/w96665909_1149_ozbourn_court.md) | compact row, asymmetric upper groups, yellow entry |
| `w96665916` | 1242 Northpoint Drive | [D9 packet](facades/d9_reference_packets/w96665916_1242_northpoint_drive.md) | deep flat canopy, local post/opening cadence |
| `w96665919` | 1116 Hutchins Court | [D9 packet](facades/d9_reference_packets/w96665919_1116_hutchins_court.md) | long row, shallow hip, paired upper windows |
| `w96665935` | 1135 Mason Court | [D10 packet](facades/d10_reference_packets/w96665935_1135_mason_court.md) | long row, low entry projections |
| `w96665936` | 1128 Reeves Court | [D10 packet](facades/d10_reference_packets/w96665936_1128_reeves_court.md) | partial boarding/privacy-box rhythm |
| `w96698619` | 1254/625 13th Street | [D10 packet](facades/d10_reference_packets/w96698619_1254_625_13th_street.md) | deep dark post-supported canopy, paired windows |
| `w96698627` | 1216/1430 Gateview Court | [D10 packet](facades/d10_reference_packets/w96698627_1216_1430_gateview_court.md) | cream row, reddish roof, entry/privacy rhythm |
| `w96698643` | 1249 Exposition Drive | [D10 packet](facades/d10_reference_packets/w96698643_1249_exposition_drive.md) | varied dark/green entry/privacy rhythm |
| `w96698645` | 1214/1420 Gateview Court | [D10 packet](facades/d10_reference_packets/w96698645_1214_1420_gateview_court.md) | deep canopy, irregular openings |
| `w96698648` | 1252 Exposition Drive | [D10 packet](facades/d10_reference_packets/w96698648_1252_exposition_drive.md) | deep canopy, shallow tan/gray roof |

## Candidates requiring imagery (30)

| Source ID | Address | Evidence | Variant / uncertainty |
|---|---|---|---|
| `w96215645` | 1122 Reeves Court | [D5 packet](facades/d5_reference_packets/w96215645_1122_reeves_court.md) | fenced rear/end only; front missing |
| `w96215660` | 1225 Northpoint Drive | [D6 packet](facades/d6_reference_packets/w96215660_1225_northpoint_drive.md) | distant north end, neighbor overlap |
| `w96215662` | 1139 Ozbourn Court | [D6 packet](facades/d6_reference_packets/w96215662_1139_ozbourn_court.md) | fenced/occluded, projecting gable; front/side cadence unknown |
| `w96215671` | 1244 Northpoint Drive | [D7 packet](facades/d7_reference_packets/w96215671_1244_northpoint_drive.md) | tree obscures center; ochre-door fragments |
| `w96215690` | 1141 Ozbourn Court | [D7 packet](facades/d7_reference_packets/w96215690_1141_ozbourn_court.md) | tree/hedge hides entry schedule |
| `w96215694` | 1251 Exposition Drive | [D8 packet](facades/d8_reference_packets/w96215694_1251_exposition_drive.md) | fence-hidden lower front; clerestory fragment |
| `w96665884` | 1145 Ozbourn Court | [D8 packet](facades/d8_reference_packets/w96665884_1145_ozbourn_court.md) | stepped mass, partial upper groupings |
| `w96665885` | 1118 Hutchins Court | [D8 packet](facades/d8_reference_packets/w96665885_1118_hutchins_court.md) | fence-hidden base |
| `w96665887` | 1115 Keppler Court | [D8 packet](facades/d8_reference_packets/w96665887_1115_keppler_court.md) | fence/trees obscure lower plane |
| `w96665892` | 1137 Mason Court | [D8 packet](facades/d8_reference_packets/w96665892_1137_mason_court.md) | fence/tree partial view |
| `w96665899` | 1108 Halyburton candidate | [D8 packet](facades/d8_reference_packets/w96665899_1108_halyburton_candidate.md) | boarded grid; target/address candidate |
| `w96665907` | 1129 Mason Court | [D9 packet](facades/d9_reference_packets/w96665907_1129_mason_court.md) | corner fragments, trees |
| `w96665910` | 1110 Hutchins Court | [D9 packet](facades/d9_reference_packets/w96665910_1110_hutchins_court.md) | entry/privacy fragment |
| `w96665915` | 1109 Keppler Court | [D9 packet](facades/d9_reference_packets/w96665915_1109_keppler_court.md) | tree-screened upper material/windows only |
| `w96665920` | 1131 Mason Court | [D9 packet](facades/d9_reference_packets/w96665920_1131_mason_court.md) | dense tree screen |
| `w96665921` | 1113 Keppler Court | [P3 packet](facades/p3_reference_packets/w96665921_1113_keppler_court.md) | front repeated row evidenced 2018/2019, rear 2025 distant; full cadence unknown |
| `w96665922` | 1114 Hutchins Court | [D9 packet](facades/d9_reference_packets/w96665922_1114_hutchins_court.md) | fence-hidden lower plane |
| `w96665923` | 1120 Reeves Court | [D9 packet](facades/d9_reference_packets/w96665923_1120_reeves_court.md) | no frozen appearance cue; fence/tree context |
| `w96665925` | 1107 Bigelow Court | [D10 packet](facades/d10_reference_packets/w96665925_1107_bigelow_court.md) | vegetation/glare/vehicles; partial boarding |
| `w96665928` | 1117 Keppler Court | [D10 packet](facades/d10_reference_packets/w96665928_1117_keppler_court.md) | tall fence/trees hide lower plane |
| `w96665933` | 1105 Bigelow Court | [D10 packet](facades/d10_reference_packets/w96665933_1105_bigelow_court.md) | intercepted sightline; no frozen recognizer |
| `w96698634` | 1253 Exposition Drive | [D10 packet](facades/d10_reference_packets/w96698634_1253_exposition_drive.md) | partial lower boarding/incomplete front |
| `w96698651` | 1315 Gateview Avenue | [OSM inventory](../data/osm/treasure-island-source-inventory.csv) | two-storey residential; possibly different broad-gabled-carport cohort |
| `w96698652` | 1223 Mariner Drive | [OSM inventory](../data/osm/treasure-island-source-inventory.csv) | two-storey residential |
| `w96698658` | 1250, street absent | [OSM inventory](../data/osm/treasure-island-source-inventory.csv) | two-storey residential |
| `w96698662` | unaddressed | [OSM inventory](../data/osm/treasure-island-source-inventory.csv) | residential, levels absent |
| `w96698663` | 1243 Northpoint Drive | [OSM inventory](../data/osm/treasure-island-source-inventory.csv) | two-storey residential |
| `w96698667` | 1218/1440 Gateview Court | [OSM inventory](../data/osm/treasure-island-source-inventory.csv) | two-storey residential |
| `w96698672` | 1245 Northpoint Drive | [OSM inventory](../data/osm/treasure-island-source-inventory.csv) | two-storey residential |
| `w96698673` | 1247, street absent | [OSM inventory](../data/osm/treasure-island-source-inventory.csv) | two-storey residential |

## Reference and comparison limits

The original 23 reviewed references are March 2025 Google Street View frontages. Their named acquisition/selection records retain private originals; no imagery was copied into this branch. Target association uses existing explicit source joins, not nearby UI address labels: the 1234, 1202, 1241, 1205 and 1397 views carry misleading neighboring labels; 1237 and 1229 also require their recorded joins. For 1205, use `1205-resolved-original.png`; the earlier headed image is a failed black receipt. Canopy ownership at 1397 remains unresolved. No source-geometry revalidation was performed by the pixel reviewer.

The initial retained-image search for 22 written matches found no directly inspectable originals. A later targeted pilot recovered and independently associated 1394 imagery, moving that one target to the additional photo-confirmed tier; the other 21 remain written-only. Written packet descriptions in the second tier still need direct-image validation. Partial images and OSM tags/footprints in the third tier only justify shortlisting; they do not establish visual family membership. Do not infer missing openings or attach the generic prototype from these rows alone. Subsequent validated targets can move tiers with a concise evidence note.

Broad-gabled-carport Gateview 1301–1318 and paired garage/stair fish-street courts may share components but have different topologies. Boundary cases `w96698611` (dark-clad courtyard/pergola), `w96698650` (unaddressed Avenue H) and `w110188516` (Avenue H) remain unresolved outside this shortlist.

## Final branch checkpoint

The [A/B gallery](../evidence/housing-family-experiment/index.html) shows final run `all23-006`: 46 original images for 23 targets. The [reproduction instructions](../game/tests/housing_family_experiment/README.md) explain the baseline, shared assembly and retained 1232/1241 roof/site components. At that frozen checkpoint, the other 52 shortlisted targets remained unconfirmed. The later reference-only pilot confirms one additional target (1394), leaving 51 unconfirmed and no additional modeled target. Earlier failed/held runs are preserved locally outside the committed checkpoint.

Independent factual source review (`family_branch_setup`, Astra Low) found consistent source identities, genuine shared construction, unchanged production loader/registry/collision/control boundaries and successful final native capture. All frozen input bindings and 46 image hashes matched; camera invariance passed the native approximate-transform guard, and Sun state equality passed its guard. This is visual-only technical evidence, not collision fit, playable integration or release acceptance.

Independent visual review (`housing_family_reference_review`, Astra Medium) found a useful provisional A/B experiment: the shared trim/screen regression was substantially repaired and 1221 roof variation restored. Five targets remain incomplete regional studies: 1204 (`w96215691`), 1205 (`w96215678`), 1237 (`w96665904`), 1229 (`w96665911`) and 1397/frozen 1246 (`w96215670`). 1397 canopy ownership remains unknown. The unobstructed 1229 view still weakly conveys the reference shallow roof surface/projecting upper-storey apron; fidelity remains unresolved, not proven missing geometry. 1227/1234 have useful views but denser, less open screens than A; 1226 is partly occluded. No blanket whole-building PASS, recognition credit or MAIN promotion is granted.

## Targeted reference pilot outcome

The later reference-only pilot supports optional question-driven acquisition. 1204’s March 2025 east view specifically exposes the left-end broad window, pale door and recessed entry; central openings and screen motifs were already supported and remain an implementation gap. 1394’s direct March 2025 view confirms the family/canopy description and raises current photo-confirmed coverage to 24. Alternate April 2019/March 2025 views of 1397 mainly corroborate canopy extent; attachment and exact receiver ownership remain unknown, so acquisition stopped. The existing 1229 image already supports the roof/apron question; no new view was needed. No runtime/model/acceptance state changed.

Permitted private originals and source/date/association notes are retained in [pilot NOTES](/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/targeted-streetview-pilot-2026-09-24/NOTES.md): `images/1204-east-oblique.png`, `images/1394-west-front.png`, `images/1397-north-oblique.png`, `images/1397-south-oblique.png`, and the reused `images/1229-baseline.png`. These locators are for local reference reuse; images are outside Git and runtime. Four distinct new views were usable; one duplicate is excluded. 1204 and 1394 supplied material evidence gains, while 1397 mainly corroborated existing context. Recorded acquisition-through-gallery time was 219.6 seconds, not total task time or measured token savings.

The subsequent [focused 1204/1229 comparison](../evidence/housing-family-experiment/quality-round1.html) retains final round-1 run 003 against historical 006, with unchanged control views from 002. Independent visual review found both fronts materially improved as a provisional branch checkpoint; simplified recesses/screens/ground and incomplete regions remain. This adds no photo-confirmed unit, whole-building acceptance or production integration.

The [focused 1205/1237 comparison](../evidence/housing-family-experiment/quality-round2.html) retains round-2 run 004. Independent visual review found restored frontage groups and distinct broad/thin bands useful, with low roof contrast and simplified entry-screen/ground detail still limiting the result. The main gallery now selects these latest reviewed pairs, the prior 1204/1229 pairs and historical 006 pairs for the other 19 targets; it is not current-source proof for every instance. Photo-confirmed and acceptance counts do not change.
