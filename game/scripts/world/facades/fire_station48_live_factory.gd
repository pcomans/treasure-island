class_name FireStation48LiveFactory
extends Node3D

const KIT := preload("res://game/scripts/world/facades/site_12_housing_kit.gd")
const UPPER_CLADDING := preload("res://game/resources/facades/fire_station48_upper_cladding.gdshader")
const CONFIG_PATH := "res://game/resources/facades/fire_station48_quality_study.json"
const WALL_KEY := "building:w764313741:wall"
const ROOF_KEY := "building:w764313741:roof"
const TARGET_RUNS := [0,1,2,3,5,6,8,9,24,25]
const PROTECTED_RUNS := [4,7,10,11,12,13,14,15,16,17,18,19,20,21,22,23]
var _tangent_builder:Callable
var _last_result:Dictionary={}

static func _json(path:String) -> Dictionary:
	var value:Variant=JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}
static func _record(records:Array,key:String) -> Dictionary:
	for row:Dictionary in records:
		if str(row.get("object_key",""))==key:return row
	return {}
static func matches_record_pair(wall:Dictionary,roof:Dictionary) -> bool:
	return str(wall.get("object_key",""))==WALL_KEY and str(roof.get("object_key",""))==ROOF_KEY
static func build_for_records(wall:Dictionary,roof:Dictionary,source_builder:Callable,tangent_builder:Callable) -> Dictionary:
	var node:=FireStation48LiveFactory.new()
	var result:=node.configure_records(wall,roof,source_builder,tangent_builder)
	if not bool(result.get("ok",false)):node.free()
	return result
