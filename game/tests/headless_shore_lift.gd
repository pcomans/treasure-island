extends SceneTree
## Walking off the island onto the ferry-plaza riprap lifts the stock player
## about 5 m straight up where they are, instead of putting them back at their
## last safe place, and leaves them floating at the jetpack's slow descent:
##   1. the lift keeps their x and z, puts them about 5 m above the higher of
##      their own height and the land edge below, with no velocity, airborne;
##   2. no second lift while they float; doing nothing, they drift back down
##      onto the wall and are lifted again there; the jetpack raises them
##      from the float with no lift on the way;
##   3. floating off over the water past the float radius puts them back above
##      the first lift, keeping their extra height;
##   4. holding the move input toward land brings them back onto walkable
##      ground with no further lift.
## Physics only (run with --headless), in the real generated world.

# What the player may end up standing on: the land, or the always-on street
# ground over it (as automated_route_qa.gd's checkpoints).
const GROUND_FEATURE_KINDS := ["land_ground", "street_kerb", "street_kerb_support"]
# 5 m inside the island outline (w26767313) north of the ferry pier, and the
# walk straight out across it onto the west segment's riprap
# (generated/world/shoreline.json). The lane from 12 m out to 20 m in is clear
# of buildings and street props.
const START_XZ := Vector2(-108.33, 799.77)
const OUT := Vector2(-0.882, 0.471)
const OWNER_LIFT_M := 5.0

var _failure := ""
var _finished := false
var _lifts: Array[Dictionary] = []


func _initialize() -> void:
	create_timer(150.0, true, false, true).timeout.connect(_on_timeout)
	call_deferred("_run")


