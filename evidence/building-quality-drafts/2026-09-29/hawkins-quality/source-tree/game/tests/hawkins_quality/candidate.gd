extends "res://game/scripts/world/facades/hawkins_77_bruton_facade.gd"
# Reuses the exact accepted shell, layout and complete motif builders.
# Projecting assemblies are bounded production inference, not surveyed recesses.
var _canopy_boxes: Array[Transform3D] = []

func configure(record: Dictionary, runtime_massing: Dictionary = {}) -> Dictionary:
	var result: Dictionary = super.configure(record,runtime_massing)
	remove_from_group("hawkins_render_only_facade")
	set_meta("render_only",false)
	set_meta("spray_ray_owner","candidate native facade details; accepted underlying shell retained")
	set_meta("collision","native indexed visible detail faces; original shell and roof unchanged")
	set_meta("maximum_relief_m",0.83)
	return result

func _add_box(material_key: String, side: Dictionary, u: float, y: float, width: float, height: float, inner: float, outer: float) -> void:
	assert(width > 0.0 and height > 0.0 and outer >= inner)
	assert(u-width*0.5 >= -0.0001 and u+width*0.5 <= float(side.length_m)+0.0001)
	assert(y-height*0.5 >= float(_layout.target.base_y_m)-0.0001 and y+height*0.5 <= float(_layout.target.main_top_y_m)+0.0001)
	# Actual photo: slender silver frames stand proud of closed glazing.
	if material_key == "frame_charcoal" and height > 0.02: outer = 0.17
	if material_key == "spandrel_pale": outer = 0.11
	var basis := _side_basis(side)
	basis.x *= width
	basis.y *= height
	basis.z *= outer-inner
	var pose := Transform3D(basis,_side_point(side,u,y,(inner+outer)*0.5))
	if not _boxes_by_material.has(material_key): _boxes_by_material[material_key] = []
	(_boxes_by_material[material_key] as Array).append(pose)

func _build_upper_window(side: Dictionary, u: float, narrow: bool, center_y: float, spandrel_y: float, volume_role: String, volume_top_y: float) -> void:
	super._build_upper_window(side,u,narrow,center_y,spandrel_y,volume_role,volume_top_y)
	# Infill between stacked openings makes continuous pale metal window strips.
	if not narrow and center_y+1.75 < volume_top_y:
		_add_box("spandrel_pale",side,u,center_y+1.48,1.8,0.5,0.013,0.07)

func _build_ground_facade(side: Dictionary, target: Dictionary) -> void:
	var assembly: Dictionary = side.duplicate(true)
	if str(side.side_id) == "side_se":
		# Connect lobby glazing to the retained paired entry; no interior is opened.
		for module: Dictionary in assembly.ground_modules:
			if str(module.kind) == "L-G":
				module.u_m = 9.025
				module.width_m = 10.55
		super._build_ground_facade(assembly,target)
		var basis := _side_basis(side)
		basis.x *= 14.2
		basis.y *= 0.16
		basis.z *= 0.82
		_canopy_boxes.append(Transform3D(basis,_side_point(side,10.8,7.24,0.42)))
	else:
		super._build_ground_facade(assembly,target)

func _add_rib_field(side: Dictionary,start_u: float,end_u: float,bottom_y: float,top_y: float,material_key: String,pitch: float,rib_width: float,outer: float) -> void:
	# Wall cladding terminates at complete opening bounds, including their frames.
	var count := int(floor((end_u-start_u-rib_width*2.0)/pitch))+1
	var first := start_u+((end_u-start_u)-float(count-1)*pitch)*0.5
	for index in count:
		var u := first+index*pitch
		var intervals: Array = [Vector2(bottom_y,top_y)]
		for module: Dictionary in side.ground_modules:
			if str(module.kind) not in ["L-G","D-P","D-S","G-G","G-W"]: continue
			if absf(u-float(module.u_m)) > float(module.width_m)*0.5+rib_width*0.5: continue
			var low := float(module.center_y_m)-float(module.height_m)*0.5
			var high := float(module.center_y_m)+float(module.height_m)*0.5
			var remaining: Array = []
			for span: Vector2 in intervals:
				if high <= span.x or low >= span.y: remaining.append(span)
				else:
					if low > span.x: remaining.append(Vector2(span.x,low))
					if high < span.y: remaining.append(Vector2(high,span.y))
			intervals = remaining
		for span: Vector2 in intervals:
			if span.y-span.x > 0.001:
				_add_box(material_key,side,u,(span.x+span.y)*0.5,rib_width,span.y-span.x,0.012,outer)

