# Mersea provenance

- **`mural.png`**: the mural on Mersea's courtyard container (`mersea_live_attachment.gd`
  hands it to `mersea_model.gd`).
  - It reconstructs a real artwork, the floral mural on the restaurant's container.
    Its artist is not established: neither the study notes nor the restaurant's
    site names the mural's painter. The site's About page (checked 2026-11-12) says
    "Artwork by famous New York street artist - @TomBobNYC" without saying which
    artwork. The game credits the mural by what and where it is in
    `game/resources/ui/credits.json` (Public art).
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
