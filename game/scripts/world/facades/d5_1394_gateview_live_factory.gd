class_name D51394GateviewLiveFactory
extends Node3D

const MARKS := preload("res://game/resources/facades/d5_1394_siding_marks.gdshader")
const KIT := preload("res://game/scripts/world/facades/site_12_housing_kit.gd")
const CONFIG_PATH := "res://game/resources/facades/d5_1394_gateview_live_factory.json"
const SOURCE_KEY := "w96215646"
const WALL_KEY := "building:w96215646:wall"
const ROOF_KEY := "building:w96215646:roof"
const SOURCE_GEOMETRY_SHA256 := "b0e6c7426ac41c995f96a647ff5102b4d85963d2b7a45f21ad1b81455e451220"
const TARGET_RUNS := [1, 2, 3, 4, 15, 16, 17, 18, 20, 21, 22, 23]
const PROTECTED_RUNS := [0, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 19]
const IVORY := preload("res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres")
const DARK_ROOF := preload("res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres")
const METAL := preload("res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres")
const RECORD_HASHES := {"area:r17241151:x_-2__z_-3": "462c4532716ddaa63c66d0c11300771ee7eb1089c27565037fb2e148b85c5d7c", "building:w96215646:roof": "299f27cd69cc90668bdd31cb076d083ee1bf98e28b0031cdbe4e38bfd0c2cc51", "building:w96215646:wall": "222fc29f2d1526d983f4653dc8ae157aa98575dbbfb16c89898827a26dc26019", "land:w26767313:x_-2__z_-3": "17c60f0f623bf919bd05c0ebc4ae93c06cce0c33a5603725175f3c4754572c02"}
var _last_result: Dictionary = {}

static func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}

static func _record(records: Array, key: String) -> Dictionary:
	for value: Dictionary in records:
		if str(value.get("object_key", "")) == key: return value
	return {}

static func build_for_records(wall: Dictionary, roof: Dictionary, neutral_wall: StandardMaterial3D, neutral_roof: StandardMaterial3D, supplied_records: Dictionary) -> Dictionary:
	var model := D51394GateviewLiveFactory.new()
	var result := model.configure_records(wall, roof, neutral_wall, neutral_roof, supplied_records)
	if not bool(result.get("ok", false)): model.free()
	return result

