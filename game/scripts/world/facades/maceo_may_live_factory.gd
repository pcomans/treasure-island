class_name MaceoMayLiveFactory
extends Node3D

const KIT := preload("res://game/scripts/world/facades/site_12_housing_kit.gd")
const UPPER_CLADDING := preload("res://game/resources/facades/maceo_may_public_fields.gdshader")
const CONFIG_PATH := "res://game/resources/facades/maceo_may_quality_study.json"
const WALL_KEY := "building:r19685981:wall"
const ROOF_KEY := "building:r19685981:roof"
const TARGET_RUNS := [8, 9, 10, 11, 12, 13, 14, 15, 16]
# Unphotographed outer WSW (0-6) and NNW (17-20) faces inherit the observed ENE
# bay grid (L2 all-sides audit 2026-11-03; production_inference).
const INFERRED_RUNS := [0, 1, 2, 3, 4, 5, 6, 17, 18, 19, 20]
# Run 7 and the inner courtyard ring stay as they were.
const PROTECTED_RUNS := [7, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39]
# The observed ENE bay, decoded from the reviewed ENE geometry: per upper storey
# a 3.44 x 2.68 m pale frame around a graphite recess with two glazed lights, a
# rail and a louvre band; on the graphite base two tall narrow framed lights.
const GRID_FLOOR_Y := [7.93, 10.83, 13.73, 16.63, 19.53]
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
	var node:Node3D=load("res://game/scripts/world/facades/maceo_may_live_factory.gd").new()
	var result:Dictionary=node.call("configure_records",wall,roof,source_builder,tangent_builder)
	if not bool(result.get("ok",false)):node.free()
	return result
func configure_records(wall:Dictionary,roof:Dictionary,source_builder:Callable,tangent_builder:Callable) -> Dictionary:
	if not _last_result.is_empty():return {"ok":false,"message":"Duplicate study construction."}
	if not source_builder.is_valid() or not tangent_builder.is_valid():return {"ok":false,"message":"Original source and tangent producers required."}
	_tangent_builder=tangent_builder
	var baseline:bool=false
	var config:=_json(CONFIG_PATH)
	if not matches_record_pair(wall,roof):return {"ok":false,"message":"Exact source wall and roof pair required."}
	if not _same_numeric_runs(config.get("mapped_runs",[]),TARGET_RUNS) or not _same_numeric_runs(config.get("protected_runs",[]),PROTECTED_RUNS):return {"ok":false,"message":"Observed/protected scope changed."}
	if not _same_numeric_runs(config.get("inferred_runs",[]),INFERRED_RUNS) or not _inferred_grid_valid(config.get("inferred_grid",{})):return {"ok":false,"message":"Inferred grid scope changed."}
	if str(config.get("schema_version",""))!="ti.maceo-may-quality-study/1":return {"ok":false,"message":"Configured emission changed."}
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
	for run in 40:
		_append_source_run(protected if run in PROTECTED_RUNS else mapped,wall,run,true)
		_append_source_run(source_walls,wall,run,true)
	_append_source_roof(source_roof,roof)
	var pale:=_public_wall_material(config)
	_add_original_wall_subset("ProtectedExactNeutralWallRuns",wall_mesh,wall,PROTECTED_RUNS,wall_mesh.get_active_material(0))
	_add_original_wall_subset("ObservedENESSEWallFields",wall_mesh,wall,TARGET_RUNS,wall_mesh.get_active_material(0) if baseline else pale)
	_add_original_wall_subset("InferredWSWNNWWallFields",wall_mesh,wall,INFERRED_RUNS,wall_mesh.get_active_material(0) if baseline else pale)
	var roof_copy:=MeshInstance3D.new();roof_copy.name="ExactSourceNeutralRoof"
	roof_copy.mesh=roof_mesh.mesh;roof_copy.layers=roof_mesh.layers;roof_copy.cast_shadow=roof_mesh.cast_shadow;roof_copy.transform=roof_mesh.transform
	add_child(roof_copy)
	(original_wall.node as Node).free();(original_roof.node as Node).free()
	var buckets:Dictionary={"source_walls":source_walls,"source_roof":source_roof}
	if not baseline:
		var raw:Dictionary=_json(str(config.geometry_path)).buckets
		for label:String in raw:buckets[label]=_decode_bucket(raw[label])
		_append_inferred_grid(buckets,wall,config.inferred_grid.faces)
		for label:String in raw:
			var family:String=str(config.bucket_materials[label])
			var material:=_material("MM_"+family,_color(config.materials[family+"_rgb"]),.42 if family=="glass" else .88)
			_add_mesh(label,buckets[label],material)
	var body:=StaticBody3D.new();body.name="ExactFootprintStructuralCollision_NoSprayOwnership";body.collision_layer=1;body.collision_mask=0
	body.set_meta("receiver_kind","none");body.set_meta("derived_object_key","prototype:"+WALL_KEY);body.set_meta("source_keys",["r19685981"])
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
	var metadata:Dictionary={"model_id":"maceo-may-first-coherent-study-001","source_key":"r19685981","mapped_public_run_indices":TARGET_RUNS,"inferred_grid_run_indices":INFERRED_RUNS,"inferred_grid_bays":0 if baseline else _inferred_bay_count(config.inferred_grid.faces),"protected_run_indices":PROTECTED_RUNS,"baseline_exact_source":baseline,"original80wall16roof_triangles_preserved":true,"source_roof_geometry_preserved":true,"interior_modeled":false,"source_terrain_untouched":true,"module_dimensions_and_counts":"production_inference","visual_batch_triangles":batches,"visual_triangles":total,"mesh_instances":batches.size(),"surfaces":batches.size(),"static_bodies":1,"shapes":counts.size(),"collision_triangles":collision_total,"collision_groups":counts,"complete_high_windows":0 if baseline else int(config.inference.window_count),"all_additions_render_only":false,"source_collision_only":false,"ground_detail_added":true,"added_collision_scope":"Five round entrance columns only; visible faces and collision identical."}
	for key:String in metadata:set_meta(key,metadata[key])
	_last_result={"ok":true,"node":self,"metadata":metadata};return _last_result

