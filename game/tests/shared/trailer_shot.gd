extends SceneTree
## Renders one trailer shot offline from a shot file (tools/trailer/shots/*.json),
## frame by frame on a fixed clock, so the motion is perfectly even whatever the
## real frame rate. Run it through tools/trailer/render-shot.sh, which starts it
## with --fixed-fps set to the shot's fps (30 unless it says) and encodes the
## frames; see tools/trailer/README.md.
##
##   tools/godot --path . --resolution 960x540 --disable-vsync --fixed-fps 30 \
##     --script game/tests/shared/trailer_shot.gd -- --shot SHOT.json --out /abs/new/dir [--stills]
##
## The capture approach is the Isle House trailer's (tools/cinematics/isle-house on
## codex/isle-house-trailer-repro): the normal game world is loaded, the 3D world is
## drawn only into an offscreen SubViewport at the shot's resolution (the small
## window shows it; no HUD, touch or fps overlay can reach the frames), and each
## frame is read back after it is drawn. Under --fixed-fps 30 every frame is two
## physics ticks of 1/60 s, so Chester (the stock player, driven through its real
## input actions) and the camera (a pure function of the frame number) advance
## exactly 1/30 s a frame.
##
## Output in --out: frames.rgb, raw RGB24 frames back to back (the wrapper encodes
## and deletes it), or with --stills frame-NNNN.png for a few frames only.
## Log lines start SHOT_; the run ends with SHOT_COMPLETE or exits non-zero.

const WorldHarness := preload("res://game/tests/shared/world_harness.gd")
## Frames a second unless the shot sets "fps" (30 or 60); the trailer's clips are 30.
const DEFAULT_FPS := 30
const FAR_M := 54000.0
## Frames drawn at the first pose before anything moves: Metal compiles its
## pipelines on the first frames, the sky's radiance map redraws after a sun
## change, and TAA needs a history (the Isle House capture warmed for 12).
const SETTLE_FRAMES := 90
## Frames drawn before each still in --stills (TAA history; motion vectors), and
## frames of the camera's real path before the first recorded frame.
const STILL_WARM_FRAMES := 12
## Pre-roll before the first recorded frame when the shot's track starts later:
## Chester's stock acceleration and the avatar's springs reach a steady state.
const DEFAULT_PREROLL_S := 1.5
## Camera clearance from anything the player collides with, checked each frame
## below CLEARANCE_CHECK_BELOW_M (the Isle House capture's low-route check).
const CAMERA_CLEARANCE_M := 0.3
const CLEARANCE_CHECK_BELOW_M := 80.0
const RIPRAP := "res://game/resources/materials/world/shoreline/riprap.gdshader"
const FOLIAGE := "res://game/resources/materials/world/vegetation/vegetation_foliage.gdshader"
const MOVES := ["idle", "walk", "run"]
## Wall-clock limit for loading the world and reaching play.
const LOAD_LIMIT_MS := 1200000

