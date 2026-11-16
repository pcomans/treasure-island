#!/usr/bin/env node
// Checks the web page's build cache (tiBuildFiles in game/web/shell.html): the page
// keeps a copy of a build's WebAssembly and data pack on the device, in the site's
// private file system, and loads the same build from it next time. This runs the
// shell's own function with stand-ins for the browser's file system (whose writable
// streams, like the browser's, change a file only when closed), Web Locks and fetch,
// and checks what a player would see:
//   - the first load downloads both files and stores them; the next load of that
//     build downloads nothing and gets the same bytes;
//   - a new build downloads its own files and, once they are stored, removes the old
//     build's folder (and a disk failure while storing keeps the old one);
//   - a download that ends early or fails is never stored as complete: the pack is
//     downloaded again and the next load downloads again;
//   - a marker naming another size, a stored file of another size, or a stored file
//     that reads short is not used;
//   - without the lock (another tab is storing) a tab uses complete copies but writes
//     nothing; with no storage, storage that throws, or no writable streams, the files
//     come from the network as before;
//   - a disk slower than the download holds the download back without losing data.
// Node only, no network and no engine; a few seconds. Part of tools/test.sh.
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
const tiBuildFiles = new Function(`${script}\nreturn tiBuildFiles;`)();

const failures = [];
const check = (ok, what) => { if (!ok) failures.push(what); };
const notFound = () => Object.assign(new Error('not found'), {name: 'NotFoundError'});
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
// whose stored copy reads short).
class Storage {
  constructor() {
    this.root = new Folder(this);
    this.failWriteAfter = Infinity;
    this.writeDelayMs = 0;
    this.shortRead = new Set();
  }
  async getDirectory() { return this.root; }
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
  async getFile() {
    const entry = this.folder.entries.get(this.name);
    if (!entry || entry instanceof Folder) throw notFound();
    const file = new File([entry.data], this.name);
    if (!this.folder.storage.shortRead.has(this.name)) return file;
    const short = new File([entry.data.subarray(0, entry.data.byteLength >> 1)], this.name);
    return {size: file.size, text: () => file.text(), stream: () => short.stream()};
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
      },
      async close() {
        const entry = folder.entries.get(name);
        if (entry && !(entry instanceof Folder)) entry.data = new Uint8Array(Buffer.concat(chunks.map((c) => Buffer.from(c))));
      },
      async abort() { chunks.length = 0; },
    };
  }
}
// Web Locks with ifAvailable: busy denies every request, as when another tab holds it.
class Locks {
  constructor(busy = false) { this.busy = busy; this.held = new Set(); }
  async request(name, options, callback) {
    if (this.busy || this.held.has(name)) return callback(null);
    this.held.add(name);
    try { return await callback({name}); } finally { this.held.delete(name); }
  }
}
// The server: each file's bytes in 64 KiB chunks. truncate[name] = n: the next n
// downloads of it end cleanly at half; fail[name] = n: the next n error at half.
class Server {
  constructor(files) { this.files = files; this.calls = {}; this.truncate = {}; this.fail = {}; }
  count(name) { return this.calls[name] || 0; }
  fetch(name) {
    this.calls[name] = this.count(name) + 1;
    const data = this.files[name];
    if (!data) return Promise.resolve(new Response('missing', {status: 404}));
    const cut = (this.truncate[name] || 0) > 0 ? (this.truncate[name] -= 1, 'end') : (this.fail[name] || 0) > 0 ? (this.fail[name] -= 1, 'error') : null;
    let offset = 0;
    const stop = cut ? data.byteLength >> 1 : data.byteLength;
    return Promise.resolve(new Response(new ReadableStream({
      pull(controller) {
        if (offset >= stop) {
          if (cut === 'error') controller.error(new TypeError('network error')); else controller.close();
          return;
        }
        const n = Math.min(65536, stop - offset);
        controller.enqueue(data.slice(offset, offset + n));
        offset += n;
      },
    })));
  }
}

