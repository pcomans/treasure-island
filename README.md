# Grand Treasure Island

I modeled an entire island with Claude. It took 3 months and about 50 billion tokens.

Any similarities to upcoming blockbusters are purely coincidental.

[![Grand Treasure Island: watch the video](https://grandtreasureisland.vercel.app/trailer/first.webp)](https://youtu.be/8WEn3Bm2Ckw)

Step into the shoes of Chester Schatz and live a life of leisure, exploration and light trespassing on Treasure Island.

## Play it

- **In the browser:** [grandtreasureisland.vercel.app/play](https://grandtreasureisland.vercel.app/play). About 140 MB loads before you can play. Needs WebGL 2; mouse and keyboard or touch.
- **On a Mac:** [download the app](https://github.com/pcomans/treasure-island/releases/latest/download/treasure-island-mac.zip) (a zip of about 229 MB). It isn't notarized, so macOS blocks it the first time you open it. Click Done, then go to System Settings > Privacy & Security, scroll down, click Open Anyway and confirm. After that it opens normally.

The downloadable version looks nicer.

`WASD` move, `Shift` runs, hold `Space` for the jetpack, `C` in the air drops fast, `F` gets in and out of a parked car, `Esc` pauses. [All controls](#controls).

## Why Treasure Island

Since January I've been living on Treasure Island in the middle of the San Francisco Bay, and I love it here. The view, the waves, the beautiful parks and the grungy shipping containers. It's a very special place. I asked myself: how hard would it be to get Claude to model all of this as a video game? Turns out pretty hard. But it is possible. I'm excited to show the first version of Grand Treasure Island. It's an entire island with 16 miles of road and almost 200 buildings, mostly modeled by Claude Opus 5.5.

## What's in the game

| | |
|---|---|
| Area | 0.63 square miles |
| Road | 16 miles |
| Buildings | 199 |
| Street signs and street furniture | 540 |
| Kinds of plants | 35 |
| Cars | 458 |

All playable. Walk, run, fly the jetpack, drop fast, drive any parked car (over the ramps, through fences, into the bay) and kick the ball into the goals.

## Real and modeled

<table>
<tr><th>Real</th><th>In the game</th></tr>
<tr><td><img src="https://grandtreasureisland.vercel.app/compare/maceo-may-real.webp" alt="Maceo May, south end: photo"></td><td><img src="https://grandtreasureisland.vercel.app/compare/maceo-may-game.webp" alt="Maceo May, south end: in the game"></td></tr>
<tr><td colspan="2">Maceo May, south end</td></tr>
<tr><td><img src="https://grandtreasureisland.vercel.app/compare/mersea-court-real.webp" alt="Mersea, the courtyard: photo"></td><td><img src="https://grandtreasureisland.vercel.app/compare/mersea-court-game.webp" alt="Mersea, the courtyard: in the game"></td></tr>
<tr><td colspan="2">Mersea, the courtyard</td></tr>
<tr><td><img src="https://grandtreasureisland.vercel.app/compare/mersea-ditch-real.webp" alt="Mersea, the ditch by the lot: photo"></td><td><img src="https://grandtreasureisland.vercel.app/compare/mersea-ditch-game.webp" alt="Mersea, the ditch by the lot: in the game"></td></tr>
<tr><td colspan="2">Mersea, the ditch by the lot</td></tr>
</table>

Even in a world with Street View, good photos are hard to come by. The areas where I supplied my own photos ended up looking a lot better.

## How it's built

Deterministic code, public data, OpenStreetMap for the layout, USGS for the terrain. But saying agents do it is simplistic. Really, what makes a difference here is the subagent system.

Agents would model one side of a building, leave the other side blank and be like, great job, job done. So the work is split up:

1. The layout comes from a frozen OpenStreetMap snapshot and the terrain from USGS lidar.
2. A deterministic world generator (Node) turns them into the island.
3. Agents improve the buildings one at a time, in shared families of similar buildings.
4. Independent agents review the code, compare the visuals with dated photos and judge the progress. The orchestrating agent never builds anything itself.
5. A fit test walks the player up to every finished building. New detail only goes on sides with a dated photo.

On Yerba Buena Island a road was going up the side of the hill, and the road surface was spilling over the side, because the road geometry and the laser-measured hill geometry didn't quite fit. You can tell the agent "this looks weird, fix it", and the agent acts as an environment artist in a game and fixes it as a one-off.

[The agent harness: how the subagents work](AGENTS.md)

## What it can't do yet

The level of detail is sort of at GTA 3, GTA 4 level at this point.

- Sides nobody has photographed get no new detail, on purpose.
- On an iPhone the web build runs, but memory is tight: an older build hit the 2 GB limit.
- The web build looks plainer than the Mac build.
- More in [KNOWN_ISSUES.md](KNOWN_ISSUES.md).

This is not a world model. This is a world created by an LLM. Maybe that's just fine.

## Made with

Mostly modeled by Claude Opus 5.5, with images generated by GPT Image 2. Some structures modeled by GPT-6 Astra. Built from public and private photographic sources. Map data from OpenStreetMap, terrain from USGS geodata.

- Map data © [OpenStreetMap](https://www.openstreetmap.org/copyright) contributors, under the Open Database License (ODbL).
- Terrain: USGS 3D Elevation Program (3DEP), public domain.
- Sound effects are generated with ElevenLabs and are not in this repository; see [Sound](#sound).
- Engine: Godot 4.7.2.
- Reference photos are never shipped or committed.
- Agents built it. I directed, reviewed and took many of the photos.
- The game's **Credits** screen lists every source ([credits.json](game/resources/ui/credits.json)).

## For developers

The whole island comes from a frozen OpenStreetMap snapshot; agents improve its buildings one at a time so they look like the real ones.

**Score:** the number of buildings that recognizably match their real
counterparts, i.e. accepted buildings in [the building catalog](discovery/facades/facade-recognition-catalog.json),
out of the catalog's standing buildings (the frozen OSM buildings less those the dated imagery shows
demolished, [tools/config/demolished-buildings.json](tools/config/demolished-buildings.json)).
`tools/test.sh` prints it.

### Develop

Development runs in the Linux devcontainer on the GMKtec (`.devcontainer/`), with
GPU rendering:

```sh
devpod up git@github.com:pcomans/treasure-island.git --id treasure-island --ide none
# Inside the container git pushes over HTTPS (DevPod's credential helper), not SSH:
devpod ssh treasure-island --command "cd /workspaces/content && git remote set-url origin https://github.com/pcomans/treasure-island.git"
devpod ssh treasure-island
cd /workspaces/content
```

Creating the container installs Godot 4.7.2 and its export templates (in the
`/opt/godot` volume, shared by every checkout), Codex, Claude Code and Node
dependencies (`.devcontainer/post-create.sh`). Log in to Codex with
`codex login --device-auth`.

Container starts delete `/tmp` content unused for 7 days (`tools/clean-tmp.sh`).

Always start Godot through `tools/godot`. It picks the project's Godot and, for
anything that renders, a headless display on the GPU:

```sh
tools/godot --headless --path . --import                       # after a fresh clone
tools/godot --headless --path . --script game/tests/<test>.gd  # a headless test
```

New textures default to VRAM compression with mipmaps and Detect 3D off, and a
VRAM-compressed texture's sides must be multiples of 4 pixels, also as the Web build
caps it (`headless_world_material_contract.gd` fails otherwise). For UI art or
textures that store shader data, use **Compress > Mode > Lossless** in the Import
dock; the same test lists the shader-data textures and checks `game/resources/ui/`.
Keep mipmaps if the shader samples them. Reimport and commit the `.import` file
with the texture.

### Check a building

```sh
# Screenshots for review: gameplay close-ups, the building in its surroundings, island overviews.
# Grass and small stones are drawn round the camera; -- --ground-dressing off|low|medium|high
# sets their density for a run (the project setting treasure_island/ground_dressing/density
# otherwise). Web builds draw none.
# Close-ups leave out street detail (trees, furniture, fences, clutter); surroundings and
# overviews come both ways (NAME-street-on.png, NAME-street-off.png). --street-detail off|on|both overrides.
tools/godot --path . --resolution 1600x900 --script game/tests/shared/building_shots.gd -- --source w291189336 --island --out /tmp/shots

# Fit and playability: roof and walls are solid, walls reach the ground, the player can walk up to it.
# Its visible-geometry checks need rendering, so it refuses --headless; --fixed-fps 60 lets
# the walks run faster than the wall clock (same results).
tools/godot --fixed-fps 60 --path . --script game/tests/shared/building_fit_test.gd -- --source w291189336
```

`--source` is the building's OSM id from `generated/world/` (e.g. `w291189336`
is the Navy Chapel). [AGENTS.md](AGENTS.md#what-done-means-for-a-building) says
when a building counts as done.

### Build for the Mac

Every push to `main` that changes more than documentation (see
[Where the builds go](#where-the-builds-go)) builds the Mac app on GitHub Actions
([mac-build.yml](.github/workflows/mac-build.yml)). Both launch checks there are
headless, so CI never exercises the game's rendering on a Mac. Once a GitHub
Apple Silicon Mac has launched the app and loaded the island, the build becomes
a new release of its own, unless a newer build has overtaken it. This link always
gets the newest release:

https://github.com/pcomans/treasure-island/releases/latest/download/treasure-island-mac.zip

The [releases page](https://github.com/pcomans/treasure-island/releases) lists
each build by build number, date and commit, and older builds stay there.
Downloaded with curl or `gh`, the zip has no quarantine flag, so the unzipped app
opens directly:

```sh
curl -fLO https://github.com/pcomans/treasure-island/releases/latest/download/treasure-island-mac.zip
gh release download --pattern treasure-island-mac.zip --repo pcomans/treasure-island   # or this
```

A release whose notes say "Signed and notarized (Developer ID)" opens directly
after a browser download. Every other build, from CI or `tools/build-mac.sh`, is
ad-hoc signed and not notarized (CI adds "not notarized" to the release title
when it tried to notarize and could not), so after a browser download macOS
blocks its first launch: open System Settings → Privacy & Security and click
"Open Anyway". CI signs and notarizes only while the repository variable
`MAC_SIGNING` is `on`, with the secrets of the GitHub environment `mac-signing`;
the top of [mac-build.yml](.github/workflows/mac-build.yml) lists them with the
`gh` commands that set them.

To build it in the devcontainer instead:

```sh
tools/build-mac.sh   # -> build/mac/treasure-island-mac-<commit>.zip
```

This exports the macOS build, checks it contains only game files (no research or
evidence folders, no images outside `game/resources/`), and launches a Linux build of the same commit to confirm the island
loads.

Desktop builds (this and `tools/build-linux.sh`) first bake the island with
`tools/prebuild-static-world.sh native` and load that baked world at startup
instead of generating it; `tools/test.sh` runs the whole-island check on it too.
The bake merges each building's opaque surfaces into far fewer draws
(`tools/merge_baked_buildings.gd`); the same triangles, packed differently.

### Where the builds go

Each release on the [releases page](https://github.com/pcomans/treasure-island/releases)
has two files, built and checked from the same commit, and these links always get
the newest:

- the Mac app: https://github.com/pcomans/treasure-island/releases/latest/download/treasure-island-mac.zip
- the Linux build: https://github.com/pcomans/treasure-island/releases/latest/download/treasure-island-linux.tar.gz
  (unpack it and run the `.x86_64` program in its `treasure-island-linux` folder;
  its `.pck` must stay beside it)

The Linux build is the one `tools/build-mac.sh` exports and launch-checks next to
the Mac app, with the same sounds.

Every build has a build number: the number of commits in its commit's history,
from [`tools/build-number`](tools/build-number). A newer build of `main` always
has a larger number, and the Mac app, the Linux build and the web build of one
commit share it (`tools/deploy-web.sh` prints it). A release's title gives it
with the game's name, the commit's date and its short hash, such as "Grand
Treasure Island, build 1918 (2026-11-16, 1a2b3c4)", and so does its tag, with
the number padded to six digits so that tags sort by it:
`build-001918-2026-11-16-1a2b3c4`. Releases from before build numbers keep their
`mac-<date>-<commit>` tags. `tools/build-number` refuses a shallow clone, which
would give too small a number.

A push to `main` that changes only documentation, that is only Markdown files
(`.md`, anywhere, as [`tools/docs-only`](tools/docs-only) decides), builds
nothing: its run on the Actions page shows the job "Decide whether to build"
with the notice "Not built: documentation only" and every other job skipped, so
no release, itch.io push or VirusTotal upload follows. Everything else counts as
code, the building catalog JSON among the notes in `discovery/` included, and a
push that changes any of it builds, whatever else it changes. A build whose
commit `main` has since passed by documentation alone is still the newest and
publishes. Build numbers count every commit, so the commits of such pushes leave
gaps: build 1925 may follow build 1921. To build anyway, start the workflow by
hand, which always builds: `gh workflow run mac-build.yml --ref main`.

After each release, CI's `itch` job also puts both builds on the itch.io page
[phppco/grand-treasure-island](https://phppco.itch.io/grand-treasure-island): the
Mac app, notarized or not, goes to channel `mac` and the Linux build to channel
`linux`, with the build number (such as `1918`) as their version. The job uses
itch's [butler](https://itch.io/docs/butler/), version 15.32.0, downloaded from
itch's own distribution site and checked against a pinned SHA-256. It pushes the
exact files of the GitHub release: it unpacks the Mac app with `ditto`, checks
it with `codesign --verify --deep --strict` (a failed check stops the Mac push),
and pushes it. itch.io then processes each build, which for builds of this size
can take around 30 minutes, and refuses a new build on a channel until its
latest one is done; the job then tries the push again once a minute for up to
30 minutes. A build's state shows on the game's Edit page under Uploads (click
the channel), or with `butler status phppco/grand-treasure-island`. Once itch.io
has processed the build, the job downloads what itch.io serves and compares it,
file by file, with what was pushed. It runs on `main` only. A failed push
never affects the GitHub release: the job reports it, and the run still
succeeds. To push an existing release again, or for the first time, start the
workflow by hand on `main` with that release's tag (a release from before build
numbers gets its date and commit as its version). Such a run builds nothing:

```sh
gh workflow run mac-build.yml --ref main -f itch_release_tag=<tag>   # such as build-001918-2026-11-16-1a2b3c4
```

CI's `virustotal` job also submits both files of each release to
[VirusTotal](https://www.virustotal.com), and the `virustotal-notes` job adds
each file's SHA-256 and VirusTotal report link to the release notes. The link is
by hash, so it works while the analysis is still running; the notes say when
that was the case. Anyone can check a download the same way:
`shasum -a 256 treasure-island-mac.zip`, then open
`https://www.virustotal.com/gui/file/<that hash>`. The job uses VirusTotal's
free public API, which is for non-commercial use and allows 4 requests a minute
and 500 a day. VirusTotal shares uploaded files with its security partners, so
only the already public release files are sent. The notes and the job's summary
carry links, never verdicts or counts; a file that VirusTotal flags is a warning
for a person to look at, never a failure: game-engine exports do get false
positives.

Both jobs take their keys, `BUTLER_API_KEY` and `VIRUSTOTAL_API_KEY`, from the
GitHub environment `itch`, whose deployment branch rule admits only `main` (no
required reviewers): a repository secret could be read by a workflow on any
branch. Each job first reads that rule through GitHub's API and uses its key
only while the environment admits `main` alone; without the key it does nothing
but say so. The top of [mac-build.yml](.github/workflows/mac-build.yml) has the
`gh` commands that set the keys.

### Sound

The game has sound effects, but this repository holds none: every sound is
generated with ElevenLabs from the public prompts in
[tools/sfx/prompts.json](tools/sfx/prompts.json), and ElevenLabs' terms forbid
making the output available as separate audio files, so it stays private. A
checkout or build without a sound source runs silent. `tools/fetch-sfx`, which
the build scripts run, copies the sounds from the private source named by
`TI_SFX_SOURCE` into the ignored `game/resources/audio/sfx/`. The Mac build on
GitHub Actions does the same when the repository variable `TI_SFX_SOURCE` and,
for a private repository, the secret `TI_SFX_GIT_TOKEN` are set. To make your own
set with your own ElevenLabs account, follow
[Make your own sound set](tools/sfx/README.md#make-your-own-sound-set); for the
terms, see
[Why our audio is not in this repository](tools/sfx/README.md#why-our-audio-is-not-in-this-repository).

### Controls

- `WASD` or the arrow keys move; hold `Shift` to run.
- Mouse looks around.
- Hold `Space` to jetpack upward; release it to descend slowly.
- Hold `C` in the air to drop fast. It does nothing on the ground, and `Space` wins if both are held.
- `F` beside a parked street or lot car, or a storage yard's van, box truck, food-truck step van or class A or C RV, gets in; `F` again gets out beside it.
- In a car: `W`/`S` (or the up and down arrows) drive, brake and reverse; `A`/`D` (or the left and right arrows) steer; `Space` is the handbrake; the mouse glances round and the view eases back behind the car; `R` puts the car back on land. No jetpack in a car.
- A car breaks through fences bay by bay (a broken bay stays open, on foot too, until a restart), shoves parked cars and K-rails, sends the pitch's ball rolling, drives through bushes, bends small young trees out of its way (they spring back) and stops at bigger trees. Driven off the shore it rolls down the rocks, watched from the shore, splashes where it meets the water and sinks, then goes back, with you in it and the view behind it, to a level spot at least 12 m inside the shore, facing away from the water and held on its brakes until you drive off. Cars stop where the island's edge crosses the causeway to Yerba Buena. On its roof or side it rights itself after about three seconds.
- Kick the pitch's ball (run into it), or push it with a car, into any goal on the athletic fields: confetti bursts at the goal and the ball goes back to its centre spot.
- Car ramps stand in three empty lots: the 12th Street and Avenue D dirt lot, the north slab site between Avenue I and Avenue M, and the former school lot by Aracely Cafe.
- Fences stop you on foot (gates, path crossings and bays a car broke stay open); the jetpack clears them.
- Stepping off the island onto the shore rocks, or flying out over the water,
  lifts you about 5 m into the air where you are; float down and steer or
  jetpack back to land.
- The mouse buttons do nothing; there is no spray.
- `R` recovers to a safe position.
- `Esc` pauses: everything stops where it is (you, the cars, the ball, the ferry, the water, the trees and the clouds) until you resume, while the sun goes on following the clock; `Q` quits while paused; `F3` toggles runtime evidence.
- **Controls** in the pause menu, or on the loading screen, lists these controls in the game; **Back** or `Esc` returns.
- **Options** in the pause menu sets, under **Graphics**, the sun's shadow quality (`game/scripts/settings/shadow_quality.gd`): Off; Low (shadows within about 200 m only, lighter); Medium (the default: sharp near the player, softer in the distance); or High (a bigger shadow map: sharper still, near and far); a frame-rate limit (30, 60, or No limit, the default: the screen's own refresh); **Show fps** (off by default); and the resolution the world is drawn at (50, 67, 75 or 100 %: 100 % by default, 67 % on the web; `game/scripts/settings/graphics_settings.gd`). Under **Time of day**, on desktop, it sets the date and time: the game opens at the real date and time on Treasure Island and runs at real speed, pause included; the date (this year) and time (island time, PST or PDT) sliders jump to any moment and time runs on from there, and **Now** returns to the real time. The light follows the sun's height down through sunset and dusk into a dark night with stars, held from 18° below the horizon until dawn. Once it is dark a flashlight at your chest lights the way where the camera looks, and the car you drive has headlights; both come on by themselves. Street lamps and windows stay dark: a few buildings' small lamps (string lights, a café's bulbs, a pier's LED, a lamp by a door) stay lit, while their lit lobby glass, sign and café interior go dark. Under **Sound** it sets the volume and mute. The web build has no shadow row (its sun shadows stay off: with them on, its renderer also brightened every sunlit surface) and no time of day: it holds the recorded moment (2026-11-13 12:30 PST). A graphics or sound choice applies at once and is kept between runs in `user://settings.cfg`; the date and time are not kept. The shared capture harness always takes the defaults and the recorded moment. `treasure_island/time_of_day/enabled=false` in `project.godot`, or `--no-time-of-day` after `--` for one run, turns the whole time of day off: the game then holds the recorded moment as the web build does.
- **Credits** in the pause menu acknowledges the sources the game draws on, from the one list in [game/resources/ui/credits.json](game/resources/ui/credits.json), and the Godot engine's own licences; a new third-party folder needs an entry there (`game/tests/headless_credits_contract.gd` checks).

### More

- [AGENTS.md](AGENTS.md): how agents work on this project. Read it before changing anything.
- [CLAUDE.md](CLAUDE.md#persisted-entrypoints): agent roles and the building skill.
- [LEARNINGS.md](LEARNINGS.md): lessons from earlier work.
- [HUMAN.md](HUMAN.md): things only the owner can do.
- [KNOWN_ISSUES.md](KNOWN_ISSUES.md): known issues and planned work.
- [tools/sfx/README.md](tools/sfx/README.md): the sound-effect prompts, the tools that make and fetch the audio (`tools/generate-sfx`, `tools/fetch-sfx`), how to make your own set, and why the audio itself stays out of Git.
- Older records: Git history and `evidence/`.


### Browser build

`tools/build-web.sh` exports the committed checkout to `build/web` and audits the
pack for game-only content. Native builds retain Forward+; the browser uses
Godot's Compatibility/WebGL 2 renderer and single-threaded WebAssembly.

Open https://treasure-island-five.vercel.app/ and wait for the island to load;
then **Click to play** (on a touch screen, **Tap to play**) starts play: that
first click or tap also starts the sound, which a browser allows only after one,
and with a mouse it captures the mouse to look around. WASD or the arrow keys
move, Shift runs, Space rises with the jetpack, releasing Space descends slowly
and holding C in the air drops fast. F gets in or out of a parked car; in a car
W/S drive, A/D steer (or the arrow keys) and Space is the handbrake. Esc
releases the mouse and pauses; **Resume** captures it again and continues. There
is no spray. F3 shows actual FPS.

To deploy, as part of a [release](AGENTS.md#pushes-and-releases), push to `main`, check out a clean `main` and run:

```sh
tools/deploy-web.sh             # build origin/main and deploy it to production
tools/deploy-web.sh --dry-run   # the same checks and build; prints the Vercel commands instead
```

It refuses unless the checkout is clean and HEAD is `origin/main`, and unless
`TI_SFX_SOURCE` names the [sound source](#sound) and that source has takes for
every sound the game plays; `--silent-ok` deploys without them on purpose. If `build/web`
isn't linked yet, it links it to the existing `treasure-island` Vercel project (never
a new one). Then it runs `tools/build-web.sh`, deploys `build/web` to production with
the pinned Vercel CLI (`npx vercel@64.5.0`) and prints the deployment URL. It uses
your saved Vercel CLI login (`npx vercel@64.5.0 login`, once). If that login has
more than one team, link once by hand:
`cd build/web && npx vercel@64.5.0 link --team <slug> --project treasure-island`.
Only `build/web` is uploaded, never the source checkout, reference imagery or
evidence. The web exporter writes immutable caching for commit-named assets and
the WASM content type.

Browser performance and pointer lock need checking on the playing machine.
The development container's Chrome 154 on headless Weston has a reproducible
pointer-lock crash; this is not evidence that a Mac browser crashes.

In the Linux development browser, mesh-size distance culling increased the
observed spawn frame rate from13 to39–40FPS. Distant small building meshes can
disappear; complete source inventory and collisions remain loaded. Initial
world construction took about90seconds. These measurements used Chrome154,
AMD Radeon780M and headless Weston; they do not predict Mac performance.
Traversal smoke checks required a test-only pointer-lock override because of
the container crash. That override is not in the deployed game.


#### Touch controls

On a touch-capable browser, **Tap to play** starts play once the island has loaded
(that tap also starts the sound). Drag the
left movement stick to walk, drag the right side to look, hold **RISE** to jetpack
upward and release it to descend, and hold **RUN** while moving to run. The
**II** button pauses; **Play / Resume** continues, **Controls** lists the touch
controls and **Credits** lists the game's sources (drag to scroll); **Options** has the
frame-rate limit, Show fps, the resolution and the sound (no shadows or time of day on the web). Movement, look and buttons
accept different fingers at the same time. Pausing, losing focus, resizing or
cancelling a finger releases held touch input. Desktop mouse and keyboard
controls are retained.

A context button above **RISE** does what F and C do. Beside a parked car it
shows a car, **DRIVE**: tap it to get in. In a car it shows **GET OUT**: tap it to
get out. In a car the stick drives and steers, **RISE** turns into **BRAKE** (a
handbrake symbol), and **RUN** and the look hint are hidden until you get out. In
the air it shows a down arrow, **DROP**: hold it to fall fast; it lets go when
you land. Otherwise it is hidden.

This ports the MIT mobile input layer from Selgesel’s Godot4 third-person
controller (see game/scripts/vendor/selgesel/README.md): its analog thumbstick,
virtual buttons and swipe camera. Stock movement physics is retained; stick
magnitude controls touch speed. Touch mode avoids pointer lock; it does
not fix iPad trackpad capture. Physical iPad Safari validation remains with the
owner; Chromium touch emulation checks are recorded in RETRO.
