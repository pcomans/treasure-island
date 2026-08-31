extends RefCounted

# Shared fixed XZ anchors plus pinned USGS terrain elevations for rendered evidence
# and continuous traversal QA. Coordinates use +X east/+Z south and NAVD 88 Y.
const CAPTURES := [
	{
		"id": "01-ferry-spawn",
		"region": "ferry_spawn",
		"requested_xz": Vector2(-104.364, 786.024),
		"terrain_y_m": 3.457,
		"yaw": -0.119,
		"intent": "Approved ferry arrival looking into Treasure Island",
	},
	{
		"id": "02-north",
		"region": "north",
		"requested_xz": Vector2(-159.535, -879.905),
		"terrain_y_m": 2.829,
		"yaw": 3.066,
		"intent": "North-island road looking south through the island",
	},
	{
		"id": "03-center",
		"region": "center",
		"requested_xz": Vector2(-159.292, -104.818),
		"terrain_y_m": 3.318,
		"yaw": -1.5707963267948966,
		"intent": "Central grid road looking east across representative massing",
	},
	{
		"id": "04-southwest",
		"region": "southwest",
		"requested_xz": Vector2(-293.543, 335.720),
		"terrain_y_m": 3.199,
		"yaw": -0.509,
		"intent": "Southwest road looking northeast toward the island interior",
	},
	{
		"id": "05-east-perimeter",
		"region": "perimeter",
		"requested_xz": Vector2(606.249, 385.227),
		"terrain_y_m": 2.580,
		"yaw": 0.934,
		"intent": "East perimeter road looking northwest across the shoreline side",
	},
]


static func capture_for_region(region: String) -> Dictionary:
	for capture: Dictionary in CAPTURES:
		if str(capture.region) == region:
			return capture
	return {}
