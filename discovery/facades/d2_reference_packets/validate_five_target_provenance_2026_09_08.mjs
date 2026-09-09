import { existsSync, readFileSync, readdirSync } from "node:fs";
import { dirname, extname, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "../../..");
const D2_INDEX = "discovery/facades/d2_reference_packets/README.md";
const INVENTORY = "discovery/FACADE_RECEIVER_INVENTORY.json";
const CATALOG = "discovery/facades/facade-recognition-catalog.json";

const TARGETS = Object.freeze([
  {
    address: "1437 Chinook Court",
    easAddressId: "725379",
    easBaseId: "483588",
    geometrySha256: "e10a10f635c1647188f7b272484dc8b964fb735dddbb2df427be24df9533fbc9",
    packet: "discovery/facades/d2_reference_packets/w95934113_1437_chinook_court.md",
    readiness: "appearance-blocked",
    source: "w95934113",
  },
  {
    address: "1449 Croaker Court",
    easAddressId: "725328",
    easBaseId: "483538",
    geometrySha256: "b34ae7aafd99a7cfedae2c3122a62b9ff79cf3013738bee803ef84a9707bf35c",
    packet: "discovery/facades/d2_reference_packets/w95934120_1449_croaker_court.md",
    readiness: "appearance-blocked",
    source: "w95934120",
  },
  {
    address: "1438 Chinook Court",
    easAddressId: "725385",
    easBaseId: "483594",
    geometrySha256: "bb6a17e66f79e8dd2922d7b74e4288dd6e478a4b82a3893d29d95afa7ebdc899",
    packet: "discovery/facades/d2_reference_packets/w95934131_1438_chinook_court.md",
    readiness: "appearance-blocked",
    source: "w95934131",
  },
  {
    address: "1436 Chinook Court",
    easAddressId: "725378",
    easBaseId: "483587",
    geometrySha256: "b3a6a5713c6f590cd6edbfc57947114e09176ab01ebc645f3a3eee7d2fd5e397",
    packet: "discovery/facades/d2_reference_packets/w95934137_1436_chinook_court.md",
    readiness: "target-front component/prototype-ready; detached study only",
    source: "w95934137",
  },
  {
    address: "1431 Halibut Court",
    easAddressId: "725353",
    easBaseId: "483562",
    geometrySha256: "034aacffde9a58b3cee515d7fdaeaa17cec4d2baeb6ae7a9d663e7170a39cb6f",
    packet: "discovery/facades/d5_reference_packets/w95934135_1431_halibut_court.md",
    readiness: "target-side prototype-ready; detached study only",
    source: "w95934135",
  },
]);

function invariant(condition, message) {
  if (!condition) throw new Error(message);
}

function absolute(relativePath) {
  const result = resolve(ROOT, relativePath);
  invariant(
    result === ROOT || result.startsWith(`${ROOT}${sep}`),
    `Path escapes repository: ${relativePath}`,
  );
  return result;
}

function read(relativePath) {
  return readFileSync(absolute(relativePath), "utf8");
}

function readJson(relativePath) {
  return JSON.parse(read(relativePath));
}

