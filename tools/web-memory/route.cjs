// tools/web-memory/route.cjs: the driver of webkit-session.sh (which starts it with this environment): one measured
// WebKit session of the web build, driven with Playwright's WebKit (headed GTK MiniBrowser on the session's private
// Weston). It is the Chrome memory study's route (iphone-memory-20261116's play4.sh) ported from agent-browser to
// Playwright, with the same in-page JavaScript: memhook (as an init script, before the page's own scripts),
// page-helper.js (window.__pc: stock keyboard events on the canvas, the pointer-lock shim, aim and the closed-loop
// autopilot), and the game's ?profile_startup=1 readback. The start prompt gets a TRUSTED click
// (Playwright's native input, a user activation, so the browser may start the sound).
// ROUTE full: start prompt; look at the breakwater 45 s; walk to the forecourt sedan, F, drive circles (W+A 18 s,
// 2 s stop) x CIRCLES, F out; jetpack to Pier 1 and back FLIGHTS times; look at the breakwater 60 s.
// ROUTE short: start prompt; look at the breakwater 60 s. ROUTE probe: about:blank checks only (WebGL 2 renderer,
// WebAssembly, AudioContext), no game.
// Env: URL, OUT, ROUTE, HOOK, HELPER, CIRCLES, FLIGHTS, WK_EXEC (Playwright executablePath), PW_MODULE, WK_ARGS (extra
// MiniBrowser arguments, such as --features=+UseGPUProcessForWebGL); JSC_* options reach the web process through the env.
// Writes OUT/labels.jsonl (epoch labels), states.jsonl, readback.log, console.txt, web-*.png, hook-*.json, env.json.
'use strict';
const fs = require('fs');
const {webkit} = require(process.env.PW_MODULE || 'playwright');

const OUT = process.env.OUT; const ROUTE = process.env.ROUTE || 'full'; const URL_ = process.env.URL;
const CIRCLES = +(process.env.CIRCLES || 5); const FLIGHTS = +(process.env.FLIGHTS || 1);
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const now = () => new Date().toISOString();
const log = (...a) => console.log(a.join(' '));
const label = (name) => fs.appendFileSync(OUT + '/labels.jsonl', JSON.stringify({label: name, e: Date.now() / 1000}) + '\n');
let page = null; let browser = null; let crashed = false;

const evalTimed = async (expr, ms = 60000) => {
  let timer;
  try {
    return await Promise.race([page.evaluate(expr), new Promise((_, rej) => { timer = setTimeout(() => rej(new Error('evaluate timeout ' + ms + ' ms')), ms); })]);
  } finally { clearTimeout(timer); }
};
const js = async (name, expr, ms) => {
  try { const r = await evalTimed(expr, ms); return r; }
  catch (e) { const m = 'EVAL_FAILED ' + name + ' ' + String(e).slice(0, 300); log(m); return m; }
};
const STATE = "(() => { window.__tiReadback(); const s = JSON.parse(window.__tiState); return JSON.stringify({ready: s.ready, paused: s.paused, input: s.input, grounded: s.grounded, driving: s.driving, position: s.position, prompt: s.start_prompt, fps: s.graphics && s.graphics.fps, scale: s.graphics && s.graphics.scale, audio: window.__mem && window.__mem.audioState ? window.__mem.audioState() : null}); })()";
const state = async (name) => {
  const r = await js('state-' + name, STATE);
  log('STATE_' + name, String(r).slice(0, 500));
  fs.appendFileSync(OUT + '/states.jsonl', JSON.stringify({name, e: Date.now() / 1000, r}) + '\n');
  try { return JSON.parse(r); } catch (e) { return null; }
};
const shot = async (name) => {
  try { await page.screenshot({path: `${OUT}/web-${name}.png`, timeout: 30000}); log('SCREENSHOT', name, 'ok', `${OUT}/web-${name}.png`); }
  catch (e) { log('SCREENSHOT', name, 'FAILED', String(e).slice(0, 200)); }
};
const dumphook = async (name) => {
  const r = await js('hook-' + name, "window.__mem ? window.__mem.dump() : 'NO_HOOK'", 60000);
  if (typeof r === 'string' && r.startsWith('{')) { fs.writeFileSync(`${OUT}/hook-${name}.json`, r); log('HOOK_DUMP', name, r.length); }
  else log('HOOK_DUMP_FAILED', name, String(r).slice(0, 200));
};
class Fail extends Error {}
const fail = async (msg) => {
  log('PLAY_FAIL', msg);
  if (page && !crashed) { await shot('failure'); await state('failure'); await dumphook('failure'); }
  throw new Fail(msg);
};

