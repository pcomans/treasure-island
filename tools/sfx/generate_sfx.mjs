#!/usr/bin/env node
// Makes the game's sound effects with ElevenLabs from the public prompt sheet,
// tools/sfx/prompts.json (workflow and reasoning: tools/sfx/README.md). Run it as
// tools/generate-sfx, which puts the devcontainer's node on PATH.
//
//   tools/generate-sfx --out DIR [--tier 1,2] [--id ID,...]   dry run: what would be made, at what cost
//   tools/generate-sfx --out DIR --generate [--force-id ID] [--concurrency N] [--tier ..] [--id ..]
//                                                             make the candidates not yet in DIR
//   tools/generate-sfx --out DIR --process [--tier ..] [--id ..]
//                                                             trim, loop, normalise and encode the kept takes
//
// Nothing is requested or charged without --generate. The audio stays private:
// ElevenLabs' terms forbid making output available as isolated audio files and
// this repository is public, so DIR must lie outside every Git work tree. A
// candidate already in DIR is never requested again; --force-id ID first moves
// that row's candidates into DIR/candidates/ID/replaced-<time>/, then makes a
// fresh set. The API key (ELEVENLABS_API_KEY, from the environment or
// ~/.config/elevenlabs/.env) is never printed or logged.
//
//   DIR/candidates/<id>/<id>.cNN.<wav|mp3>  what ElevenLabs returned, one file a generation
//   DIR/generation-log.jsonl               a line a generation: id, prompt, model, settings, credits, time, file
//   DIR/picks.json                         optional, by hand: {"<id>": [candidate numbers, in take order]}
//   DIR/game/<group>/<name>_NN.ogg         the processed takes for the game (--process, needs ffmpeg)

import { spawnSync } from "node:child_process";
import { appendFileSync, existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, realpathSync, renameSync, rmSync, statSync, unlinkSync } from "node:fs";
import { open, rename } from "node:fs/promises";
import { homedir } from "node:os";
import { basename, dirname, join, relative, resolve, sep } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { parseArgs } from "node:util";

const TOOL = "tools/generate-sfx";
export const REPO_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
export const SHEET_PATH = resolve(REPO_ROOT, "tools/sfx/prompts.json");
export const SCHEMA = "ti.sfx-prompts/1";

// The endpoint, from its reference (checked 2026-11-14):
// https://elevenlabs.io/docs/api-reference/text-to-sound-effects/convert
// POST /v1/sound-generation?output_format=<codec_rate[_bitrate]>, JSON body text,
// model_id (defaults to eleven_text_to_sound_v2, so it is always sent),
// duration_seconds ("Must be at least 0.5 and at most 30"), prompt_influence
// (0 to 1) and loop. "MP3 with 192kbps bitrate requires ... Creator tier";
// "PCM and WAV formats with 44.1kHz ... Pro tier". The answer is the audio.
const API_BASE = "https://api.elevenlabs.io";
const API_PATH = "/v1/sound-generation";
export const DURATION_RANGE = Object.freeze([0.5, 30]);
// "There is a maximum length of 450 characters for your prompt" (help centre).
export const PROMPT_MAX_CHARS = 450;
// Sound effects have their own concurrency per plan (6 on Creator); "Requests
// beyond the limit and its reduced-priority queue return 429"
// (https://elevenlabs.io/docs/changelog/2026/11/9). A 429 or 5xx is retried
// after Retry-After or a doubling wait; so is a connection that never opened.
// Anything else stops the run: a request that reached ElevenLabs and then
// failed or timed out may have been charged, so it is not silently repeated.
const MAX_ATTEMPTS = 8;
const BACKOFF_CAP_S = 30;
const RETRY_AFTER_CAP_S = 120;
const REQUEST_TIMEOUT_MS = 300_000;
const NOT_SENT_CODES = new Set(["ECONNREFUSED", "ENOTFOUND", "EAI_AGAIN", "UND_ERR_CONNECT_TIMEOUT"]);
// Post-processing: silence kept before a one-shot's onset and after its tail,
// and the level below which a trimmed take counts as silent.
const LEAD_KEEP_S = 0.003;
const TAIL_KEEP_S = 0.01;
const SILENT_DBFS = -70;
// How far an encoded take's decoded peak may sit above the recipe's, and how
// many encodings may be tried to bring it there.
const PEAK_OVER_DB = 0.3;
const PEAK_PASSES = 3;

const SHEET_FIELDS = ["car", "credits_per_second", "encode", "events", "model_id", "not_voiced", "notes", "output_format", "plan", "recipes", "schema_version", "sounds"];
const ROW_FIELDS = ["candidates_per_take", "duration_seconds", "events", "id", "keep_takes", "loop", "notes", "output", "prompt", "prompt_influence", "recipe", "tier"];
const ONE_SHOT_RECIPE_FIELDS = ["channels", "fade_in_ms", "fade_out_ms", "max_seconds", "peak_dbfs", "trim_end_db", "trim_start_db", "what"];
const LOOP_RECIPE_FIELDS = ["channels", "loop_crossfade_ms", "peak_dbfs", "trim_end_db", "trim_start_db", "what"];
// Owner decision 2026-11-14, from ElevenLabs' prompting guidance: the length,
// looping and prompt influence are set per row, never described in the text,
// and a prompt never asks for a number of repetitions.
const PROMPT_RULES = [
  [/\bloop(?:s|ed|ing|able)?\b/iu, "says loop in the text; set \"loop\" instead"],
  [/\bseamless(?:ly)?\b/iu, "says seamless in the text; set \"loop\" instead"],
  [/\b\d+(?:\.\d+)?\s*-?\s*(?:ms|s|secs?|seconds?|minutes?)\b/iu, "gives a length in the text; set duration_seconds instead"],
  [/\bprompt influence\b/iu, "describes the prompt influence; set prompt_influence instead"],
  [/\b(?:\d+|two|three|four|five|six|seven|eight|nine|ten|several|multiple|twice|thrice)\s+(?:times|steps|footsteps|hits|knocks|bounces|clicks|taps|kicks|thuds|claps|bangs)\b|\btwice\b|\bthrice\b/iu, "asks for a number of repetitions; one sound per prompt"],
];
// A prompt that mentions a car must name the sheet's one car (owner 2026-11-14).
const CAR_WORDS = /\b(?:car|cars|vehicle|vehicles|sedan|suv|crossover|truck|trucks|van|vans)\b/iu;
const ID_RE = /^[a-z][a-z0-9_]*$/u;
const EVENT_RE = /^[A-Z][0-9]+$/u;
const OUTPUT_RE = /^([a-z]+)\/([a-z0-9_]+)_\{take\}\.ogg$/u;
const FORMAT_RE = /^(wav|mp3)_\d+(?:_\d+)?$/u;

