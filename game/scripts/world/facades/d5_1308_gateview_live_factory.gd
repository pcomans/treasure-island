class_name D51308GateviewLiveFactory
extends Node3D

const MARKS := preload("res://game/resources/facades/d5_1308_siding_marks.gdshader")
const KIT := preload("res://game/scripts/world/facades/site_12_housing_kit.gd")
const LAWN_TONE := preload("res://game/resources/facades/d5_1308_lawn_tone.gdshader")
const CONCRETE_ALBEDO := preload("res://game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_diff_1k.jpg")
const CONCRETE_ROUGHNESS := preload("res://game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_rough_1k.jpg")
const LAWN_ALBEDO := preload("res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_diff_1k.jpg")
const LAWN_ROUGHNESS := preload("res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_rough_1k.jpg")
const CONFIG_PATH := "res://game/resources/facades/d5_1308_gateview_live_factory.json"
const SOURCE_KEY := "w95934123"
const WALL_KEY := "building:w95934123:wall"
const ROOF_KEY := "building:w95934123:roof"
const SOURCE_GEOMETRY_SHA256 := "6028c89be31ebfd095777b86f6d5d4a9094002b7b5fd73efb2fc940f9a9f3917"
const TARGET_RUNS := [0, 1, 2, 3, 5, 7, 8, 9, 10, 11, 12, 13, 14, 17, 18, 19, 20, 21, 27, 32]
const PROTECTED_RUNS := [4, 6, 15, 16, 22, 23, 24, 25, 26, 28, 29, 30, 31, 33]
const IVORY := preload("res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres")
const DARK_ROOF := preload("res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres")
const METAL := preload("res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres")
var _last_result: Dictionary = {}

static func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}

static func _record(records: Array, key: String) -> Dictionary:
	for value: Dictionary in records:
		if str(value.get("object_key", "")) == key: return value
	return {}

static func build_for_records(wall: Dictionary, roof: Dictionary, neutral_wall: StandardMaterial3D, neutral_roof: StandardMaterial3D) -> Dictionary:
	var model := D51308GateviewLiveFactory.new()
	var result := model.configure_records(wall, roof, neutral_wall, neutral_roof)
	if not bool(result.get("ok", false)): model.free()
	return result

