extends Node3D
## Candidate live factory derived from the frozen corrected 1206 study; geometry is unchanged.
const KIT := preload("res://game/scripts/world/facades/site_12_housing_kit.gd")
const SIDING_FIELD := preload("res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader")
const ROOF_MATERIAL := preload("res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres")
const ROOF_TONE := preload("res://game/resources/facades/d5_1317_surface_tone.gdshader")
const CONCRETE := preload("res://game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_diff_1k.jpg")
const CONCRETE_ROUGH := preload("res://game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_rough_1k.jpg")
const ASPHALT := preload("res://game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_diff_1k.jpg")
const ASPHALT_ROUGH := preload("res://game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_rough_1k.jpg")
const GROUND_BUCKETS := ["DrapedEntryPaths", "FootwaySurface", "ParkingSurface"]
const ROOF_BUCKET := "ObservedPublicRoof"
const SELF_PATH := "res://game/scripts/world/facades/mariner_1206_live_factory.gd"
const CONFIG_PATH := "res://game/resources/facades/mariner_1206_study.json"
const CHUNK_PATH := "res://generated/world/chunks/x_-2__z_-3.json"
const WALL_KEY := "building:w96215677:wall"
const ROOF_KEY := "building:w96215677:roof"
const EXPECTED_CHUNK_SHA256 := "7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5"
const TARGET_RUNS := [11,12,13,15,16,17,18,19,21,22,23]
const PROTECTED_RUNS := [0,1,2,3,4,5,6,7,8,9,10,14,20,24,25]
const PHYSICAL_BUCKETS := ["PaleCompleteTrim","BlueOpaqueGlazing","DarkOpaqueGlazing","GreenClosedDoors","LocalPrivacyScreens","PaleDrainageAndFascia","DoorHardware"]
var _tangent_builder: Callable
var _last_result: Dictionary = {}
var _buckets: Dictionary = {}

static func _json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}

static func _record(records: Array, key: String) -> Dictionary:
	for row: Dictionary in records:
		if str(row.get("object_key", "")) == key: return row
	return {}

static func matches_record_pair(wall: Dictionary, roof: Dictionary) -> bool:
	if FileAccess.get_sha256(CHUNK_PATH) != EXPECTED_CHUNK_SHA256: return false
	var records: Array = _json(CHUNK_PATH).get("records", [])
	return not wall.is_empty() and not roof.is_empty() and wall == _record(records, WALL_KEY) and roof == _record(records, ROOF_KEY)

static func build_for_records(wall: Dictionary, roof: Dictionary, source_builder: Callable, tangent_builder: Callable, baseline: bool = false) -> Dictionary:
	# Explicit construction avoids global-class discovery assumptions in helpers.
	var node: Node3D = load(SELF_PATH).new() as Node3D
	var result: Dictionary = node.call("configure_records", wall, roof, source_builder, tangent_builder, baseline) as Dictionary
	if not bool(result.get("ok", false)): node.free()
	return result

