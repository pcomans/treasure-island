extends SceneTree
## The whole island: it loads and every building counted in the recognition
## score passes the full fit check (solid, grounded, walk-up, stairs).
##
##   tools/godot --fixed-fps 60 --path . --script game/tests/shared/island_test.gd
##
## --fixed-fps 60 lets the walking simulation run as fast as the CPU allows. It
## draws nothing while it walks (see _stop_drawing).
## Optional -- --use-prebuilt-world: run the same checks on the baked native
## world that desktop exports load (bake it first: tools/prebuild-static-world.sh native).
## Optional -- --street-detail on|off or --street-detail-layers vegetation,fences:
## the street-detail layers to load (default: the project setting, on).
## Optional -- --diagnose-after SOURCE: query four sides of subsequent scored
## units only, without placement/input; always diagnostic HOLD and exit1.

const WorldHarness := preload("res://game/tests/shared/world_harness.gd")
const BuildingFit := preload("res://game/tests/shared/building_fit.gd")
const Catalog := preload("res://game/tests/shared/catalog.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var raw := OS.get_cmdline_user_args()
	# WorldLoader reads --use-prebuilt-world itself; a missing bake fails the load.
	var prebuilt := raw.has("--use-prebuilt-world")
	if prebuilt:
		raw.remove_at(raw.find("--use-prebuilt-world"))
		if raw.has("--use-prebuilt-world"):
			print("FAIL: duplicate --use-prebuilt-world")
			quit(1)
			return
	# WorldLoader reads and validates the street-detail options itself.
	for flag: String in ["--street-detail", "--street-detail-layers"]:
		while raw.has(flag):
			var at := raw.find(flag)
			if at + 1 < raw.size() and not raw[at + 1].begins_with("--"):
				raw.remove_at(at + 1)
			raw.remove_at(at)
	var diagnostic := not raw.is_empty()
	var diagnostic_units: Array[Dictionary] = []
	if diagnostic:
		# Reject every malformed diagnostic attempt before loading or movement.
		if raw.size() != 2 or raw[0] != "--diagnose-after" or raw[1].is_empty() or raw[1].begins_with("--"):
			print("DIAGNOSTIC ONLY / HOLD: use exactly --diagnose-after SOURCE; no equals syntax or duplicate/conflicting flags")
			quit(1)
			return
		var catalog_units := Catalog.accepted_units()
		var matches := 0
		var after := -1
		for i in catalog_units.size():
			if str(catalog_units[i].anchor_source_key) == raw[1]:
				matches += 1
				after = i
		if matches != 1:
			print("DIAGNOSTIC ONLY / HOLD: SOURCE must identify exactly one accepted catalog unit")
			quit(1)
			return
		for i in range(after + 1, catalog_units.size()):
			diagnostic_units.append(catalog_units[i])
		print("DIAGNOSTIC ONLY: %d subsequent units; no placement, movement, fit, active REST or acceptance credit" % diagnostic_units.size())
	var h := WorldHarness.new(self)
	var load_started := Time.get_ticks_msec()
	var error := await h.load_world()
	if error != "":
		print("FAIL: " + error)
		quit(1)
		return
	print(h.street_detail_summary())
	var street_problems := h.street_detail_problems()
	if not street_problems.is_empty():
		for problem in street_problems:
			print("FAIL: " + problem)
		h.main.queue_free()
		quit(1)
		return
	if diagnostic:
		var diagnostic_fit := BuildingFit.new(h)
		var queried := 0
		for unit: Dictionary in diagnostic_units:
			var key := str(unit.anchor_source_key)
			for side: String in ["north", "south", "west", "east"]:
				var problem := diagnostic_fit.diagnose_side(key, side)
				queried += 1
				print("DIAGNOSTIC ONLY source=%s side=%s: %s" % [key, side, "candidate available; movement untested" if problem == "" else problem])
				if diagnostic_fit.has_unsafe_failure():
					break
			if diagnostic_fit.has_unsafe_failure():
				break
		print("HOLD: diagnostic queried %d of %d sides; whole-island fit and all actual approaches remain untested" % [queried, diagnostic_units.size() * 4])
		h.main.queue_free()
		quit(1)
		return
	var accepted := Catalog.accepted_units()
	if accepted.is_empty():
		print("FAIL: the catalog has no accepted buildings to check")
		quit(1)
		return
	var fit := BuildingFit.new(h)
	var failures: Array[String] = []
	var checked := 0
	var walk_started := Time.get_ticks_msec()
	var ticks := Engine.get_physics_frames()
	var drawn := Engine.get_frames_drawn()
	var drawing := _stop_drawing()
	for unit: Dictionary in accepted:
		var key := str(unit.anchor_source_key)
		failures.append_array(await fit.check(key, true, "%s: " % key, unit.get("stairs", [])))
		checked += 1
		if fit.has_unsafe_failure():
			failures.append("island checks stopped after unsafe failure at %s; %d remaining buildings untested" % [key, accepted.size() - checked])
			break
	_resume_drawing(drawing)
	print("NOTE: island loaded in %.0f s; walked %d of %d scored buildings in %.0f s (%d physics ticks, %d frames drawn)" % [(walk_started - load_started) / 1000.0, checked, accepted.size(), (Time.get_ticks_msec() - walk_started) / 1000.0, Engine.get_physics_frames() - ticks, Engine.get_frames_drawn() - drawn])
	if failures.is_empty():
		var on := h.world.get_street_detail_layers()
		print("PASS: island loads and all %d scored buildings fit%s, street detail %s" % [accepted.size(), " (prebuilt native world)" if prebuilt else "", "on: " + ",".join(PackedStringArray(on)) if not on.is_empty() else "off"])
	else:
		for message in failures:
			print("FAIL: " + message)
	h.main.queue_free()
	quit(0 if failures.is_empty() else 1)


## The fit checks read collision and the renderer's mesh data, never pixels, so
## nothing is drawn while they walk: drawing the island on every tick made the
## walks about 50 times slower, which a compositor idle timeout once hid
## (LEARNINGS.md). Vsync goes off too: Godot's Wayland backend paces vsync by
## waiting for the compositor's frame callback, none comes while nothing is
## drawn, and it would stall up to a second at a time.
## Returns what _resume_drawing restores.
func _stop_drawing() -> Array:
	var saved := [RenderingServer.render_loop_enabled, DisplayServer.window_get_vsync_mode()]
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	RenderingServer.render_loop_enabled = false
	return saved


func _resume_drawing(saved: Array) -> void:
	RenderingServer.render_loop_enabled = saved[0]
	DisplayServer.window_set_vsync_mode(saved[1])
