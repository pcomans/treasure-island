extends RefCounted
## Source-owned 1445 replacement plus reference-supported, OSM-unmapped court.
const HOUSE = preload("res://game/resources/models/bulgarian_wall/neighbor.gd")
const COURT = preload("res://game/resources/models/bulgarian_wall/court.gd")
const CONTACTS = preload("res://game/scripts/world/facades/housing_family_live_attachment.gd")
const SOURCE := "w95934121"
const WALL := "building:w95934121:wall"
const ROOF := "building:w95934121:roof"
const T := Vector3(0.114707,0,0.993399)
const N := Vector3(-0.993399,0,0.114707)
const BASE := 3.004
const COURT_ORIGIN := Vector3(-190.6,0,-65.8)

static func house_point(p: Vector3) -> Vector3:
	# Source footprint stations: north wing, recessed center, south wing.
	var station: float
	if p.x < -5.2: station = lerpf(-114.657,-103.237,(p.x+15.0)/9.8)
	elif p.x < 5.2: station = lerpf(-103.237,-93.033,(p.x+5.2)/10.4)
	else: station = lerpf(-93.033,-81.791,(p.x-5.2)/9.8)
	# Rear articulation stays inside the frozen stepped footprint. The observed
	# balcony cavities are inference; no change to authoritative source vertices.
	var cross: float = lerpf(193.70,201.19,(p.z+5.5)/7.5) if p.z<=2.0 else lerpf(201.19,206.66,(p.z-2.0)/2.9)
	return T*station+N*cross+Vector3.UP*(BASE+p.y)

