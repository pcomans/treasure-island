#!/usr/bin/env node
// Fills the game's sound folder, game/resources/audio/sfx/, with the processed
// takes of the sounds the game plays and their manifest. Run it as
// tools/fetch-sfx, which puts the devcontainer's node on PATH.
//
//   tools/fetch-sfx                           from TI_SFX_SOURCE; with none it does nothing
//   tools/fetch-sfx --source DIR              the game folder tools/generate-sfx --process
//                                             writes (DIR/game: sfx.json and <group>/<name>_NN.ogg)
//   tools/fetch-sfx --source URL [--ref REF] [--subdir PATH]
//                                             a Git repository holding that folder (at PATH)
//   tools/fetch-sfx --project DIR             fill another checkout's folder (tools/build-web.sh's copy)
//   tools/fetch-sfx --dry-run                 print what would change and change nothing
//   tools/fetch-sfx --require-all             refuse (exit 3), changing nothing, unless there is a source
//                                             and it gives every sound the game plays its takes
//   tools/fetch-sfx --result FILE             also write the outcome to FILE as JSON (below)
//
// Exit status: 0 done; 1 the fetch failed (a source that cannot be read or cloned,
// a refused folder); 2 a usage error; 3 --require-all refused: there is no source,
// or a sound the game plays has no takes in it (each is named on a "silent:" line).
// Builds for players use --require-all (tools/deploy-web.sh, and tools/build-mac.sh
// when a source is set), so a source that lacks a sound stops them instead of
// shipping it silent; a developer's build without the flag stays silent where takes
// are missing.
//
// --result FILE (written whenever the run reaches an outcome, exit 0 or 3, and
// removed first so a failed run leaves none) is for scripts: {schema_version:
// "ti.sfx-fetch-result/1", source (the folder, or the URL with any user or password
// taken out; null with no source), ref, subdir, commit (the full commit of a Git
// source, else null), dry_run, sounds (how many sound ids the catalog has; null with
// no source), sounds_with_takes, takes (how many takes the run fetched, or would
// have; with no source, how many the folder holds), silent ([{id, why}]), complete
// (true only when there is a source and every sound has takes)}.
//
// The audio is generated with ElevenLabs, whose terms forbid making it available
// as isolated audio files, and this repository is public (owner, 2026-11-14), so
// the folder is ignored by Git (.gitignore) and filled at build time from a
// private source. The game plays what the folder holds and treats a sound with no
// takes as silence, so a checkout or build without a source works, silently.
//
// Which sounds: every id in the game's catalog, game/resources/audio/sounds.json,
// taken from the prompt sheet row its "row" names (the id itself when it names
// none). The source's manifest, sfx.json (tools/sfx/README.md "Levels"), lists
// each row's takes, its playback gain (gain_db) and whether it loops; every take
// it lists is copied, as game/resources/audio/sfx/<id>_<NN>.ogg, and the folder's
// own sfx.json keeps the source's entry for each id with its takes renamed so.
// A source without sfx.json (processed before the level plan) gives its takes by
// the sheet's output patterns (<group>/<name>_{take}.ogg) and no gains: every
// sound then plays at 0 dB. Takes of rows the game does not play are left out.
//
// Safe to repeat: a take whose bytes are unchanged is left as it is (so Godot does
// not import it again), and only takes and their .import files that the source no
// longer holds are removed. Nothing outside the folder is written or removed, and
// the folder's own files (README.md) are never touched.
//
// Environment: TI_SFX_SOURCE (a folder or a Git URL), TI_SFX_SUBDIR (the game
// folder inside a Git source), TI_SFX_REF (a branch or tag to clone) and
// TI_SFX_GIT_TOKEN (an HTTPS token for a private repository, handed to git in
// its environment as an Authorization header, never on a command line and never
// printed). Otherwise git's own credential setup applies.

