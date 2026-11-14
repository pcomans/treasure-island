#!/usr/bin/env node
// Checks tools/fetch-sfx offline, in temporary folders (no Godot, and no network
// but one refused connection to 127.0.0.1):
//   1. without a source it does nothing, leaves the sound folder as it is and
//      says how many takes it holds;
//   2. from a folder with a manifest (sfx.json) it copies the takes of the game's
//      sounds only (not of rows the game does not play), renamed <id>_NN.ogg in
//      the manifest's order, and writes the folder's sfx.json with each entry's
//      gain and loop, a sound with no row or no takes listed silent;
//   3. a second run changes nothing; with a take gone from the source, the stale
//      take and its .import go, while the folder's README.md, an unknown file in
//      it and a file outside it stay;
//   4. from a folder without a manifest (processed before the level plan) it
//      finds the takes by the sheet's output patterns and gives no gains;
//   5. from a Git repository (file:// URL, --subdir, --ref) as from a folder, and
//      a token in TI_SFX_GIT_TOKEN is never printed, even when the clone fails;
//   6. it refuses a sound folder that is a link out of the project, a source that
//      is not a folder, and a source inside the project, changing nothing;
//   7. --dry-run changes nothing;
//   8. a link in the folder is never written through: a left-over .part link to a
//      file outside goes (the file stays as it was), and a take that is a link,
//      even to the same bytes, is replaced by a plain copy;
//   9. as the Mac build workflow runs it (unset repository variables and secret
//      come as empty strings): with every TI_SFX_ variable empty it does nothing;
//      from a repository holding the processed folder at its root (the private
//      audio repository's layout) with TI_SFX_SUBDIR and TI_SFX_REF empty it fills
//      the folder; a URL with a user and password in it that cannot be cloned
//      fails without printing either, and redact() takes them out of a message;
//      with git's tracing asked for (GIT_TRACE, GIT_TRACE_CURL, GIT_TRACE_REDACT=0,
//      GIT_CURL_VERBOSE), a clone a local server refuses (401) prints no trace and
//      no Authorization header, and redact() blanks such a header's value;
//  10. --require-all: a source with every sound's takes fills the folder; one
//      without one sound's takes exits 3 naming it and changes nothing; no source
//      exits 3 only under the flag; --result records each outcome (a Git source's
//      full commit, never the token), and a failed run leaves no result behind;
//  11. tools/deploy-web.sh's sound guard (--check-sfx-guard), with stand-in sources
//      for the game's real catalog and a stand-in git that must never run: no
//      source refuses; --silent-ok goes on with a warning; a source missing one
//      sound's takes refuses, naming it, and goes on with --silent-ok, warning and
//      naming it; a source that fails stops it even with --silent-ok; a complete
//      source passes with its takes counted.
// A few seconds. Part of tools/test.sh.
//
//   node tools/check_fetch_sfx.mjs

import { spawn, spawnSync } from "node:child_process";
import { chmodSync, existsSync, lstatSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, rmSync, statSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const TOOL = join(ROOT, "tools", "sfx", "fetch_sfx.mjs");
const work = mkdtempSync(join(tmpdir(), "ti-check-fetch-sfx-"));
const failures = [];
const TOKEN = "ghp_sixteencharactersecret0123456789";

function check(condition, message) {
  if (!condition) failures.push(message);
  return condition;
}

function write(path, text) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, text);
}

// The tool as a process; one that runs past 60 s (a clone waiting on something)
// is stopped, and its status is then null.
function run(args, env = {}) {
  const result = spawnSync(process.execPath, [TOOL, ...args], { encoding: "utf8", timeout: 60000, env: { PATH: process.env.PATH, HOME: process.env.HOME, ...env } });
  return { status: result.status, out: `${result.stdout}${result.stderr}` };
}

function listing(folder) {
  return existsSync(folder) ? readdirSync(folder).sort() : [];
}

