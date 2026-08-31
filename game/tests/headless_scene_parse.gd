extends SceneTree

const SCENES := [
	"res://game/scenes/world/world_root.tscn",
	"res://game/scenes/player/player.tscn",
	"res://game/scenes/ui/hud.tscn",
	"res://game/scenes/main.tscn",
]


func _initialize() -> void:
	for path: String in SCENES:
		var resource := ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE)
		if resource == null or not resource is PackedScene:
			push_error("Could not parse scene: %s" % path)
			quit(1)
			return
	print("PASS: parsed %d gameplay scenes" % SCENES.size())
	quit(0)
