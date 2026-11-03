extends SceneTree
## Screenshots for the visual reviewer, taken in the real loaded island.
##
##   tools/godot --path . --resolution 1600x900 --script game/tests/shared/building_shots.gd -- --source w291189336 --out /tmp/shots
##   tools/godot --path . --resolution 1600x900 --script game/tests/shared/building_shots.gd -- --island --out /tmp/shots
##
## --source KEY: four gameplay-camera views of the building from around it
##   (closeup-*.png) and two raised views showing it in its surroundings (context-*.png).
## --island: fixed overview views of the whole island (island-*.png), the same
##   every run, so before/after shots of a change compare directly.
## --overhead "center_x,center_z,width,depth": orthographic world -Z-up site view.
## Pass the flag and comma-separated value as separate arguments.
## Options can be combined. Needs a GPU display; tools/godot provides one.
## --views FILE adds source-bound focused gameplay views without replacing these
## defaults: {"source": "KEY", "views": [{"name": "entrance",
## "player_xz": [x,z], "target_xyz": [x,y,z]}]}. A view may add "camera_xyz": [x,y,z]
## and "fov": degrees (vertical, default 70) to shoot from a free camera at that
## position aimed at the target, e.g. to match a reference photo's height, tilt and
## field of view, or "projection": "ortho" with "ortho_size": metres (vertical
## extent) for a square-on elevation. The player still settles at player_xz.
## The player's avatar mesh is hidden in every shot (visual only); --show-player keeps it.
## --street-views FILE: views of a street-detail area, not bound to a building:
##   {"area": "NAME", "views": [{"name": "...", "player_xz": [x,z], "target_xyz": [x,y,z]}]}
##   with the same optional camera_xyz, fov, projection and ortho_size as --views.
##   Saved as street-NAME.png; taken with street detail on and off by default.
##   A street view may add "moves": [{"hold": ["move_forward", "run"], "ticks": 60,
##   "turn_deg": 0}, ...] to drive the stock player with its real input actions
##   from where it settled, facing the target (turn_deg turns the camera, and so
##   the walk, over that step), saving a frame every "every" physics ticks
##   (default 2) as street-NAME-000.png, ... Run with --fixed-fps 60 so the frames
##   are evenly spaced in game time. A free camera (camera_xyz) follows the player,
##   keeping its offset and looking at the player. Each tick prints a MOVE_TICK
##   line, with the avatar's describe() when it has one.
##   A still view (focused or street) may add "frame_time_frames": N (10-3000) to
##   hold its camera for N more frames with vsync and the frame cap off and print
##   their frame time as a FRAME_TIME line (pass --rendering-method
##   gl_compatibility --rendering-driver opengl3 for the web renderer).
## --views-batch FILE: only the focused views of several buildings in one world load,
## [{"source": "KEY", "plan": "views.json"}, ...], each plan a --views file for its
## source, saved to OUT/KEY/detail-NAME.png. Fixed-pose views only (no closeup,
## context or overhead shots; --island may be added); any bad entry fails the run.
## --neutral-lighting: screenshots only. Switches the environment, sky and sun back
##   to the neutral pre-2026-10-23 daylight (NEUTRAL_LIGHTING) for colour matching
##   against reference photos. Gameplay always uses main.tscn's warm daylight.
## --street-detail off|on|both: street detail (vegetation, furniture, fences, clutter)
##   in every shot. Without it, close-ups and focused views are taken with street
##   detail off, and context, island and overhead views both ways. A view taken
##   both ways is saved as NAME-street-on.png and NAME-street-off.png, otherwise
##   as NAME.png. One world load: the on views first, then street detail is freed.

const WorldHarness := preload("res://game/tests/shared/world_harness.gd")

## Street-detail states per kind of shot when --street-detail is not given.
const DEFAULT_STREET_DETAIL := {
	"closeup": ["off"],
	"focused": ["off"],
	"street": ["on", "off"],
	"context": ["on", "off"],
	"island": ["on", "off"],
	"overhead": ["on", "off"],
}

## Input actions a street view's moves may hold.
const MOVE_ACTIONS := ["move_forward", "move_back", "move_left", "move_right", "run", "jetpack"]

