extends RefCounted
## Building 1's material study (owner, 2026-11-20: "building 1 also needs better, more
## detailed textures"): puts the building_1_m_*.tres material set onto the current
## building's surfaces without editing the model, for the shared capture driver's
## --study (game/tests/shared/building_shots.gd).
##
## apply("current") shows the building as the model draws it; apply("study") shows the
## material set. Each named mesh takes its study material as an override. Where one of
## the model's meshes holds parts the owner's 2026-11-20 photos show in different
## finishes (the pale blue-grey window surrounds of the wings, pavilions and rear;
## blue, dark or bronze window steel), its triangles are split by the part of the
## building of the nearest window glass, standing in for the material slots the model
## would add (a study approximation: the split follows proximity, not the model's own
## parts). The weathering map (game/scripts/world/facades/building_1_weathering_map.gd)
## is built from the loaded building and its source wall runs, each run's exposure
## from its class in the study's settings.
##
## Settings (the --study file): "run_classes": {CLASS: [run index, ...]} for the main
## wall record (the tower's runs are class "tower"); "exposure": {CLASS: 0..1};
## "by_mesh": {MESH NAME: material path}; "splits": [{"mesh": NAME, "margins_m":
## [side, top, bottom, depth], "near_windows": {CLASS: material path}, "rest":
## material path or ""}] ("" keeps the mesh's own material for triangles near no
## listed window); optional "save_map": an absolute PNG path for a picture of the map.

const HERO := preload("res://game/scripts/world/facades/building_1_hero_model.gd")
const WEATHERING_MAP := preload("res://game/scripts/world/facades/building_1_weathering_map.gd")
const SOURCE_KEYS := ["r16681702", "w1222720021"]
## The meshes holding window glass, whose panels class the splits and give the sills.
const GLASS_MESHES := ["HeroGlazing", "HeroTowerBaseStoreyGlazing", "HeroTowerExactPlanGlass"]
## A plan cell of the window index (m).
const INDEX_CELL_M := 2.0
## Thin masts standing over the roofs: no wall below hangs streaks from them.
const NOT_TOPS := ["HeroFlagpole", "HeroDrumMast", "HeroTowerVentSpike"]

## [[MeshInstance3D, Material]] overridden in the study.
static var _overrides: Array = []
## Meshes the study hides, and the split parts it shows in their place.
static var _split_sources: Array = []
static var _split_parts: Array = []
## The weathering map's {"texture", "image", "bounds"}.
static var weathering := {}


static func prepare(world: Node, settings: Dictionary) -> String:
	_overrides.clear()
	_split_sources.clear()
	_split_parts.clear()
	var meshes := _hero_meshes(world)
	if meshes.is_empty():
		return "building 1 study: no Building 1 hero meshes in the loaded world"
	var runs := _runs(settings)
	if runs.is_empty():
		return "building 1 study: the source wall runs did not resolve"
	var glass: Array = []
	for name: String in GLASS_MESHES:
		if meshes.has(name):
			glass.append(meshes[name])
	var tops: Array = []
	for name: String in meshes:
		if name not in NOT_TOPS:
			tops.append(meshes[name])
	var started := Time.get_ticks_msec()
	weathering = WEATHERING_MAP.build(tops, glass, runs)
	if weathering.is_empty():
		return "building 1 study: the weathering map is empty"
	var image := weathering.image as Image
	print("STUDY_MAP size=%dx%d bounds=%s bytes=%d build_ms=%d" % [image.get_width(), image.get_height(), weathering.bounds, image.get_data().size(), Time.get_ticks_msec() - started])
	if settings.has("save_map"):
		_save_map_picture(str(settings.save_map))
	var materials := {}
	var by_mesh: Dictionary = settings.get("by_mesh", {})
	for name: String in by_mesh:
		if not meshes.has(name):
			return "building 1 study: no mesh %s" % name
		var material := _material(str(by_mesh[name]), materials)
		if material == null:
			return "building 1 study: %s did not load" % by_mesh[name]
		_overrides.append([meshes[name], material])
	var panels := _panels(glass, runs)
	for spec: Variant in settings.get("splits", []):
		var error := _split(spec as Dictionary, meshes, panels, materials)
		if error != "":
			return error
	print("STUDY_PREPARED overrides=%d split_meshes=%d parts=%d panels=%d materials=%d" % [_overrides.size(), _split_sources.size(), _split_parts.size(), (panels.list as Array).size(), materials.size()])
	return ""