const isObject = (value) => typeof value === "object" && value !== null && !Array.isArray(value);
const isNumber = (value) => typeof value === "number" && Number.isFinite(value);
const pad2 = (n) => String(n).padStart(2, "0");
const plural = (n, word) => `${n} ${word}${n === 1 ? "" : "s"}`;
const credits = (n) => Math.round(n).toLocaleString("en-US");

// --- The sheet -------------------------------------------------------------

export function loadSheet(path = SHEET_PATH) {
  let sheet;
  try {
    sheet = JSON.parse(readFileSync(path, "utf8"));
  } catch (error) {
    return { sheet: null, problems: [`${path}: ${error.message}`] };
  }
  return { sheet, problems: validateSheet(sheet) };
}

// Every problem with the sheet, as sentences; an empty list means it is valid.
export function validateSheet(sheet) {
  const problems = [];
  const problem = (text) => problems.push(text);
  if (!isObject(sheet)) return ["the sheet is not a JSON object"];
  for (const key of Object.keys(sheet)) if (!SHEET_FIELDS.includes(key)) problem(`unknown sheet field ${key}`);
  if (sheet.schema_version !== SCHEMA) problem(`schema_version must be ${SCHEMA}`);
  if (!Array.isArray(sheet.notes) || !sheet.notes.every((note) => typeof note === "string" && note.trim())) problem("notes must be a list of sentences");
  if (typeof sheet.model_id !== "string" || !sheet.model_id.trim()) problem("model_id must name the model (the API would otherwise use its default)");
  if (!isNumber(sheet.credits_per_second) || sheet.credits_per_second <= 0) problem("credits_per_second must be a positive number");
  const plan = sheet.plan;
  if (!isObject(plan) || typeof plan.name !== "string" || !Number.isInteger(plan.credits_per_month) || plan.credits_per_month <= 0 || !Number.isInteger(plan.concurrency) || plan.concurrency < 1) {
    problem("plan must give name, credits_per_month and concurrency");
  }
  for (const kind of ["one_shot", "loop"]) {
    if (!FORMAT_RE.test(sheet.output_format?.[kind] ?? "")) problem(`output_format.${kind} must be a wav_ or mp3_ format the post-processing can read`);
  }
  const car = sheet.car;
  if (!isObject(car) || typeof car.name !== "string" || !car.name.trim() || car.basis !== "production_inference" || typeof car.why !== "string" || !car.why.trim()) {
    problem("car must give name, basis production_inference and why");
  }
  const encode = sheet.encode;
  if (!isObject(encode) || encode.codec !== "libvorbis" || !isNumber(encode.quality) || encode.quality < 0 || encode.quality > 10 || !Number.isInteger(encode.sample_rate) || encode.sample_rate < 8000) {
    problem("encode must be libvorbis with a quality from 0 to 10 and a sample_rate");
  }
  const recipes = isObject(sheet.recipes) ? sheet.recipes : {};
  if (!isObject(sheet.recipes) || !Object.keys(recipes).length) problem("recipes must be an object of post-processing recipes");
  for (const [name, recipe] of Object.entries(recipes)) {
    for (const text of validateRecipe(recipe)) problem(`recipe ${name}: ${text}`);
  }
  const events = isObject(sheet.events) ? sheet.events : {};
  if (!isObject(sheet.events) || !Object.keys(events).length) problem("events must list the game's sound events");
  for (const [id, text] of Object.entries(events)) {
    if (!EVENT_RE.test(id)) problem(`event id ${id} must be a letter and a number, like P1`);
    if (typeof text !== "string" || !text.trim()) problem(`event ${id} needs a description`);
  }
  const notVoiced = isObject(sheet.not_voiced) ? sheet.not_voiced : {};
  if (!isObject(sheet.not_voiced)) problem("not_voiced must be an object (event id: reason)");
  if (!Array.isArray(sheet.sounds) || !sheet.sounds.length) {
    problem("sounds must be a non-empty list");
    return problems;
  }
  const ids = new Set();
  const outputs = new Set();
  const served = new Set();
  const usedRecipes = new Set();
  sheet.sounds.forEach((row, index) => {
    const label = `sound ${isObject(row) && typeof row.id === "string" ? row.id : `#${index + 1}`}`;
    if (!isObject(row)) {
      problem(`${label} is not an object`);
      return;
    }
    for (const key of Object.keys(row)) if (!ROW_FIELDS.includes(key)) problem(`${label}: unknown field ${key}`);
    if (typeof row.id !== "string" || !ID_RE.test(row.id)) problem(`${label}: id must be lower_snake_case`);
    else if (ids.has(row.id)) problem(`${label}: id is used twice`);
    else ids.add(row.id);
    if (![1, 2, 3].includes(row.tier)) problem(`${label}: tier must be 1, 2 or 3`);
    if (!Array.isArray(row.events) || !row.events.length) problem(`${label}: events must list the event ids it serves`);
    else {
      if (new Set(row.events).size !== row.events.length) problem(`${label}: an event is listed twice`);
      for (const event of row.events) {
        if (!Object.hasOwn(events, event)) problem(`${label}: unknown event ${event}`);
        served.add(event);
      }
    }
    for (const text of validatePrompt(row.prompt, sheet.car?.name)) problem(`${label}: prompt ${text}`);
    const duration = row.duration_seconds;
    if (!isNumber(duration) || duration < DURATION_RANGE[0] || duration > DURATION_RANGE[1]) problem(`${label}: duration_seconds must be from ${DURATION_RANGE[0]} to ${DURATION_RANGE[1]}`);
    else if (Math.abs(duration * 10 - Math.round(duration * 10)) > 1e-9) problem(`${label}: duration_seconds must be a whole number of tenths`);
    if (typeof row.loop !== "boolean") problem(`${label}: loop must be true or false`);
    if (!isNumber(row.prompt_influence) || row.prompt_influence < 0 || row.prompt_influence > 1) problem(`${label}: prompt_influence must be from 0 to 1`);
    for (const field of ["keep_takes", "candidates_per_take"]) {
      if (!Number.isInteger(row[field]) || row[field] < 1) problem(`${label}: ${field} must be a whole number of at least 1`);
    }
    if (Number.isInteger(row.keep_takes) && Number.isInteger(row.candidates_per_take) && row.keep_takes * row.candidates_per_take > 99) problem(`${label}: at most 99 candidates`);
    const output = typeof row.output === "string" ? row.output.match(OUTPUT_RE) : null;
    if (!output) problem(`${label}: output must be like group/name_{take}.ogg`);
    else if (outputs.has(output[0])) problem(`${label}: output ${output[0]} is used twice`);
    else outputs.add(output[0]);
    if (row.notes !== undefined && (typeof row.notes !== "string" || !row.notes.trim())) problem(`${label}: notes must be a sentence when given`);
    const recipe = recipes[row.recipe];
    if (typeof row.recipe !== "string" || !recipe) problem(`${label}: unknown recipe ${row.recipe}`);
    else {
      usedRecipes.add(row.recipe);
      const loopRecipe = Object.hasOwn(recipe, "loop_crossfade_ms");
      if (row.loop === true && !loopRecipe) problem(`${label}: a loop row needs a loop recipe (one with loop_crossfade_ms)`);
      if (row.loop === false && loopRecipe) problem(`${label}: a one-shot row needs a one-shot recipe`);
      if (row.loop === true && loopRecipe && isNumber(duration) && isNumber(recipe.loop_crossfade_ms) && recipe.loop_crossfade_ms * 4 > duration * 1000) {
        problem(`${label}: ${duration} s is too short for the recipe's ${recipe.loop_crossfade_ms} ms crossfade (needs 4 times that)`);
      }
    }
  });
  for (const name of Object.keys(recipes)) if (!usedRecipes.has(name)) problem(`recipe ${name} is not used by any sound`);
  for (const [id, reason] of Object.entries(notVoiced)) {
    if (!Object.hasOwn(events, id)) problem(`not_voiced names unknown event ${id}`);
    if (typeof reason !== "string" || !reason.trim()) problem(`not_voiced ${id} needs a reason`);
    if (served.has(id)) problem(`event ${id} is both voiced by a sound and listed as not_voiced`);
  }
  for (const id of Object.keys(events)) {
    if (!served.has(id) && !Object.hasOwn(notVoiced, id)) problem(`event ${id} is neither voiced by a sound nor listed as not_voiced`);
  }
  return problems;
}

