extends SceneTree
const ADOPTION = preload("res://game/scripts/world/facades/housing_family_live_attachment.gd")

func _initialize() -> void:
	var path := "game/scripts/world/facades/housing_site_family.gd"
	var digest := FileAccess.get_sha256("res://" + path)
	var valid: Dictionary = ADOPTION.dependency_representation(path, digest)
	var checks: Array[bool] = [
		bool(valid.get("ok", false)) and str(valid.get("kind", "")) == "source",
		not bool(ADOPTION.dependency_representation(path, "0".repeat(64)).get("ok", false)),
		not bool(ADOPTION.dependency_representation("game/scripts/world/world_loader.gd", digest).get("ok", false)),
		not bool(ADOPTION.dependency_representation("game/scripts/missing-family-dependency.gd", digest).get("ok", false)),
		not bool(ADOPTION.dependency_representation("../project.godot", digest).get("ok", false)),
	]
	if false in checks:
		push_error("Family source dependency representation checks failed: " + str(checks))
		quit(1)
		return
	print("PASS: family source SHA, wrong bytes/target/path and missing dependency rejection; exported representation requires actual signed package")
	quit(0)
