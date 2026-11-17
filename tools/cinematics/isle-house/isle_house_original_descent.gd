extends SceneTree
## Standalone native Isle House trailer capture with a no-glow environment.
const WorldHarness := preload("res://game/tests/shared/world_harness.gd")
const ChesterCapturePose := preload("chester_capture_pose.gd")
const FRAME_SIZE := Vector2i(1920, 1080)
const FRAME_COUNT := 900
const EASED_START := 725
const EASED_LENS_TURN := 781
const EASED_LENS_SETTLE := 854
const EASED_EYE_CUE := 772
const EASED_FACE_FIRST := 711
const HOLD_FRAMES := 27
const MAP_SPAN_M := 2700.0
const MAP_HEIGHT_M := 26000.0
const FAR_M := 54000.0
const OVERVIEW_FRAME_COUNT := 450
const NEAR_M := 3.0
const ISLE_HOUSE_AIM := Vector3(-110.0, 37.0, 546.0)
const WATER_Y := -0.12
const LOW_WATER_EYE_Y := WATER_Y + 8.0
const ACTOR_XZ := Vector2(-132.0, 585.0)
const FINAL_CAMERA_XZ := Vector2(-135.3, 589.0)
const PROOF_FRAMES := [0, 26, 27, 28, 76, 77, 78, 79, 80, 90, 138, 206, 207, 208, 209, 210,
	211, 212, 213, 300, 420, 447, 448, 449, 450, 451, 452, 480, 510, 540, 600, 665, 715,
	730, 740, 750, 800, 844, 850, 861, 875, 880, 888, 898, 899]
const AERIAL_JOIN := 540
const TAIL_START := 590
const TAIL_PROOFS := [590, 598, 599, 600, 601, 602, 665, 715, 730, 739, 740, 741, 742,
	743, 744, 745, 746, 747, 748, 749, 750, 765, 766, 767, 768, 769, 777, 781, 782, 783, 784, 785, 800, 850,
	861, 875, 876, 877, 878, 879, 880, 881, 888, 898, 899]
const CONTACT_PROOFS := [590, 730, 744, 767, 783, 899]
const EASED_PROOFS := [0, 27, 28, 76, 77, 78, 79, 80, 206, 207, 208, 449, 450,
	650, 665, 695, 715, 719, 720, 725, 745, 758, 775, 781, 783, 793, 809,
	811, 820, 854, 899]
const AERIAL_PROOFS := [0, 1, 2, 90, 180, 276, 360, 450, 478, 479, 480, 481,
	510, 525, 536, 537, 538, 539, 540, 541, 542, 543, 544, 600, 665, 715, 730, 740,
	750, 800, 844, 850, 861, 875, 876, 877, 878, 879, 880, 881, 888, 898, 899]
const AERIAL_KEYS := [
	[0, Vector3(-760, 540, 1740), Vector3(19, -19, -29), Vector3(1, -1, -1),
		Vector3(-100, 25, 50), Vector3(-0.4, -1, 14), Vector3.ZERO, 37.0, 0.006],
	[276, Vector3(-550, 300, 1360), Vector3(30, -34, -54), Vector3.ZERO,
		Vector3(-104, 23, 253), Vector3(-0.6, 0, 42), Vector3.ZERO, 40.0, 0.007],
	[480, Vector3(-376, 110, 989), Vector3(26, -44, -30), Vector3(-3, 0, 4),
		Vector3(-114, 26, 507), Vector3(0.3, 5, 38), Vector3(0, 0, -25), 43.35, -0.014],
]
const HORIZON := "ContextWorld/BayAreaHorizon"
const JOIN_COLOR := "vec3(0.174, 0.215, 0.249)"
const RIPRAP := "res://game/resources/materials/world/shoreline/riprap.gdshader"
const FOLIAGE := "res://game/resources/materials/world/vegetation/vegetation_foliage.gdshader"