function validateRecipe(recipe) {
  if (!isObject(recipe)) return ["is not an object"];
  const problems = [];
  const loop = Object.hasOwn(recipe, "loop_crossfade_ms");
  const fields = loop ? LOOP_RECIPE_FIELDS : ONE_SHOT_RECIPE_FIELDS;
  for (const key of Object.keys(recipe)) if (!fields.includes(key)) problems.push(`field ${key} does not belong in a ${loop ? "loop" : "one-shot"} recipe`);
  for (const key of fields) if (!Object.hasOwn(recipe, key)) problems.push(`needs ${key}`);
  if (typeof recipe.what !== "string" || !recipe.what.trim()) problems.push("what must say what it is for");
  if (![1, 2].includes(recipe.channels)) problems.push("channels must be 1 or 2");
  for (const key of ["trim_start_db", "trim_end_db"]) {
    if (recipe[key] !== null && (!isNumber(recipe[key]) || recipe[key] > 0 || recipe[key] < -120)) problems.push(`${key} must be null or a level from -120 to 0 dB`);
  }
  if (!isNumber(recipe.peak_dbfs) || recipe.peak_dbfs > 0 || recipe.peak_dbfs < -24) problems.push("peak_dbfs must be from -24 to 0");
  if (loop) {
    if (!isNumber(recipe.loop_crossfade_ms) || recipe.loop_crossfade_ms <= 0) problems.push("loop_crossfade_ms must be positive");
  } else {
    if (recipe.max_seconds !== null && (!isNumber(recipe.max_seconds) || recipe.max_seconds <= 0)) problems.push("max_seconds must be null or positive");
    for (const key of ["fade_in_ms", "fade_out_ms"]) if (!isNumber(recipe[key]) || recipe[key] < 0) problems.push(`${key} must be 0 or more`);
  }
  return problems;
}

function validatePrompt(prompt, carName) {
  if (typeof prompt !== "string" || !prompt.trim()) return ["must be text"];
  const problems = [];
  if (prompt.length > PROMPT_MAX_CHARS) problems.push(`is ${prompt.length} characters; at most ${PROMPT_MAX_CHARS}`);
  if (prompt !== prompt.trim()) problems.push("has spaces at an end");
  for (const [pattern, text] of PROMPT_RULES) if (pattern.test(prompt)) problems.push(text);
  if (CAR_WORDS.test(prompt) && !(typeof carName === "string" && carName && prompt.includes(carName))) problems.push(`mentions a car without naming the sheet's car (${carName})`);
  return problems;
}

