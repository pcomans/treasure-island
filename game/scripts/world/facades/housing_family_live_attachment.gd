extends RefCounted
## Approved family appearance, with source-owned contacts matching installed meshes.
const FAMILY = preload("res://game/scripts/world/facades/housing_site_family.gd")
const CONFIG := "res://game/resources/housing_family/live_instances.json"

static func install(buildings: Node3D, chunks: Array) -> Dictionary:
	var manifest: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONFIG))
	if not manifest is Dictionary or manifest.get("instances",[]).size()!=24:
		return {"ok":false,"message":"Invalid 24-instance family manifest"}
	var records: Dictionary = {}
	for chunk: Dictionary in chunks:
		for record: Dictionary in chunk.records: records[str(record.object_key)] = record
	var nodes: Dictionary = {}
	for node: Node in buildings.find_children("*","Node3D",true,false):
		var key := str(node.get_meta("derived_object_key",""))
		# Record roots own the complete existing visual/body subtree.
		if key.is_empty() or node is CollisionObject3D: continue
		var ancestor := node.get_parent()
		var nested := false
		while ancestor != null and ancestor!=buildings:
			if str(ancestor.get_meta("derived_object_key",""))==key: nested=true; break
			ancestor=ancestor.get_parent()
		if nested: continue
		if nodes.has(key): return {"ok":false,"message":"Duplicate record root "+key}
		nodes[key]=node
	var plans: Array[Dictionary] = []
	var seen: Dictionary = {}
	for item: Dictionary in manifest.instances:
		var source := str(item.source_key)
		var wall_key := "building:"+source+":wall"
		var roof_key := "building:"+source+":roof"
		var cfg: Variant = JSON.parse_string(FileAccess.get_file_as_string(item.config))
		if seen.has(source) or not records.has(wall_key) or not records.has(roof_key) or not nodes.has(wall_key) or not nodes.has(roof_key) or not cfg is Dictionary or str(cfg.get("target",{}).get("source_key",""))!=source:
			for plan: Dictionary in plans: plan.model.free()
			return {"ok":false,"message":"Family source/pair identity failed: "+source,"source_keys":[source]}
		seen[source]=true
		var model := FAMILY.build(records[wall_key],records[roof_key],cfg)
		if not bool(model.get_meta("build_valid",false)):
			model.free()
			for plan: Dictionary in plans: plan.model.free()
			return {"ok":false,"message":"Shared geometry generation failed: "+source,"source_keys":[source]}
		var wall_owner: Node3D = nodes[wall_key]
		if not wall_owner.global_transform.is_equal_approx(Transform3D.IDENTITY):
			model.free()
			for plan: Dictionary in plans: plan.model.free()
			return {"ok":false,"message":"Unsupported transformed source owner: "+source}
		model.set_meta("scope","approved_shared_family_normal_play")
		var retained: Array[MeshInstance3D] = []
		var owners: Array[Node] = [nodes[wall_key]]
		if not bool(cfg.get("retain_production_roof",false)): owners.append(nodes[roof_key])
		var hidden: Array[MeshInstance3D] = []
		var old_bodies: Array[CollisionObject3D] = []
		for owner: Node in owners:
			for mesh: MeshInstance3D in owner.find_children("*","MeshInstance3D",true,false):
				if not mesh.visible: continue
				if bool(cfg.get("retain_production_roof",false)) and str(mesh.get_meta("physical_role",""))=="ground_visual": retained.append(mesh)
				else: hidden.append(mesh)
			for body: CollisionObject3D in owner.find_children("*","CollisionObject3D",true,false): old_bodies.append(body)
		var contact := _contacts(model,retained,source)
		if not contact.ok:
			model.free()
			for plan: Dictionary in plans: plan.model.free()
			return contact
		plans.append({"model":model,"owner":nodes[wall_key],"hidden":hidden,"old_bodies":old_bodies,"contact":contact})
	var disabled := 0
	var triangles := 0
	for plan: Dictionary in plans:
		for mesh: MeshInstance3D in plan.hidden: mesh.visible=false
		for body: CollisionObject3D in plan.old_bodies:
			body.collision_layer=0
			body.collision_mask=0
			body.remove_from_group("spray_receiver_wall")
			disabled+=1
		plan.owner.add_child(plan.model)
		triangles+=int(plan.contact.triangles)
	return {"ok":true,"instances":plans.size(),"disabled_legacy_bodies":disabled,"contact_triangles":triangles,"scope":"approved appearance; no new recognition credit"}

