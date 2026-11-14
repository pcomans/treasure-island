# Sound effects

Every sound effect in the game is generated with ElevenLabs from the prompts in
[prompts.json](prompts.json) (owner decisions, 2026-11-14). The game's audio is
a projection of these prompts: anyone with an ElevenLabs key can run them. The
prompts and the tool are public; the audio they make stays private.
ElevenLabs' terms forbid making output available "as isolated audio files or
samples" (ElevenCreative Terms, Exhibit 4 §2), and this repository is public.
`.gitignore` keeps audio files and their Godot `.import` files out of Git, and
`tools/check_sfx.mjs` (part of `tools/test.sh`) fails if any is tracked.

Nothing here plays sound in the game yet. The audio driver is still `Dummy`,
and wiring the sounds in is separate work.

## Run it

```sh
tools/generate-sfx --out ~/ti-sfx                  # dry run: credits per sound, per tier, total
tools/generate-sfx --out ~/ti-sfx --generate       # make every candidate not yet in ~/ti-sfx
tools/generate-sfx --out ~/ti-sfx --generate --tier 1 --concurrency 3
tools/generate-sfx --out ~/ti-sfx --generate --force-id jet_loop   # a fresh set; the old one is kept aside
tools/generate-sfx --out ~/ti-sfx --process        # trim, loop, normalise, Ogg Vorbis (needs ffmpeg)
```

- **Cost.** Nothing is requested or charged without `--generate`. A
  generation costs 40 credits a second of its set length, and every candidate
  is a generation. The whole sheet is 305 generations, 27,088 credits on
  2026-11-14, about a fifth of a Creator month (121,000). The dry run prints
  the current figures.
- **Key and output folder.** `--generate` reads `ELEVENLABS_API_KEY` from the
  environment, or from `~/.config/elevenlabs/.env` as
  `ELEVENLABS_API_KEY=...`. It never prints or logs the key. `--out` is
  required and is refused inside any Git work tree.
- **Calling the API.** It calls `POST https://api.elevenlabs.io/v1/sound-generation`
  with `model_id` always set, since the API still defaults to v2. It runs at
  most the plan's 6 requests at once. On a 429 or 5xx it waits (Retry-After,
  else a doubling wait) and tries again. Any other error stops the run,
  because a request that reached ElevenLabs may already have been charged.
- **Resuming.** A candidate already on disk is never requested again, so a
  stopped run resumes where it stopped. Files are written to `.part` and then
  renamed, so a half-written download never counts as made. If the sheet's
  prompt or settings for a row change after its candidates were made, the dry
  run says so; `--force-id` then makes a fresh set and moves the old one to
  `candidates/<id>/replaced-<time>/`.
- **Picking takes.** Listen to the candidates. Then, optionally, list the
  keepers in `~/ti-sfx/picks.json`, for example
  `{"footstep_hard": [3, 1, 4, 6, 8, 9, 12, 15]}`, in take order. Without
  picks, `--process` uses the first candidates on disk.
- **Processing.** `--process` turns each kept take into
  `~/ti-sfx/game/<group>/<name>_NN.ogg`, mono for positional sounds and
  stereo for the two ambience beds. The candidates themselves are only read,
  never changed.

What the output folder holds:

| Path | What |
|---|---|
| `candidates/<id>/<id>.cNN.wav` or `.mp3` | ElevenLabs' answer, one file a generation (WAV 48 kHz for one-shots; MP3 192 kbps for loops, the only format the docs offer for them) |
| `generation-log.jsonl` | A line a generation: time, id, candidate, file, prompt, model, settings, credits, status |
| `picks.json` | Optional, by hand: the candidates kept, in take order |
| `game/<group>/<name>_NN.ogg` | The processed takes |

## The sheet

Each row of `sounds` is one family of files. Its fields:

- `id`: a stable name.
- `tier`: 1 (feels wrong without it), 2 (clearly adds) or 3 (nice to have),
  from the 2026-11-14 code inventory.
- `events`: the event ids it serves.
- `prompt`: the text sent.
- `duration_seconds`, `loop`, `prompt_influence`: sent as they are.
- `keep_takes`: the variations the game keeps.
- `candidates_per_take`: how many are generated for each take kept.
- `output`: the file pattern.
- `recipe`: the post-processing to apply.
- `notes`: optional reasoning.

`recipes` holds the post-processing steps as data: channels, silence trims,
a length cap, fades, a loop crossfade and a peak level. The peak is measured
after encoding, because Vorbis overshoots bright transients by up to about
2.6 dB. `events` lists every sound-carrying event in the code (P player, V
vehicle, B ball, A ambient, U interface). Every event is served by a row or
listed in `not_voiced` with the reason; the check enforces this.

## How the prompts are written

- **Realistic.** The player is a real wooden treasure chest of gold coins with
  iron straps, brass fittings and big leather-soled shoes, flying on a small
  twin-nozzle rocket backpack. Cars and the world are realistic too.
- **One car.** Every prompt that mentions a car names the 2014 Toyota RAV4
  with its standard 2.5-liter four-cylinder gasoline engine. This is a
  production inference: the crossover is the island's most common parked
  body, and the RAV4 hybrid came later, so the engine stays audible. All cars
  share one sound set to start.
- **Scope.** No music, and no sounds for things the game does not model: no
  horn, gulls, foghorn, traffic or ferry engine. Spraying was removed from the
  game, so it has no sound. A "ready" sting at load would be music, so the
  ambience fading in marks it instead.
- **ElevenLabs' guidance.** One sound per prompt. Each prompt describes the
  action, setting and performance in one short sentence (at most 450
  characters) with recording-quality words. A prompt never asks for a number
  of repetitions: one footstep per generation, and a sequence such as
  door, engine, door is several prompts. The length, looping and prompt
  influence are set per row rather than described in the text. The validator
  rejects "loop", "seamless", a length or a repetition count in a prompt.
- **Wording.** Prompts use US English (tire, curb, gasoline), as sound
  libraries word them. They leave out place names that would invite gulls
  or traffic.

## Hard cases

Each case uses generated one-shots and loops plus volume and pitch changes in
the engine:

- **Engine following speed and throttle.** There are three steady loops of
  the same car from the same place behind it: idle, low and high. The game
  crossfades them by a virtual rev made from throttle and speed over top
  speed, and pitches each within about a third of an octave, never one loop
  across the range. Three candidates each are generated so a matching trio
  can be picked.
- **Skid.** One loop runs whenever the car is driven. Its gain follows the
  smoothed slip and the handbrake (about 50 ms up, 150 ms down), so a
  flickering drift never restarts a sound. Hard braking that slides uses the
  same loop.
- **Jetpack.** There are three parts: a start that fades out under a sustain
  loop, the sustain loop itself, and a stop tail. The loop's gain follows
  the flame's 0.04 s attack and 0.07 s release, so taps of any length work.
  A tap too soon after the last one skips the start. The 12 Hz lid rattle is
  its own loop under the jet, kept apart because each prompt is one sound.
- **Long ambience beds.** The 30 s cap per generation is each bed's length:
  generated with `loop` set, then crossfaded over 2 s at the seam whatever
  the generator delivered. The water bed's gain follows the distance to the
  shore, updated at a low rate. The wind bed is louder with height.
- **Footsteps at up to 10 a second.** Each footstep is generated alone at the
  0.5 s minimum length and cut to its transient (at most 0.3 s). Eight takes
  are kept for each of the two surfaces the ground data tells apart. The
  game picks a random take, never the same one twice running, with slight
  pitch and volume jitter.
