extends SceneTree
## The game's sound (owner, 2026-11-14), in the real generated world, headless on
## the Dummy driver (run with --headless --fixed-fps 60): every check reads the
## sound manager's request log (game/scripts/audio/sound.gd), never audio output.
## The takes are made here, in a folder of this run's own under user:// (short
## synthetic clips, two a sound, saved as Godot resources: the real audio never
## goes in Git), with a manifest in tools/fetch-sfx's form (sfx.json,
## tools/sfx/README.md "Levels"); the places are game/tests/shared/
## vehicle_cases.json's and the ditch by Mersea's.
##   1. with the folder filled: every sound has its takes; no audio player sits
##      anywhere but under the sound manager (none on the parked cars, nor on any
##      car); the wind and the bay's water fade in from play, the water's loud by
##      the shore; the menus click and the pause sounds;
##   2. on foot: steps (hard or soft) as the player walks, wet ones in the ditch by
##      Mersea's water (StandingWater); Space starts the jet, holds its roar and
##      the lid's rattle and lets it go with its tail; the landing thumps;
##   3. in a car: the doors and the engine's start getting in, then its loops,
##      climbing from idle with the throttle; the tyres skid in a handbrake turn;
##      getting out the engine stops, the doors sound and every loop stops; the
##      car crashing into a palm is a tree's crash, into a parked car a car's,
##      while the windrow's young gums bend with neither (theirs is the tier-2
##      bend); a bay of each fence material breaks with its own sound; a lamp
##      knocked over hits and then clangs on the ground; a car's splash; the ball
##      kicked softly and hard; a goal's net and confetti;
##   4. a synthetic pile-up (twenty crashes a frame for a second) keeps to the
##      crash sound's rate and voices; takes never repeat twice running; a play's
##      gain is the gain its manifest gives (0 dB where it gives none), lowered by
##      its strength and jitter, never raised;
##   5. the master volume and mute chosen on the options screen hold the Master
##      bus and are kept: a restart puts them on again;
##   6. that restart has an empty sound folder: the game loads and plays, every
##      request is silent and nothing plays, with no error.
## Its own settings file and folders, removed at the end. The first failure stops
## the run.

const MAIN_SCENE := "res://game/scenes/main.tscn"
const CASES_PATH := "res://game/tests/shared/vehicle_cases.json"
const OVERRIDES_PATH := "res://tools/config/terrain-overrides.json"
const DITCH_SITE := "mersea_ditch_promenade"
## The manifest gain given to one sound, to see it come through.
const LEVEL_ID := &"lamp_hit"
const LEVEL_DB := -9.5
const PILEUP_ID := &"car_impact_heavy"

var _failure := ""
var _main: GameMain
var _sound: Sound
var _player: PlayerController
var _vehicles: VehicleManager
var _cases: Dictionary = {}
var _settings_file := ""
var _folder := ""
var _empty_folder := ""
var _summary: Array[String] = []


func _initialize() -> void:
	create_timer(560.0, true, false, true).timeout.connect(func() -> void: _finish("The sound contract timed out."))
	_settings_file = "user://test-sound-%d.cfg" % OS.get_process_id()
	_folder = "user://test-sfx-%d" % OS.get_process_id()
	_empty_folder = "user://test-sfx-empty-%d" % OS.get_process_id()
	ShadowQuality.settings_path = _settings_file
	DirAccess.remove_absolute(_settings_file)
	call_deferred("_run")


func _run() -> void:
	_cases = JSON.parse_string(FileAccess.get_file_as_string(CASES_PATH))
	if not _require(_cases is Dictionary and not _cases.is_empty(), "%s does not read." % CASES_PATH):
		return _finish()
	if not _write_takes():
		return _finish()
	Sound.manifest_path = _folder.path_join("sfx.json")
	if not await _load_main():
		return _finish()
	for check: Callable in [_check_startup, _check_beds_and_menus, _check_on_foot, _check_ditch, _check_car, _check_hits, _check_world_sounds, _check_limits, _check_settings]:
		if not await check.call():
			return _finish()
	# The restart, with an empty sound folder: the kept settings, and silence.
	Sound.manifest_path = _empty_folder.path_join("sfx.json")
	if not await _load_main():
		return _finish()
	if not await _check_restart_silent():
		return _finish()
	print("PASS: sound: %s" % "; ".join(_summary))
	_finish()


# --- The takes and the world.

