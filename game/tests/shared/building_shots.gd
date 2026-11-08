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
##   (default 2) as street-NAME-000.png, ...; a step with "frames": false saves
##   none, such as the jetpack climb before a filmed fast-drop landing (a step
##   holding "fast_drop"). Run with --fixed-fps 60 so the frames
##   are evenly spaced in game time. A free camera (camera_xyz) follows the player,
##   keeping its offset and looking at the player. Each tick prints a MOVE_TICK
##   line, with the avatar's describe() when it has one, and what the player
##   stands on: the slide floor collider and the first solid straight under its
##   feet (support=OBJECT_KEY@y, from the body's derived_object_key or name).
##   A moving view may add "start_xyz": [x,y,z] to start the stock player in the
##   air there, at rest, after it settles at player_xz (a landing view: scenery
##   off the walk route, such as the ferry float); the moves then run from there.
##   With "camera_fixed": true its free camera stays where camera_xyz puts it,
##   aimed at the target, instead of following the player (frames of something
##   that moves by itself, such as the docked ferry's rocking).
##   A still view (focused or street) may add "frame_time_frames": N (10-3000) to
##   hold its camera for N more frames with vsync and the frame cap off and print
##   their frame time as a FRAME_TIME line (pass --rendering-method
##   gl_compatibility --rendering-driver opengl3 for the web renderer). With
##   "frame_time_layer": "clutter" (a street-detail layer that is on) the frames
##   are timed with that layer drawn and hidden, in three alternating blocks each
##   so a drift in the machine's load falls on both: one FRAME_TIME line per state.
## --views-batch FILE: only the focused views of several buildings in one world load,
## [{"source": "KEY", "plan": "views.json"}, ...], each plan a --views file for its
## source, saved to OUT/KEY/detail-NAME.png. Fixed-pose views only (no closeup,
## context or overhead shots; --island may be added); any bad entry fails the run.
## --neutral-lighting: screenshots only. Swaps in the fixed neutral daylight below
##   (NEUTRAL_ENVIRONMENT, NEUTRAL_SKY, NEUTRAL_SUN) for colour matching against
##   reference photos: a complete environment, sky and sun of its own, with Mersea's
##   reflection probes recaptured under them, so a change to main.tscn's lighting
##   does not reach these shots. A change to a palette or material does, as it
##   should. Gameplay always uses main.tscn.
## --street-detail off|on|both: street detail (vegetation, furniture, fences, clutter)
##   in every shot. Without it, close-ups and focused views are taken with street
##   detail off, and context, island and overhead views both ways. A view taken
##   both ways is saved as NAME-street-on.png and NAME-street-off.png, otherwise
##   as NAME.png. One world load: the on views first, then street detail is freed.
## Plant galleries: a --street-views plan may also plant street-vegetation kit
##   props for its shots (a species gallery, a test bed), visual only and gone
##   after them: "beds": [{"name": "...", "center_xz": [x,z], "size_m": [w,d],
##   "ground": "mulch", "edge_m": 0.0}] lays a bed of mulch (or "gravel", or the
##   streets' "street_mulch") 2 cm over the drawn ground, later beds over earlier
##   ones, its edge fading out unevenly over edge_m when that is set,
##   and "plants": [{"group": "...", "prop": "...", "variant": 0, "scale": 1.0,
##   "xz": [x,z], "yaw": 0.0}] stands kit props on the beds (or on the drawn
##   ground), built as the world builds its vegetation; a hedge prop takes a
##   "path": [[x,z], ...] instead of xz, laid on the ground under each point. A
##   plant may add "level": "lod0", "lod1" or "far" to draw its group at that
##   detail level only, at any distance (every plant of the group the same), so
##   a sheet can set the levels side by side. The aiming reticle is
##   hidden while they stand. A view may then add "show": ["GROUP", ...] to
##   draw only those groups, and "measure_frames": N to time N drawn frames with
##   them shown and N with every group hidden, in three alternating blocks each,
##   with vsync and the frame cap off (FRAME_TIME lines, with the frame's draw
##   calls and primitives).
##   Any street view may instead time a whole street-detail layer of the world:
##   "measure_frames": N with "measure_layer": "vegetation" (or another layer)
##   shows and hides that layer the same way, in the pass where it is on.
## Ground dressing (the grass of ground_dressing.gd; --ground-dressing LEVEL on the
##   command line, else the project setting): a still view may add "dressing":
##   "off", "low", "medium" or "high" to shoot at that density, "dressing_parts":
##   {"cards": false, "grass": true, "stones": true} for what draws, "dressing_params":
##   {"uniform": value, ...} to set grass uniforms (a list is a vector), all kept
##   for the views after it, "dressing_maps": true to save the ground captures
##   beside the shot, and "measure_dressing": N to time N frames at each of
##   "measure_levels" (default all four), in three alternating blocks with vsync
##   and the frame cap off, from the view's camera: one FRAME_TIME line per level
##   with wall, render CPU and GPU times, and a DRESSING_CAPTURE line with what a
##   new capture costs.

