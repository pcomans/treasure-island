extends RefCounted
# Independent reusable low hall + transverse arched passage; dimensions are inference.
const GEO = preload("res://game/tests/support/building_study_geometry.gd")
const ORIGIN = Vector3(268.366,4.064,-374.918)
const EAST = Vector3(0.890005,0,-0.455951)
const SOUTH = Vector3(0.455951,0,0.890005)
const LENGTH = 104.109
const WIDTH = 17.556
static func mat(hex:String) -> StandardMaterial3D:
	var m:=StandardMaterial3D.new();m.albedo_color=Color(hex);m.roughness=0.9
	return m
static func build() -> Node3D:
	var r:=Node3D.new();r.name="Independent600"
	r.transform=Transform3D(Basis(EAST,Vector3.UP,SOUTH),ORIGIN)
	var cream:=mat("c4c1aa");var trim:=mat("bbb7a3");var blue:=mat("67787c");var glass:=mat("344c53");var red:=mat("863c3b");var dark:=mat("343b38");var roof:=mat("bcbdb3")
	var stucco:=coating(Color("c4c1aa"))
	var coated_blue:=coating(Color("7b898b"))
	# Masonry openings occupy bounded holes, with glazing recessed behind the wall face.
	box(r,"west_base",Vector3(.24,.5,45),Vector3(.48,2.1,90),stucco)
	box(r,"west_header",Vector3(.24,5.35,45),Vector3(.48,1.3,90),stucco)
	for i in 15:
		var z:=3.0+i*6.0
		var high:bool=i>=4 and i<=10
		box(r,"west_pier",Vector3(.24,3.1,.15 if i==0 else z-3.0),Vector3(.48,3.1,.3 if i==0 else .6),stucco)
		if high:
			box(r,"high_sill_wall",Vector3(.24,2.6,z),Vector3(.48,2.1,5.4),stucco)
			for j in 3:
				var center:=z-1.8+j*1.8
				opening(r,center,3.65,4.65,1.2,glass,trim,blue)
				if j<2:box(r,"high_window_web",Vector3(.24,4.15,center+.9),Vector3(.48,1,.6),stucco)
			for side in [-1.0,1.0]:box(r,"high_terminal_web",Vector3(.24,4.15,z+side*2.55),Vector3(.48,1,.3),stucco)
		else:
			opening(r,z,1.55,4.65,5.4,glass,trim,blue)
	# The terminal joint is closed masonry, without dangling trim legs.
	box(r,"west_terminal",Vector3(.24,3.1,89.85),Vector3(.48,3.1,.3),stucco)
	# Unobserved rear restrained, no fabricated opening schedule.
	box(r,"east_wall",Vector3(WIDTH-.22,2.7,45),Vector3(.44,6.6,90),stucco)
	box(r,"south_hall_end",Vector3(WIDTH/2,2.7,89.8),Vector3(WIDTH,6.6,.4),stucco)
	# North broad alternating bands, with sheltered edge passages.
	for band in [[-.6,1.5,coated_blue],[1.5,2.8,coated_blue],[2.8,4.1,stucco],[4.1,6.0,coated_blue]]:
		box(r,"north_band",Vector3(8.7,(band[0]+band[1])/2,.25),Vector3(12.5,band[1]-band[0],.5),band[2])
	for edge in [[1.225,2.45],[16.253,2.606]]:
		box(r,"north_side_lintel",Vector3(edge[0],3.45,.25),Vector3(edge[1],1.3,.5),trim)
	box(r,"north_roof_closure",Vector3(WIDTH/2,6.02,.27),Vector3(WIDTH,.35,.46),coated_blue)
	# Pale low roof: slight crown inferred, long seams and thin edge flashing.
	for half in 2:
		var slab:=box(r,"roof",Vector3(WIDTH*(.25+.5*half),6.03,45),Vector3(WIDTH/2,.22,90),roof,false)
		slab.rotation.z=deg_to_rad(2.0 if half==0 else -2.0)
	for x in [.12,WIDTH-.12]:box(r,"roof_edge",Vector3(x,6.05,45),Vector3(.24,.32,90),trim,false)
	for z in range(3,90,6):box(r,"roof_seam",Vector3(WIDTH/2,6.20,z),Vector3(WIDTH,.035,.055),trim,false)
	# South portal looks west across the final 14m of the footprint.
	for z in [91.1,103.0]:box(r,"portal_pier",Vector3(.5,2.7,z),Vector3(1,6.6,2.2),red)
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 64:
		var za:float=92.2+i*9.7/64;var zb:float=92.2+(i+1)*9.7/64
		var ya:float=3.1+1.65*sqrt(maxf(0,1-pow((za-97.05)/4.85,2)))
		var yb:float=3.1+1.65*sqrt(maxf(0,1-pow((zb-97.05)/4.85,2)))
		quad(st,Vector3(0,ya,za),Vector3(0,yb,zb),Vector3(0,6,zb),Vector3(0,6,za))
		quad(st,Vector3(1,yb,zb),Vector3(1,ya,za),Vector3(1,6,za),Vector3(1,6,zb))
		quad(st,Vector3(0,ya,za),Vector3(1,ya,za),Vector3(1,yb,zb),Vector3(0,yb,zb))
		quad(st,Vector3(0,6,zb),Vector3(1,6,zb),Vector3(1,6,za),Vector3(0,6,za))
	st.generate_normals();piece(r,"continuous_arch",st.commit(),Vector3.ZERO,red,true)
	box(r,"passage_roof",Vector3((WIDTH+1.0)/2,5.8,97.05),Vector3(WIDTH-1.0,.24,14.109),dark,false)
	for x in [3.0,7.0,11.0,15.0]:box(r,"canopy_beam",Vector3(x,5.5,97.05),Vector3(.12,.35,14.109),dark,false)
	for z in [90.3,103.8]:box(r,"passage_edge",Vector3(WIDTH/2,5.55,z),Vector3(WIDTH,.4,.22),trim,false)
	# Cream open screen at southern passage flank; geometric perforation, no interior.
	for x in range(2,17,2):
		box(r,"screen_post",Vector3(x,2.2,103.9),Vector3(.3,5.0,.3),cream)
	for y in [.3,1.6,2.9,4.2]:box(r,"screen_rail",Vector3(9,y,103.9),Vector3(16,.6,.3),cream)
	var words:="SFFD FIRE FIGHTING SCHOOL"
	for i in words.length():
		var z:=93.0+i*.35;var u:float=(z-97.05)/4.85
		label(r,words[i],Vector3(-.025,3.35+1.65*sqrt(maxf(0,1-u*u)),z),.31)
	label(r,"600",Vector3(-.03,1.6,91.0),.22)
	for z in [93.0,95.0,97.0,99.0,101.0]:box(r,"bollard",Vector3(1.3,.55,z),Vector3(.24,1.5,.24),trim)
	return r