export const generationsOf = (row) => row.keep_takes * row.candidates_per_take;
export const creditsOf = (sheet, row) => Math.round(sheet.credits_per_second * row.duration_seconds * generationsOf(row));
const formatOf = (sheet, row) => (row.loop ? sheet.output_format.loop : sheet.output_format.one_shot);
const candidateName = (sheet, row, n) => `${row.id}.c${pad2(n)}.${formatOf(sheet, row).split("_")[0]}`;
const candidateFile = (out, sheet, row, n) => join(out, "candidates", row.id, candidateName(sheet, row, n));

// The rows a run works on, in sheet order. Unknown ids throw (a usage error).
export function selectRows(sheet, { tiers = [], ids = [] } = {}) {
  const known = new Set(sheet.sounds.map((row) => row.id));
  const unknown = ids.filter((id) => !known.has(id));
  if (unknown.length) throw new UsageError(`unknown sound id ${unknown.join(", ")}`);
  return sheet.sounds.filter((row) => (!tiers.length || tiers.includes(row.tier)) && (!ids.length || ids.includes(row.id)));
}

// --- Where the audio goes --------------------------------------------------

// Why OUT may not be used (it lies in this repository or any Git work tree), or null.
export function outProblem(out) {
  const target = resolve(out);
  let probe = target;
  const rest = [];
  while (!existsSync(probe)) {
    rest.unshift(basename(probe));
    probe = dirname(probe);
  }
  if (!statSync(probe).isDirectory()) return `${probe} is not a directory`;
  const real = join(realpathSync(probe), ...rest);
  const repo = realpathSync(REPO_ROOT);
  if (real === repo || real.startsWith(repo + sep)) return `it lies inside this repository (${repo}), which is public`;
  const env = Object.fromEntries(Object.entries(process.env).filter(([key]) => !key.startsWith("GIT_")));
  const git = spawnSync("git", ["-C", realpathSync(probe), "rev-parse", "--is-inside-work-tree", "--is-inside-git-dir"], { encoding: "utf8", env });
  if (git.status === 0 && git.stdout.split("\n").some((line) => line.trim() === "true")) return "it lies inside a Git work tree";
  return null;
}

// --- The key ---------------------------------------------------------------

export function findApiKey(env = process.env) {
  const fromEnv = env.ELEVENLABS_API_KEY?.trim();
  if (fromEnv) return { key: fromEnv, from: "ELEVENLABS_API_KEY" };
  let text;
  try {
    text = readFileSync(join(homedir(), ".config", "elevenlabs", ".env"), "utf8");
  } catch {
    return null;
  }
  for (const line of text.split(/\r?\n/u)) {
    const match = line.match(/^\s*(?:export\s+)?ELEVENLABS_API_KEY\s*=\s*(.*?)\s*$/u);
    if (!match) continue;
    let value = match[1];
    if (value.length >= 2 && (value[0] === "\"" || value[0] === "'") && value.endsWith(value[0])) value = value.slice(1, -1);
    if (value.trim()) return { key: value.trim(), from: "~/.config/elevenlabs/.env" };
  }
  return null;
}

// ELEVENLABS_API_BASE may name another ElevenLabs host (its data-residency
// servers) or, for the offline check, a stand-in on this machine's loopback.
function apiBase(env = process.env) {
  const raw = env.ELEVENLABS_API_BASE?.trim();
  if (!raw) return API_BASE;
  let url;
  try {
    url = new URL(raw);
  } catch {
    throw new UsageError("ELEVENLABS_API_BASE is not a URL");
  }
  const loopback = ["127.0.0.1", "localhost", "[::1]"].includes(url.hostname);
  if (url.protocol !== "https:" && !(url.protocol === "http:" && loopback)) throw new UsageError("ELEVENLABS_API_BASE must be https (plain http only on this machine's loopback)");
  return url.origin;
}

// --- Dry run ---------------------------------------------------------------

// For each row: which candidates are on disk, missing, or made from other settings.
function survey(out, sheet, rows, forced) {
  const logged = new Map();
  const logPath = join(out, "generation-log.jsonl");
  if (existsSync(logPath)) {
    for (const line of readFileSync(logPath, "utf8").split("\n")) {
      try {
        const entry = JSON.parse(line);
        if (entry?.status === "ok" && typeof entry.file === "string") logged.set(entry.file, entry);
      } catch {
        // A torn last line from an interrupted run; the file it named is checked on disk.
      }
    }
  }
  return rows.map((row) => {
    const format = formatOf(sheet, row);
    const present = [];
    let stale = 0;
    for (let n = 1; n <= generationsOf(row); n += 1) {
      const file = candidateFile(out, sheet, row, n);
      if (!existsSync(file)) continue;
      present.push(n);
      const entry = logged.get(relative(out, file));
      if (entry && (entry.prompt !== row.prompt || entry.model_id !== sheet.model_id || entry.duration_seconds !== row.duration_seconds
        || entry.loop !== row.loop || entry.prompt_influence !== row.prompt_influence || entry.output_format !== format)) stale += 1;
    }
    const toMake = forced.has(row.id) ? generationsOf(row) : generationsOf(row) - present.length;
    return { row, present, stale, toMake, toMakeCredits: Math.round(sheet.credits_per_second * row.duration_seconds * toMake) };
  });
}

