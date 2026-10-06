extends RefCounted
## Mersea exterior family. Module dimensions and detailing are production inference.
## Source associations and reference limits: discovery/MERSEA_STUDY.md.

static var _materials: Dictionary = {}

static func mat(c: String, metal: float = 0.0, rough: float = 0.7) -> StandardMaterial3D:
	var key := "%s/%s/%s" % [c, metal, rough]
	if _materials.has(key):
		return _materials[key]
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(c)
	m.metallic = metal
	m.roughness = rough
	_materials[key] = m
	return m

static func box(p: Node3D, pos: Vector3, size: Vector3, m: Material) -> MeshInstance3D:
	var n = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = size
	n.mesh = mesh
	n.material_override = m
	n.position = pos
	p.add_child(n)
	return n

static func cyl(p: Node3D, pos: Vector3, radius: float, height: float, m: Material, top: float = -1.0) -> MeshInstance3D:
	var n = MeshInstance3D.new()
	var mesh = CylinderMesh.new()
	mesh.top_radius = radius if top < 0.0 else top
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 8 if radius < 0.09 else 24
	n.mesh = mesh
	n.material_override = m
	n.position = pos
	p.add_child(n)
	return n

static func rod(p: Node3D, a: Vector3, b: Vector3, r: float, m: Material) -> void:
	var n = cyl(p, (a+b)*0.5, r, a.distance_to(b), m)
	var d = (b-a).normalized()
	if abs(d.dot(Vector3.UP)) < 0.999:
		n.quaternion = Quaternion(Vector3.UP, d)

static func text_sign(p: Node3D, s: String, pos: Vector3, size: int, color: Color) -> void:
	var n = Label3D.new()
	n.text = s
	n.font_size = size
	n.pixel_size = 0.007
	n.modulate = color
	n.outline_size = 0
	n.position = pos
	p.add_child(n)

static func granular(c: String, other: String, scale_value: float) -> StandardMaterial3D:
	var key := "grain/%s/%s/%s" % [c, other, scale_value]
	if _materials.has(key):return _materials[key]
	var m: StandardMaterial3D = mat(c).duplicate()
	var noise := FastNoiseLite.new()
	noise.seed = 31
	noise.frequency = 0.24
	noise.fractal_octaves = 4
	var tex := NoiseTexture2D.new()
	tex.width = 512;tex.height = 512;tex.noise = noise;tex.seamless = true
	var gradient := Gradient.new()
	gradient.set_color(0, Color(c));gradient.set_color(1, Color(other))
	tex.color_ramp = gradient
	m.albedo_color = Color.WHITE;m.albedo_texture = tex
	var normal := NoiseTexture2D.new()
	normal.width = 512;normal.height = 512;normal.noise = noise;normal.seamless = true
	normal.as_normal_map = true;normal.bump_strength = 0.65
	m.normal_enabled = true;m.normal_texture = normal;m.normal_scale = 0.28
	var rough := NoiseTexture2D.new()
	rough.width = 512;rough.height = 512;rough.noise = noise;rough.seamless = true
	var rough_ramp := Gradient.new()
	rough_ramp.set_color(0, Color(0.72,0.72,0.72));rough_ramp.set_color(1,Color.WHITE)
	rough.color_ramp = rough_ramp;m.roughness_texture = rough
	m.uv1_triplanar = true;m.uv1_scale = Vector3.ONE * scale_value
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	_materials[key] = m
	return m

static func chair(p: Node3D, pos: Vector3, yaw: float, m: Material) -> void:
	var g := Node3D.new();g.position = pos;g.rotation.y = yaw;p.add_child(g)
	# Thin welded wire mesh, with tubular perimeter and gently reclined back.
	for x in range(11):
		var xx := -0.20+x*0.04
		rod(g,Vector3(xx,0.46,-0.20),Vector3(xx,0.46,0.20),0.005,m)
		rod(g,Vector3(xx,0.51,0.21),Vector3(xx,0.86,0.27),0.005,m)
	for z in range(11):rod(g,Vector3(-0.21,0.46,-0.20+z*0.04),Vector3(0.21,0.46,-0.20+z*0.04),0.005,m)
	for y in range(9):rod(g,Vector3(-0.21,0.52+y*0.04,0.21+y*0.007),Vector3(0.21,0.52+y*0.04,0.21+y*0.007),0.005,m)
	for x in [-0.22,0.22]:
		rod(g,Vector3(x*1.2,0.02,-0.23),Vector3(x,0.46,-0.19),0.016,m)
		rod(g,Vector3(x*1.2,0.02,0.29),Vector3(x,0.87,0.27),0.016,m)
		rod(g,Vector3(x,0.46,-0.21),Vector3(x,0.46,0.23),0.017,m)
		rod(g,Vector3(x,0.65,-0.10),Vector3(x,0.65,0.23),0.014,m)
		rod(g,Vector3(x,0.46,-0.10),Vector3(x,0.65,-0.10),0.014,m)
	rod(g,Vector3(-0.22,0.87,0.27),Vector3(0.22,0.87,0.27),0.018,m)
	rod(g,Vector3(-0.22,0.46,-0.21),Vector3(0.22,0.46,-0.21),0.018,m)

static func table(p: Node3D, x: float, z: float, long_table: bool = false) -> void:
	var metal := mat("a9b1ae",0.85,0.34)
	var dark := mat("293431",0.0,0.62)
	if long_table:
		for strip in range(14):box(p,Vector3(x,0.80,z-0.46+strip*0.071),Vector3(2.7,0.045,0.062),dark)
		for dx in [-1.14,1.14]:
			for dz in [-0.4,0.4]:rod(p,Vector3(x+dx,0.02,z+dz),Vector3(x+dx,0.79,z+dz),0.027,dark)
			rod(p,Vector3(x+dx,0.69,z-0.45),Vector3(x+dx,0.69,z+0.45),0.023,dark)
		for dx in [-0.85,0.0,0.85]:
			chair(p,Vector3(x+dx,0,z+0.87),0,dark)
			chair(p,Vector3(x+dx,0,z-0.87),PI,dark)
	else:
		cyl(p,Vector3(x,0.79,z),0.55,0.038,mat("4d99ab",0.0,0.33))
		cyl(p,Vector3(x,0.40,z),0.035,0.74,metal)
		for angle in [0.0,TAU/3,TAU*2/3]:rod(p,Vector3(x,0.18,z),Vector3(x+cos(angle)*0.39,0.035,z+sin(angle)*0.39),0.021,metal)
		chair(p,Vector3(x,0,z+0.85),0,metal);chair(p,Vector3(x,0,z-0.85),PI,metal)
	# Coarse table body prevents walking through the substantial furnishing.
	var contact := box(p,Vector3(x,0.41,z),Vector3(2.6 if long_table else 0.85,0.78,0.9 if long_table else 0.85),dark)
	contact.visible = false;contact.set_meta("mersea_role","support")
	cyl(p,Vector3(x,0.89,z),0.055,0.15,mat("316f71"))

static func umbrella(p: Node3D, x: float, z: float, c: String) -> void:
	var wood = mat("99714c")
	cyl(p,Vector3(x,1.4,z),0.032,2.8,wood)
	cyl(p,Vector3(x,0.08,z),0.3,0.12,mat("414442"))
	var canopy = cyl(p,Vector3(x,2.65,z),1.6,0.43,mat(c),0.07)
	canopy.mesh.radial_segments = 8
	for i in range(8):
		var a = i*PI/4
		rod(p,Vector3(x,2.86,z),Vector3(x+cos(a)*1.55,2.44,z+sin(a)*1.55),0.013,wood)

static func plant(p: Node3D, pos: Vector3, s: float, rng: RandomNumberGenerator) -> void:
	var greens = [mat("687449"),mat("829165"),mat("4f6250"),mat("927748")]
	for i in range(7):
		var a = i*TAU/7.0
		var n = box(p,pos+Vector3(cos(a)*s*0.20,s*0.28,sin(a)*s*0.20),Vector3(s*0.14,s*0.6,s*0.08),greens[rng.randi_range(0,3)])
		n.rotation = Vector3(sin(a)*0.7,a,cos(a)*0.7)

