shader_type spatial;
// Grass blades round the camera (game/scripts/world/ground_dressing.gd). The
// MultiMesh instances only carry a place in a repeating tile and a rank (its y).
// Everything else comes from the ground's capture here, where a tuft stands
// on the drawn ground, how thick and tall it grows, its colour, so there are no
// stored plants and nothing to go stale when the ground changes.
//
// The mesh (tuft_mesh()) is one tuft at unit height, its blades' centre lines in
// VERTEX, UV.x a blade's half width (signed) and UV.y its length so far, UV2 a blade's
// root in the unit disc, COLOR its side direction (rg), a random number (b) and its
// place in the tuft (a).
//
// Tufts thin out with distance by rank, shrinking away before they go, so nothing
// pops: only the first share() of them stand at a distance, and those grow
// wider so the grass keeps its coverage. Past the ring the ground's own texture carries
// the look: the blades' colour is that ground's, their normals lean to straight up with
// distance, and their ends sink into it.
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

#include "res://game/resources/materials/world/vegetation/vegetation_wind.gdshaderinc"

// Surface capture: height, tuft thickness, tuft height (stones where negative), alpha
// open ground.
uniform sampler2D ground_surface : filter_linear, repeat_disable;
// Colour capture: the ground's albedo, alpha where there is ground.
uniform sampler2D ground_colour : filter_linear, repeat_disable;
// The window both captures cover: its corner in world x, z and one over its size.
uniform vec3 ground_window = vec3(-128.0, -128.0, 0.00390625);

// Tile size and tufts per tile at full density (ground_dressing.gd).
uniform float tile_m = 4.0;
uniform float tile_tufts = 2560.0;
// Full density stands out to this distance; past it density falls as distance squared.
uniform float full_density_m = 6.0;
// A little over 1, so the last tufts in rank reach full height before they thin.
uniform float share_margin = 1.3;
uniform float ring_end_m = 104.0;
// The ground's typical height, for distances the CPU can match without the capture.
uniform float ground_y_m = 4.0;
// How far a tuft of a given height carries before it is under a pixel tall.
uniform float reach_per_m = 420.0;
uniform float tuft_radius_m = 0.09;
uniform float blade_width_m = 0.0075;
uniform float width_scale = 1.0;
// How far the blades' feet sink below the drawn ground.
uniform float sink_m = 0.015;
// The last third of a tuft's blades go between these distances (the far mesh hasn't
// them), and the rest grow wider to make up for it.
uniform vec2 blade_thin_m = vec2(20.0, 28.0);
uniform float sway = 0.16;
// The player: x, y, z, and the radius blades bend away within.
uniform vec4 bend_centre = vec4(0.0, -1000.0, 0.0, 1.1);
// Shade along a blade, root to tip, and how much blades differ from each other.
uniform float root_shade = 0.7;
uniform float tip_shade = 1.15;
uniform float blade_contrast = 0.45;
// On pale ground (sand, graded fill) tufts are dead grass, not the ground's colour.
uniform vec3 dead_grass : source_color = vec3(0.59, 0.51, 0.35);
// How far normals lean to straight up: at the blades' nearest, and past detail_end_m.
uniform float normal_up_near = 0.6;
uniform vec2 detail_m = vec2(14.0, 50.0);
uniform float roughness = 0.75;
uniform float specular = 0.25;
uniform float translucency = 0.3;

varying vec3 tint;
#ifdef GROUND_DRESSING_CARDS
// The fallback's alpha-scissor cards (card_mesh(), card_texture()): the same tufts,
// each a few crossed cards instead of blades. Red is a blade's shade.
uniform sampler2D card_texture : filter_linear_mipmap, repeat_disable;
varying vec2 card_uv;
#endif

vec3 hash32(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
	p3 += dot(p3, p3.yxz + 33.33);
	return fract((p3.xxy + p3.yzz) * p3.zyx);
}

