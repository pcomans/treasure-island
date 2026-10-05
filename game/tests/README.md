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
| `headless_world_material_contract.gd` | The ground and building materials load with their textures. |
| `headless_facade_meter_uv_adapter_contract.gd` | Facade texture coordinates run continuously around corners. |
| `headless_building_study_geometry_contract.gd` | The shared geometry helper (`support/building_study_geometry.gd`). |
| `automated_route_qa.gd` | The player can walk the ferry-to-Trade-Winds road route without getting stuck or falling. |
| `shared/island_test.gd` | The island loads and every scored building is present, solid and grounded. |
| `tools/validate_godot_world.mjs` | The committed generated world is valid. |
| `tools/check_godot_world_determinism.mjs` | Fresh world builds from the OSM sources are identical to each other and to the committed world. |

Checks for one building, used while working on it (see [AGENTS.md](../../AGENTS.md#what-done-means-for-a-building)):

```sh
tools/godot --headless --path . --script game/tests/shared/building_fit_test.gd -- --source <key>
tools/godot --path . --resolution 1600x900 --script game/tests/shared/building_shots.gd -- --source <key> --island --out <dir>
tools/build-mac.sh   # Mac build + content audit + launch check
```

`shared/` holds these checks and their helpers (`world_harness.gd`, `building_fit.gd`,
`catalog.gd`). `support/` files are loaded by game scripts at runtime.