static func install(buildings: Node3D, ground: Node3D, chunks: Array) -> Dictionary:
	var records: Dictionary = {}
	for chunk: Dictionary in chunks:
		for row: Dictionary in chunk.records:
			if str(row.object_key) in [WALL,ROOF]: records[str(row.object_key)]=row
	if records.size()!=2 or float(records[WALL].flat_base_elevation_m)!=BASE:
		return {"ok":false,"message":"1445 frozen source pair/base missing","source_keys":[SOURCE]}
	var owners: Dictionary = {}
	for node: Node in buildings.find_children("*","Node3D",true,false):
		var key := str(node.get_meta("derived_object_key",""))
		if key not in [WALL,ROOF] or node is CollisionObject3D or node is MeshInstance3D: continue
		if owners.has(key): return {"ok":false,"message":"Duplicate 1445 owner","source_keys":[SOURCE]}
		owners[key]=node
	if owners.size()!=2: return {"ok":false,"message":"1445 source owners missing","source_keys":[SOURCE]}
	var house := HOUSE.build()
	house.name="Chinook1445Live"
	house.set_meta("source_key",SOURCE)
	house.set_meta("runtime_attachment",true)
	house.set_meta("recognition_accepted",false)
	var stair_visuals := Node3D.new()
	stair_visuals.name="StairVisuals"
	for child: Node in house.get_children():
		if not child is MeshInstance3D: continue
		var mesh := child as MeshInstance3D
		var label := str(mesh.get_meta("art_label",mesh.name))
		if label in ["Lawn","FrontPath","Driveway"]:
			house.remove_child(mesh); mesh.free(); continue
		_warp_mesh(mesh,Callable(house_point))
		var role := "wall"
		if label.begins_with("Hip") or label.begins_with("Eave") or label=="RoofVent": role="roof"
		elif label.contains("Stair") or label.contains("Rail") or label.contains("Landing") or label.contains("Paving"): role="support"
		mesh.set_meta("family_role",role)
		# Stock controller has no step-up solver. A deliberate smooth ramp contact
		# follows the tread nosings; the complete visible tread/rail geometry stays.
		if label.begins_with("StairTread"):
			house.remove_child(mesh); stair_visuals.add_child(mesh)
	if stair_visuals.get_child_count()!=34:
		house.free(); stair_visuals.free()
		return {"ok":false,"message":"1445 semantic tread exclusion drift","source_keys":[SOURCE]}
	for x in [-4.2,4.2]:
		# UpperLanding spans local z2.10..3.20 with top y2.90. Terminate
		# the nosing ramp at that OUTER edge, not at the flight start z3.12:
		# the old overlap put the ramp 54.6 mm below the landing's front lip.
		var points := [Vector3(x-0.6,2.9,3.20),Vector3(x+0.6,2.9,3.20),Vector3(x+0.6,0,7.37),Vector3(x-0.6,0,7.37)]
		points.reverse()
		COURT._quad(house,"StairWalkRamp",points,COURT._mat(Color("96998a")))
		var ramp := house.get_child(house.get_child_count()-1) as MeshInstance3D
		_warp_mesh(ramp,Callable(house_point))
		ramp.set_meta("family_role","support")
		ramp.visible=false
	# Short solid approaches bridge the measured 0.16/0.23 m terrain gap at
	# the two lower nosings without lifting terrain or changing stock controls.
	for x in [-4.2,4.2]:
		var a := house_point(Vector3(x-0.6,0,7.37))
		var b := house_point(Vector3(x+0.6,0,7.37))
		var c := house_point(Vector3(x+0.6,0,8.0))
		var d := house_point(Vector3(x-0.6,0,8.0))
		c.y=_ground_height(chunks,Vector2(c.x,c.z))+0.015
		d.y=_ground_height(chunks,Vector2(d.x,d.z))+0.015
		COURT._quad(house,"StairGroundApproach",[b,a,d,c],COURT._mat(Color("96998a")))
		house.get_child(house.get_child_count()-1).set_meta("family_role","support")
		for edge in [[a,d],[c,b]]:
			var lo: Vector3 = edge[0]
			var hi: Vector3 = edge[1]
			var bottom_lo := Vector3(lo.x,_ground_height(chunks,Vector2(lo.x,lo.z))-0.02,lo.z)
			var bottom_hi := Vector3(hi.x,_ground_height(chunks,Vector2(hi.x,hi.z))-0.02,hi.z)
			COURT._quad(house,"StairApproachSide",[lo,hi,bottom_hi,bottom_lo],COURT._mat(Color("96998a")))
			house.get_child(house.get_child_count()-1).set_meta("family_role","support")
	var contacts := CONTACTS._contacts(house,[],SOURCE)
	if not contacts.ok: house.free(); stair_visuals.free(); return contacts
	house.add_child(stair_visuals)
	# Render-only surface follows actual land/area triangles. Stock support is
	# still the unchanged land; both front wings receive the observed apron.
	for x in [-10.1,10.1]: _append_draped_apron(house,chunks,x-4.9,x+4.9,5.13,8.8)
	var court := COURT.build()
	court.name="BulgarianWall_UnmappedLandmark"
	court.set_meta("source_keys",[])
	court.set_meta("reference_identity","Bulgaria in the USA / former Navy handball courts")
	court.set_meta("placement_status","reference_bounded_production_inference")
	var court_base := -INF
	for p: Vector3 in [Vector3(-7.725,0,-0.375),Vector3(7.725,0,-0.375),Vector3(-7.725,0,10.175),Vector3(7.725,0,10.175)]:
		var at: Vector3 = COURT_ORIGIN-N*p.x+T*p.z
		court_base=maxf(court_base,_ground_height(chunks,Vector2(at.x,at.z)))
	if not is_finite(court_base): house.free(); court.free(); return {"ok":false,"message":"Court local land sample missing"}
	court_base+=0.035
	var court_faces := PackedVector3Array()
	for child: Node in court.get_children():
		if not child is MeshInstance3D: continue
		var mesh := child as MeshInstance3D
		if str(mesh.name)=="GroundSetting": court.remove_child(mesh); mesh.free(); continue
		var basis := Basis(-N,Vector3.UP,T)
		mesh.transform=Transform3D(basis,COURT_ORIGIN+Vector3.UP*court_base)*mesh.transform
		if str(mesh.name).begins_with("CourtCrack") or str(mesh.name).begins_with("RightReturnRepair") or str(mesh.name).begins_with("BulgariaInTheUSA"): continue
		for vertex: Vector3 in mesh.mesh.get_faces(): court_faces.append(mesh.transform*vertex)
	var body := StaticBody3D.new()
	body.name="CourtContact_NoSpray"
	body.collision_layer=1
	body.collision_mask=0
	body.position=COURT_ORIGIN+Vector3.UP*court_base
	body.set_meta("derived_object_key","landmark:bulgarian-wall")
	body.set_meta("source_keys",[])
	body.set_meta("receiver_kind","none")
	var local_faces := PackedVector3Array()
	for p: Vector3 in court_faces: local_faces.append(p-body.position)
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(local_faces)
	var holder := CollisionShape3D.new()
	holder.shape=shape
	body.add_child(holder)
	court.add_child(body)
	# Commit only after both complete models and contacts are prepared.
	for owner: Node in owners.values():
		for mesh: MeshInstance3D in owner.find_children("*","MeshInstance3D",true,false): mesh.visible=false
		for old: CollisionObject3D in owner.find_children("*","CollisionObject3D",true,false):
			old.collision_layer=0; old.collision_mask=0; old.remove_from_group("spray_receiver_wall")
	owners[WALL].add_child(house)
	ground.add_child(court)
	return {"ok":true,"source_key":SOURCE,"court_source_status":"unmapped_reference_landmark","court_base":court_base,"recognition_credit":0,"stairs_contact":"smooth nosing ramps; stock walking verification required"}