var harness: WorldHarness
var shot_files: Array[String] = []
var shots: Array[Dictionary] = []
var shot: Dictionary
var out_root := ""
var out_dir := ""
var stills := false
var capture: SubViewport
var camera: Camera3D
var environment: Environment
var sun: DirectionalLight3D
var stock_fog_density := 0.0
var size := Vector2i(1920, 1080)
var fps := DEFAULT_FPS
var ticks_per_frame := 2
var handle_s := 0.5
var duration_s := 0.0
var frame_count := 0
var keys: Array[Dictionary] = []
var track: Array[Dictionary] = []
var chester_on := false
var path_progress := 0.0
var path_entry := -1
var active_path: Array[Vector2] = []
var last_physics_frame := -1
var last_camera := Vector3.INF
var last_speed := -1.0
var worst_speed_change := 0.0
var obstructed_frames := 0
var failed_shots: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var problem := _read_args()
	if not problem.is_empty():
		_stop(problem)
		return
	# Check every shot file before the world loads.
	for i in shots.size():
		shot = shots[i]
		problem = _read_shot()
		if not problem.is_empty():
			_stop("%s: %s" % [shot_files[i], problem])
			return
		if bool(shot.get("street_detail", true)) != bool(shots[0].get("street_detail", true)):
			_stop("shots rendered together must agree on street_detail")
			return
	if DisplayServer.get_name() == "headless" or RenderingServer.get_current_rendering_method() != "forward_plus":
		_stop("trailer capture needs native Forward+ rendering (omit --headless)")
		return
	root.title = "Treasure Island trailer capture"
	auto_accept_quit = false
	root.close_requested.connect(func() -> void: _stop("capture window close was requested"))
	print("SHOT_DEVICE ", DisplayServer.get_name(), " / ", RenderingServer.get_video_adapter_name())
	harness = WorldHarness.new(self)
	var street_detail: Variant = WorldLoader.STREET_DETAIL_LAYERS.duplicate() if bool(shots[0].get("street_detail", true)) else []
	var failure := await _load_world(street_detail)
	if not failure.is_empty():
		_stop(failure)
		return
	print(harness.street_detail_summary())
	# GameMain pauses on focus loss once play is ready, and a pause lets go of
	# every held action (an Isle House render stopped this way). A capture never
	# pauses: with play marked not ready the focus-loss pause doesn't fire. Any
	# pause that still happens fails the run (_check_clock).
	harness.main.set("_world_ready", false)
	harness.main.get_node("Interface").hide()
	sun = harness.main.get_node("Sun") as DirectionalLight3D
	var world_environment := harness.main.get_node("WorldEnvironment") as WorldEnvironment
	environment = world_environment.environment.duplicate() as Environment
	world_environment.environment = environment
	stock_fog_density = environment.fog_density
	_lock_world_detail()
	_make_capture_viewport()
	for i in shots.size():
		shot = shots[i]
		_read_shot()
		out_dir = out_root.path_join(str(shot.name))
		if DirAccess.make_dir_recursive_absolute(out_dir) != OK:
			_stop("cannot make " + out_dir)
			return
		if Engine.physics_ticks_per_second % fps != 0:
			_stop("physics runs at %d ticks a second, not a multiple of the shot's %d fps" % [Engine.physics_ticks_per_second, fps])
			return
		ticks_per_frame = Engine.physics_ticks_per_second / fps
		print("SHOT_BEGIN ", shot.name, " -> ", out_dir)
		failure = _set_sun()
		if failure.is_empty():
			failure = await _place_chester()
		if not failure.is_empty():
			_fail(failure)
			if stills:
				continue
			return
		_apply_shadows()
		environment.glow_enabled = bool(shot.get("glow", false))
		capture.size = size
		if not await _record():
			harness.release_input()
			if stills:
				continue
			return
		print("SHOT_MOTION %s: the camera's worst frame-to-frame speed change=%.1f%%; frames with Chester hidden from the camera=%d" % [shot.name, worst_speed_change * 100.0, obstructed_frames])
		print("SHOT_DONE ", out_dir)
	if failed_shots.is_empty():
		print("SHOT_COMPLETE ", out_root)
	capture.queue_free()
	harness.main.queue_free()
	await process_frame
	quit(0 if failed_shots.is_empty() else 1)


## WorldHarness.load_world with a longer limit: on a fresh Metal shader cache,
## startup's "Compiling shaders" step and the first reflection captures took
## more than its 300 s on the M1 Pro (2026-11-16, as in the Isle House capture).
## The same steps otherwise, so the world is the one every check sees.
func _load_world(street_detail: Variant) -> String:
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	var main := (load("res://game/scenes/main.tscn") as PackedScene).instantiate() as GameMain
	main.capture_mouse_on_ready = false
	main.use_saved_settings = false
	harness.main = main
	harness.world = main.get_node("WorldRoot") as WorldLoader
	harness.world.street_detail_request = street_detail
	harness.player = main.get_node("Player") as PlayerController
	harness.hud = main.get_node("Interface/HUD") as GameHUD
	var ready: Array = []
	var failed: Array = []
	harness.world.world_ready.connect(func(report: Dictionary) -> void: ready.append(report))
	harness.world.world_failed.connect(func(code: String, message: String, _keys: Array) -> void: failed.append("%s: %s" % [code, message]))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while ready.is_empty() and failed.is_empty() and Time.get_ticks_msec() - started < LOAD_LIMIT_MS:
		await process_frame
	if not failed.is_empty():
		return "world failed to load: %s" % failed[0]
	while not (harness.player.was_first_reveal_grounded() and main.is_play_ready()) \
	and Time.get_ticks_msec() - started < LOAD_LIMIT_MS:
		await process_frame
	if not main.is_play_ready():
		return "startup did not reach play within %d s" % (LOAD_LIMIT_MS / 1000)
	print("SHOT_LOADED in %.0f s" % ((Time.get_ticks_msec() - started) / 1000.0))
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	harness.player.set_gameplay_enabled(false)
	harness.clean_hud()
	(main.get_node("WorldEnvironment") as SkyWeather).hold_at(0.0)
	return ""


