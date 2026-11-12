# Mersea provenance

- **`mural.png`**: the mural on Mersea's courtyard container (`mersea_live_attachment.gd`
  hands it to `mersea_model.gd`).
  - It reconstructs a real artwork: *Rocky Purslane* by Nathaniel J. Bice, painted
    in fall 2023. The artist's murals page, <https://njbice.com/murals/> (checked
    2026-11-12), says: "“Rocky Purslane” is a 22′ wide shipping container mural
    created for Mersea restaurant on Treasure Island." The mural's own "BY NJ BICE"
    lettering is in the reconstruction too. The game credits it in
    `game/resources/ui/credits.json` (Murals).
  - Made in this project on 2026-10-02 with the built-in image-generation tool,
    from the restaurant's own photograph of the mural, as source-inspired game art
    on a flat grey ground: not a scan or an exact copy. No photograph is in the
    repository or the game.
  - The study notes, with the sources and the generation prompt:
    `evidence/building-quality-drafts/2026-10-02/mersea-mural-quality/README.md`.
- **`gravel_albedo.png`**: generated with `tools/generate-texture` from a text prompt
  only (`discovery/MERSEA_STUDY.md`).
- **`brass_albedo.png`, `brass_normal.png`, `brass_roughness.png`**: the bar face's
  brushed-metal maps, made in this project during the Mersea study
  (`discovery/MERSEA_STUDY.md`); no source photograph is recorded for them.
