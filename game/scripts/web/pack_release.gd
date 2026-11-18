extends RefCounted
## On the web the game data pack (about 160 MB) sits in the page's memory for the whole
## session: Godot reads every resource from it, through the browser's copy of its file
## system, whenever one is loaded (core/io/file_access_pack.cpp opens the pack for each
## file). Once play is ready, release() tells the page (game/web/shell.html,
## tiPackRelease) which of its files the game never reads again, and the page frees
## their bytes:
## - the imported files (under res://.godot/imported/: textures, imported scenes,
##   sounds) of every imported resource Godot holds now. Each is held here for the rest
##   of the session, so a later load() of it, a preload() of a script loaded later
##   included, returns it from Godot's cache without reading its file. The game loads
##   nothing with a cache mode that bypasses the cache;
## - the files the caller names as loaded once: the baked world, which WorldLoader
##   loads once per session as the game starts (world_loader.gd, _load_prebuilt) and
##   lets go once its nodes are in the tree.
## Everything else stays readable: what has not been loaded yet, what was loaded and let
## go (it may be loaded again), scripts, scenes and resources exported from text, and
## every file read as it is (JSON, the credits' text, .import and .remap files). Should
## the engine still read a released file, the page answers with a read error and names
## the file in the browser's console; nothing reads one silently.

const IMPORTED := "res://.godot/imported/"

## The imported resources held for the session, so their freed files are never read.
var held: Array[Resource] = []


## Asks the page to free the pack's bytes that the game never reads again (the files
## of collect(), and ONCE: files the game has loaded and will not load again), on the
## web. Returns the page's answer ("scheduled" when it takes the request), or why
## nothing was asked.
func release(once: Array[String]) -> String:
	if not OS.has_feature("web"):
		return "not the web"
	if not bool(JavaScriptBridge.eval("typeof window.__tiPack === 'object' && window.__tiPack !== null && typeof window.__tiPack.release === 'function'")):
		return "the page has no release (it did not load the pack itself)"
	var drop := collect()
	var page: Variant = JavaScriptBridge.get_interface("__tiPack")
	return str(page.release(JSON.stringify({"drop": drop, "once": once})))


## The imported files (res:// paths under IMPORTED) of every imported resource Godot
## holds now, each such resource held from now on (held). A resource's .import file
## names its imported files, one per texture format where there are several; all of
## them are listed.
func collect() -> PackedStringArray:
	var drop := PackedStringArray()
	for import_path: String in _import_files("res://"):
		var original := import_path.trim_suffix(".import")
		if not ResourceLoader.has_cached(original):
			continue
		var resource := ResourceLoader.get_cached_ref(original)
		var config := ConfigFile.new()
		if resource == null or config.load(import_path) != OK or not config.has_section("remap"):
			continue
		var files := PackedStringArray()
		for key: String in config.get_section_keys("remap"):
			var value: Variant = config.get_value("remap", key)
			if (key == "path" or key.begins_with("path.")) and value is String and (value as String).begins_with(IMPORTED):
				files.append(value)
		if files.is_empty():
			continue
		held.append(resource)
		drop.append_array(files)
	return drop


## Every .import file under DIRECTORY (res://), outside hidden folders such as .godot
## and folders Godot imports nothing from (.gdignore; a pack has none).
static func _import_files(directory: String) -> PackedStringArray:
	var found := PackedStringArray()
	var dir := DirAccess.open(directory)
	if dir == null or dir.file_exists(".gdignore"):
		return found
	for file: String in dir.get_files():
		if file.ends_with(".import"):
			found.append(directory.path_join(file))
	for sub: String in dir.get_directories():
		found.append_array(_import_files(directory.path_join(sub)))
	return found