const WorldHarness := preload("res://game/tests/shared/world_harness.gd")
## The island overviews' far plane, the largest any camera uses: the bay water's
## bounds hold its rings (game/tests/headless_gameplay_contract.gd reads this).
const ISLAND_CAMERA_FAR_M := 10000.0
const GROUND_COVER := preload("res://game/scripts/world/ground_cover.gd")
const VegetationKit := preload("res://game/scripts/world/street_vegetation_kit.gd")
## A gallery bed's ground textures (2 m tiles), its grid step and its lift over
## the drawn ground, in metres; each later bed lies BED_LAYER_M over the earlier.
const BED_GROUNDS := {
	"mulch": "res://game/resources/textures/world/vegetation/park_mulch.png",
	"gravel": "res://game/resources/textures/world/vegetation/park_gravel.png",
	"street_mulch": "res://game/resources/textures/world/street/street_mulch.png",
}
const BED_STEP_M := 0.5
const BED_LIFT_M := 0.02
const BED_LAYER_M := 0.006

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
const MOVE_ACTIONS := ["move_forward", "move_back", "move_left", "move_right", "run", "jetpack", "fast_drop"]

## The neutral daylight for colour matching: the sun angle, tonemapper and shadows
## main.tscn had before the 2026-11-07 look pass (sun at azimuth 152, elevation 52),
## with the ambient, fog, sky and sun colour from before the 2026-10-23 warm-light
## change. These are whole settings, not overrides of main.tscn: a fresh Environment
## has SSAO, SSIL, glow and colour adjustment off, so main.tscn's lighting cannot
## reach these shots.
const NEUTRAL_ENVIRONMENT := {
	"background_mode": Environment.BG_SKY,
	"background_color": Color(0.46, 0.69, 0.86),
	"ambient_light_source": Environment.AMBIENT_SOURCE_SKY,
	"reflected_light_source": Environment.REFLECTION_SOURCE_SKY,
	"ambient_light_color": Color(0.64, 0.60, 0.53),
	"ambient_light_energy": 0.75,
	"ambient_light_sky_contribution": 0.45,
	"tonemap_mode": Environment.TONE_MAPPER_FILMIC,
	"fog_enabled": true,
	"fog_light_color": Color(0.72, 0.80, 0.88),
	"fog_light_energy": 0.85,
	"fog_density": 0.00012,
	"fog_aerial_perspective": 0.0,
	"fog_sky_affect": 0.0,
	"fog_height": 0.0,
	"fog_height_density": 0.0,
}
const NEUTRAL_SKY := {
	"sky_top_color": Color(0.24, 0.44, 0.78),
	"sky_horizon_color": Color(0.72, 0.80, 0.88),
	"sky_curve": 0.09,
	"sky_energy_multiplier": 1.0,
	"ground_bottom_color": Color(0.40, 0.40, 0.37),
	"ground_horizon_color": Color(0.50, 0.68, 0.84),
	"ground_curve": 0.3,
	"ground_energy_multiplier": 1.0,
}
const NEUTRAL_SUN := {
	"rotation_degrees": Vector3(-52.0, 28.0, 0.0),
	"light_color": Color(1.0, 0.97, 0.92),
	"light_energy": 1.1,
	"shadow_enabled": true,
	"shadow_blur": 0.5,
	"directional_shadow_max_distance": 800.0,
}

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


## Screenshot-only: the neutral daylight for colour matching, in place of the game's
## environment and sun. Mersea's probes captured the game's light at startup, so they
## update again under this one. Waits for the sky radiance map and the probes before
## any capture.
func _use_neutral_lighting() -> void:
	var sky := Sky.new()
	sky.sky_material = _with_settings(ProceduralSkyMaterial.new(), NEUTRAL_SKY)
	var environment := _with_settings(Environment.new(), NEUTRAL_ENVIRONMENT) as Environment
	environment.sky = sky
	(_h.main.get_node("WorldEnvironment") as WorldEnvironment).environment = environment
	(_h.main.get_node("Sun") as DirectionalLight3D).visible = false
	_h.main.add_child(_with_settings(DirectionalLight3D.new(), NEUTRAL_SUN) as DirectionalLight3D)
	for probe: ReflectionProbe in _h.world.buildings.find_children("Mersea*Reflection", "ReflectionProbe", true, false):
		probe.update_mode = ReflectionProbe.UPDATE_ALWAYS
	for _i in 30:
		await process_frame
	await RenderingServer.frame_post_draw
	print("LIGHTING: neutral (fixed colour-matching daylight, screenshots only)")


