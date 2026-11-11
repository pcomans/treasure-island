shader_type sky;
// The sky over Treasure Island: a daylight gradient, the sun's disc and halo,
// fair-weather cumulus and high cirrus. All of it is computed here from the live
// sun (LIGHT0), so a different sun direction, colour or energy relights it; no
// light, cloud or time of day is baked in.
//
// Cumulus: a short ray march through a slab of air round a curved earth, so the
// clouds sink toward the horizon instead of stretching to it. Density comes from
// cloud_noise (tools/bake_sky_noise.mjs): a weather field says where clouds
// stand and how tall, the red channel gives them their shape and the blue one
// frays their edges. Each step is lit by the sun through a few density taps
// toward it (bright tops and sunward sides, shaded bases), by a little light
// scattered deeper in, and by the sky. Distant clouds fade into the haze.
//
// Cost: the march runs in the half-resolution pass and the full-resolution pass
// only blends it over the gradient, the sun and the cirrus. The Compatibility
// renderer (the web build) has no half-resolution pass, so there the same march
// runs in the main pass, at the view's own resolution.
//
// Reflections and ambient light: the shader reads no TIME and no camera
// position, so Godot does not redraw the radiance map every frame. The clouds
// move by the global uniform sky_cloud_drift (game/scripts/world/sky_weather.gd
// sets it each frame), which does not mark the sky's material changed; the
// radiance map draws the clouds where reflection_cloud_drift puts them, and
// re-renders only when that script moves it (every few seconds) or the sun
// changes. The radiance map leaves out the sun's disc (the sun light itself
// gives surfaces their highlight) and shows the land's bounce light below the
// horizon instead of the ground colours.
render_mode use_half_res_pass, use_debanding;

// Metres the clouds have drifted (x, z) and risen through the noise (y);
// sky_weather.gd wraps them so every layer's offset wraps with its tile.
global uniform vec3 sky_cloud_drift;
uniform vec3 reflection_cloud_drift = vec3(0.0);
uniform sampler3D cloud_noise : filter_linear_mipmap, repeat_enable;

// The gradient ProceduralSkyMaterial drew, with its colours: the fog and the
// distant horizon's haze copy sky_horizon_color (KNOWN_ISSUES.md).
uniform vec3 sky_top_color : source_color = vec3(0.235, 0.445, 0.785);
uniform vec3 sky_horizon_color : source_color = vec3(0.74, 0.80, 0.86);
uniform float sky_curve = 0.15;
uniform float sky_energy = 1.0;
uniform vec3 ground_bottom_color : source_color = vec3(0.40, 0.40, 0.37);
uniform vec3 ground_horizon_color : source_color = vec3(0.50, 0.68, 0.84);
uniform float ground_curve = 0.3;
uniform float ground_energy = 1.0;
// The land's colour as it lights surfaces from below (the radiance map only; the
// visible sky below the horizon keeps the two ground colours).
uniform vec3 land_bounce_color : source_color = vec3(0.68, 0.62, 0.50);
// The horizon toward a low sun.
uniform vec3 low_sun_horizon_color : source_color = vec3(1.0, 0.80, 0.60);

// The sun: its disc's radius (degrees, a little larger than the real 0.27) and
// brightness, in units of the sun light's colour times energy, and its halo.
uniform float sun_disc_deg = 0.42;
uniform float sun_disc_energy = 40.0;
uniform float sun_halo = 1.0;

// Cumulus.
uniform float cloud_cover : hint_range(0.0, 1.0) = 0.48;
uniform float cloud_base_m = 1100.0;
uniform float cloud_top_m = 2100.0;
// How much narrower a cloud gets with height: more gives flatter clouds.
uniform float cloud_dome = 0.3;
// How deeply the fine noise cuts into a cloud's edge.
uniform float cloud_billow : hint_range(0.0, 1.0) = 0.85;
// Extinction per metre at full density.
uniform float cloud_extinction = 0.022;
uniform float cloud_sun_gain = 0.62;
uniform float cloud_sky_gain = 0.8;
// Distance (m) over which a cloud fades into the haze by a factor e.
uniform float cloud_haze_m = 28000.0;
// How far each pixel's march steps are offset, as a share of a step: trades
// faint layering for grain.
uniform float march_jitter : hint_range(0.0, 1.0) = 0.0;
// Cirrus.
uniform float cirrus_cover : hint_range(0.0, 1.0) = 0.5;
uniform float cirrus_height_m = 9000.0;

const float PLANET_M = 6371000.0;
// cloud_noise's tile as the shape, the weather and the edge detail read it. The
// larger tiles are whole multiples of the smaller, and sky_weather.gd's wrap is
// the largest, so the drift wraps unseen.
const float SHAPE_TILE_M = 9000.0;
const float WEATHER_TILE_M = 24000.0;
const float DETAIL_TILE_M = 2250.0;
const float CIRRUS_TILE_M = 36000.0;

