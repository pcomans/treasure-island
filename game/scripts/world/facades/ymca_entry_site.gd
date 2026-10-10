extends RefCounted
## Observed public entrance/end assembly. Dimensions are production inference.
## The generated shell, roof, rear and source footprint remain untouched.
const SUPPORT := preload("res://game/scripts/world/facades/housing_quality_support.gd")
const CONFIG := "res://game/resources/facades/ymca_entry_site.json"
const SOURCE := "building:w34313547:wall"

static func matches_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) == SOURCE

static func build(record: Dictionary) -> Dictionary:
	var cfg: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONFIG))
	if not cfg is Dictionary or cfg.get("source", "") != "w34313547" or record.get("source_keys", []) != ["w34313547"] or record.get("receiver_kind", "") != "building_wall":
		return {"ok": false, "message": "YMCA exact source and site configuration required."}
	var root := Node3D.new()
	root.name = "YMCAObservedEntrySite"
	var o := _vec(cfg.origin)
	var t := _vec(cfg.tangent).normalized()
	var n := _vec(cfg.normal).normalized()
	var cream := _mat(Color(.98,.95,.83),.87)
	var coping := _mat(Color(.38,.53,.57),.7)
	var frame := _mat(Color(.80,.83,.75),.65)
	var glass := _mat(Color(.16,.26,.28),.24)
	var blue := _mat(Color(.07,.22,.38),.76)
	var joint := _mat(Color(.37,.40,.37),.89)
	# Two warm-white solid flanks and shallow side returns enclose a closed glazed group.
	# All bases extend below the locally sampled visible grade (3.885..3.940m).
	for side: float in [-1.0,1.0]:
		_box(root,"PavilionFlank",o+t*side*4.72+n*.80+Vector3(0,1.67,0),t,n,Vector3(3.76,3.54,1.70),cream,"wall")
		_box(root,"PavilionPier",o+t*side*2.68+n*1.62+Vector3(0,1.66,0),t,n,Vector3(.25,3.52,.25),cream,"wall")
	_box(root,"PavilionHeader",o+n*.80+Vector3(0,3.29,0),t,n,Vector3(5.3,.30,1.70),cream,"wall")
	_box(root,"FlatCanopy",o+n*.96+Vector3(0,3.58,0),t,n,Vector3(14.1,.19,2.22),coping,"detail")
	_box(root,"CanopyFascia",o+n*2.08+Vector3(0,3.53,0),t,n,Vector3(14.1,.13,.065),frame,"detail")
	# Closed opaque glass preserves the no-interior scope and continuous solid receiver.
	_box(root,"ClosedGlazing",o+n*1.43+Vector3(0,1.56,0),t,n,Vector3(5.10,3.25,.12),glass,"wall")
	for x: float in [-2.55,-1.16,0.0,1.16,2.55]:
		_box(root,"GlazingMullion",o+t*x+n*1.53+Vector3(0,1.57,0),t,n,Vector3(.075,3.26,.12),frame,"detail")
	for y: float in [.04,2.30,3.17]:
		_box(root,"GlazingRail",o+n*1.53+Vector3(0,y,0),t,n,Vector3(5.17,.085,.12),frame,"detail")
	for x: float in [-.58,.58]:
		_box(root,"DoorLowerRail",o+t*x+n*1.55+Vector3(0,.24,0),t,n,Vector3(1.10,.32,.12),frame,"detail")
		_box(root,"DoorPull",o+t*(x*.25)+n*1.64+Vector3(0,1.15,0),t,n,Vector3(.035,.36,.04),frame,"detail")
	# Complete pavilion proportion correction against the dated SSE image.
	# Preserve thin structural sections; widen the composed bays and raise the
	# full transom/canopy hierarchy together instead of enlarging isolated motifs.
	for child: Node in root.get_children():
		if not child is MeshInstance3D: continue
		var part := child as MeshInstance3D
		var delta := part.position-o
		part.position=o+t*delta.dot(t)*1.45+n*delta.dot(n)+Vector3.UP*delta.y*1.40
		var box := part.mesh as BoxMesh
		box.size=Vector3(box.size.x*1.45,box.size.y*(1.0 if str(part.name).begins_with("FlatCanopy") or str(part.name).begins_with("CanopyFascia") else 1.40),box.size.z)
	var vertices: Array = record.vertices
	# Coping and sparse panel joints are confined to the two observed chains.
	for run in range(3,12):
		var a := _vec(vertices.slice(run*12,run*12+3))
		var b := _vec(vertices.slice(run*12+3,run*12+6))
		var rt := Vector3(b.x-a.x,0,b.z-a.z).normalized()
		var rn := Vector3(-rt.z,0,rt.x)
		var length := Vector2(b.x-a.x,b.z-a.z).length()
		_box(root,"ObservedCoping",Vector3((a.x+b.x)/2.0,float(record.top_elevation_m)-.04,(a.z+b.z)/2.0)+rn*.055,rt,rn,Vector3(length,.12,.15),coping,"detail")
		var count := maxi(1,int(ceil(length/3.8)))
		for j in count:
			var p := a.lerp(b,float(j)/count)
			var height := float(record.top_elevation_m)-p.y-.14
			_box(root,"PanelJoint",p+Vector3(0,height/2.0,0)+rn*.024,rt,rn,Vector3(.036,height,.035),joint,"detail")
	# ENE blue service leaf and high pale louver; anchor is bounded art inference.
	var a := _vec(vertices.slice(9*12,9*12+3))
	var b := _vec(vertices.slice(9*12+3,9*12+6))
	var et := Vector3(b.x-a.x,0,b.z-a.z).normalized()
	var en := Vector3(-et.z,0,et.x)
	var ep := a.lerp(b,.43)
	_box(root,"ServiceDoorFrame",ep+en*.065+Vector3(0,1.23,0),et,en,Vector3(1.34,2.48,.13),frame,"wall")
	_box(root,"BlueServiceDoor",ep+en*.145+Vector3(0,1.20,0),et,en,Vector3(1.15,2.35,.065),blue,"wall")
	_box(root,"ServiceHandle",ep+et*.40+en*.20+Vector3(0,1.14,0),et,en,Vector3(.04,.19,.045),frame,"detail")
	_box(root,"HighLouverFrame",ep+en*.085+Vector3(0,6.30,0),et,en,Vector3(1.0,1.14,.17),frame,"detail")
	_box(root,"HighLouverRecess",ep+en*.185+Vector3(0,6.30,0),et,en,Vector3(.85,1.0,.065),blue,"detail")
	for j in 8:
		_box(root,"LouverBlade",ep+en*.235+Vector3(0,5.86+j*.125,0),et,en,Vector3(.86,.047,.075),frame,"detail")
	for key: String in cfg.ground:
		var spec: Dictionary = cfg.ground[key]
		var arrays: Array = []; arrays.resize(Mesh.ARRAY_MAX)
		var points := PackedVector3Array(); var normals := PackedVector3Array()
		for tri: Array in spec.triangles:
			for p: Array in tri:
				points.append(_vec(p)); normals.append(Vector3.UP)
		if points.is_empty():
			root.free()
			return {"ok": false, "message": "YMCA site requires positive native coverage."}
		arrays[Mesh.ARRAY_VERTEX]=points; arrays[Mesh.ARRAY_NORMAL]=normals
		var mesh := ArrayMesh.new(); mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		mesh.surface_set_material(0,_mat(Color(spec.color[0],spec.color[1],spec.color[2]),.96))
		var instance := MeshInstance3D.new(); instance.name=key; instance.mesh=mesh
		instance.set_meta("physical_role","ground_visual")
		root.add_child(instance)
	var result := SUPPORT.attach(root,record,record,{})
	if not bool(result.get("ok",false)): return result
	var meshes := 0; var triangles := 0
	for child: Node in root.get_children():
		if child is MeshInstance3D:
			meshes += 1
			triangles += (child as MeshInstance3D).mesh.get_faces().size()/3
	return {"ok":true,"node":root,"mesh_instances":meshes,"surfaces":meshes,"triangles":triangles}

static func _vec(a: Array) -> Vector3:
	return Vector3(a[0],a[1],a[2])

static func _mat(color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color=color; material.roughness=roughness
	return material

static func _box(root: Node3D, label: String, center: Vector3, t: Vector3, n: Vector3, size: Vector3, material: Material, role: String) -> void:
	var mesh := BoxMesh.new(); mesh.size=size; mesh.material=material
	var instance := MeshInstance3D.new(); instance.name=label; instance.mesh=mesh
	instance.transform=Transform3D(Basis(t,Vector3.UP,n),center)
	instance.set_meta("physical_role",role)
	instance.set_meta("construction_detail",label)
	root.add_child(instance)