func _with_settings(object: Object, settings: Dictionary) -> Object:
	for property: String in settings:
		object.set(property, settings[property])
	return object


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
	var gallery := _plant_gallery(plan)
	if gallery.has("error"):
		_errors.append("street view plants: " + str(gallery.error))
		return
	var names := {}
	for view: Variant in plan.views:
		if not view is Dictionary or not view.get("name") is String or not _numbers(view.get("player_xz"), 2) or not _numbers(view.get("target_xyz"), 3):
			_errors.append("street view needs name, player_xz and target_xyz")
			break
		var name: String = view.name
		if name == "" or name.validate_filename() != name or names.has(name):
			_errors.append("street view names must be unique safe filenames")
			break
		names[name] = true
		var show_error := _show_groups(gallery, view)
		if show_error != "":
			_errors.append("street view " + name + ": " + show_error)
			break
		var target := Vector3(view.target_xyz[0], view.target_xyz[1], view.target_xyz[2])
		var error := ""
		if view.has("moves"):
			error = await _moving_view(view, target, "%s/street-%s%s" % [out, name, suffix])
		else:
			error = await _shoot_view(view, target, "%s/street-%s%s.png" % [out, name, suffix])
		if error == "" and view.has("measure_frames"):
			error = await _measure_view(view, target, gallery)
		if error != "":
			_errors.append("street view " + name + ": " + error)
			break
		var camera_note: Variant = view.get("camera_xyz", "gameplay")
		if not view.has("camera_xyz"):
			# How far the gameplay camera stands from its arm's origin, against the full arm.
			var arm := _h.player.get_node("CameraPivot/SpringArm3D") as SpringArm3D
			camera_note = "gameplay arm_m=%.2f of %.2f" % [arm.global_position.distance_to(_h.player.get_camera().global_position), arm.spring_length]
		print("STREET_VIEW %s area=%s player=%s on_floor=%s target=%s camera=%s" % [name, plan.area, _h.player.global_position, _h.player.is_on_floor(), target, camera_note])
	if gallery.has("node"):
		(gallery.node as Node).free()
		_h.hud.reticle.modulate.a = 1.0


## The plan's gallery beds and plants, built under one node:
## {node, groups: {name -> Node3D}}, {} when the plan has none, or {error}.
func _plant_gallery(plan: Dictionary) -> Dictionary:
	if not plan.has("plants") and not plan.has("beds"):
		return {}
	var beds: Variant = plan.get("beds", [])
	var plants: Variant = plan.get("plants", [])
	if not beds is Array or not plants is Array or (plants as Array).is_empty():
		return {"error": "plants must be a nonempty list and beds a list"}
	var ground := VisibleGround.new()
	ground.build([_h.world.ground_and_areas, _h.world.roads_and_paths])
	var root := Node3D.new()
	root.name = "PlantGallery"
	_h.main.add_child(root)
	var grids: Array[Dictionary] = []
	for bed: Variant in beds:
		if not bed is Dictionary or not bed.get("name") is String or not _numbers(bed.get("center_xz"), 2) or not _numbers(bed.get("size_m"), 2) \
		or float(bed.size_m[0]) <= 0.0 or float(bed.size_m[1]) <= 0.0 or float(bed.size_m[0]) > 60.0 or float(bed.size_m[1]) > 60.0 \
		or not BED_GROUNDS.has(bed.get("ground", "mulch")) or not _numbers([bed.get("edge_m", 0.0)], 1) or float(bed.get("edge_m", 0.0)) < 0.0 or float(bed.get("edge_m", 0.0)) > 5.0:
			root.free()
			return {"error": "a bed needs a name, center_xz, a size_m of up to 60 m, a ground of %s and an edge_m of 0-5 m" % ", ".join(PackedStringArray(BED_GROUNDS.keys()))}
		var grid := _bed_grid(Vector2(bed.center_xz[0], bed.center_xz[1]), Vector2(bed.size_m[0], bed.size_m[1]), ground, BED_LIFT_M + BED_LAYER_M * grids.size())
		if grid.has("error"):
			root.free()
			return {"error": "bed %s: %s" % [bed.name, grid.error]}
		# Plants stand on the topmost bed under them.
		grids.push_front(grid)
		root.add_child(_bed_mesh(str(bed.name), grid, str(bed.get("ground", "mulch")), float(bed.get("edge_m", 0.0))))
	var rows := {}
	var levels := {}
	for index in (plants as Array).size():
		var plant: Variant = plants[index]
		var hedge := plant is Dictionary and VegetationKit.is_hedge(str(plant.get("prop", "")))
		if not plant is Dictionary or not plant.get("group") is String or str(plant.group) == "" or not plant.get("prop") is String \
		or not (_numbers(plant.get("xz"), 2) if not hedge else plant.get("path") is Array and (plant.path as Array).size() >= 2) \
		or not _numbers([plant.get("scale", 1.0), plant.get("yaw", 0.0), plant.get("variant")], 3):
			root.free()
			return {"error": "plant %d needs a group, prop, variant and xz (a hedge, a path of at least two [x,z]), and numeric scale and yaw" % index}
		var level: Variant = plant.get("level", null)
		if (level != null and not level in ["lod0", "lod1", "far"]) or (levels.has(plant.group) and levels[plant.group] != level):
			root.free()
			return {"error": "plant %d: a level is lod0, lod1 or far, the same for every plant of a group" % index}
		levels[plant.group] = level
		var prop := str(plant.prop)
		if not rows.has(plant.group):
			rows[plant.group] = []
		if hedge:
			var line := []
			var ground_y := []
			for point: Variant in plant.path:
				if not _numbers(point, 2):
					root.free()
					return {"error": "plant %d: a path point is [x, z]" % index}
				var y := _bed_height(grids, Vector2(point[0], point[1]))
				if is_nan(y):
					y = _drawn_ground(Vector2(point[0], point[1]), ground)
				if is_nan(y):
					root.free()
					return {"error": "plant %d has no ground under its path" % index}
				line.append([float(point[0]), y, float(point[1])])
				ground_y.append(y)
			(rows[plant.group] as Array).append({"id": "gallery:%d" % index, "status": "placed", "layer": "vegetation", "kind": "hedge", "geometry": "polyline",
				"prop": prop, "prop_params": {"variant": plant.variant, "ground_y_m": ground_y}, "points_m": line})
			continue
		var params := {"variant": plant.variant, "scale": float(plant.get("scale", 1.0)), "lift_m": 0.0, "foot_spread_m": 0.0, "well_m": 0.0}
		var problem := VegetationKit.params_error(prop, str((VegetationKit.PROPS[prop].kinds as Array)[0]) if VegetationKit.PROPS.has(prop) else "", params)
		if problem != "":
			root.free()
			return {"error": "plant %d: %s" % [index, problem]}
		var xz := Vector2(plant.xz[0], plant.xz[1])
		var y := _bed_height(grids, xz)
		if is_nan(y):
			var drawn := _drawn_ground(xz, ground)
			if is_nan(drawn):
				root.free()
				return {"error": "plant %d has no ground under it" % index}
			y = drawn
		(rows[plant.group] as Array).append({"id": "gallery:%d" % index, "status": "placed", "layer": "vegetation", "kind": (VegetationKit.PROPS[prop].kinds as Array)[0],
			"prop": prop, "prop_params": params, "position_m": [xz.x, y, xz.y], "surface": {"bias_m": 0.0}, "yaw_radians": float(plant.get("yaw", 0.0))})
	var groups := {}
	for group: String in rows:
		var built := StreetVegetationBuilder.new().build({"rows": rows[group]})
		if not built.ok:
			root.free()
			return {"error": "group %s: %s" % [group, built.message]}
		var node: Node3D = built.node
		node.name = "Group_" + group.validate_node_name()
		if levels[group] != null:
			# Only the chosen detail level, drawn at any distance.
			for child in node.get_children():
				if child is GeometryInstance3D:
					var drawn := ("_%s__c" % levels[group]) in str(child.name) or "_shadow__c" in str(child.name)
					(child as GeometryInstance3D).visible = drawn
					(child as GeometryInstance3D).visibility_range_begin = 0.0
					(child as GeometryInstance3D).visibility_range_end = 0.0
		root.add_child(node)
		groups[group] = node
	# The aiming reticle would sit on the plants in the middle of every shot.
	_h.hud.reticle.modulate.a = 0.0
	print("PLANT_GALLERY beds=%d plants=%d groups=%s" % [grids.size(), (plants as Array).size(), ",".join(PackedStringArray(groups.keys()))])
	return {"node": root, "groups": groups}


