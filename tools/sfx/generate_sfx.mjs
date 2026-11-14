#!/usr/bin/env node
// Makes the game's sound effects with ElevenLabs from the public prompt sheet,
// tools/sfx/prompts.json (workflow and reasoning: tools/sfx/README.md). Run it as
// tools/generate-sfx, which puts the devcontainer's node on PATH.
//
//   tools/generate-sfx --out DIR [--tier 1,2] [--id ID,...]   dry run: what would be made, at what cost
//   tools/generate-sfx --out DIR --generate [--force-id ID [--force-again]] [--concurrency N] [--tier ..] [--id ..]
//                                                             make the candidates not yet in DIR
//   tools/generate-sfx --out DIR --process [--tier ..] [--id ..]
//                                                             trim, loop, normalise and encode the kept takes
//
// Nothing is requested or charged without --generate. The audio stays private:
// ElevenLabs' terms forbid making output available as isolated audio files and
// this repository is public, so DIR must lie outside every Git work tree. A
// candidate already in DIR is never requested again; --force-id ID first moves
// that row's candidates into DIR/candidates/ID/replaced-<time>/, then makes a
// fresh set. So that a rerun cannot pay for a set twice, the same --force-id is
// refused until that set is complete, and once a complete set was made with the
// sheet's current prompt and settings it needs --force-again. One --generate run
// at a time holds DIR/.generate.lock. SIGTERM, SIGHUP or a first Ctrl-C stops
// new requests and saves the ones in flight; a second Ctrl-C quits at once. The
// API key (ELEVENLABS_API_KEY, from the environment or ~/.config/elevenlabs/.env)
// is never printed or logged.
//
//   DIR/candidates/<id>/<id>.cNN.<wav|mp3>  what ElevenLabs returned, one file a generation
//   DIR/candidates/<id>/.picks-before-force.json
//                                          the row's picks when --force-id set its candidates aside
//   DIR/generation-log.jsonl               a line a request: id, prompt, model, settings, status, credits, time, file
//   DIR/picks.json                         optional, by hand: {"<id>": [candidate numbers, in take order]}
//   DIR/audition-notes.json                optional, from the audition pages: each row's round-1 and round-2 verdicts
//   DIR/game/<group>/<name>_NN.ogg         the processed takes for the game (--process, needs ffmpeg)
//   DIR/game/sfx.json                      the manifest the game reads: each sound's gain and takes

import { spawnSync } from "node:child_process";
import { appendFileSync, existsSync, lstatSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, realpathSync, renameSync, rmSync, statSync, unlinkSync, writeFileSync } from "node:fs";
import { open, rename } from "node:fs/promises";
import { homedir } from "node:os";
import { basename, dirname, join, relative, resolve, sep } from "node:path";
import { setTimeout as delay } from "node:timers/promises";
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
// (0 to 1) and loop. The answer is the audio.
const API_BASE = "https://api.elevenlabs.io";
const API_PATH = "/v1/sound-generation";
// The servers that reference lists: production, US, and the EU, India and
// Singapore data-residency hosts. ELEVENLABS_API_BASE may choose one of them,
// or plain http on this machine's loopback (the offline check's stand-in); no
// other host ever receives the key.
const API_HOSTS = Object.freeze(["api.elevenlabs.io", "api.us.elevenlabs.io", "api.eu.residency.elevenlabs.io", "api.in.residency.elevenlabs.io", "api.sg.residency.elevenlabs.io"]);
const LOOPBACK_HOSTS = Object.freeze(["127.0.0.1", "localhost", "[::1]"]);
export const DURATION_RANGE = Object.freeze([0.5, 30]);
// "There is a maximum length of 450 characters for your prompt" (help centre).
export const PROMPT_MAX_CHARS = 450;
// Plans from smallest to largest, and the smallest plan each output format
// needs, from the same reference: "MP3 with 192kbps bitrate requires you to be
// subscribed to Creator tier or above"; "PCM and WAV formats with 44.1kHz
// sample rate requires you to be subscribed to Pro tier or above". Only MP3 and
// WAV are listed, because the post-processing reads audio files, not raw PCM.
// Loops must be MP3: the capabilities page offers WAV only "for non-looping effects".
export const PLANS = Object.freeze(["Free", "Starter", "Creator", "Pro", "Scale", "Business", "Enterprise"]);
const FORMAT_PLAN = Object.freeze({
  mp3_22050_32: "Free", mp3_24000_48: "Free", mp3_44100_32: "Free", mp3_44100_64: "Free", mp3_44100_96: "Free", mp3_44100_128: "Free", mp3_44100_192: "Creator",
  wav_8000: "Free", wav_16000: "Free", wav_22050: "Free", wav_24000: "Free", wav_32000: "Free", wav_44100: "Pro", wav_48000: "Free",
});
// Sound effects have their own concurrency per plan (6 on Creator); "Requests
// beyond the limit and its reduced-priority queue return 429"
// (https://elevenlabs.io/docs/changelog/2026/11/9). Only a 429 or 503, which
// mean the request was not processed, or a connection that never opened is
// tried again, after Retry-After or a doubling wait. Anything else stops the
// run, a 504 or an answer lost on the way included: that request may have been
// charged, so it is not silently repeated. Redirects are never followed, since
// the key would go with them.
const RETRY_STATUSES = new Set([429, 503]);
const MAX_ATTEMPTS = 8;
const BACKOFF_CAP_S = 30;
const RETRY_AFTER_CAP_S = 120;
const REQUEST_TIMEOUT_MS = 300_000;
const NOT_SENT_CODES = new Set(["ECONNREFUSED", "ENOTFOUND", "EAI_AGAIN", "UND_ERR_CONNECT_TIMEOUT"]);
// One --generate run at a time per output folder, and a forced set in progress.
const LOCK_NAME = ".generate.lock";
const FORCE_MARK = ".forced";
// The picks a row had when --force-id set its candidates aside. It outlives the
// fresh set, so --process can tell those picks from ones made of the new set.
const PICKS_BEFORE_FORCE = ".picks-before-force.json";
// The audition pages' verdicts beside picks.json (round 1, and round 2 under
// "round2"); a row they reject and nobody picked is left out of game/.
const NOTES_NAME = "audition-notes.json";
// Post-processing: silence kept before a one-shot's onset and after its tail;
// a take shorter than MIN_TAKE_S after trimming, or peaking at SILENT_DBFS or
// below, counts as silent.
const LEAD_KEEP_S = 0.003;
const TAIL_KEEP_S = 0.01;
const MIN_TAKE_S = 0.01;
const SILENT_DBFS = -70;
// How far an encoded take's decoded peak may sit above the recipe's, and how
// many encodings may be tried to bring it there.
const PEAK_OVER_DB = 0.3;
const PEAK_PASSES = 3;
// Takes of a row are loudness-matched: each louder than the row's quietest by
// more than MATCH_EPS_LU is turned down to it (which only lowers peaks), in up
// to MATCH_PASSES encodings. The manifest the game reads is DIR/game/sfx.json.
const MATCH_EPS_LU = 0.25;
const MATCH_PASSES = 2;
const MANIFEST_NAME = "sfx.json";
export const MANIFEST_SCHEMA = "ti.sfx-manifest/1";

const SHEET_FIELDS = ["car", "credits_per_second", "encode", "events", "loudness", "model_id", "not_voiced", "notes", "output_format", "plan", "recipes", "retired_outputs", "schema_version", "sounds"];
const ROW_FIELDS = ["candidates_per_take", "duration_seconds", "events", "id", "keep_takes", "level_db", "loop", "loudness_class", "notes", "output", "prompt", "prompt_influence", "recipe", "tier"];
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

