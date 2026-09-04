# Visual bar-raiser review — recognizable, believable Treasure Island

Reviewed: **2026-09-04**  
Reviewer: **`/root/visual_bar_raiser`**  
Scope: current accepted Building 1, its separately keyed tower, Hawkins, newly
accepted Building 3, and the pending Isle House low-part prototype concept

## Outcome

The project has proved that its strongest buildings can be recognized without
photorealism. The next quality step is not more detail everywhere. It is a
clearer hierarchy of **big form -> facade structure -> focal entrance -> quiet
material field**.

- **Keep the existing recognition verdicts.** This review does not decrement an
  accepted numerator or promote a pending unit.
- **Reopen Building 1 and Building 3 for bounded visual refinement.** Both are
  top-1 recognizable, but both fail the additional believability/visual-interest
  gate in their primary ordinary-player views.
- **Keep Hawkins accepted.** It is the best current template for combining a
  recognizable mass, a differentiated ground zone, and restrained detail.
- **Keep the tower accepted with limitation.** Its large-form family works at
  player distance. Refinement is worthwhile only as part of the Building 1 pass.
- **Do not integrate or accept the Isle House low prototype yet.** Its concept is
  source-grounded and promising, but no ordinary-player visual proof exists and
  the eight identical assemblies risk reading as another procedural stamp.

The target is believable game art: a player should see why a facade is built the
way it is, where its weight sits, where people enter, and which form is the focal
one. Survey-perfect reconstruction, interiors, tiny ornament, and detail that
disappears at normal camera distance are not required.

## Evidence and review boundary

The following original-resolution evidence was inspected individually:

- Building 1: all eight `1440x900` frames in
  `evidence/first-playable/building-1-hero-2026-09-04/images/`;
- tower: both superseding grounded `1440x900` frames in
  `evidence/first-playable/building-1-tower-grounded-correction-2026-09-04/images/`;
- Hawkins: both current P1 grounded `1440x900` frames in
  `evidence/first-playable/p1-existing-live-revalidation-2026-09-04/images/hawkins/`,
  plus the accepted close/ordinary massing frames in
  `evidence/first-playable/77-bruton-massing-2026-08-29/`;
- Building 3: both new `1440x900` frames and the immutable before pair named in
  `evidence/first-playable/building-3-hero-massing-2026-09-04/`;
- Isle House: the two P1 whole/low diagnostic frames and the standalone low-part
  mapping, config, material, and module specification. There is no rendered
  prototype evidence, so the low-part visual verdict remains **unreviewed**.

The Building 1 and Hawkins image packets predate later isolated runtime/router
edits. Their target-specific accepted art is the reviewed state, but this is not
a new byte-for-byte evidence signing. Any corrective build needs fresh
exact-current captures. Building 3's current massing and facade hashes match its
latest packet. Technical contracts, metadata, and prior reviews were used only
after the pixels to understand truth boundaries; they do not create the art
verdict.

Primary-source cue packets used:

- `discovery/facades/TREASURE_ISLAND_BUILDING_1_HERO_RECOGNIZABILITY_SPEC.md`;
- `discovery/facades/p1_reference_packets/w1249412093_hawkins.md`;
- `discovery/facades/p1_reference_packets/w34313540_building_3.md`;
- `discovery/facades/p1_reference_packets/w1249412094_isle_house.md`; and
- `discovery/facades/isle_house_low_part/ISLE_HOUSE_LOW_PART_RUN_MAPPING.md`.

No source photograph was copied into this review.

## Rating scale and additional gate

Ratings are intentionally coarse:

- `5` — distinctive and convincing at normal play distance;
- `4` — strong, with a minor or local simplification;
- `3` — serviceable low-poly game art; believable but visibly economical;
- `2` — the intended cue exists, but it reads as flat, generic, or diagrammatic;
- `1` — placeholder or misleading.

The **BELIEVABILITY / VISUAL-INTEREST** gate asks whether the ordinary-player
image has coherent construction, a readable focal hierarchy, useful depth and
contact shadows, controlled repetition, and material/value response that
supports rather than replaces form. Recognition can remain accepted when this
new gate fails; the failure opens a bounded quality pass, not a demand for
photorealism.

