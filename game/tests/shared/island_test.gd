extends SceneTree
## The whole island: it loads and every building counted in the recognition
## score passes the full fit check (solid, grounded, walk-up, stairs).
##
##   tools/godot --fixed-fps 60 --path . --script game/tests/shared/island_test.gd
##
## --fixed-fps 60 lets the walking simulation run as fast as the CPU allows.
## Optional -- --use-prebuilt-world: run the same checks on the baked native
## world that desktop exports load (bake it first: tools/prebuild-static-world.sh native).
## Optional -- --street-detail on|off or --street-detail-layers vegetation,fences:
## the street-detail layers to load (default: the project setting, on).
## Optional -- --diagnose-after SOURCE: query four sides of subsequent scored
## units only, without placement/input; always diagnostic HOLD and exit1.
## Optional -- --walk-up-predictions: without placement or input, compare each
## scored side's first start that passes every mandatory check with the start
## the street-detail generator predicted for it (and kept its island clutter out
## of; the generated street detail's audit.clutter.walk_ups). Passes when they
## agree on every side; exits 1 on any difference. No fit or acceptance credit.

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
	var predictions := raw.size() == 1 and raw[0] == "--walk-up-predictions"
	if predictions:
		raw.clear()
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
	if predictions:
		var code := _check_walk_up_predictions(h)
		h.main.queue_free()
		quit(code)
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
	for unit: Dictionary in accepted:
		var key := str(unit.anchor_source_key)
		failures.append_array(await fit.check(key, true, "%s: " % key, unit.get("stairs", [])))
		checked += 1
		if fit.has_unsafe_failure():
			failures.append("island checks stopped after unsafe failure at %s; %d remaining buildings untested" % [key, accepted.size() - checked])
			break
	if failures.is_empty():
		var on := h.world.get_street_detail_layers()
		print("PASS: island loads and all %d scored buildings fit%s, street detail %s" % [accepted.size(), " (prebuilt native world)" if prebuilt else "", "on: " + ",".join(PackedStringArray(on)) if not on.is_empty() else "off"])
	else:
		for message in failures:
			print("FAIL: " + message)
	h.main.queue_free()
	quit(0 if failures.is_empty() else 1)


## Compares every accepted unit's sides (see --walk-up-predictions): the fit
## test's first start passing every mandatory check against the generator's
## predicted lane and margin. Prints each difference and a PASS or FAIL line;
## returns the exit code.
func _check_walk_up_predictions(h: WorldHarness) -> int:
	var manifest_path := h.world.default_manifest_path
	var manifest: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	if not manifest is Dictionary or not manifest.get("street_detail") is Dictionary:
		print("FAIL: walk-up predictions: no street detail in %s" % manifest_path)
		return 1
	var detail: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path.get_base_dir().path_join(str(manifest.street_detail.get("path", "")))))
	var walk_ups: Variant = detail.get("audit", {}).get("clutter", {}).get("walk_ups") if detail is Dictionary else null
	if not walk_ups is Array or walk_ups.is_empty():
		print("FAIL: walk-up predictions: the generated street detail has no audit.clutter.walk_ups")
		return 1
	var predicted := {}
	for entry: Variant in walk_ups:
		predicted["%s/%s" % [entry.get("source_key", ""), entry.get("side", "")]] = "lane %.2f / %.1f m" % [float(entry.get("lane", 0.0)), float(entry.get("margin_m", 0.0))]
	var fit := BuildingFit.new(h)
	var sides := 0
	var differences: Array[String] = []
	for unit: Dictionary in Catalog.accepted_units():
		var key := str(unit.anchor_source_key)
		var starts := fit.walk_up_starts(key)
		if not starts.ok:
			print("FAIL: walk-up predictions: %s: %s" % [key, starts.reason])
			return 1
		for side: String in ["north", "south", "west", "east"]:
			sides += 1
			var test_start := str(starts.sides[side].first_viable)
			# The generator predicts lanes only: a side whose first open start is
			# a native-wall anchor, or that has none, has no predicted lane either.
			if not test_start.begins_with("lane "):
				test_start = ""
			var generator_start := str(predicted.get("%s/%s" % [key, side], ""))
			if test_start != generator_start:
				differences.append("%s/%s: test %s, generator %s" % [key, side, test_start if test_start != "" else "no open lane", generator_start if generator_start != "" else "no open lane"])
	for difference in differences:
		print("FAIL: walk-up prediction differs: " + difference)
	if not differences.is_empty():
		print("FAIL: walk-up predictions differ on %d of %d scored sides" % [differences.size(), sides])
		return 1
	print("PASS: walk-up predictions match the fit test's first open start on all %d scored sides" % sides)
	return 0
