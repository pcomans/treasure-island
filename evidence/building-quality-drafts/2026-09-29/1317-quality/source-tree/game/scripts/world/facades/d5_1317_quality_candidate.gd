extends RefCounted
## Reversible art wrapper for the existing 1317 pair; never production dispatch.
## Observed May2019 frontage. Dimensions/hidden return finish are game-art inference.
const BASE=preload("res://game/scripts/world/facades/d5_1317_gateview_live_factory.gd")
const COMPONENTS=preload("res://game/scripts/world/facades/d5_1308_gateview_live_factory.gd")
const BOARDING=preload("res://game/resources/facades/d5_1317_candidate_boarding.gdshader")
const KIT=preload("res://game/scripts/world/facades/site_12_housing_kit.gd")
static func apply_to_pair(wall_root: Node3D,roof_root: Node3D,wall_record: Dictionary) -> Dictionary:
	if wall_root.get_meta("derived_object_key","")!=BASE.WALL_KEY or roof_root.get_meta("derived_object_key","")!=BASE.ROOF_KEY:return {"ok":false,"message":"Exact 1317 pair required"}
	var config: Dictionary=BASE._json(BASE.CONFIG_PATH)
	var siding_spec: Dictionary=config.materials.siding.duplicate(true)
	siding_spec.base_rgb=[0.76,0.745,0.655];siding_spec.seam_rgb=[0.61,0.60,0.53]
	siding_spec.relief_strength=0.025;siding_spec.color_variation=0.012
	var siding: ShaderMaterial=BASE._siding_material(siding_spec)
	var trim: StandardMaterial3D=BASE._material("1317_candidate_warm_painted_trim",Color(0.80,0.795,0.735),0.90)
	var recess: StandardMaterial3D=BASE._material("1317_candidate_opening_reveal",Color(0.15,0.135,0.105),0.97)
	var board:=ShaderMaterial.new()
	board.resource_name="1317_candidate_weathered_timber_sheet";board.shader=BOARDING
	var dark: StandardMaterial3D=BASE._material("1317_candidate_closed_dark_infill",Color(0.115,0.12,0.105),0.96)
	var roof: StandardMaterial3D=COMPONENTS._public_roof_material()
	roof.resource_name="1317_candidate_weathered_brown_roof";roof.albedo_color=Color(0.28,0.245,0.195);roof.roughness=0.96
	var removed: Array=[]
	for root_node: Node3D in [wall_root,roof_root]:
		root_node.set_meta("candidate_unaccepted",true)
		for child: Node in root_node.get_children():
			if not child is MeshInstance3D:continue
			var name: String=str(child.name)
			if name in ["UpperWarmBoardedFields","UpperDarkOpaqueFields","PaleUpperFrames"]:
				removed.append(name);root_node.remove_child(child);child.free();continue
			if name in ["ProtectedExactNeutralWallRuns","ObservedENEHorizontalSidingFields","PaleCanopyFrontGables"]:child.material_override=siding
			elif name in ["PaleGroundFrames","SlimCanopyTrim","GroundFittedPostsAndBraces"]:child.material_override=trim
			elif name=="ClosedGroundBoardedFields":child.material_override=board
			elif name in ["BrownCanopyTopsAndSides","PublicShallowBrownMainRoof"]:child.material_override=roof
	if removed.size()!=3:return {"ok":false,"message":"Existing 1317 opening set changed"}
	var warm:=KIT.new_bucket();var opaque:=KIT.new_bucket();var frames:=KIT.new_bucket();var reveals:=KIT.new_bucket();var edges:=KIT.new_bucket()
	for module: Dictionary in config.upper_modules:
		var local: Dictionary={"kind":"closed_window","station_m":module.station_m,"bottom_y":module.bottom_y,"width_m":module.width_m,"height_m":module.height_m,"frame_width_m":module.frame_width_m}
		var group: Dictionary={"runs":module.runs,"local_modules":[local]}
		var panel:=KIT.new_bucket();var frame:=KIT.new_bucket();var unused:=KIT.new_bucket()
		# Reuse 1308's complete boxed opening component; target frame/source stays1317.
		COMPONENTS._lower_modules(unused,panel,frame,wall_record,[group])
		var f: Dictionary=BASE._joined_frame(wall_record,int(module.runs[0]),int(module.runs[-1]))
		for i in frame.vertices.size():frame.vertices[i]+=f.normal*0.06
		BASE._merge(frames,frame)
		BASE._merge(warm if str(module.finish)=="boarded_warm_brown" else opaque,panel)
		var x: float=module.station_m;var y: float=module.bottom_y+module.height_m*0.5
		for side: float in [-1.0,1.0]:
			KIT.append_box(reveals,BASE._point(f,x+side*(module.width_m*0.5+0.025),y,0.09),f.tangent,f.normal,0.05,module.height_m+0.1,0.16)
			KIT.append_box(reveals,BASE._point(f,x,y+side*(module.height_m*0.5+0.025),0.09),f.tangent,f.normal,module.width_m,0.05,0.16)
		# Restrained projecting sill, same existing opening extent and no new cadence.
		KIT.append_box(edges,BASE._point(f,x,float(module.bottom_y)-0.08,0.13),f.tangent,f.normal,module.width_m+0.19,0.065,0.24)
	for f_data: Dictionary in config.frames:
		var runs: Array=f_data.runs
		var f: Dictionary=BASE._joined_frame(wall_record,int(runs[0]),int(runs[-1]))
		var length: float=f.length_m
		KIT.append_box(edges,BASE._point(f,length*0.5,8.155,0.02),f.tangent,f.normal,length,0.11,0.17)
	_add(wall_root,"CandidateUpperBoardedPanels",warm,board)
	_add(wall_root,"CandidateUpperDarkPanels",opaque,dark)
	_add(wall_root,"CandidateUpperOpeningFrames",frames,trim)
	_add(wall_root,"CandidateOpeningReveals",reveals,recess)
	_add(wall_root,"CandidateSillsAndEaveFascia",edges,trim)
	_add_upper_contact(wall_root)
	return {"ok":true,"upper_detail_contact_added":true,"source_key":"w95934125","candidate_unaccepted":true,"reuse":"1317 exact massing/porches/site fit +1308 complete opening component and matte roof material","structural_collision_unchanged":true,"source_geometry_unchanged":true,"return_finish":"continuous siding inferred; no new hidden opening schedule"}
