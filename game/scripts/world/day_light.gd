class_name DayLight
extends RefCounted
## The light of the time of day: the sun's colour and strength, the sky's colours,
## the ambient light, the fog, the exposure and the distant horizon's brightness, as
## curves over the sun's height alone (degrees, the refracted elevation DaySun
## draws). DaySun puts them on with the sun, at each of its steps.
##
## The curves are KEYS: each the whole look at its elevation, from high sun down.
## Between two keys every value runs in a straight line with the elevation; above
## the first key the look is the first key's, and below the last it is the last
## key's, NIGHT_FLOOR. Dawn is dusk run backwards, since only the height counts.
##
## The first key is main.tscn's daylight exactly (its Sun, its sky material, its
## environment) and holds from FULL_DAY_ELEVATION_DEG up, so the recorded moment
## (33.43 degrees, every test's, capture's and the web's) keeps today's look to the
## bit: there DaySun writes nothing. headless_day_clock_contract.gd checks both.
##
## Colours are as the engine's properties take them (sRGB, alpha unused). The
## distant horizon's art (game/resources/textures/context/fresh_bay) draws unlit
## and without fog, so one global factor dims it (horizon_light, owner 2026-11-14:
## one simple brightness factor), and as it falls the art turns grey and fades into
## the sky's horizon colour (horizon_haze), a hazy silhouette at sunset and a dark
## shape at night rather than daylight's teal hills pasted on a pink sky. Leaves,
## bark, impostors and grass scale their specular by another (vegetation_sheen):
## with a low sun behind a crown, the grazing Fresnel off its leaves (the engine's
## specular rises toward 0.7 at a grazing angle) washed it pale grey, which a crown
## without specular did not show (2026-11-14). As the sun comes level with the
## facades, its specular (sun_specular) and the glow's luminance cap (glow_cap)
## come down, so a glass curtain wall's sun glint and its bloom stay a glint.
##
## The night (owner, 2026-11-15: "a dark night with stars, a flashlight that turns
## on by itself and headlights on the car you drive... No glowing street lamps or
## lit windows"): the sky's stars fade in through dusk (stars, the sky material's
## star_energy); night says how dark it is, 0 by day to 1 at night, and the lights
## that turn on by themselves follow it (NightLights: the player's flashlight, the
## driven car's headlights); the parked cars' day-running and tail lamps go out as
## the sun sets (parked_lamps, a global uniform of street_clutter.gdshader; the car
## being driven keeps its own lit).

## From this height up the look is daylight's: main.tscn's.
const FULL_DAY_ELEVATION_DEG := 30.0

## The night floor: from FLOOR_ELEVATION_DEG down (astronomical dusk), through the
## night until dawn comes back up past it, the look holds. A dark navy sky full of
## stars, a little lighter toward the horizon; the island dark, its buildings, trees
## and the distant hills shapes against the sky, roads and kerbs just told apart by
## a faint cool fill (the sky's and a moon's, with no moon drawn) and a raised
## exposure; no sun, no glow on the clouds. The flashlight and the driven car's
## headlights light the way.
const FLOOR_ELEVATION_DEG := -18.0
const NIGHT_FLOOR := {
	"elevation": FLOOR_ELEVATION_DEG,
	"sun_color": Color(1.0, 0.56, 0.32), "sun_energy": 0.0, "sun_specular": 0.3,
	"sky_top": Color(0.016, 0.024, 0.055), "sky_horizon": Color(0.075, 0.085, 0.115),
	"sky_low_sun": Color(0.075, 0.085, 0.115),
	"ground_bottom": Color(0.02, 0.02, 0.022), "ground_horizon": Color(0.05, 0.055, 0.075),
	"cloud_glow": Color(0.0, 0.0, 0.0), "cloud_glow_energy": 0.0,
	"ambient_color": Color(0.17, 0.2, 0.3), "ambient_energy": 0.9,
	"fog_color": Color(0.06, 0.07, 0.095), "fog_energy": 0.55, "fog_sun_scatter": 0.0,
	"exposure": 1.58, "glow_cap": 3.0,
	"horizon_light": 0.02, "vegetation_sheen": 0.12,
	"stars": 1.0, "night": 1.0, "parked_lamps": 0.0, "shadow_reach": 0.7,
}

