# Shader-compilation stutter in the Godot web build: what exists, what could change, what is coming

2026-11-17

Research for the web build's shader-compilation hitches; the measured facts it starts from come from the instrumented drive on branch `tools/web-drive-trace-20261117`.

Research date: 2026-11-17. All external sources were checked on 2026-11-17. Engine facts come from three places: the Godot 4.7.2 source (4.7.2-stable, commit ed1daf0); GitHub raw files of Godot `master` (version.py: 4.8 beta); and the 4.8-beta3 build commit `c51ff06e`. Nothing was changed in any repository. The game's measured facts from the brief are taken as given.

Labels: **[V]** verified, with a source · **[I]** inference · **[Q]** open question.

## 1. Summary in plain language

### Today, in 4.7.2

- Every web shader program compiles on the browser main thread at first draw, and the frame waits for it. There is no async, parallel or persistent cache: WebGL 2 forbids program binaries, and Godot compiles its own cache out on web **[V]**.
- The first use of a 3D shader compiles four "default" programs, which are usually never drawn, plus the one the draw needs **[V]**.
- With a stock engine, the only tool is drawing everything once behind a loading screen. That moves the stall; it does not remove it.

### What does not exist

- Async or parallel compile for Compatibility, in any release or open PR **[V]**.
- Compatibility support in Godot 4.4/4.5's ubershaders, pipeline precompilation or shader baker. They are documented as Forward+/Mobile only, "not Compatibility" **[V]**.
- An upstream WebGPU renderer. There are only community forks, and no WebGPU PR in godotengine/godot **[V]**.

### What is coming

- **4.8** is at beta 3 (9 Nov 2026), with no RC yet. It changes nothing about how shaders are compiled **[V]**.
- **PR #124566** (clayjohn, "Overhaul GLES3 shader compiler", open, milestone **4.9**) cuts the four scene defaults to one cheap default and speeds up Godot's shader-text assembly. It is not async, and its author has not tested it on web **[V]**.
- **A real ubershader system:** "a lot of work", no timeline **[V]**.
- **Proposal #15346** (use KHR parallel compile while loading): open, no maintainer response **[V]**.

### Browsers

- Chrome desktop and Safari (including iOS) expose a non-blocking "is it compiled yet?" query (`KHR_parallel_shader_compile`). Firefox does not, and Android Chrome effectively does not **[V]**.
- Godot's web build already enables this extension through Emscripten but never queries it **[V]**.
- A 2023 WebKit bug says Safari still blocks on link. Current behaviour is unverified **[Q]**.
- Chrome keeps compiled programs between visits in a small budget shared by all sites: 6 MB on desktop **[V]**. Firefox keeps none **[V]**.

### Engine changes via a custom web template

- **Skip the unused defaults:** a few lines. One third party measured large gains on Chrome/Windows **[V]**.
- **Stop in-play stalls entirely:** this needs async compile plus skip-or-substitute. Others who tried it called it a larger refactor and did not publish **[V]**.

## 2. "If we switch to 4.8, would that help?" — No

### Release status [V]