function validateLocalLinks(relativePath, text) {
  for (const match of text.matchAll(/\[[^\]]*\]\(([^)]+)\)/g)) {
    const link = match[1];
    if (/^(?:https?:|mailto:|#)/.test(link)) continue;
    const localPath = decodeURIComponent(link.split("#")[0].split("?")[0]);
    const resolved = resolve(dirname(absolute(relativePath)), localPath);
    invariant(existsSync(resolved), `${relativePath} has broken local link ${link}`);
  }
}

const inventory = readJson(INVENTORY);
const catalog = readJson(CATALOG);
const d2Index = read(D2_INDEX);
const ledger = d2Index
  .split("## 2026-09-08 five-target provenance ledger")[1]
  ?.split("## Authoritative corrections and lifecycle boundary")[0];

invariant(ledger != null, "Five-target provenance ledger section is missing");
invariant(
  (ledger.match(/physical-building:/g) ?? []).length === TARGETS.length,
  "Five-target provenance ledger cardinality drifted",
);
invariant(d2Index.includes("**4/15** target-identifiable"), "D2 target-observation count drifted");
invariant(d2Index.includes("**1/15** additional"), "D2 component-study count drifted");
invariant(d2Index.includes("**10/15**"), "D2 blocked-prototype count drifted");
invariant(
  /No\s+panorama pixels may be copied, embedded, trained into, or shipped as textures\./.test(
    d2Index,
  ),
  "D2 no-pixel boundary drifted",
);

for (const target of TARGETS) {
  const packet = read(target.packet);
  const inventoryObject = inventory.objects.find(
    (candidate) => candidate.source.source_key === target.source,
  );
  const catalogUnit = catalog.units.find(
    (candidate) => candidate.unit_id === `physical-building:${target.source}`,
  );

  invariant(inventoryObject != null, `${target.source} is missing from receiver inventory`);
  invariant(catalogUnit != null, `${target.source} is missing from recognition catalog`);
  invariant(
    inventoryObject.identity.address.formatted === target.address,
    `${target.source} frozen address drifted`,
  );
  invariant(
    inventoryObject.source_geometry.geometry_sha256 === target.geometrySha256,
    `${target.source} inventory geometry hash drifted`,
  );
  invariant(
    inventoryObject.generated_receiver.direct_wall_object_keys.includes(
      `building:${target.source}:wall`,
    ),
    `${target.source} direct wall receiver drifted`,
  );
  invariant(
    inventoryObject.generated_receiver.direct_roof_object_keys.includes(
      `building:${target.source}:roof`,
    ),
    `${target.source} direct roof receiver drifted`,
  );
  invariant(
    catalogUnit.claim_status.reference_recognizable !== "accepted" &&
      catalogUnit.acceptance_records.length === 0,
    `${target.source} unexpectedly has recognition acceptance authority`,
  );

  for (const literal of [
    `physical-building:${target.source}`,
    `building:${target.source}:wall`,
    `building:${target.source}:roof`,
    target.geometrySha256,
    `eas_baseid=${target.easBaseId}`,
    `eas_address_id=${target.easAddressId}`,
    `Readiness: **${target.readiness}**`,
    "`verified_fact`",
    "`reference_observation`",
    "`production_inference`",
    "`unknown`",
  ]) {
    invariant(packet.includes(literal), `${target.source} packet is missing ${literal}`);
  }

  invariant(
    ledger.includes(`physical-building:${target.source}`),
    `${target.source} is absent from the five-target ledger`,
  );
  validateLocalLinks(target.packet, packet);
}

const packet1431 = read(TARGETS.find((target) => target.source === "w95934135").packet);
invariant(
  !packet1431.includes("`CITY-EAS` record `483562`"),
  "1431 retains the ambiguous EAS base-ID wording",
);
invariant(
  /does\s+not authorize live attachment, whole-building completion, or acceptance/.test(
    packet1431,
  ),
  "1431 research-only boundary drifted",
);

const packet1436 = read(TARGETS.find((target) => target.source === "w95934137").packet);
invariant(packet1436.includes("Photo 35"), "1436 caption binding is missing");
invariant(packet1436.includes("ENE run family `0,1,8,16`"), "1436 ENE inference is missing");
invariant(packet1436.includes("does not authorize live attachment or acceptance"), "1436 research-only boundary drifted");

for (const source of ["w95934113", "w95934120", "w95934131"]) {
  const packet = read(TARGETS.find((target) => target.source === source).packet);
  invariant(packet.includes("appearance cues remain **zero**"), `${source} zero-cue boundary drifted`);
}

validateLocalLinks(D2_INDEX, d2Index);

const d2PacketFiles = readdirSync(dirname(absolute(D2_INDEX))).filter(
  (name) => extname(name) === ".md" && name !== "README.md",
);
invariant(d2PacketFiles.length === 15, `Expected 15 D2 source packets, found ${d2PacketFiles.length}`);

process.stdout.write(`${JSON.stringify({
  catalog_acceptance_status: "unchanged/unaccepted",
  d2_packet_count: d2PacketFiles.length,
  ledger_target_count: TARGETS.length,
  local_links: "pass",
  no_pixel_boundary: "pass",
  status: "pass",
  target_packet_count: TARGETS.length,
}, null, 2)}\n`);
