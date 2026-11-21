# Building 1's hall: configuration

[building_1_interior.json](building_1_interior.json) is read by
[building_1_interior.gd](../../scripts/world/facades/building_1_interior.gd), which builds the
hall of Building 1 (the Administration Building, OSM r16681702) behind the crescent's middle
door group. [building_1_hero_model.gd](../../scripts/world/facades/building_1_hero_model.gd)
asks it for the hall's plan before it builds the exterior, opens that door and cuts the
exterior faces that would stand inside the hall, then returns the hall beside its wall record.
Sizes are production inference from dated photos and the National Register text named in the
file's `evidence`; nothing in it is surveyed.

The hall is laid out in polar terms about the circle fitted to the exact crescent front:
radii from that centre, angles along the arc between the crescent's outer piers.

| Block | What it sets |
|---|---|
| `plan_production_inference_m` | Radial depths: the front wall, the west zone (vestibule, rooms and balcony), the hall's width to the east wall, the east bays' recesses (`east_recess_depth`, `east_museum_depth`), the east wall's bay count, the north annex past the old north line, and the exterior cut's margin. |
| `heights_production_inference_m` | Heights over the hall's floor (`floor_y`, world metres): ceilings, balcony, fascia, parapet and rail, columns, the east band and the mural's bottom and top, coves, lanterns, office doors and windows, the sill's bevel (seen) and the gentler slope walked under it (`threshold_walk`). |
| `members_production_inference_m` | Member sizes: columns and their reeding, east piers, setbacks, the rail and its meander, lanterns, the tall windows' inner opening, panes and bars, dentils, curtains, door leaves. |
| `door`, `rooms` | Which door group opens, and what each bay holds: vestibule, bar room (blank until stage 3), curtained, closed and open bays, the east stair and museum bays, the office fronts, the bays the hall lanterns hang over. |
| `mural` | The four tiles north to south, the picture's painted length and calm ends, the cream returns at the wall's ends, and when the tiles load (`load_radius`) and go (`unload_radius`, `unload_delay`). |
| `reflections` | A trial switch for screen-space reflections on the desktop renderer: `off` (shipped), `inside` or `always`, and the floor's gloss while they are on. |
| `palette` | Each surface's colour, roughness, specular and glow. The shaded surfaces' colour is multiplied by baked vertex shading, so they are set warmer than they read in the photos. |

## Rules the code keeps

- The hall's shell is one mesh on render layer 6 (`interior`), which the Sun leaves out, with
  its own closed collision that collides from both sides. A blocker on the cars' ground layer
  stops cars in the doorway; the player and the camera pass.
- No surface the player walks is steeper than about 40 degrees: the stock capsule reads a
  slope's edges up to about 5 degrees steeper than the slope, and the controller stops at 48.
  The sill's 45-degree bevel is seen only; the feet walk `threshold_walk` under it. The fit
  check walks every catalog passage in and out across speeds, stick magnitudes, approach
  angles and physics step sizes (game/tests/shared/building_fit.gd).
- The mural's surfaces start on a small placeholder texture in the same material, and
  `Building1MuralLoader` swaps the tiles in once play has started and the camera is within
  `load_radius` of the door, one tile a frame, and puts the placeholder back after the camera
  has stayed beyond `unload_radius` for `unload_delay` seconds. Every point of the hall lies
  within `load_radius` of the door, so the mural never unloads while anyone is inside
  (game/tests/headless_building_1_interior_contract.gd checks it).
- Unphotographed parts stay plain: the end walls, the north annex and its gallery, the
  vestibule's finish, the museum rooms, the balcony walkway.

Change a value here, then run `game/tests/headless_building_1_interior_contract.gd` and
`game/tests/shared/building_fit_test.gd -- --source r16681702`, and take
`game/tests/shared/building_shots.gd` captures of the hall.
