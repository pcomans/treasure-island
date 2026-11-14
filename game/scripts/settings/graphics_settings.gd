class_name GraphicsSettings
extends RefCounted
## The frame rate limit, the 3D resolution and the frame rate display: the Options
## screen's Graphics rows with the sun shadows (owner, 2026-11-14, after playing the
## Mac build: "it clearly taxes my system quite a lot. Can we add an FPS toggle to the
## menu and also a render resolution to the graphics menu"; then "for web as well if
## possible"). A limit lets the GPU rest between frames and a lower resolution draws
## fewer pixels a frame: less heat, fan noise and battery.
##
## The defaults are the game as it was: no limit but the screen's own refresh (vsync,
## which project.godot leaves on), the world drawn at the window's full resolution
## on desktop and at three quarters on the web (its fixed scale until now), no frame
## rate shown. A choice applies at once and is kept in ShadowQuality.settings_path,
## section graphics, beside the shadow level; a test or capture driver gets the
## defaults (main.gd's use_saved_settings and player_settings_problem).
##
## The limit is Engine.max_fps. Godot 4.7.2 sleeps its main loop to that rate
## (OS::add_frame_delay, core/os/os.cpp), and on the Mac's Metal driver also shows
## each frame no sooner than 1/rate after the last (RenderingDevice::_set_max_fps,
## presentDrawableAfterMinimumDuration in drivers/metal/rendering_context_driver_metal.cpp).
## Vsync stays on, so a limit can only lower the rate: No limit is the screen's own
## (up to 120 a second on a MacBook Pro's display), and 30 and 60 divide 60 and
## 120 Hz screens evenly, so frames stay evenly spaced. A --fixed-fps run (every
## test) never sleeps for it (Main::iteration, main/main.cpp).
##
## The resolution is the window's 3D scale: the world is drawn with that share of the
## window's width and height, the HUD and menus at the window's own. Forward+ upscales
## it with AMD's FidelityFX Super Resolution 1.0 (Viewport.SCALING_3D_MODE_FSR), its
## spatial upscaler on Vulkan and Metal alike: one edge-aware upscale and sharpening
## pass, "slightly more expensive than bilinear, but it produces significantly higher
## image quality" (doc/classes/Viewport.xml). The web's Compatibility renderer has no
## FSR and keeps the project's bilinear scaling, as Godot would fall back to
## (RendererViewport::_configure_3d_render_buffers). The steps are AMD's Performance
## (50 %) and Quality (67 %) presets, three quarters (near Ultra Quality's 77 %) and
## the full window. Below full scale Godot also samples textures log2(scale) mip
## levels sharper (the same function), and MSAA, SSAO, glow and fog work on the
## smaller image.

## Each choice: its id (what the settings file keeps), its name on the Options
## screen, a line on what it does (its button's tooltip), whether the web offers it,
## and what it sets. What a choice leaves out is the game's as it started (the
## command line's or project.godot's frame limit, the window's 3D scale and mode).
const FRAME_RATES: Array[Dictionary] = [
	{"id": "30", "name": "30", "max_fps": 30, "web": true,
		"note": "At most 30 frames a second: the least work, for battery. Motion looks less smooth."},
	{"id": "60", "name": "60", "max_fps": 60, "web": true,
		"note": "At most 60 frames a second: smooth, and half the frames of a 120 Hz screen."},
	{"id": "unlimited", "name": "No limit", "web": true,
		"note": "As many frames as the screen shows: up to 120 a second on a MacBook Pro."},
]
const RESOLUTIONS: Array[Dictionary] = [
	{"id": "50", "name": "50%", "scale": 0.5, "web": true,
		"note": "The world drawn at half the width and height: a quarter of the pixels, softer."},
	{"id": "67", "name": "67%", "scale": 0.67, "web": true,
		"note": "The world drawn at two thirds of the width and height: under half the pixels."},
	{"id": "75", "name": "75%", "scale": 0.75, "web": true,
		"note": "The world drawn at three quarters of the width and height: just over half the pixels."},
	{"id": "100", "name": "100%", "web": true,
		"note": "The world drawn at the screen's full resolution: the sharpest."},
]
const SECTION := "graphics"
const FRAME_RATE_KEY := "frame_rate"
const RESOLUTION_KEY := "resolution"
const SHOW_FRAME_RATE_KEY := "show_frame_rate"

