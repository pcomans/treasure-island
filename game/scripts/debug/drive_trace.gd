extends Node
## The drive trace (owner, 2026-11-17: "the iphone build still hitches and freezes
## massively. Can you script a drive around the island and instrument it so we can
## identify why"): an opt-in diagnostic that drives one fixed route round the island
## and records where every frame's time goes. main.gd makes it only when it is asked
## for (GameMain.drive_trace_requested: ?trace=drive in the web page's address, or
## --trace-drive after -- natively), so normal play never loads this script; it
## changes nothing it does not
## drive, and sends nothing anywhere: on the web it hands its records to the page's
## trace hook (game/web/shell.html, window.__tiTrace), which keeps them on the device
## and shows the results; natively it writes them to --trace-out=FILE.
##
## The drive, the same each run (physics ticks, not wall time, so a slow device takes
## longer but drives the same path): once play has started (on the web, the start
## prompt's tap), 5 s standing at the spawn, a walk and a run to the forecourt's
## pearl-white sedan's start point, then that sedan (CAR_ROW) driven round the loop
## ROUTE_XZ (about 4.9 km: Trade Winds and Seven Seas past Isle House and Hawkins, Bruton
## Street, the Avenue of the Palms along Cityside Park, Johnson Street, 9th Street,
## Avenue B and Gateview Avenue round the housing, Avenue H, 4th Street and Avenue M
## through the industrial east to Pier 1, Avenue N, Clipper Cove Way and back to the
## ferry plaza), steered toward a point ahead on the route (pure pursuit) at a speed
## that slows for the bends (up to CRUISE_MPS); then out of the car, a walk, a run, a
## jetpack climb to about 70 m turning the view right round, a slow descent and a
## fast drop to the ground. With laps=2 (?trace=drive&laps=2) the car goes round the
## loop twice before the foot leg, the second time past places already drawn.
##
## The trace: for every frame, from the engine's own signals (physics_frame,
## process_frame, frame_pre_draw, frame_post_draw) and four probe nodes, the time of
## the physics ticks (and how much of it the scripts' _physics_process took, and of
## that the vehicles'), of the idle step (scripts, vehicles), of drawing, and the gap
## outside the engine; the draw calls, objects and primitives drawn, texture and
## buffer memory, the physics' active bodies and pairs, the player's position and
## speed. And markers: the drive's steps, nodes added to and removed from the tree
## (by parent and class: cars made live, props felled, meshes, collision, sound), jumps
## in texture or buffer memory, the car's stops and recoveries, pauses. The page's hook
## adds what only the browser sees (frame timing, shader compiles and uploads, long
## tasks, memory, the page hidden or the WebGL context lost) and attributes each long
## frame.

## The drive's route, world x, z pairs (z south), from OpenStreetMap's road centrelines
## (data/osm, planned along the road graph; the run's notes keep the planner), and the
## route point where each named stretch starts.
const ROUTE_XZ := [-108.8, 730.2, -112.2, 723.0, -111.5, 712.9, -103.5, 706.0, -68.1, 685.8, 47.9, 624.6, -18.1, 494.1, -27.2, 482.6, -33.7, 489.9, -112.5, 581.8, -121.4, 587.2, -129.2, 583.0, -131.5, 580.1, -291.4, 272.6, -284.8, 265.5, -246.5, 224.7, -192.8, 161.9, -217.3, 116.1, -233.3, 98.0, -243.6, 81.5, -273.8, 22.4, -300.9, 42.2, -344.9, 65.6, -354.4, 24.8, -356.6, 15.1, -359.9, 5.4, -366.9, -5.8, -537.7, -341.0, -545.4, -351.3, -551.9, -356.2, -559.4, -359.6, -562.4, -360.5, -581.5, -366.2, -575.6, -389.8, -550.3, -474.5, -543.1, -494.7, -530.0, -537.8, -524.3, -552.6, -517.5, -565.4, -503.1, -586.7, -488.7, -602.4, -473.4, -614.9, -442.7, -632.7, -382.1, -671.3, -370.2, -678.1, -355.7, -684.0, -343.7, -687.9, -329.3, -691.3, -304.1, -693.8, -290.7, -693.4, -263.1, -688.9, -236.4, -679.7, -223.2, -673.1, -205.8, -662.5, -183.1, -641.4, -174.1, -630.0, -161.8, -610.5, -99.1, -521.5, -92.2, -510.6, -12.3, -358.5, 136.2, -77.6, 285.5, 209.3, 366.9, 166.8, 495.7, 99.5, 500.0, 107.6, 612.7, 321.4, 634.4, 326.1, 584.8, 486.8, 483.0, 541.7, 471.3, 554.3, 408.6, 590.1, 422.3, 613.0, 328.4, 662.8, 282.4, 687.2, 132.5, 761.9, -41.9, 855.5, -70.8, 798.5, -96.2, 754.2, -108.8, 730.2]
const ROUTE_LEGS := [[0, "ferry plaza to Seven Seas"], [8, "Bruton Street"], [11, "Avenue of the Palms"], [14, "Johnson, Seven Seas, 9th St"], [23, "Avenue B"], [31, "Gateview Avenue"], [49, "Avenue H north"], [59, "Avenue H south"], [61, "4th Street"], [63, "Avenue M"], [65, "Pier 1, Avenue N"], [67, "Clipper Cove Way"], [74, "Treasure Island Road"]]
## The car driven: the forecourt lot's pearl-white sedan (its row id ends so).
const CAR_ROW := "w1473253282_left_s0191"
## Speeds (m/s): the fastest on a straight, the slowest the bends ask for, the
## sideways acceleration a bend may take, and the braking toward a bend.
const CRUISE_MPS := 16.0
const SLOWEST_MPS := 4.5
const BEND_ACCEL_MPS2 := 4.5
const BRAKE_MPS2 := 4.0
## A drive that has moved less than STUCK_M in STUCK_S backs off, then goes on; after
## STUCK_LIMIT of them it is put down further along the route (a marker says so).
const STUCK_M := 1.5
const STUCK_S := 4.0
const STUCK_LIMIT := 3
## The drive gives up after this long (s of game time) a lap and goes on to the foot leg.
const DRIVE_LIMIT_S := 900.0
## How many laps of the route the drive takes (?trace=drive&laps=N on the web,
## --trace-laps=N natively; 1 by default, at most MAX_LAPS): a second lap passes the
## same places with everything already drawn once, which tells what the first sight
## of a place costs from what drawing it costs.
const MAX_LAPS := 3
## A frame's record, in this order (the page's hook and the native file name them).
const FIELDS := ["t", "dt", "gap", "phys_n", "phys_ms", "sphys_ms", "vphys_ms", "proc_ms", "sproc_ms", "vproc_ms", "draw_ms", "dc", "obj", "prim_k", "x", "y", "z", "speed", "flags", "step", "leg", "nadd", "nrem", "tex_mb", "buf_mb", "act", "pairs", "lap"]
## flags: driving, the tree paused, nothing drawn this frame, the drive running.
const FLAG_DRIVING := 1
const FLAG_PAUSED := 2
const FLAG_UNDRAWN := 4
const FLAG_RUNNING := 8
## Memory jumps (MiB) worth a marker, and how often (ms) records go to the page.
const MEM_JUMP_MB := 0.25
const SEND_MS := 1000.0
## The steps, in order (the record's step field is the index).
const STEPS := ["wait", "baseline", "to_car", "drive", "stop", "out", "walk", "run", "rise", "hover", "drop", "landed", "done"]