## The look from high sun down to the night floor. Every key holds every value.
const KEYS: Array[Dictionary] = [
	# Daylight: main.tscn's Sun, sky material and environment, exactly.
	{
		"elevation": FULL_DAY_ELEVATION_DEG,
		"sun_color": Color(1.0, 0.96, 0.89), "sun_energy": 1.3, "sun_specular": 0.5,
		"sky_top": Color(0.235, 0.445, 0.785), "sky_horizon": Color(0.74, 0.80, 0.86),
		"sky_low_sun": Color(1.0, 0.80, 0.60),
		"ground_bottom": Color(0.40, 0.40, 0.37), "ground_horizon": Color(0.50, 0.68, 0.84),
		"cloud_glow": Color(0.0, 0.0, 0.0), "cloud_glow_energy": 0.0,
		"ambient_color": Color(0.80, 0.75, 0.66), "ambient_energy": 0.52,
		"fog_color": Color(0.74, 0.80, 0.86), "fog_energy": 0.85, "fog_sun_scatter": 0.0,
		"exposure": 1.18, "glow_cap": 12.0,
		"horizon_light": 1.0, "vegetation_sheen": 1.0,
		"stars": 0.0, "night": 0.0, "parked_lamps": 1.0, "shadow_reach": 1.0,
	},
	# The afternoon sun warming through more air; shade cooler. Glass glints and
	# their bloom held in as the sun comes level with the facades.
	{
		"elevation": 15.0,
		"sun_color": Color(1.0, 0.91, 0.78), "sun_energy": 1.2, "sun_specular": 0.42,
		"sky_top": Color(0.225, 0.43, 0.765), "sky_horizon": Color(0.75, 0.79, 0.83),
		"sky_low_sun": Color(1.0, 0.80, 0.58),
		"ground_bottom": Color(0.39, 0.39, 0.36), "ground_horizon": Color(0.50, 0.66, 0.80),
		"cloud_glow": Color(0.0, 0.0, 0.0), "cloud_glow_energy": 0.0,
		"ambient_color": Color(0.74, 0.73, 0.72), "ambient_energy": 0.52,
		"fog_color": Color(0.75, 0.79, 0.83), "fog_energy": 0.85, "fog_sun_scatter": 0.05,
		"exposure": 1.18, "glow_cap": 6.0,
		"horizon_light": 0.95, "vegetation_sheen": 0.4,
		"stars": 0.0, "night": 0.0, "parked_lamps": 1.0, "shadow_reach": 1.0,
	},
	# The sun's shadows reach the shadow option's whole distance down to here; lower,
	# where a low sun's long shadows across the whole distance cost the most, they reach
	# less (shadow_reach, measured 2026-11-15). Every other value is the straight line
	# between the 15 and 6 degree keys, so the look between them is unchanged.
	{
		"elevation": 10.0,
		"sun_color": Color(1, 0.854444, 0.68), "sun_energy": 1.088889, "sun_specular": 0.353333,
		"sky_top": Color(0.211111, 0.402222, 0.723333), "sky_horizon": Color(0.761111, 0.773333, 0.791111),
		"sky_low_sun": Color(1, 0.766667, 0.524444),
		"ground_bottom": Color(0.373333, 0.367778, 0.343333), "ground_horizon": Color(0.488889, 0.626667, 0.755556),
		"cloud_glow": Color(0, 0, 0), "cloud_glow_energy": 0.0,
		"ambient_color": Color(0.695556, 0.702222, 0.753333), "ambient_energy": 0.508889,
		"fog_color": Color(0.761111, 0.773333, 0.796667), "fog_energy": 0.822222, "fog_sun_scatter": 0.133333,
		"exposure": 1.196667, "glow_cap": 4.333333,
		"horizon_light": 0.788889, "vegetation_sheen": 0.244444,
		"stars": 0.0, "night": 0.0, "parked_lamps": 1.0, "shadow_reach": 1.0,
	},
	# Golden hour: warm sun, blue shade, a warm haze toward the sun.
	{
		"elevation": 6.0,
		"sun_color": Color(1.0, 0.81, 0.6), "sun_energy": 1.0, "sun_specular": 0.3,
		"sky_top": Color(0.2, 0.38, 0.69), "sky_horizon": Color(0.77, 0.76, 0.76),
		"sky_low_sun": Color(1.0, 0.74, 0.48),
		"ground_bottom": Color(0.36, 0.35, 0.33), "ground_horizon": Color(0.48, 0.6, 0.72),
		"cloud_glow": Color(0.0, 0.0, 0.0), "cloud_glow_energy": 0.0,
		"ambient_color": Color(0.66, 0.68, 0.78), "ambient_energy": 0.5,
		"fog_color": Color(0.77, 0.76, 0.77), "fog_energy": 0.8, "fog_sun_scatter": 0.2,
		"exposure": 1.21, "glow_cap": 3.0,
		"horizon_light": 0.66, "vegetation_sheen": 0.12,
		"stars": 0.0, "night": 0.0, "parked_lamps": 1.0, "shadow_reach": 0.75,
	},
	{
		"elevation": 3.0,
		"sun_color": Color(1.0, 0.74, 0.5), "sun_energy": 0.8, "sun_specular": 0.3,
		"sky_top": Color(0.18, 0.33, 0.61), "sky_horizon": Color(0.76, 0.70, 0.67),
		"sky_low_sun": Color(1.0, 0.66, 0.40),
		"ground_bottom": Color(0.33, 0.31, 0.30), "ground_horizon": Color(0.44, 0.52, 0.64),
		"cloud_glow": Color(0.0, 0.0, 0.0), "cloud_glow_energy": 0.0,
		"ambient_color": Color(0.62, 0.62, 0.74), "ambient_energy": 0.48,
		"fog_color": Color(0.76, 0.70, 0.67), "fog_energy": 0.75, "fog_sun_scatter": 0.3,
		"exposure": 1.24, "glow_cap": 3.0,
		"horizon_light": 0.5, "vegetation_sheen": 0.12,
		"stars": 0.0, "night": 0.0, "parked_lamps": 0.5, "shadow_reach": 0.7,
	},
	{
		"elevation": 1.0,
		"sun_color": Color(1.0, 0.65, 0.4), "sun_energy": 0.48, "sun_specular": 0.3,
		"sky_top": Color(0.155, 0.28, 0.53), "sky_horizon": Color(0.72, 0.62, 0.58),
		"sky_low_sun": Color(1.0, 0.58, 0.32),
		"ground_bottom": Color(0.28, 0.26, 0.26), "ground_horizon": Color(0.38, 0.44, 0.56),
		"cloud_glow": Color(1.0, 0.55, 0.35), "cloud_glow_energy": 0.15,
		"ambient_color": Color(0.56, 0.56, 0.70), "ambient_energy": 0.46,
		"fog_color": Color(0.72, 0.62, 0.58), "fog_energy": 0.7, "fog_sun_scatter": 0.3,
		"exposure": 1.27, "glow_cap": 3.0,
		"horizon_light": 0.4, "vegetation_sheen": 0.12,
		"stars": 0.0, "night": 0.0, "parked_lamps": 0.0, "shadow_reach": 0.7,
	},
	# The disc gone under the horizon: no sunlight on the island; the clouds, a
	# kilometre and more up, still in it.
	{
		"elevation": -0.5,
		"sun_color": Color(1.0, 0.6, 0.36), "sun_energy": 0.0, "sun_specular": 0.3,
		"sky_top": Color(0.13, 0.23, 0.46), "sky_horizon": Color(0.64, 0.54, 0.53),
		"sky_low_sun": Color(0.95, 0.5, 0.28),
		"ground_bottom": Color(0.24, 0.22, 0.22), "ground_horizon": Color(0.33, 0.37, 0.48),
		"cloud_glow": Color(1.0, 0.48, 0.32), "cloud_glow_energy": 0.35,
		"ambient_color": Color(0.5, 0.52, 0.66), "ambient_energy": 0.46,
		"fog_color": Color(0.62, 0.55, 0.55), "fog_energy": 0.66, "fog_sun_scatter": 0.0,
		"exposure": 1.31, "glow_cap": 3.0,
		"horizon_light": 0.3, "vegetation_sheen": 0.12,
		"stars": 0.0, "night": 0.05, "parked_lamps": 0.0, "shadow_reach": 0.7,
	},
	# Civil dusk: the glow low in the west, the clouds' afterglow fading.
	{
		"elevation": -3.0,
		"sun_color": Color(1.0, 0.56, 0.32), "sun_energy": 0.0, "sun_specular": 0.3,
		"sky_top": Color(0.08, 0.14, 0.31), "sky_horizon": Color(0.42, 0.38, 0.44),
		"sky_low_sun": Color(0.66, 0.38, 0.27),
		"ground_bottom": Color(0.14, 0.13, 0.14), "ground_horizon": Color(0.22, 0.25, 0.33),
		"cloud_glow": Color(0.85, 0.36, 0.32), "cloud_glow_energy": 0.12,
		"ambient_color": Color(0.36, 0.40, 0.56), "ambient_energy": 0.52,
		"fog_color": Color(0.40, 0.38, 0.45), "fog_energy": 0.62, "fog_sun_scatter": 0.0,
		"exposure": 1.4, "glow_cap": 3.0,
		"horizon_light": 0.14, "vegetation_sheen": 0.12,
		"stars": 0.05, "night": 0.25, "parked_lamps": 0.0, "shadow_reach": 0.7,
	},
	{
		"elevation": -6.0,
		"sun_color": Color(1.0, 0.56, 0.32), "sun_energy": 0.0, "sun_specular": 0.3,
		"sky_top": Color(0.055, 0.09, 0.2), "sky_horizon": Color(0.24, 0.25, 0.33),
		"sky_low_sun": Color(0.34, 0.25, 0.26),
		"ground_bottom": Color(0.07, 0.07, 0.075), "ground_horizon": Color(0.15, 0.17, 0.23),
		"cloud_glow": Color(0.0, 0.0, 0.0), "cloud_glow_energy": 0.0,
		"ambient_color": Color(0.27, 0.31, 0.44), "ambient_energy": 0.74,
		"fog_color": Color(0.22, 0.24, 0.32), "fog_energy": 0.6, "fog_sun_scatter": 0.0,
		"exposure": 1.52, "glow_cap": 3.0,
		"horizon_light": 0.06, "vegetation_sheen": 0.12,
		"stars": 0.3, "night": 0.55, "parked_lamps": 0.0, "shadow_reach": 0.7,
	},
	# The deep twilight (batch B's night floor): a dark blue sky lighter at the
	# horizon, the island lit by the sky alone; the first stars.
	{
		"elevation": -8.0,
		"sun_color": Color(1.0, 0.56, 0.32), "sun_energy": 0.0, "sun_specular": 0.3,
		"sky_top": Color(0.045, 0.07, 0.15), "sky_horizon": Color(0.17, 0.2, 0.27),
		"sky_low_sun": Color(0.17, 0.2, 0.27),
		"ground_bottom": Color(0.05, 0.05, 0.055), "ground_horizon": Color(0.12, 0.14, 0.19),
		"cloud_glow": Color(0.0, 0.0, 0.0), "cloud_glow_energy": 0.0,
		"ambient_color": Color(0.23, 0.27, 0.39), "ambient_energy": 0.85,
		"fog_color": Color(0.16, 0.18, 0.25), "fog_energy": 0.6, "fog_sun_scatter": 0.0,
		"exposure": 1.58, "glow_cap": 3.0,
		"horizon_light": 0.035, "vegetation_sheen": 0.12,
		"stars": 0.55, "night": 0.75, "parked_lamps": 0.0, "shadow_reach": 0.7,
	},
	# Nautical dusk: the last of the twilight low in the west.
	{
		"elevation": -12.0,
		"sun_color": Color(1.0, 0.56, 0.32), "sun_energy": 0.0, "sun_specular": 0.3,
		"sky_top": Color(0.026, 0.04, 0.09), "sky_horizon": Color(0.11, 0.125, 0.17),
		"sky_low_sun": Color(0.11, 0.125, 0.17),
		"ground_bottom": Color(0.03, 0.03, 0.035), "ground_horizon": Color(0.08, 0.09, 0.12),
		"cloud_glow": Color(0.0, 0.0, 0.0), "cloud_glow_energy": 0.0,
		"ambient_color": Color(0.2, 0.23, 0.34), "ambient_energy": 0.8,
		"fog_color": Color(0.1, 0.11, 0.15), "fog_energy": 0.58, "fog_sun_scatter": 0.0,
		"exposure": 1.58, "glow_cap": 3.0,
		"horizon_light": 0.025, "vegetation_sheen": 0.12,
		"stars": 0.85, "night": 0.95, "parked_lamps": 0.0, "shadow_reach": 0.7,
	},
	NIGHT_FLOOR,
]

