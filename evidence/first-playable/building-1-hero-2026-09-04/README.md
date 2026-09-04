# Building 1 hero-shell evidence — 2026-09-04

Status: **pending independent original-detail review; executor acceptance is prohibited**

This is exact-current source-project evidence for the reversible exterior-only
Building 1 hero shell. It does not prove surveyed dimensions, surveyed cadence,
an as-built reconstruction, interiors, package pixels, or owner recognition.
No source photography is included or shipped.

## Source and identity boundary

- Main building: frozen source `r16681702`, retained separately as
  `building:r16681702:wall` and `building:r16681702:roof`.
- Rooftop tower: frozen source `w1222720021`, retained as the separately
  reviewable recognition entity `building:w1222720021:wall` and
  `building:w1222720021:roof`.
- Horizontal authority: the exact generated records in
  `generated/world/chunks/x_-1__z_2.json` and
  `generated/world/chunks/x_0__z_2.json`.
- Architectural recognition grammar: National Park Service NRHP registration
  `08000081`, Section 7 pp. 5–7:
  <https://npgallery.nps.gov/NRHP/GetAsset/NRHP/08000081_text>.
- Supporting public-history context: Treasure Island Museum,
  <https://www.treasureislandmuseum.org/youarehere/building-the-bay-bridge-&-treasure-island>
  and <https://www.treasureislandmuseum.org/sculptures-and-island>.

All vertical values and facade placement coordinates are reversible production
inference. The full values and truth labels are in
`game/resources/facades/building_1_hero_model.json` and
`discovery/facades/TREASURE_ISLAND_BUILDING_1_HERO_RECOGNIZABILITY_SPEC.md`.

## Runtime result

The runtime intercepts the four generated Building 1/tower placeholders before
generic visual or collision construction, then replaces each with one
separately keyed hero component and one congruent collider owner. The combined
hero is `11 meshes / 11 surfaces / 9,379 triangles / 4 static bodies / 4
shapes`; the exact-current loaded world is `735 playable rows / 931 meshes /
941 surfaces / 59,778 triangles / 466 body-shape pairs`.

The focused headless contract additionally raycasts the exposed inferred
two-story (`y=14.75`), both three-story (`y=20.25`), four-story (`y=26.281`),
and tower-platform (`y=27.35`) collision surfaces. Separate wall rays prove
that `r16681702` and `w1222720021` retain their own spray-eligible ownership.

## Native capture

Run from the repository root:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot \
  --path . \
  --display-driver macos \
  --rendering-method forward_plus \
  --rendering-driver metal \
  --audio-driver Dummy \
  --resolution 1440x900 \
  --script game/tests/building_1_hero_capture.gd
```

The retained run used Godot `4.7.2.stable.official.ed1daf0bf`, macOS display,
Forward+, Metal, and Apple M2. It exited `0` after writing eight `1440×900`
PNGs. `capture-manifest.json` SHA-256 is
`ebeef887b37c6845c6c8fa3f25e06706351fe7c1dab0e1a3b0eaf47dfb773017`.

| View | Review role | SHA-256 |
|---|---|---|
| `01-public-curve-same-camera-after.png` | Ordinary third-person before/after continuity | `23462802a3acfd115ae0a434f72f8e6cc6167b57d21282655b0c2fc315d6903b` |
| `02-north-end-after.png` | Ordinary-height north end and wing | `c166594704e49594603f67f889b72cc0350cb9ab23bc19218b85da2859e862af` |
| `03-front-and-tower-after.png` | Ordinary-height center, entrances, and tower silhouette | `1342d058c6b104879c409c8b2e03b5e8edca4f7060675522129fefa193aada3c` |
| `04-south-end-after.png` | Ordinary-height south end and wing | `eaa12f06220150cea5f0a79038466155f83756fe94c13e571ef17bf06eb5c75a` |
| `05-whole-building-after.png` | Elevated diagnostic; not ordinary acceptance | `7ace7b55474ec2b3666b3f17dfc4c5b8599a347f09881de2b8883676faf005da` |
| `06-tower-separate-entity-after.png` | Separate `w1222720021` exact-plan tower review | `2b6a630c1132a87d27502b62736c75569b1cca7f37a895d597c5d916b5ab24c4` |
| `07-rear-east-after.png` | Rear/east truth view | `3aa70e805b1b6442c5e45bba9f57aebc42da329cfbba8ba75397e331b9459a1c` |
| `08-public-curve-changed-light-after.png` | Ordinary public curve under changed light | `967484447f83f4295c82e33999b70285dfa3922baa2da691ede73f83193fc9e4` |

## Independent reviewer checklist

- Open every image and every paired predecessor named in the manifest at
  original detail; do not judge thumbnails.
- From ordinary views, judge the `2/3/4`-story silhouette, 11-bay center,
  long canopy/projecting base, three entrance groups, `8`-upper/`7`-lower wing
  rhythm, and paired tall end compositions.
- Review `w1222720021` separately: exact octagonal source plan, wider inferred
  platform, glazing, balustrade proxy, and pyramidal roof.
- Look for z-fighting, cracks, inverted faces, facade/roof overlap, implausible
  scale, illegible relief proxies, and changed-light material failure.
- Confirm the restrained production-inference result is recognizable from
  ordinary player viewpoints without treating it as a survey or as-built model.

Known discrepancies to weigh rather than conceal: the rear/east facade remains
deliberately austere because no rear cadence was asserted; the airplane reliefs
are abstract recognition proxies, not literal sculpture reproductions; facade
coordinates, materials, all vertical dimensions, platform enlargement, and
roof pitch remain inferred; and no landscaping or forecourt reconstruction is
claimed by this bounded pass.