var harness: WorldHarness
var camera: Camera3D
var capture: SubViewport
var environment: Environment
var sun: DirectionalLight3D
var actor_aim: Vector3
var final_eye_y: float
var stock_fog_density: float
var aerial_intro := false
var tail_repair := false
var eased_map := false
var capture_chester: ChesterCapturePose
var aerial_keys: Array[Array] = []
var proof_frames: Array = PROOF_FRAMES


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() not in [2, 3] or args[1] not in ["staged", "preview", "render"] \
		or (args.size() == 3 and args[2] not in ["map", "map-eased", "aerial", "aerial-tail"]):
		_stop("Usage: -- /absolute/new-output-dir staged|preview|render [map|map-eased|aerial|aerial-tail]")
		return
	tail_repair = args.size() == 3 and args[2] == "aerial-tail"
	aerial_intro = args.size() == 3 and args[2] in ["aerial", "aerial-tail"]
	eased_map = args.size() == 3 and args[2] == "map-eased"
	if eased_map:
		proof_frames = EASED_PROOFS
	elif aerial_intro:
		proof_frames = TAIL_PROOFS if tail_repair else AERIAL_PROOFS
	var out := args[0]
	if not out.is_absolute_path() or DirAccess.dir_exists_absolute(out):
		_stop("Use a fresh absolute output directory.")
		return
	if DirAccess.make_dir_recursive_absolute(out) != OK:
		_stop("Cannot make output directory: " + out)
		return
	if DisplayServer.get_name() == "headless" or RenderingServer.get_current_rendering_method() != "forward_plus":
		_stop("Capture requires native Forward+ rendering.")
		return
	root.size = Vector2i(960, 540)
	root.title = "Treasure Island · Isle House capture"
	auto_accept_quit = false
	root.close_requested.connect(func() -> void: _stop("Capture window close was requested."))
	harness = WorldHarness.new(self)
	print("SHOT_DEVICE ", DisplayServer.get_name(), " / ", RenderingServer.get_video_adapter_name())
	var failure := await harness.load_world()
	if failure != "":
		_stop(failure)
		return
	harness.main.get_node("Interface").hide()
	var actor_failure := await _place_actor()
	if actor_failure != "":
		_stop(actor_failure)
		return
	if aerial_intro and not _prepare_aerial_intro():
		_stop("Aerial opening must descend continuously toward the source camera.")
		return
	var route_failure := _verify_low_route()
	if route_failure != "":
		_stop(route_failure)
		return
	var world_environment := harness.main.get_node("WorldEnvironment") as WorldEnvironment
	environment = world_environment.environment.duplicate() as Environment
	environment.glow_enabled = false
	world_environment.environment = environment
	stock_fog_density = environment.fog_density
	_lock_world_detail()
	if not _soften_horizon_join():
		_stop("The scoped horizon materials did not match latest main.")
		return
	_make_capture_viewport()
	var active_camera := capture.get_camera_3d()
	if active_camera != camera or active_camera.environment != environment or environment.glow_enabled:
		_stop("Capture must use the isolated no-glow environment.")
		return
	print("SHOT_ENVIRONMENT glow=", active_camera.environment.glow_enabled,
		" tonemap=", environment.tonemap_mode, " exposure=", environment.tonemap_exposure)
	if not aerial_intro and not _verify_map_registration():
		_stop("Opening view failed SVG registration.")
		return
	if eased_map and not _verify_portrait_registration():
		_stop("The native portrait no longer matches the approved closing composition.")
		return

	if args[1] != "render":
		if not await _preview(out):
			_stop("Could not capture the trailer proofs.")
			return
		if args[1] == "preview":
			quit()
			return
		if not await _review_gate(out):
			_stop("Capture stopped at the preview gate.")
			return
	if not await _render(out):
		_stop("Could not finish the trailer frame stream.")
		return
	print("SHOT_COMPLETE ", out)
	capture.queue_free()
	harness.main.queue_free()
	await process_frame
	quit()


func _place_actor() -> String:
	var settled := await harness.settle_player(ACTOR_XZ, {}, 0.24)
	if settled != "" or not harness.player.is_on_floor():
		return "Could not ground the stock player beside Isle House: " + settled
	var feet := harness.player.global_position
	actor_aim = feet + Vector3.UP * 0.97
	var end_grade := harness.ray(Vector3(FINAL_CAMERA_XZ.x, 15.0, FINAL_CAMERA_XZ.y),
		Vector3(FINAL_CAMERA_XZ.x, 0.0, FINAL_CAMERA_XZ.y), harness.player.collision_mask)
	if end_grade.is_empty() or not harness.is_walkable_ground(end_grade):
		return "Final camera needs clear walkable ground underneath."
	final_eye_y = (end_grade.position as Vector3).y + 1.30
	var face := FINAL_CAMERA_XZ - ACTOR_XZ
	harness.player.avatar_pivot.rotation.y = atan2(face.x, face.y)
	harness.player.avatar_pivot.show()
	if tail_repair or eased_map:
		capture_chester = ChesterCapturePose.new()
		var cue_frame := EASED_EYE_CUE if eased_map else ChesterCapturePose.ORIGINAL_EYE_CUE
		var contact_failure := capture_chester.prepare(harness, cue_frame)
		if not contact_failure.is_empty():
			return contact_failure
	print("SHOT_ACTOR grounded=", feet, " aim=", actor_aim, " final_eye_y=", final_eye_y)
	return ""