## Every value a key holds, besides its elevation.
const VALUES: Array[String] = [
	"sun_color", "sun_energy", "sun_specular", "sky_top", "sky_horizon", "sky_low_sun", "ground_bottom",
	"ground_horizon", "cloud_glow", "cloud_glow_energy", "ambient_color", "ambient_energy",
	"fog_color", "fog_energy", "fog_sun_scatter", "exposure", "glow_cap", "horizon_light",
	"vegetation_sheen", "stars", "night", "parked_lamps", "shadow_reach",
]

## Where each value goes: the sky material's shader parameter...
const SKY_PARAMETERS := {
	"sky_top": &"sky_top_color", "sky_horizon": &"sky_horizon_color",
	"sky_low_sun": &"low_sun_horizon_color", "ground_bottom": &"ground_bottom_color",
	"ground_horizon": &"ground_horizon_color", "cloud_glow": &"cloud_glow",
	"cloud_glow_energy": &"cloud_glow_energy", "stars": &"star_energy",
}
## ... the environment's property...
const ENVIRONMENT_PROPERTIES := {
	"ambient_color": &"ambient_light_color", "ambient_energy": &"ambient_light_energy",
	"fog_color": &"fog_light_color", "fog_energy": &"fog_light_energy",
	"fog_sun_scatter": &"fog_sun_scatter", "exposure": &"tonemap_exposure",
	"glow_cap": &"glow_hdr_luminance_cap",
}
## ... the Sun's...
const SUN_PROPERTIES := {"sun_color": &"light_color", "sun_energy": &"light_energy", "sun_specular": &"light_specular"}
## ... or a global shader uniform (project.godot's shader_globals): the factors,
## 1.0 there, and horizon_haze, the sky's horizon colour in linear RGB (horizon_haze()),
## that the distant art fades into as horizon_light falls. night goes nowhere in the
## engine: DaySun keeps it for the lights that follow it (NightLights). shadow_reach
## goes to the player's shadow option (ShadowQuality.set_reach): the share of its
## shadow distance the sun casts out to, 1 by day.
const GLOBALS := {
	"horizon_light": &"horizon_light", "vegetation_sheen": &"vegetation_sheen", "horizon_haze": &"horizon_haze",
	"parked_lamps": &"parked_lamps",
}

