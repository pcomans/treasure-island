shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// Shoreline riprap (tools/lib/shoreline-generation.mjs). One shader, two
// materials (game/scripts/world/shoreline_builder.gd), chosen by `surface`:
//   0  the underlay slope outside the outline. It shows only in the gaps of the
//      stone heap nearby, so it is dark there (voids); far away, beyond the
//      stones' visibility range, it stands in for the heap at far_brightness,
//      about the heap's average tone, so the band does not lighten where the
//      stones fade out;
//   1  the instanced stones (MultiMesh): the generated boulder skin on flat,
//      hard-edged quarry faces, tinted per stone by its instance colour
//      (COLOR.rgb), darker toward its lower part where neighbours meet it and
//      lighter on sun-facing tops. A stone may rest on any face, so its height
//      share comes from the world: the fragment's height above the stone's
//      centroid (its instance origin) against its size (the instance scale).
// (The band inside the outline is the land's own dry grass ground cover.)
// The generated textures are sampled triplanar in world space (no UVs); each
// stone offsets its sample by its own position so no two stones match. The
// warm riprap texture is graded to the mid-to-dark grey of the 2025 photos.
// The brightness of each texture also serves as a height for bump shading
// (screen-space gradient, from blurrier mips); it fades with distance and at
// grazing angles, where screen-space gradients would streak.
// Near the water plane every surface turns charcoal and glossy (the wet band of
// the dated photos), with green-brown algae at the waterline and darker under
// the water; the band's edge wanders so it does not read as a ruled line.
// Far away (beyond submerged_near_m) rock deeper than submerged_cut_m under the
// water is not drawn: through the translucent water plane it would only show
// as a smudge. Near by it stays, dark, as the wet foot of the pile.
// Colours are source_color uniforms so both renderers convert them the same way.

uniform int surface = 0;
uniform sampler2D riprap_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D boulder_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;

// One texture repeat in metres.
uniform float slope_tile_m = 4.2;
uniform float stone_tile_m = 1.7;
// Grading: saturation kept, then a brightness multiplier (linear light).
uniform float riprap_saturation = 0.3;
uniform float slope_brightness = 0.5;
uniform float stone_saturation = 0.85;
uniform float stone_brightness = 0.8;
// Underlay: dark voids within the stones' range, their average beyond it.
uniform float void_brightness = 0.45;
uniform float far_brightness = 0.75;
uniform float void_fade_start_m = 215.0;
uniform float void_fade_end_m = 290.0;
// Stones: darker toward their lower part (height share 0) where they meet the
// heap, lighter on sun-facing tops. stone_extent is a stone's typical vertical
// extent for size 1 (the longest side).
uniform float contact_dark = 0.4;
uniform float contact_height = 0.65;
uniform float top_bleach = 0.2;
uniform float stone_extent = 0.7;
// Bump.
uniform float bump_height_m = 0.035;
uniform float stone_bump_height_m = 0.02;
uniform float height_mip_bias = 2.5;
uniform float bump_fade_start_m = 18.0;
uniform float bump_fade_end_m = 70.0;
// Large-scale variation against visible tiling.
uniform float macro_tile_m = 17.0;
uniform float macro_strength = 0.28;
// Wet band.
uniform float water_y = -0.12;
uniform float wet_top_m = 1.05;
uniform float wet_soft_m = 0.22;
// sRGB multipliers: 0.4 darkens to about 13 % in linear light (charcoal,
// not black).
uniform vec3 wet_tint : source_color = vec3(0.4, 0.4, 0.38);
uniform float algae_top_m = 0.55;
uniform float algae_strength = 0.85;
uniform vec3 algae_tint : source_color = vec3(0.55, 0.68, 0.38);
uniform vec3 submerged_tint : source_color = vec3(0.42, 0.5, 0.45);
uniform float submerged_cut_m = 0.35;
uniform float submerged_near_m = 60.0;
uniform float dry_roughness = 0.88;
uniform float wet_roughness = 0.56;

varying vec3 world_position;
varying vec3 world_normal;
varying vec3 instance_origin;
varying float instance_scale;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	// Stones scale uniformly, so the model matrix keeps normals true.
	world_normal = normalize(mat3(MODEL_MATRIX) * NORMAL);
	instance_origin = MODEL_MATRIX[3].xyz;
	instance_scale = length(MODEL_MATRIX[0].xyz);
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

vec3 triplanar(sampler2D tex, vec3 p, vec3 n, float tile, float bias) {
	vec3 w = pow(abs(n), vec3(4.0));
	w /= max(w.x + w.y + w.z, 0.0001);
	vec3 x = texture(tex, p.zy / tile + vec2(0.13, 0.41), bias).rgb;
	vec3 y = texture(tex, p.xz / tile, bias).rgb;
	vec3 z = texture(tex, p.xy / tile + vec2(0.57, 0.29), bias).rgb;
	return x * w.x + y * w.y + z * w.z;
}

