extends "res://game/tests/p1_existing_live_revalidation_capture.gd"
const ART=preload("res://game/scripts/world/facades/d5_1317_quality_candidate.gd")
var _output: String=""
func _run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="):_output=arg.trim_prefix("--output=")
	if not _require(_output.is_absolute_path() and not DirAccess.dir_exists_absolute(_output),"Fresh absolute output required"):_finish(null);return
	DirAccess.make_dir_recursive_absolute(_output)
	var main: GameMain=(load("res://game/scenes/main.tscn") as PackedScene).instantiate()
	var world: WorldLoader=main.get_node("WorldRoot");var player: PlayerController=main.get_node("Player");var hud: GameHUD=main.get_node("Interface/HUD")
	var ready: Array=[];var errors: Array=[]
	world.world_ready.connect(func(r):ready.append(r));world.world_failed.connect(func(c,m,s):errors.append([c,m,s]))
	root.add_child(main)
	while ready.is_empty() and errors.is_empty():await process_frame
	if not _require(errors.is_empty(),"Actual world failed "+str(errors)):_finish(main);return
	# Preserve the main scene's own initial grounded reveal before relocating.
	# Startup descent uses a fixed slow velocity; moving it3m early prevents settling.
	while not player.was_first_reveal_grounded() and errors.is_empty():await physics_frame
	if not _require(errors.is_empty() and player.was_first_reveal_grounded(),"Stock startup grounding failed"):_finish(main);return
	var owners: Array[Node3D]=_nodes_for_keys(world,[ART.BASE.WALL_KEY,ART.BASE.ROOF_KEY])
	if not _require(owners.size()==2,"Exact target pair required"):_finish(main);return
	var wall_root: Node3D;var roof_root: Node3D
	for node: Node3D in owners:
		if node.get_meta("derived_object_key")==ART.BASE.WALL_KEY:wall_root=node
		else:roof_root=node
	var config: Dictionary=ART.BASE._json(ART.BASE.CONFIG_PATH)
	var chunk: Dictionary=ART.BASE._json(ART.BASE.CHUNK_PATH)
	var wall: Dictionary=ART.BASE._record(chunk.records,ART.BASE.WALL_KEY)
	var poses: Array=[]
	for original: Dictionary in config.capture.poses.slice(0,2):
		var f: Dictionary=ART.BASE._joined_frame(wall,int(original.runs[0]),int(original.runs[-1]))
		var target: Vector3=ART.BASE._point(f,float(original.station_m),5.35,0.0)
		if original.id=="whole_ene":target=ART.BASE._point(f,float(f.length_m)*0.5,5.15,0.0)
		poses.append({"id":original.id,"requested_xz":Vector2(original.player_xz[0],original.player_xz[1]),"aim_target":target})
	var captures: Array=[]
	var before: Array=_collisions(owners)
	var baseline: Dictionary=await _picture(player,world,hud,poses[0],"01-baseline-whole.png")
	captures.append(baseline)
	_write_json(_output.path_join("capture-progress.json"),{"captures":captures})
	if not _require(bool(baseline.ok),"Baseline pose/capture failed: "+str(baseline)):_finish(main);return
	player.set_gameplay_enabled(false)
	var candidate: Dictionary=ART.apply_to_pair(wall_root,roof_root,wall)
	if not _require(bool(candidate.ok),str(candidate.get("message","Art wrapper failed"))):_finish(main);return
	for i in 6:await physics_frame
	var after: Array=_collisions(owners)
	if not _require(before==after,"Structural source collisions changed"):_finish(main);return
	for i in poses.size():
		var picture: Dictionary=await _picture(player,world,hud,poses[i],"0%d-candidate-%s.png"%[i+2,poses[i].id])
		captures.append(picture)
		_write_json(_output.path_join("capture-progress.json"),{"captures":captures})
		if not _require(bool(picture.ok),"Candidate pose/capture failed"):_finish(main);return
	_clear_gameplay_input();Input.action_release("spray");player.set_gameplay_enabled(false)
	_write_json(_output.path_join("capture.json"),{"scope":"isolated1317art; unchanged production assets/authority; no mechanics acceptance","candidate":candidate,"captures":captures,"collisions_unchanged":before==after,"collision_snapshot":after,"source_chunk":ART.BASE.CHUNK_PATH,"source_chunk_sha256":FileAccess.get_sha256(ART.BASE.CHUNK_PATH),"candidate_sha256":FileAccess.get_sha256("res://game/scripts/world/facades/d5_1317_quality_candidate.gd")})
	print("1317_QUALITY_CAPTURE_COMPLETE")
	_finish(main)
func _picture(player: PlayerController,world: WorldLoader,hud: GameHUD,pose: Dictionary,name: String) -> Dictionary:
	var settled: Dictionary=await _settle_and_aim(world,player,hud,pose)
	if not bool(settled.get("ok",false)):return {"ok":false,"pose":settled}
	for i in 6:await physics_frame
	await RenderingServer.frame_post_draw
	var path: String=_output.path_join(name)
	return {"ok":root.get_texture().get_image().save_png(path)==OK,"file":path,"pose":settled.metadata}
func _collisions(owners: Array[Node3D]) -> Array:
	var rows: Array=[]
	for owner: Node3D in owners:
		for body: Node in owner.get_children():
			if not body is StaticBody3D:continue
			for shape: Node in body.get_children():
				if shape is CollisionShape3D:
					rows.append({"owner":owner.get_meta("derived_object_key"),"body":str(body.name),"shape":str(shape.name),"layer":body.collision_layer,"body_transform":str(body.global_transform),"shape_transform":str(shape.transform),"faces":str((shape.shape as ConcavePolygonShape3D).get_faces())})
	return rows
