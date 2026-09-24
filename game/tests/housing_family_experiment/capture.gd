extends "res://game/tests/rendered_visual_evidence_capture.gd"
const FAMILY = preload("res://game/scripts/world/facades/housing_site_family.gd")
var output := ""
var rows: Array = []

func _initialize() -> void:
	create_timer(480.0,true,false,true).timeout.connect(func(): _fail("Experiment timeout"); _receipt(); quit(1))
	call_deferred("_run")

func _run() -> void:
	var manifest_path := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--manifest="): manifest_path = arg.trim_prefix("--manifest=")
		if arg.begins_with("--output="): output = arg.trim_prefix("--output=")
	if not _require(not output.is_empty() and not DirAccess.dir_exists_absolute(output), "Fresh output required"):
		await _finish(null)
		return
	DirAccess.make_dir_recursive_absolute(output)
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	var main := (load("res://game/scenes/main.tscn") as PackedScene).instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var ready: Array = []
	var errors: Array = []
	world.world_ready.connect(func(r: Dictionary): ready.append(r))
	world.world_failed.connect(func(c: String,m: String,k: Array): errors.append([c,m,k]))
	root.add_child(main)
	var begin := Time.get_ticks_msec()
	while ready.is_empty() and errors.is_empty() and Time.get_ticks_msec()-begin < 45000: await process_frame
	if not _require(errors.is_empty() and ready.size()==1 and world.is_world_validated(), "Source world load: %s" % [errors]):
		_receipt()
		await _finish(main)
		return
	(main.get_node("Interface/HUD") as GameHUD).hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for target: Dictionary in manifest.targets:
		var key := "building:"+str(target.source_key)
		var wall_node := _record_node_for_key(world,key+":wall")
		var roof_node := _record_node_for_key(world,key+":roof")
		if not _require(wall_node != null and roof_node != null, "Missing exact source pair "+key): break
		var row: Dictionary = target.duplicate(true)
		row.requested_xz = Vector2(target.requested_xz[0],target.requested_xz[1])
		row.aim_target = FAMILY.vec(target.aim_target)
		var settled := await _settle_player(row.requested_xz,row.id,world,player)
		if not _require(settled.get("ok",false),str(settled)): break
		_aim_camera_at(player,row.aim_target)
		for frame in 6:
			_force_unpaused(player)
			await physics_frame
		if not await _wait_for_render(player): break
		var fixed_camera := player.get_camera().global_transform
		var sun := main.get_node("Sun") as DirectionalLight3D
		var light_state := [sun.global_transform,sun.light_color,sun.light_energy,sun.light_indirect_energy,sun.shadow_enabled]
		row.id = target.id+"-A"
		var saved := _save_current_view(row,output,player,{"phase":"A","baseline":"9c7f2440d3db6a7f2d0a5d474c612c0362a01c16","source_key":target.source_key})
		if not _require(saved.get("ok",false),str(saved)): break
		rows.append(saved.metadata)
		var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(target.config))
		var chunk: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(target.chunk))
		var wall: Dictionary = {}
		var roof: Dictionary = {}
		for record: Dictionary in chunk.records:
			if record.object_key == key+":wall": wall = record
			if record.object_key == key+":roof": roof = record
		if not _require(not wall.is_empty() and not roof.is_empty() and str(cfg.target.source_key)==str(target.source_key),"Instance/source identity mismatch"):
			break
		var changed: Array = []
		for receiver in ([wall_node] if bool(cfg.get("retain_production_roof",false)) else [wall_node,roof_node]):
			for node: Node in receiver.find_children("*","MeshInstance3D",true,false):
				if node.visible and not (bool(cfg.get("retain_production_roof",false)) and str(node.get_meta("physical_role","")) == "ground_visual"):
					changed.append(node)
					node.visible = false
		var model := FAMILY.build(wall,roof,cfg)
		world.add_child(model)
		if not await _wait_for_render(player):
			model.queue_free()
			for node in changed: node.visible=true
			break
		if not _require(player.get_camera().global_transform.is_equal_approx(fixed_camera) and light_state == [sun.global_transform,sun.light_color,sun.light_energy,sun.light_indirect_energy,sun.shadow_enabled],"A/B camera/light drift"):
			model.queue_free()
			for node in changed: node.visible=true
			break
		row.id = target.id+"-B"
		saved = _save_current_view(row,output,player,{"phase":"B","source_key":target.source_key,"scope":"Shared family visual experiment; original collision and receivers retained"})
		model.queue_free()
		for node in changed: node.visible=true
		if not _require(saved.get("ok",false),str(saved)): break
		rows.append(saved.metadata)
		_receipt()
		await process_frame
	if rows.size()!=manifest.targets.size()*2: _fail("Incomplete A/B pairs")
	_receipt()
	await _finish(main)

func _receipt() -> void:
	if output.is_empty() or not DirAccess.dir_exists_absolute(output): return
	var file := FileAccess.open(output.path_join("capture-receipt.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify({"ok":_failure.is_empty(),"failure":_failure,"captures":rows,"scope":"Visual experiment, no acceptance or collision fit claim"},"\t")+"\n")
