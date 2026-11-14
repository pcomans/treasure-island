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
  is a generation. The dry run prints each sound's credits, each tier's and
  the total, and what is still to make.
- **Key and output folder.** `--generate` reads `ELEVENLABS_API_KEY` from the
  environment, or from `~/.config/elevenlabs/.env` as
  `ELEVENLABS_API_KEY=...`. It never prints or logs the key. `--out` is
  required and is refused unless git confirms the folder lies outside every
  repository; if git is missing or will not answer, the folder is refused.
- **Calling the API.** It calls `POST https://api.elevenlabs.io/v1/sound-generation`
  with `model_id` always set, since the API still defaults to v2.
  `ELEVENLABS_API_BASE` may pick another of the API's documented hosts
  (`api.us.elevenlabs.io` or the EU, India and Singapore
  `*.residency.elevenlabs.io` hosts) or plain http on this machine's loopback
  (the offline check's stand-in). Nothing else is accepted, and a host other
  than the default is printed.
- **Retries and errors.** It runs at most the plan's 6 requests at once. Only
  a 429 or 503 (the request was not processed) or a connection that never
  opened is tried again, after Retry-After or a doubling wait. Any other
  answer stops the run, a 504 or an answer lost while it was read included,
  because that request may already have been charged. A redirect is never
  followed, since the key would go with it. Every request leaves a line in
  the generation log, whatever became of it.
- **One run at a time.** A `--generate` run holds `.generate.lock` in the
  output folder, and a second run there is refused. If a run was killed and
  left its lock, the tool says so and leaves the lock alone; delete it by hand
  once no run is using the folder. On Linux the tool also tells a running
  `tools/generate-sfx` owner from a pid that was reused. The lock stores the
  owner's start in clock ticks since boot, compared exactly, so a change to
  the wall clock does not matter. Either way its message names the lock file
  to delete.
- **Stopping.** SIGTERM, SIGHUP (a closed terminal) or a first Ctrl-C starts
  no new requests, lets the ones in flight finish, saves their audio and
  releases the lock. A second Ctrl-C quits at once, losing those requests.
  Output that can no longer be written (a closed pipe or terminal) is dropped,
  and the exit code still reports the run.
- **Resuming.** A candidate already on disk is never requested again, so a
  stopped run resumes where it stopped; the stop message prints the command.
  Files are written to `.part` and then renamed, so a half-written download
  never counts as made.
- **A fresh set.** If the sheet's prompt or settings for a row change after
  its candidates were made, the dry run names the candidates made otherwise
  (the generation log records each one's prompt and settings). `--force-id`
  then makes a fresh set and moves every earlier candidate file of that row to
  `candidates/<id>/replaced-<time>/`: they are kept, never deleted, including
  any numbered past the row's current count. So that a rerun of the same
  command cannot pay for a set twice, `--force-id` is refused in two cases:
  - **Unfinished.** The fresh set is not complete yet. The command without
    `--force-id` finishes it.
  - **Already current.** The set is complete, and the generation log shows
    every candidate in it was made with the sheet's current prompt, length,
    loop, influence, model and format. Add `--force-again` to pay for a fresh
    set anyway.
- **More candidates.** Raising a row's `candidates_per_take` adds the missing
  numbers beside the candidates already made, which stay as they are, and
  their picks keep their meaning. New candidates use the row's current
  prompt, and the generation log names the prompt of each, so one set may mix
  prompts. `ball_kick_hard` does this: the owner picked its c02, made from the
  earlier prompt, and c07 to c12 come from the reworded one.
- **Picking takes.** Listen to the candidates. Then, optionally, list the
  keepers in `~/ti-sfx/picks.json`, for example
  `{"footstep_hard": [3, 1, 4, 6, 8, 9, 12, 15]}`, in take order. For a row
  without picks, the audition notes and the generation log decide (below). An
  id that is not in the sheet, such as a dropped row's, is named and ignored.
  A list that cannot be right, such as a candidate number past the row's
  count, fails that row alone.
  - **Fewer picks.** A row may pick fewer takes than its `keep_takes`, and the
    game then gets exactly those. Nothing is padded with unpicked candidates,
    and the row's older takes beyond them are removed. `keep_takes` stays the
    most a row keeps, so candidate numbers and existing picks keep their
    meaning. Lowering it to match the picks would shrink the range of
    candidates, and a pick such as `tree_springback` [6] (3 takes x 2) would
    then fall outside it.
  - **Picks across a fresh set.** Picks name candidates of the set they were
    made from. When `--force-id` sets a picked row's candidates aside, it
    first records the row's picks in `candidates/<id>/.picks-before-force.json`
    and says so. While every pick in `picks.json` for the row is one of those
    recorded numbers, in any order or fewer of them, `--process` refuses the
    row: the candidates with those numbers are new and unheard. A refused row
    keeps its takes and its entry in `game/sfx.json`, so the earlier takes keep
    playing. Pick again from the fresh set to proceed. If only recorded
    numbers are right in the fresh set too, deleting the record, as the
    message says, is the only way past the check. File times play no part in
    this, so saving `picks.json` for another row or copying the folder changes
    nothing.
  - **Audition notes.** The audition pages keep
    `~/ti-sfx/audition-notes.json` beside `picks.json`, one entry an id:

    ```json
    {
      "landing": {
        "none_good": true, "note": "sounds like a tiny chest", "updated": "2026-11-14T06:08:08.860Z",
        "round2": { "still_not_right": false, "note": "better", "updated": "2026-11-14T08:01:12.000Z" }
      },
      "footstep_water": { "round2": { "still_not_right": true, "note": "too splashy", "updated": "2026-11-14T08:03:40.000Z" } }
    }
    ```

    Round 1 (`/audition/`) writes the top-level `none_good`, `note` and
    `updated`, replacing the whole entry. Round 2 (`/audition/round2.html`)
    writes only `round2`, keeping round 1's fields. Both pages clear a row's
    picks when they mark it, and offer no pick while it is marked. `--process`
    reads them so:
    - **A pick overrides a mark** of either round. Since marking clears the
      picks, a pick that is there was saved after the mark.
    - **A row the audition touched and nobody picked stays out.** That is any
      entry, a verdict or a note, in either round. Such a row is left out of
      `game/` and the manifest, so the game plays nothing for it, and the run
      names it with the reason. The reason comes from the deciding verdict,
      round 2's when the row has a `round2` and otherwise round 1's: "marked
      not good in round N" when it rejects the row (`still_not_right` or
      `none_good` true), otherwise "noted in round N but not picked". So a
      note never ships candidates the owner did not choose.
    - Ids not in the sheet are ignored. A notes file that is not a JSON object
      stops the run, since its verdicts cannot be read.
  - **Rows nobody judged.** A row with no pick and no entry in the notes gets
    its first candidates. The summary lists it ("processed from first
    candidates nobody picked"), and the manifest marks it `"picked": false`.
    That happens only while no audition has happened (`picks.json` names
    nothing and the notes hold no entry), or when all its current candidates
    predate the audition. Otherwise it is left out and named as unheard. A
    set's time is the latest time the generation log records for its current
    candidates. How the audition is dated:
    - **By the notes,** when they hold a time: it began at their earliest
      `updated`, so the set must be older than that.
    - **By picks alone,** when the notes are missing, emptied or undated but
      `picks.json` names something. Picks carry no time, so the set must come
      from the generation log's first session: its lines, in time order, up to
      the first pause of more than 15 minutes. Within one run, lines come at
      most minutes apart.

    These are times recorded inside the log and the notes, never file times.
- **Processing.** `--process` turns each kept take into
  `~/ti-sfx/game/<group>/<name>_NN.ogg`, mono for positional sounds and
  stereo for the two ambience beds. The candidates themselves are only read,
  never changed.
  - **Peak-relative trims.** Each candidate's peak is first brought to full
    scale, so a recipe's trim levels count down from the take's own peak, and
    a quiet take is trimmed like a loud one.
  - **Silent takes.** A take that is near-silent is named by id and candidate:
    "silent after trimming; pick another take or regenerate". Near-silent
    means it peaks at −70 dBFS or below, or under 10 ms is left once its
    silence is trimmed. The other rows are still processed, and the run ends
    non-zero listing the failed rows.
  - **Whole rows.** A row is replaced whole or not at all. If one of its takes
    fails, its takes in `game/` and its manifest entry stay as they were, none
    of the takes made for it in that run is used, and the FAIL lines say so.
    `game/` never holds a mix of two sets of a row.
  - **What a run removes from `game/`.** It removes only these, and lists
    each file:
    - takes numbered past what a row processed in this run keeps;
    - every take of a row this run leaves out (judged without a pick, or unheard);
    - in every run, the takes of `retired_outputs`, the rows taken out of the
      sheet.

    A row outside the run's `--id`/`--tier` selection, a refused, failed or
    skipped row, and any file merely missing from the manifest are left
    alone. The very first run on a folder, with no manifest yet, touches
    nothing else either.

What the output folder holds:

| Path | What |
|---|---|
| `candidates/<id>/<id>.cNN.wav` or `.mp3` | ElevenLabs' answer, one file a generation (WAV 48 kHz for one-shots; MP3 192 kbps for loops, the only format the docs offer for them) |
| `generation-log.jsonl` | A line a request: time, id, candidate, attempt, file, prompt, model, settings, status (`ok`, `retry`, `error`), HTTP status, credits. `credits` is computed from the sheet (`credits_per_second` × the requested seconds); the API does not report it. |
| `.generate.lock`, `candidates/<id>/.forced` | A run in progress (its pid and start); a forced set not yet complete |
| `candidates/<id>/.picks-before-force.json` | The row's picks when `--force-id` set its candidates aside, and where they went |
| `picks.json` | Optional, by hand: the candidates kept, in take order |
| `audition-notes.json` | Optional, from the audition pages: each row's round-1 and round-2 verdicts and notes |
| `game/<group>/<name>_NN.ogg` | The processed takes |
| `game/sfx.json` | The manifest the game reads: each sound's playback gain and takes (see Levels) |

Observed on 2026-11-14 in the first real run, on the Creator plan:

- `wav_48000` works for one-shots. The answer is 16-bit PCM WAV, 48 kHz,
  stereo.
- Loops come back as MP3, 44.1 kHz, 192 kbps, at the requested length.
- A 0.5 s request returns about 0.48 s of audio.

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
- `loudness_class`, `level_db`: how loud the row plays (see Levels below).
- `notes`: optional reasoning.

`recipes` holds the post-processing steps as data: channels, silence trims,
a length cap, fades, a loop crossfade and a peak level.

- **Trims.** The trim levels are dB below each candidate's own peak.
  `oneshot_impact` cuts everything before the first sample within 12 dB of
  the peak, so a take played the moment something lands starts at its hit.
- **Peak.** The peak is measured after encoding, because Vorbis overshoots
  bright transients by up to about 2.6 dB.
- **Loops.** A loop recipe with `loop_crossfade_ms` 0 keeps a loop as
  generated. It is for a loop the model already made seamless, chosen by ear;
  give that row its own recipe.
- **Formats.** The sheet's output formats must be ones its plan can use, and
  loops must be MP3.

`events` lists every sound-carrying event in the code (P player, V vehicle,
B ball, A ambient, U interface). Every event is served by a row or listed in
`not_voiced` with the reason; the check enforces this.

`retired_outputs` names the output pattern of every row taken out of the
sheet, with which row it was and why (today the three coin rows). `--process`
removes their takes from `game/` in every run. When a row leaves the sheet,
add its output here. The validator refuses an output that a row still uses.

## Levels

Every row has a planned playback level, `level_db`, in LUFS (ITU-R BS.1770,
as ffmpeg's `ebur128` measures it):

- **What is measured.** For a one-shot, the loudest momentary (400 ms)
  window, because a short sound's integrated loudness depends on how long
  its tail runs. The sound is padded with silence so a whole window fits.
  For a loop, integrated loudness, which is its average. On the first
  generation, a loop's loudest moments ran 1 to 8 dB above that average.
- **What it means.** It is how loud the sound plays at its source at full
  strength: the hardest impact, at the closest distance. The game's
  modulation (impact strength, speed, distance) only lowers it from there.

Each row also has one of six `loudness_class`es, ordered and not overlapping.
A row's level must lie inside its class, so no row can play louder than any
row of a louder class. The validator enforces both.

| Class | LUFS | What, and why there |
|---|---|---|
| `crash` | −21 to −15 | Big collisions, falls and splashes: rare, the loudest, and heard over a running engine. Fences and lamps are here because they are struck while the engine runs. |
| `loud` | −26 to −21 | Engine under load, jetpack, skid, roof scrape and lighter collisions. Below the crashes because they last or repeat. |
| `medium` | −31 to −26 | Doors, engine cruising and stopping, the chest's landing and lid, hard kicks, goals, scrapes and bends. |
| `soft` | −36 to −31 | Footsteps (up to 10 a second), idling engine, the chest's rattle and creaks, ball bounces, the ferry. Well below their real loudness because they repeat; the owner already found a coin layer "annoying". |
| `interface` | −39 to −36 | Menu clicks and the recovery whoosh: close, brief, mostly with the world paused. |
| `ambience` | −50 to −39 | Wind, bay water and foliage: always on, so the quietest. |

The scale's top is set by what the material can reach. Measured on the first
generation (2026-11-14), a peak-normalised crash reached only −13 to
−21 LUFS against −10 to −30 for everything else; its transients use up the
peak. So the crash class tops out at −15, and every row's level sits at or
below what its takes reach without being raised above their peak ceiling. The
whole mix moves up or down together with the master volume. Raising the
master above 0 dB would need a limiter on the master bus, since the loudest
crashes then play near their files' full peak.

**This is a reasoned starting mix for the owner's ear, not one verified by
listening.**

**How the level reaches the game (one mechanism).**

- The files stay peak-normalised for headroom; no level is baked into the
  audio.
- `--process` loudness-matches each row's takes, so a randomly chosen take
  never jumps in level: each take louder than the row's quietest by more than
  0.25 LU is turned down to it, which only lowers peaks. The tolerance is
  `within_row_spread_lu` (1 LU). On the first generation's picks, the measured
  spread after matching was 0.2 LU at most.
- `--process` then writes the playback gain to `DIR/game/sfx.json`, the
  manifest the game reads. Mixing stays adjustable without re-encoding: change
  a `level_db` and rerun `--process`.

The manifest is JSON, rewritten atomically by every `--process`. It keeps the
entries of rows outside the run and of failed or skipped rows as they were,
drops rows no longer in the sheet, and drops a row the run leaves out (judged
without a pick, or unheard).

```json
{
  "schema_version": "ti.sfx-manifest/1",
  "notes": ["..."],
  "sounds": {
    "car_impact_heavy": {
      "gain_db": -0.5,
      "level_db": -16,
      "loudness_class": "crash",
      "loudness_lufs": -15.5,
      "spread_lu": 0.0,
      "shortfall_db": 0,
      "loop": false,
      "channels": 1,
      "picked": true,
      "takes": ["car/impact_heavy_01.ogg", "car/impact_heavy_02.ogg"]
    }
  }
}
```

- **`gain_db`** (number, dB, never above 0) is the field the game applies:
  the playback gain for every take of that sound id (Godot: `volume_db`).
  In-engine modulation multiplies on top of it.
- **`takes`** are paths relative to `DIR/game/`.
- **`loudness_lufs`** is the loudest processed take's measured loudness, and
  `gain_db = min(0, level_db − loudness_lufs)`.
- **`shortfall_db`** above 0 means the takes cannot reach `level_db` within
  their peak ceiling, so the sound plays that much below its planned level;
  `--process` prints a NOTE for it.
- **`spread_lu`** is the matched takes' loudness range.
- **`picked`** is true when the owner picked the takes, and false when they
  are a row's first candidates, which nobody picked (see Rows nobody judged).

## How the prompts are written

- **Realistic.** The player is a real wooden treasure chest of gold coins with
  iron straps, brass fittings and big leather-soled shoes, flying on a small
  twin-nozzle rocket backpack. Cars and the world are realistic too.
- **No coins.** Coins have no sounds of their own, and the chest's impacts
  carry no coin layer. The owner dropped every coin sound after hearing them
  on 2026-11-14: "I think it would get really annoying", "we don't need this".
- **Owner's audition.** Rows the owner rejected in full are reworded, with
  the owner's words in the row's notes, and made again with `--force-id`.
  Rows with picks keep their prompts, so their candidates stay valid.
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