| Unit | Silhouette / massing | Facade hierarchy / depth | Material / value | Visual interest | Player-distance read | New gate | Existing verdict guidance |
| --- | ---: | ---: | ---: | ---: | ---: | --- | --- |
| Building 1 `r16681702` | 4 | 2 | 2 | 3 | 4 | **FAIL_CORRECTABLE** | Keep recognition accepted; reopen a focused public-front quality pass |
| Tower `w1222720021` | 4 | 3 | 2 | 3 | 3 | **PASS_WITH_LIMITATION** | Keep accepted; refine only with Building 1 |
| Hawkins `w1249412093` | 4 | 4 | 3 | 3 | 4 | **PASS_WITH_LIMITATION** | Keep accepted; optional evidence-bounded polish |
| Building 3 `w34313540` | 4 | 2 | 2 | 2 | 4 | **FAIL_CORRECTABLE** | Keep recognition accepted; reopen a focused hangar-end quality pass |
| Isle House low prototype `w1282547787` | concept: 3 | concept: 3 | concept: 3 | concept: 3 | unreviewed | **UNREVIEWED** | Remains standalone/pending; require visual A/B before integration |

## 1. Building 1 — keep the identity, rebuild the focal hierarchy

### What already works

- The truncated concave public front and `2/3/4`-story hierarchy create a strong
  whole-object read.
- The eleven tall center bays, lower wings, paired end families, long canopy,
  and rooftop tower make this unmistakably different from either hangar.
- The composition survives changed light and a wider ordinary view. It does not
  need photorealism or measured dimensions to remain recognizable.

### Why the new gate fails

The ordinary front still reads like windows drawn onto one pale extruded mass.
The center bays have little visible reveal, the pilaster rhythm has little
weight, and the canopy/base/three-door entrance does not become the focal point
that visually supports the tall center. Most materials collapse to the same
light value at distance. The result is legible architecture but not yet a
convincing place.

The end plaques are a special semantic problem: the high-contrast red-brown
vertical plaque plus crossbar reads more like a cruciform sign than the
documented figure-and-airplane relief family. It is disclosed as abstract and
was not counted for recognition, but it remains a visually prominent wrong
suggestion. A wrong high-salience symbol is worse than a quiet neutral panel.

The rear/east face is honestly unclaimed, but its uninterrupted pale acreage is
so large that it reads as unfinished world geometry. Evidence restraint should
remain; believable non-architectural continuities such as a base, roof edge,
material field, and structurally coherent corner return can be carried around
without inventing a window schedule.

### Smallest high-leverage correction

Do one **public-front depth and entrance pass**, not an all-sides detail pass:

1. recess the eleven dark glazing fields enough to create a stable reveal at
   ordinary distance, and let the fluted pilaster/frame family project slightly;
2. give the long canopy a readable leading edge and shaded underside, then
   recess the three bronze/glazed entrance groups behind it;
3. separate the rusticated/projecting base from the upper ivory field through
   both depth and a restrained value/roughness change; and
4. replace the cruciform-looking end plaque with either a semantically faithful,
   rights-safe low-relief aeronautical proxy or a quieter neutral relief field.

This is one coordinated hierarchy repair. It should preserve the accepted
footprint, story tiers, eleven-bay count, end-window family, tower, collision,
spray, and traversal. It need not add literal sculpture, interiors, or surveyed
ornament.

**Recommendation:** reopen for the new visual gate while retaining its current
recognition acceptance.

## 2. Building 1 observation/control tower — form succeeds, finish is thin

### What already works

The grounded pair shows a compact multi-sided glazed enclosure, wider railed
platform, and pyramidal cap. Those three large families survive at only about
`108–125 px` projected size. The silhouette is economical and believable enough
for this project's low-poly language.

### Limitation and smallest improvement

The enclosure is nearly a black cylinder with white bars, the rail is visually
fragile, and the platform/roof materials have little response hierarchy. The
form passes because it is small and coherent, not because the finish is rich.

If Building 1 is already being touched, strengthen the platform fascia and
balustrade silhouette, distinguish roof metal from glazing under changed light,
and give mullions enough thickness to remain stable without becoming a white
cage. Do not enlarge the whole tower merely to make details readable, and do not
add a stair unless a bounded placement is supported.

