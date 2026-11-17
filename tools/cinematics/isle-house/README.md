# Treasure Island website trailer

The camera path lives in `isle_house_original_descent.gd`. The map and aerial openings descend to a low glide over the bay and close on Chester at the Isle House crosswalk. The capture camera uses its own environment with glow disabled.

Use Godot 4.7.2 and Forward+ Metal on macOS. The original map and aerial recipes use game revision `cf9192edccdf86510da35152dac5170724989365`. The eased map recipe below uses the game revision with the updated Isle House park. A different game revision can change geometry, lighting or the avatar beneath the authored camera. Exact pixels can also vary by GPU and renderer version.

| Opening | Camera |
| --- | --- |
| `aerial` | Starts 540 m above the bay at world `(-760, 540, 1740)`. Descends from the southwest without a hold, joining the established camera at frame 540 (18 seconds). Position, aim and lens ease into the same camera motion at the join. |
| `map` | Starts north up at 26 km with a 0.90-second map registration hold and a 5.9446° vertical field of view. Keeps the established map descent and approach. |
| `map-eased` | Keeps the map opening and park approach. The closing push stays on the same path and slows near Chester's eyes, then settles into the original portrait framing. |

The `map` opening spans 4,800 × 2,700 m at sea level in a 1,920 × 1,080 image. World XZ `(0, 0)` maps to `(960, 540)` at 0.4 pixels per metre. Keep the full poster height and center any horizontal crop for website map alignment.

## Capture the eased map cut

Use game revision `140968e9b0f270cc3073cefd30675e6743e7ae1e` for the park, planting and avenue grades visible in the approved cut. Set the recipe variables before following the macOS setup below.

```bash
revision=140968e9b0f270cc3073cefd30675e6743e7ae1e
opening=map-eased
```

Run the same staged capture and review gate below. The native camera sets the portrait lens directly and captures the gaze, wink and shoe contact. The capture writes `face-track.csv` beside `frames.rgb` with projected eyes, chest corners and latch positions. The finisher uses them to draw the same smile as Chester grows in frame.

```bash
python3 -B "$rig/finish_eased.py" "$out/native" "$out/Treasure Island Trailer - Softer Push and Earlier Smile.mp4"
```

If the opening proof shows the near-vertical renderer offset described below, pass `--last-nadir-frame N` with the measured last affected frame. It was frame 78 on the approved Mac capture. The output is 900 frames at 1920 × 1080 and 30 fps, silent H.264 with BT.709 color. Chester makes clear eye contact at about 25.27 seconds and starts visibly smiling at about 26.07 seconds. He winks at about 27 seconds and the shot ends at 30 seconds after a short settled smile.

The delivered edit used the matching map and park footage for its first 24 seconds. This recipe renders the whole cut from the pinned game revision and can run without an earlier MP4.

## Capture on macOS

Use a verified local Godot 4.7.2 app, Python 3 with NumPy, and FFmpeg with `libx264`. Set these absolute paths for the current clone, a new isolated checkout, the existing Godot app and a fresh output directory. Allow at least 8 GB of scratch on APFS in addition to the checkout.

For the original cuts, set `revision=cf9192edccdf86510da35152dac5170724989365` and `opening=aerial` or `opening=map`. The setup requires those recipe choices and preserves them.

