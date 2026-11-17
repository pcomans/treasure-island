// tools/web_trace/drive.cjs: one drive-trace session of a served web build, started by tools/web_trace/session.sh
// (which gives it this environment and a private Weston). Opens URL (?trace=drive&profile_startup=1: the trace,
// and the game's startup marks and readback), waits for the start prompt, applies Chrome's CPU slowdown (THROTTLE)
// there, taps or clicks Tap/Click to play with Playwright's own (trusted) input, then leaves the page alone until
// the game's trace ends (the drive takes about 6.5 min of game time, its triggers half a minute more), and saves
// what the page gathered in OUT: log.json (everything), analysis.json, results.txt, results.png, marks.json (the
// page's and the game's startup marks: each loading line as it went up), readback-*.json (what the page and the
// game draw at), console.txt, progress.txt. Nothing is sent anywhere: the page keeps its records on the device.
// Env: OUT, URL, BROWSER webkit|chrome, PROFILE phone|phone1x|safari|desktop, THROTTLE, GL gpu|swiftshader,
// PW_MODULE (Playwright), WK_EXEC (WebKit's MiniBrowser, or a wrapper starting it), CHROME_EXEC.
'use strict';
const fs = require('fs');
const pw = require(process.env.PW_MODULE || 'playwright');

const OUT = process.env.OUT; const URL_ = process.env.URL; const BROWSER = process.env.BROWSER || 'webkit';
const PROFILE = process.env.PROFILE || 'phone'; const THROTTLE = +(process.env.THROTTLE || 1); const GL = process.env.GL || 'gpu';
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const now = () => new Date().toISOString();
const log = (...a) => { const line = a.join(' '); console.log(line); fs.appendFileSync(OUT + '/progress.txt', now().slice(11, 19) + ' ' + line + '\n'); };
// An iPhone 16 Pro (Apple's specifications: 2622 x 1206 pixels, 3 pixels a point) held sideways full screen (a home
// screen app): 874 x 402 CSS px at 3x. Safari's own page sideways is smaller: Playwright's iPhone 16 Pro landscape
// descriptor gives 756 x 352. The user agent is that descriptor's.
const PHONE_UA = 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.2 Mobile/15E148 Safari/604.1';
const PROFILES = {
  phone: {viewport: {width: 874, height: 402}, deviceScaleFactor: 3, hasTouch: true, isMobile: true, userAgent: PHONE_UA},
  phone1x: {viewport: {width: 874, height: 402}, deviceScaleFactor: 1, hasTouch: true, isMobile: true, userAgent: PHONE_UA},
  safari: {viewport: {width: 756, height: 352}, deviceScaleFactor: 3, hasTouch: true, isMobile: true, userAgent: PHONE_UA},
  desktop: {viewport: {width: 1440, height: 900}, deviceScaleFactor: 1, hasTouch: false, isMobile: false},
};
let page = null; let browser = null; let crashed = false;

const evalTimed = async (expr, ms = 60000) => {
  let timer;
  try { return await Promise.race([page.evaluate(expr), new Promise((_, rej) => { timer = setTimeout(() => rej(new Error('evaluate timeout ' + ms + ' ms')), ms); })]); }
  finally { clearTimeout(timer); }
};
const js = async (name, expr, ms) => {
  try { return await evalTimed(expr, ms); } catch (e) { const m = 'EVAL_FAILED ' + name + ' ' + String(e).slice(0, 300); log(m); return m; }
};
const shot = async (name) => {
  try { await page.screenshot({path: `${OUT}/${name}.png`, timeout: 60000}); log('SCREENSHOT', name); } catch (e) { log('SCREENSHOT_FAILED', name, String(e).slice(0, 200)); }
};
const READBACK = `(() => {
  const c = document.getElementById('canvas');
  // Only once the game runs (its readback is set from main.gd's _ready): asked for before
  // the engine makes its context, getContext would make one with other attributes.
  const gl = c && typeof window.__tiReadback === 'function' ? c.getContext('webgl2') : null;
  const d = gl && gl.getExtension('WEBGL_debug_renderer_info');
  let s = null;
  if (typeof window.__tiReadback === 'function') { try { window.__tiReadback(); s = JSON.parse(window.__tiState || 'null'); } catch (e) { s = {error: String(e)}; } }
  return JSON.stringify({dpr: window.devicePixelRatio, inner: [innerWidth, innerHeight], screen: [screen.width, screen.height],
    canvas: c ? [c.width, c.height] : null, canvas_css: c ? [c.clientWidth, c.clientHeight] : null,
    drawing_buffer: gl ? [gl.drawingBufferWidth, gl.drawingBufferHeight] : null, renderer: gl ? gl.getParameter(gl.RENDERER) : null,
    unmasked: d ? gl.getParameter(d.UNMASKED_RENDERER_WEBGL) : null, secure: window.isSecureContext, ua: navigator.userAgent,
    touch_points: navigator.maxTouchPoints, overlay: (document.getElementById('status') || {}).style ? document.getElementById('status').style.visibility : null,
    game: s ? {ready: s.ready, paused: s.paused, prompt: s.start_prompt, viewport: s.viewport, window: s.window, button: s.resume_button,
      scale: s.graphics && s.graphics.scale, fps: s.graphics && s.graphics.fps, touch: s.touch_visible} : null});
})()`;

