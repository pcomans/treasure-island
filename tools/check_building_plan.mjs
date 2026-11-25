#!/usr/bin/env node
// Checks tools/building-plan (tools/building_plan.mjs) on the frozen map data and
// the generated world, writing only to a temporary folder it removes:
//   - on a small building (the smallest standing catalog way the generator did
//     not cut, chosen by rule so the check follows the world) it writes
//     plan.svg, plan.md and, where ImageMagick's magick is on PATH, plan.png. The
//     SVG is well formed, its size matches its viewBox and every number in it is
//     finite; its x and z rulers keep one scale; the generated outline drawn in
//     it spans the roof mesh's own extent, read here from the generated record;
//     plan.md's area and extent are the roof mesh's, measured here as well; and
//     the map way and the generated outline sit in one frame: at least 95 % of
//     the way's edge lies on the outline, and the outline follows the way for
//     at least 95 % of its length (a map read shifted or mirrored fails here);
//   - a second run writes the same files, byte for byte;
//   - on Building 1 (r16681702) the map facts behind its hall front standing
//     4.4 m too far forward are flagged from geometry alone: two untagged outer
//     members joined into one outline, and w34313541 a thin strip along the
//     other; and every part of the generated outline follows a member's edge;
//   - it refuses an --out inside the repository, a key the snapshot lacks and a
//     key that is no building, writing nothing; and no run changes the work tree.
// Node only, a few seconds. Part of tools/test.sh.
//
//   node tools/check_building_plan.mjs
import { spawnSync } from "node:child_process";
import { existsSync, mkdtempSync, readFileSync, readdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const tool = join(root, "tools/building-plan");
const failures = [];
const check = (ok, what) => {
  if (!ok) failures.push(what);
  return ok;
};
const work = mkdtempSync(join(tmpdir(), "ti-check-building-plan-"));
const run = (...args) => spawnSync(tool, args, { cwd: root, encoding: "utf8" });
const treeState = () => spawnSync("git", ["status", "--porcelain", "--untracked-files=all"], { cwd: root, encoding: "utf8" }).stdout;
const hasMagick = !spawnSync("magick", ["-version"], { encoding: "utf8" }).error;

// The SVG's elements, attributes and text, read with a small tokenizer: it
// fails on unbalanced or malformed tags and on stray ampersands.
function parseSvg(text) {
  const elements = [];
  const stack = [];
  const body = text.replace(/^<\?xml[^>]*\?>\s*/u, "");
  let position = 0;
  for (const match of body.matchAll(/<(\/?)([a-zA-Z][\w:-]*)((?:\s+[\w:-]+="[^"<]*")*)\s*(\/?)>/gu)) {
    const between = body.slice(position, match.index);
    if (/[<>]/u.test(between)) throw new Error(`malformed markup before offset ${match.index}`);
    if (/&(?!amp;|lt;|gt;|quot;|apos;|#\d+;)/u.test(between)) throw new Error(`stray & before offset ${match.index}`);
    if (stack.length) stack.at(-1).text += between;
    position = match.index + match[0].length;
    const [, closing, name, attributeText, selfClosing] = match;
    if (closing) {
      const open = stack.pop();
      if (!open || open.name !== name) throw new Error(`</${name}> closes ${open ? `<${open.name}>` : "nothing"}`);
      continue;
    }
    const attributes = Object.fromEntries([...attributeText.matchAll(/([\w:-]+)="([^"]*)"/gu)].map((attribute) => [attribute[1], attribute[2]]));
    const element = { name, attributes, text: "" };
    elements.push(element);
    if (!selfClosing) stack.push(element);
  }
  if (stack.length) throw new Error(`<${stack.at(-1).name}> is never closed`);
  if (body.slice(position).trim()) throw new Error("text after the root element");
  return elements;
}

const pathNumbers = (d) => d.split(/[\sMLZ]+/u).filter(Boolean).map(Number);

function roofMesh(key) {
  const logical = JSON.parse(readFileSync(join(root, "generated/world/logical-objects.json"), "utf8")).objects;
  const object = logical.find((candidate) => candidate.logical_object_key === `building:${key}`);
  const roofKey = object.physical_object_keys.find((physical) => physical.endsWith(":roof"));
  const chunk = JSON.parse(readFileSync(join(root, "generated/world/chunks", `${object.chunk_ids[0]}.json`), "utf8"));
  const { vertices, indices } = chunk.records.find((record) => record.object_key === roofKey);
  const xs = vertices.filter((_value, index) => index % 3 === 0);
  const zs = vertices.filter((_value, index) => index % 3 === 2);
  let area = 0;
  for (let index = 0; index < indices.length; index += 3) {
    const [a, b, c] = [indices[index], indices[index + 1], indices[index + 2]].map((vertex) => [vertices[vertex * 3], vertices[vertex * 3 + 2]]);
    area += Math.abs((b[0] - a[0]) * (c[1] - a[1]) - (c[0] - a[0]) * (b[1] - a[1])) / 2;
  }
  return { minX: Math.min(...xs), maxX: Math.max(...xs), minZ: Math.min(...zs), maxZ: Math.max(...zs), area };
}

// The smallest standing catalog way with a generated roof of its own that the
// generator did not cut (its generated area is its map area), so its plan
// should show the way and the generated outline on one line.
function smallBuilding() {
  const catalog = JSON.parse(readFileSync(join(root, "discovery/facades/facade-recognition-catalog.json"), "utf8"));
  const logical = JSON.parse(readFileSync(join(root, "generated/world/logical-objects.json"), "utf8")).objects;
  const sizes = [];
  for (const unit of catalog.units) {
    const key = unit.anchor_source_key;
    if (unit.demolition || !key.startsWith("w")) continue;
    const object = logical.find((candidate) => candidate.logical_object_key === `building:${key}`);
    if (!object?.physical_object_keys.some((physical) => physical.endsWith(":roof"))) continue;
    const measure = object.source_geometry.find((entry) => entry.source_key === key);
    if (Math.abs(measure.source_measure - measure.clipped_measure) > 0.01) continue;
    sizes.push([measure.clipped_measure, key]);
  }
  sizes.sort((a, b) => a[0] - b[0] || a[1].localeCompare(b[1]));
  return sizes[0]?.[1];
}

// The plan.md line that says which members the generated outline follows.
const outlineFollows = (markdown) => /^- The generated outline \(([\d.]+) m\) follows (.*)\.$/mu.exec(markdown);

try {
  const before = treeState();

  // 1. A small building: files, a well-formed SVG drawn to scale, plan.md's measures.
  const key = smallBuilding();
  if (check(key != null, "no standing catalog building with a generated roof")) {
    const first = join(work, "first");
    const ran = run(key, "--out", first);
    check(ran.status === 0, `${key}: exit ${ran.status}: ${ran.stderr.trim()}`);
    const expected = ["plan.md", "plan.svg", ...(hasMagick ? ["plan.png"] : [])].sort();
    const written = existsSync(first) ? readdirSync(first).sort() : [];
    check(JSON.stringify(written) === JSON.stringify(expected), `${key}: wrote ${written.join(", ") || "nothing"}, expected ${expected.join(", ")}`);
    if (!hasMagick) check(/^NOTE: no plan\.png/mu.test(ran.stdout), `${key}: without magick the tool must say it wrote no plan.png`);
    const mesh = roofMesh(key);
    if (written.includes("plan.svg")) {
      const svgText = readFileSync(join(first, "plan.svg"), "utf8");
      let elements = [];
      try {
        elements = parseSvg(svgText);
      } catch (error) {
        check(false, `${key}: plan.svg is not well formed: ${error.message}`);
      }
      const svg = elements[0];
      if (check(svg?.name === "svg" && svg.attributes.xmlns === "http://www.w3.org/2000/svg", `${key}: plan.svg's root is not an SVG element`)) {
        const { width, height, viewBox } = svg.attributes;
        check(viewBox === `0 0 ${width} ${height}` && Number(width) > 0 && Number(height) > 0, `${key}: plan.svg's size ${width} x ${height} does not match its viewBox ${viewBox}`);
        const numbers = elements.flatMap((element) => [
          ...["x", "y", "cx", "cy", "r", "width", "height", "stroke-width", "font-size"].filter((name) => element.attributes[name] != null).map((name) => Number(element.attributes[name])),
          ...(element.attributes.d ? pathNumbers(element.attributes.d) : []),
        ]);
        check(numbers.length > 0 && numbers.every(Number.isFinite), `${key}: plan.svg holds a number that is not finite`);
        // The rulers: labels every 10 m at one scale on both axes. Each label
        // names its metres and its tick's pixel.
        const ruler = (name) => elements.filter((element) => element.name === "text" && element.attributes.class === name)
          .map((element) => ({ value: Number(element.attributes["data-metres"]), at: Number(element.attributes["data-px"]), text: element.text }))
          .filter((label, index, all) => all.findIndex((other) => other.value === label.value) === index)
          .sort((a, b) => a.value - b.value);
        const xs = ruler("ruler-x");
        const zs = ruler("ruler-z");
        check([...xs, ...zs].every((label) => Number(label.text) === label.value && Number.isFinite(label.at)), `${key}: a ruler label's text, metres or pixel is wrong`);
        if (check(xs.length >= 2 && zs.length >= 2, `${key}: plan.svg lacks its rulers (${xs.length} x and ${zs.length} z labels)`)) {
          const scale = (xs.at(-1).at - xs[0].at) / (xs.at(-1).value - xs[0].value);
          const zScale = (zs.at(-1).at - zs[0].at) / (zs.at(-1).value - zs[0].value);
          check(xs.every((label, index) => index === 0 || label.value - xs[index - 1].value === 10) && zs.every((label, index) => index === 0 || label.value - zs[index - 1].value === 10), `${key}: ruler labels are not every 10 m`);
          check(scale > 0 && Math.abs(scale - zScale) < 0.01, `${key}: the x scale ${scale} and z scale ${zScale} px per metre differ`);
          // The generated outline lies where the roof mesh is, to a hundredth of a pixel's rounding.
          const outline = elements.filter((element) => element.attributes.class === "generated-outline").flatMap((element) => pathNumbers(element.attributes.d));
          if (check(outline.length >= 6, `${key}: plan.svg draws no generated outline`)) {
            const toX = (px) => xs[0].value + (px - xs[0].at) / scale;
            const toZ = (py) => zs[0].value + (py - zs[0].at) / zScale;
            const drawn = {
              minX: toX(Math.min(...outline.filter((_value, index) => index % 2 === 0))),
              maxX: toX(Math.max(...outline.filter((_value, index) => index % 2 === 0))),
              minZ: toZ(Math.min(...outline.filter((_value, index) => index % 2 === 1))),
              maxZ: toZ(Math.max(...outline.filter((_value, index) => index % 2 === 1))),
            };
            const off = Math.max(...["minX", "maxX", "minZ", "maxZ"].map((side) => Math.abs(drawn[side] - mesh[side])));
            check(off <= 0.02, `${key}: the drawn generated outline is ${off.toFixed(3)} m off the roof mesh's extent (${JSON.stringify(drawn)} against ${JSON.stringify(mesh)})`);
          }
        }
      }
    }
    if (written.includes("plan.md")) {
      const markdown = readFileSync(join(first, "plan.md"), "utf8");
      const area = /^\| area \| ([\d.]+) m² traced from the roof mesh/mu.exec(markdown);
      const extent = /\(x (-?[\d.]+) to (-?[\d.]+), z (-?[\d.]+) to (-?[\d.]+)\)/u.exec(markdown);
      if (check(area && extent, `${key}: plan.md gives no area or extent for the generated outline`)) {
        check(Math.abs(Number(area[1]) - mesh.area) <= 0.01 + 1e-5 * mesh.area, `${key}: plan.md's area ${area[1]} m² is not the roof mesh's ${mesh.area.toFixed(3)} m²`);
        const [minX, maxX, minZ, maxZ] = extent.slice(1).map(Number);
        check([minX - mesh.minX, maxX - mesh.maxX, minZ - mesh.minZ, maxZ - mesh.maxZ].every((difference) => Math.abs(difference) <= 0.006), `${key}: plan.md's extent x ${minX} to ${maxX}, z ${minZ} to ${maxZ} is not the roof mesh's`);
      }
      check(/^## Flags worth a look against photos$/mu.test(markdown) && /^## What the map data cannot give$/mu.test(markdown), `${key}: plan.md lacks its flags or limits section`);
      // The map way and the generated outline in one frame: the way's edge lies
      // on the outline, and the outline follows the way.
      const edge = /^- A \S+ \([^)]*\): .*its edge runs ([\d.]+) m on the outline, ([\d.]+) m inside it and ([\d.]+) m outside it\./mu.exec(markdown);
      const follows = outlineFollows(markdown);
      if (check(edge && follows, `${key}: plan.md does not say how the way's edge and the generated outline meet`)) {
        const [on, inside, outside] = edge.slice(1).map(Number);
        const total = on + inside + outside;
        check(total > 0 && on >= 0.95 * total, `${key}: only ${on} of the way's ${total.toFixed(1)} m of edge lies on the generated outline (${inside} m inside, ${outside} m outside): the map and the generated world are not drawn in one frame`);
        const perimeter = Number(follows[1]);
        const alongWay = Number(/(?:^|, )A for ([\d.]+) m/u.exec(follows[2])?.[1] ?? 0);
        check(alongWay >= 0.95 * perimeter, `${key}: the generated outline (${perimeter} m) follows the way for only ${alongWay} m (${follows[2]})`);
      }
    }
    if (written.includes("plan.png")) {
      const png = readFileSync(join(first, "plan.png"));
      const svgSize = /width="(\d+)" height="(\d+)"/u.exec(readFileSync(join(first, "plan.svg"), "utf8"));
      check(png.subarray(1, 4).toString() === "PNG" && png.readUInt32BE(16) === Number(svgSize?.[1]) && png.readUInt32BE(20) === Number(svgSize?.[2]), `${key}: plan.png is not a PNG of the SVG's size`);
    }

    // 2. The same sources give the same files.
    const second = join(work, "second");
    run(key, "--out", second);
    for (const file of written) {
      check(existsSync(join(second, file)) && readFileSync(join(first, file)).equals(readFileSync(join(second, file))), `${key}: a second run wrote a different ${file}`);
    }
  }

  // 3. Building 1: the joined canopy strip, flagged from geometry alone.
  const building1 = join(work, "r16681702");
  const ran = run("r16681702", "--out", building1);
  if (check(ran.status === 0, `r16681702: exit ${ran.status}: ${ran.stderr.trim()}`)) {
    const markdown = readFileSync(join(building1, "plan.md"), "utf8");
    check(/\| A \| w1169707889 \| outer \| untagged \|/u.test(markdown) && /\| B \| w34313541 \| outer \| untagged \|/u.test(markdown) && /\| C \| w1222720021 \| inner \|/u.test(markdown), "r16681702: plan.md does not list the two untagged outer members and the inner one");
    check(/^\d+\. The relation has 2 outer members, which the generator joins into one outline/mu.test(markdown), "r16681702: the two outer members joined into one outline are not flagged");
    check(/^\d+\. B w34313541 \(outer\) is a thin strip: greatest width [0-5]\.\d+ m.*it lies along A w1169707889/mu.test(markdown), "r16681702: w34313541 is not flagged as a thin strip along w1169707889");
    check(!/not a wall/u.test(markdown), "r16681702: a flag must not say a member is not a wall");
    const follows = outlineFollows(markdown);
    check(follows && !follows[2].includes("no member's edge"), `r16681702: the generated outline follows no member's edge somewhere (${follows?.[2] ?? "no such line in plan.md"}): the members and the generated world are not drawn in one frame`);
  }

  // 4. Refusals, writing nothing.
  const inside = join(root, "generated", "building-plan-check-must-not-exist");
  const refused = run("w34313525", "--out", inside);
  check(refused.status === 2 && /inside the repository/u.test(refused.stderr) && !existsSync(inside), `an --out inside the repository must be refused (exit ${refused.status}): ${refused.stderr.trim()}`);
  const missing = run("w1", "--out", join(work, "missing"));
  check(missing.status === 2 && /not in the frozen map snapshot/u.test(missing.stderr) && !existsSync(join(work, "missing")), `a key missing from the snapshot must be refused (exit ${missing.status}): ${missing.stderr.trim()}`);
  const road = run("w8920838", "--out", join(work, "road"));
  check(road.status === 2 && /not a building/u.test(road.stderr) && !existsSync(join(work, "road")), `a key that is no building must be refused (exit ${road.status}): ${road.stderr.trim()}`);

  check(treeState() === before, "a run changed the work tree (git status differs)");
} finally {
  rmSync(work, { recursive: true, force: true });
}

if (failures.length) {
  for (const failure of failures) console.log(`FAIL: ${failure}`);
  process.exit(1);
}
console.log(`PASS: tools/building-plan draws a building's plan from the frozen map data: a well-formed SVG${hasMagick ? " and PNG" : ""} to scale, its generated outline on the roof mesh's extent, plan.md's area and extent the roof mesh's, the map way on the generated outline (one frame), the same files on a second run; on Building 1 the two untagged outer members joined into one outline and w34313541 a thin strip along the other are flagged, and the generated outline follows a member's edge everywhere; an --out in the repository, a missing key and a road are refused; the work tree is unchanged`);
