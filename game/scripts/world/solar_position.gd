class_name SolarPosition
extends RefCounted
## The sun's true position at an instant, seen from a place: tools/solar_position.mjs
## in GDScript, the same algorithm step for step (the NOAA Solar Calculator's
## method: Meeus' low-accuracy formulas for the sun's geometric mean longitude and
## anomaly, the equation of centre, the obliquity and its nutation correction, the
## equation of time, the hour angle from true solar time, then NOAA's atmospheric
## refraction). The Node tool stays the reference: game/tests/headless_day_clock_contract.gd
## checks this against the table it prints in each tools/test.sh run (--table).
## Any date and any time, the sun below the horizon included.
##
## Azimuth is clockwise from true north, which is world -Z (tools/lib/coordinates.mjs:
## +X east, -Z north), so the direction to the sun is
## (sin az * cos el, sin el, -cos az * cos el) and a light shining from it has
## rotation_degrees (-elevation, 180 - azimuth, 0).

const RAD := PI / 180.0
## The Julian day of the Unix epoch, 1970-01-01 00:00 UTC.
const UNIX_EPOCH_JD := 2440587.5


## The sun at `unix_seconds` (UTC) from latitude and longitude (degrees, north and
## east positive): {elevation_deg (refracted), azimuth_deg, hour_angle_deg (negative
## before solar noon, positive after), equation_of_time_min, declination_deg}.
static func at(unix_seconds: float, latitude: float, longitude: float) -> Dictionary:
	# The Node tool's julianDay(date) + local hours less the offset, for a UTC instant.
	var jd := UNIX_EPOCH_JD + unix_seconds / 86400.0
	var t := (jd - 2451545.0) / 36525.0
	var mean_longitude := fposmod(280.46646 + t * (36000.76983 + t * 0.0003032), 360.0)
	var mean_anomaly := 357.52911 + t * (35999.05029 - 0.0001537 * t)
	var eccentricity := 0.016708634 - t * (0.000042037 + 0.0000001267 * t)
	var centre := sin(mean_anomaly * RAD) * (1.914602 - t * (0.004817 + 0.000014 * t)) \
		+ sin(2.0 * mean_anomaly * RAD) * (0.019993 - 0.000101 * t) \
		+ sin(3.0 * mean_anomaly * RAD) * 0.000289
	var true_longitude := mean_longitude + centre
	var omega := 125.04 - 1934.136 * t
	var apparent_longitude := true_longitude - 0.00569 - 0.00478 * sin(omega * RAD)
	var mean_obliquity := 23.0 + (26.0 + (21.448 - t * (46.815 + t * (0.00059 - t * 0.001813))) / 60.0) / 60.0
	var obliquity := mean_obliquity + 0.00256 * cos(omega * RAD)
	var declination := asin(sin(obliquity * RAD) * sin(apparent_longitude * RAD)) / RAD
	var y := pow(tan(obliquity / 2.0 * RAD), 2.0)
	var equation_of_time := 4.0 * (y * sin(2.0 * mean_longitude * RAD) \
		- 2.0 * eccentricity * sin(mean_anomaly * RAD) \
		+ 4.0 * eccentricity * y * sin(mean_anomaly * RAD) * cos(2.0 * mean_longitude * RAD) \
		- 0.5 * y * y * sin(4.0 * mean_longitude * RAD) \
		- 1.25 * eccentricity * eccentricity * sin(2.0 * mean_anomaly * RAD)) / RAD
	# Minutes into the UTC day: the Node tool's local minutes less 60 * its offset.
	var utc_minutes := fposmod(unix_seconds, 86400.0) / 60.0
	var true_solar_minutes := fposmod(utc_minutes + equation_of_time + 4.0 * longitude, 1440.0)
	var hour_angle := true_solar_minutes / 4.0 - 180.0
	var cos_zenith := sin(latitude * RAD) * sin(declination * RAD) \
		+ cos(latitude * RAD) * cos(declination * RAD) * cos(hour_angle * RAD)
	var zenith := acos(clampf(cos_zenith, -1.0, 1.0)) / RAD
	var geometric := 90.0 - zenith
	var refraction := 0.0
	if geometric <= 85.0:
		var tangent := tan(geometric * RAD)
		if geometric > 5.0:
			refraction = 58.1 / tangent - 0.07 / pow(tangent, 3.0) + 0.000086 / pow(tangent, 5.0)
		elif geometric > -0.575:
			refraction = 1735.0 + geometric * (-518.2 + geometric * (103.4 + geometric * (-12.79 + geometric * 0.711)))
		else:
			refraction = -20.772 / tangent
		refraction /= 3600.0
	var cos_azimuth := (sin(latitude * RAD) * cos(zenith * RAD) - sin(declination * RAD)) \
		/ (cos(latitude * RAD) * sin(zenith * RAD))
	var angle := acos(clampf(cos_azimuth, -1.0, 1.0)) / RAD
	var azimuth := fmod(angle + 180.0, 360.0) if hour_angle > 0.0 else fmod(540.0 - angle, 360.0)
	return {
		"elevation_deg": geometric + refraction,
		"azimuth_deg": azimuth,
		"hour_angle_deg": hour_angle,
		"equation_of_time_min": equation_of_time,
		"declination_deg": declination,
	}


## The world direction toward a sun at this elevation and azimuth (degrees).
static func direction_to(elevation_deg: float, azimuth_deg: float) -> Vector3:
	var elevation := deg_to_rad(elevation_deg)
	var azimuth := deg_to_rad(azimuth_deg)
	return Vector3(sin(azimuth) * cos(elevation), sin(elevation), -cos(azimuth) * cos(elevation))
