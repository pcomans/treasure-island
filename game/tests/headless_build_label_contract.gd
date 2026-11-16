extends SceneTree
## The pause menu's build line (owner, 2026-11-16: "Show the build version in the
## pause menu pls"), headless, on the HUD alone:
##   - this run, from source, says "Build: source": only an export carries a stamp;
##   - the menu shows a build's stamp, read from a file as the game reads its own
##     (game/scripts/ui/build_stamp.gd): "Build 2084 (ba5ac01)", the commit's first
##     seven digits as the release's tag has them; a build without a stamp, or with
##     one that does not read, says "Build: unknown"; any stamp seen from source
##     says "Build: source";
##   - the build content audit (game/tests/shared/build_content_audit.gd) passes
##     the stamp of the build its script made, and fails a pack without a stamp,
##     another build's or commit's, and a run without the build's number and commit
##     to compare;
##   - the line is the menu's last, under Exit, in smaller type than its buttons,
##     whole, inside the panel and clear of the title and every button, the panel
##     inside the page, at the desktop frame and in a touch screen's 720 px layout
##     on an iPhone held upright and sideways;
##   - the start prompt (main.gd, on the web) hides it with the menu's other
##     buttons, and play's first start brings it back.
## The first failure stops the run.

const HUD_SCENE := "res://game/scenes/ui/hud.tscn"
const BuildStamp := preload("res://game/scripts/ui/build_stamp.gd")
const AUDIT := preload("res://game/tests/shared/build_content_audit.gd")
## The desktop frame, and an iPhone's Safari page held upright and sideways in the
## 720 px layout main.gd gives a touch browser (as headless_credits_contract.gd).
const DESKTOP := Vector2i(1440, 900)
const TOUCH_LAYOUT := Vector2i(720, 720)
const PHONE := {"upright": Vector2i(1206, 2148), "sideways": Vector2i(2622, 1110)}
## A build's stamp, as the export plugin writes it (addons/generated_world_export),
## and the line it gives.
const NUMBER := 2084
const COMMIT := "ba5ac01dc3754f25a21d42908fb230ce532be5e9"
const STAMPED := "Build 2084 (ba5ac01)"
## Where this run writes the stamps it reads, never the game's own PATH.
const STAMP_PATH := "user://test-build-stamp-%d.json"

var _failure := ""
var _hud: GameHUD
var _stamp_path := ""


func _initialize() -> void:
	create_timer(60.0, true, false, true).timeout.connect(func() -> void: _finish("The build label contract timed out."))
	_stamp_path = STAMP_PATH % OS.get_process_id()
	call_deferred("_run")


func _run() -> void:
	root.content_scale_size = DESKTOP
	root.size = DESKTOP
	_hud = (load(HUD_SCENE) as PackedScene).instantiate() as GameHUD
	root.add_child(_hud)
	await _frames(2)
	if not _require(_hud.build_label.text == "Build: source", "A run from source must say \"Build: source\", not \"%s\"." % _hud.build_label.text):
		return _finish()
	if not _check_stamps() or not _check_audit():
		return _finish()
	if not await _check_menu("desktop"):
		return _finish()
	_hud.set_touch_instructions()
	root.content_scale_size = TOUCH_LAYOUT
	for shape: String in PHONE:
		root.size = PHONE[shape]
		await _frames(2)
		var page := _hud.get_viewport_rect().size
		if not _require((page.y > page.x) == (shape == "upright") and is_equal_approx(minf(page.x, page.y), float(TOUCH_LAYOUT.x)), "The %s page laid out at %s, not %s with its short side %d px." % [shape, page, shape, TOUCH_LAYOUT.x]):
			return _finish()
		if not await _check_menu(shape):
			return _finish()
	if not await _check_start_prompt():
		return _finish()
	print("PASS: build label: a run from source says \"Build: source\"; a build shows its stamp, read as the game reads its own (\"%s\"), one without a stamp or with a broken one \"Build: unknown\", and any stamp seen from source \"Build: source\"; the content audit passes the build's own stamp and fails a missing stamp, another build's or commit's and an unset number or commit; the line is the pause menu's last, under Exit, smaller than its buttons' type, whole, inside the panel and clear of the rest, at the desktop frame and on an iPhone upright and sideways; the start prompt hides it and play's first start brings it back" % STAMPED)
	_finish()


## Each stamp file as the menu shows it in a build and from source; it ends showing
## the build's own stamp, for the checks after.
func _check_stamps() -> bool:
	var own := JSON.stringify({"build": NUMBER, "commit": COMMIT})
	# [the file's text, or null for no file; the line a build shows]
	var cases := [
		[own, STAMPED],
		[null, "Build: unknown"],
		["not json", "Build: unknown"],
		["[%d, \"%s\"]" % [NUMBER, COMMIT], "Build: unknown"],
		[JSON.stringify({"build": 0, "commit": COMMIT}), "Build: unknown"],
		[JSON.stringify({"build": 2084.5, "commit": COMMIT}), "Build: unknown"],
		[JSON.stringify({"build": str(NUMBER), "commit": COMMIT}), "Build: unknown"],
		[JSON.stringify({"build": NUMBER, "commit": COMMIT.left(6)}), "Build: unknown"],
		[JSON.stringify({"build": NUMBER, "commit": COMMIT.to_upper()}), "Build: unknown"],
		[JSON.stringify({"build": NUMBER}), "Build: unknown"],
		[own, STAMPED],
	]
	for row: Array in cases:
		DirAccess.remove_absolute(_stamp_path)
		if row[0] != null:
			var file := FileAccess.open(_stamp_path, FileAccess.WRITE)
			file.store_string(row[0])
			file.close()
		var stamp := BuildStamp.read(_stamp_path)
		_hud.show_build(stamp, false)
		var from_source := _hud.build_label.text
		_hud.show_build(stamp, true)
		if not _require(_hud.build_label.text == row[1] and from_source == "Build: source", "A stamp file %s must give \"%s\" in a build and \"Build: source\" from source, not \"%s\" and \"%s\"." % ["holding %s" % row[0] if row[0] != null else "that is missing", row[1], _hud.build_label.text, from_source]):
			return false
	var read := BuildStamp.read(_stamp_path)
	return _require(read == {"build": NUMBER, "commit": COMMIT}, "The stamp must read back as build %d, commit %s, not %s." % [NUMBER, COMMIT, read])