func configure_records(wall: Dictionary, roof: Dictionary, neutral_wall: StandardMaterial3D, neutral_roof: StandardMaterial3D, baseline: bool = false) -> Dictionary:
	if not _last_result.is_empty():return {"ok":false,"message":"Duplicate detached study configuration."}
	var config:=_json(CONFIG_PATH)
	if FileAccess.get_sha256(CONFIG_PATH)!="5fb9d42425df7d6f8b62ffdc3053e88ee559dc0efd0e7880b5e841ed0bf1ac8a" or str(wall.get("object_key",""))!=WALL_KEY or str(roof.get("object_key",""))!=ROOF_KEY or neutral_wall==null or neutral_roof==null:return {"ok":false,"message":"Validated factory inputs changed."}
	if not _same_numeric_runs(config.get("mapped_runs",[]),TARGET_RUNS) or not _same_numeric_runs(config.get("protected_runs",[]),PROTECTED_RUNS) or str(config.get("schema_version",""))!="ti.d5-1308-gateview-live-factory/1":return {"ok":false,"message":"1308 scope changed."}
	var truth:Dictionary=config.truth_boundary
	if not bool(truth.prototype_only) or bool(truth.runtime_attachment) or bool(truth.recognition_accepted) or bool(truth.interior_modeled) or bool(truth.as_built_claim):return {"ok":false,"message":"Detached truth boundary changed."}
	var inf:Dictionary=config.inference
	var protected:=KIT.new_bucket();var mapped:=KIT.new_bucket()
	for run in 34:_append_source_run(protected if run in PROTECTED_RUNS else mapped,wall,run,true)
	_add_mesh("ProtectedExactNeutralWallRuns",protected,neutral_wall)
	_add_mesh("ObservedWSWSSEHorizontalSidingFields",mapped,neutral_wall if baseline else _siding_material(inf))
	var walls:=KIT.new_bucket();_merge(walls,protected);_merge(walls,mapped)
	var roof_bucket:=KIT.new_bucket();_append_source_roof(roof_bucket,roof)
	_add_mesh("ExactSourceNeutralRoof",roof_bucket,neutral_roof)
	var structure:=KIT.new_bucket();var slabs:=KIT.new_bucket();var new_roof:=KIT.new_bucket();var lower_collision:=KIT.new_bucket()
	if not baseline:
		var glazing:=KIT.new_bucket();var trim:=KIT.new_bucket();var canopy_roofs:=KIT.new_bucket();var posts:=KIT.new_bucket()
		var pale:=_material("inferred_restrained_cream_trim",Color(.87,.86,.79),.87)
		var dark:=_material("opaque_upper_sliding_glass",Color(.14,.20,.22),.42)
		for group:Array in inf.upper_window_groups:
			var f:=_joined_frame(wall,int(group[0]),int(group[-1]))
			var count:=maxi(1,int(floor((float(f.length_m)-.40)/float(inf.slider_pitch_m))))
			var pitch:=float(f.length_m)/float(count)
			var width:=minf(float(inf.slider_width_m),pitch-.40)
			for i in count:
				var center:=_point(f,pitch*(float(i)+.5),float(inf.upper_window_bottom)+float(inf.upper_window_height)*.5,.025)
				KIT.append_grouped_opening(glazing,trim,center,f.tangent,f.normal,width,float(inf.upper_window_height),.040,.085,.085,.055)
				KIT.append_box(trim,center+(f.normal as Vector3)*.025,f.tangent,f.normal,.055,float(inf.upper_window_height),.05)
		for canopy_index in inf.canopy_groups.size():
			var group:Array=inf.canopy_groups[canopy_index]
			var pad:Dictionary=config.grade_pads.pads[canopy_index]
			var f:=_joined_frame(wall,int(group[0]),int(group[-1]));var station:=float(f.length_m)*.5
			var width:=minf(float(inf.canopy_max_width),float(f.length_m)-2.0*float(inf.canopy_edge_inset))
			_canopy(canopy_roofs,trim,f,station,width,inf)
			var depth:=float(inf.canopy_depth)
			for side_index in 2:
				var side:float=-1.0 if side_index==0 else 1.0
				var post_start:int=posts.vertices.size()
				var p:=_point(f,station+side*(width*.5-float(inf.post_inset)),(2.251+float(inf.canopy_soffit_y))*.5,depth-float(inf.post_inset))
				KIT.append_box(posts,p,f.tangent,f.normal,float(inf.post_width),float(inf.canopy_soffit_y)-2.251,float(inf.post_width))
				# Preserve original post XZ, upper vertices, normals and UVs; extend only its lower vertices.
				var lower_y:float=pad.post_bottom_y_m[side_index]
				if lower_y<2.251-.000001:
					for i in range(post_start,posts.vertices.size()):
						var v:Vector3=posts.vertices[i]
						if absf(v.y-2.251)<.000001:v.y=lower_y;posts.vertices[i]=v
			_grade_pad(slabs,pad,float(config.grade_pads.vertical_thickness_m))
		_add_mesh("RepeatedOpaqueUpperSliders",glazing,dark)
		_add_mesh("RestrainedRealWindowAndCanopyTrim",trim,pale)
		var canopy_parts:=_partition_canopy_fronts(canopy_roofs)
		_add_mesh("DeepRepeatedGableCanopyRoofs",canopy_parts[0],DARK_ROOF)
		_add_mesh("PaleSidedCanopyGableFronts",canopy_parts[1],_siding_material(inf))
		_add_mesh("ReadableCanopyRoofTops",canopy_parts[2],_public_roof_material())
		_add_mesh("RealCanopyFrontSupports",posts,pale)
		_add_mesh("GroundFlushCanopySupportSlabs",slabs,_ground_material("connected_concrete_pad_and_apron",CONCRETE_ALBEDO,CONCRETE_ROUGHNESS,Color("d8d6cf"),.92,1.8))
		_merge(structure,canopy_roofs);_merge(structure,posts)
		var refinement:Dictionary=config.fidelity_revision_001
		var pitched:=KIT.new_bucket();var fascia:=KIT.new_bucket();var apron:=KIT.new_bucket();var lawn:=KIT.new_bucket()
		_authored_triangles(pitched,refinement.surfaces.PublicPitchedRoofSlopes)
		_authored_triangles(fascia,refinement.surfaces.PublicPaleRoofFasciaAndSoffit)
		_authored_triangles(apron,refinement.surfaces.ConnectedConcreteAprons)
		_authored_triangles(lawn,refinement.surfaces.LocalFrontageLawn)
		_add_mesh("PublicPitchedRoofSlopes",pitched,_public_roof_material())
		_add_mesh("PublicPaleRoofFasciaAndSoffit",fascia,pale)
		_add_mesh("ConnectedConcreteAprons",apron,_ground_material("connected_concrete_pad_and_apron",CONCRETE_ALBEDO,CONCRETE_ROUGHNESS,Color("d8d6cf"),.92,1.8))
		_add_mesh("LocalFrontageLawn",lawn,_lawn_material())
		_merge(new_roof,pitched);_merge(new_roof,fascia)
		var doors:=KIT.new_bucket();var windows:=KIT.new_bucket();var frames:=KIT.new_bucket()
		_lower_modules(doors,windows,frames,wall,refinement.groups)
		_add_mesh("ClosedLowerDoors",doors,pale)
		_add_mesh("ClosedLowerWindows",windows,dark)
		_add_mesh("LowerOpeningFramesAndHandles",frames,pale)
		for part:Dictionary in [doors,windows,frames]:_merge(lower_collision,part)
	var body:=StaticBody3D.new();body.name="ExactFootprintStructuralCollision_NoSprayOwnership";body.collision_layer=1;body.collision_mask=0
	body.set_meta("receiver_kind","none");body.set_meta("opaque",true);body.set_meta("derived_object_key",WALL_KEY if baseline else "prototype:"+WALL_KEY);body.set_meta("source_keys",[SOURCE_KEY]);body.set_meta("prototype_only",true)
	var collisions:Dictionary={"ExactClosedSourceWalls":walls,"ExactSourceNeutralRoof":roof_bucket}
	if not baseline:collisions.merge({"RealGableCanopiesAndPosts":structure,"GroundFlushSupportSlabs":slabs,"ClosedLowerModules":lower_collision,"PublicPitchedRoofSolid":new_roof})
	var collision_triangles:=0
	for label:String in collisions:
		var bucket:Dictionary=collisions[label];var faces:=PackedVector3Array()
		for index:int in bucket.indices:faces.append(bucket.vertices[index])
		var shape:=ConcavePolygonShape3D.new();shape.set_faces(faces);shape.set_meta("receiver_kind","none");shape.set_meta("structural_role",label)
		var node:=CollisionShape3D.new();node.name=label;node.shape=shape;body.add_child(node);collision_triangles+=faces.size()/3
	add_child(body)
	var batches:Dictionary={};var total:=0
	for child:Node in get_children():
		if child is MeshInstance3D:
			var count:int=child.mesh.surface_get_array_index_len(0)/3;batches[str(child.name)]=count;total+=count
	var metadata:Dictionary={"model_id":"d5-1308-gateview-detached-observed-side-study-v1","baseline_exact_source":baseline,"prototype_only":true,"runtime_attachment":false,"recognition_accepted":false,"as_built_claim":false,"interior_modeled":false,"source_key":SOURCE_KEY,"mapped_public_run_indices":TARGET_RUNS,"protected_run_indices":PROTECTED_RUNS,"visual_batch_triangles":batches,"visual_triangles":total,"mesh_instances":batches.size(),"surfaces":batches.size(),"static_bodies":1,"shapes":collisions.size(),"collision_triangles":collision_triangles,"protected_runs_have_facade_modules":false,"original22_roof_triangles_retained":true,"roof_geometry_material_unchanged":baseline,"closed_lower_modules_at_six_existing_canopy_backs":not baseline,"stairs_added":false,"module_dimensions_and_counts":"production_inference","deterministic_signature":JSON.stringify(batches).sha256_text()}
	metadata["pad_surface_mode"]="absent" if baseline else "frozen_visible_area_plus_5mm"
	metadata["pad_top_y_ranges_m"]=[] if baseline else config.grade_pads.pads.map(func(p:Dictionary)->Array:return p.actual_top_y_range_m)
	metadata["pad_vertical_thickness_m"]=0.0 if baseline else float(config.grade_pads.vertical_thickness_m)
	metadata["post_bottom_y_m"]=[] if baseline else config.grade_pads.pads.map(func(p:Dictionary)->Array:return p.post_bottom_y_m)
	metadata["historical_flat_pad_top_y_m"]=2.251
	for key:String in metadata:set_meta(key,metadata[key])
	_last_result={"ok":true,"node":self,"metadata":metadata,"mesh_instances":batches.size(),"surfaces":batches.size(),"visual_triangles":total,"static_bodies":1,"shapes":collisions.size(),"collision_triangles":collision_triangles}
	return _last_result