var _main: GameMain
var _web := OS.has_feature("web")
var _js: JavaScriptObject
var _out: FileAccess
var _quit_at_end := false
## The engine clock (usec) the trace's times count from.
var _origin_us := 0
## This frame's moments (usec), from the engine's signals.
var _t_first := 0
var _t_proc := 0
var _t_pre := 0
var _t_post := 0
var _t_prev_first := 0
var _t_prev_end := 0
var _phys_n := 0
var _drawn := false
var _open := false
## The probes' sums for this frame (usec) and the moments they started.
var _sphys_us := 0
var _vphys_us := 0
var _sproc_us := 0
var _vproc_us := 0
var _s_start := 0
var _v_start := 0
var _nadd := 0
var _nrem := 0
var _added := {}
var _removed := {}
var _tex_mb := 0.0
var _buf_mb := 0.0
var _rows := PackedFloat64Array()
var _events: Array = []
var _last_send_ms := 0.0
var _frames := 0
## The drive.
var _step := 0
var _step_ticks := 0
var _leg := -1
var _route := PackedVector2Array()
var _cum := PackedFloat32Array()
var _speeds := PackedFloat32Array()
var _s := 0.0
var _stuck_from := Vector3.ZERO
var _stuck_ticks := 0
var _stucks := 0
var _laps := 1
var _lap := 1
var _backing := 0
var _drive_ticks := 0
var _car: DrivableCar
var _probes: Array[Node] = []
## The census of the materials the world can draw (_start_census), taken before the
## records start: BaseMaterial3D materials waiting for their generated shader's RID
## (inspect_native_shader_code answers through the group below, in order), the RIDs as
## they come, and the census itself.
var _census_base: Array[Material] = []
var _census_rids: Array[RID] = []
var _census_entries := {}
var _census: Dictionary = {}
var _vehicle_probes: Array[Node] = []


func _init(main: GameMain) -> void:
	_main = main
	name = "DriveTrace"
	# Records through the pause too (marked), and drives only while play runs.
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Before every other physics step, so the actions it sets are read this tick.
	process_physics_priority = -1000


func _ready() -> void:
	_origin_us = Time.get_ticks_usec()
	if _web:
		_js = JavaScriptBridge.get_interface("__tiTrace")
		_laps = int(str(JavaScriptBridge.eval("new URLSearchParams(location.search).get('laps') || '1'")))
	else:
		for arg: String in OS.get_cmdline_user_args():
			if arg.begins_with("--trace-out="):
				_out = FileAccess.open(arg.trim_prefix("--trace-out="), FileAccess.WRITE)
			elif arg.begins_with("--trace-laps="):
				_laps = int(arg.trim_prefix("--trace-laps="))
		_quit_at_end = OS.get_cmdline_user_args().has("--trace-quit")
	_laps = clampi(_laps, 1, MAX_LAPS)
	# The scripts' share of each step: probes first and last of all.
	for at: int in [-1000000, 1000000]:
		var probe := TraceProbe.new(self, "script_first" if at < 0 else "script_last")
		probe.process_priority = at
		probe.process_physics_priority = at
		add_child(probe)
		_probes.append(probe)
	_prepare_route()
	_event("trace", "start", 0)
	print("DRIVE_TRACE start web=%s route_m=%.0f" % [_web, _cum[_cum.size() - 1]])


