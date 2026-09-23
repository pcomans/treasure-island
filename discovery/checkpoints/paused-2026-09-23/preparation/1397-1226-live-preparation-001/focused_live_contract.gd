extends SceneTree
var NEW: Script
var ADAPTER: Script
const BUILDER := preload("res://game/scripts/world/world_chunk_builder.gd")
const WORK := "/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1397-1226-live-preparation-001"
var OLD: Script
var SPEC: Dictionary
var BATCH_SPECS: Array=[]
const OLD_BUILDER := preload("/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1397-1226-live-preparation-001/comparison/current-chunk-builder.gd")
const OBSERVED := preload("/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1397-1226-live-preparation-001/observed_builder.gd")
const RETAINED := preload("res://game/scripts/world/facades/northern_canopy_free_live_replacement.gd")
const RETAINED_1238 := preload("res://game/scripts/world/facades/northpoint_1238_live_replacement.gd")
const RETAINED_1206 := preload("res://game/scripts/world/facades/mariner_1206_live_replacement.gd")
const RETAINED_1219 := preload("res://game/scripts/world/facades/mariner_1219_live_replacement.gd")
const RETAINED_1212 := preload("res://game/scripts/world/facades/mariner_1212_live_replacement.gd")
const RETAINED_1220 := preload("res://game/scripts/world/facades/bayside_1220_live_replacement.gd")
const RETAINED_1239 := preload("res://game/scripts/world/facades/northpoint_1239_live_replacement.gd")
const RETAINED_1222 := preload("res://game/scripts/world/facades/bayside_1222_live_replacement.gd")
const RETAINED_1227 := preload("res://game/scripts/world/facades/northpoint_1227_live_replacement.gd")
const RETAINED_1202 := preload("res://game/scripts/world/facades/mariner_1202_live_replacement.gd")
const RETAINED_1234 := preload("res://game/scripts/world/facades/northpoint_1234_live_replacement.gd")
const RETAINED_1215 := preload("res://game/scripts/world/facades/bayside_1215_live_replacement.gd")
const RETAINED_1232 := preload("res://game/scripts/world/facades/northpoint_1232_live_replacement.gd")
const RETAINED_1241 := preload("res://game/scripts/world/facades/northpoint_1241_live_replacement.gd")
const RETAINED_1221 := preload("res://game/scripts/world/facades/mariner_1221_live_replacement.gd")
const RETAINED_1240 := preload("res://game/scripts/world/facades/northpoint_1240_live_replacement.gd")
const COUNTERS := ["mesh_instances", "surfaces", "triangles", "static_bodies", "shapes"]
var failures: Array[String] = []
var checks := 0
func _initialize() -> void: call_deferred("_run")
func _select(spec: Dictionary) -> void:
	SPEC=spec
	NEW=load("res://"+str(spec.factory)) as Script
	ADAPTER=load("res://"+str(spec.wrapper)) as Script
	OLD=load("/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1397-1226-live-preparation-001/comparison/study-"+str(spec.number)+".gd") as Script
func _observer() -> RefCounted:
	var observer: RefCounted=OBSERVED.new()
	observer.target_keys=[ADAPTER.WALL_KEY,ADAPTER.ROOF_KEY]
	return observer
func _run() -> void:
	_check(FileAccess.file_exists(WORK+"/SOURCE_EVIDENCE_BINDINGS.json"),"Actual accepted1397 and1226 source/mechanics/motion evidence bindings required.")
	if not failures.is_empty(): _end({}); return
	var specs: Array=JSON.parse_string(FileAccess.get_file_as_string(WORK+"/unit-expectations.json")) as Array
	_check(specs.size()==2 and specs.map(func(s):return str(s.number))==["1397","1226"],"The exact1397+1226 batch is required.")
	if not failures.is_empty(): _end({}); return
	BATCH_SPECS=specs
	var pins: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(WORK+"/source-pins.json")) as Dictionary
	for path: String in pins: _check(FileAccess.get_sha256(path)==str(pins[path]),"Frozen input "+path)
	var dump: Dictionary={"units":{}}
	var models: Dictionary={}
	for spec: Dictionary in specs:
		_select(spec)
		var result: Dictionary=_run_unit()
		if result.has("model"):
			models[str(spec.source_key)]=result.model
			dump.units[str(spec.source_key)]=result.evidence
	_mixed_plan_cleanup(dump,JSON.parse_string(FileAccess.get_file_as_string(WORK+"/unit-expectations.json")) as Array)
	if models.size()==specs.size(): await _current_world(dump,models,specs)
	for model: Node in models.values(): model.free()
	_end(dump)