func _read_args() -> String:
	var args := WorldHarness.user_args()
	var usage := "use --shot FILE[,FILE...] --out /abs/new/dir [--stills]"
	for key: String in args:
		if key not in ["shot", "out", "stills"]:
			return "unknown argument --%s; %s" % [key, usage]
	if not args.get("shot") is String or not args.get("out") is String:
		return usage
	out_root = args.out
	stills = args.has("stills")
	if not out_root.is_absolute_path() or DirAccess.dir_exists_absolute(out_root):
		return "--out must be a new absolute directory: " + out_root
	var names := {}
	for file: String in str(args.shot).split(","):
		var text := FileAccess.get_file_as_string(file)
		if text.is_empty():
			return "cannot read shot file " + file
		var parsed: Variant = JSON.parse_string(text)
		if not parsed is Dictionary:
			return "shot file is not a JSON object: " + file
		var one := parsed as Dictionary
		one["name"] = str(one.get("name", file.get_file().get_basename()))
		if names.has(one.name) or not str(one.name).is_valid_filename():
			return "shot names must be distinct file names: " + str(one.name)
		names[one.name] = true
		shot_files.append(file)
		shots.append(one)
	return ""


## Reads and checks the shot file (format in tools/trailer/README.md).
func _read_shot() -> String:
	keys.clear()
	track.clear()
	path_entry = -1
	path_progress = 0.0
	last_camera = Vector3.INF
	last_speed = -1.0
	worst_speed_change = 0.0
	obstructed_frames = 0
	duration_s = float(shot.get("duration", 0.0))
	handle_s = float(shot.get("handle", 0.5))
	if duration_s <= 0.0 or handle_s < 0.0:
		return "duration must be > 0 and handle >= 0"
	var resolution: Array = shot.get("resolution", [1920, 1080])
	size = Vector2i(int(resolution[0]), int(resolution[1]))
	if size.x < 64 or size.y < 64 or size.x % 2 != 0 or size.y % 2 != 0:
		return "resolution must be even and at least 64 x 64"
	fps = int(shot.get("fps", DEFAULT_FPS))
	if fps not in [30, 60]:
		return "fps must be 30 or 60"
	frame_count = roundi((duration_s + 2.0 * handle_s) * fps)
	var cam: Dictionary = shot.get("camera", {})
	for raw: Variant in cam.get("keys", []):
		var key := raw as Dictionary
		if key == null or not key.has("t") or not _is_vec3(key.get("position")) or not _is_vec3(key.get("target")):
			return "every camera key needs t, position [x,y,z] and target [x,y,z]"
		var fov := float(key.get("fov", 50.0))
		if fov <= 1.0 or fov >= 170.0:
			return "camera key fov must be between 1 and 170 degrees"
		keys.append({"t": float(key.t), "position": _vec3(key.position), "target": _vec3(key.target),
			"lens": log(tan(deg_to_rad(fov) * 0.5)), "follow": bool(key.get("follow", false))})
	if keys.size() < 2:
		return "the camera needs at least two keys"
	for i in range(1, keys.size()):
		if float(keys[i].t) <= float(keys[i - 1].t):
			return "camera keys must have increasing t"
	var chester: Variant = shot.get("chester")
	chester_on = chester is Dictionary
	if chester_on:
		var c := chester as Dictionary
		if not _is_vec2(c.get("at")):
			return "chester.at must be [x, z]"
		for raw: Variant in c.get("track", []):
			var entry := raw as Dictionary
			if entry == null or not entry.has("t"):
				return "every chester.track entry needs t"
			var move := str(entry.get("move", "idle"))
			if move not in MOVES:
				return "chester.track move must be one of %s" % [MOVES]
			var path: Array[Vector2] = []
			for point: Variant in entry.get("path", []):
				if not _is_vec2(point):
					return "chester.track path points must be [x, z]"
				path.append(Vector2(float(point[0]), float(point[1])))
			if move != "idle" and path.is_empty():
				return "a walk or run needs a path"
			track.append({"t": float(entry.t), "move": move, "path": path, "jetpack": bool(entry.get("jetpack", false))})
		for i in range(1, track.size()):
			if float(track[i].t) <= float(track[i - 1].t):
				return "chester.track entries must have increasing t"
	else:
		for key in keys:
			if key.follow:
				return "a camera key follows Chester, but the shot has no chester"
	if shot.has("sun") and not shot.sun is String:
		return "sun must be island time \"YYYY-MM-DD HH:MM\""
	return ""


