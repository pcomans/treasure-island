# Hawkins / 77 Bruton stepped-massing evidence

Date: **2026-08-29**  
Executor: `/root/hawkins_facade_implementation`  
Target: frozen OSM `w1249412093`; wall receiver `building:w1249412093:wall`; roof `building:w1249412093:roof`

## Status

- The owner-approved Hawkins-only massing change is implemented and mechanically passing.
- This directory is immutable after handoff and preserves the accepted facade-language assets. Earlier flat-massing evidence remains at `../77-bruton-facade-correction-2026-08-29/` and was not overwritten.
- The result is **ready for independent massing/art review; it is not self-accepted**.
- No browser, image generation, download, install, upload, external resource, service, or account was used.

## Approved before -> after

`one flat 6 m Hawkins extrusion` -> `Hawkins-only stepped mass matching the observed six-story main block and lower companion volume, with collision and spray surfaces raised to match; footprint, terrain, foundation, gameplay, and every other building unchanged.`

The frozen quadrilateral is unchanged: `A(-118.795,451.595)`, `B(-79.648,526.358)`, `C(-41.556,480.728)`, `D(-69.387,427.417)`. Runtime scalar math derives:

- `P = A + normalize(B-A) * 60.400 = (-90.7771613773, 505.1035107148)`;
- `Q = B + normalize(C-B) * 33.000 = (-58.4999702509, 501.0250010119)`;
- main `[A,P,Q,C,D]`, `21.0 m`, six stories, top `25.274 m`;
- companion `[P,B,Q]`, `14.0 m`, four stories, top `18.274 m`;
- exposed step `P->Q`, `32.533848657 m`, only from `18.274` to `25.274 m`.

Shoelace areas are `3970.518805999996 m²` outer, `3604.806003192094 m²` main, and `365.712802807902 m²` companion: exact specified delta `0`. Godot mesh-vector components quantize those scalar coordinates by only a few micrometres; the focused test checks exact scalar provenance separately from engine-vector tolerances.

## Runtime and facade contract

- The serialized wall remains `20` quads / `40` triangles at the reversible `6.0 m` source assumption. The target-only runtime wall is `22` exterior quads plus one exposed step quad (`92` vertices, `46` triangles). No wall remains at the old `10.274 m` top.
- Runtime roof planes are a three-triangle main pentagon and one-triangle companion triangle. The old two-triangle `10.274 m` roof is absent.
- Wall and roof each retain one `Mesh`, one `StaticBody3D`, and one `ConcavePolygonShape3D`. The wall remains render layer `2`, physics layers `1|4`, group `spray_receiver_wall`, receiver `building_wall`; the roof remains render layer `1`, physics layers `1|4`, receiver `none`, and is rejected by spray semantics.
- The source `20` exterior-foundation-segment metadata remains. Runtime clipping interpolates `P` bottom `4.227158575 m` and `Q` bottom `4.156504860 m`; source bottom min/max `4.043/4.274 m`, outer perimeter, terrain inputs, and foundation continuity remain unchanged.
- Accepted Hawkins materials/shader are byte-identical. ENE, NNW, and the exposed step remain material-only. Shallow modules remain render-only with no collision/navigation and maximum relief `0.05 m`.
- Deterministic facade remap: `W-P=128`, `S-H=128`, `R-C=10`, `W-N=10`, `G-W=17`, plus one each `L-G`, `D-P`, `F-SIGN`, `C-B`, `D-S`, `G-G`. Main upper rows are centered at `9.524, 13.024, 16.524, 20.024, 23.524 m`; companion rows at `9.524, 13.024, 16.524 m`.
- Layout SHA-256: `4de2239af2e18fe4121930d51dee15e081d2f81a40393da2f1f29c69464761d9`. Runtime facade signature: `d311c103c9273b94fc982588f46bae6ab67ba6be54b0d0a111dd305e39c22219`.

## Preserved contracts