static func fence(p: Node3D, a: Vector3, b: Vector3) -> void:
	var dark = mat("424c4b",0.6)
	var count = int(a.distance_to(b)/0.21)
	for i in range(count+1):
		var pt = a.lerp(b,float(i)/count)
		box(p,pt+Vector3(0,0.68,0),Vector3(0.025,1.36,0.025),dark)
	for h in [0.22,1.13]:
		rod(p,a+Vector3(0,h,0),b+Vector3(0,h,0),0.025,dark)

# Frozen OSM perimeter vertices, in source order; no bounding-box substitute.
const POI := "n8017457805"
const SOURCES := ["w1308007114","w1308007113","w1308007112","w1098437841"]
const POLYGONS := {
"w1308007114":[[-419.318,133.689],[-412.293,130.160],[-410.719,133.288],[-408.010,131.930],[-406.955,134.012],[-401.521,131.285],[-400.404,133.511],[-411.132,138.910],[-405.592,149.920],[-410.033,152.157]],
"w1308007113":[[-394.610,145.968],[-392.112,150.354],[-402.778,156.432],[-405.276,152.057]],
"w1308007112":[[-389.228,145.745],[-390.433,143.541],[-385.069,140.613],[-383.864,142.806]],
"w1098437841":[[-397.590,122.045],[-393.317,119.652],[-390.406,124.873],[-394.671,127.255]]}
const BASES := {"w1308007114":3.140,"w1308007113":2.882,"w1308007112":2.982,"w1098437841":3.202}
const HEIGHT := 2.9
const SITE_ORIGIN := Vector3(-403.7,0,137.0)
const SITE_YAW := 2.034444

static func edge_frame(a: Vector2,b: Vector2,base: float) -> Transform3D:
	var t := Vector3(b.x-a.x,0,b.y-a.y).normalized()
	return Transform3D(Basis(-t,Vector3.UP,Vector3(t.z,0,-t.x)),Vector3((a.x+b.x)/2,base,(a.y+b.y)/2))

static func glazing(p: Node3D,x: float,w: float,open_bay: bool=false, sliding: bool=false, optical_pilot: bool=false, sectional_depth: bool=false) -> void:
	var frame := mat("bfc4b7",0.0,0.38)
	if optical_pilot: frame = mat("bac1bd",0.85,0.24)
	# One consistent clear dielectric envelope; actual opposing exterior is visible.
	# Perimeter depth replaces opaque fake infill. No furnished interior is authored.
	var optical:=Shader.new()
	optical.code="""shader_type spatial;
render_mode blend_premul_alpha, depth_draw_never, cull_back, fog_disabled;
void fragment() {
	float facing=clamp(dot(normalize(NORMAL),normalize(VIEW)),0.0,1.0);
	vec2 pane_uv=fract(UV*vec2(3.0,2.0));
	vec2 border=min(pane_uv,vec2(1.0)-pane_uv);
	float edge=1.0-smoothstep(0.002,0.028,min(border.x,border.y));
	float deposits=edge*(0.65+0.35*sin(pane_uv.x*119.0)*sin(pane_uv.y*83.0));
	ALBEDO=mix(vec3(0.008,0.017,0.016),vec3(0.075,0.087,0.079),deposits);
	METALLIC=0.0;ROUGHNESS=mix(0.055,0.42,deposits);SPECULAR=0.8;
	float fresnel=0.12+0.88*pow(1.0-facing,5.0);
	ALPHA=mix(fresnel,0.48,deposits);PREMUL_ALPHA_FACTOR=1.0;
}
"""
	var custom_glass := ShaderMaterial.new()
	custom_glass.shader=optical
	var glass: Material = custom_glass
	if optical_pilot:
		# Native PBR glass variant: restrained tint over actual shaded exterior depth.
		# Reuses family geometry; parameters are game-art inference, not measured glass.
		var native_glass := StandardMaterial3D.new()
		native_glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		native_glass.albedo_color = Color(0.19,0.26,0.24,0.42)
		native_glass.metallic = 0.0
		native_glass.metallic_specular = 0.65
		native_glass.roughness = 0.08
		native_glass.cull_mode = BaseMaterial3D.CULL_BACK
		native_glass.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_OPAQUE_ONLY
		native_glass.refraction_enabled = false
		native_glass.refraction_scale = 0.005
		glass = native_glass
	var surround:=Node3D.new();surround.name="ExteriorGlazingReturns";surround.set_meta("mersea_role","wall" if optical_pilot else "decor");p.add_child(surround)
	var lining:=mat("7f8983",0.0,0.83)
	var lining_z:float=-0.19 if optical_pilot else -0.38
	var lining_depth:float=0.16 if optical_pilot else 0.54
	# Shallow folded-metal jamb/head/sill construction, production-inference depth.
	for xx in [x-w/2+0.055,x+w/2-0.055]:
		box(surround,Vector3(xx,1.19,lining_z),Vector3(0.08,2.02,lining_depth),lining)
	for yy in [0.20,2.18]:box(surround,Vector3(x,yy,lining_z),Vector3(w-0.06,0.055,lining_depth),lining)
	if sectional_depth:
		# Exterior-facing shallow receiver cavity, not a modeled room. Its sloping
		# returns give an observable depth gradient without a sheet at the glass.
		# Inferred construction/occlusion spans0.18–0.90m behind the facade.
		var cavity:=Node3D.new();cavity.name="ShallowGlazingReceiver";cavity.set_meta("mersea_role","decor");p.add_child(cavity)
		var back:=mat("46534d",0.0,0.94)
		# Partial edge occlusion leaves the upper/central exterior through-view open.
		# Low rear lip masks the sunlit floor band without a full opaque infill.
		box(cavity,Vector3(x,0.61,-0.895),Vector3(w-0.40,0.28,0.035),back)
		for side in [-1,1]:
			box(cavity,Vector3(x+side*(w/2-0.36),1.365,-0.895),Vector3(0.32,1.27,0.035),back)
		var sill:=box(cavity,Vector3(x,0.335,-0.535),Vector3(w-0.12,0.025,0.77),mat("6c7467",0.0,0.89))
		sill.rotation.x=atan2(0.27,0.71)
		var head:=box(cavity,Vector3(x,2.07,-0.535),Vector3(w-0.12,0.025,0.75),mat("818a7d",0.0,0.88))
		head.rotation.x=-atan2(0.22,0.71)
		for side in [-1,1]:
			var jamb:=box(cavity,Vector3(x+side*(w/2-0.135),1.19,-0.535),Vector3(0.025,1.98,0.75),mat("738073",0.0,0.86))
			jamb.rotation.y=side*atan2(0.17,0.71)
	# Black rubber seals sit behind existing front frames, leaving the clear spans.
	var seal:=mat("263431",0.0,0.86)
	for xx in [x-w/2+0.052,x+w/2-0.052]:
		box(surround,Vector3(xx,1.19,-0.10),Vector3(0.023,2.02,0.018),seal)
	for yy in [0.205,2.175]:box(surround,Vector3(x,yy,-0.10),Vector3(w-0.07,0.022,0.018),seal)
	# Recessed panes and deep perimeter reveal; no furniture/interior scene.
	if optical_pilot:
		# Nested aluminium sliding channels over a dark recessed structural track.
		# All exposed opaque members remain source-wall receivers, not decor covers.
		var track:=mat("46524f",0.7,0.32)
		for xx in [x-w/2,x+w/2]:
			box(p,Vector3(xx,1.17,-0.105),Vector3(0.060,2.12,0.16),track)
			box(p,Vector3(xx,1.17,-0.020),Vector3(0.030,2.12,0.030),frame)
		box(p,Vector3(x,0.14,-0.10),Vector3(w,0.12,0.22),track)
		box(p,Vector3(x,2.23,-0.10),Vector3(w+0.10,0.14,0.18),track)
		# Front lips overlap their structural channel, leaving a visible dark groove.
		for yy in [0.195,2.175]:
			box(p,Vector3(x,yy,-0.015),Vector3(w+0.02,0.030,0.065),frame)
		box(p,Vector3(x,2.32,0.025),Vector3(w+0.18,0.044,0.30),track)
	else:
		for xx in [x-w/2,x+w/2]:
			box(p,Vector3(xx,1.17,-0.075),Vector3(0.065,2.12,0.22),frame)
		box(p,Vector3(x,0.14,-0.07),Vector3(w,0.12,0.28),frame)
		box(p,Vector3(x,2.23,-0.07),Vector3(w+0.10,0.14,0.24),frame)
		box(p,Vector3(x,2.32,0.025),Vector3(w+0.18,0.044,0.30),frame)
	if open_bay:
		# Observed raised sectional panel, folded under the head on its tracks.
		var raised := box(p,Vector3(x,2.24,-1.27),Vector3(w-0.12,0.025,2.32),glass)
		raised.set_meta("mersea_role","glass")
		for xx in [x-w/2+0.08,x+w/2-0.08]:
			box(p,Vector3(xx,2.23,-1.27),Vector3(0.045,0.08,2.44),frame)
		for z in [-0.11,-0.69,-1.27,-1.85,-2.43]:
			box(p,Vector3(x,2.24,z),Vector3(w-0.12,0.075,0.075),frame)
		box(p,Vector3(x,2.24,-1.27),Vector3(0.065,0.075,2.32),frame)
	elif sliding:
		for column in range(2):
			var pane := box(p,Vector3(x+(column-0.5)*w/2,1.19,-0.135-column*0.045),Vector3(w/2-0.055,2.00,0.022),glass)
			pane.set_meta("mersea_role","glass")
		if optical_pilot:
			box(p,Vector3(x,1.19,-0.105),Vector3(0.060,2.08,0.14),mat("46524f",0.7,0.32))
			box(p,Vector3(x,1.19,-0.030),Vector3(0.024,2.08,0.025),frame)
		else:
			box(p,Vector3(x,1.19,-0.085),Vector3(0.046,2.08,0.14),frame)
		for xx in [x-0.11,x+0.11]:rod(p,Vector3(xx,0.94,0.005),Vector3(xx,1.42,0.005),0.012,mat("64736c",0.85,0.24))
		# Visible white edge drapes in G_owner_008; shallow exterior-view treatment.
		var cloth: Material=mat("b6bbb0",0.0,0.98)
		if sliding:
			# Approximate crease self-occlusion from actual35mm folded geometry depth.
			# AO affects ambient only; albedo stays uniformly pale, no painted lighting.
			var weave:=Shader.new()
			weave.code="""shader_type spatial;
varying float fold_depth;
void vertex() { fold_depth = VERTEX.z; }
void fragment() {
	ALBEDO = vec3(0.855, 0.855, 0.730);
	ROUGHNESS = 0.98;
	SPECULAR = 0.2;
	AO = mix(0.42, 1.0, smoothstep(-0.325, -0.29, fold_depth));
	AO_LIGHT_AFFECT = 0.0;
}
"""
			var folded_cloth:=ShaderMaterial.new();folded_cloth.shader=weave;cloth=folded_cloth
		for side in [-1,1]:
			var curtain:=SurfaceTool.new();curtain.begin(Mesh.PRIMITIVE_TRIANGLES)
			for fold in range(18 if optical_pilot else 12):
				var cx:float=x+side*(w/2-0.10)-side*fold*0.032
				var next:float=cx-side*0.032
				var depth:float=-0.29-(0.035 if fold%2 else 0.0)
				if optical_pilot:depth-=0.018*sin(float(fold)*0.8+x)
				var next_depth:float=-0.29-(0.035 if (fold+1)%2 else 0.0)
				if optical_pilot:next_depth-=0.018*sin(float(fold+1)*0.8+x)
				var heights: Array=[0.22,0.92+side*0.10+sin(x)*0.045,2.20]
				if optical_pilot:
					heights=[]
					for h in range(13): heights.append(lerpf(0.22,2.20,float(h)/12.0))
				for section in range(heights.size()-1):
					var lower:float=heights[section];var upper:float=heights[section+1]
					var anchor:float=x+side*(w/2-0.10)
					var lower_width:float=(0.38 if section==1 else 0.82) if sliding else 1.0
					var upper_width:float=(0.38 if section==0 else 1.40) if sliding else 1.0
					if optical_pilot:
						var tie:float=0.95+side*0.10+sin(x)*0.06
						lower_width=(0.98+0.18*(lower-0.22)/1.98-0.70*exp(-pow((lower-tie)/0.38,2.0)))*(1.0+0.10*sin(x+side))
						upper_width=(0.98+0.18*(upper-0.22)/1.98-0.70*exp(-pow((upper-tie)/0.38,2.0)))*(1.0+0.10*sin(x+side))
					var a:=Vector3(lerpf(anchor,cx,lower_width),lower,depth);var b:=Vector3(lerpf(anchor,next,lower_width),lower,next_depth)
					var c:=Vector3(lerpf(anchor,next,upper_width),upper,next_depth);var d:=Vector3(lerpf(anchor,cx,upper_width),upper,depth)
					for v in [a,d,c,a,c,b] if side<0 else [a,c,d,a,b,c]:curtain.add_vertex(v)
			curtain.generate_normals();var drape:=MeshInstance3D.new();drape.mesh=curtain.commit();drape.material_override=cloth;drape.set_meta("mersea_role","decor");p.add_child(drape)
	else:
		for row in range(4):
			for column in range(2):
				var pane := box(p,Vector3(x+(column-0.5)*w/2,0.17+(row+0.5)*2.03/4,-0.135),Vector3(w/2-0.09,0.445,0.025),glass)
				pane.set_meta("mersea_role","glass")
		for y in [0.68,1.19,1.70]:
			box(p,Vector3(x,y,-0.10),Vector3(w,0.038,0.08),frame)
		box(p,Vector3(x,1.17,-0.10),Vector3(0.038,2.03,0.08),frame)

