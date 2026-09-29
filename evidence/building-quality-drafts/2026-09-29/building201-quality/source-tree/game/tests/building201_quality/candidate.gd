extends RefCounted
## B201 candidate: existing receiver chain and complete frame components reused.
const LIVE=preload("res://game/scripts/world/facades/d1_b201_live_attachment.gd")
const PARTS=preload("res://game/scripts/world/facades/northpoint_1232_quality_model.gd")
const CONTACTS=preload("res://game/scripts/world/facades/housing_family_live_attachment.gd")
const SURFACE=preload("res://game/tests/building201_quality/surface.gdshader")
static func wall_material() -> ShaderMaterial:
	return _surface(Color(0.68,0.665,0.575),0.055,false)
static func _surface(color: Color,weather: float,courses: bool) -> ShaderMaterial:
	var m:=ShaderMaterial.new();m.shader=SURFACE;m.set_shader_parameter("base_color",color);m.set_shader_parameter("weathering",weather);m.set_shader_parameter("horizontal_courses",courses);return m
static func build(wall: Dictionary,surfaces: Array) -> Node3D:
	var prepared: Dictionary=LIVE.prepare(wall)
	if not prepared.get("ok",false):return null
	var authored: Dictionary=LIVE.authored_transform_spec(wall,prepared)
	if not authored.get("ok",false):return null
	var chain: Dictionary=prepared.chain
	var t: Vector3=chain.tangent;var n: Vector3=chain.outward
	var center: Vector3=(chain.start+chain.end)*0.5;center.y=LIVE.BASE_ELEVATION_M
	var root:=Node3D.new();root.name="Building201QualityCandidate"
	root.set_meta("candidate_unaccepted",true);root.set_meta("source_key",LIVE.SOURCE_KEY)
	var boxes: Dictionary={};var signatures: Array[String]=[]
	var wall_finish:=wall_material();var upper_finish:=_surface(Color(0.69,0.675,0.585),0.035,true)
	var green:=PARTS._material(Color(0.36,0.49,0.17),0.84)
	var trim:=PARTS._material(Color(0.63,0.64,0.565),0.86)
	var glass:=PARTS._material(Color(0.25,0.275,0.24),0.56)
	var rust:=PARTS._material(Color(0.36,0.215,0.145),0.88)
	var dark:=PARTS._material(Color(0.13,0.145,0.125),0.91)
	# Reuse existing window centres; narrower complete windows leave observed broad piers.
	for xf: Transform3D in authored.boxes.shared_dark_glass:
		var opening:=Vector2(2.65,0.93)
		var p:=Vector3(xf.origin.x,3.64,0.145)
		LIVE._add_box(boxes,signatures,"glass","DustyUpperWindow",p,Vector3(opening.x,opening.y,0.045))
		LIVE._add_complete_frame(boxes,signatures,"Upper",p+Vector3(0,0,0.055),opening,0.065,1)
		LIVE._add_box(boxes,signatures,"trim","UpperSill",p+Vector3(0,-0.53,0.055),Vector3(2.83,0.065,0.18))
	# Quiet painted upper infill; no fabricated hidden opening schedule.
	LIVE._add_box(boxes,signatures,"upper","UpperInfill",Vector3(0,3.65,0.108),Vector3(LIVE.CHAIN_LENGTH_M,1.53,0.015))
	LIVE._add_box(boxes,signatures,"green","UpperFascia",Vector3(0,4.39,0.17),Vector3(LIVE.CHAIN_LENGTH_M,0.095,0.18))
	LIVE._add_box(boxes,signatures,"trim","ParapetCoping",Vector3(0,4.94,0.18),Vector3(LIVE.CHAIN_LENGTH_M,0.13,0.23))
	# Existing shallow canopy structure extended across the photographed frontage.
	var width: float=LIVE.CHAIN_LENGTH_M-1.4
	LIVE._add_box(boxes,signatures,"wall","CanopySoffit",Vector3(0,2.79,1.05),Vector3(width,0.16,1.90))
	LIVE._add_box(boxes,signatures,"green","CanopyFascia",Vector3(0,2.78,2.025),Vector3(width,0.24,0.11))
	LIVE._add_box(boxes,signatures,"trim","CanopyDrip",Vector3(0,2.91,2.05),Vector3(width,0.045,0.17))
	for i in 16:
		var x: float=-width*0.5+1.1+i*(width-2.2)/15.0
		var world: Vector3=center+t*x+n*1.80
		var ground: float=sample_y(surfaces,world,true)
		if ground < -900.0:root.free();return null
		var bottom: float=ground-center.y-0.04;var top:=2.71
		LIVE._add_box(boxes,signatures,"rust","CanopyPost",Vector3(x,(bottom+top)*0.5,1.90),Vector3(0.12,top-bottom,0.12))
		LIVE._add_box(boxes,signatures,"rust","PostHead",Vector3(x,2.68,1.86),Vector3(0.30,0.10,0.24))
	for xf: Transform3D in authored.boxes.b201_service_leaf:
		var bottom: float=LIVE._sample_host_bottom_local_y(chain,xf.origin.x)-0.025
		var size:=Vector2(1.32,2.20-bottom);var p:=Vector3(xf.origin.x,(bottom+2.20)*0.5,0.145)
		LIVE._add_box(boxes,signatures,"dark","ServiceLeaf",p,Vector3(size.x,size.y,0.045))
		LIVE._add_outer_frame(boxes,signatures,"Service",p+Vector3(0,0,0.045),size,0.075)
	var materials: Dictionary={"wall":wall_finish,"upper":upper_finish,"green":green,"trim":trim,"glass":glass,"rust":rust,"dark":dark,"shared_pale_frame":trim}
	for key: String in boxes:
		for xf: Transform3D in boxes[key]:
			var size:=Vector3(xf.basis.x.length(),xf.basis.y.length(),xf.basis.z.length())
			var mesh:=PARTS._box(root,center+t*xf.origin.x+Vector3.UP*xf.origin.y+n*xf.origin.z,size,materials[key])
			mesh.basis=Basis(t,Vector3.UP,n);mesh.set_meta("family_role","wall")
			mesh.set_meta("derived_object_key",LIVE.RECEIVER_KEY);mesh.set_meta("source_keys",[LIVE.SOURCE_KEY]);mesh.set_meta("receiver_kind","building_wall");mesh.set_meta("opaque",true)
	# Existing B201 details are render2. Retain eligible opaque-detail semantics,
	# now giving their FINAL visible faces faithful stock solid/spray contact.
	var contact: Dictionary=CONTACTS._contacts(root,[],LIVE.SOURCE_KEY)
	if not contact.get("ok",false):root.free();return null
	for body: StaticBody3D in root.find_children("*","StaticBody3D",true,false):
		for holder: CollisionShape3D in body.get_children():
			for key in ["derived_object_key","source_keys","receiver_kind","opaque","family_role"]:
				holder.set_meta(key,body.get_meta(key));holder.shape.set_meta(key,body.get_meta(key))
	# A draped concrete apron is visual only; original LAND supplies support.
	var apron:=Node3D.new();apron.name="DrapedApronVisualOnly"
	var concrete:=_surface(Color(0.38,0.385,0.36),0.13,false)
	var apron_data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://game/tests/building201_quality/apron.json"))
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var raw: Array=apron_data.faces
	for i in range(0,raw.size(),3):
		var a:=Vector3(raw[i][0],raw[i][1],raw[i][2]);var b:=Vector3(raw[i+1][0],raw[i+1][1],raw[i+1][2]);var c:=Vector3(raw[i+2][0],raw[i+2][1],raw[i+2][2])
		var normal: Vector3=-(b-a).cross(c-a).normalized()
		if normal.y<=0.0:apron.free();root.free();return null
		for point: Vector3 in [a,b,c]:st.set_normal(normal);st.add_vertex(point)
	var mesh:=MeshInstance3D.new();mesh.name="ExactLandPlaneApron";mesh.mesh=st.commit();mesh.material_override=concrete;mesh.layers=1;mesh.set_meta("physical_role","ground_visual")
	apron.add_child(mesh);apron.set_meta("source_plane_lift_m",apron_data.uniform_land_lift_m)

	root.add_child(apron);root.set_meta("build_valid",true);root.set_meta("contact_triangles",contact.triangles)
	return root
