extends RefCounted
## Approved family appearance, with source-owned contacts matching installed meshes.
const FAMILY = preload("res://game/scripts/world/facades/housing_site_family.gd")
const CONFIG := "res://game/resources/housing_family/live_instances.json"

static func install(buildings: Node3D, chunks: Array, candidate_manifest: Dictionary = {}) -> Dictionary:
	# A source fixture may construct a bounded additional candidate before its
	# measured topology is promoted. Normal WorldLoader calls omit this argument.
	var manifest: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONFIG)) if candidate_manifest.is_empty() else candidate_manifest
	if not manifest is Dictionary or not manifest.get("instances") is Array or manifest.instances.is_empty():
		return {"ok":false,"message":"Invalid family instance manifest"}
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
		# The family's roof triangles arrive facing down for collision, so the
		# player fell through them from above; collide from both sides.
		shape.backface_collision = true
		var holder := CollisionShape3D.new()
		holder.shape=shape
		body.add_child(holder)
		model.add_child(body)
		total+=faces.size()/3
	return {"ok":true,"triangles":total}
