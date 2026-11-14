class_name StandingWater
extends RefCounted
## Where the land's ground-cover shader draws shallow standing water, for what has
## to know it on the CPU (the player's footsteps, owner 2026-11-14: "there is
## shallow water in the ditch near Mersea").
##
## There is no water surface there. ground_cover.gdshader's marsh (the ditch
## beside the Mersea lot, any land record whose family switches marsh_amount on)
## paints water onto the land itself: a shallow arm in the floor's mapped low
## ground (marsh_map's blue), where the land lies low enough (marsh_floor_y) and
## noise leaves it ragged, with reeds standing through its edge. The player walks
## on that land's own collision, so its feet are in the water wherever the shader
## draws it. pool() is the shader's own water test, term for term, at a point on a
## land record's collision, read for a walker close by (its near noises at full
## strength, nothing faded for distance): the shader's uniforms and constants come
## from the land's own material and the shader's code, nothing is listed by place,
## and other land drawn with the same marsh gets the same answer. Should the
## shader's water term change, change pool() with it.

const GROUND_COVER := preload("res://game/scripts/world/ground_cover.gd")
## A footstep counts as in the water where the drawn pool is at least this.
const WET := 0.5
## The shader uniforms and constants the water term reads.
const UNIFORMS := ["marsh_amount", "marsh_axis", "marsh_radii", "marsh_floor_y", "cover_map_rect"]
const CONSTANTS := ["WATER_LEVEL", "WATER_RISE_PER_M", "WATER_POOL", "WATER_DRY"]

## The marsh's inputs by material (instance id): {} for a material that draws no
## marsh; else its uniforms, the shader's constants and the marsh map's region
## round the marsh (an Image) with the map pixel it starts at.
static var _by_material: Dictionary = {}
## The marsh map's regions read back so far, by texture and marsh (_map_region).
static var _regions: Dictionary = {}
## The shader's declared defaults and constants, read from its code once.
static var _shader_values: Dictionary = {}


## Reads the marsh map round each marsh the ground-cover families draw, under the
## loading screen (main.gd), so no footstep waits for a texture's read-back. The
## baked world's land has its own copies of the families' materials, which share
## the map and the marsh, so they find these regions too.
static func prepare() -> void:
	for family: String in GROUND_COVER.FAMILIES:
		if float((GROUND_COVER.FAMILIES[family] as Dictionary).get("marsh_amount", 0.0)) > 0.0:
			_read_marsh(GROUND_COVER.material(family))


## Whether a point on a land record's collision (collider: its body, whose parent
## is the record) lies in standing water the land's material draws.
static func covers(collider: Object, point: Vector3) -> bool:
	return pool(collider, point) >= WET


## The shader's pool at a point on a land record's collision: 0 dry, 1 open water.
static func pool(collider: Object, point: Vector3) -> float:
	var marsh := _marsh_of(collider)
	if marsh.is_empty():
		return 0.0
	var p := Vector2(point.x, point.z)
	var axis_line: Vector4 = marsh.marsh_axis
	var start := Vector2(axis_line.x, axis_line.y)
	var axis := Vector2(axis_line.z, axis_line.w) - start
	var from_start := p - start
	var off_axis := (from_start - axis * clampf(from_start.dot(axis) / axis.dot(axis), 0.0, 1.0)).length()
	var radii: Vector2 = marsh.marsh_radii
	if off_axis >= radii.y + 13.0:
		return 0.0
	var ground_y := point.y
	var reach := off_axis + 26.0 * (value_noise(p / 29.0 + Vector2(5.1, 77.7)) - 0.5)
	var region := (1.0 - smoothstep(radii.x, radii.y, reach)) * smoothstep(1.2, 1.6, ground_y) * float(marsh.marsh_amount)
	if region <= 0.0:
		return 0.0
	var n_mid := value_noise(p / 5.7 + Vector2(23.7, 11.1))
	var n_small := value_noise(p / 2.1 + Vector2(3.3, 47.9))
	var n_tiny := value_noise(p / 0.8 + Vector2(29.9, 13.3))
	var n_fine := value_noise(p / 0.37 + Vector2(37.3, 5.9))
	var low := _map_blue(marsh, p)
	var along := Vector2(0.643 * p.x + 0.766 * p.y, 0.643 * p.y - 0.766 * p.x)
	var water := 0.38 * value_noise(along / Vector2(15.0, 5.0) + Vector2(3.7, 19.1)) + 0.38 * value_noise(along / Vector2(5.5, 2.4) + Vector2(41.3, 7.9)) + 0.24 * n_small
	water -= float(marsh.WATER_LEVEL) + float(marsh.WATER_RISE_PER_M) * maxf(0.0, ground_y - float(marsh.marsh_floor_y))
	water += float(marsh.WATER_POOL) * low - float(marsh.WATER_DRY) * (1.0 - smoothstep(0.0, 0.2, low))
	water += 0.1 * (n_fine - 0.5) + 0.2 * (n_tiny - 0.5) + 0.24 * (n_small - 0.5) + 0.12 * (n_mid - 0.5)
	var reeds := smoothstep(0.42, 0.62, 0.5 * n_tiny + 0.5 * n_small)
	return smoothstep(0.0, 0.02, water) * (1.0 - reeds * (1.0 - smoothstep(0.05, 0.2, water))) * region


