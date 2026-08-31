# Treasure Island Community YMCA exact-run material trial

Date: **2026-08-29**

Result: **mechanical integration and native render proof pass; independent exact-receiver gameplay art review is pending. This executor does not accept the art.**

The independently accepted-with-limitation corrected aggregate/background field is live only on `building:w34313547:wall` runs `3..11`, exactly **9 runs / 101.046 m**. Runs `0..2` and `12..29` retain the generated `building_wall` placeholder. No window, opening, panel joint, entry, louver, service door, mural, low wing, trim, module, motif, atlas, geometry, massing, collision, navigation, spray, or generated-data change is part of this trial.

## Runtime proof

- Before YMCA trial: `729` record-owned meshes, `731` disjoint surfaces, `48,389` render triangles, `466` collision bodies/shapes.
- After YMCA trial: `729` record-owned meshes, `732` disjoint surfaces, `48,389` render triangles, `466` collision bodies/shapes.
- Exact delta: one additional disjoint material surface on the existing YMCA wall mesh. The YMCA receiver retains its original `60` render triangles and matching `60` collision triangles with no duplicate/coplanar render triangles.
- Navy Chapel remains live only on runs `9..10`; Dormitory 369 remains live only on runs `0..5`; rejected Fire Station 48 remains one generated placeholder surface over all `26` runs with no accepted-material metadata.

The machine-readable [capture manifest](capture-manifest.json) pins source/receiver identity, before/after scope, material/shader/registry/mapping/review hashes, receiver invariants, topology, renderer/device identity, camera/light transforms, image hashes, and the independent-review boundary.

## Native Metal captures

Captured at `1440×900` with Godot `4.7.2`, Forward+, Metal, and Apple M1 Pro (Apple7):

- [Close live receiver](images/01-close.png)
- [Ordinary gameplay distance](images/02-ordinary-gameplay-distance.png)
- [Changed-light oblique](images/03-changed-light-oblique.png)
- [Whole-island load proof](images/04-whole-island-load.png)

All four images were manually inspected as nonblank live-world captures with the intended view roles and pending-review labels. The close view proves the live aggregate field locally; the ordinary and oblique views expose its receiver-scale behavior; the aerial proves one clean 38-chunk load. These observations do not grade or accept the field.

## Owner-playtest noninterference

Godot import, tests, capture, focus changes, relaunch, stop, and process signals were all deferred while exact PID `6358` lived. The staging period changed source files on disk only, which could not affect the already-running process. PID `6358` exited at `2026-08-29T22:22:39-0700`; a subsequent exact `ps -p 6358` returned no process before the first Godot editor scan. See [owner-playtest-noninterference.txt](owner-playtest-noninterference.txt).

## Review boundary

The prior standalone verdict remains `ACCEPT_WITH_LIMITATION`: dark aggregate/background only, with granular identity, `0.095–0.420 m` scale, and substrate still treated as receiver-calibration assumptions. Independent gameplay art review must now judge these exact receiver captures and the whole object. A rejection requires removal of this trial; it does not authorize a material/shader correction in this task.

The full command/result ledger is [verification-results.txt](verification-results.txt), and retained byte identities are in [ASSET_INVENTORY.sha256](ASSET_INVENTORY.sha256).
