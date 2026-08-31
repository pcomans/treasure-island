import { readFileSync } from "node:fs";

import { inverseProjectEastNorth } from "./coordinates.mjs";
import { invariant, roundCoordinate } from "./world-contract.mjs";

const TIFF_TYPES = Object.freeze({
  2: 1,
  3: 2,
  4: 4,
  5: 8,
  11: 4,
  12: 8,
});

function readTiffArray(buffer, view, littleEndian, entryOffset) {
  const type = view.getUint16(entryOffset + 2, littleEndian);
  const count = view.getUint32(entryOffset + 4, littleEndian);
  const elementBytes = TIFF_TYPES[type];
  invariant(elementBytes != null, `Unsupported TIFF field type ${type}`);
  const byteLength = count * elementBytes;
  const valueOffset = byteLength <= 4
    ? entryOffset + 8
    : view.getUint32(entryOffset + 8, littleEndian);
  invariant(valueOffset >= 0 && valueOffset + byteLength <= buffer.length, "TIFF field points outside the file");
  const values = [];
  for (let index = 0; index < count; index += 1) {
    const offset = valueOffset + index * elementBytes;
    if (type === 2) values.push(view.getUint8(offset));
    else if (type === 3) values.push(view.getUint16(offset, littleEndian));
    else if (type === 4) values.push(view.getUint32(offset, littleEndian));
    else if (type === 5) values.push(
      view.getUint32(offset, littleEndian) / view.getUint32(offset + 4, littleEndian),
    );
    else if (type === 11) values.push(view.getFloat32(offset, littleEndian));
    else if (type === 12) values.push(view.getFloat64(offset, littleEndian));
    else throw new Error(`TIFF field type ${type} is not numeric`);
  }
  return values;
}

function parseTiff(path) {
  const buffer = readFileSync(path);
  const view = new DataView(buffer.buffer, buffer.byteOffset, buffer.byteLength);
  const byteOrder = buffer.toString("ascii", 0, 2);
  invariant(byteOrder === "II" || byteOrder === "MM", `Unsupported TIFF byte order ${byteOrder}`);
  const littleEndian = byteOrder === "II";
  invariant(view.getUint16(2, littleEndian) === 42, "Input is not a classic TIFF");
  const ifdOffset = view.getUint32(4, littleEndian);
  const entryCount = view.getUint16(ifdOffset, littleEndian);
  const fields = new Map();
  for (let index = 0; index < entryCount; index += 1) {
    const entryOffset = ifdOffset + 2 + index * 12;
    const tag = view.getUint16(entryOffset, littleEndian);
    fields.set(tag, readTiffArray(buffer, view, littleEndian, entryOffset));
  }
  const scalar = (tag, label) => {
    const values = fields.get(tag);
    invariant(values?.length === 1, `TIFF is missing scalar ${label}`);
    return values[0];
  };
  const width = scalar(256, "ImageWidth");
  const height = scalar(257, "ImageLength");
  const bitsPerSample = scalar(258, "BitsPerSample");
  const compression = scalar(259, "Compression");
  const samplesPerPixel = scalar(277, "SamplesPerPixel");
  const sampleFormat = scalar(339, "SampleFormat");
  const tileWidth = scalar(322, "TileWidth");
  const tileHeight = scalar(323, "TileLength");
  const tileOffsets = fields.get(324);
  const tileByteCounts = fields.get(325);
  const pixelScale = fields.get(33550);
  const tiePoints = fields.get(33922);
  invariant(bitsPerSample === 32 && sampleFormat === 3, "Terrain TIFF must contain IEEE F32 samples");
  invariant(compression === 1 && samplesPerPixel === 1, "Terrain TIFF must be uncompressed single-band data");
  invariant(pixelScale?.length === 3 && tiePoints?.length >= 6, "Terrain TIFF lacks GeoTIFF scale/tiepoint tags");
  const tileColumns = Math.ceil(width / tileWidth);
  const tileRows = Math.ceil(height / tileHeight);
  invariant(tileOffsets?.length === tileColumns * tileRows, "Terrain TIFF tile offset count is inconsistent");
  invariant(tileByteCounts?.length === tileOffsets.length, "Terrain TIFF tile byte-count count is inconsistent");
  return {
    path,
    buffer,
    view,
    littleEndian,
    width,
    height,
    tileWidth,
    tileHeight,
    tileColumns,
    tileRows,
    tileOffsets,
    tileByteCounts,
    originLongitude: tiePoints[3],
    originLatitude: tiePoints[4],
    pixelSizeLongitude: pixelScale[0],
    pixelSizeLatitude: pixelScale[1],
  };
}

