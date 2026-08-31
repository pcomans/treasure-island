# Full-runtime headless evidence

Checked: 2026-08-28

The clean evidence run used only `.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot` (`4.7.2.stable.official.ed1daf0bf`), headlessly and without export or GUI launch. The dedicated test instantiates `game/scenes/main.tscn`; it does not substitute a fixture world for the generated island.

## Live world result

- `world_ready` reached after `1,823 ms`; only then was the player shown and physics/input enabled.
- Manifest content SHA-256 remained `5899ebe131bbf05525fedebdac703a321a7aaf95523a57960cb937085068cfaa`.
- Loaded `38/38` chunks and all `735 playable + 4 context` coverage rows.
- Instantiated `697` playable plus `4` context/boundary-attached records: `701` `ArrayMesh` instances, `701` surfaces, and `21,210` triangles.
- Instantiated `466` `StaticBody3D` nodes and `466` nonempty `ConcavePolygonShape3D` shapes. Context remained collision-free.
- Live record metadata contained `738` direct geometry source keys. Together with the approved composite-only Isle House parent, validation covered all `739` ledger obligations with zero unresolved or duplicate rows.
- Static memory at the gameplay checkpoint was `43.1 MiB`.

## Runtime behavior result

- The generated spawn was inside boundary `w26767313`; the player grounded on generated land without triggering recovery.
- Thirty physics frames moved `1.588 m` walking and `2.197 m` running. Movement after spray/recovery moved another `0.922 m`.
- Actual camera code applied yaw sensitivity and clamped pitch at `-60°` and `+25°`.
- Manual recovery and physics-driven `outside_boundary` recovery both returned to an in-bound safe transform.
- A ray against an actual generated building wall placed the tag. Its local `+Y` aligned outward with the physics hit normal and local `+Z` aligned upward, so Godot's local `-Y` decal projection points into the wall.
- Actual generated ground and roof first hits returned `receiver_rejection`; aim through non-colliding YBI context returned `no_hit`.
- The live pool capped at `64` tags, evicted exactly one oldest tag, and movement remained non-modal.
- A deliberate missing-manifest reload recorded `file_open`, disabled/hid the player, cleared every generated child, and left `0` partial-world nodes.
- The final process exited `0` with no engine errors, authored warnings, crash output, or leak warnings.

## Runtime-owned corrections

- `WorldChunkBuilder` reverses each validated generated triangle triplet when constructing Godot indices. This adapts the unchanged counterclockwise generated contract to Godot's clockwise front-face convention for both rendering and collision.
- Playable materials retain normal backface culling after that correction. Raised planar YBI/bridge/boundary context alone is two-sided because the playable camera views those coarse surfaces from below.
- Spray-tag basis construction now makes local `+Y` the outward hit normal and local `+Z` upright.
- Runtime evidence now reports load failures, static memory, and safe-transform availability, and resets stale success state at the start of every load.

## Preserved inputs and remaining stage gates

The five frozen source hashes still exactly match `GeneratedWorldContract.REQUIRED_SOURCE_ARTIFACTS`; the generated validator still passes the unchanged manifest content hash. No generator, source data, generated world file, package/install record, approval document, GUI state, or export setting was edited.

Visual/export work remains intentionally unperformed. That stage must capture the real ground-level rendered island, confirm raised planar YBI/bridge context reads acceptably, inspect tag appearance beyond the proven transform/cull contract, and exercise the native private `.app`. One known residual workflow gap also remains: a validation-failure load screen has no in-app exit control because the established `quit_game` contract is Q only while paused; changing that contract or adding a load-screen Exit control needs an exact owner decision.

Raw sanitized results are in `full-runtime-headless.log` and `headless-suite.log` in this directory.
