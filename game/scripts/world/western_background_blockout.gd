extends Node3D
## L1 non-playable geographic proxy. No final art or terrain-survey claim.
## Map identities, datum limits and inferred profile heights live with the data.
const DATA_PATH := "res://game/resources/context/western_blockout.json"
var registration: Dictionary
var ground_triangles: Array[Vector3] = []

func build_scenery() -> void:
	if get_child_count() > 0:
		return
	registration = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	for region: Dictionary in registration.profiles:
		_profile(region)
	for island: Dictionary in registration.islands:
		_island(island)
	_prison_mass(registration.alcatraz_building)
	_bridge(registration.ggb)

func _material(color: Color, region_name: String = "") -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://game/resources/textures/context/fresh_bay/land.gdshader")
	mat.set_shader_parameter("base_color", color)
	mat.set_shader_parameter("landcover_art", preload("res://game/resources/textures/context/fresh_bay/sector_north.png"))
	# Photo-supported cover families; no mapped individual vegetation claim.
	var cover := {"SFNorthShoreProxy": [0.75, 320.0, 3.0], "MarinMiddleProxy": [1.0, 560.0, 11.0], "FarRidgeProxy": [0.45, 900.0, 21.0], "AngelMappedIsland": [0.85, 270.0, 7.0], "AlcatrazMappedIsland": [0.15, 120.0, 4.0], "EastSetbackHills": [0.6, 720.0, 31.0]}
	if cover.has(region_name):
		var parameters: Array = cover[region_name]
		mat.set_shader_parameter("cover_strength", parameters[0])
		mat.set_shader_parameter("cover_scale", parameters[1])
		mat.set_shader_parameter("cover_seed", parameters[2])
	return mat

func _mesh(name_value: String, vertices: PackedVector3Array, indices: PackedInt32Array, color: Color) -> void:
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var item := MeshInstance3D.new()
	item.name = name_value
	item.mesh = mesh
	item.material_override = _material(color, name_value)
	item.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	item.layers = 1
	add_child(item)

func _profile(region: Dictionary) -> void:
	var vertices := PackedVector3Array()
	var indices := PackedInt32Array()
	for point_index in range(region.points.size()):
		var point: Array = region.points[point_index]
		vertices.append(Vector3(point[0], point[1], point[2]))
		var shore: Array = region.base_points[point_index] if region.has("base_points") else [point[0], -2.0, point[2]]
		vertices.append(Vector3(shore[0], shore[1], shore[2]))
	for i in range(region.points.size() - 1):
		var k := i * 2
		indices.append_array(PackedInt32Array([k, k + 1, k + 2, k + 2, k + 1, k + 3]))
	# Continue land behind the ridge beyond the visible far plane: no floating ribbon.
	var count: int = region.points.size()
	for point: Array in region.points:
		var top := Vector3(point[0], point[1], point[2])
		var direction := Vector3(top.x, 0.0, top.z).normalized()
		vertices.append(direction * 32000.0 + Vector3.UP * top.y)
	for i in range(count - 1):
		var a := i * 2
		var b := (i + 1) * 2
		var c := count * 2 + i
		indices.append_array(PackedInt32Array([a,c,b,b,c,c+1]))
	var nondegenerate := PackedInt32Array()
	for i in range(0, indices.size(), 3):
		var a: Vector3 = vertices[indices[i]]
		var b: Vector3 = vertices[indices[i+1]]
		var c: Vector3 = vertices[indices[i+2]]
		if (b-a).cross(c-a).length_squared() > 0.000001:
			nondegenerate.append_array(PackedInt32Array([indices[i],indices[i+1],indices[i+2]]))
	indices = nondegenerate
	for index: int in indices:
		ground_triangles.append(vertices[index])
	var c: Array = region.color
	_mesh(region.name, vertices, indices, Color(c[0], c[1], c[2]))