function pixelValue(raster, column, row) {
  if (column < 0 || row < 0 || column >= raster.width || row >= raster.height) return null;
  const tileColumn = Math.floor(column / raster.tileWidth);
  const tileRow = Math.floor(row / raster.tileHeight);
  const tileIndex = tileRow * raster.tileColumns + tileColumn;
  const tileOffset = raster.tileOffsets[tileIndex];
  const byteCount = raster.tileByteCounts[tileIndex];
  if (tileOffset === 0 || byteCount < 4) return null;
  const innerColumn = column % raster.tileWidth;
  const innerRow = row % raster.tileHeight;
  const byteOffset = tileOffset + (innerRow * raster.tileWidth + innerColumn) * 4;
  if (byteOffset + 4 > tileOffset + byteCount || byteOffset + 4 > raster.buffer.length) return null;
  const value = raster.view.getFloat32(byteOffset, raster.littleEndian);
  return Number.isFinite(value) && Math.abs(value) < 10_000 ? value : null;
}

function nearestValidPixel(raster, column, row, maximumRadius = 32) {
  const centerColumn = Math.round(column);
  const centerRow = Math.round(row);
  for (let radius = 0; radius <= maximumRadius; radius += 1) {
    for (let deltaRow = -radius; deltaRow <= radius; deltaRow += 1) {
      for (let deltaColumn = -radius; deltaColumn <= radius; deltaColumn += 1) {
        if (radius > 0 && Math.abs(deltaRow) !== radius && Math.abs(deltaColumn) !== radius) continue;
        const value = pixelValue(raster, centerColumn + deltaColumn, centerRow + deltaRow);
        if (value != null) return value;
      }
    }
  }
  return null;
}

export function loadTerrainRaster(path) {
  const raster = parseTiff(path);
  const sampleLonLat = (longitude, latitude) => {
    const pixelColumn = (longitude - raster.originLongitude) / raster.pixelSizeLongitude - 0.5;
    const pixelRow = (raster.originLatitude - latitude) / raster.pixelSizeLatitude - 0.5;
    const left = Math.floor(pixelColumn);
    const top = Math.floor(pixelRow);
    const fractionX = pixelColumn - left;
    const fractionY = pixelRow - top;
    const samples = [
      pixelValue(raster, left, top),
      pixelValue(raster, left + 1, top),
      pixelValue(raster, left, top + 1),
      pixelValue(raster, left + 1, top + 1),
    ];
    if (samples.every((value) => value != null)) {
      const topValue = samples[0] * (1 - fractionX) + samples[1] * fractionX;
      const bottomValue = samples[2] * (1 - fractionX) + samples[3] * fractionX;
      return topValue * (1 - fractionY) + bottomValue * fractionY;
    }
    const fallback = nearestValidPixel(raster, pixelColumn, pixelRow);
    invariant(fallback != null, `No USGS terrain sample near ${longitude},${latitude}`);
    return fallback;
  };
  const sampleEastNorth = (east, north) => {
    const [longitude, latitude] = inverseProjectEastNorth([east, north]);
    return sampleLonLat(longitude, latitude);
  };
  return {
    width: raster.width,
    height: raster.height,
    bbox_wgs84: [
      raster.originLongitude,
      raster.originLatitude - raster.height * raster.pixelSizeLatitude,
      raster.originLongitude + raster.width * raster.pixelSizeLongitude,
      raster.originLatitude,
    ].map((value) => Number(value.toFixed(12))),
    pixel_size_degrees: [raster.pixelSizeLongitude, raster.pixelSizeLatitude],
    sampleLonLat,
    sampleEastNorth,
    sampleWorldXZ(x, z) {
      return sampleEastNorth(x, -z);
    },
    sampleTerrainEastNorth(east, north) {
      return roundCoordinate(Math.max(0.15, sampleEastNorth(east, north)));
    },
    statistics() {
      let validSampleCount = 0;
      let minimum = Infinity;
      let maximum = -Infinity;
      let minimumPixel = null;
      let maximumPixel = null;
      for (let row = 0; row < raster.height; row += 1) {
        for (let column = 0; column < raster.width; column += 1) {
          const value = pixelValue(raster, column, row);
          if (value == null) continue;
          validSampleCount += 1;
          if (value < minimum) {
            minimum = value;
            minimumPixel = [column, row];
          }
          if (value > maximum) {
            maximum = value;
            maximumPixel = [column, row];
          }
        }
      }
      invariant(validSampleCount > 0 && minimumPixel != null && maximumPixel != null, "Terrain TIFF has no valid samples");
      const pixelLonLat = ([column, row]) => [
        raster.originLongitude + (column + 0.5) * raster.pixelSizeLongitude,
        raster.originLatitude - (row + 0.5) * raster.pixelSizeLatitude,
      ].map((value) => Number(value.toFixed(9)));
      return {
        valid_sample_count: validSampleCount,
        minimum_elevation_m: roundCoordinate(minimum),
        minimum_lon_lat: pixelLonLat(minimumPixel),
        maximum_elevation_m: roundCoordinate(maximum),
        maximum_lon_lat: pixelLonLat(maximumPixel),
      };
    },
  };
}