func _verify_low_route() -> String:
	var space := harness.player.get_world_3d().direct_space_state
	var sphere := SphereShape3D.new()
	sphere.radius = 0.32
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = sphere
	query.collision_mask = harness.player.collision_mask
	query.exclude = [harness.player.get_rid()]
	var last := Vector3.ZERO
	var previous_low := false
	var lowest := INF
	for frame in FRAME_COUNT:
		var point: Vector3 = _sample(frame).position
		if point.y > 60.0:
			continue
		query.transform = Transform3D(Basis.IDENTITY, point)
		query.motion = Vector3.ZERO
		if not space.intersect_shape(query, 1).is_empty():
			return "Low camera intersects a solid at frame %d (%s)." % [frame, point]
		if previous_low and not last.is_equal_approx(point):
			query.transform = Transform3D(Basis.IDENTITY, last)
			query.motion = point - last
			if space.cast_motion(query)[0] < 0.999:
				return "Low camera crosses a solid before frame %d." % frame
		last = point
		previous_low = true
		var below := harness.ray(point, Vector3(point.x, -0.25, point.z), harness.player.collision_mask)
		var surface := WATER_Y if below.is_empty() else (below.position as Vector3).y
		lowest = minf(lowest, point.y - surface)
	var finish: Vector3 = _sample(FRAME_COUNT - 1).position
	for height: float in [0.24, 0.90, 1.55]:
		var actor_point := harness.player.global_position + Vector3.UP * height
		if not harness.ray(finish, actor_point, harness.player.collision_mask).is_empty():
			return "Final camera sight line to the player is obstructed at %.2f m." % height
	print("SHOT_ROUTE low path clear, minimum height above first ground/water=", lowest,
		" final eye=", finish, " target distance=", finish.distance_to(actor_aim))
	return ""


func _lock_world_detail() -> void:
	var fixed_ranges := 0
	var hidden_lods := 0
	var shadow_proxies := 0
	var materials := {}
	for node in harness.world.find_children("*", "GeometryInstance3D", true, false):
		var geometry := node as GeometryInstance3D
		# The producers put LOD0 at begin=0 and place alternate meshes over it.
		# A far-only impostor also starts at zero, so it stays visible throughout.
		if geometry.visibility_range_begin > 0.0:
			geometry.hide()
			hidden_lods += 1
			continue
		# Vegetation's distance shadow is replaced by the highest mesh, which
		# already casts. Keep the fences' distinct shadow-only strips.
		if geometry.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY \
		and (geometry.has_meta("context_kind") or geometry.get_meta("street_detail_layer", "") == "vegetation"):
			geometry.hide()
			shadow_proxies += 1
			continue
		if geometry.visibility_range_end > 0.0:
			geometry.visibility_range_end = 0.0
			geometry.visibility_range_end_margin = 0.0
			geometry.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
			fixed_ranges += 1
		_collect_materials(geometry, materials)
	for material: ShaderMaterial in materials:
		match material.shader.resource_path:
			FOLIAGE:
				material.set_shader_parameter("distance_fade", false)
			RIPRAP:
				# All shoreline batches lie within 4 km of every camera pose.
				# Keep the actual stones and the underlay's near treatment.
				material.set_shader_parameter("stone_reach_min_m", 10000.0)
				material.set_shader_parameter("stone_reach_max_m", 10000.0)
				material.set_shader_parameter("stone_thin_start", 1.0)
				material.set_shader_parameter("underlay_fade_m", Vector2(10000.0, 11000.0))
	print("SHOT_FIXED_DETAIL ranges=", fixed_ranges, " alternate_meshes=", hidden_lods,
		" duplicate_shadow_proxies=", shadow_proxies, " materials=", materials.size())


func _collect_materials(geometry: GeometryInstance3D, materials: Dictionary) -> void:
	if geometry.material_override != null:
		_record_material(geometry.material_override, materials)
	elif geometry is MeshInstance3D and geometry.mesh != null:
		for i in geometry.mesh.get_surface_count():
			_record_material(geometry.get_active_material(i), materials)
	elif geometry is MultiMeshInstance3D and geometry.multimesh != null and geometry.multimesh.mesh != null:
		var mesh: Mesh = geometry.multimesh.mesh
		for i in mesh.get_surface_count():
			_record_material(mesh.surface_get_material(i), materials)


