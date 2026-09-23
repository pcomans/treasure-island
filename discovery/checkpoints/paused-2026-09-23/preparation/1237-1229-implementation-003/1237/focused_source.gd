extends SceneTree
const MODEL := preload("res://game/scripts/world/facades/northpoint_1237_study.gd")
const WORK := "/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1237-1229-implementation-003/1237"
var failures: Array[String] = []
var checks := 0
func _initialize() -> void:
	call_deferred("_run")
func _check(ok: bool, message: String) -> void:
	checks += 1
	if not ok and message not in failures: failures.append(message)
func _run() -> void:
	var pins := MODEL._json(WORK + "/../source-pins.json")
	for path: String in pins: _check(FileAccess.get_sha256(path) == str(pins[path]), "Frozen input: " + path)
	var cfg := MODEL._json(MODEL.CONFIG_PATH)
	var projection := MODEL._json(WORK + "/PREFLIGHT_RESULT.json")
	_check(bool(projection.get("ok", false)), "Changed projection/site/framing file checks.")
	var preflight := MODEL._json("/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1237-1229-implementation-003/1237/PREFLIGHT_RESULT.json")
	_check(bool(preflight.get("ok", false)), "File preflight of corrected outward footprints and proposed capture geometry.")
	var records: Array = MODEL._json(MODEL.CHUNK_PATH).records
	var wall := MODEL._record(records, MODEL.WALL_KEY); var roof := MODEL._record(records, MODEL.ROOF_KEY)
	_check(wall.vertices.size() == 324 and wall.indices.size() == 162 and roof.vertices.size() == 51 and roof.indices.size() == 45, "Exact target wall roof cardinality.")
	if not failures.is_empty(): _finish({}); return
	var built := MODEL.build_for_records(wall, roof)
	_check(bool(built.get("ok", false)), "Bounded target construction.")
	if not bool(built.get("ok", false)): _finish({}); return
	var node: Node3D = built.node as Node3D
	_check(MODEL._same_numeric_runs(built.metadata.mapped_public_run_indices, MODEL.TARGET_RUNS) and MODEL._same_numeric_runs(built.metadata.protected_run_indices, MODEL.PROTECTED_RUNS), "Exact accepted narrower front-only run partition; returns remain untouched.")
	var builder := MODEL.BUILDER.new()
	var original_wall: Dictionary = builder._build_record(wall, false)
	var original_roof: Dictionary = builder._build_record(roof, false)
	_check(bool(original_wall.get("ok", false)) and bool(original_roof.get("ok", false)), "Independent ordinary original pair construction.")
	if not bool(original_wall.get("ok", false)) or not bool(original_roof.get("ok", false)): node.free(); _finish({}); return
	var source_report := _source_channels(original_wall.node.get_node("Mesh") as MeshInstance3D, original_roof.node.get_node("Mesh") as MeshInstance3D, node)
	_check(bool(source_report.ok), "All thirteen original native channels, material state, mesh transform/layers/shadows match the ordinary builder.")
	var source_collision: Dictionary = {}
	for pair: Array in [["OriginalWallRecord", original_wall.node], ["OriginalRoofRecord", original_roof.node]]:
		var actual := node.get_node(str(pair[0]) + "/Collision") as StaticBody3D
		var expected := (pair[1] as Node).get_node("Collision") as StaticBody3D
		var equal := actual.collision_layer == expected.collision_layer and actual.collision_mask == expected.collision_mask and actual.transform == expected.transform and actual.get_child_count() == expected.get_child_count()
		for key: String in ["receiver_kind", "opaque", "derived_object_key", "source_keys"]: equal = equal and actual.get_meta(key) == expected.get_meta(key)
		equal = equal and actual.is_in_group("spray_receiver_wall") == expected.is_in_group("spray_receiver_wall")
		for index in expected.get_child_count():
			var a := actual.get_child(index) as CollisionShape3D; var b := expected.get_child(index) as CollisionShape3D
			equal = equal and a.transform == b.transform and a.disabled == b.disabled and (a.shape as ConcavePolygonShape3D).get_faces() == (b.shape as ConcavePolygonShape3D).get_faces()
		_check(equal, "Exact original collision and receiver ownership: " + str(pair[0]))
		source_collision[str(pair[0])] = {"equal": equal, "layer": actual.collision_layer, "receiver": actual.get_meta("receiver_kind"), "spray_group": actual.is_in_group("spray_receiver_wall")}
	var raw: Dictionary = node.call("get_buckets") as Dictionary
	var dumps: Dictionary = {}; var triangles := 0
	for label: String in raw:
		var bucket: Dictionary = raw[label]
		if bucket.indices.is_empty():
			_check(not node.has_node(label), "Empty optional bucket produces no mesh: " + label)
			continue
		var mesh := node.get_node(label) as MeshInstance3D
		var arrays := mesh.mesh.surface_get_arrays(0)
		var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
		var uv: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
		var ids: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		var tangents: PackedFloat32Array = arrays[Mesh.ARRAY_TANGENT]
		_check(points.size() == normals.size() and points.size() == uv.size() and tangents.size() == points.size() * 4, "Complete native addition channels: " + label)
		for i in points.size():
			_check(points[i].is_finite() and normals[i].is_finite() and uv[i].is_finite(), "Finite native channels: " + label)
			var tangent := Vector3(tangents[i*4], tangents[i*4+1], tangents[i*4+2])
			_check(tangent.is_finite() and absf(tangent.length()-1.0)<.0002 and absf(tangent.dot(normals[i]))<.0002 and absf(tangents[i*4+3])==1.0, "Orthonormal tangent and handedness: " + label)
		for i in range(0, ids.size(), 3):
			var valid := ids[i] >= 0 and ids[i+1] >= 0 and ids[i+2] >= 0 and ids[i] < points.size() and ids[i+1] < points.size() and ids[i+2] < points.size()
			_check(valid, "Native index bounds: " + label)
			if valid:
				var face := (points[ids[i+1]]-points[ids[i]]).cross(points[ids[i+2]]-points[ids[i]])
				_check(face.length() > .0000001 and face.dot(normals[ids[i]]) < 0, "Nondegenerate clockwise native triangle: " + label)
		var expected_arrays: Array = []; expected_arrays.resize(Mesh.ARRAY_MAX)
		expected_arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array(bucket.vertices)
		expected_arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array(bucket.normals)
		expected_arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array(bucket.uvs)
		expected_arrays[Mesh.ARRAY_INDEX] = PackedInt32Array(bucket.indices)
		expected_arrays[Mesh.ARRAY_TANGENT] = builder._tangents_for(expected_arrays[Mesh.ARRAY_VERTEX], expected_arrays[Mesh.ARRAY_NORMAL], expected_arrays[Mesh.ARRAY_TEX_UV], expected_arrays[Mesh.ARRAY_INDEX])
		var expected_mesh := ArrayMesh.new(); expected_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, expected_arrays)
		_check(var_to_bytes(arrays) == var_to_bytes(expected_mesh.surface_get_arrays(0)), "Actual kit producer survives native conversion in the same consumed representation: " + label)
		if label in ["NearHorizontalSiding", "ProjectedUpperSiding", "ProjectedUpperClosures", "ShallowStoryBands"]:
			var material := mesh.get_active_material(0) as ShaderMaterial
			var expected_code: String = MODEL.SIDING_FIELD.code.replace("normalize(NORMAL.xz)", "(length(NORMAL.xz) > 0.0 ? normalize(NORMAL.xz) : vec2(1.0, 0.0))")
			_check(material != null and material.shader.code == expected_code and mesh.layers == (2 if label in ["NearHorizontalSiding", "ProjectedUpperSiding"] else 1), "Existing opaque siding material; visible front receives decals and closures do not.")
		elif label == MODEL.ROOF_BUCKET:
			var material := mesh.get_active_material(0) as ShaderMaterial
			_check(material != null and material.shader == MODEL.ROOF_TONE and mesh.layers == 1 and not bool(material.get_shader_parameter("boarded_grain")), "Existing opaque roof tone on separate nonreceiver public roof.")
		else:
			var material := mesh.get_active_material(0) as StandardMaterial3D
			_check(material != null and material.transparency == BaseMaterial3D.TRANSPARENCY_DISABLED and material.metallic <= .12 and mesh.layers == 1, "Opaque complete nonreceiver addition: " + label)
		triangles += ids.size() / 3
		dumps[label] = {"triangles": ids.size()/3, "vertices": _vecs(points), "indices": Array(ids), "tangents": Array(tangents), "layers": mesh.layers}
	var details := node.get_node("PhysicalDetails_NoSprayReceiver") as StaticBody3D
	_check(details.collision_layer == 5 and details.collision_mask == 0 and not details.is_in_group("spray_receiver_wall") and str(details.get_meta("receiver_kind")) == "none", "Physical detail collision blocks movement/spray and is never an eligible wall receiver.")
	_check(details.get_child_count() == MODEL.PHYSICAL_BUCKETS.size(), "All declared nonreceiver detail partitions exist; no canopies.")
	var collision: Dictionary = {}
	for shape_node: CollisionShape3D in details.get_children():
		var actual := (shape_node.shape as ConcavePolygonShape3D).get_faces()
		var expected := PackedVector3Array(); var bucket: Dictionary = raw[str(shape_node.name)]
		for i: int in bucket.indices: expected.append(bucket.vertices[i])
		_check(actual == expected, "Native collision exactly follows emitted complete detail: " + str(shape_node.name))
		collision[str(shape_node.name)] = {"triangles": actual.size()/3, "faces_sha256": var_to_bytes(actual).hex_encode().sha256_text()}
	_check(not details.has_node("NearHorizontalSiding") and not details.has_node("DrapedEntryPaths"), "Original wall and LAND remain the supporting receivers beneath thin visual skins.")
	for label: String in MODEL.GROUND_BUCKETS: _check(not details.has_node(label), "Actual LAND alone supports render-only ground: " + label)
	var projected := node.get_node("ProjectedUpperWallReceiver") as StaticBody3D
	_check(projected.collision_layer == 5 and projected.collision_mask == 0 and projected.is_in_group("spray_receiver_wall") and projected.get_child_count() == 1, "Projected vertical front keeps the ordinary wall receiver semantics.")
	var projected_shape := (projected.get_child(0) as CollisionShape3D).shape as ConcavePolygonShape3D
	var expected_front := PackedVector3Array()
	for index: int in raw.ProjectedUpperSiding.indices: expected_front.append(raw.ProjectedUpperSiding.vertices[index])
	_check(projected_shape.get_faces() == expected_front and expected_front.size() == 18, "Target projected-front triangles exactly equal visible front; no closure is a receiver.")
	for owner: Object in [projected, projected_shape]:
		for key: String in ["receiver_kind", "opaque", "source_keys"]: _check(owner.get_meta(key) == wall[key], "Projected front exact source owner metadata: " + key)
		_check(owner.get_meta("derived_object_key") == MODEL.WALL_KEY, "Projected front owns only this source wall.")
	collision["ProjectedUpperWallReceiver"] = {"triangles": 6, "faces_sha256": var_to_bytes(projected_shape.get_faces()).hex_encode().sha256_text(), "source_key": MODEL.WALL_KEY, "receiver_kind": "building_wall", "render_layer": 2}
	# Focused correction: exact authored triangle suffix, beyond self-reported counters.
	var revised_triangles: Array = cfg.roof_termination.triangles
	var revised_points: Array = raw.PaleDrainageAndFascia.vertices
	var revised_start: int = revised_points.size() - revised_triangles.size() * 3
	_check(revised_start >= 0, "Revised physical geometry is emitted.")
	for ti: int in revised_triangles.size():
		for vi: int in 3:
			var value: Array = revised_triangles[ti][vi]
			_check((revised_points[revised_start + ti * 3 + vi] as Vector3).is_equal_approx(Vector3(float(value[0]), float(value[1]), float(value[2]))), "Revised authored triangle equals actual emitted geometry.")
	# Target-specific closed planar strips; unresolved canopies emit no geometry.
	_check(details.has_node(MODEL.ROOF_BUCKET) and raw[MODEL.ROOF_BUCKET].indices.size() == 108 and raw.ShallowStoryBands.indices.size() == 0 and raw.CarportRoof.indices.is_empty() and raw.CarportPosts.indices.is_empty() and raw.CarportFascia.indices.is_empty(), "Exact target planar closed roof/story strips; uncertain canopies excluded.")
	_check(not bool(node.call("configure_records", wall, roof).get("ok", false)), "Duplicate construction rejected.")
	var changed := wall.duplicate(true); changed.vertices[0] = float(changed.vertices[0]) + .01
	_check(not MODEL.matches_record_pair(changed, roof), "Changed source coordinates rejected.")
	var baseline := MODEL.build_for_records(wall, roof, true)
	_check(bool(baseline.get("ok", false)) and baseline.node.get_child_count() == 4 and not baseline.node.has_node("PhysicalDetails_NoSprayReceiver"), "Baseline has only the original meshes and source collision roots.")
	if baseline.has("node"): baseline.node.free()
	var result := {"source_channel_comparison": source_report, "source_collision": source_collision, "metadata": built.metadata, "added_triangles": triangles, "meshes": dumps, "detail_collision": collision, "terrain_preflight_sha256": FileAccess.get_sha256("/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1237-1229-implementation-003/1237/PREFLIGHT_RESULT.json"), "world_not_loaded": true}
	node.free(); original_wall.node.free(); original_roof.node.free(); _finish(result)