func configure_records(wall: Dictionary, roof: Dictionary, neutral_wall: StandardMaterial3D, neutral_roof: StandardMaterial3D, supplied_records: Dictionary, baseline: bool = false) -> Dictionary:
	if not _last_result.is_empty():return {"ok":false,"message":"Duplicate detached study configuration."}
	var config:=_json(CONFIG_PATH)
	if FileAccess.get_sha256(CONFIG_PATH)!="4f025e33c79465a936e64aef7e8f72af1fca44c1165b031df9c13b2652a55d8b" or not supplied_records_match(supplied_records) or wall!=supplied_records.get(WALL_KEY,{}) or roof!=supplied_records.get(ROOF_KEY,{}) or neutral_wall==null or neutral_roof==null:return {"ok":false,"message":"Exact supplied pair/grade/config/material boundary changed."}
	if not _same_numeric_runs(config.get("mapped_runs",[]),TARGET_RUNS) or not _same_numeric_runs(config.get("protected_runs",[]),PROTECTED_RUNS) or str(config.get("schema_version",""))!="ti.d5-1394-gateview-live-factory/1":return {"ok":false,"message":"1394 scope changed."}
	var truth:Dictionary=config.truth_boundary
	if not bool(truth.prototype_only) or bool(truth.runtime_attachment) or bool(truth.recognition_accepted) or bool(truth.interior_modeled) or bool(truth.as_built_claim):return {"ok":false,"message":"Detached truth boundary changed."}
	var inf:Dictionary=config.inference
	var protected:=KIT.new_bucket();var mapped:=KIT.new_bucket()
	for run in 24:_append_source_run(protected if run in PROTECTED_RUNS else mapped,wall,run,true)
	_add_mesh("ProtectedExactNeutralWallRuns",protected,neutral_wall)
	_add_mesh("ObservedWHorizontalSidingFields",mapped,neutral_wall if baseline else _siding_material(inf))
	var walls:=KIT.new_bucket();_merge(walls,protected);_merge(walls,mapped)
	var roof_bucket:=KIT.new_bucket();_append_source_roof(roof_bucket,roof)
	_add_mesh("ExactSourceNeutralRoof",roof_bucket,neutral_roof)
	var structure:=KIT.new_bucket();var ground_collision:=KIT.new_bucket()
	if not baseline:
		var glazing:=KIT.new_bucket();var trim:=KIT.new_bucket();var canopy_roofs:=KIT.new_bucket();var posts:=KIT.new_bucket();var canopy_edges:=KIT.new_bucket()
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
		_flat_canopy(canopy_roofs,canopy_edges,posts,inf)
		_add_mesh("RepeatedOpaqueUpperSliders",glazing,dark)
		_add_mesh("RestrainedRealWindowAndCanopyTrim",trim,pale)
		_add_mesh("ContinuousFlatCanopyRoof",canopy_roofs,DARK_ROOF)
		_apply_post_grade(posts,config.ground_grade)
		_add_mesh("RealCanopyFrontSupports",posts,_material("slender_weathered_posts",Color(.61,.59,.53),.94))
		_add_mesh("ContinuousFlatCanopyFasciaAndSoffit",canopy_edges,pale)
		_merge(structure,canopy_roofs);_merge(structure,canopy_edges);_merge(structure,posts)
		var ground_fields:=KIT.new_bucket();var ground_glass:=KIT.new_bucket();var ground_frames:=KIT.new_bucket();var ground_handles:=KIT.new_bucket()
		_ground_modules(ground_fields,ground_glass,ground_frames,ground_handles,wall,inf)
		_apply_ground_grade(ground_fields,ground_glass,ground_frames,ground_handles,config.ground_grade)
		_add_mesh("GroundClosedDoorsAndPrivacyPanels",ground_fields,_material("quiet_white_closed_ground_fields",Color(.84,.85,.81),.9))
		_add_mesh("GroundOpaqueWindowGlass",ground_glass,dark)
		_add_mesh("GroundModuleFrames",ground_frames,pale)
		_add_mesh("GroundDoorHandles",ground_handles,_material("restrained_dark_door_handles",Color(.23,.25,.24),.66))
		for bucket:Dictionary in [ground_fields,ground_glass,ground_frames,ground_handles]:_merge(ground_collision,bucket)

	var body:=StaticBody3D.new();body.name="ExactFootprintStructuralCollision_NoSprayOwnership";body.collision_layer=1;body.collision_mask=0
	body.set_meta("receiver_kind","none");body.set_meta("opaque",true);body.set_meta("derived_object_key",WALL_KEY if baseline else "prototype:"+WALL_KEY);body.set_meta("source_keys",[SOURCE_KEY]);body.set_meta("prototype_only",true)
	var collisions:Dictionary={"ExactClosedSourceWalls":walls,"ExactSourceNeutralRoof":roof_bucket}
	if not baseline:collisions.merge({"ContinuousFlatCanopyAndPosts":structure,"OpaqueClosedGroundModuleAssemblies":ground_collision})
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
	var metadata:Dictionary={"model_id":"d5-1394-gateview-detached-observed-side-study-v1","baseline_exact_source":baseline,"prototype_only":true,"runtime_attachment":false,"recognition_accepted":false,"as_built_claim":false,"interior_modeled":false,"source_key":SOURCE_KEY,"mapped_public_run_indices":TARGET_RUNS,"protected_run_indices":PROTECTED_RUNS,"visual_batch_triangles":batches,"visual_triangles":total,"mesh_instances":batches.size(),"surfaces":batches.size(),"static_bodies":1,"shapes":collisions.size(),"collision_triangles":collision_triangles,"protected_runs_have_facade_modules":false,"roof_geometry_material_unchanged":true,"ground_voids_open_with_real_roof_posts_and_closed_source_backs":not baseline,"stairs_added":false,"ground_module_groups":0 if baseline else 6,"ground_module_schedule":"production_inference_closed_static_no_interior","module_dimensions_and_counts":"production_inference","deterministic_signature":JSON.stringify(batches).sha256_text()}
	metadata["ground_mounting"]="absent" if baseline else "actual_visible_datum_with_closed_bases_20mm_into_land"
	metadata["historical_flat_study_datum_y"]=float(config.ground_grade.historical_flat_study_datum_y)
	metadata["actual_ground_group_datums"]=[]
	metadata["actual_post_bottoms"]=[]
	if not baseline:
		for group:Dictionary in config.ground_grade.groups:metadata.actual_ground_group_datums.append(float(group.local_visible_datum_y))
		for post:Dictionary in config.ground_grade.posts:metadata.actual_post_bottoms.append(float(post.bottom_y))
	for key:String in metadata:set_meta(key,metadata[key])
	_last_result={"ok":true,"node":self,"metadata":metadata,"mesh_instances":batches.size(),"surfaces":batches.size(),"visual_triangles":total,"static_bodies":1,"shapes":collisions.size(),"collision_triangles":collision_triangles}
	return _last_result