func _run_unit() -> Dictionary:
	_check(ADAPTER._dependencies_match(),"Exact live factory/config binding.")
	_check(RETAINED._dependencies_match(),"Retained1201 exact factory/config binding.")
	_check(RETAINED_1238._dependencies_match(),"Retained1238 exact factory/config binding.")
	_check(RETAINED_1206._dependencies_match(),"Retained1206 exact factory/config binding.")
	_check(RETAINED_1219._dependencies_match(),"Retained1219 exact factory/config binding.")
	var reg: Dictionary = NEW._json("res://game/resources/facades/facade-runtime-registry.json")
	var accepted_registry: Dictionary = NEW._json(WORK+"/accepted-registry-before.json")
	_check(reg.recognition_metric.display=="32/213" and reg.units.size()==213,"Published 32/213 authority and 213 units.")
	_check(reg.units==accepted_registry.units,"All 213 published unit records and prior acceptance/adapter bindings remain exact.")
	_check(not NEW._same_numeric_runs([8.5],[8]) and not NEW._same_numeric_runs(["8"],[8]) and not NEW._same_numeric_runs([true],[1]) and not NEW._same_numeric_runs([NAN],[0]) and not NEW._same_numeric_runs([INF],[0]) and NEW._same_numeric_runs([8.0],[8]),"Strict integral scope runs.")
	var chunk: Dictionary = NEW._json(NEW.CHUNK_PATH)
	var prepared: Dictionary = ADAPTER.prepare_chunk_records(chunk)
	_check(bool(prepared.get("ok",false)),"Exact supplied target pair preflight.")
	if not bool(prepared.get("ok",false)): return {}
	var wall: Dictionary = NEW._record(chunk.records,ADAPTER.WALL_KEY)
	var roof: Dictionary = NEW._record(chunk.records,ADAPTER.ROOF_KEY)
	var builder: RefCounted = BUILDER.new()
	var source_builder := Callable(builder,"_build_unpaired_record")
	var tangent_builder := Callable(builder,"_tangents_for")
	for key: String in [ADAPTER.WALL_KEY,ADAPTER.ROOF_KEY]:
		var absent: Dictionary = chunk.duplicate(true); absent.records=absent.records.filter(func(r):return str(r.object_key)!=key)
		_check(not bool(ADAPTER.prepare_chunk_records(absent).ok),"Missing supplied record rejects: "+key)
		var duplicate: Dictionary = chunk.duplicate(true); duplicate.records.append(NEW._record(duplicate.records,key).duplicate(true))
		_check(not bool(ADAPTER.prepare_chunk_records(duplicate).ok),"Duplicate supplied record rejects: "+key)
		var drift: Dictionary = chunk.duplicate(true); var row: Dictionary=NEW._record(drift.records,key); row.vertices[1]=float(row.vertices[1])+.01
		_check(not bool(ADAPTER.prepare_chunk_records(drift).ok),"Source drift rejects at pair preflight: "+key)
		var altered: Dictionary = prepared.source_records.duplicate(true); altered[key].vertices[0]=float(altered[key].vertices[0])+.001
		_check(not bool(NEW.build_for_records(altered[ADAPTER.WALL_KEY],altered[ADAPTER.ROOF_KEY],source_builder,tangent_builder).get("ok",false)),"Factory rejects supplied drift: "+key)
	var alias: Dictionary = chunk.duplicate(true); var extra: Dictionary=wall.duplicate(true); extra.object_key="building:unexpected:wall"; alias.records.append(extra)
	_check(not bool(ADAPTER.prepare_chunk_records(alias).ok),"Source alias rejects.")
	var moved: Dictionary=chunk.duplicate(true); moved.chunk_id=SPEC.neighbor
	_check(not bool(ADAPTER.prepare_chunk_records(moved).ok),"Moved exact pair rejects.")
	var neighbor: Dictionary=NEW._json("res://generated/world/chunks/"+str(SPEC.neighbor)+".json")
	_check(bool(ADAPTER.prepare_chunk_records(neighbor).ok) and not bool(ADAPTER.prepare_chunk_records(neighbor).contains_target),"Ordinary neighboring chunk passes through.")
	neighbor.records.append(extra)
	_check(not bool(ADAPTER.prepare_chunk_records(neighbor).ok),"Target alias in ordinary neighbor rejects.")
	_check(not bool(NEW.build_for_records(wall,roof,Callable(),tangent_builder).ok) and not bool(NEW.build_for_records(wall,roof,source_builder,Callable()).ok),"Both required invalid callbacks reject.")
	_check(not bool(builder._build_record(wall,false).ok) and not bool(builder._build_record(roof,false).ok),"Both unprepared actual target dispatches fail without generic fallback.")
	var observed: RefCounted=_observer()
	var fresh: Dictionary=NEW.build_for_records(wall,roof,Callable(observed,"_build_unpaired_record"),Callable(observed,"_tangents_for"))
	_check(bool(fresh.get("ok",false)),"Callback factory constructs frozen target geometry.")
	if not bool(fresh.get("ok",false)): return {}
	var model: Node3D=fresh.node as Node3D
	var dump: Dictionary={"factory":fresh.metadata,"callback_counts":_callback_counts(observed),"mesh_comparison":{},"collision_comparison":{}}
	_check_callbacks(observed,"One standalone callback factory",int(SPEC.standalone_detail_callbacks))
	_check(not bool(model.call("configure_records",wall,roof,source_builder,tangent_builder).ok),"Duplicate factory construction rejects.")
	var accepted: Dictionary=OLD.build_for_records(wall,roof)
	_check(bool(accepted.get("ok",false)),"Explicit frozen original-art producer constructs in same runtime.")
	if not bool(accepted.get("ok",false)): model.free(); return {}
	var accepted_node: Node3D=accepted.node as Node3D
	_check(fresh.metadata==accepted.metadata,"Combined factory metadata remains exact accepted-study state.")
	for child: Node in accepted_node.get_children():
		if child is MeshInstance3D:
			var actual: MeshInstance3D=model.get_node_or_null(NodePath(child.name)) as MeshInstance3D
			_check(actual!=null,"Accepted mesh exists: "+str(child.name))
			if actual!=null: dump.mesh_comparison[str(child.name)]=_compare_mesh(actual,child,"Accepted art")
	_check(dump.mesh_comparison.size()==int(SPEC.mesh_count) and _measure(model)==[int(SPEC.mesh_count),int(SPEC.surface_count),int(SPEC.total_triangles),int(SPEC.total_bodies),int(SPEC.total_shapes)],"All source-bound complete native mesh streams and physical counts checked.")
	for path: String in ["OriginalWallRecord","OriginalRoofRecord","PhysicalDetails_NoSprayReceiver","ProjectedUpperWallReceiver"]:
		var a: Node=model.get_node(NodePath(path)); var b: Node=accepted_node.get_node(NodePath(path))
		_check(_snapshot(a)==_snapshot(b),"Exact ordered faces/transforms/layers/masks/groups/metadata: "+path)
		dump.collision_comparison[path]={"equal":_snapshot(a)==_snapshot(b),"actual":_snapshot(a),"original":_snapshot(b)}
	_check_source_faces(model,wall,roof)
	accepted_node.free()
	var wm: Material=builder._material_for("building_wall","building_wall",false)
	var rm: Material=builder._material_for("building_roof","building_roof",false)
	var shared_before: Dictionary={"wall":_material_state(wm),"roof":_material_state(rm)}
	var changed: Dictionary=ADAPTER.prepare_chunk_records(chunk.duplicate(true)); changed.source_records[ADAPTER.WALL_KEY].vertices[1]+=.01
	_check(not bool(ADAPTER.build_chunk_plan(changed,source_builder,tangent_builder).ok),"Prepared source drift rejects before construction.")
	for order: Array in [[wall,roof],[roof,wall]]:
		var plan: Dictionary=ADAPTER.build_chunk_plan(prepared,source_builder,tangent_builder)
		_check(bool(plan.get("ok",false)) and not ADAPTER.plan_was_fully_consumed(plan),"Complete pending pair for either consume order.")
		if not bool(plan.get("ok",false)): continue
		var drifted: Dictionary=wall.duplicate(true); drifted.vertices[0]+=.01
		_check(not bool(ADAPTER.consume_record(drifted,plan).ok) and plan.pending_keys.size()==2,"Consumed drift rejects without consuming pair.")
		var consumed: Dictionary={}
		for record: Dictionary in order: consumed[str(record.object_key)]=ADAPTER.consume_record(record,plan)
		_check(bool(consumed[ADAPTER.WALL_KEY].ok) and bool(consumed[ADAPTER.ROOF_KEY].ok) and ADAPTER.plan_was_fully_consumed(plan),"Both exact rows consumed once.")
		_check(not bool(ADAPTER.consume_record(order[0],plan).ok),"Duplicate consumption rejects.")
		var wr: Dictionary=consumed[ADAPTER.WALL_KEY]; var rr: Dictionary=consumed[ADAPTER.ROOF_KEY]
		_check_pair(wr.node,rr.node,model)
		_check_native_result(wr,"Wall split counters"); _check_native_result(rr,"Roof split counters")
		_check(_counts(wr)==[int(SPEC.wall_mesh_count),int(SPEC.wall_mesh_count),int(SPEC.wall_live_triangles),int(SPEC.wall_bodies),int(SPEC.wall_shapes)] and _counts(rr)==[int(SPEC.roof_mesh_count),int(SPEC.roof_mesh_count),int(SPEC.roof_live_triangles),int(SPEC.roof_bodies),int(SPEC.roof_shapes)],"Direct split counts equal frozen study plus original source.")
		_check(wr.node.get_node("ExactOriginalWallSurfaces").get_active_material(0)==wm and rr.node.get_node("ExactSourceNeutralRoof").get_active_material(0)==rm,"Exact source-builder material resources retained through split.")
		ADAPTER.free_unconsumed(plan)
		_check(is_instance_valid(wr.node) and is_instance_valid(rr.node),"Consumed roots survive pending cleanup.")
		wr.node.free(); rr.node.free()
	var cleanup: Dictionary=ADAPTER.build_chunk_plan(prepared,source_builder,tangent_builder)
	_check(bool(cleanup.get("ok",false)),"Full cleanup fixture builds.")
	if bool(cleanup.get("ok",false)):
		var held_wall: Node=cleanup.records[ADAPTER.WALL_KEY].node; var held_roof: Node=cleanup.records[ADAPTER.ROOF_KEY].node
		ADAPTER.free_unconsumed(cleanup)
		_check(not is_instance_valid(held_wall) and not is_instance_valid(held_roof) and cleanup.records.is_empty() and ADAPTER.plan_was_fully_consumed(cleanup),"Both unconsumed roots freed and pending maps clear.")
	for first: Dictionary in [wall,roof]:
		var half: Dictionary=ADAPTER.build_chunk_plan(prepared,source_builder,tangent_builder)
		_check(bool(half.get("ok",false)),"Half-consumed cleanup fixture builds.")
		if not bool(half.get("ok",false)): continue
		var consumed: Dictionary=ADAPTER.consume_record(first,half)
		var remaining: Node=half.records.values()[0].node
		ADAPTER.free_unconsumed(half)
		_check(not is_instance_valid(remaining) and is_instance_valid(consumed.node),"Either half cleanup frees only pending root.")
		consumed.node.free()
	_check(shared_before=={"wall":_material_state(wm),"roof":_material_state(rm)},"All pair operations preserve supplied material state.")
	_caller_cleanup(chunk,dump)
	_compare_target_chunk(chunk,builder,dump)
	return {"model":model,"evidence":dump}