func _vecs(values: PackedVector3Array) -> Array:
	var out: Array = []
	for value: Vector3 in values: out.append([value.x, value.y, value.z])
	return out
func _finish(result: Dictionary) -> void:
	result.merge({"ok": failures.is_empty(), "failures": failures, "checks": checks, "recognition_credit": 0, "scope": "Detached source/channel and emitted detail integrity only; native world mechanics and visual review remain separate."})
	var path := ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): path = arg.trim_prefix("--output=")
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(result, "  ", false) + "\n"); file.close()
	print("NORTHPOINT1237_FOCUSED_" + ("PASS" if failures.is_empty() else "FAIL") + " " + JSON.stringify(failures))
	quit(0 if failures.is_empty() else 1)

func _material_channels(material:Material) -> Dictionary:
	var state:Dictionary={"class":material.get_class()}
	for property:Dictionary in material.get_property_list():
		if (int(property.usage)&PROPERTY_USAGE_STORAGE)==0:continue
		var value:Variant=material.get(str(property.name))
		if value is Resource:state[str(property.name)]={"class":value.get_class(),"path":value.resource_path}
		else:state[str(property.name)]=value
	return state
func _source_channels(original_wall:MeshInstance3D,original_roof:MeshInstance3D,study:Node3D) -> Dictionary:
	var result:Dictionary={"ok":true,"meshes":{}}
	for label:String in ["ExactOriginalWallSurfaces","ExactSourceNeutralRoof"]:
		var original:MeshInstance3D=original_roof if label=="ExactSourceNeutralRoof" else original_wall
		var current:MeshInstance3D=study.get_node(NodePath(label)) as MeshInstance3D
		var surfaces:Array=[]
		var state_equal:bool=current.transform==original.transform and current.layers==original.layers and current.cast_shadow==original.cast_shadow and current.mesh.get_surface_count()==original.mesh.get_surface_count()
		result.ok=bool(result.ok) and state_equal
		for surface in original.mesh.get_surface_count():
			var expected:Array=original.mesh.surface_get_arrays(surface);var actual:Array=current.mesh.surface_get_arrays(surface);var channels:Dictionary={}
			for ch in Mesh.ARRAY_MAX:
				var equal:bool=var_to_bytes(actual[ch])==var_to_bytes(expected[ch])
				channels[str(ch)]={"equal":equal,"actual_count":0 if actual[ch]==null else actual[ch].size(),"original_count":0 if expected[ch]==null else expected[ch].size()}
				if not equal:channels[str(ch)]["difference"]=_channel_difference(actual[ch],expected[ch])
				result.ok=bool(result.ok) and equal
			var material_equal:bool=_material_channels(current.get_active_material(surface))==_material_channels(original.get_active_material(surface))
			result.ok=bool(result.ok) and material_equal and current.mesh.surface_get_name(surface)==original.mesh.surface_get_name(surface)
			surfaces.append({"surface":surface,"name":original.mesh.surface_get_name(surface),"channels":channels,"material_equal":material_equal})
		result.meshes[label]={"source_state_equal":state_equal,"surfaces":surfaces,"complete_original_material_partitions_preserved":true}
	return result

func _channel_components(values:Variant) -> Array[float]:
	var out:Array[float]=[]
	if values==null:return out
	for value:Variant in values:
		if value is Vector3:out.append_array([value.x,value.y,value.z])
		elif value is Vector2:out.append_array([value.x,value.y])
		elif value is Color:out.append_array([value.r,value.g,value.b,value.a])
		else:out.append(float(value))
	return out
func _channel_difference(actual:Variant,expected:Variant) -> Dictionary:
	var a:Array[float]=_channel_components(actual);var b:Array[float]=_channel_components(expected)
	var count:=0;var maximum:=0.0;var examples:Array=[]
	for i in mini(a.size(),b.size()):
		if a[i]==b[i]:continue
		count+=1;var delta:float=a[i]-b[i];maximum=maxf(maximum,absf(delta))
		if examples.size()<6:examples.append({"component":i,"actual":a[i],"expected":b[i],"delta":delta})
	return {"actual_components":a.size(),"expected_components":b.size(),"unequal_shared_components":count,"max_absolute_difference":maximum,"first_examples":examples}