## The shader's hash12 and value_noise (ground_cover.gdshader).
static func hash12(p: Vector2) -> float:
	var p3 := Vector3(p.x, p.y, p.x) * 0.1031
	p3 = p3 - p3.floor()
	p3 += Vector3.ONE * p3.dot(Vector3(p3.y, p3.z, p3.x) + Vector3.ONE * 33.33)
	var h := (p3.x + p3.y) * p3.z
	return h - floorf(h)


static func value_noise(p: Vector2) -> float:
	var cell := p.floor()
	var f := p - cell
	var u := f * f * (Vector2(3.0, 3.0) - 2.0 * f)
	var a := hash12(cell)
	var b := hash12(cell + Vector2(1.0, 0.0))
	var c := hash12(cell + Vector2(0.0, 1.0))
	var d := hash12(cell + Vector2(1.0, 1.0))
	return lerpf(lerpf(a, b, u.x), lerpf(c, d, u.x), u.y)


## The marsh's inputs for a land record's collision body, or {} if its material
## draws none.
static func _marsh_of(collider: Object) -> Dictionary:
	var body := collider as Node
	var record := body.get_parent() if body != null else null
	if record == null or str(record.get_meta("feature_kind", "")) != "land_ground":
		return {}
	var mesh := record.get_node_or_null("Mesh") as MeshInstance3D
	if mesh == null or mesh.mesh == null:
		return {}
	for surface in mesh.mesh.get_surface_count():
		var material := mesh.get_active_material(surface) as ShaderMaterial
		if material == null:
			continue
		var key := material.get_instance_id()
		if not _by_material.has(key):
			_by_material[key] = _read_marsh(material)
		var marsh: Dictionary = _by_material[key]
		if not marsh.is_empty():
			return marsh
	return {}


## A ground-cover material's marsh inputs, or {} where it draws no marsh.
static func _read_marsh(material: ShaderMaterial) -> Dictionary:
	if material.shader != GROUND_COVER.SHADER:
		return {}
	var defaults := _shader_defaults(material.shader)
	var marsh := {}
	for name: String in UNIFORMS + CONSTANTS:
		var value: Variant = material.get_shader_parameter(name) if name in UNIFORMS else null
		marsh[name] = value if value != null else defaults.get(name)
		if marsh[name] == null:
			push_warning("StandingWater: the ground-cover shader has no %s; no standing water is known" % name)
			return {}
	if float(marsh.marsh_amount) <= 0.0:
		return {}
	var region := _map_region(material.get_shader_parameter("marsh_map") as Texture2D, marsh.marsh_axis, marsh.marsh_radii, marsh.cover_map_rect)
	if region.is_empty():
		return {}
	marsh.merge(region)
	return marsh