func _compare_mesh(actual: MeshInstance3D, original: MeshInstance3D, scope: String) -> Dictionary:
	var label: String=scope+": "+str(actual.name)
	_check(actual.name==original.name and actual.transform==original.transform and actual.layers==original.layers and actual.cast_shadow==original.cast_shadow,"Mesh identity/transform/layers/shadows "+label)
	_check(actual.mesh.get_class()==original.mesh.get_class() and actual.mesh.get_surface_count()==original.mesh.get_surface_count(),"Mesh class and complete surface count "+label)
	var report: Dictionary={"surfaces":[],"transform":var_to_bytes(actual.transform).hex_encode(),"layers":actual.layers,"shadow":actual.cast_shadow}
	if actual.mesh.get_surface_count()!=original.mesh.get_surface_count(): return report
	for surface in actual.mesh.get_surface_count():
		var a: Array=actual.mesh.surface_get_arrays(surface); var b: Array=original.mesh.surface_get_arrays(surface)
		_check(a.size()==13 and b.size()==13 and Mesh.ARRAY_MAX==13,"All13 native slots "+label)
		var channels: Dictionary={}
		for channel in Mesh.ARRAY_MAX:
			var av: PackedByteArray=var_to_bytes(a[channel]); var bv: PackedByteArray=var_to_bytes(b[channel])
			var equal: bool=av==bv
			_check(equal,"Exact native slot "+str(channel)+" surface"+str(surface)+" "+label)
			channels[str(channel)]={"equal":equal,"actual_sha256":_bytes_sha(av),"original_sha256":_bytes_sha(bv),"actual_count":0 if a[channel]==null else a[channel].size(),"original_count":0 if b[channel]==null else b[channel].size()}
		var an: Variant=actual.mesh.surface_get_name(surface) if actual.mesh is ArrayMesh else null
		var bn: Variant=original.mesh.surface_get_name(surface) if original.mesh is ArrayMesh else null
		_check(an==bn,"Surface name "+label)
		var am: Dictionary=_material_state(actual.get_active_material(surface)); var bm: Dictionary=_material_state(original.get_active_material(surface))
		_check(am==bm,"Complete stored material, bound shader/texture state "+label)
		report.surfaces.append({"name":an,"channels":channels,"actual_material":am,"original_material":bm})
	return report

