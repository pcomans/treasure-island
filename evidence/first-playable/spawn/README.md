# Ferry-arrival spawn evidence

Checked: 2026-08-28

The current generated world starts the player on Treasure Island ground at world `[-104.364, 1.000, 786.024]`, yaw `-0.119` radians. The camera/player forward direction points toward the exact playable-boundary centroid and therefore into the island interior.

## Frozen OSM derivation

No live map or currentness lookup was used. The generator verifies this exact chain in `data/osm/treasure-island-2026-08-27.osm`:

| Role | Frozen source key | Relevant frozen meaning |
|---|---|---|
| Terminal stop | `n9335172179` | `amenity=ferry_terminal`, named Treasure Island Ferry Terminal |
| Floating terminal footprint | `w1036802529` | named `area=yes`, `ferry=yes`, `floating=yes`, `man_made=pier`, public-transport platform |
| Platform footway | `w1036802526` | connects the access footway through the platform and stop |
| Terminal access | `w1036802527` | bridge footway from the ferry platform toward Treasure Island |
| Land-side landing | `w1011830367` | area pier admitted to the playable ledger |
| Inland approach | `w1222514694` | named Waterfront Plaza footway admitted to the playable ledger |
| Shared landing connection | `n9551738109` | shared by the access, land-side landing, and inland approach |

The floating terminal footprint and named stop are outside exact boundary `w26767313`; the platform's intersection area with that boundary is exactly zero. The generator therefore refuses to spawn on the terminal itself. It starts at `n9551738109` and walks exactly `8.000 m` inland along the reversed frozen `w1222514694` polyline.

Before the required 0.001 m serialization, that point is WGS84 `[-122.37217688572613, 37.816700576312215]`, local east/north `[-104.36446481606473, -786.0239954289626]`, with centroid-facing yaw `-0.11946884831572939` radians.

## Clearance proof

- Exact-boundary edge clearance: `14.964491636832381 m`.
- Nearest generated building footprint: `7.999442952833707 m`, source `w1222514695`.
- Land-side landing footprint clearance: `7.999623977672535 m`.
- Floating terminal footprint clearance: `76.80407266096222 m`.
- Player capsule radius: `0.35 m`; required generator safety radius with margin: `1.00 m`.
- The `5.65 m` camera-boom probe (the current `5.50 m` spring arm plus its `0.15 m` collision margin) remains in exact playable land. Triangle inequality gives conservative lower bounds of `9.314 m` from the boundary and `2.349 m` from the nearest building, both above the generator's `1.00 m` safety threshold.
- Non-playable context has no collision and is clipped/subtracted outside the playable boundary; the spawn's `14.964 m` inward clearance keeps the player/camera away from that boundary context.

The generator computes boundary/building distances against the exact projected polygon edges and every playable building/part footprint. Any source-key/tag/connectivity drift, platform leakage into the boundary, missing playable ferry sources, insufficient capsule clearance, or insufficient camera-boom clearance stops generation before atomic replacement.

## Regeneration and runtime result

- Generated content-index SHA-256 remains `5899ebe131bbf05525fedebdac703a321a7aaf95523a57960cb937085068cfaa`, because all `43` manifest-indexed artifacts are unchanged and the index intentionally excludes `manifest.json` itself.
- Current manifest file SHA-256 is `07b8b195e1a05942e38d9bbbcb801394cf9f184051fb5f7a819c75677e46f160`.
- Counts remain `739` sources = `735 playable + 4 context`, `38` chunks, `701` physical objects, zero unresolved or duplicate keys.
- Independent Node validation passed and two fresh generations compared all `44` generated files, including the manifest, deterministically.
- Clean outside-sandbox Godot 4.7.2 scene, gameplay-contract, generated-world, and full-runtime suites passed. The live main scene pinned the exact ferry transform/camera direction, grounded without recovery, walked `1.598 m`, ran `2.228 m`, resumed `0.932 m`, preserved both recovery paths and spray behavior, and cleaned up after the intentional failed reload.
- The source-project `--mac-export-smoke` path now also requires the exact ferry origin and yaw. Its clean pre-export run printed `spawn=(-104.364,1.000,786.024) yaw=-0.119` and passed; the later rebuilt package must print the same fields.

The retained `build/mac/` app was not exported or launched in this implementation round and still contains the prior centroid-spawn manifest even though its content-index hash is the same. A later isolated export produced `build/ferry-spawn-staging/Treasure Island First Playable.app`; its PCK and headless packaged smoke pin the exact ferry transform without touching the older app or GUI window. See [the staged Mac evidence](mac-run/README.md).