function manifestOf(project) {
  return JSON.parse(readFileSync(join(project, "game/resources/audio/sfx/sfx.json"), "utf8"));
}

// A project: the game's catalog (a two-take sound, a loop, a sound named by another
// row, and, unless complete, one whose row the sheet lacks), the sheet, the sound
// folder with its README.
function makeProject(name, { complete = false } = {}) {
  const project = join(work, name);
  write(join(project, "project.godot"), "config_version=5\n");
  const sounds = { step: { space: "3d" }, hum_loop: { loop: true }, knock: { row: "door_knock" } };
  if (!complete) sounds.future = {};
  write(join(project, "game/resources/audio/sounds.json"), JSON.stringify({ sounds }));
  write(join(project, "tools/sfx/prompts.json"), JSON.stringify({
    sounds: [
      { id: "step", output: "player/step_{take}.ogg" },
      { id: "hum_loop", output: "car/hum_loop_{take}.ogg" },
      { id: "door_knock", output: "car/knock_{take}.ogg" },
      { id: "coins", output: "player/coins_{take}.ogg" },
    ],
  }));
  write(join(project, "game/resources/audio/sfx/README.md"), "note\n");
  return project;
}

// A processed source folder; with a manifest unless bare.
function makeSource(name, bare = false) {
  const source = join(work, name);
  write(join(source, "player/step_01.ogg"), "step one");
  write(join(source, "player/step_02.ogg"), "step two");
  write(join(source, "car/hum_loop_01.ogg"), "hum");
  write(join(source, "car/knock_01.ogg"), "knock");
  write(join(source, "player/coins_01.ogg"), "coins");
  if (!bare) {
    write(join(source, "sfx.json"), JSON.stringify({
      schema_version: "ti.sfx-manifest/1",
      sounds: {
        step: { gain_db: -6.5, level_db: -33, loop: false, channels: 1, takes: ["player/step_02.ogg", "player/step_01.ogg"] },
        hum_loop: { gain_db: -12, loop: true, channels: 1, takes: ["car/hum_loop_01.ogg"] },
        door_knock: { gain_db: -3, loop: false, channels: 1, takes: ["car/knock_01.ogg", "../escape.ogg"] },
        coins: { gain_db: -1, loop: false, channels: 1, takes: ["player/coins_01.ogg"] },
      },
    }));
  }
  return source;
}