import { spawnSync } from "node:child_process";
import { existsSync, lstatSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, realpathSync, renameSync, rmSync, statSync, unlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, relative, resolve, sep } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { parseArgs } from "node:util";

const TOOL = "tools/fetch-sfx";
export const REPO_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");
export const CATALOG = "game/resources/audio/sounds.json";
export const SHEET = "tools/sfx/prompts.json";
export const TARGET = "game/resources/audio/sfx";
// The manifest's name and schema, in the source and in the folder alike.
export const MANIFEST = "sfx.json";
export const MANIFEST_SCHEMA = "ti.sfx-manifest/1";
// The --result file's schema.
export const RESULT_SCHEMA = "ti.sfx-fetch-result/1";
// The exit status of a run --require-all refuses.
export const EXIT_INCOMPLETE = 3;
// A sheet row's output pattern (tools/sfx/generate_sfx.mjs OUTPUT_RE).
const OUTPUT_RE = /^([a-z]+)\/([a-z0-9_]+)_\{take\}\.ogg$/u;
const ID_RE = /^[a-z0-9_]+$/u;
// A take's path in a source manifest: group folders and a file, nothing else.
const SOURCE_TAKE_RE = /^(?:[a-z0-9_]+\/)*[a-z0-9_]+\.ogg$/u;
// What this tool writes in the folder: takes, their Godot import files, and the
// unfinished copies of either a stopped run may leave.
const TAKE_RE = /^[a-z0-9_]+_[0-9]{2,}\.ogg$/u;
const IMPORT_RE = /^[a-z0-9_]+_[0-9]{2,}\.ogg\.import$/u;
const PART_RE = /^(?:[a-z0-9_]+_[0-9]{2,}\.ogg|sfx\.json)\.part$/u;
const GIT_URL_RE = /^(?:https?:\/\/|ssh:\/\/|git:\/\/|file:\/\/|git@[^:]+:)/u;

class FetchError extends Error {}

// The playback gain (dB) a source manifest entry gives its sound, or null for
// none (the game then plays it at 0 dB). The one place a source's gain is read:
// tools/sfx/README.md "Levels", gain_db.
export function entryGainDb(entry) {
  const gain = entry?.gain_db;
  return typeof gain === "number" && Number.isFinite(gain) ? gain : null;
}

// The game's sound ids and the sheet row each is taken from: [[id, row id], ...].
export function catalogRows(catalog) {
  const sounds = catalog?.sounds;
  if (!sounds || typeof sounds !== "object" || Array.isArray(sounds)) throw new FetchError(`${CATALOG} has no "sounds" object`);
  const rows = [];
  for (const [id, entry] of Object.entries(sounds).sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0))) {
    if (!ID_RE.test(id)) throw new FetchError(`${CATALOG}: "${id}" is not a lower_snake_case id`);
    const row = entry?.row ?? id;
    if (typeof row !== "string" || !ID_RE.test(row)) throw new FetchError(`${CATALOG}: ${id}'s row "${row}" is not a lower_snake_case id`);
    rows.push([id, row]);
  }
  return rows;
}

// The source's own manifest (sfx.json), or null where it has none.
export function readSourceManifest(sourceDir) {
  const path = join(sourceDir, MANIFEST);
  if (!existsSync(path)) return null;
  let manifest;
  try {
    manifest = JSON.parse(readFileSync(path, "utf8"));
  } catch (error) {
    throw new FetchError(`the source's ${MANIFEST} does not read: ${error.message}`);
  }
  if (manifest?.schema_version !== MANIFEST_SCHEMA || !manifest.sounds || typeof manifest.sounds !== "object") {
    throw new FetchError(`the source's ${MANIFEST} is not a ${MANIFEST_SCHEMA} manifest`);
  }
  return manifest;
}