func _record_material(material: Material, materials: Dictionary) -> void:
	if material is ShaderMaterial and material.shader != null and material.shader.resource_path in [RIPRAP, FOLIAGE]:
		materials[material] = true


func _soften_horizon_join() -> bool:
	# Preserve the exact authored shapes and surrounding water. Color-match the
	# north art and mapped East Bay at their 30° geographic junction.
	var north := harness.world.get_node_or_null(HORIZON + "/Continuous360Horizon/Sector1") as MeshInstance3D
	var eastern := harness.world.get_node_or_null(HORIZON + "/MappedEasternBackground")
	if north == null or eastern == null:
		return false
	var north_source := north.material_override as ShaderMaterial
	var north_shader := _horizon_shader(north_source, "ALPHA_SCISSOR_THRESHOLD = 0.5;", """
	float joined = smoothstep(27.0, 30.0, geographic_bearing);
	ALBEDO = mix(ALBEDO, %s, joined);
	ALPHA_SCISSOR_THRESHOLD = 0.5;""" % JOIN_COLOR)
	var hills := eastern.get_node_or_null("EastSetbackHills") as MeshInstance3D
	if north_shader == null or hills == null:
		return false
	var hills_source := hills.material_override as ShaderMaterial
	var east_shader := _horizon_shader(hills_source, "ALBEDO = horizon_grade(color, length(geographic_position.xz));", """
	float bearing = degrees(atan(geographic_position.x, -geographic_position.z));
	float east = smoothstep(30.0, 36.0, bearing);
	vec3 authored = horizon_grade(color, length(geographic_position.xz));
	float treatment = smoothstep(28.0, 30.0, bearing) * (1.0 - smoothstep(120.0, 135.0, bearing));
	vec3 eased = mix(%s, authored * vec3(0.92, 0.92, 0.91), east);
	ALBEDO = mix(authored, eased, treatment);""" % JOIN_COLOR)
	if east_shader == null:
		return false
	north.material_override = _horizon_material(north_source, north_shader)
	for profile_name: String in ["EastSetbackHills", "EastDevelopedEnvelope", "EastLowShore"]:
		var profile := eastern.get_node_or_null(profile_name) as MeshInstance3D
		if profile == null or not profile.material_override is ShaderMaterial:
			return false
		profile.material_override = _horizon_material(profile.material_override as ShaderMaterial, east_shader)
	print("SHOT_HORIZON matched north and eastern grades around the mapped 30-degree join")
	return true


func _horizon_shader(material: ShaderMaterial, before: String, after: String) -> Shader:
	if material == null or material.shader == null or material.shader.code.count(before) != 1:
		return null
	var shader := Shader.new()
	shader.code = material.shader.code.replace(before, after)
	return shader


func _horizon_material(source: ShaderMaterial, shader: Shader) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = shader
	material.render_priority = source.render_priority
	for uniform: Dictionary in source.shader.get_shader_uniform_list():
		var parameter: Variant = source.get_shader_parameter(uniform.name)
		if parameter != null:
			material.set_shader_parameter(uniform.name, parameter)
	return material


func _make_capture_viewport() -> void:
	sun = harness.main.get_node("Sun") as DirectionalLight3D
	sun.shadow_enabled = true
	sun.shadow_opacity = 1.0
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sun.directional_shadow_max_distance = FAR_M
	sun.directional_shadow_blend_splits = true
	sun.directional_shadow_fade_start = 0.92
	RenderingServer.directional_shadow_atlas_set_size(8192, false)
	RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)

	capture = SubViewport.new()
	capture.name = "OverviewCapture"
	capture.world_3d = root.world_3d
	capture.size = FRAME_SIZE
	capture.msaa_3d = Viewport.MSAA_4X
	capture.anisotropic_filtering_level = Viewport.ANISOTROPY_16X
	capture.mesh_lod_threshold = 0.0
	capture.scaling_3d_scale = 1.0
	capture.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(capture)
	camera = Camera3D.new()
	camera.name = "SiteOverviewCamera"
	camera.keep_aspect = Camera3D.KEEP_HEIGHT
	camera.environment = environment
	camera.near = 3.0
	camera.far = FAR_M
	capture.add_child(camera)
	_pose(0)
	camera.make_current()
	_pin_ground_dressing()
	root.disable_3d = true
	# Show the rendered texture without drawing the 3D world twice.
	var monitor := TextureRect.new()
	monitor.name = "OffscreenCaptureMonitor"
	monitor.texture = capture.get_texture()
	monitor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	monitor.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	monitor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(monitor)
	monitor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	print("SHOT_QUALITY ", capture.size, " MSAA=", capture.msaa_3d,
		" anisotropy=", capture.anisotropic_filtering_level,
		" mesh_lod_threshold=", capture.mesh_lod_threshold, " shadow_atlas=8192 shadow_range=camera_far shadow_opacity=1")