// Steps of the cloud march in the visible sky and in the radiance map.
const int MARCH_STEPS = 40;
const int REFLECTION_STEPS = 8;

#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
// The Compatibility renderer hands a sky shader its source_color uniforms and
// LIGHT0_COLOR still sRGB-encoded and decodes COLOR itself afterwards
// (drivers/gles3/shaders/sky.glsl), so the light sums here would run on encoded
// values and the clouds come out dark. Decode what comes in and encode what goes
// out, and both renderers light the sky alike.
vec3 scene_color(vec3 encoded) {
	return mix(pow((encoded + 0.055) / 1.055, vec3(2.4)), encoded / 12.92, lessThan(encoded, vec3(0.04045)));
}

vec3 sky_output(vec3 linear) {
	return mix(1.055 * pow(linear, vec3(1.0 / 2.4)) - 0.055, linear * 12.92, lessThan(linear, vec3(0.0031308)));
}
#else
vec3 scene_color(vec3 color) {
	return color;
}

vec3 sky_output(vec3 color) {
	return color;
}
#endif

// Distance along a ray from the ground, `mu` its sine of elevation, to the shell
// `height` metres up.
float shell_distance(float mu, float height) {
	float b = PLANET_M * mu;
	float c = 2.0 * PLANET_M * height + height * height;
	return c / (b + sqrt(b * b + c));
}

// Share of the sky a cumulus field covers over a ground position: 0 to 1.
float cloud_weather(vec2 xz) {
	float field = textureLod(cloud_noise, vec3(xz / WEATHER_TILE_M + vec2(0.31, 0.67), 0.37), 0.0).a;
	return clamp((field - 0.5) * 2.6 + cloud_cover, 0.0, 1.0);
}

// Cloud density, 0 to 1, at `p` (x and z in metres with the drift applied, y the
// height above the ground), `hf` its height within the slab and `cover` the
// weather there. `lump` is the fine noise there: high on a billow, low in the
// crevice between two.
float cloud_density(vec3 p, float hf, float cover, float lod, bool detail, vec3 drift, out float lump) {
	lump = 0.5;
	// Flat bases, and a ceiling.
	float slab = smoothstep(0.0, 0.07, hf) * (1.0 - smoothstep(0.85, 1.0, hf));
	if (cover * slab < 0.02) {
		return 0.0;
	}
	vec3 uvw = vec3(p.x / SHAPE_TILE_M, p.z / SHAPE_TILE_M, (p.y + drift.y) / (SHAPE_TILE_M * 0.5));
	float shape = textureLod(cloud_noise, uvw, lod).r;
	// The bar the noise must clear rises with height, so a cloud is widest at its
	// base and domes over where the noise is strongest; fuller weather lowers it.
	float bar = mix(0.82, 0.48, cover) + hf * cloud_dome;
	float d = clamp((shape - bar) / 0.16, 0.0, 1.0) * slab;
	if (detail && d > 0.0) {
		vec3 fine = vec3(p.x / DETAIL_TILE_M, p.z / DETAIL_TILE_M, (p.y - drift.y) / (DETAIL_TILE_M * 0.5));
		vec4 cells = textureLod(cloud_noise, fine, lod);
		// Billows a few hundred metres across and wisps under a hundred eat
		// into the cloud from its edge: least at the core.
		lump = cells.g * 0.55 + cells.b * 0.45;
		float erode = (1.0 - lump) * cloud_billow;
		d = clamp((d - erode) / (1.0 - erode), 0.0, 1.0);
	}
	return d;
}

float henyey_greenstein(float cos_angle, float g) {
	float g2 = g * g;
	return (1.0 - g2) / pow(1.0 + g2 - 2.0 * g * cos_angle, 1.5);
}

// Cloud density at distance `t` along `dir`, with the sample's drifted position,
// its height within the slab and the weather there.
float density_along(vec3 dir, float t, float lod, vec3 drift, out vec3 q, out float hf, out float cover, out float lump) {
	vec3 p = dir * t;
	// The earth curves away under a far sample.
	float height = p.y + dot(p.xz, p.xz) / (2.0 * PLANET_M);
	hf = (height - cloud_base_m) / (cloud_top_m - cloud_base_m);
	q = vec3(p.x - drift.x, height, p.z - drift.z);
	cover = cloud_weather(q.xz);
	return cloud_density(q, hf, cover, lod, true, drift, lump);
}