func configure_records(wall: Dictionary, roof: Dictionary, source_builder: Callable, tangent_builder: Callable, baseline: bool = false) -> Dictionary:
	if not _last_result.is_empty(): return {"ok": false, "message": "Duplicate study construction."}
	if not source_builder.is_valid() or not tangent_builder.is_valid(): return {"ok": false, "message": "Original source and tangent producers required."}
	_tangent_builder = tangent_builder
	if not matches_record_pair(wall, roof): return {"ok": false, "message": "Exact source pair changed."}
	var cfg := _json(CONFIG_PATH)
	if not _same_numeric_runs(cfg.get("mapped_runs", []), TARGET_RUNS) or not _same_numeric_runs(cfg.get("protected_runs", []), PROTECTED_RUNS):
		return {"ok": false, "message": "Observed/protected scope changed."}
	if str(cfg.get("schema_version", "")) != "ti.mariner-1206-study/1" or str(cfg.target.source_key) != "w96215677":
		return {"ok": false, "message": "This coherent study is 1206 only."}
	var truth: Dictionary = cfg.truth_boundary
	if not bool(truth.prototype_only) or bool(truth.runtime_attachment) or bool(truth.recognition_accepted) or bool(truth.as_built_claim) or bool(truth.interior_modeled):
		return {"ok": false, "message": "Study truth boundary changed."}
	# The actual builder supplies its raw source producer, outside pair dispatch.
	var originals: Array = [source_builder.call(wall, false), source_builder.call(roof, false)]
	if not bool(originals[0].get("ok", false)) or not bool(originals[1].get("ok", false)):
		for row: Dictionary in originals:
			if row.has("node"): (row.node as Node).free()
		return {"ok": false, "message": "Ordinary original construction failed."}
	for i in 2:
		var original: Node3D = originals[i].node as Node3D
		original.name = "OriginalWallRecord" if i == 0 else "OriginalRoofRecord"
		add_child(original)
		var mesh := original.get_node("Mesh") as MeshInstance3D
		mesh.reparent(self, false)
		mesh.name = "ExactOriginalWallSurfaces" if i == 0 else "ExactSourceNeutralRoof"
		# Ordinary-builder mesh resources, all thirteen channels, materials,
		# source collision shapes and wall spray groups remain untouched.
	for label: String in ["NearHorizontalSiding", "PaleCompleteTrim", "BlueOpaqueGlazing", "DarkOpaqueGlazing", "GreenClosedDoors", "LocalPrivacyScreens", "PaleDrainageAndFascia", "DoorHardware", "DrapedEntryPaths", "FootwaySurface", "ParkingSurface", "ObservedPublicRoof"]:
		_buckets[label] = KIT.new_bucket()
	if not baseline:
		for run: int in TARGET_RUNS: _append_skin(wall, run)
		for frame: Dictionary in cfg.target.frames: _append_zone(frame, cfg.facade)
		for label: String in cfg.local_ground: _append_path(cfg.local_ground[label], label)
		_append_roof(cfg.public_roof.triangles)
		for label: String in _buckets:
			_add_mesh(label, _buckets[label], _surface_material(label, cfg))
		var body := StaticBody3D.new()
		body.name = "PhysicalDetails_NoSprayReceiver"
		body.collision_layer = 5
		body.collision_mask = 0
		body.set_meta("receiver_kind", "none")
		body.set_meta("derived_object_key", "prototype:" + WALL_KEY)
		body.set_meta("feature_kind", "bounded_facade_detail")
		body.set_meta("source_keys", ["w96215677"])
		for label: String in PHYSICAL_BUCKETS:
			var bucket: Dictionary = _buckets[label]
			var faces := PackedVector3Array()
			for index: int in bucket.indices: faces.append(bucket.vertices[index])
			var shape := ConcavePolygonShape3D.new()
			shape.set_faces(faces)
			shape.set_meta("receiver_kind", "none")
			shape.set_meta("structural_role", label)
			var child := CollisionShape3D.new()
			child.name = label
			child.shape = shape
			body.add_child(child)
		add_child(body)
		# Separate public pitched addition: original roof and its collision survive.
		var roof_body := StaticBody3D.new()
		roof_body.name = "ObservedRoof_NoSprayReceiver"
		roof_body.collision_layer = 5
		roof_body.collision_mask = 0
		roof_body.set_meta("receiver_kind", "none")
		roof_body.set_meta("derived_object_key", "prototype:" + ROOF_KEY)
		roof_body.set_meta("source_keys", ["w96215677"])
		roof_body.set_meta("feature_kind", "bounded_public_roof_addition")
		var roof_faces := PackedVector3Array()
		var roof_bucket: Dictionary = _buckets[ROOF_BUCKET]
		for index: int in roof_bucket.indices: roof_faces.append(roof_bucket.vertices[index])
		var roof_shape := ConcavePolygonShape3D.new()
		roof_shape.set_faces(roof_faces)
		roof_shape.set_meta("receiver_kind", "none")
		roof_shape.set_meta("structural_role", ROOF_BUCKET)
		var roof_node := CollisionShape3D.new()
		roof_node.name = ROOF_BUCKET
		roof_node.shape = roof_shape
		roof_body.add_child(roof_node)
		add_child(roof_body)
	var batches: Dictionary = {}
	var triangles := 0
	var surfaces := 0
	for child: Node in get_children():
		if not child is MeshInstance3D: continue
		var count := 0
		for surface in child.mesh.get_surface_count():
			count += child.mesh.surface_get_arrays(surface)[Mesh.ARRAY_INDEX].size() / 3
		batches[str(child.name)] = count
		triangles += count
		surfaces += child.mesh.get_surface_count()
	var metadata: Dictionary = {"model_id": "1206-mariner-coherent-study-001", "prototype_only": true, "runtime_attachment": false, "recognition_accepted": false, "source_key": "w96215677", "mapped_public_run_indices": TARGET_RUNS, "protected_run_indices": PROTECTED_RUNS, "baseline_exact_source": baseline, "original_wall_roof_resources_preserved": true, "source_roof_geometry_preserved": true, "source_wall_spray_eligibility_preserved": true, "physical_details_spray_receiver": false, "interior_modeled": false, "as_built_claim": false, "module_dimensions_and_counts": "production_inference", "visual_batch_triangles": batches, "visual_triangles": triangles, "mesh_instances": batches.size(), "surfaces": surfaces, "source_terrain_untouched": true, "draped_paths_render_only": true, "continuous_footway_and_parking_render_only": true, "separate_public_roof_addition": not baseline, "public_roof_shapes": 0 if baseline else 1, "roof_inference": "Bounded observed front slopes; pitch and hidden inner/end closure are construction inference, not three as-built roof solids", "stairs_authored": false}
	for key: String in metadata: set_meta(key, metadata[key])
	_last_result = {"ok": true, "node": self, "metadata": metadata}
	return _last_result

