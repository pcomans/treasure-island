# D2 1441 Chinook Court — Production Visual Review (`-009`)

- Verdict: **`PASS_FOR_1441_PROMOTION_NO_CREDIT`**
- Scope: recognizability, believability, material stability, player-view truth,
  and confusion-set separation for only the exact prepromotion candidate bound
  below
- Review timestamp (UTC): `2026-09-07T18:06:38Z`
- Target: `physical-building:w95934105`, 1441 Chinook Court

## Exact candidate binding

- Evidence root:
  `evidence/first-playable/d2-1441-production-v8-staging-2026-09-05-009/`
- Canonical 40-file packet tree SHA-256:
  `e52d66e479f268a9e75372da111d9c93cc1972dd1fddca9a6cb29bb6e41a4a43`
- Static capture manifest SHA-256:
  `3c11ba6412da6a062d89142594c7b785bf546b5c1905dc32bdd7ce7806fd6885`
- Consecutive telemetry manifest SHA-256:
  `21e2b60a8fee1bcfeb984ece6124684c15ae5b1be7fb8a813f18bc0c3b240fcd`
- Visual-motion manifest SHA-256:
  `c885f6450d3eaac4814bde83beff1bbdccea3ae992e07a62c1e9dd8fc1259cad`
- Package-verification receipt SHA-256:
  `cbcda89ec1e013c3406cf919d7c7e3bcefe0df7f005be1ea0e250bfbdada1061`
- Capture override SHA-256:
  `edbc0b9caa60fa0fc6b83cebb3145bce11ce0bd976403ca1d2fbe9b7142b39c3`
- Capture generator SHA-256:
  `921acef14ef5503569f8d07bcafdb03f6bccf78570742a8a835962e845a858cf`
- Receipt generator SHA-256:
  `7f579e7bb347079d543e2e1360b7a6d24189ebd5af13cf5a41591db91e365a1a`

The packet contains exactly 40 ordinary files and no symlinks. I reproduced
the repository-defined canonical tree digest, every top-level manifest and
receipt digest, every declared source-dependency hash, all 35 PNG hashes and
byte counts, and all 35 declared and actual `1440x900` dimensions. The packet
receipt is byte-identical to the external app receipt. The evidence closure
ends at the frozen packet, app, and source bytes; no downstream review artifact
participates in this binding.

## Packaged application and production identity

- App:
  `build/d2-1441-production-v8-staging-2026-09-05-009/Treasure Island First Playable.app`
- Seven-file bundle identity SHA-256:
  `81ae851ff3dffd90202e903939f1d6cda7eeb3cfff7e2c752492fa7ed0e1e129`
- PCK SHA-256:
  `c7660d21680649d137af52e2057a23aaa7efab9292c4e427c3e2ef79d1ea80c3`
  (`66,163,452` bytes)
- Executable SHA-256:
  `e40c888a66f044c5a267ef027d94e99fd8009104462a7ca193b249b6fb6d7cfd`
  (`170,963,648` bytes)
- Architectures: `x86_64` and `arm64`
- Geometry signature:
  `b91b373e3bb8238a6f73f05734ef48b3429ae5654eddce89b1981ee41ee89195`
- Live ownership signature:
  `fcad9968be3d0c9094adef5dcc9c7fabfb7cf1754f780897188a4ec362187e4d`
- Canonical wall hash:
  `00f3cd8b90e7ae93f802842b59bb10274f1fc388433e5b5c6cae1f3e23f4393c`
- Canonical roof hash:
  `e7da0179f012e928f575ac32440e176a0f3b9651fc325a594de80ce7e3fc9d55`

The seven inventory entries independently match their hashes and sizes. The
bundle identity, PCK, and executable reproduce the receipt; the executable is
a two-slice Mach-O, deep strict code-sign verification passes, and the bundle
has no extended attributes. The ordinary runtime topology is
`735 rows / 959 meshes / 974 surfaces / 69,252 triangles / 466 bodies / 466 shapes`.
The live wall/roof pair is `9 meshes / 9 surfaces / 1,578 visual triangles /
2 bodies / 2 shapes`: 1,568 wall visual triangles with 32 wall collision
triangles, 10 roof visual triangles with 10 roof collision triangles, and
1,536 decorative-relief triangles with no decorative collision.

## Full-resolution inspection scope

- Static images opened at native resolution: `14/14`
- Visual-motion images opened at native resolution: `21/21`
- Total images opened at native resolution: `35/35`
- Actual and declared dimensions: `1440x900` for `35/35`

The static pass covered the whole default view, ordinary oblique, identical
oblique under changed light, lossless grayscale, projecting-wing/paired-recess
close view, shallow-gable/eaves view, nearby context, protected return, real
spray on an eligible wall, and real player roof landing. It also covered all
four same-area comparators: `w95934144` / 1439, `w95934143` / 1443,
`w95934131` / 1438, and `w95934129` / 1440.