function printPlan(sheet, sheetPath, out, surveyed) {
  const line = (cells) => console.log(cells.map(([text, width, left]) => (left ? String(text).padEnd(width) : String(text).padStart(width))).join(" "));
  console.log(`Sound effects from ${relative(process.cwd(), sheetPath) || sheetPath}: ${sheet.model_id}, ${sheet.credits_per_second} credits a second of set length.`);
  console.log(`Output: ${out}`);
  line([["id", 24, true], ["tier", 4], ["keep", 4], ["gens", 4], ["secs", 6], ["credits", 8], ["to make", 8]]);
  for (const { row, toMakeCredits } of surveyed) {
    line([[row.id, 24, true], [row.tier, 4], [row.keep_takes, 4], [generationsOf(row), 4], [row.duration_seconds.toFixed(1), 6], [credits(creditsOf(sheet, row)), 8], [credits(toMakeCredits), 8]]);
  }
  const total = (rows) => ({
    sounds: rows.length,
    gens: rows.reduce((sum, item) => sum + generationsOf(item.row), 0),
    credits: rows.reduce((sum, item) => sum + creditsOf(sheet, item.row), 0),
    toMake: rows.reduce((sum, item) => sum + item.toMakeCredits, 0),
  });
  for (const tier of [1, 2, 3]) {
    const rows = surveyed.filter((item) => item.row.tier === tier);
    if (!rows.length) continue;
    const t = total(rows);
    console.log(`tier ${tier}: ${plural(t.sounds, "sound")}, ${plural(t.gens, "generation")}, ${credits(t.credits)} credits; to make: ${credits(t.toMake)}`);
  }
  const t = total(surveyed);
  console.log(`total: ${plural(t.sounds, "sound")}, ${plural(t.gens, "generation")}, ${credits(t.credits)} credits; to make: ${credits(t.toMake)} (${sheet.plan.name} plan: ${credits(sheet.plan.credits_per_month)} credits a month)`);
  if (t.toMake > sheet.plan.credits_per_month) console.error(`NOTE: making all of this needs more than one month of the ${sheet.plan.name} plan's credits.`);
  for (const { row, stale } of surveyed) {
    if (stale) console.error(`NOTE: ${row.id}: ${plural(stale, "candidate")} on disk came from other settings than the sheet's; --force-id ${row.id} makes a fresh set.`);
  }
  return t;
}

// --- Generation ------------------------------------------------------------

async function writeAtomic(file, bytes) {
  const part = `${file}.part`;
  const handle = await open(part, "w");
  try {
    await handle.writeFile(bytes);
    await handle.sync();
  } finally {
    await handle.close();
  }
  await rename(part, file);
}

const sleep = (seconds) => new Promise((done) => setTimeout(done, seconds * 1000));
const backoffSeconds = (attempt) => Math.round(Math.min(BACKOFF_CAP_S, 2 ** (attempt - 1)) * (1 + Math.random() * 0.25) * 10) / 10;

function retryAfterSeconds(header) {
  if (header === null) return null;
  const text = header.trim();
  if (/^\d+(?:\.\d+)?$/u.test(text)) return Math.min(RETRY_AFTER_CAP_S, Number(text));
  const when = Date.parse(text);
  return Number.isNaN(when) ? null : Math.min(RETRY_AFTER_CAP_S, Math.max(0, (when - Date.now()) / 1000));
}

function moveAside(out, sheet, row) {
  const stamp = new Date().toISOString().replace(/[-:]/gu, "").replace(/\.\d+Z$/u, "Z");
  const aside = join(out, "candidates", row.id, `replaced-${stamp}`);
  let moved = 0;
  for (let n = 1; n <= generationsOf(row); n += 1) {
    const file = candidateFile(out, sheet, row, n);
    if (!existsSync(file)) continue;
    mkdirSync(aside, { recursive: true });
    renameSync(file, join(aside, basename(file)));
    moved += 1;
  }
  if (moved) console.log(`moved ${plural(moved, "candidate")} of ${row.id} to ${relative(out, aside)}`);
}

async function generate({ sheet, out, surveyed, forced, key, base, concurrency }) {
  const redact = (text) => String(text).split(key).join("[key]");
  const excerpt = (text) => redact(text).replace(/\s+/gu, " ").trim().slice(0, 400);
  const logPath = join(out, "generation-log.jsonl");
  const log = (entry) => appendFileSync(logPath, `${JSON.stringify(entry)}\n`);
  for (const item of surveyed) if (forced.has(item.row.id)) moveAside(out, sheet, item.row);
  const tasks = [];
  for (const { row } of surveyed) {
    for (let n = 1; n <= generationsOf(row); n += 1) {
      const file = candidateFile(out, sheet, row, n);
      if (!existsSync(file)) tasks.push({ row, n, file, format: formatOf(sheet, row) });
    }
  }
  if (!tasks.length) {
    console.log(`Nothing to make: every candidate of the chosen sounds is already in ${out}.`);
    return 0;
  }
  const planned = tasks.reduce((sum, task) => sum + sheet.credits_per_second * task.row.duration_seconds, 0);
  console.log(`Making ${plural(tasks.length, "candidate")} for ${credits(planned)} credits, up to ${concurrency} at a time.`);

  let next = 0;
  let stop = null;
  let made = 0;
  let spent = 0;
  // A wait before a retry ends the task instead when the run has stopped meanwhile.
  const waitToRetry = async (label, seconds) => {
    await sleep(seconds);
    if (stop !== null) throw new Error(`${label}: not retried, the run had stopped`);
  };
  const makeOne = async ({ row, n, file, format }) => {
    const label = `${row.id} c${pad2(n)}`;
    const cost = Math.round(sheet.credits_per_second * row.duration_seconds);
    const settings = { model_id: sheet.model_id, duration_seconds: row.duration_seconds, loop: row.loop, prompt_influence: row.prompt_influence, output_format: format };
    const record = (fields) => log({ time: new Date().toISOString(), id: row.id, candidate: n, file: relative(out, file), prompt: row.prompt, ...settings, ...fields });
    const url = `${base}${API_PATH}?output_format=${encodeURIComponent(format)}`;
    const body = JSON.stringify({ text: row.prompt, model_id: sheet.model_id, duration_seconds: row.duration_seconds, prompt_influence: row.prompt_influence, loop: row.loop });
    mkdirSync(dirname(file), { recursive: true });
    for (let attempt = 1; ; attempt += 1) {
      let response;
      try {
        response = await fetch(url, { method: "POST", headers: { "xi-api-key": key, "content-type": "application/json" }, body, signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS) });
      } catch (error) {
        // undici puts the system error code in cause; a timeout is a DOMException named TimeoutError.
        const code = String(error?.cause?.code ?? error?.name ?? "error");
        if (NOT_SENT_CODES.has(code) && attempt < MAX_ATTEMPTS) {
          const wait = backoffSeconds(attempt);
          console.error(`NOTE: ${label}: could not connect (${code}); trying again in ${wait} s`);
          await waitToRetry(label, wait);
          continue;
        }
        record({ status: "error", error: excerpt(`${code}: ${error?.message ?? ""}`) });
        throw new Error(`${label}: the request failed (${excerpt(code)}); if it reached ElevenLabs it may have been charged, so it is not repeated`);
      }
      if (response.status === 429 || response.status >= 500) {
        const text = await response.text().catch(() => "");
        if (attempt < MAX_ATTEMPTS) {
          const wait = retryAfterSeconds(response.headers.get("retry-after")) ?? backoffSeconds(attempt);
          console.error(`NOTE: ${label}: HTTP ${response.status}${response.status === 429 ? " (more requests than the plan runs at once)" : ""}; trying again in ${wait} s`);
          await waitToRetry(label, wait);
          continue;
        }
        record({ status: "error", http_status: response.status, error: excerpt(text) });
        throw new Error(`${label}: HTTP ${response.status} after ${attempt} attempts: ${excerpt(text)}`);
      }
      const type = response.headers.get("content-type") ?? "";
      if (!response.ok || /json|text/u.test(type)) {
        const text = await response.text().catch(() => "");
        record({ status: "error", http_status: response.status, error: excerpt(text) });
        throw new Error(`${label}: HTTP ${response.status}${response.ok ? ` but ${type} instead of audio` : ""}: ${excerpt(text)}`);
      }
      const bytes = Buffer.from(await response.arrayBuffer());
      if (!bytes.length) {
        record({ status: "error", http_status: response.status, error: "empty answer" });
        throw new Error(`${label}: HTTP ${response.status} with no audio`);
      }
      await writeAtomic(file, bytes);
      record({ status: "ok", credits: cost });
      console.log(`made ${relative(out, file)} (${cost} credits)`);
      return cost;
    }
  };

  const worker = async () => {
    while (stop === null && next < tasks.length) {
      const task = tasks[next];
      next += 1;
      try {
        spent += await makeOne(task);
        made += 1;
      } catch (error) {
        stop ??= error;
      }
    }
  };
  await Promise.all(Array.from({ length: Math.min(concurrency, tasks.length) }, worker));
  if (stop) {
    console.error(`FAIL: ${redact(stop.message)}`);
    console.error(`Stopped after making ${plural(made, "candidate")} (${credits(spent)} credits); no request was started after the stop. Run again to resume: candidates already made are kept and not requested again.`);
    return 1;
  }
  console.log(`Made ${plural(made, "candidate")} for ${credits(spent)} credits. Log: ${relative(process.cwd(), logPath) || logPath}`);
  console.log(`Next: listen, list the keepers in ${join(out, "picks.json")} (optional), then run ${TOOL} --out ${out} --process.`);
  return 0;
}

