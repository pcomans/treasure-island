shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// Shoreline riprap (tools/lib/shoreline-generation.mjs): the riprap overlay on the
// land inside the island outline, the rock slope outside it and the instanced
// boulders share this material (game/scripts/world/shoreline_builder.gd).
//
// The generated riprap albedo is sampled triplanar in world space, so the slope,
// its end faces and every boulder need no UVs, and a second, rotated and larger
// sample modulates it so the 4 m repeat does not show along the shore. A
// boulder's MultiMesh instance colour (COLOR, white elsewhere) tints it grey,
// tan or brown; its alpha of 0.5 marks a boulder, which samples the texture
// at boulder_tile_m so one stone shows rock grain rather than smaller stones.
// The texture's brightness also serves as a height: stones bright, the voids
// between them dark. Its screen-space gradient tilts the shading normal (bump
// mapping without UVs or tangents), so stones stand out under the sun instead of
// reading as flat paving. The height is read from blurrier mip levels than the
// colour (height_mip_bias) so granite speckle does not sparkle, it is halved on
// the faceted boulders, and it fades out with distance.
// Near the water plane the rock turns darker and glossier (the wet band of the
// dated photos) with a little green-brown algae at the waterline; the band's
// edge wanders with a noise so it does not read as a ruled line.
// Colours are source_color uniforms so both renderers convert them the same way.

uniform sampler2D riprap_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
// One texture repeat in metres: the generated image shows five or six stones
// across, about 0.6-1.2 m each in the photos.
uniform float tile_m = 4.2;
uniform float boulder_tile_m = 9.0;
// Boulders read a little lighter than the slope behind them, as in the photos.
uniform float boulder_brightness = 1.22;
// Height of the brightness relief in metres (bump strength), and its fade.
uniform float bump_height_m = 0.05;
uniform float height_mip_bias = 2.5;
uniform float bump_fade_start_m = 25.0;
uniform float bump_fade_end_m = 90.0;
uniform float macro_tile_m = 13.7;
uniform float macro_strength = 0.35;
uniform float water_y = -0.12;
// The wet band reaches this far above the water, softened over wet_soft_m.
uniform float wet_top_m = 0.6;
uniform float wet_soft_m = 0.3;
// sRGB multipliers, so 0.66 darkens to about 40 % in linear light.
uniform vec3 wet_tint : source_color = vec3(0.66, 0.64, 0.6);
uniform float algae_top_m = 0.2;
uniform vec3 algae_tint : source_color = vec3(0.6, 0.64, 0.45);
// Underwater the stones darken further (the water plane is translucent).
uniform vec3 submerged_tint : source_color = vec3(0.4, 0.45, 0.42);
uniform float dry_roughness = 0.9;
uniform float wet_roughness = 0.42;

varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float value_noise(vec2 p) {
	vec2 cell = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	float a = hash12(cell);
	float b = hash12(cell + vec2(1.0, 0.0));
	float c = hash12(cell + vec2(0.0, 1.0));
	float d = hash12(cell + vec2(1.0, 1.0));
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

vec3 triplanar(vec3 p, vec3 n, float tile, float bias) {
	vec3 w = pow(abs(n), vec3(4.0));
	w /= max(w.x + w.y + w.z, 0.0001);
	vec3 x = texture(riprap_albedo, p.zy / tile + vec2(0.13, 0.41), bias).rgb;
	vec3 y = texture(riprap_albedo, p.xz / tile, bias).rgb;
	vec3 z = texture(riprap_albedo, p.xy / tile + vec2(0.57, 0.29), bias).rgb;
	return x * w.x + y * w.y + z * w.z;
}

void fragment() {
	vec3 n = normalize(world_normal);
	bool boulder = COLOR.a < 0.75;
	float tile = boulder ? boulder_tile_m : tile_m;
	vec3 albedo = triplanar(world_position, n, tile, 0.0);
	// Bump from the blurred brightness: Mikkelsen's surface-gradient form in view space.
	float height_sample = dot(triplanar(world_position, n, tile, height_mip_bias), vec3(0.3333));
	float relief = height_sample * bump_height_m * (boulder ? 0.5 : 1.0) * (1.0 - smoothstep(bump_fade_start_m, bump_fade_end_m, length(VERTEX)));
	vec3 view_normal = normalize(NORMAL);
	vec3 dpdx = dFdx(VERTEX);
	vec3 dpdy = dFdy(VERTEX);
	vec3 r1 = cross(dpdy, view_normal);
	vec3 r2 = cross(view_normal, dpdx);
	float det = dot(dpdx, r1);
	if (abs(det) > 1e-10) {
		vec3 gradient = sign(det) * (dFdx(relief) * r1 + dFdy(relief) * r2);
		NORMAL = normalize(abs(det) * view_normal - gradient);
	}
	if (boulder) {
		albedo *= boulder_brightness;
	}
	vec2 rotated = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8)) * world_position.xz;
	float macro = dot(texture(riprap_albedo, rotated / macro_tile_m + vec2(0.31, 0.57)).rgb, vec3(0.3333));
	albedo *= 1.0 + (macro - 0.45) * macro_strength * 2.0;
	albedo *= COLOR.rgb;
	float wander = value_noise(world_position.xz * 0.9) - 0.5;
	float height = world_position.y - water_y + wander * 0.3;
	float wet = 1.0 - smoothstep(wet_top_m - wet_soft_m, wet_top_m + wet_soft_m, height);
	float algae = (1.0 - smoothstep(algae_top_m - 0.15, algae_top_m + 0.15, height)) * smoothstep(-0.9, -0.2, height);
	float submerged = 1.0 - smoothstep(-0.25, 0.0, height);
	albedo = mix(albedo, albedo * wet_tint, wet);
	albedo = mix(albedo, albedo * algae_tint * 1.35, algae * 0.55);
	albedo = mix(albedo, albedo * submerged_tint, submerged);
	ALBEDO = clamp(albedo, vec3(0.0), vec3(1.0));
	ROUGHNESS = mix(dry_roughness, wet_roughness, wet * (1.0 - submerged * 0.5));
	SPECULAR = 0.35;
	METALLIC = 0.0;
}