The motion pass covered every far/mid/near frame and every adjacent frame in
the five-image brackets around each of the three mapped signature joins. I
opened the exact authoritative images after seal rather than relying on
thumbnails or on an earlier rehearsal.

## Recognizability and believability

1441 is label-free top-1 against all four comparators. Its ranked cues are:

1. Two projecting, windowed wings visibly flank an actual central setback.
2. The setback carries paired, two-level recessed circulation/balcony bands,
   rather than reading as a single flat dark stripe.
3. A shallow dark side-gable and broad eaves cap the long residential mass.

Those cues remain legible in the whole, oblique, close, context, changed-light,
grayscale, protected-return, spray, roof, and moving player views. The grayscale
image preserves the same massing and depth hierarchy, so hue is not carrying
the recognition result. The whole/context/motion spread shows that the result
does not depend on one privileged camera. The spray mark is excluded from the
ranking. Each comparator remains a generic neighboring block without the same
combination of twin windowed projections, real center depth, doubled recessed
circulation, and shallow gable/eave silhouette.

The presentation is believable at the requested game-view bar without claiming
perfect realism. The center remains somewhat diagrammatic, the rail bands merge
when very wide, window openings are regularly inferred rather than individually
modeled, and the shallow gable is deliberately subtle. None of those limitations
collapses the three primary cues or makes a comparator more likely.

## Materials, joins, and motion stability

Across all 21 exact motion frames I found no visible seam opening, UV reset,
repeat jump, texture crawl, shimmer, moire, geometry pop, floating facade
element, material bleed, or unstable lighting response. Parallax progresses
continuously through every five-frame join bracket. The window cadence, balcony
slabs, rails, recess shadows, eaves, and faint stucco variation remain attached
to the building from far through near range.

The stucco has faint recurrence and the protected returns are intentionally
plain. Neither becomes an obvious tile boundary or contaminates the selected
public face. The protected-return image shows an undressed but grounded host
surface with no decorative spill. These are visible progress-over-perfection
limitations, not recognition or believability blockers.

The visual-motion receipt records 21 unique frame hashes and engine frames,
fixed-FPS request and receipt value `60`, in-memory post-draw image copies,
deferred PNG encoding after 360 input ticks plus 12 braking ticks, and no
live-loop file write. The maximum actual-versus-trigger deviation is
`0.0661554336547852 m`, below the unchanged `0.22 m` tolerance. Independent
sequence checks reproduce 360 consecutive physics samples, three crossed and
visually bracketed joins, continuous grounded/in-boundary travel, zero recovery,
zero player or camera transform writes, and a zero-velocity final brake sample.

## Interaction and surface truth

Static frame `09` (`fe8830dc71f4fbb4f8909d943fe51f7047180026039a00f896168cd81bc4ded0`)
visibly shows the predefined spray result on an exposed, eligible
`building:w95934105:wall` section between window rows. It is useful interaction
evidence but contributes no recognition credit.

Static frame `10` (`3230bbc774b7d410b27e84381177f27242ac54d1f119b0b0a5e3767fa51be006`)
unambiguously shows the player supported on a broad dark roof plane, with the
contiguous eave and facade/windows below retaining the building context. The
roof does not read as open ground, float beneath the player, or inherit facade
decoration. Wall, roof, and protected-return pixels are visually consistent
with their separately bound ownership and collision roles.

## Current v8 no-credit authority

- Catalog SHA-256:
  `d95be7bec8f0eabe97a9b5f7fefe1ce54ec7cbf940d85d28518ff6979eeb16ea`
- Catalog schema SHA-256:
  `44584e92e1652fc930f47882b4a83304f5216c14173eb805bc9ce68ea9927cac`
- Runtime registry SHA-256:
  `109f83f40450e9c71ef6d39f1659e76eac5f1457fcfab772538b471cc74c0051`
- Adapter contracts SHA-256:
  `dd2d13e3b0f6eee1f8c5f2957927c4f3caba43b31883beea925f9a91b826d65c`
- Registry loader SHA-256:
  `12e6c64b23b0783ed240b3d6c02499c3940c2b6a14344caa29778b850db06c04`
- Registry compiler SHA-256:
  `eee17772b1beb71b3d6bd87800035a0c1c47a7c80473014c578bb055a5ddf0c9`

These exact current authority files still report `8/213`: eight accepted
physical units out of the immutable 213-unit inventory. The target is absent
from the accepted-ID list, has no acceptance record, remains `not_evaluated`,
has no active authority adapter, and remains `all_receivers_generated_placeholder`
in the registry. The packet, manifests, and receipt all set recognition credit,
additional recognition credit, and promotion to false. This decision visually
clears only the exact bound candidate for the next promotion step; it does not
itself change the numerator, denominator, authority, or running application.

No visual blocker remains for the exact bound candidate.
