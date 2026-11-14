#!/usr/bin/env node
// Checks the sound-effect prompt sheet and its tool (tools/sfx/, tools/generate-sfx)
// offline: no engine, no network, no API key, no audio left behind.
//
// - The sheet is valid, and the validator rejects each kind of broken sheet it
//   guards against (so a valid result means something).
// - The dry run requests nothing and prices every row; its tier and total
//   credits equal credits_per_second x seconds x candidates summed here.
// - The tool refuses, before any request: an --out inside the repository, an
//   --out it cannot check (no git, or a .git file pointing nowhere), a real run
//   without a key, and an ELEVENLABS_API_BASE other than the API's own hosts
//   or the loopback.
// - Against stand-ins for the ElevenLabs API on this machine's loopback:
//   - Requests carry the sheet's model and settings and the key (read from
//     ~/.config/elevenlabs/.env), and no more run at once than allowed.
//   - A 429 or 503 is waited out, and every attempt is logged. The summary's
//     credits equal the log's, with several requests at once.
//   - A rerun requests nothing. --force-id keeps the old set aside. It is
//     refused for a set not yet complete, and for a complete set the sheet's
//     current settings made unless --force-again is given.
//   - A redirect is not followed: the other host never sees the key.
//   - A 504, an answer lost while read, or an unwritable folder stops the run
//     after one request and is logged. A 401 stops it, and a request waiting
//     to retry is not sent.
//   - A run is refused while another holds the folder's lock, and the lock is
//     left alone. The lock may be held by a running tools/generate-sfx run, or
//     left behind by one whose pid has ended or was reused. A reused pid is
//     told by the start in clock ticks the lock stores, not by the wall clock.
//   - A first Ctrl-C, SIGTERM or SIGHUP saves the requests in flight; a second
//     Ctrl-C quits at once. With stdout closed, a run still saves, releases
//     its lock and exits 0.
//   - The key is never printed or logged.
//   Every other run points at a trap stand-in that must stay unused, so no
//   case can reach the real API.
// - Post-processing (ffmpeg, which .devcontainer/post-create.sh installs, must
//   be on PATH):
//   - A one-shot starts at its onset, is cut and is peak-normalised as decoded.
//   - A loop's end runs on into its start, or the loop is kept as generated
//     when its crossfade is 0.
//   - Picks choose the takes. Picks made only of the numbers recorded when
//     --force-id set their set aside are refused, whatever the file times; a
//     copied folder takes its picks. An id not in the sheet is named and ignored.
//   - A near-silent candidate is named, and the other takes and rows go on;
//     the run ends non-zero listing the failed rows.
//   - Audition verdicts in the pages' shapes: round 2 decides over round 1, a
//     pick overrides a mark, and a set made after the audition began goes in
//     only once picked or judged. First candidates nobody picked are listed
//     and marked picked: false.
//   - A run removes only takes it decided on (past what a processed row keeps,
//     a left-out row's) and retired rows' takes: never another row's, a
//     refused row's, or anything because the manifest does not list it.
//   - Raising a row's candidates adds new ones, made with the current prompt,
//     beside the old ones and their picks.
// - Git tracks no audio, and .gitignore keeps it out.
//
//   node tools/check_sfx.mjs
//
// Prints FAIL lines and exits 1 on any failure.

