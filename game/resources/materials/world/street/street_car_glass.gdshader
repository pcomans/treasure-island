shader_type spatial;
// The see-through glass of a hero-level car (street_car_hero_kit.glb's
// car_<body>_hero_glass, drawn by game/scripts/world/street_clutter_kit.gd):
// tinted panes over the modelled cabin and clear or red lenses over the lamp
// bowls. Premultiplied alpha, so the sky's reflection keeps its full strength
// however clear the pane is: a pane is nearly clear face on and a mirror at
// grazing angles. Drawn after the opaque world without writing depth; a pane's
// back face is culled, so a window seen through the car is the far side's
// outside world, not a second tint.
// Parts (UV.x, (part + 0.5) / 32): glass 2 (front and front-door panes), grille
// 12 (the darker privacy panes behind the B pillar), trim 6 (the black frit
// band round a pane), head_lamp 8 (a clear lens), tail_lamp 9 (a red lens).
render_mode blend_premul_alpha, depth_draw_never, cull_back, diffuse_burley, specular_schlick_ggx, shadows_disabled;

varying flat int part;

void vertex() {
	part = clamp(int(UV.x * 32.0), 0, 31);
}

void fragment() {
	float facing = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	float fresnel = pow(1.0 - facing, 5.0);
	vec3 tint = vec3(0.012, 0.018, 0.017);
	float alpha = 0.42;
	float roughness = 0.02;
	float specular = 0.6;
	if (part == 12) {
		alpha = 0.8;
		tint = vec3(0.008, 0.01, 0.011);
	} else if (part == 6) {
		alpha = 1.0;
		tint = vec3(0.008);
		roughness = 0.1;
	} else if (part == 8) {
		alpha = 0.1;
		tint = vec3(0.3, 0.32, 0.34);
		specular = 0.7;
	} else if (part == 9) {
		alpha = 0.62;
		tint = vec3(0.42, 0.012, 0.012);
		specular = 0.7;
	}
	alpha = mix(alpha, 1.0, fresnel);
	// Premultiplied by hand (the tint by its alpha, the reflection left whole):
	// PREMUL_ALPHA_FACTOR does not compile in the Compatibility renderer.
	ALBEDO = tint * alpha;
	ROUGHNESS = roughness;
	METALLIC = 0.0;
	SPECULAR = specular;
	ALPHA = alpha;
}
