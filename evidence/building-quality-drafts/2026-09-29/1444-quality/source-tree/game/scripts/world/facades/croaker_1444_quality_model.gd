extends RefCounted
# Isolated1444 whole-building study. July2023 observed west face; unsurveyed dimensions are production inference.
static func color_material(c:String,rough:float=0.82)->StandardMaterial3D:
	var m:=StandardMaterial3D.new();m.albedo_color=Color(c);m.roughness=rough;return m
static func cladding()->ShaderMaterial:
	var sh:=Shader.new();sh.code="""shader_type spatial;
	varying vec3 wp;
	void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
	void fragment(){ALBEDO=vec3(0.39,0.295,0.17)*(0.995+0.005*sin(wp.x*83.0)*sin(wp.y*91.0));ROUGHNESS=0.88;}"""
	var m:=ShaderMaterial.new();m.shader=sh;return m
static func box(root:Node3D,p:Vector3,size:Vector3,m:Material,angle:float=0.0)->void:
	if size.x<0.001 or size.y<0.001 or size.z<0.001:return
	var mesh:=BoxMesh.new();mesh.size=size;var n:=MeshInstance3D.new();n.mesh=mesh;n.material_override=m;n.position=p;n.rotation.y=angle;root.add_child(n)
# The roof resource contains checked clockwise Float32 triangles. No runtime
# offset/boolean cleanup can create empty surfaces between preflight and rendering.
static func roof_part(root:Node3D,part:Dictionary,material:Material)->void:
	var vertices:=PackedVector3Array()
	var normals:=PackedVector3Array()
	var uv:=PackedVector2Array()
	for triangle in part.triangles:
		var a:=Vector3(triangle[0][0],triangle[0][1],triangle[0][2])
		var b:=Vector3(triangle[1][0],triangle[1][1],triangle[1][2])
		var c:=Vector3(triangle[2][0],triangle[2][1],triangle[2][2])
		var front:Vector3=(c-a).cross(b-a)
		assert(front.length_squared()>0.000000000001,"Degenerate authored roof triangle")
		for point in [a,b,c]:
			vertices.append(point)
			normals.append(front.normalized())
			uv.append(Vector2(point.x,point.z))
	assert(not vertices.is_empty(),"Missing authored roof surface")
	var arrays:Array=[]
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX]=vertices
	arrays[Mesh.ARRAY_NORMAL]=normals
	arrays[Mesh.ARRAY_TEX_UV]=uv
	var mesh:=ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var node:=MeshInstance3D.new()
	node.mesh=mesh
	node.material_override=material
	node.name=part.label
	root.add_child(node,true)
static func roof_material()->ShaderMaterial:
	var sh:=Shader.new();sh.code="""shader_type spatial;
	varying vec3 wp;
	void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
	void fragment(){
	 vec2 p=vec2(dot(wp.xz,vec2(0.4348295,0.9005128)),dot(wp.xz,vec2(-0.9005128,0.4348295)));
	 vec2 cell=floor(p/vec2(0.42,0.20));float grain=fract(sin(dot(cell,vec2(12.9898,78.233)))*43758.5453);
	 float course=fract(p.y/0.20);float aa=max(fwidth(p.y/0.20),0.035);float seam=1.0-smoothstep(0.025,0.025+aa,course);
	 ALBEDO=vec3(0.085,0.068,0.047)*(0.94+grain*0.12)*(1.0-seam*0.09);ROUGHNESS=0.94;
	}"""
	var m:=ShaderMaterial.new();m.shader=sh;return m