import { spawn, spawnSync } from "node:child_process";
import { createServer } from "node:http";
import { chmodSync, cpSync, existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, rmSync, symlinkSync, utimesSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { REPO_ROOT, SHEET_PATH, loadSheet, validateSheet } from "./sfx/generate_sfx.mjs";

const TOOL_MODULE = resolve(dirname(fileURLToPath(import.meta.url)), "sfx", "generate_sfx.mjs");
const WRAPPER = join(REPO_ROOT, "tools", "generate-sfx");
const failures = [];
const passes = [];
const check = (ok, text) => (ok ? null : failures.push(text));
// If the check itself breaks, it still says what had failed before.
const stopEarly = (error) => {
  for (const text of failures) console.log(`FAIL ${text}`);
  console.log(`FAIL sound effects: the check stopped early: ${error?.stack ?? error}`);
  process.exit(1);
};
process.on("uncaughtException", stopEarly);
process.on("unhandledRejection", stopEarly);
const AUDIO_RE = /\.(?:wav|ogg|oga|mp3|flac|opus|m4a|aac|aif|aiff|weba)(?:\.import)?$/iu;

// Our own temporary folder, removed however the check ends (a crash included).
const scratch = mkdtempSync(join(tmpdir(), "ti-sfx-check-"));
let cleaned = false;
const cleanUp = () => {
  if (cleaned) return;
  cleaned = true;
  spawnSync("chmod", ["-R", "u+rwx", scratch]);
  rmSync(scratch, { recursive: true, force: true });
};
process.on("exit", cleanUp);
for (const [signal, code] of [["SIGINT", 130], ["SIGTERM", 143]]) {
  process.on(signal, () => {
    cleanUp();
    process.exit(code);
  });
}

// The child's environment: no real key, no GIT_ variables, a HOME of our own.
const baseEnv = Object.fromEntries(Object.entries(process.env).filter(([key]) => !key.startsWith("ELEVENLABS_") && !key.startsWith("GIT_")));
const emptyHome = join(scratch, "home-empty");
const emptyPath = join(scratch, "path-empty");
const gitOnlyPath = join(scratch, "path-git-only");
for (const dir of [emptyHome, emptyPath, gitOnlyPath]) mkdirSync(dir);
const gitBinary = spawnSync("bash", ["-c", "command -v git"], { encoding: "utf8" }).stdout.trim();
if (gitBinary) symlinkSync(gitBinary, join(gitOnlyPath, "git"));
const key = "check-key-1a2b3c-not-real";
let trap = null;

function startTool(args, { env = {}, home = emptyHome, wrapper = false } = {}) {
  const child = spawn(wrapper ? "bash" : process.execPath, [wrapper ? WRAPPER : TOOL_MODULE, ...args], {
    cwd: REPO_ROOT,
    env: { ...baseEnv, HOME: home, ELEVENLABS_API_BASE: trap.base, ...env },
    stdio: ["ignore", "pipe", "pipe"],
  });
  let stdout = "";
  let stderr = "";
  child.stdout.on("data", (chunk) => { stdout += chunk; });
  child.stderr.on("data", (chunk) => { stderr += chunk; });
  const done = new Promise((finish) => child.on("close", (code, signal) => finish({ code, signal, stdout, stderr, all: stdout + stderr })));
  return { child, done };
}
const runTool = (args, options) => startTool(args, options).done;

const clone = (value) => JSON.parse(JSON.stringify(value));
const sleep = (ms) => new Promise((done) => setTimeout(done, ms).unref());
const listDir = (path) => (existsSync(path) ? readdirSync(path) : []);
const logText = (out) => (existsSync(join(out, "generation-log.jsonl")) ? readFileSync(join(out, "generation-log.jsonl"), "utf8") : "");
const logOf = (out) => logText(out).split("\n").filter(Boolean).map((line) => JSON.parse(line));

// --- Stand-ins for the API ------------------------------------------------------

const MAGIC = { wav: Buffer.from("RIFF\0\0\0\0WAVEfmt "), mp3: Buffer.from("ID3\u0004\0\0\0\0\0\0") };

async function startStandIn(answer, { delayMs = 60, onArrival } = {}) {
  const state = { requests: [], inFlight: 0, maxInFlight: 0 };
  const server = createServer(async (request, response) => {
    state.inFlight += 1;
    state.maxInFlight = Math.max(state.maxInFlight, state.inFlight);
    let body = "";
    for await (const chunk of request) body += chunk;
    const url = new URL(request.url, "http://stand-in");
    let json = null;
    try {
      json = JSON.parse(body);
    } catch {
      // Recorded as null; the assertions below report it.
    }
    const seen = { method: request.method, path: url.pathname, format: url.searchParams.get("output_format"), key: request.headers["xi-api-key"], body: json };
    const arrival = state.requests.push(seen);
    onArrival?.(arrival);
    await sleep(delayMs);
    state.inFlight -= 1;
    if (request.socket.destroyed) return;
    const reply = answer(seen, arrival);
    if (reply.cut) {
      // An answer that breaks off: headers and a little audio, then the connection drops.
      response.writeHead(200, { "content-type": "audio/wav", "content-length": "100000" });
      response.write(Buffer.alloc(100));
      setTimeout(() => request.socket.destroy(), 20).unref();
      return;
    }
    response.writeHead(reply.status, reply.headers ?? {});
    response.end(reply.body ?? "");
  });
  await new Promise((done) => server.listen(0, "127.0.0.1", done));
  state.base = `http://127.0.0.1:${server.address().port}`;
  state.close = () => {
    server.closeAllConnections();
    return new Promise((done) => server.close(done));
  };
  return state;
}

const audioReply = (seen) => {
  const kind = (seen.format ?? "").split("_")[0];
  return { status: 200, headers: { "content-type": kind === "wav" ? "audio/wav" : "audio/mpeg" }, body: Buffer.concat([MAGIC[kind] ?? Buffer.from("?"), Buffer.from(JSON.stringify(seen.body ?? {}))]) };
};
const errorReply = (status, headers = {}, body = "{}") => ({ status, headers: { "content-type": "application/json", ...headers }, body });

// A trap every run points at unless it names its own stand-in: it must never be reached.
trap = await startStandIn(() => errorReply(418, {}, "{\"detail\":\"the trap stand-in: a run reached an API it should not have\"}"));

// --- 1. The sheet ------------------------------------------------------------

const { sheet, problems } = loadSheet(SHEET_PATH);
if (!sheet) {
  console.log(`FAIL ${problems.join("; ")}`);
  process.exit(1);
}
for (const text of problems) failures.push(`tools/sfx/prompts.json: ${text}`);
if (!problems.length) {
  const longest = Math.max(...sheet.sounds.map((row) => row.prompt.length));
  passes.push(`sheet valid: ${sheet.sounds.length} sounds, longest prompt ${longest} characters, every event voiced or explained`);
}

// Each broken copy must be rejected with the matching reason.
{
  const loopRow = sheet.sounds.findIndex((row) => row.loop);
  const shotRow = sheet.sounds.findIndex((row) => !row.loop);
  const shotRecipe = Object.keys(sheet.recipes).find((name) => !Object.hasOwn(sheet.recipes[name], "loop_crossfade_ms"));
  const loopRecipe = Object.keys(sheet.recipes).find((name) => Object.hasOwn(sheet.recipes[name], "loop_crossfade_ms"));
  const broken = [
    ["a repeated id", (s) => { s.sounds[1].id = s.sounds[0].id; }, "id is used twice"],
    ["a 31 s duration", (s) => { s.sounds[shotRow].duration_seconds = 31; }, "duration_seconds must be from"],
    ["a 0.4 s duration", (s) => { s.sounds[shotRow].duration_seconds = 0.4; }, "duration_seconds must be from"],
    ["a 451-character prompt", (s) => { s.sounds[shotRow].prompt = `High-quality foley ${"x".repeat(451)}`.slice(0, 451); }, "at most 450"],
    ["a loop row with a one-shot recipe", (s) => { s.sounds[loopRow].recipe = shotRecipe; }, "a loop row needs a loop recipe"],
    ["a one-shot row with a loop recipe", (s) => { s.sounds[shotRow].recipe = loopRecipe; }, "a one-shot row needs a one-shot recipe"],
    ["a car prompt without the car", (s) => { s.sounds[shotRow].prompt = "High-quality recording of a car door closing."; }, "mentions a car without naming"],
    ["loop in the prompt text", (s) => { s.sounds[loopRow].prompt += " Make it loop."; }, "says loop in the text"],
    ["a length in the prompt text", (s) => { s.sounds[shotRow].prompt += " About 3 seconds long."; }, "gives a length in the text"],
    ["a number of repetitions", (s) => { s.sounds[shotRow].prompt = "High-quality foley of four footsteps on gravel."; }, "number of repetitions"],
    ["an event nobody voices", (s) => { s.events.Z9 = "An event added for the check"; }, "neither voiced by a sound nor listed"],
    ["an unknown event", (s) => { s.sounds[shotRow].events = ["Z8"]; }, "unknown event Z8"],
    ["no model_id", (s) => { delete s.model_id; }, "model_id must name the model"],
    ["an output used twice", (s) => { s.sounds[1].output = s.sounds[0].output; }, "is used twice"],
    ["an unknown row field", (s) => { s.sounds[shotRow].duration = 1; }, "unknown field duration"],
    ["a loop too short for its crossfade", (s) => { s.sounds[loopRow].duration_seconds = 0.5; }, "too short for the recipe's"],
    ["WAV for loops", (s) => { s.output_format.loop = "wav_48000"; }, "output_format.loop must be an MP3 format"],
    ["a format the plan cannot use", (s) => { s.output_format.one_shot = "wav_44100"; }, "needs the Pro plan"],
    ["a format the API does not offer", (s) => { s.output_format.one_shot = "mp3_44100_320"; }, "must be one of the API's MP3 or WAV formats"],
    ["an unknown plan", (s) => { s.plan.name = "Hobby"; }, "plan.name must be one of"],
    ["a negative crossfade", (s) => { s.recipes[loopRecipe].loop_crossfade_ms = -1; }, "loop_crossfade_ms must be 0"],
    ["a row without level_db", (s) => { delete s.sounds[shotRow].level_db; }, "level_db must be a number"],
    ["an unknown loudness class", (s) => { s.sounds[shotRow].loudness_class = "deafening"; }, "unknown loudness class deafening"],
    ["a row of the quietest class at the loudest class's level", (s) => {
      const quietest = s.loudness.classes.at(-1).name;
      s.sounds.find((row) => row.loudness_class === quietest).level_db = s.loudness.classes[0].max_db;
    }, "outside its loudness class"],
    ["loudness classes from quietest to loudest", (s) => { s.loudness.classes.reverse(); }, "from loudest to quietest"],
    ["overlapping loudness classes", (s) => { s.loudness.classes[1].max_db = s.loudness.classes[0].min_db + 1; }, "from loudest to quietest"],
    ["no loudness classes", (s) => { delete s.loudness; }, "loudness must give"],
    ["a retired output a sound still uses", (s) => { s.retired_outputs = { [s.sounds[shotRow].output]: "A row the check pretends was dropped." }; }, "is still a sound's output"],
    ["a retired output not shaped like one", (s) => { s.retired_outputs = { "coins.ogg": "A row the check pretends was dropped." }; }, "must be like group/name_{take}.ogg"],
  ];
  let caught = 0;
  for (const [what, mutate, expected] of broken) {
    const copy = clone(sheet);
    mutate(copy);
    const found = validateSheet(copy);
    if (found.some((text) => text.includes(expected))) caught += 1;
    else failures.push(`the sheet validator accepted ${what} (expected "${expected}", got: ${found.join("; ") || "no problems"})`);
  }
  const keepAsIs = clone(sheet);
  keepAsIs.recipes[loopRecipe].loop_crossfade_ms = 0;
  check(validateSheet(keepAsIs).length === 0, `the validator refused loop_crossfade_ms 0 (keep the loop as generated): ${validateSheet(keepAsIs).join("; ")}`);
  if (caught === broken.length) passes.push(`validator rejects all ${broken.length} kinds of broken sheet and accepts a loop kept as generated`);
}

// A small valid sheet, so these checks do not depend on the real sheet's rows.
function fixtureSheet() {
  return {
    schema_version: sheet.schema_version,
    notes: ["A fixture for tools/check_sfx.mjs."],
    model_id: sheet.model_id,
    credits_per_second: sheet.credits_per_second,
    plan: { name: "Creator", credits_per_month: 100000, concurrency: 3 },
    output_format: { one_shot: "wav_48000", loop: "mp3_44100_192" },
    car: { name: "Fixture Car", basis: "production_inference", why: "A fixture." },
    encode: { codec: "libvorbis", quality: 5, sample_rate: 44100 },
    loudness: {
      measure: "A fixture.",
      within_row_spread_lu: 1,
      classes: [
        { name: "crash", max_db: -3, min_db: -12, what: "The loudest." },
        { name: "mid", max_db: -12, min_db: -30, what: "The middle." },
        { name: "quiet", max_db: -30, min_db: -50, what: "The quietest." },
      ],
    },
    recipes: {
      shot: { what: "A short transient.", channels: 1, trim_start_db: -50, trim_end_db: -55, max_seconds: 0.3, fade_in_ms: 2, fade_out_ms: 40, peak_dbfs: -1 },
      bed: { what: "A loop.", channels: 1, trim_start_db: -90, trim_end_db: -90, loop_crossfade_ms: 150, peak_dbfs: -1 },
      bed_raw: { what: "A loop kept as generated.", channels: 1, trim_start_db: -90, trim_end_db: -90, loop_crossfade_ms: 0, peak_dbfs: -1 },
      hit: { what: "A one-shot that starts at its impact.", channels: 1, trim_start_db: -12, trim_end_db: -60, max_seconds: null, fade_in_ms: 2, fade_out_ms: 40, peak_dbfs: -1 },
    },
    events: { T1: "A test event.", T2: "Another test event.", T3: "A third test event.", T4: "A fourth test event." },
    not_voiced: {},
    retired_outputs: { "test/coin_{take}.ogg": "A fixture row since dropped." },
    sounds: [
      { id: "shot", tier: 1, events: ["T1"], prompt: "High-quality foley one-shot: a single knock on a wooden door, close-miked.", duration_seconds: 0.5, loop: false, prompt_influence: 0.5, keep_takes: 2, candidates_per_take: 2, output: "test/shot_{take}.ogg", recipe: "shot", loudness_class: "mid", level_db: -24 },
      { id: "bed", tier: 2, events: ["T2"], prompt: "Ambience: soft steady rain on a tin roof, recorded close.", duration_seconds: 3.0, loop: true, prompt_influence: 0.35, keep_takes: 1, candidates_per_take: 3, output: "test/bed_{take}.ogg", recipe: "bed", loudness_class: "quiet", level_db: -36 },
      { id: "bed_raw", tier: 3, events: ["T3"], prompt: "Ambience: the steady low hum of a small electric fan, recorded close.", duration_seconds: 2.0, loop: true, prompt_influence: 0.35, keep_takes: 1, candidates_per_take: 1, output: "test/bed_raw_{take}.ogg", recipe: "bed_raw", loudness_class: "quiet", level_db: -40 },
      { id: "hit", tier: 3, events: ["T4"], prompt: "High-quality foley impact: a heavy wooden crate dropped onto concrete, close-miked.", duration_seconds: 0.5, loop: false, prompt_influence: 0.5, keep_takes: 1, candidates_per_take: 1, output: "test/hit_{take}.ogg", recipe: "hit", loudness_class: "crash", level_db: -4 },
    ],
  };
}

const fixturePath = join(scratch, "fixture-sheet.json");
writeFileSync(fixturePath, `${JSON.stringify(fixtureSheet(), null, 2)}\n`);
const fixture = fixtureSheet();
check(validateSheet(fixture).length === 0, `the fixture sheet is invalid: ${validateSheet(fixture).join("; ")}`);
const generationsOf = (row) => row.keep_takes * row.candidates_per_take;
const fixtureGenerations = fixture.sounds.reduce((sum, row) => sum + generationsOf(row), 0);
const shotRow = fixture.sounds.find((row) => row.id === "shot");
const shotGenerations = generationsOf(shotRow);
const candidate = (row, n) => `candidates/${row.id}/${row.id}.c${String(n).padStart(2, "0")}.${(row.loop ? fixture.output_format.loop : fixture.output_format.one_shot).split("_")[0]}`;
const shotCandidates = (out) => listDir(join(out, "candidates", "shot")).filter((name) => /^shot\.c\d\d\.wav$/u.test(name)).sort();
const asideOf = (out) => listDir(join(out, "candidates", "shot")).filter((name) => name.startsWith("replaced-"));
const withKey = (api) => ({ ELEVENLABS_API_BASE: api.base, ELEVENLABS_API_KEY: key });

// --- 2. Dry run and refusals -----------------------------------------------------

{
  const dry = await runTool(["--out", join(scratch, "dry")]);
  const viaWrapper = await runTool(["--out", join(scratch, "dry")], { wrapper: true });
  check(dry.code === 0, `the dry run exited ${dry.code}: ${dry.stderr.trim()}`);
  check(dry.stdout.includes("Dry run: nothing was requested."), "the dry run did not say it requested nothing");
  check(!existsSync(join(scratch, "dry")), "the dry run created its --out directory");
  const sum = (rows) => rows.reduce((total, row) => total + sheet.credits_per_second * row.duration_seconds * row.keep_takes * row.candidates_per_take, 0);
  const number = (text) => Number(text.replaceAll(",", ""));
  const total = dry.stdout.match(/^total: \d+ sounds?, \d+ generations?, ([\d,]+) credits; to make: ([\d,]+)/mu);
  check(total && number(total[1]) === Math.round(sum(sheet.sounds)) && number(total[2]) === number(total[1]), `the dry run's total line ${total?.[0] ?? "is missing"}; expected ${Math.round(sum(sheet.sounds))} credits, all still to make`);
  for (const tier of [1, 2, 3]) {
    const rows = sheet.sounds.filter((row) => row.tier === tier);
    if (!rows.length) continue;
    const line = dry.stdout.match(new RegExp(`^tier ${tier}: .*?, ([\\d,]+) credits;`, "mu"));
    check(line && number(line[1]) === Math.round(sum(rows)), `the dry run's tier ${tier} line ${line?.[0] ?? "is missing"}; expected ${Math.round(sum(rows))} credits`);
  }
  const missingRows = sheet.sounds.filter((row) => !new RegExp(`^${row.id} +${row.tier} `, "mu").test(dry.stdout));
  check(!missingRows.length, `the dry run did not list ${missingRows.map((row) => row.id).join(", ")}`);
  check(viaWrapper.code === 0 && viaWrapper.stdout === dry.stdout, `tools/generate-sfx (the wrapper) exited ${viaWrapper.code} or printed something else than the module: ${viaWrapper.stderr.trim()}`);
  check(dry.stdout.includes(`Requests go to ${trap.base}`), "a non-default ELEVENLABS_API_BASE was not printed");
  if (total) passes.push(`dry run lists every sound; ${total[0].replace(/^total: /u, "")}`);

  const inRepo = await runTool(["--out", join(REPO_ROOT, "build", "sfx-check-out"), "--generate"], { env: { ELEVENLABS_API_KEY: key } });
  check(inRepo.code === 2 && inRepo.stderr.includes("refusing --out"), `an --out inside the repository was not refused (exit ${inRepo.code}): ${inRepo.all.trim()}`);
  const noGit = await runTool(["--out", join(scratch, "no-git")], { env: { PATH: emptyPath } });
  check(noGit.code === 2 && noGit.stderr.includes("git could not run"), `an --out that git could not check was not refused (exit ${noGit.code}): ${noGit.all.trim()}`);
  // Under a .git file that points nowhere git answers "not a git repository: (null)",
  // not its answer for a folder in no repository, so the folder is refused.
  const dangling = join(scratch, "dangling-gitfile");
  mkdirSync(dangling);
  writeFileSync(join(dangling, ".git"), "gitdir: /nonexistent/ti-sfx-check\n");
  const danglingRun = await runTool(["--out", join(dangling, "out")]);
  check(danglingRun.code === 2 && danglingRun.stderr.includes("git could not tell"), `an --out under a .git file pointing nowhere was not refused (exit ${danglingRun.code}): ${danglingRun.all.trim()}`);
  const noKeyOut = join(scratch, "no-key");
  const noKey = await runTool(["--out", noKeyOut, "--generate"]);
  check(noKey.code === 1 && noKey.stderr.includes("needs ELEVENLABS_API_KEY") && noKey.stderr.includes("nothing was requested"), `a real run without a key was not refused (exit ${noKey.code}): ${noKey.stderr.trim()}`);
  check(!existsSync(noKeyOut), "a refused real run created its --out directory");
  const usage = await runTool([]);
  check(usage.code === 2 && usage.stderr.includes("--out DIR is required"), `a run without --out exited ${usage.code}`);
  passes.push("refuses an in-repository --out, one git cannot check and one under a .git file pointing nowhere (exit 2), and a real run without a key (exit 1)");

  // ELEVENLABS_API_BASE: only the API's documented hosts, or http on the loopback.
  const refusedBases = ["https://example.com", "https://api.elevenlabs.io.example.com", "https://api.elevenlabs.io:8443", "http://api.elevenlabs.io", "https://user:secret@api.elevenlabs.io", "https://api.elevenlabs.io/v2", "not a url"];
  for (const base of refusedBases) {
    const result = await runTool(["--out", join(scratch, "base")], { env: { ELEVENLABS_API_BASE: base } });
    check(result.code === 2 && result.stderr.includes("ELEVENLABS_API_BASE"), `ELEVENLABS_API_BASE=${base} was accepted (exit ${result.code})`);
  }
  const residency = await runTool(["--out", join(scratch, "base")], { env: { ELEVENLABS_API_BASE: "https://api.eu.residency.elevenlabs.io" } });
  check(residency.code === 0 && residency.stdout.includes("Requests go to https://api.eu.residency.elevenlabs.io"), `the EU residency host was refused or not printed (exit ${residency.code}): ${residency.stderr.trim()}`);
  passes.push(`refuses ${refusedBases.length} other ELEVENLABS_API_BASE values; accepts and prints a documented residency host`);
}

// --- 3. Generation against stand-ins --------------------------------------------

{
  const home = join(scratch, "home-with-key");
  mkdirSync(join(home, ".config", "elevenlabs"), { recursive: true });
  writeFileSync(join(home, ".config", "elevenlabs", ".env"), `# test\nexport ELEVENLABS_API_KEY="${key}"\n`);
  const out = join(scratch, "gen");
  let throttled = 0;
  const api = await startStandIn((seen, arrival) => {
    if (arrival <= 2) {
      throttled += 1;
      return errorReply(429, { "retry-after": "0" }, JSON.stringify({ detail: { status: "too_many_concurrent_requests" } }));
    }
    return audioReply(seen);
  });
  const env = { ELEVENLABS_API_BASE: api.base };
  const first = await runTool(["--out", out, "--generate", "--sheet", fixturePath, "--concurrency", "2"], { env, home });
  check(first.code === 0, `generation against the stand-in exited ${first.code}: ${first.stderr.trim()}`);
  check(throttled === 2 && first.stderr.includes("HTTP 429"), "the 429 answers were not waited out with a NOTE");
  const firstAtOnce = api.maxInFlight;
  check(firstAtOnce <= 2, `${firstAtOnce} requests ran at once with --concurrency 2`);
  const answered = api.requests.slice(throttled);
  check(answered.length === fixtureGenerations, `${answered.length} answered requests for ${fixtureGenerations} candidates`);
  for (const seen of api.requests) {
    const row = fixture.sounds.find((item) => item.prompt === seen.body?.text);
    const ok = seen.method === "POST" && seen.path === "/v1/sound-generation" && seen.key === key && row
      && seen.body.model_id === fixture.model_id && seen.body.duration_seconds === row.duration_seconds && seen.body.loop === row.loop
      && seen.body.prompt_influence === row.prompt_influence && seen.format === (row.loop ? fixture.output_format.loop : fixture.output_format.one_shot);
    if (!ok) {
      failures.push(`a request did not carry the sheet's model, settings and key: ${JSON.stringify({ ...seen, key: seen.key === key ? "(the key)" : "(something else)" })}`);
      break;
    }
  }
  const entries = logOf(out);
  for (const row of fixture.sounds) {
    for (let n = 1; n <= generationsOf(row); n += 1) {
      const file = candidate(row, n);
      check(existsSync(join(out, file)), `candidate ${file} was not written`);
      const entry = entries.find((item) => item.file === file && item.status === "ok");
      check(entry && entry.id === row.id && entry.prompt === row.prompt && entry.model_id === fixture.model_id && entry.duration_seconds === row.duration_seconds
        && entry.loop === row.loop && entry.prompt_influence === row.prompt_influence && entry.credits === fixture.credits_per_second * row.duration_seconds && !Number.isNaN(Date.parse(entry.time)),
      `the generation log has no complete line for ${file}`);
    }
  }
  const retries = entries.filter((item) => item.status === "retry" && item.http_status === 429);
  check(retries.length === throttled, `the log has ${retries.length} lines for the ${throttled} throttled attempts; every attempt must be logged`);
  check(!listDir(join(out, "candidates", "shot")).some((name) => name.endsWith(".part")), "a .part file was left behind");
  check(!existsSync(join(out, ".generate.lock")), "the run left its lock behind");
  // The summary's credits, made with 2 requests at once, equal the log's.
  const logged = entries.filter((item) => item.status === "ok").reduce((sum, item) => sum + item.credits, 0);
  const summary = first.stdout.match(/^Made (\d+) candidates? for ([\d,]+) credits\./mu);
  check(summary && Number(summary[1]) === fixtureGenerations && Number(summary[2].replaceAll(",", "")) === logged, `the run's summary (${summary?.[0] ?? "missing"}) does not match the log: ${fixtureGenerations} candidates for ${logged} credits`);

  const before = api.requests.length;
  const again = await runTool(["--out", out, "--generate", "--sheet", fixturePath], { env, home });
  check(again.code === 0 && again.stdout.includes("Nothing to make") && api.requests.length === before, `a second run requested ${api.requests.length - before} more candidates (exit ${again.code})`);

  // Forcing a complete set the sheet's current settings made would buy the same
  // set again: refused without a request or a move, unless --force-again.
  writeFileSync(join(out, "candidates", "shot", "shot.c07.wav"), MAGIC.wav);
  writeFileSync(join(out, "picks.json"), JSON.stringify({ shot: [1] }));
  const same = await runTool(["--out", out, "--generate", "--sheet", fixturePath, "--force-id", "shot"], { env, home });
  check(same.code === 2 && same.stderr.includes("add --force-again") && api.requests.length === before && !asideOf(out).length && shotCandidates(out).length === shotGenerations + 1,
    `--force-id on a complete set made with the sheet's current settings was not refused before any request or move (exit ${same.code}, ${api.requests.length - before} requests): ${same.stderr.trim()}`);
  // With --force-again: a candidate numbered past the row's count (made when it
  // had more) goes aside with the rest, and a pick on the forced row is pointed out.
  api.maxInFlight = 0;
  const forced = await runTool(["--out", out, "--generate", "--sheet", fixturePath, "--force-id", "shot", "--force-again"], { env, home });
  check(api.maxInFlight <= fixture.plan.concurrency, `${api.maxInFlight} requests ran at once; the plan allows ${fixture.plan.concurrency}`);
  const aside = asideOf(out)[0];
  check(forced.code === 0 && api.requests.length === before + shotGenerations, `--force-id shot made ${api.requests.length - before} requests (exit ${forced.code}); expected ${shotGenerations}`);
  check(aside && listDir(join(out, "candidates", "shot", aside)).length === shotGenerations + 1 && !existsSync(join(out, "candidates", "shot", "shot.c07.wav")),
    `--force-id did not keep every earlier candidate aside, the one numbered past the row's count included: ${aside ? listDir(join(out, "candidates", "shot", aside)).join(", ") : "nothing aside"}`);
  check(!existsSync(join(out, "candidates", "shot", ".forced")), "a complete forced set is still marked as in progress");
  check(forced.stderr.includes("NOTE: picks.json picks shot c01") && forced.stderr.includes("--process refuses shot"), `forcing a picked row did not point out that its picks now name an unheard set: ${forced.stderr.trim()}`);

  const printed = [first, again, forced].map((result) => result.all).join("\n");
  check(!printed.includes(key) && !logText(out).includes(key), "the API key was printed or logged");
  await api.close();
  passes.push(`generation: model and settings sent, key read from ~/.config/elevenlabs/.env, ${firstAtOnce} at once with --concurrency 2 and ${api.maxInFlight} by the plan's ${fixture.plan.concurrency}, 429s waited out and logged, summary and log agree on ${logged} credits, rerun requested nothing, --force-id of a set the current settings made refused, with --force-again it kept ${shotGenerations} aside`);
}

// Repeating a --force-id whose fresh set is unfinished is refused; the printed command finishes it.
{
  const out = join(scratch, "forced");
  const full = await startStandIn(audioReply);
  const made = await runTool(["--out", out, "--generate", "--sheet", fixturePath, "--id", "shot"], { env: withKey(full) });
  check(made.code === 0 && shotCandidates(out).length === shotGenerations, `the first shot set was not made (exit ${made.code})`);
  const stopping = await startStandIn((seen, arrival) => (arrival === 1 ? audioReply(seen) : errorReply(401, {}, "{\"detail\":\"invalid_api_key\"}")));
  // The first set was made with the current settings, so forcing it takes --force-again,
  // which must not let a repeat move the unfinished fresh set aside.
  const forceArgs = ["--out", out, "--generate", "--sheet", fixturePath, "--id", "shot", "--force-id", "shot", "--force-again", "--concurrency", "1"];
  const broken = await runTool(forceArgs, { env: withKey(stopping) });
  check(broken.code === 1 && shotCandidates(out).length === 1, `the forced run did not stop after one new candidate (exit ${broken.code}, ${shotCandidates(out).length} on disk)`);
  check(/To resume[^\n]*--generate/u.test(broken.stderr) && !/To resume[^\n]*--force-id/u.test(broken.stderr), `the stop message does not give a resume command without --force-id: ${broken.stderr.trim()}`);
  const asideBefore = asideOf(out).length;
  const before = stopping.requests.length;
  const repeat = await runTool(forceArgs, { env: withKey(stopping) });
  check(repeat.code === 2 && repeat.stderr.includes("Finish it without --force-id") && stopping.requests.length === before, `repeating --force-id shot on an unfinished set was not refused (exit ${repeat.code}, ${stopping.requests.length - before} requests): ${repeat.stderr.trim()}`);
  check(shotCandidates(out).length === 1 && asideOf(out).length === asideBefore, "the refused --force-id moved the new paid candidate aside");
  const finish = await runTool(["--out", out, "--generate", "--sheet", fixturePath, "--id", "shot", "--concurrency", "1"], { env: withKey(full) });
  check(finish.code === 0 && shotCandidates(out).length === shotGenerations && !existsSync(join(out, "candidates", "shot", ".forced")), `the run without --force-id did not finish the forced set (exit ${finish.code})`);
  // Finished, the set was made with the sheet's current settings: forcing it
  // again is refused (a dry run says so too) unless --force-again.
  const again = await runTool(["--out", out, "--sheet", fixturePath, "--id", "shot", "--force-id", "shot"]);
  check(again.code === 2 && again.stderr.includes("would pay for the same set again"), `--force-id of its finished set, made with the current settings, was not refused (exit ${again.code}): ${again.all.trim()}`);
  const forceAgain = await runTool(["--out", out, "--sheet", fixturePath, "--id", "shot", "--force-id", "shot", "--force-again"]);
  const fullCost = Math.round(fixture.credits_per_second * shotRow.duration_seconds * shotGenerations);
  check(forceAgain.code === 0 && forceAgain.stdout.includes(`to make: ${fullCost} `), `--force-id with --force-again did not price a whole fresh set of ${fullCost} credits (exit ${forceAgain.code}): ${forceAgain.all.trim()}`);
  const stray = await runTool(["--out", out, "--sheet", fixturePath, "--force-again"]);
  check(stray.code === 2 && stray.stderr.includes("--force-again goes with --force-id"), `--force-again without --force-id was accepted (exit ${stray.code})`);
  await full.close();
  await stopping.close();
  passes.push("repeating an unfinished --force-id is refused without a request; the command without it finishes the set; forcing the finished set again needs --force-again");
}

// Answers that stop the run after one request, each logged; a 503 is waited out.
{
  const elsewhere = await startStandIn(audioReply);
  const cases = [
    ["a 307 redirect", () => errorReply(307, { location: `${elsewhere.base}/v1/sound-generation` }), "redirect", 307],
    ["a 302 redirect", () => errorReply(302, { location: `${elsewhere.base}/v1/sound-generation` }), "redirect", 302],
    ["a 504", () => errorReply(504, { "retry-after": "0" }, "{\"detail\":\"gateway timeout\"}"), "may have been charged", 504],
    ["an answer cut off while read", () => ({ cut: true }), "lost while it was read", 200],
  ];
  for (const [what, answer, said, status] of cases) {
    const out = join(scratch, `stop-${status}-${what.length}`);
    const api = await startStandIn(answer);
    const result = await runTool(["--out", out, "--generate", "--sheet", fixturePath, "--id", "shot", "--concurrency", "1"], { env: withKey(api) });
    const entries = logOf(out);
    check(result.code === 1 && result.stderr.includes(said) && api.requests.length === 1, `${what} did not stop the run after one request (exit ${result.code}, ${api.requests.length} requests): ${result.stderr.trim()}`);
    check(entries.some((entry) => entry.status === "error" && entry.http_status === status && entry.attempt === 1), `${what} was not logged as an error`);
    check(!shotCandidates(out).length, `${what} left a candidate on disk`);
    await api.close();
  }
  check(elsewhere.requests.length === 0, `a redirect was followed: the other host got ${elsewhere.requests.length} requests${elsewhere.requests.some((seen) => seen.key === key) ? ", with the key" : ""}`);
  await elsewhere.close();

  const busyOut = join(scratch, "busy");
  const busy = await startStandIn((seen, arrival) => (arrival === 1 ? errorReply(503, { "retry-after": "0" }) : audioReply(seen)));
  const waited = await runTool(["--out", busyOut, "--generate", "--sheet", fixturePath, "--id", "shot", "--concurrency", "1"], { env: withKey(busy) });
  check(waited.code === 0 && busy.requests.length === shotGenerations + 1 && logOf(busyOut).some((entry) => entry.status === "retry" && entry.http_status === 503), `a 503 was not waited out and logged (exit ${waited.code}, ${busy.requests.length} requests)`);
  await busy.close();

  if (process.getuid?.() === 0) {
    console.log("NOTE sfx: running as root, so a folder cannot be made unwritable; that case was not checked");
  } else {
    const out = join(scratch, "unwritable");
    const folder = join(out, "candidates", "shot");
    mkdirSync(folder, { recursive: true });
    chmodSync(folder, 0o555);
    const api = await startStandIn(audioReply);
    let result;
    try {
      result = await runTool(["--out", out, "--generate", "--sheet", fixturePath, "--id", "shot", "--concurrency", "1"], { env: withKey(api) });
    } finally {
      chmodSync(folder, 0o755);
    }
    check(result.code === 1 && result.stderr.includes("could not be saved") && api.requests.length === 1, `an unwritable folder did not stop the run after one request (exit ${result.code}, ${api.requests.length} requests)`);
    check(logOf(out).some((entry) => entry.status === "error" && /writing .* failed/u.test(entry.error ?? "")), "the failed write was not logged");
    await api.close();
  }
  passes.push("a 307 or 302 is not followed (the other host saw nothing); a 504, a cut answer and an unwritable folder stop after one request; each is logged; a 503 is waited out");
}

// A 401 stops the run and a request waiting out a 429 is not sent after the stop;
// the key never shows, even when the answer echoes it.
{
  const out = join(scratch, "denied");
  const api = await startStandIn((seen, arrival) => (arrival === 1
    ? errorReply(429, { "retry-after": "1" })
    : errorReply(401, {}, JSON.stringify({ detail: { status: "invalid_api_key", message: `Invalid API key: ${key}` } }))));
  const denied = await runTool(["--out", out, "--generate", "--sheet", fixturePath, "--concurrency", "2"], { env: withKey(api) });
  const log = logText(out);
  check(denied.code === 1 && denied.stderr.includes("HTTP 401") && denied.stderr.includes("[key]"), `a 401 did not stop the run with its status (exit ${denied.code}): ${denied.stderr.trim()}`);
  check(api.requests.length === 2, `the run sent ${api.requests.length} requests; after the 401 the one waiting out its 429 should not have been sent again`);
  check(!denied.all.includes(key) && !log.includes(key), "the API key echoed in an error was printed or logged");
  check(log.includes("\"status\":\"error\""), "the stopping error was not logged");
  await api.close();
  if (denied.code === 1 && api.requests.length === 2) passes.push("an HTTP 401 stops the run; a request waiting out a 429 is not sent after the stop; the echoed key is redacted");
}

// A process's start in clock ticks since boot, read here from Linux's /proc
// (field 22 of /proc/<pid>/stat, counted after the ")" that ends the name).
const hasProc = existsSync("/proc/self/stat");
const ticksOf = (pid) => {
  const stat = readFileSync(`/proc/${pid}/stat`, "utf8");
  return Number(stat.slice(stat.lastIndexOf(")") + 2).split(" ")[19]);
};

// The output folder's lock holds its owner's pid and start ticks. A running
// tools/generate-sfx owner refuses another run whatever the wall clock says,
// naming the lock to delete if that pid is something else. A lock is reported
// as left behind when its pid can never run, is now another program, or started
// at other ticks (the pid was reused). Either way the lock is left as it was and
// nothing is requested.
{
  const api = await startStandIn(audioReply);
  // Above Linux's largest possible pid (PID_MAX_LIMIT, 2^22) and macOS's (99998): never a live process.
  const NEVER_A_PID = 2 ** 22 + 1;
  // A stand-in for a run of the tool: a live process whose command names generate_sfx.mjs.
  const holder = spawn(process.execPath, ["-e", "setTimeout(() => {}, 120000)", "generate_sfx.mjs"], { stdio: "ignore" });
  await new Promise((done, fail) => {
    holder.once("spawn", done);
    holder.once("error", fail);
  });
  const now = new Date().toISOString();
  const cases = [["a lock whose pid can never run", { pid: NEVER_A_PID, start_ticks: 1, started: now }, "has ended", false]];
  if (hasProc) {
    const ticks = ticksOf(holder.pid);
    cases.push(
      ["a lock held by a running generate-sfx run", { pid: holder.pid, start_ticks: ticks, started: now }, "another --generate run", true],
      ["a running owner's lock dated years off (a clock step)", { pid: holder.pid, start_ticks: ticks, started: "2020-01-01T00:00:00.000Z" }, "another --generate run", true],
      ["a running owner's lock written without /proc (no start)", { pid: holder.pid, start_ticks: null, started: now }, "another --generate run", true],
      ["a lock whose pid is now another program", { pid: process.pid, start_ticks: ticksOf(process.pid), started: now }, "is now a different process", false],
      ["a lock from an earlier process with the same pid", { pid: holder.pid, start_ticks: ticks - 1, started: now }, "is now a different process", false],
    );
  } else {
    console.log("NOTE sfx: no /proc here, so a running lock owner cannot be told from a reused pid; those cases were not checked");
  }
  try {
    for (const [index, [what, holding, said, live]] of cases.entries()) {
      const out = join(scratch, `lock-${index}`);
      const path = join(out, ".generate.lock");
      mkdirSync(out, { recursive: true });
      const lock = `${JSON.stringify(holding)}\n`;
      writeFileSync(path, lock);
      const result = await runTool(["--out", out, "--generate", "--sheet", fixturePath, "--id", "shot"], { env: withKey(api) });
      check(result.code === 1 && result.stderr.includes(said), `${what} did not refuse the run as "${said}" (exit ${result.code}): ${result.stderr.trim()}`);
      if (live) check(result.stderr.includes(`delete ${path}`), `${what}: the message does not say which lock to delete if pid ${holding.pid} is not a generate-sfx run: ${result.stderr.trim()}`);
      check(existsSync(path) && readFileSync(path, "utf8") === lock, `${what}: the lock was changed or deleted`);
    }
  } finally {
    holder.kill();
  }
  check(api.requests.length === 0, `a locked folder still sent ${api.requests.length} requests`);
  await api.close();
  passes.push(`${cases.length} locks refused the run and were left as they were: a running generate-sfx owner by its start ticks (a clock step, or no ticks stored, changing nothing), and as left behind a pid that can never run, a pid now another program and an earlier process at the same pid`);
}

// A first Ctrl-C, SIGTERM or SIGHUP lets the requests in flight finish and saves
// them, starts no more and releases the lock; a second Ctrl-C quits at once.
// Meanwhile the lock holds the run's own pid and start ticks.
{
  for (const [signal, code] of [["SIGINT", 130], ["SIGTERM", 143], ["SIGHUP", 129]]) {
    const out = join(scratch, `stop-by-${signal}`);
    let started = null;
    let held = null;
    let ownTicks = null;
    const api = await startStandIn(audioReply, {
      delayMs: 700,
      onArrival: (arrival) => {
        if (arrival !== 2) return;
        try {
          held = JSON.parse(readFileSync(join(out, ".generate.lock"), "utf8"));
        } catch {
          held = null;
        }
        if (hasProc) ownTicks = ticksOf(started.child.pid);
        started.child.kill(signal);
      },
    });
    started = startTool(["--out", out, "--generate", "--sheet", fixturePath, "--id", "shot", "--concurrency", "2"], { env: withKey(api) });
    const result = await started.done;
    check(result.code === code && api.requests.length === 2, `${signal} did not stop new requests gently (exit ${result.code}, signal ${result.signal}, ${api.requests.length} requests)`);
    check(shotCandidates(out).length === 2 && logOf(out).filter((entry) => entry.status === "ok").length === 2, `the requests in flight at ${signal} were not saved (${shotCandidates(out).length} on disk)`);
    check(!existsSync(join(out, ".generate.lock")), `a run stopped by ${signal} left its lock behind`);
    check(held?.pid === started.child.pid && held?.start_ticks === (hasProc ? ownTicks : null), `the lock a run held did not carry its pid ${started.child.pid} and start ticks ${ownTicks}: ${JSON.stringify(held)}`);
    await api.close();
  }

  const quitOut = join(scratch, "quit");
  let quitting = null;
  let firstSignal = 0;
  const slow = await startStandIn(audioReply, {
    delayMs: 5000,
    onArrival: (arrival) => {
      if (arrival !== 2) return;
      firstSignal = Date.now();
      quitting.child.kill("SIGINT");
      setTimeout(() => quitting.child.kill("SIGINT"), 150).unref();
    },
  });
  quitting = startTool(["--out", quitOut, "--generate", "--sheet", fixturePath, "--id", "shot", "--concurrency", "2"], { env: withKey(slow) });
  const quit = await quitting.done;
  const took = Date.now() - firstSignal;
  check(quit.code === 130 && took < 3000, `a second Ctrl-C did not quit at once (exit ${quit.code}, signal ${quit.signal}, ${took} ms)`);
  check(!shotCandidates(quitOut).length && !existsSync(join(quitOut, ".generate.lock")), "quitting at once left a candidate or the lock");
  await slow.close();
  passes.push(`a first Ctrl-C, SIGTERM or SIGHUP each saved the 2 requests in flight, started no more and released the lock (exit 130, 143, 129); a second Ctrl-C quit after ${took} ms; the lock held the run's pid and start ticks`);
}

// With stdout closed from the start (its reader gone), a run still saves every
// candidate, releases its lock and exits 0; no EPIPE escapes.
{
  const out = join(scratch, "stdout-closed");
  const api = await startStandIn(audioReply);
  const started = startTool(["--out", out, "--generate", "--sheet", fixturePath, "--id", "shot", "--concurrency", "2"], { env: withKey(api) });
  started.child.stdout.destroy();
  const result = await started.done;
  const left = existsSync(join(out, ".generate.lock"));
  check(result.code === 0 && shotCandidates(out).length === shotGenerations && !left && !result.stderr.includes("EPIPE"),
    `with stdout closed a run exited ${result.code} (signal ${result.signal}) with ${shotCandidates(out).length} of ${shotGenerations} candidates${left ? " and its lock left behind" : ""}: ${result.stderr.trim().slice(0, 400)}`);
  await api.close();
  passes.push(`with stdout closed from the start a run saved all ${shotGenerations} candidates, released its lock and exited 0`);
}

// --- 4. Post-processing --------------------------------------------------------

const hasTool = (tool) => {
  const probe = spawnSync(tool, ["-version"], { encoding: "utf8" });
  return !probe.error && probe.status === 0;
};

function decode(file) {
  const result = spawnSync("ffmpeg", ["-v", "error", "-nostdin", "-i", file, "-f", "f32le", "-ac", "1", "-"], { maxBuffer: 256 * 1024 * 1024 });
  if (result.status !== 0) throw new Error(`could not decode ${file}`);
  const bytes = result.stdout;
  return new Float32Array(bytes.buffer, bytes.byteOffset, bytes.length / 4);
}

const isPlainObject = (value) => typeof value === "object" && value !== null && !Array.isArray(value);

// Loudness measured here, from the files: a one-shot's loudest momentary
// (400 ms) window, padded so a short sound fits one, or a loop's integrated
// loudness (ITU-R BS.1770 as ffmpeg's ebur128 measures it).
function measureLoudness(file, loop) {
  const result = spawnSync("ffmpeg", ["-hide_banner", "-nostdin", "-nostats", "-v", "info", "-i", file, "-af", "apad=pad_dur=0.5,ebur128=framelog=info", "-f", "null", "-"], { encoding: "utf8", maxBuffer: 64 * 1024 * 1024 });
  if (loop) {
    const match = result.stderr.slice(result.stderr.lastIndexOf("Summary:")).match(/I:\s+(-?\d+(?:\.\d+)?) LUFS/u);
    return match ? Number(match[1]) : -Infinity;
  }
  return Math.max(...[...result.stderr.matchAll(/\bM:\s*(-?\d+(?:\.\d+)?)/gu)].map((match) => Number(match[1])));
}

const channelsOf = (file) => Number(spawnSync("ffprobe", ["-v", "error", "-select_streams", "a:0", "-show_entries", "stream=channels", "-of", "csv=p=0", file], { encoding: "utf8" }).stdout.trim());
const peakOf = (samples) => samples.reduce((peak, value) => Math.max(peak, Math.abs(value)), 0);

// The jump across the wrap (last sample to first) against the signal's own 99th-percentile step.
function seamRatio(samples) {
  const steps = [];
  for (let i = 1; i < samples.length; i += 1) steps.push(Math.abs(samples[i] - samples[i - 1]));
  steps.sort((a, b) => a - b);
  return Math.abs(samples[0] - samples[samples.length - 1]) / steps[Math.floor(steps.length * 0.99)];
}

function synthesize(file, filter, inputs) {
  const result = spawnSync("ffmpeg", ["-v", "error", "-nostdin", "-y", ...inputs.flatMap((input) => ["-f", "lavfi", "-i", input]), ...filter, file], { encoding: "utf8" });
  if (result.status !== 0) throw new Error(`could not make ${file}: ${result.stderr}`);
}

{
  const setup = readFileSync(join(REPO_ROOT, ".devcontainer", "post-create.sh"), "utf8").replace(/\\\n/gu, " ");
  const installs = setup.split("\n").filter((line) => /apt-get install/u.test(line) && !line.trim().startsWith("#"));
  check(installs.some((line) => /(?:^|\s)ffmpeg(?:\s|$)/u.test(line)), ".devcontainer/post-create.sh does not install ffmpeg, which --process and this check need");
  const out = join(scratch, "process");
  const noFfmpeg = await runTool(["--out", out, "--process", "--sheet", fixturePath], { env: { PATH: gitOnlyPath } });
  check(noFfmpeg.code === 1 && noFfmpeg.stderr.includes("not on PATH"), `--process without ffmpeg did not say so (exit ${noFfmpeg.code}): ${noFfmpeg.stderr.trim()}`);
  if (!hasTool("ffmpeg") || !hasTool("ffprobe")) {
    failures.push("ffmpeg or ffprobe is not on PATH; --process and this check need them (.devcontainer/post-create.sh installs ffmpeg)");
  } else {
    // A candidate from one aevalsrc expression of t, written like the API's
    // one-shots (48 kHz, 16-bit, stereo). Quiet signals must not go through
    // concat here: its low-resolution sample format turned them into silence.
    const fromExpression = (file, expression, seconds) => synthesize(file, ["-ac", "2", "-c:a", "pcm_s16le"], [`aevalsrc='${expression}':s=48000:d=${seconds}`]);
    const NEAR_SILENT = "0.0001*sin(2*PI*1000*t)*between(t,0.1,0.2)";
    const shotDir = join(out, "candidates", "shot");
    const bedDir = join(out, "candidates", "bed");
    const rawDir = join(out, "candidates", "bed_raw");
    const hitDir = join(out, "candidates", "hit");
    for (const dir of [shotDir, bedDir, rawDir, hitDir]) mkdirSync(dir, { recursive: true });
    // A quiet take (impact at -26 dBFS) behind a softer lead-in (-50 dBFS): the
    // impact recipe must cut the lead-in, whatever the take's level.
    fromExpression(join(hitDir, "hit.c01.wav"), "0.00316*(2*random(0)-1)*lt(t,0.2)+0.05*(2*random(1)-1)*between(t,0.2,0.25)", 0.6);
    // Two knocks in silence: a 0.12 s and a 0.2 s burst, so each take shows its source.
    for (const [n, lead, burst] of [[1, 0.3, 0.12], [2, 0.25, 0.2]]) {
      synthesize(join(shotDir, `shot.c0${n}.wav`), ["-filter_complex", "[1:a]aformat=channel_layouts=stereo[n];[0:a][n][2:a]concat=n=3:v=0:a=1[o]", "-map", "[o]", "-c:a", "pcm_s16le"],
        [`anullsrc=r=48000:cl=stereo:d=${lead}`, `anoisesrc=r=48000:a=0.5:d=${burst}:c=white:seed=${n}`, "anullsrc=r=48000:cl=stereo:d=0.4"]);
    }
    // A 437 Hz tone of 2.3 s ends mid-cycle, so as generated it would click at the seam.
    synthesize(join(bedDir, "bed.c01.mp3"), ["-c:a", "libmp3lame", "-b:a", "192k"], ["sine=frequency=437:sample_rate=44100:duration=2.3"]);
    // A 441 Hz cosine of 2 s is whole cycles that start at full level (so no
    // silence is trimmed): a loop the model already made seamless.
    synthesize(join(rawDir, "bed_raw.c01.mp3"), ["-c:a", "libmp3lame", "-b:a", "192k"], ["aevalsrc=0.125*cos(2*PI*441*t):s=44100:d=2"]);
    // A first run, with no manifest yet. game/ already holds a take numbered past
    // the one bed keeps, a take of a retired row and a take of no row the tool knows.
    mkdirSync(join(out, "game", "test"), { recursive: true });
    for (const name of ["bed_02.ogg", "coin_01.ogg", "mystery_01.ogg"]) writeFileSync(join(out, "game", "test", name), "not audio\n");
    const processed = await runTool(["--out", out, "--process", "--sheet", fixturePath]);
    check(processed.code === 0, `--process exited ${processed.code}: ${processed.all.trim()}`);
    const take = (name) => join(out, "game", "test", name);
    if (processed.code === 0) {
      const recipe = fixture.recipes.shot;
      const rate = fixture.encode.sample_rate;
      const shots = ["shot_01.ogg", "shot_02.ogg"].map((name) => decode(take(name)));
      for (const [index, samples] of shots.entries()) {
        const seconds = samples.length / rate;
        const peak = peakOf(samples);
        const onset = samples.findIndex((value) => Math.abs(value) > peak * 0.1) / rate;
        const peakDb = 20 * Math.log10(peak);
        check(channelsOf(take(`shot_0${index + 1}.ogg`)) === recipe.channels, `shot_0${index + 1}.ogg is not ${recipe.channels}-channel`);
        check(seconds > 0.05 && seconds <= recipe.max_seconds + 0.02, `shot_0${index + 1}.ogg lasts ${seconds.toFixed(3)} s; the recipe keeps at most ${recipe.max_seconds} s`);
        check(onset <= 0.01, `shot_0${index + 1}.ogg starts ${(onset * 1000).toFixed(1)} ms before its onset; the silence before it should be cut`);
        // Decoded, as the game hears it: never more than a hair over the recipe's peak.
        check(peakDb <= recipe.peak_dbfs + 0.35, `shot_0${index + 1}.ogg peaks at ${peakDb.toFixed(2)} dBFS decoded; the recipe allows ${recipe.peak_dbfs}`);
        check(Math.abs(samples[samples.length - 1]) < peak * 0.05, `shot_0${index + 1}.ogg does not fade out at its end`);
      }
      // Matching turns the louder take down; the quietest still reaches the recipe's peak.
      const loudestPeak = Math.max(...shots.map((samples) => 20 * Math.log10(peakOf(samples))));
      check(loudestPeak >= recipe.peak_dbfs - 1.5, `no take of shot reaches the recipe's peak: the highest is ${loudestPeak.toFixed(2)} dBFS for ${recipe.peak_dbfs}`);
      check(shots[1].length > shots[0].length + 0.04 * rate, "the two takes are not cut from their own candidates");
      // The two knocks (0.12 s and 0.2 s of the same noise at the same peak) differ
      // by about 2 LU as they come; matched, they land within the row's tolerance.
      const shotLoudness = ["shot_01.ogg", "shot_02.ogg"].map((name) => measureLoudness(take(name), false));
      const shotSpread = Math.max(...shotLoudness) - Math.min(...shotLoudness);
      check(shotSpread <= fixture.loudness.within_row_spread_lu, `shot's takes differ by ${shotSpread.toFixed(2)} LU; within a row they must match within ${fixture.loudness.within_row_spread_lu}`);
      // The manifest: each processed sound's playback gain, from its measured loudness to its level.
      const manifestPath = join(out, "game", "sfx.json");
      const manifest = existsSync(manifestPath) ? JSON.parse(readFileSync(manifestPath, "utf8")) : null;
      check(manifest?.schema_version === "ti.sfx-manifest/1" && isPlainObject(manifest.sounds), `--process wrote no manifest at game/sfx.json: ${manifest ? JSON.stringify(manifest).slice(0, 200) : "missing"}`);
      for (const row of fixture.sounds) {
        const entry = manifest?.sounds?.[row.id];
        const measured = entry ? Math.max(...entry.takes.map((path) => measureLoudness(join(out, "game", path), row.loop))) : NaN;
        const ok = entry && entry.takes.length > 0 && entry.takes.every((path) => existsSync(join(out, "game", path))) && entry.gain_db <= 0 && entry.picked === false
          && entry.level_db === row.level_db && entry.loudness_class === row.loudness_class && Math.abs(entry.loudness_lufs - measured) <= 0.3
          && Math.abs(entry.gain_db - Math.min(0, row.level_db - entry.loudness_lufs)) <= 0.02 && Math.abs(entry.shortfall_db - Math.max(0, row.level_db - entry.loudness_lufs)) <= 0.02;
        check(ok, `the manifest's entry for ${row.id} does not give its takes, its level and the gain from its measured loudness (${measured.toFixed(2)} LUFS): ${JSON.stringify(entry)}`);
      }
      check(manifest?.sounds?.hit?.shortfall_db > 0 && manifest.sounds.hit.gain_db === 0 && processed.stderr.includes("NOTE: hit: its takes reach only"), `a level the takes cannot reach was not reported as a shortfall: ${JSON.stringify(manifest?.sounds?.hit)}`);
      // The run removed only what it decided: the take past the one bed keeps, and
      // the retired row's. The take of no known row stays.
      check(!existsSync(take("bed_02.ogg")) && processed.stdout.includes("removed game/test/bed_02.ogg: bed keeps 1 take now") && !existsSync(take("coin_01.ogg"))
        && processed.stdout.includes("removed game/test/coin_01.ogg: a retired output") && existsSync(take("mystery_01.ogg")),
      `a first run did not remove exactly the take past what bed keeps and the retired row's take, keeping the take of no known row: ${processed.stdout.trim()}`);
      // Nobody picked anything yet: every row came from its first candidates, and the summary says so.
      check(processed.stdout.includes("NOTE: processed from first candidates nobody picked: shot, bed, bed_raw, hit"), `the summary does not list the rows processed from first candidates nobody picked: ${processed.stdout.trim()}`);
      passes.push("a first run with no manifest removed only the take past what bed keeps and a retired row's take, kept a take of no known row, and listed the rows processed from first candidates nobody picked (picked: false)");
      const raw = decode(join(bedDir, "bed.c01.mp3"));
      const bed = decode(take("bed_01.ogg"));
      const expected = raw.length - (fixture.recipes.bed.loop_crossfade_ms / 1000) * rate;
      check(seamRatio(raw) > 4, `the test tone does not jump at its seam (ratio ${seamRatio(raw).toFixed(2)}), so the loop check proves nothing`);
      check(seamRatio(bed) <= 1.5, `bed_01.ogg jumps at its loop seam: ${seamRatio(bed).toFixed(2)} times its 99th-percentile step`);
      check(Math.abs(bed.length - expected) <= 0.02 * rate, `bed_01.ogg has ${bed.length} samples; expected the candidate less the crossfade, about ${Math.round(expected)}`);
      const rawIn = decode(join(rawDir, "bed_raw.c01.mp3"));
      const rawOut = decode(take("bed_raw_01.ogg"));
      check(Math.abs(rawOut.length - rawIn.length) <= 0.01 * rate, `bed_raw_01.ogg has ${rawOut.length} samples for ${rawIn.length} generated; a 0 ms crossfade must keep the loop as generated`);
      check(seamRatio(rawOut) <= 1.5, `bed_raw_01.ogg, kept as generated, jumps at its seam: ${seamRatio(rawOut).toFixed(2)} times its 99th-percentile step`);
      const hit = decode(take("hit_01.ogg"));
      const hitOnset = hit.findIndex((value) => Math.abs(value) > peakOf(hit) * 0.1) / rate;
      check(hitOnset <= 0.01 && hit.length / rate < 0.12, `hit_01.ogg does not start at its impact: onset ${(hitOnset * 1000).toFixed(1)} ms, ${(hit.length / rate).toFixed(3)} s long (the lead-in is 0.2 s)`);
      const shortest = shots[1].length;
      // Fewer picks than keep_takes: exactly the picked take, nothing padded from
      // unpicked candidates, and the take beyond it removed.
      writeFileSync(join(out, "picks.json"), JSON.stringify({ shot: [2] }));
      const picked = await runTool(["--out", out, "--process", "--sheet", fixturePath, "--id", "shot"]);
      check(picked.code === 0 && existsSync(take("shot_01.ogg")) && !existsSync(take("shot_02.ogg")) && /test\/shot_01\.ogg .*from c02  -?\d/mu.test(picked.stdout) && !picked.stdout.includes("first on disk"),
        `picks.json {"shot": [2]} for a row that keeps 2 did not give exactly that one take (exit ${picked.code}): ${picked.all.trim()}`);
      if (picked.code === 0) check(Math.abs(decode(take("shot_01.ogg")).length - shortest) <= 0.005 * rate, "the picked take did not come from candidate 2");
      // A run over one row updates its entry and keeps the others'.
      const updated = JSON.parse(readFileSync(manifestPath, "utf8")).sounds;
      check(updated.shot?.takes?.length === 1 && updated.shot.picked === true && ["bed", "bed_raw", "hit"].every((id) => updated[id]?.takes?.length && updated[id].picked === false),
        `a --process of shot alone did not update its entry (picked) and keep the others: ${JSON.stringify(updated)}`);
      writeFileSync(join(out, "picks.json"), JSON.stringify({ shot: [9] }));
      // An impossible pick fails its row alone; the other rows are still processed.
      const badPick = await runTool(["--out", out, "--process", "--sheet", fixturePath]);
      check(badPick.code === 1 && /^FAIL: shot: .*picks\.json/mu.test(badPick.stderr) && /failed rows: shot \(its picks in picks\.json\)$/mu.test(badPick.stderr) && badPick.stdout.includes("test/bed_01.ogg"),
        `an impossible pick did not fail its row alone (exit ${badPick.code}): ${badPick.all.trim()}`);
      const peaks = shots.map((samples) => (20 * Math.log10(peakOf(samples))).toFixed(2));
      passes.push(`post-processing: one-shots start at their onset (${shots.map((s) => (s.length / rate).toFixed(2)).join(" s, ")} s; decoded peaks ${peaks.join(", ")} dBFS for ${recipe.peak_dbfs}), the impact recipe cut a quiet take's 0.2 s lead-in (onset ${(hitOnset * 1000).toFixed(1)} ms), loop seam ${seamRatio(bed).toFixed(2)} x a normal step (was ${seamRatio(raw).toFixed(2)}), a 0 ms crossfade keeps the loop as generated, one pick for a row of 2 gave exactly that take`);
      passes.push(`levels: a row's takes are loudness-matched (shot's two knocks within ${shotSpread.toFixed(2)} LU), the manifest game/sfx.json gives every sound its takes and the gain from its measured loudness to its level, an unreachable level is a reported shortfall, and a run over one row keeps the others' entries`);

      // Verdicts in the shapes the audition pages write (audition/server.mjs):
      // round 1 {none_good, note, updated}, round 2 under "round2"
      // {still_not_right, note, updated}. Round 2 decides when present, a pick
      // overrides a mark, and a set made after the audition began goes in only
      // once picked or judged. The generation log dates each candidate.
      const ver = join(scratch, "process-verdicts");
      const verTake = (name) => join(ver, "game", "test", name);
      const verSounds = () => (existsSync(join(ver, "game", "sfx.json")) ? JSON.parse(readFileSync(join(ver, "game", "sfx.json"), "utf8")).sounds : {});
      cpSync(join(out, "candidates"), join(ver, "candidates"), { recursive: true });
      const at = (minutes) => new Date(Date.parse("2026-11-14T06:00:00.000Z") + minutes * 60_000).toISOString();
      const [beforeAudition, round1, madeAgain, round2] = [at(-120), at(0), at(60), at(90)];
      // shot and bed were made before the audition; bed_raw and hit after it began.
      const dated = { shot: [beforeAudition, 2], bed: [beforeAudition, 1], bed_raw: [madeAgain, 1], hit: [madeAgain, 1] };
      const logLines = Object.entries(dated).flatMap(([id, [time, count]]) => Array.from({ length: count }, (_, index) => JSON.stringify({
        time, id, candidate: index + 1, attempt: 1, file: candidate(fixture.sounds.find((row) => row.id === id), index + 1), status: "ok",
      })));
      writeFileSync(join(ver, "generation-log.jsonl"), `${logLines.join("\n")}\n`);
      mkdirSync(join(ver, "game", "test"), { recursive: true });
      for (const name of ["bed_01.ogg", "hit_01.ogg"]) cpSync(take("hit_01.ogg"), verTake(name));
      writeFileSync(join(ver, "picks.json"), JSON.stringify({ shot: [2] }));
      const verdicts = {
        shot: { none_good: true, note: "too quiet", updated: round1 },
        bed: { none_good: true, note: "not this", updated: round1 },
        bed_raw: { none_good: true, note: "too much hiss", updated: round1, round2: { still_not_right: false, note: "better now", updated: round2 } },
      };
      writeFileSync(join(ver, "audition-notes.json"), JSON.stringify(verdicts));
      const firstVerdicts = await runTool(["--out", ver, "--process", "--sheet", fixturePath]);
      const afterFirst = verSounds();
      check(firstVerdicts.code === 0 && afterFirst.shot?.picked === true, `a pick did not override a round-1 none-good mark (exit ${firstVerdicts.code}): ${firstVerdicts.all.trim()}`);
      check(!afterFirst.bed && !existsSync(verTake("bed_01.ogg")) && firstVerdicts.stdout.includes("bed: left out of game/ and sfx.json, marked not good in round 1; removed game/test/bed_01.ogg"),
        `a row marked none good in round 1 and never picked was not left out with its takes: ${firstVerdicts.stdout.trim()}`);
      check(afterFirst.bed_raw?.picked === false && firstVerdicts.stdout.includes("NOTE: processed from first candidates nobody picked: bed_raw"),
        `round 2's verdict (not rejected, saved after the set was made) did not decide over round 1's rejection: ${firstVerdicts.stdout.trim()}`);
      check(!afterFirst.hit && !existsSync(verTake("hit_01.ogg")) && /^NOTE: left out of game\/, so the game plays nothing for them: .*hit \(unheard: its candidates were made after the audition began/mu.test(firstVerdicts.stdout),
        `a set made after the audition began, never picked or judged, was not left out and named in the summary: ${firstVerdicts.stdout.trim()}`);
      // Round 2 marks shot (still picked), bed_raw and the new hit still not right;
      // bed's round-1 mark is gone, and its set was made before the audition.
      verdicts.shot.round2 = { still_not_right: true, note: "", updated: round2 };
      verdicts.bed_raw.round2 = { still_not_right: true, note: "still hiss", updated: round2 };
      verdicts.hit = { round2: { still_not_right: true, note: "still not right", updated: round2 } };
      delete verdicts.bed;
      writeFileSync(join(ver, "audition-notes.json"), JSON.stringify(verdicts));
      const secondVerdicts = await runTool(["--out", ver, "--process", "--sheet", fixturePath]);
      const afterSecond = verSounds();
      check(secondVerdicts.code === 0 && afterSecond.shot?.picked === true, `a pick did not override a round-2 mark (exit ${secondVerdicts.code}): ${secondVerdicts.all.trim()}`);
      check(afterSecond.bed?.picked === false && secondVerdicts.stdout.includes("NOTE: processed from first candidates nobody picked: bed"),
        `a set made before the audition, with no pick and no verdict, did not go in from its first candidates, listed: ${secondVerdicts.stdout.trim()}`);
      check(!afterSecond.bed_raw && !existsSync(verTake("bed_raw_01.ogg")) && secondVerdicts.stdout.includes("bed_raw: left out of game/ and sfx.json, marked not good in round 2"),
        `round 2's rejection did not decide: ${secondVerdicts.stdout.trim()}`);
      check(!afterSecond.hit && secondVerdicts.stdout.includes("hit: left out of game/ and sfx.json, marked not good in round 2"), `a new row rejected in round 2 was not left out: ${secondVerdicts.stdout.trim()}`);
      passes.push("audition verdicts in the pages' shapes: round 2 decides over round 1 either way, a pick overrides a mark of either round, a set made after the audition began with no pick or verdict since is left out and named, one made before it ships from first candidates, listed and marked picked: false");

      // A run over one row keeps every other row's takes, even with no manifest to
      // list them (the first run on a folder an earlier tool processed).
      const sub = join(scratch, "process-subset");
      const subTake = (name) => join(sub, "game", "test", name);
      cpSync(join(out, "candidates"), join(sub, "candidates"), { recursive: true });
      const whole = await runTool(["--out", sub, "--process", "--sheet", fixturePath]);
      rmSync(join(sub, "game", "sfx.json"), { force: true });
      for (const name of ["coin_02.ogg", "mystery_02.ogg"]) writeFileSync(subTake(name), "not audio\n");
      const others = ["shot_01.ogg", "shot_02.ogg", "bed_01.ogg", "bed_raw_01.ogg", "mystery_02.ogg"];
      const othersBefore = others.map((name) => (existsSync(subTake(name)) ? readFileSync(subTake(name)) : null));
      const one = await runTool(["--out", sub, "--process", "--sheet", fixturePath, "--id", "hit"]);
      const oneSounds = existsSync(join(sub, "game", "sfx.json")) ? Object.keys(JSON.parse(readFileSync(join(sub, "game", "sfx.json"), "utf8")).sounds) : [];
      check(whole.code === 0 && one.code === 0 && others.every((name, index) => othersBefore[index] && existsSync(subTake(name)) && readFileSync(subTake(name)).equals(othersBefore[index])) && oneSounds.join() === "hit",
        `--process --id hit with no manifest touched other rows' takes (exit ${whole.code}, ${one.code}; manifest ${oneSounds.join(", ")}): ${one.all.trim()}`);
      check(!existsSync(subTake("coin_02.ogg")) && one.stdout.includes("removed game/test/coin_02.ogg: a retired output"), `a run over one row did not remove a retired row's take: ${one.stdout.trim()}`);
      passes.push("a run over one row with no manifest kept every other row's takes and a take of no known row, and removed a retired row's take");

      // A quiet take (a -55 dBFS burst) is trimmed from its own peak, so it is
      // kept whole, not called silent.
      const soft = join(scratch, "process-soft");
      mkdirSync(join(soft, "candidates", "shot"), { recursive: true });
      fromExpression(join(soft, "candidates", "shot", "shot.c01.wav"), "0.00178*(2*random(0)-1)*between(t,0.1,0.18)", 0.5);
      cpSync(join(shotDir, "shot.c02.wav"), join(soft, "candidates", "shot", "shot.c02.wav"));
      const softRun = await runTool(["--out", soft, "--process", "--sheet", fixturePath, "--id", "shot"]);
      const softTake = softRun.code === 0 ? decode(join(soft, "game", "test", "shot_01.ogg")) : new Float32Array(0);
      const softSeconds = softTake.length / rate;
      const softOnset = softTake.findIndex((value) => Math.abs(value) > peakOf(softTake) * 0.1) / rate;
      check(softRun.code === 0 && softSeconds > 0.07 && softSeconds < 0.12 && softOnset <= 0.01,
        `a quiet take (a -55 dBFS burst of 0.08 s) was not kept whole: exit ${softRun.code}, ${softSeconds.toFixed(3)} s, onset ${(softOnset * 1000).toFixed(1)} ms: ${softRun.stderr.trim()}`);
      passes.push(`a quiet take (a -55 dBFS burst of 0.08 s) is trimmed from its own peak and kept whole (${softSeconds.toFixed(3)} s)`);

      // A near-silent candidate (a -80 dBFS tone) is named by id and candidate;
      // the other rows are still processed, its row gets no take made in this
      // run, and the run ends non-zero listing the failed row.
      const quiet = join(scratch, "process-quiet");
      const quietShot = join(quiet, "candidates", "shot");
      mkdirSync(quietShot, { recursive: true });
      fromExpression(join(quietShot, "shot.c01.wav"), NEAR_SILENT, 0.5);
      cpSync(join(shotDir, "shot.c02.wav"), join(quietShot, "shot.c02.wav"));
      for (const id of ["bed", "bed_raw", "hit"]) cpSync(join(out, "candidates", id), join(quiet, "candidates", id), { recursive: true });
      const quietRun = await runTool(["--out", quiet, "--process", "--sheet", fixturePath]);
      const quietTake = (name) => join(quiet, "game", "test", name);
      check(quietRun.code === 1 && quietRun.stderr.includes("shot c01: silent after trimming; pick another take or regenerate"), `a near-silent candidate was not named as silent by id and candidate (exit ${quietRun.code}): ${quietRun.stderr.trim()}`);
      check(/failed rows: shot \(c01\)$/mu.test(quietRun.stderr), `the run did not end by listing exactly the failed row: ${quietRun.stderr.trim()}`);
      check(["bed_01.ogg", "bed_raw_01.ogg", "hit_01.ogg"].every((name) => existsSync(quietTake(name))) && !existsSync(quietTake("shot_01.ogg")) && !existsSync(quietTake("shot_02.ogg"))
        && quietRun.stderr.includes("FAIL: shot: left as it was in game/ and sfx.json; its 1 other take made now is not used"),
      `after the near-silent take, the other rows were not processed, or its row got part of a new set: ${quietRun.all.trim()}`);
      passes.push("a near-silent candidate (-80 dBFS) is named (shot c01, silent after trimming); the other rows are processed, its row gets none of the takes made with it, and the run exits 1 listing the failed row");

      // A row with a take that fails is left as it was, its earlier takes and
      // manifest entry included, and the FAIL line says so: never a mix of sets.
      const replace = join(scratch, "process-replace");
      const replaceShot = join(replace, "candidates", "shot");
      const replaceTake = (name) => join(replace, "game", "test", name);
      mkdirSync(replaceShot, { recursive: true });
      for (const n of [1, 2]) cpSync(join(shotDir, `shot.c0${n}.wav`), join(replaceShot, `shot.c0${n}.wav`));
      const before = await runTool(["--out", replace, "--process", "--sheet", fixturePath, "--id", "shot"]);
      check(before.code === 0 && existsSync(replaceTake("shot_01.ogg")) && existsSync(replaceTake("shot_02.ogg")), `the first --process of the replace case failed (exit ${before.code})`);
      const earlierTakes = ["shot_01.ogg", "shot_02.ogg"].map((name) => (existsSync(replaceTake(name)) ? readFileSync(replaceTake(name)) : null));
      const earlierEntry = existsSync(join(replace, "game", "sfx.json")) ? JSON.parse(readFileSync(join(replace, "game", "sfx.json"), "utf8")).sounds.shot : null;
      fromExpression(join(replaceShot, "shot.c02.wav"), NEAR_SILENT, 0.5);
      writeFileSync(join(replace, "picks.json"), JSON.stringify({ shot: [2] }));
      const after = await runTool(["--out", replace, "--process", "--sheet", fixturePath, "--id", "shot"]);
      const afterEntry = existsSync(join(replace, "game", "sfx.json")) ? JSON.parse(readFileSync(join(replace, "game", "sfx.json"), "utf8")).sounds.shot : null;
      check(after.code === 1 && after.stderr.includes("shot c02: silent after trimming") && after.stderr.includes("FAIL: shot: left as it was in game/ and sfx.json; no take of it was made"),
        `a failed take did not leave its row as it was, said so (exit ${after.code}): ${after.stderr.trim()}`);
      check(["shot_01.ogg", "shot_02.ogg"].every((name, index) => earlierTakes[index] && existsSync(replaceTake(name)) && readFileSync(replaceTake(name)).equals(earlierTakes[index]))
        && earlierEntry && JSON.stringify(afterEntry) === JSON.stringify(earlierEntry), `the failed row's earlier takes or manifest entry changed: ${listDir(join(replace, "game", "test")).join(", ")}; ${JSON.stringify(afterEntry)}`);
      passes.push("a row with a take that fails is left as it was, takes and manifest entry, and says so");

      // Stand-ins that answer with real one-shot audio, like the API's 48 kHz
      // stereo WAV: request k gets a noise burst BURSTS[offset + k - 1] seconds
      // long, so the length of a processed take tells which candidate it came from.
      const BURSTS = [0.055, 0.08, 0.105, 0.13, 0.155, 0.18, 0.205, 0.23];
      const burstAudio = BURSTS.map((seconds, index) => {
        const file = join(scratch, `burst-${index + 1}.wav`);
        fromExpression(file, `0.5*(2*random(0)-1)*between(t,0.1,${(0.1 + seconds).toFixed(3)})`, 0.5);
        return readFileSync(file);
      });
      const burstApi = (offset) => startStandIn((seen, arrival) => (burstAudio[offset + arrival - 1]
        ? { status: 200, headers: { "content-type": "audio/wav" }, body: burstAudio[offset + arrival - 1] }
        : errorReply(418, {}, "{\"detail\":\"no more bursts\"}")));
      // The burst (1-based) a take was cut from: the shot recipe keeps 3 ms before
      // the onset and 10 ms after the tail; 0 when no burst is that close.
      const burstOf = (file) => {
        if (!existsSync(file)) return 0;
        const seconds = decode(file).length / rate - 0.013;
        const index = BURSTS.findIndex((length) => Math.abs(seconds - length) < 0.01);
        return index + 1;
      };
      const shotVariant = (name, change) => {
        const copy = fixtureSheet();
        change(copy.sounds.find((row) => row.id === "shot"));
        const path = join(scratch, `fixture-${name}.json`);
        writeFileSync(path, `${JSON.stringify(copy, null, 2)}\n`);
        return path;
      };
      const metalPrompt = "High-quality foley one-shot: a single knock on a metal door, close-miked.";
      const metalPath = shotVariant("metal", (row) => { row.prompt = metalPrompt; });
      const morePath = shotVariant("more", (row) => { row.candidates_per_take = 3; });

      // Picks across --force-id, by recorded facts, not file times. The forced
      // row's picks are recorded when its set goes aside; --process refuses picks
      // made only of those numbers (in any order, or fewer of them), however
      // recently picks.json was saved, and takes picks made from the fresh set.
      const forcedOut = join(scratch, "process-forced");
      const forcedTake = (name) => join(forcedOut, "game", "test", name);
      const heardTakes = () => ["shot_01.ogg", "shot_02.ogg"].map((name) => (existsSync(forcedTake(name)) ? readFileSync(forcedTake(name)) : null));
      let api = await burstApi(0);
      const firstSet = await runTool(["--out", forcedOut, "--generate", "--sheet", metalPath, "--id", "shot", "--concurrency", "1"], { env: withKey(api) });
      await api.close();
      writeFileSync(join(forcedOut, "picks.json"), JSON.stringify({ shot: [2, 1] }));
      const firstTakes = await runTool(["--out", forcedOut, "--process", "--sheet", metalPath, "--id", "shot"]);
      const heard = heardTakes();
      check(firstSet.code === 0 && firstTakes.code === 0 && burstOf(forcedTake("shot_01.ogg")) === 2, `the first set and its picked takes were not made (exit ${firstSet.code}, ${firstTakes.code}): ${firstTakes.all.trim()}`);
      const stillHeard = () => heardTakes().every((bytes, index) => bytes && heard[index] && bytes.equals(heard[index]));
      // The prompt has changed since, so the complete set is forced without --force-again.
      api = await burstApi(4);
      const reworded = await runTool(["--out", forcedOut, "--generate", "--sheet", fixturePath, "--id", "shot", "--force-id", "shot", "--concurrency", "1"], { env: withKey(api) });
      await api.close();
      check(reworded.code === 0 && api.requests.length === shotGenerations, `--force-id of a set made with another prompt needed more than --force-id (exit ${reworded.code}, ${api.requests.length} requests): ${reworded.stderr.trim()}`);
      // A first full run with no manifest (as on a folder an earlier tool
      // processed), picks.json saved again later for another row and now newer
      // than every candidate: shot is refused and its heard takes stay untouched.
      rmSync(join(forcedOut, "game", "sfx.json"), { force: true });
      writeFileSync(join(forcedOut, "picks.json"), JSON.stringify({ shot: [2, 1], gone: [1] }));
      const inAnHour = new Date(Date.now() + 3600_000);
      utimesSync(join(forcedOut, "picks.json"), inAnHour, inAnHour);
      const stalePicks = await runTool(["--out", forcedOut, "--process", "--sheet", fixturePath]);
      check(stalePicks.code === 1 && stalePicks.stderr.includes("FAIL: shot: picks.json picks c02, c01, only numbers it had picked before --force-id") && stalePicks.stderr.includes("Listen to them and update shot in picks.json") && stillHeard(),
        `picks made before --force-id were taken for the new, unheard set, or the refused row's heard takes were touched, on a full run with no manifest (exit ${stalePicks.code}): ${stalePicks.all.trim()}`);
      check(stalePicks.stderr.includes("names gone, which is not in the sheet; ignored"), `an id in picks.json that is not in the sheet was not named and ignored: ${stalePicks.stderr.trim()}`);
      // Fewer of the recorded numbers, or the same in another order: still the old set's picks.
      for (const list of [[1], [1, 2]]) {
        writeFileSync(join(forcedOut, "picks.json"), JSON.stringify({ shot: list }));
        const partial = await runTool(["--out", forcedOut, "--process", "--sheet", fixturePath, "--id", "shot"]);
        check(partial.code === 1 && partial.stderr.includes("only numbers it had picked before --force-id") && stillHeard(), `picks ${JSON.stringify(list)}, only numbers recorded before --force-id, were taken (exit ${partial.code}): ${partial.all.trim()}`);
      }
      // Picked from the fresh set: taken.
      writeFileSync(join(forcedOut, "picks.json"), JSON.stringify({ shot: [4, 3] }));
      const repicked = await runTool(["--out", forcedOut, "--process", "--sheet", fixturePath, "--id", "shot"]);
      check(repicked.code === 0 && burstOf(forcedTake("shot_01.ogg")) === 8 && burstOf(forcedTake("shot_02.ogg")) === 7, `picks made from the fresh set were not taken (exit ${repicked.code}): ${repicked.all.trim()}`);
      // The old numbers picked again from the fresh set, on purpose: refused until
      // the record is deleted, as the message says; then taken.
      writeFileSync(join(forcedOut, "picks.json"), JSON.stringify({ shot: [2, 1] }));
      const sameNumbers = await runTool(["--out", forcedOut, "--process", "--sheet", fixturePath, "--id", "shot"]);
      const record = "candidates/shot/.picks-before-force.json";
      check(sameNumbers.code === 1 && sameNumbers.stderr.includes(`delete ${record}, which is the only way past this check`) && burstOf(forcedTake("shot_01.ogg")) === 8,
        `the old numbers picked again were not refused with the record to delete (exit ${sameNumbers.code}): ${sameNumbers.stderr.trim()}`);
      rmSync(join(forcedOut, record), { force: true });
      const confirmed = await runTool(["--out", forcedOut, "--process", "--sheet", fixturePath, "--id", "shot"]);
      check(confirmed.code === 0 && burstOf(forcedTake("shot_01.ogg")) === 6, `with the record deleted, the same numbers did not take the fresh candidates (exit ${confirmed.code}): ${confirmed.all.trim()}`);
      passes.push("picks across --force-id: recorded as the set went aside; picks made only of those numbers (all, fewer, reordered) refused, even with picks.json saved later and on a full run with no manifest, whose refused row kept its heard takes; taken once picked from the fresh set, the same numbers once the record is deleted; a set made with another prompt is forced without --force-again; an id not in the sheet is named and ignored");

      // A plain copy of the folder (new file times, picks.json the oldest file) takes its picks as they are.
      const copied = join(scratch, "process-copied");
      cpSync(join(out, "candidates", "shot"), join(copied, "candidates", "shot"), { recursive: true });
      writeFileSync(join(copied, "picks.json"), JSON.stringify({ shot: [2] }));
      const anHourAgo = new Date(Date.now() - 3600_000);
      utimesSync(join(copied, "picks.json"), anHourAgo, anHourAgo);
      const copiedRun = await runTool(["--out", copied, "--process", "--sheet", fixturePath, "--id", "shot"]);
      const copiedTake = join(copied, "game", "test", "shot_01.ogg");
      check(copiedRun.code === 0 && existsSync(copiedTake) && Math.abs(decode(copiedTake).length - shortest) <= 0.005 * rate, `a copied folder, picks.json older than its candidates, did not take its picks (exit ${copiedRun.code}): ${copiedRun.all.trim()}`);
      passes.push("a plain copy of the folder, picks.json older than its candidates, takes its picks");

      // Raising a row's candidates_per_take adds candidates beside the old ones,
      // made with the sheet's current prompt. The old ones stay as they were, a pick
      // of one stays valid, and the generation log names each candidate's prompt.
      const moreOut = join(scratch, "process-more");
      const moreFile = (n) => join(moreOut, "candidates", "shot", `shot.c0${n}.wav`);
      api = await burstApi(0);
      const oldSet = await runTool(["--out", moreOut, "--generate", "--sheet", metalPath, "--id", "shot", "--concurrency", "1"], { env: withKey(api) });
      await api.close();
      const oldBytes = [1, 2, 3, 4].map((n) => (existsSync(moreFile(n)) ? readFileSync(moreFile(n)) : Buffer.alloc(0)));
      writeFileSync(join(moreOut, "picks.json"), JSON.stringify({ shot: [2] }));
      const moreDry = await runTool(["--out", moreOut, "--sheet", morePath, "--id", "shot"]);
      const addCost = Math.round(fixture.credits_per_second * shotRow.duration_seconds * 2);
      check(oldSet.code === 0 && moreDry.code === 0 && moreDry.stdout.includes(`to make: ${addCost} `) && moreDry.stderr.includes("NOTE: shot: c01, c02, c03, c04 were made with other settings"),
        `the dry run of a row raised from 4 to 6 candidates did not price 2 (${addCost} credits) and name the 4 made with another prompt (exit ${oldSet.code}, ${moreDry.code}): ${moreDry.all.trim()}`);
      api = await burstApi(4);
      const added = await runTool(["--out", moreOut, "--generate", "--sheet", morePath, "--id", "shot", "--concurrency", "1"], { env: withKey(api) });
      await api.close();
      check(added.code === 0 && api.requests.length === 2 && api.requests.every((seen) => seen.body?.text === shotRow.prompt) && existsSync(moreFile(5)) && existsSync(moreFile(6)),
        `raising candidates_per_take did not make exactly the 2 new candidates with the current prompt (exit ${added.code}, ${api.requests.length} requests): ${added.all.trim()}`);
      check([1, 2, 3, 4].every((n, index) => existsSync(moreFile(n)) && readFileSync(moreFile(n)).equals(oldBytes[index])), "making the added candidates changed or moved the old ones");
      const promptOf = (n) => logOf(moreOut).filter((entry) => entry.status === "ok" && entry.candidate === n).at(-1)?.prompt;
      check([1, 2, 3, 4].every((n) => promptOf(n) === metalPrompt) && [5, 6].every((n) => promptOf(n) === shotRow.prompt), "the generation log does not name the prompt that made each candidate");
      const morePicked = await runTool(["--out", moreOut, "--process", "--sheet", morePath, "--id", "shot"]);
      check(morePicked.code === 0 && burstOf(join(moreOut, "game", "test", "shot_01.ogg")) === 2, `the pick of an old candidate was not taken once new ones were added (exit ${morePicked.code}): ${morePicked.all.trim()}`);
      passes.push("raising candidates_per_take from 2 to 3 made only the 2 new candidates, with the current prompt, beside 4 untouched old ones; the log names each one's prompt and the pick of old c02 still stands");
    }
  }
}

// --- 5. Git --------------------------------------------------------------------

{
  const tracked = spawnSync("git", ["-C", REPO_ROOT, "ls-files", "-z"], { encoding: "utf8", maxBuffer: 64 * 1024 * 1024 });
  if (tracked.status !== 0) failures.push(`git ls-files failed: ${tracked.stderr.trim()}`);
  else {
    const audio = tracked.stdout.split("\0").filter((path) => AUDIO_RE.test(path));
    check(!audio.length, `Git tracks audio, which must stay out of this public repo: ${audio.slice(0, 10).join(", ")}`);
  }
  const samples = ["game/resources/audio/sfx/footstep_hard_01.ogg", "game/resources/audio/sfx/footstep_hard_01.ogg.import", "tools/sfx/take.WAV", "take.wav.import", "a.mp3", "a.mp3.import", "a.Flac", "a.opus", "a.m4a", "a.aac", "a.aiff", "a.oga", "a.weba"];
  const ignored = spawnSync("git", ["-C", REPO_ROOT, "check-ignore", "--no-index", ...samples], { encoding: "utf8" });
  const listed = new Set(ignored.stdout.split("\n").filter(Boolean));
  const open = samples.filter((path) => !listed.has(path));
  check(!open.length, `.gitignore does not keep these audio paths out of Git: ${open.join(", ")}`);
  if (tracked.status === 0 && !open.length) passes.push("Git tracks no audio and .gitignore keeps it out");
}

check(trap.requests.length === 0, `${trap.requests.length} requests reached the trap stand-in: a run went to an API it was not pointed at`);
await trap.close();
if (failures.length) {
  for (const text of failures) console.log(`FAIL ${text}`);
  console.log(`FAIL sound effects: ${failures.length} problems`);
  process.exit(1);
}
for (const text of passes) console.log(`PASS sfx ${text}`);
process.exit(0);