const READY_JS = `(() => {
  const marks = {};
  for (const m of performance.getEntriesByType('mark')) if (m.name.startsWith('TI_BOOT:') || m.name.startsWith('TI:')) marks[m.name] = Math.round(m.startTime);
  let state = null;
  if (typeof window.__tiReadback === 'function') { try { window.__tiReadback(); state = JSON.parse(window.__tiState || 'null'); } catch (e) { state = {readback_error: String(e)}; } }
  const status = document.getElementById('status'); const notice = document.getElementById('status-notice');
  return JSON.stringify({href: location.href, readyState: document.readyState, overlay: status ? getComputedStyle(status).visibility : null, notice: notice ? notice.textContent : null, state, marks});
})()`;
const ENV_JS = `(() => { const c = document.createElement('canvas').getContext('webgl2'); const d = c && c.getExtension('WEBGL_debug_renderer_info'); const cv = document.getElementById('canvas');
  return JSON.stringify({renderer: d ? c.getParameter(d.UNMASKED_RENDERER_WEBGL) : null, vendor: d ? c.getParameter(d.UNMASKED_VENDOR_WEBGL) : null, gl_renderer: c ? c.getParameter(c.RENDERER) : null, gl_version: c ? c.getParameter(c.VERSION) : null,
    dpr: window.devicePixelRatio, canvas: cv ? [cv.width, cv.height] : null, css: cv ? [cv.clientWidth, cv.clientHeight] : null, ua: navigator.userAgent, wasm_mb: window.__mem && window.__mem.wasm ? window.__mem.wasm.buffer.byteLength / 1048576 : null,
    memDesc: window.__mem ? window.__mem.memDesc || null : null, memExport: window.__mem ? window.__mem.memExport || null : null, performance_memory: typeof performance.memory, measureUASM: typeof performance.measureUserAgentSpecificMemory, deviceMemory: navigator.deviceMemory ?? null,
    page_ext: window.__mem && window.__mem.gl ? (window.__mem.gl.extensions || []).filter((e) => /compress/i.test(e)) : null, audio: window.__mem && window.__mem.audioState ? window.__mem.audioState() : null}); })()`;

async function waitReady(deadlineS) {
  const t0 = Date.now(); let last = '';
  for (;;) {
    if (crashed) return 'crash';
    let line;
    try {
      const r = JSON.parse(await evalTimed(READY_JS, 20000));
      fs.appendFileSync(OUT + '/readback.log', new Date().toISOString().slice(11, 19) + ' ' + JSON.stringify(r) + '\n');
      const ready = !!(r.state && r.state.ready); const play = r.marks['TI_BOOT:play_ready'];
      line = `STATE ready=${ready} overlay=${r.overlay} play_ready_mark=${play ?? 'none'} notice=${r.notice || ''}`;
      if (r.marks['TI_BOOT:failed'] !== undefined) { log('PAGE_FAILED', r.notice); return 'failed'; }
      if (ready && play !== undefined && r.overlay === 'hidden') { log('READY', now().slice(11, 19), JSON.stringify(r.marks)); return 'ready'; }
    } catch (e) { line = 'POLL ' + String(e).slice(0, 160); }
    if (line !== last) { log(now().slice(11, 19), line); last = line; }
    if ((Date.now() - t0) / 1000 > deadlineS) { log('DEADLINE', line); return 'deadline'; }
    await sleep(3000);
  }
}

