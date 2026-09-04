# Independent visual bar-raiser review — 1439 Chinook standalone hero

Date: 2026-09-04  
Reviewer: `/root/d6_reference_research`  
Target: 1439 Chinook Court, source `w95934144`  
Review scope: sealed isolated prototype and evidence only; no production implementation by this reviewer

## Decision

**PASS, with nonblocking limitations, for exactly one future reversible,
fail-closed live study.**

The standalone establishes a believable and visually specific 1439 read without
depending on its warm tint, name, source ID, or map location. Its strongest cue
is the ordered asymmetric value/depth sequence along the public side:

1. one offset, deeply shadowed two-level balcony stack;
2. a broad and unusually quiet upper register with only three separated dark
   opening groups; and
3. a near-blank opposite end terminating in one ground passage.

That sequence survives whole-building distance, oblique views, changed light,
and the complete declared motion interval. It is materially different from
the balanced-wing/central-recess composition of 1441 Chinook and from the two
broad undercroft fields plus far narrow balcony stack of 1444 Croaker.

This is **not** live recognition acceptance. The prototype remains unattached,
unregistered, and worth **+0** recognized buildings. No catalog, registry, or
metric may change until the proposed live study itself passes an independent
live-world visual review. The unavailable appearance evidence for 1437 and
1438 also prevents a final all-confusion-set top-1 claim at this stage; that is
a disclosed final-acceptance limitation, not a reason to block a reversible
study.

## Evidence and authorities reviewed

- repository `AGENTS.md`;
- authoritative D2 packet
  `discovery/facades/d2_reference_packets/w95934144_1439_chinook_court.md`;
- the 1439 README, capture/motion manifests, source/technical/evidence/package
  contracts, checksum ledger, config, factory, and focused tests;
- all six 1440x900 same-pose baseline/prototype stills, including the changed-
  light pair;
- the derived motion contact sheet and every process frame in the declared
  endpoint-inclusive range 64-184 (dense sequential sheets for 64-183 plus the
  final frame at native size) from the sealed 191-frame MJPEG AVI;
- the 1441 Chinook and 1444 Croaker standalone READMEs, implementations,
  evidence, and independent bar-raiser reviews, with their public-side after
  views inspected directly for confusion comparison;
- the package-approved Site-12 stucco promotion receipt and independent package
  audit.

`shasum -a 256 -c CHECKSUMS.sha256` passed for every declared 1439 artifact.
The reference packet remains pinned at
`050ceb6195bf1f7a4b1c753cde5a509c30b0911599af9233db5746605b9cfeb6`.

## Cold visual read

### Identity without labels or hue

The target still reads after mentally discarding the small warm/cool material
difference. The high-value wall field and dark apertures do most of the work:
the balcony is a large double void rather than a repeated window rhythm, the
middle is conspicuously sparse and upper-only, and the far passage is isolated
under a blank upper wall. These are solid/void facts, not color coding.

The silhouette alone is intentionally modest: two low levels, a shallow dark
gable/eave, and footprint-driven steps. It would not carry identity by itself.
The added depth hierarchy completes the read. Balcony recess, projecting slabs,
rails, framed upper openings, passage shadow, passage piers, and continuous
eaves establish foreground/midground/background layers while leaving large
quiet solids intact.

At the widest supplied view, the individual pickets are nearly lost, but the
two balcony voids and slabs remain legible. The three upper opening groups and
lone passage also remain separable. At oblique and walking distances the rails,
recess depth, eave projection, and footprint steps add enough visual interest
to prevent the structure from reading as a decorated box. This is the right
priority order: large identity shapes survive first; small rail detail enriches
the closer read without being required for recognition.

### Exact public-run discipline

The implementation and contracts preserve the packet's exact partition:

| Run set | Reviewed treatment | Verdict |
| --- | --- | --- |
| `11,12,16,17,18,19,22,23` | warm public-side receiver field and mapped eave chains only | PASS |
| `11` | offset recessed two-level balcony stack | PASS |
| `19` | three separated upper-only opening groups across a broad quiet field | PASS |
| `23` | one deep passage with two piers below a near-blank end | PASS |
| `12,16,17,18,22` | mapped continuation only, no addressable motif | PASS |
| `17,18` | tiny clipping fragments, no standalone motif | PASS |
| `0-10,13-15,20,21` | exact neutral protected source walls | PASS |

No lower window/door schedule was invented behind the documented screening.
No motif spills onto a continuation fragment or protected return, and no
neighbor facade schedule is borrowed. The three mapped eave chains give the
public sequence a coherent cap while respecting footprint breaks.

### Confusion comparison

- **Versus 1441 Chinook (`w95934105`): PASS.** 1441 is balanced around paired
  central two-storey recesses and densely windowed projecting wings. 1439 has
  one end stack, one broad quiet middle, and one isolated passage end. Even
  with both buildings using the same promoted warm-ivory stucco, their void
  distribution and balance are plainly different.
- **Versus 1444 Croaker (`w95934117`): PASS.** 1444's dominant public-side
  signature is a broad blank upper mass directly over two adjacent undercroft
  fields, followed by a stepped sparse return and a narrow far two-level
  balcony stack. 1439 instead presents a single large end stack, no two-field
  undercroft rhythm, three upper-only middle openings, and one opposite passage.
  The ordered value pattern distinguishes them without ochre versus ivory.
