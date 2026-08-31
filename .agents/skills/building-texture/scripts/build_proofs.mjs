#!/usr/bin/env node

import { createHash } from "node:crypto";
import { execFileSync, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, readdirSync, statSync, writeFileSync } from "node:fs";
import { basename, join, resolve } from "node:path";

const SCRIPT_VERSION = "1.0.0";
const EDGE_THRESHOLDS = Object.freeze({ mae: 0.03, rmse: 0.06 });

function fail(message) {
  process.stderr.write(`building-texture proof error: ${message}\n`);
  process.exit(2);
}

function sha256(path) {
  return createHash("sha256").update(readFileSync(path)).digest("hex");
}

function magick(args) {
  try {
    return execFileSync("magick", args, { encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] }).trim();
  } catch (error) {
    const detail = String(error.stderr || error.message || error).trim();
    fail(`ImageMagick command failed: magick ${args.join(" ")}\n${detail}`);
  }
}

function identify(path) {
  const raw = magick(["identify", "-format", "%w\t%h\t%[colorspace]\t%[channels]", path]);
  const [widthText, heightText, colorspace, channels] = raw.split("\t");
  const width = Number(widthText);
  const height = Number(heightText);
  if (!Number.isInteger(width) || !Number.isInteger(height) || width < 2 || height < 2) {
    fail(`input must be a raster image at least 2x2 pixels; identify returned ${raw}`);
  }
  return { width, height, colorspace, channels };
}

function compareMetric(metric, first, second) {
  const result = spawnSync("magick", ["compare", "-metric", metric, first, second, "null:"], {
    encoding: "utf8",
  });
  if (![0, 1].includes(result.status)) {
    fail(`ImageMagick compare failed for ${metric}: ${String(result.stderr || result.stdout).trim()}`);
  }
  const raw = `${result.stderr || ""} ${result.stdout || ""}`.trim();
  const normalizedMatch = raw.match(/\(([-+0-9.eE]+)\)/);
  const fallbackMatch = raw.match(/[-+0-9.eE]+/);
  const value = Number(normalizedMatch?.[1] ?? fallbackMatch?.[0]);
  if (!Number.isFinite(value)) {
    fail(`could not parse normalized ${metric} from ImageMagick output: ${raw}`);
  }
  return value;
}

function proofRecord(outputDir, filename, dimensions) {
  const path = join(outputDir, filename);
  return { file: filename, dimensions, sha256: sha256(path) };
}

if (process.argv.length !== 4) {
  fail("usage: node build_proofs.mjs <input-tile> <new-or-empty-output-dir>");
}

const inputPath = resolve(process.argv[2]);
const outputDir = resolve(process.argv[3]);

if (!existsSync(inputPath) || !statSync(inputPath).isFile()) {
  fail(`input tile is not a readable file: ${inputPath}`);
}
if (existsSync(outputDir)) {
  if (!statSync(outputDir).isDirectory()) fail(`output path is not a directory: ${outputDir}`);
  if (readdirSync(outputDir).length !== 0) fail(`output directory must be empty: ${outputDir}`);
} else {
  mkdirSync(outputDir, { recursive: true });
}

try {
  execFileSync("magick", ["-version"], { stdio: "ignore" });
} catch {
  fail("ImageMagick 7 executable `magick` is required");
}

const sourceInfo = identify(inputPath);
const normalizedName = "input-srgb-rgb.png";
const normalizedPath = join(outputDir, normalizedName);
magick([inputPath, "-auto-orient", "-alpha", "off", "-colorspace", "sRGB", "-strip", `PNG24:${normalizedPath}`]);
const { width, height, colorspace, channels } = identify(normalizedPath);

const edgeFiles = {
  left: join(outputDir, "edge-left.png"),
  right: join(outputDir, "edge-right.png"),
  top: join(outputDir, "edge-top.png"),
  bottom: join(outputDir, "edge-bottom.png"),
};
magick([normalizedPath, "-crop", `1x${height}+0+0`, "+repage", "-strip", edgeFiles.left]);
magick([normalizedPath, "-crop", `1x${height}+${width - 1}+0`, "+repage", "-strip", edgeFiles.right]);
magick([normalizedPath, "-crop", `${width}x1+0+0`, "+repage", "-strip", edgeFiles.top]);
magick([normalizedPath, "-crop", `${width}x1+0+${height - 1}`, "+repage", "-strip", edgeFiles.bottom]);

const edgeMetrics = {
  x: {
    mae: compareMetric("MAE", edgeFiles.left, edgeFiles.right),
    rmse: compareMetric("RMSE", edgeFiles.left, edgeFiles.right),
  },
  y: {
    mae: compareMetric("MAE", edgeFiles.top, edgeFiles.bottom),
    rmse: compareMetric("RMSE", edgeFiles.top, edgeFiles.bottom),
  },
};
for (const axis of ["x", "y"]) {
  edgeMetrics[axis].verdict = edgeMetrics[axis].mae <= EDGE_THRESHOLDS.mae && edgeMetrics[axis].rmse <= EDGE_THRESHOLDS.rmse
    ? "pass_candidate_screen"
    : "fail";
}
const numericPass = edgeMetrics.x.verdict === "pass_candidate_screen" && edgeMetrics.y.verdict === "pass_candidate_screen";

const repeat3Name = "repeat-3x3-borderless.png";
const repeat3Path = join(outputDir, repeat3Name);
magick(["-size", `${width * 3}x${height * 3}`, `tile:${normalizedPath}`, "-strip", repeat3Path]);