func _pin_ground_dressing() -> void:
	# Keep the stock procedural cover on the near shore, without replacing
	# cells as the moving shot enters its short grass radius.
	var dressing := harness.main.ground_dressing
	if dressing == null:
		return
	_pose(FRAME_COUNT - 1)
	dressing.reparent(capture)
	dressing._process(0.0)
	dressing.set_process(false)
	_pose(0)
	print("SHOT_DRESSING fixed at the low camera's final waterfront position")


func _draw(frame: int) -> void:
	_pose(frame)
	await process_frame
	if capture_chester != null:
		capture_chester.aim_eyes(frame, camera)
	await RenderingServer.frame_post_draw


func _warm(frame: int) -> void:
	capture.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	capture.use_taa = false
	await _draw(frame)
	capture.use_taa = true
	for i in range(12, 0, -1):
		await _draw(maxi(frame - i, 0))


func _preview(out: String) -> bool:
	var folder := out.path_join("preview")
	if DirAccess.make_dir_recursive_absolute(folder) != OK:
		return false
	var previous := -2
	# Establish the original opening before testing the nearby eye detail.
	var proof_order := [TAIL_START if tail_repair else 0, FRAME_COUNT - 1]
	proof_order.append_array(proof_frames.slice(1, -1))
	for frame: int in proof_order:
		if frame != previous + 1:
			await _warm(frame)
		await _draw(frame)
		if capture_chester != null and frame in CONTACT_PROOFS and not capture_chester.verify_contacts(frame):
			return false
		var pixels := _read_frame()
		if pixels == null or pixels.save_png(folder.path_join("frame-%04d.png" % frame)) != OK:
			return false
		previous = frame
		print("SHOT_PROOF frame=", frame, " camera=", camera.global_position, " fov=", camera.fov,
			" near=", camera.near, " shadow_splits=", Vector3(sun.directional_shadow_split_1,
				sun.directional_shadow_split_2, sun.directional_shadow_split_3))
	print("SHOT_PREVIEW_READY ", folder)
	return true


func _review_gate(out: String) -> bool:
	capture.render_target_update_mode = SubViewport.UPDATE_DISABLED
	var deadline := Time.get_ticks_msec() + 300000
	var gate := out.path_join("review-decision.txt")
	print("SHOT_WAIT_REVIEW ", gate)
	while Time.get_ticks_msec() < deadline:
		if FileAccess.file_exists(gate):
			return FileAccess.get_file_as_string(gate).strip_edges() == "GO"
		OS.delay_msec(75)
		await process_frame
	return false


func _render(out: String) -> bool:
	var raw := FileAccess.open(out.path_join("frames.rgb"), FileAccess.WRITE)
	if raw == null:
		return false
	var face_track: FileAccess
	if eased_map:
		face_track = FileAccess.open(out.path_join("face-track.csv"), FileAccess.WRITE)
		if face_track == null:
			return false
	var first := TAIL_START if tail_repair else 0
	await _warm(first)
	for frame in range(first, FRAME_COUNT):
		await _draw(frame)
		if capture_chester != null and frame in CONTACT_PROOFS and not capture_chester.verify_contacts(frame):
			return false
		var pixels := _read_frame()
		if pixels == null:
			return false
		if frame in proof_frames:
			if pixels.save_png(out.path_join("frame-%04d.png" % frame)) != OK:
				return false
		pixels.convert(Image.FORMAT_RGB8)
		raw.store_buffer(pixels.get_data())
		if raw.get_error() != OK:
			return false
		if face_track != null and frame >= EASED_FACE_FIRST:
			face_track.store_csv_line(capture_chester.face_row(frame, camera))
			if face_track.get_error() != OK:
				return false
		if frame % 60 == 0:
			print("SHOT_FRAME ", frame, " / ", FRAME_COUNT)
	raw.close()
	if face_track != null:
		face_track.close()
	return true