## Every material the world can draw as play starts, for telling which ones the shaders
## compiled in play belong to: each material's kind, its shader (a file, or for a
## StandardMaterial3D the code Godot generated for it, read through the engine's own
## shader inspector, Material.inspect_native_shader_code, which answers the group
## "_native_shader_source_visualizer" a frame later), the shader's uniform names, how
## many nodes draw it and how many of them as MultiMesh instances, the shortest
## visibility range among them, the 50 m cells they stand in, and where the spawn camera
## looks. Taken in the frames before the records start, so its cost is not in them.
func _start_census() -> void:
	add_to_group("_native_shader_source_visualizer")
	var camera := _main.player.get_camera()
	_census = {"camera": [camera.global_position.x, camera.global_position.y, camera.global_position.z, -camera.global_basis.z.x, -camera.global_basis.z.y, -camera.global_basis.z.z, camera.fov, camera.far]}
	for node: Node in _main.find_children("*", "GeometryInstance3D", true, false):
		var geometry := node as GeometryInstance3D
		var mesh: Mesh = null
		var instanced := false
		if geometry is MeshInstance3D:
			mesh = (geometry as MeshInstance3D).mesh
		elif geometry is MultiMeshInstance3D and (geometry as MultiMeshInstance3D).multimesh != null:
			mesh = (geometry as MultiMeshInstance3D).multimesh.mesh
			instanced = true
		var used: Array[Material] = []
		if geometry.material_override != null:
			used.append(geometry.material_override)
		elif mesh != null:
			for surface in mesh.get_surface_count():
				var material: Material = (geometry as MeshInstance3D).get_surface_override_material(surface) if geometry is MeshInstance3D else null
				if material == null:
					material = mesh.surface_get_material(surface)
				if material != null:
					used.append(material)
		if geometry.material_overlay != null:
			used.append(geometry.material_overlay)
		var centre := geometry.global_transform * geometry.get_aabb().get_center()
		var cell := "%d,%d" % [floori(centre.x / 50.0), floori(centre.z / 50.0)]
		for first: Material in used:
			var material := first
			while material != null:
				_census_add(material, geometry, instanced, cell)
				material = material.next_pass


func _census_add(material: Material, geometry: GeometryInstance3D, instanced: bool, cell: String) -> void:
	var id := material.get_instance_id()
	var entry: Dictionary = _census_entries.get(id, {})
	if entry.is_empty():
		entry = {"kind": material.get_class(), "path": material.resource_path, "shader": "", "uniforms": [], "users": 0, "instanced": 0, "range": 0.0, "cells": {}, "example": "%s/%s" % [geometry.get_parent().name, geometry.name]}
		if material is ShaderMaterial and (material as ShaderMaterial).shader != null:
			var shader := (material as ShaderMaterial).shader
			entry.shader = shader.resource_path if not shader.resource_path.is_empty() else "built-in"
			entry.uniforms = shader.get_shader_uniform_list().map(func(uniform: Dictionary) -> String: return str(uniform.name))
		elif material is BaseMaterial3D:
			entry["inspect"] = _census_base.size()
			_census_base.append(material)
			material.inspect_native_shader_code()
			# The features that name the defines of its generated shader (what tells one
			# StandardMaterial3D's programs from another's), in case the inspector's
			# answers cannot be matched to the materials asked.
			var base := material as BaseMaterial3D
			var features: Array[String] = []
			if base.cull_mode == BaseMaterial3D.CULL_DISABLED:
				features.append("DO_SIDE_CHECK")
			if base.vertex_color_use_as_albedo:
				features.append("COLOR_USED")
			if base.normal_enabled:
				features.append("NORMAL_MAP_USED")
			if base.backlight_enabled:
				features.append("LIGHT_BACKLIGHT_USED")
			if base.rim_enabled:
				features.append("LIGHT_RIM_USED")
			if base.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS:
				features.append("USE_OPAQUE_PREPASS")
			if base.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED:
				features.append("MODE_UNSHADED")
			if base.billboard_mode != BaseMaterial3D.BILLBOARD_DISABLED:
				features.append("billboard")
			if base.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
				features.append("transparency %d" % base.transparency)
			entry["features"] = features
		_census_entries[id] = entry
	entry.users += 1
	if instanced:
		entry.instanced += 1
	if geometry.visibility_range_end > 0.0:
		entry.range = geometry.visibility_range_end if entry.range == 0.0 else minf(entry.range, geometry.visibility_range_end)
	if (entry.cells as Dictionary).size() < 400:
		entry.cells[cell] = true


## The engine's shader inspector's answer: a material's shader, in the order asked.
func _inspect_shader(shader: RID) -> void:
	_census_rids.append(shader)