static func _siding_material(inf:Dictionary) -> ShaderMaterial:
	var material:=ShaderMaterial.new();material.shader=MARKS;material.resource_name="inferred_quiet_cool_gray_horizontal_siding"
	material.set_shader_parameter("base_color",Color(.65,.69,.70));material.set_shader_parameter("seam_color",Color(.50,.55,.57));material.set_shader_parameter("roughness_value",.87)
	material.set_shader_parameter("course_height_m",float(inf.siding_course_m));material.set_shader_parameter("phase_offset_m",float(inf.siding_phase_y));material.set_shader_parameter("seam_half_width_cycles",.006/(2.0*float(inf.siding_course_m)))
	material.set_shader_parameter("relief_strength",.02);material.set_shader_parameter("color_variation",0.0)
	return material

static func _ground_modules(fields:Dictionary,glazing:Dictionary,frames:Dictionary,handles:Dictionary,wall:Dictionary,inf:Dictionary) -> void:
	var g:Dictionary=inf.ground_modules
	for group:Array in inf.upper_window_groups:
		var f:=_joined_frame(wall,int(group[0]),int(group[-1]))
		for fraction:float in g.center_fractions:
			var station:=float(f.length_m)*fraction
			var door_center:=_point(f,station+float(g.door_offset_m),2.949+float(g.door_height_m)*.5,float(g.base_depth_m)+float(g.field_depth_m)*.5)
			KIT.append_box(fields,door_center,f.tangent,f.normal,float(g.door_width_m),float(g.door_height_m),float(g.field_depth_m))
			# Three-sided frame; no raised threshold or traversable opening.
			var frame_center:=door_center+(f.normal as Vector3)*(float(g.field_depth_m)*.5+float(g.frame_depth_m)*.5)
			KIT.append_box(frames,frame_center+Vector3.UP*(float(g.door_height_m)*.5+float(g.frame_width_m)*.5),f.tangent,f.normal,float(g.door_width_m)+2.0*float(g.frame_width_m),float(g.frame_width_m),float(g.frame_depth_m))
			for sign_value:float in [-1.0,1.0]:KIT.append_box(frames,frame_center+(f.tangent as Vector3)*sign_value*(float(g.door_width_m)*.5+float(g.frame_width_m)*.5),f.tangent,f.normal,float(g.frame_width_m),float(g.door_height_m),float(g.frame_depth_m))
			KIT.append_box(handles,_point(f,station+float(g.door_offset_m)+.28,2.949+1.02,float(g.base_depth_m)+float(g.field_depth_m)+.015),f.tangent,f.normal,.14,.035,.03)
			var window_center:=_point(f,station+float(g.window_offset_m),2.949+float(g.window_bottom_above_base_m)+float(g.window_height_m)*.5,float(g.base_depth_m))
			KIT.append_grouped_opening(glazing,frames,window_center,f.tangent,f.normal,float(g.window_width_m),float(g.window_height_m),float(g.field_depth_m),float(g.frame_width_m),float(g.frame_depth_m),.045)
			KIT.append_box(fields,_point(f,station+float(g.privacy_panel_offset_m),2.949+float(g.privacy_panel_height_m)*.5,float(g.base_depth_m)+float(g.field_depth_m)*.5),f.tangent,f.normal,float(g.privacy_panel_width_m),float(g.privacy_panel_height_m),float(g.field_depth_m))

static func _flat_canopy(top:Dictionary,edges:Dictionary,posts:Dictionary,inf:Dictionary) -> void:
	var outline:=PackedVector2Array()
	for p:Array in inf.canopy_outline_xz:outline.append(Vector2(float(p[0]),float(p[1])))
	var triangles:=Geometry2D.triangulate_polygon(outline)
	assert(triangles.size()==(outline.size()-2)*3,"Continuous canopy outline must triangulate completely.")
	var ytop:=float(inf.canopy_top_y);var ybottom:=float(inf.canopy_soffit_y)
	for i in range(0,triangles.size(),3):
		var a:=outline[triangles[i]];var b:=outline[triangles[i+1]];var c:=outline[triangles[i+2]]
		_triangle(top,Vector3(a.x,ytop,a.y),Vector3(b.x,ytop,b.y),Vector3(c.x,ytop,c.y),Vector3.UP)
		_triangle(edges,Vector3(a.x,ybottom,a.y),Vector3(b.x,ybottom,b.y),Vector3(c.x,ybottom,c.y),Vector3.DOWN)
	# Only front and terminal fascia: exact opaque source walls close the rear.
	# Rear wall faces are not duplicated; no coplanar finish is laid on protected returns.
	for i in range(int(inf.canopy_rear_point_count)-1,outline.size()):
		var a:=outline[i];var b:=outline[(i+1)%outline.size()]
		var midpoint:=(a+b)*.5;var outward:=Vector3(b.y-a.y,0,a.x-b.x).normalized()
		if Geometry2D.is_point_in_polygon(midpoint+Vector2(outward.x,outward.z)*.01,outline):outward=-outward
		_quad(edges,Vector3(a.x,ybottom,a.y),Vector3(b.x,ybottom,b.y),Vector3(b.x,ytop,b.y),Vector3(a.x,ytop,a.y),outward)
	var front_start:=Vector3(float(inf.canopy_front_start_xz[0]),0,float(inf.canopy_front_start_xz[1]))
	var front_end:=Vector3(float(inf.canopy_front_end_xz[0]),0,float(inf.canopy_front_end_xz[1]))
	var tangent:=(front_end-front_start).normalized();var normal:=Vector3(-tangent.z,0,tangent.x)
	var intervals:=maxi(1,int(ceil(front_start.distance_to(front_end)/float(inf.post_pitch_max_m))))
	for i in intervals+1:
		var p:=front_start.lerp(front_end,float(i)/float(intervals))-normal*float(inf.post_width)*.5
		p+=tangent*(float(inf.post_width)*.5 if i==0 else (-float(inf.post_width)*.5 if i==intervals else 0.0))
		p.y=(2.949+ybottom)*.5
		KIT.append_box(posts,p,tangent,normal,float(inf.post_width),ybottom-2.949,float(inf.post_width))

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