static func apply(_world: Node, set_name: String) -> String:
	if set_name not in ["current", "study"]:
		return "building 1 study: the sets are current and study, not %s" % set_name
	var study := set_name == "study"
	for pair: Array in _overrides:
		(pair[0] as MeshInstance3D).material_override = pair[1] if study else null
	for node: Variant in _split_sources:
		(node as MeshInstance3D).visible = not study
	for node: Variant in _split_parts:
		(node as MeshInstance3D).visible = study
	print("STUDY_SET %s" % set_name)
	return ""


## Building 1's hero meshes by name (Hero*), under the nodes of its two sources.
static func _hero_meshes(world: Node) -> Dictionary:
	var found := {}
	var roots: Array[Node] = []
	_collect_roots(world, roots)
	for root in roots:
		for node: Node in root.find_children("Hero*", "MeshInstance3D", true, false):
			if not found.has(node.name):
				found[str(node.name)] = node
	return found


static func _collect_roots(node: Node, roots: Array[Node]) -> void:
	if str(node.name).begins_with("Building1"):
		for key: String in SOURCE_KEYS:
			var keyed := node.has_meta("source_keys") and key in (node.get_meta("source_keys") as Array).map(func(k: Variant) -> String: return str(k))
			if keyed or (node.has_meta("derived_object_key") and (":%s:" % key) in str(node.get_meta("derived_object_key"))):
				roots.append(node)
				return
	for child in node.get_children():
		_collect_roots(child, roots)


## The source wall runs' feet with their class and exposure: [{"start", "end",
## "class", "exposure"}].
static func _runs(settings: Dictionary) -> Array:
	var classes := {}
	var run_classes: Dictionary = settings.get("run_classes", {})
	for name: String in run_classes:
		for index: Variant in run_classes[name]:
			classes[int(index)] = name
	var exposure: Dictionary = settings.get("exposure", {})
	var runs: Array = []
	for source: Array in [[HERO.MAIN_CHUNK_PATH, HERO.BUILDING_WALL_KEY, ""], [HERO.TOWER_CHUNK_PATH, HERO.TOWER_WALL_KEY, "tower"]]:
		var record := HERO._record_from_chunk(str(source[0]), str(source[1]))
		var values: Array = record.get("vertices", [])
		for run in values.size() / 12:
			var o := run * 12
			var start := Vector3(float(values[o]), float(values[o + 1]), float(values[o + 2]))
			var end := Vector3(float(values[o + 3]), float(values[o + 4]), float(values[o + 5]))
			var name: String = str(source[2]) if str(source[2]) != "" else str(classes.get(run, "other"))
			runs.append({"start": start, "end": end, "class": name, "exposure": float(exposure.get(name, exposure.get("other", 0.5)))})
	return runs


