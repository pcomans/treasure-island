extends RefCounted
## Opt-in diagnostic marks/material probe; default and native paths are no-ops.
static var _checked := false
static var _enabled := false


static func enabled() -> bool:
	if not _checked:
		_checked = true
		_enabled = OS.has_feature("web") and bool(JavaScriptBridge.eval("new URLSearchParams(location.search).get('profile_startup') === '1'"))
	return _enabled


static func mark(label: String) -> void:
	if enabled():
		JavaScriptBridge.get_interface("performance").mark("TI:" + label)


static func probe_building_materials(buildings: Node3D) -> void:
	if not enabled():
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
