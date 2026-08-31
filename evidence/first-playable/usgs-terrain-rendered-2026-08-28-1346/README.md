# USGS terrain Forward+/Metal evidence

This isolated evidence set was captured from the source project on 2026-08-28 with Godot `4.7.2.stable.official.ed1daf0bf`, Forward+, Metal, and the Apple M1 Pro adapter. It did not overwrite earlier evidence.

- Generated content: `77a154d5d52815a68de57be6ebe8ac222b859649a7b741416d46f1ddbce3e804`
- Manifest file: `cc66404953a709dadcdb64e5b85c6f18f51a7556053ac2e72a911dedf589ea18`
- Runtime: 38 chunks, 735 playable + 4 context rows, 701 meshes, 33,055 rendered triangles, 466 bodies/shapes
- Eight captures: five physics-grounded island regions, one real-controller wall tag, SF context, and YBI/bridge context

The five regional captures settled on generated terrain at `3.457`, `2.829`, `3.318`, `3.199`, and `2.580 m`, each with zero recovery and at most `0.001 m` reported ground clearance. The context frame visibly shows a non-round USGS-derived YBI ridge rising from its OSM shoreline and the eastern bridge geometry in a light-concrete material. YBI, both bridge treatments, and the SF billboard remain non-colliding.

`capture-manifest.json` records every image hash and grounded/context assertion. This is source-project rendered evidence, not proof of the separately exported app and not owner acceptance.