static func _partition_canopy_fronts(source:Dictionary) -> Array:
	var roof:=KIT.new_bucket();var front:=KIT.new_bucket();var tops:=KIT.new_bucket()
	for bucket:Dictionary in [roof,front,tops]:
		for key:String in ["vertices","normals","uvs"]:bucket[key]=source[key].duplicate()
	for tri in int(source.indices.size()/3):
		var bucket:Dictionary=tops if tri%16 in [0,1,2,3] else (front if tri%16 in [10,11,12] else roof)
		bucket.indices.append_array(source.indices.slice(tri*3,tri*3+3))
	return [roof,front,tops]

static func _authored_triangles(bucket:Dictionary,triangles:Array) -> void:
	for tri:Array in triangles:
		var a:=_v(tri[0]);var b:=_v(tri[1]);var c:=_v(tri[2])
		_triangle(bucket,a,b,c,(b-a).cross(c-a).normalized())

static func _lower_modules(doors:Dictionary,windows:Dictionary,frames:Dictionary,wall:Dictionary,groups:Array) -> void:
	for group:Dictionary in groups:
		var f:=_joined_frame(wall,int(group.runs[0]),int(group.runs[-1]))
		for module:Dictionary in group.local_modules:
			var station:float=module.station_m;var low:float=module.bottom_y;var width:float=module.width_m;var height:float=module.height_m;var fw:float=module.frame_width_m
			var bucket:Dictionary=doors if str(module.kind)=="closed_entry" else windows
			KIT.append_box(bucket,_point(f,station,low+height*.5,.05),f.tangent,f.normal,width,height,.10)
			for side:float in [-1.0,1.0]:
				KIT.append_box(frames,_point(f,station+side*(width*.5+fw*.5),low+height*.5,.07),f.tangent,f.normal,fw,height+2.0*fw,.14)
				KIT.append_box(frames,_point(f,station,low+height*.5+side*(height*.5+fw*.5),.07),f.tangent,f.normal,width,fw,.14)
			if str(module.kind)=="closed_entry":KIT.append_box(frames,_point(f,station+width*.32,low+1.0,.15),f.tangent,f.normal,.11,.04,.08)