func _check_source_faces(model: Node3D,wall: Dictionary,roof: Dictionary) -> void:
	for spec: Array in [["OriginalWallRecord",wall],["OriginalRoofRecord",roof]]:
		var body: StaticBody3D=model.get_node(NodePath(spec[0]+"/Collision")) as StaticBody3D
		var expected := PackedVector3Array()
		var record: Dictionary=spec[1]
		for i in range(0,record.indices.size(),3):
			for index: int in [int(record.indices[i]),int(record.indices[i+2]),int(record.indices[i+1])]:
				expected.append(Vector3(float(record.vertices[index*3]),float(record.vertices[index*3+1]),float(record.vertices[index*3+2])))
		_check(body.get_child_count()==1 and var_to_bytes(body.get_child(0).shape.get_faces())==var_to_bytes(expected),"Original actual-builder ordered source faces: "+str(spec[0]))
	var detail: StaticBody3D=model.get_node("PhysicalDetails_NoSprayReceiver") as StaticBody3D
	_check(detail.get_child_count()==int(SPEC.detail_shape_count) and detail.collision_layer==5 and detail.collision_mask==0 and not detail.is_in_group("spray_receiver_wall") and detail.get_meta("receiver_kind")=="none" and detail.get_meta("derived_object_key")=="prototype:"+ADAPTER.WALL_KEY,"All source-bound separately owned nonreceiver detail shapes preserve prototype identity.")
	for i in NEW.PHYSICAL_BUCKETS.size():
		var label: String=NEW.PHYSICAL_BUCKETS[i]
		var shape: CollisionShape3D=detail.get_child(i) as CollisionShape3D
		var mesh: MeshInstance3D=model.get_node_or_null(NodePath(label)) as MeshInstance3D
		if mesh==null:
			_check(shape.shape.get_faces().is_empty(),"Absent optional visual bucket retains its exact empty physical slot: "+label)
			continue
		var arrays: Array=mesh.mesh.surface_get_arrays(0); var faces := PackedVector3Array()
		for index: int in arrays[Mesh.ARRAY_INDEX]: faces.append(arrays[Mesh.ARRAY_VERTEX][index])
		_check(str(shape.name)==label and shape.shape.get_meta("structural_role")==label and shape.shape.get_meta("receiver_kind")=="none" and var_to_bytes(shape.shape.get_faces())==var_to_bytes(faces),"Ordered detail shape matches native visible faces: "+label)

	var projected: StaticBody3D=model.get_node("ProjectedUpperWallReceiver") as StaticBody3D
	var projected_shape: CollisionShape3D=projected.get_child(0) as CollisionShape3D
	var projected_mesh: MeshInstance3D=model.get_node("ProjectedUpperSiding") as MeshInstance3D
	var projected_arrays: Array=projected_mesh.mesh.surface_get_arrays(0)
	var projected_faces := PackedVector3Array()
	for index: int in projected_arrays[Mesh.ARRAY_INDEX]: projected_faces.append(projected_arrays[Mesh.ARRAY_VERTEX][index])
	var expected_projected_runs: Array[int]=[]
	for run: Variant in SPEC.projected_receiver_runs: expected_projected_runs.append(int(run))
	_check(projected.get_child_count()==1 and projected.collision_layer==5 and projected.collision_mask==0 and projected.is_in_group("spray_receiver_wall") and projected.get_meta("source_run_indices")==expected_projected_runs,"Projected receiver retains only the accepted observed front runs.")
	for projected_owner: Object in [projected,projected_shape.shape]:
		_check(projected_owner.get_meta("receiver_kind")==wall.receiver_kind and projected_owner.get_meta("opaque")==wall.opaque and projected_owner.get_meta("derived_object_key")==wall.object_key and projected_owner.get_meta("source_keys")==wall.source_keys,"Projected receiver body and ordered shape retain exact original wall identity/eligibility.")
	_check(projected_mesh.layers==2 and projected_faces.size()==int(SPEC.projected_receiver_triangles)*3 and str(projected_shape.name)=="ProjectedUpperSiding" and var_to_bytes(projected_shape.shape.get_faces())==var_to_bytes(projected_faces),"All source-bound projected-front triangles match the native visible receiver; closures remain separate nonreceivers.")
	_check(model.has_node("ObservedPublicRoof")==bool(SPEC.public_roof_detail) and not model.has_node("ObservedRoof_NoSprayReceiver"),"Public roof presence matches the accepted study and its unchanged nonreceiver detail ownership.")

func _check_pair(wall: Node3D,roof: Node3D,original: Node3D) -> void:
	var adapter: Script=ADAPTER
	var seen: Array[String]=[]
	for spec: Array in [[wall,adapter.WALL_KEY,true],[roof,adapter.ROOF_KEY,false]]:
		var node: Node3D=spec[0]; var key: String=spec[1]; var is_wall: bool=spec[2]
		_check(node.transform==Transform3D.IDENTITY and node.get_meta("derived_object_key")==key and node.get_meta("source_keys")==[adapter.SOURCE_KEY] and node.get_meta("adapter_id")==adapter.ADAPTER_ID and bool(node.get_meta("runtime_attachment")) and not bool(node.get_meta("prototype_only")) and not bool(node.get_meta("recognition_accepted")),"Exact live outer ownership: "+key)
		_check(node.get_meta("feature_kind")==("building_wall" if is_wall else "building_roof") and node.get_meta("receiver_kind")==("building_wall" if is_wall else "none") and bool(node.get_meta("runtime_supersedes_generated_placeholder")) and node.get_meta("superseded_object_keys")==[adapter.WALL_KEY,adapter.ROOF_KEY],"Exact outer supersession/receiver contract: "+key)
		for child: Node in node.get_children():
			if child is MeshInstance3D:
				seen.append(str(child.name)); _compare_mesh(child,original.get_node(NodePath(child.name)),"Split")
				_check(child.get_meta("derived_object_key")==key and child.get_meta("source_keys")==[adapter.SOURCE_KEY] and bool(child.get_meta("runtime_attachment")) and not bool(child.get_meta("prototype_only")),"Direct split mesh live metadata: "+str(child.name))
			else: _check(_snapshot(child)==_snapshot(original.get_node(NodePath(child.name))),"Nested original/detail identity and native collision unchanged: "+str(child.name))
		var body: StaticBody3D=node.get_node(NodePath(("OriginalWallRecord" if is_wall else "OriginalRoofRecord")+"/Collision")) as StaticBody3D
		_check(body.collision_layer==5 and body.collision_mask==0 and body.is_in_group("spray_receiver_wall")==is_wall and body.get_meta("derived_object_key")==key and body.get_meta("source_keys")==[adapter.SOURCE_KEY] and body.get_meta("receiver_kind")==("building_wall" if is_wall else "none"),"Preserved real source collision ownership: "+key)
	_check(seen.size()==int(SPEC.mesh_count) and _measure(wall)==[int(SPEC.wall_mesh_count),int(SPEC.wall_mesh_count),int(SPEC.wall_live_triangles),int(SPEC.wall_bodies),int(SPEC.wall_shapes)] and _measure(roof)==[int(SPEC.roof_mesh_count),int(SPEC.roof_mesh_count),int(SPEC.roof_live_triangles),int(SPEC.roof_bodies),int(SPEC.roof_shapes)],"All exact split native streams/shapes retained without duplication.")