void vertex() {
	vec3 place = MODEL_MATRIX[3].xyz;
	float rank = place.y;
	vec2 cell = place.xz;
	float dist = length(vec3(cell.x - CAMERA_POSITION_WORLD.x, ground_y_m - CAMERA_POSITION_WORLD.y, cell.y - CAMERA_POSITION_WORLD.z));
	float ratio = full_density_m / max(dist, full_density_m);
	float share = share_margin * ratio * ratio;
	vec3 out_vertex = vec3(0.0);
	vec3 out_normal = vec3(0.0, 1.0, 0.0);
	tint = vec3(0.0);
#ifdef GROUND_DRESSING_CARDS
	card_uv = vec2(sign(UV.x) * 0.5 + 0.5, 1.0 - UV.y);
#endif
	if (rank < share && dist < ring_end_m) {
		vec3 h = hash32(cell * 7.31);
		// Spacing of the tufts of this rank: a far tuft moves further, so the tile's
		// pattern never shows.
		vec2 tuft = cell + (h.xy - 0.5) * (1.3 * tile_m) * inversesqrt(rank * tile_tufts + 1.0);
		float yaw = h.z * TAU;
		float cy = cos(yaw);
		float sy = sin(yaw);
		vec2 root = tuft + vec2(cy * UV2.x - sy * UV2.y, sy * UV2.x + cy * UV2.y) * tuft_radius_m;
		vec2 map_uv = (root - ground_window.xy) * ground_window.z;
		vec4 surface = textureLod(ground_surface, map_uv, 0.0);
		float inside = step(0.002, min(map_uv.x, map_uv.y)) * step(max(map_uv.x, map_uv.y), 0.998);
		float thick = surface.g * smoothstep(0.35, 0.75, surface.a) * inside;
		float tall = max(surface.b, 0.0);
		float kept = min(share, share_margin * thick);
		float stand = clamp((kept - rank) / (0.3 * kept + 0.0001), 0.0, 1.0);
		float reach = min(ring_end_m, reach_per_m * tall);
		float thin_out = smoothstep(blade_thin_m.x, blade_thin_m.y, dist);
		float blade_stays = 1.0 - thin_out * step(0.62, COLOR.a);
		float wild = smoothstep(0.1, 0.18, tall);
		// The tuft's last blade is a long stem, which mown grass hasn't got.
		float stem = mix(1.0 - 0.35 * step(0.85, COLOR.a), 1.0, wild);
		float height = tall * stem * stand * blade_stays * (1.0 - smoothstep(0.7 * reach, reach, dist)) * (0.8 + 0.4 * h.x);
		if (height > 0.003) {
			float t = UV.y;
			vec3 shape = VERTEX;
			vec2 side = COLOR.rg * 2.0 - 1.0;
			vec3 lean = vec3(cy * shape.x - sy * shape.z, shape.y, sy * shape.x + cy * shape.z);
			float width = blade_width_m * width_scale * (1.0 + 0.5 * thin_out) / ratio;
			vec3 blade = vec3(root.x, surface.r - sink_m, root.y) + lean * height
				+ vec3(cy * side.x - sy * side.y, 0.0, sy * side.x + cy * side.y) * (UV.x * width);
			blade += vegetation_wind(blade, vec3(0.0, 1.0, 0.0), vec2(sway * height * t * t, 0.0), MODEL_MATRIX, TIME);
			// Blades lean away from the player and lie down under its feet.
			vec2 away = root - bend_centre.xz;
			float from_player = length(away);
			float press = (1.0 - smoothstep(0.35 * bend_centre.w, bend_centre.w, from_player)) * (1.0 - smoothstep(0.6, 1.6, abs(surface.r - bend_centre.y)));
			blade.xz += away / max(from_player, 0.05) * (press * 0.9 * height * t);
			blade.y -= press * 0.55 * height * t;
			out_vertex = blade - place;

			float detail = 1.0 - smoothstep(detail_m.x, detail_m.y, dist);
			vec3 facing = vec3(cy * NORMAL.x - sy * NORMAL.z, NORMAL.y, sy * NORMAL.x + cy * NORMAL.z);
			out_normal = normalize(mix(facing, vec3(0.0, 1.0, 0.0), mix(1.0, normal_up_near, detail)));

			vec4 ground = textureLod(ground_colour, map_uv, 0.0);
			float one_blade = fract(COLOR.b + 3.7 * h.x);
			float along = mix(root_shade, tip_shade, pow(t, 0.7));
			vec3 colour = ground.rgb / max(ground.a, 0.02);
			colour = mix(colour, dead_grass, 0.8 * smoothstep(0.22, 0.4, dot(colour, vec3(0.2126, 0.7152, 0.0722))));
			tint = colour * mix(1.0, along, 0.35 + 0.65 * detail) * (1.0 + (one_blade - 0.5) * blade_contrast * detail);
		}
	}
	VERTEX = out_vertex;
	NORMAL = out_normal;
}

void fragment() {
	ALBEDO = tint;
#ifdef GROUND_DRESSING_CARDS
	vec4 card = texture(card_texture, card_uv);
	ALBEDO *= 1.25 * card.r;
	ALPHA = card.a;
	ALPHA_SCISSOR_THRESHOLD = 0.4;
#endif
	ROUGHNESS = roughness;
	SPECULAR = specular;
	// The renderer flips NORMAL on back faces of double-sided materials; a blade is
	// lit the same on both sides.
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
	BACKLIGHT = tint * translucency;
}