// --- Post-processing -------------------------------------------------------

function run(command, args) {
  const result = spawnSync(command, args, { encoding: "utf8", maxBuffer: 64 * 1024 * 1024 });
  if (result.error) throw new Error(`${command} could not run: ${result.error.message}`);
  if (result.status !== 0) throw new Error(`${command} failed: ${result.stderr.trim().split("\n").slice(-3).join(" / ")}`);
  return result;
}

const ffmpeg = (args) => run("ffmpeg", ["-hide_banner", "-nostdin", "-y", ...args]);

function samplesOf(file) {
  const result = run("ffprobe", ["-v", "error", "-select_streams", "a:0", "-show_entries", "stream=duration_ts", "-of", "csv=p=0", file]);
  const samples = Number.parseInt(result.stdout.trim(), 10);
  if (!Number.isInteger(samples)) throw new Error(`ffprobe gave no length for ${file}`);
  return samples;
}

// The sample peak in dBFS, measured in float (astats), so an overshoot above
// full scale reads as such; volumedetect works on 16-bit samples and caps it at 0.
function peakDbfs(file, format = []) {
  const result = ffmpeg(["-v", "info", "-nostats", ...format, "-i", file, "-af", "astats=measure_perchannel=none:measure_overall=Peak_level", "-f", "null", "-"]);
  const matches = [...result.stderr.matchAll(/Peak level dB:\s*(-?(?:\d+(?:\.\d+)?|inf))/gu)];
  if (!matches.length) throw new Error(`no level measured for ${file}`);
  const value = matches.at(-1)[1];
  return value.endsWith("inf") ? -Infinity : Number(value);
}

