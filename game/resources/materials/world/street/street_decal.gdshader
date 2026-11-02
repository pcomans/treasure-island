shader_type spatial;
// Asphalt wear (generated street-wear records): cracks, oil stains, patches,
// manholes and drains on flat quads draped a few millimetres over the road,
// alpha blended so their soft edges fade into it, with no depth writes. Each
// vertex is pulled a hair toward the camera so the quads never z-fight the
// surface under them, in either renderer. Road paint is opaque
// (street_paint.gdshader) and hides any wear under it.
render_mode blend_mix, depth_draw_never, cull_back, diffuse_burley, specular_schlick_ggx;

// UV.x's integer part is the atlas cell (street-ground-generation.mjs
// STREET_WEAR_CELLS), the fraction and UV.y the decal's local coordinates.
uniform sampler2D wear_atlas : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform vec2 atlas_cells = vec2(4.0, 2.0);
uniform float view_pull = 0.9995;

void vertex() {
	vec4 view_position = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	// Perspective: scaling along the view ray keeps the point on screen.
	// Orthographic: the rays are parallel, so only the depth moves.
	if (PROJECTION_MATRIX[3][3] == 0.0) {
		view_position.xyz *= view_pull;
	} else {
		view_position.z *= view_pull;
	}
	POSITION = PROJECTION_MATRIX * view_position;
}

void fragment() {
	float cell = floor(UV.x);
	vec2 local = vec2(fract(UV.x), UV.y);
	vec2 atlas_uv = (vec2(mod(cell, atlas_cells.x), floor(cell / atlas_cells.x)) + local) / atlas_cells;
	vec4 texel = texture(wear_atlas, atlas_uv);
	float alpha = texel.a;
	float rough = 0.55;
	if (cell < 3.5) {
		// Cracks and stains: soft, fading out before the cell edge.
		vec2 edge = min(local, vec2(1.0) - local);
		alpha *= smoothstep(0.0, 0.08, min(edge.x, edge.y)) * (cell < 1.5 ? 0.85 : 0.55);
		rough = cell < 1.5 ? 0.9 : 0.45;
	} else if (cell < 4.5) {
		// Patches: a slightly darker seal that feathers into the old asphalt.
		vec2 edge = min(local, vec2(1.0) - local);
		alpha *= smoothstep(0.0, 0.2, min(edge.x, edge.y)) * 0.6;
		rough = 0.9;
	}
	ALBEDO = texel.rgb;
	ALPHA = alpha;
	ROUGHNESS = rough;
	SPECULAR = 0.35;
}