func _chunk_detail_callbacks() -> int:
	var total: int=int(SPEC.baseline_chunk_detail_callbacks)
	for unit_spec: Dictionary in BATCH_SPECS:
		if str(unit_spec.chunk)==str(SPEC.chunk): total+=int(unit_spec.standalone_detail_callbacks)
	return total

func _callback_counts(observer: RefCounted) -> Dictionary:
	return {"raw_calls":observer.raw_calls.duplicate(true),"detail_tangent_calls":observer.detail_tangent_calls,"source_internal_tangent_calls":observer.source_tangent_calls}
func _check_callbacks(observer: RefCounted,label: String,expected_details: int) -> void:
	_check(observer.raw_calls==[{"key":ADAPTER.WALL_KEY,"is_context":false},{"key":ADAPTER.ROOF_KEY,"is_context":false}] and observer.detail_tangent_calls==expected_details,"Actual raw constructor2/detail tangent"+str(expected_details)+" callbacks: "+label)
func _caller_cleanup(chunk: Dictionary,dump: Dictionary) -> void:
	var wall: Dictionary=NEW._record(chunk.records,ADAPTER.WALL_KEY); var roof: Dictionary=NEW._record(chunk.records,ADAPTER.ROOF_KEY)
	var other: Dictionary={}
	for row: Dictionary in chunk.records:
		if not ADAPTER.claims_record(row): other=row; break
	var report: Dictionary={}
	for mode: String in ["missing_parent","later_failure","unconsumed_pair","normal"]:
		var observer: RefCounted=_observer()
		var fixture: Dictionary=chunk.duplicate(true)
		# Reordering exact rows makes the consumed/pending halves deterministic; source bytes stay unchanged.
		fixture.records=[wall,other,roof]
		for row: Dictionary in chunk.records:
			if row.object_key not in [wall.object_key,other.object_key,roof.object_key]: fixture.records.append(row)
		if mode=="later_failure": observer.injected_failure_key=str(other.object_key)
		if mode=="unconsumed_pair": observer.skip_consumption_key=ADAPTER.WALL_KEY
		var parents: Dictionary={} if mode=="missing_parent" else {"ground":Node3D.new(),"roads":Node3D.new(),"buildings":Node3D.new()}
		var result: Dictionary=observer.build_chunk(fixture,parents)
		if mode=="normal":
			_check(bool(result.get("ok",false)),"Observed inherited actual build_chunk succeeds.")
			_check_callbacks(observer,"Actual build_chunk passes callbacks for target and retained neighbors",_chunk_detail_callbacks())
			if result.has("node"): _check_native_result(result,"Observed actual builder counters"); result.node.free()
		else:
			var expected: String={"missing_parent":"builder_parent","later_failure":"probe_later_record_failure","unconsumed_pair":str(SPEC.stem)+"_unconsumed_pair"}[mode]
			_check(not bool(result.get("ok",false)) and str(result.get("code",""))==expected,"Actual caller reaches intended cleanup branch: "+mode)
		var remaining := 0
		for node: Variant in observer.held_nodes:
			if is_instance_valid(node): remaining+=1
		_check(observer.held_nodes.size()>=2 and remaining==0,"Actual caller frees all observed staged/consumed/pending node references: "+mode)
		report[mode]={"ok":result.get("ok",false),"code":result.get("code",""),"observed_node_refs":observer.held_nodes.size(),"remaining_valid_refs":remaining,"callbacks":_callback_counts(observer)}
		for parent: Node in parents.values(): parent.free()
	dump["actual_caller_lifecycle"]=report

func _mixed_plan_cleanup(dump: Dictionary,specs: Array) -> void:
	specs=specs.duplicate(true)
	specs.append({"number":"1215","wrapper":"game/scripts/world/facades/bayside_1215_live_replacement.gd"})
	var builder: RefCounted=BUILDER.new()
	var registered: Array[Dictionary]=[]
	var pending: Array[Node]=[]
	var owner := Node3D.new()
	var consumed: Node=null
	for index: int in [0,1]:
		var spec: Dictionary=specs[index]
		var adapter: Script=load("res://"+str(spec.wrapper)) as Script
		var chunk: Dictionary=adapter.FACTORY._json(adapter.FACTORY.CHUNK_PATH)
		var prepared: Dictionary=adapter.prepare_chunk_records(chunk)
		var plan: Dictionary=adapter.build_chunk_plan(prepared,Callable(builder,"_build_unpaired_record"),Callable(builder,"_tangents_for"))
		_check(bool(plan.get("ok",false)),"Mixed cleanup fixture builds real pair: "+str(spec.number))
		if not bool(plan.get("ok",false)):
			builder._free_unconsumed_plans(registered); owner.free(); return
		registered.append({"adapter":adapter,"plan":plan})
		if index==0:
			var taken: Dictionary=adapter.consume_record(plan.source_records[adapter.WALL_KEY],plan)
			_check(bool(taken.get("ok",false)),"Mixed cleanup fixture consumes one real wall.")
			if not bool(taken.get("ok",false)):
				builder._free_unconsumed_plans(registered); owner.free(); return
			consumed=taken.node; owner.add_child(consumed)
		for value: Dictionary in plan.records.values(): pending.append(value.node)
	var empty_adapter: Script=registered[0].adapter
	var neighbor: Dictionary=empty_adapter.FACTORY._json("res://generated/world/chunks/"+str(specs[0].neighbor)+".json")
	var empty_prepared: Dictionary=empty_adapter.prepare_chunk_records(neighbor)
	var empty_plan: Dictionary=empty_adapter.build_chunk_plan(empty_prepared,Callable(builder,"_build_unpaired_record"),Callable(builder,"_tangents_for"))
	_check(bool(empty_plan.get("ok",false)) and not bool(empty_plan.get("contains_target",true)),"Mixed cleanup includes a successful empty neighboring plan.")
	if not bool(empty_plan.get("ok",false)):
		builder._free_unconsumed_plans(registered); owner.free(); return
	registered.append({"adapter":empty_adapter,"plan":empty_plan})
	if bool(empty_plan.get("contains_target",true)):
		builder._free_unconsumed_plans(registered); owner.free(); return
	var before: Array=[]
	for entry: Dictionary in registered: before.append(entry.plan.pending_keys.size())
	_check(before==[1,2,0] and pending.size()==3,"Mixed cleanup reaches one partial pair, one pending pair and one empty plan.")
	builder._free_unconsumed_plans(registered)
	var remaining := 0
	for node: Variant in pending:
		if is_instance_valid(node): remaining+=1
	var owner_retained: bool=is_instance_valid(consumed) and consumed.get_parent()==owner and owner.get_child_count()==1
	_check(remaining==0 and owner_retained,"Central cleanup frees all three pending roots and preserves the separately owned consumed wall.")
	for entry: Dictionary in registered:
		var adapter: Script=entry.adapter
		_check(entry.plan.records.is_empty() and entry.plan.pending_keys.is_empty() and adapter.plan_was_fully_consumed(entry.plan),"Central cleanup clears each original plan dictionary.")
	owner.free()
	_check(not is_instance_valid(consumed),"Consumed wall remains its owner's cleanup responsibility.")
	dump["mixed_plan_cleanup"]={"pending_before":before,"remaining_pending_roots":remaining,"consumed_owner_retained":owner_retained,"consumed_freed_with_owner":not is_instance_valid(consumed)}