const overlayName = "repeat-3x3-boundary-overlay.png";
const overlayPath = join(outputDir, overlayName);
const lineWidth = Math.max(2, Math.round(Math.min(width, height) / 512));
magick([
  repeat3Path,
  "-fill", "none",
  "-stroke", "rgba(255,0,255,0.9)",
  "-strokewidth", String(lineWidth),
  "-draw", `line ${width},0 ${width},${height * 3 - 1} line ${width * 2},0 ${width * 2},${height * 3 - 1} line 0,${height} ${width * 3 - 1},${height} line 0,${height * 2} ${width * 3 - 1},${height * 2}`,
  "-strip", overlayPath,
]);

const rollSpecs = [
  ["roll-half-x.png", Math.floor(width / 2), 0],
  ["roll-half-y.png", 0, Math.floor(height / 2)],
  ["roll-half-xy.png", Math.floor(width / 2), Math.floor(height / 2)],
];
for (const [filename, x, y] of rollSpecs) {
  magick([normalizedPath, "-roll", `+${x}+${y}`, "-strip", join(outputDir, filename)]);
}

const macroCellName = "macro-cell.png";
const macroCellPath = join(outputDir, macroCellName);
magick([normalizedPath, "-filter", "Lanczos", "-resize", "256x256>", "-strip", macroCellPath]);
const macroCellInfo = identify(macroCellPath);
const macroName = "repeat-8x8-macro.png";
const macroPath = join(outputDir, macroName);
magick(["-size", `${macroCellInfo.width * 8}x${macroCellInfo.height * 8}`, `tile:${macroCellPath}`, "-strip", macroPath]);

const magickVersion = magick(["-version"]).split("\n")[0];
const report = {
  schema_version: "codex.building-texture-proof/1",
  script_version: SCRIPT_VERSION,
  image_magick: magickVersion,
  input: {
    path: inputPath,
    filename: basename(inputPath),
    sha256: sha256(inputPath),
    dimensions: { width: sourceInfo.width, height: sourceInfo.height },
    colorspace: sourceInfo.colorspace,
    channels: sourceInfo.channels,
  },
  normalized_input: {
    file: normalizedName,
    sha256: sha256(normalizedPath),
    dimensions: { width, height },
    colorspace,
    channels,
  },
  numeric_edge_screen: {
    method: "Opposite 1-pixel edges of stripped sRGB RGB input; normalized ImageMagick MAE and RMSE",
    thresholds: EDGE_THRESHOLDS,
    x_left_right: edgeMetrics.x,
    y_top_bottom: edgeMetrics.y,
    verdict: numericPass ? "pass_candidate_screen" : "fail",
    acceptance_scope: "Candidate rejection screen only; numeric pass is never semantic or overall acceptance.",
  },
  proofs: {
    borderless_3x3: proofRecord(outputDir, repeat3Name, { width: width * 3, height: height * 3 }),
    boundary_overlay_3x3: proofRecord(outputDir, overlayName, { width: width * 3, height: height * 3 }),
    half_x_roll: proofRecord(outputDir, "roll-half-x.png", { width, height }),
    half_y_roll: proofRecord(outputDir, "roll-half-y.png", { width, height }),
    half_xy_roll: proofRecord(outputDir, "roll-half-xy.png", { width, height }),
    macro_repeat_8x8: proofRecord(outputDir, macroName, { width: macroCellInfo.width * 8, height: macroCellInfo.height * 8 }),
  },
  semantic_repeat_review: {
    verdict: "unreviewed",
    required: "Compare every boundary motif with the predeclared grammar; fail any new, resized, duplicated, or deleted motif.",
  },
  art_review: { verdict: "unreviewed" },
  godot_receiver_review: { verdict: "unreviewed" },
  overall_acceptance: {
    verdict: "not_accepted",
    reason: "Mechanical proof generation cannot accept a building texture; semantic, absolute art, and exact-receiver reviews remain required.",
  },
};

writeFileSync(join(outputDir, "proof-report.json"), `${JSON.stringify(report, null, 2)}\n`);
const markdown = `# Building texture proof report

- Input: \`${report.input.filename}\` (${width} × ${height}, SHA-256 \`${report.input.sha256}\`)
- X edge: MAE \`${edgeMetrics.x.mae}\`, RMSE \`${edgeMetrics.x.rmse}\` — **${edgeMetrics.x.verdict}**
- Y edge: MAE \`${edgeMetrics.y.mae}\`, RMSE \`${edgeMetrics.y.rmse}\` — **${edgeMetrics.y.verdict}**
- Numeric candidate screen: **${report.numeric_edge_screen.verdict}**
- Semantic repeat verdict: **unreviewed**
- Art verdict: **unreviewed**
- Exact Godot receiver verdict: **unreviewed**
- Overall acceptance: **not accepted**

Numeric edge metrics may reject a candidate, but they can never accept one. Inspect the 3×3, boundary overlay, circular rolls, and macro repeat against a predeclared motif grammar, then review the exact Godot receiver at ordinary gameplay distance.
`;
writeFileSync(join(outputDir, "PROOF_REPORT.md"), markdown);

process.stdout.write(`Proof evidence: ${outputDir}\n`);
process.stdout.write(`Numeric candidate screen: ${report.numeric_edge_screen.verdict}\n`);
process.stdout.write("Semantic repeat verdict: unreviewed\n");
process.stdout.write("Overall acceptance: not accepted\n");