static func polygon_surface(p: Node3D,points: PackedVector2Array,y: float,m: Material,role: String) -> MeshInstance3D:
	var v := PackedVector3Array()
	var n := PackedVector3Array()
	var uv := PackedVector2Array()
	for q in points:
		v.append(Vector3(q.x,y,q.y));n.append(Vector3.UP);uv.append(q)
	var indices := Geometry2D.triangulate_polygon(points)
	var arrays := [];arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX]=v;arrays[Mesh.ARRAY_NORMAL]=n;arrays[Mesh.ARRAY_TEX_UV]=uv;arrays[Mesh.ARRAY_INDEX]=indices
	var raw := ArrayMesh.new();raw.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var tool := SurfaceTool.new();tool.create_from(raw,0);tool.generate_tangents();var mesh := tool.commit()
	var node := MeshInstance3D.new();node.mesh=mesh;node.material_override=m
	node.set_meta("mersea_role",role);p.add_child(node)
	return node

static func building(source: String,wall_record: Dictionary,mural_asset_path: String) -> Node3D:
	var p := Node3D.new();p.name="Mersea_"+source
	p.set_meta("source_keys",[source]);p.set_meta("mersea_role","wall")
	p.set_meta("derived_object_key","building:"+source+":wall")
	var origin: Array=POLYGONS[source][0]
	p.position=Vector3(origin[0],float(wall_record.flat_base_elevation_m),origin[1])
	var points := PackedVector2Array()
	for q: Array in POLYGONS[source]:points.append(Vector2(q[0]-origin[0],q[1]-origin[1]))
	var roofmat := granular("b8bbb2","d7d8ce",1.0)
	var underside := mat("626b62" if source=="w1308007114" else "c6c8bc",0.0,0.88)
	underside.cull_mode=BaseMaterial3D.CULL_DISABLED
	polygon_surface(p,points,HEIGHT,roofmat,"roof")
	polygon_surface(p,points,HEIGHT-0.10,underside,"roof")
	polygon_surface(p,points,0.10,mat("555c50" if source=="w1308007114" else "bdb4a0",0.0,0.94 if source=="w1308007114" else 0.7),"support")
	var steel := granular("4d5c46","5b6951",2.0)
	steel.roughness=0.60
	var rib := mat("69755e",0.0,0.66)
	var rail := mat("505e48",0.0,0.62)
	for i in points.size():
		var a := points[i];var b := points[(i+1)%points.size()]
		var length := a.distance_to(b)
		var g := Node3D.new();g.name="Edge_%d"%i;g.transform=edge_frame(a,b,0);p.add_child(g)
		var openings: Array=[]
		if source=="w1308007114" and i==7:openings=[Vector2(-3.95,3.65),Vector2(0,3.65),Vector2(3.95,3.65)]
		if source=="w1308007113" and i==3:openings=[Vector2(3.3,4.2)]
		if source=="w1308007114" and i==0:openings=[Vector2(0,4.8)]
		if source=="w1308007114" and i==6:openings=[Vector2(-3.6,1.60),Vector2(-1.4,1.6),Vector2(1.6,1.15)]
		if source=="w1308007113" and i==0:openings=[Vector2(0,length-0.38)]
		if source=="w1308007112" and i==1:openings=[Vector2(-1.25,1.06),Vector2(1.10,1.12)]
		# Photo-supported daylight through the rear pavilion; inferred bay alignment
		# follows the frozen opposite perimeter, with no furnished interior.
		if source=="w1308007114" and i==9:openings=[Vector2(2.068948,3.55),Vector2(6.268947,3.55)]
		# Opposite glazing completes an exterior glass room, without invented interior.
		if source=="w1308007113" and i==1:openings=[Vector2(-2.10,3.55),Vector2(2.10,3.55)]
		# Split at exact opening boundaries, so the corrugation never leaves ragged gaps.
		var cuts: Array[float]=[-length/2,length/2]
		for op: Vector2 in openings:
			cuts.append(op.x-op.y/2)
			cuts.append(op.x+op.y/2)
		cuts.sort()
		for j in range(cuts.size()-1):
			var middle: float=(cuts[j]+cuts[j+1])*0.5
			var hole := false
			for op: Vector2 in openings:
				if absf(middle-op.x)<op.y/2:hole=true
			var panel_bottom:float=2.34 if hole else 0.10
			if hole and source=="w1308007114" and i==0:panel_bottom=2.79
			if hole and source=="w1308007112" and i==1:panel_bottom=2.23 if middle<0 else 2.18
			if panel_bottom<2.79:corrugated_panel(g,cuts[j],cuts[j+1],panel_bottom,2.79,steel)
		for y in [0.16,2.82]:box(g,Vector3(0,y,-0.02),Vector3(length,0.14,0.16),rail)
		for x in [-length/2+0.08,length/2-0.08]:
			box(g,Vector3(x,1.47,-0.05),Vector3(0.16,2.85,0.18),rail)
			for y in [0.16,2.82]:
				box(g,Vector3(x,y,0),Vector3(0.22,0.21,0.20),rib)
				box(g,Vector3(x,y,0.106),Vector3(0.08,0.085,0.014),mat("394442"))
		for op: Vector2 in openings:
			# One raised rear courtyard bay as observed in the later patio photo.
			# Its adjacent closed bay retains the exact glazing-contact test plane.
			var raised_bay: bool = source=="w1308007114" and i==7 and op.x>0.0
			if source=="w1308007112" and i==1:landward_opening(g,op.x,op.y,op.x<0,steel)
			elif source=="w1308007114" and i==0:gold_service(g,op.x,op.y)
			else:glazing(g,op.x,op.y,false if source=="w1308007114" and i==7 else raised_bay,(source=="w1308007113" and i==0) or (source=="w1308007114" and i in [7,9]),source=="w1308007114" and i==7,source=="w1308007113" and i==3)
		if source=="w1308007114" and i==6:
			box(g,Vector3(-1.7,0.93,0.30),Vector3(5.5,0.10,0.65),mat("bdc0b7",0.65,0.30))
			box(g,Vector3(4.3,1.75,0.10),Vector3(1.7,1.0,0.09),mat("384440"))
			text_sign(g,"MERSEA",Vector3(4.3,1.95,0.16),24,Color("e5dfca"))
			text_sign(g,"KITCHEN / BAR",Vector3(4.3,1.64,0.16),14,Color("e5dfca"))
		if source=="w1308007113" and i==3:
			var paint := Node3D.new()
			paint.position.x=-2.7
			g.add_child(paint)
			mural(paint,6.2,mural_asset_path)
		if source=="w1098437841" and i==3:
			for x in [-1.45,1.45]:restroom_door(g,x)
		# Thin cap, drain line and container weld plates give the roof a legible edge.
		box(g,Vector3(0,2.94,-0.03),Vector3(length+0.06,0.065,0.23),mat("afb3a3",0.0,0.59))
		for x in [-length/2+0.25,length/2-0.25]:
			box(g,Vector3(x,2.80,0.072),Vector3(0.045,0.05,0.022),mat("b2b6ac",0.8,0.35))
	# Low foundation apron connects the retained source base to actual terrain.
	var wall_vertices: Array=wall_record.vertices
	var minimum := float(wall_record.flat_base_elevation_m)
	for j in range(1,wall_vertices.size(),3):minimum=minf(minimum,float(wall_vertices[j]))
	for i in points.size():
		var a := points[i];var b := points[(i+1)%points.size()]
		var g := Node3D.new();g.transform=edge_frame(a,b,0);g.set_meta("mersea_role","support");p.add_child(g)
		var depth := maxf(0.12,p.position.y-minimum+0.10)
		box(g,Vector3(0,-depth/2+0.10,-0.09),Vector3(a.distance_to(b),depth,0.16),mat("aaa796"))
	return p

