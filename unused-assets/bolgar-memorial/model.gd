extends RefCounted
# Bolgar Memorial Sign exterior study. Dimensions and hidden elevations inferred.
# Front = +Z. No photographed pixels, external dependencies or scene-tree effects.

static func build() -> Node3D:
	var root := Node3D.new()
	root.name = "Bolgar_Memorial_Sign"
	var stone := _stone(false)
	var carved := _stone(true)
	var trim := _mat(Color("ddd6c3"), 0.8)
	var dark := _mat(Color("263e3c"), 0.27)
	var gold := _mat(Color("b29a50"), 0.28, 0.85)
	var base := _mat(Color("a59e8e"), 0.9)
	_prism(root, "Octagonal_plinth", 10.5, 0.0, 1.65, stone)
	_prism(root, "Lower_stone_core", 8.62, 1.65, 11.55, stone)
	_prism(root, "Upper_octagon", 8.05, 11.55, 16.0, stone)
	_prism(root, "Lower_cornice", 9.1, 11.50, 11.7, trim)
	_prism(root, "Upper_cornice", 8.45, 15.94, 16.18, trim)
	for i in range(8):
		var lower := _face(root, "Lower_facet_%d" % i, i, 9.0)
		var w := 2.0 * 9.0 * tan(PI / 8.0)
		if i % 2 == 0:
			# Deep pointed portal/large vertical recess, closed exterior backing.
			_arch_wall(lower, w, 1.65, 11.5, 4.9, 9.3, 0.45, stone)
			_arch_panel(lower, "Portal_recess", 4.9, 9.3, Vector3(0,1.65,-0.34), stone)
			_arch_border(lower, 4.9, 9.3, 1.65, 0.14, 0.08, trim)
			if i == 0:
				_window(lower, 1.9, 3.0, Vector3(0,1.67,-0.26), dark, gold, false)
				_box(lower, "Door_transom", Vector3(0,4.81,-0.15), Vector3(2.05,0.22,0.18), trim)
				_window(lower, 1.95, 3.55, Vector3(0,5.03,-0.25), dark, gold)
				_box(lower, "Door_centre", Vector3(0,3.12,-0.08), Vector3(0.06,2.85,0.09), gold)
			else:
				_window(lower, 2.0, 5.4, Vector3(0,3.6,-0.23), dark, gold)
			for sx in [-1.0,1.0]:
				_box(lower,"Carved_portal_spandrel",Vector3(sx*2.83,6.66,0.015),Vector3(0.7,9.67,0.05),carved)
		else:
			_box(lower, "Stone_facet", Vector3(0,6.575,-0.16), Vector3(w,9.85,0.32),stone)
			_window(lower, 1.85, 3.55, Vector3(0,7.55,0.045), dark, gold)
			# Broad sloped shoulders below the upper windows.
			_wedge(lower, w, 1.65, 5.3, 7.15, 2.0, stone)
		var upper := _face(root, "Upper_facet_%d" % i, i, 8.35)
		var uw := 2.0 * 8.35 * tan(PI/8.0)
		_box(upper,"Carved_recess_panel",Vector3(0,13.79,-0.055),Vector3(uw-1.15,3.81,0.11),carved)
		for sx in [-1.0,1.0]:
			_box(upper,"Panel_side_frame",Vector3(sx*(uw/2.0-0.24),13.78,0.035),Vector3(0.48,4.3,0.22),stone)
		_box(upper,"Panel_head",Vector3(0,15.78,0.035),Vector3(uw,0.30,0.22),stone)
		_arch_panel(upper,"Upper_pointed_niche",3.35,3.5,Vector3(0,11.77,0.05),stone)
		_arch_border(upper,3.35,3.5,11.77,0.16,0.19,trim)
		_window(upper,1.12,2.65,Vector3(0,11.8,0.13),dark,gold)
	# Low entrance-side terrace parapets, kept separate from the upper monument.
	for sx in [-1.0,1.0]:
		_box(root,"Terrace_wing",Vector3(sx*11.3,0.74,7.7),Vector3(7.4,1.48,5.8),stone)
		_box(root,"Terrace_cap",Vector3(sx*11.3,1.52,7.7),Vector3(7.6,0.16,6.0),trim)
		for xx in [9.4,12.0]:
			var vent := Node3D.new()
			root.add_child(vent)
			vent.position=Vector3(sx*xx,0,10.63)
			_window(vent,1.25,0.92,Vector3(0,0.14,0),dark,gold)
	for j in range(11):
		_box(root,"Entrance_step_%02d"%j,Vector3(0,0.075*float(j+1),13.6-float(j)*0.31),Vector3(7.35,0.15*float(j+1),0.34),base)
	_box(root,"Entrance_landing",Vector3(0,1.59,9.94),Vector3(7.35,0.12,1.50),stone)
	# Gilded drum, pointed hemispherical dome, and slender crescent finial.
	_cylinder(root,"Gold_drum",8.02,0.78,Vector3(0,16.52,0),gold)
	_dome(root, gold)
	_cylinder(root,"Finial_neck",0.12,0.6,Vector3(0,25.44,0),gold)
	_sphere(root,"Finial_orb",0.47,Vector3(0,25.98,0),gold)
	_cylinder(root,"Finial_stem",0.075,0.7,Vector3(0,26.47,0),gold)
	_crescent(root,gold)
	_finish_rods(root)
	return root

