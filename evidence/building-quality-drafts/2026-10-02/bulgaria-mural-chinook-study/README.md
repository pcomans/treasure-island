# Bulgarian Wall and 1445 Chinook Court — isolated art study

Reviewed standalone model of Oleg Gotchev’s “Bulgaria in the USA” mural/handball courts and the neighboring two-storey building at 1445 Chinook Court, Treasure Island (OSM way `w95934121`). Building identity is supported by reciprocal road/court context and matching exterior architecture in the retained StreetView originals, alongside the frozen August 27, 2026 inventory; an address label alone was not treated as confirmation.

Open [comparison.html](comparison.html) for the four original final native renders. This archive contains eight authored resources, four native images and portable documentation. `.gdignore` keeps the archive outside Godot resource discovery. Source photographs and earlier candidates/HOLD reviews remain privately retained; they are not redistributed here.

## Review scope

Independent source review passed bounded detached `RefCounted` / static `build()` execution safety and the complete relative resource graph. Independent visual review passed whole-building/composite resemblance and isolated art readiness across the final west/front, court context, near and direct garden views. Earlier candidates remained HOLD for garden recess/composition gaps; the final two stacked garden bays around a broad white center resolved the visible architectural mismatch.

The final four images were captured October 3, 2026 UTC in Godot 4.7.2 Forward+; the owned process exited normally with all four outputs and no engine errors. This is an unpromoted study: no as-built, surveyed scale, actual-world placement/contact, gameplay, collision, stair walking, mechanics, integration, release or recognition-credit acceptance is claimed. Dimensions, relative spacing, concealed surfaces and ground treatment are inferred. Recess shading is understated; roof pattern, glazing, weathering and court mottling remain simplified. Fine mural lettering and illustration are reconstructed rather than an exact transcription.

## Sources and credits

The Precita Eyes November 2018 newsletter identifies Gotchev’s mural and its November 11 unveiling at the former Navy handball courts at Ninth Street and Avenue D. The two sponsor photographs have no established exact capture date. An additional privately retained Google Maps contributor photograph by Yayo displayed October 2023. Neighbor references were acquired through the actual Maps road/StreetView UI on October 3, 2026 UTC; panorama imagery dates are September 2025 (court/south end) and March 2025 (east garden and west frontage). These dates do not establish present-day conditions. Photographer permissions and reuse licenses were not established; references below are links only.

- [Owner’s Bulgarian Wall place pin](https://maps.app.goo.gl/NBQKk54sXYYccEA88?g_st=ic)
- [Precita Eyes newsletter (November 2018)](https://www.precitaeyes.org/newsletters-2018-2024.html)
- [Precita mural photograph](https://www.precitaeyes.org/uploads/1/0/7/4/107469011/oleg-mural_12.png)
- [Precita dedication photograph](https://www.precitaeyes.org/uploads/1/0/7/4/107469011/oleg-ribbon-cuttingl_13.jpg)
- [Court and south end — September 2025](https://www.google.com/maps/@?api=1&map_action=pano&pano=zAM1Qq_v9eQfSvvu_wwHbw&heading=0)
- [Garden elevation — March 2025](https://www.google.com/maps/@?api=1&map_action=pano&pano=njpZyDGLc459BTjbe7LvGA&heading=270)
- [West frontage — March 2025](https://www.google.com/maps/@?api=1&map_action=pano&pano=jXNDm81ug17019Uuw6qzOQ&heading=90)

The author independently selected one unique opaque raster albedo for the mural and generated it with the built-in image-generation tool from the retained mural photographs. The completed generation was copied byte-for-byte as `mural.png` (2115 × 743); it is loaded directly relative to the concrete shader and mipmapped without PNG import. This reconstructed artwork does not establish exact lettering fidelity or rights clearance. Court geometry/materials were preserved during the neighbor revisions. The portable `site_12_housing_kit.gd` reuses maintained Site12 housing geometry primitives (with global class registration removed); roof and siding shaders reuse the maintained family resources. No global registration or live-world attachment is required.

### Actual image-generation prompt

> Use case: precise-object-edit. Asset type: opaque flat unique-elevation albedo texture for private 3D recreation of The Bulgarian Wall / Bulgaria in the USA mural. Inputs are reference photos of the SAME mural; image 1 provides complete composition, image 2 close details. Reconstruct only the entire rectangular painted mural straight-on, orthographic, edge-to-edge, aspect ratio approximately 2.85:1. Remove all people, poles, divider, sky, trees, pavement, perspective, sunlight/shadows. Fill occluded art coherently. Preserve composition closely: three equal horizontal white, teal green, crimson red fields; left half huge elegant italic calligraphy, gold 'България' across white, gold 'Bulgaria' across green, light blue 'in the U.S.A.' across red extending to center-right. Right half finely detailed gold/green medieval armored mounted rider on horse facing right, eagle flying above to his left; running small horse lower left of rider, gold crouching lion beneath rider facing forward-right; tiny gold dedication lettering blocks near bottom-right. Keep artwork handpainted, elaborate shaded gold illustration exactly like reference, not simplified icons. White top field includes rider/eagle. No wall thickness, no frame, no margin, no 3D view, no lighting effects, no photograph context. Uniformly lit matte paint, all pixels opaque. Texture itself only.

## Reproduce in an isolated preview

Use the maintained [capture driver](../../../../tools/model_shootout/run_capture.py) and [capture project](../../../../tools/model_shootout/project) as the donor in a separate temporary workspace. Adapt the complete driver/project together: copy all eight resources, preserve names and relative preloads, load `model.gd`, call static `build()` and attach its returned node to the isolated preview scene. The image loader resolves `mural.png` from the copied concrete shader’s resource directory. Do not remove this archive’s `.gdignore` or attach the model to the normal world. No new harness copy or replay is included in this archive; the recorded images came from the privately retained study adaptation.

Use the following four-pose profile and matching expected output names together. Coordinates are Y-up; all views use perspective FOV 60°, near 0.1, far 250, at 1440 × 900.

| Output | Camera position | Look-at target |
| --- | --- | --- |
| 01-west-front.png | (-47, 7, -8) | (-18, 2.8, -8) |
| 02-court-building-context.png | (10, 10, 34) | (-9, 2, -5) |
| 03-building-near.png | (-34, 4, -7) | (-18, 2.8, -7) |
| 04-garden-side.png | (21, 7, -8) | (-12, 2.8, -8) |

Composite setting bounds are approximately x [-30.7, 10], z [-26, 12.5], with building height 6.91 m; these are model extents, not survey measurements. The neighbor is translated (-17.8, 0, -8) and rotated -π/2 around Y; its frontage faces west. Retain the donor’s isolated environment: neutral ground at y -0.025, sun rotation (-42°, -32°, 0°), energy 1.4 with shadows, ambient energy 0.55 and filmic tonemapping. Allow 16 process frames and a completed draw before saving each image. Adapt timeout/termination and complete-resource copying from the maintained bounded driver; do not rely on editor imports or global class caches.