func _finish_census() -> void:
	remove_from_group("_native_shader_source_visualizer")
	var uniform := RegEx.create_from_string("uniform\\s+(?:(?:lowp|mediump|highp)\\s+)?\\w+\\s+(\\w+)")
	var render_mode := RegEx.create_from_string("render_mode\\s+([^;]*);")
	# One entry a shader (the programs are a shader's, whatever the material's values):
	# the materials that draw with it merged, their users and cells added up.
	var shaders := {}
	for entry: Dictionary in _census_entries.values():
		if entry.has("inspect"):
			var index := int(entry.inspect)
			entry.erase("inspect")
			if index < _census_rids.size():
				entry.shader = "generated %d" % _census_rids[index].get_id()
				if not shaders.has(entry.shader):
					var code := RenderingServer.shader_get_code(_census_rids[index])
					entry.uniforms = uniform.search_all(code).map(func(found: RegExMatch) -> String: return found.get_string(1))
					var mode := render_mode.search(code)
					entry["render_mode"] = mode.get_string(1) if mode != null else ""
		var key := str(entry.shader) if not str(entry.shader).is_empty() and entry.shader != "built-in" else "%s %s" % [entry.kind, entry.example]
		if not shaders.has(key):
			entry["materials"] = 0
			entry["examples"] = []
			shaders[key] = entry
		var merged: Dictionary = shaders[key]
		merged.materials += 1
		if not is_same(merged, entry):
			merged.users += entry.users
			merged.instanced += entry.instanced
			if entry.range > 0.0:
				merged.range = entry.range if merged.range == 0.0 else minf(merged.range, entry.range)
			for cell: String in entry.cells:
				if (merged.cells as Dictionary).size() < 400:
					merged.cells[cell] = true
		if (merged.examples as Array).size() < 4:
			merged.examples.append(str(entry.path) if not str(entry.path).is_empty() else str(entry.example))
	var materials: Array = []
	for entry: Dictionary in shaders.values():
		entry.cells = (entry.cells as Dictionary).keys()
		materials.append(entry)
	_census["materials"] = materials
	_census["material_count"] = _census_entries.size()
	# The inspector answers in the order asked only if every material asked had a shader.
	_census["inspector"] = {"asked": _census_base.size(), "answered": _census_rids.size()}
	_census_entries.clear()
	_census_base.clear()
	# To the page now, a tick before the records start, so its cost is in none of them.
	if _js != null:
		_js.census(JSON.stringify(_census))
	print("DRIVE_TRACE census materials=%d inspected=%d" % [materials.size(), _census_rids.size()])


## The probes round the vehicles (the manager, its cars, breakers, the bending
## trees' and the driving camera's steps): one just before the manager among main's
## children and one as its last child (kept last as cars are added).
func _wrap_vehicles(vehicles: Node) -> void:
	if not _vehicle_probes.is_empty() or vehicles == null:
		return
	var before := TraceProbe.new(self, "vehicles_before")
	var after := TraceProbe.new(self, "vehicles_after")
	before.process_mode = Node.PROCESS_MODE_ALWAYS
	after.process_mode = Node.PROCESS_MODE_ALWAYS
	vehicles.get_parent().add_child(before)
	vehicles.get_parent().move_child(before, vehicles.get_index())
	vehicles.add_child(after)
	vehicles.child_entered_tree.connect(func(_child: Node) -> void: _keep_last.call_deferred(vehicles, after))
	_vehicle_probes = [before, after]


func _keep_last(parent: Node, probe: Node) -> void:
	if is_instance_valid(parent) and is_instance_valid(probe) and probe.get_parent() == parent and probe.get_index() != parent.get_child_count() - 1:
		parent.move_child(probe, parent.get_child_count() - 1)


func _now_us() -> int:
	return Time.get_ticks_usec()


func _ms(us: int) -> float:
	return float(us - _origin_us) / 1000.0


# --- The frame's moments -------------------------------------------------------

func _begin_frame(at: int) -> void:
	if _open:
		_finish_frame()
	_open = true
	_t_first = at
	_t_proc = 0
	_t_pre = 0
	_t_post = 0
	_phys_n = 0
	_drawn = false
	_sphys_us = 0
	_vphys_us = 0
	_sproc_us = 0
	_vproc_us = 0
	_nadd = 0
	_nrem = 0


func _on_physics_frame() -> void:
	var now := _now_us()
	if not _open or _t_proc != 0:
		_begin_frame(now)
	_phys_n += 1


func _on_process_frame() -> void:
	var now := _now_us()
	if not _open or _t_proc != 0:
		_begin_frame(now)
	_t_proc = now


func _on_pre_draw() -> void:
	_t_pre = _now_us()


func _on_post_draw() -> void:
	_t_post = _now_us()
	_drawn = true
	_finish_frame()


func probe_hit(which: String, physics: bool) -> void:
	var now := _now_us()
	match which:
		"script_first":
			_s_start = now
		"script_last":
			if physics:
				_sphys_us += now - _s_start
			else:
				_sproc_us += now - _s_start
		"vehicles_before":
			_v_start = now
		"vehicles_after":
			if physics:
				_vphys_us += now - _v_start
			else:
				_vproc_us += now - _v_start