vec3 grade(vec3 color, float saturation, float brightness) {
	float luminance = dot(color, vec3(0.2126, 0.7152, 0.0722));
	return mix(vec3(luminance), color, saturation) * brightness;
}

void fragment() {
	if (world_position.y < water_y - submerged_cut_m && length(VERTEX) > submerged_near_m) {
		discard;
	}
	vec3 n = normalize(world_normal);
	float distance_m = length(VERTEX);
	bool stone = surface == 1;
	vec3 p = world_position;
	if (stone) {
		// Each stone samples its own part of the texture.
		p += vec3(hash12(instance_origin.xz), hash12(instance_origin.zx + 7.1), hash12(instance_origin.xz * 1.7 + 3.3)) * 37.0;
	}
	float tile = stone ? stone_tile_m : slope_tile_m;
	vec3 albedo;
	float height_sample;
	if (stone) {
		albedo = grade(triplanar(boulder_albedo, p, n, tile, 0.0), stone_saturation, stone_brightness);
		height_sample = dot(triplanar(boulder_albedo, p, n, tile, height_mip_bias), vec3(0.3333));
	} else {
		albedo = grade(triplanar(riprap_albedo, p, n, tile, 0.0), riprap_saturation, slope_brightness);
		height_sample = dot(triplanar(riprap_albedo, p, n, tile, height_mip_bias), vec3(0.3333));
	}
	// Bump from the blurred brightness: Mikkelsen's surface-gradient form in
	// view space, faded with distance and at grazing angles.
	vec3 view_normal = normalize(NORMAL);
	float facing = abs(dot(view_normal, normalize(-VERTEX)));
	float strength = stone ? stone_bump_height_m : bump_height_m;
	float relief = height_sample * strength * (1.0 - smoothstep(bump_fade_start_m, bump_fade_end_m, distance_m)) * smoothstep(0.12, 0.4, facing);
	vec3 dpdx = dFdx(VERTEX);
	vec3 dpdy = dFdy(VERTEX);
	vec3 r1 = cross(dpdy, view_normal);
	vec3 r2 = cross(view_normal, dpdx);
	float det = dot(dpdx, r1);
	if (abs(det) > 1e-10) {
		vec3 gradient = sign(det) * (dFdx(relief) * r1 + dFdy(relief) * r2);
		NORMAL = normalize(abs(det) * view_normal - gradient);
	}
	if (stone) {
		float share = clamp(0.5 + (world_position.y - instance_origin.y) / max(instance_scale * stone_extent, 0.01), 0.0, 1.0);
		albedo *= COLOR.rgb;
		albedo *= mix(contact_dark, 1.0, smoothstep(0.0, contact_height, share));
		albedo *= 1.0 + top_bleach * smoothstep(0.55, 1.0, share) * max(n.y, 0.0);
	} else {
		albedo *= mix(void_brightness, far_brightness, smoothstep(void_fade_start_m, void_fade_end_m, distance_m));
	}
	vec2 rotated = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8)) * world_position.xz;
	float macro = dot(texture(riprap_albedo, rotated / macro_tile_m + vec2(0.31, 0.57)).rgb, vec3(0.3333));
	albedo *= 1.0 + (macro - 0.2) * macro_strength * 2.5;
	float wander = value_noise(world_position.xz * 0.9) - 0.5;
	float height = world_position.y - water_y + wander * 0.3;
	float wet = 1.0 - smoothstep(wet_top_m - wet_soft_m, wet_top_m + wet_soft_m, height);
	float algae = (1.0 - smoothstep(algae_top_m - 0.15, algae_top_m + 0.15, height)) * smoothstep(-0.9, -0.2, height);
	float submerged = 1.0 - smoothstep(-0.25, 0.0, height);
	albedo = mix(albedo, albedo * wet_tint, wet);
	albedo = mix(albedo, albedo * algae_tint * 1.3, algae * algae_strength);
	albedo = mix(albedo, albedo * submerged_tint, submerged);
	ALBEDO = clamp(albedo, vec3(0.0), vec3(1.0));
	ROUGHNESS = mix(dry_roughness, wet_roughness, wet * (1.0 - submerged * 0.5));
	// Wet rock stays dark: little more sheen than dry rock, so it does not
	// lighten toward the sky's reflection at grazing angles.
	SPECULAR = mix(0.3, 0.34, wet);
	METALLIC = 0.0;
}
