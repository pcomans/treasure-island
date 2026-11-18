extends SceneTree
## The game's side of freeing the game data pack's bytes on the web
## (game/scripts/web/pack_release.gd; the page's side, game/web/shell.html, is checked by
## tools/check_web_build_files.mjs), natively, on the project's own imports:
##   - collect() lists, for an imported resource Godot holds, every imported file of it
##     (the ones its .import file's [deps] dest_files names, one per texture format), and
##     holds the resource: let go everywhere else, it stays in Godot's cache and load()
##     gives the same resource, so its files are never read again. A resource let go
##     without that hold leaves the cache (so a held one stays only because it is held);
##   - an imported resource that is not loaded is neither listed nor held, and nothing
##     outside res://.godot/imported/ is listed (scripts, scenes, .tres, JSON stay);
##   - release() off the web asks the page nothing and says so.
## The first failure stops the run.

const PACK_RELEASE := preload("res://game/scripts/web/pack_release.gd")
## A texture with a file per texture format (s3tc and etc2), loaded and held.
const HELD := "res://game/resources/mersea/brass_albedo.png"
## A texture the run never loads.
const UNLOADED := "res://game/resources/mersea/brass_normal.png"
## A texture loaded and let go without the hold.
const LET_GO := "res://game/resources/mersea/brass_roughness.png"

var _failure := ""


func _initialize() -> void:
	create_timer(60.0, true, false, true).timeout.connect(func() -> void: _finish("The pack release contract timed out."))
	call_deferred("_run")


func _run() -> void:
	for path: String in [HELD, UNLOADED, LET_GO]:
		if ResourceLoader.has_cached(path):
			_finish("%s is in Godot's cache before the run loads it." % path)
			return
	var texture: Resource = load(HELD)
	var texture_id := texture.get_instance_id() if texture != null else 0
	if texture == null:
		_finish("%s does not load." % HELD)
		return
	var release := PACK_RELEASE.new()
	var drop := release.collect()
	var expected := _dest_files(HELD)
	if expected.size() < 2:
		_finish("%s.import names %d imported files, not one per texture format." % [HELD, expected.size()])
		return
	for file: String in expected:
		if not drop.has(file):
			_finish("collect() did not list %s, an imported file of %s, which Godot holds." % [file, HELD])
			return
	for file: String in _dest_files(UNLOADED):
		if drop.has(file):
			_finish("collect() listed %s, though %s was never loaded." % [file, UNLOADED])
			return
	for file: String in drop:
		if not file.begins_with(PACK_RELEASE.IMPORTED):
			_finish("collect() listed %s, which is not an imported file." % file)
			return
	if not release.held.any(func(held: Resource) -> bool: return held.get_instance_id() == texture_id):
		_finish("collect() listed %s's files but does not hold it." % HELD)
		return
	if release.held.any(func(held: Resource) -> bool: return held.resource_path == UNLOADED):
		_finish("collect() holds %s, which was never loaded." % UNLOADED)
		return
	texture = null
	if not ResourceLoader.has_cached(HELD) or load(HELD).get_instance_id() != texture_id:
		_finish("%s, held by collect() and let go elsewhere, left Godot's cache, so a later load would read its released files." % HELD)
		return
	var other: Resource = load(LET_GO)
	if other == null:
		_finish("%s does not load." % LET_GO)
		return
	other = null
	if ResourceLoader.has_cached(LET_GO):
		_finish("%s, let go without a hold, is still in Godot's cache: the check above would pass without the hold." % LET_GO)
		return
	var answer := release.release([])
	if answer != "not the web":
		_finish("release() off the web answered %s, not \"not the web\"." % answer)
		return
	print("PASS: collect() lists the %d imported files of the %d imported resources Godot holds (both of %s's) and holds them, so a later load() comes from the cache; nothing unloaded or outside res://.godot/imported/; release() asks nothing off the web" % [drop.size(), release.held.size(), HELD.get_file()])
	_finish("")


## The imported files a source project's .import file lists for PATH ([deps] dest_files).
func _dest_files(path: String) -> PackedStringArray:
	var config := ConfigFile.new()
	if config.load(path + ".import") != OK:
		return PackedStringArray()
	return PackedStringArray(config.get_value("deps", "dest_files", []))


func _finish(failure: String) -> void:
	if not failure.is_empty() and _failure.is_empty():
		_failure = failure
		push_error("FAIL: " + failure)
	quit(1 if not _failure.is_empty() else 0)