## Two short synthetic takes a sound in this run's folder, and their manifest:
## LEVEL_ID's gain LEVEL_DB, every other sound with no gain.
func _write_takes() -> bool:
	DirAccess.make_dir_recursive_absolute(_folder)
	var catalog := Sound.load_catalog()
	var sounds := {}
	var seed := 1
	for id: StringName in catalog:
		var loop := bool((catalog[id] as Dictionary).get("loop", false))
		var takes: Array[String] = []
		for take in 2:
			var name := "%s_%02d.tres" % [id, take + 1]
			if ResourceSaver.save(_clip(0.5 if loop else 0.2, seed), _folder.path_join(name)) != OK:
				return _require(false, "Could not save a synthetic take in %s." % _folder)
			seed += 1
			takes.append(name)
		var entry := {"row": String(id), "loop": loop, "channels": 1, "takes": takes}
		if id == LEVEL_ID:
			entry["gain_db"] = LEVEL_DB
		sounds[String(id)] = entry
	var file := FileAccess.open(_folder.path_join("sfx.json"), FileAccess.WRITE)
	if file == null:
		return _require(false, "Could not write the synthetic manifest.")
	file.store_string(JSON.stringify({"schema_version": "ti.sfx-manifest/1", "sounds": sounds}, "  "))
	file.close()
	return true