// A row's takes in the source: [path relative to the source], in take order.
function rowTakes(row, entry, sourceDir) {
  if (entry) {
    const listed = Array.isArray(entry.takes) ? entry.takes : [];
    return listed.filter((take) => typeof take === "string" && SOURCE_TAKE_RE.test(take) && isFile(join(sourceDir, take)));
  }
  const output = typeof row?.output === "string" ? row.output.match(OUTPUT_RE) : null;
  if (!output) return [];
  const [, group, name] = output;
  const folder = join(sourceDir, group);
  const takeRe = new RegExp(`^${name}_([0-9]{2,})\\.ogg$`, "u");
  const found = [];
  if (existsSync(folder) && statSync(folder).isDirectory()) {
    for (const file of readdirSync(folder)) {
      const match = file.match(takeRe);
      if (match && isFile(join(folder, file))) found.push([Number(match[1]), `${group}/${file}`]);
    }
  }
  return found.sort((a, b) => a[0] - b[0]).map(([, path]) => path);
}

function isFile(path) {
  try {
    return statSync(path).isFile();
  } catch {
    return false;
  }
}

// What the folder should hold: {files: [{id, name, from}], sounds: {id: entry}, silent: [[id, why]], gains}.
export function plan(catalog, sheet, sourceDir) {
  const sheetRows = new Map();
  for (const row of Array.isArray(sheet?.sounds) ? sheet.sounds : []) {
    if (typeof row?.id === "string") sheetRows.set(row.id, row);
  }
  const manifest = readSourceManifest(sourceDir);
  const files = [];
  const sounds = {};
  const silent = [];
  for (const [id, rowId] of catalogRows(catalog)) {
    const row = sheetRows.get(rowId);
    const source = manifest ? manifest.sounds[rowId] : undefined;
    const entry = { row: rowId };
    if (source && typeof source === "object") {
      for (const [key, value] of Object.entries(source)) if (key !== "takes") entry[key] = value;
      const gain = entryGainDb(source);
      if (gain === null) delete entry.gain_db;
      else entry.gain_db = gain;
    }
    entry.takes = [];
    sounds[id] = entry;
    if (!row && !source) {
      silent.push([id, `no row ${rowId} in ${SHEET} yet`]);
      continue;
    }
    if (manifest && !source) {
      silent.push([id, `no entry ${rowId} in the source's ${MANIFEST}`]);
      continue;
    }
    const takes = rowTakes(row, source, sourceDir);
    takes.forEach((take, index) => {
      const name = `${id}_${String(index + 1).padStart(2, "0")}.ogg`;
      files.push({ id, name, from: join(sourceDir, take) });
      entry.takes.push(name);
    });
    if (takes.length === 0) silent.push([id, `no takes in the source`]);
  }
  return { files, sounds, silent, manifest: manifest !== null };
}

// The folder, made if need be; refused if it (or a folder on its way) is a link or
// not a folder.
function targetFolder(project) {
  const projectReal = realpathSync(project);
  let at = projectReal;
  for (const part of TARGET.split("/")) {
    at = join(at, part);
    let stat = null;
    try {
      stat = lstatSync(at);
    } catch {
      stat = null;
    }
    if (stat?.isSymbolicLink()) throw new FetchError(`${relative(projectReal, at)} is a link; the sound folder must be a plain folder in the project`);
    if (stat && !stat.isDirectory()) throw new FetchError(`${relative(projectReal, at)} is not a folder`);
  }
  return join(projectReal, TARGET);
}

// Whether b is a plain file (not a link) with a's bytes.
function sameBytes(a, b) {
  if (!isPlainFile(b)) return false;
  if (statSync(a).size !== statSync(b).size) return false;
  return readFileSync(a).equals(readFileSync(b));
}

function isPlainFile(path) {
  try {
    return lstatSync(path).isFile();
  } catch {
    return false;
  }
}

// Writes a new file beside path and renames it over path (which replaces a link
// there rather than following it). Whatever was at the .part name goes first, and
// the new file is made exclusively, so a link left there is never written through.
function writeAtomic(path, bytes) {
  const part = `${path}.part`;
  rmSync(part, { force: true });
  writeFileSync(part, bytes, { flag: "wx" });
  renameSync(part, path);
}

