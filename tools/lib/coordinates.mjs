import { invariant, roundCoordinate } from "./world-contract.mjs";

export const EARTH_RADIUS_M = 6_378_137;
export const ORIGIN_LON = -122.37099;
export const ORIGIN_LAT = 37.82376155;

const DEGREES_TO_RADIANS = Math.PI / 180;
const RADIANS_TO_DEGREES = 180 / Math.PI;
const ORIGIN_LATITUDE_COSINE = Math.cos(ORIGIN_LAT * DEGREES_TO_RADIANS);

export function projectLonLat(coordinate) {
  invariant(
    Array.isArray(coordinate) && coordinate.length >= 2,
    "Expected a longitude/latitude coordinate",
  );
  const longitude = Number(coordinate[0]);
  const latitude = Number(coordinate[1]);
  invariant(
    Number.isFinite(longitude) && Number.isFinite(latitude),
    `Non-finite WGS84 coordinate ${JSON.stringify(coordinate)}`,
  );
  return [
    EARTH_RADIUS_M * (longitude - ORIGIN_LON) * DEGREES_TO_RADIANS * ORIGIN_LATITUDE_COSINE,
    EARTH_RADIUS_M * (latitude - ORIGIN_LAT) * DEGREES_TO_RADIANS,
  ];
}

export function inverseProjectEastNorth(coordinate) {
  invariant(
    Array.isArray(coordinate) && coordinate.length >= 2,
    "Expected an east/north coordinate",
  );
  const east = Number(coordinate[0]);
  const north = Number(coordinate[1]);
  invariant(Number.isFinite(east) && Number.isFinite(north), "Non-finite local coordinate");
  return [
    ORIGIN_LON + (east / (EARTH_RADIUS_M * ORIGIN_LATITUDE_COSINE)) * RADIANS_TO_DEGREES,
    ORIGIN_LAT + (north / EARTH_RADIUS_M) * RADIANS_TO_DEGREES,
  ];
}

export function eastNorthToWorld(coordinate, elevation = 0) {
  return [coordinate[0], elevation, -coordinate[1]];
}

export function eastNorthToWorldRounded(coordinate, elevation = 0) {
  return [
    roundCoordinate(coordinate[0]),
    roundCoordinate(elevation),
    roundCoordinate(-coordinate[1]),
  ];
}

export function projectGeoJsonGeometry(geometry) {
  invariant(geometry && typeof geometry.type === "string", "Missing GeoJSON geometry");
  const projectCoordinates = (coordinates, depth) => {
    if (depth === 0) return projectLonLat(coordinates);
    return coordinates.map((child) => projectCoordinates(child, depth - 1));
  };
  if (geometry.type === "LineString") {
    return { type: geometry.type, coordinates: projectCoordinates(geometry.coordinates, 1) };
  }
  if (geometry.type === "Polygon") {
    return { type: geometry.type, coordinates: projectCoordinates(geometry.coordinates, 2) };
  }
  if (geometry.type === "MultiPolygon") {
    return { type: geometry.type, coordinates: projectCoordinates(geometry.coordinates, 3) };
  }
  throw new Error(`Unsupported geometry type ${geometry.type}`);
}

export function verifyProjectionRoundTrip(coordinates, toleranceDegrees = 1e-9) {
  let maximumError = 0;
  for (const coordinate of coordinates) {
    const roundTrip = inverseProjectEastNorth(projectLonLat(coordinate));
    maximumError = Math.max(
      maximumError,
      Math.abs(roundTrip[0] - coordinate[0]),
      Math.abs(roundTrip[1] - coordinate[1]),
    );
  }
  invariant(
    maximumError <= toleranceDegrees,
    `Projection round-trip error ${maximumError} exceeds ${toleranceDegrees}`,
  );
  return maximumError;
}

export function coordinateSystemManifest() {
  return {
    source_crs: "EPSG:4326",
    earth_radius_m: EARTH_RADIUS_M,
    origin_lon: ORIGIN_LON,
    origin_lat: ORIGIN_LAT,
    world_axes: "+X east,+Y up,-Z north",
    meters_per_unit: 1,
    ground_model: "USGS 3DEP bare-earth terrain",
    vertical_datum: "NAVD 88",
    coordinate_rounding_m: 0.001,
  };
}
