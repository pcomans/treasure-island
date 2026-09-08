# D2 1441 Chinook Court — independent v9 release visual review (`-001`)

- Reviewer: `/root/v9_release_visual`
- Review date: `2026-09-07`
- Scope: recognizability, believability, player-view truth, confusion-set
  separation, material/motion stability, and visual non-regression for only the
  exact postpromotion candidate bound below
- Target: `physical-building:w95934105`, 1441 Chinook Court
- Credit effect: none; v9 authority already records the one accepted unit, and
  this downstream release review grants no additional recognition credit

## Exact candidate and upstream binding

- Evidence root:
  `evidence/first-playable/d2-1441-postpromotion-v9-2026-09-07-001/`
- Canonical 40-file packet-tree SHA-256:
  `60f9c875d3429347047525beab75310073e971af78e6445b551b6586a79cb45e`
- Static capture manifest SHA-256:
  `50ab60b3f509ac30b26dbb98ea03bf8f8cc4b1b4c4054f87204e8af6f16797d1`
- Consecutive motion telemetry SHA-256:
  `dbbe6f53bd6f176cf4760faa6684d306265327635fe6b53d8917bfa78ac2f171`
- Visual-motion manifest SHA-256:
  `5392cb8e2942fdeda033482c2658fd5a842c6d28abedf1ddfe7c7488664790ea`
- Package-verification receipt SHA-256:
  `61b63b0ad7aac01039e4f1e2125268c5e1900e047b3077e785c00893a85a6a59`
- Capture override SHA-256:
  `edbc0b9caa60fa0fc6b83cebb3145bce11ce0bd976403ca1d2fbe9b7142b39c3`
- Capture generator SHA-256:
  `ab315b37b6a7f7f07105bc26f464d0d3e50c02b1d082e2643169eec47949214c`
- Receipt generator SHA-256:
  `1ead2f87ab103d42d483473f40d0fff383cef46f35dd6e5ce55b339e92cf611d`
- Upstream independent semantic audit:
  `evidence/reviews/d2-1441-promotion-v9-2026-09-07-INDEPENDENT_SEMANTIC_AUDIT.md`
- Upstream semantic-audit SHA-256:
  `3388576780493b6116c126684072426ad22279b9a3508127a0ffc8bcb77f9700`
- Upstream semantic-audit raw verdict:
  `PASS_FOR_V9_POSTPROMOTION_EXPORT`

I independently recomputed the packet tree from bytewise-sorted `./relative`
file records, all five top-level packet hashes, all 35 declared image hashes,
byte counts, and dimensions, all 40 dependency hashes in each of the three
capture documents, all 47 receipt source hashes, and the upstream audit hash
and sole raw verdict line. The packet contains exactly 40 ordinary files, no
symlinks, 14 still PNGs, and 21 motion PNGs. Every PNG is actually and
declaratively `1440x900`. No mismatch was found.

This review is downstream-only. It does not bind a sibling mechanical review or
itself, and no current v9 authority file binds this packet or either downstream
postpromotion release review. The packet, all manifests, and the receipt set
`recognition_credit=false`, `additional_recognition_credit=false`, and
`promotion=false`.

## App and exact-current authority

- App:
  `build/d2-1441-postpromotion-v9-2026-09-07-001/Treasure Island First Playable.app`
- Seven-file bundle identity SHA-256:
  `f83ddd5678086099d66fc433c0851fc2788c42e702d8bffac4eee4d7a7d595cb`
- Executable SHA-256:
  `cf0bd6e789e9317248b1aeb2eb626cfd76b837fef362eca449336644cff77941`
  (`170,963,648` bytes)
- PCK SHA-256:
  `0945ac7b08ebd2fc5389ffa05a919b7324ecb298dac46032c8fdc30d8c47404a`
  (`66,300,344` bytes)
- Geometry signature:
  `b91b373e3bb8238a6f73f05734ef48b3429ae5654eddce89b1981ee41ee89195`
- Live ownership signature:
  `fcad9968be3d0c9094adef5dcc9c7fabfb7cf1754f780897188a4ec362187e4d`
- Canonical wall hash:
  `00f3cd8b90e7ae93f802842b59bb10274f1fc388433e5b5c6cae1f3e23f4393c`