## The frame's record, once it has been drawn (or the next frame has begun).
func _finish_frame() -> void:
	if not _open:
		return
	_open = false
	var end := _t_post if _drawn else maxi(_t_proc, _t_first)
	var player := _main.player
	var at := player.global_position
	var speed := 0.0
	var flags := 0
	var vehicles := _main.vehicles
	if vehicles != null and vehicles.is_driving():
		flags |= FLAG_DRIVING
		var car := vehicles.active_car()
		if car != null:
			at = car.global_position
			speed = car.linear_velocity.length()
	else:
		speed = player.velocity.length()
	if get_tree().paused:
		flags |= FLAG_PAUSED
	if not _drawn:
		flags |= FLAG_UNDRAWN
	if _step > 0 and _step < STEPS.size() - 1:
		flags |= FLAG_RUNNING
	var tex_mb := float(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TEXTURE_MEM_USED)) / 1048576.0
	var buf_mb := float(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_BUFFER_MEM_USED)) / 1048576.0
	if _frames > 0:
		if absf(tex_mb - _tex_mb) >= MEM_JUMP_MB:
			_event("mem", "texture memory %+.2f MiB" % (tex_mb - _tex_mb), tex_mb - _tex_mb)
		if absf(buf_mb - _buf_mb) >= MEM_JUMP_MB:
			_event("mem", "buffer memory %+.2f MiB" % (buf_mb - _buf_mb), buf_mb - _buf_mb)
	_tex_mb = tex_mb
	_buf_mb = buf_mb
	_flush_nodes()
	var phys_ms := float(_t_proc - _t_first) / 1000.0 if _phys_n > 0 and _t_proc > 0 else 0.0
	var proc_ms := float((_t_pre if _t_pre > 0 else end) - _t_proc) / 1000.0 if _t_proc > 0 else 0.0
	var draw_ms := float(_t_post - _t_pre) / 1000.0 if _drawn and _t_pre > 0 else 0.0
	var row := [
		_ms(_t_first), float(_t_first - _t_prev_first) / 1000.0 if _t_prev_first > 0 else 0.0,
		float(_t_first - _t_prev_end) / 1000.0 if _t_prev_end > 0 else 0.0,
		_phys_n, phys_ms, _sphys_us / 1000.0, _vphys_us / 1000.0, proc_ms, _sproc_us / 1000.0, _vproc_us / 1000.0, draw_ms,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME) / 1000.0,
		at.x, at.y, at.z, speed, flags, _step, _leg, _nadd, _nrem, tex_mb, buf_mb,
		Performance.get_monitor(Performance.PHYSICS_3D_ACTIVE_OBJECTS), Performance.get_monitor(Performance.PHYSICS_3D_COLLISION_PAIRS), _lap,
	]
	for value: Variant in row:
		_rows.append(float(value))
	_frames += 1
	_t_prev_first = _t_first
	_t_prev_end = end
	if _ms(end) - _last_send_ms >= SEND_MS:
		_send()


# --- Markers --------------------------------------------------------------------

func _event(kind: String, text: String, value: float) -> void:
	_events.append([snappedf(_ms(_now_us()), 0.01), kind, text, value])


## Nodes added to or removed from the tree, counted by parent and class each frame.
func _on_node_added(node: Node) -> void:
	_nadd += 1
	var key := _node_key(node)
	_added[key] = int(_added.get(key, 0)) + 1


func _on_node_removed(node: Node) -> void:
	_nrem += 1
	var key := _node_key(node)
	_removed[key] = int(_removed.get(key, 0)) + 1


static func _node_key(node: Node) -> String:
	var parent := node.get_parent()
	var where := ""
	if parent != null:
		where = str(parent.name)
		var grand := parent.get_parent()
		if grand != null and grand.name != &"root":
			where = str(grand.name) + "/" + where
	return "%s %s (%s)" % [where, node.get_class(), str(node.name).left(40)]


func _flush_nodes() -> void:
	for pair: Array in [["node+", _added], ["node-", _removed]]:
		var counts: Dictionary = pair[1]
		if counts.is_empty():
			continue
		var keys := counts.keys()
		keys.sort_custom(func(a: String, b: String) -> bool: return counts[a] > counts[b])
		var total := 0
		for key: String in counts:
			total += int(counts[key])
		var shown := PackedStringArray()
		for index in mini(keys.size(), 6):
			shown.append("%dx %s" % [counts[keys[index]], keys[index]])
		_event(pair[0], "%d: %s%s" % [total, "; ".join(shown), "" if keys.size() <= 6 else "; +%d kinds" % (keys.size() - 6)], total)
		counts.clear()


# --- Sending --------------------------------------------------------------------

func _send() -> void:
	_last_send_ms = _ms(_now_us())
	if _rows.is_empty() and _events.is_empty():
		return
	var batch := JSON.stringify({"rows": Array(_rows), "events": _events, "fields": FIELDS.size()})
	_rows = PackedFloat64Array()
	_events = []
	if _js != null:
		_js.engine(batch)
	elif _out != null:
		_out.store_line(batch)
		_out.flush()