// The cumulus along `dir`: premultiplied colour and opacity.
vec4 march_clouds(vec3 dir, vec3 sun, vec3 sun_light, vec3 sky_light, vec3 drift, int steps, float jitter) {
	float mu = dir.y;
	if (mu < 0.012) {
		return vec4(0.0);
	}
	float near = shell_distance(mu, cloud_base_m);
	float far = shell_distance(mu, cloud_top_m);
	float dt = (far - near) / float(steps);
	float lod = clamp(log2(dt / 220.0), 0.0, 3.0);
	float thickness = cloud_top_m - cloud_base_m;
	float cos_sun = dot(dir, sun);
	// Forward scattering round the sun (the bright rim), a little back toward it.
	float phase = mix(henyey_greenstein(cos_sun, 0.55), henyey_greenstein(cos_sun, -0.25), 0.4);
	float transmittance = 1.0;
	vec3 color = vec3(0.0);
	float mean_distance = 0.0;
	// Steps are placed from where the ray enters a cloud, not on fixed shells, so
	// a cloud's face does not show the shells as terraces.
	float shift = 0.0;
	bool inside = false;
	int entries = 0;
	for (int i = 0; i < steps; i++) {
		float t = near + (float(i) + jitter) * dt + shift;
		if (t > far) {
			break;
		}
		vec3 q;
		float hf;
		float cover;
		float lump;
		float density = density_along(dir, t, lod, drift, q, hf, cover, lump);
		if (density <= 0.001) {
			inside = false;
			continue;
		}
		if (!inside && entries < 3) {
			inside = true;
			entries++;
			float outside = t - dt;
			float within = t;
			for (int k = 0; k < 4; k++) {
				float middle = 0.5 * (outside + within);
				if (density_along(dir, middle, lod, drift, q, hf, cover, lump) > 0.001) {
					within = middle;
				} else {
					outside = middle;
				}
			}
			float entered = within + 0.5 * dt;
			shift += entered - t;
			t = entered;
			density = density_along(dir, t, lod, drift, q, hf, cover, lump);
		}
		// Optical depth toward the sun: three taps, each standing for a longer stretch.
		float depth = 0.0;
		float reach = 0.0;
		for (int k = 0; k < 3; k++) {
			float stretch = 90.0 * exp2(float(k));
			vec3 s = q + sun * (reach + stretch * 0.5);
			float unused;
			// The nearest tap sees the billows, so they shade each other.
			depth += cloud_density(s, (s.y - cloud_base_m) / thickness, cover, lod + (k == 0 ? 0.0 : 1.0), k == 0, drift, unused) * stretch;
			reach += stretch;
		}
		depth *= cloud_extinction;
		// Direct sun, then light scattered deeper into the cloud, then the sky's
		// own light, stronger near the top.
		// Less of either reaches a crevice between billows.
		float crevice = smoothstep(0.25, 0.7, lump);
		vec3 light = sun_light * (exp(-depth) * phase + 0.55 * exp(-depth * 0.2)) * mix(0.72, 1.08, crevice) + sky_light * mix(0.5, 1.0, clamp(hf, 0.0, 1.0)) * mix(0.8, 1.05, crevice);
		float opacity = 1.0 - exp(-density * cloud_extinction * dt);
		color += transmittance * opacity * light;
		mean_distance += transmittance * opacity * t;
		transmittance *= 1.0 - opacity;
		if (transmittance < 0.02) {
			break;
		}
	}
	float alpha = 1.0 - transmittance;
	if (alpha < 0.001) {
		return vec4(0.0);
	}
	mean_distance /= alpha;
	// Into the haze with distance, and out before the horizon line.
	float keep = exp(-mean_distance / cloud_haze_m) * smoothstep(0.012, 0.06, mu);
	return vec4(color, alpha) * keep;
}

// High cirrus on one thin shell: opacity.
float cirrus(vec3 dir, vec3 drift) {
	float mu = dir.y;
	if (mu < 0.02) {
		return 0.0;
	}
	vec2 xz = dir.xz * shell_distance(mu, cirrus_height_m) - drift.xz * 2.0;
	vec2 uv = xz / CIRRUS_TILE_M;
	// Where the cirrus is, in broad patches.
	float field = texture(cloud_noise, vec3(uv + vec2(0.17, 0.43), 0.63)).a;
	// Fibres: the noise stretched along one bearing and bent a little.
	vec2 bend = (texture(cloud_noise, vec3(uv * 1.3, 0.11)).ga - 0.5) * 0.7;
	vec2 along = vec2(0.94, 0.34);
	vec2 fibre_uv = vec2(dot(uv, along) * 2.4, dot(uv, vec2(-along.y, along.x)) * 7.0) + bend;
	float fibre = texture(cloud_noise, vec3(fibre_uv, 0.29)).a * 0.55 + texture(cloud_noise, vec3(fibre_uv * 3.1 + vec2(0.4, 0.1), 0.71)).a * 0.45;
	float amount = smoothstep(0.62 - cirrus_cover * 0.2, 0.8, field) * smoothstep(0.45, 0.75, fibre);
	return amount * smoothstep(0.02, 0.2, mu);
}