## The neutral daylight in main.tscn before the 2026-10-23 warm-light change,
## restored by --neutral-lighting as [target, property, value].
const NEUTRAL_LIGHTING := [
	["environment", "ambient_light_color", Color(0.64, 0.60, 0.53)],
	["environment", "ambient_light_energy", 0.75],
	["environment", "ambient_light_sky_contribution", 0.45],
	["environment", "fog_light_color", Color(0.72, 0.80, 0.88)],
	["environment", "fog_density", 0.00012],
	["environment", "fog_aerial_perspective", 0.0],
	["sky", "sky_top_color", Color(0.24, 0.44, 0.78)],
	["sky", "sky_horizon_color", Color(0.72, 0.80, 0.88)],
	["sky", "sky_curve", 0.09],
	["sun", "light_color", Color(1.0, 0.97, 0.92)],
]

var _h: WorldHarness
var _errors: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := WorldHarness.user_args()
	var out := str(args.get("out", ""))
	if out == "" or (not args.has("source") and not args.has("island") and not args.has("overhead") and not args.has("views-batch") and not args.has("street-views")):
		_fail("usage: -- [--source KEY] [--street-views FILE] [--island] [--overhead center_x,center_z,width,depth] --out DIR")
		return
	var batch: Array[Dictionary] = []
	if args.has("views-batch"):
		batch = _batch_entries(args["views-batch"])
		if batch.is_empty() or args.has("source") or args.has("views") or args.has("overhead") or args.has("street-views"):
			_fail("--views-batch needs a nonempty list of unique {source, plan} entries and no shot option other than --island")
			return
	var street := DEFAULT_STREET_DETAIL.duplicate(true)
	if args.has("street-detail"):
		var choice := str(args["street-detail"])
		if choice not in ["off", "on", "both"]:
			_fail("--street-detail takes off, on or both")
			return
		for kind: String in street.keys():
			street[kind] = ["on", "off"] if choice == "both" else [choice]
	var kinds: Array[String] = []
	if args.has("source"):
		kinds.append("closeup")
		kinds.append("context")
	if args.has("views") or not batch.is_empty():
		kinds.append("focused")
	if args.has("street-views"):
		kinds.append("street")
	if args.has("island"):
		kinds.append("island")
	if args.has("overhead"):
		kinds.append("overhead")
	var passes: Array[String] = []
	var plan: Array[String] = []
	for kind in kinds:
		plan.append("%s=%s" % [kind, "+".join(PackedStringArray(street[kind]))])
	for state: String in ["on", "off"]:
		for kind in kinds:
			if state in street[kind] and state not in passes:
				passes.append(state)
	print("STREET_DETAIL_SHOTS " + " ".join(PackedStringArray(plan)))
	DirAccess.make_dir_recursive_absolute(out)
	_h = WorldHarness.new(self)
	# Load with every layer on when any view wants it; the off views come after.
	var error := await _h.load_world(WorldLoader.STREET_DETAIL_LAYERS.duplicate() if "on" in passes else [])
	if error != "":
		_fail(error)
		return
	print("RENDERER: %s / %s" % [RenderingServer.get_video_adapter_name(), DisplayServer.get_name()])
	if args.has("neutral-lighting"):
		await _use_neutral_lighting()
	if not args.has("show-player"):
		(_h.player.get_node("AvatarPivot") as Node3D).visible = false
	for state in passes:
		if state == "off" and not _h.world.get_street_detail_layers().is_empty():
			var switched := _h.world.apply_street_detail([])
			if not switched.ok:
				_errors.append(str(switched.message))
				break
		var problems := _h.street_detail_problems()
		if not problems.is_empty():
			_errors.append_array(problems)
			break
		print("STREET_DETAIL_PASS state=%s %s" % [state, _h.street_detail_summary()])
		if args.has("source") and state in street.closeup:
			await _closeup_shots(str(args.source), out, _suffix(street.closeup, state))
		if args.has("source") and state in street.context:
			await _context_shots(str(args.source), out, _suffix(street.context, state))
		if args.has("views") and state in street.focused:
			await _focused_views(str(args.get("source", "")), str(args.views), out, _suffix(street.focused, state))
		if args.has("street-views") and state in street.street:
			await _street_views(str(args["street-views"]), out, _suffix(street.street, state))
		if args.has("island") and state in street.island:
			await _island_shots(out, _suffix(street.island, state))
		if args.has("overhead") and state in street.overhead:
			await _overhead_shot(str(args.overhead), out, _suffix(street.overhead, state))
		if state in street.focused:
			for entry: Dictionary in batch:
				var folder := out.path_join(entry.source)
				DirAccess.make_dir_recursive_absolute(folder)
				await _focused_views(entry.source, entry.plan, folder, _suffix(street.focused, state))
				if not _errors.is_empty():
					break
		if not _errors.is_empty():
			break
	if _errors.is_empty():
		print("PASS: screenshots in %s" % out)
	else:
		for message in _errors:
			push_error(message)
	_h.main.queue_free()
	quit(0 if _errors.is_empty() else 1)