static func _mat(c:Color,r:float,m:float=0.0)->StandardMaterial3D:
	var a:=StandardMaterial3D.new()
	a.albedo_color=c
	a.roughness=r
	a.metallic=m
	return a

static func _stone(ornament:bool)->ShaderMaterial:
	var s:=Shader.new()
	s.code="""shader_type spatial;
render_mode cull_disabled;
uniform bool ornament=false;
varying vec3 p;
void vertex(){p=VERTEX;}
float hash(vec2 v){return fract(sin(dot(v,vec2(127.1,311.7)))*43758.5453);}
void fragment(){
 vec2 q=vec2(p.x+p.z,p.y);
 float row=floor(q.y/0.34);
 float jx=abs(fract(q.x/0.83+mod(row,2.0)*0.5)-0.5);
 float jy=abs(fract(q.y/0.34)-0.5);
 float joint=max(smoothstep(0.478,0.497,jx),smoothstep(0.474,0.497,jy));
 float grain=hash(floor(q*150.0));
 float variation=hash(vec2(floor(q.x/0.83+mod(row,2.0)*0.5),row));
 vec3 col=vec3(0.57,0.535,0.465)*(0.97+0.06*variation);
 col=mix(col,col*0.76,joint*0.48);
 if(ornament){
  vec2 t=q*30.0;
  float vine=sin(t.x+1.1*sin(t.y))*cos(t.y+0.8*cos(t.x));
  float relief=smoothstep(0.10,0.23,abs(vine));
  col=vec3(0.57,0.535,0.465)*(0.93+0.075*relief);
  NORMAL_MAP=normalize(vec3(cos(t.x+sin(t.y))*0.045,sin(t.y+cos(t.x))*0.045,1.0))*0.5+0.5;
 }
 ALBEDO=col*(0.984+grain*0.032); ROUGHNESS=0.88;
}
"""
	var mat:=ShaderMaterial.new()
	mat.shader=s
	mat.set_shader_parameter("ornament",ornament)
	return mat

static func _mesh(parent:Node3D,n:String,verts:PackedVector3Array,uv:PackedVector2Array,mat:Material)->MeshInstance3D:
	var st:=SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(verts.size()):
		st.set_uv(uv[i])
		st.add_vertex(verts[i])
	st.generate_normals()
	var ob:=MeshInstance3D.new()
	ob.name=n
	ob.mesh=st.commit()
	ob.material_override=mat
	parent.add_child(ob)
	return ob

static func _poly(parent:Node3D,n:String,pts:PackedVector2Array,z:float,mat:Material)->void:
	var ids:=Geometry2D.triangulate_polygon(pts)
	var v:=PackedVector3Array()
	var uv:=PackedVector2Array()
	for j in range(0,ids.size(),3):
		for k in [0,2,1]:
			var p:=pts[ids[j+k]]
			v.append(Vector3(p.x,p.y,z))
			uv.append(p)
	_mesh(parent,n,v,uv,mat)