func configure_records(wall:Dictionary,roof:Dictionary,source_builder:Callable,tangent_builder:Callable) -> Dictionary:
	if not _last_result.is_empty():return {"ok":false,"message":"Duplicate study construction."}
	if not source_builder.is_valid() or not tangent_builder.is_valid():return {"ok":false,"message":"Original source and tangent producers required."}
	_tangent_builder=tangent_builder
	var baseline:bool=false
	if not matches_record_pair(wall,roof) or not _valid_source_streams(wall,roof):
		return {"ok":false,"message":"Complete finite source wall/roof streams required before the runtime height override."}
	# Runtime game-art height override; frozen XZ and terrain-contact bottoms remain source-owned.
	wall=wall.duplicate(true);roof=roof.duplicate(true)
	for run in 26:
		wall.vertices[run*12+7]=7.60;wall.vertices[run*12+10]=7.60
	for index in range(1,roof.vertices.size(),3):roof.vertices[index]=7.60
	wall.top_elevation_m=7.60;roof.top_elevation_m=7.60
	var config:=_json(CONFIG_PATH)
	if not matches_record_pair(wall,roof):return {"ok":false,"message":"Exact source wall and roof pair required."}
	if not _same_numeric_runs(config.get("mapped_runs",[]),TARGET_RUNS) or not _same_numeric_runs(config.get("protected_runs",[]),PROTECTED_RUNS):return {"ok":false,"message":"Observed/protected scope changed."}
	if str(config.get("schema_version",""))!="ti.fire-station48-quality-study/1":return {"ok":false,"message":"Configured emission changed."}
	# Use the ordinary builder's consumed original streams/material partitions.
	var original_wall:Dictionary=source_builder.call(wall,false)
	var original_roof:Dictionary=source_builder.call(roof,false)
	if not bool(original_wall.get("ok",false)) or not bool(original_roof.get("ok",false)):
		if original_wall.has("node"):(original_wall.node as Node).free()
		if original_roof.has("node"):(original_roof.node as Node).free()
		return {"ok":false,"message":"Original source construction failed."}
	var wall_mesh:MeshInstance3D=(original_wall.node as Node3D).get_node("Mesh") as MeshInstance3D
	var roof_mesh:MeshInstance3D=(original_roof.node as Node3D).get_node("Mesh") as MeshInstance3D
	if wall_mesh.mesh.get_surface_count()!=1 or roof_mesh.mesh.get_surface_count()!=1:
		(original_wall.node as Node).free();(original_roof.node as Node).free()
		return {"ok":false,"message":"Original source material partition changed."}
	var protected:=KIT.new_bucket();var mapped:=KIT.new_bucket();var source_walls:=KIT.new_bucket();var source_roof:=KIT.new_bucket()
	for run in 26:
		_append_source_run(protected if run in PROTECTED_RUNS else mapped,wall,run,true)
		_append_source_run(source_walls,wall,run,true)
	_append_source_roof(source_roof,roof)
	var pale:=_public_wall_material(config)
	_add_original_wall_subset("ProtectedExactNeutralWallRuns",wall_mesh,wall,PROTECTED_RUNS,wall_mesh.get_active_material(0))
	_add_original_wall_subset("ObservedWSWNNWPaleWallFields",wall_mesh,wall,TARGET_RUNS,wall_mesh.get_active_material(0) if baseline else pale)
	var roof_copy:=MeshInstance3D.new();roof_copy.name="ExactSourceNeutralRoof"
	roof_copy.mesh=roof_mesh.mesh.duplicate();roof_copy.mesh.surface_set_material(0,_material("FS48_flat_membrane",Color(0.32,0.34,0.33),0.94));roof_copy.layers=roof_mesh.layers;roof_copy.cast_shadow=roof_mesh.cast_shadow;roof_copy.transform=roof_mesh.transform
	add_child(roof_copy)
	(original_wall.node as Node).free();(original_roof.node as Node).free()
	var buckets:Dictionary={"source_walls":source_walls,"source_roof":source_roof}
	var trim:=_material("FS48_complete_pale_surrounds",_color(config.materials.trim_rgb),.88)
	var glass:=_material("FS48_opaque_dark_glazing_no_interior",_color(config.materials.glass_rgb),.4)
	var edge:=_material("FS48_thin_roof_edge",_color(config.materials.edge_rgb),.89)
	if not baseline:
		var raw:Dictionary=_json(str(config.geometry_path)).buckets
		for label:String in raw:
			var bucket:=_decode_bucket(raw[label]);buckets[label]=bucket
			var material:Material=trim
			if label=="OpaqueHighWindowGlass":material=glass
			elif label=="ThinStraightPublicRoofEdge":material=edge
			_add_mesh(label,bucket,material)
	_build_entry(wall,buckets,trim,glass)
	var body:=StaticBody3D.new();body.name="ExactFootprintStructuralCollision_NoSprayOwnership";body.collision_layer=1;body.collision_mask=0
	body.set_meta("receiver_kind","none");body.set_meta("derived_object_key","prototype:"+WALL_KEY);body.set_meta("source_keys",["w764313741"])
	var counts:Dictionary={};var collision_total:=0
	for label:String in config.collision_groups:
		if baseline and label not in ["ExactClosedSourceWalls","ExactSourceNeutralRoof"]:continue
		var faces:=PackedVector3Array()
		for name:String in config.collision_groups[label]:
			var bucket:Dictionary=buckets[name]
			for index:int in bucket.indices:faces.append(bucket.vertices[index])
		var shape:=ConcavePolygonShape3D.new();shape.set_faces(faces);shape.set_meta("receiver_kind","none");shape.set_meta("structural_role",label)
		var shape_node:=CollisionShape3D.new();shape_node.name=label;shape_node.shape=shape;body.add_child(shape_node);counts[label]=faces.size()/3;collision_total+=faces.size()/3
	add_child(body)
	var batches:Dictionary={};var total:=0
	for child:Node in get_children():
		if child is MeshInstance3D:
			var count:int=child.mesh.surface_get_array_index_len(0)/3;batches[str(child.name)]=count;total+=count
	var metadata:Dictionary={"model_id":"fire-station48-whole-building-20261010","source_key":"w764313741","mapped_public_run_indices":TARGET_RUNS,"protected_run_indices":PROTECTED_RUNS,"baseline_exact_source":baseline,"source_xz_and_wall_bottoms_preserved":true,"source_roof_geometry_preserved":false,"interior_modeled":false,"source_terrain_untouched":true,"module_dimensions_and_counts":"production_inference","visual_batch_triangles":batches,"visual_triangles":total,"mesh_instances":batches.size(),"surfaces":batches.size(),"static_bodies":1,"shapes":counts.size(),"collision_triangles":collision_total,"collision_groups":counts,"complete_high_windows":0 if baseline else int(config.inference.window_count),"all_additions_render_only":false,"source_collision_only":false,"ground_detail_added":true}
	for key:String in metadata:set_meta(key,metadata[key])
	_last_result={"ok":true,"node":self,"metadata":metadata};return _last_result