func _set_sun() -> String:
	if not shot.has("sun") and DayClock.enabled() and DayClock.now() != DayClock.RECORDED_UNIX:
		DayClock.pin()
		harness.main.day_sun.follow(true)
	if shot.has("sun"):
		if not DayClock.enabled():
			return "the shot sets the sun, but the time of day is off: " + DayClock.off_reason()
		var unix := DayClock.parse_local(str(shot.sun))
		if is_nan(unix):
			return "sun must be island time \"YYYY-MM-DD HH:MM\", got " + str(shot.sun)
		DayClock.pin(unix)
		harness.main.day_sun.follow(true)
	print("SHOT_SUN ", DayClock.moment_text(DayClock.now()), " rotation=", sun.rotation_degrees, " energy=", sun.light_energy)
	return ""


func _place_chester() -> String:
	var avatar := harness.player.avatar_pivot
	if not chester_on:
		avatar.hide()
		return ""
	var c: Dictionary = shot.chester
	var at := Vector2(float(c.at[0]), float(c.at[1]))
	var settled := await harness.settle_player(at, {}, 0.3)
	if not settled.is_empty() or not harness.player.is_on_floor():
		return "Chester can't stand at %s: %s" % [at, settled]
	var facing: Variant = c.get("facing")
	if _is_vec2(facing):
		var face := Vector2(float(facing[0]), float(facing[1])) - at
		avatar.rotation.y = atan2(face.x, face.y)
	avatar.show()
	print("SHOT_CHESTER grounded at ", harness.player.global_position, " yaw=", rad_to_deg(avatar.rotation.y))
	return ""


## The Isle House capture's shadow setup: the sun's shadows reach the far
## plane, with cascades fitted to the shot's depth of interest each frame. Put
## on after the sun is set, which puts on its own shadow reach.
func _apply_shadows() -> void:
	sun.shadow_enabled = true
	sun.shadow_opacity = 1.0
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sun.directional_shadow_max_distance = FAR_M
	sun.directional_shadow_blend_splits = true
	sun.directional_shadow_fade_start = 0.92
	RenderingServer.directional_shadow_atlas_set_size(8192, false)
	RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)


func _make_capture_viewport() -> void:
	capture = SubViewport.new()
	capture.name = "TrailerCapture"
	capture.world_3d = root.world_3d
	capture.size = size
	capture.msaa_3d = Viewport.MSAA_4X
	capture.use_taa = true
	capture.anisotropic_filtering_level = Viewport.ANISOTROPY_16X
	capture.mesh_lod_threshold = 0.0
	capture.scaling_3d_scale = 1.0
	capture.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(capture)
	camera = Camera3D.new()
	camera.name = "TrailerCamera"
	camera.keep_aspect = Camera3D.KEEP_HEIGHT
	camera.environment = environment
	capture.add_child(camera)
	camera.make_current()
	# The grass and stones are generated round their viewport's camera: let them
	# follow this one (they are built not to pop as cells change).
	if harness.main.ground_dressing != null:
		harness.main.ground_dressing.reparent(capture)
	root.disable_3d = true
	var monitor := TextureRect.new()
	monitor.texture = capture.get_texture()
	monitor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	monitor.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	monitor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(monitor)
	monitor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	print("SHOT_QUALITY MSAA 4x, TAA, anisotropy 16x, lod threshold 0, shadow atlas 8192")