static func _box(parent:Node3D,n:String,p:Vector3,size:Vector3,mat:Material)->void:
	var ob:=MeshInstance3D.new()
	ob.name=n
	var mesh:=BoxMesh.new()
	mesh.size=size
	ob.mesh=mesh
	ob.position=p
	ob.material_override=mat
	parent.add_child(ob)

static func _face(parent:Node3D,n:String,i:int,a:float)->Node3D:
	var f:=Node3D.new()
	f.name=n
	f.rotation.y=float(i)*PI/4.0
	f.position=Vector3(sin(f.rotation.y)*a,0,cos(f.rotation.y)*a)
	parent.add_child(f)
	return f

static func _prism(parent:Node3D,n:String,a:float,y0:float,y1:float,mat:Material)->void:
	for i in range(8):
		var f:=_face(parent,n+"_%d"%i,i,a)
		var w:=a*tan(PI/8.0)
		_poly(f,n,PackedVector2Array([Vector2(-w,y0),Vector2(w,y0),Vector2(w,y1),Vector2(-w,y1)]),0,mat)
	var ob:=MeshInstance3D.new()
	var mesh:=CylinderMesh.new()
	mesh.top_radius=a/cos(PI/8.0)
	mesh.bottom_radius=mesh.top_radius
	mesh.height=0.10
	mesh.radial_segments=8
	ob.mesh=mesh
	ob.position.y=y1-0.05
	ob.rotation.y=PI/8.0
	ob.material_override=mat
	parent.add_child(ob)

static func _arch(w:float,h:float)->PackedVector2Array:
	var p:=PackedVector2Array([Vector2(-w/2,0),Vector2(w/2,0),Vector2(w/2,h*0.68)])
	for i in range(1,13):
		var t:=float(i)/12.0
		p.append(Vector2(w/2.0*(1.0-t*t),h*(0.68+0.32*t)))
	for i in range(1,13):
		var t:=1.0-float(i)/12.0
		p.append(Vector2(-w/2.0*(1.0-t*t),h*(0.68+0.32*t)))
	return p

static func _arch_panel(parent:Node3D,n:String,w:float,h:float,pos:Vector3,mat:Material)->void:
	var pts:=_arch(w,h)
	for i in range(pts.size()):pts[i]+=Vector2(pos.x,pos.y)
	_poly(parent,n,pts,pos.z,mat)

static func _arch_border(parent:Node3D,w:float,h:float,y:float,thick:float,z:float,mat:Material)->void:
	var pts:=_arch(w,h)
	for i in range(1,pts.size()):
		var a:=pts[i]+Vector2(0,y)
		var b:=pts[(i+1)%pts.size()]+Vector2(0,y)
		_rod(parent,Vector3(a.x,a.y,z),Vector3(b.x,b.y,z),thick,mat)

static func _arch_wall(parent:Node3D,w:float,y0:float,y1:float,aw:float,ah:float,depth:float,mat:Material)->void:
	var arch:=_arch(aw,ah)
	# Each side polygon follows half the arch to avoid a filled-in opening.
	var right:=PackedVector2Array([Vector2(aw/2,y0),Vector2(w/2,y0),Vector2(w/2,y1),Vector2(0,y1),Vector2(0,y0+ah)])
	for j in range(13,1,-1):right.append(arch[j]+Vector2(0,y0))
	_poly(parent,"Portal_right_wall",right,0,mat)
	var left:=PackedVector2Array()
	for j in range(right.size()-1,-1,-1):left.append(Vector2(-right[j].x,right[j].y))
	_poly(parent,"Portal_left_wall",left,0,mat)
	for j in range(1,arch.size()):
		var a:=arch[j]+Vector2(0,y0)
		var b:=arch[(j+1)%arch.size()]+Vector2(0,y0)
		var v:=PackedVector3Array([Vector3(a.x,a.y,0),Vector3(b.x,b.y,0),Vector3(b.x,b.y,-depth),Vector3(a.x,a.y,0),Vector3(b.x,b.y,-depth),Vector3(a.x,a.y,-depth)])
		_mesh(parent,"Portal_reveal",v,PackedVector2Array([a,b,b,a,b,a]),mat)