```bash
rig=/absolute/path/to/current-clone/tools/cinematics/isle-house
project=/absolute/path/to/new-pinned-checkout
pinned=/absolute/path/to/Godot.app
out=/absolute/path/to/new-output
: "${revision:?Set the recipe revision first}"
: "${opening:?Set the recipe opening first}"

GIT_LFS_SKIP_SMUDGE=1 git worktree add --detach "$project" "$revision"
mkdir "$out"
git -C "$project" apply "$rig/godot-macos.patch"
cp "$rig/isle_house_original_descent.gd" "$rig/chester_capture_pose.gd" "$project/"
if [ "$opening" = map-eased ]; then
  git -C "$project" apply "$rig/capture-startup.patch"
fi
mkdir -p "$project/.tools/godot/4.7.2"
cp -R "$pinned" "$project/.tools/godot/4.7.2/Godot.app"
touch "$project/.tools/godot/4.7.2/_sc_"

python3 "$rig/run_native_slot.py" "$project" "$out/import.log" 360 -- \
  --headless --import
python3 "$rig/run_native_slot.py" "$project" "$out/parse.log" 60 -- \
  --headless --check-only --script res://isle_house_original_descent.gd
python3 "$rig/run_native_slot.py" "$project" "$out/render.log" 1800 --require-capture -- \
  --rendering-driver metal --resolution 960x540 --disable-vsync --fixed-fps 30 \
  --script res://isle_house_original_descent.gd -- "$out/native" staged "$opening"
```

Use the Mac's native engine slot A and keep the small Godot window visible. The isolated wrapper patch selects the macOS display path. For `map-eased`, the startup patch allows up to ten minutes for the world and reflections to reach play in that checkout. The runner uses the native slot lock, checks that a full capture completed and reports the actual terminal status. In staged mode, inspect `$out/native/preview` when the engine logs `SHOT_PREVIEW_READY`. Write `GO` to `$out/native/review-decision.txt` within five minutes to continue. For stills alone, use `preview` and omit `--require-capture`. The full frame stream is 900 RGB24 frames at 1920 × 1080 and 30 fps.

## Finish the trailer

Use the complete native RGB24 capture directly. The editor preserves the camera motion and uses the new take's pixels to track Chester's eyes and lip. It eases in the final portrait crop and moves the smile and wink two seconds earlier than the previous cut. A single continuous encode produces the silent 1920 × 1080 H.264 MP4 with 966 frames at 30 fps (32.2 seconds).

```bash
python3 -B "$rig/finish_no_glow.py" "$out/native/frames.rgb" "$out/Treasure Island Trailer.mp4"
ffmpeg -nostdin -n -v error -i "$out/Treasure Island Trailer.mp4" \
  -frames:v 1 -update 1 "$out/Treasure Island Trailer Poster.png"
```

For a `map` take, apply `--last-nadir-frame N` only if native frames show the initial renderer hold at exact nadir. Use the measured last affected frame. The correction stays within the fixed-azimuth portion of the map opening. The aerial opening needs no nadir correction.

If a map capture shows the isolated flare at frame 207 and its staged same-pose proof `frame-0207.png` is clean, run `python3 "$rig/repair_frame_207.py" "$out/native/frames.rgb" "$out/native/preview/frame-0207.png" "$out/repaired.rgb"` and finish from the repaired stream. This correction requires the same take's clean proof.

## Repair the aerial ending

The corrected take uses `aerial-tail` from the same capture checkout. It aims Chester's stock eye shader at the picture camera, drives the wink in that shader, and fits each rendered shoe sole to its own patch of pavement. These changes belong to the shot. The tail finisher shapes the smile and softens existing eye highlights.

Start with the 966-frame aerial MP4 made by the `aerial` recipe above, or use the original aerial MP4 if you already have it. The finisher requires the matching H.264 stream settings and a clean keyframe at frame 600 (20 seconds). It keeps the first 600 encoded video packets unchanged.

```bash
original=/absolute/path/to/aerial.mp4
python3 "$rig/run_native_slot.py" "$project" "$out/tail-render.log" 1800 --require-capture -- \
  --rendering-driver metal --resolution 960x540 --disable-vsync --fixed-fps 30 \
  --script res://isle_house_original_descent.gd -- "$out/tail" staged aerial-tail
python3 -B "$rig/finish_contact.py" "$out/tail/frames.rgb" "$out/Treasure Island Trailer - Corrected.mp4" \
  --original "$original" --work "$out/tail-encode"
```

After the staged stills pass review, write `GO` to `$out/tail/review-decision.txt`. The 310-frame tail capture includes ten frames of lead-in (590–599). The finished MP4 uses the corrected frames from 600 onward and preserves the 32.2-second runtime at 30 fps.
