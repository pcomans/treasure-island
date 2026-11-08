extends Node3D
## Original cylindrical distant art; scale and interpolation are production inference.
## +X east, -Z north. Existing 3D Bay Bridges/YBI remain exclusive nearby owners.
const SECTORS := [
	preload("res://game/resources/textures/context/fresh_bay/sector_west.png"),
	preload("res://game/resources/textures/context/fresh_bay/sector_north.png"),
	preload("res://game/resources/textures/context/fresh_bay/sector_east.png"),
	preload("res://game/resources/textures/context/fresh_bay/sector_south.png"),
]
const SKYLINE := preload("res://game/resources/textures/context/fresh_bay/sf_skyline.png")
const RADIUS := 3500.0 # Historical angular authoring reference, not runtime depth.
const SECTOR_RADII := [14000.0, 14000.0, 14000.0, 6000.0]
const SECTOR_WIDTH_DEG := 94.0
# Uniform angular mapping; four-degree overlaps contain no landmark motifs.
# Visible Angel center estimated pixel1470/2172 -> geographic target309.5deg.
const WEST_START_DEG := 245.882136
const WATERLINES := [0.934, 0.902, 0.950, 0.941]
const WESTERN_BLOCKOUT := preload("res://game/scripts/world/western_background_blockout.gd")
const EASTERN_BLOCKOUT := preload("res://game/scripts/world/eastern_background_blockout.gd")
const SECTOR_SHADER := preload("res://game/resources/textures/context/fresh_bay/sector.gdshader")

func _ready() -> void:
	build_scenery()

func build_scenery() -> void:
	if get_child_count() > 0:
		return
	var band := Node3D.new()
	band.name = "Continuous360Horizon"
	add_child(band)
	for sector in range(4):
		var vertices := PackedVector3Array()
		var uvs := PackedVector2Array()
		var indices := PackedInt32Array()
		# Equal physical texel scale horizontally/vertically: no aspect warp.
		var radius: float = SECTOR_RADII[sector]
		for i in range(129):
			var u := float(i) / 128.0
			var bearing := deg_to_rad(WEST_START_DEG + sector * 90.0 + u * SECTOR_WIDTH_DEG)
			var column_radius := _sector_radius(sector, rad_to_deg(bearing))
			var height := column_radius * deg_to_rad(SECTOR_WIDTH_DEG) / 3.0
			var radial := Vector3(sin(bearing), 0.0, -cos(bearing)) * column_radius
			vertices.append(radial + Vector3.UP * height * WATERLINES[sector])
			vertices.append(radial + Vector3.UP * height * (WATERLINES[sector] - 1.0))
			uvs.append(Vector2(u, 0.0))
			uvs.append(Vector2(u, 1.0))
			if i < 128:
				var k := i * 2
				indices.append_array(PackedInt32Array([k, k + 1, k + 2, k + 2, k + 1, k + 3]))
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_TEX_UV] = uvs
		arrays[Mesh.ARRAY_INDEX] = indices
		var mesh := ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		var item := MeshInstance3D.new()
		item.name = "Sector%d" % sector
		item.mesh = mesh
		var material := ShaderMaterial.new()
		material.shader = SECTOR_SHADER
		# Real-depth cutouts share water/bridge depth; no forced-far horizon placement.
		material.render_priority = -11 if sector == 3 else -10
		material.set_shader_parameter("north_left_join", sector == 1)
		material.set_shader_parameter("south_right_backing", sector == 3)
		material.set_shader_parameter("western_blockout_cut", sector == 3)
		material.set_shader_parameter("eastern_blockout_cut", sector == 1 or sector == 2)
		material.set_shader_parameter("sector_start_deg", WEST_START_DEG + sector * 90.0)
		material.set_shader_parameter("art_waterline", WATERLINES[sector])
		material.set_shader_parameter("art", SECTORS[sector])
		material.set_shader_parameter("restore_bridge_cables", sector == 0)
		material.set_shader_parameter("atmosphere", 0.16)
		item.material_override = material
		item.layers = 1
		item.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		item.visible = sector != 0 # True-depth western owner replaces all old western motifs.
		band.add_child(item)
		if sector != 0:
			_mainland_backing(band, sector, radius)
	var western = WESTERN_BLOCKOUT.new()
	western.name = "MappedWesternBackground"
	add_child(western)
	western.build_scenery()
	var eastern = EASTERN_BLOCKOUT.new()
	eastern.name = "MappedEasternBackground"
	add_child(eastern)
	eastern.build_scenery()
	var city := MeshInstance3D.new()
	city.name = "SanFranciscoDepthCard"
	var quad := QuadMesh.new()
	# Native3:1 aspect retained. Content baseline around.90, tallest ~.53.
	quad.size = Vector2(3438.707776, 1146.235925)
	quad.material = _material(SKYLINE)
	city.mesh = quad
	var angle := deg_to_rad(221.631974001)
	city.position = Vector3(sin(angle) * 4500.0, 458.494370, -cos(angle) * 4500.0)
	city.rotation.y = -angle
	city.layers = 1
	city.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(city)

func _material(texture: Texture2D) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = preload("res://game/resources/textures/context/fresh_bay/city.gdshader")
	material.set_shader_parameter("art", texture)
	return material

func _sector_radius(sector: int, bearing_deg: float) -> float:
	# Inferred connector depth, not surveyed coast. The entire overlap shares
	# South's physical radius; matching origin angles alone failed from jetpack.
	if sector == 2:
		var bearing := fposmod(bearing_deg, 360.0)
		var t := smoothstep(135.0, fposmod(WEST_START_DEG + 270.0, 360.0), bearing)
		return lerpf(14000.0, 6000.0, t)
	return SECTOR_RADII[sector]

func _mainland_backing(parent: Node3D, sector: int, radius: float) -> void:
	# Inferred mainland continuation beyond the artwork coast; not mapped terrain.
	var vertices := PackedVector3Array()
	var indices := PackedInt32Array()
	for i in range(129):
		var angle := WEST_START_DEG + sector * 90.0 + float(i) / 128.0 * SECTOR_WIDTH_DEG
		var a := deg_to_rad(angle)
		var direction := Vector3(sin(a), 0.0, -cos(a))
		vertices.append(direction * _sector_radius(sector, angle))
		vertices.append(direction * 32000.0)
		if i < 128:
			var bearing := fposmod(angle + SECTOR_WIDTH_DEG / 256.0, 360.0)
			if (sector == 1 or sector == 2) and bearing >= 30.0 and bearing <= 135.0:
				continue
			if sector == 3 and bearing >= 232.0:
				continue
			var k := i * 2
			indices.append_array(PackedInt32Array([k,k+1,k+2,k+2,k+1,k+3]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var item := MeshInstance3D.new()
	item.name = "LegacyMainlandBacking%d" % sector
	item.mesh = mesh
	var material := ShaderMaterial.new()
	# Real mainland continues into the existing world's distance atmosphere.
	# Unlike foreground profile art, its far-clip edge must not disable fog.
	material.shader = preload("res://game/resources/textures/context/fresh_bay/mainland_ground.gdshader")
	material.set_shader_parameter("base_color", Color(0.40,0.48,0.50))
	item.material_override = material
	item.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	item.layers = 1
	parent.get_parent().add_child(item)
