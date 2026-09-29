extends RefCounted
# Building 3: contemporary observed front; unknown dimensions and unseen sides inferred.
static func mat(c: Color) -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.9
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m

static func mineral(c: Color, strength: float) -> ShaderMaterial:
	var s = Shader.new()
	s.code = """shader_type spatial;
render_mode cull_disabled;
uniform vec4 base : source_color;
uniform float amount;
varying vec3 pos;
float hash(vec3 p){return fract(sin(dot(p,vec3(127.1,311.7,74.7)))*43758.5453);}
float noise(vec3 p){vec3 i=floor(p);vec3 f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z);}
void vertex(){pos=VERTEX;}
void fragment(){float n=noise(pos*0.5)*0.6+noise(pos*3.5)*0.3+noise(pos*22.0)*0.1;float damp=(1.0-smoothstep(0.0,1.3,pos.y))*0.07;float drip=exp(-abs(pos.y-9.6)*2.5)*noise(vec3(pos.x*2.0,0.0,pos.z))*0.12;ALBEDO=base.rgb*(1.0+amount*(n-0.5)-damp-drip);ROUGHNESS=0.94;}
"""
	var m = ShaderMaterial.new()
	m.shader = s
	m.set_shader_parameter('base',c)
	m.set_shader_parameter('amount',strength)
	return m

# Roof finish is a procedural material, never reference-image texturing.
# Grid cadence, repair extents and colors are reversible production inference.
static func roofing() -> ShaderMaterial:
	var s = Shader.new()
	s.code = """shader_type spatial;
render_mode cull_back;
varying vec3 pos;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){vec2 i=floor(p);vec2 f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
float rect(vec2 p,vec2 lo,vec2 hi){return step(lo.x,p.x)*step(lo.y,p.y)*step(p.x,hi.x)*step(p.y,hi.y);}
void vertex(){pos=VERTEX;}
void fragment(){
vec2 p=pos.xz;
vec3 base=vec3(0.058,0.054,0.052);
float broad=noise(p*0.12);
float grain=noise(p*4.0);
float repair=max(rect(p,vec2(-34,-132),vec2(-12,-106)),rect(p,vec2(17,-130),vec2(34,-92)));
repair=max(repair,rect(p,vec2(-34,-28),vec2(-22,-8)));
repair=max(repair,rect(p,vec2(-29,-106),vec2(-12,-100)));
base=mix(base,vec3(0.084,0.099,0.110),repair*0.55);
vec2 cell=abs(fract((p+vec2(0,0.7))/vec2(2.3,10.5))-0.5)*vec2(2.3,10.5);
vec2 edge=vec2(1.15,5.25)-cell;
vec2 aa=max(fwidth(p),vec2(0.01));
float seam=max(1.0-smoothstep(0.025,0.025+aa.x,edge.x),1.0-smoothstep(0.035,0.035+aa.y,edge.y));
ALBEDO=base*(0.88+broad*0.23+grain*0.05)*(1.0-seam*0.055);
ROUGHNESS=0.91;
}
"""
	var m = ShaderMaterial.new()
	m.shader = s
	return m

static func box(r: Node3D, p: Vector3, s: Vector3, m: Material) -> MeshInstance3D:
	var n = MeshInstance3D.new()
	var b = BoxMesh.new()
	b.size = s
	n.mesh = b
	n.material_override = m
	n.position = p
	r.add_child(n)
	return n

static func surface(r: Node3D, v: PackedVector3Array, m: Material, smooth: bool = false) -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	if not smooth:
		st.set_smooth_group(-1)
	for p in v:
		st.add_vertex(p)
	st.generate_normals()
	var n = MeshInstance3D.new()
	n.mesh = st.commit()
	n.material_override = m
	r.add_child(n)

static func quad(v: PackedVector3Array, a: Vector3,b: Vector3,c: Vector3,d: Vector3) -> void:
	v.append_array(PackedVector3Array([a,b,c,a,c,d]))

static func roof_y(x: float) -> float:
	return 18.0 + 5.0 * (1.0 - pow(x / 35.0, 2.0))

