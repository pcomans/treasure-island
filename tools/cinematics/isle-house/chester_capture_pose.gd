extends RefCounted
## Shot-local contacts, eyeline and wink on the stock Chester model.
const WorldHarness := preload("res://game/tests/shared/world_harness.gd")
const Parts := preload("res://game/scripts/player/chest_avatar_parts.gd")
const ORIGINAL_EYE_CUE := 840
const CONTACT_M := 0.002
const FOOT_REGION := 0.58
const IRIS_WHITE := Color(0.88, 0.875, 0.86, 1.0)
const EYE_FILE := "res://game/resources/player/chest_eye.gdshader"

var avatar: ChestAvatar
var material: ShaderMaterial
var ground_triangles: Array[PackedVector3Array] = []
var meshes: Array[MeshInstance3D] = []
var sole_samples: Array[PackedVector3Array] = []
var world_harness: WorldHarness
var eye_cue_frame := ORIGINAL_EYE_CUE


func prepare(harness: WorldHarness, cue_frame: int = ORIGINAL_EYE_CUE) -> String:
	world_harness = harness
	eye_cue_frame = cue_frame
	avatar = harness.player.avatar_pivot.get_node_or_null("ChestAvatar") as ChestAvatar
	if avatar == null:
		return "The shot has no stock Chester."
	var from: Vector3 = avatar.global_position
	_collect_ground(harness.world.ground_and_areas, from)
	_collect_ground(harness.world.roads_and_paths, from)
	if ground_triangles.is_empty():
		return "No rendered support triangles found near Chester."
	# The harness turns the avatar after settling the capsule. Reseat the actual
	# rendered legs after that turn, so their world contacts belong to this yaw.
	avatar._reset(avatar.global_transform)
	avatar._physics_process(1.0 / 60.0)
	for leg in avatar._legs:
		for surface_name in ["ShoeMesh", "ShoeOutline"]:
			var mesh := leg.shoe.get_node(surface_name) as MeshInstance3D
			var soles := _sole_vertices(mesh.mesh)
			if soles.is_empty():
				return "Cannot sample the actual stock shoe sole."
			meshes.append(mesh)
			sole_samples.append(soles)
		var sole_i := meshes.size() - 2
		var before := _sole_range(sole_i)
		if not _plant_shoe(leg, sole_i, before):
			return "Neither the stock foot center nor a nearby stock stance can rest both ends of side %s on the drawn pavement." % leg.side
	if not _install_eye_material():
		return "Could not route the stock eyes to the capture-only shader parameters."
	print("SHOT_SUPPORT rendered_triangles=", ground_triangles.size(), " sole_vertices=",
		sole_samples[0].size() + sole_samples[1].size(), ",",
		sole_samples[2].size() + sole_samples[3].size())
	return ""


func verify_contacts(frame: int) -> bool:
	var a := _sole_range(0)
	var b := _sole_range(2)
	print("SHOT_SOLE_PROOF frame=", frame, " support_and_visible_ranges_mm=", a * 1000.0, ",", b * 1000.0)
	return _supported(a) and _supported(b)


func _supported(clearance: Vector3) -> bool:
	return clearance.x >= 0.0005 and clearance.x < 0.005 \
		and clearance.y < 0.010 and clearance.z < 0.036


