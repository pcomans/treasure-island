shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

// Public-only painted cement stucco for Building 1's crescent, wings and
// pavilions. Existing CC0 Poly Haven plaster_grey_04 channels supply fine
// aggregate, pores and roughness breakup. Paint colour, physical span and the
// very low-contrast broad coating drift are reversible production inference;
// no shadow, dirt pattern or facade feature is baked into the surface.
uniform sampler2D surface_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D surface_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D surface_roughness : filter_linear_mipmap_anisotropic, repeat_enable;
// Fine linear detail (incised lines, the canopy fascia's rolls, dentils) as a
// greyscale multiplier over the paint, read with the mesh's UV; white where unset,
// so the plain stucco materials are unchanged. Mipmapped, it settles to the mean
// tone with distance instead of switching or shimmering.
uniform sampler2D detail_pattern : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 paint_color : source_color = vec4(0.845, 0.8, 0.665, 1.0);
uniform float tile_span_m = 2.6;
uniform float relief_strength = 0.12;
uniform float grain_variation = 0.2;
uniform float broad_variation = 0.1;
uniform float roughness_base = 0.84;
uniform float roughness_variation = 0.12;
// Matte paint's specular level (Godot's SPECULAR; its own default is 0.5): low, so
// small ledges seen edge-on do not mirror the sky as blue lines.
uniform float specular_level = 0.25;
// Fine relief kept to what the screen can show (the crescent piers' reeds). Its mesh
// carries in UV its flat face's normal as an angle about Y from +X (x, radians) and
// each point's place across the reeds (y, metres). Where a reed of relief_period_m
// spans fewer pixels across than relief_fade_px.y, down to relief_fade_px.x, its own
// normals give way to one broad wave per relief_coarse_period_m across the same reeds
// (tilting relief_coarse_tilt at most), and that wave in turn to the flat face: a
// calm stripe at every distance, no switch, no pop. A relief_period_m of 0 (the
// default) leaves normals alone.
uniform float relief_period_m = 0.0;
uniform float relief_coarse_period_m = 0.45;
uniform float relief_coarse_tilt = 0.45;
uniform vec2 relief_fade_px = vec2(3.0, 6.0);
// How much less of the sky the relief's hollows see (an occlusion deepening from each
// reed's crest to its grooves, and from the broad wave's crests to its troughs), half
// of it on direct light too, so the fluting reads in shade and in sun; 0 leaves it.
uniform float relief_cavity = 0.0;
// How much less of the sky a whole face sees that stands in a return or recess (the
// crescent piers' sides, the hollow behind the head bands' dentils), half of it on
// direct light too, as relief_cavity: a projection's edge then reads at play distances
// whatever the sun's direction, where its cast shadow is finer than the shadow map's
// texels. 0 (the default) leaves it.
uniform float face_occlusion = 0.0;
varying vec3 world_position;
varying vec3 world_normal;
varying vec3 face_normal;
varying float relief_across;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
	face_normal = MODEL_NORMAL_MATRIX * vec3(cos(UV.x), 0.0, sin(UV.x));
	relief_across = UV.y;
}

void fragment() {
	vec3 n = normalize(world_normal);
	if (face_occlusion > 0.0) {
		AO = 1.0 - face_occlusion;
		AO_LIGHT_AFFECT = 0.5;
	}
	if (relief_period_m > 0.0) {
		vec3 face = normalize(face_normal);
		vec3 across = vec3(-face.z, 0.0, face.x);
		float metres_per_pixel = max(fwidth(relief_across), 1e-5);
		float fine = smoothstep(relief_fade_px.x, relief_fade_px.y, relief_period_m / metres_per_pixel);
		float coarse = smoothstep(relief_fade_px.x, relief_fade_px.y, relief_coarse_period_m / metres_per_pixel);
		vec3 wave = normalize(face + across * (relief_coarse_tilt * sin(6.2831853 * relief_across / relief_coarse_period_m)));
		float hollow = fine * clamp((1.0 - dot(n, face)) / 0.36, 0.0, 1.0) + (1.0 - fine) * coarse * 0.6 * clamp((1.0 - dot(wave, face)) / 0.09, 0.0, 1.0);
		AO = (1.0 - face_occlusion) * (1.0 - relief_cavity * hollow);
		AO_LIGHT_AFFECT = 0.5;
		n = normalize(mix(mix(face, wave, coarse), n, fine));
	}
	// Face-aligned world-metre projection keeps one continuous phase across the
	// exact runs and applied modules, independent of their box UVs. V runs
	// downward so the OpenGL normal map's +Y stays world-up on walls.
	vec3 reference_axis = abs(n.y) > 0.8 ? vec3(1.0, 0.0, 0.0) : vec3(0.0, 1.0, 0.0);
	vec3 t = normalize(cross(reference_axis, n));
	vec3 b = normalize(cross(n, t));
	vec2 uv = vec2(dot(world_position, t), -dot(world_position, b)) / tile_span_m;
	float grain = dot(texture(surface_color, uv).rgb, vec3(0.2126, 0.7152, 0.0722));
	// Broad drift reads a heavily filtered, rotated copy over tens of metres.
	vec2 broad_uv = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8)) * uv * 0.083 + vec2(0.37, 0.61);
	float broad = dot(textureLod(surface_color, broad_uv, 7.0).rgb, vec3(0.2126, 0.7152, 0.0722));
	float variation = 1.0 + (grain - 0.27) * grain_variation + (broad - 0.27) * broad_variation * 6.0;
	ALBEDO = paint_color.rgb * clamp(variation, 0.86, 1.1) * texture(detail_pattern, UV).rgb;
	ROUGHNESS = clamp(roughness_base + (texture(surface_roughness, uv).r - 0.5) * roughness_variation, 0.45, 0.97);
	METALLIC = 0.0;
	SPECULAR = specular_level;
	vec3 detail = texture(surface_normal, uv).rgb * 2.0 - 1.0;
	vec3 perturbed = normalize(n + (t * detail.x + b * detail.y) * relief_strength);
	NORMAL = normalize((VIEW_MATRIX * vec4(perturbed, 0.0)).xyz);
}
