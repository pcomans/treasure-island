extends RefCounted
# Geometry-bound ambient visibility and return finish; direct sun is unchanged.
# Original opaque BoxMeshes and complete contact ordering remain unchanged.
const FIELD_PATH := "res://game/scripts/world/facades/croaker_1444_shelter_visibility.json"

static func _vector(values:Array)->Vector3:
	return Vector3(values[0],values[1],values[2])

static func _material(original:Material,fields:Array,size:Vector3,shared:Dictionary)->ShaderMaterial:
	var original_code:String
	if original is ShaderMaterial:
		original_code=original.shader.code
	else:
		assert(original is StandardMaterial3D)
		assert(original.cull_mode==0 and original.shading_mode==1 and original.transparency==0)
		original_code="""shader_type spatial;
		uniform vec4 original_color : source_color;
		uniform float original_roughness;
		void vertex(){}
		void fragment(){ALBEDO=original_color.rgb;ROUGHNESS=original_roughness;METALLIC=0.0;SPECULAR=0.5;}"""
	var declarations:="varying vec3 shelter_world; varying vec3 shelter_position; varying vec3 shelter_normal; uniform vec4 soffit_color : source_color;"
	var ambient:="AO=1.0; AO_LIGHT_AFFECT=0.0;"
	var finish:=""
	for i in fields.size():
		var suffix:=str(i)
		declarations+="uniform sampler2D visibility_"+suffix+" : filter_linear, repeat_disable; uniform vec3 normal_"+suffix+"; uniform vec3 u_"+suffix+"; uniform vec3 v_"+suffix+"; uniform vec2 span_"+suffix+"; uniform vec2 grid_"+suffix+";"
		var condition:="dot(normalize(shelter_normal),normal_"+suffix+")>0.99"
		ambient+="if ("+condition+"){vec2 p=vec2(dot(shelter_position,u_"+suffix+"),dot(shelter_position,v_"+suffix+"));vec2 uv=clamp(p/span_"+suffix+"+vec2(0.5),vec2(0.0),vec2(1.0));AO=texture(visibility_"+suffix+",(uv*(grid_"+suffix+"-vec2(1.0))+vec2(0.5))/grid_"+suffix+").r;}"
		if bool(fields[i].get("soffit_finish",false)):
			finish+="if ("+condition+"){ALBEDO=soffit_color.rgb;ROUGHNESS=0.82;METALLIC=0.0;SPECULAR=0.5;}"
	var has_underside:=false
	for field:Dictionary in fields:
		if _vector(field.normal_local)==Vector3.DOWN:has_underside=true
	if has_underside:
		declarations+="uniform sampler2D shared_visibility : filter_linear, repeat_disable; uniform vec2 shared_origin; uniform vec2 shared_span; uniform vec2 shared_grid;"
		finish+="if(shelter_normal.y < -0.99){vec2 uv=clamp((shelter_world.xz-shared_origin)/shared_span,vec2(0.0),vec2(1.0));AO=texture(shared_visibility,(uv*(shared_grid-vec2(1.0))+vec2(0.5))/shared_grid).r;AO_LIGHT_AFFECT=0.0;ALBEDO=soffit_color.rgb;ROUGHNESS=0.82;METALLIC=0.0;SPECULAR=0.5;}"
	var code:=original_code.replace("shader_type spatial;","shader_type spatial;"+declarations).replace("void vertex(){","void vertex(){shelter_world=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;shelter_position=VERTEX;shelter_normal=NORMAL;").replace("void fragment(){","void fragment(){"+ambient)
	var end:int=code.rfind("}")
	code=code.left(end)+finish+code.substr(end)
	var shader:=Shader.new();shader.code=code
	var material:=ShaderMaterial.new();material.shader=shader
	material.set_shader_parameter("soffit_color",Color("9b9279"))
	if original is StandardMaterial3D:
		material.set_shader_parameter("original_color",original.albedo_color)
		material.set_shader_parameter("original_roughness",original.roughness)
	for i in fields.size():
		var field:Dictionary=fields[i]
		var suffix:=str(i)
		var values:=PackedFloat32Array(field.values)
		var image:=Image.create_from_data(int(field.width),int(field.height),false,Image.FORMAT_RF,values.to_byte_array())
		material.set_shader_parameter("visibility_"+suffix,ImageTexture.create_from_image(image))
		material.set_shader_parameter("normal_"+suffix,_vector(field.normal_local))
		var u:=Vector3.ZERO;var v:=Vector3.ZERO
		u[int(field.uv_axes[0])]=1.0;v[int(field.uv_axes[1])]=1.0
		material.set_shader_parameter("u_"+suffix,u);material.set_shader_parameter("v_"+suffix,v)
		material.set_shader_parameter("span_"+suffix,Vector2(size[int(field.uv_axes[0])],size[int(field.uv_axes[1])]))
		material.set_shader_parameter("grid_"+suffix,Vector2(field.width,field.height))
	if has_underside:
		var values:=PackedFloat32Array(shared.values)
		var image:=Image.create_from_data(int(shared.width),int(shared.height),false,Image.FORMAT_RF,values.to_byte_array())
		material.set_shader_parameter("shared_visibility",ImageTexture.create_from_image(image))
		material.set_shader_parameter("shared_origin",Vector2(shared.origin[0],shared.origin[1]))
		material.set_shader_parameter("shared_span",Vector2(shared.span[0],shared.span[1]))
		material.set_shader_parameter("shared_grid",Vector2(shared.width,shared.height))
	return material

static func _host(root:Node3D,binding:Dictionary)->MeshInstance3D:
	var expected_origin:=_vector(binding.origin);var expected_size:=_vector(binding.size)
	var matches:Array=[]
	for node in root.find_children("*","MeshInstance3D",true,false):
		if node.mesh is BoxMesh and node.position.distance_to(expected_origin)<0.0001 and node.mesh.size.distance_to(expected_size)<0.0001:matches.append(node)
	assert(matches.size()==1,"Exact native shelter host required")
	return matches[0]

static func apply(root:Node3D)->void:
	var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(FIELD_PATH))
	var groups:Dictionary={};var bindings:Array=[]
	for field:Dictionary in data.fields:
		var node:=_host(root,field.binding)
		if not groups.has(node):groups[node]=[]
		groups[node].append(field)
		bindings.append({"label":field.label,"child_index":node.get_index(),"origin":field.binding.origin,"size":field.binding.size,"width":field.width,"height":field.height,"normal":field.normal_local,"soffit_finish":field.soffit_finish})
	for node:MeshInstance3D in groups:node.material_override=_material(node.material_override,groups[node],node.mesh.size,data.shared_underside)
	assert(data.replacements.is_empty(),"Material recovery cannot alter original geometry")
	root.set_meta("shelter_visibility_bindings",bindings)
	root.set_meta("shelter_visibility_sha256",FileAccess.get_sha256(FIELD_PATH))