async function main() {
  log('START', 'browser=' + BROWSER, 'profile=' + PROFILE, 'throttle=' + THROTTLE, 'gl=' + GL, 'url=' + URL_);
  const profile = PROFILES[PROFILE];
  if (!profile) throw new Error('no profile ' + PROFILE);
  if (BROWSER === 'webkit') {
    browser = await pw.webkit.launch({headless: false, executablePath: process.env.WK_EXEC || undefined, timeout: 90000, env: {...process.env}});
  } else {
    const args = ['--ozone-platform=wayland', '--no-first-run', '--no-default-browser-check', '--ignore-gpu-blocklist', '--disable-background-timer-throttling', '--disable-renderer-backgrounding'];
    if (GL === 'swiftshader') args.push('--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader');
    browser = await pw.chromium.launch({headless: false, executablePath: process.env.CHROME_EXEC || undefined, timeout: 90000, env: {...process.env}, args});
  }
  log('BROWSER', browser.version());
  const context = await browser.newContext(profile);
  if (profile.hasTouch && BROWSER === 'webkit') {
    // A test stand-in (labelled so): WebKitGTK reports no touch points even with touch emulated, so the game
    // would take it for a mouse ("Click to play", no touch controls); a phone reports touch points.
    await context.addInitScript(() => {
      if (navigator.maxTouchPoints === 0) Object.defineProperty(Navigator.prototype, 'maxTouchPoints', {configurable: true, get: () => 5});
    });
  }
  page = await context.newPage();
  page.on('console', (m) => fs.appendFileSync(OUT + '/console.txt', `${now().slice(11, 23)} [${m.type()}] ${m.text()}\n`));
  page.on('pageerror', (e) => fs.appendFileSync(OUT + '/console.txt', `${now().slice(11, 23)} [pageerror] ${String(e).slice(0, 600)}\n`));
  page.on('crash', () => { crashed = true; log('PAGE_CRASH', now()); });
  let cdp = null;
  if (BROWSER === 'chrome') cdp = await context.newCDPSession(page);
  await page.goto(URL_, {waitUntil: 'commit', timeout: 90000});
  log('OPEN');
  // The start prompt: play ready, the loading screen gone, the game paused behind its prompt.
  const t0 = Date.now(); let r = null; let last = '';
  for (;;) {
    if (crashed) throw new Error('crashed while loading');
    try { r = JSON.parse(await evalTimed(READBACK, 20000)); } catch (e) { r = null; }
    const line = r ? `overlay=${r.overlay} ready=${r.game && r.game.ready} prompt=${r.game && r.game.prompt}` : 'no readback';
    if (line !== last) { log('LOAD', ((Date.now() - t0) / 1000).toFixed(0) + 's', line); last = line; }
    if (r && r.game && r.game.ready && r.game.prompt && r.overlay === 'hidden') break;
    if (Date.now() - t0 > 600000) throw new Error('no start prompt in 10 min: ' + line);
    await sleep(2000);
  }
  log('PROMPT', ((Date.now() - t0) / 1000).toFixed(0) + 's', JSON.stringify(r));
  fs.writeFileSync(OUT + '/readback-prompt.json', JSON.stringify(r, null, 1));
  await sleep(1500);
  await shot('prompt');
  if (cdp && THROTTLE > 1) {
    await cdp.send('Emulation.setCPUThrottlingRate', {rate: THROTTLE});
    log('THROTTLE', THROTTLE);
  }
  const rect = JSON.parse(await js('rect', `JSON.stringify((() => { const r = document.getElementById('canvas').getBoundingClientRect(); return [r.left, r.top, r.width, r.height]; })())`));
  const x = Math.round(rect[0] + r.game.button[0] * rect[2] / r.game.viewport[0]);
  const y = Math.round(rect[1] + r.game.button[1] * rect[3] / r.game.viewport[1]);
  if (/^Tap/.test(r.game.prompt)) {
    await page.touchscreen.tap(x, y);
  } else {
    // The browser's own pointer lock is never asked for here: it crashed Chromium on a headless Weston.
    await js('shim', `(() => { const c = document.getElementById('canvas'); let locked = false;
      Object.defineProperty(document, 'pointerLockElement', {configurable: true, get: () => (locked ? c : null)});
      c.requestPointerLock = function () { locked = true; setTimeout(() => document.dispatchEvent(new Event('pointerlockchange')), 0); return Promise.resolve(); };
      document.exitPointerLock = function () { locked = false; setTimeout(() => document.dispatchEvent(new Event('pointerlockchange')), 0); };
      return 'shim'; })()`);
    await page.mouse.move(x, y); await page.mouse.down(); await sleep(80); await page.mouse.up();
  }
  log('TAP', x, y, /^Tap/.test(r.game.prompt) ? 'touch' : 'mouse');
  await sleep(3000);
  const after = JSON.parse(await js('after', READBACK));
  log('AFTER_TAP', JSON.stringify(after.game));
  if (!after.game || after.game.paused !== false) throw new Error('the start prompt did not start play');
  // The drive: leave the page alone until the trace ends.
  const t1 = Date.now(); let state = null;
  for (;;) {
    await sleep(10000);
    if (crashed) throw new Error('crashed during the drive');
    const s = await js('state', 'JSON.stringify(window.__tiTrace.state())', 60000);
    try { state = JSON.parse(s); } catch (e) { state = null; }
    log('DRIVE', ((Date.now() - t1) / 1000).toFixed(0) + 's', state ? `rows=${state.rows} raf=${state.raf} ${state.status || ''}` : s);
    if (state && state.end) break;
    if (Date.now() - t1 > 40 * 60000) throw new Error('the drive did not end in 40 min');
  }
  log('END', JSON.stringify(state.end));
  if (cdp && THROTTLE > 1) await cdp.send('Emulation.setCPUThrottlingRate', {rate: 1});
  await sleep(3000);
  fs.writeFileSync(OUT + '/readback-end.json', await js('readback', READBACK));
  const full = await js('log', 'JSON.stringify(window.__tiTrace.log())', 180000);
  fs.writeFileSync(OUT + '/log.json', full);
  const analysis = await js('analysis', 'JSON.stringify(window.__tiTrace.analysis())', 180000);
  fs.writeFileSync(OUT + '/analysis.json', analysis);
  fs.writeFileSync(OUT + '/marks.json', await js('marks', "JSON.stringify(performance.getEntriesByType('mark').map((m) => [m.name, Math.round(m.startTime * 10) / 10]))"));
  const text = await js('text', "(document.querySelector('#ti-trace-results textarea') || {}).value || 'NO_RESULTS'");
  fs.writeFileSync(OUT + '/results.txt', text);
  await shot('results');
  log('SAVED', 'log', full.length, 'analysis', analysis.length, 'text', text.length);
  return state.end.result === 'complete' ? 0 : 4;
}

main().then(async (code) => {
  try { if (browser) await browser.close(); } catch (e) { log('CLOSE_FAILED', String(e).slice(0, 200)); }
  log('DRIVER_EXIT', code); process.exit(code);
}, async (e) => {
  log('DRIVER_ERROR', String(e && e.stack || e).slice(0, 1500));
  if (page && !crashed) {
    await shot('failure');
    try { fs.writeFileSync(OUT + '/readback-failure.json', await evalTimed(READBACK, 20000)); } catch (e2) { /* gone */ }
    try { fs.writeFileSync(OUT + '/log-partial.json', await evalTimed('JSON.stringify(window.__tiTrace ? window.__tiTrace.log() : null)', 120000)); } catch (e3) { /* gone */ }
    try { fs.writeFileSync(OUT + '/marks.json', await evalTimed("JSON.stringify(performance.getEntriesByType('mark').map((m) => [m.name, Math.round(m.startTime * 10) / 10]))", 20000)); } catch (e4) { /* gone */ }
  }
  try { if (browser) await browser.close(); } catch (e2) { log('CLOSE_FAILED', String(e2).slice(0, 200)); }
  process.exit(6);
});