static func _public_wall_material(config:Dictionary) -> ShaderMaterial:
	var material:=ShaderMaterial.new()
	material.resource_name="FS48_private_observed_upper_cladding"
	material.shader=UPPER_CLADDING
	material.set_shader_parameter("wall_color",_color(config.materials.wall_rgb))
	material.set_shader_parameter("head_color",_color(config.materials.band_rgb))
	for key:String in ["rib_period_m","rib_normal_slope","rib_albedo_amplitude","upper_start_y","upper_full_y"]:
		material.set_shader_parameter(key,float(config.private_wall_material[key]))
	material.set_shader_parameter("head_limits",Vector2(float(config.private_wall_material.head_line_y[0]),float(config.private_wall_material.head_line_y[1])))
	return material

static func _decode_bucket(raw:Dictionary) -> Dictionary:
	var out:=KIT.new_bucket()
	for i in range(0,raw.vertices.size(),3):out.vertices.append(_v(raw.vertices.slice(i,i+3)));out.normals.append(_v(raw.normals.slice(i,i+3)))
	for i in range(0,raw.uvs.size(),2):out.uvs.append(Vector2(float(raw.uvs[i]),float(raw.uvs[i+1])))
	for value:Variant in raw.indices:out.indices.append(int(value))
	return out
static func _color(rgb:Array) -> Color:
	return Color(float(rgb[0]),float(rgb[1]),float(rgb[2]))
static func _xz(values:Array,y:float) -> Vector3:
	return Vector3(float(values[0]),y,float(values[1]))
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

func _add_original_wall_subset(label:String,original:MeshInstance3D,record:Dictionary,runs:Array,material:Material) -> void:
	# Match the ordinary builder's pre-packing inputs and full index order.
	# Tangents are generated before the draw-index subset, never decoded/repacked.
	var vertices:=PackedVector3Array();var normals:=PackedVector3Array()
	var uvs:=PackedVector2Array();var original_indices:=PackedInt32Array()
	for index in range(0,record.vertices.size(),3):vertices.append(Vector3(float(record.vertices[index]),float(record.vertices[index+1]),float(record.vertices[index+2])))
	for index in range(0,record.normals.size(),3):normals.append(Vector3(float(record.normals[index]),float(record.normals[index+1]),float(record.normals[index+2])))
	for index in range(0,record.uvs.size(),2):uvs.append(Vector2(float(record.uvs[index]),float(record.uvs[index+1])))
	for index in range(0,record.indices.size(),3):original_indices.append_array([int(record.indices[index]),int(record.indices[index+2]),int(record.indices[index+1])])
	var arrays:Array=[];arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_NORMAL]=normals;arrays[Mesh.ARRAY_TEX_UV]=uvs
	arrays[Mesh.ARRAY_TANGENT]=_tangent_builder.call(vertices,normals,uvs,original_indices)
	var selected:=PackedInt32Array()
	for run:int in runs:selected.append_array(original_indices.slice(run*6,run*6+6))
	arrays[Mesh.ARRAY_INDEX]=selected
	var mesh:=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	mesh.surface_set_material(0,material);mesh.surface_set_name(0,original.mesh.surface_get_name(0))
	var node:=MeshInstance3D.new();node.name=label;node.mesh=mesh
	node.layers=original.layers;node.cast_shadow=original.cast_shadow;node.transform=original.transform;add_child(node)

