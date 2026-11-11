#!/usr/bin/env node
// The sun's true position over Treasure Island at a local date and time, by the
// NOAA Solar Calculator's method (Meeus' low-accuracy formulas: the sun's
// geometric mean longitude and anomaly, the equation of centre, the obliquity and
// its nutation correction, the equation of time, the hour angle from true solar
// time, then NOAA's atmospheric refraction). Good to a few hundredths of a degree.
//
// The Sun node in game/scenes/main.tscn states its moment and these two angles in
// its solar_* metadata, and game/tests/shared/building_shots.gd's "sun" views take
// them; compute both here rather than by eye. Azimuth is clockwise from true
// north, which is world -Z (tools/lib/coordinates.mjs: +X east, -Z north), so the
// direction to the sun is (sin az * cos el, sin el, -cos az * cos el) and the
// light's rotation_degrees is (-elevation, 180 - azimuth, 0).
//
//   node tools/solar_position.mjs "2026-11-13 12:30" [--utc-offset -8] [--lat 37.82] [--lon -122.37]
//
// --utc-offset is hours east of UTC for the stated local time: -8 for PST, -7
// for PDT.

import { resolve } from "node:path";
import { fileURLToPath } from "node:url";

const RAD = Math.PI / 180;

function julianDay(year, month, day) {
  let y = year;
  let m = month;
  if (m <= 2) {
    y -= 1;
    m += 12;
  }
  const a = Math.floor(y / 100);
  const b = 2 - a + Math.floor(a / 4);
  return Math.floor(365.25 * (y + 4716)) + Math.floor(30.6001 * (m + 1)) + day + b - 1524.5;
}

// {elevation_deg (refracted), azimuth_deg, equation_of_time_min, declination_deg}
// for a local wall-clock time `utcOffsetHours` east of UTC.
export function solarPosition({ year, month, day, hour, minute, utcOffsetHours, latitude, longitude }) {
  const localMinutes = hour * 60 + minute;
  const jd = julianDay(year, month, day) + (localMinutes / 60 - utcOffsetHours) / 24;
  const t = (jd - 2451545) / 36525;
  const meanLongitude = (((280.46646 + t * (36000.76983 + t * 0.0003032)) % 360) + 360) % 360;
  const meanAnomaly = 357.52911 + t * (35999.05029 - 0.0001537 * t);
  const eccentricity = 0.016708634 - t * (0.000042037 + 0.0000001267 * t);
  const centre =
    Math.sin(meanAnomaly * RAD) * (1.914602 - t * (0.004817 + 0.000014 * t)) +
    Math.sin(2 * meanAnomaly * RAD) * (0.019993 - 0.000101 * t) +
    Math.sin(3 * meanAnomaly * RAD) * 0.000289;
  const trueLongitude = meanLongitude + centre;
  const omega = 125.04 - 1934.136 * t;
  const apparentLongitude = trueLongitude - 0.00569 - 0.00478 * Math.sin(omega * RAD);
  const meanObliquity = 23 + (26 + (21.448 - t * (46.815 + t * (0.00059 - t * 0.001813))) / 60) / 60;
  const obliquity = meanObliquity + 0.00256 * Math.cos(omega * RAD);
  const declination = Math.asin(Math.sin(obliquity * RAD) * Math.sin(apparentLongitude * RAD)) / RAD;
  const y = Math.tan((obliquity / 2) * RAD) ** 2;
  const equationOfTime =
    (4 *
      (y * Math.sin(2 * meanLongitude * RAD) -
        2 * eccentricity * Math.sin(meanAnomaly * RAD) +
        4 * eccentricity * y * Math.sin(meanAnomaly * RAD) * Math.cos(2 * meanLongitude * RAD) -
        0.5 * y * y * Math.sin(4 * meanLongitude * RAD) -
        1.25 * eccentricity * eccentricity * Math.sin(2 * meanAnomaly * RAD))) /
    RAD;
  const trueSolarMinutes = (((localMinutes + equationOfTime + 4 * longitude - 60 * utcOffsetHours) % 1440) + 1440) % 1440;
  const hourAngle = trueSolarMinutes / 4 < 0 ? trueSolarMinutes / 4 + 180 : trueSolarMinutes / 4 - 180;
  const cosZenith =
    Math.sin(latitude * RAD) * Math.sin(declination * RAD) +
    Math.cos(latitude * RAD) * Math.cos(declination * RAD) * Math.cos(hourAngle * RAD);
  const zenith = Math.acos(Math.min(1, Math.max(-1, cosZenith))) / RAD;
  const geometric = 90 - zenith;
  let refraction = 0;
  if (geometric <= 85) {
    const tangent = Math.tan(geometric * RAD);
    if (geometric > 5) refraction = 58.1 / tangent - 0.07 / tangent ** 3 + 0.000086 / tangent ** 5;
    else if (geometric > -0.575) refraction = 1735 + geometric * (-518.2 + geometric * (103.4 + geometric * (-12.79 + geometric * 0.711)));
    else refraction = -20.772 / tangent;
    refraction /= 3600;
  }
  const cosAzimuth =
    (Math.sin(latitude * RAD) * Math.cos(zenith * RAD) - Math.sin(declination * RAD)) /
    (Math.cos(latitude * RAD) * Math.sin(zenith * RAD));
  const angle = Math.acos(Math.min(1, Math.max(-1, cosAzimuth))) / RAD;
  const azimuth = hourAngle > 0 ? (angle + 180) % 360 : (540 - angle) % 360;
  return {
    elevation_deg: geometric + refraction,
    azimuth_deg: azimuth,
    equation_of_time_min: equationOfTime,
    declination_deg: declination,
  };
}

function main() {
  const args = process.argv.slice(2);
  const option = (name, fallback) => {
    const index = args.indexOf(name);
    return index >= 0 ? Number(args[index + 1]) : fallback;
  };
  const match = /^(\d{4})-(\d{2})-(\d{2}) (\d{1,2}):(\d{2})$/.exec(args[0] ?? "");
  if (!match) {
    process.stderr.write('usage: node tools/solar_position.mjs "YYYY-MM-DD HH:MM" [--utc-offset -8] [--lat 37.82] [--lon -122.37]\n');
    process.exit(2);
  }
  const [year, month, day, hour, minute] = match.slice(1).map(Number);
  const utcOffsetHours = option("--utc-offset", -8);
  const latitude = option("--lat", 37.82);
  const longitude = option("--lon", -122.37);
  const sun = solarPosition({ year, month, day, hour, minute, utcOffsetHours, latitude, longitude });
  const elevation = +sun.elevation_deg.toFixed(2);
  const azimuth = +sun.azimuth_deg.toFixed(2);
  const toSun = [
    Math.sin(azimuth * RAD) * Math.cos(elevation * RAD),
    Math.sin(elevation * RAD),
    -Math.cos(azimuth * RAD) * Math.cos(elevation * RAD),
  ].map((value) => +value.toFixed(4));
  process.stdout.write(`${JSON.stringify({
    local_time: args[0],
    utc_offset_hours: utcOffsetHours,
    latitude,
    longitude,
    elevation_deg: elevation,
    azimuth_deg: azimuth,
    equation_of_time_min: +sun.equation_of_time_min.toFixed(2),
    declination_deg: +sun.declination_deg.toFixed(2),
    world_direction_to_sun_xyz: toSun,
    shadow_bearing_deg: +((azimuth + 180) % 360).toFixed(2),
    light_rotation_degrees: [-elevation, +(180 - azimuth).toFixed(2), 0],
  })}\n`);
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main();