## The drawn ground's height at xz (the land under it plus the lift of the
## surface drawn over it), or NAN off the land.
func _drawn_ground(xz: Vector2, ground: VisibleGround) -> float:
	var hit := _h.ray(Vector3(xz.x, 300.0, xz.y), Vector3(xz.x, -50.0, xz.y))
	if hit.is_empty():
		return NAN
	return float((hit.position as Vector3).y) + ground.lift_at(xz.x, xz.y)


## A bed's grid of heights, lift over the drawn ground: {origin, step, counts, heights}.
func _bed_grid(center: Vector2, size: Vector2, ground: VisibleGround, lift: float) -> Dictionary:
	var counts := Vector2i(ceili(size.x / BED_STEP_M) + 1, ceili(size.y / BED_STEP_M) + 1)
	var origin := center - size * 0.5
	var step := Vector2(size.x / (counts.x - 1), size.y / (counts.y - 1))
	var heights := PackedFloat32Array()
	for j in counts.y:
		for i in counts.x:
			var y := _drawn_ground(origin + Vector2(i * step.x, j * step.y), ground)
			if is_nan(y):
				return {"error": "it leaves the land"}
			heights.append(y + lift)
	return {"origin": origin, "step": step, "counts": counts, "heights": heights}


## The height of the bed surface at xz, or NAN outside every bed.
func _bed_height(grids: Array[Dictionary], xz: Vector2) -> float:
	for grid in grids:
		var counts: Vector2i = grid.counts
		var local: Vector2 = (xz - (grid.origin as Vector2)) / (grid.step as Vector2)
		if local.x < 0.0 or local.y < 0.0 or local.x > counts.x - 1 or local.y > counts.y - 1:
			continue
		var i := mini(int(local.x), counts.x - 2)
		var j := mini(int(local.y), counts.y - 2)
		var fx := local.x - i
		var fz := local.y - j
		var heights: PackedFloat32Array = grid.heights
		var low := lerpf(heights[j * counts.x + i], heights[j * counts.x + i + 1], fx)
		var high := lerpf(heights[(j + 1) * counts.x + i], heights[(j + 1) * counts.x + i + 1], fx)
		return lerpf(low, high, fz)
	return NAN


