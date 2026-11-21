extends SceneTree
## Bakes Building 1's weathering map (game/scripts/world/facades/building_1_weathering_map.gd)
## from the hero model's built records, as the world builds them, and writes it with its
## bounds into the materials that read it (game/resources/facades/building_1_weathering.json).
## The game never builds the map at load; run this again whenever the building's form
## changes:
##   tools/godot --headless --path . --script tools/bake_building_1_weathering.gd
## Prints the map's size, bounds and bytes; exits 1 when it cannot bake.

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
	var meshes: Array = []
	var flat: Array = []
	var glass: Array = []
	for node: Node in holder.find_children("Hero*", "MeshInstance3D", true, false):
		var name := str(node.name)
		if name in (config.glass as Array):
			glass.append(node)
		if name in (config.not_tops as Array):
			continue
		if name.begins_with(FLAT_TOPS_PREFIX):
			flat.append(node)
		else:
			meshes.append(node)
	var runs := _runs(config as Dictionary)
	if meshes.is_empty() or glass.is_empty() or runs.is_empty():
		_fail("nothing to map: %d meshes, %d glass, %d runs" % [meshes.size(), glass.size(), runs.size()])
		return
	var started := Time.get_ticks_msec()
	var map := WEATHERING_MAP.build(meshes, glass, runs, {"flat_tops": flat, "interior_exposure": float(config.interior_exposure), "exposure_blur_m": float(config.exposure_blur_m)})
	if map.is_empty():
		_fail("the weathering map is empty")
		return
	var image := map.image as Image
	var texture := ImageTexture.create_from_image(image)
	var error := ResourceSaver.save(texture, str(config.map_path))
	if error != OK:
		_fail("cannot save %s (%d)" % [config.map_path, error])
		return
	var bounds := map.bounds as Vector4
	for path: Variant in config.materials:
		var problem := _write_into(str(path), str(config.map_path), bounds)
		if problem != "":
			_fail(problem)
			return
	print("WEATHERING_MAP %dx%d cells, bounds %s, %d bytes of image data, built in %d ms, written into %d materials" % [image.get_width(), image.get_height(), bounds, image.get_data().size(), Time.get_ticks_msec() - started, (config.materials as Array).size()])
	holder.free()
	quit(0)


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