func _plant_shoe(leg: Variant, first: int, original_range: Vector3) -> bool:
	var rest: Vector3 = leg.foot
	var yaw: float = leg.yaw
	var offsets := PackedVector2Array([Vector2.ZERO])
	for distance_m: float in [0.028, 0.056, 0.084]:
		for direction in 8:
			offsets.append(Vector2.RIGHT.rotated(float(direction) * PI / 4.0) * distance_m)
	var best_score := INF
	var best_foot := rest
	var best_normal := Vector3.UP
	var best_yaw := yaw
	for offset: Vector2 in offsets:
		var center := rest + Vector3(offset.x, 0.0, offset.y)
		var ground := _ground_levels(center)
		if not is_finite(ground.x + ground.y):
			continue
		center.y = maxf(ground.x, ground.y)
		for angle: float in [0.0, -0.19, 0.19]:
			leg.foot = center
			leg.yaw = yaw + angle
			leg.normal = Vector3.UP
			_update_leg(leg)
			var normal := _fit_contact_plane(leg.shoe.global_transform)
			if normal.y < 0.94:
				continue
			leg.normal = normal
			_update_leg(leg)
			var range_m := _sole_range(first)
			var lift := CONTACT_M - range_m.x
			if not is_finite(lift + range_m.y + range_m.z):
				continue
			var score := range_m.z + lift + offset.length() * 0.18 + absf(angle) * 0.014
			if score >= best_score or range_m.y + lift >= 0.010 or range_m.z + lift >= 0.036:
				continue
			best_score = score
			best_foot = center + Vector3.UP * lift
			best_normal = normal
			best_yaw = yaw + angle
	if not is_finite(best_score):
		print("SHOT_SOLE_REJECT side=", leg.side, " original_mm=", original_range * 1000.0, " foot=", rest)
		return false
	leg.foot = best_foot
	leg.target = best_foot
	leg.yaw = best_yaw
	leg.normal = best_normal
	leg.target_normal = best_normal
	_update_leg(leg)
	var final_range := _sole_range(first)
	var movement := Vector2(best_foot.x - rest.x, best_foot.z - rest.z).length()
	print("SHOT_SOLE side=", leg.side, " original_mm=", original_range * 1000.0,
		" corrected_mm=", final_range * 1000.0, " horizontal_adjustment_mm=", movement * 1000.0,
		" contact=", best_foot, " plane=", best_normal)
	return _supported(final_range)

func aim_eyes(frame: int, camera: Camera3D) -> void:
	# The gameplay camera is in the root viewport. Use the true picture camera
	# instead, leaving the bulb shape, ink rim and eyelid geometry untouched.
	var direction := (avatar._eye_mount.global_transform.affine_inverse() * camera.global_position).normalized()
	var look := Vector2(direction.x, direction.y) * 0.55
	material.set_shader_parameter(&"shot_look", look.limit_length(0.43))
	var seconds := float(frame - eye_cue_frame) / 30.0
	var wink := _smooth((seconds - 1.08) / 0.14) * (1.0 - _smooth((seconds - 1.36) / 0.21))
	# Keep natural paired blinks away from the deliberately single-eye cue.
	var isolated := _smooth((seconds - 0.73) / 0.27) * (1.0 - _smooth((seconds - 1.71) / 0.22))
	material.set_shader_parameter(&"shot_wink", wink)
	material.set_shader_parameter(&"shot_isolated", isolated)


func face_row(frame: int, camera: Camera3D) -> PackedStringArray:
	# Seed the finishing fit from the actual projected character, including the smaller smile pose.
	var mount := avatar._eye_mount.global_transform
	var eye_left := camera.unproject_position(mount * Vector3(-Parts.EYE_CENTER.x, 0.016, 0.035))
	var eye_right := camera.unproject_position(mount * Vector3(Parts.EYE_CENTER.x, 0.016, 0.035))
	var body := avatar._body.global_transform
	var corner := Vector3(Parts.BODY_W * 0.5 + 0.016, Parts.BODY_H - 0.022, Parts.BODY_D * 0.5 + 0.016)
	var mouth_left := camera.unproject_position(body * Vector3(-corner.x, corner.y, corner.z))
	var mouth_right := camera.unproject_position(body * corner)
	var latch := camera.unproject_position(avatar._lid.global_transform * Vector3(0.0, 0.03, Parts.LID_D + 0.029))
	return PackedStringArray([str(frame), str(minf(eye_left.x, eye_right.x)), str(maxf(eye_left.x, eye_right.x)),
		str((eye_left.y + eye_right.y) * 0.5), str(minf(mouth_left.x, mouth_right.x)),
		str(maxf(mouth_left.x, mouth_right.x)), str(latch.x), str(latch.y)])


