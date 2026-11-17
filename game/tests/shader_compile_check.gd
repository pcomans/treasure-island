extends SceneTree
## Every shader the game ships compiles on the renderer this run uses. Each .gdshader
## under res://game, and a copy for each name its code (or an include) tests with
## #ifdef, #ifndef or defined() with that name defined (as the ground dressing builds
## its capture variants), is drawn in front of a camera for a few frames, so the
## renderer builds it, not only parses it. A shader that fails prints the engine's
## SHADER ERROR and "ERROR: Shader compilation failed." lines, which fail
## tools/test.sh's check of this run; one whose code declares uniforms but compiled to
## none fails here too. tools/test.sh runs it on Forward+ and on the Compatibility
## renderer, which the web build uses and which compiles each shader's
## CURRENT_RENDERER == RENDERER_COMPATIBILITY branches.
##   tools/godot --path . --script game/tests/shader_compile_check.gd
##   tools/godot --rendering-method gl_compatibility --rendering-driver opengl3 --path . --script game/tests/shader_compile_check.gd

const ROOT := "res://game"
## The renderer's own names, never a variant.
const BUILT_IN := ["CURRENT_RENDERER", "RENDERER_COMPATIBILITY", "RENDERER_MOBILE", "RENDERER_FORWARD_PLUS"]
const FRAMES := 30

var _failures: Array[String] = []


func _initialize() -> void:
	_run()


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		print("FAIL: shader compile check needs a renderer; run it without --headless")
		quit(1)
		return
	var camera := Camera3D.new()
	camera.position = Vector3(0.0, 0.0, 6.0)
	root.add_child(camera)
	camera.make_current()
	var sun := DirectionalLight3D.new()
	sun.rotation = Vector3(-0.8, 0.4, 0.0)
	root.add_child(sun)
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0.0, 1.0, 3.0)
	root.add_child(lamp)
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.sky = Sky.new()
	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	root.add_child(world_environment)
	var canvas := CanvasLayer.new()
	root.add_child(canvas)
	var shaders := 0
	var variants := 0
	var skies: Array[ShaderMaterial] = []
	var placed := 0
	for path: String in _shader_paths(ROOT):
		var shader := load(path) as Shader
		if shader == null:
			_failures.append("%s does not load as a shader" % path)
			continue
		shaders += 1
		var source := _with_includes(shader.code, {})
		var made: Array[Shader] = [shader]
		for name: String in _tested_names(source):
			var variant := Shader.new()
			variant.code = "#define %s\n%s" % [name, shader.code]
			made.append(variant)
			variants += 1
		for each: Shader in made:
			var material := ShaderMaterial.new()
			material.shader = each
			var label := path if each == shader else "%s with %s" % [path, each.code.get_slice("\n", 0)]
			if _declares_uniforms(source) and each.get_shader_uniform_list().is_empty():
				_failures.append("%s compiled to no uniforms (a parse error)" % label)
			match each.get_mode():
				Shader.MODE_SPATIAL:
					var quad := MeshInstance3D.new()
					var mesh := QuadMesh.new()
					mesh.size = Vector2(0.3, 0.3)
					quad.mesh = mesh
					quad.material_override = material
					quad.position = Vector3(float(placed % 12) * 0.35 - 1.9, floorf(float(placed) / 12.0) * 0.35 - 1.2, 0.0)
					root.add_child(quad)
					placed += 1
				Shader.MODE_CANVAS_ITEM:
					var rect := ColorRect.new()
					rect.size = Vector2(16.0, 16.0)
					rect.material = material
					canvas.add_child(rect)
				Shader.MODE_SKY:
					skies.append(material)
				_:
					print("NOTE: %s is a shader mode this check doesn't draw" % label)
	for _i in FRAMES:
		await process_frame
	for sky: ShaderMaterial in skies:
		environment.sky.sky_material = sky
		for _i in 4:
			await process_frame
	if not _failures.is_empty():
		for failure: String in _failures:
			print("FAIL: %s" % failure)
		quit(1)
		return
	# Not a word of the engine's own error lines here: tools/test.sh reads them.
	print("PASS: %d shaders and %d define variants under %s compiled and drawn on %s (%s); tools/test.sh fails the run on any shader error the engine printed" % [shaders, variants, ROOT, RenderingServer.get_current_rendering_method(), RenderingServer.get_video_adapter_name()])
	quit(0)


## Every .gdshader under dir, sorted.
func _shader_paths(dir: String) -> Array[String]:
	var found: Array[String] = []
	for file: String in DirAccess.get_files_at(dir):
		if file.get_extension() == "gdshader":
			found.append(dir.path_join(file))
	for sub: String in DirAccess.get_directories_at(dir):
		if not sub.begins_with("."):
			found.append_array(_shader_paths(dir.path_join(sub)))
	found.sort()
	return found


## The code with each #include's file appended once, to read the names it tests.
func _with_includes(code: String, seen: Dictionary) -> String:
	var include := RegEx.create_from_string("(?m)^\\s*#\\s*include\\s+\"([^\"]+)\"")
	var whole := code
	for found: RegExMatch in include.search_all(code):
		var path := found.get_string(1)
		if seen.has(path):
			continue
		seen[path] = true
		whole += "\n" + _with_includes(FileAccess.get_file_as_string(path), seen)
	return whole


## The names the code tests with #ifdef, #ifndef or defined() and leaves to whoever
## compiles it: not the renderer's own, nor one the code #defines itself (a switch of
## its own, such as the water's WATER_SIMPLE on the web, whose second definition would
## only fail).
func _tested_names(code: String) -> Array[String]:
	var own: Array[String] = []
	for found: RegExMatch in RegEx.create_from_string("(?m)^\\s*#\\s*define\\s+(\\w+)").search_all(code):
		own.append(found.get_string(1))
	var names: Array[String] = []
	var tests := RegEx.create_from_string("(?m)^\\s*#\\s*(?:ifdef|ifndef)\\s+(\\w+)|defined\\s*\\(\\s*(\\w+)\\s*\\)")
	for found: RegExMatch in tests.search_all(code):
		var name := found.get_string(1) if found.get_string(1) != "" else found.get_string(2)
		if not name in BUILT_IN and not name in own and not name in names:
			names.append(name)
	names.sort()
	return names


## Whether the code declares a material uniform (not an instance or global one).
func _declares_uniforms(code: String) -> bool:
	return RegEx.create_from_string("(?m)^\\s*uniform\\s").search(code) != null