func _island(island: Dictionary) -> void:
	var coast: Array = island.coast_xz
	var peak := Vector3(island.peak_xz[0], island.peak_height, island.peak_xz[1])
	var vertices := PackedVector3Array([peak])
	var indices := PackedInt32Array()
	# The mapped shoreline is exact to input; interior interpolation is a proxy.
	var rings := [0.22, 0.5, 0.78, 1.0]
	for ring_index in range(rings.size()):
		var t: float = rings[ring_index]
		for p: Array in coast:
			var edge := Vector3(p[0], 0.0, p[1])
			var v := peak.lerp(edge, t)
			v.y = peak.y * float(island.ring_levels[ring_index + 1])
			v.x += float(island.shoulder_bias_xz[0]) * 4.0 * t * (1.0 - t)
			v.z += float(island.shoulder_bias_xz[1]) * 4.0 * t * (1.0 - t)
			if island.has("angular_height_cap"):
				var bearing := fposmod(rad_to_deg(atan2(v.x, -v.z)), 360.0)
				var envelope: Array = island.angular_height_cap
				for segment in range(envelope.size() - 1):
					var a: Array = envelope[segment]
					var b: Array = envelope[segment + 1]
					if bearing >= float(a[0]) and bearing <= float(b[0]):
						var weight := (bearing - float(a[0])) / (float(b[0]) - float(a[0]))
						v.y = minf(v.y, peak.y * lerpf(float(a[1]), float(b[1]), weight))
						break
			vertices.append(v)
	var count := coast.size()
	for i in range(count):
		var j := (i + 1) % count
		indices.append_array(PackedInt32Array([0, 1 + i, 1 + j]))
		for ring in range(rings.size() - 1):
			var a := 1 + ring * count + i
			var b := 1 + ring * count + j
			var c := a + count
			var d := b + count
			indices.append_array(PackedInt32Array([a, c, b, b, c, d]))
	_mesh(island.name.capitalize() + "MappedIsland", vertices, indices,
		Color(0.35, 0.44, 0.48) if island.name == "alcatraz" else Color(0.41, 0.50, 0.53))

func _prison_mass(building: Dictionary) -> void:
	var vertices := PackedVector3Array()
	var indices := PackedInt32Array()
	var points: Array = building.footprint_xz.duplicate()
	if points.size() > 1 and points[0] == points[-1]:
		points.pop_back()
	for p: Array in points:
		vertices.append(Vector3(p[0], building.base_y, p[1]))
		vertices.append(Vector3(p[0], building.base_y + building.proxy_height, p[1]))
	for i in range(points.size()):
		var k := i * 2
		var j := ((i + 1) % points.size()) * 2
		indices.append_array(PackedInt32Array([k, k + 1, j, k + 1, j + 1, j]))
	var outline := PackedVector2Array()
	for p: Array in points:
		outline.append(Vector2(p[0], p[1]))
	var roof := Geometry2D.triangulate_polygon(outline)
	for k: int in roof:
		indices.append(k * 2 + 1)
	_mesh("AlcatrazPrisonMassProxy", vertices, indices, Color(0.64, 0.67, 0.64))

func _beam(name_value: String, a: Vector3, b: Vector3, width: float, color: Color) -> void:
	var item := MeshInstance3D.new()
	item.name = name_value
	var box := BoxMesh.new()
	box.size = Vector3(width, a.distance_to(b), width)
	item.mesh = box
	item.material_override = _material(color, name_value)
	item.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	item.position = (a + b) * 0.5
	var direction := (b - a).normalized()
	var side := direction.cross(Vector3.FORWARD)
	if side.length_squared() < 0.001:
		side = direction.cross(Vector3.RIGHT)
	side = side.normalized()
	item.basis = Basis(side, direction, side.cross(direction).normalized())
	add_child(item)