const FOLDER = 'grand-treasure-island-builds';
const build = (name, wasmSize = 300000, packSize = 1000003, seed = 1) => ({
  name,
  wasm: [`${name}.wasm`, bytes(wasmSize, seed)],
  pack: [`${name}.pck`, bytes(packSize, seed + 1)],
});
const serverFor = (...builds) => new Server(Object.fromEntries(builds.flatMap((b) => [b.wasm, b.pack])));
// One page load of build B, as the shell does it: the engine's WebAssembly response,
// the pack's buffer, then finish(). Returns what the page got and where from.
async function load(b, {storage, locks, server, canWrite = true}) {
  const marks = [];
  const env = {storage, locks, canWrite, fetch: (n) => server.fetch(n), mark: (m) => marks.push(m), warn: () => {}};
  const files = tiBuildFiles(b.name, env);
  let wasmFrom = null;
  const packFrom = new Set();
  let packProgress = 0;
  let wasm = null;
  let wasmError = null;
  try {
    const response = await files.wasm(b.wasm[0], b.wasm[1].byteLength, (from) => { wasmFrom = from; });
    wasm = new Uint8Array(await response.arrayBuffer());
  } catch (err) {
    wasmError = err;
  }
  let pack = null;
  let error = null;
  try {
    pack = new Uint8Array(await files.pack(b.pack[0], b.pack[1].byteLength, (n, from) => { packFrom.add(from); packProgress = n; }));
  } catch (err) {
    error = err;
  }
  await files.finish();
  return {wasm, wasmError, pack, error, wasmFrom, packFrom: [...packFrom], packProgress, marks};
}
// Whether build B's file NAME is stored complete: the file and a marker naming its size.
const stored = (storage, b, which) => {
  const folder = storage.folder(FOLDER, b.name);
  const [name, data] = b[which];
  const file = folder && folder.entries.get(name);
  const marker = folder && folder.entries.get(`${name}.complete`);
  return Boolean(file && marker && same(file.data, data) && new TextDecoder().decode(marker.data) === String(data.byteLength));
};
const marked = (storage, b, which) => Boolean(storage.folder(FOLDER, b.name)?.entries.has(`${b[which][0]}.complete`));
const got = (r, b) => r.wasm !== null && same(r.wasm, b.wasm[1]) && r.pack !== null && same(r.pack, b.pack[1]);

const A = build('treasure-island-aaaaaaa', 300000, 1000003, 1);
const B = build('treasure-island-bbbbbbb', 310000, 1100005, 7);

