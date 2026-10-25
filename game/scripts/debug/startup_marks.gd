extends RefCounted
## Opt-in diagnostic marks/material probe; default paths are no-ops.
static var _checked := false
static var _enabled := false


static func enabled() -> bool:
	if not _checked:
		_checked = true
		if OS.has_feature("web"):
			_enabled = bool(JavaScriptBridge.eval("new URLSearchParams(location.search).get('profile_startup') === '1'"))
		else:
			_enabled = OS.get_cmdline_user_args().has("--profile-startup-native")
	return _enabled


static func mark(label: String) -> void:
	if not enabled():
		return
	if OS.has_feature("web"):
		JavaScriptBridge.get_interface("performance").mark("TI:" + label)
	else:
		print("TI_NATIVE_MARK %s ticks_usec=%d" % [label, Time.get_ticks_usec()])
		if label == "first_frame_submitted":
			print("TI_NATIVE_RENDERER %s / %s" % [DisplayServer.get_name(), RenderingServer.get_video_adapter_name()])


static func probe_building_materials(buildings: Node3D) -> void:
	if not OS.has_feature("web") or not enabled():
		return
	var isolate := bool(JavaScriptBridge.eval("new URLSearchParams(location.search).get('profile_materials') === 'shared_buildings'"))
	mark("material_probe_begin")
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.65, 0.65, 0.65)
	material.roughness = 0.8
	var meshes := buildings.find_children("*", "MeshInstance3D", true, false)
	var applied := 0
	for mesh: MeshInstance3D in meshes:
		if isolate:
			mesh.material_override = material
			if mesh.material_override == material:
				applied += 1
	print("TI_MATERIAL_PROBE shared=%s meshes=%d applied=%d frames_drawn=%d" % [isolate, meshes.size(), applied, Engine.get_frames_drawn()])
	mark("material_probe_end")
