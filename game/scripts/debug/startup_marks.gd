extends RefCounted
## Optional diagnostic User Timing marks; no runtime behavior or GPU readback.
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
