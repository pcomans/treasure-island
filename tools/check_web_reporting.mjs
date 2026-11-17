#!/usr/bin/env node
// Checks the web page's anonymous statistics (tiReporting and its helpers in
// game/web/shell.html) with stand-ins for the browser's storage, Web Locks and clock and
// for the Sentry SDK: a fake that records what the page asks of it, builds each message
// as the SDK would (with what the SDK adds by default and the page must strip), and sends
// it through the page's own transport, which scrubs it and lets it out or not. What a
// player would see, and what would leave the page (owner, 2026-11-17: "Ask once on first
// launch"):
//   - not asked yet, answered no (this visit and the next) or with storage that can't be
//     read: over a whole visit, no storage write, no lock, no SDK load and nothing sent;
//     an error made before the yes is dropped, not kept for later;
//   - the yes at the start prompt: the answer kept, the visit's record started from it,
//     the SDK loaded once with narrow settings and the session sent; then errors, "game
//     start" when play starts (no load times from before the answer) and the timed stats;
//   - a player who said yes earlier: the SDK loads at the start prompt and the load's
//     transaction goes when play starts, with the funnel's times; with no DSN, nothing is
//     loaded or sent but the records are kept;
//   - the end of an earlier visit that stopped unexpectedly in front is reported exactly
//     once, with its build, phase, last snapshot, store, bucketed length and time since,
//     and never again; one in the background, a clean one and another tab's live one are
//     not; an earlier visit that ended before play started is sent once as a "game visit"
//     of its own build, with how far it got (not one whose record began at the answer);
//   - the scrubbing: no query string, fragment, host, local path's user name, request,
//     cookies, user agent, breadcrumbs, extra data, other contexts, IP address or user
//     field but the anonymous id, and no tags but the page's own; sessions keep only the
//     anonymous id as their user; client reports never leave;
//   - at most five error events per page load (in the page and again in the transport),
//     each error once; the timed stats at most 48;
//   - a no mid-visit stops sending at once, closes the SDK, deletes every key of ours but
//     the answer and lets the lock go; a yes again sends again, with a new anonymous id;
//   - the timed stats as a transaction with the cells and movements as spans and the
//     frame rates and memory as measurements; stats that come before the SDK is up are
//     dropped;
//   - the anonymous id: none before a yes, then the same on every later visit (the user
//     of every message and the session's distinct id), gone with a no and new after;
//   - a failed load, a lost WebGL context and the engine's error exit are each reported
//     once, a failed load letting the SDK load before the start prompt;
//   - the privacy page's link opens only an https address, only where the game says;
//   - tiLoadSpans, tiDeviceTags and tiEnvironment on samples, and the page's names (funnel
//     steps, snapshot fields, movements, the anonymous id's size) match GameStats'
//     (game/scripts/reports/game_stats.gd).
// Node only, no network and no engine; well under a second. Part of tools/test.sh.
//
//   node tools/check_web_reporting.mjs [SHELL]   (SHELL: another copy of the page's shell)
import {readFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import {dirname, join} from 'node:path';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const shell = readFileSync(process.argv[2] || join(root, 'game/web/shell.html'), 'utf8');
const script = [...shell.matchAll(/<script>([\s\S]*?)<\/script>/g)].map((m) => m[1]).find((code) => code.includes('function tiReporting('));
if (!script) {
  console.log('FAIL: game/web/shell.html has no inline script with function tiReporting');
  process.exit(1);
}
const {tiReporting, tiDeviceTags, tiEnvironment, tiLoadSpans, tiScrubText, tiScrubEvent, tiScrubEnvelope} = new Function(
  `${script}\nreturn {tiReporting, tiDeviceTags, tiEnvironment, tiLoadSpans, tiScrubText, tiScrubEvent, tiScrubEnvelope};`)();

const failures = [];
const check = (ok, what) => { if (!ok) failures.push(what); };
const settle = () => new Promise((resolve) => setTimeout(resolve, 0));
const HEX32 = /^[0-9a-f]{32}$/;
const PREFIX = 'grand-treasure-island.';
const NOW = 1_800_000_000_000;

// localStorage: broken throws on every call, as blocked site data does; the keys
// written (setItem) and deleted, in order.
class Storage {
  constructor({broken = false} = {}) { this.map = new Map(); this.broken = broken; this.writes = []; this.deletions = []; }
  guard() { if (this.broken) throw Object.assign(new Error('blocked'), {name: 'SecurityError'}); }
  getItem(key) { this.guard(); return this.map.has(key) ? this.map.get(key) : null; }
  setItem(key, value) { this.guard(); this.writes.push(key); this.map.set(key, String(value)); }
  removeItem(key) { this.guard(); this.deletions.push(key); this.map.delete(key); }
  key(index) { this.guard(); return [...this.map.keys()][index] ?? null; }
  get length() { this.guard(); return this.map.size; }
}
// Web Locks: a lock is held while the promise its callback returns is pending, until its
// page dies (dieAll); requests counts the locks asked for.
class Locks {
  constructor() { this.held = new Set(); this.requests = 0; }
  request(name, callback) {
    this.requests += 1;
    this.held.add(name);
    Promise.resolve().then(() => callback()).then(() => this.held.delete(name));
    return new Promise(() => {});
  }
  query() { return Promise.resolve({held: [...this.held].map((name) => ({name}))}); }
  dieAll() { this.held.clear(); }
}
// A page's TI_BOOT marks (ms from the navigation's start), as a returning load has them.
const MARKS = {
  'TI_BOOT:engine_init_begin': 400, 'TI_BOOT:step:Downloading the\u00a0game': 420, 'TI_BOOT:download_complete': 30000,
  'TI_BOOT:step:Starting the\u00a0engine…': 30100, 'TI_BOOT:game_start_begin': 30200, 'TI_BOOT:step:Loading the\u00a0island…': 33000,
  'TI_BOOT:step:Setting up the\u00a0island…': 40000, 'TI_BOOT:step:Compiling shaders: sky and\u00a0player…': 42000,
  'TI_BOOT:step:Rendering reflections…': 58000, 'TI_BOOT:play_ready': 60000, 'TI_BOOT:overlay_hidden': 60020,
};
const CONFIG = {dsn: 'https://0123456789abcdef0123456789abcdef@o1.ingest.example.invalid/2', release: 'grand-treasure-island@2177+140968e',
  sdk: 'treasure-island-140968e9.sentry.js', integrity: 'sha384-stand-in', traces_sample_rate: 1};

// The Sentry SDK, as far as the page uses it: each message built as the SDK builds it
// (with what it adds by default), through the page's beforeSend and transport; the
// network transport keeps each envelope as the bytes the SDK would send.
function fakeSdk() {
  const sdk = {loads: 0, inits: [], closes: 0, network: [], user: null, options: null, transport: null, enabled: false, scope: null, scopeTags: {}, events: 0};
  for (const name of ['eventFilters', 'linkedErrors', 'dedupe', 'browserSession', 'browserTracing']) {
    sdk[name + 'Integration'] = (options) => ({name, options});
  }
  const serialize = ([headers, items]) => [JSON.stringify(headers), ...items.flatMap(([header, payload]) => [JSON.stringify(header), JSON.stringify(payload)])].join('\n');
  sdk.makeFetchTransport = () => ({send: (envelope) => { sdk.network.push(serialize(envelope)); return Promise.resolve({}); }, flush: () => Promise.resolve(true)});
  const dsc = () => ({trace_id: 'a'.repeat(32), public_key: '0123456789abcdef0123456789abcdef', release: sdk.options.release, environment: sdk.options.environment, user_id: 'not-sent', replay_id: 'not-sent'});
  sdk.init = (options) => {
    sdk.inits.push(options);
    sdk.options = options;
    sdk.enabled = true;
    sdk.user = (options.initialScope && options.initialScope.user) || null;
    sdk.scopeTags = {...((options.initialScope && options.initialScope.tags) || {})};
    sdk.transport = options.transport({url: 'stand-in'});
    // The session start, as browserSessionIntegration sends it, and a client report.
    sdk.transport.send([{sent_at: 'now', sdk: {name: 'sentry.javascript.browser', version: '11.10.0'}}, [
      [{type: 'session'}, {sid: 'f'.repeat(32), did: sdk.user && sdk.user.id, init: true, started: 'now', status: 'ok', errors: 0,
        attrs: {release: options.release, environment: options.environment, user_agent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 26_1 like Mac OS X)', ip_address: '{{auto}}'}}],
      [{type: 'client_report'}, {discarded_events: [{reason: 'sample_rate', category: 'transaction', quantity: 1}]}],
    ]]);
  };
  sdk.close = () => { sdk.closes += 1; sdk.enabled = false; return Promise.resolve(true); };
  sdk.setUser = (user) => { sdk.user = user; };
  sdk.withScope = (callback) => {
    const before = sdk.scope;
    sdk.scope = {tags: {}, contexts: {}, setTags(tags) { Object.assign(this.tags, tags); }, setContext(key, value) { this.contexts[key] = value; }};
    try { callback(sdk.scope); } finally { sdk.scope = before; }
  };
  // What the SDK adds to an error event by default, which the page must strip.
  const defaults = () => ({
    request: {url: 'https://grandtreasureisland.vercel.app/game/?store=1#top', headers: {'User-Agent': 'Mozilla/5.0 (iPhone)', Referer: 'https://elsewhere.example/?q=secret', Cookie: 'session=abc'}},
    breadcrumbs: [{category: 'console', message: 'chest says hello'}], extra: {player: 'alice'}, server_name: 'alice-laptop', modules: {a: '1'},
    sdk: {name: 'sentry.javascript.browser', version: '11.10.0', settings: {infer_ip: 'never'}},
  });
  function sendEvent(base, context) {
    if (!sdk.enabled) return;
    sdk.events += 1;
    const event = {event_id: 'e'.repeat(31) + sdk.events % 10, platform: 'javascript', timestamp: NOW / 1000, release: base.release || sdk.options.release, environment: sdk.options.environment,
      ...defaults(), ...base,
      tags: {...sdk.scopeTags, ...(context.tags || {}), ...(base.tags || {}), extra_tag: 'from elsewhere'},
      contexts: {...(base.contexts || {}), ...(context.contexts || {}), culture: {locale: 'en-US', timezone: 'America/Los_Angeles'}, browser: {name: 'Safari', version: '26.1'}, os: {name: 'iOS'}},
      user: {...(sdk.user || {}), ip_address: '{{auto}}', username: 'alice', geo: {city: 'San Francisco'}}};
    const out = sdk.options.beforeSend(event, {});
    if (out) sdk.transport.send([{event_id: event.event_id, sent_at: 'now', sdk: event.sdk, trace: dsc()}, [[{type: 'event'}, out]]]);
  }
  sdk.captureException = (error, context = {}) => sendEvent({exception: {values: [{type: error.name, value: error.message, stacktrace: {frames: [
    {filename: 'https://grandtreasureisland.vercel.app/game/?store=1#top', function: 'tiReporting', lineno: 700, colno: 9},
    {filename: 'file:///Users/alice/Downloads/game/treasure-island-140968e9.js', function: 'Ea', lineno: 1, colno: 9999},
  ]}}]}, level: 'error'}, context);
  sdk.captureMessage = (message, context = {}) => sendEvent({message, level: context.level || 'info'}, context);
  sdk.captureEvent = (event) => sendEvent(event, {});
  sdk.startInactiveSpan = (options) => {
    const span = {...options, children: [], measurements: {}, scope: sdk.scope};
    span.end = (time) => {
      span.endTime = time;
      if (options.forceTransaction && sdk.enabled) {
        const transaction = {event_id: 't'.repeat(32), type: 'transaction', transaction: span.name, start_timestamp: span.startTime, timestamp: time,
          release: sdk.options.release, environment: sdk.options.environment, ...defaults(),
          contexts: {trace: {trace_id: 'a'.repeat(32), span_id: 'b'.repeat(16), op: span.op, data: {'sentry.op': span.op, 'url.full': 'https://grandtreasureisland.vercel.app/game/?store=1', deviceMemory: '8 GB', hardwareConcurrency: '8'}},
            ...span.scope.contexts, culture: {timezone: 'America/Los_Angeles'}},
          tags: {...sdk.scopeTags, ...span.scope.tags}, user: {...(sdk.user || {}), ip_address: '{{auto}}'},
          spans: span.children.map((child) => ({description: child.name, op: child.op, start_timestamp: child.startTime, timestamp: child.endTime, data: {'sentry.op': child.op, 'url.full': 'https://x.example/?q=1'}})),
          measurements: {...span.measurements, 'connection.rtt': {value: 50, unit: 'millisecond'}}};
        const out = sdk.options.beforeSendTransaction(transaction, {});
        if (out) sdk.transport.send([{event_id: transaction.event_id, sent_at: 'now', trace: {...dsc(), transaction: span.name, sampled: 'true'}}, [[{type: 'transaction'}, out]]]);
      }
    };
    if (options.parentSpan) options.parentSpan.children.push(span);
    return span;
  };
  sdk.setMeasurement = (name, value, unit, span) => { span.measurements[name] = {value, unit}; };
  return sdk;
}
// The items that left, as [type, payload] (from the envelopes' bytes).
const sentItems = (sdk) => sdk.network.flatMap((bytes) => {
  const lines = bytes.split('\n');
  const out = [];
  for (let i = 1; i < lines.length; i += 2) out.push([JSON.parse(lines[i]).type, JSON.parse(lines[i + 1])]);
  return out;
});
const ofType = (sdk, type) => sentItems(sdk).filter(([kind]) => kind === type).map(([, payload]) => payload);
const measure = (event, name) => ((event && event.measurements) || {})[name] && event.measurements[name].value;

// One page load: its stand-in browser and SDK, and the page's statistics started.
function page({storage = new Storage(), locks = new Locks(), sdk = fakeSdk(), config = CONFIG, visible = true, focused = true, now = NOW, marks = MARKS} = {}) {
  let ids = 0;
  const env = {
    storage, locks, now: () => env.clock, sinceStart: () => env.since, randomBytes: (count) => Uint8Array.from({length: count}, () => Math.floor(Math.random() * 256)),
    id: () => `${env.clock}-${ids += 1}`, visible: () => env.isVisible, focused: () => env.isFocused,
    tags: {device: 'iPhone', os: 'iOS 26', browser: 'Safari 26'}, store: false, environment: 'production', timeOrigin: NOW - 90000,
    marks: () => env.marksNow, page: () => ({ttfb: 120, fcp: 300}), wasmBytes: () => 536870912,
    loadSdk: (src, integrity) => { sdk.loads += 1; sdk.loadedWith = [src, integrity]; return Promise.resolve(sdk); },
    every: (ms, fn) => { env.heartbeat = fn; env.heartbeatMs = ms; },
  };
  Object.assign(env, {clock: now, since: 90000, isVisible: visible, isFocused: focused, marksNow: marks});
  const reporting = tiReporting(config, env);
  return {reporting, env, sdk, storage, locks, started: reporting.start()};
}
const SNAPSHOT = {area: '-2,7', movement: 'in_car', height_m: '<5', speed_m_s: '10-25', fps: '30-45', session_min: '5-15', resolution: '67', shadows: 'off', frame_rate_limit: 'unlimited',
  gpu: 'Apple GPU', screen: 'small', input: 'touch', video_mb: 410, texture_mb: 350, buffer_mb: 60};
const STATS = {first: true, play_min: 1, window_s: 60, fps_median: 41.5, fps_p05: 22.0, fps_worst: 9.5,
  areas_s: {'-2,7': 31, '-2,8': 12, '-1,7': 9, '-3,7': 3, '-3,8': 2, '0,7': 1, '0,8': 1, '1,8': 1, other: 1}, movement_s: {on_foot: 30, jetpack: 10, in_car: 20},
  graphics_changes: [{setting: 'resolution', from: '67', to: '50'}], snapshot: SNAPSHOT};
// A player who said yes on an earlier visit, and one who said no.
const answered = (answer) => { const storage = new Storage(); storage.map.set(PREFIX + 'crash-reports', answer); return storage; };
const returning = () => answered('yes');
// Everything a visit does, as the page and the game would do it.
async function wholeVisit(p) {
  await p.started;
  p.reporting.step('download_finished', 30000);
  p.reporting.error(new Error('during the load'));
  p.reporting.phase('play');
  p.reporting.step('start_prompt', 60020);
  p.reporting.snapshot(JSON.stringify(SNAPSHOT));
  p.reporting.seen();
  p.env.heartbeat();
  p.reporting.playStarted();
  p.reporting.error(new Error('in play'));
  p.reporting.contextLost();
  p.reporting.engineExit(3);
  p.reporting.stats(JSON.stringify(STATS));
  p.reporting.ended();
  p.reporting.resumed();
  await settle();
}

{ // Not asked yet: over a whole visit nothing is written, locked, loaded or sent; the game asks.
  const p = page();
  await wholeVisit(p);
  const told = JSON.parse(p.reporting.read());
  check(p.storage.writes.length === 0 && p.storage.deletions.length === 0 && p.locks.requests === 0 && p.sdk.loads === 0 && p.sdk.network.length === 0
    && told.consent === null && told.storage === true && JSON.parse(p.reporting.status()).blocked === 'not asked yet',
  `not asked yet: wrote ${p.storage.writes}, deleted ${p.storage.deletions}, locks ${p.locks.requests}, loaded ${p.sdk.loads}, sent ${p.sdk.network.length}, read ${JSON.stringify(told)}`);
}
{ // Answered no on an earlier visit: nothing written, locked, loaded or sent, this visit and the next.
  const storage = answered('no');
  for (const visit of [1, 2]) {
    const p = page({storage});
    await wholeVisit(p);
    const told = JSON.parse(p.reporting.read());
    check(storage.writes.length === 0 && storage.deletions.length === 0 && p.locks.requests === 0 && p.sdk.loads === 0 && p.sdk.network.length === 0 && told.consent === 'no',
      `answered no, visit ${visit}: wrote ${storage.writes}, locks ${p.locks.requests}, loaded ${p.sdk.loads}, sent ${p.sdk.network.length}, read ${JSON.stringify(told)}`);
  }
}
{ // Storage that can't be read: nothing loaded or sent, no question (storage false), a yes kept nowhere.
  const p = page({storage: new Storage({broken: true})});
  await p.started;
  p.reporting.phase('play');
  p.reporting.setConsent('yes');
  p.reporting.playStarted();
  p.reporting.error(new Error('boom'));
  await settle();
  const told = JSON.parse(p.reporting.read());
  check(p.sdk.loads === 0 && p.sdk.network.length === 0 && p.locks.requests === 0 && told.consent === null && told.storage === false,
    `broken storage: loaded ${p.sdk.loads}, sent ${p.sdk.network.length}, locks ${p.locks.requests}, read ${JSON.stringify(told)}`);
}
{ // No DSN, with the yes kept: nothing loads or leaves, and the page keeps its records all the same.
  const storage = returning();
  storage.setItem(PREFIX + 'session.old', JSON.stringify({v: 1, release: 'grand-treasure-island@2100+abcdef0', build: '2100', since: 'load', phase: 'play', steps: {page_opened: 0, play_started: 5000},
    snapshot: SNAPSHOT, visible: true, focused: true, store: false, startedAt: NOW - 400000, lastSeenAt: NOW - 20000, clean: false}));
  const p = page({storage, config: {...CONFIG, dsn: ''}});
  await wholeVisit(p);
  const status = JSON.parse(p.reporting.status());
  check(p.sdk.loads === 0 && p.sdk.network.length === 0 && status.blocked === 'no DSN', `no DSN: the SDK loaded ${p.sdk.loads} times and ${p.sdk.network.length} envelopes left (${status.blocked})`);
  check(storage.getItem(PREFIX + 'unclean') !== null && [...storage.map.keys()].some((key) => key.startsWith(PREFIX + 'session.') && key !== PREFIX + 'session.old'),
    'no DSN: the page did not keep its records (the earlier visit\'s end, this visit\'s record)');
}
{ // The first visit, yes at the start prompt: nothing before the answer; then the answer and
  // the record kept, the SDK loaded once, the session; errors from then on; "game start"
  // when play starts, no load times; the timed stats.
  const p = page();
  await p.started;
  p.reporting.step('download_finished', 30000);
  p.reporting.error(new Error('during the load'));
  p.reporting.phase('play');
  p.reporting.step('start_prompt', 60020);
  p.reporting.snapshot(JSON.stringify(SNAPSHOT));
  p.env.heartbeat();
  await settle();
  const beforeYes = [p.storage.writes.length, p.locks.requests, p.sdk.loads, p.sdk.network.length];
  p.env.since = 70000;
  p.reporting.setConsent('yes');
  await settle();
  const kept = [p.storage.getItem(PREFIX + 'crash-reports'), [...p.storage.map.keys()].filter((key) => key.startsWith(PREFIX + 'session.')).length, p.locks.held.size];
  p.reporting.error(new Error('after the yes'));
  p.env.since = 75000;
  p.reporting.playStarted();
  await settle();
  p.env.since = 135000;
  p.reporting.stats(JSON.stringify(STATS));
  await settle();
  check(beforeYes.join() === '0,0,0,0', `first visit: before the yes wrote, locked, loaded and sent ${beforeYes}, not 0,0,0,0`);
  check(kept[0] === 'yes' && kept[1] === 1 && kept[2] === 1, `first visit: the yes did not keep the answer, the visit's record and its lock (${kept})`);
  check(p.sdk.loads === 1 && p.sdk.loadedWith.join() === `${CONFIG.sdk},${CONFIG.integrity}`, `first visit: the SDK loaded ${p.sdk.loads} times, from ${p.sdk.loadedWith}`);
  const options = p.sdk.inits[0] || {integrations: [], dataCollection: {}, tracePropagationTargets: [1]};
  check(options.defaultIntegrations === false && options.integrations.map((i) => i.name).join() === 'eventFilters,linkedErrors,dedupe,browserSession' && options.tracePropagationTargets.length === 0
    && options.dataCollection.userInfo === false && options.dataCollection.httpHeaders === false && options.dataCollection.cookies === false && options.dataCollection.urlQueryParams === false
    && options.sendClientReports === false && options.maxBreadcrumbs === 0 && options.attachStacktrace === false && options.tracesSampleRate === 1 && options.environment === 'production' && options.release === CONFIG.release,
  `first visit: the SDK's settings are not the page's narrow ones: ${JSON.stringify({...options, transport: undefined, beforeSend: undefined, beforeSendTransaction: undefined})}`);
  const events = ofType(p.sdk, 'event');
  const transactions = ofType(p.sdk, 'transaction');
  const starts = transactions.filter((t) => t.transaction === 'game start');
  const sessions = ofType(p.sdk, 'session');
  check(events.length === 1 && events[0].exception.values[0].value === 'after the yes' && events[0].tags.phase === 'play',
    `first visit: the errors that left are not the one after the yes alone (${JSON.stringify(events.map((e) => [e.exception && e.exception.values[0].value, e.tags.phase]))})`);
  check(starts.length === 1 && measure(starts[0], 'funnel.play_started') === 75000 && Object.keys(starts[0].measurements || {}).join() === 'funnel.play_started' && starts[0].tags.kind === 'start'
    && transactions.every((t) => t.transaction !== 'game load') && transactions.filter((t) => t.transaction === 'game stats').length === 1,
  `first visit: not one game start with play's time alone, no load and the stats (${JSON.stringify(transactions.map((t) => [t.transaction, t.tags.kind, t.measurements]))})`);
  const id = events[0] && events[0].user && events[0].user.id;
  check(HEX32.test(id || '') && starts[0] && starts[0].user.id === id && sessions.length === 1 && sessions[0].did === id, `first visit: the anonymous id is not every message's user and the session's distinct id (${id}, ${JSON.stringify(sessions)})`);
  check(sentItems(p.sdk).every(([type]) => type !== 'client_report'), 'first visit: a client report left');
  check(JSON.stringify(JSON.parse(p.reporting.status()).steps) === JSON.stringify({play_started: 75000, playing_1min: 135000}), `first visit: the record's steps are not those after the yes alone (${JSON.stringify(JSON.parse(p.reporting.status()).steps)})`);
}
{ // A player who said yes earlier: the SDK loads at the start prompt; the load's transaction waits for play.
  const p = page({storage: returning()});
  await p.started;
  p.reporting.step('download_finished', 30000);
  p.reporting.phase('play');
  p.reporting.step('start_prompt', 60020);
  await settle();
  const atPrompt = [p.sdk.loads, ofType(p.sdk, 'session').length, ofType(p.sdk, 'transaction').length];
  p.env.since = 75000;
  p.reporting.playStarted();
  await settle();
  const loads = ofType(p.sdk, 'transaction').filter((t) => t.transaction === 'game load');
  check(atPrompt.join() === '1,1,0' && loads.length === 1 && measure(loads[0], 'funnel.download_finished') === 30000 && measure(loads[0], 'funnel.start_prompt') === 60020
    && measure(loads[0], 'funnel.play_started') === 75000 && loads[0].spans.some((s) => s.description === 'waiting to play') && loads[0].tags.visit === undefined,
  `yes earlier: at the start prompt loaded, sessions, transactions ${atPrompt} (want 1,1,0); then ${JSON.stringify(loads.map((l) => [l.tags, l.measurements]))}`);
}
{ // An earlier visit that ended unexpectedly in front: reported once, with its tags and snapshot.
  const storage = returning();
  const locks = new Locks();
  const record = (fields) => JSON.stringify({v: 1, release: 'grand-treasure-island@2100+abcdef0', build: '2100', phase: 'play', steps: {page_opened: 0, download_finished: 30000, start_prompt: 50000, play_started: 60000},
    snapshot: SNAPSHOT, visible: true, focused: true, store: false, startedAt: NOW - 400000, lastSeenAt: NOW - 20000, clean: false, ...fields});
  storage.setItem(PREFIX + 'session.crashed', record({}));
  storage.setItem(PREFIX + 'session.background', record({visible: false, lastSeenAt: NOW - 10000, build: '2101', phase: 'loading'}));
  storage.setItem(PREFIX + 'session.unfocused', record({focused: false, lastSeenAt: NOW - 5000, build: '2102'}));
  storage.setItem(PREFIX + 'session.clean', record({clean: true}));
  storage.setItem(PREFIX + 'session.gave-up', record({clean: true, steps: {page_opened: 0, download_finished: 30000, start_prompt: 50000}}));
  storage.setItem(PREFIX + 'session.live', record({}));
  storage.setItem(PREFIX + 'session.answered', record({clean: true, since: 'answer', steps: {}}));
  locks.held.add(PREFIX + 'session.live');
  const p = page({storage, locks});
  await p.started;
  p.reporting.phase('play');
  await settle();
  const ends = ofType(p.sdk, 'event').filter((e) => e.message === 'previous session ended unexpectedly');
  const end = ends[0] || {tags: {}};
  check(ends.length === 1 && end.level === 'fatal' && end.release === 'grand-treasure-island@2100+abcdef0' && end.tags.kind === 'unclean_exit' && end.tags.previous_build === '2100'
    && end.tags.phase === 'play' && end.tags.store === 'no' && end.tags.session_length === '5m-15m' && end.tags.returned_after === '<30s' && end.tags.area === '-2,7' && end.tags.movement === 'in_car'
    && end.tags.device === 'iPhone' && end.contexts && end.contexts.game && end.contexts.game.video_mb === 410,
  `an earlier visit's unexpected end: reported ${ends.length} times, as ${JSON.stringify(end)}`);
  const visits = ofType(p.sdk, 'transaction').filter((t) => t.transaction === 'game visit');
  check(visits.length === 1 && visits[0].release === 'grand-treasure-island@2100+abcdef0' && visits[0].tags.reached === 'start_prompt' && visits[0].tags.ended === 'cleanly'
    && measure(visits[0], 'funnel.start_prompt') === 50000 && !(visits[0].contexts && visits[0].contexts.game),
  `an earlier visit that ended before play: sent as ${JSON.stringify(visits.map((v) => [v.release, v.tags, v.measurements]))}, not one game visit of build 2100 that reached the start prompt`);
  check(storage.getItem(PREFIX + 'session.live') !== null && ['crashed', 'background', 'unfocused', 'clean', 'gave-up', 'answered'].every((name) => storage.getItem(PREFIX + 'session.' + name) === null),
    'earlier visits: a live tab\'s record was taken, or a dead one left');
  const again = page({storage, locks});
  await again.started;
  again.reporting.phase('play');
  await settle();
  check(ofType(again.sdk, 'event').length === 0 && ofType(again.sdk, 'transaction').filter((t) => t.transaction === 'game visit').length === 0, 'the next visit reported the earlier visits again');
}
{ // The scrubbing, on an event as the SDK builds it with everything it may add.
  const p = page({storage: returning()});
  await p.started;
  p.reporting.snapshot(JSON.stringify({...SNAPSHOT, extra_field: 'x', area: 'a'.repeat(100)}));
  p.reporting.phase('play');
  await settle();
  p.reporting.error(new Error('Failed to fetch https://grandtreasureisland.vercel.app/game/x.pck?store=1#top from /Users/bob/game and C:\\Users\\carol\\game'));
  await settle();
  const event = ofType(p.sdk, 'event')[0] || {};
  const text = p.sdk.network.join('\n');
  const leaked = ['alice', 'bob', 'carol', 'store=1', '#top', 'grandtreasureisland.vercel.app', 'elsewhere', 'Mozilla', 'Cookie', 'session=abc', '{{auto}}', 'San Francisco', 'America/Los_Angeles', 'chest says hello', 'not-sent', 'extra_field', 'deviceMemory']
    .filter((needle) => text.includes(needle));
  check(leaked.length === 0, `scrubbing: what left still holds ${leaked.join(', ')}`);
  check(event.request === undefined && event.breadcrumbs === undefined && event.extra === undefined && event.server_name === undefined && JSON.stringify(event.user) === JSON.stringify({id: event.user && event.user.id})
    && Object.keys(event.contexts || {}).join() === 'game' && event.tags.extra_tag === undefined && event.tags.area === undefined,
  `scrubbing: the event keeps what it must not: ${JSON.stringify(event)}`);
  const frames = (((event.exception || {}).values || [])[0] || {}).stacktrace;
  check(frames && frames.frames.map((f) => f.filename).join() === 'index.html,treasure-island-140968e9.js' && event.exception.values[0].value === 'Failed to fetch x.pck from /Users/~/game and C:\\Users\\~\\game',
    `scrubbing: the frames and message are not reduced to file names and ~ (${JSON.stringify(event.exception)})`);
  check(tiScrubText('see https://a.example/b/c.js?x=1#y and http://h/ and file:///home/dan/x') === 'see c.js and index.html and x' && tiScrubText('/home/eve/a') === '/home/~/a',
    `tiScrubText: ${tiScrubText('see https://a.example/b/c.js?x=1#y and http://h/ and file:///home/dan/x')}`);
  const envelope = tiScrubEnvelope([{trace: {trace_id: 't', user_id: 'u', replay_id: 'r', release: 'x'}}, [[{type: 'session'}, {did: 'alice@example.com', attrs: {user_agent: 'UA', ip_address: '1.2.3.4', release: 'x'}}], [{type: 'attachment'}, 'data'], [{type: 'replay_event'}, {}]]], () => true);
  check(envelope && envelope[1].length === 1 && envelope[1][0][1].did === undefined && JSON.stringify(envelope[1][0][1].attrs) === '{"release":"x"}' && JSON.stringify(envelope[0].trace) === '{"trace_id":"t","release":"x"}',
    `tiScrubEnvelope: ${JSON.stringify(envelope)}`);
}
{ // The cap: at most five error events per page load, each error once, in the page and the transport.
  const p = page({storage: returning()});
  await p.started;
  p.reporting.phase('play');
  await settle();
  for (let i = 0; i < 20; i += 1) p.reporting.error(new Error('loop ' + (i % 12)));
  p.reporting.error(new Error('loop 0'));
  await settle();
  check(ofType(p.sdk, 'event').length === 5, `the cap: ${ofType(p.sdk, 'event').length} error events left, not 5`);
  const q = page({storage: returning()});
  await q.started;
  q.reporting.phase('play');
  await settle();
  for (let i = 0; i < 7; i += 1) q.sdk.transport.send([{}, [[{type: 'event'}, {message: 'direct ' + i}]]]);
  check(ofType(q.sdk, 'event').length === 5, `the transport's cap: ${ofType(q.sdk, 'event').length} of 7 events sent straight to it left, not 5`);
}
{ // A no mid-visit (Options' switch off): at once nothing more, the SDK closed, every key of
  // ours but the answer deleted and the lock let go; a yes again sends again, with a new id.
  const storage = returning();
  storage.map.set(PREFIX + 'visits', '[]');
  const p = page({storage});
  await p.started;
  p.reporting.phase('play');
  p.reporting.playStarted();
  p.reporting.error(new Error('before the no'));
  await settle();
  const before = p.sdk.network.length;
  const firstId = storage.getItem(PREFIX + 'anonymous-id');
  p.reporting.setConsent('no');
  p.env.heartbeat();
  p.reporting.seen();
  p.reporting.error(new Error('after the no'));
  p.reporting.stats(JSON.stringify(STATS));
  p.sdk.transport.send([{}, [[{type: 'event'}, {message: 'queued in the SDK'}]]]);
  await settle();
  const off = [p.sdk.network.length - before, p.sdk.closes, [...storage.map.keys()].join(), storage.getItem(PREFIX + 'crash-reports'), p.locks.held.size];
  p.reporting.setConsent('yes');
  await settle();
  p.reporting.error(new Error('after the yes again'));
  await settle();
  const again = ofType(p.sdk, 'event').filter((e) => e.exception && e.exception.values[0].value === 'after the yes again');
  const newId = again[0] && again[0].user.id;
  check(HEX32.test(firstId || '') && off[0] === 0 && off[1] === 1 && off[2] === PREFIX + 'crash-reports' && off[3] === 'no' && off[4] === 0 && p.sdk.inits.length === 2 && again.length === 1
    && HEX32.test(newId || '') && newId !== firstId,
  `a no mid-visit: ${off[0]} more envelopes, ${off[1]} closes, keys left ${off[2]}, answer ${off[3]}, locks held ${off[4]}; a yes again: ${p.sdk.inits.length} inits, ${again.length} events, id ${newId} (was ${firstId})`);
}
{ // The timed stats: a transaction over the window, the cells and movements as spans, the
  // numbers as measurements; dropped before the SDK is up; at most 48.
  const p = page({storage: returning()});
  await p.started;
  p.reporting.stats(JSON.stringify(STATS));
  p.reporting.phase('play');
  p.reporting.playStarted();
  await settle();
  const early = ofType(p.sdk, 'transaction').filter((t) => t.transaction === 'game stats').length;
  p.reporting.stats(JSON.stringify(STATS));
  const stats = ofType(p.sdk, 'transaction').filter((t) => t.transaction === 'game stats');
  const s = stats[0] || {spans: [], measurements: {}, tags: {}};
  const areas = s.spans.filter((span) => span.op === 'ti.area');
  const moves = s.spans.filter((span) => span.op === 'ti.movement');
  check(early === 0 && stats.length === 1 && areas.length === 9 && areas.find((a) => a.description === 'area -2,7').timestamp - s.start_timestamp === 31
    && moves.map((m) => m.description).join() === 'on_foot,jetpack,in_car' && s.timestamp - s.start_timestamp === 60
    && measure(s, 'fps.median') === 41.5 && measure(s, 'fps.worst') === 9.5 && measure(s, 'play_min') === 1 && measure(s, 'memory.wasm_mb') === 512
    && s.tags.stats === 'first' && s.tags.graphics_changed === 'yes' && s.tags.area === '-2,7' && s.tags.gpu === 'Apple GPU' && s.contexts.game.graphics_changes[0].to === '50'
    && s.measurements['connection.rtt'] === undefined && s.contexts.trace.data['url.full'] === undefined && HEX32.test(s.user.id),
  `the timed stats: ${early} sent before the SDK was up; then ${JSON.stringify(s)}`);
  for (let i = 0; i < 60; i += 1) p.reporting.stats(JSON.stringify({...STATS, first: false}));
  check(ofType(p.sdk, 'transaction').filter((t) => t.transaction === 'game stats').length === 48, 'the timed stats: not at most 48 per page load');
}
{ // The anonymous id: none before a yes; then kept across visits as every message's user;
  // gone with a no (kept so on the next visit), a new one after a yes again.
  const storage = new Storage();
  const first = page({storage});
  await first.started;
  first.reporting.phase('play');
  first.reporting.error(new Error('before the yes'));
  await settle();
  const beforeYes = storage.getItem(PREFIX + 'anonymous-id');
  first.reporting.setConsent('yes');
  first.reporting.playStarted();
  await settle();
  const made = storage.getItem(PREFIX + 'anonymous-id');
  const ids = [];
  for (const visit of [1, 2]) {
    const p = page({storage});
    await p.started;
    p.reporting.phase('play');
    await settle();
    ids.push((ofType(p.sdk, 'session')[0] || {}).did);
  }
  const off = page({storage});
  await off.started;
  off.reporting.setConsent('no');
  await settle();
  const later = page({storage});
  await wholeVisit(later);
  const whileOff = [storage.getItem(PREFIX + 'anonymous-id'), later.sdk.network.length];
  later.reporting.setConsent('yes');
  later.reporting.error(new Error('yes again'));
  await settle();
  const fresh = (ofType(later.sdk, 'event')[0] || {user: {}}).user.id;
  check(beforeYes === null && HEX32.test(made || '') && ids.every((id) => id === made) && whileOff[0] === null && whileOff[1] === 0 && HEX32.test(fresh || '') && fresh !== made
    && storage.getItem(PREFIX + 'anonymous-id') === fresh,
  `the anonymous id: before the yes ${beforeYes}, made ${made}, later visits ${ids}, after a no ${whileOff}, a yes again ${fresh}`);
}
{ // A failed load (the SDK loads at once), a lost WebGL context and an error exit: each once.
  const p = page({storage: returning()});
  await p.started;
  p.reporting.loadFailed("Failed loading file 'treasure-island-140968e9.pck': HTTP 503");
  p.reporting.loadFailed("Failed loading file 'treasure-island-140968e9.pck': HTTP 503");
  p.reporting.contextLost(); p.reporting.contextLost();
  p.reporting.engineExit(0); p.reporting.engineExit(3); p.reporting.engineExit(3);
  await settle();
  const messages = ofType(p.sdk, 'event').map((e) => [e.message, e.tags.kind, e.tags.file, e.tags.status, e.tags.code].join('|'));
  check(p.sdk.loads === 1 && messages.join(';') === 'load failed: pck HTTP 503|load_failed|treasure-island-140968e9.pck|503|;WebGL context lost|webgl_context_lost|||;engine exited|engine_exit|||3',
    `a failed load, a lost context and an error exit: ${messages.join(';')}`);
  const q = page({storage: returning()});
  await q.started;
  q.reporting.loadFailed('Game stopped before startup completed (1).');
  await settle();
  check((ofType(q.sdk, 'event')[0] || {}).message === 'load failed: Game stopped before startup completed (1).', 'a failed start: not reported with its first line');
  const r = page();
  await r.started;
  r.reporting.loadFailed("Failed loading file 'treasure-island-140968e9.pck': HTTP 503");
  await settle();
  check(r.sdk.loads === 0 && r.sdk.network.length === 0 && r.storage.writes.length === 0 && JSON.parse(r.reporting.status()).phase === 'error',
    `a failed load before any answer: loaded ${r.sdk.loads}, sent ${r.sdk.network.length}, wrote ${r.storage.writes}, phase ${JSON.parse(r.reporting.status()).phase}`);
}
{ // The privacy page's link: only an https address and areas of four numbers; a point in
  // an area gives the address, anywhere else nothing.
  const p = page();
  await p.started;
  const privacy = 'https://grandtreasureisland.vercel.app/privacy';
  p.reporting.linkAreas(JSON.stringify({url: privacy, areas: [[0.1, 0.2, 0.3, 0.05], [1, 2], 'x']}));
  const hits = [p.reporting.linkAt(0.2, 0.22), p.reporting.linkAt(0.5, 0.5)];
  p.reporting.linkAreas(JSON.stringify({url: 'javascript:alert(1)', areas: [[0, 0, 1, 1]]}));
  const scheme = p.reporting.linkAt(0.5, 0.5);
  p.reporting.linkAreas(JSON.stringify({url: privacy, areas: []}));
  const gone = p.reporting.linkAt(0.2, 0.22);
  check(hits[0] === privacy && hits[1] === '' && scheme === '' && gone === '', `the privacy link: ${JSON.stringify([hits, scheme, gone])}`);
}
{ // tiLoadSpans, tiDeviceTags, tiEnvironment.
  const names = tiLoadSpans(MARKS, 75000).map((span) => span.name);
  check(names.join('|') === 'page|Downloading the game|Starting the engine|Loading the island|Setting up the island|Compiling shaders: sky and player|Rendering reflections|start prompt|waiting to play',
    `tiLoadSpans: ${names.join('|')}`);
  const agents = [
    ['Mozilla/5.0 (iPhone; CPU iPhone OS 26_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Mobile/15E148 Safari/604.1', 5, 'iPhone|iOS 26|Safari 26'],
    ['Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15', 5, 'iPad|iPadOS|Safari 26'],
    ['Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15', 0, 'desktop|macOS|Safari 26'],
    ['Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36', 5, 'Android|Android 15|Chrome 142'],
    ['Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', 0, 'desktop|Windows|Edge 142'],
    ['Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0', 0, 'desktop|Linux|Firefox 140'],
    ['Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/142.0.0.0 Mobile/15E148 Safari/604.1', 5, 'iPhone|iOS 18|Chrome 142'],
  ];
  for (const [agent, touch, want] of agents) {
    const tags = tiDeviceTags(agent, touch);
    check([tags.device, tags.os, tags.browser].join('|') === want, `tiDeviceTags: ${[tags.device, tags.os, tags.browser].join('|')}, not ${want}, for ${agent}`);
  }
  check(tiEnvironment('grandtreasureisland.vercel.app') === 'production' && tiEnvironment('play-grandtreasureisland.vercel.app') === 'production' && tiEnvironment('127.0.0.1') === 'local'
    && tiEnvironment('treasure-island-git-x.vercel.app') === 'local', 'tiEnvironment: not production at the two public hosts alone');
}
{ // The page's names are GameStats' (game/scripts/reports/game_stats.gd).
  const gd = readFileSync(join(root, 'game/scripts/reports/game_stats.gd'), 'utf8');
  const constant = (name) => JSON.parse((gd.match(new RegExp(`^const ${name} := (\\[[^\\]]*\\])`, 'm')) || [])[1] || 'null');
  const js = (name) => JSON.parse(((script.match(new RegExp(`const ${name} = (\\[[^\\]]*\\])`)) || [])[1] || 'null').replace(/'/g, '"'));
  const snapshotKeys = [...((gd.match(/func snapshot\(\) -> Dictionary:[\s\S]*?return \{([\s\S]*?)\n\t\}/) || [])[1] || '').matchAll(/"([a-z_]+)":/g)].map((m) => m[1]);
  const bytes = Number((gd.match(/^const ANONYMOUS_ID_BYTES := (\d+)/m) || [])[1]);
  check(JSON.stringify(constant('FUNNEL_STEPS')) === JSON.stringify(js('FUNNEL_STEPS')) && JSON.stringify(constant('MOVEMENTS')) === JSON.stringify(js('MOVEMENTS'))
    && snapshotKeys.length > 0 && JSON.stringify(snapshotKeys) === JSON.stringify(js('SNAPSHOT_FIELDS')) && script.includes(`const ANONYMOUS_ID_BYTES = ${bytes};`),
  `the page's names differ from GameStats': funnel ${js('FUNNEL_STEPS')} / ${constant('FUNNEL_STEPS')}, movements ${js('MOVEMENTS')} / ${constant('MOVEMENTS')}, snapshot ${js('SNAPSHOT_FIELDS')} / ${snapshotKeys}, anonymous id bytes ${bytes}`);
}

if (failures.length > 0) {
  for (const failure of failures) console.log(`FAIL: ${failure}`);
  process.exit(1);
}
console.log('PASS: the page\'s anonymous statistics write, lock, load and send nothing while not asked yet, after a no (this visit and the next) or with unreadable storage, and drop errors made before a yes; a yes at the start prompt keeps the answer and the visit\'s record from then on, loads the SDK once with narrow settings, sends the session, the errors after it, a game start with play\'s time (no load times from before the answer) and the timed stats; a player who said yes earlier gets the SDK at the start prompt and the load\'s transaction with the funnel\'s times; with no DSN nothing loads or leaves but the records are kept; an earlier visit\'s unexpected end is reported once with its tags and snapshot (a background, clean or live one not), an earlier visit that ended before play once as a game visit of its build (not one begun at the answer); the scrubbing leaves no query, host, path user name, request, cookie, user agent, breadcrumb, extra, other context, IP or stray tag, sessions only the anonymous id, no client reports; at most five error events per page load, each once, in the page and the transport; a no stops sending at once, closes the SDK, deletes every key but the answer and lets the lock go, a yes again sends with a new anonymous id; the timed stats go as a transaction with cells and movements as spans and the numbers as measurements, none before the SDK, at most 48; the anonymous id is made only after a yes, kept across visits and replaced after a no and a yes; a failed load, a lost context and an error exit are each reported once (a failed load before any answer not at all); the privacy link opens only an https address where the game says; the load\'s steps, device tags and environment read right; the page\'s names match GameStats\'');