## The keys in use: KEYS. A probe may put others here (the same shape, the night
## floor last) to try a look without editing these.
static var keys: Array[Dictionary] = KEYS


## The look with the sun `elevation_deg` up: every value in VALUES, and horizon_haze.
static func at(elevation_deg: float) -> Dictionary:
	if elevation_deg >= float(keys[0].elevation):
		return _values(keys[0])
	for index in range(1, keys.size()):
		var lower: Dictionary = keys[index]
		if elevation_deg >= float(lower.elevation):
			var upper: Dictionary = keys[index - 1]
			var t := (elevation_deg - float(lower.elevation)) / (float(upper.elevation) - float(lower.elevation))
			var look := {}
			for value: String in VALUES:
				var from: Variant = lower[value]
				var to: Variant = upper[value]
				look[value] = (from as Color).lerp(to as Color, t) if from is Color else lerpf(float(from), float(to), t)
			look["horizon_haze"] = horizon_haze(look.sky_horizon)
			return look
	return _values(keys[keys.size() - 1])


## Whether the sun is low enough that the look is the night floor.
static func is_floor(elevation_deg: float) -> bool:
	return elevation_deg <= float(keys[keys.size() - 1].elevation)


## The haze the distant art fades into at dusk: the sky's horizon colour (sRGB, as
## the sky material takes it), in linear RGB, as the art's shaders work.
static func horizon_haze(sky_horizon: Color) -> Vector3:
	var linear := sky_horizon.srgb_to_linear()
	return Vector3(linear.r, linear.g, linear.b)


static func _values(key: Dictionary) -> Dictionary:
	var look := {}
	for value: String in VALUES:
		look[value] = key[value]
	look["horizon_haze"] = horizon_haze(key.sky_horizon)
	return look