## The glass's window panels (faces at least 0.3 m wide, walls only), each with its
## plane, extent and class (the nearest run's), indexed by plan cell.
static func _panels(glass: Array, runs: Array) -> Dictionary:
	var panels: Array = []
	for node: Variant in glass:
		var instance := node as MeshInstance3D
		var xform := instance.global_transform
		var arrays := instance.mesh.surface_get_arrays(0)
		var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
		var normals := arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array
		var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
		for t in range(0, indices.size(), 3):
			var n := (xform.basis * normals[indices[t]]).normalized()
			if absf(n.y) > 0.3:
				continue
			var points: Array[Vector3] = [xform * vertices[indices[t]], xform * vertices[indices[t + 1]], xform * vertices[indices[t + 2]]]
			var along_axis := Vector3.UP.cross(n).normalized()
			var a0 := INF
			var a1 := -INF
			var y0 := INF
			var y1 := -INF
			for p in points:
				a0 = minf(a0, p.dot(along_axis))
				a1 = maxf(a1, p.dot(along_axis))
				y0 = minf(y0, p.y)
				y1 = maxf(y1, p.y)
			if a1 - a0 < 0.3:
				continue
			var center := (points[0] + points[1] + points[2]) / 3.0
			panels.append({"normal": n, "along": along_axis, "a": Vector2(a0, a1), "y": Vector2(y0, y1), "plane": points[0].dot(n), "center": center, "class": _nearest_class(center, runs)})
	var index := {}
	for p in panels.size():
		var panel: Dictionary = panels[p]
		var c := panel.center as Vector3
		var reach := (panel.a as Vector2).y - (panel.a as Vector2).x + 2.0
		for i in range(int(floorf((c.x - reach) / INDEX_CELL_M)), int(floorf((c.x + reach) / INDEX_CELL_M)) + 1):
			for j in range(int(floorf((c.z - reach) / INDEX_CELL_M)), int(floorf((c.z + reach) / INDEX_CELL_M)) + 1):
				var key := Vector2i(i, j)
				if not index.has(key):
					index[key] = []
				(index[key] as Array).append(p)
	return {"list": panels, "index": index}


static func _nearest_class(point: Vector3, runs: Array) -> String:
	var best := INF
	var name := "other"
	var p := Vector2(point.x, point.z)
	for run: Dictionary in runs:
		var a := Vector2((run.start as Vector3).x, (run.start as Vector3).z)
		var b := Vector2((run.end as Vector3).x, (run.end as Vector3).z)
		var segment := b - a
		var along := clampf((p - a).dot(segment) / maxf(segment.length_squared(), 1e-9), 0.0, 1.0)
		var distance := (p - (a + segment * along)).length()
		if distance < best:
			best = distance
			name = str(run["class"])
	return name


## Splits one mesh's triangles by the class of the nearest window panel within the
## margins: each listed class becomes a part with its material, the others the rest.
static func _split(spec: Dictionary, meshes: Dictionary, panels: Dictionary, materials: Dictionary) -> String:
	var name := str(spec.get("mesh", ""))
	if not meshes.has(name):
		return "building 1 study: no mesh %s to split" % name
	var source := meshes[name] as MeshInstance3D
	var margins: Array = spec.get("margins_m", [0.3, 0.45, 0.35, 0.7])
	var near: Dictionary = (spec.get("near_windows", {}) as Dictionary).duplicate()
	var xform := source.global_transform
	var arrays := source.mesh.surface_get_arrays(0)
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
	# Plain Arrays in the dictionary: a packed array read back through it would be a
	# copy, and what was appended to it lost.
	var parts := {}
	# Broad flat faces of a mesh of mouldings (the crescent's attic frieze, the
	# pavilions' fins) are wall in the photos, board lines and all.
	var large: Dictionary = spec.get("large_faces", {})
	for t in range(0, indices.size(), 3):
		var a := xform * vertices[indices[t]]
		var b := xform * vertices[indices[t + 1]]
		var d := xform * vertices[indices[t + 2]]
		var c := (a + b + d) / 3.0
		var found := _panel_class(c, panels, margins)
		var part := found if near.has(found) else ""
		if part == "" and not large.is_empty() and _is_large_wall_face(a, b, d, large):
			part = "large"
			near["large"] = large.material
		if not parts.has(part):
			parts[part] = []
		(parts[part] as Array).append_array([indices[t], indices[t + 1], indices[t + 2]])
	_split_sources.append(source)
	for part: String in parts:
		var path := str(near[part]) if part != "" else str(spec.get("rest", ""))
		var material: Material = source.mesh.surface_get_material(0) if path == "" else _material(path, materials)
		if material == null:
			return "building 1 study: %s did not load" % path
		var part_arrays := arrays.duplicate()
		part_arrays[Mesh.ARRAY_INDEX] = PackedInt32Array(parts[part] as Array)
		var mesh := ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, part_arrays)
		mesh.surface_set_material(0, material)
		var node := MeshInstance3D.new()
		node.name = "%sStudy%s" % [name, part.capitalize().replace(" ", "") if part != "" else "Rest"]
		node.mesh = mesh
		node.layers = source.layers
		node.cast_shadow = source.cast_shadow
		node.visible = false
		source.get_parent().add_child(node)
		node.global_transform = source.global_transform
		_split_parts.append(node)
		print("STUDY_SPLIT %s part=%s triangles=%d material=%s" % [name, part if part != "" else "rest", (parts[part] as Array).size() / 3, path if path != "" else "(own)"])
	return ""