static func mural(g: Node3D,length: float,mural_asset_path: String) -> void:
	# Private prototype: finite source-inspired paint, projected onto existing ribs.
	# Imported texture supports both source runs and later ordinary exports.
	var texture := load(mural_asset_path) as Texture2D
	var decal := Decal.new()
	decal.name="MerseaMuralPaint"
	decal.texture_albedo=texture
	var width: float=length-0.40
	decal.size=Vector3(width,0.16,width*827.0/1902.0)
	# Rotate the image plane 180 degrees; retain +Y outward / -Y projection inward.
	decal.transform=Transform3D(Basis(Vector3.RIGHT,Vector3.BACK,Vector3.DOWN),Vector3(0,1.47,0.035))
	decal.cull_mask=2
	decal.normal_fade=0.15
	decal.upper_fade=0.02
	decal.lower_fade=0.02
	decal.set_meta("mersea_role","decor")
	g.add_child(decal)

static func terrain_y(land: Dictionary,x: float,z: float) -> float:
	var v: Array=land.vertices;var ix: Array=land.indices
	for i in range(0,ix.size(),3):
		var a:=Vector3(v[ix[i]*3],v[ix[i]*3+1],v[ix[i]*3+2])
		var b:=Vector3(v[ix[i+1]*3],v[ix[i+1]*3+1],v[ix[i+1]*3+2])
		var c:=Vector3(v[ix[i+2]*3],v[ix[i+2]*3+1],v[ix[i+2]*3+2])
		var den: float=(b.z-c.z)*(a.x-c.x)+(c.x-b.x)*(a.z-c.z)
		if absf(den)<0.0000001:continue
		var u: float=((b.z-c.z)*(x-c.x)+(c.x-b.x)*(z-c.z))/den
		var w: float=((c.z-a.z)*(x-c.x)+(a.x-c.x)*(z-c.z))/den
		if minf(u,minf(w,1-u-w))>=-0.00001:return u*a.y+w*b.y+(1-u-w)*c.y
	return NAN

static func site_point(x: float,z: float) -> Vector3:
	return SITE_ORIGIN+Basis(Vector3.UP,SITE_YAW)*Vector3(x,0,z)

static func skin(p: Node3D,land: Dictionary,polygon: PackedVector2Array,m: Material,bias: float) -> void:
	# Clip actual terrain triangles; visual skin has no competing land collider.
	var v: Array=land.vertices;var ix: Array=land.indices
	var verts:=PackedVector3Array();var normals:=PackedVector3Array();var uvs:=PackedVector2Array()
	for i in range(0,ix.size(),3):
		var tri:=PackedVector2Array()
		for j in range(3):tri.append(Vector2(v[ix[i+j]*3],v[ix[i+j]*3+2]))
		for piece: PackedVector2Array in Geometry2D.intersect_polygons(polygon,tri):
			var ids:=Geometry2D.triangulate_polygon(piece)
			for k in ids:
				var q:=piece[k];verts.append(Vector3(q.x,terrain_y(land,q.x,q.y)+0.055+bias,q.y));normals.append(Vector3.UP);uvs.append(q)
	if verts.is_empty():return
	var arrays:=[];arrays.resize(Mesh.ARRAY_MAX);arrays[Mesh.ARRAY_VERTEX]=verts;arrays[Mesh.ARRAY_NORMAL]=normals;arrays[Mesh.ARRAY_TEX_UV]=uvs
	var raw:=ArrayMesh.new();raw.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var tool:=SurfaceTool.new();tool.create_from(raw,0);tool.generate_tangents();var mesh:=tool.commit()
	var node:=MeshInstance3D.new();node.mesh=mesh;node.material_override=m;node.set_meta("mersea_role","decor");p.add_child(node)