- Canonical roof hash:
  `e7da0179f012e928f575ac32440e176a0f3b9651fc325a594de80ce7e3fc9d55`

The bundle contains exactly the seven receipt inventory files; every hash and
byte count matches, and the bundle identity reproduces the receipt. The current
authority source bytes reproduce the receipt and upstream semantic-audit pins:

| Current v9 authority artifact | SHA-256 |
|---|---|
| `discovery/facades/facade-recognition-catalog.json` | `dc6d121d48621f98a203f2fea458316a46446a11e5f2a77d4064694322b2baa2` |
| `discovery/facades/facade-recognition-catalog.schema.json` | `8896fb9dcfd1cb48fc4bf0ed7ddc5fa50fdf7ec31335111291a1e2a2006e106d` |
| `game/resources/facades/facade-runtime-registry.json` | `26dcf64a34cf92aa7766c60940933190cdb5f9bc595dc23dc2f16fa01752e16c` |
| `game/resources/facades/facade-runtime-adapter-contracts.json` | `8c61ea5601ab94852ac593b8658963b52cb5253aae22a2ff109f2e46771caa93` |
| `game/scripts/world/facades/facade_runtime_registry_loader.gd` | `32e63c8774c0589856f15ac2ca0e7458e1cdce1403380e50a6ba99bd5185bd26` |
| `tools/build_facade_recognition_registry.mjs` | `4d6da1afa587d2dd8aefb24775d6ba838dd39ac60131985c9c899209572d3e74` |

The exact registry metric is `9/213`: nine accepted physical units and 204 not
evaluated. `physical-building:w95934105` appears exactly once in the accepted-ID
list. It has exactly one wall-indexed active authority adapter and no roof-indexed
adapter. The postpromotion packet therefore observes already-promoted v9 state
without creating a tenth claim or a second 1441 claim.

## Native-resolution inspection

I opened all `14/14` authoritative stills and all `21/21` authoritative motion
frames individually at their original `1440x900` resolution after the packet was
sealed.

| Still | Concrete observation |
|---|---|
| `01-whole-sse-default` | At an ordinary distant road view, the two pale windowed wings, dark center, and overhanging rooflines distinguish 1441 from the surrounding undressed masses. |
| `02-sse-oblique-default` | The near wing visibly projects ahead of the actual center setback; the second wing, two stacked recess levels, and broad eaves remain spatial rather than painted cues. |
| `03-sse-oblique-changed-light` | The exact same pose under materially changed light preserves the wing/recess hierarchy and opening cadence; stronger edge light does not create or erase the identity. |
| `04-whole-sse-default-grayscale` | Removing hue leaves the same top-1 silhouette, window rhythm, paired dark center, and eave lines, so color is not doing the recognition work. |
| `05-projecting-wings-paired-recess-close` | The near and far projecting wings, actual depth between them, stacked balcony slabs, opaque voids, and rails read clearly at close player distance. |
| `06-shallow-gable-broad-eaves` | The shallow dark roof slopes and long projecting eaves remain visible in a non-hero distant view; the cue is deliberately subtle but present. |
| `07-nearby-context` | 1441 remains the only detailed, windowed, eave-capped residential form amid several nearby generic blocks, without isolation or a privileged crop. |
| `08-protected-return-run11` | The plain protected return terminates cleanly beside the selected stacked circulation geometry; decoration does not spill onto the unobserved side. |
| `09-real-spray-eligible-wall` | The predefined cyan/yellow wavy tag is plainly visible between window rows on the exposed pale wall; it is excluded from the recognition ranking. |
| `10-real-player-roof-landing` | The player is visibly supported on the dark sloped target roof with a contact shadow and coherent roof planes; there is no visual float or false ground read. |
| `11-comparator-w95934144` | 1439 remains an undressed, windowless textured mass and lacks the target's three-cue combination. |
| `12-comparator-w95934143` | 1443 remains a long generic block without twin windowed projections, a paired recessed center, or the target roof treatment. |
| `13-comparator-w95934131` | 1438 remains a collection of generic textured boxes; its footprint articulation does not resemble the target facade hierarchy. |
| `14-comparator-w95934129` | 1440 remains a centered generic mass; even with 1441 visible farther left, the two forms cannot plausibly be confused. |