## Level of detail fixed at its nearest meshes for the whole shot, so nothing
## swaps or fades as the camera moves (the Isle House capture's _lock_world_detail).
func _lock_world_detail() -> void:
	var fixed_ranges := 0
	var hidden_lods := 0
	var materials := {}
	for node in harness.world.find_children("*", "GeometryInstance3D", true, false):
		var geometry := node as GeometryInstance3D
		# LOD0 starts at 0; alternates start further out and sit over it.
		if geometry.visibility_range_begin > 0.0:
			geometry.hide()
			hidden_lods += 1
			continue
		if geometry.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY \
		and (geometry.has_meta("context_kind") or geometry.get_meta("street_detail_layer", "") == "vegetation"):
			# Vegetation's distance shadow stands in for the full mesh, which casts.
			geometry.hide()
			continue
		if geometry.visibility_range_end > 0.0:
			geometry.visibility_range_end = 0.0
			geometry.visibility_range_end_margin = 0.0
			geometry.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
			fixed_ranges += 1
		var found: Array[Material] = [geometry.material_override]
		if geometry is MeshInstance3D and (geometry as MeshInstance3D).mesh != null:
			for i in (geometry as MeshInstance3D).mesh.get_surface_count():
				found.append((geometry as MeshInstance3D).get_active_material(i))
		elif geometry is MultiMeshInstance3D and (geometry as MultiMeshInstance3D).multimesh != null \
		and (geometry as MultiMeshInstance3D).multimesh.mesh != null:
			var mesh := (geometry as MultiMeshInstance3D).multimesh.mesh
			for i in mesh.get_surface_count():
				found.append(mesh.surface_get_material(i))
		for material in found:
			if material is ShaderMaterial and (material as ShaderMaterial).shader != null:
				materials[material] = true
	for material: ShaderMaterial in materials:
		match material.shader.resource_path:
			FOLIAGE:
				material.set_shader_parameter("distance_fade", false)
			RIPRAP:
				material.set_shader_parameter("stone_reach_min_m", 10000.0)
				material.set_shader_parameter("stone_reach_max_m", 10000.0)
				material.set_shader_parameter("stone_thin_start", 1.0)
				material.set_shader_parameter("underlay_fade_m", Vector2(10000.0, 11000.0))
	print("SHOT_FIXED_DETAIL ranges=", fixed_ranges, " alternate_meshes=", hidden_lods)


## Draws the shot. Frame i is shot time i / fps - handle; the usable part is
## 0..duration, with handle seconds of the same motion either side.
func _record() -> bool:
	var first_tick := -roundi(handle_s * fps)
	var sim_start := first_tick - roundi(DEFAULT_PREROLL_S * fps)
	if not track.is_empty():
		sim_start = mini(sim_start, floori(float(track[0].t) * fps))
	var proofs := _still_frames()
	var raw: FileAccess = null
	if not stills:
		raw = FileAccess.open(out_dir.path_join("frames.rgb"), FileAccess.WRITE)
		if raw == null:
			_fail("cannot write frames.rgb")
			return false
	# Settle: hold the first pose while pipelines compile and the sky redraws.
	_pose(-handle_s - float(STILL_WARM_FRAMES) / fps)
	for _i in SETTLE_FRAMES:
		await process_frame
		await RenderingServer.frame_post_draw
	if chester_on:
		harness.player.set_gameplay_enabled(true)
		harness.player.camera_rig.set_input_enabled(false)
	last_physics_frame = -1
	print("SHOT_START frames=%d (%.2f s usable + %.2f s handles at %d fps), pre-roll from t=%.2f s, %s" % [
		frame_count, duration_s, handle_s, fps, float(sim_start) / fps, "stills" if stills else "full"])
	for tick in range(sim_start, frame_count + first_tick):
		var t := float(tick) / fps
		var frame := tick - first_tick
		_drive_chester(t)
		var draw := not stills
		if stills:
			for proof: int in proofs:
				if frame <= proof and frame > proof - STILL_WARM_FRAMES:
					draw = true
		capture.render_target_update_mode = SubViewport.UPDATE_ALWAYS if draw or frame < 0 else SubViewport.UPDATE_DISABLED
		await process_frame
		var clock := _check_clock()
		if not clock.is_empty():
			_fail(clock)
			return false
		# The camera holds still until shortly before the first frame, then runs
		# its real path for TAA's history (extrapolating a fast move far back
		# could send it through anything).
		_pose(maxf(t, -handle_s - float(STILL_WARM_FRAMES) / fps))
		if frame >= 0 and not _camera_clear(frame):
			return false
		await RenderingServer.frame_post_draw
		if frame < 0:
			continue
		if stills:
			if frame in proofs:
				var image := _read_frame()
				if image == null or image.save_png(out_dir.path_join("frame-%04d.png" % frame)) != OK:
					_fail("cannot save still %d" % frame)
					return false
				print("SHOT_STILL frame=%d t=%.3f camera=%s chester=%s" % [frame, t, camera.global_position, harness.player.global_position])
			continue
		var pixels := _read_frame()
		if pixels == null:
			_fail("cannot read frame %d" % frame)
			return false
		pixels.convert(Image.FORMAT_RGB8)
		raw.store_buffer(pixels.get_data())
		if raw.get_error() != OK:
			_fail("cannot write frame %d" % frame)
			return false
		if frame % fps == 0:
			print("SHOT_FRAME %d / %d camera=%s chester=%s velocity=%s" % [frame, frame_count, camera.global_position, harness.player.global_position, harness.player.velocity])
	if raw != null:
		raw.close()
	harness.release_input()
	return true