## "" when a kind of view is taken in one street-detail state, else -street-on/-off.
func _suffix(states: Array, state: String) -> String:
	return "" if states.size() == 1 else "-street-" + state


## Screenshot-only: the neutral daylight for colour matching. Waits for the sky
## radiance map to update before any capture.
func _use_neutral_lighting() -> void:
	var environment := (_h.main.get_node("WorldEnvironment") as WorldEnvironment).environment
	var targets := {"environment": environment, "sky": environment.sky.sky_material, "sun": _h.main.get_node("Sun")}
	for entry: Array in NEUTRAL_LIGHTING:
		(targets[entry[0]] as Object).set(entry[1] as String, entry[2])
	for _i in 30:
		await process_frame
	await RenderingServer.frame_post_draw
	print("LIGHTING: neutral (pre-2026-10-23 daylight, screenshots only)")


func _focused_views(source: String, path: String, out: String, suffix: String) -> void:
	var plan: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not plan is Dictionary or source == "" or plan.get("source", "") != source or not plan.get("views") is Array or plan.views.is_empty():
		_errors.append("focused views need a nonempty view list bound to --source")
		return
	var meshes := _h.visual_meshes(_h.building_nodes(source))
	if meshes.is_empty():
		_errors.append("focused views have no source geometry")
		return
	var bounds := _h.bounds(meshes).grow(1.0)
	var names := {}
	for view: Variant in plan.views:
		if not view is Dictionary or not view.get("name") is String or not _numbers(view.get("player_xz"), 2) or not _numbers(view.get("target_xyz"), 3):
			_errors.append("focused view needs name, player_xz and target_xyz")
			return
		var name: String = view.name
		if name == "" or name.validate_filename() != name or names.has(name):
			_errors.append("focused view names must be unique safe filenames")
			return
		names[name] = true
		var target := Vector3(view.target_xyz[0], view.target_xyz[1], view.target_xyz[2])
		if not bounds.has_point(target):
			_errors.append("focused view target lies outside the source building: " + name)
			return
		var error := await _shoot_view(view, target, "%s/detail-%s%s.png" % [out, name, suffix])
		if error != "":
			_errors.append("focused view " + name + ": " + error)
			return
		print("FOCUSED_VIEW %s source=%s player=%s target=%s camera=%s" % [name, source, _h.player.global_position, target, view.get("camera_xyz", "gameplay")])