func get_buckets() -> Dictionary:
	return _buckets

func _append_zone(frame: Dictionary, facade: Dictionary) -> void:
	var tangent := _v(frame.tangent)
	var normal := _v(frame.normal)
	var trim: Dictionary = _buckets.PaleCompleteTrim
	for key: String in ["upper_windows", "lower_windows"]:
		for window: Dictionary in frame[key]:
			var bucket: Dictionary = _buckets.DarkOpaqueGlazing if str(window.glazing) == "dark" else _buckets.BlueOpaqueGlazing
			KIT.append_grouped_opening(bucket, trim, _point(frame, float(window.station_m), float(window.center_y), .022), tangent, normal, float(window.width_m), float(window.height_m), .046, .074, .066, .047)
			# Complete projecting lower sill, safely clear of the opening's trim.
			KIT.append_box(trim, _point(frame, float(window.station_m), float(window.center_y) - float(window.height_m) / 2.0 - .087, .104), tangent, normal, float(window.width_m) + .22, .06, .20)
	for entry: Dictionary in frame.entries:
		var s := float(entry.station_m)
		var bottom := float(entry.bottom_y)
		var width := float(entry.width_m)
		var height := float(entry.height_m)
		KIT.append_box(_buckets.GreenClosedDoors, _point(frame, s, bottom + height / 2.0, .071), tangent, normal, width, height, .098)
		for side in [-1.0, 1.0]:
			KIT.append_box(trim, _point(frame, s + side * (width / 2.0 + .05), bottom + height / 2.0, .115), tangent, normal, .10, height, .15)
		KIT.append_box(trim, _point(frame, s, bottom + height + .05, .115), tangent, normal, width + .20, .10, .15)
		KIT.append_box(_buckets.DoorHardware, _point(frame, s + width * .34, bottom + 1.03, .131), tangent, normal, .045, .16, .035)
		_append_path(entry.path_mesh)
	for screen: Dictionary in frame.screens:
		var center := _point(frame, float(screen.station_m), float(screen.bottom_y) + float(screen.height_m) / 2.0, float(screen.depth_m))
		_append_screen(center, tangent, normal, float(screen.width_m), float(screen.height_m))
		# Short return toward the wall, with no invented full fence or canopy.
		var length := float(screen.return_length_m)
		var return_center := center - tangent * (float(screen.width_m) / 2.0 - .045) - normal * (length / 2.0 + .035)
		_append_screen(return_center, -normal, tangent, length, float(screen.height_m))
	for pipe: Dictionary in frame.pipes:
		var height := float(pipe.top_y) - float(pipe.bottom_y)
		KIT.append_box(_buckets.PaleDrainageAndFascia, _point(frame, float(pipe.station_m), float(pipe.bottom_y) + height / 2.0, .162), tangent, normal, .073, height, .085)
		for y in [float(pipe.bottom_y) + .42, float(facade.story_band_y) + .11, 7.82]:
			KIT.append_box(_buckets.PaleDrainageAndFascia, _point(frame, float(pipe.station_m), y, .17), tangent, normal, .103, .044, .10)
	var length := float(frame.length_m) - .035
	# Continuous pale fascia/gutter; original roof remains intact beneath/behind the addition.
	KIT.append_eave_band(_buckets.PaleDrainageAndFascia, _point(frame, float(frame.length_m) / 2.0, float(facade.fascia_center_y), .015), tangent, normal, length, .145, .25)
	KIT.append_box(_buckets.PaleDrainageAndFascia, _point(frame, float(frame.length_m) / 2.0, float(facade.gutter_center_y), .21), tangent, normal, length, .038, .15)
	KIT.append_box(trim, _point(frame, float(frame.length_m) / 2.0, float(facade.story_band_y), .053), tangent, normal, length, .060, .088)