## A near-vertical face at least min_area_m2 in area and min_extent_m both along and
## up the face.
static func _is_large_wall_face(a: Vector3, b: Vector3, c: Vector3, large: Dictionary) -> bool:
	var cross := (b - a).cross(c - a)
	var area := cross.length() * 0.5
	if area < float(large.get("min_area_m2", 1.2)):
		return false
	var n := cross.normalized()
	if absf(n.y) > 0.3:
		return false
	var along := Vector3.UP.cross(n).normalized()
	var extent_along := maxf(maxf(a.dot(along), b.dot(along)), c.dot(along)) - minf(minf(a.dot(along), b.dot(along)), c.dot(along))
	var extent_up := maxf(maxf(a.y, b.y), c.y) - minf(minf(a.y, b.y), c.y)
	var least := float(large.get("min_extent_m", 0.8))
	return extent_along >= least and extent_up >= least


static func _panel_class(c: Vector3, panels: Dictionary, margins: Array) -> String:
	var key := Vector2i(int(floorf(c.x / INDEX_CELL_M)), int(floorf(c.z / INDEX_CELL_M)))
	var best := INF
	var found := ""
	for p: int in panels.index.get(key, []):
		var panel: Dictionary = panels.list[p]
		var depth := absf(c.dot(panel.normal) - float(panel.plane))
		if depth > float(margins[3]):
			continue
		var a := c.dot(panel.along)
		var range_a := panel.a as Vector2
		var range_y := panel.y as Vector2
		if a < range_a.x - float(margins[0]) or a > range_a.y + float(margins[0]):
			continue
		if c.y < range_y.x - float(margins[2]) or c.y > range_y.y + float(margins[1]):
			continue
		if depth < best:
			best = depth
			found = str(panel["class"])
	return found


static func _material(path: String, cache: Dictionary) -> Material:
	if cache.has(path):
		return cache[path]
	var material := load(path) as Material
	if material is ShaderMaterial and weathering.has("texture"):
		var shader_material := material as ShaderMaterial
		shader_material.set_shader_parameter("weathering_map", weathering.texture)
		shader_material.set_shader_parameter("weathering_map_bounds", weathering.bounds)
	cache[path] = material
	return material


## A picture of the map for the material board: R the top, G the sill (both over
## 0-40 m), B the exposure.
static func _save_map_picture(path: String) -> void:
	var image := weathering.image as Image
	var picture := Image.create_empty(image.get_width(), image.get_height(), false, Image.FORMAT_RGB8)
	for j in image.get_height():
		for i in image.get_width():
			var value := image.get_pixel(i, j)
			picture.set_pixel(i, j, Color(clampf(value.r / 40.0, 0.0, 1.0), clampf(value.g / 40.0, 0.0, 1.0), value.b))
	picture.save_png(path)
	print("STUDY_MAP_SAVED %s" % path)
