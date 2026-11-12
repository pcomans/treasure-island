# Bulgarian Wall provenance

- **`mural.png.dat`**: the mural on the handball-court wall at Ninth Street and
  Avenue D, a PNG kept under a `.dat` name so `court.gd` loads it directly
  (`Image.load_png_from_buffer`), without an import; every export preset ships it
  through its `include_filter`.
  - It reconstructs a real artwork: Oleg Gotchev's mural *Bulgaria in the USA*,
    unveiled on 11 November 2018 (Precita Eyes newsletter, November 2018). The
    game credits it in `game/resources/ui/credits.json` (Public art).
  - Made in this project on 2026-10-03 with the built-in image-generation tool,
    from photographs of the mural, as an approximation for game art: not a scan
    or an exact copy of its lettering. No photograph is in the repository or the
    game.
  - The study notes, with the sources and the generation prompt:
    `evidence/building-quality-drafts/2026-10-02/bulgaria-mural-chinook-study/README.md`.
- The shaders and scripts beside it (`concrete.gdshader`, `roof.gdshader`,
  `siding.gdshader`, `court.gd`, `neighbor.gd`) were written in this project.
