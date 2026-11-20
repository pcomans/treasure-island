extends SceneTree
## The bake's material sharing (tools/share_baked_materials.gd), headless, on hand-built
## nodes; and every function in game/ that writes materials:
##   - equal materials on overrides, overlays, surface overrides, mesh surfaces (a
##     MultiMesh's and a PrimitiveMesh's too) come out as one object, the first found,
##     and next passes are shared before the materials pointing to them; materials that
##     differ in one value, their name, a shader parameter, a texture's identity or the
##     walkers that find them stay apart, as do scripted materials and two saved in files
##     of their own (the copies of one point to it); a mesh saved in a file of its own
##     keeps its materials; every reference ends at a material equal to its own;
##   - the bake's walkers (SHARE.world_walkers) on a hand-built world: equal daylight
##     fills under the buildings are shared, an equal copy elsewhere is not; the ground
##     cover the ground dressing's captures copy is what it writes in play
##     (GroundDressing._set_lawn_threads), before and after sharing, and its write
##     reaches the same meshes as before;
##   - every function in game/ (its tests aside, which never run in play) that writes a
##     material's values (_writes: assigns a material property or a component of one,
##     sets one by name, deferred, by path or with a tween, sets a shader parameter, or
##     calls a RenderingServer material function) is classified, by folder, file or
##     function (a script that also reads the baked world's materials, by function):
##     BUILDS (it writes while the island loads or bakes, before the bake shares the baked
##     world's materials; none of its writes sits in a callback Godot calls in play),
##     OWN (in play it writes only materials it makes or copies, or ones the baked world
##     doesn't hold) or WALKS (in play it writes what one of the bake's WALKERS finds,
##     which the bake shares only among themselves). A new writer fails here until it
##     says which; a classification that matches no writer fails too.