static func _apply_post_grade(posts:Dictionary,grade:Dictionary) -> void:
	for i in grade.posts.size():
		var spec:Dictionary=grade.posts[i]
		for j in range(i*24,i*24+24):
			var p:Vector3=posts.vertices[j]
			if absf(p.y-float(spec.old_bottom_y))<.000001:p.y=float(spec.bottom_y);posts.vertices[j]=p

static func _apply_ground_grade(fields:Dictionary,glazing:Dictionary,frames:Dictionary,handles:Dictionary,grade:Dictionary) -> void:
	var buckets:Dictionary={"GroundClosedDoorsAndPrivacyPanels":fields,"GroundOpaqueWindowGlass":glazing,"GroundModuleFrames":frames,"GroundDoorHandles":handles}
	var group_vertex_counts:Dictionary={"GroundClosedDoorsAndPrivacyPanels":48,"GroundOpaqueWindowGlass":24,"GroundModuleFrames":192,"GroundDoorHandles":24}
	for group_index in grade.groups.size():
		var group:Dictionary=grade.groups[group_index];var delta:float=group.translation_y_m
		for name:String in buckets:
			var bucket:Dictionary=buckets[name];var count:int=group_vertex_counts[name]
			for i in range(group_index*count,(group_index+1)*count):
				var p:Vector3=bucket.vertices[i];p.y+=delta;bucket.vertices[i]=p
		for spec:Dictionary in group.closed_components:
			var bucket:Dictionary=buckets[str(spec.mesh)];var box:int=int(spec.box)
			for i in range(box*24,box*24+24):
				var p:Vector3=bucket.vertices[i]
				if absf(p.y-float(spec.old_bottom_y)-delta)<.000001:p.y=float(spec.bottom_y);bucket.vertices[i]=p

static func supplied_records_match(records: Dictionary) -> bool:
	if records.size()!=4:return false
	for key:String in RECORD_HASHES:
		if not (records.get(key,null) is Dictionary) or canonical_record_signature(records[key])!=str(RECORD_HASHES[key]):return false
	return true

static func canonical_record_signature(record: Dictionary) -> String:
	return (_stable_json(record, 0) + "\n").sha256_text()

static func _stable_json(value: Variant, depth: int) -> String:
	match typeof(value):
		TYPE_NIL:
			return "null"
		TYPE_BOOL:
			return "true" if bool(value) else "false"
		TYPE_INT:
			return str(int(value))
		TYPE_FLOAT:
			var number := float(value)
			if not is_finite(number): return "__NON_FINITE__"
			return str(int(number)) if number == floor(number) else JSON.stringify(number)
		TYPE_STRING, TYPE_STRING_NAME:
			return JSON.stringify(str(value))
		TYPE_ARRAY:
			var values := value as Array
			if values.is_empty():
				return "[]"
			var lines: Array[String] = []
			for item: Variant in values:
				lines.append(" ".repeat((depth + 1) * 2) + _stable_json(item, depth + 1))
			return "[\n%s\n%s]" % [",\n".join(lines), " ".repeat(depth * 2)]
		TYPE_DICTIONARY:
			var object := value as Dictionary
			if object.is_empty():
				return "{}"
			var keys: Array[String] = []
			for key: Variant in object.keys():
				keys.append(str(key))
			keys.sort()
			var lines: Array[String] = []
			for key: String in keys:
				lines.append(" ".repeat((depth + 1) * 2) + JSON.stringify(key) + ": " + _stable_json(object[key], depth + 1))
			return "{\n%s\n%s}" % [",\n".join(lines), " ".repeat(depth * 2)]
	return JSON.stringify(value)

