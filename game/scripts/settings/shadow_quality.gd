class_name ShadowQuality
extends RefCounted
## The sun's shadow quality, the setting on the pause menu's Options screen (owner,
## 2026-11-12: "right now the shadows are pretty rough ... make that sort of an
## options item"). Medium is the game as it was: main.tscn's Sun and the shadow
## map and filter project.godot gives the engine, read when this is made, so it
## stays whatever those say. Medium's nearest split reaches 40 m on a quarter of a
## 4096 px map, about 5.5 cm by 10 cm of ground per shadow texel with the sun 33
## degrees up: coarser than the avatar's 8-9 cm legs and a palm's leaflets, which the
## owner saw as chunky and pixelated (2026-11-12). High doubles the map, uses a
## smoother filter and pulls that split in to 16 m, the next ending at 48 m and the
## third at 200 m: near the player about a fifth of Medium's texel, out to about
## 120 m still finer, and from about 120 to 240 m a little softer (computed: the
## smoother filter spreads wider there). Tried and not offered
## (2026-11-12): only doubling the map (a modest step), Medium's map with its nearest
## split at 24 m (sharper inside, softer just past it), and giving the sun a size
## (palm shadows blurred far more than the real sun's). Low and Off are for a slow
## machine. The web keeps Off, its default, and offers nothing else, so it has no
## Options item: in the Compatibility renderer sun shadows also brightened every
## sunlit surface by about 40% (2026-11-12, native Compatibility on the dev
## machine), unlike desktop's Forward+.
## A change applies at once, with no restart; the choice is kept in settings_path
## between runs, and where storage fails it lasts the session (save quietly fails).

## Each level: its id (what the settings file keeps), its name on the Options
## screen, a line on what it does, whether the web offers it, and what it sets.
## What a level leaves out is Medium's (the scene's Sun or project.godot's):
##   enabled: the sun casts shadows at all;
##   atlas: the directional shadow map's size (px), which the sun's splits share;
##   filter: the soft-shadow filter (RenderingServer.ShadowQuality);
##   mode: the splits (DirectionalLight3D.ShadowMode);
##   splits: the split distances, as shares of max_distance;
##   max_distance: how far from the camera the sun casts shadows (m).
## Low keeps Medium's map and filter, so what shadows it draws look like Medium's
## (a smaller map and the cheapest filter striped, dithered and crawled, review of
## 2026-11-12); it is lighter by drawing two splits out to 200 m instead of four
## to 800 m.
const LEVELS: Array[Dictionary] = [
	{"id": "off", "name": "Off", "web": true, "enabled": false,
		"note": "No sun shadows. The lightest choice, for a slow machine."},
	{"id": "low", "name": "Low", "web": false,
		"mode": DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS, "splits": [0.2, 0.2, 0.2], "max_distance": 200.0,
		"note": "Shadows nearby only, none in the distance. Lighter, for a slow machine."},
	{"id": "medium", "name": "Medium", "web": false,
		"note": "The game's usual shadows."},
	{"id": "high", "name": "High", "web": false, "atlas": 8192, "filter": RenderingServer.SHADOW_QUALITY_SOFT_HIGH,
		"splits": [0.02, 0.06, 0.25],
		"note": "Sharper shadows near you: your own, a palm's fronds. Costs a little more."},
]
const SECTION := "graphics"
const KEY := "shadow_quality"

## The player's settings file.
const DEFAULT_SETTINGS_PATH := "user://settings.cfg"
## The settings file in use; a test points it at its own.
static var settings_path := DEFAULT_SETTINGS_PATH

var sun: DirectionalLight3D
## Where the engine's shadow map and filter settings go: the RenderingServer, or a
## test's stand-in that records them.
var server: Object = RenderingServer
## The level on now ("" until one is applied).
var current := ""
## Medium's settings: the scene Sun's and project.godot's, as this was made.
var _medium := {}


func _init(scene_sun: DirectionalLight3D) -> void:
	sun = scene_sun
	_medium = {
		"enabled": sun.shadow_enabled,
		"mode": sun.directional_shadow_mode,
		"splits": [sun.directional_shadow_split_1, sun.directional_shadow_split_2, sun.directional_shadow_split_3],
		"max_distance": sun.directional_shadow_max_distance,
		"atlas": int(ProjectSettings.get_setting_with_override("rendering/lights_and_shadows/directional_shadow/size")),
		"bits_16": bool(ProjectSettings.get_setting_with_override("rendering/lights_and_shadows/directional_shadow/16_bits")),
		"filter": int(ProjectSettings.get_setting_with_override("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality")),
	}


## The levels this platform offers, in order: all of them, or the web's.
static func offered() -> Array:
	var web := OS.has_feature("web")
	return LEVELS.filter(func(level: Dictionary) -> bool: return not web or bool(level.web))


## The level a player who never chose one gets: the game as it was, Medium, or on
## the web Off.
static func default_id() -> String:
	return "off" if OS.has_feature("web") else "medium"


static func is_offered(id: String) -> bool:
	return offered().any(func(level: Dictionary) -> bool: return level.id == id)


## The level kept in the settings file, if this platform offers it; else the default.
static func saved_id() -> String:
	var file := ConfigFile.new()
	if file.load(settings_path) == OK:
		var id := str(file.get_value(SECTION, KEY, ""))
		if is_offered(id):
			return id
	return default_id()


## Keeps the level for the next run, with whatever else the file holds. Where
## storage is unavailable (a private browser window) this quietly keeps nothing.
static func save_id(id: String) -> void:
	var file := ConfigFile.new()
	file.load(settings_path)
	file.set_value(SECTION, KEY, id)
	file.save(settings_path)


## What the level sets: its own settings over Medium's.
func settings_of(id: String) -> Dictionary:
	for level: Dictionary in LEVELS:
		if level.id == id:
			return _medium.merged(level, true)
	return {}


## Puts the level on at once: the sun's shadow settings, the shadow map's size and
## the soft-shadow filter. A level this platform doesn't offer puts on the default.
func apply(id: String) -> void:
	if not is_offered(id):
		id = default_id()
	var settings := settings_of(id)
	var splits: Array = settings.splits
	sun.shadow_enabled = bool(settings.enabled)
	sun.set("directional_shadow_mode", int(settings.mode))
	sun.directional_shadow_split_1 = float(splits[0])
	sun.directional_shadow_split_2 = float(splits[1])
	sun.directional_shadow_split_3 = float(splits[2])
	sun.directional_shadow_max_distance = float(settings.max_distance)
	# The engine ignores a size or filter it already has.
	server.directional_shadow_atlas_set_size(int(settings.atlas), bool(settings.bits_16))
	server.directional_soft_shadow_filter_set_quality(int(settings.filter))
	current = id