// Brings the folder to the plan. Returns {copied, unchanged, removed}.
export function apply(project, planned, { dryRun = false } = {}) {
  const folder = targetFolder(project);
  if (!dryRun) mkdirSync(folder, { recursive: true });
  const wanted = new Set(planned.files.map((file) => file.name));
  const counts = { copied: 0, unchanged: 0, removed: 0 };
  for (const file of planned.files) {
    const to = join(folder, file.name);
    if (sameBytes(file.from, to)) {
      counts.unchanged += 1;
      continue;
    }
    counts.copied += 1;
    if (!dryRun) writeAtomic(to, readFileSync(file.from));
  }
  const present = existsSync(folder) ? readdirSync(folder) : [];
  for (const name of present) {
    const path = join(folder, name);
    const stat = lstatSync(path);
    // A left-over .part goes whatever it is (a link included: the link, not its target).
    if (PART_RE.test(name) && stat.isSymbolicLink()) {
      if (!dryRun) unlinkSync(path);
      continue;
    }
    if (!stat.isFile()) continue;
    const stale = (TAKE_RE.test(name) && !wanted.has(name))
      || (IMPORT_RE.test(name) && !wanted.has(name.slice(0, -".import".length)))
      || PART_RE.test(name);
    if (!stale) continue;
    if (TAKE_RE.test(name)) counts.removed += 1;
    if (!dryRun) unlinkSync(path);
  }
  const manifest = {
    schema_version: MANIFEST_SCHEMA,
    notes: [`Written by ${TOOL} (tools/sfx/fetch_sfx.mjs); ignored by Git. For each sound id of ${CATALOG}: the sheet row it comes from and that row's entry in the source's ${MANIFEST} (tools/sfx/README.md "Levels"), its takes renamed as copied into this folder. The game applies gain_db as each take's playback gain; a sound with no gain_db plays at 0 dB, one with no takes is silent.`],
    sounds: planned.sounds,
  };
  if (!dryRun) writeAtomic(join(folder, MANIFEST), `${JSON.stringify(manifest, null, 2)}\n`);
  return counts;
}