## Views of a street-detail area, not bound to a building (--street-views).
func _street_views(path: String, out: String, suffix: String) -> void:
	var plan: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not plan is Dictionary or not plan.get("area") is String or str(plan.area) == "" or str(plan.area).validate_filename() != str(plan.area) \
	or not plan.get("views") is Array or plan.views.is_empty():
		_errors.append("street views need a safe area name and a nonempty view list")
		return
	var names := {}
	for view: Variant in plan.views:
		if not view is Dictionary or not view.get("name") is String or not _numbers(view.get("player_xz"), 2) or not _numbers(view.get("target_xyz"), 3):
			_errors.append("street view needs name, player_xz and target_xyz")
			return
		var name: String = view.name
		if name == "" or name.validate_filename() != name or names.has(name):
			_errors.append("street view names must be unique safe filenames")
			return
		names[name] = true
		var target := Vector3(view.target_xyz[0], view.target_xyz[1], view.target_xyz[2])
		var error := ""
		if view.has("moves"):
			error = await _moving_view(view, target, "%s/street-%s%s" % [out, name, suffix])
		else:
			error = await _shoot_view(view, target, "%s/street-%s%s.png" % [out, name, suffix])
		if error != "":
			_errors.append("street view " + name + ": " + error)
			return
		var camera_note: Variant = view.get("camera_xyz", "gameplay")
		if not view.has("camera_xyz"):
			# How far the gameplay camera stands from its arm's origin, against the full arm.
			var arm := _h.player.get_node("CameraPivot/SpringArm3D") as SpringArm3D
			camera_note = "gameplay arm_m=%.2f of %.2f" % [arm.global_position.distance_to(_h.player.get_camera().global_position), arm.spring_length]
		print("STREET_VIEW %s area=%s player=%s on_floor=%s target=%s camera=%s" % [name, plan.area, _h.player.global_position, _h.player.is_on_floor(), target, camera_note])


## Settles the player at the view's player_xz and saves one screenshot from the
## gameplay camera aimed at target, or from a free camera at camera_xyz. Returns
## an error message, or "".
func _shoot_view(view: Dictionary, target: Vector3, path: String) -> String:
	var camera_error := _free_camera_error(view, target)
	if camera_error != "":
		return camera_error
	var error := await _h.settle_player(Vector2(view.player_xz[0], view.player_xz[1]))
	if error != "":
		return error
	var free := _free_camera(view, target)
	if free == null:
		_h.aim_camera(target)
	await physics_frame
	await physics_frame
	error = await _h.save_screenshot(path)
	if error == "" and view.has("frame_time_frames"):
		error = await _frame_time(view.frame_time_frames, path.get_file().get_basename())
	if free != null:
		free.queue_free()
		_h.player.get_camera().make_current()
	return error


## Holds the view's camera for `frames` more drawn frames, with vsync and the
## frame cap off, and prints the wall time between them as a FRAME_TIME line
## (mean, median, 95th percentile and the mean's fps). Returns an error, or "".
func _frame_time(frames: Variant, label: String) -> String:
	if not _numbers([frames], 1) or float(frames) != floorf(float(frames)) or float(frames) < 10.0 or float(frames) > 3000.0:
		return "frame_time_frames must be a whole number from 10 to 3000"
	var vsync := DisplayServer.window_get_vsync_mode()
	var max_fps := Engine.max_fps
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	# Let the change and any first-use work settle before timing.
	for _i in 30:
		await RenderingServer.frame_post_draw
	var times := PackedFloat64Array()
	var last := Time.get_ticks_usec()
	for _i in int(frames):
		await RenderingServer.frame_post_draw
		var now := Time.get_ticks_usec()
		times.append(float(now - last) / 1000.0)
		last = now
	DisplayServer.window_set_vsync_mode(vsync)
	Engine.max_fps = max_fps
	times.sort()
	var total := 0.0
	for time in times:
		total += time
	var mean := total / float(times.size())
	print("FRAME_TIME %s frames=%d mean_ms=%.2f median_ms=%.2f p95_ms=%.2f mean_fps=%.1f method=%s adapter=%s" % [
		label, times.size(), mean, times[times.size() / 2], times[mini(times.size() - 1, int(times.size() * 0.95))],
		1000.0 / mean, RenderingServer.get_current_rendering_method(), RenderingServer.get_video_adapter_name(),
	])
	return ""


## The view's free camera at camera_xyz aimed at target, made current, or null
## when the view has none.
func _free_camera(view: Dictionary, target: Vector3) -> Camera3D:
	if not view.has("camera_xyz"):
		return null
	var free := Camera3D.new()
	if view.get("projection", "perspective") == "ortho":
		free.projection = Camera3D.PROJECTION_ORTHOGONAL
		free.size = float(view.ortho_size)
	else:
		free.fov = float(view.get("fov", 70.0))
	free.far = 5000.0
	_h.main.add_child(free)
	free.global_position = Vector3(view.camera_xyz[0], view.camera_xyz[1], view.camera_xyz[2])
	free.look_at(target, Vector3.UP)
	free.make_current()
	return free


