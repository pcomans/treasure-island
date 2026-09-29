extends RefCounted
## Isolated B225 appearance study. Existing source solid and roof remain authoritative.
const CONTACTS = preload("res://game/scripts/world/facades/housing_family_live_attachment.gd")
const LIVE = preload("res://game/scripts/world/facades/d1_b225_live_attachment.gd")
const PARTS = preload("res://game/scripts/world/facades/northpoint_1232_quality_model.gd")
const CLADDING = preload("res://game/resources/materials/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_v1.tres")
const TRIM = preload("res://game/resources/materials/world/d1_current/shared_pale_frame.tres")
const GLASS = preload("res://game/resources/materials/world/d1_current/shared_dark_glass.tres")

static func build(wall: Dictionary, _roof: Dictionary, cfg: Dictionary) -> Node3D:
	var root := Node3D.new()
	root.name = "Building225QualityStudy"
	root.set_meta("source_key", "w95934119")
	root.set_meta("scope", "isolated_candidate_wall_contacts_original_roof_and_terrain_retained")
	var prepared: Dictionary = LIVE.prepare(wall)
	assert(bool(prepared.get("ok",false)))
	var authored: Dictionary = LIVE.authored_transform_spec(wall,prepared)
	assert(bool(authored.get("ok",false)))
	var chain: Dictionary = prepared.chain
	var start: Vector3 = chain.start
	var end: Vector3 = chain.end
	var t: Vector3 = chain.tangent
	var n: Vector3 = chain.outward
	var center := (start+end)*0.5
	center.y = LIVE.BASE_ELEVATION_M
	var widths: Array = []
	var holes: Array[Rect2] = []
	# Reuse accepted full motif schedule; shift opaque panes behind the wall and deepen complete reveals.
	for transform: Transform3D in authored.boxes.shared_dark_glass:
		var w := transform.basis.x.length()
		var h := transform.basis.y.length()
		var s := transform.origin.x+LIVE.CHAIN_LENGTH_M*0.5
		var y := LIVE.BASE_ELEVATION_M+transform.origin.y
		holes.append(Rect2(s-w*0.5,y-h*0.5,w,h))
		widths.append(w)
		var p := center+t*transform.origin.x+Vector3.UP*transform.origin.y
		_reveal(root,p,t,n,w,h,TRIM)
	for transform: Transform3D in authored.boxes.shared_dark_glass:
		var p := center+t*transform.origin.x+Vector3.UP*transform.origin.y-n*0.16
		_panel(root,p,t,n,Vector3(transform.basis.x.length(),transform.basis.y.length(),0.025),GLASS)
	for transform: Transform3D in authored.boxes.shared_pale_frame:
		var size := Vector3(transform.basis.x.length(),transform.basis.y.length(),transform.basis.z.length())
		var p := center+t*transform.origin.x+Vector3.UP*transform.origin.y+n*0.045
		_panel(root,p,t,n,size,TRIM)
	var lower: Array = cfg.get("lower_nnw",[])
	var weathered := PARTS._material(Color(0.43,0.44,0.40),0.92)
	for opening: Dictionary in lower:
		var s := float(opening.station)
		var w := float(opening.width)
		var h := float(opening.height)
		var y := float(opening.center_y)
		holes.append(Rect2(s-w*0.5,y-h*0.5,w,h))
		var p := Vector3(start.x,0,start.z)+t*s+Vector3.UP*y
		_reveal(root,p,t,n,w,h,TRIM)
		_panel(root,p-n*0.15,t,n,Vector3(w,h,0.03),weathered if opening.kind=="service" else GLASS)
		if opening.kind=="service":
			for i in range(1,int(h/0.18)):
				_panel(root,p+Vector3.UP*(-h*0.5+i*0.18)-n*0.125,t,n,Vector3(w,0.022,0.025),weathered)
		else:
			_panel(root,p-n*0.08,t,n,Vector3(0.07,h,0.08),TRIM)
			_panel(root,p-n*0.08,t,n,Vector3(w,0.065,0.08),TRIM)
	var v: Array = wall.vertices
	var side_u := 0.0
	for run in range(v.size()/12):
		if run in [0,3,7,10]: side_u=0.0
		var a := Vector3(v[run*12],v[run*12+1],v[run*12+2])
		var b := Vector3(v[run*12+3],v[run*12+4],v[run*12+5])
		var length := Vector2(b.x-a.x,b.z-a.z).length()
		var local_holes: Array[Rect2] = []
		if run>=10:
			for h: Rect2 in holes:
				var lo := maxf(side_u,h.position.x)
				var hi := minf(side_u+length,h.end.x)
				if hi>lo: local_holes.append(Rect2(lo-side_u,h.position.y,hi-lo,h.size.y))
		_wall(root,a,b,LIVE.TOP_ELEVATION_M,local_holes,side_u,CLADDING)
		var rt := Vector3(b.x-a.x,0,b.z-a.z).normalized()
		var rn := Vector3(-rt.z,0,rt.x)
		# Existing aged cladding carries the quiet continuous boarding; no thin pale course boxes.
		_panel(root,Vector3(a.x,LIVE.TOP_ELEVATION_M-0.035,a.z)+rt*length*0.5+rn*0.025,rt,rn,Vector3(length,0.12,0.13),TRIM)
		if run in [0,3,7,10]:
			_panel(root,Vector3(a.x,(a.y+LIVE.TOP_ELEVATION_M)*0.5,a.z)+rn*0.025,rt,rn,Vector3(0.12,LIVE.TOP_ELEVATION_M-a.y,0.09),TRIM)
		side_u+=length
	# Reuse the established face-baking installation path; all new surfaces are this wall's opaque exterior.
	for mesh: MeshInstance3D in root.get_children():
		mesh.set_meta("family_role","wall")
		mesh.set_meta("derived_object_key","building:w95934119:wall")
		mesh.set_meta("source_keys",["w95934119"])
		mesh.set_meta("receiver_kind","building_wall")
		mesh.set_meta("opaque",true)
	var contact: Dictionary = CONTACTS._contacts(root,[],"w95934119")
	if not bool(contact.get("ok",false)):
		root.free()
		return null
	for body: StaticBody3D in root.find_children("*","StaticBody3D",true,false):
		for holder: CollisionShape3D in body.get_children():
			for key in ["derived_object_key","source_keys","receiver_kind","opaque","family_role"]:
				holder.set_meta(key,body.get_meta(key))
				holder.shape.set_meta(key,body.get_meta(key))
	root.set_meta("build_valid",true)
	root.set_meta("contact_triangles",contact.triangles)
	return root