func _header() -> Dictionary:
	var viewport := get_viewport()
	var outline: Array = []
	var boundary := _main.world_root.get_boundary()
	if boundary != null:
		for component: Variant in boundary.get_boundary_data().get("components", []):
			var ring: Array = (component as Dictionary).get("outer", [])
			var step := maxi(1, ring.size() / 300)
			var points: Array = []
			for index in range(0, ring.size(), step):
				points.append([snappedf(float(ring[index][0]), 0.1), snappedf(float(ring[index][1]), 0.1)])
			outline.append(points)
	var route: Array = []
	for point: Vector2 in _route:
		route.append([point.x, point.y])
	var stamp: Variant = ProjectSettings.get_setting("application/config/version", "")
	return {
		"fields": FIELDS, "steps": STEPS, "legs": ROUTE_LEGS, "route": route, "outline": outline,
		"route_m": _cum[_cum.size() - 1], "car": CAR_ROW, "cruise_mps": CRUISE_MPS, "laps": _laps,
		"renderer": RenderingServer.get_current_rendering_method(), "adapter": RenderingServer.get_video_adapter_name(),
		"vendor": RenderingServer.get_video_adapter_vendor(), "display": DisplayServer.get_name(), "os": OS.get_name(),
		"engine": Engine.get_version_info().get("string", ""), "version": stamp,
		"physics_ticks": Engine.physics_ticks_per_second, "max_physics_steps": Engine.max_physics_steps_per_frame,
		"physics_engine": ProjectSettings.get_setting("physics/3d/physics_engine", ""),
		"viewport": [viewport.get_visible_rect().size.x, viewport.get_visible_rect().size.y],
		"window": [get_window().size.x, get_window().size.y], "scale_3d": viewport.scaling_3d_scale,
		"msaa_3d": viewport.msaa_3d, "max_fps": Engine.max_fps, "vsync": DisplayServer.window_get_vsync_mode(),
		"touch": _main.get_node_or_null("Interface/HUD/TouchControls") != null,
		"audio_driver": AudioServer.get_driver_name(), "memory_static_mb": Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
		"objects": Performance.get_monitor(Performance.OBJECT_COUNT), "nodes": Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
		"video_mem_mb": RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED) / 1048576.0,
	}


## Starts the records, as play starts: the frame signals and the tree's node signals.
func _begin_report() -> void:
	get_tree().physics_frame.connect(_on_physics_frame)
	get_tree().process_frame.connect(_on_process_frame)
	RenderingServer.frame_pre_draw.connect(_on_pre_draw)
	RenderingServer.frame_post_draw.connect(_on_post_draw)
	get_tree().node_added.connect(_on_node_added)
	get_tree().node_removed.connect(_on_node_removed)
	_origin_us = _now_us()
	var header := _header()
	header["origin_ms_engine"] = 0.0
	if _web and _js != null:
		# The page's clock at this trace's origin (both are performance.now() on the web).
		var before := _now_us()
		var page_now := float(JavaScriptBridge.eval("performance.now()"))
		var after := _now_us()
		header["page_ms_at_origin"] = page_now - float((before + after) / 2 - _origin_us) / 1000.0
		_js.begin(JSON.stringify(header))
	elif _out != null:
		_out.store_line(JSON.stringify({"header": header}))
		_out.store_line(JSON.stringify({"census": _census}))
	print("DRIVE_TRACE header renderer=%s adapter=%s viewport=%s touch=%s" % [header.renderer, header.adapter, header.viewport, header.touch])


func _end_report(result: String) -> void:
	_send()
	var summary := {
		"result": result, "frames": _frames, "stucks": _stucks, "ms": _ms(_now_us()),
		"memory_static_mb": Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
		"objects": Performance.get_monitor(Performance.OBJECT_COUNT), "nodes": Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
		"video_mem_mb": RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED) / 1048576.0,
	}
	if _js != null:
		_js.end(JSON.stringify(summary))
	elif _out != null:
		_out.store_line(JSON.stringify({"end": summary}))
		_out.close()
	print("DRIVE_TRACE done result=%s frames=%d stucks=%d ms=%.0f" % [result, _frames, _stucks, summary.ms])
	if _quit_at_end:
		get_tree().quit(0 if result == "complete" else 1)


# --- The drive -----------------------------------------------------------------

func _prepare_route() -> void:
	_route.clear()
	for index in range(0, ROUTE_XZ.size(), 2):
		_route.append(Vector2(float(ROUTE_XZ[index]), float(ROUTE_XZ[index + 1])))
	_cum.resize(_route.size())
	_cum[0] = 0.0
	for index in range(1, _route.size()):
		_cum[index] = _cum[index - 1] + _route[index - 1].distance_to(_route[index])
	# The speed each metre of the route allows: the bend's (its heading change over
	# 12 m), then braking toward every slower stretch ahead.
	var total := _cum[_cum.size() - 1]
	var count := int(ceilf(total)) + 1
	_speeds.resize(count)
	for metre in count:
		var behind := _point_at(maxf(0.0, metre - 6.0))
		var here := _point_at(float(metre))
		var ahead := _point_at(minf(total, metre + 6.0))
		var turn := absf((here - behind).angle_to(ahead - here)) if (here - behind).length() > 0.5 and (ahead - here).length() > 0.5 else 0.0
		var curvature := turn / 12.0
		_speeds[metre] = clampf(sqrt(BEND_ACCEL_MPS2 / curvature) if curvature > 0.0001 else CRUISE_MPS, SLOWEST_MPS, CRUISE_MPS)
	for metre in range(count - 2, -1, -1):
		_speeds[metre] = minf(_speeds[metre], sqrt(_speeds[metre + 1] * _speeds[metre + 1] + 2.0 * BRAKE_MPS2))
	# Slow to a stop at the end.
	for metre in range(count - 1, -1, -1):
		_speeds[metre] = minf(_speeds[metre], sqrt(2.0 * BRAKE_MPS2 * (total - metre)) + 0.5)