static func _inferred_bay_count(faces:Array) -> int:
	var bays:=0
	for face:Dictionary in faces:bays+=int(face.bays)
	return bays

static func _inferred_grid_valid(grid:Variant) -> bool:
	if not grid is Dictionary or not (grid as Dictionary).get("faces") is Array:return false
	var seen:Array=[]
	for face:Variant in grid.faces:
		if not face is Dictionary or not face.get("runs") is Array or face.runs.size()!=2:return false
		var first:=int(face.runs[0]);var last:=int(face.runs[1]);var bays:=int(face.get("bays",0))
		if first>last or bays<1:return false
		for run in range(first,last+1):
			if run not in INFERRED_RUNS or run in seen:return false
			seen.append(run)
	return seen.size()==INFERRED_RUNS.size()

# Each inferred face is one straight run chain; its bays are centred in equal
# cells along it, at the ENE storey lines (cadence and count are production
# inference). Render-only detail in the existing ENE batches and materials.
static func _append_inferred_grid(buckets:Dictionary,wall:Dictionary,faces:Array) -> void:
	var pale:Dictionary=buckets.PaleCompleteENEFrames;var graphite:Dictionary=buckets.GraphiteRecessAndMullions
	var glass:Dictionary=buckets.OpaqueBlueGrayGlazing;var louver:Dictionary=buckets.GraphiteLouvers
	for face:Dictionary in faces:
		var frame:=_joined_frame(wall,int(face.runs[0]),int(face.runs[1]))
		var bays:=int(face.bays);var pitch:float=float(frame.length_m)/bays
		for bay in bays:
			var c0:=pitch*(float(bay)+0.5)
			for y0:float in GRID_FLOOR_Y:
				_box(pale,frame,c0,y0+0.17,0.1525,3.44,0.34,0.215)
				_box(pale,frame,c0,y0+2.51,0.1525,3.44,0.34,0.215)
				_box(graphite,frame,c0,y0+1.34,0.0335,2.76,2.0,0.043)
				_box(louver,frame,c0,y0+2.165,0.0925,2.66,0.25,0.035)
				for side:float in [-1.0,1.0]:
					_box(pale,frame,c0+side*1.55,y0+1.34,0.1525,0.34,2.0,0.215)
					_box(glass,frame,c0+side*0.83,y0+1.22,0.0645,0.98,1.62,0.013)
					_box(graphite,frame,c0+side*0.83,y0+0.8025,0.087,0.98,0.045,0.03)
			for side:float in [-1.0,1.0]:
				var s:=c0+side*0.78
				_box(glass,frame,s,6.115,0.031,0.58,2.8,0.026)
				_box(graphite,frame,s,4.6875,0.056,0.69,0.055,0.088)
				_box(graphite,frame,s,7.5425,0.056,0.69,0.055,0.088)
				for edge:float in [-1.0,1.0]:
					_box(graphite,frame,s+edge*0.3175,6.115,0.056,0.055,2.8,0.088)

static func _box(bucket:Dictionary,frame:Dictionary,station:float,y:float,depth:float,width:float,height:float,thickness:float) -> void:
	KIT.append_box(bucket,_point(frame,station,y,depth),frame.tangent,frame.normal,width,height,thickness)

static func _public_wall_material(config:Dictionary) -> ShaderMaterial:
	var material:=ShaderMaterial.new()
	material.resource_name="MM_private_observed_ENE_SSE_fields"
	material.shader=UPPER_CLADDING
	for key:String in ["wall","graphite"]:material.set_shader_parameter(key+"_color",_color(config.materials[key+"_rgb"]))
	for key:String in ["upper_start_y","rib_period_m","rib_albedo_amplitude","sse_corner_start_m"]:material.set_shader_parameter(key,float(config.private_wall_material[key]))
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