## The bed's surface of its ground texture in 2 m tiles, as the planting strips
## draw theirs; with edge_m, its edge fades out unevenly over that width (a
## gravel patch worked into the mulch round it, not a cut square).
func _bed_mesh(name: String, grid: Dictionary, ground: String, edge_m: float) -> MeshInstance3D:
	var counts: Vector2i = grid.counts
	var origin: Vector2 = grid.origin
	var step: Vector2 = grid.step
	var heights: PackedFloat32Array = grid.heights
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for j in counts.y:
		for i in counts.x:
			var x := origin.x + i * step.x
			var z := origin.y + j * step.y
			var alpha := 1.0
			if edge_m > 0.0:
				var inside := minf(minf(i * step.x, (counts.x - 1 - i) * step.x), minf(j * step.y, (counts.y - 1 - j) * step.y))
				# A fixed per-vertex wobble, so the fade's outline is ragged.
				var wobble := (fposmod(sin(float(i) * 12.9898 + float(j) * 78.233) * 43758.5453, 1.0) - 0.5) * edge_m
				alpha = clampf((inside + wobble) / edge_m, 0.0, 1.0)
			surface.set_color(Color(1.0, 1.0, 1.0, alpha))
			surface.set_uv(Vector2(x, z) / 2.0)
			surface.add_vertex(Vector3(x, heights[j * counts.x + i], z))
	for j in counts.y - 1:
		for i in counts.x - 1:
			var a := j * counts.x + i
			# Clockwise seen from above (Godot's front face).
			surface.add_index(a)
			surface.add_index(a + 1)
			surface.add_index(a + counts.x)
			surface.add_index(a + 1)
			surface.add_index(a + counts.x + 1)
			surface.add_index(a + counts.x)
	surface.generate_normals()
	var material := StandardMaterial3D.new()
	material.albedo_texture = load(BED_GROUNDS[ground])
	material.roughness = 1.0
	if edge_m > 0.0:
		material.vertex_color_use_as_albedo = true
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	var instance := MeshInstance3D.new()
	instance.name = "Bed_" + name.validate_node_name()
	instance.mesh = surface.commit()
	instance.material_override = material
	return instance


## Shows only the gallery groups a view names in "show" (all when it names none).
func _show_groups(gallery: Dictionary, view: Dictionary) -> String:
	if not gallery.has("groups"):
		return "show needs plants in the plan" if view.has("show") else ""
	var show: Variant = view.get("show", [])
	if not show is Array:
		return "show must list plant groups"
	for group: Variant in show:
		if not (gallery.groups as Dictionary).has(group):
			return "show names no plant group %s" % group
	for group: String in gallery.groups:
		(gallery.groups[group] as Node3D).visible = (show as Array).is_empty() or group in show
	return ""


## Times a view's drawn frames from its camera, with vsync and the frame cap
## off: measure_frames with its plant groups as shown and as many with every
## group hidden (the beds stay), in three alternating blocks each so a slow
## drift in the machine's load falls on both. With "measure_layer": NAME the
## view needs no plants: the world's street-detail layer of that name is shown
## and hidden instead (a view taken while that layer is off prints a
## FRAME_TIME_SKIPPED line). With "measure_ground": true it times the ground-cover
## shader's bare-soil branch instead: "plants" is the ground as it is, "empty" the
## same with every family's bare threshold out of reach, which skips that branch.
## Prints one FRAME_TIME line per state, with the last frame's draw calls and
## primitives, then restores what was shown.
## Returns an error, or "".
func _measure_view(view: Dictionary, target: Vector3, gallery: Dictionary) -> String:
	var toggled: Array[Node3D] = []
	var ground := view.has("measure_ground")
	if view.has("measure_layer"):
		var layer := str(view.measure_layer)
		if not layer in WorldLoader.STREET_DETAIL_LAYERS:
			return "measure_layer must name a street-detail layer"
		if not layer in _h.world.get_street_detail_layers():
			print("FRAME_TIME_SKIPPED view=%s layer=%s is off in this pass" % [view.name, layer])
			return ""
		var node := _h.world.street_detail_layer(layer)
		if node == null:
			return "measure_layer %s has no street-detail node" % layer
		toggled.append(node)
	elif gallery.has("groups"):
		for group: String in gallery.groups:
			toggled.append(gallery.groups[group] as Node3D)
	if not _numbers([view.get("measure_frames")], 1) or float(view.measure_frames) < 30.0 or float(view.measure_frames) > 3000.0 or (toggled.is_empty() and not ground):
		return "measure_frames needs 30-3000 frames and plants in the plan, a measure_layer or measure_ground"
	var error := await _h.settle_player(Vector2(view.player_xz[0], view.player_xz[1]))
	if error != "":
		return error
	var free := _free_camera(view, target)
	if free == null:
		_h.aim_camera(target)
	var shown: Array[bool] = []
	for node in toggled:
		shown.append(node.visible)
	var uncapped := _uncap_frames()
	var blocks := 3
	var per_block := maxi(10, int(view.measure_frames) / blocks)
	# Packed arrays are values in GDScript: keep one local per state, not two in a dictionary.
	var plants_times := PackedFloat64Array()
	var empty_times := PackedFloat64Array()
	var info := {}
	for block in blocks * 2:
		var state := "plants" if block % 2 == 0 else "empty"
		for index in toggled.size():
			toggled[index].visible = shown[index] and state == "plants"
		if ground:
			_set_ground_bare(state == "plants")
		var times := await _frame_times(per_block, 20)
		if state == "plants":
			plants_times.append_array(times)
		else:
			empty_times.append_array(times)
		info[state] = [RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME), RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)]
	_restore_frames(uncapped)
	for index in toggled.size():
		toggled[index].visible = shown[index]
	if ground:
		_set_ground_bare(true)
	for state: String in ["plants", "empty"]:
		var stats := _frame_stats(plants_times if state == "plants" else empty_times)
		print("FRAME_TIME view=%s state=%s frames=%d mean_ms=%.2f median_ms=%.2f p95_ms=%.2f draw_calls=%d primitives=%d renderer=%s/%s" % [view.name, state, stats.frames, stats.mean,
			stats.median, stats.p95, info[state][0], info[state][1], RenderingServer.get_current_rendering_method(), RenderingServer.get_video_adapter_name()])
	if free != null:
		free.queue_free()
		_h.player.get_camera().make_current()
	return ""