static func _ground_material(label:String,albedo:Texture2D,rough:Texture2D,tint:Color,roughness:float,repeat_m:float) -> StandardMaterial3D:
	var material:=_material(label,tint,roughness)
	material.albedo_texture=albedo;material.roughness_texture=rough
	material.uv1_scale=Vector3(1.0/repeat_m,1.0/repeat_m,1.0)
	material.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	material.set_flag(BaseMaterial3D.FLAG_USE_TEXTURE_REPEAT,true)
	return material

static func _public_roof_material() -> StandardMaterial3D:
	# Private neutral matte study: the source bitumen texture has broad dark bands.
	# Suppress that albedo only on this duplicate; preserve cached resource/undersides.
	var material:=DARK_ROOF.duplicate() as StandardMaterial3D
	material.resource_name="private_matte_gray_planar_roof"
	material.albedo_texture=null
	material.albedo_color=Color(.44,.47,.48,1.0)
	return material

static func _lawn_material() -> ShaderMaterial:
	var material:=ShaderMaterial.new();material.shader=LAWN_TONE;material.resource_name="private_restrained_green_frontage_lawn"
	material.set_shader_parameter("lawn_albedo",LAWN_ALBEDO);material.set_shader_parameter("lawn_roughness",LAWN_ROUGHNESS)
	material.set_shader_parameter("dark_color",Color("4d663d"));material.set_shader_parameter("light_color",Color("819a57"));material.set_shader_parameter("luminance_gain",5.0)
	return material