## The content audit's stamp check, as the build scripts run it on each pack.
func _check_audit() -> bool:
	var stamp := {"build": NUMBER, "commit": COMMIT}
	var own := AUDIT.stamp_problem(stamp, str(NUMBER), COMMIT)
	if not _require(own.is_empty(), "The content audit must pass the stamp of the build its script made, not fail it: %s" % own):
		return false
	# [the pack's stamp, TI_BUILD_NUMBER, TI_BUILD_COMMIT, what it is]
	for row: Array in [
		[{}, str(NUMBER), COMMIT, "a pack without a stamp"],
		[stamp, str(NUMBER + 1), COMMIT, "another build's stamp"],
		[stamp, str(NUMBER), COMMIT.replace("b", "c"), "another commit's stamp"],
		[stamp, "", "", "a run without the build's number and commit"],
		[stamp, "0", COMMIT, "a build number of 0"],
	]:
		if not _require(not AUDIT.stamp_problem(row[0], row[1], row[2]).is_empty(), "The content audit must fail %s." % row[3]):
			return false
	return true


## The pause menu at this window shape: the build line last, under Exit, in smaller
## type than the buttons, whole, inside the panel and clear of the title and every
## button, and the panel inside the page.
func _check_menu(shape: String) -> bool:
	_hud.set_paused(true)
	await _frames(2)
	var label := _hud.build_label
	var layout := _hud.pause_box.get_node("PauseLayout")
	var line := label.get_global_rect()
	var panel := _hud.pause_box.get_global_rect()
	var page := Rect2(Vector2.ZERO, _hud.get_viewport_rect().size)
	var clashes := PackedStringArray()
	for child: Node in layout.get_children():
		if child != label and child is Control and (child as Control).visible and (child as Control).get_global_rect().intersects(line):
			clashes.append(child.name)
	var label_px := label.get_theme_font_size("font_size")
	var button_px := _hud.exit_button.get_theme_font_size("font_size")
	var ok := _require(_hud.pause_panel.visible and label.is_visible_in_tree() and label.text == STAMPED and layout.get_child(layout.get_child_count() - 1) == label, "%s: the pause menu's last line must show \"%s\" (menu shown %s, line shown %s, \"%s\", last %s)." % [shape, STAMPED, _hud.pause_panel.visible, label.is_visible_in_tree(), label.text, layout.get_child(layout.get_child_count() - 1).name]) \
		and _require(line.position.y >= _hud.exit_button.get_global_rect().end.y and clashes.is_empty(), "%s: the build line (%s) must sit under Exit (%s), clear of the title and every button (it crosses %s)." % [shape, line, _hud.exit_button.get_global_rect(), ", ".join(clashes)]) \
		and _require(label_px < button_px, "%s: the build line must be in smaller type than the buttons (%d px, buttons %d px)." % [shape, label_px, button_px]) \
		and _require(label.size.x >= label.get_minimum_size().x and panel.encloses(line) and page.encloses(panel), "%s: the build line (%s, %.0f px of %.0f px wide) must show whole inside the panel (%s), and the panel inside the page (%s)." % [shape, line, label.size.x, label.get_minimum_size().x, panel, page])
	_hud.set_paused(false)
	return ok


## The start prompt hides the build line with the menu's other buttons; play's first
## start (its Resume) ends the prompt, and the next pause shows the line again.
func _check_start_prompt() -> bool:
	_hud.set_start_prompt("Tap to play")
	_hud.set_paused(true)
	await _frames(1)
	if not _require(_hud.pause_panel.visible and not _hud.build_label.visible and not _hud.exit_button.visible, "The start prompt must hide the build line with the menu's other buttons (menu shown %s, line shown %s, Exit shown %s)." % [_hud.pause_panel.visible, _hud.build_label.visible, _hud.exit_button.visible]):
		return false
	_hud.set_paused(false)
	_hud.set_paused(true)
	await _frames(1)
	var ok := _require(_hud.start_prompt_text().is_empty() and _hud.build_label.is_visible_in_tree() and _hud.build_label.text == STAMPED, "After the start prompt the pause menu must show the build line again (prompt \"%s\", line shown %s, \"%s\")." % [_hud.start_prompt_text(), _hud.build_label.is_visible_in_tree(), _hud.build_label.text])
	_hud.set_paused(false)
	return ok


func _frames(count: int) -> void:
	for _frame in count:
		await process_frame


func _require(condition: bool, message: String) -> bool:
	if not condition and _failure == "":
		_failure = message
	return condition


func _finish(timeout_message := "") -> void:
	DirAccess.remove_absolute(_stamp_path)
	if timeout_message != "" and _failure == "":
		_failure = timeout_message
	if _failure != "":
		push_error("FAIL: " + _failure)
		print("FAIL: " + _failure)
		quit(1)
	else:
		quit(0)
