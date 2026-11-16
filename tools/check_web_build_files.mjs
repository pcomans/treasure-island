#!/usr/bin/env node
// Checks the web page's build cache (tiBuildFiles and tiLoadingLine in
// game/web/shell.html): the page keeps a copy of a build's game data pack on the
// device, in the site's private file system, and loads the same build from it next
// time. This runs the shell's own functions with stand-ins for the browser's file
// system (whose writable streams, like the browser's, change a file only when closed),
// Web Locks, HTTP cache and fetch, and checks what a player would see:
//   - the first load downloads the pack, without a second copy in the HTTP cache, and
//     stores it; the next load of that build downloads nothing and gets the same bytes;
//     a pack the HTTP cache already has is stored from there, without the network;
//   - a new build downloads its own pack and, once it is stored, removes the old
//     build's folder (and a disk failure while storing keeps the old one);
//   - a download that ends early, fails or holds more than the page expects is never
//     stored as complete: the pack is downloaded again and the next load downloads again;
//   - a marker naming another size, a stored file of another size, or a stored file
//     that reads short is not used;
//   - without the lock (another tab is storing) a tab uses complete copies but writes
//     nothing; with no storage, storage that throws, no writable streams, or a storage
//     call that never answers, the pack comes from the network as before, within seconds;
//   - one buffer holds the pack through retries and a stored copy that reads short;
//   - a disk slower than the download loses nothing, and what waits for it goes in few
//     writes;
//   - the loading line: never blank once anything reports, "from this device" only when
//     the pack comes from there, a percentage once every size is known.
// Node only, no network and no engine; about twenty seconds, mostly the page's waits
// between download attempts and for storage that doesn't answer. Part of tools/test.sh.
//
//   node tools/check_web_build_files.mjs [SHELL]   (SHELL: another copy of the page's shell)
import {readFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import {dirname, join} from 'node:path';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const shell = readFileSync(process.argv[2] || join(root, 'game/web/shell.html'), 'utf8');
const script = [...shell.matchAll(/<script>([\s\S]*?)<\/script>/g)].map((m) => m[1]).find((code) => code.includes('function tiBuildFiles('));
if (!script) {
  console.log('FAIL: game/web/shell.html has no inline script with function tiBuildFiles');
  process.exit(1);
}
// The shell's script, with its Uint8Array counting every buffer the size of the pack.
const packBuffers = {size: -1, made: 0};
class CountingUint8Array extends Uint8Array {
  constructor(...args) {
    super(...args);
    if (args[0] === packBuffers.size) packBuffers.made += 1;
  }
}
const {tiBuildFiles, tiLoadingLine} = new Function('Uint8Array', `${script}\nreturn {tiBuildFiles, tiLoadingLine};`)(CountingUint8Array);

const failures = [];
const check = (ok, what) => { if (!ok) failures.push(what); };
const notFound = () => Object.assign(new Error('not found'), {name: 'NotFoundError'});
const never = () => new Promise(() => {});
const bytes = (n, seed) => {
  const out = new Uint8Array(n);
  let x = seed;
  for (let i = 0; i < n; i += 1) { x = (x * 1103515245 + 12345) >>> 0; out[i] = x >>> 24; }
  return out;
};
const same = (a, b) => a.byteLength === b.byteLength && Buffer.compare(Buffer.from(a), Buffer.from(b)) === 0;
const later = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// The site's private file system: folders of files; a writable stream's chunks reach the
// file only on close(), as the browser's swap file does. Knobs: failWriteAfter (a write
// past that many bytes throws, as a full disk does), writeDelayMs, shortRead (file names
// whose stored copy reads short), hangDirectory (getDirectory never answers) and
// hangOnce (file names whose next getFile never answers).
class Storage {
  constructor() {
    this.root = new Folder(this);
    this.failWriteAfter = Infinity;
    this.writeDelayMs = 0;
    this.shortRead = new Set();
    this.hangDirectory = false;
    this.hangOnce = new Set();
    this.writes = {};
  }
  getDirectory() { return this.hangDirectory ? never() : Promise.resolve(this.root); }
  folder(...path) { let f = this.root; for (const p of path) { f = f.entries.get(p); if (!(f instanceof Folder)) return null; } return f; }
}
class Folder {
  constructor(storage) { this.storage = storage; this.entries = new Map(); }
  async getDirectoryHandle(name, {create = false} = {}) {
    let entry = this.entries.get(name);
    if (!entry && create) this.entries.set(name, entry = new Folder(this.storage));
    if (!(entry instanceof Folder)) throw notFound();
    return entry;
  }
  async getFileHandle(name, {create = false} = {}) {
    if (!this.entries.has(name) && create) this.entries.set(name, {data: new Uint8Array(0)});
    const entry = this.entries.get(name);
    if (!entry || entry instanceof Folder) throw notFound();
    return new FileHandle(this, name);
  }
  async removeEntry(name, {recursive = false} = {}) {
    const entry = this.entries.get(name);
    if (!entry) throw notFound();
    if (entry instanceof Folder && entry.entries.size > 0 && !recursive) throw new Error('not empty');
    this.entries.delete(name);
  }
  async *keys() { for (const name of [...this.entries.keys()]) yield name; }
}
class FileHandle {
  constructor(folder, name) { this.folder = folder; this.name = name; }
  getFile() {
    const storage = this.folder.storage;
    if (storage.hangOnce.delete(this.name)) return never();
    const entry = this.folder.entries.get(this.name);
    if (!entry || entry instanceof Folder) return Promise.reject(notFound());
    const file = new File([entry.data], this.name);
    if (!storage.shortRead.has(this.name)) return Promise.resolve(file);
    const short = new File([entry.data.subarray(0, entry.data.byteLength >> 1)], this.name);
    return Promise.resolve({size: file.size, text: () => file.text(), stream: () => short.stream()});
  }
  async createWritable() {
    const {folder, name} = this;
    const storage = folder.storage;
    const chunks = [];
    let written = 0;
    return {
      async write(data) {
        if (storage.writeDelayMs) await later(storage.writeDelayMs);
        const chunk = typeof data === 'string' ? new TextEncoder().encode(data) : new Uint8Array(data);
        if (written + chunk.byteLength > storage.failWriteAfter) throw Object.assign(new Error('disk full'), {name: 'QuotaExceededError'});
        chunks.push(chunk.slice());
        written += chunk.byteLength;
        storage.writes[name] = (storage.writes[name] || 0) + 1;
      },
      async close() {
        const entry = folder.entries.get(name);
        if (entry && !(entry instanceof Folder)) entry.data = new Uint8Array(Buffer.concat(chunks.map((c) => Buffer.from(c))));
      },
      async abort() { chunks.length = 0; },
    };
  }
}
// Web Locks with ifAvailable: busy denies every request, as when another tab holds it;
// hang never answers.
class Locks {
  constructor({busy = false, hang = false} = {}) { this.busy = busy; this.hang = hang; this.held = new Set(); }
  async request(name, options, callback) {
    if (this.hang) return never();
    if (this.busy || this.held.has(name)) return callback(null);
    this.held.add(name);
    try { return await callback({name}); } finally { this.held.delete(name); }
  }
}
// The server behind the browser's HTTP cache: each file's bytes in 64 KiB chunks, as a
// byte stream like a browser's download (a BYOB reader reads it through its own
// buffer), or with byteStreams false a plain stream of chunks. A plain fetch keeps a
// complete download in the HTTP cache; 'no-store' doesn't; 'only-if-cached' answers from
// it or fails, never from the network. downloads counts the network's answers, hits the
// cache's. truncate[name] = n: the next n downloads of it end cleanly at half;
// fail[name] = n: the next n error at half.
class Server {
  constructor(files) { Object.assign(this, {files, downloads: {}, hits: {}, modes: {}, truncate: {}, fail: {}, httpCache: new Set(), byteStreams: true}); }
  count(name) { return this.downloads[name] || 0; }
  fetch(name, init = {}) {
    const mode = init.cache || 'default';
    (this.modes[name] ||= []).push(mode);
    const data = this.files[name];
    if (mode === 'only-if-cached') {
      if (!this.httpCache.has(name)) return Promise.reject(new TypeError('Failed to fetch'));
      this.hits[name] = (this.hits[name] || 0) + 1;
      return Promise.resolve(this.respond(data, null));
    }
    this.downloads[name] = this.count(name) + 1;
    if (!data) return Promise.resolve(new Response('missing', {status: 404}));
    const cut = (this.truncate[name] || 0) > 0 ? (this.truncate[name] -= 1, 'end') : (this.fail[name] || 0) > 0 ? (this.fail[name] -= 1, 'error') : null;
    if (mode !== 'no-store' && !cut) this.httpCache.add(name);
    return Promise.resolve(this.respond(data, cut));
  }
  respond(data, cut) {
    let offset = 0;
    const stop = cut ? data.byteLength >> 1 : data.byteLength;
    return new Response(new ReadableStream({
      type: this.byteStreams ? 'bytes' : undefined,
      pull(controller) {
        if (offset >= stop) {
          if (cut === 'error') controller.error(new TypeError('network error')); else controller.close();
          if (controller.byobRequest) controller.byobRequest.respond(0);
          return;
        }
        const request = controller.byobRequest;
        const n = Math.min(65536, stop - offset, request ? request.view.byteLength : Infinity);
        if (request) {
          request.view.set(data.subarray(offset, offset + n));
          request.respond(n);
        } else {
          controller.enqueue(data.slice(offset, offset + n));
        }
        offset += n;
      },
    }));
  }
}

const FOLDER = 'grand-treasure-island-builds';
const build = (name, size = 1000003, seed = 1) => ({name, pack: [`${name}.pck`, bytes(size, seed)]});
const serverFor = (...builds) => new Server(Object.fromEntries(builds.map((b) => b.pack)));
// One page load of build B, as the shell does it: the pack's buffer, then finish().
// Returns what the page got, where from, and how long it took.
async function load(b, {storage, locks, server, canWrite = true}) {
  const marks = [];
  const env = {storage, locks, canWrite, fetch: (n, init) => server.fetch(n, init), mark: (m) => marks.push(m), warn: () => {}};
  const files = tiBuildFiles(b.name, env);
  const from = new Set();
  let progress = 0;
  let pack = null;
  let error = null;
  const start = Date.now();
  packBuffers.size = b.pack[1].byteLength;
  packBuffers.made = 0;
  try {
    pack = new Uint8Array(await files.pack(b.pack[0], b.pack[1].byteLength, (n, f) => { from.add(f); progress = n; }));
  } catch (err) {
    error = err;
  }
  const savingAfterPack = files.saving();
  await files.finish();
  return {pack, error, from: [...from], progress, marks, ms: Date.now() - start, buffers: packBuffers.made, savingAfterPack, savingAfterFinish: files.saving()};
}
// Whether build B's pack is stored complete: the file and a marker naming its size.
const stored = (storage, b) => {
  const folder = storage.folder(FOLDER, b.name);
  const [name, data] = b.pack;
  const file = folder && folder.entries.get(name);
  const marker = folder && folder.entries.get(`${name}.complete`);
  return Boolean(file && marker && same(file.data, data) && new TextDecoder().decode(marker.data) === String(data.byteLength));
};
const marked = (storage, b) => Boolean(storage.folder(FOLDER, b.name)?.entries.has(`${b.pack[0]}.complete`));
const got = (r, b) => r.pack !== null && same(r.pack, b.pack[1]);

const A = build('treasure-island-aaaaaaa', 1000003, 1);
const B = build('treasure-island-bbbbbbb', 1100005, 7);

{ // A first load stores; the next load of that build downloads nothing.
  const storage = new Storage(); storage.writeDelayMs = 3; const locks = new Locks(); const server = serverFor(A, B);
  const first = await load(A, {storage, locks, server});
  check(got(first, A), 'first load: the page got other bytes than the server sent');
  check(first.from.join() === 'network' && first.progress === A.pack[1].byteLength, `first load: came from ${first.from}, progress ${first.progress}`);
  check(stored(storage, A), 'first load: the pack was not stored complete with its marker');
  check(server.modes[A.pack[0]].join() === 'only-if-cached,no-store' && !server.httpCache.has(A.pack[0]), `first load: fetched ${server.modes[A.pack[0]]}, HTTP cache ${server.httpCache.has(A.pack[0])}`);
  check(first.savingAfterPack && !first.savingAfterFinish, `first load: saving() ${first.savingAfterPack} after the pack, ${first.savingAfterFinish} after finish()`);
  const second = await load(A, {storage, locks, server});
  check(got(second, A) && second.from.join() === 'device', `second load: came from ${second.from}, not the device`);
  check(server.count(A.pack[0]) === 1 && !server.hits[A.pack[0]], `second load: ${server.count(A.pack[0])} downloads in all, ${server.hits[A.pack[0]] || 0} from the HTTP cache`);
  check(!second.savingAfterPack, 'second load: saving() while nothing was stored');
  // A new build downloads its own pack and then removes the old build's folder.
  const next = await load(B, {storage, locks, server});
  check(got(next, B) && server.count(B.pack[0]) === 1 && stored(storage, B), 'new build: not downloaded once and stored');
  check(storage.folder(FOLDER, A.name) === null && next.marks.includes('cache:removed_other_builds'), 'new build: the old build\'s folder is still there');
  // A rollback stores the old build again and removes the new one.
  const back = await load(A, {storage, locks, server});
  check(got(back, A) && stored(storage, A) && storage.folder(FOLDER, B.name) === null, 'rollback: the old build was not stored again in place of the new one');
  check(locks.held.size === 0, 'the lock is still held after finish()');
}
{ // A pack the HTTP cache already has is stored from there, without the network.
  const storage = new Storage(); const server = serverFor(A);
  server.httpCache.add(A.pack[0]);
  const r = await load(A, {storage, locks: new Locks(), server});
  check(got(r, A) && server.count(A.pack[0]) === 0 && server.hits[A.pack[0]] === 1 && stored(storage, A), `HTTP cache copy: ${server.count(A.pack[0])} downloads, ${server.hits[A.pack[0]] || 0} cache answers`);
}
{ // A download that ends early or fails is never stored as complete, and one buffer holds it.
  for (const how of ['truncate', 'fail']) {
    const storage = new Storage(); const locks = new Locks(); const server = serverFor(A);
    server[how][A.pack[0]] = 3;
    const r = await load(A, {storage, locks, server});
    check(got(r, A) && server.count(A.pack[0]) === 4 && stored(storage, A), `${how}: three cut downloads then a whole one were not loaded and stored (${server.count(A.pack[0])} downloads)`);
    check(r.buffers === 1, `${how}: four attempts made ${r.buffers} buffers of the pack's size`);
  }
  const storage = new Storage(); const locks = new Locks(); const server = serverFor(A);
  server.truncate[A.pack[0]] = 4;
  const r = await load(A, {storage, locks, server});
  check(r.error && /Failed loading file/.test(r.error.message) && server.count(A.pack[0]) === 4, `four short downloads: ${r.error ? r.error.message : 'no error'}`);
  check(!marked(storage, A) && storage.folder(FOLDER, A.name)?.entries.has(A.pack[0]) !== true, 'four short downloads: a pack was left stored');
  const again = await load(A, {storage, locks, server});
  check(got(again, A) && again.from.join() === 'network' && stored(storage, A), 'after four short downloads the next load did not download and store the pack');
}
{ // A download that holds more than the size the page expects is never stored.
  const long = build('treasure-island-ddddddd', 30000, 5);
  const storage = new Storage(); const server = new Server({[long.pack[0]]: bytes(30001, 6)});
  const r = await load(long, {storage, locks: new Locks(), server});
  check(r.error && /more than the expected/.test(r.error.message) && server.count(long.pack[0]) === 4 && !marked(storage, long), `a longer pack: ${r.error ? r.error.message : 'no error'}`);
}
{ // A plain stream (no BYOB reader) loads, retries and stores the same.
  const storage = new Storage(); const server = serverFor(A);
  server.byteStreams = false;
  server.truncate[A.pack[0]] = 1;
  const r = await load(A, {storage, locks: new Locks(), server});
  check(got(r, A) && server.count(A.pack[0]) === 2 && stored(storage, A) && r.buffers === 1, 'plain streams: not loaded, retried and stored in one buffer');
}
{ // A wrong marker, a stored file of another size or one that reads short is not used.
  for (const harm of ['marker', 'size', 'short']) {
    const storage = new Storage(); const locks = new Locks(); const server = serverFor(A);
    await load(A, {storage, locks, server});
    const folder = storage.folder(FOLDER, A.name);
    if (harm === 'marker') folder.entries.get(`${A.pack[0]}.complete`).data = new TextEncoder().encode('123');
    if (harm === 'size') folder.entries.get(A.pack[0]).data = A.pack[1].slice(0, 1000);
    if (harm === 'short') storage.shortRead.add(A.pack[0]);
    const r = await load(A, {storage, locks, server});
    check(got(r, A) && server.count(A.pack[0]) === 2 && r.from.includes('network'), `${harm}: the damaged stored copy was used (${server.count(A.pack[0])} downloads)`);
    if (harm === 'short') check(r.from.join() === 'device,network' && r.buffers === 1, `short: the read and the download made ${r.buffers} buffers of the pack's size`);
    storage.shortRead.clear();
    check(stored(storage, A), `${harm}: it was not stored again`);
  }
}
{ // Without the lock a tab uses complete copies but writes nothing, and downloads as before.
  const storage = new Storage(); const server = serverFor(A, B);
  await load(A, {storage, locks: new Locks(), server});
  const busy = new Locks({busy: true});
  const r = await load(A, {storage, locks: busy, server});
  check(got(r, A) && r.from.join() === 'device', 'without the lock: the stored copy was not used');
  const rb = await load(B, {storage, locks: busy, server});
  check(got(rb, B) && rb.from.join() === 'network' && server.modes[B.pack[0]].join() === 'default', `without the lock: the new build was fetched ${server.modes[B.pack[0]]}`);
  check(!storage.folder(FOLDER, B.name)?.entries.has(B.pack[0]) && storage.folder(FOLDER, A.name) !== null, 'without the lock: a tab wrote or removed something');
}
{ // No storage, storage that throws, no writable streams: the network, as before.
  const throwing = {getDirectory: () => Promise.reject(new Error('SecurityError'))};
  for (const [what, storage, canWrite] of [['no storage', undefined, true], ['throwing storage', throwing, true], ['no createWritable', new Storage(), false]]) {
    const server = serverFor(A);
    const r = await load(A, {storage, locks: new Locks(), server, canWrite});
    check(got(r, A) && r.from.join() === 'network' && server.modes[A.pack[0]].join() === 'default', `${what}: did not load from the network as before`);
    if (storage instanceof Storage) check(storage.folder(FOLDER) === null, `${what}: wrote to storage`);
  }
}
{ // A storage call that never answers counts as no storage within seconds.
  for (const what of ['directory', 'lock', 'stored file']) {
    const storage = new Storage(); const server = serverFor(A);
    let locks = new Locks();
    if (what === 'stored file') {
      await load(A, {storage, locks, server});
      storage.hangOnce.add(`${A.pack[0]}.complete`);
    }
    if (what === 'directory') storage.hangDirectory = true;
    if (what === 'lock') locks = new Locks({hang: true});
    const r = await load(A, {storage, locks, server});
    check(got(r, A) && r.from.join() === 'network' && r.ms < 4000, `${what} never answers: ${r.error ? r.error.message : 'loaded'} from ${r.from} in ${r.ms} ms`);
    if (what !== 'stored file') check(r.marks.includes('cache:none'), `${what} never answers: no 'cache:none' mark`);
  }
}
{ // A disk that fails while storing loses the store, not the download, and keeps the old build.
  const storage = new Storage(); const locks = new Locks(); const server = serverFor(A, B);
  await load(A, {storage, locks, server});
  storage.failWriteAfter = 500000;
  const r = await load(B, {storage, locks, server});
  check(got(r, B), 'disk failure: the download did not complete');
  check(!marked(storage, B) && !storage.folder(FOLDER, B.name)?.entries.has(B.pack[0]), 'disk failure: a partial pack was kept or marked');
  check(stored(storage, A), 'disk failure: the old build was removed although the new one was not stored');
}
{ // A disk slower than the download loses nothing, and what waits goes in few writes.
  const big = build('treasure-island-ccccccc', 40 * 1024 * 1024 + 5, 3);
  const storage = new Storage(); storage.writeDelayMs = 2;
  const r = await load(big, {storage, locks: new Locks(), server: serverFor(big)});
  const chunks = Math.ceil(big.pack[1].byteLength / 65536);
  check(got(r, big) && stored(storage, big), 'slow disk: the pack was not loaded and stored complete');
  check(storage.writes[big.pack[0]] < chunks / 4, `slow disk: the pack's ${chunks} chunks took ${storage.writes[big.pack[0]]} writes`);
}
{ // The loading line.
  const nb = String.fromCharCode(160);
  const line = (started, engine, pack) => tiLoadingLine({started, engine, pack});
  check(line(false, {loaded: 0, total: 0}, {loaded: 0, total: 0, from: null}) === null, 'line: shown before anything reported');
  const cases = [
    [line(true, {loaded: 0, total: 100}, {loaded: 0, total: 0, from: null}), `Downloading the${nb}game…`, 'an unknown source'],
    [line(true, {loaded: 50, total: 100}, {loaded: 150, total: 300, from: 'network'}), `Downloading the${nb}game: 50%`, 'the network'],
    [line(true, {loaded: 100, total: 100}, {loaded: 300, total: 300, from: 'device'}), `Loading the game from this${nb}device: 100%`, 'the device'],
    [line(true, {loaded: 10, total: 100}, null), `Downloading the${nb}game: 10%`, 'the engine loading the pack'],
    [line(true, {loaded: 5, total: 0}, null), `Downloading the${nb}game…`, 'an export without sizes'],
  ];
  for (const [shown, want, what] of cases) check(shown && shown.text === want, `line for ${what}: ${shown ? JSON.stringify(shown.text) : 'none'}, not ${JSON.stringify(want)}`);
  check(cases[2][0].done && !cases[1][0].done, 'line: done at 100% only');
}

if (failures.length > 0) {
  for (const failure of failures) console.log(`FAIL: ${failure}`);
  process.exit(1);
}
console.log('PASS: the page\'s build cache stores a build\'s pack (without a second copy in the HTTP cache), loads that build from the device without downloading, removes an older build once a new one is stored, never marks a short, long or failed download, ignores damaged copies, writes only with the lock, keeps one buffer through retries, falls back to the network without storage or when storage never answers, and its loading line is never blank');