static func _grade_pad(bucket:Dictionary,pad:Dictionary,thickness:float) -> void:
	for tri:Array in pad.top_triangles:
		var a:=_v(tri[0]);var b:=_v(tri[1]);var c:=_v(tri[2])
		_triangle(bucket,a,b,c,Vector3.UP)
		_triangle(bucket,a-Vector3.UP*thickness,b-Vector3.UP*thickness,c-Vector3.UP*thickness,Vector3.DOWN)
	for edge:Array in pad.boundary_segments:
		var a:=_v(edge[0]);var b:=_v(edge[1]);var direction:=b-a
		var outward:=Vector3(direction.z,0,-direction.x).normalized()
		_quad(bucket,a,b,b-Vector3.UP*thickness,a-Vector3.UP*thickness,outward)

static func _siding_material(inf:Dictionary) -> ShaderMaterial:
	var material:=ShaderMaterial.new();material.shader=MARKS;material.resource_name="inferred_quiet_pale_horizontal_siding"
	material.set_shader_parameter("base_color",Color(.81,.82,.75));material.set_shader_parameter("seam_color",Color(.63,.65,.58));material.set_shader_parameter("roughness_value",.87)
	material.set_shader_parameter("course_height_m",float(inf.siding_course_m));material.set_shader_parameter("phase_offset_m",float(inf.siding_phase_y));material.set_shader_parameter("seam_half_width_cycles",.006/(2.0*float(inf.siding_course_m)))
	material.set_shader_parameter("relief_strength",.02);material.set_shader_parameter("color_variation",0.0)
	return material