try {
  // 1. No source.
  const project = makeProject("project");
  const sfx = join(project, "game/resources/audio/sfx");
  let result = run(["--project", project]);
  check(result.status === 0 && /nothing fetched; game\/resources\/audio\/sfx holds 0 takes/u.test(result.out) && listing(sfx).join() === "README.md", `1: with no source it must do nothing and say the folder holds 0 takes (exit ${result.status}, folder ${listing(sfx)}): ${result.out}`);

  // 2. A folder with a manifest.
  const source = makeSource("source");
  write(join(work, "escape.ogg"), "outside");
  result = run(["--project", project], { TI_SFX_SOURCE: source });
  const expected = ["README.md", "hum_loop_01.ogg", "knock_01.ogg", "sfx.json", "step_01.ogg", "step_02.ogg"];
  check(result.status === 0 && listing(sfx).join() === expected.join(), `2: the folder must hold ${expected} (exit ${result.status}, has ${listing(sfx)}): ${result.out}`);
  check(readFileSync(join(sfx, "step_01.ogg"), "utf8") === "step two", "2: takes must be copied in the manifest's order");
  let manifest = manifestOf(project);
  check(manifest.schema_version === "ti.sfx-manifest/1", "2: the folder's manifest must keep the schema");
  check(manifest.sounds.step.gain_db === -6.5 && manifest.sounds.step.level_db === -33 && manifest.sounds.step.takes.join() === "step_01.ogg,step_02.ogg", `2: step's entry is wrong: ${JSON.stringify(manifest.sounds.step)}`);
  check(manifest.sounds.hum_loop.loop === true && manifest.sounds.hum_loop.gain_db === -12, `2: hum_loop's entry is wrong: ${JSON.stringify(manifest.sounds.hum_loop)}`);
  check(manifest.sounds.knock.row === "door_knock" && manifest.sounds.knock.takes.join() === "knock_01.ogg" && manifest.sounds.knock.gain_db === -3, `2: knock must come from row door_knock, without the take outside the source: ${JSON.stringify(manifest.sounds.knock)}`);
  check(manifest.sounds.future.takes.length === 0 && !("gain_db" in manifest.sounds.future) && /silent: future/u.test(result.out), `2: future, whose row is missing, must be listed silent: ${JSON.stringify(manifest.sounds.future)}`);
  check(!("coins" in manifest.sounds) && !listing(sfx).some((name) => name.startsWith("coins")), "2: a row the game does not play must not be copied");

  // 3. Repeat; a take gone.
  const before = statSync(join(sfx, "step_01.ogg")).mtimeMs;
  result = run(["--project", project], { TI_SFX_SOURCE: source });
  check(result.status === 0 && /0 copied, 4 unchanged, 0 removed/u.test(result.out) && statSync(join(sfx, "step_01.ogg")).mtimeMs === before, `3: a second run must change nothing: ${result.out}`);
  write(join(sfx, "step_02.ogg.import"), "[remap]\n");
  write(join(sfx, "notes.txt"), "keep me");
  write(join(project, "game/resources/audio/keep.ogg"), "outside the folder");
  const manifestPath = join(source, "sfx.json");
  const sourceManifest = JSON.parse(readFileSync(manifestPath, "utf8"));
  sourceManifest.sounds.step.takes = ["player/step_01.ogg"];
  writeFileSync(manifestPath, JSON.stringify(sourceManifest));
  result = run(["--project", project], { TI_SFX_SOURCE: source });
  check(result.status === 0 && !existsSync(join(sfx, "step_02.ogg")) && !existsSync(join(sfx, "step_02.ogg.import")), `3: the stale take and its .import must go: ${listing(sfx)}`);
  check(existsSync(join(sfx, "README.md")) && existsSync(join(sfx, "notes.txt")) && existsSync(join(project, "game/resources/audio/keep.ogg")), "3: the README, an unknown file and a file outside the folder must stay");
  check(readFileSync(join(sfx, "step_01.ogg"), "utf8") === "step one", "3: a take whose source changed must be copied again");

  // 4. A folder without a manifest.
  const bareProject = makeProject("bare-project");
  const bare = makeSource("bare", true);
  result = run(["--project", bareProject, "--source", bare]);
  manifest = manifestOf(bareProject);
  check(result.status === 0 && /NOTE: .*no sfx\.json/u.test(result.out) && manifest.sounds.step.takes.join() === "step_01.ogg,step_02.ogg" && !("gain_db" in manifest.sounds.step) && manifest.sounds.knock.takes.join() === "knock_01.ogg", `4: without a manifest the sheet's patterns must give the takes and no gains: ${JSON.stringify(manifest.sounds)} ${result.out}`);

  // 5. A Git repository.
  const repo = join(work, "repo");
  const git = (args, cwd = repo) => spawnSync("git", args, { cwd, encoding: "utf8", env: { ...process.env, GIT_AUTHOR_NAME: "check", GIT_AUTHOR_EMAIL: "check@example.invalid", GIT_COMMITTER_NAME: "check", GIT_COMMITTER_EMAIL: "check@example.invalid" } });
  mkdirSync(repo, { recursive: true });
  git(["init", "--quiet", "--initial-branch=sounds"]);
  makeSource("repo/game");
  git(["add", "."]);
  git(["commit", "--quiet", "-m", "takes"]);
  const gitProject = makeProject("git-project");
  result = run(["--project", gitProject], { TI_SFX_SOURCE: `file://${repo}`, TI_SFX_SUBDIR: "game", TI_SFX_REF: "sounds", TI_SFX_GIT_TOKEN: TOKEN });
  check(result.status === 0 && listing(join(gitProject, "game/resources/audio/sfx")).join() === expected.join() && !result.out.includes(TOKEN), `5: a Git source must fill the folder as a folder does, never printing the token (exit ${result.status}): ${result.out}`);
  result = run(["--project", gitProject], { TI_SFX_SOURCE: `file://${repo}-missing`, TI_SFX_GIT_TOKEN: TOKEN });
  check(result.status === 1 && /could not clone/u.test(result.out) && !result.out.includes(TOKEN), `5: a failed clone must exit 1 without the token: ${result.out}`);

  // 6. Refusals.
  const linked = makeProject("linked-project");
  const outside = join(work, "outside-folder");
  mkdirSync(outside);
  rmSync(join(linked, "game/resources/audio/sfx"), { recursive: true });
  symlinkSync(outside, join(linked, "game/resources/audio/sfx"));
  result = run(["--project", linked, "--source", source]);
  check(result.status === 1 && /is a link/u.test(result.out) && listing(outside).length === 0, `6: a linked sound folder must be refused, writing nothing: ${result.out}`);
  result = run(["--project", project, "--source", join(work, "no-such-folder")]);
  check(result.status === 1 && /not a folder/u.test(result.out), `6: a missing source must be refused: ${result.out}`);
  result = run(["--project", project, "--source", join(project, "game")]);
  check(result.status === 1 && /lies in the project/u.test(result.out), `6: a source inside the project must be refused: ${result.out}`);

  // 7. Dry run.
  const dryProject = makeProject("dry-project");
  result = run(["--project", dryProject, "--source", source, "--dry-run"]);
  check(result.status === 0 && /would fetch/u.test(result.out) && listing(join(dryProject, "game/resources/audio/sfx")).join() === "README.md", `7: --dry-run must change nothing: ${result.out}`);

  // 8. Links in the folder.
  const linkProject = makeProject("link-project");
  const linkSfx = join(linkProject, "game/resources/audio/sfx");
  const victim = join(work, "victim.txt");
  const twin = join(work, "knock-twin.ogg");
  write(victim, "victim");
  write(twin, "knock");
  // .part links where takes and the manifest are written, and one where nothing is.
  for (const name of ["step_01.ogg.part", "hum_loop_01.ogg.part", "sfx.json.part", "step_02.ogg.part"]) symlinkSync(victim, join(linkSfx, name));
  symlinkSync(twin, join(linkSfx, "knock_01.ogg"));
  result = run(["--project", linkProject, "--source", source]);
  const plain = (name) => existsSync(join(linkSfx, name)) && lstatSync(join(linkSfx, name)).isFile();
  check(result.status === 0 && readFileSync(victim, "utf8") === "victim" && readFileSync(twin, "utf8") === "knock", `8: a link in the folder must never be written through (exit ${result.status}): ${result.out}`);
  check(!listing(linkSfx).some((name) => name.endsWith(".part")) && plain("step_01.ogg") && plain("hum_loop_01.ogg") && plain("knock_01.ogg") && readFileSync(join(linkSfx, "knock_01.ogg"), "utf8") === "knock", `8: the .part links must go and every take must be a plain file: ${listing(linkSfx)}`);

  // 9. As the Mac build workflow runs it.
  const ciEmpty = { TI_SFX_SOURCE: "", TI_SFX_SUBDIR: "", TI_SFX_REF: "", TI_SFX_GIT_TOKEN: "" };
  const ciProject = makeProject("ci-project");
  const ciSfx = join(ciProject, "game/resources/audio/sfx");
  result = run(["--project", ciProject], ciEmpty);
  check(result.status === 0 && /nothing fetched/u.test(result.out) && listing(ciSfx).join() === "README.md", `9: with every TI_SFX_ variable empty it must do nothing (exit ${result.status}): ${result.out}`);
  const rootRepo = join(work, "root-repo");
  mkdirSync(rootRepo, { recursive: true });
  git(["init", "--quiet", "--initial-branch=main"], rootRepo);
  makeSource("root-repo");
  git(["add", "."], rootRepo);
  git(["commit", "--quiet", "-m", "takes"], rootRepo);
  result = run(["--project", ciProject], { ...ciEmpty, TI_SFX_SOURCE: `file://${rootRepo}`, TI_SFX_GIT_TOKEN: TOKEN });
  check(result.status === 0 && listing(ciSfx).join() === expected.join() && /fetched from file:.* into game\/resources\/audio\/sfx: 3 of 4 sounds with takes, 4 takes/u.test(result.out) && !result.out.includes(TOKEN), `9: a repository with the processed folder at its root, TI_SFX_SUBDIR and TI_SFX_REF empty, must fill the folder as a folder does, never printing the token (exit ${result.status}, has ${listing(ciSfx)}): ${result.out}`);
  const URL_SECRET = "pw-in-the-url-0123456789";
  result = run(["--project", ciProject], { ...ciEmpty, TI_SFX_SOURCE: `https://ci-user:${URL_SECRET}@127.0.0.1:9/audio.git`, TI_SFX_GIT_TOKEN: TOKEN });
  check(result.status === 1 && /could not clone https:\/\/127\.0\.0\.1:9\/audio\.git/u.test(result.out) && !result.out.includes(URL_SECRET) && !result.out.includes("ci-user") && !result.out.includes(TOKEN), `9: a credentialed URL that cannot be cloned must fail without printing its user, password or the token: ${result.out}`);
  const { redact } = await import(pathToFileURL(TOOL).href);
  const said = redact(`fatal: unable to access 'https://ci-user:${URL_SECRET}@example.invalid/audio.git/': refused; see https://example.invalid/help`);
  check(!said.includes(URL_SECRET) && !said.includes("ci-user") && said.includes("'https://example.invalid/audio.git/'") && said.includes("see https://example.invalid/help"), `9: redact() must take a user and password out of a URL inside a message, and nothing else: ${said}`);
  const header = Buffer.from(`x-access-token:${TOKEN}`).toString("base64");
  const blanked = redact(`=> Send header: Authorization: Basic ${header}\n< WWW-Authenticate: Basic realm=audio`);
  check(!blanked.includes(header) && blanked.includes("Authorization: Basic ***") && blanked.includes("WWW-Authenticate: Basic realm=audio"), `9: redact() must blank an Authorization header's value, and nothing else: ${blanked}`);
  // A local server (its own process: the check itself waits on git) that refuses
  // every request, so git sends its headers and fails.
  const server = spawn(process.execPath, ["-e", "const s = require('node:http').createServer((q, r) => { r.writeHead(401, { 'WWW-Authenticate': 'Basic realm=audio' }); r.end(); }); s.listen(0, '127.0.0.1', () => console.log(s.address().port));"], { stdio: ["ignore", "pipe", "inherit"] });
  try {
    const port = await new Promise((done) => server.stdout.once("data", (chunk) => done(String(chunk).trim())));
    const traced = run(["--project", ciProject], { ...ciEmpty, TI_SFX_SOURCE: `http://127.0.0.1:${port}/audio.git`, TI_SFX_GIT_TOKEN: TOKEN, GIT_TRACE: "1", GIT_TRACE_CURL: "1", GIT_TRACE_REDACT: "0", GIT_CURL_VERBOSE: "1" });
    check(traced.status === 1 && /could not clone http:\/\/127\.0\.0\.1:/u.test(traced.out) && !traced.out.includes(header) && !traced.out.includes(TOKEN) && !/Send header|authorization:/iu.test(traced.out), `9: with git's tracing asked for, a refused clone must print no trace and no Authorization header: ${traced.out}`);
  } finally {
    server.kill();
  }

  // 10. --require-all and --result.
  const resultFile = join(work, "result.json");
  const outcomeOf = () => (existsSync(resultFile) ? JSON.parse(readFileSync(resultFile, "utf8")) : null);
  const fullProject = makeProject("full-project", { complete: true });
  const fullSfx = join(fullProject, "game/resources/audio/sfx");
  const fullSource = makeSource("full-source");
  result = run(["--project", fullProject, "--require-all", "--result", resultFile], { TI_SFX_SOURCE: fullSource });
  let outcome = outcomeOf();
  const fullListing = ["README.md", "hum_loop_01.ogg", "knock_01.ogg", "sfx.json", "step_01.ogg", "step_02.ogg"];
  check(result.status === 0 && listing(fullSfx).join() === fullListing.join(), `10: --require-all with every sound's takes in the source must fetch them (exit ${result.status}, has ${listing(fullSfx)}): ${result.out}`);
  check(outcome?.schema_version === "ti.sfx-fetch-result/1" && outcome.complete === true && outcome.sounds === 3 && outcome.sounds_with_takes === 3 && outcome.takes === 4 && outcome.silent.length === 0 && outcome.source === fullSource && outcome.commit === null && outcome.dry_run === false, `10: the result of a complete fetch is wrong: ${JSON.stringify(outcome)}`);
  const gapSource = makeSource("gap-source");
  rmSync(join(gapSource, "car/knock_01.ogg"));
  const folderState = () => listing(fullSfx).map((name) => `${name}:${statSync(join(fullSfx, name)).mtimeMs}:${readFileSync(join(fullSfx, name), "utf8")}`).join("|");
  const beforeGap = folderState();
  result = run(["--project", fullProject, "--require-all", "--result", resultFile], { TI_SFX_SOURCE: gapSource });
  outcome = outcomeOf();
  check(result.status === 3 && /--require-all: 1 of 3 sounds the game plays have no takes in \S*gap-source, so nothing was fetched/u.test(result.out) && /silent: knock: no takes in the source/u.test(result.out), `10: a source without one sound's takes must exit 3 under --require-all, naming it (exit ${result.status}): ${result.out}`);
  check(folderState() === beforeGap, "10: a run --require-all refuses must leave the folder exactly as it was");
  check(outcome?.complete === false && outcome.silent.map((entry) => entry.id).join() === "knock" && outcome.sounds_with_takes === 2 && outcome.takes === 3, `10: the refused run's result must name knock: ${JSON.stringify(outcome)}`);
  result = run(["--project", fullProject, "--require-all", "--result", resultFile]);
  outcome = outcomeOf();
  check(result.status === 3 && /--require-all: there is no source/u.test(result.out) && folderState() === beforeGap, `10: --require-all without a source must exit 3, changing nothing (exit ${result.status}): ${result.out}`);
  check(outcome?.source === null && outcome.complete === false && outcome.sounds === null && outcome.takes === 4, `10: the no-source result is wrong: ${JSON.stringify(outcome)}`);
  result = run(["--project", fullProject]);
  check(result.status === 0 && /nothing fetched/u.test(result.out), `10: without --require-all no source still does nothing and passes (exit ${result.status}): ${result.out}`);
  const dryFull = makeProject("dry-full-project", { complete: true });
  result = run(["--project", dryFull, "--dry-run", "--require-all", "--result", resultFile], { TI_SFX_SOURCE: fullSource });
  outcome = outcomeOf();
  check(result.status === 0 && /would fetch/u.test(result.out) && listing(join(dryFull, "game/resources/audio/sfx")).join() === "README.md" && outcome?.dry_run === true && outcome.complete === true, `10: --dry-run --require-all must check without fetching (exit ${result.status}): ${result.out} ${JSON.stringify(outcome)}`);
  const repoHead = git(["rev-parse", "HEAD"]).stdout.trim();
  result = run(["--project", gitProject, "--result", resultFile], { TI_SFX_SOURCE: `file://${repo}`, TI_SFX_SUBDIR: "game", TI_SFX_REF: "sounds", TI_SFX_GIT_TOKEN: TOKEN });
  outcome = outcomeOf();
  check(result.status === 0 && /^[0-9a-f]{40}$/u.test(repoHead) && outcome?.commit === repoHead && outcome.source === `file://${repo}` && outcome.ref === "sounds" && outcome.subdir === "game" && outcome.complete === false && outcome.silent.map((entry) => entry.id).join() === "future" && !readFileSync(resultFile, "utf8").includes(TOKEN), `10: a Git source's result must hold its full commit, ref and subdir, never the token: ${JSON.stringify(outcome)} ${result.out}`);
  result = run(["--project", gitProject, "--require-all", "--result", resultFile], { TI_SFX_SOURCE: `file://${repo}`, TI_SFX_SUBDIR: "game", TI_SFX_REF: "sounds", TI_SFX_GIT_TOKEN: TOKEN });
  check(result.status === 3 && /silent: future: no row future in tools\/sfx\/prompts\.json yet/u.test(result.out) && !result.out.includes(TOKEN), `10: a Git source without one sound must exit 3 under --require-all, naming it, never the token (exit ${result.status}): ${result.out}`);
  write(resultFile, "stale");
  result = run(["--project", fullProject, "--result", resultFile, "--source", join(work, "no-such-folder")]);
  check(result.status === 1 && !existsSync(resultFile), `10: a failed run must leave no result behind (exit ${result.status}): ${result.out}`);
  result = run(["--project", fullProject, "--result", work]);
  check(result.status === 1 && /is a folder/u.test(result.out), `10: --result naming a folder must be refused (exit ${result.status}): ${result.out}`);

  // 11. tools/deploy-web.sh's sound guard, offline: stand-in sources for the game's
  // real catalog (one take a sound), and a stand-in git that must never run.
  const { catalogRows } = await import(pathToFileURL(TOOL).href);
  const realRows = catalogRows(JSON.parse(readFileSync(join(ROOT, "game/resources/audio/sounds.json"), "utf8")));
  const ids = realRows.length;
  const [gapId, gapRow] = realRows[0];
  const standSource = (name, skipRow = null) => {
    const folder = join(work, name);
    const sounds = {};
    for (const [, row] of realRows) {
      sounds[row] = { gain_db: -1, loop: false, channels: 1, takes: [`stand/${row}_01.ogg`] };
      if (row !== skipRow) write(join(folder, "stand", `${row}_01.ogg`), row);
    }
    write(join(folder, "sfx.json"), JSON.stringify({ schema_version: "ti.sfx-manifest/1", sounds }));
    return folder;
  };
  const completeStand = standSource("stand-complete");
  const gapStand = standSource("stand-gap", gapRow);
  const standBin = join(work, "stand-bin");
  const gitCalls = join(work, "git-calls.log");
  write(join(standBin, "git"), `#!/bin/sh\necho "stand-in git: $*" >> '${gitCalls}'\nexit 97\n`);
  chmodSync(join(standBin, "git"), 0o755);
  const deploy = (args, env = {}) => {
    const ran = spawnSync("bash", [join(ROOT, "tools", "deploy-web.sh"), ...args], { encoding: "utf8", timeout: 60000, env: { PATH: `${standBin}:${process.env.PATH}`, HOME: process.env.HOME, ...env } });
    return { status: ran.status, out: `${ran.stdout}${ran.stderr}` };
  };
  const escapeRe = (text) => text.replace(/[.*+?^${}()|[\]\\]/gu, "\\$&");
  let ran = deploy(["--check-sfx-guard"]);
  check(ran.status === 1 && /FAIL: no sound source: TI_SFX_SOURCE is not set/u.test(ran.out) && !/PASS/u.test(ran.out), `11: with no sound source the deploy must refuse (exit ${ran.status}): ${ran.out}`);
  ran = deploy(["--check-sfx-guard", "--silent-ok"]);
  check(ran.status === 0 && /^WARNING: SILENT DEPLOY \(--silent-ok\): TI_SFX_SOURCE is not set/mu.test(ran.out) && /^SOUNDS: NONE: no sound source/mu.test(ran.out) && /^PASS: the sound guard lets this deploy build/mu.test(ran.out), `11: --silent-ok without a source must go on with the warning (exit ${ran.status}): ${ran.out}`);
  ran = deploy(["--check-sfx-guard"], { TI_SFX_SOURCE: completeStand });
  check(ran.status === 0 && new RegExp(`^SOUNDS: ${ids} takes for ${ids} of ${ids} sounds, from ${escapeRe(completeStand)}, a folder \\(no commit\\)$`, "mu").test(ran.out) && !/WARNING|FAIL/u.test(ran.out) && /^PASS: the sound guard/mu.test(ran.out), `11: a source with every sound's takes must pass, counting them (exit ${ran.status}): ${ran.out}`);
  ran = deploy(["--check-sfx-guard"], { TI_SFX_SOURCE: gapStand });
  check(ran.status === 1 && new RegExp(`silent: ${gapId}: no takes in the source`, "u").test(ran.out) && /FAIL: the sound source has no takes for the sounds listed above/u.test(ran.out) && !/PASS/u.test(ran.out), `11: a source without one sound's takes must refuse, naming it (exit ${ran.status}): ${ran.out}`);
  ran = deploy(["--check-sfx-guard", "--silent-ok"], { TI_SFX_SOURCE: gapStand });
  check(ran.status === 0 && /^WARNING: PARTLY SILENT DEPLOY \(--silent-ok\)/mu.test(ran.out) && new RegExp(`^SOUNDS: .*; SILENT \\(--silent-ok\\): (.*, )?${gapId}(,|$)`, "mu").test(ran.out) && /^PASS: the sound guard/mu.test(ran.out), `11: --silent-ok with a source missing one sound must go on, warning and naming it (exit ${ran.status}): ${ran.out}`);
  ran = deploy(["--check-sfx-guard", "--silent-ok"], { TI_SFX_SOURCE: join(work, "no-such-folder") });
  check(ran.status === 1 && /FAIL: the sound fetch failed \(tools\/fetch-sfx exited 1\)/u.test(ran.out) && !/PASS/u.test(ran.out), `11: a source that fails must stop the deploy even with --silent-ok (exit ${ran.status}): ${ran.out}`);
  ran = deploy(["--check-sfx-guard", "--dry-run"]);
  check(ran.status === 2 && /usage:/u.test(ran.out), `11: --check-sfx-guard takes only --silent-ok (exit ${ran.status}): ${ran.out}`);
  check(!existsSync(gitCalls), `11: --check-sfx-guard must never run git: ${existsSync(gitCalls) ? readFileSync(gitCalls, "utf8") : ""}`);
} finally {
  rmSync(work, { recursive: true, force: true });
}

if (failures.length > 0) {
  for (const failure of failures) console.log(`FAIL: ${failure}`);
  process.exit(1);
}
console.log("PASS: tools/fetch-sfx does nothing without a source; from a folder or a Git repository it copies the game's sounds' takes only, in the manifest's order, with their gains and loops, silent where a row or take is missing; it repeats without change, removes only its own stale takes, finds takes by the sheet's patterns without a manifest, never prints a token, refuses a linked folder, a missing source and one inside the project, never writes through a link in the folder, and runs as the Mac build workflow runs it (empty variables do nothing; a repository holding the takes at its root fills the folder; a credentialed URL never shows its user or password, and git's tracing never shows the token's header); --require-all exits 3, changing nothing and naming each sound, when there is no source or a sound has no takes, and --result records the outcome with a Git source's full commit; tools/deploy-web.sh's sound guard refuses no source and a source missing a sound, goes on with a warning under --silent-ok, stops on a failed fetch even then, and never runs git");