## A quiet noise clip of this length, mono 16-bit.
static func _clip(seconds: float, seed: int) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	var frames := int(seconds * wav.mix_rate)
	var data := PackedByteArray()
	data.resize(frames * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	for frame in frames:
		data.encode_s16(frame * 2, rng.randi_range(-2000, 2000))
	wav.data = data
	return wav


## The main scene, freed before if there was one, to play.
func _load_main() -> bool:
	if is_instance_valid(_main):
		_release()
		_main.queue_free()
		await process_frame
		await process_frame
	_main = (load(MAIN_SCENE) as PackedScene).instantiate() as GameMain
	_main.capture_mouse_on_ready = false
	# This run's own settings file (ShadowQuality.settings_path), kept across the restart.
	_main.use_saved_settings = true
	var failures: Array[String] = []
	(_main.get_node("WorldRoot") as WorldLoader).world_failed.connect(func(code: String, message: String, _keys: Array) -> void: failures.append("%s: %s" % [code, message]))
	root.add_child(_main)
	var started := Time.get_ticks_msec()
	while not _main.is_play_ready() and failures.is_empty() and Time.get_ticks_msec() - started < 240000:
		await process_frame
	if not _require(_main.is_play_ready(), "The world did not reach play: %s" % [failures]):
		return false
	paused = false
	_sound = _main.sound
	_player = _main.player
	_vehicles = _main.vehicles
	return _require(_sound != null and Sound.current == _sound and _vehicles != null, "main made no sound manager.")


# --- 1. Startup, the beds and the menus.

func _check_startup() -> bool:
	var catalog := Sound.load_catalog()
	for id: StringName in catalog:
		if not _require(_sound.takes_of(id) == 2, "%s has %d takes, not the manifest's 2." % [id, _sound.takes_of(id)]):
			return false
	var strays := PackedStringArray()
	for node: Node in root.find_children("*", "", true, false):
		if (node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D) and not _sound.is_ancestor_of(node):
			strays.append(str(node.get_path()))
	if not _require(strays.is_empty(), "Audio players outside the sound manager (none may sit on a parked car or any car): %s" % strays):
		return false
	var cars := 0
	for id: String in _vehicles.swappable_ids():
		if _vehicles.live_node(id) == null:
			cars += 1
	_summary.append("%d sounds with their takes, every player under the sound manager and none on the %d parked rows" % [catalog.size(), cars])
	return true


func _check_beds_and_menus() -> bool:
	var bay: Dictionary = _cases.bay
	if not await _stand_player(Vector2(bay.start_xz[0], bay.start_xz[1])):
		return false
	await _frames(150)
	var wind := _sound.requested(Sound.WIND_BED).any(func(entry: Dictionary) -> bool: return entry.result == "loop_start")
	var water := _sound.requested(Sound.WATER_BED).any(func(entry: Dictionary) -> bool: return entry.result == "loop_start")
	if not _require(wind and water and _sound.bed_level(Sound.WATER_BED) > 0.5 and _sound.bed_level(Sound.WIND_BED) > 0.3, "By the west shore the wind and the bay's water must have faded in (wind %s at %.2f, water %s at %.2f)." % [wind, _sound.bed_level(Sound.WIND_BED), water, _sound.bed_level(Sound.WATER_BED)]):
		return false
	var mark := Engine.get_process_frames()
	_main._set_paused(true)
	await process_frame
	var hud := _main.hud
	hud.options_button.pressed.emit()
	await process_frame
	OS.delay_msec(150)
	hud.options_back_button.pressed.emit()
	OS.delay_msec(150)
	_main._set_paused(false)
	await process_frame
	var clicks := _played(&"ui_click", mark)
	var pauses := _played(&"ui_pause", mark)
	if not _require(clicks >= 2 and pauses == 2, "Options and Back must click (%d) and the pause and Resume must sound (%d of 2)." % [clicks, pauses]):
		return false
	_summary.append("the wind and the bay's water fade in from play (water %.2f by the west shore), the menus click and the pause sounds" % _sound.bed_level(Sound.WATER_BED))
	return true


# --- 2. On foot.

func _check_on_foot() -> bool:
	var spot: Dictionary = _cases.on_foot
	if not await _stand_player(Vector2(spot.at_xz[0], spot.at_xz[1])):
		return false
	var mark := Engine.get_process_frames()
	Input.action_press("move_forward")
	await _ticks(90)
	_release()
	var steps := _played(&"footstep_hard", mark) + _played(&"footstep_soft", mark)
	if not _require(steps >= 3, "Walking 1.5 s must step at least 3 times (stepped %d)." % steps):
		return false
	mark = Engine.get_process_frames()
	Input.action_press("jetpack")
	await _ticks(30)
	var holding := _sound.loop_playing(&"jet_loop", _avatar()) and _sound.loop_playing(&"chest_rattle_loop", _avatar())
	Input.action_release("jetpack")
	var landed := false
	for _tick in 240:
		await physics_frame
		if _played(&"landing", mark) > 0:
			landed = true
			break
	await _ticks(30)
	var started := _played(&"jet_start", mark)
	var stopped := _played(&"jet_stop", mark)
	var roared := _sound.requested(&"jet_loop").any(func(entry: Dictionary) -> bool: return entry.result == "loop_start" and int(entry.frame) >= mark)
	if not _require(started == 1 and roared and holding and stopped == 1 and landed, "Space must start the jet once (%d), hold its roar and rattle (started %s, both playing %s), let it go with its tail (%d) and the landing must thump (%s)." % [started, roared, holding, stopped, landed]):
		return false
	_summary.append("%d steps walking 1.5 s; the jet's start, roar, rattle and tail; the landing" % steps)
	return true


## The ditch by Mersea: where the land's ground cover draws its shallow water, the
## player's steps are wet.
func _check_ditch() -> bool:
	var spot := _ditch_water()
	if not _require(spot.is_finite(), "No standing water found in the ditch by Mersea (%s in %s): StandingWater and ground_cover.gdshader's marsh disagree, or the ditch moved." % [DITCH_SITE, OVERRIDES_PATH]):
		return false
	if not await _stand_player(Vector2(spot.x, spot.z)):
		return false
	var mark := Engine.get_process_frames()
	# A slow walk (the touch stick's share of the walk speed), so it stays in the water.
	_player.touch_input_vector = Vector2(0.0, -0.25)
	await _ticks(120)
	_player.touch_input_vector = Vector2.ZERO
	var wet := _played(&"footstep_water", mark)
	if not _require(wet >= 1, "Walking in the ditch's water at %s must make wet steps (made %d; hard %d, soft %d)." % [spot, wet, _played(&"footstep_hard", mark), _played(&"footstep_soft", mark)]):
		return false
	_summary.append("%d wet steps in the ditch by Mersea at (%.1f, %.1f)" % [wet, spot.x, spot.z])
	return true


## A spot in the ditch's site (its terrain override's scope) where the ground's
## drawn water stands all round, at least 1.5 m out, or Vector3.INF.
func _ditch_water() -> Vector3:
	var overrides: Variant = JSON.parse_string(FileAccess.get_file_as_string(OVERRIDES_PATH))
	var low := Vector2.INF
	var high := -Vector2.INF
	var sites: Array = (overrides as Dictionary).get("sites", []) if overrides is Dictionary else []
	for site: Dictionary in sites:
		if site.get("id") != DITCH_SITE:
			continue
		for polygon: Array in (site.scope as Dictionary).get("add_xz", []):
			for point: Array in polygon:
				low = low.min(Vector2(point[0], point[1]))
				high = high.max(Vector2(point[0], point[1]))
	if not low.is_finite():
		return Vector3.INF
	var best := Vector3.INF
	var best_pool := 0.0
	var space := _player.get_world_3d().direct_space_state
	var x := low.x
	while x <= high.x:
		var z := low.y
		while z <= high.y:
			var here := _water_at(space, Vector2(x, z))
			if here.y >= 0.9:
				var least := here.y
				for step in 8:
					least = minf(least, _water_at(space, Vector2(x, z) + Vector2.from_angle(step * TAU / 8.0) * 1.5).y)
				if least > best_pool:
					best_pool = least
					best = Vector3(x, 0.0, z)
			z += 2.0
		x += 2.0
	return best if best_pool >= 0.6 else Vector3.INF


## (ground height, drawn water) at xz on the land.
func _water_at(space: PhysicsDirectSpaceState3D, xz: Vector2) -> Vector2:
	var query := PhysicsRayQueryParameters3D.create(Vector3(xz.x, 80.0, xz.y), Vector3(xz.x, -20.0, xz.y), _player.collision_mask, [_player.get_rid()])
	var hit := space.intersect_ray(query)
	if hit.is_empty():
		return Vector2(0.0, 0.0)
	return Vector2((hit.position as Vector3).y, StandingWater.pool(hit.collider, hit.position))


# --- 3. In a car.

func _check_car() -> bool:
	var route: Dictionary = _cases.route
	var points: Array = route.points_xz
	var start := Vector2(points[0][0], points[0][1])
	var heading := (Vector2(points[1][0], points[1][1]) - start).normalized()
	var mark := Engine.get_process_frames()
	var car := await _drive_from(start, heading)
	if car == null:
		return false
	await _ticks(60)
	var getting_in := [_played(&"car_door_open", mark), _played(&"car_door_close", mark), _played(&"car_engine_start", mark)]
	var idle := _sound.loop_playing(CarSound.IDLE, car)
	if not _require(getting_in == [1, 1, 1] and idle, "Getting in must open and shut the door and start the engine, once each (%s: %s), and its idle loop must run (%s)." % [getting_in, _results([&"car_door_open", &"car_door_close", &"car_engine_start"], mark), idle]):
		return false
	Input.action_press("move_forward")
	await _ticks(180)
	var rev := _vehicles.car_sound().rev()
	var climbing := _sound.loop_playing(CarSound.LOW, car) and _sound.loop_playing(CarSound.HIGH, car)
	Input.action_press("handbrake")
	Input.action_press("move_right")
	await _ticks(50)
	var skidding := _sound.loop_playing(CarSound.SKID, car)
	_release()
	Input.action_press("move_back")
	for _tick in 240:
		await physics_frame
		if car.linear_velocity.length() < 0.5:
			break
	_release()
	if not _require(rev > 0.4 and climbing and skidding, "At speed the engine's rev must climb past 0.4 (%.2f) into its low and high loops (%s), and a handbrake turn must skid (%s)." % [rev, climbing, skidding]):
		return false
	mark = Engine.get_process_frames()
	_vehicles.exit_car()
	await _ticks(70)
	var getting_out := [_played(&"car_engine_stop", mark), _played(&"car_door_open", mark), _played(&"car_door_close", mark)]
	var quiet := not (_sound.loop_playing(CarSound.IDLE, car) or _sound.loop_playing(CarSound.LOW, car) or _sound.loop_playing(CarSound.HIGH, car) or _sound.loop_playing(CarSound.SKID, car))
	if not _require(getting_out == [1, 1, 1] and quiet, "Getting out must stop the engine and open and shut the door, once each (%s: %s), and every engine and tyre loop must stop (%s)." % [getting_out, _results([&"car_engine_stop", &"car_door_open", &"car_door_close"], mark), quiet]):
		return false
	_summary.append("getting in, the engine climbing to a rev of %.2f, a skid, getting out" % rev)
	return true


func _check_hits() -> bool:
	# A palm's trunk stops the car: a tree's knock.
	var tree: Dictionary = _cases.tree
	var mark := Engine.get_process_frames()
	var car := await _drive_from(Vector2(tree.start_xz[0], tree.start_xz[1]), Vector2(tree.heading_xz[0], tree.heading_xz[1]))
	if car == null:
		return false
	var trees := await _press_until(&"car_tree_impact", mark, 360)
	var crashes := _played(&"car_impact_light", mark) + _played(&"car_impact_heavy", mark)
	if not _require(trees >= 1 and crashes == 0, "Driven into a palm the car must knock as on a tree (%d), not as on anything else (%d)." % [trees, crashes]):
		return false
	# A parked car across the road: a crash.
	var shove: Dictionary = _cases.shove
	mark = Engine.get_process_frames()
	car = await _drive_from(Vector2(shove.start_xz[0], shove.start_xz[1]), Vector2(shove.heading_xz[0], shove.heading_xz[1]))
	if car == null:
		return false
	await _press_until(&"car_impact_light", mark, 360, &"car_impact_heavy")
	crashes = _played(&"car_impact_light", mark) + _played(&"car_impact_heavy", mark)
	if not _require(crashes >= 1 and _played(&"car_tree_impact", mark) == 0, "Driven into a parked car the car must crash (%d), with no tree's knock (%d)." % [crashes, _played(&"car_tree_impact", mark)]):
		return false
	# The windrow's young gums bend out of the way: no tree's crash, no car's (the
	# bend's own sound is tier 2, tools/sfx/prompts.json tree_bend).
	var small: Dictionary = _cases.small_trees
	var bender := _vehicles.tree_bender()
	var first: Vector3 = bender.tree(str(small.first)).foot
	var last: Vector3 = bender.tree(str(small.last)).foot
	var along := Vector2(last.x - first.x, last.z - first.z).normalized()
	mark = Engine.get_process_frames()
	car = await _drive_from(Vector2(first.x, first.z) - along * float(small.run_up_m), along)
	if car == null:
		return false
	# Along the windrow's line, as the vehicle contract drives it: toward a point on
	# it 8 m ahead of the car, at a park's pace (the pile-up test's 12 m/s).
	var a := Vector2(first.x, first.z)
	var line_m := Vector2(last.x - first.x, last.z - first.z).length()
	Input.action_press("move_forward")
	for _tick in 600:
		_steer_toward(car, a + along * ((Vector2(car.global_position.x, car.global_position.z) - a).dot(along) + 8.0))
		if car.linear_velocity.length() > 12.0:
			Input.action_release("move_forward")
		elif not Input.is_action_pressed("move_forward"):
			Input.action_press("move_forward")
		await physics_frame
		if (Vector2(car.global_position.x, car.global_position.z) - a).dot(along) > line_m + car.length_m:
			break
	_release()
	var bent := bender.bending_ids().filter(func(id: String) -> bool: return bender.most_lean_degrees(id) > 5.0).size()
	# The hits along the run (the cars shoved before may still knock about elsewhere).
	var from := a - along * float(small.run_up_m)
	var hits := _sound.requests.filter(func(entry: Dictionary) -> bool:
		if int(entry.frame) < mark or not str(entry.id) in ["car_tree_impact", "car_impact_light", "car_impact_heavy"]:
			return false
		var at: Vector3 = entry.at
		return Geometry2D.get_closest_point_to_segment(Vector2(at.x, at.z), from, a + along * (line_m + 10.0)).distance_to(Vector2(at.x, at.z)) < 8.0)
	if not _require(bent >= 4 and hits.is_empty(), "Through the windrow of young gums (%d bent) the car must not crash, into a tree or anything else (%s; the car ended at %s)." % [bent, hits, car.global_position]):
		return false
	_summary.append("a palm crashes as a tree, a parked car as a car (%d), and %d young gums bend with neither" % [crashes, bent])
	return await _stop()


func _check_world_sounds() -> bool:
	# A bay of each fence material the world has.
	var breaker := _vehicles.fence_breaker()
	var tested := {}
	for body: Node in _main.world_root.street_detail_layer("fences").find_children("Collision", "StaticBody3D", true, false):
		var group := body.get_parent() as Node3D
		var type := str(group.get_meta("fence_type", "")) if group != null else ""
		var id: StringName = breaker.BREAK_SOUNDS.get(type, &"")
		if id == &"" or tested.has(id):
			continue
		for shape: Node in body.get_children():
			if shape is CollisionShape3D and not (shape as CollisionShape3D).disabled and str(shape.get_meta("fence_bay", "")) != "":
				var bay_mark := Engine.get_process_frames()
				breaker.break_bay(group, shape as CollisionShape3D, Vector3(8.0, 0.0, 0.0))
				tested[id] = _asked(id, bay_mark)
				await _ticks(8)
				break
	if not _require(tested.size() >= 3 and tested.values().all(func(count: int) -> bool: return count == 1), "Breaking a bay of each fence material must sound its material once (%s)." % [tested]):
		return false
	# A street lamp knocked over, driven at as the vehicle contract does: its hit,
	# then its head on the ground.
	var lamps := _vehicles.furniture_breaker()
	var cases_lamps: Dictionary = _cases.lamps
	var lamp := str(cases_lamps.fell)
	var foot: Vector3 = lamps.pole(lamp).get("foot", Vector3.INF)
	if not _require(foot.is_finite(), "%s is not a lamp a car knocks over in this world." % lamp):
		return false
	var lamp_heading := Vector2(cases_lamps.fell_heading_xz[0], cases_lamps.fell_heading_xz[1]).normalized()
	var mark := Engine.get_process_frames()
	if await _drive_from(Vector2(foot.x, foot.z) - lamp_heading * float(cases_lamps.run_up_m), lamp_heading) == null:
		return false
	Input.action_press("move_forward")
	for _tick in 300:
		await physics_frame
		if lamps.is_felled(lamp):
			break
	_release()
	var hit := _asked(&"lamp_hit", mark)
	var fell := false
	for _tick in 360:
		await physics_frame
		if _asked(&"lamp_fall", mark) > 0:
			fell = true
			break
	await _stop()
	if not _require(lamps.is_felled(lamp) and hit == 1 and fell, "A lamp knocked over (%s) must hit (%d) and then clang on the ground (%s)." % [lamps.is_felled(lamp), hit, fell]):
		return false
	# A car's splash.
	var car := _vehicles.live_node(str(_cases.enter.car)) as DrivableCar
	mark = Engine.get_process_frames()
	car.splashed.emit(car.global_position, 9.0)
	await _ticks(2)
	# The ball: a soft kick walking, a hard one running, and a goal.
	var ball := get_first_node_in_group(SoccerBall.GROUP) as SoccerBall
	if not _require(ball != null and not ball.goals.is_empty(), "No ball with goals in the world."):
		return false
	var kicks := []
	if _vehicles.is_driving():
		_vehicles.force_exit()
	for speed: float in [4.0, 20.0]:
		ball.place(ball.spot.origin)
		await _ticks(12)
		_player.set_gameplay_enabled(false)
		_player.global_position = ball.global_position - Vector3(0.42, ball.global_position.y - ball.spot.origin.y + 0.11, 0.0)
		_player.velocity = Vector3(speed, 0.0, 0.0)
		var kick_mark := Engine.get_process_frames()
		ball._push_from(_player)
		kicks.append([_asked(&"ball_kick_soft", kick_mark), _asked(&"ball_kick_hard", kick_mark)])
		_player.velocity = Vector3.ZERO
		await _ticks(12)
	_player.set_gameplay_enabled(true)
	var goal_mark := Engine.get_process_frames()
	ball._score(ball.goals[0])
	var goal := [_asked(&"goal_net", goal_mark), _asked(&"goal_confetti", goal_mark)]
	if not _require(_asked(&"car_splash", mark) == 1 and kicks == [[1, 0], [0, 1]] and goal == [1, 1], "A splash (%d), a soft then a hard kick ([[soft, hard], ...] %s) and a goal's net and confetti (%s) must each sound once." % [_asked(&"car_splash", mark), kicks, goal]):
		return false
	_summary.append("a bay of each fence material breaks with its own sound (%s); a lamp hits and clangs down; a splash; a soft and a hard kick; a goal" % ", ".join(PackedStringArray(tested.keys())))
	return true


# --- 4. Limits, takes and levels.

func _check_limits() -> bool:
	var settings: Dictionary = Sound.load_catalog()[PILEUP_ID]
	var listener := root.get_camera_3d().global_position
	var most := 0
	var results := {}
	# The manager's own request (as Sound.play makes it), whose result is counted
	# here: the log keeps only the last REQUEST_LOG_SIZE.
	for _frame in 60:
		for index in 20:
			var result := str(_sound.request(PILEUP_ID, listener + Vector3(index, 0.0, 0.0), 1.0, 1.0).result)
			results[result] = int(results.get(result, 0)) + 1
		most = maxi(most, _sound.voices_of(PILEUP_ID))
		await process_frame
	var played := int(results.get("played", 0))
	var limited := int(results.get("limited", 0))
	var cap := ceili(1.0 / float(settings.min_gap_s)) + 1
	if not _require(played >= 2 and played <= cap and played + limited == 1200 and most <= int(settings.voices), "Twenty crashes a frame for a second must play at most %d and drop the rest (%s) and never sound more than %d at once (%d)." % [cap, results, settings.voices, most]):
		return false
	# Takes never repeat twice running.
	var mark := Engine.get_process_frames()
	for _step in 16:
		Sound.play(&"footstep_hard", listener, 1.0)
		await _frames(4)
	var takes := _sound.requested(&"footstep_hard").filter(func(entry: Dictionary) -> bool: return int(entry.frame) >= mark and entry.result == "played").map(func(entry: Dictionary) -> int: return int(entry.take))
	var repeats := 0
	for index in range(1, takes.size()):
		if takes[index] == takes[index - 1]:
			repeats += 1
	if not _require(takes.size() >= 12 and repeats == 0, "Steps must never play the same take twice running (%d repeats in %s)." % [repeats, takes]):
		return false
	# A play's gain: the manifest's gain, lowered by the strength and the jitter,
	# never raised (a strength above 1 is held at 1).
	mark = Engine.get_process_frames()
	await _frames(12)
	Sound.play(LEVEL_ID, listener, 0.5)
	await _frames(12)
	Sound.play(LEVEL_ID, listener, 3.0)
	await _frames(12)
	Sound.play(&"lamp_fall", listener, 1.0)
	var leveled: Array = _sound.requested(LEVEL_ID).filter(func(entry: Dictionary) -> bool: return int(entry.frame) >= mark and entry.result == "played")
	var plain: Array = _sound.requested(&"lamp_fall").filter(func(entry: Dictionary) -> bool: return int(entry.frame) >= mark and entry.result == "played")
	var jitter := float((Sound.load_catalog()[LEVEL_ID] as Dictionary).get("gain_jitter_db", 0.0))
	var half: Dictionary = leveled[0] if leveled.size() == 2 else {}
	var over: Dictionary = leveled[1] if leveled.size() == 2 else {}
	var half_db := LEVEL_DB + linear_to_db(0.5)
	if not _require(not half.is_empty() and is_equal_approx(float(half.level_db), LEVEL_DB) and is_equal_approx(float(half.gain_db), linear_to_db(0.5)) \
			and float(half.volume_db) <= half_db + 0.001 and float(half.volume_db) >= half_db - jitter - 0.001, "%s's play at half strength must take the manifest's %.1f dB and %.1f dB less, lowered by at most %.1f dB of jitter (%s)." % [LEVEL_ID, LEVEL_DB, -linear_to_db(0.5), jitter, half]) \
	or not _require(not over.is_empty() and float(over.volume_db) <= LEVEL_DB + 0.001, "A strength above 1 must not raise %s above its manifest's %.1f dB (%s)." % [LEVEL_ID, LEVEL_DB, over]) \
	or not _require(not plain.is_empty() and is_zero_approx(float((plain[0] as Dictionary).level_db)) and float((plain[0] as Dictionary).volume_db) <= 0.001, "A sound its manifest gives no gain must play at 0 dB at most (%s)." % [plain]):
		return false
	_summary.append("a synthetic pile-up of 1200 crashes in a second plays %d, at most %d at once; takes never repeat; %s plays at its manifest's %.1f dB, lowered, never raised" % [played, most, LEVEL_ID, LEVEL_DB])
	return true


# --- 5. The volume and mute.

func _check_settings() -> bool:
	var hud := _main.hud
	hud.sound_volume.value = 40.0
	hud.sound_mute.button_pressed = true
	await process_frame
	var master := AudioServer.get_bus_index(&"Master")
	var kept := Sound.saved_settings()
	if not _require(is_equal_approx(AudioServer.get_bus_volume_linear(master), 0.4) and AudioServer.is_bus_mute(master) and is_equal_approx(float(kept.volume), 0.4) and bool(kept.muted), "The options screen's volume (40) and mute must hold the Master bus (%.2f, muted %s) and be kept (%s)." % [AudioServer.get_bus_volume_linear(master), AudioServer.is_bus_mute(master), kept]):
		return false
	return true


# --- 6. The restart: kept settings, an empty folder, silence.

func _check_restart_silent() -> bool:
	var master := AudioServer.get_bus_index(&"Master")
	var hud := _main.hud
	if not _require(is_equal_approx(_sound.volume, 0.4) and _sound.muted and is_equal_approx(AudioServer.get_bus_volume_linear(master), 0.4) and AudioServer.is_bus_mute(master) \
			and is_equal_approx(hud.sound_volume.value, 40.0) and hud.sound_mute.button_pressed, "After a restart the kept volume (0.4) and mute must be on again (volume %.2f, muted %s, slider %.0f, mute shown %s)." % [_sound.volume, _sound.muted, hud.sound_volume.value, hud.sound_mute.button_pressed]):
		return false
	for id: StringName in Sound.load_catalog():
		if not _require(_sound.takes_of(id) == 0, "With an empty sound folder %s still has takes." % id):
			return false
	var mark := Engine.get_process_frames()
	var spot: Dictionary = _cases.on_foot
	if not await _stand_player(Vector2(spot.at_xz[0], spot.at_xz[1])):
		return false
	Input.action_press("move_forward")
	await _ticks(60)
	_release()
	Input.action_press("jetpack")
	await _ticks(20)
	_release()
	await _ticks(120)
	var route: Dictionary = _cases.route
	var points: Array = route.points_xz
	var car := await _drive_from(Vector2(points[0][0], points[0][1]), (Vector2(points[1][0], points[1][1]) - Vector2(points[0][0], points[0][1])).normalized())
	if car == null:
		return false
	Input.action_press("move_forward")
	await _ticks(60)
	_release()
	await _stop()
	_vehicles.exit_car()
	await _ticks(70)
	var asked := _sound.requests.filter(func(entry: Dictionary) -> bool: return int(entry.frame) >= mark)
	var sounded := asked.filter(func(entry: Dictionary) -> bool: return entry.result in ["played", "loop_start"])
	var ids := {}
	for entry: Dictionary in asked:
		ids[str(entry.id)] = true
	var playing := 0
	for node: Node in _sound.find_children("*", "", true, false):
		if (node is AudioStreamPlayer or node is AudioStreamPlayer3D) and bool(node.get("playing")):
			playing += 1
	if not _require(asked.size() >= 10 and sounded.is_empty() and playing == 0, "With an empty sound folder the game must still ask for its sounds (%d asks) and play none (%d played, %d players playing)." % [asked.size(), sounded.size(), playing]):
		return false
	_summary.append("after a restart the kept volume and mute are on; with an empty sound folder the game plays, makes %d requests of %d sounds (%s) and plays none" % [asked.size(), ids.size(), ", ".join(PackedStringArray(ids.keys()))])
	return true


# --- Helpers.

func _avatar() -> Node:
	return _player.get_node("AvatarPivot/ChestAvatar")


## How many plays of id were played since frame mark.
func _played(id: StringName, mark: int) -> int:
	return _sound.requested(id).filter(func(entry: Dictionary) -> bool: return int(entry.frame) >= mark and entry.result == "played").size()


## What came of the requests for these ids since frame mark (for failure messages).
func _results(ids: Array, mark: int) -> Dictionary:
	var found := {}
	for id: StringName in ids:
		found[String(id)] = _sound.requested(id).filter(func(entry: Dictionary) -> bool: return int(entry.frame) >= mark).map(func(entry: Dictionary) -> String: return str(entry.result))
	return found


## How many plays of id were asked for since frame mark and played, or not only
## because they were too far from the listener (a world sound set off by a direct
## call somewhere else on the island).
func _asked(id: StringName, mark: int) -> int:
	return _sound.requested(id).filter(func(entry: Dictionary) -> bool: return int(entry.frame) >= mark and entry.result in ["played", "far"]).size()


## Presses W until id (or also) has played since mark, at most limit ticks.
func _press_until(id: StringName, mark: int, limit: int, also: StringName = &"") -> int:
	Input.action_press("move_forward")
	var count := 0
	for _tick in limit:
		await physics_frame
		count = _played(id, mark) + (_played(also, mark) if also != &"" else 0)
		if count > 0:
			break
	_release()
	await _stop()
	return count


## Stops the driven car on its brakes.
func _stop() -> bool:
	var car := _vehicles.active_car()
	_release()
	if car == null:
		return true
	Input.action_press("move_back")
	for _tick in 240:
		await physics_frame
		if car.linear_velocity.length() < 0.5:
			break
	_release()
	return true


## The vehicle contract's place for getting in: its car on the ground at xz facing
## heading, the player in it, settled. The player stands there first, as one walks
## up to a car, so the doors sound by the camera, not from across the island.
func _drive_from(xz: Vector2, heading: Vector2) -> DrivableCar:
	if not await _stand_player(xz - heading * 4.0):
		return null
	var id := str(_cases.enter.car)
	var error := _vehicles.drive_from(id, xz, heading)
	if not _require(error == "", "Could not start a drive at %s: %s." % [xz, error]):
		return null
	await _ticks(45)
	return _vehicles.active_car()


## Steering keys toward a point (as the vehicle contract's crude driver).
func _steer_toward(car: DrivableCar, target: Vector2) -> void:
	var forward := -car.global_transform.basis.z
	var to := Vector2(target.x - car.global_position.x, target.y - car.global_position.z)
	var angle := Vector2(forward.x, forward.z).angle_to(to)
	Input.action_release("move_left")
	Input.action_release("move_right")
	if angle > deg_to_rad(4.0):
		Input.action_press("move_right")
	elif angle < deg_to_rad(-4.0):
		Input.action_press("move_left")


## The stock player standing still on the ground at xz, out of any car, walking.
func _stand_player(xz: Vector2) -> bool:
	_release()
	if _vehicles.is_driving():
		_vehicles.force_exit()
	_player.set_gameplay_enabled(false)
	var query := PhysicsRayQueryParameters3D.create(Vector3(xz.x, 200.0, xz.y), Vector3(xz.x, -50.0, xz.y), _player.collision_mask, [_player.get_rid()])
	var hit := _player.get_world_3d().direct_space_state.intersect_ray(query)
	if not _require(not hit.is_empty(), "No ground under %s." % xz):
		return false
	_player.global_transform = Transform3D(Basis.IDENTITY, (hit.position as Vector3) + Vector3.UP * 0.3)
	_player.velocity = Vector3.ZERO
	_player.set_gameplay_enabled(true)
	for _tick in 90:
		await physics_frame
		if _player.is_on_floor() and _player.velocity.length() < 0.05:
			return true
	return _require(false, "The player did not settle at %s." % xz)


func _release() -> void:
	for action: StringName in GameMain.GAMEPLAY_ACTIONS:
		Input.action_release(action)
	if _player != null:
		_player.touch_input_vector = Vector2.ZERO


func _ticks(count: int) -> void:
	for _tick in count:
		await physics_frame


func _frames(count: int) -> void:
	for _frame in count:
		await process_frame


func _require(condition: bool, message: String) -> bool:
	if not condition and _failure == "":
		_failure = message
	return condition


func _finish(timeout_message := "") -> void:
	if timeout_message != "" and _failure == "":
		_failure = timeout_message
	_release()
	if is_instance_valid(_main):
		_main.free()
	for folder: String in [_folder, _empty_folder]:
		if DirAccess.dir_exists_absolute(folder):
			for file: String in DirAccess.get_files_at(folder):
				DirAccess.remove_absolute(folder.path_join(file))
			DirAccess.remove_absolute(folder)
	DirAccess.remove_absolute(_settings_file)
	Sound.manifest_path = Sound.DEFAULT_MANIFEST_PATH
	if _failure != "":
		push_error("FAIL: " + _failure)
		print("FAIL: " + _failure)
		quit(1)
	else:
		quit(0)