func _append_screen(center: Vector3, tangent: Vector3, normal: Vector3, width: float, height: float) -> void:
	var bucket: Dictionary = _buckets.LocalPrivacyScreens
	for side in [-1.0, 1.0]:
		KIT.append_box(bucket, center + tangent * side * (width / 2.0 - .045), tangent, normal, .09, height, .09)
	for vertical in [-.36, .36]:
		KIT.append_box(bucket, center + Vector3.UP * height * vertical - normal * .036, tangent, normal, width - .10, .075, .064)
	var count := maxi(2, int(floor((width - .16) / .115)))
	for i in count:
		var along := lerpf(-width / 2.0 + .13, width / 2.0 - .13, float(i) / float(count - 1))
		KIT.append_box(bucket, center + tangent * along + normal * .018, tangent, normal, .078, height - .08, .04)

func _append_path(path: Dictionary, label: String = "DrapedEntryPaths") -> void:
	var bucket: Dictionary = _buckets[label]
	var down := Vector3.DOWN * float(path.thickness_m)
	# The six paths are clipped to actual LAND triangles and the existing road
	# overlay transition. Only LAND supplies walking support; no new collider.
	for triangle: Array in path.top_triangles:
		_append_path_triangle(bucket, _v(triangle[0]), _v(triangle[1]), _v(triangle[2]), false)
		_append_path_triangle(bucket, _v(triangle[0]) + down, _v(triangle[1]) + down, _v(triangle[2]) + down, true)
	for segment: Array in path.boundary_segments:
		var start := _v(segment[0]); var end := _v(segment[1])
		var outward := Vector3.UP.cross(end - start).normalized()
		KIT.append_quad(bucket, start, end, end + down, start + down, outward, Vector2.ZERO, Vector2(start.distance_to(end), float(path.thickness_m)))

