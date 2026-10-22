# Godot 4 Third Person Controller — mobile input port

MIT source: https://github.com/selgesel/godot4-third-person-controller
Revision: c809ec20fd8170f4a81f3d8964e8a9838f8b29da (checked 2026-10-22).
Retained LICENSE accompanies the scripts. Original paths: ui/VirtualThumbStick.gd,
ui/VirtualButton.gd, player/MobileControls.gd; five matching images from assets/
are in game/resources/ui/selgesel. No full character controller was imported.

Thumbstick retains upstream fixed-center analog math and ring/arrow animation;
changes rename class/input entrypoint, fix its drag guard, handle cancellation,
add release/reset and a 0.12 radial deadzone. Buttons retain upstream action,
texture and color behavior; changes rename class/input entrypoint, fix the Godot4
handled-input API, keep one owner finger and handle cancellation.

MobileControls retains movement/camera output and upstream0.1 degrees per logical
pixel camera math. Swimming/player-state, extra buttons and pinch zoom were
removed. Look deltas use the tracked finger’s previous/current logical positions: the
first hosted four-finger trial produced a large jump from event.relative despite
a small owner-finger move. Explicit routing excludes stick/buttons from one right-side look finger;
pause/focus releases all. touch_controls.gd supplies layout and stock-camera/vector
mapping. Player physics is retained; only touch movement preserves analog strength.
This older upstream template does not claim Godot4.7 web or iPad Safari support;
our checks and owner device feel are separate from upstream provenance.
