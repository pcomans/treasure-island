# Building 600 — w34313548

SF Fire Dept Treasure Island Training Facility, Building 600, 750 Avenue M.

**Model:** `game/scripts/world/facades/fire_training_600_model.gd`, authored as the
PR #5 fresh study (2026-10-02, Claude Code team) and chosen by the owner as the most
faithful of three versions (PR #5, PR #6, `main`'s 2026-10-04 study). It is built from
the actual source roof footprint, wall record and the chunk's ground records
(`fire_training_600_live_factory.gd`, wired through
`fire_training_600_live_replacement.gd`). Heights, bay cadence, east face and passage
fittings are production inference; see PR #5's task note
(`evidence/first-playable/b600-fresh-study-2026-10-02/TASK_NOTE.md` on that branch).

Changes made while porting it live (2026-10-05): the wall bottom comes from the source
wall record instead of a fixed height; the build fails cleanly on a footprint too small
for its fixed porch/east-wall positions or on points outside the ground records; "SFFD"
leads the arch lettering, larger, as on the real sign; an unsupported red disk inside
the passage was removed.

**Checks:** `building_fit_test.gd` passes (roof, walls, grounded, walk-up, and the
passage walked both ways with `--routes`). Independent code review PASS and visual
review PASS (`b600-pr5-code-20261005`, `b600-pr5-visual-20261005`). Visual review needed
close portal views (`building_shots.gd --views`); the default close-ups are too far
away for a building this long.

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
