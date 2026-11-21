extends SceneTree
## Bakes Building 1's weathering map (game/scripts/world/facades/building_1_weathering_map.gd)
## from the hero model's built records, as the world builds them, and writes it with its
## bounds into the materials that read it (game/resources/facades/building_1_weathering.json).
## It also bakes the web's copy, the same map at web_cell_m (0.5 m: a quarter of the
## memory) over the same bounds, beside it as MAP.web, which web exports carry in the
## map's place (addons/generated_world_export); desktop and the editor draw the map.
## The game never builds the map at load; run this again whenever the building's form
## changes:
##   tools/godot --headless --path . --script tools/bake_building_1_weathering.gd
## Prints the maps' sizes, bounds and bytes; exits 1 when it cannot bake.

const HERO := preload("res://game/scripts/world/facades/building_1_hero_model.gd")
const WEATHERING_MAP := preload("res://game/scripts/world/facades/building_1_weathering_map.gd")
const CONFIG_PATH := "res://game/resources/facades/building_1_weathering.json"
## The cab's runs, their class.
const TOWER_CLASS := "tower"
## The cab's meshes, whose tops join the map without growth (they stand on the drum's
## roof a metre or two behind its coping).
const FLAT_TOPS_PREFIX := "HeroTower"
## The map's ext_resource id in the materials it is written into.
const MAP_ID := "9_weathering_map"
## The web copy's name beside the map (GeneratedWorldExport.WEB_COPY_SUFFIX).
const WEB_SUFFIX := ".web"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var config: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	if not config is Dictionary:
		_fail("%s does not parse" % CONFIG_PATH)
		return
	var holder := Node3D.new()
	root.add_child(holder)
	for key: String in [HERO.BUILDING_WALL_KEY, HERO.BUILDING_ROOF_KEY, HERO.TOWER_WALL_KEY, HERO.TOWER_ROOF_KEY]:
		var chunk := HERO.TOWER_CHUNK_PATH if key.begins_with("building:w") else HERO.MAIN_CHUNK_PATH
		var record: Dictionary = HERO._record_from_chunk(chunk, key)
		var built: Dictionary = HERO.build_record(record)
		if not bool(built.get("ok", false)) or not built.get("node") is Node3D:
			_fail("%s does not build: %s" % [key, built.get("message", "")])
			return
		holder.add_child(built.node as Node3D)
		# The wall's record also builds the hall beside it (extra_nodes), which the map
		# does not read: freed at once.
		for extra: Variant in built.get("extra_nodes", []):
			var extra_node: Variant = ((extra as Dictionary).get("result", {}) as Dictionary).get("node")
			if extra_node is Node:
				(extra_node as Node).free()
	var meshes: Array = []
	var flat: Array = []
	for node: Node in holder.find_children("Hero*", "MeshInstance3D", true, false):
		var name := str(node.name)
		if name in (config.not_tops as Array):
			continue
		if name.begins_with(FLAT_TOPS_PREFIX):
			flat.append(node)
		else:
			meshes.append(node)
	var runs := _runs(config as Dictionary)
	if meshes.is_empty() or runs.is_empty():
		_fail("nothing to map: %d meshes, %d runs" % [meshes.size(), runs.size()])
		return
	var started := Time.get_ticks_msec()
	var options := {"flat_tops": flat, "interior_exposure": float(config.interior_exposure), "exposure_blur_m": float(config.exposure_blur_m)}
	var map := WEATHERING_MAP.build(meshes, runs, options)
	options["cell_m"] = float(config.web_cell_m)
	var web := WEATHERING_MAP.build(meshes, runs, options)
	if map.is_empty() or web.is_empty():
		_fail("the weathering map is empty")
		return
	var bounds := map.bounds as Vector4
	# The materials hold one bounds for both: the web's cells must tile the same area.
	if not (web.bounds as Vector4).is_equal_approx(bounds):
		_fail("the web copy's bounds %s are not the map's %s" % [web.bounds, bounds])
		return
	var image := map.image as Image
	var web_image := web.image as Image
	# A resource saver needs a .res name: the web copy is saved at the map's path
	# first, its bytes copied to MAP.web, and the map itself then saved over it.
	var problem := _save(web_image, str(config.map_path))
	if problem == "":
		problem = _copy_to_web(str(config.map_path))
	if problem == "":
		problem = _save(image, str(config.map_path))
	if problem != "":
		_fail(problem)
		return
	for path: Variant in config.materials:
		problem = _write_into(str(path), str(config.map_path), bounds)
		if problem != "":
			_fail(problem)
			return
	print("WEATHERING_MAP %dx%d cells, bounds %s, %d bytes of image data; web copy %dx%d cells, %d bytes; built in %d ms, written into %d materials" % [image.get_width(), image.get_height(), bounds, image.get_data().size(), web_image.get_width(), web_image.get_height(), web_image.get_data().size(), Time.get_ticks_msec() - started, (config.materials as Array).size()])
	holder.free()
	quit(0)