static func rectangle(x: float,z: float,w: float,d: float) -> PackedVector2Array:
	var points:=PackedVector2Array()
	for q in [Vector2(x-w/2,z-d/2),Vector2(x+w/2,z-d/2),Vector2(x+w/2,z+d/2),Vector2(x-w/2,z+d/2)]:
		var pt:=site_point(q.x,q.y);points.append(Vector2(pt.x,pt.z))
	return points

static func ground_material(a: String,b: String,frequency: float) -> StandardMaterial3D:
	var m:=granular(a,b,1.0).duplicate()
	# World-metre UVs; 512 texels per metre gives visible fine aggregate, no macro blotches.
	m.uv1_triplanar=false;m.albedo_color=Color.WHITE
	var tex: NoiseTexture2D=m.albedo_texture;tex.noise.frequency=frequency*0.60
	m.normal_scale=0.85 if frequency>0.5 else 0.14
	m.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	m.roughness=0.95
	return m

static func site(land: Dictionary) -> Node3D:
	var p:=Node3D.new();p.name="MerseaSite_"+POI
	p.set_meta("source_keys",[POI]);p.set_meta("derived_object_key","site:"+POI);p.set_meta("mersea_role","decor")
	var sand:=ground_material("8e795c","b29a77",0.72)
	# Original generated aggregate albedo, inferred0.9m tile; fine independent
	# normal is sub-grain surface finish, not a measured per-stone height map.
	sand.albedo_texture=load("res://game/resources/mersea/gravel_albedo.png") as Texture2D
	sand.uv1_scale=Vector3.ONE/0.9;sand.normal_scale=0.18
	sand.roughness_texture=null;sand.roughness=0.96
	var concrete:=ground_material("999c92","a6a99f",0.08)
	var gravel:=ground_material("6e746b","96988b",0.9)
	skin(p,land,rectangle(-4.8,1.8,17.8,26.0),sand,0.015)
	skin(p,land,rectangle(-4.5,-6.6,17.7,1.5),concrete,0.020)
	skin(p,land,rectangle(0.5,3.0,2.2,22.0),concrete,0.020)
	skin(p,land,rectangle(-10.1,-0.8,1.5,13.2),concrete,0.020)
	skin(p,land,rectangle(-1,-6.13,21.0,0.18),gravel,0.024)
	for zz in range(-7,15,2):skin(p,land,rectangle(0.5,float(zz),2.18,0.013),mat("62685e",0.0,0.95),0.022)
	# Bounded side branch reaches the two restroom doors; visible overlay only.
	var restroom_a:=Vector2(-394.671,127.255);var restroom_b:=Vector2(-397.590,122.045)
	var front:=edge_frame(restroom_a,restroom_b,0.0)
	var apron:=PackedVector2Array()
	for q in [Vector3(-3.0,0,0.05),Vector3(3.0,0,0.05),Vector3(3.0,0,1.55),Vector3(-3.0,0,1.55)]:
		var pt:Vector3=front*q;apron.append(Vector2(pt.x,pt.z))
	skin(p,land,apron,concrete,0.021)
	# Short branch joins the visible apron to the continuous circulation spine.
	skin(p,land,rectangle(4.0,11.30,6.1,1.40),concrete,0.022)
	for xx in [2.0,4.0,6.0]:skin(p,land,rectangle(xx,11.30,0.013,1.38),mat("62685e",0.0,0.95),0.024)
	var rng:=RandomNumberGenerator.new();rng.seed=93
	var furniture:=Node3D.new();furniture.name="CourtyardFurniture";p.add_child(furniture)
	for q in [Vector3(-7.9,-1.6,1),Vector3(-7.9,2.0,1),Vector3(-1.95,-1.6,1),Vector3(-1.95,2.0,1),Vector3(-5.0,-4.8,0),Vector3(-8.7,5.2,0),Vector3(-2.1,5.0,0)]:
		var group:=Node3D.new();var pt:=site_point(q.x,q.y);pt.y=terrain_y(land,pt.x,pt.z)+0.074;group.position=pt;group.rotation.y=SITE_YAW;furniture.add_child(group)
		table(group,0,0,q.z>0.5)
	var planter:=Node3D.new();var pp:=site_point(-4.8,0.2);pp.y=terrain_y(land,pp.x,pp.z)+0.075;planter.position=pp;planter.rotation.y=SITE_YAW+PI/2;planter.set_meta("mersea_role","support");p.add_child(planter)
	box(planter,Vector3(0,0.32,0),Vector3(3.5,0.62,1.4),mat("719997"))
	box(planter,Vector3(0,0.65,0),Vector3(3.65,0.10,1.55),mat("8a644b"))
	var greens:=Node3D.new();greens.set_meta("mersea_role","decor");planter.add_child(greens)
	for i in range(25):plant(greens,Vector3(rng.randf_range(-1.55,1.55),0.72,rng.randf_range(-0.5,0.5)),rng.randf_range(0.30,0.60),rng)
	# Satellite diagonal lane pair; angle/compact dimensions are production inference.
	var lane_basis:=Basis(Vector3.UP,SITE_YAW+deg_to_rad(50.0))
	var lane_center:=site_point(-5.9,11.2)
	for offset in [-1.4,1.4]:
		var corners: Array[Vector3]=[]
		var lane_polygon:=PackedVector2Array()
		for q in [Vector3(-4.35,0,offset-1.25),Vector3(4.35,0,offset-1.25),Vector3(4.35,0,offset+1.25),Vector3(-4.35,0,offset+1.25)]:
			var pt:Vector3=lane_center+lane_basis*q
			pt.y=terrain_y(land,pt.x,pt.z)+0.17
			corners.append(pt);lane_polygon.append(Vector2(pt.x,pt.z))
		skin(p,land,lane_polygon,sand,0.028)
		for i in range(4):
			var a:Vector3=corners[i];var b:Vector3=corners[(i+1)%4]
			var rail:=box(p,(a+b)/2,Vector3(0.10,0.28,a.distance_to(b)),mat("8a684c"))
			var along:Vector3=(b-a).normalized();var across:=Vector3.UP.cross(along).normalized()
			rail.basis=Basis(across,along.cross(across).normalized(),along)
	var turf:=ground_material("58734e","7e955f",0.60)
	var surround_turf:=ground_material("304b32","486344",0.60)
	# Satellite regional composition; exact contours/anchors are production inference.
	# The parking-side green patch is observed, but its golf-hole function is unknown.
	var surround:=PackedVector2Array()
	for q in [Vector2(9,-2.8),Vector2(12,-3.0),Vector2(14,-1.7),Vector2(14.6,2),Vector2(16,4),Vector2(16.3,8),Vector2(14.8,11.2),Vector2(11.3,11.4),Vector2(8.6,9.4),Vector2(8.2,5.5),Vector2(9,2.4),Vector2(8.7,0)]:
		var pt:=site_point(q.x,q.y);surround.append(Vector2(pt.x,pt.z))
	skin(p,land,surround,surround_turf,0.025)
	for lobe in [Vector4(12.0,7.0,3.3,3.0),Vector4(11.0,-0.5,1.45,1.75),Vector4(2.8,17.5,1.1,1.45)]:
		var green:=PackedVector2Array()
		for i in range(48):
			var angle:=TAU*float(i)/48.0
			var softness:=1.0+0.06*cos(angle*3.0)
			var local:=Vector2(lobe.x+cos(angle)*lobe.z*softness,lobe.y+sin(angle)*lobe.w*softness)
			if lobe.z>3.0:
				# Broad road-facing crown (+X), tapered court-facing end and western inflection.
				var inflection:=exp(-pow((angle-4.05)/0.45,2.0))
				local=Vector2(lobe.x+3.0*cos(angle)+0.35*cos(2.0*angle)+0.30*inflection,lobe.y+3.05*sin(angle)*(0.72+0.28*cos(angle))+0.30*inflection)
			var pt:=site_point(local.x,local.y)
			green.append(Vector2(pt.x,pt.z))
		skin(p,land,green,turf,0.029)
	# A restrained winding neutral separator follows the western pocket and main green.
	var neutral:=PackedVector2Array()
	for q in [Vector2(9,1.6),Vector2(11,1.8),Vector2(13.1,2.8),Vector2(14.3,3.6),Vector2(14.7,3.1),Vector2(13.5,2.2),Vector2(11.2,1.2),Vector2(9,1.0)]:
		var pt:=site_point(q.x,q.y);neutral.append(Vector2(pt.x,pt.z))
	skin(p,land,neutral,sand,0.033)
	for q in [Vector2(11,-0.5),Vector2(12,7)]:
		var pt:=site_point(q.x,q.y);pt.y=terrain_y(land,pt.x,pt.z)
		cyl(p,pt+Vector3(0,0.60,0),0.012,1.15,mat("dfdfd0"));box(p,pt+Vector3(0.13,1.08,0),Vector3(0.26,0.18,0.012),mat("dfdfd0"))
	var reflection:=ReflectionProbe.new();reflection.name="MerseaExteriorReflection"
	reflection.position=Vector3(-408.0,5.0,140.0);reflection.size=Vector3(30,10,30)
	reflection.max_distance=30.0;reflection.box_projection=false;reflection.intensity=1.0
	# Local glass/tagged-metal reflection only; preserve capture and source/spray masks.
	reflection.update_mode=ReflectionProbe.UPDATE_ALWAYS
	reflection.ambient_mode=ReflectionProbe.AMBIENT_DISABLED
	reflection.cull_mask=3;reflection.reflection_mask=4
	reflection.enable_shadows=false;reflection.mesh_lod_threshold=4.0
	p.add_child(reflection)
	# Bar-only reflected context at the service facade, outside all opaque sheets.
	# Production-inference probe anchor; glass keeps its existing courtyard origin.
	var bar_reflection:=ReflectionProbe.new();bar_reflection.name="MerseaBarReflection"
	var bar_edge:=edge_frame(Vector2(-419.318,133.689),Vector2(-412.293,130.160),BASES.w1308007114)
	bar_reflection.position=bar_edge*Vector3(0,1.10,0.70)
	bar_reflection.size=Vector3(10,6,10);bar_reflection.max_distance=16.0
	bar_reflection.box_projection=false;bar_reflection.intensity=1.0
	bar_reflection.update_mode=ReflectionProbe.UPDATE_ALWAYS
	bar_reflection.ambient_mode=ReflectionProbe.AMBIENT_DISABLED
	bar_reflection.cull_mask=3;bar_reflection.reflection_mask=8
	bar_reflection.enable_shadows=false;bar_reflection.mesh_lod_threshold=4.0
	p.add_child(bar_reflection)
	string_lights(p,land)
	return p