async function main() {
  log('START', now(), 'route=' + ROUTE, 'url=' + URL_, 'circles=' + CIRCLES, 'flights=' + FLIGHTS);
  label('launch');
  const args = (process.env.WK_ARGS || '').split(' ').filter(Boolean);
  browser = await webkit.launch({headless: false, executablePath: process.env.WK_EXEC, timeout: 60000, env: {...process.env}, args});
  log('LAUNCH_ARGS', JSON.stringify(args), 'JSC env', JSON.stringify(Object.fromEntries(Object.entries(process.env).filter(([k]) => k.startsWith('JSC_')))));
  log('BROWSER', browser.version());
  const context = await browser.newContext({viewport: {width: 1440, height: 900}});
  if (process.env.HOOK) await context.addInitScript({path: process.env.HOOK});
  page = await context.newPage();
  page.on('console', (m) => fs.appendFileSync(OUT + '/console.txt', `${now().slice(11, 23)} [${m.type()}] ${m.text()}\n`));
  page.on('pageerror', (e) => fs.appendFileSync(OUT + '/console.txt', `${now().slice(11, 23)} [pageerror] ${String(e).slice(0, 600)}\n`));
  page.on('crash', () => { crashed = true; log('WEBKIT_PAGE_CRASH', now()); label('crash'); });
  page.on('close', () => log('PAGE_CLOSE', now()));
  await sleep(3000);
  if (ROUTE === 'probe') {
    await page.goto('about:blank');
    const env = await js('env', ENV_JS);
    log('ENV', env); fs.writeFileSync(OUT + '/env.json', String(env));
    const audio = await js('audio', `(async () => { const c = new AudioContext(); const t0 = c.currentTime; const s0 = c.state; await new Promise((r) => setTimeout(r, 1500)); const r = {before: s0, t0, after: c.state, t1: c.currentTime, rate: c.sampleRate}; return JSON.stringify(r); })()`);
    log('AUDIO_NO_GESTURE', audio);
    await page.setContent('<button id=b style="width:400px;height:200px">go</button><script>window.r = null; document.getElementById("b").onclick = async () => { const c = new AudioContext(); await c.resume().catch((e) => null); const t0 = c.currentTime; setTimeout(() => { window.r = {state: c.state, t0, t1: c.currentTime, rate: c.sampleRate}; }, 1500); };</script>');
    await page.mouse.click(200, 100); await sleep(2500);
    log('AUDIO_AFTER_TRUSTED_CLICK', await js('audio2', 'JSON.stringify(window.r)'));
    log('WASM', await js('wasm', 'JSON.stringify({memory: typeof WebAssembly.Memory, max64k: (() => { try { const m = new WebAssembly.Memory({initial: 1, maximum: 65536}); m.grow(16384 - 1); return m.buffer.byteLength / 1048576; } catch (e) { return String(e); } })()})'));
    await shot('probe');
    await sleep(2000);
    return 0;
  }
  label('navigate');
  await page.goto(URL_, {waitUntil: 'commit', timeout: 60000});
  log('OPEN', now());
  const ready = await waitReady(360);
  label('ready');
  log('READY_EXIT', ready, now());
  if (ready !== 'ready') { await state('notready'); await dumphook('notready'); await shot('notready'); return 5; }
  const env = await js('env', ENV_JS);
  log('ENV', String(env).slice(0, 1500)); fs.writeFileSync(OUT + '/env.json', String(env));
  await shot('prompt');
  log('HELPER', await js('helper', fs.readFileSync(process.env.HELPER, 'utf8')));
  // The start prompt: the shim, then a trusted click on its Play button.
  log('PROMPT_SHIM', await js('shim', 'window.__pc.installShim()'));
  const before = JSON.parse(await js('before', "(() => { window.__tiReadback(); const s = JSON.parse(window.__tiState); const r = document.getElementById('canvas').getBoundingClientRect(); return JSON.stringify({prompt: s.start_prompt === undefined ? null : s.start_prompt, paused: s.paused, pointer_locked: s.pointer_locked, touch_visible: s.touch_visible, x: Math.round(r.left + s.resume_button[0] * r.width / s.viewport[0]), y: Math.round(r.top + s.resume_button[1] * r.height / s.viewport[1])}); })()"));
  log('PROMPT_BEFORE', JSON.stringify(before));
  label('prompt_click');
  await page.mouse.move(before.x, before.y); await page.mouse.down(); await sleep(80); await page.mouse.up();
  log('PROMPT_CLICK trusted at', before.x, before.y, JSON.stringify(before.prompt));
  await sleep(1500);
  const after = JSON.parse(await js('after', "(() => { window.__tiReadback(); const s = JSON.parse(window.__tiState); return JSON.stringify({prompt: s.start_prompt, paused: s.paused, pointer_locked: s.pointer_locked, pointer_free: s.pointer_free, input: s.input}); })()"));
  log('PROMPT_AFTER', JSON.stringify(after));
  if (after.paused !== false || after.prompt) await fail('the start prompt did not start play');
  label('playing');
  await sleep(2000);
  const sp = await state('spawn');
  if (!sp || sp.paused !== false || sp.input !== true) await fail('not playing after the start prompt');
  const calibrate = async (name, how) => {
    const r = await js('cal-' + name, `window.__pc.${how}.then((r) => JSON.stringify(r))`);
    log('CAL_' + name, String(r).slice(0, 300));
    let psi; try { psi = JSON.parse(r).psi; } catch (e) { psi = undefined; }
    if (typeof psi !== 'number' || !isFinite(psi)) await fail('calibration ' + name);
    log('CAM_' + name, await js('cam-' + name, `(() => { window.__pc.cam = {psi: ${psi}, theta: -8 * Math.PI / 180, g: 0.003}; return JSON.stringify(window.__pc.cam); })()`));
  };
  const look = async (name, secs) => {
    log('AIM_' + name, String(await js('aim-' + name, 'JSON.stringify(window.__pc.aim([-260.59, 2.0, 801.48]))')).slice(0, 300));
    await sleep(2500); await shot(name); label(name + '_start'); await sleep(secs * 1000); await state(name); label(name + '_end');
  };
  await calibrate('spawn', 'calibrate(500)');
  await look('look1', ROUTE === 'short' ? 60 : 45);
  if (ROUTE === 'full') {
    const poll = async (name, tries) => {
      let r = '';
      for (let i = 0; i < tries; i++) {
        await sleep(2000);
        r = await js('ap-' + name, 'JSON.stringify({done: window.__pc.ap.done, phase: window.__pc.ap.phase, result: window.__pc.ap.result, last: window.__pc.ap.log.slice(-1)[0]})');
        if (/"done":true|EVAL_FAILED/.test(r)) break;
      }
      return r;
    };
    const walk = async (name, x, z) => {
      log('AIM_PRE_' + name, String(await js('aimpre-' + name, `JSON.stringify(window.__pc.aim([${x}, 5.5, ${z}]))`)).slice(0, 200));
      await sleep(1000);
      log('GO_' + name, await js('go-' + name, `window.__pc.go([[${x}, ${z}]], {mode: 'land', deadline: 60})`));
      const r = await poll(name, 40); log('AP_' + name, r);
      if (!/landed/.test(r)) await fail(`walk ${name} did not arrive: ${r}`);
    };
    const fly = async (name, points) => {
      log('GO_' + name, await js('go-' + name, `window.__pc.go(${points}, {cruise: 40, mode: 'land', deadline: 150})`));
      const r = await poll(name, 90);
      fs.writeFileSync(`${OUT}/aplog-${name}.json`, String(await js('aplog-' + name, 'JSON.stringify(window.__pc.ap.log)')));
      log('AP_' + name, r);
      if (!/landed/.test(r)) await fail(`flight ${name} did not land: ${r}`);
    };
    label('walk_start');
    await walk('walk-a', -91.18, 778.26); await walk('walk-b', -78.0, 770.5); await walk('walk-door', -68.17, 769.79);
    label('walk_end');
    log('AIM_car', String(await js('aim-car', 'JSON.stringify(window.__pc.aim([-67.44, 4.8, 771.21]))')).slice(0, 200));
    await sleep(1500);
    log('KEY_F', await js('f-in', "window.__pc.tap('f')"));
    await sleep(1500);
    const sin = await state('in');
    if (!sin || sin.driving !== true) await fail('F beside the sedan did not get in');
    label('drive_start');
    for (let n = 1; n <= CIRCLES; n++) { await js('circle', "window.__pc.hold(['w', 'a'], 18000)"); await sleep(20000); await state('drive-' + n); }
    label('drive_end');
    log('KEY_F_OUT', await js('f-out', "window.__pc.tap('f')"));
    await sleep(2000);
    const sout = await state('out');
    if (!sout || sout.driving !== false) await fail('F did not get out');
    await calibrate('air', 'calibrateAir(1500, 500)');
    label('fly_start');
    for (let k = 1; k <= FLIGHTS; k++) {
      const sfx = k > 1 ? '-' + k : '';
      await fly('pier' + sfx, '[[636.0, 324.0]]');
      await state('pier' + sfx);
      if (k === 1) await shot('pier');
      await calibrate('pier' + sfx, 'calibrate(500)');
      await fly('back' + sfx, '[[-104.36, 786.02]]');
      if (k < FLIGHTS) { await state('back' + sfx); await calibrate('back' + sfx, 'calibrate(500)'); }
    }
    label('fly_end');
    await state('back');
    await calibrate('back', 'calibrate(500)');
    await look('look2', 60);
  }
  label('settle_end');
  const se = await state('end');
  if (!se || se.paused !== false) await fail('paused at the end');
  await sleep(4000); label('after_gc'); await sleep(10000); label('after_dump');
  await dumphook('end');
  log('EXTRA', String(await js('extra', 'JSON.stringify({pack: window.__mem && window.__mem.pack ? {calls: window.__mem.pack.calls, bytes: window.__mem.pack.bytes, size: window.__mem.pack.size} : null, audio: window.__mem ? {buffers: window.__mem.audio.buffers, bytes: window.__mem.audio.bytes, sources: window.__mem.audio.sources, contexts: window.__mem.audioState()} : null})')).slice(0, 900));
  log('PLAY_DONE', now());
  return 0;
}

main().then(async (code) => {
  try { if (browser) await browser.close(); } catch (e) { log('CLOSE_FAILED', String(e).slice(0, 200)); }
  label('closed'); log('ROUTE_EXIT', code, now()); process.exit(code);
}, async (e) => {
  const code = e instanceof Fail ? 6 : 7;
  if (!(e instanceof Fail)) log('ROUTE_ERROR', String(e && e.stack || e).slice(0, 1200));
  try { if (browser) await browser.close(); } catch (e2) { log('CLOSE_FAILED', String(e2).slice(0, 200)); }
  label('closed'); log('ROUTE_EXIT', code, now()); process.exit(code);
});