## Saves image as a texture at path. Returns a problem, or "".
func _save(image: Image, path: String) -> String:
	var error := ResourceSaver.save(ImageTexture.create_from_image(image), path)
	return "" if error == OK else "cannot save %s (%d)" % [path, error]


## Copies the texture file at path to path + WEB_SUFFIX. Returns a problem, or "".
func _copy_to_web(path: String) -> String:
	var bytes := FileAccess.get_file_as_bytes(path)
	var file := FileAccess.open(path + WEB_SUFFIX, FileAccess.WRITE)
	if bytes.is_empty() or file == null:
		return "cannot copy %s to %s%s" % [path, path, WEB_SUFFIX]
	file.store_buffer(bytes)
	file.close()
	return ""


## The source wall runs' feet with their class's exposure: [{"start", "end", "exposure"}].
func _runs(config: Dictionary) -> Array:
	var classes := {}
	for name: String in config.run_classes:
		for index: Variant in config.run_classes[name]:
			classes[int(index)] = name
	var exposure := config.exposure as Dictionary
	var runs: Array = []
	for source: Array in [[HERO.MAIN_CHUNK_PATH, HERO.BUILDING_WALL_KEY, ""], [HERO.TOWER_CHUNK_PATH, HERO.TOWER_WALL_KEY, TOWER_CLASS]]:
		var record: Dictionary = HERO._record_from_chunk(str(source[0]), str(source[1]))
		var values: Array = record.get("vertices", [])
		for run in values.size() / 12:
			var o := run * 12
			var name: String = str(source[2]) if str(source[2]) != "" else str(classes.get(run, "other"))
			runs.append({"start": Vector3(float(values[o]), float(values[o + 1]), float(values[o + 2])), "end": Vector3(float(values[o + 3]), float(values[o + 4]), float(values[o + 5])), "exposure": float(exposure.get(name, exposure.get("other", 0.5)))})
	return runs


## Sets the map and its bounds in a material's text (a ShaderMaterial .tres): its
## ext_resource and the two shader parameters, replacing earlier ones.
func _write_into(path: String, map_path: String, bounds: Vector4) -> String:
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty() or not "[resource]" in text:
		return "%s is not a material file" % path
	var lines: Array[String] = []
	for line in text.split("\n"):
		if line.begins_with("[ext_resource") and MAP_ID in line:
			continue
		if line.begins_with("shader_parameter/weathering_map"):
			continue
		lines.append(line)
	var last_ext := -1
	for index in lines.size():
		if lines[index].begins_with("[ext_resource"):
			last_ext = index
	if last_ext < 0:
		return "%s has no external resources to follow" % path
	lines.insert(last_ext + 1, "[ext_resource type=\"Texture2D\" path=\"%s\" id=\"%s\"]" % [map_path, MAP_ID])
	var out := "\n".join(lines).strip_edges(false, true)
	out += "\nshader_parameter/weathering_map = ExtResource(\"%s\")" % MAP_ID
	out += "\nshader_parameter/weathering_map_bounds = Vector4(%s, %s, %s, %s)\n" % [bounds.x, bounds.y, bounds.z, bounds.w]
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return "cannot write %s" % path
	file.store_string(out)
	file.close()
	return ""


func _fail(message: String) -> void:
	print("FAIL: Building 1's weathering map: %s" % message)
	quit(1)