- Generated target chunk SHA-256: `b8696d4feb4157d39969ec039e610af572f25510d712c802d4a96943d6069c8c`.
- Generated manifest SHA-256: `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`; content SHA-256: `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`.
- `git diff -- generated/world data/osm` produced no output and exited `0`.
- Full runtime retains `729` meshes/surfaces, `466` bodies/shapes, all `38` chunks, `738` source identities, and now reports the exact authorized topology delta `48,381 -> 48,389` triangles.
- Player movement, jetpack, camera, recovery, `6 m` spray range, tag placement rules, route QA, terrain, water, Building 3, Isle House, and all other buildings are unchanged. Building 3 and Isle House focused contracts pass with their accepted signatures. The Museum still has no facade attachment.

## Forward+/Metal evidence

All six PNGs are `1440 x 900`, Forward+/Metal on Apple M1 Pro, normal `70°` third-person camera and `5.5 m` spring. `capture-manifest.json` records exact transforms, hashes, device, materials/layout identity, massing signature, module counts, sun, and real spray results.

| View | Purpose | SHA-256 |
|---|---|---|
| `01-address-close.png` | Close SE facade/story remap, default light | `35fd43882bc153ba801f4ae96de889352849c3588309baa29491a61f88495cb5` |
| `02-address-close-sprayed.png` | Same pose after real lower-wall spray | `292714927584e68c04829dbae0426fc024080dbef696a99ab2dd17126c06300d` |
| `03-wsw-ordinary-stepped.png` | Grounded WSW third-person view aimed at `14.774 m` | `d67f4dd4666fc719211e4eebe10fe5ea44b01b57134e589761346d53ded2af9a` |
| `04-corner-b-oblique.png` | Ordinary 40 m corner-B view of the whole stepped object | `9c026c74d52fd0a795093569dd397603b131cf27790f57008f70129c1a07603d` |
| `05-companion-roof-upper-step-sprayed.png` | Stable companion-roof proof after real within-range upper-step spray | `eae3b6b137cca31c3b0a1a0eb744adba2af1938fdf6983d0789b5922a8ad721c` |
| `06-corner-b-changed-light.png` | Byte-recorded repeat of view 04 under sun `(-38,125,0)` | `8c9f2c1d970ca3d533fdf1aa6b22fb67cfa0aa78582fbcf41049e472768f8bb8` |

The requested WSW `u≈35`, `35–45 m` supported approach did not resolve generated land/road in the deterministic pose search; the harness recorded its necessary `12 m` support fallback rather than moving world geometry or teleporting onto an invalid surface. The separate corner-B ordinary and changed-light pair retains the requested `40 m` distance and frames the whole stepped mass. View 05 uses the exact non-spray companion-roof collider as stable support after the already-passing unchanged jetpack contract; it does not claim a recorded manual flight path.

For direct before/after comparison, use the flat accepted-correction views `../77-bruton-facade-correction-2026-08-29/03-broad-gameplay-camera.png` and `04-corner-oblique-gameplay.png` against views `03` and `04` here. Poses differ where necessary to frame the newly approved height; both manifests retain the exact transforms.

## Exact verification

See `verification-results.txt` for every retained command and result. All listed commands exited `0`. Headless Godot emits the pre-existing restricted-environment `user://logs` rotation and macOS CA-certificate warnings; assertions and exit codes pass. No unrelated validator failure remains.

## Independent-review boundary and known approximations

The P/Q cut is a deterministic medium-confidence inference aligned to the accepted facade connectors, not an as-built survey. The `3.5 m` story grid is reversible. Roofs remain flat with no parapet, furniture, pavilion, rail, solar canopy, or courtyard articulation. Facade modules remain shallow opaque-glass proxies with reference-relative—not surveyed—cadence. Unobserved sides remain deliberately conservative. Mechanical completion does not accept silhouette, architectural composition, or art direction; those are ready for independent review.
