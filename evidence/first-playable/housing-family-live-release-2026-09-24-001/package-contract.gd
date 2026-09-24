extends SceneTree
# External source/mounted consumer of the product's same live-adoption validator.
const ADOPTION = preload("res://game/scripts/world/facades/housing_family_live_attachment.gd")
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var pck := ""
	var expected := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--pck="): pck=arg.trim_prefix("--pck=")
		if arg.begins_with("--pck-sha256="): expected=arg.trim_prefix("--pck-sha256=")
	if not pck.is_empty():
		if expected.is_empty() or FileAccess.get_sha256(pck)!=expected or FileAccess.file_exists("res://project.godot") or not FileAccess.file_exists("res://project.binary"):
			push_error("Exact mounted package boundary failed");quit(1);return
	var main := (load("res://game/scenes/main.tscn") as PackedScene).instantiate()
	var world := main.get_node("WorldRoot")
	var load_failure := {"message": ""}
	world.world_failed.connect(func(code: String, message: String, _keys: Array) -> void: load_failure.message = code + ": " + message)
	root.add_child(main)
	var deadline := Time.get_ticks_msec() + 120000
	while not world.is_world_validated() and str(load_failure.message).is_empty() and Time.get_ticks_msec() < deadline:
		await process_frame
	if not world.is_world_validated():
		push_error("Normal world not validated: " + str(load_failure.message));main.free();quit(1);return
	var result: Dictionary = ADOPTION.validate_live(world)
	if not bool(result.get("ok",false)):
		push_error("Family adoption contract: "+str(result));main.free();quit(1);return
	print("FAMILY_RELEASE_COMPONENT_PASS ",JSON.stringify(result))
	main.free()
	quit(0)