| Version | Status | Date / source |
|---|---|---|
| 4.8 | **beta 3**, commit c51ff06e | 9 Nov 2026 (https://godotengine.org/article/dev-snapshot-godot-4-8-beta-3/, https://github.com/godotengine/godot-builds/releases/tag/4.8-beta3) |
| 4.8 betas 1 and 2 | released | 15 Oct 2026, 29 Oct 2026 (https://godotengine.org/blog/) |
| 4.8 RC / stable | none yet | Beta 3 post: "it won't be too much longer before we're ready to transition to the release candidate phase" |
| 4.8 feature freeze | in effect | dev 7, 29 Sep 2026: "no new features will be integrated for Godot 4.8" (https://godotengine.org/article/dev-snapshot-godot-4-8-dev-7/) |
| 4.7.3 | not released | The 4.7 branch says "4.7.3-rc" (bumped 2026-08-17), with cherry-picks to 2026-11-04 (https://github.com/godotengine/godot/compare/4.7.2-stable...4.7) |

### What 4.8 changes in this code path [V]

- **The compile code is the same.** At beta 3, `drivers/gles3/shader_gles3.h/.cpp` are byte-identical to master. Against 4.7.2 they differ only in two ways:
  - embedded shader-source compression (#124058);
  - `EMULATE_MULTIVIEW` when multiview is unsupported.
- **The broken paths are untouched:**
  - the `if (false)` "Queue load this specialization … (TODO)" branch is still there (beta 3 `shader_gles3.h:197`);
  - `_initialize_version()` still compiles the defaults for every variant;
  - `scene.glsl` still has its four modes;
  - there is no `KHR_parallel_shader_compile` / `COMPLETION_STATUS` use in `shader_gles3.*` or `storage/config.cpp`.
- **No other change targets compile scheduling.** No master commit touching `drivers/gles3` or `platform/web` since 2026-04-01 addresses it.
- **No precompile API** exists in `rendering_server.h`, in 4.7.2 or master.

### Things in 4.8 that could change counts for this game [I]

- **Compatibility decals** (#118070). These add `USE_DECALS`/`USE_DECAL_MIPMAPS` specialization bits, set per instance when `decals_count > 0`.
  - If the web build starts drawing real Decal nodes, materials touched by decals get **new** specializations, so there would be more first-use compiles.
  - The game currently substitutes geometry for its Mersea Decal on Compatibility (`game/scripts/world/facades/mersea_model.gd`).
- **`USE_LIGHTMAP_SPECULAR`**, which matters only with lightmaps.

### Other versions

- **4.7.3** touches only `particles_copy.glsl`, a `scene.glsl` area-light init and `texture_storage.h` in `drivers/gles3`. The four scene modes are unchanged **[V]**.
- **#124566** is milestone 4.9 **[V]**.

### Unverified without running 4.8 [Q]

- Changes to generated shader text (globals moved to a texture, decal code) and their effect on compile cost per program.
- Whether any feature the game uses now selects different specializations.
- Other beta web behaviour. A web frame-delay regression fix landed 2026-11-16, after beta 3 (#125510).

## 3. How the stall arises in 4.7.2 [V]

1. **First bind of a version.** `_version_bind_shader()` (`shader_gles3.h:183`) calls `_initialize_version()` (`shader_gles3.cpp:703`), which compiles `specialization_default_mask` for every variant. The scene shader has 4 variants (`scene.glsl:4-7`), sky has 2 and canvas has 1.
2. **Requested specialization.** A key not yet compiled is compiled synchronously, "Compile on the spot" (`shader_gles3.h:200`).
   - The "Queue load … use defaults in the meantime (TODO)" branch is behind `if (false)` (`:195-198`).
   - `build_queued` is never set true anywhere, so the "still queued" path is dead code.
3. **Why defaults rarely match.** The scene default has all lights enabled, fog, radiance, `BASE_PASS` and `APPLY_TONEMAPPING`. The real key is computed per instance, pass and light situation (`rasterizer_scene_gles3.cpp:3540-3682`). Any change of light or shadow situation creates a new key, compiled at first draw **[I]**. The key depends on:
   - omni, spot and area lights present;
   - whether every directional light has a shadow;
   - reflection probes, lightmaps and sun scatter;
   - additive passes with PCF and PSSM bits;
   - MultiMesh instancing, which is a separate variant.
4. **Each compile blocks three times.** `_compile_specialization()` (`shader_gles3.cpp:307-470`) runs these steps in order:
   - compile vertex shader → query `COMPILE_STATUS`;
   - compile fragment shader → query `COMPILE_STATUS`;
   - link → query `LINK_STATUS`;
   - read uniform locations and set samplers (`_get_uniform_locations`, `:265`).

   Each status query blocks until the work finishes (MDN WebGL best practices).
5. **No cache on web.** The cache functions return immediately under `WEB_ENABLED` (`:547-551`, `:633-635`). The WebGL 2 spec says "No Program Binaries".
6. **Uniforms depend on the exact key.** `_version_get_uniform` (`shader_gles3.h:224-232`) looks up `(variant, specialization)` and fails (`ERR_FAIL_NULL_V(spec, -1)`) if that exact key is absent. This is what "relies on the specialization existing": a fallback program would make every `version_set_uniform(…, spec_constants)` miss.
   - Internal effect shaders bind and set uniforms with the default key. They need it to exist when they bind it, but not in advance: the bind path compiles any missing key.
7. **A failed bind skips one element.** In the scene renderer `if (!success) break;` (`rasterizer_scene_gles3.cpp:3685`) skips the rest of that element's passes, not the whole list.
8. **The parallel-compile query is already reachable.**
   - The web context uses Emscripten defaults (`display_server_web.cpp:1137-1145`).
   - Emscripten 4.0.20, used for the official 4.7 templates, auto-enables `KHR_parallel_shader_compile` (`libwebgl.js:207`; `GL_SUPPORT_AUTOMATIC_ENABLE_EXTENSIONS = true`).
   - Emscripten's `glGetProgramiv` and `glGetShaderiv` pass `COMPLETION_STATUS_KHR` (0x91B1) through.
   - Godot's `Config` already lists browser extensions with the `GL_` prefix (`config.cpp:58-70`).
   - So an engine patch could poll completion with no further wiring **[V]**. Per-browser behaviour **[I]**.

## 4. Platform facts

| Item | Chrome/Edge desktop | Safari macOS/iOS | Firefox | Chrome Android |
|---|---|---|---|---|
| Parallel-compile extension (`KHR_parallel_shader_compile`) exposed | **Yes**, since 76 (MDN BCD) **[V]**. Survey: Chrome 77%, Edge 98%; Windows 89%, Linux 43% (web3dsurvey) | **Yes**, since 14.1, iOS mirrors it **[V]**. Survey: Safari 99%, iOS 99% | **No** **[V]**. Bug 1736076 is NEW; patches are blocked by conformance timing (status queries took 334–485 ms against a 100 ms limit). It was originally filed by Godot's project manager | **Effectively no** (0.3%) **[V]** |
| Non-blocking in practice | ANGLE links on a worker pool and waits only at `resolveLink` (ANGLE `Program.cpp`) **[V]** | **Unverified [Q].** WebKit bug 251514 (NEW, last modified 2023-03-23) says "linkProgram … blocks", due to missing parallel linking in ANGLE Metal. ANGLE main and WebKit's copy now set `enableParallelMtlLibraryCompilation = true` (`DisplayMtl.mm:1304` / `:1313`) **[V]** | n/a | n/a |
| Without the extension | Khronos spec: implementations may compile concurrently, "but without this extension, there is no way … to check compile/link status without potentially blocking" **[V]** | same | same | same |
| Cache between visits | **6 MB [V].** GPU program cache from ANGLE blob callbacks, sized `gpu_program_cache_size`. Default `kDefaultMaxProgramCacheMemoryBytes` is 6 MB on desktop, 2 MB on Android, 128 KB on low-end Android. The disk cache default uses the same constant and is per storage partition. Shared by all WebGL content in the profile **[I]** | **Unverified.** No primary source. A third-party guide says the macOS system Metal cache keeps binaries | **None.** Bug 918941 is open **[V]** | 2 MB **[V]** |
| WebGPU `createRenderPipelineAsync` | Chrome 113+ | Safari 26 | 141+ on Windows; macOS Apple Silicon 145/147+; not Linux | 121+ |

- **Godot and WebGPU [V]:** no upstream renderer. godot-proposals #6646 is open with "implementer wanted". Forks only, and no PR in godotengine/godot.
- **Godot docs [V]:** the pipeline-compilation page "only applies to the Forward+ and Mobile renderers, not Compatibility … use the legacy approach of preloading". The shader baker "is not supported on the web platform".

## 5. Option families (unranked)

**Given counts:**

- **Load:** about 450 programs, of which about 270 (60%) are unused defaults.
- **In play:** 163 programs, of which 108 are unused defaults and 55 are needed.
- **Versions first bound in play:** 108 ÷ 4 ≈ **27** scene versions, if all 108 are scene defaults **[I]**. Sky has 2 variants and canvas 1, so the census needs splitting by shader type **[Q]**.

### A. Warm-up behind the loading screen (stock engine)

**What it is.** Draw every material, in every key situation it will meet, before play. The game is already doing this.

**Evidence:**
- **Docs:** this is the documented Compatibility approach.
- **clayjohn** (#81496, 2024-03-01): "the only surefire solution … is to draw every object with every combination of potential settings at load time".
- **Calinou** (proposals #12119, 2025-03-31): `RenderingServer.instance_set_ignore_culling()` for one frame forces rendering reliably.
- **Community write-ups** (itch devlog; forum thread, Calinou 2023-12-10).
- **Add-ons:**
  - "Shader Stutter Tracker": Compatibility, Godot 4.6+, v0.2.0 marked unstable, MIT, updated 29 Sep 2026. Its page does not say whether it covers specializations.
  - FSIB: targets Forward+.

**What it removes:**
- **In play:** up to all 163, if versions and keys are fully covered.
- **Load:** rises to about 613 programs (every default is still compiled).
- **Main-thread blocking:** **moved to the load, not removed.**

The 108 in-play defaults imply about 27 whole versions were never drawn before play. Possible sources: Label3D, runtime materials, particles **[I]**.

**Coverage must reproduce every bit of the key:**
- omni/spot presence;
- shadowed vs unshadowed lights;
- additive passes and PCF/PSSM;
- probes, fog and sun scatter;
- tonemapping;
- MultiMesh;
- depth prepass and shadow pass.

**Cost and upkeep:** game code and a census. Every new material, light behaviour or environment change can add keys.

**Risks:** residual misses; a longer load; "page unresponsive" if one frame compiles too much (spread across frames).

**[Q]** Were the 163 measured with the warm-up in place?

### B. Need fewer programs (game content and project settings, stock engine)

**What it is:**
- **Fewer distinct versions:** each BaseMaterial3D feature set is its own version; avoid changing feature flags at runtime; Label3D, Sprite3D and particles make their own materials.
- **Fewer keys:** keep the light and shadow situation stable. Each source is listed in §3.3.
- **Smaller shaders:** `rendering/limits/opengl/max_renderable_lights` and `max_lights_per_object` become `MAX_LIGHT_DATA_STRUCTS` and `MAX_FORWARD_LIGHTS` (`rasterizer_scene_gles3.cpp:4606-4608`) **[V]**.
  - clayjohn listed "Reduce size of max lights … likely helps on web more than anywhere else" as an idea (#86731, 2024-01-24) **[V]**.
  - The effect on this game is **[Q]**.
- **GPU particles:** one report measured GPUParticles3D process shaders at 22–25 s each on Chrome/Windows (ANGLE/D3D11). CPUParticles3D removed the cost (#87843, 2026-11-01) **[V third-party]**.

**What it removes:** per avoided version, 4 defaults plus at least one needed program; per avoided key, one program. Unquantified **[Q]**.

**Cost and upkeep:** content and design constraints only. No engine work.

**Risks:** visual or design compromises.

### C. Engine patch: lazy defaults (do not pre-compile `specialization_default_mask`)

**What it is.** In `_initialize_version()` (`shader_gles3.cpp:703-719`), create the per-variant maps but compile nothing. Any later bind, including of the default key, compiles on demand through the existing path.

**Evidence:**
- **Third party, 4.7.2 web template, Chrome/Windows (ANGLE/D3D11)** (#86731, kuhlsnu, 2026-11-01). Single, unreviewed report **[V third-party]**:

  | Measure | Before | After |
  |---|---|---|
  | Programs | 183 | 74 |
  | Compile + link | 63–103 s | 10.5 s |
  | Cold first frame | 85–125 s | 31 s |
  | Worst in-play hitch | 4–5 s | about 1 s |

  - "changed nothing I could see in screenshots";
  - defaults averaged 0.8 s each, against 0.3 s for the keys actually drawn;
  - they said it needed `rendering/shader_compiler/shader_cache/enabled` off on web. I could not see why from the source **[Q]**.
- **clayjohn:** the defaults made the first compile "at least 5x more expensive than necessary" (#124566).

**What it removes [I]:**
- About 108 of 163 in-play programs (66%).
- About 270 of about 450 load programs (60%).
- Probably more than those shares in time, since defaults are the costlier programs.
- **Blocking: reduced, not removed.** The 55 needed programs still block at first draw unless warmed (A).

**Size:** about 5–10 lines **[I]**. Needs a custom template (§6).

**Risks (from source):**
- Effect shaders compile their default key at first bind, not in advance.
- Uniform setters follow a bind of the same key at the call sites checked.
- Compile errors surface at the first real key, with the same messages.

**Upkeep:** a small rebase each upgrade. #124566 rewrites this function, so redo or drop the patch when it lands.

**[Q]** From the existing trace: what share of in-play *time* the 108 defaults take, and which long frames contained defaults.

### D. Backport #124566 (custom template)

**What it is.** Three commits **[V]**:
1. Faster text assembly. It fixes "each line got treated as its own shader chunk" and drops `String`/`StringBuilder` there.
2. Cache restructuring. Irrelevant on web: `_is_shader_cache_enabled()` returns false there.
3. The scene shader becomes one variant. `USE_INSTANCING` and `MODE_RENDER_DEPTH` become specializations, and the default becomes cheap: lights, fog, radiance and tonemapping all off.

**Evidence [V]:**
- **Author, desktop 3D no-cache:** dev build 1600 → 160 ms, optimized build 890 → 130 ms.
- **Pixel 5 (other contributor):** cold 3118 → 1612 ms.
- **Author:** "still need to do smoke testing on … web and Android".
- **Author:** commit 3 is "a stopgap solution".

**What it removes [I]:**
- **In play:** 108 defaults become about 27 cheaper ones, so about 82 programs instead of 163.
- **Load:** scene defaults drop to 1 per version; other shader types are unchanged **[Q split]**.
- **Text assembly:** shorter. Its share in WebAssembly is **[Q]**.
- **Blocking:** reduced, not removed.

**Cost [V]:** 4 files, about +305/−232 lines. `shader_gles3.*` in 4.7.2 differs from master only by compression and multiview, so a backport looks feasible **[I]**.

**Risks:** unmerged and may change; untested on web; touches how the scene renderer picks keys.

### E. Engine patch: parallel batch compile during loading

**What it is.** During loading only:
- compile and link without the status queries, and mark programs pending;
- skip draws with pending programs (they are behind the loading screen);
- poll `COMPLETION_STATUS_KHR`, then finish link status and uniform locations;
- after loading, go back to synchronous behaviour.

This is the shape of proposals #15346 (open since 2026-08-08, no comments).

**Evidence:**
- **Private implementation** (#105864, marcosc90, 2025-04-28): "I already have `KHR_parallel_shader_compile` implemented, and it works great for preloading". It took a `requestAnimationFrame` violation "from ~700ms to zero". Not found published **[V]**.
- **Godot 3.x** implemented this polling on web: a `JAVASCRIPT_ENABLED` branch checking `GL_KHR_parallel_shader_compile`, with `_EXT_COMPLETION_STATUS 0x91B1`. It was opt-in; the web default was synchronous (`shader_compilation_mode.web = 0`) **[V]**.
- **Contradiction:** a 2023 maintainer comment says compile "can't be made asynchronous on HTML5" (#72584). It conflicts with the 3.x source and the 2025 report **[V both]**.

**What it removes:**
- Program count: unchanged.
- Load wall time: shorter where the browser compiles in parallel (Chrome desktop; Safari **[Q]**; not Firefox or Android Chrome).
- Page responsiveness: kept during loading. **Load-time blocking is removed where the extension works.**
- In play: nothing, unless combined with A or F.

**Where:**
- `shader_gles3.*`: split compile into begin and finish, plus a pending state;
- `config.*`: extension flag;
- `rasterizer_scene_gles3.cpp`: skip-while-pending during loading;
- a new "queue empty" hook. GLES3 has no existing API for this **[V]**.

**Risks:** Godot's own text assembly stays on the main thread. Browsers without the extension take the synchronous path.

### F. Engine patch: async compile in play, with hide-until-ready or a fallback

**What it is.** Implement the TODO:
- on a miss, start compile and link, and return "not ready";
- poll completion on later binds;
- meanwhile either skip the object (3.x "hidden" mode) or draw another compiled key (the TODO's "use defaults in the meantime").

**Evidence [V]:**
- **#105864:** callers "either crash or don't work correctly when it returns `false`"; jordo: "Larger refactor seemed necessary".
- **#124566:** the long-term plan is an ubershader with background specialization, "this will be a lot of work".
- **3.x precedent:** #53411, merged for 3.5.

**What it removes:**
- In play: the stalls of the 163 compiles (55 with C) move off the main thread where the extension works. They are traded for objects appearing late.
- Firefox and Android Chrome: no change.

**Risks (from source):**
- **Fallback to the default key** renders wrong for a few frames: tonemapping, fog and all light loops on, and the shadow/depth keys differ. Every `version_set_uniform(…, spec_constants)` must be redirected to the bound program.
- **Hide mode** has problems of its own:
  - a depth-prepass key ready before the colour key can leave a hole;
  - shadow casters vanish briefly;
  - sky and post-effect shaders cannot be skipped and stay synchronous **[I]**.
- **Size:** several hundred lines across `shader_gles3.*`, the scene/canvas/sky/particle bind sites and config **[I]**. `drivers/gles3` had about 130 master commits since April 2026 **[V]**, so the rebase cost is real.
- **Safari:** behaviour unverified **[Q]**.

### G. Engine patch: per-frame compile budget, no async

**What it is.** Cap compiles per frame. Objects over the budget are skipped this frame and compiled on a later one.

**What it removes:**
- Count: unchanged.
- Hitch: capped per frame, but never below the cost of the single most expensive program.
- Whether one program fits in a frame is **[Q]**, given the 200–380 ms worst frames.
- Works in every browser.

**Risks:** pop-in, and the same pass-consistency issues as F. Simpler than F, since there is no polling **[I]**.

### H. Drop the two per-stage status queries

**What it is.** Query only `LINK_STATUS`, and read the shader logs only on failure. This is MDN's best practice: "Don't check shader compile status unless linking fails" **[V]**.

**Two ways to do it:**
- **Engine patch:** about 10 lines, with a custom template.
- **No custom template:** a post-export patch of Emscripten's `glGetShaderiv` in the exported JS, using the same exact-string, fail-loudly mechanism as `tools/build-web.sh` already does **[I]**.

**What it removes:** two of the three blocking round trips per program, and the vertex and fragment compiles may overlap. Programs still compile one after another. The gain is plausibly modest and unmeasured **[Q]**.

**Risk:** when a stage fails, the log shows the link failure, not the compile log.

### I. Browser caches for returning visitors

**What it is.** Rely on the browser keeping compiled programs between visits.

**Facts:**
- Chrome: 6 MB, shared by all sites **[V]**.
- Firefox: nothing **[V]**.
- Safari: unverified.

**What it removes:** possibly some compile cost on later visits in Chrome and Safari. Nothing on a first visit, and nothing the game controls **[I]**.

**[Q]** The size of the game's program binaries. Comparing the `GPUCache` folder after a session against 6 MB would tell.

**Speculative, unverified:** pre-compiling recorded GLSL from page JS during the pack download to fill browser caches. Nothing shows the caches would then hit for Godot's own compiles.

### J. Wait for upstream

- **4.8:** no help.
- **4.9:** maybe #124566, which is not async.
- **Async or ubershader for Compatibility:** no PR, no timeline.

**Cadence [I]:** 4.6-stable shipped 26 Jan 2026 and 4.7-stable 18 Jun 2026, about 5 months apart. At that pace 4.8 stable would land around the end of 2026 and 4.9 around mid-2027. This is not an official date.

### K. WebGPU

WebGPU has async pipeline creation and broad browser support, but Godot has no upstream renderer or PR **[V]**. Only forks exist. Not available to this project today.

## 6. Custom web export templates (applies to C–H)

**Toolchain [V]:**
- Emscripten ≥ 4.0.0 (`detect.py` refuses older), Python ≥ 3.9, SCons ≥ 4.4 (4.7 docs).
- Official 4.7 templates use **Emscripten 4.0.20** (build-containers 4.7 `Dockerfile.web`); master uses 6.0.12.
- The devcontainer already has SCons 4.8.1 and built a custom 4.7.2 Linux template via `.devcontainer/setup-godot-tracy.sh` (`INSTALL_LOG.md`, 2026-10-25). That is a precedent for an optional pinned build script. `emcc` is not installed.

**Build [V]:**
- Official scripts build with `scons platform=web target=template_release threads=no production=yes` (godot-build-scripts `build-web/build.sh`).
- The preset points at the zip through `custom_template/release` (`export_plugin.cpp:372`).

**Build time:** undocumented **[Q]**. Godot's CI allows 60 minutes per web template job (ubuntu-24.04, dev_mode, emsdk 4.0.11) — a ceiling, not a measurement. Measure it in the devcontainer.

**Reproducibility [I]:**
- Pin the Godot commit and the emsdk version.
- Build from an optional devcontainer script, and in CI with `emscripten-core/setup-emsdk`.
- Keep the zip out of Git (CI artifact plus checksum).

**The project's existing JS patches [V]:**
- `tools/build-web.sh` patches the exported engine JS after export: `canOwn` in `FS.writeFile`, and the shared buffer in `getAudioBuffer`.
- Each matches an exact minified string and stops the build unless it applies exactly once.
- **Same Emscripten, same Godot JS:** the strings should match **[I]**.
- **Different Emscripten:** minification may differ and the guard stops the build — a safe failure **[I]**.
- **Alternative:** move the changes into the engine sources (`platform/web/js/libs/library_godot_os.js:224`, `library_godot_audio.js:126`).
- 4.8 already has the audio fix (#124857).

**Upkeep [I]:** every upgrade needs a rebase, rebuild and retest. Native builds are unaffected. C is small and stable until #124566 lands; F is large and sits in files that change often.

## 7. Program-count arithmetic (from the given counts)

| Case | Load | In play | In-play blocking |
|---|---|---|---|
| Today | ~450 | 163 (108 unused defaults + 55 needed) | yes |
| A: complete warm-up | ~613 | 0 | moved to the load |
| C: lazy defaults | ~180 | ~55 | yes, less |
| C + complete warm-up | ~235 | 0 | moved to the load |
| D: #124566 | scene defaults 4 → 1 cheap **[Q split]** | ~82 **[I]** | yes, less |
| E: parallel load | same | same | load not blocking where KHR works |
| F: async in play | same | same count | off the main thread where KHR works; pop-in |
| G: per-frame budget | same | same | capped per frame |

## 8. Upstream items worth following

| Item | Status 2026-11-17 |
|---|---|
| godot#124566, Overhaul GLES3 shader compiler | open, 4.9, web untested |
| godot#86731, Compatibility compile very slow | open; Oct–Nov 2026 3D and web data, including the C-style result |
| proposals#15346, async WebGL compile at load | open, no comments |
| proposals#12119, Compatibility precompilation | open; RD mechanism "isn't portable to OpenGL" |
| godot#81496, shader load API | open since 2023; maintainer reluctant ("only randomly work") |
| godot#105864 | merged 4.5; thread documents the KHR preload attempt and the async difficulty |
| godot#87553 / #87558 | merged 4.3 / 4.4; canvas variant cut, the precedent for #124566 |
| godot#87843, GPU particles slow on web | open |
| godot#76241, first-2D-draw stutter | open |
| proposals#6646, WebGPU | open, implementer wanted |
| godot#100205, asyncify | open, not shader-specific |
| Mozilla 1736076, KHR_parallel_shader_compile in Firefox | NEW, blocked on conformance |
| Mozilla 918941, WebGL shader cache | NEW |
| WebKit 251514, KHR does not avoid blocking | NEW, last modified 2023-03-23 |

## 9. Could not establish

- **Safari:** whether current Safari and iOS Safari link without blocking when polled with `COMPLETION_STATUS_KHR`, and whether they cache programs across page loads.
- **Chrome:**
  - the size of the game's program binaries, and whether they fit 6 MB;
  - whether Chrome on the dev box's Linux GPU exposes the extension.
- **The game's own profile:**
  - per-program compile times;
  - the share of text assembly in WebAssembly;
  - the share of in-play time taken by the 108 defaults;
  - which frames had defaults.

  The existing trace may already hold this.
- **The template build:** build time and peak memory of a `production=yes` web template build.
- **The C-style result:** whether it holds for this game, or on Mac and iOS. It is one unreviewed Chrome/Windows report.
- **Hidden work:** whether marcosc90's KHR code is public anywhere.
- **Dates:** official dates for 4.8 stable, 4.7.3 or 4.9 content.
- **4.8 in practice:** behaviour for this game without running it.

## 10. Most decision-relevant facts (no recommendation)

1. **No upstream release fixes this.** The compile path is unchanged from 4.7.2 through 4.8 beta 3, and #124566 is unmerged, aimed at 4.9, not async, and untested on web.
2. **A few lines remove two thirds of in-play programs.** 108 of the 163 in-play programs (and about 270 at load) are unused defaults from one loop in `_initialize_version()`. A third-party web result for removing it: 183 → 74 programs, hitch 4–5 s → about 1 s. The 55 needed programs still block.
3. **Non-blocking compile is partial.** It needs the parallel-compile extension (Chrome desktop and Safari/iOS have it; Firefox and Android Chrome do not) plus a reworked bind path ("larger refactor"). Safari is unverified.
4. **The browser will not rescue a first visit.** WebGL forbids program binaries, and browser caches are small and shared (Chrome) or absent (Firefox).

## Sources (all checked 2026-11-17)

**Local**
- Godot 4.7.2 source (4.7.2-stable, commit ed1daf0), at the files and lines cited above.
- This repository, `origin/main`: [`tools/build-web.sh`](../tools/build-web.sh), [`INSTALL_LOG.md`](../INSTALL_LOG.md), [`game/scripts/world/facades/mersea_model.gd`](../game/scripts/world/facades/mersea_model.gd).

**Godot**
- Blog:
  - https://godotengine.org/blog/
  - https://godotengine.org/article/dev-snapshot-godot-4-8-beta-3/
  - https://godotengine.org/article/dev-snapshot-godot-4-8-beta-1/
  - https://godotengine.org/article/dev-snapshot-godot-4-8-dev-7/
  - https://godotengine.org/article/rendering-priorities-september-2024/
- Releases and source:
  - https://github.com/godotengine/godot-builds/releases/tag/4.8-beta3
  - https://github.com/godotengine/godot/releases
  - raw files at master and at c51ff06e8836a70ea905701c081bf94124dcd6ce
  - https://api.github.com/repos/godotengine/godot/compare/4.7.2-stable...4.7
  - GitHub commits API (`drivers/gles3`, `platform/web`, since 2026-04-01)
- PRs: https://github.com/godotengine/godot/pull/ — 124566, 81496, 105864, 53411, 87553, 87558, 105833, 76092, 100205, 125510
- Issues: https://github.com/godotengine/godot/issues/ — 86731, 87843, 72584, 76241
- Commit: https://github.com/godotengine/godot/commit/5a90a3cd47
- Proposals: https://github.com/godotengine/godot-proposals/issues/ — 15346, 12119, 4754, 6646
- 3.x source: `drivers/gles3/shader_gles3.cpp`, `rasterizer_storage_gles3.cpp`, `servers/visual_server.cpp`, `doc/classes/ProjectSettings.xml`
- Docs:
  - https://docs.godotengine.org/en/stable/tutorials/performance/pipeline_compilations.html
  - https://docs.godotengine.org/en/stable/engine_details/development/compiling/compiling_for_web.html
- Build infrastructure:
  - https://github.com/godotengine/build-containers/blob/4.7/Dockerfile.web
  - https://github.com/godotengine/build-containers/blob/main/Dockerfile.web
  - https://github.com/godotengine/godot-build-scripts/blob/main/build-web/build.sh
  - https://github.com/godotengine/godot/blob/4.7.2-stable/.github/workflows/web_builds.yml

**Emscripten**
- `src/lib/libwebgl.js` and `src/settings.js` at tag 4.0.20, and `libwebgl.js` on main (github.com/emscripten-core/emscripten)

**Khronos / MDN**
- https://registry.khronos.org/webgl/extensions/KHR_parallel_shader_compile/
- https://registry.khronos.org/webgl/specs/latest/2.0/
- https://developer.mozilla.org/en-US/docs/Web/API/KHR_parallel_shader_compile
- https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/WebGL_best_practices
- MDN browser-compat-data: `api/KHR_parallel_shader_compile.json`, `api/GPUDevice.json`
- https://web3dsurvey.com/webgl/extensions/KHR_parallel_shader_compile

**Browser engines**
- Bug trackers:
  - https://bugzilla.mozilla.org/show_bug.cgi?id=1736076
  - https://bugzilla.mozilla.org/show_bug.cgi?id=918941
  - https://bugs.webkit.org/show_bug.cgi?id=251514
- ANGLE main: `src/libANGLE/Program.cpp`, `Display.cpp`, `renderer/metal/ProgramMtl.mm`, `renderer/metal/DisplayMtl.mm`, `include/platform/autogen/FeaturesMtl_autogen.h`
- WebKit main: `Source/ThirdParty/ANGLE/.../metal/DisplayMtl.mm`, `ProgramMtl.mm`
- Chromium main: `gpu/config/gpu_preferences.{h,cc}`, `gpu/ipc/common/gpu_disk_cache_type.h`, `gpu/ipc/service/gpu_channel_manager.cc`, `gpu/command_buffer/service/passthrough_program_cache.cc`

**Third-party (lower weight)**
- https://docs.wavedash.com/tutorials/shader-stutter
- https://store.godotengine.org/asset/robolabgs2/shader-stutter-tracker/
- https://store.godotengine.org/asset/lakamfo/fsib-shader-warmup-for-godot-4/
- https://vaalribbok.itch.io/web-export-test-tool-for-godot-4-2/devlog/640897/forced-shader-compilation
- https://forum.godotengine.org/t/handling-particle-shader-compilation-lag-in-godot-4-web-compatibility-renderer/36170
