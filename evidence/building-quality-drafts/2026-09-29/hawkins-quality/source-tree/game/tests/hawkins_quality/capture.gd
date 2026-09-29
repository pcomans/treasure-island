extends "res://game/tests/rendered_visual_evidence_capture.gd"
const MODEL_PATH := "res://game/tests/hawkins_quality/candidate.gd"
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
	while ready.is_empty() and errors.is_empty() and Time.get_ticks_msec()-begin < 90000: await process_frame
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
		row.aim_target = Vector3(target.aim_target[0],target.aim_target[1],target.aim_target[2])
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
		var saved := _save_current_view(row,output,player,{"phase":"A","baseline":str(manifest.baseline),"source_key":target.source_key})
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
		var old_facade := wall_node.find_child("Hawkins77BrutonFacade",true,false) as Node3D
		if not _require(old_facade!=null,"Exact accepted Hawkins facade required"): break
		var model: Node3D = load(MODEL_PATH).new()
		var built: Dictionary = model.configure(wall,load("res://game/scripts/world/massing/hawkins_77_bruton_massing.gd").massing_contract())
		if not _require(bool(built.get("ok",false)) and bool(model.get_meta("build_valid",false)),"Candidate native detail contacts must build before replacement"):
			model.free()
			break
		model.set_meta("render_only",false)
		model.set_meta("collision","native facade detail faces; accepted shell contacts retained")
		model.set_meta("maximum_relief_m",0.83)
		var changed: Array = [old_facade]
		var old_states: Array = []
		var old_roof_visible: bool = roof_node.visible
		old_facade.visible=false
		world.add_child(model)
		if not await _wait_for_render(player):
			_restore_candidate(model,changed,old_states)
			roof_node.visible=old_roof_visible
			break
		if not _require(player.get_camera().global_transform.is_equal_approx(fixed_camera) and light_state == [sun.global_transform,sun.light_color,sun.light_energy,sun.light_indirect_energy,sun.shadow_enabled],"A/B camera/light drift"):
			_restore_candidate(model,changed,old_states)
			roof_node.visible=old_roof_visible
			break
		row.id = target.id+"-B"
		saved = _save_current_view(row,output,player,{"phase":"B","source_key":target.source_key,"scope":"Hawkins isolated facade assemblies; accepted shell/wall/roof contacts and source footprint/foundation/terrain preserved; stock mechanics pending"})
		_restore_candidate(model,changed,old_states)
		roof_node.visible=old_roof_visible
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

func _restore_candidate(model: Node3D,changed: Array,old_states: Array) -> void:
	# Remove new contact ownership before re-enabling the exact original state.
	for body: CollisionObject3D in model.find_children("*","CollisionObject3D",true,false):
		body.collision_layer=0
		body.collision_mask=0
		body.remove_from_group("spray_receiver_wall")
	model.queue_free()
	for state: Dictionary in old_states:
		var body: CollisionObject3D=state.body
		body.collision_layer=state.layer
		body.collision_mask=state.mask
		if state.spray: body.add_to_group("spray_receiver_wall")
	for node: Node3D in changed: node.visible=true