func _run() -> void:
	var main := (load("res://game/scenes/main.tscn") as PackedScene).instantiate() as GameMain
	main.capture_mouse_on_ready = false
	# The default shadows, never a level saved in the shared user folder (main.gd).
	main.use_saved_settings = false
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var load_failures: Array[String] = []
	world.world_failed.connect(func(code: String, message: String, _keys: Array) -> void: load_failures.append("%s: %s" % [code, message]))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while not main.is_play_ready() and load_failures.is_empty() and Time.get_ticks_msec() - started < 90000:
		await process_frame
	if not _require(load_failures.is_empty() and main.is_play_ready(), "World did not reach play: %s" % [load_failures]):
		_finish(main)
		return
	paused = false
	_release()
	var recovery := player.get_recovery_controller()
	if not _require(is_equal_approx(recovery.boundary_lift_m, OWNER_LIFT_M), "The boundary lift must default to the owner's 5 m, not %s." % recovery.boundary_lift_m):
		_finish(main)
		return
	player.recovered.connect(func(cause: String, from_position: Vector3) -> void:
		_lifts.append({"cause": cause, "from": from_position, "to": player.global_position, "velocity": player.velocity, "tick": Engine.get_physics_frames()}))
	var boundary := world.get_boundary()
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var out3 := Vector3(OUT.x, 0.0, OUT.y).normalized()

	# The start: walkable ground inside the outline, the outline crossed within 8 m.
	var start_ground := _ground_below(player, Vector3(START_XZ.x, 300.0, START_XZ.y))
	if not _require(boundary.contains_position(Vector3(START_XZ.x, 0.0, START_XZ.y)) and not boundary.contains_position(Vector3(START_XZ.x, 0.0, START_XZ.y) + out3 * 8.0), "The start must lie inside the outline with the edge within 8 m.") \
	or not _require(_is_ground(start_ground), "The start has no walkable ground below it: %s." % [start_ground]):
		_finish(main)
		return
	player.set_gameplay_enabled(false)
	player.global_transform = Transform3D(Basis.IDENTITY, (start_ground.position as Vector3) + Vector3.UP * 0.3)
	player.velocity = Vector3.ZERO
	player.set_gameplay_enabled(true)
	# Settle, then stand long enough to become the last safe place (0.75 s),
	# which the old reset returned to.
	for _tick in 90:
		await physics_frame
	if not _require(player.is_on_floor() and _lifts.is_empty(), "The player did not settle at the start."):
		_finish(main)
		return
	var start := player.global_position

	# 1. Walk out over the outline until the edge lifts the player.
	_face(rig, out3)
	Input.action_press("move_forward")
	var last_inside := player.global_position
	for _tick in 240:
		await physics_frame
		if not _lifts.is_empty():
			break
		if boundary.contains_position(player.global_position):
			last_inside = player.global_position
	_release()
	if not _require(_lifts.size() == 1, "Walking out over the riprap did not lift the player once (lifts=%d, at %s)." % [_lifts.size(), player.global_position]):
		_finish(main)
		return
	var first: Dictionary = _lifts[0]
	var from1: Vector3 = first.from
	var to1: Vector3 = first.to
	var edge := _ground_below(player, last_inside + Vector3.UP)
	var edge_y := float((edge.position as Vector3).y) if not edge.is_empty() else -INF
	print("LIFT 1 cause=%s from=%s to=%s velocity=%s edge_y=%.3f last_inside=%s start=%s" % [first.cause, from1, to1, first.velocity, edge_y, last_inside, start])
	if not _require(first.cause == "outside_boundary" and not boundary.contains_position(from1), "The first lift was not the edge's: %s from %s." % [first.cause, from1]) \
	or not _require(_is_ground(edge) and last_inside.distance_to(from1) < 0.5, "The lift was not just past the land edge: last inside %s, from %s." % [last_inside, from1]) \
	or not _require(_same_xz(to1, from1), "The lift moved the player sideways: %s to %s." % [from1, to1]) \
	or not _require(absf(to1.y - (maxf(from1.y, edge_y) + OWNER_LIFT_M)) <= 0.01 and to1.y - from1.y >= OWNER_LIFT_M - 0.01, "The lift is not about 5 m above the player and the land edge: from y %.3f, edge %.3f, to y %.3f." % [from1.y, edge_y, to1.y]) \
	or not _require((first.velocity as Vector3) == Vector3.ZERO, "The lift kept velocity %s." % [first.velocity]) \
	or not _require(Vector2(to1.x - start.x, to1.z - start.z).length() > 4.0, "The lift went back toward the last safe place %s." % [start]):
		_finish(main)
		return

	# 2. Float with no input: airborne, slow descent, no second lift on the way
	# down (the cooldown alone is 0.5 s); then the same lift again at the wall.
	var previous_y := to1.y
	for tick in 36:
		await physics_frame
		var at := player.global_position
		if not _require(_lifts.size() == 1, "A second lift came %d ticks after the first, while floating." % (tick + 1)) \
		or not _require(not player.is_on_floor() and at.y <= previous_y + 0.0001 and _same_xz(at, to1), "The lifted player did not float straight down: %s on_floor=%s." % [at, player.is_on_floor()]):
			_finish(main)
			return
		previous_y = at.y
	if not _require(absf(player.velocity.y + player.jetpack_descent_speed_mps) <= 0.01, "The lifted player is not at the slow descent: %s." % [player.velocity]):
		_finish(main)
		return
	for _tick in 420:
		await physics_frame
		if _lifts.size() > 1:
			break
	if not _require(_lifts.size() == 2, "Doing nothing, the player was not lifted again after drifting down (at %s)." % [player.global_position]):
		_finish(main)
		return
	var second: Dictionary = _lifts[1]
	var from2: Vector3 = second.from
	var to2: Vector3 = second.to
	print("LIFT 2 after %d ticks from=%s to=%s" % [int(second.tick) - int(first.tick), from2, to2])
	if not _require(int(second.tick) - int(first.tick) >= 180, "The second lift came after only %d ticks, before the drift down." % (int(second.tick) - int(first.tick))) \
	or not _require(absf(from2.y - from1.y) <= 0.3 and Vector2(from2.x - to1.x, from2.z - to1.z).length() <= 0.5, "The second lift was not back down at the wall: from %s, first from %s." % [from2, from1]) \
	or not _require(_same_xz(to2, from2) and to2.y - from2.y >= OWNER_LIFT_M - 0.01 and to2.y - from2.y <= OWNER_LIFT_M + 0.5, "The second lift is not about 5 m straight up: %s to %s." % [from2, to2]):
		_finish(main)
		return

	# The jetpack works from the float: straight up, no lift on the way.
	Input.action_press("jetpack")
	for _tick in 30:
		await physics_frame
	_release()
	if not _require(_lifts.size() == 2 and player.global_position.y > to2.y + 1.0 and _same_xz(player.global_position, to2), "Jetpacking from the float did not rise straight up with no lift: %s lifts=%d." % [player.global_position, _lifts.size()]):
		_finish(main)
		return

	# 3. Run off over the water: past the float radius the player goes back
	# above the first lift, keeping the height the jetpack gave them.
	_face(rig, out3)
	Input.action_press("move_forward")
	Input.action_press("run")
	for _tick in 240:
		await physics_frame
		if _lifts.size() > 2:
			break
	_release()
	if not _require(_lifts.size() == 3, "Running off over the water did not bring the player back (at %s)." % [player.global_position]):
		_finish(main)
		return
	var third: Dictionary = _lifts[2]
	var from3: Vector3 = third.from
	var to3: Vector3 = third.to
	var floated := Vector2(from3.x - to1.x, from3.z - to1.z).length()
	print("LIFT 3 floated=%.3fm from=%s to=%s" % [floated, from3, to3])
	if not _require(floated > recovery.boundary_float_radius_m and floated < recovery.boundary_float_radius_m + 1.0, "The float-away lift came %.3f m from the first lift, not just past %.1f m." % [floated, recovery.boundary_float_radius_m]) \
	or not _require(_same_xz(to3, to1) and from3.y > to1.y and absf(to3.y - from3.y) <= 0.001, "The float-away lift did not return above the first lift %s at its own height: %s to %s." % [to1, from3, to3]):
		_finish(main)
		return

	# 4. Hold the move input toward land: back on walkable ground inside the
	# outline, with no further lift.
	_face(rig, -out3)
	Input.action_press("move_forward")
	var landed := false
	for _tick in 600:
		await physics_frame
		if not _require(_lifts.size() == 3, "Steering back to land lifted the player again at %s." % [player.global_position]):
			_finish(main)
			return
		if player.is_on_floor() and boundary.contains_position(player.global_position):
			landed = true
			break
	_release()
	for _tick in 60:
		await physics_frame
	var rest_at := player.global_position
	var below := _ground_below(player, rest_at + Vector3.UP)
	if not _require(landed and _lifts.size() == 3 and player.is_on_floor() and boundary.contains_position(rest_at), "Holding toward land did not bring the player back onto the island: %s on_floor=%s lifts=%d." % [rest_at, player.is_on_floor(), _lifts.size()]) \
	or not _require(_is_ground(below) and absf(rest_at.y - float((below.position as Vector3).y)) <= 0.1, "The player did not come back onto walkable ground: %s over %s." % [rest_at, below]):
		_finish(main)
		return
	print("LANDED at=%s ground=%s inland_of_first_lift=%.3fm" % [rest_at, str((below.collider as Node).get_parent().get_meta("feature_kind", "")), Vector2(rest_at.x - to1.x, rest_at.z - to1.z).length()])
	print("PASS: the edge lifted the stock player 5 m straight up where it stepped onto the riprap (no velocity, airborne, no second lift while floating), lifted it again once it drifted back down onto the wall, let the jetpack raise it from the float, brought it back above the first lift when it floated off over the water, and holding toward land returned it to walkable ground with no further lift")
	_finish(main)