func _append_path_triangle(bucket: Dictionary, a: Vector3, b: Vector3, c: Vector3, underside: bool) -> void:
	var normal := (b - a).cross(c - a).normalized()
	if (normal.y > 0.0) == underside:
		var swap := b; b = c; c = swap
		normal = -normal
	var base: int = bucket.vertices.size()
	for point: Vector3 in [a, b, c]:
		bucket.vertices.append(point)
		bucket.normals.append(normal)
		bucket.uvs.append(Vector2(point.x, point.z))
	bucket.indices.append_array([base, base + 2, base + 1])

func _append_skin(wall: Dictionary, run: int) -> void:
	var bucket: Dictionary = _buckets.NearHorizontalSiding
	var f := KIT.run_frame(wall, run)
	var normal: Vector3 = f.normal
	var points: Array[Vector3] = []
	for i in 4: points.append(_v(wall.vertices.slice(run * 12 + i * 3, run * 12 + i * 3 + 3)))
	var a := points[0] + normal * .010; var b := points[1] + normal * .010
	var c := points[2] + normal * .010; var d := points[3] + normal * .010
	# One thin closed skin per source run, meeting at exact shared run endpoints.
	KIT.append_quad(bucket, a, b, c, d, normal, Vector2(a.dot(f.tangent), a.y), Vector2(float(f.length_m), c.y - b.y))
	KIT.append_quad(bucket, points[1], points[0], points[3], points[2], -normal, Vector2.ZERO, Vector2.ONE)
	for i in 4:
		var j := (i + 1) % 4
		var outside := (points[j] - points[i]).cross(normal).normalized()
		var midpoint := (points[0] + points[1] + points[2] + points[3]) / 4.0
		if outside.dot((points[i] + points[j]) / 2.0 - midpoint) < 0: outside = -outside
		KIT.append_quad(bucket, points[i], points[j], points[j] + normal * .010, points[i] + normal * .010, outside, Vector2.ZERO, Vector2(points[i].distance_to(points[j]), .010))

func _append_roof(triangles: Array) -> void:
	var bucket: Dictionary = _buckets[ROOF_BUCKET]
	for triangle: Array in triangles:
		var a := _v(triangle[0]); var b := _v(triangle[1]); var c := _v(triangle[2])
		var normal := (b-a).cross(c-a).normalized()
		var u := normal.cross(Vector3.UP)
		if u.length_squared() < .000001: u = Vector3.RIGHT
		u = u.normalized()
		var v := normal.cross(u).normalized()
		var base: int = bucket.vertices.size()
		for point: Vector3 in [a,b,c]:
			bucket.vertices.append(point)
			bucket.normals.append(normal)
			bucket.uvs.append(Vector2(point.dot(u),point.dot(v)))
		bucket.indices.append_array([base,base+2,base+1])