{ // A first load stores; the next load of that build downloads nothing.
  const storage = new Storage(); const locks = new Locks(); const server = serverFor(A, B);
  const first = await load(A, {storage, locks, server});
  check(got(first, A), 'first load: the page got other bytes than the server sent');
  check(first.wasmFrom === 'network' && first.packFrom.join() === 'network', `first load: came from ${first.wasmFrom}/${first.packFrom}, not the network`);
  check(stored(storage, A, 'wasm') && stored(storage, A, 'pack'), 'first load: the files were not stored complete with their markers');
  check(first.packProgress === A.pack[1].byteLength, 'first load: the pack progress did not reach its size');
  const second = await load(A, {storage, locks, server});
  check(got(second, A), 'second load: the page got other bytes than stored');
  check(server.count(A.wasm[0]) === 1 && server.count(A.pack[0]) === 1, `second load: downloaded again (wasm ${server.count(A.wasm[0])}, pack ${server.count(A.pack[0])} downloads in all)`);
  check(second.wasmFrom === 'device' && second.packFrom.join() === 'device', `second load: came from ${second.wasmFrom}/${second.packFrom}, not the device`);
  // A new build downloads its own files and then removes the old build's folder.
  const next = await load(B, {storage, locks, server});
  check(got(next, B) && server.count(B.pack[0]) === 1, 'new build: not downloaded once with the right bytes');
  check(stored(storage, B, 'wasm') && stored(storage, B, 'pack'), 'new build: not stored');
  check(storage.folder(FOLDER, A.name) === null, 'new build: the old build\'s folder is still there');
  check(locks.held.size === 0, 'the lock is still held after finish()');
}
{ // A download that ends early or fails is never stored as complete.
  const storage = new Storage(); const locks = new Locks(); const server = serverFor(A);
  server.truncate[A.pack[0]] = 1;
  server.fail[A.wasm[0]] = 1;
  const r = await load(A, {storage, locks, server});
  check(r.wasmError !== null, 'a WebAssembly download that failed half way did not fail');
  check(r.pack && same(r.pack, A.pack[1]) && server.count(A.pack[0]) === 2, 'a pack download that ended early was not downloaded again');
  check(stored(storage, A, 'pack'), 'the pack\'s complete second download was not stored');
  check(!marked(storage, A, 'wasm'), 'a WebAssembly download that failed half way was marked complete');
  // One that ends early without an error.
  const storage1 = new Storage(); const server1 = serverFor(A);
  server1.truncate[A.wasm[0]] = 1;
  const r1 = await load(A, {storage: storage1, locks, server: server1});
  check(r1.wasm !== null && r1.wasm.byteLength === A.wasm[1].byteLength >> 1 && !marked(storage1, A, 'wasm'), 'a WebAssembly download that ended early was marked complete');
  check(storage.folder(FOLDER, A.name)?.entries.has(A.wasm[0]) !== true, 'a WebAssembly download that failed left its file behind');
  // Every attempt ends early: the load fails and nothing is marked.
  const storage2 = new Storage(); const server2 = serverFor(A);
  server2.truncate[A.pack[0]] = 4;
  const r2 = await load(A, {storage: storage2, locks, server: server2});
  check(r2.error && /Failed loading file/.test(r2.error.message) && server2.count(A.pack[0]) === 4, `four short downloads: ${r2.error ? r2.error.message : 'no error'}, ${server2.count(A.pack[0])} attempts`);
  check(!marked(storage2, A, 'pack') && storage2.folder(FOLDER, A.name)?.entries.has(A.pack[0]) !== true, 'four short downloads: a pack was left stored');
  const r3 = await load(A, {storage: storage2, locks, server: server2});
  check(got(r3, A) && r3.packFrom.join() === 'network' && stored(storage2, A, 'pack'), 'after four short downloads the next load did not download and store the pack');
}
{ // A wrong marker, a stored file of another size or one that reads short is not used.
  for (const [which, harm] of [['pack', 'marker'], ['pack', 'size'], ['pack', 'short'], ['wasm', 'marker'], ['wasm', 'size']]) {
    const storage = new Storage(); const locks = new Locks(); const server = serverFor(A);
    await load(A, {storage, locks, server});
    const folder = storage.folder(FOLDER, A.name);
    const [name, data] = A[which];
    if (harm === 'marker') folder.entries.get(`${name}.complete`).data = new TextEncoder().encode('123');
    if (harm === 'size') folder.entries.get(name).data = data.slice(0, 1000);
    if (harm === 'short') storage.shortRead.add(name);
    const r = await load(A, {storage, locks, server});
    const from = which === 'pack' ? r.packFrom.includes('network') : r.wasmFrom === 'network';
    check(got(r, A) && server.count(name) === 2 && from, `${which} ${harm}: the damaged stored copy was used (${server.count(name)} downloads)`);
    storage.shortRead.clear();
    check(stored(storage, A, which), `${which} ${harm}: it was not stored again`);
  }
}
{ // Without the lock a tab uses complete copies but writes nothing.
  const storage = new Storage(); const server = serverFor(A, B);
  await load(A, {storage, locks: new Locks(), server});
  const busy = new Locks(true);
  const r = await load(A, {storage, locks: busy, server});
  check(got(r, A) && r.wasmFrom === 'device' && r.packFrom.join() === 'device', 'without the lock: the stored copies were not used');
  const rb = await load(B, {storage, locks: busy, server});
  check(got(rb, B) && rb.packFrom.join() === 'network', 'without the lock: the new build did not download');
  check(!storage.folder(FOLDER, B.name)?.entries.has(B.pack[0]) && storage.folder(FOLDER, A.name) !== null, 'without the lock: a tab wrote or removed something');
}
{ // No storage, storage that throws, or no writable streams: the network, as before.
  const throwing = {getDirectory: () => Promise.reject(new Error('SecurityError'))};
  for (const [what, storage, canWrite] of [['no storage', undefined, true], ['throwing storage', throwing, true], ['no createWritable', new Storage(), false]]) {
    const server = serverFor(A);
    const r = await load(A, {storage, locks: new Locks(), server, canWrite});
    check(got(r, A) && r.wasmFrom === 'network' && r.packFrom.join() === 'network', `${what}: did not load from the network`);
    if (storage instanceof Storage) check(storage.folder(FOLDER) === null, `${what}: wrote to storage`);
  }
}
{ // A disk that fails while storing loses the store, not the download, and keeps the old build.
  const storage = new Storage(); const locks = new Locks(); const server = serverFor(A, B);
  await load(A, {storage, locks, server});
  storage.failWriteAfter = 500000;
  const r = await load(B, {storage, locks, server});
  check(got(r, B), 'disk failure: the download did not complete');
  check(!marked(storage, B, 'pack') && !storage.folder(FOLDER, B.name)?.entries.has(B.pack[0]), 'disk failure: a partial pack was kept or marked');
  check(stored(storage, A, 'pack'), 'disk failure: the old build was removed although the new one was not stored');
}
{ // A disk slower than the download (and a queue past its limit) loses nothing.
  const big = build('treasure-island-ccccccc', 200000, 40 * 1024 * 1024 + 5, 3);
  const storage = new Storage(); storage.writeDelayMs = 2;
  const server = serverFor(big);
  const r = await load(big, {storage, locks: new Locks(), server});
  check(got(r, big) && stored(storage, big, 'pack'), 'slow disk: the pack was not loaded and stored complete');
}

if (failures.length > 0) {
  for (const failure of failures) console.log(`FAIL: ${failure}`);
  process.exit(1);
}
console.log('PASS: the page\'s build cache stores a build\'s files, loads that build from the device without downloading, removes an older build once a new one is stored, never marks a short or failed download, ignores damaged copies, writes only with the lock, and falls back to the network without storage');
