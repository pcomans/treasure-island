extends RefCounted
## Palette-only reusable visual asset. No live dispatch or recognition authority.
## The accepted builder remains the sole construction source. Site-specific geometry
## is normalized around origin; callers place instances with their root transform.
const MODEL = preload("res://game/scripts/world/facades/northpoint_1232_quality_model.gd")
const SOURCE_COLOR := "vec3(0.27,0.33,0.34)"
var _scene: PackedScene
var origin := Vector3.ZERO

func prepare(record: Dictionary, ground: Callable) -> Error:
	_scene = null
	var model: Node3D = MODEL.build(record, ground)
	var bounds := AABB()
	var first := true
	var doors: Array[Material] = []
	# This adapter knows the existing builder's explicit threshold construction:
	# the preceding slab must have the documented size and original door finish.
	for i in model.get_child_count():
		var node := model.get_child(i) as MeshInstance3D
		if node.get_meta("construction_detail", "") == "door_threshold":
			if i == 0:
				model.free()
				return ERR_INVALID_DATA
			var slab := model.get_child(i - 1) as MeshInstance3D
			var slab_box := slab.mesh as BoxMesh
			var material := slab.material_override as StandardMaterial3D
			if slab_box == null or not slab_box.size.is_equal_approx(Vector3(0.92, 2.13, 0.06)) or material == null or not material.albedo_color.is_equal_approx(Color(0.075, 0.13, 0.19)):
				model.free()
				return ERR_INVALID_DATA
			doors.append(material)
		var local_bounds: AABB = node.transform * node.get_aabb()
		bounds = local_bounds if first else bounds.merge(local_bounds)
		first = false
	if doors.is_empty():
		model.free()
		return ERR_INVALID_DATA
	origin = Vector3(bounds.get_center().x, bounds.position.y, bounds.get_center().z)
	for node: MeshInstance3D in model.get_children():
		var material := node.material_override
		if node.get_meta("physical_role", "") == "wall":
			if not material is ShaderMaterial or not material.shader.code.contains(SOURCE_COLOR):
				model.free()
				return ERR_INVALID_DATA
			node.set_meta("appearance_slot", "walls")
		elif material in doors:
			node.set_meta("appearance_slot", "doors")
		node.position -= origin
		node.owner = model
	model.set_meta("template_source_key", "w96215673")
	model.set_meta("template_origin", origin)
	model.set_meta("asset_scope", "visual_palette_demo_only")
	_scene = PackedScene.new()
	var result := _scene.pack(model)
	model.free()
	return result

func instantiate(palette: Dictionary = {}) -> Node3D:
	if _scene == null:
		push_error("Prepare the house asset before instantiating it.")
		return null
	for key: Variant in palette:
		if key not in ["walls", "doors"] or not palette[key] is Color:
			push_error("House palette accepts only walls/doors Color overrides.")
			return null
	var instance := _scene.instantiate() as Node3D
	var materials: Dictionary = {}
	for node: MeshInstance3D in instance.get_children():
		var original := node.material_override
		var slot := str(node.get_meta("appearance_slot", ""))
		# A finish may serve both walls and unrelated screens in the source model.
		# Cache by semantic slot as well as material to preserve those details.
		var key := str(original.get_instance_id()) + ":" + slot
		if not materials.has(key):
			materials[key] = original.duplicate(true)
		node.material_override = materials[key]
		if not palette.has(slot): continue
		if slot == "doors":
			(node.material_override as StandardMaterial3D).albedo_color = palette[slot]
		else:
			var material := node.material_override as ShaderMaterial
			if material.shader.code.contains(SOURCE_COLOR):
				material.shader.code = material.shader.code.replace("varying vec3 wp;", "uniform vec4 wall_color : source_color; varying vec3 wp;").replace(SOURCE_COLOR, "wall_color.rgb")
			material.set_shader_parameter("wall_color", palette[slot])
	return instance