## Every ground-cover family's bare soil on as configured, or off by a bare
## threshold out of reach (the shader then skips its bare branch).
func _set_ground_bare(on: bool) -> void:
	for family: String in GROUND_COVER.FAMILIES:
		var made := GROUND_COVER.material(family)
		var preset: Dictionary = GROUND_COVER.FAMILIES[family]
		made.set_shader_parameter("bare_threshold", float(preset.bare_threshold) if on else 2.0)
		for uniform: String in GROUND_COVER.COVER_MAP_RECIPES:
			var recipe: Dictionary = GROUND_COVER.FAMILIES[GROUND_COVER.COVER_MAP_RECIPES[uniform]]
			made.set_shader_parameter(uniform, Vector3(recipe.dry_threshold, float(recipe.bare_threshold) if on else 2.0, recipe.green_dryness))


## Settles the player at the view's player_xz and saves one screenshot from the
## gameplay camera aimed at target, or from a free camera at camera_xyz. Returns
## an error message, or "".
func _shoot_view(view: Dictionary, target: Vector3, path: String) -> String:
	var camera_error := _free_camera_error(view, target)
	if camera_error != "":
		return camera_error
	var dressing_error := _apply_dressing(view)
	if dressing_error != "":
		return dressing_error
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
		error = await _frame_time(view.frame_time_frames, path.get_file().get_basename(), str(view.get("frame_time_layer", "")))
	if error == "" and view.get("dressing_maps", false):
		error = _save_dressing_maps(path.get_basename())
	if error == "" and view.has("measure_dressing"):
		error = await _measure_dressing(view, path.get_file().get_basename())
	if free != null:
		free.queue_free()
		_h.player.get_camera().make_current()
	return error


## Applies a view's "dressing" level and "dressing_params". Returns an error, or "".
func _apply_dressing(view: Dictionary) -> String:
	if not view.has("dressing") and not view.has("dressing_parts") and not view.has("dressing_params"):
		return ""
	var dressing := _h.main.ground_dressing
	if dressing == null:
		return "this run draws no ground dressing (Forward+ only, and not at --ground-dressing off)"
	if view.has("dressing"):
		var level := str(view.dressing)
		if level != dressing.OFF and not dressing.LEVELS.has(level):
			return "dressing must be off, low, medium or high"
		dressing.set_level(level)
	if view.has("dressing_parts"):
		var parts: Dictionary = view.dressing_parts
		dressing.set_parts(bool(parts.get("cards", false)), bool(parts.get("grass", true)), bool(parts.get("stones", true)))
	var params: Dictionary = view.get("dressing_params", {})
	for uniform: String in params:
		var value: Variant = params[uniform]
		if value is Array:
			value = Vector2(value[0], value[1]) if value.size() == 2 else Vector3(value[0], value[1], value[2])
		dressing.set_parameter(uniform, value)
	return ""


## Saves the ground dressing's captures as PREFIX-surface.png (red the height over
## 16 m, green how thickly tufts stand, blue their height, alpha open ground) and
## PREFIX-colour.png, printing the height at the window's centre.
func _save_dressing_maps(prefix: String) -> String:
	var dressing := _h.main.ground_dressing
	if dressing == null:
		return "this run draws no ground dressing"
	var surface := dressing.surface_viewport.get_texture().get_image()
	var centre := surface.get_pixel(surface.get_width() / 2, surface.get_height() / 2)
	print("DRESSING_MAPS %s format=%d size=%s centre=%s" % [prefix.get_file(), surface.get_format(), surface.get_size(), centre])
	var shown := Image.create_empty(surface.get_width(), surface.get_height(), false, Image.FORMAT_RGBA8)
	for y in surface.get_height():
		for x in surface.get_width():
			var pixel := surface.get_pixel(x, y)
			shown.set_pixel(x, y, Color(pixel.r / 16.0, pixel.g, pixel.b, 1.0).lerp(Color.MAGENTA, 1.0 - pixel.a))
	var colour := dressing.colour_viewport.get_texture().get_image()
	colour.convert(Image.FORMAT_RGBA8)
	var error := shown.save_png(prefix + "-surface.png")
	if error == OK:
		error = colour.save_png(prefix + "-colour.png")
	return "" if error == OK else "could not save the dressing maps (error %d)" % error


