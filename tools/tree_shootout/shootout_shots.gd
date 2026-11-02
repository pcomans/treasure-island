extends SceneTree
## Tree shootout (2026-11-02, evaluation only). In the real loaded island at
## Building 1's Avenue of the Palms frontage, captures matched views of a row of
## Mexican fan palms and a grove of Monterey cypresses for each variant:
##   A  the parametric trees (game/scripts/vegetation/shootout_tree_builder.gd)
##   B  Sketchfab CC-BY models, when downloaded to game/resources/_eval/sketchfab/
## Every variant is shot from the same camera; only the trees change. The
## island's existing vegetation, the HUD and the player avatar are hidden.
## --perf adds narrow local measurements with about 300 trees per variant.
##
##   tools/godot [--rendering-method gl_compatibility --rendering-driver opengl3] --path . \
##     --resolution 1600x900 --script tools/tree_shootout/shootout_shots.gd -- --out DIR [--perf]
##
## Writes DIR/<species>-<view>-<variant>.png, DIR/<species>-lod-*.png and DIR/metrics.json.

const WorldHarness := preload("res://game/tests/shared/world_harness.gd")
const Builder := preload("res://game/scripts/vegetation/shootout_tree_builder.gd")

## Avenue of the Palms frontage: the west edge of Building 1's parking lot
## (OSM w96665914), running NNE from (-89.8, 744.9) to (-61.6, 795.5).
const FRONT_START := Vector2(-89.8, 744.9)
const FRONT_END := Vector2(-61.6, 795.5)
## Street View cameras of the dated references (Sep 2025), as world x/z, plus
## heading (degrees from north), pitch (degrees up) and vertical field of view.
const REFERENCE_VIEWS := {
	"palm": {"xz": Vector2(-93.2, 763.8), "heading": 55.0, "pitch": 6.0, "fov": 75.0, "photo": "building1-references/public-wsw-sep2025.png"},
	"cypress": {"xz": Vector2(-66.8, 802.8), "heading": 55.0, "pitch": 6.0, "fov": 75.0, "photo": "building1-references/southwest-sep2025.png"},
}
## Hero cypress and grove, on the open ground south of Building 1's south pavilion.
const CYPRESS_HERO := Vector2(-22.0, 818.0)
const CYPRESS_GROVE := [
	Vector2(0.0, 0.0), Vector2(13.0, 3.0), Vector2(-12.0, 6.0), Vector2(26.0, -1.0),
	Vector2(6.0, 11.0), Vector2(39.0, 2.0), Vector2(19.0, 10.0), Vector2(-24.0, 9.0),
	Vector2(52.0, 4.0), Vector2(32.0, 11.0), Vector2(-36.0, 3.0), Vector2(-6.0, -9.0),
]
## Sketchfab downloads (variant B), one folder per model under _eval/.
const SKETCHFAB := {
	"palm": "res://game/resources/_eval/sketchfab/palm/",
	"cypress": "res://game/resources/_eval/sketchfab/cypress/",
}
const B_TRIANGLE_BUDGET := {"palm": 12000, "cypress": 15000}
const FORMAT_NAMES := {Image.FORMAT_RGB8: "RGB8", Image.FORMAT_RGBA8: "RGBA8", Image.FORMAT_DXT1: "DXT1 (BC1)", Image.FORMAT_DXT5: "DXT5 (BC3)", Image.FORMAT_BPTC_RGBA: "BPTC (BC7)", Image.FORMAT_ETC2_RGB8: "ETC2 RGB", Image.FORMAT_ETC2_RGBA8: "ETC2 RGBA", Image.FORMAT_ASTC_4x4: "ASTC 4x4"}