func _add_mesh(label: String,bucket: Dictionary,material: Material) -> void:
	if bucket.indices.is_empty():return
	var arrays: Array=[];arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX]=PackedVector3Array(bucket.vertices);arrays[Mesh.ARRAY_NORMAL]=PackedVector3Array(bucket.normals);arrays[Mesh.ARRAY_TEX_UV]=PackedVector2Array(bucket.uvs);arrays[Mesh.ARRAY_INDEX]=PackedInt32Array(bucket.indices)
	# Match the existing world-builder tangent/handedness convention for these UVs.
	arrays[Mesh.ARRAY_TANGENT]=_tangent_builder.call(arrays[Mesh.ARRAY_VERTEX],arrays[Mesh.ARRAY_NORMAL],arrays[Mesh.ARRAY_TEX_UV],arrays[Mesh.ARRAY_INDEX])
	var mesh:=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays);mesh.surface_set_material(0,material)
	var node:=MeshInstance3D.new();node.name=label;node.mesh=mesh;node.layers=1;add_child(node)

# The observed entry/access family is placed on the long public host as production inference.
# Station/depth are in that host frame; the terrain preflight supports these modest elevations.
func _build_entry(wall:Dictionary,buckets:Dictionary,trim:Material,dark:Material) -> void:
	var frame:=_joined_frame(wall,0,3)
	var metal:=KIT.new_bucket();var door:=KIT.new_bucket();var surround:=KIT.new_bucket();var sign:=KIT.new_bucket()
	_box(door,frame,26.7,5.55,0.035,1.05,2.10,0.07)
	_box(surround,frame,26.09,5.55,0.07,0.12,2.34,0.14)
	_box(surround,frame,27.31,5.55,0.07,0.12,2.34,0.14)
	_box(surround,frame,26.7,6.66,0.07,1.34,0.12,0.14)
	_box(sign,frame,26.7,7.04,0.075,3.55,0.33,0.15)
	_box(metal,frame,27.04,5.48,0.105,0.035,0.24,0.08)
	# Landing top 4.50, thin deck and posts seated below the sampled local land.
	_box(metal,frame,26.5,4.43,0.88,5.0,0.14,1.76)
	for station:float in [24.08,26.5,28.92]:
		for depth:float in [0.14,1.62]:
			_box(metal,frame,station,3.87,depth,0.07,1.14,0.07)
	# Front railing leaves a 1.2m stair entry centred at station28.2.
	for bounds:Vector2 in [Vector2(24.0,27.56),Vector2(28.84,29.0)]:
		_box(metal,frame,(bounds.x+bounds.y)*0.5,5.51,1.70,bounds.y-bounds.x,0.045,0.045)
		_box(metal,frame,(bounds.x+bounds.y)*0.5,4.87,1.70,bounds.y-bounds.x,0.035,0.035)
		var count:=int(ceil((bounds.y-bounds.x)/0.16))
		for i in count+1:
			_box(metal,frame,lerpf(bounds.x,bounds.y,float(i)/maxi(count,1)),5.0,1.70,0.025,1.02,0.025)
	for station:float in [24.0,29.0]:
		_box(metal,frame,station,5.51,0.86,0.045,0.045,1.72)
		for i in 11:_box(metal,frame,station,5.0,0.08+i*0.16,0.025,1.02,0.025)
	# Reuse Chapel's visible/native sloping-support grammar. The metal walking
	# surface is continuous, deck-flush and seated below local LAND (~3.32),
	# within the existing 1.2m x 2.24m flight. Underlying tread ends retain the
	# fabricated flight rhythm; they cannot project above the walking surface.
	var slope_normal:Vector3=(Vector3.UP+frame.normal*(1.22/2.24)).normalized()
	for step in 7:
		var inner_depth:=1.76+float(step)*0.32
		var outer_depth:=inner_depth+0.32
		var inner_top:=lerpf(4.50,3.28,float(step)/7.0)
		var top:=lerpf(4.50,3.28,float(step+1)/7.0)
		var depth:=1.76+(float(step)+0.5)*0.32
		_box(metal,frame,28.2,top-0.055,depth,1.2,0.11,0.32)
		var a:=_point(frame,27.60,inner_top,inner_depth)
		var b:=_point(frame,28.80,inner_top,inner_depth)
		var c:=_point(frame,28.80,top,outer_depth)
		var d:=_point(frame,27.60,top,outer_depth)
		KIT.append_quad(metal,a,b,c,d,slope_normal,Vector2.ZERO,Vector2(1.2,0.32))
		# Close the plate sides against each horizontal tread, so the physical
		# sloping support is also visible fabrication rather than a hidden ramp.
		_triangle(metal,a,d,_point(frame,27.60,top,inner_depth),-frame.tangent)
		_triangle(metal,c,b,_point(frame,28.80,top,inner_depth),frame.tangent)
		for station:float in [27.60,28.80]:
			var mid_top:float=(inner_top+top)*0.5
			_box(metal,frame,station,(mid_top+3.20)*0.5,depth,0.055,mid_top-3.20,0.055)
			_box(metal,frame,station,mid_top+0.5,depth,0.035,1.0,0.035)
			_box(metal,frame,station,mid_top+1.0,depth,0.045,0.045,0.36)
	buckets["RaisedMetalAccess"]=metal
	buckets["ClosedEntryDoor"]=door
	buckets["EntrySurround"]=surround
	buckets["StationSign"]=sign
	_add_mesh("RaisedMetalAccess",metal,_material("FS48_galvanized_access",Color(0.52,0.56,0.56),0.56))
	_add_mesh("ClosedEntryDoor",door,dark)
	_add_mesh("EntrySurround",surround,trim)
	_add_mesh("StationSign",sign,_material("FS48_station_sign",Color(0.27,0.085,0.055),0.86))
	var label:=Label3D.new();label.name="Station48Lettering";label.text="SFFD STATION 48";label.font_size=64;label.pixel_size=0.004
	label.position=_point(frame,26.7,7.04,0.158);label.no_depth_test=false;label.outline_size=0
	label.modulate=Color(0.92,0.91,0.81);label.billboard=BaseMaterial3D.BILLBOARD_DISABLED
	label.rotation.y=atan2(frame.normal.x,frame.normal.z);add_child(label)

static func _box(bucket:Dictionary,frame:Dictionary,station:float,y:float,depth:float,width:float,height:float,thickness:float) -> void:
	KIT.append_box(bucket,_point(frame,station,y,depth),frame.tangent,frame.normal,width,height,thickness)

static func _valid_source_streams(wall:Dictionary,roof:Dictionary) -> bool:
	for record:Dictionary in [wall,roof]:
		for key:String in ["vertices","normals","uvs","indices"]:
			if not record.get(key) is Array or record[key].is_empty():return false
			for value:Variant in record[key]:
				if not (value is int or value is float) or not is_finite(float(value)):return false
		var vertices:int=record.vertices.size()/3
		if record.vertices.size()%3!=0 or record.normals.size()!=record.vertices.size() or record.uvs.size()!=vertices*2 or record.indices.size()%3!=0:return false
		for value:Variant in record.indices:
			if float(value)!=floorf(float(value)) or int(value)<0 or int(value)>=vertices:return false
	# Four vertices and six indices per scheduled wall run are this producer's layout.
	var runs:int=TARGET_RUNS.size()+PROTECTED_RUNS.size()
	return wall.vertices.size()==runs*12 and wall.indices.size()==runs*6