static func _contacts(model: Node3D, retained: Array[MeshInstance3D], source: String) -> Dictionary:
	var faces_by_role: Dictionary = {"wall":PackedVector3Array(),"roof":PackedVector3Array(),"support":PackedVector3Array(),"ground":PackedVector3Array()}
	var meshes: Array[MeshInstance3D] = []
	for child: Node in model.get_children():
		if child is MeshInstance3D: meshes.append(child)
	meshes.append_array(retained)
	for mesh: MeshInstance3D in meshes:
		var role := str(mesh.get_meta("family_role","support"))
		var faces := mesh.mesh.get_faces()
		if faces.is_empty(): return {"ok":false,"message":"Empty installed mesh contacts: "+source}
		var transform := mesh.transform
		if retained.has(mesh):
			transform=Transform3D.IDENTITY
			var current: Node3D = mesh
			while current != null:
				transform=current.transform*transform
				current=current.get_parent() as Node3D
		else: mesh.layers=2 if role=="wall" else 1
		var combined: PackedVector3Array = faces_by_role[role]
		for vertex: Vector3 in faces: combined.append(transform*vertex)
		faces_by_role[role]=combined
	var total := 0
	for role: String in faces_by_role:
		var faces: PackedVector3Array = faces_by_role[role]
		if faces.is_empty(): continue
		var body := StaticBody3D.new()
		body.name="FamilyContact_"+role
		body.collision_layer=5 if role=="wall" else 1
		body.collision_mask=0
		var key := "building:"+source+(":roof" if role=="roof" else ":wall")
		for node: Node in [body]:
			node.set_meta("derived_object_key",key)
			node.set_meta("source_keys",[source])
			node.set_meta("receiver_kind","building_wall" if role=="wall" else "none")
			node.set_meta("opaque",role=="wall")
			node.set_meta("family_role",role)
		if role=="wall": body.add_to_group("spray_receiver_wall")
		# Keep physics calculations local while preserving every world-space vertex.
		var origin := faces[0]
		body.position=origin
		var local_faces := PackedVector3Array()
		for vertex: Vector3 in faces: local_faces.append(vertex-origin)
		var shape := ConcavePolygonShape3D.new()
		shape.set_faces(local_faces)
		var holder := CollisionShape3D.new()
		holder.shape=shape
		body.add_child(holder)
		model.add_child(body)
		total+=faces.size()/3
	return {"ok":true,"triangles":total}

const ADOPTION := "res://game/resources/housing_family/live_adoption.json"

static func measure_world(world: Node3D) -> Dictionary:
	var totals := {"visible_meshes":0,"visible_surfaces":0,"visible_triangles":0,"active_bodies":0,"active_shapes":0,"disabled_bodies":0}
	for child: Node in world.find_children("*","Node3D",true,false):
		if child is MeshInstance3D and child.is_visible_in_tree() and child.mesh != null:
			totals.visible_meshes+=1
			totals.visible_surfaces+=child.mesh.get_surface_count()
			totals.visible_triangles+=child.mesh.get_faces().size()/3
		elif child is StaticBody3D:
			if child.collision_layer==0: totals.disabled_bodies+=1
			else:
				totals.active_bodies+=1
				for shape: Node in child.get_children():
					if shape is CollisionShape3D and not shape.disabled: totals.active_shapes+=1
	return totals

