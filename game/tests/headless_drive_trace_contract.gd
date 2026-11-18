extends SceneTree
## The drive trace (game/scripts/debug/drive_trace.gd) stays out of normal play,
## headless:
##   - a run without --trace-drive is not the trace (GameMain.drive_trace_requested;
##     on the web the same test reads ?trace=drive, which tools/check_web_trace.mjs
##     checks on the page's side);
##   - main.tscn made and started as in play has no DriveTrace node, has not loaded
##     the trace's script, and no frame or tree signal calls into it: the trace costs
##     normal play nothing;
##   - the trace's script loads and makes a node, which records nothing and drives
##     nothing until play has started (it waits on its first step, its frame and node
##     signals not yet connected);
##   - its whole drive follows the whole route, and route=corner the part of it that
##     passes the Mersea corner, from Bruton Street's start.
## The drive itself and its records are checked by running it (natively with
## --trace-drive --trace-out=FILE, and in browsers with ?trace=drive).

var _failure := ""


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if GameMain.drive_trace_requested():
		_fail("This run has no --trace-drive, but GameMain.drive_trace_requested() says it is the drive trace.")
		return
	var main := (load("res://game/scenes/main.tscn") as PackedScene).instantiate() as GameMain
	main.capture_mouse_on_ready = false
	main.use_saved_settings = false
	root.add_child(main)
	if main.get_node_or_null("DriveTrace") != null:
		_fail("main.tscn made a DriveTrace node in a run that did not ask for it.")
		return
	if ResourceLoader.has_cached(GameMain.DRIVE_TRACE_PATH):
		_fail("main.tscn loaded %s in a run that did not ask for the trace." % GameMain.DRIVE_TRACE_PATH)
		return
	for item: Array in [[physics_frame, "physics_frame"], [process_frame, "process_frame"], [node_added, "node_added"], [node_removed, "node_removed"], [RenderingServer.frame_pre_draw, "frame_pre_draw"], [RenderingServer.frame_post_draw, "frame_post_draw"]]:
		for connection: Dictionary in (item[0] as Signal).get_connections():
			var target: Object = (connection.callable as Callable).get_object()
			if target != null and target.get_script() != null and str((target.get_script() as Script).resource_path) == GameMain.DRIVE_TRACE_PATH:
				_fail("%s calls into the drive trace in a run that did not ask for it." % item[1])
				return
	# Freed in the frame it started, before its deferred load of the world begins.
	main.free()
	# The trace's own node, made as main.gd makes it (for a main that never starts,
	# so never loads a world): before play it waits, with no frame or node signal
	# connected and no action held.
	main = (load("res://game/scenes/main.tscn") as PackedScene).instantiate() as GameMain
	var trace := (load(GameMain.DRIVE_TRACE_PATH) as GDScript).new(main) as Node
	root.add_child(trace)
	for _frame in 3:
		await process_frame
	var steps: Array = (trace.get_script() as GDScript).get_script_constant_map()["STEPS"]
	if str(steps[int(trace.get("_step"))]) != "wait":
		_fail("Before play the drive trace must wait, but it is on step %s." % trace.get("_step"))
		return
	if node_added.is_connected(Callable(trace, "_on_node_added")) or process_frame.is_connected(Callable(trace, "_on_process_frame")) or RenderingServer.frame_post_draw.is_connected(Callable(trace, "_on_post_draw")):
		_fail("Before play the drive trace must not record: its node or frame signals are already connected.")
		return
	for action: StringName in GameMain.GAMEPLAY_ACTIONS:
		if Input.is_action_pressed(action):
			_fail("Before play the drive trace must not drive, but %s is held." % action)
			return
	# The routes: the whole loop with every named stretch, and route=corner, the part of
	# it from Bruton Street round the Mersea corner to Johnson Street's bend.
	var constants := (trace.get_script() as GDScript).get_script_constant_map()
	var route_xz: Array = constants["ROUTE_XZ"]
	var whole: PackedVector2Array = trace.get("_route")
	if whole.size() != route_xz.size() / 2 or str(trace.get("_legs")) != str(constants["ROUTE_LEGS"]):
		_fail("The whole drive must follow every point of ROUTE_XZ with every stretch of ROUTE_LEGS, but it has %d points and stretches %s." % [whole.size(), trace.get("_legs")])
		return
	trace.set("_route_name", "corner")
	trace.call("_prepare_route")
	var corner: PackedVector2Array = trace.get("_route")
	var legs: Array = trace.get("_legs")
	var nearest := INF
	for index in range(1, corner.size()):
		nearest = minf(nearest, Geometry2D.get_closest_point_to_segment(constants["MERSEA_CORNER_XZ"], corner[index - 1], corner[index]).distance_to(constants["MERSEA_CORNER_XZ"]))
	var first: int = constants["CORNER_POINTS"][0]
	if corner.is_empty() or corner[0] != Vector2(route_xz[first * 2], route_xz[first * 2 + 1]) or nearest > 5.0 or legs.is_empty() or int(legs[0][0]) != 0 or str(legs[0][1]) != "Bruton Street":
		_fail("route=corner must start on Bruton Street and pass within 5 m of the Mersea corner, but it starts at %s, passes %.1f m from it, with stretches %s." % [corner[0] if not corner.is_empty() else null, nearest, legs])
		return
	trace.free()
	main.free()
	print("PASS: drive trace: a run without --trace-drive is not the trace; main.tscn then makes no DriveTrace, never loads its script and connects no frame or tree signal to it; the trace's own node, made before play, waits with no signal connected and no action held; the whole drive follows the whole route, route=corner the part round the Mersea corner")
	quit(0)


func _fail(message: String) -> void:
	if _failure == "":
		_failure = message
		push_error("FAIL: " + message)
		print("FAIL: " + message)
		quit(1)