func _install_eye_material() -> bool:
	var eye_mesh := avatar._eye_mount.get_node_or_null("Eyes") as MeshInstance3D
	if eye_mesh == null or eye_mesh.mesh.get_surface_count() != 1:
		return false
	var base: ShaderMaterial = avatar._materials.eye
	if eye_mesh.get_active_material(0) != base or base.shader.resource_path != EYE_FILE:
		return false
	var code := base.shader.code
	var old_pupil := "(p - look) / vec2(0.40, 0.56)"
	var old_lid := "float shut = clamp(lid_rest + blink * (1.0 - lid_rest), 0.0, 1.0);"
	var old_lower := "mix(-1.08, meet, clamp(blink, 0.0, 1.0))"
	var old_edge := "if (blink > 0.02"
	if code.count(old_pupil) != 1 or code.count(old_lid) != 1 or code.count(old_lower) != 1 or code.count(old_edge) != 1:
		return false
	code = code.replace("uniform vec2 look = vec2(0.0, -0.08);",
		"uniform vec2 look = vec2(0.0, -0.08);\nuniform vec2 shot_look;\nuniform float shot_wink;\nuniform float shot_isolated;")
	code = code.replace(old_pupil, "(p - shot_look) / vec2(0.40, 0.56)")
	code = code.replace(old_lid, """float lid_blink = blink * (1.0 - shot_isolated);
		if (side > 0.0) {
			lid_blink = max(lid_blink, shot_wink);
		}
		float shut = clamp(lid_rest + lid_blink * (1.0 - lid_rest), 0.0, 1.0);""")
	code = code.replace(old_lower, "mix(-1.08, meet, clamp(lid_blink, 0.0, 1.0))")
	code = code.replace(old_edge, "if (lid_blink > 0.02")
	var shader := Shader.new()
	shader.code = code
	material = ShaderMaterial.new()
	material.shader = shader
	for uniform: Dictionary in base.shader.get_shader_uniform_list():
		var value: Variant = base.get_shader_parameter(uniform.name)
		if value != null:
			material.set_shader_parameter(uniform.name, value)
	material.set_shader_parameter(&"white", IRIS_WHITE)
	avatar._materials.eye = material
	eye_mesh.set_surface_override_material(0, material)
	print("SHOT_NATIVE_EYES stock eye mesh and rim; capture camera target and viewer-right wink")
	return true


func _update_leg(leg: Variant) -> void:
	var pose: Transform3D = avatar.global_transform
	var yaw := atan2(pose.basis.z.x, pose.basis.z.z)
	avatar._update_leg(leg, avatar._body.transform, pose.affine_inverse(), yaw, Vector3.ZERO, 1.0 / 60.0)


func _sole_vertices(mesh: Mesh) -> PackedVector3Array:
	var all := PackedVector3Array()
	for surface in mesh.get_surface_count():
		var data := mesh.surface_get_arrays(surface)
		var vertices: PackedVector3Array = data[Mesh.ARRAY_VERTEX]
		all.append_array(vertices)
	if all.is_empty():
		return all
	var minimum := INF
	for p: Vector3 in all:
		minimum = minf(minimum, p.y)
	var lowest := PackedVector3Array()
	for p: Vector3 in all:
		if p.y <= minimum + 0.0001:
			lowest.append(p)
	return lowest


func _fit_contact_plane(pose: Transform3D) -> Vector3:
	var right := Vector3(pose.basis.x.x, 0.0, pose.basis.x.z).normalized()
	var forward := Vector3(pose.basis.z.x, 0.0, pose.basis.z.z).normalized()
	var a := _support_y(pose.origin - right * 0.065)
	var b := _support_y(pose.origin + right * 0.065)
	var c := _support_y(pose.origin - forward * 0.105)
	var d := _support_y(pose.origin + forward * 0.105)
	if not is_finite(a + b + c + d):
		return Vector3.ZERO
	return (Vector3.UP - right * ((b - a) / 0.13) - forward * ((d - c) / 0.21)).normalized()