// A URL, or a message with URLs in it (git's own), with any user or password
// taken out of every URL and the value of any Authorization header blanked.
export function redact(text) {
  return text
    .replace(/([a-z][a-z0-9+.-]*:\/\/)[^@/\s'"]*@/giu, "$1")
    .replace(/(authorization:\s*[a-z]+\s+)[^\s'"]+/giu, "$1***");
}

// Clones a Git source (shallow) into a new temporary folder; returns {dir, source,
// commit (short, for the log line), fullCommit}.
function cloneSource(url, ref, token) {
  const dir = mkdtempSync(join(tmpdir(), "ti-sfx-"));
  // No tracing of git's own (GIT_TRACE*, GIT_CURL_VERBOSE): it could print the
  // header below.
  const env = Object.fromEntries(Object.entries(process.env).filter(([key]) => !key.startsWith("GIT_TRACE") && key !== "GIT_CURL_VERBOSE"));
  env.GIT_TERMINAL_PROMPT = "0";
  if (token) {
    // git reads GIT_CONFIG_COUNT/KEY/VALUE as -c would set them (git 2.31+), so
    // the header stays out of every process's command line. With a token no
    // credential helper is asked (an empty helper resets the list): a refused
    // token fails at once, never prompting or falling back to other credentials.
    const count = Number.parseInt(env.GIT_CONFIG_COUNT ?? "0", 10) || 0;
    env.GIT_CONFIG_COUNT = String(count + 2);
    env[`GIT_CONFIG_KEY_${count}`] = "http.extraHeader";
    env[`GIT_CONFIG_VALUE_${count}`] = `Authorization: Basic ${Buffer.from(`x-access-token:${token}`).toString("base64")}`;
    env[`GIT_CONFIG_KEY_${count + 1}`] = "credential.helper";
    env[`GIT_CONFIG_VALUE_${count + 1}`] = "";
  }
  const args = ["clone", "--depth", "1", "--quiet", "--no-tags"];
  if (ref) args.push("--branch", ref);
  args.push("--", url, join(dir, "source"));
  const cloned = spawnSync("git", args, { env, encoding: "utf8" });
  if (cloned.status !== 0) {
    rmSync(dir, { recursive: true, force: true });
    let said = `${cloned.stderr ?? ""}${cloned.error ? String(cloned.error) : ""}`.trim();
    if (token) said = said.split(token).join("***");
    throw new FetchError(`git could not clone ${redact(url)}${ref ? ` at ${ref}` : ""}: ${redact(said) || `exit ${cloned.status}`}`);
  }
  const revParse = (...args) => spawnSync("git", ["-C", join(dir, "source"), "rev-parse", ...args, "HEAD"], { encoding: "utf8" }).stdout?.trim() ?? "";
  return { dir, source: join(dir, "source"), commit: revParse("--short"), fullCommit: revParse() };
}

// Writes the --result file (see the header). Nothing is written without a path.
function writeResult(path, result) {
  if (!path) return;
  writeAtomic(path, `${JSON.stringify({ schema_version: RESULT_SCHEMA, ...result }, null, 2)}\n`);
}

function readJson(path, what) {
  try {
    return JSON.parse(readFileSync(path, "utf8"));
  } catch (error) {
    throw new FetchError(`could not read ${what} (${path}): ${error.message}`);
  }
}

// Inside base (or base itself), after resolving links.
function inside(base, path) {
  const rel = relative(realpathSync(base), realpathSync(path));
  return rel === "" || (rel !== ".." && !rel.startsWith(`..${sep}`) && !rel.startsWith(sep));
}

export function main(argv = process.argv.slice(2), env = process.env) {
  const { values } = parseArgs({
    args: argv,
    options: {
      source: { type: "string" },
      subdir: { type: "string" },
      ref: { type: "string" },
      project: { type: "string" },
      "dry-run": { type: "boolean", default: false },
      "require-all": { type: "boolean", default: false },
      result: { type: "string" },
      help: { type: "boolean", default: false },
    },
    strict: true,
  });
  if (values.help) {
    console.log(`usage: ${TOOL} [--source DIR|URL] [--subdir PATH] [--ref REF] [--project DIR] [--dry-run] [--require-all] [--result FILE]`);
    return 0;
  }
  const dryRun = values["dry-run"];
  const requireAll = values["require-all"];
  // A failed run must leave no earlier result behind for a script to read.
  const resultPath = values.result === undefined ? null : resolve(values.result);
  if (resultPath) {
    let stat = null;
    try {
      stat = lstatSync(resultPath);
    } catch {
      stat = null;
    }
    if (stat?.isDirectory()) throw new FetchError(`--result ${resultPath} is a folder; give a file`);
    if (stat) unlinkSync(resultPath);
  }
  const project = resolve(values.project ?? REPO_ROOT);
  if (!existsSync(join(project, "project.godot"))) throw new FetchError(`${project} is not the game's project (no project.godot)`);
  const source = values.source ?? env.TI_SFX_SOURCE ?? "";
  if (source === "") {
    const folder = join(project, TARGET);
    const takes = existsSync(folder) ? readdirSync(folder).filter((name) => TAKE_RE.test(name)).length : 0;
    console.log(`${TOOL}: no source (--source or TI_SFX_SOURCE): nothing fetched; ${TARGET} holds ${takes} takes, left as they are`);
    writeResult(resultPath, { source: null, ref: null, subdir: null, commit: null, dry_run: dryRun, sounds: null, sounds_with_takes: null, takes, silent: [], complete: false });
    if (requireAll) {
      console.error(`${TOOL}: --require-all: there is no source, so no sound the game plays gets its takes`);
      return EXIT_INCOMPLETE;
    }
    return 0;
  }
  const subdir = values.subdir ?? env.TI_SFX_SUBDIR ?? "";
  const ref = values.ref ?? env.TI_SFX_REF ?? "";
  const catalog = readJson(join(project, CATALOG), "the game's sound catalog");
  const sheet = readJson(join(project, SHEET), "the prompt sheet");
  let clone = null;
  try {
    let from;
    let described;
    if (GIT_URL_RE.test(source)) {
      clone = cloneSource(source, ref, env.TI_SFX_GIT_TOKEN ?? "");
      from = join(clone.source, subdir);
      if (!existsSync(from) || !statSync(from).isDirectory() || !inside(clone.source, from)) throw new FetchError(`${subdir || "the repository"} is not a folder in ${redact(source)}`);
      described = `${redact(source)}${ref ? ` at ${ref}` : ""} (${clone.commit})${subdir ? `, ${subdir}` : ""}`;
    } else {
      from = resolve(source, subdir);
      if (!existsSync(from) || !statSync(from).isDirectory()) throw new FetchError(`the source ${from} is not a folder`);
      if (inside(project, from)) throw new FetchError(`the source ${from} lies in the project; give the private folder the processed takes are in`);
      described = from;
    }
    const planned = plan(catalog, sheet, from);
    const ids = Object.keys(planned.sounds).length;
    const withTakes = Object.values(planned.sounds).filter((entry) => entry.takes.length > 0).length;
    const gains = Object.values(planned.sounds).filter((entry) => "gain_db" in entry).length;
    const outcome = {
      source: clone ? redact(source) : from,
      ref: clone ? ref || null : null,
      subdir: subdir || null,
      commit: clone ? clone.fullCommit || null : null,
      dry_run: dryRun,
      sounds: ids,
      sounds_with_takes: withTakes,
      takes: planned.files.length,
      silent: planned.silent.map(([id, why]) => ({ id, why })),
      complete: planned.silent.length === 0,
    };
    if (requireAll && !outcome.complete) {
      // Checked before anything is written, so a refused run leaves the folder as it was.
      console.error(`${TOOL}: --require-all: ${planned.silent.length} of ${ids} sounds the game plays have no takes in ${described}, so nothing was fetched:`);
      for (const [id, why] of planned.silent) console.error(`  silent: ${id}: ${why}`);
      writeResult(resultPath, outcome);
      return EXIT_INCOMPLETE;
    }
    const counts = apply(project, planned, { dryRun });
    console.log(`${TOOL}: ${dryRun ? "would fetch" : "fetched"} from ${described} into ${TARGET}: ${withTakes} of ${ids} sounds with takes, ${planned.files.length} takes (${counts.copied} copied, ${counts.unchanged} unchanged, ${counts.removed} removed), ${gains} with a playback gain`);
    if (!planned.manifest) console.log(`NOTE: ${TOOL}: the source has no ${MANIFEST} (processed before the level plan): no playback gains, every sound plays at 0 dB`);
    for (const [id, why] of planned.silent) console.log(`  silent: ${id}: ${why}`);
    writeResult(resultPath, outcome);
    return 0;
  } finally {
    if (clone) rmSync(clone.dir, { recursive: true, force: true });
  }
}

if (import.meta.url === pathToFileURL(process.argv[1] ?? "").href) {
  try {
    process.exitCode = main();
  } catch (error) {
    if (error instanceof FetchError || error?.code === "ERR_PARSE_ARGS_UNKNOWN_OPTION" || error?.code === "ERR_PARSE_ARGS_INVALID_OPTION_VALUE") {
      console.error(`${TOOL}: ${error.message}`);
      process.exitCode = error instanceof FetchError ? 1 : 2;
    } else {
      throw error;
    }
  }
}
