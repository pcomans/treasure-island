class_name D51317GateviewLiveFactory
extends Node3D

const KIT := preload("res://game/scripts/world/facades/site_12_housing_kit.gd")
const MARKS := preload("res://game/resources/facades/d5_1317_siding_marks.gdshader")
const ROOF_MATERIAL := preload("res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres")
const SURFACE_TONE := preload("res://game/resources/facades/d5_1317_surface_tone.gdshader")
const CONCRETE_ALBEDO := preload("res://game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_diff_1k.jpg")
const CONCRETE_ROUGHNESS := preload("res://game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_rough_1k.jpg")
const CONFIG_PATH := "res://game/resources/facades/d5_1317_gateview_quality_study.json"
const CHUNK_PATH := "res://generated/world/chunks/x_-3__z_-2.json"
const WALL_KEY := "building:w95934125:wall"
const ROOF_KEY := "building:w95934125:roof"
const EXPECTED_CHUNK_SHA256 := "35bf23d64e860d39c5b79a98be7830f4f477143f7e9490c6739dec0627062d11"
const TARGET_RUNS := [10,13,14,15,17,20,22,24,26,27,29,31]
const PROTECTED_RUNS := [0,1,2,3,4,5,6,7,8,9,11,12,16,18,19,21,23,25,28,30,32,33]
const RECORD_HASHES := {"area:r17241151:x_-3__z_-2": "336bb7c5d763d853c19184da045cf4a114f25493ecf02a367ca1e0523d8bebd1", "area:r17241152:x_-3__z_-2": "104faf44f5234729b0411e75595abeec1888f867d0efa6a3d765aaa4f93d991e", "building:w95934125:roof": "ae444960fc7ae2d8cae3a7fa28637ecd06b9c17d691d3c69c146564d5c6874ef", "building:w95934125:wall": "3537997ae045f8022bbe4c6449cec82655797411e417397d15ace85fedc3a6ef", "land:w26767313:x_-3__z_-2": "9ff2ddf4241136939a8dbe377679ef9f30e4c17e229b91ffbafc117c03d47c04"}
var _last_result: Dictionary = {}

static func _json(path:String) -> Dictionary:
	var data:Variant=JSON.parse_string(FileAccess.get_file_as_string(path))
	return data as Dictionary if data is Dictionary else {}
static func _record(records:Array,key:String) -> Dictionary:
	for row:Dictionary in records:
		if str(row.get("object_key",""))==key:return row
	return {}
static func supplied_records_match(records:Dictionary) -> bool:
	if records.size()!=RECORD_HASHES.size():return false
	for key:String in RECORD_HASHES:
		if not records.get(key,null) is Dictionary or canonical_record_signature(records[key])!=str(RECORD_HASHES[key]):return false
	return true
static func build_for_records(wall:Dictionary,roof:Dictionary,neutral_wall:StandardMaterial3D,neutral_roof:StandardMaterial3D,supplied_records:Dictionary) -> Dictionary:
	var node:=D51317GateviewLiveFactory.new()
	var result:=node.configure_records(wall,roof,neutral_wall,neutral_roof,supplied_records)
	if not bool(result.get("ok",false)):node.free()
	return result

