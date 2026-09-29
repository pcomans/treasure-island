extends RefCounted
# Isolated1439 whole-building study. July2023 observed SSE face; unsurveyed dimensions are production inference.
static func color_material(c:String,rough:float=0.82)->StandardMaterial3D:
	var m:=StandardMaterial3D.new();m.albedo_color=Color(c);m.roughness=rough;return m
static func cladding()->ShaderMaterial:
	var sh:=Shader.new();sh.code="""shader_type spatial;
	varying vec3 wp;
	void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
	void fragment(){ALBEDO=vec3(0.62,0.58,0.49)*(0.995+0.005*sin(wp.x*83.0)*sin(wp.y*91.0));ROUGHNESS=0.88;}"""
	var m:=ShaderMaterial.new();m.shader=sh;return m
static func box(root:Node3D,p:Vector3,size:Vector3,m:Material,angle:float=0.0,detail:String="")->void:
	if size.x<0.001 or size.y<0.001 or size.z<0.001:return
	var mesh:=BoxMesh.new();mesh.size=size;var n:=MeshInstance3D.new();n.mesh=mesh;n.material_override=m;n.position=p;n.rotation.y=angle;root.add_child(n)
	if not detail.is_empty():n.set_meta("construction_detail",detail)
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
	 vec2 p=vec2(dot(wp.xz,vec2(0.891,-0.454)),dot(wp.xz,vec2(0.454,0.891)));
	 vec2 cell=floor(p/vec2(0.42,0.20));float grain=fract(sin(dot(cell,vec2(12.9898,78.233)))*43758.5453);
	 float course=fract(p.y/0.20);float aa=max(fwidth(p.y/0.20),0.035);float seam=1.0-smoothstep(0.025,0.025+aa,course);
	 ALBEDO=vec3(0.085,0.068,0.047)*(0.94+grain*0.12)*(1.0-seam*0.09);ROUGHNESS=0.94;
	}"""
	var m:=ShaderMaterial.new();m.shader=sh;return m
static func build(record:Dictionary,ground:Callable)->Node3D:
	var root:=Node3D.new();root.name="Chinook1439ScratchStudy"
	var stucco:=cladding();var glass:=color_material("414c4a",0.38);var frame:=color_material("b5b4a4");var rail:=color_material("555a4c");var slab:=color_material("a19d8a");var soffit:=color_material("bcb6a3")
	var base:float=record.flat_base_elevation_m;var height:=5.62;var pts:Array[Vector3]=[]
	for i in range(0,record.vertices.size(),12):pts.append(Vector3(record.vertices[i],base,record.vertices[i+2]))
	var origin:Vector3=pts[4];var along:Vector3=(pts[6]-origin).normalized();var out:=Vector3(-along.z,0,along.x);var angle:=atan2(-along.z,along.x)
	# Finite elevation: broad pale panels separated by two exterior loggias.
	# Upper proportions are observed; precise positions and lower treatment inferred.
	var holes:Array[Rect2]=[Rect2(3.05,2.98,3.15,2.48),Rect2(14.1,2.98,3.9,2.48),Rect2(3.05,0.10,3.15,2.54),Rect2(14.1,0.10,3.9,2.54),Rect2(8.55,4.12,0.98,1.05),Rect2(10.55,4.12,1.10,1.05),Rect2(8.55,0.98,0.98,1.08),Rect2(10.55,0.98,1.10,1.08)]
	for j in pts.size():
		var a:Vector3=pts[j];var b:Vector3=pts[(j+1)%pts.size()];var t:Vector3=(b-a).normalized();var n:=Vector3(-t.z,0,t.x);var size:=a.distance_to(b);var rot:=atan2(-t.z,t.x)
		var cuts:Array[Rect2]=[];var station:float=(a-origin).dot(along)
		if j in [4,5]:cuts=holes
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
				if j in [4,5] and mid.y<0.10:
					for lower:int in [2,3]:
						if mid.x>holes[lower].position.x and mid.x<holes[lower].end.x:empty=true
				if not empty:box(root,a+t*(mid.x-station)+Vector3.UP*mid.y-n*0.10,Vector3(wid,hei,0.20),stucco,rot)
		# Follow each frozen source wall bottom rather than flattening local terrain.
		var bottom:float=base
		for v in range(4):bottom=minf(bottom,float(record.vertices[j*12+v*3+1]))
		var skirt:float=base-bottom+0.08
		if j in [4,5]:
			var spans:Array[Vector2]=[Vector2(0,size)]
			for lower:int in [2,3]:
				var left:float=clampf(holes[lower].position.x-station,0,size)
				var right:float=clampf(holes[lower].end.x-station,0,size)
				if right<=left:continue
				var kept:Array[Vector2]=[]
				for span:Vector2 in spans:
					if left>span.x:kept.append(Vector2(span.x,minf(left,span.y)))
					if right<span.y:kept.append(Vector2(maxf(right,span.x),span.y))
				spans=kept
			for span:Vector2 in spans:
				box(root,a+t*((span.x+span.y)*0.5)-Vector3.UP*(skirt*0.5)-n*0.10,Vector3(span.y-span.x,skirt,0.20),stucco,rot,"1439_grounded_loggia_fit")
		else:
			box(root,a+t*(size*0.5)-Vector3.UP*(skirt*0.5)-n*0.10,Vector3(size,skirt,0.20),stucco,rot)
	for k in holes.size():
		var h:Rect2=holes[k];var c:=h.get_center();var p:=origin+along*c.x+Vector3.UP*c.y;var loggia:bool=k<4;var deep:float=1.55 if loggia else 0.19
		var shell_p:Vector3=p;var shell_height:float=h.size.y;var fit_detail:String=""
		if k in [2,3]:
			# Open the lower mouth onto intact LAND; no slab, ramp or altered terrain.
			var low:float=base
			for station_x:float in [h.position.x,h.end.x]:
				for depth:float in [0.0,deep]:
					var sample:Vector3=origin+along*station_x-out*depth
					low=minf(low,float(ground.call(Vector2(sample.x,sample.z))))
			low-=0.03
			var top:float=base+h.end.y
			shell_height=top-low;shell_p.y=(top+low)*0.5;fit_detail="1439_grounded_loggia_fit"
		# Opaque exterior back seals the recess; no interior space or borrowed scene.
		box(root,shell_p-out*deep,Vector3(h.size.x,shell_height,0.12),stucco if loggia else glass,angle,fit_detail)
		for side in [-1.0,1.0]:box(root,shell_p+along*(float(side)*(h.size.x*0.5-0.06))-out*(deep*0.5),Vector3(0.12,shell_height,deep),stucco if loggia else frame,angle,fit_detail)
		for side in [-1.0,1.0]:
			if k in [2,3] and side<0:continue
			box(root,p+Vector3.UP*(float(side)*(h.size.y*0.5-0.04))-out*(deep*0.5),Vector3(h.size.x,0.08,deep),soffit if loggia else frame,angle)
		if loggia:
			var floor_y:float=base+h.position.y
			if k<2:box(root,Vector3(p.x,floor_y+0.04,p.z)-out*0.77,Vector3(h.size.x,0.12,1.55),slab,angle)
			# Restrained rear glazing reads as exterior access from ordinary distance.
			box(root,p-out*(deep-0.07)+Vector3.UP*0.06,Vector3(h.size.x*0.58,h.size.y*0.80,0.04),glass,angle)
			box(root,p-out*(deep-0.10)+Vector3.UP*0.06,Vector3(0.055,h.size.y*0.80,0.05),frame,angle)
			if k<2:
				for y in [0.16,1.12]:box(root,Vector3(p.x,floor_y+float(y),p.z)-out*0.12,Vector3(h.size.x,0.07,0.08),rail,angle)
				var count:int=int(h.size.x/0.18)
				for i in count+1:box(root,Vector3(p.x,floor_y+0.63,p.z)+along*((float(i)/count-0.5)*(h.size.x-0.12))-out*0.12,Vector3(0.035,0.92,0.045),rail,angle)
		else:
			box(root,p-out*0.09,Vector3(0.035,h.size.y,0.06),frame,angle)
			box(root,p-Vector3.UP*(h.size.y*0.5)+out*0.03,Vector3(h.size.x+0.12,0.065,0.25),frame,angle)
	var roof_data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://game/scripts/world/facades/chinook_1439_roof001.json"))
	assert(roof_data.object_key==record.object_key)
	for part in roof_data.parts:roof_part(root,part,stucco if part.label=="RoofWallClosure" else soffit if part.label=="RoofSoffit" else roof_material())
	root.set_meta("roof_expected",roof_data.expected)
	# Shared production support owns classified contacts once from these meshes.
	for child:Node in root.get_children():
		if child is MeshInstance3D:
			var mesh:=child as MeshInstance3D
			var role:="wall" if mesh.material_override == stucco else "detail"
			if str(mesh.name).begins_with("Roof") and str(mesh.name)!="RoofWallClosure":role="roof"
			mesh.set_meta("physical_role",role)
	root.set_meta("roof_triangle_count",roof_data.expected.triangle_counts.RoofTop)
	return root