func _verify_map_registration() -> bool:
	var original := camera.get_camera_transform()
	var pins: Array[Vector2] = [Vector2(-208.0, -954.0), Vector2(711.0, 135.0), Vector2(-35.0, 954.0),
		Vector2(345.0, 601.0), Vector2(529.0, 489.0), Vector2(-60.0, 695.0)]
	for pin: Vector2 in pins:
		var actual := camera.unproject_position(Vector3(pin.x, 0.0, pin.y))
		var expected := Vector2(960.0, 540.0) + pin * 0.4
		print("SHOT_MAP_PIN ", pin, " got=", actual, " expected=", expected)
		if actual.distance_to(expected) > 0.15:
			return false
	return original.is_equal_approx(camera.get_camera_transform())


func _pose(frame: int) -> void:
	var pose := _sample(frame)
	var position: Vector3 = pose.position
	var direction: Vector3 = pose.direction
	var target: Vector3 = pose.target
	var screen_up: Vector3 = pose.screen_up
	if pose.has("frustum_size"):
		camera.set_frustum(pose.frustum_size, Vector2(0.0, pose.frustum_shift), NEAR_M, FAR_M)
	else:
		camera.set_perspective(float(pose.fov), NEAR_M, FAR_M)
	camera.global_position = position
	camera.look_at(position + direction, screen_up)
	_fit_shadow_cascades(position.distance_to(target))
	environment.fog_density = stock_fog_density * minf(1.0, 650.0 / position.y)


func _fit_shadow_cascades(focus_depth: float) -> void:
	# The reviewed all-distance profile includes the actual scene beyond the
	# Bay Bridge and holds fine cascades around the current depth of interest.
	var span := FAR_M - NEAR_M
	var first_end := maxf(250.0, focus_depth * 1.12 + 75.0)
	var second_end := maxf(900.0, focus_depth * 1.45 + 240.0)
	var third_end := maxf(2500.0, focus_depth * 2.0 + 700.0)
	sun.directional_shadow_split_1 = minf((first_end - NEAR_M) / span, 0.78)
	sun.directional_shadow_split_2 = minf((second_end - NEAR_M) / span, 0.86)
	sun.directional_shadow_split_3 = minf((third_end - NEAR_M) / span, 0.93)


func _sample(frame: int) -> Dictionary:
	if aerial_intro and frame < AERIAL_JOIN:
		return _aerial_sample(frame)
	if eased_map and frame >= EASED_START:
		return _eased_portrait(frame)
	return _established_sample(frame)


func _eased_portrait(frame: int) -> Dictionary:
	# Follow the established world-space path while spending more time near eye height.
	var f := float(frame)
	var lag := 12.0 * _window(f, EASED_START, 780.0) * (1.0 - _window(f, 780.0, 840.0))
	var pose := _established_sample(f - lag)
	var first := _projected_scale(EASED_START)
	var incoming_rate := (_projected_scale(EASED_START + 0.05) - _projected_scale(EASED_START - 0.05)) * 300.0
	var finished := _projected_scale(FRAME_COUNT - 1) / 0.8
	var scale: float
	if f < EASED_LENS_TURN:
		scale = _lens_curve(f, EASED_START, EASED_LENS_TURN, first, 480.0, incoming_rate, 200.0)
	elif f < EASED_LENS_SETTLE:
		scale = _lens_curve(f, EASED_LENS_TURN, EASED_LENS_SETTLE, 480.0, finished, 200.0, 0.0)
	else:
		scale = finished
	var depth: float = (pose.position as Vector3).distance_to(pose.target)
	var near_half := NEAR_M * FRAME_SIZE.y * 0.5 / (depth * scale)
	# The shifted lens frames the same top-anchored portrait directly in the renderer.
	var anchor := 1.0 - 0.2 * _window(f, 777.0, EASED_LENS_SETTLE)
	pose["frustum_size"] = near_half * 2.0
	pose["frustum_shift"] = near_half * (1.0 - anchor) / anchor
	return pose


func _projected_scale(frame: float) -> float:
	var pose := _established_sample(frame)
	var depth: float = (pose.position as Vector3).distance_to(pose.target)
	return FRAME_SIZE.y * 0.5 / (depth * tan(deg_to_rad(float(pose.fov) * 0.5)))


func _lens_curve(frame: float, first: float, last: float, a: float, b: float, da: float, db: float) -> float:
	# Match endpoint velocities in projected pixels per second, at 30 frames per second.
	var span := last - first
	return cubic_interpolate(a, b, b - span * da / 15.0, a + span * db / 15.0, (frame - first) / span)