## Times this view's camera at each dressing level, in alternating blocks. See the
## header. Returns an error, or "".
func _measure_dressing(view: Dictionary, label: String) -> String:
	var dressing := _h.main.ground_dressing
	if dressing == null:
		return "this run draws no ground dressing"
	var levels: Array = view.get("measure_levels", ["off", "low", "medium", "high"])
	var frames := int(view.measure_dressing)
	var kept: String = dressing.get_level()
	var window := root.get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(window, true)
	var uncapped := _uncap_frames()
	var rows := {}
	for level: String in levels:
		rows[level] = {"wall": [], "cpu": [], "gpu": []}
	var blocks := 3
	for block in blocks:
		for level: String in levels:
			dressing.set_level(level)
			for _i in 20:
				await RenderingServer.frame_post_draw
			var row: Dictionary = rows[level]
			var last := Time.get_ticks_usec()
			for _i in maxi(10, frames / blocks):
				await RenderingServer.frame_post_draw
				var now := Time.get_ticks_usec()
				(row.wall as Array).append(float(now - last) / 1000.0)
				(row.cpu as Array).append(RenderingServer.viewport_get_measured_render_time_cpu(window) + RenderingServer.get_frame_setup_time_cpu())
				(row.gpu as Array).append(RenderingServer.viewport_get_measured_render_time_gpu(window))
				last = now
			row.draws = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
			row.primitives = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
	for level: String in levels:
		var row: Dictionary = rows[level]
		var wall := _frame_stats(PackedFloat64Array(row.wall))
		var cpu := _frame_stats(PackedFloat64Array(row.cpu))
		var gpu := _frame_stats(PackedFloat64Array(row.gpu))
		print("FRAME_TIME view=%s dressing=%s frames=%d wall_mean_ms=%.2f wall_median_ms=%.2f wall_p95_ms=%.2f cpu_median_ms=%.2f gpu_median_ms=%.2f gpu_p95_ms=%.2f draw_calls=%d primitives=%d renderer=%s/%s" % [label, level, wall.frames, wall.mean, wall.median, wall.p95, cpu.median, gpu.median, gpu.p95, row.draws, row.primitives, RenderingServer.get_current_rendering_method(), RenderingServer.get_video_adapter_name()])
	dressing.set_level(kept)
	if kept != dressing.OFF:
		# A capture only draws when the camera has gone far enough, so draw them every
		# frame for a moment to read their cost.
		var captures := dressing.capture_viewports()
		for viewport: SubViewport in captures:
			RenderingServer.viewport_set_measure_render_time(viewport.get_viewport_rid(), true)
			viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		for _i in 30:
			await RenderingServer.frame_post_draw
		var cost := {}
		for viewport: SubViewport in captures:
			cost[viewport.name] = RenderingServer.viewport_get_measured_render_time_gpu(viewport.get_viewport_rid())
			viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
		print("DRESSING_CAPTURE view=%s gpu_ms=%s" % [label, cost])
	RenderingServer.viewport_set_measure_render_time(window, false)
	_restore_frames(uncapped)
	return ""


## Holds the view's camera for `frames` more drawn frames, with vsync and the
## frame cap off, and prints the wall time between them as a FRAME_TIME line
## (mean, median, 95th percentile and the mean's fps, and the last frame's
## draw calls and primitives). Returns an error, or "".
func _frame_time(frames: Variant, label: String, layer := "") -> String:
	if not _numbers([frames], 1) or float(frames) != floorf(float(frames)) or float(frames) < 10.0 or float(frames) > 3000.0:
		return "frame_time_frames must be a whole number from 10 to 3000"
	if layer != "":
		if not layer in WorldLoader.STREET_DETAIL_LAYERS:
			return "frame_time_layer must be a street-detail layer: %s" % layer
		# Only while the layer is on (the street-detail-on pass); off, time it plainly.
		if layer in _h.world.get_street_detail_layers():
			return await _frame_time_layer(int(frames), label, layer)
	var uncapped := _uncap_frames()
	# Let the change and any first-use work settle before timing.
	var stats := _frame_stats(await _frame_times(int(frames), 30))
	_restore_frames(uncapped)
	print("FRAME_TIME %s frames=%d mean_ms=%.2f median_ms=%.2f p95_ms=%.2f mean_fps=%.1f draw_calls=%d primitives=%d method=%s adapter=%s" % [
		label, stats.frames, stats.mean, stats.median, stats.p95, 1000.0 / stats.mean,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME),
		RenderingServer.get_current_rendering_method(), RenderingServer.get_video_adapter_name(),
	])
	return ""


## Times `frames` drawn frames with a street-detail layer drawn and as many with
## it hidden (its collision stays), in three alternating blocks each, and prints
## one FRAME_TIME line per state with the last frame's draw calls and primitives.
func _frame_time_layer(frames: int, label: String, layer: String) -> String:
	var node := _h.world.street_detail_layer(layer)
	var visible := node.visible
	var uncapped := _uncap_frames()
	var blocks := 3
	var per_block := maxi(10, frames / blocks)
	# Packed arrays are values in GDScript: one local per state.
	var shown_times := PackedFloat64Array()
	var hidden_times := PackedFloat64Array()
	var info := {}
	for block in blocks * 2:
		var state := "shown" if block % 2 == 0 else "hidden"
		node.visible = visible and state == "shown"
		var times := await _frame_times(per_block, 20)
		if state == "shown":
			shown_times.append_array(times)
		else:
			hidden_times.append_array(times)
		info[state] = [RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME), RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)]
	node.visible = visible
	_restore_frames(uncapped)
	for state: String in ["shown", "hidden"]:
		var stats := _frame_stats(shown_times if state == "shown" else hidden_times)
		print("FRAME_TIME %s layer=%s state=%s frames=%d mean_ms=%.2f median_ms=%.2f p95_ms=%.2f mean_fps=%.1f draw_calls=%d primitives=%d method=%s adapter=%s" % [
			label, layer, state, stats.frames, stats.mean, stats.median, stats.p95, 1000.0 / stats.mean, info[state][0], info[state][1],
			RenderingServer.get_current_rendering_method(), RenderingServer.get_video_adapter_name(),
		])
	return ""


