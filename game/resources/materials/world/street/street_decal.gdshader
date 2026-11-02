shader_type spatial;
// Street paint and asphalt wear (generated street-marking and street-wear
// records): flat quads draped a few millimetres over the road, alpha blended,
// with no depth writes. Each vertex is pulled a hair toward the camera along
// its view ray, so the quads never z-fight the surface under them at any
// distance in either renderer (Forward+ and the web's Compatibility renderer)
// and never shift on screen.
render_mode blend_mix, depth_draw_never, cull_back, diffuse_burley, specular_schlick_ggx;

// 0: road paint. UV.x's integer part is the paint kind (street-ground-generation.mjs
// STREET_PAINT_KINDS: 0 white, 1 yellow, 2 red lane, 3 green lane, 4 tactile pad,
// 5 STOP legend); a legend's fraction and UV.y are its local coordinates.
// 1: wear. UV.x's integer part is the atlas cell (STREET_WEAR_CELLS), the
// fraction and UV.y the decal's local coordinates.
uniform int mode = 0;
uniform sampler2D paint_wear : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D tactile : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D stop_legend : hint_default_black, filter_linear_mipmap_anisotropic, repeat_disable;
uniform sampler2D wear_atlas : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform vec2 atlas_cells = vec2(4.0, 2.0);
uniform float view_pull = 0.9995;
uniform float paint_tile_m = 1.7;
uniform float tactile_tile_m = 0.6;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec4 view_position = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	view_position.xyz *= view_pull;
	POSITION = PROJECTION_MATRIX * view_position;
}

void fragment() {
	float cell = floor(UV.x);
	vec2 local = vec2(fract(UV.x), UV.y);
	vec3 albedo = vec3(1.0);
	float alpha = 1.0;
	float rough = 0.75;
	if (mode == 0) {
		// Linear colours of the photographed paints: thermoplastic white and
		// yellow, the red transit lane and green bike-lane conflict paint.
		float wear = texture(paint_wear, world_position.xz / paint_tile_m).r;
		float strength = 0.95;
		if (cell < 0.5) {
			albedo = vec3(0.78, 0.78, 0.75);
		} else if (cell < 1.5) {
			albedo = vec3(0.80, 0.47, 0.04);
		} else if (cell < 2.5) {
			albedo = vec3(0.21, 0.028, 0.024);
			strength = 0.9;
			wear = mix(1.0, wear, 0.5);
		} else if (cell < 3.5) {
			albedo = vec3(0.06, 0.23, 0.085);
			strength = 0.9;
			wear = mix(1.0, wear, 0.5);
		} else if (cell < 4.5) {
			albedo = texture(tactile, world_position.xz / tactile_tile_m).rgb;
			wear = 1.0;
			strength = 1.0;
			rough = 0.6;
		} else {
			albedo = vec3(0.78, 0.78, 0.75);
			wear *= texture(stop_legend, local).r;
		}
		alpha = clamp(wear, 0.0, 1.0) * strength;
	} else {
		vec2 atlas_uv = (vec2(mod(cell, atlas_cells.x), floor(cell / atlas_cells.x)) + local) / atlas_cells;
		vec4 texel = texture(wear_atlas, atlas_uv);
		albedo = texel.rgb;
		alpha = texel.a;
		if (cell < 3.5) {
			// Cracks and stains: soft, fading out before the cell edge.
			vec2 edge = min(local, vec2(1.0) - local);
			alpha *= smoothstep(0.0, 0.08, min(edge.x, edge.y)) * (cell < 1.5 ? 0.85 : 0.55);
			rough = cell < 1.5 ? 0.9 : 0.45;
		} else {
			rough = cell < 4.5 ? 0.9 : 0.55;
		}
	}
	ALBEDO = albedo;
	ALPHA = alpha;
	ROUGHNESS = rough;
	SPECULAR = 0.35;
}