func _verify_portrait_registration() -> bool:
	_pose(FRAME_COUNT - 1)
	var pins: Array[Vector3] = [actor_aim, actor_aim + Vector3.UP * 0.4, actor_aim + Vector3.RIGHT * 0.25]
	var actual: Array[Vector2] = []
	for point in pins:
		actual.append(camera.unproject_position(point))
	camera.set_perspective(float(_established_sample(FRAME_COUNT - 1).fov), NEAR_M, FAR_M)
	var matched := true
	for i in pins.size():
		var expected := (camera.unproject_position(pins[i]) - Vector2(192.0, 0.0)) / 0.8
		print("SHOT_PORTRAIT_PIN ", actual[i], " expected=", expected)
		matched = matched and actual[i].distance_to(expected) <= 0.3
	_pose(0)
	return matched


func _established_sample(frame: float) -> Dictionary:
	if frame < OVERVIEW_FRAME_COUNT:
		return _overview_sample(int(frame))
	var end := _overview_sample(OVERVIEW_FRAME_COUNT - 1)
	var t := float(frame - (OVERVIEW_FRAME_COUNT - 1)) / 30.0
	var route_frame := lerpf(565.0, 882.0, _window(t, 0.0, 14.35))
	var path := _approach_sample(route_frame)
	var blend := _window(t, 0.0, 4.0)
	var position := (end.position as Vector3).lerp(path.position, blend)
	var target := (end.target as Vector3).lerp(path.target, blend)
	var screen_up := (end.screen_up as Vector3).lerp(path.screen_up, blend).normalized()
	var start_lens := tan(deg_to_rad(float(end.fov) / 2.0))
	var end_lens := tan(deg_to_rad(float(path.fov) / 2.0))
	var lens := exp(lerpf(log(start_lens), log(end_lens), blend))
	return {"position": position, "target": target, "direction": position.direction_to(target),
		"screen_up": screen_up, "fov": 2.0 * rad_to_deg(atan(lens))}


func _prepare_aerial_intro() -> bool:
	for key: Array in AERIAL_KEYS:
		aerial_keys.append([key[0], key[1], key[2], key[3], key[4], key[5], key[6],
			Vector3(_log_lens(key[7]), 0, 0), Vector3(key[8], 0, 0), Vector3.ZERO])
	var poses: Array[Dictionary] = []
	for offset in range(-2, 3):
		var pose := _established_sample(AERIAL_JOIN + offset)
		pose["lens"] = Vector3(_log_lens(pose.fov), 0, 0)
		poses.append(pose)
	var end: Array = [AERIAL_JOIN]
	# At 30 fps the 5-point derivative uses 30/12 and (30*30)/12.
	# Centered differences avoid cancellation at world-scale coordinates.
	for property: String in ["position", "target", "lens"]:
		var center: Vector3 = poses[2][property]
		var back: Vector3 = poses[1][property] - center
		var back2: Vector3 = poses[0][property] - center
		var ahead: Vector3 = poses[3][property] - center
		var ahead2: Vector3 = poses[4][property] - center
		var velocity := (back2 - 8.0 * back + 8.0 * ahead - ahead2) * 2.5
		var acceleration := (16.0 * (back + ahead) - back2 - ahead2) * 75.0
		end.append_array([center, velocity, acceleration])
	aerial_keys.append(end)
	var previous: Vector3 = _aerial_sample(0).position
	for frame in range(1, AERIAL_JOIN + 1):
		var current: Vector3 = _sample(frame).position
		if current.x <= previous.x or current.y >= previous.y or current.z >= previous.z:
			print("SHOT_AERIAL nonmonotonic at ", frame, " ", previous, " to ", current)
			return false
		previous = current
	print("SHOT_AERIAL_JOIN frame=", AERIAL_JOIN, " position=", end[1], " velocity=", end[2],
		" acceleration=", end[3], " target=", end[4], " fov=", poses[2].fov)
	return true


func _aerial_sample(frame: int) -> Dictionary:
	var from: Array = aerial_keys[0]
	var to: Array = aerial_keys[1]
	for index in range(1, aerial_keys.size() - 1):
		if frame < int(aerial_keys[index][0]):
			break
		from = aerial_keys[index]
		to = aerial_keys[index + 1]
	var span := float(to[0] - from[0])
	var t := (float(frame) - float(from[0])) / span
	var seconds := span / 30.0
	var position := _quintic(from, to, 1, t, seconds)
	var target := _quintic(from, to, 4, t, seconds)
	var focal := _quintic(from, to, 7, t, seconds).x
	var screen_up := Vector3.UP
	if frame > 510:
		var outgoing_up: Vector3 = _established_sample(frame).screen_up
		screen_up = screen_up.lerp(outgoing_up, _window(float(frame), 510, AERIAL_JOIN)).normalized()
	return {"position": position, "target": target, "direction": position.direction_to(target),
		"screen_up": screen_up, "fov": 2.0 * rad_to_deg(atan(exp(focal)))}