static func _surface_material(label: String, cfg: Dictionary) -> Material:
	if label == ROOF_BUCKET:
		var roof := ShaderMaterial.new()
		roof.shader = ROOF_TONE
		roof.resource_name = "1206_warm_weathered_observed_roof"
		roof.set_shader_parameter("source_albedo", ROOF_MATERIAL.albedo_texture)
		roof.set_shader_parameter("low_color", _color(cfg.facade.roof_low_rgb))
		roof.set_shader_parameter("high_color", _color(cfg.facade.roof_high_rgb))
		roof.set_shader_parameter("boarded_grain", false)
		return roof
	if label in GROUND_BUCKETS:
		var ground := StandardMaterial3D.new()
		var parking := label == "ParkingSurface"
		ground.resource_name = "1206_actual_grade_" + label
		ground.albedo_texture = ASPHALT if parking else CONCRETE
		ground.roughness_texture = ASPHALT_ROUGH if parking else CONCRETE_ROUGH
		ground.albedo_color = _color(cfg.materials.parking_rgb if parking else (cfg.materials.footway_rgb if label == "FootwaySurface" else cfg.materials.path_rgb))
		ground.roughness = .93
		ground.uv1_scale = Vector3(.55,.55,1.0)
		ground.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		return ground
	var colors: Dictionary = {"PaleCompleteTrim": cfg.materials.trim_rgb, "BlueOpaqueGlazing": cfg.materials.blue_glass_rgb, "DarkOpaqueGlazing": cfg.materials.dark_glass_rgb, "GreenClosedDoors": cfg.materials.door_rgb, "LocalPrivacyScreens": cfg.materials.screen_rgb, "PaleDrainageAndFascia": cfg.materials.trim_rgb, "DoorHardware": cfg.materials.metal_rgb, "DrapedEntryPaths": cfg.materials.path_rgb}
	if label == "NearHorizontalSiding":
		var material := ShaderMaterial.new()
		var shader := Shader.new()
		shader.code = SIDING_FIELD.code.replace("normalize(NORMAL.xz)", "(length(NORMAL.xz) > 0.0 ? normalize(NORMAL.xz) : vec2(1.0, 0.0))")
		material.shader = shader
		material.resource_name = "1206_warm_weathered_gray_horizontal_siding"
		var base := _color(cfg.materials.siding_rgb)
		material.set_shader_parameter("base_color", base)
		material.set_shader_parameter("seam_color", base * float(cfg.siding.seam_color_multiplier))
		for key: String in ["course_height_m", "color_variation", "filter_start_cycles_per_pixel", "filter_end_cycles_per_pixel"]:
			material.set_shader_parameter(key, float(cfg.siding[key]))
		material.set_shader_parameter("roughness_value", float(cfg.siding.roughness))
		material.set_shader_parameter("relief_strength", float(cfg.siding.normal_relief))
		return material
	var material := StandardMaterial3D.new()
	material.resource_name = "1206_" + label
	material.albedo_color = _color(colors[label])
	material.roughness = .48 if "Glazing" in label else .86
	return material

func _add_mesh(label: String, bucket: Dictionary, material: Material) -> void:
	var arrays: Array = []; arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array(bucket.vertices)
	arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array(bucket.normals)
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array(bucket.uvs)
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array(bucket.indices)
	arrays[Mesh.ARRAY_TANGENT] = _tangent_builder.call(arrays[Mesh.ARRAY_VERTEX], arrays[Mesh.ARRAY_NORMAL], arrays[Mesh.ARRAY_TEX_UV], arrays[Mesh.ARRAY_INDEX])
	var mesh := ArrayMesh.new(); mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays); mesh.surface_set_material(0, material)
	var node := MeshInstance3D.new(); node.name = label; node.mesh = mesh
	# Wall decal projection reaches the 10mm skin; physical additions reject spray.
	node.layers = 2 if label == "NearHorizontalSiding" else 1
	if label == "NearHorizontalSiding" or label in GROUND_BUCKETS: node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(node)

static func _same_numeric_runs(actual: Array, expected: Array) -> bool:
	if actual.size() != expected.size(): return false
	for i in actual.size():
		if not (actual[i] is float or actual[i] is int): return false
		var value := float(actual[i])
		if not is_finite(value) or floorf(value) != value or value != float(expected[i]): return false
	return true

static func _v(a: Array) -> Vector3:
	return Vector3(float(a[0]), float(a[1]), float(a[2]))

static func _color(a: Array) -> Color:
	return Color(float(a[0]), float(a[1]), float(a[2]), 1.0)

static func _point(frame: Dictionary, station: float, y: float, depth: float) -> Vector3:
	var point := _v(frame.start) + _v(frame.tangent) * station + _v(frame.normal) * depth
	point.y = y
	return point

static func _joined_frame(wall: Dictionary, first: int, last: int) -> Dictionary:
	var frame := KIT.run_frame(wall, first)
	frame.end = KIT.run_frame(wall, last).end
	var delta: Vector3 = frame.end - frame.start
	delta.y = 0.0
	frame.length_m = delta.length(); frame.tangent = delta.normalized()
	return frame