**Recommendation:** do not reopen as an independent blocker. Bundle this polish
with the Building 1 correction and recapture the grounded pair.

## 3. Hawkins — current quality benchmark, with disciplined restraint

### What works

- The six-/four-story step is clear in both current views.
- The dark ground/lobby/service zone visibly carries the light residential
  volume; the building does not float on a generic base.
- Upper-window cadence, stepped mass, and the ground-zone sequence cooperate.
  The result remains Hawkins even when the tiny name is ignored.
- Observed principal sides are articulated while unobserved returns stay quiet.
  This is a good example of evidence restraint that does not erase the whole
  building's identity.

### Optional high-leverage improvement

The ordinary view still compresses the dark ground band into a long strip, and
the orientation-active pearl fluting is mostly invisible. A later principal-side
pass could deepen the lobby/stoop/service thresholds and tune the existing
fluted material so it changes gently under light without moire or glitter. The
blank return should remain module-free unless direct evidence appears; improve
its material continuity and edge conditions, not its invented opening count.

**Recommendation:** keep accepted. Use Hawkins as a calibration target for
future mid-rise work; polish is nonblocking.

## 4. Building 3 — strong silhouette, weak construction read

### What already works

The curved/barrel crown and raised end shoulders transform the former flat box
into a recognizable hangar. One dominant opening and the separate upper band
survive both ordinary views and distinguish the target from Building 2's twin
gridded monumental composition. This is a real recognition success.

### Why the new gate fails

The main opening remains a flat near-black rectangle pasted onto a pale end.
There is no convincing jamb/header thickness, panel scale, track/contact, or
shadowed recess. The shoulders are recognizable in silhouette but too weakly
modeled and valued to read as load-bearing pylons. The upper band is a thin dark
line. From the oblique, the roof establishes depth but the wall still looks like
a diagram of a hangar rather than a built hangar.

### Smallest high-leverage correction

Turn the one dominant opening into a **single believable hangar-door assembly**:

- recess the door plane behind a thick, pale jamb and header;
- add a restrained large-panel or vertical-joint rhythm as disclosed production
  inference, never a second opening or facade-photo wallpaper;
- ground it with a subtle threshold/track and contact shadow; and
- strengthen the four pylon/shoulder faces and their low tops just enough that
  the crown visibly terminates into them.

Keep the broad quiet wall, exact footprint, one-door grammar, crown, source IDs,
wall spray ownership, and congruent roof/wall collision. Do not invent long-side
windows or a WSW schedule.

**Recommendation:** reopen for the new visual gate while retaining its current
recognition acceptance.

## 5. Isle House low-part prototype — promising grammar, visual proof required

### Concept keep

The mapping makes a good art-direction choice: warm dark brick at eye level,
large two-level glazing, an individual half/Dutch-door entry, and a shallow
patio threshold are a much better recognition family than a generic repeated
wall texture. The exact Avenue/Garden Walk mapping and protected NNW/upper/roof
regions are disciplined. Keeping the module render-only and shallow is also
appropriate for a first facade pass.

### Concept change before integration

Eight instances currently share the same 19-box assembly. That may be
technically clean yet visually read as a stamped storefront kit. The module also
has only `0.1 m` maximum relief, so glazing, door, brick piers, and patio edge may
collapse into one plane. There is no rendered evidence to show otherwise.

Do not solve this with random offsets or noise. First capture the exact standalone
prototype from the Avenue and Garden Walk sides. If repetition dominates, use at
most two or three **source-observed** door/gallery variants—such as a genuinely
observed mirrored door relationship or different complete bay width—while
retaining one shared structural grammar. Strengthen the entry recess, header,
brick-pier weight, and threshold depth before varying colors. If the sources do
not support a variant, keep a consistent module and let the mapped run spacing
provide variation.

The untouched `y=10.25..19.103` band, protected NNW side, and five-level versus
real seven-story podium mismatch still prevent whole-composite acceptance. The
low prototype should not be asked to hide that massing problem.

**Recommendation:** keep standalone and pending. Require a grounded A/B visual
review before any world-builder attachment.

## Cross-project art direction

1. **Recognize in three seconds.** At the nearest normal route, a building should
   have one big-form cue and one facade/focal cue before fine surface detail is
   considered.
