# Tests

Run everything with `tools/test.sh` in the devcontainer (see the [README](../../README.md#develop)).
It must pass before anything is pushed to `main`.

| Test | Checks |
| --- | --- |
| junk check (in `tools/test.sh`) | New files add no screenshots, videos, builds, logs, reference photos or files over 5 MB outside `game/resources/` and `generated/`. |
| `headless_scene_parse.gd` | The gameplay scenes parse. |
| `headless_startup_configuration_contract.gd` | Dummy audio is selected; the building catalog lists 213 buildings and every accepted one has a reviewer verdict. Prints the score. |
| `validate_generated_world.gd` | The generated world data is valid and matches its manifest. |
| `headless_gameplay_contract.gd` | Controls, movement and jetpack defaults, water, skyline billboard. |
| `headless_touch_controls.gd` | The browser touch controls: proportional stick, independent fingers, release, pause and teardown. |
| `headless_world_material_contract.gd` | The ground and building materials load with their textures. |
| `headless_facade_meter_uv_adapter_contract.gd` | Facade texture coordinates run continuously around corners. |
| `headless_building_study_geometry_contract.gd` | The shared geometry helper (`support/building_study_geometry.gd`). |
| `headless_facade_grid_contract.gd` | The shared facade window grid and assembly helpers (`scripts/world/facades/facade_grid.gd`, `facade_assembly.gd`) on hand-built grids. |
| `automated_route_qa.gd` | The player can walk the ferry-to-Trade-Winds road route without getting stuck or falling. Each checkpoint must sit on the land or on the always-on street ground over it (sidewalks, the Waterfront Plaza, curb ramps), within 0.35 m of its terrain anchor and on the road geometry it names. |
| `shared/island_test.gd` | The island loads and every scored building is present, solid and grounded. |
| `shared/island_test.gd -- --use-prebuilt-world` | The same, on the baked world desktop exports load (baked first by `tools/prebuild-static-world.sh native`, removed afterwards). |
| `tools/validate_godot_world.mjs` | The committed generated world is valid. |
| `tools/check_godot_world_determinism.mjs` | Fresh world builds from the OSM sources are identical to each other and to the committed world. |
| `tools/check_street_detail_clearance.mjs` | With every street-detail layer on, nothing intrudes on a catalog stair, its door or approach, the ferry spawn, the ferry path or the QA route. |

Checks for one building, used while working on it (see [AGENTS.md](../../AGENTS.md#what-done-means-for-a-building)):

```sh
tools/godot --headless --path . --script game/tests/shared/building_fit_test.gd -- --source <key>
tools/godot --path . --resolution 1600x900 --script game/tests/shared/building_shots.gd -- --source <key> --island --out <dir>
tools/build-mac.sh   # Mac build + content audit + launch check
```

A `--views` focused view may add `camera_xyz` with a vertical `fov` (default 70) to shoot from a free camera aimed at its `target_xyz`, for example to match a reference photo, or `"projection": "ortho"` with `ortho_size` (vertical extent in metres) for a square-on elevation.
`--street-views FILE` shoots a street-detail area instead of a building: `{"area": "NAME", "views": [...]}` with the same view fields but no building bound, saved as `street-NAME.png`, with street detail on and off by default.
The player avatar is hidden in every shot; `--show-player` keeps it.

Street detail (the vegetation, furniture, fences and clutter layers under `PlayableWorld/StreetDetail`) is on in play, the web build and `island_test.gd`, and off in `building_fit_test.gd`.
The furniture layer's poles, posts, cabinets and hydrants are solid on their own street-prop physics layer (layer 4): the player collides with it, the spray ray stops on it (a refusal, never a tag) and the camera arm ignores it. `automated_route_qa.gd`, `island_test.gd` and fits with `--street-detail on` walk among them; the clearance check keeps them off the walked corridors and the walk straight ahead from the spawn. A `--spray` plan may add `"expect": "receiver_rejection"` to aim through such a solid and require the refusal. Gameplay-camera street views print `arm_m`, the camera's distance along its arm.
`building_shots.gd` takes close-ups and focused views with it off and context, island and overhead views both ways (`NAME-street-on.png`, `NAME-street-off.png`); `--street-detail off|on|both` sets every view.
Override a test with `-- --street-detail on|off`, or choose layers with `--street-detail-layers vegetation,fences` (`island_test.gd`); the play default is the project setting `treasure_island/street_detail/enabled` and `.../layers`.

`shared/` holds these checks and their helpers (`world_harness.gd`, `building_fit.gd`,
`catalog.gd`). `support/` files are loaded by game scripts at runtime.