## Settles the player at the view's player_xz, faces the gameplay camera to the
## target, then drives the stock player through the view's moves with its real
## input actions, saving a frame every `every` physics ticks as PREFIX-000.png,
## PREFIX-001.png, ... A free camera keeps its offset from the player and looks
## at the player's capsule. Prints one MOVE_TICK line per tick, after its
## physics. Returns an error message, or "".
func _moving_view(view: Dictionary, target: Vector3, prefix: String) -> String:
	var every: Variant = view.get("every", 2)
	if not view.moves is Array or view.moves.is_empty() or not _numbers([every], 1) or float(every) != floorf(float(every)) or float(every) < 1.0:
		return "moves need a nonempty list of steps and a whole positive every"
	for step: Variant in view.moves:
		if not step is Dictionary or not step.get("hold") is Array or not _numbers([step.get("ticks")], 1) \
		or float(step.ticks) != floorf(float(step.ticks)) or float(step.ticks) < 1.0 \
		or (step.has("turn_deg") and not _numbers([step.get("turn_deg")], 1)):
			return "each move needs hold (a list of actions), whole positive ticks and an optional numeric turn_deg"
		for action: Variant in step.hold:
			if not action in MOVE_ACTIONS:
				return "moves may hold only " + ", ".join(PackedStringArray(MOVE_ACTIONS))
	var camera_error := _free_camera_error(view, target)
	if camera_error != "":
		return camera_error
	var error := await _h.settle_player(Vector2(view.player_xz[0], view.player_xz[1]))
	if error != "":
		return error
	var player := _h.player
	var capsule := player.get_node("CollisionShape3D") as Node3D
	var free := _free_camera(view, target)
	var camera_offset := free.global_position - player.global_position if free != null else Vector3.ZERO
	_h.aim_camera(target)
	var rig := player.get_node("CameraPivot") as Node3D
	var pivot := player.get_node("AvatarPivot") as Node3D
	var avatar: Node = pivot.get_child(0) if pivot.get_child_count() > 0 else null
	_h.clean_hud()
	player.set_gameplay_enabled(true)
	var tick := 0
	var frame := 0
	for step: Dictionary in view.moves:
		for action: String in step.hold:
			Input.action_press(action)
		var turn := deg_to_rad(float(step.get("turn_deg", 0.0))) / float(step.ticks)
		for _i in int(step.ticks):
			rig.rotation.y += turn
			await physics_frame
			# Resume after this tick's physics has moved the player.
			await process_frame
			var saved := "-"
			if tick % int(every) == 0:
				if free != null:
					free.global_position = player.global_position + camera_offset
					free.look_at(capsule.global_position, Vector3.UP)
				_h.clean_hud()
				await RenderingServer.frame_post_draw
				var path := "%s-%03d.png" % [prefix, frame]
				if root.get_texture().get_image().save_png(path) != OK:
					error = "could not save " + path
					break
				saved = path.get_file()
				frame += 1
			var velocity := player.get_real_velocity()
			var state: Variant = _plain(avatar.describe()) if avatar != null and avatar.has_method("describe") else null
			print("MOVE_TICK %s tick=%d frame=%s pos=%s speed=%.3f floor=%s held=%s avatar=%s" % [prefix.get_file(), tick, saved, player.global_position, Vector2(velocity.x, velocity.z).length(), player.is_on_floor(), ",".join(PackedStringArray(step.hold)), JSON.stringify(state)])
			tick += 1
		_h.release_input()
		if error != "":
			break
	player.set_gameplay_enabled(false)
	if free != null:
		free.queue_free()
		player.get_camera().make_current()
	return error


## Vectors as plain number lists, so a describe() dictionary prints as JSON.
static func _plain(value: Variant) -> Variant:
	if value is Vector3:
		return [value.x, value.y, value.z]
	if value is Array:
		return value.map(func(item: Variant) -> Variant: return _plain(item))
	if value is Dictionary:
		var plain := {}
		for key: Variant in value:
			plain[key] = _plain(value[key])
		return plain
	return value


