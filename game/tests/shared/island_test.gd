extends SceneTree
## The whole island: it loads and every building counted in the recognition
## score passes the full fit check (solid, grounded, walk-up, stairs).
##
##   tools/godot --headless --fixed-fps 60 --path . --script game/tests/shared/island_test.gd
##
## --fixed-fps 60 lets the walking simulation run as fast as the CPU allows.

const WorldHarness := preload("res://game/tests/shared/world_harness.gd")
const BuildingFit := preload("res://game/tests/shared/building_fit.gd")
const Catalog := preload("res://game/tests/shared/catalog.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var h := WorldHarness.new(self)
	var error := await h.load_world()
	if error != "":
		print("FAIL: " + error)
		quit(1)
		return
	var accepted := Catalog.accepted_units()
	if accepted.is_empty():
		print("FAIL: the catalog has no accepted buildings to check")
		quit(1)
		return
	var fit := BuildingFit.new(h)
	var failures: Array[String] = []
	for unit: Dictionary in accepted:
		var key := str(unit.anchor_source_key)
		failures.append_array(await fit.check(key, true, "%s: " % key, unit.get("stairs", [])))
	if failures.is_empty():
		print("PASS: island loads and all %d scored buildings fit" % accepted.size())
	else:
		for message in failures:
			print("FAIL: " + message)
	h.main.queue_free()
	quit(0 if failures.is_empty() else 1)
