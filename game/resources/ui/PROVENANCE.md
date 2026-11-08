# UI image provenance

- **`app_icon.png`, `app_icon_360.png`** (the game's app icon: the cartoon treasure chest with googly eyes, gold coins and a padlock).
  - Owner-supplied, 2026-11-08: the owner sent the picture and asked to use it as the app icon from now on. The original is a 980 x 980 WebP with a transparent background and an sRGB profile, SHA-256 `9866388c6d11d101a6e17681cfb081a2cef5ab60a44e1332f17e129af578dfb9`. It isn't kept in the repo.
  - `tools/make_app_icon.sh <original>` makes `app_icon.png`, the master: the picture unscaled, centred on a transparent 1024 x 1024 square, its visible pixels unchanged. From that it makes `app_icon_360.png` with Lanczos. In both, fully transparent pixels are black.
  - Used as the macOS app icon (`export_presets.cfg` `application/icon`, from the master) and as `application/config/icon` (the 360 version): the Linux window icon, the web favicon and the web's 180 x 180 apple-touch-icon.
- The RISE and RUN button art and the stick in `selgesel/` come from the MIT Selgesel controller; see `game/scripts/vendor/selgesel/README.md`.