// One candidate through its recipe into an Ogg Vorbis take; returns its length (s).
export function processTake(sheet, recipe, input, output, work) {
  const rate = sheet.encode.sample_rate;
  const loop = Object.hasOwn(recipe, "loop_crossfade_ms");
  const chain = [`aresample=${rate}`];
  if (recipe.trim_start_db !== null) {
    chain.push(`silenceremove=start_periods=1:start_threshold=${recipe.trim_start_db}dB:start_silence=${loop ? 0 : LEAD_KEEP_S}:detection=peak`, "asetpts=PTS-STARTPTS");
  }
  if (!loop && recipe.max_seconds !== null) chain.push(`atrim=end=${recipe.max_seconds}`, "asetpts=PTS-STARTPTS");
  // The tail is handled reversed: its silence becomes a lead, a fade-out a fade-in.
  const tail = [];
  if (recipe.trim_end_db !== null) tail.push(`silenceremove=start_periods=1:start_threshold=${recipe.trim_end_db}dB:start_silence=${loop ? 0 : TAIL_KEEP_S}:detection=peak`);
  if (!loop && recipe.fade_out_ms > 0) tail.push(`afade=t=in:d=${recipe.fade_out_ms / 1000}`);
  if (tail.length) chain.push("areverse", ...tail, "areverse");
  if (!loop && recipe.fade_in_ms > 0) chain.push(`afade=t=in:d=${recipe.fade_in_ms / 1000}`);
  const shaped = join(work, "shaped.wav");
  ffmpeg(["-v", "error", "-i", input, "-af", chain.join(","), "-ac", String(recipe.channels), "-c:a", "pcm_f32le", shaped]);
  let source = shaped;
  let samples = samplesOf(shaped);
  if (loop) {
    // Crossfade the last X samples into the first X (equal power): the take
    // becomes original[X .. L-X] followed by the blend of original[L-X .. L]
    // into original[0 .. X], so its end runs on into its start without a jump.
    const x = Math.round((recipe.loop_crossfade_ms / 1000) * rate);
    if (samples < 4 * x) throw new Error(`only ${(samples / rate).toFixed(2)} s after trimming, too short for a ${recipe.loop_crossfade_ms} ms crossfade`);
    const looped = join(work, "looped.wav");
    ffmpeg(["-v", "error", "-i", shaped, "-filter_complex",
      `[0:a]asplit=2[a][b];[a]atrim=start_sample=${x},asetpts=PTS-STARTPTS[body];[b]atrim=end_sample=${x},asetpts=PTS-STARTPTS[head];[body][head]acrossfade=ns=${x}:c1=qsin:c2=qsin[out]`,
      "-map", "[out]", "-c:a", "pcm_f32le", looped]);
    source = looped;
    samples = samplesOf(looped);
  }
  const peak = peakDbfs(source);
  if (!(peak > SILENT_DBFS)) throw new Error(`silent after trimming (peak ${peak} dBFS); pick another candidate`);
  // Lossy coding overshoots the peak of bright transients (white noise by about
  // 2.6 dB at quality 5), so the encoded take is measured and its gain lowered
  // until the decoded peak is within PEAK_OVER_DB of the recipe's.
  const part = `${output}.part`;
  let gain = recipe.peak_dbfs - peak;
  try {
    for (let pass = 1; ; pass += 1) {
      ffmpeg(["-v", "error", "-i", source, "-af", `volume=${gain.toFixed(2)}dB`, "-c:a", "libvorbis", "-q:a", String(sheet.encode.quality), "-ar", String(rate), "-f", "ogg", part]);
      const decoded = peakDbfs(part, ["-f", "ogg"]);
      if (decoded <= recipe.peak_dbfs + PEAK_OVER_DB) break;
      if (pass === PEAK_PASSES) throw new Error(`still peaks at ${decoded.toFixed(2)} dBFS after ${pass} encodings; the recipe asks ${recipe.peak_dbfs}`);
      gain -= decoded - recipe.peak_dbfs + 0.1;
    }
    renameSync(part, output);
  } finally {
    rmSync(part, { force: true });
  }
  return samples / rate;
}

function readPicks(out, sheet) {
  const path = join(out, "picks.json");
  if (!existsSync(path)) return {};
  let picks;
  try {
    picks = JSON.parse(readFileSync(path, "utf8"));
  } catch (error) {
    throw new Error(`${path} is not valid JSON: ${error.message}`);
  }
  if (!isObject(picks)) throw new Error(`${path} must be an object: {"<id>": [candidate numbers]}`);
  const rows = new Map(sheet.sounds.map((row) => [row.id, row]));
  for (const [id, list] of Object.entries(picks)) {
    const row = rows.get(id);
    if (!row) throw new Error(`${path} names ${id}, which is not in the sheet`);
    const valid = Array.isArray(list) && list.length >= 1 && list.length <= row.keep_takes && new Set(list).size === list.length
      && list.every((n) => Number.isInteger(n) && n >= 1 && n <= generationsOf(row));
    if (!valid) throw new Error(`${path}: ${id} must list 1 to ${row.keep_takes} different candidate numbers from 1 to ${generationsOf(row)}`);
  }
  return picks;
}

function postProcess({ sheet, out, rows }) {
  for (const tool of ["ffmpeg", "ffprobe"]) {
    const probe = spawnSync(tool, ["-version"], { encoding: "utf8" });
    if (probe.error || probe.status !== 0) {
      console.error(`FAIL: ${tool} is not on PATH; --process needs ffmpeg and ffprobe. .devcontainer/post-create.sh does not install them yet.`);
      return 1;
    }
  }
  if (!existsSync(join(out, "candidates"))) {
    console.error(`FAIL: no candidates in ${out}; run ${TOOL} --out ${out} --generate first.`);
    return 1;
  }
  const picks = readPicks(out, sheet);
  const work = mkdtempSync(join(out, ".work-"));
  let failed = 0;
  let skipped = 0;
  let takes = 0;
  try {
    for (const row of rows) {
      const recipe = sheet.recipes[row.recipe];
      const present = [];
      for (let n = 1; n <= generationsOf(row); n += 1) if (existsSync(candidateFile(out, sheet, row, n))) present.push(n);
      let chosen = picks[row.id];
      if (chosen) {
        const missing = chosen.filter((n) => !present.includes(n));
        if (missing.length) {
          console.error(`FAIL: ${row.id}: picked candidates ${missing.join(", ")} are not on disk`);
          failed += 1;
          continue;
        }
      } else if (present.length >= row.keep_takes) {
        chosen = present.slice(0, row.keep_takes);
      } else {
        console.error(`NOTE: ${row.id}: skipped, ${present.length} of the ${row.keep_takes} takes it keeps are on disk and picks.json names none; run --generate first`);
        skipped += 1;
        continue;
      }
      const [, group, name] = row.output.match(OUTPUT_RE);
      const folder = join(out, "game", group);
      mkdirSync(folder, { recursive: true });
      try {
        chosen.forEach((n, index) => {
          const output = join(folder, `${name}_${pad2(index + 1)}.ogg`);
          const seconds = processTake(sheet, recipe, candidateFile(out, sheet, row, n), output, work);
          console.log(`${relative(out, output)}  ${seconds.toFixed(2)} s ${recipe.channels === 1 ? "mono" : "stereo"}${row.loop ? " loop" : ""}  from c${pad2(n)}${picks[row.id] ? "" : " (first on disk)"}`);
          takes += 1;
        });
        // Takes beyond the ones kept now (fewer picks than before) are stale.
        const pattern = new RegExp(`^${name}_(\\d{2})\\.ogg$`, "u");
        for (const file of readdirSync(folder)) {
          const match = file.match(pattern);
          if (match && Number(match[1]) > chosen.length) unlinkSync(join(folder, file));
        }
      } catch (error) {
        console.error(`FAIL: ${row.id}: ${error.message}`);
        failed += 1;
      }
    }
  } finally {
    rmSync(work, { recursive: true, force: true });
  }
  console.log(`Processed ${plural(takes, "take")} into ${join(out, "game")}; ${failed} failed, ${skipped} skipped.`);
  return failed || skipped ? 1 : 0;
}