## Why a view's free-camera fields are unusable, or "" (also when it has none).
func _free_camera_error(view: Dictionary, target: Vector3) -> String:
	if not view.has("camera_xyz"):
		for key in ["projection", "fov", "ortho_size"]:
			if view.has(key):
				return key + " needs camera_xyz"
		return ""
	if not _numbers(view.get("camera_xyz"), 3):
		return "camera_xyz needs three numbers"
	var projection: Variant = view.get("projection", "perspective")
	if not projection is String or not projection in ["perspective", "ortho"]:
		return "projection must be \"perspective\" or \"ortho\""
	if view.has("fov") and (not _numbers([view.get("fov")], 1) or float(view.fov) <= 0.0 or float(view.fov) >= 180.0):
		return "fov must be a number of degrees between 0 and 180"
	if projection == "ortho" and (not _numbers([view.get("ortho_size")], 1) or float(view.ortho_size) <= 0.0):
		return "ortho needs a positive ortho_size"
	var direction := target - Vector3(view.camera_xyz[0], view.camera_xyz[1], view.camera_xyz[2])
	if direction.length() < 0.01 or absf(direction.normalized().dot(Vector3.UP)) > 0.999:
		return "camera_xyz must not coincide with or lie straight above or below the target"
	return ""


## The --views-batch list, or empty when it is not a nonempty list of unique,
## filename-safe sources each paired with a plan path.
func _batch_entries(path: Variant) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	if not path is String:
		return entries
	var list: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not list is Array:
		return entries
	var seen := {}
	for entry: Variant in list:
		if not entry is Dictionary or not entry.get("source") is String or not entry.get("plan") is String:
			return [] as Array[Dictionary]
		var source: String = entry.source
		if source == "" or source.validate_filename() != source or seen.has(source) or str(entry.plan) == "":
			return [] as Array[Dictionary]
		seen[source] = true
		entries.append({"source": source, "plan": str(entry.plan)})
	return entries


func _numbers(value: Variant, size: int) -> bool:
	if not value is Array or value.size() != size:
		return false
	for number: Variant in value:
		if not (number is float or number is int) or not is_finite(float(number)):
			return false
	return true


## The building's visible bounds and the shot framing derived from them, or {}.
func _building_frame(source_key: String) -> Dictionary:
	var nodes := _h.building_nodes(source_key)
	var meshes := _h.visual_meshes(nodes)
	if meshes.is_empty():
		_errors.append("no visible geometry found for building %s" % source_key)
		return {}
	var box := _h.bounds(meshes)
	var center := box.get_center()
	return {
		"box": box,
		"center": center,
		"own": _h.collision_rids(nodes),
		"radius": maxf(Vector2(box.size.x, box.size.z).length() * 0.5 + 10.0, 15.0),
		"target": Vector3(center.x, box.position.y + box.size.y * 0.4, center.z),
	}


func _closeup_shots(source_key: String, out: String, suffix: String) -> void:
	var frame := _building_frame(source_key)
	if frame.is_empty():
		return
	var center: Vector3 = frame.center
	var own: Array[RID] = frame.own
	var radius: float = frame.radius
	var target: Vector3 = frame.target
	# Gameplay-camera views from the four sides, trying nearby spots when a
	# side is blocked (water, another building, outside the boundary).
	for side in ["north", "east", "south", "west"]:
		var base_angle: float = {"north": -PI / 2.0, "east": 0.0, "south": PI / 2.0, "west": PI}[side]
		var taken := false
		for attempt in [[0.0, 1.0], [0.35, 1.0], [-0.35, 1.0], [0.0, 1.4], [0.0, 0.75], [0.7, 1.2], [-0.7, 1.2]]:
			var angle := base_angle + float(attempt[0])
			var spot := Vector2(center.x, center.z) + Vector2(cos(angle), sin(angle)) * radius * float(attempt[1])
			if await _h.settle_player(spot) != "":
				continue
			_h.aim_camera(target)
			await physics_frame
			await physics_frame
			if not _sees_building(target, own):
				continue
			var error := await _h.save_screenshot("%s/closeup-%s%s.png" % [out, side, suffix])
			if error != "":
				_errors.append(error)
			taken = true
			break
		if not taken:
			print("NOTE: no clear gameplay view of %s from the %s" % [source_key, side])