func configure_records(wall:Dictionary,roof:Dictionary,neutral_wall:StandardMaterial3D,neutral_roof:StandardMaterial3D,supplied_records:Dictionary,baseline:bool=false) -> Dictionary:
	if not _last_result.is_empty():return {"ok":false,"message":"Duplicate study construction."}
	var config:=_json(CONFIG_PATH)
	if not supplied_records_match(supplied_records) or wall!=supplied_records.get(WALL_KEY,{}) or roof!=supplied_records.get(ROOF_KEY,{}) or neutral_wall==null or neutral_roof==null:return {"ok":false,"message":"Exact source pair changed."}
	if not _same_numeric_runs(config.get("mapped_runs",[]),TARGET_RUNS) or not _same_numeric_runs(config.get("protected_runs",[]),PROTECTED_RUNS):return {"ok":false,"message":"Public/protected scope changed."}
	if str(config.get("schema_version",""))!="ti.d5-1317-quality-study/1" or FileAccess.get_sha256(str(config.geometry_path))!=str(config.geometry_sha256):return {"ok":false,"message":"Configured emission changed."}
	var truth:Dictionary=config.truth_boundary
	if not bool(truth.prototype_only) or bool(truth.runtime_attachment) or bool(truth.recognition_accepted) or bool(truth.interior_modeled) or bool(truth.as_built_claim):return {"ok":false,"message":"Study truth boundary changed."}
	var protected:=KIT.new_bucket();var mapped:=KIT.new_bucket();var source_roof:=KIT.new_bucket();var source_walls:=KIT.new_bucket()
	for run in 34:_append_source_run(protected if run in PROTECTED_RUNS else mapped,wall,run,true)
	for run in 34:_append_source_run(source_walls,wall,run,true)
	_append_source_roof(source_roof,roof)
	_add_mesh("ProtectedExactNeutralWallRuns",protected,neutral_wall)
	_add_mesh("ObservedENEHorizontalSidingFields",mapped,neutral_wall if baseline else _siding_material(config.materials.siding))
	_add_mesh("ExactSourceNeutralRoof",source_roof,neutral_roof)
	var buckets:Dictionary={"source_walls":source_walls,"source_roof":source_roof}
	var pale:=_material("1317_inferred_pale_trim",_color(config.materials.pale_trim_rgb),.91)
	var brown:=ROOF_MATERIAL.duplicate(true) as StandardMaterial3D
	brown.resource_name="1317_private_matte_brown_roof";brown.albedo_color=Color(.84,.64,.44);brown.roughness=.93;brown.metallic=0.0
	var main_roof:=_surface_tone("1317_private_readable_brown_main_roof",config.materials.main_roof_tone,false)
	main_roof.set_shader_parameter("source_albedo",brown.albedo_texture)
	var boarding:=_surface_tone("1317_private_subtle_board_grain",config.materials.boarding_tone,true)
	var concrete:=StandardMaterial3D.new();concrete.resource_name="1317_local_concrete_approaches_visual_only"
	concrete.albedo_texture=CONCRETE_ALBEDO;concrete.roughness_texture=CONCRETE_ROUGHNESS;concrete.albedo_color=Color(.85,.84,.80);concrete.roughness=.92;concrete.uv1_scale=Vector3(1.0/1.8,1.0/1.8,1.0);concrete.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	if not baseline:
		var raw:Dictionary=_json(str(config.geometry_path)).buckets
		for label:String in raw:
			var bucket:=_decode_bucket(raw[label]);buckets[label]=bucket
			var material:Material=pale
			if label in ["UpperWarmBoardedFields","ClosedGroundBoardedFields"]:material=boarding
			elif label=="UpperDarkOpaqueFields":material=_material("1317_dark_opaque_closed",_color(config.materials.dark_opaque_rgb),.91)
			elif label=="BrownCanopyTopsAndSides":material=brown
			elif label=="PublicShallowBrownMainRoof":material=main_roof
			elif label=="LocalConcretePorchesAndApproaches":material=concrete
			elif label=="PaleCanopyFrontGables":material=_siding_material(config.materials.siding)
			_add_mesh(label,bucket,material)
		_add_address_mark(wall,config)
	var body:=StaticBody3D.new();body.name="ExactFootprintStructuralCollision_NoSprayOwnership";body.collision_layer=1;body.collision_mask=0
	body.set_meta("receiver_kind","none");body.set_meta("derived_object_key","prototype:"+WALL_KEY);body.set_meta("source_keys",["w95934125"]);body.set_meta("prototype_only",true)
	var collision_counts:Dictionary={};var collision_total:=0
	for label:String in config.collision_groups:
		if baseline and label not in ["ExactClosedSourceWalls","ExactSourceNeutralRoof"]:continue
		var faces:=PackedVector3Array()
		for bucket_name:String in config.collision_groups[label]:
			var bucket:Dictionary=buckets[bucket_name]
			for index:int in bucket.indices:faces.append(bucket.vertices[index])
		var shape:=ConcavePolygonShape3D.new();shape.set_faces(faces);shape.set_meta("receiver_kind","none");shape.set_meta("structural_role",label)
		var node:=CollisionShape3D.new();node.name=label;node.shape=shape;body.add_child(node);collision_counts[label]=faces.size()/3;collision_total+=faces.size()/3
	add_child(body)
	var batches:Dictionary={};var triangles:=0
	for node:Node in get_children():
		if node is MeshInstance3D:
			var count:int=node.mesh.surface_get_array_index_len(0)/3;batches[str(node.name)]=count;triangles+=count
	var metadata:Dictionary={"prototype_only":true,"runtime_attachment":false,"recognition_accepted":false,"source_key":"w95934125","mapped_public_run_indices":TARGET_RUNS,"protected_run_indices":PROTECTED_RUNS,"baseline_exact_source":baseline,"original_roof_22_triangles_preserved":true,"public_shallow_roof_added":not baseline,"interior_modeled":false,"as_built_claim":false,"source_terrain_untouched":true,"module_dimensions_and_counts":"production_inference","visual_batch_triangles":batches,"visual_triangles":triangles,"mesh_instances":batches.size(),"surfaces":batches.size(),"static_bodies":1,"shapes":collision_counts.size(),"collision_triangles":collision_total,"collision_groups":collision_counts,"ground_module_groups":0 if baseline else 6,"canopies":0 if baseline else 3,"address_mark":"" if baseline else "1317","address_suffix_claim":false}
	for key:String in metadata:set_meta(key,metadata[key])
	_last_result={"ok":true,"node":self,"metadata":metadata}
	return _last_result