const isObject = (value) => typeof value === "object" && value !== null && !Array.isArray(value);
const isNumber = (value) => typeof value === "number" && Number.isFinite(value);
const pad2 = (n) => String(n).padStart(2, "0");
const plural = (n, word) => `${n} ${word}${n === 1 ? "" : "s"}`;
const credits = (n) => Math.round(n).toLocaleString("en-US");
const shellWord = (word) => (/^[\w./,:=@+-]+$/u.test(word) ? word : `'${word.replaceAll("'", "'\\''")}'`);

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
  if (!isObject(plan) || !Number.isInteger(plan.credits_per_month) || plan.credits_per_month <= 0 || !Number.isInteger(plan.concurrency) || plan.concurrency < 1) {
    problem("plan must give name, credits_per_month and concurrency");
  }
  const planKnown = PLANS.includes(plan?.name);
  if (!planKnown) problem(`plan.name must be one of ${PLANS.join(", ")}`);
  for (const kind of ["one_shot", "loop"]) {
    const format = sheet.output_format?.[kind];
    const needs = typeof format === "string" && Object.hasOwn(FORMAT_PLAN, format) ? FORMAT_PLAN[format] : null;
    if (!needs) problem(`output_format.${kind} must be one of the API's MP3 or WAV formats: ${Object.keys(FORMAT_PLAN).join(", ")}`);
    else if (planKnown && PLANS.indexOf(needs) > PLANS.indexOf(plan.name)) problem(`output_format.${kind} ${format} needs the ${needs} plan or above; the sheet's plan is ${plan.name}`);
  }
  if (typeof sheet.output_format?.loop === "string" && !sheet.output_format.loop.startsWith("mp3_")) {
    problem("output_format.loop must be an MP3 format: ElevenLabs offers WAV only for effects that do not loop");
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
  // Loudness classes run from loudest to quietest without overlapping, so a
  // row's level inside its class keeps it below every louder class.
  const loudness = sheet.loudness;
  const classes = new Map();
  if (!isObject(loudness) || typeof loudness.measure !== "string" || !loudness.measure.trim() || !isNumber(loudness.within_row_spread_lu)
    || loudness.within_row_spread_lu <= 0 || !Array.isArray(loudness.classes) || !loudness.classes.length) {
    problem("loudness must give measure, within_row_spread_lu (above 0) and a list of classes");
  } else {
    let above = null;
    for (const [index, entry] of loudness.classes.entries()) {
      const label = `loudness class ${isObject(entry) && typeof entry.name === "string" ? entry.name : `#${index + 1}`}`;
      if (!isObject(entry) || typeof entry.name !== "string" || !ID_RE.test(entry.name) || typeof entry.what !== "string" || !entry.what.trim()
        || !isNumber(entry.max_db) || !isNumber(entry.min_db) || entry.min_db > entry.max_db || entry.max_db > 0) {
        problem(`${label} must give name, what, max_db and min_db (min_db at most max_db, max_db at most 0)`);
        continue;
      }
      if (classes.has(entry.name)) problem(`${label} is listed twice`);
      if (above && entry.max_db > above.min_db) {
        problem(`loudness classes must run from loudest to quietest without overlapping: ${entry.name} reaches ${entry.max_db}, above ${above.name}'s lowest, ${above.min_db}`);
      }
      classes.set(entry.name, entry);
      above = entry;
    }
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
    const loudClass = typeof row.loudness_class === "string" ? classes.get(row.loudness_class) : undefined;
    if (!loudClass) problem(`${label}: unknown loudness class ${row.loudness_class}`);
    if (!isNumber(row.level_db)) problem(`${label}: level_db must be a number, its playback loudness in LUFS`);
    else if (loudClass && (row.level_db > loudClass.max_db || row.level_db < loudClass.min_db)) {
      problem(`${label}: level_db ${row.level_db} lies outside its loudness class ${loudClass.name} (${loudClass.min_db} to ${loudClass.max_db}), against the classes' order`);
    }
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
  // The outputs of rows taken out of the sheet: --process removes their takes from game/.
  const retired = sheet.retired_outputs ?? {};
  if (!isObject(retired)) problem("retired_outputs must be an object (output pattern: which row it was and why it went)");
  for (const [output, why] of Object.entries(isObject(retired) ? retired : {})) {
    if (!OUTPUT_RE.test(output)) problem(`retired output ${output} must be like group/name_{take}.ogg`);
    else if (outputs.has(output)) problem(`retired output ${output} is still a sound's output`);
    if (typeof why !== "string" || !why.trim()) problem(`retired output ${output} needs a reason`);
  }
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
    // 0 keeps a loop as generated, for one the model already made seamless (chosen by ear).
    if (!isNumber(recipe.loop_crossfade_ms) || recipe.loop_crossfade_ms < 0) problems.push("loop_crossfade_ms must be 0 (keep the loop as generated) or more");
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
const forceMark = (out, row) => join(out, "candidates", row.id, FORCE_MARK);
const picksBeforeForce = (out, row) => join(out, "candidates", row.id, PICKS_BEFORE_FORCE);
const presentOf = (out, sheet, row) => Array.from({ length: generationsOf(row) }, (_, i) => i + 1).filter((n) => existsSync(candidateFile(out, sheet, row, n)));

// The rows a run works on, in sheet order. Unknown ids throw (a usage error).
export function selectRows(sheet, { tiers = [], ids = [] } = {}) {
  const known = new Set(sheet.sounds.map((row) => row.id));
  const unknown = ids.filter((id) => !known.has(id));
  if (unknown.length) throw new UsageError(`unknown sound id ${unknown.join(", ")}`);
  return sheet.sounds.filter((row) => (!tiers.length || tiers.includes(row.tier)) && (!ids.length || ids.includes(row.id)));
}

// --- Where the audio goes --------------------------------------------------

// Why OUT may not be used, or null. Fails closed: OUT passes only on git's
// exact answer for a folder in no repository; anything else is refused (git
// missing, a repository of dubious ownership, a .git file pointing nowhere,
// which git answers with "not a git repository: (null)").
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
  Object.assign(env, { LC_ALL: "C", LANGUAGE: "C", GIT_DISCOVERY_ACROSS_FILESYSTEM: "1" });
  const git = spawnSync("git", ["-C", realpathSync(probe), "rev-parse", "--is-inside-work-tree"], { encoding: "utf8", env });
  if (git.error) return `git could not run (${git.error.code ?? git.error.message}), so it cannot be checked that it lies outside every Git work tree`;
  if (git.status === 128 && /^fatal: not a git repository \(or any of the parent directories\): \.git$/mu.test(git.stderr)) return null;
  if (git.status === 0) return "it lies inside a Git repository";
  return `git could not tell whether it lies in a Git work tree (exit ${git.status}: ${git.stderr.trim().split("\n")[0]})`;
}

// --- The key and the server ------------------------------------------------

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

function apiBase(env = process.env) {
  const raw = env.ELEVENLABS_API_BASE?.trim();
  if (!raw) return API_BASE;
  const allowed = `${API_HOSTS.map((host) => `https://${host}`).join(", ")}, or http on this machine's loopback`;
  let url;
  try {
    url = new URL(raw);
  } catch {
    throw new UsageError(`ELEVENLABS_API_BASE is not a URL; it may be ${allowed}`);
  }
  const bare = !url.username && !url.password && url.pathname === "/" && !url.search && !url.hash;
  const official = url.protocol === "https:" && url.port === "" && API_HOSTS.includes(url.hostname);
  const loopback = url.protocol === "http:" && LOOPBACK_HOSTS.includes(url.hostname);
  if (!bare || !(official || loopback)) throw new UsageError(`ELEVENLABS_API_BASE may only be ${allowed} (with no path, port or user)`);
  return url.origin;
}

// --- The output folder's lock and forced sets --------------------------------

class LockError extends Error {}

// A process's start in clock ticks since boot (field 22 of Linux's
// /proc/<pid>/stat): fixed for the life of the process and untouched by changes
// to the wall clock, so a reused pid shows a different start. null without /proc.
function startTicks(pid) {
  try {
    const stat = readFileSync(`/proc/${pid}/stat`, "utf8");
    // Fields are counted after the ")" that ends the process name, which may hold spaces.
    const ticks = Number(stat.slice(stat.lastIndexOf(")") + 2).split(" ")[19]);
    return Number.isSafeInteger(ticks) ? ticks : null;
  } catch {
    return null;
  }
}

// Whether a running pid is the tools/generate-sfx run that took the lock:
// false when its command is something else or its start differs from the one
// the lock stored (the pid was reused); true when it fits; null where there is
// no /proc to tell (not Linux). A lock written without /proc stores no start,
// and then the command is all there is to go on.
function isLockOwner(pid, holder) {
  let command;
  try {
    command = readFileSync(`/proc/${pid}/cmdline`, "utf8").split("\0");
  } catch {
    return null;
  }
  if (!command.some((word) => word.endsWith("generate_sfx.mjs"))) return false;
  return Number.isSafeInteger(holder?.start_ticks) ? startTicks(pid) === holder.start_ticks : true;
}

// Takes DIR/.generate.lock (created exclusively, holding this pid and its start
// in clock ticks) or throws a LockError. A lock is never deleted here: one left
// by a run that has gone is reported, and whoever runs the tool deletes it.
function takeLock(out) {
  const path = join(out, LOCK_NAME);
  try {
    writeFileSync(path, `${JSON.stringify({ pid: process.pid, start_ticks: startTicks(process.pid), started: new Date().toISOString() })}\n`, { flag: "wx" });
    return path;
  } catch (error) {
    if (error.code !== "EEXIST") throw error;
  }
  let holder = null;
  try {
    holder = JSON.parse(readFileSync(path, "utf8"));
  } catch {
    // Unreadable or torn: reported below as a lock of unknown owner.
  }
  const pid = Number.isInteger(holder?.pid) && holder.pid > 0 ? holder.pid : null;
  let alive = false;
  if (pid !== null) {
    try {
      process.kill(pid, 0);
      alive = true;
    } catch (error) {
      alive = error.code === "EPERM";
    }
  }
  const owner = alive ? isLockOwner(pid, holder) : false;
  if (owner !== false) {
    throw new LockError(`another --generate run (pid ${pid}, started ${holder.started ?? "?"}) is using ${out}; wait for it to end. If pid ${pid} is not a tools/generate-sfx run using this folder, delete ${path} and run again`);
  }
  const why = pid === null ? "its owner cannot be read" : alive ? `pid ${pid} is now a different process` : `pid ${pid} has ended`;
  throw new LockError(`${path} is left from a run that is not running any more (${why}); if no run is using ${out}, delete that file and run again`);
}

function releaseLock(path) {
  try {
    if (JSON.parse(readFileSync(path, "utf8")).pid === process.pid) rmSync(path, { force: true });
  } catch {
    // Already gone, or not ours: leave it.
  }
}

// The same command without --force-id: it finishes a forced set without paying for it twice.
function resumeCommand(args, out) {
  const words = [TOOL, "--out", out, "--generate"];
  if (args.sheet !== SHEET_PATH) words.push("--sheet", args.sheet);
  if (args.tiers.length) words.push("--tier", args.tiers.join(","));
  if (args.ids.length) words.push("--id", args.ids.join(","));
  if (args.concurrency !== undefined) words.push("--concurrency", args.concurrency);
  return words.map(shellWord).join(" ");
}

// --- Dry run ---------------------------------------------------------------

// The generation log's "ok" lines by file: each candidate's own line is the
// last one naming its file, since a file made again after --force-id is logged
// after the one it replaced. A line records the prompt, settings and time.
function readLog(out) {
  const logged = new Map();
  const logPath = join(out, "generation-log.jsonl");
  if (!existsSync(logPath)) return logged;
  for (const line of readFileSync(logPath, "utf8").split("\n")) {
    try {
      const entry = JSON.parse(line);
      if (entry?.status === "ok" && typeof entry.file === "string") logged.set(entry.file, entry);
    } catch {
      // A torn last line from an interrupted run; the file it named is checked on disk.
    }
  }
  return logged;
}

// For each row: which candidates are on disk, which of them the generation log
// shows were made with other settings than the sheet's (stale), and whether the
// set is complete and logged as made entirely with the sheet's settings (current).
function survey(out, sheet, rows, forced) {
  const logged = readLog(out);
  return rows.map((row) => {
    const format = formatOf(sheet, row);
    const present = presentOf(out, sheet, row);
    const made = present.map((n) => logged.get(relative(out, candidateFile(out, sheet, row, n))));
    const matches = (entry) => entry.prompt === row.prompt && entry.model_id === sheet.model_id && entry.duration_seconds === row.duration_seconds
      && entry.loop === row.loop && entry.prompt_influence === row.prompt_influence && entry.output_format === format;
    const stale = present.filter((n, index) => made[index] && !matches(made[index]));
    const current = present.length === generationsOf(row) && made.every((entry) => entry && matches(entry));
    const toMake = forced.has(row.id) ? generationsOf(row) : generationsOf(row) - present.length;
    return { row, present, stale, current, toMake, toMakeCredits: Math.round(sheet.credits_per_second * row.duration_seconds * toMake) };
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
    if (!stale.length) continue;
    const names = stale.map((n) => `c${pad2(n)}`).join(", ");
    console.error(`NOTE: ${row.id}: ${names} ${stale.length === 1 ? "was" : "were"} made with other settings than the sheet's (the generation log has each one's prompt). They stay, and new candidates use the sheet's; --force-id ${row.id} would set the whole set aside for a fresh one.`);
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

const backoffSeconds = (attempt) => Math.round(Math.min(BACKOFF_CAP_S, 2 ** (attempt - 1)) * (1 + Math.random() * 0.25) * 10) / 10;

function retryAfterSeconds(header) {
  if (header === null) return null;
  const text = header.trim();
  if (/^\d+(?:\.\d+)?$/u.test(text)) return Math.min(RETRY_AFTER_CAP_S, Number(text));
  const when = Date.parse(text);
  return Number.isNaN(when) ? null : Math.min(RETRY_AFTER_CAP_S, Math.max(0, (when - Date.now()) / 1000));
}

// Moves every candidate file of a row into the folder aside (kept, never
// deleted), whatever its number or format, so a set made when the row had more
// candidates, or another output format, leaves no strays among the fresh set.
function moveAside(out, row, aside) {
  const folder = join(out, "candidates", row.id);
  const pattern = new RegExp(`^${row.id}\\.c\\d{2}\\.(?:wav|mp3)$`, "u");
  let moved = 0;
  for (const name of existsSync(folder) ? readdirSync(folder) : []) {
    if (!pattern.test(name)) continue;
    mkdirSync(aside, { recursive: true });
    renameSync(join(folder, name), join(aside, name));
    moved += 1;
  }
  if (moved) console.log(`moved ${plural(moved, "candidate")} of ${row.id} to ${relative(out, aside)}`);
}

// Before a forced row's candidates go aside: records the picks that named them,
// so --process can refuse those picks until they are made again from the fresh
// set. A row without picks has nothing to record, and an older record goes.
function recordPicksBeforeForce(out, row, picks, aside) {
  const path = picksBeforeForce(out, row);
  if (!Array.isArray(picks)) {
    rmSync(path, { force: true });
    return;
  }
  writeFileSync(path, `${JSON.stringify({ picks, set_aside_in: relative(out, aside), recorded: new Date().toISOString() })}\n`);
}

// The signals that stop a --generate run gently: no new requests, the ones in
// flight finish and are saved, the lock is released. A second Ctrl-C quits at once.
const STOP_SIGNALS = Object.freeze({ SIGHUP: 1, SIGINT: 2, SIGTERM: 15 });

class Interrupted extends Error {
  constructor(signal) {
    super(`stopped by ${signal}`);
    this.exitCode = 128 + STOP_SIGNALS[signal];
  }
}

// run: { stop, stopping, sending }, shared with main's signal handlers.
// picked: picks.json as read before the run, for the forced rows' records.
async function generate({ sheet, out, surveyed, forced, picked, key, base, concurrency, resume, run }) {
  const redact = (text) => String(text).split(key).join("[key]");
  const excerpt = (text) => redact(text).replace(/\s+/gu, " ").trim().slice(0, 400);
  const logPath = join(out, "generation-log.jsonl");
  const log = (entry) => appendFileSync(logPath, `${JSON.stringify(entry)}\n`);
  if (run.stop !== null) {
    console.error(`Stopped (${run.stop.message}) before any request; nothing was moved or made.`);
    return run.stop.exitCode;
  }
  // A forced row's picks are recorded before its set goes aside, and the set is
  // marked until it is complete, so the same --force-id cannot move it aside unfinished.
  const stamp = new Date().toISOString().replace(/[-:]/gu, "").replace(/\.\d+Z$/u, "Z");
  for (const { row } of surveyed) {
    if (!forced.has(row.id)) continue;
    const aside = join(out, "candidates", row.id, `replaced-${stamp}`);
    mkdirSync(join(out, "candidates", row.id), { recursive: true });
    recordPicksBeforeForce(out, row, picked[row.id], aside);
    writeFileSync(forceMark(out, row), `${JSON.stringify({ started: new Date().toISOString(), pid: process.pid })}\n`);
    moveAside(out, row, aside);
  }
  const unmarkComplete = () => {
    for (const { row } of surveyed) {
      if (existsSync(forceMark(out, row)) && presentOf(out, sheet, row).length === generationsOf(row)) rmSync(forceMark(out, row), { force: true });
    }
  };
  const tasks = [];
  for (const { row } of surveyed) {
    for (let n = 1; n <= generationsOf(row); n += 1) {
      const file = candidateFile(out, sheet, row, n);
      if (!existsSync(file)) tasks.push({ row, n, file, format: formatOf(sheet, row) });
    }
  }
  if (!tasks.length) {
    unmarkComplete();
    console.log(`Nothing to make: every candidate of the chosen sounds is already in ${out}.`);
    return 0;
  }
  const planned = tasks.reduce((sum, task) => sum + sheet.credits_per_second * task.row.duration_seconds, 0);
  console.log(`Making ${plural(tasks.length, "candidate")} for ${credits(planned)} credits, up to ${concurrency} at a time.`);

  let next = 0;
  let made = 0;
  let spent = 0;
  const halt = (error) => {
    if (run.stop !== null) return;
    run.stop = error;
    run.stopping.abort();
  };

  // One request for a candidate: returns { cost } when saved or { wait } to try
  // again; throws to stop the run. Every request leaves a line in the log.
  const attemptOnce = async ({ row, n, file, format }, attempt) => {
    const label = `${row.id} c${pad2(n)}`;
    const settings = { model_id: sheet.model_id, duration_seconds: row.duration_seconds, loop: row.loop, prompt_influence: row.prompt_influence, output_format: format };
    const record = (fields) => log({ time: new Date().toISOString(), id: row.id, candidate: n, attempt, file: relative(out, file), prompt: row.prompt, ...settings, ...fields });
    const url = `${base}${API_PATH}?output_format=${encodeURIComponent(format)}`;
    const body = JSON.stringify({ text: row.prompt, model_id: sheet.model_id, duration_seconds: row.duration_seconds, prompt_influence: row.prompt_influence, loop: row.loop });
    let response;
    try {
      response = await fetch(url, { method: "POST", redirect: "manual", headers: { "xi-api-key": key, "content-type": "application/json" }, body, signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS) });
    } catch (error) {
      // undici puts the system error code in cause; a timeout is a DOMException named TimeoutError.
      const code = String(error?.cause?.code ?? error?.name ?? "error");
      if (NOT_SENT_CODES.has(code) && attempt < MAX_ATTEMPTS) {
        const wait = backoffSeconds(attempt);
        record({ status: "retry", error: code, wait_seconds: wait });
        console.error(`NOTE: ${label}: could not connect (${code}); trying again in ${wait} s`);
        return { wait };
      }
      record({ status: "error", error: excerpt(`${code}: ${error?.message ?? ""}`) });
      throw new Error(`${label}: the request failed (${excerpt(code)}); if it reached ElevenLabs it may have been charged, so it is not repeated`);
    }
    const status = response.status;
    if (response.type === "opaqueredirect" || (status >= 300 && status < 400)) {
      const where = excerpt(response.headers.get("location") ?? "somewhere");
      record({ status: "error", http_status: status, error: `redirect to ${where}, not followed` });
      throw new Error(`${label}: HTTP ${status} redirect to ${where}; not followed, since the key would go with it`);
    }
    if (RETRY_STATUSES.has(status)) {
      const text = await response.text().catch(() => "");
      if (attempt < MAX_ATTEMPTS) {
        const wait = retryAfterSeconds(response.headers.get("retry-after")) ?? backoffSeconds(attempt);
        record({ status: "retry", http_status: status, error: excerpt(text), wait_seconds: wait });
        console.error(`NOTE: ${label}: HTTP ${status}${status === 429 ? " (more requests than the plan runs at once)" : ""}; trying again in ${wait} s`);
        return { wait };
      }
      record({ status: "error", http_status: status, error: excerpt(text) });
      throw new Error(`${label}: HTTP ${status} after ${attempt} attempts: ${excerpt(text)}`);
    }
    const type = response.headers.get("content-type") ?? "";
    if (!response.ok || /json|text/u.test(type)) {
      const text = await response.text().catch(() => "");
      record({ status: "error", http_status: status, error: excerpt(text) });
      const charged = status >= 500 ? "; it may have been charged, so it is not repeated" : "";
      throw new Error(`${label}: HTTP ${status}${response.ok ? ` but ${type} instead of audio` : ""}${charged}: ${excerpt(text)}`);
    }
    let bytes;
    try {
      bytes = Buffer.from(await response.arrayBuffer());
    } catch (error) {
      const why = excerpt(error?.cause?.code ?? error?.cause?.message ?? error?.message ?? String(error));
      record({ status: "error", http_status: status, error: `reading the answer failed: ${why}` });
      throw new Error(`${label}: the answer was lost while it was read (${why}); it may have been charged, so it is not repeated`);
    }
    if (!bytes.length) {
      record({ status: "error", http_status: status, error: "empty answer" });
      throw new Error(`${label}: HTTP ${status} with no audio`);
    }
    try {
      await writeAtomic(file, bytes);
    } catch (error) {
      record({ status: "error", http_status: status, error: excerpt(`writing ${relative(out, file)} failed: ${error?.code ?? error?.message}`) });
      throw new Error(`${label}: the audio was paid for but could not be saved (${error?.code ?? error?.message})`);
    }
    const cost = Math.round(sheet.credits_per_second * row.duration_seconds);
    record({ status: "ok", http_status: status, credits: cost });
    console.log(`made ${relative(out, file)} (${cost} credits)`);
    return { cost };
  };

  const makeOne = async (task) => {
    mkdirSync(dirname(task.file), { recursive: true });
    for (let attempt = 1; ; attempt += 1) {
      run.sending += 1;
      let result;
      try {
        result = await attemptOnce(task, attempt);
      } finally {
        run.sending -= 1;
      }
      if (result.cost !== undefined) return result.cost;
      // A wait before a retry ends early once the run stops, and the task with it.
      try {
        await delay(result.wait * 1000, undefined, { signal: run.stopping.signal });
      } catch {
        // Cut short by the stop.
      }
      if (run.stop !== null) throw new Error(`${task.row.id} c${pad2(task.n)}: not retried, the run had stopped`);
    }
  };

  const worker = async () => {
    while (run.stop === null && next < tasks.length) {
      const task = tasks[next];
      next += 1;
      try {
        // Add after the await: `spent += await ...` reads spent before awaiting,
        // and concurrent workers would then overwrite each other's credits.
        const cost = await makeOne(task);
        spent += cost;
        made += 1;
      } catch (error) {
        halt(error);
      }
    }
  };
  try {
    await Promise.all(Array.from({ length: Math.min(concurrency, tasks.length) }, worker));
  } finally {
    unmarkComplete();
  }
  const stop = run.stop;
  if (stop) {
    console.error(`${stop instanceof Interrupted ? "Stopped" : "FAIL"}: ${redact(stop.message)}`);
    console.error(`Made ${plural(made, "candidate")} (${credits(spent)} credits) before the stop; no request was started after it. To resume (candidates already made are kept and not requested again): ${resume}`);
    return stop instanceof Interrupted ? stop.exitCode : 1;
  }
  console.log(`Made ${plural(made, "candidate")} for ${credits(spent)} credits. Log: ${relative(process.cwd(), logPath) || logPath}`);
  console.log(`Next: listen, list the keepers in ${join(out, "picks.json")} (optional), then run ${TOOL} --out ${shellWord(out)} --process.`);
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
// astats prints no level for a stream with (next to) no samples: that is silence.
function peakDbfs(file, format = []) {
  const result = ffmpeg(["-v", "info", "-nostats", ...format, "-i", file, "-af", "astats=measure_perchannel=none:measure_overall=Peak_level", "-f", "null", "-"]);
  const matches = [...result.stderr.matchAll(/Peak level dB:\s*(-?(?:\d+(?:\.\d+)?|inf))/gu)];
  if (!matches.length) return -Infinity;
  const value = matches.at(-1)[1];
  return value.endsWith("inf") ? -Infinity : Number(value);
}

// A candidate with nothing, or next to nothing, left once its silence is trimmed.
class SilentTake extends Error {
  constructor() {
    super("silent after trimming; pick another take or regenerate");
  }
}

// Loudness in LUFS (ITU-R BS.1770, as ffmpeg's ebur128 measures it): a loop's
// integrated loudness, a one-shot's loudest momentary (400 ms) window. The
// sound is padded with silence so a short one-shot fits a whole window; the
// silence is gated out of the integrated figure.
function loudnessOf(file, loop, format = []) {
  const result = ffmpeg(["-v", "info", "-nostats", ...format, "-i", file, "-af", "apad=pad_dur=0.5,ebur128=framelog=info", "-f", "null", "-"]);
  if (loop) {
    const summary = result.stderr.slice(result.stderr.lastIndexOf("Summary:"));
    const match = summary.match(/I:\s+(-?\d+(?:\.\d+)?) LUFS/u);
    return match ? Number(match[1]) : -Infinity;
  }
  const values = [...result.stderr.matchAll(/\bM:\s*(-?\d+(?:\.\d+)?)/gu)].map((match) => Number(match[1]));
  return values.length ? Math.max(...values) : -Infinity;
}

// Encodes a shaped take to Ogg Vorbis at `gain` dB. Lossy coding overshoots the
// peak of bright transients (white noise by about 2.6 dB at quality 5), so the
// gain is lowered until the decoded peak is within PEAK_OVER_DB of the
// recipe's; returns the gain used.
function encodeTake(sheet, recipe, source, part, gain) {
  for (let pass = 1; ; pass += 1) {
    ffmpeg(["-v", "error", "-i", source, "-af", `volume=${gain.toFixed(2)}dB`, "-c:a", "libvorbis", "-q:a", String(sheet.encode.quality), "-ar", String(sheet.encode.sample_rate), "-f", "ogg", part]);
    const decoded = peakDbfs(part, ["-f", "ogg"]);
    if (decoded <= recipe.peak_dbfs + PEAK_OVER_DB) return gain;
    if (pass === PEAK_PASSES) throw new Error(`still peaks at ${decoded.toFixed(2)} dBFS after ${pass} encodings; the recipe asks ${recipe.peak_dbfs}`);
    gain -= decoded - recipe.peak_dbfs + 0.1;
  }
}

// One candidate through its recipe up to the encode: returns the shaped float
// WAV (stem.wav, or stem.loop.wav once crossfaded) and its length in samples.
function shapeTake(sheet, recipe, input, stem) {
  const rate = sheet.encode.sample_rate;
  const loop = Object.hasOwn(recipe, "loop_crossfade_ms");
  // The candidate's own peak as generated: at SILENT_DBFS or below it is silent.
  // Otherwise its peak is brought to full scale before anything is trimmed, so
  // the recipe's trim levels count down from the take's own peak and a quiet
  // take is trimmed like a loud one.
  const level = peakDbfs(input);
  if (!(level > SILENT_DBFS)) throw new SilentTake();
  const chain = [`aresample=${rate}`, "aformat=sample_fmts=flt", `volume=${(-level).toFixed(3)}dB`];
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
  const shaped = `${stem}.wav`;
  ffmpeg(["-v", "error", "-i", input, "-af", chain.join(","), "-ac", String(recipe.channels), "-c:a", "pcm_f32le", shaped]);
  let source = shaped;
  let samples = samplesOf(shaped);
  // A near-silent candidate trims to nothing or a few samples, which cannot even be measured.
  if (samples < MIN_TAKE_S * rate) throw new SilentTake();
  // A loop recipe with loop_crossfade_ms 0 keeps the generated loop as it is.
  const x = loop ? Math.round((recipe.loop_crossfade_ms / 1000) * rate) : 0;
  if (x > 0) {
    // Crossfade the last X samples into the first X (equal power): the take
    // becomes original[X .. L-X] followed by the blend of original[L-X .. L]
    // into original[0 .. X], so its end runs on into its start without a jump.
    if (samples < 4 * x) throw new Error(`only ${(samples / rate).toFixed(2)} s after trimming, too short for a ${recipe.loop_crossfade_ms} ms crossfade`);
    const looped = `${stem}.loop.wav`;
    ffmpeg(["-v", "error", "-i", shaped, "-filter_complex",
      `[0:a]asplit=2[a][b];[a]atrim=start_sample=${x},asetpts=PTS-STARTPTS[body];[b]atrim=end_sample=${x},asetpts=PTS-STARTPTS[head];[body][head]acrossfade=ns=${x}:c1=qsin:c2=qsin[out]`,
      "-map", "[out]", "-c:a", "pcm_f32le", looped]);
    source = looped;
    samples = samplesOf(looped);
  }
  const peak = peakDbfs(source);
  if (!(peak > SILENT_DBFS)) throw new SilentTake();
  return { source, samples, peak };
}

// A JSON object from DIR, or null when the file is not there. Anything else
// throws: the owner's choices in it cannot be read.
function readObject(path, shape) {
  if (!existsSync(path)) return null;
  let value;
  try {
    value = JSON.parse(readFileSync(path, "utf8"));
  } catch (error) {
    throw new Error(`${path} is not valid JSON: ${error.message}`);
  }
  if (!isObject(value)) throw new Error(`${path} must be an object: ${shape}`);
  return value;
}

// picks.json: { picks: valid lists by id, bad: why a row's list cannot be right }.
// An id not in the sheet (a row since dropped) is named and ignored.
function readPicks(out, sheet) {
  const path = join(out, "picks.json");
  const found = { picks: {}, bad: new Map() };
  const picks = readObject(path, "{\"<id>\": [candidate numbers]}") ?? {};
  const rows = new Map(sheet.sounds.map((row) => [row.id, row]));
  for (const [id, list] of Object.entries(picks)) {
    const row = rows.get(id);
    if (!row) {
      console.error(`NOTE: ${path} names ${id}, which is not in the sheet; ignored`);
      continue;
    }
    const valid = Array.isArray(list) && list.length >= 1 && list.length <= row.keep_takes && new Set(list).size === list.length
      && list.every((n) => Number.isInteger(n) && n >= 1 && n <= generationsOf(row));
    if (valid) found.picks[id] = list;
    else found.bad.set(id, `${path} must list 1 to ${row.keep_takes} different candidate numbers from 1 to ${generationsOf(row)} for it`);
  }
  return found;
}

// audition-notes.json as the audition pages write it (format in the README):
//   {"<id>": {"none_good": <bool>, "note": "...", "updated": "<time>",                     round 1
//             "round2": {"still_not_right": <bool>, "note": "...", "updated": "<time>"}}}   round 2
// Returns the notes by id, and when the owner first saved any of them (ms, or
// null when nothing is dated). A set made before then was there to be judged.
function readNotes(out) {
  const notes = readObject(join(out, NOTES_NAME), "{\"<id>\": {\"none_good\": true, ...}}") ?? {};
  const saved = Object.values(notes).flatMap((entry) => [entry?.updated, entry?.round2?.updated]).map((time) => Date.parse(time)).filter(Number.isFinite);
  return { notes, auditionStart: saved.length ? Math.min(...saved) : null };
}

// The verdict that decides a row: round 2's when the row has one, otherwise
// round 1's; null when it has neither. { round, rejected, at (ms, or NaN) }.
function verdictOf(entry) {
  if (isObject(entry?.round2)) return { round: 2, rejected: entry.round2.still_not_right === true, at: Date.parse(entry.round2.updated) };
  if (isObject(entry) && typeof entry.none_good === "boolean") return { round: 1, rejected: entry.none_good, at: Date.parse(entry.updated) };
  return null;
}

// When a row's current candidates were made: the latest time the generation
// log records for them (ms), or null when one of them is not in the log.
function madeOf(out, sheet, row, present, logged) {
  const times = present.map((n) => Date.parse(logged.get(relative(out, candidateFile(out, sheet, row, n)))?.time));
  return times.length && times.every(Number.isFinite) ? Math.max(...times) : null;
}

// Why the first candidates of a row nobody picked or rejected must stay out of
// game/, or null when they may go in. They are unheard when the set was made,
// or added to, after the audition began and no verdict on the row was saved
// since. Before any dated verdict (no audition yet), the first candidates go in.
function unheardWhy(verdict, made, auditionStart) {
  if (auditionStart === null) return null;
  if (made === null) return "unheard: the generation log does not date its candidates";
  if (Number.isFinite(verdict?.at) && verdict.at >= made) return null;
  if (made < auditionStart) return null;
  return "unheard: its candidates were made after the audition began, and nobody has picked or judged them since";
}

// What --force-id recorded for a row: { picks } or null; { broken } when unreadable.
function picksBeforeForceOf(out, row) {
  const path = picksBeforeForce(out, row);
  if (!existsSync(path)) return null;
  try {
    const record = JSON.parse(readFileSync(path, "utf8"));
    if (Array.isArray(record?.picks)) return record;
  } catch {
    // Reported as unreadable below.
  }
  return { broken: true };
}

// Removes the takes of one output pattern (game/<group>/<name>_NN.ogg) numbered
// above keep, all of them for 0: files only, in a real folder of game/.
// Returns their paths relative to DIR.
function removeTakes(out, output, keep) {
  const [, group, name] = output.match(OUTPUT_RE);
  const folder = join(out, "game", group);
  if (!existsSync(folder) || !lstatSync(folder).isDirectory()) return [];
  const pattern = new RegExp(`^${name}_(\\d{2})\\.ogg$`, "u");
  const removed = [];
  for (const file of readdirSync(folder, { withFileTypes: true })) {
    const match = file.name.match(pattern);
    if (!file.isFile() || !match || Number(match[1]) <= keep) continue;
    unlinkSync(join(folder, file.name));
    removed.push(relative(out, join(folder, file.name)));
  }
  return removed.sort();
}

function postProcess({ sheet, out, rows }) {
  for (const tool of ["ffmpeg", "ffprobe"]) {
    const probe = spawnSync(tool, ["-version"], { encoding: "utf8" });
    if (probe.error || probe.status !== 0) {
      console.error(`FAIL: ${tool} is not on PATH; --process needs ffmpeg and ffprobe (.devcontainer/post-create.sh installs them).`);
      return 1;
    }
  }
  if (!existsSync(join(out, "candidates"))) {
    console.error(`FAIL: no candidates in ${out}; run ${TOOL} --out ${shellWord(out)} --generate first.`);
    return 1;
  }
  const { picks, bad: badPicks } = readPicks(out, sheet);
  const { notes, auditionStart } = readNotes(out);
  const logged = readLog(out);
  const work = mkdtempSync(join(out, ".work-"));
  // A take that fails is reported with its candidate, and the other rows still
  // go on; the failed rows are listed at the end. A failed row (refused before
  // processing, or with a take that failed), a skipped row and every row
  // outside the run keep their takes in game/ and their entry in game/sfx.json,
  // if any, as they were.
  // A row with picks gets exactly the picked takes, fewer than keep_takes if
  // so picked: unpicked candidates never fill the gap.
  const failedRows = [];
  const entries = {};
  const leftOut = [];
  const unpicked = [];
  let skipped = 0;
  let takes = 0;
  // A row left out of game/: its takes go, and so does its manifest entry.
  const leaveOut = (row, why) => {
    const gone = removeTakes(out, row.output, 0);
    entries[row.id] = null;
    leftOut.push({ id: row.id, why });
    console.log(`${row.id}: left out of game/ and ${MANIFEST_NAME}, ${why}${gone.length ? `; removed ${gone.join(", ")}` : ""}`);
  };
  try {
    for (const row of rows) {
      const recipe = sheet.recipes[row.recipe];
      const present = presentOf(out, sheet, row);
      if (badPicks.has(row.id)) {
        console.error(`FAIL: ${row.id}: ${badPicks.get(row.id)}`);
        failedRows.push(`${row.id} (its picks in picks.json)`);
        continue;
      }
      let chosen = picks[row.id];
      if (chosen) {
        // A pick overrides a not-good mark: both audition pages clear a row's
        // picks when they mark it, so a pick still there was saved after the mark.
        // Picks made only of numbers the row had picked when --force-id set its
        // candidates aside were picks of that set: those numbers now name new,
        // unheard candidates.
        const before = picksBeforeForceOf(out, row);
        const record = relative(out, picksBeforeForce(out, row));
        if (before?.broken) {
          console.error(`FAIL: ${row.id}: ${record} cannot be read, so it is unknown whether picks.json's picks for it were made from its current candidates. Once they are, delete ${record}.`);
          failedRows.push(`${row.id} (${record} unreadable)`);
          continue;
        }
        if (before && chosen.every((n) => before.picks.includes(n))) {
          const names = (list) => list.map((n) => `c${pad2(n)}`).join(", ");
          console.error(`FAIL: ${row.id}: picks.json picks ${names(chosen)}, only numbers it had picked before --force-id set that set aside (${names(before.picks)}, now in ${before.set_aside_in}); the candidates with those numbers now are new and unheard. Listen to them and update ${row.id} in picks.json. If these numbers are right in the new set too, delete ${record}, which is the only way past this check.`);
          failedRows.push(`${row.id} (picks made before --force-id)`);
          continue;
        }
        const missing = chosen.filter((n) => !present.includes(n));
        if (missing.length) {
          console.error(`FAIL: ${row.id}: picked candidates ${missing.join(", ")} are not on disk`);
          failedRows.push(`${row.id} (picked ${missing.map((n) => `c${pad2(n)}`).join(", ")} not on disk)`);
          continue;
        }
      } else {
        // Nobody picked: the deciding verdict may reject the row; otherwise its
        // first candidates go in, unless nobody has heard them.
        const verdict = verdictOf(notes[row.id]);
        if (verdict?.rejected) {
          leaveOut(row, `marked not good in round ${verdict.round}`);
          continue;
        }
        if (present.length < row.keep_takes) {
          console.error(`NOTE: ${row.id}: skipped, ${present.length} of the ${row.keep_takes} takes it keeps are on disk and picks.json names none; run --generate first`);
          skipped += 1;
          continue;
        }
        const unheard = unheardWhy(verdict, madeOf(out, sheet, row, present, logged), auditionStart);
        if (unheard) {
          leaveOut(row, unheard);
          continue;
        }
        chosen = present.slice(0, row.keep_takes);
      }
      const [, group, name] = row.output.match(OUTPUT_RE);
      const folder = join(out, "game", group);
      mkdirSync(folder, { recursive: true });
      const bad = [];
      const made = [];
      chosen.forEach((n, index) => {
        const output = join(folder, `${name}_${pad2(index + 1)}.ogg`);
        const stem = join(work, `${row.id}_${pad2(index + 1)}`);
        try {
          const { source, samples, peak } = shapeTake(sheet, recipe, candidateFile(out, sheet, row, n), stem);
          const part = `${stem}.ogg`;
          const gain = encodeTake(sheet, recipe, source, part, recipe.peak_dbfs - peak);
          made.push({ n, output, source, part, gain, seconds: samples / sheet.encode.sample_rate, loudness: loudnessOf(part, row.loop, ["-f", "ogg"]) });
        } catch (error) {
          console.error(`FAIL: ${row.id} c${pad2(n)}: ${error.message}`);
          bad.push(`c${pad2(n)}`);
        }
      });
      // A row is replaced whole or not at all: with a take failed, its takes in
      // game/ and its manifest entry stay as they were, and none made now is used.
      if (bad.length) {
        console.error(`FAIL: ${row.id}: left as it was in game/ and ${MANIFEST_NAME}; ${made.length ? `its ${plural(made.length, "other take")} made now ${made.length === 1 ? "is" : "are"} not used` : "no take of it was made"}`);
        failedRows.push(`${row.id} (${bad.join(", ")})`);
        continue;
      }
      // Loudness-match the row's takes, so a randomly chosen take never jumps in
      // level: each louder than the quietest by more than MATCH_EPS_LU is turned
      // down to it, which only lowers its peak.
      for (let pass = 1; pass <= MATCH_PASSES && made.length > 1; pass += 1) {
        const quietest = Math.min(...made.map((take) => take.loudness));
        const louder = made.filter((take) => take.loudness - quietest > MATCH_EPS_LU);
        if (!louder.length) break;
        for (const take of louder) {
          // Encoded beside the take, which is replaced only once the new one is measured.
          const trial = `${take.part}.match`;
          try {
            const gain = encodeTake(sheet, recipe, take.source, trial, take.gain - (take.loudness - quietest));
            const loudness = loudnessOf(trial, row.loop, ["-f", "ogg"]);
            renameSync(trial, take.part);
            Object.assign(take, { gain, loudness });
          } catch (error) {
            rmSync(trial, { force: true });
            console.error(`NOTE: ${row.id} c${pad2(take.n)}: kept at ${take.loudness.toFixed(1)} LUFS, its matching encode failed: ${error.message}`);
          }
        }
      }
      for (const take of made) {
        renameSync(take.part, take.output);
        console.log(`${relative(out, take.output)}  ${take.seconds.toFixed(2)} s ${recipe.channels === 1 ? "mono" : "stereo"}${row.loop ? " loop" : ""}  from c${pad2(take.n)}${picks[row.id] ? "" : " (first on disk, nobody picked)"}  ${take.loudness.toFixed(1)} LUFS`);
        takes += 1;
      }
      // The row keeps only the takes made now: higher numbers (an earlier run's,
      // when it kept more) go.
      for (const path of removeTakes(out, row.output, chosen.length)) console.log(`removed ${path}: ${row.id} keeps ${plural(chosen.length, "take")} now`);
      entries[row.id] = manifestEntry(sheet, row, recipe, made, join(out, "game"), Boolean(picks[row.id]));
      if (!picks[row.id]) unpicked.push(row.id);
    }
  } finally {
    rmSync(work, { recursive: true, force: true });
  }
  writeManifest(out, sheet, entries);
  // Rows taken out of the sheet: their takes go, whatever the run's selection.
  for (const [output, why] of Object.entries(sheet.retired_outputs ?? {})) {
    for (const path of removeTakes(out, output, 0)) console.log(`removed ${path}: a retired output (${why})`);
  }
  console.log(`Processed ${plural(takes, "take")} into ${join(out, "game")}; ${failedRows.length} ${failedRows.length === 1 ? "row" : "rows"} failed, ${skipped} skipped, ${leftOut.length} left out. Levels: ${join(out, "game", MANIFEST_NAME)}`);
  if (unpicked.length) console.log(`NOTE: processed from first candidates nobody picked: ${unpicked.join(", ")} ("picked": false in ${MANIFEST_NAME})`);
  if (leftOut.length) console.log(`NOTE: left out of game/, so the game plays nothing for them: ${leftOut.map(({ id, why }) => `${id} (${why})`).join("; ")}`);
  if (failedRows.length) console.error(`FAIL: failed rows: ${failedRows.join("; ")}`);
  return failedRows.length || skipped ? 1 : 0;
}

// --- The manifest the game reads ---------------------------------------------

const MANIFEST_NOTES = Object.freeze([
  "Written by tools/generate-sfx --process from tools/sfx/prompts.json; the format is in tools/sfx/README.md. One entry a sound id.",
  "gain_db: the playback gain in dB for every take of the sound (Godot: volume_db), never above 0. It plays the takes at level_db, the row's planned loudness in LUFS: a one-shot's loudest momentary (400 ms) window, a loop's integrated loudness. In-engine modulation (impact strength, speed, distance) comes on top and should only lower it.",
  "loudness_lufs is the processed takes' measured loudness (the loudest take). A sound's takes are loudness-matched to within spread_lu. When shortfall_db is above 0, the takes cannot reach level_db within their peak ceiling, so the sound plays that much below its planned level.",
  "picked: true when the owner picked the takes; false when they are the first candidates, which nobody picked.",
]);

const round2 = (value) => Math.round(value * 100) / 100;

// A row's manifest entry: its gain to its level from its loudest matched take,
// and whether its takes were picked or are first candidates nobody picked.
function manifestEntry(sheet, row, recipe, made, gameDir, picked) {
  const loudest = Math.max(...made.map((take) => take.loudness));
  const spread = loudest - Math.min(...made.map((take) => take.loudness));
  const gain = Math.min(0, row.level_db - loudest);
  const shortfall = Math.max(0, row.level_db - loudest);
  console.log(`${row.id}: ${plural(made.length, "take")} at ${loudest.toFixed(1)} LUFS (spread ${spread.toFixed(1)} LU); level ${row.level_db}, gain ${gain.toFixed(1)} dB`);
  if (spread > sheet.loudness.within_row_spread_lu) console.error(`NOTE: ${row.id}: its takes still differ by ${spread.toFixed(1)} LU, more than ${sheet.loudness.within_row_spread_lu}`);
  if (shortfall > 0) console.error(`NOTE: ${row.id}: its takes reach only ${loudest.toFixed(1)} LUFS at their peak ceiling, ${shortfall.toFixed(1)} dB short of its level ${row.level_db}; too quiet or too dynamic to reach it cleanly`);
  return {
    gain_db: round2(gain),
    level_db: row.level_db,
    loudness_class: row.loudness_class,
    loudness_lufs: round2(loudest),
    spread_lu: round2(spread),
    shortfall_db: round2(shortfall),
    loop: row.loop,
    channels: recipe.channels,
    picked,
    takes: made.map((take) => relative(gameDir, take.output)),
  };
}

// Updates DIR/game/sfx.json: entries for the rows just processed replace their
// old ones (null drops one), rows no longer in the sheet go, the rest stay.
function writeManifest(out, sheet, entries) {
  const path = join(out, "game", MANIFEST_NAME);
  let sounds = {};
  try {
    const old = JSON.parse(readFileSync(path, "utf8"));
    if (old?.schema_version === MANIFEST_SCHEMA && isObject(old.sounds)) sounds = old.sounds;
  } catch {
    // None yet, or unreadable: written afresh.
  }
  for (const [id, entry] of Object.entries(entries)) {
    if (entry === null) delete sounds[id];
    else sounds[id] = entry;
  }
  const ids = new Set(sheet.sounds.map((row) => row.id));
  const kept = Object.fromEntries(Object.entries(sounds).filter(([id]) => ids.has(id)).sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0)));
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(`${path}.part`, `${JSON.stringify({ schema_version: MANIFEST_SCHEMA, notes: MANIFEST_NOTES, sounds: kept }, null, 2)}\n`);
  renameSync(`${path}.part`, path);
}

// --- Command line ----------------------------------------------------------

export class UsageError extends Error {}

const USAGE = `usage: ${TOOL} --out DIR [--tier 1,2,3] [--id ID,...] [--sheet PATH]
         dry run (the default): prints each sound's credits and what is still to make; requests nothing
       ${TOOL} --out DIR --generate [--force-id ID]... [--force-again] [--concurrency N] [--tier ..] [--id ..]
         makes the candidates not yet in DIR (needs ELEVENLABS_API_KEY, from the environment or ~/.config/elevenlabs/.env);
         --force-id makes a fresh set of a sound, and --force-again lets it replace a complete set the sheet's current settings made
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
        "force-again": { type: "boolean" },
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
  if (values["force-again"] && !values["force-id"]) throw new UsageError("--force-again goes with --force-id");
  if (values.concurrency !== undefined && !values.generate) throw new UsageError("--concurrency goes with --generate");
  if (!values.help && !values.out) throw new UsageError("--out DIR is required");
  return {
    help: Boolean(values.help),
    out: values.out,
    sheet: values.sheet ? resolve(values.sheet) : SHEET_PATH,
    tiers,
    ids: list(values.id),
    forced: list(values["force-id"]),
    forceAgain: Boolean(values["force-again"]),
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
  for (const { row, present, current } of surveyed) {
    if (!forced.has(row.id)) continue;
    if (existsSync(forceMark(out, row)) && present.length < generationsOf(row)) {
      console.error(`${TOOL}: --force-id ${row.id} again would move aside its unfinished forced set (${present.length} of ${generationsOf(row)} candidates made) and pay for it twice. Finish it without --force-id: ${resumeCommand(args, out)}`);
      console.error(`To throw that set away and force a fresh one anyway, delete ${forceMark(out, row)} first.`);
      return 2;
    }
    // A complete set that the sheet's current prompt and settings made would only be bought again.
    if (current && !args.forceAgain) {
      console.error(`${TOOL}: all ${generationsOf(row)} candidates of ${row.id} are made, and the generation log shows each was made with the sheet's current prompt and settings, so --force-id ${row.id} would pay for the same set again. To make a fresh set anyway, add --force-again.`);
      return 2;
    }
  }
  // A forced row's picks are recorded before its set goes aside: afterwards they
  // would name the fresh set, which nobody has heard yet.
  let picked = {};
  if (forced.size) {
    try {
      picked = readObject(join(out, "picks.json"), "{\"<id>\": [candidate numbers]}") ?? {};
    } catch (error) {
      console.error(`${TOOL}: ${error.message}. --force-id records a forced sound's picks from it, so fix it first; nothing was done.`);
      return 2;
    }
  }
  for (const id of forced) {
    if (!Array.isArray(picked[id])) continue;
    console.error(`NOTE: picks.json picks ${id} ${picked[id].map((n) => `c${pad2(n)}`).join(", ")}. --force-id moves those candidates aside (kept in candidates/${id}/replaced-<time>/) and records these picks, so --process refuses ${id} until picks.json picks from the fresh set.`);
  }
  if (base !== API_BASE) console.log(`Requests go to ${base} (ELEVENLABS_API_BASE), not ${API_BASE}.`);
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
  // The stop signals are caught before the lock is taken, so none can leave it behind:
  // SIGHUP, SIGTERM and a first Ctrl-C stop new requests, let the ones in flight
  // finish and be saved, and release the lock; a second Ctrl-C quits at once.
  const run = { stop: null, stopping: new AbortController(), sending: 0 };
  let lock = null;
  const release = () => {
    if (lock) releaseLock(lock);
  };
  const onSignal = (signal) => {
    if (run.stop === null) {
      run.stop = new Interrupted(signal);
      run.stopping.abort();
      console.error(`NOTE: ${signal}: stopping; no new requests, and ${plural(run.sending, "request")} in flight will finish and be saved.${signal === "SIGINT" ? " Ctrl-C again quits at once and loses them." : ""}`);
    } else if (signal !== "SIGINT") {
      console.error(`NOTE: ${signal}: already stopping; waiting for ${plural(run.sending, "request")} in flight.`);
    } else {
      console.error("Quit at once; requests in flight were not saved (they may have been charged).");
      process.exit(130);
    }
  };
  const handlers = Object.keys(STOP_SIGNALS).map((signal) => [signal, () => onSignal(signal)]);
  for (const [signal, handler] of handlers) process.on(signal, handler);
  process.on("exit", release);
  try {
    try {
      lock = takeLock(out);
    } catch (error) {
      if (!(error instanceof LockError)) throw error;
      console.error(`FAIL: ${error.message}; nothing was requested.`);
      return 1;
    }
    return await generate({ sheet, out, surveyed, forced, picked, key: found.key, base, concurrency, resume: resumeCommand(args, out), run });
  } finally {
    for (const [signal, handler] of handlers) process.off(signal, handler);
    process.off("exit", release);
    release();
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(realpathSync(process.argv[1])).href) {
  // Output that cannot be written (a closed pipe or terminal) is dropped for the
  // rest of the process: a late console line must neither crash a run that is
  // saving paid audio nor change the exit code, which reports the run.
  for (const stream of [process.stdout, process.stderr]) stream.on("error", () => {});
  process.exitCode = await main();
}