## Top-1 recognizability and believability

1441 is the unambiguous label-free top-1 result against `w95934144` / 1439,
`w95934143` / 1443, `w95934131` / 1438, and `w95934129` / 1440. Its identity is
carried by the conjunction of:

1. twin projecting, windowed wings;
2. an actual central setback with paired two-level recessed
   circulation/balcony bands; and
3. shallow dark side-gable planes with broad projecting eaves.

The cues survive whole, oblique, close, context, changed-light, grayscale,
spray, protected-return, roof, and moving views. No sign or debug label identifies
the target, hue is disproved by the grayscale frame, the unchanged `70` degree
stock camera is used without crop or postprocess, and the spray is not needed to
pick the building. The result is believable at the requested game-view bar.

The center is still somewhat diagrammatic; rail detail merges into the dark void
at the widest views; inferred openings are regular; the gable is subtle; protected
sides are plain; and the stucco variation is faintly recurrent. These are visible
progress-over-perfection simplifications. They do not flatten the real setback,
detach the wings, erase both circulation levels, or make a comparator competitive.

## Motion, joins, and material stability

The exact six-second route contains 360 consecutive grounded, in-boundary input
samples plus 12 separately recorded braking samples, crosses all three signature
joins, and reports zero player transforms, zero camera transforms, and zero
recoveries. All 21 post-draw frame hashes and engine frames are unique.

- Frames `01`, `02`, and `03` show continuous early far/mid/near parallax while
  both wings, the center depth, window pairs, rooflines, and facade material stay
  attached.
- Frames `04` through `08` bracket join 1 on both sides and at the crossing. The
  left wing-to-center edge remains closed and spatially coherent; no seam opens,
  UV phase jumps, element pops, or rails detach.
- Frames `09` through `13` bracket join 2. The two-by-two recessed bands, slabs,
  rails, and wing shoulders advance smoothly through the head-on portion with no
  shimmer, crawl, moire, flicker, or depth discontinuity.
- Frames `14` through `18` bracket join 3. The far shoulder and center remain
  closed across the crossing; faint stucco variation and the thin eaves do not
  jump, bleed, or float.
- Frames `19`, `20`, and `21` continue the near end of the traverse. Occlusion and
  parallax change monotonically while geometry, lighting, materials, opening
  cadence, and contact with the world remain stable.

Across all 21 frames I found no visible seam, obvious repeat boundary, texture
crawl, shimmer, moire, geometry or material pop, floating facade part, protected
surface bleed, or unstable lighting response.

## Pixel non-regression from prepromotion `-009`

I compared every current image directly with its same-named prepromotion `-009`
counterpart at original resolution. All 21 motion PNGs are byte-identical across
the two packets. That includes every far/mid/near image and all fifteen images in
the three five-frame join brackets, giving exact pixel proof that v9 authority did
not change the traversed facade presentation.

The 14 still PNGs are fresh input-only recaptures and are not byte-identical. The
recorded differences are tiny natural controller convergence differences rather
than a content change: the maximum camera-position delta is `0.062815 m`, maximum
player-position delta is `0.062487 m`, maximum yaw delta is `0.154732` degrees,
and the whole-view footprint projection differs by at most `0.032661` pixels.
Direct pair inspection of all fourteen shows the same geometry, materials,
lighting roles, spray, roof support, protected return, comparators, and cue
ranking. I found no pixel regression attributable to v9 authority.

## Interaction and surface truth

Still `09` has SHA-256
`f0f602a86a2f939c643174127034babf3bbc52d2f95ffdb37a5be0326f915dbe`
and visibly shows the real predefined cyan/yellow spray on
`building:w95934105:wall`. Still `10` has SHA-256
`ed8151aadde5d8218aa02dd443c5b227c6a750fae11ca3d4af0c61067572244f`
and visibly shows supported player contact on
`building:w95934105:roof`. The wall remains the sole spray owner; the roof reads
as a coherent world-solid landing surface without facade decoration.

No visual discrepancy or release blocker remains for this exact candidate.

PASS_FOR_D2_1441_V9_RELEASE
