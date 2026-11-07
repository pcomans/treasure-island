// The dust a fast-drop landing kicks up (landing_poof.gd): soft, lumpy,
// camera-facing puffs from a CPUParticles3D, lit as thin dust rather than as
// cards: part of the sunlight scatters evenly through it, part falls on it as
// on a soft ball tipped towards the sky, its underside darker, so a puff keeps
// its volume on ground of its own colour, and part scatters forwards towards the
// camera when it looks towards the sun, so backlit dust glows. The sun's shadow
// on it is softened, as on a thin cloud; the sky's ambient light and the fog
// reach it as they reach the ground.
//
// Its colour is the ground's where the player landed. On Forward+ the grass's
// ground captures (ground_dressing.gd) hold the colour of the open ground round
// the camera, and the dust takes that colour paler and greyer, averaged over a
// metre round the landing. The captures mask paving, roofs, stairs and the feet
// of props, which give a light grey. Without a capture there (the web's
// Compatibility renderer, or outside its window) the dust keeps its own light
// dusty neutral.
//
// The quad stays upright (its pivot sits at the bottom of the drawn blob, on
// the drawn ground) and only its lumps turn with the particle. Per particle,
// from CPUParticles3D: INSTANCE_CUSTOM.x is its angle (turns and seeds the
// lumps), INSTANCE_CUSTOM.y its age (0..1), over which its edge draws in and
// frays; COLOR.a fades it in and out (the emitter's colour ramp). Works in
// Forward+ and Compatibility: no screen or depth textures.
shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_disabled;

// ground_surface, ground_colour, ground_window, ground_uv(), in_window(), ground_tone().
#include "res://game/resources/materials/world/ground_cover/ground_dressing_common.gdshaderinc"

// The dust's own colour, without a capture, and its colour on paving and roofs.
uniform vec3 tint : source_color = vec3(0.76, 0.72, 0.65);
uniform vec3 paved_tint : source_color = vec3(0.71, 0.71, 0.69);
// Whether this landing has the captures, and where it was (world x, z).
uniform bool ground_capture = false;
uniform vec2 landing_xz = vec2(0.0);
// From the ground's colour to its dust: the share of colour it keeps, and how far
// it pales towards white, on the darkest ground and on the lightest.
uniform float dust_saturation = 0.7;
uniform vec2 dust_pale = vec2(0.4, 0.1);
// 0 draws nothing: the start-up burst that compiles this shader early.
uniform float strength = 1.0;
// Height over width of the puff's body: below 1 it is wider than tall.
uniform float squash = 0.75;
// Shares of the direct light: scattered evenly, falling on the ball, and
// scattered forwards (at its strongest looking straight into the light).
uniform float even_light = 0.25;
uniform float ball_light = 0.75;
uniform float forward_light = 1.1;
// How much of a directional light's shadow the thin dust keeps.
uniform float shadow_kept = 0.55;

varying vec2 spin;
varying float age;
varying float seed;
varying vec3 dust;

float hash(vec2 p) {
	p = fract(p * vec2(0.1031, 0.1030));
	p += dot(p, p.yx + 33.33);
	return fract((p.x + p.y) * p.x);
}

// Smooth value noise, 0..1.
float lumps(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// The dust of ground of this (linear) colour: greyer and paler, more so on dark ground.
vec3 dust_of(vec3 ground) {
	vec3 shown = pow(max(ground, vec3(0.0)), vec3(1.0 / 2.2));
	float luma = dot(shown, vec3(0.299, 0.587, 0.114));
	vec3 grey = mix(vec3(luma), shown, dust_saturation);
	return pow(mix(grey, vec3(1.0), mix(dust_pale.x, dust_pale.y, luma)), vec3(2.2));
}

// The dust's colour at the landing: the open ground's within half a metre round
// it, paving's where it is masked, or the dust's own outside a capture.
vec3 landing_dust() {
	vec2 uv = ground_uv(landing_xz);
	if (!ground_capture || in_window(uv) < 0.5) {
		return tint;
	}
	vec3 ground = vec3(0.0);
	float weight = 0.0;
	for (int i = 0; i < 5; i++) {
		float turn = float(i) * 1.5707963;
		vec2 tap = ground_uv(landing_xz + (i == 0 ? vec2(0.0) : 0.5 * vec2(cos(turn), sin(turn))));
		float open = in_window(tap) * smoothstep(0.35, 0.75, textureLod(ground_surface, tap, 0.0).a) * step(0.02, textureLod(ground_colour, tap, 0.0).a);
		ground += open * ground_tone(tap);
		weight += open;
	}
	float open_here = smoothstep(0.35, 0.75, textureLod(ground_surface, uv, 0.0).a);
	return weight > 0.0 ? mix(paved_tint, dust_of(ground / weight), open_here) : paved_tint;
}

void vertex() {
	// Face the camera, keeping the particle's scale.
	mat4 facing = mat4(normalize(INV_VIEW_MATRIX[0]), normalize(INV_VIEW_MATRIX[1]), normalize(INV_VIEW_MATRIX[2]), MODEL_MATRIX[3]);
	facing = facing * mat4(
			vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
			vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
			vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_MATRIX = VIEW_MATRIX * facing;
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	spin = vec2(cos(INSTANCE_CUSTOM.x), sin(INSTANCE_CUSTOM.x));
	age = INSTANCE_CUSTOM.y;
	seed = fract(INSTANCE_CUSTOM.x * 0.15915494) * 61.0;
	dust = landing_dust();
}

void fragment() {
	// -1..1 across the quad (y down); e is the body's frame, wider than tall.
	vec2 c = UV * 2.0 - 1.0;
	vec2 e = vec2(c.x, c.y / squash);
	float r = length(e);
	vec2 turned = vec2(c.x * spin.x - c.y * spin.y, c.x * spin.y + c.y * spin.x);
	float lump = lumps(turned * 1.8 + seed) * 0.65 + lumps(turned * 3.9 - seed) * 0.35;
	// A soft, full body whose edge frays with the lumps; with age the edge draws
	// in and frays more, so the puff thins out from the outside.
	float edge = 0.8 - 0.22 * age;
	float density = 1.0 - smoothstep(edge * 0.3, edge, r + (lump - 0.5) * (0.45 + 0.5 * age));
	density *= 1.0 - smoothstep(0.85, 1.0, max(abs(c.x), abs(c.y)));
	// The ball, tipped towards the sky; its underside darker, in any light.
	vec3 ball = normalize(vec3(e.x, -e.y, sqrt(max(1.0 - r * r, 0.0)) + 0.15));
	vec3 sky = (VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz;
	NORMAL = normalize(mix(ball, sky, 0.3));
	ALBEDO = dust * COLOR.rgb * mix(1.0, 0.72, smoothstep(-0.3, 0.75, e.y));
	ALPHA = clamp(density * COLOR.a * strength, 0.0, 1.0);
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;
}

void light() {
	float shadow = LIGHT_IS_DIRECTIONAL ? mix(1.0, ATTENUATION, shadow_kept) : ATTENUATION;
	float ball = clamp((dot(NORMAL, LIGHT) + 0.6) / 1.6, 0.0, 1.0);
	float forward = pow(clamp(dot(LIGHT, -VIEW), 0.0, 1.0), 2.0);
	DIFFUSE_LIGHT += LIGHT_COLOR * shadow * (even_light + ball_light * ball + forward_light * forward) / PI;
}