## First, middle and last usable frames, both handle edges, and a 10 fps run
## across each cut point, for --stills.
func _still_frames() -> Array[int]:
	var first := roundi(handle_s * fps)
	var last := frame_count - 1 - first
	var picked: Array[int] = [0, first, (first + last) / 2, last, frame_count - 1]
	for edge: int in [first, last]:
		for step in range(-3, 4):
			picked.append(clampi(edge + step * (fps / 10), 0, frame_count - 1))
	var unique: Array[int] = []
	for frame in picked:
		if frame not in unique:
			unique.append(frame)
	unique.sort()
	return unique


## Every loop step must be exactly one unpaused frame of 1/fps s: the same
## number of physics ticks each frame (2 at 30 fps with 60 physics ticks).
func _check_clock() -> String:
	if paused:
		return "the game paused during the capture"
	var physics := Engine.get_physics_frames()
	if last_physics_frame >= 0 and physics != last_physics_frame + ticks_per_frame:
		return "frame step ran %d physics ticks, not %d (run with --fixed-fps %d)" % [physics - last_physics_frame, ticks_per_frame, fps]
	last_physics_frame = physics
	if not is_equal_approx(root.get_process_delta_time(), 1.0 / fps):
		return "frame step was %.5f s, not 1/%d (run with --fixed-fps %d)" % [root.get_process_delta_time(), fps, fps]
	return ""


## Holds Chester's stock input actions for the tick about to run.
func _drive_chester(t: float) -> void:
	if not chester_on:
		return
	var active := -1
	for i in track.size():
		if t >= float(track[i].t):
			active = i
	if active < 0:
		harness.release_input()
		return
	var entry: Dictionary = track[active]
	var here := Vector2(harness.player.global_position.x, harness.player.global_position.z)
	if active != path_entry:
		# A new step's path starts where Chester is when it begins.
		path_entry = active
		path_progress = 0.0
		active_path = [here]
		active_path.append_array(entry.path)
	_hold("jetpack", bool(entry.jetpack))
	var move: String = entry.move
	if move == "idle":
		_hold("move_forward", false)
		_hold("run", false)
		return
	# Steer at a point a little ahead along the path, from the player's own
	# position: corners round off and the walk keeps its stock speed.
	var path := active_path
	path_progress = maxf(path_progress, _project(path, here))
	if _path_length(path) - path_progress < 0.15:
		_hold("move_forward", false)
		_hold("run", false)
		return
	var aim := _point_at(path, path_progress + 1.5) - here
	if aim.length() < 0.001:
		return
	harness.player.camera_rig.rotation = Vector3(0.0, atan2(-aim.x, -aim.y), 0.0)
	_hold("move_forward", true)
	_hold("run", move == "run")