2. **Use three depth bands.** Major massing/crown is geometry; openings and
   entrances have readable recess/projection; material relief stays shallow.
   A facade where everything sits within a few centimetres will read as a decal.
3. **Spend detail at decisions.** Entrances, canopies, corners, crowns, and
   volume transitions deserve contrast. Long secondary walls should remain
   quieter. A useful target is roughly 20% focal articulation and 80% supporting
   field, adjusted to the reference.
4. **Let structure organize rhythm.** Window and pier cadence should explain
   floors, spans, or bays. Never distribute motifs merely to fill surface area.
5. **Use value before color.** A building must still read in grayscale. Reserve
   the darkest values for openings/recesses and the sharpest light/dark edge for
   the focal entrance or crown. Hue is supporting information.
6. **Create controlled exceptions.** A repeated family needs a reference-backed
   entrance, end bay, corner, or volume transition. Random variation creates
   noise; perfect cloning creates procedural wallpaper.
7. **Preserve quiet unknown sides without leaving them raw.** Continue material,
   base, parapet/cornice, and physically necessary edge logic when supported.
   Do not invent doors, windows, signs, or service programs.
8. **Make contact credible.** Doors need thresholds, deep openings need jambs,
   canopies need undersides, roofs need edges, and heavy masses need bases. Tiny
   contact shadows often add more believability than many extra motifs.
9. **Judge at player distance.** Detail that is visible only in an elevated or
   extreme close-up does not earn recognition value. Detail that shimmers,
   aliases, or becomes noise at distance is a defect.
10. **Keep one island art language.** Reuse a small material family and common
    modeling grammar, but give each building a reference-backed silhouette,
    cadence, or focal assembly that separates it from nearby decoys.

## Geometry versus material

| Recognition problem | Geometry / complete module owns it | Material owns it |
| --- | --- | --- |
| silhouette, story step, tower, barrel crown, deep roof form | **always** | never |
| entrance canopy, large door recess, pylon, deep window reveal, podium/base projection | **always** | contact and surface response only |
| window/door/stoop cadence visible at normal play distance | complete placed modules | frame coating, glass response, shallow seals |
| panel, brick, flute, joint, or board rhythm | geometry/shader if it changes silhouette or has a fixed architectural period | shallow surface-scale rhythm only |
| stucco aggregate, paint variation, pores, fine mortar, subtle weathering | no | **yes** |
| signage, plaques, murals, emblems | target-specific modeled/rights-cleared art | never hallucinated into a repeat tile |
| fixed shadow, reflection, bright edge, deep crack | real lighting/geometry | never baked into albedo/AO |

Recognition should come primarily from geometry, cadence, and focal assemblies.
Materials make those forms feel built. A beautiful texture cannot rescue the
wrong massing, and a correct silhouette can still feel like a blockout when all
surfaces have one flat response.

## Why textures are difficult, and where generative imagery is viable

The difficult part is not obtaining an attractive square image. One material
must remain semantically correct across both joins, keep the same physical scale
on every receiver, survive mipmapping and changed light, avoid visible macro
repetition over a 100-metre facade, and contain no feature that ought to be
geometry. Generative imagery often produces excellent local pixels while
quietly baking a highlight, warping a brick at the edge, inventing a sign, or
creating a stain that becomes an obvious repeated landmark.

Generative imagery is viable here as a **candidate source for neutral,
seam-validated micro-surface fields**. It is not viable as a whole-building
facade generator or a substitute for exact modules. Prefer generating one
neutral albedo/height candidate, then deriving or authoring coherent roughness
and OpenGL normal behavior from the accepted structure. Do not independently
prompt three maps and assume their pixels align.

### Six high-value shared material families

All spans below are reversible art calibration, not real-product measurements.
Start at `1024x1024`; use a larger source only if native and ordinary views prove
that 1024 is insufficient after import. `L*` refers to perceptual albedo value,
before scene lighting.