static func build() -> Node3D:
	var r = Node3D.new()
	r.name = 'Building3_StreetViewStudy'
	var wall = mineral(Color('#a8a897'), 0.08)
	var trim = mineral(Color('#919586'), 0.06)
	var light = mat(Color('#bab9a9'))
	var seam = mat(Color('#898e80'))
	var roof = roofing()
	var wing_roof = mineral(Color('#888379'), 0.10)
	var flashing = mat(Color('#72736b'))
	var dark = mat(Color('#202827'))
	var blue = mat(Color('#49646a'))
	var metal = mat(Color('#667575'))
	var paving = mineral(Color('#73766a'), 0.12)
	var joint = mat(Color('#777b70'))
	var ring = [[-44.912523491766834, -136.70454937145104], [-36.3065347604348, -136.66688033660293], [-25.892909272817768, -136.62035933432338], [-6.1777092648888825, -136.53294281779952], [-2.2117723856107077, -136.5156897142752], [-0.11742159022859511, -136.50659323790978], [17.706070933664115, -136.42697382608054], [21.468941327535305, -136.40967067816285], [36.07308094298221, -136.34364725402887], [45.14923186662026, -136.30230222598647], [47.708810311053576, -136.29033615760846], [47.65864402866536, -128.55901354474904], [47.632952466116784, -124.46455510148527], [48.59069941874076, -124.45840898568325], [48.556363528705724, -117.79369661029477], [57.75769057078156, -117.73088208358868], [57.643339276047755, -100.52446953531489], [57.6242780198781, -97.66105781701222], [57.60728127207989, -95.1326994344714], [57.38245177542812, -61.42933751466532], [57.173741511424325, -30.178279852152524], [55.43764751119298, -30.188410121679475], [47.26885202480556, -30.24015276924102], [47.219389419731485, -23.170377210519295], [45.41425176087225, -23.18956138546205], [45.406078902500816, -19.065895152073853], [45.396731783441744, -14.23191939382215], [45.159904065996436, -3.907985046680551e-14], [35.106723675344455, -0.00018168771986637466], [26.118987598517485, 0.00028016002826625197], [8.918197471399194, 0.00033335987555283], [2.4052663086099777, -0.00048442308399554435], [-0.998564593585023, -4.938008721844245e-05], [-21.308878155358563, 0.00010040986781412187], [-37.10385286251448, 8.292754548122616e-05], [-45.02302261932713, 0.0006852428196992832], [-45.159904065996415, -3.907985046680551e-14], [-44.99526349259895, -7.933304386041904], [-44.851867218095435, -14.827633469314492], [-44.693698923726146, -22.447275441917686], [-46.28083038430796, -22.43144108587134], [-45.868396436866874, -43.582418468465235], [-45.32246646846014, -71.55598244357569], [-43.1773808775246, -71.53616307020648], [-43.175662295485836, -74.39389749566936], [-40.70841174869172, -75.9945332254168], [-39.86387747013647, -76.54189220483084], [-38.556843792347, -78.36556787915568], [-37.8573893060434, -80.2486112725988], [-37.64985755428633, -82.35187506299995], [-37.90516760727379, -83.8488489361332], [-38.01462044164601, -84.49232549129884], [-38.996310979234636, -86.53945242639811], [-40.178386287056114, -87.93577759147927], [-40.997261033688815, -88.45565175829965], [-43.03401582540807, -89.74724880010825], [-43.00251527133422, -92.69049950555166], [-45.1063119791651, -92.70255820034436], [-45.00275077599767, -116.24546422481801]]
	var walls = PackedVector3Array()
	var poly = PackedVector2Array()
	for q in ring:
		poly.append(Vector2(q[0],q[1]))
	for i in range(ring.size()):
		var a = ring[i]
		var b = ring[(i+1)%ring.size()]
		quad(walls,Vector3(a[0],0,a[1]),Vector3(b[0],0,b[1]),Vector3(b[0],10,b[1]),Vector3(a[0],10,a[1]))
	surface(r,walls,wall)
	var top = PackedVector3Array()
	var ids = Geometry2D.triangulate_polygon(poly)
	for i in ids:
		top.append(Vector3(poly[i].x,9.95,poly[i].y))
	surface(r,top,wing_roof)
	# Continuous main barrel and its front/rear vertical arched closures.
	var shell = PackedVector3Array()
	var ends = PackedVector3Array()
	for i in range(70):
		var x = -35.0+i
		var y = roof_y(x)
		var y2 = roof_y(x+1)
		quad(shell,Vector3(x,y,-5),Vector3(x,y,-134),Vector3(x+1,y2,-134),Vector3(x+1,y2,-5))
		quad(ends,Vector3(x,9.9,-5),Vector3(x,y,-5),Vector3(x+1,y2,-5),Vector3(x+1,9.9,-5))
		quad(ends,Vector3(x,9.9,-134),Vector3(x+1,9.9,-134),Vector3(x+1,y2,-134),Vector3(x,y,-134))
	surface(r,shell,roof,true)
	surface(r,ends,wall)
	for x in [-35.0,35.0]:
		box(r,Vector3(x,14,-69.5),Vector3(0.3,8,129),wall)
	# Restrained eave flashing joins the membrane to the tall side walls.
	for x in [-34.94,34.94]:
		box(r,Vector3(x,18.05,-69.5),Vector3(0.12,0.18,129),flashing)
	# Thin curved cap; broad front remains uninterrupted mineral surface.
	var lip = PackedVector3Array()
	for i in range(70):
		var x = -35.0+i
		quad(lip,Vector3(x,roof_y(x),-4.9),Vector3(x,roof_y(x)+0.16,-4.9),Vector3(x+1,roof_y(x+1)+0.16,-4.9),Vector3(x+1,roof_y(x+1),-4.9))
		quad(lip,Vector3(x,roof_y(x)+0.16,-4.9),Vector3(x,roof_y(x)+0.16,-5.35),Vector3(x+1,roof_y(x+1)+0.16,-5.35),Vector3(x+1,roof_y(x+1)+0.16,-4.9))
	surface(r,lip,trim)
	# Narrow Art Deco pylons: stepped shoulders, vertical raised strips and small cap.
	for x in [-36.0,36.0]:
		box(r,Vector3(x,14.8,-4.6),Vector3(4.4,10.1,3.8),wall)
		box(r,Vector3(x,20.1,-4.6),Vector3(3.4,0.65,3.6),light)
		box(r,Vector3(x,15.3,-2.57),Vector3(1.65,9.25,0.32),light)
		for dx in [-1.65,1.65]:
			box(r,Vector3(x+dx,15.0,-2.58),Vector3(0.26,8.4,0.32),trim)
			box(r,Vector3(x+dx,18.8,-2.35),Vector3(0.55,1.4,0.6),trim)
	# Fine antenna stems visible on the left pylon.
	for dx in [-1.2,0.0,1.2]:
		box(r,Vector3(-36+dx,22.15,-4.4),Vector3(0.045,4.0,0.045),metal)
	# Low facade parapet, stained underside and restrained panel breaks.
	box(r,Vector3(0,10.05,-0.02),Vector3(90.25,0.45,0.42),trim)
	box(r,Vector3(0,9.69,0.055),Vector3(90.0,0.12,0.07),seam)
	box(r,Vector3(0,0.45,0.045),Vector3(90,0.8,0.1),trim)
	for x in [-30.0,-15.0,15.0,30.0]:
		box(r,Vector3(x,5.1,0.038),Vector3(0.055,9,0.045),trim)
	for x in [-15.0,0.0,15.0]:
		box(r,Vector3(x,17.4,-4.97),Vector3(0.048,7.0,0.04),trim)
	# Compact blue surround and deep nearly black central entry, no invented interior.
	box(r,Vector3(0,2.85,0.11),Vector3(13,5.7,0.3),blue)
	box(r,Vector3(0,2.6,0.3),Vector3(6.4,5.2,0.14),dark)
	box(r,Vector3(0,5.7,0.55),Vector3(13.6,0.45,1.1),metal)
	for x in [-3.3,3.3]:
		box(r,Vector3(x,2.65,0.43),Vector3(0.18,5.3,0.25),metal)
	box(r,Vector3(0,7.95,0.12),Vector3(6.7,2.65,0.22),light)
	var sign_label = Label3D.new()
	sign_label.text = 'BIGGE'
	sign_label.font_size = 80
	sign_label.pixel_size = 0.018
	sign_label.modulate = Color('#354f64')
	sign_label.position = Vector3(0,8.3,0.26)
	r.add_child(sign_label)
	var sub = Label3D.new()
	sub.text = 'CRANE • RIGGING CO.'
	sub.font_size = 36
	sub.pixel_size = 0.015
	sub.modulate = Color('#536573')
	sub.position = Vector3(0,7.5,0.27)
	r.add_child(sub)
	# Observed service conduit beneath the parapet.
	box(r,Vector3(17,3,0.13),Vector3(34,0.065,0.1),metal)
	box(r,Vector3(34,6.35,0.13),Vector3(0.07,6.6,0.1),metal)
	# Restrained side articulation: no claimed unseen bay schedule.
	for x in [-35.2,35.2]:
		box(r,Vector3(x,17.8,-69),Vector3(0.26,0.23,129),trim)
	# Forecourt slab grid with irregular patch tones; all below architectural base.
	box(r,Vector3(2,-0.10,31),Vector3(116,0.28,62),paving)
	box(r,Vector3(58,-0.10,-60),Vector3(12,0.28,150),paving)
	for x in range(-54,60,12):
		box(r,Vector3(x,0.048,31),Vector3(0.045,0.012,62),joint)
	for z in range(8,62,10):
		box(r,Vector3(2,0.048,z),Vector3(116,0.012,0.045),joint)
	# Sparse utility objects give the loading apron scale without becoming a facade motif.
	var timber = mat(Color('#756958'))
	for x in [-15.0,18.0]:
		for k in range(4):
			box(r,Vector3(x,0.17+k*0.23,2),Vector3(6,0.16,1.45),timber)
	for x in [7.4,8.5]:
		box(r,Vector3(x,0.65,1.0),Vector3(0.8,1.3,0.8),metal)
	return r