func _bridge(bridge: Dictionary) -> void:
	var s: Array = bridge.towers.south.world_xz_m
	var n: Array = bridge.towers.north.world_xz_m
	var south := Vector3(s[0], 0.0, s[1])
	var north := Vector3(n[0], 0.0, n[1])
	var color := Color(0.48, 0.43, 0.40)
	var roadway := 82.57032 # Official midspan MLLW; constant grade is L1 proxy.
	_beam("GGBCalibratedSouthTower", south, south + Vector3.UP * 227.0, 16.0, color)
	_beam("GGBCalibratedNorthTower", north, north + Vector3.UP * 227.0, 16.0, color)
	_beam("GGBMainRoadwayProxy", south + Vector3.UP * roadway, north + Vector3.UP * roadway, 8.0, color)
	var axis := (north - south).normalized()
	var south_anchor := south - axis * float(bridge.official_side_span_m)
	var north_anchor := north + axis * float(bridge.official_side_span_m)
	for side in range(2):
		var anchor: Vector3 = south_anchor if side == 0 else north_anchor
		var tower: Vector3 = south if side == 0 else north
		_beam("GGBSideRoadway%d" % side, anchor + Vector3.UP * roadway, tower + Vector3.UP * roadway, 8.0, color)
		# Coarse approach piers support the elevated deck; land stays at source height.
		for fraction: float in [0.0, 0.4, 0.8]:
			var foot := anchor.lerp(tower, fraction)
			_beam("GGBApproachPier%d_%d" % [side, int(fraction * 10)], foot, foot + Vector3.UP * roadway, 7.0, color)
		for segment in range(16):
			var t0 := float(segment) / 16.0
			var t1 := float(segment + 1) / 16.0
			var a := anchor.lerp(tower, t0)
			var b := anchor.lerp(tower, t1)
			a.y = roadway + (227.0 - roadway) * t0 * t0
			b.y = roadway + (227.0 - roadway) * t1 * t1
			_beam("GGBSideCable%d_%d" % [side, segment], a, b, 2.0, color)
	_landward_approaches(bridge, color)
	# Cable sag is reference-based silhouette inference, not an engineering catenary.
	for i in range(48):
		var t0 := float(i) / 48.0
		var t1 := float(i + 1) / 48.0
		var a := south.lerp(north, t0)
		var b := south.lerp(north, t1)
		a.y = 91.0 + 136.0 * pow(2.0 * t0 - 1.0, 2.0)
		b.y = 91.0 + 136.0 * pow(2.0 * t1 - 1.0, 2.0)
		_beam("GGBMainCable%d" % i, a, b, 2.0, color)
		if i % 3 == 0:
			_beam("GGBHanger%d" % i, Vector3(a.x, roadway, a.z), a, 1.0, color)

func _ground_height(xz: Vector2) -> float:
	var found := -2.0
	for i in range(0, ground_triangles.size(), 3):
		var a: Vector3 = ground_triangles[i]
		var b: Vector3 = ground_triangles[i+1]
		var c: Vector3 = ground_triangles[i+2]
		var va := Vector2(a.x,a.z)
		var vb := Vector2(b.x,b.z)
		var vc := Vector2(c.x,c.z)
		var denominator := (vb-va).cross(vc-va)
		if absf(denominator) < 0.001:
			continue
		var u := (xz-va).cross(vc-va)/denominator
		var v := (vb-va).cross(xz-va)/denominator
		if u >= -0.001 and v >= -0.001 and u+v <= 1.001:
			found = maxf(found, a.y*(1.0-u-v)+b.y*u+c.y*v)
	return maxf(found, 0.0)

func _landward_approaches(bridge: Dictionary, color: Color) -> void:
	for approach: Dictionary in bridge.landward_approaches:
		var anchor: Array = approach.anchor_xz
		var points := PackedVector3Array([Vector3(anchor[0],82.57032,anchor[1])])
		for sample: Dictionary in approach.route:
			points.append(Vector3(sample.xz[0],0.0,sample.xz[1]))
		var total := 0.0
		for i in range(1,points.size()):
			total += Vector2(points[i].x-points[i-1].x,points[i].z-points[i-1].z).length()
		var last: Vector3 = points[points.size()-1]
		# Higher mainland naturally occludes the level road; never ramp up the proxy ridge.
		var end_height := minf(82.57032, _ground_height(Vector2(last.x,last.z)) + 2.0)
		var distance := 0.0
		for i in range(1,points.size()):
			distance += Vector2(points[i].x-points[i-1].x,points[i].z-points[i-1].z).length()
			points[i].y = lerpf(82.57032,end_height,distance/maxf(total,1.0))
			_beam("GGBLandward%s%d" % [approach.side,i],points[i-1],points[i],8.0,color)
			var foot := points[i]
			foot.y = _ground_height(Vector2(foot.x,foot.z))
			if points[i].y > foot.y + 2.0:
				_beam("GGBLandSupport%s%d" % [approach.side,i],foot,points[i],5.0,color)