func _hold(action: StringName, on: bool) -> void:
	if on and not Input.is_action_pressed(action):
		Input.action_press(action)
	elif not on and Input.is_action_pressed(action):
		Input.action_release(action)


static func _path_length(path: Array[Vector2]) -> float:
	var total := 0.0
	for i in range(1, path.size()):
		total += path[i - 1].distance_to(path[i])
	return total


static func _point_at(path: Array[Vector2], distance: float) -> Vector2:
	var walked := 0.0
	for i in range(1, path.size()):
		var length := path[i - 1].distance_to(path[i])
		if walked + length >= distance:
			return path[i - 1].lerp(path[i], (distance - walked) / maxf(length, 0.0001))
		walked += length
	var end := path[path.size() - 1]
	var before := path[path.size() - 2]
	return end + (end - before).normalized() * (distance - walked)


static func _project(path: Array[Vector2], point: Vector2) -> float:
	var best := INF
	var best_distance := 0.0
	var walked := 0.0
	for i in range(1, path.size()):
		var a := path[i - 1]
		var b := path[i]
		var ab := b - a
		var s := clampf((point - a).dot(ab) / maxf(ab.length_squared(), 0.0001), 0.0, 1.0)
		var d := point.distance_to(a + ab * s)
		if d < best:
			best = d
			best_distance = walked + ab.length() * s
		walked += ab.length()
	return best_distance


## The camera at shot time t: a cubic Hermite spline through the keys with
## time-weighted Catmull-Rom tangents (C1, so no velocity jumps at keys), and the
## same velocity carried straight on before the first key and after the last.
## A follow key's position and target are offsets from Chester's feet now.
func _pose(t: float) -> void:
	var chester := harness.player.global_position if chester_on else Vector3.ZERO
	var positions: Array = []
	var targets: Array = []
	var lenses: Array = []
	for key in keys:
		var base: Vector3 = chester if key.follow else Vector3.ZERO
		positions.append(base + key.position)
		targets.append(base + key.target)
		lenses.append(Vector3(key.lens, 0.0, 0.0))
	var position := _spline(positions, t)
	var target := _spline(targets, t)
	var lens := _spline(lenses, t).x
	var direction := position.direction_to(target)
	if absf(direction.y) > 0.999:
		direction = (direction + Vector3(0.0, 0.0, -0.002)).normalized()
	camera.set_perspective(2.0 * rad_to_deg(atan(exp(lens))), float(shot.camera.get("near", 0.2)), FAR_M)
	camera.global_position = position
	camera.look_at(position + direction, Vector3.UP)
	_fit_shadow_cascades(position.distance_to(target))
	environment.fog_density = stock_fog_density * minf(1.0, 650.0 / maxf(position.y, 1.0))


func _spline(values: Array, t: float) -> Vector3:
	var n := keys.size()
	if t <= float(keys[0].t):
		return values[0] + _tangent(values, 0) * (t - float(keys[0].t))
	if t >= float(keys[n - 1].t):
		return values[n - 1] + _tangent(values, n - 1) * (t - float(keys[n - 1].t))
	var i := 0
	while t > float(keys[i + 1].t):
		i += 1
	var h := float(keys[i + 1].t) - float(keys[i].t)
	var s := (t - float(keys[i].t)) / h
	var s2 := s * s
	var s3 := s2 * s
	return (2.0 * s3 - 3.0 * s2 + 1.0) * values[i] + (s3 - 2.0 * s2 + s) * h * _tangent(values, i) \
		+ (-2.0 * s3 + 3.0 * s2) * values[i + 1] + (s3 - s2) * h * _tangent(values, i + 1)


## Velocity at key i: the time-weighted mean of the neighbouring chords (a
## non-uniform Catmull-Rom tangent); at either end, the end chord's.
func _tangent(values: Array, i: int) -> Vector3:
	var n := keys.size()
	if i == 0:
		return (values[1] - values[0]) / (float(keys[1].t) - float(keys[0].t))
	if i == n - 1:
		return (values[n - 1] - values[n - 2]) / (float(keys[n - 1].t) - float(keys[n - 2].t))
	var before := float(keys[i].t) - float(keys[i - 1].t)
	var after := float(keys[i + 1].t) - float(keys[i].t)
	var into: Vector3 = (values[i] - values[i - 1]) / before
	var out: Vector3 = (values[i + 1] - values[i]) / after
	return (into * after + out * before) / (before + after)