## The first thing the player collides with straight below from, or {}.
func _ground_below(player: PlayerController, from: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, Vector3(from.x, -20.0, from.z), player.collision_mask, [player.get_rid()])
	query.hit_back_faces = false
	return player.get_world_3d().direct_space_state.intersect_ray(query)


func _is_ground(hit: Dictionary) -> bool:
	if hit.is_empty() or (hit.normal as Vector3).dot(Vector3.UP) < 0.7:
		return false
	var collider := hit.get("collider") as Node
	var record := collider.get_parent() if collider != null else null
	return record != null and str(record.get_meta("feature_kind", "")) in GROUND_FEATURE_KINDS


func _same_xz(a: Vector3, b: Vector3) -> bool:
	return Vector2(a.x - b.x, a.z - b.z).length() <= 0.001


## Turns the gameplay camera, and with it the walk, to face direction.
func _face(rig: PlayerCamera, direction: Vector3) -> void:
	rig.look_at(rig.global_position + direction, Vector3.UP)


func _release() -> void:
	for action: StringName in ["move_forward", "move_back", "move_left", "move_right", "run", "jetpack"]:
		Input.action_release(action)


func _require(condition: bool, message: String) -> bool:
	if not condition and _failure.is_empty():
		_failure = message
		push_error(message)
	return condition


func _finish(main: Node) -> void:
	if _finished:
		return
	_finished = true
	_release()
	if main != null and is_instance_valid(main):
		main.queue_free()
		await process_frame
	quit(0 if _failure.is_empty() else 1)


func _on_timeout() -> void:
	if not _finished:
		_finished = true
		_require(false, "The shore lift test did not finish within 150 s.")
		_release()
		quit(1)