static func build(records: Dictionary,land: Dictionary,mural_asset_path: String) -> Node3D:
	var p:=Node3D.new();p.name="MerseaAssembly"
	for source: String in SOURCES:p.add_child(building(source,records["building:"+source+":wall"],mural_asset_path))
	p.add_child(site(land))
	gold_platform(p.get_node("Mersea_w1308007114"),land)
	# Roof extractors belong to the actual kitchen's northern wing.
	var host:Node3D=p.get_node("Mersea_w1308007114")
	for pt in [Vector2(-414.0,133.3),Vector2(-403.1,133.2)]:
		var g:=Node3D.new();g.position=Vector3(pt.x,BASES.w1308007114+HEIGHT,pt.y)-host.position;g.set_meta("mersea_role","roof");host.add_child(g)
		box(g,Vector3(0,0.08,0),Vector3(1.0,0.16,1.0),mat("b9bdb5",0.7))
		cyl(g,Vector3(0,0.32,0),0.30,0.5,mat("b6bcb5",0.75,0.3));cyl(g,Vector3(0,0.62,0),0.51,0.32,mat("c8cbc2",0.7,0.3),0.44)
	p.ready.connect(_settle_bar_reflection.bind(p.get_node("MerseaSite_"+POI+"/MerseaBarReflection")),CONNECT_ONE_SHOT)
	return p


static func corrugated_panel(parent: Node3D,left: float,right: float,bottom: float,top: float,material: Material) -> void:
	# Trapezoidal pressed steel relief, 0.28m inferred cadence and 59mm peak-to-trough depth.
	# Back plate closes the solid wall; profile supplies physically shaded folds.
	box(parent,Vector3((left+right)/2,(bottom+top)/2,-0.058),Vector3(right-left,top-bottom,0.092),material)
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var x:=left
	while x<right-0.00001:
		var next:=minf(right,x+0.28)
		var span:=next-x
		var profile: Array[Vector2]=[Vector2(x,-0.004),Vector2(x+span*0.22,-0.004),Vector2(x+span*0.38,0.055),Vector2(x+span*0.72,0.055),Vector2(x+span*0.88,-0.004),Vector2(next,-0.004)]
		for j in range(profile.size()-1):
			var a:=Vector3(profile[j].x,bottom,profile[j].y)
			var b:=Vector3(profile[j+1].x,bottom,profile[j+1].y)
			var c:=Vector3(profile[j+1].x,top,profile[j+1].y)
			var d:=Vector3(profile[j].x,top,profile[j].y)
			var normal:=(b-a).cross(d-a).normalized()
			for v in [a,d,c,a,c,b]:
				surface.set_normal(normal)
				surface.set_uv(Vector2(v.x,v.y))
				surface.add_vertex(v)
		x=next
	surface.generate_tangents()
	var node:=MeshInstance3D.new()
	node.mesh=surface.commit()
	node.material_override=material
	parent.add_child(node)


# Shared Mersea box/frame/hardware grammar; landward variant omits restroom motifs.
# September2026 door/window organization observed; dimensions/anchors inferred.
static func landward_opening(g: Node3D,x: float,w: float,door: bool,steel: Material) -> void:
	var white:=mat("d1d4c5",0.0,0.40)
	if door:
		box(g,Vector3(x,1.165,-0.015),Vector3(w,2.13,0.13),mat("3e4d40",0.0,0.64))
		for xx in [x-w/2,x+w/2]:box(g,Vector3(xx,1.17,0.055),Vector3(0.075,2.15,0.13),mat("77816b",0.0,0.64))
		box(g,Vector3(x,2.25,0.12),Vector3(w+0.18,0.075,0.29),white)
		box(g,Vector3(x+0.35,1.08,0.075),Vector3(0.12,0.04,0.075),mat("b3b8ac",0.75,0.28))
	else:
		corrugated_panel(g,x-w/2,x+w/2,0.10,1.12,steel)
		var glazing_material:=mat("778888",0.0,0.09).duplicate()
		glazing_material.metallic_specular=1.0
		var pane:=box(g,Vector3(x,1.65,-0.055),Vector3(w,1.06,0.06),glazing_material)
		pane.set_meta("mersea_role","glass")
		for xx in [x-w/2,x,x+w/2]:box(g,Vector3(xx,1.65,0.02),Vector3(0.055,1.10,0.13),white)
		for yy in [1.10,2.20]:box(g,Vector3(x,yy,0.05),Vector3(w+0.12,0.07,0.19),white)

