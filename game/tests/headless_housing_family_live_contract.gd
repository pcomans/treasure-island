extends "res://game/tests/headless_world_material_contract.gd"

const ADOPTION = preload("res://game/scripts/world/facades/housing_family_live_attachment.gd")

func _initialize() -> void:
	create_timer(180.0,true,false,true).timeout.connect(func(): push_error("Family live contract timed out"); quit(1))
	call_deferred("_run_live")

func _run_live() -> void:
	if not _adoption_negative_controls():
		quit(1)
		return
	var builder := WorldChunkBuilder.new()
	for key: String in EXPECTED_MATERIALS:
		var expected: Dictionary = EXPECTED_MATERIALS[key]
		if not _material_matches(key,builder._material_for(key,str(expected.feature_kind),bool(expected.context)),expected):
			quit(1)
			return
	if not _runtime_tangents_are_present(builder):
		quit(1)
		return
	print("FAMILY_SOURCE_MATERIALS: pass")
	var main := (load("res://game/scenes/main.tscn") as PackedScene).instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var ready: Array = []
	var errors: Array = []
	world.world_ready.connect(func(report: Dictionary): ready.append(report))
	world.world_failed.connect(func(code: String,message: String,keys: Array): errors.append([code,message,keys]))
	root.add_child(main)
	for cycle in range(2):
		var began := Time.get_ticks_msec()
		while (ready.size()<cycle+1 or not main.player.is_on_floor()) and errors.is_empty() and Time.get_ticks_msec()-began<45000:
			await physics_frame
		for frame in range(3): await physics_frame
		if not _require(errors.is_empty() and ready.size()==cycle+1 and world.is_world_validated() and main.player.is_on_floor(),"Normal load/reload or stock grounding failed: %s" % [errors]):
			main.free()
			quit(1)
			return
		main.player.set_gameplay_enabled(false)
		var result := ADOPTION.validate_live(world)
		if not _require(bool(result.get("ok",false)),"Current adoption: %s" % result) or not _connections_once(main):
			main.free()
			quit(1)
			return
		print("FAMILY_SOURCE_RELOAD_CYCLE: "+JSON.stringify({"cycle":cycle,"adoption":result,"connections_once":true,"grounded":true}))
		if cycle==0: world.load_world()
	main.free()
	print("PASS: current 24-instance adoption, existing semantic materials, and actual GameMain reload with single signal connections")
	quit(0)

func _connections_once(main: GameMain) -> bool:
	var evidence = main.world_root.get_runtime_evidence()
	var spray = main.player.get_spray_controller()
	var pairs := [[main.player.feedback_requested,main.hud.show_feedback],[main.player.spray_result,evidence.record_spray],[main.player.recovered,evidence.record_recovery],[spray.spray_identity,evidence.record_spray_identity],[spray.tag_instances.active_count_changed,evidence.set_active_decals],[spray.tag_instances.oldest_tag_removed,evidence.record_tag_eviction]]
	for pair: Array in pairs:
		var matches := 0
		for connection: Dictionary in (pair[0] as Signal).get_connections():
			if connection.callable==pair[1]: matches+=1
		if not _require(matches==1,"GameMain runtime signal must be connected exactly once"): return false
	return true

func _adoption_negative_controls() -> bool:
	var loader_script = load("res://game/scripts/world/facades/facade_runtime_registry_loader.gd")
	var registry: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://game/resources/facades/facade-runtime-registry.json"))
	var contracts: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://game/resources/facades/facade-runtime-adapter-contracts.json"))
	for label in ["missing_adoption","altered_adoption_sha","old_current_scope"]:
		var changed := registry.duplicate(true)
		var changed_contracts := contracts.duplicate(true)
		var code := "appearance_adoption_mismatch"
		if label=="missing_adoption": changed.erase("appearance_adoption")
		elif label=="altered_adoption_sha": changed.appearance_adoption.sha256="0".repeat(64)
		else:
			code="northern_1241_parity_mismatch"
			for adapter: Dictionary in changed.active_runtime_adapters:
				if adapter.receiver_key=="building:w96215674:wall": adapter.active_runtime_contract.behavior_contract.geometry_contract.world_topology_scope="current_integration_topology"
			for plan: Dictionary in changed_contracts.plans:
				if plan.receiver_key=="building:w96215674:wall": plan.behavior_contract.geometry_contract.world_topology_scope="current_integration_topology"
		var result: Dictionary = loader_script.new().load_from_data(changed,changed_contracts)
		if not _require(not result.get("ok",true) and result.get("error_code","")==code,"Adoption negative %s: %s" % [label,result]): return false
		print("FAMILY_ADOPTION_NEGATIVE: "+label+" "+code)
	if not _require(ADOPTION.topology_matches({"n":1},{"n":1.0}) and not ADOPTION.topology_matches({"n":1},{"n":1.1}) and not ADOPTION.topology_matches({"n":1},{"n":"1"}) and not ADOPTION.topology_matches({"n":1},{"other":1}),"Exact numeric topology controls"): return false
	return true
