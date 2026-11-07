// The dust a fast-drop landing kicks up (landing_poof.gd): soft, lumpy,
// camera-facing puffs from a CPUParticles3D, lit as thin dust rather than as
// cards: part of the sunlight scatters evenly through it, part falls on it as
// on a soft ball tipped towards the sky (so a puff keeps its volume on ground
// of its own colour, such as pale sand), and part scatters forwards towards the
// camera when it looks towards the sun, so backlit dust glows. The sun's shadow
// on it is softened, as on a thin cloud; the sky's ambient light and the fog
// reach it as they reach the ground. The quad stays upright (its pivot sits at
// the bottom of the drawn blob, on the drawn ground) and only its lumps turn
// with the particle. Per particle, from CPUParticles3D: INSTANCE_CUSTOM.x is its
// angle (turns and seeds the lumps), INSTANCE_CUSTOM.y its age (0..1), over
// which its edge draws in and frays; COLOR.a fades it in and out (the
// emitter's colour ramp). Works in Forward+ and Compatibility: no screen or
// depth textures.
shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_disabled;

uniform vec3 tint : source_color = vec3(0.76, 0.72, 0.65);
// Height over width of the puff's body: below 1 it is wider than tall.
uniform float squash = 0.75;
// Shares of the direct light: scattered evenly, falling on the ball, and
// scattered forwards (at its strongest looking straight into the light).
uniform float even_light = 0.3;
uniform float ball_light = 0.7;
uniform float forward_light = 1.4;
// How much of a directional light's shadow the thin dust keeps.
uniform float shadow_kept = 0.7;

varying vec2 spin;
varying float age;
varying float seed;

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
	// The ball, tipped towards the sky; its underside a little darker.
	vec3 ball = normalize(vec3(e.x, -e.y, sqrt(max(1.0 - r * r, 0.0)) + 0.15));
	vec3 sky = (VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz;
	NORMAL = normalize(mix(ball, sky, 0.3));
	ALBEDO = tint * COLOR.rgb * mix(1.0, 0.86, smoothstep(-0.4, 0.7, e.y));
	ALPHA = clamp(density * COLOR.a, 0.0, 1.0);
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;
}

void light() {
	float shadow = LIGHT_IS_DIRECTIONAL ? mix(1.0, ATTENUATION, shadow_kept) : ATTENUATION;
	float ball = clamp((dot(NORMAL, LIGHT) + 0.6) / 1.6, 0.0, 1.0);
	float forward = pow(clamp(dot(LIGHT, -VIEW), 0.0, 1.0), 1.5);
	DIFFUSE_LIGHT += LIGHT_COLOR * shadow * (even_light + ball_light * ball + forward_light * forward) / PI;
}