func _fit_shadow_cascades(focus_depth: float) -> void:
	var near := camera.near
	var span := FAR_M - near
	var first_end := maxf(40.0, focus_depth * 1.5 + 20.0)
	var second_end := maxf(250.0, focus_depth * 3.0 + 100.0)
	var third_end := maxf(1500.0, focus_depth * 6.0 + 500.0)
	sun.directional_shadow_split_1 = minf((first_end - near) / span, 0.78)
	sun.directional_shadow_split_2 = minf((second_end - near) / span, 0.86)
	sun.directional_shadow_split_3 = minf((third_end - near) / span, 0.93)


## Fails the shot when the camera is inside or passes through something solid
## near the ground, and counts frames where Chester is hidden from it.
func _camera_clear(frame: int) -> bool:
	var at := camera.global_position
	if at.y < CLEARANCE_CHECK_BELOW_M:
		var space := harness.player.get_world_3d().direct_space_state
		var sphere := SphereShape3D.new()
		sphere.radius = CAMERA_CLEARANCE_M
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = sphere
		query.collision_mask = harness.player.collision_mask
		query.exclude = [harness.player.get_rid()]
		query.transform = Transform3D(Basis.IDENTITY, at)
		var inside := space.intersect_shape(query, 1)
		if not inside.is_empty():
			_fail("the camera is inside %s at frame %d (%s)" % [_describe(inside[0].collider), frame, at])
			return false
		if last_camera.is_finite() and last_camera.y < CLEARANCE_CHECK_BELOW_M:
			query.transform = Transform3D(Basis.IDENTITY, last_camera)
			query.motion = at - last_camera
			var fraction: float = space.cast_motion(query)[1]
			if fraction < 1.0:
				query.transform = Transform3D(Basis.IDENTITY, last_camera + query.motion * fraction)
				query.motion = Vector3.ZERO
				var hit := space.get_rest_info(query)
				_fail("the camera passes through %s before frame %d (at %s)" % [_describe(hit.get("collider_id", 0)), frame, query.transform.origin])
				return false
	if last_camera.is_finite():
		var speed := last_camera.distance_to(at) * fps
		if last_speed >= 0.0 and frame > 0:
			worst_speed_change = maxf(worst_speed_change, absf(speed - last_speed) / maxf(maxf(speed, last_speed), 0.05))
		last_speed = speed
	last_camera = at
	if chester_on and frame >= 0 and harness.player.avatar_pivot.visible:
		var chest := harness.player.global_position + Vector3.UP * 0.6
		if not harness.ray(at, chest, harness.player.collision_mask).is_empty():
			obstructed_frames += 1
	return true


## A collider for a failure message: its node path and derived object key.
func _describe(collider: Variant) -> String:
	var node: Object = collider if collider is Object else instance_from_id(int(collider))
	if node is Node:
		return "%s (%s)" % [(node as Node).get_path(), (node as Node).get_meta("derived_object_key", "")]
	return "something solid"


func _read_frame() -> Image:
	var pixels := capture.get_texture().get_image()
	if pixels == null or pixels.is_empty() or pixels.get_size() != size:
		return null
	return pixels


static func _is_vec3(value: Variant) -> bool:
	return _is_numbers(value, 3)


static func _is_vec2(value: Variant) -> bool:
	return _is_numbers(value, 2)


static func _is_numbers(value: Variant, count: int) -> bool:
	if not value is Array or (value as Array).size() != count:
		return false
	for v: Variant in value:
		if not (v is float or v is int):
			return false
	return true


static func _vec3(value: Array) -> Vector3:
	return Vector3(float(value[0]), float(value[1]), float(value[2]))


## A shot that can't be rendered. With --stills the other shots go on (the run
## still ends with a failure); otherwise the run stops here.
func _fail(message: String) -> void:
	failed_shots.append(str(shot.get("name", "")))
	if not stills:
		_stop("%s: %s" % [shot.get("name", ""), message])
		return
	push_error("SHOT_FAILED %s: %s" % [shot.get("name", ""), message])


func _stop(message: String) -> void:
	push_error("SHOT_FAILED " + message)
	quit(1)