- **Versus 1437/1438 Chinook: unresolved for final acceptance.** Their packet
  appearance states remain blocked. The 1439 prototype is specific enough to
  advance, but this review does not pretend unseen peers were visually tested.

## Material and motion judgment

The promoted stucco is a restrained neutral field, not an identity decal. In
the native stills I found no obvious hard tile seam, baked highlight or shadow,
high-frequency moire, or distracting repeated landmark. The changed-light pair
moves form shadows across the balcony, piers, eaves, and footprint breaks while
the albedo character remains stable. The texture's recurrence is faint and its
surface relief is subtle—sometimes nearly scalar at player distance—but that is
preferable to a conspicuous synthetic pattern on this broad quiet facade.

I inspected the entire declared four-second walking interval rather than only
the contact-sheet samples. Across frames 64-184 there is no visible texture
crawl, shimmer, seam pop, lighting baked into the albedo, or objectionable rail
flicker. Aperture and eave edges move consistently. MJPEG compression softens
fine grain, so the native PNGs remain the stronger static seam check; both forms
of evidence agree.

Tileability is therefore adequate for this bounded stage. A faint repeat or a
minor edge mismatch would be nonblocking under the stated progress-first rule;
neither rises to distracting prominence here. The Site-12 promotion receipt
also pins the exact lossless/mipmapped warm-ivory source at SHA-256
`af1c7a8f90ab5e60b9ab40a3bcf087aa26b00892edd48a2b4f1c84533f8be51c`,
approximately 3 m repeat, with no generated normal, roughness,
AO, height, or displacement map. The source-pixel boundary is clean: text-only
generated neutral material, no retained third-party or target-photo pixels.

## Capture, package, and ownership integrity

- The stills use the actual stock `Player/CameraPivot/SpringArm3D/Camera3D`
  path, visible grounded player, 70-degree FOV, and exact before/after camera
  reuse. The full entity is shown in an isolated neutral fixture; no crop,
  telephoto trick, debug overlay, or hidden live context is presented as proof.
- Motion is a stock-player `move_right` walk: 4.0 seconds, 240 physics frames,
  15.8669 m displacement, public-tangent absolute dot `0.939965`, no run input,
  all samples grounded, zero recovery, zero camera-orientation change, and zero
  transform writes after input begins.
- The exact PCK remains SHA-256
  `ecaaa6cf48b7a2d5ac8206bd7bb409ae768d40df00ed0f3ca049a17ce650c8e6`,
  65,421,188 bytes. I independently mounted it from outside the checkout; the
  target-specific package closure passed and found one exact structural shell,
  its required materials, the frozen source pair, and no discovery/evidence or
  pilot-only payload.
- The prototype rebuilds as 11 meshes/surfaces and 574 visual triangles with
  deterministic signature
  `b82660eb7774ab022c417c7d417d51646f68fd288d916ad47a91d58db5bc8fb9`.
  It owns one structural body/shape with 58 collision triangles, no fallback
  collider, no navigation, no spray, no runtime attachment, and no registry
  entry. Relief remains noncolliding.

These checks passed independently during this review:

- `headless_d2_1439_chinook_standalone_hero_contract.gd`;
- `headless_d2_1439_chinook_standalone_hero_evidence_contract.gd`;
- `headless_d2_1439_chinook_standalone_hero_package_contract.gd` against source;
- the same package contract mounted from the retained PCK outside the checkout.

## Ranked findings

### Blocking failures for the proposed live study

None.

### Nonblocking limitations, highest priority first

1. **Very dark voids compress semantic detail.** In the frontal whole view,
   the balcony fields and lone passage can momentarily read as large opaque
   glazing or garage-like panels. Recess depth, slabs, piers, and the oblique
   read resolve them. The live review should verify terrain and ambient light
   do not flatten those depth cues; do not invent interiors to solve it.
2. **Rails are a near-distance cue.** Ten slim pickets are credible and stable,
   but mostly disappear in the widest view. The slabs and paired voids carry
   identity adequately. Do not thicken or multiply rails unless live evidence
   shows the balcony stack itself is lost.
3. **The shallow eave is quiet.** Its thin dark line usefully unifies the SSE
   runs and reveals footprint steps, but it is not a dramatic silhouette. This
   is consistent with the reference boundary and should not be exaggerated for
   spectacle.
4. **Stucco character is deliberately subtle.** Its faint recurrence is
   acceptable and temporally stable, but it will not add much close-up richness.
   Preserve the quiet field until a live review demonstrates an actual need;
   high-frequency texture would compete with the solid/void signature.
5. **Two authoritative peers remain appearance-blocked.** Final recognition
   acceptance must revisit 1437/1438 when honest evidence exists. The current
   study may compare only the implemented 1441/1444 peers and must disclose the
   missing comparisons.

## Authorized next step and stop condition

The approved next step is one isolated, reversible live attachment study at the
exact `w95934144` receiver. It must default fail-closed, avoid a duplicate shell
or fallback ownership path, preserve the exact run/motif partition above, and
make no catalog or recognition claim. Review it from stock-player public
approaches under ordinary world light and terrain, with 1441 and 1444 comparison
views available. If the balcony/middle/passage ordering or the depth hierarchy
collapses in context, disable the study and return to standalone evidence.

Only a new independent live-world review may authorize acceptance. Until then:
**standalone visual gate PASS; live recognition +0.**