static func restroom_door(parent: Node3D,x: float) -> void:
	var green:=mat("637559",0.0,0.76)
	box(parent,Vector3(x,1.10,0.10),Vector3(1.04,2.13,0.13),mat("394639"))
	box(parent,Vector3(x,1.10,0.18),Vector3(0.91,2.03,0.07),green)
	for dx in [-0.52,0.52]:box(parent,Vector3(x+dx,1.10,0.19),Vector3(0.08,2.2,0.18),green)
	box(parent,Vector3(x,2.24,0.29),Vector3(1.16,0.075,0.40),mat("92937d"))
	for y in [0.60,1.25,1.75]:
		box(parent,Vector3(x-0.40,y,0.24),Vector3(0.08,0.12,0.045),mat("a4aba0",0.8,0.36))
	box(parent,Vector3(x+0.32,1.08,0.25),Vector3(0.045,0.18,0.09),mat("acb3a9",0.8,0.3))
	var wood:=granular("4c493b","6b6652",3.0)
	for i in range(7):box(parent,Vector3(x-0.235+i*0.078,1.27,0.241),Vector3(0.060,1.36,0.045),wood)
	for y in [0.68,1.25,1.85]:box(parent,Vector3(x,y,0.270),Vector3(0.60,0.075,0.035),wood)
	var tri:=SurfaceTool.new();tri.begin(Mesh.PRIMITIVE_TRIANGLES)
	for q in [Vector3(x-0.12,1.69,0.296),Vector3(x,1.94,0.296),Vector3(x+0.12,1.69,0.296)]:tri.add_vertex(q)
	tri.generate_normals();var sign:=MeshInstance3D.new();sign.mesh=tri.commit();sign.material_override=mat("ce9994",0.0,0.82);parent.add_child(sign)
	box(parent,Vector3(x+0.66,1.57,0.12),Vector3(0.16,0.23,0.05),mat("293b42"))
	text_sign(parent,"WC",Vector3(x+0.66,1.58,0.151),9,Color("e0e2d3"))
	var lamp:=cyl(parent,Vector3(x,2.49,0.13),0.085,0.13,mat("d0d5bf"))
	lamp.rotation.x=PI/2


static func string_lights(parent: Node3D,land: Dictionary) -> void:
	var cable:=mat("353b32",0.0,0.78)
	var bulb:=mat("e9d3a0",0.0,0.3).duplicate()
	bulb.emission_enabled=true
	bulb.emission=Color("e9c77d")
	bulb.emission_energy_multiplier=0.35
	for z in [-5.8,0.0,5.5,11.0]:
		var a:=site_point(-11.2,z)
		var b:=site_point(3.0,z)
		a.y=terrain_y(land,a.x,a.z)+3.85
		b.y=terrain_y(land,b.x,b.z)+3.85
		for anchor in [a,b]:
			var foot:=Vector3(anchor.x,terrain_y(land,anchor.x,anchor.z),anchor.z)
			rod(parent,foot,anchor,0.04,cable)
		var last:=a
		for i in range(1,25):
			var t:=float(i)/24
			var point:=a.lerp(b,t)-Vector3.UP*(0.32*sin(t*PI))
			rod(parent,last,point,0.009,cable)
			if i%2==0 and i<24:
				rod(parent,point,point-Vector3.UP*0.12,0.012,cable)
				cyl(parent,point-Vector3.UP*0.12,0.021,0.045,cable)
				var lamp := MeshInstance3D.new();var sphere := SphereMesh.new()
				sphere.radius=0.028;sphere.height=0.065;sphere.radial_segments=8;sphere.rings=4
				lamp.mesh=sphere;lamp.material_override=bulb;lamp.position=point-Vector3.UP*0.164;parent.add_child(lamp)
			last=point


static func gold_service(g: Node3D,x: float,w: float) -> void:
	var trim := mat("74795b",0.0,0.66)
	# Opaque lower service panel, deep framed opening and counter, no interior.
	# S23 broad folded brass sheet and bright perimeter are one exterior assembly.
	# Production-inference satin finish; actual local reflections supply lighting.
	var brushed:=mat("b6a782",1.0,0.24).duplicate()
	brushed.anisotropy_enabled=true;brushed.anisotropy=0.65
	var edge_metal:=mat("e1ded3",1.0,0.10)
	var face:=box(g,Vector3(x,0.89,-0.035),Vector3(w,1.58,0.10),brushed)
	# Original color/non-color maps share one inferred4.8m by1.58m sheet.
	# BoxMesh front UV spans1/3 by1/2; native3x2 scaling covers one map.
	# The native roughness scalar multiplies map data; preserve satin, not mirror metal.
	var sheet: StandardMaterial3D = brushed.duplicate()
	sheet.albedo_color = Color.WHITE
	sheet.albedo_texture = load("res://game/resources/mersea/brass_albedo.png")
	sheet.roughness = 0.6
	sheet.roughness_texture = load("res://game/resources/mersea/brass_roughness.png")
	sheet.normal_enabled = true
	sheet.normal_texture = load("res://game/resources/mersea/brass_normal.png")
	sheet.normal_scale = 0.12
	sheet.uv1_scale = Vector3(3.0,2.0,1.0)
	sheet.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	face.material_override = sheet
	face.set_meta("mersea_reflective_metal",true)
	var folded:=Node3D.new();folded.name="FoldedServiceMetal";folded.set_meta("mersea_role","decor");g.add_child(folded)
	# S23 narrow inset sheet edge above a rounded projecting bottom rail.
	# Reuse the family cylinder grammar with smooth curved normals at this scale.
	beveled_metal_border(folded,Vector3(x,1.24,0.014),Vector2(w-0.10,0.72),0.035,0.047,edge_metal)
	var bottom_rail:=cyl(folded,Vector3(x,0.85,0.085),0.065,w-0.08,edge_metal)
	bottom_rail.rotation.z=PI/2
	(bottom_rail.mesh as CylinderMesh).radial_segments=32
	bottom_rail.set_meta("mersea_reflective_metal",true)
	# The shallow mounting strip intersects the rail rear and sheet, without floating ends.
	box(folded,Vector3(x,0.85,0.043),Vector3(w-0.07,0.075,0.060),brushed).set_meta("mersea_reflective_metal",true)
	# Fine physical vertical sheet join, not another container corrugation field.
	box(folded,Vector3(x,0.89,0.019),Vector3(0.008,1.35,0.020),mat("847b60",0.82,0.36)).set_meta("mersea_reflective_metal",true)
	for yy in [0.14,1.64]:
		var border:=box(g,Vector3(x,yy,0.052),Vector3(w,0.065,0.025),edge_metal)
		border.set_meta("mersea_reflective_metal",true)
	var counter_finish:=mat("d2d5ce",1.0,0.14)
	var counter:=box(g,Vector3(x,1.72,0.16),Vector3(w+0.22,0.09,0.57),counter_finish)
	counter.set_meta("mersea_reflective_metal",true)
	box(g,Vector3(x,2.20,-0.90),Vector3(w-0.10,0.94,0.035),mat("394238",0.0,0.88))
	# S23/S08 connected stepped portal, authored as legitimate source114 wall faces.
	# Dimensions are production inference; exposed structure receives spray/contact.
	var portal:=Node3D.new();portal.name="BarStructuralPortal";portal.set_meta("mersea_role","wall");g.add_child(portal)
	var olive:=trim
	var olive_return:=mat("80876b",0.0,0.64)
	for side in [-1,1]:
		# Full-height shoulder meets the existing platform and overlaps its inner lining.
		box(portal,Vector3(x+side*(w/2+0.025),1.81,0.09),Vector3(0.29,2.10,0.30),olive)
		box(portal,Vector3(x+side*(w/2-0.12),2.20,-0.065),Vector3(0.07,0.94,0.22),olive_return)
		var cheek:=box(portal,Vector3(x+side*(w/2-0.25),2.20,-0.50),Vector3(0.08,0.94,0.94),olive_return)
		cheek.rotation.y=side*atan2(0.42,0.78)
	# Continuous substantial head replaces disconnected shutter-like decorative strips.
	box(portal,Vector3(x,2.75,0.09),Vector3(w+0.34,0.20,0.30),olive)
	box(portal,Vector3(x,2.62,-0.48),Vector3(w-0.22,0.28,0.90),olive_return)
	var reveal:=Node3D.new();reveal.name="BarExteriorReturns";reveal.set_meta("mersea_role","decor");g.add_child(reveal)
	# The existing continuous counter surface and rounded nose remain exterior finish.
	box(reveal,Vector3(x,1.72,-0.48),Vector3(w-0.12,0.085,0.87),counter_finish).set_meta("mersea_reflective_metal",true)
	# One neutral-metal cap joins the exposed service ledge and shallow reveal.
	# Thin folded sheet and rounded nose are exterior finish, not new contact geometry.
	var ledge_metal:=mat("d2d5ce",1.0,0.14).duplicate()
	ledge_metal.anisotropy_enabled=true;ledge_metal.anisotropy=0.55
	box(reveal,Vector3(x,1.774,-0.225),Vector3(w+0.24,0.025,1.35),ledge_metal).set_meta("mersea_reflective_metal",true)
	var ledge_nose:=cyl(reveal,Vector3(x,1.753,0.449),0.034,w+0.24,ledge_metal)
	ledge_nose.rotation.z=PI/2
	(ledge_nose.mesh as CylinderMesh).radial_segments=32
	ledge_nose.set_meta("mersea_reflective_metal",true)
	# A slim inset metal bead identifies the aperture without replacing the olive portal.
	var inner_lip:=mat("aaa98b",0.65,0.30)
	for side in [-1,1]:
		box(portal,Vector3(x+side*(w/2-0.16),2.20,0.04),Vector3(0.025,0.91,0.045),inner_lip).set_meta("mersea_reflective_metal",true)
	box(portal,Vector3(x,2.475,-0.015),Vector3(w-0.30,0.025,0.045),inner_lip).set_meta("mersea_reflective_metal",true)
	box(reveal,Vector3(x,1.713,0.455),Vector3(w+0.20,0.090,0.030),counter_finish).set_meta("mersea_reflective_metal",true)
	for yy in [2.90,3.10,3.30]:box(g,Vector3(x,yy,0.12),Vector3(w+0.32,0.185,0.15),olive)
	# Raised serif lettering reuses the existing native TextMesh sign grammar.
	# Portable system fallback; exact font appearance on Mac is not yet verified.
	var sign_face:=Node3D.new();sign_face.name="GoldenHourRaisedSign";sign_face.set_meta("mersea_role","decor");g.add_child(sign_face)
	var serif:=SystemFont.new();serif.font_names=PackedStringArray(["Georgia","Times New Roman","DejaVu Serif"]);serif.font_weight=600
	var letters:=TextMesh.new();letters.text="GOLD BAR & MERSEA";letters.font=serif;letters.font_size=96;letters.pixel_size=0.007;letters.depth=0.045
	letters.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;letters.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	letters.material=mat("d7b468",0.85,0.23)
	var letter_mesh:=MeshInstance3D.new();letter_mesh.mesh=letters
	var letter_bounds:=letters.get_aabb()
	var letter_scale:=minf((w-0.12)/maxf(letter_bounds.size.x,0.01),0.43/maxf(letter_bounds.size.y,0.01))
	letter_mesh.scale=Vector3.ONE*letter_scale
	# Center actual font ink bounds and seat its rear1mm into existing receiver boards.
	var ink_center:=letter_bounds.get_center()
	letter_mesh.position=Vector3(x-ink_center.x*letter_scale,3.10-ink_center.y*letter_scale,0.194-letter_bounds.position.z*letter_scale)
	letter_mesh.set_meta("mersea_role","decor");sign_face.add_child(letter_mesh)

