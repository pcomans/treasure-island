shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

// Hiroshi Sugimoto's Point of Infinity on Yerba Buena Island: a pseudosphere whose base
// is glass-fibre-reinforced concrete (eight panels) and whose upper part, from
// steel_from_m up, is mirror-polished stainless steel to the tip (KQED 2023-06-09;
// Secret San Francisco 2023-04-12). The steel starts 6.0 m up, where the surface is
// 0.9 m across: inferred from the close photo of 2025-05-27 (tools/config/
// ybi-context.json). The mesh is the exact surface (tools/lib/ybi-context-generation.mjs)
// and the bed it stands in: UV.x carries the part and runs round the axis (0-1 the
// sculpture, 2-3 its white gravel, 4-5 the light concrete curb), UV.y is the height above
// the rim in metres.
//
// The sky is all this steel can mirror here, so a true mirror turns sky-coloured and
// vanishes against the sky behind it. From Treasure Island the dated photos show it as
// a satin mid-grey line darker than the sky, with a bright glint low on the steel, just
// above the cone (the 2025-05-27 profile: about sRGB 119,146,174 against 132,180,211).
// So the steel is a darker satin metal, with a glint along its sunlit edges (RIM,
// scaled by the light, so it follows a moving sun) strongest just above the cone. Its
// upper reach is far thinner than a pixel from Treasure Island, so the vertex shader
// holds the surface at least min_pixels wide on screen, narrowing in its last stretch
// to tip_pixels: a line that neither vanishes nor breaks into dashes at 1-1.5 km, and
// the true form up close.

// The axis's foot (world x, the rim's height, world z), set from the mesh at load.
uniform vec3 axis_base = vec3(0.0);
uniform float height_m = 21.03;
uniform float steel_from_m = 6.0;
uniform float min_pixels = 2.0;
uniform float tip_pixels = 1.4;
// Glass-fibre-reinforced concrete with a slight warm cast (the close photo).
uniform vec3 concrete_color : source_color = vec3(0.57, 0.525, 0.465);
uniform vec3 steel_color : source_color = vec3(0.62, 0.64, 0.67);
uniform float steel_metallic : hint_range(0.0, 1.0) = 0.55;
uniform float steel_roughness : hint_range(0.0, 1.0) = 0.3;
// The sunlit glint along its edges (scaled by the light, so it dims with the day), and
// its extra strength in the band just above the cone, glint_m high.
uniform float steel_rim : hint_range(0.0, 1.0) = 0.35;
uniform float glint_rim : hint_range(0.0, 1.0) = 0.65;
uniform float glint_m = 2.5;
uniform float panels = 8.0;
uniform vec3 gravel_color : source_color = vec3(0.8, 0.79, 0.75);
uniform vec3 curb_color : source_color = vec3(0.7, 0.68, 0.64);

void vertex() {
	vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 radial = world.xz - axis_base.xz;
	float r = length(radial);
	float h = world.y - axis_base.y;
	// A pixel's angle on this camera, then the radius that covers min_pixels at this distance.
	float pixel_angle = 2.0 / (PROJECTION_MATRIX[1][1] * VIEWPORT_SIZE.y);
	float distance_m = length(CAMERA_POSITION_WORLD - world);
	float tip_taper = clamp((height_m - h) / (0.2 * height_m), 0.0, 1.0);
	float r_min = 0.5 * mix(tip_pixels, min_pixels, sqrt(tip_taper)) * pixel_angle * distance_m;
	if (UV.x < 1.5 && r > 1e-6 && r < r_min && h > 0.05) {
		world.xz = axis_base.xz + radial * (r_min / r);
		VERTEX = (inverse(MODEL_MATRIX) * vec4(world, 1.0)).xyz;
	}
}

void fragment() {
	// Derivatives first, outside the branch on the part.
	float seam_x = UV.x * panels;
	float seam_w = max(fwidth(seam_x), 1e-4);
	float part = floor(UV.x * 0.5);
	if (part >= 1.0) {
		// The bed: white gravel, then the curb.
		ALBEDO = part >= 2.0 ? curb_color : gravel_color;
		METALLIC = 0.0;
		ROUGHNESS = 0.92;
		SPECULAR = 0.3;
	} else {
		float h = UV.y;
		float steel = smoothstep(steel_from_m - 0.04, steel_from_m + 0.04, h);
		// The base's eight panels meet in faint seams.
		float seam = (1.0 - smoothstep(0.0, 1.5 * seam_w, abs(fract(seam_x + 0.5) - 0.5))) * (1.0 - smoothstep(0.3, 0.8, seam_w));
		vec3 concrete = concrete_color * (1.0 - 0.25 * seam);
		ALBEDO = mix(concrete, steel_color, steel);
		METALLIC = steel * steel_metallic;
		ROUGHNESS = mix(0.85, steel_roughness, steel);
		SPECULAR = mix(0.3, 0.5, steel);
		float glint = 1.0 - smoothstep(0.0, glint_m, h - steel_from_m);
		RIM = steel * clamp(steel_rim + glint_rim * glint, 0.0, 1.0);
		RIM_TINT = 0.3;
	}
}