static func _window(parent:Node3D,w:float,h:float,pos:Vector3,glass:Material,gold:Material,pointed:bool=true)->void:
	var group:=Node3D.new()
	group.name="Pointed_gold_lattice"
	group.position=pos
	parent.add_child(group)
	var pts:=_arch(w,h) if pointed else PackedVector2Array([Vector2(-w/2,0),Vector2(w/2,0),Vector2(w/2,h),Vector2(-w/2,h)])
	_poly(group,"Dark_glazing",pts,0,glass)
	for j in range(pts.size()):
		var a:=pts[j]
		var b:=pts[(j+1)%pts.size()]
		_rod(group,Vector3(a.x,a.y,0.035),Vector3(b.x,b.y,0.035),0.045,gold)
	var cell:=0.36
	for yi in range(int(h/cell)+1):
		for xi in range(-int(w/cell),int(w/cell)+1):
			var centre:=Vector2(float(xi)*cell,float(yi)*cell+0.16)
			for j in range(16):
				var a:=float(j)*TAU/16.0
				var b:=float(j+1)*TAU/16.0
				var r1:=cell*(0.48 if j%2==0 else 0.28)
				var r2:=cell*(0.48 if (j+1)%2==0 else 0.28)
				var p1:=centre+Vector2(cos(a),sin(a))*r1
				var p2:=centre+Vector2(cos(b),sin(b))*r2
				if Geometry2D.is_point_in_polygon(p1,pts) and Geometry2D.is_point_in_polygon(p2,pts):
					_rod(group,Vector3(p1.x,p1.y,0.05),Vector3(p2.x,p2.y,0.05),0.019,gold)

static func _rod(parent:Node3D,a:Vector3,b:Vector3,r:float,mat:Material)->void:
	if not parent.has_meta("rod_data"):
		parent.set_meta("rod_data", {"vertices": [], "uv": [], "material": mat})
	var data:Dictionary=parent.get_meta("rod_data")
	var direction:Vector3=(b-a).normalized()
	var side:Vector3=direction.cross(Vector3.FORWARD).normalized()*r
	var depth:=Vector3(0,0,r)
	var ring:Array[Vector3]=[side+depth,-side+depth,-side-depth,side-depth]
	for i in range(4):
		var k: int=(i+1)%4
		for v in [a+ring[i],b+ring[k],b+ring[i],a+ring[i],a+ring[k],b+ring[k]]:
			data.vertices.append(v)
			data.uv.append(Vector2(v.x,v.y))

static func _finish_rods(parent:Node3D)->void:
	for child in parent.get_children():
		if child is Node3D:_finish_rods(child)
	if parent.has_meta("rod_data"):
		var data:Dictionary=parent.get_meta("rod_data")
		_mesh(parent,"Batched_raised_metal_or_trim",PackedVector3Array(data.vertices),PackedVector2Array(data.uv),data.material)
		parent.remove_meta("rod_data")

static func _wedge(parent:Node3D,w:float,bottom:float,front_top:float,back_top:float,d:float,mat:Material)->void:
	var v:=PackedVector3Array()
	var uv:=PackedVector2Array()
	var a:=Vector3(-w/2,bottom,d)
	var b:=Vector3(w/2,bottom,d)
	var c:=Vector3(w/2,front_top,d)
	var e:=Vector3(-w/2,front_top,d)
	var f:=Vector3(-w/2,back_top,0)
	var g:=Vector3(w/2,back_top,0)
	for tri in [[a,c,b],[a,e,c],[e,g,c],[e,f,g],[a,f,e],[a,Vector3(-w/2,bottom,0),f],[b,c,g],[b,g,Vector3(w/2,bottom,0)]]:
		for p in tri:
			v.append(p)
			uv.append(Vector2(p.x+p.z,p.y))
	_mesh(parent,"Sloping_stone_shoulder",v,uv,mat)