static func _warp_mesh(mesh: MeshInstance3D, transform_point: Callable) -> void:
	var output := ArrayMesh.new()
	for surface in mesh.mesh.get_surface_count():
		var a := mesh.mesh.surface_get_arrays(surface)
		var vertices: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
		var indices := PackedInt32Array()
		if a[Mesh.ARRAY_INDEX] != null: indices=a[Mesh.ARRAY_INDEX]
		if indices.is_empty():
			for i in vertices.size(): indices.append(i)
		a[Mesh.ARRAY_INDEX]=indices
		for i in vertices.size(): vertices[i]=transform_point.call(mesh.transform*vertices[i])
		a[Mesh.ARRAY_VERTEX]=vertices
		# Nonuniform source fit needs geometric normals, not the old local normals.
		var normals := PackedVector3Array(); normals.resize(vertices.size())
		for i in range(0,indices.size(),3):
			var normal := (vertices[indices[i+2]]-vertices[indices[i]]).cross(vertices[indices[i+1]]-vertices[indices[i]]).normalized()
			for j in 3: normals[indices[i+j]]+=normal
		for i in normals.size(): normals[i]=normals[i].normalized()
		a[Mesh.ARRAY_NORMAL]=normals
		output.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,a)
	mesh.mesh=output
	mesh.transform=Transform3D.IDENTITY

static func _ground_height(chunks: Array, point: Vector2, visible_surface: bool = false) -> float:
	var result := -INF
	for chunk: Dictionary in chunks:
		if str(chunk.chunk_id)!="x_-1__z_-1": continue
		for row: Dictionary in chunk.records:
			if str(row.feature_kind)!="land_ground" and not (visible_surface and str(row.feature_kind) in ["major_area","road_path"]): continue
			var v: Array = row.vertices
			var ids: Array = row.indices
			for i in range(0,ids.size(),3):
				var a:=Vector3(v[int(ids[i])*3],v[int(ids[i])*3+1],v[int(ids[i])*3+2])
				var b:=Vector3(v[int(ids[i+1])*3],v[int(ids[i+1])*3+1],v[int(ids[i+1])*3+2])
				var c:=Vector3(v[int(ids[i+2])*3],v[int(ids[i+2])*3+1],v[int(ids[i+2])*3+2])
				var det := (b.z-c.z)*(a.x-c.x)+(c.x-b.x)*(a.z-c.z)
				if absf(det)<0.000001: continue
				var u := ((b.z-c.z)*(point.x-c.x)+(c.x-b.x)*(point.y-c.z))/det
				var w := ((c.z-a.z)*(point.x-c.x)+(a.x-c.x)*(point.y-c.z))/det
				if u>=-0.00001 and w>=-0.00001 and u+w<=1.00001: result=maxf(result,u*a.y+w*b.y+(1-u-w)*c.y)
	return result

static func _append_draped_apron(root: Node3D, chunks: Array, xmin: float, xmax: float, zmin: float, zmax: float) -> void:
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for z in 7:
		for x in 9:
			var p := house_point(Vector3(lerpf(xmin,xmax,x/8.0),0,lerpf(zmin,zmax,z/6.0)))
			p.y=_ground_height(chunks,Vector2(p.x,p.z),true)+0.018
			vertices.append(p)
			uvs.append(Vector2(x,z))
	for z in 6:
		for x in 8:
			var i := z*9+x
			indices.append_array(PackedInt32Array([i,i+1,i+10,i,i+10,i+9]))
	var arrays: Array = []; arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX]=vertices
	arrays[Mesh.ARRAY_INDEX]=indices
	arrays[Mesh.ARRAY_TEX_UV]=uvs
	var normals := PackedVector3Array(); normals.resize(vertices.size()); normals.fill(Vector3.UP)
	arrays[Mesh.ARRAY_NORMAL]=normals
	var mesh := ArrayMesh.new(); mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var node := MeshInstance3D.new(); node.name="TerrainFollowingDrivewayApron"
	node.mesh=mesh; node.material_override=COURT._concrete(Color("96998a"),0.04,0.18)
	node.set_meta("physical_role","ground_visual")
	root.add_child(node)
