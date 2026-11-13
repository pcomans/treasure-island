# Building 201 provenance

- **`mural_nnw.png`**: the mural on Building 201's north-northwest end wall (Island
  Cove Market, 800 Avenue I), drawn by `b201_market_model.gd`.
  - It reconstructs a real artwork by description. Its title, artist and year are
    not established: the credits research of 2026-11-12 searched sf.gov's Treasure
    Island public art page, the San Francisco Arts Commission, Precita Eyes, Street
    Art Cities and others without a match. The game credits it by what and where it
    is in `game/resources/ui/credits.json` (Murals).
  - Made in this project on 2026-11-06 with `tools/generate-texture` from text
    prompts written from the study's dated references (refs 05 and 18); no
    photograph was given to the generator. The pieces were composed with
    ImageMagick, each at its natural aspect on a plain generated wall, in the real
    wall's order: "Viewer's left to right: low block, raised block with the narrow
    cone and robed figures, main block with the tall palm and the two graffiti
    pieces (refs 05, 18)." The graffiti spells nothing on purpose.
  - The prompts, from the study's scripts (`gen-batch1.sh`, `gen-batch3.sh`,
    `gen-batch4.sh`, composed by `make-art.sh`; kept outside Git with the study):
    - every section: "a unique_elevation: one section of a long original amateur
      wall mural seen straight on, sun-faded and chalky, pale washed-out blue-grey
      painted wall, dull muted colours, flaking paint, a sandy strip along the very
      bottom edge that runs off both sides of the image at the same height, the
      blue-grey sky colour also reaching both side edges so that sections join, no
      frame, no words";
    - the wall and small palm: "this section: nearly empty sky with a low sandy
      ground and one small faded palm tree near the right, all subject matter in
      the lower half of the image";
    - the cone and figures: "this section: one tall dark brown cone-shaped mountain
      standing in the left half reaching near the top of the image, beside it at
      the right two small faded pale figures in long loose robes and hats, painted
      loosely in dull pink and grey, standing on the sand, small in the frame";
    - the palm and graffiti: "this section: a bright yellow-green palm tree at the
      far left, then a loose black-and-white outlined graffiti piece of tangled
      abstract shapes, then a dull red-orange graffiti piece with black outline at
      the right, abstract shapes that spell nothing, all subject matter in the lower
      half of the image";
    - the end graffiti: "a unique_elevation: original wall graffiti on a pale
      sky-blue painted wall, very wide panoramic composition filling the whole
      image, two big rounded abstract bubble-letter shapes that do not spell
      anything, thick black outlines, orange, rust and cream fills, dripping spray
      paint, a black-and-white wave of tangled outlines, frontal flat view of the
      wall surface, weathered sun-faded, no frame, no real words".
- The folder's other textures are original: see [README.md](README.md).