static func _cylinder(parent:Node3D,n:String,r:float,h:float,p:Vector3,mat:Material)->void:
	var ob:=MeshInstance3D.new()
	ob.name=n
	var mesh:=CylinderMesh.new()
	mesh.top_radius=r
	mesh.bottom_radius=r
	mesh.height=h
	mesh.radial_segments=96
	ob.mesh=mesh
	ob.position=p
	ob.material_override=mat
	parent.add_child(ob)

static func _sphere(parent:Node3D,n:String,r:float,p:Vector3,mat:Material)->void:
	var ob:=MeshInstance3D.new()
	ob.name=n
	var mesh:=SphereMesh.new()
	mesh.radius=r
	mesh.height=r*2.0
	ob.mesh=mesh
	ob.position=p
	ob.material_override=mat
	parent.add_child(ob)

static func _dome(parent:Node3D,_gold:Material)->void:
	var shader:=Shader.new()
	shader.code="""shader_type spatial;
render_mode cull_disabled;
void fragment(){
 vec2 q=UV*vec2(160.0,46.0);
 q.x+=mod(floor(q.y),2.0)*0.5;
 vec2 c=fract(q)-0.5;
 float edge=smoothstep(0.43,0.49,length(vec2(c.x,c.y*0.8)));
 ALBEDO=mix(vec3(0.46,0.31,0.085),vec3(0.29,0.23,0.095),edge*0.43);
 METALLIC=0.9;ROUGHNESS=0.29+edge*0.14;
 NORMAL_MAP=normalize(vec3(c.x*0.12,c.y*0.10,1.0))*0.5+0.5;
}
"""
	var mat:=ShaderMaterial.new()
	mat.shader=shader
	var st:=SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var nr:=48
	var ns:=128
	for j in range(nr):
		for i in range(ns):
			for off in [Vector2i(0,0),Vector2i(1,1),Vector2i(1,0),Vector2i(0,0),Vector2i(0,1),Vector2i(1,1)]:
				var t:=float(j+off.y)/float(nr)
				var angle:=float(i+off.x)*TAU/float(ns)
				var r:=8.08*cos(t*PI/2.0)
				var y:=16.9+8.3*(0.75*sin(t*PI/2.0)+0.25*t)
				st.set_uv(Vector2(float(i+off.x)/float(ns),t))
				st.add_vertex(Vector3(sin(angle)*r,y,cos(angle)*r))
	st.generate_normals()
	var ob:=MeshInstance3D.new()
	ob.name="Gilded_scale_dome"
	ob.mesh=st.commit()
	ob.material_override=mat
	parent.add_child(ob)

static func _crescent(parent:Node3D,mat:Material)->void:
	# Tapered crescent outline in the facade plane, open toward upper right.
	var pts:=PackedVector2Array()
	for i in range(49):
		var a:=deg_to_rad(58.0+float(i)*244.0/48.0)
		pts.append(Vector2(cos(a)*0.95,sin(a)*0.95))
	for i in range(49):
		var a:=deg_to_rad(302.0-float(i)*244.0/48.0)
		var t:=float(i)/48.0
		var r:=0.95-0.24*sin(t*PI)
		pts.append(Vector2(cos(a)*r+0.13*sin(t*PI),sin(a)*r))
	for z in [-0.08,0.08]:
		var shifted:=PackedVector2Array()
		for p in pts:shifted.append(p+Vector2(0,27.42))
		_poly(parent,"Crescent",shifted,z,mat)
	for i in range(pts.size()):
		var a:=pts[i]+Vector2(0,27.42)
		var b:=pts[(i+1)%pts.size()]+Vector2(0,27.42)
		_mesh(parent,"Crescent_edge",PackedVector3Array([Vector3(a.x,a.y,-0.08),Vector3(b.x,b.y,0.08),Vector3(b.x,b.y,-0.08),Vector3(a.x,a.y,-0.08),Vector3(a.x,a.y,0.08),Vector3(b.x,b.y,0.08)]),PackedVector2Array([a,b,b,a,a,b]),mat)