static func validate_live(world: Node3D) -> Dictionary:
	var binding: Variant = JSON.parse_string(FileAccess.get_file_as_string(ADOPTION))
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(CONFIG))
	if not binding is Dictionary or binding.get("recognition_credit",-1)!=0 or binding.get("base_recognition","")!="34/213":
		return {"ok":false,"message":"Invalid zero-credit family adoption binding"}
	var expected: Array[String] = []
	for item: Dictionary in manifest.instances: expected.append(str(item.source_key))
	expected.sort()
	if binding.get("enabled_sources",[])!=expected: return {"ok":false,"message":"Adoption target set drift"}
	var exported := FileAccess.file_exists("res://project.binary") and not FileAccess.file_exists("res://project.godot")
	for relative_path: String in binding.dependencies:
		var path := "res://"+relative_path
		if exported and (path.ends_with(".gd") or path.ends_with(".gdshader")):
			if not ResourceLoader.exists(path): return {"ok":false,"message":"Missing remapped adoption resource "+path}
		elif FileAccess.get_sha256(path)!=str(binding.dependencies[relative_path]):
			return {"ok":false,"message":"Adoption dependency drift "+path}
	var found: Dictionary = {}
	for model: Node3D in world.find_children("SharedHousing_*","Node3D",true,false):
		var source := str(model.get_meta("source_key",""))
		if source not in expected or found.has(source) or not bool(model.get_meta("build_valid",false)):
			return {"ok":false,"message":"Live family instance identity/build drift "+source}
		found[source]=true
		var owner := model.get_parent()
		if str(owner.get_meta("derived_object_key",""))!="building:"+source+":wall": return {"ok":false,"message":"Live owner drift "+source}
		var bodies := 0
		for child: Node in model.get_children():
			var role := str(child.get_meta("family_role","support"))
			if child is MeshInstance3D:
				if not child.visible or child.mesh==null or child.layers!=(2 if role=="wall" else 1): return {"ok":false,"message":"Live visual/layer drift "+source}
			elif child is StaticBody3D:
				bodies+=1
				var wall := role=="wall"
				if child.collision_layer!=(5 if wall else 1) or child.is_in_group("spray_receiver_wall")!=wall or child.get_meta("source_keys",[])!=[source]: return {"ok":false,"message":"Live contact/spray owner drift "+source}
				if child.get_child_count()!=1 or not child.get_child(0) is CollisionShape3D or child.get_child(0).shape==null: return {"ok":false,"message":"Live shape drift "+source}
		if bodies<2: return {"ok":false,"message":"Missing live bodies "+source}
		for body: CollisionObject3D in owner.find_children("*","CollisionObject3D",true,false):
			if not model.is_ancestor_of(body) and body.collision_layer!=0: return {"ok":false,"message":"Active hidden legacy body "+source}
		var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://game/resources/housing_family/"+source+".json"))
		if not bool(cfg.get("retain_production_roof",false)):
			for roof_owner: Node3D in world.find_children("*","Node3D",true,false):
				if roof_owner.has_meta("feature_kind") and str(roof_owner.get_meta("derived_object_key",""))=="building:"+source+":roof":
					for body: CollisionObject3D in roof_owner.find_children("*","CollisionObject3D",true,false):
						if body.collision_layer!=0: return {"ok":false,"message":"Active hidden legacy roof "+source}
	if found.size()!=24: return {"ok":false,"message":"Missing adopted instances"}
	var topology := measure_world(world)
	if not topology_matches(topology,binding.current_visible_active_topology): return {"ok":false,"message":"Current adoption topology drift","topology":topology}
	return {"ok":true,"instances":24,"topology":topology,"recognition_credit":0}

static func topology_matches(actual: Dictionary, expected: Dictionary) -> bool:
	var actual_keys := actual.keys()
	var expected_keys := expected.keys()
	actual_keys.sort()
	expected_keys.sort()
	if actual_keys!=expected_keys: return false
	for key: String in actual_keys:
		if typeof(actual[key]) not in [TYPE_INT,TYPE_FLOAT] or typeof(expected[key]) not in [TYPE_INT,TYPE_FLOAT]: return false
		var a := float(actual[key])
		var b := float(expected[key])
		if not is_finite(a) or not is_finite(b) or a<0 or b<0 or a!=floor(a) or b!=floor(b) or a!=b: return false
	return true