## The marsh map round a marsh: its axis and the furthest its noisy edge reaches
## (radii.y + 13 m), plus a texel; {map (an Image), map_from (its first texel in
## the whole map), map_size (the whole map's size)}, or {} without a map. Read back
## once per map and marsh.
static func _map_region(texture: Texture2D, axis: Vector4, radii: Vector2, rect: Vector4) -> Dictionary:
	if texture == null:
		return {}
	var key := "%d|%s|%s|%s" % [texture.get_instance_id(), axis, radii, rect]
	if _regions.has(key):
		return _regions[key]
	var image := texture.get_image()
	if image == null or image.is_empty():
		return {}
	if image.is_compressed():
		image.decompress()
	var size := Vector2(image.get_width(), image.get_height())
	var low := (Vector2(minf(axis.x, axis.z), minf(axis.y, axis.w)) - Vector2.ONE * (radii.y + 14.0) - Vector2(rect.x, rect.y)) * Vector2(rect.z, rect.w) * size
	var high := (Vector2(maxf(axis.x, axis.z), maxf(axis.y, axis.w)) + Vector2.ONE * (radii.y + 14.0) - Vector2(rect.x, rect.y)) * Vector2(rect.z, rect.w) * size
	var from := Vector2i(clampi(floori(low.x) - 1, 0, image.get_width() - 1), clampi(floori(low.y) - 1, 0, image.get_height() - 1))
	var to := Vector2i(clampi(ceili(high.x) + 1, 0, image.get_width() - 1), clampi(ceili(high.y) + 1, 0, image.get_height() - 1))
	var map := image.get_region(Rect2i(from, to - from + Vector2i.ONE))
	if map.has_mipmaps():
		map.clear_mipmaps()
	var region := {"map": map, "map_from": from, "map_size": size}
	_regions[key] = region
	return region


## The marsh map's blue at a world point, sampled as the shader's filter_linear
## (bilinear between texel centres, clamped at the edge).
static func _map_blue(marsh: Dictionary, p: Vector2) -> float:
	var rect: Vector4 = marsh.cover_map_rect
	var size: Vector2 = marsh.map_size
	var from: Vector2i = marsh.map_from
	var map: Image = marsh.map
	var texel := (p - Vector2(rect.x, rect.y)) * Vector2(rect.z, rect.w) * size - Vector2(0.5, 0.5) - Vector2(from)
	var base := texel.floor()
	var t := texel - base
	var x0 := clampi(int(base.x), 0, map.get_width() - 1)
	var y0 := clampi(int(base.y), 0, map.get_height() - 1)
	var x1 := clampi(int(base.x) + 1, 0, map.get_width() - 1)
	var y1 := clampi(int(base.y) + 1, 0, map.get_height() - 1)
	var top := lerpf(map.get_pixel(x0, y0).b, map.get_pixel(x1, y0).b, t.x)
	var bottom := lerpf(map.get_pixel(x0, y1).b, map.get_pixel(x1, y1).b, t.x)
	return lerpf(top, bottom, t.y)


## The shader's declared uniform defaults and constants that the water term
## reads, from its code.
static func _shader_defaults(shader: Shader) -> Dictionary:
	var key := shader.get_instance_id()
	if _shader_values.has(key):
		return _shader_values[key]
	var values := {}
	var code := shader.code
	var uniform := RegEx.create_from_string("uniform\\s+(?:float|vec2|vec4)\\s+(\\w+)\\s*(?::[^=;]*)?=\\s*([^;]+);")
	var constant := RegEx.create_from_string("const\\s+float\\s+(\\w+)\\s*=\\s*([^;]+);")
	for found: RegExMatch in uniform.search_all(code) + constant.search_all(code):
		var name := found.get_string(1)
		if name in UNIFORMS or name in CONSTANTS:
			values[name] = _glsl_value(found.get_string(2).strip_edges())
	_shader_values[key] = values
	return values


## A GLSL float, vec2 or vec4 literal as a float, Vector2 or Vector4 (null if not one).
static func _glsl_value(text: String) -> Variant:
	if text.is_valid_float():
		return text.to_float()
	var vector := RegEx.create_from_string("^vec([24])\\s*\\(([^)]*)\\)$").search(text)
	if vector == null:
		return null
	var parts := vector.get_string(2).split(",")
	var numbers: Array[float] = []
	for part: String in parts:
		if not part.strip_edges().is_valid_float():
			return null
		numbers.append(part.strip_edges().to_float())
	if vector.get_string(1) == "2" and numbers.size() == 2:
		return Vector2(numbers[0], numbers[1])
	if vector.get_string(1) == "4" and numbers.size() == 4:
		return Vector4(numbers[0], numbers[1], numbers[2], numbers[3])
	return null