static func _canopy(bucket:Dictionary,trim:Dictionary,f:Dictionary,station:float,width:float,inf:Dictionary) -> void:
	var half:=width*.5;var depth:=float(inf.canopy_depth);var eave:=float(inf.canopy_eave_y);var ridge:=float(inf.canopy_ridge_y);var soffit:=float(inf.canopy_soffit_y)
	var l0:=_point(f,station-half,eave,0);var r0:=_point(f,station+half,eave,0);var p0:=_point(f,station,ridge,0)
	var l1:=_point(f,station-half,eave,depth);var r1:=_point(f,station+half,eave,depth);var p1:=_point(f,station,ridge,depth)
	var bl0:=_point(f,station-half,soffit,0);var br0:=_point(f,station+half,soffit,0);var bl1:=_point(f,station-half,soffit,depth);var br1:=_point(f,station+half,soffit,depth)
	_quad(bucket,l0,l1,p1,p0,Vector3.UP);_quad(bucket,p0,p1,r1,r0,Vector3.UP)
	_quad(bucket,bl0,br0,br1,bl1,Vector3.DOWN)
	_quad(bucket,bl0,bl1,l1,l0,-(f.tangent as Vector3));_quad(bucket,br1,br0,r0,r1,f.tangent)
	_quad(bucket,bl1,br1,r1,l1,f.normal);_triangle(bucket,l1,r1,p1,f.normal)
	_quad(bucket,br0,bl0,l0,r0,-(f.normal as Vector3));_triangle(bucket,r0,l0,p0,-(f.normal as Vector3))
	# Side beams retain their existing extent; front gable faces project 5mm beyond the roof end.
	var edge_width:=.04
	var inset:=edge_width*.5
	var a:=_point(f,station-half+inset,eave,depth-inset);var b:=_point(f,station,ridge-inset,depth-inset);var c:=_point(f,station+half-inset,eave,depth-inset)
	var front_start:int=trim.vertices.size()
	_beam(trim,a,b,edge_width);_beam(trim,b,c,edge_width)
	for index in range(front_start,trim.vertices.size()):
		trim.vertices[index]+=(f.normal as Vector3)*.005
	for side:float in [-1.0,1.0]:_beam(trim,_point(f,station+side*(half-inset),eave,0),_point(f,station+side*(half-inset),eave,depth-inset),edge_width)

static func _panel(bucket:Dictionary,frame:Dictionary,left:float,right:float,low:float,high:float,depth:float,normal:Vector3) -> void:
	_quad(bucket,_point(frame,left,low,depth),_point(frame,right,low,depth),_point(frame,right,high,depth),_point(frame,left,high,depth),normal)
static func _quad(bucket:Dictionary,a:Vector3,b:Vector3,c:Vector3,d:Vector3,normal:Vector3) -> void:
	_triangle(bucket,a,b,c,normal);_triangle(bucket,a,c,d,normal)
func get_build_result() -> Dictionary:
	return _last_result

static func _same_numeric_runs(actual: Array, expected: Array) -> bool:
	if actual.size() != expected.size(): return false
	for i in actual.size():
		if not (actual[i] is float or actual[i] is int):return false
		var value:=float(actual[i])
		if not is_finite(value) or floorf(value)!=value or value!=float(expected[i]):return false
	return true

static func _v(a: Array) -> Vector3:
	return Vector3(float(a[0]),float(a[1]),float(a[2]))

static func _point(frame: Dictionary, station: float, y: float, depth: float) -> Vector3:
	var point := (frame.start as Vector3)+(frame.tangent as Vector3)*station+(frame.normal as Vector3)*depth
	point.y=y
	return point

static func _joined_frame(wall: Dictionary, first: int, last: int) -> Dictionary:
	var frame := KIT.run_frame(wall,first)
	frame.end=KIT.run_frame(wall,last).end
	var delta: Vector3=frame.end-frame.start
	delta.y=0.0
	frame.length_m=delta.length();frame.tangent=delta.normalized()
	var normal := Vector3(-delta.z,0,delta.x).normalized()
	if normal.dot(frame.normal)<0: normal=-normal
	frame.normal=normal
	return frame