var _h: WorldHarness
var _builder := Builder.new()
var _out := ""
var _camera: Camera3D
var _errors: Array[String] = []
var _metrics := {"views": {}, "variants": {}, "perf": {}, "sites": {}}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := WorldHarness.user_args()
	_out = str(args.get("out", ""))
	if _out == "":
		_fail("usage: -- --out DIR [--perf]")
		return
	DirAccess.make_dir_recursive_absolute(_out)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	_h = WorldHarness.new(self)
	var error := await _h.load_world()
	if error != "":
		_fail(error)
		return
	_metrics.renderer = {
		"method": RenderingServer.get_current_rendering_method(),
		"adapter": RenderingServer.get_video_adapter_name(),
		"display": DisplayServer.get_name(),
		"resolution": [root.size.x, root.size.y],
	}
	print("RENDERER: %s" % JSON.stringify(_metrics.renderer))
	(_h.world.get_node("PlayableWorld/Vegetation") as Node3D).visible = false
	(_h.player.get_node("AvatarPivot") as Node3D).visible = false
	(_h.main.get_node("Interface") as CanvasLayer).visible = false
	_camera = Camera3D.new()
	_camera.near = 0.08
	_camera.far = 5000.0
	_h.main.add_child(_camera)
	for species: String in ["palm", "cypress"]:
		await _species_shots(species)
		if not _errors.is_empty():
			break
	if _errors.is_empty() and args.has("perf"):
		await _perf()
	var file := FileAccess.open(_out.path_join("metrics.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(_metrics, "  "))
	file.close()
	if _errors.is_empty():
		print("PASS: tree shootout captures in %s" % _out)
	for message in _errors:
		push_error(message)
	_h.main.queue_free()
	quit(0 if _errors.is_empty() else 1)


# --- Sites and trees ------------------------------------------------------------


func _sites(species: String) -> Array[Vector3]:
	var spots: Array[Vector2] = []
	if species == "palm":
		var along := (FRONT_END - FRONT_START).normalized()
		var west := Vector2(-along.y, along.x)
		# The hero (first) stands where the reference photo's palms are.
		for s: float in [16.0, -12.0, -5.0, 2.0, 9.0, 23.0, 30.0, 37.0, 44.0, 51.0, 58.0, 65.0]:
			spots.append(FRONT_START + along * s + west * 0.8)
	else:
		for offset: Vector2 in CYPRESS_GROVE:
			spots.append(CYPRESS_HERO + offset)
	var sites: Array[Vector3] = []
	var notes := []
	for spot in spots:
		var hit := _h.ray(Vector3(spot.x, 300.0, spot.y), Vector3(spot.x, -50.0, spot.y), _h.player.collision_mask)
		if hit.is_empty() or not _h.is_walkable_ground(hit):
			notes.append({"xz": [spot.x, spot.y], "skipped": _ground_name(hit)})
			continue
		sites.append(hit.position)
		notes.append({"xz": [spot.x, spot.y], "y": (hit.position as Vector3).y, "ground": _ground_name(hit)})
	_metrics.sites[species] = notes
	print("SITES %s %s" % [species, JSON.stringify(notes)])
	return sites


func _ground_name(hit: Dictionary) -> String:
	if hit.is_empty():
		return "none"
	var record := (hit.collider as Node).get_parent()
	return "%s %s" % [str(record.get_meta("feature_kind", "?")), str(record.name)]


## Variant A: a row/grove of parametric trees. Seeds vary per site.
func _variant_a(species: String, sites: Array[Vector3]) -> Dictionary:
	var root := Node3D.new()
	root.name = "VariantA_" + species
	var trees := []
	for i in sites.size():
		var overrides := {"seed": 101 + i}
		if species == "palm":
			# Treasure Island's fan palms are mostly trimmed: short skirts or none.
			overrides.merge({"height": [17.0, 15.5, 18.5, 16.2, 19.0, 14.8][i % 6], "skirt_length": [1.5, 0.0, 1.9, 0.9, 0.0, 1.2][i % 6]})
			if float(overrides.skirt_length) <= 0.0:
				overrides.skirt = false
		else:
			overrides.merge({"height": [13.0, 11.5, 14.0, 12.2][i % 4], "spread": [17.0, 14.5, 18.5, 15.5][i % 4], "leaders": [4, 3, 4, 5][i % 4]})
		var tree := _builder.build(species, overrides)
		var node := _builder.tree_node(tree)
		node.position = sites[i]
		root.add_child(node)
		trees.append(tree)
	_h.main.add_child(root)
	return {"root": root, "hero": trees[0], "trees": trees}


## Variant B: the downloaded Sketchfab model, scaled to the variant-A tree's
## height and reduced to a game budget with Godot's own LOD generation.
func _variant_b(species: String, sites: Array[Vector3], target_height: float) -> Dictionary:
	var path := _sketchfab_scene(species)
	if path == "":
		print("NOTE: variant B %s has no downloaded model under %s" % [species, SKETCHFAB[species]])
		return {}
	var scene := load(path) as PackedScene
	if scene == null:
		_errors.append("could not load " + path)
		return {}
	var source := scene.instantiate() as Node3D
	var converted := _scissor_materials(source)
	var raw := _mesh_stats(source)
	var reduced := source.duplicate() as Node3D
	var reduction := _reduce(reduced, int(B_TRIANGLE_BUDGET[species]))
	var box := _node_bounds(source)
	var scale := target_height / maxf(box.size.y, 0.01)
	var root := Node3D.new()
	root.name = "VariantB_" + species
	var raw_hero: Node3D
	for i in sites.size():
		var holder := Node3D.new()
		holder.position = sites[i]
		holder.rotation.y = i * 2.39996
		var copy := reduced.duplicate() as Node3D
		copy.scale = Vector3.ONE * scale
		copy.position = -Vector3(box.get_center().x, box.position.y, box.get_center().z) * scale
		holder.add_child(copy)
		root.add_child(holder)
		if i == 0:
			raw_hero = source.duplicate() as Node3D
			raw_hero.scale = copy.scale
			raw_hero.position = copy.position
			raw_hero.visible = false
			# The raw model as downloaded: keep Godot's automatic mesh LOD off.
			for instance in raw_hero.find_children("*", "MeshInstance3D", true, false):
				(instance as GeometryInstance3D).lod_bias = 1000.0
			holder.add_child(raw_hero)
	_h.main.add_child(root)
	source.free()
	reduced.free()
	_metrics.variants["B_" + species] = {"scene": path, "scale": scale, "raw": raw, "reduced": reduction, "blend_to_scissor_surfaces": converted}
	return {"root": root, "raw_hero": raw_hero}


func _sketchfab_scene(species: String) -> String:
	var dir := DirAccess.open(SKETCHFAB[species])
	if dir == null:
		return ""
	for file in dir.get_files():
		if file.get_extension().to_lower() in ["glb", "gltf"]:
			return SKETCHFAB[species].path_join(file)
	return ""


# --- Views ---------------------------------------------------------------------


func _species_shots(species: String) -> void:
	var sites := _sites(species)
	if sites.size() < 6:
		_errors.append("%s: only %d usable tree sites" % [species, sites.size()])
		return
	var a := _variant_a(species, sites)
	var hero: Dictionary = a.hero
	var hero_box: AABB = (hero.lod0 as ArrayMesh).get_aabb()
	var target_height := hero_box.end.y
	var b := _variant_b(species, sites, target_height)
	var variants := {"A": a.root}
	if not b.is_empty():
		variants["B"] = b.root
	_metrics.variants["A_" + species] = _a_stats(species, hero)
	var base: Vector3 = sites[0]
	var crown := base + (hero.crown as Vector3)
	var reference: Dictionary = REFERENCE_VIEWS[species]
	# Views look from the reference camera's side, so Building 1 is behind the trees.
	var toward_camera := (reference.xz as Vector2 - Vector2(base.x, base.z)).normalized()
	var reach := maxf(hero_box.size.x, hero_box.size.z) * 0.5 if species == "cypress" else 0.0
	var mid_height := target_height * 0.5
	var views := []
	views.append(["ref", _reference_pose(reference, base)])
	# Aimed level with the camera pivot (about 2 m up), so the stock spring arm
	# keeps its normal height instead of dropping toward the ground.
	views.append(["close", await _gameplay_pose(base, toward_camera, 6.0 + reach, base + Vector3(0.0, 2.0 if species == "palm" else 3.0, 0.0))])
	var crown_eye := crown + Vector3(toward_camera.x, 0.0, toward_camera.y) * (9.0 + reach) + Vector3(0.0, 0.3 if species == "palm" else -0.5, 0.0)
	views.append(["crown", _free_pose(crown_eye, crown, 70.0)])
	views.append(["mid", await _gameplay_pose(base, toward_camera, 25.0, base + Vector3(0.0, mid_height, 0.0))])
	views.append(["far", await _gameplay_pose(base, toward_camera, 90.0, base + Vector3(0.0, mid_height, 0.0))])
	var row_center := Vector3.ZERO
	for site in sites:
		row_center += site
	row_center /= sites.size()
	var row_side := Vector2(toward_camera.x, toward_camera.y)
	var row_eye := row_center + Vector3(row_side.x, 0.0, row_side.y) * 46.0 + Vector3(0.0, 30.0, 0.0)
	views.append(["row", _free_pose(row_eye, row_center + Vector3(0.0, mid_height * 0.6, 0.0), 60.0)])
	for view: Array in views:
		var pose: Dictionary = view[1]
		if pose.is_empty():
			_errors.append("%s %s: no usable camera pose" % [species, view[0]])
			continue
		_apply_pose(pose)
		_metrics.views["%s-%s" % [species, view[0]]] = _pose_record(pose, base, a.root)
		for variant: String in variants:
			_show_only(variants, variant)
			await _shoot("%s-%s-%s" % [species, view[0], variant])
	# LOD strip: the same raised camera on the hero with each LOD forced.
	_show_only(variants, "A")
	var strip_eye := crown + Vector3(toward_camera.x, 0.0, toward_camera.y) * (22.0 + reach * 1.5) - Vector3(0.0, target_height * 0.35, 0.0)
	_apply_pose(_free_pose(strip_eye, base + Vector3(0.0, target_height * 0.55, 0.0), 52.0))
	var hero_node := (a.root as Node3D).get_child(0)
	for other in (a.root as Node3D).get_children():
		(other as Node3D).visible = other == hero_node
	for lod in hero_node.get_children():
		var keep := {"begin": lod.visibility_range_begin, "end": lod.visibility_range_end}
		for sibling in hero_node.get_children():
			sibling.visible = sibling == lod
		lod.visibility_range_begin = 0.0
		lod.visibility_range_end = 0.0
		await _shoot("%s-lod-%s-A" % [species, str(lod.name).to_lower()])
		lod.visibility_range_begin = keep.begin
		lod.visibility_range_end = keep.end
	for sibling in hero_node.get_children():
		sibling.visible = true
	for other in (a.root as Node3D).get_children():
		(other as Node3D).visible = true
	if not b.is_empty():
		_show_only(variants, "B")
		var b_hero := (b.root as Node3D).get_child(0)
		for other in (b.root as Node3D).get_children():
			(other as Node3D).visible = other == b_hero
		await _shoot("%s-lod-reduced-B" % species)
		(b_hero.get_child(0) as Node3D).visible = false
		(b.raw_hero as Node3D).visible = true
		await _shoot("%s-lod-raw-B" % species)
	for variant: String in variants:
		(variants[variant] as Node3D).queue_free()
	await process_frame


func _show_only(variants: Dictionary, chosen: String) -> void:
	for variant: String in variants:
		(variants[variant] as Node3D).visible = variant == chosen


## A camera matching a Street View reference: its position, heading, pitch and
## field of view, at a car-mounted camera height above the local ground.
func _reference_pose(reference: Dictionary, base: Vector3) -> Dictionary:
	var xz: Vector2 = reference.xz
	var hit := _h.ray(Vector3(xz.x, 300.0, xz.y), Vector3(xz.x, -50.0, xz.y))
	var ground := (hit.position as Vector3).y if not hit.is_empty() else base.y
	var heading := deg_to_rad(float(reference.heading))
	var pitch := deg_to_rad(float(reference.pitch))
	var forward := Vector3(sin(heading) * cos(pitch), sin(pitch), -cos(heading) * cos(pitch))
	var eye := Vector3(xz.x, ground + 2.5, xz.y)
	var pose := _free_pose(eye, eye + forward * 10.0, float(reference.fov))
	pose.kind = "reference-matched free camera"
	return pose


func _free_pose(eye: Vector3, target: Vector3, fov: float) -> Dictionary:
	return {"kind": "free camera", "transform": Transform3D(Basis.IDENTITY, eye).looking_at(target, Vector3.UP), "fov": fov, "target": target}


## The stock gameplay camera: settle the player so the camera ends up about
## camera_distance from the tree, aim it with the stock rig, let the spring arm
## settle, and copy its final transform. Tries other directions, nearest
## first, when the spot is off the island or the view is blocked.
func _gameplay_pose(base: Vector3, direction: Vector2, camera_distance: float, aim: Vector3) -> Dictionary:
	var arm := (_h.player.get_node("CameraPivot/SpringArm3D") as SpringArm3D).spring_length
	for turn: float in [0.0, 0.3, -0.3, 0.6, -0.6, 0.9, -0.9, 1.2, -1.2, 1.5, -1.5, 1.8, -1.8, 2.1, -2.1, 2.4, -2.4, 2.8, -2.8, PI]:
		var toward := direction.rotated(turn)
		var player_xz := Vector2(base.x, base.z) + toward * maxf(camera_distance - arm, 0.9)
		if await _h.settle_player(player_xz) != "":
			continue
		_h.aim_camera(aim)
		for _i in 6:
			await physics_frame
		var camera := _h.player.get_camera()
		var hit := _h.ray(camera.global_position, aim)
		if not hit.is_empty():
			continue
		return {"kind": "stock gameplay camera", "transform": camera.global_transform, "fov": camera.fov, "target": aim, "player": _h.player.global_position, "turn": turn}
	return {}


func _apply_pose(pose: Dictionary) -> void:
	_camera.global_transform = pose.transform
	_camera.fov = pose.fov
	_camera.make_current()


func _pose_record(pose: Dictionary, base: Vector3, root: Node3D) -> Dictionary:
	var eye: Vector3 = (pose.transform as Transform3D).origin
	var record := {"kind": pose.kind, "eye": [eye.x, eye.y, eye.z], "fov": pose.fov, "distance_to_hero_m": snappedf(Vector2(eye.x - base.x, eye.z - base.z).length(), 0.1)}
	var target: Vector3 = pose.target
	record.target = [target.x, target.y, target.z]
	# Which LOD the hero shows here (Godot measures from the camera to the AABB centre).
	var hero := root.get_child(0)
	for lod in hero.get_children():
		var instance := lod as GeometryInstance3D
		var distance := eye.distance_to(instance.global_transform * (instance as MeshInstance3D).mesh.get_aabb().get_center())
		if distance >= instance.visibility_range_begin and (instance.visibility_range_end <= 0.0 or distance < instance.visibility_range_end):
			record.hero_lod = str(lod.name)
	if pose.has("player"):
		var player: Vector3 = pose.player
		record.player = [player.x, player.y, player.z]
	return record


func _shoot(name: String) -> void:
	var error := await _h.save_screenshot(_out.path_join(name + ".png"))
	if error != "":
		_errors.append(error)
	else:
		print("SHOT %s" % name)


# --- Metrics ---------------------------------------------------------------------


func _a_stats(species: String, tree: Dictionary) -> Dictionary:
	var stats := {"lod0": _triangles(tree.lod0), "lod1": _triangles(tree.lod1)}
	var impostor := _builder.impostor_mesh(tree)
	if impostor != null:
		stats.impostor = _triangles(impostor)
	stats.draw_surfaces = {"lod0": (tree.lod0 as ArrayMesh).get_surface_count(), "lod1": (tree.lod1 as ArrayMesh).get_surface_count(), "impostor": impostor.get_surface_count() if impostor != null else 0}
	stats.ranges_m = Builder.PALM_RANGES if species == "palm" else Builder.CYPRESS_RANGES
	stats.ranges_m = [stats.ranges_m.x, stats.ranges_m.y, stats.ranges_m.z]
	var textures := {}
	for mesh: ArrayMesh in [tree.lod0, impostor] if impostor != null else [tree.lod0]:
		for surface in mesh.get_surface_count():
			_collect_textures(mesh.surface_get_material(surface), textures)
	stats.textures = _texture_stats(textures)
	return stats


func _triangles(mesh: Mesh) -> int:
	var count := 0
	for surface in mesh.get_surface_count():
		var arrays := mesh.surface_get_arrays(surface)
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		count += (indices.size() if not indices.is_empty() else (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()) / 3
	return count


func _collect_textures(material: Material, textures: Dictionary) -> void:
	if material is BaseMaterial3D:
		for slot in BaseMaterial3D.TEXTURE_MAX:
			var texture := (material as BaseMaterial3D).get_texture(slot)
			if texture != null:
				textures[texture.resource_path if texture.resource_path != "" else str(texture.get_rid())] = texture
	elif material is ShaderMaterial:
		for uniform: Dictionary in (material as ShaderMaterial).shader.get_shader_uniform_list():
			var value: Variant = (material as ShaderMaterial).get_shader_parameter(uniform.name)
			if value is Texture2D:
				textures[(value as Texture2D).resource_path if (value as Texture2D).resource_path != "" else str((value as Texture2D).get_rid())] = value


## Size of each texture as stored for the GPU (format and mipmaps included).
func _texture_stats(textures: Dictionary) -> Dictionary:
	var list := []
	var total := 0
	for key: String in textures:
		var texture: Texture2D = textures[key]
		var image := texture.get_image()
		var bytes := image.get_data_size() if image != null else 0
		total += bytes
		var format: String = FORMAT_NAMES.get(image.get_format(), str(image.get_format())) if image != null else "none"
		list.append({"texture": key, "size": [texture.get_width(), texture.get_height()], "format": format, "mipmaps": image.has_mipmaps() if image != null else false, "bytes": bytes})
	return {"list": list, "total_bytes": total}


func _mesh_stats(node: Node) -> Dictionary:
	var triangles := 0
	var surfaces := 0
	var textures := {}
	for instance in node.find_children("*", "MeshInstance3D", true, false):
		var mesh := (instance as MeshInstance3D).mesh
		if mesh == null:
			continue
		triangles += _triangles(mesh)
		surfaces += mesh.get_surface_count()
		for surface in mesh.get_surface_count():
			var material := (instance as MeshInstance3D).get_active_material(surface)
			if material != null:
				_collect_textures(material, textures)
	return {"triangles": triangles, "draw_surfaces": surfaces, "textures": _texture_stats(textures)}


## Exact bounds of the vertices under node, in node's own space. A transformed
## mesh AABB is only conservative: the Umbrella Pine's rotated leaf node gave a box
## reaching 1.7 m below the trunk base, which lifted the whole tree off the ground.
func _node_bounds(node: Node3D) -> AABB:
	var box := AABB()
	var first := true
	for instance in node.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := instance as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		var transform := Transform3D.IDENTITY
		var walker: Node = mesh_instance
		while walker != node and walker is Node3D:
			transform = (walker as Node3D).transform * transform
			walker = walker.get_parent()
		for surface in mesh_instance.mesh.get_surface_count():
			var vertices: PackedVector3Array = mesh_instance.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
			for vertex in vertices:
				var point := transform * vertex
				if first:
					box = AABB(point, Vector3.ZERO)
					first = false
				else:
					box = box.expand(point)
	return box


## Game-ready materials for variant B: blended foliage (glTF BLEND) becomes
## alpha scissor, as in variant A, so it sorts and casts shadows like game foliage.
func _scissor_materials(node: Node) -> int:
	var converted := 0
	for instance in node.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := instance as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		for surface in mesh_instance.mesh.get_surface_count():
			var material := mesh_instance.get_active_material(surface) as BaseMaterial3D
			# Godot imports glTF BLEND as alpha with a depth pre-pass.
			if material == null or material.transparency not in [BaseMaterial3D.TRANSPARENCY_ALPHA, BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS]:
				continue
			var scissor := material.duplicate() as BaseMaterial3D
			scissor.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
			scissor.alpha_scissor_threshold = 0.5
			mesh_instance.set_surface_override_material(surface, scissor)
			converted += 1
	return converted


## Swaps every mesh under node for one of its Godot-generated LODs, choosing per
## surface the level nearest the share of the triangle budget. Coarser levels
## stay attached as the mesh's runtime LODs, as on any imported mesh.
func _reduce(node: Node, budget: int) -> Dictionary:
	var raw: int = _mesh_stats(node).triangles
	var share := minf(1.0, float(budget) / maxf(raw, 1.0))
	for instance in node.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := instance as MeshInstance3D
		var mesh := mesh_instance.mesh as ArrayMesh
		if mesh == null:
			continue
		var reduced := ArrayMesh.new()
		for surface in mesh.get_surface_count():
			var arrays := mesh.surface_get_arrays(surface)
			# Extra glTF texture coordinates arrive as custom channels, which
			# need their format flags to be re-added. StandardMaterial3D doesn't
			# read them, so drop them.
			for channel in [Mesh.ARRAY_CUSTOM0, Mesh.ARRAY_CUSTOM1, Mesh.ARRAY_CUSTOM2, Mesh.ARRAY_CUSTOM3]:
				arrays[channel] = null
			var importer := ImporterMesh.new()
			importer.add_surface(Mesh.PRIMITIVE_TRIANGLES, arrays, [], {}, mesh_instance.get_active_material(surface))
			importer.generate_lods(25.0, 60.0, [])
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			var wanted := indices.size() * share
			var best := indices
			for lod in importer.get_surface_lod_count(0):
				var candidate := importer.get_surface_lod_indices(0, lod)
				if absf(candidate.size() - wanted) < absf(best.size() - wanted):
					best = candidate
			var lods := {}
			for lod in importer.get_surface_lod_count(0):
				var candidate := importer.get_surface_lod_indices(0, lod)
				if candidate.size() < best.size():
					lods[importer.get_surface_lod_size(0, lod)] = candidate
			arrays[Mesh.ARRAY_INDEX] = best
			reduced.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, [], lods)
			reduced.surface_set_material(surface, mesh_instance.get_active_material(surface))
		mesh_instance.mesh = reduced
	var stats := _mesh_stats(node)
	stats.budget = budget
	return stats


# --- Performance ----------------------------------------------------------------


## About 300 trees per variant spread over the land around Building 1 and the
## ferry plaza, seen from a gameplay-height camera at the island's spawn point
## looking east, so near trees show LOD0, mid ones LOD1 and far ones impostors.
## Records median frame figures over a fixed number of frames.
func _perf() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261102
	var spawn := Vector3(-104.364, 0.0, 786.024)
	var candidates: Array[Vector2] = []
	for row in 23:
		for column in 21:
			candidates.append(Vector2(-200.0 + column * 12.0, 610.0 + row * 12.0) + Vector2(rng.randf_range(-3.0, 3.0), rng.randf_range(-3.0, 3.0)))
	# Deterministic shuffle, so the first 300 usable spots spread over the area.
	for i in range(candidates.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap := candidates[i]
		candidates[i] = candidates[j]
		candidates[j] = swap
	var spots: Array[Vector3] = []
	for xz in candidates:
		if spots.size() >= 300:
			break
		if xz.distance_to(Vector2(spawn.x, spawn.z)) < 9.0:
			continue
		var hit := _h.ray(Vector3(xz.x, 300.0, xz.y), Vector3(xz.x, -50.0, xz.y), _h.player.collision_mask)
		if not hit.is_empty() and _h.is_walkable_ground(hit):
			spots.append(hit.position)
	var ground := _h.ray(Vector3(spawn.x, 300.0, spawn.z), Vector3(spawn.x, -50.0, spawn.z))
	var eye := Vector3(spawn.x, ((ground.position as Vector3).y if not ground.is_empty() else 3.5) + 2.6, spawn.z)
	_apply_pose(_free_pose(eye, eye + Vector3(40.0, 3.0, -8.0), 70.0))
	_metrics.perf.trees = spots.size()
	_metrics.perf.camera = [eye.x, eye.y, eye.z]
	var viewport := root.get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(viewport, true)
	await _measure("none", null)
	for species: String in ["palm", "cypress"]:
		var pool := []
		for seed in 4:
			pool.append(_builder.build(species, {"seed": 301 + seed}))
		var field := Node3D.new()
		for i in spots.size():
			var node := _builder.tree_node(pool[i % pool.size()])
			node.position = spots[i]
			node.rotation.y = rng.randf() * TAU
			field.add_child(node)
		_h.main.add_child(field)
		await _measure("A_" + species, field)
		await _shoot("perf-%s-A" % species)
		for node in field.get_children():
			for lod in node.get_children():
				lod.visible = lod.name == "LOD0"
				lod.visibility_range_begin = 0.0
				lod.visibility_range_end = 0.0
		await _measure("A_%s_lod0_only" % species, field)
		field.queue_free()
		var path := _sketchfab_scene(species)
		if path != "":
			var scene := load(path) as PackedScene
			var reduced := scene.instantiate() as Node3D
			_scissor_materials(reduced)
			_reduce(reduced, int(B_TRIANGLE_BUDGET[species]))
			var box := _node_bounds(reduced)
			var height := (pool[0].lod0 as ArrayMesh).get_aabb().end.y
			var scale := height / maxf(box.size.y, 0.01)
			var b_field := Node3D.new()
			for i in spots.size():
				var holder := Node3D.new()
				holder.position = spots[i]
				holder.rotation.y = rng.randf() * TAU
				var copy := reduced.duplicate() as Node3D
				copy.scale = Vector3.ONE * scale
				copy.position = -Vector3(box.get_center().x, box.position.y, box.get_center().z) * scale
				holder.add_child(copy)
				b_field.add_child(holder)
			_h.main.add_child(b_field)
			await _measure("B_%s_reduced" % species, b_field)
			await _shoot("perf-%s-B" % species)
			b_field.queue_free()
			reduced.free()
		await process_frame
	RenderingServer.viewport_set_measure_render_time(viewport, false)


func _measure(name: String, field: Node3D) -> void:
	for _i in 90:
		await process_frame
	var viewport := root.get_viewport_rid()
	var frames := []
	var gpu := []
	var cpu := []
	var draws := []
	var primitives := []
	var objects := []
	var last := Time.get_ticks_usec()
	for _i in 240:
		await process_frame
		var now := Time.get_ticks_usec()
		frames.append((now - last) / 1000.0)
		last = now
		gpu.append(RenderingServer.viewport_get_measured_render_time_gpu(viewport))
		cpu.append(RenderingServer.viewport_get_measured_render_time_cpu(viewport))
		draws.append(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME))
		primitives.append(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME))
		objects.append(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME))
	var result := {
		"frame_ms_median": _median(frames), "frame_ms_p95": _percentile(frames, 0.95),
		"fps_median": snappedf(1000.0 / maxf(_median(frames), 0.001), 0.1),
		"gpu_ms_median": _median(gpu), "cpu_render_ms_median": _median(cpu),
		"draw_calls_median": _median(draws), "primitives_median": _median(primitives), "objects_median": _median(objects),
		"texture_mem_bytes": RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TEXTURE_MEM_USED),
		"video_mem_bytes": RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED),
	}
	_metrics.perf[name] = result
	print("PERF %s %s" % [name, JSON.stringify(result)])


func _median(values: Array) -> float:
	return _percentile(values, 0.5)


func _percentile(values: Array, fraction: float) -> float:
	var sorted := values.duplicate()
	sorted.sort()
	return snappedf(float(sorted[clampi(int(round(fraction * (sorted.size() - 1))), 0, sorted.size() - 1)]), 0.001)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
