extends SceneTree
## Startup configuration, headless.
##   - Sound is a product requirement (owner, 2026-11-14), so project.godot no
##     longer forces the Dummy audio driver for the game (2026-08-31 forced it on
##     every platform after a macOS launch hung in CoreAudio while the host's audio
##     service was stopped; the game had no sound then): neither audio/driver/driver
##     nor any of its feature overrides (driver.macos, driver.web, ...) may name
##     Dummy, so each platform plays through its own driver. Every development,
##     test, capture and build launch still runs on Dummy, by tools/godot's default
##     and the --audio-driver Dummy that tools/test.sh and tools/build-mac.sh pass.
##     This test runs headless, and a headless Godot is on Dummy whatever it is
##     told, so its own driver shows nothing about that default: the wrapper's
##     guard is tools/check_godot_weston_wait.sh, which checks that tools/godot adds
##     --audio-driver Dummy unless a driver is given. (This test checked the
##     opposite until the owner's 2026-11-14 decision changed its premise.)
##   - The game's buses load from project.godot's bus layout: SFX, Ambience and UI,
##     each into Master (game/scripts/audio/sound.gd).
##   - The building catalog's scores read (below).

const SILENT_DRIVER := "Dummy"
const BUSES := ["SFX", "Ambience", "UI"]
const CATALOG_PATH := "res://discovery/facades/facade-recognition-catalog.json"
const DEMOLISHED_PATH := "res://tools/config/demolished-buildings.json"


func _initialize() -> void:
	var project_config := ConfigFile.new()
	var load_error := project_config.load("res://project.godot")
	if load_error != OK:
		_fail("Could not load project.godot: %s" % error_string(load_error))
		return
	if project_config.has_section("audio"):
		for key: String in project_config.get_section_keys("audio"):
			if (key == "driver/driver" or key.begins_with("driver/driver.")) and str(project_config.get_value("audio", key, "")) == SILENT_DRIVER:
				_fail("project.godot sets audio/%s to Dummy: the game has sound, so each platform must use its own driver (tools/godot keeps development and test runs on Dummy)." % key)
				return
	# Headless, Godot is on Dummy whatever it is told (see above): this only says
	# the test did run headless; tools/check_godot_weston_wait.sh guards the wrapper.
	if AudioServer.get_driver_name() != SILENT_DRIVER:
		_fail("This headless test ran on the %s audio driver, not Dummy: run it with --headless (tools/check_godot_weston_wait.sh checks tools/godot's Dummy default)." % AudioServer.get_driver_name())
		return
	var layout := str(ProjectSettings.get_setting("audio/buses/default_bus_layout", ""))
	if not ResourceLoader.exists(layout) or not load(layout) is AudioBusLayout:
		_fail("project.godot's audio/buses/default_bus_layout (%s) is not a bus layout." % layout)
		return
	for bus: String in BUSES:
		var index := AudioServer.get_bus_index(bus)
		if index <= 0 or AudioServer.get_bus_send(index) != &"Master":
			_fail("The %s bus is missing or does not send to Master (index %d)." % [bus, index])
			return
	var catalog_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	if not (catalog_value is Dictionary):
		_fail("The building catalog did not parse.")
		return
	var demolished_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(DEMOLISHED_PATH))
	if not (demolished_value is Dictionary) or not (demolished_value as Dictionary).get("entries", null) is Array:
		_fail("The demolished-buildings config did not parse.")
		return
	var listed: Dictionary = {}
	for entry: Dictionary in (demolished_value as Dictionary).entries:
		listed[str(entry.get("source_key", ""))] = true
	# Every building has exactly one recognition status: accepted ones carry the
	# reviewer verdict they were accepted on, and demolished ones are exactly the
	# buildings the demolished-buildings config leaves out of the world. The score
	# counts the accepted buildings among those still standing.
	var units := (catalog_value as Dictionary).get("units", []) as Array
	var accepted := 0
	var standing := 0
	for unit: Dictionary in units:
		var status := str((unit.get("claim_status", {}) as Dictionary).get("reference_recognizable", ""))
		var key := str(unit.get("anchor_source_key", ""))
		if (status == "demolished") != listed.has(key):
			_fail("%s: catalog status '%s' disagrees with %s." % [unit.get("unit_id", "?"), status, DEMOLISHED_PATH])
			return
		if status == "demolished":
			if not unit.get("demolition", null) is Dictionary:
				_fail("%s is demolished without its demolition record." % unit.get("unit_id", "?"))
				return
			listed.erase(key)
			continue
		standing += 1
		if status == "accepted":
			accepted += 1
			if (unit.get("acceptance_records", []) as Array).is_empty():
				_fail("%s is accepted without a reviewer verdict." % unit.get("unit_id", "?"))
				return
		elif status != "not_evaluated":
			_fail("%s has unknown recognition status '%s'." % [unit.get("unit_id", "?"), status])
			return
	if not listed.is_empty():
		_fail("Demolished buildings missing from the catalog: %s" % ", ".join(PackedStringArray(listed.keys())))
		return
	if standing == 0:
		_fail("The catalog lists no standing buildings.")
		return
	print("PASS: the game picks each platform's own audio driver (project.godot forces none; this headless run is on Dummy, as any headless run is, and tools/check_godot_weston_wait.sh checks tools/godot's own Dummy default); buses %s load into Master; catalog score %d/%d (%d demolished)" % [", ".join(PackedStringArray(BUSES)), accepted, standing, units.size() - standing])
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