static func _material(label: String, color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name=label;material.albedo_color=color;material.roughness=roughness
	return material

static func _append_source_run(bucket: Dictionary, record: Dictionary, run: int, exact_uv: bool) -> void:
	var base: int=bucket.vertices.size()
	for local in 4:
		var index:=run*4+local
		var p:=_v(record.vertices.slice(index*3,index*3+3))
		bucket.vertices.append(p);bucket.normals.append(_v(record.normals.slice(index*3,index*3+3)))
		bucket.uvs.append(Vector2(float(record.uvs[index*2]),float(record.uvs[index*2+1])) if exact_uv else Vector2(p.dot(KIT.run_frame(record,run).tangent),p.y))
	for offset in [0,3]:
		var src: int=run*6+offset
		bucket.indices.append_array([base+int(record.indices[src])-run*4,base+int(record.indices[src+2])-run*4,base+int(record.indices[src+1])-run*4])

static func _append_source_roof(bucket: Dictionary, record: Dictionary) -> void:
	for index in range(int(record.vertices.size()/3)):
		bucket.vertices.append(_v(record.vertices.slice(index*3,index*3+3)));bucket.normals.append(Vector3.UP)
		bucket.uvs.append(Vector2(float(record.uvs[index*2]),float(record.uvs[index*2+1])))
	for offset in range(0,record.indices.size(),3):bucket.indices.append_array([record.indices[offset],record.indices[offset+2],record.indices[offset+1]])

static func _triangle(bucket: Dictionary,a: Vector3,b: Vector3,c: Vector3,outward: Vector3) -> void:
	if (b-a).cross(c-a).length()<0.0000001:return
	if (b-a).cross(c-a).dot(outward)<0:
		var swap:=b;b=c;c=swap
	var normal: Vector3=(b-a).cross(c-a).normalized()
	var base: int=bucket.vertices.size()
	for p: Vector3 in [a,b,c]:
		bucket.vertices.append(p);bucket.normals.append(normal);bucket.uvs.append(Vector2(p.x,p.z) if absf(normal.y)>.5 else Vector2(p.dot(Vector3(-normal.z,0,normal.x)),p.y))
	bucket.indices.append_array([base,base+2,base+1])

static func _merge(dst: Dictionary,src: Dictionary) -> void:
	var base: int=dst.vertices.size()
	for key: String in ["vertices","normals","uvs"]:dst[key].append_array(src[key])
	for index: int in src.indices:dst.indices.append(base+index)

func _add_mesh(label: String,bucket: Dictionary,material: Material) -> void:
	if bucket.indices.is_empty():return
	var arrays: Array=[];arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX]=PackedVector3Array(bucket.vertices);arrays[Mesh.ARRAY_NORMAL]=PackedVector3Array(bucket.normals);arrays[Mesh.ARRAY_TEX_UV]=PackedVector2Array(bucket.uvs);arrays[Mesh.ARRAY_INDEX]=PackedInt32Array(bucket.indices)
	var mesh:=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays);mesh.surface_set_material(0,material)
	var node:=MeshInstance3D.new();node.name=label;node.mesh=mesh;node.layers=1;add_child(node)

static func _door_frame(bucket: Dictionary,frame: Dictionary,center: Vector3,width: float,height: float) -> void:
	var t: Vector3=frame.tangent;var n: Vector3=frame.normal
	KIT.append_box(bucket,center+Vector3.UP*(height*.5+.055)+n*.022,t,n,width+.22,.11,.105)
	for sign_value: float in [-1.0,1.0]:KIT.append_box(bucket,center+t*sign_value*(width*.5+.055)+n*.022,t,n,.11,height,.105)

static func _beam(bucket: Dictionary,a: Vector3,b: Vector3,width: float) -> void:
	var direction: Vector3=(b-a).normalized()
	var side: Vector3=direction.cross(Vector3.UP).normalized() if absf(direction.dot(Vector3.UP))<.99 else Vector3.RIGHT
	var up: Vector3=side.cross(direction).normalized()
	var corners: Array[Vector3]=[]
	for point: Vector3 in [a,b]:
		corners.append_array([point-side*width*.5-up*width*.5,point+side*width*.5-up*width*.5,point+side*width*.5+up*width*.5,point-side*width*.5+up*width*.5])
	for spec: Array in [[0,1,2,3,-direction],[5,4,7,6,direction],[0,4,5,1,-up],[3,2,6,7,up],[0,3,7,4,-side],[1,5,6,2,side]]:
		KIT.append_quad(bucket,corners[spec[0]],corners[spec[1]],corners[spec[2]],corners[spec[3]],spec[4],Vector2.ZERO,Vector2(width,a.distance_to(b)))