| Family | Best use | Candidate physical span | Albedo/value boundary | Relief/response boundary |
| --- | --- | ---: | --- | --- |
| Warm mineral stucco | Building 1 and pale historic civic faces | `2–4 m` square | median `L* 68–82`; 95% within `55–88`; microvariation <= `6 L*` | pores/aggregate only, roughly `1–3 mm`; roughness `0.72–0.90` |
| Pale painted concrete | hangars and institutional blocks | `3–6 m` square | median `L* 58–76`; long-wave drift <= `5 L*` | pores/formwork/patching <= `5 mm`; no structural cracks; roughness `0.68–0.88` |
| Warm handcrafted brick/tile microfield | Isle House low realm and supported residential bases | `2–3 m` square | brick median `L* 28–48`; mortar `L* 42–65`; no clipped highlights | bond and mortar must pass semantic joins; relief <= `15 mm`; roughness `0.72–0.92` |
| Dark bronze / coated entrance metal | Building 1 entry and supported civic accents | `0.8–1.5 m` square | median `L* 12–32`; 95% above `L* 6`, never featureless black | separate exposed bronze from coated steel; no fake reflection; roughness `0.35–0.68` |
| Industrial coated-door microfield | Building 3 and supported hangar doors | `2–4 m` square | median `L* 16–38`; local variation <= `6 L*` | panel joints belong to modules/shader; coating is dielectric; roughness `0.48–0.72` |
| Pearl cladding microfield | Hawkins observed principal sides | `1–2 m` square | median `L* 72–86`; microvariation <= `4 L*` | combine with deterministic flute normal/roughness; do not ask GenAI to preserve a `0.064 m` architectural period |

Glazing is intentionally absent from this list. It should be a controlled game
material or module, not a tile containing generated sky, rooms, reflections, or
lights.

### Mandatory generation, tile, UV, and value constraints

- One Godot unit remains one metre. Record the selected span and use one
  metre-based UV phase per continuous facade chain; do not restart the texture
  at every source triangle or wall run.
- A tile may contain only the declared local material. Reject windows, doors,
  vents, facade bands, letters, numbers, emblems, plants, people, perspective,
  cast shadows, sky reflections, and directional highlights.
- Reject clipped white or black. Across the final albedo, keep the first and
  ninety-ninth percentiles inside roughly `L* 5–92`, with the tighter family
  ranges above. Preserve at least `8–12 L*` separation between focal openings
  and their surrounding field at normal distance.
- Use identical UV transforms for aligned maps. Roughness, height, AO, and
  normal are linear data; albedo is sRGB. Use an OpenGL normal map in Godot.
- Do not bake sun shadows, canopy shadows, deep reveals, window interiors, or
  ambient facade occlusion into a repeat tile. AO may describe only local pores
  or mortar cavities.
- Inspect native borderless `3x3`, boundary-overlay `3x3`, half-X/Y/XY rolls,
  and a large macro repeat. A smooth pixel join still fails if it creates,
  narrows, doubles, or deletes a brick, flute, joint, pore cluster, or stain.
- Use mipmaps, linear filtering, and anisotropy. Reject shimmer, moire, crawling
  normal detail, synchronized stains, obvious four-way crosses, and a readable
  repeat grid at any normal movement speed or camera distance.
- Keep macro variation separate from the base cell and very low contrast. Do
  not make every building dirty in the same corners, and do not use procedural
  noise as a substitute for local architecture.

### One small A/B pilot

Use Building 1's accepted public front because it is the owner's stated priority
and its broad pale field exposes both improvement and failure clearly.

- **A/control:** current warm-ivory material and unchanged accepted geometry.
- **B/candidate:** one seamless generated warm-mineral microfield with the
  `2–4 m`, `L*`, roughness, and shallow-relief bounds above. No facade features.
- Keep geometry, modules, lighting, exposure, camera, and import settings fixed.
- Capture the same stock-player `70°`-FOV grounded public-curve view, a grounded
  close oblique that shows several repeats, and the same public-curve pose under
  changed light, all at `1440x900`. Add a short walking sweep to expose shimmer.

The B candidate passes only if an independent reviewer prefers it for believable
painted mineral in both ordinary views, the entrance/window value hierarchy is
not weakened, no seam or repeat grid is visible from approximately `5–80 m`, no
highlight or shadow remains fixed when the light changes, and the walking sweep
shows no shimmer. It does **not** earn a recognition claim by itself. If B merely
looks noisier, keep A and spend the next effort on entrance/reveal geometry.

## Ranked top-ten corrections and opportunities