static func gold_platform(host: Node3D,land: Dictionary) -> void:
	# S23/S08 Golden Hour Bar platform motif, bound to verified114 waterfront edge0.
	# Width/depth/anchors inferred within actual land; not a surveyed reconstruction.
	var points: Array=POLYGONS.w1308007114
	var frame:=edge_frame(Vector2(points[0][0],points[0][1]),Vector2(points[1][0],points[1][1]),0.0)
	var p:=Node3D.new();p.name="GoldBarPlatform";p.transform=host.transform.affine_inverse()*frame
	p.set_meta("mersea_role","support");host.add_child(p)
	var foot:=frame*Vector3(0,0,5.28)
	var ground:=terrain_y(land,foot.x,foot.z)
	var top:=ground+0.56
	var concrete:=granular("898e82","9fa398",1.0).duplicate()
	concrete.roughness=0.94;concrete.normal_scale=0.16
	box(p,Vector3(0,(ground-0.1+top)/2,2.0),Vector3(7.4,top-ground+0.1,4.0),concrete)
	for x in [-2.6,2.6]:
		for step in range(3):
			var h:=top-float(step)*0.18
			var tread:=box(p,Vector3(x,(ground-0.1+h)/2,4.0+0.16+step*0.32),Vector3(1.65,h-ground+0.1,0.32),concrete)
			tread.set_meta("mersea_role","decor")
		# Ramp passes exactly through outer nosings; no collision below visible lips.
		var a:=Vector3(x-0.825,top-0.54,5.28);var b:=Vector3(x+0.825,top-0.54,5.28)
		var c:=Vector3(x+0.825,top,4.32);var d:=Vector3(x-0.825,top,4.32)
		var e:=Vector3(x+0.825,top,4.0);var f:=Vector3(x-0.825,top,4.0)
		var outer_a:=frame*Vector3(x-0.825,0,5.55);var outer_b:=frame*Vector3(x+0.825,0,5.55)
		outer_a.y=terrain_y(land,outer_a.x,outer_a.z)+0.005
		outer_b.y=terrain_y(land,outer_b.x,outer_b.z)+0.005
		outer_a=frame.affine_inverse()*outer_a;outer_b=frame.affine_inverse()*outer_b
		var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
		# Godot clockwise front faces, including the terrain-to-first-nosing approach.
		for v: Vector3 in [a,c,b,a,d,c,d,e,c,d,f,e,outer_a,b,outer_b,outer_a,a,b]:st.add_vertex(v)
		st.generate_normals()
		var ramp:=MeshInstance3D.new();ramp.mesh=st.commit();ramp.visible=false;ramp.set_meta("mersea_role","support");p.add_child(ramp)
	# Construction joints and small block faces, finite physical geometry.
	for row in range(3):
		for i in range(3):
			box(p,Vector3(-0.66+i*0.66,top-0.10-row*0.18,4.012),Vector3(0.64,0.16,0.035),concrete).set_meta("mersea_role","decor")
	for xx in [-1.0,1.0]:box(p,Vector3(xx,top+0.001,2.0),Vector3(0.012,0.002,3.99),mat("636a60")).set_meta("mersea_role","decor")


static func _settle_bar_reflection(probe: ReflectionProbe) -> void:
	# Keep startup rendering available while procedural images are generated.
	# Completed draw opportunities are not a cubemap-ready query.
	if DisplayServer.get_name()=="headless":
		probe.update_mode=ReflectionProbe.UPDATE_ONCE
		return
	var textures: Dictionary={}
	for material: Material in _materials.values():
		if material is StandardMaterial3D:
			for texture in [material.albedo_texture,material.normal_texture,material.roughness_texture]:
				if texture is NoiseTexture2D:textures[texture.get_instance_id()]=texture
	var deadline:=Time.get_ticks_msec()+5000
	while is_instance_valid(probe) and probe.is_inside_tree():
		var ready:=true
		for texture: NoiseTexture2D in textures.values():
			var image:=texture.get_image()
			if image==null or image.is_empty():ready=false;break
		if ready:break
		if Time.get_ticks_msec()>deadline:
			push_warning("Mersea bar reflection retained continuous updates: procedural images unavailable")
			return
		await probe.get_tree().process_frame
	if not is_instance_valid(probe) or not probe.is_inside_tree():return
	print("MERSEA_BAR_IMAGES_AVAILABLE rendered=%d textures=%d" % [Engine.get_frames_drawn(),textures.size()])
	for frame in range(8):
		await RenderingServer.frame_post_draw
		if not is_instance_valid(probe) or not probe.is_inside_tree():return
	probe.update_mode=ReflectionProbe.UPDATE_ONCE
	print("MERSEA_BAR_UPDATE_ONCE rendered=%d" % Engine.get_frames_drawn())


static func beveled_metal_border(p: Node3D,center: Vector3,size: Vector2,width: float,depth: float,material: Material) -> void:
	var corners: Array[Vector2]=[Vector2(-1,-1),Vector2(-1,1),Vector2(1,1),Vector2(1,-1)]
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(4):
		var a:Vector2=corners[i];var b:Vector2=corners[(i+1)%4]
		var outer_a:=center+Vector3(a.x*size.x/2,a.y*size.y/2,0)
		var outer_b:=center+Vector3(b.x*size.x/2,b.y*size.y/2,0)
		var inner_a:=center+Vector3(a.x*(size.x/2-width),a.y*(size.y/2-width),depth)
		var inner_b:=center+Vector3(b.x*(size.x/2-width),b.y*(size.y/2-width),depth)
		for v in [outer_a,outer_b,inner_b,outer_a,inner_b,inner_a]:st.add_vertex(v)
	st.generate_normals()
	var mesh:=MeshInstance3D.new();mesh.mesh=st.commit();mesh.material_override=material
	mesh.set_meta("mersea_reflective_metal",true);p.add_child(mesh)
