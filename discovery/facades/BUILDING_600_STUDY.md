# Building 600 study — w34313548

2026-10-04, `b600_art`, branch `buildings/fire-training-600`, source base `ca90a2d`.
Owner authorized a fresh whole-building study; the older texture-only correction
budget does not govern this assignment. Root authorized recognition acceptance after independent reviews.

Reference sufficiency: Root accepted the retained exterior set for bounded game
art. September 2025 Street View now confirms the dark-red arch, pale curved school
lettering, coarse cream wing, blue-gray windows and protective bollards. The wing
has small high openings as well as broad groups near the entrance. Trees conceal
much of its schedule; counts and spacing are production inference.

Private originals, outside Git/game: `/tmp/b600-reference-20261004/`:

- `sv-portal-202509.png`, panorama `ifdNQ-gh7K1ryx3rVMvW2w`, September 2025,
  37.8262806,-122.3677375, heading 90. Resolved URL in `sv-portal-url.txt`.
- `sv-wing-202509.png`, panorama `t8V4SOhQFPRXL_vukoMRog`, September 2025,
  37.8267255,-122.3679894, heading 80. URL in `sv-wing-url.txt`.
- `gallery01.png`, Google Maps/Dave Moloney, image capture December 2019:
  complete cross-passage, steel roof trusses, classroom wall and perforated screen.
  Its cream arch paint is historical, not the current palette.
- `recruit134.png` and `recruit134-release-20241112.pdf`, SFFD release November 12,
  2024: red repaint. [Official release](https://files.constantcontact.com/5e99cb80601/f6e60c19-4fd2-43dc-81de-ea8bf8ea20f8.pdf).
- `official-training.jpeg`, [SFFD photo](https://sf-fire.org/sites/default/files/2022-02/IMG_6625.jpeg):
  plausible yard-facing wing with service bays/upper vents. Capture date unknown;
  2022-02 is the URL path, not a verified photography date. Root permits restrained
  bay vocabulary as production inference; no per-bay as-built claim.
- `satellite.png` plus three `*-osm-pin.png` views: roof layout and exact source
  corner association; satellite capture date undisclosed. These show the gray
  canopy within the source footprint's southern end, opening across the WSW/ENE
  faces. The SSE end is the perforated screen, not the street entrance face.

The frozen source roof corners and manifest coordinate conversion establish that
association: SW (315.832,-282.245) is 37.826297,-122.3673982; SE
(331.457,-290.249) is 37.8263689,-122.3672205. Geometry consumes the actual supplied
wall/roof pair; the long wing and open cross-canopy replace the box atomically.
Terrain, area geometry, neighboring sources and stock controls remain protected.

Reuse: the housing row's gables/detached canopies and Station 48's upper cladding
are structural mismatches. The new institutional wing/cross-canopy uses existing
`site_12_housing_kit.gd` geometry primitives instead of copying a complete building.
No trees or training-yard props are authored in this study.

Focused site preflight sampled actual colliding land at source corners: 3.680,
4.348, 4.199 and 3.940 m, against source flat base 4.064 m. Wall and pier bottoms
extend below local land. No level platform is added; the open passage retains
actual terrain and existing visible area surfaces. The curved arch and screen
openings are mesh/collision voids. Roof/steel structure has its own opaque,
non-wall spray blocker; wall geometry has the target's wall receiver identity.

Baseline actual-world shots are `/tmp/b600-model-20261004/baseline/`; terminal
exit 0 and all planned images retained. Observed display/adapter: Wayland / AMD
Radeon 780M Graphics (RADV PHOENIX). Existing pointer-constraint diagnostics occur
at stock mouse-mode changes and remain in `baseline.log`; they did not prevent
WORLD_READY or captures. No renderer/platform requirement was introduced.

Harness friction so far: CLAUDE's MAIN wording is overridden by the owner's
branch-only instruction; missing browser dependency/display recipe was repaired
in prior commit `ca90a2d`; initial Street View failures needed a fresh headed
session with the full resolved panorama URL (cause unproved). Old B600 notes
placed the portal on the SSE end; actual roof/corner/photo evidence resolves it
as the southern WSW cross-passage. Reference palette differences were an actual
repaint, not proof that all older observations were wrong.

Implementation and review, 2026-10-04: factory/replacement and masonry shader
replace only this source's generated wall/roof pair. Exact four-corner mapping
and terrain-reaching bollards were corrected after source review. Shared shots
now accepts optional source-bound named `--views`; shared fit accepts optional
bidirectional `--routes`, preserving case/aggregate HOLD and recording supported,
stopped, input-released active-controller rest before safe disable. Recovery stops
movement immediately. Defaults remain available; no target-specific driver added.

Actual captures are `/tmp/b600-model-20261004/model01/`, `model02/`, `model03/`.
The first two review HOLDs exposed fascia overlap, the classroom return gap and
screen row count. Model03 restored continuous red construction, a full-height
return and three perforation rows. Independent visual PASS:
`b600-visual-model03-20261004`; game-art recognition, not surveyed/as-built fidelity.
Flat glazing and obscured/inferred wing cadence remain explicit approximations.

`fit02.log` completed exit 0: roof 0/19 bad, wall 0/18, ground 0/18; three stock
walk-up sides. Cross-canopy travel both directions arrived within 0.343/0.330 m,
with no contacts or recovery; each recorded active supported/rested/released state
then a safe disabled final state. Original solid box is removed, not masked.
After this run code review identified coplanar wing-roof/return end faces. Root
approved a narrow one-capture budget extension: terminate roof 0.18 m inside the
0.36 m return. Retain fit02 with this explicit subsequent source delta; no new
full fit was authorized. Final suite and acceptance remain Root-coordinated gates.

Additional harness issues: the standard full-footprint closeups were too distant
for this 104 m wing, so the approved shared optional view extension uses the same
stock gameplay camera; default center approaches did not prove an open passage,
so the shared optional route extension supplies both directions. The previous
rest check observed velocity after disable, which itself zeroes velocity; active
rest is now recorded first. Root's completed-agent followup hit a thread limit;
existing named agents continued without extra delegation. Reference pixels and
all captures/logs remain outside Git and game resources.

Corrected-source independent code PASS: roof center and extent both use the
recessed end; reviewer confirms prior passage/ground/rest evidence remains
applicable. Additional shared capture `/tmp/b600-model-20261004/seam04/` completed
exit 0 (session 75631), same observed Wayland/AMD adapter; focused seam visual
PASS `b600-visual-seam04-20261004` confirms the corrected junction. All engine handles consumed; no Godot/Weston PID remained.

Final corrected-state `tools/test.sh` completed once, session 33828 exit 0,
`/tmp/b600-model-20261004/full-suite.log`: ALL TESTS PASS, including all 44 scored
buildings fitting and generator determinism. Catalog recognition is accepted by
Root's authorization with both independent visual review IDs; as-built fidelity
remains unclaimed. No Mac build, merge or main-branch push is part of this study.