## The frame limit and the window's 3D scale and mode as the game started, taken by
## the first one made: a choice that leaves them out puts them back, however often
## main is made in one run.
static var _started := {}

## The window whose 3D scale a resolution sets.
var window: Viewport
## The choices on now, as defaults() lays them out ({} until apply).
var current := {}


func _init(game_window: Viewport) -> void:
	window = game_window
	if _started.is_empty():
		_started = {"max_fps": Engine.max_fps, "scale": window.scaling_3d_scale, "mode": int(window.scaling_3d_mode)}


## The frame rate limits (FRAME_RATE_KEY) or resolutions (RESOLUTION_KEY) this
## platform offers, in order: all of them, or the web's.
static func offered(key: String, web := OS.has_feature("web")) -> Array:
	var choices: Array = FRAME_RATES if key == FRAME_RATE_KEY else RESOLUTIONS
	return choices.filter(func(choice: Dictionary) -> bool: return not web or bool(choice.web))


## The choices of a player who never made one: the game as it was.
static func defaults(web := OS.has_feature("web")) -> Dictionary:
	return {FRAME_RATE_KEY: "unlimited", RESOLUTION_KEY: "75" if web else "100", SHOW_FRAME_RATE_KEY: false}


## The offered frame rate limit or resolution with this id, or {}.
static func find(key: String, id: String) -> Dictionary:
	for choice: Dictionary in offered(key):
		if choice.id == id:
			return choice
	return {}


## The choices, each one missing, unknown or not offered here at its default.
static func valid(choices: Dictionary) -> Dictionary:
	var kept := defaults()
	for key: String in [FRAME_RATE_KEY, RESOLUTION_KEY]:
		var id := str(choices.get(key, ""))
		if not find(key, id).is_empty():
			kept[key] = id
	if choices.get(SHOW_FRAME_RATE_KEY) is bool:
		kept[SHOW_FRAME_RATE_KEY] = choices[SHOW_FRAME_RATE_KEY]
	return kept


## The choices kept in the settings file; any missing or unknown, its default.
static func saved() -> Dictionary:
	var file := ConfigFile.new()
	if file.load(ShadowQuality.settings_path) != OK:
		return defaults()
	var kept := {}
	for key: String in defaults():
		if file.has_section_key(SECTION, key):
			kept[key] = file.get_value(SECTION, key)
	return valid(kept)


## Keeps the choices for the next run, with whatever else the file holds. Where
## storage is unavailable (a private browser window) this quietly keeps nothing.
static func save(choices: Dictionary) -> void:
	var file := ConfigFile.new()
	file.load(ShadowQuality.settings_path)
	var kept := valid(choices)
	for key: String in kept:
		file.set_value(SECTION, key, kept[key])
	file.save(ShadowQuality.settings_path)


## What the choices set: the frame limit (Engine.max_fps, 0 for none) and the
## window's 3D scale and scaling mode, each choice's own over the game's as it
## started. Below full scale Forward+ upscales with FSR; Compatibility keeps its mode.
func settings_of(choices: Dictionary) -> Dictionary:
	var on := valid(choices)
	var rate := find(FRAME_RATE_KEY, on[FRAME_RATE_KEY])
	var resolution := find(RESOLUTION_KEY, on[RESOLUTION_KEY])
	var upscaled := resolution.has("scale") and RenderingServer.get_current_rendering_method() != "gl_compatibility"
	return {
		"max_fps": int(rate.get("max_fps", _started.max_fps)),
		"scale": float(resolution.get("scale", _started.scale)),
		"mode": int(Viewport.SCALING_3D_MODE_FSR) if upscaled else int(_started.mode),
	}


## Puts the choices on at once, any missing, unknown or not offered at its default.
## The frame rate display is the HUD's (main.gd shows it from current).
func apply(choices: Dictionary) -> void:
	var settings := settings_of(choices)
	Engine.max_fps = settings.max_fps
	window.set("scaling_3d_mode", settings.mode)
	window.scaling_3d_scale = settings.scale
	current = valid(choices)
