#!/usr/bin/env node
// Checks tools/fetch-sfx offline, in temporary folders (no Godot, no network):
//   1. without a source it does nothing, and leaves the sound folder as it is;
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
//      even to the same bytes, is replaced by a plain copy.
// A few seconds. Part of tools/test.sh.
//
//   node tools/check_fetch_sfx.mjs

import { spawnSync } from "node:child_process";
import { existsSync, lstatSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, rmSync, statSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

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

function run(args, env = {}) {
  const result = spawnSync(process.execPath, [TOOL, ...args], { encoding: "utf8", env: { PATH: process.env.PATH, HOME: process.env.HOME, ...env } });
  return { status: result.status, out: `${result.stdout}${result.stderr}` };
}

function listing(folder) {
  return existsSync(folder) ? readdirSync(folder).sort() : [];
}

function manifestOf(project) {
  return JSON.parse(readFileSync(join(project, "game/resources/audio/sfx/sfx.json"), "utf8"));
}

// A project: the game's catalog (a two-take sound, a loop, a sound named by another
// row, one whose row the sheet lacks), the sheet, the sound folder with its README.
function makeProject(name) {
  const project = join(work, name);
  write(join(project, "project.godot"), "config_version=5\n");
  write(join(project, "game/resources/audio/sounds.json"), JSON.stringify({
    sounds: {
      step: { space: "3d" },
      hum_loop: { loop: true },
      knock: { row: "door_knock" },
      future: {},
    },
  }));
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
  check(result.status === 0 && /nothing fetched/u.test(result.out) && listing(sfx).join() === "README.md", `1: with no source it must do nothing (exit ${result.status}, folder ${listing(sfx)}): ${result.out}`);

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
} finally {
  rmSync(work, { recursive: true, force: true });
}

if (failures.length > 0) {
  for (const failure of failures) console.log(`FAIL: ${failure}`);
  process.exit(1);
}
console.log("PASS: tools/fetch-sfx does nothing without a source; from a folder or a Git repository it copies the game's sounds' takes only, in the manifest's order, with their gains and loops, silent where a row or take is missing; it repeats without change, removes only its own stale takes, finds takes by the sheet's patterns without a manifest, never prints a token, refuses a linked folder, a missing source and one inside the project, and never writes through a link in the folder");
