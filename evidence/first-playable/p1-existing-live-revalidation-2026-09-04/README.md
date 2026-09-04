# P1 existing-live whole-building revalidation evidence

Status: **technical capture valid; every recognition verdict remains pending independent review**.

This batch records the exact-current live treatments for Building 3
(`w34313540`) and Hawkins (`w1249412093`) as candidates for no-change
whole-building revalidation. Isle House (`w1249412094`) is diagnostic only:
its high and low receivers are judged together, and the visible low receiver
remains intentionally untreated. Nothing in this directory accepts any target
as recognizable.

## Capture provenance

- Native renderer: Godot 4.7.2, macOS display, Forward+, Metal, Apple M2.
- Resolution: uncropped `1440x900` PNGs.
- Camera: the actual visible-player `CameraPivot/SpringArm3D/Camera3D` rig,
  stock `70 degree` FOV and `5.5 m` configured arm. No detached camera, FOV
  change, hidden context, light change, post-process, or fallback pose.
- Grounding: each fixed XZ anchor was spawned `3 m` above generated walkable
  collision and settled through actual CharacterBody physics. Final clearance
  is at most `0.002325 m`; every recovery delta is zero and every pose remains
  inside the gameplay boundary.
- HUD: the ordinary reticle is present; debug, feedback, loading, and pause
  panels are absent in every image.
- Binding: the viewport-center world-solid ray first-hits the exact receiver and
  exact source-key array recorded in `capture-manifest.json`.
- Current runtime pins: `735` playable rows, `4` context rows, `931` meshes,
  `941` surfaces, `59,778` triangles, `466` bodies, and `466` shapes; generated
  content SHA-256 `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`.

Capture command:

```text
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/p1_existing_live_revalidation_capture.gd
```

## Frozen review protocol

The confusion sets and recognition gates were copied from the P1 packets and
frozen in the harness before any new image was inspected:

| Target | Frozen confusion set | Review purpose |
| --- | --- | --- |
| Building 3 | Building 2 `w24274434`; Building 1 `r16681702` | Candidate for no-change review; require the packet's single dark-teal hangar opening plus long upper band, with the crown/shoulder massing limitation explicit. |
| Hawkins | Maceo May `r19685981`; Star View Court `w1212173437`; 490 Avenue of the Palms `w1272162518` | Candidate for no-change review; require at least two packet cues. |
| Isle House composite | Hawkins `w1249412093`; 490 Avenue of the Palms `w1272162518` | Diagnostic only; the high part does not excuse a generic low part. |

Each target has exactly one whole-object view and one oblique approach. The
whole-object bounds are fully within frame. Oblique views may let distant parts
of the target union cross a frame edge; their purpose is an ordinary approach
to the exact receiver at the reticle, not a second whole-object composition.

## Technical inspection results

All six final PNGs were opened at original detail. They decode at `1440x900`,
are nonblank, contain the intended target and ordinary world context, show no
debug/feedback/loading/pause overlay, and have no technical corruption. This was
only a technical-validity inspection; facade fidelity and recognizability were
not scored.

| View | Receiver first hit | Camera height above ground | Arm | Projected target bounds W x H | LOS distance |
| --- | --- | ---: | ---: | ---: | ---: |
| Building 3 whole | `building:w34313540:wall` | `1.443 m` | `5.500 m` | `0.718 x 0.353` | `77.873 m` |
| Building 3 oblique | `building:w34313540:wall` | `1.728 m` | `5.500 m` | `0.818 x 0.816` | `52.972 m` |
| Hawkins whole | `building:w1249412093:wall` | `1.428 m` | `5.500 m` | `0.471 x 0.255` | `87.970 m` |
| Hawkins oblique | `building:w1249412093:wall` | `1.243 m` | `5.500 m` | `0.652 x 0.301` | `69.243 m` |
| Isle House whole composite | `building-composite:w1249412094:w1282547786:wall` | `1.204 m` | `5.500 m` | `0.397 x 0.482` | `104.430 m` |
| Isle House low oblique | `building-composite:w1249412094:w1282547787:wall` | `1.773 m` | `5.500 m` | `0.741 x 0.793` | `55.814 m` |

One pre-seal technical iteration is disclosed: the initial Isle whole-composite
anchor used the stock rig but pitching at the tall tower lowered the camera to
`0.166 m` above local ground. Before sealing the batch, that fixed anchor was
moved farther back and the aim point lowered, then a `>=1.0 m` camera-height
requirement was added for every view. The final height is `1.204 m`; no target
visual, confusion set, review gate, light, FOV, or receiver was changed.

## Independent reviewer handoff

Open every PNG at original detail and compare only against the cited packet.
Review Building 3 and Hawkins for possible no-change whole-building acceptance.
Review Isle House only as a composite diagnostic and explicitly include the
untreated low receiver. Record the reviewer identity, date, image hashes,
confusion-set result, cue-by-cue result, and one of `accept`, `revise`, or
`blocked`. Until that separate record exists, all three verdicts stay pending.