func _build_lobby(side: Dictionary,u: float,y: float,width: float,height: float) -> void:
	_add_box("glass_proxy",side,u,y,width-0.14,height-0.14,0.020,0.075)
	_add_complete_frame(side,u,y,width,height,0.075,5)
	# Deep head and two end reveals join glazing to the solid cladding.
	_add_box("base_ribbed",side,u-width*0.5-0.12,y,0.24,height,0.013,0.30)
	_add_box("base_ribbed",side,u+width*0.5+0.12,y,0.24,height,0.013,0.30)
	_add_box("base_ribbed",side,u,y+height*0.5+0.12,width+0.48,0.24,0.013,0.30)

func _build_garage(side: Dictionary,u: float,y: float,width: float,height: float) -> void:
	# Closed dark garage face sheltered within thick solid piers/head, not an applied grille.
	_add_box("garage_dark",side,u,y,width,height,0.020,0.055)
	_add_complete_frame(side,u,y,width,height,0.07,1)
	for index in 27:
		_add_box("frame_charcoal",side,u,y-height*0.46+index*height*0.92/26.0,width-0.18,0.014,0.060,0.075)
	for sign in [-1.0,1.0]:
		_add_box("base_smooth",side,u+sign*(width*0.5+0.45),y,0.9,height,0.013,0.52)
	_add_box("base_smooth",side,u,y+height*0.5+0.38,width+1.8,0.76,0.013,0.52)

func _flush_render_batches() -> void:
	super._flush_render_batches()
	var faces := PackedVector3Array()
	for instance: MultiMeshInstance3D in get_node("RenderBatches").get_children():
		var box := instance.multimesh.mesh as BoxMesh
		var material := box.material.duplicate() as StandardMaterial3D
		var key := str(instance.get_meta("material_key"))
		if key == "frame_charcoal":
			material.albedo_color = Color(0.58,0.62,0.62)
			material.metallic = 0.32
			material.roughness = 0.43
		elif key == "glass_proxy":
			material.albedo_color = Color(0.25,0.34,0.37)
			material.metallic = 0.12
			material.roughness = 0.27
		box.material = material
		_tag(instance,"building_wall")
		for index in instance.multimesh.instance_count:
			_append_native_box(faces,box,instance.multimesh.get_instance_transform(index))
	_contact("FacadeDetailContact",faces,"building_wall")
	var canopy_faces := PackedVector3Array()
	for pose in _canopy_boxes:
		var box := BoxMesh.new()
		box.size = Vector3.ONE
		box.material = MATERIALS.spandrel_pale
		var mesh := MeshInstance3D.new()
		mesh.name = "EntranceCanopy"
		mesh.mesh = box
		mesh.transform = pose
		mesh.layers = 1
		_tag(mesh,"none")
		add_child(mesh)
		_append_native_box(canopy_faces,box,pose)
	_contact("CanopyContact",canopy_faces,"none")
	set_meta("build_valid",not faces.is_empty() and not canopy_faces.is_empty())
	set_meta("contact_geometry","actual indexed BoxMesh faces transformed by rendered instance transforms")

func _append_native_box(faces: PackedVector3Array,box: BoxMesh,pose: Transform3D) -> void:
	var arrays := box.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	for index in indices: faces.append(pose*vertices[index])

func _tag(object: Object,receiver: String) -> void:
	object.set_meta("source_keys",[TARGET_SOURCE_KEY])
	object.set_meta("derived_object_key",TARGET_RECEIVER_OBJECT_KEY)
	object.set_meta("receiver_kind",receiver)
	object.set_meta("collision_kind","world_solid")
	object.set_meta("feature_kind","building_wall")
	object.set_meta("opaque",true)

func _contact(label: String,faces: PackedVector3Array,receiver: String) -> void:
	var body := StaticBody3D.new()
	body.name = label
	body.collision_layer = 5
	body.collision_mask = 0
	_tag(body,receiver)
	if receiver == "building_wall": body.add_to_group("spray_receiver_wall")
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	_tag(shape,receiver)
	var holder := CollisionShape3D.new()
	holder.shape = shape
	_tag(holder,receiver)
	body.add_child(holder)
	add_child(body)