static func _add(parent: Node3D,label: String,bucket: Dictionary,material: Material) -> void:
	if bucket.indices.is_empty():return
	var arrays: Array=[];arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX]=PackedVector3Array(bucket.vertices);arrays[Mesh.ARRAY_NORMAL]=PackedVector3Array(bucket.normals);arrays[Mesh.ARRAY_TEX_UV]=PackedVector2Array(bucket.uvs);arrays[Mesh.ARRAY_INDEX]=PackedInt32Array(bucket.indices)
	var mesh:=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var node:=MeshInstance3D.new();node.name=label;node.mesh=mesh;node.material_override=material;node.layers=1
	node.set_meta("derived_object_key",BASE.WALL_KEY);node.set_meta("source_keys",["w95934125"]);node.set_meta("candidate_unaccepted",true)
	parent.add_child(node)

static func _add_upper_contact(parent: Node3D) -> void:
	# Same opaque/nonreceiver role as ClosedLowerModules, from final visible faces.
	var body:=StaticBody3D.new();body.name="CandidateUpperDetailContact";body.collision_layer=5;body.collision_mask=0
	for object: Object in [body]:
		object.set_meta("receiver_kind","none");object.set_meta("derived_object_key",BASE.WALL_KEY);object.set_meta("source_keys",["w95934125"]);object.set_meta("opaque",true);object.set_meta("candidate_unaccepted",true);object.set_meta("spray_ray_blocking",true)
	for label: String in ["CandidateUpperBoardedPanels","CandidateUpperDarkPanels","CandidateUpperOpeningFrames","CandidateOpeningReveals","CandidateSillsAndEaveFascia"]:
		var mesh_node:=parent.get_node_or_null(label) as MeshInstance3D
		if mesh_node==null:continue
		var faces: PackedVector3Array=mesh_node.mesh.get_faces()
		for i in faces.size():faces[i]=mesh_node.transform*faces[i]
		var shape:=ConcavePolygonShape3D.new();shape.set_faces(faces)
		var node:=CollisionShape3D.new();node.name=label;node.shape=shape
		for object: Object in [node,shape]:
			object.set_meta("receiver_kind","none");object.set_meta("derived_object_key",BASE.WALL_KEY);object.set_meta("source_keys",["w95934125"]);object.set_meta("opaque",true);object.set_meta("structural_role","ClosedUpperDetails");object.set_meta("candidate_unaccepted",true)
		body.add_child(node)
	parent.add_child(body)