func _quintic(from: Array, to: Array, channel: int, t: float, seconds: float) -> Vector3:
	# Each key stores value, velocity and acceleration for the three channels.
	var a0: Vector3 = from[channel]
	var a1: Vector3 = from[channel + 1] * seconds
	var a2: Vector3 = from[channel + 2] * (0.5 * seconds * seconds)
	var p: Vector3 = to[channel] - a0 - a1 - a2
	var v: Vector3 = to[channel + 1] * seconds - a1 - 2.0 * a2
	var a: Vector3 = to[channel + 2] * (seconds * seconds) - 2.0 * a2
	var a3 := 10.0 * p - 4.0 * v + 0.5 * a
	var a4 := -15.0 * p + 7.0 * v - a
	var a5 := 6.0 * p - 3.0 * v + 0.5 * a
	return a0 + t * (a1 + t * (a2 + t * (a3 + t * (a4 + t * a5))))


func _log_lens(vertical_fov: float) -> float:
	return log(tan(deg_to_rad(vertical_fov * 0.5)))


func _overview_sample(frame: int) -> Dictionary:
	# Slide the point of interest toward the ferry approach as the lens
	# opens and the camera descends. Fixing the look target from above
	# avoids letting the high-altitude tilt send the island offscreen.
	var t := float(maxi(frame-HOLD_FRAMES, 0))/30.0
	var move := _ease(t/13.1)
	var dive := _ease(t/12.9)
	var track := _window(t, 1.6, 11.6)
	var altitude := exp(lerpf(log(MAP_HEIGHT_M), log(116.0), dive))
	var position := Vector3(-348.0*move, altitude, 945.0*move)
	var target := Vector3(-122.0*track, 16.0*track, 632.0*track)
	var direction := position.direction_to(target)
	var yaw := deg_to_rad(36.0) * _window(t, 2.0, 11.3)
	var zoom := _window(t, 1.1, 10.0)
	var lens := exp(lerpf(log(MAP_SPAN_M/(2.0*MAP_HEIGHT_M)), log(tan(deg_to_rad(46.0/2.0))), zoom))
	return {"position": position, "target": target, "direction": direction,
		"screen_up": Vector3.FORWARD.rotated(Vector3.UP, -yaw), "fov": 2.0*rad_to_deg(atan(lens))}


func _approach_sample(frame: float) -> Dictionary:
	var t := maxf(frame - float(HOLD_FRAMES), 0.0) / 30.0
	var arc := _ease(t / 28.4)
	# Retain the proven low bay arc and extend its end toward Chester.
	var xz := Vector2.ZERO.bezier_interpolate(Vector2(-170.0, 630.0),
		Vector2(-605.0, 1450.0), FINAL_CAMERA_XZ, arc)
	var descent := exp(lerpf(log(MAP_HEIGHT_M), log(LOW_WATER_EYE_Y), _ease(t / 24.7)))
	var altitude := descent + (final_eye_y - LOW_WATER_EYE_Y) * _window(t, 24.4, 28.4)
	var position := Vector3(xz.x, altitude, xz.y)
	var tower_target := ISLE_HOUSE_AIM * _window(t, 3.2, 19.2)
	var target := tower_target.lerp(actor_aim, _window(t, 17.4, 26.8))
	# Finish levelling the roll before the camera aims up from the bay.
	var screen_up := Vector3.FORWARD.lerp(Vector3.UP, _window(t, 4.2, 14.5)).normalized()
	var zoom := _window(t, 2.4, 20.4)
	var lens := exp(lerpf(log(MAP_SPAN_M / (2.0 * MAP_HEIGHT_M)), log(tan(deg_to_rad(43.0 / 2.0))), zoom))
	lens = lerpf(lens, tan(deg_to_rad(20.5 / 2.0)), _window(t, 21.3, 28.4))
	return {"position": position, "target": target, "screen_up": screen_up, "fov": 2.0 * rad_to_deg(atan(lens))}


func _window(t: float, start: float, end: float) -> float:
	return _ease((t-start)/(end-start))


func _ease(t: float) -> float:
	t = clampf(t, 0.0, 1.0)
	return t*t*t*(t*(t*6.0-15.0)+10.0)


func _read_frame() -> Image:
	var pixels := capture.get_texture().get_image()
	if pixels == null or pixels.is_empty() or pixels.get_size() != FRAME_SIZE:
		return null
	return pixels


func _stop(message: String) -> void:
	push_error(message)
	quit(1)