func _sole_range(first: int) -> Vector3:
	var least := INF
	var visible_least := INF
	var visible_most := -INF
	for i in range(first, first + 2):
		var pose := meshes[i].global_transform
		for local: Vector3 in sole_samples[i]:
			var point := pose * local
			var ground := _ground_levels(point)
			if not is_finite(ground.x + ground.y):
				return Vector3(NAN, NAN, NAN)
			least = minf(least, point.y - maxf(ground.x, ground.y))
			# The visible outline is the lowest piece and defines contact.
			if i == first + 1:
				visible_least = minf(visible_least, point.y - ground.y)
				visible_most = maxf(visible_most, point.y - ground.y)
	return Vector3(least, visible_least, visible_most)


func _support_y(point: Vector3) -> float:
	var levels := _ground_levels(point)
	return maxf(levels.x, levels.y)


func _ground_levels(point: Vector3) -> Vector2:
	var h := world_harness.ray(point + Vector3.UP * 0.23, point - Vector3.UP * 0.28,
		world_harness.player.collision_mask)
	if h.is_empty():
		return Vector2(NAN, NAN)
	var hit: Vector3 = h.position
	var drawn := -INF
	var xz := Vector2(point.x, point.z)
	for tri in ground_triangles:
		var a := Vector2(tri[0].x, tri[0].z)
		var b := Vector2(tri[1].x, tri[1].z) - a
		var c := Vector2(tri[2].x, tri[2].z) - a
		var denom := b.cross(c)
		if absf(denom) < 0.0000001:
			continue
		var d := xz - a
		var u := d.cross(c) / denom
		var v := b.cross(d) / denom
		if u < -0.00001 or v < -0.00001 or u + v > 1.00001:
			continue
		var y := tri[0].y + u * (tri[1].y - tri[0].y) + v * (tri[2].y - tri[0].y)
		if absf(y - hit.y) < 0.25:
			drawn = maxf(drawn, y)
	if not is_finite(drawn):
		drawn = hit.y
		var collider := h.get("collider") as Node
		if collider != null and collider.get_parent() != null and collider.get_parent().get_meta("feature_kind", "") == "land_ground":
			drawn += avatar._visible_ground.lift_at(point.x, point.z)
	return Vector2(hit.y, drawn)

func _collect_ground(root: Node, center: Vector3) -> void:
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var geometry := node as MeshInstance3D
		var source := geometry.mesh as ArrayMesh
		if source == null or not geometry.is_visible_in_tree():
			continue
		var transform := geometry.global_transform
		var box: AABB = transform * source.get_aabb()
		if box.position.x > center.x + FOOT_REGION or box.end.x < center.x - FOOT_REGION \
		or box.position.z > center.z + FOOT_REGION or box.end.z < center.z - FOOT_REGION \
		or box.position.y > center.y + 0.25 or box.end.y < center.y - 0.15:
			continue
		for surface in source.get_surface_count():
			if source.surface_get_primitive_type(surface) != Mesh.PRIMITIVE_TRIANGLES:
				continue
			var arrays := source.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
			var count := indices.size() if not indices.is_empty() else vertices.size()
			for aspect in range(0, count - 2, 3):
				var a := transform * vertices[indices[aspect] if not indices.is_empty() else aspect]
				var b := transform * vertices[indices[aspect + 1] if not indices.is_empty() else aspect + 1]
				var c := transform * vertices[indices[aspect + 2] if not indices.is_empty() else aspect + 2]
				if minf(a.x, minf(b.x, c.x)) > center.x + FOOT_REGION or maxf(a.x, maxf(b.x, c.x)) < center.x - FOOT_REGION \
				or minf(a.z, minf(b.z, c.z)) > center.z + FOOT_REGION or maxf(a.z, maxf(b.z, c.z)) < center.z - FOOT_REGION:
					continue
				ground_triangles.append(PackedVector3Array([a, b, c]))


func _smooth(value: float) -> float:
	var t := clampf(value, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)
