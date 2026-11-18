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
//   - a stored copy whose data comes after the page was busy for longer than the stall
//     limit is still used, and one that stops coming falls back to the network;
//   - once the pack is in, "Saving…" lasts only until the copy is written, never shows
//     for a store that already failed, and ends as soon as one fails;
//   - with storing off (an iPhone or iPad, or ?store=0) the page makes no storage call,
//     reads no stored copy and downloads as before, and the switch reads ?store=1 or
//     ?store=0 first;
//   - a browser that answers 'only-if-cached' from the network (WebKit) still gets one
//     download, read and stored as such;
//   - a disk slower than the download loses nothing, and what waits for it goes in few
//     writes;
//   - the loading line: never blank once anything reports, "Loading the game…" while the
//     pack's source isn't known, "Downloading" only once the pack comes over the network,
//     "from this device" only when it comes from there, a percentage once every size is known;
//   - once play is ready, freeing what the game no longer reads of the pack (tiPackDirectory,
//     tiReleasedPack, tiPackRelease, with a stand-in for the engine's file and MEMFS's read):
//     the pack's directory reads as Godot writes it, and a damaged one or a pack the page
//     should leave alone (encrypted, sparse) doesn't; every kept byte reads as before, read
//     as the engine does, once the pack's buffer is detached; a read that starts in a released
//     file, of any length, is an I/O error that names the file; one that runs on past a kept
//     file into a released one gets zeros there; the swap runs in a task of its own, and the
//     buffer is freed only once this tab's store has stopped writing from it; without the
//     engine's own file of the pack (a build without the engine-script patch, a copy, another
//     size, a lookup that throws) or with a request it does not take, it keeps the whole pack.
// Node only, no network and no engine; about thirty seconds, mostly the page's
// waits between download attempts and for storage that doesn't answer. Part of tools/test.sh.
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
const {tiBuildFiles, tiLoadingLine, tiAfterDownload, tiStoreOnThisDevice, tiAppleTouchDevice, tiPackDirectory, tiReleasedPack, tiPackRelease} = new Function('Uint8Array',
  `${script}\nreturn {tiBuildFiles, tiLoadingLine, tiAfterDownload, tiStoreOnThisDevice, tiAppleTouchDevice, tiPackDirectory, tiReleasedPack, tiPackRelease};`)(CountingUint8Array);

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
// whose stored copy reads short), hangDirectory (getDirectory never answers),
// hangOnce (file names whose next getFile never answers), readPlan (file names whose
// stored copy reads as plannedStream says) and removeDelayMs (removing what is there
// takes that long); directoryCalls counts getDirectory calls.
class Storage {
  constructor() {
    this.root = new Folder(this);
    this.failWriteAfter = Infinity;
    this.writeDelayMs = 0;
    this.shortRead = new Set();
    this.hangDirectory = false;
    this.hangOnce = new Set();
    this.readPlan = {};
    this.removeDelayMs = 0;
    this.directoryCalls = 0;
    this.writes = {};
  }
  getDirectory() {
    this.directoryCalls += 1;
    return this.hangDirectory ? never() : Promise.resolve(this.root);
  }
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
    if (this.storage.removeDelayMs) await later(this.storage.removeDelayMs);
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
    const plan = storage.readPlan[this.name];
    if (plan) return Promise.resolve({size: file.size, text: () => file.text(), stream: () => plannedStream(entry.data, plan)});
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
// A stored copy's read as a byte stream of 64 KiB pieces: with blockMs, its first
// read keeps the page busy that long (a synchronous wait, as the engine's setup on a
// slow phone) and its data then comes in a later task; with stopAfter, it gives that
// many pieces and then nothing more.
function plannedStream(data, {blockMs = 0, stopAfter = Infinity} = {}) {
  let offset = 0;
  let given = 0;
  const give = (controller) => {
    if (offset >= data.byteLength) {
      controller.close();
      if (controller.byobRequest) controller.byobRequest.respond(0);
      return;
    }
    const request = controller.byobRequest;
    const n = Math.min(65536, data.byteLength - offset, request ? request.view.byteLength : Infinity);
    if (request) {
      request.view.set(data.subarray(offset, offset + n));
      request.respond(n);
    } else {
      controller.enqueue(data.slice(offset, offset + n));
    }
    offset += n;
    given += 1;
  };
  return new ReadableStream({
    type: 'bytes',
    pull(controller) {
      if (given >= stopAfter) return never();
      if (blockMs > 0 && given === 0) {
        const until = Date.now() + blockMs;
        while (Date.now() < until) { /* the page is busy */ }
        return new Promise((resolve) => setTimeout(() => {
          try {
            give(controller);
          } catch (err) {
            // The page gave up on the read and cancelled it.
          }
          resolve();
        }, 0));
      }
      give(controller);
      return undefined;
    },
  });
}
// Web Locks with ifAvailable: busy denies every request, as when another tab holds it;
// hang never answers; requests counts them.
class Locks {
  constructor({busy = false, hang = false} = {}) { this.busy = busy; this.hang = hang; this.held = new Set(); this.requests = 0; }
  async request(name, options, callback) {
    this.requests += 1;
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
// it or fails, never from the network, unless onlyIfCachedDownloads (as WebKit does: a
// whole download). downloads counts the network's answers, hits the cache's.
// truncate[name] = n: the next n downloads of it end cleanly at half; fail[name] = n:
// the next n error at half.
class Server {
  constructor(files) { Object.assign(this, {files, downloads: {}, hits: {}, modes: {}, truncate: {}, fail: {}, httpCache: new Set(), byteStreams: true, onlyIfCachedDownloads: false}); }
  count(name) { return this.downloads[name] || 0; }
  fetch(name, init = {}) {
    const mode = init.cache || 'default';
    (this.modes[name] ||= []).push(mode);
    const data = this.files[name];
    if (mode === 'only-if-cached' && !this.onlyIfCachedDownloads) {
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
async function load(b, {storage, locks, server, canWrite = true, stallMs, store = true}) {
  const marks = [];
  const env = {store, storage, locks, canWrite, stallMs, fetch: (n, init) => server.fetch(n, init), mark: (m) => marks.push(m), warn: () => {}};
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
{ // A stored copy's read: data that comes after the page was busy for longer than the
  // stall limit is still used; a read that stops falls back to the network soon after it.
  const storage = new Storage(); const locks = new Locks(); const server = serverFor(A);
  await load(A, {storage, locks, server});
  storage.readPlan[A.pack[0]] = {blockMs: 2500};
  const busy = await load(A, {storage, locks, server, stallMs: 300});
  check(got(busy, A) && busy.from.join() === 'device' && server.count(A.pack[0]) === 1 && busy.ms >= 2500, `busy page during the read: came from ${busy.from} (${server.count(A.pack[0])} downloads in all) in ${busy.ms} ms`);
  storage.readPlan[A.pack[0]] = {stopAfter: 2};
  const stopped = await load(A, {storage, locks, server, stallMs: 300});
  check(got(stopped, A) && stopped.from.join() === 'device,network' && server.count(A.pack[0]) === 2 && stopped.ms < 2000, `a read that stops: came from ${stopped.from} in ${stopped.ms} ms`);
}
{ // Once the pack is in, "Saving…" lasts only until the copy is written, though the
  // engine may still be getting ready; without a store the engine starts at once.
  const storage = new Storage(); storage.writeDelayMs = 5; const locks = new Locks(); const server = serverFor(A);
  const env = {store: true, storage, locks, canWrite: true, fetch: (n, init) => server.fetch(n, init), mark: () => {}, warn: () => {}};
  const files = tiBuildFiles(A.name, env);
  await files.pack(A.pack[0], A.pack[1].byteLength, () => {});
  const steps = [];
  let engineReady = false;
  tiAfterDownload(files, (step) => steps.push([step, files.saving(), engineReady]));
  check(steps.length === 1 && steps[0][0] === 'saving' && steps[0][1], `after the download: ${JSON.stringify(steps)}, not "saving" while the copy is written`);
  for (let i = 0; i < 400 && steps.length < 2; i += 1) await later(5);
  check(steps.length === 2 && steps[1][0] === 'starting' && !steps[1][1] && !steps[1][2], `after the copy is written: ${JSON.stringify(steps)}, not "starting" before the engine is ready`);
  engineReady = true;
  await files.finish();
  const again = tiBuildFiles(A.name, env);
  await again.pack(A.pack[0], A.pack[1].byteLength, () => {});
  const steps2 = [];
  tiAfterDownload(again, (step) => steps2.push(step));
  check(steps2.join() === 'starting', `a launch from the device: steps ${steps2}`);
  await again.finish();
}
{ // A store that fails: "Saving…" doesn't show once it has failed, and ends at once when
  // it fails while shown, before its clean-up (here a slow one) is over.
  const make = () => {
    const storage = new Storage(); const server = serverFor(A);
    const env = {store: true, storage, locks: new Locks(), canWrite: true, fetch: (n, init) => server.fetch(n, init), mark: () => {}, warn: () => {}};
    return {storage, files: tiBuildFiles(A.name, env)};
  };
  const early = make();
  early.storage.failWriteAfter = 200000;
  early.storage.removeDelayMs = 1500;
  await early.files.pack(A.pack[0], A.pack[1].byteLength, () => {});
  await later(50);
  const steps = [];
  tiAfterDownload(early.files, (step) => steps.push(step));
  check(steps.join() === 'starting', `a store that failed during the download: steps ${steps}, not "starting" at once`);
  await early.files.finish();
  const late = make();
  late.storage.writeDelayMs = 40;
  late.storage.failWriteAfter = A.pack[1].byteLength - 1000;
  late.storage.removeDelayMs = 1500;
  await late.files.pack(A.pack[0], A.pack[1].byteLength, () => {});
  const steps2 = [];
  const shown = Date.now();
  tiAfterDownload(late.files, (step) => steps2.push([step, Date.now() - shown]));
  for (let i = 0; i < 300 && steps2.length < 2; i += 1) await later(5);
  check(steps2.length === 2 && steps2[0][0] === 'saving' && steps2[1][0] === 'starting' && steps2[1][1] < 1000, `a store that fails while "Saving…" shows: ${JSON.stringify(steps2)}, not "starting" before its clean-up`);
  await late.files.finish();
  check(!marked(late.storage, A) && late.storage.folder(FOLDER, A.name)?.entries.has(A.pack[0]) !== true, 'a store that failed left its file');
}
{ // Storing off (an iPhone or iPad, or ?store=0): no storage call, no stored copy read,
  // a plain download as before; and the switch.
  const storage = new Storage(); const locks = new Locks(); const server = serverFor(A);
  await load(A, {storage, locks, server});
  const callsBefore = storage.directoryCalls; const requestsBefore = locks.requests;
  const off = await load(A, {storage, locks, server, store: false});
  check(got(off, A) && off.from.join() === 'network' && server.modes[A.pack[0]].slice(-1).join() === 'default' && server.modes[A.pack[0]].length === 3, `storing off: came from ${off.from}, fetched ${server.modes[A.pack[0]]}`);
  check(storage.directoryCalls === callsBefore && locks.requests === requestsBefore && off.marks.includes('cache:off'), `storing off: ${storage.directoryCalls - callsBefore} file system and ${locks.requests - requestsBefore} lock calls`);
  check(!off.savingAfterPack && off.buffers === 1, `storing off: saving() ${off.savingAfterPack}, ${off.buffers} buffers of the pack's size`);
  const iPhone = 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Mobile/15E148 Safari/604.1';
  const iPad = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15';
  const android = 'Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36';
  const decisions = [
    ['an iPhone', tiStoreOnThisDevice('', tiAppleTouchDevice(iPhone, 5)), false],
    ['an iPad asking for desktop sites', tiStoreOnThisDevice('', tiAppleTouchDevice(iPad, 5)), false],
    ['a Mac', tiStoreOnThisDevice('', tiAppleTouchDevice(iPad, 0)), true],
    ['an Android phone', tiStoreOnThisDevice('', tiAppleTouchDevice(android, 5)), true],
    ['an iPhone with ?store=1', tiStoreOnThisDevice('?store=1', tiAppleTouchDevice(iPhone, 5)), true],
    ['a Mac with ?store=0', tiStoreOnThisDevice('?x=2&store=0', tiAppleTouchDevice(iPad, 0)), false],
  ];
  for (const [what, shownStore, want] of decisions) check(shownStore === want, `the switch on ${what}: ${shownStore}, not ${want}`);
}
{ // A browser that answers 'only-if-cached' from the network (WebKit): that answer is the
  // download, read and stored as one, with no second request.
  const storage = new Storage(); const server = serverFor(A);
  server.onlyIfCachedDownloads = true;
  const r = await load(A, {storage, locks: new Locks(), server});
  check(got(r, A) && r.from.join() === 'network' && r.progress === A.pack[1].byteLength && stored(storage, A), `only-if-cached from the network: came from ${r.from}, stored ${stored(storage, A)}`);
  check(server.count(A.pack[0]) === 1 && server.modes[A.pack[0]].join() === 'only-if-cached', `only-if-cached from the network: ${server.count(A.pack[0])} downloads, fetched ${server.modes[A.pack[0]]}`);
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
    [line(true, {loaded: 0, total: 100}, {loaded: 0, total: 0, from: null}), `Loading the${nb}game…`, 'an unknown source'],
    [line(true, {loaded: 60, total: 100}, {loaded: 0, total: 0, from: null}), `Loading the${nb}game…`, 'an unknown source while the engine loads'],
    [line(true, {loaded: 100, total: 100}, {loaded: 300, total: 300, from: null}), `Loading the${nb}game…`, 'an unknown source with every size known'],
    [line(true, {loaded: 0, total: 100}, {loaded: 0, total: 300, from: 'network'}), `Downloading the${nb}game: 0%`, 'the network, at the start'],
    [line(true, {loaded: 50, total: 100}, {loaded: 150, total: 300, from: 'network'}), `Downloading the${nb}game: 50%`, 'the network'],
    [line(true, {loaded: 100, total: 100}, {loaded: 300, total: 300, from: 'device'}), `Loading the game from this${nb}device: 100%`, 'the device'],
    [line(true, {loaded: 10, total: 100}, null), `Downloading the${nb}game: 10%`, 'the engine loading the pack'],
    [line(true, {loaded: 5, total: 0}, null), `Downloading the${nb}game…`, 'an export without sizes'],
  ];
  for (const [shown, want, what] of cases) check(shown && shown.text === want, `line for ${what}: ${shown ? JSON.stringify(shown.text) : 'none'}, not ${JSON.stringify(want)}`);
  check(cases[5][0].done && !cases[4][0].done && !cases[2][0].done, 'line: done at 100% only, never while the source is unknown');
}

// Releasing the pack once play is ready (tiPackDirectory, tiReleasedPack, tiPackRelease).
// A pack as Godot 4.7.2 writes one (format 3, offsets from the end of its 112-byte
// header, files 16-byte aligned, the directory after them; names padded to 4 bytes),
// FILES [path, size] in order, each file's bytes from bytes(size, seed).
function makePack(files, {version = 3, flags = 2} = {}) {
  const parts = [];
  let at = 112;
  for (const [path, size] of files) {
    at = Math.ceil(at / 16) * 16;
    parts.push({path, size, at, data: bytes(size, path.length * 7 + size)});
    at += size;
  }
  const names = parts.map((p) => new TextEncoder().encode(p.path));
  const padded = names.map((n) => Math.ceil((n.length + 1) / 4) * 4);
  const dirAt = Math.ceil(at / 16) * 16;
  const total = dirAt + 4 + padded.reduce((n, l) => n + 4 + l + 8 + 8 + 16 + 4, 0);
  const out = new Uint8Array(total);
  const view = new DataView(out.buffer);
  view.setUint32(0, 0x43504447, true);
  view.setUint32(4, version, true);
  view.setUint32(8, 4, true); view.setUint32(12, 7, true); view.setUint32(16, 2, true);
  view.setUint32(20, flags, true);
  view.setBigUint64(24, 112n, true);
  view.setBigUint64(32, BigInt(dirAt), true);
  for (const p of parts) out.set(p.data, p.at);
  let d = dirAt;
  view.setUint32(d, parts.length, true); d += 4;
  parts.forEach((p, i) => {
    view.setUint32(d, padded[i], true); d += 4;
    out.set(names[i], d); d += padded[i];
    view.setBigUint64(d, BigInt(p.at - 112), true); d += 8;
    view.setBigUint64(d, BigInt(p.size), true); d += 8 + 16 + 4;
  });
  return {pack: out, files: Object.fromEntries(parts.map((p) => [p.path, p]))};
}
// MEMFS's read (Emscripten, as the engine script has it): through contents.subarray() for
// more than 8 bytes, else byte by byte; never past the file's size.
function memfsRead(node, position, length) {
  const contents = node.contents;
  if (position >= node.usedBytes) return new Uint8Array(0);
  const size = Math.min(node.usedBytes - position, length);
  const out = new Uint8Array(size);
  if (size > 8 && contents.subarray) out.set(contents.subarray(position, position + size), 0);
  else for (let i = 0; i < size; i += 1) out[i] = contents[position + i];
  return out;
}
const throwsEio = (fn) => { try { fn(); return false; } catch (e) { return e.name === 'ErrnoError' && e.errno === 29; } };
const FILES = [['generated/build_stamp.json', 75], ['generated/web/static_world.scn', 300001], ['game/a.gd.remap', 40],
  ['.godot/imported/a.png-1.s3tc.ctex', 70000], ['.godot/imported/a.png-1.etc2.ctex', 50000], ['game/a.png.import', 300],
  ['.godot/imported/b.ogg-2.oggvorbisstr', 3], ['game/credits.json', 9000], ['project.binary', 1200]];
{ // The pack's directory, and what it refuses.
  const {pack, files} = makePack(FILES);
  const dir = tiPackDirectory(pack);
  check(dir && dir.entries.length === FILES.length && dir.entries.every((e) => files[e.path] && e.offset === files[e.path].at && e.size === files[e.path].size),
    `directory: ${dir ? JSON.stringify(dir.entries.slice(0, 2)) : 'none'}, not the pack's files`);
  const v2 = makePack(FILES, {version: 4});
  check(tiPackDirectory(v2.pack) !== null, 'directory: format 4 does not read');
  for (const [what, damage] of [['another magic', (p) => { p[0] = 0; }], ['an encrypted directory', (p) => { p[20] |= 1; }],
    ['a sparse bundle', (p) => { p[20] |= 4; }], ['a cut directory', null],
    ['a file past its end', (p) => { const v = new DataView(p.buffer); const at = Number(v.getBigUint64(32, true)) + 8 + v.getUint32(Number(v.getBigUint64(32, true)) + 4, true) + 8; v.setBigUint64(at, BigInt(p.byteLength), true); }],
    ['files that overlap', (p) => { const v = new DataView(p.buffer); const at = Number(v.getBigUint64(32, true)) + 8 + v.getUint32(Number(v.getBigUint64(32, true)) + 4, true) + 8; v.setBigUint64(at, 100n, true); }]]) {
    const copy = what === 'a cut directory' ? pack.slice(0, pack.byteLength - 20) : pack.slice();
    if (damage) damage(copy);
    check(tiPackDirectory(copy) === null, `directory: read a pack with ${what}`);
  }
}
{ // The released pack's contents: every kept byte, as before; released files read as an I/O error.
  const {pack, files} = makePack(FILES);
  const original = pack.slice();
  const dir = tiPackDirectory(pack);
  const gone = new Set(['generated/web/static_world.scn', '.godot/imported/a.png-1.s3tc.ctex', '.godot/imported/a.png-1.etc2.ctex', '.godot/imported/b.ogg-2.oggvorbisstr']);
  const released = dir.entries.filter((e) => gone.has(e.path));
  const misses = [];
  const made = tiReleasedPack(pack, released, (entry, position, length) => misses.push([entry && entry.path, position, length]));
  const node = {usedBytes: pack.byteLength, contents: made.contents};
  const releasedBytes = released.reduce((n, e) => n + e.size, 0);
  check(made.keptBytes === pack.byteLength - releasedBytes, `released: keeps ${made.keptBytes} bytes, not ${pack.byteLength - releasedBytes}`);
  // The pack's own buffer can go: detached, every kept byte still reads.
  pack.buffer.transfer(0);
  check(pack.byteLength === 0, 'released: the test could not detach the pack');
  let same = true;
  for (const e of dir.entries) {
    if (gone.has(e.path)) continue;
    // As the engine reads a file: from its start, in pieces of 1 to 4096 bytes (stdio and the binary loader).
    for (let at = e.offset, n = 1; at < e.offset + e.size; at += n, n = (n * 7 + 3) % 4096 + 1) {
      const want = original.subarray(at, Math.min(at + n, e.offset + e.size));
      const got = memfsRead(node, at, want.byteLength);
      if (Buffer.compare(Buffer.from(got), Buffer.from(want)) !== 0) { same = false; break; }
    }
  }
  check(same, 'released: a kept file reads other bytes than the pack had');
  const header = memfsRead(node, 0, 112);
  check(Buffer.compare(Buffer.from(header), Buffer.from(original.subarray(0, 112))) === 0, 'released: the header reads other bytes');
  check(misses.length === 0, `released: kept reads counted as misses: ${JSON.stringify(misses)}`);
  // stdio's read-ahead past a kept file into a released one: the kept bytes, then zeros.
  const stamp = files['generated/build_stamp.json'];
  const ahead = memfsRead(node, stamp.at + 10, 1024);
  const keptPart = stamp.size - 10 + (files['generated/web/static_world.scn'].at - stamp.at - stamp.size);
  check(Buffer.compare(Buffer.from(ahead.subarray(0, keptPart)), Buffer.from(original.subarray(stamp.at + 10, stamp.at + 10 + keptPart))) === 0
    && ahead.subarray(keptPart).every((b) => b === 0) && made.state().spills === 1 && misses.length === 0, 'released: a read on past a kept file into a released one is not its kept bytes, then zeros');
  // A read that starts in a released file, large or byte by byte: an I/O error naming it.
  const world = files['generated/web/static_world.scn'];
  check(throwsEio(() => memfsRead(node, world.at, 4096)), 'released: a read of the released world is no I/O error');
  check(throwsEio(() => memfsRead(node, world.at + 100, 4)), 'released: a 4-byte read of the released world is no I/O error');
  const tiny = files['.godot/imported/b.ogg-2.oggvorbisstr'];
  check(throwsEio(() => memfsRead(node, tiny.at, 3)), 'released: a read of a released 3-byte file is no I/O error');
  check(misses.length === 3 && misses[0][0] === world.path && misses[2][0] === tiny.path && made.state().misses === 3, `released: misses ${JSON.stringify(misses)}`);
  // The last file before the directory, and past the end, read as MEMFS does.
  const last = files['project.binary'];
  check(Buffer.compare(Buffer.from(memfsRead(node, last.at, last.size + 50000)), Buffer.from(original.subarray(last.at, original.byteLength))) === 0, 'released: the pack\'s end reads other bytes');
}
{ // The page's side: a request, the swap in a task of its own, the buffer freed once the store stops writing.
  const {pack, files} = makePack(FILES);
  const original = pack.slice();
  const buffer = pack.buffer;
  let storeDone = null;
  const storeOver = new Promise((resolve) => { storeDone = resolve; });
  const marks = [];
  const errors = [];
  const node = {usedBytes: buffer.byteLength, contents: new Uint8Array(buffer)};
  const env = {node: () => node, saved: () => storeOver, later: (fn) => setTimeout(fn, 0), now: () => performance.now(),
    log: () => {}, error: (...a) => errors.push(a.join(' ')), mark: (m) => marks.push(m)};
  const page = tiPackRelease(buffer, env);
  const request = JSON.stringify({drop: ['res://.godot/imported/a.png-1.s3tc.ctex', 'res://.godot/imported/a.png-1.etc2.ctex', 'res://.godot/imported/not-in-the-pack.ctex'], once: ['res://generated/web/static_world.scn']});
  const answer = page.release(request);
  check(answer === 'scheduled' && node.contents instanceof Uint8Array, `page: the request answered ${answer}, or the swap ran inside the game's call`);
  await later(10);
  const st = page.state();
  check(st.status === 'released' && st.files === 3 && st.unknown === 1 && st.released_bytes === 300001 + 70000 + 50000 && !(node.contents instanceof Uint8Array),
    `page: after the swap ${JSON.stringify(st)}`);
  check(buffer.byteLength === original.byteLength, 'page: the buffer was freed while the store may still write from it');
  storeDone();
  await later(10);
  check(page.state().status === 'freed' && page.state().freed === 'detached' && buffer.byteLength === 0 && marks.join() === 'pack:released,pack:freed',
    `page: once the store stopped, ${JSON.stringify(page.state())}, buffer ${buffer.byteLength} bytes, marks ${marks}`);
  const credits = files['game/credits.json'];
  check(Buffer.compare(Buffer.from(memfsRead(node, credits.at, credits.size)), Buffer.from(original.subarray(credits.at, credits.at + credits.size))) === 0, 'page: a kept file reads other bytes after the free');
  check(throwsEio(() => memfsRead(node, files['.godot/imported/a.png-1.etc2.ctex'].at, 100)) && errors.length === 1 && errors[0].includes('a.png-1.etc2.ctex') && marks.includes('pack:miss'),
    `page: a read of a released file: errors ${JSON.stringify(errors)}`);
  check(page.release(request) === 'freed', 'page: a second request was taken');
}
{ // The page keeps the whole pack when anything is unexpected, and frees nothing.
  const refusals = [
    ['no engine file (a build without the patch)', (node) => null, '{"drop": ["res://game/credits.json"]}'],
    ['the engine\'s file is a copy', (node) => ({...node, contents: node.contents.slice()}), '{"drop": ["res://game/credits.json"]}'],
    ['the file has another size', (node) => ({...node, usedBytes: node.usedBytes - 1}), '{"drop": ["res://game/credits.json"]}'],
    ['the lookup throws', () => { throw new Error('no such file'); }, '{"drop": ["res://game/credits.json"]}'],
    ['a request that does not read', (node) => node, 'not json'],
    ['a request naming no file of the pack', (node) => node, '{"drop": ["res://nothing.ctex"], "once": []}'],
  ];
  for (const [what, nodeOf, request] of refusals) {
    const {pack} = makePack(FILES);
    const buffer = pack.buffer;
    const node = {usedBytes: buffer.byteLength, contents: new Uint8Array(buffer)};
    const contents = node.contents;
    const page = tiPackRelease(buffer, {node: () => nodeOf(node), saved: () => Promise.resolve(), later: (fn) => setTimeout(fn, 0), now: () => 0,
      log: () => {}, error: () => {}, mark: () => {}});
    page.release(request);
    await later(10);
    check(page.state().status.startsWith('kept: ') && node.contents === contents && buffer.byteLength === pack.byteLength && page.release(request).startsWith('kept: '),
      `keeps the pack with ${what}: ${JSON.stringify(page.state())}, buffer ${buffer.byteLength} bytes`);
  }
}

if (failures.length > 0) {
  for (const failure of failures) console.log(`FAIL: ${failure}`);
  process.exit(1);
}
console.log('PASS: the page\'s build cache stores a build\'s pack (without a second copy in the HTTP cache), loads that build from the device without downloading, removes an older build once a new one is stored, never marks a short, long or failed download, ignores damaged copies, writes only with the lock, keeps one buffer through retries, keeps a stored copy through a busy page, falls back to the network without storage, when storage never answers or when a stored copy stops, shows "Saving…" only while a store is writing, makes no storage call with storing off (an iPhone or iPad, ?store=0), takes an only-if-cached answer from the network as its one download, its loading line is never blank and says "Downloading" only for the network, and once play is ready it frees the pack\'s released files: every kept byte still reads, a read of a released file is an I/O error that names it, a read running on past a kept file gets zeros, the buffer goes only once the store has stopped writing from it, and without the engine\'s own file of the pack or with a request it does not take it keeps the whole pack');