static func label(r:Node3D,text:String,p:Vector3,size:float) -> void:
	var l:=Label3D.new();l.text=text;l.font_size=64;l.pixel_size=size/64;l.position=p;l.rotation.y=-PI/2;l.modulate=Color("edece1");l.outline_size=0;r.add_child(l)
static func opening(r:Node3D,z:float,bottom:float,top:float,width:float,glass:Material,trim:Material,blue:Material) -> void:
	box(r,"recessed_glazing",Vector3(.40,(bottom+top)/2,z),Vector3(.10,top-bottom,width),glass)
	for side in [-1.0,1.0]:box(r,"masonry_reveal",Vector3(.21,(bottom+top)/2,z+side*(width/2-.055)),Vector3(.46,top-bottom,.11),trim)
	for y in [bottom,top]:box(r,"window_edge",Vector3(.20,y,z),Vector3(.48,.10,width),trim)
	if width>2:
		for j in 3:box(r,"mullion",Vector3(.34,(bottom+top)/2,z-1.35+j*1.35),Vector3(.12,top-bottom,.045),blue)
static func quad(st:SurfaceTool,a:Vector3,b:Vector3,c:Vector3,d:Vector3) -> void:
	for v in [a,c,b,a,d,c]:st.add_vertex(v)
static func box(r:Node3D,role:String,p:Vector3,size:Vector3,m:Material,spray:bool=true) -> MeshInstance3D:
	var mesh:=BoxMesh.new();mesh.size=size
	return piece(r,role,mesh,p,m,spray)
static func piece(r:Node3D,role:String,mesh:Mesh,p:Vector3,m:Material,spray:bool) -> MeshInstance3D:
	var n:=MeshInstance3D.new();n.mesh=mesh;n.material_override=m;n.position=p;n.set_meta("semantic_role",role);n.layers=2 if spray else 1;r.add_child(n)
	var body:=StaticBody3D.new();body.collision_layer=5;body.collision_mask=0
	body.set_meta("receiver_kind","building_wall" if spray else "none");body.set_meta("opaque",true);body.set_meta("derived_object_key","building:w34313548:"+("wall" if spray else "roof"));body.set_meta("source_keys",["w34313548"])
	if spray:body.add_to_group("spray_receiver_wall")
	var shape:=ConcavePolygonShape3D.new();shape.set_faces(mesh.get_faces());shape.set_meta("receiver_kind",body.get_meta("receiver_kind"));shape.set_meta("opaque",true)
	var c:=CollisionShape3D.new();c.shape=shape;body.add_child(c);n.add_child(body)
	return n

static func coating(tint:Color) -> ShaderMaterial:
	var shader:=Shader.new()
	shader.code="""shader_type spatial;
uniform vec4 tint : source_color;
varying vec3 masonry_position;
void vertex(){ masonry_position=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
float hash(vec3 p){p=fract(p*0.1031);p+=dot(p,p.yzx+33.33);return fract((p.x+p.y)*p.z);}
float noise3(vec3 p){vec3 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1)),f.x),f.y),f.z);}
void fragment(){
 vec3 p=masonry_position;
 // Metre-based continuous rough coating. Shallow relief only, no silhouette claim.
 float coarse=noise3(p*6.5);
 float aggregate=noise3(p*21.0);
 float fine=noise3(p*45.0);
 float course=abs(fract((p.y+0.018*noise3(p*5.0))/0.24)-0.5)*0.24;
 float seam=1.0-smoothstep(0.004,0.018,course);
 float relief=0.021*coarse+0.004*aggregate+0.001*fine-0.0015*seam;
 vec3 dx=dFdx(VERTEX),dy=dFdy(VERTEX);
 vec3 r1=cross(dy,NORMAL),r2=cross(NORMAL,dx);
 float det=dot(dx,r1);
 NORMAL=normalize(abs(det)*NORMAL-sign(det)*(dFdx(relief)*r1+dFdy(relief)*r2));
 float field=noise3(p*0.7);
 float base_weather=(1.0-smoothstep(4.0,5.15,p.y))*(0.5+0.5*noise3(vec3(p.x*2.0,p.y*0.15,p.z*2.0)));
 ALBEDO=tint.rgb*(0.94+0.075*coarse+0.045*field-0.010*seam-0.075*base_weather);
 ROUGHNESS=0.92;
}
"""
	var material:=ShaderMaterial.new();material.shader=shader;material.set_shader_parameter("tint",tint)
	return material