## Turns vsync and the frame cap off for timing; returns what to restore.
func _uncap_frames() -> Array:
	var saved := [DisplayServer.window_get_vsync_mode(), Engine.max_fps]
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	return saved


func _restore_frames(saved: Array) -> void:
	DisplayServer.window_set_vsync_mode(saved[0])
	Engine.max_fps = saved[1]


## The wall time (ms) between each of `frames` drawn frames, after `settle`
## frames that let a change settle; the shared timer of measure_frames and
## frame_time_frames.
func _frame_times(frames: int, settle: int) -> PackedFloat64Array:
	for _i in settle:
		await RenderingServer.frame_post_draw
	var times := PackedFloat64Array()
	var last := Time.get_ticks_usec()
	for _i in frames:
		await RenderingServer.frame_post_draw
		var now := Time.get_ticks_usec()
		times.append(float(now - last) / 1000.0)
		last = now
	return times


## Frame count, mean, median and 95th percentile (ms) of frame times.
func _frame_stats(times: PackedFloat64Array) -> Dictionary:
	var sorted := times.duplicate()
	sorted.sort()
	var total := 0.0
	for time in sorted:
		total += time
	return {"frames": sorted.size(), "mean": total / float(sorted.size()), "median": sorted[sorted.size() / 2], "p95": sorted[mini(sorted.size() - 1, int(sorted.size() * 0.95))]}


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
		or (step.has("turn_deg") and not _numbers([step.get("turn_deg")], 1)) or (step.has("frames") and not step.frames is bool):
			return "each move needs hold (a list of actions), whole positive ticks, an optional numeric turn_deg and an optional true or false frames"
		for action: Variant in step.hold:
			if not action in MOVE_ACTIONS:
				return "moves may hold only " + ", ".join(PackedStringArray(MOVE_ACTIONS))
	var camera_error := _free_camera_error(view, target)
	if camera_error != "":
		return camera_error
	if view.has("start_xyz") and not _numbers(view.get("start_xyz"), 3):
		return "start_xyz needs [x, y, z]"
	var error := await _h.settle_player(Vector2(view.player_xz[0], view.player_xz[1]))
	if error != "":
		return error
	var player := _h.player
	if view.has("start_xyz"):
		player.global_position = Vector3(view.start_xyz[0], view.start_xyz[1], view.start_xyz[2])
		player.velocity = Vector3.ZERO
		print("MOVE_START %s at=%s (placed in the air after settling at %s)" % [prefix.get_file(), player.global_position, view.player_xz])
	var capsule := player.get_node("CollisionShape3D") as Node3D
	var free := _free_camera(view, target)
	if view.has("camera_fixed") and (not view.camera_fixed is bool or free == null):
		if free != null:
			free.queue_free()
			player.get_camera().make_current()
		return "camera_fixed needs true or false and a camera_xyz"
	var follow := free != null and not bool(view.get("camera_fixed", false))
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
			if tick % int(every) == 0 and step.get("frames", true):
				if follow:
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
			print("MOVE_TICK %s tick=%d frame=%s pos=%s speed=%.3f floor=%s held=%s avatar=%s floor_body=%s support=%s" % [prefix.get_file(), tick, saved, player.global_position, Vector2(velocity.x, velocity.z).length(), player.is_on_floor(), ",".join(PackedStringArray(step.hold)), JSON.stringify(state), _floor_body(player), _support_under(player)])
			tick += 1
		_h.release_input()
		if error != "":
			break
	player.set_gameplay_enabled(false)
	if free != null:
		free.queue_free()
		player.get_camera().make_current()
	return error


## The collider of the player's floor contact this tick, or "-".
func _floor_body(player: CharacterBody3D) -> String:
	if not player.is_on_floor():
		return "-"
	for index in player.get_slide_collision_count():
		var collision := player.get_slide_collision(index)
		if collision.get_normal().dot(player.up_direction) >= cos(player.floor_max_angle):
			return _body_label(collision.get_collider() as Node)
	return "snap"


## The first solid straight under the player's feet within a metre, as
## OBJECT_KEY@height, or "-".
func _support_under(player: CharacterBody3D) -> String:
	var feet := player.global_position
	var hit := _h.ray(feet + Vector3.UP * 0.2, feet - Vector3.UP * 1.0, player.collision_mask)
	if hit.is_empty():
		return "-"
	return "%s@%.3f" % [_body_label(hit.collider as Node), (hit.position as Vector3).y]


static func _body_label(node: Node) -> String:
	if node == null:
		return "?"
	return str(node.get_meta("derived_object_key", node.name))


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
	camera.far = ISLAND_CAMERA_FAR_M
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