static func _panel(root: Node3D,p: Vector3,t: Vector3,n: Vector3,size: Vector3,material: Material) -> void:
	var node := PARTS._box(root,p,size,material)
	node.basis=Basis(t,Vector3.UP,n)

static func _reveal(root: Node3D,p: Vector3,t: Vector3,n: Vector3,w: float,h: float,material: Material) -> void:
	for side in [-1.0,1.0]:
		_panel(root,p+t*side*(w*0.5+0.025)-n*0.065,t,n,Vector3(0.05,h+0.1,0.23),material)
		_panel(root,p+Vector3.UP*side*(h*0.5+0.025)-n*0.065,t,n,Vector3(w+0.1,0.05,0.23),material)
	_panel(root,p-Vector3.UP*(h*0.5+0.075)+n*0.045,t,n,Vector3(w+0.16,0.08,0.24),material)

static func _wall(root: Node3D,a: Vector3,b: Vector3,top: float,holes: Array[Rect2],u0: float,material: Material) -> void:
	var length := Vector2(b.x-a.x,b.z-a.z).length()
	var t := Vector3(b.x-a.x,0,b.z-a.z).normalized()
	var xs: Array[float] = [0.0,length]
	var ys: Array[float] = [minf(a.y,b.y),top]
	for h: Rect2 in holes: xs.append(h.position.x);xs.append(h.end.x);ys.append(h.position.y);ys.append(h.end.y)
	xs.sort();ys.sort()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(xs.size()-1):
		if xs[i+1]-xs[i]<0.0001: continue
		for j in range(ys.size()-1):
			if ys[j+1]-ys[j]<0.0001: continue
			var mid := Vector2((xs[i]+xs[i+1])*0.5,(ys[j]+ys[j+1])*0.5)
			var omit := false
			for h: Rect2 in holes:
				if h.has_point(mid): omit=true
			if omit: continue
			var points: Array[Vector3] = []
			for q in [Vector2(xs[i],ys[j]),Vector2(xs[i+1],ys[j]),Vector2(xs[i+1],ys[j+1]),Vector2(xs[i],ys[j+1])]:
				points.append(Vector3(a.x,maxf(q.y,lerpf(a.y,b.y,q.x/length)),a.z)+t*q.x)
			for index in [0,2,1,0,3,2]:
				var p: Vector3=points[index]
				st.set_uv(Vector2(u0+Vector3(p.x-a.x,0,p.z-a.z).dot(t),top-p.y))
				st.add_vertex(p)
	st.generate_normals()
	var node := MeshInstance3D.new();node.mesh=st.commit();node.material_override=material;root.add_child(node)