static func sample_y(records: Array,p: Vector3,land_only: bool) -> float:
	var best: float=-1000.0
	for r: Dictionary in records:
		if land_only and str(r.get("feature_kind",""))!="land_ground":continue
		var v: Array=r.vertices;var ids: Array=r.indices
		for k in range(0,ids.size(),3):
			var a:=Vector3(v[int(ids[k])*3],v[int(ids[k])*3+1],v[int(ids[k])*3+2]);var b:=Vector3(v[int(ids[k+1])*3],v[int(ids[k+1])*3+1],v[int(ids[k+1])*3+2]);var c:=Vector3(v[int(ids[k+2])*3],v[int(ids[k+2])*3+1],v[int(ids[k+2])*3+2])
			var den: float=(b.z-c.z)*(a.x-c.x)+(c.x-b.x)*(a.z-c.z)
			if absf(den)<0.000001:continue
			var u: float=((b.z-c.z)*(p.x-c.x)+(c.x-b.x)*(p.z-c.z))/den;var w: float=((c.z-a.z)*(p.x-c.x)+(a.x-c.x)*(p.z-c.z))/den
			if minf(minf(u,w),1.0-u-w)>=-0.00001:best=maxf(best,u*a.y+w*b.y+(1.0-u-w)*c.y)
	return best