// Interleaved gradient noise (Jimenez 2014): offsets each pixel's march steps.
float pixel_noise(vec2 pixel) {
	return fract(52.9829189 * fract(dot(pixel, vec2(0.06711056, 0.00583715))));
}

void sky() {
	vec3 dir = normalize(EYEDIR);
	vec3 sun = LIGHT0_ENABLED ? LIGHT0_DIRECTION : vec3(0.0, 1.0, 0.0);
	vec3 sun_color = LIGHT0_ENABLED ? scene_color(LIGHT0_COLOR) * LIGHT0_ENERGY : vec3(0.0);
	vec3 drift = AT_CUBEMAP_PASS ? reflection_cloud_drift : sky_cloud_drift;
	// 0 with the sun high, 1 as it nears the horizon.
	float low_sun = 1.0 - smoothstep(0.08, 0.5, sun.y);
	float toward_sun = dot(normalize(dir.xz + vec2(1e-5, 0.0)), normalize(sun.xz + vec2(1e-5, 0.0))) * 0.5 + 0.5;

	vec3 top = scene_color(sky_top_color) * mix(1.0, 0.78, low_sun);
	vec3 horizon = mix(scene_color(sky_horizon_color), scene_color(low_sun_horizon_color), low_sun * 0.7 * mix(0.3, 1.0, toward_sun * toward_sun));
	vec3 sky_light = mix(horizon, top, 0.4) * cloud_sky_gain;
	vec3 cloud_sun = sun_color * cloud_sun_gain;

#if CURRENT_RENDERER != RENDERER_COMPATIBILITY
	if (AT_HALF_RES_PASS) {
		vec4 clouds = march_clouds(dir, sun, cloud_sun, sky_light, drift, AT_CUBEMAP_PASS ? REFLECTION_STEPS : MARCH_STEPS, AT_CUBEMAP_PASS ? 0.5 : 0.5 + (pixel_noise(FRAGCOORD.xy) - 0.5) * march_jitter);
		COLOR = clouds.rgb;
		ALPHA = clouds.a;
	} else {
		vec4 clouds = HALF_RES_COLOR;
#else
	{
		vec4 clouds = march_clouds(dir, sun, cloud_sun, sky_light, drift, AT_CUBEMAP_PASS ? REFLECTION_STEPS : MARCH_STEPS, 0.5);
#endif
		float up = clamp(dir.y, 0.0, 1.0);
		vec3 color = mix(top, horizon, clamp(pow(1.0 - up, 1.0 / sky_curve), 0.0, 1.0)) * sky_energy;
		float cos_sun = dot(dir, sun);
		float angle = acos(clamp(cos_sun, -1.0, 1.0));
		// The halo: a tight glare, a wider aureole and a faint brightening of that
		// whole side of the sky.
		float halo = 0.9 * exp(-angle / radians(1.3)) + 0.16 * exp(-angle / radians(7.0)) + 0.05 * exp(-angle / radians(28.0));
		color += sun_color * halo * sun_halo;
		float streaks = cirrus(dir, drift);
		vec3 cirrus_light = sun_color * (0.5 + 0.35 * henyey_greenstein(cos_sun, 0.6)) + sky_light * 0.35;
		color = mix(color, cirrus_light, streaks * 0.22);
		if (!AT_CUBEMAP_PASS) {
			float disc = 1.0 - smoothstep(radians(sun_disc_deg) * 0.8, radians(sun_disc_deg), angle);
			color += sun_color * sun_disc_energy * disc * (1.0 - streaks * 0.5);
		}
		// Clouds hide the disc and its glare faster than they hide the sky.
		float through = 1.0 - clouds.a;
		color = color * through + clouds.rgb;
		vec3 ground = mix(scene_color(ground_bottom_color), scene_color(ground_horizon_color), clamp(pow(1.0 + clamp(dir.y, -1.0, 0.0), 1.0 / ground_curve), 0.0, 1.0));
		if (AT_CUBEMAP_PASS) {
			// What lights a surface from below is the land around it: its colour
			// under the live sun and sky, so shade under an eave is warm and
			// shade open to the sky is cool.
			vec3 bounce = scene_color(land_bounce_color) * (sun_color * max(sun.y, 0.0) + sky_light * 0.7);
			ground = mix(ground, bounce, smoothstep(0.0, -0.3, dir.y));
		}
		COLOR = sky_output(dir.y >= 0.0 ? color : ground * ground_energy);
	}
}
