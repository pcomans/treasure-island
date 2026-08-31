# Frozen USGS terrain source

Checked and acquired: 2026-08-28

`treasure-island-ybi-usgs-3dep-2023.tif` is the immutable elevation input for Treasure Island and Yerba Buena Island. OSM remains authoritative for every horizontal shoreline, road, public-space, and building footprint; this raster supplies only bare-earth elevation.

## Exact source and export

- Publisher/service: U.S. Geological Survey, 3D Elevation Program (3DEP), `https://elevation.nationalmap.gov/arcgis/rest/services/3DEPElevation/ImageServer`
- Locked catalogue object: `OBJECTID=71423`, title `USGS 1 Meter 10 x55y419 CA_SanFrancisco_B23`
- Acquisition date reported by the catalogue: `2023-04-20`
- Source tile: `USGS_1M_10_x55y419_CA_SanFrancisco_B23.tif`
- Source URL: `https://prd-tnm.s3.amazonaws.com/StagedProducts/Elevation/1m/Projects/CA_SanFrancisco_B23/TIFF/USGS_1M_10_x55y419_CA_SanFrancisco_B23.tif`
- Vertical datum: NAVD 88
- Export parameters: WGS84 bbox `[-122.3800, 37.8060, -122.3580, 37.8330]`, `1669x2048`, F32 TIFF, bilinear interpolation, `esriMosaicLockRaster` with `lockRasterIds=[71423]`
- Returned GeoTIFF bounds: `[-122.380001708984, 37.806, -122.357998291016, 37.833]`
- Frozen file: `10,160,678` bytes; SHA-256 `3af54acdd116f3e253af8ece5ec501a08dff94cfca47b7f05f2c326c9ba33f3f`

USGS data are public domain. The dynamic service and exact tile require no account, credential, purchase, or recurring service.

## Integrity checks

The service emits an uncompressed tiled float TIFF with zero-byte-count tiles over empty water. Some generic image viewers abort at the first sparse tile and incorrectly report an all-zero image. The project-owned reader deliberately treats those tiles as absent and reads valid F32 tiles directly; no GDAL or new package is required.

The generator refuses the raster unless all of these pins match:

- dimensions `1669x2048`
- valid samples `2,492,288`
- source elevation range `-1.080` to `104.756 m`
- ferry vicinity `4.037 m`, central TI `3.265 m`, northern TI `3.467 m`
- YBI high ground `104.756 m`, low shoreline `0.000 m`

The first attempted `2048x3072` export exceeded the service's `maxDownloadSizeLimit=2048`, produced malformed sparse tile metadata, and was rejected and replaced; it is not retained. The accepted export keeps both dimensions within the advertised limit and its island samples were read directly before adoption.

## Derived use

`tools/build_godot_world.mjs` verifies this exact hash, samples the raster, clips a deterministic 32 m terrain tessellation to the frozen OSM shorelines, drapes roads/public-space overlays, assigns each building a flat base sampled from the generated terrain surface, and emits `generated/world/terrain.json` with source statistics and terrain-aware route/capture anchors. Treasure Island terrain is colliding/playable; YBI remains non-colliding context. Regenerate rather than editing derived JSON.