const SHARE := preload("res://tools/share_baked_materials.gd")
const MERGE_BUILDINGS := preload("res://tools/merge_baked_buildings.gd")
const GROUND_DRESSING := preload("res://game/scripts/world/ground_dressing.gd")
const GROUND_COVER := preload("res://game/scripts/world/ground_cover.gd")
## Scanned for writers, but for TESTS_ROOT: tests and their support run only in tests.
const SCRIPTS_ROOT := "res://game"
const TESTS_ROOT := "res://game/tests/"
## The callbacks Godot calls in play (as headless_shader_warm_up_contract.gd's).
const RUNTIME_CALLBACKS := "^(_process|_physics_process|_input|_unhandled_input|_unhandled_key_input|_notification|_integrate_forces|_on_\\w+)$"
## The material classes whose properties WRITES looks for.
const MATERIAL_CLASSES: Array[String] = ["StandardMaterial3D", "ORMMaterial3D", "ShaderMaterial"]
## Writers whose writes all come while the island loads or bakes, before the bake shares
## the baked world's materials: by folder (ending "/"), file, or "FILE::FUNCTION".
const BUILDS := {
	"res://game/resources/models/bulgarian_wall/": "builds the Bulgarian Wall's court and neighbour while the island loads (or bakes)",
	"res://game/scripts/world/facades/": "builds buildings while the island loads (or bakes)",
	"res://game/scripts/world/massing/": "builds buildings while the island loads (or bakes)",
	"res://game/scripts/world/bay_bridge_builder.gd": "builds the Bay Bridge while the island loads (or bakes)",
	"res://game/scripts/world/breakwater_birds.gd": "builds the birds while the island loads (or bakes)",
	"res://game/scripts/world/ferry_terminal.gd": "builds the ferry terminal while the island loads (or bakes)",
	"res://game/scripts/world/fresh_bay_horizon.gd": "builds the horizon while the island loads (or bakes)",
	"res://game/scripts/world/ground_cover.gd": "makes the ground-cover materials while the island loads (or bakes)",
	"res://game/scripts/world/mulch_ground.gd": "makes the mulch materials while the island loads (or bakes)",
	"res://game/scripts/world/shoreline_builder.gd": "builds the shoreline while the island loads (or bakes)",
	"res://game/scripts/world/street_detail_batches.gd": "gives the street detail's levels their band copies while the island loads (or bakes)",
	"res://game/scripts/world/street_furniture_builder.gd": "builds the street furniture while the island loads (or bakes)",
	"res://game/scripts/world/western_background_blockout.gd": "builds the western background while the island loads (or bakes)",
	"res://game/scripts/world/world_chunk_builder.gd": "builds the island's chunks while it loads (or bakes)",
	"res://game/scripts/world/ybi_detail_materials.gd": "makes Yerba Buena Island's materials while the island loads (or bakes)",
	"res://game/scripts/world/ybi_ground.gd": "builds Yerba Buena Island's ground while the island loads (or bakes)",
	"res://game/scripts/world/ybi_vegetation_builder.gd": "builds Yerba Buena Island's trees while the island loads (or bakes)",
}
## Writers that in play write only materials they make or copy, or ones the baked world
## doesn't hold, so the bake's sharing never reaches what they write. Scripts that also
## find the baked world's materials (day_sun, ground_dressing, drivable_car,
## street_furniture_breaker) are classified by function, so a new writer there must say.
const OWN := {
	"res://game/scripts/debug/drive_trace.gd": "writes no material: its census records have a field named shader",
	"res://game/scripts/debug/startup_marks.gd": "its probe's own material (a startup measurement, only with ?profile_startup=1)",
	"res://game/scripts/world/facades/building_1_mural_loader.gd": "only the Building 1 hall's own mural materials, which its builder names for the hall alone (Building1Interior_*), so the bake's sharing joins them with no other material: the mural tiles' textures as they load and go",
	"res://game/scripts/world/facades/building_1_hall_reflections.gd": "only the Building 1 hall's own floor material, which its builder names for the hall alone (Building1Interior_terrazzo), so the bake's sharing joins it with no other material: its polish while the hall's floor reflections are on",
	"res://game/scripts/player/": "the player's own materials, made with it",
	"res://game/scripts/vehicles/car_driver.gd": "a car driver's own materials, made with it",
	"res://game/scripts/vehicles/car_splash.gd": "a splash's own materials",
	"res://game/scripts/vehicles/drivable_car.gd::set_lamps_lit": "a driven car's lit lamps: a copy of its kit's material, made before it writes, on the car's own pieces",
	"res://game/scripts/vehicles/street_furniture_breaker.gd::_lens_off_material": "makes the felled lamps' lens-off material, which only a felled prop's own copy draws",
	"res://game/scripts/world/day_sun.gd::light": "the sky's material (main.tscn's environment), which the baked world doesn't hold",
	"res://game/scripts/world/goal_confetti.gd": "the confetti's own materials",
	"res://game/scripts/world/ground_dressing.gd::configure": "the chips' own material: its capture",
	"res://game/scripts/world/ground_dressing.gd::_ring_material": "makes a ring's material",
	"res://game/scripts/world/ground_dressing.gd::_share_captures": "a ring's own material: the captures it reads",
	"res://game/scripts/world/ground_dressing.gd::_pick_grass": "makes the grass cards' material",
	"res://game/scripts/world/ground_dressing.gd::set_level": "the grass's own material: its blades' width",
	"res://game/scripts/world/ground_dressing.gd::set_chip_occluders": "its own chips occluder material",
	"res://game/scripts/world/ground_dressing.gd::set_render_priority": "its rings' own materials",
	"res://game/scripts/world/ground_dressing.gd::set_parameter": "its rings' own materials and the captures' copies (tuning shots)",
	"res://game/scripts/world/ground_dressing.gd::_process": "the grass's own material: where the player bends it",
	"res://game/scripts/world/ground_dressing.gd::_capture": "its rings' own materials: the captures' windows",
	"res://game/scripts/world/ground_dressing.gd::_set_ring": "a ring's own material: its density and reach",
	"res://game/scripts/world/ground_dressing.gd::_build_captures": "makes the captures' mask and occluder materials",
	"res://game/scripts/world/ground_dressing.gd::_mulch_capture": "makes a mulch material's capture copies",
	"res://game/scripts/world/ground_dressing.gd::_ground_capture": "makes a ground family's capture copies",
	"res://game/scripts/world/ground_dressing.gd::_yard_capture": "a yard material's capture copy, and the stones' own material",
	"res://game/scripts/world/shader_warm_up.gd": "its proxies' own labels",
	"res://game/scripts/world/sky_weather.gd": "the sky's material (main.tscn's environment), which the baked world doesn't hold",
	"res://game/scripts/world/soccer_ball.gd": "the ball's own material, made with it",
	"res://game/scripts/world/street_clutter_kit.gd": "makes its materials when a kit is made (the street detail's while the island loads or bakes, the vehicles' own in play)",
	"res://game/scripts/world/street_fence_kit.gd": "makes its materials when a kit is made (the fences' while the island loads or bakes, the fence breaker's own in play)",
	"res://game/scripts/world/street_furniture_kit.gd": "makes its materials when a kit is made, while the island loads (or bakes)",
	"res://game/scripts/world/street_vegetation_kit.gd": "makes its materials when a kit is made or first asked for one, while the island loads (or bakes)",
	"res://game/scripts/world/street_yard_kit.gd": "makes its materials when a kit is made (the yards' while the island loads or bakes, the vehicles' own in play)",
}
## Ways of writing a material the scan must see, and lines it must not take for one.
const WRITE_SPELLINGS: Array[String] = [
	"m.albedo_color = Color.RED", "m.albedo_color.a = 0.5", "m.uv1_scale.x *= 2.0", "m.set(\"emission_energy_multiplier\", 2.0)",
	"m.set_deferred(&\"albedo_color\", Color.RED)", "m.set_indexed(\"albedo_color:a\", 0.5)",
	"create_tween().tween_property(m, \"emission_energy_multiplier\", 2.0, 1.0)", "m.set_shader_parameter(\"amount\", 1.0)",
	"RenderingServer.material_set_param(rid, \"amount\", 1.0)",
]
const NOT_WRITES: Array[String] = ["# m.albedo_color = Color.RED", "if m.albedo_color == Color.RED: pass", "var c := m.albedo_color", "m.roughness >= 0.5"]
## Writers that in play write the baked world's materials they find by walking it, by
## function: the walker (SHARE.WALKERS) that finds the same materials, which the bake
## shares only among themselves.
const WALKS := {
	"res://game/scripts/world/day_sun.gd::_put_fill": "daylight fills",
	"res://game/scripts/world/ground_dressing.gd::_set_lawn_threads": "lawn threads",
}