// --- Command line ----------------------------------------------------------

export class UsageError extends Error {}

const USAGE = `usage: ${TOOL} --out DIR [--tier 1,2,3] [--id ID,...] [--sheet PATH]
         dry run (the default): prints each sound's credits and what is still to make; requests nothing
       ${TOOL} --out DIR --generate [--force-id ID]... [--concurrency N] [--tier ..] [--id ..]
         makes the candidates not yet in DIR (needs ELEVENLABS_API_KEY, from the environment or ~/.config/elevenlabs/.env)
       ${TOOL} --out DIR --process [--tier ..] [--id ..]
         turns the kept takes into game-ready Ogg Vorbis files under DIR/game (needs ffmpeg)
DIR must lie outside every Git work tree: the audio is private.`;

function parseCommandLine(argv) {
  let values;
  try {
    ({ values } = parseArgs({
      args: argv,
      strict: true,
      allowPositionals: false,
      options: {
        out: { type: "string" },
        sheet: { type: "string" },
        tier: { type: "string", multiple: true },
        id: { type: "string", multiple: true },
        "force-id": { type: "string", multiple: true },
        concurrency: { type: "string" },
        "dry-run": { type: "boolean" },
        generate: { type: "boolean" },
        process: { type: "boolean" },
        help: { type: "boolean", short: "h" },
      },
    }));
  } catch (error) {
    throw new UsageError(error.message);
  }
  const list = (items) => (items ?? []).flatMap((item) => item.split(",")).map((item) => item.trim()).filter(Boolean);
  const tiers = list(values.tier).map(Number);
  if (tiers.some((tier) => ![1, 2, 3].includes(tier))) throw new UsageError("--tier takes 1, 2 or 3");
  const modes = ["dry-run", "generate", "process"].filter((mode) => values[mode]);
  if (modes.length > 1) throw new UsageError(`--${modes.join(" and --")} do not go together`);
  if (values["force-id"] && values.process) throw new UsageError("--force-id goes with --generate (or a dry run), not --process");
  if (values.concurrency !== undefined && !values.generate) throw new UsageError("--concurrency goes with --generate");
  if (!values.help && !values.out) throw new UsageError("--out DIR is required");
  return {
    help: Boolean(values.help),
    out: values.out,
    sheet: values.sheet ? resolve(values.sheet) : SHEET_PATH,
    tiers,
    ids: list(values.id),
    forced: list(values["force-id"]),
    concurrency: values.concurrency,
    mode: modes[0] ?? "dry-run",
  };
}

export async function main(argv = process.argv.slice(2)) {
  let args;
  try {
    args = parseCommandLine(argv);
  } catch (error) {
    console.error(`${TOOL}: ${error.message}\n${USAGE}`);
    return 2;
  }
  if (args.help) {
    console.log(USAGE);
    return 0;
  }
  const { sheet, problems } = loadSheet(args.sheet);
  if (problems.length) {
    for (const text of problems) console.error(`FAIL: ${text}`);
    console.error(`${TOOL}: ${args.sheet} has ${plural(problems.length, "problem")}; nothing was done.`);
    return 1;
  }
  let rows;
  let out;
  let base;
  let concurrency = sheet.plan.concurrency;
  try {
    rows = selectRows(sheet, { tiers: args.tiers, ids: args.ids });
    if (!rows.length) throw new UsageError("no sound matches --tier and --id");
    const chosen = new Set(rows.map((row) => row.id));
    const stray = args.forced.filter((id) => !chosen.has(id));
    if (stray.length) throw new UsageError(`--force-id ${stray.join(", ")} is not among the chosen sounds`);
    out = resolve(args.out);
    const why = outProblem(out);
    if (why) throw new UsageError(`refusing --out ${out}: ${why}. Generated audio must stay out of Git.`);
    if (args.concurrency !== undefined) {
      concurrency = Number(args.concurrency);
      if (!Number.isInteger(concurrency) || concurrency < 1 || concurrency > sheet.plan.concurrency) {
        throw new UsageError(`--concurrency must be from 1 to ${sheet.plan.concurrency} (the ${sheet.plan.name} plan's limit)`);
      }
    }
    base = apiBase();
  } catch (error) {
    if (!(error instanceof UsageError)) throw error;
    console.error(`${TOOL}: ${error.message}`);
    return 2;
  }
  if (args.mode === "process") {
    try {
      return postProcess({ sheet, out, rows });
    } catch (error) {
      console.error(`FAIL: ${error.message}`);
      return 1;
    }
  }
  const forced = new Set(args.forced);
  const surveyed = survey(out, sheet, rows, forced);
  printPlan(sheet, args.sheet, out, surveyed);
  const found = findApiKey();
  if (args.mode === "dry-run") {
    console.log(`Dry run: nothing was requested. ${found ? `An API key was found (${found.from}); add --generate` : "No ELEVENLABS_API_KEY in the environment or ~/.config/elevenlabs/.env; set one and add --generate"} to make what is still to make.`);
    return 0;
  }
  if (!found) {
    console.error(`FAIL: ${TOOL} --generate needs ELEVENLABS_API_KEY in the environment or in ~/.config/elevenlabs/.env; nothing was requested.`);
    return 1;
  }
  mkdirSync(out, { recursive: true });
  return generate({ sheet, out, surveyed, forced, key: found.key, base, concurrency });
}

if (process.argv[1] && import.meta.url === pathToFileURL(realpathSync(process.argv[1])).href) {
  process.exitCode = await main();
}
