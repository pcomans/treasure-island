extends SceneTree
## Checks that a building fits into the island and plays right, in the real loaded world.
##
##   tools/godot --headless --path . --script game/tests/shared/building_fit_test.gd -- --source w291189336
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

const WorldHarness := preload("res://game/tests/shared/world_harness.gd")
const BuildingFit := preload("res://game/tests/shared/building_fit.gd")
const Catalog := preload("res://game/tests/shared/catalog.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := WorldHarness.user_args()
	if not args.has("source"):
		push_error("usage: -- --source KEY")
		quit(1)
		return
	var source_key := str(args.source)
	var h := WorldHarness.new(self)
	var error := await h.load_world()
	if error != "":
		push_error(error)
		quit(1)
		return
	var stairs: Array = Catalog.unit_for(source_key).get("stairs", [])
	var failures := await BuildingFit.new(h).check(source_key, true, "", stairs)
	if failures.is_empty():
		print("PASS: building %s fits and plays" % source_key)
	else:
		for message in failures:
			print("FAIL: " + message)
	h.main.queue_free()
	quit(0 if failures.is_empty() else 1)