1. **P0 — Building 1 public-front depth hierarchy:** recess center glazing,
   project pilasters, and make canopy underside plus three-door entrance the
   focal assembly.
2. **P0 — Building 1 end-relief semantics:** remove the cruciform read; use a
   semantically faithful low-relief aeronautical proxy or a quiet neutral panel.
3. **P0 — Building 3 hangar-door construction:** add a real recess, header,
   jambs, restrained large-panel rhythm, and grounded threshold without adding a
   second door.
4. **P0 — Isle House low visual proof:** capture the standalone exact receiver
   from both mapped sides before integration; reject a stamped-kit result.
5. **P1 — Building 3 pylon/shoulder termination:** strengthen the four anchors
   enough that the curved crown visibly lands in them from both ordinary views.
6. **P1 — Building 1 material A/B:** run the single warm-mineral GenAI pilot;
   retain it only if it improves believability without noise or false features.
7. **P1 — Isle House low module hierarchy:** deepen entry/glazing/threshold
   relationships and permit only source-observed complete variants, never random
   per-instance mutation.
8. **P1 — Hawkins principal-side depth:** make lobby, service, and stoop
   thresholds read as different built conditions while preserving module-free
   unknown sides.
9. **P1 — Shared edge grammar:** give evidence-safe quiet walls coherent bases,
   corners, parapet/cornice edges, and material continuity so “unknown” does not
   look “unfinished.”
10. **P1 — Batch review hardening:** add grayscale and short-motion checks to
    the two grounded ordinary views; reject detail that only succeeds in labels,
    elevated diagnostics, extreme close-ups, or a single favorable light.

## Reusable bar-raiser checklist

Apply this after the strict provenance/receiver gate and before promotion:

### Blind ordinary-player read

- [ ] Inspect at least two distinct grounded stock-player views before labels,
  manifests, source IDs, or builder prose.
- [ ] Name the visible big-form cue and facade/focal cue in plain language.
- [ ] Confirm top-1 separation from at least two close island decoys without
  color, address, signage, or map location carrying the match.
- [ ] Check a grayscale read and a materially changed-light view.

### Believability / visual interest

- [ ] Silhouette and major massing are unmistakable at normal route distance.
- [ ] Entrance, canopy, crown, corner, or volume transition creates one clear
  focal hierarchy; the whole facade is not equally loud.
- [ ] Deep features have visible depth/contact; shallow material detail does not
  impersonate geometry.
- [ ] Window, pier, panel, and door rhythm explains the building rather than
  filling space.
- [ ] Repetition is controlled, with only evidence-supported complete variants;
  no stamped modules or random noise.
- [ ] Materials separate field, frame, opening, base, and focal element in value
  and roughness while remaining subordinate to form.
- [ ] Large unknown sides are restrained but have coherent base, edge, corner,
  and material continuation rather than raw placeholder acreage.
- [ ] No obvious floating quad, paper-thin canopy, black void, missing jamb,
  unsupported slab, z-fight, or mismatched visual/collision form is visible.

### Truth and scope

- [ ] Every prominent cue is a verified fact, reference observation, or clearly
  bounded production inference; no contradiction is hidden behind “stylization.”
- [ ] No hallucinated sign, token plaque, arbitrary color swap, facade-photo
  wallpaper, copied neighboring schedule, or invented unobserved-side program
  contributes to acceptance.
- [ ] Tiny ornament, interiors, surveyed dimensions, and photoreal finish are
  not demanded unless they materially change recognition or safe geometry.
- [ ] The smallest high-leverage fix is stated when the new gate fails.

### Material and motion

- [ ] Physical span, pixels per metre, UV phase, repeat axes, channels, and
  import settings are recorded.
- [ ] Native `3x3`, roll, macro, changed-light, and receiver-distance proofs pass.
- [ ] No baked light, seam-created motif, macro grid, moire, shimmer, crawling
  normal, or value clipping appears while walking.

### Decision

- [ ] Report recognition, believability/visual interest, as-built fidelity, and
  technical integrity as separate verdicts.
- [ ] A green test or “more detail than before” is not an art pass.
- [ ] Preserve an accepted recognition verdict unless the new evidence actually
  undermines identity; otherwise open a bounded polish item.

