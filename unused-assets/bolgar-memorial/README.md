# Unused Bolgar Memorial Sign

Wrong-target standalone exterior study, retained at the owner's request on 2026-10-02. **Unused and not instantiated.** This is the Bolgar Memorial Sign in Bolgar, Tatarstan, Russia; it is not a Treasure Island building. The local `.gdignore` excludes this archive from Godot resource discovery/import.

- [Source](model.gd) and [concise author note](NOTE.md)
- [Final three-quarter preview](02-three-quarter.png)
- [Final near preview](03-near.png)

The source and PNGs are unchanged byte copies of the finished study. Dimensions, hidden elevations and ornamental detail are inferred, not surveyed. Neighboring buildings, interiors and riverbank terrain/stair context are omitted. No original reference photographs are packaged here.

Source review passed detached self-contained preview execution safety; two isolated Godot 4.7.2 Forward+ captures completed cleanly. Independent final static visual review passed bounded standalone exterior art readiness, while noting simplified entrance glazing/recess depth and overly pale stone. These judgments establish no gameplay, collision, stair walkability, integration, recognition credit or release acceptance.

## References and credits

Identity: [Bolgar Museum-Reserve, Memorial Sign](https://tour.vbolgar.ru/?p=621).

Photographs by Mike1979 Russia, dated 2024-07-12, own work, [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/): [front 1060](https://commons.wikimedia.org/wiki/File:Bolghar_Memorial_Sign_2024-07-12_1060.jpg), [oblique 1049](https://commons.wikimedia.org/wiki/File:Bolghar_Memorial_Sign_2024-07-12_1049.jpg).

Bolgar Museum-Reserve reference photographs: [601-3](https://tour.vbolgar.ru/wp-content/uploads/2024/09/601-3.jpg), [602](https://tour.vbolgar.ru/wp-content/uploads/2024/09/602.jpg), [601-1](https://tour.vbolgar.ru/wp-content/uploads/2024/09/601-1.jpg). Photographer, capture dates and reuse license were not established; consulted privately only. Archive previews are native renders, not those photographs.

## Reproduce in an isolated preview

Use the maintained [isolated capture driver](../../tools/model_shootout/run_capture.py) and its [project](../../tools/model_shootout/project), adapting their target/view/output bindings in a separate temporary project. Copy this `model.gd` there; its static `build()` returns the detached building to add to the preview scene. Do not remove this archive's ignore marker or attach it to the live world.

The final previews used 1440×900, perspective FOV 60°, Y-up, three-quarter camera (42,22,48) looking at (0,12,0), and near camera (13,5,26) looking at (0,9,0). Neutral ground and lighting belong to the capture driver, not the asset. This archive stores no caches, process records or capture harness copies.