static func build(record:Dictionary,ground:Callable)->Node3D:
	var root:=Node3D.new();root.name="Croaker1444ScratchStudy"
	var stucco:=cladding();var glass:=color_material("354344",0.35);var frame:=color_material("bcb8a2");var roofmat:=roof_material();var rail:=color_material("565e4d");var slab:=color_material("8e8b77")
	var soffit:=color_material("9b9279")
	var base:float=record.flat_base_elevation_m;var height:=5.62;var pts:Array[Vector3]=[]
	for i in range(0,record.vertices.size(),12):pts.append(Vector3(record.vertices[i],base,record.vertices[i+2]))
	var origin:Vector3=pts[0];var along:Vector3=(pts[2]-origin).normalized();var out:=Vector3(-along.z,0,along.x);var angle:=atan2(-along.z,along.x);var length:=origin.distance_to(pts[2])
	# Quiet upper north mass over a continuous, open exterior corner shelter.
	# Photo supports the solid/void relationship; exact extent and cadence are inferred.
	var holes:Array[Rect2]=[Rect2(0.0,0.0,5.30,2.64),Rect2(length-3.35,0.02,2.9,2.58),Rect2(length-3.35,2.92,2.9,2.52)]
	for x in [10.9,14.3,17.9]:
		holes.append(Rect2(x,3.83,0.92,1.15))
		holes.append(Rect2(x,0.98,0.92,1.12))
	for j in pts.size():
		var a:Vector3=pts[j];var b:Vector3=pts[(j+1)%pts.size()];var t:Vector3=(b-a).normalized();var n:=Vector3(-t.z,0,t.x);var size:=a.distance_to(b);var rot:=atan2(-t.z,t.x)
		var cuts:Array[Rect2]=[];var station:float=(a-origin).dot(along)
		if j in [0,1]:cuts=holes
		# Retain the north corner pier and open the short return into the shelter.
		if j==20:cuts=[Rect2(station+0.27,0.0,size-0.27,2.64)]
		if j==21:cuts=[Rect2(station,0.0,size,2.64)]
		var xs:Array[float]=[0.0,size];var ys:Array[float]=[0.0,height]
		for h in cuts:
			if h.end.x>station and h.position.x<station+size:
				xs.append(clampf(h.position.x-station,0,size));xs.append(clampf(h.end.x-station,0,size));ys.append(h.position.y);ys.append(h.end.y)
		xs.sort();ys.sort()
		for xi in range(xs.size()-1):
			for yi in range(ys.size()-1):
				var wid:float=xs[xi+1]-xs[xi];var hei:float=ys[yi+1]-ys[yi]
				if wid<0.001 or hei<0.001:continue
				var mid:=Vector2((xs[xi]+xs[xi+1])*0.5+station,(ys[yi]+ys[yi+1])*0.5);var empty:=false
				for h in cuts:if h.has_point(mid):empty=true
				if not empty:box(root,a+t*(mid.x-station)+Vector3.UP*mid.y-n*0.10,Vector3(wid,hei,0.20),stucco,rot)
		# Foundations follow only solid wall portions; never bridge a shelter mouth.
		for xi in range(xs.size()-1):
			var left:float=xs[xi]
			var right:float=xs[xi+1]
			var bottom_open:=false
			for h in cuts:
				if h.position.y<0.1 and h.has_point(Vector2(station+(left+right)*0.5,0.1)):bottom_open=true
			if not bottom_open:box(root,a+t*((left+right)*0.5)-Vector3.UP*0.13-n*0.08,Vector3(right-left,0.26,0.16),slab,rot)
	# The open L-shaped sheltered space joins run 20, return 21 and frontage 0.
	# The rear and side are exterior enclosure, with no rooms or interior detail.
	var shelter_top:=2.64
	var back_depth:=6.15
	var north_station:float=(pts[20]-origin).dot(along)
	var end_depth:float=-(pts[20]-origin).dot(out)
	var back_left:float=north_station+0.20
	var back_width:float=5.30-back_left
	box(root,origin+along*((back_left+5.30)*0.5)-out*back_depth+Vector3.UP*(shelter_top*0.5-0.13),Vector3(back_width,shelter_top+0.26,0.20),stucco,angle)
	box(root,origin+along*5.30-out*(back_depth*0.5)+Vector3.UP*(shelter_top*0.5-0.13),Vector3(0.20,shelter_top+0.26,back_depth),stucco,angle)
	box(root,origin+along*2.65-out*(back_depth*0.5)+Vector3.UP*(shelter_top+0.08),Vector3(5.30,0.16,back_depth),soffit,angle)
	box(root,origin+along*(north_station*0.5)-out*((back_depth+end_depth)*0.5)+Vector3.UP*(shelter_top+0.08),Vector3(-north_station,0.16,back_depth-end_depth),soffit,angle)
	for k in range(1,holes.size()):
		var h:Rect2=holes[k];var c:=h.get_center();var p:=origin+along*c.x+Vector3.UP*c.y;var deep:float=1.85 if k<3 else 0.19
		# Exterior recess: sealed at back, no interiors or false deep painted void.
		box(root,p-out*deep,Vector3(h.size.x,h.size.y,0.12),glass,angle)
		for side in [-1.0,1.0]:box(root,p+along*(float(side)*(h.size.x*0.5-0.06))-out*(deep*0.5),Vector3(0.12,h.size.y,deep),stucco if k<3 else frame,angle)
		for side in [-1.0,1.0]:box(root,p+Vector3.UP*(float(side)*(h.size.y*0.5-0.04))-out*(deep*0.5),Vector3(h.size.x,0.08,deep),stucco if k<3 else frame,angle)
		if k in [1,2]:
			var floor_y:float=base+h.position.y
			box(root,Vector3(p.x,floor_y+0.04,p.z)-out*0.90,Vector3(h.size.x,0.12,1.8),slab,angle)
			if k==2:
				for z in [0.15,1.10]:box(root,Vector3(p.x,floor_y+float(z),p.z)-out*0.08,Vector3(h.size.x,0.065,0.07),rail,angle)
				for i in 17:box(root,Vector3(p.x,floor_y+0.62,p.z)+along*((float(i)/16.0-0.5)*(h.size.x-0.1))-out*0.08,Vector3(0.035,0.92,0.045),rail,angle)
		elif k>=3:
			box(root,p-out*0.08,Vector3(0.035,h.size.y,0.06),frame,angle)
			box(root,p-Vector3.UP*(h.size.y*0.5)+out*0.04,Vector3(h.size.x+0.12,0.065,0.28),frame,angle)
	# Coherent shallow roof: exact offline Float32 triangles, sealed shell,
	# 0.28 m eave and the same height function for frozen-wall gable closures.
	var roof_data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://game/scripts/world/facades/croaker_1444_roof003.json"))
	assert(roof_data.object_key==record.object_key)
	for part in roof_data.parts:
		roof_part(root,part,stucco if part.label=="RoofWallClosure" else soffit if part.label=="RoofSoffit" else roofmat)
	root.set_meta("roof_expected",roof_data.expected)
	# Assign ownership before shelter material instances are specialized.
	for child:Node in root.get_children():
		if child is MeshInstance3D:
			var mesh:=child as MeshInstance3D
			var role:="wall" if mesh.material_override == stucco else "detail"
			if str(mesh.name).begins_with("Roof") and str(mesh.name)!="RoofWallClosure":role="roof"
			mesh.set_meta("physical_role",role)
	var visibility=load("res://game/scripts/world/facades/croaker_1444_shelter_visibility.gd")
	visibility.apply(root)
	# The live factory derives tagged contacts from these same visible meshes.
	root.set_meta("roof_triangle_count",roof_data.expected.triangle_counts.RoofTop)
	return root