## The route's point at s metres along it.
func _point_at(s: float) -> Vector2:
	var index := _cum.bsearch(s)
	if index <= 0:
		return _route[0]
	if index >= _route.size():
		return _route[_route.size() - 1]
	var span := _cum[index] - _cum[index - 1]
	var part := (s - _cum[index - 1]) / span if span > 0.0 else 0.0
	return _route[index - 1].lerp(_route[index], clampf(part, 0.0, 1.0))


## How far along the route (m) the point nearest p is, looking near the last.
func _nearest_s(p: Vector2, around: float) -> float:
	var best := around
	var best_d := INF
	for index in range(1, _route.size()):
		if _cum[index] < around - 15.0 or _cum[index - 1] > around + 40.0:
			continue
		var a := _route[index - 1]
		var b := _route[index]
		var ab := b - a
		var t := clampf((p - a).dot(ab) / maxf(ab.length_squared(), 0.0001), 0.0, 1.0)
		var d := p.distance_to(a + ab * t)
		if d < best_d:
			best_d = d
			best = _cum[index - 1] + ab.length() * t
	return best


func _set_step(step: String) -> void:
	_step = STEPS.find(step)
	_step_ticks = 0
	_event("step", step, _step)
	print("DRIVE_TRACE step=%s t=%.1f s" % [step, _ms(_now_us()) / 1000.0])


func _hold(action: StringName, strength: float) -> void:
	if strength > 0.0:
		Input.action_press(action, clampf(strength, 0.0, 1.0))
	elif Input.is_action_pressed(action):
		Input.action_release(action)


func _release_all() -> void:
	for action: StringName in [&"move_forward", &"move_back", &"move_left", &"move_right", &"run", &"jetpack", &"fast_drop", &"vehicle_enter_exit", &"handbrake", &"recover"]:
		if Input.is_action_pressed(action):
			Input.action_release(action)


func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	_step_ticks += 1
	var player := _main.player
	match STEPS[_step]:
		"wait":
			# Play has started: on the web after the start prompt's tap.
			if _main.is_play_ready() and player.is_processing_unhandled_input():
				if _step_ticks == 60:
					_start_census()
				elif _step_ticks > 60 and (_census_rids.size() >= _census_base.size() or _step_ticks > 120):
					_finish_census()
					_wrap_vehicles(_main.vehicles)
					_begin_report()
					_set_step("baseline")
			else:
				_step_ticks = 0
		"baseline":
			if _step_ticks >= 300:
				_set_step("to_car")
		"to_car":
			var to := _route[0] - Vector2(player.global_position.x, player.global_position.z)
			_face(player, to)
			_hold(&"move_forward", 1.0)
			_hold(&"run", 1.0 if _step_ticks > 90 else 0.0)
			if to.length() < 8.0 or _step_ticks > 900:
				_release_all()
				_start_drive()
		"drive":
			_drive(delta)
		"stop":
			_hold(&"move_back", 1.0 if _car != null and _car.linear_velocity.length() > 0.3 else 0.0)
			if _car == null or _car.linear_velocity.length() < 0.3 or _step_ticks > 300:
				_release_all()
				_set_step("out")
		"out":
			if _step_ticks == 1:
				Input.action_press(&"vehicle_enter_exit")
			elif _step_ticks == 3:
				Input.action_release(&"vehicle_enter_exit")
			elif _step_ticks >= 45:
				if _main.vehicles.is_driving():
					_main.vehicles.force_exit()
					_event("car", "F did not get out; forced out", 0)
				_set_step("walk")
		"walk":
			_hold(&"move_forward", 1.0)
			if _step_ticks >= 180:
				_set_step("run")
		"run":
			_hold(&"run", 1.0)
			_hold(&"move_forward", 1.0)
			if _step_ticks >= 240:
				_release_all()
				(player.camera_rig.get_node("SpringArm3D") as Node3D).rotation.x = deg_to_rad(-25.0)
				_set_step("rise")
		"rise":
			_hold(&"jetpack", 1.0)
			player.camera_rig.rotation.y += PI / 840.0
			if _step_ticks >= 840:
				_hold(&"jetpack", 0.0)
				_set_step("hover")
		"hover":
			player.camera_rig.rotation.y += PI / 360.0
			if _step_ticks >= 360:
				_set_step("drop")
		"drop":
			_hold(&"fast_drop", 1.0)
			if player.is_on_floor() or _step_ticks > 900:
				_hold(&"fast_drop", 0.0)
				_set_step("landed")
		"landed":
			if _step_ticks >= 180:
				_release_all()
				_set_step("done")
				_end_report("complete" if _stucks == 0 else "complete_with_stops")


## Turns the on-foot camera (and so the walk) toward a direction on the ground.
func _face(player: PlayerController, to: Vector2) -> void:
	if to.length() > 0.01:
		player.camera_rig.rotation.y = atan2(-to.x, -to.y)


func _start_drive() -> void:
	var vehicles := _main.vehicles
	var id := ""
	for row: Variant in vehicles.swappable_ids():
		if str(row).ends_with(CAR_ROW):
			id = str(row)
			break
	if id == "":
		_event("car", "no car row ending %s" % CAR_ROW, 0)
		_end_report("no_car")
		_set_step("done")
		return
	var started := vehicles.drive_from(id, _route[0], _route[1] - _route[0])
	if started != "":
		_event("car", "drive_from failed: " + started, 0)
		_end_report("no_drive")
		_set_step("done")
		return
	_car = vehicles.active_car()
	_s = 0.0
	_drive_ticks = 0
	_stuck_ticks = 0
	_backing = 0
	_stuck_from = _car.global_position
	_set_step("drive")