static func _decode_bucket(raw:Dictionary) -> Dictionary:
	var out:=KIT.new_bucket()
	for i in range(0,raw.vertices.size(),3):out.vertices.append(_v(raw.vertices.slice(i,i+3)));out.normals.append(_v(raw.normals.slice(i,i+3)))
	for i in range(0,raw.uvs.size(),2):out.uvs.append(Vector2(float(raw.uvs[i]),float(raw.uvs[i+1])))
	for value:Variant in raw.indices:out.indices.append(int(value))
	return out
static func _color(rgb:Array) -> Color:
	return Color(float(rgb[0]),float(rgb[1]),float(rgb[2]))
static func _surface_tone(label:String,spec:Dictionary,boarded:bool) -> ShaderMaterial:
	var material:=ShaderMaterial.new();material.shader=SURFACE_TONE;material.resource_name=label
	material.set_shader_parameter("low_color",_color(spec.low_rgb));material.set_shader_parameter("high_color",_color(spec.high_rgb));material.set_shader_parameter("boarded_grain",boarded)
	return material
static func _siding_material(spec:Dictionary) -> ShaderMaterial:
	var material:=ShaderMaterial.new();material.shader=MARKS;material.resource_name="1317_inferred_cream_world_y_siding"
	material.set_shader_parameter("base_color",_color(spec.base_rgb));material.set_shader_parameter("seam_color",_color(spec.seam_rgb));material.set_shader_parameter("roughness_value",float(spec.roughness))
	material.set_shader_parameter("course_height_m",float(spec.course_height_m));material.set_shader_parameter("phase_offset_m",float(spec.phase_y));material.set_shader_parameter("seam_half_width_cycles",.006/(2.0*float(spec.course_height_m)))
	material.set_shader_parameter("relief_strength",float(spec.relief_strength));material.set_shader_parameter("color_variation",float(spec.color_variation))
	return material
func _add_address_mark(wall:Dictionary,config:Dictionary) -> void:
	var spec:Dictionary=config.address_mark;var f:=_joined_frame(wall,29,29);var group:Dictionary=config.ground_groups[-1]
	var label:=Label3D.new();label.name="Observed1317_NoSuffixClaim";label.text="1317";label.font_size=48;label.pixel_size=.00165;label.modulate=Color(.22,.22,.19);label.outline_size=0;label.shaded=true;label.no_depth_test=false;label.billboard=BaseMaterial3D.BILLBOARD_DISABLED;label.double_sided=false
	label.position=_point(f,float(f.length_m)*float(spec.proposed_host_fraction),float(group.local_visible_datum_y)+float(spec.height_above_group_datum_m),.15)
	label.basis=Basis(f.tangent,Vector3.UP,f.normal);add_child(label)
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
			if not is_finite(number):return "__NON_FINITE__"
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