## Raised views of the building in its surroundings.
func _context_shots(source_key: String, out: String, suffix: String) -> void:
	var frame := _building_frame(source_key)
	if frame.is_empty():
		return
	var box: AABB = frame.box
	var center: Vector3 = frame.center
	var radius: float = frame.radius
	var camera := Camera3D.new()
	camera.fov = 60.0
	camera.far = 5000.0
	_h.main.add_child(camera)
	for view in [["southwest", Vector3(-1.0, 0.0, 1.0)], ["northeast", Vector3(1.0, 0.0, -1.0)]]:
		var direction := (view[1] as Vector3).normalized()
		camera.global_position = center + direction * radius * 3.0 + Vector3.UP * (box.size.y + radius * 1.2)
		camera.look_at(center, Vector3.UP)
		camera.make_current()
		var error := await _h.save_screenshot("%s/context-%s%s.png" % [out, view[0], suffix])
		if error != "":
			_errors.append(error)
	camera.queue_free()
	_h.player.get_camera().make_current()


func _sees_building(target: Vector3, own: Array[RID]) -> bool:
	var from := _h.player.get_camera().global_position
	var hit := _h.ray(from, target)
	return hit.is_empty() or (hit.rid as RID) in own


func _island_shots(out: String, suffix: String) -> void:
	var low := Vector2(INF, INF)
	var high := Vector2(-INF, -INF)
	for component: Dictionary in _h.world.get_boundary().get_boundary_data().components:
		for point: Array in component.outer:
			low = Vector2(minf(low.x, point[0]), minf(low.y, point[1]))
			high = Vector2(maxf(high.x, point[0]), maxf(high.y, point[1]))
	var center := Vector3((low.x + high.x) * 0.5, 0.0, (low.y + high.y) * 0.5)
	var span := (high - low).length()
	var camera := Camera3D.new()
	camera.fov = 55.0
	camera.far = 10000.0
	_h.main.add_child(camera)
	var views := [
		["top", Vector3(0.0, span * 0.75, span * 0.05)],
		["from-southwest", Vector3(-span * 0.36, span * 0.26, span * 0.36)],
		["from-southeast", Vector3(span * 0.36, span * 0.26, span * 0.36)],
		["from-northwest", Vector3(-span * 0.36, span * 0.26, -span * 0.36)],
		["from-northeast", Vector3(span * 0.36, span * 0.26, -span * 0.36)],
	]
	for view in views:
		camera.global_position = center + (view[1] as Vector3)
		camera.look_at(center, Vector3.UP)
		camera.make_current()
		var error := await _h.save_screenshot("%s/island-%s%s.png" % [out, view[0], suffix])
		if error != "":
			_errors.append(error)
	camera.queue_free()
	_h.player.get_camera().make_current()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)


func _overhead_shot(spec: String, out: String, suffix: String) -> void:
	var fields := spec.split(",")
	if fields.size() != 4:
		_errors.append("overhead requires center_x,center_z,width,depth")
		return
	for field in fields:
		if not field.is_valid_float():
			_errors.append("overhead fields must be numeric")
			return
	var width := float(fields[2])
	var depth := float(fields[3])
	if width <= 0.0 or depth <= 0.0:
		_errors.append("overhead extent must be positive")
		return
	var old_size := root.size
	root.size = Vector2i(roundi(1000.0 * width / depth), 1000)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = depth
	camera.far = 500.0
	_h.main.add_child(camera)
	var center := Vector3(float(fields[0]),0.0,float(fields[1]))
	camera.global_position = center + Vector3.UP * 100.0
	camera.look_at(center, Vector3.FORWARD)
	camera.make_current()
	await process_frame
	await process_frame
	var error := await _h.save_screenshot(out.path_join("site-overhead%s.png" % suffix))
	if error != "": _errors.append(error)
	print("OVERHEAD center=%s extent=%s north_up=-Z size=%s" % [center, Vector2(width,depth), root.size])
	camera.queue_free()
	_h.player.get_camera().make_current()
	root.size = old_size
