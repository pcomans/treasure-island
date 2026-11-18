// tools/web_trace/gl_buffers.cjs: what one GL buffer costs the browser's processes, on a Mac, in Playwright's own
// WebKit. For each case (N buffers of S bytes) it opens tools/web_trace/gl_buffers.html in a fresh page, records
// `footprint -f bytes` of this session's web process and GPU process (no sudo: Playwright's WebKit is not hardened),
// makes the buffers (each drawn from once, then gl.finish), waits, records again, and prints the difference by
// category. Not part of the game.
//   OUT=<dir> PW_MODULE=<node_modules>/playwright node tools/web_trace/gl_buffers.cjs [N:S ...]
// Default cases: 20000:200 20000:4096 20000:16384 4:1048576 43000:5120. A case mesh:N:V:LAYOUT instead makes N meshes
// of V vertices in Godot's Compatibility layout (gl_buffers.html makeMeshes: LAYOUT normal, normals without tangents,
// read with a stride of 4; tangent, with a stride of 8), records the footprint once they are made and again once
// each has been drawn once. A case sized:N:S:KIND makes N STATIC_DRAW buffers of S bytes (KIND array: vertex buffers;
// element: index buffers), each drawn once from a vertex array of its own in Godot's layout with tangents
// (gl_buffers.html makeSized), and records the footprint after. Writes OUT/gl-buffers.json.
'use strict';
const fs = require('fs');
const path = require('path');
const {execFileSync} = require('child_process');
const pw = require(process.env.PW_MODULE || 'playwright');

const OUT = process.env.OUT;
if (!OUT || process.platform !== 'darwin') { console.error('usage: OUT=<dir> on a Mac'); process.exit(2); }
const CASES = (process.argv.slice(2).length ? process.argv.slice(2) : ['20000:200', '20000:4096', '20000:16384', '4:1048576', '43000:5120'])
  .map((c) => (/^(mesh|sized):/.test(c) ? c.split(':') : c.split(':').map(Number)));
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const log = (...a) => { const line = a.join(' '); console.log(line); fs.appendFileSync(OUT + '/progress.txt', line + '\n'); };

// This session's processes: only while exactly one Playwright WebKit browser runs from its folder.
function processes() {
  const folder = path.dirname(pw.webkit.executablePath());
  const ps = execFileSync('ps', ['-axww', '-o', 'pid=,rss=,command='], {encoding: 'utf8'});
  const procs = ps.split('\n').map((l) => l.trim().match(/^(\d+)\s+(\d+)\s+(.*)$/)).filter(Boolean).map((m) => ({pid: +m[1], rss: +m[2], cmd: m[3]}));
  const mine = procs.filter((p) => p.cmd.startsWith(folder + '/'));
  const browsers = mine.filter((p) => /\/Contents\/MacOS\/Playwright(\s|$)/.test(p.cmd));
  if (browsers.length !== 1) throw new Error(`${browsers.length} Playwright WebKit browsers from ${folder} are running, not this one alone`);
  // The newest web process (each case's page is opened in a fresh context) and the GPU process.
  const newest = (re) => mine.filter((p) => re.test(p.cmd)).sort((a, b) => b.pid - a.pid)[0] || null;
  return {web: newest(/com\.apple\.WebKit\.WebContent/), gpu: newest(/com\.apple\.WebKit\.GPU/)};
}

// A process's footprint: its total and each category's dirty bytes.
function footprint(pid) {
  const text = execFileSync('footprint', ['-f', 'bytes', String(pid)], {encoding: 'utf8', timeout: 120000});
  const total = +((text.match(/Footprint:\s*(\d+) B/) || [0, 0])[1]);
  const categories = {};
  for (const m of text.matchAll(/^\s*(\d+) B\s+\d+ B\s+\d+ B\s+(\d+)\s+(.+?)\s*$/gm)) categories[m[3]] = {bytes: +m[1], regions: +m[2]};
  return {total, categories};
}
const diff = (before, after) => {
  const out = {total: after.total - before.total};
  for (const name of new Set([...Object.keys(before.categories), ...Object.keys(after.categories)])) {
    const d = ((after.categories[name] || {}).bytes || 0) - ((before.categories[name] || {}).bytes || 0);
    const r = ((after.categories[name] || {}).regions || 0) - ((before.categories[name] || {}).regions || 0);
    if (Math.abs(d) >= 1048576) out[name] = {bytes: d, regions: r};
  }
  return out;
};

async function main() {
  fs.mkdirSync(OUT, {recursive: true});
  const browser = await pw.webkit.launch({headless: false});
  const results = [];
  try {
    for (const c of CASES) {
      const context = await browser.newContext({viewport: {width: 400, height: 300}});
      const page = await context.newPage();
      await page.goto('file://' + path.join(__dirname, 'gl_buffers.html'));
      if (!(await page.evaluate('window.ready()'))) throw new Error('no WebGL2');
      await sleep(2000);
      const procs = processes();
      const measure = () => ({web: footprint(procs.web.pid), gpu: procs.gpu ? footprint(procs.gpu.pid) : null});
      const change = (a, b) => ({web: diff(a.web, b.web), gpu: a.gpu ? diff(a.gpu, b.gpu) : null});
      const before = measure();
      let result;
      if (c[0] === 'mesh') {
        const [, count, vertices, layout] = c;
        const made = await page.evaluate(`window.makeMeshes(${+count}, ${+vertices}, ${JSON.stringify(layout)})`);
        await sleep(3000);
        const afterMade = measure();
        const drawn = await page.evaluate('window.drawMeshes()');
        await sleep(3000);
        const afterDrawn = measure();
        result = {meshes: +count, vertices: +vertices, layout, made, drawn, web_pid: procs.web.pid, gpu_pid: procs.gpu ? procs.gpu.pid : null,
          made_change: change(before, afterMade), drawn_change: change(afterMade, afterDrawn)};
      } else if (c[0] === 'sized') {
        const [, count, size, kind] = c;
        const made = await page.evaluate(`window.makeSized(${+count}, ${+size}, ${JSON.stringify(kind)})`);
        await sleep(3000);
        result = {buffers: +count, size: +size, kind, bytes: +count * +size, made, web_pid: procs.web.pid, gpu_pid: procs.gpu ? procs.gpu.pid : null, ...change(before, measure())};
      } else {
        const [n, size] = c;
        const made = await page.evaluate(`window.makeBuffers(${n}, ${size})`);
        await sleep(3000);
        const after = measure();
        result = {buffers: n, size, bytes: n * size, made, web_pid: procs.web.pid, gpu_pid: procs.gpu ? procs.gpu.pid : null, ...change(before, after)};
      }
      results.push(result);
      log('CASE', JSON.stringify(result));
      await context.close();
      await sleep(2000);
    }
  } finally {
    await browser.close();
  }
  fs.writeFileSync(OUT + '/gl-buffers.json', JSON.stringify(results, null, 1));
}
main().then(() => process.exit(0), (e) => { log('ERROR', String(e && e.stack || e).slice(0, 1000)); process.exit(1); });