## The parts of the world the walkers read (WorldLoader's), empty but for what a check
## adds.
class FakeWorld extends Node3D:
	var ground_and_areas := Node3D.new()
	var roads_and_paths := Node3D.new()
	var buildings := Node3D.new()
	var street_detail := Node3D.new()

	func _init() -> void:
		for part: Node3D in [ground_and_areas, roads_and_paths, buildings, street_detail]:
			add_child(part)
		for layer: String in ["Furniture", "Clutter"]:
			var node := Node3D.new()
			node.name = layer
			street_detail.add_child(node)


var _failed := false


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var scan := _check_scan()
	_check_sharing()
	_check_walkers()
	if _failed or scan.is_empty():
		quit(1)
		return
	print("PASS: material sharing: equal materials shared, kept ones and walkers' finds kept apart; %s" % scan)
	quit(0)


func _require(condition: bool, message: String) -> bool:
	if not condition:
		_failed = true
		push_error("FAIL: " + message)
	return condition


## Hand-built references of every kind, shared once.
func _check_sharing() -> void:
	var holder := Node3D.new()
	root.add_child(holder)
	var shader := Shader.new()
	shader.code = "shader_type spatial;\nuniform float amount = 0.5;\nvoid fragment() { ALBEDO = vec3(amount); }\n"
	var brick := _standard("brick", Color(0.5, 0.4, 0.3))
	var brick_copy := brick.duplicate() as StandardMaterial3D
	var rougher := brick.duplicate() as StandardMaterial3D
	rougher.roughness += 0.01
	var renamed := brick.duplicate() as StandardMaterial3D
	renamed.resource_name = "brick_b"
	var shaded := ShaderMaterial.new()
	shaded.shader = shader
	shaded.set_shader_parameter("amount", 1.0)
	var shaded_copy := shaded.duplicate() as ShaderMaterial
	var shaded_other := shaded.duplicate() as ShaderMaterial
	shaded_other.set_shader_parameter("amount", 2.0)
	var image := Image.create_empty(4, 4, false, Image.FORMAT_RGBA8)
	var textured := _standard("textured", Color.WHITE)
	textured.albedo_texture = ImageTexture.create_from_image(image)
	var textured_alike := textured.duplicate() as StandardMaterial3D
	textured_alike.albedo_texture = ImageTexture.create_from_image(image)
	# Two materials whose next passes are equal copies.
	var outline := _standard("outline", Color.BLACK)
	var outline_copy := outline.duplicate() as StandardMaterial3D
	var outlined := _standard("outlined", Color.RED)
	outlined.next_pass = outline
	var outlined_copy := outlined.duplicate() as StandardMaterial3D
	outlined_copy.next_pass = outline_copy
	# Scripted materials, equal in every value, stay apart.
	var material_script := GDScript.new()
	material_script.source_code = "extends StandardMaterial3D\n"
	material_script.reload()
	var scripted := _standard("scripted", Color.BLUE)
	scripted.set_script(material_script)
	var scripted_copy := _standard("scripted", Color.BLUE)
	scripted_copy.set_script(material_script)
	# Materials and a mesh saved in files of their own.
	var filed := _filed(_standard("filed", Color.GREEN), "user://material_sharing_contract_a.res") as StandardMaterial3D
	var filed_alike := _filed(_standard("filed", Color.GREEN), "user://material_sharing_contract_b.res") as StandardMaterial3D
	var filed_copy := filed.duplicate() as StandardMaterial3D
	var mesh_file := _filed(_mesh([brick.duplicate()]), "user://material_sharing_contract_mesh.res") as ArrayMesh
	var in_mesh_file := mesh_file.surface_get_material(0)
	var boxed := BoxMesh.new()
	boxed.material = brick.duplicate()

	var first := _instance(holder, _mesh([brick, shaded, outlined]))
	var second := _instance(holder, _mesh([renamed, outlined_copy]))
	second.material_override = brick_copy
	second.material_overlay = shaded_copy
	second.set_surface_override_material(0, rougher)
	var instances := MultiMeshInstance3D.new()
	instances.multimesh = MultiMesh.new()
	instances.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	instances.multimesh.mesh = _mesh([shaded_other, textured, textured_alike, filed_copy])
	instances.multimesh.instance_count = 1
	holder.add_child(instances)
	var from_file := _instance(holder, mesh_file)
	from_file.material_override = filed
	var other_file := _instance(holder, _mesh([]))
	other_file.material_override = filed_alike
	var scripted_one := _instance(holder, _mesh([]))
	scripted_one.material_override = scripted
	var scripted_two := _instance(holder, _mesh([]))
	scripted_two.material_override = scripted_copy
	var box := _instance(holder, boxed)
	# A walker finds the materials under `walked`: its two equal ones are shared, and an
	# equal one it doesn't find stays apart from them.
	var walked := Node3D.new()
	holder.add_child(walked)
	var found_one := _instance(walked, _mesh([]))
	found_one.material_override = brick.duplicate()
	var found_two := _instance(walked, _mesh([]))
	found_two.material_override = brick.duplicate()
	var not_found := _instance(holder, _mesh([]))
	not_found.material_override = brick.duplicate()
	var walker := func() -> Array:
		var materials: Array = []
		for node: Node in walked.get_children():
			materials.append((node as GeometryInstance3D).material_override)
		return materials

	var roots: Array[Node] = [holder]
	var places := _places(roots)
	var report := SHARE.share(roots, {"fixture": walker})
	_require((report.problems as PackedStringArray).is_empty(), "The sharing finds no problem in its own checks: %s" % [report.problems])
	var first_mesh := first.mesh
	var second_mesh := second.mesh
	var many := instances.multimesh.mesh
	_require(second.material_override == brick and second.material_overlay == shaded, "An override and an overlay equal to a mesh's materials point to them (%s, %s)." % [second.material_override, second.material_overlay])
	_require(second.get_surface_override_material(0) == rougher and second_mesh.surface_get_material(0) == renamed, "A material with one value or its name different keeps itself.")
	_require(outlined_copy.next_pass == outline and second_mesh.surface_get_material(1) == outlined and first_mesh.surface_get_material(2) == outlined, "Next passes are shared first, so materials whose next passes were equal copies are shared too.")
	_require(many.surface_get_material(0) == shaded_other, "A shader material with another parameter value keeps itself.")
	_require(many.surface_get_material(1) == textured and many.surface_get_material(2) == textured_alike, "Two materials with alike but distinct textures stay apart.")
	_require(many.surface_get_material(3) == filed and from_file.material_override == filed and other_file.material_override == filed_alike, "A copy of a material saved in its own file points to that file's; two such files stay apart.")
	_require(mesh_file.surface_get_material(0) == in_mesh_file and in_mesh_file != brick, "A mesh saved in its own file keeps its materials.")
	_require(scripted_one.material_override == scripted and scripted_two.material_override == scripted_copy, "Scripted materials are never shared.")
	_require(box.mesh == boxed and boxed.material == brick, "A PrimitiveMesh's material is shared too.")
	_require(found_one.material_override == found_two.material_override and found_one.material_override != brick, "A walker's equal materials are shared among themselves, apart from equal ones it doesn't find.")
	_require(not_found.material_override == brick, "An equal material no walker finds joins the others no walker finds.")
	var after := _places(roots)
	_require(after.size() == places.size(), "Sharing keeps every reference (%d before, %d after)." % [places.size(), after.size()])
	for place: String in places:
		_require(after.get(place, "") == places[place], "%s points to a material equal to its own." % place)
	for path: String in ["user://material_sharing_contract_a.res", "user://material_sharing_contract_b.res", "user://material_sharing_contract_mesh.res"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	holder.free()


## The bake's own walkers on a hand-built world: daylight fills under the buildings, and
## the ground cover the ground dressing's captures copy.
func _check_walkers() -> void:
	var world := FakeWorld.new()
	root.add_child(world)
	var lobby := _instance(world.buildings, _mesh([_fill()]))
	var lobby_two := _instance(world.buildings, _mesh([_fill()]))
	var fill_outside := _instance(world.ground_and_areas, _mesh([_fill()]))
	var lawn := GROUND_COVER.material("lawn").duplicate() as ShaderMaterial
	var ground := _instance(world.ground_and_areas, _mesh([lawn]))
	var road := _instance(world.roads_and_paths, _mesh([lawn.duplicate()]))
	var yard := _instance(world.buildings, _mesh([lawn.duplicate()]))
	var hidden := _instance(world.ground_and_areas, _mesh([lawn.duplicate()]))
	hidden.hide()
	var furniture := _instance(world.street_detail.get_node("Furniture"), _mesh([lawn.duplicate()]))
	# What the ground dressing writes in play is what the bake's walker finds, before
	# sharing and after.
	_require(_dressed(world) == _set_of(SHARE.walked(SHARE.LAWN_THREADS, world)), "The lawn threads walker finds the ground cover the dressing writes, before sharing.")
	var roots: Array[Node] = [world]
	var report := SHARE.share(roots, SHARE.world_walkers(world))
	_require((report.problems as PackedStringArray).is_empty(), "The bake's walkers: the sharing finds no problem in its own checks: %s" % [report.problems])
	var shared_fill := _material_of(lobby)
	_require(_material_of(lobby_two) == shared_fill and _material_of(fill_outside) != shared_fill, "Equal daylight fills under the buildings are shared, and an equal copy elsewhere is not.")
	_require(SHARE.walked(SHARE.DAYLIGHT_FILLS, world) == [shared_fill], "DaySun finds the one shared fill.")
	var shared_lawn := _material_of(ground)
	_require(_material_of(road) == shared_lawn and _material_of(yard) == shared_lawn, "The ground cover the captures copy is shared among itself.")
	_require(_material_of(hidden) != shared_lawn and _material_of(furniture) != shared_lawn and _material_of(hidden) == _material_of(furniture), "Equal ground cover the captures don't copy stays apart from it, shared among itself.")
	var dressed := _dressed(world)
	_require(dressed == _set_of(SHARE.walked(SHARE.LAWN_THREADS, world)) and dressed.size() == 1, "The lawn threads walker finds the ground cover the dressing writes, after sharing.")
	# So the dressing's write in play (_set_lawn_threads) reaches the meshes the captures
	# copy, and only them, as before.
	for mesh: MeshInstance3D in [ground, road, yard, hidden, furniture]:
		_require(dressed.has(_material_of(mesh)) == (mesh in [ground, road, yard]), "The lawn threads reach %s only if the captures copy it." % mesh.get_path())
	world.free()


## The ground cover a ground dressing configured on world writes in play (its
## _ground_materials, which _set_lawn_threads writes).
func _dressed(world: Node3D) -> Dictionary:
	var dressing := _dressing(world)
	var found := (dressing._ground_materials as Dictionary).duplicate()
	dressing.free()
	return found


func _dressing(world: Node3D) -> GROUND_DRESSING:
	var dressing: GROUND_DRESSING = GROUND_DRESSING.new()
	root.add_child(dressing)
	dressing.configure(world, null, "medium")
	return dressing


static func _set_of(materials: Array) -> Dictionary:
	var found := {}
	for material: Material in materials:
		found[material] = true
	return found


static func _material_of(instance: MeshInstance3D) -> Material:
	return instance.get_active_material(0)


## Every reference under roots as its place -> what the material there is (_deep_key).
static func _places(roots: Array[Node]) -> Dictionary:
	var places := {}
	for reference: Array in SHARE._references(roots).references:
		places["%s %s" % [reference[0], reference[1]]] = _deep_key(reference[4])
	return places


## A material's values, its next pass's values in place of which one it is.
static func _deep_key(material: Material) -> String:
	if material == null:
		return "none"
	return MERGE_BUILDINGS.value_key(material, SHARE.IGNORED + ["next_pass"]) + "|next " + _deep_key(material.next_pass)


## A daylight fill, as a building family makes one (DaySun.NIGHT_ROLE).
static func _fill() -> StandardMaterial3D:
	var fill := _standard("lobby_glow", Color.WHITE)
	fill.emission_enabled = true
	fill.set_meta(DaySun.NIGHT_ROLE, DaySun.DAYLIGHT_FILL)
	return fill


static func _standard(material_name: String, colour: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = material_name
	material.albedo_color = colour
	material.roughness = 0.8
	return material


## A mesh with one triangle surface per material.
static func _mesh(materials: Array) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	for material: Material in materials:
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([Vector3.ZERO, Vector3.RIGHT, Vector3.FORWARD])
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh.surface_set_material(mesh.get_surface_count() - 1, material)
	return mesh


static func _instance(parent: Node, mesh: Mesh) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	parent.add_child(instance)
	return instance


## resource saved to path and loaded back: a resource in a file of its own.
func _filed(resource: Resource, path: String) -> Resource:
	_require(ResourceSaver.save(resource, path) == OK, "Saved %s." % path)
	return ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)


## Every function that writes materials is classified; the classifications name writers.
## Returns a summary, or "" after failing.
func _check_scan() -> String:
	var pattern := _writes()
	for line: String in WRITE_SPELLINGS + NOT_WRITES:
		var found := _writers("func f():\n\t%s\n" % line, pattern).size()
		if not _require(found == (1 if line in WRITE_SPELLINGS else 0), "The writer scan finds %d writes in `%s`." % [found, line]):
			return ""
	var runtime := RegEx.create_from_string(RUNTIME_CALLBACKS)
	var unclassified: Array[String] = []
	var in_play: Array[String] = []
	var used := {}
	var writers := 0
	var files := 0
	for path: String in _scripts(SCRIPTS_ROOT):
		if path.begins_with(TESTS_ROOT):
			continue
		var written := _writers(FileAccess.get_file_as_string(path), pattern)
		if written.is_empty():
			continue
		files += 1
		for writer: Array in written:
			writers += 1
			var function := str(writer[0])
			var key := _classification(path, function)
			if key.is_empty():
				unclassified.append("%s (%s: %s)" % [path, function, writer[1]])
				continue
			used[key] = true
			if BUILDS.has(key) and not key.contains("::") and runtime.search(function) != null:
				in_play.append("%s (%s: %s)" % [path, function, writer[1]])
	if not unclassified.is_empty():
		_require(false, "These functions write materials but are not classified in game/tests/headless_material_sharing_contract.gd (BUILDS: while the island loads or bakes; OWN: in play only materials they make or copy, or the baked world doesn't hold; WALKS: in play what a walker of tools/share_baked_materials.gd finds): %s" % [unclassified])
		return ""
	if not in_play.is_empty():
		_require(false, "These writers are inside callbacks Godot calls in play, in scripts classified as writing while the island loads or bakes (BUILDS): classify the function: %s" % [in_play])
		return ""
	var stale: Array[String] = []
	var tables: Array[Dictionary] = [BUILDS, OWN, WALKS]
	var seen := {}
	for table: Dictionary in tables:
		for key: String in table:
			if seen.has(key):
				stale.append(key + " (classified twice)")
			seen[key] = true
			if not used.has(key):
				stale.append(key)
	if not stale.is_empty():
		_require(false, "These classifications name no writer of materials (or are gone): %s" % [stale])
		return ""
	var walked := {}
	for key: String in WALKS:
		walked[WALKS[key]] = true
		if not SHARE.WALKERS.has(WALKS[key]):
			_require(false, "%s writes what the walker \"%s\" finds, which tools/share_baked_materials.gd has no walker of (WALKERS: %s)." % [key, WALKS[key], SHARE.WALKERS])
			return ""
	for walker: String in SHARE.WALKERS:
		if not walked.has(walker):
			_require(false, "tools/share_baked_materials.gd's walker \"%s\" names no writer here (WALKS)." % walker)
			return ""
	return "%d writes of materials in %d scripts, each classified (%d functions write what the bake's walkers find)" % [writers, files, WALKS.size()]


## The classification of a writer: its function's, else its file's, else its folder's
## key ("" when none).
static func _classification(path: String, function: String) -> String:
	var tables: Array[Dictionary] = [BUILDS, OWN, WALKS]
	for table: Dictionary in tables:
		if table.has(path + "::" + function):
			return path + "::" + function
	for table: Dictionary in tables:
		if table.has(path):
			return path
	for table: Dictionary in tables:
		for key: String in table:
			if key.ends_with("/") and path.begins_with(key):
				return key
	return ""


## A material's values written: one of its properties (MATERIAL_CLASSES', as the engine
## lists them, its name among them) or a component of one assigned, or set by name
## (set, set_deferred, set_indexed) or with a tween (tween_property), a shader parameter
## set, or a RenderingServer material call.
static func _writes() -> RegEx:
	var names := {}
	for type: String in MATERIAL_CLASSES:
		for property: Dictionary in ClassDB.class_get_property_list(type):
			var usage := int(property.usage)
			if usage & PROPERTY_USAGE_STORAGE != 0 and usage & (PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SUBGROUP | PROPERTY_USAGE_CATEGORY) == 0:
				names[str(property.name)] = true
	for unwritten: String in ["resource_path", "resource_scene_unique_id", "resource_local_to_scene", "script"]:
		names.erase(unwritten)
	var alternatives := "|".join(PackedStringArray(names.keys()))
	var by_name := "&?\"(?:shader_parameter/|(?:%s)[:\"])" % alternatives
	return RegEx.create_from_string("\\bset_shader_parameter\\(|\\bRenderingServer\\.material_\\w+\\(|\\.(?:set|set_deferred|set_indexed)\\(\\s*%s|\\btween_property\\(\\s*[^,]+,\\s*%s|\\.(?:%s)\\b(?:\\.\\w+)*\\s*[-+*/]?=(?!=)" % [by_name, by_name, alternatives])


## Each write in a script's source (a match not on a comment line): [the function it is
## in ("" at the script's top level), the text matched].
static func _writers(source: String, pattern: RegEx) -> Array:
	var functions := RegEx.create_from_string("(?m)^(?:static\\s+)?func\\s+(\\w+)")
	var starts: Array = []
	for found: RegExMatch in functions.search_all(source):
		starts.append([found.get_start(), found.get_string(1)])
	var written: Array = []
	for found: RegExMatch in pattern.search_all(source):
		var line_start := source.rfind("\n", found.get_start()) + 1
		if source.substr(line_start, found.get_start() - line_start).strip_edges().begins_with("#"):
			continue
		var function := ""
		for start: Array in starts:
			if int(start[0]) < found.get_start():
				function = str(start[1])
		written.append([function, found.get_string()])
	return written


static func _scripts(folder: String) -> Array[String]:
	var paths: Array[String] = []
	for file: String in DirAccess.get_files_at(folder):
		if file.ends_with(".gd"):
			paths.append(folder.path_join(file))
	for sub: String in DirAccess.get_directories_at(folder):
		paths.append_array(_scripts(folder.path_join(sub)))
	return paths