func _drive(delta: float) -> void:
	var vehicles := _main.vehicles
	if not vehicles.is_driving() or not is_instance_valid(_car):
		_event("car", "no longer driving", 0)
		_release_all()
		_set_step("walk")
		return
	_drive_ticks += 1
	var total := _cum[_cum.size() - 1]
	var position := Vector2(_car.global_position.x, _car.global_position.z)
	_s = _nearest_s(position, _s)
	var leg := -1
	for index in ROUTE_LEGS.size():
		if _s >= _cum[int(ROUTE_LEGS[index][0])]:
			leg = index
	if leg != _leg:
		_leg = leg
		_event("leg", str(ROUTE_LEGS[leg][1]), leg)
	if _s >= total - 4.0 and _lap < _laps:
		# The route ends where it starts: round again.
		_lap += 1
		_s = 0.0
		_leg = -1
		_event("lap", "lap %d" % _lap, _lap)
		return
	if _s >= total - 4.0 or _drive_ticks * delta > DRIVE_LIMIT_S * _laps:
		if _s < total - 4.0:
			_event("car", "drive time limit at %.0f m of %.0f" % [_s, total], _s)
		_release_all()
		_set_step("stop")
		return
	var velocity := _car.linear_velocity
	var forward := -_car.global_transform.basis.z
	var speed := Vector2(velocity.x, velocity.z).dot(Vector2(forward.x, forward.z).normalized())
	# Backing off after a stop: reverse straight for a second and a half.
	if _backing > 0:
		_backing -= 1
		_hold(&"move_forward", 0.0)
		_hold(&"move_back", 1.0)
		_hold(&"move_left", 0.0)
		_hold(&"move_right", 0.0)
		if _backing == 0:
			_hold(&"move_back", 0.0)
			_stuck_from = _car.global_position
			_stuck_ticks = 0
		return
	# Steering: toward a point ahead on the route (pure pursuit).
	var look := clampf(5.0 + 0.55 * absf(speed), 6.0, 16.0)
	var target := _point_at(minf(total, _s + look))
	var to := target - position
	var heading := Vector2(forward.x, forward.z)
	var angle := heading.angle_to(to) if to.length() > 0.1 and heading.length() > 0.1 else 0.0
	var wheelbase := _car.wheelbase
	var wanted := atan(2.0 * wheelbase * sin(angle) / maxf(to.length(), 1.0))
	var lock := lerpf(deg_to_rad(32.0), deg_to_rad(7.0), clampf(absf(speed) / 35.0, 0.0, 1.0))
	var steer := clampf(wanted / lock, -1.0, 1.0)
	_hold(&"move_right", steer if steer > 0.02 else 0.0)
	_hold(&"move_left", -steer if steer < -0.02 else 0.0)
	# Speed: the route's limit here, with throttle and brake by how far off it is.
	var limit := _speeds[clampi(int(_s), 0, _speeds.size() - 1)]
	var error := limit - speed
	if error > 0.3:
		_hold(&"move_back", 0.0)
		_hold(&"move_forward", clampf(0.35 + error * 0.25, 0.2, 1.0))
	elif error < -1.0:
		_hold(&"move_forward", 0.0)
		_hold(&"move_back", clampf(-error * 0.3, 0.2, 1.0))
	else:
		_hold(&"move_forward", 0.0)
		_hold(&"move_back", 0.0)
	# Stuck: moved less than STUCK_M in STUCK_S.
	_stuck_ticks += 1
	if _stuck_ticks * delta >= STUCK_S:
		if _car.global_position.distance_to(_stuck_from) < STUCK_M:
			_stucks += 1
			_event("car", "stuck at %.0f m (%.1f, %.1f)" % [_s, position.x, position.y], _s)
			if _stucks % STUCK_LIMIT == 0:
				var ahead := minf(total - 5.0, _s + 25.0)
				var put := _point_at(ahead)
				var started := vehicles.drive_from(_car.row_id, put, _point_at(minf(total, ahead + 5.0)) - put)
				_car = vehicles.active_car()
				_s = ahead
				_event("car", "put down further along at %.0f m%s" % [ahead, "" if started == "" else ": " + started], ahead)
				if _car == null:
					_set_step("walk")
					return
			else:
				_backing = 90
		_stuck_from = _car.global_position
		_stuck_ticks = 0


func _exit_tree() -> void:
	if _step < STEPS.size() - 1 and _step > 0:
		_end_report("left")
	_release_all()


## A node that tells the trace when its step runs: first or last of every step (by
## priority), or round the vehicles (by its place in the tree).
class TraceProbe extends Node:
	var _trace: Node
	var _which: String

	func _init(trace: Node, which: String) -> void:
		_trace = trace
		_which = which
		name = "Probe_" + which
		process_mode = Node.PROCESS_MODE_ALWAYS

	func _physics_process(_delta: float) -> void:
		_trace.probe_hit(_which, true)

	func _process(_delta: float) -> void:
		_trace.probe_hit(_which, false)
