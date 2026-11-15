# Treasure Island website trailer

This capture starts north up at 26 km, descends over Treasure Island, glides above the bay, and closes on Chester at the Isle House crosswalk. The camera path lives in `isle_house_original_descent.gd`. It samples the original overview through frame 449, then blends into the low approach. The visual corrections and Chester's expression are applied to the captured frames.

The delivered shot was rendered from game revision `f72d6b212708759a7d3a558fdd25dac3ad5cbf32` with Godot 4.7.2 and Forward+ Metal on macOS. Use that revision for the original scene. A newer game checkout can change assets, lighting, and nearby geometry even if the authored camera is identical. Exact pixels can also vary across GPUs and renderer versions.

| Time | Camera |
| --- | --- |
| 0:00–0:00.90 | Map registration hold, north up at 26 km, 5.9446° vertical field of view |
| 0:00.90–0:15 | Island descent to the original overview, with gradual lens opening and roll |
| 0:15–0:24 | Blend from the overview into a low sweep above the bay |
| 0:24–0:30 | Approach the grounded avatar at the Isle House crosswalk |

The sea-level map span is 4,800 × 2,700 m at 1,920 × 1,080 pixels. World XZ `(0, 0)` maps to `(960, 540)` at 0.4 px/m. Keep the full poster height and center any horizontal crop for website map alignment.

## Capture a clean base

Use macOS, a verified local Godot 4.7.2 app, Python 3 with NumPy, and FFmpeg with `libx264`. Set these absolute paths for the current clone, a new isolated checkout, the existing Godot app and a fresh output directory. Allow at least 8 GB of scratch on APFS in addition to the checkout.

```bash
rig=/absolute/path/to/current-clone/tools/cinematics/isle-house
project=/absolute/path/to/new-pinned-checkout
pinned=/absolute/path/to/Godot.app
out=/absolute/path/to/new-output

GIT_LFS_SKIP_SMUDGE=1 git worktree add --detach "$project" f72d6b212708759a7d3a558fdd25dac3ad5cbf32
mkdir "$out"
git -C "$project" apply "$rig/godot-macos.patch"
cp "$rig/isle_house_original_descent.gd" "$project/"
mkdir -p "$project/.tools/godot/4.7.2"
cp -R "$pinned" "$project/.tools/godot/4.7.2/Godot.app"
touch "$project/.tools/godot/4.7.2/_sc_"

python3 "$rig/run_native_slot.py" "$project" "$out/import.log" 360 -- \
  --headless --import
python3 "$rig/run_native_slot.py" "$project" "$out/parse.log" 60 -- \
  --headless --check-only --script res://isle_house_original_descent.gd
python3 "$rig/run_native_slot.py" "$project" "$out/render.log" 1800 -- \
  --rendering-driver metal --resolution 960x540 --disable-vsync --fixed-fps 30 \
  --script res://isle_house_original_descent.gd -- "$out/native" staged
```

Use the Mac's native engine slot A and keep the small Godot window visible. The isolated wrapper patch selects the macOS display path. The runner uses the native slot lock and reports the actual terminal status. In staged mode, inspect `$out/native/preview` when the engine logs `SHOT_PREVIEW_READY`. Write `GO` to `$out/native/review-decision.txt` within five minutes to continue to the full capture. Use `preview` instead of `staged` for stills alone. The full frame stream is RGB24 at 1920 × 1080, 30 fps, for 900 frames.

```bash
python3 "$rig/finish_capture.py" "$out/native/frames.rgb" "$out/finished.rgb"
"$rig/encode.sh" "$out/finished.rgb" "$out/clean-base.mp4"
```

`finish_capture.py` eases the final 1.25× portrait crop in over frames 777–876. If the new native capture shows the renderer's initial nadir hold, add `--last-affected N` with the measured last affected frame. The delivered take used `78`; the correction is limited to the fixed-azimuth portion. If this take shows the isolated flare at frame 207 and its staged same-pose `frame-0207.png` is clean, run `python3 "$rig/repair_frame_207.py" "$out/finished.rgb" "$out/native/preview/frame-0207.png" "$out/repaired.rgb"` and encode the repaired stream instead.

## Finish the trailer

Pass the 900-frame clean, portrait-reframed base to the editor. This also works with an existing clean base from the pinned capture.

```bash
python3 "$rig/reproduce_edit.py" "$out/clean-base.mp4" "$out/Treasure Island Trailer.mp4"
ffmpeg -nostdin -n -v error -i "$out/Treasure Island Trailer.mp4" \
  -frames:v 1 -update 1 "$out/Treasure Island Trailer Poster.png"
```

The editor first draws Chester's direct gaze and wide grin, then moves the smile and wink 60 frames (2.0 s) earlier. The grin begins during the moving portrait at about 28.13 s. The wink begins around 29.1 s. Both eyes reopen for the final hold. The edit tracks the eyes and lid on the moving frames, keeps the underlying camera motion, and outputs a silent H.264 MP4 with 966 frames at 30 fps (32.2 s). Use a new output path and allow about 6 GB of scratch beside it. To replay only the 60-frame timing edit, add `--wide-base /absolute/path/to/reviewed-wide-smile.mp4` and provide the same clean base.

The editor preserves the earlier encoded frames by copying packets. If a newly encoded base chooses a different B-frame order at either splice, the editor rejects the cut before publishing the output. The reviewed base and wide-smile cut work with these splices.