func _counts(result: Dictionary) -> Array:
	var counts: Array=[]
	for key: String in COUNTERS: counts.append(int(result[key]))
	return counts
func _measure(node: Node) -> Array:
	var result: Array=[0,0,0,0,0]
	if node is MeshInstance3D:
		result[0]=1; result[1]=node.mesh.get_surface_count()
		for surface in node.mesh.get_surface_count(): result[2]+=int(node.mesh.surface_get_array_index_len(surface)/3)
	if node is StaticBody3D: result[3]=1
	if node is CollisionShape3D: result[4]=1
	for child: Node in node.get_children():
		var counts: Array=_measure(child)
		for i in 5: result[i]+=counts[i]
	return result
func _check_native_result(result: Dictionary,label: String) -> void:
	_check(_counts(result)==_measure(result.node),label+" equal descendant native measurement.")
func _bytes_sha(bytes: PackedByteArray) -> String:
	var context := HashingContext.new(); context.start(HashingContext.HASH_SHA256); context.update(bytes)
	return context.finish().hex_encode()
func _check(ok: bool,message: String) -> void:
	checks+=1
	if not ok and message not in failures: failures.append(message)
func _end(dump: Dictionary) -> void:
	dump["recognition_credit"]=0
	dump["scope"]="One exact frozen-study native channels/materials/projected receiver owners, per-target paired rejection and caller cleanup, same-chunk records outside all batch pairs, retained published current32 attachments, the accepted mixed-plan ownership fixture and one ordinary source world. No motion, spray placement, visual, package, authority or recognition acceptance."
	dump["ok"]=failures.is_empty(); dump["failures"]=failures; dump["checks"]=checks
	var file := FileAccess.open(WORK+"/focused-001-result.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(dump,"\t")+"\n")
	print("GATEVIEW1397_BAYSIDE1226_LIVE_FOCUSED_"+("PASS" if failures.is_empty() else "FAIL")+" "+JSON.stringify(failures))
	quit(0 if failures.is_empty() else 1)

func _material_equal(a:Material,b:Material) -> bool:
	return _material_state(a)==_material_state(b)
func _material_state(material:Material) -> Dictionary:
	var state:Dictionary={"class":material.get_class()}
	for property:Dictionary in material.get_property_list():
		if (int(property.usage)&PROPERTY_USAGE_STORAGE)==0 or str(property.name) in ["script","resource_path"]:continue
		var value:Variant=material.get(str(property.name))
		if value is Resource:
			state[str(property.name)]={"class":value.get_class(),"path":value.resource_path,"name":value.resource_name}
			if value is Shader:state[str(property.name)]["code_sha256"]=value.code.sha256_text()
			if not value.resource_path.is_empty() and FileAccess.file_exists(value.resource_path):state[str(property.name)]["source_sha256"]=FileAccess.get_sha256(value.resource_path)
		else:state[str(property.name)]=var_to_bytes(value).hex_encode()
	return state


func _snapshot(node:Node) -> Dictionary:
	var out:Dictionary={"class":node.get_class(),"name":str(node.name),"children":[]}
	if node is Node3D:out["transform"]=var_to_bytes(node.transform).hex_encode()
	var metadata:Dictionary={}
	for key:StringName in node.get_meta_list():metadata[str(key)]=var_to_bytes(node.get_meta(key)).hex_encode()
	out["metadata"]=metadata
	if node is MeshInstance3D:
		out["layers"]=node.layers;out["shadow"]=node.cast_shadow;out["surfaces"]=[]
		out["mesh_class"]=node.mesh.get_class()
		out["named_surface_api"]=node.mesh is ArrayMesh
		for surface in node.mesh.get_surface_count():
			var surface_name:Variant=node.mesh.surface_get_name(surface) if node.mesh is ArrayMesh else null
			out.surfaces.append({"arrays":var_to_bytes(node.mesh.surface_get_arrays(surface)).hex_encode(),"name":surface_name,"material":_material_state(node.get_active_material(surface))})
	if node is CollisionObject3D:out["collision_layer"]=node.collision_layer;out["collision_mask"]=node.collision_mask;out["wall_group"]=node.is_in_group("spray_receiver_wall")
	if node is CollisionShape3D and node.shape is ConcavePolygonShape3D:
		out["faces"]=var_to_bytes(node.shape.get_faces()).hex_encode()
		var shape_meta:Dictionary={}
		for key:StringName in node.shape.get_meta_list():shape_meta[str(key)]=var_to_bytes(node.shape.get_meta(key)).hex_encode()
		out["shape_metadata"]=shape_meta
	for child:Node in node.get_children():out.children.append(_snapshot(child))
	return out


func _compare_target_chunk(chunk:Dictionary,builder:RefCounted,dump:Dictionary) -> void:
	var parents:Dictionary={"ground":Node3D.new(),"roads":Node3D.new(),"buildings":Node3D.new()}
	var old_builder:=OLD_BUILDER.new()
	var old_result:Dictionary=old_builder.build_chunk(chunk,parents)
	var current:Dictionary=builder.build_chunk(chunk,parents)
	_check(bool(old_result.get("ok",false)) and bool(current.get("ok",false)),"Original and current actual target chunks build before attachment.")
	if bool(old_result.get("ok",false)) and bool(current.get("ok",false)):
		var before:Node3D=old_result.node;var after:Node3D=current.node
		_check(before.get_child_count()==after.get_child_count(),"Same complete supplied chunk record count.")
		var changed_keys: Array[String]=[]
		var chunk_delta: Array[int]=[0,0,0,0,0]
		for unit_spec: Dictionary in BATCH_SPECS:
			if str(unit_spec.chunk)!=str(chunk.chunk_id): continue
			changed_keys.append("building:"+str(unit_spec.source_key)+":wall")
			changed_keys.append("building:"+str(unit_spec.source_key)+":roof")
			var unit_delta: Array[int]=[int(unit_spec.added_mesh_count),int(unit_spec.added_mesh_count),int(unit_spec.added_triangles),2,int(unit_spec.added_shape_count)]
			for index in 5: chunk_delta[index]+=unit_delta[index]
		var retained:=0
		for proxy:Node in before.get_children():
			var original:Node=proxy.get_child(0)
			var key:=str(original.get_meta("derived_object_key",""))
			if key in changed_keys:continue
			var other:Node=after.get_node(NodePath(proxy.name)).get_child(0)
			_check(_snapshot(original)==_snapshot(other),"Unchanged same-chunk source arrays/material/collision/ownership: "+key);retained+=1
		for index in COUNTERS.size():
			_check(int(current[COUNTERS[index]])-int(old_result[COUNTERS[index]])==chunk_delta[index],"Exact combined same-chunk source-derived counter delta: "+str(COUNTERS[index]))
		_check(current.source_keys==old_result.source_keys,"Complete source-key inventory unchanged.")
		_check(retained==int(SPEC.target_records)-changed_keys.size() and before.get_child_count()==int(SPEC.target_records),"Every record outside the batch target pairs retains current32 native state.")
		_check_native_result(current,"Actual candidate chunk counters")
		dump["same_chunk_preservation"]={"retained_records":retained,"changed_keys":changed_keys,"expected_delta":chunk_delta,"original_counts":[old_result.mesh_instances,old_result.surfaces,old_result.triangles,old_result.static_bodies,old_result.shapes],"current_counts":[current.mesh_instances,current.surfaces,current.triangles,current.static_bodies,current.shapes]}
	for result:Dictionary in [old_result,current]:
		if result.has("node"):result.node.free()
	for value:Node in parents.values():value.free()


func _current_world(dump:Dictionary,models:Dictionary,specs:Array) -> void:
	var main:=load("res://game/scenes/main.tscn").instantiate() as GameMain
	var world:=main.get_node("WorldRoot") as WorldLoader;var ready:Array=[];var failed:Array=[]
	world.world_ready.connect(func(x):ready.append(x));world.world_failed.connect(func(a,b,c):failed.append([a,b,c]));root.add_child(main)
	var start:=Time.get_ticks_msec()
	while ready.is_empty() and failed.is_empty() and Time.get_ticks_msec()-start<45000:await process_frame
	_check(ready.size()==1 and failed.is_empty(),"Ordinary current main loads actual builder: "+JSON.stringify(failed))
	if ready.size()==1:
		var e:=world.get_runtime_evidence();dump["measured_world"]={"rows":e.playable_rows,"meshes":e.mesh_instances,"surfaces":e.surfaces,"triangles":e.triangles,"bodies":e.static_bodies,"shapes":e.shapes}
		var parsed_world: Dictionary=NEW._json(WORK+"/baseline-world.json").measured_world
		var expected_world: Dictionary={}
		var world_keys:Array[String]=["bodies","meshes","rows","shapes","surfaces","triangles"]
		_check(parsed_world.size()==world_keys.size(),"Exactly six expected world counter keys.")
		for key:String in world_keys:
			var value:Variant=parsed_world.get(key,null)
			var numeric:bool=typeof(value)==TYPE_INT or typeof(value)==TYPE_FLOAT
			var exact:bool=numeric and is_finite(float(value)) and float(value)>=0.0 and float(value)<=9007199254740991.0 and float(value)==floor(float(value))
			_check(exact,"Finite exact integer expected world counter: "+key)
			if exact:expected_world[key]=int(value)
		if expected_world.size()!=world_keys.size():main.queue_free();await process_frame;return
		for unit_spec: Dictionary in specs:
			expected_world.meshes+=int(unit_spec.added_mesh_count); expected_world.surfaces+=int(unit_spec.added_mesh_count)
			expected_world.triangles+=int(unit_spec.added_triangles); expected_world.bodies+=2; expected_world.shapes+=int(unit_spec.added_shape_count)
		_check(dump.measured_world==expected_world,"Measured world equals current32 plus the source-bound1397 and1226 additions.")
		dump["expected_world"]=expected_world
		for spec: Dictionary in specs:
			_select(spec)
			var model: Node3D=models[str(spec.source_key)]
			var real_pair:Dictionary={}
			for key:String in [ADAPTER.WALL_KEY,ADAPTER.ROOF_KEY,"building:w95934144:wall","building:w95934144:roof","building:w95934117:wall","building:w95934117:roof","building:w95934123:wall","building:w95934123:roof","building:w96215646:wall","building:w96215646:roof","building:w95934125:wall","building:w95934125:roof","building:w764313741:wall","building:w764313741:roof","building:r19685981:wall","building:r19685981:roof"]:
				var found:Array=[]
				for node:Node in world.find_children("*","Node3D",true,false):
					if not node is MeshInstance3D and not node is CollisionObject3D and node.has_meta("feature_kind") and str(node.get_meta("derived_object_key",""))==key:
						if key not in [ADAPTER.WALL_KEY,ADAPTER.ROOF_KEY] or (str(node.get_meta("adapter_id",""))==ADAPTER.ADAPTER_ID and bool(node.get_meta("runtime_attachment",false))):found.append(node)
				_check(found.size()==1,"Exactly one current real pair root "+key)
				if found.size()==1 and key in [ADAPTER.WALL_KEY,ADAPTER.ROOF_KEY]:real_pair[key]=found[0]
			_check(main._mac_export_projected_family_attachment_valid(ADAPTER,str(spec.number)),"New exact ordinary-main attachment predicate: "+str(spec.number))
			if real_pair.size()==2:
				_check_pair(real_pair[ADAPTER.WALL_KEY],real_pair[ADAPTER.ROOF_KEY],model)
				for key:String in real_pair:
					var outer:Node=real_pair[key];var proxy:Node=outer.get_parent()
					_check(proxy.name=="%s__%s" % [ADAPTER.TARGET_CHUNK_ID,key.validate_node_name()] and proxy.get_child_count()==1 and proxy.get_parent()==world.get_node("PlayableWorld/Buildings"),"Actual category proxy ancestry and single outer owner: "+key)
				dump.units[str(spec.source_key)]["actual_attachment_paths"]={"wall":str(real_pair[ADAPTER.WALL_KEY].get_path()),"roof":str(real_pair[ADAPTER.ROOF_KEY].get_path())}
		var smoke:Dictionary={}
		for method:String in ["_mac_export_1439_attachment_valid","_mac_export_1444_attachment_valid","_mac_export_1308_attachment_valid","_mac_export_1394_attachment_valid","_mac_export_1317_attachment_valid","_mac_export_fire_station48_attachment_valid","_mac_export_maceo_may_attachment_valid","_mac_export_1201_attachment_valid","_mac_export_1238_attachment_valid","_mac_export_1206_attachment_valid","_mac_export_1219_attachment_valid","_mac_export_1212_attachment_valid","_mac_export_1220_attachment_valid","_mac_export_1239_attachment_valid"]:
			smoke[method]=bool(main.call(method));_check(bool(smoke[method]),"Actual merged-context attachment predicate: "+method)
		for pair: Array in [[RETAINED_1222,"1222"],[RETAINED_1227,"1227"],[RETAINED_1202,"1202"],[RETAINED_1234,"1234"],[RETAINED_1215,"1215"],[RETAINED_1232,"1232"],[RETAINED_1241,"1241"],[RETAINED_1221,"1221"],[RETAINED_1240,"1240"]]:
			_check(main._mac_export_projected_family_attachment_valid(pair[0],pair[1]),"Retained current32 projected attachment: "+str(pair[1]))
		dump["merged_attachment_predicates"]=smoke
		dump["world_ready_report"]=ready[0]
		_retained_northern(world,dump)
	main.queue_free();await process_frame

func _retained_northern(world: Node3D,dump: Dictionary) -> void:
	# Exact current32 caller is the prior-state producer, distinct from each frozen original study.
	var reports: Dictionary={}
	for adapter: Script in [RETAINED,RETAINED_1238,RETAINED_1206,RETAINED_1219,RETAINED_1212,RETAINED_1220,RETAINED_1239,RETAINED_1222,RETAINED_1227,RETAINED_1202,RETAINED_1234,RETAINED_1215,RETAINED_1232,RETAINED_1241,RETAINED_1221,RETAINED_1240]:
		var source_key: String=str(adapter.SOURCE_KEY)
		var wall_key: String=str(adapter.WALL_KEY)
		var roof_key: String=str(adapter.ROOF_KEY)
		var adapter_id: String=str(adapter.ADAPTER_ID)
		var chunk_id: String=str(adapter.TARGET_CHUNK_ID)
		var chunk: Dictionary=NEW._json(adapter.FACTORY.CHUNK_PATH)
		var parents: Dictionary={"ground":Node3D.new(),"roads":Node3D.new(),"buildings":Node3D.new()}
		var parent_builder: RefCounted=OLD_BUILDER.new()
		var before: Dictionary=parent_builder.build_chunk(chunk,parents)
		_check(bool(before.get("ok",false)),"Exact combined parent builds before retained pair comparison: "+source_key)
		var report: Dictionary={"comparison_scope":"Actual native retained attachment against frozen current32 caller; original art decisions separately bound.","roots":{}}
		if bool(before.get("ok",false)):
			_check_native_result(before,"Retained parent chunk counters: "+source_key)
			for key: String in [wall_key,roof_key]:
				var expected: Node3D=null
				for proxy: Node in before.node.get_children():
					var candidate: Node3D=proxy.get_child(0) as Node3D
					if str(candidate.get_meta("adapter_id",""))==adapter_id and str(candidate.get_meta("derived_object_key",""))==key: expected=candidate
				var found: Array=[]
				for node: Node in world.find_children("*","Node3D",true,false):
					if not node is MeshInstance3D and not node is CollisionObject3D and str(node.get_meta("adapter_id",""))==adapter_id and str(node.get_meta("derived_object_key",""))==key and bool(node.get_meta("runtime_attachment",false)):found.append(node)
				_check(expected!=null and found.size()==1,"Exactly one retained outer owner: "+key)
				if expected==null or found.size()!=1: continue
				var actual: Node3D=found[0] as Node3D
				var proxy: Node=actual.get_parent()
				var actual_snapshot: Dictionary=_snapshot(actual)
				var expected_snapshot: Dictionary=_snapshot(expected)
				var equal: bool=actual_snapshot==expected_snapshot
				var counts: Array=_measure(actual)
				_check(equal,"All retained native arrays/materials/shapes/metadata equal exact combined parent: "+key)
				_check(counts==_measure(expected),"Retained source-derived split counters: "+key)
				_check(proxy.name=="%s__%s" % [chunk_id,key.validate_node_name()] and proxy.get_child_count()==1 and proxy.get_parent()==world.get_node("PlayableWorld/Buildings"),"Retained actual category ancestry: "+key)
				report.roots[key]={"equal_native_snapshot":equal,"actual_path":str(actual.get_path()),"counts":counts,"actual_snapshot_sha256":_bytes_sha(var_to_bytes(actual_snapshot)),"parent_snapshot_sha256":_bytes_sha(var_to_bytes(expected_snapshot))}
			_check(report.roots.size()==2,"Both retained roots compared completely: "+source_key)
		if before.has("node"): before.node.free()
		for parent: Node in parents.values(): parent.free()
		reports[source_key]=report
	dump["retained_northern_attachments"]=reports
