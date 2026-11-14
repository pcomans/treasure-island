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
//   - A rerun requests nothing. --force-id keeps the old set aside, and
//     repeating it before its fresh set is complete is refused.
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
//   - Picks choose the takes.
//   - A near-silent candidate is named, and the other takes and rows go on;
//     the run ends non-zero listing the failed rows.
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

  // A candidate numbered past the row's count (made when it had more) goes aside
  // with the rest, and a pick on the forced row is pointed out.
  writeFileSync(join(out, "candidates", "shot", "shot.c07.wav"), MAGIC.wav);
  writeFileSync(join(out, "picks.json"), JSON.stringify({ shot: [1] }));
  api.maxInFlight = 0;
  const forced = await runTool(["--out", out, "--generate", "--sheet", fixturePath, "--force-id", "shot"], { env, home });
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
  passes.push(`generation: model and settings sent, key read from ~/.config/elevenlabs/.env, ${firstAtOnce} at once with --concurrency 2 and ${api.maxInFlight} by the plan's ${fixture.plan.concurrency}, 429s waited out and logged, summary and log agree on ${logged} credits, rerun requested nothing, --force-id kept ${shotGenerations} aside`);
}

// Repeating a --force-id whose fresh set is unfinished is refused; the printed command finishes it.
{
  const out = join(scratch, "forced");
  const full = await startStandIn(audioReply);
  const made = await runTool(["--out", out, "--generate", "--sheet", fixturePath, "--id", "shot"], { env: withKey(full) });
  check(made.code === 0 && shotCandidates(out).length === shotGenerations, `the first shot set was not made (exit ${made.code})`);
  const stopping = await startStandIn((seen, arrival) => (arrival === 1 ? audioReply(seen) : errorReply(401, {}, "{\"detail\":\"invalid_api_key\"}")));
  const forceArgs = ["--out", out, "--generate", "--sheet", fixturePath, "--id", "shot", "--force-id", "shot", "--concurrency", "1"];
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
  const again = await runTool(["--out", out, "--sheet", fixturePath, "--id", "shot", "--force-id", "shot"]);
  check(again.code === 0, `--force-id was still refused after its set was finished (exit ${again.code}): ${again.stderr.trim()}`);
  await full.close();
  await stopping.close();
  passes.push("repeating an unfinished --force-id is refused without a request; the command without it finishes the set");
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
        const ok = entry && entry.takes.length > 0 && entry.takes.every((path) => existsSync(join(out, "game", path))) && entry.gain_db <= 0
          && entry.level_db === row.level_db && entry.loudness_class === row.loudness_class && Math.abs(entry.loudness_lufs - measured) <= 0.3
          && Math.abs(entry.gain_db - Math.min(0, row.level_db - entry.loudness_lufs)) <= 0.02 && Math.abs(entry.shortfall_db - Math.max(0, row.level_db - entry.loudness_lufs)) <= 0.02;
        check(ok, `the manifest's entry for ${row.id} does not give its takes, its level and the gain from its measured loudness (${measured.toFixed(2)} LUFS): ${JSON.stringify(entry)}`);
      }
      check(manifest?.sounds?.hit?.shortfall_db > 0 && manifest.sounds.hit.gain_db === 0 && processed.stderr.includes("NOTE: hit: its takes reach only"), `a level the takes cannot reach was not reported as a shortfall: ${JSON.stringify(manifest?.sounds?.hit)}`);
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
      check(updated.shot?.takes?.length === 1 && ["bed", "bed_raw", "hit"].every((id) => updated[id]?.takes?.length), `a --process of shot alone did not update its entry and keep the others: ${Object.keys(updated).join(", ")}`);
      writeFileSync(join(out, "picks.json"), JSON.stringify({ shot: [9] }));
      const badPick = await runTool(["--out", out, "--process", "--sheet", fixturePath]);
      check(badPick.code === 1 && badPick.stderr.includes("picks.json"), `an impossible pick was not refused (exit ${badPick.code})`);
      const peaks = shots.map((samples) => (20 * Math.log10(peakOf(samples))).toFixed(2));
      passes.push(`post-processing: one-shots start at their onset (${shots.map((s) => (s.length / rate).toFixed(2)).join(" s, ")} s; decoded peaks ${peaks.join(", ")} dBFS for ${recipe.peak_dbfs}), the impact recipe cut a quiet take's 0.2 s lead-in (onset ${(hitOnset * 1000).toFixed(1)} ms), loop seam ${seamRatio(bed).toFixed(2)} x a normal step (was ${seamRatio(raw).toFixed(2)}), a 0 ms crossfade keeps the loop as generated, one pick for a row of 2 gave exactly that take`);
      passes.push(`levels: a row's takes are loudness-matched (shot's two knocks within ${shotSpread.toFixed(2)} LU), the manifest game/sfx.json gives every sound its takes and the gain from its measured loudness to its level, an unreachable level is a reported shortfall, and a run over one row keeps the others' entries`);

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
      // the rest of its row and the other rows are still processed, and the run
      // ends non-zero listing the failed row.
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
      check(["shot_02.ogg", "bed_01.ogg", "bed_raw_01.ogg", "hit_01.ogg"].every((name) => existsSync(quietTake(name))), "after the near-silent take, the rest of its row and the other rows were not processed");
      passes.push("a near-silent candidate (-80 dBFS) is named (shot c01, silent after trimming); its row's other take and the other rows are processed, and the run exits 1 listing the failed row");

      // A take that fails takes its earlier output with it, named in the FAIL
      // line, and a failed row keeps no stale takes either.
      const replace = join(scratch, "process-replace");
      const replaceShot = join(replace, "candidates", "shot");
      const replaceTake = (name) => join(replace, "game", "test", name);
      mkdirSync(replaceShot, { recursive: true });
      for (const n of [1, 2]) cpSync(join(shotDir, `shot.c0${n}.wav`), join(replaceShot, `shot.c0${n}.wav`));
      const before = await runTool(["--out", replace, "--process", "--sheet", fixturePath, "--id", "shot"]);
      check(before.code === 0 && existsSync(replaceTake("shot_01.ogg")) && existsSync(replaceTake("shot_02.ogg")), `the first --process of the replace case failed (exit ${before.code})`);
      fromExpression(join(replaceShot, "shot.c02.wav"), NEAR_SILENT, 0.5);
      const anHourAgo = new Date(Date.now() - 3600_000);
      for (const n of [1, 2]) utimesSync(join(replaceShot, `shot.c0${n}.wav`), anHourAgo, anHourAgo);
      writeFileSync(join(replace, "picks.json"), JSON.stringify({ shot: [2] }));
      const after = await runTool(["--out", replace, "--process", "--sheet", fixturePath, "--id", "shot"]);
      check(after.code === 1 && after.stderr.includes("shot c02: silent after trimming") && after.stderr.includes("removed the earlier game/test/shot_01.ogg"), `a failed take did not remove and name its earlier output (exit ${after.code}): ${after.stderr.trim()}`);
      check(!existsSync(replaceTake("shot_01.ogg")) && !existsSync(replaceTake("shot_02.ogg")), `the failed row left earlier takes in game/: ${listDir(join(replace, "game", "test")).join(", ")}`);
      passes.push("a take that fails removes its earlier output and says so; a failed row keeps no stale takes");

      // Picks made before a candidate was made again (by --force-id) name an
      // earlier set: the row is refused until picks.json is updated.
      const stale = join(scratch, "process-stale-picks");
      const staleShot = join(stale, "candidates", "shot");
      mkdirSync(staleShot, { recursive: true });
      for (const n of [1, 2]) cpSync(join(shotDir, `shot.c0${n}.wav`), join(staleShot, `shot.c0${n}.wav`));
      writeFileSync(join(stale, "picks.json"), JSON.stringify({ shot: [2, 1] }));
      utimesSync(join(stale, "picks.json"), anHourAgo, anHourAgo);
      const twoHoursAgo = new Date(Date.now() - 7200_000);
      utimesSync(join(staleShot, "shot.c01.wav"), twoHoursAgo, twoHoursAgo);
      const staleRun = await runTool(["--out", stale, "--process", "--sheet", fixturePath, "--id", "shot"]);
      check(staleRun.code === 1 && staleRun.stderr.includes("picks.json is older than c02") && !existsSync(join(stale, "game", "test", "shot_01.ogg")),
        `picks older than a picked candidate were used (exit ${staleRun.code}): ${staleRun.all.trim()}`);
      passes.push("picks.json older than a picked candidate (made again after the pick) refuses the row instead of using an unheard take");
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
