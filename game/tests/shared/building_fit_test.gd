extends SceneTree
## Checks that a building fits into the island and plays right, in the real loaded world.
##
##   tools/godot --path . --script game/tests/shared/building_fit_test.gd -- --source w291189336
##
## 1. Roof: wherever the building is visible from above, the player can stand on it
##    (collision is there, not just a picture of a roof).
## 2. Walls: wherever a wall is visible at chest height, it also blocks the player.
## 3. Grounded: visible walls reach down to the ground next to them (no floating building).
## 4. Walk-up: from each side the stock player walks up to the building, arrives
##    next to it (within 1.5 m), stays on the ground and never needs a fall
##    recovery. Ending up under the building (carport, arcade) is only noted;
##    walking through walls is check 2.
## 5. Stairs: each flight listed in the building's catalog entry as
##    "stairs": [{"bottom": [x, z], "top": [x, z]}] is walked up and back down.
## A check with nothing to sample fails: it would otherwise pass untested.
##
## Prints PASS or FAIL lines and exits non-zero on failure.
## Optional --routes FILE: {"source":"KEY", "routes":[{"name":"passage",
## "start_xz":[x,z], "end_xz":[x,z]}]}. Each route is walked in both directions.
## Optional --spray FILE: {"source":"KEY", "player_xz":[x,z], "target_xyz":[x,y,z]}.
## Optional --diagnose-side north|south|west|east: native candidate queries only,
## without placement/movement. Always reports whole-building HOLD and exits1.

const WorldHarness := preload("res://game/tests/shared/world_harness.gd")
const BuildingFit := preload("res://game/tests/shared/building_fit.gd")
const Catalog := preload("res://game/tests/shared/catalog.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	# Validate exact option/value pairs before the permissive shared parser.
	# Consumed paths are values, even when their filenames resemble options.
	var raw_args := OS.get_cmdline_user_args()
	var seen := {}
	var index := 0
	while index < raw_args.size():
		var flag := raw_args[index]
		if flag not in ["--source", "--routes", "--spray", "--diagnose-side"] or seen.has(flag):
			push_error("unsupported or duplicate option: " + flag)
			quit(1)
			return
		if index + 1 >= raw_args.size() or raw_args[index + 1].is_empty() or raw_args[index + 1].begins_with("--"):
			push_error("missing value for " + flag)
			quit(1)
			return
		seen[flag] = true
		index += 2
	var args := WorldHarness.user_args()
	if not args.has("source"):
		push_error("usage: -- --source KEY")
		quit(1)
		return
	var source_key := str(args.source)
	var diagnostic_side := str(args.get("diagnose-side", ""))
	if args.has("diagnose-side"):
		if diagnostic_side not in ["north", "south", "west", "east"] or args.has("routes") or args.has("spray"):
			push_error("--diagnose-side needs one cardinal side and cannot combine routes/spray")
			quit(1)
			return
		print("DIAGNOSTIC ONLY: whole-building HOLD; no four-side, fit or acceptance credit")
	var routes: Array = []
	if args.has("routes"):
		var plan: Variant = JSON.parse_string(FileAccess.get_file_as_string(str(args.routes)))
		if not plan is Dictionary or plan.get("source", "") != source_key or not plan.get("routes") is Array or plan.routes.is_empty():
			push_error("routes need a nonempty route list bound to --source")
			quit(1)
			return
		routes = plan.routes
	var spray_case: Dictionary = {}
	if args.has("spray"):
		var plan: Variant = JSON.parse_string(FileAccess.get_file_as_string(str(args.spray)))
		if not plan is Dictionary or plan.get("source", "") != source_key:
			push_error("spray needs a source-bound plan")
			quit(1)
			return
		spray_case = plan
	var h := WorldHarness.new(self)
	var error := await h.load_world()
	if error != "":
		push_error(error)
		quit(1)
		return
	if diagnostic_side != "":
		var diagnostic_error := BuildingFit.new(h).diagnose_side(source_key, diagnostic_side)
		print("DIAGNOSTIC ONLY: " + ("candidate queries completed" if diagnostic_error == "" else diagnostic_error))
		print("HOLD: whole-building fit and four actual approaches were not tested")
		h.main.queue_free()
		quit(1)
		return
	var stairs: Array = Catalog.unit_for(source_key).get("stairs", [])
	var failures := await BuildingFit.new(h).check(source_key, true, "", stairs, routes, spray_case)
	if failures.is_empty():
		print("PASS: building %s fits and plays" % source_key)
	else:
		for message in failures:
			print("FAIL: " + message)
	h.main.queue_free()
	quit(0 if failures.is_empty() else 1)
